package ui;

class Dropdown extends h2d.Object {
	var input:h2d.Interactive;

	var button:h2d.Graphics;
	var panel:h2d.Graphics;
	var highlight:h2d.Bitmap;
	
	var items:Array<Item> = [];
	var selected:Item = null;

	public var label:h2d.Text;
	
	public var width:Float = 80;
	public var height:Float = 40;

	public var dividers:Int = 0;
	public var padding:Int = 25;

	public var wide:Int = 240;
	public var size:Int = 40;
	

	public function new(?parent:h2d.Object, text:String = "") {
		super(parent);

		input = new h2d.Interactive(0, 0, this);
		input.cursor = Default;

		input.onClick = onClick;
		input.onMove = onMove;
		input.onOver = onOver;
		input.onOut = onOut;

		button = new h2d.Graphics(this);
		button.visible = false;

		panel = new h2d.Graphics(this);
		panel.visible = false;

		highlight = new h2d.Bitmap(h2d.Tile.fromColor(Style.over, wide, size), panel);
		highlight.visible = false;

		label = new h2d.Text(Assets.defaultFont, this);
		label.textColor = Style.text;
		label.smooth = true;
		label.text = text;

		filter = new h2d.filter.DropShadow(5, Math.PI/4, 0, 0.25, 20.0, 1, 1.0, true);

		setSize(60, 40);
	}


	public dynamic function onChange(value:String, type:String) {
	}


	public function add(value:String, ?icon:String = "", ?shortcut:String = "", ?closable:Bool = true) {
		var item = new Item(panel, value);
		
		item.y = dividers + items.length * size;

		item.closable = closable;
		item.shortcut = shortcut;
		item.icon = icon;

		items.push(item);
	}


	public function addDivider() {
		var item = new Item(panel, "");

		item.y = dividers + items.length * size;
		item.setDivider(wide, 4);

		dividers += 4;
	}


	public function setSize(w:Float, h:Float) {
		width = w;
		height = h;

		input.width = width;
		input.height = height;

		button.clear();
		button.beginFill(Style.menu);
		button.drawRect(0, 0, width, height);
		button.endFill();

		label.x = 16;
		label.y = height * 0.5 - label.textHeight * 0.5;
	}


	public function align(position:String) {
	}


	public function get(name:String) {
		for (node in items) {
			if (node.text == name) return node;
		}
		return null;
	}


	public function clear() {
		panel.removeChildren();
		items = [];
	}


	function onClick(e:hxd.Event) {
		if (!panel.visible) return;

		if (selected != null) {
			if (selected.closable) close();

			onChange(selected.text, selected.icon);
		}
	}


	function onMove(event:hxd.Event) {
		if (!panel.visible) return;

		selected = null;

		var mouse = new h2d.col.Point(event.relX, event.relY - height);

		for (node in items) {
			if (mouse.y >= node.y && mouse.y < node.y + size) {
				selected = node;
			}
		}

		highlight.visible = selected != null ? true : false;
		highlight.y = selected != null ? selected.y : 0;
	}


	function onOver(e:hxd.Event) {
		if (items.length <= 1) return;

		input.width = wide;
		input.height = dividers + items.length * size + size;
		input.x = panel.x;
		input.focus();

		panel.clear();
		panel.beginFill(Style.menu);
		panel.drawRect(0, 0, input.width, input.height-size);
		panel.endFill();

		panel.visible = true;
		button.visible = true;

		panel.y = height;
	}


	function onOut(e:hxd.Event) {
		close();
	}


	function close() {
		input.width = width;
		input.height = height;
		input.x = 0;

		panel.visible = false;
		button.visible = false;

		highlight.visible = false;
	}
}