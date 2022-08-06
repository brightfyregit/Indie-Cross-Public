import flixel.util.FlxColor;
import GameJolt.GameJoltAPI;
import flixel.FlxG;

using StringTools;

/**
 * @author BrightFyre
 */

class Achieve
{
	public var name:String;
	public var desc:String;
	public var sec:Bool;
	public var id:Int;
	public var img:String;
	public var color:FlxColor;

	public function new(nm:String, dsc:String, sec:Bool, id:Int, img:String, ?color:FlxColor = 0xFFFF00)
	{
		name = nm;
		desc = dsc;
		this.sec = sec;
		this.id = id;
		this.img = img;
		this.color = color;
	}
}

class Achievements
{
	public static var achievements:Array<Achieve> =
		[
			//bronze achievements
			new Achieve("Captured", "Lose to Sans and Papyrus", true, 148410, "b1",FlxColor.fromRGB( 219, 148, 77)),
			//silver achievements
			new Achieve("Unworthy", "Hit 50 blue bone notes", false, 148408, "s1", FlxColor.fromRGB(192,192,192)),
			new Achieve("Unworthy II", "Hit 50 ink notes", false, 148409, "s2", FlxColor.fromRGB(192,192,192)),
			new Achieve("Unworthy III", "Die on Despair 50 times", false, 148405, "s3", FlxColor.fromRGB(192,192,192)),
			new Achieve("Pacifist", "Choose peace", false, 148406, "s4", FlxColor.fromRGB(192,192,192)),
			new Achieve("Genocide", "Kill Sans", false, 148422, "s5", FlxColor.fromRGB(192,192,192)),
			//gold achievements
			new Achieve("Gose?", "Play the secret Gose song", true, 148412, "g1", FlxColor.fromRGB(255,204,51)),
			new Achieve("Take One For The Team", "Die protecting mugman", true, 157761, "g2", FlxColor.fromRGB(255,204,51)),
			new Achieve("Saness", "Play the secret Saness song", true, 157762, "g3", FlxColor.fromRGB(255,204,51)),
			new Achieve("Courage", "Beat Last Reel on hard without dodging once", true, 158227, "g4", FlxColor.fromRGB(255,204,51)),
			new Achieve("What Is Blood?", "Play the secret Fuel Song", true, 0 /* there's no achievement yet, i don't wanna break anything tho*/, "g5", FlxColor.fromRGB(255,204,51)), // DO NOT USE THIS ONE YET! !!!!
			//platinum achievements
			new Achieve("The Legendary Chalice", "FC the entire Cuphead week on Hard", false, 148401, "p1", FlxColor.fromRGB(254,224,104)),
			new Achieve("Determination", "FC the entire Sans week on Hard", false, 148402, "p2", FlxColor.fromRGB(254,224,104)),
			new Achieve("Bring Home the Bacon", "FC the entire Ink Demon week on Hard", false, 148400, "p3", FlxColor.fromRGB(254,224,104)),
			new Achieve("Ultimate Knockout", "Defeat Nightmare Cuphead", false, 148398, "p4", FlxColor.fromRGB(255,0,102)),
			new Achieve("bad time", "Defeat Nightmare Sans", false, 148399, "p5", FlxColor.fromRGB(0,251,251)),
			new Achieve("Inking Mistake", "Defeat Nightmare Bendy", false, 148397, "p6", FlxColor.fromRGB(255,206,0)),
			new Achieve("The End", "Beat every week", false, 148396, "p7", FlxColor.fromRGB(214, 214, 214))
		];

	public static function unlockAchievement(name:String = "", ?hasSound:Bool = true):Void
	{
		var ID:Int = 0;

		for (i in 0...achievements.length)
		{
			if (achievements[i].name == name)
			{
				ID = i;
			}
		}

		if (!FlxG.save.data.achievementsIndie[achievements[ID].id])
		{
			FlxG.save.data.achievementsIndie[achievements[ID].id] = true;

			GameJoltAPI.getTrophy(achievements[ID].id);
			Main.gjToastManager.createToast("assets/achievements/images/" + Achievements.achievements[ID].img + ".png", Achievements.achievements[ID].name, Achievements.achievements[ID].desc, hasSound, Achievements.achievements[ID].color);
	
			FlxG.save.flush();
		}
	}

	public static function gotAll():Bool
	{
		var unfinished:Int = 0;
		for (i in 0...achievements.length)
		{
			if (!FlxG.save.data.achievementsIndie[achievements[i].id])
			{
				trace('hasnt done ' + achievements[i].name);
				unfinished++;
			}
		}

		if (unfinished == 0)
		{
			trace('user has 100%d :D');
			return true;
		}
		else 
		{
			trace('user has not 100%d :(((');
			return false;
		}
	}

	public static function syncGJ():Void
	{
		for (i in 0...achievements.length)
		{
			if (FlxG.save.data.achievementsIndie[i])
			{
				GameJoltAPI.getTrophy(achievements[i].id);
			}
		}
	}

	public static function defaultAchievements()
	{
		FlxG.save.data.achievementsIndie = [];
		for (i in 0...achievements.length)
		{
			FlxG.save.data.achievementsIndie[achievements[i].id] = false;
		}
		FlxG.save.flush();
	}
}
