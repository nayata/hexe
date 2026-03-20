package effect;

import property.component.Label;
import property.component.Slider;


class Blur extends Effect {
	var effect:h2d.filter.Filter;


	public function new(?parent:h2d.Object) {
		super(parent);

		name = "Blur";

		// Radius
		var label = new Label("Radius", 0, 14, this);

		var input = new Slider(this);
		input.setPosition(230, 0);
		input.setSize(60, 32);

		input.setSliderSize(130, 32);
		input.setSliderRange(0, 50);
		
		input.minimum = 0;
		input.maximum = 50;
		input.step = 1;

		input.onUpdate = onChange;

		registry.set("radius", input);
		input.field = "radius";


		// Linear
		label = new Label("Linear", 0, 40 + 14, this);

		input = new Slider(this);
		input.setPosition(230, 40);
		input.setSize(60, 32);

		input.setSliderSize(130, 32);
		input.setSliderRange(0, 1);
		
		input.minimum = 0;
		input.maximum = 1;
		input.step = 0.1;

		input.onUpdate = onChange;

		registry.set("linear", input);
		input.field = "linear";


		// Gain
		label = new Label("Gain", 0, 80 + 14, this);

		input = new Slider(this);
		input.setPosition(230, 80);
		input.setSize(60, 32);

		input.setSliderSize(130, 32);
		input.setSliderRange(0, 2);
		
		input.minimum = 0;
		input.maximum = 2;
		input.step = 0.01;

		input.onUpdate = onChange;
		
		registry.set("gain", input);
		input.field = "gain";


		// Quality
		label = new Label("Quality", 0, 120 + 14, this);

		input = new Slider(this);
		input.setPosition(230, 120);
		input.setSize(60, 32);

		input.setSliderSize(130, 32);
		input.setSliderRange(0, 1);
		
		input.minimum = 0;
		input.maximum = 1;
		input.step = 0.1;

		input.onUpdate = onChange;
		
		registry.set("quality", input);
		input.field = "quality";
	}


	override public function init(entry:prefab.Prefab) {
		prefab = entry;

		effect = prefab.filter.get(name);

		if (effect == null) {
			effect = new h2d.filter.Blur();

			prefab.filter.data.set(name, { radius : 1.0, gain : 1.0, quality : 1.0, linear : 0.0 });
			prefab.filter.add(name, effect);
		}

		for (field => item in registry) {
			var value = Reflect.field(prefab.filter.data[name], field);
			item.value = Std.string(value);
		}
	}


	function onChange(prop:Dynamic) {
		if (prefab.object.filter == null) return;

		Reflect.setProperty(effect, prop.field, prop.to);
		Reflect.setProperty(prefab.filter.data[name], prop.field, prop.to);
	}
}