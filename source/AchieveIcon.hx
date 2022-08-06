import flixel.FlxG;
import flixel.FlxSprite;

class AchieveIcon extends FlxSprite
{
	public var sprTracker:FlxSprite;

	public function new(x:Float = 0, y:Float = 0, id:Int = 0)
	{
		super(x, y);

		trace('ID: ' + id);

		if (FlxG.save.data.achievementsIndie[Achievements.achievements[id].id])
		{
			var path:String = Paths.image(Achievements.achievements[id].img, 'achievements');
			trace("IMAGE PATH: " + path);
			loadGraphic(path);
		}
		else
		{
			var path:String = Paths.image('locked', 'achievements');
			trace("IMAGE PATH: " + path);
			loadGraphic(path);
		}

		scrollFactor.set();
		updateHitbox();
		antialiasing = FlxG.save.data.highquality;
	}

	override function update(elapsed:Float)
	{
		if (sprTracker != null)
		{
			setPosition(sprTracker.x - 170, sprTracker.y - 40);
		}

		super.update(elapsed);
	}
}
