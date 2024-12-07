package ui;


class Scroll extends h2d.Object {
	var touch:Touch;
	var scroll:h2d.Bitmap;
	var cursor:h2d.Bitmap;

	public var view:h2d.Bitmap;

	public var width(default, set):Int = 0;
	public var height(default, set):Int = 0;

	public var size:Int = 42;
	

	public function new(?parent:h2d.Object, text:String = "") {
		super(parent);

		touch = new Touch(width, height, this);
		touch.onWheel = onWheel;

		view = new h2d.Bitmap(h2d.Tile.fromColor(Style.panel, 10, 10), this);
		view.width = view.height = 10;

		scroll = new h2d.Bitmap(h2d.Tile.fromColor(Style.scrollBackground, 10, 10), this);
		cursor = new h2d.Bitmap(h2d.Tile.fromColor(Style.scrollBar, 10, 10), scroll);

		scroll.width = scroll.height = 6;
		cursor.width = cursor.height = 6;

		scroll.x = width - scroll.width;
		scroll.visible = false;
	}


	function onWheel(event:hxd.Event) {
		event.propagate = false;

		view.y -= event.wheelDelta * size;
		view.y = Math.max(-view.height + height, view.y);
		view.y = Math.min(0, view.y);

		touch.focus();
		touch.blur();

		onScroll();
	}


	function onScroll() {
		if (view.height <= height) {
			scroll.visible = false;
		}
		else {
			scroll.visible = true;
			scroll.height = Math.ceil(height);
			cursor.height = hxd.Math.imax(1, Std.int(height * (1 - (view.height - height) / view.height)));
		}

		var paddingTop = Std.int(view.y * (height - cursor.height) / (view.height - height));
		cursor.y = -paddingTop;
	}


	public function onResize() {
		scroll.x = width - scroll.width;
		view.y = 0;
		onScroll();
	}


	override function drawRec(ctx:h2d.RenderContext) {
		h2d.Mask.maskWith(ctx, this, width, height, 0, 0);
		super.drawRec(ctx);
		h2d.Mask.unmask(ctx);
	}


	function set_width(v) {
		width = v;
		touch.width = width;
		onScroll();
		return v;
	}


	function set_height(v) {
		height = v;
		touch.height = height;
		onScroll();
		return v;
	}
}