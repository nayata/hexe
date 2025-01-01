package prefab;


class Object extends Prefab {
	public var smooth(default, set):Int = 0;

	public function new() {
		super();

		object = new Container();
		type = "object";
		link = "object";
	}


	override public function serialize():Dynamic {
		var data:Dynamic = super.serialize();
		if (smooth != 0) data.smooth = smooth;

		return data;
	}


	override public function clone():Prefab {
		var prefab = new Object();
		prefab.smooth = smooth;
		prefab.copy(this);
		return prefab;
	}


	function set_smooth(v) {
		var container = (cast object : Container);
		container.marker = v == 1 ? true : false;

		var size = container.marker ? 64 : 0;

		width = size;
		height = size;

		x = -size * 0.5;
		y = -size * 0.5;

		container.tile.setCenterRatio();
		return smooth = v;
	}
}


class Container extends h2d.Object {
	public var tile = hxd.Res.marker.toTile();
	public var marker:Bool = false;


	override function drawContent(ctx:h2d.RenderContext) {
		super.drawContent(ctx);
		if (marker) emitTile(ctx, tile);
	}
}