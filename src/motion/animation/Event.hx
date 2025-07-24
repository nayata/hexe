package motion.animation;

class Event extends Frame {
	override public function serialize():Dynamic {
		var data:Dynamic = {};

		data.name = name;
		data.start = start;

		return data;
	}
}