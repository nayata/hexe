package property.component;


class Select extends Input {
	var back:h2d.ScaleGrid;
	var face:h2d.ScaleGrid;

	var input:h2d.Interactive;
	var highlight:h2d.Bitmap;
	var panel:h2d.Object;

	var tile:h2d.Bitmap;

	var text:h2d.Text;
	var size:Int = 30;
	var padding:Int = 12;

	var items:Array<Element> = [];
	var selected:Element = null;

	var undo:Dynamic = null;


	public function new(?parent:h2d.Object) {
		super(parent);

		back = new h2d.ScaleGrid(Assets.icon("input"), 10, 10, this);

		highlight = new h2d.Bitmap(h2d.Tile.fromColor(0x3F3F3F, 166, 32), this);
		highlight.visible = false;

		face = new h2d.ScaleGrid(Assets.icon("focus"), 10, 10, this);
		face.visible = false;

		input = new h2d.Interactive(0, 0, this);
		input.cursor = Default;

		input.onClick = onClick;
		input.onMove = onMove;
		input.onOut = onOut;

		panel = new h2d.Object(this);
		panel.visible = false;
		panel.y = 10;

		text = new h2d.Text(Assets.defaultFont, this);
		text.textColor = Style.input;
		text.textAlign = h2d.Text.Align.Left;
		text.smooth = true;
		text.text = "Alpha";

		text.x = 20;
		text.y = 20 - text.textHeight*0.5;

		setSize(166, 40);
	}


	public function add(value:Array<Dynamic>) {
		panel.removeChildren();
		items = [];

		for (index in value) {
			var item = new Element(panel);

			item.value = index;

			item.x = 20;
			item.y = 2 + items.length * size;

			item.width = width;
			item.height = size;

			item.alpha = 0.75;

			var label = new h2d.Text(Assets.defaultFont, item);
			label.textColor = Style.input;
			label.textAlign = h2d.Text.Align.Left;
			label.smooth = true;
			label.text = Std.string(index);
	
			items.push(item);
		}
	}


	function onClick(event:hxd.Event) {
		if (!panel.visible) {
			open();
			return;
		}

		if (selected != null) {
			onChange({ field : field, from : undo, to : selected.value });

			text.text = Std.string(selected.value);
			close();
		}
	}


	function onMove(event:hxd.Event) {
		if (!panel.visible) return;

		if (selected != null) selected.alpha = 0.75;
		selected = null;

		var mouse = new h2d.col.Point(event.relX, event.relY);
		for (node in items) {
			if (mouse.y >= node.y && mouse.y < node.y + size) {
				selected = node;

				node.alpha = 1;
			}
			else {
				node.alpha = 0.75;
			}
		}

		highlight.visible = selected != null ? true : false;
		highlight.y = selected != null ? selected.y + 3 : 0;
	}


	function onOut(event:hxd.Event) {
		close();
	}


	function open() {
		if (items.length < 2) return;
		
		back.height = 12 + items.length * size;
		face.height = 12 + items.length * size;
		input.height = 12 + items.length * size;

		face.visible = true;
		panel.visible = true;
		text.visible = false;

		selected = items[0];
		selected.alpha = 1;

		if (tile != null) tile.visible = false;

		onFocus(this);
		input.focus();
	}


	function close() {
		if (selected != null) selected.alpha = 0.75;

		back.height = height;
		input.height = height;

		highlight.visible = false;

		face.visible = false;
		panel.visible = false;
		text.visible = true;

		if (tile != null) tile.visible = true;
	}


	override public function setSize(w:Float, h:Float) {
		super.setSize(w, h);

		back.width = width;
		back.height = height;

		face.width = width;
		face.height = height;

		input.width = width;
		input.height = height;

		if (tile != null) {
			tile.x = width - tile.tile.width * 0.5 - padding;
			tile.y = height * 0.5;
		}
	}


	override function set_label(v) {
		text.text = v;
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


	override function set_value(v) {
		undo = v;
		text.text = v;
		return v;
	}
}