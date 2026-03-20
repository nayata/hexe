package effect;

import property.component.Label;
import property.component.Checkbox;
import property.component.BlendMode;
import property.component.Slider;


class Blending extends Effect {
	public function new(?parent:h2d.Object) {
		super(parent);

		name = "Blending";


		// Radius
		var label = new Label("Alpha", 0, 50 + 14, this);

		var input = new Slider(this);
		input.setPosition(230, 50);
		input.setSize(60, 32);

		input.setSliderSize(130, 32);
		input.setSliderRange(0, 1);
		
		input.minimum = 0;
		input.maximum = 1;
		input.step = 0.025;

		input.onUpdate = onChange;

		registry.set("alpha", input);
		input.field = "alpha";


		// Visible
		label = new Label("Visible", 0, 100 + 7, this);

		var input = new Checkbox(this);
		input.setPosition(90, 100);

		input.onChange = onChange;

		registry.set("visible", input);
		input.field = "visible";


		// BlendMode
		label = new Label("BlendMode", 0, 14, this);

		var input = new BlendMode(this);
		input.setPosition(90, 0);
		input.setSize(200, 40);

		input.add(haxe.EnumTools.createAll(h2d.BlendMode));
		input.icon = "menu";

		input.onChange = onChange;

		registry.set("blendMode", input);
		input.field = "blendMode";
	}


	override public function init(entry:prefab.Prefab) {
		prefab = entry;

		for (field => item in registry) {
			var value = Reflect.field(prefab.object, field);
			item.value = Std.string(value);
		}
	}


	function onChange(prop:Dynamic) {
		if (prefab.object.filter == null) return;

		Reflect.setProperty(prefab.object, prop.field, prop.to);
		Editor.ME.outliner.update(prefab);
		Editor.ME.onTransform();
	}
}