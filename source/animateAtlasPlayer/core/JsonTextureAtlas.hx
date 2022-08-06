package animateAtlasPlayer.core;

import animateAtlasPlayer.textures.SubTexture;
import animateAtlasPlayer.textures.TextureAtlas;
import openfl.display.BitmapData;
import openfl.geom.Rectangle;

typedef SpriteDef = {
	var name : String;
	var x : Int;
	var y : Int;
	var w : Int;
	var h : Int;
	var rotated : Bool;
}

typedef SpriteCell = {
	var SPRITE: SpriteDef;
}

typedef Sprites = {
	var SPRITES: Array<SpriteCell>;
}

typedef Spritemap = {
  var ATLAS : Sprites;
  var meta : String;
  var app : String;
  var version : String;
  var image : String;
  var format : String;
  var size : Dynamic;
  var scale : String;
}

class JsonTextureAtlas extends TextureAtlas
{
    
	private static var helperRectangle:Rectangle = new Rectangle();
	
	public function new(texture : BitmapData, data : Dynamic = null)
    {
        super(texture, data);
    }
    
    override private function parseAtlasData(data : Dynamic) : Void
    {
        parseAtlasJson(data);

    }
    
    private function parseAtlasJson(data : Spritemap) : Void
    {
        var region : Rectangle = helperRectangle;
		
		
        for (element in data.ATLAS.SPRITES)
        {
			var node : SpriteDef = element.SPRITE;
            region.setTo(node.x, node.y, node.w, node.h);
 			addSubTexture(node.name, new SubTexture(texture, region, false, null, node.rotated));
        }

    }

}