package;

import Shaders.BloomHandler;
import Shaders.ChromaHandler;
import Shaders.BrightHandler;
import Conductor.BPMChangeEvent;
import flixel.FlxBasic;
import flixel.FlxG;
import flixel.util.FlxColor;
import openfl.Lib;
import openfl.filters.ShaderFilter;
import openfl.display.FPS;
class MusicBeatState extends FNFState
{
	private var lastBeat:Int = -1;
	private var lastStep:Int = -1;

	public var curStep:Int = 0;

	private var curBeat:Int = 0;
	private var controls(get, never):Controls;

	inline function get_controls():Controls
		return PlayerSettings.player1.controls;

	override function create()
	{
		setChrome(0);
		FlxG.mouse.visible = false;
		
		if (Lib.current.getChildAt(0) != null)
		{
			(cast(Lib.current.getChildAt(0), Main)).setFPSCap(FlxG.save.data.fpsCap);
		}

		if (transIn != null)
			trace('reg ' + transIn.region);

		super.create();
	}

	var array:Array<FlxColor> = [
		FlxColor.fromRGB(148, 0, 211),
		FlxColor.fromRGB(75, 0, 130),
		FlxColor.fromRGB(0, 0, 255),
		FlxColor.fromRGB(0, 255, 0),
		FlxColor.fromRGB(255, 255, 0),
		FlxColor.fromRGB(255, 127, 0),
		FlxColor.fromRGB(255, 0, 0)
	];

	var skippedFrames = 0;

	override function update(elapsed:Float)
	{
		updateCurStep();
		updateBeat();

		if (FlxG.save.data.fpsRain && skippedFrames >= 6)
		{
			if (currentColor >= array.length)
				currentColor = 0;
			(cast(Lib.current.getChildAt(0), Main)).changeDisplayColor(array[currentColor]);
			currentColor++;
			skippedFrames = 0;
		}
		else
		{
			skippedFrames++;
		}

		if ((cast(Lib.current.getChildAt(0), Main)).getFPSCap != FlxG.save.data.fpsCap && FlxG.save.data.fpsCap <= 290)
		{
			(cast(Lib.current.getChildAt(0), Main)).setFPSCap(FlxG.save.data.fpsCap);
		}

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

	private function updateBeat():Void
	{
		curBeat = Math.floor(curStep / 4);

		if (lastBeat != curBeat && curBeat > 0)
		{
			beatHit();
			lastBeat = curBeat;
		}
	}

	public static var currentColor = 0;

	private function updateCurStep():Void
	{
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}
		for (i in 0...Conductor.bpmChangeMap.length)
		{
			if (Conductor.songPosition >= Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];
		}

		var tempCurStep:Int = lastChange.stepTime + Math.floor((Conductor.songPosition - lastChange.songTime) / Conductor.stepCrochet);

		if (lastStep != tempCurStep && tempCurStep > 0)
		{
			if (lastStep < tempCurStep)
			{
				var diff:Int = tempCurStep - lastStep;

				if (diff > 1)
				{
					trace("Missed " + diff + " steps.");
				}

				for (i in 0...diff)
				{
					curStep = lastStep + i + 1;
					stepHit();
				}
			}
			else
			{
				curStep = tempCurStep;
				stepHit();
			}

			lastStep = tempCurStep;
		}
	}

	public function stepHit():Void {}

	public function beatHit():Void {}

	public function onTick():Void {}

	public function pushToAchievementIDS(name:String, ?fromPlaystate:Bool = false, ?hasSound:Bool = true)
	{
		if (fromPlaystate)
		{
			if ((!PlayStateChangeables.botPlay || (PlayStateChangeables.botPlay && MainMenuState.showcase)) && PlayState.mechanicsEnabled)
			{
				Achievements.unlockAchievement(name, hasSound);
			}
		}
		else
		{
			Achievements.unlockAchievement(name, hasSound);
		}
	}

	// PERFORMANCE SHIT
	var trackedAssets:Array<Dynamic> = [];

	// polybiusproxy a real one
	// thx brightfyre

	override function add(Object:flixel.FlxBasic):flixel.FlxBasic
	{
		trackedAssets.insert(trackedAssets.length, Object);
		// scanType(Object);
		return super.add(Object);
	}

	/*just found out dump only works on legacy lime lmfao

		function scanType(Object:Dynamic) {
			if (Std.isOfType(Object, FlxSprite)) {
				var myObject:FlxSprite = cast(Object, FlxSprite);
				if (myObject.graphic != null)
					myObject.graphic.dump();
			}
			if (Std.isOfType(Object, FlxTypedGroup)) {
				var myGroup:FlxTypedGroup<Dynamic> = Object;
				myGroup.forEach(function(instance:Dynamic){
					scanType(instance);
				});
			}
		}
	 */
	// BRIGHT SHADER
	public var brightShader(get, never):ShaderFilter;

	inline function get_brightShader():ShaderFilter
		return BrightHandler.brightShader;

	public function setBrightness(brightness:Float):Void
		BrightHandler.setBrightness(brightness);

	public function setContrast(contrast:Float):Void
		BrightHandler.setContrast(contrast);

	// CHROMATIC SHADER
	public var chromaticAberration(get, never):ShaderFilter;

	inline function get_chromaticAberration():ShaderFilter
		return ChromaHandler.chromaticAberration;

	public function setChrome(daChrome:Float):Void
		ChromaHandler.setChrome(daChrome);

	// BLOOM SHADER
	public var bloomShader(get, never):ShaderFilter;

	inline function get_bloomShader():ShaderFilter
		return BloomHandler.bloomShader;

	public function setThreshold(value:Float)
		BloomHandler.setThreshold(value);

	public function setIntensity(value:Float)
		BloomHandler.setIntensity(value);

	public function setBlurSize(value:Float)
		BloomHandler.setBlurSize(value);
}
