package motion.dopesheet;

class Track extends h2d.Object {
	public var keyframe:Array<Marker> = [];
	
	var maximum:Int = 128;
	var index:Int = 0;
	

	public function new(color:Int = 0x00c3ff, ?parent:h2d.Object) {
		super(parent);

		for (i in 0...maximum) {
			var key = new Marker(color, this);

			key.visible = false;
			key.y = 15;
		
			keyframe.push(key);
		}
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


class Marker extends h2d.Graphics {
	public var frame:motion.animation.Frame;
	public var time:Int = -1;

	var selected = false;
	var shade = 0x00c3ff;


	public function new(color:Int, ?parent:h2d.Object) {
		super(parent);
		
		this.shade = color;

		beginFill(shade);
		drawEllipse(0, 0, 6, 6, 0, 4);
		endFill();
	}

	
	public function select() {
		if (selected) return;
		
		clear();
		beginFill(0xfffb00);
		drawEllipse(0, 0, 6, 6, 0, 4);
		endFill();

		selected = true;
	}


	public function unselect() {
		if (!selected) return;

		clear();
		beginFill(shade);
		drawEllipse(0, 0, 6, 6, 0, 4);
		endFill();

		selected = false;
	}
}