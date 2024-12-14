import h2d.col.Point;
import h2d.Object;
import h2d.Bitmap;
import hxd.Event;

import ui.Touch;


enum State {
	None;
	Translate;
	Rotation;
	Scale;
	Size;
	Skew;
}


class Toolbar extends h2d.Object {
	var editor:Editor;
	var touch:Touch;

	var tools:Array<Tool> = [];
	var selected:Tool;

	public var width:Float = 40;
	public var height:Float = 40;
	public var size:Int = 40;

	public var tool:State = Translate;
	
	
	public function new(?parent:h2d.Object) {
		super(parent);

		editor = Editor.ME;

		touch = new Touch(width, height, this);
		touch.onClick = onClick;

		var offset = 0;

		var item = new Tool(this, 40 * offset++, 0);
		item.action = Translate;
		item.setIcon("position");
		tools.push(item);

		item.selected = true;
		selected = item;

		item = new Tool(this, 40 * offset++, 0);
		item.action = Rotation;
		item.setIcon("rotation");
		tools.push(item);

		item = new Tool(this, 40 * offset++, 0);
		item.action = Scale;
		item.setIcon("scale");
		tools.push(item);

		item = new Tool(this, 40 * offset++, 0);
		item.action = Size;
		item.setIcon("size");
		tools.push(item);

		var check = new CheckBox(this, 40 * offset++, 0);
		check.onSelect = editor.autoSelect;

		touch.width = tools.length * size;
		width = 40 + tools.length * size;

		filter = new h2d.filter.DropShadow(5, Math.PI/4, 0, 0.25, 20.0, 1, 1.0, true);
	}


	public function select(item:Tool) {
		if (selected == item) return;

		selected.selected = false;

		item.selected = true;
		tool = item.action;

		onChange(tool);

		selected = item;
	}


	function onClick(event:Event) {
		for (item in tools) {
			if (event.relX >= item.x && event.relX < item.x + size) {
				select(item);
			}
		}
	}


	public dynamic function onChange(tool:State) {
	}
}


class Tool extends h2d.Object {
	var back:h2d.Graphics;
	var face:h2d.Bitmap;
	
	var width:Float = 40;
	var height:Float = 40;

	public var selected(default, set):Bool;
	public var action:State = None;
	

	public function new(?parent:h2d.Object, x:Float = 0, y:Float = 0) {
		super(parent);

		this.x = x;
		this.y = y;

		back = new h2d.Graphics(this);
		back.beginFill(Style.toolbar);
		back.drawRect(0, 0, width, height);
		back.endFill();

		face = new h2d.Bitmap(h2d.Tile.fromColor(0xFFFFFF, 16, 16), this);
		face.tile.setCenterRatio();

		face.x = width * 0.5;
		face.y = height * 0.5;
	}

	
	public function setIcon(v:String) {
		face.tile = Assets.icon(v);
		face.tile.setCenterRatio();

		face.x = width * 0.5;
		face.y = height * 0.5;
	}


	function set_selected(value:Bool):Bool {
		selected = value;

		back.clear();
		back.beginFill(value ? Style.tool : Style.toolbar);
		back.drawRect(0, 0, width, height);
		back.endFill();

		return value;
	}
}


class CheckBox extends h2d.Object {
	var input:h2d.Interactive;

	var back:h2d.Bitmap;
	var checkbox:h2d.Bitmap;
	var select:h2d.Bitmap;

	public var selected(default, set):Bool = true;


	public function new(?parent:h2d.Object, x:Float, y:Float) {
		super(parent);

		input = new h2d.Interactive(40, 40, this);
		input.onClick = onClick;

		back = new h2d.Bitmap(h2d.Tile.fromColor(Style.toolbar, 40, 40), this);

		checkbox = new h2d.Bitmap(h2d.Tile.fromColor(Style.checkbox, 12, 12), this);
		checkbox.tile.setCenterRatio();
		checkbox.x = checkbox.y = 20;

		select = new h2d.Bitmap(h2d.Tile.fromColor(Style.checked, 8, 8), this);
		select.tile.setCenterRatio();
		select.x = select.y = 20;

		this.x = x;
		this.y = y;
	}


	function set_selected(value:Bool):Bool {
		selected = value;
		select.visible = value;
		return value;
	}


	function onClick(event:hxd.Event) {
		selected = !selected;
		onSelect(selected);
	}


	public dynamic function onSelect(value:Bool) {
	}
}