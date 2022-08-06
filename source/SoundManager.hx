import flixel.FlxG;
import flixel.input.keyboard.FlxKey;

class SoundManager
{
	public static var volumeUpKeys:Array<FlxKey> = [PLUS, NUMPADPLUS];
	public static var volumeDownKeys:Array<FlxKey> = [MINUS, NUMPADMINUS];
	public static var muteKeys:Array<FlxKey> = [ZERO, NUMPADZERO];

	public static function toggleMuted():Void
	{
		FlxG.sound.muted = !FlxG.sound.muted;

		FlxG.save.data.muted = FlxG.sound.muted;

		if (FlxG.sound.volumeHandler != null)
		{
			FlxG.sound.volumeHandler(FlxG.sound.muted ? 0 : FlxG.sound.volume);
		}

		showSoundTray();
	}

	public static function changeVolume(Amount:Float):Void
	{
		FlxG.sound.muted = false;
		FlxG.sound.volume += Amount;

		if (Amount > 0)
		{
			FlxG.sound.play(Paths.sound('soundup', 'preload'), 0.5);
		}
		else
		{
			FlxG.sound.play(Paths.sound('sounddown', 'preload'), 0.6);
		}

		FlxG.save.data.volume = FlxG.sound.volume;
		FlxG.save.flush();

		showSoundTray();
	}

	public static function showSoundTray():Void
	{
		#if FLX_SOUND_TRAY
		if (FlxG.game.soundTray != null)
		{
			FlxG.game.soundTray.show(true);
		}
		#end
	}
}
