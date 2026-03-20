package effect;

import property.component.Label;
import property.component.Slider;


class ColorMatrix extends Effect {
	var effect:h2d.filter.Filter;


	public function new(?parent:h2d.Object) {
		super(parent);

		name = "ColorMatrix";

		// Hue
		var label = new Label("Hue", 0, 14, this);

		var input = new Slider(this);
		input.setPosition(230, 0);
		input.setSize(60, 32);

		input.setSliderSize(130, 32);
		input.setSliderRange(-100, 100);
		
		input.minimum = -100;
		input.maximum = 100;
		input.step = 1;

		input.onUpdate = onChange;

		registry.set("hue", input);
		input.field = "hue";


		// Saturation
		label = new Label("Saturation", 0, 40 + 14, this);

		input = new Slider(this);
		input.setPosition(230, 40);
		input.setSize(60, 32);

		input.setSliderSize(130, 32);
		input.setSliderRange(-100, 100);
		
		input.minimum = -100;
		input.maximum = 100;
		input.step = 1;

		input.onUpdate = onChange;

		registry.set("saturation", input);
		input.field = "saturation";


		// Brightness
		label = new Label("Brightness", 0, 80 + 14, this);

		input = new Slider(this);
		input.setPosition(230, 80);
		input.setSize(60, 32);

		input.setSliderSize(130, 32);
		input.setSliderRange(-100, 100);
		
		input.minimum = -100;
		input.maximum = 100;
		input.step = 1;

		input.onUpdate = onChange;
		
		registry.set("lightness", input);
		input.field = "lightness";


		// Contrast
		label = new Label("Contrast", 0, 120 + 14, this);

		input = new Slider(this);
		input.setPosition(230, 120);
		input.setSize(60, 32);

		input.setSliderSize(130, 32);
		input.setSliderRange(-100, 100);
		
		input.minimum = -100;
		input.maximum = 100;
		input.step = 1;

		input.onUpdate = onChange;
		
		registry.set("contrast", input);
		input.field = "contrast";
	}


	override public function init(entry:prefab.Prefab) {
		prefab = entry;

		effect = prefab.filter.get(name);

		if (effect == null) {
			effect = new h2d.filter.ColorMatrix();

			prefab.filter.data.set(name, { saturation : 0.0, lightness : 0.0, hue : 0.0, contrast : 0.0 });
			prefab.filter.add(name, effect);
		}

		for (field => item in registry) {
			var value:Float = Reflect.field(prefab.filter.data[name], field);

			value = field == "hue" ? value * 180 / Math.PI : value * 100;
			item.value = Std.string(snap(value));
		}
	}


	function onChange(prop:Dynamic) {
		if (prefab.object.filter == null) return;

		var value:Float = prop.field == "hue" ? prop.to * Math.PI / 180 : prop.to / 100;
		Reflect.setProperty(prefab.filter.data[name], prop.field, value);

		var colorMatrix = (cast effect : h2d.filter.ColorMatrix);

		colorMatrix.matrix.identity();
		colorMatrix.matrix.adjustColor(prefab.filter.data[name]);
	}


	inline function snap(value:Float, step:Float = 1) {
		return Math.round(value / step) * step;
	}
}