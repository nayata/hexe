package ui;


class Mask extends h2d.Object {
	public var width:Int = 0;
	public var height:Int = 0;

	public var clip:Bool = true;


	public function new(width, height, ?parent) {
		super(parent);
		this.width = width;
		this.height = height;
	}

	
	override function drawRec(ctx:h2d.RenderContext) {
		if (clip) h2d.Mask.maskWith(ctx, this, width, height, 0, 0);
		super.drawRec(ctx);
		if (clip) h2d.Mask.unmask(ctx);
	}
}