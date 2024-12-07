import hxe.Prefab;

class App extends hxd.App {
	var card:Prefab;
	var button:Prefab;

	
	static function main() {
		new App();
	}


	override function init() {
		engine.backgroundColor = 0x222222;
		hxd.Res.initLocal();

		// Add `card.prefab`
		card = hxe.Lib.load("card", s2d);
		card.x = s2d.width * 0.5;
		card.y = s2d.height * 0.5 - 64;

		// Set card prefab title text
		var title:h2d.Text = card.get("title");
		title.text = "Deem";

		// Get type of the `title` object:
		var type = card.typeof("title");
		trace(type);

		// Add `button.prefab`
		button = hxe.Lib.load("button", s2d);
		button.x = s2d.width * 0.5;
		button.y = s2d.height - 128;

		// Set button prefab label text
		var label:h2d.Text = button.get("label");
		label.text = "Select";

		// Get interactive from button prefab
		var input:h2d.Interactive = button.get("input");
		input.onClick = onClick;
		input.onOver = onOver;
		input.onOut = onOut;
	}


	function onClick(e:hxd.Event) {
		var title:h2d.Text = card.get("title");
		title.text = title.text == "Grimm" ? "Reaper" : "Grimm";
	}


	function onOver(e:hxd.Event) {
		button.get("over").visible = true;
	}


	function onOut(e:hxd.Event) {
		button.get("over").visible = false;
	}
}