package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

/**
 * @author BrightFyre
 */
using StringTools;
class InspectReward extends MusicBeatSubstate
{
	var icon:AchieveIcon;

	public function new()
	{
		super();
		FlxG.mouse.visible = true;

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		icon = new AchieveIcon(0, 0, AchievementsMenuState.curSelected);
		icon.updateHitbox();
		icon.screenCenter();
		icon.antialiasing = FlxG.save.data.highquality;
		icon.scrollFactor.set();
		icon.alpha = 0;
		add(icon);

		var descText:FlxText = new FlxText(20, icon.y + 300, 0,
			Achievements.achievements[AchievementsMenuState.curSelected].name + ' - ' + Achievements.achievements[AchievementsMenuState.curSelected].desc,
			64);

		if (Achievements.achievements[AchievementsMenuState.curSelected].name.contains("Unworthy"))
		{
			trace('is milestone achievement ' + Achievements.achievements[AchievementsMenuState.curSelected].name);
			switch (Achievements.achievements[AchievementsMenuState.curSelected].name)
			{
				case "Unworthy":
					descText.text += " (Bone Notes hit: " + FlxG.save.data.boneshit + ")";
				case "Unworthy II":
					descText.text += " (Ink Notes hit: " + FlxG.save.data.inkshit + ")";
				case "Unworthy III":
					descText.text += " (Despair deaths: " + FlxG.save.data.despairdeaths + ")";
			}
		}
		descText.scrollFactor.set();
		descText.setFormat(HelperFunctions.returnMenuFont(descText), 32);
		descText.setBorderStyle(OUTLINE, 0xFF000000, 5, 1);
		descText.updateHitbox();
		add(descText);
		descText.screenCenter(X);
		descText.alpha = 0;

		trace(icon.scale.x, icon.scale.y);

		FlxTween.tween(bg, {alpha: 0.85}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(icon, {alpha: 1}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(descText, {alpha: 1}, 0.4, {ease: FlxEase.quartInOut});
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (controls.BACK || (FlxG.mouse.justPressedRight && Main.focused))
		{
			backOut();
		}
	}

	function backOut()
	{
		FlxG.sound.play(Paths.sound('cancelMenu'));
		close();
	}
}
