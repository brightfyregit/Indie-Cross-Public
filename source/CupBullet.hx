package;

import flash.display.BlendMode;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.math.FlxMath;
using StringTools;

class CupBullet extends FlxSprite
{
	public var bType:String = 'hadoken';
	public var state:String = 'unactive';

	public var time:Float = 0;
	public var hsp:Float = 0;
	public var vsp:Float = 0;
	public var cantmove = false;
	static public var pewOrder:Int = 0;
	var triggered:Bool = false;

	public var pew:Void->Void = null;
	var realOffset:FlxPoint;

	public function new(type:String, sX:Float, sY:Float)
	{
		x = sX;
		y = sY;

		bType = type;

		super(x, y);

		realOffset = new FlxPoint();
		switch (bType)
		{
			case 'hadoken':
				if (PlayState.SONG.player2 == 'cupheadNightmare')
				{
					frames = Paths.getSparrowAtlas('bull/NMcupheadAttacks', 'cup');
					animation.addByPrefix('fire', 'DeathBlast instance 1', 24, false);
				}
				else
				{
					frames = Paths.getSparrowAtlas('bull/Cuphead Hadoken', 'cup');
					animation.addByPrefix('fire', 'Hadolen instance 1', 24, false);
				}
				animation.play('fire');

			case 'roundabout':
				frames = Paths.getSparrowAtlas('bull/Roundabout', 'cup');
				animation.addByPrefix('fire', 'Roundabout instance 1', 24, false);
				animation.play('fire');

			case 'chaser':
				frames = Paths.getSparrowAtlas('bull/GreenShit', 'cup');
				var assValue:Int = FlxG.random.int(0, 1);
				switch (assValue)
				{
					case 0:
						animation.addByPrefix('fire', 'GreenShit01', 24, false);
					case 1:
						animation.addByPrefix('fire', 'GreenShit02', 24, false);
					case 2:
						animation.addByPrefix('fire', 'GreenShit03', 24, false);
				}
				animation.play('fire');

			case 'pew':
				frames = Paths.getSparrowAtlas('bull/Cupheadshoot', 'cup');
				animation.addByPrefix('fire', 'BulletFX_H-Tween_02 instance 1', 24, false);
				animation.addByPrefix('fire-alt', 'BulletFX_H-Tween_03 instance 1', 24, false);

				switch (pewOrder) {
					case 1:
						realOffset.y = 25;
					case 2:
						realOffset.y = -40;
				}
				animation.play('fire');
				pewOrder++;
				if (pewOrder > 2)
					pewOrder = 0;

			case 'pewFX':
				frames = Paths.getSparrowAtlas('bull/Cupheadshoot', 'cup');
				animation.addByPrefix('fire', 'BulletFlashFX instance 1', 24, false);
				animation.play('fire');
				
			case 'hadokenFX':
				frames = Paths.getSparrowAtlas('bull/Cuphead Hadoken', 'cup');
				animation.addByPrefix('fire', 'BurstFX', 24, false);
				animation.play('fire');	

			case 'laser':
				frames = Paths.getSparrowAtlas('bull/NMcupheadBull', 'cup');
				var assValue:Int = FlxG.random.int(0, 4);
				switch (assValue)
				{
					case 0:
						animation.addByPrefix('fire', 'Shot01 instance 1', 24, false);
					case 1:
						animation.addByPrefix('fire', 'Shot02 instance 1', 24, false);
					case 2:
						animation.addByPrefix('fire', 'Shot03 instance 1', 24, false);
					case 3:
						animation.addByPrefix('fire', 'Shot04 instance 1', 24, false);
					case 4:
						animation.addByPrefix('fire', 'Shot05 instance 1', 24, false);		
				}
				animation.play('fire');
				scale.y = 1.25;
				scale.x = 1.65;
		}

		antialiasing = FlxG.save.data.highquality;

		alpha = 0.0001; // making this very low instead of 0 will remove the lag when cuphead shoots it

		if (PlayState.SONG.song.toLowerCase() == 'knockout') blend = BlendMode.ADD;

		updateHitbox();

		offset.x = frameWidth / 2 + realOffset.x;
		offset.y = frameHeight / 2 + realOffset.y;
	}
	var aaa = 0.0;

	override function update(elapsed:Float)
	{
		var timeIndex = elapsed * 120;

		switch (state) // General code that applies to every type
		{
			case 'unactive':
				alpha = 0.0001;
				time = 0;

			case 'debug':
				alpha = 1;
				time = 0;
				animation.pause();
			case 'shoot':
				alpha = 1;
				animation.play('fire');
				time += timeIndex;
			case 'oneshoot':
				alpha = 1;
				// animation.play('fire');
				time += timeIndex;
			case '':
				// :)
		}

		switch (bType)
		{
			case 'hadoken':
				switch (state)
				{
					case 'shoot':
						if (PlayState.SONG.song.toLowerCase() != 'devils-gambit') hsp = 12;
						else hsp = 18;
				}

			case 'roundabout':
				scale.set(1.5,1.5);
				aaa = 5;
				switch (state)
				{
					case 'shoot':
						var roundtime = 90;
						if (time < 10)
						{
							hsp = 16;
						}
						else if (time > roundtime && time < roundtime + 100)
						{
							hsp -= timeIndex * 0.3;
						}
				}

			case 'chaser':
				if (animation.curAnim != null)
				{
					if (animation.curAnim.curFrame == 12 && !triggered)
					{
						triggered = true;
						pew();
					}
				}
			case 'pew':
				if (animation.curAnim.curFrame == 6 && !triggered)
				{
					triggered = true;
					pew();
				}
			case 'laser':
				if (animation.curAnim.curFrame == 6 && !triggered)
				{
					triggered = true;
					pew();
				}
		}

		if (!cantmove)
		{
			x += hsp * timeIndex;
			y += vsp * timeIndex + (Math.sin(FlxG.game.ticks / 90) * -aaa);
		}

		super.update(elapsed);
	}
}
