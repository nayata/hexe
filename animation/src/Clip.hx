class Clip extends hxe.Animation {
	public var library:Map<String, hxe.Animation.Timeline> = new Map();
	public var state(default, set):String = "default";


	public function set(name:String, data:hxe.Animation.Timeline) {
		library.set(name, data);

		if (animation == null) {
			animation = library.get(name);
			state = name;
		}
	}
	

	function set_state(name:String) {
		if (!library.exists(name)) return state;
		if (state == name) return state;

		animation = library.get(name);
		state = name;
		time = 0;

		update(time);

		return state;
	}
}