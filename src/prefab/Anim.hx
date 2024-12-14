package prefab;
import h2d.col.Point;


class Anim extends Drawable {
	public var row(default, set):Int = 1;
	public var col(default, set):Int = 1;

	public var speed(default, set):Int = 30;
	public var loop(default, set):Int = 1;


	public function new() {
		super();

		object = new h2d.Anim([], speed);

		type = "anim";
		link = "anim";
	}


	override public function serialize():Dynamic {
		var data:Dynamic = super.serialize();

		data.width = row;
		data.height = col;

		data.speed = speed;
		data.loop = loop;

		if (smooth != 0) data.smooth = smooth;
		if (atlas != "") data.atlas = atlas;
		if (path != "") data.path = path;

		data.src = src;

		return data;
	}


	override public function clone():Prefab {
		var prefab = new Anim();

		if (atlas != "") {
			prefab.atlas = atlas;
			prefab.image = src;
			prefab.path = path;
		}
		else {
			prefab.row = row;
			prefab.col = col;
			prefab.tile = tile.clone();
		}
		
		prefab.src = src;

		prefab.speed = speed;
		prefab.loop = loop;
		prefab.smooth = smooth;

		prefab.copy(this);

		return prefab;
	}


	override function set_tile(t:h2d.Tile) {
		if (atlas != "") return null;
		if (t == null) return null;

		var anim = (cast object : h2d.Anim);
		var tiles:Array<h2d.Tile> = [];

		width = Std.int(t.width / row);
		height = Std.int(t.height / col);

		for (y in 0...col) {    
			for (x in 0...row) {
				tiles.push( t.sub(x * width, y * height, width, height, -(width / 2), -(height / 2)) );
			}
		}

		anim.play(tiles);
		anim.pause = loop == 0 ? true : false;

		x = -width * 0.5;
		y = -height * 0.5;

		return tile = t;
	}


	override function set_width(v) {
		width = v;
		return v;
	}


	override function set_height(v) {
		height = v;
		return v;
	}


	function set_row(v) {
		row = v;
		tile = tile;
		return v;
	}


	function set_col(v) {
		col = v;
		tile = tile;
		return v;
	}


	function set_speed(v) {
		var anim = (cast object : h2d.Anim);
		anim.speed = v;
		return speed = v;
	}


	function set_loop(v) {
		var anim = (cast object : h2d.Anim);
		anim.pause = v == 0 ? true : false;
		return loop = v;
	}


	override function set_bitmap(v) {
		var file = Editor.ME.file.directory + v;
		var data = sys.io.File.getBytes(file);
		tile = hxd.res.Any.fromBytes(file, data).toImage().toTile();

		src = v;

		return bitmap = v;
	}


	override function set_image(v) {
		var anim = (cast object : h2d.Anim);
		
		var tiles = Assets.atlas.get(atlas).getAnim(v);
		for (t in tiles) t.setCenterRatio(0.5, 0.5);

		anim.play(tiles);
		anim.pause = loop == 0 ? true : false;

		width = anim.getFrame().width;
		height = anim.getFrame().height;

		x = -width * 0.5;
		y = -height * 0.5;

		src = v;

		return image = v;
	}


	override function set_smooth(v) {
		var anim = (cast object : h2d.Anim);
		anim.smooth = v == 1 ? true : false;

		return smooth = v;
	}
}