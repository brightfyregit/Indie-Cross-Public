package animateAtlasPlayer.assets;

class AssetReference
{
    public var name(get, set) : String;
    public var url(get, set) : String;
    public var data(get, set) : Dynamic;
    public var mimeType(get, set) : String;
    public var extension(get, set) : String;
    //public var textureOptions(get, set) : TextureOptions;
    @:allow(animateAtlasPlayer.assets)
	private var filename(get, never) : String;

    private var _name : String;
    private var _url : String;
    private var _data : Dynamic;
    private var _mimeType : String;
    private var _extension : String;

    public function new(data : Dynamic=null)
    {
        _data = data;
        //_textureOptions = new TextureOptions();
        
        //if (Std.is(data, String))
        //{
            //_url = Std.string(data);
        //}
        //else if (Lambda.has(data, "url"))
        //{
            //_url = Std.string(Reflect.field(data, "url"));
        //}
    }

    private function get_name() : String
    {
        return _name;
    }
    private function set_name(value : String) : String
    {
        _name = value;
        return value;
    }

    private function get_url() : String
    {
        return _url;
    }
    private function set_url(value : String) : String
    {
        _url = value;
        return value;
    }

    private function get_data() : Dynamic
    {
        return _data;
    }
    private function set_data(value : Dynamic) : Dynamic
    {
        _data = value;
        return value;
    }

    private function get_mimeType() : String
    {
        return _mimeType;
    }
    private function set_mimeType(value : String) : String
    {
        _mimeType = value;
        return value;
    }

    private function get_extension() : String
    {
        return _extension;
    }
    private function set_extension(value : String) : String
    {
        _extension = value;
        return value;
    }
    
    private function get_filename() : String
    {
        if (name != null && extension != null && extension != "")
        {
            return name + "." + extension;
        }
        else if (name != null)
        {
            return name;
        }
        else
        {
            return null;
        }
    }
}

