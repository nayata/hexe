package property;

import property.component.Label;
import property.component.Input;

import property.component.Number;
import property.component.FloatNumber;
import property.component.TextArea;
import property.component.Select;
import property.component.Align;
import property.component.Color;

import property.component.Font;


class Text extends Property {
	var panel:h2d.Layers;
	var text:TextArea;
	var choice:Select;
	

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


		// Text Font
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
		input.onChange = onChange;
		input.onFocus = onFocus;
		input.setSize(166, 32);

		top += input.height + padding;


		// maxWidth & lineSpacing
		label = new Label("Size", 0, top + half, panel);

		input = set("letterSpacing", new Number(panel));
		input.setPosition(second, top);
		input.onUpdate = onUpdate;
		input.onChange = onChange;
		input.icon = "spacing";

		input = set("lineSpacing", new Number(panel));
		input.setPosition(third, top);
		input.onUpdate = onUpdate;
		input.onChange = onChange;
		input.icon = "leading";


		top += input.height + padding;

		// maxWidth
		input = set("maxWidth", new Number(panel));
		input.setPosition(second, top);
		input.onUpdate = onUpdate;
		input.onChange = onChange;
		input.minimum = -1;
		input.icon = "wrap";

		over(choice);
	}


	override public function onFocus(o:h2d.Object) {
		panel.over(o);
	}


	override public function rebuild() {
		var fonts = [];
		for (name => font in Assets.fonts) {
			fonts.push(name);
		}
		fonts.push("Load");
		choice.add(fonts);
	}
}