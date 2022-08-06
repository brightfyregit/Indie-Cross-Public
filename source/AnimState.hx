package;

import animateAtlasPlayer.assets.AssetManager;
import animateAtlasPlayer.core.Animation;
import flixel.FlxG;

class AnimState extends MusicBeatState
{
    var loaded:Bool = false;
    var leAssets:AssetManager;
    var leAnimation:Animation;

    override function create()
    {
        super.create();

        var sans:AssetManager = new AssetManager();
        sans.enqueue("assets/shared/images/characters/Saness");
        sans.loadQueue(onLoad);
    }

    function onLoad(assets:AssetManager):Void
    {
        trace('no way i loaded wtf?!?!?');

        loaded = true;
        leAssets = assets;

        leAnimation = leAssets.createAnimation("Idle");
        
        for (anim in leAssets.getAnimationAtlasNames("", []))
        {
            trace(anim);
        }

        FlxG.stage.addChild(leAnimation);
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if (loaded)
        {
            if (FlxG.keys.justPressed.UP)
            {
                leAnimation = leAssets.createAnimation("Up");
            }
            else if (FlxG.keys.justPressed.DOWN)
            {
                leAnimation = leAssets.createAnimation("Down");
            }
            else if (FlxG.keys.justPressed.LEFT)
            {
                leAnimation = leAssets.createAnimation("Left");
            }
            else if (FlxG.keys.justPressed.RIGHT)
            {
                leAnimation = leAssets.createAnimation("Right");
            }
        }
    }
}
