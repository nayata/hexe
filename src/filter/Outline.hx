package filter;

import property.component.Label;
import property.component.Checkbox;
import property.component.Number;
import property.component.FloatNumber;
import property.component.Slider;
import property.component.Color;

import filter.Filter;


class Outline extends Effect {
	var effect:h2d.filter.Filter;

	var size:Float = 4.0;
	var color:Int = 0x000000;
	var quality:Float = 0.3;
	var multiplyAlpha:Bool = true;


	public function new(?parent:h2d.Object) {
		super(parent);

		// Color
		var label = new Label("Color", 40, 40 + 14, content);

		var input = new Color(content);
		input.setPosition(130, 40);
		input.onChange = onChange;
		input.setSize(166, 32);

		registry.set("color", input);
		input.field = "color";
		input.value = "000000";


		// Size
		label = new Label("Size", 40, 80 + 14, content);

		var input = new Slider(content);
		input.setPosition(232, 80);
		input.onUpdate = onChange;

		input.setSliderRange(0, 30);
		
		input.minimum = 0;
		input.maximum = 30;
		input.step = 1;

		registry.set("size", input);
		input.field = "size";


		// Quality
		label = new Label("Quality", 40, 120 + 14, content);

		var input = new FloatNumber(content);
		input.setPosition(130, 120);
		input.onUpdate = onChange;
		input.onChange = onChange;

		input.minimum = 0;
		input.maximum = 1;
		input.step = 0.1;
		
		registry.set("quality", input);
		input.field = "quality";
		input.value = "0.3";


		// multiplyAlpha
		label = new Label("Alpha", 40, 170 + 7, content);

		var input = new Checkbox(content);
		input.setPosition(130, 170);
		input.onChange = onChange;

		registry.set("multiplyAlpha", input);
		input.field = "multiplyAlpha";
		input.value = "true";


		window.title = "Outline";
		window.visible = false;
		window.width = 356;
		window.height = 238;
	}


	override public function init(entry:prefab.Prefab) {
		prefab = entry;

		if (prefab.object.filter == null) {
			prefab.filter = new Filter(prefab);

			effect = new h2d.filter.Outline();

			prefab.filter.data.set("Outline", { size : 4.0, color : 0x000000, quality : 0.3, multiplyAlpha : true });
			prefab.filter.add(effect);
		}
		else {
			effect = prefab.filter.get(h2d.filter.Outline);

			if (effect == null) {
				effect = new h2d.filter.Outline();

				prefab.filter.data.set("Outline", { size : 4.0, color : 0x000000, quality : 0.3, multiplyAlpha : true });
				prefab.filter.add(effect);
			}
		}

		for (field => item in registry) {
			var value = Reflect.field(prefab.filter.data["Outline"], field);

			Reflect.setProperty(this, field, value);
			item.value = Std.string(value);
		}

		var prop = prefab.filter.data["Outline"];
		registry.get("color").value = StringTools.hex(prop.color, 6);
	}


	function onChange(prop:Dynamic) {
		if (prefab.object.filter == null) return;

		if (prop.field == "color") prop.to = Editor.ME.getColor(prop.to);

		Reflect.setProperty(effect, prop.field, prop.to);
		Reflect.setProperty(prefab.filter.data["Outline"], prop.field, prop.to);
	}
}