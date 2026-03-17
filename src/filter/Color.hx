package filter;

import property.component.Label;
import property.component.Slider;


class Color extends Effect {
	var saturation = 0.0;
	var lightness = 0.0;
	var hue = 0.0;
	var contrast = 0.0;


	public function new(?parent:h2d.Object) {
		super(parent);

		// Hue
		var label = new Label("Hue", 40, 40 + 14, content);

		var input = new Slider(content);
		input.setPosition(340, 40);
		input.onUpdate = onChange;

		input.setSliderRange(-180, 180);
		input.setSliderSize(200, 32);
		
		input.minimum = -100;
		input.maximum = 100;
		input.step = 1;

		registry.set("hue", input);
		input.field = "hue";


		// Saturation
		label = new Label("Saturation", 40, 80 + 14, content);

		input = new Slider(content);
		input.setPosition(340, 80);
		input.onUpdate = onChange;

		input.setSliderRange(-100, 100);
		input.setSliderSize(200, 32);
		
		input.minimum = -100;
		input.maximum = 100;
		input.step = 1;

		registry.set("saturation", input);
		input.field = "saturation";


		// Brightness
		label = new Label("Brightness", 40, 120 + 14, content);

		input = new Slider(content);
		input.setPosition(340, 120);
		input.onUpdate = onChange;

		input.setSliderRange(-100, 100);
		input.setSliderSize(200, 32);
		
		input.minimum = -100;
		input.maximum = 100;
		input.step = 1;

		registry.set("lightness", input);
		input.field = "lightness";


		// Contrast
		label = new Label("Contrast", 40, 160 + 14, content);

		input = new Slider(content);
		input.setPosition(340, 160);
		input.onUpdate = onChange;

		input.setSliderRange(-100, 100);
		input.setSliderSize(200, 32);
		
		input.minimum = -100;
		input.maximum = 100;
		input.step = 1;

		registry.set("contrast", input);
		input.field = "contrast";


		window.title = "Adjust Color";
		window.visible = false;
		window.width = 440;
		window.height = 238;
	}


	override public function allowed(entry:prefab.Prefab):Bool {
		if (entry.type == "anim" || entry.type == "bitmap" || entry.type == "scalegrid") return true;
		return false;
	}
	

	override public function init(entry:prefab.Prefab) {
		prefab = entry;

		if (prefab.matrix == null) prefab.matrix = new filter.Matrix(prefab);

		for (field => item in registry) {
			var value = Reflect.field(prefab.matrix.data, field);

			Reflect.setProperty(this, field, value);
			item.value = Std.string(value);
		}
	}


	function onChange(prop:Dynamic) {
		if (prefab == null) return;

		Reflect.setProperty(this, prop.field, prop.to);
		Reflect.setProperty(prefab.matrix.data, prop.field, prop.to);

		prefab.matrix.apply();
	}
}