package motion.animation;


class Easing {
	public static inline var LINEAR:String = "linear";
	public static inline var STEPPED:String = "stepped";

	public static inline var EASE_IN:String = "easeIn";
	public static inline var EASE_OUT:String = "easeOut";
	public static inline var EASE_IN_OUT:String = "easeInOut";

	public static inline var BACK_IN:String = "backIn";
	public static inline var BACK_OUT:String = "backOut";
	public static inline var BACK_IN_OUT:String = "backInOut";

	public static inline var ELASTIC:String = "elastic";
	public static inline var BOUNCE:String = "bounce";

	static var library:Map<String, Float->Float>;


	public static function get(name:String):Float->Float {
		if (library == null) registerDefaults();
		return library[name];
	}
	
	public static function set(name:String, func:Float->Float) {
		if (library == null) registerDefaults();
		library[name] = func;
	}
	
	static function registerDefaults() {
		library = new Map<String, Float->Float>();

		set(LINEAR, linear);
		set(STEPPED, stepped);

		set(EASE_IN, easeIn);
		set(EASE_OUT, easeOut);
		set(EASE_IN_OUT, easeInOut);


		set(BACK_IN, backIn);
		set(BACK_OUT, backOut);
		set(BACK_IN_OUT, backInOut);

		set(ELASTIC, elastic);
		set(BOUNCE, bounce);
	}

	static function linear(ratio:Float):Float {
		return ratio;
	}

	static function stepped(ratio:Float):Float {
		return ratio >= 1 ? 1 : 0;
	}
		
	static function easeIn(ratio:Float):Float {
		return ratio * ratio * ratio;
	}
		
	static function easeOut(ratio:Float):Float {
		var invRatio:Float = ratio - 1.0;
		return invRatio * invRatio * invRatio + 1;
	}
		
	static function easeInOut(ratio:Float):Float {
		return easeCombined(easeIn, easeOut, ratio);
	}
		
	static function backIn(ratio:Float):Float {
		var s:Float = 1.70158;
		return Math.pow(ratio, 2) * ((s + 1.0)*ratio - s);
	}
		
	static function backOut(ratio:Float):Float {
		var invRatio:Float = ratio - 1.0;
		var s:Float = 1.70158;
		return Math.pow(invRatio, 2) * ((s + 1.0)*invRatio + s) + 1.0;
	}
		
	static function backInOut(ratio:Float):Float {
		return easeCombined(backIn, backOut, ratio);
	}
		
	static function elastic(ratio:Float):Float {
		if (ratio == 0 || ratio == 1) return ratio;
		else {
			var p:Float = 0.3;
			var s:Float = p/4.0;
			return Math.pow(2.0, -10.0*ratio) * Math.sin((ratio-s)*(2.0*Math.PI)/p) + 1;
		}
	}

	static function bounce(ratio:Float):Float {
		var s:Float = 7.5625;
		var p:Float = 2.75;
		var l:Float;
		if (ratio < (1.0/p)) {
			l = s * Math.pow(ratio, 2);
		}
		else {
			if (ratio < (2.0/p)) {
				ratio -= 1.5/p;
				l = s * Math.pow(ratio, 2) + 0.75;
			}
			else {
				if (ratio < 2.5/p) {
					ratio -= 2.25/p;
					l = s * Math.pow(ratio, 2) + 0.9375;
				}
				else {
					ratio -= 2.625/p;
					l = s * Math.pow(ratio, 2) + 0.984375;
				}
			}
		}
		return l;
	}
		
	static function easeCombined(startFunc:Float->Float, endFunc:Float->Float, ratio:Float):Float {
		if (ratio < 0.5) return 0.5 * startFunc(ratio*2.0);
		else return 0.5 * endFunc((ratio-0.5)*2.0) + 0.5;
	}
}