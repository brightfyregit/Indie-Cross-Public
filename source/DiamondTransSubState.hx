package;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

class DiamondTransSubState extends FlxSubState
{
    var shader:DiamondTransShader;
    var rect:FlxSprite;
    var tween:FlxTween;
    
    var finishCallback:() -> Void;
    var duration:Float;

    var fi:Bool = true;

    public function new(duration:Float = 1.0, fadeIn:Bool = true, finishCallback:() -> Void = null)
    {
        super();
        
        this.duration = duration;
        this.finishCallback = finishCallback;
        this.fi = fadeIn;
    }

    override public function create()
    {
        super.create();

        camera = new FlxCamera();
        camera.bgColor = FlxColor.TRANSPARENT;

        FlxG.cameras.add(camera, false);

        shader = new DiamondTransShader();

        shader.progress.value = [0.0];
        shader.reverse.value = [false];

        rect = new FlxSprite(0, 0);
        rect.makeGraphic(1, 1, 0xFF000000);
        rect.scale.set(1280, 720);
        rect.origin.set();
        rect.shader = shader;
        rect.visible = false;
        add(rect);

        if (fi)
            fadeIn();
        else
            fadeOut();

		closeCallback = _closeCallback;
    }

    function __fade(from:Float, to:Float, reverse:Bool)
    {
        trace("fade initiated");
        
        rect.visible = true;
        shader.progress.value = [from];
        shader.reverse.value = [reverse];

        tween = FlxTween.num(from, to, duration, {ease: FlxEase.linear, onComplete: function(_)
        {
            trace("finished");
            if (finishCallback != null)
            {
                trace("with callback");
                finishCallback();
            }
        }}, function(num:Float)
        {
            shader.progress.value = [num];
        });
    }

    function fadeIn()
    {
        __fade(0.0, 1.0, true);
    }

    function fadeOut()
    {
        __fade(0.0, 1.0, false);
    }

    function _closeCallback()
    {
        if (tween != null)
            tween.cancel();
    }
}