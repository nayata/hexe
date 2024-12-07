package ui;

class Button extends h2d.Object {
	var input:h2d.Interactive;
	var label:h2d.Text;

	public var width:Float = 80;
	public var height:Float = 40;

	public var text(get, set):String;


	public function new(text:String = "", ?parent:h2d.Object) {
		super(parent);

		input = new h2d.Interactive(0, 0, this);
		input.onClick = onClick;
		input.onOver = onOver;
		input.onOut = onOut;
		input.cursor = Default;

		label = new h2d.Text(Assets.defaultFont, this);
		label.textAlign = Center;
		label.textColor = Style.text;
		label.smooth = true;
		label.text = text;

		setSize(110, 40);
	}


	function onClick(event:hxd.Event) {
		onChange();
	}


	public dynamic function onChange() {
	}


	function onOver(e:hxd.Event) {
		label.alpha = 0.75;
	}


	function onOut(e:hxd.Event) {
		label.alpha = 1;
	}


	function get_text():String {
		return label.text;
	}


	function set_text(t:String) {
		label.text = t;
		return t;
	}


	public function setSize(w:Float, h:Float) {
		width = w;
		height = h;

		input.width = width;
		input.height = height;

		label.x = width * 0.5;
		label.y = height * 0.5 - label.textHeight * 0.5;
	}
}