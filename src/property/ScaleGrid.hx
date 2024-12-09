package property;

import property.component.Label;
import property.component.Input;
import property.component.Checkbox;
import property.component.Number;
import property.component.File;


class ScaleGrid extends Property {
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
		input.label = "W";

		input = set("height", new Number(this));
		input.setPosition(third, top);
		input.onUpdate = onUpdate;
		input.onChange = onChange;
		input.label = "H";

		top += input.height + padding;

		
		// Border size
		label = new Label("Border", 0, top + half, this);

		input = set("border", new Number(this));
		input.setPosition(second, top);
		input.onUpdate = onUpdate;
		input.onChange = onChange;
		input.label = "S";

		top += input.height + divider;


		// Bitmap smooth
		label = new Label("Smooth", 0, top + half * 0.5, this);

		input = set("smooth", new Checkbox(this));
		input.setPosition(second, top);
		input.onChange = onChange;
	}


	override public function select(object:Dynamic) {
		super.select(object);

		var prefab = (cast object : prefab.Image);
		file.icon = prefab.atlas == "" ? "bitmap" : "texture";
	}


	function onFile(prop:Dynamic) {
		var prefab = (cast object : prefab.Image);

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
	}


	function openTexture(prop:Dynamic) {
		function onSelect(name:String) {
			onChange({ field : "image", from : file.value, to : name });
			file.value = name;

			Editor.ME.texture.onSelect = null;
		}

		var prefab = (cast object : prefab.Image);

		Editor.ME.texture.onSelect = onSelect;
		Editor.ME.texture.open(prefab.atlas);
	}
}