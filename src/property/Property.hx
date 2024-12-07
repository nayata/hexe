package property;

import property.component.Input;


class Property extends h2d.Layers {
	var registry:Map<String, Input> = new Map();
	var object:Null<Dynamic> = null;

	// Position style
	var top:Float = 0;
	var divider:Float = 20;
	var padding:Float = 6;

	var full:Float = 32;
	var tall:Float = 40;
	var half:Float = 14;

	var first:Float = 0;
	var second:Float = 74;
	var third:Float = 160;


	public function set(field:String, input:Input):Input {
		registry.set(field, input);
		input.field = field;
		return input;
	}


	public function select(object:Dynamic) {
		this.object = object;

		for (field => item in registry) {
			var value = Reflect.field(object, field);
			item.value = Std.string(value);
		}

		visible = true;
	}


	public function unselect() {
		for (item in registry) {
			item.blur();
		}

		object = null;
		visible = false;
	}


	public function update() {
		if (object == null) return;

		for (field => item in registry) {
			var value = Reflect.field(object, field);
			item.value = Std.string(value);
		}
	}


	public function rebuild() {
	}


	function onUpdate(prop:Dynamic) {
		Reflect.setProperty(object, prop.field, prop.to);
		Editor.ME.onProperty();
	}
	

	function onChange(prop:Dynamic) {
		if (object == null) return;

		Reflect.setProperty(object, prop.field, prop.to);
		Editor.ME.onProperty();

		if (prop.from == prop.to) return;

		Editor.ME.history.add(new History.Property(object, prop.field, prop.from, prop.to));
	}


	public dynamic function onFocus(o:h2d.Object) {}


	public function onResize() {
	}
}