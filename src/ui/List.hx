package ui;

class List extends h2d.Object {
	var input:h2d.Interactive;
	var panel:h2d.Object;

	var items:Array<Tab> = [];
	var selected:Tab = null;

	public var width:Float = 80;
	public var height:Float = 30;
	

	public function new(?parent:h2d.Object) {
		super(parent);

		input = new h2d.Interactive(0, 0, this);
		input.onClick = onClick;
		input.cursor = Button;
		input.visible = false;

		panel = new h2d.Object(this);
	}


	public function add(value:String) {
		var item = new Tab(value, panel);
		
		item.x = input.width;

		input.width += item.width;
		input.height = item.height;

		input.visible = items.length > 0;

		items.push(item);
	}


	public function get(name:String) {
		for (node in items) {
			if (node.text == name) return node;
		}
		return null;
	}


	public function set(name:String) {
		if (selected != null && selected.active) selected.active = false;

		for (node in items) {
			if (node.text == name) {
				selected = node;
				selected.active = true;
			}
		}
	}


	public function clear() {
		input.visible = false;
		input.width = 0;

		panel.removeChildren();
		items = [];
	}


	public dynamic function onSelect(value:String) {}


	function onClick(event:hxd.Event) {
		if (selected != null && selected.active) selected.active = false;

		for (node in items) {
			if (event.relX >= node.x && event.relX < node.x + node.width) {
				selected = node;
				selected.active = true;

				onSelect(selected.text);
			}
		}
	}
}


class Tab extends h2d.Object {
	public var label:h2d.Text;

	public var width:Float = 250;
	public var height:Float = 40;

	public var active(default, set):Bool = true;
	public var text(get, set):String;


	public function new(text:String = "", ?parent:h2d.Object) {
		super(parent);

		label = new h2d.Text(Assets.defaultFont, this);
		label.textColor = Style.menu;
		label.textAlign = h2d.Text.Align.Left;
		label.smooth = false;
		label.text = text;

		setSize(label.textWidth + 32, 30);
	}


	public function setSize(w:Float, h:Float) {
		width = w;
		height = h;

		label.x = 16;
		label.y = height*0.5 - label.textHeight*0.5;
	}


	function set_active(v) {
		label.textColor = v ? Style.menu : Style.text;
		return active = v;
	}


	function get_text():String {
		return label.text;
	}


	function set_text(t:String) {
		label.text = t;
		return t;
	}
}