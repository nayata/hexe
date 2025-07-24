package ui;

class Icon extends h2d.Object {
	var input:h2d.Interactive;
	var image:h2d.Bitmap;

	public var width:Float = 32;
	public var height:Float = 32;

	public var icon(default, set):String = "";


	public function new(icon:String = "", ?parent:h2d.Object) {
		super(parent);

		input = new h2d.Interactive(0, 0, this);
		input.cursor = Default;
		input.onClick = onClick;
		input.onOver = onOver;
		input.onOut = onOut;
		
		image = new h2d.Bitmap(Assets.icon(icon), this);
		image.tile.setCenterRatio();

		setSize(width, height);
	}


	function onClick(event:hxd.Event) {
		onChange();
	}


	public dynamic function onChange() {
	}


	function onOver(e:hxd.Event) {
		alpha = 0.75;
	}


	function onOut(e:hxd.Event) {
		alpha = 1;
	}

	public function set_icon(v) {
		if (v == "") return v;

		image.tile = Assets.icon(v);
		image.tile.setCenterRatio();

		image.x = width * 0.5;
		image.y = height * 0.5;

		return icon = v;
	}


	public function setSize(w:Float, h:Float) {
		width = w;
		height = h;

		input.width = width;
		input.height = height;

		image.x = width * 0.5;
		image.y = height * 0.5;
	}
}