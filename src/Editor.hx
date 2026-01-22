import h2d.Object;
import h2d.Bitmap;

import hxd.Event;
import h3d.Vector;
import h2d.col.Point;
import hxd.Key;

import prefab.Prefab;
import ui.Button;
import ui.Grid;


class Editor extends hxd.App {
	public static var ME:Editor;

	public var WIDTH:Int = 1600;
	public var HEIGHT:Int = 900;

	public var children:Map<String, Prefab> = new Map();
	public var hierarchy:Array<Object> = [];

	public var selected:Null<Object> = null;

	public var grid:Grid;
	public var scene:Object;

	public var control:Control;
	public var outliner:Outliner;
	public var context:Context;

	public var toolbar:Toolbar;
	public var sidebar:Sidebar;
	public var property:Properties;
	public var texture:Texture;

	public var menu:Menu;
	public var view:Button;

	public var clipboard:Null<Prefab> = null;

	public var history:History;
	public var file:File;

	
    static function main() {
		ME = new Editor();
    }


	override function init() {
		hl.UI.closeConsole();
		engine.backgroundColor = Style.background;
		
		hxd.Res.initLocal();

		Config.init();
		Assets.init();
		
		grid = new Grid(s2d.width, s2d.height, Config.gridSize, s2d);
		grid.onMove(200, 200);

		scene = new Object(s2d);
		scene.x = scene.y = 200;
		scene.name = "root";

		control = new Control(s2d);
		control.onKeyboard = onKeyboard;
		control.gridSize = Config.gridSize;
		control.width = s2d.width - 300;
		control.height = s2d.height;

		sidebar = new Sidebar(s2d);

		outliner = new Outliner(sidebar);
		outliner.onSize = onScroll;
		outliner.y = 60;

		context = new Context(s2d);

		property = new Properties(sidebar);
		property.y = 300;

		history = new History();
		file = new File();

		toolbar = new Toolbar(s2d);
		toolbar.onChange = control.onTool;
		toolbar.x = s2d.width * 0.5 - toolbar.width * 0.5;
		toolbar.y = 20;

		menu = new Menu(s2d);
		menu.x = 10;
		menu.y = 10;

		view = new Button("Actual Size", s2d);
		view.onChange = control.onView;
		view.x = s2d.width - view.width;
		view.y = 10;

		texture = new Texture(s2d);

		onResize();
	}


	override function onResize() {
		super.onResize();

		if (hxd.Window.getInstance().height == 0) return;

		WIDTH = hxd.Window.getInstance().width;
		HEIGHT = hxd.Window.getInstance().height;

		toolbar.x = (WIDTH - sidebar.width) * 0.5 - toolbar.width * 0.5 + toolbar.height;
		view.x = WIDTH - sidebar.width - view.width;

		grid.width = WIDTH;
		grid.height = HEIGHT;

		control.width = WIDTH - sidebar.width;
		control.height = HEIGHT;
		control.onResize();

		sidebar.height = HEIGHT;
		sidebar.x = WIDTH - sidebar.width;
		sidebar.onResize();

		outliner.onResize();
		property.onResize();

		texture.width = WIDTH;
		texture.height = HEIGHT;
	}


	function onScroll() {
		property.y = outliner.position + outliner.y + 40;
		property.onResize();
	}


	/* ------------------------------ Editor API ------------------------------ */

	// Selection
	public function autoSelect(value:Bool) {
		control.autoSelect = value;
	}


	public function select(selection:String) {
		if (!children.exists(selection)) return;

		selected = children.get(selection).object;

		outliner.select(selected);
		control.select(selected);

		property.select(selected);
	}


	public function unselect() {
		outliner.unselect();
		control.unselect();

		property.unselect();

		selected = null;
	}


	public function onTransform() {
		property.onChange();
	}

	
	public function onProperty() {
		control.onChange();
	}


	public function onHistory() {
		outliner.onResize();
		property.onChange();
		control.onChange();
	}


	public function onScene() {
		hxd.Window.getInstance().title = file.filename;
		property.onScene();
		unselect();
	}


	public function onProject() {
		property.onScene();
	}


	public function onName() {
		if (selected == null) return;
		outliner.rename(selected.name, children.get(selected.name).link);
	}


	public function snapToGrid(value:Bool) {
		control.snapToGrid = value;
	}


	// New Scene
	public function clear() {
		hxd.Window.getInstance().title = file.defaultName;
		scene.removeChildren();

		Assets.clear();
		
		children.clear();
		hierarchy = [];

		outliner.clear();
		property.clear();
		history.clear();

		texture.clear();
		file.clear();
		uid.clear();

		clipboard = null;

		property.onScene();
		control.onScene();
		unselect();
	}


	/* ------------------------------ Keyboard actions ------------------------------ */
	function onKeyboard(key:Int) {
		switch (key) {
			case Key.DELETE : 
				delete(selected);

			case Key.Z if (Key.isDown(Key.CTRL)):
				history.undo();
			case Key.Y if (Key.isDown(Key.CTRL)):
				history.redo();

			case Key.D if (Key.isDown(Key.CTRL)):
				onClipboard("copy");
				onClipboard("paste");

			case Key.C if (Key.isDown(Key.CTRL)):
				onClipboard("copy");
			case Key.X if (Key.isDown(Key.CTRL)):
				onClipboard("cut");
			case Key.V if (Key.isDown(Key.CTRL)):
				onClipboard("paste");

			default:
		}
	}


	/* ------------------------------ Objects actions ------------------------------ */
	public function addChild(object:Object, ?highlighted = false) {
		var container:Object = scene;

		if (highlighted && selected != null) {
			container = children.get(selected.name).locked ? selected.parent : selected;
		}

		container.addChild(object);
	}


	public function add(object:Object, prefab:Prefab, keep:Bool = true) {
		hierarchy.push(object);
		children.set(object.name, prefab);

		outliner.add(object.name, prefab.link);
		outliner.onChange(); // [?]

		select(object.name);

		if (keep) history.add(new History.Add(object, prefab, object.parent, object.parent.getChildIndex(object)));
	}


	public function delete(object:Object, keep:Bool = true) {
		if (object == null) return;

		outliner.delete(object);
			
		// Remove Object and Prefab
		// Object childs prefabs still exist in the `children` list

		if (keep) history.add(new History.Delete(object, children.get(object.name), object.parent, object.parent.getChildIndex(object)));
			
		children.remove(object.name);

		object.remove();
		unselect();

		outliner.onChange();
	}


	/* ------------------------------ Clipboard actions ------------------------------ */
	public function onClipboard(type:String, ?highlighted = false) {
		switch (type) {
			case "copy":
				if (selected != null) clipboard = children.get(selected.name);
			case "cut":
				if (selected != null) {
					clipboard = children.get(selected.name);
					delete(selected);
				}
			case "paste":
				if (clipboard != null) {
					var prefab = clipboard.clone();

					if (prefab != null) {
						prefab.name = getUID(prefab.type);
						prefab.object.name = prefab.name;
				
						addChild(prefab.object, highlighted);
						add(prefab.object, prefab);
					}
				}
			case "duplicate":
				if (selected != null) {
					clipboard = children.get(selected.name);

					var prefab = clipboard.clone();
					if (prefab != null) {
						prefab.name = getUID(prefab.type);
						prefab.object.name = prefab.name;
					
						addChild(prefab.object, highlighted);
						add(prefab.object, prefab);
					}
				}
			default:
		}
	}


	/* ------------------------------ ASSETS ------------------------------ */

	public function make(type:String, ?highlighted = false) {
		var prefab:Prefab;

		switch (type) {
			case "object":
				prefab = new prefab.Object();
			case "text":
				prefab = new prefab.Text();
			case "bitmap":
				prefab = new prefab.Bitmap();
			case "interactive":
				prefab = new prefab.Interactive();
			case "graphics":
				prefab = new prefab.Graphics();
			case "mask":
				prefab = new prefab.Mask();
			case "collider":
				prefab = new prefab.Collider();
			default:
				prefab = new Prefab();
		}

		prefab.name = getUID(prefab.type);
		prefab.object.name = prefab.name;

		addChild(prefab.object, highlighted);
		add(prefab.object, prefab);
	}


	public function addAtlas(atlas:Texture.Atlas, name:String, path:String) {
		Assets.atlas.set(name, atlas);
		Assets.atlasPath.set(name, path);

		texture.set(name);
	}


	public function addFont(font:h2d.Font, name:String, path:String) {
		Assets.fonts.set(name, font);
		Assets.fontPath.set(name, path);

		property.rebuild("text");
	}


	/* ------------------------------ Tools ------------------------------ */
	// Unique ID generation
	var uid:Map<String, Int> = new Map();

	public function getUID(type:String):String {
		var unique = type;

		if (uid.exists(type)) {
			uid.set(type, uid.get(type) + 1);
			unique = type + "." + uid.get(type);
		}
		else {
			uid.set(type, 0);
		}

		return unique;
	}


	public function setUID(name:String) {
		var entry = name.split(".");

		var type = entry.shift();
		var link = entry.length > 0 ? Std.parseInt(entry[0]) : 0;

		if (uid.exists(type)) {
			var unique = Math.max(uid.get(type), link);
			uid.set(type, Std.int(unique));
		}
		else {
			uid.set(type, Std.int(link));
		}
	}


	// Color from String
	public function getColor(hex:String):Null<Int> {
		if (hex.charAt(0) == "#") hex = hex.substr(1);

		var color = Std.parseInt("0x"+hex);
		if (color == null) return null;

		color = color & 0xFFFFFFFF;

		switch (hex.length) {
			case 2: // Assume color is shade of gray
				color = (color << 16) + (color << 8) + (color);
			case 3: // handle #XXX html codes
				var r = (color >> 8) & 0xF;
				var g = (color >> 4) & 0xF;
				var b = (color >> 0) & 0xF;
				color = (r << 20) + (r << 16) + (g << 12) + (g << 8) + (b << 4) + (b << 0);
			case 6:
			case 8:
			default:
				return null;
		}

		return color & 0xFFFFFF;
	}
}