package ui.color;

class Picker extends h2d.Object {
	public var shader:RgbShader;
	
	var bitmap:h2d.Bitmap;
	var cursor:h2d.Bitmap;
	var input:h2d.Interactive;

	public var saturation:Float = 0;
	public var value:Float = 1;


	public function new(?parent:h2d.Object) {
		super(parent);

		shader = new RgbShader();

		bitmap = new h2d.Bitmap(h2d.Tile.fromColor(0xffffff, 128, 128), this);
		bitmap.addShader(shader);
		bitmap.smooth = true;

		input = new h2d.Interactive(128, 128, this);
		input.cursor = Default;
		input.onPush = onInput;

		cursor = new h2d.Bitmap(Assets.icon("rgb"), this);
		cursor.tile.setCenterRatio();
		cursor.smooth = true;
	}


	public dynamic function onChange() {}


	public function onCursor() {
		var luminance = value * (1.0 - saturation * 0.5);

		cursor.blendMode = luminance > 0.5 ? Sub : Alpha;
		cursor.alpha = 0.85;

		cursor.x = saturation * input.width;
		cursor.y = input.height * (1-value);
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
		relX = hxd.Math.clamp(relX, 0, input.width);
		relY = hxd.Math.clamp(relY, 0, input.height);

		saturation = relX / input.width;
		value = 1.0 - (relY / input.height);

		onChange();
	}
}