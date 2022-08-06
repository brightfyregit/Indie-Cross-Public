package animateAtlasPlayer.core;

class SymbolType
{
    
    public static inline var GRAPHIC : String = "G";
    public static inline var MOVIE_CLIP : String = "MC";
    public static inline var BUTTON : String = "button";
    
    public static function isValid(value : String) : Bool
    {
        return value == GRAPHIC || value == MOVIE_CLIP || value == BUTTON;
    }
}

