package ui;

import h2d.col.Point;
import ui.Touch;


class Touch extends h2d.Interactive {
	public var position:Point = new Point();

	public var left:Bool = false;
	public var right:Bool = false;

	
	public function new(width, height, ?parent) {
		super(width, height, parent);

		enableRightButton = true;
		cursor = null;
	}
}