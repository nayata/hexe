import h2d.Font.FontType;
import h2d.Font.SDFChannel;

class Font {
	var base:h2d.Font;
	var font:h2d.Font;
	var mode:Int = -1;
	var size:Int = -1;

	public function new() {}

	
	public function get(name:String, mode:Int, size:Int):h2d.Font {
		var b = Assets.font(name);
		if (b == base && mode == this.mode && size == this.size) return font;

		base = b;
		this.mode = mode;
		this.size = size;
		return font = make(b, mode, size);
	}

	// mode: 0 = Bitmap, 1 = MSDF, 2 = SDF
	public static function make(base:h2d.Font, mode:Int, size:Int):h2d.Font {
		var sdf = mode != 0;
		if (!sdf && (size <= 0 || size == base.size)) return base;

		var f = base.clone();
		if (size > 0 && size != f.size) f.resizeTo(size);

		if (sdf) {
			var channel = mode == 1 ? SDFChannel.MultiChannel : SDFChannel.Alpha;
			f.type = FontType.SignedDistanceField(channel, 0.5, -1);
			f.tile.getTexture().filter = Linear;
		}
		return f;
	}
}