package property.component;


class Font extends Select {
	override function onClick(event:hxd.Event) {
		if (items.length < 3) {
			openFont();
			return;
		}

		if (!panel.visible) {
			open();
			return;
		}

		if (selected != null) {
			if (selected.value == "Load") {
				openFont();
				return;
			}

			onChange({ field : field, from : undo, to : selected.value });
			text.text = Std.string(selected.value);
			close();
		}
	}

	function openFont() {
		var font = Editor.ME.file.openFont();

		if (font != null) {
			onChange({ field : field, from : undo, to : font });
			text.text = Std.string(font);
		}
		close();
	}
}