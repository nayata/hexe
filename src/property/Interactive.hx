package property;

import property.component.Label;
import property.component.Input;
import property.component.Number;
import property.component.Checkbox;
import property.component.Color;


class Interactive extends Property {
	public function new(?parent:h2d.Object) {
		super(parent);

		var label = new Label("Size", 0, half, this);

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

		top += input.height + divider;

		// isEllipse
		label = new Label("isEllipse", 0, top + half * 0.5, this);

		input = set("smooth", new Checkbox(this));
		input.setPosition(second, top);
		input.onChange = onChange;
	}
}