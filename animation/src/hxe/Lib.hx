package hxe;


class Lib {
	static var asset:Map<String, hxd.res.Atlas> = new Map();
	static var cache:Map<String, Data> = new Map();


	/** 
		Load the Prefab from `path` and assign all created hierarchy objects to fields of the `object` instance.

		@param path Prefab name. Can point to a subfolder and must be without an extension.
		@param object An instance to which the prefab adds itself and assigns fields from the loaded `path` hierarchy.
	**/
	public static function bind(path:String, object:Dynamic) {
		var fields = Type.getInstanceFields(Type.getClass(object));

		var hierarchy = get(path, (cast object : h2d.Object));

		for (field in fields) {
			if (hierarchy.exists(field)) {
				Reflect.setField(object, field, hierarchy.get(field));
			}
		}
	}


	/** 
		Create a Prefab with a given class `type`, load data from `path` and assign all created hierarchy objects to fields of this instance.

		@param path Prefab name. Can point to a subfolder and must be without an extension.
		@param type Prefab class. All objects from the loaded hierarchy will be assigned to the fields of this instance.
		@param parent An optional parent `h2d.Object` instance to which prefab adds itself if set.
	**/
	public static function make(path:String, type:Class<Dynamic>, ?parent:h2d.Object):Dynamic {
		var object = Type.createInstance(type, [parent]);
		var fields = Type.getInstanceFields(type);

		object.hierarchy = get(path, (cast object : h2d.Object));
		object.name = getName(path);

		for (field in fields) {
			if (object.hierarchy.exists(field)) {
				Reflect.setField(object, field, object.hierarchy.get(field));
			}
		}

		return object;
	}


	/**
		Load the Prefab with the given name `path` from the `res` folder.
		`path` can point to a subfolder (eg: "ui/button") and must be without an extension.

		@param path Prefab name.
		@param parent An optional parent `h2d.Object` instance to which prefab adds itself if set.
		@param field An optional `Field` structure to override default values ​​for an object in the prefab hierarchy(text, texture atlas tile. eg: "[{ name : "label", type : "text", value : "new label" }]").
	**/
	public static function load(path:String, ?parent:h2d.Object, ?field:Array<Field>):Prefab {
		var prefab = new Prefab(parent);
		
		prefab.hierarchy = get(path, prefab, field);
		prefab.name = getName(path);

		return prefab;
	}


	/**
		Animation
	**/
	public static function motion(path:String, ?parent:h2d.Object, ?field:Array<Field>):Animation {
		var prefab = new Animation(parent);

		prefab.hierarchy = get(path, prefab, field);
		prefab.animation = from(path, prefab);
		prefab.name = getName(path);

		return prefab;
	}


	public static function from(path:String, prefab:Animation):Animation.Timeline {
		var res = read(path);

		var animation = new Animation.Timeline();

		animation.duration = res.duration;
		animation.speed = res.speed;
		animation.loop = res.loop == 1 ? true : false;

		for (entry in res.animation) {
			var frame = new Animation.Frame();

			frame.name = entry.name;
			frame.type = entry.type;

			frame.ease = entry.ease ?? "linear";
		
			frame.start = entry.start;
			frame.end = entry.end;
		
			frame.from = entry.from;
			frame.to = entry.to;

			frame.speed = 1 / (frame.end - frame.start);
			frame.range = frame.to - frame.from;

			prefab.childrens.set(frame.name, prefab.getObjectByName(frame.name));
			animation.frame.push(frame);
		}

		for (entry in res.events) {
			var frame = new Animation.Frame();

			frame.name = entry.name;
			frame.start = entry.start;

			animation.event.push(frame);
		}

		return animation;
	}


	/**
		Get json `Data` of the Prefab with the given name `path` from the `res` folder.

		@param path Prefab name.
	**/
	public static function read(path:String):Data {
		if (cache.exists(path)) return cache.get(path);

		var raw = hxd.Res.load(path + ".prefab");
		var res:Data = haxe.Json.parse(raw.entry.getText());

		cache.set(path, res);

		return res;
	}


	// Load hierarchy and create objects
	static function get(path:String, parent:h2d.Object, ?field:Array<Field>):Map<String, h2d.Object> {
		var res = read(path);

		var hierarchy:Map<String, h2d.Object> = new Map();
		var childrens:Map<String, h2d.Object> = new Map();

		for (entry in res.children) {
			var object:Null<h2d.Object> = null;

			switch (entry.type) {
				case "object" :
					var item = new h2d.Object();

					hierarchy.set(entry.link, item);
					childrens.set(entry.name, item);

					object = item;

				case "bitmap" :
					var tile:h2d.Tile;

					// Tile from the Texture Atlas or Tile from the Image
					if (entry.atlas != null) {
						if (!hxd.res.Loader.currentInstance.exists(entry.path)) throw("Could not find atlas " + entry.atlas + ".atlas");

						// Load and store Texture Atlas
						var atlas = getAtlas(entry.path);
						tile = atlas.get(entry.src);

						// Override bitmap tile with a value from the field
						if (field != null) {
							for (key in field) {
								if (key.name == entry.link && key.type == "bitmap") tile = atlas.get(key.value);
							}
						}
					}
					else {
						if (!hxd.res.Loader.currentInstance.exists(entry.src)) throw("Could not find image " + entry.src);
						tile = hxd.Res.load(entry.src).toImage().toTile();
					}

					var item = new h2d.Bitmap(tile);

					if (entry.width != null) item.width = entry.width;
					if (entry.height != null) item.height = entry.height;

					if (entry.smooth != null) item.smooth = entry.smooth == 1 ? true : false;
					if (entry.dx != null) item.tile.setCenterRatio(entry.dx, entry.dy);

					hierarchy.set(entry.link, item);
					childrens.set(entry.name, item);

					object = item;

				case "scalegrid" :
					var tile:h2d.Tile;

					if (entry.atlas != null) {
						if (!hxd.res.Loader.currentInstance.exists(entry.path)) throw("Could not find atlas " + entry.atlas + ".atlas");

						var atlas = getAtlas(entry.path);
						tile = atlas.get(entry.src);
					}
					else {
						if (!hxd.res.Loader.currentInstance.exists(entry.src)) throw("Could not find image " + entry.src);
						tile = hxd.Res.load(entry.src).toImage().toTile();
					}

					var size = entry.range ?? 10;
					var item = new h2d.ScaleGrid(tile, size, size);

					item.width = entry.width;
					item.height = entry.height;

					if (entry.smooth != null) item.smooth = entry.smooth == 1 ? true : false;

					hierarchy.set(entry.link, item);
					childrens.set(entry.name, item);

					object = item;

				case "anim" :
					var tiles:Array<h2d.Tile> = [];

					if (entry.atlas != null) {
						if (!hxd.res.Loader.currentInstance.exists(entry.path)) throw("Could not find atlas " + entry.atlas + ".atlas");

						var atlas = getAtlas(entry.path);
						tiles = atlas.getAnim(entry.src);

						for (t in tiles) t.setCenterRatio(0.5, 0.5);
					}
					else {
						if (!hxd.res.Loader.currentInstance.exists(entry.src)) throw("Could not find image " + entry.src);

						var tile = hxd.Res.load(entry.src).toImage().toTile();

						var row = Std.int(entry.width);
						var col = Std.int(entry.height);
						var w = Std.int(tile.width / row);
						var h = Std.int(tile.height / col);
				
						for (y in 0...col) {    
							for (x in 0...row) {
								tiles.push( tile.sub(x * w, y * h, w, h, -(w / 2), -(h / 2)) );
							}
						}
					}

					var item = new h2d.Anim(tiles, entry.speed);
					item.pause = entry.loop == 0 ? true : false;

					if (entry.smooth != null) item.smooth = entry.smooth == 1 ? true : false;

					hierarchy.set(entry.link, item);
					childrens.set(entry.name, item);

					object = item;

				case "text" :
					var font = hxd.res.DefaultFont.get();

					if (entry.font != null) {
						if (!hxd.res.Loader.currentInstance.exists(entry.src)) throw("Could not find Font file " + entry.src);
						font = hxd.Res.load(entry.src).to(hxd.res.BitmapFont).toFont();
					}

					var item = new h2d.Text(font);
					item.smooth = true;

					if (entry.color != null) item.textColor = entry.color;
					if (entry.width != null) item.letterSpacing = entry.width;
					if (entry.height != null) item.lineSpacing = entry.height;
					if (entry.range != null) item.maxWidth = entry.range;

					if (entry.align != null) {
						switch (entry.align) {
							case 1 : item.textAlign = Center;
							case 2 : item.textAlign = Right;
							default : item.textAlign = Left;
						}
					}

					item.text = entry.text ?? "";

					// Override text with a value from the field
					if (field != null) {
						for (key in field) {
							if (key.name == entry.link && key.type == "text") item.text = key.value;
						}
					}

					hierarchy.set(entry.link, item);
					childrens.set(entry.name, item);

					object = item;

				case "interactive" :
					var item = new h2d.Interactive(128, 128);

					item.width = Std.int(entry.width);
					item.height = Std.int(entry.height);

					if (entry.smooth != null) item.isEllipse = true;

					hierarchy.set(entry.link, item);
					childrens.set(entry.name, item);

					object = item;

				case "graphics" :
					var item = new h2d.Graphics();

					var c = entry.color ?? 0xFFFFFF;
					var w = entry.width ?? 128;
					var h = entry.height ?? 128;

					item.beginFill(c);
					item.drawRect(0, 0, w, h);
					item.endFill();

					hierarchy.set(entry.link, item);
					childrens.set(entry.name, item);

					object = item;

				case "mask" :
					var item = new h2d.Mask(Std.int(entry.width), Std.int(entry.height));

					hierarchy.set(entry.link, item);
					childrens.set(entry.name, item);
					
					object = item;

				case "prefab" :
					if (!hxd.res.Loader.currentInstance.exists(entry.src)) throw("Could not find Prefab file " + entry.src);

					var path = entry.src.split(".").shift();
					var item = load(path, object, entry.field);

					hierarchy.set(entry.link, item);
					childrens.set(entry.name, item);

					object = item;

				default:
			}

			if (object == null) continue;

			// Set the object name
			object.name = entry.name;

			// Set the object transform
			object.x = entry.x ?? 0;
			object.y = entry.y ?? 0;

			object.scaleX = entry.scaleX ?? 1;
			object.scaleY = entry.scaleY ?? 1;

			object.rotation = entry.rotation ?? 0;

			// Set the object display options
			if (entry.blendMode != null) object.blendMode = haxe.EnumTools.createByName(h2d.BlendMode, entry.blendMode);

			object.visible = entry.visible ?? true;
			object.alpha = entry.alpha ?? 1;

			// Place object
			var p:h2d.Object = entry.parent != null ? childrens.get(entry.parent) : parent;
			p.addChild(object);
		}

		return hierarchy;
	}


	// Load or get the Texture Atlas
	public static function getAtlas(path:String):hxd.res.Atlas {
		var name = getName(path);

		if (asset.exists(name)) return asset.get(name);

		var atlas = hxd.Res.load(path).to(hxd.res.Atlas);
		asset.set(name, atlas);

		return atlas;
	}


	// Add the Texture Atlas to cache
	public static function setAtlas(atlas:hxd.res.Atlas) {
		asset.set(getName(atlas.name), atlas);
	}


	// Get name from the Path
	static inline function getName(path:String):String {
		return haxe.io.Path.withoutDirectory(path).split(".").shift();
	}


	// Clear cache
	public static function clear() {
		asset = new Map();
		cache = new Map();
	}
}


typedef Field = { name : String, type : String, value : String };

typedef Data = {
	var name : String;
	var type : String;
	var link : String;

	@:optional var children : Array<Data>;
	@:optional var parent : String;

	@:optional var field : Array<Field>;

	@:optional var animation : Array<Keyframe>;
	@:optional var events : Array<Keyframe>;

	@:optional var x : Float;
	@:optional var y : Float;
	@:optional var scaleX : Float;
	@:optional var scaleY : Float;
	@:optional var rotation : Float;
	@:optional var alpha : Float;

	@:optional var blendMode : String;
	@:optional var visible : Bool;
	@:optional var smooth : Int;

	@:optional var src : String;

	@:optional var width : Float;
	@:optional var height : Float;

	@:optional var dx : Float;
	@:optional var dy : Float;

	@:optional var color : Int;
	@:optional var align : Int;
	@:optional var range : Int;

	@:optional var duration : Float;
	@:optional var speed : Float;
	@:optional var loop : Int;

	@:optional var text : String;
	@:optional var atlas : String;
	@:optional var font : String;
	@:optional var path : String;
}

typedef Keyframe = {
	var name : String;

	@:optional var type : String;
	@:optional var ease : String;

	@:optional var from : Float;
	@:optional var to : Float;
	@:optional var start : Float;
	@:optional var end : Float;
}