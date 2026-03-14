package ui;

class Window extends h2d.Object {
	var backdrop:Touch;

	var window:h2d.Object;

	var background:h2d.Bitmap;
	var content:h2d.Mask;
	var header:Header;
	

	public var width(default, set):Int = 340;
	public var height(default, set):Int = 256;

	public var title(default, set):String = "";


	public function new(?parent:h2d.Object) {
		super(parent);

		backdrop = new Touch(Editor.ME.WIDTH, Editor.ME.HEIGHT, this);
		backdrop.onClick = onBackdrop;

		window = new h2d.Object(this);
		
		background = new h2d.Bitmap(h2d.Tile.fromColor(Style.menu, width, height), window);
		background.filter = new h2d.filter.DropShadow(5, Math.PI/4, 0, 0.25, 20.0, 1, 1.0, true);

		content = new h2d.Mask(width, height, window);
		
		header = new Header(window);
		header.handle.onPush = onDrag;
		header.window = this;

		background.y = header.y = -header.height;
	}


	function onBackdrop(event:hxd.Event) {
		var mx = Editor.ME.s2d.mouseX;
		var my = Editor.ME.s2d.mouseY;
	
		if (mx < window.x || mx > window.x + width || my < window.y - header.height || my > window.y + height - header.height) {
			close();
		}
	}


	function onDrag(event:hxd.Event) {
		header.handle.position.x = Editor.ME.s2d.mouseX - window.x;
		header.handle.position.y = Editor.ME.s2d.mouseY - window.y;

		header.handle.startCapture(function(event) {
			switch(event.kind) {
				case EPush:
				case EMove:
					window.x = Editor.ME.s2d.mouseX - header.handle.position.x;
					window.y = Editor.ME.s2d.mouseY - header.handle.position.y;
	
				case ERelease, EReleaseOutside:
					Editor.ME.s2d.stopCapture();

				default:
			}
			event.propagate = false;
		});
	}


	public function open(?prop:String) {}


	public function close() {
		remove();
	}


	public function clear() {}


	public function onResize() {
		var w = Editor.ME.WIDTH;
		var h = Editor.ME.HEIGHT;

		backdrop.width = w;
		backdrop.height = h;

		window.x = w * 0.5 - width * 0.5;
		window.y = header.height * 0.5 + h * 0.5 - height * 0.5;
	}


	function set_title(v) {
		header.title.text = v;
		return title = v;
	}


	function set_width(v) {
		width = v;

		background.width = width;
		content.width = width;
		header.width = width;

		return v;
	}


	function set_height(v) {
		height = v;

		background.height = height + header.height;
		content.height = height;

		return v;
	}
}


class Header extends h2d.Object {
	public var window:Window;

	public var handle:Touch;
	public var button:Icon;

	var background:h2d.Bitmap;

	public var width(default, set):Int = 340;
	public var height(default, set):Int = 30;

	public var title:h2d.Text;


	public function new(?parent:h2d.Object) {
		super(parent);

		handle = new Touch(width, 30, this);
		background = new h2d.Bitmap(h2d.Tile.fromColor(Style.white, width, 30), this);

		title = new h2d.Text(Assets.defaultFont, this);
		title.textColor = Style.menu;
		title.textAlign = h2d.Text.Align.Left;
		title.smooth = false;

		title.x = 16;
		title.y = height * 0.5 - title.textHeight * 0.5;

		button = new Icon("close", this);
		button.onClick = close;
		button.setSize(36, 30);
		button.x = width - button.width;
	}


	public function close() {
		window.close();
	}


	public function onResize() {
	}


	function set_width(v) {
		width = v;
		button.x = width - button.width;
		background.width = width;
		background.height = height;
		handle.width = width;
		return v;
	}


	function set_height(v) {
		height = v;
		background.width = width;
		background.height = height;
		handle.height = height;
		return v;
	}
}