package property.component;


class Color extends TextField {
	var picker:ColorPicker;

	var swatch:h2d.Interactive;
	var undo:String = "";


	public function new(?parent:h2d.Object) {
		super(parent);

		tile = new h2d.Bitmap(h2d.Tile.fromColor(0xFFFFFF, 16, 16), this);

		swatch = new h2d.Interactive(16, 16, this);
		swatch.onClick = onSwatch;

		picker = new ColorPicker(this);
		picker.input.onFocusLost = colorFocusLost;
		picker.onChange = onColor;
		picker.visible = false;
	}


	function onSwatch(event:hxd.Event) {
		onFocus(this);

		picker.visible = !picker.visible;
		if (picker.visible) picker.input.focus();
	}


	function colorFocusLost(event:hxd.Event) {
		picker.visible = false;
	}


	function onColor(prop:Dynamic) {
		var color = Editor.ME.getColor(prop.color);
		if (color == null) return;

		setTileColor(prop.color);
		input.text = prop.color;

		onChange({ field : field, from : undo, to :  prop.color });
	}


	override function onFocusLost(event:hxd.Event) {
		super.onFocusLost(event);

		var color = Editor.ME.getColor(input.text);
		if (color == null) return;

		setTileColor(input.text);

		onChange({ field : field, from : undo, to :  input.text });
	}


	override public function blur() {
		if (input.hasFocus()) {
			var color = Editor.ME.getColor(input.text);
			if (color == null) return;

			onChange({ field : field, from : undo, to : input.text });
		}
	}


	override function set_value(v) {
		undo = v;
		input.text = v;
		setTileColor(v);

		return v;
	}


	function setTileColor(v:String) {
		var color = Editor.ME.getColor(v);
		if (color == null) return;

		var a = tile.color.w;
		tile.color.setColor(color);
		tile.color.w = a;
	}


	override public function setSize(w:Float, h:Float) {
		super.setSize(w, h);

		if (tile != null) {
			tile.x = padding;
			tile.y = height*0.5 - tile.tile.height*0.5;

			swatch.x = tile.x;
			swatch.y = tile.y;

			picker.x = swatch.x - picker.width * 0.5;
			picker.y = swatch.y - picker.height;

			input.inputWidth = Std.int(width-tile.tile.width-padding*4);
			input.x = tile.tile.width + padding*2;
		}
	}
}