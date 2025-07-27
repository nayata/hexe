import hxe.Prefab;
import hxe.Animation;


class AnimSimple extends hxd.App {
	var intro:Animation;

	
	static function main() {
		new AnimSimple();
	}


	override function init() {
		engine.backgroundColor = 0x4E4E4E;
		hxd.Res.initLocal();

		intro = hxe.Lib.animate("haxe", s2d);
		intro.playing = true;

		intro.onEnd = onEnd;
	}


	function onEnd() {
		trace("Animation End");
	}
}