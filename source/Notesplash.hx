import flixel.graphics.frames.FlxAtlasFrames;
import flixel.FlxG;
import flixel.FlxSprite;

class Notesplash extends FlxSprite
{
    public var noteType:Int;
    public var noteData:Int;

    public function new(x:Float, y:Float, type:Int, data:Int)
    {
        super(x, y);

        noteType = type;
        noteData = data;

		var tex:FlxAtlasFrames = Paths.getSparrowAtlas('AllnoteSplashes', 'notes');

		switch (noteType)
		{
			case 3 | 4 | 9 | 10:
				tex = Paths.getSparrowAtlas('sinSplashes', 'notes');
			case 5:
				tex = Paths.getSparrowAtlas('Parry_assets', 'notes');
			case 11 | 12:
				tex = Paths.getSparrowAtlas('NOTE_bounce', 'notes');
			case 13:
				tex = Paths.getSparrowAtlas('NOTE_fire', 'notes');
		}

		frames = tex;

		switch (noteType)
		{
			case 0 | 8:
				var colorName = ['Purp', 'Blue', 'Green', 'Red'];
				for (i in 0...4)
				{
					animation.addByPrefix('splash ' + i, colorName[i] + 'C instance 1', 24, false);
				}
			case 3 | 4 | 10:
				var colorName = ['purple', 'blue', 'green', 'red'];
				for (i in 0...4)
				{
					animation.addByPrefix('splash 0 ' + i, 'note impact 1 ' + colorName[i], 24, false);
					animation.addByPrefix('splash 1 ' + i, 'note impact 2 ' + colorName[i], 24, false);
				}
			case 1:
				animation.addByPrefix('splash', 'CyanC instance 1', 24, false);
			case 2:
				animation.addByPrefix('splash', 'OrangeC instance 1', 24, false);
			case 5:
				animation.addByPrefix('splash', 'ParryFX', 24, false);
			case 6:
				animation.addByPrefix('splash', 'TrickyC instance 1', 24, false);
			case 7:
				animation.addByPrefix('splash', 'Bsshhhh instance 1', 24, false);
			case 11:
				animation.addByPrefix('splash', 'NoteSplash instance 1', 24, false);
			case 12:
				animation.addByPrefix('splash', 'NoteSplash Orange instance 1', 24, false);
			case 13:
				animation.addByPrefix('splash', 'oUCH', 24, false);
		}

        switch (noteType)
        {
            case 0:
                offset.set(85, 80);
            case 1:
                offset.set(85, 80);
            case 2:
                offset.set(85, 80);
            case 3:
                offset.set(80, 98);
            case 4:
                offset.set(73, 98);
            case 5:
                offset.set(211, 239);
            case 6:
                offset.set(90, 83);
            case 7:
                offset.set(215, 196);
            case 8:
                offset.set(81, 87);
            case 9:
                offset.set(80, 100);
            case 10:
                offset.set(73, 93);
            case 11:
                offset.set(92, 88);
            case 12:
                offset.set(90, 85);
            case 13:
                offset.set(164, 146);
        }

        antialiasing = true;
        alpha = 0.6;
	}

    public function playStatePlay()
    {
        play();

        animation.finishCallback = function(name)
        {
            alpha = 0;
            kill();
            destroy();
        }
    }

    public function play()
    {
        switch (noteType)
        {
            case 0 | 8:
                animation.play('splash ' + noteData, true);
            case 1 | 2 | 11 | 12:
                animation.play('splash', true);
            case 3 | 4 | 10:
                animation.play('splash ' + FlxG.random.int(0, 1) + " " + noteData, true);
            case 5:
                animation.play('splash', true);
            case 6:
                animation.play('splash', true);
            case 7:
                animation.play('splash', true);
            case 13:
                animation.play('splash', true);
        }
    }
}