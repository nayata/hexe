package property;

import property.component.Label;


class Project extends Property {
	var text:Label;
	var icon:h2d.Bitmap;

	public function new(?parent:h2d.Object) {
		super(parent);

		var label = new ui.Text("Project", 0, -40, this);

		text = new Label("untitled", 30, 6, this);

		icon = new h2d.Bitmap(Assets.icon("project"), this);
		icon.tile.setCenterRatio();
		icon.setPosition(10, 6);

		var input = new h2d.Interactive(240, 30, this);
		input.onClick = onClick;
		input.onOver = onOver;
		input.onOut = onOut;
		input.y = -10;
	}


	function onClick(event:hxd.Event) {
		var path = Editor.ME.file.filepath;

		if (path != "") {
			var cmd = "explorer.exe /select," + '"' + path + '"';
			Sys.command(cmd);
		}
	}


	function onOver(e:hxd.Event) {
		if (Editor.ME.file.filepath == "") return;

		icon.tile = Assets.icon("explorer");
		icon.tile.setCenterRatio();

		text.text = "Open Prefab in Explorer";
	}


	function onOut(e:hxd.Event) {
		if (Editor.ME.file.filepath == "") return;

		icon.tile = Assets.icon("project");
		icon.tile.setCenterRatio();

		text.text = Editor.ME.file.project;
	}


	override public function update() {
		text.text = Editor.ME.file.project;
	}


	override public function rebuild() {
		text.text = "untitled";
	}


	override public function select(object:Dynamic) {
		visible = false;
	}


	override public function unselect() {
		visible = true;
	}
}