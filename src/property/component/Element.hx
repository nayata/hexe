package property.component;

class Element extends h2d.Object {
	public var width:Float = 0;
	public var height:Float = 0;

	public var value:Dynamic = null;
	public var label:String = null;


	public function new(x:Float = 0, y:Float = 0, width:Float = 32, height:Float = 32, parent:h2d.Object) {
		super(parent);

		this.width = width;
		this.height = height;
		this.x = x;
		this.y = y;
	}


	public dynamic function select() {}


	public dynamic function unselect() {}


	public dynamic function highlight(v:Bool) {
	}
}