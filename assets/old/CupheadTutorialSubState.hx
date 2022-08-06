package;

import flixel.FlxCamera;
import flixel.util.FlxTimer;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxSprite;

class CupheadTutorialSubState extends MusicBeatSubstate
{

	public var finishCallback:Void->Void;

	var alreadyPressed = false;
	var thing:FlxSprite;
	var bScreen:FlxSprite;
	var closeTmr:FlxTimer;

	public function new(tutorial:String,renderCamera:FlxCamera)
	{
		super();
		// parsing the camera cuz substates are dumb and render to main camera 
		bScreen = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
		bScreen.alpha = 0.001;
		bScreen.cameras = [renderCamera];
		bScreen.scrollFactor.set();
		bScreen.screenCenter();

		add(bScreen);

		FlxTween.tween(bScreen, {alpha: 0.4}, 1, {ease: FlxEase.expoOut});

		thing = new FlxSprite();
		thing.screenCenter();
		thing.cameras = [renderCamera];
		thing.y += 720;
		thing.x -= 550;
		thing.frames = Paths.getSparrowAtlas("attackdodge", "shared");
		thing.animation.addByPrefix("parry", "Parry notes instance 1", 24, false);
		thing.animation.addByPrefix("dodge", "Dodge instance 1", 24, false);
		thing.animation.play(tutorial);
		//thing.scale.set(0.75, 0.75);
		add(thing);
		FlxTween.tween(thing, {y: thing.y - 1040}, 1.2, {ease: FlxEase.expoOut, startDelay: 0.75});

		closeTmr = new FlxTimer().start(3);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.keys.justPressed.ANY && !alreadyPressed && closeTmr.finished)
		{
			alreadyPressed = true;
			FlxTween.tween(bScreen, {alpha: 0}, 1, {ease: FlxEase.expoOut});
			FlxTween.tween(thing, {y: thing.y + 900}, 1.2, {
				ease: FlxEase.expoOut,
				onComplete: function(twn:FlxTween)
				{
					close();
					finishCallback();
				}
			});
		}
	}
}