package property;

import property.component.Label;
import property.component.Input;
import property.component.Number;
import property.component.TextArea;
import property.component.Option;
import property.component.Color;


class Collider extends Property {
	var panel:h2d.Layers;

	var path:h2d.Object;
	var prop:h2d.Object;

	var position:Float = 0;


	public function new(?parent:h2d.Object) {
		super(parent);

		panel = new h2d.Layers(this);

		var label = new Label("Size", 0, half, panel);

		var input = set("width", new Number(panel));
		input.setPosition(second, top);
		input.onUpdate = onUpdate;
		input.onChange = onChange;
		input.minimum = 0;
		input.label = "W";

		input = set("height", new Number(panel));
		input.setPosition(third, top);
		input.onUpdate = onUpdate;
		input.onChange = onChange;
		input.minimum = 0;
		input.label = "H";

		top += input.height + divider;

		// Type
		label = new Label("Type", 0, top + tall * 0.5, panel);

		var choice = new Option(panel);
		registry.set("body", choice);
		choice.setPosition(second, top);
		choice.add(["Static", "Dynamic", "Kinematic", "Sensor"]);
		choice.onFocus = onFocus;
		choice.onChange = onChange;
		choice.field = "body";
		choice.icon = "menu";
		choice.setSize(166, 40);

		top += choice.height + padding;

		// Shape
		label = new Label("Shape", 0, top + tall * 0.5, panel);

		choice = new Option(panel);
		registry.set("shape", choice);
		choice.setPosition(second, top);
		choice.add(["Box", "Sphere", "Polygon", "Capsule"]);
		choice.onFocus = onFocus;
		choice.onChange = onChange;
		choice.field = "shape";
		choice.icon = "shape";
		choice.setSize(166, 40);

		position = top + choice.height;
		top += choice.height + padding;
		
		// Path
		path = new h2d.Object(panel);
		path.setPosition(0, top);

		// Vertices
		label = new Label("Points", 0, tall * 0.5, path);

		choice = new Option(path);
		registry.set("mode", choice);
		choice.setPosition(second, 0);
		choice.add(["Quad", "Slope Right", "Slope Left", "Triangle", "Diamond", "Octagon"]);
		choice.onFocus = onObjectFocus;
		choice.onChange = onChange;
		choice.field = "mode";
		choice.icon = "path";
		choice.setSize(166, 40);

		top += choice.height + divider;

		// Data
		prop = new h2d.Object(panel);
		prop.setPosition(0, top);

		label = new Label("Data", 0, tall * 0.5, prop);

		input = set("text", new TextArea(prop));
		input.setPosition(second, 0);
		input.onChange = onChange;
		input.icon = "wrap";
		input.setSize(166, 40);

		top = input.height + padding;

		// Color
		label = new Label("Color", 0, top + half, prop);

		input = set("color", new Color(prop));
		input.setPosition(second, top);
		input.onChange = onChange;
		input.onFocus = onObjectFocus;
		input.setSize(166, 32);
	}


	override public function select(object:Dynamic) {
		super.select(object);

		var collider = (cast object : prefab.Collider);

		path.visible = collider.shape == prefab.Collider.POLYGON;
		prop.y = path.visible ? position + 40 + divider : position + divider;
	}


	override function onChange(prop:Dynamic) {
		super.onChange(prop);
		if (object != null) select(object);
	}


	function onObjectFocus(o:h2d.Object) {
		panel.over(o.parent);
	}


	override public function onFocus(o:h2d.Object) {
		panel.over(o);
	}
}