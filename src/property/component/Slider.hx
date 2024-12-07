package property.component;


class Slider extends TextField {
	var slider:h2d.Slider;

	public var step:Float = 0.05;
	public var min:Int = 0;
	public var max:Int = 1;

	var time:Int = -1;
	var undo:Float = 0;


	public function new(?parent:h2d.Object) {
		super(parent);

		setSize(64, 32);

		slider = new h2d.Slider(92, 20, this);

		slider.cursorTile = Assets.icon("slider");
		slider.cursorTile.dy = slider.tile.dy - 5;

		slider.x = -slider.width - 10;
		slider.y = height*0.5 - slider.height*0.5;

		slider.minValue = min;
		slider.maxValue = max;

		slider.onRelease = sliderRelease;
		slider.onChange = onSlider;
	}


	function onSlider() {
		var val = Math.round(slider.value / step) * step;
		input.text = Std.string(val);

		onUpdate({ field : field, to : val });
	}


	function sliderRelease(event:hxd.Event) {
		var val = Std.parseFloat(input.text);
		onChange({ field : field, from : undo, to : val });

		undo = val;
	}


	override function onInput() {
		var val = Std.parseFloat(input.text);

		if (Math.isNaN(val) || !Math.isFinite(val)) {
			slider.value = undo;
			val = undo;
		}
		else {
			val = hxd.Math.clamp(val, min, max);
			slider.value = val;

			onUpdate({ field : field, to : val });
		}
	}


	override function onWheel(event:hxd.Event) {
		if (hxd.Timer.frameCount - time < 2) {
			var val = Std.parseFloat(input.text);
			val = event.wheelDelta > 0 ? val - step : val + step;

			val = hxd.Math.clamp(val, min, max);
			slider.value = val;

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
		slider.value = undo;
		input.text = v;
		return v;
	}
}