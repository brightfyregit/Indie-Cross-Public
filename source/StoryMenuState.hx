package;

import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;

using StringTools;

#if windows
import Discord.DiscordClient;
#end

class DiffButton extends FlxSprite
{
	public var animOffsets:Map<String, Array<Dynamic>>;
	public var daZoom:Float = 1;
	public var curAnimName:String = 'idle';

	public function new(x:Int, y:Int)
	{
		super(x, y);
		animOffsets = new Map<String, Array<Dynamic>>();
		
		frames = Paths.getSparrowAtlas('story mode/Difficulties', 'preload');
		animation.addByPrefix(HelperFunctions.mechDifficultyFromInt(2), 'Mechs Dis instance 1', 24, true);
		animation.addByPrefix(HelperFunctions.mechDifficultyFromInt(1), 'Mechs Hard instance 1', 24, true);
		animation.addByPrefix(HelperFunctions.mechDifficultyFromInt(0), 'Mechs Hell instance 1', 24, true);

		addOffset(HelperFunctions.mechDifficultyFromInt(2), 0, 0);
		addOffset(HelperFunctions.mechDifficultyFromInt(1), 0, 0);
		addOffset(HelperFunctions.mechDifficultyFromInt(0), 10, 30);

		playAnim(HelperFunctions.mechDifficultyFromInt(StoryMenuState.curMechDifficulty), true);

        offset.set(0, 0);
		antialiasing = FlxG.save.data.highquality;
        scrollFactor.set();
	}

	public function setZoom(?toChange:Float = 1):Void
	{
		daZoom = toChange;
		scale.set(toChange, toChange);
	}

	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		animation.play(AnimName, Force, Reversed, Frame);
		curAnimName = AnimName;

		var daOffset = animOffsets.get(AnimName);
		if (animOffsets.exists(AnimName))
		{
			offset.set(daOffset[0] * daZoom, daOffset[1] * daZoom);
		}
		else
		{
			offset.set(0, 0);
		}
	}

	public function addOffset(name:String, x:Float = 0, y:Float = 0)
	{
		animOffsets[name] = [x, y];
	}
}

class StoryMenuState extends MusicBeatState
{
	public static var weekData:Array<Dynamic> = [
		['Snake-Eyes', 'Technicolor-Tussle', 'Knockout'],
		['Whoopee', 'Sansational', 'Burning-In-Hell', 'Final-Stretch'],
		['Imminent-Demise', 'Terrible-Sin', 'Last-Reel', 'Nightmare-Run']
	];

	var scoreText:FlxText;

	static var curDifficulty:Int = 1;
	public static var curMechDifficulty:Int = 1;

	public static var weekUnlocked:Array<Bool> = [true, true, true, false];

	static var curWeek:Int = 0;

	var daScaling:Float = 0.675;

	var actualBG:FlxSprite;

	var bendoBG:FlxSprite;

	var diffifSpr:FlxSprite;
	var diffOrigX:Float = 0;
	var diffTween:FlxTween;

	var diffmechSpr:DiffButton;
	var diffmechOrigX:Int = -2;
	var diffmechTween:FlxTween;

	var options:Array<FlxSprite>;
	var optFlashes:Array<FlxSprite>;
	var optionShit:Array<String> = ['Week1', 'Week2', 'Week3'];

	var actualLeft:Float = 0; // doing this only bc the screen zero isn't the real left side

	var gamingCup:FlxSprite;
	var gamingSands:FlxSprite;

	var cupTea:FlxSprite;

	public static var fromWeek:Int = -1;

	public static var leftDuringWeek:Bool = false;

	var allowTransit:Bool = false;

	var holdshifttext:FlxText;

	override function create()
	{
		super.create();

		persistentUpdate = true;

		FlxG.mouse.visible = true;

		#if windows
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Story Mode Menu", null);
		#end

		actualBG = new FlxSprite().loadGraphic(Paths.image('story mode/BG', 'preload'));
		actualBG.scrollFactor.set();
		actualBG.setGraphicSize(Std.int(actualBG.width * daScaling));
		actualBG.updateHitbox();
		actualBG.screenCenter();
		actualBG.antialiasing = FlxG.save.data.highquality;
		add(actualBG);

		gamingSands = new FlxSprite();
		gamingSands.frames = Paths.getSparrowAtlas('story mode/SansStorymodeMenu', 'preload');
		gamingSands.animation.addByPrefix('bruh', 'Saness instance 1', 24, true);
		gamingSands.animation.play('bruh');
		gamingSands.scrollFactor.set();
		gamingSands.setGraphicSize(Std.int(gamingSands.width * (daScaling * 1.5)));
		gamingSands.updateHitbox();
		gamingSands.x = -13;
		gamingSands.y = -41;
		gamingSands.antialiasing = FlxG.save.data.highquality;
		add(gamingSands);

		bendoBG = new FlxSprite();
		bendoBG.frames = Paths.getSparrowAtlas('story mode/Bendy_Gaming', 'preload');
		bendoBG.animation.addByPrefix('bruh', 'Creepy shit instance 1');
		bendoBG.animation.play('bruh');
		bendoBG.scrollFactor.set();
		bendoBG.setGraphicSize(Std.int(bendoBG.width * daScaling));
		bendoBG.updateHitbox();
		bendoBG.screenCenter();
		bendoBG.antialiasing = FlxG.save.data.highquality;
		bendoBG.alpha = 0;
		add(bendoBG);

		var leftpanel:FlxSprite = new FlxSprite().loadGraphic(Paths.image('story mode/Left-Panel_above BGs', 'preload'));
		leftpanel.scrollFactor.set();
		leftpanel.updateHitbox();
		leftpanel.screenCenter();
		leftpanel.antialiasing = FlxG.save.data.highquality;
		add(leftpanel);

		gamingCup = new FlxSprite();
		gamingCup.frames = Paths.getSparrowAtlas('story mode/Cuphead_Gaming', 'preload');
		gamingCup.animation.addByPrefix('bruh', 'Cuphead Gaming instance 1', 24, true);
		gamingCup.animation.play('bruh');
		gamingCup.scrollFactor.set();
		gamingCup.setGraphicSize(Std.int(gamingCup.width * daScaling));
		gamingCup.updateHitbox();
		gamingCup.x = 760;
		gamingCup.y = 233;
		gamingCup.antialiasing = FlxG.save.data.highquality;
		add(gamingCup);

		var bottompannel:FlxSprite = new FlxSprite().loadGraphic(Paths.image('story mode/Score_bottom panel', 'preload'));
		bottompannel.scrollFactor.set();
		bottompannel.setGraphicSize(Std.int(bottompannel.width * daScaling));
		bottompannel.updateHitbox();
		bottompannel.screenCenter();
		bottompannel.antialiasing = FlxG.save.data.highquality;
		add(bottompannel);

		diffifSpr = new FlxSprite();
		diffifSpr.frames = Paths.getSparrowAtlas('story mode/Difficulties', 'preload');
		diffifSpr.animation.addByPrefix('EASY', 'Chart Easy instance 1', 24, true);
		diffifSpr.animation.addByPrefix('NORMAL', 'Chart Normal instance 1', 24, true);
		diffifSpr.animation.addByPrefix('HARD', 'Chart Hard instance 1', 24, true);
		diffifSpr.animation.play('NORMAL');
		diffifSpr.scrollFactor.set();
		diffifSpr.setGraphicSize(Std.int(diffifSpr.width * 1.0));
		diffifSpr.updateHitbox();
		diffOrigX = -2;
		diffifSpr.y = 128;
		diffifSpr.antialiasing = FlxG.save.data.highquality;
		add(diffifSpr);

		diffTween = FlxTween.tween(this, {}, 0);

		diffmechSpr = new DiffButton(diffmechOrigX, 200);
		add(diffmechSpr);

		diffmechTween = FlxTween.tween(this, {}, 0);

		holdshifttext = new FlxText(8, 257, 0, "Hold 'SHIFT' to change", 24);
		holdshifttext.setFormat(HelperFunctions.returnMenuFont(scoreText), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		holdshifttext.borderSize = 1.5;
		holdshifttext.antialiasing = FlxG.save.data.highquality;
		holdshifttext.alpha = 0.8;
		add(holdshifttext);

		var storyPanel:FlxSprite = new FlxSprite().loadGraphic(Paths.image('story mode/Storymode', 'preload'));
		storyPanel.scrollFactor.set();
		storyPanel.setGraphicSize(Std.int(storyPanel.width * daScaling));
		storyPanel.updateHitbox();
		storyPanel.screenCenter();
		storyPanel.antialiasing = FlxG.save.data.highquality;
		add(storyPanel);

		options = [];
		optFlashes = [];

		for (i in 0...optionShit.length)
		{
			var menuItem:FlxSprite = new FlxSprite().loadGraphic(Paths.image('story mode/Weeks/' + optionShit[i], 'preload'));
			menuItem.setGraphicSize(Std.int(menuItem.width * daScaling));
			add(menuItem);
			options.push(menuItem);
			menuItem.alpha = 0.5;
			menuItem.scrollFactor.set();
			menuItem.antialiasing = FlxG.save.data.highquality;
			menuItem.updateHitbox();
			menuItem.screenCenter();
			actualLeft = menuItem.x;

			var flash = new FlxSprite().loadGraphic(Paths.image('story mode/Weeks/' + optionShit[i] + '_selected', 'preload'));
			flash.setGraphicSize(Std.int(flash.width * daScaling));
			add(flash);
			optFlashes.push(flash);
			flash.alpha = 0;
			flash.scrollFactor.set();
			flash.antialiasing = FlxG.save.data.highquality;
			flash.updateHitbox();
		}

		persistentUpdate = persistentDraw = true;

		scoreText = new FlxText(10, 10, 0, "SCORE: 49324858", 36);
		scoreText.setFormat(HelperFunctions.returnMenuFont(scoreText), 32, FlxColor.WHITE, CENTER);
		scoreText.screenCenter();
		scoreText.borderSize = 2.4;
		scoreText.y += 335;
		
		trace("Line 124");

		changeDifficulty();
		changeMechDifficulty();
		changeWeek(curWeek);

		add(scoreText);

		cupTea = new FlxSprite();
		cupTea.frames = Paths.getSparrowAtlas('the_thing2.0', 'cup');
		cupTea.animation.addByPrefix('start', "BOO instance 1", 24, false);
		cupTea.setGraphicSize(Std.int((FlxG.width / FlxG.camera.zoom) * 1.1), Std.int((FlxG.height / FlxG.camera.zoom) * 1.1));
		cupTea.updateHitbox();
		cupTea.screenCenter();
		cupTea.antialiasing = FlxG.save.data.highquality;
		cupTea.scrollFactor.set();
		if (fromWeek == 0)
		{
			cupTea.alpha = 1;
			cupTea.animation.play('start', true);
			cupTea.animation.finishCallback = function(name)
			{
				cupTea.alpha = 0.00001;
			}
		}
		else
		{
			cupTea.alpha = 0.00001;
		}
		add(cupTea);

		new FlxTimer().start(Main.transitionDuration, function(tmr:FlxTimer)
		{
			allowTransit = true;
		});
	}

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null && !lockInput)
		{
			if (!FlxG.sound.music.playing)
				FlxG.sound.playMusic(Paths.music(Main.menuMusic));
		}

		// scoreText.setFormat('VCR OSD Mono', 32);
		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, 0.4));
		
		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;


		scoreText.text = "WEEK SCORE: " + lerpScore;
		scoreText.x = FlxG.width / 2 - scoreText.width / 2;

		if (!lockInput)
		{
			var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

			if (gamepad != null)
			{
				if (gamepad.justPressed.DPAD_UP)
				{
					changeWeek(curWeek - 1);
				}

				if (gamepad.justPressed.DPAD_DOWN)
				{
					changeWeek(curWeek + 1);
				}

				if (gamepad.justPressed.DPAD_LEFT)
				{
					changeDifficulty(1);
				}

				if (gamepad.justPressed.DPAD_RIGHT)
				{
					changeDifficulty(-1);
				}
			}

			if (FlxG.keys.justPressed.UP || FlxG.keys.justPressed.W)
			{
				changeWeek(curWeek - 1);
			}

			if (FlxG.keys.justPressed.DOWN || FlxG.keys.justPressed.S)
			{
				changeWeek(curWeek + 1);
			}

			if (FlxG.mouse.wheel != 0)
			{
				if (FlxG.mouse.wheel > 0)
				{
					changeWeek(curWeek - 1);
				}
				else
				{
					changeWeek(curWeek + 1);
				}
			}

			if (FlxG.keys.pressed.SHIFT) //holding shift while changing diffiuclty, change mech diff
				{
					if (FlxG.keys.justPressed.RIGHT || FlxG.keys.justPressed.D)
						changeMechDifficulty(-1);
					if (FlxG.keys.justPressed.LEFT || FlxG.keys.justPressed.A)
						changeMechDifficulty(1);
				}
			else //not holding shift, change chart diffiuclty
				{
					if (FlxG.keys.justPressed.RIGHT || FlxG.keys.justPressed.D)
						changeDifficulty(1);
					if (FlxG.keys.justPressed.LEFT || FlxG.keys.justPressed.A)
						changeDifficulty(-1);
				}

			if (controls.ACCEPT || (FlxG.mouse.justPressed && Main.focused))
			{
				selectWeek();
			}

			if (controls.BACK || (FlxG.mouse.justPressedRight && Main.focused))
			{
				backOut();
			}
		}

		for (i in 0...options.length)
		{
			if (i != curWeek && options[i].alpha > 0.5)
				options[i].alpha -= 0.01;
			options[i].x += (actualLeft - options[i].x) / 6;

			if (optFlashes[i].alpha > 0)
				optFlashes[i].alpha -= 0.01;
			optFlashes[i].x = options[i].x;
			optFlashes[i].y = options[i].y;
		}

		super.update(elapsed);
	}

	function backOut()
	{
		if (!lockInput && allowTransit)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			lockInput = true;
	
			Main.switchState(new MainMenuState());
		}
	}

	var stopspamming:Bool = false;
	var lockInput:Bool = false;

	function selectWeek()
	{
		if (weekUnlocked[curWeek] && curWeek < 3)
		{
			if (stopspamming == false)
			{
				if (PlayState.storyWeek == curWeek && leftDuringWeek && PlayState.isStoryMode && PlayState.storyDifficulty == curDifficulty)
				{
					persistentUpdate = false;
					lockInput = true;
					openSubState(new Prompt("Would You Like to Resume Your Current Week?"));
					Prompt.acceptThing = function()
					{
						PlayState.playCutscene = true;
						PlayState.isStoryMode = true;
						leftDuringWeek = false;
						LoadingState.target = new PlayState();
						LoadingState.stopMusic = true;
						Main.switchState(new LoadingState());
					}
					Prompt.backThing = function()
					{
						leftDuringWeek = false;
						lockInput = false;
						persistentUpdate = true;
					}
				}
				else
				{
					aaaaa();
				}
			}
		}
		else
		{
			FlxG.camera.shake(0.01);
			FlxG.sound.play(Paths.sound('weekDeny', 'shared'));
		}
	}

	function aaaaa()
	{
		var waitDuration:Float = 1;

		switch (curWeek)
		{
			case 0:
				FNFState.disableNextTransOut = true;
				waitDuration = 1.1;
				cupTea.alpha = 1;
				cupTea.animation.play('start', true, true);
				FlxG.sound.play(Paths.sound('boing', 'cup'), 1);
				FlxG.sound.music.volume = 0;

				OptionsMenu.returnedfromOptions = false;
			default:
				if (FlxG.sound.music != null)
				{
					FlxG.sound.music.fadeOut(1, 0);
				}
				FlxG.sound.play(Paths.sound('confirmMenu'));

				options[curWeek].x -= 15;
				optFlashes[curWeek].alpha = 1;

				OptionsMenu.returnedfromOptions = false;

				for (i in 0...options.length)
				{
					var spr = options[i];
					if (curWeek != i)
					{
						FlxTween.tween(spr, {alpha: 0}, 1.3, {
							ease: FlxEase.quadOut,
							onComplete: function(twn:FlxTween)
							{
								spr.kill();
							}
						});
					}
				}
		}

		if (curWeek == 2 && curDifficulty != 2)
		{
			PlayState.storyPlaylist = ['Imminent-Demise', 'Terrible-Sin', 'Last-Reel'];
		}
		else
		{
			if (curWeek == 1)
			{
				PlayState.storyPlaylist = ['Whoopee', 'Sansational'];
			}
			else
			{
				PlayState.storyPlaylist = weekData[curWeek];
			}
		}
		
		PlayState.isStoryMode = true;
		lockInput = true;

		PlayState.storyDifficulty = curDifficulty;
		PlayState.difficulty = curDifficulty;

		var poop:String = Highscore.formatSong(PlayState.storyPlaylist[0], curDifficulty);

		PlayState.geno = false;

		HelperFunctions.checkExistingChart(PlayState.storyPlaylist[0], poop);

		PlayState.storyWeek = curWeek;
		PlayState.mechanicType = curMechDifficulty;
		PlayState.campaignScore = 0;

		LoadingState.target = new PlayState();
		LoadingState.stopMusic = true;

		PlayState.storyIndex = 1;

		new FlxTimer().start(waitDuration, function(tmr:FlxTimer)
		{
			PlayState.playCutscene = true;

			Main.switchState(new LoadingState());
		});

		stopspamming = true;
	}

	function changeDifficulty(change:Int = 0):Void
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = 2;
		if (curDifficulty > 2)
			curDifficulty = 0;

		switch (curDifficulty)
		{
			case 0:
				diffifSpr.animation.play('EASY');
			case 1:
				diffifSpr.animation.play('NORMAL');
			case 2:
				diffifSpr.animation.play('HARD');
		}

		diffifSpr.x = diffOrigX - 20;

		if (diffTween != null)
			diffTween.cancel();

		diffTween = FlxTween.tween(diffifSpr, {x: diffOrigX}, 0.2, {ease: FlxEase.quadOut});

		intendedScore = Highscore.getWeekScore(curWeek, curDifficulty);

		#if !switch
		intendedScore = Highscore.getWeekScore(curWeek, curDifficulty);
		#end
	}

	function changeMechDifficulty(change:Int = 0):Void
	{
		curMechDifficulty += change;

		if (curMechDifficulty < 0)
			curMechDifficulty = 2;
		if (curMechDifficulty > 2)
			curMechDifficulty = 0;

		switch (curMechDifficulty)
		{
			case 0:
				diffmechSpr.playAnim(HelperFunctions.mechDifficultyFromInt(0));
			case 1:
				diffmechSpr.playAnim(HelperFunctions.mechDifficultyFromInt(1));
			case 2:
				diffmechSpr.playAnim(HelperFunctions.mechDifficultyFromInt(2));
		}

		diffmechSpr.x = diffmechOrigX - 20;

		if (diffmechTween != null)
			diffmechTween.cancel();

		diffmechTween = FlxTween.tween(diffmechSpr, {x: diffmechOrigX}, 0.2, {ease: FlxEase.quadOut});
	}

	var lerpScore:Int = 0;
	var intendedScore:Int = 0;

	function changeWeek(change:Int = 0):Void
	{
		var lSel = curWeek;

		if (change >= weekData.length)
			change = 0;
		if (change < 0)
			change = weekData.length - 1;

		curWeek = change;

		switch (curWeek)
		{
			default:
				actualBG.alpha = 1;
				bendoBG.alpha = 0;
				actualBG.loadGraphic(Paths.image('story mode/BG', 'preload'));
				gamingCup.alpha = 1;
				gamingSands.alpha = 0;
			case 1:
				actualBG.alpha = 0;
				bendoBG.alpha = 0;
				gamingCup.alpha = 0;
				gamingSands.alpha = 1;
			case 2:
				actualBG.alpha = 0;
				bendoBG.alpha = 1;
				gamingCup.alpha = 0;
				gamingSands.alpha = 0;
			case 3:
				actualBG.alpha = 0;
				bendoBG.alpha = 0;
				gamingCup.alpha = 0;
				gamingSands.alpha = 0;
		}

		if (change != curWeek)
		{
			FlxG.sound.play(Paths.sound('scrollMenu'));
		}

		optionUpdate(lSel, '');
		optionUpdate(curWeek, '_selected');

		options[curWeek].x -= 40;
		options[curWeek].alpha = 1;

		intendedScore = Highscore.getWeekScore(curWeek, curDifficulty);

		#if !switch
		intendedScore = Highscore.getWeekScore(curWeek, curDifficulty);
		#end
	}

	function optionUpdate(num:Int, type:String)
	{
		options[num].loadGraphic(Paths.image('story mode/Weeks/' + optionShit[num] + type, 'preload'));
		options[num].updateHitbox();
		options[num].screenCenter(X);
	}
}
