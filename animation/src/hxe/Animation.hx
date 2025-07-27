package hxe;

class Animation extends Prefab {
	public var childrens:Map<String, h2d.Object> = new Map();
	public var animation:Timeline;

	public var playing:Bool = false;
	public var pause:Bool = false;
	public var time:Float = 0;


	public function update(dt:Float) {
		if (pause) return;

		time += dt * animation.speed;

		for (key in animation.frame) {
			if (time < key.start || time > key.end + 0.01667) continue;

			var step = key.speed * (time - key.start);
			var ease = easing(key.ease, step);
		
			if (step < 1) {
				apply(key.name, key.type, key.from + ease * key.range);
			}
			else {
				apply(key.name, key.type, key.to);
			}
		}
		for (event in animation.event) {
			if (time >= event.start && !event.done) {
				onEvent(event.name);
				event.done = true;
			}
		}

		if (time >= animation.duration) {
			if (!animation.loop) playing = false;

			if (animation.loop) {
				for (event in animation.event) event.done = false;
				time = 0;
			}

			onEnd();
		}
	}


	inline function apply(name:String, type:String, value:Float) {
		var object = childrens.get(name);

		switch (type) {
			case "x": object.x = value;
			case "y": object.y = value;
			case "scaleX": object.scaleX = value;
			case "scaleY": object.scaleY = value;
			case "rotation": object.rotation = value;
			case "alpha": object.alpha = value;
			default:
		}
	}


	function easing(type:String, step:Float):Float {
		if (type == "linear") return step;
		var ease = Easing.get(type);
		return ease(step);
	}


	public dynamic function onEvent(event:String) {}
	public dynamic function onEnd() {}


	override function sync(ctx:h2d.RenderContext) {
		super.sync(ctx);
		if (playing) update(ctx.elapsedTime);
	}
}


class Timeline {
	public var duration:Float = 1;
	public var speed:Float = 1.0;
	public var loop:Bool = true;

	public var frame:Array<Frame> = [];
	public var event:Array<Frame> = [];

	public function new() {}
}


class Frame {
	public var name:String;
	public var type:String;

	public var data:String;
	public var done:Bool = false;

	public var ease:String;
	public var speed:Float;
	public var range:Float;

	public var start:Float;
	public var end:Float;

	public var from:Float;
	public var to:Float;

	public function new() {}
}