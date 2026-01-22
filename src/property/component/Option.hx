package property.component;

class Option extends Select {
	var last:Int = 0;


	override public function add(value:Array<Dynamic>) {
		panel.removeChildren();
		items = [];

		var index = 0;

		for (entry in value) {
			var item = new Element(panel);

			item.value = index++;
			item.label = Std.string(entry);

			item.x = 20;
			item.y = 2 + items.length * size;

			item.width = width;
			item.height = size;

			item.alpha = 0.75;

			var label = new h2d.Text(Assets.defaultFont, item);
			label.textColor = Style.input;
			label.textAlign = h2d.Text.Align.Left;
			label.smooth = true;
			label.text = entry;
	
			items.push(item);
		}
	}


	override function onClick(event:hxd.Event) {
		if (!panel.visible) {
			open();
			return;
		}

		if (selected != null) {
			onChange({ field : field, from : last, to : selected.value });

			text.text = items[selected.value].label;
			close();
		}
	}


	override function set_value(v) {
		last = Std.parseInt(v);
		text.text = items[last].label;
		return v;
	}
}