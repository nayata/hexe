package motion.dopesheet;

class Thread extends h2d.Object {
	var input:Text;

	var icon:h2d.Bitmap;
	var text:h2d.Text;

	var choice:Select;
	

	public function new(?parent:h2d.Object) {
		super(parent);

		input = new Text(this);
		input.onChange = onChange;
		input.setSize(170, 32);

		input.value = "default";

		var icon = new ui.Icon("wrap", this);
		icon.onChange = onToggle;
		icon.x = 170-32; 

		choice = new Select(this);
		choice.onChange = onSelect;
		choice.add(["play", "stop", "prev", "next", "text", "hit", "shoot", "hide", "toggle", "lock"]);
		choice.setSize(170, 32);
		choice.visible = false;

		x = 30;
		y = 60;
	}


	function onToggle() {
		choice.onToggle();
	}


	public function update(?frame:motion.animation.Frame) {
		input.value = frame != null ? frame.name : "default";
	}


	function onChange(prop:Dynamic) {
		if (prop.from != prop.to) Editor.ME.motion.event(prop.to);
	}


	function onSelect(prop:Dynamic) {
		if (input.value != prop) {
			Editor.ME.motion.event(prop);
			input.value = prop;
		}
	}
}


class Text extends property.component.Text {
	public function new(?parent:h2d.Object) {
		super(parent);
		
		back.tile = Assets.icon("dialogue");
		input.alpha = 0.5;
		face.alpha = 0.5;
	}
}


class Select extends property.component.Select {
	public function onToggle() {
		if (!panel.visible) {
			visible = true;
			open();
		}
		else {
			close();
		}
	}

	override function onClick(event:hxd.Event) {
		if (selected != null) {
			onChange(selected.value);
			visible = false;
			close();
		}
	}

	override function open() {
		super.open();
		y = -input.height + size;
	}

	override function close() {
		visible = false;
		super.close();
	}

	override function set_value(v) {
		text.text = v;
		return v;
	}
}