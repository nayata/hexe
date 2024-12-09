package prefab;


class Mask extends Prefab {

	public function new() {
		super();

		object = new Shape(64, 64);

		width = 64;
		height = 64;

		type = "mask";
		link = "mask";
	}


	override public function serialize():Dynamic {
		var data:Dynamic = super.serialize();

		data.width = width;
		data.height = height;

		return data;
	}


	override public function clone():Prefab {
		var prefab = new Mask();

		prefab.width = width;
		prefab.height = height;

		prefab.copy(this);

		return prefab;
	}


	override function set_width(v) {
		width = v;

		var mask = (cast object : Shape);
		mask.width = Std.int(v);

		return v;
	}


	override function set_height(v) {
		height = v;
		
		var mask = (cast object : Shape);
		mask.height = Std.int(v);

		return v;
	}
}


class Shape extends h2d.Mask {
	var tile = h2d.Tile.fromColor(0xff00ff, 64, 64, 0.5);


	override function getBoundsRec( relativeTo : h2d.Object, out : h2d.col.Bounds, forSize : Bool ) {
		super.getBoundsRec(relativeTo, out, forSize);
		addBounds(relativeTo, out, tile.dx, tile.dy, tile.width, tile.height);
	}


	override function draw(ctx:h2d.RenderContext) {
		@:privateAccess {
			if (tile.width != width) tile.width = width;
			if (tile.height != height) tile.height = height;
		}
		emitTile(ctx, tile);
	}
}