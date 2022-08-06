package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;

using StringTools;

class SansGameover extends MusicBeatSubstate
{
	var txtList = [
		'hehe look at your face, oh yeah, you cant hehehe',
		'how about you play with two hands next time',
		'forget this, im goin to grillbys',
		'sure looks like youre having a bad time kiddo',
		'so cool',
		'how was THAT fall',
		'for a human, that performance was bone dry'
	];

	var charInd = 0;
	var charFlow = 0.0;
	var char = '';
	var txtStart = false;
	var txtInd = 0;
	var h:FlxSprite;

	var txt:FlxText;

	public function new()
	{
		super();

		FlxG.mouse.visible = true;

		Conductor.songPosition = 0;

		FlxG.sound.music.stop();

		FlxG.sound.play(Paths.sound('utDie', 'sans'));

		h = new FlxSprite(0, 120);
		h.frames = Paths.getSparrowAtlas('Soul_ded', 'sans');
		h.animation.addByIndices('split', 'UTdeath', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], '', 30, false);
		h.animation.addByPrefix('break', 'UTdeath', 30, false);
		h.scrollFactor.set();
		h.screenCenter(X);
		h.antialiasing = false;
		add(h);
		h.animation.play('split');

		var gameover:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('gameover', 'sans'));
		// gameover.cameras = [PlayState.camHUD];
		gameover.scrollFactor.set();
		gameover.setGraphicSize(Std.int(gameover.width * 1.5));
		gameover.updateHitbox();
		gameover.screenCenter();
		gameover.y -= 150;
		gameover.antialiasing = false;
		gameover.scrollFactor.set();
		gameover.alpha = 0;
		add(gameover);

		new FlxTimer().start(1.3, function(tmr:FlxTimer)
		{
			h.animation.play('break');
			h.animation.curAnim.curFrame = 15;
		});
		new FlxTimer().start(2.7, function(tmr:FlxTimer)
		{
			canAccept = true;
			FlxTween.tween(gameover, {alpha: 1}, 1);
			FlxG.sound.playMusic(Paths.music('GameOverSans', 'shared'), 1, true);
		});

		new FlxTimer().start(3.6, function(tmr:FlxTimer)
		{
			txtStart = true;
			txtInd = Std.int(Math.round(Math.random() * (txtList.length - 1)));
			txt = new FlxText(200, 400, 1280, 'cock');
			txt.setFormat(Paths.font('comic-sans-ut-font-rus-eng.ttf'), 35);
			txt.scrollFactor.set();
			txtVc = new FlxSound();
			txtVc.loadEmbedded(Paths.sound('snd_txtsans', 'sans'));
			// txt.cameras = [PlayState.extCam];
			add(txt);
		});
	}

	var txtVc:FlxSound;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (txtStart)
		{
			charFlow += elapsed * 20;
			var curStr = txtList[txtInd];
			if (charFlow > curStr.length)
				charFlow = curStr.length;

			while (charInd < Math.floor(charFlow))
			{
				charInd++;
				if (curStr.substr(charInd, 1) != ' ')
				{
					txtVc.stop();
					txtVc.play();
				}
			}
			txt.text = curStr.substr(0, charInd);
		}

		if (controls.ACCEPT || (FlxG.mouse.justPressed && Main.focused))
		{
			endBullshit();
		}

		if (controls.BACK || (FlxG.mouse.justPressedRight && Main.focused))
		{
			backOut();
		}
	}

	function backOut()
	{
		Application.current.window.title = Main.appTitle;

		if (FlxG.sound.music != null)
		{
			FlxG.sound.music.fadeOut(2, 0);
		}

		FlxG.camera.fade(FlxColor.BLACK, 2, false, function()
		{
			if (PlayState.isStoryMode)
			{
				StoryMenuState.leftDuringWeek = true;
				Main.switchState(new StoryMenuState());
			}
			else
			{
				Main.switchState(new FreeplayState());
			}
		});
	}

	var canAccept:Bool = false;

	var isEnding:Bool = false;

	function endBullshit():Void
	{
		if (canAccept)
		{
			if (!isEnding)
			{
				isEnding = true;
	
				if (FlxG.sound.music != null)
				{
					FlxG.sound.music.fadeOut(2, 0);
				}
	
				FlxG.camera.fade(FlxColor.BLACK, 2, false, function()
				{
					FlxG.resetState();
				});
			}
		}
	}
}
