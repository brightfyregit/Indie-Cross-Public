package;

import flixel.input.gamepad.FlxGamepad;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.text.FlxTypeText;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import openfl.utils.Assets as OpenFlAssets;

using StringTools;

class SansDialogueBox extends FlxSpriteGroup
{
	var box:FlxSprite;

	var curCharacter:String = '';
	var curSound:String = '';
	var soundDelay:String = '';



	var dialogue:Alphabet;
	var dialogueList:Array<String> = [];

	// SECOND DIALOGUE FOR THE PIXEL SHIT INSTEAD???
	var swagDialogue:FlxTypeText;

	public var finishThing:Void->Void;

	public function new(?dialogueList:Array<String>)
	{
		super();

		box = new FlxSprite(700, 480);
		box.frames = Paths.getSparrowAtlas('Sans_Text_box', 'sans');
		box.animation.addByPrefix('normalOpen', 'Normall instance 1', 24, false);
		box.animation.addByIndices('normal', 'Normall instance 1', [23], "", 24, false);
		box.animation.addByPrefix('wink', 'Winkk instance 1', 24, false);
		box.animation.addByPrefix('eyesclosed', 'eyes closed instance 1', 24, false);
		box.animation.addByPrefix('funne', 'funne instance 1', 24, false);
		box.animation.addByPrefix('noeyes', 'no eyes instance 1', 24, false);
		box.animation.addByPrefix('ending', 'Dialogue End instance 1', 24, false);
		// what am i supposed to call this y'all confusing me
		box.animation.addByPrefix('gay', 'son dying is gay instance 1', 24, false);

		this.dialogueList = dialogueList;

		box.animation.play('normalOpen');
		// box.setGraphicSize(Std.int(box.width * 0.6));
		box.alpha = 0.0001;
		add(box);

		box.screenCenter(X);
		box.scrollFactor.set();

		swagDialogue = new FlxTypeText(336, 545, Std.int(FlxG.width * 0.6), "", 38); // old X: 336
		swagDialogue.font = Paths.font("Comic Sans [PIXEL].ttf");
		swagDialogue.color = 0xFF3F2021;
		swagDialogue.sounds = [FlxG.sound.load(Paths.sound('snd_txtsans', 'sans'), 0.6)];
		swagDialogue.alpha = 0.0001;
		add(swagDialogue);

		dialogue = new Alphabet(0, 80, "", false, true);
	}

	var dialogueOpened:Bool = false;
	var dialogueStarted:Bool = false;

	override function update(elapsed:Float)
	{
		if (!PlayState.instance.dialoguePaused)
		{
			box.alpha = 1;
			swagDialogue.alpha = 1;
			// HARD CODING CUZ IM STUPDI
			swagDialogue.color = FlxColor.WHITE;

			if (box.animation.curAnim != null)
			{
				if (box.animation.curAnim.name == 'normalOpen' && box.animation.curAnim.finished)
				{
					box.animation.play('normal');
					dialogueOpened = true;
				}
			}

			if (dialogueOpened && !dialogueStarted)
			{
				startDialogue();
				dialogueStarted = true;
			}

			if (PlayerSettings.player1.controls.ACCEPT)
			{
				accept();
			}
		}
		else
		{
			box.alpha = 0.0001;
			swagDialogue.alpha = 0.0001;
		}

		super.update(elapsed);
	}

	function accept()
	{
		if (dialogueStarted == true)
		{
			remove(dialogue);

			if (dialogueList[1] == null && dialogueList[0] != null)
			{
				if (!isEnding)
				{
					isEnding = true;
					swagDialogue.visible = false;

					box.animation.play('ending',true);
					box.animation.finishCallback = function(unused:String)
					{
						box.visible = false;
						finishThing();
						kill();
					}
					

					new FlxTimer().start(0.5, function(tmr:FlxTimer)
					{
						finishThing();
						kill();
					});
				}
			}
			else
			{
				dialogueList.remove(dialogueList[0]);
				startDialogue();
			}
		}
	}

	var isEnding:Bool = false;

	function startDialogue():Void
	{
		cleanDialog();

		swagDialogue.resetText(dialogueList[0]);
		swagDialogue.start(0.04, true);

		box.animation.play(curCharacter);

		if (curSound != 'none')
		{
			trace('sound is not null');
			if (soundDelay == 'invalid')
			{
				trace('sound is not timed');
				if (OpenFlAssets.exists(Paths.sound(curSound, 'sans')))
					FlxG.sound.play(Paths.sound(curSound, 'sans'));
			}
			else
			{
				trace('sound is timed');

				new FlxTimer().start(Std.parseFloat(soundDelay), function(tmr:FlxTimer)
				{
					if (OpenFlAssets.exists(Paths.sound(curSound, 'sans')))
						FlxG.sound.play(Paths.sound(curSound, 'sans'));
				});
			}
		}
	}

	function cleanDialog():Void
	{
		var splitName:Array<String> = dialogueList[0].split(":");
		trace("splitName: " + splitName);

		dialogueList[0] = splitName[0];
		curCharacter = splitName[1];

		if (splitName[2].contains('--'))
		{
			var splitSound:Array<String> = splitName[2].split("--");
			trace("splitSound: " + splitSound);
			curSound = splitSound[0];
			soundDelay = splitSound[1];
		}
		else
		{
			curSound = splitName[2];
			soundDelay = 'invalid';
		}
	}
}
