package prefab;


class Drawable extends Prefab {
	public var tile(default, set):h2d.Tile = null;

	public var bitmap(default, set):String = "";
	public var image(default, set):String = "";

	public var smooth(default, set):Int = 0;

	public var atlas:String = "";
	public var path:String = "";


	function set_bitmap(v) {
		return bitmap = v;
	}


	function set_image(v) {
		return image = v;
	}


	function set_tile(v) {
		return tile = v;
	}


	function set_smooth(v) {
		return smooth = v;
	}
}