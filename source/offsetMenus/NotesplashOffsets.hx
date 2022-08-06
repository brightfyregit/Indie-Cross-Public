package offsetMenus;

import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;

/**
 * @author BrightFyre
 */
class NotesplashOffsets extends FlxState
{
	var sploosh:Notesplash;
	var camFollow:FlxObject;
    var text:FlxText;

	public function new()
	{
		super();
	}

    var splooshX:Float = 0;
    var splooshY:Float = 0;

	override function create()
	{
		FlxG.sound.music.stop();

		var gridBG:FlxSprite = FlxGridOverlay.create(10, 10);
		gridBG.scrollFactor.set(0.5, 0.5);
		add(gridBG);

        var babyArrow:FlxSprite = new FlxSprite(0, 0);
        babyArrow.frames = Paths.getSparrowAtlas('NOTE_assets', 'notes');
        babyArrow.animation.addByPrefix('purple', 'arrowLEFT');
        babyArrow.antialiasing = FlxG.save.data.highquality;
        babyArrow.setGraphicSize(Std.int(babyArrow.width * Note.noteWidth));
        babyArrow.animation.addByPrefix('static', 'arrowLEFT');
        babyArrow.animation.play('static', true);
        babyArrow.scrollFactor.set(0, 0);
        babyArrow.updateHitbox();
        babyArrow.screenCenter();
        add(babyArrow);

        splooshX = babyArrow.x;
        splooshY = babyArrow.y;

		loadSploosh(0);

		camFollow = new FlxObject(0, 0, 2, 2);
		camFollow.screenCenter();
		add(camFollow);

		FlxG.camera.follow(camFollow);

        text = new FlxText(10, 20, 0, "X: " + sploosh.offset.x + ", Y: " + sploosh.offset.y, 15);
        text.scrollFactor.set();
        text.color = FlxColor.BLUE;
        add(text);

        var types:Array<String> = 
        [
            "0",
            "1",
            "2",
            "3",
            "4",
            "5",
            "6",
            "7",
            "8",
            "9",
            "10",
            "11",
            "12",
            "13"
        ];

		var typeMenu = new FlxUIDropDownMenu(50, 50, FlxUIDropDownMenu.makeStrIdLabelArray(types, true), function(index:String)
        {
            remove(sploosh);
            loadSploosh(Std.parseInt(index));
        });

        typeMenu.selectedLabel = "0";

        add(typeMenu);

		super.create();
	}

    function loadSploosh(type:Int)
    {
        sploosh = new Notesplash(splooshX, splooshY, type, 0);
        sploosh.play();
		add(sploosh);
    }

	override function update(elapsed:Float)
	{
		if (FlxG.keys.justPressed.E)
			FlxG.camera.zoom += 0.25;
		if (FlxG.keys.justPressed.Q)
			FlxG.camera.zoom -= 0.25;

		if (FlxG.keys.pressed.I || FlxG.keys.pressed.J || FlxG.keys.pressed.K || FlxG.keys.pressed.L)
		{
			if (FlxG.keys.pressed.I)
				camFollow.velocity.y = -90;
			else if (FlxG.keys.pressed.K)
				camFollow.velocity.y = 90;
			else
				camFollow.velocity.y = 0;

			if (FlxG.keys.pressed.J)
				camFollow.velocity.x = -90;
			else if (FlxG.keys.pressed.L)
				camFollow.velocity.x = 90;
			else
				camFollow.velocity.x = 0;
		}
		else
		{
			camFollow.velocity.set();
		}

		if (FlxG.keys.justPressed.BACKSPACE)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			Main.switchState(new MainMenuState());
		}

		var upP = FlxG.keys.anyJustPressed([UP]);
		var rightP = FlxG.keys.anyJustPressed([RIGHT]);
		var downP = FlxG.keys.anyJustPressed([DOWN]);
		var leftP = FlxG.keys.anyJustPressed([LEFT]);

		var holdShift = FlxG.keys.pressed.SHIFT;
		var multiplier = 1;
		if (holdShift)
			multiplier = 10;

		if (upP || rightP || downP || leftP)
		{
			if (upP)
				sploosh.offset.y += 1 * multiplier;
			if (downP)
				sploosh.offset.y -= 1 * multiplier;
			if (leftP)
				sploosh.offset.x += 1 * multiplier;
			if (rightP)
				sploosh.offset.x -= 1 * multiplier;

            text.text = "X: " + sploosh.offset.x + ", Y: " + sploosh.offset.y;  

            sploosh.play();
		}

        if (FlxG.keys.justPressed.SPACE)
        {
            sploosh.play();
        }

		super.update(elapsed);
	}
}
