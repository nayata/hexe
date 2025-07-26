import h2d.Object;
import h2d.Bitmap;
import hxd.Event;

import motion.Animation;
import motion.Timeline;
import motion.Tracker;

import motion.dopesheet.Chanel;
import motion.dopesheet.Thread;

import motion.animation.Frame;
import motion.Menu;

import ui.Touch;
import ui.Icon;


class Motion extends h2d.Object {
	public var width:Int = 1300;
	public var height:Int = 280;

	var editor:Editor;

	var touch:Touch;
	var scroller:h2d.Mask;
	var view:h2d.Object;
	
	var panel:h2d.Bitmap;
	var grip:h2d.Bitmap;

	var timeline:Timeline;
	var tracker:Tracker;

	var chanel:Chanel;
	var thread:Thread;

	var control:h2d.Object;

	public var enabled = false;

	public var menu:Menu;
	public var animation:Animation;

	public var time:Float = 0;
	public var frame:Int = 0;

	public var playing = false;

	public var frameDuration:Int = 60;
	public var duration:Float = 2;

	public var speed:Float = 1.0;
	public var loop:Bool = true;

	var clipboard:Array<Frame> = [];

	var indent:Int = 230;
	var offset:Int = 16;


	public function new(?parent:h2d.Object) {
		super(parent);

		editor = Editor.ME;

		menu = new Menu();

		touch = new Touch(width, height, this);
		touch.onPush = onDown;
		touch.onRelease = onUp;
		touch.onMove = onMove;
		touch.onWheel = onWheel;

		panel = new h2d.Bitmap(h2d.Tile.fromColor(Style.panel, width, height), this);
		panel.smooth = false;

		grip = new h2d.Bitmap(h2d.Tile.fromColor(Style.border, 4, height), this);

		control = new h2d.Object(this);
		control.y = 5;

		var icon = new Icon("menu", control);
		icon.onChange = onToggle;
		icon.x = 22;

		var button = new Icon("play", control);
		button.onChange = play;
		button.x = 110;

		button = new Icon("prev", control);
		button.onChange = prev;
		button.x = 80;

		button = new Icon("next", control);
		button.onChange = next;
		button.x = 140;

		scroller = new h2d.Mask(width - indent, height, this);
		view = new Object(scroller);
		view.x = 20;

		animation = new Animation(editor.children);
		timeline = new Timeline(view);

		tracker = new Tracker(view);
		tracker.timeline = animation.timeline;
		tracker.y = 100;

		chanel = new Chanel(this);
		thread = new Thread(this);

		visible = false;
	}


	/* ------------------------------ Animation control ------------------------------ */

	public function play() {
		playing = !playing;
		if (playing && time >= duration) time = 0;

		if (!playing) {
			frame = fromTime(time);
			time = fromFrame(frame);

			onUpdate();
		}
	}


	function prev() {
		playing = false;
		frame = 0;
		time = 0;
		onUpdate();
	}


	function next() {
		playing = false;
		frame = fromTime(duration);
		time = fromFrame(frame);
		onUpdate();
	}


	// Animation playing
	public function update(delta:Float) {
		if (playing) {
			time += delta * speed;
			frame = fromTime(time);

			animation.timeline.update(time);
			timeline.update(time);

			editor.control.onChange();
		}

		if (playing && time >= duration) {
			if (!loop) {
				time = duration;
				playing = false;

				onUpdate();
			}
			if (loop) time = 0;
		}
	}


	// Animation at specific time
	function advance(value:Float) {
		time = getTime(value);
		frame = fromTime(time);

		onUpdate();
	}


	function onUpdate() {
		animation.timeline.update(time);
		timeline.update(time);

		thread.update(animation.find("", "event", frame));

		editor.property.onChange();
		editor.control.onChange();
	}


	/* ------------------------------ Object actions ------------------------------ */

	public function select(object:h2d.Object) {
		if (!enabled) return;

		tracker.select(object.name);
		tracker.alpha = 1.0;
	}


	public function unselect() {
		if (!enabled) return;
		
		tracker.unselect();
		//tracker.alpha = 0.5; // Leave keys visible
	}


	public function delete(object:h2d.Object) {
		if (!enabled) return;

		animation.delete(object.name);
		tracker.unselect();
	}


	// Object Transform
	public function onTransform(element:History.Transform, object:h2d.Object, from:Property, to:Property) {
		if (!enabled) return;
		
		var history:Array<Keyframe> = [];

		if (from.x != to.x) {
			var added = animation.set(object.name, "x", to.x, frame);
			history.push({ time : frame, field : "x", added : added });
		}
		if (from.y != to.y) {
			var added = animation.set(object.name, "y", to.y, frame);
			history.push({ time : frame, field : "y", added : added });
		}

		if (from.scaleX != to.scaleX) {
			var added = animation.set(object.name, "scaleX", to.scaleX, frame);
			history.push({ time : frame, field : "scaleX", added : added });
		}
		if (from.scaleY != to.scaleY) {
			var added = animation.set(object.name, "scaleY", to.scaleY, frame);
			history.push({ time : frame, field : "scaleY", added : added });
		}

		if (from.rotation != to.rotation) {
			var added = animation.set(object.name, "rotation", to.rotation, frame);
			history.push({ time : frame, field : "rotation", added : added });
		}

		element.motion = history;
		tracker.select(object.name);
	}


	// Object Property
	public function onProperty(element:History.Property, object:h2d.Object, type:String, from:Float, to:Float) {
		if (!enabled) return;

		if (from != to) {
			var added = animation.set(object.name, type, to, frame);
			element.motion = { time : frame, field : type, added : added };
		}

		tracker.select(object.name);
	}


	// Add animation [called from File.hx]
	public function add(name:String, type:String, ease:String, data:Float, time:Float) {
		var frame = fromTime(time);

		if (type != "event") animation.timeline.add(name, type, ease, data, frame);
		if (type == "event") animation.event(name, frame);

		animation.update();
	}


	// Has animation for 'name' object [called from File.hx]
	public function has(name:String):Bool {
		return editor.children.exists(name);
	}


	public function onHistory(position:Int) {
		frame = position;
		time = fromFrame(frame);
		onUpdate();
	}


	public function onEvent() {
		thread.update(animation.find("", "event", frame));
		tracker.onEvent();
	}


	/* ------------------------------ Key actions ------------------------------ */

	// Add key to `type` channel, e.g.(object, "x", object.value, currentFrame) [called from Chanel.hx]
	public function set(type:String) {
		if (editor.selected == null) return;

		animation.set(editor.selected.name, type, Reflect.field(editor.selected, type), frame);
		tracker.select(editor.selected.name);

		var history = new History.Set(editor.selected.name, type, Reflect.field(editor.selected, type), frame);
		Editor.ME.history.add(new History.Edit(editor.selected.name, [history]));
	}


	public function event(type:String) {
		var exist = animation.find("", "event", frame);
		var event = exist != null ? exist.name : name;
		
		var added = animation.event(type, frame);

		var history = new History.Event(type, event, added ? "add" : "set", frame);
		Editor.ME.history.add(new History.Edit(name, [history]));

		tracker.onEvent();
	}


	// Add, Select or Delete keys
	public function onKeyframe(type:String) {
		var name = editor.selected != null ? editor.selected.name : "";

		switch (type) {
			case "add" if (editor.selected != null) :
				animation.set(editor.selected.name, "x", editor.selected.x, frame);
				animation.set(editor.selected.name, "y", editor.selected.y, frame);
		
				animation.set(editor.selected.name, "scaleX", editor.selected.scaleX, frame);
				animation.set(editor.selected.name, "scaleY", editor.selected.scaleY, frame);
		
				animation.set(editor.selected.name, "rotation", editor.selected.rotation, frame);
				animation.set(editor.selected.name, "alpha", editor.selected.alpha, frame);

				var history = { x : editor.selected.x, y : editor.selected.y, scaleX : editor.selected.scaleX, scaleY : editor.selected.scaleY, rotation : editor.selected.rotation, alpha : editor.selected.alpha };
				Editor.ME.history.add(new History.All(editor.selected.name, history, frame));
		
				tracker.select(editor.selected.name);

			case "select":
				tracker.selectAll();

			case "delete" if (tracker.selected.length > 0) :
				var history:Array<History.Element> = [];

				for (keyframe in tracker.selected) {
					if (keyframe.type == "event") history.push(new History.Event(keyframe.name, "", "delete", keyframe.time));
					if (keyframe.type != "event") history.push(new History.Clear(name, keyframe.type, keyframe.ease, keyframe.from, keyframe.time));

					animation.remove(keyframe);
				}

				Editor.ME.history.add(new History.Edit(name, history));

				animation.update();
				tracker.select(name);

			default:
		}
	}


	// Set selected key easing
	public function setEase(name:String) {
		if (editor.selected == null) return;
		if (tracker.selected.length == 0) return;

		var history:Array<History.Element> = [];

		for (frame in tracker.selected) {
			history.push(new History.Ease(editor.selected.name, frame.type, frame.ease, name, frame.time));
			frame.ease = name;
		}

		Editor.ME.history.add(new History.Edit(editor.selected.name, history));
	}


	public function onClipboard(type:String) {
		var name = editor.selected != null ? editor.selected.name : "";

		switch (type) {
			case "copy": 
				if (clipboard.length > 0) clipboard = [];

				for (entry in tracker.selected) {
					clipboard.push(entry);
				}

			case "cut" if (tracker.selected.length > 0) :
				var history:Array<History.Element> = [];

				for (entry in tracker.selected) {
					if (entry.type == "event") history.push(new History.Event(entry.name, "", "delete", entry.time));
					if (entry.type != "event") history.push(new History.Clear(name, entry.type, entry.ease, entry.from, entry.time));
					clipboard.push(entry);

					animation.remove(entry);
				}

				Editor.ME.history.add(new History.Edit(name, history));

				animation.update();
				tracker.select(name);

			case "paste" if (clipboard.length > 0) :
				var history:Array<History.Element> = [];

				for (entry in clipboard) {
					if (entry.type == "event") {
						animation.event(entry.name, frame);
						history.push(new History.Event(entry.name, "", "add", frame));
					}
					if (entry.type != "event" && editor.selected != null) {
						history.push(new History.Set(editor.selected.name, entry.type, entry.from, frame));

						animation.set(editor.selected.name, entry.type, entry.from, frame);
						animation.ease(editor.selected.name, entry.type, entry.ease, frame);
					}
				}

				Editor.ME.history.add(new History.Edit(name, history));

				animation.update();
				tracker.select(name);
				onUpdate();

			default:
		}
	}


	inline function getName():String {
		return editor.selected != null ? editor.selected.name : "";
	}


	/* ------------------------------ Mouse Events ------------------------------ */

	var tracking = false;
	var state = "empty";

	var position:Int = 0;

	var min:Int = 0;
	var max:Int = 0;


	function onDown(event:hxd.Event) {
		if (event.button == 0) {
			playing = false;
			
			touch.position.x = event.relX - view.x;
			touch.position.y = event.relY - tracker.y;

			position = getFrame(event.relX - view.x);

			if (event.relY <= 40) tracking = true;

			touch.left = true;
		}

		if (event.button == 1) {
			touch.position.x = editor.s2d.mouseX - view.x;
			touch.right = true;
		}

		// Move on timeline
		if (touch.left && tracking) advance(event.relX - view.x);

		
		// Key selection
		if (touch.left && tracking) return;
		if (touch.right) return;

		//if (editor.selected == null) return;

		// Take a single key or confirm selection
		var selected = animation.find(getName(), tracker.getType(touch.position.y), position);

		// selected confirmed and need to be checked
		if (selected != null) {
			if (!tracker.selected.contains(selected)) {
				tracker.clearKey();

				tracker.selected = [selected];

				var keyframe = tracker.getKey(selected);
				keyframe.select();
			}

			state = "drag";

			// Set dragging range
			min = Std.int(duration * 1000);
			max = 0;

			for (frame in tracker.selected) {
				if (frame.time < min) min = frame.time;
				if (frame.time > max) max = frame.time;
			}
		}

		// selected is null, ready to select
		if (selected == null) {
			tracker.clearKey();
			state = "select";
		}
	}


	function onMove(event:hxd.Event) {
		if (!touch.right) {
			timeline.cursor.x = (event.relX - view.x) - 0.5;
		}

		// Move on timeline
		if (touch.left && tracking) {
			advance(event.relX - view.x);
		}


		// Drag selected keys
		if (touch.left && state == "drag") {
			var current = getFrame(event.relX - view.x);
			var diff:Int = current - position;

			if (diff < -min) diff = -min;
			if (max + diff > duration * 30) diff = Std.int(duration * 30 - max);


			// Update Key time & update Traker keys
			for (frame in tracker.selected) {
				frame.time = frame.step + diff;
				
				var keyframe = tracker.getKey(frame);
				
				keyframe.x = fromFrame(frame.time) * timeline.scaling;
				keyframe.time = frame.time;
			}
		}


		// Select keys
		if (touch.left && state == "select") {
			var relX = event.relX - view.x;
			var relY = event.relY - tracker.y;

			if (Math.abs(touch.position.x - relX) > 8 || Math.abs(touch.position.y - relY) > 8) {
				tracker.onSelect(touch.position.x, touch.position.y, relX, relY);
			}
		}


		// Drag view
		if (touch.right) {
			view.x = editor.s2d.mouseX - touch.position.x;
			view.x = Math.max(view.x, -((timeline.length + 0.336) * timeline.scaling) + scroller.width);
			view.x = Math.min(view.x, 20);
		}
	}

	
	function onUp(event:hxd.Event) {
		if (state == "drag") {
			var changed = Math.abs(position - getFrame(event.relX - view.x)) > 0;

			// Move to time if nothing dragged
			if (!changed) advance(event.relX - view.x);

			// Update animation if key dragged
			if (changed) {
				var history:Array<History.Element> = [];

				for (frame in tracker.selected) {
					history.push(new History.Time(getName(), frame.type, frame.step, frame.time));
				}

				Editor.ME.history.add(new History.Edit(getName(), history));
				animation.update();
			}
		}
		
		if (state == "select") {
			var relX = event.relX - view.x;
			var relY = event.relY - tracker.y;

			// Select all keys in rectangle
			if (Math.abs(touch.position.x - relX) > 8 || Math.abs(touch.position.y - relY) > 8) {
				tracker.selectKey(touch.position.x, touch.position.y, relX, relY);
			}
			else {
				advance(event.relX - view.x);
			}
		}

		if (touch.left && state != "drag" && state != "select") {
			advance(event.relX - view.x);
		}

		if (touch.right) {
			view.x = snap(view.x, 1);
		}

		tracking = false;
		state = "empty";
		
		touch.left = false;
		touch.right = false;
	}


	// Advance time on MouseScroll or resize Timeline
	function onWheel(event:hxd.Event) {
		if (event.relY <= 40) {
			timeline.onWheel(event.wheelDelta);
			timeline.update(time);

			tracker.scaling = timeline.scaling;
			tracker.onResize();

			view.x = Math.max(view.x, -((timeline.length + 0.336) * timeline.scaling) + scroller.width);
			view.x = Math.min(view.x, 20);

			return;
		}

		var val = 0.0;

		val = event.wheelDelta > 0 ? -1 : 1;
		val = hxd.Math.clamp(frame + val, 0, frameDuration);
		
		frame = Std.int(val);
		time = fromFrame(frame);

		onUpdate();
	}


	/* ------------------------------ Time actions ------------------------------ */

	function getTime(value:Float):Float {
		if (value < 0) value = 0;
		if (value > timeline.length * timeline.scaling) value = timeline.length * timeline.scaling;

		value = snap(value / timeline.scaling, 0.03333);
		value = snap(value, 0.001);

		return value;
	}


	function getFrame(value:Float):Int {
		if (value < 0) value = 0;
		if (value > timeline.length * timeline.scaling) value = timeline.length * timeline.scaling;

		value = snap((value / timeline.scaling) * 30, 1);

		return Std.int(value);
	}


	function fromTime(value:Float):Int {
		value = Math.round((value * 30) / 1) * 1;
		return Std.int(value);
	}


	function fromFrame(fraction:Float):Float {
		var value = fraction / 30;

		value = snap(value, 0.03333);
		value = snap(value, 0.001);

		return value;
	}


	function snap(value:Float, fraction:Float = 0.3) {
		return Math.round(value / fraction) * fraction;
	}


	/* ------------------------------ Animation Mode ------------------------------ */

	public function onDuration(value:Float) {
		value = Math.max(value, 0);

		frameDuration = Std.int(value);
		duration = fromFrame(value);
		timeline.duration = duration;
	}


	public function onAnimation(mode:Bool = false) {
		clear();

		menu.visible = mode;
		visible = mode;

		enabled = mode;

		editor.property.onScene();
		editor.onAnimation();
	}


	public function onScene() {
		frameDuration = fromTime(duration);
		duration = fromFrame(frameDuration);
		timeline.duration = duration;

		menu.visible = true;
		visible = true;

		enabled = true;
		editor.onAnimation();
	}


	// Reset all
	public function clear() {
		playing = false;

		time = 0;
		frame = 0;

		animation = new Animation(editor.children);

		tracker.timeline = animation.timeline;
		tracker.unselect();
		
		frameDuration = 60;
		duration = 2;

		timeline.duration = duration;
		timeline.update(time);

		loop = true;
		speed = 1;
		
		menu.visible = false;
		visible = false;

		enabled = false;
		editor.onAnimation();
	}


	function onToggle() {
		height = height != 280 ? 280 : 40;

		editor.onAnimation();
		onResize();
	}


	public function onResize() {
		panel.width = width;
		panel.height = height;

		touch.width = width - indent;
		touch.x = indent;

		scroller.width = width - indent - offset;
		scroller.x = indent;

		grip.x = width - 4;
	}


	override function sync(ctx:h2d.RenderContext) {
		super.sync(ctx);
		if (enabled) update(ctx.elapsedTime);
	}
}


private typedef Property = { x : Float, y :Float, scaleX : Float, scaleY : Float, rotation : Float };
private typedef Keyframe = { time : Int, field : String, added : Bool };