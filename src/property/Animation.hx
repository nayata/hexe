package property;

import property.component.Text;
import property.component.Input;
import property.component.Label;
import property.component.Number;
import property.component.Checkbox;
import property.component.FloatNumber;


class Animation extends Property {
	public function new(?parent:h2d.Object) {
		super(parent);

		var text = new ui.Text("Animation", 0, -40, this);

		var label = new Label("Duration", 0, top + half, this);

		var input:Input = set("duration", new Number(this));
		input.setSize(120, 32);
		input.setPosition(120, top);
		input.onUpdate = onUpdate;
		input.onChange = onChange;
		input.label = "F";
		input.value = "60";

		top += input.height + padding;

		label = new Label("Speed", 0, top + half, this);

		input = set("speed", new FloatNumber(this));
		input.setSize(120, 32);
		input.setPosition(120, top);
		input.onUpdate = onUpdate;
		input.onChange = onChange;
		input.label = "S";
		input.value = "1";

		top += input.height + divider;

		label = new Label("Loop", 0, top + half * 0.5, this);

		input = set("loop", new Checkbox(this));
		input.setPosition(120, top);
		input.onChange = onChange;
		input.value = "1";

		visible = false;
	}


	override function onUpdate(prop:Dynamic) {
		if (prop.field == "duration") Editor.ME.motion.onDuration(prop.to);
		if (prop.field == "speed") Editor.ME.motion.speed = Math.max(prop.to, 0);
		if (prop.field == "name") Editor.ME.motion.name = prop.to;
	}


	override function onChange(prop:Dynamic) {
		if (prop.field == "duration") Editor.ME.motion.onDuration(prop.to);
		if (prop.field == "speed") Editor.ME.motion.speed = Math.max(prop.to, 0);
		if (prop.field == "loop") Editor.ME.motion.loop = prop.to;
	}


	override public function update() {
		registry.get("duration").value = Std.string(Editor.ME.motion.frameDuration);
		registry.get("speed").value = Std.string(Editor.ME.motion.speed);
		registry.get("loop").value = Editor.ME.motion.loop ? "1" : "0";

		if (Editor.ME.motion.enabled && Editor.ME.selected == null) visible = true;
		if (!Editor.ME.motion.enabled) visible = false;
	}


	override public function select(object:Dynamic) {
		visible = false;
	}


	override public function unselect() {
		visible = Editor.ME.motion.enabled;
	}
}