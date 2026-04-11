package motion.dopesheet;

class Channel extends h2d.Object {
	public var list:Array<Link> = [];
	public var animation:Animation;

	var height = 28;
	

	public function new(?parent:h2d.Object) {
		super(parent);

		list.push(new Line("event", "event", "event", 0, this));
		list.push(new Link("translate x", "x", "position", height, this));
		list.push(new Link("translate y", "y", "position", height * 2, this));
		list.push(new Link("scaleX", "scaleX", "scale", height * 3, this));
		list.push(new Link("scaleY", "scaleY", "scale", height * 4, this));
		list.push(new Link("rotation", "rotation", "rotation", height * 5, this));
		list.push(new Link("alpha", "alpha", "alpha", height * 6, this));
	}


	public function select(name:String, frame:Int) {
		for (chanel in list) {
			chanel.select(animation.find(name, chanel.type, frame));
		}
	}


	public function unselect() {
		for (chanel in list) chanel.unselect();
	}


	public function update(name:String, frame:Int) {
		for (chanel in list) {
			chanel.select(animation.find(name, chanel.type, frame));
		}
	}
}


class Link extends h2d.Object {
	public var type:String;

	var input:h2d.Interactive;
	var image:h2d.Bitmap;
	var icon:h2d.Bitmap;
	var slot:h2d.Bitmap;

	var text:h2d.Text;
	var mode:Select;


	public function new(name:String, type:String, src:String, position:Int, ?parent:h2d.Object) {
		super(parent);

		input = new h2d.Interactive(176, 28, this);
		input.onClick = onClick;
		input.onOver = onOver;
		input.onOut = onOut;

		image = new h2d.Bitmap(h2d.Tile.fromColor(Style.toolbar, 176, 28), this);
		image.visible = false;

		icon = new h2d.Bitmap(Assets.icon(src), this);
		icon.tile.setCenterRatio();
		icon.x = 38;
		icon.y = 14;

		Assets.colorize(icon);

		text = new h2d.Text(Assets.defaultFont, this);
		text.textColor = Style.label;
		text.textAlign = h2d.Text.Align.Left;
		text.smooth = true;
		text.text = name;

		text.x = 60;
		text.y = 14 - text.textHeight * 0.5;

		slot = new h2d.Bitmap(Assets.icon("keyslot"), this);
		slot.x = 156 - slot.tile.width * 0.5;
		slot.y = 14 - slot.tile.height * 0.5;

		mode = new Select(100, 28, this);
		mode.onClick = onSelect;
		mode.x = 176;

		this.type = type;

		y = position;
	}


	public function select(?frame:motion.animation.Frame) {
		slot.tile = frame != null ? Assets.icon("keyframe") : Assets.icon("keyslot");
		mode.label.text = frame != null ? frame.ease : "none";
	}


	public function unselect() {
		slot.tile = Assets.icon("keyslot");
		mode.label.text = "none";
	}


	function onClick(e:hxd.Event) {
		Editor.ME.motion.set(type);
	}


	function onSelect(e:hxd.Event) {
		Editor.ME.motion.context.ease.open(type);
	}


	function onOver(e:hxd.Event) {
		text.textColor = Style.props;
		image.visible = true;
	}


	function onOut(e:hxd.Event) {
		text.textColor = Style.label;
		image.visible = false;
	}
}


class Line extends Link {
	override public function select(?frame:motion.animation.Frame) {
		slot.tile = frame != null ? Assets.icon("keyframe") : Assets.icon("keyslot");
		mode.label.text = frame != null ? frame.name : "none";
	}

	override public function unselect() {
	}

	override function onClick(e:hxd.Event) {
		Editor.ME.motion.context.event.open();
	}

	override function onSelect(e:hxd.Event) {
		Editor.ME.motion.context.event.open();
	}
}


class Select extends h2d.Interactive {
	public var label:h2d.Text;

	var image:h2d.Bitmap;
	var icon:h2d.Bitmap;
	var mask:h2d.Mask;

	public function new(width, height, ?parent) {
		super(width, height, parent);

		onOver = over;
		onOut = out;

		image = new h2d.Bitmap(h2d.Tile.fromColor(Style.highlight, 100, 28), this);
		image.visible = false;

		mask = new h2d.Mask(60, 28, this);
		mask.x = 10;

		label = new h2d.Text(Assets.defaultFont, mask);
		label.textColor = Style.label;
		label.text = "none";

		label.y = 14 - label.textHeight * 0.5;

		icon = new h2d.Bitmap(Assets.icon("arrow"), this);
		icon.x = 88 - icon.tile.width * 0.5;
		icon.y = 14 - icon.tile.height * 0.5;
	}

	function over(e:hxd.Event) {
		image.visible = true;
	}

	function out(e:hxd.Event) {
		image.visible = false;
	}
}