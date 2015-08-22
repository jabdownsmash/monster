import Main;
import lime.Assets;


class ApplicationMain {
	
	
	public static var config:lime.app.Config;
	public static var preloader:lime.app.Preloader;
	
	private static var app:lime.app.Application;
	
	
	public static function create ():Void {
		
		#if !munit
		app = new Main ();
		app.create (config);
		#end
		
		preloader = new lime.app.Preloader ();
		preloader.onComplete = start;
		preloader.create (config);
		
		#if (js && html5)
		var urls = [];
		var types = [];
		
		
		urls.push ("assets/head.png");
		types.push (AssetType.IMAGE);
		
		
		urls.push ("assets/leftarm.png");
		types.push (AssetType.IMAGE);
		
		
		urls.push ("assets/soldier-stand.png");
		types.push (AssetType.IMAGE);
		
		
		urls.push ("assets/rightarm.png");
		types.push (AssetType.IMAGE);
		
		
		urls.push ("assets/soldier-runcycle.png");
		types.push (AssetType.IMAGE);
		
		
		urls.push ("assets/body.png");
		types.push (AssetType.IMAGE);
		
		
		
		if (config.assetsPrefix != null) {
			
			for (i in 0...urls.length) {
				
				if (types[i] != AssetType.FONT) {
					
					urls[i] = config.assetsPrefix + urls[i];
					
				}
				
			}
			
		}
		
		preloader.load (urls, types);
		#end
		
	}
	
	
	public static function main () {
		
		config = {
			
			antialiasing: Std.int (0),
			background: Std.int (16777215),
			borderless: false,
			company: "Company Name",
			depthBuffer: false,
			file: "Monster",
			fps: Std.int (60),
			fullscreen: false,
			hardware: true,
			height: Std.int (0),
			orientation: "",
			packageName: "com.sample.monster",
			resizable: true,
			stencilBuffer: false,
			title: "Monster",
			version: "1.0.0",
			vsync: false,
			width: Std.int (0),
			
		}
		
		#if (!html5 || munit)
		create ();
		#end
		
	}
	
	
	public static function start ():Void {
		
		#if !munit
		
		var result = app.exec ();
		
		#if (sys && !nodejs && !emscripten)
		Sys.exit (result);
		#end
		
		#else
		
		new Main ();
		
		#end
		
	}
	
	
	#if neko
	@:noCompletion public static function __init__ () {
		
		var loader = new neko.vm.Loader (untyped $loader);
		loader.addPath (haxe.io.Path.directory (Sys.executablePath ()));
		loader.addPath ("./");
		loader.addPath ("@executable_path/");
		
	}
	#end
	
	
}
