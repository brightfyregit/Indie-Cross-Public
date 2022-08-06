package animateAtlasPlayer.core;

class LoopMode
{
    
    public static inline var LOOP : String = "loop";
    public static inline var PLAY_ONCE : String = "playonce";
    public static inline var SINGLE_FRAME : String = "singleframe";
    
    public static function isValid(value : String) : Bool
    {
        return value == LOOP || value == PLAY_ONCE || value == SINGLE_FRAME;
    }
}
