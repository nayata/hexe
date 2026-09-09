package ui.color;

class Slider extends h2d.Object {
	public var shader:HueShader;
	
	var bitmap:h2d.Bitmap;
	var cursor:h2d.Bitmap;
	var input:h2d.Interactive;

	public var hue:Float = 0;


	public function new(?parent:h2d.Object) {
		super(parent);

		shader = new HueShader();

		bitmap = new h2d.Bitmap(h2d.Tile.fromColor(0xffffff, 256, 256), this);
		bitmap.addShader(shader);
		bitmap.smooth = true;

		input = new h2d.Interactive(256, 256, this);
		input.cursor = Default;
		input.isEllipse = true;
		input.onPush = onInput;

		cursor = new h2d.Bitmap(Assets.icon("hsv"), this);
		cursor.tile.setCenterRatio();
		cursor.smooth = true;
	}


	public dynamic function onChange() {}


	public function onCursor() {
		var angle = hue * Math.PI * 2.0;
		var radius = (shader.innerRadius + shader.outerRadius) * 0.5 * input.width;

		var cx = input.width * 0.5;
		var cy = input.height * 0.5;

		cursor.x = cx + Math.cos(angle) * radius;
		cursor.y = cy + Math.sin(angle) * radius;
	}


	function onInput(event:hxd.Event) {
		input.startCapture(function(event) {
			switch(event.kind) {
				case EPush, EMove:
					onColor(event.relX, event.relY);
					onCursor();
	
				case ERelease, EReleaseOutside:
					onColor(event.relX, event.relY);
					onCursor();

					var scene = getScene();
					scene.stopCapture();
		
				default:
			}
			
			event.propagate = false;
		});
	}


	function onColor(relX:Float, relY:Float) {
		var cx = input.width * 0.5;
		var cy = input.height * 0.5;
		
		var dx = relX - cx;
		var dy = relY - cy;
		
		hue = Math.atan2(dy, dx);
		hue = hue / (Math.PI * 2.0);
		hue = (hue + 1.0) % 1.0;

		onChange();
	}
}