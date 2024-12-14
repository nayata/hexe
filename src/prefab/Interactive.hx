package prefab;
import h2d.col.Point;


class Interactive extends Prefab {
	public var smooth(default, set):Int = 0;


	public function new() {
		super();

		object = new h2d.Bitmap(h2d.Tile.fromColor(0x015AFF, 64, 64, 0.5));

		width = 64;
		height = 64;

		type = "interactive";
		link = "interactive";
		locked = true;
	}


	override public function serialize():Dynamic {
		var data:Dynamic = super.serialize();

		if (smooth != 0) data.smooth = smooth;
		data.width = width;
		data.height = height;

		return data;
	}


	override public function clone():Prefab {
		var prefab = new Interactive();

		prefab.smooth = smooth;
		prefab.width = width;
		prefab.height = height;

		prefab.copy(this);

		return prefab;
	}


	function set_smooth(v) {
		return smooth = v;
	}


	override function set_width(v) {
		width = v;

		var bitmap = (cast object : h2d.Bitmap);
		bitmap.width = Std.int(v);

		return v;
	}


	override function set_height(v) {
		height = v;
		
		var bitmap = (cast object : h2d.Bitmap);
		bitmap.height = Std.int(v);

		return v;
	}


	override function set_scaleX(v) {
		return width = v;
	}


	override function set_scaleY(v) {
		return height = v;
	}
}