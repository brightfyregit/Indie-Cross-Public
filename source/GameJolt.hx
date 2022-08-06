import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.ui.FlxUIInputText;
import flash.display.BlendMode;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import openfl.Lib;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Sprite;
import openfl.text.TextField;
import openfl.text.TextFormat;
import tentools.api.FlxGameJolt as GJApi;

using StringTools;
class GameJoltAPI
{
	static var userLogin:Bool = false;
	public static var totalTrophies:Float = GJApi.TROPHIES_ACHIEVED + GJApi.TROPHIES_MISSING;

	public static var betatesters:Array<String> =
	[
		//Core 			(unknown @)
		'8owser16',
		'JellyFishEdm',
		//ray zord 		(unknown @)
		'UniqueGeese',
		//woops 		(unknown @)
		'KadeDev',
		'StickyBM',
		'BrightFyre',
		'PolybiusProxy'
	];

	public static function getUserInfo(username:Bool = true):String
	{
		if (username)
			return GJApi.username;
		else
			return GJApi.usertoken;
	}

	public static function getStatus():Bool
	{
		return userLogin;
	}

	public static function connect()
	{
		trace("Grabbing API keys...");
		GJApi.init(Std.int(GJKeys.id), Std.string(GJKeys.key), false);
	}

	public static function authDaUser(in1, in2, ?loginArg:Bool = false)
	{
		if (!userLogin)
		{
			GJApi.authUser(in1, in2, function(v:Bool)
			{
				trace("user: " + (in1 == "" ? "n/a" : in1));
				trace("token: " + in2);
				if (v)
				{
					trace("User authenticated!");
					FlxG.save.data.gjUser = in1;
					FlxG.save.data.gjToken = in2;
					FlxG.save.flush();
					userLogin = true;
					startSession();
					if (loginArg)
					{
						GameJoltLogin.login = true;
						Main.switchState(new GameJoltLogin());
					}
				}
				else
				{
					if (loginArg)
					{
						GameJoltLogin.login = true;
						Main.switchState(new GameJoltLogin());
					}
					trace("User login failure!");
				}
			});
		}
	}

	public static function deAuthDaUser()
	{
		closeSession();
		userLogin = false;
		trace(FlxG.save.data.gjUser + FlxG.save.data.gjToken);
		FlxG.save.data.gjUser = "";
		FlxG.save.data.gjToken = "";
		FlxG.save.flush();
		trace(FlxG.save.data.gjUser + FlxG.save.data.gjToken);
		trace("Logged out!");
		TitleState.restart();
	}

	public static function getTrophy(trophyID:Int)
	{
		if (userLogin)
		{
			GJApi.addTrophy(trophyID);
		}
	}

	/**
	 * 
	 * This function checks the data that we got back from GameJolt,
	 * if it says that the trophy is already unlocked,
	 * check if the trophy is unlocked IN THE GAME.
	 * 
	 * If it isn't, then unlock it.
	 * 
	 * NOTE: For this function to work, the Tenta's GameJolt API has to be modified.
	 * You must make the 'returnMap' variable available. A example: https://imgur.com/a/wj0ARTa
	 * 
	 * @param	trophyID	The ID of the trophy on GameJolt.
	 * 
	 */
	/*
		public static function checkTrophy(trophyID:Int)
		{
			GJApi.fetchTrophy(trophyID, function(returnMap)
			{
				var title:String = "";

				@:privateAccess
				{
					var trophies:String = GJApi.returnMap.get('trophies').toString();
					var data:String = 
					title = data;
				}

				@:privateAccess
				if (GJApi.returnMap.exists('message'))
				{
					var data:String = GJApi.returnMap.get('message').toString();
					if (data.contains('already'))
					{
						trace('unlocking alioIYOIWUYBCDOIWTBRCOIWBT');
						Achievements.unlockAchievement(title, true);
					}
				}

				@:privateAccess
				if (GJApi.returnMap.exists('achieved'))
				{
					var data:String = GJApi.returnMap.get('achieved').toString();
					if (data.contains('true'))
					{
						trace('synced from gj!');
						Achievements.unlockAchievement(title, true);
					}
				}
			});
		}
	 */
	public static function startSession()
	{
		GJApi.openSession(function()
		{
			trace("Session started!");
			new FlxTimer().start(20, function(tmr:FlxTimer)
			{
				pingSession();
			}, 0);
		});
	}

	public static function pingSession()
	{
		GJApi.pingSession(true, function()
		{
			trace("Ping!");
		});
	}

	public static function closeSession()
	{
		GJApi.closeSession(function()
		{
			trace('Closed out the session');
		});
	}
}

class GameJoltInfo extends FlxSubState
{
	public static var version:String = "1.0.2 Public Beta";
	public static var fontPath:String = "assets/fonts/Bronx.otf";
}

class GameJoltLogin extends MusicBeatState
{
	var loginTexts:FlxTypedGroup<FlxText>;
	var loginBoxes:FlxTypedGroup<FlxUIInputText>;
	var loginButtons:FlxTypedGroup<FlxButton>;
	var usernameText:FlxText;
	var tokenText:FlxText;
	var usernameBox:FlxUIInputText;
	var tokenBox:FlxUIInputText;
	var signInBox:FlxButton;
	var helpBox:FlxButton;
	var logOutBox:FlxButton;
	var cancelBox:FlxButton;
	var profileIcon:FlxSprite;
	var username:FlxText;
	var gamename:FlxText;
	var trophy:FlxBar;
	var trophyText:FlxText;
	var missTrophyText:FlxText;
	public static var fromOptions:Bool = false;
	var menuItems:FlxTypedGroup<GJButton>;

	public static var charBop:FlxSprite;

	var icon:FlxSprite;
	var baseX:Int = 370;
	var versionText:FlxText;
	var curSelected:Int = -1;

	public static var login:Bool = false;
	static var trophyCheck:Bool = false;

	override function create()
	{
		super.create();

		persistentUpdate = true;

		trace("init? " + GJApi.initialized);
		FlxG.mouse.visible = true;

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('gamejolt/Background', 'preload'));
		bg.setGraphicSize(FlxG.width);
		bg.antialiasing = true;
		bg.updateHitbox();
		bg.screenCenter();
		bg.scrollFactor.set();
		add(bg);

		charBop = new FlxSprite();
		charBop.frames = Paths.getSparrowAtlas('gamejolt/BF', 'preload');
		charBop.animation.addByPrefix('idle', 'BF  instance 1', 24, false);
		charBop.setGraphicSize(Std.int(charBop.width * 1.3));
		charBop.antialiasing = true;
		charBop.updateHitbox();
		charBop.screenCenter();
		charBop.x -= 350;
		charBop.y += 200;
		charBop.animation.play('idle', true);
		charBop.blend = BlendMode.ADD;
		add(charBop);

		loginTexts = new FlxTypedGroup<FlxText>(2);
		add(loginTexts);

		usernameText = new FlxText(0, 125, 300, "Username:", 30);
		usernameText.alignment = CENTER;

		tokenText = new FlxText(0, 225, 300, "Token:", 30);
		tokenText.alignment = CENTER;

		loginTexts.add(usernameText);
		loginTexts.add(tokenText);
		loginTexts.forEach(function(item:FlxText)
		{
			item.screenCenter(X);
			item.x += baseX;
			item.font = HelperFunctions.returnMenuFont(item);
		});

		loginBoxes = new FlxTypedGroup<FlxUIInputText>(2);
		add(loginBoxes);

		usernameBox = new FlxUIInputText(0, 175, 300, '', 32, FlxColor.BLACK, FlxColor.GRAY);
		tokenBox = new FlxUIInputText(0, 275, 300, '', 32, FlxColor.BLACK, FlxColor.GRAY);

		loginBoxes.add(usernameBox);
		loginBoxes.add(tokenBox);
		loginBoxes.forEach(function(item:FlxUIInputText)
		{
			item.screenCenter(X);
			item.x += baseX;
		});

		if (GameJoltAPI.getStatus())
		{
			remove(loginTexts);
			remove(loginBoxes);
		}

		menuItems = new FlxTypedGroup<GJButton>();
		add(menuItems);

		if (!GameJoltAPI.getStatus())
		{
			addButton(0, 'Sign In', 50);
			addButton(1, 'Get Token', 165);
			addButton(2, 'Go Back', 280);
		}
		else
		{
			addButton(0, 'Continue', 165);
			addButton(1, 'Log Out', 280);
		}

		if (GameJoltAPI.getStatus())
		{
			/* not working for some reason
				FlxGameJolt.fetchAvatarImage(function(avatar:BitmapData)
				{
					var avatarImage:FlxSprite = new FlxSprite();
					avatarImage.loadGraphic(FlxGraphic.fromBitmapData(avatar));
					avatarImage.antialiasing = true;
					avatarImage.updateHitbox();
					avatarImage.screenCenter();
					avatarImage.x += 350;
					avatarImage.y += 200;
					remove(charBop);
					add(avatarImage);
				});
			 */

			trace(GameJoltAPI.getUserInfo());
			username = new FlxText(0, 75, 400, "Signed in as:\n" + GameJoltAPI.getUserInfo(), 40);
			username.alignment = CENTER;
			username.screenCenter(X);
			username.font = HelperFunctions.returnMenuFont(username);
			username.x += baseX;
			username.y += 200;
			add(username);
		}
	}

	function addButton(id:Int, text:String, yOffset:Int)
	{
		var menuItem:GJButton = new GJButton(0, 0, text);
		menuItem.updateHitbox();
		menuItem.screenCenter();

		//small fix for the mouse overriding key selection thing

		menuItem.x += baseX;
		menuItem.y += yOffset;

		var text:FlxText = new FlxText(menuItem.x, menuItem.y, 400, text, 37);
		text.alignment = CENTER;
		text.color = FlxColor.BLACK;
		text.font = HelperFunctions.returnMenuFont(text);
		text.y += 35;
		text.alpha = 0.5;
		add(text);
		
		menuItems.add(menuItem);
	}

	function changeSelection(selection:Int)
	{
		if (!selected)
		{
			if (menuItems.members[selection].curAnimName == 'idle')
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
	
				curSelected = selection;
	
				if (!selected)
				{
					for (i in 0...menuItems.length)
					{
						if (i == curSelected)
						{
							menuItems.members[i].playAnim('hover', true);
						}
						else
						{
							menuItems.members[i].playAnim('idle', true);
						}
					}
				}
			}
		}
	}

	var selected:Bool = false;

	function selectButton()
	{
		if (!selected)
		{
			if (menuItems.members[curSelected].daText != 'Get Token')
			{
				selected = true;
			}
			menuItems.members[curSelected].playAnim('select', true);
			switch (menuItems.members[curSelected].daText)
			{
				case 'Sign In':
				{
					//Sign In
					trace(usernameBox.text);
					trace(tokenBox.text);
					FlxG.sound.play(Paths.sound('confirmMenu'));
					changeSelection(-1);
					GameJoltAPI.authDaUser(usernameBox.text, tokenBox.text, true);
				}
				case 'Get Token':
				{
					//Gamejolt Token Tutorial
					HelperFunctions.fancyOpenURL('https://www.youtube.com/watch?v=T5-x7kAGGnE');
				}
				case 'Go Back' | 'Continue':
				{
					//Go Back OR Continue
					FlxG.sound.play(Paths.sound('cancelMenu'));

					var durag:Float = 0;
		
					if (GameJoltLogin.fromOptions)
					{
						durag = 0.5;
						if (FlxG.sound.music != null)
						{
							FlxG.sound.music.fadeOut(0.5, 0);
						}
					}
			
					new FlxTimer().start(durag, function(tmr:FlxTimer)
					{
						if (GameJoltLogin.fromOptions)
						{
							FlxG.sound.music.stop();
						}
						GameJoltLogin.fromOptions = false;
						Main.switchState(new MainMenuState());
					});
				}
				case 'Log Out':
				{
					//Log Out & Restart
					GameJoltAPI.deAuthDaUser();
				}
			}
		}
	}

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		if (FlxG.mouse.justPressed)
		{
			if (curSelected != -1)
			{
				if (FlxG.mouse.overlaps(menuItems.members[curSelected]))
				{
					selectButton();
				}
			}
		}

		if (FlxG.mouse.justMoved)
		{
			for (i in 0...menuItems.members.length)
			{
				if (FlxG.mouse.overlaps(menuItems.members[i]))
				{
					changeSelection(i);
				}
				else
				{
					menuItems.members[i].playAnim('idle', true);
				}
			}
		}

		if (!FlxG.sound.music.playing)
		{
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
		}

		if (FlxG.keys.justPressed.ESCAPE)
		{
			if (GameJoltLogin.fromOptions)
			{
				FlxG.sound.music.stop();
			}
			GameJoltLogin.fromOptions = false;
			Main.switchState(new MainMenuState());
		}

		super.update(elapsed);
	}

	override function beatHit()
	{
		super.beatHit();
		charBop.animation.play('idle', true);
	}
}

class GJButton extends FlxSprite
{
	public var animOffsets:Map<String, Array<Dynamic>>;
	public var daZoom:Float = 1;
	public var daText:String;
	public var curAnimName:String = 'idle';

	public function new(x:Int, y:Int, text:String)
	{
		super(x, y);
		daText = text;
		animOffsets = new Map<String, Array<Dynamic>>();
		
		frames = Paths.getSparrowAtlas("gamejolt/Button_shit", "preload");
		animation.addByPrefix('idle', 'Button instance 1', 24, true);
		animation.addByPrefix('hover', 'Mouse on the button instance 1', 24, false);
		animation.addByPrefix('select', 'Button Click instance 1', 24, false);

		addOffset('idle', 0, 0);
		addOffset('hover', 15, 4);
		addOffset('select', 0, 0);

		playAnim('idle', true);

		blend = BlendMode.ADD;
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

class GJToastManager extends Sprite
{
	public static var ENTER_TIME:Float = 0.5;
	public static var DISPLAY_TIME:Float = 2.0;
	public static var LEAVE_TIME:Float = 0.5;
	public static var TOTAL_TIME:Float = ENTER_TIME + DISPLAY_TIME + LEAVE_TIME;
	public static var leSound:FlxSound;

	var playTime:FlxTimer = new FlxTimer();

	public function new()
	{
		super();
		FlxG.signals.postStateSwitch.add(onStateSwitch);
		FlxG.signals.gameResized.add(onWindowResized);
		leSound = new FlxSound().loadEmbedded(Paths.sound('achievement'));
		leSound.persist = true;
		leSound.volume = 1;
	}

	/**
	 * Create a toast!
	 * 
	 * Usage: **Main.gjToastManager.createToast(iconPath, title, description);**
	 * @param iconPath Path for the image **Paths.getLibraryPath("image/example.png")**
	 * @param title Title for the toast
	 * @param description Description for the toast
	 * @param sound Want to have an alert sound? Set this to **true**! Defaults to **false**.
	 */
	public function createToast(iconPath:String, title:String, description:String, ?sound:Bool = false, ?color:FlxColor = 0xFFFF00):Void
	{
		var toast = new Toast(iconPath, title, description, color);
		addChild(toast);

		if (sound)
		{
			leSound.play();
			new FlxTimer().start(0.4, function(tmr:FlxTimer)
			{
				loadToast();
			});
		}
		else
		{
			loadToast();
		}
	}

	function loadToast()
	{
		playTime.start(TOTAL_TIME);
		playToasts();
	}

	public function playToasts():Void
	{
		for (i in 0...numChildren)
		{
			var child = getChildAt(i);
			FlxTween.cancelTweensOf(child);
			FlxTween.tween(child, {y: (numChildren - 1 - i) * child.height}, ENTER_TIME, {
				ease: FlxEase.quadOut,
				onComplete: function(tween:FlxTween)
				{
					FlxTween.cancelTweensOf(child);
					FlxTween.tween(child, {y: (i + 1) * -child.height}, ((LEAVE_TIME / 2) * numChildren), {
						ease: FlxEase.quadIn,
						startDelay: DISPLAY_TIME,
						onComplete: function(tween:FlxTween)
						{
							cast(child, Toast).removeChildren();
							removeChild(child);
						}
					});
				}
			});
		}
	}

	public function collapseToasts():Void
	{
		for (i in 0...numChildren)
		{
			var child = getChildAt(i);
			FlxTween.tween(child, {y: (i + 1) * -child.height}, ((LEAVE_TIME / 2) * numChildren), {
				ease: FlxEase.quadIn,
				onComplete: function(tween:FlxTween)
				{
					cast(child, Toast).removeChildren();
					removeChild(child);
				}
			});
		}
	}

	public function onStateSwitch():Void
	{
		if (!playTime.active)
			return;

		var elapsedSec = playTime.elapsedTime / 1000;
		if (elapsedSec < ENTER_TIME)
		{
			for (i in 0...numChildren)
			{
				var child = getChildAt(i);
				FlxTween.cancelTweensOf(child);
				FlxTween.tween(child, {y: (numChildren - 1 - i) * child.height}, ENTER_TIME - elapsedSec, {
					ease: FlxEase.quadOut,
					onComplete: function(tween:FlxTween)
					{
						FlxTween.cancelTweensOf(child);
						FlxTween.tween(child, {y: (i + 1) * -child.height}, ((LEAVE_TIME / 2) * numChildren), {
							ease: FlxEase.quadIn,
							startDelay: DISPLAY_TIME,
							onComplete: function(tween:FlxTween)
							{
								cast(child, Toast).removeChildren();
								removeChild(child);
							}
						});
					}
				});
			}
		}
		else if (elapsedSec < DISPLAY_TIME)
		{
			for (i in 0...numChildren)
			{
				var child = getChildAt(i);
				FlxTween.cancelTweensOf(child);
				FlxTween.tween(child, {y: (i + 1) * -child.height}, ((LEAVE_TIME / 2) * numChildren), {
					ease: FlxEase.quadIn,
					startDelay: DISPLAY_TIME - (elapsedSec - ENTER_TIME),
					onComplete: function(tween:FlxTween)
					{
						cast(child, Toast).removeChildren();
						removeChild(child);
					}
				});
			}
		}
		else if (elapsedSec < LEAVE_TIME)
		{
			for (i in 0...numChildren)
			{
				var child = getChildAt(i);
				FlxTween.tween(child, {y: (i + 1) * -child.height}, ((LEAVE_TIME / 2) * numChildren) - (elapsedSec - ENTER_TIME - DISPLAY_TIME), {
					ease: FlxEase.quadIn,
					onComplete: function(tween:FlxTween)
					{
						cast(child, Toast).removeChildren();
						removeChild(child);
					}
				});
			}
		}
	}

	public function onWindowResized(x:Int, y:Int):Void
	{
		for (i in 0...numChildren)
		{
			var child = getChildAt(i);
			child.x = Lib.current.stage.stageWidth - child.width;
		}
	}
}

class Toast extends Sprite
{
	var back:Bitmap;
	var icon:Bitmap;
	var title:TextField;
	var desc:TextField;

	public function new(iconPath:String, titleText:String, description:String, color:FlxColor)
	{
		super();
		back = new Bitmap(new BitmapData(500, 125, true, 0xFF000000));
		back.alpha = 0.9;
		back.x = 0;
		back.y = 0;

		if (iconPath != null)
		{
			icon = new Bitmap(BitmapData.fromFile(iconPath));
			trace("BITMAP DATA: " + BitmapData.fromFile(iconPath));
			icon.x = 10;
			icon.y = 10;

			if (titleText == 'Saness')
			{
				icon.width = 118;
			}
			else
			{
				icon.width = 100;
			}
			icon.height = 100;
		}

		title = new TextField();
		title.text = titleText;
		title.setTextFormat(new TextFormat(HelperFunctions.returnMenuFont(), 24, 0xFFFF00, true));
		if (color != 0xFFFF00)
		{
			title.textColor = color;
		}
		title.wordWrap = true;
		title.width = 360;
		if (iconPath != null)
		{
			title.x = 120;
		}
		else
		{
			title.x = 5;
		}
		title.y = 10;

		desc = new TextField();
		desc.text = description;
		desc.setTextFormat(new TextFormat(HelperFunctions.returnMenuFont(), 18, 0xFFFFFF));
		desc.wordWrap = true;
		desc.width = 360;
		desc.height = 95;

		if (iconPath != null)
		{
			desc.x = 120;
		}
		else
		{
			desc.x = 5;
		}
		desc.y = 35;
		
		if (titleText.length >= 25 || titleText.contains("\n"))
		{
			desc.y += 25;
			desc.height -= 25;
		}

		addChild(back);
		if (iconPath != null)
		{
			addChild(icon);
		}
		addChild(title);
		addChild(desc);

		width = back.width;
		height = back.height;
		x = Lib.current.stage.stageWidth - width;
		y = -height;
	}
}
