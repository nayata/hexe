package property.component;


class BlendMode extends Select {
	var from:h2d.BlendMode = Alpha;


	override function onClick(event:hxd.Event) {
		if (!panel.visible) {
			open();
			return;
		}

		if (selected != null) {
			onChange({ field : field, from : from, to : selected.value });

			text.text = Std.string(selected.value);
			close();
		}
	}


	override function set_value(v) {
		from = haxe.EnumTools.createByName(h2d.BlendMode, v);
		text.text = v;
		return v;
	}
}