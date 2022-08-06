package background;

import flixel.FlxG;
import flixel.FlxSprite;

class BendyBoy extends FlxSprite
{
	public var type:String;
	public var attacking:Bool = false;
	public var swinging:Bool = false;

	public var hp:Int = 2;

	public var animOffsets:Map<String, Array<Dynamic>>;

	public function new(x:Float, y:Float, type:String, despair:Bool)
	{
		super(x - 50, y - 50);
		this.type = type;

		animOffsets = new Map<String, Array<Dynamic>>();

		offset.set(0, 0);

		var suffix:String = "";

		if (despair)
		{
			suffix = "Despair";
		}

		switch (type)
		{
			case "piper":
				frames = Paths.getSparrowAtlas("third/Piper" + suffix, "bendy");
				animation.addByPrefix("walk", "pip walk instance 1", 24, true);
				animation.addByPrefix("idle", "Piperr instance 1", 24, true);
				animation.addByPrefix("hit", "Piper gets Hit instance 1", 24, false);
				animation.addByPrefix("ded", "Piper ded instance 1", 24, false);
				animation.addByPrefix("preAttack", "PipAttack instance 1", 24, false);
				animation.addByPrefix("attack", "PeepAttack instance 1", 24, false);

				addOffset("walk", 0, 0);
				addOffset("idle", -110, -10);
				addOffset("hit", -30, 140);
				addOffset("ded", -50, 140);
				addOffset("preAttack", -40, 30);
				addOffset("attack", 220, 200);
			case "striker":
				frames = Paths.getSparrowAtlas("third/Striker" + suffix, "bendy");
				animation.addByPrefix("walk", "Str walk instance 1", 24, true);
				animation.addByPrefix("idle", "strrr instance 1", 24, true);
				animation.addByPrefix("hit", "Sticker  instance 1", 24, false);
				animation.addByPrefix("ded", "I ded instance 1", 24, false);
				animation.addByPrefix("preAttack", "PunchAttack_container instance 1", 24, false);
				animation.addByPrefix("attack", "regeg instance 1", 24, false);

				addOffset("walk", 0, 0);
				addOffset("idle", -20, -10);
				addOffset("hit", 110, 70);
				addOffset("ded", 210, 70);
				addOffset("preAttack", 0, 0);
				addOffset("attack", -22, -4);
		}

		if (despair)
		{
			scrollFactor.set(0.91, 0.91);
			setZoom(1.3 * 1.7);
		}
		else
		{
			setZoom(1.1 * 1.7);
		}

		antialiasing = FlxG.save.data.highquality;

		playAnim("walk");
	}

	public var daZoom:Float = 1;

	public function die()
	{
		trace(type + " died");
		FlxG.sound.play(Paths.sound('butcherSounds/Ded', 'bendy'), 1);
		hp = 0;
		playAnim("ded", true);
		attacking = false;
	}

	public function hit()
	{
		var randomsound:String = 'butcherSounds/Hurt0' + FlxG.random.int(1, 2);
		trace(randomsound);
		FlxG.sound.play(Paths.sound(randomsound, 'bendy'), 1);
		playAnim("hit", true);
	}

	public function attack()
	{
		var randomsound:String = 'butcherSounds/Attack0' + FlxG.random.int(1, 4);
		trace(randomsound);
		FlxG.sound.play(Paths.sound(randomsound, 'bendy'), 1);
		playAnim("attack", true);
	}

	public function preAttack()
	{
		swinging = true;
		playAnim("preAttack", true);
	}

	public function setZoom(?toChange:Float = 1):Void
	{
		daZoom = toChange;
		scale.set(toChange, toChange);
	}

	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		animation.play(AnimName, Force, Reversed, Frame);

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
		animOffsets[name] = [x/1.7, y/1.7];
	}
}
