package;

import flixel.util.FlxTimer;
import Discord.DiscordClient;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.text.FlxText;
import flixel.util.FlxColor;

using StringTools;

/**
 * @author BrightFyre
 */
class AchievementsMenuState extends MusicBeatState
{
	var visibleAchievements:Array<String> = [];
	private var grpAchievements:FlxTypedGroup<Alphabet>;

	public static var curSelected:Int = 0;

	private var achievementArray:Array<AchieveIcon> = [];
	private var achievementIndex:Array<Int> = [];
	private var descText:FlxText;

	var daScaling:Float = 0.675;

	var allowTransit:Bool = false;

	override function create()
	{
		super.create();

		persistentUpdate = true;

		FlxG.mouse.visible = true;

		#if desktop
		DiscordClient.changePresence("Browsing the Achievements Menu", null);
		#end

		var menuBG:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menu/BG', 'preload'));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		menuBG.antialiasing = FlxG.save.data.highquality;
		add(menuBG);

		grpAchievements = new FlxTypedGroup<Alphabet>();
		add(grpAchievements);

		for (i in 0...Achievements.achievements.length)
		{
			visibleAchievements.push(Achievements.achievements[i].name);
			achievementIndex.push(i);
		}

		for (i in 0...visibleAchievements.length)
		{
			var text:Alphabet = new Alphabet(0, (100 * i) + 210,
				FlxG.save.data.achievementsIndie[Achievements.achievements[i].id] ? Achievements.achievements[achievementIndex[i]].name : '?', true, false);
			text.isMenuItem = true;
			text.x += 280;
			text.xAdd = 200;
			text.targetY = i;
			grpAchievements.add(text);

			var icon:AchieveIcon = new AchieveIcon(text.x - 170, text.y - 40, i);
			icon.sprTracker = text;
			achievementArray.push(icon);
			add(icon);
		}

		var bottompannel:FlxSprite = new FlxSprite().loadGraphic(Paths.image('story mode/Score_bottom panel', 'preload'));
		bottompannel.scrollFactor.set();
		bottompannel.setGraphicSize(Std.int(bottompannel.width * daScaling));
		bottompannel.flipY = true;
		bottompannel.updateHitbox();
		bottompannel.screenCenter();
		bottompannel.antialiasing = FlxG.save.data.highquality;
		add(bottompannel);

		descText = new FlxText(150, 5, 980, "", 32);
		descText.setFormat(HelperFunctions.returnMenuFont(descText), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		descText.scrollFactor.set();
		descText.borderSize = 2.4;
		add(descText);

		changeSelection();

		new FlxTimer().start(Main.transitionDuration, function(tmr:FlxTimer)
		{
			allowTransit = true;
		});
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.sound.music != null)
		{
			if (!FlxG.sound.music.playing)
				FlxG.sound.playMusic(Paths.music(Main.menuMusic));
		}

		if (FlxG.keys.justPressed.DELETE)
		{
			persistentUpdate = false;
			openSubState(new Prompt("Are you sure you want to clear your achievements?"));
			Prompt.acceptThing = function()
			{
				trace('cleared achievements');
				FlxG.sound.play(Paths.sound('delete', 'preload'));
				FlxG.save.data.givenCode = false;
				Achievements.defaultAchievements();
				Main.switchState(new MainMenuState());
			}
			Prompt.backThing = function()
			{
				persistentUpdate = true;
			}
		}

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (gamepad != null)
		{
			if (gamepad.justPressed.DPAD_UP)
			{
				changeSelection(-1);
			}
			if (gamepad.justPressed.DPAD_DOWN)
			{
				changeSelection(1);
			}
		}

		if (FlxG.keys.justPressed.UP || FlxG.keys.justPressed.W)
		{
			changeSelection(-1);
		}
		if (FlxG.keys.justPressed.DOWN || FlxG.keys.justPressed.S)
		{
			changeSelection(1);
		}

		if (FlxG.mouse.wheel != 0)
		{
			if (FlxG.mouse.wheel > 0)
			{
				changeSelection(-1);
			}
			else
			{
				changeSelection(1);
			}
		}

		if ((controls.BACK || (FlxG.mouse.justPressedRight && Main.focused)) && allowTransit)
		{
			backOut();
		}

		if (controls.ACCEPT || (FlxG.mouse.justPressed && Main.focused))
		{
			accepted();
		}
	}

	function accepted()
	{
		if (FlxG.save.data.achievementsIndie[Achievements.achievements[curSelected].id])
		{
			FlxG.sound.play(Paths.sound('confirmMenu'));
			openSubState(new InspectReward());
		}
		else
		{
			FlxG.camera.shake(0.01);
			FlxG.sound.play(Paths.sound('weekDeny', 'shared'));
		}
	}

	function backOut()
	{
		allowTransit = false;
		FlxG.sound.play(Paths.sound('cancelMenu'));
		Main.switchState(new MainMenuState());
	}

	function changeSelection(change:Int = 0)
	{
		curSelected += change;

		if (curSelected < 0)
			curSelected = visibleAchievements.length - 1;
		if (curSelected >= visibleAchievements.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpAchievements.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			if (item.targetY == 0)
			{
				item.alpha = 1;
			}
		}

		for (i in 0...achievementArray.length)
		{
			achievementArray[i].alpha = 0.6;
			if (i == curSelected)
			{
				achievementArray[i].alpha = 1;
			}
		}

		if (change != 0)
		{
			FlxG.sound.play(Paths.sound('scrollMenu'));
		}

		//chooses what title text to use
		if (Achievements.achievements[achievementIndex[curSelected]].sec && !FlxG.save.data.achievementsIndie[Achievements.achievements[curSelected].id])
		{
			descText.text = "?";
		}
		else if (!FlxG.save.data.achievementsIndie[Achievements.achievements[curSelected].id])
		{
			descText.text = Achievements.achievements[achievementIndex[curSelected]].name;
		}
		else
		{
			descText.text = Achievements.achievements[achievementIndex[curSelected]].desc;
		}
	}
}
