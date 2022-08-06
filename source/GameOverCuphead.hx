package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;
import lime.media.openal.AL;
import openfl.system.System;

/**
 * @author BrightFyre
 */
class GameOverCuphead extends MusicBeatSubstate
{
	var bgImage:FlxSprite;
	var bfRunning:FlxSprite;

	var optionShit:Array<String> = ['retry', 'menu'];

	var menuItems:FlxTypedGroup<FlxSprite>;
	var menuArray:Array<FlxSprite> = [];

	var curSelected:Int = 0;

	var percentDone:Float = 0;

	var runPos:Array<Dynamic> = [[0, 145], [370, 75]];

	// imagine making a mod moddable
	var dialogue:Array<String> = [
		"I've fought monsters 10 times your size!",
		"I'm surprised that you had the balls to fight me!",
		"It was too easy to defeat you!",
		"Time your dodges better, geese"
	];

	var quip:String = '';

	var goalPos:Array<Float> = [];

	var text:FlxText;

	var deadMusic:FlxSound;

	public function new(time:Float = 0, totalTime:Float = 0)
	{
		super();

		trace('curtime is: ' + time + ' totaltime is: ' + totalTime);

		deadMusic = new FlxSound().loadEmbedded(Paths.inst(PlayState.SONG.song), true, true);
		deadMusic.fadeOut(2, 0.4);
		deadMusic.play(false, Conductor.songPosition);
		deadMusic.ID = 9000;
		FlxG.sound.list.add(deadMusic);

		FlxTween.tween(this, {songSpeed: 0.5}, 2);

		FlxG.mouse.visible = true;

		if (PlayState.SONG.song.toLowerCase() == 'knockout')
		{
			dialogue = ["You had your run, but now you're done!"];
		}
		else if (PlayState.curStage == 'devilHall')
		{
			dialogue = ["Anyone who opposes me will be destroyed!"];
		}

		// fuck off -- dialogue = CoolUtil.coolTextFile(Paths.txt('cupGameovers/normal'));

		var rando:Int = 0;

		// REMINDER: CHANGE THIS WHEN ADDING NEW DIALOGUE
		rando = FlxG.random.int(0, dialogue.length - 1); // dialogue.length can return a 3 so thats why its null sometimes
		quip = dialogue[rando];
		trace(quip);

		percentDone = (time / totalTime) * 1.07;

		// brightfyre made me use the pithagorean theorem to do an fnf mod let that sink in
		// sperez misspelled pythagorean theorem let that sink in
		// brightfyre misdpelled srperez wrong let that sink in
		// polybiusproxy misspelled misspelled let that sink in
		// brightfyre stealed my code without me and tweeted it bragging let that sink in
		// also brightfyre missed the word "wrong" let that sink in
		// brightfyre didnt replyed so i won the argument heeheh
		// let that sink in

		var goalAngle:Float = 10 * (Math.PI / 180);
		var mathStuff:Array<Float> = [runPos[1][0] - runPos[0][0], runPos[1][1] - runPos[0][1]];
		var goalDis:Float = Math.sqrt(Math.pow(mathStuff[0], 2) + Math.pow(mathStuff[1], 2));

		goalPos = [
			runPos[0][0] + (Math.cos(goalAngle) * goalDis * percentDone),
			runPos[0][1] - (Math.sin(goalAngle) * goalDis * percentDone)
		];

		FlxG.sound.play(Paths.sound('death', 'cup'));

		PlayState.boyfriend.alpha = 0;
		var bfGhost:FlxSprite = new FlxSprite(PlayState.boyfriend.x, PlayState.boyfriend.y);
		bfGhost.frames = Paths.getSparrowAtlas('BF_Ghost', 'cup');
		bfGhost.animation.addByPrefix('ded lol', 'thrtr instance 1', 24, true);
		bfGhost.animation.play('ded lol', true);
		add(bfGhost);
		FlxTween.tween(bfGhost, {y: PlayState.boyfriend.y - 1500}, 4.25);

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.setGraphicSize(Std.int(bg.width * 3));
		bg.updateHitbox();
		bg.screenCenter();
		bg.alpha = 0.6;
		bg.scrollFactor.set();
		add(bg);

		var death:FlxSprite = new FlxSprite().loadGraphic(Paths.image('death', 'cup'));
		death.updateHitbox();
		death.screenCenter();
		death.scrollFactor.set();
		death.antialiasing = FlxG.save.data.highquality;
		// death.cameras = [PlayState.instance.camHUD];
		add(death);

		bgImage = new FlxSprite().loadGraphic(Paths.image('cuphead_death', 'cup'));
		if (PlayState.SONG.song.toLowerCase() == 'knockout')
			bgImage.loadGraphic(Paths.image('cuphead_death2', 'cup'));
		else if (PlayState.curStage == 'devilHall')
			bgImage.loadGraphic(Paths.image('devil_death', 'cup'));
		bgImage.setGraphicSize(Std.int(bgImage.width * 1.2));
		bgImage.updateHitbox();
		bgImage.screenCenter();
		bgImage.antialiasing = FlxG.save.data.highquality;
		bgImage.scrollFactor.set();
		bgImage.angle = -55;
		bgImage.alpha = 0;
		// bgImage.cameras = [PlayState.instance.camHUD];
		add(bgImage);

		bfRunning = new FlxSprite();
		bfRunning.frames = Paths.getSparrowAtlas('NewCupheadrunAnim', 'cup');
		bfRunning.animation.addByPrefix('ohlawdherunnin', 'Run_cycle_gif', 24, true);
		bfRunning.animation.play('ohlawdherunnin', true);
		bfRunning.setGraphicSize(Std.int(bfRunning.width * 0.7));
		bfRunning.updateHitbox();
		bfRunning.x = runPos[0][0];
		bfRunning.y = runPos[0][1];
		bfRunning.antialiasing = FlxG.save.data.highquality;
		bfRunning.scrollFactor.set();
		bfRunning.angle = -10;
		bfRunning.alpha = 0;
		// bfRunning.cameras = [PlayState.instance.camHUD];
		add(bfRunning);

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		// calculated by holding 5 on the menu, I'm not a maniac
		var itmPos:Array<Dynamic> = [[618, 503], [560, 577]];

		for (i in 0...optionShit.length)
		{
			var menuItem:FlxSprite = new FlxSprite(0, 0);
			menuItem.frames = Paths.getSparrowAtlas('buttons', 'cup');
			menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
			menuItem.animation.play('idle', true);
			menuItem.scrollFactor.set();
			menuItem.antialiasing = FlxG.save.data.highquality;
			menuItem.screenCenter();
			menuItem.x = itmPos[i][0];
			menuItem.y = itmPos[i][1];
			menuItem.angle = -10;
			menuItem.alpha = 0;
			// menuItem.cameras = [PlayState.instance.camHUD];
			menuItems.add(menuItem);
			menuArray.push(menuItem);
		}

		text = new FlxText(0, 0, 500, '"' + quip + '"'); // cuphead style
		text.setFormat(Paths.font("memphis.otf"), 20, FlxColor.fromRGB(63, 68, 77), CENTER); // brightfyre is dumb when using custom fonts lmao
		text.angle = -10;
		text.updateHitbox();
		text.screenCenter();
		text.y -= 25;
		text.scrollFactor.set();
		text.alpha = 0;
		// text.cameras = [PlayState.instance.camHUD];
		add(text);

		changeItem(3);

		new FlxTimer().start(1, function(tmr:FlxTimer)
		{
			FlxTween.tween(death, {alpha: 0}, 0.7);

			new FlxTimer().start(0.7, function(tmr:FlxTimer)
			{
				canAccept = true;
				FlxTween.tween(bgImage, {angle: -10}, 0.7, {ease: FlxEase.cubeOut});
				FlxTween.tween(bgImage, {alpha: 1}, 0.7);

				new FlxTimer().start(0.5, function(tmr:FlxTimer)
				{
					for (i in 0...menuArray.length)
					{
						FlxTween.tween(menuArray[i], {alpha: 1}, 0.7, {ease: FlxEase.cubeOut});
					}

					FlxTween.tween(text, {alpha: 1}, 0.7);

					FlxTween.tween(bfRunning, {alpha: 1}, 0.2);
					// FlxTween.tween(text, {alpha: 1}, 0.2);

					FlxTween.tween(bfRunning, {x: goalPos[0], y: goalPos[1]}, 2, {ease: FlxEase.cubeOut});
				});
			});
		});
	}

	var songSpeed:Float = 1;

	var canAccept:Bool = false;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		@:privateAccess
		{
			AL.sourcef(deadMusic._channel.__source.__backend.handle, AL.PITCH, songSpeed);
		}

		if (!isEnding)
		{
			if (controls.ACCEPT)
			{
				endBullshit(curSelected);
			}

			if ((FlxG.mouse.justPressed && Main.focused))
			{
				if (FlxG.mouse.overlaps(menuItems.members[curSelected]))
				{
					endBullshit(curSelected);
				}
			}

			if (FlxG.keys.justPressed.UP)
			{
				changeItem(curSelected - 1);
			}

			if (FlxG.keys.justPressed.DOWN)
			{
				changeItem(curSelected + 1);
			}

			if (FlxG.mouse.justMoved)
			{
				for (i in 0...menuItems.members.length)
				{
					if (i != curSelected)
					{
						if (FlxG.mouse.overlaps(menuItems.members[i]))
						{
							changeItem(i);
						}
					}
				}
			}

			var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

			if (gamepad != null)
			{
				if (gamepad.justPressed.DPAD_UP)
				{
					changeItem(curSelected - 1);
				}
				if (gamepad.justPressed.DPAD_DOWN)
				{
					changeItem(curSelected + 1);
				}
			}
		}

		// this was the code used to get the options offsets, might be cool to leave it as an easter egg
		var spr = menuArray[curSelected];
		if (FlxG.keys.pressed.FIVE)
		{
			spr.x = FlxG.mouse.x;
			spr.y = FlxG.mouse.y;
		}
		if (FlxG.keys.justPressed.FOUR)
		{
			trace(spr.x + ',' + spr.y);
		}
	}

	var isEnding:Bool = false;

	function endBullshit(type:Int):Void
	{
		if (canAccept)
		{
			if (!isEnding)
			{
				isEnding = true;

				switch (type)
				{
					case 0:
						FNFState.disableNextTransIn = true;
						FNFState.disableNextTransOut = true;
						FlxG.sound.play(Paths.sound('select', 'cup'));
						deadMusic.fadeOut(0.3);
						FlxG.camera.fade(FlxColor.BLACK, 0.3, false, function()
						{
							LoadingState.loadAndSwitchState(new PlayState());
						});
					case 1:
						FlxG.sound.music.stop();

						Application.current.window.title = Main.appTitle;

						FlxG.sound.play(Paths.sound('select', 'cup'));

						deadMusic.fadeOut(0.3);

						FlxG.camera.fade(FlxColor.BLACK, 0.3, false, function()
						{
							if (PlayState.isStoryMode)
							{
								StoryMenuState.fromWeek = 0;
								StoryMenuState.leftDuringWeek = true;
								Main.switchState(new StoryMenuState());
							}
							else
							{
								FreeplayState.fromWeek = 0;
								Main.switchState(new FreeplayState());
							}
						});
				}
			}
		}
	}

	function changeItem(huh:Int = 0)
	{
		if (huh != 3)
		{
			FlxG.sound.play(Paths.sound('select', 'cup'));
		}

		curSelected = huh;

		if (curSelected > 1)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = 1;

		for (i in 0...menuArray.length)
		{
			var spr = menuArray[i];
			spr.animation.play('idle', true);

			if (i == curSelected)
			{
				spr.animation.play('selected', true);
			}

			spr.updateHitbox();
		}
	}
}
