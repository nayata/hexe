import h2d.Object;
import h2d.Bitmap;
import h2d.Graphics;

import h2d.col.Bounds;
import h2d.col.Point;
import hxd.Event;
import h3d.Vector;
import hxd.Key;

import prefab.Prefab;

import ui.Touch;
import ui.Grid;


class Control extends h2d.Object {
	var editor:Editor;

	var s2d:h2d.Scene;
	var scene:Object;
	var grid:Grid;

	var touch:Touch;

	public var width(default, set):Float = 0;
	public var height(default, set):Float = 0;
	public var zoom:Float = 1;

	public var selected:Null<h2d.Object> = null;
	public var prefab:Null<Prefab> = null;

	public var autoSelect:Bool = true;

	var selection:Graphics;
	var bound:Bounds;

	var cursor:Cursor;

	var transform = { x : 0.0, y : 0.0, scaleX : 1.0, scaleY : 1.0, width : 1.0, height : 1.0, rotation : 0.0, mouseX : 0.0, mouseY : 0.0, absX : 0.0, absY : 0.0 };
	var history = { x : 0.0, y : 0.0, scaleX : 1.0, scaleY : 1.0, width : 1.0, height : 1.0, rotation : 0.0 };

	var step:Float = 0;
	var time:Float = 0;

	
	public function new(?parent:h2d.Object) {
		super(parent);

		editor = Editor.ME;
		scene = editor.scene;
		grid = editor.grid;
		s2d = editor.s2d;

		touch = new Touch(width, height, this);
		touch.onPush = onDown;
		touch.onMove = onMove;
		touch.onRelease = onUp;
		touch.onKeyDown = onKeyDown;
		touch.onKeyUp = onKeyUp;
		touch.onWheel = onWheel;
		touch.onOver = onOver;
		touch.onOut = onOut;

		selection = new Graphics(this);
		selection.visible = false;

		cursor = new Cursor(this);
		cursor.visible = false;
	}


	public function select(object:h2d.Object) {
		selected = object;
		prefab = editor.children.get(object.name);

		getSelection();
		updateCursor();
	}


	public function unselect() {
		selected = null;
		prefab = null;
		updateCursor();
	}


	public function onTool(tool:Toolbar.State) {
		cursor.tool = tool;
	}


	public function onChange() {
		getSelection();
		updateCursor();
	}


	function onDown(event:Event) {
		if (event.button == 0) {
			var picked:Object = getObject(s2d.mouseX, s2d.mouseY);

			if (selected != null && cursor.state != XY) {
				picked = selected;
			}

			if (autoSelect && picked != null) {
				editor.select(picked.name);
				select(picked);
			}

			if (autoSelect && picked == null) editor.unselect();

			if (selected != null) {
				var mouse = new Point(s2d.mouseX, s2d.mouseY);

				touch.position.x = snap(mouse.x - selected.x);
				touch.position.y = snap(mouse.y - selected.y);

				transform.mouseX = mouse.x;
				transform.mouseY = mouse.y;

				var mat = selected.getAbsPos();
				transform.x = mouse.x - mat.x;
				transform.y = mouse.y - mat.y;

				transform.rotation = selected.rotation;

				transform.scaleX = selected.scaleX;
				transform.scaleY = selected.scaleY;

				transform.width = prefab.scaleX;
				transform.height = prefab.scaleY;

				var pos = new Point(s2d.mouseX, s2d.mouseY);
				selected.parent.globalToLocal(pos);

				transform.absX = pos.x;
				transform.absY = pos.y;

				// Store data for history
				history.x = selected.x;
				history.y = selected.y;

				history.scaleX = selected.scaleX;
				history.scaleY = selected.scaleY;

				history.width = prefab.scaleX;
				history.height = prefab.scaleY;

				history.rotation = selected.rotation;
			}

			touch.left = true;
		}

		if (event.button == 1) {
			touch.position.x = snap(s2d.mouseX - scene.x);
			touch.position.y = snap(s2d.mouseY - scene.y);

			touch.right = true;
		}

		touch.focus();
	}


	function onMove(event:Event) {
		if (touch.left == false && selected != null) {
			cursor.get(s2d.mouseX, s2d.mouseY);
		}

		if (touch.left && selected != null) {
			var mouse = new Point(s2d.mouseX, s2d.mouseY);

			var tool = editor.toolbar.tool;

			switch (tool) {
				case Translate:
					var pos = new Point(mouse.x - transform.x, mouse.y - transform.y);

					selected.parent.globalToLocal(pos);

					if (cursor.state != Y) selected.x = snap(pos.x);
					if (cursor.state != X) selected.y = snap(pos.y);

					editor.onTransform();
					updateCursor();
				case Rotation:
					var center = selected.localToGlobal();
					var startAngle = Math.atan2(transform.mouseY - center.y, transform.mouseX - center.x);
					var rotation = hxd.Math.angle(Math.atan2(s2d.mouseY - center.y, s2d.mouseX - center.x) - startAngle);

					selected.rotation = transform.rotation + rotation;

					editor.onTransform();
					getSelection();
					updateCursor();
				case Scale:
					var dx = mouse.x - transform.mouseX;
					var dy = mouse.y - transform.mouseY;

					var transformX = transform.scaleX + dx * 0.01;
					var transformY = transform.scaleY - dy * 0.01;

					if (cursor.state == XY) {
						var scaleSign = transform.x > 0 ? 1 : -1;

						transformX = transform.scaleX + dx * scaleSign * 0.01;
						transformY = transformX * (transform.scaleY / transform.scaleX);
					}

					if (cursor.state != Y) selected.scaleX = snap(transformX, 0.01);
					if (cursor.state != X) selected.scaleY = snap(transformY, 0.01);

					editor.onTransform();
					getSelection();
					updateCursor();
				case Size:
					var pos = new Point(s2d.mouseX, s2d.mouseY);
					selected.parent.globalToLocal(pos);

					var dx = (pos.x - transform.absX) * 1 / selected.scaleX;
					var dy = (pos.y - transform.absY) * 1 / selected.scaleY;

					var transformX = transform.width + dx * 1.0;
					var transformY = transform.height - dy * 1.0;

					if (cursor.state == XY) {
						var scaleSign = -1;

						transformX = transform.width + dx * 1.0;
						transformY = transform.height - dy * scaleSign * 1.0;

						if (Key.isDown(Key.SHIFT)) transformY = transformX * (transform.height / transform.width);
					}

					transformX = Math.max(transformX, 0);
					transformY = Math.max(transformY, 0);

					if (cursor.state != Y) prefab.scaleX = snap(transformX, 1);
					if (cursor.state != X) prefab.scaleY = snap(transformY, 1);

					editor.onTransform();
					getSelection();
					updateCursor();
				default:
			}
		}

		if (touch.right) {
			scene.x = snap(s2d.mouseX - touch.position.x);
			scene.y = snap(s2d.mouseY - touch.position.y);

			grid.onMove(scene.x, scene.y);

			updateCursor();
		}
	}

	
	function onUp(event:Event) {
		if (touch.left && selected != null) {
			// Check if transform changed
			var transformChanged = false;

			if (selected.x != history.x || selected.y != history.y) transformChanged = true;
			if (selected.scaleX != history.scaleX || selected.scaleX != history.scaleX) transformChanged = true;
			if (selected.rotation != history.rotation) transformChanged = true;

			
			// Send all to history
			if (transformChanged) {
				var undo = { x : history.x, y : history.y, scaleX : history.scaleX, scaleY : history.scaleY, rotation : history.rotation };
				var redo = { x : selected.x, y : selected.y, scaleX : selected.scaleX, scaleY : selected.scaleY, rotation : selected.rotation };

				editor.history.add(new History.Transform(selected, undo, redo));
			}

			// Send Prefab transform to history
			if (prefab.width != history.width || prefab.height != history.height) {
				var undo = { width : history.width, height : history.height };
				var redo = { width : prefab.width, height : prefab.height };

				editor.history.add(new History.Resize(prefab, undo, redo));
			}
		}

		touch.left = false;
		touch.right = false;
	}


	public function onTranslate(key:Int) {
		if (selected == null) return;
		if (![Key.UP, Key.DOWN, Key.LEFT, Key.RIGHT].contains(key)) return;

		history.x = selected.x;
		history.y = selected.y;

		switch (key) {
			case Key.UP : selected.y--;
			case Key.DOWN : selected.y++;
			case Key.LEFT : selected.x--;
			case Key.RIGHT : selected.x++;
			default:
		}

		editor.onTransform();
		updateCursor();
	}


	public function onTransform(key:Int) {
		if (selected == null) return;
		if (![Key.UP, Key.DOWN, Key.LEFT, Key.RIGHT].contains(key)) return;

		var undo = { x : history.x, y : history.y, scaleX : selected.scaleX, scaleY : selected.scaleY, rotation : selected.rotation };
		var redo = { x : selected.x, y : selected.y, scaleX : selected.scaleX, scaleY : selected.scaleY, rotation : selected.rotation };

		editor.history.add(new History.Transform(selected, undo, redo));
	}


	public dynamic function onKeyboard(key:Int) {}


	function onKeyDown(event:hxd.Event) {
		onTranslate(event.keyCode);
		onKeyboard(event.keyCode);
	}


	function onKeyUp(event:hxd.Event) {
		onTransform(event.keyCode);
	}


	function onWheel(event:Event) {
		zoom -= event.wheelDelta * 0.05; // TODO: correct power depend on `touch.hasFocus`

		if (zoom < 0.05) zoom = 0.05;
		if (zoom > 5) zoom = 5;

		zoom = snap(zoom, 0.01);

		var ratio = 1 - zoom / scene.scaleX;

		scene.x += (s2d.mouseX - scene.x) * ratio;
		scene.y += (s2d.mouseY - scene.y) * ratio;
		
		scene.scaleX = scene.scaleY = zoom;

		grid.onResize(zoom);
		grid.onMove(scene.x, scene.y);

		getSelection();
		updateCursor();
	}


	function onOver(event:hxd.Event) {
		//if (!touch.hasFocus()) touch.focus();
	}


	function onOut(event:hxd.Event) {
		touch.blur();
	}


	function getObject(x : Float, y : Float):h2d.Object {
		var shape:Object = null;

		for (object in editor.hierarchy) {
			var prefab = editor.children.get(object.name);
			var i = prefab.object;

			// if (prefab.type == "object") continue; [?]
			if (i.visible == false) continue;

			if (i.posChanged) i.syncPos();

			var dx = x - i.absX;
			var dy = y - i.absY;

			var invDet = 1 / (i.matA * i.matD - i.matB * i.matC);

			var rx = (dx * i.matD - dy * i.matC) * invDet;
			var ry = (dy * i.matA - dx * i.matB) * invDet;

			var min = new Point(prefab.x, prefab.y);
			var max = new Point(prefab.width + prefab.x, prefab.height + prefab.y);

			if (ry < min.y || rx < min.x || rx >= max.x || ry >= max.y) continue;

			shape = i;
		}

		return shape;
	}


	function getSelection() {
		if (selected == null) selection.visible = false;

		if (selected != null) {
			bound = selected.getBounds();

			var w = bound.width;
			var h = bound.height;
	
			selection.clear();
			selection.lineStyle(1, Style.selected);
			selection.drawRect(-w*0.5, -h*0.5, w, h);
	
			selection.setPosition(bound.getCenter().x, bound.getCenter().y);
			selection.visible = true;

			var absRotation = selected.rotation;

			var p = selected.parent;
			while (p != null) {
				absRotation += p.rotation;
				p = p.parent;
			}

			cursor.transform = absRotation;
		}
	}


	function updateCursor() {
		if (selected == null) cursor.visible = false;
		if (selected == null) selection.visible = false;

		if (selected != null) {
			var point = selected.localToGlobal();

			cursor.x = point.x;
			cursor.y = point.y;

			cursor.visible = true;

			bound = selected.getBounds();
			selection.setPosition(bound.getCenter().x, bound.getCenter().y);
		}
	}


	inline function snap(value:Float, step:Float = 1) {
		return Math.round(value / step) * step;
	}


	function set_width(v) {
		width = v;
		touch.width = width;
		return v;
	}


	function set_height(v) {
		height = v;
		touch.height = height;
		return v;
	}


	override function sync( ctx : h2d.RenderContext ) {
		super.sync(ctx);

		if (time < 0) return;

		zoom += step;
		if (time == 0) zoom = 1;

		var ratio = 1 - zoom / scene.scaleX;

		scene.x += (width * 0.5 - scene.x) * ratio;
		scene.y += (height * 0.5 - scene.y) * ratio;

		scene.scaleX = scene.scaleY = zoom;

		grid.onResize(zoom);
		grid.onMove(scene.x, scene.y);

		getSelection();
		updateCursor();

		time--;
	}


	public function onView() {
		if (zoom == 1) return;

		step = (1 - zoom) / 6;
		time = 6;
	}


	public function onScene() {
		zoom = 1;

		scene.scaleX = scene.scaleY = zoom;
		scene.x = scene.y = 200;

		grid.onResize(zoom);
		grid.onMove(scene.x, scene.y);

		getSelection();
		updateCursor();
	}


	public function fitView() {
		zoom = 1;
		scene.scaleX = scene.scaleY = zoom;

		if (scene.numChildren > 0) {
			scene.syncPos();
			var view = scene.getBounds(scene);

			scene.x = width * 0.5;
			scene.y = height * 0.5;

			scene.x -= view.getCenter().x;
			scene.y -= view.getCenter().y;
		}

		grid.onResize(zoom);
		grid.onMove(scene.x, scene.y);

		getSelection();
		updateCursor();
	}


	public function onResize() {
		scene.scaleX = scene.scaleY = zoom;

		grid.onResize(zoom);
		grid.onMove(scene.x, scene.y);

		getSelection();
		updateCursor();
	}
}


enum CursorState {
	XY;
	X;
	Y;
}


class Cursor extends h2d.Object {
	public var state(default, set):CursorState = XY;
	public var tool(default, set):Toolbar.State = Translate;
	public var transform(default, set):Float = 0;

	var cursor:Bitmap;
	var guideX:Bitmap;
	var guideY:Bitmap;

	var highlight:Int = 0xffff00;


	public function new(?parent:h2d.Object) {
		super(parent);

		cursor = new Bitmap(hxd.Res.gizmo.toTile(), this);
		cursor.tile.setCenterRatio();
		cursor.smooth = false;

		guideX = new Bitmap(hxd.Res.moveX.toTile(), this);
		guideX.smooth = true;
		guideX.x = 10;
		guideX.y = -8;

		setColor(guideX, 0xd1484e);

		guideY = new Bitmap(hxd.Res.moveY.toTile(), this);
		guideY.smooth = true;
		guideY.x = -8;
		guideY.y = -10-32;

		setColor(guideY, 0x89bd18);
	}


	public function get(mouseX:Float, mouseY:Float) {
		var mouse = globalToLocal(new Point(mouseX, mouseY));

		state = XY;

		if (mouse.x >= 10 && mouse.x < 42 && mouse.y >= -8 && mouse.y < 8) state = X;
		if (mouse.x >= -8 && mouse.x < 8 && mouse.y >= -42 && mouse.y < -10) state = Y;
	}


	function set_state(v) {
		if (state == v) return v;

		switch (v) {
			case X : 
				setColor(guideX, highlight);
				setColor(guideY, 0x89bd18);
			case Y : 
				setColor(guideX, 0xd1484e);
				setColor(guideY, highlight);
			case XY :
				setColor(guideX, 0xd1484e);
				setColor(guideY, 0x89bd18);
			default:
		}

		return state = v;
	}


	function set_tool(v) {
		if (tool == v) return v;

		switch (v) {
			case Scale : 
				guideX.tile = hxd.Res.scaleX.toTile();
				guideY.tile = hxd.Res.scaleY.toTile();
				rotation = transform;
			case Size : 
				guideX.tile = hxd.Res.scaleX.toTile();
				guideY.tile = hxd.Res.scaleY.toTile();
				rotation = transform;
			default:
				guideX.tile = hxd.Res.moveX.toTile();
				guideY.tile = hxd.Res.moveY.toTile();
				rotation = 0;
		}

		return tool = v;
	}


	function set_transform(v) {
		if (tool == Scale) rotation = v;
		if (tool == Size) rotation = v;
		return transform = v;
	}


	function setColor(bitmap:Bitmap, color:Int) {
		var a = bitmap.color.w;
		bitmap.color.setColor(color);
		bitmap.color.w = a;
	}
}