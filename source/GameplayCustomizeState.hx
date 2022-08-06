import flixel.input.gamepad.FlxGamepad;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
#if windows
import Discord.DiscordClient;
#end

class GameplayCustomizeState extends MusicBeatState
{
	var defaultX:Float = FlxG.width * 0.55 - 135;
	var defaultY:Float = FlxG.height / 2 - 50;

	var background:FlxSprite;
	var curt:FlxSprite;
	var front:FlxSprite;

	var sick:FlxSprite;

	var text:FlxText;
	var blackBorder:FlxSprite;

	var strumLine:FlxSprite;
	var strumLineNotes:FlxTypedGroup<FlxSprite>;
	var playerStrums:FlxTypedGroup<FlxSprite>;
	private var camHUD:FlxCamera;

	public override function create()
	{
		super.create();

		#if windows
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Customizing Gameplay Modules", null);
		#end

		// Conductor.changeBPM(102);
		persistentUpdate = true;

		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		FlxG.cameras.add(camHUD);

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menu/BG', 'preload'));
		bg.setGraphicSize(Std.int(bg.width * 0.7));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = FlxG.save.data.highquality;
		add(bg);

		var camFollow = new FlxObject(0, 0, 1, 1);
		var camPos:FlxPoint = new FlxPoint(500, 100);

		camFollow.setPosition(camPos.x, camPos.y);

		sick = new FlxSprite().loadGraphic(Paths.image('sick', 'shared'));
		sick.scrollFactor.set();
		sick.cameras = [camHUD];
		add(sick);

		add(camFollow);

		FlxG.camera.follow(camFollow, LOCKON, 0.01);
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = 0.9;
		FlxG.camera.focusOn(camFollow.getPosition());

		strumLine = new FlxSprite(0, FlxG.save.data.strumline).makeGraphic(FlxG.width, 14);
		strumLine.scrollFactor.set();
		strumLine.alpha = 0.4;

		add(strumLine);

		if (FlxG.save.data.downscroll)
			strumLine.y = FlxG.height - 165;

		strumLineNotes = new FlxTypedGroup<FlxSprite>();
		add(strumLineNotes);

		playerStrums = new FlxTypedGroup<FlxSprite>();

		sick.cameras = [camHUD];
		strumLine.cameras = [camHUD];
		playerStrums.cameras = [camHUD];

		generateStaticArrows(0);
		generateStaticArrows(1);

		text = new FlxText(5, FlxG.height + 40, 0,
			"Use the arrow keys to move the rating position.\nPress R to reset.\nPress Escape to go back.", 12);
		text.scrollFactor.set();
		text.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);

		blackBorder = new FlxSprite(-30, FlxG.height + 40).makeGraphic((Std.int(text.width + 900)), Std.int(text.height + 600), FlxColor.BLACK);
		blackBorder.alpha = 0.5;

		add(blackBorder);

		add(text);

		FlxTween.tween(text, {y: FlxG.height - 18}, 2, {ease: FlxEase.elasticInOut});
		FlxTween.tween(blackBorder, {y: FlxG.height - 18}, 2, {ease: FlxEase.elasticInOut});

		if (!FlxG.save.data.changedHit)
		{
			FlxG.save.data.changedHitX = defaultX;
			FlxG.save.data.changedHitY = defaultY;
		}

		sick.x = FlxG.save.data.changedHitX;
		sick.y = FlxG.save.data.changedHitY;
	}

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		super.update(elapsed);

		FlxG.camera.zoom = FlxMath.lerp(0.9, FlxG.camera.zoom, 0.95);
		camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (gamepad != null)
		{
			if (gamepad.justPressed.DPAD_UP)
			{
				moveSick("y", -40);
			}
			if (gamepad.justPressed.DPAD_DOWN)
			{
				moveSick("y", 40);
			}
			if (gamepad.justPressed.DPAD_LEFT)
			{
				moveSick("x", -40);
			}
			if (gamepad.justPressed.DPAD_RIGHT)
			{
				moveSick("x", 40);
			}
		}

		if (FlxG.keys.anyJustPressed([UP]))
		{
			moveSick("y", -40);
		}
		if (FlxG.keys.anyJustPressed([DOWN]))
		{
			moveSick("y", 40);
		}
		if (FlxG.keys.anyJustPressed([LEFT]))
		{
			moveSick("x", -40);
		}
		if (FlxG.keys.anyJustPressed([RIGHT]))
		{
			moveSick("x", 40);
		}

		for (i in playerStrums)
			i.y = strumLine.y;
		for (i in strumLineNotes)
			i.y = strumLine.y;

		if (FlxG.keys.justPressed.R)
		{
			sick.x = defaultX;
			sick.y = defaultY;
			FlxG.save.data.changedHitX = sick.x;
			FlxG.save.data.changedHitY = sick.y;
			FlxG.save.data.changedHit = false;
		}

		if (controls.BACK)
		{
			backOut();
		}
	}

	function moveSick(coord:String, amount:Float)
	{
		FlxG.save.data.changedHitX = sick.x;
		FlxG.save.data.changedHitY = sick.y;
		FlxG.save.data.changedHit = true;

		if (coord == "x")
		{
			sick.x += amount;
		}
		else
		{
			sick.y += amount;
		}
	}

	function backOut()
	{
		FlxG.sound.play(Paths.sound('cancelMenu'));
		Main.switchState(new OptionsMenu());
	}

	override function beatHit()
	{
		super.beatHit();

		FlxG.camera.zoom += 0.015;
		camHUD.zoom += 0.010;

		trace('beat');
	}

	// ripped from play state cuz im lazy

	private function generateStaticArrows(player:Int):Void
	{
		for (i in 0...4)
		{
			var babyArrow:FlxSprite = new FlxSprite(0, strumLine.y);

			babyArrow.frames = Paths.getSparrowAtlas('NOTE_assets', 'shared');
			babyArrow.animation.addByPrefix('green', 'arrowUP');
			babyArrow.animation.addByPrefix('blue', 'arrowDOWN');
			babyArrow.animation.addByPrefix('purple', 'arrowLEFT');
			babyArrow.animation.addByPrefix('red', 'arrowRIGHT');

			babyArrow.antialiasing = FlxG.save.data.highquality;
			babyArrow.setGraphicSize(Std.int(babyArrow.width * Note.noteWidth));

			switch (Math.abs(i))
			{
				case 0:
					babyArrow.x += Note.swagWidth * 0;
					babyArrow.animation.addByPrefix('static', 'arrowLEFT');
					babyArrow.animation.addByPrefix('pressed', 'left press', 24, false);
					babyArrow.animation.addByPrefix('confirm', 'left confirm', 24, false);
				case 1:
					babyArrow.x += Note.swagWidth * 1;
					babyArrow.animation.addByPrefix('static', 'arrowDOWN');
					babyArrow.animation.addByPrefix('pressed', 'down press', 24, false);
					babyArrow.animation.addByPrefix('confirm', 'down confirm', 24, false);
				case 2:
					babyArrow.x += Note.swagWidth * 2;
					babyArrow.animation.addByPrefix('static', 'arrowUP');
					babyArrow.animation.addByPrefix('pressed', 'up press', 24, false);
					babyArrow.animation.addByPrefix('confirm', 'up confirm', 24, false);
				case 3:
					babyArrow.x += Note.swagWidth * 3;
					babyArrow.animation.addByPrefix('static', 'arrowRIGHT');
					babyArrow.animation.addByPrefix('pressed', 'right press', 24, false);
					babyArrow.animation.addByPrefix('confirm', 'right confirm', 24, false);
			}

			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set(0, 0);

			babyArrow.ID = i;

			switch (player)
			{
				case 1:
					playerStrums.add(babyArrow);
			}

			babyArrow.animation.play('static');


			switch (player)
			{
				// This should be symmetrical now
				case 0:
					babyArrow.x += ((FlxG.width / 4)) - (babyArrow.width * 2);
				case 1:
					babyArrow.x += ((FlxG.width / 4) * 3) - (babyArrow.width * 2);
			}

			strumLineNotes.add(babyArrow);
		}
	}
}
