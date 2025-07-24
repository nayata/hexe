package property;

import property.component.Label;
import property.component.Input;

import property.component.Number;
import property.component.FloatNumber;
import property.component.BlendMode;
import property.component.Slider;
import property.component.Angle;


class Transform extends Property {
	public function new(?parent:h2d.Object) {
		super(parent);


		// Position
		var label = new Label("Position", 0, 16, this);

		var input:Input = new Number(this);
		input.setPosition(74, 0);
		input.onUpdate = onUpdate;
		input.onChange = onTransform;
		input.field = "x";
		input.label = "X";

		registry.set(input.field, input);


		input = new Number(this);
		input.setPosition(160, 0);
		input.onUpdate = onUpdate;
		input.onChange = onTransform;
		input.field = "y";
		input.label = "Y";

		registry.set(input.field, input);


		// Scaling
		label = new Label("Scale", 0, 54, this);

		input = new FloatNumber(this);
		input.setPosition(74, 38);
		input.onUpdate = onUpdate;
		input.onChange = onTransform;
		input.field = "scaleX";
		input.label = "X";

		registry.set(input.field, input);


		input = new FloatNumber(this);
		input.setPosition(160, 38);
		input.onUpdate = onUpdate;
		input.onChange = onTransform;
		input.field = "scaleY";
		input.label = "Y";

		registry.set(input.field, input);


		// Rotation
		label = new Label("Rotation", 0, 92, this);

		input = new Angle(this);
		input.setPosition(74, 76);
		input.onUpdate = onUpdate;
		input.onChange = onTransform;
		input.field = "rotation";
		input.icon = "angle";

		registry.set(input.field, input);


		// BlendMode
		label = new Label("BlendMode", 0, 148, this);

		var choice = new BlendMode(this);
		choice.setPosition(74, 128);
		choice.add(haxe.EnumTools.createAll(h2d.BlendMode));
		choice.onFocus = function(o:h2d.Object) { onFocus(this); };
		choice.onChange = onChange;
		choice.field = "blendMode";
		choice.icon = "menu";
		choice.setSize(166, 40);


		registry.set(choice.field, choice);


		// Alpha
		label = new Label("Opacity", 0, 190, this);

		input = new Slider(this);
		input.setPosition(176, 174);
		input.onUpdate = onUpdate;
		input.onChange = onTransform;
		
		input.minimum = 0;
		input.maximum = 1;

		input.field = "alpha";
		input.label = "%";

		registry.set(input.field, input);


		// Dropdown over all
		over(choice);
	}


	function onTransform(prop:Dynamic) {
		if (object == null) return;
		if (prop.from == prop.to) return;

		Reflect.setProperty(object, prop.field, prop.to);
		Editor.ME.onProperty();

		var element = new History.Property(object, prop.field, prop.from, prop.to);

		Editor.ME.motion.onProperty(element, object, prop.field, prop.from, prop.to);
		Editor.ME.history.add(element);
	}
}