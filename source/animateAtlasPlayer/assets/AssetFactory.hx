package animateAtlasPlayer.assets;
import openfl.system.Capabilities;

class AssetFactory
{
	@:allow(animateAtlasPlayer.assets)
    private var priority(get, set) : Int;

    private var _priority : Int;
    private var _mimeTypes : Array<String>;
    private var _extensions : Array<String>;
    
    /** Creates a new instance. */
    public function new()
    {
        if (Capabilities.isDebugger &&
            Type.getClassName(Type.getClass(this)) == "animateAtlasPlayer.assets::AssetFactory")
        {
            // TODO
			throw "new AbstractClassError();";
        }
        
        _mimeTypes = [];
        _extensions = [];
    }
    
    public function create(reference : AssetReference,assets:AssetManager/*, helper : AssetFactoryHelper,
            onComplete : Function, onError : Function*/) : Void
    {  // to be implemented by subclasses  
       
    }

    public function addMimeTypes(args : Array<Dynamic> = null) : Void
    {
        for (mimeType in args)
        {
            mimeType = mimeType.toLowerCase();
            
            if (Lambda.indexOf(_mimeTypes, mimeType) == -1)
            {
                _mimeTypes[_mimeTypes.length] = mimeType;
            }
        }
    }

    public function addExtensions(arg) : Void
    {
            var extension:String = arg.toLowerCase();
            
            if (Lambda.indexOf(_extensions, extension) == -1)
            {
                _extensions[_extensions.length] = extension;
            }
    }

    public function getMimeTypes(out : Array<String> = null) : Array<String>
    {
        out = (out != null) ? out : new Array<String>();
        
        for (i in 0..._mimeTypes.length)
        {
            out[i] = _mimeTypes[i];
        }
        
        return out;
    }

    public function getExtensions(out : Array<String> = null) : Array<String>
    {
        out = (out != null) ? out : new Array<String>();
        
        for (i in 0..._extensions.length)
        {
            out[i] = _extensions[i];
        }
        
        return out;
    }
    
    private function get_priority() : Int
    {
        return _priority;
    }

    private function set_priority(value : Int) : Int
    {
        _priority = value;
        return value;
    }
	
	public function toString () : String {
		return "[Object " +Type.getClassName(Type.getClass(this)).split(".").pop() + "]";
	}
}

