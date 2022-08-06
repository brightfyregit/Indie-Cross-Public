package;

import flixel.util.FlxTimer;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

/**
 * @author BrightFyre
 */
class Prompt extends MusicBeatSubstate
{
    public static var acceptThing:Void->Void;
	public static var backThing:Void->Void;

	var entertime:Float = 0.4;
	var lockInput = true;

	public function new(questionText:String = "Fuck you", ?textColor:FlxColor = FlxColor.WHITE)
	{
		super();
		FlxG.mouse.visible = true;

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		var icon:FlxSprite = new FlxSprite().loadGraphic(Paths.image('what', 'achievements'));
		icon.updateHitbox();
		icon.screenCenter();
		icon.antialiasing = FlxG.save.data.highquality;
		icon.scrollFactor.set();
		icon.alpha = 0;
		add(icon);

		var text:FlxText = new FlxText(0, icon.y - 100, 0, '', 32);
		text.scrollFactor.set();
		text.setFormat(HelperFunctions.returnMenuFont(text), 32);
		text.setBorderStyle(OUTLINE, 0xFF000000, 5, 1);
		text.text = questionText;
		text.updateHitbox();
		add(text);
		text.screenCenter(X);
		text.alpha = 0;

		var text2:FlxText = new FlxText(0, icon.y + 200, 0, '', 32);
		text2.scrollFactor.set();
		text2.setFormat(HelperFunctions.returnMenuFont(text2), 32);
		text2.setBorderStyle(OUTLINE, 0xFF000000, 5, 1);
		text2.text = 'Accept for yes, Back for no';
		text2.updateHitbox();
		add(text2);
		text2.screenCenter(X);
		text2.alpha = 0;

		FlxTween.tween(bg, {alpha: 0.6}, entertime, {ease: FlxEase.quartInOut});
		FlxTween.tween(text, {alpha: 1}, entertime, {ease: FlxEase.quartInOut});
		FlxTween.tween(text2, {alpha: 1}, entertime, {ease: FlxEase.quartInOut});
		FlxTween.tween(icon, {alpha: 1}, entertime, {ease: FlxEase.quartInOut});

		new FlxTimer().start(entertime, function(tmr:FlxTimer)
		{
			lockInput = false;
		});
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (!lockInput)
		{
			if (controls.BACK)
			{
				FlxG.sound.play(Paths.sound('cancelMenu', 'preload'));
				if (backThing != null)
				{
					backThing();
				}
				close();
			}
	
			if (controls.ACCEPT)
			{
				acceptThing();
			}
		}
	}
}
