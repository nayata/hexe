package motion;

import ui.Icon;

class Control extends h2d.Object {
	public var play:Icon;

	public var first:Icon;
	public var last:Icon;

	public var next:Icon;
	public var prev:Icon;

	public var width:Float = 40;
	public var height:Float = 40;
	public var size:Float = 40;


	public function new(?parent:h2d.Object) {
		super(parent);

		first = new Icon("first", this);
		first.setSize(size, height);

		prev = new Icon("prev", this);
		prev.setSize(size, height);
		prev.x = size;

		play = new Icon("play", this);
		play.setSize(size, height);
		play.x = size * 2;

		next = new Icon("next", this);
		next.setSize(size, height);
		next.x = size * 3;

		last = new Icon("last", this);
		last.setSize(size, height);
		last.x = size * 4;

		width = size * 5;
	}
}