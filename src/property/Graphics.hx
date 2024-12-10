package property;

import property.component.Label;
import property.component.Input;
import property.component.Number;
import property.component.Color;


class Graphics extends Property {
	public function new(?parent:h2d.Object) {
		super(parent);

		// Graphics color
		var label = new Label("Color", 0, half, this);

		var input = set("color", new Color(this));
		input.setPosition(second, top);
		input.onChange = onChange;
		input.onFocus = onFocused;
		input.setSize(166, 32);

		top += input.height + padding;


		// Graphics size
		label = new Label("Size", 0, top + half, this);

		input = set("width", new Number(this));
		input.setPosition(second, top);
		input.onUpdate = onUpdate;
		input.onChange = onChange;
		input.minimum = 0;
		input.label = "W";

		input = set("height", new Number(this));
		input.setPosition(third, top);
		input.onUpdate = onUpdate;
		input.onChange = onChange;
		input.minimum = 0;
		input.label = "H";
	}


	function onFocused(o:h2d.Object) {
		onFocus(this);
	}
}