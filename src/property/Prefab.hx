package property;

import property.component.Label;
import property.component.Input;
import property.component.TextArea;
import property.component.File;

import ui.Scroll;


class Prefab extends Property {
	var prefab:Null<prefab.Linked> = null;
	
	var bitmap:Array<Input> = [];
	var text:Array<Input> = [];

	var scroll:Scroll;

	var label:Label;
	var max:Int = 16;


	public function new(?parent:h2d.Object) {
		super(parent);

		scroll = new Scroll(this);
		scroll.y = full;

		scroll.width = 240 + 14;
		scroll.height = 42 * 6 - 6;
		scroll.size = 42;
		
		scroll.onResize();

		label = new Label("Fields", 0, half, this);

		for (i in 0...max) {
			var input = new TextArea(scroll.view);
			input.onUpdate = onUpdate;
			input.setSize(240, 36);
			input.visible = false;
			text.push(input);
		}
		for (i in 0...max) {
			var input = new File(scroll.view);
			input.onSelect = onFile;
			input.setSize(240, 36);
			input.icon = "bitmap";
			input.visible = false;
			bitmap.push(input);
		}
	}


	override public function select(object:Dynamic) {
		prefab = (cast object : prefab.Linked);

		label.text = prefab.src;

		var i = 0;
		for (field in prefab.field) {
			if (field.type != "text") continue;
			if (i >= max) continue;

			text[i].field = field.name;
			text[i].label = field.name;
			text[i].value = field.value;

			text[i].y = i * 42;
			text[i].visible = true;
			i++;
		}

		scroll.view.height = i * 42;
		top = i * 42;
		i = 0;

		for (field in prefab.field) {
			if (field.type != "bitmap") continue;
			if (i >= max) continue;

			bitmap[i].field = field.name;
			bitmap[i].label = field.name;
			bitmap[i].value = field.value;

			bitmap[i].y = top + i * 42;
			bitmap[i].visible = true;
			i++;
		}

		scroll.view.height += i * 42 - 6;
		scroll.onResize();

		visible = true;
	}


	override function onResize() {
		var h = parent.y + this.y + scroll.y + 20;

		if (h > Editor.ME.HEIGHT) return;
		scroll.height = Std.int(Editor.ME.HEIGHT - h);
		scroll.onResize();
	}


	override public function unselect() {
		super.unselect();
		
		for (input in text) {
			input.visible = false;
			input.blur();
		}
		for (input in bitmap) {
			input.visible = false;
		}
		prefab = null;
	}


	override function onUpdate(prop:Dynamic) {
		prefab.setText(prop.field, prop.to);
	}
	

	override function onChange(prop:Dynamic) {
	}


	function onFile(prop:Dynamic) {
		function onSelect(name:String) {
			Editor.ME.texture.onSelect = null;

			prefab.setBitmap(prop.field, name);

			for (input in bitmap) {
				if (input.field == prop.field) input.value = name;
			}
		}

		// get bitmap texture atlas name
		var atlas = prefab.field.get(prop.field).data;

		Editor.ME.texture.onSelect = onSelect;
		Editor.ME.texture.open(atlas);
	}


	override public function onFocus(o:h2d.Object) {
		over(o);
	}
}