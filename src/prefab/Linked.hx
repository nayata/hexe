package prefab;

typedef Field = { name : String, type : String, data : String, original : String, value : String };

class Linked extends Prefab {
	public var bitmap:Map<String, h2d.Bitmap> = new Map();
	public var text:Map<String, h2d.Text> = new Map();

	public var field:Map<String, Field> = new Map();


	public function new() {
		super();

		object = new h2d.Object();
		type = "prefab";
		link = "prefab";

		locked = true;
	}


	override public function serialize():Dynamic {
		var data:Dynamic = super.serialize();

		var fields = [];
		for (entry in field) {
			if (entry.value != entry.original) {
				fields.push({ name : entry.name, type : entry.type, value : entry.value });
			}
		}

		if (fields.length > 0) data.field = fields;
		data.src = src;

		return data;
	}


	public function setBitmap(name:String, value:String) {
		var bitmap = bitmap.get(name);

		var dx = bitmap.tile.dx / bitmap.tile.width;
		var dy = bitmap.tile.dy / bitmap.tile.height;

		var atlas = field.get(name).data;
		var tile = Assets.atlas.get(atlas).get(value);

		bitmap.tile = tile;
		bitmap.tile.setCenterRatio(-dx, -dy);

		field.get(name).value = value;
	}


	public function setText(name:String, value:String) {
		text.get(name).text = value;
		field.get(name).value = value;
	}


	override public function clone():Prefab {
		var prefab = Editor.ME.file.getPrefab(src);
		prefab.link = link;
		prefab.src = src;
		prefab.copy(this);

		return prefab;
	}
}