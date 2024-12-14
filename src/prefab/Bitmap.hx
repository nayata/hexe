package prefab;
import h2d.col.Point;


class Bitmap extends Drawable {
	public var dx:Float = 0;
	public var dy:Float = 0;

	public var anchor(default, set):String = "0,0";


	public function new() {
		super();

		object = new h2d.Bitmap();
		type = "bitmap";
		link = "bitmap";
	}


	override public function serialize():Dynamic {
		var data:Dynamic = super.serialize();

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

		prefab.atlas = atlas;
		prefab.path = path;
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


	override function set_tile(v) {
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


	override function set_bitmap(v) {
		var file = Editor.ME.file.directory + v;
		var data = sys.io.File.getBytes(file);
		tile = hxd.res.Any.fromBytes(file, data).toImage().toTile();

		src = v;

		return bitmap = v;
	}


	override function set_image(v) {
		tile = Assets.atlas.get(atlas).get(v);
		src = v;

		return image = v;
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


	override function set_smooth(v) {
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