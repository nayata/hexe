package filter;

import prefab.Prefab;


class Filter {
	public var data:Map<String, Dynamic> = new Map();

	var filter:h2d.filter.Group;
	var prefab:Prefab;


	public function new(prefab:Prefab, ?source:Array<File.Entry>) {
		this.prefab = prefab;
		
		filter = new h2d.filter.Group();
		prefab.object.filter = filter;

		if (source != null) {
			for (entry in source) {
				var f:h2d.filter.Filter = null;
	
				switch (entry.name) {
					case "DropShadow" : f = new h2d.filter.DropShadow();
					case "Outline" : f = new h2d.filter.Outline();
					case "Glow" : f = new h2d.filter.Glow();
					case "Blur" : f = new h2d.filter.Blur();
					default : continue;
				}
	
				data.set(entry.name, entry.prop);
				apply(f, entry.prop);
				filter.add(f);
			}
		}
	}


	public function add(entry:h2d.filter.Filter) {
		filter.add(entry);
	}


	public function get(cls:Class<h2d.filter.Filter>):h2d.filter.Filter {
		@:privateAccess for (f in filter.filters) {
			if (Type.getClass(f) == cls) return f;
		}
	
		return null;
	}


	public function remove(cls:Class<h2d.filter.Filter>) {
		@:privateAccess for (f in filter.filters) {
			if (Type.getClass(f) == cls) filter.filters.remove(f);
		}
	}


	public function has():Bool {
		return data.iterator().hasNext();
	}


	public function serialize():Dynamic {
		var all = [];

		for (name => value in data) {
			all.push({ name : name, prop : value });
		}

		return all;
	}


	public static function build(filters:Array<File.Entry>):h2d.filter.Group {
		var group = new h2d.filter.Group();

		for (entry in filters) {
			var filter:h2d.filter.Filter = null;

			switch (entry.name) {
				case "DropShadow" : filter = new h2d.filter.DropShadow();
				case "Outline" : filter = new h2d.filter.Outline();
				case "Glow" : filter = new h2d.filter.Glow();
				case "Blur" : filter = new h2d.filter.Blur();
				default : continue;
			}

			apply(filter, entry.prop);
			group.add(filter);
		}

		return group;
	}


	static function apply(target:h2d.filter.Filter, props:Dynamic) {
		for (f in Reflect.fields(props)) {
			var v = Reflect.field(props, f);
			Reflect.setProperty(target, f, v);
		}
	}
}