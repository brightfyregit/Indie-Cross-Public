package;

import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.FlxG;


using StringTools;

class JumpscareState extends MusicBeatState
{
    public static var allowRetry:Bool = false;
    var screen:FlxSprite;
    var accepted:Bool = false;

    override function create()
    {
        super.create();
        
        /*screen = new FlxSprite(0, 0).loadGraphic(Paths.image('bonusSongs/BlackScreen', 'shared'));
        screen.scrollFactor.set(0, 0);
        add(screen);*/

       
        if (PlayState.SONG.song.toLowerCase() == 'despair')
        {
            FlxG.sound.playMusic(Paths.music('fuck you', 'bendy'));
            FlxG.sound.play(Paths.sound('trolled', 'bendy'));
            FNFState.disableNextTransIn = true;
        }

        if (PlayState.SONG.song.toLowerCase() == 'devils-gambit')
        {
           FlxG.sound.playMusic(Paths.music('fuck you', 'cup'));
           FlxG.sound.play(Paths.sound('trolled', 'cup'));
        }

        if (PlayState.SONG.song.toLowerCase() == 'bad-time')
        {
            FlxG.sound.playMusic(Paths.music('fuck you', 'sans'));
            FlxG.sound.play(Paths.sound('trolled', 'sans'));
        }

        FNFState.disableNextTransOut = true;
    }


	override function update(elapsed:Float)
	{
		super.update(elapsed);

        if (!accepted)
        {
            if (controls.ACCEPT)
            {
                accept();
            }
    
            if (controls.BACK)
            {
                backOut();
            }
        }
	}

    function accept()
    {
        if (allowRetry)
        {
            accepted = true;
            FlxG.sound.music.stop();
            FlxG.sound.play(Paths.sound('click', 'bendy'));

            FlxG.camera.fade(FlxColor.BLACK, 1, false, function()
            {
                FlxG.switchState(new PlayState());
            });
        }
    }

    function backOut()
    {
        if (MainMenuState.debugTools || allowRetry)
        {
            accepted = true;
            Main.switchState(new FreeplayState());
        }
    }
}