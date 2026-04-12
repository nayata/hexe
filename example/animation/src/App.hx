import hxe.Prefab;
import hxe.Animation;

class App extends hxd.App {
	var player:Animation;
	var button:Button;

	
	static function main() {
		new App();
	}


	override function init() {
		engine.backgroundColor = 0x383838;
		hxd.Res.initLocal();

		// Player
		player = new Animation("cat", s2d);
		player.x = s2d.width * 0.5;
		player.y = s2d.height * 0.5 + 32;

		player.set("idle", Animation.from("idle", player));
		player.set("walk", Animation.from("walk", player));

		player.onEvent = onEvent;
		player.onEnd = onEnd;

		player.state = "idle";
		player.playing = true;


		// Add `button.prefab`
		button = new Button("button", s2d);
		button.x = s2d.width * 0.5;
		button.y = s2d.height - 128;

		button.onClick = onClick;
		button.text = "State: idle";
	}


	function onEvent(event:String) {
		trace("Event: " + event);
	}


	function onEnd() {
		trace("Animation end");
	}


	function onClick() {
		player.state = player.state == "idle" ? "walk" : "idle";
		button.text = "State: " + player.state;
	}
}