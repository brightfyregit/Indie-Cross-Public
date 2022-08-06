package;

import GameJolt.GJToastManager;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxState;
import flixel.graphics.FlxGraphic;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import haxe.CallStack;
import haxe.io.Path;
import lime.app.Application;
import openfl.Lib;
import openfl.display.FPS;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.UncaughtErrorEvent;
import openfl.system.System;
import openfl.utils.Assets;
import sys.FileSystem;
import sys.io.File;
import sys.io.Process;

#if debug
// import flixel.addons.studio.FlxStudio;
#end
class Main extends Sprite
{
	var gameWidth:Int = 1280; // Width of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var gameHeight:Int = 720; // Height of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var initialState:Class<FlxState> = SpecsDetector; // The FlxState the game starts with.
	var zoom:Float = -1; // If -1, zoom is automatically calculated to fit the window dimensions.
	var framerate:Int = 120; // How many frames per second the game should run at.
	var skipSplash:Bool = true; // Whether to skip the flixel splash screen that appears in release mode.
	var startFullscreen:Bool = false; // Whether to start the game in fullscreen on desktop targets

	#if cpp
	var memoryMonitor:MemoryMonitor = new MemoryMonitor(10, 3, 0xffffff);
	#end
	var fpsCounter:FPSMonitor = new FPSMonitor(10, 3, 0xFFFFFF);

	////Indie cross vars
	public static var dataJump:Int = 8; // The j
	public static var menuOption:Int = 0;

	public static var unloadDelay:Float = 0.5;

	public static var appTitle:String = 'Indie Cross';

	public static var menuMusic:String = 'freakyMenu';
	public static var menubpm:Float = 117;

	public static var curSave:String = 'save';

	public static var logAsked:Bool = false;
	public static var focusMusicTween:FlxTween;

	public static var hiddenSongs:Array<String> = ['gose', 'gose-classic', 'saness'];

	public static var gjToastManager:GJToastManager;

	public static var transitionDuration:Float = 0.5;

	// You can pretty much ignore everything from here on - your code should go in your states.

	public static function main():Void
	{
		// quick checks

		Lib.current.addChild(new Main());
	}

	public function new()
	{
		super();

		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onCrash);

		if (stage != null)
		{
			init();
		}
		else
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
	}

	private function init(?E:Event):Void
	{
		if (hasEventListener(Event.ADDED_TO_STAGE))
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
		}

		setupGame();
	}

	private function setupGame():Void
	{
		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;

		if (zoom == -1)
		{
			var ratioX:Float = stageWidth / gameWidth;
			var ratioY:Float = stageHeight / gameHeight;
			zoom = Math.min(ratioX, ratioY);
			gameWidth = Math.ceil(stageWidth / zoom);
			gameHeight = Math.ceil(stageHeight / zoom);
		}

		game = new FlxGame(gameWidth, gameHeight, initialState, zoom, framerate, framerate, skipSplash, startFullscreen);

		#if (debug && poly)
		FlxStudio.create();
		#end

		addChild(game);

		#if cpp
		addChild(memoryMonitor);
		#end

		addChild(fpsCounter);

		gjToastManager = new GJToastManager();
		addChild(gjToastManager);

		#if debug
		// debugging shit
		FlxG.console.registerObject("Paths", Paths);
		FlxG.console.registerObject("Conductor", Conductor);
		FlxG.console.registerObject("PlayState", PlayState);
		FlxG.console.registerObject("Note", Note);
		FlxG.console.registerObject("PlayStateChangeables", PlayStateChangeables);

		FlxG.console.registerObject("MainMenuState", MainMenuState);
		#end

		Application.current.window.onFocusOut.add(onWindowFocusOut);
		Application.current.window.onFocusIn.add(onWindowFocusIn);
	}

	var game:FlxGame;
	var oldVol:Float = 1.0;
	var newVol:Float = 0.3;

	public static var focused:Bool = true;

	// thx for ur code ari
	function onWindowFocusOut()
	{
		focused = false;

		// Lower global volume when unfocused
		if (Type.getClass(FlxG.state) != PlayState) // imagine stealing my code smh
		{
			oldVol = FlxG.sound.volume;
			if (oldVol > 0.3)
			{
				newVol = 0.3;
			}
			else
			{
				if (oldVol > 0.1)
				{
					newVol = 0.1;
				}
				else
				{
					newVol = 0;
				}
			}

			trace("Game unfocused");

			if (focusMusicTween != null)
				focusMusicTween.cancel();
			focusMusicTween = FlxTween.tween(FlxG.sound, {volume: newVol}, 0.5);

			// Conserve power by lowering draw framerate when unfocuced
			FlxG.drawFramerate = 60;
		}
	}

	function onWindowFocusIn()
	{
		new FlxTimer().start(0.2, function(tmr:FlxTimer)
		{
			focused = true;
		});

		// Lower global volume when unfocused
		if (Type.getClass(FlxG.state) != PlayState)
		{
			trace("Game focused");

			// Normal global volume when focused
			if (focusMusicTween != null)
				focusMusicTween.cancel();

			focusMusicTween = FlxTween.tween(FlxG.sound, {volume: oldVol}, 0.5);

			// Bring framerate back when focused
			FlxG.drawFramerate = 120;
		}
	}

	// you tried lol
	public static var persistentAssets:Array<FlxGraphic> = [];
	public static var idk:Array<String> = ['', 'assets/'];

	public static function dumpCache()
	{
		// /*
		if (Main.dumping)
		{
			trace('removed ur mom');
			// haya's stuff again lol
			@:privateAccess
			for (key in FlxG.bitmap._cache.keys())
			{
				var obj = FlxG.bitmap._cache.get(key);
				if (obj != null && !persistentAssets.contains(obj))
				{
					Assets.cache.removeBitmapData(key);
					FlxG.bitmap._cache.remove(key);
					obj.destroy();
					openfl.Assets.cache.removeBitmapData(key);
				}
			}

			// clear gpu vram
			GPUFunctions.disposeAllTextures();
			// clear songs
			for (i in 0...idk.length)
			{
				Assets.cache.clear(idk[i] + "songs");
				Assets.cache.clear(idk[i] + "sans/sounds");
				Assets.cache.clear(idk[i] + "cuphead/sounds");
				Assets.cache.clear(idk[i] + "bendy/sounds");
				Assets.cache.clear(idk[i] + "shared/sounds");
			}
			openfl.Assets.cache.clear("songs");
			openfl.Assets.cache.clear("assets/songs");
			// garbage disposal
			System.gc();
		}
		Main.dumping = false;
		// */
	}

	public static var dumping:Bool = false;

	public static function switchState(target:FlxState)
	{
		dumping = true;
		FlxG.switchState(target);
	}

	public function toggleFPS(fpsEnabled:Bool):Void
	{
		fpsCounter.visible = fpsEnabled;
	}

	public function toggleMemCounter(enabled:Bool):Void
	{
		#if cpp
		memoryMonitor.visible = enabled;
		#end
	}

	public function changeDisplayColor(color:FlxColor)
	{
		#if cpp
		fpsCounter.textColor = color;
		memoryMonitor.textColor = color;
		#end
	}

	public function setFPSCap(cap:Float)
	{
		Lib.current.stage.frameRate = cap;
	}

	public function getFPSCap():Float
	{
		return Lib.current.stage.frameRate;
	}

	public function getFPS():Float
	{
		return fpsCounter.currentFPS;
	}

	function onCrash(e:UncaughtErrorEvent):Void
	{
		var errMsg:String = "";
		var path:String;
		var callStack:Array<StackItem> = CallStack.exceptionStack(true);
		var dateNow:String = Date.now().toString();

		dateNow = StringTools.replace(dateNow, " ", "_");
		dateNow = StringTools.replace(dateNow, ":", "'");

		path = "./crash/" + "IndieCross_" + dateNow + ".txt";

		errMsg = "Version: " + Lib.application.meta["version"] + "\n";

		for (stackItem in callStack)
		{
			switch (stackItem)
			{
				case FilePos(s, file, line, column):
					errMsg += file + " (line " + line + ")\n";
				default:
					Sys.println(stackItem);
			}
		}

		errMsg += "\nUncaught Error: " + e.error + "\nReport the error here: https://discord.gg/cZydhxFYpp";

		if (!FileSystem.exists("./crash/"))
			FileSystem.createDirectory("./crash/");

		File.saveContent(path, errMsg + "\n");

		Sys.println(errMsg);
		Sys.println("Crash dump saved in " + Path.normalize(path));

		var crashDialoguePath:String = "FlixelCrashHandler";

		#if windows
		crashDialoguePath += ".exe";
		#end

		if (FileSystem.exists("./" + crashDialoguePath))
		{
			Sys.println("Found crash dialog: " + crashDialoguePath);

			#if linux
			crashDialoguePath = "./" + crashDialoguePath;
			#end
			new Process(crashDialoguePath, [path]);
		}
		else
		{
			Sys.println("No crash dialog found! Making a simple alert instead...");
			Application.current.window.alert(errMsg, "Error!");
		}

		Sys.exit(1);
	}
}
