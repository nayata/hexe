package property;

import property.component.Label;
import property.component.Input;
import property.component.Number;
import property.component.Checkbox;
import property.component.Anchor;
import property.component.File;


class Texture extends Bitmap {


	public function new(?parent:h2d.Object) {
		super(parent);
		file.icon = "texture";
	}


	override function onFile(prop:Dynamic) {
		function onSelect(name:String) {
			onChange({ field : "image", from : file.value, to : name });
			file.value = name;

			Editor.ME.texture.onSelect = null;
		}

		var prefab = (cast object : prefab.Bitmap);

		Editor.ME.texture.onSelect = onSelect;
		Editor.ME.texture.open(prefab.atlas);
	}
}