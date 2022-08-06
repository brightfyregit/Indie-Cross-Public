import openfl.filters.ColorMatrixFilter;
import openfl.filters.BitmapFilter;
import flixel.FlxG;
import flixel.graphics.tile.FlxGraphicsShader;
import openfl.filters.ShaderFilter;
import flixel.system.FlxAssets.FlxShader;

class BloomHandler
{
	public static var bloomShader:ShaderFilter = new ShaderFilter(new Bloom());

	public static function setThreshold(value:Float)
		bloomShader.shader.data.threshold.value = [value];
	
	public static function setIntensity(value:Float)
		bloomShader.shader.data.intensity.value = [value];
	
	public static function setBlurSize(value:Float)
		bloomShader.shader.data.blurSize.value = [value];
}

class Bloom extends FlxShader
{
	@:glFragmentSource('
		#pragma header  

		uniform float threshold;
        uniform float intensity;
        uniform float blurSize;

        vec4 BlurColor (in vec2 Coord, in sampler2D Tex, in float MipBias)
        {
            vec2 TexelSize = MipBias / vec2(1280, 720);
            
            vec4 Color = texture(Tex, Coord, MipBias);
            
            for (int i = 0; i < 2; i++) {
                float mul = (float(i)+1.0) / 2.0;
                
                Color += texture(Tex, Coord + vec2(TexelSize.x*mul,0.0), MipBias);
                Color += texture(Tex, Coord + vec2(-TexelSize.x*mul,0.0), MipBias);
                Color += texture(Tex, Coord + vec2(0.0,TexelSize.y*mul), MipBias);
                Color += texture(Tex, Coord + vec2(0.0,-TexelSize.y*mul), MipBias);
                Color += texture(Tex, Coord + vec2(TexelSize.x*mul,TexelSize.y*mul), MipBias);
                Color += texture(Tex, Coord + vec2(-TexelSize.x*mul,TexelSize.y*mul), MipBias);
                Color += texture(Tex, Coord + vec2(TexelSize.x*mul,-TexelSize.y*mul), MipBias);
                Color += texture(Tex, Coord + vec2(-TexelSize.x*mul,-TexelSize.y*mul), MipBias);
            }

            return Color/17.0;
        }

        void main()
        {
            vec2 uv = openfl_TextureCoordv;
            vec4 Color = texture(bitmap, uv);

            if (intensity > 0.0)
            {
                vec4 Highlight = clamp(BlurColor(uv, bitmap, blurSize)-threshold,0.0,1.0)*1.0/(1.0-threshold);
                gl_FragColor = 1.0-(1.0-Color)*(1.0-Highlight*intensity);
            }
            else
            {
                gl_FragColor = Color;
            }
        }')
	
    public function new()
	{
		super();

        threshold.value = [0.4];
        intensity.value = [1.0];
        blurSize.value = [10.0];
	}
}





class BrightHandler
{
	public static var brightShader:ShaderFilter = new ShaderFilter(new Bright());

	public static function setBrightness(brightness:Float):Void
	{
		brightShader.shader.data.brightness.value = [brightness];
	}
	
	public static function setContrast(contrast:Float):Void
	{
		brightShader.shader.data.contrast.value = [contrast];
	}
}

class Bright extends FlxShader
{
	@:glFragmentSource('
		#pragma header

		uniform float brightness;
		uniform float contrast;

		void main()
		{
			vec4 col = texture2D(bitmap, openfl_TextureCoordv);
			col.rgb = col.rgb * contrast;
			col.rgb = col.rgb + brightness;

			gl_FragColor = col;
		}')
	public function new()
	{
		super();
	}
}





class ChromaHandler
{
	public static var chromaticAberration:ShaderFilter = new ShaderFilter(new ChromaticAberration());
	
	public static function setChrome(chromeOffset:Float):Void
	{
		chromaticAberration.shader.data.rOffset.value = [chromeOffset];
		chromaticAberration.shader.data.gOffset.value = [0.0];
		chromaticAberration.shader.data.bOffset.value = [chromeOffset * -1];
	}
}

class ChromaticAberration extends FlxShader
{
	@:glFragmentSource('
		#pragma header

		uniform float rOffset;
		uniform float gOffset;
		uniform float bOffset;

		void main()
		{
			vec4 col = vec4(1.0);
			
			col.r = texture2D(bitmap, openfl_TextureCoordv - vec2(rOffset, 0.0)).r;
			col.ga = texture2D(bitmap, openfl_TextureCoordv - vec2(gOffset, 0.0)).ga;
			col.b = texture2D(bitmap, openfl_TextureCoordv - vec2(bOffset, 0.0)).b;

			gl_FragColor = col;
		}')
	public function new()
	{
		super();

		rOffset.value = [0.0];
		gOffset.value = [0.0];
		bOffset.value = [0.0];
	}
}





class WhiteOverlayShader extends FlxGraphicsShader
{
	@:glFragmentSource("
	#pragma header

	uniform float progress;

	void main(void)
	{
		vec4 color = flixel_texture2D(bitmap, openfl_TextureCoordv);
		gl_FragColor = mix(color, vec4(color.a), progress);
	}
	")

	public function new()
	{
		super();
		progress.value = [0.0];
	}
}




class FXHandler
{
    public static var matrix:Array<Float>;
    public static var colorM:Array<Float>;

    public static function UpdateColors(?input:Array<BitmapFilter> = null):Void
    {
        trace("VALUE: " + FlxG.save.data.colorblind);

        var a1:Float = 1;
        var a2:Float = 0;
        var a3:Float = 0;

        var b1:Float = 0;
        var b2:Float = 1;
        var b3:Float = 0;

        var c1:Float = 0;
        var c2:Float = 0;
        var c3:Float = 1;

        switch (FlxG.save.data.colorblind)
        {
            case 0:
                trace('No color filter');
                a1 = 1; b1 = 0; c1 = 0;
                a2 = 0; b2 = 1; c2 = 0;
                a3 = 0; b3 = 0; c3 = 1;
            case 1:
                trace('Protanopia filter');
                a1 = 0.567; b1 = 0.433; c1 = 0;
                a2 = 0.558; b2 = 0.442; c2 = 0;
                a3 = 0; b3 = 0.242; c3 = 0.758;
            case 2:
                trace('Protanomaly filter');
                a1 = 0.817; b1 = 0.183; c1 = 0;
                a2 = 0.333; b2 = 0.667; c2 = 0;
                a3 = 0; b3 = 0.125; c3 = 0.875;
            case 3:
                trace('Deuteranopia filter');
                a1 = 0.625; b1 = 0.375; c1 = 0;
                a2 = 0.7; b2 = 0.3; c2 = 0;
                a3 = 0; b3 = 0; c3 = 1.0;
            case 4:
                trace('Deuteranomaly filter');
                a1 = 0.8; b1 = 0.2; c1 = 0;
                a2 = 0.258; b2 = 0.742; c2 = 0;
                a3 = 0; b3 = 0.142; c3 = 0.858;
            case 5:
                trace('Tritanopia filter');
                a1 = 0.95; b1 = 0.05; c1 = 0;
                a2 = 0; b2 = 0.433; c2 = 0.567;
                a3 = 0; b3 = 0.475; c3 = 0.525;
            case 6:
                trace('Tritanomaly filter');
                a1 = 0.967; b1 = 0.033; c1 = 0;
                a2 = 0; b2 = 0.733; c2 = 0.267;
                a3 = 0; b3 = 0.183; c3 = 0.817;
            case 7:
                trace('Achromatopsia filter');
                a1 = 0.299; b1 = 0.587; c1 = 0.114;
                a2 = 0.299; b2 = 0.587; c2 = 0.114;
                a3 = 0.299; b3 = 0.587; c3 = 0.114;
            case 8:
                trace('Achromatomaly filter');
                a1 = 0.618; b1 = 0.320; c1 = 0.062;
                a2 = 0.163; b2 = 0.775; c2 = 0.062;
                a3 = 0.163; b3 = 0.320; c3 = 0.516;
        }

        matrix = [
            a1 * FlxG.save.data.gamma, b1 * FlxG.save.data.gamma, c1 * FlxG.save.data.gamma, 0, FlxG.save.data.brightness,
            a2 * FlxG.save.data.gamma, b2 * FlxG.save.data.gamma, c2 * FlxG.save.data.gamma, 0, FlxG.save.data.brightness,
            a3 * FlxG.save.data.gamma, b3 * FlxG.save.data.gamma, c3 * FlxG.save.data.gamma, 0, FlxG.save.data.brightness,
            0, 0, 0, 1, 0,
        ];

        if (input != null)
        {
            input.push(new ColorMatrixFilter(matrix));
        }
        else
        {
            var filters:Array<BitmapFilter> = [];
            filters.push(new ColorMatrixFilter(matrix));
            FlxG.game.filtersEnabled = true;
            FlxG.game.setFilters(filters);
        }
    }
}