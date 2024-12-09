import h2d.Object;
import h2d.Bitmap;
import h2d.Graphics;

import h2d.col.Bounds;
import h2d.col.Point;
import hxd.Event;
import h3d.Vector;
import hxd.Key;

import ui.Touch;



class Texture extends h2d.Object {
	var editor:Editor;
	var s2d:h2d.Scene;

	var touch:Touch;
	var select:ui.Dropdown;

	public var width(default, set):Float = 0;
	public var height(default, set):Float = 0;
	public var zoom:Float = 1;

	public var atlas:Atlas;
	var selected:Null<String> = null;

	var view:Object;
	var back:Bitmap;
	var image:Bitmap;

	var selection:Graphics;


	public function new(?parent:h2d.Object) {
		super(parent);

		editor = Editor.ME;
		s2d = editor.s2d;

		touch = new Touch(width, height, this);
		touch.onPush = onDown;
		touch.onMove = onMove;
		touch.onRelease = onUp;
		//touch.onWheel = onWheel;

		touch.backgroundColor = 0x60000000;

		view = new h2d.Object(this);
		view.filter = new h2d.filter.DropShadow(5, Math.PI/4, 0, 0.25, 20.0, 1, 1.0, true);

		back = new Bitmap(h2d.Tile.fromColor(Style.selection, 128, 128), view);
		image = new Bitmap(h2d.Tile.fromColor(Style.white, 128, 128), view);

		selection = new Graphics(view);

		select = new ui.Dropdown(this, "Texture");
		select.onChange = onChange;
		select.setSize(100, 40);

		select.x = 10;
		select.y = 50;

		var icon = new h2d.Bitmap(Assets.icon("texture"), select);
		icon.tile.setCenterRatio();
		icon.x = icon.y = 20;

		visible = false;
	}


	public function set(name:String) {
		atlas = Assets.atlas.get(name);

		image.tile = atlas.tile;

		back.width = atlas.tile.width;
		back.height = atlas.tile.height;

		selection.visible = false;

		if (select.get(name) == null) select.add(name);
		setLabel(name);
		
		onResize();
	}


	public function open(?name:String) {
		if (atlas == null && name == null) return;
		if (name != null && atlas.name != name) set(name);
		
		touch.focus(); // TODO: Lock `Control` scroll
		visible = true;

		onResize();
	}


	public function close() {
		selected = null;
		selection.visible = false;
		visible = false;
	}


	public dynamic function onSelect(name:String) {}


	function onChange(value:String, type:String) {
		if (name != value) set(value);
	}


	function setLabel(value:String) {
		select.label.text = value;
		select.setSize(select.label.textWidth + 60, 40);
		select.label.x = 36;
	}


	function onDown(event:Event) {
		if (event.button == 0) {
			if (selected != null && selected != "") {
				onSelect(selected);
				close();
			}
			else {
				close();
			}

			touch.left = true;
		}

		if (event.button == 1) {
			touch.position.x = snap(s2d.mouseX - view.x);
			touch.position.y = snap(s2d.mouseY - view.y);

			touch.right = true;
		}
	}


	function onMove(event:Event) {
		if (!touch.right) {
			selected = null;

			var mouse = view.globalToLocal(new Point(s2d.mouseX, s2d.mouseY));
			selected = getObject(mouse.x, mouse.y);
		}

		if (touch.right) {
			view.x = snap(s2d.mouseX - touch.position.x);
			view.y = snap(s2d.mouseY - touch.position.y);

			select.x = view.x;
			select.y = view.y - 40;
		}
	}

	
	function onUp(event:Event) {
		touch.left = false;
		touch.right = false;
	}


	function onWheel(event:Event) {
		zoom -= event.wheelDelta * 0.05;

		if (zoom < 0.05) zoom = 0.05;
		if (zoom > 5) zoom = 5;

		zoom = snap(zoom, 0.01);

		var ratio = 1 - zoom / view.scaleX;

		view.x += (s2d.mouseX - view.x) * ratio;
		view.y += (s2d.mouseY - view.y) * ratio;
		
		view.scaleX = view.scaleY = zoom;
	}



	function getObject(x : Float, y : Float):String {
		var shape:String = "";

		if (atlas == null) return shape;

		for (tile in atlas.regions) {
			var xMin:Float = tile.x;
			var yMin:Float = tile.y;
		
			var xMax:Float = tile.x + tile.width;
			var yMax:Float = tile.y + tile.height;

			if (x >= xMin && x < xMax && y >= yMin && y < yMax) {
				if (shape != tile.name) {
					setCursor(xMin, yMin, tile.width, tile.height);

					shape = tile.name;

				}
				break;
			}
		}

		return shape;
	}


	function setCursor(xpos:Float = 0, ypos:Float =  0, w:Float, h:Float) {
		var line = 2 / zoom;

		selection.clear();
		selection.lineStyle(line, 0xFFE600);
		selection.drawRect(0, 0, w, h);

		selection.x = xpos;
		selection.y = ypos;

		selection.visible = true;
	}


	inline function snap(value:Float, step:Float = 1) {
		return Math.round(value / step) * step;
	}


	function set_width(v) {
		width = v;
		touch.width = width;
		return v;
	}


	function set_height(v) {
		height = v;
		touch.height = height;
		return v;
	}


	public function onView() {
		zoom = 1;
	}


	public function onResize() {
		var safeBorder = 128;

		var w = width - safeBorder;
		var h = height - safeBorder;

		var sx = w / image.tile.width;
		var sy = h / image.tile.height;

		zoom = Math.min(sx, sy);
		zoom = Math.min(zoom, 1);

		view.scaleX = view.scaleY = zoom;

		view.x = width * 0.5 - (image.tile.width * zoom) * 0.5;
		view.y = height * 0.5 - (image.tile.height * zoom) * 0.5;

		select.x = view.x;
		select.y = view.y - 40;
	}


	public function clear() {
		image.tile = h2d.Tile.fromColor(Style.white, 128, 128);
		
		select.clear();
		atlas = null;
	}
}


class Atlas {
	var contents : Map<String,Array<{ t : h2d.Tile, width : Int, height : Int }>>;

	public var regions:Array<{ name : String, x : Float, y : Float, width : Float, height : Float }> = [];

	public var name:String;
	public var entry:String;
	public var tile:h2d.Tile;


	public function new(n:String, e:String, t:h2d.Tile) {
		name = n;
		entry = e;
		tile = t;
		getContents();
	}


	function tileAlign( t : h2d.Tile, halign : h2d.Flow.FlowAlign, valign : h2d.Flow.FlowAlign, width : Int, height : Int ) {
		if( halign == null ) halign = Left;
		if( valign == null ) valign = Top;
		var dx = 0, dy = 0;
		switch( halign ) {
		case Middle:
			dx = width >> 1;
		case Right:
			dx = width;
		default:
		}
		switch( valign ) {
		case Middle:
			dy = height >> 1;
		case Bottom:
			dy = height;
		default:
		}
		return t.sub(0, 0, t.width, t.height, t.dx - dx, t.dy - dy);
	}

	public function get( name : String, ?horizontalAlign : h2d.Flow.FlowAlign, ?verticalAlign : h2d.Flow.FlowAlign ) : h2d.Tile {
		var c = getContents().get(name);
		if( c == null )
			return null;
		var t = c[0];
		if( t == null )
			return null;
		return tileAlign(t.t, horizontalAlign, verticalAlign, t.width, t.height);
	}

	public function getAnim( ?name : String, ?horizontalAlign : h2d.Flow.FlowAlign, ?verticalAlign : h2d.Flow.FlowAlign ) : Array<h2d.Tile> {
		if( name == null ) {
			var cont = getContents().keys();
			name = cont.next();
			if( cont.hasNext() )
				throw "Altas has several items in it " + Lambda.array( contents );
		}
		var c = getContents().get(name);
		if( c == null )
			return null;
		return [for( t in c ) if( t == null ) null else tileAlign(t.t, horizontalAlign, verticalAlign, t.width, t.height)];
	}

	public function getContents() {
		if( contents != null )
			return contents;

		contents = new Map();
		var lines = entry.split("\n");

		while( lines.length > 0 ) {
			var line = StringTools.trim(lines.shift());
			if ( line == "" ) continue;
			var scale = 1.;
			var file = tile;
			while( lines.length > 0 ) {
				if( lines[0].indexOf(":") < 0 ) break;
				var line = StringTools.trim(lines.shift()).split(": ");
				switch( line[0] ) {
				case "size":
					var wh = line[1].split(",");
					var w = Std.parseInt(wh[0]);
					scale = file.width / w;
				default:
				}
			}
			while( lines.length > 0 ) {
				var line = StringTools.trim(lines.shift());
				if( line == "" ) break;
				var prop = line.split(": ");
				if( prop.length > 1 ) continue;
				var key = line;
				var tileX = 0, tileY = 0, tileW = 0, tileH = 0, tileDX = 0, tileDY = 0, origW = 0, origH = 0, index = 0;
				while( lines.length > 0 ) {
					var line = StringTools.trim(lines.shift());
					var prop = line.split(": ");
					if( prop.length == 1 ) {
						lines.unshift(line);
						break;
					}
					var v = prop[1];
					switch( prop[0] ) {
					case "rotate":
						if( v == "true" ) throw "Rotation not supported in atlas";
					case "xy":
						var vals = v.split(",");
						tileX = Std.parseInt(vals[0]);
						tileY = Std.parseInt(StringTools.trim(vals[1]));
					case "size":
						var vals = v.split(",");
						tileW = Std.parseInt(vals[0]);
						tileH = Std.parseInt(StringTools.trim(vals[1]));
					case "offset":
						var vals = v.split(",");
						tileDX = Std.parseInt(vals[0]);
						tileDY = Std.parseInt(StringTools.trim(vals[1]));
					case "orig":
						var vals = v.split(",");
						origW = Std.parseInt(vals[0]);
						origH = Std.parseInt(StringTools.trim(vals[1]));
					case "index":
						index = Std.parseInt(v);
						if( index < 0 ) index = 0;
					default:
						trace("Unknown prop " + prop[0]);
					}
				}
				// offset is bottom-relative
				tileDY = origH - (tileH + tileDY);

				var t = file.sub(Std.int(tileX * scale), Std.int(tileY * scale), Std.int(tileW * scale), Std.int(tileH * scale), tileDX, tileDY);
				if( scale != 1 ) t.scaleToSize(tileW, tileH);
				var tl = contents.get(key);
				if( tl == null ) {
					tl = [];

					regions.push({ name : key, x : tileX * scale, y : tileY * scale, width : tileW * scale, height : tileH * scale });
					contents.set(key, tl);
				}
				tl[index] = { t : t, width : origW, height : origH };
			}
		}

		// remove first element if index started at 1 instead of 0
		for( tl in contents )
			if( tl.length > 1 && tl[0] == null ) tl.shift();
		return contents;
	}

}