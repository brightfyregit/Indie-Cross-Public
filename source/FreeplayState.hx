package;

import offsetMenus.IconOffsets;
import GameJolt.GameJoltInfo;
import Shaders.FXHandler;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxMath;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;
import openfl.events.Event;
import openfl.filters.BitmapFilter;
import openfl.media.Sound;
import openfl.media.SoundChannel;
import openfl.media.SoundTransform;
import openfl.utils.Assets;
import sys.thread.Thread;
import flixel.input.keyboard.FlxKey;

using StringTools;

#if cpp
import Discord.DiscordClient;
#end

class FreeplayState extends MusicBeatState
{
	var songs:Array<SongMetadata> = [];

	var selector:FlxText;

	static var curSelected:Array<Int> = [0, 0, 0];
	static var curDifficulty:Int = 1;

	public static var curMechDifficulty:Int = 1;

	var scoreText:FlxText;
	var comboText:FlxText;
	var diffText:FlxText;
	var lerpScore:Int = 0;

	var scoreMultiplier:Float = 1.25 - (0.25 * curMechDifficulty); // should be 0.75 if the mechanics are off !

	var mechDiffText:FlxText;
	var mechDiffMult:FlxText;
	var mechDiffBG:FlxSprite;
	var mechDiffTextinfo:FlxText;

	static var intendedScore:Int = 0;
	static var combo:String = '';

	private var grpSongs:FlxTypedGroup<Alphabet>;
	var curPlaying:Bool = false;

	private var camGame:FlxCamera;

	public var camHUD:FlxCamera;

	private var iconArray:Array<HealthIcon> = [];

	public static var bpm:Float = 102;

	var defaultZoom:Float = 1;

	var filters:Array<BitmapFilter> = [];

	var lockDiff:Bool = false;

	var camZoom:FlxTween;

	public static var freeplayType = 0;

	var playingEasyInst:Bool = false;

	var jbugWatermark:FlxSprite;

	public static var fromWeek:Int = -1;

	var cupTea:FlxSprite;

	var allowTransit:Bool = false;

	private var music:MikuSoundSystem;
	var waitshit:FlxTimer = new FlxTimer();

	var alert:FlxSprite;

	override function create()
	{
		super.create();

		persistentUpdate = true;

		FlxG.mouse.visible = true;

		songs = [];

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		if (FlxG.save.data.givenCode || MainMenuState.debugTools) secretCodes.insert(2, 'saness');

		switch (freeplayType)
		{
			case 0:
				{
					if (FlxG.save.data.weeksbeat[0])
					{
						songs.push(new SongMetadata('Snake-Eyes', 0, 'cuphead'));
						songs.push(new SongMetadata('Technicolor-Tussle', 0, 'cuphead'));
						songs.push(new SongMetadata('Knockout', 0, 'angrycuphead'));
					}

					if (FlxG.save.data.weeksbeat[1])
					{
						songs.push(new SongMetadata('Whoopee', 1, 'sans'));
						songs.push(new SongMetadata('Sansational', 1, 'sans'));

						if (FlxG.save.data.hasgenocided)
						{
							songs.push(new SongMetadata('Burning-In-Hell', 1, 'sansScared'));
						}

						if (FlxG.save.data.haspacifisted)
						{
							songs.push(new SongMetadata('Final-Stretch', 1, 'sans'));
						}
					}

					if (FlxG.save.data.weeksbeat[2])
					{
						songs.push(new SongMetadata('Imminent-Demise', 2, 'bendyDA'));
						songs.push(new SongMetadata('Terrible-Sin', 2, 'bendy'));
						songs.push(new SongMetadata('Last-Reel', 2, 'bendy'));
						songs.push(new SongMetadata('Nightmare-Run', 2, 'bendy'));
					}
				}
			case 1:
				{
					if (FlxG.save.data.weeksbeat[0] || MainMenuState.debugTools)
					{
						songs.push(new SongMetadata('Satanic-Funkin', 0, 'devilFull'));
						trace('adding satan');
					}

					if (FlxG.save.data.weeksbeat[1] || MainMenuState.debugTools)
					{
						if (FlxG.save.data.hasgenocided || MainMenuState.debugTools)
						{
							songs.push(new SongMetadata('Bad-To-The-Bone', 1, 'papyrus'));
						}
						if (FlxG.save.data.haspacifisted || MainMenuState.debugTools)
						{
							songs.push(new SongMetadata('Bonedoggle', 1, 'papyrusandsans'));
						}
					}

					if (FlxG.save.data.weeksbeat[2] || MainMenuState.debugTools)
					{
						songs.push(new SongMetadata('Ritual', 2, 'sammy'));
						songs.push(new SongMetadata('Freaky-Machine', 2, 'bendyDA'));
					}

					trace("weeks beat: " + FlxG.save.data.weeksbeat);
				}
			case 2:
				{
					if ((FlxG.save.data.weeksbeatonhard[0] && FlxG.save.data.shownalerts[0]) || MainMenuState.debugTools)
					{
						songs.push(new SongMetadata('Devils-Gambit', 0, 'cupheadNightmare'));
					}

					if ((FlxG.save.data.weeksbeatonhard[1] && FlxG.save.data.shownalerts[1]) || MainMenuState.debugTools)
					{
						songs.push(new SongMetadata('Bad-Time', 1, 'sansNightmare'));
					}

					if ((FlxG.save.data.weeksbeatonhard[2] && FlxG.save.data.shownalerts[2]) || MainMenuState.debugTools)
					{
						songs.push(new SongMetadata('Despair', 2, 'bendyNightmare'));
					}

					trace("weeks beat on hard: " + FlxG.save.data.weeksbeatonhard);
					trace("cup secret: " + FlxG.save.data.secretChars[5]);
					trace("sans secret: " + FlxG.save.data.secretChars[6]);
					trace("bendy secret: " + FlxG.save.data.secretChars[7]);
				}
		}

		trace(songs);

		music = new MikuSoundSystem();
		music.changeVolume(FlxG.sound.volume);
		FlxG.sound.volumeHandler = onVChange;

		FlxG.game.filtersEnabled = true;
		filters.push(chromaticAberration);
		FXHandler.UpdateColors(filters);
		FlxG.game.setFilters(filters);

		camGame = new FlxCamera();
		camHUD = new FlxCamera();

		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD, false);

		// FlxCamera.defaultCameras = [camGame];
		FlxG.cameras.setDefaultDrawTarget(camGame, true);
		// proxy can you like fucking not please? this shit doesnt work fam -- UPDATE YOUR FLIXEL LIB IFUYBOFEIU CVWIC

		// LOAD MUSIC

		// LOAD CHARACTERS

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menu/BG', 'preload'));
		//bg.setGraphicSize(Std.int(bg.width * 0.675));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = FlxG.save.data.highquality;
		add(bg);

		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		for (i in 0...songs.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, songs[i].songName, true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpSongs.add(songText);

			var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
			icon.sprTracker = songText;

			iconArray.push(icon);
			add(icon);
		}

		scoreText = new FlxText(FlxG.width * 0.685, 5, 0, "", 32);
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);
		scoreText.font = HelperFunctions.returnMenuFont(scoreText);
		// scoreText.alignment = RIGHT;

		var scoreBG:FlxSprite = new FlxSprite(scoreText.x - 6, 0).makeGraphic(Std.int(FlxG.width * 0.35), 66, 0xFF000000);
		scoreBG.alpha = 0.6;
		add(scoreBG);

		diffText = new FlxText(scoreText.x, scoreText.y + 25, 0, "", 24);
		diffText.font = HelperFunctions.returnMenuFont(diffText);
		add(diffText);

		comboText = new FlxText(diffText.x + 160, diffText.y - 5, 0, "", 24);
		comboText.font = HelperFunctions.returnMenuFont(comboText);
		add(comboText);

		add(scoreText);

		mechDiffBG = new FlxSprite(871, 78).makeGraphic(409, 63, 0xFF000000);
		mechDiffBG.alpha = 0.6;
		add(mechDiffBG);

		mechDiffTextinfo = new FlxText(scoreText.x, 80, 0, "Mechanic Difficulty", 24);
		mechDiffTextinfo.alignment = LEFT;
		mechDiffTextinfo.font = HelperFunctions.returnMenuFont(mechDiffTextinfo);
		add(mechDiffTextinfo);

		mechDiffText = new FlxText(scoreText.x,mechDiffTextinfo.y + mechDiffTextinfo.height + 2, 0, "Hard", 24);
		mechDiffText.alignment = LEFT;
		mechDiffText.font = HelperFunctions.returnMenuFont(mechDiffText);
		add(mechDiffText);

		mechDiffMult = new FlxText(scoreText.x + 150, mechDiffTextinfo.y + mechDiffTextinfo.height + 2, 0, "Multiplier: ", 24);
		mechDiffMult.alignment = LEFT;
		mechDiffMult.font = HelperFunctions.returnMenuFont(mechDiffMult);
		add(mechDiffMult);

		selector = new FlxText();

		selector.size = 40;
		selector.text = ">";
		// add(selector);

		jbugWatermark = new FlxSprite().loadGraphic(Paths.image('bonusSongs/J-BugWatermark', 'shared'));
		jbugWatermark.x = 930;
		jbugWatermark.y = 500;
		jbugWatermark.antialiasing = FlxG.save.data.highquality;
		jbugWatermark.setGraphicSize(Std.int(jbugWatermark.width * 0.6));
		jbugWatermark.scrollFactor.set();
		jbugWatermark.alpha = 0;
		add(jbugWatermark);

		changeSelection();
		changeDiff();
		changeMechDiff();
		checkCustom();

		camZoom = FlxTween.tween(this, {}, 0);

		scoreText.cameras = [camHUD];
		scoreBG.cameras = [camHUD];
		diffText.cameras = [camHUD];
		comboText.cameras = [camHUD];
		jbugWatermark.cameras = [camHUD];

		mechDiffBG.cameras = [camHUD];
		mechDiffText.cameras = [camHUD];
		mechDiffMult.cameras = [camHUD];
		mechDiffTextinfo.cameras = [camHUD];

		cupTea = new FlxSprite();
		cupTea.frames = Paths.getSparrowAtlas('the_thing2.0', 'cup');
		cupTea.animation.addByPrefix('start', "BOO instance 1", 24, false);
		cupTea.setGraphicSize(Std.int((FlxG.width / FlxG.camera.zoom) * 1.1), Std.int((FlxG.height / FlxG.camera.zoom) * 1.1));
		cupTea.updateHitbox();
		cupTea.screenCenter();
		cupTea.antialiasing = FlxG.save.data.highquality;
		cupTea.scrollFactor.set();
		cupTea.cameras = [camHUD];
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

		alert = new FlxSprite();
		
		trace('alerts shown: ' + FlxG.save.data.shownalerts);
		if (!FlxG.save.data.secretChars[0] && !FlxG.save.data.shownalerts[0]) //cuphead bonus
		{
			showing = true;
			alert.loadGraphic(Paths.image('cupalert', 'preload'));
			FlxG.save.data.shownalerts[0] = true;
		}
		if (!FlxG.save.data.secretChars[1] && !FlxG.save.data.secretChars[2] && !FlxG.save.data.shownalerts[1]) //sans bonus
		{
			showing = true;
			alert.loadGraphic(Paths.image('sansalert', 'preload'));
			FlxG.save.data.shownalerts[1] = true;
		}
		if (!FlxG.save.data.secretChars[3] && !FlxG.save.data.secretChars[4] && !FlxG.save.data.shownalerts[2]) //bendy bonus
		{
			showing = true;
			alert.loadGraphic(Paths.image('bendyalert', 'preload'));
			FlxG.save.data.shownalerts[2] = true;
		}

		if (showing)
		{
			music.stop();
			waitshit.cancel();
			//alert.setGraphicSize(Std.int((FlxG.width / FlxG.camera.zoom) * 1.1), Std.int((FlxG.height / FlxG.camera.zoom) * 1.1));
			alert.updateHitbox();
			alert.screenCenter();
			alert.antialiasing = FlxG.save.data.highquality;
			alert.scrollFactor.set();
			alert.cameras = [camHUD];
			add(alert);

			FlxG.save.data.freeplaylocked[2] = false;

			accepted = true;
		}
	}

	var showing:Bool = false;
	var accepted:Bool = false;

	public function addSong(songName:String, weekNum:Int, songCharacter:String)
	{
		songs.push(new SongMetadata(songName, weekNum, songCharacter));
	}

	public function addWeek(songs:Array<String>, weekNum:Int, ?songCharacters:Array<String>)
	{
		if (songCharacters == null)
			songCharacters = ['dad'];

		var num:Int = 0;
		for (song in songs)
		{
			addSong(song, weekNum, songCharacters[num]);

			if (songCharacters.length != 1)
				num++;
		}
	}

	var selectedSomthin:Bool = false;

	var chromVal:Float = 0;

	var secretCodes:Array<String> = ['gose',  'devilmayquake'];
	var songNames:Array<Array<String>> = [['gose', 'gose'], ['Fuel', 'face'], ['Saness', 'saness']];
	var allowedKeys:String = 'abcdefghijklmnopqrstuvwxyzzeroonetwothreefourfivesixseveneightnine';
	var codeBuffer:String = '';

	var curGose:String = '';
	var curSaness:String = '';
	var curDMQ:String = '';

	var waitTime:Float = 0.4;

	function codeStringFormat(str:String):String {
		var numArray:Array<String> = ['ZERO', 'ONE', 'TWO', 'THREE', 'FOUR', 'FIVE', 'SIX', 'SEVEN', 'EIGHT', 'NINE'];
		if (numArray.contains(str))
			return Std.string(numArray.indexOf(str));
		return str;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		setChrome(chromVal);

		if (music.channel != null)
			Conductor.songPosition = music.channel.position;

		if (FlxG.keys.justPressed.Q && MainMenuState.debugTools)
			{
				music.stop();
				waitshit.cancel();
				showing = true;
				alert.loadGraphic(Paths.image('cupalert', 'preload'));
				alert.color = FlxColor.BLACK;
				FlxTween.color(alert, 0.75, FlxColor.BLACK, FlxColor.WHITE, {ease: FlxEase.quadOut});
				alert.setGraphicSize(Std.int((FlxG.width / FlxG.camera.zoom) * 1), Std.int((FlxG.height / FlxG.camera.zoom) * 1));
				alert.updateHitbox();
				alert.screenCenter();
				alert.antialiasing = FlxG.save.data.highquality;
				alert.scrollFactor.set();
				alert.cameras = [camHUD];
				add(alert);
	
				FlxG.save.data.freeplaylocked[2] = false;
	
				accepted = true;
			}

		/*
			if (leInst != null)
				Conductor.songPosition = leInst.getPosition();
		 */

		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, 0.4));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;

		scoreText.text = "PERSONAL BEST: " + lerpScore;
		comboText.text = combo + '\n';

		if (showing)
		{
			if (controls.ACCEPT || controls.BACK)
			{
				FlxG.sound.play(Paths.sound('confirmMenu', 'preload'));
				showing = false;
				FlxTween.tween(alert, {alpha: 0}, 1, {
					onComplete: function(twn:FlxTween)
					{
						accepted = false;
						music.loadSound(Paths.inst(songs[curSelected[freeplayType]].songName), false);
						music.play();
					}
				});
			}
		}

		if (!accepted) // THE NEW SECRET SONG CODE SYSTEM, JUST A BIT MORE MODULAR
		{
			if (FlxG.keys.firstJustPressed() != FlxKey.NONE) {
				var keyPressed:FlxKey = FlxG.keys.firstJustPressed();
				var keyName:String = Std.string(keyPressed);
				if (allowedKeys.contains(keyName.toLowerCase())) {
					codeBuffer += codeStringFormat(keyName);
					if (codeBuffer.length > 32) {
						FlxG.sound.play(Paths.sound('delete', 'preload'));
						codeBuffer = '';
					}
					for (wordRaw in secretCodes) {
						var word:String = wordRaw.toUpperCase(); // idk just incase
						if (word.contains(codeBuffer) && codeBuffer.length > 0)
							{
								FlxG.sound.play(Paths.sound('type', 'preload'), 1.5);
								trace('current code: ' + codeBuffer + ', word chosen: ' + word);
							}

						if (codeBuffer.contains(word)) {
							codeAccepted(word); // IT WORKS!!! ✅
						}
					}
					
					for (word in secretCodes) {
						if (!word.toUpperCase().contains(codeBuffer.substring(0, codeBuffer.length - 1)) || word.toUpperCase().contains(codeBuffer))
							break;
						if (codeBuffer.length > 1) {
							trace(word);
							FlxG.sound.play(Paths.sound('delete', 'preload'), 2);
							codeBuffer = '';
						}
					}
				}
			}
		}

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (gamepad != null)
		{
			if (gamepad.justPressed.A)
			{
				accept();
			}
			if (gamepad.justPressed.DPAD_UP)
			{
				changeSelection(-1);
			}
			if (gamepad.justPressed.DPAD_DOWN)
			{
				changeSelection(1);
			}
			if (!lockDiff)
			{
				if (gamepad.justPressed.DPAD_LEFT)
				{
					changeDiff(-1);
				}
				if (gamepad.justPressed.DPAD_RIGHT)
				{
					changeDiff(1);
				}
			}
		}

		if (FlxG.keys.justPressed.UP)
		{
			changeSelection(-1);
		}
		if (FlxG.keys.justPressed.DOWN)
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

		if (FlxG.keys.justPressed.I && FlxG.keys.pressed.CONTROL && MainMenuState.debugTools)
		{
			Main.switchState(new IconOffsets(songs[curSelected[freeplayType]].songCharacter));
		}

		if (!lockDiff)
		{
			if (FlxG.keys.pressed.SHIFT) //change mech diff
				{
					if (FlxG.keys.justPressed.LEFT)
						changeMechDiff(1);
					if (FlxG.keys.justPressed.RIGHT)
						changeMechDiff(-1);
				}
			else //change chart diff
				{
					if (FlxG.keys.justPressed.LEFT)
						changeDiff(-1);
					if (FlxG.keys.justPressed.RIGHT)
						changeDiff(1);
				}
		}
		else
			{
				if (FlxG.keys.pressed.SHIFT) //change mech diff
					{
						if (FlxG.keys.justPressed.LEFT)
							changeMechDiff(1);
						if (FlxG.keys.justPressed.RIGHT)
							changeMechDiff(-1);
					}
			}

		if ((controls.BACK || (FlxG.mouse.justPressedRight && Main.focused)) && allowTransit)
		{
			backOut();
		}

		// gotsong doesnt work poly, dont use it lmao
		if ((FlxG.keys.justPressed.ENTER || FlxG.keys.justPressed.Z) || (FlxG.mouse.justPressed && Main.focused))
		{
			accept();
		}
	}

	function codeAccepted(code:String) {
		if (code == '999414666') if (!FlxG.save.data.givenCode || !MainMenuState.debugTools) return;
		achievementCheck(code);

		var suffix:String = '';

		if (code == 'gose')
		{
			if (Achievements.gotAll() || MainMenuState.debugTools) 
			{
				persistentUpdate = false;
				openSubState(new Prompt("Would you like to play classic GOSE?"));
				Prompt.acceptThing = function()
				{
					suffix = '-classic';
				}
				Prompt.backThing = function() {	}
			}
		}

		persistentUpdate = true;
		FlxG.sound.play(Paths.sound('confirmMenu', 'preload'));
		accepted = true;
		Application.current.window.title = Main.appTitle;

		music.stop();
		waitshit.cancel();

		FlxTween.tween(camHUD, {alpha: 0}, 0.5);
		FlxTween.tween(FlxG.camera, {alpha: 0}, 1);

		var songName:String = songNames[secretCodes.indexOf(code.toLowerCase())][0].toLowerCase();

		for (i in 0...grpSongs.members.length)
		{
			if (i == curSelected[freeplayType])
			{
				remove(iconArray[i]);
				grpSongs.members[i].changeText(songName);
				iconArray[i] = new HealthIcon(songNames[secretCodes.indexOf(code.toLowerCase())][1]);
				iconArray[i].sprTracker = grpSongs.members[i];
				iconArray[i].yOffset = 20;
				add(iconArray[i]);
				FlxFlicker.flicker(grpSongs.members[i], 1, 0.06, false, false);
				FlxFlicker.flicker(iconArray[i], 1, 0.06, false, false);
			}
			else
			{
				FlxTween.tween(grpSongs.members[i], {alpha: 0.0}, 0.4, {ease: FlxEase.quadIn});
				FlxTween.tween(iconArray[i], {alpha: 0.0}, 0.4, {ease: FlxEase.quadIn});
			}
		}

		StoryMenuState.leftDuringWeek = false;

		// wait 0.1 secs since writing files to disk takes its time
		new FlxTimer().start(0.5, function(tmr:FlxTimer)
		{
			StoryMenuState.leftDuringWeek = false;

			HelperFunctions.checkExistingChart(songName + suffix, Highscore.formatSong(songName + suffix, 2));
			PlayState.isStoryMode = false;
			PlayState.storyDifficulty = 2;
			PlayState.storyWeek = -1;
			PlayState.mechanicType = curMechDifficulty;

			PlayState.playCutscene = false;
			PlayState.storyIndex = 0;

			LoadingState.target = new PlayState();
			LoadingState.stopMusic = true;

			Main.switchState(new LoadingState());
		});
	}

	function achievementCheck(code:String) {
		switch (code) {
			case 'gose':
				pushToAchievementIDS("Gose?", false);
			case '999414666':
				pushToAchievementIDS("Saness", false);
			case 'devilmayquake':
				// pushToAchievementIDS("BloodIsFuel", false); // <--- DO NOT USE THIS ONE !!!!
		}
	}

	function backOut()
	{
		if (!accepted)
		{
			accepted = true;

			music.stop();
			waitshit.cancel();

			Application.current.window.title = Main.appTitle;

			FlxG.sound.play(Paths.sound('cancelMenu'));

			FlxTween.tween(camHUD, {alpha: 0}, 0.5);

			FlxG.camera.fade(FlxColor.BLACK, 0.5, false);

			new FlxTimer().start(0.5, function(tmr:FlxTimer)
			{
				Main.switchState(new FreeplaySelect());
			});
		}
	}

	function accept()
	{
		if (!accepted)
		{
			accepted = true;

			Application.current.window.title = Main.appTitle;

			music.stop();
			waitshit.cancel();

			var waitDuration:Float = 1;

			if (iconArray[curSelected[freeplayType]].character.contains('cup')
				|| iconArray[curSelected[freeplayType]].character.contains('devil'))
			{
				FNFState.disableNextTransOut = true;
				waitDuration = 1.1;
				cupTea.alpha = 1;
				cupTea.animation.play('start', true, true);
				FlxG.sound.play(Paths.sound('boing', 'cup'), 1);
			}
			else
			{
				FlxG.sound.play(Paths.sound('confirmMenu'));

				for (i in 0...grpSongs.members.length)
				{
					if (i == curSelected[freeplayType])
					{
						FlxFlicker.flicker(grpSongs.members[i], 1, 0.06, false, false);
						FlxFlicker.flicker(iconArray[i], 1, 0.06, false, false);
					}
					else
					{
						FlxTween.tween(grpSongs.members[i], {alpha: 0.0}, 0.4, {ease: FlxEase.quadIn});
						FlxTween.tween(iconArray[i], {alpha: 0.0}, 0.4, {ease: FlxEase.quadIn});
					}
				}
			}

			var poop:String = Highscore.formatSong(songs[curSelected[freeplayType]].songName, curDifficulty);
			trace(poop);

			if (songs[curSelected[freeplayType]].songName.toLowerCase() == 'devils-gambit') FNFState.disableNextTransOut = true;

			HelperFunctions.checkExistingChart(songs[curSelected[freeplayType]].songName, poop);

			StoryMenuState.leftDuringWeek = false;

			PlayState.isStoryMode = false;
			PlayState.storyDifficulty = curDifficulty;
			PlayState.difficulty = curDifficulty;
			PlayState.storyWeek = songs[curSelected[freeplayType]].week;
			PlayState.mechanicType = curMechDifficulty;

			PlayState.geno = false;

			trace('CUR WEEK' + PlayState.storyWeek);
			LoadingState.target = new PlayState();
			LoadingState.stopMusic = true;
			
			PlayState.playCutscene = false;
			StoryMenuState.leftDuringWeek = false;

			new FlxTimer().start(waitDuration, function(tmr:FlxTimer)
			{
				Main.switchState(new LoadingState());
			});
		}
	}

	function changeDiff(change:Int = 0, ?customName:String = '')
	{
		if (!accepted)
		{
			if (customName != '')
			{
				curDifficulty = change;
			}
			else
			{
				curDifficulty += change;

				if (curDifficulty < 0)
					curDifficulty = 2;
				if (curDifficulty > 2)
					curDifficulty = 0;
			}

			// adjusting the highscore song name to be compatible (changeDiff)
			var songHighscore = StringTools.replace(songs[curSelected[freeplayType]].songName, " ", "-");

			intendedScore = Highscore.getScore(songHighscore, curDifficulty);
			combo = Highscore.getCombo(songHighscore, curDifficulty);

			if (customName != '')
			{
				diffText.text = customName.toUpperCase();
			}
			else
			{
				diffText.text = HelperFunctions.difficultyFromInt(curDifficulty).toUpperCase();
			}

			if (songs[curSelected[freeplayType]].songName.toLowerCase() == 'last-reel')
			{
				if (curDifficulty == 0 && !playingEasyInst)
				{
					gotSong = false;
					music.stop();

					playingEasyInst = true;

					waitshit.cancel();
					waitshit.start(waitTime, function(tmr:FlxTimer)
					{
						music.loadSound(Paths.instEasy(songs[curSelected[freeplayType]].songName), false);
						music.play();
					});

					bopOnBeat();
				}
				else if (curDifficulty >= 1 && playingEasyInst)
				{
					gotSong = false;
					music.stop();

					playingEasyInst = false;

					waitshit.cancel();
					waitshit.start(waitTime, function(tmr:FlxTimer)
					{
						music.loadSound(Paths.inst(songs[curSelected[freeplayType]].songName), false);
						music.play();
					});

					bopOnBeat();
				}
			}
		}
	}

	function changeMechDiff(?change:Int = 0)
	{
		if (!accepted)
		{
			mechDiffBG.visible = true;
			mechDiffTextinfo.visible = true;
			mechDiffText.visible = true;
			mechDiffMult.visible = true;

			curMechDifficulty += change;

			if (freeplayType == 2) //enforce hard and hell only
			{
				if (curMechDifficulty < 0)
					curMechDifficulty = 1;
				if (curMechDifficulty > 1)
					curMechDifficulty = 0;
			}
			else
			{
				if (curMechDifficulty < 0)
					curMechDifficulty = 2;
				if (curMechDifficulty > 2)
					curMechDifficulty = 0;
			}

			if (HelperFunctions.getSongData(songs[curSelected[freeplayType]].songName.toLowerCase(), 'hasmech') == "false")
			{
				mechDiffBG.visible = false;
				mechDiffTextinfo.visible = false;
				mechDiffText.visible = false;
				mechDiffMult.visible = false;
			}

			switch (curMechDifficulty)
			{
				case 0:
					mechDiffText.text = HelperFunctions.mechDifficultyFromInt(0);
					mechDiffText.color = 0xFFC708FE;
				case 1:
					mechDiffText.text = HelperFunctions.mechDifficultyFromInt(1);
					mechDiffText.color = 0xFFFB195F;
				case 2:
					mechDiffText.text = HelperFunctions.mechDifficultyFromInt(2);
					mechDiffText.color = FlxColor.GRAY;
			}
			mechDiffMult.text = "Multiplier: " + (1.25 - (0.25 * curMechDifficulty));
		}
	}	

	var gotSong:Bool = false;

	function changeSelection(change:Int = 0)
	{
		if (!accepted)
		{
			if (songs.length > 1 || change == 0)
			{
				if (change != 0)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
				}
	
				curSelected[freeplayType] += change;
	
				if (curSelected[freeplayType] < 0)
					curSelected[freeplayType] = songs.length - 1;
				if (curSelected[freeplayType] >= songs.length)
					curSelected[freeplayType] = 0;
	
				var songHighscore = StringTools.replace(songs[curSelected[freeplayType]].songName, " ", "-");
	
				if (songs[curSelected[freeplayType]].songName.toLowerCase() == "bad-to-the-bone")
				{
					jbugWatermark.alpha = 1;
				}
				else
				{
					jbugWatermark.alpha = 0;
				}
	
				intendedScore = Highscore.getScore(songHighscore, curDifficulty);
				combo = Highscore.getCombo(songHighscore, curDifficulty);
	
				var poop:String = Highscore.formatSong(songs[curSelected[freeplayType]].songName, curDifficulty);
	
				HelperFunctions.checkExistingChart(songs[curSelected[freeplayType]].songName, poop);
	
				HelperFunctions.getSongData(songs[curSelected[freeplayType]].songName.toLowerCase(), 'bpm');
				var bullShit:Int = 0;
	
				for (i in 0...iconArray.length)
				{
					iconArray[i].alpha = 0.6;
				}
				iconArray[curSelected[freeplayType]].alpha = 1;
	
				for (item in grpSongs.members)
				{
					item.targetY = bullShit - curSelected[freeplayType];
					bullShit++;
	
					item.alpha = 0.6;
	
					if (item.targetY == 0)
					{
						item.alpha = 1;
					}
				}
				var listenin:String = 'Freeplay - Listening to '
					+ HelperFunctions.getSongData(songs[curSelected[freeplayType]].songName.toLowerCase(), "artist")
					+ ' - '
					+ HelperFunctions.getSongData(songs[curSelected[freeplayType]].songName.toLowerCase(), 'name');
				
				Application.current.window.title = Main.appTitle + ' - ' + listenin;

				if (HelperFunctions.shouldBeHidden(songs[curSelected[freeplayType]].songName.toLowerCase()))
					listenin = 'Freeplay - Listening to SOMETHING NEW :)';
					
				DiscordClient.changePresence(listenin, null);
	
				music.stop();
	
				waitshit.cancel();
				waitshit.start(waitTime, function(tmr:FlxTimer)
				{
					music.loadSound(Paths.inst(songs[curSelected[freeplayType]].songName), true);
					music.play();
				});

				checkCustom();
				changeMechDiff();
			}
		}
	}

	function onVChange(volume:Float)
	{
		music.changeVolume(volume);
	}

	override function beatHit()
	{
		super.beatHit();

		if (!accepted)
		{
			bopOnBeat();
		}
	}

	override function stepHit()
	{
		super.stepHit();

		if (songs[curSelected[freeplayType]].songName.toLowerCase() == 'imminent-demise')
		{
			if (curStep == 470)
			{
				remove(iconArray[curSelected[freeplayType]]);
				iconArray[curSelected[freeplayType]] = new HealthIcon("bendy");
				iconArray[curSelected[freeplayType]].sprTracker = grpSongs.members[curSelected[freeplayType]];
				add(iconArray[curSelected[freeplayType]]);
			}
			else if (curStep == 1)
			{
				remove(iconArray[curSelected[freeplayType]]);
				iconArray[curSelected[freeplayType]] = new HealthIcon("bendyDA");
				iconArray[curSelected[freeplayType]].sprTracker = grpSongs.members[curSelected[freeplayType]];
				add(iconArray[curSelected[freeplayType]]);
			}
		}
	}

	function bopOnBeat()
	{
		if (!selectedSomthin)
		{
			FlxG.camera.zoom += 0.015;
			camZoom = FlxTween.tween(FlxG.camera, {zoom: defaultZoom}, 0.1);
			if (songs[curSelected[freeplayType]].songName.toLowerCase() == 'bad-time'
				&& curBeat % 2 == 0
				&& !FlxG.save.data.photosensitive)
			{
				FlxG.camera.shake(0.015, 0.1);
			}

			if (freeplayType == 2 && !FlxG.save.data.photosensitive)
			{
				if (chromVal == 0)
				{
					chromVal = FlxG.random.float(0.03, 0.10);
					FlxTween.tween(this, {chromVal: 0}, FlxG.random.float(0.05, 0.2), {ease: FlxEase.expoOut}); // added easing to it, dunno if it looks better
				}
			}
			else
			{
				FlxTween.tween(this, {chromVal: 0}, FlxG.random.float(0.05, 0.2), {ease: FlxEase.expoOut});
			}
		}
	}

	function checkCustom()
	{
		switch (songs[curSelected[freeplayType]].songName.toLowerCase())
		{
			case 'nightmare-run' | 'final-stretch' | 'burning-in-hell':
				lockDiff = true;
				curDifficulty = 2;
				diffText.color = FlxColor.RED;
				changeDiff();

			case 'bad-time':
				lockDiff = true;
				changeDiff(2, 'genocidal');
				diffText.color = FlxColor.RED;
				comboText.x = diffText.x + 125;
			case 'devils-gambit':
				lockDiff = true;
				changeDiff(2, 'devilish');
				diffText.color = FlxColor.RED;
				comboText.x = diffText.x + 125;
			case 'despair':
				lockDiff = true;
				changeDiff(2, 'demonic');
				diffText.color = FlxColor.RED;
			default:
				lockDiff = false;
				changeDiff();
				diffText.color = FlxColor.WHITE;
				comboText.x = diffText.x + 100;
		}
	}
}

class SongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";

	public function new(song:String, week:Int, songCharacter:String)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
	}
}
