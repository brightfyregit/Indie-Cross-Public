package;

import Shaders.ChromaHandler;
import Shaders.BrightHandler;
import flixel.FlxG;
import Conductor.BPMChangeEvent;
import flixel.FlxSubState;
import openfl.filters.ShaderFilter;

class MusicBeatSubstate extends FlxSubState
{

	private var lastBeat:Float = 0;
	private var lastStep:Float = 0;

	private var curStep:Int = 0;
	private var curBeat:Int = 0;
	private var controls(get, never):Controls;

	inline function get_controls():Controls
		return PlayerSettings.player1.controls;

	public function new()
	{
		FlxG.mouse.visible = false;
		super();
	}

	override function update(elapsed:Float)
	{
		//everyStep();
		var oldStep:Int = curStep;

		updateCurStep();
		curBeat = Math.floor(curStep / 4);

		if (oldStep != curStep && curStep > 0)
			stepHit();

		if (FlxG.keys.anyJustReleased(SoundManager.muteKeys))
		{
			SoundManager.toggleMuted();
		}
		else if (FlxG.keys.anyJustReleased(SoundManager.volumeUpKeys))
		{
			SoundManager.changeVolume(0.1);
		}
		else if (FlxG.keys.anyJustReleased(SoundManager.volumeDownKeys))
		{
			SoundManager.changeVolume(-0.1);
		}

		super.update(elapsed);
	}

	private function updateCurStep():Void
	{
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}
		for (i in 0...Conductor.bpmChangeMap.length)
		{
			if (Conductor.songPosition > Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];
		}

		curStep = lastChange.stepTime + Math.floor((Conductor.songPosition - lastChange.songTime) / Conductor.stepCrochet);
	}

	public function stepHit():Void
	{
		if (curStep % 4 == 0)
			beatHit();
	}

	public function beatHit():Void
	{
		//do literally nothing dumbass
	}

	//PERFORMANCE SHIT
	var trackedAssets:Array<Dynamic> = [];

	override function add(Object:flixel.FlxBasic):flixel.FlxBasic
	{
		trackedAssets.insert(trackedAssets.length, Object);
		return super.add(Object);
	}

	/*override function switchState(nextState:flixel.FlxState):flixel.FlxG
	{
		unloadAssets();
		return super.switchState(nextState);
	}*/

	//BRIGHT SHADER
	public var brightShader(get, never):ShaderFilter;

	inline function get_brightShader():ShaderFilter
	{
		return BrightHandler.brightShader;
	}
		
	public function setBrightness(brightness:Float):Void
	{
		BrightHandler.setBrightness(brightness);
	}
		
	public function setContrast(contrast:Float):Void
	{
		BrightHandler.setContrast(contrast);
	}
}
