package motion;

import motion.animation.Easing;
import motion.animation.Timeline;
import motion.animation.Frame;
import motion.animation.Event;

import prefab.Prefab;


class Animation {
	public var timeline:Timeline = null;

	public function new(prefab:Map<String, Prefab>) {
		timeline = new Timeline();
		timeline.hierarchy = prefab;
	}


	public function set(name:String, type:String, data:Float, time:Int):Bool {
		var frame = find(name, type, time);
		var added = false;

		if (frame != null) {
			frame.from = data;
			frame.to = data;
		}

		if (frame == null) {
			frame = timeline.add(name, type, "linear", data, time);
			added = true;
		}

		timeline.frame.sort(cmp);

		for (key in timeline.frame) {
			if (key.type == type) calculate(key);
		}

		return added;
	}


	public function event(name:String, time:Int):Bool {
		var event = find(name, "event", time);
		var added = false;

		if (event == null) {
			event = new Event();

			event.type = "event";
			event.start = getTime(time);
	
			timeline.event.push(event);
			added = true;
		}

		event.name = name;
		event.time = time;
		event.step = time;

		return added;
	}


	public function ease(name:String, type:String, data:String, time:Int) {
		var frame = find(name, type, time);
		if (frame != null) frame.ease = data;
	}


	public function move(name:String, type:String, from:Int, to:Int) {
		var frame = find(name, type, from);
		if (frame != null) frame.time = to;
	}


	public function clear(name:String, type:String, time:Int) {
		var frame = find(name, type, time);
		if (frame != null) remove(frame);
	}


	public function clearAt(name:String, time:Int) {
		var index = timeline.frame.length - 1;

		while (index >= 0) {
			var frame = timeline.frame[index];
			if (frame.name == name && frame.time == time) {
				timeline.frame.remove(frame);
			}
			index--;
		}
	}


	public function delete(name:String) {
		var index = timeline.frame.length - 1;

		while (index >= 0) {
			var frame = timeline.frame[index];
			if (frame.name == name) {
				timeline.frame.remove(frame);
			}
			index--;
		}
	}


	public function remove(frame:Frame) {
		if (frame.type == "event") timeline.event.remove(frame);
		if (frame.type != "event") timeline.frame.remove(frame);
	}


	public function update() {
		timeline.frame.sort(cmp);

		for (frame in timeline.frame) {
			calculate(frame);
		}
		for (frame in timeline.event) {
			calculate(frame);
		}
	}


	public function calculate(frame:Frame) {
		var key = next(frame);

		if (key == null) {
			frame.step = frame.time;

			frame.to = frame.from;

			frame.start = getTime(frame.time);
			frame.end = getTime(frame.time);
			
			frame.speed = 1 / (frame.end - frame.start);
			frame.range = frame.to - frame.from;
		}

		if (key != null) {
			frame.step = frame.time;
			
			frame.start = getTime(frame.time);
			frame.end = getTime(key.time);
			
			frame.to = key.from;

			frame.speed = 1 / (frame.end - frame.start);
			frame.range = frame.to - frame.from;
		}
	}


	public function next(frame:Frame):Null<Frame> {
		if (frame.type == "event") return null;

		var index = timeline.frame.indexOf(frame) + 1;

		for (i in index...timeline.frame.length) {
			var key = timeline.frame[i];
			if (key.name == frame.name && key.type == frame.type) {
				return(key);
			}
		}

		return null;
	}


	public function find(name:String, type:String, time:Int):Null<Frame> {
		for (frame in timeline.frame) {
			if (frame.name == name && frame.type == type && frame.time == time) {
				return(frame);
			}
		}

		for (frame in timeline.event) {
			if (frame.type == type && frame.time == time) {
				return(frame);
			}
		}

		return null;
	}


	function getTime(fraction:Int):Float {
		var value = fraction / 30;

		value = snap(value, 0.03333);
		value = snap(value, 0.001);

		return value;
	}


	function snap(value:Float, fraction:Float) {
		return Math.round(value / fraction) * fraction;
	}


	static inline function cmp(a:Frame, b:Frame):Int {
		if (a.time < b.time) return -1;
		if (a.time > b.time) return 1;
		return 0;
	}
}