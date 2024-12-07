package prefab;


class Object extends Prefab {

	public function new() {
		super();

		object = new h2d.Object();
		type = "object";
		link = "object";
	}


	override public function clone():Prefab {
		var prefab = new Object();
		prefab.copy(this);
		return prefab;
	}
}