package prefab;


class Text extends Prefab {
	public var font(default, set):String = "Default";
	public var text(default, set):String = "text";

	public var letterSpacing(default, set):Int = 0;
	public var lineSpacing(default, set):Int = 0;
	public var maxWidth(default, set):Int = -1;

	public var color(default, set):String = "FFFFFF";
	public var align(default, set):Int = 0;


	public function new() {
		super();

		var h2dText = new h2d.Text(Assets.font("Default"));
		h2dText.smooth = true;
		h2dText.text = "text";

		type = "text";
		link = "text";

		width = h2dText.textWidth;
		height = h2dText.textHeight;

		object = h2dText;
		locked = true;
	}


	override public function serialize():Dynamic {
		var data:Dynamic = super.serialize();

		if (font != "Default") {
			data.src = Assets.fontPath.get(font);
			data.font = font;
		}

		if (color != "FFFFFF") data.color = Editor.ME.getColor(color);

		if (letterSpacing != 0) data.width = letterSpacing;
		if (lineSpacing != 0) data.height = lineSpacing;
		if (maxWidth != -1) data.range = maxWidth;
		if (align != 0) data.align = align;

		data.text = text;

		return data;
	}


	override public function clone():Prefab {
		var prefab = new Text();

		prefab.font = font;
		prefab.src = src;

		prefab.color = color;
		prefab.letterSpacing = letterSpacing;
		prefab.lineSpacing = lineSpacing;
		prefab.maxWidth = maxWidth;
		prefab.align = align;

		prefab.text = text;

		prefab.copy(this);

		return prefab;
	}


	function set_color(v) {
		var val = Editor.ME.getColor(v);
		if (val == null) return null;

		var h2dText = (cast object : h2d.Text);
		h2dText.textColor = val;

		return color = v;
	}


	function set_align(v) {
		align = v;

		var h2dText = (cast object : h2d.Text);

		switch (align) {
			case 1:
				h2dText.textAlign = Center;
				x = -h2dText.textWidth * 0.5;
			case 2:
				h2dText.textAlign = Right;
				x = -h2dText.textWidth;
			default:
				h2dText.textAlign = Left;
				x = 0;
		}

		return v;
	}


	function set_maxWidth(v) {
		var h2dText = (cast object : h2d.Text);
		h2dText.maxWidth = v;

		width = h2dText.textWidth;
		height = h2dText.textHeight;

		align = align;

		return maxWidth = v;
	}


	function set_letterSpacing(v) {
		var h2dText = (cast object : h2d.Text);
		h2dText.letterSpacing = v;

		width = h2dText.textWidth;
		height = h2dText.textHeight;

		align = align;

		return letterSpacing = v;
	}


	function set_lineSpacing(v) {
		var h2dText = (cast object : h2d.Text);
		h2dText.lineSpacing = v;

		width = h2dText.textWidth;
		height = h2dText.textHeight;

		align = align;

		return lineSpacing = v;
	}

	
	function set_font(v) {
		var h2dText = (cast object : h2d.Text);
		h2dText.font = Assets.font(v);

		width = h2dText.textWidth;
		height = h2dText.textHeight;

		align = align;

		return font = v;
	}


	function set_text(v) {
		var h2dText = (cast object : h2d.Text);
		h2dText.text = v;

		width = h2dText.textWidth;
		height = h2dText.textHeight;

		/// x/y update
		align = align;

		return text = v;
	}
}