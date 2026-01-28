package prefab;

import h2d.col.Point;

class Collider extends Prefab {
	public static inline var DYNAMIC:Int = 1;

	public static inline var SPHERE:Int = 1;
	public static inline var POLYGON:Int = 2;
	public static inline var CAPSULE:Int = 3;

	static var palette:Array<String> = ["0496ff", "d81159", "b000d3", "80bc00", "7029cf", "ffffff"];

	public var shape(default, set):Int = 0;
	public var body(default, set):Int = 0;
	public var mode(default, set):Int = 0;

	public var color(default, set):String = "0496ff";
	public var text:String = "empty";
	
	var graphics:Polygon;


	public function new() {
		super();

		graphics = new Polygon();
		object = graphics;

		width = 128;
		height = 128;

		pivotX = 0.5;
		pivotY = 0.5;

		type = "collider";
		link = "collider";

		locked = true;
		fixed = false;
	}


	override public function serialize():Dynamic {
		var data:Dynamic = {};

		data.name = name;
		data.type = type;
		data.link = link;

		if (object.parent.name != "root") data.parent = object.parent.name;

		data.body = body;
		data.shape = shape;

		data.x = object.x;
		data.y = object.y;

		data.width = width;
		data.height = height;

		if (object.rotation != 0) data.rotation = object.rotation;

		if (mode != 0) {
			data.mode = mode;
			data.path = verticesToString(graphics.vertices);
		}

		if (text != "empty" && text != "") data.text = text;
		if (color != "0496ff") data.color = Editor.ME.getColor(color);

		if (!object.visible) data.visible = false;

		return data;
	}


	override public function clone():Prefab {
		var prefab = new Collider();

		prefab.shape = shape;
		prefab.body = body;

		prefab.width = width;
		prefab.height = height;

		prefab.mode = mode;
		prefab.text = text;
		prefab.color = color;

		prefab.copy(this);

		return prefab;
	}


	function set_body(v) {
		if (shape == CAPSULE && height < width) height = width;

		body = v;
		color = palette[body];
		fixed = shape == SPHERE;

		return body;
	}


	function set_shape(v) {
		if (v == SPHERE) height = width;
		if (v == CAPSULE && height < width) height = width;

		shape = v;
		fixed = shape == SPHERE;

		graphics.shape = v;
		graphics.render();

		return shape;
	}


	function set_mode(v) {
		mode = v;

		trace(v);
		if (shape == POLYGON) {
			graphics.set(v);
			graphics.render();
		}
		
		return mode;
	}


	function set_color(v) {
		var val = Editor.ME.getColor(v);
		if (val == null) return null;

		color = v;
		graphics.shade = val;
		graphics.render();

		return color;
	}


	override function set_width(v) {
		width = v;

		if (shape == CAPSULE && height < width) height = width;
		graphics.width = Std.int(width);

		x = -width * 0.5;
		y = -height * 0.5;

		return v;
	}


	override function set_height(v) {
		height = v;
		graphics.height = Std.int(v);

		x = -width * 0.5;
		y = -height * 0.5;

		return v;
	}


	override function set_scaleX(v) {
		return width = v;
	}


	override function set_scaleY(v) {
		return height = v;
	}


	function verticesToString(vertices:Array<Point>):String {
		var w = width * 0.5;
		var h = height * 0.5;
	
		var out = new Array<String>();
	
		for (v in vertices) {
			out.push(Std.string(v.x * w));
			out.push(Std.string(v.y * h));
		}
	
		return out.join(",");
	}
}


class Polygon extends h2d.Graphics {
	public var width(default, set):Float = 64;
	public var height(default, set):Float = 64;

	public var shade:Int = 0x0496ff;
	public var shape:Int = 0;

	public var vertices:Array<Point> = [new Point(-1, -1), new Point(1, -1), new Point(1, 1), new Point(-1, 1)];


	function set_width(v) {
		width = v;
		render();
		return v;
	}


	function set_height(v) {
		height = v;
		render();
		return v;
	}


	public function render() {
		switch (shape) {
			case Collider.SPHERE:
				clear();
				lineStyle(2, shade);
				beginFill(shade, 0.75);
				drawCircle(0, 0, width * 0.5, 0);
				drawRect(-2, -2, 4, 4);
				endFill();
			
			case Collider.POLYGON:
				var w = width * 0.5;
				var h = height * 0.5;
			
				inline function px(p:Point) return p.x * w;
				inline function py(p:Point) return p.y * h;

				clear();
				lineStyle(2, shade);
				beginFill(shade, 0.75);

				moveTo(px(vertices[0]), py(vertices[0]));

				for (i in 1...vertices.length) {
					lineTo(px(vertices[i]), py(vertices[i]));
				}

				lineTo(px(vertices[0]), py(vertices[0]));

				endFill();

			case Collider.CAPSULE:
				if (height < width) height = width;

				var r = width * 0.5;
				var h = height * 0.5;
				var k = 0.5522847498;

				clear();
				lineStyle(2, shade);
				beginFill(shade, 0.75);

				moveTo(-r, -h + r);
				lineTo(-r, h - r);
			
				cubicCurveTo(-r, h - r + r * k, -r * k, h, 0, h);
				cubicCurveTo(r * k, h, r, h - r + r * k, r, h - r);
			
				lineTo(r, -h + r);
			
				cubicCurveTo(r, -h + r - r * k, r * k, -h, 0, -h);
				cubicCurveTo(-r * k, -h, -r, -h + r - r * k, -r, -h + r);

				endFill();

			default:
				clear();
				lineStyle(2, shade);
				beginFill(shade, 0.75);
				drawRect(1-width*0.5, 1-height * 0.5, width-2, height-2);
				drawRect(-2, -2, 4, 4);
				endFill();
		}
	}


	public function set(mode:Int) {
		switch (mode) {
			case 1:
				vertices = [new Point(-1, 1), new Point(-1, -1), new Point(1, 1)];
			case 2:
				vertices = [new Point(-1, 1), new Point(1, -1), new Point(1, 1)];
			case 3:
				vertices = [new Point(-1, 1), new Point(0, -1), new Point(1, 1)];
			case 4:
				vertices = [new Point(-1, 0), new Point(0, -1), new Point(1, 0), new Point(0, 1)];
			case 5:
				vertices = [new Point(-0.4,  1), new Point(-1,  0.4), new Point(-1, -0.4), new Point(-0.4, -1), new Point(0.4, -1), new Point(1, -0.4), new Point(1,  0.4), new Point(0.4,  1)];

			default:
				vertices = [new Point(-1, -1), new Point(1, -1), new Point(1, 1), new Point(-1, 1)];
		}
	}


	override function onAdd() {
		super.onAdd();
		render();
	}
}