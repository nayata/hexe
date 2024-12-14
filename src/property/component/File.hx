package property.component;


class File extends Input {
	var back:h2d.ScaleGrid;
	var tile:h2d.Bitmap;

	var description:h2d.Text;
	var text:h2d.Text;

	var input:h2d.Interactive;

	var padding:Int = 12;
	var indent:Int = 30;
	var max:Int = 16;


	public function new(?parent:h2d.Object) {
		super(parent);

		back = new h2d.ScaleGrid(Assets.icon("input"), 10, 10, this);
		text = new h2d.Text(Assets.defaultFont, this);

		input = new h2d.Interactive(0, 0, this);
		input.onClick = onClick;

		setSize(80, 32);
	}


	function onClick(event:hxd.Event) {
		onSelect({ field : field, value : value });
	}


	override function set_value(v:String) {
		var str:String = v;
		if (str.length > max) str = "..." + str.substr(str.length - max);
		text.text = str;

		return value = v;
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

		if (tile != null) description.x = width - tile.tile.width - padding - 8;

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

		if (description != null) description.x = width - indent;

		return icon = v;
	}


	override public function setSize(w:Float, h:Float) {
		super.setSize(w, h);

		back.width = width;
		back.height = height;

		text.x = padding;
		text.y = height * 0.5 - text.textHeight * 0.5;

		input.width = Std.int(width);
		input.height = Std.int(height);

		if (description != null) {
			description.x = width - padding;
			description.y = height * 0.5 - description.textHeight * 0.5;
		}

		if (tile != null) {
			tile.x = width - tile.tile.width * 0.5 - padding;
			tile.y = height * 0.5;
		}
	}
}