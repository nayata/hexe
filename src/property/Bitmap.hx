package property;

import property.component.Label;
import property.component.Input;
import property.component.Number;
import property.component.Checkbox;
import property.component.Anchor;
import property.component.File;


class Bitmap extends Property {
	var file:Input;


	public function new(?parent:h2d.Object) {
		super(parent);

		var label = new Label("Source", 0, half, this);
		//label("Source", 0, half);

		
		file = set("src", new File(this));
		file.setPosition(second, 0);
		file.onSelect = onFile;
		file.setSize(166, 32);
		file.icon = "bitmap";

		top += file.height + padding;


		// Bitmap size
		label = new Label("Size", 0, top + half, this);

		var input:Input = set("width", new Number(this));
		input.setPosition(second, top);
		input.onUpdate = onUpdate;
		input.onChange = onChange;
		input.label = "W";

		input = set("height", new Number(this));
		input.setPosition(third, top);
		input.onUpdate = onUpdate;
		input.onChange = onChange;
		input.label = "H";

		top += input.height + divider;


		// Bitmap tile pivot
		label = new Label("Pivot", 0, top + half * 0.5, this);

		input = set("anchor", new Anchor(this));
		input.setPosition(second, top);
		input.onChange = onChange;

		top += input.height + divider;


		// Bitmap smooth
		label = new Label("Smooth", 0, top + half * 0.5, this);

		input = set("smooth", new Checkbox(this));
		input.setPosition(second, top);
		input.onChange = onChange;
	}


	function onFile(prop:Dynamic) {
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
}