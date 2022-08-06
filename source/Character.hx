package;

import flixel.math.FlxRect;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxTimer;

using StringTools;

class Character extends FlxSprite
{
	public var animOffsets:Map<String, Array<Dynamic>>;
	public var debugMode:Bool = false;

	public var isPlayer:Bool = false;
	public var curCharacter:String = 'bf';
	public var offsetNames:Array<String> = [];

	public var holdTimer:Float = 0;

	public var daZoom:Float = 1;
	public var specialAnimList:Array<String> = [];
	public var notSoSpecialAnimList:Array<String> = ['idle','sing'];//list for animations that are common and can get overridden, aka singing, idle ect 
	/*make sure to push stuff into this BEFORE adding an offset*/

	public var singDuration:Float = 6;

	public var preventDance = false;
	public var preventDanceConstant = false;

	public var idleReplacement:String = '';

	public var constantLooping = false; //only to be used for nightmare run for bendy only

	public var loopedIdle:Bool = false;

	var idletimer:FlxTimer;

	public function new(x:Float, y:Float, ?character:String = "none", ?isPlayer:Bool = false)
	{
		super(x, y);

		animOffsets = new Map<String, Array<Dynamic>>();
		curCharacter = character;
		this.isPlayer = isPlayer;

		antialiasing = FlxG.save.data.highquality;

		switch (curCharacter)
		{

			case 'dad':
				frames = Paths.getSparrowAtlas('characters/DADDY_DEAREST', 'shared', true);
				animation.addByPrefix('idle', 'Dad idle dance', 24, false);
				animation.addByPrefix('singUP', 'Dad Sing Note UP', 24);
				animation.addByPrefix('singRIGHT', 'Dad Sing Note RIGHT', 24);
				animation.addByPrefix('singDOWN', 'Dad Sing Note DOWN', 24);
				animation.addByPrefix('singLEFT', 'Dad Sing Note LEFT', 24);

				addOffset('idle');
				addOffset("singUP", -6, 50);
				addOffset("singRIGHT", 0, 27);
				addOffset("singLEFT", -10, 10);
				addOffset("singDOWN", 0, -30);

				playAnim('idle');

			case 'cupheadNightmare':
				frames = Paths.getSparrowAtlas('characters/Nightmare_Cuphead', 'shared', true);
				animation.addByPrefix('idle', 'Idle instance 1', 24, true);
				animation.addByPrefix('singUP', 'Up instance 1', 24);
				animation.addByPrefix('singRIGHT', 'Right instance 1', 24);
				animation.addByPrefix('singDOWN', 'Down  instance 1', 24);
				animation.addByPrefix('singLEFT', 'Left instance 1', 24);
				animation.addByPrefix('attack1', 'Beamm instance 1', 24);
				animation.addByPrefix('attack2', 'ShootDown instance 1', 24, false);
				animation.addByPrefix('attackEnd', 'Dodgez instance 1', 24);
				animation.addByPrefix('singDOWN-alt', 'ShootDown instance 1', 24);
				animation.addByPrefix('singUP-alt', 'ShootUp instance 1', 24);
				animation.addByPrefix('singRIGHT-alt', 'ShootRight instance 1', 24);
				animation.addByPrefix('singLEFT-alt', 'ShootLeft instance 1', 24);
				animation.addByPrefix('hit', 'Dodgez instance 1', 24, false);

				addOffset('idle', 0, -76);
				addOffset('singUP', 118, 26);
				addOffset('singRIGHT', 29, -125);
				addOffset('singLEFT', 180, -176);
				addOffset('singDOWN', 22, -149);
				addOffset('attack1', -16, -308);
				addOffset('attack2', 52, -148);
				addOffset('attackEnd', 75, -179);
				addOffset('singUP-alt', 109, -94);
				addOffset('singRIGHT-alt', 9, -135);
				addOffset('singLEFT-alt', 121, -196);
				addOffset('singDOWN-alt', 51, -149);
				addOffset('hit', 77, -178);

				scale.x = 1.25;
				scale.y = 1.25;

				loopedIdle = true;

				playAnim('idle');

			case 'saness':
				frames = Paths.getSparrowAtlas('characters/Saness', 'hiddenContent', true);
				animation.addByPrefix('idle', 'Sans instance 1', 24, false);
				animation.addByPrefix('singUP', 'Up instance 1', 24);
				animation.addByPrefix('singRIGHT', 'Right instance 1', 24);
				animation.addByPrefix('singDOWN', 'Down instance 1', 24);
				animation.addByPrefix('singLEFT', 'Left instance 1', 24);

				animation.addByPrefix('aaa', 'AAAAA instance 1', 24);
				animation.addByPrefix('ded', 'Ded instance 1', 24);

				animation.addByPrefix('singDOWN-alt', 'Table sfx instance 1', 24);
				animation.addByPrefix('singUP-alt', 'Up instance 1', 24);
				animation.addByPrefix('singRIGHT-alt', 'Right instance 1', 24);
				animation.addByPrefix('singLEFT-alt', 'Left instance 1', 24);

				addOffset('idle', 0, 0);
				addOffset('singUP', -10, 90);
				addOffset('singRIGHT', -30, -20);
				addOffset('singLEFT', 60, -40);
				addOffset('singDOWN', 30, 10);
				addOffset('aaa', 20, 60);
				addOffset('ded', -20, 10);

				addOffset('singDOWN-alt', 20, -30);
				addOffset('singUP-alt', -10, 90);
				addOffset('singRIGHT-alt', -30, -20);
				addOffset('singLEFT-alt', 60, -40);

				playAnim('idle');

				setZoom(1.5);

			case 'gose':
				frames = Paths.getSparrowAtlas('goose', 'hiddenContent', true);

				animation.addByPrefix('idle', 'Goose Idle0', 24, false);
				animation.addByPrefix('idle-alt', 'Gose Idle Dank', 24, false);
				animation.addByPrefix('singUP', 'Goose Up', 24);
				animation.addByPrefix('singRIGHT', 'Goose Right', 24);
				animation.addByPrefix('singDOWN', 'Goose Down', 24);
				animation.addByPrefix('singLEFT', 'Goose Left', 24);
				animation.addByPrefix('singUP-alt', 'Gose Up Dank', 24);
				animation.addByPrefix('singRIGHT-alt', 'Gose Right Dank', 24);
				animation.addByPrefix('singDOWN-alt', 'Gose Down Dank', 24);
				animation.addByPrefix('singLEFT-alt', 'Gose Left Dank', 24);
				animation.addByPrefix('mlg', 'Goose MLG Anim', 24, false);

				addOffset('idle');
				addOffset('idle-alt', 30, 0);
				addOffset("singUP", -16, 170);
				addOffset("singRIGHT", -10, -3);
				addOffset("singLEFT", 170, 50);
				addOffset("singDOWN", -10, -30);
				addOffset("singUP-alt", 24, 170);
				addOffset("singRIGHT-alt", -40, 7);
				addOffset("singLEFT-alt", 130, 50);
				addOffset("singDOWN-alt", -10, -30);
				addOffset('mlg', 27, 162);

				playAnim('idle');

			case 'sammy':
				frames = Paths.getSparrowAtlas('characters/SammyRemastered', 'shared', true);
				animation.addByPrefix('idle', 'Sammy Idle instance 1', 24, false);
				animation.addByPrefix('singUP', 'Up instance 1', 24);
				animation.addByPrefix('singRIGHT', 'Right instance 1', 24);
				animation.addByPrefix('singDOWN', 'down instance 1', 24);
				animation.addByPrefix('singLEFT', 'Left instance 1', 24);
				animation.addByPrefix('Intro', 'Intro instance 1', 27, false);
				moroAnim('End1', 'End Part01');
				moroAnim('End2', 'End02');

				addOffset('idle', -156, -130);
				addOffset('singUP', 113, -76);
				addOffset('singRIGHT', -1, -270);
				addOffset('singLEFT', 400, -161);
				addOffset('singDOWN', -7, -297);

				//addOffset('Attack', -156, -130);
				addOffset('Intro', 720, 34);
				addOffset('End1', -30, -236);
				addOffset('End2', 31, -100);

				playAnim('idle');

				setGraphicSize(Std.int(frameWidth * 1.75));
				updateHitbox();
			case 'bendy':
				frames = Paths.getSparrowAtlas('characters/Bendy_remastered', 'shared', true);
				animation.addByPrefix('idle', 'Bendy Idle instance 1', 24, false);
				animation.addByPrefix('singUP', 'Up instance 1', 24, false);
				animation.addByPrefix('singRIGHT', 'B-Right instance 1', 24, false);
				animation.addByPrefix('singDOWN', 'bendydown instance 1', 24, false);
				animation.addByPrefix('singLEFT', 'Left instance 1', 24, false);

				animation.addByPrefix('roar', 'Scream instance 1', 24, false);

				addOffset('idle', 0, 0);
				addOffset('singUP', 130, 101);
				addOffset('singRIGHT', 68, -16);
				addOffset('singLEFT', 242, 12);
				addOffset('singDOWN', 69, -33);
				addOffset('roar', 60, 6);

				playAnim('idle');

				setZoom(2.4);
			case 'bendyNightmare':
				frames = Paths.getSparrowAtlas('characters/NMB', 'shared', true);
				animation.addByPrefix('idle', 'DeathBendy instance 1', 25, true);
				animation.addByPrefix('singUP', 'Up instance 1', 25, false);
				animation.addByPrefix('singRIGHT', 'FUCK YOU instance 1', 25, false);
				animation.addByPrefix('singDOWN', 'Down instance 1', 25, false);
				animation.addByPrefix('singLEFT', 'Left instance 1', 25, false);
				animation.addByPrefix('ink', 'bye bitch instance 1', 25, false);
				animation.addByPrefix('fall', 'Intro instance 1', 25, false);

				addOffset('idle', 0, 0);
				addOffset('singUP', 30, 140);
				addOffset('singRIGHT', -37, 30);
				addOffset('singLEFT', 136, 8);
				addOffset('singDOWN', -43, -156);
				addOffset('ink', 167, -48);
				addOffset('fall', -130, 1100);

				playAnim('idle');

				setZoom(3);

			case 'bendyChase':
				frames = Paths.getSparrowAtlas('characters/Bendy_run_Remastered', 'shared', true);
				animation.addByPrefix('idle', 'Bendy Run instance 1', 24, true);
				animation.addByPrefix('singUP', 'Upp instance 1', 24, true);
				animation.addByPrefix('singRIGHT', 'Right instance 1', 24, true);
				animation.addByPrefix('singDOWN', 'Dowwn instance 1', 24, true);
				animation.addByPrefix('singLEFT', 'Leftr instance 1', 24, true);

				addOffset('idle', -150, 20);
				addOffset("singUP", -160, 105);
				addOffset("singRIGHT", -150, 10);
				addOffset("singLEFT", -90, 90);
				addOffset("singDOWN", -160, -30);

				loopedIdle = true;

				playAnim('idle');

				setZoom(2.5);
				constantLooping = true;
				
			case 'bendyChaseDark':
				frames = Paths.getSparrowAtlas('characters/dark/Bendy_run_Remastered', 'shared', true);
				animation.addByPrefix('idle', 'Bendy Run instance 1', 24, true);
				animation.addByPrefix('singUP', 'Upp instance 1', 24, true);
				animation.addByPrefix('singRIGHT', 'Right instance 1', 24, true);
				animation.addByPrefix('singDOWN', 'Dowwn instance 1', 24, true);
				animation.addByPrefix('singLEFT', 'Leftr instance 1', 24, true);

				addOffset('idle', -150, 20);
				addOffset("singUP", -160, 105);
				addOffset("singRIGHT", -150, 10);
				addOffset("singLEFT", -90, 90);
				addOffset("singDOWN", -160, -30);

				loopedIdle = true;

				playAnim('idle');

				setZoom(2.5);
				constantLooping = true;

			case 'bfChase':
				frames = Paths.getSparrowAtlas('characters/NM_run_BF', 'shared', true);
				animation.addByPrefix('idle', 'Run_cycle instance 1', 24);
				animation.addByPrefix('idle2', 'Run_When Bendy is Close instance 1', 24);
				animation.addByPrefix('singUP', 'Up instance 1', 24);
				animation.addByPrefix('singLEFT', 'Leftt instance 1', 24);
				animation.addByPrefix('singRIGHT', 'Rightt instance 1', 24);
				animation.addByPrefix('singDOWN', 'Down instance 1', 24);
				animation.addByPrefix('singUPmiss', 'Up Miss instance 1', 24, false);
				animation.addByPrefix('singLEFTmiss', 'Left Miss instance 1', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'Right Miss instance 1', 24, false);
				animation.addByPrefix('singDOWNmiss', 'Down Miss instance 1', 24, false);

				addOffset('idle', -5, 0);
				addOffset('singUP', -2, 0);
				addOffset('singRIGHT', -6, -5);
				addOffset('singLEFT', 5, -6);
				addOffset('singDOWN', 4, -2);
				addOffset('singUPmiss', -7, -15);
				addOffset('singRIGHTmiss', 7, -18);
				addOffset('singLEFTmiss', -5, -19);
				addOffset('singDOWNmiss', 3, -19);

				playAnim('idle');

				setZoom(1.4);
				
				x -= 50;

				flipX = true;
				constantLooping = true;

			case 'bfChaseDark':
				frames = Paths.getSparrowAtlas('characters/dark/NM-run-BF-Dark', 'shared', true);
				animation.addByPrefix('idle', 'Run_cycle instance 1', 24);
				animation.addByPrefix('idle2', 'Run_When Bendy is Close instance 1', 24);
				animation.addByPrefix('singUP', 'Up instance 1', 24);
				animation.addByPrefix('singLEFT', 'Leftt instance 1', 24);
				animation.addByPrefix('singRIGHT', 'Rightt instance 1', 24);
				animation.addByPrefix('singDOWN', 'Down instance 1', 24);
				animation.addByPrefix('singUPmiss', 'Up Miss instance 1', 24);
				animation.addByPrefix('singLEFTmiss', 'Left Miss instance 1', 24);
				animation.addByPrefix('singRIGHTmiss', 'Right Miss instance 1', 24);
				animation.addByPrefix('singDOWNmiss', 'Down Miss instance 1', 24);

				addOffset('idle', -5, 0);
				addOffset('singUP', 1, -2);
				addOffset('singRIGHT', -10, -10);
				addOffset('singLEFT', 5, -6);
				addOffset('singDOWN', 10, 0);
				addOffset('singUPmiss', -11, -19);
				addOffset('singRIGHTmiss', -11, -19);
				addOffset('singLEFTmiss', -11, -19);
				addOffset('singDOWNmiss', -11, -19);

				setZoom(1.4);

				x -= 50;

				playAnim('idle');

				flipX = true;
				constantLooping = true;

			case 'cuphead':
				frames = Paths.getSparrowAtlas('characters/Cuphead_Remastered', 'shared', true);
				animation.addByPrefix('idle', 'Cuphead_standing instance 1', 24, true);
				animation.addByPrefix('singUP', 'Up instance 1', 24);
				animation.addByPrefix('singRIGHT', 'Right instance 1', 24);
				animation.addByPrefix('singDOWN', 'Down instance 1', 24);
				animation.addByPrefix('singLEFT', 'Left instance 1', 24);

				animation.addByPrefix('intro', 'Cuphead Intro phase 2 instance 1', false);
				animation.addByPrefix('attack1', 'Shoot instance 1', 24, true);
				animation.addByPrefix('dodge', 'Dodge instance 1', 24, false);
				animation.addByPrefix('hit', 'Hurt instance 1', 24, false);

				notSoSpecialAnimList.push('attack1');

				addOffset('idle', 0, 0);
				addOffset('singUP', -12, 51);
				addOffset('singRIGHT', -20, -10);
				addOffset('singLEFT', 40, -8);
				addOffset('singDOWN', -24, -16);
				addOffset('intro', 49, 2);
				addOffset('attack1', 2, -3);
				addOffset('dodge', 32, -9);
				addOffset('hit', 120, 63);

				setZoom(1.74);

				playAnim('idle');

			case 'angrycuphead':
				frames = Paths.getSparrowAtlas('characters/Cuphead Pissed', 'shared', true);
				animation.addByPrefix('idle', '1 instance 1', 24, true);
				animation.addByPrefix('singUP', 'Up instance 1', 24, false);
				animation.addByPrefix('singRIGHT', 'Right instance 1', 24, false);
				animation.addByPrefix('singDOWN', 'Down instance 1', 24, false);
				animation.addByPrefix('singLEFT', 'Left instance 1', 24, false);

				animation.addByPrefix('attack1', 'DIE BITCH instance 1', 24, true);
				animation.addByPrefix('attack2', 'Hadoken!! instance 1', 24, false);
				animation.addByPrefix('hit', 'Ouch instance 1', 24, false);
				animation.addByPrefix('roundAttack', 'Roundattack instance 1', 24, false);
				animation.addByPrefix('pewUP', 'PewUp instance 1', 24, false);
				animation.addByPrefix('pewDOWN', 'pewdown instance 1', 24, false);
				animation.addByPrefix('pewLEFT', 'Pewleft instance 1', 24, false);
				animation.addByPrefix('pewRIGHT', 'PewRight instance 1', 24, false);
				animation.addByIndices('regret', 'Phase 2 starts instance 1', [0], "", 24, false);

				notSoSpecialAnimList.push('attack1');
				notSoSpecialAnimList.push('pew');
				notSoSpecialAnimList.push('regret');

				addOffset('idle');
				addOffset("singUP", 35, 125);
				addOffset("singRIGHT", -30, 30);
				addOffset("singLEFT", 120, -10);
				addOffset("singDOWN", -31, -40);

				addOffset('attack1', 0, -13);
				addOffset('attack2', 350, 270);
				addOffset('hit', 110, -20);
				addOffset('roundAttack', 21, 0);
				addOffset('pewUP', 50, 80);
				addOffset('pewDOWN', -30, -35);
				addOffset('pewLEFT', 112, -38);
				addOffset('pewRIGHT', -29, 26);
				addOffset('regret', -30, -35);

				loopedIdle = true;
				
				scale.set(1.7, 1.7);
				playAnim('idle');

			case 'sans':
				frames = Paths.getSparrowAtlas('characters/Sans', 'shared', true);
				animation.addByIndices('idleLeft', 'Sans FNF instance 1', [28, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "", 24, false);
				animation.addByIndices('idleRight', 'Sans FNF instance 1', [13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27], "", 24, false);
				animation.addByPrefix('singUP', 'Up instance 1', 24, false);
				animation.addByPrefix('singRIGHT', 'Right instance 1', 24, false);
				animation.addByPrefix('singDOWN', 'Down instance 1', 24, false);
				animation.addByPrefix('singLEFT', 'Left instance 1', 24, false);
				animation.addByPrefix('singUP-alt', 'Up 02 instance 1', 24, false);
				animation.addByPrefix('singRIGHT-alt', 'Right 02 instance 1', 24, false);
				animation.addByPrefix('singDOWN-alt', 'Down 02 instance 1', 24, false);
				animation.addByPrefix('singLEFT-alt', 'Left 02 instance 1', 24, false);
				animation.addByPrefix('miss', 'SansDodge instance 1', 24, false);
				animation.addByPrefix('snap', 'Switch to UT mode instance 1', 24, false);

				addOffset('idleLeft');
				addOffset('idleRight');
				addOffset("singUP", -16, 28);
				addOffset("singRIGHT", -18, -1);
				addOffset("singLEFT", 48, 1);
				addOffset("singDOWN", -12, -15);
				addOffset("singUP-alt", 36, 28);
				addOffset("singRIGHT-alt", -17, -1);
				addOffset("singLEFT-alt", 46, 1);
				addOffset("singDOWN-alt", -11, -15);
				addOffset("miss", 76, 35);
				addOffset('snap', 20, 0);

				playAnim('idleRight');
			/*
				case 'saness':
					frames = 
					playAnim('idle');
			 */

			case 'sansScared':
				frames = Paths.getSparrowAtlas('characters/Sans_Phase_3', 'shared', true);
				animation.addByIndices('idleLeft', 'Sans FNF instance 1', [28, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "", 24, false);
				animation.addByIndices('idleRight', 'Sans FNF instance 1', [13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27], "", 24, false);
				animation.addByPrefix('singUP', 'Up instance 1', 24, false);
				animation.addByPrefix('singRIGHT', 'Right instance 1', 24, false);
				animation.addByPrefix('singDOWN', 'Down instance 1', 24, false);
				animation.addByPrefix('singLEFT', 'Left instance 1', 24, false);
				animation.addByPrefix('miss', 'SansDodge instance 1', 24, false);

				animation.addByPrefix('idle-alt', 'Sans FNF Tired instance 1', 24, false);
				animation.addByPrefix('singUP-alt', 'Up Tired instance 1', 24, false);
				animation.addByPrefix('singRIGHT-alt', 'Right Tired instance 1', 24, false);
				animation.addByPrefix('singDOWN-alt', 'Down Tired instance 1', 24, false);
				animation.addByPrefix('singLEFT-alt', 'Left Tired instance 1', 24, false);
				animation.addByPrefix('miss-alt', 'SansDodgeTired instance 1', 24, false);
				
				animation.addByPrefix('idleLeft-alt', 'Sans FNF Tired instance 1', 24, false);
				animation.addByPrefix('idleRight-alt', 'Sans FNF Tired instance 1', 24, false);

				animation.addByPrefix('snap', 'Snap to UT mode instance 1', 24, false);


				addOffset('idleLeft');
				addOffset('idleRight');
				addOffset("singUP", -17, 28);
				addOffset("singRIGHT", -19, 1);
				addOffset("singLEFT", 47, 1);
				addOffset("singDOWN", -13, -15);
				addOffset("miss", 100, 22);

				addOffset('idle-alt', -14, 0);
				addOffset("singUP-alt", 37, 30);
				addOffset("singRIGHT-alt", -18, 0);
				addOffset("singLEFT-alt", 48, 1);
				addOffset("singDOWN-alt", -13, -14);
				addOffset("miss-alt", 76, 35);

				addOffset('idleLeft-alt', -14, 0);
				addOffset('idleRight-alt', -14, 0);
				addOffset('snap', 20, 0);

				playAnim('idleRight');

			case 'sanswaterfall':
				frames = Paths.getSparrowAtlas('characters/SansWF', 'shared', true);
				animation.addByPrefix('idle', 'Sans FNF Tired instance 1', 24, false);
				animation.addByPrefix('singUP', 'Up Tired instance 1', 24, false);
				animation.addByPrefix('singRIGHT', 'Right Tired instance 1', 24, false);
				animation.addByPrefix('singDOWN', 'Down Tired instance 1', 24, false);
				animation.addByPrefix('singLEFT', 'Left Tired instance 1', 24, false);

				addOffset('idle', 0, 1);
				addOffset("singUP", 50, 29);
				addOffset("singRIGHT", -2, 0);
				addOffset("singLEFT", 62, 2);
				addOffset("singDOWN", 4, -12);

				playAnim('idle');
				//setZoom(1.75);
			/*
				case 'saness':
					frames = 
					playAnim('idle');
				*/

			case 'papyrus':
				frames = Paths.getSparrowAtlas('characters/Papyrus', 'shared', true);

				animation.addByPrefix('bruh', 'Bruh instance 1', 24, false);
				animation.addByPrefix('singUP-alt', 'ISTG instance 1', 24);
				animation.addByPrefix('ohyoumotherfucker', 'Oh Sans you Mother fuc- instance 1', 24, false);
				animation.addByPrefix('singLEFT-alt', 'SANS WAKE UP BITCH instance 1', 24, false);
				animation.addByPrefix('letsgo', 'Sans lessgo instance 1', 24, false);
				animation.addByPrefix('maboi', "That's ma boi instance 1", 24, true);
				animation.addByPrefix('gzezy', "gzezy instance 1", 24, false);
				animation.addByPrefix('idle-alt', "gzezy instance 1", 24, false);
				animation.addByPrefix('singDOWN-alt', "jghrue instance 1", 24, false);
				animation.addByPrefix('singRIGHT-alt', "upahgn instance 1", 24, false);

				animation.addByPrefix('idle', 'Idle instance 1', 24, false);
				animation.addByPrefix('singUP', 'Up instance 1', 24, false);
				animation.addByPrefix('singRIGHT', 'Right copy instance 1', 24, false);
				animation.addByPrefix('singDOWN', 'fzt instance 1', 24, false);
				animation.addByPrefix('singLEFT', 'left instance 1', 24, false);

				addOffset('bruh', -4, -25);
				addOffset('singUP-alt', 97, 69);
				addOffset('ohyoumotherfucker', 7, 52);
				addOffset('singLEFT-alt', 160, -71);
				addOffset('letsgo', 40, 30);
				addOffset('maboi', 34, -1);
				addOffset('gzezy', 60, -25);
				addOffset('idle-alt', 59, -25);
				addOffset('singDOWN-alt', 157, 7);
				addOffset('singRIGHT-alt', 70, 20);

				addOffset('idle');
				addOffset("singUP", -1, 84);
				addOffset("singRIGHT", 114, -39);
				addOffset("singLEFT", 89, 5);
				addOffset("singDOWN", 81, -80);

				playAnim('idle');

				setZoom(1.45);

			case 'sanswinter':
				frames = Paths.getSparrowAtlas('characters/Sans_Brrrr', 'shared', true);

				animation.addByPrefix('wakeup', '03 instance 1', 24, false);
				animation.addByPrefix('fallasleep', '01 instance 1', 24, false);
				animation.addByPrefix('sleep', '02 instance 1', 24);
				animation.addByPrefix('letsgo', '1:22 instance 1', 24, false);

				animation.addByPrefix('takeout', 'Taste my Lightsaber instance 1', 24, false);
				animation.addByPrefix('putin', 'Sans puts back his shit instance 1', 24, false);

				animation.addByPrefix('idle', 'Sans FNF instance 1', 24);
				animation.addByPrefix('singUP', 'Upo instance 1', 24, false);
				animation.addByPrefix('singRIGHT', 'S-Right instance 1', 24, false);
				animation.addByPrefix('singDOWN', 'Donw instance 1', 24, false);
				animation.addByPrefix('singLEFT', 'Lefft instance 1', 24, false);

				animation.addByPrefix('idle-alt', 'SansboneIdle instance 1', 24, false);
				animation.addByPrefix('singLEFT-alt', 'Right instance 1', 24);
				animation.addByPrefix('singRIGHT-alt', 'Left instance 1', 24, false);
				animation.addByPrefix('singUP-alt', 'Left instance 1', 24, false);
				animation.addByPrefix('singDOWN-alt', 'Right instance 1', 24, false);

				addOffset('idle', 0, 0);
				addOffset('singUP', -10, 20);
				addOffset('singRIGHT', -20, 5);
				addOffset('singLEFT', 44, -5);
				addOffset('singDOWN', 5, -2);
				addOffset('idle-alt', 68, 0);
				addOffset('singUP-alt', 160, 51);
				addOffset('singLEFT-alt', 77, 93);
				addOffset('singRIGHT-alt', 157, 51);
				addOffset('singDOWN-alt', 77, 94);
				addOffset('wakeup', 30, 10);
				addOffset('fallasleep', 32, 2);
				addOffset('sleep', 10, -150);
				addOffset('letsgo', -16, 32);
				addOffset('takeout', 39, 87);
				addOffset('putin', 39, 88);

			case 'sansNightmare':
				frames = Paths.getSparrowAtlas('characters/DeathSans002', 'shared', true);
				animation.addByPrefix('idle', 'Nightmare SANS Idle instance 1', 24, true);
				animation.addByPrefix('singUP', 'UPP instance 1', 24);
				animation.addByPrefix('singRIGHT', 'Rightt instance 1', 24);
				animation.addByPrefix('singDOWN', 'DOWNN instance 1', 24);
				animation.addByPrefix('singLEFT', 'Leftt instance 1', 24);

				addOffset('idle');
				addOffset("singUP", -85, 61);
				addOffset("singRIGHT", 60, -93);
				addOffset("singLEFT", 109, -85);
				addOffset("singDOWN", 2, 10);

				loopedIdle = true;

				playAnim('idle');

			case 'sansbattle':
				frames = Paths.getSparrowAtlas('characters/Sans_but_Rip_colors', 'shared', true);
				animation.addByIndices('idleLeft', 'EReree ee instance 1', [24, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "", 24, false);
				animation.addByIndices('idleRight', 'EReree ee instance 1', [13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23], "", 24, false);
				animation.addByPrefix('singUP', 'UpUT instance 1', 24, false);
				animation.addByPrefix('singRIGHT', 'RightUT instance 1', 24, false);
				animation.addByPrefix('singDOWN', 'DownUT instance 1', 24, false);
				animation.addByPrefix('singLEFT', 'LeftUT instance 1', 24, false);
				animation.addByPrefix('miss', 'Sike instance 1', 24, false);

				addOffset('idleLeft');
				addOffset('idleRight');
				addOffset("singUP", 13, 28);
				addOffset("singRIGHT", 13, -1);
				addOffset("singLEFT", 59, 1);
				addOffset("singDOWN", 15, 0);
				addOffset('miss', 0, 0);

				playAnim('idleLeft');
			
			case 'bfSammy':
				frames = Paths.getSparrowAtlas('characters/BoyFriend_Sammy', 'shared', true);
				moroAnim('idle', 'BF idle dance', false);
				moroAnim('singUPA', 'BF NOTE UP', false);
				moroAnim('singDOWNA', 'BF NOTE DOWN', false);
				moroAnim('singLEFTA', 'BF NOTE LEFT', false);
				moroAnim('singRIGHTA', 'BF NOTE RIGHT', false);

				moroAnim('singUPmiss', 'U-Miss', false);
				moroAnim('singDOWNmiss', 'D-Miss', false);
				moroAnim('singLEFTmiss', 'L-Miss', false);
				moroAnim('singRIGHTmiss', 'R-Miss', false);

				moroAnim('dodge', 'Dodge', false);
				moroAnim('damage', 'Ouch', false);

				addOffset('idle', -5, 0);
				addOffset('singUPA', -53, 58);
				addOffset('singRIGHTA', -37, 3);
				addOffset('singLEFTA', 25, -2);
				addOffset('singDOWNA', -38, -32);
				addOffset('singUPmiss', -57, 112);
				addOffset('singRIGHTmiss', 7, 21);
				addOffset('singLEFTmiss', -33, 25);
				addOffset('singDOWNmiss', -50, -22);
				addOffset('dodge', -9, 15);
				addOffset('damage', -10, 148);

				playAnim('idle');

				flipX = true;

			case 'bf':
				frames = Paths.getSparrowAtlas('characters/BOYFRIEND', 'shared', true);
				animation.addByPrefix('idle', '0Idle', 24, false);
				animation.addByPrefix('singUP', '0UPPP', 24, false);
				animation.addByPrefix('singLEFT', '0EERR', 24, false);
				animation.addByPrefix('singRIGHT', '0EEEE', 24, false);
				animation.addByPrefix('singDOWN', '0Ouu', 24, false);
				animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
				animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
				animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);
				animation.addByPrefix('attack', '0BF attack', 24, false);

				animation.addByPrefix('firstDeath', "BF dies", 24, false);
				animation.addByPrefix('deathLoop', "BF Dead Loop", 24, false);
				animation.addByPrefix('deathConfirm', "BF Dead confirm", 24, false);

				animation.addByPrefix('dodge', '0Dodge', 24, false);
				animation.addByPrefix('dodge2', '0Dodge02', 24, false);

				addOffset('idle', -5, 0);
				addOffset('singUP', -46, 36);
				addOffset('singRIGHT', -37, -7);
				addOffset('singLEFT', 0, -10);
				addOffset('singDOWN', -13, -57);
				addOffset('singUPmiss', -53, 24);
				addOffset('singRIGHTmiss', -53, 15);
				addOffset('singLEFTmiss', -10, 13);
				addOffset('singDOWNmiss', -25, -25);
				addOffset('attack', 944, -15);
				addOffset('firstDeath', 11, 4);
				addOffset('deathLoop', 11, -2);
				addOffset('deathConfirm', 11, 61);
				addOffset('dodge', 54, -15);
				addOffset('dodge2', -9, -18);

				playAnim('idle');

				flipX = true;

			case 'bfswag':
				frames = Paths.getSparrowAtlas('characters/BoyFriend_Cuphead', 'shared', true);
				animation.addByPrefix('idle', 'BF idle dance instance 1', 24, false);
				animation.addByPrefix('singUP', 'BF NOTE UP instance 1', 24, false);
				animation.addByPrefix('singLEFT', 'BF NOTE LEFT instance 1', 24, false);
				animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT instance 1', 24, false);
				animation.addByPrefix('singDOWN', 'BF NOTE DOWN instance 1', 24, false);
				animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS instance 1', 24, false);
				animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS instance 1', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS instance 1', 24, false);
				animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS instance 1', 24, false);
				animation.addByPrefix('attack', '0BF attack instance 1', 24, false);
				animation.addByPrefix('hurt', 'BF hit instance 1', 24, false);
				animation.addByPrefix('dodge', 'boyfriend dodge instance 1', 24, false);

				addOffset('idle', -4, 2);
				addOffset("singUP", -51, 55);
				addOffset("singRIGHT", -38, 1);
				addOffset("singLEFT", 24, 3);
				addOffset("singDOWN", -32, -35);
				addOffset("singUPmiss", -60, 17);
				addOffset("singRIGHTmiss", -60, 24);
				addOffset("singLEFTmiss", -27, 19);
				addOffset("singDOWNmiss", -37, -17);
				addOffset("attack", 1083, -7);
				addOffset("hurt", 42, 53);
				addOffset("dodge", -20, -7);

				playAnim('idle');

				flipX = true;

			case 'bfda':
				frames = Paths.getSparrowAtlas('characters/BoyFriend_DA', 'shared', true);
				animation.addByPrefix('idle', 'BF idle dance instance 1', 24, false);
				animation.addByPrefix('singUP', 'BF NOTE UP instance 1', 24, false);
				animation.addByPrefix('singLEFT', 'BF NOTE LEFT instance 1', 24, false);
				animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT instance 1', 24, false);
				animation.addByPrefix('singDOWN', 'BF NOTE DOWN instance 1', 24, false);
				animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS instance 1', 24, false);
				animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS instance 1', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS instance 1', 24, false);
				animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS instance 1', 24, false);
				animation.addByPrefix('attack', '0BF attack instance 1', 24, false);
				animation.addByPrefix('hurt', 'BF hit instance 1', 24, false);
				animation.addByPrefix('dodge', 'boyfriend dodge instance 1', 24, false);

				addOffset('idle', -4, 2);
				addOffset("singUP", -51, 55);
				addOffset("singRIGHT", -38, 1);
				addOffset("singLEFT", 24, 3);
				addOffset("singDOWN", -32, -35);
				addOffset("singUPmiss", -60, 17);
				addOffset("singRIGHTmiss", -60, 24);
				addOffset("singLEFTmiss", -27, 19);
				addOffset("singDOWNmiss", -37, -17);
				addOffset("attack", 1083, -7);
				addOffset("hurt", 42, 53);
				addOffset("dodge", -20, -7);

				playAnim('idle');

				flipX = true;

			case 'rainbf':
				frames = Paths.getSparrowAtlas('characters/BoyFriend_Rain', 'shared', true);
				animation.addByPrefix('idle', 'BF idle dance instance 1', 24, false);
				animation.addByPrefix('singUP', 'BF NOTE UP instance 1', 24, false);
				animation.addByPrefix('singLEFT', 'BF NOTE RIGHT instance 1', 24, false);
				animation.addByPrefix('singRIGHT', 'BF NOTE LEFT instance 1', 24, false);
				animation.addByPrefix('singDOWN', 'BF NOTE DOWN instance 1', 24, false);
				animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS instance 1', 24, false);
				animation.addByPrefix('singLEFTmiss', 'BF NOTE RIGHT MISS instance 1', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'BF NOTE LEFT MISS instance 1', 24, false);
				animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS instance 1', 24, false);
				animation.addByPrefix('attack', '0BF attack instance 1', 24, false);
				animation.addByPrefix('hurt', 'BF hit instance 1', 24, false);
				animation.addByPrefix('dodge', 'boyfriend dodge instance 1', 24, false);

				addOffset('idle', -5, 0);
				addOffset('singUP', -51, 57);
				addOffset("singRIGHT", -48, 4);
				addOffset("singLEFT", 32, 3);
				addOffset('singDOWN', -20, -40);
				addOffset('singUPmiss', -49, 17);
				addOffset('singRIGHTmiss', -29, 25);
				addOffset('singLEFTmiss', -58, 24);
				addOffset('singDOWNmiss', -31, -19);
				addOffset('attack', 1095, -12);
				addOffset('hurt', 40, 50);
				addOffset('dodge', -20, -10);

				playAnim('idle');

				flipX = true;

			case 'bfnightmareCup':
				frames = Paths.getSparrowAtlas('characters/BoyFriend_NM', 'shared', true);
				animation.addByPrefix('idle', 'BF idle dance instance 1', 24, false);
				animation.addByPrefix('singUP', 'BF NOTE UP instance 1', 24, false);
				animation.addByPrefix('singLEFT', 'BF NOTE LEFT instance 1', 24, false);
				animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT instance 1', 24, false);
				animation.addByPrefix('singDOWN', 'BF NOTE DOWN instance 1', 24, false);
				animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS instance 1', 24, false);
				animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS instance 1', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS instance 1', 24, false);
				animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS instance 1', 24, false);
				animation.addByPrefix('attack', '0BF attack instance 1', 24, false);
				animation.addByPrefix('hurt', 'BF hit instance 1', 24, false);
				animation.addByPrefix('dodge', 'boyfriend dodge instance 1', 24, false);

				addOffset('idle', -5);
				addOffset("singUP", -51, 57);
				addOffset("singRIGHT", -48, 4);
				addOffset("singLEFT", 32, 3);
				addOffset("singDOWN", -20, -40);
				addOffset("singUPmiss", -59, 7);
				addOffset("singRIGHTmiss", -60, 22);
				addOffset("singLEFTmiss", -28, 24);
				addOffset("singDOWNmiss", -31, -19);
				addOffset("attack", 1095, -16);
				addOffset("hurt", 40, 50);
				addOffset("dodge", -20, -20);

				playAnim('idle');

				flipX = true;

			case 'bf-bendo':
				frames = Paths.getSparrowAtlas('characters/BoyFriend_BendyShade', 'shared', true);

				animation.addByPrefix('idle', 'BF idle dance instance 1', 24, false);
				animation.addByPrefix('idleA', 'BFA idle dance  instance 1', 24, false);
				animation.addByPrefix('idleS', 'BFS idle  instance 1', 24, false);

				animation.addByPrefix('singUP', 'BF NOTE UP instance 1', 24, false);
				animation.addByPrefix('singLEFT', 'BF NOTE LEFT instance 1', 24, false);
				animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT instance 1', 24, false);
				animation.addByPrefix('singDOWN', 'BF NOTE DOWN instance ', 24, false);

				animation.addByPrefix('singUPA', 'BFA NOTE UP  instance 1', 24, false);
				animation.addByPrefix('singLEFTA', 'BFA NOTE LEFT  instance 1', 24, false);
				animation.addByPrefix('singRIGHTA', 'BFA NOTE RIGHT  instance 1', 24, false);
				animation.addByPrefix('singDOWNA', 'BFA NOTE DOWN  instance 1', 24, false);

				animation.addByPrefix('singUPS', 'BFS NOTE UP instance 1', 24, false);
				animation.addByPrefix('singLEFTS', 'BFS NOTE LEFT instance 1', 24, false);
				animation.addByPrefix('singRIGHTS', 'BFS NOTE RIGHT instance 1', 24, false);
				animation.addByPrefix('singDOWNS', 'BFS NOTE DOWN instance 1', 24, false);

				animation.addByPrefix('singUPmiss', 'U-Miss', 24, false);
				animation.addByPrefix('singLEFTmiss', 'R-Miss', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'L-Miss', 24, false);
				animation.addByPrefix('singDOWNmiss', 'D-Miss', 24, false);

				animation.addByPrefix('ouch', 'Ouch instance 1', 24, false);

				addOffset('idle', 0, 0);
				addOffset('idleA', 0, 0);
				addOffset('idleS', 0, 0);

				addOffset('singUP', -50, 60);
				addOffset('singRIGHT', -30, 10);
				addOffset('singLEFT', 30, 0);
				addOffset('singDOWN', -20, -30);

				addOffset('singUPA', -50, 60);
				addOffset('singRIGHTA', -30, 0);
				addOffset('singLEFTA', 24, 0);
				addOffset('singDOWNA', -23, -30);

				addOffset('singUPS', -60, 60);
				addOffset('singRIGHTS', -30, 0);
				addOffset('singLEFTS', 25, -1);
				addOffset('singDOWNS', -30, -30);

				addOffset('singUPmiss', -60, 110);
				addOffset('singRIGHTmiss', -20, 20);
				addOffset('singLEFTmiss', 17, 23);
				addOffset('singDOWNmiss', -33, -19);

				addOffset('ouch', 0, 150);

				playAnim('idle');

				flipX = true;

			case 'bfFUCKINWHATTHEFUCKBITCH':
				frames = Paths.getSparrowAtlas('characters/BoyFriend_3rdPhase', 'shared', true);
				animation.addByPrefix('idle', 'BF idle dance copy 2 instance', 24, true);
				animation.addByPrefix('singUP', 'BF NOTE UP copy 2 instance', 24, false);
				animation.addByPrefix('singLEFT', 'BF NOTE LEFT copy 2 instance', 24, false);
				animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT copy 2 instance', 24, false);
				animation.addByPrefix('singDOWN', 'BF NOTE DOWN copy 2 instance', 24, false);
				animation.addByPrefix('singUPmiss', 'BF NOTE UP copy 2 instance', 24, false);
				animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT copy 2 instance', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT copy 2 instance', 24, false);
				animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN copy 2 instance', 24, false);
				animation.addByPrefix('attackLeft', "Attack instance 1", 28, false);
				animation.addByPrefix('attackRight', "Attack instance 2", 28, false);
				animation.addByPrefix('dodge', 'Dodge instance', 24, false);
				animation.addByPrefix('ouchy', 'Ouch instance', 24, false);

				addOffset('idle', -5, 0);
				addOffset('singUP', -30, 54);
				addOffset('singRIGHT', -19, 0);
				addOffset('singLEFT', 44, -4);
				addOffset('singDOWN', -20, -34);
				addOffset('singUPmiss', -30, 54);
				addOffset('singRIGHTmiss', -19, 0);
				addOffset('singLEFTmiss', 44, -4);
				addOffset('singDOWNmiss', -20, -34);
				addOffset('attackRight', -40, 154);
				addOffset('attackLeft', 457, 155);
				addOffset('dodge', 11, 15);
				addOffset('ouchy', 18, 145);

				loopedIdle = true;

				playAnim('idle');

				flipX = true;

			case 'bfwhoareyou':
				frames = Paths.getSparrowAtlas('characters/BF_FINAL', 'shared', true);
				animation.addByPrefix('idle', 'BF annoyed instance 1', 24, true);
				animation.addByPrefix('singUP', 'BF NOTE UP copy instance 1', 24, false);
				animation.addByPrefix('singLEFT', 'BF NOTE LEFT copy instance 1', 24, false);
				animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT copy instance 1', 24, false);
				animation.addByPrefix('singDOWN', 'BF NOTE DOWN copy instance 1', 24, false);
				animation.addByPrefix('singUPmiss', 'U-Miss instance 1', 24, false);
				animation.addByPrefix('singLEFTmiss', 'L-Miss instance 1', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'R-Miss instance 1', 24, false);
				animation.addByPrefix('singDOWNmiss', 'D-Miss instance 1', 24, false);

				addOffset('idle', -5, 0);
				addOffset('singUP', -40, 37);
				addOffset('singRIGHT', -31, 0);
				addOffset('singLEFT', 10, -4);
				addOffset('singDOWN', -15, -24);
				addOffset('singUPmiss', -43, 74);
				addOffset('singRIGHTmiss', 4, 15);
				addOffset('singLEFTmiss', -19, 15);
				addOffset('singDOWNmiss', -20, -17);

				playAnim('idle');

				flipX = true;

				setZoom(1.481171548117155);

			case 'bfSans':
				frames = Paths.getSparrowAtlas('characters/BoyFriend_CRshader', 'shared', true);
				animation.addByPrefix('attack', '0BF attack instance 1', 24, false);
				animation.addByPrefix('oof', 'OuchBonesinmyAss instance 1', 24, false);
				animation.addByPrefix('idle', 'BF idle dance instance 1', 24, false);
				animation.addByPrefix('singUP', 'BF NOTE UP instance 1', 24, false);
				animation.addByPrefix('singLEFT', 'BF NOTE LEFT instance 1', 24, false);
				animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT instance 1', 24, false);
				animation.addByPrefix('singDOWN', 'BF NOTE DOWN instance 1', 24, false);
				animation.addByPrefix('singUPmiss', 'U-Miss', 24, false);
				animation.addByPrefix('singLEFTmiss', 'R-Miss', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'L-Miss', 24, false);
				animation.addByPrefix('singDOWNmiss', 'D-Miss', 24, false);

				addOffset('idle', 0, 0);
				addOffset('singUP', -49, 58);
				addOffset('singRIGHT', -34, 4);
				addOffset('singLEFT', 28, -3);
				addOffset('singDOWN', -23, -32);
				addOffset('singUPmiss', -56, 113);
				addOffset('singRIGHTmiss', -26, 24);
				addOffset('singLEFTmiss', 10, 23);
				addOffset('singDOWNmiss', -34, -24);
				addOffset('attack', 1101, -10);
				addOffset('oof', -20, -30);

				playAnim('idle');

				flipX = true;

			case 'bfsanswaterfall':
				frames = Paths.getSparrowAtlas('characters/BoyFriend_SansWT', 'shared', true);
				animation.addByPrefix('idle', 'BF idle dance instance 1', 24, false);
				animation.addByPrefix('singUP', 'BF NOTE UP instance 1', 24, false);
				animation.addByPrefix('singLEFT', 'BF NOTE LEFT instance 1', 24, false);
				animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT instance 1', 24, false);
				animation.addByPrefix('singDOWN', 'BF NOTE DOWN instance 1', 24, false);
				animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS instance 1', 24, false);
				animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS instance 1', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS instance 1', 24, false);
				animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS instance 1', 24, false);
				animation.addByPrefix('attack', '0BF attack instance 1', 24, false);
				animation.addByPrefix('hurt', 'BF hit instance 1', 24, false);
				animation.addByPrefix('dodge', 'boyfriend dodge instance 1', 24, false);

				addOffset('idle', -4, 2);
				addOffset("singUP", -51, 55);
				addOffset("singRIGHT", -38, 1);
				addOffset("singLEFT", 24, 3);
				addOffset("singDOWN", -32, -35);
				addOffset("singUPmiss", -60, 17);
				addOffset("singRIGHTmiss", -60, 24);
				addOffset("singLEFTmiss", -27, 19);
				addOffset("singDOWNmiss", -37, -17);
				addOffset("attack", 1083, -7);
				addOffset("hurt", 42, 53);
				addOffset("dodge", -20, -7);

				playAnim('idle');

				flipX = true;

			case 'bfchara':
				frames = Paths.getSparrowAtlas('characters/Chara', 'shared', true);
				animation.addByPrefix('idle', '0Idle', 24, false);
				animation.addByPrefix('singUP', '0UPPP', 24, false);
				animation.addByPrefix('singLEFT', '0EERR', 24, false);
				animation.addByPrefix('singRIGHT', '0EEEE', 24, false);
				animation.addByPrefix('singDOWN', '0Ouu', 24, false);
				animation.addByPrefix('singUPmiss', 'U-Miss', 24, false);
				animation.addByPrefix('singLEFTmiss', 'R-Miss', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'L-Miss', 24, false);
				animation.addByPrefix('singDOWNmiss', 'D-Miss', 24, false);
				animation.addByPrefix('firstDeath', "gdgdg instance 1", 24, false);
				animation.addByPrefix('attack', "0BF attack copy instance 1", 24, false);

				addOffset('idle', -5, 0);
				addOffset('singUP', -29, 47);
				addOffset('singRIGHT', -28, -7);
				addOffset('singLEFT', 72, -6);
				addOffset('singDOWN', -10, -30);
				addOffset('singUPmiss', -39, 107);
				addOffset('singRIGHTmiss', 2, 24);
				addOffset('singLEFTmiss', 40, 21);
				addOffset('singDOWNmiss', -10, -20);
				addOffset('firstDeath', 10, 30);
				addOffset('attack', 1117, -13);

				playAnim('idle');

				flipX = true;

			case 'bfwinter':
				frames = Paths.getSparrowAtlas('characters/BoyFriend_Assets_CHRISTMAS_VARIANT', 'shared', true);
				animation.addByPrefix('idle', 'BF idle dance', 24, false);
				animation.addByPrefix('singUP', 'BF NOTE UP instance 1', 24, false);
				animation.addByPrefix('singLEFT', 'BF NOTE LEFT instance 1', 24, false);
				animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT instance 1', 24, false);
				animation.addByPrefix('singDOWN', 'BF NOTE DOWN instance 1', 24, false);
				animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS instance 1', 24, false);
				animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS instance 1', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS instance 1', 24, false);
				animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS instance 1', 24, false);
				animation.addByPrefix('hey', 'BF HEY!! instance 1', 24, false);

				addOffset('hey', 7);
				addOffset('idle', 0);
				addOffset("singUP", -39, 37);
				addOffset("singRIGHT", -38, -7);
				addOffset("singLEFT", 22, -6);
				addOffset("singDOWN", -20, -40);
				addOffset("singUPmiss", -49, 27);
				addOffset("singRIGHTmiss", -48, 24);
				addOffset("singLEFTmiss", 0, 21);
				addOffset("singDOWNmiss", -20, -25);

				playAnim('idle');

				flipX = true;

			case 'bfSansNightmare':
				frames = Paths.getSparrowAtlas('characters/BF-BS-shader', 'shared', true);
				animation.addByPrefix('idle', 'BF idle dance instance 1', 24, false);
				animation.addByPrefix('singUP', 'BF NOTE UP instance 1', 24, false);
				animation.addByPrefix('singLEFT', 'BF NOTE LEFT instance 1', 24, false);
				animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT instance 1', 24, false);
				animation.addByPrefix('singDOWN', 'BF NOTE DOWN instance 1', 24, false);
				animation.addByPrefix('dodge', 'boyfriend dodge instance 1', 24, false);
				animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS instance 1', 24, false);
				animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS instance 1', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS instance 1', 24, false);
				animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS instance 1', 24, false);

				addOffset('idle',-5,0);
				addOffset('singUP',-53,55);
				addOffset('singRIGHT',-37,-1);
				addOffset('singLEFT',24,-3);
				addOffset('singDOWN',-26,-37);
				addOffset('singUPmiss',-55,14);
				addOffset('singRIGHTmiss',-63,24);
				addOffset('singLEFTmiss',-30,21);
				addOffset('singDOWNmiss',-27,-24);
				addOffset('dodge,-21,-15');

				playAnim('idle');

				flipX = true;

			case 'bfbattle':
				frames = Paths.getSparrowAtlas('characters/UT BF', 'shared', true);
				animation.addByPrefix('idle', '0Idle', 24, false);
				animation.addByPrefix('singUP', '0UPPP', 24, false);
				animation.addByPrefix('singLEFT', '0EERR', 24, false);
				animation.addByPrefix('singRIGHT', '0EEEE', 24, false);
				animation.addByPrefix('singDOWN', '0Ouu', 24, false);
				animation.addByPrefix('singUPmiss', 'Ouch instance 1', 24, false);
				animation.addByPrefix('singLEFTmiss', 'Ouch instance 1', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'Ouch instance 1', 24, false);
				animation.addByPrefix('singDOWNmiss', 'Ouch instance 1', 24, false);
				animation.addByPrefix('pee', 'Pee instance 1', 24, false);
				animation.addByPrefix('roses', 'Roses got me like instance 1', 24, true);

				addOffset('idle', -5, 0);
				addOffset("singUP", -29, 47);
				addOffset("singRIGHT", -18, -7);
				addOffset("singLEFT", 12, -6);
				addOffset("singDOWN", -10, -20);
				addOffset("singUPmiss", 40, 80);
				addOffset("singRIGHTmiss", 40, 80);
				addOffset("singLEFTmiss", 40, 80);
				addOffset("singDOWNmiss", 40, 80);
				addOffset("pee", 50, 150);
				addOffset("roses", 210, 190);

				flipX = true;

				playAnim('idle');

			case 'bfNightmareBendynew':
				frames = Paths.getSparrowAtlas('characters/BoyFriend_NM_Bendy', 'shared', true);
				animation.addByPrefix('idle', 'BF idle dance copy 2 instance 1', 24, true);
				animation.addByPrefix('singUP', 'BF NOTE UP copy 2 instance 1', 24, false);
				animation.addByPrefix('singLEFT', 'BF NOTE LEFT copy 2 instance 1', 24, false);
				animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT copy 2 instance 1', 24, false);
				animation.addByPrefix('singDOWN', 'BF NOTE DOWN copy 2 instance 1', 24, false);
				animation.addByPrefix('singUPmiss', 'U-Miss instance 1', 24, false);
				animation.addByPrefix('singLEFTmiss', 'L-Miss instance 1', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'R-Miss instance 1', 24, false);
				animation.addByPrefix('singDOWNmiss', 'D-Miss instance 1', 24, false);
				animation.addByPrefix('running', 'RUN BITCH instance 1', 24, false);
				animation.addByPrefix('dodge', 'Dodge instance 1', 24, false);
				animation.addByPrefix('hurt', 'Ouch instance 1', 24, false);
				animation.addByPrefix('ouchy', 'Ouch instance 1', 24, false);
				animation.addByPrefix('attackLeft', "Attack instance 1", 28, false);
				animation.addByPrefix('attackRight', "Attack instance 2", 28, false);

				addOffset('idle', 0, -205);
				addOffset('singUP', -39, -136);
				addOffset('singRIGHT', -21, -200);
				addOffset('singLEFT', 55, -205);
				addOffset('singDOWN', -20, -244);
				addOffset('singUPmiss', -43, -63);
				addOffset('singRIGHTmiss', 38, -170);
				addOffset('singLEFTmiss', -13, -166);
				addOffset('singDOWNmiss', 1, -236);
				addOffset('dodge', 15, -186);
				addOffset('ouchy', 15, -6);
				addOffset('hurt', 10, -4);
				addOffset('attackRight', -40, -6);
				addOffset('attackLeft', 537, -5);
				addOffset('running', 1931, -145);

				loopedIdle = true;

				playAnim('idle');
				setGraphicSize(Std.int(width * 1));

				flipX = true;

			case 'charabattle':
				frames = Paths.getSparrowAtlas('characters/CharaUT', 'shared', true);
				animation.addByPrefix('idle', '0Idle', 24, false);
				animation.addByPrefix('singUP', '0UPPP', 24, false);
				animation.addByPrefix('singLEFT', '0EERR', 24, false);
				animation.addByPrefix('singRIGHT', '0EEEE', 24, false);
				animation.addByPrefix('singDOWN', '0Ouu', 24, false);
				animation.addByPrefix('singUPmiss', 'Ouch instance 1', 24, false);
				animation.addByPrefix('singLEFTmiss', 'Ouch instance 1', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'Ouch instance 1', 24, false);
				animation.addByPrefix('singDOWNmiss', 'Ouch instance 1', 24, false);
				animation.addByPrefix('pee', 'Pee instance 1', 24, false);

				addOffset('idle', -5, 0);
				addOffset('singUP', -39, 47);
				addOffset('singRIGHT', -28, -7);
				addOffset('singLEFT', 32, -16);
				addOffset('singDOWN', 20, -20);
				addOffset('singUPmiss', -20, 0);
				addOffset('singRIGHTmiss', -20, 0);
				addOffset('singLEFTmiss', -20, 0);
				addOffset('singDOWNmiss', -20, 0);
				addOffset('pee', 50, 150);

				playAnim('idle');

			case 'devilFull':
				frames = Paths.getSparrowAtlas('characters/Devil', 'shared', true);
				animation.addByPrefix('idle', 'Idle instance 1', 20, false);
				animation.addByPrefix('singUP', 'Up instance 1', 20, false);
				animation.addByPrefix('singLEFT', 'Left instance 1', 20, false);
				animation.addByPrefix('singRIGHT', 'Right instance 1', 20, false);
				animation.addByPrefix('singDOWN', 'Down instance 1', 20, false);

				addOffset('idle', -4, -1);
				addOffset('singUP', 216, 145);
				addOffset('singRIGHT', -38, -297);
				addOffset('singLEFT', 612, -116);
				addOffset('singDOWN', 83, 7);

				playAnim('idle');

				setZoom(1.3);

			case 'bendyDA':
				frames = Paths.getSparrowAtlas('characters/BendyDAgames', 'shared', true);

				animation.addByPrefix('idle-alt', 'Oblivion Bendy instance 1', 24, true);
				animation.addByPrefix('singUP-alt', 'Up Oblivion instance 1', 24, false);
				animation.addByPrefix('singRIGHT-alt', 'Right Oblivion instance 1', 24, false);
				animation.addByPrefix('singDOWN-alt', 'Down Oblivion instance 1', 24, false);
				animation.addByPrefix('singLEFT-alt', 'Left Oblivion instance 1', 24, false);

				animation.addByPrefix('bendyIsTrans', 'Transformation instance 1', 24, false);
				animation.addByPrefix("you've got this", "You've got this instance 1", 24, false);
				animation.addByPrefix('ugh', 'ugh lowblow instance 1', 24, false);

				animation.addByPrefix('idle', 'Idle Normal instance 1', 24, true);
				animation.addByPrefix('singUP', 'Up Normal instance 1', 24, false);
				animation.addByPrefix('singRIGHT', 'Right Normal instance 1', 24, false);
				animation.addByPrefix('singDOWN', 'Down Normal instance 1', 24, false);
				animation.addByPrefix('singLEFT', 'Left instance 1', 24, false);
				animation.addByPrefix('hey', 'Up Normal instance 1', 24, false); //idk

				addOffset('idle', -1, 2);
				addOffset('singUP', 52, 64);
				addOffset('singRIGHT', 13, -24);
				addOffset('singLEFT', 149, -29);
				addOffset('singDOWN', 66, -42);
				addOffset('idle-alt', 152, 108);
				addOffset('singUP-alt', 30, 179);
				addOffset('singRIGHT-alt', 103, 80);
				addOffset('singLEFT-alt', 197, 60);
				addOffset('singDOWN-alt', 118, 21);
				addOffset('bendyIsTrans', -6, -17);
				addOffset('ugh', -33, 72);
				addOffset("you've got this", 22, -29);
				addOffset('hey', 52, 62); 

				loopedIdle = true;

				playAnim('idle');
				setZoom(1.5);

				updateHitbox();
			case 'none':
				//gave it a case to prevent crash

		}

		dance();

		if (isPlayer)
		{
			flipX = !flipX;

			// Doesn't flip for BF, since his are already in the right place???
			if (!curCharacter.startsWith('bf'))
			{
				// var animArray
				var oldRight = animation.getByName('singRIGHT').frames;
				animation.getByName('singRIGHT').frames = animation.getByName('singLEFT').frames;
				animation.getByName('singLEFT').frames = oldRight;

				// IF THEY HAVE MISS ANIMATIONS??
				if (animation.getByName('singRIGHTmiss') != null)
				{
					var oldMiss = animation.getByName('singRIGHTmiss').frames;
					animation.getByName('singRIGHTmiss').frames = animation.getByName('singLEFTmiss').frames;
					animation.getByName('singLEFTmiss').frames = oldMiss;
				}
			}
		}

		trace(curCharacter + "'s special animations are: " + specialAnimList);
		trace(curCharacter + "'s not so special animations are: " + notSoSpecialAnimList);
	}

	// Run this function with how much you want it to scale
	//-brightfyre
	public function setZoom(?toChange:Float = 1):Void
	{
		daZoom = toChange;
		scale.set(toChange, toChange);
	}

	public function moroAnim(animName, animPrefix, ?looped = false)
	{
		animation.addByPrefix(animName, animPrefix + ' instance 1', 24, looped);
	}

	public var altIdle:Bool = false;

	override function update(elapsed:Float)
	{
		if (preventDanceConstant && !preventDance)
		{
			preventDance = true;
		}

		if (!isPlayer)
		{
			if (animation.curAnim.name.startsWith('sing') || animation.curAnim.name.startsWith('pew'))
			{
				holdTimer += elapsed;
			}

			if (holdTimer >= Conductor.stepCrochet * 0.001 * singDuration)
			{
				// trace('dance');

				var altAnim:String = "";

				if (altIdle)
					altAnim = '-alt';

				dance(altAnim);

				holdTimer = 0;
			}
		}

		super.update(elapsed);
	}

	private var danced:Bool = false;

	/**
	 * FOR IDY CRUST DANCING SHIT
	 */
	public function dance(alt:String = '')
	{
		if (!debugMode)
		{
			if (!preventDance)
			{
				switch (curCharacter)
				{
					case 'sans' | 'sansbattle' | 'sansScared':
						danced = !danced;

						if (danced)
						{
							playAnim('idleRight' + alt);
						}
						else
						{
							playAnim('idleLeft' + alt);
						}
					default:
						if (idleReplacement != '')
						{
							playAnim(idleReplacement);
						}
						else
						{
							if (alt != '')
							{
								if (animation.curAnim.name != 'mlg')
								{
									if (animOffsets.exists('idle-alt'))
									{
										playAnim('idle-alt');
									}
									else if (animOffsets.exists('idle' + alt))
									{
										playAnim('idle' + alt);
									}
									else
									{
										playAnim('idle');
									}
								}
							}
							else
							{
								playAnim('idle');
							}
						}
				}
			}
			else
			{
				preventDance = false;
			}
		}
	}

	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0, playafterfin:Bool = false, whatanimtoplay:String = ''):Void
	{
		if (constantLooping)
		{
			animation.play(AnimName, Force, Reversed, this.animation.curAnim.curFrame + 1);
		}
		else animation.play(AnimName, Force, Reversed, Frame);

		var daOffset = animOffsets.get(AnimName);
		if (animOffsets.exists(AnimName))
		{
			offset.set(daOffset[0] * daZoom, daOffset[1] * daZoom);
			// if (!AnimName.startsWith('sing'))
			// trace('anim is ' + AnimName + ' offsets are ' + daOffset[0] + " and "  + daOffset[1]);
		}
		else
			offset.set(0, 0);

		if (playafterfin)
		{
			var num = animation.animNAMES.indexOf(AnimName);
			idletimer = new FlxTimer().start(animation.animFRAMES[num]/animation.animFPS[num]+0.05, function(tmr:FlxTimer)
			{
				if (whatanimtoplay == '')
					dance();
				else
					playAnim(whatanimtoplay,true);
			});
			// trace(AnimName + ' frames amt: ' + animation.animFRAMES[num] + ' fps: '+animation.animFPS[num]);
		}
	}

	public function addOffset(name:String, x:Float = 0, y:Float = 0)
	{
		if (check(name))
		{
			specialAnimList.push(name);
		}

		offsetNames.push(name);
		animOffsets[name] = [x, y];
	}

	public function check(str:String) {
		var total = notSoSpecialAnimList.length;
		var amt=0;
		for (i in 0...notSoSpecialAnimList.length)
		{
			if (!str.contains(notSoSpecialAnimList[i]))
				amt++;
		}
		if (amt == total)
			return true;
		else
			return false;
	}

	public function onpause(isp:Bool) {
		if (isp)
		{
			if (idletimer != null)
				idletimer.active = false;
		}
		else
		{
			if (idletimer != null)
				idletimer.active = true;
		}
	}
}