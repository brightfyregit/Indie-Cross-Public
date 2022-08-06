package;

import animateAtlasPlayer.textures.SubTexture;
import flixel.math.FlxMath;
import Options;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

class OptionsMenu extends MusicBeatState
{
	public static var instance:OptionsMenu;

	var selector:FlxText;
	var curSelected:Int = 0;

	var options:Array<OptionCategory> = [
		new OptionCategory("Gameplay", [
			new DFJKOption(), 
			new DownscrollOption("Change the layout of the strumline."),
			new GhostTapOption("Ghost Tapping is when you tap a direction and it doesn't give you a miss."),
			new BotPlay("Showcase your charts and mods with autoplay."),
			new ResetButtonOption("Toggle pressing R to gameover."), 
			new Hitsounds("Toggle hitsounds."), 
			new Judgement("Customize your Hit Timings (LEFT or RIGHT)"), 
			new AccuracyDOption("Change how accuracy is calculated. (Accurate = Simple, Complex = Milisecond Based)")
		]),
		new OptionCategory("Appearance", [
			new SongPositionOption("Show the songs current position (as a bar)"),
			new HudAlpha("Change the transparency of your HUD"),
			new LaneUnderlayOption("Toggle a lane underway (Left or right for transparency)"),
			new CamZoomOption("Toggle the camera zoom in-game."),
			new AccuracyOption("Display accuracy information."),
			new NPSDisplayOption("Shows your current Notes Per Second."),
			new ShowMS("Show the MS count for each note press")
		]),
		new OptionCategory("Performance", [
			new Photosensitive("Turn off visual effects that may harm your vision."),
			new HighQuality("Enable low quality mode for a smoother playing experience."),
			new CacheStart("Enables caching and loading of images before the game starts and songs.")
		]),
		new OptionCategory("Window", [
			new Resolution("Change the game's resolution, press ENTER to apply"),
			new Gamma("Change the gamma value of the app."),
			new Brightness("Change the brightness value of the app."),
			new FocusFreeze("Freeze the game when clicking off of the application."),
			new FocusPause("Open the pause menu when clicking off of the application in a song (Only works with Focus Freeze)."),
			new FPSCapOption("Cap your FPS"),
			new FPSOption("Toggle the FPS Counter"),
			new MemOption("Toggle the Memory Counter"),
			new RainbowFPSOption("Make the FPS and Memory Counter Rainbow")
		]),
		new OptionCategory("Accessibility", [
			new ShowSubtitles("Show subtitles during cutscenes."),
			new Colorblind(""),
			new LogInGJ("Log into gamejolt for achievements & perks"),
			new LogOutGJ("Log out of your gamejolt account")
		])
	];

	public var acceptInput:Bool = true;

	private var currentDescription:String = "";
	private var grpControls:FlxTypedGroup<Alphabet>;

	public static var versionShit:FlxText;

	var currentSelectedCat:OptionCategory;
	var blackBorder:FlxSprite;

	public static var fromFreeplay:Bool = false;
	public static var returnedfromOptions:Bool = false;

	var allowTransit:Bool = false;

	static var outOfCatSel:Int = 0;

	override function create()
	{
		super.create();

		persistentUpdate = true;

		FlxG.mouse.visible = true;

		instance = this;

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menu/BG', 'preload'));
		//bg.setGraphicSize(Std.int(bg.width * 0.675));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = FlxG.save.data.highquality;
		add(bg);

		grpControls = new FlxTypedGroup<Alphabet>();
		add(grpControls);

		for (i in 0...options.length)
		{
			var controlLabel:Alphabet = new Alphabet(0, (70 * i) + 30, options[i].getName(), true, false);
			controlLabel.isMenuItem = true;
			controlLabel.targetY = i;
			grpControls.add(controlLabel);
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !! ma dumbass didnt read this lmao
		}

		currentDescription = "none";

		versionShit = new FlxText(5, FlxG.height + 40, 0, "Offset (Left, Right, Shift for slow): " + HelperFunctions.truncateFloat(FlxG.save.data.offset, 2),
			12);
		versionShit.scrollFactor.set();
		versionShit.setFormat(HelperFunctions.returnMenuFont(versionShit), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);

		blackBorder = new FlxSprite(-30, FlxG.height + 40).makeGraphic((Std.int(versionShit.width + 973)), Std.int(versionShit.height + 600), FlxColor.BLACK);
		blackBorder.alpha = 0.5;

		add(blackBorder);

		add(versionShit);

		FlxTween.tween(versionShit, {y: FlxG.height - 18}, 2, {ease: FlxEase.elasticInOut});
		FlxTween.tween(blackBorder, {y: FlxG.height - 18}, 2, {ease: FlxEase.elasticInOut});

		changeSelection(0);

		new FlxTimer().start(Main.transitionDuration, function(tmr:FlxTimer)
		{
			allowTransit = true;
		});
	}

	var isCat:Bool = false;
	var backed:Bool = false;

	function accept()
	{
		if (isCat)
		{
			FlxG.save.flush();
			if (currentSelectedCat.getOptions()[curSelected].press())
			{
				grpControls.members[curSelected].changeText(currentSelectedCat.getOptions()[curSelected].getDisplay());
				trace(currentSelectedCat.getOptions()[curSelected].getDisplay());
			}

			changeSelection(curSelected);
		}
		else
		{
			FlxG.sound.play(Paths.sound('confirmMenu'));
			currentSelectedCat = options[curSelected];
			isCat = true;
			grpControls.clear();
			for (i in 0...currentSelectedCat.getOptions().length)
			{
				var controlLabel:Alphabet = new Alphabet(0, ((FlxMath.remapToRange(i, 0, 1, 0, 1.3) * 120) + (FlxG.height * 0.48)) , currentSelectedCat.getOptions()[i].getDisplay(), true, false);
				controlLabel.isMenuItem = true;
				controlLabel.targetY = i;
				grpControls.add(controlLabel);
			}

			outOfCatSel = curSelected;
			trace('outOfCatSel: ' + outOfCatSel);
			curSelected = 0;

			changeSelection(curSelected);
		}
	}

	function backOut()
	{
		FlxG.save.flush();
		if (!isCat && !backed)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			backed = true;
			returnedfromOptions = true;

			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.fadeOut(0.5, 0);
			}

			new FlxTimer().start(0.5, function(tmr:FlxTimer)
			{
				FlxG.sound.music.stop();
				if (fromFreeplay)
				{
					LoadingState.target = new PlayState();
					LoadingState.stopMusic = true;
					fromFreeplay = false;

					Main.switchState(new LoadingState());
				}
				else
					Main.switchState(new MainMenuState());
			});
		}
		else if (isCat && !backed)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			isCat = false;
			grpControls.clear();
			for (i in 0...options.length)
			{
				var controlLabel:Alphabet = new Alphabet(0, ((FlxMath.remapToRange(i, 0, 1, 0, 1.3) * 120) + (FlxG.height * 0.48)) , options[i].getName(), true, false);
				controlLabel.isMenuItem = true;
				controlLabel.targetY = i;
				grpControls.add(controlLabel);
			}

			trace('outOfCatSel: ' + outOfCatSel);
			//curSelected = outOfCatSel;
			curSelected = 0;

			changeSelection(curSelected);
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.sound.music != null)
		{
			if (!FlxG.sound.music.playing && !backed)
				FlxG.sound.playMusic(Paths.music('settin', 'preload'), 1);
		}

		if (acceptInput)
		{
			if (controls.ACCEPT || (FlxG.mouse.justPressed && Main.focused))
			{
				accept();
			}

			if ((controls.BACK || FlxG.keys.justPressed.BACKSPACE || (FlxG.mouse.justPressedRight && Main.focused)) && allowTransit)
			{
				backOut();
			}

			if (FlxG.keys.justPressed.UP || FlxG.keys.justPressed.W)
			{
				changeSelection(curSelected - 1);
			}
			if (FlxG.keys.justPressed.DOWN || FlxG.keys.justPressed.S)
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

			if (isCat)
			{
				if (currentSelectedCat.getOptions()[curSelected].getAccept())
				{
					catOption();
				}
				else
				{
					offsetChange();
				}
			}
			else
			{
				offsetChange();
			}
		}
	}

	function catOption()
	{
		if (FlxG.keys.pressed.SHIFT || !currentSelectedCat.getOptions()[curSelected].allowFastChange)
		{
			if (FlxG.keys.justPressed.RIGHT)
				currentSelectedCat.getOptions()[curSelected].right();
			FlxG.save.flush();
			if (FlxG.keys.justPressed.LEFT)
				currentSelectedCat.getOptions()[curSelected].left();
			FlxG.save.flush();
		}
		else
		{
			if (FlxG.keys.pressed.RIGHT || FlxG.keys.pressed.D)
				currentSelectedCat.getOptions()[curSelected].right();
			else if (FlxG.keys.pressed.LEFT || FlxG.keys.pressed.A)
				currentSelectedCat.getOptions()[curSelected].left();
		}

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (gamepad != null)
		{
			if (gamepad.justPressed.DPAD_RIGHT)
			{
				currentSelectedCat.getOptions()[curSelected].right();
			}
			if (gamepad.justPressed.DPAD_LEFT)
			{
				currentSelectedCat.getOptions()[curSelected].left();
			}
		}

		versionShit.text = currentSelectedCat.getOptions()[curSelected].getValue();
		if (currentDescription != '')
		{
			versionShit.text += " - Description - " + currentDescription;
		}
	}

	function offsetChange()
	{
		if (FlxG.keys.pressed.SHIFT)
		{
			if (FlxG.keys.justPressed.RIGHT || FlxG.keys.justPressed.D)
				FlxG.save.data.offset += 0.1;
			else if (FlxG.keys.justPressed.LEFT || FlxG.keys.justPressed.A)
				FlxG.save.data.offset -= 0.1;
		}
		else if (FlxG.keys.pressed.RIGHT || FlxG.keys.pressed.D)
			FlxG.save.data.offset += 0.1;
		else if (FlxG.keys.pressed.LEFT || FlxG.keys.pressed.A)
			FlxG.save.data.offset -= 0.1;

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (gamepad != null)
		{
			if (gamepad.justPressed.DPAD_RIGHT)
			{
				FlxG.save.data.offset += 0.1;
			}
			if (gamepad.justPressed.DPAD_LEFT)
			{
				FlxG.save.data.offset -= 0.1;
			}
		}

		versionShit.text = "Offset (Left, Right, Shift for slow): " + HelperFunctions.truncateFloat(FlxG.save.data.offset, 2) + " - Description - "
			+ currentDescription;
	}

	var isSettingControl:Bool = false;

	function changeSelection(change:Int = 0)
	{
		if (change != curSelected)
		{
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		}

		if (change < 0)
			change = grpControls.length - 1;
		if (change >= grpControls.length)
			change = 0;

		curSelected = change;

		if (isCat)
			currentDescription = currentSelectedCat.getOptions()[curSelected].getDescription();
		else
			currentDescription = "Please select a category";
		if (isCat)
		{
			if (currentSelectedCat.getOptions()[curSelected].getAccept())
				versionShit.text = currentSelectedCat.getOptions()[curSelected].getValue() + " - Description - " + currentDescription;
			else
				versionShit.text = "Offset (Left, Right, Shift for slow): " + HelperFunctions.truncateFloat(FlxG.save.data.offset, 2) + " - Description - "
					+ currentDescription;
		}
		else
			versionShit.text = "Offset (Left, Right, Shift for slow): " + HelperFunctions.truncateFloat(FlxG.save.data.offset, 2) + " - Description - "
				+ currentDescription;

		var bullShit:Int = 0;

		for (item in grpControls.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;

			if (item.targetY == 0)
			{
				item.alpha = 1;
			}
		}
	}
}
