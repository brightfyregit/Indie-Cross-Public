package animateAtlasPlayer.assets;

class BitmapTextureFactory extends AssetFactory
{
    public function new()
    {
        super();
        //addMimeTypes("image/png", "image/jpg", "image/jpeg", "image/gif");
        addExtensions("png");
    }

    override public function create(reference : AssetReference,assets:AssetManager/*, helper : AssetFactoryHelper,
            onComplete : Function, onError : Function*/) : Void
    {
		assets.addAsset(reference.name, reference.data);
		

    }
	
}

