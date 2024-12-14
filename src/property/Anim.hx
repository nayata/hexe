package property;

import property.component.Label;
import property.component.Input;
import property.component.Checkbox;
import property.component.Number;
import property.component.File;


class Anim extends Property {
	var file:Input;


	public function new(?parent:h2d.Object) {
		super(parent);

		var label = new Label("Source", 0, half, this);
		
		file = set("src", new File(this));
		file.setPosition(second, 0);
		file.onSelect = onFile;
		file.setSize(166, 32);
		file.icon = "bitmap";

		top += file.height + padding;


		// Size
		label = new Label("Size", 0, top + half, this);

		var input = set("width", new Number(this));
		input.setPosition(second, top);
		input.onUpdate = onUpdate;
		input.onChange = onChange;
		input.enabled = false;
		input.minimum = 0;
		input.label = "W";

		input = set("height", new Number(this));
		input.setPosition(third, top);
		input.onUpdate = onUpdate;
		input.onChange = onChange;
		input.enabled = false;
		input.minimum = 0;
		input.label = "H";

		top += input.height + padding;

		
		// Total Frames
		label = new Label("Grid", 0, top + half, this);

		input = set("row", new Number(this));
		input.setPosition(second, top);
		input.onUpdate = onUpdate;
		input.onChange = onChange;
		input.minimum = 1;
		input.label = "X";

		input = set("col", new Number(this));
		input.setPosition(third, top);
		input.onUpdate = onUpdate;
		input.onChange = onChange;
		input.minimum = 1;
		input.label = "Y";

		top += input.height + padding;

		
		// Total Frames
		label = new Label("Speed", 0, top + half, this);

		input = set("speed", new Number(this));
		input.setPosition(second, top);
		input.onUpdate = onUpdate;
		input.onChange = onChange;
		input.minimum = 0;
		input.maximum = 60;

		top += input.height + divider;


		// Loop
		label = new Label("Loop", 0, top + half * 0.5, this);

		input = set("loop", new Checkbox(this));
		input.setPosition(second, top);
		input.onChange = onChange;

		top += input.height + padding;


		// Bitmap smooth
		label = new Label("Smooth", 0, top + half * 0.5, this);

		input = set("smooth", new Checkbox(this));
		input.setPosition(second, top);
		input.onChange = onChange;
	}


	override public function select(object:Dynamic) {
		super.select(object);

		var prefab = (cast object : prefab.Drawable);
		file.icon = prefab.atlas == "" ? "bitmap" : "texture";

		registry.get("row").enabled = prefab.atlas == "" ? true : false;
		registry.get("col").enabled = prefab.atlas == "" ? true : false;
	}


	override function onUpdate(prop:Dynamic) {
		super.onUpdate(prop);
		select(object);
	}


	function onFile(prop:Dynamic) {
		var prefab = (cast object : prefab.Drawable);

		if (prefab.atlas == "") openBitmap(prop);
		if (prefab.atlas != "") openTexture(prop);
	}


	function openBitmap(prop:Dynamic) {
		// msg: save project first
		if (Editor.ME.file.directory == "") return;

		var path = Editor.ME.file.openfile("Open Image", "Image Files", ["png", "jpeg", "jpg"]);
		if (path == null) return;

		// msg: swap images only in res folder
		if (Editor.ME.file.isExternal(path)) return;

		var src = Editor.ME.file.getPath(path);

		onChange({ field : "bitmap", from : file.value, to : src });
		file.value = src;
		select(object);
	}


	function openTexture(prop:Dynamic) {
		function onSelect(name:String) {
			onChange({ field : "image", from : file.value, to : name });
			file.value = name;
			select(object);

			Editor.ME.texture.onSelect = null;
		}

		var prefab = (cast object : prefab.Drawable);

		Editor.ME.texture.onSelect = onSelect;
		Editor.ME.texture.open(prefab.atlas);
	}
}