package;

import flixel.FlxG;
import openfl.media.Sound;
import openfl.media.SoundChannel;
import openfl.media.SoundTransform;
import openfl.utils.Assets;

class SoundSystem
{
	public var sound:Sound;

	var channel:SoundChannel;
	var volume:Float = 1;
	var force:Bool = false;

	public function new()
	{
		sound = new Sound();
	}

	public function loadSound(key:String, cache:Bool = true)
	{
		if (sound != null)
		{
			sound = Assets.getMusic(key, cache);
		}
		else
			trace('Sound is null!');
	}

	public function play(?startTime:Float = 0.0, ?loops:Int = 0)
	{
		channel = sound.play(startTime, loops);
		changeVolume(FlxG.sound.volume, true);
	}

	public function changeVolume(vol:Float, overrideForce:Bool = false)
	{
		if (channel != null)
		{
			channel.soundTransform = new SoundTransform(vol);
		}

		if (overrideForce)
			force = true;

		volume = vol;
		trace(volume);
	}

	public function getPosition()
	{
		if (channel != null)
		{
			return channel.position;
		}
		else
			return 0;
	}

	// how do i pause :(
	public function stop()
	{
		if (channel != null && sound != null)
		{
			channel.stop();
		}
		else
			trace('No sound was found!');
	}
	/*
		public function tweenPan()
		{
			if (channel != null)
			{
				channel.soundTransform.pan = FlxTween.num(-1, 1)
			}
		}
	 */
}
