import filter.Color;
import filter.DropShadow;
import filter.Outline;
import filter.Glow;
import filter.Blur;


class Effects {
	var editor:Editor;
	var registry:Map<String, filter.Effect> = new Map();
	
	
	public function new(parent:h2d.Object) {
		editor = Editor.ME;

		registry.set("Color", new Color(parent));
		registry.set("DropShadow", new DropShadow(parent));
		registry.set("Outline", new Outline(parent));
		registry.set("Glow", new Glow(parent));
		registry.set("Blur", new Blur(parent));
	}


	public function open(name:String) {
		if (editor.selected == null) return;
		if (!registry.exists(name)) return;

		var prefab = editor.children.get(editor.selected.name);

		if (prefab.type == "interactive" || prefab.type == "mask" || prefab.type == "collider") return;

		var effect = registry.get(name);
		
		if (!effect.allowed(prefab)) return;

		effect.init(prefab);
		effect.open();
	}
}