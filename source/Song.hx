package;

import Section.SwagSection;
import haxe.Json;
import lime.utils.Assets;

using StringTools;

typedef SwagSong =
{
	var song:String;
	var notes:Array<SwagSection>;
	var bpm:Float;
	var needsVoices:Bool;
	var speed:Float;

	var player1:String;
	var player2:String;
	var player3:String;
	var gfVersion:String;
	var noteStyle:String;
	var stage:String;
	var validScore:Bool;
}

class Song
{
	public var song:String;
	public var notes:Array<SwagSection>;
	public var bpm:Float;
	public var needsVoices:Bool = true;
	public var speed:Float = 1;

	public var player1:String = 'bf';
	public var player2:String = 'dad';
	public var player3:String = 'dad';
	public var gfVersion:String = 'gf';
	public var noteStyle:String = 'normal';
	public var stage:String = 'stage';

	public function new(song, notes, bpm)
	{
		this.song = song;
		this.notes = notes;
		this.bpm = bpm;
	}

	public static function loadFromJson(jsonInput:String, ?folder:String):SwagSong
	{
		// pre lowercasing the folder name
		var folderLowercase = StringTools.replace(folder, " ", "-").toLowerCase();

		var rawJson;

		if (Main.hiddenSongs.contains(folder.toLowerCase()))
		{
			rawJson = Assets.getText(Paths.jsonHidden(folderLowercase + '/' + jsonInput.toLowerCase())).trim();
		}
		else
		{
			rawJson = Assets.getText(Paths.json(folderLowercase + '/' + jsonInput.toLowerCase())).trim();
		}

		while (!rawJson.endsWith("}"))
		{
			rawJson = rawJson.substr(0, rawJson.length - 1);
		}


		return parseJSONshit(rawJson);
	}

	public static function parseJSONshit(rawJson:String):SwagSong
	{
		var swagShit:SwagSong = cast Json.parse(rawJson).song;
		swagShit.validScore = true;
		return swagShit;
	}
}
