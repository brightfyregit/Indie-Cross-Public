package;

import PlayState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxMath;

using StringTools;

class Note extends FlxSprite
{
	public var strumTime:Float = 0;

	public var mustPress:Bool = false;
	public var player3Note:Bool = false;
	public var noteData:Int = 0;
	public var canBeHit:Bool = false;
	public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;
	public var prevNote:Note;
	public var modifiedByLua:Bool = false;
	public var sustainLength:Float = 0;
	public var isSustainNote:Bool = false;

	public static var swagWidth:Float = 160 * 0.7;
	public static var PURP_NOTE:Int = 0;
	public static var GREEN_NOTE:Int = 2;
	public static var BLUE_NOTE:Int = 1;
	public static var RED_NOTE:Int = 3;
	public static var noteWidth:Float = 0.7;

	var typeFile:Array<String> = ['assets', 'bones', 'bones', 'sin', 'sin', 'parry', 'tricky', 'flash', 'nmrunassets', 'sin_notes', 'ink_notes2',  'bounce', 'bounce', 'fire', 'sin_notes' ]; // the shared folder image name after 'NOTE_'
	var typeDirName:Array<Dynamic> = [
		['purple', 'blue', 'green', 'red'], // assets
		['leftB', 'downB', 'upB', 'rightB'], // bones
		['leftO', 'downO', 'upO', 'rightO'], // bones
		['0', '002ae', '001Ink note', '003Bruue'], // sin
		['EER', 'CE', 'DEATH NOTE', 'Bruh'], // sin
		['LEf', 'OO', 'Pink note', 'EF'], // parry
		['Left', 'Down', 'Up', 'Right'], // tricky
		['Left', 'Down', 'Up', 'Right'], // flash
		['purple', 'blue', 'green', 'red'], // nmrunassets
		['D-Left', 'D-Down', 'D-Up', 'D-Right'], //sin_notes
		['left', 'down', 'up', 'right'], // ink_notes2
		['Left instance 1', 'Down instance 1', 'Up instance 1', 'Right instance 1'], // bounce
		[
			'Left Orng instance 1',
			'Down Orenji instance 1',
			'Up Orang instance 1',
			'Right Orng instance 1'
		], // bounce
		['Left', 'Down', 'Up', 'Right'] // fire
	];
	// the sprite offset for each note type :)
	var typeOffset:Array<Dynamic> = [
		[0, 0], // default | 0
		[0, 0], // blue bones | 1
		[0, 0], // orange bones | 2
		[0, 0], // old ink notes | 3
		[-1, -1], // death ink notes | 4
		[0, 0], // parry notes | 5
		[0, 0], // tricky notes (are these even used?) | 6
		[0, 0], // flash notes | 7
		[-16, -16], // nmrun notes | 8
		[
			[-53, -29],
			[-49, 10]
						], // nmrun tunnel death notes | 9
		[-39, -34], // tunnel ink notes v2 | 10
		[0, 0], // blue bounce notes | 11
		[0, 0], // orange bounce notes | 12

		[	// devil notes | 13
			[-10, -20], //upscroll offset
			[-10, 120]	//downscroll offset
					]
	];
	// if there's a difference in notes for downscroll or not
	var typeDS:Array<Bool> = [false, false, false, false, false, false, false, false, false, true, false, false, false, true]; // the two trues are the devil fire notes and new death ink notes :)

	// what susඞ note the type posseses. [yes = normal, no = no sus sprite, shared = every note shares left's sustain sprites]
	var typeSus:Array<String> = ['yes', 'shared', 'shared', 'no', 'no', 'no', 'no', 'shared', 'yes', 'no', 'no'];

	public var dataColor:Array<String> = ['purple', 'blue', 'green', 'red'];

	public var noteType:Int = 0;

	public var rating:String = "shit";

	public var isParent:Bool = false;
	public var parent:Note = null;
	public var spotInLine:Int = 0;
	public var sustainActive:Bool = true;

	public var children:Array<Note> = [];

	public var noteYOff:Int = 0;

	public var noteXspriteOffset:Int = 0;
	public var noteYspriteOffset:Int = 0;

	public var bouncing:Bool = false;
	public var bounced:Bool = false;

	public function new(strumTime:Float, noteData:Int, ?prevNote:Note, ?sustainNote:Bool = false, ?inCharter:Bool = false)
	{
		super();

		noteWidth = 0.7;
		swagWidth = 160 * 0.7;

		if (prevNote == null)
			prevNote = this;

		this.prevNote = prevNote;
		isSustainNote = sustainNote;

		x += 50;
		// MAKE SURE ITS DEFINITELY OFF SCREEN?
		y -= 2000;
		if (inCharter)
			this.strumTime = strumTime;
		else
			this.strumTime = Math.round(strumTime); // + FlxG.save.data.offset;
		if (this.strumTime < 0)
			this.strumTime = 0;

		var t = Std.int(noteData / Main.dataJump);
		this.noteType = t;
		this.noteData = noteData % 4;

		if (isSustainNote
			&& (prevNote.noteType == 3 || prevNote.noteType == 4 || prevNote.noteType == 5 || prevNote.noteType == 6 || prevNote.noteType == 7
				|| prevNote.noteType == 9 || prevNote.noteType == 10))
		{
			noteType == prevNote.noteType;
		}

		if (typeDS[noteType])
		{
			if (PlayStateChangeables.useDownscroll)
			{
				typeFile[9] += '_downscroll'; // the fire notes don't have the '-downscroll' suffix cus fuck consistency ig;
				typeDirName[9] = ['downscrollleft', 'downscrolldown', 'downscrollup', 'downscrollright'];
				typeDirName[13] = ['DownScroll-Left', 'DownScroll-Down', 'DownScroll-Up', 'DownScroll-Right'];

				noteXspriteOffset = typeOffset[noteType][1][0];
				noteYspriteOffset = typeOffset[noteType][1][1];
			} else {
				noteXspriteOffset = typeOffset[noteType][0][0];
				noteYspriteOffset = typeOffset[noteType][0][1];
			}
		} else {
			noteXspriteOffset = typeOffset[noteType][0];
			noteYspriteOffset = typeOffset[noteType][1];
		}
		
		if (noteType == 9)
		{
			noteWidth = noteWidth*0.975;
			if (PlayStateChangeables.useDownscroll)
			{
				noteWidth = noteWidth*1.175;
			}
		}

		if (!PlayState.mechanicsEnabled && !PlayState.inNightmareSong)
		{
			switch (noteType)
			{
				case 1 | 3 | 4 | 6 | 7 | 9 | 10 | 13:
					this.kill();
				case 2 | 5 | 11 | 12:
					this.noteType = 0;
			}
		}

		if (t == 0 || !PlayState.mechanicsEnabled) // why were these two seperate if statements???
		{
			if (PlayState.curStage == 'field' || PlayState.curStage == 'devilHall')
			{
				frames = Paths.getSparrowAtlas('NOTE_cup', 'notes');
			} else {
				frames = PlayState.noteskinSprite;
			}
		} else {
			frames = Paths.getSparrowAtlas('NOTE_' + typeFile[t], 'notes');
		}

		for (i in 0...4)
		{
			switch (noteType)
			{
				case 9 | 10:
					animation.addByPrefix(typeDirName[0][i] + 'Scroll', typeDirName[t][i]);
				case 6:
					animation.addByPrefix(typeDirName[0][i] + 'Scroll', typeDirName[t][FlxG.random.int(0, 3)] + ' alone');
				default:
					animation.addByPrefix(typeDirName[0][i] + 'Scroll', typeDirName[t][i] + ' alone');
			}

			switch (typeSus[t])
			{
				case 'yes':
					animation.addByPrefix(typeDirName[0][i] + 'hold', typeDirName[t][i] + ' hold');
					animation.addByPrefix(typeDirName[0][i] + 'holdend', typeDirName[t][i] + ' tail');
				case 'no':
					animation.addByPrefix(typeDirName[0][i] + 'hold', typeDirName[t][i] + ' alone');
					animation.addByPrefix(typeDirName[0][i] + 'holdend', typeDirName[t][i] + ' alone');
				case 'shared':
					animation.addByPrefix(typeDirName[0][i] + 'hold', typeDirName[t][0] + ' hold');
					animation.addByPrefix(typeDirName[0][i] + 'holdend', typeDirName[t][0] + ' tail');
			}

			if (!FlxG.save.data.mechanicsEnabled && !PlayState.inNightmareSong)
			{
				animation.addByPrefix(typeDirName[0][i] + 'Scroll', typeDirName[0][i] + ' alone');
			}
		}

		setGraphicSize(Std.int(width * noteWidth));
		updateHitbox();
		antialiasing = FlxG.save.data.highquality;

		switch (noteData % 4)
		{
			case 0:
				x += swagWidth * 0;
				animation.play('purpleScroll');
			case 1:
				x += swagWidth * 1;
				animation.play('blueScroll');
			case 2:
				x += swagWidth * 2;
				animation.play('greenScroll');
			case 3:
				x += swagWidth * 3;
				animation.play('redScroll');
		}
		x += noteXspriteOffset;
		y += noteYspriteOffset;

		if (isSustainNote)
		{
			alpha = 0.5;
		}

		// trace(prevNote);

		// we make sure its downscroll and its a SUSTAIN NOTE (aka a trail, not a note)
		// and flip it so it doesn't look weird.
		// THIS DOESN'T FUCKING FLIP THE NOTE, CONTRIBUTERS DON'T JUST COMMENT THIS OUT JESUS
		if (FlxG.save.data.downscroll && sustainNote)
			flipY = true;

		var stepHeight = (0.45 * Conductor.stepCrochet * FlxMath.roundDecimal(PlayState.songScrollSpeed,
			2));

		if (isSustainNote && prevNote != null)
		{
			alpha = 0.6;

			x += width / 2;

			switch (noteData % 4)
			{
				case 2:
					animation.play('greenholdend');
				case 3:
					animation.play('redholdend');
				case 1:
					animation.play('blueholdend');
				case 0:
					animation.play('purpleholdend');
			}

			updateHitbox();

			x -= width / 2;

			if (PlayState.curStage.startsWith('school'))
				x += 30;

			if (prevNote.isSustainNote)
			{
				switch (prevNote.noteData % 4)
				{
					case 0:
						prevNote.animation.play('purplehold');
					case 1:
						prevNote.animation.play('bluehold');
					case 2:
						prevNote.animation.play('greenhold');
					case 3:
						prevNote.animation.play('redhold');
				}

				prevNote.updateHitbox();

				prevNote.scale.y *= (stepHeight + 1) / prevNote.height; // + 1 so that there's no odd gaps as the notes scroll
				prevNote.updateHitbox();
				prevNote.noteYOff = Math.round(-prevNote.offset.y);

				// prevNote.setGraphicSize();

				noteYOff = Math.round(-offset.y);
			}
		}
	}

	function updateSprite()
	{

	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (!modifiedByLua)
		{
			if (!sustainActive)
			{
				alpha = 0.3;
			}
		}

		if (isSustainNote
			&& (prevNote.noteType == 3 || prevNote.noteType == 4 || prevNote.noteType == 5 || prevNote.noteType == 6 || prevNote.noteType == 7
				|| prevNote.noteType == 9))
		{
			this.kill();
		}

		if (player3Note)
		{
			canBeHit = false;

			if (strumTime <= Conductor.songPosition)
				wasGoodHit = true;
		}

		if (mustPress)
		{
			// ass

			switch (noteType)
			{
				case 1 | 3 | 4 | 7 | 9 | 10 | 13: // blue, ink, death, flash notes, tunnel, fire
					{
						if (strumTime > Conductor.songPosition - (Conductor.safeZoneOffset * 0.2)
							&& strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * 0.2))
							canBeHit = true;
						else
							canBeHit = false;
					}
				case 2:
					{
						if (strumTime > Conductor.songPosition - (Conductor.safeZoneOffset * 1.2)
							&& strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * 1.2))
							canBeHit = true;
						else
							canBeHit = false;
					}
				default:
					{
						if (isSustainNote)
						{
							if (strumTime > Conductor.songPosition - (Conductor.safeZoneOffset * 1.5)
								&& strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * 0.5))
								canBeHit = true;
							else
								canBeHit = false;
						}
						else
						{
							if (strumTime > Conductor.songPosition - Conductor.safeZoneOffset
								&& strumTime < Conductor.songPosition + Conductor.safeZoneOffset)
								canBeHit = true;
							else
								canBeHit = false;
						}
					}
			}

			if (strumTime < Conductor.songPosition - Conductor.safeZoneOffset * Conductor.timeScale && !wasGoodHit)
				tooLate = true;
		}
		else
		{
			canBeHit = false;

			if (strumTime <= Conductor.songPosition)
				wasGoodHit = true;
		}

		if (tooLate)
		{
			if (alpha > 0.3)
				alpha = 0.3;
		}
	}
}
