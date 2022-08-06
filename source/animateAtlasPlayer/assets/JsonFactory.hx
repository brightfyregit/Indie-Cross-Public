package animateAtlasPlayer.assets;
import animateAtlasPlayer.assets.AssetReference;

class JsonFactory extends AssetFactory
{
    public function new()
    {
        super();
        addExtensions("json");
        //TODO ? addMimeTypes("application/json", "text/json");
    }
    
    /** @inheritDoc */
    override public function create(reference : AssetReference,assets:AssetManager/*, helper : AssetFactoryHelper, onComplete : Function, onError : Function*/) : Void
    {	
			//try
            //{
                //var bytes:ByteArray = reference.data as ByteArray;
                //var object:Object = JSON.parse(bytes.readUTFBytes(bytes.length));
                //onComplete(reference.name, object);
            //}
            //catch (e:Error)
            //{
                //onError("Could not parse JSON: " + e.message);
            //}
    }
}

