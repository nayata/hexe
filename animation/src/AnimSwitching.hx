import hxe.Prefab;


class AnimSwitching extends hxd.App {
	var button:Prefab;
	var stage:Prefab;

	var player:Clip;
	
	static function main() {
		new AnimSwitching();
	}


	override function init() {
		engine.backgroundColor = 0x4E4E4E;
		hxd.Res.initLocal();

		stage = hxe.Lib.load("stage", s2d);

		button = hxe.Lib.load("button", s2d);
		button.x = s2d.width * 0.5;
		button.y = s2d.height - 128;

		var input:h2d.Interactive = button.get("input");
		input.onClick = onClick;
		input.onOver = onOver;
		input.onOut = onOut;

		// Player
		player = new Clip(s2d);
		player.x = s2d.width * 0.5;
		player.y = s2d.height * 0.5 + 64;
		player.scale(0.8);

		// Bind `cat.prefab` to player object
		hxe.Lib.bind("cat", player);

		// Add `hxe.Animation.Timeline` animations to `Clip.library`
		player.set("idle", hxe.Lib.from("idle", player));
		player.set("walk", hxe.Lib.from("walk", player));

		// Set `onEvent` and `onEnd` handlers
		player.onEvent = onEvent;
		player.onEnd = idle;

		// Set animation state
		player.state = "walk";
		player.playing = true;
	}


	function onEvent(event:String) {
		trace(event);
	}


	function idle() {
		if (player.state == "walk") {
			trace(player.state);
		}
	}


	function onClick(e:hxd.Event) {
		player.state = player.state == "walk" ? "idle" : "walk";
	}


	function onOver(e:hxd.Event) {
		button.get("over").visible = true;
	}


	function onOut(e:hxd.Event) {
		button.get("over").visible = false;
	}
}