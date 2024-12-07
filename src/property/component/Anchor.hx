package property.component;

class Anchor extends Choice {
	public function new(?parent:h2d.Object) {
		super(parent);

		var item = new Element(0, 0, 20, 20, this);
		var tile = new h2d.Bitmap(Assets.icon("checkbox"), item);
		item.value = "0,0";
		items.push(item);

		item = new Element(20, 0, 20, 20, this);
		tile = new h2d.Bitmap(Assets.icon("checkbox"), item);
		item.value = "0.5,0";
		items.push(item);

		item = new Element(40, 0, 20, 20, this);
		tile = new h2d.Bitmap(Assets.icon("checkbox"), item);
		item.value = "1,0";
		items.push(item);



		item = new Element(0, 20, 20, 20, this);
		tile = new h2d.Bitmap(Assets.icon("checkbox"), item);
		item.value = "0,0.5";
		items.push(item);

		item = new Element(20, 20, 20, 20, this);
		tile = new h2d.Bitmap(Assets.icon("checkbox"), item);
		item.value = "0.5,0.5";
		items.push(item);

		item = new Element(40, 20, 20, 20, this);
		tile = new h2d.Bitmap(Assets.icon("checkbox"), item);
		item.value = "1,0.5";
		items.push(item);



		item = new Element(0, 40, 20, 20, this);
		tile = new h2d.Bitmap(Assets.icon("checkbox"), item);
		item.value = "0,1";
		items.push(item);

		item = new Element(20, 40, 20, 20, this);
		tile = new h2d.Bitmap(Assets.icon("checkbox"), item);
		item.value = "0.5,1";
		items.push(item);

		item = new Element(40, 40, 20, 20, this);
		tile = new h2d.Bitmap(Assets.icon("checkbox"), item);
		item.value = "1,1";
		items.push(item);

		setSize(18 * 3, 18 * 3);
	}


	override function onClick(event:hxd.Event) {
		if (selected != null) {
			for (node in items) {
				node.alpha = 0.25;
			}
			selected.alpha = 1;

			onChange({ field : field, from : undo, to : selected.value });
		}
	}


	override function set_value(v) {
		undo = v;

		for (node in items) {
			node.alpha = 0.25;
			if (node.value == undo) {
				node.alpha = 1;
			}
		}

		return value = v;
	}

	
	override public function setSize(w:Float, h:Float) {
		super.setSize(w, h);

		input.width = width;
		input.height = height;
	}
}