package hxe;


class Prefab extends h2d.Object {
	@:allow(hxe.Lib) var hierarchy:Map<String, Dynamic> = new Map();


	/**
		Check if the prefab has a object in the hierarchy with the given `n` name.
	**/
	public function has(n:String):Bool {
		return hierarchy.exists(n);
	}


	/**
		Get an object from the prefab hierarchy with the given name `n`.
	**/
	public function get<T>(n:String):Null<T> {
		return hierarchy.get(n);
	}


	/**
		Find all objects of the given class `c` in the prefab hierarchy.
		@param all An optional array instance to fill results with. Allocates a new array if not set.
	**/
	public function getAll<T:h2d.Object>(c:Class<T>, ?all:Array<T>):Array<T> {
		if (all == null) all = [];
		
		for (o in hierarchy) {
			var i = Std.downcast(o, c);
			if (i != null) all.push(i);
		}
		return all;
	}


	/** Check if the prefab matches the given class `c`. **/
	public function is<T:Prefab>(c:Class<T>) return Std.isOfType(this, c);

	
	/** Converts the prefab to another `c` prefab class. **/
	public function as<T:Prefab>(c:Class<T>) : T return Std.downcast(this, c);


	/**
		Get the class name of the object from the prefab hierarchy with the given name `n`.
	**/
	public function typeof(n:String):String {
		if (!hierarchy.exists(n)) return "Object not found";
		
		var cl = Type.getClass(hierarchy.get(n));
		return Type.getClassName(cl);
	}
}