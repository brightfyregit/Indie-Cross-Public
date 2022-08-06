package animateAtlasPlayer.core;

import openfl.display.DisplayObject;
import openfl.display.DisplayObjectContainer;
import openfl.display.Sprite;
import openfl.errors.Error;
import openfl.events.Event;

class Animation extends DisplayObjectContainer
{
    public var currentLabel(get, never) : String;
    public var currentFrame(get, set) : Int;
    private var currentTime(get, set) : Float;
    public var frameRate(get, set) : Float;
    public var loop(get, set) : Bool;
    public var totalFrames(get, never) : Int;
    public var isPlaying(get, never) : Bool;
    private var totalTime(get, never) : Float;

    private var _symbol : Symbol;
    private var _behavior : MovieBehavior;
    private var _cumulatedTime : Float = 0.0;
	
	private var items:Map<String,DisplayObject> = new Map<String,DisplayObject>();
	
	public static inline var ITEM_PREFIX:String = "*";
    
    public function new(data : Dynamic, atlas : AnimationAtlas)
    {
        super();
        _symbol = new Symbol(data, atlas);
		addChild(_symbol);
		_symbol.createLayers();
        _symbol.update();
        
        _behavior = new MovieBehavior(this, onFrameChanged, atlas.frameRate);
        _behavior.numFrames = _symbol.numFrames;
        _behavior.addEventListener(Event.COMPLETE, onComplete);
		addEventListener(Event.ENTER_FRAME, onEnterFrame);
        play();
    }
    
    private function onComplete(pEvent:Event ) : Void
    {
        // TODO: dispatchEventWith(Event.COMPLETE);
        dispatchEvent(new Event(Event.COMPLETE));
    }
    
    private function onFrameChanged(frameIndex : Int) : Void
    {
        _symbol.currentFrame = frameIndex;
    }
    
    public function play() : Void
    {
        _behavior.play();
    }
    
    public function stop() : Void
    {
        _behavior.pause();
    }
	
	public function gotoAndPlay(frame:Dynamic, scene:String = null):Void {
		gotoFrame(frame);
		play();
	}
	
	public function gotoAndStop(frame:Dynamic, scene:String = null):Void {
		gotoFrame(frame);
		stop();
	}
	
	public function nextFrame():Void {
		gotoFrame(currentFrame+1);
		stop();
	}
	
	public function prevFrame():Void {
		gotoFrame(currentFrame-1);
		stop();
	}
    
    private function gotoFrame(indexOrLabel : Dynamic) : Void
    {
        currentFrame = (Std.is(indexOrLabel, String)) ? 
        _symbol.getFrame(Std.string(indexOrLabel)) : Std.int(indexOrLabel);
    }
    
	private function onEnterFrame (pEvent:Event):Void {
		//TODO: on peut se baser sur le temps entre deux frames si on veut (getTimer)
		advanceTime(0.016);
	}
	
    private function advanceTime(time:Float) : Void
    {
		
		var frameRate : Float = _behavior.frameRate;
        var prevTime : Float = _cumulatedTime;
        
        _behavior.advanceTime(time);
        _cumulatedTime += time;
        
        if (Std.int(prevTime * frameRate) != Std.int(_cumulatedTime * frameRate))
        {
            _symbol.nextFrame_MovieClips();
        }
    }
    
    public function getNextLabel(afterLabel : String = null) : String
    {
        return _symbol.getNextLabel(afterLabel);
    }
    
    public function getFrame(label : String) : Int
    {
        return _symbol.getFrame(label);
    }
    
    private function get_currentLabel() : String
    {
        return _symbol.currentLabel;
    }
    
    private function get_currentFrame() : Int
    {
        return _behavior.currentFrame+1;
    }
    private function set_currentFrame(value : Int) : Int
    {
        _behavior.currentFrame = value-1;
        return value;
    }
    
    private function get_currentTime() : Float
    {
        return _behavior.currentTime;
    }
    private function set_currentTime(value : Float) : Float
    {
        _behavior.currentTime = value;
        return value;
    }
    
    private function get_frameRate() : Float
    {
        return _behavior.frameRate;
    }
    private function set_frameRate(value : Float) : Float
    {
        _behavior.frameRate = value;
        return value;
    }
    
    private function get_loop() : Bool
    {
        return _behavior.loop;
    }
    private function set_loop(value : Bool) : Bool
    {
        _behavior.loop = value;
        return value;
    }
    
    private function get_totalFrames() : Int
    {
        return _behavior.numFrames;
    }
    private function get_isPlaying() : Bool
    {
        return _behavior.isPlaying;
    }
    private function get_totalTime() : Float
    {
        return _behavior.totalTime;
    }
	
	public function addItem(swapName:String, pItem:DisplayObject = null):Void {
		if (swapName.indexOf(ITEM_PREFIX) != 0) throw new Error("Item prefix (" + ITEM_PREFIX + ") missing."); 
		if (pItem == null) items[swapName] =  new Sprite();
		else items[swapName] = pItem;
		setItem(swapName, this , items[swapName]);
	}
	
	public function removeItem(swapName:String):Void {
		addItem(swapName);
	}
	
	public function getItem (name:String):DisplayObject {
		if (items[name] == null) items[name] = new Sprite();
		return items[name];
	}
	
	private function setItem (itemName:String,symbol:DisplayObjectContainer,item:DisplayObject=null): Void {
		
		var child:DisplayObjectContainer;
		for (i in 0...symbol.numChildren) {
			if (!Std.is(symbol.getChildAt(i), DisplayObjectContainer)) continue;
			child = cast(symbol.getChildAt(i), DisplayObjectContainer);
			if (child.name.indexOf(itemName)==0 && child.numChildren>0) cast(child.getChildAt(0), Symbol).setItem(item);
			else setItem (itemName, cast(child,DisplayObjectContainer), item);
		}
		
	}
	


}

