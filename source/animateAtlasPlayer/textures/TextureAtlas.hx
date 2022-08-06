package animateAtlasPlayer.textures;
import animateAtlasPlayer.textures.SubTexture;
import animateAtlasPlayer.utils.ArrayUtil;
import openfl.display.BitmapData;
import openfl.geom.Rectangle;

class TextureAtlas
{
    public var texture(get, never) : BitmapData;

    private static var NAME_REGEX : EReg = new EReg('(.+?)\\d+$', "");  // find text before trailing digits  
    
    private var _atlasTexture : BitmapData;
    private var _subTextures : Map<String,SubTexture>;
    private var _subTextureNames : Array<String>;
    
    private static var sNames : Array<String> = [];
    
    public function new(texture : BitmapData, data : Dynamic = null)
    {
        _subTextures = new Map<String,SubTexture>();
        _atlasTexture = texture;
        
        if (data != null)
        {
            parseAtlasData(data);
        }
    }
    
    public function dispose() : Void
    {
        _atlasTexture.dispose();
    }
    
    private function parseAtlasData(data : Dynamic) : Void
    {
        //if (Std.is(data, FastXML))
        //{
            //parseAtlasXml(try cast(data, FastXML) catch(e:Dynamic) null);
        //}
        //else
        //{
            //throw new ArgumentError("TextureAtlas only supports XML data");
        //}
    }
	
    public function getTexture(name : String) : BitmapData
    {
		return _subTextures[name];
    }
    
    public function getTextures(prefix : String = "", out : Array<BitmapData> = null) : Array<BitmapData>
    {
        if (out == null)
        {
            out = [];
        }
        
        for (name in getNames(prefix, sNames))
        {
            out[out.length] = getTexture(name);
        }  // avoid 'push'  
        
		sNames = [];
        return out;
    }
    
    public function getNames(prefix : String = "", out : Array<String> = null) : Array<String>
    {
        var name : String;
        if (out == null)
        {
            out = [];
        }
        
        if (_subTextureNames == null) {
        
			// optimization: store sorted list of texture names
            
            _subTextureNames = [];
            for (name in _subTextures.keys())
            {
                _subTextureNames[_subTextureNames.length] = name;
            }
            
			_subTextureNames.sort(ArrayUtil.CASEINSENSITIVE);
        }
        
        for (name in _subTextureNames)
        {
            if (name.indexOf(prefix) == 0)
            {
                out[out.length] = name;
            }
        }
        
        return out;
    }
    
    public function getRegion(name : String) : Rectangle
    {
        var subTexture : SubTexture = _subTextures[name];
        return (subTexture != null) ? subTexture.region : null;
    }
    
    public function getFrame(name : String) : Rectangle
    {
		//TODO:
		return null;
		//var subTexture : SubTexture = _subTextures[name];
        //return subTexture != null ? subTexture.frame : null;
    }
    
    public function getRotation(name : String) : Bool
    {
        var subTexture : SubTexture = _subTextures[name];
        return subTexture != null ? subTexture.rotated : false;
    }
    
    public function addRegion(name : String, region : Rectangle, frame : Rectangle = null, rotated : Bool = false) : Void
    {
		addSubTexture(name, new SubTexture(_atlasTexture, region, false, frame, rotated));
    }
    
    public function addSubTexture(name : String, subTexture : SubTexture) : Void
    {
		//TODO :
		//if (subTexture.root != _atlasTexture.root)
        //{
            //throw new ArgumentError("SubTexture's root must be atlas texture.");
        //}

        _subTextures[name]=subTexture;
        _subTextureNames = null;
    }
    
    public function removeRegion(name : String) : Void
    {
        var subTexture : SubTexture = _subTextures[name];
        if (subTexture != null)
        {
            subTexture.dispose();
        }
		_subTextures[name]=null;
        _subTextureNames = null;
    }
    
    private function get_texture() : BitmapData
    {
        return _atlasTexture;
    }
	
	public function toString () : String {
		return "[Object " +Type.getClassName(Type.getClass(this)).split(".").pop() + "]";
	}
}

