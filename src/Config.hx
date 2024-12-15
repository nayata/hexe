class Config {
	public static var detectProject:Bool = true;
	public static var resourceDir:String = "res";
	public static var gridSize:Int = 128;

	
	public static function init() {
		if (!sys.FileSystem.exists("editor.config")) return;

		var data = haxe.Json.parse(sys.io.File.getContent("editor.config"));

		Config.detectProject = data.auto;
		Config.gridSize = data.grid;
	}
}