package ui.color;

class Palette extends h2d.Object {
	var input:h2d.Interactive;

	var items:Array<property.component.Element> = [];
	var selected:property.component.Element = null;

	public var width:Int = 10;
	public var height:Int = 0;
	public var size:Int = 25;


	public function new(?parent:h2d.Object) {
		super(parent);

		var raw = hxd.Res.load("color.txt");
		var res = raw.entry.getText().split(",");

		var w = 0.0;
		var h = 0.0;

		for (i in 0...res.length) {
			var rowPosition = Math.floor(i / width);
			var colPosition = i % width;

			var color = StringTools.trim(res[i]);

			var item = new property.component.Element(colPosition * size, rowPosition * size, size, size, this);
			var tile = new h2d.Bitmap(h2d.Tile.fromColor(Std.parseInt("0x" + color), size, size), item);

			item.value = color;
			items.push(item);

			w = Math.max(w, colPosition * size + size);
			h = Math.max(h, rowPosition * size + size);
		}

		height = Math.ceil(res.length / width);

		input = new h2d.Interactive(0, 0, this);
		input.onClick = onClick;
		input.cursor = Default;

		input.width = w;
		input.height = h;
	}


	public dynamic function onChange(prop:String) {}


	function onClick(event:hxd.Event) {
		var mouse = new h2d.col.Point(event.relX, event.relY);
		for (node in items) {
			if (mouse.x > node.x && mouse.x < node.x + node.width && mouse.y > node.y && mouse.y < node.y + node.height) {
				onChange(node.value);
			}
		}
	}
}