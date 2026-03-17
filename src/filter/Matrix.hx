package filter;

import prefab.Prefab;


class Matrix {
	public var data:h3d.Matrix.ColorAdjust = { saturation : 0.0, lightness : 0.0, hue : 0.0, contrast : 0.0 };
	var prefab:Prefab;


	public function new(prefab:Prefab, ?source:h3d.Matrix.ColorAdjust) {
		this.prefab = prefab;
		
		if (source != null) {
			data = { saturation : source.saturation * 100, lightness : source.lightness * 100, hue : source.hue * 180 / Math.PI, contrast : source.contrast * 100 };

			var drawable = (cast prefab.object : h2d.Drawable);
			drawable.adjustColor(source);
		}
	}

	public function apply() {
		var drawable = (cast prefab.object : h2d.Drawable);
		drawable.adjustColor({ saturation : data.saturation / 100, lightness : data.lightness / 100, hue : data.hue * Math.PI / 180, contrast : data.contrast / 100 });
	}

	public function remove() {
	}


	public function has():Bool {
		return false;
	}


	public function serialize():Dynamic {
		var matrix = { saturation : data.saturation / 100, lightness : data.lightness / 100, hue : data.hue * Math.PI / 180, contrast : data.contrast / 100 };
		return matrix;
	}
}