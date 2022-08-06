package animateAtlasPlayer.core;

import animateAtlasPlayer.textures.TextureAtlas;
import animateAtlasPlayer.utils.ArrayUtil;
import openfl.display.Bitmap;
import openfl.display.BitmapData;

typedef Frame = {
	var name: String;
	var I: Int;
	var DU: Int;
	var E: Array<Dynamic>;
}

typedef LayerData = {
	var LN: String;
	@:optional var Layer_type: String;
	@:optional var Clipped_by: String;
	var FR: Array<Frame>;
}

typedef Timeline = {
	var L : Array<LayerData>;
	@optional var sortedForRender:Bool;
}

typedef SymbolData = {
	var SN: String;
	@:optional var IN: String;
	var TL: Timeline;
	var M3D:Dynamic;
	var bitmap:Dynamic;
	@:optional var C:Dynamic;
	@:optional var LP:Dynamic;
	var ST:String;
	@:optional var FF:Int;
}

typedef SymbolDictionnary = {
	var S : Array<SymbolData>;
}

typedef MetaData = {
	var FRT : Int;
}

typedef AnimationJson = {
  var AN : Dynamic;
  var SD : SymbolDictionnary;
  var MD : MetaData;
}

class AnimationAtlas
{
    public var frameRate(get, set) : Float;

    public static inline var ASSET_TYPE : String = "animationAtlas";
    
    private var _atlas : TextureAtlas;
    private var _symbolData : Map<String,Dynamic>;
    private var _symbolPool : Dynamic;
    private var _imagePool : Array<Dynamic>;
    private var _frameRate : Float;
    private var _defaultSymbolName : String;
    
    private static var STD_MATRIX3D_DATA : Dynamic = {
            m00 : 1,
            m01 : 0,
            m02 : 0,
            m03 : 0,
            m10 : 0,
            m11 : 1,
            m12 : 0,
            m13 : 0,
            m20 : 0,
            m21 : 0,
            m22 : 1,
            m23 : 0,
            m30 : 0,
            m31 : 0,
            m32 : 0,
            m33 : 1
        };
    
	public function new(data : Dynamic, atlas : TextureAtlas)
    {
        parseData(data);
        
        _atlas = atlas;
        _symbolPool = {};
        _imagePool = [];
    }
    
    public function hasAnimation(name : String) : Bool
    {
        return hasSymbol(name);
    }
    
    public function createAnimation(name : String = null) : Animation
    {
        name = name != null ? name : _defaultSymbolName;
		
        if (!hasSymbol(name))
        {
			throw "Animation not found: " + name;
        }
		
        return new Animation(getSymbolData(name), this);
    }
    
    public function getAnimationNames(prefix : String = "", out : Array<String> = null) : Array<String>
    {
        out = (out != null) ? out : new Array<String>();
        
        for (name in Reflect.fields(_symbolData))
        {
            if (name != Symbol.BITMAP_SYMBOL_NAME && name.indexOf(prefix) == 0)
            {
                out[out.length] = name;
            }
        }
        
        out.sort(ArrayUtil.CASEINSENSITIVE);
        return out;
    }
    
    // pooling
    
    @:allow(animateAtlasPlayer.core)
    private function getTexture(name : String) : BitmapData
    {
		return _atlas.getTexture(name);
    }
    
    @:allow(animateAtlasPlayer.core)
    private function getImage(texture : BitmapData) : Bitmap
    {

		if (_imagePool.length == 0)
        {
            return new Bitmap(texture);
        }
        else
        {
            var image : Bitmap = cast _imagePool.pop();
            image.bitmapData = texture;
            //TODO: image.readjustSize();
            return image;
        }
    }
    
    @:allow(animateAtlasPlayer.core)
    private function putImage(image : Bitmap) : Void
    {
        _imagePool[_imagePool.length] = image;
    }
    
    @:allow(animateAtlasPlayer.core)
    private function hasSymbol(name : String) : Bool
    {
        return _symbolData[name]!=null;
    }
    
    @:allow(animateAtlasPlayer.core)
    private function getSymbol(name : String) : Symbol
    {
        var pool : Array<Dynamic> = getSymbolPool(name);
        if (pool.length == 0)
        {
			return new Symbol(getSymbolData(name), this);
        }
        else
        {
            return pool.pop();
        }
    }
    
    @:allow(animateAtlasPlayer.core)
    private function putSymbol(symbol : Symbol) : Void
    {
        symbol.reset();
        var pool : Array<Dynamic> = getSymbolPool(symbol.symbolName);
        pool[pool.length] = symbol;
        symbol.currentFrame = 0;
    }
    
    // helpers
    
    private function parseData(data : AnimationJson) : Void
    {
        var metaData : MetaData = data.MD;
        
        if (metaData != null && metaData.FRT > 0)
        {
            _frameRate = metaData.FRT;
        }
        else
        {
            _frameRate = 24;
        }
		//TODO2020: bug pas compris
        //_symbolData = new Map<String,SymbolData>();
        _symbolData = new Map<String,Dynamic>();
        
        // the actual symbol dictionary
        for (symbolData in data.SD.S)
        {
			_symbolData[symbolData.SN]=preprocessSymbolData(symbolData);
        }
        
        // the main animation
        var defaultSymbolData : SymbolData = preprocessSymbolData(data.AN);
        _defaultSymbolName = defaultSymbolData.SN;
        _symbolData[_defaultSymbolName]= defaultSymbolData;

        // a purely internal symbol for bitmaps - simplifies their handling		
		_symbolData[Symbol.BITMAP_SYMBOL_NAME]=	{
                    SN : Symbol.BITMAP_SYMBOL_NAME,
                    TL : {
                        L : []
                    }
                };	
				
    }
    
    private static function preprocessSymbolData(symbolData : SymbolData) : Dynamic
    {
        var timeLineData : Timeline = symbolData.TL;
        var layerDates : Array<LayerData> = timeLineData.L;
        
        // In Animate CC, layers are sorted front to back.
        // In animateAtlasPlayer, it's the other way round - so we simply reverse the layer data.
       // TODO: voir s'il faut faire comme animateAtlasPlayer 	
		
        if (!Reflect.hasField(timeLineData,"sortedForRender"))
        {
            timeLineData.sortedForRender = true;
            layerDates.reverse();
        }
        
        // We replace all "ATLAS_SPRITE_instance/ASI" elements with symbols of the same contents.
        // That way, we are always only dealing with symbols.
        
        var numLayers : Int = layerDates.length;
        
        for (l in 0...numLayers)
        {
            var layerData : LayerData = layerDates[l];
            var frames : Array<Frame> = cast layerData.FR;
            var numFrames : Int = frames.length;
			var lBitmap:Dynamic;
            
            for (f in 0...numFrames)
            {
                var elements : Array<Dynamic> = cast frames[f].E;
                var numElements : Int = elements.length;
                
                for (e in 0...numElements)
                {
                    var element : Dynamic = elements[e];
                    
                    if (Reflect.hasField(element, "ASI"))
                    {
                        lBitmap = element.ASI;
						lBitmap.M3D = expandMatrix(lBitmap.M3D);
						
						element = elements[e] = {
                                            SI : {
                                                SN : Symbol.BITMAP_SYMBOL_NAME,
                                                Instance_Name : "InstName",
                                                bitmap : lBitmap,
                                                symbolType : SymbolType.GRAPHIC,
                                                firstFrame : 0,
                                                loop : LoopMode.LOOP,
                                                TRP : {
                                                    x : 0,
                                                    y : 0
                                                },
                                                M3D : STD_MATRIX3D_DATA
                                            }
                                        };
                    } else {
						element.SI.M3D=expandMatrix(element.SI.M3D);

					}
                    
                    // not needed - remove decomposed matrix to save some memory
                    element.SI.DecomposedMatrix=null;
                }
            }
        }
        
        return symbolData;
    }
	
	private static function expandMatrix (pMatrix:Array<Float>) : Dynamic {
		return {
			m00 : pMatrix[0],
			m01 : pMatrix[1],
			m02 : pMatrix[2],
			m03 : pMatrix[3],
			m10 : pMatrix[4],
			m11 : pMatrix[5],
			m12 : pMatrix[6],
			m13 : pMatrix[7],
			m20 : pMatrix[8],
			m21 : pMatrix[9],
			m22 : pMatrix[10],
			m23 : pMatrix[11],
			m30 : pMatrix[12],
			m31 : pMatrix[13],
			m32 : pMatrix[14],
			m33 : pMatrix[15]
		}
	}
    
    private function getSymbolData(name : String) : Dynamic
    {
        return _symbolData[name];
    }
    
    public function getSymbolPool(name : String) : Array<Dynamic>
    {
        var pool : Array<Dynamic> = Reflect.field(_symbolPool, name);
        if (pool == null)
        {
            Reflect.setField(_symbolPool, name, []);
			pool = Reflect.field(_symbolPool, name);
        }
        return pool;
    }
    
    // properties
    
    private function get_frameRate() : Float
    {
        return _frameRate;
    }
    private function set_frameRate(value : Float) : Float
    {
        _frameRate = value;
        return value;
    }
	
	public function toString () : String {
		return "[Object " +Type.getClassName(Type.getClass(this)).split(".").pop() + "]";
	}
}

