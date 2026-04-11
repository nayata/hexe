package motion.animation;

class Frame {
	public var time:Int = 0;
	public var step:Int = 0;

	public var name:String;
	public var type:String;

	public var ease:String;
	public var speed:Float;
	public var range:Float;

	public var start:Float;
	public var end:Float;

	public var from:Float;
	public var to:Float;

	public function new() {}

	public function serialize():Dynamic {
		var data:Dynamic = {};

		data.name = name;
		data.type = type;

		if (ease != "linear") data.ease = ease;

		data.from = from;
		data.to = to;

		data.start = start;
		data.end = end;

		return data;
	}
}