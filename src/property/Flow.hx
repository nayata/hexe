package property;

import property.component.Label;
import property.component.Input;
import property.component.TextArea;
import property.component.Number;
import property.component.Checkbox;
import property.component.Anchor;
import property.component.Option;
import property.component.Swatch;


class Flow extends Property {
	public function new(?parent:h2d.Object) {
		super(parent);


		// Size
		var label = new Label("Layout", 0, tall * 0.5, this);

		// scaleMode
		var input = new Option(this);
		input.setPosition(second, 0);
		input.setSize(166, 40);
		input.icon = "shape";

		input.add(["Horizontal", "Vertical", "Stack"]);

		input.onFocus = onFocus;
		input.onChange = onChange;

		registry.set("layout", input);
		input.field = "layout";

		top += input.height + divider;


		// Padding
		label = new Label("Spacing", 0, top + half, this);

		var input = new Number(this);
		input.setPosition(second, top);
		input.onUpdate = onUpdate;
		input.onChange = onChange;
		input.minimum = 0;
		input.label = "H";

		registry.set("horizontalSpacing", input);
		input.field = "horizontalSpacing";


		input = new Number(this);
		input.setPosition(third, top);
		input.onUpdate = onUpdate;
		input.onChange = onChange;
		input.minimum = 0;
		input.label = "V";

		registry.set("verticalSpacing", input);
		input.field = "verticalSpacing";

		top += input.height + padding;


		label = new Label("Padding", 0, top + half, this);

		input = new Number(this);
		input.setPosition(second, top);
		input.onUpdate = onUpdate;
		input.onChange = onChange;
		input.minimum = 0;

		registry.set("padding", input);
		input.field = "padding";
	}


	override public function onFocus(o:h2d.Object) {
		over(o);
	}
}