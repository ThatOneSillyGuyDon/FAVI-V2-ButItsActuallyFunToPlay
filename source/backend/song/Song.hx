package backend.song;

import haxe.Json;
import haxe.format.JsonParser;
import lime.utils.Assets;

#if sys
import sys.io.File;
import sys.FileSystem;
#end

typedef SwagSong =
{
	var song:String;
	var notes:Array<SwagSection>;
	var events:Array<Dynamic>;
	var bpm:Float;
	var needsVoices:Bool;
	var speed:Float;

	var composer:String;

	var player1:String;
	var player2:String;
	var voiceSfx1:String;
	var voiceSfx2:String;
	var gfVersion:String;
	var stage:String;

	var arrowSkin:String;
	var splashSkin:String;
	var validScore:Bool;
}

class Song
{
	public static var chartFile:String;
	public static var randomizer:Int;

	public var song:String;
	public var notes:Array<SwagSection>;
	public var events:Array<Dynamic>;
	public var bpm:Float;
	public var needsVoices:Bool = true;
	public var arrowSkin:String;
	public var splashSkin:String;
	public var speed:Float = 1;
	public static var charter:String = "Unknown";
	public var stage:String;
	public var player1:String = 'bf';
	public var player2:String = 'dad';
	public var voiceSfx1:String = "Player";
	public var voiceSfx2:String = "Opponent";
	public var gfVersion:String = 'gf';

	private static function onLoadJson(songJson:Dynamic) // Convert old charts to newest format
	{
		if(songJson.gfVersion == null)
		{
			songJson.gfVersion = songJson.player3;
			songJson.player3 = null;
		}

		if(songJson.events == null)
		{
			songJson.events = [];
			for (secNum in 0...songJson.notes.length)
			{
				var sec:SwagSection = songJson.notes[secNum];

				var i:Int = 0;
				var notes:Array<Dynamic> = sec.sectionNotes;
				var len:Int = notes.length;
				while(i < len)
				{
					var note:Array<Dynamic> = notes[i];
					if(note[1] < 0)
					{
						songJson.events.push([note[0], [[note[2], note[3], note[4]]]]);
						notes.remove(note);
						len = notes.length;
					}
					else i++;
				}
			}
		}
	}

	public function new(song, notes, bpm)
	{
		this.song = song;
		this.notes = notes;
		this.bpm = bpm;
	}

	public static function loadFromJson(jsonInput:String, ?folder:String, ?crossRandomizer:Int):SwagSong
	{
		/*chartFile = (jsonInput == "events" ? ChartMap.events : ChartMap.charts).get(folder);
		
		if (folder == "dont-cross" && !ClientPrefs.mechanics && jsonInput != "events")
			chartFile = ChartMap.charts.get("don't cross 4");*/
		
		switch(folder)
		{
			case "isolated": chartFile = Chart.isolated;
			case "isolated-beta": chartFile = Chart.isolatedBeta;
			case "isolated-old": chartFile = Chart.isolatedOld;
			case "isolated-legacy": chartFile = Chart.isolatedLegacy;
			case "lunacy": chartFile = Chart.lunacy;
			case "lunacy-legacy": chartFile = Chart.lunacyLegacy;
			case "delusional": chartFile = Chart.delusional;
			case "delusional-legacy": chartFile = Chart.delusionalLegacy;
			case "malfunction": chartFile = Chart.malfunction;
			case "malfunction-legacy": chartFile = Chart.malfunctionLegacy;
			case "bless": chartFile = Chart.bless;
			case "devilish-deal": chartFile = Chart.devilishDeal;
			case "hunted": chartFile = Chart.hunted;
			case "hunted-legacy": chartFile = Chart.huntedLegacy;
			case "war-dilemma": chartFile = Chart.warDilemma;
			case "birthday": chartFile = Chart.birthday;
			case "mercy": chartFile = Chart.mercy;
			case "mercy-legacy": chartFile = Chart.mercyLegacy;
			case "laugh-track": chartFile = Chart.laughTrack;
			case "delutrance": chartFile = Chart.delutrance;
			case "cycled-sins": chartFile = Chart.cycledSins;
			case "twisted-grins": 
				chartFile = Chart.twistedGrins;

				if (jsonInput == 'events')
					chartFile = Event.twistedGrinsNoteSpeed;
			case "dont-cross":
				if (!ClientPrefs.mechanics)
				{
					trace('lmao no, get fucked');
					chartFile = Chart.dontCross4; // because no lmao
				}
				else
				{
					randomizer = crossRandomizer;
					trace('random chart loaded!');
					switch (randomizer)
					{
						case 1: chartFile = Chart.dontCross1;
						case 2: chartFile = Chart.dontCross2;
						case 3: chartFile = Chart.dontCross3;
						case 4: chartFile = Chart.dontCross4;
						case 5: chartFile = Chart.dontCross1;
					}
				}

				if (jsonInput == 'events')
				{
					trace('got event!');
					chartFile = Event.dontCrossAnimatedShit;
				}
			default:
				chartFile = null;
		}
		var rawJson = null;
		
		var formattedFolder:String = Paths.formatToSongPath(folder);
		var formattedSong:String = Paths.formatToSongPath(jsonInput);
		#if MODS_ALLOWED
		var moddyFile:String = Paths.modsJson(formattedFolder + '/' + formattedSong);
		if(FileSystem.exists(moddyFile)) {
			rawJson = File.getContent(moddyFile).trim();
		}
		#end

		if(rawJson == null) {
			if (chartFile == null)
			{
				#if sys
				rawJson = File.getContent(Paths.json(formattedFolder + '/' + formattedSong)).trim();
				#else
				rawJson = Assets.getText(Paths.json(formattedFolder + '/' + formattedSong)).trim();
				#end
			}
			else
			{
				rawJson = chartFile;
			}
		}

		while (!rawJson.endsWith("}"))
		{
			rawJson = rawJson.substr(0, rawJson.length - 1);
			// LOL GOING THROUGH THE BULLSHIT TO CLEAN IDK WHATS STRANGE
		}

		// FIX THE CASTING ON WINDOWS/NATIVE
		// Windows???
		// trace(songData);

		// trace('LOADED FROM JSON: ' + songData.notes);
		/* 
			for (i in 0...songData.notes.length)
			{
				trace('LOADED FROM JSON: ' + songData.notes[i].sectionNotes);
				// songData.notes[i].sectionNotes = songData.notes[i].sectionNotes
			}

				daNotes = songData.notes;
				daSong = songData.song;
				daBpm = songData.bpm; */

		var songJson:Dynamic = parseJSONshit(rawJson);
		if(jsonInput != 'events') StageData.loadDirectory(songJson);
		onLoadJson(songJson);
		return songJson;
	}

	public static function getCharterCredits():String
	{
		switch (PlayState.SONG.song)
		{
			case "Devilish Deal" | "Lunacy" | "Hunted" | "War Dilemma" | "Twisted Grins" | "Isolated": charter = "Purg";
			case "Delusional" | "Cycled Sins" | "Birthday" | "Cycled Sins Legacy": charter = "Dreupy";
			case "Lunacy Legacy": charter = "obscurity.";
			case "Bless" | "Malfunction" | "Delutrance" | "Mercy" | "Mercy Legacy" | "Isolated Old" | "Isolated Legacy" | "Isolated Beta" | "Malfunction Legacy" | "Laugh Track": charter = "DEMOLITIONDON96";
			case "Delusional Legacy": charter = "Noppz";
			case "Dont Cross":
				switch (randomizer)
				{
					case 1 | 4: charter = "DEMOLITIONDON96";
					case 2 | 5: charter = "Dreupy";
					case 3: charter = "Purg";
				}
			default: charter = "Unknown";
		}
		return charter;
	}

	public static function parseJSONshit(rawJson:String):SwagSong
	{
		var swagShit:SwagSong = cast Json.parse(rawJson).song;
		swagShit.validScore = true;
		return swagShit;
	}
}
