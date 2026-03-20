package effect;

class Effect extends h2d.Object {
	public var registry:Map<String, property.component.Input> = new Map();
	public var prefab:Null<prefab.Prefab> = null;


	public function new(?parent:h2d.Object) {
		super(parent);
		visible = false;
	}

	public function init(entry:prefab.Prefab) {}

	public function open() {
		visible = true;
	}
	
	public function close() {
		visible = false;
		prefab = null;
	}
}