package;

import lime.math.Vector2;
import offsetMenus.AnimationDebug;
import background.BendyBoy;
import Section.SwagSection;
import Shaders.FXHandler;
import Song.SwagSong;
import animateAtlasPlayer.core.Animation;
import background.DevilBitches;
import flash.display.BlendMode;
import flixel.FlxBasic;
using flixel.util.FlxSpriteUtil;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxParticle;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxFramesCollection;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxGradient;
import flixel.util.FlxSort;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxTimer;
import haxe.ValueException;
import lime.app.Application;
import lime.media.AudioContext;
import lime.media.AudioManager;
import lime.media.openal.AL;
import openfl.Lib;
import openfl.events.KeyboardEvent;
import openfl.filters.BitmapFilter;
import openfl.filters.ShaderFilter;
import openfl.media.Sound;
import openfl.ui.KeyLocation;
import openfl.ui.Keyboard;
import openfl.utils.Assets;

using StringTools;

#if desktop
import sys.io.File;
import sys.io.Process;
import sys.thread.Thread;
#end
#if cpp
import Discord.DiscordClient;
import sys.FileSystem;
#end

class PlayState extends MusicBeatState
{
	public static var instance:PlayState = null;

	var bendy:FlxSprite;
	var jumpscareStatic:FlxSprite;
	var blast:FlxSprite;
	var iskinky = false;
	var forcesize = false;
	var bridged = false;
	var ogposes = [];
	var cuptimer:FlxTimer;
	var dietimer:FlxTimer;
	var strikeraddtime=0.0;
	var piperaddtime=0.0;

	var blue = false;
	var sign:FlxSprite;
	var stepsbeforeshoot:Array<Int> = [142, 398, 501, 647, 772, 1598,603, 912,1167];
	var cardbary = 0.0;

	public static var playCutscene:Bool = false;
	// set this to true if bf attacks a singular time lmao
	public static var geno:Bool = false;

	public static var curStage:String = '';
	public static var SONG:SwagSong;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var mechanicType:Int = 1;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;
	public static var difficulty:Int = 1;

	public var shits:Int = 0;
	public var bads:Int = 0;
	public var goods:Int = 0;
	public var sicks:Int = 0;
	public var misses:Int = 0;
 
	var attackCooldown:Int = 0;
	var dodgeCooldown:Int = 0;

	var bfOnRight:Bool = true;
	var bfCanMove:Bool = false;
	var bfMovementOver:Bool = true;

	var songSpeed:Float = 1.0;
	var slow:Bool = false;

	var cutsceneSpr:FlxSprite;

	public var bendyBoyGroup:FlxTypedGroup<BendyBoy>;

	var inkscroll:FlxTypedGroup<FlxSprite>;
	var emitt:FlxTypedGroup<FlxEmitter>;

	public var currentPiper:BendyBoy;
	public var currentStriker:BendyBoy;

	public var bendyForeground:FlxSprite;

	public var attackHud:HudIcon;
	public var dodgeHud:HudIcon;

	var usedTimeTravel:Bool = false;
	var canheal:Bool = true;
	var utmode:Bool = false;
	var battleBoundaries:FlxRect;
	var cangethurt:Bool = true;

	var animName:String = 'normal';

	var camFocus:String = "";
	var camMovement:FlxTween;
	var healthTweenObj:FlxTween;
	var krTweenObj:FlxTween;
	var cardtween:FlxTween;
	var chromVal:Float = 0;
	var specialIntro:Bool = false;

	var piperTween:FlxTween;
	var strikerTween:FlxTween;

	var songPosBG:FlxSprite;
	var songPosBar:FlxBar;
	var songPosBarPreDemise:FlxBar;

	public var visibleCombos:Array<FlxSprite> = [];

	var songLength:Float = 0;
	var songText:FlxText;

	public var devilGroup:FlxTypedGroup<DevilBitches>;

	public var storyDifficultyText:String = "";

	var iconRPC:String = "";
	var detailsText:String = "";
	var detailsPausedText:String = "";

	private var vocals:FlxSound;

	public var originalX:Float;

	public static var dad:Character;
	public static var boyfriend:Boyfriend;
	public static var player3:Character;

	public var notes:FlxTypedGroup<Note>;

	private var unspawnNotes:Array<Note> = [];

	public var strumLine:FlxSprite;

	private var camFollow:FlxObject;

	var cardanims:FlxSprite;

	private static var prevCamFollow:FlxObject;

	public var strumLineNotes:FlxTypedGroup<FlxSprite> = null;
	public var playerStrums:FlxTypedGroup<FlxSprite> = null;
	public var cpuStrums:FlxTypedGroup<FlxSprite> = null;
	public var cpuStrums2:FlxTypedGroup<FlxSprite> = null;
	public static var noteskinSprite:FlxAtlasFrames;

	public var altStrumLineNotes:FlxTypedGroup<FlxSprite> = null;
	public var altPlayerStrums:FlxTypedGroup<FlxSprite> = null;
	public var altCpuStrums:FlxTypedGroup<FlxSprite> = null;

	private var camZooming:Bool = false;
	private var curSong:String = "";

	public var health:Float = 1; // making public because sethealth doesnt work without it

	public var laneunderlay:FlxSprite;
	public var laneunderlayOpponent:FlxSprite;
	public var laneunderlayOpponent2:FlxSprite;

	private var combo:Int = 0;

	public var accuracy:Float = 0.00;

	private var accuracyDefault:Float = 0.00;
	private var totalNotesHit:Float = 0;
	private var totalNotesHitDefault:Float = 0;
	private var totalPlayed:Int = 0;
	private var ss:Bool = false;

	private var healthBarBG:FlxSprite;
	private var healthBar:FlxBar;
	private var healthBarBGOverlay:FlxSprite;
	private var healthMax:FlxSprite;
	private var songPositionBar:Float = 0;

	private var krBar:FlxBar;
	var kr = 0.0;

	var generatedMusic:Bool = false;

	private var startingSong:Bool = false;

	public var iconP1:HealthIcon; // making these public again because i may be stupid
	public var iconP2:HealthIcon; // what could go wrong?
	public var iconP2alt:HealthIcon; // bendys icon kept ending up behind the health bar lol
	public var camHUD:FlxCamera;

	var overrideNMZoom:Bool = false;

	private var camGame:FlxCamera;
	private var camOVERLAY:FlxCamera;
	private var camDialogue:FlxCamera;
	private var camINSTRUCTION:FlxCamera;

	private var camSUBTITLES:FlxCamera;

	public static var offsetTesting:Bool = false;

	var notesHitArray:Array<Date> = [];
	var currentFrames:Int = 0;

	public var dialoguePaused:Bool = false;

	var songName:FlxText;

	var fc:Bool = true;

	var talking:Bool = true;

	public var songScore:Int = 0;

	var speed:Float = 650;
	var blaster:FlxTypedGroup<FlxSprite>;

	var cannotDie:Bool = false; // helps prevent the game locking up when dying while going into charting state, etc.
	var transitioningToState = false; // boogaloo

	var songScoreDef:Int = 0;
	var scoreTxt:FlxText;
	var replayTxt:FlxText;

	var fuckinAngry:Bool = false;

	public static var campaignScore:Int = 0;

	var defaultCamZoom:Float = 1.05;

	var funneEffect:FlxSprite;
	var inCutscene:Bool = false;

	// Will fire once to prevent debug spam messages and broken animations
	private var triggeredAlready:Bool = false;

	// Will decide if she's even allowed to headbang at all depending on the song
	private var allowedToHeadbang:Bool = false;

	// Per song additive offset
	var songOffset:Float = 0;

	// BotPlay text
	private var botPlayState:FlxText;

	private var executeModchart = false;

	var cupheadChaserMode:Bool = false;

	var cupheadPewMode:Bool = false;
	var cupheadPewFX:CupBullet;

	var cardbar:FlxBar;
	var cardfloat:Float = 0;
	var didntdoanimyet:Bool = true;
	var poped:Bool = true;

	var piper:FlxSprite;
	var fisher:FlxSprite;

	// API stuff

	public function addObject(object:FlxBasic)
	{
		add(object);
	}

	public function removeObject(object:FlxBasic)
	{
		remove(object);
	}

	var songLowercase:String;
	var camLerp:Float = 0.4;
	var filters:Array<BitmapFilter> = [];

	// SANS
	var battle:FlxSprite;
	var battleBG:FlxSprite;
	var bg:FlxSprite;
	var battleMode:Bool = false;

	// BENDY
	var inkObj:FlxSprite;
	var inkProg:Int = 0;
	var inkStormRain:FlxSprite;
	var blackOverlay:FlxSprite;
	var stickmanGuy:FlxSprite;
	var blackStickmanThereInBG:FlxSprite;
	var bendyboysfg:FlxSprite;
	var bendyIntroOverlay:FlxSprite;

	var sansCanAttack:Bool = false;

	var p2:FlxColor;

	var bgs:Array<FlxSprite>;
	var transition:FlxSprite;
	// var lights:FlxSprite;
	var darkHallway:FlxSprite;
	var finalStretchBarTop:FlxSprite;
	var finalStretchBarBottom:FlxSprite;
	var finalStretchwhiteBG:FlxSprite;
	var finalStretchWaterFallBG:FlxSprite;

	var transitionLayer:FlxTypedGroup<FlxSprite>;
	var stairsGrp:FlxTypedGroup<FlxSprite>;
	var stairsBG:FlxBackdrop;
	var stairs:FlxSprite;
	var stairsChainL:FlxBackdrop;
	var stairsChainR:FlxBackdrop;
	var stairsGradient:FlxSprite;
	var cutouts:Array<FlxSprite>;
	var nmStairs:Bool = false;
	var canCameraMove:Bool = true;

	var backbg:FlxTypedGroup<FlxSprite>;
	var frontbg:FlxTypedGroup<FlxSprite>;

	var machineCurtainLeft:FlxSprite;
	var machineCurtainRight:FlxSprite;
	var freakyMachineVideoSpr:FlxSprite;

	var lastAnimPlay:Float = 0;

	var infiniteResize:Float = 2.3;

	var randomPick:Int;
	var randomCutout:Int;
	var oldRando:Int;

	var cup:Bool = false;

	var dataSuffix:Array<String> = ['LEFT', 'DOWN', 'UP', 'RIGHT'];

	var dadPos:Array<Float> = [0, 0];
	var bfPos:Array<Float> = [0, 0];
	var player3Pos:Array<Float> = [0, 0];

	var offsetX = 0;
	var offsetY = 0;

	var daFunneOffsetMultiplier:Float = 20;

	var icon2AnimArray:Array<Bool> = [false, false];

	var iconXOffset:Int = 0;
	var iconYOffset:Int = 0;

	public var camZoomTween:FlxTween;

	private var uiZoomTween:FlxTween;

	var gosebg:FlxSprite;

	var nightmareSansBgs:Array<FlxSprite>;

	public static var storyIndex:Int = 1;

	var cutPrefix:String = '';

	var alarm:FlxSprite;
	var bfDodge:FlxSprite;
	// NM Sans
	var alarmbone:FlxSprite;
	var sammyAxe:FlxSprite;
	var mugdead:FlxSprite;
	var mugcanhit:Bool = false;
	var songSprite:FlxSprite;

	var knockoutSpr:FlxSprite;
	var fgRain:FlxSprite;
	var fgRain2:FlxSprite;
	var fgStatic:FlxSprite;
	var fgGrain:FlxSprite;
	var devilIntroSpr:FlxSprite;

	var sans:VideoHandler;
	var sansSprite:FlxSprite;
	var sansTalking:Bool = false;

	var cupBullets:Array<CupBullet> = [];

	var daCanvasSway:Float = 0;

	var speaker:FlxSprite;
	var postDemise:FlxSprite;
	var pillar:FlxSprite;

	var bendo:FlxSprite;

	var origSpeed:Float;

	var flashback:FlxSprite;
	var cupheadPew:CupBullet;
	var canCupheadShoot:Bool = true;
	var pewdmg:Float = 0;
	var pewdmgScale:Float = 1.0;
	var pewhits:Int = 0;
	var ball:Balls; // testicles
	var canaddshaders:Bool = false;

	var sanessBG:FlxSprite;

	var mechInstructions:FlxSprite;
	var mechAnim:FlxSprite;
	var mechPressEnter:FlxText;
	var hasInstruction:Bool = false;
	var videoPlaying:Bool = false;
	var mechInstructMusic:FlxSound;

	var light:FlxSprite;

	public var isBotPlaying:Bool = false;

	var defaultChromVal:Float = 0;

	var despairBG:FlxSprite;
	var fire:FlxSprite;

	public static var inNightmareSong:Bool = false;
	public static var mechanicsEnabled:Bool = true;

	var hasBlackBars:Bool = false;

	var gameVideos:Array<VideoHandler> = [];

	public function new()
	{
		super();
		dumpAddt = false;
	}

	override public function create()
	{
		super.create();
		instance = this;

		generatedMusic = false;

		Application.current.window.onFocusOut.add(onWindowFocusOut);

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		if (PlayState.SONG.song.toLowerCase() == 'bonedoggle')
			Main.dataJump = 12;
		else
			Main.dataJump = 8;

		GameOverSubstate.gameOverChar = 'bf';

		dead = false;

		bfBendoCustomExpression = '';

		camZoomTween = FlxTween.tween(this, {}, 0);
		uiZoomTween = FlxTween.tween(this, {}, 0);

		if (FlxG.save.data.fpsCap > 290)
			(cast(Lib.current.getChildAt(0), Main)).setFPSCap(800);

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		if (!isStoryMode)
		{
			sicks = 0;
			bads = 0;
			shits = 0;
			goods = 0;
		}

		cannotDie = false;

		PlayStateChangeables.useDownscroll = FlxG.save.data.downscroll;
		PlayStateChangeables.safeFrames = FlxG.save.data.frames;
		PlayStateChangeables.botPlay = FlxG.save.data.botplay;

		// pre lowercasing the song name (create)
		songLowercase = StringTools.replace(PlayState.SONG.song, " ", "-").toLowerCase();

		#if cpp
		executeModchart = FileSystem.exists(Paths.lua(songLowercase + "/modchart"));
		#end
		#if !cpp
		executeModchart = false; // FORCE disable for non cpp targets
		#end

		#if cpp
		// Making difficulty text for Discord Rich Presence.
		storyDifficultyText = HelperFunctions.difficultyFromInt(storyDifficulty);

		iconRPC = SONG.player2;

		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		if (isStoryMode)
		{
			detailsText = "Story Mode: Week " + storyWeek;
		}
		else
		{
			detailsText = "Freeplay";
		}

		// String for when the game is paused
		detailsPausedText = "Paused - " + detailsText;

		// Updating Discord Rich Presence.
			var disSong:String = SONG.song;
			if (HelperFunctions.shouldBeHidden(SONG.song.toLowerCase()))
				disSong = '[CONFIDENTIAL]';
		DiscordClient.changePresence(detailsText
			+ " "
			+ disSong
			+ " ("
			+ storyDifficultyText
			+ ") "
			+ Ratings.GenerateLetterRank(accuracy),
			"\nAcc: "
			+ HelperFunctions.truncateFloat(accuracy, 2)
			+ "% | Score: "
			+ songScore
			+ " | Misses: "
			+ misses, iconRPC);
		#end

		FlxG.game.setFilters(filters);

		FlxG.game.filtersEnabled = true;

		camMovement = FlxTween.tween(this, {}, 0);

		healthTweenObj = FlxTween.tween(this, {}, 0);
		krTweenObj = FlxTween.tween(this, {}, 0);

		// var gameCam:FlxCamera = FlxG.camera;
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		camDialogue = new FlxCamera();
		camDialogue.bgColor.alpha = 0;

		camOVERLAY = new FlxCamera();
		camOVERLAY.bgColor.alpha = 0;

		camSUBTITLES = new FlxCamera();
		camSUBTITLES.bgColor.alpha = 0;

		camINSTRUCTION = new FlxCamera();
		camINSTRUCTION.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD, false);
		FlxG.cameras.add(camOVERLAY, false);
		FlxG.cameras.add(camINSTRUCTION, false);
		FlxG.cameras.add(camSUBTITLES, false);
		FlxG.cameras.add(camDialogue, false);

		if (!FlxG.save.data.photosensitive && FlxG.save.data.highquality)
		{
			canaddshaders = true;
			trace('added the fucking shaders AAAAAAAAAAAAAAAA');
		}

		camHUD.alpha = FlxG.save.data.hudalpha;

		// FlxCamera.defaultCameras = [camGame];
		FlxG.cameras.setDefaultDrawTarget(camGame, true);
		// proxy why -- among us

		persistentUpdate = true;
		persistentDraw = true;

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		songScrollSpeed = SONG.speed;

		// defaults if no stage was found in chart
		var stageCheck:String = 'stage';

		stageCheck = SONG.stage;

		fuckinAngry = false;

		if (songLowercase == 'devils-gambit' || songLowercase == 'bad-time' || songLowercase == 'despair')
			inNightmareSong = true;
		else
			inNightmareSong = false;

		trace('mechanic type is ' + mechanicType + " (" + HelperFunctions.mechDifficultyFromInt(mechanicType) + ")");
		mechanicsEnabled = mechanicType < 2;

		if (mechanicType != 0)
		{
			piperaddtime = 6000;
			strikeraddtime = -8000;
		}

		switch (songLowercase)
		{
			case 'snake-eyes' | 'technicolor-tussle' | 'knockout':
				pewdmg = 0.0225;
				chromVal = 0.001;
				defaultChromVal = 0.001;
				stageCheck = 'field';
				if (canaddshaders)
					filters.push(chromaticAberration);
			case 'satanic-funkin' | 'devils-gambit':
				stageCheck = 'devilHall';
				chromVal = 0.001;
				defaultChromVal = 0.001;
				if (songLowercase == 'devils-gambit')
				{
					fuckinAngry = true;
				}
				if (canaddshaders)
					filters.push(chromaticAberration);
			case 'whoopee' | 'sansational' | 'burning-in-hell' | 'final-stretch' | 'bad-time':
				stageCheck = 'hall';
				defaultChromVal = 0;
				if (canaddshaders)
					filters.push(chromaticAberration);
				if (songLowercase == 'bad-time')
				{
					fuckinAngry = true;
				}
				if (songLowercase == 'burning-in-hell')
				{
					defaultChromVal = 0;
					if (canaddshaders)
						filters.push(chromaticAberration);
				}
			case 'bad-to-the-bone' | 'bonedoggle':
				stageCheck = 'papyrus';
			case 'saness':
				stageCheck = 'theVoid';
			case 'imminent-demise' | 'terrible-sin' | 'last-reel' | 'nightmare-run' | 'despair' | 'ritual' | 'freaky-machine':
				stageCheck = 'factory';
				if (songLowercase == 'despair')
				{
					fuckinAngry = true;
					defaultChromVal = 0;

					if (canaddshaders)
						filters.push(chromaticAberration);
				}
			case 'gose' | 'gose-classic':
				stageCheck = 'gose';
		}

		if (isStoryMode)
		{
			switch (storyWeek)
			{
				case 0:
					cutPrefix = 'cuphead';
				case 1:
					cutPrefix = 'sans';
				case 2:
					cutPrefix = 'bendy';
			}
		}

		setChrome(defaultChromVal);
		camGame.setFilters(filters);
		camGame.filtersEnabled = true;

		if (!fuckinAngry && SONG.song.toLowerCase() != 'whoopee')
		{
			camHUD.filtersEnabled = true;
			camHUD.setFilters(filters);
		}
		else
		{
			camHUD.filtersEnabled = false;
		}

		filters.push(brightShader);
		FXHandler.UpdateColors(filters);

		var daDad:String = SONG.player2;
		var daBF:String = SONG.player1;
		var daPlayer3:String = SONG.player3;

		if (SONG.song.toLowerCase() != 'bonedoggle')
		{
			daPlayer3 = 'none';
		}
		else
		{
			daPlayer3 = 'sanswinter';
			daCanvasSway = 0;
		}

		switch (stageCheck)
		{
			case 'hall':
				{
					defaultCamZoom = 0.9;
					curStage = 'hall';

					bg = new FlxSprite();
					if (SONG.song.toLowerCase() == 'burning-in-hell')
					{
						bg.loadGraphic(Paths.image('halldark', 'sans',false));
					}
					else
						bg.loadGraphic(Paths.image('hall', 'sans',false));

					bg.setGraphicSize(Std.int(bg.width * 1.5));
					bg.updateHitbox();
					bg.screenCenter();
					bg.x -= 300;

					if (SONG.song.toLowerCase() == 'burning-in-hell')
					{
						bg.loadGraphic(Paths.image('halldark', 'sans',false));
					}

					bg.antialiasing = FlxG.save.data.highquality;
					bg.scrollFactor.set(1.0, 1.0);
					bg.active = false;

					if (!fuckinAngry)
						add(bg);

					if (SONG.song.toLowerCase() == 'final-stretch')
					{
						finalStretchWaterFallBG = new FlxSprite(0, 0).loadGraphic(Paths.image('Waterfall', 'sans',false));
						finalStretchWaterFallBG.setGraphicSize(Std.int(bg.width * 1.5));
						finalStretchWaterFallBG.updateHitbox();
						finalStretchWaterFallBG.screenCenter();
						finalStretchWaterFallBG.x -= 300;
						finalStretchWaterFallBG.alpha = 0.0001;
						add(finalStretchWaterFallBG);

						finalStretchwhiteBG = new FlxSprite(-640, -640).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.WHITE);
						finalStretchwhiteBG.scrollFactor.set(0, 0);
						finalStretchwhiteBG.cameras = [camGame];
						finalStretchwhiteBG.visible = false;
						add(finalStretchwhiteBG);

						finalStretchBarTop = new FlxSprite(-640, -560).makeGraphic(FlxG.width * 2, 560, FlxColor.BLACK);
						finalStretchBarTop.scrollFactor.set(0, 0);
						finalStretchBarTop.cameras = [camOVERLAY];
						add(finalStretchBarTop);

						finalStretchBarBottom = new FlxSprite(-640, 720).makeGraphic(FlxG.width * 2, 560, FlxColor.BLACK);
						finalStretchBarBottom.scrollFactor.set(0, 0);
						finalStretchBarBottom.cameras = [camOVERLAY];
						add(finalStretchBarBottom);
					}

					if (fuckinAngry)
					{
						nightmareSansBgs = [];

						var beatDropbg:FlxSprite = new FlxSprite(-100, 300);
						var bg:FlxSprite = new FlxSprite(-600, -160);

						bg.frames = Paths.getSparrowAtlas('Nightmare Sans Stage', 'sans');
						bg.animation.addByIndices('normal', 'Normal instance 1', [0], '', 24, false);
						bg.animation.addByPrefix('beatdrop', 'Normal instance 1', 24, true);
						bg.animation.addByPrefix('beatDropFinish', 'sdfs instance 1', 24, false);
						bg.animation.play('normal');
						bg.scrollFactor.set(1, 1);
						bg.antialiasing = FlxG.save.data.highquality;

						add(bg);

						beatDropbg.frames = Paths.getSparrowAtlas('Nightmare Sans Stage', 'sans');
						beatDropbg.animation.addByPrefix('beatHit', 'dd instance 1', 32, false);
						beatDropbg.scrollFactor.set(0, 0);
						beatDropbg.blend = BlendMode.ADD;
						beatDropbg.antialiasing = FlxG.save.data.highquality;
						beatDropbg.alpha = 0;

						nightmareSansBgs.push(bg);
						nightmareSansBgs.push(beatDropbg);

						nightmareSansBGManager('normal');
					}

					if (SONG.song.toLowerCase() == 'sansational' || SONG.song.toLowerCase() == 'burning-in-hell')
					{
						battle = new FlxSprite(-600, -200).loadGraphic(Paths.image('battleUI/battle', 'sans'));
						battle.antialiasing = FlxG.save.data.highquality;
						battle.scrollFactor.set(1, 1);
						battle.alpha = 0.0001;

						battleBG = new FlxSprite(-600, 0).loadGraphic(Paths.image('battleUI/bg', 'sans'));
						battleBG.antialiasing = false;
						battleBG.scrollFactor.set(1, 1);
						battleBG.alpha = 0.0001;
						battleBG.setGraphicSize(Std.int(battle.width));
						battleBG.updateHitbox();

						add(battle);
						add(battleBG);
						battleBoundaries = new FlxRect(battle.x + 220,battle.y + 1239,1516,750);
					}

					switch (SONG.song.toLowerCase())
					{
						case 'burning-in-hell':
							daDad = 'sansScared';
							daBF = 'bfchara';
						case 'bad-time':
							daDad = 'sansNightmare';
							daBF = 'bfSansNightmare';
						default:
							daDad = 'sans';
							daBF = 'bfSans';
					}
				}
			case 'field':
				{
					defaultCamZoom = 0.61;
					curStage = 'field';

					// this was loading 2 bg's lol
					var bg:FlxSprite = new FlxSprite();

					if (SONG.song.toLowerCase() == 'knockout')
						bg.loadGraphic(Paths.image('angry/CH-RN-00', 'cup',false));
					else
						bg.loadGraphic(Paths.image('BG-00', 'cup',false));

					bg.setGraphicSize(Std.int(bg.width * 0.7 * 4));
					bg.updateHitbox();
					bg.screenCenter();
					bg.antialiasing = FlxG.save.data.highquality;
					bg.scrollFactor.set(0.2, 0.2);
					bg.active = false;
					add(bg);

					var trees:FlxSprite = new FlxSprite();

					if (SONG.song.toLowerCase() == 'knockout')
						trees.loadGraphic(Paths.image('angry/CH-RN-01', 'cup',false));
					else
						trees.loadGraphic(Paths.image('BG-01', 'cup',false));

					trees.setGraphicSize(Std.int(trees.width * 0.7 * 4));
					trees.updateHitbox();
					trees.screenCenter();
					trees.x -= 75;
					trees.antialiasing = FlxG.save.data.highquality;
					trees.scrollFactor.set(0.45, 0.45);
					trees.active = false;
					add(trees);

					var fg:FlxSprite = new FlxSprite();

					if (SONG.song.toLowerCase() == 'knockout')
						fg.loadGraphic(Paths.image('angry/CH-RN-02', 'cup',false));
					else
						fg.loadGraphic(Paths.image('Foreground', 'cup',false));

					fg.setGraphicSize(Std.int(fg.width * 0.9 * 4));
					fg.updateHitbox();
					fg.screenCenter();
					fg.x -= 100;
					fg.y -= 200;
					fg.antialiasing = FlxG.save.data.highquality;
					fg.active = false;
					add(fg);

					checkCupheadChrom();

					cup = true;
					specialIntro = true;

					if (SONG.song.toLowerCase() == 'knockout')
					{
						daDad = 'angrycuphead';
						daBF = 'rainbf';
					}
					else
					{
						daBF = 'bfswag';
						daDad = 'cuphead';
					}
				}
			case 'factory':
				{
					curStage = 'factory';

					if (SONG.song.toLowerCase() == 'nightmare-run')
					{
						defaultCamZoom = 0.45;

						bgs = [];
						// Might take a bit longer to load but hey, no black boxes yay
						// also initializing them as characters right away to prevent a weird small freezing when the frame change happens
						// flixel sucks ass

						for (i in 0...5)
						{
							var bg:FlxSprite = new FlxSprite();
							var imgName:String = '';
							var animName:String = '';
							switch (i)
							{
								case 0:
									imgName = 'Fuck_the_hallway';
									animName = 'Loop01 instance 1';
								case 1:
									imgName = 'Fuck_the_hallway';
									animName = 'Loop02 instance 1';
								case 2:
									imgName = 'Fuck_the_hallway';
									animName = 'Loop03 instance 1';
								case 3:
									imgName = 'Fuck_the_hallway';
									animName = 'Loop04 instance 1';
								case 4:
									imgName = 'Fuck_the_hallway';
									animName = 'Loop05 instance 1';
							}

							bg.frames = Paths.getSparrowAtlas('run/' + imgName, 'bendy');
							bg.animation.addByPrefix('bruh', animName, 75, false);
							bg.setGraphicSize(Std.int(bg.width * 3));
							bg.updateHitbox();
							bg.screenCenter();
							bg.scrollFactor.set(0.8, 0.8);
							// bg.x -= 100;
							bg.y -= 50;
							bg.antialiasing = FlxG.save.data.highquality;
							bg.graphic.persist = true;
							bg.graphic.destroyOnNoUse = false;
							bg.alpha = 0.0001;
							add(bg);

							bgs.push(bg);
						}

						randomPick = FlxG.random.int(0, bgs.length - 1);
						oldRando = randomPick;

						darkHallway = new FlxSprite();
						darkHallway.frames = Paths.getSparrowAtlas('run/Fuck_the_hallway', 'bendy');
						darkHallway.animation.addByPrefix('bruh', 'Tunnel instance 1', 75, false);
						darkHallway.setGraphicSize(Std.int(darkHallway.width * infiniteResize));
						darkHallway.updateHitbox();
						darkHallway.screenCenter();
						darkHallway.x -= 200;
						darkHallway.scrollFactor.set(0.8, 0.8);
						darkHallway.antialiasing = FlxG.save.data.highquality;
						darkHallway.alpha = 0.0001;
						add(darkHallway);

						bgs[randomPick].alpha = 1;
						bgs[randomPick].animation.play('bruh', true);

						darkHallway.animation.play('bruh', true);

						daBF = 'bfChase';
						daDad = 'bendyChase';
					}
					else
					{
						if (fuckinAngry)
						{
							defaultCamZoom = 0.65;

							despairBG = new FlxSprite(0, 0).loadGraphic(Paths.image('inky depths', 'bendy',false));
							despairBG.setGraphicSize(Std.int(despairBG.width * 2));
							despairBG.updateHitbox();
							despairBG.screenCenter();
							despairBG.antialiasing = FlxG.save.data.highquality;
							despairBG.scrollFactor.set(0.6, 0.6);
							despairBG.x -= 220;
							despairBG.y += 200;
							despairBG.alpha = 0.0001;
							add(despairBG);

							fire = new FlxSprite(0, 0);
							fire.frames = Paths.getSparrowAtlas('Fyre', 'bendy');
							fire.animation.addByPrefix('fire', 'Penis instance 1', 24, true);
							fire.setGraphicSize(Std.int(fire.width * 2.3));
							fire.updateHitbox();
							fire.screenCenter();
							fire.y = 760;
							fire.antialiasing = FlxG.save.data.highquality;
							fire.scrollFactor.set(0.8, 0.8);
							add(fire);

							var bg2:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('nightmareBendy_foreground', 'bendy',false));
							bg2.setGraphicSize(Std.int(despairBG.width * 1.4));
							bg2.updateHitbox();
							bg2.screenCenter();
							bg2.y += 450;
							bg2.antialiasing = FlxG.save.data.highquality;
							bg2.scrollFactor.set(0.91, 0.91);
							add(bg2);

							daBF = 'bfNightmareBendynew';
							daDad = 'bendyNightmare';
						}
						else
						{
							if (SONG.song.toLowerCase() == 'ritual')
							{
								defaultCamZoom = 0.375;

								var bg:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('SammyS', 'bendy',false));
								bg.updateHitbox();
								bg.screenCenter();
								// bg.y -= 200;
								bg.antialiasing = FlxG.save.data.highquality;
								bg.scrollFactor.set(0.8, 0.8);
								add(bg);

								specialIntro = true;

								daBF = 'bfSammy';
								daDad = 'sammy';

								bfBendoCustomExpression = 'A';
							}
							else if (SONG.song.toLowerCase() == 'imminent-demise')
							{
								defaultCamZoom = 0.55;

								var bg:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('first/BG01', 'bendy',false));
								bg.updateHitbox();
								bg.screenCenter();
								bg.antialiasing = FlxG.save.data.highquality;
								bg.scrollFactor.set(0.9, 0.9);
								bg.x -= 300;
								add(bg);

								speaker = new FlxSprite(0, 0);
								speaker.frames = Paths.getSparrowAtlas('first/MusicBox', 'bendy');
								speaker.animation.addByPrefix('bump', 'Music box thingy instance 1', 24, false);
								speaker.updateHitbox();
								speaker.screenCenter();
								speaker.x -= 400;
								speaker.y += 80;
								speaker.antialiasing = FlxG.save.data.highquality;
								speaker.scrollFactor.set(0.95, 0.95);
								add(speaker);

								bendo = new FlxSprite(0, 0).loadGraphic(Paths.image('first/Boi', 'bendy'));
								bendo.updateHitbox();
								bendo.screenCenter();
								bendo.antialiasing = FlxG.save.data.highquality;
								bendo.scrollFactor.set(1, 1);
								bendo.x -= 875;
								bendo.y += 50;
								add(bendo);

								postDemise = new FlxSprite(0, 0).loadGraphic(Paths.image('postdemise', 'bendy'));
								postDemise.updateHitbox();
								postDemise.screenCenter();
								postDemise.antialiasing = FlxG.save.data.highquality;
								postDemise.scrollFactor.set(1, 1);
								postDemise.alpha = 0.0001;
								postDemise.setGraphicSize(Std.int(postDemise.width * 1));
								postDemise.x = -1280;
								postDemise.y = -845;
								add(postDemise);

								daDad = 'bendy';
								daBF = 'bf-bendo';
							}
							else if (SONG.song.toLowerCase() == 'freaky-machine')
							{
								defaultCamZoom = 0.85;
								curStage = 'freaky-machine';

								var bg:FlxSprite = new FlxSprite(-500, 50).loadGraphic(Paths.image('bonusSongs/dabg', "shared"));
								bg.setGraphicSize(Std.int(bg.width * 1.6));
								bg.updateHitbox();
								bg.antialiasing = FlxG.save.data.highquality;
								bg.scrollFactor.set(1, 1);
								bg.active = false;
								add(bg);

								freakyMachineVideoSpr = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.WHITE);
								freakyMachineVideoSpr.width = FlxG.width / 4;
								freakyMachineVideoSpr.height = FlxG.height / 4;
								add(freakyMachineVideoSpr);
								freakyMachineVideoSpr.screenCenter();
								freakyMachineVideoSpr.x -= 600;
								freakyMachineVideoSpr.y -= 250;
								freakyMachineVideoSpr.blend = ADD;
								freakyMachineVideoSpr.alpha = 0.0001;

								var freakyMachineVideo:VideoHandler = new VideoHandler();
								var videoName:String = 'bgscenephotosensitive';
								if (!FlxG.save.data.photosensitive && FlxG.save.data.highquality)
								{
									videoName = 'bgscene';
								}
								freakyMachineVideo.playMP4(Paths.video('bendy/' + videoName), true, freakyMachineVideoSpr, false, false, true);
								gameVideos.push(freakyMachineVideo);

								machineCurtainLeft = new FlxSprite(-403, -50).loadGraphic(Paths.image('bonusSongs/Curtain1', "shared"));
								machineCurtainLeft.setGraphicSize(Std.int(machineCurtainLeft.width * 1.6));
								machineCurtainLeft.updateHitbox();
								machineCurtainLeft.antialiasing = FlxG.save.data.highquality;
								// machineCurtainLeft.scrollFactor.set(0.95, 0.95);
								machineCurtainLeft.active = false;
								add(machineCurtainLeft);

								machineCurtainRight = new FlxSprite(1900, -50).loadGraphic(Paths.image('bonusSongs/Curtain2', "shared"));
								machineCurtainRight.setGraphicSize(Std.int(machineCurtainRight.width * 1.6));
								machineCurtainRight.updateHitbox();
								machineCurtainRight.x -= machineCurtainRight.width;
								machineCurtainRight.antialiasing = FlxG.save.data.highquality;
								// machineCurtainRight.scrollFactor.set(0.95, 0.95);
								machineCurtainRight.active = false;
								add(machineCurtainRight);

								daDad = 'bendyDA';
								daBF = 'bfda';
							}
							else
							{
								defaultCamZoom = 0.50;

								var farbg:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('BACKBACKgROUND', 'bendy',false));
								farbg.updateHitbox();
								farbg.screenCenter();
								farbg.x -= 200;
								farbg.y -= 160;
								farbg.antialiasing = FlxG.save.data.highquality;
								farbg.scrollFactor.set(0.8, 0.8);
								add(farbg);

								if (SONG.song.toLowerCase() == "last-reel")
								{
									stickmanGuy = new FlxSprite(-350, 190);

									stickmanGuy.frames = Paths.getSparrowAtlas("third/JzBoy", "bendy");

									stickmanGuy.setGraphicSize(Std.int(stickmanGuy.width * 0.9));
									stickmanGuy.animation.addByPrefix('run', 'Jack Copper Walk by instance 1', 24, false);
									stickmanGuy.visible = false;

									add(stickmanGuy);
								}

								var bg:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('BackgroundwhereDEEZNUTSfitINYOmOUTH', 'bendy',false));
								bg.updateHitbox();
								bg.screenCenter();
								bg.antialiasing = FlxG.save.data.highquality;
								bg.scrollFactor.set(0.91, 0.91);
								add(bg);

								if (SONG.song.toLowerCase() == "terrible-sin" || SONG.song.toLowerCase() == "last-reel")
								{
									blackStickmanThereInBG = new FlxSprite(225, 180);

									blackStickmanThereInBG.frames = Paths.getSparrowAtlas("third/SammyBg", "bendy");

									blackStickmanThereInBG.setGraphicSize(Std.int(blackStickmanThereInBG.width * 1.1));
									blackStickmanThereInBG.animation.addByPrefix('sam', 'Sam instance', 24, false);

									add(blackStickmanThereInBG);
								}

								var mg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('MidGrounUTS', 'bendy',false));
								// mg.setGraphicSize(Std.int(mg.width * 0.7));
								mg.updateHitbox();
								mg.screenCenter();
								mg.antialiasing = FlxG.save.data.highquality;
								mg.scrollFactor.set(0.95, 0.95);
								add(mg);

								var chain:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('ChainUTS', 'bendy',false));
								// kindafg.setGraphicSize(Std.int(kindafg.width * 0.7));
								chain.updateHitbox();
								chain.screenCenter();
								chain.x -= 1500;
								chain.y -= 700;
								chain.antialiasing = FlxG.save.data.highquality;
								// fg.scrollFactor.set(1.3, 1.3);
								add(chain);

								bendyForeground = new FlxSprite(-600, -700).loadGraphic(Paths.image('NUTS', 'bendy',false));
								// kindafg.setGraphicSize(Std.int(kindafg.width * 0.7));
								bendyForeground.updateHitbox();
								bendyForeground.screenCenter();
								bendyForeground.y -= 900;
								bendyForeground.antialiasing = FlxG.save.data.highquality;
								// fg.scrollFactor.set(1.3, 1.3);
								add(bendyForeground);

								// load asset

								if (SONG.song.toLowerCase() != "last-reel")
								{
									daBF = 'bf-bendo';
								}
								else
								{
									daBF = 'bfFUCKINWHATTHEFUCKBITCH';
								}

								if (SONG.song.toLowerCase() == 'terrible-sin')
								{
									daBF = 'bfwhoareyou';
								}
									
								daDad = 'bendy';
							}
						}
					}
				}
			case 'gose':
				{
					defaultCamZoom = 0.75;
					curStage = 'canada';

					gosebg = new FlxSprite();
					gosebg.frames = Paths.getSparrowAtlas('BG', 'hiddenContent');
					gosebg.animation.addByPrefix('bop', 'BG instance 1', 24, false);
					gosebg.updateHitbox();
					gosebg.screenCenter();
					gosebg.antialiasing = FlxG.save.data.highquality;
					add(gosebg);

					GameOverSubstate.gameOverChar = 'gose';

					daBF = 'bfswag';
					daDad = 'gose';
				}
			case 'papyrus':
				{
					defaultCamZoom = 0.85;
					curStage = 'papyrus';

					bg = new FlxSprite().loadGraphic(Paths.image('bonusSongs/Papyrus_BG', 'shared',false));
					bg.setGraphicSize(Std.int(bg.width * 1.2));
					bg.updateHitbox();
					bg.screenCenter();
					bg.x -= 370;
					bg.y += 65;
					bg.antialiasing = FlxG.save.data.highquality;
					bg.scrollFactor.set(1.0, 1.0);
					add(bg);

					daDad = 'papyrus';
					daBF = 'bfwinter';
				}
			case 'devilHall':
				{
					defaultCamZoom = 0.45;
					curStage = 'devilHall';

					var bg:FlxSprite = new FlxSprite();
					if (SONG.song.toLowerCase() == 'devils-gambit')
						bg.loadGraphic(Paths.image('nightmarecupbg', 'cup',false));
					else
						bg.loadGraphic(Paths.image('bonusSongs/devil', 'shared',false));
					
					bg.setGraphicSize(Std.int(bg.width * 2));
					bg.updateHitbox();
					bg.screenCenter();
					bg.antialiasing = FlxG.save.data.highquality;
					bg.scrollFactor.set(0.7, 0.7);
					add(bg);

					cup = true;
					specialIntro = true;

					daBF = 'bfswag';
					daDad = 'devilFull';

					if (SONG.song.toLowerCase() == 'devils-gambit')
					{
						defaultCamZoom = 0.65;

						//bg.loadGraphic(Paths.image('nightmarecupbg', 'cup'));

						daBF = 'bfnightmareCup';
						daDad = 'cupheadNightmare';
					}

					checkCupheadChrom();
				}
			case 'theVoid':
				{
					defaultCamZoom = 0.575;
					curStage = 'theVoid';
				}
			default:
				{
					defaultCamZoom = 0.9;
					curStage = 'stage';
					var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('stageback'));
					bg.antialiasing = FlxG.save.data.highquality;
					bg.scrollFactor.set(0.9, 0.9);
					bg.active = false;
					add(bg);

					var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.image('stagefront'));
					stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
					stageFront.updateHitbox();
					stageFront.antialiasing = FlxG.save.data.highquality;
					stageFront.scrollFactor.set(0.9, 0.9);
					stageFront.active = false;
					add(stageFront);

					var stageCurtains:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.image('stagecurtains'));
					stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
					stageCurtains.updateHitbox();
					stageCurtains.antialiasing = FlxG.save.data.highquality;
					stageCurtains.scrollFactor.set(1.3, 1.3);
					stageCurtains.active = false;

					add(stageCurtains);
				}
		}

		oldDefaultCamZoom = defaultCamZoom;

		switch (SONG.song.toLowerCase())
		{
			case 'imminent-demise' | 'terrible-sin' | 'last-reel' | 'nightmare-run' | 'freaky-machine' | 'ritual' | 'despair':
				hasBendyTitleIntro = true;
			default:
				hasBendyTitleIntro = false;
		}

		if ((isStoryMode && deathCount <= 0 && !OptionsMenu.returnedfromOptions) && mechanicsEnabled)
		{
			switch (SONG.song.toLowerCase())
			{
				case 'knockout':
					mechInstructions = new FlxSprite().loadGraphic(Paths.image('instructions/Cuphead2', 'preload'));
					mechInstructions.cameras = [camINSTRUCTION];
					add(mechInstructions);
					hasInstruction = true;
					canPause = false;

					mechInstructMusic = new FlxSound().loadEmbedded(Paths.music('pause', 'cup'), true, true);
					mechInstructMusic.volume = 0.5;
					FlxG.sound.list.add(mechInstructMusic);
				case 'technicolor-tussle':
					mechInstructions = new FlxSprite().loadGraphic(Paths.image('instructions/Cuphead', 'preload'));
					mechInstructions.cameras = [camINSTRUCTION];
					add(mechInstructions);
					hasInstruction = true;
					canPause = false;

					mechInstructMusic = new FlxSound().loadEmbedded(Paths.music('pause', 'cup'), true, true);
					mechInstructMusic.volume = 0.5;
					FlxG.sound.list.add(mechInstructMusic);

				case 'whoopee':
					mechInstructions = new FlxSprite().loadGraphic(Paths.image('instructions/Sans', 'preload'));
					mechInstructions.cameras = [camINSTRUCTION];
					dialoguePaused = true;
					add(mechInstructions);
					hasInstruction = true;
					canPause = false;

					mechInstructMusic = new FlxSound().loadEmbedded(Paths.music('pause', 'sans'), true, true);
					mechInstructMusic.volume = 0.5;
					FlxG.sound.list.add(mechInstructMusic);

				case 'terrible-sin': // gonna format this stuff so it wont be as long, i just dont feel like doing it rn lol
					if (storyDifficulty >= 1)
					{
						mechInstructions = new FlxSprite().loadGraphic(Paths.image('instructions/Bendy-Phase2', 'preload'));
						mechInstructions.cameras = [camINSTRUCTION];
						add(mechInstructions);
						hasInstruction = true;
						canPause = false;

						mechInstructMusic = new FlxSound().loadEmbedded(Paths.music('pause', 'bendy'), true, true);
						FlxG.sound.list.add(mechInstructMusic);
					}

				case 'last-reel':
					if (storyDifficulty >= 1)
					{
						mechInstructions = new FlxSprite().loadGraphic(Paths.image('instructions/Bendy-Phase3', 'preload'));
						mechInstructions.cameras = [camINSTRUCTION];
						add(mechInstructions);
						hasInstruction = true;
						canPause = false;

						mechInstructMusic = new FlxSound().loadEmbedded(Paths.music('pause', 'bendy'), true, true);
						FlxG.sound.list.add(mechInstructMusic);

						mechAnim = new FlxSprite(26, 244);
						mechAnim.frames = Paths.getSparrowAtlas('instructions/Tutorialanim', 'preload');
						mechAnim.animation.addByPrefix('play', 'Example instance 1', 24, true);
						mechAnim.animation.play('play',true);
						mechAnim.cameras = [camINSTRUCTION];
						add(mechAnim);
					}

				case 'nightmare-run':
					mechInstructions = new FlxSprite().loadGraphic(Paths.image('instructions/Bendy-Phase4', 'preload'));
					mechInstructions.cameras = [camINSTRUCTION];
					add(mechInstructions);
					hasInstruction = true;
					canPause = false;

					mechInstructMusic = new FlxSound().loadEmbedded(Paths.music('pause', 'bendy'), true, true);
					FlxG.sound.list.add(mechInstructMusic);
			}
		}
		if (hasInstruction)
		{
			mechPressEnter = new FlxText(793, 672, 0, 'Press Enter to Continue', 32);
			mechPressEnter.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			mechPressEnter.cameras = [camINSTRUCTION];
			mechPressEnter.borderSize = 1.5;
			mechPressEnter.font = HelperFunctions.returnHudFont(mechPressEnter);
			add(mechPressEnter);
			FlxTween.tween(mechPressEnter, {alpha: 0.0}, 5, {ease: FlxEase.quadInOut, type: PINGPONG});
		}

		if (hasBendyTitleIntro)
		{
			bendyIntroOverlay = new FlxSprite().makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
			bendyIntroOverlay.updateHitbox();
			bendyIntroOverlay.screenCenter();
			bendyIntroOverlay.scrollFactor.set();
			bendyIntroOverlay.cameras = [camOVERLAY];
			add(bendyIntroOverlay);
		}

		if (curStage == 'factory')
		{
			inkObj = new FlxSprite().loadGraphic(Paths.image('Damage01', 'bendy'));
			inkObj.setGraphicSize(Std.int(FlxG.width / camOVERLAY.zoom), Std.int(FlxG.height / camOVERLAY.zoom));
			inkObj.updateHitbox();
			inkObj.screenCenter();
			inkObj.antialiasing = FlxG.save.data.highquality;
			inkObj.alpha = 0.0001;
			inkObj.scrollFactor.set();
			add(inkObj);

			inkObj.cameras = [camOVERLAY];

			flashback = new FlxSprite();
			flashback.frames = Paths.getSparrowAtlas('HorrorVision', 'bendy');
			flashback.animation.addByPrefix('play', 'Add instance 1', 24, true);
			flashback.setGraphicSize(Std.int(FlxG.width * 1.15));
			flashback.updateHitbox();
			flashback.screenCenter();
			flashback.antialiasing = FlxG.save.data.highquality;
			flashback.scrollFactor.set();
			flashback.cameras = [camOVERLAY];
			flashback.blend = BlendMode.ADD;
			flashback.alpha = 0.0001;
			add(flashback);
		}

		dad = new Character(100, 100, daDad);

		boyfriend = new Boyfriend(770, 450, daBF);

		player3 = new Character(100, 100, daPlayer3);

		switch (dad.curCharacter)
		{
			case 'saness':
				dad.y += 215;
				dad.x -= 120;
			case 'cuphead' | 'cupheadNightmare':
				dad.y += 300;
			case 'angrycuphead':
				dad.y += 390;
				dad.x += 40;
			case 'bendy':
				dad.y -= -25;
				dad.x -= 325;
			case 'bendyChase':
				dad.x -= 500;
				dad.y += 200;
			case 'sans' | 'sansScared' | 'sansNightmare' | 'papyrus' | 'sanswinter':
				dad.setPosition(-310.6, 245);
				if (dad.curCharacter == 'sansNightmare')
				{
					dad.setPosition(-350, -130);
				}
				else if (dad.curCharacter == 'papyrus')
				{
					dad.y -= 60;
					boyfriend.y -= 35;
				}
			case 'bendyDA':
				dad.y += 225;
				boyfriend.y += 40;
			case 'devilFull':
				boyfriend.y += 325;
				boyfriend.x += 400;
				dad.x -= 400;
				dad.y -= 100;
				boyfriend.setGraphicSize(Std.int(FlxG.width * 0.3));
		}

		switch (player3.curCharacter)
		{
			case 'sanswinter':
				player3.setPosition(-50.6, 305);
				player3.x -= 300;
				dad.x += 250;
		}

		// REPOSITIONING PER STAGE
		switch (curStage)
		{
			case 'hall':
				boyfriend.setPosition(616.3, 375.1);
			case 'factory':
				boyfriend.x += 300;
				boyfriend.y += 200;
				dad.x -= 200;
				dad.y += 30;
				ogposes = [boyfriend.x,boyfriend.y,dad.x,dad.y];
				if (SONG.song.toLowerCase() == 'despair')
				{
					trace('despair');
					boyfriend.x += 300;
					boyfriend.y += 100;
					dad.x -= 300;
					dad.y -= 140;
					boyfriend.scrollFactor.set(0.91, 0.91);
					dad.scrollFactor.set(0.91, 0.91);
				}
				if (SONG.song.toLowerCase() == 'ritual')
				{
					dad.scrollFactor.set(0.8, 0.8);
					boyfriend.scrollFactor.set(0.8, 0.8);
					boyfriend.y += 20;
				}
				else if (SONG.song.toLowerCase() == 'imminent-demise')
				{
					boyfriend.setPosition(760, 450);
					dad.x -= 220;
					dad.y -= 200;
					dad.alpha = 0.0001;
				}
				else if (SONG.song.toLowerCase() == 'last-reel')
				{
					boyfriend.x -= 350;
					boyfriend.y += 40;
					trace('boyfriend x: ' + boyfriend.x);
					trace('boyfriend y: ' + boyfriend.y);
				}
				else if (SONG.song.toLowerCase() == 'freaky-machine')
				{
					boyfriend.y += 30;
				}
				else if (SONG.song.toLowerCase() == 'terrible-sin')
				{
					boyfriend.x = 935;
					boyfriend.y = 720;
					trace('boyfriend x: ' + boyfriend.x);
					trace('boyfriend y: ' + boyfriend.y);
				}
			case 'field':
				dad.x -= 150;
				boyfriend.x += 175;
				if (SONG.song.toLowerCase() != 'knockout')
					dad.y += 80;
			case 'canada':
				boyfriend.y -= 160;
			case 'freaky-machine':
				boyfriend.x += 150;
				boyfriend.y += 180;
				dad.x += 150;
				dad.y += 180;
			case 'devilHall':
				boyfriend.scrollFactor.set(0.7, 0.7);
				dad.scrollFactor.set(0.7, 0.7);
				if (SONG.song.toLowerCase() == 'devils-gambit')
				{
					boyfriend.y += 285;
					boyfriend.x += 190;
					dad.y += 50;
					dad.x -= 200;
				}
		}

		/*
			sans gang
			██████████▀▀▀▀▀▀▀▀▀▀▀▀▀██████████
			█████▀▀░░░░░░░░░░░░░░░░░░░▀▀█████
			███▀░░░░░░░░░░░░░░░░░░░░░░░░░▀███
			██░░░░░░░░░░░░░░░░░░░░░░░░░░░░░██
			█░░░░░░▄▄▄▄▄▄░░░░░░░░▄▄▄▄▄▄░░░░░█
			█░░░▄██▀░░░▀██░░░░░░██▀░░░▀██▄░░█
			█░░░██▄░░▀░░▄█░░░░░░█▄░░▀░░▄██░░█
			██░░░▀▀█▄▄▄██░░░██░░░██▄▄▄█▀▀░░██
			███░░░░░░▄▄▀░░░████░░░▀▄▄░░░░░███
			██░░░░░█▄░░░░░░▀▀▀▀░░░░░░░█▄░░░██
			██░░░▀▀█░█▀▄▄▄▄▄▄▄▄▄▄▄▄▄▀██▀▀░░██
			███░░░░░▀█▄░░█░░█░░░█░░█▄▀░░░░███
			████▄░░░░░░▀▀█▄▄█▄▄▄█▄▀▀░░░░▄████
			███████▄▄▄▄░░░░░░░░░░░░▄▄▄███████
		 */

		Application.current.window.title = (Main.appTitle
			+ ' - '
			+ HelperFunctions.getSongData(SONG.song.toLowerCase(), 'artist')
			+ ' - '
			+ HelperFunctions.getSongData(SONG.song.toLowerCase(), 'name')
			+ ' ['
			+ storyDifficultyText
			+ ']'
			+ ' ['
			+ HelperFunctions.mechDifficultyFromInt(mechanicType)
			+ ']'
			);

		if (SONG.song.toLowerCase() == 'devils-gambit')
		{
			var bgGlow:FlxSprite = new FlxSprite(dad.x - 460, dad.y - 370);
			bgGlow.frames = Paths.getSparrowAtlas('NMClight', 'cup');
			bgGlow.animation.addByPrefix('play', 'rgrrr instance 1', 30, true);
			bgGlow.animation.play('play', true);
			bgGlow.updateHitbox();
			bgGlow.antialiasing = true;
			bgGlow.scrollFactor.set(0.7, 0.7);
			add(bgGlow);

			cupBullets[0] = new CupBullet('laser', 0, 0);
			cupBullets[0].scrollFactor.set(0.7, 0.7);
			cupBullets[0].pew = function()
			{
				healthChange(-0.0475);
			};
			//add(cupBullets[0]);

			sign = new FlxSprite(540, 343);
			if (PlayStateChangeables.useDownscroll)
				sign.frames = Paths.getSparrowAtlas('gay', 'shared');
			else
				sign.frames = Paths.getSparrowAtlas('mozo', 'shared');
			sign.animation.addByPrefix('play', 'YTJT instance 1', 24, false);
			sign.animation.play('play');
			sign.antialiasing = FlxG.save.data.highquality;
			sign.cameras=[camHUD];
			sign.alpha = 0;
			add(sign);

			if (PlayStateChangeables.useDownscroll)
			{
				sign.x = 540;
				sign.y = 62;
			}
		}

		if (true) // !PlayStateChangeables.Optimize) [[this shit has some pretty important code that cannot be deactivated or the game'd break]]
		{
			if (SONG.song.toLowerCase() == 'nightmare-run')
			{
				remove(boyfriend);
				boyfriend = new Boyfriend(boyfriend.x, boyfriend.y, 'bfChaseDark');
				remove(dad);
				dad = new Character(dad.x, dad.y, 'bendyChaseDark');
				layerChars();
				remove(boyfriend);
				boyfriend = new Boyfriend(boyfriend.x, boyfriend.y, 'bfChase');
				remove(dad);
				dad = new Character(dad.x, dad.y, 'bendyChase');
			}
			layerChars();

			if (SONG.song.toLowerCase() == 'despair')
			{
				bendyBoyGroup = new FlxTypedGroup<BendyBoy>();
				add(bendyBoyGroup);

				currentPiper = new BendyBoy(0, 260, "piper", true);
				add(currentPiper);
				remove(currentPiper);
				currentPiper = null;

				currentStriker = new BendyBoy(0, 260, "striker", true);
				add(currentStriker);
				remove(currentStriker);
				currentStriker = null;

				devilGroup = new FlxTypedGroup<DevilBitches>();
				var newDevil:DevilBitches = new DevilBitches(true);
				newDevil.visible = false;
				newDevil.setGraphicSize(Std.int(newDevil.width * 0.8));
				devilGroup.add(newDevil);

				if (mechanicsEnabled)
				{
					add(devilGroup);
				}

				resetDevilGroupIndex();
			}
			else if (SONG.song.toLowerCase() == 'last-reel' && storyDifficulty >= 1)
			{
				bendyBoyGroup = new FlxTypedGroup<BendyBoy>();
				if (mechanicsEnabled)
					add(bendyBoyGroup);

				currentPiper = new BendyBoy(0, 0, "piper", false);
				add(currentPiper);
				remove(currentPiper);
				currentPiper = null;

				currentStriker = new BendyBoy(0, 0, "striker", false);
				add(currentStriker);
				remove(currentStriker);
				currentStriker = null;
			}
			else if (SONG.song.toLowerCase().contains('satanic-funkin'))
			{
				devilGroup = new FlxTypedGroup<DevilBitches>();
				var newDevil:DevilBitches = new DevilBitches();
				newDevil.visible = false;
				devilGroup.add(newDevil);

				if (mechanicsEnabled)
				{
					add(devilGroup);
				}

				resetDevilGroupIndex();
			}

			if (SONG.song.toLowerCase() == 'bonedoggle')
				add(player3);

			sammyAxe = new FlxSprite();
			switch (curStage)
			{
				// this is where it'll spawn over the characters
				case 'hall':
					{
						alarm = new FlxSprite();
						alarm.frames = Paths.getSparrowAtlas('DodgeMechs', 'sans');

						if (SONG.song.toLowerCase() == 'burning-in-hell')
						{
							alarm.frames = Paths.getSparrowAtlas('Cardodge', 'sans');
						}

						alarm.animation.addByPrefix('play', 'Alarm instance 1', 24, false);
						alarm.animation.addByPrefix('DIE', 'Bones boi instance 1', 24, false);
						alarm.updateHitbox();
						alarm.antialiasing = true;
						alarm.alpha = 0.0001;
						alarm.x = boyfriend.x - 175;
						alarm.y = boyfriend.y - 100;
						add(alarm);

						alarmbone = new FlxSprite();
						alarmbone.frames = Paths.getSparrowAtlas('Sans_Shit_NM', 'sans');
						alarmbone.animation.addByPrefix('playblue', 'AlarmBlue instance 1', 24, false);
						alarmbone.animation.addByPrefix('blue', 'Bones boi instance 1', 24, false);
						alarmbone.animation.addByPrefix('playorange', 'AlarmOrange instance 1', 24, false);
						alarmbone.animation.addByPrefix('orange', 'Bones Orange instance 1', 24, false);
						alarmbone.updateHitbox();
						alarmbone.antialiasing = true;
						alarmbone.alpha = 0.0001;
						alarmbone.x = boyfriend.x - 175;
						alarmbone.y = boyfriend.y - 100;
						alarmbone.blend = BlendMode.ADD;
						add(alarmbone);

						bfDodge = new FlxSprite();
						bfDodge.frames = Paths.getSparrowAtlas('DodgeMechs', 'sans');
						var yOffset:Int = 0;
						if (fuckinAngry)
						{
							bfDodge.frames = Paths.getSparrowAtlas('characters/BF-BS-shader', 'shared', true);
							add(nightmareSansBgs[1]);
						}
						else if (SONG.song.toLowerCase() == 'burning-in-hell')
						{
							bfDodge.frames = Paths.getSparrowAtlas('Cardodge', 'sans');
							yOffset = 40;
						}
						if (fuckinAngry)
						{
							bfDodge.animation.addByPrefix('Dodge', 'boyfriend dodge instance 1', 24, false);
						}
						else
						{
							bfDodge.animation.addByPrefix('Dodge', 'Dodge instance 1', 24, false);
						}
						bfDodge.updateHitbox();
						bfDodge.antialiasing = true;
						bfDodge.alpha = 0.0001;
						bfDodge.x = boyfriend.x;
						bfDodge.y = boyfriend.y + yOffset;
						add(bfDodge);
					}
				case 'factory':
					{
						// saruky song (imminent demise has all 3 bf expressions)
						// 2nd song only has angry pose
						// sammy song has normal smiling bf

						if (SONG.song.toLowerCase() == 'ritual')
						{
							sammyAxe.frames = Paths.getSparrowAtlas('characters/SammyRemastered', 'shared');
							sammyAxe.animation.addByPrefix('throw', 'Axe attack instance 1', 24, false);
							sammyAxe.alpha = 0.00001;
							sammyAxe.antialiasing = FlxG.save.data.highquality;
							sammyAxe.x = dad.getMidpoint().x + 200;
							sammyAxe.y = dad.getMidpoint().y - 120;
							sammyAxe.updateHitbox();
							sammyAxe.scale.set(1.75, 1.75);
							sammyAxe.scrollFactor.set(0.8, 0.8);
							add(sammyAxe);
						}

						if (SONG.song.toLowerCase() == 'last-reel' || SONG.song.toLowerCase() == 'despair')
						{
							inkStormRain = new FlxSprite();
							inkStormRain.frames = Paths.getSparrowAtlas('third/InkRain', 'bendy');
							inkStormRain.animation.addByPrefix('play', 'erteyd instance 1', 30, true);
							inkStormRain.antialiasing = FlxG.save.data.highquality;
							inkStormRain.setGraphicSize(FlxG.width);
							inkStormRain.updateHitbox();
							inkStormRain.screenCenter();
							inkStormRain.cameras = [camHUD];
							add(inkStormRain);
							inkStormRain.alpha = 0.0001;

							inkscroll = new FlxTypedGroup<FlxSprite>();
							add(inkscroll);

							for (i in 0...3)
							{
								var ink:FlxSprite;
								ink = new FlxSprite().loadGraphic(Paths.image('third/Ink_shit', 'bendy'));
								ink.antialiasing = FlxG.save.data.highquality;
								ink.alpha = 0.0001;
								ink.cameras = [camHUD];
								ink.setGraphicSize(FlxG.width);
								ink.updateHitbox();
								ink.x += i * 762;
								ink.blend = OVERLAY;
								inkscroll.add(ink);
							}

							blackOverlay = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
							blackOverlay.updateHitbox();
							blackOverlay.screenCenter();
							blackOverlay.alpha = 0.0001;
							blackOverlay.scrollFactor.set();
							blackOverlay.cameras = [camHUD];
							add(blackOverlay);
						}

						if (SONG.song.toLowerCase() == 'imminent-demise')
						{
							light = new FlxSprite(0, 0);
							light.frames = Paths.getSparrowAtlas('first/Light(Add-Blend)', 'bendy');
							light.animation.addByPrefix('flash', 'fezt instance 1', 24, true);
							if (!FlxG.save.data.photosensitive && FlxG.save.data.highquality)
								light.animation.play('flash', true);
							light.updateHitbox();
							light.screenCenter();
							light.antialiasing = FlxG.save.data.highquality;
							light.scrollFactor.set(0.9, 0.9);
							light.x += 700;
							light.y += 50;
							light.blend = BlendMode.ADD;
							add(light);

							pillar = new FlxSprite(0, 0).loadGraphic(Paths.image('first/Pillar', 'bendy'));
							pillar.updateHitbox();
							pillar.screenCenter();
							pillar.antialiasing = FlxG.save.data.highquality;
							pillar.scrollFactor.set(1.2, 1.2);
							pillar.x += 650;
							add(pillar);
						}

						if (SONG.song.toLowerCase() == 'nightmare-run')
						{
							transition = new FlxSprite();
							transition.frames = Paths.getSparrowAtlas('dark/Trans', 'bendy');
							transition.animation.addByPrefix('bruh', 'beb instance 1', 24, false);
							transition.setGraphicSize(Std.int(transition.width * infiniteResize));
							transition.updateHitbox();
							transition.screenCenter();
							transition.scrollFactor.set(0.8, 0.8);
							transition.antialiasing = FlxG.save.data.highquality;
							transition.alpha = 0.0001;
							transition.animation.play('bruh', true);
							transition.cameras = [camHUD];

							/*lights = new FlxSprite();
								lights.frames = Paths.getSparrowAtlas('dark/Lights', 'bendy');
								lights.animation.addByPrefix('bruh', 'RunLol Hallway instance 1', 24, false);
								lights.setGraphicSize(Std.int(lights.width * infiniteResize));
								lights.updateHitbox();
								lights.screenCenter();
								lights.scrollFactor.set(0.8, 0.8);
								lights.antialiasing = FlxG.save.data.highquality;
								lights.alpha = 0.0001;
								lights.animation.play('bruh', true);
								lights.blend = BlendMode.ADD;
							 */

							// i dont like how i implmented the stair stuff, feel free to make it better
							stairsBG = new FlxBackdrop(Paths.image('stairs/scrollingBG', 'bendy'), 0, 1, false, true);
							stairsBG.screenCenter();
							stairsBG.alpha = 0.0001;
							stairsBG.velocity.set(0, 180);

							stairs = new FlxSprite(0, 0).loadGraphic(Paths.image('stairs/stairs', 'bendy'));
							stairs.updateHitbox();
							stairs.screenCenter();
							stairs.alpha = 0.0001;
							stairs.antialiasing = FlxG.save.data.highquality;
							stairs.y -= 720;

							stairsGradient = new FlxSprite(0, 0).loadGraphic(Paths.image('stairs/gradient', 'bendy'));
							stairsGradient.updateHitbox();
							stairsGradient.screenCenter();
							stairsGradient.y -= 1;
							stairsGradient.blend = OVERLAY;

							stairsGrp = new FlxTypedGroup<FlxSprite>();
							add(stairsGrp);
							// stairsGrp.add(stairsBG);
							// stairsGrp.add(stairs);
							// stairsGrp.add(stairsChainL);
							// stairsGrp.add(stairsChainR);

							remove(boyfriend);
							remove(dad);
							layerChars();
							transitionLayer = new FlxTypedGroup<FlxSprite>();
							add(transitionLayer);
							// transitionLayer.add(lights);
							transitionLayer.add(transition);

							//kink machine

							backbg = new FlxTypedGroup<FlxSprite>();
							add(backbg);

							frontbg = new FlxTypedGroup<FlxSprite>();
							add(frontbg);

							var strings = ['0','4','3','2','6_BLEND_MODE_ADD'];

							for (killme in 0...5)
							{
								var bg:FlxSprite = new FlxSprite();
								bg.loadGraphic(Paths.image('gay/C_0' + strings[killme], 'bendy',false));
								if (killme == 4)
									bg.blend = BlendMode.ADD;
								backbg.add(bg);
							}

							for (i in 0...3)
							{
								var bg:FlxSprite = new FlxSprite();
								bg.loadGraphic(Paths.image('gay/C_01', 'bendy',false));
								bg.x += i * bg.width;
								frontbg.add(bg);
							}

							var bg:FlxSprite = new FlxSprite();
							bg.loadGraphic(Paths.image('gay/C_05', 'bendy',false));
							frontbg.add(bg);

							var bg:FlxSprite = new FlxSprite();
							bg.loadGraphic(Paths.image('gay/C_07', 'bendy',false));
							frontbg.add(bg);

							for (i in frontbg)
							{
								i.scrollFactor.set(0, 0);
								i.alpha = 0;
								i.setGraphicSize(Std.int(FlxG.width*1.815));
								i.screenCenter();
								i.antialiasing = FlxG.save.data.highquality;
							}

							for (i in 0...3)
							{
								frontbg.members[i].x += i * FlxG.width*1.815;
							}

							for (i in backbg)
							{
								i.scrollFactor.set(0, 0);
								i.alpha = 0;
								i.setGraphicSize(Std.int(FlxG.width*1.815));
								i.screenCenter();
								i.antialiasing = FlxG.save.data.highquality;
							}

							for (i in 1...5)
							{
								backbg.members[i].x += 300;
							}
						}

						cutouts = [];

						for (i in 0...4)
						{
							var cutout:FlxSprite = new FlxSprite();
							var imgName:String = 'BendyCutouts';
							var animName:String = '';
							switch (i)
							{
								case 0:
									animName = '01 instance 1';
								case 1:
									animName = '02 instance 1';
								case 2:
									animName = '03 instance 1';
								case 3:
									animName = '04 instance 1';
							}

							cutout.frames = Paths.getSparrowAtlas('Cutouts/' + imgName, 'bendy');
							cutout.animation.addByPrefix('bruh', animName, 24, false);
							cutout.setGraphicSize(Std.int(FlxG.width*1/2));
							cutout.updateHitbox();
							cutout.scrollFactor.set(0, 0);
							cutout.antialiasing = FlxG.save.data.highquality;
							cutout.graphic.persist = true;
							cutout.graphic.destroyOnNoUse = false;
							cutout.alpha = 0.0001;
							cutout.cameras = [camHUD];
							add(cutout);

							switch (i)
							{
								case 0:
									cutout.x = 655; 
									cutout.y = 197;
								case 1:
									cutout.x = 41; 
									cutout.y = -159;
								case 2:
									cutout.x = 159; 
									cutout.y = -131;
								case 3:
									cutout.x = -19; 
									cutout.y = -378;
							}

							cutouts.push(cutout);
						}

						if (SONG.song.toLowerCase() == 'terrible-sin' || SONG.song.toLowerCase() == 'last-reel')
						{
							var fg = new FlxSprite(-600, -150).loadGraphic(Paths.image('ForegroundEEZNUTS', 'bendy',false));
							fg.updateHitbox();
							fg.screenCenter();
							fg.x += 1000;
							fg.antialiasing = FlxG.save.data.highquality;
							fg.scrollFactor.set(1.1, 1.1);
							add(fg);

							if (SONG.song.toLowerCase() == 'last-reel')
							{
								bendyboysfg = new FlxSprite(-1450, 655);
								bendyboysfg.frames = Paths.getSparrowAtlas('third/Butchergang_Bg', 'bendy');
								bendyboysfg.animation.addByPrefix('dance', 'Symbol 1 instance 1', 24, false);
								bendyboysfg.setGraphicSize(Std.int(bendyboysfg.width * 3));
								bendyboysfg.updateHitbox();
								bendyboysfg.antialiasing = FlxG.save.data.highquality;
								bendyboysfg.scrollFactor.set(0.95, 0.95);
								add(bendyboysfg);
							}
						}

						if (SONG.song.toLowerCase() == 'ritual')
						{
							var candle = new FlxSprite(345, 1300);
							candle.frames = Paths.getSparrowAtlas('Candles', 'bendy');
							candle.animation.addByPrefix('candles', 'Candless instance 1', 24, true);
							candle.updateHitbox();
							candle.antialiasing = FlxG.save.data.highquality;
							candle.setGraphicSize(Std.int(candle.width * 3));
							candle.scrollFactor.set(0.95, 0.95);
							add(candle);
							candle.animation.play('candles', true);

							var candleLight = new FlxSprite(100, 1050);
							candleLight.frames = Paths.getSparrowAtlas('Candles', 'bendy');
							candleLight.animation.addByPrefix('lights', 'Lights instance 1', 24, true);
							candleLight.updateHitbox();
							candleLight.antialiasing = FlxG.save.data.highquality;
							candleLight.setGraphicSize(Std.int(candleLight.width * 3));
							candleLight.scrollFactor.set(0.95, 0.95);
							candleLight.blend = BlendMode.ADD;
							add(candleLight);
							candleLight.animation.play('lights', true);
						}

						if (SONG.song.toLowerCase() == 'last-reel')
						{
							piper = new FlxSprite();
							piper.frames = Paths.getSparrowAtlas('jumpscares/PiperJumpscare', 'bendy');
							piper.animation.addByPrefix('bruh', 'Fuck uuuu instance 1', 24, false);
							piper.updateHitbox();
							piper.screenCenter();
							piper.scrollFactor.set(0, 0);
							piper.antialiasing = FlxG.save.data.highquality;
							piper.graphic.persist = true;
							piper.graphic.destroyOnNoUse = false;
							piper.alpha = 0.0001;
							piper.cameras = [camOVERLAY];
							add(piper);

							fisher = new FlxSprite(-1280);
							fisher.frames = Paths.getSparrowAtlas('jumpscares/DontmindmeImmajustwalkby', 'bendy');
							fisher.animation.addByPrefix('bruh', 'WalkinFhis instance 1', 24, true);
							fisher.updateHitbox();
							fisher.screenCenter(Y);
							fisher.scrollFactor.set(0, 0);
							fisher.antialiasing = FlxG.save.data.highquality;
							fisher.graphic.persist = true;
							fisher.graphic.destroyOnNoUse = false;
							fisher.alpha = 0.0001;
							fisher.cameras = [camHUD];
							add(fisher);
						}

						if (SONG.song.toLowerCase() == 'despair')
						{
							bendy = new FlxSprite(-410, -980);
							bendy.frames = Paths.getSparrowAtlas('bonusSongs/NightmareJumpscares03', 'shared');
							bendy.animation.addByPrefix('play', 'Emmi instance 1', 24, false);
							bendy.antialiasing = FlxG.save.data.highquality;
							bendy.setGraphicSize(FlxG.width);
							bendy.updateHitbox();
							bendy.screenCenter();
							bendy.scrollFactor.set();
							bendy.cameras = [camOVERLAY];
							bendy.alpha = 0.0001;
							add(bendy);

							jumpscareStatic = new FlxSprite(0, 0);
							jumpscareStatic.frames = Paths.getSparrowAtlas('bonusSongs/static', 'shared');
							jumpscareStatic.animation.addByPrefix('static', 'static', 24, true);
							jumpscareStatic.antialiasing = FlxG.save.data.highquality;
							jumpscareStatic.updateHitbox();
							jumpscareStatic.scrollFactor.set();
							jumpscareStatic.alpha = 1.0;
							jumpscareStatic.setGraphicSize(Std.int(FlxG.width * 1.1));
							jumpscareStatic.screenCenter();
							jumpscareStatic.cameras = [camOVERLAY];
							jumpscareStatic.visible = false;
							add(jumpscareStatic);

							blast = new FlxSprite(dad.x - 700, dad.y);
							blast.frames = Paths.getSparrowAtlas('characters/AAAAAAAAAAAAAAAAAA');
							blast.animation.addByPrefix('play', 'JumpEffect instance 1', 25, false);
							blast.setGraphicSize(Std.int(blast.width * 3));
							blast.alpha = 0.00001;
							add(blast);
						}
					}
				case 'field' | 'devilHall':
					{
						if (curStage == 'field')
						{
							// bullets
							cupBullets[0] = new CupBullet('hadoken', 0, 0);
							add(cupBullets[0]);
							cupBullets[1] = new CupBullet('roundabout', 0, 0);
							add(cupBullets[1]);

							if (SONG.song.toLowerCase() == 'knockout')
							{
								mugdead = new FlxSprite();
								mugdead.frames = Paths.getSparrowAtlas('characters/Mugman Fucking dies');
								mugdead.animation.addByPrefix('Dead', 'MUGMANDEAD', 24, false);
								mugdead.animation.addByPrefix('Stroll', 'Mugman instance', 24, true);
								mugdead.animation.play('Stroll', true);
								mugdead.animation.pause();
								mugdead.updateHitbox();
								mugdead.antialiasing = true;
								mugdead.x = boyfriend.x + 500;
								mugdead.y = boyfriend.y;
								add(mugdead);

								fgRain = new FlxSprite();
								fgRain.frames = Paths.getSparrowAtlas('angry/NewRAINLayer01', 'cup');
								fgRain.animation.addByPrefix('play', 'RainFirstlayer instance 1', 24, true);
								fgRain.animation.play('play', true);
								fgRain.setGraphicSize(FlxG.width);
								fgRain.updateHitbox();
								fgRain.screenCenter();
								fgRain.antialiasing = FlxG.save.data.highquality;
								fgRain.scrollFactor.set();
								fgRain.cameras = [camOVERLAY];
								add(fgRain);

								fgRain2 = new FlxSprite();
								fgRain2.frames = Paths.getSparrowAtlas('angry/NewRainLayer02', 'cup');
								fgRain2.animation.addByPrefix('play', 'RainFirstlayer instance 1', 24, true);
								fgRain2.animation.play('play', true);
								fgRain2.setGraphicSize(FlxG.width);
								fgRain2.updateHitbox();
								fgRain2.screenCenter();
								fgRain2.antialiasing = FlxG.save.data.highquality;
								fgRain2.scrollFactor.set();
								fgRain2.cameras = [camOVERLAY];
								add(fgRain2);

								knockoutSpr = new FlxSprite();
								knockoutSpr.frames = Paths.getSparrowAtlas('knock', 'cup');
								knockoutSpr.animation.addByPrefix('start', "A KNOCKOUT!", 24, false);
								knockoutSpr.updateHitbox();
								knockoutSpr.screenCenter();
								knockoutSpr.antialiasing = FlxG.save.data.highquality;
								knockoutSpr.scrollFactor.set();
								knockoutSpr.alpha = 0.0001;
								add(knockoutSpr);
							}
						}

						fgStatic = new FlxSprite();
						fgStatic.frames = Paths.getSparrowAtlas('CUpheqdshid', 'cup');
						fgStatic.animation.addByPrefix('play', 'Cupheadshit_gif instance 1', 24, true);
						fgStatic.animation.play('play', true);
						fgStatic.setGraphicSize(FlxG.width);
						fgStatic.updateHitbox();
						fgStatic.screenCenter();
						fgStatic.antialiasing = FlxG.save.data.highquality;
						fgStatic.scrollFactor.set();
						fgStatic.cameras = [camOVERLAY];
						add(fgStatic);

						fgGrain = new FlxSprite();
						fgGrain.frames = Paths.getSparrowAtlas('Grainshit', 'cup');
						fgGrain.animation.addByPrefix('play', 'Geain instance 1', 24, true);
						fgGrain.animation.play('play', true);
						fgGrain.setGraphicSize(FlxG.width);
						fgGrain.updateHitbox();
						fgGrain.screenCenter();
						fgGrain.antialiasing = FlxG.save.data.highquality;
						fgGrain.scrollFactor.set();
						fgGrain.cameras = [camOVERLAY];
						add(fgGrain);

						if (SONG.song.toLowerCase() == 'knockout')
						{
							fgStatic.alpha = 0.6;

							sign = new FlxSprite(540, 343);
							sign.frames = Paths.getSparrowAtlas('mozo', 'shared');
							sign.animation.addByPrefix('play', 'YTJT instance 1', 24, false);
							sign.animation.play('play');
							sign.antialiasing = FlxG.save.data.highquality;
							sign.cameras=[camHUD];
							sign.alpha = 0;
							add(sign);

							if (PlayStateChangeables.useDownscroll)
							{
								sign.flipY = true;
								sign.x = 540;
								sign.y = 62;
							}
						}

						if (SONG.song.toLowerCase() == 'satanic-funkin')
						{
							devilIntroSpr = new FlxSprite(-322, -283);
							devilIntroSpr.frames = Paths.getSparrowAtlas('characters/Devil_Intro', 'shared');
							devilIntroSpr.animation.addByPrefix('start', "Intro instance 1", 24, false);
							devilIntroSpr.updateHitbox();
							devilIntroSpr.antialiasing = FlxG.save.data.highquality;
							devilIntroSpr.scrollFactor.set(0.9, 0.9);
							devilIntroSpr.setGraphicSize(Std.int(devilIntroSpr.width * 1.3));
							add(devilIntroSpr);
							devilIntroSpr.alpha = 0.00001;

							devilIntroSpr.animation.finishCallback = function(name:String)
							{
								trace('anim finished');
							}
						}
					}
			}
		}

		camZooming = true;

		getCamOffsets();

		if (curStage == 'field' || curStage == 'devilHall')
		{
			cupTea = new FlxSprite();
			cupTea.frames = Paths.getSparrowAtlas('the_thing2.0', 'cup');
			cupTea.animation.addByPrefix('start', "BOO instance 1", 24, false);
			cupTea.setGraphicSize(Std.int((FlxG.width / camHUD.zoom) * 1.1), Std.int((FlxG.height / camHUD.zoom) * 1.1));
			cupTea.updateHitbox();
			cupTea.screenCenter();
			cupTea.antialiasing = FlxG.save.data.highquality;
			cupTea.scrollFactor.set();
			cupTea.cameras = [camOVERLAY];
			cupTea.alpha = 0.00001;
			add(cupTea);
		}

		var camPos:FlxPoint;

		if (isStoryMode && curStage == 'hall')
		{
			camPos = new FlxPoint((dadPos[0] + bfPos[0]) / 2, (dadPos[1] + bfPos[1]) / 2);
		}
		else
		{
			camPos = new FlxPoint(bfPos[0], bfPos[1]);
		}

		if (SONG.song.toLowerCase() == 'devils-gambit')
		{
			camPos.x -= 400;
			camPos.y -= 1000;
		}

		pushToSpecialAnim('bf');
		pushToSpecialAnim('dad');
		if (SONG.song.toLowerCase() == 'bonedoggle')
			pushToSpecialAnim('player3');

		Conductor.songPosition = -5000;

		strumLine = new FlxSprite(0, 50).makeGraphic(FlxG.width, 10);
		strumLine.scrollFactor.set();

		if (PlayStateChangeables.useDownscroll)
			strumLine.y = FlxG.height - 165;

		if (SONG.song.toLowerCase() == 'bonedoggle')
			{
				Note.noteWidth = 0.65;
				Note.swagWidth = 155 * 0.65;
			}

		laneunderlayOpponent = new FlxSprite(0, 0).makeGraphic(Std.int(Note.swagWidth * 4), FlxG.height * 2);
		laneunderlayOpponent.alpha = 1 - FlxG.save.data.laneTransparency;
		laneunderlayOpponent.color = FlxColor.BLACK;
		laneunderlayOpponent.scrollFactor.set();

		laneunderlayOpponent2 = new FlxSprite(0, 0).makeGraphic(Std.int(Note.swagWidth * 4), FlxG.height * 2);
		laneunderlayOpponent2.alpha = 1 - FlxG.save.data.laneTransparency;
		laneunderlayOpponent2.color = FlxColor.BLACK;
		laneunderlayOpponent2.scrollFactor.set();

		laneunderlay = new FlxSprite(0, 0).makeGraphic(Std.int(Note.swagWidth * 4), FlxG.height * 2);
		laneunderlay.alpha = 1 - FlxG.save.data.laneTransparency;
		laneunderlay.color = FlxColor.BLACK;
		laneunderlay.scrollFactor.set();

		if (FlxG.save.data.laneUnderlay)
		{
			add(laneunderlayOpponent);
			add(laneunderlay);
			if (SONG.song.toLowerCase() == 'bonedoggle')
				add(laneunderlayOpponent2);
		}

		strumLineNotes = new FlxTypedGroup<FlxSprite>();
		add(strumLineNotes);

		playerStrums = new FlxTypedGroup<FlxSprite>();
		cpuStrums = new FlxTypedGroup<FlxSprite>();
		cpuStrums2 = new FlxTypedGroup<FlxSprite>();

		altStrumLineNotes = new FlxTypedGroup<FlxSprite>();
		altPlayerStrums = new FlxTypedGroup<FlxSprite>();
		altCpuStrums = new FlxTypedGroup<FlxSprite>();
		add(altStrumLineNotes);

		if (curStage == 'field' || curStage == 'devilHall')
		{
			noteskinSprite = Paths.getSparrowAtlas('NOTE_cup', 'notes');
		}
		else
		{
			noteskinSprite = Paths.getSparrowAtlas('NOTE_assets', 'notes');
		}

		generateStaticArrows(0, true);
		generateStaticArrows(1, true);

		if (SONG.song.toLowerCase() == 'bonedoggle')
			generateStaticArrows(2, true);

		generateAltStaticArrows(0, true);
		generateAltStaticArrows(1, true);

		// Update lane underlay positions AFTER static arrows :)

		laneunderlay.screenCenter(Y);
		laneunderlayOpponent.screenCenter(Y);
		laneunderlayOpponent2.screenCenter(Y);

		// make da hud elements

		var suffix:String = (curStage != 'hall' ? '' : 'UT');
		attackHud = new HudIcon(6, 235, 'attack' + suffix);
		dodgeHud = new HudIcon(6, 145 + attackHud.height, 'dodge' + suffix);

		dodgeHud.cameras = [camHUD];
		attackHud.cameras = [camHUD];

		switch (SONG.song.toLowerCase())
		{
			case 'last-reel':
				add(attackHud);
				add(dodgeHud);
			case 'despair':
				add(attackHud);
				add(dodgeHud);
				attackHud.alpha = 0.0001;
				dodgeHud.alpha = 0.0001;
			case 'sansational' | 'burning-in-hell':
				add(attackHud);
				add(dodgeHud);
				attackHud.alpha = 0.0001;
				dodgeHud.alpha = 0.0001;
				sansCanAttack = true;
			case 'whoopee':
				add(dodgeHud);
			case 'technicolor-tussle':
				add(attackHud);
			case 'knockout' | 'devils-gambit':
				add(attackHud);
				add(dodgeHud);
			case 'satanic-funkin':
				add(dodgeHud);
			case 'ritual':
				add(dodgeHud);
				dodgeHud.alpha = 0.0001;
		}

		generateSong(SONG.song);

		origSpeed = SONG.speed;

		for (i in unspawnNotes)
		{
			var dunceNote:Note = i;
			notes.add(dunceNote);
			dunceNote.cameras = [camHUD];
		}

		if (startTime != 0)
		{
			var toBeRemoved = [];
			for (i in 0...notes.members.length)
			{
				var dunceNote:Note = notes.members[i];

				if (dunceNote.strumTime - startTime <= 0)
					toBeRemoved.push(dunceNote);
				else
				{
					if (PlayStateChangeables.useDownscroll)
					{
						if (dunceNote.mustPress)
							dunceNote.y = (playerStrums.members[Math.floor(Math.abs(dunceNote.noteData))].y
								+ 0.45 * (startTime - dunceNote.strumTime) * FlxMath.roundDecimal(songScrollSpeed, 2))
								- dunceNote.noteYOff;
						else
							dunceNote.y = (strumLineNotes.members[Math.floor(Math.abs(dunceNote.noteData))].y
								+ 0.45 * (startTime - dunceNote.strumTime) * FlxMath.roundDecimal(songScrollSpeed, 2))
								- dunceNote.noteYOff;
					}
					else
					{
						if (dunceNote.mustPress)
							dunceNote.y = (playerStrums.members[Math.floor(Math.abs(dunceNote.noteData))].y
								- 0.45 * (startTime - dunceNote.strumTime) * FlxMath.roundDecimal(songScrollSpeed, 2))
								+ dunceNote.noteYOff;
						else
							dunceNote.y = (strumLineNotes.members[Math.floor(Math.abs(dunceNote.noteData))].y
								- 0.45 * (startTime - dunceNote.strumTime) * FlxMath.roundDecimal(songScrollSpeed, 2))
								+ dunceNote.noteYOff;
					}
				}
			}

			for (i in toBeRemoved)
				notes.members.remove(i);
		}

		// add(strumLine);

		camFollow = new FlxObject(camPos.x, camPos.y, 1, 1);

		camFollow.setPosition(camPos.x, camPos.y);

		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}

		add(camFollow);

		FlxG.camera.follow(camFollow, LOCKON, 0.04 * (30 / (cast(Lib.current.getChildAt(0), Main)).getFPS()));
		// camHUD.follow(camFollow, LOCKON, 0.04 * (30 / (cast(Lib.current.getChildAt(0), Main)).getFPS()));
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow.getPosition());

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;

		healthBarBG = new FlxSprite(0, FlxG.height * 0.9);

		// someone fix the new healthbars
		// i got ya brightfyre even if i have a respiratory disease
		// *coding through laptop go brrr*

		// edit: it doesnt work + it will look like ass (flxbars arent rounded soo)

		// IM GONNA ATTEMPT THIS SHIT !!!! - volv

		switch (curStage)
		{
			case 'field' | 'devilHall':
				healthBarBG.loadGraphic(Paths.image('healthBar'));
				healthBarBG.setGraphicSize(620, 28);
			case 'factory' | 'freaky-machine':
				healthBarBG.loadGraphic(Paths.image('healthBar'));
				healthBarBG.setGraphicSize(600, 36);
			case 'hall':
				healthBarBG.loadGraphic(Paths.image('healthbar/sanshealthbar3', 'preload'));
				// healthBarBG.setGraphicSize(560, 25);
			default:
				healthBarBG.loadGraphic(Paths.image('healthBar'));
				healthBarBG.setGraphicSize(600);
		}

		healthBarBG.updateHitbox();

		if (PlayStateChangeables.useDownscroll)
			healthBarBG.y = 50;

		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set(0, 0);
		if (((PlayStateChangeables.botPlay && MainMenuState.showcase) || !PlayStateChangeables.botPlay))
			add(healthBarBG);

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, 2);
		healthBar.scrollFactor.set(0, 0);

		if (healthBar != null)
		{
			switch (curStage)
			{
				case 'field' | 'devilHall':
					healthBar.y -= 18;
					if (PlayStateChangeables.useDownscroll)
						healthBar.y = 50;

				case 'factory' | 'freaky-machine':
					healthBar.y -= 18;
					if (PlayStateChangeables.useDownscroll)
						healthBar.y = 50;
			}
		}

		healthBar.width = Std.int(healthBarBG.width - 8);
		healthBar.height = Std.int(healthBarBG.height - 8);

		var p1:FlxColor;

		if (dad.curCharacter == 'bendyNightmare')
		{
			p1 = FlxColor.fromRGB(22, 22, 22);
		}
		else
		{
			p1 = FlxColor.fromRGB(8, 191, 212);
		}

		switch (dad.curCharacter)
		{
			case 'bendy' | 'bendyChase':
				p2 = FlxColor.fromRGB(22, 22, 22);
			case 'bendyNightmare':
				p2 = FlxColor.fromRGB(255, 204, 0);
			case 'sansNightmare':
				p2 = FlxColor.fromRGB(102, 255, 255);
			case 'cuphead' | 'angrycuphead':
				p2 = FlxColor.fromRGB(171, 22, 74);
			case 'sans' | 'sansScared' | 'sanswinter':
				p2 = FlxColor.fromRGB(37, 75, 120);
			case 'gose':
				p2 = FlxColor.WHITE;
			case 'papyrus':
				p2 = FlxColor.fromRGB(171, 22, 74);
			case 'cupheadNightmare':
				p2 = FlxColor.fromRGB(171, 22, 74);
			default:
				p2 = FlxColor.fromRGB(73, 73, 73);
		}
		healthBar.createFilledBar(p2, p1);
		if (((PlayStateChangeables.botPlay && MainMenuState.showcase) || !PlayStateChangeables.botPlay) && curStage != 'hall')
			add(healthBar);

		// overlaying healthbar or something idk (the way this is coded is fucking terrible i should clean it up sometime lmao)
		switch (curStage)
		{
			case 'field' | 'devilHall':
				healthBarBG.alpha = 0.0;
				healthBarBGOverlay = new FlxSprite(0, FlxG.height * 0.8565);
				healthBarBGOverlay.loadGraphic(Paths.image('healthbar/cuphealthbar', 'preload'));
				healthBarBGOverlay.y += 15;
				healthBar.y += 15;
				if (((PlayStateChangeables.botPlay && MainMenuState.showcase) || !PlayStateChangeables.botPlay))
					add(healthBarBGOverlay);
				healthBarBGOverlay.updateHitbox();

				if (PlayStateChangeables.useDownscroll)
				{
					healthBarBGOverlay.y = 30;
					healthBar.y = 45;
				}

				healthBarBGOverlay.screenCenter(X);
				healthBarBGOverlay.scrollFactor.set(0, 0);

			case 'factory' | 'freaky-machine':
				healthBarBG.alpha = 0.0;
				healthBarBGOverlay = new FlxSprite(0, FlxG.height * 0.77);
				healthBarBGOverlay.loadGraphic(Paths.image('healthbar/bendyhealthbar', 'preload'));
				if (((PlayStateChangeables.botPlay && MainMenuState.showcase) || !PlayStateChangeables.botPlay))
					add(healthBarBGOverlay);
				healthBarBGOverlay.updateHitbox();

				if (PlayStateChangeables.useDownscroll)
					healthBarBGOverlay.y = -27;

				healthBarBGOverlay.screenCenter(X);
				healthBarBGOverlay.scrollFactor.set(0, 0);

			case 'hall':
				healthBarBG.x -= 16;
				healthBarBGOverlay = new FlxSprite(0, FlxG.height * 0.77);
				healthBarBGOverlay.loadGraphic(Paths.image('healthbar/sanshealthbar1', 'preload'));
				healthBarBGOverlay.y += 94;
				if (((PlayStateChangeables.botPlay && MainMenuState.showcase) || !PlayStateChangeables.botPlay))
					add(healthBarBGOverlay);
				healthBarBGOverlay.updateHitbox();

				if (PlayStateChangeables.useDownscroll)
					healthBarBGOverlay.y = 50;

				//healthBarBGOverlay.screenCenter(X);
				healthBarBGOverlay.scrollFactor.set(0, 0);
				healthBarBGOverlay.x = healthBarBG.x - 123;
				healthMax = new FlxSprite(healthBarBGOverlay.x, healthBarBGOverlay.y);
				healthMax.loadGraphic(Paths.image('healthbar/sanshealthbar2', 'preload'));
				if (((PlayStateChangeables.botPlay && MainMenuState.showcase) || !PlayStateChangeables.botPlay))
					add(healthMax);
				healthBarBGOverlay.updateHitbox();

				if (PlayStateChangeables.useDownscroll)
					healthMax.y = 50;
				healthMax.screenCenter(X);
				healthMax.scrollFactor.set(0, 0);
				healthMax.cameras = [camHUD];

				if (((PlayStateChangeables.botPlay && MainMenuState.showcase) || !PlayStateChangeables.botPlay))
					add(healthBarBGOverlay);
				healthBar = new FlxBar(healthBarBG.x, healthBarBG.y, LEFT_TO_RIGHT, Std.int(healthBarBG.width), Std.int(healthBarBG.height), this,
					'health', 0, 2);
				healthBar.createFilledBar(0x00FFFFFF, FlxColor.YELLOW);

				//healthBarBG.alpha = 0.0;

				krBar = new FlxBar(healthBar.x, healthBar.y, LEFT_TO_RIGHT, Std.int(healthBar.width), Std.int(healthBar.height), this,
				'kr', 0,2); 
				krBar.scrollFactor.set(0, 0);
				krBar.createFilledBar(FlxColor.RED, 0xFFff00ff);
				krBar.cameras = [camHUD];

				if (((PlayStateChangeables.botPlay && MainMenuState.showcase) || !PlayStateChangeables.botPlay))
					add(krBar);
					add(healthBar); // add the healthbar OVER this bg
		}

		if (FlxG.save.data.songPosition) // I dont wanna talk about this code :(
		{
			songPosBG = new FlxSprite(0, 10).loadGraphic(Paths.image('healthBar'));
			if (PlayStateChangeables.useDownscroll)
				songPosBG.y = FlxG.height * 0.9 + 45;
			songPosBG.screenCenter(X);
			songPosBG.scrollFactor.set(0, 0);
			add(songPosBG);

			if (SONG.song.toLowerCase() == 'imminent-demise') // for ppl with song position on, create a fake max timer for the first-half
			{
				songPosBar = new FlxBar(songPosBG.x + 4, songPosBG.y + 4, LEFT_TO_RIGHT, Std.int(songPosBG.width - 8), Std.int(songPosBG.height - 8), this,
					'songPositionBar', 0, songLength);
				songPosBar.scrollFactor.set(0, 0);
				songPosBar.createFilledBar(FlxColor.GRAY, p2);
				add(songPosBar);

				songPosBarPreDemise = new FlxBar(songPosBG.x + 4, songPosBG.y + 4, LEFT_TO_RIGHT, Std.int(songPosBG.width - 8), Std.int(songPosBG.height - 8),
					this, 'songPositionBar', 0, (songLength * 0.42));
				songPosBarPreDemise.scrollFactor.set(0, 0);
				songPosBarPreDemise.createFilledBar(FlxColor.GRAY, p2);
				add(songPosBarPreDemise);
			}
			else
			{
				songPosBar = new FlxBar(songPosBG.x + 4, songPosBG.y + 4, LEFT_TO_RIGHT, Std.int(songPosBG.width - 8), Std.int(songPosBG.height - 8), this,
					'songPositionBar', 0, songLength);
				songPosBar.scrollFactor.set(0, 0);
				songPosBar.createFilledBar(FlxColor.GRAY, p2);
				add(songPosBar);
			}

			var songName = new FlxText(songPosBG.x + (songPosBG.width / 2) - (SONG.song.length * 5), songPosBG.y, 0, SONG.song, 16);
			if (PlayStateChangeables.useDownscroll)
				songName.y -= 3;
			songName.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			songName.font = HelperFunctions.returnHudFont(songName);
			songName.scrollFactor.set(0, 0);
			add(songName);
			songName.cameras = [camHUD];
		}

		if (SONG.song.toLowerCase() == 'technicolor-tussle'
			|| SONG.song.toLowerCase() == 'knockout'
			|| SONG.song.toLowerCase() == 'devils-gambit')
		{
			cardbar = new FlxBar(0, 0, TOP_TO_BOTTOM, 97, 144, this, 'cardfloat', 0, 200);
			cardbar.scrollFactor.set(0, 0);
			cardbar.x = healthBarBG.x + 670;
			cardbar.y = healthBarBG.y + 15;
			cardbar.cameras = [camHUD];
			cardbar.createImageEmptyBar(Paths.image('cardempty', 'cup'), FlxColor.WHITE);
			cardbar.createImageFilledBar(Paths.image('cardfull', 'cup'), FlxColor.WHITE);
			add(cardbar);

			cardanims = new FlxSprite();
			cardanims.frames = Paths.getSparrowAtlas('Cardcrap', 'cup');
			cardanims.x = healthBarBG.x + 665;
			cardanims.y = healthBarBG.y - 67 - (100 / 1.5) + 5;
			cardanims.animation.addByPrefix('parry', 'PARRY Card Pop out  instance 1', 24, false);
			cardanims.animation.addByPrefix('pop', "Card Normal Pop out instance 1", 24, false);
			cardanims.animation.addByPrefix('use', "Card Used instance 1", 24, false);
			cardanims.animation.play('pop', true);
			cardanims.alpha = 0.0001;
			cardanims.antialiasing = true;
			cardanims.scrollFactor.set(0, 0);
			cardanims.cameras = [camHUD];
			add(cardanims);

			if (PlayStateChangeables.useDownscroll)
			{
				cardbary += 65;
				cardanims.y += 65;
			}
		}

		// Literally copy-paste of the above, fu
		botPlayState = new FlxText(healthBarBG.x + healthBarBG.width / 2 - 75, healthBarBG.y + (PlayStateChangeables.useDownscroll ? 100 : -100), 0,
			"BOTPLAY", 20);
		botPlayState.setFormat(Paths.font("vcr.ttf"), 42, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		botPlayState.font = HelperFunctions.returnHudFont(botPlayState);
		botPlayState.scrollFactor.set(0, 0);
		botPlayState.borderSize = 4;
		botPlayState.borderQuality = 2;
		botPlayState.cameras = [camHUD];
		if (PlayStateChangeables.botPlay && !MainMenuState.showcase)
			add(botPlayState);

		iconP1 = new HealthIcon(boyfriend.curCharacter, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		iconP1.scrollFactor.set(0, 0);
		if (((PlayStateChangeables.botPlay && MainMenuState.showcase) || !PlayStateChangeables.botPlay))
			add(iconP1);

		iconP2 = new HealthIcon(dad.curCharacter, false);

		if (SONG.song.toLowerCase() == 'bonedoggle' && player3.curCharacter == 'sanswinter')
			iconP2 = new HealthIcon('papyrusandsans', false);

		if (SONG.song.toLowerCase() == 'imminent-demise')
			iconP2 = new HealthIcon('bendyDA', false);

		iconP2.y = healthBar.y - (iconP2.height / 2);
		iconP2.scrollFactor.set(0, 0);
		if (((PlayStateChangeables.botPlay && MainMenuState.showcase) || !PlayStateChangeables.botPlay))
			add(iconP2);

		if (SONG.song.toLowerCase() == 'imminent-demise')
		{
			iconP2alt = new HealthIcon('bendy', false);
			iconP2alt.x -= 5;
			iconP2alt.y = healthBar.y - (iconP2alt.height / 2);
			iconP2alt.scrollFactor.set(0, 0);
			iconP2alt.visible = false;
			if (((PlayStateChangeables.botPlay && MainMenuState.showcase) || !PlayStateChangeables.botPlay))
				add(iconP2alt);
		}

		switch (dad.curCharacter)
		{
			case 'sansNightmare':
				iconYOffset -= 15;
			case 'sans' | 'sansScared' | 'sanswinter':
				iconYOffset -= 30;
				iconXOffset += 15;
			case 'angrycuphead' | 'cuphead':
				iconYOffset += 5;
				iconXOffset -= 30;
			case 'bendy' | 'bendyChase':
				iconYOffset -= 5;
			case 'bendyNightmare':
				iconXOffset -= 10;
				iconYOffset -= 10;
			case 'papyrus':
				iconXOffset -= 20;
			case 'papyrusandsans':
				iconYOffset -= 10;
			case 'devilFull':
				iconXOffset -= 5;
				iconYOffset -= 18;
		}

		iconP2.y += iconYOffset;

		if (iconP2.animOffsets.exists('loss'))
		{
			icon2AnimArray[0] = true;
		}
		if (iconP2.animOffsets.exists('win'))
		{
			icon2AnimArray[1] = true;
		}

		if (curStage == 'hall')
		{
			iconP1.visible = false;
			iconP2.visible = false;
		}

		scoreTxt = new FlxText(FlxG.width / 2 - 235, healthBarBG.y + 44, 0, "", 20);
		originalX = scoreTxt.x;
		scoreTxt.scrollFactor.set(0, 0);
		scoreTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreTxt.font = HelperFunctions.returnHudFont(scoreTxt);
		scoreTxt.screenCenter(X);
		scoreTxt.updateHitbox();
		add(scoreTxt);

		strumLineNotes.cameras = [camHUD];
		altStrumLineNotes.cameras = [camHUD];
		notes.cameras = [camHUD];

		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		if (healthBarBGOverlay != null)
			healthBarBGOverlay.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		laneunderlay.cameras = [camHUD];
		laneunderlayOpponent.cameras = [camHUD];
		laneunderlayOpponent2.cameras = [camHUD];

		if (FlxG.save.data.songPosition)
		{
			songPosBG.cameras = [camHUD];
			songPosBar.cameras = [camHUD];
			if (songPosBarPreDemise != null)
				songPosBarPreDemise.cameras = [camHUD];
		}

		if (SONG.song.toLowerCase() == 'technicolor-tussle'
			|| SONG.song.toLowerCase() == 'knockout'
			|| SONG.song.toLowerCase() == 'devils-gambit')
		{
			// attackMeter.cameras = [camHUD];
			cardanims.cameras = [camHUD];
		}

		if (SONG.song.toLowerCase() == 'imminent-demise')
			iconP2alt.cameras = [camHUD];

		startingSong = true;

		if (curStage == 'hall')
		{
			if (SONG.song.toLowerCase() == 'final-stretch')
			{
				waterFallEvent();
				waterFallEvent();
			}
			else if (SONG.song.toLowerCase() == 'sansational' || SONG.song.toLowerCase() == 'burning-in-hell')
			{
				transToCombatUI();
				transToSansStage();
			}
		}

		var suffix:String = '';
		if (geno)
		{
			suffix = 'b';
		}

		if (isStoryMode)
		{
			// sans dialogue code stuff
			if (curStage == 'hall')
			{
				trace('sans cutscene shit');

				if (!playCutscene && SONG.song.toLowerCase() == 'burning-in-hell')
				{
					camDialogue.fade(FlxColor.BLACK, 1, true, function()
					{
						var theDialogue:Array<String> = [];

						if (mechanicsEnabled)
						{
							switch (deathCount)
							{
								case 1:
									theDialogue = [
										'Bring It.:noeyes:eye--0.6:',
										'...:normal:none',
										'you look frustrated about something:normal:none',
										'looks like you doubled down a little too hard:funne:none',
										"guess i'm pretty good at my job, huh?:noeyes:none"
									];
								case 2:
									theDialogue = [
										'hmm:normal:none:',
										'that expression...:normal:none:',
										"that's the expression of someone who's died twice in a row.:gay:none:",
										"suffice to say, you look really...:wink:none:",
										"unsatisfied:wink:none:",
										"how 'bout we make it a third:noeyes:eye--0.6:"
									];
								case 3:
									theDialogue = [
										'hmm:normal:none:',
										'that expression...:normal:none:',
										"that's the expression of someone who's died thrice in a row.:gay:none:",
										"...:wink:none:",
										'hey, what comes after "thrice", anyway?:gay:none:',
										"let's find out:noeyes:eye--0.6:"
									];
								case 4:
									theDialogue = [
										'hmm:normal:none:',
										'that expression...:normal:none:',
										"that's the expression of someone who's died quice in a row.:gay:none:",
										"quice?:gay:none:",
										"frice?:gay:none:",
										"welp, won't need to use it again anyways:noeyes:eye--0.6:"
									];
								case 5:
									theDialogue = [
										'hmm:normal:none:',
										'that expression...:normal:none:',
										"that's the expression of someone who's died five times in a row.:gay:none:",
										"that's one for each finger:wink:none:",
										"but soon...:eyesclosed:none:"
									];
								case 6:
									theDialogue = [
										'hmm:normal:none:',
										'that expression...:normal:none:',
										"that's the expression of someone who's died six times in a row.:gay:none:",
										"that's the number of fingers on a mutant hand:wink:none:",
										"but soon...:eyesclosed:none:"
									];
								case 7:
									theDialogue = [
										'hmm:normal:none:',
										'that expression...:normal:none:',
										"that's the expression of someone who's died seven times in a row.:gay:none:",
										"hey, that's good:normal:none:",
										"seven's supposed to be a lucky number.:normal:none:",
										"who knows, maybe you'll hit the jackpot:wink:none:"
									];
								case 8:
									theDialogue = [
										'hmm:normal:none:',
										'that expression...:normal:none:',
										"that's the expression of someone who's died eight times in a row.:gay:none:",
										"that's the number of fingers on a spider:normal:none:",
										"but soon...:eyesclosed:none:"
									];
								case 9:
									theDialogue = [
										'hmm:normal:none:',
										'that expression...:normal:none:',
										"that's the expression of someone who's died seven times in a row.:gay:none:",
										"...:gay:none:",
										"nope, wait, that's definitely nine, sorry:wink:none:",
										"or was it ten?:noeyes:eye--0.6:"
									];
								case 10:
									theDialogue = [
										'hmm:normal:none:', 'that expression...:normal:none:',
										"that's the expression of someone who's died ten times in a row.:gay:none:", "hey, congrats!:wink:none:",
										"the big one-oh!:wink:none:", "lets invite all your friends over:gay:none:",
										"we can have pie, and hot dogs, and...:wink:none:", "hmmm... wait.:eyesclosed:none:",
										"something's not right.:eyesclosed:none:", "you don't have any friends.:noeyes:none:"
									];
								case 11:
									theDialogue = [
										'hmm:normal:none:',
										'that expression...:normal:none:',
										"that's the expression of someone who's died eleven times in a row.:gay:none:",
										"well, give or take.:wink:none:",
										"there's nuance to this stuff.:gay:none:",
										"don't think i'll be able to count from here.:wink:none:",
										"count for me, ok?:gay:none:",
										"we'll start from 12:noeyes:eye--0.6:"
									];
								default:
									theDialogue = ["let's just get to the point.:noeyes:none:"];
							}
						}
						else
						{
							switch (deathCount)
							{
								case 1:
									theDialogue = [
										'Ah.:noeyes:none:',
										'You need a handicap to beat me?:noeyes:none:',
										'Very Funny.:noeyes:none:'
									];
								case 2:
									theDialogue = [
										'Even with that big of an advantage.:noeyes:none:',
										"You still don't have what it takes to kill me.:noeyes:none:"
									];
								case 20:
									theDialogue = [
										'there I go breaking the fourth wall again:normal:none:',
										"probably a joke to be made about that.:funne:none:"
									];
								default:
									theDialogue = ["let's just get to the point, cheater.:noeyes:none:"];
							}
						}

						sansTalking = true;
						var dialogue = new SansDialogueBox(theDialogue);
						dialogue.cameras = [camDialogue];
						add(dialogue);
						dialogue.finishThing = function()
						{
							if (SONG.song.toLowerCase() == 'burning-in-hell')
							{
								lastUpdatedPos = Math.floor(FlxG.sound.music.time);
								boyfriend.playAnim('attack', true);
								boyfriend.animation.finishCallback = function(name:String)
								{
									boyfriend.playAnim('idle', true);
								};
								boyfriend.playAnim('attack', true, false, 0, true);

								FlxG.sound.play(Paths.sound('Throw' + FlxG.random.int(1, 3), 'sans'));

								if (bfDodge != null)
								{
									bfDodge.alpha = 0.0001;
									boyfriend.alpha = 1;
								}

								new FlxTimer().start(0.375, function(tmr:FlxTimer)
								{
									dad.playAnim('miss', true);
									dad.playAnim('miss', true, false, 0, true);

									FlxG.sound.play(Paths.sound('dodge', 'sans'), 0.6);

									genocideShit();

									startCountdown();
									sansTalking = false;

									FlxG.camera.shake(0.005);
								});
							}
							else
							{
								startCountdown();
							}
						};
					});
				}
				else
				{
					camGame.visible = false;
					camHUD.visible = false;
					camOVERLAY.visible = false;

					checkCut((cutPrefix + '/' + storyIndex + suffix).toString(), function()
					{
						trace('b');
						camGame.visible = true;
						videoPlaying = false;
						if (cutsceneSpr != null) cutsceneSpr.visible = false;
						camDialogue.fade(FlxColor.BLACK, 1, true, function()
						{
							var theDialogue:Array<String> = [];

							switch (SONG.song.toLowerCase())
							{
								case 'whoopee':
									theDialogue = [
										'welcome to the underground:normal:none:',
										'how was your fall?:funne:none:',
										'...:gay:none:',
										'you know, i was hired to tear you to shreds:eyesclosed:none:',
										'and spread those pieces across 6 different suns.:noeyes:none:',
										'...:eyesclosed:none:',
										'after a few rounds of rap battling...:wink:none:',
										'for some reason...:funne:none:',
										'Ready yourself Human.:noeyes:none:'
									];
								case 'sansational':
									theDialogue = [
										'you see, i cant judge the book by its cover but...:normal:none:',
										'i know what happened with you and that cup guy.:gay:none:',
										"i'd say if you try to do the same with me...:eyesclosed:none:",
										'things wont turn out so well.:funne:none:',
										'up to you kid....:normal:none:',
										'No Pressure.:noeyes:none:'
									];
								case 'burning-in-hell':
									theDialogue = ['Bring It.:noeyes:eye--0.6:'];
								case 'final-stretch':
									theDialogue = [
										'im surprised you didnt try anything.:normal:none:',
										'i guess you learned something from last time...:wink:none:',
										'Lets finish this.:noeyes:none:'
									];
							}

							sansTalking = true;
							var dialogue = new SansDialogueBox(theDialogue);
							dialogue.cameras = [camDialogue];
							add(dialogue);
							dialogue.finishThing = function()
							{
								if (SONG.song.toLowerCase() == 'burning-in-hell')
								{
									lastUpdatedPos = Math.floor(FlxG.sound.music.time);
									boyfriend.playAnim('attack', true, false, 0, true);

									FlxG.sound.play(Paths.sound('Throw' + FlxG.random.int(1, 3), 'sans'));

									new FlxTimer().start(0.375, function(tmr:FlxTimer)
									{
										dad.playAnim('miss', true, false, 0, true);

										FlxG.sound.play(Paths.sound('dodge', 'sans'), 0.6);

										genocideShit();

										startCountdown();
										sansTalking = false;

										FlxG.camera.shake(0.005);
									});
								}
								else
								{
									startCountdown();
									sansTalking = false;
								}
							};
						});
					});
				}
			}
			else
			{
				if (FileSystem.exists(Paths.video(cutPrefix + '/' + storyIndex + suffix)))
				{
					camGame.visible = false;
					camHUD.visible = false;
					camOVERLAY.visible = false;

					checkCut((cutPrefix + '/' + storyIndex + suffix).toString(), startCountdown);
				}
				else
				{
					startCountdown();
				}
			}
		}
		else
		{
			if (SONG.song.toLowerCase() == 'devils-gambit')
			{
				brightSetup();
				camHUD.alpha = 0;
				inCutscene = true;

				FlxG.sound.play(Paths.sound('Lights_Turn_On'));
				defaultCamZoom += 0.3;

				new FlxTimer().start(0.8, function(tmr:FlxTimer)
				{
					FlxTween.tween(FlxG.camera, {zoom: oldDefaultCamZoom}, 2.5, {
						ease: FlxEase.quadInOut,
						onComplete: function(twn:FlxTween)
						{
							startCountdown();
							defaultCamZoom = oldDefaultCamZoom;
							camFollow.setPosition(camPos.x, camPos.y);
						}
					});
				});
			}
			else
			{
				startCountdown();
			}
		}

		switch (songLowercase)
		{
			case 'burning-in-hell' | 'bad-time':
				blaster = new FlxTypedGroup<FlxSprite>();
				add(blaster);
				var b:FlxSprite;
				b = new FlxSprite().loadGraphic(Paths.image('Gaster_blasterss', 'sans'));
				b.alpha = 0.0001;
				add(b);
		}

		defineSteps();
	}

	public static var songScrollSpeed:Float = 0;

	var cupTea:FlxSprite;

	public static var deathCount:Int = 0;

	function checkCut(vid:String = '', daCallback:Void->Void)
	{
		if (playCutscene)
		{
			playCutscene = false;

			var video:VideoHandler = new VideoHandler();
			video.finishCallback = daCallback;
			video.allowSkip = false;

			if (MainMenuState.debugTools)
			{
				trace('allowing skip');
				video.allowSkip = true;
			}
			else
			{
				switch (storyWeek)
				{
					case 0:
						if (FlxG.save.data.weeksbeat[0])
						{
							trace('allowing skip');
							video.allowSkip = true;
						}
					case 1:
						if (FlxG.save.data.weeksbeat[1])
						{
							if (geno)
							{
								if (FlxG.save.data.hasgenocided)
								{
									trace('allowing skip');
									video.allowSkip = true;
								}
							}
							else
							{
								if (FlxG.save.data.haspacifisted)
								{
									trace('allowing skip');
									video.allowSkip = true;
								}
							}
						}
					case 2:
						if (FlxG.save.data.weeksbeat[2])
						{
							trace('allowing skip');
							video.allowSkip = true;
						}
				}
			}

			canPause = false;

			cutsceneSpr = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
			add(cutsceneSpr);
			cutsceneSpr.cameras = [camSUBTITLES];
			camSUBTITLES.visible = true;
			video.playMP4(Paths.video(vid), false, cutsceneSpr, false, false, false);
			videoPlaying = true;

			new FlxTimer().start(0.10, function(tmr:FlxTimer) //keeps that white flash from happening
				{
					cutsceneSpr.color = FlxColor.WHITE;
				});

			var accessibilitySubtitles:FlxText;
			accessibilitySubtitles = new FlxText(0, FlxG.height - 84, 0, "Test", 32);
			accessibilitySubtitles.alpha = 0;
			accessibilitySubtitles.setFormat(Paths.font("Bronx.otf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			accessibilitySubtitles.scrollFactor.set();
			accessibilitySubtitles.screenCenter(X);
			accessibilitySubtitles.borderSize = 1.5;
			accessibilitySubtitles.cameras = [camSUBTITLES];
			add(accessibilitySubtitles);

			switch (vid)
			{
				case "cuphead/1":
				{
					pushSubtitle('Hmm...', 10.583, 11.375, false);
					pushSubtitle("now if I were a crazy portal openin'", 11.375, 13.542, false);
					pushSubtitle('where would I be?', 13.542, 14.917, false);
					pushSubtitle("Well, it's no portal", 15.542, 16.833, false);
					pushSubtitle('but it looks like I found the screw loose!', 17.03, 19.04, false);
					pushSubtitle('Hey, busta!', 22.250, 23.125, false);
					pushSubtitle("You got a lotta nerve messin' with our land!", 23.125, 25.375, false);
					pushSubtitle('What say we settle this here and now?', 25.375, 28.08, false);
					pushSubtitle('Beep!', 30.45, 31.167, false);
				}
				case "cuphead/2":
				{
					pushSubtitle('Aw, blast!', 0.54, 1.41, false);
					pushSubtitle('This is gonna be tougher than I thought.', 1.41, 3.208, false);
					pushSubtitle("Looks like I'm gonna have to...", 3.208, 4.667, false);
					pushSubtitle('double down!', 4.66, 5.667, false);
					pushSubtitle('Hey! Do you need any help, Cuphead?', 5.667, 7.292, false);
					pushSubtitle('Nah, I got this, bro!', 7.292, 8.708, false);
					pushSubtitle('Go see if you can find Ms. Chalice lady for us, yeah?', 8.708, 10.958, false);
					pushSubtitle('You got it! But please, Cuphead...', 10.958, 12.792, false);
					pushSubtitle('No. More. Violence!', 12.792, 14.667, false);
					pushSubtitle("I'll be back before ya even know it!", 15.0, 16.833, false);
					pushSubtitle('Hopefully not too soon.', 17.625, 19.333, false);
					pushSubtitle("He doesn't do too well with damage", 19.333, 21.125, false);
					pushSubtitle('Now, where were we?', 21.125, 22.333, false);
					pushSubtitle('Oh, yeah!', 22.333, 23.375, false);
					pushSubtitle("Let's double down!", 23.375, 24.667, false);
					pushSubtitle('Beep!', 27.417, 28.125, false);
				}
				case "cuphead/3":
				{
					pushSubtitle('Argh...', 10.458, 10.792, false);
					pushSubtitle('nuts to this!', 10.792, 12.167, false);
					pushSubtitle('Ugh...', 12.167, 12.875, false);
					pushSubtitle('What did my brother say?', 12.875, 14.417, false);
					pushSubtitle('Now remember, bro!', 14.417, 15.458, false);
					pushSubtitle('No. More. Violence!', 15.458, 17.083, false);
					pushSubtitle("Unless it's a boy with a red cap, blue hair and white shirt...", 17.083, 20.000, false);
					pushSubtitle("then uh go frickin' wild!", 20.000, 21.208, false);
					pushSubtitle('Oh, yeah!', 21.208, 21.917, false);
					pushSubtitle("Good ol' reliable Mugman!", 21.917, 24.125, false);
					pushSubtitle('Alright Kid, you asked for this!', 24.125, 25.958, false);
					pushSubtitle('Time to go full triple down on your ass!', 25.958, 29.625, false);
					pushSubtitle('Beep!', 32.583, 33.167, false);
				}
				case "bendy/2":
				{
					pushSubtitle('Sheep, sheep, sheep...', 0.250, 2.208, false);
					pushSubtitle("It's time...", 2.208, 3.417, false);
					pushSubtitle("My lord!", 6.083, 7.083, false);
					pushSubtitle("Hm?! What the...?", 8.958, 10.542, false);
					pushSubtitle("Hm.. I see.", 12.667, 14.500, false);
					pushSubtitle("There's only one way to put an end to this", 14.500, 16.958, false);
					pushSubtitle("though it's not gonna be pleasant.", 16.958, 19.542, false);
					pushSubtitle("What the ****?!", 19.542, 21.667, false);
				}
				case "bendy/3":
				{
					pushSubtitle('Not bad...', 0.458, 1.875, false);
				}			
			}

			
		}
		else
		{
			cutsceneOver();
		}
	}

	function pushSubtitle(text:String, occurTime:Float, endTime:Float, isInGame:Bool)
		{
			new FlxTimer().start(occurTime, function(tmr:FlxTimer)
				{
					var accessibilitySubtitles:FlxText;
					accessibilitySubtitles = new FlxText(0, FlxG.height - 64, 0, text, 32);
					accessibilitySubtitles.alpha = 1.0;
					accessibilitySubtitles.setFormat(Paths.font("Bronx.otf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
					accessibilitySubtitles.scrollFactor.set();
					accessibilitySubtitles.screenCenter(X);
					accessibilitySubtitles.borderSize = 1.5;
					accessibilitySubtitles.cameras = [camSUBTITLES];
					add(accessibilitySubtitles);
					if (isInGame)
						{
						accessibilitySubtitles.alpha = 0.0;
						camSUBTITLES.visible = true;
						accessibilitySubtitles.y -= 140;
						FlxTween.tween(accessibilitySubtitles, {alpha: 1}, 0.25, {ease: FlxEase.quadInOut});
					}
					
					new FlxTimer().start(endTime - occurTime, function(tmr:FlxTimer)
						{
							if (isInGame)
								{
									if (accessibilitySubtitles != null) FlxTween.tween(accessibilitySubtitles, {alpha: 0.0}, 0.25, {ease: FlxEase.quadInOut, onComplete: function(twn:FlxTween){camSUBTITLES.visible = false; remove(accessibilitySubtitles);}});
								}
							else
								{
									if (accessibilitySubtitles != null) remove(accessibilitySubtitles);
								}
						});
				});
		}

	function brightSetup()
	{
		if (curStage == 'factory' && (!FlxG.save.data.photosensitive && FlxG.save.data.highquality))
		{
			if (fuckinAngry)
			{
				defaultBrightVal = -0.05;
				brightSpeed = 0.2;
				brightMagnitude = 0.05;
			}
			else
			{
				if (SONG.song.toLowerCase() == 'ritual')
				{
					defaultBrightVal = -0.05;
					brightSpeed = 0.5;
					brightMagnitude = 0.05;
				}
				else
				{
					if (SONG.song.toLowerCase() == 'nightmare-run')
					{
						defaultBrightVal = -0.05;
						brightSpeed = 0.5;
						brightMagnitude = 0.05;
					}
					else if (SONG.song.toLowerCase() == 'imminent-demise')
					{
						defaultBrightVal = 0;
					}
					else
					{
						defaultBrightVal = -0.05;
						brightSpeed = 0.5;
						brightMagnitude = 0.05;
					}
				}
			}
		}
		else if (SONG.song.toLowerCase() == 'devils-gambit')
		{
			defaultBrightVal = -0.05;
			brightSpeed = 0.2;
			brightMagnitude = 0.05;
		}
		else if (SONG.song.toLowerCase() == 'burning-in-hell')
		{
			defaultBrightVal = -0.04;
			brightSpeed = 0.1;
			brightMagnitude = 0.04;
		}
		else
		{
			defaultBrightVal = 0;
		}
	}

	override public function draw():Void
	{
		super.draw();
	}

	function cutsceneOver():Void
	{
		FlxG.camera.fade(FlxColor.BLACK, 0, true);
		videoPlaying = false;
		startCountdown();
	}

	var startTimer:FlxTimer;
	var perfectMode:Bool = false;

	#if cpp
	public static var luaModchart:ModchartState = null;
	#else
	public static var luaModchart:Dynamic;
	#end

	var countdownNarrator:FlxSound;

	var hasBendyTitleIntro:Bool = false;

	function cupteaPlay()
	{
		cupTea.alpha = 1;
		cupTea.animation.play('start', true);
		cupTea.animation.finishCallback = function(name)
		{
			cupTea.alpha = 0.00001;
		}
	}

	function cupteaBackout()
	{
		cupTea.alpha = 1;
		cupTea.animation.play('start', true, true);
	}

	var wallop:FlxSprite;

	function startCountdown():Void
	{
		bumpRate = 4;

		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, handleInput);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, releaseInput);

		if (cutsceneSpr != null) cutsceneSpr.visible = false;

		camSUBTITLES.visible = false;

		if (mechInstructMusic != null)
		{
			mechInstructMusic.play();
		}

		checkFocus(false);

		if (SONG.song.toLowerCase() != 'devils-gambit')
		{
			brightSetup();
		}
		else
		{
			FlxTween.tween(camHUD, {alpha: 1}, 2, {ease: FlxEase.quadInOut});
		}

		videoPlaying = false;

		checkHiddenChars();

		if (!hasInstruction)
		{
			var controlsOverlay = new ControlsOverlay();
			controlsOverlay.scrollFactor.set();
			controlsOverlay.cameras = [camOVERLAY];
			add(controlsOverlay);
			controlsOverlay.fade();
			
			camGame.visible = true;
			camHUD.visible = true;
			camOVERLAY.visible = true;

			inCutscene = false;

			canPause = false;

			#if cpp
			// pre lowercasing the song name (startCountdown)
			if (executeModchart)
			{
				luaModchart = ModchartState.createModchartState();
				luaModchart.executeState('start', [songLowercase]);
			}
			#end

			talking = false;
			startedCountdown = true;
			Conductor.songPosition = 0;

			if (mechInstructions == null)
			{
				if (curStage == 'field' || curStage == 'devilHall')
				{
					if (SONG.song.toLowerCase() != 'devils-gambit')
					{
						cupteaPlay();
					}
				}
			}

			if (cup && SONG.song.toLowerCase() != "devils-gambit")
			{
				wallop = new FlxSprite();
				wallop.frames = Paths.getSparrowAtlas('ready_wallop', 'cup');
				wallop.animation.addByPrefix('start', "Ready? WALLOP!", 24, false);
				wallop.setGraphicSize(Std.int(wallop.width * 0.8));
				wallop.updateHitbox();
				wallop.screenCenter();
				wallop.antialiasing = FlxG.save.data.highquality;
				wallop.scrollFactor.set();
				wallop.cameras = [camHUD];
				wallop.alpha = 0.00001;
				add(wallop);

				new FlxTimer().start(1.1, function(tmr:FlxTimer)
				{
					wallop.alpha = 1;
					wallop.animation.play('start', true);
					wallop.animation.finishCallback = function(name)
					{
						wallop.destroy();
						remove(wallop);
					}
				});

				if (SONG.song.toLowerCase() != 'knockout')
				{
					var rando:Int = FlxG.random.int(0, 4);
					countdownNarrator = new FlxSound().loadEmbedded(Paths.sound('intros/normal/' + rando, 'cup'));
					countdownNarrator.play();
				}
				else
				{
					var rando:Int = FlxG.random.int(0, 1);
					countdownNarrator = new FlxSound().loadEmbedded(Paths.sound('intros/angry/' + rando, 'cup'));
					countdownNarrator.play(); // i didnt knew why intro wasnt played then i figured out how dumb i am sometimes
				}

				FlxG.sound.music.fadeIn(3, 0.5, 1);

				if (mechInstructions == null)
				{
					canPause = true;
				}

				if (dad.curCharacter == 'devilFull')
				{
					new FlxTimer().start(0.25, function(tmr:FlxTimer)
					{
						devilIntroSpr.alpha = 1.0;
						dad.alpha = 0.0001;
						devilIntroSpr.animation.play('start', true);

						devilIntroSpr.animation.finishCallback = function(name:String)
						{
							devilIntroSpr.alpha = 0.0001;
							dad.alpha = 1;
						}
					});
				}
			}
			else
			{
				Conductor.songPosition -= Conductor.crochet * 5;

				var swagCounter:Int = 0;

				startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
				{
					var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
					introAssets.set('default', ['ready', "set", "go"]);

					var introAlts:Array<String> = introAssets.get('default');

					var path:String = 'shared';
					if (curStage == 'factory')
					{
						path = "bendy";
					}

					if (hasBendyTitleIntro && swagCounter == 0)
					{
						canPause = false;

						var songTitle:FlxSprite = new FlxSprite();

						switch (SONG.song.toLowerCase())
						{
							case 'imminent-demise':
								songTitle.loadGraphic(Paths.image('introductionsong1', 'bendy'));

							case 'terrible-sin':
								songTitle.loadGraphic(Paths.image('introductionsong2', 'bendy'));

							case 'last-reel':
								songTitle.loadGraphic(Paths.image('introductionsong3', 'bendy'));

							case 'nightmare-run':
								songTitle.loadGraphic(Paths.image('introductionsong4', 'bendy'));

							case 'ritual':
								songTitle.loadGraphic(Paths.image('introductionbonus2', 'bendy'));

							case 'freaky-machine':
								songTitle.loadGraphic(Paths.image('introductionbonus', 'bendy'));

							case 'despair':
								songTitle.loadGraphic(Paths.image('introductiondespair', 'bendy'));
						}

						songTitle.scrollFactor.set();
						songTitle.updateHitbox();
						songTitle.screenCenter();
						songTitle.cameras = [camOVERLAY];
						songTitle.scale.x = 0.75;
						songTitle.scale.y = songTitle.scale.x;
						songTitle.antialiasing = true;
						songTitle.alpha = 0.0;
						add(songTitle);

						new FlxTimer().start(0.25, function(tmr:FlxTimer)
						{
							FlxG.sound.play(Paths.sound('whoosh', 'bendy'));
						});
						FlxTween.tween(songTitle, {alpha: 1}, 1, {ease: FlxEase.quadOut});
						FlxTween.tween(songTitle.scale, {x: 1.1, y: 1.1}, 6);

						new FlxTimer().start(1, function(tmr:FlxTimer)
						{
							var duration:Float = 0.8;
							if (SONG.song.toLowerCase() == 'freaky-machine')
							{
								duration = 8; // It should look better now :D
							}
							FlxTween.tween(bendyIntroOverlay, {alpha: 0}, duration, {ease: FlxEase.quadIn});
						});

						new FlxTimer().start(3, function(tmr:FlxTimer)
						{
							FlxTween.tween(songTitle, {alpha: 0}, 2.0, {ease: FlxEase.quadOut});
							if (SONG.song.toLowerCase() != 'ritual')
							{
								canPause = true;
							}
						});
					}

					if (!hasBendyTitleIntro)
					{
						switch (swagCounter)
						{
							case 0:
								if (curStage == 'hall' || curStage == 'papyrus')
								{
									FlxG.sound.play(Paths.sound('countdown', 'sans'), 0.6);
								}
								else
								{
									FlxG.sound.play(Paths.sound('intro3'), 0.6);
								}

								bop();
							case 1:
								var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[0], path));
								ready.antialiasing = FlxG.save.data.highquality;
								ready.scrollFactor.set();
								ready.updateHitbox();
								ready.cameras = [camHUD];
								ready.screenCenter();
								add(ready);
								FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
									ease: FlxEase.cubeInOut,
									onComplete: function(twn:FlxTween)
									{
										ready.destroy();
									}
								});
								if (curStage == 'hall' || curStage == 'papyrus')
								{
									FlxG.sound.play(Paths.sound('countdown', 'sans'), 1);
								}
								else
								{
									FlxG.sound.play(Paths.sound('intro2'), 0.6);
								}
								bop();

							case 2:
								var set:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[1], path));
								set.antialiasing = FlxG.save.data.highquality;
								set.scrollFactor.set();
								set.cameras = [camHUD];
								set.screenCenter();
								add(set);
								FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
									ease: FlxEase.cubeInOut,
									onComplete: function(twn:FlxTween)
									{
										set.destroy();
									}
								});
								if (curStage == 'hall' || curStage == 'papyrus')
								{
									FlxG.sound.play(Paths.sound('countdown', 'sans'), 1);
								}
								else
								{
									FlxG.sound.play(Paths.sound('intro1'), 0.6);
								}

								bop();
							case 3:
								var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[2], path));
								go.antialiasing = FlxG.save.data.highquality;
								go.scrollFactor.set();
								go.cameras = [camHUD];
								go.updateHitbox();
								go.screenCenter();
								add(go);
								FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
									ease: FlxEase.cubeInOut,
									onComplete: function(twn:FlxTween)
									{
										go.destroy();
									}
								});
								if (curStage == 'hall' || curStage == 'papyrus')
								{
									FlxG.sound.play(Paths.sound('countdown finish', 'sans'), 1);
								}
								else
								{
									FlxG.sound.play(Paths.sound('introGo'), 0.6);
								}

								canPause = true;
								bop();

							// FUCK
							//-brightfyre
							case 4:
								bop();

								if (SONG.song.toLowerCase() == 'sansational' || SONG.song.toLowerCase() == 'sansational')
								{
									attackHud.alpha = 1;
									dodgeHud.alpha = 1;
								}
						}
					}
					else
					{
						switch (swagCounter) // BENDY INTRO
						{
							case 0 | 1 | 2 | 4:
								bop();

							case 3:
								bop();
								canPause = true;
						}
					}

					swagCounter += 1;
					// generateSong('fresh');
				}, 5);

				if (dad.curCharacter == 'cuphead' && (SONG.song.toLowerCase() == 'snake-eyes' || !isStoryMode))
				{
					new FlxTimer().start(0.25, function(tmr:FlxTimer)
					{
						dad.playAnim('intro', false, false, 0, true);
					});
				}
			}

			// Conductor.songPosition -= Conductor.crochet * 5;

			songSprite = new FlxSprite().loadGraphic(Paths.image('musicBar', 'preload'));
			songSprite.updateHitbox();
			songSprite.cameras = [camHUD];
			songSprite.alpha = 0.7;
			songSprite.setPosition(FlxG.width, 497);
			add(songSprite);

			songText = new FlxText(0, 0, songSprite.width,
				HelperFunctions.getSongData(SONG.song.toLowerCase(), 'artist') + ' - ' + HelperFunctions.getSongData(SONG.song.toLowerCase(), 'name'), 15);
			songText.setPosition(songSprite.x, songSprite.getGraphicMidpoint().y - songText.height);
			songText.setFormat(HelperFunctions.returnHudFont(songText), 35);
			songText.cameras = [camHUD];
			songText.alpha = 0.7;
			songText.antialiasing = FlxG.save.data.highquality;
			add(songText);

			var swagCounter2:Int = 0;

			new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
			{
				switch (swagCounter2)
				{
					case 3:
						FlxTween.tween(songSprite, {x: FlxG.width - songSprite.width - 50}, 0.5, {ease: FlxEase.sineOut});
						FlxTween.tween(songText, {x: FlxG.width - songSprite.width}, 0.5, {ease: FlxEase.sineOut});
						canPause = true;
					case 13: // entre mas me la mamas mas me crece
						FlxTween.tween(songText, {x: FlxG.width}, 0.5, {ease: FlxEase.sineInOut});

						FlxTween.tween(songSprite, {x: FlxG.width}, 0.5, {
							ease: FlxEase.sineInOut,
							onComplete: function(tween:FlxTween)
							{
								remove(songSprite);
								remove(songText);
							}
						});
				}

				swagCounter2 += 1;
			}, 15);

			if (SONG.song.toLowerCase() == 'nightmare-run')
			{
				defaultCamZoom = 1.4;
				FlxTween.tween(this, {defaultCamZoom: oldDefaultCamZoom}, 5);

				focusedOnChar = true;
				camMovement.cancel();
				camFocus = 'bf';

				camMovement = FlxTween.tween(camFollow, {x: bfPos[0] + 200, y: bfPos[1]}, 0, {ease: FlxEase.quintOut});
			}
		}
		else
		{
			videoPlaying = false;
		}
	}

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	/** HERE THERE SOME SHIT THAT MAKES GAME CRASH WITH NO REASON
		I DONT UNDERSTAND THIS NOTE HANDLING SHIT IT JUST ANNOYS ME (conchetumadre kade)

		A GOOD REPRESENTATION OF THIS SITUATION WOULD BE THIS: https://i.kym-cdn.com/entries/icons/mobile/000/023/397/C-658VsXoAo3ovC.jpg
		i tried to fix this but no clue :(
		where is kade and his pull requests when you need them :(((((

			FUCKING ASS ENGINE

		-- because this wasn't ever used and was left over from an early implementation of openfl keybinds dumbass. don't use it lol
	**/
	var keys = [false, false, false, false];

	private function releaseInput(evt:KeyboardEvent):Void // handles releases
	{
		@:privateAccess
		var key = FlxKey.toStringMap.get(evt.keyCode);

		var binds:Array<String> = [
			FlxG.save.data.leftBind,
			FlxG.save.data.downBind,
			FlxG.save.data.upBind,
			FlxG.save.data.rightBind
		];

		var data = -1;

		switch (evt.keyCode) // arrow keys
		{
			case 37:
				data = 0;
			case 40:
				data = 1;
			case 38:
				data = 2;
			case 39:
				data = 3;
		}

		for (i in 0...binds.length) // binds
		{
			if (binds[i].toLowerCase() == key.toLowerCase())
				data = i;
		}

		keys[data] = false;
	}

	var inputSpacePressed:Bool = false;

	private function handleInput(evt:KeyboardEvent):Void
	{ // this actually handles press inputs

		if ((PlayStateChangeables.botPlay && !MainMenuState.showcase) || paused)
			return;

		// first convert it from openfl to a flixel key code
		// then use FlxKey to get the key's name based off of the FlxKey dictionary
		// this makes it work for special characters

		@:privateAccess
		var key = FlxKey.toStringMap.get(Keyboard.__convertKeyCode(evt.keyCode));

		var binds:Array<String> = [
			FlxG.save.data.leftBind,
			FlxG.save.data.downBind,
			FlxG.save.data.upBind,
			FlxG.save.data.rightBind
		];

		var data = -1;

		switch (evt.keyCode) // arrow keys
		{
			case 37:
				data = 0;
			case 40:
				data = 1;
			case 38:
				data = 2;
			case 39:
				data = 3;
		}

		for (i in 0...binds.length) // binds
		{
			if (binds[i].toLowerCase() == key.toLowerCase())
				data = i;
		}

		if (data == -1)
		{
			// BENDY THE BOYS ATTACK
			if ((SONG.song.toLowerCase() == "last-reel" && storyDifficulty >= 1) || SONG.song.toLowerCase() == "despair")
			{
				if (FlxG.save.data.attackLeftBind == 'SHIFT')
				{
					if (FlxG.save.data.attackRightBind == 'SHIFT')
					{
						if (evt.keyCode == 16)
						{
							switch (evt.keyLocation)
							{
								case KeyLocation.LEFT:
									trace("attack left that is shift shift");
									bfAttack(true);
								default:
									// bip rozo
							}
						}
					}
					else if (evt.keyCode == 16)
					{
						trace("attack left that is kinda shift");
						bfAttack(true);
					}
				}

				if (FlxG.save.data.attackRightBind == 'SHIFT')
				{
					if (FlxG.save.data.attackLeftBind == 'SHIFT')
					{
						if (evt.keyCode == 16)
						{
							switch (evt.keyLocation)
							{
								case KeyLocation.RIGHT:
									trace("attack right that is shift shift");
									bfAttack(false);
								default:
									// bip rozo
							}
						}
					}
					else if (evt.keyCode == 16)
					{
						trace("attack right that is kinda shift");
						bfAttack(false);
					}
				}
			}

			return;
		}

		if (keys[data])
		{
			return;
		}

		keys[data] = true;

		var dataNotes = [];
		if (notes != null && songStarted)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit && daNote.noteData == data)
					dataNotes.push(daNote);
			}); // Collect notes that can be hit
		}

		dataNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime)); // sort by the earliest note

		if (dataNotes.length != 0)
		{
			var coolNote = null;

			for (i in dataNotes)
			{
				coolNote = i;
				break;
			}

			if (dataNotes.length > 1) // stacked notes or really close ones
			{
				for (i in 0...dataNotes.length)
				{
					if (i == 0) // skip the first note
						continue;

					var note = dataNotes[i];

					if (!note.isSustainNote && ((note.strumTime - coolNote.strumTime) < 2) && note.noteData == data)
					{
						trace('found a stacked/really close note ' + (note.strumTime - coolNote.strumTime));
						// just fuckin remove it since it's a stacked note and shouldn't be there
						note.kill();
						notes.remove(note, true);
						note.destroy();
					}
				}
			}

			goodNoteHit(coolNote);
		}
		else if (!FlxG.save.data.ghost && songStarted && !utmode)
		{
			noteMiss(data, null);
			healthChange(-0.20);
		}
	}

	function bfAttack(left:Bool)
	{
		if (attackCooldown == 0 && !PlayStateChangeables.botPlay)
		{
			if (mechanicType != 0)
				attackCooldown = 3;
			else
				attackCooldown = 5;
			lastUpdatedPos = Math.floor(FlxG.sound.music.time);
			if (left)
			{
				boyfriend.playAnim("attackLeft", true, false, 0, true);
				if (currentStriker != null)
				{
					if (currentStriker.attacking)
					{
						hitStriker();
					}
				}
			}
			else
			{
				boyfriend.playAnim("attackRight", true, false, 0, true);
				if (currentPiper != null)
				{
					if (currentPiper.attacking)
					{
						hitPiper();
					}
				}
			}
		}
	}

	function hitStriker()
	{
		lastStrikerSpawn = Math.floor(FlxG.sound.music.time);
		currentStriker.swinging = false;
		currentStriker.hp--;
		if (currentStriker.hp == 0)
		{
			currentStriker.die();
		}
		else
		{
			currentStriker.hit();
		}
	}

	function hitPiper()
	{
		lastPiperSpawn = Math.floor(FlxG.sound.music.time);
		currentPiper.swinging = false;
		currentPiper.hp--;
		if (currentPiper.hp == 0)
		{
			currentPiper.die();
		}
		else
		{
			currentPiper.hit();
		}
	}

	var dodgeAmt:Int = 0;

	function bfMechDodge()
	{
		dodgeHud.useHUD();
		spaceCooldown = 1.6;
		inputSpacePressed = true;
		
		boyfriend.playAnim('dodge', true, false, 0, true);

		new FlxTimer().start(0.6, function(tmr:FlxTimer)
		{
			inputSpacePressed = false;
		});
	}

	var songStarted = false;

	public static var startTime = 0.0;

	function startSong():Void
	{
		startingSong = false;
		songStarted = true;
		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		// uhhhhh cock
		if (Main.hiddenSongs.contains(PlayState.SONG.song.toLowerCase()))
		{
			FlxG.sound.playMusic(Paths.instHidden(PlayState.SONG.song), 1, false);
		}
		else
		{
			FlxG.sound.music.play();
		}

		FlxG.sound.music.looped = false;

		if (vocals != null)
		{
			vocals.play();
		}

		FlxG.sound.music.volume = 1;

		FlxG.sound.music.time = startTime;
		if (vocals != null)
			vocals.time = startTime;
		Conductor.songPosition = startTime;
		startTime = 0;

		allowedToHeadbang = false;

		#if cpp
		// Updating Discord Rich Presence (with Time Left)
			var disSong:String = SONG.song;
			if (HelperFunctions.shouldBeHidden(SONG.song.toLowerCase()))
				disSong = '[CONFIDENTIAL]';
		DiscordClient.changePresence(detailsText
			+ " "
			+ disSong
			+ " ("
			+ storyDifficultyText
			+ ") "
			+ Ratings.GenerateLetterRank(accuracy),
			"\nAcc: "
			+ HelperFunctions.truncateFloat(accuracy, 2)
			+ "% | Score: "
			+ songScore
			+ " | Misses: "
			+ misses, iconRPC);
		#end
	}

	var debugNum:Int = 0;

	private function generateSong(dataPath:String):Void
	{
		// FlxG.log.add(ChartParser.parse());

		// antiCheat();

		/*
			if (SONG.song.toLowerCase() == 'sansational')
			{
				sansPreload();
			}
		 */

		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.song;

		if (SONG.song.toLowerCase() == 'last-reel' && storyDifficulty == 0)
		{
			FlxG.sound.playMusic(Paths.instEasy(PlayState.SONG.song), 1, false);
		}
		else
		{
			if (!Main.hiddenSongs.contains(PlayState.SONG.song.toLowerCase()))
			{
				FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 1, false);
			}
		}

		FlxG.sound.music.volume = 0;

		if (SONG.song.toLowerCase() == 'last-reel' && storyDifficulty == 0)
		{
			vocals = new FlxSound().loadEmbedded(Paths.voicesEasy(PlayState.SONG.song));
		}
		else
		{
			if (Main.hiddenSongs.contains(PlayState.SONG.song.toLowerCase()))
			{
				vocals = new FlxSound().loadEmbedded(Paths.voicesHidden(PlayState.SONG.song));
			}
			else
			{
				vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
			}
		}

		if (isStoryMode
			&& ((SONG.song.toLowerCase() == "knockout"
				|| SONG.song.toLowerCase() == "final-stretch"
				|| SONG.song.toLowerCase() == "burning-in-hell"
				|| SONG.song.toLowerCase() == "nightmare-run") || 
				SONG.song.toLowerCase() == 'last-reel' && storyDifficultyText != 'Hard'))
		{
			FlxG.sound.music.onComplete = partyFinale;
			FlxG.sound.music.pause();
		}
		else
		{
			FlxG.sound.music.onComplete = partyIsOver;
			FlxG.sound.music.pause();
		}

		vocals.looped = false;

		FlxG.sound.list.add(vocals);

		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;

		if (FlxG.save.data.songPosition)
		{
			remove(songPosBG);
			remove(songPosBar);
			remove(songName);
			if (songPosBarPreDemise != null)
				remove(songPosBarPreDemise);

			songPosBG = new FlxSprite(0, 10).loadGraphic(Paths.image('healthBar'));
			if (PlayStateChangeables.useDownscroll)
				songPosBG.y = FlxG.height * 0.9 + 45;
			songPosBG.screenCenter(X);
			songPosBG.scrollFactor.set(0, 0);
			add(songPosBG);

			if (SONG.song.toLowerCase() == 'imminent-demise') // for ppl with song position on, create a fake max timer for the first-half
			{
				songPosBar = new FlxBar(songPosBG.x + 4, songPosBG.y + 4, LEFT_TO_RIGHT, Std.int(songPosBG.width - 8), Std.int(songPosBG.height - 8), this,
					'songPositionBar', 0, songLength);
				songPosBar.scrollFactor.set(0, 0);
				songPosBar.createFilledBar(FlxColor.GRAY, p2);
				add(songPosBar);

				songPosBarPreDemise = new FlxBar(songPosBG.x + 4, songPosBG.y + 4, LEFT_TO_RIGHT, Std.int(songPosBG.width - 8), Std.int(songPosBG.height - 8),
					this, 'songPositionBar', 0, (songLength * 0.42));
				songPosBarPreDemise.scrollFactor.set(0, 0);
				songPosBarPreDemise.createFilledBar(FlxColor.GRAY, p2);
				add(songPosBarPreDemise);
			}
			else
			{
				songPosBar = new FlxBar(songPosBG.x + 4, songPosBG.y + 4, LEFT_TO_RIGHT, Std.int(songPosBG.width - 8), Std.int(songPosBG.height - 8), this,
					'songPositionBar', 0, songLength);
				songPosBar.scrollFactor.set(0, 0);
				songPosBar.createFilledBar(FlxColor.GRAY, p2);
				add(songPosBar);
			}

			var songName = new FlxText(songPosBG.x + (songPosBG.width / 2) - (SONG.song.length * 5), songPosBG.y, 0, SONG.song, 16);
			if (PlayStateChangeables.useDownscroll)
				songName.y -= 3;
			songName.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			songName.font = HelperFunctions.returnHudFont(songName);
			songName.scrollFactor.set(0, 0);
			add(songName);

			songPosBG.cameras = [camHUD];
			songPosBar.cameras = [camHUD];
			if (songPosBarPreDemise != null)
				songPosBarPreDemise.cameras = [camHUD];
			songName.cameras = [camHUD];
		}

		notes = new FlxTypedGroup<Note>();

		add(notes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var playerCounter:Int = 0;

		// Per song offset check
		#if windows
		// pre lowercasing the song name (generateSong)

		var songPath = 'assets/data/' + songLowercase + '/';

		if (FileSystem.exists(songPath))
		{
			for (file in sys.FileSystem.readDirectory(songPath))
			{
				var path = haxe.io.Path.join([songPath, file]);
				if (!sys.FileSystem.isDirectory(path))
				{
					if (path.endsWith('.offset'))
					{
						songOffset = Std.parseFloat(file.substring(0, file.indexOf('.off')));
						break;
					}
					else
					{
						sys.io.File.saveContent(songPath + songOffset + '.offset', '');
					}
				}
			}
		}
		else
		{
			songOffset = 0;
		}
		#end
		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped
		for (section in noteData)
		{
			var coolSection:Int = Std.int(section.lengthInSteps / 4);

			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0] + FlxG.save.data.offset + songOffset;
				if (daStrumTime < 0)
					daStrumTime = 0;
				var daNoteData:Int = Std.int(songNotes[1]);
				var player3Note:Bool = false;

				var gottaHitNote:Bool = section.mustHitSection;

				if (songNotes[1] % Main.dataJump > 3)
				{
					gottaHitNote = !section.mustHitSection;
				}

				if (songNotes[1] % Main.dataJump > 7)
				{
					gottaHitNote = false;
					player3Note = true;
				}

				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;

				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote);
				swagNote.player3Note = player3Note;

				swagNote.sustainLength = songNotes[2];
				swagNote.scrollFactor.set(daCanvasSway, 0);

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				unspawnNotes.push(swagNote);

				if (susLength > 0)
					swagNote.isParent = true;

				var type = 0;

				for (susNote in 0...Math.floor(susLength))
				{
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

					var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, oldNote, true);
					sustainNote.scrollFactor.set(daCanvasSway, 0);
					unspawnNotes.push(sustainNote);
					sustainNote.player3Note = player3Note;
					sustainNote.mustPress = gottaHitNote;

					if (sustainNote.mustPress)
					{
						sustainNote.x += FlxG.width / 2; // general offset
					}

					sustainNote.parent = swagNote;
					swagNote.children.push(sustainNote);
					sustainNote.spotInLine = type;
					type++;
				}

				swagNote.mustPress = gottaHitNote;

				if (swagNote.mustPress)
				{
					swagNote.x += FlxG.width / 2; // general offset
				}
			}
			daBeats += 1;
		}

		unspawnNotes.sort(sortByShit);

		generatedMusic = true;
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	private function generateStaticArrows(player:Int, ?funnyTiming:Bool = false):Void
	{
		for (i in 0...4)
		{
			var babyArrow:FlxSprite = new FlxSprite(0, strumLine.y);
			if (SONG.song.toLowerCase() == 'bonedoggle')
			{
				babyArrow.x = 0;
			}

			babyArrow.frames = noteskinSprite;
			babyArrow.animation.addByPrefix('green', 'arrowUP');
			babyArrow.animation.addByPrefix('blue', 'arrowDOWN');
			babyArrow.animation.addByPrefix('purple', 'arrowLEFT');
			babyArrow.animation.addByPrefix('red', 'arrowRIGHT');

			babyArrow.antialiasing = FlxG.save.data.highquality;
			babyArrow.setGraphicSize(Std.int(babyArrow.width * Note.noteWidth));

			switch (Math.abs(i))
			{
				case 0:
					babyArrow.x += Note.swagWidth * 0;
					babyArrow.animation.addByPrefix('static', 'arrowLEFT');
					babyArrow.animation.addByPrefix('pressed', 'left press', 24, false);
					babyArrow.animation.addByPrefix('confirm', 'left confirm', 24, false);
				case 1:
					babyArrow.x += Note.swagWidth * 1;
					babyArrow.animation.addByPrefix('static', 'arrowDOWN');
					babyArrow.animation.addByPrefix('pressed', 'down press', 24, false);
					babyArrow.animation.addByPrefix('confirm', 'down confirm', 24, false);
				case 2:
					babyArrow.x += Note.swagWidth * 2;
					babyArrow.animation.addByPrefix('static', 'arrowUP');
					babyArrow.animation.addByPrefix('pressed', 'up press', 24, false);
					babyArrow.animation.addByPrefix('confirm', 'up confirm', 24, false);
				case 3:
					babyArrow.x += Note.swagWidth * 3;
					babyArrow.animation.addByPrefix('static', 'arrowRIGHT');
					babyArrow.animation.addByPrefix('pressed', 'right press', 24, false);
					babyArrow.animation.addByPrefix('confirm', 'right confirm', 24, false);
			}

			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set(daCanvasSway, 0);

			if (!isStoryMode)
			{
				babyArrow.y -= 10;
				if (funnyTiming)
				{
					babyArrow.alpha = 0.0001;
					var number:Int = i + 1;
					if (player == 0)
					{
						switch (number)
						{
							case 1:
								number = 4;
							case 2:
								number = 3;
							case 3:
								number = 2;
							case 4:
								number = 1;
						}
					}

					if (SONG.song.toLowerCase() == 'bonedoggle')
					{
						number = 1;
					}
					FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: (Conductor.crochet / 1000 * number)});
				}
			}

			babyArrow.ID = i;

			switch (player)
			{
				case 0:
					cpuStrums.add(babyArrow);
				case 1:
					playerStrums.add(babyArrow);
				case 2:
					cpuStrums2.add(babyArrow);
			}

			babyArrow.animation.play('static');

			switch (SONG.song.toLowerCase())
			{
				case 'bonedoggle':
					switch (player)
					{
						case 0:
							babyArrow.x += ((FlxG.width / 4)) - (babyArrow.width * 2);
						case 1:
							babyArrow.x += ((FlxG.width / 4) * 3) - (babyArrow.width * 2);
						case 2:
							babyArrow.x += ((FlxG.width / 4) * -1) - (babyArrow.width * 2); // sans starts offscreen to the left now
					}

					cpuStrums2.forEach(function(spr:FlxSprite)
					{
						spr.centerOffsets(); // CPU arrows start out slightly off-center
					});
				default:
					switch (player)
					{
						// This should be symmetrical now
						case 0:
							babyArrow.x += ((FlxG.width / 4)) - (babyArrow.width * 2);
						case 1:
							babyArrow.x += ((FlxG.width / 4) * 3) - (babyArrow.width * 2);
					}
			}

			cpuStrums.forEach(function(spr:FlxSprite)
			{
				spr.centerOffsets(); // CPU arrows start out slightly off-center
			});

			strumLineNotes.add(babyArrow);

			if (fuckinAngry)
			{
				playerStrums.forEach(function(spr:FlxSprite)
				{
					spr.alpha = 0.0;
				});
				cpuStrums.forEach(function(spr:FlxSprite)
				{
					spr.alpha = 0.0;
				});
			}
		}
	}

	private function generateAltStaticArrows(player:Int, ?funnyTiming:Bool = false):Void
	{
		for (i in 0...4)
		{
			var altArrow:FlxSprite = new FlxSprite(54, strumLine.y);

			altArrow.frames = Paths.getSparrowAtlas("NOTE_NMassets", 'notes');
			altArrow.animation.addByPrefix('green', 'arrowUP');
			altArrow.animation.addByPrefix('blue', 'arrowDOWN');
			altArrow.animation.addByPrefix('purple', 'arrowLEFT');
			altArrow.animation.addByPrefix('red', 'arrowRIGHT');

			altArrow.antialiasing = FlxG.save.data.highquality;
			altArrow.setGraphicSize(Std.int(altArrow.width * Note.noteWidth));

			switch (Math.abs(i))
			{
				case 0:
					altArrow.x += Note.swagWidth * 0;
					altArrow.animation.addByPrefix('static', 'arrowLEFT');
					altArrow.animation.addByPrefix('pressed', 'left press', 24, false);
					altArrow.animation.addByPrefix('confirm', 'left confirm', 24, false);
				case 1:
					altArrow.x += Note.swagWidth * 1;
					altArrow.animation.addByPrefix('static', 'arrowDOWN');
					altArrow.animation.addByPrefix('pressed', 'down press', 24, false);
					altArrow.animation.addByPrefix('confirm', 'down confirm', 24, false);
				case 2:
					altArrow.x += Note.swagWidth * 2;
					altArrow.animation.addByPrefix('static', 'arrowUP');
					altArrow.animation.addByPrefix('pressed', 'up press', 24, false);
					altArrow.animation.addByPrefix('confirm', 'up confirm', 24, false);
				case 3:
					altArrow.x += Note.swagWidth * 3;
					altArrow.animation.addByPrefix('static', 'arrowRIGHT');
					altArrow.animation.addByPrefix('pressed', 'right press', 24, false);
					altArrow.animation.addByPrefix('confirm', 'right confirm', 24, false);
			}

			altArrow.updateHitbox();
			altArrow.scrollFactor.set(daCanvasSway, 0);

			if (!isStoryMode)
			{
				if (funnyTiming)
				{
					altArrow.alpha = 0.0001;
					var number:Int = i + 1;
					if (player == 0)
					{
						switch (number)
						{
							case 1:
								number = 4;
							case 2:
								number = 3;
							case 3:
								number = 2;
							case 4:
								number = 1;
						}
					}
				}
			}

			altArrow.ID = i;

			switch (player)
			{
				case 0:
					altCpuStrums.add(altArrow);
				case 1:
					altPlayerStrums.add(altArrow);
			}

			altArrow.animation.play('static');

			altArrow.x += 50;
			altArrow.x += ((FlxG.width / 2) * player);
			altArrow.alpha = 0.0001;

			altArrow.x += 52;
			altArrow.y += 45;

			altStrumLineNotes.add(altArrow);

			altCpuStrums.forEach(function(spr:FlxSprite)
			{
				spr.centerOffsets(); // CPU arrows start out slightly off-center
			});

			if (PlayState.SONG.song.toLowerCase() != 'nightmare-run')
			{
				altPlayerStrums.forEach(function(spr:FlxSprite)
				{
					spr.visible = false;
				});
				altCpuStrums.forEach(function(spr:FlxSprite)
				{
					spr.visible = false;
				});
			}

			/*if (PlayState.SONG.song.toLowerCase() == 'bad-time'
					|| PlayState.SONG.song.toLowerCase() == 'devils-gambit'
					|| PlayState.SONG.song.toLowerCase() == 'despair')
				{
					altPlayerStrums.forEach(function(spr:FlxSprite)
					{
						spr.visible = true;
						spr.alpha = 1.0;
					});
					altCpuStrums.forEach(function(spr:FlxSprite)
					{
						spr.visible = true;
						spr.alpha = 1.0;
					});
			}*/
		}
	}

	function tweenCamIn():Void
	{
		FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();

				if (vocals != null)
				{
					vocals.pause();
				}

				// this will make countdown intro stop when pausing cuphead songs
				// it was so annoying fr
				if (countdownNarrator != null)
				{
					if (countdownNarrator.playing)
						countdownNarrator.pause();
				}
			}

			if (curStage == 'factory')
			{
				if (SONG.song.toLowerCase() == 'nightmare-run')
				{
					if (bgs != null)
					{
						bgs[randomPick].animation.pause();
					}
				}

				if (jumpingBendyTimer1 != null)
				{
					jumpingBendyTimer1.active = false;
				}

				if (jumpingBendyTimer2 != null)
				{
					jumpingBendyTimer2.active = false;
				}

				if (jumpingBendyTimer3 != null)
				{
					jumpingBendyTimer3.active = false;
				}

				if (jumpingBendyTimer4 != null)
				{
					jumpingBendyTimer4.active = false;
				}
				if (inkTimer != null)
					inkTimer.active = false;

				if (cuptimer != null)
					cuptimer.active = false;

				if (dietimer != null)
					dietimer.active = false;

				if(cupBullets[0] != null)
				{
					cupBullets[0].cantmove = true;
					cupBullets[1].cantmove = true;
				}
				dad.onpause(true);
				boyfriend.onpause(true);
				if (player3 != null)
					player3.onpause(true);
			}

			#if cpp
			var disSong:String = SONG.song;
			if (HelperFunctions.shouldBeHidden(SONG.song.toLowerCase()))
				disSong = '[CONFIDENTIAL]';
			DiscordClient.changePresence("PAUSED on "
				+ disSong
				+ " ("
				+ storyDifficultyText
				+ ") "
				+ Ratings.GenerateLetterRank(accuracy),
				"Acc: "
				+ HelperFunctions.truncateFloat(accuracy, 2)
				+ "% | Score: "
				+ songScore
				+ " | Misses: "
				+ misses, iconRPC);
			#end
			if (!specialIntro)
			{
				if (!startTimer.finished)
					startTimer.active = false;
			}
		}

		super.openSubState(SubState);
	}

	var jumpscareTimerMin:Int = 60;
	var jumpscareTimerMax:Int = 100;

	override function closeSubState()
	{
		if (paused && !dead)
		{
			FlxTween.globalManager.active = true;

			FlxG.mouse.visible = false;

			if (vocals != null)
			{
				vocals.pause();
				vocals.time = Conductor.songPosition;
				vocals.play();
			}

			FlxG.sound.music.play();
			Conductor.songPosition = FlxG.sound.music.time;

			#if cpp
			var disSong:String = SONG.song;
			if (HelperFunctions.shouldBeHidden(SONG.song.toLowerCase()))
				disSong = '[CONFIDENTIAL]';
			DiscordClient.changePresence(detailsText
				+ " "
				+ disSong
				+ " ("
				+ storyDifficultyText
				+ ") "
				+ Ratings.GenerateLetterRank(accuracy),
				"\nAcc: "
				+ HelperFunctions.truncateFloat(accuracy, 2)
				+ "% | Score: "
				+ songScore
				+ " | Misses: "
				+ misses, iconRPC);
			#end

			if (curStage == 'factory')
			{
				if (SONG.song.toLowerCase() == 'nightmare-run')
				{
					if (bgs != null)
					{
						bgs[randomPick].animation.resume();
					}
				}

				if (jumpingBendyTimer1 != null)
				{
					jumpingBendyTimer1.active = true;
				}

				if (jumpingBendyTimer2 != null)
				{
					jumpingBendyTimer2.active = true;
				}

				if (jumpingBendyTimer3 != null)
				{
					jumpingBendyTimer3.active = true;
				}

				if (jumpingBendyTimer4 != null)
				{
					jumpingBendyTimer4.active = true;
				}
				if (inkTimer != null)
					inkTimer.active = true;

				if (cuptimer != null)
					cuptimer.active = true;

				if (dietimer != null)
					dietimer.active = true;

				if(cupBullets[0] != null)
				{
					cupBullets[0].cantmove = false;
					cupBullets[1].cantmove = false;
				}
				dad.onpause(false);
				boyfriend.onpause(false);
				if (player3 != null)
					player3.onpause(false);
			}

			if (gameVideos != null)
			{
				for (i in 0...gameVideos.length)
				{
					gameVideos[i].bitmap.resume();
				}
			}

			if (!specialIntro)
			{
				if (!startTimer.finished)
					startTimer.active = true;
			}

			paused = false;

			#if cpp
			if (!specialIntro)
			{
				if (startTimer.finished)
				{
					var disSong:String = SONG.song;
					if (HelperFunctions.shouldBeHidden(SONG.song.toLowerCase()))
						disSong = '[CONFIDENTIAL]';
					DiscordClient.changePresence(detailsText
						+ " "
						+ disSong
						+ " ("
						+ storyDifficultyText
						+ ") "
						+ Ratings.GenerateLetterRank(accuracy),
						"\nAcc: "
						+ HelperFunctions.truncateFloat(accuracy, 2)
						+ "% | Score: "
						+ songScore
						+ " | Misses: "
						+ misses, iconRPC, true,
						songLength
						- Conductor.songPosition);
				}
				else
				{
					var disSong:String = SONG.song;
					if (HelperFunctions.shouldBeHidden(SONG.song.toLowerCase()))
						disSong = '[CONFIDENTIAL]';
					DiscordClient.changePresence(detailsText, disSong + " (" + storyDifficultyText + ") " + Ratings.GenerateLetterRank(accuracy), iconRPC);
				}
			}
			else
			{
				var disSong:String = SONG.song;
				if (HelperFunctions.shouldBeHidden(SONG.song.toLowerCase()))
					disSong = '[CONFIDENTIAL]';
				DiscordClient.changePresence(detailsText, disSong + " (" + storyDifficultyText + ") " + Ratings.GenerateLetterRank(accuracy), iconRPC);
			}
			#end
		}

		super.closeSubState();
	}

	function resyncVocals():Void
	{
		if (!paused)
		{
			if (vocals != null)
			{
				vocals.pause();

				FlxG.sound.music.play();
				Conductor.songPosition = FlxG.sound.music.time;
				vocals.time = Conductor.songPosition;
				vocals.play();

				#if cpp
				var disSong:String = SONG.song;
				if (HelperFunctions.shouldBeHidden(SONG.song.toLowerCase()))
					disSong = '[CONFIDENTIAL]';
				DiscordClient.changePresence(detailsText
					+ " "
					+ disSong
					+ " ("
					+ storyDifficultyText
					+ ") "
					+ Ratings.GenerateLetterRank(accuracy),
					"\nAcc: "
					+ HelperFunctions.truncateFloat(accuracy, 2)
					+ "% | Score: "
					+ songScore
					+ " | Misses: "
					+ misses, iconRPC);
				#end
			}
		}
	}

	private var paused:Bool = false;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;
	var nps:Int = 0;
	var maxNPS:Int = 0;

	public static var songRate = 1.5;

	public var stopUpdate = false;

	var shakeyCam:Bool = false;
	var brightFyreVal:Float = 0;
	var brightMagnitude:Float = 0;
	var brightSpeed:Float = 0;

	public var defaultBrightVal:Float = 0;

	var flashing:Bool = false;
	var pressedSpace:Bool = false;

	var overrideDadAnim:Bool = false;
	var overridePlayer3Anim:Bool = false;

	var dodgeType:String = 'sans';

	var lastUpdatedPos:Float = 0;

	var lastPiperSpawn:Float = 0;
	var lastStrikerSpawn:Float = 0;
	var lastPiperAttack:Float = 0;
	var lastStrikerAttack:Float = 0;

	var baseDadFloat:Float;

	var spaceCooldown:Float = 0;

	var fisherAng:Float = 180;
	var fisherX:Float = -700;
	var fisherKill = false;
	var fisheraaa:Float = 0;
	var ae = 0;

	var prevHealth:Float = 0;

	override public function update(elapsed:Float)
	{
		#if !debug
		perfectMode = false;
		#end

		if (SONG.song.toLowerCase() == "satanic-funkin" || SONG.song.toLowerCase() == "despair" || (SONG.song.toLowerCase() == "last-reel" && storyDifficulty >= 1) || SONG.song.toLowerCase() == "despair")
		{
			if ((controls.DODGE && dodgeHud.alpha > 0.001) && !inputSpacePressed && !PlayStateChangeables.botPlay)
			{
				dodgeAmt++;
				bfMechDodge();
			}
		}

		if ((SONG.song.toLowerCase() == "last-reel" && storyDifficulty >= 1) || SONG.song.toLowerCase() == "despair")
		{
			// attack code that didnt work in handleInput for some reason
			if ((controls.ATTACKLEFT && attackHud.alpha > 0.001) && FlxG.save.data.attackLeftBind != 'SHIFT')
			{
				trace("attack left that is not shift");
				bfAttack(true);
			}
			if ((controls.ATTACKRIGHT && attackHud.alpha > 0.001) && FlxG.save.data.attackRightBind != 'SHIFT')
			{
				trace("attack right that is not shift");
				bfAttack(false);
			}
		}

		if ((PlayStateChangeables.botPlay && cupheadPewMode) && (curStage == 'field' || SONG.song.toLowerCase() == 'devils-gambit'))
		{
			useAttackSlot();
		}
		else if ((SONG.song.toLowerCase() == 'last-reel' || SONG.song.toLowerCase() == 'despair') && PlayStateChangeables.botPlay)
		{
			if ((currentStriker != null || currentPiper != null) && attackCooldown == 0)
			{
				if (currentStriker != null)
				{
					if (currentStriker.attacking)
					{
						if (mechanicType != 0)
							attackCooldown = 3;
						else
							attackCooldown = 5;
						lastUpdatedPos = Math.floor(FlxG.sound.music.time);
						boyfriend.playAnim("attackLeft",true, false, 0, true);
						lastStrikerSpawn = Math.floor(FlxG.sound.music.time);
						currentStriker.swinging = false;
						currentStriker.hp--;
						if (currentStriker.hp == 0)
						{
							currentStriker.die();
						}
						else
						{
							currentStriker.hit();
						}
					}
				}
				if (currentPiper != null)
				{
					if (currentPiper.attacking)
					{
						if (mechanicType != 0)
							attackCooldown = 3;
						else
							attackCooldown = 5;
						lastUpdatedPos = Math.floor(FlxG.sound.music.time);
						boyfriend.playAnim("attackRight",true, false, 0, true);
						lastPiperSpawn = Math.floor(FlxG.sound.music.time);
						currentPiper.swinging = false;
						currentPiper.hp--;
						if (currentPiper.hp == 0)
						{
							currentPiper.die();
						}
						else
						{
							currentPiper.hit();
						}
					}
				}
			}
		}

		if (mechAnim != null)
		{
			mechAnim.alpha = mechInstructions.alpha;
		}

		if (hasInstruction && controls.ACCEPT && !inCutscene && !videoPlaying)
		{
			hasInstruction = false;
			camGame.visible = true;
			camHUD.visible = true;
			camOVERLAY.visible = true;
			switch (curStage)
			{
				case 'factory':
					FlxG.sound.play(Paths.sound('click', 'bendy'));
				case 'field' | 'devilHall':
					FlxG.sound.play(Paths.sound('select', 'cup'));
				case 'papyrus' | 'hall':
					FlxG.sound.play(Paths.sound('ping', 'sans'));
				default:
					FlxG.sound.play(Paths.sound('confirmMenu'));
			}
			mechInstructMusic.stop();

			if (mechPressEnter != null)
			{
				FlxTween.cancelTweensOf(mechPressEnter);
				mechPressEnter.alpha = 1;
				FlxFlicker.flicker(mechPressEnter, 1, 0.06, false, false);
			}

			if (mechInstructions != null)
			{
				if (!dialoguePaused)
					startCountdown();
				FlxTween.tween(mechInstructions, {alpha: 0.0}, 0.5, {
					ease: FlxEase.quadInOut,
					startDelay: 1.0,
					onComplete: function(twn:FlxTween)
					{
						canPause = true;
						dialoguePaused = false;
						mechInstructions.destroy();
						if (mechAnim != null)
							mechAnim.destroy();
					}
				});
				if (curStage == 'field' || curStage == 'devilHall')
				{
					cupteaPlay();
				}
			}
		}

		if (MainMenuState.debugTools)
		{
			if (FlxG.keys.pressed.CONTROL)
			{
				if (FlxG.keys.justPressed.L)
				{
					trace('the fcinator');
					goods = 0;
					bads = 0;
					shits = 0;
					misses = 0;
					accuracy = 100;
				}

				var ff = 0;
				if (FlxG.keys.pressed.M)
					ff = 1;
				if (FlxG.keys.pressed.N)
					ff -= 1;

				if (ff != 0)
				{
					FlxG.sound.music.pause();
					// FlxG.camera.zoom = 1;
					camHUD.zoom = 1;
					vocals.pause();
					if (FlxG.keys.pressed.SHIFT)
						ff *= 10;
					Conductor.songPosition += elapsed * 60 * 100 * ff;
					vocals.time = Conductor.songPosition;
					FlxG.sound.music.time = Conductor.songPosition;

					FlxG.sound.music.play();
					vocals.play();
					health = 2;

					vocals.volume = 1;

					pressedSpace = true;
					if (inkObj != null)
					{
						inkTime = 0;
						inkProg = 0;
						inkObj.alpha = 0;
					}
				}
			}
		}

		/*if (SONG.song.toLowerCase() == "despair")
			{
				if (FlxG.keys.justPressed.A && bfOnRight && bfCanMove && bfMovementOver) // i'm dumb, idk how to make it use left and right shift for now just doing A and L :((()))
				{
					bfMovementOver = false;
					boyfriend.x = 1290;
					boyfriend.playAnim('running', true);
					boyfriend.flipX = false;
					boyfriend.animation.finishCallback = function(name:String)
					{
						boyfriend.dance();
						boyfriend.x = -650;
						boyfriend.flipX = true;
						bfMovementOver = true;
					};

					new FlxTimer().start(0.25, function(tmr:FlxTimer)
					{
						bfOnRight = false;
					});
				}
				if (FlxG.keys.justPressed.L && !bfOnRight && bfCanMove && bfMovementOver)
				{
					bfMovementOver = false;
					boyfriend.x = 1290;
					boyfriend.playAnim('running', true);
					boyfriend.flipX = true;
					boyfriend.animation.finishCallback = function(name:String)
					{
						boyfriend.dance();
						boyfriend.x = 1290;
						boyfriend.flipX = false;
						bfMovementOver = true;
					};

					new FlxTimer().start(0.25, function(tmr:FlxTimer)
					{
						bfOnRight = true;
					});
				}
		}*/

		if (SONG.song.toLowerCase() == 'satanic-funkin' || SONG.song.toLowerCase() == 'despair')
		{
			if (boyfriend.overlaps(devilGroup))
			{
				devilGroup.forEachAlive(function(bitch:DevilBitches)
				{
					if (!bitch.hasHit && ((bitch.x < boyfriend.x + boyfriend.width / 4) && (bitch.x > boyfriend.x - boyfriend.width / 2)))
					{
						bitch.bitchCooldown += elapsed;
						if (bitch.bitchCooldown > 0.15 && spaceCooldown <= 0)
						{
							if (boyfriend.animation.curAnim.name == 'dodge')
								bitch.bitchCooldown = -0.2;
							else
							{
								if (PlayStateChangeables.botPlay)
								{
									bitch.bitchCooldown = -0.2;

									boyfriend.playAnim('dodge', true, false, 0, true);

									dodgeHud.useHUD();
									spaceCooldown = 1.6;
									inputSpacePressed = true;
								}
								else
								{
									boyfriend.playAnim('hurt', true, false, 0, true);
									if (SONG.song.toLowerCase() == 'satanic-funkin')
									{
										FlxG.sound.play(Paths.sound('hurt', 'cup'));
									}
									FlxG.camera.shake(0.05, 0.5);
									trace('oh shit');
									healthChange(-1);
									bitch.hasHit = true;
								}
							}
						}
					}
				});
			}
			if (spaceCooldown > 0 && boyfriend.animation.curAnim.name != 'dodge')
				spaceCooldown -= elapsed;
		}

		if (SONG.song.toLowerCase() == 'knockout' && mugdead != null)
		{
			if (mugdead.overlaps(cupBullets[0]) && (mugcanhit))
			{
				if (((cupBullets[0].x < mugdead.x + mugdead.width / 4) && (cupBullets[0].x > mugdead.x - mugdead.width / 2)))
				{
					if ((mugdead.animation.curAnim.name == 'Stroll'))
					{
						var cupheadPewThing = new CupBullet('hadokenFX', cupBullets[0].x + cupBullets[0].width / 4, cupBullets[0].y);
						cupheadPewThing.state = 'oneshoot';
						add(cupheadPewThing);
						cupBullets[0].state = 'unactive';
						cupheadPewThing.animation.finishCallback = function(name:String)
						{
							remove(cupheadPewThing);
						};
						knockout();
						mugdead.animation.play('Dead', true);
						FlxG.sound.play(Paths.sound('hurt', 'cup'));
						mugcanhit = false;
					}
				}
			}
		}

		if (sansCanAttack)
		{
			if (((controls.ATTACKLEFT || controls.ATTACKRIGHT) && attackHud.alpha > 0.001)
				&& attackCooldown == 0
				&& !battleMode
				&& !PlayStateChangeables.botPlay
				&& !sansTalking)
			{
				trace('literally bruhing rn');
				attackCooldown = 5;
				lastUpdatedPos = Math.floor(FlxG.sound.music.time);
				boyfriend.playAnim('attack', true, false, 0, true);

				FlxG.sound.play(Paths.sound('Throw' + FlxG.random.int(1, 3), 'sans'));

				if (bfDodge != null)
				{
					bfDodge.alpha = 0.0001;
					boyfriend.alpha = 1;
				}

				new FlxTimer().start(0.375, function(tmr:FlxTimer)
				{
					// overrideDadAnim = true;
					if (!battleMode)
					{
						if (forceAlt)
							dad.playAnim('miss-alt', true, false, 0, true);
						else
							dad.playAnim('miss', true, false, 0, true);

						FlxG.sound.play(Paths.sound('dodge', 'sans'), 0.6);

						genocideShit();

						healthChange(0.2);

						FlxG.camera.shake(0.005);

						chromVal = 0.0025;
						FlxTween.tween(this, {chromVal: 0}, 0.3);
					}
				});
			}
		}

		if (dadFloat)
		{
			dad.y = baseDadFloat + Math.sin((Conductor.songPosition / 1000) * (Conductor.bpm / 60) * 2.0) * 10;
		}

		var righty = 165;
		var lefty = 130;
		var leftx = 120;
		var rightx = 35;

		if ((SONG.song.toLowerCase() == "last-reel" && storyDifficulty >= 1) || SONG.song.toLowerCase() == "despair")
		{
			// strikers and pipers

			if (Math.floor(FlxG.sound.music.time) > lastPiperSpawn + 6000 + piperaddtime
				&& currentPiper == null
				&& songStarted
				&& butchersActive) // every 6 seconds
			{
				if (SONG.song.toLowerCase() == "despair")
				{
					currentPiper = new BendyBoy(boyfriend.x + 1110, boyfriend.y + righty, "piper", true);
					// currentPiper.setGraphicSize(Std.int(currentPiper.width * 0.7));
					bendyBoyGroup.add(currentPiper);
					piperTween = FlxTween.tween(currentPiper, {x: boyfriend.x + 250 + rightx + 70}, 4, {
						onComplete: function(tween:FlxTween)
						{
							lastPiperSpawn = Math.floor(FlxG.sound.music.time);
							if (currentPiper != null)
							{
								currentPiper.attacking = true;
								currentPiper.playAnim("idle");

								if (boyfriend.animation.curAnim.name == 'attackRight')
								{
									hitPiper();
								}
							}
						}
					});
				}
				else if (SONG.song.toLowerCase() == "last-reel" && storyDifficulty >= 1)
				{
					currentPiper = new BendyBoy(boyfriend.x + 1100, boyfriend.y - 45 + righty, "piper", false);
					bendyBoyGroup.add(currentPiper);
					piperTween = FlxTween.tween(currentPiper, {x: boyfriend.x + 450 + rightx}, 4, {
						onComplete: function(tween:FlxTween)
						{
							lastPiperSpawn = Math.floor(FlxG.sound.music.time);
							if (currentPiper != null)
							{
								currentPiper.attacking = true;
								currentPiper.playAnim("idle");

								if (boyfriend.animation.curAnim.name == 'attackRight')
								{
									hitPiper();
								}
							}
						}
					});
				}

				if (currentPiper != null)
				{
					currentPiper.animation.finishCallback = function(name)
					{
						if (name != 'walk' && SONG.song.toLowerCase() == "last-reel")
						{
							canCameraMove=true;
							FlxTween.tween(this, {defaultCamZoom: oldDefaultCamZoom}, 0.3, {ease: FlxEase.quadOut});
						}
						switch (name)
						{
							case "ded":
								bendyBoyGroup.members.remove(currentPiper);
								currentPiper = null;
							case "attack":
								currentPiper.playAnim("idle");
								currentPiper.swinging = false;
							case "preAttack":
								currentPiper.attack();
								if ((currentPiper.swinging && boyfriend.animation.curAnim.name != 'dodge')
									&& !PlayStateChangeables.botPlay)
								{
									// has attacked during the last 500ms, opening input window
									new FlxTimer().start(0.1, function(tmr:FlxTimer)
									{
										if (boyfriend.animation.curAnim.name != 'dodge')
										{
											// player did not dodge in input window
											updateInkProg(2);
											boyfriend.playAnim("ouchy",true, false, 0, true);
										}
									});
								}
								else if (PlayStateChangeables.botPlay)
								{
									// bot is playing, so just dodge
									boyfriend.playAnim('dodge',true, false, 0, true);

									dodgeHud.useHUD();
									inputSpacePressed = true;
								}
							case "walk":
							// nothin
							case "hit":
								lastPiperAttack = Math.floor(FlxG.sound.music.time);
								currentPiper.swinging = false;
								currentPiper.playAnim("idle");
							default:
								currentPiper.playAnim("idle");
						}
					}
				}
			}

			if (Math.floor(FlxG.sound.music.time) > lastStrikerSpawn + 6000 + strikeraddtime
				&& currentStriker == null
				&& songStarted
				&& butchersActive) // every 11.35 seconds
			{
				if (mechanicType != 0)
				{
					strikeraddtime = 3000;
				}

				if (SONG.song.toLowerCase() == "despair")
				{
					currentStriker = new BendyBoy(dad.x - 1400, boyfriend.y - 45 + lefty + 85, "striker", true);
					// currentStriker.setGraphicSize(Std.int(currentPiper.width * 0.8));
					bendyBoyGroup.add(currentStriker);
					strikerTween = FlxTween.tween(currentStriker, {x: boyfriend.x - 750 + leftx + 80}, 8, {
						onComplete: function(tween:FlxTween)
						{
							lastStrikerSpawn = Math.floor(FlxG.sound.music.time);
							if (currentStriker != null)
							{
								currentStriker.attacking = true;
								currentStriker.playAnim("idle");

								if (boyfriend.animation.curAnim.name == 'attackLeft')
								{
									hitStriker();
								}
							}
						}
					});
				}
				else if (SONG.song.toLowerCase() == "last-reel" && storyDifficulty >= 1)
				{
					currentStriker = new BendyBoy(dad.x - 1400, boyfriend.y + lefty, "striker", false);
					bendyBoyGroup.add(currentStriker);
					strikerTween = FlxTween.tween(currentStriker, {x: boyfriend.x - 400 + leftx}, 8, {
						onComplete: function(tween:FlxTween)
						{
							lastStrikerSpawn = Math.floor(FlxG.sound.music.time);
							if (currentStriker != null)
							{
								currentStriker.attacking = true;
								currentStriker.playAnim("idle");

								if (boyfriend.animation.curAnim.name == 'attackLeft')
								{
									hitStriker();
								}
							}
						}
					});
				}

				if (currentStriker != null)
				{
					currentStriker.animation.finishCallback = function(name)
					{

						if (name != 'walk' && SONG.song.toLowerCase() == "last-reel")
							{
								canCameraMove=true;
								FlxTween.tween(this, {defaultCamZoom: oldDefaultCamZoom}, 0.3, {ease: FlxEase.quadOut});
							}
						switch (name)
						{
							case "ded":
								bendyBoyGroup.members.remove(currentStriker);
								currentStriker = null;
							case "attack":
								currentStriker.playAnim("idle");
								currentStriker.swinging = false;
							case "preAttack":
								currentStriker.attack();
								if ((currentStriker.swinging && boyfriend.animation.curAnim.name != 'dodge')
									&& !PlayStateChangeables.botPlay)
								{
									// has attacked during the last 500ms, opening input window
									new FlxTimer().start(0.1, function(tmr:FlxTimer)
									{
										if (boyfriend.animation.curAnim.name != 'dodge')
										{
											// player did not dodge in input window
											updateInkProg(2);
											boyfriend.playAnim("ouchy",true , false, 0, true);
										}
									});
								}
								else if (PlayStateChangeables.botPlay)
								{
									// bot is playing, so just dodge
									boyfriend.playAnim('dodge', false, 0, true);

									dodgeHud.useHUD();
									inputSpacePressed = true;
								}
							case "walk":
							// nothin
							case "hit":
								lastStrikerAttack = Math.floor(FlxG.sound.music.time);
								currentStriker.swinging = false;
								currentStriker.playAnim("idle");
							default:
								currentStriker.playAnim("idle");
						}
					};
				}
			}

			if (bendyBoyGroup != null)
			{
				for (boi in bendyBoyGroup.members)
				{
					if (boi.attacking && !boi.swinging && mechanicsEnabled)
					{
						switch (boi.type)
						{
							case "piper":
								if (Math.floor(FlxG.sound.music.time) > lastPiperAttack + 7000)
								{
									lastPiperAttack = Math.floor(FlxG.sound.music.time);
									boi.preAttack();
									if (SONG.song.toLowerCase() == "last-reel")
										checkFocus(true,'bf',0.075,0.5);
								}
							case "striker":
								if (Math.floor(FlxG.sound.music.time) > lastStrikerAttack + 7000)
								{
									lastStrikerAttack = Math.floor(FlxG.sound.music.time);
									boi.preAttack();
									if (SONG.song.toLowerCase() == "last-reel")
										checkFocus(true,'bf',0.075,0.5);
								}
						}
					}
				}
			}

			if (curStage == 'factory')
			{
				if (fisher != null)
				{
					if (fisher.alpha >= 0.05)
					{
						var fisherToX = (1280 / 2) + Math.cos(fisherAng * Math.PI / 180) * (1280 / 2);
						fisherX += ((fisherToX - fisherX) / 10) * elapsed * 60;
						var anothax = fisheraaa;

						if (fisher.animation.curAnim.curFrame > 75)
						{
							fisher.animation.curAnim.curFrame = 0;
						}
						fisher.offset.x = fisher.animation.curAnim.curFrame * 17 + 250;
						fisher.x = fisherX + anothax;
						fisherAng += elapsed * 60 / 1.5;
					}

					if (fisherKill)
					{
						fisheraaa += elapsed * 45;
						if(FlxG.keys.justPressed.SPACE)
							trace('homhomhomhh ' + fisheraaa);
						if (fisheraaa >= 325.800000000001)
						{
							fisher.kill();
						}
						/*fisher.alpha -= elapsed * 3;
						if (fisher)
						{
							fisher.kill();
						}*/
					}
				}
			}
		}

		if (curStage == 'field' || curStage == 'devilHall')
			if (chromVal < 0.001)
				chromVal = 0.001;

		if (attackCooldown != 0 && songStarted)
		{
			if (attackCooldown != 0)
				attackHud.playAnim(Std.string(attackCooldown));

			if (Math.floor(FlxG.sound.music.time) > lastUpdatedPos + 1000)
			{
				lastUpdatedPos = Math.floor(FlxG.sound.music.time);

				attackCooldown--;

				if (attackCooldown == 0)
				{
					attackHud.useHUD();
				}
			}
		}

		if (battleMode)
		{
			boyfriend.y = 1248.7 + Math.sin((Conductor.songPosition / 1000) * (Conductor.bpm / 60) * 2.5) * 20;
		}

		if (canPressSpace && (controls.DODGE && dodgeHud.alpha > 0.001) && !PlayStateChangeables.botPlay && !MainMenuState.showcase)
		{
			dodgeAmt++;
			pressedSpace = true;

			if (dodgeType == 'sans' || dodgeType == 'orange')
			{
				FlxG.sound.play(Paths.sound('dodge', 'sans'), 0.6);
			}
			else if (dodgeType == 'blue')
			{
				if (!PlayStateChangeables.botPlay)
				{
					if (mechanicType == 0)
					{
						playerDie();
					}
					else 
					{
						healthChange(-1.0,'sans'); //50% of health
						//krChange(-1.0);
						boyfriend.playAnim('singUPmiss', true);
					}
					FlxG.sound.play(Paths.sound('sansattack', 'sans'));
				}
			}
			else
			{
				FlxG.sound.play(Paths.sound('scrollMenu', 'preload'));
			}

			FlxG.camera.shake(0.02, 0.01);

			canPressSpace = false;

			dodgeHud.useHUD();
		}

		var lengthInPx = scoreTxt.textField.length * scoreTxt.frameHeight; // bad way but does more or less a better job
		// scoreTxt.x = (originalX - (lengthInPx / 2)) + 335;
		scoreTxt.screenCenter(X);
		scoreTxt.updateHitbox();

		if (((controls.ATTACKLEFT || controls.ATTACKRIGHT) && attackHud.alpha > 0.001) && !PlayStateChangeables.botPlay)
		{
			useAttackSlot();
		}

		if (SONG.song.toLowerCase() == 'nightmare-run')
		{
			cycleScroll();
		}

		if (shakeyCam)
		{
			FlxG.camera.shake(0.1, 0.01);
		}

		if (brightSpeed != 0)
		{
			brightFyreVal = defaultBrightVal + Math.sin((Conductor.songPosition / 1000) * (Conductor.bpm / 60) * brightSpeed) * brightMagnitude;
			setBrightness(brightFyreVal);
		}
		else
		{
			setBrightness(defaultBrightVal);
		}

		setContrast(1.0);

		if ((fuckinAngry
			|| curStage == 'hall'
			|| SONG.song.toLowerCase() == "technicolor-tussle"
			|| SONG.song.toLowerCase() == "knockout"
			|| SONG.song.toLowerCase() == "devils-gambit")
			&& (FlxG.save.data.highquality && !FlxG.save.data.photosensitive))
		{
			setChrome(chromVal);
		}

		if (executeModchart && luaModchart != null && songStarted)
		{
			luaModchart.setVar('songPos', Conductor.songPosition);
			luaModchart.setVar('hudZoom', camHUD.zoom);
			luaModchart.setVar('cameraZoom', FlxG.camera.zoom);
			luaModchart.executeState('update', [elapsed]);

			FlxG.camera.angle = luaModchart.getVar('cameraAngle', 'float');
			camHUD.angle = luaModchart.getVar('camHudAngle', 'float');

			if (luaModchart.getVar("showOnlyStrums", 'bool'))
			{
				healthBarBG.visible = false;
				healthBar.visible = false;
				iconP1.visible = false;
				iconP2.visible = false;
				scoreTxt.visible = false;
			}
			else
			{
				healthBarBG.visible = true;
				healthBar.visible = true;
				iconP1.visible = true;
				iconP2.visible = true;
				scoreTxt.visible = true;
			}

			var p1 = luaModchart.getVar("strumLine1Visible", 'bool');
			var p2 = luaModchart.getVar("strumLine2Visible", 'bool');

			for (i in 0...4)
			{
				strumLineNotes.members[i].visible = p1;
				if (i <= playerStrums.length)
					playerStrums.members[i].visible = p2;
			}
		}

		// reverse iterate to remove oldest notes first and not invalidate the iteration
		// stop iteration as soon as a note is not removed
		// all notes should be kept in the correct order and this is optimal, safe to do every frame/update
		{
			var balls = notesHitArray.length - 1;
			while (balls >= 0)
			{
				var cock:Date = notesHitArray[balls];
				if (cock != null && cock.getTime() + 1000 < Date.now().getTime())
					notesHitArray.remove(cock);
				else
					balls = 0;
				balls--;
			}
			nps = notesHitArray.length;
			if (nps > maxNPS)
				maxNPS = nps;
		}

		if (cardbar != null && cardanims != null)
		{
			if (!poped || cardfloat == 200)
			{
				cardbar.alpha = 0.0001;
				cardanims.alpha = 1;
			}
			cardbar.y = cardbary + healthBarBG.y + 40 - (cardfloat / 1.5);
			if (cardanims.animation.curAnim.name == 'parry')
			{
				cardfloat = 200;
			}
		}
		if (cardfloat >= 200)
			cardfloat = 200;

		if (cupheadPewMode && SONG.song.toLowerCase() == 'technicolor-tussle')
			dad.idleReplacement = 'attack1';

		if (battleMode)
			bfPos[0] = dadPos[0];

		if (utmode && ball != null)
		{
			blaster.forEachAlive(function(bull:FlxSprite)
				{
					if (ball.overlaps(bull) && bull.alpha == 1)
					{
						bull.animation.callback = function(boom, frameNumber:Int, frameIndex:Int)
						{
							if (frameNumber >= 28)
							{
								var hitboxRect = new AdvancedRect(bull.x,bull.y + 100,bull.width,bull.height + 25);
								var rotatedRect = hitboxRect.getTheRotatedBounds(bull.angle);
								rotatedRect.width = hitboxRect.width;
								rotatedRect.height = hitboxRect.height;
								if (ball.isInside(rotatedRect))
								{
									if (!PlayStateChangeables.botPlay)
									{
										gethurt();
									}
								}
							}
						}
					}
				});

			var up:Bool = false;
			var down:Bool = false;
			var left:Bool = false;
			var right:Bool = false;

			up = controls.UP;
			down = controls.DOWN;
			left = controls.LEFT;
			right = controls.RIGHT;

			if (up && down)
				up = down = false;
			if (left && right)
				left = right = false;

			if (up || down || left || right)
			{
				if (up)
				{
					ball.y -= speed * elapsed;
					if (!ball.isInside(battleBoundaries))
					{
						// trace('cantgo');
						ball.y += speed * elapsed;
					}
				}
				if (down)
				{
					ball.y += speed * elapsed;
					if (!ball.isInside(battleBoundaries))
					{
						// trace('cantgo');
						ball.y -= speed * elapsed;
					}
				}
				if (left)
				{
					ball.x -= speed * elapsed;
					if (!ball.isInside(battleBoundaries))
					{
						// trace('cantgo');
						ball.x += speed * elapsed;
					}
				}
				if (right)
				{
					ball.x += speed * elapsed;
					if (!ball.isInside(battleBoundaries))
					{
						// trace('cantgo');
						ball.x -= speed * elapsed;
					}
				}
			}
		}
		if (utmode)
			dadPos[1] = bfPos[1];

		/*if (FlxG.sound.music.playing && !songOver)
			{
				@:privateAccess
				{
					lime.media.openal.AL.sourcef(FlxG.sound.music._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, songSpeed);
					if (vocals.playing && vocals != null)
						lime.media.openal.AL.sourcef(vocals._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, songSpeed);
				}
		}*/

		if (inkscroll != null)
		{
			for (i in inkscroll)
			{
				i.x += 350 * elapsed;
				if (i.x >= 1280)
					i.x = -i.width;
			}
		}

		if (SONG.song.toLowerCase() == 'nightmare-run' && iskinky) 
		{
			boyfriend.idleReplacement = 'idle';
			backbg.members[1].x -= 35 * elapsed;
			backbg.members[4].x -= 35 * elapsed;
			backbg.members[3].x -= 30 * elapsed;
			backbg.members[2].x -= 30 * elapsed;
			var midx = (bfPos[0] + dadPos[0]) / 2;
			var midy = (bfPos[1] + dadPos[1]) / 2;
			bfPos[0] = midx;
			dadPos[0] = midx;
			bfPos[1] = midy;
			dadPos[1] = midy;
		}

		if (forcesize)
		{
			boyfriend.setZoom(0.75);
			dad.setZoom(0.75 + 0.25);
		}

		if (frontbg != null)
		{
			for (i in 0...2)
				{
					frontbg.members[i].x -= 1450 * elapsed;
					if (frontbg.members[i].x <= -FlxG.width*1.815)
						frontbg.members[i].x = FlxG.width*1.815 - 200;
				}
		}

		if (FlxG.save.data.laneUnderlay)
		{
			laneunderlayOpponent.alpha = cpuStrums.members[0].alpha - FlxG.save.data.laneTransparency;
			laneunderlayOpponent.x = cpuStrums.members[0].x;

			laneunderlay.alpha = playerStrums.members[0].alpha - FlxG.save.data.laneTransparency;
			laneunderlay.x = playerStrums.members[0].x;

			if (SONG.song.toLowerCase() == 'bonedoggle')
			{
				laneunderlayOpponent2.alpha = cpuStrums2.members[0].alpha - FlxG.save.data.laneTransparency;
				laneunderlayOpponent2.x = cpuStrums2.members[0].x;
			}
		}

		if (krBar !=null)
		{
			if (kr<health) {
				kr=health;
				krBar.alpha = 0;
				healthMax.color = 0xFFFFFFFF;
			}
			if (kr>2)
				kr = 2;
			if (kr != health && kr > health) {
				krBar.alpha = healthBar.alpha;
				healthMax.color = 0xFFFF00FF;
				kr -= elapsed / 5.5;
			}
		}

		var obj = null;
		if (obj != null)
		{
			if(FlxG.keys.pressed.Q)
				obj.x--;
			if(FlxG.keys.pressed.W)
				obj.y++;
			if(FlxG.keys.pressed.E)
				obj.y--;
			if(FlxG.keys.pressed.R)
				obj.x++;
			if(FlxG.keys.justPressed.SPACE)
				trace(obj.x + ' ' + obj.y);
		}

		super.update(elapsed);

		if (SONG.notes[Math.floor(curStep / 16)] != null)
		{
			if (SONG.notes[Math.floor(curStep / 16)].altAnim || forceAlt)
			{
				dad.altIdle = true;
			}
			else
			{
				dad.altIdle = false;
			}
		}

		// i toll brightfyre on discord to make every text lowercase if enemy is sans but he ONLY MADE IT IN PAUSE MENU
		// so as always i came and fixed it

		scoreTxt.text = Ratings.CalculateRanking(songScore, songScoreDef, nps, maxNPS, accuracy);
		scoreTxt.screenCenter(X);
		scoreTxt.updateHitbox();

		if (controls.PAUSE && startedCountdown && canPause && !transitioningToState && songStarted)
		{
			pauseGame();
		}

		if ((FlxG.keys.justPressed.SEVEN && !dead && !transitioningToState) && (!isStoryMode || MainMenuState.debugTools))
		{
			cannotDie = true;
			transitioningToState = true;
			DiscordClient.changePresence("Chart Editor", null, null, true);
			FlxG.switchState(new ChartingState());
			Application.current.window.onFocusOut.remove(onWindowFocusOut);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleInput);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);
			if (luaModchart != null)
			{
				luaModchart.die();
				luaModchart = null;
			}
		}

		// FlxG.watch.addQuick('VOL', vocals.amplitudeLeft);
		// FlxG.watch.addQuick('VOLRight', vocals.amplitudeRight);

		var p2width = 150;
		if (dad.curCharacter == 'sansNightmare')
		{
			p2width = 200;
		}
		var iconOffset:Int = 26;

		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
		iconP2.x = (healthBar.x
			+ (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01))
			- (iconP2.width - iconOffset))
			+ iconXOffset;

		if (SONG.song.toLowerCase() == 'imminent-demise' && iconP2alt != null)
		{
			iconP2alt.x = (healthBar.x
				+ (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01))
				- (iconP2alt.width - iconOffset))
				+ iconXOffset;
		}

		if (health > 2)
			health = 2;

		if (iconP2.special)
		{
			if (healthBar.percent > 80 && icon2AnimArray[0])
			{
				animName = 'loss';
			}
			else if (healthBar.percent < 20 && icon2AnimArray[1])
			{
				animName = 'win';
			}
			else
			{
				animName = 'normal';
			}

			if (iconP2.animation.curAnim.finished || (animName != iconP2.animation.curAnim.name))
			{
				iconP2.playAnim(animName, true);
			}
		}
		else if (iconP2.oneframe) {}
		else
		{
			if (healthBar.percent < 20)
				iconP2.animation.curAnim.curFrame = 1;
			else
				iconP2.animation.curAnim.curFrame = 0;
		}

		if (healthBar.percent < 20)
			iconP1.animation.curAnim.curFrame = 1;
		else
			iconP1.animation.curAnim.curFrame = 0;

		if ((SONG.song.toLowerCase() == 'ritual' && curStep > 80) || SONG.song.toLowerCase() != 'ritual')
		{
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
		}

		if (MainMenuState.debugTools)
		{
			if (FlxG.keys.justPressed.LBRACKET)
			{
				defaultCamZoom -= 0.025;
				trace(defaultCamZoom);
			}
			else if (FlxG.keys.justPressed.RBRACKET)
			{
				defaultCamZoom += 0.025;
				trace(defaultCamZoom);
			}

			if (FlxG.keys.justPressed.SIX)
			{
				AnimationDebug.isDad = true;

				FlxG.switchState(new AnimationDebug(dad.curCharacter));
				Application.current.window.onFocusOut.remove(onWindowFocusOut);
				FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleInput);
				FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);
				if (luaModchart != null)
				{
					luaModchart.die();
					luaModchart = null;
				}
			}
			if (FlxG.keys.justPressed.B && MainMenuState.debugTools)
			{
				if (cannotDie)
					cannotDie = false;
				else
					cannotDie = true;
				trace(cannotDie);
			}

			if (FlxG.keys.justPressed.C && MainMenuState.debugTools)
			{
				@:privateAccess
				for (key in FlxG.bitmap._cache.keys())
				{
					if (key.contains('assets'))
					{
						trace('key: ' + key + " is on mem");
					}
				}
			}
			if (FlxG.keys.justPressed.TWO)
			{ // Go 10 seconds into the future, credit: Shadow Mario#9396
				if (!usedTimeTravel && Conductor.songPosition + 10000 < FlxG.sound.music.length)
				{
					usedTimeTravel = true;

					health = 2;
					cupheadPewMode = false;

					FlxG.sound.music.pause();
					vocals.pause();
					Conductor.songPosition += 10000;
					notes.forEachAlive(function(daNote:Note)
					{
						if (daNote.strumTime - 500 < Conductor.songPosition)
						{
							daNote.active = false;
							daNote.visible = false;

							daNote.kill();
							notes.remove(daNote, true);
							daNote.destroy();
						}
					});
					for (i in 0...unspawnNotes.length)
					{
						var daNote:Note = unspawnNotes[0];
						if (daNote.strumTime - 500 >= Conductor.songPosition)
						{
							break;
						}
						unspawnNotes.splice(unspawnNotes.indexOf(daNote), 1);
					}

					FlxG.sound.music.time = Conductor.songPosition;
					FlxG.sound.music.play();

					vocals.time = Conductor.songPosition;
					vocals.play();
					new FlxTimer().start(0.5, function(tmr:FlxTimer)
					{
						usedTimeTravel = false;
					});
				}
			}

			if (FlxG.keys.justPressed.THREE)
			{
				// same as condition above but it goes 10 seconds to the past :)
				if (!usedTimeTravel && Conductor.songPosition - 10000 < FlxG.sound.music.length)
				{
					usedTimeTravel = true;
					FlxG.sound.music.pause();
					vocals.pause();
					Conductor.songPosition -= 10000;

					notes.forEachAlive(function(daNote:Note)
					{
						if (daNote.strumTime - 500 < Conductor.songPosition)
						{
							daNote.active = false;
							daNote.visible = false;

							daNote.kill();
							notes.remove(daNote, true);
							daNote.destroy();
						}
					});
					for (i in 0...unspawnNotes.length)
					{
						var daNote:Note = unspawnNotes[0];
						if (daNote.strumTime - 500 >= Conductor.songPosition)
						{
							break;
						}
						unspawnNotes.splice(unspawnNotes.indexOf(daNote), 1);
					}

					FlxG.sound.music.time = Conductor.songPosition;
					FlxG.sound.music.play();

					vocals.time = Conductor.songPosition;
					vocals.play();
					new FlxTimer().start(0.5, function(tmr:FlxTimer)
					{
						usedTimeTravel = false;
					});
				}
			}
		}

		if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.songPosition += FlxG.elapsed * 1000;
				if (Conductor.songPosition >= 0)
				{
					startSong();
				}
			}
		}
		else
		{
			// Conductor.songPosition = FlxG.sound.music.time;
			Conductor.songPosition += elapsed * 1000 * songSpeed;
			/*@:privateAccess
				{
					FlxG.sound.music._channel.
			}*/
			songPositionBar = Conductor.songPosition;

			if (!paused)
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				// Interpolation type beat
				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
				}
			}

			// Conductor.lastSongPos = FlxG.sound.music.time;
		}

		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);
		FlxG.watch.addQuick("music ms", Math.floor(FlxG.sound.music.time));

		if (health <= 0 && !cannotDie)
		{
			if (curStage != 'hall')
				playerDie();
			else
				{
					if (kr <= 0)
						playerDie();
					else
						kr += health;
					
				}
			health = 0;
			if (kr > 0)
				health = (2 / 99);
		}

		if (FlxG.save.data.resetButton)
		{
			if (FlxG.keys.justPressed.R && !cannotDie && !paused && !videoPlaying && !hasInstruction && !inCutscene && !sansTalking)
			{
				playerDie();
			}
		}

		if (generatedMusic)
		{
			if (cupheadPewMode)
			{
				if (canCupheadShoot && dad.animation.curAnim.name == 'attack1')
				{
					if (dad.curCharacter == 'cupheadNightmare')
					{
						shootOnce(true);
					}
					else
					{
						shootOnce();
					}
					canCupheadShoot = false;
					new FlxTimer().start(0.15, function(tmr:FlxTimer)
					{
						canCupheadShoot = true;
					});
				}
			}
			else if (dad.animation.curAnim.name == 'attack1')
			{
				dad.idleReplacement = '';
				dad.dance();
			}

			var holdArray:Array<Bool> = [controls.LEFT, controls.DOWN, controls.UP, controls.RIGHT];

			notes.forEachAlive(function(daNote:Note)
			{
				// instead of doing stupid y > FlxG.height
				// we be men and actually calculate the time :)
				if (daNote.tooLate)
				{
					daNote.active = false;
					daNote.visible = false;
				}
				else
				{
					daNote.visible = true;
					daNote.active = true;
				}

				if (!daNote.modifiedByLua)
				{
					if (PlayStateChangeables.useDownscroll)
					{
						if (daNote.mustPress && !daNote.player3Note)
							daNote.y = (playerStrums.members[Math.floor(Math.abs(daNote.noteData))].y
								+ 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(songScrollSpeed, 2))
								- daNote.noteYOff
								- daNote.noteYspriteOffset;
						else if (!daNote.mustPress && !daNote.player3Note)
							daNote.y = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y
								+ 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(songScrollSpeed, 2))
								- daNote.noteYOff
								- daNote.noteYspriteOffset;
						else if (daNote.player3Note)
							daNote.y = (cpuStrums2.members[Math.floor(Math.abs(daNote.noteData))].y
								+ 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(songScrollSpeed, 2))
								- daNote.noteYOff
								- daNote.noteYspriteOffset;

						if (daNote.isSustainNote)
						{
							// Remember = minus makes notes go up, plus makes them go down
							if (daNote.animation.curAnim.name.endsWith('end') && daNote.prevNote != null)
								daNote.y += daNote.prevNote.height;
							else
								daNote.y += daNote.height / 2;

							// If not in botplay, only clip sustain notes when properly hit, botplay gets to clip it everytime
							if (!PlayStateChangeables.botPlay && !MainMenuState.showcase)
							{
								if ((!daNote.mustPress
									|| !daNote.player3Note
									|| daNote.wasGoodHit
									|| daNote.prevNote.wasGoodHit
									|| holdArray[Math.floor(Math.abs(daNote.noteData))]
									&& !daNote.tooLate)
									&& daNote.y
									- daNote.offset.y * daNote.scale.y
									+ daNote.height >= (strumLine.y + Note.swagWidth / 2))
								{
									// Clip to strumline
									var swagRect = new FlxRect(0, 0, daNote.frameWidth * 2, daNote.frameHeight * 2);
									swagRect.height = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y
										+ Note.swagWidth / 2
										- daNote.y) / daNote.scale.y;
									swagRect.y = daNote.frameHeight - swagRect.height;

									daNote.clipRect = swagRect;
								}
							}
							else
							{
								var swagRect = new FlxRect(0, 0, daNote.frameWidth * 2, daNote.frameHeight * 2);
								swagRect.height = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y
									+ Note.swagWidth / 2
									- daNote.y) / daNote.scale.y;
								swagRect.y = daNote.frameHeight - swagRect.height;

								daNote.clipRect = swagRect;
							}
						}
					}
					else
					{
						if (daNote.mustPress && !daNote.player3Note)
							daNote.y = (playerStrums.members[Math.floor(Math.abs(daNote.noteData))].y
								- 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(songScrollSpeed, 2))
								+ daNote.noteYOff
								+ daNote.noteYspriteOffset;
						else if (!daNote.mustPress && !daNote.player3Note)
							daNote.y = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y
								- 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(songScrollSpeed, 2))
								+ daNote.noteYOff
								+ daNote.noteYspriteOffset;
						else if (daNote.player3Note)
							daNote.y = (cpuStrums2.members[Math.floor(Math.abs(daNote.noteData))].y
								- 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(songScrollSpeed, 2))
								+ daNote.noteYOff
								+ daNote.noteYspriteOffset;
						if (daNote.isSustainNote)
						{
							daNote.y -= daNote.height / 2;

							if (!PlayStateChangeables.botPlay && !MainMenuState.showcase)
							{
								if ((!daNote.mustPress
									|| !daNote.player3Note
									|| daNote.wasGoodHit
									|| daNote.prevNote.wasGoodHit
									|| holdArray[Math.floor(Math.abs(daNote.noteData))]
									&& !daNote.tooLate)
									&& daNote.y
									+ daNote.offset.y * daNote.scale.y <= (strumLine.y + Note.swagWidth / 2))
								{
									// Clip to strumline
									var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
									swagRect.y = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y
										+ Note.swagWidth / 2
										- daNote.y) / daNote.scale.y;
									swagRect.height -= swagRect.y;

									daNote.clipRect = swagRect;
								}
							}
							else
							{
								var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
								swagRect.y = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y
									+ Note.swagWidth / 2
									- daNote.y) / daNote.scale.y;
								swagRect.height -= swagRect.y;

								daNote.clipRect = swagRect;
							}
						}
					}
				}

				if (daNote.player3Note && daNote.wasGoodHit)
				{
					switch (daNote.noteType)
					{
						case 0 | 2 | 5 | 6 | 8 | 11 | 12:
							{
								var altAnim:String = "";

								if (SONG.notes[Math.floor(curStep / 16)] != null)
								{
									if (SONG.notes[Math.floor(curStep / 16)].altAnim || forceAlt)
										altAnim = '-alt';
								}

								if (curStep < 416)//some unneeded alt notes in the song but cant find em so fuck it
									altAnim = '';

								var delay:Int = 0;

								if (daNote.isSustainNote)
								{
									delay = 3;
								}

								var singData:Int = Std.int(Math.abs(daNote.noteData % 4));

								if (player3.curCharacter != 'none')
								{
									if ((player3.specialAnimList.contains(player3.animation.curAnim.name)
										&& player3.animation.curAnim.finished)
										|| !player3.specialAnimList.contains(player3.animation.curAnim.name))
									{
										player3.playAnim('sing' + dataSuffix[singData] + altAnim, true, false, delay);

										canDancePlayer3 = false;

										player3.animation.finishCallback = function(name:String)
										{
											canDancePlayer3 = true;
										};

										if (camFocus == 'player3')
										{
											triggerCamMovement(Math.abs(daNote.noteData % 4));
										}

										if (player3.curCharacter != 'none')
											player3.holdTimer = 0;
									}
								}

								if (dad.curCharacter.toLowerCase().contains('bend')
									&& !flashing
									&& dad.curCharacter != 'bendyDA'
									&& dad.alpha == 1.0)
								{
									if (!nmStairs || !iskinky)
										FlxG.camera.shake(0.01, 0.01);
									// camHUD.shake(0.05, 0.01);
									if (healthBar.percent > 19.95 && !daNote.isSustainNote && mechanicsEnabled)
									{
										if (!daNote.isSustainNote)
										{
											switch (storyDifficulty)
											{
												case 0:
													healthTween(-0.015);
												case 1:
													healthTween(-0.03);
												case 2:
													healthTween(-0.05);
											}
										}
										else
										{
											healthTween(-0.015);
										}
									}
								}
								cpuStrums2.forEach(function(spr:FlxSprite)
								{
									if (Math.abs(daNote.noteData) == spr.ID)
									{
										spr.animation.play('confirm', true);
									}
									if (spr.animation.curAnim.name == 'confirm')
									{
										spr.centerOffsets();
										spr.offset.x -= 13;
										spr.offset.y -= 13;
									}
									else
										spr.centerOffsets();
								});

								#if cpp
								if (luaModchart != null)
									luaModchart.executeState('playerThreeSing', [Math.abs(daNote.noteData), Conductor.songPosition]);
								#end
							}
					}

					if (HelperFunctions.vocalExists(SONG.song.toLowerCase()))
					{
						if (vocals != null)
						{
							vocals.volume = 1;
						}
					}

					daNote.active = false;

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}

				if (!daNote.mustPress && daNote.wasGoodHit && !daNote.player3Note)
				{
					if (SONG.song.toLowerCase() == 'imminent-demise' && curStep <= 1088) {
						trace('shouldn\'t hit note!!');
						new FlxTimer().start(0.4, function(tmr:FlxTimer) {
							daNote.kill();
							notes.remove(daNote, true);
							daNote.destroy();
						}, 1);
						return;
					}
					switch (daNote.noteType)
					{
						case 0 | 2 | 5 | 6 | 8 | 11 | 12:
							{
								var altAnim:String = "";

								if (SONG.notes[Math.floor(curStep / 16)] != null)
								{
									if (SONG.notes[Math.floor(curStep / 16)].altAnim || forceAlt)
										altAnim = '-alt';
								}

								// if (dad.curCharacter == 'papyrus')
								//	altAnim = '';

								var delay:Int = 0;

								if (daNote.isSustainNote)
								{
									delay = 3;
								}

								var singData:Int = Std.int(Math.abs(daNote.noteData % 4));

								if ((dad.specialAnimList.contains(dad.animation.curAnim.name) && dad.animation.curAnim.finished)
									|| !dad.specialAnimList.contains(dad.animation.curAnim.name))
								{
									dad.holdTimer = 0;
									if (cupheadChaserMode)
									{
										if (dad.animOffsets.exists('pew' + dataSuffix[singData] + altAnim))
										{
											dad.playAnim('pew' + dataSuffix[singData] + altAnim, true, false, delay);
										}
										else
										{
											dad.playAnim('pew' + dataSuffix[singData], true, false, delay);
										}
									}
									else
									{
										if (daNote.noteType != 5)
										{
											if (dad.animOffsets.exists('sing' + dataSuffix[singData] + altAnim))
											{
												dad.playAnim('sing' + dataSuffix[singData] + altAnim, true, false, delay);
											}
											else
											{
												dad.playAnim('sing' + dataSuffix[singData], true, false, delay);
											}
										}

										if (dad.loopedIdle)
										{
											dad.animation.finishCallback = function(name:String)
											{
												charsDance('dad');
											};
										}
									}

									if (vocals != null)
									{
										vocals.volume = 1;
									}

									if (SONG.song.toLowerCase() == 'devils-gambit')
									{
										cupheadPewMode = false;
									}

									if (cupheadChaserMode && !daNote.isSustainNote)
									{
										var chaseOffset:Array<Int> = [0, 0];
										switch (singData)
										{
											case 0:
												chaseOffset = [707, -19];
											case 1:
												chaseOffset = [817, -9];
											case 2:
												chaseOffset = [717, -19];
											case 3:
												chaseOffset = [847, 27];
										}
										chaseOffset[0] -= 140;
										var chaser:CupBullet = new CupBullet('chaser', dad.getMidpoint().x, dad.getMidpoint().y);
										chaser.x += chaseOffset[0];
										chaser.y += chaseOffset[1];
										add(chaser);
										chaser.blend = BlendMode.ADD;
										chaser.state = 'oneshoot';
										chaser.animation.finishCallback = function(name:String)
										{
											remove(chaser);
										};
										chaser.pew = function()
										{
											if (!PlayStateChangeables.botPlay || (PlayStateChangeables.botPlay && MainMenuState.showcase))
											{
												healthChange(-0.02);
											}
										}
										FlxG.sound.play(Paths.sound('attacks/chaser' + FlxG.random.int(0, 4), 'cup'), 0.7);
									}

									canDanceDad = false;

									dad.animation.finishCallback = function(name:String)
									{
										canDanceDad = true;
									};

									if (camFocus == 'dad' && canCameraMove)
									{
										triggerCamMovement(Math.abs(daNote.noteData % 4));
									}

									if (fuckinAngry && !FlxG.save.data.photosensitive)
									{
										FlxG.camera.shake(0.015, 0.1);
										camHUD.shake(0.005, 0.1);

										chromVal = FlxG.random.float(0.005, 0.01);
										FlxTween.tween(this, {chromVal: defaultChromVal}, FlxG.random.float(0.05, 0.12));
									}

									if (dad.curCharacter.toLowerCase().contains('bend')
										&& !flashing
										&& dad.curCharacter != 'bendyDA'
										&& dad.alpha == 1.0
										&& !fuckinAngry)
									{
										if (!iskinky || !nmStairs)
											FlxG.camera.shake(0.01, 0.01);
										if (healthBar.percent > 19.95 && !daNote.isSustainNote && mechanicsEnabled)
										{
											if (!daNote.isSustainNote)
											{
												switch (storyDifficulty)
												{
													case 0:
														healthTween(-0.015);
													case 1:
														healthTween(-0.03);
													case 2:
														healthTween(-0.05);
												}
											}
											else
											{
												healthTween(-0.015);
											}
										}
									}

									if (dad.curCharacter.toLowerCase().contains('devil'))
									{
										if (healthBar.percent > 19.95 && !daNote.isSustainNote && mechanicsEnabled)
										{
											if (!daNote.isSustainNote)
											{
												switch (storyDifficulty)
												{
													case 0:
														healthTween(-0.015);
													case 1:
														healthTween(-0.03);
													case 2:
														healthTween(-0.05);
												}
											}
											else
											{
												healthTween(-0.015);
											}
										}
									}
								}

								cpuStrums.forEach(function(spr:FlxSprite)
								{
									if (Math.abs(daNote.noteData) == spr.ID)
									{
										spr.animation.play('confirm', true);
									}
									if (spr.animation.curAnim.name == 'confirm')
									{
										spr.centerOffsets();
										spr.offset.x -= 13;
										spr.offset.y -= 13;
									}
									else
										spr.centerOffsets();
								});
								altCpuStrums.forEach(function(spr:FlxSprite)
								{
									if (Math.abs(daNote.noteData) == spr.ID)
									{
										spr.animation.play('confirm', true);
									}
									if (spr.animation.curAnim.name == 'confirm')
									{
										spr.centerOffsets();
										spr.offset.x -= 13;
										spr.offset.y -= 13;
									}
									else
										spr.centerOffsets();
								});

								#if cpp
								if (luaModchart != null)
									luaModchart.executeState('playerTwoSing', [Math.abs(daNote.noteData), Conductor.songPosition]);
								#end

							}
					}

					if (HelperFunctions.vocalExists(SONG.song.toLowerCase()))
					{
						if (vocals != null)
						{
							vocals.volume = 1;
						}
					}

					daNote.active = false;

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}

				if (daNote.noteType == 11 || daNote.noteType == 12)
				{
					if (daNote.y <= 600 && !PlayStateChangeables.useDownscroll)
						daNote.bouncing = true;
					else if (daNote.y >= 100 && PlayStateChangeables.useDownscroll)
						daNote.bouncing = true;
				}

				if (daNote.mustPress && !daNote.modifiedByLua)
				{
					daNote.visible = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].visible;
					if (daNote.noteType == 11 || daNote.noteType == 12)
					{
						if (!daNote.bouncing)
							daNote.x = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].x + daNote.noteXspriteOffset - 640;
						else
						{
							if (!daNote.bounced)
							{
								daNote.bounced = true;
								FlxG.sound.play(Paths.sound('ping', 'sans'));
								FlxTween.tween(daNote, {x: daNote.x + 640}, 0.4, {ease: FlxEase.quadInOut});
							}
						}
					}
					else
						daNote.x = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].x + daNote.noteXspriteOffset;

					if (!daNote.isSustainNote)
						daNote.angle = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].angle;
					if (daNote.sustainActive)
						daNote.alpha = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].alpha;
					daNote.alpha = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].alpha;
				}
				else if (daNote.player3Note && !daNote.modifiedByLua && !daNote.mustPress)
				{
					daNote.visible = cpuStrums2.members[Math.floor(Math.abs(daNote.noteData))].visible;
					daNote.x = cpuStrums2.members[Math.floor(Math.abs(daNote.noteData))].x + daNote.noteXspriteOffset;
					if (!daNote.isSustainNote)
						daNote.angle = cpuStrums2.members[Math.floor(Math.abs(daNote.noteData))].angle;
					if (daNote.sustainActive)
						daNote.alpha = cpuStrums2.members[Math.floor(Math.abs(daNote.noteData))].alpha;
					daNote.alpha = cpuStrums2.members[Math.floor(Math.abs(daNote.noteData))].alpha;
				}
				else if (!daNote.wasGoodHit && !daNote.modifiedByLua && !daNote.mustPress)
				{
					daNote.visible = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].visible;
					if (!daNote.bouncing)
					{
						if (daNote.noteType == 11 || daNote.noteType == 12)
						{
							daNote.x = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].x + daNote.noteXspriteOffset - 640;
						}
						else
							daNote.x = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].x + daNote.noteXspriteOffset;
					}
					if (!daNote.isSustainNote)
						daNote.angle = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].angle;
					if (daNote.sustainActive)
						daNote.alpha = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].alpha;
					daNote.alpha = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].alpha;
				}

				if (daNote.isSustainNote)
					daNote.x += daNote.width / 2 + 17;

				if (daNote.isSustainNote && daNote.noteType == 8)
					daNote.x += 16;

				/*if (daNote.isSustainNote && daNote.noteType == 0 && fuckinAngry)
					daNote.x += 16; */

				if ((daNote.mustPress && daNote.tooLate && !PlayStateChangeables.useDownscroll || daNote.mustPress && daNote.tooLate
					&& PlayStateChangeables.useDownscroll)
					&& daNote.mustPress) // umm what is this condition?
				{
					switch (daNote.noteType)
					{
						case 0 | 6 | 8 | 11: // normal, tricky, nightmare/tunnel normal
							if (daNote.isSustainNote && daNote.wasGoodHit)
							{
								daNote.kill();
								notes.remove(daNote, true);
							}
							else
							{
								if (!daNote.isSustainNote)
									healthTween(-0.1);
								if (vocals != null)
								{
									vocals.volume = 0;
								}
								if (!daNote.isSustainNote)
									noteMiss(daNote.noteData, daNote);

								if (daNote.isParent)
								{
									healthTween(-0.2); // give a health punishment for failing a LN
									for (i in daNote.children)
									{
										i.alpha = 0.3;
										i.sustainActive = false;
									}
								}
								else
								{
									if (!daNote.wasGoodHit
										&& daNote.isSustainNote
										&& daNote.sustainActive
										&& daNote.spotInLine != daNote.parent.children.length)
									{
										healthTween(-0.2); // give a health punishment for failing a LNy
										for (i in daNote.parent.children)
										{
											i.alpha = 0.3;
											i.sustainActive = false;
										}
										if (daNote.parent.wasGoodHit)
											misses++;
										updateAccuracy();
									}
								}
							}

							daNote.visible = false;
							daNote.kill();
							notes.remove(daNote, true);
						case 1 | 3 | 4 | 5 | 13: // note types: blue, ink, death, parry, flash, fire
							daNote.kill();
							notes.remove(daNote, true);
							daNote.destroy();
						case 2 | 12: // orange bones
							bigHit(daNote);
						case 7:
							FlxG.sound.play(Paths.sound('flash' + FlxG.random.int(0, 2), 'bendy'));
							daNote.kill();
							notes.remove(daNote, true);
							daNote.destroy();
							vocals.volume = 0;
							flashback.alpha = 1;
							flashing = true;
							flashback.animation.play('play', true);
							var amt:Int = FlxG.random.int(1, 3);
							new FlxTimer().start(0.375, function(tmr:FlxTimer)
							{
								flashback.animation.play('play', true);
							}, (amt - 1));
							FlxG.camera.shake(0.075, 0.375 * amt);
							camHUD.shake(0.05, 0.375 * amt);
							new FlxTimer().start(0.375 * (amt - 1), function(tmr:FlxTimer)
							{
								flashback.alpha = 0.0001;
								flashing = false;
							});
					}
				}

				if (PlayStateChangeables.useDownscroll)
				{
					if (daNote.y < -300)
					{
						daNote.active = false;
						daNote.visible = false;
					}
					else
					{
						daNote.active = true;
						daNote.visible = true;
					}
				}
				else
				{
					if (daNote.y > 1000)
					{
						daNote.active = false;
						daNote.visible = false;
					}
					else
					{
						daNote.active = true;
						daNote.visible = true;
					}
				}
			});
		}

		cpuStrums.forEach(function(spr:FlxSprite)
		{
			if (spr.animation.finished)
			{
				spr.animation.play('static');
				spr.centerOffsets();
			}
		});

		altCpuStrums.forEach(function(spr:FlxSprite)
		{
			if (spr.animation.finished)
			{
				spr.animation.play('static');
				spr.centerOffsets();
			}
		});

		cpuStrums2.forEach(function(spr:FlxSprite)
		{
			if (spr.animation.finished)
			{
				spr.animation.play('static');
				spr.centerOffsets();
			}
		});

		if (PlayStateChangeables.botPlay)
		{
			playerStrums.forEach(function(spr:FlxSprite)
			{
				if (spr.animation.finished)
				{
					spr.animation.play('static');
					spr.centerOffsets();
				}
			});
			altPlayerStrums.forEach(function(spr:FlxSprite)
			{
				if (spr.animation.finished)
				{
					spr.animation.play('static');
					spr.centerOffsets();
				}
			});
		}

		if (!inCutscene)
			keyShit();

		//inkFade();

		if (FlxG.keys.justPressed.ONE && FlxG.keys.pressed.CONTROL && MainMenuState.debugTools)
		{
			if (isStoryMode
				&& (SONG.song.toLowerCase() == "knockout"
					|| SONG.song.toLowerCase() == "final-stretch"
					|| SONG.song.toLowerCase() == "burning-in-hell"
					|| SONG.song.toLowerCase() == "nightmare-run"))
			{
				partyFinale();
			}
			else
			{
				partyIsOver();
			}
		}

		if (SONG.song.toLowerCase() == 'nightmare-run' && !nmStairs && !iskinky)
		{
			if (!forcesize)
			{
				boyfriend.x = FlxMath.lerp(boyfriend.x, 1040 + (health * 100), 0.07);
				dad.x = FlxMath.lerp(dad.x, -400 + (health * -300), 0.07);
			}
			
			// defaultBrightVal = -0.20 + (health * 0.05); hmm???
			canCameraMove = true;

			if (health > 1)
				boyfriend.idleReplacement = 'idle';
			else
				boyfriend.idleReplacement = 'idle2';

			if (!overrideNMZoom)
			{
			if (health < 0.99)
			{
				defaultCamZoom = 0.85 + (health * -0.35);
				camMovement = FlxTween.tween(camFollow, {x: bfPos[0] + 100, y: bfPos[1] + 25}, camLerp, {ease: FlxEase.quintOut}); // bad
			}
			else if (health >= 1.00 && curStep >= 1)
				defaultCamZoom = 0.55;
			}
		}
		else if (SONG.song.toLowerCase() == 'nightmare-run' && nmStairs)
		{
			defaultCamZoom = 1;
			camMovement = FlxTween.tween(camFollow, {x: 500, y: 500}, camLerp, {ease: FlxEase.quintOut});
			canCameraMove = false;

			if (health > 1)
				boyfriend.idleReplacement = 'idle';
			else
				boyfriend.idleReplacement = 'idle2';
		}
	}

	var enXOff = 0;
	var enYOff = 0;
	var pXOff = 0;
	var pYOff = 0;

	function camOffsetGet()
	{
		switch (curStage)
		{
			case('factory'):
				pYOff = -200;
				pXOff = 70;
				enYOff = -200;
		}
	}

	var attacktimes:Int = 0;

	function genocideShit()
	{
		if (SONG.song.toLowerCase() == 'sansational')
		{
			attacktimes++;
			if (attacktimes == 3)
			{
				new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
				{
					FlxG.sound.play(Paths.sound('genocide', 'sans'));
				});

				geno = true;
			}
		}
	}

	function pacifistShit()
	{
		geno = false;
		FlxG.save.data.haspacifisted = true;
		pushToAchievementIDS("Pacifist", true);
	}
	

	function partyFinale():Void // tried a couple hours but got a idea to use a different function all together will prob finish it later tomorrow
	{
		var scoreMultiplier:Float = 1.25 - (0.25 * mechanicType); // should be 0.75 if the mechanics are off !
		if (HelperFunctions.getSongData(PlayState.SONG.song.toLowerCase(), 'hasmech') == 'false')
			scoreMultiplier == 1;
		songScore = Math.round(songScore * scoreMultiplier);

		jumpscareTimerAmt = 2000000;


		StoryMenuState.leftDuringWeek = false;

		StoryMenuState.fromWeek = storyWeek;
		FreeplayState.fromWeek = storyWeek;

		FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleInput);
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);

		trace('trigger ending of story week'); // MUTE MUSIC/VOCALS
		songOver = true;
		inCutscene = true;
		canPause = false;
		FlxG.sound.music.volume = 0;
		FlxG.sound.music.pause();

		if (vocals != null)
		{
			vocals.stop();
			vocals.destroy();
		}
		vocals = null;

		if (FlxG.save.data.fpsCap > 290) // FPS CAP
			(cast(Lib.current.getChildAt(0), Main)).setFPSCap(290);

		#if cpp // REMOVE MODCHART
		if (luaModchart != null)
		{
			luaModchart.die();
			luaModchart = null;
		}
		#end

		if (SONG.validScore) // SAVE SCORE
		{
			var daDifficulty:Int = storyDifficulty;


			if ((SONG.song.toLowerCase() == 'final-stretch' || SONG.song.toLowerCase() == 'burning-in-hell')
				&& storyDifficulty != difficulty)
			{
				daDifficulty = difficulty;
			}

			Highscore.saveWeekScore(storyWeek, campaignScore, daDifficulty);

			// adjusting the highscore song name to be compatible
			// would read original scores if we didn't change packages
			var songHighscore = StringTools.replace(PlayState.SONG.song, " ", "-");

			Highscore.saveScore(songHighscore, Math.round(songScore), storyDifficulty);
			Highscore.saveCombo(songHighscore, Ratings.GenerateLetterRank(accuracy), storyDifficulty);

			Highscore.saveWeekScore(storyWeek, campaignScore, daDifficulty);

			FlxG.save.flush();
		}

		if (isStoryMode) // ACHIVEMENT CONDITIONS
		{
			if (SONG.song.toLowerCase() == 'sansational')
			{
				if (geno)
				{
					storyPlaylist.push('Burning-In-Hell');
				}
				else
				{
					storyPlaylist.push('Final-Stretch');
				}
			}

			trace(storyPlaylist);

			storyPlaylist.remove(storyPlaylist[0]);

			trace("new" + storyPlaylist);
		}

		checkAchievements();

		var suffix:String = ''; // GENOCIDE CHECK (Sans Only)
		if (geno)
		{
			suffix = 'b';
		}

		notes.forEachAlive(function(daNote:Note) // KILL NOTES
		{
			daNote.kill();
			notes.remove(daNote, true);
			daNote.destroy();
		});

		for (i in 0...unspawnNotes.length)
		{
			var daNote:Note = unspawnNotes[0];
			unspawnNotes.splice(unspawnNotes.indexOf(daNote), 1);
		}

		defaultBrightVal = 0;
		brightSpeed = 0;
		brightMagnitude = 0;
		setBrightness(0);

		camGame.visible = false; // PLAY CUTSCENE DIRECTLY
		camHUD.visible = false;
		camOVERLAY.visible = false;
		canPause = false;
		var video:VideoHandler = new VideoHandler();
		video.fadeFromBlack = true;
		video.allowSkip = false;

		if (MainMenuState.debugTools)
		{
			trace('allowing skip');
			video.allowSkip = true;
		}

		video.finishCallback = function()
		{
			Conductor.changeBPM(Main.menubpm);	
			if ((FlxG.save.data.weeksbeat[0] && FlxG.save.data.weeksbeat[1] && FlxG.save.data.weeksbeat[2]) && storyWeek == 2)
			{
				MainMenuState.showCredits = true;
				pushToAchievementIDS("The End", true);
				Main.switchState(new MainMenuState());
			}
			else
			{
				Main.switchState(new StoryMenuState());
			}
		};

		cutsceneSpr = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(cutsceneSpr);
		cutsceneSpr.cameras = [camSUBTITLES];
		camSUBTITLES.visible = true;
		
		switch (SONG.song.toLowerCase())
		{
			case 'knockout':
				video.playMP4(Paths.video('cuphead/4'), false, cutsceneSpr, false, true);
			case 'final-stretch':
				video.playMP4(Paths.video('sans/4'), false, cutsceneSpr, false, true);
			case 'burning-in-hell':
				video.playMP4(Paths.video('sans/4b'), false, cutsceneSpr, false, true);
			case 'last-reel':
				video.playMP4(Paths.video('bendy/4ez'), false, cutsceneSpr, false, true);
			case 'nightmare-run':
				{
					video.playMP4(Paths.video('bendy/5'), false, cutsceneSpr, false, true);
					pushSubtitle('Those who mess with the Ink Demon...', 7.833, 11.542, false);
					pushSubtitle('shall pay.', 11.542, 13.833, false);
				}

			new FlxTimer().start(0.10, function(tmr:FlxTimer) //keeps that white flash from happening
				{
					cutsceneSpr.color = FlxColor.WHITE;
				});
		}
	}

	function partyIsOver():Void
	{
		var scoreMultiplier:Float = 1.25 - (0.25 * mechanicType); // should be 0.75 if the mechanics are off !
		if (HelperFunctions.getSongData(PlayState.SONG.song.toLowerCase(), 'hasmech') == 'false')
			scoreMultiplier == 1;
		songScore = Std.int(songScore * scoreMultiplier);

		FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleInput);
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);

		StoryMenuState.fromWeek = storyWeek;
		FreeplayState.fromWeek = storyWeek;

		trace('ending');

		if (FlxG.save.data.fpsCap > 290)
			(cast(Lib.current.getChildAt(0), Main)).setFPSCap(290);

		#if cpp
		if (luaModchart != null)
		{
			luaModchart.die();
			luaModchart = null;
		}
		#end

		canPause = false;
		if (FlxG.sound.music != null)
		{
			FlxG.sound.music.volume = 0;
			FlxG.sound.music.pause();
		}

		if (vocals != null)
		{
			vocals.stop();
			vocals.destroy();
		}
		vocals = null;

		if (SONG.validScore)
		{
			// adjusting the highscore song name to be compatible
			// would read original scores if we didn't change packages
			var songHighscore = StringTools.replace(PlayState.SONG.song, " ", "-");

			Highscore.saveScore(songHighscore, Math.round(songScore), storyDifficulty);
			Highscore.saveCombo(songHighscore, Ratings.GenerateLetterRank(accuracy), storyDifficulty);
		}

		if (isStoryMode)
		{
			if (SONG.song.toLowerCase() == 'sansational')
			{
				storyDifficulty = 2;
				if (geno)
				{
					storyPlaylist.push('Burning-In-Hell');
				}
				else
				{
					storyPlaylist.push('Final-Stretch');
				}
			}

			trace(storyPlaylist);

			storyPlaylist.remove(storyPlaylist[0]);

			trace("new" + storyPlaylist);
		}

		checkAchievements();

		var suffix:String = '';
		if (geno)
		{
			suffix = 'b';
		}

		if (isStoryMode && (storyPlaylist.length <= 0 && SONG.song.toLowerCase() != 'sansational'))
		{
			if (FileSystem.exists(Paths.video(cutPrefix + '/' + (storyIndex + 1) + suffix)))
			{
				camGame.visible = false;
				camHUD.visible = false;
				camOVERLAY.visible = false;

				checkCut((cutPrefix + '/' + (storyIndex + 1) + suffix).toString(), endSong);
			}
			else
			{
				endSong();
			}
		}
		else
		{
			endSong();
		}
	}

	function checkHiddenChars()
	{
		switch (dad.curCharacter)
		{
			case 'devilFull':
				FlxG.save.data.secretChars[0] = false;
			case 'sammy':
				FlxG.save.data.secretChars[3] = false;
			case 'bendyDA':
				FlxG.save.data.secretChars[4] = false;
			case 'cupheadNightmare':
				FlxG.save.data.secretChars[5] = false;
			case 'sansNightmare':
				FlxG.save.data.secretChars[6] = false;
			case 'bendyNightmare':
				FlxG.save.data.secretChars[7] = false;
		}
		switch (SONG.song.toLowerCase())
		{
			case 'bad-to-the-bone':
				FlxG.save.data.secretChars[1] = false;
			case 'bonedoggle':
				FlxG.save.data.secretChars[2] = false;
		}
	}

	var songOver:Bool = false;

	function endSong():Void
	{
		if (dodgeAmt == 0 && SONG.song.toLowerCase() == 'last-reel' && storyDifficulty == 2)
		{
			pushToAchievementIDS("Courage", true);
		}
		else
		{
			trace('dodgeAmt: ' + dodgeAmt);
			trace('song: ' + SONG.song.toLowerCase());
			trace('story difficulty: ' + storyDifficulty);
		}

		deathCount = 0;
		OptionsMenu.returnedfromOptions = false;

		Application.current.window.onFocusOut.remove(onWindowFocusOut);

		canPause = false;

		Conductor.songPosition = FlxG.sound.music.length;

		FlxG.sound.music.stop();

		if (vocals != null)
		{
			vocals.stop();
			vocals.destroy();
		}
		vocals = null;

		notes.forEachAlive(function(daNote:Note)
		{
			daNote.kill();
			notes.remove(daNote, true);
			daNote.destroy();
		});

		for (i in 0...unspawnNotes.length)
		{
			var daNote:Note = unspawnNotes[0];
			unspawnNotes.splice(unspawnNotes.indexOf(daNote), 1);
		}

		songOver = true;

		if (offsetTesting)
		{
			FlxG.sound.playMusic(Paths.music(Main.menuMusic));
			Conductor.changeBPM(Main.menubpm);
			offsetTesting = false;
			LoadingState.loadAndSwitchState(new OptionsMenu());
			FlxG.save.data.offset = offsetTest;
		}
		else
		{
			if (isStoryMode)
			{
				campaignScore += Math.round(songScore);

				if (storyPlaylist.length <= 0)
				{
					paused = true;

					#if cpp
					if (luaModchart != null)
					{
						luaModchart.die();
						luaModchart = null;
					}
					#end

					Application.current.window.title = Main.appTitle;

					storyIndex = 1;

					FlxG.sound.playMusic(Paths.music(Main.menuMusic));
					Conductor.changeBPM(Main.menubpm);

					OptionsMenu.returnedfromOptions = false;
					Main.switchState(new MainMenuState());
				}
				else
				{
					OptionsMenu.returnedfromOptions = false;
					var songFormat = StringTools.replace(PlayState.storyPlaylist[0], " ", "-");

					var poop:String = Highscore.formatSong(songFormat, storyDifficulty);
					prevCamFollow = camFollow;

					HelperFunctions.checkExistingChart(PlayState.storyPlaylist[0], poop);

					FlxG.sound.music.stop();

					playCutscene = true;

					storyIndex += 1;

					LoadingState.target = new PlayState();
					LoadingState.stopMusic = true;

					// cuphead transitions
					if (curStage == 'field' || curStage == 'devilHall')
					{
						FNFState.disableNextTransIn = true;
						FNFState.disableNextTransOut = true;
						cupteaBackout();
						FlxG.sound.play(Paths.sound('boing', 'cup'), 1);
						new FlxTimer().start(1.1, function(tmr:FlxTimer)
						{
							FlxG.switchState(new LoadingState());
						});
					}
					else
					{
						FlxG.switchState(new LoadingState());
					}
				}
			}
			else
			{
				paused = true;

				Application.current.window.title = Main.appTitle;

				if (curStage == 'field' || curStage == 'devilHall')
				{
					OptionsMenu.returnedfromOptions = false;
					FNFState.disableNextTransOut = true;
					cupteaBackout();
					new FlxTimer().start(0.666, function(tmr:FlxTimer)
					{
						Main.switchState(new FreeplayState());
					});
				}
				else
				{
					if (SONG.song.toLowerCase().contains('gose'))
					{
						Sys.exit(0);
					}
					else
					{
						OptionsMenu.returnedfromOptions = false;
						Main.switchState(new FreeplayState());
					}
				}
			}
		}
	}

	var hits:Array<Float> = [];
	var offsetTest:Float = 0;
	var timeShown = 0;
	var currentTimingShown:FlxText = null;

	private function popUpScore(daNote:Note, ?extraHeal:Bool):Void
	{
		if (FlxG.save.data.hitsounds)
		{
			FlxG.sound.play(Paths.sound('hitsounds', 'shared'), 0.6);
		}

		var daRating = daNote.rating;

		var funneRating:String = daRating;

		if (overrideDaSploosh)
		{
			funneRating = 'sick';
		}

		showSploosh(daNote, funneRating);

		if ((!PlayStateChangeables.botPlay || (PlayStateChangeables.botPlay && MainMenuState.showcase)))
		{
			var noteDiff:Float = -(daNote.strumTime - Conductor.songPosition);
			var wife:Float = EtternaFunctions.wife3(-noteDiff, Conductor.timeScale);
			// boyfriend.playAnim('hey');
			vocals.volume = 1;
			var placement:String = Std.string(combo);

			var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
			coolText.screenCenter();
			coolText.x = FlxG.width * 0.55;
			coolText.y -= 350;
			coolText.cameras = [camGame];

			var rating:FlxSprite = new FlxSprite();
			rating.scrollFactor.set();
			var score:Float = 350;

			if (FlxG.save.data.accuracyMod == 1)
				totalNotesHit += wife;

			var healthincrease:Float = 0.0;

			switch (daRating)
			{
				case 'shit':
					score = -300;
					combo = 0;
					misses++;
					healthincrease = -0.2;
					ss = false;
					shits++;
					if (FlxG.save.data.accuracyMod == 0)
						totalNotesHit -= 1;
				case 'bad':
					daRating = 'bad';
					score = 0;
					healthincrease = -0.06;
					ss = false;
					bads++;
					if (FlxG.save.data.accuracyMod == 0)
						totalNotesHit += 0.50;
				case 'good':
					daRating = 'good';
					score = 200;
					ss = false;
					goods++;
					if (health < 2)
						if (canheal)
						{
							if (extraHeal)
							{
								healthincrease = 0.08;
							}
							else
							{
								healthincrease = 0.04;
							}
						}
						else
							healthincrease = 0;

					if (FlxG.save.data.accuracyMod == 0)
						totalNotesHit += 0.75;
				case 'sick':
					if (health < 2)
						if (canheal)
						{
							if (extraHeal)
							{
								healthincrease = 0.2;
							}
							else
							{
								healthincrease = 0.1;
							}
						}
						else
							healthincrease = 0;

					if (FlxG.save.data.accuracyMod == 0)
						totalNotesHit += 1;
					sicks++;
					if (SONG.song.toLowerCase() == 'technicolor-tussle'
						|| SONG.song.toLowerCase() == 'knockout'
						|| SONG.song.toLowerCase() == 'devils-gambit')
					{
						if (cardfloat <= 200)
							cardtweening(1.75);
						else
						{
							if (poped)
							{
								trace('played pop anim');
								poped = false;
								cardanims.animation.play('pop');
								cardanims.alpha = 1;
								cardbar.alpha = 0;
							}
						}
					}
			}
			if (canheal)
				healthTween(healthincrease);

			if (curStage == 'hall')
				krTween(healthincrease);

			if (daRating != 'shit' || daRating != 'bad')
			{
				songScore += Math.round(score);
				songScoreDef += Math.round(convertScore(noteDiff));

				rating.loadGraphic(Paths.image(daRating));
				rating.screenCenter();
				rating.y -= 50;
				rating.x = coolText.x - 125;

				if (FlxG.save.data.changedHit)
				{
					rating.x = FlxG.save.data.changedHitX;
					rating.y = FlxG.save.data.changedHitY;
				}
				rating.acceleration.y = 550;
				rating.velocity.y -= FlxG.random.int(140, 175);
				rating.velocity.x -= FlxG.random.int(0, 10);

				var msTiming = HelperFunctions.truncateFloat(noteDiff, 3);
				if ((PlayStateChangeables.botPlay && !MainMenuState.showcase))
					msTiming = 0;

				if (currentTimingShown != null)
					remove(currentTimingShown);

				currentTimingShown = new FlxText(0, 0, 0, "0ms");
				timeShown = 0;
				currentTimingShown.setFormat(Paths.font("Bronx.otf"), 32);

				switch (daRating)
				{
					case 'shit' | 'bad':
						currentTimingShown.color = FlxColor.RED;
					case 'good':
						currentTimingShown.color = FlxColor.GREEN;
					case 'sick':
						currentTimingShown.color = FlxColor.CYAN;
				}

				currentTimingShown.borderStyle = OUTLINE;
				currentTimingShown.borderSize = 1;
				currentTimingShown.borderColor = FlxColor.BLACK;
				currentTimingShown.text = msTiming + "ms";
				currentTimingShown.scrollFactor.set(0, 0);
				currentTimingShown.antialiasing = FlxG.save.data.highQuality;

				if (msTiming >= 0.03 && offsetTesting)
				{
					// Remove Outliers
					hits.shift();
					hits.shift();
					hits.shift();
					hits.pop();
					hits.pop();

					hits.pop();
					hits.push(msTiming);

					var total = 0.0;

					for (i in hits)
						total += i;

					offsetTest = HelperFunctions.truncateFloat(total / hits.length, 2);
				}

				if (currentTimingShown.alpha != 1)
					currentTimingShown.alpha = 1;

				if ((!PlayStateChangeables.botPlay || (PlayStateChangeables.botPlay && MainMenuState.showcase)) && FlxG.save.data.showms)
					add(currentTimingShown);

				currentTimingShown.screenCenter();
				currentTimingShown.x = rating.x + 100;
				currentTimingShown.y = rating.y + 100;
				currentTimingShown.acceleration.y = 600;
				currentTimingShown.velocity.y -= 150;

				currentTimingShown.velocity.x += FlxG.random.int(1, 10);
				if (!PlayStateChangeables.botPlay || (PlayStateChangeables.botPlay && MainMenuState.showcase))
					add(rating);

				rating.setGraphicSize(Std.int(rating.width * 0.7));
				rating.antialiasing = FlxG.save.data.highquality;

				currentTimingShown.updateHitbox();

				rating.updateHitbox();

				currentTimingShown.cameras = [camHUD];
				rating.cameras = [camHUD];

				var seperatedScore:Array<Int> = [];

				var comboSplit:Array<String> = (combo + "").split('');

				// make sure we have 3 digits to display (looks weird otherwise lol)
				if (comboSplit.length == 1)
				{
					seperatedScore.push(0);
					seperatedScore.push(0);
				}
				else if (comboSplit.length == 2)
					seperatedScore.push(0);

				for (i in 0...comboSplit.length)
				{
					var str:String = comboSplit[i];
					seperatedScore.push(Std.parseInt(str));
				}

				var daLoop:Int = 0;
				for (i in seperatedScore)
				{
					var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image('num' + Std.int(i)));
					numScore.scrollFactor.set();
					numScore.screenCenter();
					numScore.x = rating.x + (43 * daLoop) - 50;
					numScore.y = rating.y + 100;
					numScore.cameras = [camHUD];

					numScore.antialiasing = FlxG.save.data.highquality;
					numScore.setGraphicSize(Std.int(numScore.width * 0.5));
					numScore.updateHitbox();

					numScore.acceleration.y = FlxG.random.int(200, 300);
					numScore.velocity.y -= FlxG.random.int(140, 160);
					numScore.velocity.x = FlxG.random.float(-5, 5);

					add(numScore);

					visibleCombos.push(numScore);

					FlxTween.tween(numScore, {alpha: 0}, 0.2, {
						onComplete: function(tween:FlxTween)
						{
							visibleCombos.remove(numScore);
							numScore.destroy();
						},
						onUpdate: function(tween:FlxTween)
						{
							if (!visibleCombos.contains(numScore))
							{
								numScore.destroy();
								tween.cancel();
							}
						},
						startDelay: Conductor.crochet * 0.002
					});

					if (visibleCombos.length > 25)
					{
						for (i in 0...seperatedScore.length - 1)
						{
							visibleCombos.remove(visibleCombos[visibleCombos.length - 1]);
						}
					}

					daLoop++;
				}

				coolText.text = Std.string(seperatedScore);
				// add(coolText);

				FlxTween.tween(rating, {alpha: 0}, 0.2, {
					startDelay: Conductor.crochet * 0.001,
					onUpdate: function(tween:FlxTween)
					{
						if (currentTimingShown != null)
							currentTimingShown.alpha -= 0.02;
						timeShown++;
					},
					onComplete: function(tween:FlxTween)
					{
						rating.destroy();
					}
				});

				new FlxTimer().start(Conductor.crochet * 0.001, function(tmr:FlxTimer)
				{
					coolText.destroy();
					if (currentTimingShown != null && timeShown >= 20)
					{
						remove(currentTimingShown);
						currentTimingShown = null;
					}
				});
			}
		}
	}

	function showSploosh(daNote:Note, daRating:String)
	{
		if (daRating == 'sick')
		{
			var sploosh:Notesplash = new Notesplash(daNote.x, playerStrums.members[daNote.noteData].y, daNote.noteType, daNote.noteData);
			add(sploosh);
			sploosh.playStatePlay();
			sploosh.cameras = [camHUD];
		}
	}

	public function NearlyEquals(value1:Float, value2:Float, unimportantDifference:Float = 10):Bool
	{
		return Math.abs(FlxMath.roundDecimal(value1, 1) - FlxMath.roundDecimal(value2, 1)) < unimportantDifference;
	}

	var upHold:Bool = false;
	var downHold:Bool = false;
	var rightHold:Bool = false;
	var leftHold:Bool = false;

	// THIS FUNCTION JUST FUCKS WIT HELD NOTES AND BOTPLAY/REPLAY (also gamepad shit)

	private function keyShit():Void // I've invested in emma stocks
	{
		// control arrays, order L D R U
		var holdArray:Array<Bool> = [controls.LEFT, controls.DOWN, controls.UP, controls.RIGHT];
		var pressArray:Array<Bool> = [controls.LEFT_P, controls.DOWN_P, controls.UP_P, controls.RIGHT_P];
		var releaseArray:Array<Bool> = [controls.LEFT_R, controls.DOWN_R, controls.UP_R, controls.RIGHT_R];
		#if cpp
		if (luaModchart != null)
		{
			if (controls.LEFT_P)
			{
				luaModchart.executeState('keyPressed', ["left"]);
			};
			if (controls.DOWN_P)
			{
				luaModchart.executeState('keyPressed', ["down"]);
			};
			if (controls.UP_P)
			{
				luaModchart.executeState('keyPressed', ["up"]);
			};
			if (controls.RIGHT_P)
			{
				luaModchart.executeState('keyPressed', ["right"]);
			};
		};
		#end

		// Prevent player input if botplay is on
		if (PlayStateChangeables.botPlay && !MainMenuState.showcase)
		{
			holdArray = [false, false, false, false];
			pressArray = [false, false, false, false];
			releaseArray = [false, false, false, false];
		}

		// HOLDS, check for sustain notes
		if (holdArray.contains(true) && generatedMusic)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.isSustainNote && daNote.canBeHit && daNote.mustPress && holdArray[daNote.noteData])
					goodNoteHit(daNote);
			});
		}

		if (KeyBinds.gamepad && !FlxG.keys.justPressed.ANY)
		{
			// PRESSES, check for note hits
			if (pressArray.contains(true) && generatedMusic)
			{
				var possibleNotes:Array<Note> = []; // notes that can be hit
				var directionList:Array<Int> = []; // directions that can be hit
				var dumbNotes:Array<Note> = []; // notes to kill later
				var directionsAccounted:Array<Bool> = [false, false, false, false]; // we don't want to do judgments for more than one presses

				notes.forEachAlive(function(daNote:Note)
				{
					if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit && !directionsAccounted[daNote.noteData])
					{
						if (directionList.contains(daNote.noteData))
						{
							directionsAccounted[daNote.noteData] = true;
							for (coolNote in possibleNotes)
							{
								if (coolNote.noteData == daNote.noteData && Math.abs(daNote.strumTime - coolNote.strumTime) < 10)
								{ // if it's the same note twice at < 10ms distance, just delete it
									// EXCEPT u cant delete it in this loop cuz it fucks with the collection lol
									dumbNotes.push(daNote);
									break;
								}
								else if (coolNote.noteData == daNote.noteData && daNote.strumTime < coolNote.strumTime)
								{ // if daNote is earlier than existing note (coolNote), replace
									possibleNotes.remove(coolNote);
									possibleNotes.push(daNote);
									break;
								}
							}
						}
						else
						{
							possibleNotes.push(daNote);
							directionList.push(daNote.noteData);
						}
					}
				});

				for (note in dumbNotes)
				{
					FlxG.log.add("killing dumb ass note at " + note.strumTime);
					note.kill();
					notes.remove(note, true);
					note.destroy();
				}

				possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));
				if (perfectMode)
					goodNoteHit(possibleNotes[0]);
				else if (possibleNotes.length > 0)
				{
					if (!FlxG.save.data.ghost && !utmode)
					{
						for (shit in 0...pressArray.length)
						{ // if a direction is hit that shouldn't be
							if (pressArray[shit] && !directionList.contains(shit))
								noteMiss(shit, null);
						}
					}
					for (coolNote in possibleNotes)
					{
						if (pressArray[coolNote.noteData])
						{
							if (mashViolations != 0)
								mashViolations--;
							scoreTxt.color = FlxColor.WHITE;
							var noteDiff:Float = -(coolNote.strumTime - Conductor.songPosition);
							goodNoteHit(coolNote);
						}
					}
				}
				else if (!FlxG.save.data.ghost && !utmode)
				{
					for (shit in 0...pressArray.length)
						if (pressArray[shit])
							noteMiss(shit, null);
				}
			}
		}
		notes.forEachAlive(function(daNote:Note)
		{
			if (PlayStateChangeables.useDownscroll && daNote.y > strumLine.y || !PlayStateChangeables.useDownscroll && daNote.y < strumLine.y)
			{
				// Force good note hit regardless if it's too late to hit it or not as a fail safe
				if ((PlayStateChangeables.botPlay || MainMenuState.showcase)
					&& daNote.canBeHit
					&& daNote.mustPress
					|| (MainMenuState.showcase || PlayStateChangeables.botPlay)
					&& daNote.tooLate
					&& daNote.mustPress)
				{
					switch (daNote.noteType)
					{
						case 0 | 2 | 5 | 6 | 7 | 8 | 11 | 12:
							{
								goodNoteHit(daNote);
								if ((boyfriend.specialAnimList.contains(boyfriend.animation.curAnim.name) && boyfriend.animation.curAnim.finished)
									|| !boyfriend.specialAnimList.contains(boyfriend.animation.curAnim.name))
									boyfriend.holdTimer = daNote.sustainLength;
							}
					}
				}
			}
		});

		if (boyfriend.holdTimer > Conductor.stepCrochet * 4 * 0.001
			&& (!holdArray.contains(true) || (MainMenuState.showcase || PlayStateChangeables.botPlay)))
		{
			var altAnim:String = '';
			if (bfBendoCustomExpression != '')
			{
				altAnim = bfBendoCustomExpression;
			}
			if (boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss'))
				boyfriend.dance(altAnim);
		}

		playerStrums.forEach(function(spr:FlxSprite)
		{
			if (pressArray[spr.ID] && spr.animation.curAnim.name != 'confirm' && spr.animation.curAnim.name != 'pressed' && !utmode)
				spr.animation.play('pressed');

			if (!holdArray[spr.ID])
				spr.animation.play('static');

			if (spr.animation.curAnim.name == 'confirm' && !curStage.startsWith('school'))
			{
				spr.centerOffsets();
				spr.offset.x -= 13;
				spr.offset.y -= 13;
			}
			else
				spr.centerOffsets();
		});

		altPlayerStrums.forEach(function(spr:FlxSprite)
		{
			if (pressArray[spr.ID] && spr.animation.curAnim.name != 'confirm' && spr.animation.curAnim.name != 'pressed')
				spr.animation.play('pressed');

			if (!holdArray[spr.ID])
				spr.animation.play('static');

			if (spr.animation.curAnim.name == 'confirm' && !curStage.startsWith('school'))
			{
				spr.centerOffsets();
				spr.offset.x -= 13;
				spr.offset.y -= 13;
			}
			else
				spr.centerOffsets();
		});
	}

	function noteMiss(direction:Int = 1, daNote:Note):Void
	{
		if (!boyfriend.stunned)
		{

			if (curStage == 'hall')
				updatesansbars();

			if (daNote.noteType == 12 && mechanicType == 1)
			{
				healthTween(-0.5); // 25% health :)
			}

			if (fuckinAngry)
			{
				healthTween(-0.1);
			}
			else
			{
				healthTween(-0.06);
			}

			combo = 0;
			misses++;

			// var noteDiff:Float = Math.abs(daNote.strumTime - Conductor.songPosition);
			// var wife:Float = EtternaFunctions.wife3(noteDiff, FlxG.save.data.etternaMode ? 1 : 1.7);

			if (FlxG.save.data.accuracyMod == 1)
				totalNotesHit -= 1;

			songScore -= 10;

			if (combo > 10)
			{
				// FlxG.sound.play(Paths.soundRandom('bigmiss', 1, 3), 0.7);
			}
			else
			{
				// FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), 0.7);
			}

			if ((boyfriend.specialAnimList.contains(boyfriend.animation.curAnim.name) && boyfriend.animation.curAnim.finished)
				|| !boyfriend.specialAnimList.contains(boyfriend.animation.curAnim.name))
				boyfriend.playAnim('sing' + dataSuffix[direction % 4] + 'miss', true);

			canDanceBF = false;

			boyfriend.animation.finishCallback = function(name:String)
			{
				canDanceBF = true;
			};

			if (camFocus == 'bf')
			{
				triggerCamMovement(direction % 4);
			}

			#if cpp
			if (luaModchart != null)
				luaModchart.executeState('playerOneMiss', [direction, Conductor.songPosition]);
			#end

			updateAccuracy();
			// FlxG.camera.shake(0.1, 0.2);
		}
	}

	function updateAccuracy()
	{
		totalPlayed += 1;
		accuracy = Math.max(0, totalNotesHit / totalPlayed * 100);
		accuracyDefault = Math.max(0, totalNotesHitDefault / totalPlayed * 100);
	}

	function getKeyPresses(note:Note):Int
	{
		var possibleNotes:Array<Note> = []; // copypasted but you already know that

		notes.forEachAlive(function(daNote:Note)
		{
			if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate)
			{
				possibleNotes.push(daNote);
				possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));
			}
		});
		if (possibleNotes.length == 1)
			return possibleNotes.length + 1;
		return possibleNotes.length;
	}

	var mashing:Int = 0;
	var mashViolations:Int = 0;
	var etternaModeScore:Int = 0;

	var noteHitRating:Int = 0;

	function noteCheck(controlArray:Array<Bool>, note:Note):Void // sorry lol
	{
		var noteDiff:Float = -(note.strumTime - Conductor.songPosition);

		note.rating = Ratings.judgeNote(noteDiff);

		if (controlArray[note.noteData])
		{
			goodNoteHit(note, (mashing > getKeyPresses(note)));
		}
	}

	function goodNoteHit(note:Note, resetMashViolation = true):Void
	{
		if (mashing != 0)
			mashing = 0;

		var noteDiff:Float = -(note.strumTime - Conductor.songPosition);

		note.rating = Ratings.judgeNote(noteDiff);

		if (note.rating == "miss")
			return;

		noteHitRating++;
		if (note.rating == "sick")
			noteHitRating++;
		// add newest note to front of notesHitArray
		// the oldest notes are at the end and are removed first
		if (!note.isSustainNote)
			notesHitArray.unshift(Date.now());

		if (!resetMashViolation && mashViolations >= 1)
			mashViolations--;

		if (mashViolations < 0)
			mashViolations = 0;

		if (!note.wasGoodHit)
		{
			switch (note.noteType)
			{
				case 0 | 8:
					hitGoodNote(note, false, false, noteDiff);
				case 1: // blue
					bigHit(note);
					showSploosh(note, 'sick');
					FlxG.save.data.boneshit += 1;
					if (FlxG.save.data.boneshit >= 50)
					{
						pushToAchievementIDS("Unworthy", true);
					}
				case 11:
					bigHit(note);
				case 2 | 12:
					hitGoodNote(note, true, true, noteDiff);
				case 3 | 10:
					// ink shit here
					updateInkProg();
					note.kill();
					notes.remove(note, true);
					note.destroy();
					if (vocals != null)
						vocals.volume = 0;
					showSploosh(note, 'sick');
					FlxG.save.data.inkshit += 1;
					if (FlxG.save.data.inkshit >= 50)
					{
						pushToAchievementIDS("Unworthy II", true);
					}
				case 4 | 9: // death notes
					bigHit(note);
				case 13:
					healthChange(-0.4);
					showSploosh(note, 'sick');
					FlxG.sound.play(Paths.sound('burnSound'), 0.6);
					note.kill();
					notes.remove(note, true);
					note.destroy();
				case 5:
					if (cardfloat >= 200)
					{
						hitGoodNote(note, true, true, noteDiff);
						FlxG.sound.play(Paths.sound('parry', 'cup'));
						// healthTween(-0.3);
						// note.kill();
						// notes.remove(note, true);
						// note.destroy();
						// vocals.volume = 0; why??
					}
					else
					{
						meterUpdate();
						hitGoodNote(note, true, true, noteDiff);
						FlxG.sound.play(Paths.sound('parry', 'cup'));
					}
				case 6:
					hitGoodNote(note, true, true, noteDiff);
				case 7:
					hitGoodNote(note, false, true, noteDiff);
			}
		}
	}

	var danced:Bool = false;

	function bigHit(note:Note = null)
	{
		if (!PlayStateChangeables.botPlay)
		{
			if (mechanicType == 0)
			{
				playerDie();
			}
			else
			{
				switch (note.noteType)
				{
					case 1 | 2: //blue bone, orange bone
						healthChange(-0.8,'sans'); //40% of health
						//krChange(-0.8);
					case 4 | 9: //sin, nightmare sin
						healthChange(-0.8); //40% of health
					case 11 | 12:
						healthChange(-0.8);
				}
			}

			note.kill();
			notes.remove(note, true);
			note.destroy();

			if (vocals != null)
				vocals.volume = 0;

			if ((boyfriend.specialAnimList.contains(boyfriend.animation.curAnim.name) && boyfriend.animation.curAnim.finished)
				|| !boyfriend.specialAnimList.contains(boyfriend.animation.curAnim.name))
			{
				boyfriend.playAnim('sing' + dataSuffix[note.noteData % 4] + 'miss');

				canDanceBF = false;

				boyfriend.animation.finishCallback = function(name:String)
				{
					canDanceBF = true;
				};

				if (camFocus == 'bf')
				{
					triggerCamMovement(note.noteData % 4);
				}
			}
		}
	}

	var inkTime:Float = 0;

	var inkTimer:FlxTimer;

	var inkTween:FlxTween;
	function updateInkProg(num:Int = 1)
	{
		FlxG.sound.play(Paths.sound('inked', 'bendy'));
		FlxG.camera.shake(0.03, 0.05);
		//inkTime = 1000;

		if (inkTimer != null)
			inkTimer.cancel();

		FlxTween.cancelTweensOf(inkObj);
		inkObj.alpha = 1;
		// remove(inkObj);
		if (inkProg + 1 < 5)
		{
			inkObj.loadGraphic(Paths.image('Damage0' + (inkProg + 1), 'bendy'));
			if (mechanicType != 0)
			{
				switch (inkProg)
				{
					case 0:
						inkObj.alpha = 0.3;
					case 1:
						inkObj.alpha = 0.5;
					case 2:
						inkObj.alpha = 0.7;
					case 3:
						inkObj.alpha = 0.8;
					case 4:
						inkObj.alpha = 0.9;
					case 5:
						inkObj.alpha = 1;
				}
			}
		}
		// add(inkObj);

		if (inkProg <= 4)
		{
			inkProg += num;
		}
		else
		{
			playerDie();
		}

		//Timer that handles the length of the ink
		inkTimer = new FlxTimer().start(2,function(tmr)
			{
				FlxTween.tween(inkObj,{alpha:0},1.2,{onComplete:function(twn)
					{
						inkProg = 0;
					}
				});
	
				//inkProg = 0;
	
			}
			);
	}

	function inkFade() // called from update, containing it here for easy editing
	{
		if (inkTime > 0)
		{
			inkTime--;
			var opInk = 300;
			if (inkTime < opInk)
				inkObj.alpha = inkTime / opInk;
		}
		else
		{
			inkProg = 0;
		}
	}

	var oldDefaultCamZoom:Float;

	function gethurt()
	{
		if (mechanicType != 0)
		{
			FlxG.sound.play(Paths.sound('hurt', 'sans'));
			healthChange(-((2 / 99) * 3), 'sans');
			//krChange(health - 1 / 99, true);
		}
		if (cangethurt)
		{
			if (mechanicType == 0)
			{
				healthChange(-1,'sans');
				//krChange(-1);
			}
			cangethurt = false;
			FlxG.sound.play(Paths.sound('hurt', 'sans'));
			if (mechanicType == 0)
				FlxFlicker.flicker(ball, 1.5, 0.1, true);
			new FlxTimer().start(1.5, function(tmr:FlxTimer)
			{
				cangethurt = true;
			}, 1);
		}
	}

	var stepHitFuncs:Array<StepEvent> = [];

	var butchersActive:Bool = false;

	function pushStepEvent(step:Int, callback:Void->Void)
	{
		stepHitFuncs.push(new StepEvent(step, callback));
	}

	function pushMultStepEvents(allSteps:Array<Int>, callback:Void->Void)
	{
		for (i in 0...allSteps.length)
		{
			stepHitFuncs.push(new StepEvent(allSteps[i], callback));
		}
	}

	function defineSteps()
	{
		switch (curSong.toLowerCase())
		{
			case 'sansational':
				{
					pushMultStepEvents([172, 300, 492], function()
					{
						dodgeAttackEvent();
					});
					pushStepEvent(775, function()
					{
						if (geno)
						{
							dad.playAnim('snap');
						}
						else
						{
							dodgeHud.alpha = 0;
							attackHud.alpha = 0;
							// despawn all blue notes, make all orange notes normal
							notes.forEachAlive(function(flaggedNote:Note)
							{
								if (flaggedNote.noteType == 1)
								{
									flaggedNote.kill();
								}
								else if (flaggedNote.noteType == 2)
								{
									var newNote:Note = new Note(flaggedNote.strumTime, flaggedNote.noteData, flaggedNote.prevNote, flaggedNote.isSustainNote,
										false);
									newNote.mustPress = flaggedNote.mustPress;
									if (newNote.mustPress)
									{
										newNote.x += FlxG.width / 2;
									}
									flaggedNote.kill();
									notes.add(newNote);
								}
							});

							FlxTween.tween(attackHud, {alpha: 0.6}, 0, {ease: FlxEase.quartInOut});
							FlxTween.tween(dodgeHud, {alpha: 0.6}, 0, {ease: FlxEase.quartInOut});
						}
					});

					pushStepEvent(780, function()
					{
						if (geno)
						{
							camGame.visible = false;
							FlxG.sound.play(Paths.sound('countdown', 'sans'), 1); // guh??
							transToCombatUI();
							// /lmao = true;
						}
					});

					/*pushStepEvent(784, function()
					{
						if (geno)
						{
							boyfriend.playAnim('pee', true);
						}
					});

					pushStepEvent(800, function()
					{
						if (geno)
						{
							boyfriend.playAnim('roses', true);
						}
					});*/// nvm LOL

					pushStepEvent(782, function()
					{
						if (geno)
						{
							camGame.visible = true;
							FlxG.sound.play(Paths.sound('countdown', 'sans'), 1);
						}
					});
				}

			case 'last-reel':
				{
					if (storyDifficulty >= 1) // iirc it plays the old version of last reel on normal and above so
					{
						pushStepEvent(1, function()
						{
							butchersActive = true;
						});

						pushStepEvent(80, function()
						{
							overrideDadAnim = false;
							shakeyCam = false;
						});

						pushStepEvent(111, function()
						{
							shakeyCam = true;
							overrideDadAnim = true;
							dad.playAnim('roar', true);
						});

						pushStepEvent(127, function()
						{
							overrideDadAnim = false;
							shakeyCam = false;
							dad.dance();
						});

						pushStepEvent(986, function()
						{
							stickmanGuy.animation.play("run");
							stickmanGuy.visible = true;
						});

						pushStepEvent(1024, function()
						{
							piper.alpha = 1;
							piper.animation.play('bruh', true);
							FlxG.sound.play(Paths.sound('boo', 'bendy'));

							new FlxTimer().start(1.75, function(tmr:FlxTimer)
							{
								piper.kill();
							});
						});

						pushStepEvent(1128, function()
						{
							jumpscareTimerAmt = FlxG.random.int(jumpscareTimerMin, jumpscareTimerMax);
						});

						pushStepEvent(1664, function()
						{
							dad.playAnim('roar', true, false, 22, true);

							overrideDadAnim = true;
							shakeyCam = true;

							inkStorm();
							dodgeHud.alpha = 0;
							attackHud.alpha = 0;

							healthSet(0.01, 10);
							FlxTween.tween(bendyboysfg, {x: bendyboysfg.x, y: bendyboysfg.y + 300, alpha: 0.0}, 1.5, {ease: FlxEase.quadOut});
						});

						pushStepEvent(1680, function()
						{
							overrideDadAnim = false;
							shakeyCam = false;
						});

						pushStepEvent(1776, function()
						{
							trace('3');
						});

						pushStepEvent(1781, function()
						{
							trace('2');
							var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image('ready', 'bendy'));
							ready.scrollFactor.set();
							ready.updateHitbox();
							ready.cameras = [camHUD];
							ready.screenCenter();
							add(ready);
							FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
								ease: FlxEase.cubeInOut,
								onComplete: function(twn:FlxTween)
								{
									ready.destroy();
								}
							});
						});

						pushStepEvent(1784, function()
						{
							trace('1');
							var set:FlxSprite = new FlxSprite().loadGraphic(Paths.image('set', 'bendy'));
							set.scrollFactor.set();
							set.cameras = [camHUD];
							set.screenCenter();
							add(set);
							FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
								ease: FlxEase.cubeInOut,
								onComplete: function(twn:FlxTween)
								{
									set.destroy();
								}
							});
						});

						pushStepEvent(1789, function()
						{
							trace('GO');
							var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image('go', 'bendy'));
							go.scrollFactor.set();
							go.cameras = [camHUD];
							go.updateHitbox();
							go.screenCenter();
							add(go);
							FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
								ease: FlxEase.cubeInOut,
								onComplete: function(twn:FlxTween)
								{
									go.destroy();
								}
							});
						});

						pushStepEvent(1808, function()
						{
							inkStormFade();
						});

						if (mechanicsEnabled)
						{
							pushStepEvent(2000, function()
							{
								fisher.alpha = 1;
								fisher.animation.play('bruh', true);
	
								new FlxTimer().start(6, function(tmr:FlxTimer)
								{
									fisherKill = true;
								});
							});
						}
					}
					else
					{
						pushStepEvent(48, function()
						{
							overrideDadAnim = true;
							dad.playAnim('roar', true);
							shakeyCam = true;
						});

						pushStepEvent(64, function()
						{
							overrideDadAnim = false;
							dad.dance();
							shakeyCam = false;
						});

						pushStepEvent(960, function()
						{
							jumpscareTimerAmt = FlxG.random.int(jumpscareTimerMin, jumpscareTimerMax);
						});

						pushStepEvent(1715, function()
						{
							trace('2');
							var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image('ready', 'bendy'));
							ready.scrollFactor.set();
							ready.updateHitbox();
							ready.cameras = [camHUD];
							ready.screenCenter();
							add(ready);
							FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
								ease: FlxEase.cubeInOut,
								onComplete: function(twn:FlxTween)
								{
									ready.destroy();
								}
							});
						});

						pushStepEvent(1720, function()
						{
							trace('1');
							var set:FlxSprite = new FlxSprite().loadGraphic(Paths.image('set', 'bendy'));
							set.scrollFactor.set();
							set.cameras = [camHUD];
							set.screenCenter();
							add(set);
							FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
								ease: FlxEase.cubeInOut,
								onComplete: function(twn:FlxTween)
								{
									set.destroy();
								}
							});
						});

						pushStepEvent(1724, function()
						{
							trace('GO');
							var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image('go', 'bendy'));
							go.scrollFactor.set();
							go.cameras = [camHUD];
							go.updateHitbox();
							go.screenCenter();
							add(go);
							FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
								ease: FlxEase.cubeInOut,
								onComplete: function(twn:FlxTween)
								{
									go.destroy();
								}
							});
						});
					}
				}

			case 'bonedoggle':
				{
					pushStepEvent(16, function()
					{
						strumToggle('player3', false);
					});
					pushStepEvent(192, function()
					{
						FlxTween.tween(this, {defaultCamZoom: oldDefaultCamZoom + 0.3}, 4);
						sansBar();
						strumToggle('player3', true, 1);
					});
					pushStepEvent(240, function()
					{
						player3.playAnim('fallasleep', false);
						strumToggle('player3', false, 1);
					});
					pushStepEvent(248, function()
					{
						defaultCamZoom = oldDefaultCamZoom;
					});
					pushStepEvent(252, function()
					{
						dad.playAnim('ohyoumotherfucker', true);
						camFocus = 'dad';
						triggerCamMovement();
						FlxTween.tween(this, {defaultCamZoom: oldDefaultCamZoom - 0.15}, .5);
					});
					pushStepEvent(256, function()
					{
						player3.playAnim('sleep', true);
						overridePlayer3Anim = true;
					});
					pushStepEvent(268, function()
					{
						dad.playAnim('idle-alt', true);
					});
					pushStepEvent(284, function()
					{
						overrideDadAnim = true;
					});
					pushStepEvent(297, function()
					{
						player3.playAnim('wakeup', false);
						overridePlayer3Anim = false;
					});
					pushStepEvent(300, function()
					{
						strumToggle('player3', true);
					});
					pushStepEvent(320, function()
					{
						overrideDadAnim = false;
						defaultCamZoom = oldDefaultCamZoom;
						player3.playAnim('idle', true);
					});
					pushStepEvent(352, function()
					{
						dad.playAnim('maboi', true);
						camFocus = 'dad';
						triggerCamMovement();
					});
					pushStepEvent(416, function()
					{
						dad.playAnim('idle', true);
					});
					pushStepEvent(684, function()
					{
						player3.playAnim('takeout', false);
						overridePlayer3Anim = true;
						overrideDadAnim = true;
						FlxTween.tween(this, {defaultCamZoom: oldDefaultCamZoom - 0.1}, .5);
					});
					pushStepEvent(688, function()
					{
						player3.playAnim('idle-alt', false);
						dad.playAnim('singUP-alt', true);
					});

					// papyrus freaks the fuck out
					pushMultStepEvents([695, 701, 702], function()
					{
						dad.playAnim('singUP-alt', true);
					});
					pushMultStepEvents([689, 690, 694, 698, 703], function()
					{
						dad.playAnim('singRIGHT-alt', true);
					});
					pushMultStepEvents([691, 692, 697, 700], function()
					{
						dad.playAnim('singLEFT-alt', true);
					});
					pushMultStepEvents([693, 696, 699], function()
					{
						dad.playAnim('singDOWN-alt', true);
					});

					pushStepEvent(688, function()
					{
						player3.playAnim('idle-alt', false);
						dad.playAnim('singUP-alt', true);
					});
					pushStepEvent(704, function()
					{
						dad.playAnim('bruh', true);
						camFocus = 'player3';
						triggerCamMovement();
						overridePlayer3Anim = false;
					});
					pushMultStepEvents([736, 752], function()
					{
						camFocus = 'dad';
						triggerCamMovement();
					});
					pushStepEvent(768, function()
					{
						overrideDadAnim = false;
						defaultCamZoom = oldDefaultCamZoom;
					});
					pushStepEvent(772, function()
					{
						player3.playAnim('idle-alt', false);
					});
					pushStepEvent(812, function()
					{
						player3.playAnim('putin', true);
						dad.playAnim('maboi', true);
						overridePlayer3Anim = true;
						overrideDadAnim = true;
					});
					pushStepEvent(824, function()
					{
						player3.playAnim('letsgo', false);
						camFocus = 'player3';
						triggerCamMovement();
					});
					pushStepEvent(828, function()
					{
						dad.playAnim('letsgo', false);
						camFocus = 'dad';
						triggerCamMovement();
					});
					pushStepEvent(832, function()
					{
						overridePlayer3Anim = false;
					});
					pushStepEvent(1152, function()
					{
						player3.playAnim('singDOWN', true);
						overridePlayer3Anim = true;
					});
					pushStepEvent(1232, function()
					{
						player3.playAnim('fallasleep', false);
					});
					pushStepEvent(1244, function()
					{
						dad.playAnim('bruh', true);
						camFocus = 'dad';
						triggerCamMovement();
						camHUD.visible = false;
					});
					pushStepEvent(1248, function()
					{
						player3.playAnim('sleep', true);
						camFocus = 'dad';
						triggerCamMovement();
					});
					pushMultStepEvents([1264, 1280], function()
					{
						camFocus = 'dad';
						triggerCamMovement();
					});
				}
			case 'despair':
				{
					pushStepEvent(48, function()
					{
						dad.alpha = 1;
						dad.playAnim('fall', true, false, 0, true);
						FlxG.sound.play(Paths.sound('nmbendy_land', 'bendy'));
						new FlxTimer().start(0.10, function(tmr:FlxTimer) // death check
						{
							FlxG.camera.shake(0.20, 0.05);
						});
						new FlxTimer().start(0.66, function(tmr:FlxTimer)
						{
							dad.preventDanceConstant = false;
						});
						FlxTween.tween(this, {defaultCamZoom: oldDefaultCamZoom - 0.2}, 4);

						jumpscareTimerAmt = FlxG.random.int(jumpscareTimerMin, jumpscareTimerMax);
					});
					pushStepEvent(1296, function()
					{
						bfPos[0] = boyfriend.getMidpoint().x - 700 + offsetX + pXOff;
						bfPos[1] = boyfriend.getMidpoint().y - 320 + offsetY + pYOff;
						FlxTween.tween(despairBG, {alpha: 1}, 1, {ease: FlxEase.expoOut});
						FlxTween.tween(this, {defaultCamZoom: oldDefaultCamZoom - 0.25}, 4);
						changeNoteSpeed(songScrollSpeed + 0.2, 0.2);
					});
					pushStepEvent(1350, function()
					{
						butchersActive = true;
						FlxTween.tween(attackHud, {alpha: 0.6}, 1, {ease: FlxEase.quartInOut});
						FlxTween.tween(dodgeHud, {alpha: 0.6}, 1, {ease: FlxEase.quartInOut});
					});
					pushStepEvent(1680, function()
					{
						// storm
						changeNoteSpeed(songScrollSpeed + 0.2, 0.2);
						inkStorm();
						jumpscareTimerAmt = 2000000;
					});
					pushStepEvent(1856, function()
					{
						// storm goes away, bf starts singing
						inkStormFade();

						bfPos[0] = boyfriend.getMidpoint().x - 350 + offsetX + pXOff;
						bfPos[1] = boyfriend.getMidpoint().y - 50 + offsetY + pYOff;

						FlxTween.tween(attackHud, {alpha: 0}, 1, {ease: FlxEase.quartInOut});
						FlxTween.tween(dodgeHud, {alpha: 0}, 1, {ease: FlxEase.quartInOut});

						FlxTween.tween(despairBG, {alpha: 0}, 2, {ease: FlxEase.quartInOut});
						FlxTween.tween(this, {defaultCamZoom: oldDefaultCamZoom}, 2);
					});
					pushStepEvent(2064, function()
					{
						// zooms out again
						bfPos[0] = boyfriend.getMidpoint().x - 700 + offsetX + pXOff;
						bfPos[1] = boyfriend.getMidpoint().y - 320 + offsetY + pYOff;
						FlxTween.tween(despairBG, {alpha: 1}, 2, {ease: FlxEase.expoOut});
						FlxTween.tween(this, {defaultCamZoom: oldDefaultCamZoom - 0.25}, 4);
					});
					pushStepEvent(2128, function()
					{
						butchersActive = true;

						jumpscareTimerAmt = FlxG.random.int(jumpscareTimerMin, jumpscareTimerMax);

						FlxTween.tween(attackHud, {alpha: 0.6}, 1, {ease: FlxEase.quartInOut});
						FlxTween.tween(dodgeHud, {alpha: 0.6}, 1, {ease: FlxEase.quartInOut});

						changeNoteSpeed(songScrollSpeed + 0.2, 0.2);
					});
					pushStepEvent(3024, function()
					{
						inkStorm();
						changeNoteSpeed(songScrollSpeed + 0.2, 0.2);
					});
					pushStepEvent(3216, function()
					{
						inkStormFade();
						// fire comes out
						fire.animation.play('fire', true);
						FlxTween.tween(fire, {y: -227}, 7.68, {ease: FlxEase.sineOut});
						changeNoteSpeed(songScrollSpeed + 0.2, 0.2);
					});
					pushStepEvent(3248, function()
					{
						butchersActive = true;
					});
					pushStepEvent(3912, function()
					{
						inkStorm();
						jumpscareTimerAmt = 200000;
					});
					pushStepEvent(3965, function()
					{
						inkStormFade();
						dadPos[1] = dad.getMidpoint().y + 40 + offsetY + enYOff;
					});
					pushStepEvent(3968, function()
					{
						dad.preventDanceConstant = true;
						dad.playAnim('ink', true);
					});
					pushStepEvent(3984, function()
					{
						bendy.alpha = 1;
						bendy.animation.play('play');
						jumpscareStatic.animation.play('static');
						FlxG.sound.play(Paths.sound('Lights_Turn_On'));
						FlxG.sound.play(Paths.sound('scare_bendy'));

						new FlxTimer().start(0.66, function(tmr:FlxTimer)
						{
							jumpscareStatic.visible = true;
							FlxTween.color(jumpscareStatic, 1.85, FlxColor.WHITE, FlxColor.BLACK, {ease: FlxEase.quadOut});
							bendy.alpha = 0.0;
						});
					});
				}

			case 'imminent-demise':
				{
					pushStepEvent(940, function()
					{
						canPause = false;
						var video:VideoHandler = new VideoHandler();
						video.fadeFromBlack = true;
						video.allowSkip = false;
						video.playMP4(Paths.video('bendy/1.5'), false, null, false, false, true);

						remove(light);
					});
					pushStepEvent(1088, function()
					{
						defaultCamZoom = 0.45;
						dadPos[1] = dad.getMidpoint().y - 40 + offsetY + enYOff;
						dadPos[0] = dad.getMidpoint().x + 460 + offsetX + enXOff;
						bfPos[0] = boyfriend.getMidpoint().x - 700 + offsetX + pXOff;

						if (FlxG.save.data.songPosition)
						{
							songPosBar.visible = true;
							if (songPosBarPreDemise != null)
								songPosBarPreDemise.visible = false;
						}

						iconP2.visible = false;
						iconP2alt.visible = true;

						remove(boyfriend);
						boyfriend = new Boyfriend(720, 465, 'bfwhoareyou');
						add(boyfriend);

						trace('boyfriend x: ' + boyfriend.x);
						trace('boyfriend y: ' + boyfriend.y);

						dad.alpha = 1;
						bendo.visible = false;
						speaker.visible = false;
						postDemise.alpha = 1.0;
						pillar.visible = false;
					});
					pushStepEvent(1209, function()
					{
						canPause = true;
						defaultBrightVal = -0.05;
						brightSpeed = 0.5;
						brightMagnitude = 0.05;
					});
				}

			case 'technicolor-tussle':
				{
					if (mechanicsEnabled)
					{
						pushMultStepEvents([452, 833, 1215], function()
						{
							startCupheadShoot();
							canheal = false;
						});
					}
				}

			case 'devils-gambit':
				if (mechanicsEnabled)
				{
					pushMultStepEvents([40, 208, 448, 800, 1232], function()
					{
						startCupheadShoot();
						canheal = false;
					});
				}

			case 'knockout':
				{
					// camera stuff
					pushMultStepEvents([659], function()
					{
						boyfriend.playAnim('idle', true);
					});
					pushMultStepEvents([144, 400, 911, 1216], function()
					{
						bumpRate = 1;
					});
					pushMultStepEvents([251, 507, 1040, 1472], function()
					{
						bumpRate = 4;
					});
					pushMultStepEvents([528, 880, 888, 896, 904, 1184, 1208], function()
					{
						FlxG.camera.zoom += 0.15;
					});
					pushStepEvent(1072, function()
					{
						FlxTween.tween(this, {defaultCamZoom: oldDefaultCamZoom + 0.3}, 6);
					});
					pushStepEvent(1536, function()
					{
						FlxTween.tween(this, {defaultCamZoom: oldDefaultCamZoom + 0.15}, 3.5);
					});
					pushMultStepEvents([1212, 1600], function()
					{
						defaultCamZoom = oldDefaultCamZoom;
					});

					// attack stuff
					if (mechanicsEnabled)
					{

						for (i in 0...stepsbeforeshoot.length)
						{
							pushStepEvent(stepsbeforeshoot[i]-4, function()
							{
								showdodgesign();
							});
						}
						pushMultStepEvents([142, 398, 501, 647, 772, 1598], function()
						{
							dodgeAttackEvent('cuphead');
						});
						pushMultStepEvents([603, 912], function()
						{
							dodgeAttackEvent('cuphead', 'roundabout');
						});
						pushMultStepEvents([308, 722, 820], function()
						{
							canheal = false;
							cupheadChaserMode = false;
							startCupheadShoot();
						});
						pushMultStepEvents([465, 1283], function()
						{
							canheal = false;
							startCupheadShoot();
						});
						pushMultStepEvents([272, 656, 784, 848, 1044], function()
						{
							cupheadChaserMode = true;
						});
						pushMultStepEvents([977, 1412], function()
						{
							cupheadChaserMode = false;
							startCupheadShoot();
							canheal = false;
						});

						pushStepEvent(1102, function()
						{
							cupheadChaserMode = false;
						});

						// mugman enter stage
						pushStepEvent(1151, function()
						{
							mugdead.animation.play('Stroll', true);
							mugcanhit = true;
							FlxTween.tween(mugdead, {x: boyfriend.x + 200}, 1, {ease: FlxEase.quadInOut});
						});
						pushStepEvent(1167, function()
						{
							dodgeAttackEvent('cuphead', 'alt');
							defaultCamZoom = oldDefaultCamZoom * 4/3;
						});
					}
				}

			case 'gose' | 'gose-classic':
				{
					pushStepEvent(112, function()
					{
						dad.playAnim('mlg', true);
					});
					if (SONG.song.toLowerCase() == 'gose-classic')
					{
						pushStepEvent(1648, function()
						{
							// embedded audio loops (idk)
							endSong();
						});
					}
					else
					{
						pushStepEvent(1695, function()
						{
							// amogus
							endSong();
						});
					}
				}
			case 'saness':
				{
					pushStepEvent(2764, function()
					{
						// embedded audio loops (idk)
						endSong();
					});
				}
			case 'freaky-machine':
				{
					pushMultStepEvents([220, 1118], function()
					{
						//boyfriend.playAnim('hey');
					});
					pushStepEvent(281, function()
					{
						dad.playAnim("you've got this", true);
						pushSubtitle("You've got this!", 0.0, 0.8, true);
					});
					pushStepEvent(670, function()
					{
						trace('changing');
						dad.playAnim('bendyIsTrans', true);
						dad.preventDanceConstant = true;
						new FlxTimer().start(2, function(tmr:FlxTimer)
						{
							camHUD.fade(FlxColor.BLACK, 1, false, function()
							{
								dad.y -= 250;
								dadPos[1] -= 350;
								baseDadFloat = dad.y;
								dadFloat = true;
								forceAlt = true;
								dad.preventDanceConstant = false;
								bfPos[1] -= 150;
								freakyMachineVideoSpr.alpha = 1;
							});
						});
					});
					pushStepEvent(704, function()
					{
						camHUD.fade(FlxColor.BLACK, 0, true);
						FlxTween.tween(this, {defaultCamZoom: 0.75}, 0.5, {ease: FlxEase.sineOut});
						FlxTween.tween(machineCurtainLeft, {x: machineCurtainLeft.x - 900}, 0.8, {ease: FlxEase.quadOut});
						FlxTween.tween(machineCurtainRight, {x: machineCurtainRight.x + 900}, 0.8, {ease: FlxEase.quadOut});
					});
					pushStepEvent(1113, function()
					{
						trace(dad.specialAnimList);
						dad.playAnim("ugh", true);
						pushSubtitle("Ugh! Low blow!", 0.0, 0.8, true); //ugh homo is indie cross gay? idk
					});
				}

			case 'whoopee':
				{
					pushStepEvent(16, function()
					{
						brightSpeed = 0.0000001;
						FlxTween.tween(this, {defaultBrightVal: -0.15}, 5);
						FlxTween.tween(this, {defaultCamZoom: oldDefaultCamZoom + 0.4}, 5);
					});
					pushStepEvent(32, function()
					{
						dodgeAttackEvent();
					});
					pushStepEvent(160, function()
					{
						dodgeHud.alpha = 0.00001;
						FlxTween.tween(this, {defaultBrightVal: 0}, 0.6);
						defaultCamZoom = oldDefaultCamZoom;
					});

					pushStepEvent(155, function()
					{
						dad.playAnim('snap',true);
					});
				}

			case 'bad-time':
				{
					pushMultStepEvents([
						32, 140, 268, 333, 528, 669, 720, 778, 832, 856, 941, 969, 1072, 1136, 1232, 1313, 1366, 1456
					], function()
					{
						blue = !blue;

						if (blue)
						{
							dodgeAttackEvent('blue');
						}
						else
						{
							dodgeAttackEvent('orange');
						}
					});
					pushMultStepEvents([384, 768, 1184], function()
					{
						nightmareSansBGManager('beatdrop');
					});
					pushMultStepEvents([512, 928, 1440], function()
					{
						nightmareSansBGManager('beatdropFinished');
					});
				}

			case 'final-stretch':
				{
					pushStepEvent(1, function()
					{
						FlxTween.tween(this, {defaultCamZoom: oldDefaultCamZoom + 0.15}, 9, {ease: FlxEase.quadInOut});
					});
					pushStepEvent(128, function()
					{
						FlxG.camera.zoom += 0.2;
						defaultCamZoom = oldDefaultCamZoom;
					});
					pushStepEvent(384, function()
					{
						defaultCamZoom += 0.10;
					});
					pushMultStepEvents([434, 440, 562, 568], function()
					{
						FlxG.camera.zoom += 0.05;
					});
					pushStepEvent(766, function()
					{
						camGame.visible = false;
						FlxG.sound.play(Paths.sound('countdown', 'sans'));
						defaultCamZoom = oldDefaultCamZoom;
						FlxG.camera.zoom += 0.10;
						waterFallEvent();
					});
					pushStepEvent(768, function()
					{
						camGame.visible = true;
						FlxG.sound.play(Paths.sound('countdown', 'sans'));
					});
					pushStepEvent(896, function()
					{
						FlxG.camera.zoom += 0.10;
						bumpRate = 1;
						FlxTween.tween(this, {defaultCamZoom: oldDefaultCamZoom + 0.15}, 1.35, {ease: FlxEase.quadInOut});

						blackBars();
					});
					pushStepEvent(1150, function()
					{
						bumpRate = 4;
						FlxTween.tween(this, {defaultCamZoom: oldDefaultCamZoom}, 1.35, {ease: FlxEase.quadInOut});

						blackBars();
					});
					pushStepEvent(1276, function()
					{
						camGame.visible = false;
						FlxG.sound.play(Paths.sound('countdown', 'sans'));
						defaultCamZoom += 0.10;
						FlxG.camera.zoom += 0.10;
						waterFallEvent();
					});
					pushStepEvent(1278, function()
					{
						camGame.visible = true;
						FlxG.sound.play(Paths.sound('countdown', 'sans'));
					});
					pushStepEvent(1792, function()
					{
						finalStretchwhiteBG.visible = true;
						finalStretchwhiteBG.alpha = 0.0001;
						FlxTween.tween(finalStretchwhiteBG, {alpha: 1.0}, 1.5, {ease: FlxEase.quadInOut});
						FlxTween.color(boyfriend, 1.5, FlxColor.WHITE, FlxColor.BLACK, {ease: FlxEase.quadInOut});
						FlxTween.color(dad, 1.5, FlxColor.WHITE, FlxColor.BLACK, {ease: FlxEase.quadInOut});
						FlxTween.tween(this, {defaultCamZoom: oldDefaultCamZoom + 0.10}, 10, {ease: FlxEase.quadInOut});
						blackBars();
					});
					pushStepEvent(2048, function()
					{
						FlxG.camera.zoom += 0.10;
						defaultCamZoom = oldDefaultCamZoom;
						finalStretchwhiteBG.visible = false;
						boyfriend.color = FlxColor.WHITE;
						dad.color = FlxColor.WHITE;
						if (finalStretchBarTop != null)
						{
							finalStretchBarTop.visible = false;
						}
						if (finalStretchBarBottom != null)
						{
							finalStretchBarBottom.visible = false;
						}

						for (i in 0...8)
						{
							strumLineNotes.members[i].y = strumLine.y;
						}
					});
				}

			case 'burning-in-hell':
				{
					pushStepEvent(368, function()
					{
						dad.playAnim('snap', true);
					});

					pushMultStepEvents([377, 379, 1148, 1150], function()
					{
						camGame.visible = false;
					});
					pushMultStepEvents([380, 1151], function()
					{
						camGame.visible = true;
					});
					pushMultStepEvents([378, 1149], function()
					{
						camGame.visible = true;
						transToCombatUI();
					});
					pushMultStepEvents([384, 1537], function()
					{
						bumpRate = 1;
					});
					pushMultStepEvents([640, 1521], function()
					{
						bumpRate = 4;
					});
					pushStepEvent(895, function()
					{
						transToSansStage();
					});
					pushStepEvent(1408, function()
					{
						bumpRate = 1;
						transToSansStage();
					});
					pushStepEvent(1664, function()
					{
						forceAlt = true;
						FlxG.camera.zoom += 0.2;
						FlxTween.tween(this, {defaultCamZoom: oldDefaultCamZoom + 0.3}, 14, {ease: FlxEase.quadInOut});
						bumpRate = 4;
					});
					pushStepEvent(1902, function()
					{
						FlxG.camera.zoom += 0.2;
						FlxTween.tween(camHUD, {alpha: 0.0}, 4.5, {ease: FlxEase.quadInOut});
						FlxTween.tween(this, {defaultCamZoom: oldDefaultCamZoom + 0.15}, 4.5, {ease: FlxEase.quadInOut});
						bumpRate = 64;
					});

					if (mechanicsEnabled)
					{
						// combat

						pushMultStepEvents([400, 662], function()
						{
							doutshit();
						});
						pushMultStepEvents([508, 762], function()
						{
							dontutshit();
						});

						pushMultStepEvents([160, 232, 912, 936, 1029, 1100, 1431, 1543, 1577], function()
						{
							dodgeAttackEvent();
						});

						pushMultStepEvents([405, 415, 430, 455, 481, 674, 684, 700, 710, 725, 735], function()
						{
							blastem(ball.y);
						});
					}
				}

			case 'terrible-sin':
				{
					pushStepEvent(192, function()
					{
						FlxTween.tween(this, {defaultCamZoom: oldDefaultCamZoom + 0.05}, 5, {ease: FlxEase.quadInOut});
					});
					pushStepEvent(384, function()
					{
						defaultCamZoom = oldDefaultCamZoom;
					});
					pushStepEvent(576, function()
					{
						defaultCamZoom += 0.15;
						FlxTween.tween(this, {defaultCamZoom: oldDefaultCamZoom + 0.05}, 5, {ease: FlxEase.quadInOut});

						jumpscareTimerAmt = FlxG.random.int(jumpscareTimerMin, jumpscareTimerMax);
					});
					pushStepEvent(672, function()
					{
						defaultCamZoom = oldDefaultCamZoom;
						FlxTween.tween(this, {defaultCamZoom: oldDefaultCamZoom + 0.05}, 5, {ease: FlxEase.quadInOut});
					});
					pushStepEvent(768, function()
					{
						defaultCamZoom += 0.25;
						FlxTween.tween(this, {defaultCamZoom: oldDefaultCamZoom + 0.10}, 5, {ease: FlxEase.quadInOut});
						bumpRate = 1;
					});
					pushStepEvent(865, function()
					{
						defaultCamZoom += 0.25;
						FlxTween.tween(this, {defaultCamZoom: oldDefaultCamZoom + 0.10}, 5, {ease: FlxEase.quadInOut});
					});
					pushStepEvent(935, function()
					{
						bumpRate = 4;
					});
					pushStepEvent(960, function()
					{
						defaultCamZoom = oldDefaultCamZoom;
						FlxG.camera.zoom += 0.15;
					});
					/*pushStepEvent(1150, function()
					{
						FlxG.sound.play(Paths.sound('Lights_Turn_Off'));
						camGame.visible = false;
						// ok so hear me out, maybe when the texture atlas stuff is fully working,
						// we could make this a section where the lights are off and the only
						// thing that is visible is bendy's red eye i think that would be cool!!
					});*/
					pushStepEvent(1343, function()
					{
						//camGame.visible = true;
						FlxG.camera.zoom += 0.3;
					});
					pushStepEvent(1552, function()
					{
						FlxTween.tween(this, {defaultCamZoom: oldDefaultCamZoom + 0.2}, 9.5, {ease: FlxEase.quadInOut});
					});
					pushMultStepEvents([1722, 1726], function()
					{
						defaultCamZoom = oldDefaultCamZoom;
					});
					pushStepEvent(1728, function()
					{
						bumpRate = 1;
					});
					pushStepEvent(1920, function()
					{
						bumpRate = 4;
						FlxG.camera.zoom += 0.3;
						defaultCamZoom += 0.15;
						FlxTween.tween(this, {defaultCamZoom: oldDefaultCamZoom}, 7, {ease: FlxEase.quadInOut});
					});
				}

			case 'ritual':
				{
					pushStepEvent(1, function()
					{
						dad.preventDanceConstant = true;
						dad.playAnim('Intro', true);
						pushSubtitle("It's time...", 0, 1.20, true);
					});
					pushStepEvent(17, function()
						{
							pushSubtitle("We've all been waiting...", 0, 1.4, true);
						});
					pushStepEvent(40, function()
						{
							pushSubtitle("But now...", 0, 0.6, true);
						});
					pushStepEvent(50, function()
						{
							pushSubtitle("the wait is over.", 0, 2.5, true);
						});
					pushStepEvent(48, function()
					{
						FlxTween.tween(camHUD, {alpha: 0}, 2);
						FlxTween.tween(FlxG.camera, {alpha: 0}, 2);
					});
					pushStepEvent(80, function()
					{
						canPause = true;
						dad.preventDanceConstant = false;
						FlxTween.tween(camHUD, {alpha: 1}, 2);
						FlxTween.tween(FlxG.camera, {alpha: 1}, 2);
					});
					pushStepEvent(384, function()
					{
						jumpscareTimerAmt = FlxG.random.int(jumpscareTimerMin, jumpscareTimerMax);
					});

					pushStepEvent(1258, function()
					{
						if (mechanicsEnabled)
						{
							dodgeHud.alpha = 0.6;
						}
					});

					pushStepEvent(1266, function()
					{
						if (mechanicsEnabled)
						{
							dodgeAttackEvent('sammy');
						}
						new FlxTimer().start(2, function(tmr:FlxTimer)
						{
							FlxTween.tween(camHUD, {alpha: 0}, 3);
							FlxTween.tween(FlxG.camera, {alpha: 0}, 3);
						});
					});
				}

			case 'nightmare-run':
				{
					pushStepEvent(31, function()
					{
						focusedOnChar = false;
					});
					pushMultStepEvents([164, 415, 671, 863, 1952], function()
					{
						bumpRate = 1;
					});
					pushMultStepEvents([287, 607, 1311, 1503, 1632, 1696], function()
					{
						bumpRate = 2;
					});
					pushMultStepEvents([543, 735, 1664, 2080], function()
					{
						bumpRate = 4;
					});
					pushMultStepEvents([411, 539], function()
					{
						setDarkTunnel();
					});
					pushStepEvent(768, function()
					{
						setnmStairs();
					});
					pushStepEvent(799, function()
					{
						bumpRate = 2;
						jumpscareTimerAmt = FlxG.random.int(jumpscareTimerMin, jumpscareTimerMax);
					});
					pushStepEvent(927, function()
					{
						jumpscareTimerAmt = 200000;
					});
					pushStepEvent(1050, function()
					{
						transrights();
					});
					pushStepEvent(1303, function()
					{
						inBlackout = true;
						new FlxTimer().start(0.5, function(tmr:FlxTimer)
						{
							forcesize = false;
							iskinky = false;
							bridged = false;
						});
						setDarkTunnel();
					});
					pushStepEvent(1439, function()
					{
						bumpRate = 1;
						jumpscareTimerAmt = FlxG.random.int(jumpscareTimerMin, jumpscareTimerMax);
					});
					pushStepEvent(1567, function()
					{
						bumpRate = 1;
						jumpscareTimerAmt = 200000;
					});
					pushMultStepEvents([1659, 1930], function()
					{
						setDarkTunnel();
					});
				}
		}

		if (stepHitFuncs != null)
		{
			var allSteps:String = '';
			for (i in 0...stepHitFuncs.length)
			{
				allSteps += stepHitFuncs[i].step + ' ';
			}
			trace("All Step Events: " + allSteps);
		}
	}

	override function stepHit()
	{
		super.stepHit();

		if (stepHitFuncs != null)
		{
			for (i in 0...stepHitFuncs.length)
			{
				if (stepHitFuncs[i] != null)
				{
					// if curStep is ready or has been ready to do event, do event and remove from list
					if (curStep >= stepHitFuncs[i].step)
					{
						trace('running step ' + stepHitFuncs[i].step);
						stepHitFuncs[i].callback();
						stepHitFuncs.remove(stepHitFuncs[i]);
					}
				}
			}
		}

		// FlxG.log.add(curStep);
		if (!songOver)
		{
			if (FlxG.sound.music.time > Conductor.songPosition + 20 || FlxG.sound.music.time < Conductor.songPosition - 20)
			{
				resyncVocals();
			}

			#if cpp
			if (executeModchart && luaModchart != null)
			{
				luaModchart.setVar('curStep', curStep);
				luaModchart.executeState('stepHit', [curStep]);
			}
			#end

			// yes this updates every step.
			// yes this is bad
			// but i'm doing it to update misses and accuracy

			songLength = FlxG.sound.music.length;

			// Updating Discord Rich Presence (with Time Left)
			var disSong:String = SONG.song;
			if (HelperFunctions.shouldBeHidden(SONG.song.toLowerCase()))
				disSong = '[CONFIDENTIAL]';
			DiscordClient.changePresence(detailsText
				+ " "
				+ disSong
				+ " ("
				+ storyDifficultyText
				+ ") "
				+ Ratings.GenerateLetterRank(accuracy),
				"Acc: "
				+ HelperFunctions.truncateFloat(accuracy, 2)
				+ "% | Score: "
				+ songScore
				+ " | Misses: "
				+ misses, iconRPC, true,
				songLength
				- Conductor.songPosition);
		}
	}

	var didntfuckinlag:Bool = false;

	var dadFloat:Bool = false;
	var atWaterFall:Bool = false;

	function waterFallEvent()
	{
		if (atWaterFall)
		{
			atWaterFall = false;

			finalStretchWaterFallBG.alpha = 0.0001;
			remove(boyfriend);
			boyfriend = new Boyfriend(boyfriend.x, boyfriend.y, 'bfSans');
			remove(dad);
			dad = new Character(dad.x - 50, dad.y, 'sans');
			layerChars();
		}
		else
		{
			atWaterFall = true;

			finalStretchWaterFallBG.alpha = 1.0;
			remove(boyfriend);
			boyfriend = new Boyfriend(boyfriend.x, boyfriend.y, 'bfsanswaterfall');
			remove(dad);
			dad = new Character(dad.x + 50, dad.y, 'sanswaterfall');
			layerChars();
		}
	}

	function inkStorm()
	{
		inkStormRain.animation.play('play', true);
		for (inkscroll in inkscroll)
			FlxTween.tween(inkscroll, {alpha: 0.6}, 1, {ease: FlxEase.cubeInOut});
		FlxTween.tween(inkStormRain, {alpha: 1}, 1, {ease: FlxEase.cubeInOut});
		FlxTween.tween(blackOverlay, {alpha: 0.33}, 1, {ease: FlxEase.cubeInOut});

		butchersActive = false;

		if (currentStriker != null)
		{
			if (strikerTween != null)
				strikerTween.cancel();
			currentStriker.die();
		}
		if (currentPiper != null)
		{
			if (piperTween != null)
				piperTween.cancel();
			currentPiper.die();
		}
	}

	function inkStormFade()
	{
		for (inkscroll in inkscroll)
			FlxTween.tween(inkscroll, {alpha: 0}, 1, {ease: FlxEase.cubeInOut});
		FlxTween.tween(inkStormRain, {alpha: 0}, 1, {ease: FlxEase.cubeInOut});
		FlxTween.tween(blackOverlay, {alpha: 0}, 1, {ease: FlxEase.cubeInOut});
	}

	function changeSpeed(amt:Float)
	{
		if (amt != 0)
		{
			trace(songScrollSpeed);
			songScrollSpeed = origSpeed + amt;
			trace(songScrollSpeed);
		}
	}

	function bop()
	{
		switch (SONG.song.toLowerCase())
		{
			case 'terrible-sin' | 'last-reel':
				if (blackStickmanThereInBG != null)
				{
					blackStickmanThereInBG.animation.play("sam");
				}
				if (SONG.song.toLowerCase() == 'last-reel' && storyDifficulty >= 1)
				{
					if (bendyboysfg != null)
					{
						bendyboysfg.animation.play('dance', true);
					}
				}
			case 'imminent-demise':
				if (speaker != null && curBeat % 2 == 0)
				{
					speaker.animation.play('bump', true);
				}
			case 'gose' | 'gose-classic':
				if (gosebg != null)
					gosebg.animation.play('bop', true);
		}

		charsDance();
	}

	public function changeNoteSpeed(newSpeed:Float, duration:Float)
	{
		FlxTween.tween(SONG, {speed: newSpeed}, duration);
		trace('Changed song speed to $newSpeed');
	}

	function summonDevil()
	{
		if (PlayState.SONG.notes[Std.int(curStep / 16)] != null)
		{
			trace('DEVIL LENGTH IS: ' + devilGroup.length);
			if (devilGroup.length <= 0)
			{
				var newDevil:DevilBitches = new DevilBitches(false);
				newDevil.y = boyfriend.y - 64;
				newDevil.setDirection(PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection);
				devilGroup.add(newDevil);
			}
		}
	}

	function summonFisher()
	{
		trace('FISHER LENGTH IS: ' + devilGroup.length);
		if (devilGroup.length <= 0)
		{
			trace('spawned');
			var newDevil:DevilBitches = new DevilBitches(true);
			newDevil.y = boyfriend.y - 230; // + newDevil.height / 2;
			var pain:Bool;
			if (FlxG.random.bool(50))
				pain = false;
			else
				pain = true;

			/*must hit or not doesnt matter too much since the camera is mostly in the center
				so lets give em some more pain by making it random */

			newDevil.setDirection(pain);
			devilGroup.add(newDevil);
		}
	}

	public function resetDevilGroupIndex()
	{
		devilGroup.clear();
	}

	function finishCupHeadTutorial():Void
	{
		persistentUpdate = true;
		health = 2;
		dad.animation.resume();
		boyfriend.animation.resume();
		slow = false;

		canPause = true;
		FlxTween.num(songSpeed, 1, 2, {}, function(v:Float)
		{
			songSpeed = v;
		});

		FlxTween.num(pewdmg, 0.0325, 2, {}, function(v:Float)
		{
			pewdmg = v;
		});
	}

	function blackBars()
	{
		if (!hasBlackBars)
		{
			hasBlackBars = true;

			FlxTween.tween(finalStretchBarTop, {y: finalStretchBarTop.y + 112}, 1.5, {ease: FlxEase.quadInOut});

			FlxTween.tween(finalStretchBarBottom, {y: finalStretchBarBottom.y - 112}, 1.5, {ease: FlxEase.quadInOut});

			trace(strumLineNotes.members[0].y);

			for (i in 0...8)
			{
				if (PlayStateChangeables.useDownscroll)
				{
					FlxTween.tween(strumLineNotes.members[i], {y: strumLine.y - 70}, 1.5, {ease: FlxEase.quadInOut});
				}
				else
				{
					FlxTween.tween(strumLineNotes.members[i], {y: strumLine.y + 70}, 1.5, {ease: FlxEase.quadInOut});
				}
			}
		}
		else
		{
			hasBlackBars = false;

			if (finalStretchBarTop != null)
			{
				FlxTween.tween(finalStretchBarTop, {y: finalStretchBarTop.y - 112}, 1.5, {ease: FlxEase.quadInOut});
			}

			if (finalStretchBarBottom != null)
			{
				FlxTween.tween(finalStretchBarBottom, {y: finalStretchBarBottom.y + 112}, 1.5, {ease: FlxEase.quadInOut});
			}

			for (i in 0...8)
			{
				FlxTween.tween(strumLineNotes.members[i], {y: strumLine.y}, 1.5, {ease: FlxEase.quadInOut});
			}
		}
	}

	override function beatHit()
	{
		super.beatHit();

		if (curStage == 'factory')
		{
			if (cutouts.length != 0)
			{
				if (jumpscareTimerAmt == 0)
				{
					triggerJumpscare();
				}
				else
				{
					jumpscareTimerAmt -= 1;
				}
			}
		}

		if (curBeat % 2 == 0 && MainMenuState.debugTools)
		{
			///trace('curStep:' + curStep);
			///trace('curBeat:' + curBeat);
		}

		bop();
		
		if (curStage == 'hall' && fuckinAngry && curBeat % 2 == 0)
		{
			nightmareSansBgs[1].animation.play('beatHit', true);
		}

		if (SONG.song.toLowerCase() == 'satanic-funkin' && curBeat % 24 == 0)
			summonDevil();

		if ((SONG.song.toLowerCase() == 'despair' && curBeat % 24 == 0) && butchersActive)
			summonFisher();

		if (SONG.song.toLowerCase() == 'devils-gambit' && curBeat % 48 == 0)
		{
			if (dad.animation.curAnim.name != 'attack1')
			{
				dodgeAttackEvent('cuphead', 'hadoken');
			}
		}

		if (curBeat % 4 == 0)
		{
			checkFocus();
		}

		if (generatedMusic)
		{
			notes.sort(FlxSort.byY, (PlayStateChangeables.useDownscroll ? FlxSort.ASCENDING : FlxSort.DESCENDING));
		}

		#if cpp
		if (executeModchart && luaModchart != null)
		{
			luaModchart.setVar('curBeat', curBeat);
			luaModchart.executeState('beatHit', [curBeat]);
		}
		#end

		if (SONG.notes[Math.floor(curStep / 16)] != null)
		{
			if (SONG.notes[Math.floor(curStep / 16)].changeBPM)
			{
				Conductor.changeBPM(SONG.notes[Math.floor(curStep / 16)].bpm);
				FlxG.log.add('CHANGED BPM!');
			}
		}

		if ((SONG.song.toLowerCase() == 'ritual' && curStep > 80) || SONG.song.toLowerCase() != 'ritual' && !battleMode)
		{
			if (FlxG.camera.zoom < 1.35 && (curBeat % bumpRate == 0))
			{
				FlxG.camera.zoom += 0.015;
				camHUD.zoom += 0.03;
			}
		}
	}

	var curLight:Int = 0;
	var bumpRate:Int = 4;

	var inBlackout:Bool = false;

	function setDarkTunnel()
	{
		canPause = false;
		transition.alpha = 1;
		transition.animation.play('bruh', true);
		transition.animation.finishCallback = function(name:String)
		{
			transition.alpha = 0.0001;
			canPause = true;
		}

		if (!inBlackout)
		{
			inBlackout = true;

			altPlayerStrums.forEach(function(spr:FlxSprite)
			{
				FlxTween.tween(spr, {alpha: 1}, 0.5, {startDelay: 1});
			});
			altCpuStrums.forEach(function(spr:FlxSprite)
			{
				FlxTween.tween(spr, {alpha: 1}, 0.5, {startDelay: 1});
			});

			new FlxTimer().start(0.6, function(tmr:FlxTimer)
			{
				bgs[randomPick].alpha = 0.0001;

				if (darkHallway != null)
				{
					darkHallway.alpha = 1;
					darkHallway.animation.play('bruh', true, false, bgs[randomPick].animation.curAnim.curFrame);
					overrideNMZoom = true;
					FlxTween.tween(this,{defaultCamZoom:defaultCamZoom - 0.15},0.7,{ease:FlxEase.smoothStepOut,startDelay:1});
					//trace('Tweening cam shit');
			
				}

				//trace('SWITCHING FRAMES');

				remove(boyfriend);
				boyfriend = new Boyfriend(ogposes[0], ogposes[1], 'bfChaseDark');

				remove(dad);
				dad = new Character(ogposes[2], ogposes[3], 'bendyChaseDark');

				layerChars();
			});
		}
		else
		{
			inBlackout = false;

			altPlayerStrums.forEach(function(spr:FlxSprite)
			{
				FlxTween.tween(spr, {alpha: 0}, 0.5, {startDelay: 1});
			});
			altCpuStrums.forEach(function(spr:FlxSprite)
			{
				FlxTween.tween(spr, {alpha: 0}, 0.5, {startDelay: 1});
			});

			new FlxTimer().start(0.6, function(tmr:FlxTimer)
			{

				if (frontbg!= null)
					{
						for (i in frontbg)
							i.alpha = 0;
						for (i in backbg)
							i.alpha = 0;
						if (emitt!=null)
						{
							for (i in emitt)
								i.kill();
						}
					}
				if (darkHallway != null)
				{
					darkHallway.alpha = 0.0001;
					overrideNMZoom = false;
					FlxTween.tween(this,{defaultCamZoom:defaultCamZoom + 0.15},0.7,{ease:FlxEase.smoothStepOut,startDelay: 1});
					
				}

				bgs[randomPick].alpha = 1;
				bgs[randomPick].animation.play('bruh', true, false, darkHallway.animation.curAnim.curFrame);

				//trace('SWITCHING FRAMES');

				remove(boyfriend);
				boyfriend = new Boyfriend(ogposes[0], ogposes[1], 'bfChase');

				remove(dad);
				dad = new Character(ogposes[2], ogposes[3], 'bendyChase');

				layerChars();
			});
		}
	}

	function transrights()
		{
			bridged = true;
			altPlayerStrums.forEach(function(spr:FlxSprite)
			{
				FlxTween.tween(spr, {alpha: 1}, 0.5, {startDelay: 1});
			});
			altCpuStrums.forEach(function(spr:FlxSprite)
			{
				FlxTween.tween(spr, {alpha: 1}, 0.5, {startDelay: 1});
			});
			canPause = false;
			transition.alpha = 1;
			transition.animation.play('bruh', true);
			transition.animation.finishCallback = function(name:String)
			{
				transition.alpha = 0.0001;
				canPause = true;
				iskinky = true;
			}

			new FlxTimer().start(0.65, function(tmr:FlxTimer)
			{
				nmStairs = false;
				stairsBG.alpha = 0.0001;
				stairs.alpha = 0.0001;
				forcesize = true;
				defaultBrightVal = 0.0;
				brightSpeed = 0.0;
				brightMagnitude = 0.0;
				defaultCamZoom = 1;
				remove(dad);
				remove(boyfriend);
				remove(backbg);
				remove(frontbg);
				add(backbg);
				canCameraMove = false;
				emitt = new FlxTypedGroup<FlxEmitter>();
				add(emitt);
				for (i in 0...3)
				{
					var emitter:FlxEmitter;
					emitter = new FlxEmitter(FlxG.width*1.85/2-2500, 1300);
					emitter.scale.set(0.9, 0.9, 2, 2, 0.9, 0.9, 1, 1);
					emitter.drag.set(0, 0, 0, 0, 5, 5, 10, 10);
					emitter.width = FlxG.width*2;
					emitter.alpha.set(1, 1, 1, 0);
					emitter.lifespan.set(5, 10);
					emitter.launchMode = FlxEmitterMode.SQUARE;
					emitter.velocity.set(-50, -150, 50, -750, -100, 0, 100, -100);
					emitter.loadParticles(Paths.image('gay/Particlestuff' + i, 'bendy'), 500, 16, true);
					emitter.start(false, FlxG.random.float(0.2, 0.3), 10000000);
					emitt.add(emitter);
				}
				boyfriend = new Boyfriend(0, 0, 'bfChaseDark');
				dad = new Character(0, 0, 'bendyChaseDark');
				dad.screenCenter();
				boyfriend.screenCenter();
				dad.x -= 445;
				dad.y += 375;
				boyfriend.x += 130;
				boyfriend.y += 420;
				add(dad);
				add(boyfriend);
				add(frontbg);
				for (i in frontbg)
					i.alpha = 1;
				for (i in backbg)
					i.alpha = 1;
			});
		}

	function setnmStairs()
	{
		canPause = false;
		transition.alpha = 1;
		transition.animation.play('bruh', true);
		transition.animation.finishCallback = function(name:String)
		{
			transition.alpha = 0.0001;
			canPause = true;
		}

		new FlxTimer().start(0.6, function(tmr:FlxTimer)
		{
			if (!nmStairs) // WHAT THE FUCK IS THIS CODE
			{
				//trace('trans to stairs');
				nmStairs = true;
				defaultBrightVal = 0.0;
				brightSpeed = 0.0;
				brightMagnitude = 0.0;
				stairsBG.alpha = 1.0;
				stairs.alpha = 1.0;

				remove(boyfriend);
				boyfriend = new Boyfriend(-160, -220, 'bfChase');
				boyfriend.angle = -15;

				remove(dad);
				dad = new Character(-1080, -220, 'bendyChase');
				dad.angle = -15;

				FlxTween.cancelTweensOf(stairs);
				FlxTween.cancelTweensOf(dad);
				FlxTween.cancelTweensOf(boyfriend);
				stairs.y = -620;
				dad.y = -320;
				boyfriend.y = -520;
				// FlxTween.tween(stairs, {y: 820}, 2.3, {type: LOOPING});
				FlxTween.tween(dad, {x: 1080, y: 880}, 2.3, {type: LOOPING});
				FlxTween.tween(boyfriend, {x: 2000, y: 880}, 2.3, {type: LOOPING});

				layerChars();
			}
			else
			{
				//trace('tras back from stairs');
				nmStairs = false;
				defaultBrightVal = -0.05;
				brightSpeed = 0.5;
				brightMagnitude = 0.05;

				stairsBG.alpha = 0.0001;
				stairs.alpha = 0.0001;

				remove(boyfriend);
				boyfriend.angle = 0;
				boyfriend = new Boyfriend(-700, 650, 'bfChase');

				remove(dad);
				dad.angle = 0;
				dad = new Character(-700, 330, 'bendyChase');

				layerChars();
			}
		});
	}

	function cycleScroll()
	{
		if (bgs != null && !nmStairs)
		{
			if (inBlackout)
			{
				if (darkHallway != null)
				{
					if (darkHallway.animation.curAnim != null)
					{
						if (darkHallway.animation.curAnim.finished)
						{
							darkHallway.animation.play('bruh', true);
						}
					}
				}
			}
			else
			{
				if (bgs[randomPick].animation.curAnim.finished)
				{
					randomPick = FlxG.random.int(0, bgs.length - 1);
					if (!FlxG.save.data.highquality)
					{
						// making it just use one if shit pc
						randomPick = 0;
					}
					else
					{
						if ((randomPick == oldRando) && randomPick != 0)
						{
							if (randomPick + 1 != bgs.length)
							{
								randomPick += 1;
							}
							else
							{
								randomPick -= 1;
							}
						}
						oldRando = randomPick;
					}

					for (i in 0...bgs.length)
					{
						if (i == randomPick)
						{
							bgs[i].alpha = 1;
							bgs[i].animation.play('bruh', true);
						}
						else
						{
							bgs[i].alpha = 0.0001;
						}
					}
				}
			}
		}
	}

	var jumpingBendyTimer1:FlxTimer;
	var jumpingBendyTimer2:FlxTimer;
	var jumpingBendyTimer3:FlxTimer;
	var jumpingBendyTimer4:FlxTimer;
	var jumpscareTimerAmt:Int = 20000;

	function triggerJumpscare(testing:Bool = false,aaa:Int = 0)
	{
		if (!testing)
		{
			FlxG.sound.play(Paths.sound('cutout', 'bendy'));
			randomCutout = FlxG.random.int(0, cutouts.length - 1);
	
			for (i in 0...cutouts.length)
			{
				if (i == randomCutout)
				{
					//trace('cur selected ' + i);
					cutouts[i].alpha = 1;
					cutouts[i].animation.play('bruh', true);
	
					cutouts[i].animation.finishCallback = function(name)
					{
						cutouts[i].alpha = 0.0001;
					}
				}
				else
				{
					cutouts[i].alpha = 0.0001;
				}
			}
	
			jumpscareTimerAmt = FlxG.random.int(jumpscareTimerMin, jumpscareTimerMax);
		}
		else
		{
			cutouts[aaa].alpha = 1;
			cutouts[aaa].animation.play('bruh', true);

			cutouts[aaa].animation.finishCallback = function(name)
			{
				cutouts[aaa].alpha = 0.0001;
			}

			new FlxTimer().start(0.000001, function(tmr:FlxTimer)
			{
				if (cutouts[aaa].alpha == 1)
				{
					FlxG.mouse.visible = true;
					cutouts[aaa].x = FlxG.mouse.x - 250;
					cutouts[aaa].y = FlxG.mouse.y - 250;
					//if(FlxG.keys.justPressed.SPACE)
						//trace(cutouts[aaa].x + ' ' + cutouts[aaa].y);
				}
			},0);
		}
	}

	var daBG:Int = 0;

	function nightmareSansBGManager(mode:String)
	{
		//trace('changing bg shit');
		switch (mode)
		{
			case 'normal':
				nightmareSansBgs[0].animation.play('normal', true);
				nightmareSansBgs[0].alpha = 1;
				nightmareSansBgs[1].alpha = 0;
			case 'beatdrop':
				nightmareSansBgs[0].animation.play('beatdrop', true);
				nightmareSansBgs[0].alpha = 1;
				nightmareSansBgs[1].alpha = 0;
			case 'beatdropFinished':
				nightmareSansBgs[0].animation.play('beatDropFinish', true);
				nightmareSansBgs[0].alpha = 1;
				nightmareSansBgs[1].alpha = 1;
		}
	}

	function onWindowFocusOut():Void
	{
		if (FlxG.save.data.focuspause && !FlxG.save.data.focusfreeze)
		{
			if (!dead && !paused && startedCountdown && canPause)
			{
				pauseGame();
			}
		}
	}

	function midSongVidFinish()
	{
		remove(sansSprite);
		FlxG.camera.fade(FlxColor.BLACK, 0, true);
	}

	var first:Bool = true;

	function transToCombatUI()
	{
		if (bfDodge != null)
			bfDodge.alpha = 0.0001;

		boyfriend.alpha = 1;
		battle.alpha = 1;
		battleBG.alpha = 1;
		battleMode = true;

		if (fuckinAngry)
		{
			for (i in 0...nightmareSansBgs.length)
			{
				nightmareSansBgs[i].alpha = 0.0001;
			}
		}

		if (bg != null)
		{
			bg.alpha = 0.0001;
		}

		attackHud.alpha = 0.0001; // prevents the player attacking while sans is talking
		dodgeHud.alpha = 0.0001;

		/** i hope this fixes the bg and chars not loading after 
			cutscene finishes -- thank god kade thought of this

			p.d: based kade
			-polybiusproxy

			p.p.d: it didnt but i found the real fix
			for the moment i will leave this here
		**/
		/*
			if (SONG.song.toLowerCase() == 'sansational')
			{
				sans = new VideoHandler();
				sansSprite = new FlxSprite(0, 0);
				sansSprite.scrollFactor.set();
				sansSprite.cameras = [camGame];

				sansSprite.width = FlxG.width;
				sansSprite.height = FlxG.height;

				sans.playMP4(Paths.video('sanstrans'), false, sansSprite, false, false, true);
				sans.finishCallback = midSongVidFinish;
				add(sansSprite);
			}
		 */

		dad.playAnim('miss', true);

		remove(dad);
		remove(boyfriend);

		dad = new Character(155.1, 436.5, 'sansbattle'); // WTF FLOAT COORDINATES

		if (SONG.song.toLowerCase() == 'burning-in-hell')
		{
			boyfriend = new Boyfriend(158.3, 1248.7, 'charabattle');
		}
		else
		{
			boyfriend = new Boyfriend(158.3, 1248.7, 'bfbattle'); // WTF FLOAT COORDINATES
		}

		layerChars();

		if (first)
		{
			pushToSpecialAnim('bf');
			pushToSpecialAnim('dad');
			first = false;
		}

		camMovement.cancel();
		getCamOffsets();

		defaultCamZoom = 0.35;
		FlxG.camera.zoom = defaultCamZoom;
	}

	function transToSansStage()
	{
		// bg.alpha = 1;
		battle.alpha = 0.0001;
		battleBG.alpha = 0.0001;

		if (bg != null)
		{
			bg.alpha = 1;
		}

		battleMode = false;

		attackHud.alpha = 1;
		dodgeHud.alpha = 1;

		if (fuckinAngry)
		{
			nightmareSansBGManager('normal');
		}

		remove(boyfriend);
		if (fuckinAngry)
		{
			boyfriend = new Boyfriend(616.3, 375.1, 'bfSansNightmare');
		}
		else if (SONG.song.toLowerCase() == 'burning-in-hell')
		{
			boyfriend = new Boyfriend(616.3, 375.1, 'bfchara');
		}
		else
		{
			boyfriend = new Boyfriend(616.3, 375.1, 'bfSans');
		}

		remove(dad);
		if (fuckinAngry)
		{
			dad = new Character(-350, -130, 'sansNightmare');
		}
		else if (SONG.song.toLowerCase() == 'burning-in-hell')
		{
			dad = new Character(-310.6, 230, 'sansScared');
		}
		else
		{
			dad = new Character(-310.6, 230, 'sans');
		}

		layerChars();

		camMovement.cancel();
		getCamOffsets();

		camFollow.x = dadPos[0];
		camFollow.y = dadPos[1];
		camMovement = FlxTween.tween(camFollow, {x: dadPos[0], y: dadPos[1]}, 0, {ease: FlxEase.quintOut});

		defaultCamZoom = oldDefaultCamZoom;
		trace('old def zoom: ' + oldDefaultCamZoom);
		FlxG.camera.zoom = defaultCamZoom;
	}

	var canPressSpace:Bool = false;
	var focusedOnChar:Bool = false;
	var isDodgeEvent:Bool = false;

	function dodgeAttackEvent(?type:String = 'sans', ?special = '')
	{
		if ((!isDodgeEvent || special == 'rb_back') && mechanicsEnabled)
		{
			canPause = false;
			isDodgeEvent = true;
			dodgeType = type;
			pressedSpace = false;
			canPressSpace = true;

			var waitTime:Float = 1;

			switch (type)
			{
				case 'sans':
					FlxG.sound.play(Paths.sound('notice', 'sans'), 0.6);

					alarm.alpha = 1;
					alarm.animation.play('play', true);

					waitTime = Conductor.crochet / 500;
				case 'blue':
					FlxG.sound.play(Paths.sound('notice', 'sans'), 0.6);

					alarmbone.alpha = 1;
					alarmbone.animation.play('playblue', true);

					waitTime = Conductor.crochet / 500;
				case 'orange':
					FlxG.sound.play(Paths.sound('notice', 'sans'), 0.6);

					alarmbone.alpha = 1;
					alarmbone.animation.play('playorange', true);

					waitTime = Conductor.crochet / 500;
				case 'sammy':
					dad.playAnim('End1', true, false, 0, true, 'End2');
					// FlxG.sound.play(Paths.sound('notice', 'sans'));
					FlxG.sound.play(Paths.sound('sammyAxeThrow', 'shared'));
					waitTime = 0.7;

					new FlxTimer().start(0.6, function(tmr:FlxTimer)
					{
						sammyAxe.alpha = 1;
						sammyAxe.animation.play('throw');
						sammyAxe.animation.curAnim.curFrame = 0;
					});
				case 'cuphead':
					waitTime = 0.7;
					var shootWait = 0.5;
					dad.preventDance = true;
					switch (special)
					{
						case 'roundabout':
							remove(boyfriend);
							remove(cupBullets[1]);
							add(cupBullets[1]);
							add(boyfriend);
							shootWait = 0.5;
							dad.playAnim('attack2', true, false, 0, true, 'idle');
							special = 'roundabout';
							dad.animation.finishCallback = function(attack2)
							{
								if (SONG.song.toLowerCase() == 'devils-gambit')
								{
									new FlxTimer().start(0.81, function(tmr:FlxTimer)
									{
										dad.idleReplacement = '';
									});
								}
								else
								{
									new FlxTimer().start(shootWait, function(tmr:FlxTimer)
									{
										dodgeAttackEvent('cuphead', 'rb_back');
									});
								}
							}
							waitTime = 0.4 + shootWait;
						case 'chaser':
							waitTime = 2.2;
							
						case 'rb_back':
							waitTime = 0.9;
							remove(boyfriend);
							remove(cupBullets[1]);
							add(boyfriend);
							add(cupBullets[1]);
						case 'alt':
							dad.playAnim('attack2', true);
							special = 'hadoken';
							dad.animation.finishCallback = function(attack2)
							{
								dad.playAnim('regret', false);
								dad.animation.finishCallback = function(regret)
								{
									dad.dance();
								}
							}
						default:
							if (SONG.song.toLowerCase() == 'devils-gambit')
							{
								FlxG.sound.play(Paths.sound('pre_shoot', 'cup'),1);
							}
							dad.playAnim('attack2', true, false, 0, true, 'idle');
							special = 'hadoken';
							dad.animation.finishCallback = function(attack2)
							{
								if (SONG.song.toLowerCase() == 'devils-gambit')
								{
									new FlxTimer().start(0.8, function(tmr:FlxTimer)
									{
										dad.idleReplacement = '';
									});
								}
							}
					}
					cuptimer = new FlxTimer().start(shootWait, function(tmr:FlxTimer)
					{
						for (i in 0...cupBullets.length)
						{
							if (cupBullets[i].bType == special)
							{
								cupBullets[i].x = dad.getMidpoint().x;
								cupBullets[i].y = dad.getMidpoint().y;
								if (SONG.song.toLowerCase() == 'devils-gambit')
								{
									cupBullets[i].x = dad.getMidpoint().x - 200;
									cupBullets[i].y = dad.getMidpoint().y + 400;
								}
								cupBullets[i].state = 'shoot';
								cupBullets[i].time = 0;
								cupBullets[i].hsp = 0;
								cupBullets[i].vsp = 0; // roundabout breakes if you use it twice so i had to reset the time and stuff
							}
						}
						switch (special)
						{
							case 'hadoken':
								chromVal = 0.01;
								FlxTween.tween(this, {chromVal: 0.001}, 0.3);
							case 'roundabout':
								FlxG.sound.play(Paths.sound('shoot', 'cup'));
								chromVal = 0.01;
								FlxTween.tween(this, {chromVal: 0.001}, 0.3);
							case 'rb_back':
							// no sound
							default:
								chromVal = 0.01;
								FlxTween.tween(this, {chromVal: 0.001}, 0.3);
								FlxG.sound.play(Paths.sound('shoot', 'cup'));
						}
					});
			}

			focusedOnChar = true;
			camMovement.cancel();
			camFocus = 'bf';

			camMovement = FlxTween.tween(camFollow, {x: bfPos[0], y: bfPos[1]}, camLerp, {ease: FlxEase.quintOut});

			dietimer = new FlxTimer().start(waitTime, function(tmr:FlxTimer)
			{
				switch (type)
				{
					case 'sans':
						alarm.alpha = 1.0;
						alarm.animation.play('DIE', true);
						FlxG.sound.play(Paths.sound('sansattack', 'sans'));
						alarm.animation.finishCallback = function(name:String)
						{
							alarm.alpha = 0.0001;
							isDodgeEvent = false;
						}
					case 'blue':
						if (health > 0)
						{
							alarmbone.alpha = 1.0;
							alarmbone.animation.play('blue', true);
							FlxG.sound.play(Paths.sound('sansattack', 'sans'));
							alarmbone.animation.finishCallback = function(name:String)
							{
								alarmbone.alpha = 0.0001;
								isDodgeEvent = false;
							}
						}
					case 'orange':
						alarmbone.alpha = 1.0;
						alarmbone.animation.play('orange', true);
						FlxG.sound.play(Paths.sound('sansattack', 'sans'));
						alarmbone.animation.finishCallback = function(name:String)
						{
							alarmbone.alpha = 0.0001;
							isDodgeEvent = false;
						}
				}

				if (pressedSpace && special != 'chaser' || MainMenuState.showcase || PlayStateChangeables.botPlay)
				{
					switch (type)
					{
						case 'cuphead':
							FlxG.sound.play(Paths.sound('dodge', 'cup'));
						case 'sans':
							FlxG.sound.play(Paths.sound('dodge', 'sans'));
						case 'orange':
							FlxG.sound.play(Paths.sound('dodge', 'sans'));
						case 'sammy':
							new FlxTimer().start(0.08, function(tmr:FlxTimer)
							{
								FlxG.sound.play(Paths.sound('sammyAxeGround', 'shared'));
								FlxG.sound.play(Paths.sound('sansattack', 'sans'));
							});
					}

					switch (SONG.song.toLowerCase())
					{
						case 'devils-gambit' | 'ritual':
							boyfriend.playAnim('dodge', true, false, 0, true);
							boyfriend.alpha = 1;
						default:
							switch (type)
							{
								case 'blue':
									trace('nothing');
								default:
									{
										if (bfDodge != null)
										{
											trace('bf dodge is not null, using dodge spritesheet to dodge');
											chromVal = 0.002;
											FlxTween.tween(this, {chromVal: 0}, 0.3);
											bfDodge.alpha = 1;
											bfDodge.animation.play('Dodge', true);
											boyfriend.alpha = 0.0001;

											bfDodge.animation.finishCallback = function(name:String)
											{
												bfDodge.alpha = 0.0001;
												boyfriend.alpha = 1;
											}
										}
										else
										{
											trace('bf dodge is null, using bf spritesheet to dodge');
											chromVal = 0.002;
											FlxTween.tween(this, {chromVal: 0}, 0.3);
											boyfriend.playAnim('dodge', true, false, 0, true);
										}
									}
							}
					}
				}
				else if (type == 'blue')
				{
					FlxG.camera.shake(0.005);
				}
				else
				{
					if (type == 'sammy')
						boyfriend.playAnim('damage', true, false, 0, true);

					switch (special)
					{
						case 'chaser':
							healthTween(-0.1);
						case 'hadoken':
							if (mechanicType == 0 || mugcanhit)
							{
								if (SONG.song.toLowerCase() == 'knockout' && mugcanhit)
								{
									pushToAchievementIDS("Take One For The Team", true, false);
								}
								playerDie();
							}
							else
							{
								healthChange(-1.4); //70% of health
								boyfriend.playAnim('hurt', true, false, 0, true);
								FlxG.sound.play(Paths.sound('hurt', 'cup'), 1);
							}
						case 'roundabout' | 'rb_back':
							if (mechanicType == 0)
							{
								playerDie();
							}
							else
							{
								healthChange(-0.6); //30% of health
								boyfriend.playAnim('hurt', true, false, 0, true);
								FlxG.sound.play(Paths.sound('hurt', 'cup'), 1);
							}
						default:
							if (mechanicType == 0)
								{
									playerDie();
								}
							else 
								{
									healthChange(-1.0,'sans'); //50% of health
									//krChange(-1.0);
									boyfriend.playAnim('singUPmiss', true);
								}
					}

					FlxG.camera.shake(0.005);
				}

				focusedOnChar = false;

				canPressSpace = false;

				if (special != 'roundabout')
					canPause = true;

				new FlxTimer().start(1, function(tmr:FlxTimer)
				{
					if (alarm != null)
					{
						alarm.alpha = 0.0001;
					}
					if (alarmbone != null)
					{
						alarmbone.alpha = 0.0001;
					}
					isDodgeEvent = false;
				});
			});
		}
	}

	function nightmareBendyJump(dur:Int = 3)
	{
		var onRightSide:Bool = false;
		dad.preventDanceConstant = true;
		dad.playAnim('leap', true);
		FlxG.sound.play(Paths.sound('nmbendy_jump', 'bendy'));
		jumpingBendyTimer1 = new FlxTimer().start(0.5, function(tmr:FlxTimer)
		{
			FlxG.camera.shake(0.20, 0.05);
			var blast:FlxSprite = new FlxSprite(dad.x - 700, dad.y);
			blast.frames = Paths.getSparrowAtlas('characters/AAAAAAAAAAAAAAAAAA');
			blast.animation.addByPrefix('play', 'JumpEffect instance 1', 25, false);
			blast.setGraphicSize(Std.int(blast.width * 3));
			blast.animation.play('play');
			add(blast);
			blast.animation.finishCallback = function(name:String)
			{
				remove(blast);
				bfCanMove = true;
			}
		});

		jumpingBendyTimer2 = new FlxTimer().start(dur + 0.9, function(tmr:FlxTimer)
		{
			if (FlxG.random.bool(50)) // RIGHT
			{
				dad.x = 1390;
				dad.flipX = true;
				onRightSide = true;
			}
			else // LEFT
			{
				dad.x = -300;
				dad.flipX = false;
			}
		});

		jumpingBendyTimer3 = new FlxTimer().start(dur + 1, function(tmr:FlxTimer)
		{
			var warning:FlxSprite = new FlxSprite(dad.x, dad.y);
			warning.frames = Paths.getSparrowAtlas('characters/AAAAAAAAAAAAAAAAAA');
			warning.animation.addByPrefix('warn', 'Warning instance 1', 25, false);
			warning.setGraphicSize(Std.int(warning.width * 1.5));
			warning.animation.play('warn');
			add(warning);
			warning.animation.finishCallback = function(name:String)
			{
				remove(warning);
			}
		});

		jumpingBendyTimer4 = new FlxTimer().start(dur + 2, function(tmr:FlxTimer)
		{
			dad.playAnim('fall', true, false, 0, true);
			FlxG.sound.play(Paths.sound('nmbendy_land', 'bendy'));
			new FlxTimer().start(0.10, function(tmr:FlxTimer) // death check
			{
				bfCanMove = false;
				if (onRightSide == bfOnRight)
				{
					playerDie();
				}

				FlxG.camera.shake(0.20, 0.05);
			});
			new FlxTimer().start(0.66, function(tmr:FlxTimer)
			{
				dad.preventDanceConstant = false;
			});
		});
	}

	function startCupheadShoot()
	{
		if (!dad.animation.curAnim.name.contains('hit'))
		{
			dad.idleReplacement = 'attack1';
			cupheadPewMode = true;
			dad.playAnim('attack1', true, false, 0, true);

			dad.animation.finishCallback = function(attack1)
			{
				if (dad.preventDance == false)
				{
					if (!cupheadPewMode)
					{
						dad.idleReplacement = '';
					}
				}
			};
		}
	}

	function shootOnce(isNightmare:Bool = false)
	{
		var cupheadPewThing = new CupBullet('pewFX', dad.getMidpoint().x + 324, dad.getMidpoint().y - 27);
		if (SONG.player2 != 'cupheadNightmare')
		{
			cupheadPewThing.state = 'oneshoot';
			add(cupheadPewThing);

			cupheadPewThing.animation.finishCallback = function(name:String)
			{
				remove(cupheadPewThing);
			};

			// cupheadPewThing.x -= 80;
			// cupheadPewThing.y += 360;
		}

		var chaseOffset = [760, -40];
		var pew:String = 'pew';
		if (isNightmare)
		{
			pew = 'laser';
			chaseOffset = [700, 270];
		}
		var cupheadShot = new CupBullet(pew, dad.getMidpoint().x + chaseOffset[0], dad.getMidpoint().y + chaseOffset[1]);
		if (SONG.player2 == 'cupheadNightmare')
		{
			cupheadShot.x += 300;
			cupheadShot.y += 100;

			FlxG.sound.play(Paths.sound('attacks/pea' + FlxG.random.int(0, 5), 'cup'), 0.4);
		}
		else
		{
			FlxG.sound.play(Paths.sound('attacks/pea' + FlxG.random.int(0, 5), 'cup'), 0.6);
		}

		add(cupheadShot);
		cupheadShot.state = 'oneshoot';

		switch (songLowercase)
		{
			case 'knockout':
				pewdmg = 0.0475;

			case 'devils-gambit':
				pewdmg = 0.075;

			case 'technicolor-tussle':
				cupheadPewThing.x -= 100;
				cupheadShot.x-=100;
		}

		if (pewhits >= 10
			&& songLowercase != 'technicolor-tussle'
			&& cupheadPewMode) // to keep people from passing the bullet sections without dying
		{
			pewdmgScale += 0.15;
			if (songLowercase == 'devils-gambit')
				pewdmgScale += 0.05;
			pewdmg *= pewdmgScale;
		}
		else if (pewhits > 15 && songLowercase == 'technicolor-tussle' && cupheadPewMode)
		{
			pewdmgScale += 0.01;
			pewdmg *= pewdmgScale;
		}

		cupheadShot.pew = function()
		{
			if (!PlayStateChangeables.botPlay)
			{
				healthTween(-pewdmg);
				trace(pewdmg);
				pewhits += 1;
			}
		};

		cupheadShot.animation.finishCallback = function(name:String)
		{
			remove(cupheadShot);
		};
	}

	function knockout()
	{
		FlxG.sound.play(Paths.sound('knockout', 'cup'));

		knockoutSpr.alpha = 1;
		knockoutSpr.animation.play('start');

		new FlxTimer().start(2, function(tmr:FlxTimer)
		{
			FlxTween.tween(knockoutSpr, {alpha: 0}, 2.5);
			new FlxTimer().start(4, function(tmr:FlxTimer)
			{
				knockoutSpr.alpha = 0.0001;
			});
		});
	}

	var dead:Bool = false;

	public function playerDie()
	{
		if (!usedTimeTravel && !dead && !cannotDie)
		{
			if (vocals != null)
			{
				vocals.stop();
				vocals.destroy();
			}
			vocals = null;
			FlxG.sound.music.stop();
	
			if (FlxG.save.data.highquality && !FlxG.save.data.photosensitive)
			{
				setChrome(defaultChromVal);
			}

			if (SONG.song.toLowerCase() == 'sansational')
			{
				geno = false;
			}

			deathCount++;

			persistentUpdate = false;

			dead = true;

			boyfriend.stunned = true;

			paused = true;

			canPause = false;

			FlxTween.cancelTweensOf(defaultBrightVal);
			FlxTween.cancelTweensOf(defaultCamZoom);
			defaultBrightVal = 0.0;
			defaultCamZoom = oldDefaultCamZoom;

			switch (curStage)
			{
				case 'factory':
					GameOverSubstate.gameOverChar = 'bendy';
			}

			if (SONG.song.toLowerCase() == 'despair')
			{
				FlxG.save.data.despairdeaths += 1;
			}

			if (FlxG.save.data.despairdeaths >= 50)
			{
				pushToAchievementIDS("Unworthy III", true);
			}

			changeSpeed(0);

			if (fuckinAngry)
			{
				FlxG.sound.music.stop();
				persistentDraw = false;

				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;

				filters = [];
				FXHandler.UpdateColors();

				if (curStage == 'devilHall')
				{
					FlxTween.tween(fgStatic, {alpha: 0}, 1);
					FlxTween.tween(fgGrain, {alpha: 0}, 1);
				}

				JumpscareState.allowRetry = true;
				FNFState.disableNextTransIn = true;
				FNFState.disableNextTransOut = true;
				FlxG.switchState(new JumpscareState());
			}
			else
			{
				if (curStage == 'field' || curStage == 'devilHall')
				{
					persistentDraw = true;
					slow = false;

					if (wallop != null)
					{
						wallop.destroy();
						remove(wallop);
					}

					FlxTween.tween(camHUD, {alpha: 0}, 1);
					FlxG.camera.shake(0.005);

					camMovement.cancel();

					camMovement = FlxTween.tween(camFollow, {x: bfPos[0], y: bfPos[1]}, camLerp);

					if (SONG.song.toLowerCase() == 'knockout')
					{
						FlxTween.tween(fgRain, {alpha: 0}, 1);
						FlxTween.tween(fgRain2, {alpha: 0}, 1);
					}

					FlxTween.tween(fgStatic, {alpha: 0}, 1);
					FlxTween.tween(fgGrain, {alpha: 0}, 1);

					openSubState(new GameOverCuphead(Conductor.songPosition, FlxG.sound.music.length));
					FlxG.sound.music.stop();
				}
				else
				{
					chromVal = 0;
					FlxG.sound.music.stop();
					persistentDraw = false;
					filters = [];
					FXHandler.UpdateColors();
					if (PlayState.SONG.song.toLowerCase() == 'bonedoggle')
					{
						pushToAchievementIDS("Captured", true);
						if (!FlxG.save.data.givenCode || MainMenuState.debugTools)
						{
							GameOverSubstate.gameOverChar = 'papyrus';
						}
					}

					if ((curStage == 'hall' || curStage == 'papyrus') && battleMode)
					{
						defaultCamZoom = 1;
						FlxG.camera.zoom = 1;
						openSubState(new SansGameover());
					}
					else
					{
						if (curStage == 'hall' || curStage == 'papyrus')
						{
							GameOverSubstate.sansSong = true;
						}
						else
						{
							GameOverSubstate.sansSong = false;
						}

						FlxG.camera.alpha = 1;
						camHUD.alpha = 1;

						openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
					}
				}
			}

			#if cpp
			// Game Over doesn't get his own variable because it's only used here
			var disSong:String = SONG.song;
			if (HelperFunctions.shouldBeHidden(SONG.song.toLowerCase()))
				disSong = '[CONFIDENTIAL]';
			DiscordClient.changePresence("GAME OVER -- "
				+ disSong
				+ " ("
				+ storyDifficultyText
				+ ") "
				+ Ratings.GenerateLetterRank(accuracy),
				"\nAcc: "
				+ HelperFunctions.truncateFloat(accuracy, 2)
				+ "% | Score: "
				+ songScore
				+ " | Misses: "
				+ misses, iconRPC);
			#end
		}
	}

	function checkAchievements()
	{
		if (storyDifficulty == 2)
		{
			var songsNotFCd:Int = 0;
			for (i in 0...StoryMenuState.weekData[storyWeek].length)
			{
				var songHighscore = StringTools.replace(StoryMenuState.weekData[storyWeek][i], " ", "-");

				trace("highscore for " + songHighscore + ": " + Highscore.getCombo(songHighscore, 2).toLowerCase());

				if (Highscore.getCombo(songHighscore, 2).toLowerCase().contains('fc'))
				{
					trace('gj you fcd it!!!');
				}
				else
				{
					trace('dumbass you didnt fc it');
					songsNotFCd++;
				}
			}

			trace("you have not fcd " + songsNotFCd + " songs");

			if (songsNotFCd == 0) //has fcd the whole week
			{
				trace('gj! you fcd week ' + storyWeek);
				switch (storyWeek)
				{
					case 0:
						pushToAchievementIDS("The Legendary Chalice", true);
					case 1:
						pushToAchievementIDS("Determination", true);
					case 2:
						pushToAchievementIDS("Bring Home the Bacon", true);
				}
			}
		}

		if (SONG.song.toLowerCase() == 'final-stretch' && isStoryMode)
		{
			if (!geno)
			{
				pacifistShit();
			}
		}

		if (SONG.song.toLowerCase() == 'burning-in-hell' && isStoryMode)
		{
			new FlxTimer().start(22.6, function(tmr:FlxTimer) // timed to the cutscene
			{
				FlxG.save.data.hasgenocided = true;
				pushToAchievementIDS("Genocide", true, false);
			});
		}

		if (isStoryMode)
		{
			switch (songLowercase)
			{
				case 'knockout' | 'burning-in-hell' | 'final-stretch' | 'nightmare-run' | 'last-reel':
					var num:Int = -1;

					switch (songLowercase)
					{
						case 'knockout':
							num = 0;
						case 'burning-in-hell' | 'final-stretch':
							num = 1;
						case 'nightmare-run':
							num = 2;
					}

					if (SONG.song.toLowerCase() == 'last-reel' && storyDifficultyText != 'Hard')
					{
						num = 2;
					}

					if (num != -1)
					{
						FlxG.save.data.weeksbeat[num] = true;
						FlxG.save.data.freeplaylocked[0] = false;
						FlxG.save.data.freeplaylocked[1] = false;
	
						if (storyDifficultyText == 'Hard')
						{
							FlxG.save.data.weeksbeatonhard[num] = true;
						}
					}
			}

			trace("weeks beat: " + FlxG.save.data.weeksbeat);
			trace("weeks beat on hard: " + FlxG.save.data.weeksbeatonhard);
		}

		switch (songLowercase)
		{
			case 'devils-gambit':
				pushToAchievementIDS("Ultimate Knockout", true);
				FlxG.save.data.huh = false;
			case 'bad-time':
				pushToAchievementIDS("bad time", true);
				FlxG.save.data.huh = false;
			case 'despair':
				pushToAchievementIDS("Inking Mistake", true);
				FlxG.save.data.huh = false;
			default:
				trace('not one of the unlockable nightmare achievements');
		}

		FlxG.save.flush();
	}

	function convertScore(noteDiff:Float):Int
	{
		var daRating:String = Ratings.judgeNote(noteDiff);

		switch (daRating)
		{
			case 'shit':
				return -300;
			case 'bad':
				return 0;
			case 'good':
				return 200;
			case 'sick':
				return 350;
			default:
				return 0;
		}
	}

	function pushToSpecialAnim(target:String = 'bf')
	{
		/*if (target == 'bf')
		{
			for (anim => offsets in boyfriend.animOffsets)
			{
				if (anim.contains('idle') || anim.contains('sing')) {}
				else
				{
					bfStopAnimsList.push(anim);
				}
			}
			trace(bfStopAnimsList);
		}
		else if (target == 'player3')
		{
			for (anim => offsets in player3.animOffsets)
			{
				if (anim.contains('idle') || anim.contains('sing')) {}
				else
				{
					player3SpecialAnimList.push(anim);
				}
			}
			trace(player3SpecialAnimList);
		}
		else
		{
			for (anim => offsets in dad.animOffsets)
			{
				if (anim.contains('idle') || anim.contains('sing') || anim.contains('pew') || anim.contains('attack1')) {}
				else
				{
					if (dad.curCharacter == 'papyrus')
					{
						if (anim.contains('wakeup') || anim.contains('jghrue') || anim.contains('upahgn') || anim.contains('istg')) {}
						else
						{
							dadSpecialAnimList.push(anim);
						}
					}
					else
					{
						dadSpecialAnimList.push(anim);
					}
				}
			}
			trace(dadSpecialAnimList);
		}*/
	}

	function triggerCamMovement(num:Float = 0)
	{
		if (!focusedOnChar && !FlxG.save.data.photosensitive)
		{
			camMovement.cancel();

			if (camFocus == 'bf')
			{
				switch (num)
				{
					case 2:
						camMovement = FlxTween.tween(camFollow, {y: bfPos[1] - daFunneOffsetMultiplier, x: bfPos[0]}, Conductor.crochet / 10000,
							{ease: FlxEase.circIn});
					case 3:
						camMovement = FlxTween.tween(camFollow, {x: bfPos[0] + daFunneOffsetMultiplier, y: bfPos[1]}, Conductor.crochet / 10000,
							{ease: FlxEase.circIn});
					case 1:
						camMovement = FlxTween.tween(camFollow, {y: bfPos[1] + daFunneOffsetMultiplier, x: bfPos[0]}, Conductor.crochet / 10000,
							{ease: FlxEase.circIn});
					case 0:
						camMovement = FlxTween.tween(camFollow, {x: bfPos[0] - daFunneOffsetMultiplier, y: bfPos[1]}, Conductor.crochet / 10000,
							{ease: FlxEase.circIn});
				}
			}
			else if (camFocus == 'player3')
			{
				switch (num)
				{
					case 2:
						camMovement = FlxTween.tween(camFollow, {y: player3Pos[1] - daFunneOffsetMultiplier, x: player3Pos[0]}, Conductor.crochet / 10000,
							{ease: FlxEase.circIn});
					case 3:
						camMovement = FlxTween.tween(camFollow, {x: player3Pos[0] + daFunneOffsetMultiplier, y: player3Pos[1]}, Conductor.crochet / 10000,
							{ease: FlxEase.circIn});
					case 1:
						camMovement = FlxTween.tween(camFollow, {y: player3Pos[1] + daFunneOffsetMultiplier, x: player3Pos[0]}, Conductor.crochet / 10000,
							{ease: FlxEase.circIn});
					case 0:
						camMovement = FlxTween.tween(camFollow, {x: player3Pos[0] - daFunneOffsetMultiplier, y: player3Pos[1]}, Conductor.crochet / 10000,
							{ease: FlxEase.circIn});
				}
			}
			else if (dad.alpha == 1)
			{
				switch (num)
				{
					case 2:
						camMovement = FlxTween.tween(camFollow, {y: dadPos[1] - daFunneOffsetMultiplier, x: dadPos[0]}, Conductor.crochet / 10000,
							{ease: FlxEase.circIn});
					case 3:
						camMovement = FlxTween.tween(camFollow, {x: dadPos[0] + daFunneOffsetMultiplier, y: dadPos[1]}, Conductor.crochet / 10000,
							{ease: FlxEase.circIn});
					case 1:
						camMovement = FlxTween.tween(camFollow, {y: dadPos[1] + daFunneOffsetMultiplier, x: dadPos[0]}, Conductor.crochet / 10000,
							{ease: FlxEase.circIn});
					case 0:
						camMovement = FlxTween.tween(camFollow, {x: dadPos[0] - daFunneOffsetMultiplier, y: dadPos[1]}, Conductor.crochet / 10000,
							{ease: FlxEase.circIn});
				}
			}
		}
	}

	var overrideDaSploosh:Bool = false;

	function hitGoodNote(note:Note, extraHeal:Bool = false, overrideSploosh:Bool = false, noteDiff:Float)
	{
		if (note.prevNote.strumTime == note.strumTime)
		{
			if (note.prevNote.mustPress && note.mustPress)
			{
				trace('double note hit!');
			}
		}

		overrideDaSploosh = overrideSploosh;
		if (!note.isSustainNote)
		{
			popUpScore(note, extraHeal);

			combo += 1;
		}
		else
		{
			if (!PlayStateChangeables.botPlay && canheal)
			{
				healthTween(0.015);
			}
			totalNotesHit += 1;
		}

		var delay:Int = 0;

		if (note.isSustainNote && boyfriend.curCharacter != 'bfChase')
		{
			delay = 4;
		}

		var altAnim:String = '';
		if (bfBendoCustomExpression != '')
		{
			altAnim = bfBendoCustomExpression;
		}

		if ((boyfriend.specialAnimList.contains(boyfriend.animation.curAnim.name) && boyfriend.animation.curAnim.finished)
			|| !boyfriend.specialAnimList.contains(boyfriend.animation.curAnim.name))
		{
			boyfriend.holdTimer = 0;
			boyfriend.playAnim('sing' + dataSuffix[note.noteData % 4] + altAnim, true, false, delay);
		}

		if (PlayStateChangeables.botPlay || MainMenuState.showcase)
		{
			playerStrums.forEach(function(spr:FlxSprite)
			{
				if (Math.abs(note.noteData) == spr.ID)
				{
					spr.animation.play('confirm', true);
				}
				if (spr.animation.curAnim.name == 'confirm')
				{
					spr.centerOffsets();
					spr.offset.x -= 13;
					spr.offset.y -= 13;
				}
				else
					spr.centerOffsets();
			});
		}

		canDanceBF = false;

		boyfriend.animation.finishCallback = function(name:String)
		{
			canDanceBF = true;
		};

		if (camFocus == 'bf' && canCameraMove)
		{
			triggerCamMovement(note.noteData % 4);
		}

		#if cpp
		if (luaModchart != null)
			luaModchart.executeState('playerOneSing', [note.noteData, Conductor.songPosition]);
		#end

		if (!PlayStateChangeables.botPlay)
		{
			playerStrums.forEach(function(spr:FlxSprite)
			{
				if (Math.abs(note.noteData) == spr.ID)
				{
					spr.animation.play('confirm', true);
				}
			});
		}

		note.wasGoodHit = true;

		if (vocals != null)
			vocals.volume = 1;

		note.kill();
		notes.remove(note, true);
		note.destroy();

		updateAccuracy();
	}

	function meterUpdate()
	{
		didntdoanimyet = false;
		cardbar.alpha = 0.0001;
		cardanims.alpha = 1;
		cardanims.animation.play('parry', true);
		cardfloat += 200;
	}

	function useAttackSlot()
	{
		trace(cardfloat);
		if (cardfloat >= 200)
		{
			// attackMeter.y = healthBarBG.y - 10;
			// attackMeter.animation.play('blank', true);
			canheal = true;	
			cardfloat = 0;
			poped = true;
			cardanims.animation.play('use', true);
			cupheadPewMode = false;
			pewdmgScale = 1.0;
			cardanims.animation.finishCallback = function(use)
			{
				didntdoanimyet = true;
				cardbar.alpha = 1;
				if (cardfloat < 200)
					cardanims.alpha = 0.0001;
			}

			new FlxTimer().start(0.3, function(tmr:FlxTimer)
			{
				chromVal = 0.004;
				FlxTween.tween(this, {chromVal: 0.001}, 0.3);
				if (forceAlt)
					dad.playAnim('hit-alt',true, false, 0, true);
				else
					dad.playAnim('hit',true , false, 0, true);
				FlxG.sound.play(Paths.sound('hurt', 'cup'), 0.5);
				dad.animation.callback = function(hit, aaa, frameIndex:Int)
				{
					if (aaa == 23)
					{
						if (dad.animation.curAnim.name == 'attack1')
							dad.idleReplacement = '';
						dad.dance();
					}
				}
				healthChange(0.5);
				pewhits = 0;
				switch (songLowercase)
				{
					case 'technicolor-tussle':
						pewdmg = 0.0225;

					case 'knockout':
						pewdmg = 0.0475;

					case 'devils-gambit':
						pewdmg = 0.075;
				}
			});

			boyfriend.playAnim('attack');
			boyfriend.playAnim('attack', true, false, 0, true);
			FlxG.sound.play(Paths.sound('Throw' + FlxG.random.int(1, 3), 'sans'));
			boyfriend.animation.finishCallback = function(attack)
			{
				boyfriend.playAnim('idle', true);
			}

		}
	}

	var canDanceDad:Bool = true;
	var canDanceBF:Bool = true;
	var canDancePlayer3:Bool = true;

	public static var bfBendoCustomExpression:String = '';

	function charsDance(?char:String = 'all')
	{
		if (char == 'all' || char == 'bf')
		{
			if (canDanceBF)
			{
				var altAnim:String = "";
				if (boyfriend.animation.curAnim.name.startsWith("idle")
					&& ((boyfriend.specialAnimList.contains(boyfriend.animation.curAnim.name) && boyfriend.animation.curAnim.finished))
					|| !boyfriend.specialAnimList.contains(boyfriend.animation.curAnim.name)
					&& boyfriend.animation.curAnim.name.startsWith("idle"))
				{
					if (SONG.notes[Math.floor(curStep / 16)] != null)
					{
						if (SONG.notes[Math.floor(curStep / 16)].altAnim)
							altAnim = '-alt';
					}

					if (bfBendoCustomExpression != '')
					{
						altAnim = bfBendoCustomExpression;
					}

					boyfriend.dance(altAnim);
				}
			}
		}

		if (char == 'all' || char == 'p3')
		{
			if (player3.curCharacter != 'none')
			{
				if (canDancePlayer3)
				{
					var altAnim:String = "";

					if (SONG.notes[Math.floor(curStep / 16)] != null)
					{
						if (SONG.notes[Math.floor(curStep / 16)].altAnim)
							altAnim = '-alt';
					}

					if (!overridePlayer3Anim)
					{
						if ((player3.specialAnimList.contains(player3.animation.curAnim.name)
							&& player3.animation.curAnim.finished)
							|| !player3.specialAnimList.contains(player3.animation.curAnim.name))
						player3.dance(altAnim);
					}
				}
			}
		}

		if (char == 'all' || char == 'dad')
		{
			if (canDanceDad)
			{
				var altAnim:String = "";

				if (SONG.notes[Math.floor(curStep / 16)] != null)
				{
					if (SONG.notes[Math.floor(curStep / 16)].altAnim || forceAlt)
					{
						altAnim = '-alt';
					}
				}

				if (!overrideDadAnim)
				{
					if ((dad.specialAnimList.contains(dad.animation.curAnim.name) && dad.animation.curAnim.finished)
						|| !dad.specialAnimList.contains(dad.animation.curAnim.name))
					{
						if (dad.curCharacter == 'bendy')
						{
							//trace('is bendy and is attempting idle');
							if ((dad.animation.curAnim.name.contains('sing') && dad.animation.curAnim.finished)
								|| !dad.animation.curAnim.name.contains('sing'))
							{
								//trace('successfully did idle, the animation was ' + dad.animation.curAnim.name);
								dad.dance(altAnim);
							}
						}
						else
						{
							dad.dance(altAnim);
						}
					}
				}
			}
		}
	}

	var forceAlt:Bool = false;

	function pauseGame()
	{
		if (!dead)
		{
			persistentUpdate = false;
			persistentDraw = true;
		}
		paused = true;

		if (gameVideos != null)
		{
			for (i in 0...gameVideos.length)
			{
				gameVideos[i].bitmap.pause();
			}
		}

		openSubState(new PauseSubState());
	}

	function antiCheat()
	{
		if (!FlxG.fullscreen)
		{
			var output = new Process("tasklist", []).stdout.readAll().toString().toLowerCase();
			var blockedShit:Array<String> = ['fnfbot.exe', 'fnfbot20.exe', 'form1.exe', 'cheatengine.exe']; //people managed to break the game with cheat engine lmfao

			trace('checking for fnf bot');

			for (i in 0...blockedShit.length)
			{
				if (output.contains(blockedShit[i]))
				{
					trace(blockedShit[i]);
					throw new ValueException("Don't Cheat :)");
					// System.exit(0);
				}
			}
		}
	}

	function getCamOffsets()
	{
		// offset shit FUCK

		// dad shit
		dadPos[0] = dad.getMidpoint().x + 150 + offsetX + enXOff;
		dadPos[1] = dad.getMidpoint().y - 100 + offsetY + enYOff;

		switch (dad.curCharacter)
		{
			case 'bendy':
				trace('bendy');
				dadPos[0] = dad.getMidpoint().x + 425 + offsetX + enXOff;
				dadPos[1] = dad.getMidpoint().y - 125 + offsetY + enYOff;
				if (SONG.song.toLowerCase() == 'last-reel')
				{
					dadPos[0] = dad.getMidpoint().x + 425 + offsetX + enXOff;
				}
				else if (SONG.song.toLowerCase() == 'imminent-demise')
				{
					dadPos[1] = dad.getMidpoint().y + offsetY + enYOff;
				}
			case 'bendyChase':
				dadPos[0] = dad.getMidpoint().x + 430 + offsetX + enXOff;
			case 'sansNightmare':
				dadPos[0] = dad.getMidpoint().x + 180 + offsetX + enXOff;
				dadPos[1] = dad.getMidpoint().y + 50 + offsetY + enYOff;
			case 'sans' | 'sansScared':
				dadPos[0] = dad.getMidpoint().x + 180 + offsetX + enXOff;
			case 'devilFull':
				dadPos[1] = dad.getMidpoint().y - 100 + offsetY + enYOff;
			case 'cupheadNightmare':
				dadPos[1] = dad.getMidpoint().y + 150 + offsetY + pYOff;
			case 'bendyNightmare':
				dadPos[0] = dad.getMidpoint().x + 320 + offsetX + enXOff;
				dadPos[1] = dad.getMidpoint().y - 40 + offsetY + enYOff;
		}

		if (player3.curCharacter == 'sanswinter')
		{
			dadPos[0] -= 150;
		}

		// bf shit
		bfPos[0] = boyfriend.getMidpoint().x - 700 + offsetX + pXOff;
		bfPos[1] = boyfriend.getMidpoint().y - 100 + offsetY + pYOff;

		switch (curStage)
		{
			case 'factory':
				bfPos[1] = boyfriend.getMidpoint().y - 320 + offsetY + pYOff;

				if (SONG.song.toLowerCase() == 'imminent-demise')
				{
					bfPos[0] = boyfriend.getMidpoint().x - 250 + offsetX + pXOff;
				}
				else if (SONG.song.toLowerCase() == 'terrible-sin')
				{
					bfPos[0] = boyfriend.getMidpoint().x - 400 + offsetX + pXOff;
				}

				if (fuckinAngry)
				{
					bfPos[0] = boyfriend.getMidpoint().x - 550 + offsetX + pXOff;
					bfPos[1] = boyfriend.getMidpoint().y - 320 + offsetY + pYOff;
				}
			case 'field':
				{
					bfPos[1] = boyfriend.getMidpoint().y - 170 + offsetY;
				}
			case 'hall' | 'papyrus':
				{
					if (SONG.song.toLowerCase() == 'bad-to-the-bone')
						bfPos[0] = boyfriend.getMidpoint().x - 350 + offsetX + pXOff;
					else
						bfPos[0] = boyfriend.getMidpoint().x - 900 + offsetX + pXOff;
					if (fuckinAngry || SONG.song.toLowerCase() == 'bonedoggle')
					{
						bfPos[0] = boyfriend.getMidpoint().x - 500 + offsetX + pXOff;
					}
					bfPos[1] = boyfriend.getMidpoint().y - 150 + offsetY + pYOff;

					if (SONG.song.toLowerCase() == 'bad-time')
					{
						bfPos[0] -= 400;
					}
				}
			case 'devilHall':
				{
					if (SONG.song.toLowerCase() == 'devils-gambit')
					{
						bfPos[1] = boyfriend.getMidpoint().y - 50 + offsetY + pYOff;
					}
					else
					{
						bfPos[1] = boyfriend.getMidpoint().y - 250 + offsetY + pYOff;
					}
				}
		}
		if (dad.curCharacter == 'sansbattle')
			dadPos[0] -= 200;

		if (battleMode)
		{
			// trace(bfPos[0] + 'bf x');
			// trace(dadPos[0] + 'dad x');
		}

		// player3 shit
		player3Pos[0] = player3.getMidpoint().x + 150 + offsetX + enXOff;
		player3Pos[1] = player3.getMidpoint().y - 100 + offsetY + enYOff;
	}

	function cardtweening(amt:Float)
	{
		if (SONG.song.toLowerCase() != 'snake-eyes' && mechanicsEnabled)
		{
			if (cardtween != null)
				cardtween.cancel();
			cardtween = FlxTween.num(cardfloat, cardfloat + amt, 0.001, {ease: FlxEase.cubeInOut}, function(v:Float)
			{
				cardfloat = v;
			});
		}
	}

	function healthTween(amt:Float)
	{
		healthTweenObj.cancel();
		healthTweenObj = FlxTween.num(health, health + amt, 0.1, {ease: FlxEase.cubeInOut}, function(v:Float)
		{
			health = v;
			if (curStage == 'hall')
				updatesansbars();
		});
	}

	function healthChange(amt:Float,typeatk:String = 'urmom')
	{
		healthTweenObj.cancel();

		switch(typeatk)//may be useful later
		{
			default:
				health += amt;
		}
		
		if (curStage == 'hall')
			updatesansbars();
	}

	function krTween(amt:Float) {
		if (health <= 0)
			amt = Math.abs(amt);
		krTweenObj.cancel();
		krTweenObj = FlxTween.num(kr, kr - amt, 0.1, {ease: FlxEase.cubeInOut}, function(v:Float)
		{
			kr = v;
			updatesansbars();
		});
	}

	function krChange(amt:Float, force:Bool = false) {

		if (health <= 0)
		{
			amt = Math.abs(amt);
		}
		
		if (krTweenObj!=null)
			krTweenObj.cancel();

		if (force)
			kr = amt;
		else
			kr -= amt;

		updatesansbars();
	}

	function healthSet(amt:Float, duration:Float)
	{
		healthTweenObj.cancel();
		healthTweenObj = FlxTween.num(health, amt, duration, {ease: FlxEase.cubeInOut}, function(v:Float)
		{
			health = v;
		});
	}

	function layerChars()
	{
		if ((dad.curCharacter.contains('san') && dad.curCharacter.toLowerCase() != 'saness') || dad.curCharacter.contains('cup'))
		{
			add(dad);
			add(boyfriend);

			if (SONG.song.toLowerCase() == 'devils-gambit')
			{
				cupBullets[1] = new CupBullet('hadoken', 0, 0);
				add(cupBullets[1]);
			}
		}
		else
		{
			add(boyfriend);
			add(dad);
		}

		if (curStage == 'hall')
		{
			remove(boyfriend);
			remove(dad);
			add(boyfriend);
			add(dad);
		}

		// NIGHTMARE RUN STAIRS
		if (SONG.song.toLowerCase() == 'nightmare-run' && nmStairs)
		{
			stairsBG = new FlxBackdrop(Paths.image('stairs/scrollingBG', 'bendy'), 0, 1, false, true);
			stairsBG.screenCenter();
			stairsBG.velocity.set(0, 240);

			stairsChainL = new FlxBackdrop(Paths.image('stairs/chainleft', 'bendy'), 0, 1, false, true);
			stairsChainL.screenCenter();
			stairsChainL.x -= 500;
			stairsChainL.velocity.set(0, 1000);

			stairsChainR = new FlxBackdrop(Paths.image('stairs/chainright', 'bendy'), 0, 1, false, true);
			stairsChainR.screenCenter();
			stairsChainR.x += 520;
			stairsChainR.velocity.set(0, 1510);

			remove(boyfriend);
			remove(dad);
			stairsGrp.add(stairsBG);
			stairsGrp.add(boyfriend);
			stairsGrp.add(dad);
			boyfriend.setZoom(0.6);
			dad.setZoom(0.85);

			stairs = new FlxSprite(0, 0).loadGraphic(Paths.image('stairs/stairs', 'bendy'));
			stairs.updateHitbox();
			stairs.screenCenter();
			stairs.alpha = 1.0;
			stairs.antialiasing = FlxG.save.data.highquality;
			stairs.y -= 920;
			stairsGrp.add(stairs);
			FlxTween.tween(stairs, {y: 1120}, 2.3, {type: LOOPING});
			stairsGrp.add(stairsChainL);
			stairsGrp.add(stairsChainR);
			stairsGrp.add(stairsGradient);
		}
		else if (SONG.song.toLowerCase() == 'nightmare-run' && !nmStairs)
		{
			if (stairsGrp != null)
			{
				for (member in stairsGrp)
				{
					member.kill();
				}
			}
			// the transitions aren't layered correctly if somebody could fix it that would be awesom
		}

		if (SONG.song.toLowerCase() == 'despair')
		{
			dad.alpha = 0.00001;
		}
	}

	function checkFocus(?resync:Bool = true,forcefocus:String = '',addzoom:Float=0,speed:Float=0)
	{
		var lastspeed:Float;
		if (speed == 0)
			lastspeed=camLerp;
		else
			lastspeed=speed;

		if (resync)
		{
			resyncVocals();
		}

		if (generatedMusic && SONG.notes[Std.int(curStep / 16)] != null)
		{
			if (luaModchart != null)
				luaModchart.setVar("mustHit", PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection);

			camOffsetGet();
			if (ball != null) {
				camMovement.cancel();
				camFollow.x = battle.x + (battle.width / 2);
				camFollow.y = bfPos[1];
			}
			else {
				if (camFocus != 'player3' && SONG.notes[Std.int(curStep / 16)].focusCamOnPlayer3)
				{
					if (luaModchart != null)
					{
						offsetX = luaModchart.getVar("followXOffset", "float");
						offsetY = luaModchart.getVar("followYOffset", "float");
					}

					camMovement.cancel();
					camFocus = 'player3';

					if (canCameraMove)
						camMovement = FlxTween.tween(camFollow, {x: player3Pos[0], y: player3Pos[1]}, lastspeed, {ease: FlxEase.quintOut});

					if (luaModchart != null)
						luaModchart.executeState('playerThreeTurn', []);
				}
				if (camFocus != "dad"
					&& !SONG.notes[Std.int(curStep / 16)].mustHitSection
					&& !SONG.notes[Std.int(curStep / 16)].focusCamOnPlayer3|| forcefocus == 'dad')
				{
					if (luaModchart != null)
					{
						offsetX = luaModchart.getVar("followXOffset", "float");
						offsetY = luaModchart.getVar("followYOffset", "float");
					}

					camMovement.cancel();
					camFocus = 'dad';

					if (canCameraMove)
						camMovement = FlxTween.tween(camFollow, {x: dadPos[0], y: dadPos[1]}, lastspeed, {ease: FlxEase.quintOut});

					if (luaModchart != null)
						luaModchart.executeState('playerTwoTurn', []);

					if (SONG.song.toLowerCase() == 'imminent-demise')
					{
						if (vocals != null)
						{
							vocals.volume = 1;
						}
					}
				}
				if (camFocus != "bf"
					&& SONG.notes[Std.int(curStep / 16)].mustHitSection
					&& !SONG.notes[Std.int(curStep / 16)].focusCamOnPlayer3|| forcefocus == 'bf')
				{
					if (luaModchart != null)
					{
						offsetX = luaModchart.getVar("followXOffset", "float");
						offsetY = luaModchart.getVar("followYOffset", "float");
					}

					camMovement.cancel();
					camFocus = 'bf';

					if (canCameraMove)
						camMovement = FlxTween.tween(camFollow, {x: bfPos[0], y: bfPos[1]}, lastspeed, {ease: FlxEase.quintOut});

					if (luaModchart != null)
						luaModchart.executeState('playerOneTurn', []);
				}
			}
		}

		if (forcefocus != '')
		{
			canCameraMove=false;
			FlxTween.tween(this, {defaultCamZoom: oldDefaultCamZoom + addzoom}, speed, {ease: FlxEase.quadOut});
		}
	}

	function strumToggle(player:String, visible:Bool, ?fade:Float = .05)
	{
		switch (player)
		{
			case 'dad':
				if (!visible)
				{
					for (i in 0...4)
					{
						FlxTween.tween(strumLineNotes.members[i], {alpha: 0}, fade);
					}
				}
				else
				{
					for (i in 0...4)
					{
						FlxTween.tween(strumLineNotes.members[i], {alpha: 1}, fade);
					}
				}

			case 'bf':
				if (!visible)
				{
					for (i in 4...8)
					{
						FlxTween.tween(strumLineNotes.members[i], {alpha: 0}, fade);
					}
				}
				else
				{
					for (i in 4...8)
					{
						FlxTween.tween(strumLineNotes.members[i], {alpha: 1}, fade);
					}
				}

			case 'player3':
				if (!visible)
				{
					for (i in 8...12)
					{
						FlxTween.tween(strumLineNotes.members[i], {alpha: 0}, fade);
					}
				}
				else
				{
					for (i in 8...12)
					{
						FlxTween.tween(strumLineNotes.members[i], {alpha: 1}, fade);
					}
				}
		}
	}

	function doutshit()
	{
		if (ball == null)
		{
			ball = new Balls(battle.x + 940, battle.y + 1560);
			ball.alpha = 0.0001;
			add(ball);
		}
		FlxTween.tween(ball, {alpha: 1}, 0.5);
		FlxTween.tween(boyfriend, {alpha: 0.5}, 0.5);
		utmode = true;
	}

	function dontutshit()
	{
		FlxTween.tween(ball, {alpha: 0}, 0.5);
		FlxTween.tween(boyfriend, {alpha: 1}, 0.5);
		utmode = false;
	}

	function findSlope(x0:Float, y0:Float, x1:Float, y1:Float)
	{
		return (y1 - y0) / (x1 - x0);
	}

	function blastem(killme:Float)
	{
		/*FlxTween.num(songSpeed, 0.95, 0.25, {}, function(v:Float)
			{
				songSpeed = v;
		});*/

		var pointAt:Vector2 = new Vector2(ball.x, ball.y);

		FlxG.sound.play(Paths.sound('readygas', 'sans'));

		var gay:FlxSprite = new FlxSprite(battle.x - 2450, ball.y - 150);
		gay.frames = Paths.getSparrowAtlas("Gaster_blasterss", "sans");
		gay.animation.addByPrefix('boom', 'fefe instance 1', 27, false);
		gay.animation.play('boom');
		gay.antialiasing = FlxG.save.data.highquality;
		gay.flipX = FlxG.random.bool();
		blaster.add(gay);
		gay.alpha = 0.999999;

		gay.height = gay.height * 0.8;

		var homo = 180 / Math.PI * (Math.atan(findSlope(gay.x, gay.y, pointAt.x, pointAt.y)));
		gay.angle = homo;
		gay.y += homo * 2;

		gay.animation.callback = function(boom, frameNumber:Int, frameIndex:Int)
		{
			if (frameNumber == 28)
			{
				gay.alpha = 1;
				/*FlxTween.num(songSpeed, 1, 0.5, {}, function(v:Float)
					{
						songSpeed = v;
				});*/ // nvmmmmmmmmmmmmmmmmmmmmmmmm
				FlxG.sound.play(Paths.sound('shootgas', 'sans'));
				FlxG.camera.shake(0.015, 0.1);
				camHUD.shake(0.005, 0.1);

				chromVal = 0.01;
				FlxTween.tween(this, {chromVal: defaultChromVal}, FlxG.random.float(0.05, 0.12));

				for (i in playerStrums)
				{
					if (i.angle == 0)
					{
						var baseX:Float = i.x;
						var baseY:Float = i.y;
						var baseA:Float = i.angle;
						var randox = if (FlxG.random.bool()) FlxG.random.float(-30, -15); else FlxG.random.float(30, 15);
						var randoy = if (FlxG.random.bool()) FlxG.random.float(-30, -15); else FlxG.random.float(30, 15);
						var randoa = if (FlxG.random.bool()) FlxG.random.float(-45, -15); else FlxG.random.float(45, 15);
						i.x += randox;
						i.y += randoy;
						i.angle += randoa;
						FlxTween.tween(i, {x: baseX, y: baseY, angle: baseA}, 0.4, {
							ease: FlxEase.cubeOut,
							onComplete: function(twn:FlxTween)
							{
								i.x = baseX;
								i.y = baseY;
								i.angle = baseA;
							}
						});
					}
				}
			}
		}
		gay.animation.finishCallback = function(boom)
		{
			gay.kill();
		}
	}

	function sansBar()
	{
		// This is a really buns way to code this, but im sleepy so bleh - BLVKAROT
		FlxTween.tween(strumLineNotes.members[0], {x: ((FlxG.width / 2)) - (strumLineNotes.members[1].width * 2)}, 1, {ease: FlxEase.quadInOut});
		FlxTween.tween(strumLineNotes.members[1], {x: ((FlxG.width / 2)) - (strumLineNotes.members[1].width * 1)}, 1, {ease: FlxEase.quadInOut});
		FlxTween.tween(strumLineNotes.members[2], {x: ((FlxG.width / 2)) + (strumLineNotes.members[1].width * 0)}, 1, {ease: FlxEase.quadInOut});
		FlxTween.tween(strumLineNotes.members[3], {x: ((FlxG.width / 2)) + (strumLineNotes.members[1].width * 1)}, 1, {ease: FlxEase.quadInOut});

		FlxTween.tween(strumLineNotes.members[4], {x: ((FlxG.width - 15)) - (strumLineNotes.members[1].width * 4)}, 1, {ease: FlxEase.quadInOut});
		FlxTween.tween(strumLineNotes.members[5], {x: ((FlxG.width - 15)) - (strumLineNotes.members[1].width * 3)}, 1, {ease: FlxEase.quadInOut});
		FlxTween.tween(strumLineNotes.members[6], {x: ((FlxG.width - 15)) - (strumLineNotes.members[1].width * 2)}, 1, {ease: FlxEase.quadInOut});
		FlxTween.tween(strumLineNotes.members[7], {x: ((FlxG.width - 15)) - (strumLineNotes.members[1].width * 1)}, 1, {ease: FlxEase.quadInOut});

		FlxTween.tween(strumLineNotes.members[8], {x: 15}, 1, {ease: FlxEase.quadInOut});
		FlxTween.tween(strumLineNotes.members[9], {x: 15 + (strumLineNotes.members[1].width * 1)}, 1, {ease: FlxEase.quadInOut});
		FlxTween.tween(strumLineNotes.members[10], {x: 15 + (strumLineNotes.members[1].width * 2)}, 1, {ease: FlxEase.quadInOut});
		FlxTween.tween(strumLineNotes.members[11], {x: 15 + (strumLineNotes.members[1].width * 3)}, 1, {ease: FlxEase.quadInOut});
	}

	function checkCupheadChrom()
	{
		if (!FlxG.save.data.photosensitive && FlxG.save.data.highquality)
		{
			setChrome(0.001);
		}
	}

	function updatesansbars() {
		if (kr > health)
			healthMax.color = 0xFFff00ff;
		if (kr <= health) {
			healthMax.color = 0xFFFFFFFF;
			kr = health;
		}
		if (kr>2)
			kr = 2;
	}

	function showdodgesign() {
		sign.alpha = 1;
		sign.animation.play('play');
		FlxG.sound.play(Paths.sound('fuckyoumoro', 'cup'),0.75);
		sign.animation.finishCallback = function(name:String)
		{
			FlxTween.tween(sign, {alpha: 0}, 0.25, {
				ease: FlxEase.sineInOut});
		}
	}

	function removestuff(ar:Array<Dynamic>) {
		for (i in ar)
		{
			if (i != null)
				remove(i);
			else
				trace('is null');
		}
	}

	function addstuff(ar:Array<Dynamic>) {
		for (i in ar)
		{
			if (i != null)
				add(i);
			else
				trace('is null');
		}
	}
}
