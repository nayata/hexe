class Context extends ui.Context {
	public function new(?parent:h2d.Object) {
		super(parent);

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
			case "Duplicate" : editor.onClipboard("duplicate", true);
			case "Cut" : editor.onClipboard("cut");
			case "Copy" : editor.onClipboard("copy");
			case "Paste" : editor.onClipboard("paste", true);
			case "Delete" : editor.delete(editor.selected);
			
			default:
		}
	}
}