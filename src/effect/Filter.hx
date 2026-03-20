package effect;

import prefab.Prefab;


class Filter {
	public var list:Map<String, h2d.filter.Filter> = new Map();
	public var data:Map<String, Dynamic> = new Map();

	var filter:h2d.filter.Group;
	var prefab:Prefab;


	public function new(prefab:Prefab, ?source:Array<File.Entry>) {
		this.prefab = prefab;
		
		filter = new h2d.filter.Group();
		prefab.object.filter = filter;

		if (source != null) {
			for (entry in source) {
				var effect = build(entry);
				if (effect == null) continue;
	
				data.set(entry.name, entry.prop);
				add(entry.name, effect);
			}
		}
	}


	public function add(name:String, entry:h2d.filter.Filter) {
		list.set(name, entry);
		filter.add(entry);
	}


	public function get(name:String):Null<h2d.filter.Filter> {
		if (has(name)) return list.get(name);
		return null;
	}


	public function remove(name:String) {
		if (has(name)) {
			filter.remove(list.get(name));
			list.remove(name);
			data.remove(name);
		}
	}


	public function has(name:String):Bool {
		return list.exists(name);
	}


	public function count():Int {
		var all = 0;
		for (entry in list) all++;
		return all;
	}


	public function notEmpty():Bool {
		return data.iterator().hasNext();
	}


	public function serialize():Dynamic {
		var all = [];

		@:privateAccess
		for (entry in filter.filters) {
			var name = Type.getClassName(Type.getClass(entry)).split(".").pop();
			all.push({ name : name, prop : data.get(name) });
		}

		return all;
	}


	public static function from(filters:Array<File.Entry>):h2d.filter.Group {
		var group = new h2d.filter.Group();

		for (entry in filters) {
			var effect = build(entry);
			if (effect == null) continue;
			group.add(effect);
		}

		return group;
	}


	static function build(entry:File.Entry):Null<h2d.filter.Filter> {
		var effect:h2d.filter.Filter = null;

		switch (entry.name) {
			case "ColorMatrix":
				var colorMatrix = new h2d.filter.ColorMatrix();
				colorMatrix.matrix.adjustColor(entry.prop);
				effect = colorMatrix;

			case "DropShadow":
				effect = new h2d.filter.DropShadow();
				apply(effect, entry.prop);

			case "Outline":
				effect = new h2d.filter.Outline();
				apply(effect, entry.prop);

			case "Glow":
				effect = new h2d.filter.Glow();
				apply(effect, entry.prop);

			case "Blur":
				effect = new h2d.filter.Blur();
				apply(effect, entry.prop);
		}

		return effect;
	}


	static function apply(target:h2d.filter.Filter, props:Dynamic) {
		for (f in Reflect.fields(props)) {
			var v = Reflect.field(props, f);
			Reflect.setProperty(target, f, v);
		}
	}
}