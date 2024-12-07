class Button extends h2d.Object {
	var over:h2d.Bitmap;
	var input:h2d.Interactive;
	var label:h2d.Text;

	public var text(default, set):String = "text"; 
	

	public function new(?parent:h2d.Object) {
		super(parent);

		hxe.Lib.bind("button", this);
		
		input.onClick = function(e:hxd.Event) { onClick(); };
		input.onOver = onOver;
		input.onOut = onOut;
	}


	public dynamic function onClick() {}


	function set_text(v) {
		return text = label.text = v;
	}


	function onOver(e:hxd.Event) {
		over.visible = true;
		label.textColor = 0x333333;
	}

	function onOut(e:hxd.Event) {
		over.visible = false;
		label.textColor = 0xffffff;
	}
}