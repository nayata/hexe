package property.component;

class ColorPicker extends Choice {
	var back:h2d.ScaleGrid;

	var wide:Int = 6;
	var size:Int = 30;


	public function new(?parent:h2d.Object) {
		super(parent);

		back = new h2d.ScaleGrid(Assets.icon("select"), 10, 10, this);
		back.filter = new h2d.filter.DropShadow(5, Math.PI/4, 0, 0.25, 20.0, 1, 1.0, true);

		var raw = hxd.Res.load("color.txt");
		var res = raw.entry.getText().split(",");

		var w = 0.0;
		var h = 0.0;

		for (i in 0...res.length) {
			var rowPosition = Math.floor(i / wide);
			var colPosition = i % wide;

			var color = StringTools.trim(res[i]);

			var item = new Element(colPosition * size, rowPosition * size, size, size, this);
			var tile = new h2d.Bitmap(h2d.Tile.fromColor(Std.parseInt("0x" + color), size, size), item);

			item.value = color;
			items.push(item);

			w = Math.max(w, colPosition * size + size);
			h = Math.max(h, rowPosition * size + size);
		}

		setSize(w, h);
	}


	override function onClick(event:hxd.Event) {
		if (selected != null) {
			onChange({ color : selected.value });
			close();
		}
	}


	override function close() {
		visible = false;
		blur();
	}

	
	override public function setSize(w:Float, h:Float) {
		super.setSize(w, h);

		input.width = width;
		input.height = height;

		back.width = width + 16;
		back.height = height + 16;

		back.x = back.y = -8;
	}
}