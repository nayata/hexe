package filter;

import property.component.Label;
import property.component.Checkbox;
import property.component.Number;
import property.component.FloatNumber;
import property.component.Slider;
import property.component.Color;

import filter.Filter;


class DropShadow extends Effect {
	var effect:h2d.filter.Filter;

	var distance:Float = 4.0;
	var angle:Float = 0.785;

	var color:Int = 0x000000;
	var alpha:Float = 1.0;

	var radius:Float = 1.0;
	var gain:Float = 1.0;
	var quality:Float = 1.0;

	var smoothColor:Bool = false;


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


		// Distance
		label = new Label("Distance", 40, 80 + 14, content);

		var input = new Slider(content);
		input.setPosition(232, 80);
		input.onUpdate = onChange;

		input.setSliderRange(0, 30);
		
		input.minimum = 0;
		input.maximum = 30;
		input.step = 1;

		registry.set("distance", input);
		input.field = "distance";


		// Angle
		label = new Label("Angle", 40, 120 + 14, content);

		var input = new Slider(content);
		input.setPosition(232, 120);
		input.onUpdate = onChange;

		input.setSliderRange(0, 360);
		
		input.minimum = 0;
		input.maximum = 360;
		input.step = 1;

		registry.set("angle", input);
		input.field = "angle";


		// Radius
		label = new Label("Radius", 40, 160 + 14, content);

		var input = new Slider(content);
		input.setPosition(232, 160);
		input.onUpdate = onChange;

		input.setSliderRange(0, 250);
		
		input.minimum = 0;
		input.maximum = 250;
		input.step = 1;

		registry.set("radius", input);
		input.field = "radius";


		// Alpha
		label = new Label("Alpha", 40, 200 + 14, content);

		var input = new Slider(content);
		input.setPosition(232, 200);
		input.onUpdate = onChange;

		input.setSliderRange(0, 1);
		
		input.minimum = 0;
		input.maximum = 1;
		input.step = 0.05;

		registry.set("alpha", input);
		input.field = "alpha";


		// Quality
		label = new Label("Quality", 40, 240 + 14, content);

		var input = new FloatNumber(content);
		input.setPosition(130, 240);
		input.onUpdate = onChange;
		input.onChange = onChange;

		input.minimum = 0;
		input.maximum = 1;
		input.step = 0.1;
		
		registry.set("quality", input);
		input.field = "quality";


		// Smooth Color
		label = new Label("Smooth", 40, 290 + 7, content);

		var input = new Checkbox(content);
		input.setPosition(130, 290);
		input.onChange = onChange;

		registry.set("smoothColor", input);
		input.field = "smoothColor";


		window.title = "DropShadow";
		window.visible = false;
		window.width = 356;
		window.height = 358;
	}


	override public function init(entry:prefab.Prefab) {
		prefab = entry;

		if (prefab.object.filter == null) {
			prefab.filter = new Filter(prefab);

			effect = new h2d.filter.DropShadow();

			prefab.filter.data.set("DropShadow", { distance : 4.0, angle : 0.785, color : 0x000000, alpha : 1.0, radius : 1.0, gain : 1.0, quality : 1.0, smoothColor : false });
			prefab.filter.add(effect);
		}
		else {
			effect = prefab.filter.get(h2d.filter.DropShadow);

			if (effect == null) {
				effect = new h2d.filter.DropShadow();

				prefab.filter.data.set("DropShadow", { distance : 4.0, angle : 0.785, color : 0x000000, alpha : 1.0, radius : 1.0, gain : 1.0, quality : 1.0, smoothColor : false });
				prefab.filter.add(effect);
			}
		}

		for (field => item in registry) {
			var value = Reflect.field(prefab.filter.data["DropShadow"], field);

			Reflect.setProperty(this, field, value);
			item.value = Std.string(value);
		}

		var prop = prefab.filter.data["DropShadow"];
		registry.get("color").value = StringTools.hex(prop.color, 6);
		registry.get("angle").value = Std.string(snap(prop.angle * 180 / Math.PI));
	}


	function onChange(prop:Dynamic) {
		if (prefab.object.filter == null) return;

		if (prop.field == "color") prop.to = Editor.ME.getColor(prop.to);
		if (prop.field == "angle") prop.to = prop.to * Math.PI / 180;

		Reflect.setProperty(effect, prop.field, prop.to);
		Reflect.setProperty(prefab.filter.data["DropShadow"], prop.field, prop.to);
	}


	inline function snap(value:Float, step:Float = 1) {
		return Math.round(value / step) * step;
	}
}