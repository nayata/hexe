package property;

import property.component.Label;
import property.component.Input;
import property.component.Number;


class Mask extends Property {
	public function new(?parent:h2d.Object) {
		super(parent);

		var label = new Label("Size", 0, half, this);

		var input = set("width", new Number(this));
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
}