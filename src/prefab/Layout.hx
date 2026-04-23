package prefab;

class Size {
	public var width(default, set):Int = 0;
	public var height(default, set):Int = 0;

	function set_width(v:Float) return width = Std.int(v);
	function set_height(v:Float) return height = Std.int(v);

	public function new() {}
}

class ScaleMode {
	public static inline var Auto:Int = 0;
	public static inline var Resize:Int = 1;
}

class Element {
	public var name:String = "element";
	public var type:String = "element";

	public var parent:Layout;
	public var prefab:Prefab;

	public var width:Float = 0;
	public var height:Float = 0;

	public var original:Size = new Size();

	public var anchor:String = "0,0";
	public var color:String = "999999";

	public var anchorX:Float = 0;
	public var anchorY:Float = 0;

	public var resizeX:Int = 0;
	public var resizeY:Int = 0;

	public var scaleX:Float = 100;
	public var scaleY:Float = 100;
	
	public var clipping:Bool = false;
	public var padding:Int = 0;

	public function new() {}

	public function serialize():Dynamic {
		var data:Dynamic = {};

		data.name = name;
		data.type = type;
		data.path = parent.name;

		data.width = original.width;
		data.height = original.height;

		if (clipping) data.clipping = clipping;
		if (padding != 0) data.padding = padding;
		if (color != "999999") data.color = Editor.ME.getColor(color);

		data.dx = anchorX;
		data.dy = anchorY;

		data.scaleX = scaleX;
		data.scaleY = scaleY;

		data.x = resizeX;
		data.y = resizeY;

		return data;
	}
}


class Layout extends Prefab {
	public var children:Map<String, Element> = new Map();
	public var elements:Array<Element> = [];

	public var color(default, set):String = "999999";
	public var anchor(default, set):String = "0,0";

	public var masking(default, set):Bool = false;
	public var clipping(default, set):Bool = false;

	public var resizeX(default, set):Int = 0;
	public var resizeY(default, set):Int = 0;

	public var padding(default, set):Int = 0;
	public var margin(default, set):Int = 0;
	
	public var selected:Null<Element> = null;


	public function new() {
		super();

		var layout = new Graphic();
		layout.prefab = this;

		object = layout;

		width = 960;
		height = 540;
	
		type = "layout";
		link = "layout";
		
		color = "999999";
		fixed = true;
	}


	public function add(layout:Layout, entry:h2d.Object):Void {
		var prefab = Editor.ME.children.get(entry.name);

		if (prefab != null) {
			var exist = children.exists(prefab.name);
			var element = get(prefab.name);

			element.parent = layout;
			element.prefab = prefab;

			element.name = prefab.name;
			element.type = prefab.type;

			if (!exist) element.width = prefab.object.getBounds(prefab.object).width;
			if (!exist) element.height = prefab.object.getBounds(prefab.object).height;

			element.original.width = element.width;
			element.original.height = element.height;

			if (element.clipping) {
				Reflect.setProperty(prefab.object, "clipping", true);
			}

			prefab.fixed = true;
		}

		onResize();
	}


	public function delete(entry:h2d.Object):Void {
		var element = children.get(entry.name);

		if (element.type != "layout") element.prefab.fixed = false;

		element.prefab.object.x = 0;
		element.prefab.object.y = 0;

		element.prefab.object.scaleX = 1;
		element.prefab.object.scaleY = 1;

		elements.remove(element);
		children.remove(entry.name);

		onResize();
	}


	public function get(name:String):Element {
		if (children.exists(name)) return children.get(name);
		var element = set(name);
		return element;
	}


	public function set(name:String):Element {
		var element = new Element();
		element.name = name;

		elements.push(element);
		children.set(name, element);

		return element;
	}


	public function resize(name:String) {
		var element = children.get(name);

		if (element != null) {
			var object = element.prefab.object;

			element.width = object.getBounds(object).width;
			element.height = object.getBounds(object).height;

			element.original.width = element.width;
			element.original.height = element.height;

			onResize();
		}
	}


	public function select(prefab:Prefab) {
		selected = children.get(prefab.name);
	}


	public function origin():Layout {
		var layout:Layout = this;
		var p = object.parent;

		while (p != null) {
			var prefab = Editor.ME.children.get(p.name);

			if (prefab != null && prefab.type == "layout") {
				layout = (cast prefab : Layout);
			}
			p = p.parent;
		}

		return layout;
	}


	function onResize() {
		for (child in elements) {
			var parent = child.parent;

			if (parent == null) continue;

			var w = parent.width - parent.padding * 2;
			var h = parent.height - parent.padding * 2;

			var width = parent.width - parent.padding * 2;
			var height = parent.height - parent.padding * 2;

			if (child.resizeX == ScaleMode.Resize) width = width * (child.scaleX / 100);
			if (child.resizeY == ScaleMode.Resize) height = height * (child.scaleY / 100);
			
			var resizeX = width / child.original.width;
			var resizeY = height / child.original.height;
		
			var scaleX = 1.0;
			var scaleY = 1.0;
		
			// STRETCH
			if (child.resizeX == ScaleMode.Resize && child.resizeY == ScaleMode.Resize) {
				scaleX = resizeX;
				scaleY = resizeY;
			}
			// AUTO
			if (child.resizeX == ScaleMode.Auto && child.resizeY == ScaleMode.Auto) {
				var s = (child.original.width > width || child.original.height > height) ? Math.min(resizeX, resizeY) : 1.0;
				scaleX = scaleY = s;
			}
			// COVER width
			if (child.resizeX == ScaleMode.Resize && child.resizeY == ScaleMode.Auto) {
				scaleX = scaleY = resizeX;
			}
			// COVER height
			if (child.resizeX == ScaleMode.Auto && child.resizeY == ScaleMode.Resize) {
				scaleX = scaleY = resizeY;
			}

			switch (child.type) {
				case "layout":
					Reflect.setProperty(child.prefab, "width", width);
					Reflect.setProperty(child.prefab, "height", height);

					child.width = width;
					child.height = height;
			
				case "scalegrid", "interactive", "mask":
					child.width = child.original.width * scaleX;
					child.height = child.original.height * scaleY;

					Reflect.setProperty(child.prefab, "width", child.width);
					Reflect.setProperty(child.prefab, "height", child.height);
			
				default:
					child.width = child.original.width * scaleX;
					child.height = child.original.height * scaleY;

					child.prefab.object.scaleX = scaleX;
					child.prefab.object.scaleY = scaleY;
			}

			child.prefab.object.x = parent.padding + (w - child.width) * child.anchorX;
			child.prefab.object.y = parent.padding + (h - child.height) * child.anchorY;
		}
	}


	override function set_scaleX(v) {
		if (selected == null) return v;

		selected.scaleX = v;
		onResize();

		return v;
	}


	override function set_scaleY(v) {
		if (selected == null) return v;

		selected.scaleY = v;
		onResize();

		return v;
	}


	function set_resizeX(v) {
		if (selected == null) return v;

		selected.resizeX = v;
		onResize();

		return v;
	}


	function set_resizeY(v) {
		if (selected == null) return v;

		selected.resizeY = v;
		onResize();

		return v;
	}


	function set_anchor(v) {
		if (selected == null) return v;

		var val = v.split(",");

		selected.anchorX = Std.parseFloat(StringTools.trim(val[0]));
		selected.anchorY = Std.parseFloat(StringTools.trim(val[1]));

		selected.anchor = v;
		onResize();

		return v;
	}


	function set_color(v) {
		var val = Color.from(v);
		if (val == null) return color;

		val = Color.desaturate(val);

		if (selected == null) color = v;
		if (selected != null && selected.type != "layout") return color;

		var source = selected == null ? object : selected.prefab.object;
		var bitmap = (cast source : h2d.Drawable);

		var a = bitmap.color.w;
		bitmap.color.setColor(val);
		bitmap.color.w = a;

		if (selected != null) {
			Reflect.setProperty(selected.prefab, "color", v);
			selected.color = v;
		}

		return v;
	}


	function set_masking(v:Bool) {
		masking = v;

		var layout = (cast object : Graphic);
		layout.clipping = masking;

		return v;
	}


	function set_clipping(v:Bool) {
		if (selected == null) return v;

		selected.clipping = v;
		Reflect.setProperty(selected.prefab.object, "clipping", v);

		return v;
	}


	override function set_width(v) {
		width = v;

		var element = (cast object : Graphic);
		element.width = Std.int(v);
		onResize();

		return v;
	}


	override function set_height(v) {
		height = v;
		
		var element = (cast object : Graphic);
		element.height = Std.int(v);
		onResize();

		return v;
	}


	function set_margin(v) {
		if (selected == null) return v;

		selected.padding = v;
		if (selected.type == "layout") {
			Reflect.setProperty(selected.prefab, "padding", v);
		}
		onResize();

		return v;
	}


	function set_padding(v) {
		padding = v;
		onResize();

		return v;
	}


	override public function serialize():Dynamic {
		var data:Dynamic = super.serialize();

		data.width = width;
		data.height = height;

		if (masking) data.clipping = masking;
		if (padding != 0) data.padding = padding;

		if (color != "999999") data.color = Editor.ME.getColor(color);

		var children = [];

		for (child in elements) {
			children.push(child.serialize());
		}

		if (children.length > 0) data.children = children;

		return data;
	}


	override public function clone():Prefab {
		var prefab = new Layout();

		prefab.width = width;
		prefab.height = height;
		prefab.color = color;

		prefab.copy(this);

		return prefab;
	}
}


class Graphic extends h2d.Graphics {
	public var prefab:Layout;

	public var width(default, set):Int = 0;
	public var height(default, set):Int = 0;
	
	public var clipping:Bool = false;
	public var padding:Int = 0;


	override function drawRec(ctx:h2d.RenderContext) {
		if (clipping) h2d.Mask.maskWith(ctx, this, width, height, 0, 0);
		super.drawRec(ctx);
		if (clipping) h2d.Mask.unmask(ctx);
	}


	override public function addChildAt(s:h2d.Object, pos:Int):Void {
		super.addChildAt(s, pos);

		var root = prefab.origin();
		root.add(prefab, s);
	}


	override public function removeChild(s:h2d.Object) {
		super.removeChild(s);

		var root = prefab.origin();
		root.delete(s);
	}


	override function onAdd() {
		super.onAdd();
		onResize();
	}


	function set_width(v) {
		width = Std.int(v);
		onResize();
		return width;
	}


	function set_height(v) {
		height = Std.int(v);
		onResize();
		return height;
	}


	function onResize() {
		var dash = 8.0;
		var gap = 8.0;
		var step = dash + gap;
		
		var offset = 1.0;

		var left = offset;
		var top = offset;
		var right = width - offset;
		var bottom = height - offset;

		clear();
		lineStyle(2, 0xFFFFFF, 1);

		var x = left;
		while (x < right) {
			var x2 = Math.min(x + dash, right);
			moveTo(x, top);
			lineTo(x2, top);
			x += step;
		}

		var y = top;
		while (y < bottom) {
			var y2 = Math.min(y + dash, bottom);
			moveTo(right, y);
			lineTo(right, y2);
			y += step;
		}

		x = right;
		while (x > left) {
			var x2 = Math.max(x - dash, left);
			moveTo(x, bottom);
			lineTo(x2, bottom);
			x -= step;
		}

		y = bottom;
		while (y > top) {
			var y2 = Math.max(y - dash, top);
			moveTo(left, y);
			lineTo(left, y2);
			y -= step;
		}
	}
}