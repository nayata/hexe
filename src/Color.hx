import ui.color.Palette;
import ui.color.Picker;
import ui.color.Slider;


class Color extends ui.Window {
	var editor:Editor;
	var s2d:h2d.Scene;

	var palette:Palette;

	var picker:Picker;
	var slider:Slider;

	var rgb:Int = 0xffffff;


	public function new(?parent:h2d.Object) {
		super(parent);

		editor = Editor.ME;
		s2d = editor.s2d;

		title = "Color";
		content.clip = false;
		width = 296;
		height = 368;

		slider = new Slider(content);
		slider.onChange = onColor;
		slider.x = slider.y = 20;

		picker = new Picker(content);
		picker.onChange = onColor;
		picker.x = picker.y = 64 + 20;

		palette = new Palette(content);
		palette.onChange = onPalette;
		palette.x = 20;
		palette.y = 296;

		height = 296 + (palette.height * palette.size) + 20;

		visible = false;
	}


	override public function open(color:String = "ffffff") {
		setColor(color);
		visible = true;
		onResize();
	}


	override public function close() {
		onChange(to(rgb));
		visible = false;
	}


	public dynamic function onUpdate(prop:String) {}
	public dynamic function onChange(prop:String) {}


	function setColor(color:String) {
		rgb = from(color);

		var hsv = rgbToHsv(rgb);

		picker.shader.hue = hsv.h;
		picker.saturation = hsv.s;
		picker.value = hsv.v;

		slider.hue = hsv.h;

		picker.onCursor();
		slider.onCursor();
	}


	function onPalette(color:String) {
		setColor(color); 
		onUpdate(color);
	}


	function onColor() {
		rgb = hsvToRgb(slider.hue, picker.saturation, picker.value);
		picker.shader.hue = slider.hue;

		onUpdate(to(rgb));
	}


	// Conver color
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


	public static function to(color:Int):String {
		return StringTools.hex(color, 6);
	}


	public static function hsvToRgb(h:Float, s:Float, v:Float):Int {
		h = h % 1.0;

		var r:Float = 0;
		var g:Float = 0;
		var b:Float = 0;

		var i = Std.int(h * 6);
		var f = h * 6 - i;

		var p = v * (1 - s);
		var q = v * (1 - f * s);
		var t = v * (1 - (1 - f) * s);

		switch (i % 6) {
			case 0:
				r = v;
				g = t;
				b = p;

			case 1:
				r = q;
				g = v;
				b = p;

			case 2:
				r = p;
				g = v;
				b = t;

			case 3:
				r = p;
				g = q;
				b = v;

			case 4:
				r = t;
				g = p;
				b = v;

			case 5:
				r = v;
				g = p;
				b = q;
		}

		return (Std.int(r * 255) << 16) | (Std.int(g * 255) << 8) | (Std.int(b * 255));
	}


	public static function rgbToHsv(color:Int) {
		var r:Float = ((color >> 16) & 0xFF) / 255.0;
		var g:Float = ((color >> 8) & 0xFF) / 255.0;
		var b:Float = (color & 0xFF) / 255.0;

		var max = Math.max(r, Math.max(g, b));
		var min = Math.min(r, Math.min(g, b));

		var h = 0.0;
		var s = 0.0;
		var v = max;

		var d = max - min;

		s = max == 0 ? 0 : d / max;

		if (max != min) {
			if (max == r) {
				h = (g - b) / d + (g < b ? 6 : 0);
			}
			else if (max == g) {
				h = (b - r) / d + 2;
			}
			else {
				h = (r - g) / d + 4;
			}

			h /= 6;
		}

		return { h: h, s: s, v: v };
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