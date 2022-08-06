package;

import Conductor.BPMChangeEvent;
import Section.SwagSection;
import Song.SwagSong;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUITabMenu;
import flixel.addons.ui.FlxUIText;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import haxe.Json;
import haxe.ValueException;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.net.FileReference;

using StringTools;

class ChartingState extends MusicBeatState
{
	var _file:FileReference;

	public var playClaps:Bool = false;

	public var snap:Int = 1;

	var UI_box:FlxUITabMenu;

	/**
	 * Array of notes showing when each section STARTS in STEPS
	 * Usually rounded up??
	 */
	var curSection:Int = 0;

	public static var lastSection:Int = 0;

	var bpmTxt:FlxText;

	var strumLine:FlxSprite;
	var curSong:String = 'Dad Battle';
	var amountSteps:Int = 0;

	var bullshitUI:FlxGroup;
	var writingNotesText:FlxText;
	var highlight:FlxSprite;

	var GRID_SIZE:Int = 40;

	var dummyArrow:FlxSprite;

	var noEscape:Bool = false;

	var curRenderedNotes:FlxTypedGroup<Note>;
	var curRenderedSustains:FlxTypedGroup<FlxSprite>;

	var gridBG:FlxSprite;

	var _song:SwagSong;

	var typingShit:FlxInputText;
	/*
	 * WILL BE THE CURRENT / LAST PLACED NOTE
	**/
	var curSelectedNote:Array<Dynamic>;

	var tempBpm:Float = 0;
	var gridBlackLine:FlxSprite;
	var gridBlackLine2:FlxSprite;
	var vocals:FlxSound;

	var player2:Character = new Character(0, 0, "dad");
	var player1:Boyfriend = new Boyfriend(0, 0, "bf");

	var leftIcon:HealthIcon;
	var rightIcon:HealthIcon;
	var player3Icon:HealthIcon;

	private var lastNote:Note;
	var bendy:FlxSprite;
	var cuphead:FlxSprite;
	var sans:FlxSprite;
	var jumpscareStatic:FlxSprite;
	var scare:FlxSound;
	var claps:Array<Note> = [];

	public var snapText:FlxText;

	var currType:Int = 0;
	var leBG:FlxSprite;

	override function create()
	{
		super.create();
		
		setBrightness(0);
		
		curSection = lastSection;

		if (PlayState.SONG != null)
			_song = PlayState.SONG;
		else
		{
			_song = {
				song: 'Test',
				notes: [],
				bpm: 150,
				needsVoices: true,
				player1: 'bf',
				player2: 'dad',
				player3: null,
				gfVersion: 'gf',
				noteStyle: 'normal',
				stage: 'stage',
				speed: 1,
				validScore: false
			};
		}

		// -100, -400
		leBG = new FlxSprite(0, 0).loadGraphic(Paths.image('menu/BGwhite', 'preload'));
		leBG.scrollFactor.set();
		leBG.updateHitbox();
		leBG.screenCenter();
		leBG.antialiasing = FlxG.save.data.highquality;
		add(leBG);

		var blackBorder:FlxSprite = new FlxSprite(60, 10).makeGraphic(120, 100, FlxColor.BLACK);
		blackBorder.scrollFactor.set();

		blackBorder.alpha = 0.3;

		switch (_song.song.toLowerCase())
		{
			case 'bonedoggle':
				gridBG = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, GRID_SIZE * 12, GRID_SIZE * 16);
				add(gridBG);

				gridBlackLine = new FlxSprite(gridBG.x + gridBG.width / 3).makeGraphic(2, Std.int(gridBG.height), FlxColor.BLACK);
				add(gridBlackLine);

				gridBlackLine2 = new FlxSprite(gridBG.x + gridBG.width / 1.5).makeGraphic(2, Std.int(gridBG.height), FlxColor.BLACK);
				add(gridBlackLine2);
			default:
				gridBG = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, GRID_SIZE * 8, GRID_SIZE * 16);
				add(gridBG);

				gridBlackLine = new FlxSprite(gridBG.x + gridBG.width / 2).makeGraphic(2, Std.int(gridBG.height), FlxColor.BLACK);
				add(gridBlackLine);
		}

		snapText = new FlxText(60, 10, 0, "Snap: 1/" + snap + " (Press Control to unsnap the cursor)\nAdd Notes: 1-8 (or click)\n", 14);
		snapText.scrollFactor.set();

		curRenderedNotes = new FlxTypedGroup<Note>();
		curRenderedSustains = new FlxTypedGroup<FlxSprite>();

		FlxG.mouse.visible = true;

		tempBpm = _song.bpm;

		addSection();

		// sections = _song.notes;

		updateGrid();

		loadSong(_song.song);
		Conductor.changeBPM(_song.bpm);
		Conductor.mapBPMChanges(_song);

		leftIcon = new HealthIcon("bf");
		rightIcon = new HealthIcon("dad");
		leftIcon.scrollFactor.set(1, 1);
		rightIcon.scrollFactor.set(1, 1);

		leftIcon.setGraphicSize(0, 45);
		rightIcon.setGraphicSize(0, 45);

		add(leftIcon);
		add(rightIcon);

		leftIcon.setPosition(0, -100);
		rightIcon.setPosition(gridBG.width / 2, -100);
		if (_song.song.toLowerCase() == 'bonedoggle')
		{
			rightIcon.setPosition(gridBG.width / 3, -100);
			player3Icon = new HealthIcon(_song.player3);
			player3Icon.scrollFactor.set(1, 1);
			player3Icon.setGraphicSize(0, 45);
			player3Icon.setPosition(gridBG.width / 1.5, -100);
			add(player3Icon);
		}

		bpmTxt = new FlxText(1000, 50, 0, "", 16);
		bpmTxt.scrollFactor.set();
		add(bpmTxt);

		strumLine = new FlxSprite(0, 50).makeGraphic(Std.int(FlxG.width / 2), 4);
		add(strumLine);

		dummyArrow = new FlxSprite().makeGraphic(GRID_SIZE, GRID_SIZE);
		add(dummyArrow);

		var tabs = [
			{name: "Song", label: 'Song Data'},
			{name: "Section", label: 'Section Data'},
			{name: "Note", label: 'Note Data'}
		];

		UI_box = new FlxUITabMenu(null, tabs, true);

		UI_box.resize(300, 400);
		UI_box.x = FlxG.width / 2;
		UI_box.y = 20;
		if (_song.song.toLowerCase() == 'bonedoggle')
		{
			UI_box.x += 170;
			UI_box.y = 150;
		}
		add(UI_box);

		addSongUI();
		addSectionUI();
		addNoteUI();

		add(curRenderedNotes);
		add(curRenderedSustains);

		add(blackBorder);
		add(snapText);

		bendy = new FlxSprite(-410, -980);
		bendy.frames = Paths.getSparrowAtlas('bonusSongs/NightmareJumpscares03', 'shared');
		bendy.animation.addByPrefix('play', 'Emmi instance 1', 24, false);
		bendy.antialiasing = FlxG.save.data.highquality;
		bendy.updateHitbox();
		bendy.scrollFactor.set();
		bendy.alpha = 0;
		add(bendy);

		cuphead = new FlxSprite(-900, -800);
		cuphead.frames = Paths.getSparrowAtlas('bonusSongs/NightmareJumpscares01', 'shared');
		cuphead.animation.addByPrefix('play', 'CupScare instance 1', 24, false);
		cuphead.antialiasing = FlxG.save.data.highquality;
		cuphead.updateHitbox();
		cuphead.scrollFactor.set();
		cuphead.alpha = 0;
		add(cuphead);

		sans = new FlxSprite(-210, -630);
		sans.frames = Paths.getSparrowAtlas('bonusSongs/NightmareJumpscares02', 'shared');
		sans.animation.addByPrefix('play', 'Wussup Bitch instance 1', 24, false);
		sans.antialiasing = FlxG.save.data.highquality;
		sans.updateHitbox();
		sans.scrollFactor.set();
		sans.alpha = 0;
		add(sans);

		jumpscareStatic = new FlxSprite(0, 0);
		jumpscareStatic.frames = Paths.getSparrowAtlas('bonusSongs/static', 'shared');
		jumpscareStatic.animation.addByPrefix('static', 'static', 24, true);
		jumpscareStatic.antialiasing = FlxG.save.data.highquality;
		jumpscareStatic.updateHitbox();
		jumpscareStatic.scrollFactor.set();
		jumpscareStatic.alpha = 1.0;
		jumpscareStatic.setGraphicSize(Std.int(jumpscareStatic.width * 1.3));
		jumpscareStatic.screenCenter();
		jumpscareStatic.visible = false;
		add(jumpscareStatic);

		if (!MainMenuState.debugTools)
		{
			if (PlayState.SONG.song.toLowerCase() == 'devils-gambit' || PlayState.SONG.song.toLowerCase() == 'bad-time' || PlayState.SONG.song.toLowerCase() == 'despair')
				noEscape = true;
		}
	}

	function addSongUI():Void
	{
		var UI_songTitle = new FlxUIInputText(10, 10, 70, _song.song, 8);
		typingShit = UI_songTitle;

		var check_voices = new FlxUICheckBox(10, 25, null, null, "Has voice track", 100);
		check_voices.checked = _song.needsVoices;
		// _song.needsVoices = check_voices.checked;
		check_voices.callback = function()
		{
			_song.needsVoices = check_voices.checked;
			trace('CHECKED!');
		};

		var check_mute_inst = new FlxUICheckBox(10, 200, null, null, "Mute Instrumental (in editor)", 100);
		check_mute_inst.checked = false;
		check_mute_inst.callback = function()
		{
			var vol:Float = 1;

			if (check_mute_inst.checked)
				vol = 0;

			FlxG.sound.music.volume = vol;
		};

		var saveButton:FlxButton = new FlxButton(110, 8, "Save", function()
		{
			saveLevel();
		});

		var reloadSong:FlxButton = new FlxButton(saveButton.x + saveButton.width + 10, saveButton.y, "Reload Audio", function()
		{
			loadSong(_song.song);
		});

		var reloadSongJson:FlxButton = new FlxButton(reloadSong.x, saveButton.y + 30, "Reload JSON", function()
		{
			loadJson(_song.song.toLowerCase());
		});

		var restart = new FlxButton(10, 140, "Reset Chart", function()
		{
			for (ii in 0..._song.notes.length)
			{
				for (i in 0..._song.notes[ii].sectionNotes.length)
				{
					_song.notes[ii].sectionNotes = [];
				}
			}
			resetSection(true);
		});

		var loadAutosaveBtn:FlxButton = new FlxButton(reloadSongJson.x, reloadSongJson.y + 30, 'load autosave', loadAutosave);
		var stepperBPM:FlxUINumericStepper = new FlxUINumericStepper(10, 65, 0.1, 1, 1.0, 5000.0, 1);
		stepperBPM.value = Conductor.bpm;
		stepperBPM.name = 'song_bpm';

		var stepperBPMLabel = new FlxText(74, 65, 'BPM');

		var stepperSpeed:FlxUINumericStepper = new FlxUINumericStepper(10, 80, 0.1, 1, 0.1, 10, 1);
		stepperSpeed.value = _song.speed;
		stepperSpeed.name = 'song_speed';

		var stepperSpeedLabel = new FlxText(74, 80, 'Scroll Speed');

		var stepperVocalVol:FlxUINumericStepper = new FlxUINumericStepper(10, 95, 0.1, 1, 0.1, 10, 1);
		stepperVocalVol.value = vocals.volume;
		stepperVocalVol.name = 'song_vocalvol';

		var stepperVocalVolLabel = new FlxText(74, 95, 'Vocal Volume');

		var stepperSongVol:FlxUINumericStepper = new FlxUINumericStepper(10, 110, 0.1, 1, 0.1, 10, 1);
		stepperSongVol.value = FlxG.sound.music.volume;
		stepperSongVol.name = 'song_instvol';

		var hitsounds = new FlxUICheckBox(10, stepperSongVol.y + 60, null, null, "Play hitsounds", 100);
		hitsounds.checked = false;
		hitsounds.callback = function()
		{
			playClaps = hitsounds.checked;
		};

		var stepperSongVolLabel = new FlxText(74, 110, 'Instrumental Volume');

		var shiftNoteDialLabel = new FlxText(10, 245, 'Shift Note FWD by (Section)');
		var stepperShiftNoteDial:FlxUINumericStepper = new FlxUINumericStepper(10, 260, 1, 0, -1000, 1000, 0);
		stepperShiftNoteDial.name = 'song_shiftnote';
		var shiftNoteDialLabel2 = new FlxText(10, 275, 'Shift Note FWD by (Step)');
		var stepperShiftNoteDialstep:FlxUINumericStepper = new FlxUINumericStepper(10, 290, 1, 0, -1000, 1000, 0);
		stepperShiftNoteDialstep.name = 'song_shiftnotems';
		var shiftNoteDialLabel3 = new FlxText(10, 305, 'Shift Note FWD by (ms)');
		var stepperShiftNoteDialms:FlxUINumericStepper = new FlxUINumericStepper(10, 320, 1, 0, -1000, 1000, 2);
		stepperShiftNoteDialms.name = 'song_shiftnotems';

		var shiftNoteButton:FlxButton = new FlxButton(10, 335, "Shift", function()
		{
			shiftNotes(Std.int(stepperShiftNoteDial.value), Std.int(stepperShiftNoteDialstep.value), Std.int(stepperShiftNoteDialms.value));
		});

		_song.player1 = 'bf';

		_song.player2 = 'dad';

		_song.player3 = 'dad';

		_song.gfVersion = 'gf';

		_song.stage = 'stage';

		_song.noteStyle = 'normal';

		var tab_group_song = new FlxUI(null, UI_box);
		tab_group_song.name = "Song";
		tab_group_song.add(UI_songTitle);
		tab_group_song.add(restart);
		tab_group_song.add(check_voices);
		tab_group_song.add(check_mute_inst);
		tab_group_song.add(saveButton);
		tab_group_song.add(reloadSong);
		tab_group_song.add(reloadSongJson);
		tab_group_song.add(loadAutosaveBtn);
		tab_group_song.add(stepperBPM);
		tab_group_song.add(stepperBPMLabel);
		tab_group_song.add(stepperSpeed);
		tab_group_song.add(stepperSpeedLabel);
		tab_group_song.add(stepperVocalVol);
		tab_group_song.add(stepperVocalVolLabel);
		tab_group_song.add(stepperSongVol);
		tab_group_song.add(stepperSongVolLabel);
		tab_group_song.add(shiftNoteDialLabel);
		tab_group_song.add(stepperShiftNoteDial);
		tab_group_song.add(shiftNoteDialLabel2);
		tab_group_song.add(stepperShiftNoteDialstep);
		tab_group_song.add(shiftNoteDialLabel3);
		tab_group_song.add(stepperShiftNoteDialms);
		tab_group_song.add(shiftNoteButton);
		tab_group_song.add(hitsounds);

		UI_box.addGroup(tab_group_song);
		UI_box.scrollFactor.set();

		FlxG.camera.follow(strumLine);
	}

	var stepperLength:FlxUINumericStepper;
	var check_mustHitSection:FlxUICheckBox;
	var check_focusCamOnPlayer3:FlxUICheckBox;
	var check_changeBPM:FlxUICheckBox;
	var stepperSectionBPM:FlxUINumericStepper;
	var stepperType:FlxUINumericStepper;
	var check_altAnim:FlxUICheckBox;
	var typeNameTxt:FlxText;
	var typeNames:Array<String> = [
		'Normal', 'Blue bone', 'Orange bone', 'Ink', 'Black Death', 'Parry', 'Tricky', 'Flash', 'Tunnel Normal', 'Tunnel Death', 'Tunnel Ink', 'Bounce',
		'Bounce orange', 'Fire note'
	];

	function addSectionUI():Void
	{
		var tab_group_section = new FlxUI(null, UI_box);
		tab_group_section.name = 'Section';

		stepperLength = new FlxUINumericStepper(10, 10, 4, 0, 0, 999, 0);
		stepperLength.value = _song.notes[curSection].lengthInSteps;
		stepperLength.name = "section_length";

		var stepperLengthLabel = new FlxText(74, 10, 'Section Length (in steps)');

		stepperSectionBPM = new FlxUINumericStepper(10, 80, 1, Conductor.bpm, 0, 999, 0);
		stepperSectionBPM.value = Conductor.bpm;
		stepperSectionBPM.name = 'section_bpm';

		var tx = 150;
		var ty = 400;
		stepperType = new FlxUINumericStepper(tx, ty, 1, currType, 0, typeNames.length - 1, 0);
		stepperType.value = currType;
		stepperType.name = 'note_type';
		stepperType.scrollFactor.set();

		typeNameTxt = new FlxText(tx, ty + 20, 0, 'Normal notes', 12);
		typeNameTxt.scrollFactor.set();
		typeNameTxt.color = 0xFFFFFFFF;
		add(typeNameTxt);

		var stepperCopy:FlxUINumericStepper = new FlxUINumericStepper(110, 132, 1, 1, -999, 999, 0);
		var stepperCopyLabel = new FlxText(174, 132, 'sections back');

		var copyButton:FlxButton = new FlxButton(10, 130, "Copy last section", function()
		{
			copySection(Std.int(stepperCopy.value));
		});

		var clearSectionButton:FlxButton = new FlxButton(10, 150, "Clear Section", clearSection);

		var swapSection:FlxButton = new FlxButton(10, 170, "Swap Section", function()
		{
			for (i in 0..._song.notes[curSection].sectionNotes.length)
			{
				var note = _song.notes[curSection].sectionNotes[i];
				var nT = Math.floor(note[1] / Main.dataJump);
				note[1] = (note[1] + 4) % 8 + nT * Main.dataJump;
				_song.notes[curSection].sectionNotes[i] = note;
				updateGrid();
			}
		});
		check_mustHitSection = new FlxUICheckBox(10, 30, null, null, "Camera Points to P1?", 100);
		check_mustHitSection.name = 'check_mustHit';
		check_mustHitSection.checked = true;

		check_focusCamOnPlayer3 = new FlxUICheckBox(140, 30, null, null, "Camera Points to P3?", 100);
		check_focusCamOnPlayer3.name = 'check_focusCamPlayer3';
		check_focusCamOnPlayer3.checked = false;
		// _song.needsVoices = check_mustHit.checked;

		check_altAnim = new FlxUICheckBox(10, 400, null, null, "Alternate Animation", 100);
		check_altAnim.name = 'check_altAnim';

		check_changeBPM = new FlxUICheckBox(10, 60, null, null, 'Change BPM', 100);
		check_changeBPM.name = 'check_changeBPM';

		tab_group_section.add(stepperLength);
		tab_group_section.add(stepperLengthLabel);
		tab_group_section.add(stepperSectionBPM);
		tab_group_section.add(stepperCopy);
		tab_group_section.add(stepperCopyLabel);
		tab_group_section.add(check_mustHitSection);

		if (_song.song.toLowerCase() == 'bonedoggle')
			tab_group_section.add(check_focusCamOnPlayer3);

		tab_group_section.add(check_altAnim);
		tab_group_section.add(check_changeBPM);
		tab_group_section.add(copyButton);
		tab_group_section.add(clearSectionButton);
		tab_group_section.add(swapSection);
		add(stepperType);

		UI_box.addGroup(tab_group_section);
	}

	var stepperSusLength:FlxUINumericStepper;

	var tab_group_note:FlxUI;

	function addNoteUI():Void
	{
		tab_group_note = new FlxUI(null, UI_box);
		tab_group_note.name = 'Note';

		writingNotesText = new FlxUIText(20, 100, 0, "");
		writingNotesText.setFormat("Arial", 20, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);

		stepperSusLength = new FlxUINumericStepper(10, 10, Conductor.stepCrochet / 2, 0, 0, Conductor.stepCrochet * _song.notes[curSection].lengthInSteps * 4);
		stepperSusLength.value = 0;
		stepperSusLength.name = 'note_susLength';

		var stepperSusLengthLabel = new FlxText(74, 10, 'Note Sustain Length');

		var applyLength:FlxButton = new FlxButton(10, 100, 'Apply Data');

		tab_group_note.add(stepperSusLength);
		tab_group_note.add(stepperSusLengthLabel);
		tab_group_note.add(applyLength);

		UI_box.addGroup(tab_group_note);

		/*player2 = new Character(0,gridBG.y, _song.player2);
			player1 = new Boyfriend(player2.width * 0.2,gridBG.y + player2.height, _song.player1);

			player1.y = player1.y - player1.height;

			player2.setGraphicSize(Std.int(player2.width * 0.2));
			player1.setGraphicSize(Std.int(player1.width * 0.2));

			UI_box.add(player1);
			UI_box.add(player2); */
	}

	function loadSong(daSong:String):Void
	{
		if (FlxG.sound.music != null)
		{
			FlxG.sound.music.stop();
			// vocals.stop();
		}

		if (Main.hiddenSongs.contains(daSong.toLowerCase()))
		{
			FlxG.sound.playMusic(Paths.instHidden(daSong), 0.6);
			vocals = new FlxSound().loadEmbedded(Paths.voicesHidden(daSong));
		}
		else
		{
			FlxG.sound.playMusic(Paths.inst(daSong), 0.6);
			vocals = new FlxSound().loadEmbedded(Paths.voices(daSong));
		}

		// WONT WORK FOR TUTORIAL OR TEST SONG!!! REDO LATER
		FlxG.sound.list.add(vocals);

		FlxG.sound.music.pause();
		vocals.pause();

		FlxG.sound.music.onComplete = function()
		{
			vocals.pause();
			vocals.time = 0;
			FlxG.sound.music.pause();
			FlxG.sound.music.time = 0;
			changeSection();
		};
	}

	function generateUI():Void
	{
		while (bullshitUI.members.length > 0)
		{
			bullshitUI.remove(bullshitUI.members[0], true);
		}

		// general shit
		var title:FlxText = new FlxText(UI_box.x + 20, UI_box.y + 20, 0);
		bullshitUI.add(title);
		/* 
			var loopCheck = new FlxUICheckBox(UI_box.x + 10, UI_box.y + 50, null, null, "Loops", 100, ['loop check']);
			loopCheck.checked = curNoteSelected.doesLoop;
			tooltips.add(loopCheck, {title: 'Section looping', body: "Whether or not it's a simon says style section", style: tooltipType});
			bullshitUI.add(loopCheck);

		 */
	}

	override function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>)
	{
		if (id == FlxUICheckBox.CLICK_EVENT)
		{
			var check:FlxUICheckBox = cast sender;
			var label = check.getLabel().text;
			switch (label)
			{
				case 'Camera Points to P1?':
					_song.notes[curSection].mustHitSection = check.checked;
				case 'Camera Points to P3?':
					_song.notes[curSection].focusCamOnPlayer3 = check.checked;
				case 'Change BPM':
					_song.notes[curSection].changeBPM = check.checked;
					FlxG.log.add('changed bpm shit');
				case "Alternate Animation":
					_song.notes[curSection].altAnim = check.checked;
			}
		}
		else if (id == FlxUINumericStepper.CHANGE_EVENT && (sender is FlxUINumericStepper))
		{
			var nums:FlxUINumericStepper = cast sender;
			var wname = nums.name;
			FlxG.log.add(wname);
			if (wname == 'section_length')
			{
				if (nums.value <= 4)
					nums.value = 4;
				_song.notes[curSection].lengthInSteps = Std.int(nums.value);
				updateGrid();
			}
			else if (wname == 'song_speed')
			{
				if (nums.value <= 0)
					nums.value = 0;
				_song.speed = nums.value;
			}
			else if (wname == 'song_bpm')
			{
				if (nums.value <= 0)
					nums.value = 1;
				tempBpm = Std.int(nums.value);
				Conductor.mapBPMChanges(_song);
				Conductor.changeBPM(Std.int(nums.value));
			}
			else if (wname == 'note_susLength')
			{
				if (curSelectedNote == null)
					return;

				if (nums.value <= 0)
					nums.value = 0;
				curSelectedNote[2] = nums.value;
				updateGrid();
			}
			else if (wname == 'section_bpm')
			{
				if (nums.value <= 0.1)
					nums.value = 0.1;
				_song.notes[curSection].bpm = Std.int(nums.value);
				updateGrid();
			}
			else if (wname == 'song_vocalvol')
			{
				if (nums.value <= 0.1)
					nums.value = 0.1;
				vocals.volume = nums.value;
			}
			else if (wname == 'song_instvol')
			{
				if (nums.value <= 0.1)
					nums.value = 0.1;
				FlxG.sound.music.volume = nums.value;
			}
			else if (wname == 'note_type')
			{
				currType = Std.int(nums.value);
				typeNameTxt.text = typeNames[currType] + ' notes';
				// updateGrid();
			}
		}

		// FlxG.log.add(id + " WEED " + sender + " WEED " + data + " WEED " + params);
	}

	var updatedSection:Bool = false;

	/* this function got owned LOL
		function lengthBpmBullshit():Float
		{
			if (_song.notes[curSection].changeBPM)
				return _song.notes[curSection].lengthInSteps * (_song.notes[curSection].bpm / _song.bpm);
			else
				return _song.notes[curSection].lengthInSteps;
	}*/
	function stepStartTime(step):Float
	{
		return _song.bpm / (step / 4) / 60;
	}

	function sectionStartTime():Float
	{
		var daBPM:Float = _song.bpm;
		var daPos:Float = 0;
		for (i in 0...curSection)
		{
			if (_song.notes[i].changeBPM)
			{
				daBPM = _song.notes[i].bpm;
			}
			daPos += 4 * (1000 * 60 / daBPM);
		}
		return daPos;
	}

	var writingNotes:Bool = false;
	var doSnapShit:Bool = true;

	var subDiv = 1;

	override function update(elapsed:Float)
	{
		updateHeads();

		snapText.text = "Snap: 1/"
			+ snap
			+ " ("
			+ (doSnapShit ? "Control to disable" : "Snap Disabled, Control to renable")
			+ ")\nAdd Notes: 1-8 (or click)\n\n"
			+ 'Subdivisions (press F/G): '
			+ subDiv
			+ '\n';

		var ls = subDiv;
		if (FlxG.keys.justPressed.G)
			subDiv++;
		if (FlxG.keys.justPressed.F)
			subDiv--;

		if (subDiv < 1)
			subDiv = 1;

		if (subDiv != ls)
		{
			remove(dummyArrow);
			dummyArrow.destroy();
			dummyArrow = new FlxSprite().makeGraphic(GRID_SIZE, Std.int(GRID_SIZE / subDiv));
			add(dummyArrow);
		}

		curStep = recalculateSteps();

		/*if (FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.RIGHT)
				snap = snap * 2;
			if (FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.LEFT)
				snap = Math.round(snap / 2);
			if (snap >= 192)
				snap = 192;
			if (snap <= 1)
				snap = 1; */

		if (FlxG.keys.justPressed.CONTROL)
			doSnapShit = !doSnapShit;

		Conductor.songPosition = FlxG.sound.music.time;
		_song.song = typingShit.text;

		var left = FlxG.keys.justPressed.ONE;
		var down = FlxG.keys.justPressed.TWO;
		var up = FlxG.keys.justPressed.THREE;
		var right = FlxG.keys.justPressed.FOUR;
		var leftO = FlxG.keys.justPressed.FIVE;
		var downO = FlxG.keys.justPressed.SIX;
		var upO = FlxG.keys.justPressed.SEVEN;
		var rightO = FlxG.keys.justPressed.EIGHT;

		var pressArray = [left, down, up, right, leftO, downO, upO, rightO, leftO, downO, upO, rightO];
		var delete = false;
		curRenderedNotes.forEach(function(note:Note)
		{
			if (strumLine.overlaps(note) && pressArray[Math.floor(Math.abs(note.noteData))])
			{
				deleteNote(note);
				delete = true;
				trace('deelte note');
			}
		});
		for (p in 0...pressArray.length)
		{
			var i = pressArray[p];
			if (i && !delete)
			{
				addNote(new Note(Conductor.songPosition, p));
			}
		}

		strumLine.y = getYfromStrum((Conductor.songPosition - sectionStartTime()) % (Conductor.stepCrochet * _song.notes[curSection].lengthInSteps));

		if (playClaps)
		{
			curRenderedNotes.forEach(function(note:Note)
			{
				if (FlxG.sound.music.playing)
				{
					FlxG.overlap(strumLine, note, function(_, _)
					{
						if (!claps.contains(note))
						{
							claps.push(note);
							FlxG.sound.play(Paths.sound('SNAP'));
						}
					});
				}
			});
		}
		
		if (curBeat % 4 == 0 && curStep >= 16 * (curSection + 1))
		{
			trace(curStep);
			trace((_song.notes[curSection].lengthInSteps) * (curSection + 1));
			trace('DUMBSHIT');

			if (_song.notes[curSection + 1] == null)
			{
				addSection();
			}

			changeSection(curSection + 1, false);
		}

		FlxG.watch.addQuick('daBeat', curBeat);
		FlxG.watch.addQuick('daStep', curStep);

		if (FlxG.sound.music.playing) {}

		if (FlxG.mouse.justPressed)
		{
			if (!MainMenuState.debugTools)
			{
				if (PlayState.SONG.song.toLowerCase() == 'despair' && bendy.alpha == 0)
				{
					bendy.alpha = 1;
					bendy.animation.play('play');
					jumpscareStatic.animation.play('static');
					FlxG.sound.play(Paths.sound('Lights_Turn_On'));
					FlxG.sound.play(Paths.sound('scare_bendy'));
	
					FlxG.sound.music.pause();
					vocals.pause();
	
					FlxTransitionableState.skipNextTransIn = true;
					FlxTransitionableState.skipNextTransOut = true;
	
					new FlxTimer().start(0.66, function(tmr:FlxTimer)
					{
						jumpscareStatic.visible = true;
						FlxTween.color(jumpscareStatic, 1.85, FlxColor.WHITE, FlxColor.BLACK, {ease: FlxEase.quadOut});
						bendy.alpha = 0.0;
					});
	
					JumpscareState.allowRetry = false;
					new FlxTimer().start(3, function(tmr:FlxTimer)
					{
						Main.switchState(new JumpscareState());
					});
				}
	
				if (PlayState.SONG.song.toLowerCase() == 'devils-gambit' && cuphead.alpha == 0)
				{
					cuphead.alpha = 1;
					cuphead.animation.play('play');
					jumpscareStatic.animation.play('static');
					FlxG.sound.play(Paths.sound('Lights_Turn_On'));
					FlxG.sound.play(Paths.sound('scare_cuphead'));
	
					FlxTransitionableState.skipNextTransIn = true;
					FlxTransitionableState.skipNextTransOut = true;
	
					new FlxTimer().start(0.91, function(tmr:FlxTimer)
					{
						jumpscareStatic.visible = true;
						FlxTween.color(jumpscareStatic, 1.85, FlxColor.WHITE, FlxColor.BLACK, {ease: FlxEase.quadOut});
						cuphead.alpha = 0.0;
					});
	
					JumpscareState.allowRetry = false;
					new FlxTimer().start(3, function(tmr:FlxTimer)
					{
						Main.switchState(new JumpscareState());
					});
				}
	
				if (PlayState.SONG.song.toLowerCase() == 'bad-time' && sans.alpha == 0)
				{
					sans.alpha = 1;
					sans.animation.play('play');
					jumpscareStatic.animation.play('static');
					FlxG.sound.play(Paths.sound('Lights_Turn_On'));
					FlxG.sound.play(Paths.sound('scare_sans'));
	
					FlxTransitionableState.skipNextTransIn = true;
					FlxTransitionableState.skipNextTransOut = true;
	
					new FlxTimer().start(0.875, function(tmr:FlxTimer)
					{
						jumpscareStatic.visible = true;
						FlxTween.color(jumpscareStatic, 1.85, FlxColor.WHITE, FlxColor.BLACK, {ease: FlxEase.quadOut});
						sans.alpha = 0.0;
					});
	
					JumpscareState.allowRetry = false;
					new FlxTimer().start(3, function(tmr:FlxTimer)
					{
						Main.switchState(new JumpscareState());
					});
				}
			}

			if (FlxG.mouse.overlaps(curRenderedNotes))
			{
				curRenderedNotes.forEach(function(note:Note)
				{
					if (FlxG.mouse.overlaps(note))
					{
						if (FlxG.keys.pressed.CONTROL)
						{
							selectNote(note);
						}
						else
						{
							deleteNote(note);
						}
					}
				});
			}
			else
			{
				if (FlxG.mouse.x > gridBG.x
					&& FlxG.mouse.x < gridBG.x + gridBG.width
					&& FlxG.mouse.y > gridBG.y
					&& FlxG.mouse.y < gridBG.y + (GRID_SIZE * _song.notes[curSection].lengthInSteps))
				{
					FlxG.log.add('added note');
					addNote();
				}
			}
		}

		if (FlxG.mouse.x > gridBG.x
			&& FlxG.mouse.x < gridBG.x + gridBG.width
			&& FlxG.mouse.y > gridBG.y
			&& FlxG.mouse.y < gridBG.y + (GRID_SIZE * _song.notes[curSection].lengthInSteps))
		{
			dummyArrow.x = Math.floor(FlxG.mouse.x / GRID_SIZE) * GRID_SIZE;

			var space = GRID_SIZE / subDiv;
			if (FlxG.keys.pressed.SHIFT)
				dummyArrow.y = FlxG.mouse.y;
			else
				dummyArrow.y = Math.floor(FlxG.mouse.y / space) * space;
		}
		if (FlxG.keys.justPressed.ANY)
		{
			if (PlayState.SONG.song.toLowerCase() == 'despair' && bendy.alpha == 0 && !MainMenuState.debugTools)
			{
				bendy.alpha = 1;
				bendy.animation.play('play');
				jumpscareStatic.animation.play('static');
				FlxG.sound.play(Paths.sound('scare_bendy'));
				FlxG.sound.music.pause();
				vocals.pause();
				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;
				new FlxTimer().start(0.66, function(tmr:FlxTimer)
				{
					jumpscareStatic.visible = true;
					FlxTween.color(jumpscareStatic, 1.85, FlxColor.WHITE, FlxColor.BLACK, {ease: FlxEase.quadOut});
				});

				JumpscareState.allowRetry = false;
				new FlxTimer().start(3, function(tmr:FlxTimer)
				{
					Main.switchState(new JumpscareState());
				});
			}
			if (PlayState.SONG.song.toLowerCase() == 'devils-gambit' && cuphead.alpha == 0 && !MainMenuState.debugTools)
			{
				cuphead.alpha = 1;
				cuphead.animation.play('play');
				jumpscareStatic.animation.play('static');
				FlxG.sound.play(Paths.sound('scare_cuphead'));
				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;
				new FlxTimer().start(0.91, function(tmr:FlxTimer)
				{
					jumpscareStatic.visible = true;
					FlxTween.color(jumpscareStatic, 1.85, FlxColor.WHITE, FlxColor.BLACK, {ease: FlxEase.quadOut});
				});

				JumpscareState.allowRetry = false;
				new FlxTimer().start(3, function(tmr:FlxTimer)
				{
					Main.switchState(new JumpscareState());
				});
			}
			if (PlayState.SONG.song.toLowerCase() == 'bad-time' && sans.alpha == 0 && !MainMenuState.debugTools)
			{
				sans.alpha = 1;
				sans.animation.play('play');
				jumpscareStatic.animation.play('static');
				FlxG.sound.play(Paths.sound('scare_sans'));
				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;
				new FlxTimer().start(0.875, function(tmr:FlxTimer)
				{
					jumpscareStatic.visible = true;
					FlxTween.color(jumpscareStatic, 1.85, FlxColor.WHITE, FlxColor.BLACK, {ease: FlxEase.quadOut});
				});

				JumpscareState.allowRetry = false;
				new FlxTimer().start(3, function(tmr:FlxTimer)
				{
					Main.switchState(new JumpscareState());
				});
			}
		}
		if (sans.alpha == 1 || bendy.alpha == 1 || cuphead.alpha == 1) // cam shake and zoom if jumpscare is active
		{
			FlxG.camera.zoom = FlxMath.lerp(FlxG.camera.zoom, 1.35, 0.08);
			camera.shake(0.010, 0.015);
		}

		if (FlxG.keys.justPressed.ENTER && !noEscape)
		{
			// let only us cheat to get the secret song because we are the devs
			// therefore we control the game
			// therefore we control YOU :)
			// look behind you
			var notAllowed:Array<String> = [
				'gose', 'saness', 'satanic-funkin', 'bad-to-the-bone', 'bonedoggle', 'ritual', 'freaky-machine', 'devils-gambit', 'bad-time', 'despair', 'burning-in-hell', 'final-stretch'
			];

			for (i in 0...notAllowed.length)
			{
				if ((!_song.song.toLowerCase().contains(notAllowed[i]) || MainMenuState.debugTools)
				|| (FlxG.save.data.hasgenocided && _song.song.toLowerCase() == 'burning-in-hell') || (FlxG.save.data.haspacifisted && _song.song.toLowerCase() == 'final-stretch')
				|| (FlxG.save.data.weeksbeat[0] && _song.song.toLowerCase() == 'statanic-funkin')
				|| (FlxG.save.data.weeksbeat[1] && (FlxG.save.data.hasgenocided && _song.song.toLowerCase() == 'bad-to-the-bone') || (FlxG.save.data.haspacifisted && _song.song.toLowerCase() == 'bonedoggle'))
				|| (FlxG.save.data.weeksbeat[2] && (_song.song.toLowerCase() == 'ritual' || _song.song.toLowerCase() == 'freaky-machine'))
				)
				{
					lastSection = curSection;
					PlayState.SONG = _song;
					FlxG.sound.music.stop();
					vocals.stop();
					LoadingState.target = new PlayState();
					LoadingState.stopMusic = true;
					FlxG.switchState(new LoadingState());
				}
				else
				{
					throw new ValueException("You really thought it was funny to get the secret song by cheating?");
				}
			}
		}

		if (FlxG.keys.justPressed.BACKSPACE && !noEscape)
		{
			lastSection = curSection;
			FlxG.sound.music.stop();
			vocals.stop();
			Main.switchState(new MainMenuState());
		}
		if (FlxG.keys.justPressed.E)
		{
			changeNoteSustain(Conductor.stepCrochet);
		}
		if (FlxG.keys.justPressed.Q)
		{
			changeNoteSustain(-Conductor.stepCrochet);
		}
		if (FlxG.keys.justPressed.TAB)
		{
			if (FlxG.keys.pressed.SHIFT)
			{
				UI_box.selected_tab -= 1;
				if (UI_box.selected_tab < 0)
					UI_box.selected_tab = 2;
			}
			else
			{
				UI_box.selected_tab += 1;
				if (UI_box.selected_tab >= 3)
					UI_box.selected_tab = 0;
			}
		}
		if (!typingShit.hasFocus)
		{
			if (FlxG.keys.pressed.CONTROL)
			{
				if (FlxG.keys.justPressed.Z && lastNote != null)
				{
					trace(curRenderedNotes.members.contains(lastNote) ? "delete note" : "add note");
					if (curRenderedNotes.members.contains(lastNote))
						deleteNote(lastNote);
					else
						addNote(lastNote);
				}
			}
			var shiftThing:Int = 1;

			if (FlxG.keys.pressed.SHIFT)
				shiftThing = 4;
			if (!FlxG.keys.pressed.CONTROL)
			{
				if (FlxG.keys.justPressed.RIGHT || FlxG.keys.justPressed.D)
					changeSection(curSection + shiftThing);
				if (FlxG.keys.justPressed.LEFT || FlxG.keys.justPressed.A)
					changeSection(curSection - shiftThing);
			}
			if (FlxG.keys.justPressed.SPACE && !noEscape)
			{
				if (FlxG.sound.music.playing)
				{
					FlxG.sound.music.pause();
					vocals.pause();
					claps.splice(0, claps.length);
				}
				else
				{
					vocals.play();
					FlxG.sound.music.play();
				}
			}
			if (FlxG.keys.justPressed.R)
			{
				if (FlxG.keys.pressed.SHIFT)
					resetSection(true);
				else
					resetSection();
			}
			/*if (FlxG.keys.justPressed.I)
					{
						sans.alpha = 0.9;
						sans.animation.play('play');
						sans.y -= 10;
						trace(sans);
					}

				if (FlxG.keys.justPressed.K)
					{
						sans.alpha = 0.9;
						sans.animation.play('play');
						sans.y += 10;
						trace(sans);
					}

				if (FlxG.keys.justPressed.J)
					{
						sans.alpha = 0.9;
						sans.animation.play('play');
						sans.x -= 10;
						trace(sans);
					}

				if (FlxG.keys.justPressed.L)
					{
						sans.alpha = 0.9;
						sans.animation.play('play');
						sans.x += 10;
						trace(sans);
					}
			 */

			if (FlxG.sound.music.time < 0 || curStep < 0)
				FlxG.sound.music.time = 0;
			if (FlxG.mouse.wheel != 0)
			{
				FlxG.sound.music.pause();
				vocals.pause();
				claps.splice(0, claps.length);
				var stepMs = curStep * Conductor.stepCrochet;

				trace(Conductor.stepCrochet / snap);
				if (doSnapShit)
					FlxG.sound.music.time = stepMs - (FlxG.mouse.wheel * Conductor.stepCrochet / snap);
				else
					FlxG.sound.music.time -= (FlxG.mouse.wheel * Conductor.stepCrochet * 0.4);
				trace(stepMs + " + " + Conductor.stepCrochet / snap + " -> " + FlxG.sound.music.time);
				vocals.time = FlxG.sound.music.time;
			}
			if (!FlxG.keys.pressed.SHIFT)
			{
				if (FlxG.keys.pressed.W || FlxG.keys.pressed.S)
				{
					FlxG.sound.music.pause();
					vocals.pause();
					claps.splice(0, claps.length);
					var daTime:Float = 700 * FlxG.elapsed;

					if (FlxG.keys.pressed.W)
					{
						FlxG.sound.music.time -= daTime;
					}
					else
						FlxG.sound.music.time += daTime;
					vocals.time = FlxG.sound.music.time;
				}
			}
			else
			{
				if (FlxG.keys.justPressed.W || FlxG.keys.justPressed.S)
				{
					FlxG.sound.music.pause();
					vocals.pause();
					var daTime:Float = Conductor.stepCrochet * 2;
					if (FlxG.keys.justPressed.W)
					{
						FlxG.sound.music.time -= daTime;
					}
					else
						FlxG.sound.music.time += daTime;
					vocals.time = FlxG.sound.music.time;
				}
			}
		}
		_song.bpm = tempBpm;
		/* if (FlxG.keys.justPressed.UP)
				Conductor.changeBPM(Conductor.bpm + 1);
			if (FlxG.keys.justPressed.DOWN)
				Conductor.changeBPM(Conductor.bpm - 1); */
		bpmTxt.text = bpmTxt.text = Std.string(FlxMath.roundDecimal(Conductor.songPosition / 1000, 2))
			+ " / "
			+ Std.string(FlxMath.roundDecimal(FlxG.sound.music.length / 1000, 2))
			+ "\nSection: "
			+ curSection
			+ "\nCurStep: "
			+ curStep
			+ "\nCurBeat: "
			+ curBeat;
		super.update(elapsed);
	}

	function changeNoteSustain(value:Float):Void
	{
		if (curSelectedNote != null)
		{
			if (curSelectedNote[2] != null)
			{
				curSelectedNote[2] += value;
				curSelectedNote[2] = Math.max(curSelectedNote[2], 0);
			}
		}

		updateNoteUI();
		updateGrid();
	}

	override function beatHit()
	{
		trace('beat');

		super.beatHit();
		if (!player2.animation.curAnim.name.startsWith("sing"))
		{
			player2.playAnim('idle');
		}
		player1.dance();
	}

	function recalculateSteps():Int
	{
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}
		for (i in 0...Conductor.bpmChangeMap.length)
		{
			if (FlxG.sound.music.time > Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];
		}

		curStep = lastChange.stepTime + Math.floor((FlxG.sound.music.time - lastChange.songTime) / Conductor.stepCrochet);
		updateBeat();

		return curStep;
	}

	function resetSection(songBeginning:Bool = false):Void
	{
		updateGrid();

		FlxG.sound.music.pause();
		vocals.pause();

		// Basically old shit from changeSection???
		FlxG.sound.music.time = sectionStartTime();

		if (songBeginning)
		{
			FlxG.sound.music.time = 0;
			curSection = 0;
		}

		vocals.time = FlxG.sound.music.time;
		updateCurStep();

		updateGrid();
		updateSectionUI();
	}

	function changeSection(sec:Int = 0, ?updateMusic:Bool = true):Void
	{
		trace('changing section' + sec);

		if (_song.notes[sec] != null)
		{
			trace('naw im not null');
			curSection = sec;

			updateGrid();

			if (updateMusic)
			{
				FlxG.sound.music.pause();
				vocals.pause();

				FlxG.sound.music.time = sectionStartTime();
				vocals.time = FlxG.sound.music.time;
				updateCurStep();
			}

			updateGrid();
			updateSectionUI();
		}
		else
			trace('bro wtf I AM NULL'); // imagine being null
	}

	function copySection(?sectionNum:Int = 1)
	{
		var daSec = FlxMath.maxInt(curSection, sectionNum);

		for (note in _song.notes[daSec - sectionNum].sectionNotes)
		{
			var strum = note[0] + Conductor.stepCrochet * (_song.notes[daSec].lengthInSteps * sectionNum);

			var copiedNote:Array<Dynamic> = [strum, note[1], note[2]];
			_song.notes[daSec].sectionNotes.push(copiedNote);
		}

		updateGrid();
	}

	function updateSectionUI():Void
	{
		var sec = _song.notes[curSection];

		stepperLength.value = sec.lengthInSteps;
		check_mustHitSection.checked = sec.mustHitSection;
		check_focusCamOnPlayer3.checked = sec.focusCamOnPlayer3;
		check_altAnim.checked = sec.altAnim;
		check_changeBPM.checked = sec.changeBPM;
		stepperSectionBPM.value = sec.bpm;
	}

	function updateHeads():Void
	{
		if (player3Icon != null)
		{
			if (player3Icon.special)
			{
				player3Icon.playAnim('normal', true);
			}
			else
			{
				player3Icon.playAnim(_song.player3, true);
			}
		}

		if (check_mustHitSection.checked)
		{
			leftIcon.playAnim("bf", true);
		}
		else
		{
			leftIcon.playAnim("dad", true);
		}

		if (check_mustHitSection.checked)
		{
			rightIcon.playAnim("dad", true);
		}
		else
		{
			rightIcon.playAnim("bf", true);
		}
	}

	function updateNoteUI():Void
	{
		if (curSelectedNote != null)
			stepperSusLength.value = curSelectedNote[2];
	}

	function updateGrid():Void
	{
		if (gridBG != null)
		{
			remove(gridBG);
		}

		switch (_song.song.toLowerCase())
		{
			case 'bonedoggle':
				gridBG = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, GRID_SIZE * 12, GRID_SIZE * _song.notes[curSection].lengthInSteps);
				add(gridBG);

				gridBlackLine = new FlxSprite(gridBG.x + gridBG.width / 3).makeGraphic(2, Std.int(gridBG.height), FlxColor.BLACK);
				add(gridBlackLine);

				gridBlackLine2 = new FlxSprite(gridBG.x + gridBG.width / 1.5).makeGraphic(2, Std.int(gridBG.height), FlxColor.BLACK);
				add(gridBlackLine2);
			default:
				gridBG = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, GRID_SIZE * 8, GRID_SIZE * _song.notes[curSection].lengthInSteps);
				add(gridBG);

				gridBlackLine = new FlxSprite(gridBG.x + gridBG.width / 2).makeGraphic(2, Std.int(gridBG.height), FlxColor.BLACK);
				add(gridBlackLine);
		}

		while (curRenderedNotes.members.length > 0)
		{
			curRenderedNotes.remove(curRenderedNotes.members[0], true);
		}

		while (curRenderedSustains.members.length > 0)
		{
			curRenderedSustains.remove(curRenderedSustains.members[0], true);
		}

		var sectionInfo:Array<Dynamic> = _song.notes[curSection].sectionNotes;

		if (_song.notes[curSection].changeBPM && _song.notes[curSection].bpm > 0)
		{
			Conductor.changeBPM(_song.notes[curSection].bpm);
			FlxG.log.add('CHANGED BPM!');
		}
		else
		{
			// get last bpm
			var daBPM:Float = _song.bpm;
			for (i in 0...curSection)
				if (_song.notes[i].changeBPM)
					daBPM = _song.notes[i].bpm;
			Conductor.changeBPM(daBPM);
		}

		/* // PORT BULLSHIT, INCASE THERE'S NO SUSTAIN DATA FOR A NOTE
			for (sec in 0..._song.notes.length)
			{
				for (notesse in 0..._song.notes[sec].sectionNotes.length)
				{
					if (_song.notes[sec].sectionNotes[notesse][2] == null)
					{
						trace('SUS NULL');
						_song.notes[sec].sectionNotes[notesse][2] = 0;
					}
				}
			}
		 */

		for (i in sectionInfo)
		{
			var daNoteInfo = i[1];
			var daStrumTime = i[0];
			var daSus = i[2];

			var note:Note = new Note(daStrumTime, daNoteInfo, null, false, true);
			note.sustainLength = daSus;
			note.setGraphicSize(GRID_SIZE);
			note.updateHitbox();

			note.x = Math.floor((daNoteInfo % Main.dataJump) * GRID_SIZE);
			note.y = Math.floor(getYfromStrum((daStrumTime - sectionStartTime()) % (Conductor.stepCrochet * _song.notes[curSection].lengthInSteps)));

			if (curSelectedNote != null)
				if (curSelectedNote[0] == note.strumTime)
					lastNote = note;

			curRenderedNotes.add(note);

			if (daSus > 0)
			{
				var sustainVis:FlxSprite = new FlxSprite(note.x + (GRID_SIZE / 2),
					note.y + GRID_SIZE).makeGraphic(8,
					Math.floor(FlxMath.remapToRange(daSus, 0, Conductor.stepCrochet * _song.notes[curSection].lengthInSteps, 0, gridBG.height)));
				curRenderedSustains.add(sustainVis);
			}
		}
	}

	private function addSection(lengthInSteps:Int = 16):Void
	{
		var sec:SwagSection = {
			lengthInSteps: lengthInSteps,
			bpm: _song.bpm,
			changeBPM: false,
			mustHitSection: true,
			focusCamOnPlayer3: false,
			sectionNotes: [],
			typeOfSection: 0,
			altAnim: false
		};

		_song.notes.push(sec);
	}

	function selectNote(note:Note):Void
	{
		var swagNum:Int = 0;

		for (i in _song.notes[curSection].sectionNotes)
		{
			if (i.strumTime == note.strumTime && i.noteData % 4 == note.noteData)
			{
				curSelectedNote = _song.notes[curSection].sectionNotes[swagNum];
			}

			swagNum += 1;
		}

		updateGrid();
		updateNoteUI();
	}

	function deleteNote(note:Note):Void
	{
		lastNote = note;
		for (i in _song.notes[curSection].sectionNotes)
		{
			if (i[0] == note.strumTime && i[1] % 4 == note.noteData)
			{
				if (i == curSelectedNote) curSelectedNote = null;

				_song.notes[curSection].sectionNotes.remove(i);
				break;
			}
		}

		updateGrid();
	}

	function clearSection():Void
	{
		_song.notes[curSection].sectionNotes = [];

		updateGrid();
	}

	function clearSong():Void
	{
		for (daSection in 0..._song.notes.length)
		{
			_song.notes[daSection].sectionNotes = [];
		}

		updateGrid();
	}

	private function newSection(lengthInSteps:Int = 16, mustHitSection:Bool = false, altAnim:Bool = true, focusCamOnPlayer3:Bool = false):SwagSection
	{
		var sec:SwagSection = {
			lengthInSteps: lengthInSteps,
			bpm: _song.bpm,
			changeBPM: false,
			mustHitSection: mustHitSection,
			focusCamOnPlayer3: focusCamOnPlayer3,
			sectionNotes: [],
			typeOfSection: 0,
			altAnim: altAnim
		};

		return sec;
	}

	function shiftNotes(measure:Int = 0, step:Int = 0, ms:Int = 0):Void
	{
		var newSong = [];

		var millisecadd = (((measure * 4) + step / 4) * (60000 / _song.bpm)) + ms;
		var totaladdsection = Std.int((millisecadd / (60000 / _song.bpm) / 4));
		trace(millisecadd, totaladdsection);
		if (millisecadd > 0)
		{
			for (i in 0...totaladdsection)
			{
				newSong.unshift(newSection());
			}
		}
		for (daSection1 in 0..._song.notes.length)
		{
			newSong.push(newSection(16, _song.notes[daSection1].mustHitSection, _song.notes[daSection1].altAnim, _song.notes[daSection1].focusCamOnPlayer3));
		}

		for (daSection in 0...(_song.notes.length))
		{
			var aimtosetsection = daSection + Std.int((totaladdsection));
			if (aimtosetsection < 0)
				aimtosetsection = 0;
			newSong[aimtosetsection].mustHitSection = _song.notes[daSection].mustHitSection;
			newSong[aimtosetsection].focusCamOnPlayer3 = _song.notes[daSection].focusCamOnPlayer3;
			newSong[aimtosetsection].altAnim = _song.notes[daSection].altAnim;
			// trace("section "+daSection);
			for (daNote in 0...(_song.notes[daSection].sectionNotes.length))
			{
				var newtiming = _song.notes[daSection].sectionNotes[daNote][0] + millisecadd;
				if (newtiming < 0)
				{
					newtiming = 0;
				}
				var futureSection = Math.floor(newtiming / 4 / (60000 / _song.bpm));
				_song.notes[daSection].sectionNotes[daNote][0] = newtiming;
				newSong[futureSection].sectionNotes.push(_song.notes[daSection].sectionNotes[daNote]);

				// newSong.notes[daSection].sectionNotes.remove(_song.notes[daSection].sectionNotes[daNote]);
			}
		}
		// trace("DONE BITCH");
		_song.notes = newSong;
		updateGrid();
		updateSectionUI();
		updateNoteUI();
	}

	private function addNote(?n:Note):Void
	{
		var noteStrum = getStrumTime(dummyArrow.y) + sectionStartTime();
		var noteData = Math.floor(FlxG.mouse.x / GRID_SIZE);
		var noteSus = 0;

		if (n != null)
			_song.notes[curSection].sectionNotes.push([n.strumTime, n.noteData, n.sustainLength]);
		else
		{
			_song.notes[curSection].sectionNotes.push([noteStrum, noteData + Main.dataJump * currType, noteSus]);
		}

		var thingy = _song.notes[curSection].sectionNotes[_song.notes[curSection].sectionNotes.length - 1];

		curSelectedNote = thingy;
		updateGrid();
		updateNoteUI();

		autosaveSong();
	}

	function getStrumTime(yPos:Float):Float
	{
		return FlxMath.remapToRange(yPos, gridBG.y, gridBG.y + gridBG.height, 0, 16 * Conductor.stepCrochet);
	}

	function getYfromStrum(strumTime:Float):Float
	{
		return FlxMath.remapToRange(strumTime, 0, 16 * Conductor.stepCrochet, gridBG.y, gridBG.y + gridBG.height);
	}

	/*
		function calculateSectionLengths(?sec:SwagSection):Int
		{
			var daLength:Int = 0;

			for (i in _song.notes)
			{
				var swagLength = i.lengthInSteps;

				if (i.typeOfSection == Section.COPYCAT)
					swagLength * 2;

				daLength += swagLength;

				if (sec != null && sec == i)
				{
					trace('swag loop??');
					break;
				}
			}

			return daLength;
	}*/
	private var daSpacing:Float = 0.3;

	function loadLevel():Void
	{
		trace(_song.notes);
	}

	function getNotes():Array<Dynamic>
	{
		var noteData:Array<Dynamic> = [];

		for (i in _song.notes)
		{
			noteData.push(i.sectionNotes);
		}

		return noteData;
	}

	function loadJson(song:String):Void
	{
		PlayState.SONG = Song.loadFromJson(song.toLowerCase(), song.toLowerCase());
		LoadingState.target = new ChartingState();
		LoadingState.stopMusic = true;
		Main.switchState(new LoadingState());
	}

	function loadAutosave():Void
	{
		PlayState.SONG = Song.parseJSONshit(FlxG.save.data.autosave);
		LoadingState.target = new ChartingState();
		LoadingState.stopMusic = true;
		Main.switchState(new LoadingState());
	}

	function autosaveSong():Void
	{
		FlxG.save.data.autosave = Json.stringify({
			"song": _song
		});
		FlxG.save.flush();
	}

	private function saveLevel()
	{
		var json = {
			"song": _song
		};

		var data:String = Json.stringify(json);

		if ((data != null) && (data.length > 0))
		{
			_file = new FileReference();
			_file.addEventListener(Event.COMPLETE, onSaveComplete);
			_file.addEventListener(Event.CANCEL, onSaveCancel);
			_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			_file.save(data.trim(), _song.song.toLowerCase() + ".json");
		}
	}

	function onSaveComplete(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.notice("Successfully saved LEVEL DATA.");
	}

	/**
	 * Called when the save file dialog is cancelled.
	 */
	function onSaveCancel(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
	}

	/**
	 * Called if there is an error while saving the gameplay recording.
	 */
	function onSaveError(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.error("Problem saving Level data");
	}
}
