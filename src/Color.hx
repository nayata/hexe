class Color {
	public static function from(hex:String):Null<Int> {
		if (hex.charAt(0) == "#") hex = hex.substr(1);

		var color = Std.parseInt("0x"+hex);
		if (color == null) return null;

		color = color & 0xFFFFFFFF;

		switch (hex.length) {
			case 2: // Assume color is shade of gray
				color = (color << 16) + (color << 8) + (color);
			case 3: // handle #XXX html codes
				var r = (color >> 8) & 0xF;
				var g = (color >> 4) & 0xF;
				var b = (color >> 0) & 0xF;
				color = (r << 20) + (r << 16) + (g << 12) + (g << 8) + (b << 4) + (b << 0);
			case 6:
			case 8:
			default:
				return null;
		}

		return color & 0xFFFFFF;
	}

	public static function desaturate(color:Int, factor:Float = 0.3):Int {
		var r = (color >> 16) & 0xFF;
		var g = (color >> 8) & 0xFF;
		var b = color & 0xFF;
	
		var gray = Std.int(0.3 * r + 0.59 * g + 0.11 * b);
	
		r = Std.int(r * factor + gray * (1 - factor));
		g = Std.int(g * factor + gray * (1 - factor));
		b = Std.int(b * factor + gray * (1 - factor));
	
		return (r << 16) | (g << 8) | b;
	}
}