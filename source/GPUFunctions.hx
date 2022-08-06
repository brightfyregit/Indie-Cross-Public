package;

import flixel.FlxG;
import openfl.display.BitmapData;
import openfl.display3D.Context3DTextureFormat;
import openfl.display3D.textures.Texture;
import openfl.utils.Assets;

using StringTools;

/**
 * A class that works with GPU's VRAM.
 * thx smokey my man
 */
class GPUFunctions
{
	static var trackedTextures:Array<TexAsset> = new Array<TexAsset>();

	/**
	 * This function loads a bitmap and transfers it to the GPU's VRAM.
	 *
	 * @param   path                The file path.
	 * @param   texFormat           The texture format.
	 * @param   optimizeForRender   Keep this true. Always. Dumbass.
	 * @param   _cachekey            Key for the Texture Buffer cache. 
	 *
	 */
	public static function bitmapToGPU(path:String, texFormat:Context3DTextureFormat = BGRA, optimizeForRender:Bool = true, ?_cacheKey:String):BitmapData
	{
		if (_cacheKey == null)
			_cacheKey = path;

		for (tex in trackedTextures)
		{
			if (tex.cacheKey == _cacheKey)
			{
				return BitmapData.fromTexture(tex.texture);
			}
		}
		trace('Creating texture $_cacheKey');

		var _bmp = Assets.getBitmapData(path, false);
		var _texture = FlxG.stage.context3D.createTexture(_bmp.width, _bmp.height, texFormat, optimizeForRender);
		_texture.uploadFromBitmapData(_bmp);

		_bmp.dispose();
		_bmp.disposeImage();
		_bmp = null;

		var trackedTex = new TexAsset(_texture, _cacheKey);
		trackedTextures.push(trackedTex);

		return BitmapData.fromTexture(_texture);
	}

	/**

		* This function is planned to be used for Animate's texture atlases (WIP)
		*
		* @param   path                The file path.
		* @param   _width			   The width of the texture.
		* @param   _height  		   The height of the texture.
		* @param   texFormat           The texture format.
		* @param   optimizeForRender   Keep this true. Always. Dumbass.
		* @param   _cachekey           Key for the Texture Buffer cache. 
		*
	 */
	public static function ATFtoGPU(path:String, _width:Int, _height:Int, texFormat:Context3DTextureFormat = COMPRESSED_ALPHA, optimizeForRender:Bool = false,
			?_cachekey:String):BitmapData
	{
		if (_cachekey == null)
			_cachekey = path;

		for (tex in trackedTextures)
		{
			if (tex.cacheKey == _cachekey)
			{
				return BitmapData.fromTexture(tex.texture);
			}
		}


		var _texture = FlxG.stage.context3D.createTexture(_width, _height, texFormat, optimizeForRender);
		_texture.uploadCompressedTextureFromByteArray(Assets.getBytes(path), 0);

		var trackedTex = new TexAsset(_texture, _cachekey);
		trackedTextures.push(trackedTex);

		return BitmapData.fromTexture(_texture);
	}

	public static function disposeAllTextures():Void
	{
		var counter:Int = 0;

		for (texture in trackedTextures)
		{
			texture.texture.dispose();
			trackedTextures.remove(texture);
			counter++;
		}

	}

	public static function disposeTexturesByKey(key:String)
	{
		var counter:Int = 0;

		for (texture in trackedTextures)
		{
			if (texture.cacheKey.contains(key))
			{
				texture.texture.dispose();
				trackedTextures.remove(texture);
				counter++;
			}
		}

	}
}

class TexAsset
{
	public var texture:Texture;
	public var cacheKey:String;

	public function new(texture:Texture, cacheKey:String)
	{
		this.texture = texture;
		this.cacheKey = cacheKey;
	}
}
