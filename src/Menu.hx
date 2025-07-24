import h2d.col.Point;
import h2d.Object;
import h2d.Bitmap;
import hxd.Event;


class Menu extends h2d.Object {
	var editor:Editor;
	
	var fileMenu:ui.Dropdown;
	var editMenu:ui.Dropdown;
	var assetMenu:ui.Dropdown;
	var motionMenu:ui.Dropdown;

	var divider:Int = 0;
	public var width:Float = 0;

	
	public function new(?parent:h2d.Object) {
		super(parent);

		editor = Editor.ME;

		// File
		fileMenu = new ui.Dropdown(this, "File");
		fileMenu.onChange = onChange;

		fileMenu.add("New");
		fileMenu.add("Open");
		fileMenu.add("Save");
		fileMenu.add("Save As");
		fileMenu.addDivider();
		
		fileMenu.add("About");
		fileMenu.addDivider();

		fileMenu.add("Quit");


		// Edit
		editMenu = new ui.Dropdown(this, "Edit");
		editMenu.onChange = onChange;
		editMenu.x = fileMenu.x + fileMenu.width + divider;

		editMenu.add("Undo", "undo", "Ctrl+Z", false);
		editMenu.add("Redo", "redo", "Ctrl+Y", false);
		editMenu.addDivider();

		editMenu.add("Cut", "", "Ctrl+X");
		editMenu.get("Cut").padding = Style.menuPadding;

		editMenu.add("Copy", "", "Ctrl+C");
		editMenu.get("Copy").padding = Style.menuPadding;

		editMenu.add("Paste", "", "Ctrl+V");
		editMenu.get("Paste").padding = Style.menuPadding;

		editMenu.add("Delete", "delete", "Delete");


		// Asset
		assetMenu = new ui.Dropdown(this, "Asset");
		assetMenu.onChange = onChange;
		assetMenu.x = editMenu.x + editMenu.width + divider;
		
		assetMenu.add("Add Object", "object");

		assetMenu.add("Add Bitmap", "bitmap");
		assetMenu.add("Add ScaleGrid", "scalegrid");
		assetMenu.add("Add Anim", "anim");

		assetMenu.add("Add Text", "text");
		assetMenu.add("Add Interactive", "interactive");
		assetMenu.add("Add Graphics", "graphics");
		assetMenu.add("Add Mask", "mask");
		assetMenu.addDivider();

		assetMenu.add("Add from Texture Atlas", "bitmap");
		assetMenu.add("Add from Texture Atlas", "scalegrid");
		assetMenu.add("Add from Texture Atlas", "anim");
		assetMenu.addDivider();

		assetMenu.add("Place Prefab", "prefab");
		assetMenu.addDivider();
		
		assetMenu.add("Load Texture Atlas", "load");
		assetMenu.add("Load Font", "load");


		// Animation
		motionMenu = new ui.Dropdown(this, "Animation");
		motionMenu.onChange = onChange;
		motionMenu.x = assetMenu.x + assetMenu.width + divider;
		
		motionMenu.add("New Animation", "add");
		motionMenu.add("Remove", "delete");

		width = motionMenu.x + motionMenu.width + divider;
	}


	// Not Enums for speed
	function onChange(value:String, type:String) {
		switch (value) {
			case "New" : editor.clear();
			case "Open" : editor.file.open();
			case "Save" : editor.file.save();
			case "Save As" : editor.file.save(true);

			case "About" : hxd.System.openURL("https://github.com/nayata/hexe");
			case "Quit" : hxd.System.exit();

			case "Undo" : editor.history.undo();
			case "Redo" : editor.history.redo();

			case "Cut" : editor.onClipboard("cut");
			case "Copy" : editor.onClipboard("copy");
			case "Paste" : editor.onClipboard("paste");

			case "Delete" : editor.delete(editor.selected);

			case "Add Object" : editor.make("object");

			case "Add Bitmap" : editor.file.openBitmap();
			case "Add ScaleGrid" : editor.file.openBitmap("scalegrid");
			case "Add Anim" : editor.file.openBitmap("anim");
			
			case "Add Text" : editor.make("text");
			case "Add Interactive" : editor.make("interactive");
			case "Add Graphics" : editor.make("graphics");
			case "Add Mask" : editor.make("mask");

			case "Add from Texture Atlas" : editor.file.openTexture(type);
			case "Place Prefab" : editor.file.openPrefab();

			case "Load Texture Atlas" : editor.file.openAtlas();
			case "Load Font" : editor.file.openFont();

			case "New Animation" : editor.motion.onAnimation(true);
			case "Remove" : editor.motion.onAnimation();
			
			default:
		}
	}
}