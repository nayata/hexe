package filter;

import property.component.Input;


class Effect {
	var registry:Map<String, Input> = new Map();

	public var prefab:Null<prefab.Prefab> = null;
	public var window:ui.Window;
	public var content:ui.Mask;


	public function new(parent:h2d.Object) {
		window = new ui.Window(parent);

		content = window.content;
		window.content.clip = false;
		
		window.close = close;
	}


	public function init(entry:prefab.Prefab) {}


	public function allowed(entry:prefab.Prefab):Bool {
		return true;
	}


	public function open(?prop:String) {
		window.visible = true;
		window.onResize();
	}


	public function close() {
		window.visible = false;
		prefab = null;
	}
}