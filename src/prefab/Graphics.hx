package prefab;
import h2d.col.Point;


class Graphics extends Prefab {
	public var color(default, set):String = "FFFFFF";


	public function new() {
		super();

		object = new h2d.Bitmap(h2d.Tile.fromColor(0xFFFFFF, 128, 128));

		width = 128;
		height = 128;

		type = "graphics";
		link = "graphics";
	}


	override public function serialize():Dynamic {
		var data:Dynamic = super.serialize();

		if (color != "FFFFFF") data.color = Editor.ME.getColor(color);
		data.width = width;
		data.height = height;

		return data;
	}


	override public function clone():Prefab {
		var prefab = new Graphics();

		prefab.color = color;
		prefab.width = width;
		prefab.height = height;

		prefab.copy(this);

		return prefab;
	}


	function set_color(v) {
		var val = Editor.ME.getColor(v);
		if (val == null) return null;

		var bitmap = (cast object : h2d.Bitmap);

		var a = bitmap.color.w;
		bitmap.color.setColor(val);
		bitmap.color.w = a;

		return color = v;
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