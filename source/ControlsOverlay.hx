package;

import flixel.util.FlxColor;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.text.FlxText;
import flixel.FlxG;
import flixel.group.FlxSpriteGroup;

using StringTools;

class ControlsOverlay extends FlxSpriteGroup
{
    var controlsHelp:FlxText;

	public function new()
	{
		super();

        controlsHelp = new FlxText(10, 10, 0, HelperFunctions.getSongData(PlayState.SONG.song.toLowerCase(), 'mech'), 32);
		controlsHelp.scrollFactor.set();
		controlsHelp.setFormat(Paths.font('vcr.ttf'), 32, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		controlsHelp.alignment = LEFT;
		controlsHelp.font = HelperFunctions.returnHudFont(controlsHelp);
		controlsHelp.updateHitbox();
		add(controlsHelp);
		if (controlsHelp.text == "CONTROLS\n")
		{
			controlsHelp.visible = false;
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
	}

    public function setAlpha(alpha:Float)
    {
        controlsHelp.alpha = alpha;
    }

	public function fade()
	{
        FlxTween.tween(controlsHelp, {alpha: 0}, Conductor.crochet / 1000, {
            ease: FlxEase.cubeInOut, 
            startDelay: (Conductor.crochet / 1000) * 8, 
            onComplete: function(twn:FlxTween)
            {
                kill();
            }
        });
	}
}
