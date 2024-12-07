package property;
import property.component.Text;


class Name extends Property {
	public function new(?parent:h2d.Object) {
		super(parent);

		var input = new Text(this);
		
		input.onUpdate = onUpdate;
		input.onChange = onChange;
		input.label = "Name";
		input.field = "link";

		input.setSize(240, 40);

		registry.set(input.field, input);
	}


	override function onUpdate(prop:Dynamic) {
		Reflect.setProperty(object, prop.field, prop.to);
		Editor.ME.onName();
	}


	override function onChange(prop:Dynamic) {
		if (object == null) return;

		Reflect.setProperty(object, prop.field, prop.to);
		Editor.ME.onName();

		if (prop.from == prop.to) return;

		Editor.ME.history.add(new History.Property(object, prop.field, prop.from, prop.to));
	}
}