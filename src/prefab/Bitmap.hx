package prefab;
import h2d.col.Point;


class Bitmap extends Prefab {
	public var dx:Float = 0;
	public var dy:Float = 0;

	public var anchor(default, set):String = "0,0";
	public var smooth(default, set):Int = 0;

	public var tile(default, set):h2d.Tile = null;

	//
	public var bitmap(default, set):String = "";
	public var image(default, set):String = "";

	public var atlas:String = "";
	public var path:String = "";


	public function new() {
		super();

		object = new h2d.Bitmap();
		type = "bitmap";
		link = "bitmap";
	}


	override public function serialize():Dynamic {
		var data:Dynamic = {};

		data.name = name;
		data.type = "bitmap";
		data.link = link;

		if (object.parent.name != "root") data.parent = object.parent.name;

		if (object.x != 0) data.x = object.x;
		if (object.y != 0) data.y = object.y;

		if (object.scaleX != 1) data.scaleX = object.scaleX;
		if (object.scaleY != 1) data.scaleY = object.scaleY;

		if (object.rotation != 0) data.rotation = object.rotation;
		
		if (object.blendMode != h2d.BlendMode.Alpha) data.blendMode = Std.string(object.blendMode);
		if (object.alpha != 1) data.alpha = object.alpha;
		if (!object.visible) data.visible = false;


		var bitmap = (cast object : h2d.Bitmap);

		if (width != bitmap.tile.width) data.width = width;
		if (height != bitmap.tile.height) data.height = height;
		if (smooth != 0) data.smooth = smooth;

		if (dx != 0 || dy != 0) {
			data.dx = dx;
			data.dy = dy;
		}

		if (atlas != "") data.atlas = atlas;
		if (path != "") data.path = path;

		data.src = src;

		return data;
	}


	override public function clone():Prefab {
		var prefab = new Bitmap();

		prefab.tile = tile.clone();
		prefab.src = src;

		prefab.width = width;
		prefab.height = height;

		prefab.anchor = anchor;
		prefab.smooth = smooth;

		prefab.dx = dx;
		prefab.dy = dy;

		prefab.copy(this);

		return prefab;
	}


	function set_bitmap(v) {
		var file = Editor.ME.file.directory + v;
		var data = sys.io.File.getBytes(file);
		tile = hxd.res.Any.fromBytes(file, data).toImage().toTile();

		src = v;

		return bitmap = v;
	}


	function set_image(v) {
		tile = Assets.atlas.get(atlas).get(v);
		src = v;

		return image = v;
	}


	function set_tile(v) {
		var bitmap = (cast object : h2d.Bitmap);
		bitmap.tile = v;
		
		bitmap.tile.setCenterRatio(dx, dy);

		bitmap.width = v.width;
		bitmap.height = v.height;

		width = bitmap.width;
		height = bitmap.height;

		x = -width * dx;
		y = -height * dy;

		return tile = v;
	}


	function set_anchor(v) {
		var val = v.split(",");

		var vx = Std.parseFloat(StringTools.trim(val[0]));
		var vy = Std.parseFloat(StringTools.trim(val[1]));

		var bitmap = (cast object : h2d.Bitmap);
		bitmap.tile.setCenterRatio(vx, vy);

		x = -width * vx;
		y = -height * vy;

		dx = vx;
		dy = vy;

		return anchor = v;
	}


	function set_smooth(v) {
		var bitmap = (cast object : h2d.Bitmap);
		bitmap.smooth = v == 1 ? true : false;

		return smooth = v;
	}


	override function set_width(v) {
		width = v;

		var bitmap = (cast object : h2d.Bitmap);
		bitmap.width = Std.int(v);

		x = -width * dx;
		y = -height * dy;

		return v;
	}


	override function set_height(v) {
		height = v;
		
		var bitmap = (cast object : h2d.Bitmap);
		bitmap.height = Std.int(v);

		x = -width * dx;
		y = -height * dy;

		return v;
	}
}