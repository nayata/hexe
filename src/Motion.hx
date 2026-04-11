import h2d.Object;
import h2d.Bitmap;
import hxd.Event;

import motion.Animation;
import motion.Timeline;
import motion.Tracker;
import motion.Liner;

import motion.dopesheet.Channel;
import motion.animation.Easing;
import motion.animation.Frame;

import motion.Control;
import motion.Context;

import motion.Quantize;

import ui.Touch;
import ui.Icon;


class Motion extends h2d.Object {
	var editor:Editor;

	var clipboard:Array<Frame> = [];

	var touch:Touch;
	var scroller:h2d.Mask;
	var view:h2d.Object;
	
	var panel:h2d.Bitmap;
	var grip:h2d.Bitmap;

	var timeline:Timeline;
	var tracker:Tracker;
	var channel:Channel;
	var liner:Liner;

	var control:Control;
	var dragger:Dragger;
	var toggle:Icon;

	public var animation:Animation;

	public var frameDuration:Int = 60;
	public var duration:Float = 2;
	public var speed:Float = 1.0;
	public var loop:Bool = true;

	public var playing = false;
	public var time:Float = 0;
	public var frame:Int = 0;

	public var context:Context;

	public var width:Int = 1300;
	public var height:Int = 316;

	public var enabled = false;

	var padding = 38;
	var indent = 320;
	var offset = 16;
	var size = 316;

	var clickTime:Int = -1;
	

	public function new(?parent:h2d.Object) {
		super(parent);

		editor = Editor.ME;

		touch = new Touch(width, height, this);
		touch.onPush = onDown;
		touch.onRelease = onUp;
		touch.onMove = onMove;
		touch.onWheel = onWheel;
		touch.y = padding;

		panel = new h2d.Bitmap(h2d.Tile.fromColor(Style.panel, width, height), this);
		panel.smooth = false;

		grip = new h2d.Bitmap(h2d.Tile.fromColor(Style.border, 4, height), this);

		dragger = new Dragger(width, 20, this);
		dragger.onPush = onDragger;
		dragger.y = -10;

		control = new Control(this);
		control.x = width * 0.5 - control.width * 0.5;
		control.y = 25 - control.height * 0.5;

		control.play.onClick = play;

		control.prev.onClick = prev;
		control.next.onClick = next;

		control.first.onClick = first;
		control.last.onClick = last;
		
		var label = new property.component.Label("Animation Timeline", 70, 24, this);

		var menu = new Icon("menu", this);
		menu.onClick = function() { context.settings.open(); };
		menu.setSize(40, 48);
		menu.x = 20;

		toggle = new Icon("toggle", this);
		toggle.onClick = onToggle;
		toggle.setSize(60, 48);
		toggle.x = width - toggle.width;

		scroller = new h2d.Mask(width - indent, height, this);
		scroller.y = padding;

		view = new Object(scroller);
		view.x = 20;

		animation = new Animation(editor.children);

		liner = new Liner(view);
		liner.y = 65;

		timeline = new Timeline(view);

		tracker = new Tracker(view);
		tracker.timeline = animation.timeline;
		tracker.liner = liner;
		tracker.y = 50;

		channel = new Channel(this);
		channel.animation = animation;
		channel.y = scroller.y + tracker.y;

		context = new Context(editor.s2d);

		visible = false;
	}


	/* ------------------------------ Animation control ------------------------------ */

	public function play() {
		playing = !playing;
		if (playing && time >= duration) time = 0;

		if (!playing) {
			frame = Quantize.time(time);
			time = Quantize.frame(frame);

			onUpdate();
		}

		control.play.icon = playing ? "pause" : "play";
	}


	function prev() {
		playing = false;
		frame = Quantize.time(time) - 1;
		frame = frame < 0 ? 0 : frame;
		time = Quantize.frame(frame);
		onUpdate();
	}


	function next() {
		playing = false;
		frame = Quantize.time(time) + 1;
		frame = frame > frameDuration ? frameDuration : frame;
		time = Quantize.frame(frame);
		onUpdate();
	}


	function first() {
		playing = false;
		frame = 0;
		time = 0;
		onUpdate();
	}


	function last() {
		playing = false;
		frame = Quantize.time(duration);
		time = Quantize.frame(frame);
		onUpdate();
	}


	// Animation playing
	public function update(delta:Float) {
		if (playing) {
			time += delta * speed;
			frame = Quantize.time(time);

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
		time = timeline.getTime(value);
		frame = Quantize.time(time);

		onUpdate();
	}


	function onUpdate() {
		animation.timeline.update(time);
		timeline.update(time);

		var name = editor.selected != null ? editor.selected.name : "";
		channel.update(name, frame);

		editor.property.onChange();
		editor.control.onChange();
	}


	/* ------------------------------ Object actions ------------------------------ */

	public function select(object:h2d.Object) {
		if (!enabled) return;

		channel.select(object.name, frame);
		tracker.select(object.name);
	}


	public function unselect() {
		if (!enabled) return;
		
		tracker.unselect();
		channel.unselect();
	}


	public function delete(object:h2d.Object) {
		if (!enabled) return;

		animation.delete(object.name);
		tracker.unselect();
		channel.unselect();
	}


	// Add animation [called from File.hx]
	public function add(name:String, type:String, ease:String, data:Float, time:Float) {
		var frame = Quantize.time(time);

		if (type != "event") animation.timeline.add(name, type, ease, data, frame);
		if (type == "event") animation.event(name, frame);

		animation.update();
	}


	// Has animation for 'name' object [called from File.hx]
	public function has(name:String):Bool {
		return editor.children.exists(name);
	}


	// Object Transform
	public function onTransform(object:h2d.Object, from:Property, to:Property) {
		if (!enabled) return;
		
		var history:Array<Keyframe> = [];

		if (from.x != to.x) {
			var added = animation.set(object.name, "x", to.x, frame);
			history.push({ time : frame, field : "x", from : from.x, to : to.x, added : added });
		}
		if (from.y != to.y) {
			var added = animation.set(object.name, "y", to.y, frame);
			history.push({ time : frame, field : "y", from : from.y, to : to.y, added : added });
		}

		if (from.scaleX != to.scaleX) {
			var added = animation.set(object.name, "scaleX", to.scaleX, frame);
			history.push({ time : frame, field : "scaleX", from : from.scaleX, to : to.scaleX, added : added });
		}
		if (from.scaleY != to.scaleY) {
			var added = animation.set(object.name, "scaleY", to.scaleY, frame);
			history.push({ time : frame, field : "scaleY", from : from.scaleY, to : to.scaleY, added : added });
		}

		if (from.rotation != to.rotation) {
			var added = animation.set(object.name, "rotation", to.rotation, frame);
			history.push({ time : frame, field : "rotation", from : from.rotation, to : to.rotation, added : added });
		}

		editor.history.append(new History.Key(object, history));

		channel.select(object.name, frame);
		tracker.select(object.name);
	}


	// Object Property
	public function onProperty(object:h2d.Object, type:String, from:Float, to:Float) {
		if (!enabled) return;

		var added = animation.set(object.name, type, to, frame);

		var history:Array<Keyframe> = [{ time : frame, field : type, from : from, to : to, added : added }];
		editor.history.append(new History.Key(object, history));

		channel.select(object.name, frame);
		tracker.select(object.name);
	}


	public function onHistory(position:Int) {
		frame = position;
		time = Quantize.frame(frame);
		onUpdate();
	}


	public function onEvent() {
		tracker.onEvent();
	}


	/* ------------------------------ Keyframe actions ------------------------------ */

	// Add key to `type` channel, e.g.(object, "x", object.value, currentFrame) [called from Channel.hx]
	public function set(type:String) {
		if (editor.selected == null) return;

		var exist = animation.find(getName(), type, frame);
		
		if (exist != null) return;

		animation.set(editor.selected.name, type, Reflect.field(editor.selected, type), frame);
		channel.select(editor.selected.name, frame);
		tracker.select(editor.selected.name);

		var history = new History.Set(editor.selected.name, type, Reflect.field(editor.selected, type), frame);
		editor.history.add(new History.Edit(editor.selected.name, [history]));
	}


	public function event(type:String) {
		var exist = animation.find("", "event", frame);
		var event = exist != null ? exist.name : name;
		
		var added = animation.event(type, frame);

		var history = new History.Event(type, event, added ? "add" : "set", frame);
		editor.history.add(new History.Edit(name, [history]));

		channel.update(getName(), frame);
		tracker.onEvent();
	}


	// Add, Select or Delete keys
	public function onKeyframe(type:String, ?name:String) {
		switch (type) {
			case "add" if (editor.selected != null) :
				set(name);

			case "select":
				tracker.selectAll();

			case "delete" if (tracker.selected.length > 0) :
				var history:Array<History.Element> = [];

				for (keyframe in tracker.selected) {
					if (keyframe.type == "event") history.push(new History.Event(keyframe.name, "", "delete", keyframe.time));
					if (keyframe.type != "event") history.push(new History.Clear(getName(), keyframe.type, keyframe.ease, keyframe.from, keyframe.time));

					animation.remove(keyframe);
				}

				editor.history.add(new History.Edit(getName(), history));

				animation.update();
				channel.select(getName(), frame);
				tracker.select(getName());

			default:
		}
	}


	// Set selected key easing
	public function setEase(type:String, name:String) {
		if (editor.selected == null) return;

		var history:Array<History.Element> = [];

		if (tracker.selected.length == 0) {
			var keyframe = animation.find(editor.selected.name, name, frame);

			if (keyframe == null) return;

			history.push(new History.Ease(editor.selected.name, keyframe.type, keyframe.ease, type, keyframe.time));
			keyframe.ease = type;
		}

		for (keyframe in tracker.selected) {
			history.push(new History.Ease(editor.selected.name, keyframe.type, keyframe.ease, type, keyframe.time));
			keyframe.ease = type;
		}

		editor.history.add(new History.Edit(editor.selected.name, history));
		channel.select(editor.selected.name, frame);
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

				editor.history.add(new History.Edit(name, history));

				animation.update();
				channel.select(name, frame);
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

				editor.history.add(new History.Edit(name, history));

				animation.update();
				channel.select(name, frame);
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

			position = timeline.getFrame(event.relX - view.x);

			if (event.relY <= 40) tracking = true;

			touch.left = true;
		}

		if (event.button == 1) {
			clickTime = hxd.Timer.frameCount;

			touch.position.x = editor.s2d.mouseX - view.x;
			touch.right = true;
		}

		// Move on timeline
		if (touch.left && tracking) {
			// Force blur to focused input
			@:privateAccess editor.s2d.events.blur();
			advance(event.relX - view.x);
		}

		
		// Key selection
		if (touch.left && tracking) return;
		if (touch.right) return;

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
				if (frame.time >= max) max = frame.time;
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
			var current = timeline.getFrame(event.relX - view.x);
			var diff:Int = current - position;

			if (diff < -min) diff = -min;
			if (max + diff > duration * 30) diff = Std.int(duration * 30 - max);


			// Update Key time & update Traker keys
			for (frame in tracker.selected) {
				frame.time = frame.step + diff;
				
				var keyframe = tracker.getKey(frame);
				
				keyframe.x = Quantize.frame(frame.time) * timeline.scaling;
				keyframe.time = frame.time;
			}

			liner.update();
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
			var changed = Math.abs(position - timeline.getFrame(event.relX - view.x)) > 0;

			// Move to time if nothing dragged
			if (!changed) advance(event.relX - view.x);

			// Update animation if key dragged
			if (changed) {
				var history:Array<History.Element> = [];

				for (frame in tracker.selected) {
					history.push(new History.Time(getName(), frame.type, frame.step, frame.time));
				}

				editor.history.add(new History.Edit(getName(), history));
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
			view.x = Math.round(view.x);

			var current = Math.abs(clickTime - hxd.Timer.frameCount);
			if (current < 20) {
				var type = tracker.getType(event.relY - tracker.y);
				context.edit.open(type);
			}
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
		time = Quantize.frame(frame);

		onUpdate();
	}


	/* ------------------------------ Serialize ------------------------------ */

	public function serialize():Dynamic {
		var data = [];

		for (frame in animation.timeline.frame) {
			if (has(frame.name)) data.push(frame.serialize());
		}

		return data;
	}


	/* ------------------------------ Animation Mode ------------------------------ */

	public function onDuration(value:Float) {
		value = Math.max(value, 0);

		frameDuration = Std.int(value);
		duration = Quantize.frame(value);
		timeline.duration = duration;
	}


	public function onAnimation(mode:Bool = false) {
		clear();

		enabled = mode;
		visible = mode;

		context.settings.update();

		editor.property.onScene();
		editor.onAnimation();
	}


	public function onScene() {
		frameDuration = Quantize.time(duration);
		duration = Quantize.frame(frameDuration);
		timeline.duration = duration;

		enabled = true;
		visible = true;
		
		context.settings.update();
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

		channel.animation = animation;
		channel.unselect();
		
		frameDuration = 60;
		duration = 2;

		timeline.duration = duration;
		timeline.update(time);

		loop = true;
		speed = 1;
		
		enabled = false;
		visible = false;

		editor.onAnimation();
	}


	function onToggle() {
		height = height != 45 ? 45 : size;

		toggle.image.scaleY = height != size ? -1 : 1;

		editor.onAnimation();
		onResize();
	}


	function onDragger(event:hxd.Event) {
		dragger.dragStart = editor.s2d.mouseY - y;

		var max = editor.HEIGHT - size;
		var min = editor.HEIGHT - 45;

		dragger.startCapture(function(event) {
			switch(event.kind) {
				case EPush:
				case EMove:
					dragger.dragOffset = editor.s2d.mouseY - dragger.dragStart;

					if (dragger.dragOffset >= min) dragger.dragOffset = min;
					if (dragger.dragOffset <= max) dragger.dragOffset = max;

					height = Std.int(editor.HEIGHT - dragger.dragOffset);

					editor.onAnimation();
					onResize();
	
				case ERelease, EReleaseOutside:
					editor.s2d.stopCapture();
				default:
			}
			
			event.propagate = false;
		});
	}


	public function onResize() {
		panel.width = width;
		panel.height = height;

		touch.width = width - indent;
		touch.x = indent;

		control.x = width * 0.5 - control.width * 0.5;
		
		scroller.width = width - indent - offset;
		scroller.x = indent;

		dragger.width = width;

		toggle.x = width - toggle.width;
		grip.x = width - 4;
	}


	override function sync(ctx:h2d.RenderContext) {
		super.sync(ctx);
		if (enabled) update(ctx.elapsedTime);
	}
}


private typedef Property = { x : Float, y :Float, scaleX : Float, scaleY : Float, rotation : Float };
private typedef Keyframe = { time : Int, field : String, from : Float, to : Float, added : Bool };


class Dragger extends h2d.Interactive {
	public var dragStart:Float = 0;
	public var dragOffset:Float = 0;
}