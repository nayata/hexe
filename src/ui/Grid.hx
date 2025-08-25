package ui;

class Grid extends h2d.Object {
	public var width:Float = 1600;
	public var height:Float = 900;

	var cell:Float = 128;
	var size:Float = 128;

	var grid:h2d.Graphics;

	var axisX:h2d.Bitmap;
	var axisY:h2d.Bitmap;


	public function new(width:Float, height:Float, cell:Float, ?parent:h2d.Object) {
		super(parent);

		this.width = width;
		this.height = height;

		this.cell = cell;
		size = cell;

		grid = new h2d.Graphics(this);
		
		axisX = new h2d.Bitmap(h2d.Tile.fromColor(Style.guideX, 1, 1), this);
		axisY = new h2d.Bitmap(h2d.Tile.fromColor(Style.guideY, 1, 1), this);

		axisX.smooth = false;
		axisY.smooth = false;

		axisX.width = width;
		axisX.height = 1;

		axisY.width = 1;
		axisY.height = height;

		onResize();
	}


	public function onMove(relX:Float = 0, relY:Float = 0) {
		grid.x = -size + wrap(relX, 0, size);
		grid.y = -size + wrap(relY, 0, size);

		axisX.setPosition(0, relY); 
		axisY.setPosition(relX, 0); 
	}


	public function onResize(zoom:Float = 1) {
		size = cell * zoom;

		if (zoom <= 0.2) size = (cell*10) * zoom;

		var gridX:Int = Math.round(width / size) + 2;
		var gridY:Int = Math.round(height / size) + 2;

		grid.clear();
		grid.lineStyle(1, Style.grid);

		for(x in 0...gridX){
			for(y in 0...gridY){        
				grid.moveTo(x * size, 0); 
				grid.lineTo(x * size, height + size);

				grid.moveTo(0, y * size); 
				grid.lineTo(width + size, y * size);
			}
		}

		axisX.width = width;
		axisY.height = height;
	}


	function wrap(value:Float, min:Float, max:Float) {
		var range = max - min;
		return (min + ((((value - min) % range) + range) % range));
	}
}