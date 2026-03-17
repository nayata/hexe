package filter;

import property.component.Label;
import property.component.Checkbox;
import property.component.Number;
import property.component.FloatNumber;
import property.component.Slider;
import property.component.Color;

import filter.Filter;


class Glow extends Effect {
	var effect:h2d.filter.Filter;

	var radius:Float = 1.0;
	var color:Int = 0xFFFFFF;
	var alpha:Float = 1.0;
	var quality:Float = 1.0;
	var smoothColor:Bool = true;


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


		// Radius
		label = new Label("Radius", 40, 80 + 14, content);

		var input = new Slider(content);
		input.setPosition(232, 80);
		input.onUpdate = onChange;

		input.setSliderRange(0, 250);
		
		input.minimum = 0;
		input.maximum = 250;
		input.step = 1;

		registry.set("radius", input);
		input.field = "radius";


		// Alpha
		label = new Label("Alpha", 40, 120 + 14, content);

		var input = new Slider(content);
		input.setPosition(232, 120);
		input.onUpdate = onChange;

		input.setSliderRange(0, 1);
		
		input.minimum = 0;
		input.maximum = 1;
		input.step = 0.05;

		registry.set("alpha", input);
		input.field = "alpha";


		// Quality
		label = new Label("Quality", 40, 160 + 14, content);

		var input = new FloatNumber(content);
		input.setPosition(130, 160);
		input.onUpdate = onChange;
		input.onChange = onChange;

		input.minimum = 0;
		input.maximum = 1;
		input.step = 0.1;
		
		registry.set("quality", input);
		input.field = "quality";


		// Smooth Color
		label = new Label("Smooth", 40, 210 + 7, content);

		var input = new Checkbox(content);
		input.setPosition(130, 210);
		input.onChange = onChange;

		registry.set("smoothColor", input);
		input.field = "smoothColor";


		window.title = "Glow";
		window.visible = false;
		window.width = 356;
		window.height = 278;
	}


	override public function init(entry:prefab.Prefab) {
		prefab = entry;

		if (prefab.object.filter == null) {
			prefab.filter = new Filter(prefab);

			effect = new h2d.filter.Glow(0xFFFFFF, 1.0, 1.0, 1.0, 1.0, true);

			prefab.filter.data.set("Glow", { color : 0xFFFFFF, alpha : 1.0, radius : 1.0,  quality : 1.0, smoothColor : true });
			prefab.filter.add(effect);
		}
		else {
			effect = prefab.filter.get(h2d.filter.Glow);

			if (effect == null) {
				effect = new h2d.filter.Glow(0xFFFFFF, 1.0, 1.0, 1.0, 1.0, true);

				prefab.filter.data.set("Glow", { color : 0xFFFFFF, alpha : 1.0, radius : 1.0,  quality : 1.0, smoothColor : true });
				prefab.filter.add(effect);
			}
		}

		for (field => item in registry) {
			var value = Reflect.field(prefab.filter.data["Glow"], field);

			Reflect.setProperty(this, field, value);
			item.value = Std.string(value);
		}

		var prop = prefab.filter.data["Glow"];
		registry.get("color").value = StringTools.hex(prop.color, 6);
	}


	function onChange(prop:Dynamic) {
		if (prefab.object.filter == null) return;

		if (prop.field == "color") prop.to = Editor.ME.getColor(prop.to);

		Reflect.setProperty(effect, prop.field, prop.to);
		Reflect.setProperty(prefab.filter.data["Glow"], prop.field, prop.to);
	}
}