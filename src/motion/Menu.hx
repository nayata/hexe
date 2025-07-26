package motion;

class Menu extends h2d.Object {
	var editor:Editor;
	
	var keyframeMenu:ui.Dropdown;
	var easingMenu:ui.Dropdown;

	var divider:Int = 0;

	
	public function new(?parent:h2d.Object) {
		super(parent);

		editor = Editor.ME;

		// Keyframe
		keyframeMenu = new ui.Dropdown(this, "Key");
		keyframeMenu.onChange = onChange;
		
		keyframeMenu.add("Add Keyframe", "add", "", false);
		keyframeMenu.add("Select All", "wrap", "", false);
		keyframeMenu.addDivider();

		keyframeMenu.add("Cut");
		keyframeMenu.get("Cut").padding = Style.menuPadding;

		keyframeMenu.add("Copy");
		keyframeMenu.get("Copy").padding = Style.menuPadding;

		keyframeMenu.add("Paste");
		keyframeMenu.get("Paste").padding = Style.menuPadding;

		keyframeMenu.add("Delete", "delete");


		// Easing
		easingMenu = new ui.Dropdown(this, "Easing");
		easingMenu.onChange = onChange;
		easingMenu.x = keyframeMenu.x + keyframeMenu.width + divider;

		easingMenu.add("linear", "bitmap");

		easingMenu.add("easeIn", "bitmap");
		easingMenu.add("easeOut", "bitmap");

		easingMenu.add("easeInOut", "bitmap");
		easingMenu.add("easeOutIn", "bitmap");

		easingMenu.add("easeInBack", "bitmap");
		easingMenu.add("easeOutBack", "bitmap");

		easingMenu.add("easeInOutBack", "bitmap");
		easingMenu.add("easeOutInBack", "bitmap");

		easingMenu.add("easeInElastic", "bitmap");
		easingMenu.add("easeOutElastic", "bitmap");

		easingMenu.add("easeInBounce", "bitmap");
		easingMenu.add("easeOutBounce", "bitmap");

		visible = false;
	}


	// Not Enums for speed
	function onChange(value:String, type:String) {
		if (type == "bitmap") editor.motion.setEase(value);

		switch (value) {
			case "Add Keyframe" : editor.motion.onKeyframe("add");
			case "Select All" : editor.motion.onKeyframe("select");

			case "Cut" : editor.motion.onClipboard("cut");
			case "Copy" : editor.motion.onClipboard("copy");
			case "Paste" : editor.motion.onClipboard("paste");

			case "Delete" : editor.motion.onKeyframe("delete");

			default:
		}
	}
}