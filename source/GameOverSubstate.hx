package;

import haxe.ValueException;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;

using StringTools;

class GameOverSubstate extends MusicBeatSubstate
{
	var bf:Boyfriend;
	var camFollow:FlxObject;

	public static var gameOverChar:String = 'bf';

	var gameOverSpr:FlxSprite;

	var playMusic:Bool = false;
	var hasVOfinished:Bool = true;

	public static var sansSong:Bool = false;

	var papyrusDialogue:Array<String> = [
		"...:eyesclosed:none",
		"hey:normal:none",
		"thanks for letting my brother win:normal:none",
		"he doesn't handle humans so well:funne:none",
		"i wanna thank you with a gift:normal:none",
		"goodbye, player. have fun.:normal:none"
	];

	public function new(x:Float, y:Float)
	{
		super();

		FlxG.mouse.visible = true;

		var daBf:String = '';
		daBf = gameOverChar;

		switch (PlayState.SONG.song.toLowerCase())
		{
			case 'devious-deal' | 'bad-time' | 'despair':
				FlxG.save.data.huh = false;
		}

		PlayState.instance.defaultBrightVal = 0;
		setBrightness(0);

		switch (gameOverChar)
		{
			default:
				{
					Conductor.songPosition = 0;

					bf = new Boyfriend(x, y, daBf);
					add(bf);

					camFollow = new FlxObject(bf.getGraphicMidpoint().x, bf.getGraphicMidpoint().y, 1, 1);
					add(camFollow);

					FlxG.sound.play(Paths.sound('fnf_loss_sfx'));
					Conductor.changeBPM(100);
					bf.playAnim('firstDeath');

					new FlxTimer().start(2.375, function(tmr:FlxTimer)
					{
						playMusic = true;
					});
					new FlxTimer().start(3.4, function(tmr:FlxTimer)
					{
						if (PlayState.SONG.player2 == 'saness')
						{
							hasVOfinished = false;
							var maxRand:Int = 16;
							if (HelperFunctions.isRecording())
							{
								maxRand = 19;
							}
							var random = FlxG.random.int(1, maxRand);

							trace('random line: ' + random);

							FlxG.sound.music.fadeOut(0.5, 0.1, function(twn:FlxTween)
							{
								if (random > 16)
								{
									trace('playing stream deathlines');
									var newVal = random - 16;
									FlxG.sound.play(Paths.sound("deathlines/streamer/" + newVal, 'shared'), 1, false, null, true, function()
									{
										trace('finished sound');
										FlxG.sound.music.fadeOut(0.5, 1);
										hasVOfinished = true;
									});
								}
								else
								{
									trace('playing normal deathlines');
									FlxG.sound.play(Paths.sound('deathlines/normal/' + random, 'shared'), 1, false, null, true, function()
									{
										trace('finished sound');
										FlxG.sound.music.fadeOut(0.5, 1);
										hasVOfinished = true;
									});
								}
							});
						}
					});
				}
			case 'bendy':
				{
					Conductor.songPosition = 0;
					gameOverSpr = new FlxSprite();
					gameOverSpr.frames = Paths.getSparrowAtlas('Ded', 'bendy');
					gameOverSpr.animation.addByPrefix('enter', 'Res', 24, false);
					gameOverSpr.animation.addByPrefix('loop', 'Reset', 24, false);
					gameOverSpr.updateHitbox();
					gameOverSpr.screenCenter();
					gameOverSpr.scrollFactor.set();
					gameOverSpr.antialiasing = FlxG.save.data.highquality;
					add(gameOverSpr);
					gameOverSpr.alpha = 0;

					new FlxTimer().start(2, function(tmr:FlxTimer)
					{
						if (gameOverSpr != null)
						{
							if (gameOverSpr.alpha == 0) // to prevent it from activating if the player retry
							{
								gameOverSpr.alpha = 1;
								gameOverSpr.animation.play('loop', true);
								playMusic = true;
							}
						}
					});

					FlxG.sound.play(Paths.sound('jumpscare', 'bendy'));
				}
			case 'papyrus':
				if (PlayState.SONG.song.toLowerCase() == 'bonedoggle')
				{
					dialogueOver = false;
					var dialogue = new SansDialogueBox(papyrusDialogue);
					add(dialogue);

					dialogue.finishThing = function()
					{
						FlxG.save.data.givenCode = true;
						dialogueOver = true;
						FlxG.save.flush();
						endBullshit();
					};
				}
			case 'gose':
				vidSpr = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.WHITE);
				add(vidSpr);

				var video:VideoHandler = new VideoHandler();
				video.allowSkip = false;
				video.finishCallback = function()
				{
					throw new ValueException('Honk');
				};
				video.playMP4(Paths.video('gose'), false, vidSpr, false, true, false);
		}

		FlxG.camera.scroll.set();
		FlxG.camera.target = null;
		FlxG.sound.music.stop();
	}

	var dialogueOver:Bool = true;

	var vidSpr:FlxSprite;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (controls.ACCEPT || (FlxG.mouse.justPressed && Main.focused))
		{
			if (hasVOfinished)
				{
					if (dialogueOver)
						{
							endBullshit();
						}
				}
			else
				{
					endBullshit();
					if (!isEnding)
					{
						var random = FlxG.random.int(1, 3);
						FlxG.sound.play(Paths.sound('deathlines/skip/' + random));
					}
				}
		}

		if (controls.BACK || (FlxG.mouse.justPressedRight && Main.focused))
		{
			if (dialogueOver)
				{
					backOut();
				}
		}

		if (playMusic && !isEnding)
		{
			switch (gameOverChar)
			{
				case 'bf':
					if (sansSong)
					{
						FlxG.sound.playMusic(Paths.music('gameovernormal', 'sans'), 1, true);
					}
					else
					{
						FlxG.sound.playMusic(Paths.music('gameOver', 'shared'), 1, true);
					}

				case 'bendy':
					FlxG.sound.playMusic(Paths.sound('heartbeat', 'bendy'), 1, true);
			}
			playMusic = false;
		}

		switch (gameOverChar)
		{
			case 'bf':
				if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.curFrame == 12)
				{
					FlxG.camera.follow(camFollow, LOCKON, 0.01);
				}
		}

		if (FlxG.sound.music.playing)
		{
			Conductor.songPosition = FlxG.sound.music.time;
		}
	}

	function backOut()
	{
		FlxG.sound.music.stop();

		Application.current.window.title = Main.appTitle;

		var fromWeek:Int = -1;

		if (PlayState.isStoryMode)
		{
			StoryMenuState.fromWeek = fromWeek;
			StoryMenuState.leftDuringWeek = true;
			Main.switchState(new StoryMenuState());
		}
		else
		{
			FreeplayState.fromWeek = fromWeek;
			Main.switchState(new FreeplayState());
		}
	}

	override function beatHit()
	{
		super.beatHit();

		FlxG.log.add('beat');
	}

	var isEnding:Bool = false;

	function endBullshit():Void
	{
		if (!isEnding)
		{
			isEnding = true;
			switch (gameOverChar)
			{
				default:
					{
						bf.playAnim('deathConfirm', true);
						if (PlayState.dad.curCharacter.contains('sans') || PlayState.dad.curCharacter.contains('papyrus'))
						{
							FlxG.sound.play(Paths.music('GameOverSansEnd', 'shared'));
						}
						else
						{
							FlxG.sound.play(Paths.music('gameOverEnd', 'shared'));
						}

						FlxG.sound.music.stop();
					}
				case 'bendy':
					{
						gameOverSpr.alpha = 1;
						gameOverSpr.animation.play('enter', true);
						FlxG.sound.music.stop();
						FlxG.sound.play(Paths.sound('click', 'bendy'));
					}
				case 'papyrus':
			}

			new FlxTimer().start(0.7, function(tmr:FlxTimer)
			{
				FlxG.camera.fade(FlxColor.BLACK, 2, false, function()
				{
					if (PlayState.SONG.song.toLowerCase() == 'bonedoggle')
					{
						HelperFunctions.fancyOpenURL("https://drive.google.com/file/d/1Z3ezmWKEhwrqFS0kYiV0-FUQ_rCkCCPw/view?usp=sharing");
					}

					FlxG.resetState(); // changed because it unloads memory when it restarts song lol
				});
			});
		}
	}
}
