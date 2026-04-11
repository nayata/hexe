package motion.dopesheet;

class Track extends h2d.Object {
	public var keyframe:Array<Marker> = [];
	
	var maximum:Int = 128;
	var index:Int = 0;


	public function new(color:Int = 0x00c3ff, position:Int = 0, ?parent:h2d.Object) {
		super(parent);

		for (i in 0...maximum) {
			var key = new Marker(color, position, this);

			key.visible = false;
			key.y = 15;
		
			keyframe.push(key);
		}

		y = position;
	}


	public function get():Marker {
		return keyframe[index++];
	}


	public function clear() {
		for (key in keyframe) {
			key.visible = false;
			key.unselect();

			key.frame = null;
			key.time = -1;
		}

		index = 0;
	}
}


class Marker extends h2d.Object {
	public var frame:motion.animation.Frame;
	public var track:Int = -1;
	public var time:Int = -1;

	var selected = false;
	var shade = 0x00c3ff;

	var icon:h2d.Bitmap;


	public function new(color:Int, channel:Int = 0, ?parent:h2d.Object) {
		super(parent);
		
		track = channel;
		shade = color;

		icon = new h2d.Bitmap(Assets.icon("key"), this);
		icon.tile.setCenterRatio();

		Assets.colorize(icon, shade);
	}

	
	public function select() {
		if (selected) return;
		
		Assets.colorize(icon, 0xfffb00);
		selected = true;
	}


	public function unselect() {
		if (!selected) return;

		Assets.colorize(icon, shade);
		selected = false;
	}
}