package;

import cpp.ConstCharStar;
import cpp.Native;
import cpp.UInt64;
import flixel.FlxG;
import flixel.FlxState;
import lime.app.Application;
import openfl.system.Capabilities;

#if windows
@:headerCode("#include <windows.h>")
#elseif linux
@:headerCode("#include <stdio.h>")
#end
class SpecsDetector extends FlxState
{
	var cache:Bool = false;
	var isCacheSupported:Bool = false;

	override public function create()
	{
		KadeEngineData.initSave();
		super.create();

		FlxG.save.data.cachestart = checkSpecs();
		FlxG.switchState(new Caching());
	}

	function checkSpecs():Bool
	{
		var cpu:Bool = Capabilities.supports64BitProcesses; // too lazy for changing this
		var ram:UInt64 = obtainRAM();

		if (cpu && ram >= 4096)
			return true;
		else
		{
			return messageBox("INDIE CROSS",
				"Your PC does not meet the requirements Indie Cross has.\nWhile you can still play the mod, you may experience framedrops and/or lag spikes.\n\nDo you want to play anyway?");
		}

		return true;
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}

	#if windows
	@:functionCode("
		// simple but effective code
		unsigned long long allocatedRAM = 0;
		GetPhysicallyInstalledSystemMemory(&allocatedRAM);

		return (allocatedRAM / 1024);
	")
	#elseif linux
	@:functionCode('
		// swag linux 😎😎😎😎😎
		FILE *meminfo = fopen("/proc/meminfo", "r");

    	if(meminfo == NULL)
			return -1;

    	char line[256];
    	while(fgets(line, sizeof(line), meminfo))
    	{
        	int ram;
        	if(sscanf(line, "MemTotal: %d kB", &ram) == 1)
        	{
            	fclose(meminfo);
            	return (ram / 1024);
        	}
    	}

    	fclose(meminfo);
    	return -1;
	')
	#end
	function obtainRAM()
	{
		return 0;
	}

	function messageBox(title:ConstCharStar = null, msg:ConstCharStar = null)
	{
		#if windows
		var msgID:Int = untyped MessageBox(null, msg, title, untyped __cpp__("MB_ICONQUESTION | MB_YESNO"));

		if (msgID == 7)
		{
			Sys.exit(0);
		}

		return true;
		#else
		lime.app.Application.current.window.alert(cast msg, cast title);
		return true;
		#end
	}
}
