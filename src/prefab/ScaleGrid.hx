package prefab;


class ScaleGrid extends Image {
	public var border(default, set):Int = 10;
	public var smooth(default, set):Int = 0;

	public var bitmap(default, set):String = "";
	public var image(default, set):String = "";


	public function new() {
		super();

		object = new h2d.ScaleGrid(h2d.Tile.fromColor(0xFFFFFF, 128, 128), 10, 10);

		width = 128;
		height = 128;

		type = "scalegrid";
		link = "scalegrid";
	}


	override public function serialize():Dynamic {
		var data:Dynamic = super.serialize();

		data.width = width;
		data.height = height;

		if (border != 10) data.range = border;
		if (smooth != 0) data.smooth = smooth;

		if (atlas != "") data.atlas = atlas;
		if (path != "") data.path = path;

		data.src = src;

		return data;
	}


	override public function clone():Prefab {
		var prefab = new ScaleGrid();

		prefab.tile = tile.clone();
		
		prefab.atlas = atlas;
		prefab.path = path;
		prefab.src = src;

		prefab.width = width;
		prefab.height = height;

		prefab.border = border;
		prefab.smooth = smooth;

		prefab.copy(this);

		return prefab;
	}


	override function set_tile(v) {
		var bitmap = (cast object : h2d.ScaleGrid);
		bitmap.tile = v;

		bitmap.width = width;
		bitmap.height = height;

		return tile = v;
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


	function set_border(v) {
		var bitmap = (cast object : h2d.ScaleGrid);
		bitmap.borderWidth = bitmap.borderHeight = v;

		return border = v;
	}


	function set_smooth(v) {
		var bitmap = (cast object : h2d.ScaleGrid);
		bitmap.smooth = v == 1 ? true : false;

		return smooth = v;
	}


	override function set_width(v) {
		width = v;

		var bitmap = (cast object : h2d.ScaleGrid);
		bitmap.width = Std.int(v);

		return v;
	}


	override function set_height(v) {
		height = v;
		
		var bitmap = (cast object : h2d.ScaleGrid);
		bitmap.height = Std.int(v);

		return v;
	}
}