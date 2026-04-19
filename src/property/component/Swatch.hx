package property.component;


class Swatch extends Input {
	var picker:ColorPicker;
	var swatch:h2d.Interactive;

	var back:h2d.ScaleGrid;
	var tile:h2d.Bitmap;
	var padding:Int = 12;

	var undo:String = "";


	public function new(?parent:h2d.Object) {
		super(parent);

		back = new h2d.ScaleGrid(Assets.icon("input"), 10, 10, this);
		tile = new h2d.Bitmap(h2d.Tile.fromColor(0xFFFFFF, 16, 16), this);

		swatch = new h2d.Interactive(16, 16, this);
		swatch.onClick = onSwatch;

		picker = new ColorPicker(this);
		picker.input.onFocusLost = colorFocusLost;
		picker.onChange = onColor;
		picker.visible = false;

		setSize(80, 32);
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

		onChange({ field : field, from : undo, to :  prop.color });
	}


	override function set_value(v) {
		undo = v;
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


	override function set_enabled(v) {
		swatch.visible = v;
		tile.alpha = v ? 1 : 0.3;
		return enabled = v;
	}


	override public function setSize(w:Float, h:Float) {
		super.setSize(w, h);

		back.width = width;
		back.height = height;

		tile.x = padding;
		tile.y = padding;

		tile.width = width - padding * 2;
		tile.height = height - padding * 2;

		picker.x = swatch.x - picker.width * 0.5;
		picker.y = swatch.y - picker.height;

		swatch.width = width;
		swatch.height = height;
	}
}