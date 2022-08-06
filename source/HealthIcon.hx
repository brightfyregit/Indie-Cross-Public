package;

import flixel.FlxG;
import flixel.FlxSprite;

/**
 * @author BrightFyre
 */

using StringTools;
class HealthIcon extends FlxSprite
{
	public var animOffsets:Map<String, Array<Dynamic>>;
	public var sprTracker:FlxSprite;
	public var special:Bool = false;

	public var character:String = 'bf';

	public function new(char:String = 'bf', isPlayer:Bool = false)
	{
		super();

		character = char;

		animOffsets = new Map<String, Array<Dynamic>>();

		antialiasing = FlxG.save.data.highquality;

		if (
			   (character == 'devilFull' && FlxG.save.data.secretChars[0]
			|| character == 'papyrus' && FlxG.save.data.secretChars[1]
			|| character == 'papyrusandsans' && FlxG.save.data.secretChars[2]
			|| character == 'sammy' && FlxG.save.data.secretChars[3]
			|| character == 'bendyDA' && FlxG.save.data.secretChars[4]
			|| character == 'cupheadNightmare' && FlxG.save.data.secretChars[5]
			|| character == 'sansNightmare' && FlxG.save.data.secretChars[6]
			|| character == 'bendyNightmare' && FlxG.save.data.secretChars[7])
			&& Type.getClass(FlxG.state) != PlayState
			)
		{
			loadGraphic(Paths.image('what', 'achievements'));

			setGraphicSize(100, 100);

			offset.set(0, 0);
		}
		else
		{
			switch (character)
			{
				case 'sans' | 'saness' | 'sansScared' | 'cuphead' | 'cupheadNightmare' | 'angrycuphead' | 'bendyChase' | 'bendyNightmare' | 'gose' |
					'papyrus' | 'sansNightmare' | 'bendy' | 'sammy' | 'papyrusandsans' | 'devilFull':
					{
						frames = Paths.getSparrowAtlas('UI_assets', 'preload');
	
						offset.set(0, 0);
	
						switch (character)
						{
							case 'sans' | 'sanswinter':
								animation.addByPrefix('normal', 'sans normal', 24, true, isPlayer);
								animation.addByPrefix('loss', 'sans lose', 24, true, isPlayer);
	
								addOffset('normal', 0, 0);
								addOffset('loss', 0, 0);
							case 'sansScared':
								animation.addByPrefix('normal', 'sans scared normal', 24, true, isPlayer);
								animation.addByPrefix('loss', 'sans scared lose', 24, true, isPlayer);
	
								addOffset('normal', 0, 0);
								addOffset('loss', 0, 0);
							case 'bendy' | 'bendyChase':
								frames = Paths.getSparrowAtlas('NewIcons', 'preload');
	
								animation.addByPrefix('normal', 'Bendo instance 1', 24, true, isPlayer);
	
								addOffset('normal', 0, 0);
							case 'sammy':
								frames = Paths.getSparrowAtlas('SammyIcon', 'preload');
	
								animation.addByPrefix('normal', 'black dude instance 1', 24, true, isPlayer);
								animation.addByPrefix('loss', 'black dude instance 1', 24, true, isPlayer);
	
								addOffset('normal', 0, 0);
								addOffset('loss', 0, 0);
							case 'cuphead':
								frames = Paths.getSparrowAtlas('NewIcons', 'preload');
	
								animation.addByPrefix('normal', 'C-Normal instance 1', 24, true, isPlayer);
								animation.addByPrefix('loss', 'C-lose instance 1', 24, true, isPlayer);
	
								addOffset('normal', 0, 0);
								addOffset('loss', 0, 0);
							case 'angrycuphead':
								frames = Paths.getSparrowAtlas('NewIcons', 'preload');
	
								animation.addByPrefix('normal', 'C-Pissed instance 1', 24, true, isPlayer);
								animation.addByPrefix('loss', 'C-Dead instance 1', 24, true, isPlayer);
	
								addOffset('normal', 0, 15);
								addOffset('loss', 0, 0);
							case 'cupheadNightmare':
								frames = Paths.getSparrowAtlas('NewIcons', 'preload');
	
								animation.addByPrefix('normal', 'C-Nightmare instance 1', 24, true, isPlayer);
	
								addOffset('normal', 0, 0);
							case 'bendyNightmare':
								animation.addByPrefix('normal', 'nightmare bendy normal', 24, true, isPlayer);
								animation.addByPrefix('win', 'nightmare bendy win', 24, true, isPlayer);
	
								addOffset('normal', 0, 0);
								addOffset('win', 35, 45);
							case 'gose':
								frames = Paths.getSparrowAtlas('goose_icons', 'hiddenContent');
	
								animation.addByPrefix('normal', 'gose', 24, true, isPlayer);
								animation.addByPrefix('loss', 'goose pissed', 24, true, isPlayer);
	
								addOffset('normal', 0, 0);
								addOffset('loss', 0, 0);
							case 'sansNightmare':
								frames = Paths.getSparrowAtlas('UISansIcon_assets', 'preload');
	
								offset.set(20, 32);
	
								animation.addByPrefix('loss', 'loss', 24, true, isPlayer);
								animation.addByPrefix('normal', 'normal', 24, true, isPlayer);
								animation.addByPrefix('win', 'win', 24, true, isPlayer);
	
								addOffset('loss', -80, -20);
								addOffset('normal', 20, 30);
								addOffset('win', 69, 13);
							case 'papyrus':
								frames = Paths.getSparrowAtlas('Pee', 'preload');
	
								animation.addByPrefix('normal', 'Hehe boii instance 1', 24, true, isPlayer);
								animation.addByPrefix('loss', 'oh shit instance 1', 24, true, isPlayer);
	
								addOffset('normal', 0, 0);
								addOffset('loss', 0, 0);
							case 'papyrusandsans':
								frames = Paths.getSparrowAtlas('UTbros', 'preload');
	
								animation.addByPrefix('normal', 'Bros instance 1', 24, true, isPlayer);
								animation.addByPrefix('loss', "Fuck sans we're losing instance 1", 24, true, isPlayer);
	
								addOffset('normal', 0, 0);
								addOffset('loss', 0, 0);
							case 'devilFull':
								frames = Paths.getSparrowAtlas('NewDevilIcon', 'preload');
	
								offset.set(7, 20);
	
								animation.addByPrefix('loss', 'Devilmad instance 1', 24, true, isPlayer);
								animation.addByPrefix('normal', 'Dev instance 1', 24, true, isPlayer);
	
								addOffset('loss', 34, -4);
								addOffset('normal', 0, 0);
	
							case 'saness':
								frames = Paths.getSparrowAtlas('FuckBoi', 'hiddenContent');
	
								animation.addByPrefix('normal', 'hehe funne sans instance 1', 24, true, isPlayer);
								animation.addByPrefix('loss', "Bro wut instance 1", 24, true, isPlayer);
	
								addOffset('normal', 0, 0);
								addOffset('loss', 0, 0);
						}
	
						playAnim('normal', true);
	
						special = true;
					}
				case 'bendyDA':
					{
						loadGraphic(Paths.image('BendyIcon', 'preload'));
						oneframe = true;
					}
				default:
					{
						loadGraphic(Paths.image('iconGrid'), true, 150, 150);
	
						animation.add('bf', [0, 1], 0, false, isPlayer);
						animation.add('gf', [16], 0, false, isPlayer);
						animation.add('dad', [12, 13], 0, false, isPlayer);
	
						if (character.contains('bf'))
						{
							playAnim('bf', true);
						}
						else
						{
							playAnim(character, true);
						}
					}
			}
		}

		scrollFactor.set();
	}

	public var oneframe:Bool = false;

	public var yOffset:Int = 0;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30 + yOffset);
	}

	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		animation.play(AnimName, Force, Reversed, Frame);

		var daOffset = animOffsets.get(AnimName);

		if (animOffsets.exists(AnimName))
		{
			offset.set(daOffset[0], daOffset[1]);
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
