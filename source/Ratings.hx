import flixel.FlxG;

class Ratings
{
	public static function GenerateLetterRank(accuracy:Float) // generate a letter ranking
	{
		var ranking:String = "N/A";

		if (PlayState.instance.misses == 0 && PlayState.instance.bads == 0 && PlayState.instance.shits == 0 && PlayState.instance.goods == 0) // Marvelous (SICK) Full Combo
			ranking = "(MFC)";
		else if (PlayState.instance.misses == 0 && PlayState.instance.bads == 0 && PlayState.instance.shits == 0 && PlayState.instance.goods >= 1) // Good Full Combo (Nothing but Goods & Sicks)
			ranking = "(GFC)";
		else if (PlayState.instance.misses == 0) // Regular FC
			ranking = "(FC)";
		else if (PlayState.instance.misses < 10) // Single Digit Combo Breaks
			ranking = "(SDCB)";
		else
			ranking = "(Clear)";

		// WIFE TIME :)))) (based on Wife3)

		var wifeConditions:Array<Bool> = [
			accuracy >= 99.9935, // AAAAA
			accuracy >= 99.980, // AAAA:
			accuracy >= 99.970, // AAAA.
			accuracy >= 99.955, // AAAA
			accuracy >= 99.90, // AAA:
			accuracy >= 99.80, // AAA.
			accuracy >= 99.70, // AAA
			accuracy >= 99, // AA:
			accuracy >= 96.50, // AA.
			accuracy >= 93, // AA
			accuracy >= 90, // A:
			accuracy >= 85, // A.
			accuracy >= 80, // A
			accuracy >= 70, // B
			accuracy >= 60, // C
			accuracy < 60 // D
		];

		for (i in 0...wifeConditions.length)
		{
			var b = wifeConditions[i];
			if (b)
			{
				switch (i)
				{
					case 0:
						ranking += " AAAAA";
					case 1:
						ranking += " AAAA:";
					case 2:
						ranking += " AAAA.";
					case 3:
						ranking += " AAAA";
					case 4:
						ranking += " AAA:";
					case 5:
						ranking += " AAA.";
					case 6:
						ranking += " AAA";
					case 7:
						ranking += " AA:";
					case 8:
						ranking += " AA.";
					case 9:
						ranking += " AA";
					case 10:
						ranking += " A:";
					case 11:
						ranking += " A.";
					case 12:
						ranking += " A";
					case 13:
						ranking += " B";
					case 14:
						ranking += " C";
					case 15:
						ranking += " D";
				}
				break;
			}
		}

		if (accuracy == 0)
			ranking = "N/A";
		else if (PlayStateChangeables.botPlay && !MainMenuState.showcase)
			ranking = "BotPlay";

		return ranking;
	}

	public static var timingWindows = [166.0, 135.0, 90.0, 45.0];

	public static function judgeNote(noteDiff:Float)
	{
		var diff = Math.abs(noteDiff); /*/ (PlayState.songMultiplier >= 1 ? PlayState.songMultiplier : 1); */ // 1.7 thing
		for (index in 0...timingWindows.length) // based on 4 timing windows, will break with anything else
		{
			var time = timingWindows[index] * Conductor.timeScale;
			var nextTime = index + 1 > timingWindows.length - 1 ? 0 : timingWindows[index + 1];
			if (diff < time && diff >= nextTime * Conductor.timeScale)
			{
				switch (index)
				{
					case 0: // shit
						return "shit";
					case 1: // bad
						return "bad";
					case 2: // good
						return "good";
					case 3: // sick
						return "sick";
				}
			}
		}
		return "good";
	}

	public static function CalculateRanking(score:Int, scoreDef:Int, nps:Int, maxNPS:Int, accuracy:Float):String
	{
		if (PlayState.dad.curCharacter == 'saness')
		{
			return (FlxG.save.data.npsDisplay ? // NPS Toggle
				"NPS: "
				+ nps
				+ " (Max "
				+ maxNPS
				+ ")"
				+ ((!PlayStateChangeables.botPlay || (PlayStateChangeables.botPlay && MainMenuState.showcase)) ? " | " : "") : "") 
							+ // 	NPS
							((!PlayStateChangeables.botPlay || (PlayStateChangeables.botPlay && MainMenuState.showcase)) ? "social credit points: " + (Conductor.safeFrames != 10 ? score + " (" + scoreDef + ")" : "" + score) 
							+ // Score
							(FlxG.save.data.accuracyDisplay ? // Accuracy Toggle
							" | skill issues: "
							+ PlayState.instance.misses
							+ // 	Misses/Combo Breaks
							" | wackyness: "
							+ ((PlayStateChangeables.botPlay && !MainMenuState.showcase) ? "N/A" : HelperFunctions.truncateFloat(accuracy, 2) + " %")
							+ // 	Accuracy
							" | "
							+ GenerateLetterRank(accuracy) : "") : ""); // 	Letter Rank
		}
		else
		{
			return (FlxG.save.data.npsDisplay ? // NPS Toggle
				"NPS: "
				+ nps
				+ " (Max "
				+ maxNPS
				+ ")"
				+ ((!PlayStateChangeables.botPlay || (PlayStateChangeables.botPlay && MainMenuState.showcase)) ? " | " : "") : "") 
							+ // 	NPS
							(!PlayStateChangeables.botPlay || (PlayStateChangeables.botPlay && MainMenuState.showcase) ? "Score: " + (Conductor.safeFrames != 10 ? score + " (" + scoreDef + ")" : "" + score)
							 + // Score
							(FlxG.save.data.accuracyDisplay ? // Accuracy Toggle
							" | Misses: "
							+ PlayState.instance.misses
							+ // 	Misses/Combo Breaks
							" | Accuracy: "
							+ ((PlayStateChangeables.botPlay && !MainMenuState.showcase) ? "N/A" : HelperFunctions.truncateFloat(accuracy, 2) + " %")
							+ // 	Accuracy
							" | "
							+ GenerateLetterRank(accuracy) : "") : "");
		}
	}
}
