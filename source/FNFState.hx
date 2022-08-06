package;

import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.ui.FlxUIState;

class FNFState extends FlxUIState
{
	public static var disableNextTransIn:Bool = false;
	public static var disableNextTransOut:Bool = false;
    
    public var enableTransIn:Bool = true;
    public var enableTransOut:Bool = true;

    public static var dumpcachetuff:Bool = true;
    
    var transOutRequested:Bool = false;
    var finishedTransOut:Bool = false;

    var dumpAddt:Bool = true;

    public function new()
    {
        super();
    }

    override function create()
    {
		if (dumpAddt)
            LoadingState.dumpAdditionalAssets();
        
        if (dumpcachetuff)
            Main.dumpCache();
        
        super.create();

		if (disableNextTransIn)
		{
			enableTransIn = false;
			disableNextTransIn = false;
		}
        
		if (disableNextTransOut)
		{
			enableTransOut = false;
			disableNextTransOut = false;
		}
        
		if (enableTransIn)
		{
			trace("transIn");
			fadeIn();
		}
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);
    }

    override function switchTo(state:FlxState):Bool
    {
        if (!finishedTransOut && !transOutRequested)
        {
            if (enableTransOut)
            {   
                fadeOut(function()
                {
                    finishedTransOut = true;
                    Main.switchState(state);
                });

                transOutRequested = true;
            }
            else
                return true;
        }

        return finishedTransOut;
    }

    function fadeIn()
    {
        subStateRecv(this, new DiamondTransSubState(0.5, true, function() { closeSubState(); }));
    }

    function fadeOut(finishCallback:()->Void)
    {
        trace("trans out");
        subStateRecv(this, new DiamondTransSubState(0.5, false, finishCallback));
    }

    function subStateRecv(from:FlxState, state:FlxSubState)
    {
        if (from.subState == null)
            from.openSubState(state);
        else
            subStateRecv(from.subState, state);
    }
}