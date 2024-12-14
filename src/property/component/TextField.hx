package property.component;


class TextField extends Input {
	var back:h2d.ScaleGrid;
	var face:h2d.ScaleGrid;

	var tile:h2d.Bitmap;

	var description:h2d.Text;
	var input:h2d.TextInput;

	var padding:Int = 12;
	var indent:Int = 30;


	public function new(?parent:h2d.Object) {
		super(parent);

		back = new h2d.ScaleGrid(Assets.icon("input"), 10, 10, this);
		face = new h2d.ScaleGrid(Assets.icon("focus"), 10, 10, this);
		face.visible = false;

		input = new h2d.TextInput(Assets.defaultFont, this);
		
		input.onChange = onInput;
		@:privateAccess { input.interactive.onWheel = onWheel; }
		input.onFocus = onInputFocus;
		input.onFocusLost = onFocusLost;

		setSize(80, 32);
	}


	function onInput() {
	}


	function onWheel(event:hxd.Event) {
		if (!enabled) return;
	}


	function onInputFocus(event:hxd.Event) {
		face.visible = true;
	}


	function onFocusLost(event:hxd.Event) {
		face.visible = false;
	}


	override function set_enabled(v) {
		input.canEdit = v;
		input.textColor = v ? 0xffffff : Style.label;
		return enabled = v;
	}


	override function set_value(v) {
		input.text = v;
		return v;
	}


	override function set_label(v) {
		if (description == null) {
			description = new h2d.Text(Assets.defaultFont, this);
			description.textColor = Style.label;
			description.textAlign = h2d.Text.Align.Right;
			description.smooth = true;
		}

		description.text = v;

		description.x = width - padding;
		description.y = height*0.5 - description.textHeight*0.5;

		input.inputWidth = Std.int(width-description.textWidth-indent);

		return label = v;
	}


	override function set_icon(v) {
		if (tile == null) {
			tile = new h2d.Bitmap(h2d.Tile.fromColor(Style.icon, 16, 16), this);
			tile.tile.setCenterRatio();
		}

		tile.tile = Assets.icon(v);
		tile.tile.setCenterRatio();

		tile.x = width - tile.tile.width * 0.5 - padding;
		tile.y = height * 0.5;

		return icon = v;
	}


	override public function setSize(w:Float, h:Float) {
		super.setSize(w, h);

		back.width = width;
		back.height = height;

		face.width = width;
		face.height = height;

		input.x = padding;
		input.y = height * 0.5 - input.textHeight * 0.5;

		input.inputWidth = Std.int(width-padding*2);

		if (description != null) {
			description.x = width - padding;
			description.y = height * 0.5 - description.textHeight * 0.5;

			input.inputWidth = Std.int(width-description.textWidth-indent);
		}

		if (tile != null) {
			tile.x = width - tile.tile.width * 0.5 - padding;
			tile.y = height * 0.5;
		}
	}
}