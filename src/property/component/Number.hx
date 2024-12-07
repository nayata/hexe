package property.component;


class Number extends TextField {
	public var step:Int = 1;
	public var min:Int = 0;
	public var max:Int = 1;

	var time:Int = -1;
	var undo:Int = 0;


	override function onInput() {
		var val = Std.parseInt(input.text);

		if (Math.isNaN(val) || !Math.isFinite(val) || val == null) {
			val = undo;
		}
		else {
			onUpdate({ field : field, to : val });
		}
	}


	override function onWheel(event:hxd.Event) {
		if (hxd.Timer.frameCount - time < 2) {
			var val = Std.parseInt(input.text);
			val = event.wheelDelta > 0 ? val - step : val + step;

			input.text = Std.string(val);

			onUpdate({ field : field, to : val });
		}

		time = hxd.Timer.frameCount;
	}


	override function onFocusLost(event:hxd.Event) {
		super.onFocusLost(event);
		
		var val = Std.parseInt(input.text);
		onChange({ field : field, from : undo, to : val });
	}


	override public function blur() {
		if (input.hasFocus()) onChange({ field : field, from : undo, to : Std.parseInt(input.text) });
	}


	override function set_value(v) {
		undo = Std.parseInt(v);
		input.text = v;
		return v;
	}
}