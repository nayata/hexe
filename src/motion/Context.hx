package motion;

import property.component.Label;
import property.component.Number;
import property.component.Checkbox;
import property.component.FloatNumber;


class Context extends h2d.Object {
	public var settings:Settings;
	public var event:Event;
	public var edit:ui.Context;
	public var ease:ui.Context;


	public function new(?parent:h2d.Object) {
		super(parent);

		settings = new Settings(this);
		event = new Event(this);
		edit = new Editing(this);
		ease = new Ease(this);
	}
}



class Settings extends ui.Context {
	var registry:Map<String, property.component.Input> = new Map();


	public function new(?parent:h2d.Object) {
		super(parent);

		attachment = hxd.Direction.Down;
		padding = 164;
		
		// Duration
		var label = new Label("Duration", 20, 30 + 14, this);

		var number = new Number(this);
		number.setPosition(100, 30);
		number.setSize(110, 32);
		
		number.label = "F";
		number.value = "60";

		number.minimum = 0;
		number.step = 1;

		number.onUpdate = onInput;
		number.onChange = onInput;

		registry.set("duration", number);
		number.field = "duration";

		@:privateAccess number.input.onOut = onChildOut;

		// Speed
		label = new Label("Speed", 20, 70 + 14, this);

		var number = new FloatNumber(this);
		number.setPosition(100, 70);
		number.setSize(110, 32);

		number.onUpdate = onInput;
		number.onChange = onInput;

		number.label = "S";
		number.value = "1";
		
		number.minimum = 0;
		number.step = 0.1;

		number.onUpdate = onInput;
		number.onChange = onInput;

		registry.set("speed", number);
		number.field = "speed";

		@:privateAccess number.input.onOut = onChildOut;

		// Loop
		label = new Label("Loop", 20, 120 + 7, this);

		var checkbox = new Checkbox(this);
		checkbox.setPosition(100, 120);
		
		checkbox.onChange = onInput;
		checkbox.value = "true";

		registry.set("loop", checkbox);
		checkbox.field = "loop";
		
		// Edit
		addDivider();
		add("New Animation", "add");
		add("Remove", "delete");

		onResize();
	}


	override function onOut(e:hxd.Event) {
		check();
	}


	function onChildOut(e:hxd.Event) {
		check();
	}


	function check() {
		var scene = editor.s2d;

		var min = getAbsPos();
		var max = new h2d.col.Point(min.x + input.width, min.y + input.height);

		if (scene.mouseY < min.y || scene.mouseX < min.x || scene.mouseX >= max.x || scene.mouseY >= max.y) {
			close();
		}
	}


	function onInput(prop:Dynamic) {
		if (prop.field == "duration") editor.motion.onDuration(prop.to);
		if (prop.field == "speed") editor.motion.speed = prop.to;
		if (prop.field == "loop") editor.motion.loop = prop.to;
	}


	public function update() {
		registry.get("duration").value = Std.string(editor.motion.frameDuration);
		registry.get("speed").value = Std.string(editor.motion.speed);
		registry.get("loop").value = Std.string(editor.motion.loop);
	}


	override function onChange(value:String, type:String) {
		switch (value) {
			case "New Animation" : editor.motion.onAnimation(true);
			case "Remove" : editor.motion.onAnimation();
			default:
		}
	}
}


class Ease extends ui.Context {
	var channel:String = "";

	public function new(?parent:h2d.Object) {
		super(parent);

		attachment = hxd.Direction.Down;

		add("linear", "ease");
		add("stepped", "ease");

		addDivider();

		add("easeIn", "ease");
		add("easeOut", "ease");
		add("easeInOut", "ease");

		addDivider();

		add("backIn", "ease");
		add("backOut", "ease");
		add("backInOut", "ease");

		addDivider();
		
		add("elastic", "ease");
		add("bounce", "ease");
	}

	override public function open(?channel:String) {
		this.channel = channel;
		super.open();
	}

	override function onChange(value:String, type:String) {
		editor.motion.setEase(value, channel);
	}
}


class Event extends ui.Context {
	var text:property.component.Text;

	public function new(?parent:h2d.Object) {
		super(parent);

		attachment = hxd.Direction.Down;

		add("play", "action");
		add("stop", "action");
		add("prev", "action");
		add("next", "action");

		add("text", "action");
		add("action", "action");
		add("shoot", "action");
		add("hit", "action");

		add("hide", "action");
		add("show", "action");
		add("toggle", "action");
		add("lock", "action");

		addDivider();

		text = new property.component.Text(this);
		text.setPosition(16, input.height + 20);
		text.setSize(220-46, 40);

		text.onChange = onText;

		text.label = "Event";
		text.value = "none";

		@:privateAccess text.input.onOut = onChildOut;

		var button = new ui.Icon("add", this);
		button.onClick = onButton;
		button.input.onOut = onChildOut;

		button.setPosition(193, text.y);
		button.setSize(40, 40);

		input.height = input.height + text.height + 40;
		panel.height = input.height;
	}


	public function update(?frame:motion.animation.Frame) {
		text.value = frame != null ? frame.name : "none";
	}


	override function onOut(e:hxd.Event) {
		check();
	}


	function onChildOut(e:hxd.Event) {
		check();
	}


	function check() {
		var scene = editor.s2d;

		var min = getAbsPos();
		var max = new h2d.col.Point(min.x + input.width, min.y + input.height);

		if (scene.mouseY < min.y || scene.mouseX < min.x || scene.mouseX >= max.x || scene.mouseY >= max.y) {
			close();
		}
	}


	function onText(prop:Dynamic) {
		editor.motion.event(prop.to);
	}


	function onButton() {
		close();
	}


	override function onChange(value:String, type:String) {
		editor.motion.event(value);
		text.value = value;
	}
}


class Editing extends ui.Context {
	var channel:String = "";

	public function new(?parent:h2d.Object) {
		super(parent);

		attachment = hxd.Direction.Down;

		add("Select All", "all");
		addDivider();

		add("Cut");
		get("Cut").padding = Style.menuPadding;

		add("Copy");
		get("Copy").padding = Style.menuPadding;

		add("Paste");
		get("Paste").padding = Style.menuPadding;

		add("Delete", "delete");
	}

	override public function open(?channel:String) {
		this.channel = channel;
		super.open();
	}

	override function onChange(value:String, type:String) {
		switch (value) {
			case "Add Keyframe" : editor.motion.onKeyframe("add", channel);
			case "Select All" : editor.motion.onKeyframe("select");

			case "Cut" : editor.motion.onClipboard("cut");
			case "Copy" : editor.motion.onClipboard("copy");
			case "Paste" : editor.motion.onClipboard("paste");

			case "Delete" : editor.motion.onKeyframe("delete");
			
			default:
		}
	}
}