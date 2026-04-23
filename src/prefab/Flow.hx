package prefab;
import h2d.col.Point;


class Flow extends Prefab {
	public var layout(default, set):Int = 0;

	public var horizontalSpacing(default, set):Int = 0;
	public var verticalSpacing(default, set):Int = 0;
	public var padding(default, set):Int = 0;


	public function new() {
		super();

		var flow = new h2d.Flow();
		flow.onAfterReflow = onReflow;

		object = flow;

		type = "flow";
		link = "flow";
	}


	public dynamic function onReflow() {
		var prefab = Editor.ME.children.get(object.parent.name);

		if (prefab != null && prefab.type == "layout") {
			var layout = (cast prefab : Layout);
			var root = layout.origin();
			
			root.resize(object.name);
		}

		var flow = (cast object : h2d.Flow);

		width = flow.innerWidth;
		height = flow.innerHeight;

		if (Editor.ME.selected != null) Editor.ME.select(Editor.ME.selected.name);
	}


	override public function serialize():Dynamic {
		var data:Dynamic = super.serialize();

		data.mode = layout;
		data.dx = horizontalSpacing;
		data.dy = verticalSpacing;
		data.padding = padding;

		return data;
	}


	override public function clone():Prefab {
		var prefab = new Flow();

		prefab.layout = layout;
		prefab.horizontalSpacing = horizontalSpacing;
		prefab.verticalSpacing = verticalSpacing;
		prefab.padding = padding;

		prefab.copy(this);

		return prefab;
	}



	function set_layout(v) {
		layout = v;

		var flow = (cast object : h2d.Flow);
		flow.layout = haxe.EnumTools.createByIndex(h2d.Flow.FlowLayout, layout);

		return v;
	}

	
	function set_padding(v) {
		padding = v;

		var flow = (cast object : h2d.Flow);
		flow.padding = padding;

		return v;
	}


	function set_horizontalSpacing(v) {
		horizontalSpacing = v;

		var flow = (cast object : h2d.Flow);
		flow.horizontalSpacing = horizontalSpacing;

		return v;
	}


	function set_verticalSpacing(v) {
		verticalSpacing = v;

		var flow = (cast object : h2d.Flow);
		flow.verticalSpacing = verticalSpacing;

		return v;
	}
}