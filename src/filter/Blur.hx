package filter;

import property.component.Label;
import property.component.Slider;


class Blur extends Effect {
	var effect:h2d.filter.Filter;

	var radius:Float = 1.0;
	var linear:Float = 0.0;
	var gain:Float = 1.0;
	var quality:Float = 1.0;
	

	public function new(?parent:h2d.Object) {
		super(parent);

		// Radius
		var label = new Label("Radius", 40, 40 + 14, content);

		var input = new Slider(content);
		input.setPosition(340, 40);
		input.onUpdate = onUpdate;

		input.setSliderRange(0, 40);
		input.setSliderSize(200, 32);
		
		input.minimum = 0;
		input.maximum = 40;
		input.step = 1;

		registry.set("radius", input);
		input.field = "radius";


		// Linear
		label = new Label("Linear", 40, 80 + 14, content);

		input = new Slider(content);
		input.setPosition(340, 80);
		input.onUpdate = onUpdate;

		input.setSliderRange(0, 1);
		input.setSliderSize(200, 32);
		
		input.minimum = 0;
		input.maximum = 1;
		input.step = 0.1;

		registry.set("linear", input);
		input.field = "linear";


		// Gain
		label = new Label("Gain", 40, 120 + 14, content);

		input = new Slider(content);
		input.setPosition(340, 120);
		input.onUpdate = onUpdate;

		input.setSliderRange(0, 2);
		input.setSliderSize(200, 32);
		
		input.minimum = 0;
		input.maximum = 2;
		input.step = 0.01;
		
		registry.set("gain", input);
		input.field = "gain";


		// Quality
		label = new Label("Quality", 40, 160 + 14, content);

		input = new Slider(content);
		input.setPosition(340, 160);
		input.onUpdate = onUpdate;

		input.setSliderRange(0, 1);
		input.setSliderSize(200, 32);
		
		input.minimum = 0;
		input.maximum = 1;
		input.step = 0.1;
		
		registry.set("quality", input);
		input.field = "quality";


		window.title = "Blur";
		window.visible = false;
		window.width = 440;
		window.height = 238;
	}


	override public function init(entry:prefab.Prefab) {
		prefab = entry;

		if (prefab.object.filter == null) {
			prefab.filter = new Filter(prefab);

			effect = new h2d.filter.Blur();

			prefab.filter.data.set("Blur", { radius : 1.0, gain : 1.0, quality : 1.0, linear : 0.0 });
			prefab.filter.add(effect);
		}
		else {
			effect = prefab.filter.get(h2d.filter.Blur);

			if (effect == null) {
				effect = new h2d.filter.Blur();

				prefab.filter.data.set("Blur", { radius : 1.0, gain : 1.0, quality : 1.0, linear : 0.0 });
				prefab.filter.add(effect);
			}
		}

		for (field => item in registry) {
			var value = Reflect.field(prefab.filter.data["Blur"], field);

			Reflect.setProperty(this, field, value);
			item.value = Std.string(value);
		}
	}


	function onUpdate(prop:Dynamic) {
		if (prefab.object.filter == null) return;

		Reflect.setProperty(effect, prop.field, prop.to);
		Reflect.setProperty(prefab.filter.data["Blur"], prop.field, prop.to);
	}
}