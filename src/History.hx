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


	public function append(child:Element) {
		if (undoElements.length == 0) return;

		var element = undoElements[undoElements.length - 1];
		element.child = child;
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
	public var child:Element;
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
		
		if (child != null) child.undo();
		Editor.ME.select(object.name);
	}

	override public function redo() {
		change(to);

		if (child != null) child.redo();
		Editor.ME.select(object.name);
	}

	inline function change(t:Properties) {
		object.x = t.x;
		object.y = t.y;
		object.scaleX = t.scaleX;
		object.scaleY = t.scaleY;
		object.rotation = t.rotation;
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

		if (child != null) child.undo();
		Editor.ME.select(object.name);
	}

	override public function redo() {
		Reflect.setProperty(object, field, to);

		if (child != null) child.redo();
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


// Animation
private typedef Keyframe = { x : Float, y : Float, scaleX : Float, scaleY : Float, rotation : Float, alpha : Float };
private typedef Frame = { time : Int, field : String, from : Float, to : Float, added : Bool };


// Edit Keyframe
class Key extends Element {
	var motion:Array<Frame>;
	var object:h2d.Object;

	public function new(object:h2d.Object, motion:Array<Frame>) {
		super();
		
		this.object = object;
		this.motion = motion;
	}

	override public function undo() {
		var time = 0;

		for (frame in motion) {
			if (!frame.added) Editor.ME.motion.animation.set(object.name, frame.field, frame.from, frame.time);
			if (frame.added) Editor.ME.motion.animation.clear(object.name, frame.field, frame.time);

			time = frame.time;
		}

		
		Editor.ME.motion.animation.update();
		Editor.ME.motion.onHistory(time);
	}

	override public function redo() {
		for (frame in motion) {
			Editor.ME.motion.animation.set(object.name, frame.field, frame.to, frame.time);
			Editor.ME.motion.onHistory(frame.time);
			Editor.ME.motion.animation.update();
		}
	}
}

class Edit extends Element {
	var motion:Array<Element>;
	var name:String;

	public function new(name:String, motion:Array<Element>) {
		super();
		
		this.motion = motion;
		this.name = name;
	}

	override public function undo() {
		for (element in motion) element.undo();
		change();
	}

	override public function redo() {
		for (element in motion) element.redo();
		change();
	}

	inline function change() {
		Editor.ME.motion.animation.update();
		Editor.ME.motion.onEvent();
		Editor.ME.select(name);
	}
}


class Set extends Element {
	var name:String;
	var type:String;
	var data:Float;
	var time:Int;

	public function new(name:String, type:String, data:Float, time:Int) {
		super();
		
		this.name = name;
		this.type = type;
		this.data = data;
		this.time = time;
	}

	override public function undo() {
		Editor.ME.motion.animation.clear(name, type, time);
	}

	override public function redo() {
		Editor.ME.motion.animation.set(name, type, data, time);
	}
}


class Clear extends Element {
	var name:String;
	var type:String;
	var ease:String;
	var data:Float;
	var time:Int;

	public function new(name:String, type:String, ease:String, data:Float, time:Int) {
		super();
		
		this.name = name;
		this.type = type;
		this.ease = ease;
		this.data = data;
		this.time = time;
	}

	override public function undo() {
		Editor.ME.motion.animation.set(name, type, data, time);
		Editor.ME.motion.animation.ease(name, type, ease, time);
	}

	override public function redo() {
		Editor.ME.motion.animation.clear(name, type, time);
	}
}


class Ease extends Element {
	var name:String;
	var type:String;
	var time:Int;

	var from:String;
	var to:String;

	public function new(name:String, type:String, from:String, to:String, time:Int) {
		super();
		
		this.name = name;
		this.type = type;
		this.time = time;

		this.from = from;
		this.to = to;
	}

	override public function undo() {
		Editor.ME.motion.animation.ease(name, type, from, time);
	}

	override public function redo() {
		Editor.ME.motion.animation.ease(name, type, to, time);
	}
}


class Time extends Element {
	var name:String;
	var type:String;

	var from:Int;
	var to:Int;

	public function new(name:String, type:String, from:Int, to:Int) {
		super();
		
		this.name = name;
		this.type = type;

		this.from = from;
		this.to = to;
	}

	override public function undo() {
		Editor.ME.motion.animation.move(name, type, to, from);

		Editor.ME.motion.animation.update();
		Editor.ME.select(name);
	}

	override public function redo() {
		Editor.ME.motion.animation.move(name, type, from, to);

		Editor.ME.motion.animation.update();
		Editor.ME.select(name);
	}
}


class Event extends Element {
	var name:String;
	var data:String;
	var type:String;
	var time:Int;

	public function new(name:String, data:String, type:String, time:Int) {
		super();
		
		this.name = name;
		this.data = data;
		this.type = type;
		this.time = time;
	}

	override public function undo() {
		if (type == "add") Editor.ME.motion.animation.clear(name, "event", time);
		if (type == "set") Editor.ME.motion.animation.event(data, time);
		if (type == "delete") Editor.ME.motion.animation.event(name, time);
	}

	override public function redo() {
		if (type == "add") Editor.ME.motion.animation.event(name, time);
		if (type == "set") Editor.ME.motion.animation.event(name, time);
		if (type == "delete") Editor.ME.motion.animation.clear(name, "event", time);
	}
}