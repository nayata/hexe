package property.component;


class Color extends TextField {
	var swatch:h2d.Interactive;
	var undo:String = "";


	public function new(?parent:h2d.Object) {
		super(parent);

		tile = new h2d.Bitmap(h2d.Tile.fromColor(0xFFFFFF, 16, 16), this);

		swatch = new h2d.Interactive(16, 16, this);
		swatch.onClick = onSwatch;
	}


	function onSwatch(event:hxd.Event) {
		Editor.ME.color.onUpdate = updateColor;
		Editor.ME.color.onChange = changeColor;
		Editor.ME.color.open(undo);
		
		var position = getAbsPos();
		var window = Editor.ME.color;
		
		window.position(position.x - window.width * 0.5, position.y - window.height + 20);
	}


	function updateColor(prop:String) {
		var color = Editor.ME.getColor(prop);
		if (color == null) return;

		setTileColor(prop);
		input.text = prop;

		onUpdate({ field : field, from : undo, to : prop });
	}


	function changeColor(prop:String) {
		onChange({ field : field, from : undo, to : prop });
		undo = prop;
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

			input.inputWidth = Std.int(width-tile.tile.width-padding*4);
			input.x = tile.tile.width + padding*2;
		}
	}
}