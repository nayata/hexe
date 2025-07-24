package motion.dopesheet;

class Chanel extends h2d.Object {
	var icon:h2d.Bitmap;
	var text:h2d.Text;
	
	public function new(?parent:h2d.Object) {
		super(parent);

		var height = 26;

		new Link("translate x", "x", 0, this);
		new Link("translate y", "y", height, this);
		new Link("scaleX", "scaleX", height * 2, this);
		new Link("scaleY", "scaleY", height * 3, this);
		new Link("rotation", "rotation", height * 4, this);
		new Link("alpha", "alpha", height * 5, this);

		y = 100;
	}
}

class Link extends h2d.Object {
	var input:h2d.Interactive;
	var image:h2d.Bitmap;
	var icon:h2d.Bitmap;
	var text:h2d.Text;

	var type:String;
	
	public function new(name:String, type:String, position:Int, ?parent:h2d.Object) {
		super(parent);

		input = new h2d.Interactive(200, 30, this);
		input.onClick = onClick;
		input.onOver = onOver;
		input.onOut = onOut;

		image = new h2d.Bitmap(h2d.Tile.fromColor(Style.over, 200, 30), this);
		image.visible = false;

		icon = new h2d.Bitmap(Assets.icon("object"), this);
		icon.tile.setCenterRatio();
		icon.x = 38;
		icon.y = 15;

		text = new h2d.Text(Assets.defaultFont, this);
		text.textColor = Style.label;
		text.textAlign = h2d.Text.Align.Left;
		text.smooth = true;
		text.text = name;

		text.x = 60;
		text.y = 15 - text.textHeight * 0.5;

		this.type = type;

		y = position;
	}

	function onClick(e:hxd.Event) {
		Editor.ME.motion.set(type);
	}

	function onOver(e:hxd.Event) {
		image.visible = true;
	}

	function onOut(e:hxd.Event) {
		image.visible = false;
	}
}