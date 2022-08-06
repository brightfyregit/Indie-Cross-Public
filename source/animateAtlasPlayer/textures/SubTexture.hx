package animateAtlasPlayer.textures;
import openfl.geom.Point;
import openfl.display.BitmapData;
import openfl.geom.Matrix;
import openfl.geom.Rectangle;
import openfl.system.Capabilities;

class SubTexture extends BitmapData
{
    public var parent(get, never) : BitmapData;
    public var ownsParent(get, never) : Bool;
    public var rotated(get, never) : Bool;
    public var region(get, never) : Rectangle;

    private var _parent : BitmapData;
    private var _ownsParent : Bool;
    private var _region : Rectangle;
    private var _frame : Rectangle;
    private var _rotated : Bool;
    private var _width : Float;
    private var _height : Float;
    private var _scale : Float;
    private var _transformationMatrix : Matrix;
    private var _transformationMatrixToRoot : Matrix;
    
    private static inline var E : Float = 0.000001;
    
    public function new(parent : BitmapData, region : Rectangle = null, ownsParent : Bool = false, frame : Rectangle = null,rotated : Bool = false, scaleModifier : Float = 1)
    {
		super(Std.int(region.width), Std.int(region.height));
		//floodFill(0, 0, 0xFF00FF);
		copyPixels(parent, region, new Point());
		//TODO: traiter les autres parametres
    }
    
    private function setTo(parent : BitmapData, region : Rectangle = null,
            ownsParent : Bool = false, frame : Rectangle = null,
            rotated : Bool = false, scaleModifier : Float = 1) : Void
    {
        if (_region == null)
        {
            _region = new Rectangle();
        }
        if (region != null)
        {
            _region.copyFrom(region);
        }
        else
        {
            _region.setTo(0, 0, parent.width, parent.height);
        }
        
        if (frame != null)
        {
            if (_frame != null)
            {
                _frame.copyFrom(frame);
            }
            else
            {
                _frame = frame.clone();
            }
        }
        else
        {
            _frame = null;
        }
        
        _parent = parent;
        _ownsParent = ownsParent;
        _rotated = rotated;
        _width = ((rotated) ? _region.height : _region.width) / scaleModifier;
        _height = ((rotated) ? _region.width : _region.height) / scaleModifier;
        //TODO: _scale = _parent.scale * scaleModifier;
        
        if (Capabilities.isDebugger && _frame != null && (_frame.x > 0 || _frame.y > 0 ||
            _frame.right + E < _width || _frame.bottom + E < _height))
        {
            trace("[animateAtlasPlayer] Warning: frames inside the texture's region are unsupported.");
        }
        
        updateMatrices();
    }
    
    private function updateMatrices() : Void
    {
        if (_transformationMatrix != null)
        {
            _transformationMatrix.identity();
        }
        else
        {
            _transformationMatrix = new Matrix();
        }
        
        if (_transformationMatrixToRoot != null)
        {
            _transformationMatrixToRoot.identity();
        }
        else
        {
            _transformationMatrixToRoot = new Matrix();
        }
        
        if (_rotated)
        {
            _transformationMatrix.translate(0, -1);
            _transformationMatrix.rotate(Math.PI / 2.0);
        }
        
        _transformationMatrix.scale(_region.width / _parent.width, 
                _region.height / _parent.height
        );
        _transformationMatrix.translate(_region.x / _parent.width, 
                _region.y / _parent.height
        );
        
        var texture : SubTexture = this;
        while (texture!=null)
        {
            _transformationMatrixToRoot.concat(texture._transformationMatrix);
            texture = try cast(texture.parent, SubTexture) catch(e:Dynamic) null;
        }
    }
    
    override public function dispose() : Void
    {
        if (_ownsParent)
        {
            _parent.dispose();
        }
        super.dispose();
		
    }

    private function get_parent() : BitmapData
    {
        return _parent;
    }

    private function get_ownsParent() : Bool
    {
        return _ownsParent;
    }
    
    private function get_rotated() : Bool
    {
        return _rotated;
    }
    
    private function get_region() : Rectangle
    {
        return _region;
    }
    
}
