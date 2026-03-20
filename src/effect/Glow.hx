package effect;

import property.component.Label;
import property.component.Checkbox;
import property.component.Number;
import property.component.FloatNumber;
import property.component.Slider;
import property.component.Color;


class Glow extends Effect {
	var effect:h2d.filter.Filter;


	public function new(?parent:h2d.Object) {
		super(parent);

		name = "Glow";

		// Color
		var label = new Label("Color", 0, 14, this);

		var input = new Color(this);
		input.setPosition(90, 0);
		input.setSize(130, 32);

		input.onChange = onChange;

		registry.set("color", input);
		input.field = "color";


		// Radius
		label = new Label("Radius", 0, 40 + 14, this);

		var input = new Slider(this);
		input.setPosition(230, 40);
		input.setSize(60, 32);

		input.setSliderSize(130, 32);
		input.setSliderRange(0, 250);
		
		input.minimum = 0;
		input.maximum = 250;
		input.step = 1;

		input.onUpdate = onChange;

		registry.set("radius", input);
		input.field = "radius";


		// Alpha
		label = new Label("Alpha", 0, 80 + 14, this);

		var input = new Slider(this);
		input.setPosition(230, 80);
		input.setSize(60, 32);

		input.setSliderSize(130, 32);
		input.setSliderRange(0, 1);
		
		input.minimum = 0;
		input.maximum = 1;
		input.step = 0.05;

		input.onUpdate = onChange;

		registry.set("alpha", input);
		input.field = "alpha";


		// Quality
		label = new Label("Quality", 0, 120 + 14, this);

		var input = new FloatNumber(this);
		input.setPosition(90, 120);
		input.setSize(60, 32);

		input.minimum = 0;
		input.maximum = 1;
		input.step = 0.1;

		input.onUpdate = onChange;
		input.onChange = onChange;
		
		registry.set("quality", input);
		input.field = "quality";


		// Smooth Color
		label = new Label("Smooth", 0, 170 + 7, this);

		var input = new Checkbox(this);
		input.setPosition(90, 170);
		
		input.onChange = onChange;

		registry.set("smoothColor", input);
		input.field = "smoothColor";
	}


	override public function init(entry:prefab.Prefab) {
		prefab = entry;

		effect = prefab.filter.get(name);

		if (effect == null) {
			effect = new h2d.filter.Glow(0xFFFFFF, 1.0, 1.0, 1.0, 1.0, true);

			prefab.filter.data.set(name, { color : 0xFFFFFF, alpha : 1.0, radius : 1.0,  quality : 1.0, smoothColor : true });
			prefab.filter.add(name, effect);
		}

		for (field => item in registry) {
			var value = Reflect.field(prefab.filter.data[name], field);
			item.value = Std.string(value);
		}

		var prop = prefab.filter.data[name];
		registry.get("color").value = StringTools.hex(prop.color, 6);
	}


	function onChange(prop:Dynamic) {
		if (prefab.object.filter == null) return;

		if (prop.field == "color") prop.to = Editor.ME.getColor(prop.to);

		Reflect.setProperty(effect, prop.field, prop.to);
		Reflect.setProperty(prefab.filter.data[name], prop.field, prop.to);
	}
}