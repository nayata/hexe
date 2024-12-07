package property.component;


class Label extends Input {
	public var text(get, set):String;
	var object:h2d.Text;


	public function new(text:String = "", x:Float, y:Float, ?parent:h2d.Object) {
		super(parent);

		object = new h2d.Text(Assets.defaultFont, this);
		object.textColor = Style.label;
		object.textAlign = h2d.Text.Align.Left;
		object.smooth = true;
		object.text = text;

		this.x = x;
		this.y = y - object.textHeight * 0.5;
	}


	function get_text():String {
		return object.text;
	}


	function set_text(t:String) {
		object.text = t;
		return t;
	}
}