class Config {
	public static var detectProject:Bool = true;
	public static var resourceDir:String = "res";
	public static var gridSize:Int = 128;

	public static var collider:Array<String> = ["Static", "Dynamic", "Kinematic", "Sensor"];
	public static var palette:Array<String> = ["0496ff", "d81159", "b000d3", "80bc00"];

	
	public static function init() {
		if (!sys.FileSystem.exists("editor.config")) return;

		var data = haxe.Json.parse(sys.io.File.getContent("editor.config"));

		Config.detectProject = data.auto;
		Config.gridSize = data.grid;

		if (data.collider != null) Config.collider = StringTools.replace(data.collider, " ", "").split(",");
		if (data.palette != null) Config.palette = StringTools.replace(data.palette, " ", "").split(",");
	}
}