package animateAtlasPlayer.assets;

import animateAtlasPlayer.core.Animation;
import animateAtlasPlayer.core.AnimationAtlas;
import animateAtlasPlayer.core.AnimationAtlasFactory;
import animateAtlasPlayer.textures.TextureAtlas;
import animateAtlasPlayer.utils.ArrayUtil;
import haxe.Json;
import haxe.io.Bytes;
import haxe.io.BytesInput;
import haxe.zip.Entry;
import haxe.zip.Reader;
import lime.app.Future;
import openfl.Assets;
import openfl.display.BitmapData;
import openfl.events.Event;
import openfl.events.EventDispatcher;
import openfl.utils.ByteArray;

class AssetManager extends EventDispatcher
{

	public var verbose(get, set) : Bool;
	public var numQueuedAssets(get, never) : Int;
	public var numConnections(get, set) : Int;
	//public var textureOptions(get, set) : TextureOptions;
	//public var dataLoader(get, set) : DataLoader;
	public var registerBitmapFontsWithFontFace(get, set) : Bool;

	//private var _animateAtlasPlayer : animateAtlasPlayer;
	private var _assets : Map<String,Map<String,Dynamic>>;
	private var _verbose : Bool;
	private var _numConnections : Int;
	//private var _dataLoader : DataLoader;
	//private var _textureOptions : TextureOptions;
	private var _queue : Array<AssetReference>;
	private var _registerBitmapFontsWithFontFace : Bool;
	private var _assetFactories : Array<AssetFactory>;
	private var _numRestoredTextures : Int;
	private var _numLostTextures : Int;

	private static inline var NO_NAME : String = "unnamed";
	private static var sNoNameCount : Int = 0;

	private static var sNames : Array<String> = [];

	public function new(scaleFactor : Float = 1)
	{
		super();
		_assets = new Map<String,Map<String,Dynamic>>();
		_verbose = true;
		//_textureOptions = new TextureOptions(scaleFactor);
		_queue = new Array<AssetReference>();
		_numConnections = 3;
		//_dataLoader = new DataLoader();
		_assetFactories = [];

		//registerFactory(new BitmapTextureFactory());
		//registerFactory(new AtfTextureFactory());
		//registerFactory(new SoundFactory());
		registerFactory(new JsonFactory());
		//registerFactory(new XmlFactory());
		//registerFactory(new ByteArrayFactory(), -100);
		registerFactory(new AnimationAtlasFactory(), 10);
	}

	public function dispose() : Void
	{
		purgeQueue();

		for (store in _assets)
		{
			for (asset in store)
			{
				disposeAsset(asset);
			}
		}
	}

	public function purge() : Void
	{
		trace("Purging all assets, emptying queue");

		purgeQueue();
		dispose();

		_assets = new Map<String,Map<String,Dynamic>>();
	}

	public function purgeQueue() : Void
	{
		//as3hx.Compat.setArrayLength(_queue, 0);
		_queue = new Array<AssetReference>();
		//TODO dispatchEventWith(Event.CANCEL);
		dispatchEvent(new Event(Event.CANCEL));
	}

	public function enqueue(url : String) : Void
	{
		if (getExtensionFromUrl(url) == "zip")
		{
			trace ("TODO: zip package");
		}
		else {
			
			//TODO_2020: gerer la numérotation des spritemap
			
			enqueueSingle(url + "/spritemap1.png");
			enqueueSingle(url+"/spritemap1.json");
			/*if (Assets.exists(url + "/Animation.zip")) enqueueSingle(url+"/Animation.zip");
			else*/ enqueueSingle(url + "/Animation.json");	
		}
	}
	
	private function enqueueSingle(url : String, name : String = null/*, options : TextureOptions = null*/) : String
	{
		var extension:String = getExtensionFromUrl(url);
		var assetReference : AssetReference = new AssetReference();
		assetReference.url = url;
		assetReference.extension = extension;
		if (name != null) assetReference.name = name;
		else {
			assetReference.name =  getNameFromUrl(url);
			if (assetReference.extension == "png") assetReference.name=StringTools.replace(assetReference.name, AnimationAtlasFactory.SPRITEMAP_SUFFIX, "");
		}

		// assetReference.textureOptions = options || _textureOptions;

		_queue.push(assetReference);
		trace("Enqueuing '" + assetReference.filename);
		return assetReference.name;
	}

	private var index:Int;
	private var onCompleteCallback:AssetManager->Void;
	private var onErrorCallback:String->Void;
	private var onProgressCallback:Int->Int->Void;

	public function loadQueue(onComplete : AssetManager->Void, onError : Dynamic = null, onProgress : Dynamic = null) : Void
	{
		onCompleteCallback = onComplete;
		onErrorCallback = onError==null ? onDefaultErrorCallback : onError;
		onProgressCallback = onProgress==null ? onDefaultProgressCallback : onProgress ;
		index = 0;
		loadSingle();
	}
	
	private function onDefaultProgressCallback (pLoaded:Int, pTotalToLoad:Int):Void {
		trace (pLoaded, pTotalToLoad);
	};
	
	private function onDefaultErrorCallback (pError:String):Void {
		throw pError;
	};
	
	private function loadSingle() : Void
	{
		if (index >= _queue.length) {
			onSingleProgress(100, 100);
			onLoadComplete();
		}
		else{
			var assetReference : AssetReference = _queue[index]; 
			if (assetReference.extension == "zip") {
				Assets.loadBytes(assetReference.url).onComplete(onSingleComplete).onError(onErrorCallback).onProgress(onSingleProgress);
			}
			else if (assetReference.extension == "json")  Assets.loadText(assetReference.url).onComplete(onSingleComplete).onError(onErrorCallback).onProgress(onSingleProgress);
			else Assets.loadBitmapData(assetReference.url).onComplete(onSingleComplete).onError(onErrorCallback).onProgress(onSingleProgress);
		};
	}
	
	private function onSingleProgress(pLoaded:Int, pTotalToLoad:Int):Void {
			var lCurrentLoad:Float = pLoaded / pTotalToLoad;
			var lProgressForOneSingle:Float = 1 / _queue.length;
			var lProgress:Int = Math.floor(((index - 1) * lProgressForOneSingle + lProgressForOneSingle * lCurrentLoad) * 100);
			onProgressCallback(lProgress, 100);	
	}
	
	private function onSingleComplete (pData:Dynamic) :Void 
	{
		var data;
		
		if (Std.is(pData, ByteArrayData)) {
			var entries:List<Entry> = Reader.readZip(new BytesInput(pData));
			var bad:ByteArrayData = new ByteArrayData();
			var entry:Entry = entries.first();
			
			if (entry.compressed) {
				bad = new ByteArrayData();
				bad.writeBytes(entry.data);
				bad.inflate();
				data = Json.parse(bad.toString());
			} else data = Json.parse(entry.data.toString());
		}
		else if (Std.is(pData, String))  data = Json.parse(pData);
		else data=pData;

		var assetReference : AssetReference = _queue[index];
		assetReference.data = data;
		
		if (assetReference.extension=="zip") assetReference.extension = "json";

		trace("'" + assetReference.filename + " loaded'");
		
		index++;
		loadSingle();

	}
	
	private function onLoadComplete ():Void {
		var asset:AssetReference;
		for (i in 0..._queue.length)
		{
			asset = _queue[i];
			var assetFactory : AssetFactory = getFactoryFor(asset);
			if (assetFactory == null)
			{
				trace("Warning: no suitable factory found for '" + asset.name + "'");
			}
			else
			{
				assetFactory.create(asset, this/*, helper, onComplete, onCreateError*/);
			}
		}
		
		_queue = [];
		index = 0;
		
		onCompleteCallback(this);
	}
	
	

	private function getFactoryFor(asset : AssetReference) : AssetFactory
	{
		var lFactory:AssetFactory = asset.extension == "json" ? new AnimationAtlasFactory() : new BitmapTextureFactory();
		return lFactory;
	}

	public function addAsset(name : String, asset : Dynamic, type : String = null) : Void
	{

		if (type == null && Std.isOfType(asset, AnimationAtlas))
		{
			type = AnimationAtlas.ASSET_TYPE;
		}

		type = (type != null) ? type : AssetType.fromAsset(asset);

		var store : Map<String,Dynamic> = _assets[type];
		if (store == null)
		{
			store = new Map<String,Dynamic>();
			_assets[type] = store;
		}

		trace("Adding " + type + " '" + name + "'");

		var prevAsset : Map<String,Dynamic> = store[name];
		if (prevAsset != null && prevAsset != asset)
		{
			trace("Warning: name was already in use; disposing the previous " + type);
			disposeAsset(prevAsset);
		}

		store[name] = asset;
	}

	public function getAnimationAtlas(name : String) : AnimationAtlas
	{
		return cast getAsset(AnimationAtlas.ASSET_TYPE, name);
	}

	public function getAnimationAtlasNames(prefix : String = "", out : Array<String> = null) : Array<String>
	{
		return getAssetNames(AnimationAtlas.ASSET_TYPE, prefix, true, out);
	}

	public function createAnimation(name : String) : Animation
	{

		var atlasNames : Array<String> = getAnimationAtlasNames("", sNames);
		var animation : Animation = null;
		for (atlasName in atlasNames)
		{
			var atlas : AnimationAtlas = getAnimationAtlas(atlasName);
			if (atlas.hasAnimation(name))
			{
				animation = atlas.createAnimation(name);
				break;
			}
		}

		sNames = [];
		animation.name = name;
		
		return animation;
	}

	public function getAsset(type : String, name : String, recursive : Bool = true) : Dynamic
	{

		if (recursive)
		{

			var managerStore : Map<String,Dynamic> = _assets[AssetType.ASSET_MANAGER];
			if (managerStore != null)
			{
				for (manager in managerStore)
				{
					var asset : Dynamic = manager.getAsset(type, name, true);
					if (asset != null)
					{
						return asset;
					}
				}
			}

			if (type == AssetType.TEXTURE)
			{
				var atlasStore : Map<String,Dynamic> = _assets[AssetType.TEXTURE_ATLAS];
				if (atlasStore != null)
				{
					for (atlas in atlasStore)
					{
						var texture : BitmapData = atlas.getTexture(name);
						if (texture != null)
						{
							return texture;
						}
					}
				}
			}
		}

		var store : Map<String,Dynamic> = _assets[type];
		if (store != null) return store[name];
		else return null;

	}

	public function getAssetNames(assetType : String, prefix : String = "", recursive : Bool = true,
								  out : Array<String> = null) : Array<String>
	{
		out = (out != null) ? out : new Array<String>();

		if (recursive)
		{
			var managerStore : Map<String,Dynamic> = _assets[AssetType.ASSET_MANAGER];
			if (managerStore != null)
			{
				for (manager in managerStore)
				{
					manager.getAssetNames(assetType, prefix, true, out);
				}
			}

			if (assetType == AssetType.TEXTURE)
			{
				var atlasStore : Map<String,Dynamic> = _assets[AssetType.TEXTURE_ATLAS];
				if (atlasStore != null)
				{
					for (atlas in atlasStore)
					{
						atlas.getNames(prefix, out);
					}
				}
			}
		}

		getDictionaryKeys(_assets[assetType], prefix, out);
		out.sort(ArrayUtil.CASEINSENSITIVE);

		return out;
	}

	public function getTexture(name : String) : BitmapData
	{
		return cast getAsset(AssetType.TEXTURE, name);
	}

	public function getTextures(prefix : String = "", out : Array<BitmapData> = null) : Array<BitmapData>
	{
		if (out == null)
		{
			out = [];
		}

		for (name in getTextureNames(prefix, sNames))
		{
			out[out.length] = getTexture(name);
		}  // avoid 'push'

		sNames = [];
		return out;
	}

	public function getTextureNames(prefix : String = "", out : Array<String> = null) : Array<String>
	{
		return getAssetNames(AssetType.TEXTURE, prefix, true, out);
	}

	public function getTextureAtlas(name : String) : TextureAtlas
	{
		return cast getAsset(AssetType.TEXTURE_ATLAS, name);
	}

	public function getTextureAtlasNames(prefix : String = "", out : Array<String> = null) : Array<String>
	{
		return getAssetNames(AssetType.TEXTURE_ATLAS, prefix, true, out);
	}

	public function getObject(name : String) : Dynamic
	{
		return getAsset(AssetType.OBJECT, name);
	}

	public function getObjectNames(prefix : String = "", out : Array<String> = null) : Array<String>
	{
		return getAssetNames(AssetType.OBJECT, prefix, true, out);
	}

	public function getByteArray(name : String) : ByteArray
	{
		return cast getAsset(AssetType.BYTE_ARRAY, name);
	}

	public function getByteArrayNames(prefix : String = "", out : Array<String> = null) : Array<String>
	{
		return getAssetNames(AssetType.BYTE_ARRAY, prefix, true, out);
	}

	public function getAssetManager(name : String) : AssetManager
	{
		return cast getAsset(AssetType.ASSET_MANAGER, name);
	}

	public function getAssetManagerNames(prefix : String = "", out : Array<String> = null) : Array<String>
	{
		return getAssetNames(AssetType.ASSET_MANAGER, prefix, true, out);
	}

	public function registerFactory(factory : AssetFactory, priority : Int = 0) : Void
	{
		factory.priority = priority;

		_assetFactories.push(factory);
		_assetFactories.sort(comparePriorities);
	}

	private static function comparePriorities(a : Dynamic, b : Dynamic) : Int
	{
		if (a.priority == b.priority)
		{
			return 0;
		}
		return (a.priority > b.priority) ? -1 : 1;
	}

	private function getNameFromUrl(url : String) : String
	{
		var separator : String = "/";
		var elements : Array<Dynamic> = url.split(separator);
		var folderName : String = elements[elements.length - 2];
		var fileName : String = elements[elements.length - 1];
		var suffix : String = fileName.indexOf("Animation")==0 ? AnimationAtlasFactory.ANIMATION_SUFFIX : AnimationAtlasFactory.SPRITEMAP_SUFFIX;
		return folderName+suffix;
	}

	private function getExtensionFromUrl(url : String) : String
	{
		if (url != null)
		{
			return url.split("?")[0].split(".").pop();
		}

		return "";
	}

	private function disposeAsset(asset:Dynamic):Void
	{
		if (Reflect.hasField(asset,"dispose")) Reflect.field(asset,"dispose")();
	}

	private static function getDictionaryKeys(dictionary : Map<String,Dynamic>, prefix : String = "", out : Array<String> = null) : Array<String>
	{
		if (dictionary != null)
		{
			for (name in dictionary.keys())
			{
				if (name.indexOf(prefix) == 0)
				{
					out[out.length] = name;
				}
			}  // avoid 'push'

			out.sort(ArrayUtil.CASEINSENSITIVE);
		}
		return out;
	}

	private static function getUniqueName() : String
	{
		return NO_NAME + "-" + sNoNameCount++;
	}

	private function get_verbose() : Bool
	{
		return _verbose;
	}
	private function set_verbose(value : Bool) : Bool
	{
		_verbose = value;
		return value;
	}

	private function get_numQueuedAssets() : Int
	{
		return _queue.length;
	}

	private function get_numConnections() : Int
	{
		return _numConnections;
	}
	private function set_numConnections(value : Int) : Int
	{
		_numConnections = Std.int(Math.min(1, value));
		return value;
	}

	private function get_registerBitmapFontsWithFontFace() : Bool
	{
		return _registerBitmapFontsWithFontFace;
	}

	private function set_registerBitmapFontsWithFontFace(value : Bool) : Bool
	{
		_registerBitmapFontsWithFontFace = value;
		return value;
	}
}

class AssetPostProcessor
{
	public var priority(get, never) : Int;

	private var _priority : Int;
	private var _callback : Dynamic;

	public function new(callback : Dynamic, priority : Int)
	{
		//TODO:
		//if (callback == null || as3hx.Compat.getFunctionLength(callback) != 1)
		//{
		//throw new ArgumentError("callback must be a function " +
		//"accepting one 'AssetStore' parameter");
		//}

		_callback = callback;
		_priority = priority;
	}

	@:allow(animateAtlasPlayer.assets.AssetManager)
	private function execute(store : AssetManager) : Void
	{
		_callback(store);
	}

	private function get_priority() : Int
	{
		return _priority;
	}

}