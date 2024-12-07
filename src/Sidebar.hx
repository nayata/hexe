class Sidebar extends h2d.Object {
	var panel:h2d.Bitmap;

	public var width:Int = 300;
	public var height:Int = 900;

	
	public function new(?parent:h2d.Object) {
		super(parent);

		panel = new h2d.Bitmap(h2d.Tile.fromColor(Style.panel, width, height), this);
		panel.smooth = false;
	}


	public function onResize() {
		panel.width = width;
		panel.height = height;
	}
}