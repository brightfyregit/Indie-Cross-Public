package offsetMenus;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.FlxUIGroup;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUITabMenu;
import flixel.addons.ui.FlxUITooltip.FlxUITooltipStyle;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.ui.FlxSpriteButton;
import flixel.util.FlxColor;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.net.FileReference;

using StringTools;

#if cpp
import systools.Clipboard;
#end

/**
	*DEBUG MODE
 */
class AnimationDebug extends MusicBeatState
{
	public static var daChar:String = 'bf';

	var UI_box:FlxUITabMenu;
	var bf:Boyfriend;
	var dad:Character;
	var char:Character;
	var textAnim:FlxText;
	var dumbTexts:FlxTypedGroup<FlxText>;
	var layeringbullshit:FlxTypedGroup<FlxSprite>;
	var animList:Array<String> = [];
	var curAnim:Int = 0;

	public static var isDad:Bool = true;

	var daAnim:String = 'spooky';
	var camFollow:FlxObject;
	var camHUD:FlxCamera;
	var camGame:FlxCamera;
	var player:FlxUICheckBox;
	var _file:FileReference;
	var ghostBF:Character;

	var tempChaser:CupBullet;
	var chaseOffset:Array<Int> = [];
	var chaser:CupBullet;

	private function saveLevel()
	{
		var data:String = '';

		for (anim in animList)
		{
			/*
				addOffset('idle', -5); -- how i want it to be added (WOOOOOH)
				idle -5 0 -- how it adds (bruh)
			 */

			char.addOffset(anim, char.animOffsets.get(anim)[0], char.animOffsets.get(anim)[1]);

			if (anim != "dischargeScared")
			{
				data += "addOffset('" + anim + "', " + char.animOffsets.get(anim)[0] + ", " + char.animOffsets.get(anim)[1] + ");" + "\n";
			}
		}

		if ((data != null) && (data.length > 0))
		{
			#if cpp
			var leData = data.trim();
			Clipboard.setText(leData);

			trace('saved shit on clipboard :D');
			#end
		}
	}

	public function new(daAnim:String = 'spooky')
	{
		super();
		this.daAnim = daAnim;
	}

	override function create()
	{
		super.create();

		setBrightness(0);

		FlxG.mouse.visible = true;
		FlxG.sound.music.stop();
		var gridBG:FlxSprite = FlxGridOverlay.create(10, 10);
		gridBG.scrollFactor.set(0, 0);
		add(gridBG);

		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		camGame = new FlxCamera();

		FlxG.cameras.add(camGame);
		FlxG.cameras.add(camHUD, false);
		FlxG.cameras.setDefaultDrawTarget(camGame, true);

		layeringbullshit = new FlxTypedGroup<FlxSprite>();
		add(layeringbullshit);

		var tabs = [
			{name: "Character", label: "Character"}
		];

		UI_box = new FlxUITabMenu(null, tabs, true);
		UI_box.cameras = [camHUD];
		UI_box.resize(300, 200);
		UI_box.x = (FlxG.width / 2) + 250;
		UI_box.y = 20;
		add(UI_box);

		var characterTab = new FlxUI(null, UI_box);
		characterTab.name = "Character";

		var characters:Array<String> = 
		[
			PlayState.dad.curCharacter,
			PlayState.boyfriend.curCharacter
		];

		var cumfart = new FlxUIDropDownMenu(50, 50, FlxUIDropDownMenu.makeStrIdLabelArray(characters, true), function(character:String)
		{
			daAnim = characters[Std.parseInt(character)];
			displayCharacter(daAnim);
		});

		cumfart.selectedLabel = daAnim; // CUM FART HAHAHAHAHHA

		player = new FlxUICheckBox(175, 50, null, null, "flipX", 100);
		player.checked = false;
		player.callback = function()
		{
			char.flipX = player.checked;
			trace('flipX: ' + char.flipX);
		};

		//player.checked = char.flipX;

		var saveButton:FlxButton = new FlxButton(100, 125, "Save", function()
		{
			saveLevel();
		});

		characterTab.add(player);
		characterTab.add(saveButton);
		characterTab.add(cumfart);
		UI_box.addGroup(characterTab);
		dumbTexts = new FlxTypedGroup<FlxText>();
		dumbTexts.cameras = [camHUD];
		add(dumbTexts);

		textAnim = new FlxText(300, 16);
		textAnim.size = 26;
		textAnim.scrollFactor.set();
		textAnim.color = FlxColor.WHITE;
		textAnim.borderStyle = FlxTextBorderStyle.OUTLINE;
		textAnim.borderSize = 2;
		add(textAnim);

		camFollow = new FlxObject(0, 0, 2, 2);
		camFollow.screenCenter();
		add(camFollow);
		camGame.follow(camFollow);

		displayCharacter(daAnim);
		chaser = new CupBullet('chaser', dad.getMidpoint().x, dad.getMidpoint().y);
		add(chaser);
		chaser.state = 'debug';

		if (char.flipX)
			player.checked = true;
	}

	function displayCharacter(daAnim:String)
	{
		dumbTexts.forEach(function(text:FlxText)
		{
			dumbTexts.remove(text, true);
		});
		dumbTexts.clear();

		animList = [];

		if (daAnim == 'bf')
			isDad = false;
		else
			isDad = true;

		if (dad != null)
			layeringbullshit.remove(dad);

		if (bf != null)
			layeringbullshit.remove(bf);

		if (ghostBF != null)
			layeringbullshit.remove(ghostBF);

		ghostBF = new Character(0, 0, daAnim);
		ghostBF.alpha = .5;
		ghostBF.screenCenter();
		ghostBF.debugMode = true;

		layeringbullshit.add(ghostBF);

		if (isDad)
		{
			dad = new Character(0, 0, daAnim);
			dad.screenCenter();
			dad.debugMode = true;
			layeringbullshit.add(dad);

			char = dad;
			dad.flipX = player.checked;
		}
		else
		{
			bf = new Boyfriend(0, 0, daAnim);
			bf.screenCenter();
			bf.debugMode = true;
			layeringbullshit.add(bf);

			char = bf;
			bf.flipX = player.checked;
		}

		genBoyOffsets();
	}

	function genBoyOffsets(pushList:Bool = true):Void
	{
		var daLoop:Int = 0;

		if (char.offsetNames != ['']) // some chars arent even coded in so it throws the good ol' null object reference
		{
			for (anim in char.offsetNames)
			{
				var offsets = char.animOffsets.get(anim);
				var text:FlxText = new FlxText(10, 20 + (18 * daLoop), 0, anim + ": " + offsets, 15);
				text.scrollFactor.set();
				text.color = FlxColor.WHITE;
				text.borderStyle = FlxTextBorderStyle.OUTLINE;
				text.borderSize = 2;
				dumbTexts.add(text);

				if (pushList)
					animList.push(anim);

				daLoop++;
			}
		}
		var text:FlxText = new FlxText(10, 20 + (18 * daLoop), 0, "chaser x: " + chaseOffset[0], 15);
		text.scrollFactor.set();
		text.color = FlxColor.WHITE;
		text.borderStyle = FlxTextBorderStyle.OUTLINE;
		text.borderSize = 2;
		dumbTexts.add(text);
		daLoop++;
		var text2:FlxText = new FlxText(10, 20 + (18 * daLoop), 0, "chaser y: " + chaseOffset[1], 15);
		text2.scrollFactor.set();
		text2.color = FlxColor.WHITE;
		text2.borderStyle = FlxTextBorderStyle.OUTLINE;
		text2.borderSize = 2;
		dumbTexts.add(text2);
	}

	function updateTexts():Void
	{
		dumbTexts.forEach(function(text:FlxText)
		{
			text.kill();
			dumbTexts.remove(text, true);
		});
		dumbTexts.clear();
	}

	override function update(elapsed:Float)
	{
		if (char != null)
		{
			if (char.animation.curAnim != null) textAnim.text = char.animation.curAnim.name;
			ghostBF.flipX = char.flipX;
		}

		if (FlxG.keys.justPressed.ESCAPE || FlxG.keys.justPressed.BACKSPACE)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			Main.switchState(new PlayState());
		}

		if (FlxG.keys.justPressed.P)
		{
			dad.animation.curAnim.pause();
		}
		if (FlxG.keys.justPressed.V)
		{
			chaser.animation.curAnim.curFrame++;
		}
		if (FlxG.keys.justPressed.B)
		{
			chaser.animation.curAnim.curFrame--;
		}

		if (FlxG.keys.justPressed.E)
			camGame.zoom += 0.25;
		if (FlxG.keys.justPressed.Q)
			camGame.zoom -= 0.25;

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

		if (FlxG.keys.justPressed.W)
		{
			curAnim -= 1;
		}

		if (FlxG.keys.justPressed.S)
		{
			curAnim += 1;
		}

		if (curAnim < 0)
			curAnim = animList.length - 1;

		if (curAnim >= animList.length)
			curAnim = 0;

		if (FlxG.keys.justPressed.S || FlxG.keys.justPressed.W || FlxG.keys.justPressed.SPACE)
		{
			char.playAnim(animList[curAnim]);

			ghostBF.playAnim(animList[0]);
			updateTexts();
			genBoyOffsets(false);
		}

		var upP = FlxG.keys.anyJustPressed([UP]);
		var rightP = FlxG.keys.anyJustPressed([RIGHT]);
		var downP = FlxG.keys.anyJustPressed([DOWN]);
		var leftP = FlxG.keys.anyJustPressed([LEFT]);

		var iP = FlxG.keys.anyJustPressed([I]);
		var lP = FlxG.keys.anyJustPressed([L]);
		var kP = FlxG.keys.anyJustPressed([K]);
		var jP = FlxG.keys.anyJustPressed([J]);

		var holdShift = FlxG.keys.pressed.SHIFT;
		var multiplier = 1;
		if (holdShift)
			multiplier = 10;
		if (iP || lP || kP || jP)
		{
			updateTexts();
			if (iP)
				chaseOffset[1] -= 1 * multiplier;
			if (kP)
				chaseOffset[1] += 1 * multiplier;
			if (jP)
				chaseOffset[0] -= 1 * multiplier;
			if (lP)
				chaseOffset[0] += 1 * multiplier;

			chaser.x = dad.getMidpoint().x + chaseOffset[0];
			chaser.y = dad.getMidpoint().y + chaseOffset[1];
			updateTexts();
			genBoyOffsets(false);
		}

		if (upP || rightP || downP || leftP)
		{
			updateTexts();
			if (upP)
				char.animOffsets.get(animList[curAnim])[1] += 1 * multiplier;
			if (downP)
				char.animOffsets.get(animList[curAnim])[1] -= 1 * multiplier;
			if (leftP)
				char.animOffsets.get(animList[curAnim])[0] += 1 * multiplier;
			if (rightP)
				char.animOffsets.get(animList[curAnim])[0] -= 1 * multiplier;

			updateTexts();
			genBoyOffsets(false);
			char.playAnim(animList[curAnim]);
			
			ghostBF.playAnim(animList[0]);
		}

		super.update(elapsed);
	}
}
