package property.component;


class FloatNumber extends TextField {
	public var step:Float = 0.1;
	public var min:Int = 0;
	public var max:Int = 1;

	var time:Int = -1;
	var undo:Float = 0;


	override function onInput() {
		var val = Std.parseFloat(input.text);

		if (Math.isNaN(val) || !Math.isFinite(val)) {
			val = undo;
		}
		else {
			onUpdate({ field : field, to : val });
		}
	}


	override function onWheel(event:hxd.Event) {
		if (hxd.Timer.frameCount - time < 2) {
			var val = Std.parseFloat(input.text);
			val = event.wheelDelta > 0 ? val - step : val + step;

			input.text = Std.string(val);

			onUpdate({ field : field, to : val });
		}

		time = hxd.Timer.frameCount;
	}


	override function onFocusLost(event:hxd.Event) {
		super.onFocusLost(event);

		var val = Std.parseFloat(input.text);
		onChange({ field : field, from : undo, to : val });
	}


	override public function blur() {
		if (input.hasFocus()) onChange({ field : field, from : undo, to : Std.parseFloat(input.text) });
	}


	override function set_value(v) {
		undo = Std.parseFloat(v);
		input.text = v;
		return v;
	}
}