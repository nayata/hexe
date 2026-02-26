import h2d.Object;
import h2d.Bitmap;
import h2d.Layers;
import hxd.Event;
import h2d.col.Point;

import ui.Touch;


class Outliner extends h2d.Object {
	var editor:Editor;

	var touch:Touch;
	var highlight:Bitmap;
	var selection:Bitmap;
	var cursor:Bitmap;
	var ghost:Node;

	var scroller:h2d.Mask;
	var container:Object;
	var view:Object;

	var label:ui.Text;
	var dragger:ui.Dragger;

	var scrollBar:h2d.Bitmap;
	var barCursor:h2d.Bitmap;

	var nodes:Array<Node> = [];

	var highlighted:Node = null;
	var selected:Node = null;
	var draged:String = "";

	public var width:Int = 300;
	public var height:Int = 30;

	public var position:Int = 120;
	public var size:Int = 30;

	var dragStart:Float = 0;
	var dragScroll = 0;

	
	public function new(?parent:h2d.Object) {
		super(parent);

		editor = Editor.ME;

		label = new ui.Text("Outliner", 30, -40, this);

		touch = new Touch(width, position, this);
		touch.onPush = onDown;
		touch.onMove = onMove;
		touch.onRelease = onUp;
		touch.onWheel = onWheel;
		touch.onOver = onOver;
		touch.onOut = onOut;

		scroller = new h2d.Mask(width, position, this);
		container = new Object(scroller);

		highlight = new Bitmap(h2d.Tile.fromColor(Style.highlight, width, size), container);
		highlight.visible = false;

		selection = new Bitmap(h2d.Tile.fromColor(Style.selection, width, size), container);
		selection.visible = false;

		view = new Object(container);

		cursor = new Bitmap(h2d.Tile.fromColor(Style.hover, width, size), this);
		cursor.visible = false;

		dragger = new ui.Dragger(this);
		dragger.onChange = onDragger;
		dragger.onDrag = onDraggerPush;

		dragger.width = width;
		dragger.height = 40;

		dragger.maxHeight = 900 - dragger.height - 60 - 60;
		dragger.position = position;
		dragger.y = dragger.position;

		scrollBar = new Bitmap(h2d.Tile.fromColor(Style.scrollBackground, 10, 10), this);
		barCursor = new Bitmap(h2d.Tile.fromColor(Style.scrollBar, 10, 10), scrollBar);

		scrollBar.width = scrollBar.height = 10;
		barCursor.width = barCursor.height = 10;

		scrollBar.x = width - scrollBar.width;
		scrollBar.visible = false;

		ghost = new Node(this);
		ghost.addChildAt(new Bitmap(h2d.Tile.fromColor(Style.selection, width, size)), 0);
		ghost.filter = new h2d.filter.DropShadow(0, Math.PI/4, 0, 0.5, 5.0, 1, 1.0, true);
		ghost.visible = false;
	}


	public function add(name:String, link:String = "prefab") {
		var node = new Node(view);

		node.name = name;
		node.text = link;
		node.y = nodes.length * size;
		node.id = nodes.length;
		nodes.push(node);

		height = nodes.length * size;
	}


	public function delete(object:h2d.Object) {
		var all:Array<Object> = getAllChildren(object);

		for (child in all) {
			for (node in nodes) {
				if (node.name == child.name) {
					nodes.remove(node);
					node.remove();
				}
			}
		}

		height = nodes.length * size;
	}


	public function make() {
		var all:Array<Object> = getHierarchy(editor.scene);

		editor.hierarchy = all;

		for (child in all) {
			add(child.name);
		}
	}


	public function rename(name:String, link:String = "prefab") {
		for (node in nodes) {
			if (node.name == name) node.text = link;
		}
	}


	public function clear() {
		scrollBar.visible = false;
		highlight.visible = false;
		cursor.visible = false;
		unselect();

		view.removeChildren();
		nodes = [];

		container.y = 0;
		
		height = size;
	}


	public function select(object:h2d.Object) {
		for (node in nodes) {
			if (node.name == object.name) {
				selected = node;

				selection.visible = true;
				selection.y = selected.y;

				scrollToSelected();
			}
		}
	}


	function scrollToSelected() {
		if (selected == null) return;
		if (height <= position) return;

		var top = selected.y + container.y;
		var bottom = top + size;
	
		if (top >= 0 && bottom <= position) return;

		if (top < 0) {
			container.y = -selected.y;
		}
		else if (bottom > position) {
			container.y = -selected.y + position - size;
		}
	
		container.y = Math.max(-(height - position), container.y);
		container.y = Math.min(0, container.y);

		onScroll();
	}


	function scrollOnDrag() {
		if (selected == null) return;
		if (dragScroll == 0) return;

		if (height <= dragger.y && container.y == 0) return;

		container.y -= dragScroll * 10;
		container.y = Math.max(-(height - position), container.y);
		container.y = Math.min(0, container.y);

		onScroll();
	}


	public function unselect() {
		selection.visible = false;
		selected = null;
	}

	
	function onDown(event:Event) {
		if (highlighted != null && event.button == 0) {
			editor.select(highlighted.name);

			draged = highlighted.name;
			ghost.text = highlighted.text;

			if (event.relX >= width - size * 2) {
				var object = editor.children.get(highlighted.name).object;
				object.visible = !object.visible;

				highlighted.visibility = object.visible;
			}

			touch.left = true;
		}

		if (highlighted != null && event.button == 1) {
			editor.select(highlighted.name);
			editor.context.open();

			touch.right = true;
		}
	}

	
	function onMove(event:Event) {
		// Prepare to pick a node
		highlighted = null;

		// Mouse relative to scrolled container
		var mouseY = event.relY - container.y;

		for (node in nodes) {
			if (mouseY >= node.y && mouseY < node.y + size) {
				highlighted = node;
			}
		}


		// Highlight picked node
		if (!touch.left) {
			highlight.visible = highlighted != null ? true : false;
			highlight.y = highlighted != null ? highlighted.y : 0;
		}


		// Show drop position
		if (!touch.left) return;

		if (selected != null) {
			dragScroll = 0;

			if (event.relY > scroller.height - 15) dragScroll = 1;
			if (event.relY < 15) dragScroll = -1;

			// Selected ghost
			ghost.x = editor.s2d.mouseX - x + 5;
			ghost.y = editor.s2d.mouseY - y + 5;

			ghost.x = event.relX + 5;
			ghost.y = event.relY + 5;

			ghost.visible = true;
		}

		if (selected != null && highlighted != null) {
			var area = Math.abs(highlighted.y - mouseY) / size;

			if (area < 0.25) {
				cursor.y = highlighted.y + container.y - 2;
				cursor.visible = true;

				cursor.width = width;
				cursor.height = 4;
			} 
			else if (area > 0.75) {
				cursor.y = highlighted.y + container.y + size - 2;
				cursor.visible = true;

				cursor.width = width;
				cursor.height = 4;
			} 
			else {
				cursor.y = highlighted.y + container.y;
				cursor.visible = true;

				cursor.width = 6;
				cursor.height = size;
			}
		}
	}

	
	function onUp(event:Event) {
		// Move object to the end of the hierarchy if the mouse.y > nodes.height
		var mouseY = event.relY - container.y;

		if (touch.left && selected != null && highlighted == null) {
			if (mouseY > nodes.length * size) {
				var object = editor.children.get(selected.name).object;

				moveObject(object, editor.scene, editor.scene.children.length);
			} 
		}

		// Hide hovers and reset mouse down
		highlight.visible = false;
		cursor.visible = false;
		ghost.visible = false;
		touch.left = false;
		touch.right = false;

		dragScroll = 0;

		// Get the new position and move object
		if (selected != null && highlighted != null) {
			if (selected == highlighted) return;

			var area = Math.abs(highlighted.y - mouseY) / size;

			var object = editor.children.get(selected.name).object;
			var nextObject:Object;

			var order:Int = 0;
			var index:Int = 0;

			if (area < 0.25) {
				nextObject = editor.children.get(highlighted.name).object;

				order = highlighted.y > selected.y ? -1 : 0;
				index = nextObject.parent.getChildIndex(nextObject);

				moveObject(object, nextObject.parent, index + order);
			}
			else if (area > 0.75) {
				nextObject = editor.children.get(highlighted.name).object;

				order = highlighted.y < selected.y ? 1 : 0;
				index = nextObject.parent.getChildIndex(nextObject);

				moveObject(object, nextObject.parent, index + order);
			}
			else {
				nextObject = editor.children.get(highlighted.name).object;
				index = nextObject.children.length;

				moveObject(object, nextObject, index);
			}
		}
	}


	function moveObject(object:Object, newParent:Object, index:Int) {
		var newParentIsChild = false;

		var p = newParent;
		while (p != null) {
			if (p == object) newParentIsChild = true;
			p = p.parent;
		}

		if (newParentIsChild) return;
		if (newParent == editor.s2d) return;


		// Checking if Prefab is locked
		// TODO: show exp. message
		var newParentIsLocked = false;

		if (newParent.name != "root") newParentIsLocked = editor.children.get(newParent.name).locked;
		if (newParentIsLocked) return;


		// Store object position for history
		var undo = { parent : object.parent, index : object.parent.getChildIndex(object) };

		// Add object to the new parent
		newParent.addChildAt(object, index);

		// Send all to history
		var redo = { parent : object.parent, index : object.parent.getChildIndex(object) };

		editor.history.add(new History.Hierarchy(object, undo, redo));


		onDraged();
	}


	public function onView() {
		var all = editor.hierarchy;

		for (i in 0...all.length) {
			var prefab = editor.children.get(nodes[i].name);
			nodes[i].text = prefab.link;
		}
	}


	public function onChange() {
		var all:Array<Object> = getHierarchy(editor.scene);

		editor.hierarchy = all;

		checkNodes(all.length);

		for (i in 0...all.length) {
			nodes[i].name = all[i].name;
			nodes[i].y = i * size;
			nodes[i].id = i;

			nodes[i].padding = getPadding(all[i].parent) * 20;
			nodes[i].visibility = all[i].visible;

			var prefab = editor.children.get(nodes[i].name);

			nodes[i].text = prefab.link;
			nodes[i].icon = prefab.type;
		}

		height = nodes.length * size;
		onScroll();
	}


	public function onDraged() {
		onChange();
		editor.select(draged);
	}


	function onOver(event:hxd.Event) {
		touch.focus();
	}


	function onOut(event:hxd.Event) {
		highlight.visible = false;
		cursor.visible = false;
		touch.blur();
	}

	
	function onWheel(event:hxd.Event) {
		if (height <= dragger.y && container.y == 0) return;

		event.propagate = false;

		container.y -= event.wheelDelta * size;
		container.y = Math.max(-(height - position), container.y);
		container.y = Math.min(0, container.y);

		onScroll();
	}


	function onDragger() {
		position = Std.int(dragger.y);

		scroller.height = position;
		touch.height = position;

		if (container.y < 0) {
			container.y = position - dragStart;
			container.y = Math.max(-(height - position), container.y);
			container.y = Math.min(0, container.y);
		}

		onScroll();
		onSize();
	}


	function onDraggerPush() {
		dragStart = dragger.y - container.y;
	}


	function onScroll() {
		if (height <= position) {
			scrollBar.visible = false;
		}
		else {
			scrollBar.visible = true;
			scrollBar.height = Math.ceil(position);
			barCursor.height = hxd.Math.imax(1, Std.int(position * (1 - (height - position) / height)));
		}

		if (dragger.y < 1) scrollBar.visible = false;

		var paddingTop = Std.int(container.y * (position - barCursor.height) / (height - position));
		barCursor.y = -paddingTop;
	}


	public function onResize() {
		dragger.maxHeight = editor.HEIGHT - dragger.height - 60 - 60;

		if (dragger.position > dragger.maxHeight) {
			dragger.position = dragger.maxHeight;
		}
		if (dragger.position < dragger.minHeight) {
			dragger.position = dragger.minHeight + size;
		}
		dragger.y = dragger.position;
		onDragger();
	}


	public dynamic function onSize() {
	}


	public function getHierarchy(object:h2d.Object) {
		var all:Array<Object> = getAllChildren(object);
		all.remove(object);

		return all;
	}


	function getAllChildren(object:h2d.Object, ?data:Array<Object>) {
		if (data == null) data = [];

		data.push(object);
		
		// `h2d.Text` have `numChildren` > 0
		// Linked Prefab childrens should be skiped
		// h2d.Anim, h2d.ScaleGrid [?]

		if (object.name != "root") {
			var prefab = editor.children.get(object.name);
			if (prefab.locked) return data;
		}

		for (child in object.children) {
			data = getAllChildren(child, data);
		} 

		return data;
	}


	function checkNodes(allChildren:Int) {
		if (allChildren == nodes.length) return;

		var difference = allChildren - nodes.length;
		for (i in 0...difference) {
			add("empty");
		}
	}


	function getPadding(object:h2d.Object) {
		var distance = 0;

		var p = object;
		while (p != editor.scene) {
			distance++;
			p = p.parent;
		}

		return distance;
	}


	override function sync(ctx:h2d.RenderContext) {
		super.sync(ctx);
		scrollOnDrag();
	}
}


class Node extends h2d.Object {
	var tile:h2d.Bitmap;
	var view:h2d.Bitmap;
	var label:h2d.Text;
	
	var width:Float = 300;
	var height:Float = 30;

	public var visibility(default, set):Bool = true;
	public var padding(default, set):Int = 0;

	public var icon(never, set):String;
	public var text(get, set):String;
	public var id:Int = -1;


	public function new(?parent:h2d.Object) {
		super(parent);

		tile = new h2d.Bitmap(h2d.Tile.fromColor(Style.icon, 16, 12), this);
		tile.tile.setCenterRatio();

		tile.x = 40;
		tile.y = height * 0.5;

		view = new h2d.Bitmap(Assets.icon("visible"), this);
		view.tile.setCenterRatio();

		view.x = width - 40;
		view.y = height * 0.5;

		label = new h2d.Text(Assets.defaultFont, this);
		label.textColor = Style.label;
		label.textAlign = h2d.Text.Align.Left;
		label.smooth = true;
		label.text = "text";

		label.x = 60;
		label.y = height*0.5 - label.textHeight*0.5;
	}


	function set_visibility(v) {
		view.tile = v ? Assets.icon("visible") : Assets.icon("hidden");
		view.tile.setCenterRatio();

		return visibility = v;
	}


	function set_icon(v) {
		tile.tile = Assets.icon(v);
		tile.tile.setCenterRatio();

		tile.x = 40 + padding;
		tile.y = height * 0.5;

		return v;
	}


	function set_padding(v) {
		label.x = 60 + v;
		tile.x = 40 + v;

		return padding = v;
	}


	function get_text():String {
		return label.text;
	}


	function set_text(t:String) {
		label.text = t;
		return t;
	}
}