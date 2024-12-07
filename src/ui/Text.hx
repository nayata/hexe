package ui;


class Text extends h2d.Object {
	public var text(get, set):String;
	var label:h2d.Text;


	public function new(text:String = "", x:Float = 0, y:Float = 0, ?parent:h2d.Object) {
		super(parent);

		label = new h2d.Text(Assets.mediumFont, this);
		label.textColor = Style.title;
		label.textAlign = h2d.Text.Align.Left;
		label.smooth = true;
		label.text = text;

		this.x = x;
		this.y = y;
	}


	function get_text():String {
		return label.text;
	}


	function set_text(t:String) {
		label.text = t;
		return t;
	}
}