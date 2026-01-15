import h2d.col.Point;
import h2d.Object;
import h2d.Bitmap;
import hxd.Event;

import ui.Item;


class Context extends h2d.Object {
	var editor:Editor;
	
	var input:h2d.Interactive;
	var panel:h2d.Graphics;
	var highlight:h2d.Bitmap;
	
	var items:Array<Item> = [];
	var selected:Item = null;

	public var width:Int = 240;
	public var height:Int = 40;

	public var dividers:Int = 0;
	public var padding:Int = 25;

	public var wide:Int = 240;
	public var size:Int = 40;

	
	public function new(?parent:h2d.Object) {
		super(parent);

		editor = Editor.ME;

		input = new h2d.Interactive(0, 0, this);
		input.cursor = Default;
		input.onClick = onClick;
		input.onMove = onMove;
		input.onOut = onOut;

		panel = new h2d.Graphics(this);

		highlight = new h2d.Bitmap(h2d.Tile.fromColor(Style.menu, wide, size), panel);
		highlight.visible = false;


		// Visuals
		add("Add Object", "object");

		add("Add Bitmap", "bitmap");
		add("Add ScaleGrid", "scalegrid");
		add("Add Anim", "anim");

		add("Add Text", "text");
		add("Add Interactive", "interactive");
		add("Add Graphics", "graphics");
		add("Add Mask", "mask");

		add("Add from Texture Atlas", "bitmap");
		add("Add from Texture Atlas", "scalegrid");
		add("Add from Texture Atlas", "anim");

		add("Place Prefab", "prefab");

		addDivider();

		// Clipboard
		add("Cut", "", "Ctrl+X");
		get("Cut").padding = Style.menuPadding;

		add("Copy", "", "Ctrl+C");
		get("Copy").padding = Style.menuPadding;

		add("Paste", "", "Ctrl+V");
		get("Paste").padding = Style.menuPadding;

		add("Delete", "delete", "Delete");


		input.width = width;
		input.height = dividers + items.length * height;

		panel.clear();
		panel.beginFill(Style.background);
		panel.drawRect(0, 0, input.width, input.height);
		panel.endFill();

		filter = new h2d.filter.DropShadow(5, Math.PI/4, 0, 0.25, 20.0, 1, 1.0, true);

		visible = false;
	}


	function add(value:String, ?icon:String = "", ?shortcut:String = "", ?closable:Bool = true) {
		var item = new Item(this, value);
		
		item.y = dividers + items.length * height;

		item.closable = closable;
		item.shortcut = shortcut;
		item.icon = icon;

		items.push(item);
	}


	function get(name:String) {
		for (node in items) {
			if (node.text == name) return node;
		}
		return null;
	}


	function addDivider() {
		var item = new Item(this, "");

		item.y = dividers + items.length * height;
		item.setDivider(width, 4);

		dividers += 4;
	}


	function onClick(e:hxd.Event) {
		if (!visible) return;

		if (selected != null) {
			if (selected.closable) close();

			onChange(selected.text, selected.icon);
		}
	}


	function onMove(event:hxd.Event) {
		if (!visible) return;

		selected = null;

		var mouse = new h2d.col.Point(event.relX, event.relY);

		for (node in items) {
			if (mouse.y >= node.y && mouse.y < node.y + size) {
				selected = node;
			}
		}

		highlight.visible = selected != null ? true : false;
		highlight.y = selected != null ? selected.y : 0;
	}


	function onOut(e:hxd.Event) {
		close();
	}


	public function open() {
		x = editor.s2d.mouseX - 20;
		y = editor.s2d.mouseY - 5;

		if (x + width > editor.WIDTH) x = editor.WIDTH - width - 20;
		
		visible = true;
	}


	public function close() {
		highlight.visible = false;
		visible = false;
	}


	function onChange(value:String, type:String) {
		switch (value) {
			case "Add Object" : editor.make("object", true);

			case "Add Bitmap" : editor.file.openBitmap(true);
			case "Add ScaleGrid" : editor.file.openBitmap("scalegrid", true);
			case "Add Anim" : editor.file.openBitmap("anim", true);
			
			case "Add Text" : editor.make("text", true);
			case "Add Interactive" : editor.make("interactive", true);
			case "Add Graphics" : editor.make("graphics", true);
			case "Add Mask" : editor.make("mask", true);

			case "Add from Texture Atlas" : editor.file.openTexture(type, true);
			case "Place Prefab" : editor.file.openPrefab(true);

			case "Cut" : editor.onClipboard("cut");
			case "Copy" : editor.onClipboard("copy");
			case "Paste" : editor.onClipboard("paste", true);
			case "Delete" : editor.delete(editor.selected);
			
			default:
		}
	}
}