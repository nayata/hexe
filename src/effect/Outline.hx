package effect;

import property.component.Label;
import property.component.Checkbox;
import property.component.Number;
import property.component.FloatNumber;
import property.component.Slider;
import property.component.Color;


class Outline extends Effect {
	var effect:h2d.filter.Filter;


	public function new(?parent:h2d.Object) {
		super(parent);

		name = "Outline";

		// Color
		var label = new Label("Color", 0, 0 + 14, this);

		var input = new Color(this);
		input.setPosition(90, 0);
		input.setSize(130, 32);

		input.onChange = onChange;

		registry.set("color", input);
		input.field = "color";


		// Size
		label = new Label("Size", 0, 40 + 14, this);

		var input = new Slider(this);
		input.setPosition(230, 40);
		input.setSize(60, 32);

		input.setSliderSize(130, 32);
		input.setSliderRange(0, 30);
		
		input.minimum = 0;
		input.maximum = 30;
		input.step = 1;

		input.onUpdate = onChange;

		registry.set("size", input);
		input.field = "size";


		// Quality
		label = new Label("Quality", 0, 80 + 14, this);

		var input = new FloatNumber(this);
		input.setPosition(90, 80);
		input.setSize(60, 32);

		input.onUpdate = onChange;
		input.onChange = onChange;

		input.minimum = 0;
		input.maximum = 1;
		input.step = 0.1;
		
		registry.set("quality", input);
		input.field = "quality";


		// Multiply Alpha
		label = new Label("Alpha", 0, 130 + 7, this);

		var input = new Checkbox(this);
		input.setPosition(90, 130);
		
		input.onChange = onChange;

		registry.set("multiplyAlpha", input);
		input.field = "multiplyAlpha";
	}


	override public function init(entry:prefab.Prefab) {
		prefab = entry;

		effect = prefab.filter.get(name);

		if (effect == null) {
			effect = new h2d.filter.Outline();

			prefab.filter.data.set(name, { size : 4.0, color : 0x000000, quality : 0.3, multiplyAlpha : true });
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