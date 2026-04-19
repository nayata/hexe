package property;

import property.component.Label;
import property.component.Input;
import property.component.TextArea;
import property.component.Number;
import property.component.Checkbox;
import property.component.Anchor;
import property.component.Option;
import property.component.Swatch;


class Layout extends Property {
	var root:h2d.Layers;
	var node:h2d.Layers;


	public function new(?parent:h2d.Object) {
		super(parent);

		root = new h2d.Layers(this);
		node = new h2d.Layers(this);


		// Size
		var label = new Label("Size", 0, top + half, root);

		var input = new Number(root);
		input.setPosition(second, top);
		input.onUpdate = onUpdate;
		input.onChange = onChange;
		input.minimum = 0;
		input.step = 10;
		input.label = "W";

		registry.set("width", input);
		input.field = "width";


		input = new Number(root);
		input.setPosition(third, top);
		input.onUpdate = onUpdate;
		input.onChange = onChange;
		input.minimum = 0;
		input.step = 10;
		input.label = "H";

		registry.set("height", input);
		input.field = "height";

		top += input.height + padding;


		// Padding
		label = new Label("Padding", 0, top + half, root);

		var input = set("padding", new Number(root));
		input.setPosition(second, top);
		input.onUpdate = onUpdate;
		input.onChange = onChange;
		input.minimum = 0;

		top += input.height + divider;


		// Clipping
		label = new Label("Clipping", 0, top + half * 0.5, root);

		input = set("masking", new Checkbox(root));
		input.setPosition(second, top);
		input.onChange = onChange;

		top += input.height + divider;


		// Selected Element

		// Width
		label = new Label("Width", 0, half, node);

		var input = new Number(node);
		input.setPosition(second, 0);

		input.onUpdate = onUpdate;
		input.onChange = onChange;

		input.minimum = 5;
		input.maximum = 100;
		input.step = 5;

		registry.set("scaleX", input);
		input.field = "scaleX";
		input.label = "%";

		// scaleMode
		var choice = new Option(node);
		choice.setPosition(third, 0);
		choice.setSize(80, 32);

		choice.add(["Auto", "Resize"]);

		choice.onFocus = onFocus;
		choice.onChange = onScaleMode;

		registry.set("resizeX", choice);
		choice.field = "resizeX";

		top = input.height + padding;


		// Height
		label = new Label("Height", 0, top + half, node);

		var input = new Number(node);
		input.setPosition(second, top);

		input.onUpdate = onUpdate;
		input.onChange = onChange;

		input.minimum = 5;
		input.maximum = 100;
		input.step = 5;

		registry.set("scaleY", input);
		input.field = "scaleY";
		input.label = "%";

		// scaleMode
		var choice = new Option(node);
		choice.setPosition(third, top);
		choice.setSize(80, 32);

		choice.add(["Auto", "Resize"]);

		choice.onFocus = onFocus;
		choice.onChange = onScaleMode;

		registry.set("resizeY", choice);
		choice.field = "resizeY";

		top += choice.height + padding + padding;


		// Element Padding
		label = new Label("Padding", 0, top + half, node);

		var input = new Number(node);
		input.setPosition(second, top);

		input.onUpdate = onUpdate;
		input.onChange = onChange;
		input.minimum = 0;

		registry.set("margin", input);
		input.field = "margin";


		// Color
		var input = new Swatch(node);
		input.setPosition(third, top);
		input.onChange = onChange;
		input.onFocus = onFocus;

		registry.set("color", input);
		input.field = "color";

		top += input.height + divider;


		// Anchor
		label = new Label("Anchor", 0, top + half * 0.5, node);

		var input = new Anchor(node);
		input.setPosition(second, top);
		input.onChange = onChange;

		registry.set("anchor", input);
		input.field = "anchor";

		top += input.height + divider;


		// Clipping
		label = new Label("Clipping", 0, top + half * 0.5, node);

		var input = set("clipping", new Checkbox(node));
		input.setPosition(second, top);
		input.onChange = onChange;
	}


	function onScaleMode(prop:Dynamic) {
		onChange(prop);

		if (object == null) return;

		var layout = (cast object : prefab.Layout);
		if (layout.selected != null) {
			registry.get("scaleX").enabled = layout.selected.resizeX == 1;
			registry.get("scaleY").enabled = layout.selected.resizeY == 1;
		}
	}


	override public function onFocus(o:h2d.Object) {
		node.over(o);
	}


	function onFocused(o:h2d.Object) {
		onFocus(this);
	}


	override function select(object:Dynamic) {
		super.select(object);

		if (object == null) return;

		var layout = (cast object : prefab.Layout);

		root.visible = layout.selected == null;
		node.visible = layout.selected != null;

		if (layout.selected != null) {
			registry.get("scaleX").value = Std.string(layout.selected.scaleX);
			registry.get("scaleY").value = Std.string(layout.selected.scaleY);

			registry.get("resizeX").value = Std.string(layout.selected.resizeX);
			registry.get("resizeY").value = Std.string(layout.selected.resizeY);

			registry.get("anchor").value = Std.string(layout.selected.anchor);
			registry.get("color").value = Std.string(layout.selected.color);

			registry.get("margin").value = Std.string(layout.selected.padding);
			registry.get("clipping").value = Std.string(layout.selected.clipping);

			// Enable
			registry.get("scaleX").enabled = layout.selected.resizeX == 1;
			registry.get("scaleY").enabled = layout.selected.resizeY == 1;

			registry.get("margin").enabled = layout.selected.type == "layout";
			registry.get("color").enabled = layout.selected.type == "layout";
			registry.get("clipping").enabled = layout.selected.type == "layout";
		}
	}


	override function unselect() {
		var layout = (cast object : prefab.Layout);
		if (layout != null) layout.selected = null;

		for (item in registry) {
			item.blur();
		}

		object = null;
		visible = false;
	}
}