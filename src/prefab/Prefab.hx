package prefab;


class Prefab {
	public var object:h2d.Object;

	public var name:String = "prefab";
	public var type:String = "prefab";
	public var link:String = "prefab";

	public var x:Float = 0;
	public var y:Float = 0;

	public var width(default, set):Float = 0;
	public var height(default, set):Float = 0;

	public var scaleX(get, set):Float;
	public var scaleY(get, set):Float;

	public var pivotX:Float = 0;
	public var pivotY:Float = 0;

	public var locked:Bool = false;
	public var fixed:Bool = false;

	public var src:String = "";


	public function new() {}


	public function serialize():Dynamic {
		var data:Dynamic = {};

		data.name = name;
		data.type = type;
		data.link = link;

		if (object.parent.name != "root") data.parent = object.parent.name;

		if (object.x != 0) data.x = object.x;
		if (object.y != 0) data.y = object.y;

		if (object.scaleX != 1) data.scaleX = object.scaleX;
		if (object.scaleY != 1) data.scaleY = object.scaleY;

		if (object.rotation != 0) data.rotation = object.rotation;
		
		if (object.blendMode != h2d.BlendMode.Alpha) data.blendMode = Std.string(object.blendMode);
		if (object.alpha != 1) data.alpha = object.alpha;
		if (!object.visible) data.visible = false;

		return data;
	}


	public function clone():Prefab {
		return null;
	}


	function copy(prefab:Prefab) {
		object.x = prefab.object.x;
		object.y = prefab.object.y;

		object.scaleX = prefab.object.scaleX;
		object.scaleY = prefab.object.scaleY;

		object.rotation = prefab.object.rotation;

		object.blendMode = prefab.object.blendMode;
		object.alpha = prefab.object.alpha;
		object.visible = prefab.object.visible;
	}


	function set_width(v) return width = v;
	function set_height(v) return height = v;


	function get_scaleX() return width;
	function get_scaleY() return height;

	
	function set_scaleX(v) return width;
	function set_scaleY(v) return height;
}