import haxe.Json;
import prefab.Prefab;


class File {
	public var directory:String = "";
	public var filepath:String = "";
	public var filename:String = "untitled.prefab";
	public var defaultFilename:String = "untitled.prefab";

	var loadDirectory:String = "";
	var empty:String = "";

	var editor:Editor;


	public function new() {
		editor = Editor.ME;
	}


	public function openfile(title:String, name:String, extensions:Array<String>) {
		var options:hl.UI.FileOptions = { };

		options.title = title;
		options.filters = [{name: name, exts: extensions}];
		
		var allowTimeout = hxd.System.allowTimeout;
		hxd.System.allowTimeout = false;

		var file = hl.UI.loadFile(options);
		hxd.System.allowTimeout = allowTimeout;

		return file;
	}


	public function open() {
		var file = openfile("Open File", "Prefab Files", ["prefab", "json"]);
		if (file == null) return;

		var data = sys.io.File.getContent(file);
		if (data == empty) return;

		// New Scene
		editor.clear();

		directory = haxe.io.Path.directory(file).split("\\").join("/")+"/";
		filename = haxe.io.Path.withoutDirectory(file);
		filepath = file;

		var scene:Data = haxe.Json.parse(data);

		for (entry in scene.children) {
			var prefab:Prefab = null;

			// Object Prefab
			if (entry.type == "object") {
				var item = new prefab.Object();
				prefab = item;
			}


			// Bitmap Prefab
			if (entry.type == "bitmap") {
				var tile:h2d.Tile;

				if (entry.atlas != null) {
					if (!sys.FileSystem.exists(directory + entry.path)) throw("Could not find atlas " + entry.atlas + ".atlas");

					loadAtlas(directory + entry.path);
					tile = Assets.atlas.get(entry.atlas).get(entry.src);
				}
				else {
					if (!sys.FileSystem.exists(directory + entry.src)) throw("Could not find image " + entry.src);

					var path = directory + entry.src;
					var bytes = sys.io.File.getBytes(path);
					tile = hxd.res.Any.fromBytes(path, bytes).toImage().toTile();
				}

				var item = new prefab.Bitmap();

				if (entry.atlas != null) {
					item.atlas = entry.atlas;
					item.path = entry.path;
				}
				
				item.src = entry.src;
				item.tile = tile;

				if (entry.width != null) item.width = Std.int(entry.width);
				if (entry.height != null) item.height = Std.int(entry.height);
				if (entry.smooth != null) item.smooth = Std.int(entry.smooth);
				if (entry.dx != null) item.anchor = entry.dx + "," + entry.dy;

				prefab = item;
			}


			// ScaleGrid Prefab
			if (entry.type == "scalegrid") {
				var tile:h2d.Tile;

				if (entry.atlas != null) {
					if (!sys.FileSystem.exists(directory + entry.path)) throw("Could not find atlas " + entry.atlas + ".atlas");

					loadAtlas(directory + entry.path);
					tile = Assets.atlas.get(entry.atlas).get(entry.src);
				}
				else {
					if (!sys.FileSystem.exists(directory + entry.src)) throw("Could not find image " + entry.src);

					var path = directory + entry.src;
					var bytes = sys.io.File.getBytes(path);
					tile = hxd.res.Any.fromBytes(path, bytes).toImage().toTile();
				}

				var item = new prefab.ScaleGrid();

				if (entry.atlas != null) {
					item.atlas = entry.atlas;
					item.path = entry.path;
				}
				
				item.src = entry.src;
				item.tile = tile;

				item.width = Std.int(entry.width);
				item.height = Std.int(entry.height);

				if (entry.range != null) item.border = Std.int(entry.range);
				if (entry.smooth != null) item.smooth = Std.int(entry.smooth);

				prefab = item;
			}


			// Text Prefab
			if (entry.type == "text") {
				var item = new prefab.Text();

				if (entry.font != null) {
					loadFont(directory + entry.src);

					item.font = entry.font;
					item.src = entry.src;
				}

				if (entry.color != null) item.color = StringTools.hex(entry.color);
				if (entry.width != null) item.letterSpacing = Std.int(entry.width);
				if (entry.height != null) item.lineSpacing = Std.int(entry.height);
				if (entry.range != null) item.maxWidth = Std.int(entry.range);
				if (entry.align != null) item.align = Std.int(entry.align);

				item.text = entry.text ?? "";

				prefab = item;
			}


			// Interactive Prefab
			if (entry.type == "interactive") {
				var item = new prefab.Interactive();

				if (entry.smooth != null) item.smooth = entry.smooth;
				item.width = Std.int(entry.width);
				item.height = Std.int(entry.height);

				prefab = item;
			}


			// Graphics Prefab
			if (entry.type == "graphics") {
				var item = new prefab.Graphics();

				if (entry.color != null) item.color = StringTools.hex(entry.color);
				if (entry.width != null) item.width = Std.int(entry.width);
				if (entry.height != null) item.height = Std.int(entry.height);

				prefab = item;
			}


			// Mask Prefab
			if (entry.type == "mask") {
				var item = new prefab.Mask();

				item.width = Std.int(entry.width);
				item.height = Std.int(entry.height);

				prefab = item;
			}


			// Linked Prefab
			if (entry.type == "prefab") {
				if (!sys.FileSystem.exists(directory + entry.src)) throw("Could not find prefab " + entry.src);

				var item = loadPrefab(directory + entry.src, directory);

				if (entry.field != null) {
					for (field in entry.field) {
						if (field.type == "bitmap") item.setBitmap(field.name, field.value);
						if (field.type == "text") item.setText(field.name, field.value);
					}
				}

				item.src = entry.src;

				prefab = item;
			}

			if (prefab == null) continue;

			editor.getUID(entry.name.split(".").shift());

			prefab.name = entry.name;
			prefab.object.name = prefab.name;
			prefab.link = entry.link;

			prefab.object.x = entry.x ?? 0;
			prefab.object.y = entry.y ?? 0;

			prefab.object.scaleX = entry.scaleX ?? 1;
			prefab.object.scaleY = entry.scaleY ?? 1;

			prefab.object.rotation = entry.rotation ?? 0;

			if (entry.blendMode != null) {
				prefab.object.blendMode = haxe.EnumTools.createByName(h2d.BlendMode, entry.blendMode);
			}

			prefab.object.alpha = entry.alpha ?? 1;
			prefab.object.visible = entry.visible ?? true;


			// Place object
			if (entry.parent == null || entry.parent == "root") {
				editor.scene.addChild(prefab.object);
			}
			else {
				var parent = editor.children.get(entry.parent);
				parent.object.addChild(prefab.object);
			}

			editor.add(prefab.object, prefab, false);
		}

		editor.onScene();
	}


	public function save(?newFile:Bool = false) {
		// Prepare scene data
		var children = [];

		for (object in editor.hierarchy) {
			var prefab = editor.children.get(object.name);
			children.push(prefab.serialize());
		}

		var data:Dynamic = {};

		data.name = "prefab";
		data.type = "prefab";
		data.children = children;

		var json = Json.stringify(data, "\t");

		// Saving file
		if (filepath != "" && newFile == false) {
			sys.io.File.saveContent(filepath, json);
			return true;
		}
		else {
			var options:hl.UI.FileOptions = { };
			options.title = "Save File";
			options.fileName = filename;
			options.filters = [{name: "prefab", exts: ["prefab"]}];
			
			var allowTimeout = hxd.System.allowTimeout;
			hxd.System.allowTimeout = false;
	
			var file = hl.UI.saveFile(options);
			hxd.System.allowTimeout = allowTimeout;

			if (file != null) {
				directory = haxe.io.Path.directory(file).split("\\").join("/")+"/";
				filepath = haxe.io.Path.withoutExtension(file)+".prefab";
				filename = haxe.io.Path.withoutDirectory(filepath);
				
				sys.io.File.saveContent(filepath, json);
				editor.onScene();

				return true;
			}
		}

		return false;
	}


	/* ------------------------------ ASSETS LOADING ------------------------------ */


	// Open Bitmap file
	public function openBitmap(type:String = "bitmap") {
		var file = openfile("Open Image", "Image Files", ["png", "jpeg", "jpg"]);
		if (file == null) return;

		var data = sys.io.File.getBytes(file);
		var tile = hxd.res.Any.fromBytes(file, data).toImage().toTile();
		var name = haxe.io.Path.withoutDirectory(file).split(".").shift();

		var prefab:prefab.Image = null;
		switch (type) {
			case "bitmap":
				prefab = new prefab.Bitmap();
			case "scalegrid":
				prefab = new prefab.ScaleGrid();
			case "anim":
			default:
		}

		prefab.tile = tile;
		prefab.src = getPath(file);

		prefab.name = editor.getUID(prefab.type);
		prefab.object.name = prefab.name;

		editor.scene.addChild(prefab.object);
		editor.add(prefab.object, prefab);
	}



	// Open Texture image
	public function openTexture(type:String = "bitmap") {
		if (editor.texture.atlas == null) {
			openAtlas(type);
			return;
		}

		function onSelect(name:String) {
			var atlas = editor.texture.atlas;

			var prefab:prefab.Image = null;
			switch (type) {
				case "bitmap":
					prefab = new prefab.Bitmap();
				case "scalegrid":
					prefab = new prefab.ScaleGrid();
				case "anim":
				default:
			}

			prefab.name = editor.getUID(prefab.type);
			prefab.object.name = prefab.name;
	
			prefab.tile = atlas.get(name);
			prefab.atlas = atlas.name;
			prefab.path = Assets.atlasPath.get(atlas.name);
			prefab.src = name;
	
			editor.scene.addChild(prefab.object);
			editor.add(prefab.object, prefab);

			// Clear onSelect
			editor.texture.onSelect = null;
		}

		editor.texture.onSelect = onSelect;
		editor.texture.open();
	}


	// Open Prefab file
	public function openPrefab() {
		var file = openfile("Open File", "Prefab Files", ["prefab", "json"]);
		if (file == null) return;

		var name = haxe.io.Path.withoutDirectory(file).split(".").shift();
		var path = haxe.io.Path.directory(file).split("\\").join("/")+"/";

		if (directory == empty) loadDirectory = path;
		if (directory != empty) path = directory;

		var data = sys.io.File.getContent(file);
		if (data == empty) return;

		var prefab = loadPrefab(file, path);

		prefab.name = editor.getUID(prefab.type);
		prefab.object.name = prefab.name;
		prefab.link = name;
		prefab.src = getPath(file);

		editor.scene.addChild(prefab.object);
		editor.add(prefab.object, prefab);
	}


	public function getPrefab(name:String) {
		var path = directory == empty ? loadDirectory : directory;
		return loadPrefab(path + name, path);
	}


	// Load prefab as h2d.Object
	public function loadPrefab(file:String, path:String = ""):prefab.Linked {
		var raw = sys.io.File.getContent(file);
		var res:Data = haxe.Json.parse(raw);

		var hierarchy:Map<String, h2d.Object> = new Map();
		var prefab = new prefab.Linked();

		for (entry in res.children) {
			var object:h2d.Object = null;

			if (entry.type == "object") {
				var item = new h2d.Object();
				hierarchy.set(entry.name, item);
				object = item;
			}

			if (entry.type == "bitmap") {
				var tile:h2d.Tile;

				if (entry.atlas != null) {
					if (!sys.FileSystem.exists(path + entry.path)) throw("Could not find atlas " + entry.atlas + ".atlas");

					loadAtlas(path + entry.path);
					tile = Assets.atlas.get(entry.atlas).get(entry.src);
				}
				else {
					if (!sys.FileSystem.exists(path + entry.src)) throw("Could not find image " + entry.src);

					var bytes = sys.io.File.getBytes(path + entry.src);
					tile = hxd.res.Any.fromBytes(path + entry.src, bytes).toImage().toTile();
				}

				var item = new h2d.Bitmap(tile);

				if (entry.width != null) item.width = entry.width;
				if (entry.height != null) item.height = entry.height;

				if (entry.smooth != null) item.smooth = entry.smooth == 1 ? true : false;
				if (entry.dx != null) item.tile.setCenterRatio(entry.dx, entry.dy);

				if (entry.atlas != null) {
					prefab.bitmap.set(entry.link, item);
					prefab.field.set(entry.link, { name : entry.link, type : "bitmap", data : entry.atlas, original : entry.src, value : entry.src });
				}

				hierarchy.set(entry.name, item);
				object = item;
			}

			if (entry.type == "scalegrid") {
				var tile:h2d.Tile;

				if (entry.atlas != null) {
					if (!sys.FileSystem.exists(path + entry.path)) throw("Could not find atlas " + entry.atlas + ".atlas");

					loadAtlas(path + entry.path);
					tile = Assets.atlas.get(entry.atlas).get(entry.src);
				}
				else {
					if (!sys.FileSystem.exists(path + entry.src)) throw("Could not find image " + entry.src);

					var bytes = sys.io.File.getBytes(path + entry.src);
					tile = hxd.res.Any.fromBytes(path + entry.src, bytes).toImage().toTile();
				}

				var size = entry.range ?? 10;
				var item = new h2d.ScaleGrid(tile, size, size);

				item.width = entry.width;
				item.height = entry.height;

				if (entry.smooth != null) item.smooth = entry.smooth == 1 ? true : false;

				hierarchy.set(entry.name, item);
				object = item;
			}

			if (entry.type == "text") {
				var font = hxd.res.DefaultFont.get();
				if (entry.font != null) font = getFont(path + entry.src);

				var item = new h2d.Text(font);
				item.text = entry.text ?? "";
				item.smooth = true;

				if (entry.color != null) item.textColor = entry.color;
				if (entry.align != null) item.textAlign = entry.align == 1 ? Center : Right;
				if (entry.width != null) item.letterSpacing = entry.width;
				if (entry.height != null) item.lineSpacing = entry.height;
				if (entry.range != null) item.maxWidth = entry.range;

				prefab.text.set(entry.link, item);
				prefab.field.set(entry.link, { name : entry.link, type : "text", data : empty, original : item.text, value : item.text });
				
				hierarchy.set(entry.name, item);
				object = item;
			}

			if (entry.type == "graphics") {
				var item = new h2d.Bitmap(h2d.Tile.fromColor(0xFFFFFF, 128, 128));

				if (entry.color != null) {
					var a = item.color.w;
					item.color.setColor(entry.color);
					item.color.w = a;
				}

				if (entry.width != null) item.width = entry.width;
				if (entry.height != null) item.height = entry.height;

				item.smooth = false;
				
				hierarchy.set(entry.name, item);
				object = item;
			}

			if (entry.type == "mask") {
				var item = new h2d.Mask(Std.int(entry.width), Std.int(entry.height));

				hierarchy.set(entry.name, item);
				object = item;
			}

			if (entry.type == "prefab") {
				if (!sys.FileSystem.exists(path + entry.src)) throw("Could not find prefab " + entry.src);

				var f = haxe.io.Path.directory(file).split("\\").join("/")+"/";
				var n = haxe.io.Path.withoutDirectory(file);

				if (path + entry.src == f + n) throw("Prefab: " + entry.src + " is linked to itself");

				var item = loadPrefab(path + entry.src, path);
				object = item.object;
			}

			if (object == null) continue;

			object.name = entry.link;

			object.x = entry.x ?? 0;
			object.y = entry.y ?? 0;
			object.scaleX = entry.scaleX ?? 1;
			object.scaleY = entry.scaleY ?? 1;
			object.rotation = entry.rotation ?? 0;

			if (entry.blendMode != null) object.blendMode = haxe.EnumTools.createByName(h2d.BlendMode, entry.blendMode);
			object.visible = entry.visible ?? true;
			object.alpha = entry.alpha ?? 1;

			var p:h2d.Object = entry.parent != null ? hierarchy.get(entry.parent) : prefab.object;
			p.addChild(object);
		}

		var bound = prefab.object.getBounds();

		prefab.width = bound.width;
		prefab.height = bound.height;

		prefab.x = bound.getCenter().x - bound.width * 0.5;
		prefab.y = bound.getCenter().y - bound.height * 0.5;

		return prefab;
	}



	// Open Atlas file
	public function openAtlas(type:String = "bitmap") {
		var file = openfile("Open Texture Atlas", "Texture Atlas Files", ["atlas"]);
		if (file == null) return;

		var folder = haxe.io.Path.directory(file).split("\\").join("/")+"/";
		var name = haxe.io.Path.withoutDirectory(file).split(".").shift();

		if (Assets.atlas.exists(name)) return;

		var data = sys.io.File.getBytes(folder + name + ".png");
		var tile = hxd.res.Any.fromBytes(folder + name + ".png", data).toImage().toTile();
		var entry = sys.io.File.getContent(file);
		var path = getPath(file);

		var atlas = new Texture.Atlas(name, entry, tile);

		editor.addAtlas(atlas, name, path);
		openTexture(type);
	}


	public function loadAtlas(file:String) {
		var folder = haxe.io.Path.directory(file).split("\\").join("/")+"/";
		var name = haxe.io.Path.withoutDirectory(file).split(".").shift();

		if (Assets.atlas.exists(name)) return; // [?]

		var data = sys.io.File.getBytes(folder + name + ".png");
		var tile = hxd.res.Any.fromBytes(folder + name + ".png", data).toImage().toTile();
		var entry = sys.io.File.getContent(file);
		var path = getPath(file);

		var atlas = new Texture.Atlas(name, entry, tile);

		editor.addAtlas(atlas, name, path);
	}



	// Open Font file
	public function openFont():Null<String> {
		var file = openfile("Open Font", "Font Files", ["fnt"]);
		if (file == null) return null;

		var name = haxe.io.Path.withoutDirectory(file).split(".").shift();
		var font = getFont(file);
		var path = getPath(file);

		editor.addFont(font, name, path);
		return name;
	}


	public function loadFont(file:String) {
		var name = haxe.io.Path.withoutDirectory(file).split(".").shift();
		
		if (!sys.FileSystem.exists(file)) throw("Could not find Font " + name + ".fnt");

		// TODO: check if font is loaded
		var font = getFont(file);
		var path = getPath(file);

		editor.addFont(font, name, path);
	}


	public function getFont(file:String) {
		function resolveFontImage(path:String):h2d.Tile {
			var data = sys.io.File.getBytes(path);
			return hxd.res.Any.fromBytes(path, data).toImage().toTile();
		}

		var font:h2d.Font = hxd.fmt.bfnt.FontParser.parse(sys.io.File.getBytes(file), file, resolveFontImage);
		return font;
	}


	// Get relative path to file
	public function getPath(file:String) {
		var folder = haxe.io.Path.directory(file).split("\\").join("/")+"/";
		var name = haxe.io.Path.withoutDirectory(file);


		// Prefab not saved: can't build relative path
		if (directory == empty) return name;

		// External file: can't build relative path
		if (!StringTools.startsWith(folder.toLowerCase(), directory.toLowerCase())) return name;

		// Relative path to file
		if (StringTools.startsWith(folder.toLowerCase(), directory.toLowerCase())) return folder.substr(directory.length) + name;


		return name;
	}


	public function isExternal(file:String) {
		var folder = haxe.io.Path.directory(file).split("\\").join("/")+"/";

		if (directory == empty) return true;
		if (!StringTools.startsWith(folder.toLowerCase(), directory.toLowerCase())) return true;

		return false;
	}


	public function clear() {
		filename = defaultFilename;
		directory = "";
		filepath = "";
	}
}


typedef Field = { name : String, type : String, data : String, original : String, value : String };

typedef Data = {
	var name : String;
	var type : String;
	var link : String;

	@:optional var children : Array<Data>;
	@:optional var parent : String;

	@:optional var field : Array<Field>;

	@:optional var x : Float;
	@:optional var y : Float;
	@:optional var scaleX : Float;
	@:optional var scaleY : Float;
	@:optional var rotation : Float;

	@:optional var blendMode : String;
	@:optional var visible : Bool;
	@:optional var alpha : Float;

	@:optional var src : String;

	@:optional var width : Float;
	@:optional var height : Float;

	@:optional var smooth : Int;
	
	@:optional var dx : Float;
	@:optional var dy : Float;

	@:optional var color : Int;
	@:optional var align : Int;
	@:optional var range : Int;

	@:optional var text : String;
	@:optional var atlas : String;
	@:optional var font : String;
	@:optional var path : String;
}