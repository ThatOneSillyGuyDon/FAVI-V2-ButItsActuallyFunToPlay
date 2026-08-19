package backend.song;

import haxe.Json;
import lime.utils.Assets;
import backend.song.Section;

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

	var gameOverStyle:String;

	var player1:String;
	var player2:String;
	var gfVersion:String;
	var stage:String;

	@:optional var disableNoteRGB:Bool;

	@:optional var arrowSkin:String;
	@:optional var splashSkin:String;
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
	public var gameOverStyle:String = "Base Game";
	public var disableNoteRGB:Bool = false;
	public var speed:Float = 1;
	public static var charter:String = "Unknown";
	public var stage:String;
	public var player1:String = 'bf';
	public var player2:String = 'dad';
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
		switch(folder)
		{
			case "malfunction": 
				if(ClientPrefs.data.gameplaySettings["botplay"] == true)
					chartFile = Chart.malfunctionBOT;
				else
					chartFile = Chart.malfunction;
			case "scrapped": chartFile = Chart.scrapped;
			case "whimsical-bar-blues": chartFile = Chart.wbb;

			case "dont-cross":
				var eventRandom = FlxG.random.int(1,4);
				if (!ClientPrefs.data.mechanics)
				{
					trace('lmao no, get fucked');
					if (ClientPrefs.data.gameplaySettings["botplay"])
						ClientPrefs.data.gameplaySettings["botplay"] = false;
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
						case 4: chartFile = ClientPrefs.data.gameplaySettings["botplay"] ? Chart.dontCross1 : Chart.dontCross4;
						case 5: chartFile = ClientPrefs.data.gameplaySettings["botplay"] ? Chart.dontCross3 : Chart.dontCross5;
						case 6: chartFile = ClientPrefs.data.gameplaySettings["botplay"] ? Chart.dontCross2 : Chart.dontCross6;
						case 7: chartFile = Chart.dontCross7;
						case 8: chartFile = ClientPrefs.data.gameplaySettings["botplay"] ? Chart.dontCross1 : Chart.dontCross8;
						case 9: chartFile = ClientPrefs.data.gameplaySettings["botplay"] ? Chart.dontCross1 : Chart.dontCross9;
						case 10: chartFile = ClientPrefs.data.gameplaySettings["botplay"] ? Chart.dontCross1 : Chart.dontCross10;
						case 11: chartFile = ClientPrefs.data.gameplaySettings["botplay"] ? Chart.dontCross1 : Chart.dontCross11;
					}
					if (jsonInput == 'events' && FlxG.random.bool(10) && !ClientPrefs.data.gameplaySettings["botplay"])
					{
						switch (eventRandom)
						{
							case 1: chartFile = Event.bullshitEvent1;
							case 2: chartFile = Event.bullshitEvent2;
							case 3: chartFile = Event.bullshitEvent3;
							case 4: chartFile = Event.bullshitEvent4;
						}
					}
				}
			case "rotten-petals": chartFile = Chart.rottenPetals;
			case "somber-night": chartFile = Chart.somberNight;
			case "simple-life": chartFile = Chart.simpleLife;
			case "seeking-freedom": chartFile = Chart.seekingFreedom;
			case "am-i-real": chartFile = Chart.amIReal;
			case "alone": chartFile = Chart.alone;
			case "curtain-call": chartFile = Chart.curtainCall;
			case "distant-stars": chartFile = Chart.distantStars;
			case "mistful-wind": chartFile = Chart.mistfulWind;
			default:
				chartFile = null;
		}
		var rawJson = null;
		
		var formattedFolder:String = Paths.formatToSongPath(folder);
		var formattedSong:String = Paths.formatToSongPath(jsonInput);
		
		if(rawJson == null) {
			if (chartFile == null) {
				var jsonPath = Paths.json(formattedFolder + '/' + formattedSong);
				
				#if sys
				if (FileSystem.exists(jsonPath)) {
					rawJson = File.getContent(jsonPath).trim();
				} else {
					trace('JSON file not found: ${jsonPath}');
					// Return a default/empty song structure instead of crashing
					return createDefaultSong(jsonInput, folder);
				}
				#else
				if (Assets.exists(jsonPath, TEXT)) {
					rawJson = Assets.getText(jsonPath).trim();
				} else {
					trace('JSON file not found: ${jsonPath}');
					// Return a default/empty song structure instead of crashing
					return createDefaultSong(jsonInput, folder);
				}
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

	// MY SAFE HEAVEN💙💙 -- mr_chaoss
	private static function createDefaultSong(songName:String, folder:String):SwagSong
	{
		trace('Creating default song structure for: ${songName}');
		
		return {
			song: songName != null ? songName : "test",
			notes: [],
			events: [],
			bpm: 150,
			needsVoices: false,
			speed: 1,
			gameOverStyle: "Base Game",
			player1: "bf",
			player2: "bf-pixel-opponent",
			gfVersion: "gf",
			stage: "stage",
			composer: "Unknown"
		};
	}

	public static function getCharterCredits():String
	{
		switch (PlayState.SONG.song)
		{
			case "Devilish Deal" | "Lunacy" | "Hunted" | "War Dilemma" | "Twisted Grins" | "Isolated" | "The Wretched Tilezones (Simple Life)": charter = "Purg";
			case "Delusional", "delusional-anniversary" | "Cycled Sins" | "Birthday" | "Cycled Sins Legacy" | "Twisted Grins Legacy" | "Scrapped" | "Ship the Fart Yay Hooray <3 (Distant Stars)" | "Mistful Wind": charter = "Dreupy";
			case "Curtain Call": charter = "Dreupy [Ft. ThatOneSillyGuy]";
			case "Lunacy Legacy": charter = "obscurity.";
			case "Malfunction" | "Mercy" | "Mercy Legacy" | "Isolated Old" | "Isolated Legacy" | "Isolated Beta" | "Malfunction Legacy" | "Laugh Track" | "Rotten Petals" | "Ahh the Scary (Somber Night)" | "Whimsical Bar Blues" | "Am I Real?" | "Seeking Freedom" | "Alone": charter = "ThatOneSillyGuy";
			case "Delusional Legacy": charter = "Noppz";
			case "Bless": charter = "ThatOneSillyGuy [Ft. Goober Man]";
			case "Dont Cross":
				switch (randomizer)
				{
					case 1 | 4 | 8 | 9 | 10 | 11: charter = "ThatOneSillyGuy";
					case 2 | 7: charter = "Dreupy";
					case 5: charter = ClientPrefs.data.gameplaySettings["botplay"] ? "Purg" : "MalyPlus";
					case 3: charter = "Purg";
					case 6: charter = ClientPrefs.data.gameplaySettings["botplay"] ? "Dreupy" : "rezeo285";
				}
			default: charter = "Unknown";
		}
		return charter;
	}

	public static function parseJSONshit(rawJson:String):SwagSong
	{
		var swagShit:SwagSong = cast Json.parse(rawJson).song;
		return swagShit;
	}
}
