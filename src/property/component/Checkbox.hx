package property.component;


class Checkbox extends Input {
	var back:h2d.Bitmap;
	var face:h2d.Bitmap;

	var input:h2d.Interactive;

	var checked:Bool = false;
	var undo:Bool = false;


	public function new(?parent:h2d.Object) {
		super(parent);

		back = new h2d.Bitmap(Assets.icon("checkbox"), this);
		face = new h2d.Bitmap(Assets.icon("checked"), this);

		back.alpha = 0.25;
		face.visible = false;

		input = new h2d.Interactive(16, 16, this);
		input.onClick = onClick;
		input.cursor = Default;
	}


	function onClick(event:hxd.Event) {
		checked = !checked;
		face.visible = checked;

		onChange({ field : field, from : undo, to : checked });
	}


	override function set_value(v) {
		checked = v == "true" ? true : false;
		
		face.visible = checked;
		undo = checked;

		return v;
	}
}