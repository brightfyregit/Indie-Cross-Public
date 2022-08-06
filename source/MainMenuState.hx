
package;

import offsetMenus.DiffButtonOffsets;
#if desktop
import sys.io.File;
import sys.FileSystem;
#end
import flixel.FlxObject;
import openfl.utils.Object;
import offsetMenus.NotesplashOffsets;
import Shaders.WhiteOverlayShader;
import flixel.input.gamepad.FlxGamepad;
import GameJolt.GameJoltAPI;
import GameJolt.GameJoltLogin;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;
import openfl.Lib;
import flixel.system.debug.Window;

using StringTools;

#if cpp
import Discord.DiscordClient;
#end

class LoginScreen extends FlxTypedSpriteGroup<FlxSprite>
{
	public var onClosed:Void->Void;
	public var controls:Controls;
	
	var buttons:Array<FlxSprite> = [];
	var curSelected:Int = 0;
	var disableInput:Bool = true;

	var logFade:FlxSprite;
	var prompt:FlxSprite;
	var curTween:FlxTween;
	
	public function new(c:Controls)
	{
		super(10, 10);

		controls = c;

		alpha = 0;

		logFade = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
		logFade.origin.set();
		logFade.scale.set(1280, 720);
		logFade.updateHitbox();
		logFade.alpha = 0.6;
		add(logFade);

		prompt = new FlxSprite(0, 100).loadGraphic(Paths.image('menu/log/prompt', 'preload'));
		prompt.updateHitbox();
		prompt.screenCenter(X);
		prompt.antialiasing = true;
		add(prompt);

		var yesBtt:FlxSprite = new FlxSprite(0, 350).loadGraphic(Paths.image('menu/log/btt_yes', 'preload'));
		yesBtt.updateHitbox();
		yesBtt.screenCenter(X);
		yesBtt.antialiasing = true;
		add(yesBtt);
		yesBtt.alpha = 1;
		buttons.push(yesBtt);

		var noBtt:FlxSprite = new FlxSprite(0, 475).loadGraphic(Paths.image('menu/log/btt_no', 'preload'));
		noBtt.updateHitbox();
		noBtt.screenCenter(X);
		noBtt.antialiasing = true;
		add(noBtt);
		buttons.push(noBtt);

		FlxTween.tween(this, {alpha: 1.0}, 0.5, {onComplete: function(_)
		{
			disableInput = false;
			changeSelection(0);
		}});

		FlxTween.num(0.0, 1.0, 0.5, null, function(num:Float)
		{
			logFade.alpha = num * 0.6;
			prompt.alpha = num;
			for (button in buttons)
				button.alpha = num * 0.5;
		});

		for (i in 0...buttons.length)
		{
			buttons[i].shader = new WhiteOverlayShader();
		}

		setPosition(0, 0);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (!disableInput)
		{
			if ((controls.BACK || (FlxG.mouse.justPressedRight && Main.focused)))
			{
				back();
			}

			if (FlxG.keys.justPressed.UP || FlxG.keys.justPressed.W)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeSelection(curSelected - 1);
			}

			if (FlxG.keys.justPressed.DOWN || FlxG.keys.justPressed.S)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeSelection(curSelected + 1);
			}

			if (FlxG.mouse.justMoved)
			{
				for (i in 0...buttons.length)
				{
					if (i != curSelected)
					{
						if (FlxG.mouse.overlaps(buttons[i]) && !FlxG.mouse.overlaps(buttons[curSelected]))
						{
							changeSelection(i);
						}
					}
				}
			}

			if (controls.ACCEPT)
			{
				enterSelection();
			}

			if ((FlxG.mouse.justPressed && Main.focused))
			{
				if (FlxG.mouse.overlaps(buttons[curSelected]))
				{
					enterSelection();
				}
			}
		}
	}

	function changeSelection(selection:Int)
	{
		if (doInput)
		{
			if (selection != curSelected)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
			}
	
			if (selection < 0)
				selection = buttons.length - 1;
			if (selection >= buttons.length)
				selection = 0;
	
			for (i in 0...buttons.length)
			{
				var button:FlxSprite = buttons[i];
				if (i == selection)
				{
					button.alpha = 1.0;
				}
				else
				{
					button.alpha = 0.5;
				}
			}
	
			curSelected = selection;
		}
	}

	var doInput:Bool = true;

	function enterSelection()
	{	
		doInput = false;
		buttons[curSelected].shader.data.progress.value = [1.0];
		FlxTween.num(1, 0, 0.5, {ease: FlxEase.cubeOut}, function(num:Float)
		{
			buttons[curSelected].shader.data.progress.value = [num];
		});

		switch (curSelected)
		{
			case 0:
				FlxG.sound.play(Paths.sound('confirmMenu'));
				for (i in 0...buttons.length)
				{
					if (i != curSelected)
					{
						FlxTween.tween(buttons[i], {alpha: 0}, 0.5, {ease: FlxEase.cubeOut});
					}
				}
			case 1:
				FlxG.sound.play(Paths.sound('cancelMenu'));
				back();
		}

		new FlxTimer().start(0.5, function(tmr:FlxTimer)
		{
			switch (curSelected)
			{
				case 0:
					disableInput = true;
					Main.switchState(new GameJoltLogin());
			}
		});
	}

	function back()
	{
		doInput = false;
		FlxTween.tween(logFade, {alpha: 0}, 0.5, {onComplete: function(_)
		{
			if (onClosed != null)
				onClosed();
		}});

		FlxTween.tween(prompt, {alpha: 0}, 0.5);
		
		for (button in buttons)
		{
			FlxTween.tween(button, {alpha: 0}, 0.5);
		}

		disableInput = true;
	}
}

class MainMenuState extends MusicBeatState
{
	public static final daScaling:Float = 0.675;
	
	public static var debugTools:Bool = false;
	public static var showcase:Bool = false;
	public static var logged:Bool = false;

	static final menuStrings:Array<String> = ["storymode", "freeplay", "options", "credits", "achievements"];
	static final buttonRevealRange:Float = 50;
	static final menuItemTweenOptions:TweenOptions = {ease: FlxEase.circOut};

	final name:String = Lib.application.meta["name"];
	final version:String = Lib.application.meta["version"];
	static final commitHash:String = GitHash.getGitCommitHash();
	
	static var curSelected:Int = 0;

	var disableInput:Bool = false;
	var menuPosTweens:Array<FlxTween>;
	
	var loginScreen:LoginScreen;
	var menuItems:FlxTypedGroup<FlxSprite>;

	public static var showKeybindsMenu:Bool = false;

	public static var showCredits:Bool = false;

	var skipText:FlxText;
	var videoDone:Bool = true;
	var vidSpr:FlxSprite;

	var allowTransit:Bool = false;

	public function new()
	{
		super();
	}
	
	override public function create()
	{
		super.create();

		#if debug
		debugTools = true;
		#end

		persistentUpdate = true;

		FlxG.mouse.visible = true;

		Application.current.window.title = Main.appTitle;
		DiscordClient.changePresence("In the Menus", null);

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menu/BG', 'preload'));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = FlxG.save.data.highquality;
		add(bg);

		var logo:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menu/LOGO', 'preload'));
		logo.origin.set();
		logo.scale.set(daScaling, daScaling);
		logo.updateHitbox();
		logo.antialiasing = FlxG.save.data.highquality;
		add(logo);

		var sketch:FlxSprite = new FlxSprite().loadGraphic(Paths.image("menu/sketch", "preload"), true, 1144, 940);
		sketch.animation.add("default", [0, 1, 2], 5, true);
		sketch.animation.play("default");
		sketch.origin.set();
		sketch.scale.set(daScaling, daScaling);
		sketch.updateHitbox();
		sketch.setPosition(1280 - sketch.width, 720 - sketch.height);
		sketch.antialiasing = FlxG.save.data.highquality;
		add(sketch);

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		var versionText:FlxText = new FlxText(0, FlxG.height - 22);
		versionText.setFormat(HelperFunctions.returnMenuFont(versionText), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		versionText.text = name + " v." + version;
		#if debug
		versionText.text = name + " v." + version + " commit " + commitHash;
		#end
		add(versionText);

		if (!FlxG.save.data.stopGJ && !GameJoltAPI.getStatus())
		{
			if (!Main.logAsked)
			{
				new FlxTimer().start(0.4, function(_:FlxTimer)
				{				
					loginScreen = new LoginScreen(controls);
					loginScreen.onClosed = function()
					{
						loginScreen.destroy();
						loginScreen = null;
						disableInput = false;
					};
					add(loginScreen);

					disableInput = true;
					Main.logAsked = true;
				});
			}
		}
		else
		{
			if (GameJoltAPI.getStatus() && !Main.logAsked)
			{
				Main.gjToastManager.createToast("assets/achievements/images/p7.png", 'Signed in as ' + GameJoltAPI.getUserInfo(), 'Connected to GameJolt', false);
				Main.logAsked = true;
			}
		}

		if (GameJoltAPI.getStatus())
		{
			if (GameJoltAPI.betatesters.contains(GameJoltAPI.getUserInfo()))
			{
				versionText.text += '  //  Thanks for being a beta tester!';
			}
			if (GameJoltAPI.getUserInfo().contains('penkaru'))
			{
				versionText.text += '  //  Thanks for being penkaru!';
			}
			if (GameJoltAPI.getUserInfo() == 'TKTems')
			{
				versionText.text += '  //  Fuck you tk';
			}
		}

		generateButtons(270, 100);
		changeSelection(curSelected);

		if (showCredits)
		{
			videoDone = false;

			vidSpr = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.WHITE);
			add(vidSpr);

			if (FlxG.sound.music != null)
				FlxG.sound.music.stop();

			skipText = new FlxText(0, FlxG.height - 26, 0, "Press Enter to skip", 18);
			skipText.alpha = 0;
			skipText.setFormat(HelperFunctions.returnMenuFont(skipText), 18, FlxColor.WHITE, RIGHT);
			skipText.scrollFactor.set();
			skipText.screenCenter(X);

			var video:VideoHandler = new VideoHandler(); // it plays but it doesn't show???
			video.allowSkip = FlxG.save.data.seenCredits;
			video.finishCallback = function()
			{
				FlxG.save.data.seenCredits = true;
				FlxG.save.flush();
				videoDone = true;
				vidSpr.visible = false;
				showCredits = false;
				remove(skipText);
			};
			video.playMP4(Paths.video('credits'), false, vidSpr, false, true, false);

			if (video.allowSkip)
			{
				add(skipText);
				FlxTween.tween(skipText, {alpha: 1}, 1, {ease: FlxEase.quadIn});
				FlxTween.tween(skipText, {alpha: 0}, 1, {ease: FlxEase.quadIn, startDelay: 4});
			}
		}

		new FlxTimer().start(Main.transitionDuration, function(tmr:FlxTimer)
		{
			allowTransit = true;
		});

		soundX = FlxG.width/2;
		ear = new FlxObject();
		ear.setPosition(soundX, FlxG.height/2);

		/*var username:String = 'user';
		if (GameJoltAPI.getStatus())
		{
			username = GameJoltAPI.getUserInfo();
		}
		else
		{
			username = HelperFunctions.getUsername();
		}
		trace(username);

		if (FileSystem.exists('./assets/data/user.txt'))
		{
			trace('user text found');
		}
		else
		{
			trace('user text not found');
			File.saveContent('./assets/data/user.txt', username);
		}*/

		//shitty fix (im sorry ppl who played the broken build)
					if (!FlxG.save.data.secretChars[0] && !FlxG.save.data.secretChars[1] && !FlxG.save.data.secretChars[2] 
						&& !FlxG.save.data.secretChars[3] && !FlxG.save.data.secretChars[4])
					{
						FlxG.save.data.freeplaylocked[2] = false;
					}

					if (!FlxG.save.data.secretChars[0] && !FlxG.save.data.shownalerts[0]) //cuphead bonus
					{
						FlxG.save.data.shownalerts[0] = true;
					}
					if (!FlxG.save.data.secretChars[1] && !FlxG.save.data.secretChars[2] && !FlxG.save.data.shownalerts[1]) //sans bonus
					{
						FlxG.save.data.shownalerts[1] = true;
					}
					if (!FlxG.save.data.secretChars[3] && !FlxG.save.data.secretChars[4] && !FlxG.save.data.shownalerts[2]) //bendy bonus
					{
						FlxG.save.data.shownalerts[2] = true;
					}
	}

	var soundX:Float = 0;
	var ear:FlxObject;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if ((!FlxG.sound.music.playing && videoDone) && !disableInput)
		{
			FlxG.sound.playMusic(Paths.music(Main.menuMusic));
		}

		if (!disableInput && videoDone)
		{
			if (FlxG.keys.justPressed.P && FlxG.keys.pressed.CONTROL && debugTools)
			{
				FlxG.save.data.freeplaylocked = [false, false, false];
				FlxG.save.data.weeksbeat = [true, true, true];
				FlxG.save.data.weeksbeatonhard = [true, true, true];
				FlxG.save.data.hasgenocided = true;
				FlxG.save.data.haspacifisted = true;
				//FlxG.save.data.secretChars = [false, false, false, false, false, false, false, false];

				FlxG.save.flush();

				FlxG.sound.play(Paths.sound('confirmMenu', 'preload'));
			}

			if (FlxG.keys.justPressed.DELETE)
			{
				persistentUpdate = false;
				openSubState(new Prompt("Are you sure you want to erase your save?"));
				Prompt.acceptThing = function()
				{
					FlxG.save.erase();
					FlxG.save.flush();
					FlxG.save.bind(Main.curSave, 'indiecross');
	
					KadeEngineData.initSave();
	
					trace('cleared data');
					FlxG.sound.play(Paths.sound('delete', 'preload'));
					TitleState.restart();
				}
				Prompt.backThing = function()
				{
					persistentUpdate = true;
				}
			}

			if (FlxG.keys.justPressed.I && FlxG.keys.pressed.CONTROL && debugTools)
			{
				//Main.switchState(new NotesplashOffsets());
				Main.switchState(new DiffButtonOffsets());
			}

			if (FlxG.keys.justPressed.LEFT && FlxG.keys.pressed.CONTROL && debugTools)
			{
				soundX -= 25;
			}

			if (FlxG.keys.justPressed.RIGHT && FlxG.keys.pressed.CONTROL && debugTools)
			{
				soundX += 25;
			}

			if (debugTools && soundX != FlxG.width/2)
			{
				FlxG.sound.music.proximity(soundX, FlxG.height/2, ear, 300, true);
			}

			#if cpp
			if (FlxG.keys.justPressed.SEMICOLON)
			{
				if (FlxG.keys.pressed.CONTROL)
				{
					DiscordClient.shutdown();
				}
				else
				{
					DiscordClient.initialize();
				}
			}
			#end

			if (FlxG.keys.justPressed.A && FlxG.keys.pressed.CONTROL && FlxG.keys.pressed.SHIFT && debugTools)
			{
				for (i in 0...Achievements.achievements.length)
				{
					pushToAchievementIDS(Achievements.achievements[i].name, false);
				}
			}

			var debuggers:Array<String> = ['BrightFyre', 'Sector03', 'volv'];

			if (debuggers.contains(GameJoltAPI.getUserInfo()))
			{
				if (FlxG.keys.justPressed.D && FlxG.keys.pressed.CONTROL)
				{
					debugTools = !debugTools;
					trace("Debug tools is now " + (debugTools ? "enabled." : "disabled."));
					FlxG.sound.play(Paths.sound('confirmMenu', 'preload'));
				}
			}


			if (FlxG.keys.justPressed.L && FlxG.keys.pressed.CONTROL && debugTools)
			{
				showcase = !showcase;
				trace("Showcase is now " + (showcase ? "enabled." : "disabled."));
				FlxG.sound.play(Paths.sound('confirmMenu', 'preload'));
			}

			if (FlxG.keys.justPressed.UP || FlxG.keys.justPressed.W)
			{
				changeSelection(curSelected - 1);
			}

			if (FlxG.keys.justPressed.DOWN || FlxG.keys.justPressed.S)
			{
				changeSelection(curSelected + 1);
			}

			if (controls.ACCEPT)
			{
				if (showKeybindsMenu && curSelected == 0)
				{
					persistentUpdate = false;
					openSubState(new KeyBindMenu());
					showKeybindsMenu = false;
					KeyBindMenu.backThing = function()
					{
						persistentUpdate = true;
						enterSelection();
					}
				}
				else
				{
					enterSelection();
				}
			}

			if (FlxG.mouse.justPressed && Main.focused)
			{
				if (FlxG.mouse.overlaps(menuItems.members[curSelected]))
				{
					if (showKeybindsMenu && curSelected == 0)
					{
						persistentUpdate = false;
						openSubState(new KeyBindMenu());
						showKeybindsMenu = false;
						KeyBindMenu.backThing = function()
						{
							persistentUpdate = true;
							enterSelection();
						}
					}
					else
					{
						enterSelection();
					}
				}
			}

			if ((controls.BACK || (FlxG.mouse.justPressedRight && Main.focused)) && allowTransit)
			{
				backOut();
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

			if (FlxG.mouse.justMoved)
			{
				for (i in 0...menuItems.length)
				{
					if (i != curSelected)
					{
						if (FlxG.mouse.overlaps(menuItems.members[i]) && !FlxG.mouse.overlaps(menuItems.members[curSelected]))
						{
							changeSelection(i);
						}
					}
				}
			}
		}
	}

	function backOut()
	{
		disableInput = true;
		FlxG.sound.play(Paths.sound('cancelMenu'));
		Main.switchState(new TitleState());
	}

	function generateButtons(yPos:Float, sep:Float)
	{
		if (menuItems == null)
			return;

		if (menuItems.members != null && menuItems.members.length > 0)
			menuItems.forEach(function(_:FlxSprite) {menuItems.remove(_); _.destroy(); } );

		menuPosTweens = new Array<FlxTween>();
		
		for (i in 0...menuStrings.length)
		{
			menuPosTweens.push(null);
			
			var str:String = menuStrings[i];

			var menuItem:FlxSprite = new FlxSprite()
				.loadGraphic(Paths.image("menu/buttons/" + str, "preload"));
			menuItem.origin.set();
			menuItem.scale.set(daScaling, daScaling);
			menuItem.updateHitbox();
			menuItem.alpha = 0.5;

			menuItem.shader = new WhiteOverlayShader();

			if (str == "achievements")
			{
				menuItem.setPosition(1280 - menuItem.width + buttonRevealRange, 630);
			}
			else
			{
				menuItem.setPosition(-buttonRevealRange, yPos + (i * sep));
			}
			
			menuItems.add(menuItem);
		}
	}

	function changeSelection(selection:Int)
	{
		if (selection != curSelected)
		{
			FlxG.sound.play(Paths.sound('scrollMenu'));
		}

		if (selection < 0)
			selection = menuStrings.length - 1;
		if (selection >= menuStrings.length)
			selection = 0;

		for (i in 0...menuStrings.length)
		{
			var str:String = menuStrings[i];
			var menuItem:FlxSprite = menuItems.members[i];
			if (i == selection)
			{
				menuItem.alpha = 1.0;
				if (menuPosTweens[i] != null)
				{
					menuPosTweens[i].cancelChain();
					menuPosTweens[i].destroy();
					menuPosTweens[i] = null;
				}
				if (str == "achievements")
					menuPosTweens[i] = FlxTween.tween(menuItem, {x: 1280 - menuItem.width}, 0.2, menuItemTweenOptions);
				else
					menuPosTweens[i] = FlxTween.tween(menuItem, {x: 0}, 0.2, menuItemTweenOptions);
			}
			else
			{
				if (menuItem.alpha == 1.0)
				{
					if (menuPosTweens[i] != null)
					{
						menuPosTweens[i].cancelChain();
						menuPosTweens[i].destroy();
						menuPosTweens[i] = null;
					}
				}
				
				if (str == "achievements")
					menuPosTweens[i] = FlxTween.tween(menuItem, {x: 1280 - menuItem.width + buttonRevealRange}, 0.35, menuItemTweenOptions);
				else
					menuPosTweens[i] = FlxTween.tween(menuItem, {x: -buttonRevealRange}, 0.35, menuItemTweenOptions);
				
				menuItem.alpha = 0.5;
			}
		}

		curSelected = selection;
	}

	function enterSelection()
	{
		disableInput = true;
		
		var str:String = menuStrings[curSelected];
		var menuItem:FlxSprite = menuItems.members[curSelected];

		if (menuPosTweens[curSelected] != null)
			menuPosTweens[curSelected].cancel();
		if (str == "achievements")
		{
			menuItem.x = 1280 - menuItem.width + buttonRevealRange;
			menuPosTweens[curSelected] = FlxTween.tween(menuItem, {x: 1280 - menuItem.width}, 0.4, menuItemTweenOptions);
		}
		else
		{
			menuItem.x = -buttonRevealRange;
			menuPosTweens[curSelected] = FlxTween.tween(menuItem, {x: 0}, 0.4, menuItemTweenOptions);
		}

		menuItem.shader.data.progress.value = [1.0];
		FlxTween.num(1.0, 0.0, 1.0, {ease: FlxEase.cubeOut}, function(num:Float)
		{
			menuItem.shader.data.progress.value = [num];
		});

		for (i in 0...menuItems.members.length)
		{
			if (i != curSelected)
			{
				FlxTween.tween(menuItems.members[i], {alpha: 0}, 1, {ease: FlxEase.cubeOut});
			}
		}

		if (str == 'options')
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.fadeOut(1, 0);
			}
		}
		
		FlxG.sound.play(Paths.sound('confirmMenu'));

		new FlxTimer().start(1, function(tmr:FlxTimer)
		{
			switch (str)
			{
				case "storymode":
					StoryMenuState.fromWeek = -1;
					Main.switchState(new StoryMenuState());
				case "freeplay":
					Main.switchState(new FreeplaySelect());
				case "options":
					FlxG.sound.music.stop();
					Main.switchState(new OptionsMenu());
				case "credits":
					Main.switchState(new CreditsMenu());
				case "achievements":
					Main.switchState(new AchievementsMenuState());
			}
		});
	}
}
