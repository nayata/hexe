import property.Property;
import property.Transform;
import property.Bitmap;
import property.Interactive;
import property.ScaleGrid;
import property.Graphics;
import property.Prefab;
import property.Text;
import property.Mask;
import property.Name;


class Properties extends h2d.Layers {
	var editor:Editor;
	
	var properties:Map<String, Property> = new Map();
	var property:Property = null;

	public var width:Float = 280;
	public var height:Float = 900;

	var uid:Name;
	var transform:Transform;
	var label:ui.Text;
	
	
	public function new(?parent:h2d.Object) {
		super(parent);

		editor = Editor.ME;

		// Name
		uid = new Name(this);
		uid.visible = false;
		uid.x = 30;
		uid.y = 60;

		label = new ui.Text("Properties", 0, -40, uid);

		// Object transform
		transform = new Transform(this);
		transform.onFocus = onFocus;
		transform.visible = false;
		transform.x = 30;
		transform.y = 120;


		// Bitmap Prefab
		var element:Property = new Bitmap(this);
		element.visible = false;
		element.x = 30;
		element.y = 346;
		properties.set("bitmap", element);


		// Text Prefab
		element = new Text(this);
		element.visible = false;
		element.x = 30;
		element.y = 346;
		properties.set("text", element);


		// Graphics Prefab
		element = new Graphics(this);
		element.onFocus = onFocus;
		element.visible = false;
		element.x = 30;
		element.y = 346;
		properties.set("graphics", element);


		// Interactive Prefab
		element = new Interactive(this);
		element.onFocus = onFocus;
		element.visible = false;
		element.x = 30;
		element.y = 346;
		properties.set("interactive", element);


		// ScaleGrid Prefab
		element = new ScaleGrid(this);
		element.onFocus = onFocus;
		element.visible = false;
		element.x = 30;
		element.y = 346;
		properties.set("scalegrid", element);


		// Mask Prefab
		element = new Mask(this);
		element.onFocus = onFocus;
		element.visible = false;
		element.x = 30;
		element.y = 346;
		properties.set("mask", element);


		// Linked Prefab
		element = new Prefab(this);
		element.visible = false;
		element.x = 30;
		element.y = 346;
		properties.set("prefab", element);

		over(transform);
	}


	public function select(object:h2d.Object) {
		var prefab = editor.children.get(object.name);

		transform.select(object);
		uid.select(prefab);

		if (property != null) property.unselect();

		if (properties.exists(prefab.type)) {
			property = properties.get(prefab.type);
			property.select(prefab);
		}
	}


	public function unselect() {
		transform.unselect();
		uid.unselect();

		if (property != null) property.unselect();
		property = null;
	}


	public function onChange() {
		transform.update();
	}


	function onFocus(o:h2d.Object) {
		over(o);
	}


	public function rebuild(name:String) {
		if (properties.exists(name)) {
			properties.get(name).rebuild();
		}
	}


	public function clear() {
		for (item in properties) {
			item.rebuild();
		}
	}


	public function onResize() {
		for (item in properties) {
			item.onResize();
		}
	}
}