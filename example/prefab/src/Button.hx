class Button extends hxe.Prefab {
	var over:h2d.Object;
	var input:h2d.Interactive;
	var label:h2d.Text;

	public var text(default, set):String = "text"; 
	

	override function init() {
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
	}

	function onOut(e:hxd.Event) {
		over.visible = false;
	}
}