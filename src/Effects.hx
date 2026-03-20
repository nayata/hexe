import effect.Effect;
import effect.Blending;
import effect.ColorMatrix;
import effect.DropShadow;
import effect.Outline;
import effect.Glow;
import effect.Blur;


class Effects extends ui.Window {
	var editor:Editor;

	var registry:Map<String, Effect> = new Map();
	var effect:Null<Effect> = null;

	var prefab:Null<prefab.Prefab> = null;

	var locking:h2d.Interactive;
	var navigation:h2d.Object;
	var container:h2d.Object;

	var toolbar:Array<Item> = [];
	var active:Null<Item> = null;

	
	public function new(?parent:h2d.Object) {
		super(parent);

		editor = Editor.ME;

		title = "Prefab Effects";
		content.clip = false;
		width = 560;
		height = 360;

		
		navigation = new h2d.Object(content);
		navigation.x = 20;
		navigation.y = 37;


		var item = new Item("Blending", "Blending", navigation);
		item.y = toolbar.length * 42;
		item.onSelect = onBlending;
		item.onEnable = onBlending;
		item.checked = true;
		toolbar.push(item);

		add("Adjust Color", "ColorMatrix");
		add("Drop Shadow", "DropShadow");
		add("Outline", "Outline");
		add("Glow", "Glow");
		add("Blur", "Blur");


		var divider = new h2d.Bitmap(h2d.Tile.fromColor(Style.divider, 3, 344), content);
		divider.x = 240 - 30 - 3;
		divider.y = 8;

		container = new h2d.Object(content);
		container.x = 240;
		container.y = 40;


		registry.set("Blending", new Blending(container));
		registry.set("ColorMatrix", new ColorMatrix(container));
		registry.set("DropShadow", new DropShadow(container));
		registry.set("Outline", new Outline(container));
		registry.set("Glow", new Glow(container));
		registry.set("Blur", new Blur(container));


		locking	= new h2d.Interactive(width - 240, height, content);
		locking.backgroundColor = 0x81373737;
		locking.cursor = Default;
		locking.x = container.x;
		locking.visible = false;

		editor.outliner.onDoubleClick = onOpen;

		visible = false;
	}


	override public function open(?name:String) {
		if (editor.selected == null) return;
		if (!registry.exists(name)) return;

		prefab = editor.children.get(editor.selected.name);

		if (prefab.type == "interactive" || prefab.type == "mask" || prefab.type == "collider") {
			prefab = null;
			return;
		}

		if (prefab.object.filter == null) {
			prefab.filter = new effect.Filter(prefab);
		}

		effect = registry.get(name);
		effect.init(prefab);
		effect.open();

		select(name);
		enable();

		visible = true;
		onResize();
	}


	override public function close() {
		if (effect != null) effect.close();

		prefab = null;
		visible = false;
	}


	public function onOpen() {
		open("Blending");
	}


	function add(text:String, value:String) {
		var item = new Item(text, value, navigation);
		item.y = toolbar.length * 42;

		item.onSelect = onSelect;
		item.onEnable = onEnable;
		
		toolbar.push(item);
	}


	public function select(value:String) {
		if (active != null) active.selected = false;

		for (node in toolbar) {
			node.checked = prefab.filter.has(node.value);
			if (node.value == "Blending") node.checked = true;

			if (node.value == value) {
				node.selected = true;
				active = node;
			}
		}
	}


	function onSelect(selected:Item) {
		if (effect != null && effect.name != selected.value) effect.close();

		effect = registry.get(selected.value);
		effect.init(prefab);
		effect.open();
		enable();

		if (active != null && active.value != selected.value) active.selected = false;
		active = selected;
	}


	function onEnable(selected:Item) {
		if (selected.checked == true) {
			if (effect != null && effect.name == selected.value) enable();

			var checked = registry.get(selected.value);
			checked.init(prefab);
		}
		else {
			if (effect != null && effect.name == selected.value) disable();

			if (prefab.filter.has(selected.value)) {
				prefab.filter.remove(selected.value);
				prefab.filter.data.remove(selected.value);
			}
		}
	}


	function onBlending(selected:Item) {
		selected.selected = true;
		onSelect(selected);
	}

	
	function enable() { locking.visible = false; }
	function disable() { locking.visible = true; }
}


class Item extends h2d.Object {
	var input:h2d.Interactive;

	var back:h2d.ScaleGrid;
	var checkbox:h2d.Bitmap;
	var label:h2d.Text;

	public var width:Int = 160;
	public var height:Int = 38;

	public var selected(default, set):Bool = false;
	public var checked(default, set):Bool = false;

	public var value:String = "";


	public function new(text:String, value:String, ?parent:h2d.Object) {
		super(parent);

		input = new h2d.Interactive(width, height, this);
		input.cursor = Default;
		input.onClick = onClick;

		back = new h2d.ScaleGrid(Assets.icon("dialogue"), 10, 10, this);
		back.width = width;
		back.height = height;
		back.visible = false;

		checkbox = new h2d.Bitmap(Assets.icon("checkbox"), this);
		checkbox.alpha = 0.25;
		checkbox.x = 10;
		checkbox.y = 11;

		label = new h2d.Text(Assets.defaultFont, this);
		label.textColor = Style.text;
		label.text = text;

		label.x = 40;
		label.y = height * 0.5 - label.textHeight * 0.5;

		this.value = value;
	}


	function onClick(event:hxd.Event) {
		if (event.relX > 40) {
			selected = true;
			onSelect(this);
		}
		else {
			checked = !checked;
			onEnable(this);
		}
	}


	public dynamic function onSelect(value:Item) {}
	public dynamic function onEnable(value:Item) {}


	function set_selected(v) {
		selected = v;

		back.visible = selected;
		if (!checked && selected) checked = true;

		return  v;
	}


	function set_checked(v) {
		checked = v;

		checkbox.tile = checked ? Assets.icon("checked") : Assets.icon("checkbox");
		checkbox.alpha = checked ? 1 : 0.25;

		return v;
	}
}