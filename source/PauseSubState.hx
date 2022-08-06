package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxMath;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;
import openfl.Lib;

class PauseSubState extends MusicBeatSubstate
{
	var grpMenuShit:FlxTypedGroup<Alphabet>;

	var menuItems:Array<String> = ['Resume', 'Options', 'Restart Song', 'Exit to menu'];
	var curSelected:Int = 0;

	var pauseMusic:FlxSound;

	var levelInfo:FlxText;

	var lerpOut:Bool = false;
	var poggers:Float = 0;

	var bg:FlxSprite;

	var levelDifficulty:FlxText;

	var mechDiffLabel:FlxText;

	public static var playingPause:Bool = false;

	var exitStateTimeDelay:Float = 0.5;
	var exitStateTime:FlxTimer;

	var confirmSound:FlxSound;
	var scrollSound:FlxSound;
	var cancelSound:FlxSound;

	var value:Float = 0;

	var controlsOverlay:ControlsOverlay;

	public function new()
	{
		super();
		FlxG.mouse.visible = true;
		FlxTween.globalManager.active = false;

		var fileName:String = '';
		var path:String = '';
		var bpm:Float = 102;

		confirmSound = new FlxSound().loadEmbedded(Paths.sound('confirmMenu'), false, false);
		scrollSound = new FlxSound().loadEmbedded(Paths.sound('scrollMenu'), false, false);
		cancelSound = new FlxSound().loadEmbedded(Paths.sound('cancelMenu'), false, false);

		switch (PlayState.curStage)
		{
			case 'field' | 'devilHall':
				fileName = 'pause';
				path = 'cup';
				bpm = 170;
				confirmSound = new FlxSound().loadEmbedded(Paths.sound('select', 'cup'), false, false);
				scrollSound = new FlxSound().loadEmbedded(Paths.sound('select', 'cup'), false, false);
				cancelSound = new FlxSound().loadEmbedded(Paths.sound('select', 'cup'), false, false);
			case 'hall' | 'papyrus':
				fileName = 'pause';
				path = 'sans';
				bpm = 120;
				confirmSound = new FlxSound().loadEmbedded(Paths.sound('select', 'sans'), false, false);
				scrollSound = new FlxSound().loadEmbedded(Paths.sound('move', 'sans'), false, false);
				cancelSound = new FlxSound().loadEmbedded(Paths.sound('move', 'sans'), false, false);
			case 'factory':
				fileName = 'pause';
				path = 'bendy';
				bpm = 102;
				confirmSound = new FlxSound().loadEmbedded(Paths.sound('click', 'bendy'), false, false);
				scrollSound = null;
				cancelSound = new FlxSound().loadEmbedded(Paths.sound('back', 'bendy'), false, false);
			default:
				fileName = 'breakfast';
				path = 'shared';
				bpm = 160;
		}

		for (i in FlxG.sound.list)
		{
			if (i.playing && i.ID != 9000)
				i.pause();
		}

		if (!playingPause)
		{
			playingPause = true;
			pauseMusic = new FlxSound().loadEmbedded(Paths.music(fileName, path), true, true);

			if (path == 'bendy')
			{
				pauseMusic.volume = 0.7;
			}
			else
			{
				pauseMusic.volume = 0;
			}

			pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));
			pauseMusic.ID = 9000;

			FlxG.sound.list.add(pauseMusic);
		}
		else
		{
			for (i in FlxG.sound.list)
			{
				if (i.ID == 9000) // jankiest static variable
					pauseMusic = i;
			}
		}

		Conductor.changeBPM(bpm);

		FlxG.sound.list.add(pauseMusic);

		Application.current.window.title = Main.appTitle
			+ ' - '
			+ HelperFunctions.getSongData(PlayState.SONG.song.toLowerCase(), 'artist')
			+ ' - '
			+ HelperFunctions.getSongData(PlayState.SONG.song.toLowerCase(), 'name')
			+ ' ['
			+ PlayState.instance.storyDifficultyText
			+ '] - PAUSED';

		bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.scrollFactor.set();
		bg.alpha = 0.6;
		add(bg);

		grpMenuShit = new FlxTypedGroup<Alphabet>();
		add(grpMenuShit);

		for (i in 0...menuItems.length)
		{
			var songText:Alphabet = new Alphabet(0, ((FlxMath.remapToRange(i, 0, 1, 0, 1.3) * 120) + (FlxG.height * 0.48)) , menuItems[i], true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpMenuShit.add(songText);
		}

		levelInfo = new FlxText(20, 20, 0, "", 32);
		levelInfo.text += StringTools.replace(PlayState.SONG.song, " ", "-");
		levelInfo.scrollFactor.set();
		levelInfo.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		levelInfo.font = HelperFunctions.returnHudFont(levelInfo);
		levelInfo.updateHitbox();
		add(levelInfo);

		levelDifficulty = new FlxText(20, 52, 0, "", 32);
		levelDifficulty.text += HelperFunctions.difficultyFromInt(PlayState.storyDifficulty).toUpperCase();
		levelDifficulty.scrollFactor.set();
		levelDifficulty.setFormat(Paths.font('vcr.ttf'), 32, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		levelDifficulty.font = HelperFunctions.returnHudFont(levelDifficulty);
		levelDifficulty.updateHitbox();
		add(levelDifficulty);
		
		mechDiffLabel = new FlxText(20, 84, 0, "", 32);
		mechDiffLabel.text += HelperFunctions.mechDifficultyFromInt(PlayState.mechanicType).toUpperCase();
		mechDiffLabel.scrollFactor.set();
		mechDiffLabel.setFormat(Paths.font('vcr.ttf'), 32, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		mechDiffLabel.font = HelperFunctions.returnHudFont(mechDiffLabel);
		mechDiffLabel.updateHitbox();
		add(mechDiffLabel);

		levelDifficulty.alpha = 0;
		levelInfo.alpha = 0;
		mechDiffLabel.alpha = 0;

		levelInfo.x = FlxG.width - (levelInfo.width + 20);
		levelDifficulty.x = FlxG.width - (levelDifficulty.width + 20);
		mechDiffLabel.x = FlxG.width - (mechDiffLabel.width + 20);

		controlsOverlay = new ControlsOverlay();
		controlsOverlay.scrollFactor.set();
		add(controlsOverlay);


		changeSelection();

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];

		cancelSound.play(true);

		exitStateTimeDelay = 0.5;
		new FlxTimer().start(0.1, function(exitStateTime:FlxTimer)
		{
			exitStateTimeDelay -= 0.11;
		}, 5);
	}

	override function update(elapsed:Float)
	{
		if (pauseMusic.volume < 0.5)
			pauseMusic.volume += 0.01 * elapsed;

		super.update(elapsed);

		if (!lerpOut)
		{
			value = FlxMath.lerp(value,1,poggers / 0.4);
			if (poggers < 0.4)
				poggers += FlxG.elapsed;
		}
		else
		{
			value = FlxMath.lerp(value,0,poggers / 0.4);
			if (poggers < 0.4)
				poggers += FlxG.elapsed;

			for (i in 0...grpMenuShit.members.length)
			{
				if (i != curSelected)
				{
					grpMenuShit.members[i].alpha = value;
				}
			}
		}

		bg.alpha = value * 0.6;
		levelInfo.alpha = value;
		levelDifficulty.alpha = value;
		mechDiffLabel.alpha = value;
		controlsOverlay.setAlpha(value);

		if (controls.ACCEPT || (FlxG.mouse.justPressed && Main.focused))
		{
			accept();
		}

		if (controls.BACK)
		{
			backOut();
		}

		if (FlxG.keys.justPressed.R)
		{
			if (exitStateTimeDelay <= 0.0)
			{
				PlayState.instance.health = 0;
				close();
			}
		}

		if (FlxG.keys.justPressed.UP || FlxG.keys.justPressed.W)
		{
			changeSelection(curSelected - 1);
		}
		else if (FlxG.keys.justPressed.DOWN || FlxG.keys.justPressed.S)
		{
			changeSelection(curSelected + 1);
		}

		if (FlxG.mouse.wheel != 0)
		{
			if (FlxG.mouse.wheel > 0)
			{
				changeSelection(curSelected - 1);
			}
			else
			{
				changeSelection(curSelected + 1);
			}
		}

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (gamepad != null)
		{
			if (gamepad.justPressed.DPAD_UP)
			{
				changeSelection(curSelected - 1);
			}
			if (gamepad.justPressed.DPAD_DOWN)
			{
				changeSelection(curSelected + 1);
			}
		}
	}

	function accept()
	{
		var daSelected:String = menuItems[curSelected];

		switch (daSelected)
		{
			case "Resume":
				if (exitStateTimeDelay <= 0.0)
				{
					closeState();
					resumin();
				}
			case 'Options':
				if (exitStateTimeDelay <= 0.0)
				{
					FlxTween.globalManager.active = true;

					PlayState.instance.defaultBrightVal = 0;
					setBrightness(0);

					OptionsMenu.fromFreeplay = true;
					FlxG.switchState(new OptionsMenu());
				}
			case "Restart Song":
				if (exitStateTimeDelay <= 0.0)
				{
					FlxTween.globalManager.active = true;

					PlayState.instance.defaultBrightVal = 0;
					setBrightness(0);

					PlayState.instance.playerDie();
					close();
				}
			case "Exit to menu":
				if (exitStateTimeDelay <= 0.0)
				{
					if (PlayState.isStoryMode)
					{
						StoryMenuState.leftDuringWeek = true;
					}

					PlayState.deathCount = 0;

					FlxTween.globalManager.active = true;

					PlayState.instance.defaultBrightVal = 0;
					setBrightness(0);

					if (PlayState.luaModchart != null)
					{
						PlayState.luaModchart.die();
						PlayState.luaModchart = null;
					}

					if (FlxG.save.data.fpsCap > 290)
						(cast(Lib.current.getChildAt(0), Main)).setFPSCap(290);

					Application.current.window.title = Main.appTitle;

					var fromWeek:Int = -1;

					var duration:Float = 0;
					if (PlayState.storyWeek == 0)
					{
						FNFState.disableNextTransIn = true;
						duration = 0.3;
						fromWeek = 0;
					}
					else
					{
						cancelSound.play(true);
					}

					new FlxTimer().start(duration, function(tmr:FlxTimer)
					{
						if (PlayState.isStoryMode)
						{
							StoryMenuState.fromWeek = fromWeek;
							Main.switchState(new StoryMenuState());
						}
						else
						{
							FreeplayState.fromWeek = fromWeek;
							Main.switchState(new FreeplayState());
						}
					});
				}
		}
	}

	function backOut()
	{
		if (exitStateTimeDelay <= 0.0)
		{
			changeSelection(0);
			closeState(0);
			resumin();
		}
	}

	override function destroy()
	{
		pauseMusic.destroy();
		playingPause = false;

		super.destroy();
	}

	function resumin()
	{
		if (!returning)
		{
			Application.current.window.title = Main.appTitle
				+ ' - '
				+ HelperFunctions.getSongData(PlayState.SONG.song.toLowerCase(), 'artist')
				+ ' - '
				+ HelperFunctions.getSongData(PlayState.SONG.song.toLowerCase(), 'name')
				+ ' ['
				+ PlayState.instance.storyDifficultyText
				+ ']';
			confirmSound.play(true);
			returning = true;
		}
	}

	var returning:Bool = false;

	function changeSelection(to:Int = 0):Void
	{
		if (!returning)
		{
			curSelected = to;

			if (curSelected < 0)
				curSelected = menuItems.length - 1;
			if (curSelected >= menuItems.length)
				curSelected = 0;

			if (to != 0)
			{
				if (scrollSound != null)
				{
					scrollSound.play(true);
				}
			}

			var bullShit:Int = 0;

			for (item in grpMenuShit.members)
			{
				item.targetY = bullShit - curSelected;
				bullShit++;

				item.alpha = 0.6;
				// item.setGraphicSize(Std.int(item.width * 0.8));

				if (item.targetY == 0)
				{
					item.alpha = 1;
					// item.setGraphicSize(Std.int(item.width));
				}
			}
		}
	}

	var startTimer:FlxTimer;

	var daTime:Float = 0.5;

	function closeState(?custom:Int = null)
	{
		closing = true;
		exitStateTimeDelay = 0.5;
		new FlxTimer().start(0.1, function(exitStateTime:FlxTimer)
		{
			exitStateTimeDelay -= 0.1;
			trace(exitStateTimeDelay);
		}, 5);

		Conductor.changeBPM(PlayState.SONG.bpm);

		lerpOut = true;
		poggers = 0;

		var da:Int = curSelected;
		if (custom != null)
		{
			da = custom;
		}

		for (i in 0...grpMenuShit.members.length)
		{
			if (i == da)
			{
				FlxFlicker.flicker(grpMenuShit.members[i], 1, 0.06, false, false);
			}
		}

		new FlxTimer().start(daTime, function(tmr:FlxTimer)
		{
			close();
		});
	}

	var closing:Bool = false;
}
