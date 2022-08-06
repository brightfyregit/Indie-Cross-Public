package;

import flixel.graphics.tile.FlxGraphicsShader;

class DiamondTransShader extends FlxGraphicsShader
{
    @:glFragmentSource("
    #pragma header

    // Ranges from 0 to 1 over the course of the transition.
    // We use this to actually animate the shader.
    
    uniform float progress;
    uniform bool reverse;

    // Size of each diamond, in pixels.
    uniform float diamondPixelSize;

    void main() {
        float xFraction = fract(gl_FragCoord.x / diamondPixelSize);
        float yFraction = fract(gl_FragCoord.y / diamondPixelSize);
        float xDistance = abs(xFraction - 0.5);
        float yDistance = abs(yFraction - 0.5);
        
        float target = xDistance + yDistance + openfl_TextureCoordv.y;
        float actualProgress = progress * 2.0;
        
        if (reverse) {
            if (target < actualProgress) discard;
        }
        else {
            if (target > actualProgress) discard;
        }

        gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
    }
    ")

    public function new()
    {
        super();

        progress.value = [0.0];
        reverse.value = [false];
        diamondPixelSize.value = [30.0];
    }
}