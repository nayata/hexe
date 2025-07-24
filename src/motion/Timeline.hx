package motion;

class Timeline extends h2d.Object {
	var time:h2d.Object;
	var dash:h2d.Graphics;
	
	var mark:h2d.Graphics;
	var text:h2d.Text;
	
	public var duration(default, set):Float = 2;
	public var length:Float = 10.336;

	public var scaling:Float = 256;
	public var fraction:Float = 10;

	public var cursor:h2d.Bitmap;
	public var range:h2d.Graphics;


	public function new(?parent:h2d.Object) {
		super(parent);

		time = new h2d.Object(this);
		dash = new h2d.Graphics(this);

		range = new h2d.Graphics(this);
		range.beginFill(0x4f8efd);
		range.drawEllipse(0, 0, 5, 5, hxd.Math.degToRad(-90), 3);
		range.endFill();

		range.scaleY = 0.6;
		range.x = duration * scaling - 0.5;
		range.y = 39;

		cursor = new h2d.Bitmap(h2d.Tile.fromColor(0x636363, 1, 40), this);
		cursor.smooth = false;

		mark = new h2d.Graphics(this);
		mark.beginFill(0xfffb00);

		var r = 255;
		var g = 255;
		var b = 0;

		var w = 26/2;
		var h = 14;
		var s = 20.75;

		mark.addVertex(-w, 0, r, g, b, 1);
		mark.addVertex(w, 0, r, g, b, 1);
		mark.addVertex(w, h, r, g, b, 1);
		mark.addVertex(0, s, r, g, b, 1);
		mark.addVertex(-w, h, r, g, b, 1);

		mark.endFill();

		mark.lineStyle(1, 0xfffb00);
		mark.moveTo(-0.5, 0); 
		mark.lineTo(-0.5, 280);
		
		mark.y = 16;

		text = new h2d.Text(hxd.res.DefaultFont.get(), mark);
		text.textAlign = h2d.Text.Align.Center;
		text.textColor = 0x444444;
		text.text = "0";
		text.y = 0;

		onResize();
	}

	
	public function update(time:Float) {
		text.text = Std.string(Math.round((time * 30) / 1) * 1);
		mark.x = time * scaling;
	}


	function set_duration(value:Float) {
		duration = value;

		range.x = duration * scaling - 0.5;

		if (duration >= length) length = duration + 0.336;
		if (duration < length) length = Math.max(duration, 10.336);

		onResize();

		return duration;
	}


	public function onWheel(delta:Float) {
		var scale = scaling + delta * 30;

		scale = Math.max(120, scale);
		scale = Math.min(600, scale);

		scaling = scale;

		onResize();

		range.x = duration * scaling - 0.5;
	}

	
	public function onResize() {
		dash.clear();
		dash.lineStyle(1, 0x636363);
		time.removeChildren();

		var step:Float = scaling / 3;

		if (scaling >= 360) step = scaling / 6;
		fraction = scaling >= 360 ? 5 : 10;
		
		var width:Float = (length + 1) * scaling;
		var units:Float = 60 / (60 / step);
		var count = Std.int(width / units);

		for (i in 0...count) {
			var dx = i * units;

			dash.moveTo(dx, 16); 
			dash.lineTo(dx, 40);

			for (j in 1...5) {
				dash.moveTo(dx + j * ( units / 5), 33); 
				dash.lineTo(dx + j * ( units / 5), 40);
			}

			if (i == count - 1) {
				dash.moveTo(dx + units, 16); 
				dash.lineTo(dx + units, 40);
			}
		}

		for (i in 0...count + 1) {
			var label = new h2d.Text(hxd.res.DefaultFont.get(), time);
			label.text = i * fraction + "";
			label.textColor = 0x888888;
			label.x = i * units + 2;
			label.y = 12;
		}
	}
}