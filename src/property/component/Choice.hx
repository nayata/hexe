package property.component;


class Choice extends Input {
	public var input:h2d.Interactive;

	var items:Array<Element> = [];
	var selected:Element = null;

	var undo:Dynamic = null;


	public function new(?parent:h2d.Object) {
		super(parent);

		input = new h2d.Interactive(0, 0, this);
		input.cursor = Default;

		input.onClick = onClick;
		input.onMove = onMove;
		input.onOver = onOver;
		input.onOut = onOut;
	}


	function onClick(event:hxd.Event) {
		if (selected != null) {
			onChange({ field : field, from : undo, to : selected.value });
		}
	}


	function onMove(event:hxd.Event) {
		selected = null;

		var mouse = new h2d.col.Point(event.relX, event.relY);
		for (node in items) {
			if (mouse.x > node.x && mouse.x < node.x + node.width && mouse.y > node.y && mouse.y < node.y + node.height) {
				selected = node;
			}
		}
	}


	function onOver(event:hxd.Event) {
	}


	function onOut(event:hxd.Event) {
		close();
	}


	function close() {
	}


	override function set_value(v) {
		undo = v;
		return v;
	}
}