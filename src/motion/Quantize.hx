package motion;

class Quantize {
	public static function time(value:Float):Int {
		value = Math.round((value * 30) / 1) * 1;
		return Std.int(value);
	}

	public static function frame(fraction:Float):Float {
		var value = fraction / 30;

		value = Math.round(value / 0.03333) * 0.03333;
		value = Math.round(value / 0.001) * 0.001;

		return value;
	}
}