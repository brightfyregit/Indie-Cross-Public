package animateAtlasPlayer.assets;
import animateAtlasPlayer.textures.TextureAtlas;
import openfl.display.BitmapData;
import openfl.media.Sound;
import openfl.utils.ByteArray;

class AssetType
{
    
    public static inline var TEXTURE : String = "texture";
    public static inline var TEXTURE_ATLAS : String = "textureAtlas";
    public static inline var SOUND : String = "sound";
    public static inline var OBJECT : String = "object";
    public static inline var BYTE_ARRAY : String = "byteArray";
    public static inline var ASSET_MANAGER : String = "assetManager";

    public static function fromAsset(asset : Dynamic) : String
    {
        if (Std.is(asset, BitmapData))
        {
            return TEXTURE;
        }
        else if (Std.is(asset, TextureAtlas))
        {
            return TEXTURE_ATLAS;
        }
        else if (Std.is(asset, Sound))
        {
            return SOUND;
        }
        else if (Std.is(asset, ByteArrayData))
        {
            return BYTE_ARRAY;
        }
        else if (Std.is(asset, AssetManager))
        {
            return ASSET_MANAGER;
        }
        else
        {
            return OBJECT;
        }
    }
}

