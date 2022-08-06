import GameJolt.GameJoltInfo;
#if desktop
import sys.io.Process;
import sys.FileSystem;
import sys.io.File;
#end
import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import lime.utils.Assets;
import openfl.display.BitmapData;
import sys.thread.Thread;

using StringTools;

class HelperFunctions
{
	public static var difficultyArray:Array<String> = ['Easy', "Normal", "Hard"];

	public static var v1Songs:Array<String> = [
		'snake-eyes', 'technicolor-tussle', 'knockout', 'satanic-funkin',
		'whoopee', 'sansational', 'final-stretch', 'burning-in-hell', 'bad-to-the-bone', 'bonedoggle',
		'imminent-demise', 'terrible-sin', 'last-reel', 'nightmare-run', 'ritual', 'freaky-machine',
		'devils-gambit', 'bad-time', 'despair',
		'gose', 'saness'
	];

	public static function difficultyFromInt(difficulty:Int):String
	{
		return difficultyArray[difficulty];
	}

	public static var mechDifficultyArray:Array<String> = ['Hell', "Standard", "Off"];

	public static function mechDifficultyFromInt(mechDifficulty:Int):String
	{
		return mechDifficultyArray[mechDifficulty];
	}

	public static function coolTextFile(path:String):Array<String>
	{
		var daList:Array<String> = Assets.getText(path).trim().split('\n');

		for (i in 0...daList.length)
		{
			daList[i] = daList[i].trim();
		}

		return daList;
	}

	public static function boundTo(value:Float, min:Float, max:Float):Float 
	{
		var newValue:Float = value;
		if (newValue < min) 
		{
			newValue = min;
		}
		else if (newValue > max) 
		{
			newValue = max;
		}
		return newValue;
	}
	
	public static function coolStringFile(path:String):Array<String>
	{
		var daList:Array<String> = path.trim().split('\n');

		for (i in 0...daList.length)
		{
			daList[i] = daList[i].trim();
		}

		return daList;
	}

	public static function numberArray(max:Int, ?min = 0):Array<Int>
	{
		var dumbArray:Array<Int> = [];
		for (i in min...max)
		{
			dumbArray.push(i);
		}
		return dumbArray;
	}
	
	public static function truncateFloat(number:Float, precision:Int):Float
	{
		var num = number;
		num = num * Math.pow(10, precision);
		num = Math.round(num) / Math.pow(10, precision);
		return num;
	}

	public static function GCD(a, b)
	{
		return b == 0 ? FlxMath.absInt(a) : GCD(b, a % b);
	}

	/**
	 * Checks whether the song should be hidden in a discord RPC
	 * 
	 * Usage: **HelperFunctions.shouldBeHidden(songName);**
	 * @param songName Song name
	 */
	public static function shouldBeHidden(?songName:String):Bool
	{
		return !v1Songs.contains(songName);
	}

	/**
	 * Gets data for a song
	 * 
	 * Usage: **HelperFunctions.getSongData(name, type);**
	 * @param song Song name
	 * @param type Type of parameter **Artist, BPM, or Name**
	 */
	public static function getSongData(song:String, type:String)
	{
		var artistPrefix:String = 'Kawai Sprite';
		var bpm:String = "150";
		var formattedName:String = 'Tutorial';
		var mechStuff:String = 'CONTROLS\n';
		var hasMech:String = "false";

		switch (song)
		{
			//cuphead
			case 'snake-eyes':
				artistPrefix = 'Mike Geno';
				bpm = "221";
				formattedName = 'Snake Eyes';
			case 'technicolor-tussle':
				artistPrefix = 'BLVKAROT';
				bpm = "140";
				formattedName = 'Technicolor Tussle';
				hasMech = "true";
			case 'knockout':
				artistPrefix = 'Orenji Music';
				bpm = "136";
				formattedName = 'Knockout';
				hasMech = "true";

			//sans
			case 'whoopee':
				artistPrefix = 'YingYang48 & Saster';
				bpm = "120";
				formattedName = 'Whoopee';
				hasMech = "true";
			case 'sansational':
				artistPrefix = 'Tenzubushi';
				bpm = "130";
				formattedName = 'sansational';
				hasMech = "true";
			case 'burning-in-hell':
				artistPrefix = 'TheInnuendo & Saster';
				bpm = "170";
				formattedName = 'Burning In Hell';
				hasMech = "true";
			case 'final-stretch':
				artistPrefix = 'Saru';
				bpm = "175";
				formattedName = 'Final Stretch';

			//bendy
			case 'imminent-demise':
				artistPrefix = 'Saru & CDMusic';
				bpm = "100";
				formattedName = 'Imminent Demise';
			case 'terrible-sin':
				artistPrefix = 'CDMusic & Rozebud';
				bpm = "220";
				formattedName = 'Terrible Sin';
				hasMech = "true";
			case 'last-reel':
				artistPrefix = 'Joan Atlas';
				bpm = "180";
				formattedName = 'Last Reel';
				hasMech = "true";
			case 'nightmare-run':
				artistPrefix = 'Orenji Music & Rozebud';
				bpm = "167";
				formattedName = 'Nightmare Run';
				hasMech = "true";

			//bonus
			case 'satanic-funkin':
				artistPrefix = 'TheInnuendo';
				bpm = "180";
				formattedName = 'Satanic Funkin';
				hasMech = "true";
			case 'bad-to-the-bone':
				artistPrefix = 'Yamahearted';
				bpm = "118";
				formattedName = 'Bad To The Bone';
				hasMech = "true";
			case 'bonedoggle':
				artistPrefix = 'Saster';
				bpm = "150";
				formattedName = 'Bonedoggle';
			case 'ritual':
				artistPrefix = 'BBPanzu & Brandxns';
				bpm = "160";
				formattedName = 'Ritual';
				hasMech = "true";
			case 'freaky-machine':
				artistPrefix = 'DAGames & Saster';
				bpm = "130";
				formattedName = 'Freaky Machine';
			
			//nightmare
			case 'devils-gambit':
				artistPrefix = 'Saru & TheInnuend0';
				bpm = "175";
				formattedName = 'Devils Gambit';
				hasMech = "true";
			case 'bad-time':
				artistPrefix = 'Tenzubushi';
				bpm = "330";
				formattedName = 'Bad Time';
				hasMech = "true";
			case 'despair':
				artistPrefix = 'CDMusic, Joan Atlas & Rozebud';
				bpm = "375";
				formattedName = 'Despair';
				hasMech = "true";

			//secret
			case 'gose' | 'gose-classic':
				artistPrefix = 'CrystalSlime';
				bpm = "100";
				formattedName = 'Gose';
			case 'saness':
				artistPrefix = 'CrystalSlime';
				bpm = "250";
				formattedName = 'Saness';
				hasMech = "true";
		}

		//dodge stuff
		switch (song.toLowerCase())
		{
			case 'knockout' | 'whoopee' | 'sansational' | 'burning-in-hell' | 'last-reel' | 'bad-time' | 'despair':
				var bindDodge = FlxG.save.data.dodgeBind;

				mechStuff += bindDodge.toUpperCase() + ' - Dodge\n';
		}
		//attack stuff
		switch (song.toLowerCase())
		{
			case 'knockout' | 'sansational' | 'burning-in-hell' | 'technicolor-tussle':
				var bindText = FlxG.save.data.attackLeftBind + 'or' + FlxG.save.data.attackRightBind;

				if (FlxG.save.data.attackLeftBind == 'SHIFT' && FlxG.save.data.attackRightBind == 'SHIFT')
				{
					bindText = "SHIFT";
				}

				mechStuff += bindText.toUpperCase() + ' - Attack\n';

			case 'last-reel' | 'despair':
				var bindLeft = FlxG.save.data.attackLeftBind;
				var bindRight = FlxG.save.data.attackRightBind;

				if (FlxG.save.data.attackLeftBind == 'SHIFT' && FlxG.save.data.attackRightBind == 'SHIFT')
				{
					bindLeft = "LEFT SHIFT";
					bindRight = "RIGHT SHIFT";
				}

				mechStuff += bindLeft.toUpperCase() + ' - Attack (Left)\n';
				mechStuff += bindRight.toUpperCase() + ' - Attack (Right)\n';
		}

		switch(type.toLowerCase())
		{
			case "artist":
				return artistPrefix;
			case "bpm":
				Conductor.changeBPM(Std.parseInt(bpm));
				return bpm;
			case "name":
				return formattedName;
			case "mech":
				return mechStuff;
			case "hasmech":
				trace('this song (' + song + ') has mechanics');
				return hasMech;
		}

		return "";
	}

	public static function getUsername():String
	{
		#if !js
		var envs = Sys.environment();
		if (envs.exists("USERNAME")) 
		{
			return envs["USERNAME"];
		}
		if (envs.exists("USER")) 
		{
			return envs["USER"];
		}
		#end
	
		return null;
	}

	public static function checkExistingChart(song:String, poop:String)
	{
		if (Main.hiddenSongs.contains(song.toLowerCase()))
		{
			PlayState.SONG = Song.loadFromJson(poop, song.toLowerCase());
		}
		else
		{
			if (FileSystem.exists('assets/data/' + song.toLowerCase() + '/' + poop.toLowerCase() + '.json'))
			{
				var json:Dynamic;
	
				try
				{
					json = Assets.getText(Paths.json(song.toLowerCase() + '/' + poop.toLowerCase())).trim();
				}
				catch (e)
				{
					trace("dang! stupid hashlink cant handle an empty file!");
					json = null;
				}
	
				if (json == null)
				{
					trace('aw fuck its null');
					createFakeSong(song);
				}
				else
				{
					trace('found file');
					PlayState.SONG = Song.loadFromJson(poop, song.toLowerCase());
				}
			}
			else
			{
				trace('aw fuck its null');
				createFakeSong(song);
			}
		}
	}

	
	public static function isRecording():Bool
	{
		var programList:Array<String> = 
		[
			'obs32',
			'obs64',
			'streamlabs obs',
			'bdcam',
			'fraps',
			'xsplit', // TIL c# program
			'hycam2', // hueh
			'twitchstudio' // why
		];

		var taskList:Process = new Process('tasklist', []);
		var readableList:String = taskList.stdout.readAll().toString().toLowerCase();
		var isOBS:Bool = false;

		for (i in 0...programList.length)
		{
			if (readableList.contains(programList[i]))
			{
				trace('found ' + programList[i]);
				isOBS = true;
			}
			else
			{
				trace('didnt find anything');
			}
		}

		taskList.close();
		readableList = '';

		return isOBS;
	}

	public static function instExists(song:String):Bool
	{
		if (FileSystem.exists('assets/songs/' + song.toLowerCase() + '/Inst.ogg'))
		{
			return true;
		}
		else
		{
			return false;
		}
	}

	public static function vocalExists(song:String):Bool
	{
		if (FileSystem.exists('assets/songs/' + song.toLowerCase() + '/Voices.ogg'))
		{
			return true;
		}
		else
		{
			return false;
		}
	}

	public static function instEasyExists(song:String):Bool
	{
		if (FileSystem.exists('assets/songs/' + song.toLowerCase() + '/Inst-easy.ogg'))
		{
			return true;
		}
		else
		{
			return false;
		}
	}

	public static function vocalEasyExists(song:String):Bool
	{
		if (FileSystem.exists('assets/songs/' + song.toLowerCase() + '/Voices-easy.ogg'))
		{
			return true;
		}
		else
		{
			return false;
		}
	}

	public static function createFakeSong(name:String):Void
	{
		PlayState.SONG = {
			song: name,
			notes: [],
			bpm: FreeplayState.bpm,
			needsVoices: true,
			player1: 'bf',
			player2: 'dad',
			player3: null,
			gfVersion: 'gf',
			noteStyle: 'normal',
			stage: 'stage',
			speed: 1,
			validScore: false
		};
	}

	public static function fancyOpenURL(schmancy:String)
	{
		#if linux
		Sys.command('/usr/bin/xdg-open', [schmancy, "&"]);
		#else
		FlxG.openURL(schmancy);
		#end
	}

	public static function returnMenuFont(?obj:FlxText = null):String
	{
		if (obj != null)
		{
			obj.y += 5;
		}
		return openfl.utils.Assets.getFont(GameJoltInfo.fontPath).fontName;
	}

	public static function returnHudFont(?obj:FlxText = null):String
	{
		var font:String = '';

		switch (PlayState.curStage)
		{
			case 'factory' | 'freaky-machine':
				font = Paths.font("DK Black Bamboo.ttf");
			case 'field' | 'devilHall':
				if (obj != null)
				{
					obj.y -= 1;
				}
				font = Paths.font("memphis.otf"); // i hate arial so i fixed this
			case 'hall':
				if (obj != null)
				{
					obj.y -= 5;
					// obj.screenCenter(X);
					obj.updateHitbox();
					obj.borderStyle = NONE;
					obj.size -= 2;
					obj.antialiasing = false;
				}
				font = Paths.font("undertale-hud-font.ttf");
				obj.text = obj.text.toUpperCase();
			case 'papyrus':
				font = Paths.font("Papyrus Font [UNDETALE].ttf");
			case 'the-void':
				if (obj != null)
				{
					obj.y -= 5;
				}
				font = Paths.font("Comic Sans MS.ttf");
				obj.text = obj.text.toLowerCase();
			default:
				if (obj != null)
				{
					obj.y += 5;
				}
				font = openfl.utils.Assets.getFont(GameJoltInfo.fontPath).fontName;
		}

		return font;
	}

	/**
	 * Gets image that didn't exist during compiling
	 * 
	 * Usage: **HelperFunctions.getSparrowAtlas(path);**
	 * @param path The path to the image
	 */
	public static function getSparrowAtlas(path:String):FlxAtlasFrames
	{
		return FlxAtlasFrames.fromSparrow(FlxGraphic.fromBitmapData(BitmapData.fromFile(path + ".png")), File.getContent(path + ".xml"));
	}
}
