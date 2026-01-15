package ui;


class Item extends h2d.Object {
	var back:h2d.Graphics;
	var label:h2d.Text;

	var description:h2d.Text;
	var tile:h2d.Bitmap;
	
	public var width:Float = 250;
	public var height:Float = 40;

	public var icon(default, set):String = "";
	public var shortcut(default, set):String = "";
	public var checked(default, set):Bool = false;
	public var padding(default, set):Int = 0;

	public var text(get, set):String;

	public var checkable:Bool = false;
	public var closable:Bool = true;


	public function new(?parent:h2d.Object, text:String = "") {
		super(parent);

		back = new h2d.Graphics(this);
		back.visible = false;

		label = new h2d.Text(Assets.defaultFont, this);
		label.textColor = Style.text;
		label.textAlign = h2d.Text.Align.Left;
		label.smooth = true;
		label.text = text;

		setSize(250, 40);
	}


	public function setSize(w:Float, h:Float) {
		width = w;
		height = h;

		back.clear();
		back.beginFill(Style.highlight);
		back.drawRect(0, 0, width, height);
		back.endFill();

		label.x = 20;
		label.y = height*0.5 - label.textHeight*0.5;
	}


	public function setDivider(w:Float, h:Float) {
		width = w;
		height = h;

		back.visible = false;
		label.visible = false;

		var divider = new h2d.Graphics(this);

		divider.beginFill(Style.divider);
		divider.drawRect(4, 0, width-8, 2);
		divider.endFill();

		divider.y = height*0.5 - 1;
	}


	public function onOver(value:Bool) {
		back.visible = value;
	}


	public function set_icon(v) {
		if (v == "") return v;

		if (tile == null) {
			tile = new h2d.Bitmap(h2d.Tile.fromColor(Style.icon, 16, 16), this);
			tile.tile.setCenterRatio();
		}

		tile.tile = Assets.icon(v);
		tile.tile.setCenterRatio();

		tile.x = 25;
		tile.y = height * 0.5;

		padding = 25;

		return icon = v;
	}


	function set_shortcut(v:String) {
		if (description == null) {
			description = new h2d.Text(Assets.defaultFont, this);
			description.textColor = Style.shortcut;
			description.textAlign = h2d.Text.Align.Right;
			description.smooth = true;
		}

		description.text = v;

		description.x = width - 30;
		description.y = height*0.5 - description.textHeight*0.5;

		return shortcut = v;
	}


	function set_checked(v) {
		if (tile != null) tile.visible = v;
		return checked = v;
	}


	function set_padding(v) {
		label.x = 20 + v;
		return padding = v;
	}


	function get_text():String {
		return label.text;
	}


	function set_text(t:String) {
		label.text = t;
		return t;
	}
}