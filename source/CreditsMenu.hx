package;

import flixel.util.FlxTimer;
import flixel.input.gamepad.FlxGamepad;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import openfl.display.BitmapData;
import sys.Http;
import sys.io.Process;

using StringTools;

// ye i fucked up formatting
// cry about it
// change hxformat.json if u wanna avoid
class CreditsMenu extends MusicBeatState
{
	static final credits:Array<Array<String>> = [
		[
			'Brightfyre',
			"indie cross season 2",
			'Leader',
			"0",
			"https://linktr.ee/BrightFyre"
		],
		[
			'moro',
			"Nothing is permanent. Bad times will pass away. Just keep yourself together",
			'Animator',
			"2",
			"https://twitter.com/moro_nighteye"
		],
		[
			'JzBoy',
			"I want to play FNF Indie Cross",
			"Artist",
			"0",
			"https://twitter.com/JzBoyAnims"
		],
		[
			'Iku Aldena',
			"Jtm comme l7em, mais l7em pour chwa, et toi pour l7wa",
			"Artist",
			"1",
			"https://twitter.com/Iku_Aldena"
		],
		[
			'Crae',
			"hahahahahahahahahahahaahahahahahahhahahahahahahahahahaha lol",
			"Artist",
			"2",
			"https://www.youtube.com/channel/UCw56btKqHAJUYPYhjrDjuAw"
		],
		[
			'Diavololi',
			"Scourge of Mongolia",
			"Artist",
			"0",
			"https://twitter.com/d1avololi"
		],
		[
			'Sugarratio',
			"I like drawing and animating stickfigures",
			'Artist',
			"1",
			"https://twitter.com/SugarRatio"
		],
		[
			'Cally3D',
			"I made a singular 3D model why am I here!?",
			"Artist",
			"1",
			"https://twitter.com/Cally3D"
		],
		[
			'River',
			"Wait, I worked on this?",
			"Artist",
			"0",
			"https://twitter.com/RiverOaken"
		],
		[
			'nonsense',
			"did you just shot me?",
			"Artist",
			"0",
			"https://www.youtube.com/c/NonsenseHumorLOL"
		],
		[
			'Sector',
			"I don't think Indie Cross can beat Goku :/",
			"Developer",
			"1",
			"https://twitter.com/Sector0003"
		],
		[
			'Shadowfi', 
			"mozo", 
			'Developer', 
			"0", 
			"https://twitter.com/Shadowfi1385"
		],
		[
			'Gedehari',
			"Good at programming, bad at everything else.",
			"Developer",
			"1",
			"https://twitter.com/gedehari"
		],
		[
			'Perez',
			"el pepe",
			"Developer",
			"0",
			"https://www.youtube.com/c/sebaelperezoso/featured"
		],
		[
			'Proxy',
			"made mp4 support, follow me on twitter!111",
			"Developer",
			"1",
			"https://twitter.com/polybiusproxy"
		],
		[
			'Smokey', 
			"kenny's a bitch", 
			'Developer', 
			"0", 
			"https://twitter.com/Smokey_5_"
		],
		[
			'Hexar',
			"brightfyre is a 5head",
			"Developer",
			"0",
			"https://twitter.com/hexar__"
		],
		[
			'volv',
			"how did i get here?",
			"Developer",
			"0",
			"https://twitter.com/_Volved"
		],
		[
			'KadeDev',
			"pasc *kissing noises*",
			"Developer",
			"0",
			"https://twitter.com/KadeDeveloper"
		],
		[
			'Taeyai', 
			"I can do anything!", 
			"Developer", 
			"0", 
			"https://twitter.com/Taeyai_"
		],
		[
			'isophoro',
			"play vs isophoro",
			'Developer',
			"3",
			"https://twitter.com/isophoro"
		],




		[
			'Saster',
			"quality content, as usual",
			"Musician",
			"0",
			"https://www.youtube.com/channel/UCC4CkqOAwulRil3BEK9L3Mg"
		],
		[
			'Saru',
			"Momazos Saru",
			'Musician',
			"0",
			"https://www.youtube.com/channel/UCKLD_M9TFSzgMTECZ6lcyrw"
		],
		[
			'Tenzu',
			"pico pichula weon conchetumare culiao uwu",
			"Musician",
			"1",
			"https://www.youtube.com/channel/UC7KmfbdAPt2bYCcSNJnCm-g"
		],
		[
			'TheInnuend0',
			"H",
			"Musician",
			"0",
			"https://www.youtube.com/channel/UCPM7_b1BzPxOerSEJmKxZCw"
		],
		[
			'Orenji',
			"top 10 cheese",
			"Musician",
			"0",
			"https://www.youtube.com/channel/UCUrh__AJo0Y_pCwJYjB7shw"
		],
		[
			'Yingyang',
			"Sans Undertale is my father",
			'Musician',
			"0",
			"https://www.youtube.com/channel/UCnIjU-JNj3szZ1Q8tLCKjuw"
		],
		[
			'Rozebud',
			"Download Bunker Bumrush",
			'Musician',
			"0",
			"https://www.youtube.com/c/Rozebud/featured"
		],
		[
			'DAGames',
			"Wheres my wife? Can someone find my wife?",
			"Musician",
			"1",
			"https://www.youtube.com/channel/UCK7OXr0m5mnM1z9p7n_Bwfw"
		],
		[
			'CrystalSlime', // the cool one of the team (shhh dont tell the others) //WTF Crystal? - TaeYai
			"you can wake up being yourself but you cant wake up being a different self than you originally were. so shoot for the moon between all of the stars because every day is a chance to start the day with a new day. thats the first step in the process of opening up your mind",
			"Musician",
			"3",
			"https://www.youtube.com/channel/UCT_wYKD4twxoYOZt2ggXHlw"
		],
		[
			'BLVKAROT',
			"50% Sea, 50% Weed, and 100% reason to remember the name.",
			"Musician",
			"1",
			"https://www.youtube.com/channel/UCPRT4ptgtoz-jPD_hqJ3mtg"
		],
		[
			'Joan Atlas',
			"ete sech",
			"Musician",
			"0",
			"https://www.youtube.com/channel/UCraIAPdHnnkJxfapv8oRv0w"
		],
		[
			'Mike Geno',
			"I make music for fun",
			"Musician",
			"0",
			"https://www.youtube.com/channel/UCyDQKOgEjuIiuPXctcuQKlg"
		],
		[
			'CDmusic',
			"hi I’m bri’ish and I make music for a bunch of stuff :p also 375bpm",
			"Musician",
			"2",
			"https://www.youtube.com/channel/UCOItBqiAAbWEdm21Mcv3g_Q"
		],
		[
			'BBpanzu',
			"Know your worth.",
			"Musician",
			"0",
			"https://www.youtube.com/c/bbpanzuRulesSoSubscribeplz123/featured"
		],
		[
			'Brandxn',
			"You can call me the worst producer",
			'Musician',
			"1",
			"https://www.youtube.com/c/Brandxns/featured"
		],




		[
			'Kal',
			"i love snas",
			"Charter",
			"0",
			"https://twitter.com/Kal_050"
		],
		[
			'DJ',
			"The amount of dandruff in your hair bro, if i were to smack your shit. It would be a smoke screen",
			"Charter",
			"3",
			"https://twitter.com/AlchoholicDj"
		],
		[
			'Cerbera',
			"Nightmare Nightmare Nightmare Nightmare Nightmare Nightmare Nightmare",
			"Charter",
			"2",
			"https://twitter.com/Cerbera_fnf"
		],
		[
			'Cval', 
			"what the? im jads?", 
			"Charter", 
			"0", 
			"https://twitter.com/cval_brown"
		]
	];

	var specialThanksMain:String = 
		"James Dijit (VA of Sammy)\n
		Dextermanning (Devil vocals)\n
		Fliper (Pixel art for the First Sans Cutscene)\n
		OblivionFall (Additional Anims and Special Effects)\n
		Mashed:Tim Bender (Additional Special Effects)\n
		J-Bug and YamaHearted (Owners of the Papyrus Song)\n
		Salterino(Sound effects)\n
		SrPelo (VA of Saness)\n
		Axelorca (Menu SFX)\n
		TentaRJ/Firubii (Original Flixel Gamejolt support)\n
		CanadianGoose (Cuphead Gameover Editor)\n
		Yoshubs (Additional Programming)"
	;

	var specialThanksExtra:String = 
		'Penkaru\n
		Uniquegeese, StickyBM\n
		Woops, RayZord\n
		8owser16, Core\n
		VaporTheGamer, 8-BitRyan\n
		Dawko, niffirg\n
		Mikeeey, JellyFish\n
		HugeNate (i love hugenate)\n'
	;

	var bg:FlxSprite;
	var bigIcon:FlxSprite;

	var selctionHighlighter:FlxSprite;

	var credIcons:Array<FlxSprite> = [];
	var bigIconsAssets:Array<BitmapData> = [];

	var bgAssets:Array<BitmapData> = [];

	var selXLerp:Float = 0;
	var selYLerp:Float = 0;

	var curIcon:Int = -1;

	var credLargeName:FlxText;
	var credQuoteText:FlxText;
	var credRoleText:FlxText;

	var credTypes:Array<String> = ["Leader", "Coder", "Music", "Charter", "Artist"];

	var quoteBack:FlxSprite;

	var specialThanksText:FlxText;

	var thanksOverlay:FlxSprite;

	var thanksTitle:FlxSprite;

	var allowTransit:Bool = false;

	override function create()
	{
		super.create();

		persistentUpdate = true;

		FlxG.mouse.visible = true;

		bg = new FlxSprite().loadGraphic(Paths.image('credits/bg/Leader_BG', 'preload'));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = FlxG.save.data.highquality;
		add(bg);

		for (i in 0...credTypes.length)
		{
			var bgBitmap:BitmapData = BitmapData.fromFile(Paths.image("credits/bg/" + credTypes[i] + '_BG', "preload"));
			bgAssets.push(bgBitmap);
		}

		for (i in 0...credits.length)
		{
			var bigIconAsset:BitmapData = BitmapData.fromFile(Paths.image("credits/icons/big_icons/" + credits[i][0], "preload"));
			bigIconsAssets.push(bigIconAsset);
			//make the small ones use the big ones just resized, saves a bit of loading time(not really)


			var smallIcon:FlxSprite = new FlxSprite().loadGraphic(bigIconAsset);
			smallIcon.setGraphicSize(102,102);
			smallIcon.updateHitbox();

			if (i < 28)
			{
				smallIcon.x = (17 + ((i * 110) % (7 * 110)));
				smallIcon.y = 25 + (110 * Math.ffloor(i / 7));
			}
			else
			{
				smallIcon.x = (55 + (((i - 1) * 110) % (6 * 110)));
				smallIcon.y = 25 + (110 * (Math.ffloor((i - 4) / 6)));
			}

			add(smallIcon);
			smallIcon.ID = i;
			FlxMouseEventManager.add(smallIcon, null, null, hoverCallback,null,false,true,false);

			credIcons.push(smallIcon);

			//var bigIconAsset:BitmapData = BitmapData.fromFile(Paths.image("credits/icons/big_icons/" + credits[i][0], "preload"));
			//bigIconsAssets.push(bigIconAsset);
		}

		selctionHighlighter = new FlxSprite(3, 11).loadGraphic(BitmapData.fromFile(Paths.image('credits/icons/selector', 'preload')));
		selctionHighlighter.setGraphicSize(Std.int(selctionHighlighter.width * 0.7));
		selctionHighlighter.updateHitbox();
		selctionHighlighter.antialiasing = FlxG.save.data.highquality;
		selctionHighlighter.visible = false;
		add(selctionHighlighter);

		bigIcon = new FlxSprite(718, -50);
		bigIcon.scale.set(0.65, 0.65);
		bigIcon.updateHitbox();
		bigIcon.antialiasing = FlxG.save.data.highquality;
		add(bigIcon);
		bigIcon.loadGraphic(bigIconsAssets[0], false, bigIcon.frameWidth, bigIcon.frameHeight, true);

		credLargeName = new FlxText(748, 422, 500, 'MORO');
		credLargeName.setFormat(Paths.font("Bronx.otf"), 64, FlxColor.WHITE);
		credLargeName.alignment = CENTER;
		add(credLargeName);

		credRoleText = new FlxText(770, 478, 450, 'LEADER');
		credRoleText.setFormat(Paths.font("Bronx.otf"), 32, 0xFFB254FF);
		credRoleText.alignment = CENTER;
		add(credRoleText);

		quoteBack = new FlxSprite(744, 535).loadGraphic(Paths.image('credits/bg/quote_box', 'preload'));
		quoteBack.setGraphicSize(Std.int(quoteBack.width * 0.75));
		quoteBack.updateHitbox();
		quoteBack.antialiasing = FlxG.save.data.highquality;
		quoteBack.blend = OVERLAY;
		quoteBack.visible = false;
		add(quoteBack);

		specialThanksText = new FlxText(quoteBack.x, quoteBack.y + 120, 500, 'Press TAB for Special Thanks');
		specialThanksText.setFormat(Paths.font("Bronx.otf"), 16, FlxColor.WHITE);
		specialThanksText.alignment = CENTER;
		add(specialThanksText);

		credQuoteText = new FlxText(740, 580, 500, " ");
		credQuoteText.setFormat(Paths.font("Bronx.otf"), 28, FlxColor.WHITE);
		credQuoteText.alignment = CENTER;
		add(credQuoteText);

		thanksOverlay = new FlxSprite().makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
		thanksOverlay.updateHitbox();
		thanksOverlay.screenCenter();
		thanksOverlay.scrollFactor.set();
		thanksOverlay.alpha = 0.00001;
		add(thanksOverlay);

		thanksTitle = new FlxSprite(0, 50);
		thanksTitle.frames = Paths.getSparrowAtlas('credits/Special_Thanks', 'preload');
		thanksTitle.animation.addByPrefix('play', 'SP instance 1', 24, true);
		thanksTitle.animation.play('play');
		thanksTitle.updateHitbox();
		thanksTitle.screenCenter(X);
		thanksTitle.antialiasing = FlxG.save.data.highquality;
		thanksTitle.alpha = 0;
		add(thanksTitle);

		lthanks = new FlxText(0, 200, 500, specialThanksMain);
		lthanks.setFormat(Paths.font("Bronx.otf"), 16, FlxColor.WHITE);
		lthanks.alignment = LEFT;
		lthanks.screenCenter(X);
		lthanks.x -= 200;
		lthanks.alpha = 0;
		add(lthanks);

		rthanks = new FlxText(0, 200, 500, specialThanksExtra);
		rthanks.setFormat(Paths.font("Bronx.otf"), 16, FlxColor.WHITE);
		rthanks.alignment = RIGHT;
		rthanks.screenCenter(X);
		rthanks.x += 200;
		rthanks.alpha = 0;
		add(rthanks);

		updateSelection(0);

		new FlxTimer().start(Main.transitionDuration, function(tmr:FlxTimer)
		{
			allowTransit = true;
		});
	}

	var lthanks:FlxText;
	var rthanks:FlxText;

	function hoverCallback(object:FlxObject)
	{
		if (!thanksOpen)
		{
			trace("overlap " + object.ID);
			FlxG.sound.play(Paths.sound('scrollMenu'));
			updateSelection(object.ID);
			curIcon = object.ID;
		}
	}

	function backOut()
	{
		if (thanksOpen)
		{
			thanksOpen = false;
			FlxTween.tween(selctionHighlighter, {alpha: 1}, 0.5, {ease: FlxEase.quadOut});
			FlxTween.tween(specialThanksText, {alpha: 1	}, 0.5, {ease: FlxEase.quadOut});
			FlxTween.tween(thanksTitle, {alpha: 0}, 0.5, {ease: FlxEase.quadOut});
			FlxTween.tween(lthanks, {alpha: 0}, 0.5, {ease: FlxEase.quadOut});
			FlxTween.tween(rthanks, {alpha: 0}, 0.5, {ease: FlxEase.quadOut});
			FlxTween.tween(thanksOverlay, {alpha: 0}, 0.5, {ease: FlxEase.quadOut, onComplete: function(twn:FlxTween)
			{
				whiteTweening = false;
			}});
		}
		else
		{
			allowTransit = false;
			FlxG.sound.play(Paths.sound('cancelMenu'));
			Main.switchState(new MainMenuState());
		}
	}

	var thanksOpen:Bool = false;
	var whiteTweening:Bool = false;

	function toggleThanks()
	{
		if (!whiteTweening)
		{
			whiteTweening = true;
			if (!thanksOpen)
			{
				//open menu
				thanksOpen = true;
				FlxTween.tween(selctionHighlighter, {alpha: 0}, 0.5, {ease: FlxEase.quadOut});
				FlxTween.tween(specialThanksText, {alpha: 0}, 0.5, {ease: FlxEase.quadOut});
				FlxTween.tween(thanksTitle, {alpha: 1}, 0.5, {ease: FlxEase.quadOut});
				FlxTween.tween(lthanks, {alpha: 1}, 0.5, {ease: FlxEase.quadOut});
				FlxTween.tween(rthanks, {alpha: 1}, 0.5, {ease: FlxEase.quadOut});
				FlxTween.tween(thanksOverlay, {alpha: 0.7}, 0.5, {ease: FlxEase.quadOut, onComplete: function(twn:FlxTween)
				{
					whiteTweening = false;
				}});
			}
			else
			{
				//close menu
				thanksOpen = false;
				FlxTween.tween(selctionHighlighter, {alpha: 1}, 0.5, {ease: FlxEase.quadOut});
				FlxTween.tween(specialThanksText, {alpha: 1	}, 0.5, {ease: FlxEase.quadOut});
				FlxTween.tween(thanksTitle, {alpha: 0}, 0.5, {ease: FlxEase.quadOut});
				FlxTween.tween(lthanks, {alpha: 0}, 0.5, {ease: FlxEase.quadOut});
				FlxTween.tween(rthanks, {alpha: 0}, 0.5, {ease: FlxEase.quadOut});
				FlxTween.tween(thanksOverlay, {alpha: 0}, 0.5, {ease: FlxEase.quadOut, onComplete: function(twn:FlxTween)
				{
					whiteTweening = false;
				}});
			}
		}
	}

	override function update(elapsed:Float)
	{
		if (controls.ACCEPT && !thanksOpen)
		{
			HelperFunctions.fancyOpenURL(credits[curIcon][4]);
		}

		if ((controls.BACK || (FlxG.mouse.justPressedRight && Main.focused)) && allowTransit)
		{
			backOut();
		}

		if (FlxG.keys.justPressed.TAB)
		{
			toggleThanks();
		}

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (gamepad != null)
		{
			if (gamepad.justPressed.Y)
			{
				toggleThanks();
			}
		}

		for (i in 0...credIcons.length)
		{
			var smallIcon:FlxSprite = credIcons[i];

			if ((curIcon == i && FlxG.mouse.overlaps(credIcons[curIcon])) && !thanksOpen)
			{
				smallIcon.alpha = 1.0;
				if (FlxG.mouse.justReleased)
				{
					FlxG.openURL(credits[curIcon][4]);
				}
			}
			else
			{
				smallIcon.alpha = 0.5;
			}
		}

		selctionHighlighter.x = FlxMath.lerp(selctionHighlighter.x, selXLerp, 0.25);
		selctionHighlighter.y = FlxMath.lerp(selctionHighlighter.y, selYLerp, 0.25);

		super.update(elapsed);
	}

	function updateSelection(sel:Int)
	{
		var smallIcon:FlxSprite = credIcons[sel];

		selXLerp = smallIcon.x - 14;
		selYLerp = smallIcon.y - 14;
		selctionHighlighter.visible = true;

		smallIcon.alpha = 1.0;

		credLargeName.text = credits[sel][0];
		credQuoteText.text = credits[sel][1];

		quoteBack.visible = true;
		if (credQuoteText.text == " ")
		{
			quoteBack.visible = false;
		}

		switch (credits[sel][2])
		{
			case 'Leader':
				bg.loadGraphic(bgAssets[0], false, bg.frameWidth, bg.frameHeight, true);
				credRoleText.color = FlxColor.fromRGB(178, 84, 255);
				credRoleText.text = 'Leader';
			case 'Artist':
				bg.loadGraphic(bgAssets[4], false, bg.frameWidth, bg.frameHeight, true);
				credRoleText.color = FlxColor.fromRGB(255, 218, 82);
				credRoleText.text = 'Artist';
			case 'Animator':
				bg.loadGraphic(bgAssets[4], false, bg.frameWidth, bg.frameHeight, true);
				credRoleText.color = FlxColor.fromRGB(255, 218, 82);
				credRoleText.text = 'Animator';
			case 'Charter':
				bg.loadGraphic(bgAssets[3], false, bg.frameWidth, bg.frameHeight, true);
				credRoleText.color = FlxColor.fromRGB(82, 255, 151);
				credRoleText.text = 'Charter';
			case 'Developer':
				bg.loadGraphic(bgAssets[1], false, bg.frameWidth, bg.frameHeight, true);
				credRoleText.color = FlxColor.fromRGB(255, 92, 82);
				credRoleText.text = 'Developer';
			case 'Musician':
				bg.loadGraphic(bgAssets[2], false, bg.frameWidth, bg.frameHeight, true);
				credRoleText.color = FlxColor.fromRGB(82, 119, 255);
				credRoleText.text = 'Musician';
		}

		switch (credits[sel][0])
		{
			case 'Proxy':
				credLargeName.setFormat(Paths.font("Comic Sans MS.ttf"), 64, FlxColor.WHITE);
				credQuoteText.setFormat(Paths.font("Comic Sans MS.ttf"), 28, FlxColor.WHITE);
				credRoleText.font = Paths.font("Comic Sans MS.ttf");
				credLargeName.text = 'PolyProxy';
				credRoleText.offset.x = 5; // wtf i hate offsets
				credLargeName.offset.y = 10; // wtf i hate offsets
			case 'River':
				credLargeName.text = 'RiverOaken';
			case 'Gedehari':
				credLargeName.text = 'Sqirra-RNG';
			default:
				credRoleText.offset.x = 0;
				credLargeName.offset.x = 0;
				credLargeName.setFormat(Paths.font("Bronx.otf"), 64, FlxColor.WHITE);
				credQuoteText.setFormat(Paths.font("Bronx.otf"), 28, FlxColor.WHITE);
				credRoleText.font = Paths.font("Bronx.otf");
				credRoleText.offset.x = 0;
				credLargeName.offset.y = 0;
		}

		credQuoteText.y = 580;

		switch (credits[sel][3]) // no text heights on flxsprite bc its automatic? :C
		{
			case '1':
				credQuoteText.y -= (12 * 1);
			case '2':
				credQuoteText.y -= (12 * 2);
			case '3':
				credQuoteText.y -= (12 * 3);
		}

		bigIcon.loadGraphic(bigIconsAssets[sel], false, bigIcon.frameWidth, bigIcon.frameHeight, true);
	}
}
