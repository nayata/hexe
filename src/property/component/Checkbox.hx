package property.component;


class Checkbox extends Input {
	var back:h2d.Bitmap;
	var face:h2d.Bitmap;

	var input:h2d.Interactive;

	var checked:Int = 0;
	var undo:Int = 0;


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
		checked = checked == 1 ? 0 : 1;
		face.visible = checked == 1 ? true : false;

		onChange({ field : field, from : undo, to : checked });
	}


	override function set_value(v) {
		checked = Std.parseInt(v);
		
		face.visible = checked == 1 ? true : false;
		undo = checked;

		return v;
	}
}