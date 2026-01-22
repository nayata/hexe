package property;

import property.component.Label;
import property.component.Input;
import property.component.Checkbox;


class Object extends Property {
	public function new(?parent:h2d.Object) {
		super(parent);

		var label = new Label("Marker", 0, half * 0.5, this);

		var input = set("mode", new Checkbox(this));
		input.setPosition(second, top);
		input.onChange = onChange;
	}
}