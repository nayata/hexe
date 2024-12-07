package ui;

class Dragger extends h2d.Object {
	var input:h2d.Interactive;

	var back:h2d.Bitmap;
	var grip:h2d.Bitmap;
	var icon:h2d.Bitmap;

	var moving(default, null): Bool;
	var time:Int = -1;

	public var width(default, set):Float = 300;
	public var height(default, set):Float = 40;

	public var minHeight:Float = 0;
	public var maxHeight:Float = 800;
	
	public var position:Float = 0;


	public function new(?parent:h2d.Object) {
		super(parent);

		input = new h2d.Interactive(40, 40, this);
		input.propagateEvents = true;
		input.onPush = onDown;
		input.onMove = onMove;

		back = new h2d.Bitmap(h2d.Tile.fromColor(Style.panel, 300, 40), this);

		grip = new h2d.Bitmap(h2d.Tile.fromColor(Style.border, 240+60, 4), this);
		grip.tile.setCenterRatio();

		icon = new h2d.Bitmap(Assets.icon("drag"), this);
		icon.tile.setCenterRatio();
	}


	function set_width(v) {
		width = v;
		input.width = width;
		back.width = width;

		grip.x = width * 0.5;
		icon.x = width * 0.5;

		return v;
	}


	function set_height(v) {
		height = v;
		input.height = height;
		back.height = height;

		grip.y = height - grip.tile.height;
		icon.y = height * 0.5;

		return v;
	}


	function onDown(event:hxd.Event) {
		if (event.button != 0) return;
		event.propagate = false;

		time = hxd.Timer.frameCount;

		startMove();
		onDrag();
	}


	function onMove(event:hxd.Event) {
		if (moving) return;
	}


	public function startMove() {
		var scene = getScene();
		var dragStart = scene.mouseY-y;

		moving = true;

		input.startCapture(function(e:hxd.Event) {
			switch( e.kind ) {
				case ERelease, EReleaseOutside:
					moving = false;
					input.stopCapture();

					//if (Math.abs(time - hxd.Timer.frameCount) < 20) toggle();
				case EMove:
					position = scene.mouseY - dragStart;

					if (position <= minHeight) position = minHeight;
					if (position >= maxHeight) position = maxHeight;

					y = position;

					onChange();
				default:
			}
		}, function() {
			moving = false;
		});
	}


	function toggle() {
		position = position < maxHeight ? maxHeight : minHeight;
		y = position;
		onChange();
	}


	public dynamic function onDrag() {
	}


	public dynamic function onChange() {
	}
}