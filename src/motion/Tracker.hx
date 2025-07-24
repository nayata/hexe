package motion;

import motion.dopesheet.Track;
import motion.animation.Timeline;
import motion.animation.Frame;


class Tracker extends h2d.Object {
	public var channel:Map<String, Track> = new Map();
	public var timeline:Timeline;

	public var selected:Array<Frame> = [];
	public var scaling:Float = 256;

	var highlight:h2d.Bitmap;
	var height = 26;

	
	public function new(parent:h2d.Object) {
		super(parent);

		highlight = new h2d.Bitmap(h2d.Tile.fromColor(Style.hover, 10, 10), this);
		highlight.visible = false;
		highlight.smooth = false;
		highlight.alpha = 0.5;

		channel.set("event", new Track(0xdb1a40, this));

		channel.set("x", new Track(this));
		channel.set("y", new Track(this));

		channel.set("scaleX", new Track(this));
		channel.set("scaleY", new Track(this));

		channel.set("rotation", new Track(this));
		channel.set("alpha", new Track(this));


		channel["x"].y = 0;
		channel["y"].y = height;

		channel["scaleX"].y = height * 2;
		channel["scaleY"].y = height * 3;

		channel["rotation"].y = height * 4;
		channel["alpha"].y = height * 5;

		channel["event"].y = -39;
	}

	
	public function select(name:String) {
		unselect();

		for (frame in timeline.frame) {
			if (frame.name == name) {
				var keyframe = channel[frame.type].get();
				
				keyframe.time = frame.time;
				keyframe.frame = frame;

				keyframe.x = frame.start * scaling;
				keyframe.visible = true;
			}
		}
	}


	public function onEvent() {
		channel["event"].clear();

		for (frame in timeline.event) {
			var keyframe = channel["event"].get();
				
			keyframe.time = frame.time;
			keyframe.frame = frame;

			keyframe.x = frame.start * scaling;
			keyframe.visible = true;
		}
	}


	public function unselect() {
		selected = [];
		
		for (track in channel) {
			track.clear();
		}
		onEvent();
	}


	public function getType(y:Float):String {
		for (name => element in channel) {
			if (y > element.y && y < element.y + height) return name;
		}

		return "empty";
	}


	public function getKey(frame:Frame) {
		for (track in channel) {
			for (keyframe in track.keyframe) {
				if (keyframe.frame == null) continue;
				if (keyframe.frame == frame) return keyframe;
			}
		}

		return null;
	}


	public function onSelect(x:Float, y:Float, w:Float, h:Float) {
		highlight.visible = true;

		highlight.x = x;
		highlight.y = y;

		highlight.width = Math.abs(w-x);
		highlight.height = Math.abs(h-y);

		highlight.scaleX = w < x ? -1 : 1;
		highlight.scaleY = h < y ? -1 : 1;
	}


	public function selectKey(x:Float, y:Float, w:Float, h:Float) {
		var minX = w < x ? w : x;
		var minY = h < y ? h : y;

		var maxX = w < x ? x : w;
		var maxY = h < y ? y : h;

		for (track in channel) {
			for (keyframe in track.keyframe) {
				if (keyframe.frame == null) continue;

				if (keyframe.x >= minX && keyframe.x <= maxX) {
					if (track.y + 10 > minY && track.y + 20 < maxY) {
						selected.push(keyframe.frame);
						keyframe.select();
					}
				}
			}
		}

		highlight.visible = false;
	}


	public function selectAll() {
		for (track in channel) {
			for (keyframe in track.keyframe) {
				if (keyframe.frame == null) continue;
				selected.push(keyframe.frame);
				keyframe.select();
			}
		}
	}


	public function clearKey() {
		selected = [];
		
		for (track in channel) {
			for (keyframe in track.keyframe) {
				if (keyframe.frame != null) keyframe.unselect();
			}
		}
	}


	public function onResize() {
		for (track in channel) {
			for (keyframe in track.keyframe) {
				if (keyframe.frame != null) keyframe.x = keyframe.frame.start * scaling;
			}
		}
	}
}