package prefab;


class Image extends Prefab {
	public var tile(default, set):h2d.Tile = null;

	public var atlas:String = "";
	public var path:String = "";


	function set_tile(v) {
		return tile = v;
	}
}