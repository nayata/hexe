class Context extends ui.Context {
	public function new(?parent:h2d.Object) {
		super(parent);

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

		add("Add Collider", "collider");
		add("Place Prefab", "prefab");

		addDivider();

		// Clipboard
		add("Duplicate", "duplicate", "Ctrl+D");
		add("Cut", "", "Ctrl+X");
		get("Cut").padding = Style.menuPadding;

		add("Copy", "", "Ctrl+C");
		get("Copy").padding = Style.menuPadding;

		add("Paste", "", "Ctrl+V");
		get("Paste").padding = Style.menuPadding;

		add("Delete", "delete", "Delete");
	}


	override function onChange(value:String, type:String) {
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

			case "Add Collider" : editor.make("collider", true);
			case "Place Prefab" : editor.file.openPrefab(true);

			case "Duplicate" : editor.onClipboard("duplicate", true);
			case "Cut" : editor.onClipboard("cut");
			case "Copy" : editor.onClipboard("copy");
			case "Paste" : editor.onClipboard("paste", true);
			case "Delete" : editor.delete(editor.selected);
			
			default:
		}
	}
}