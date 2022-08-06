package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.graphics.FlxGraphic;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import sys.thread.Thread;

using StringTools;

class LoadingState extends MusicBeatState
{
	public static var target:FlxState;
	public static var stopMusic = false;

	static var imagesToCache:Array<String> = [];
	static var soundsToCache:Array<String> = [];
	static var library:String = "";

	var screen:LoadingScreen;

	public function new()
	{
		super();

		enableTransIn = false;
		enableTransOut = false;
	}

	override function create()
	{
		super.create();

		// Hardcoded, aaaaahhhh
		switch (PlayState.storyWeek)
		{
			case 0:
				library = "cup";
		
				soundsToCache = ["parry", "knockout", "death"];

				imagesToCache = ['knock', 'ready_wallop', 'bull/Roundabout', 'bull/GreenShit', 'bull/Cupheadshoot', 'bull/Cuphead Hadoken','mozo'];
				
				FNFState.disableNextTransIn = true;
			
			case 1:
				library = "sans";
			
				soundsToCache = ["notice", "sansattack", "dodge", "readygas", "shootgas"];

				imagesToCache = ["DodgeMechs"];

				switch (PlayState.SONG.song.toLowerCase())
				{
					case 'bad-time':
						imagesToCache = imagesToCache.concat([	
							'Gaster_blasterss',
							'DodgeMechsBS-Shader'
						]);
				}
			
			case 2:
				library = "bendy";
			
				soundsToCache = ['inked'];

				imagesToCache = ['Damage01', 'Damage02', 'Damage03', 'Damage04'];
		}
		
		// Hardcoded for now
		if (PlayState.SONG.song.toLowerCase() == 'ritual')
			FNFState.disableNextTransIn = true;

		screen = new LoadingScreen();
		add(screen);

		screen.max = soundsToCache.length + imagesToCache.length;

		FlxG.camera.fade(FlxG.camera.bgColor, 0.5, true);

		FlxGraphic.defaultPersist = true;
		Thread.create(() ->
		{
			screen.setLoadingText("Loading sounds...");
			for (sound in soundsToCache)
			{
				trace("Caching sound " + sound);
				FlxG.sound.cache(Paths.sound(sound, library));
				screen.progress += 1;
			}

			screen.setLoadingText("Loading images...");
			for (image in imagesToCache)
			{
				trace("Caching image " + image);
				FlxG.bitmap.add(Paths.image(image, library));
				screen.progress += 1;
			}

			FlxGraphic.defaultPersist = false;

			screen.setLoadingText("Done!");
			trace("Done caching");
			
			FlxG.camera.fade(FlxColor.BLACK, 1, false);
			new FlxTimer().start(1, function(_:FlxTimer)
			{
				screen.kill();
				screen.destroy();
				loadAndSwitchState(target, false);
			});
		});
	}

	public static function loadAndSwitchState(target:FlxState, stopMusic = false)
	{
		Paths.setCurrentLevel("week" + PlayState.storyWeek);

		if (stopMusic && FlxG.sound.music != null)
			FlxG.sound.music.stop();
		Main.dumping = false;
		FlxG.switchState(target);
	}

	public static function dumpAdditionalAssets()
	{
		for (image in imagesToCache)
		{
			trace("Dumping image " + image);
			FlxG.bitmap.removeByKey(Paths.image(image, library));
		}
		soundsToCache = [];
		imagesToCache = [];
	}
}
