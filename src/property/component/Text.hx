package property.component;


class Text extends TextField {
	var undo:String = "";


	override function onInput() {
		onUpdate({ field : field, to : input.text });
	}


	override function onFocusLost(event:hxd.Event) {
		super.onFocusLost(event);
		onChange({ field : field, from : undo, to :  input.text });
	}


	override public function blur() {
		if (input.hasFocus()) onChange({ field : field, from : undo, to : input.text });
	}


	override function set_value(v) {
		undo = v;
		input.text = v;
		return v;
	}
}