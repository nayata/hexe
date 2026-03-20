package effect;

import property.component.Label;
import property.component.Checkbox;
import property.component.Number;
import property.component.FloatNumber;
import property.component.Slider;
import property.component.Color;


class DropShadow extends Effect {
	var effect:h2d.filter.Filter;

	
	public function new(?parent:h2d.Object) {
		super(parent);

		name = "DropShadow";

		// Color
		var label = new Label("Color", 0, 14, this);

		var input = new Color(this);
		input.setPosition(90, 0);
		input.setSize(130, 32);

		input.onChange = onChange;

		registry.set("color", input);
		input.field = "color";


		// Distance
		label = new Label("Distance", 0, 40 + 14, this);

		var input = new Slider(this);
		input.setPosition(230, 40);
		input.setSize(60, 32);

		input.setSliderSize(130, 32);
		input.setSliderRange(0, 30);
		
		input.minimum = 0;
		input.maximum = 30;
		input.step = 1;

		input.onUpdate = onChange;

		registry.set("distance", input);
		input.field = "distance";


		// Angle
		label = new Label("Angle", 0, 80 + 14, this);

		var input = new Slider(this);
		input.setPosition(230, 80);
		input.setSize(60, 32);

		input.setSliderSize(130, 32);
		input.setSliderRange(0, 360);
		
		input.minimum = 0;
		input.maximum = 360;
		input.step = 1;

		input.onUpdate = onChange;

		registry.set("angle", input);
		input.field = "angle";


		// Radius
		label = new Label("Radius", 0, 120 + 14, this);

		var input = new Slider(this);
		input.setPosition(230, 120);
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
		label = new Label("Alpha", 0, 160 + 14, this);

		var input = new Slider(this);
		input.setPosition(230, 160);
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
		label = new Label("Quality", 0, 200 + 14, this);

		var input = new FloatNumber(this);
		input.setPosition(90, 200);
		input.setSize(60, 32);

		input.onUpdate = onChange;
		input.onChange = onChange;

		input.minimum = 0;
		input.maximum = 1;
		input.step = 0.1;
		
		registry.set("quality", input);
		input.field = "quality";


		// Smooth Color
		label = new Label("Smooth", 0, 250 + 7, this);

		var input = new Checkbox(this);
		input.setPosition(90, 250);

		input.onChange = onChange;

		registry.set("smoothColor", input);
		input.field = "smoothColor";
	}


	override public function init(entry:prefab.Prefab) {
		prefab = entry;

		effect = prefab.filter.get(name);

		if (effect == null) {
			effect = new h2d.filter.DropShadow();

			prefab.filter.data.set(name, { distance : 4.0, angle : 0.785, color : 0x000000, alpha : 1.0, radius : 1.0, gain : 1.0, quality : 1.0, smoothColor : false });
			prefab.filter.add(name, effect);
		}

		for (field => item in registry) {
			var value = Reflect.field(prefab.filter.data[name], field);
			item.value = Std.string(value);
		}

		var prop = prefab.filter.data[name];
		registry.get("color").value = StringTools.hex(prop.color, 6);
		registry.get("angle").value = Std.string(snap(prop.angle * 180 / Math.PI));
	}


	function onChange(prop:Dynamic) {
		if (prefab.object.filter == null) return;

		if (prop.field == "color") prop.to = Editor.ME.getColor(prop.to);
		if (prop.field == "angle") prop.to = prop.to * Math.PI / 180;

		Reflect.setProperty(effect, prop.field, prop.to);
		Reflect.setProperty(prefab.filter.data[name], prop.field, prop.to);
	}


	inline function snap(value:Float, step:Float = 1) {
		return Math.round(value / step) * step;
	}
}