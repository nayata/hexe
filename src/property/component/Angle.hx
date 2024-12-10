package property.component;


class Angle extends TextField {
	public var step:Float = 1;

	var time:Int = -1;
	var undo:Float = 0;


	override function onInput() {
		var val = Std.parseFloat(input.text);

		if (Math.isNaN(val) || !Math.isFinite(val)) {
			val = undo;
		}
		else {
			onUpdate({ field : field, to : hxd.Math.degToRad(val) });
		}
	}


	override function onWheel(event:hxd.Event) {
		if (hxd.Timer.frameCount - time < 2) {
			var val = Std.parseFloat(input.text);
			val = event.wheelDelta > 0 ? val - step : val + step;

			input.text = Std.string(val);

			onUpdate({ field : field, to : hxd.Math.degToRad(val) });
		}

		time = hxd.Timer.frameCount;
	}


	override function onFocusLost(event:hxd.Event) {
		super.onFocusLost(event);

		var val = Std.parseFloat(input.text);
		onChange({ field : field, from : undo, to :  hxd.Math.degToRad(val) });
	}


	override public function blur() {
		if (input.hasFocus()) onChange({ field : field, from : undo, to : hxd.Math.degToRad(Std.parseFloat(input.text)) });
	}


	override function set_value(v) {
		undo = Std.parseFloat(v);

		var val = hxd.Math.radToDeg(undo);
		val = hxd.Math.round(val);

		input.text = Std.string(val);
		return v;
	}
}