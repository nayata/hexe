package motion.animation;

class Timeline {
	public var hierarchy:Map<String, prefab.Prefab>;

	public var frame:Array<Frame> = [];
	public var event:Array<Frame> = [];


	public function new() {}


	public function update(time:Float) {
		for (key in frame) {
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
	}


	inline function apply(name:String, type:String, value:Float) {
		var object = hierarchy.get(name).object;

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


	public function add(name:String, type:String, ease:String, value:Float, time:Int):Frame {
		var key = new Frame();

		key.name = name;
		key.type = type;

		key.time = time;
		key.step = time;

		key.ease = ease ?? "linear";
		key.speed = 0;
		key.range = 0;

		key.start = 0;
		key.end = 0;
		
		key.from = value;
		key.to = value;

		frame.push(key);

		return key;
	}
}