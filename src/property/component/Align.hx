package property.component;


class Align extends Choice {
	var back:h2d.ScaleGrid;


	public function new(?parent:h2d.Object) {
		super(parent);

		back = new h2d.ScaleGrid(Assets.icon("input"), 10, 10, this);


		var item = new Element(0, 0, 55, 32, this);
		var tile = new h2d.Bitmap(item);

		tile.tile = Assets.icon("left");
		tile.tile.setCenterRatio();

		tile.x = item.width * 0.5;
		tile.y = item.height * 0.5;

		item.value = 0;
		items.push(item);

		item = new Element(55, 0, 55, 32, this);
		tile = new h2d.Bitmap(item);

		tile.tile = Assets.icon("center");
		tile.tile.setCenterRatio();

		tile.x = item.width * 0.5;
		tile.y = item.height * 0.5;

		item.value = 1;
		items.push(item);

		item = new Element(110, 0, 55, 32, this);
		tile = new h2d.Bitmap(item);

		tile.tile = Assets.icon("right");
		tile.tile.setCenterRatio();

		tile.x = item.width * 0.5;
		tile.y = item.height * 0.5;

		item.value = 2;
		items.push(item);
	}


	override function onClick(event:hxd.Event) {
		if (selected != null) {
			for (node in items) node.alpha = 0.3;
			selected.alpha = 1;

			onChange({ field : field, from : undo, to : selected.value });
		}
	}


	override function set_value(v) {
		undo = Std.parseInt(v);

		for (node in items) {
			if (node.value == undo) {
				node.alpha = 1;
			}
			else {
				node.alpha = 0.3;
			}
		}

		return v;
	}

	
	override public function setSize(w:Float, h:Float) {
		super.setSize(w, h);

		back.width = width;
		back.height = height;

		input.width = width;
		input.height = height;
	}
}