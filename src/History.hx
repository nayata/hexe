import Reflect;
import h2d.Object;
import prefab.Prefab;


class History {
	var undoElements : Array<Element> = [];
	var redoElements : Array<Element> = [];
	

	public function new() {}

	
	public function add(element:Element) {
		undoElements.push(element);
		redoElements = [];
	}


	public function clear() {
		undoElements = [];
		redoElements = [];
	}


	public function undo() {
		var element = undoElements.pop();
		
		if (element != null) {
			redoElements.push(element);
			element.undo();
		}

		Editor.ME.onHistory();
	}


	public function redo() {
		var element = redoElements.pop();

		if (element != null) {
			undoElements.push(element);
			element.redo();
		}

		Editor.ME.onHistory();
	}
}


class Element {
	public function new() {}
	public function undo() {}
	public function redo() {}
}


private typedef Properties = { x : Float, y :Float, scaleX : Float, scaleY : Float, rotation : Float };

class Transform extends Element {
	var object:h2d.Object;
	var from:Properties;
	var to:Properties;

	public function new(object:h2d.Object, from:Properties, to:Properties) {
		super();

		this.object = object;
		this.from = from;
		this.to = to;
	}

	override public function undo() {
		change(from);
	}

	override public function redo() {
		change(to);
	}

	inline function change(t:Properties) {
		object.x = t.x;
		object.y = t.y;
		object.scaleX = t.scaleX;
		object.scaleY = t.scaleY;
		object.rotation = t.rotation;

		Editor.ME.select(object.name);
	}
}


private typedef Size = { width : Float, height : Float };

class Resize extends Element {
	var prefab:Prefab;
	var from:Size;
	var to:Size;

	public function new(prefab:Prefab, from:Size, to:Size) {
		super();

		this.prefab = prefab;
		this.from = from;
		this.to = to;
	}

	override public function undo() {
		change(from);
	}

	override public function redo() {
		change(to);
	}

	inline function change(t:Size) {
		prefab.scaleX = t.width;
		prefab.scaleY = t.height;

		Editor.ME.select(prefab.object.name);
	}
}


private typedef Content = { parent : h2d.Object, index : Int };

class Hierarchy extends Element {
	var object:h2d.Object;
	var from:Content;
	var to:Content;

	public function new(object:h2d.Object, from:Content, to:Content) {
		super();
		
		this.object = object;
		this.from = from;
		this.to = to;
	}

	override public function undo() {
		from.parent.addChildAt(object, from.index);
	
		Editor.ME.outliner.onChange();
		Editor.ME.select(object.name);
	}
	
	override public function redo() {
		to.parent.addChildAt(object, to.index);
	
		Editor.ME.outliner.onChange();
		Editor.ME.select(object.name);
	}
}


class Add extends Element {
	var object:h2d.Object;
	var prefab:Prefab;

	var parent:h2d.Object;
	var index:Int;

	public function new(object:h2d.Object, prefab:Prefab, parent:h2d.Object, index:Int) {
		super();
		
		this.object = object;
		this.prefab = prefab;
		this.parent = parent;
		this.index = index;
	}

	override public function undo() {
		Editor.ME.delete(object, false);
	}

	override public function redo() {
		parent.addChildAt(object, index);
		Editor.ME.add(object, prefab, false);
	}
}


class Delete extends Element {
	var object:h2d.Object;
	var prefab:Prefab;

	var parent:h2d.Object;
	var index:Int;

	public function new(object:h2d.Object, prefab:Prefab, parent:h2d.Object, index:Int) {
		super();
		
		this.object = object;
		this.prefab = prefab;
		this.parent = parent;
		this.index = index;
	}

	override public function undo() {
		parent.addChildAt(object, index);
		Editor.ME.add(object, prefab, false);
	}

	override public function redo() {
		Editor.ME.delete(object, false);
	}
}


// HIDE `Dynamic` from `HistoryElement`
class Property extends Element {
	var object:Dynamic;
	var field:String;
	var from:Dynamic;
	var to:Dynamic;

	public function new(object:Dynamic, field:String, from:Dynamic, to:Dynamic) {
		super();
		
		this.object = object;
		this.field = field;
		this.from = from;
		this.to = to;
	}

	override public function undo() {
		Reflect.setProperty(object, field, from);
		Editor.ME.select(object.name);
	}

	override public function redo() {
		Reflect.setProperty(object, field, to);
		Editor.ME.select(object.name);
	}
}