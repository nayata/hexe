class Assets {
	public static var ui:Map<String, h2d.Tile> = new Map();

	public static var atlas:Map<String, Texture.Atlas> = new Map();
	public static var atlasPath:Map<String, String> = new Map();

	public static var fonts:Map<String, h2d.Font> = new Map();
	public static var fontPath:Map<String, String> = new Map();

	public static var defaultFont:h2d.Font;
	public static var mediumFont:h2d.Font;

	static var inited = false;

	
	public static function init() {
		if (inited) return;
		
		fonts.set("Default", hxd.res.DefaultFont.get());

		defaultFont = hxd.res.DefaultFont.get();
		mediumFont = hxd.Res.robotoMedium.toFont();

		inited = true;
	}


	// TODO: texture atlas
	public static function icon(name:String):h2d.Tile {
		if (!ui.exists(name)) {
			if (!hxd.res.Loader.currentInstance.exists(name + ".png")) return h2d.Tile.fromColor(0x9a9aa0, 16, 16);
			ui.set(name, hxd.Res.load(name + ".png").toImage().toTile());
		}

		return ui.get(name);
	}


	public static function font(name:String):h2d.Font {
		if (fonts.exists(name)) return fonts.get(name);
		return hxd.res.DefaultFont.get();
	}


	public static function clear() {
		fontPath.clear();
		fonts.clear();

		fonts.set("Default", hxd.res.DefaultFont.get());

		atlasPath.clear();
		atlas.clear();
	}
}