package property;

import property.component.Label;
import property.component.Input;

import property.component.Number;
import property.component.TextArea;
import property.component.Checkbox;
import property.component.Option;
import property.component.Align;
import property.component.Color;
import property.component.Font;


class Text extends Property {
	var panel:h2d.Layers;
	var text:TextArea;
	var choice:Font;
	

	public function new(?parent:h2d.Object) {
		super(parent);

		// Text
		text = new TextArea(this);
		text.onUpdate = onUpdate;
		text.onChange = onChange;
		text.label = "Text";
		text.setSize(240, 40);
		set("text", text);


		panel = new h2d.Layers(this);
		panel.y = text.height + divider;


		// Font
		var label = new Label("Font", 0, top + tall * 0.5, panel);

		choice = new Font(panel);
		choice.setPosition(second, top);
		choice.onChange = onChange;
		choice.onFocus = onFocus;
		choice.label = "Font";
		choice.icon = "font";
		choice.add(["Default", "Load"]);
		choice.setSize(166, 40);
		set("font", choice);

		top += choice.height + padding;


		// Text Align
		label = new Label("Align", 0, top + half, panel);

		var input = set("align", new Align(panel));
		input.setPosition(second, top);
		input.onChange = onChange;
		input.setSize(166, 32);

		top += input.height + padding;

		
		// Text Color
		label = new Label("Color", 0, top + half, panel);

		input = set("color", new Color(panel));
		input.setPosition(second, top);
		input.onUpdate = onUpdate;
		input.onChange = onChange;
		input.onFocus = onFocus;
		input.setSize(166, 32);

		top += input.height + padding;


		// Size
		label = new Label("Size", 0, top + half, panel);

		input = set("size", new Number(panel));
		input.setPosition(second, top);
		input.onUpdate = onUpdate;
		input.onChange = onChange;
		input.minimum = 0;
		input.icon = "font";

		// Mode
		var option = new Option(panel);
		registry.set("mode", option);
		option.setPosition(third, top);
		option.add(["Bitmap", "MSDF", "SDF"]);
		option.onFocus = onFocus;
		option.onChange = onChange;
		option.field = "mode";
		option.setSize(80, 32);

		top += input.height + padding;


		label = new Label("Spacing", 0, top + half, panel);

		// letterSpacing
		input = set("letterSpacing", new Number(panel));
		input.setPosition(second, top);
		input.onUpdate = onUpdate;
		input.onChange = onChange;
		input.icon = "spacing";

		// lineSpacing
		input = set("lineSpacing", new Number(panel));
		input.setPosition(third, top);
		input.onUpdate = onUpdate;
		input.onChange = onChange;
		input.minimum = -1;
		input.icon = "leading";

		top += input.height + padding;

		
		label = new Label("maxWidth", 0, top + half, panel);

		// maxWidth
		input = set("maxWidth", new Number(panel));
		input.setPosition(second, top);
		input.onUpdate = onUpdate;
		input.onChange = onChange;
		input.minimum = -1;
		input.icon = "wrap";

		top += input.height + padding + padding;


		// smooth
		label = new Label("Smooth", 0, top + half * 0.5, panel);

		input = set("smooth", new Checkbox(panel));
		input.setPosition(second, top);
		input.onChange = onChange;

		over(choice);
	}


	override public function onFocus(o:h2d.Object) {
		panel.over(o);
	}


	override public function rebuild() {
		var fonts = ["Default"];
		for (name => font in Assets.fonts) {
			if (name != "Default") fonts.push(name);
		}
		fonts.push("Load");
		choice.add(fonts);
	}
}