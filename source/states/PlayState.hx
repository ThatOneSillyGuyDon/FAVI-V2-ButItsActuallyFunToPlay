package states;

import backend.data.Highscore;
import backend.data.StageData;
import backend.data.WeekData;
import backend.song.Song;
import backend.song.Section;
import backend.Rating;

import modcharting.ModchartFuncs;
import modcharting.NoteMovement;
import modcharting.PlayfieldRenderer;
import lime.app.Application;
import openfl.Lib;
import flash.system.System;

import flixel.FlxBasic;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxSave;
import flixel.input.keyboard.FlxKey;
import flixel.animation.FlxAnimationController;
import lime.utils.Assets;
import openfl.utils.Assets as OpenFlAssets;
import openfl.events.KeyboardEvent;
import haxe.Json;

import gameObjects.Character.Shadow;
import gameObjects.ui.SubtitlesBox.EventType;
import gameObjects.ui.SubtitlesBox.SubtitlesUtil;

import states.editors.ChartingState;
import states.editors.CharacterEditorState;

#if !flash
import flixel.addons.display.FlxRuntimeShader;
import openfl.filters.ShaderFilter;
#end

#if VIDEOS_ALLOWED
#if (hxCodec >= "3.0.0") import hxcodec.flixel.FlxVideo as VideoHandler;
#elseif (hxCodec >= "2.6.1") import hxcodec.VideoHandler as VideoHandler;
#elseif (hxCodec == "2.6.0") import VideoHandler;
#else import vlc.MP4Handler as VideoHandler; #end
#end

import gameObjects.ui.notes.Note.EventNote;
import gameObjects.*;

import psychlua.LuaUtils;
import psychlua.HScript;

#if HSCRIPT_ALLOWED
import psychlua.HScript.HScriptInfos;
import crowplexus.iris.Iris;
import crowplexus.hscript.Expr.Error as IrisError;
import crowplexus.hscript.Printer;
#end

enum CinematicControls
{
	MOVE;
	FLASH;
	ANGLE;
	ALPHA;
	COLOR;
	BOP;
}

enum FlashType
{
	BG_FLASH;
	BG_DARK;
	SET_COLOR;
	TWEEN_COLOR;
	CAM_FLASH_FANCY;
}

typedef CinematicSettings =
{
	@:optional var valueInput:Float;

	@:optional var timer:Float;

	@:optional var ease:String;

	@:optional var colors:Array<Int>;
}

typedef FlashingSettings = 
{
	/**
	* The visiblity of your background you want it to flash at
	*/
	@:optional var alpha:Float;

	/**
	* How long you want the fade out transition to take
	*/
	@:optional var timer:Float;

	/**
	* Fade out transition easing
	*/
	@:optional var ease:(t:Float)->Float;

	/**
	 * The array of the color values (RGB)
	 */
	@:optional var colors:Array<Int>;

	/**
	* The bool that checks for if it should enable the badapple style events (only used in BADAPPLE_A and BADAPPLE_B)
	*/
	@:optional var enableBadapple:Bool;
}

//God recreating these events are going to be a pain in the ASS

/**
 * This is where all the Gameplay stuff happens and is managed
 *
 * here's some useful tips if you are making a mod in source:
 *
 * If you want to add your stage to the game, copy states/stages/Template.hx,
 * and put your stage code there, then, on PlayState, search for
 * "switch (curStage)", and add your stage to that list.
 *
 * If you want to code Events, you can either code it on a Stage file or on PlayState, if you're doing the latter, search for:
 *
 * "function eventPushed" - Only called *one time* when the game loads, use it for precaching events that use the same assets, no matter the values
 * "function eventPushedUnique" - Called one time per event, use it for precaching events that uses different assets based on its values
 * "function eventEarlyTrigger" - Used for making your event start a few MILLISECONDS earlier
 * "function triggerEvent" - Called when the song hits your event's timestamp, this is probably what you were looking for
**/
class PlayState extends MusicBeatState
{
	public static var STRUM_X = 42;
	public static var STRUM_X_MIDDLESCROLL = -278;
	var middlescroll:Bool = false;

	public static var ratingStuff:Array<Dynamic> = [
		['You Suck!', 0.2], //From 0% to 19%
		['Shit', 0.4], //From 20% to 39%
		['Bad', 0.5], //From 40% to 49%
		['Bruh', 0.6], //From 50% to 59%
		['Meh', 0.69], //From 60% to 68%
		['Nice', 0.7], //69%
		['Good', 0.8], //From 70% to 79%
		['Great', 0.9], //From 80% to 89%
		['Sick!', 1], //From 90% to 99%
		['Perfect!!', 1] //The value on this one isn't used actually, since Perfect is always "1"
	];

	//event variables
	private var isCameraOnForcedPos:Bool = false;

	public var boyfriendMap:Map<String, Character> = new Map<String, Character>();
	public var dadMap:Map<String, Character> = new Map<String, Character>();
	public var gfMap:Map<String, Character> = new Map<String, Character>();

	#if HSCRIPT_ALLOWED
	public var hscriptArray:Array<HScript> = [];
	#end

	public var modchartTweens:Map<String, FlxTween> = new Map<String, FlxTween>();
	//public var modchartSprites:Map<String, ModchartSprite> = new Map<String, ModchartSprite>();
	public var modchartTimers:Map<String, FlxTimer> = new Map<String, FlxTimer>();
	public var modchartSounds:Map<String, FlxSound> = new Map<String, FlxSound>();
	public var modchartTexts:Map<String, FlxText> = new Map<String, FlxText>();
	public var modchartSaves:Map<String, FlxSave> = new Map<String, FlxSave>();

	public var BF_X:Float = 770;
	public var BF_Y:Float = 100;
	public var DAD_X:Float = 100;
	public var DAD_Y:Float = 100;
	public var GF_X:Float = 400;
	public var GF_Y:Float = 130;

	public var songSpeedTween:FlxTween;
	public var songSpeed(default, set):Float = 1;
	public var songSpeedType:String = "multiplicative";
	public var noteKillOffset:Float = 350;

	public var playbackRate(default, set):Float = 1;

	public var boyfriendGroup:FlxSpriteGroup;
	public var dadGroup:FlxSpriteGroup;
	public var gfGroup:FlxSpriteGroup;
	public static var curStage:String = '';
	public static var stageUI:String = "normal";
	public static var isPixelStage(get, never):Bool;
	public static var isGreyscale:Bool = false;

	@:noCompletion
	static function get_isPixelStage():Bool
		return stageUI == "pixel" || stageUI.endsWith("-pixel") || SONG != null && (SONG.song == "Malfunction" || SONG.song == "Malfunction Legacy" || SONG.song == "Cycled Sins" || SONG.song == "Cycled Sins Legacy");

	public static var SONG:SwagSong = null;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;

	public var spawnTime:Float = 2000;

	public var inst:FlxSound;
	public var vocals:FlxSound;
	public var opponentVocals:FlxSound;

	public var dad:Character = null;
	public var gf:Character = null;
	public var boyfriend:Character = null;

	public static var gameBopIntensity:Float = 0;
	public static var uiBopIntensity:Float = 0;

	public var notes:FlxTypedGroup<Note>;
	public var unspawnNotes:Array<Note> = [];
	public var eventNotes:Array<EventNote> = [];

	//Handles the new epic mega sexy cam code that i've done
	public var camFollow:FlxPoint;
	public var camFollowPos:FlxObject;
	private static var prevCamFollow:FlxPoint;
	private static var prevCamFollowPos:FlxObject;

	public var strumLineNotes:FlxTypedGroup<StrumNote>;
	public var opponentStrums:FlxTypedGroup<StrumNote>;
	public var playerStrums:FlxTypedGroup<StrumNote>;
	public var grpNoteSplashes:FlxTypedGroup<NoteSplash>;

	public var camZooming:Bool = false;
	public var camZoomingMult:Float = 1;
	public var camZoomingDecay:Float = 1;
	private var curSong:String = "";

	public static var songCard:SongCard;

	public var gfSpeed:Int = 1;
	public var healthThing:Float = 1;
	public var healthLerp:Float = 1;
	public var combo:Int = 0;

	public var healthBar:Bar;
	public var timeBar:Bar;
	var songPercent:Float = 0;

	public var ratingsData:Array<Rating> = Rating.loadDefault();
	
	private var generatedMusic:Bool = false;
	public var endingSong:Bool = false;
	public var startingSong:Bool = false;
	private var updateTime:Bool = true;
	public static var changedDifficulty:Bool = false;
	public static var chartingMode:Bool = false;
	public static var modchartingMode:Bool = false;

	//Gameplay settings
	public var healthGain:Float = 1;
	public var healthLoss:Float = 1;

	public var instakillOnMiss:Bool = false;
	public var cpuControlled:Bool = false;
	public var practiceMode:Bool = false;

	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;
	public var camHUD:FlxCamera;
	public var camBars:FlxCamera;
	public var camGame:FlxCamera;
	public var camOther:FlxCamera;
	public var fakeCam:FlxCamera;
	public var camVideo:FlxCamera;
	public var cameraSpeed:Float = 1;

	var flashSprite:FlxSprite;
	var flashSpeed:Float = 0.0;
	var camTwn:Array<FlxTween> = [];

	public var songScore:Int = 0;
	public var songHits:Int = 0;
	public var songMisses:Int = 0;
	public var scoreTxt:FlxText;
	var timeTxt:FlxText;
	var scoreTxtTween:FlxTween;

	public var scratch:FlxSprite; // Peter Griffin: This reminds me of the time I met the Scratch cat
	public var scratchButLessVisible:FlxSprite;

	//vars for manageLyrics function
	var lyricsIcon:HealthIcon;
	var lyrics:FlxTypeText;
	var lyricsTween:FlxTween;
	var iconTween:FlxTween;

	// Display Texts
	public var infoDisplay:String = CoolUtil.dashToSpace(SONG.song);
	public var engineDisplay:String = '~ Episode 1 ~';

	public static var campaignScore:Int = 0;
	public static var campaignMisses:Int = 0;
	public static var seenCutscene:Bool = false;
	public static var deathCounter:Int = 0;
	public static var malfunctionTrollCounter:Int = 0;

	public var defaultCamZoom:Float = 1.05;

	// how big to stretch the pixel art assets
	public static var daPixelZoom:Float = 6;
	private var singAnimations:Array<String> = ['singLEFT', 'singDOWN', 'singUP', 'singRIGHT'];

	public var inCutscene:Bool = false;
	public var skipCountdown:Bool = false;
	var songLength:Float = 0;

	public var boyfriendCameraOffset:Array<Float> = null;
	public var opponentCameraOffset:Array<Float> = null;
	public var girlfriendCameraOffset:Array<Float> = null;

	#if DISCORD_ALLOWED
	// Discord RPC variables
	var storyDifficultyText:String = "";
	public static var detailsText:String = "";
	var detailsPausedText:String = "";
	#end

	//Achievement shit
	var keysPressed:Array<Int> = [];
	var boyfriendIdleTime:Float = 0.0;
	var boyfriendIdled:Bool = false;

	// Lua shit
	public static var instance:PlayState;

	#if HSCRIPT_ALLOWED
	private var luaDebugGroup:FlxTypedGroup<psychlua.DebugLuaText>;
	#end

	public var introSoundsSuffix:String = '';

	public var fancyBarOverlay:FlxSprite;
	public var watermarkTxt:FlxText;
	public var songTxt:FlxText;

	// Less laggy controls
	private var keysArray:Array<String>;
	public var songName:String;

	// Callbacks for stages
	public var startCallback:Void->Void = null;
	public var endCallback:Void->Void = null;

	// stores the last judgement object
	public static var lastRating:FlxSprite;
	// stores the last combo sprite object
	public static var lastCombo:FlxSprite;
	// stores the last combo score objects in an array
	public static var lastScore:Array<FlxSprite> = [];

	var backupGpu:Bool;
	var backupMiddlescroll:Bool;

	//FUNKIN.AVI V2
	var drainValue:Float = 0;
	var boundValue:Float = 0;
	public static var thing:Int;

	public var cinematicBars:Map<String, FlxSprite> = ["top" => null, "bottom" => null];

	public var chromTween:FlxTween;
	public var chromEffect:Float = 0.0001;

	public static var pathway:String = '';

	public static var curEpisode:String;

	var stageBGFlash:FlxSprite;
	var stageBGDark:FlxSprite;
	var stageBGColor:FlxSprite;

	var BGFlashTween:FlxTween;
	var BGDarkTween:FlxTween;
	var BGTweenColor:FlxTween;

	public var globalGradient:FlxSprite;

	public static var blendFlash:FlxSprite;
	var flashTween:FlxTween;

	public static var windowName:String = "";
	public static var windowTimer:FlxTimer;

	//Pause/gameOver variables
	public static var pauseCountEnabled:Bool = false;
	public static var useFakeDeluName:Bool = false;

	public var canBopCam:Bool = false;

	var autism:Float = 0.42;
	var	autisticDesires:Float = 15; //apparently, i needed another value for some decay value bullshit
	var forceAutismIntoThisNoteLikeAnAverageAmericanDoctor:Float = 0.7;

	public var shadowDad:Shadow;
	public var shadowBF:Shadow;
	public var shadowGF:Shadow;
	public var spawnShadow:Array<Bool> = [false, false, false];

	//META EVENT VARIABLES
	var discordIcon:String;
	var discordTxt:Array<String> = [];
	var isDisplayingScore:Bool = true;

	var winX(default, set):Int;
	var winY(default, set):Int;


	@:noCompletion function set_winX(x:Int):Int { 
		winX = x;
		Lib.application.window.x = winX;
		return x; 
	}

	@:noCompletion function set_winY(y:Int):Int {
		winY = y;
		Lib.application.window.y = winY;
		return y; 
	}

	var subtitles:SubtitlesBox;
	var subtitleTwnHandler:Array<FlxTween> = [];
	var iconHandler:Array<FlxTween> = [];
	public var malThing:FlxCamera; 

	override public function create()
	{
		//trace('Playback Rate: ' + playbackRate);
		Paths.clearStoredMemory();

		startCallback = startCountdown;
		endCallback = endSong;

		// for lua
		instance = this;

		PauseSubState.songName = null; //Reset to default
		playbackRate = ClientPrefs.getGameplaySetting('songspeed');

		keysArray = [
			'note_left',
			'note_down',
			'note_up',
			'note_right'
		];

		if(FlxG.sound.music != null)
			FlxG.sound.music.stop();

		// Gameplay settings
		healthGain = ClientPrefs.getGameplaySetting('healthgain');
		healthLoss = ClientPrefs.getGameplaySetting('healthloss');
		instakillOnMiss = ClientPrefs.getGameplaySetting('instakill');
		practiceMode = ClientPrefs.getGameplaySetting('practice');
		cpuControlled = ClientPrefs.getGameplaySetting('botplay');

		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		malThing = new FlxCamera();
		camBars = new FlxCamera();
		camVideo = new FlxCamera();
		camOther = new FlxCamera();
		fakeCam = new FlxCamera();

		camHUD.bgColor.alpha = 0;
		camBars.bgColor.alpha = 0;
		camVideo.bgColor.alpha = 0;
		camOther.bgColor.alpha = 0;
		fakeCam.bgColor.alpha = 0;
		malThing.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camVideo, false);
		FlxG.cameras.add(camBars, false);
		FlxG.cameras.add(camHUD, false);
		FlxG.cameras.add(malThing, false);
		FlxG.cameras.add(camOther, false);
		FlxG.cameras.add(fakeCam, false);

		FlxG.cameras.setDefaultDrawTarget(camGame, true);
		grpNoteSplashes = new FlxTypedGroup<NoteSplash>();

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('isolated-null', 'isolated');

		Conductor.mapBPMChanges(SONG);
		Conductor.bpm = SONG.bpm;

		if (!isStoryMode) 
			GameData.setFreeplayData();
		else
		{
			switch (SONG.song)
			{
				case "Birthday":
					GameData.birthdayLocky = 'unlocked';
					GameData.saveShit();
			}
			if (!GameData.canOverrideCPU)
				GameData.checkBotplay(null);
		}

		switch (SONG.song)
		{
			case "Isolated Old" | "Isolated Beta" | "Isolated Legacy" | "Lunacy Legacy" | "Delusional Legacy" | "Hunted Legacy" | "Twisted Grins Legacy" | "Cycled Sins Legacy" | "Mercy Legacy" | "Malfunction Legacy":
				AppIcon.changeIcon("legacyIcon");
			case "Malfunction":
				AppIcon.changeIcon("glitchIcon");
			default:
				AppIcon.changeIcon("newIcon");
		}

		#if DISCORD_ALLOWED
		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		storyDifficultyText = Difficulty.getString();

		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		if (isStoryMode)
		{
			detailsText = "Episode 1 - " + (SONG.song == "Dont Cross" ? "Don't Cross!" : SONG.song) + " (" + FreeplayState.getDiffRank() + ")";
		}
		else
		{
			detailsText = "Freeplay - " + (SONG.song == "Dont Cross" ? "Don't Cross!" : SONG.song) + " (" + FreeplayState.getDiffRank() + ")";
		}

		// String for when the game is paused
		detailsPausedText = "Paused - " + detailsText;
		#end

		songName = Paths.formatToSongPath(SONG.song);
		if(SONG.stage == null || SONG.stage.length < 1) {
			SONG.stage = StageData.vanillaSongStage(songName);
		}
		curStage = SONG.stage;

		// pathway = 'favi/stages/' + curStage;
		pathway = 'favi/stages/' + curStage + (SONG.song == "Malfunction" ? '/stupidShit/' : '/images/');
		
		trace('[PlayState] curStage=' + curStage
		+ ' SONG.stage=' + (SONG != null ? SONG.stage : 'null')
		+ ' pathway=' + pathway
		+ ' Paths.currentLevel=' + Paths.currentLevel);


		if (SONG.song != "Malfunction Legacy")
			daPixelZoom = 5;
		else
			daPixelZoom = 6;

		var stageData:StageFile = StageData.getStageFile(curStage);
		if(stageData == null) { //Stage couldn't be found, create a dummy stage for preventing a crash
			stageData = StageData.dummy();
		}

		defaultCamZoom = stageData.defaultZoom;

		stageUI = "normal";
		if (stageData.stageUI != null && stageData.stageUI.trim().length > 0)
			stageUI = stageData.stageUI;
		else {
			if (stageData.isPixelStage)
				stageUI = "pixel";
		}

		BF_X = stageData.boyfriend[0];
		BF_Y = stageData.boyfriend[1];
		GF_X = stageData.girlfriend[0];
		GF_Y = stageData.girlfriend[1];
		DAD_X = stageData.opponent[0];
		DAD_Y = stageData.opponent[1];

		if(stageData.camera_speed != null)
			cameraSpeed = stageData.camera_speed;

		boyfriendCameraOffset = stageData.camera_boyfriend;
		if(boyfriendCameraOffset == null) //Fucks sake should have done it since the start :rolling_eyes:
			boyfriendCameraOffset = [0, 0];

		opponentCameraOffset = stageData.camera_opponent;
		if(opponentCameraOffset == null)
			opponentCameraOffset = [0, 0];

		girlfriendCameraOffset = stageData.camera_girlfriend;
		if(girlfriendCameraOffset == null)
			girlfriendCameraOffset = [0, 0];

		boyfriendGroup = new FlxSpriteGroup(BF_X, BF_Y);
		dadGroup = new FlxSpriteGroup(DAD_X, DAD_Y);
		gfGroup = new FlxSpriteGroup(GF_X, GF_Y);

		isGreyscale = false;

		if (curStage != "waltRoom") healthThing = 0.5;

		switch (curStage)
		{
			case 'stage': new StageWeek1(); //Week 1
			case 'alleyway' | 'ddStage': new DDStage(); //Devilish Deal
			case 'abandonedStreet': new AbandonedStreet(); //Isolated, Lunacy, and Delusional
			case 'forestNew': new ForestNew(); //Hunted
			case 'circus': new Circus(); //Laugh Track
			case 'vaultRoom': new VaultRoom(); //Bless
			case 'fuckingLine': new FuckingLine(); //Don't Cross!
			case 'war': new War(); //War Dilemma
			case 'trueGrinsOfSins': new TrueGrinsOfSins(); //Twisted Grins
			case 'waltRoom': new WaltStage(); //Mercy/Mercy Legacy
			case 'apartment': new Apartment(); //Cycled Sins
			case 'grassNation': new GrassNation(); //Malfunction
			case 'clubhouse': new Clubhouse(); //Birthday
			case 'staticVoid': new StaticVoid(); //RS lmao
			case 'menuSongs': new MenuSongs(); //Menu Songs
			//Legacy is A S S
			case 'theLoop': new TheLoop(); //Episode 1 legacy songs
			case 'forestOld': new ForestOld(); //Hunted Legacy
			case 'smilesOffice': new SmilesOffice(); //Twisted Grins Legacy
			case 'forbiddenRealm': new ForbiddenRealm(); //Malfunction Legacy
			case 'testingArea': new TestStage(); //test area
		}

		stageBGDark = new FlxSprite().makeGraphic(1, 1, 0xFFFFFFFF);
		stageBGDark.scale.set(FlxG.width * 5, FlxG.height * 5);
		stageBGDark.alpha = 0.0001; // it's at this value so the game doesn't lag when it becomes visible
		stageBGDark.x -= 750;
		stageBGDark.y -= 450;
		stageBGDark.scrollFactor.set();
		add(stageBGDark);

		stageBGColor = new FlxSprite().makeGraphic(1, 1, 0xFFFFFFFF);
		stageBGColor.scale.set(FlxG.width * 5, FlxG.height * 5);
		stageBGColor.alpha = 0.0001; // it's at this value so the game doesn't lag when it becomes visible
		stageBGColor.x -= 750;
		stageBGColor.y -= 450;
		stageBGColor.scrollFactor.set();
		add(stageBGColor);

		stageBGFlash = new FlxSprite().makeGraphic(1, 1, 0xFFFFFFFF);
		stageBGFlash.scale.set(FlxG.width * 5, FlxG.height * 5);
		stageBGFlash.alpha = 0.0001; // it's at this value so the game doesn't lag when it becomes visible
		stageBGFlash.x -= 750;
		stageBGFlash.y -= 450;
		stageBGFlash.scrollFactor.set();
		add(stageBGFlash);

		switch (SONG.song)
		{
			case "Isolated" | "Devilish Deal" | "Lunacy" | "Delusional" | "Hunted" | "Twisted Grins" | "Twisted Grins Legacy" | "Laugh Track" |  "Isolated Old" | "Isolated Beta" | "Isolated Legacy" | "Lunacy Legacy" | "Delusional Legacy" | "Hunted Legacy" | "Birthday" | "Rotten Petals" | "Seeking Freedom" | "Am I Real?" | "Curtain Call" | "Your Final Bow" | "Mistful Wind" | "The Wretched Tilezones (Simple Life)" | "Ship the Fart Yay Hooray <3 (Distant Stars)" | "Ahh the Scary (Somber Night)" | "Alone":
				introSoundsSuffix = "-cartoon";
			case "Cycled Sins Legacy" | "Cycled Sins":
				introSoundsSuffix = "-sins";
			case "Malfunction":
				introSoundsSuffix = "-error";
			case "Malfunction Legacy":
				introSoundsSuffix = "-glitch";
			default:
				if(isPixelStage) {
					introSoundsSuffix = '-pixel';
				}
		}

		add(gfGroup);
		add(dadGroup);
		add(boyfriendGroup);

		var checkSongForGimmicks:Array<String> = [
			"Isolated",
			"Lunacy",
			"Delusional",
			"Hunted",
			"Laugh Track",
			"Dont Cross",
			"Cycled Sins",
			"Bless",
			"Mercy",
			"Cycled Sins Legacy",
			"Mercy Legacy",
			"War Dilemma"
		];

		var checkMechanics:Bool = false;
		for (i in 0...checkSongForGimmicks.length)
			if (SONG.song == checkSongForGimmicks[i])
				checkMechanics = true;

		switch (SONG.song)
		{
			case "Devilish Deal" | "Isolated" | "Lunacy" | "Delusional": curEpisode = "Episode 1";
			case "Complications" | "Hallucinations" | "Backfired": curEpisode = "Episode 2"; // might as well prepare it early (these names are just made up, idk what the real ones are lmao)
			default: curEpisode = "Episode ???";
		}

		if (SONG.song == "Devilish Deal" && isStoryMode && GameData.episode1FPLock != "unlocked")
			windowName = "Funkin.avi - Episode 1 - Isolated (Composed by: obscurity) - Chart by: Purg [NORMAL] - Mechanics: " + (ClientPrefs.data.mechanics ? "Enabled" : "Disabled"); // shitty long ass name that credits literally every fucking thing
		else
			windowName = "Funkin.avi - " + 
			(isStoryMode ? curEpisode + " - " : "Freeplay - ") + 
			(SONG.song == "Dont Cross" ? "Don't Cross!" : SONG.song) + 
			" (Composed by: " + FreeplayState.getArtistName() + 
			") - Chart by: " + Song.getCharterCredits() + 
			" [" + FreeplayState.getDiffRank() + "]" + 
			(checkMechanics ? ' - Mechanics: ' + (ClientPrefs.data.mechanics ? "Enabled" : "Disabled") : ""); // shitty long ass name that credits literally every fucking thing


		if (curStage == "menuSongs")
		{
			backupMiddlescroll = ClientPrefs.data.middleScroll;
			ClientPrefs.data.middleScroll = true;
		}
		

		#if HSCRIPT_ALLOWED
		luaDebugGroup = new FlxTypedGroup<psychlua.DebugLuaText>();
		luaDebugGroup.cameras = [camOther];
		add(luaDebugGroup);
		#end

		// "GLOBAL" SCRIPTS
		#if HSCRIPT_ALLOWED
		for (folder in Mods.directoriesWithFile(Paths.getSharedPath(), 'scripts/'))
			for (file in FileSystem.readDirectory(folder))
			{
				#if HSCRIPT_ALLOWED
				if(file.toLowerCase().endsWith('.hx'))
					initHScript(folder + file);
				#end
			}
		#end

		// STAGE SCRIPTS
		#if HSCRIPT_ALLOWED
		startHScriptsNamed('stages/' + curStage + '.hx');
		#end

		if (!stageData.hide_girlfriend)
		{
			if(SONG.gfVersion == null || SONG.gfVersion.length < 1) SONG.gfVersion = 'gf'; //Fix for the Chart Editor
			gf = new Character(0, 0, SONG.gfVersion);
			startCharacterPos(gf);
			gf.scrollFactor.set(0.95, 0.95);
			gfGroup.add(gf);
			startCharacterScripts(gf.curCharacter);

			if (spawnShadow[2])
			{
				shadowGF = new Shadow(gf);
				shadowGF.parseData('shadowData-gf');
				startCharacterPos(shadowGF);
				shadowGF.scrollFactor.set(0.95, 0.95);
				if (shadowGF.hasData)
				{
					shadowGF.alpha = shadowGF.data.alpha;
					shadowGF.x += shadowGF.data.offsetData[0];
					shadowGF.y += shadowGF.data.offsetData[1];
					shadowGF.skew.x = shadowGF.data.skewData[0];
					shadowGF.skew.y = shadowGF.data.skewData[1];
					shadowGF.scale.set(shadowGF.data.scaleData[0], shadowGF.data.scaleData[1]);
					shadowGF.forceIsOnScreen = true;
					shadowGF.colorTransform.color = FlxColor.fromRGB(shadowGF.data.color[0], shadowGF.data.color[1], shadowGF.data.color[2]);
				}
				else
				{
					shadowGF.alpha = 0.001;
					shadowGF.x += 0;
					shadowGF.y += 0;
					shadowGF.skew.x = 0;
					shadowGF.skew.y = 0;
					shadowGF.scale.set(1, 1);
					shadowGF.forceIsOnScreen = true;
					shadowGF.colorTransform.color = FlxColor.BLACK;
				}
				addBehindGF(shadowGF);
			}
		}

		dad = new Character(0, 0, SONG.player2);
		startCharacterPos(dad, true);
		dadGroup.add(dad);
		startCharacterScripts(dad.curCharacter);

		boyfriend = new Character(0, 0, SONG.player1, true);
		startCharacterPos(boyfriend);
		boyfriendGroup.add(boyfriend);
		startCharacterScripts(boyfriend.curCharacter);

		if (spawnShadow[0])
		{
			shadowDad = new Shadow(dad);
			shadowDad.parseData('shadowData-dad');
			startCharacterPos(shadowDad, true);
			if (shadowDad.hasData)
			{
				shadowDad.alpha = shadowDad.data.alpha;
				shadowDad.x += shadowDad.data.offsetData[0];
				shadowDad.y += shadowDad.data.offsetData[1];
				shadowDad.skew.x = shadowDad.data.skewData[0];
				shadowDad.skew.y = shadowDad.data.skewData[1];
				shadowDad.scale.set(shadowDad.data.scaleData[0], shadowDad.data.scaleData[1]);
				shadowDad.forceIsOnScreen = true;
				shadowDad.colorTransform.color = FlxColor.fromRGB(shadowDad.data.color[0], shadowDad.data.color[1], shadowDad.data.color[2]);
			}
			else
			{
				shadowDad.alpha = 0.001;
				shadowDad.x += 0;
				shadowDad.y += 0;
				shadowDad.skew.x = 0;
				shadowDad.skew.y = 0;
				shadowDad.scale.set(1, 1);
				shadowDad.forceIsOnScreen = true;
				shadowDad.colorTransform.color = FlxColor.BLACK;
			}
			addBehindDad(shadowDad);
		}

		if (spawnShadow[1])
		{
			shadowBF = new Shadow(boyfriend);
			shadowBF.parseData('shadowData-bf');
			startCharacterPos(shadowBF);
			if (shadowBF.hasData)
			{
				shadowBF.alpha = shadowBF.data.alpha;
				shadowBF.x += shadowBF.data.offsetData[0];
				shadowBF.y += shadowBF.data.offsetData[1];
				shadowBF.skew.x = shadowBF.data.skewData[0];
				shadowBF.skew.y = shadowBF.data.skewData[1];
				shadowBF.scale.set(shadowBF.data.scaleData[0], shadowBF.data.scaleData[1]);
				shadowBF.forceIsOnScreen = true;
				shadowBF.colorTransform.color = FlxColor.fromRGB(shadowBF.data.color[0], shadowBF.data.color[1], shadowBF.data.color[2]);
			}
			else
			{
				shadowBF.alpha = 0.001;
				shadowBF.x += 0;
				shadowBF.y += 0;
				shadowBF.skew.x = 0;
				shadowBF.skew.y = 0;
				shadowBF.scale.set(1, 1);
				shadowBF.forceIsOnScreen = true;
				shadowBF.colorTransform.color = FlxColor.BLACK;
			}
			addBehindBF(shadowBF);
		}

		var camPos:FlxPoint = FlxPoint.get(girlfriendCameraOffset[0], girlfriendCameraOffset[1]);
		if(gf != null)
		{
			camPos.x += gf.getGraphicMidpoint().x + gf.cameraPosition[0];
			camPos.y += gf.getGraphicMidpoint().y + gf.cameraPosition[1];
		}

		if(dad.curCharacter.startsWith('gf')) {
			dad.setPosition(GF_X, GF_Y);
			if(gf != null)
				gf.visible = false;
		}
		stagesFunc(function(stage:BaseStage) stage.createPost());

		flashSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.WHITE);
		flashSprite.scale.set(3, 3);
		flashSprite.screenCenter();
		flashSprite.alpha = 0.001;
		flashSprite.cameras = [camBars];
		add(flashSprite);

		comboGroup = new FlxSpriteGroup();
		add(comboGroup);
		uiGroup = new FlxSpriteGroup();
		add(uiGroup);
		noteGroup = new FlxTypedGroup<FlxBasic>();
		add(noteGroup);

		blendFlash = new FlxSprite().makeGraphic(1, 1, 0xFFFFFFFF);
		blendFlash.scale.set(FlxG.width * 5, FlxG.height * 5);
		blendFlash.alpha = 0.0001;
		blendFlash.blend = ADD;
		blendFlash.x -= 750;
		blendFlash.y -= 450;
		blendFlash.scrollFactor.set();
		add(blendFlash);

		Conductor.songPosition = -5000 / Conductor.songPosition;

		if (!ClientPrefs.data.middleScroll)
			middlescroll = SONG.song.toLowerCase() == 'cycled sins' || curStage == "menuSongs";
		else
			middlescroll = true;

		var showTime:Bool = (ClientPrefs.data.timeBarType != 'Disabled');
		timeTxt = new FlxText(STRUM_X + (FlxG.width / 2) - 248, 19, 400, "", 32);
		timeTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		timeTxt.scrollFactor.set();
		timeTxt.alpha = 0;
		timeTxt.visible = false;
		timeTxt.borderSize = 2;
		timeTxt.visible = updateTime = showTime;
		if(ClientPrefs.data.downScroll) timeTxt.y = FlxG.height - 44;
		if(ClientPrefs.data.timeBarType == 'Song Name') timeTxt.text = SONG.song;

		timeBar = new Bar(0, timeTxt.y + (timeTxt.height / 4), 'timeBar', function() return songPercent, 0, 1);
		timeBar.scrollFactor.set();
		timeBar.screenCenter(X);
		timeBar.alpha = 0;
		timeBar.visible = false;
		uiGroup.add(timeBar);
		uiGroup.add(timeTxt);

		strumLineNotes = new FlxTypedGroup<StrumNote>();
		noteGroup.add(strumLineNotes);

		if(ClientPrefs.data.timeBarType == 'Song Name')
		{
			timeTxt.size = 24;
			timeTxt.y += 3;
		}

		var splash:NoteSplash = new NoteSplash(100, 100);
		grpNoteSplashes.add(splash);
		splash.alpha = 0.000001;

		opponentStrums = new FlxTypedGroup<StrumNote>();
		playerStrums = new FlxTypedGroup<StrumNote>();

		backupGpu = ClientPrefs.data.cacheOnGPU;
		ClientPrefs.data.cacheOnGPU = false;

		generateSong(SONG.song);

		playfieldRenderer = new PlayfieldRenderer(strumLineNotes, notes, this);
		noteGroup.add(playfieldRenderer);

		if (SONG.song == "Birthday" || SONG.song == "Delusional Legacy")
		{
			noteGroup.remove(playfieldRenderer);
			playfieldRenderer.destroy();

			strumLineNotes.visible = true;
			notes.visible = true; // the game will literally refuse to let the actual notes appear unless playfieldRenderer was made if you play these 2 songs before the others, fuck this man... (don)
		}
		noteGroup.add(grpNoteSplashes);


		camFollow = new FlxPoint();
		camFollowPos = new FlxObject(0, 0, 1, 1);

		snapCamFollowToPos(camPos.x, camPos.y);
		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}
		if (prevCamFollowPos != null)
		{
			camFollowPos = prevCamFollowPos;
			prevCamFollowPos = null;
		}
		add(camFollowPos);

		FlxG.camera.follow(camFollowPos, LOCKON, 1);
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow);

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;
		moveCameraSection();

		healthBar = new Bar(0, FlxG.height * (!ClientPrefs.data.downScroll ? 0.89 : 0.11), 'healthBar', function() return FreeplayState.freeplayMenuList != 2  ? healthLerp : healthThing, 0, 2);
		healthBar.screenCenter(X);
		healthBar.leftToRight = SONG.song == "Devilish Deal" ? true : false;
		healthBar.scrollFactor.set();
		healthBar.visible = !ClientPrefs.data.hideHud;
		healthBar.alpha = ClientPrefs.data.healthBarAlpha;
		reloadHealthBarColors();
		if(ClientPrefs.data.downScroll || curStage == "waltRoom" || curStage == "menuSongs") healthBar.y = FlxG.height * 0.11;

		//have to make an underlay so you can see the healthbar colors lmao
		fancyBarOverlay = new FlxSprite(healthBar.x, healthBar.y).loadGraphic(Paths.image('episode1Overlay'));
		fancyBarOverlay.scale.set(1.01, 1);
		fancyBarOverlay.screenCenter(X);
		fancyBarOverlay.scrollFactor.set();
		if (ClientPrefs.data.downScroll || curStage == "waltRoom" || curStage == "menuSongs")
		{
			fancyBarOverlay.y -= 10;
		}
		else
		{
			fancyBarOverlay.y -= 117;
			fancyBarOverlay.flipY = true;
		}
		fancyBarOverlay.visible = SONG.song.toLowerCase() != 'cycled sins';
		uiGroup.add(healthBar);
		if (FreeplayState.freeplayMenuList != 2)
			uiGroup.add(fancyBarOverlay);

		iconP1 = new HealthIcon((SONG.song == "Mercy" ? "everettmercy" : boyfriend.healthIcon), (SONG.song == "Mercy" ? false : true));
		iconP1.y = healthBar.y - 75;

		// reposition specific icons on the healthbar properly
		switch (boyfriend.healthIcon)
		{
			case "everett" | "maleverett-pixel": iconP1.y -= 20;
			case "everettmodern": iconP1.y -= 10;
			case "everettb": iconP1.y -= 5;
		}

		iconP1.visible = !ClientPrefs.data.hideHud;
		iconP1.alpha = ClientPrefs.data.healthBarAlpha;
		uiGroup.add(iconP1);

		iconP2 = new HealthIcon(dad.healthIcon, false);
		iconP2.y = healthBar.y - 75;

		// reposition specific icons on the healthbar properly
		switch (dad.healthIcon)
		{
			case "walt" | "ricky" | "noise": iconP2.y -= 20;
			case "goofy" | "smile" | "relapseNEW-pixel": iconP2.y -= 10;
			case "cross": iconP2.y -= 15;
		}

		iconP2.visible = !ClientPrefs.data.hideHud;
		iconP2.alpha = ClientPrefs.data.healthBarAlpha;
		uiGroup.add(iconP2);
		reloadHealthBarColors();

		scoreTxt = new FlxText(0, ((curStage == "menuSongs" || curStage == "waltRoom") ? (ClientPrefs.data.downScroll ? 15 : 675) : healthBar.y + 36), FlxG.width, "", 20);
		scoreTxt.setFormat(Paths.font("DisneyFont.ttf"), (FreeplayState.freeplayMenuList == 2  ? 28 : 20), FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreTxt.scrollFactor.set();
		scoreTxt.borderSize = 1.25;
		scoreTxt.visible = (!ClientPrefs.data.hideHud || !cpuControlled);
		updateScore(false);
		uiGroup.add(scoreTxt);

		if (FreeplayState.freeplayMenuList == 2 && !isStoryMode)
		{
		#if desktop
			var peWatermark:FlxText = new FlxText(5, FlxG.height - 29, 0, "", 16);
			peWatermark.setFormat(Paths.font("DisneyFont.ttf"), 28, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			peWatermark.scrollFactor.set();
			peWatermark.text = 'Funkin.avi | $curSong (Hard)';
			peWatermark.cameras = [camOther];
			add(peWatermark);
		#end
			var SCALEdebugText:FlxText = new FlxText(10,10,200,"Default scale mode (ratio)");
			SCALEdebugText.scrollFactor.set(0,0);
			SCALEdebugText.cameras = [camOther];
			add(SCALEdebugText);
		}

		if (curStage == 'vaultRoom') iconP2.blend = ADD;

		if (curStage == "waltRoom" || curStage == "menuSongs")
		{
			fancyBarOverlay.flipY = true;
			for (bar in [healthBar, fancyBarOverlay])
			{
				bar.angle = 90;
				bar.x -= 580;
				bar.y += 270;
			}
			fancyBarOverlay.x += 54;
			fancyBarOverlay.y -= 53;
			iconP1.x = healthBar.x + 220;
			iconP2.x = healthBar.x + 220;
		}

		switch (SONG.song)
		{
			case "Devilish Deal" | "Isolated" | "Lunacy" | "Delusional":
				if (isStoryMode) 
					engineDisplay = "~ Episode 1 ~";
				else
					engineDisplay = "~ Freeplay ~";
			default:
				if (isStoryMode) 
					engineDisplay = "~ Episode ??? ~";
				else
					engineDisplay = "~ Freeplay ~";
		}
		watermarkTxt = new FlxText(0, 0, 0, engineDisplay);
		watermarkTxt.setFormat(Paths.font('DisneyFont.ttf'), 32, FlxColor.WHITE);
		watermarkTxt.setBorderStyle(OUTLINE, FlxColor.BLACK, 2);
		if (ClientPrefs.data.downScroll) watermarkTxt.setPosition(0, 655); else watermarkTxt.setPosition(0, 8);
		watermarkTxt.screenCenter(X);
		if (FreeplayState.freeplayMenuList != 2)
			uiGroup.add(watermarkTxt);

		songTxt = new FlxText(watermarkTxt.x, watermarkTxt.y + 30, 1280, (SONG.song == "Dont Cross" ? "Don't Cross!" : '$infoDisplay'));
		songTxt.setFormat(Paths.font('DisneyFont.ttf'), 22, FlxColor.WHITE, CENTER);
		songTxt.setBorderStyle(OUTLINE, FlxColor.BLACK, 2);
		songTxt.alpha = 0.6;
		songTxt.screenCenter(X);
		if (FreeplayState.freeplayMenuList != 2)
			uiGroup.add(songTxt);

		if (curStage == "menuSongs")
		{
			watermarkTxt.visible = false;
			songTxt.alpha = 1;
			songTxt.angle = 90;
			songTxt.screenCenter(Y);
			songTxt.x += 270;
			scoreTxt.screenCenter(Y);
			scoreTxt.angle = -90;
			scoreTxt.x -= 270;
			iconP1.visible = false;
			iconP2.visible = false;
		}

		if (!ClientPrefs.data.lowQuality)
		{
			globalGradient = new FlxSprite().loadGraphic(Paths.image('favi/filters/gradient'));
			globalGradient.screenCenter();
			globalGradient.setGraphicSize(Std.int(globalGradient.width * 0.68));
			globalGradient.cameras = [camOther];
			globalGradient.alpha = 0;
			add(globalGradient);
		}

		uiGroup.cameras = [camHUD];
		noteGroup.cameras = [camHUD];
		comboGroup.cameras = [camHUD];

		if (!ClientPrefs.data.lowQuality)
		{
			switch (curStage)
			{
				case 'stage' | 'desktop' | 'waltRoom' | 'apartment' | 'treasureIsland' | 'forbiddenRealm' | 'fuckingLine' | 'staticVoid' | 'vaultRoom' | 'war' | 'grassNation' | 'testingArea':
				// don't add scratch assets

				case 'theLoop':
					scratch = new FlxSprite();
					scratch.frames = Paths.getSparrowAtlas('favi/filters/scratchShit');
					scratch.animation.addByPrefix('e', 'scratch thing', 24, true);
					scratch.animation.play('e');
					scratch.cameras = [camHUD];
					add(scratch);
				
				default:
					scratch = new FlxSprite();
					scratch.frames = Paths.getSparrowAtlas('favi/filters/scratchShit');
					scratch.animation.addByPrefix('e', 'scratch thing', 24, true);
					scratch.animation.play('e');
					scratch.cameras = [camOther];
					add(scratch);
			}
		}

		// shitty thing to make it so the health bar is visible at all times
		if (curStage == "waltRoom")
		{
			for (funny in [healthBar, fancyBarOverlay, iconP1, iconP2])
				funny.cameras = [fakeCam];
		}

		startingSong = true;

		lime.app.Application.current.window.title = windowName;

		windowTimer = new FlxTimer().start(5, function(tmr:FlxTimer)
		{
			windowName = "Funkin.avi - " + (isStoryMode ? curEpisode + " - " : "Freeplay - ") + (SONG.song == "Dont Cross" ? "Don't Cross!" : SONG.song) + " [" + FreeplayState.getDiffRank() + "]"; // short version that displays after 5 seconds yayaya

			lime.app.Application.current.window.title = windowName;
		});

		#if HSCRIPT_ALLOWED
		for (notetype in noteTypes)
			startHScriptsNamed('custom_notetypes/' + notetype + '.hx');
		for (event in eventsPushed)
			startHScriptsNamed('custom_events/' + event + '.hx');
		#end

		noteTypes = null;
		eventsPushed = null;

		if(eventNotes.length > 1)
		{
			for (event in eventNotes) event.strumTime -= eventEarlyTrigger(event);
			eventNotes.sort(sortByTime);
		}

		// SONG SPECIFIC SCRIPTS
		#if HSCRIPT_ALLOWED
		for (folder in Mods.directoriesWithFile(Paths.getSharedPath(), 'data/$songName/'))
			for (file in FileSystem.readDirectory(folder))
			{
				#if HSCRIPT_ALLOWED
				if(file.toLowerCase().endsWith('.hx'))
					initHScript(folder + file);
				#end
			}
		#end

		startCallback();
		RecalculateRating();

		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyRelease);

		//PRECACHING THINGS THAT GET USED FREQUENTLY TO AVOID LAGSPIKES
		if(ClientPrefs.data.hitsoundVolume > 0) Paths.sound('hitsound');
		for (i in 1...4) Paths.sound('missnote$i');
		Paths.image('alphabet');

		if (PauseSubState.songName != null)
			Paths.music(PauseSubState.songName, 'music');
		else if(Paths.formatToSongPath(ClientPrefs.data.pauseMusic) != 'none')
			Paths.music(Paths.formatToSongPath(ClientPrefs.data.pauseMusic));

		resetRPC();

		callOnScripts('onCreatePost');

		cacheCountdown();
		cachePopUpScore();

		subtitles = new SubtitlesBox(camOther, iconHandler, subtitleTwnHandler);
		add(subtitles);

		songCard = new SongCard();
		songCard.cameras = [camOther];
		add(songCard);

		super.create();
		Paths.clearUnusedMemory();

		if(eventNotes.length < 1) checkEventNote();
	}

	function set_songSpeed(value:Float):Float
	{
		if(generatedMusic)
		{
			var ratio:Float = value / songSpeed; //funny word huh
			if(ratio != 1)
			{
				for (note in notes.members) note.resizeByRatio(ratio);
				for (note in unspawnNotes) note.resizeByRatio(ratio);
			}
		}
		songSpeed = value;
		noteKillOffset = Math.max(Conductor.stepCrochet, 350 / songSpeed * playbackRate);
		return value;
	}

	function set_playbackRate(value:Float):Float
	{
		#if FLX_PITCH
		if(generatedMusic)
		{
			vocals.pitch = value;
			opponentVocals.pitch = value;
			FlxG.sound.music.pitch = value;

			var ratio:Float = playbackRate / value; //funny word huh
			if(ratio != 1)
			{
				for (note in notes.members) note.resizeByRatio(ratio);
				for (note in unspawnNotes) note.resizeByRatio(ratio);
			}
		}
		playbackRate = value;
		FlxG.animationTimeScale = value;
		Conductor.safeZoneOffset = (ClientPrefs.data.safeFrames / 60) * 1000 * value;
		setOnScripts('playbackRate', playbackRate);
		#else
		playbackRate = 1.0; // ensuring -Crow
		#end
		return playbackRate;
	}

	#if HSCRIPT_ALLOWED
	public function addTextToDebug(text:String, color:FlxColor) {
		var newText:psychlua.DebugLuaText = luaDebugGroup.recycle(psychlua.DebugLuaText);
		newText.text = text;
		newText.color = color;
		newText.disableTime = 6;
		newText.alpha = 1;
		newText.setPosition(10, 8 - newText.height);

		luaDebugGroup.forEachAlive(function(spr:psychlua.DebugLuaText) {
			spr.y += newText.height + 2;
		});
		luaDebugGroup.add(newText);

		Sys.println(text);
	}
	#end

	public function reloadHealthBarColors() {
		switch (SONG.song)
		{
			case "Mercy":
				healthBar.setColors(FlxColor.fromRGB(97, 72, 52), 
					FlxColor.fromRGB(255, 239, 176));
			case "Devilish Deal":
				healthBar.setColors(FlxColor.fromRGB(135, 99, 99),
					FlxColor.fromRGB(158, 158, 158));
			default:
				healthBar.setColors(FlxColor.fromRGB(dad.healthColorArray[0], dad.healthColorArray[1], dad.healthColorArray[2]),
					FlxColor.fromRGB(boyfriend.healthColorArray[0], boyfriend.healthColorArray[1], boyfriend.healthColorArray[2]));
		}
		healthBar.updateBar();
	}

	public function addCharacterToList(newCharacter:String, type:Int) {
		switch(type) {
			case 0:
				if(!boyfriendMap.exists(newCharacter)) {
					var newBoyfriend:Character = new Character(0, 0, newCharacter, true);
					boyfriendMap.set(newCharacter, newBoyfriend);
					boyfriendGroup.add(newBoyfriend);
					startCharacterPos(newBoyfriend);
					newBoyfriend.alpha = 0.00001;
					startCharacterScripts(newBoyfriend.curCharacter);
				}

			case 1:
				if(!dadMap.exists(newCharacter)) {
					var newDad:Character = new Character(0, 0, newCharacter);
					dadMap.set(newCharacter, newDad);
					dadGroup.add(newDad);
					startCharacterPos(newDad, true);
					newDad.alpha = 0.00001;
					startCharacterScripts(newDad.curCharacter);
				}

			case 2:
				if(gf != null && !gfMap.exists(newCharacter)) {
					var newGf:Character = new Character(0, 0, newCharacter);
					newGf.scrollFactor.set(0.95, 0.95);
					gfMap.set(newCharacter, newGf);
					gfGroup.add(newGf);
					startCharacterPos(newGf);
					newGf.alpha = 0.00001;
					startCharacterScripts(newGf.curCharacter);
				}
		}
	}

	function startCharacterScripts(name:String)
	{
		// HScript
		#if HSCRIPT_ALLOWED
		var doPush:Bool = false;
		var scriptFile:String = 'characters/' + name + '.hx';
		
		scriptFile = Paths.getSharedPath(scriptFile);
		if(FileSystem.exists(scriptFile))
			doPush = true;

		if(doPush)
		{
			if(Iris.instances.exists(scriptFile))
				doPush = false;

			if(doPush) initHScript(scriptFile);
		}
		#end
	}

	public function getLuaObject(tag:String, text:Bool=true):FlxSprite {
		return null;
	}

	function startCharacterPos(char:Character, ?gfCheck:Bool = false) {
		if(gfCheck && char.curCharacter.startsWith('gf')) { //IF DAD IS GIRLFRIEND, HE GOES TO HER POSITION
			char.setPosition(GF_X, GF_Y);
			char.scrollFactor.set(0.95, 0.95);
			char.danceEveryNumBeats = 2;
		}
		char.x += char.positionArray[0];
		char.y += char.positionArray[1];
	}

	public function startVideo(name:String)
	{
		#if VIDEOS_ALLOWED
		inCutscene = true;

		var filepath:String = Paths.video(name);
		#if sys
		if(!FileSystem.exists(filepath))
		#else
		if(!OpenFlAssets.exists(filepath))
		#end
		{
			FlxG.log.warn('Couldnt find video file: ' + name);
			startAndEnd();
			return;
		}

		var video:VideoHandler = new VideoHandler();
			#if (hxCodec >= "3.0.0")
			// Recent versions
			video.play(filepath);
			video.onEndReached.add(function()
			{
				video.dispose();
				startAndEnd();
				return;
			}, true);
			#else
			// Older versions
			video.playVideo(filepath);
			video.finishCallback = function()
			{
				startAndEnd();
				return;
			}
			#end
		#else
		FlxG.log.warn('Platform not supported!');
		startAndEnd();
		return;
		#end
	}

	function startAndEnd()
	{
		if(endingSong)
			endSong();
		else
			startCountdown();
	}

	var startTimer:FlxTimer;
	var finishTimer:FlxTimer = null;

	// For being able to mess with the sprites on Lua
	public var countdownIntro:FlxSprite;
	public var countdownReady:FlxSprite;
	public var countdownSet:FlxSprite;
	public var countdownGo:FlxSprite;
	public static var startOnTime:Float = 0;

	public var count3:FlxSound;
	public var count2:FlxSound;
	public var count1:FlxSound;
	public var countGo:FlxSound;

	function cacheCountdown()
	{
		var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
		introAssets.set('default', ['ready', 'set', 'go']);
		introAssets.set('pixel', ['pixelUI/ready-pixel', 'pixelUI/set-pixel', 'pixelUI/date-pixel']);
		introAssets.set('cartoon', ['favi/countdown/prepare', 'favi/countdown/ready', 'favi/countdown/set', 'favi/countdown/go']);
		introAssets.set('malfunction', ['favi/countdown/mal-prepare', 'favi/countdown/mal-ready', 'favi/countdown/mal-set', 'favi/countdown/mal-go']);
		introAssets.set('sins', ['favi/countdown/relapse-prepare', 'favi/countdown/relapse-ready', 'favi/countdown/relapse-set', 'favi/countdown/relapse-go']);

		var introAlts:Array<String> = introAssets.get('default');
		switch (SONG.song)
		{
			case "Isolated" | "Devilish Deal" | "Lunacy" | "Delusional" | "Hunted" | "Twisted Grins" | "Twisted Grins Legacy" | "Laugh Track" |  "Isolated Old" | "Isolated Beta" | "Isolated Legacy" | "Lunacy Legacy" | "Delusional Legacy" | "Hunted Legacy" | "Birthday" | "Rotten Petals" | "Curtain Call" | "Seeking Freedom" | "Mistful Wind" | "Am I Real?" | "Your Final Bow" | "Ship the Fart Yay Hooray <3 (Distant Stars)" | "The Wretched Tilezones (Simple Life)" | "Ahh the Scary (Somber Night)" | "Alone":
				introAlts = introAssets.get('cartoon');
			case "Cycled Sins Legacy" | "Cycled Sins":
				introAlts = introAssets.get('sins');
			case "Malfunction" | "Malfunction Legacy":
				introAlts = introAssets.get('malfunction');
			default:
				if(isPixelStage) {
					introAlts = introAssets.get('pixel');
				}
		}
		
		for (asset in introAlts)
			Paths.image(asset);
		
		Paths.sound('intro3' + introSoundsSuffix);
		Paths.sound('intro2' + introSoundsSuffix);
		Paths.sound('intro1' + introSoundsSuffix);
		Paths.sound('introGo' + introSoundsSuffix);
	}

	public function startCountdown()
	{
		if(startedCountdown) {
			callOnScripts('onStartCountdown');
			return false;
		}

		seenCutscene = true;
		inCutscene = false;
		var ret:Dynamic = callOnScripts('onStartCountdown', null, true);
		if(ret != LuaUtils.Function_Stop) {
			if (skipCountdown || startOnTime > 0) skipArrowStartTween = true;

			generateStaticArrows(0);
			generateStaticArrows(1);

			if (SONG.song != "Birthday")
				NoteMovement.getDefaultStrumPos(this);

			winX = Std.int((Lib.application.window.display.bounds.width - Lib.application.window.width) * 0.5);
			winY = Std.int((Lib.application.window.display.bounds.height - Lib.application.window.height) * 0.5);

			count3 = new FlxSound().loadEmbedded(Paths.sound('intro3' + introSoundsSuffix));
			count2 = new FlxSound().loadEmbedded(Paths.sound('intro2' + introSoundsSuffix));
			count1 = new FlxSound().loadEmbedded(Paths.sound('intro1' + introSoundsSuffix));
			countGo = new FlxSound().loadEmbedded(Paths.sound('introGo' + introSoundsSuffix));

			for (sfx in [count3, count2, count1, countGo])
			{
				FlxG.sound.list.add(sfx);
				sfx.volume = 0.6;
			}

			Lib.application.window.onClose.removeAll();
			Lib.application.window.onClose.add(function() {
				persistentUpdate = false;
				persistentDraw = true;
				paused = true;
	
				if(inst != null) {
					inst.pause();
					vocals.pause();
					opponentVocals.pause();
				}
	
				openSubState(new gameObjects.ui.customEditorUI.Prompt('Are you sure you want to quit?\n\nYou will lose your unsaved progress.', 0, function(){
					System.exit(0);
					DiscordClient.shutdown();
				}, function(){
					persistentUpdate = true;
					persistentDraw = true;
				},false, camOther));
				Lib.application.window.onClose.cancel();
			});

			for (i in 0...playerStrums.length) {
				setOnScripts('defaultPlayerStrumX' + i, playerStrums.members[i].x);
				setOnScripts('defaultPlayerStrumY' + i, playerStrums.members[i].y);
			}
			for (i in 0...opponentStrums.length) {
				setOnScripts('defaultOpponentStrumX' + i, opponentStrums.members[i].x);
				setOnScripts('defaultOpponentStrumY' + i, opponentStrums.members[i].y);
			}

			startedCountdown = true;
			Conductor.songPosition = SONG.song == "Cycled Sins" ? ((-.8 * 5) * 1000) : -Conductor.crochet * 5;
			setOnScripts('startedCountdown', true);
			callOnScripts('onCountdownStarted', null);

			var swagCounter:Int = 0;

			if (startOnTime > 0) {
				clearNotesBefore(startOnTime);
				setSongTime(startOnTime - 350);
				return true;
			}
			else if (skipCountdown)
			{
				setSongTime(0);
				return true;
			}
			moveCameraSection();

			startTimer = new FlxTimer().start(SONG.song == "Cycled Sins" ? .8 : Conductor.crochet / 1000 / playbackRate, function(tmr:FlxTimer)
			{
				characterBopper(tmr.loopsLeft);

				var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
				introAssets.set('default', ['ready', 'set', 'go']);
				introAssets.set('pixel', ['pixelUI/ready-pixel', 'pixelUI/set-pixel', 'pixelUI/date-pixel']);
				introAssets.set('cartoon', ['favi/countdown/prepare', 'favi/countdown/ready', 'favi/countdown/set', 'favi/countdown/go']);
				introAssets.set('malfunction', ['favi/countdown/mal-prepare', 'favi/countdown/mal-ready', 'favi/countdown/mal-set', 'favi/countdown/mal-go']);
				introAssets.set('sins', ['favi/countdown/relapse-prepare', 'favi/countdown/relapse-ready', 'favi/countdown/relapse-set', 'favi/countdown/relapse-go']);

				var introAlts:Array<String> = introAssets.get('default');
				var antialias:Bool = ClientPrefs.data.antialiasing;
				switch (SONG.song)
				{
					case "Isolated" | "Devilish Deal" | "Lunacy" | "Delusional" | "Hunted" | "Twisted Grins" | "Twisted Grins Legacy" | "Laugh Track" |  "Isolated Old" | "Isolated Beta" | "Isolated Legacy" | "Lunacy Legacy" | "Delusional Legacy" | "Hunted Legacy" | "Birthday" | "Rotten Petals" | "Curtain Call" | "Seeking Freedom" | "Mistful Wind" | "Am I Real?" | "Your Final Bow" | "Ship the Fart Yay Hooray <3 (Distant Stars)" | "The Wretched Tilezones (Simple Life)" | "Ahh the Scary (Somber Night)" | "Alone":
						introAlts = introAssets.get('cartoon');
					case "Cycled Sins Legacy" | "Cycled Sins":
						introAlts = introAssets.get('sins');
						antialias = false;
					case "Malfunction" | "Malfunction Legacy":
						introAlts = introAssets.get('malfunction');
						antialias = false;
					default:
						if(isPixelStage) {
							introAlts = introAssets.get('pixel');
							antialias = false;
						}
				}

				switch (swagCounter)
				{
					case 0:
						countdownIntro = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
						countdownIntro.cameras = [camOther];
						countdownIntro.scrollFactor.set();
						countdownIntro.updateHitbox();

						if (isPixelStage)
							countdownIntro.setGraphicSize(Std.int(countdownIntro.width * daPixelZoom));

						countdownIntro.screenCenter();
						countdownIntro.antialiasing = antialias;
						switch (SONG.song)
						{
							case "Delusional":
								//nothing
							case "War Dilemma" | "Dont Cross" | "Bless" | "Mercy" | "Mercy Legacy" | "Delutrance":
								count3.play();
							default:
								add(countdownIntro);
								FlxTween.tween(countdownIntro, {alpha: 0}, Conductor.crochet / 1000, {
									ease: FlxEase.cubeInOut,
									onComplete: function(twn:FlxTween)
									{
										remove(countdownIntro);
										countdownIntro.destroy();
									}
								});
								count3.play();
						}
					case 1:
						switch (SONG.song)
						{
							case "Delusional":
								//nothing
							case "War Dilemma" | "Dont Cross" | "Bless" | "Mercy" | "Mercy Legacy" | "Delutrance":
								countdownReady = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
								countdownReady.cameras = [camOther];
								countdownReady.scrollFactor.set();
								countdownReady.updateHitbox();

								if (isPixelStage)
									countdownReady.setGraphicSize(Std.int(countdownReady.width * daPixelZoom));

								countdownReady.screenCenter();
								countdownReady.antialiasing = antialias;
								add(countdownReady);
								FlxTween.tween(countdownReady, {/*y: countdownReady.y + 100,*/ alpha: 0}, Conductor.crochet / 1000, {
									ease: FlxEase.cubeInOut,
									onComplete: function(twn:FlxTween)
									{
										remove(countdownReady);
										countdownReady.destroy();
									}
								});
								count2.play();
							default:
								countdownReady = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
								countdownReady.cameras = [camOther];
								countdownReady.scrollFactor.set();
								countdownReady.updateHitbox();

								if (isPixelStage)
									countdownReady.setGraphicSize(Std.int(countdownReady.width * daPixelZoom));

								countdownReady.screenCenter();
								countdownReady.antialiasing = antialias;
								add(countdownReady);
								FlxTween.tween(countdownReady, {/*y: countdownReady.y + 100,*/ alpha: 0}, Conductor.crochet / 1000, {
									ease: FlxEase.cubeInOut,
									onComplete: function(twn:FlxTween)
									{
										remove(countdownReady);
										countdownReady.destroy();
									}
								});
								count2.play();
						}
					case 2:
						switch (SONG.song)
						{
							case "Delusional":
								//nothing
							case "War Dilemma" | "Dont Cross" | "Bless" | "Mercy" | "Mercy Legacy" | "Delutrance":
								countdownSet = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
								countdownSet.cameras = [camOther];
								countdownSet.scrollFactor.set();

								if (isPixelStage)
									countdownSet.setGraphicSize(Std.int(countdownSet.width * daPixelZoom));

								countdownSet.screenCenter();
								countdownSet.antialiasing = antialias;
								insert(members.indexOf(notes), countdownSet);
								add(countdownSet);
								FlxTween.tween(countdownSet, {/*y: countdownSet.y + 100,*/ alpha: 0}, Conductor.crochet / 1000, {
									ease: FlxEase.cubeInOut,
									onComplete: function(twn:FlxTween)
									{
										remove(countdownSet);
										countdownSet.destroy();
									}
								});
								count1.play();
							default:
								countdownSet = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
								countdownSet.cameras = [camOther];
								countdownSet.scrollFactor.set();

								if (isPixelStage)
									countdownSet.setGraphicSize(Std.int(countdownSet.width * daPixelZoom));

								countdownSet.screenCenter();
								countdownSet.antialiasing = antialias;
								insert(members.indexOf(notes), countdownSet);
								add(countdownSet);
								FlxTween.tween(countdownSet, {/*y: countdownSet.y + 100,*/ alpha: 0}, Conductor.crochet / 1000, {
									ease: FlxEase.cubeInOut,
									onComplete: function(twn:FlxTween)
									{
										remove(countdownSet);
										countdownSet.destroy();
									}
								});
								count1.play();
						}
					case 3:
						switch (SONG.song)
						{
							case "Delusional":
								//nothing
							case "War Dilemma" | "Dont Cross" | "Bless" | "Mercy" | "Mercy Legacy" | "Delutrance":
								countdownGo = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
								countdownGo.cameras = [camOther];
								countdownGo.scrollFactor.set();

								if (isPixelStage)
									countdownGo.setGraphicSize(Std.int(countdownGo.width * daPixelZoom));

								countdownGo.updateHitbox();

								countdownGo.screenCenter();
								countdownGo.antialiasing = antialias;
								insert(members.indexOf(notes), countdownGo);
								add(countdownGo);
								FlxTween.tween(countdownGo, {/*y: countdownGo.y + 100,*/ alpha: 0}, Conductor.crochet / 1000, {
									ease: FlxEase.cubeInOut,
									onComplete: function(twn:FlxTween)
									{
										remove(countdownGo);
										countdownGo.destroy();
									}
								});
								countGo.play();
							default:
								countdownGo = new FlxSprite().loadGraphic(Paths.image(introAlts[3]));
								countdownGo.cameras = [camOther];
								countdownGo.scrollFactor.set();

								if (isPixelStage)
									countdownGo.setGraphicSize(Std.int(countdownGo.width * daPixelZoom));

								countdownGo.updateHitbox();

								countdownGo.screenCenter();
								countdownGo.antialiasing = antialias;
								insert(members.indexOf(notes), countdownGo);
								add(countdownGo);
								FlxTween.tween(countdownGo, {/*y: countdownGo.y + 100,*/ alpha: 0}, Conductor.crochet / 1000, {
									ease: FlxEase.cubeInOut,
									onComplete: function(twn:FlxTween)
									{
										remove(countdownGo);
										countdownGo.destroy();
									}
								});
								countGo.play();
						}
					case 4:
						if (ClientPrefs.data.pauseCountdown)
							pauseCountEnabled = true;
					case 5:
						new FlxTimer().start(0.5, function(tmr:FlxTimer) {
							for (sfx in [count3, count2, count1, countGo])
							{
								FlxG.sound.list.remove(sfx);
								sfx = null;
							}
						});
				}

				notes.forEachAlive(function(note:Note) {
					if(ClientPrefs.data.opponentStrums || note.mustPress)
					{
						note.copyAlpha = false;
						note.alpha = note.multAlpha;
						if(middlescroll && !note.mustPress)
							note.alpha *= 0.35;
					}
				});

				//stagesFunc(function(stage:BaseStage) stage.countdownTick(tick, swagCounter));
				callOnLuas('onCountdownTick', [swagCounter]);
				//callOnHScript('onCountdownTick', [tick, swagCounter]);

				swagCounter += 1;
			}, 5);
		}
		return true;
	}

	public function addBehindGF(obj:FlxBasic)
	{
		insert(members.indexOf(gfGroup), obj);
	}
	public function addBehindBF(obj:FlxBasic)
	{
		insert(members.indexOf(boyfriendGroup), obj);
	}
	public function addBehindDad(obj:FlxBasic)
	{
		insert(members.indexOf(dadGroup), obj);
	}

	public function clearNotesBefore(time:Float)
	{
		var i:Int = unspawnNotes.length - 1;
		while (i >= 0) {
			var daNote:Note = unspawnNotes[i];
			if(daNote.strumTime - 350 < time)
			{
				daNote.active = false;
				daNote.visible = false;
				daNote.ignoreNote = true;

				daNote.kill();
				unspawnNotes.remove(daNote);
				daNote.destroy();
			}
			--i;
		}

		i = notes.length - 1;
		while (i >= 0) {
			var daNote:Note = notes.members[i];
			if(daNote.strumTime - 350 < time)
			{
				daNote.active = false;
				daNote.visible = false;
				daNote.ignoreNote = true;
				invalidateNote(daNote);
			}
			--i;
		}
	}

	// fun fact: Dynamic Functions can be overriden by just doing this
	// `updateScore = function(miss:Bool = false) { ... }
	// its like if it was a variable but its just a function!
	// cool right? -Crow
	public dynamic function updateScore(miss:Bool = false)
	{
		var ret:Dynamic = callOnScripts('preUpdateScore', [miss], true);
		if (ret == LuaUtils.Function_Stop)
			return;

		if (FreeplayState.freeplayMenuList == 2)
			scoreTxt.text = 'Score: ' + songScore + ' | Misses: ' + songMisses + ' | Accuracy: ' + CoolUtil.floorDecimal(ratingPercent * 100, 2) + '% ' + ' [' + (ratingName != '?' ? '$ratingFC' : '?') + ']';//peeps wanted no integer rating
		//This basically now makes the score/misses look like this: 1,000 instead of this: 1000
		else
			scoreTxt.text = 'Score: ' + FlxStringUtil.formatMoney(songScore, false, true) + ' | Combo Breaks: ' + FlxStringUtil.formatMoney(songMisses, false, true) + ' | Rank: ' + (ratingName != '?' ? '$ratingFC (${CoolUtil.floorDecimal(ratingPercent * 100, 2)}%)' : '?');

		if (!miss && !cpuControlled)
			doScoreBop();

		callOnScripts('onUpdateScore', [miss]);
	}

	public var sicks:Int;
	public var goods:Int;
	public var bads:Int;
	public var shits:Int;
	public dynamic function fullComboFunction()
	{
		sicks = ratingsData[0].hits;
		goods = ratingsData[1].hits;
		bads = ratingsData[2].hits;
		shits = ratingsData[3].hits;
		ratingFC = "";
		if(songMisses == 0)
		{
			if (bads > 0 || shits > 0) ratingFC = 'FC';
			else if (goods > 0) ratingFC = 'GFC';
			else if (sicks > 0) ratingFC = 'SFC';
		}
		else {
			if (songMisses < 10) ratingFC = 'SDCB';
			else ratingFC = 'Clear';
		}
	}

	public function doScoreBop():Void {
		if(!ClientPrefs.data.scoreZoom)
			return;

		if(scoreTxtTween != null)
			scoreTxtTween.cancel();

		scoreTxt.scale.x = 1.075;
		scoreTxt.scale.y = 1.075;
		scoreTxtTween = FlxTween.tween(scoreTxt.scale, {x: 1, y: 1}, 0.2, {
			onComplete: function(twn:FlxTween) {
				scoreTxtTween = null;
			}
		});

		// Updating Discord Rich Presence (with Time Left)
		if (autoUpdateRPC)
			switch (SONG.song)
			{
				case "Joygrim" | "Neglection" | "Scrapped" | "Whimsical Bar Blues": DiscordClient.changePresence("Playing a song", "It's a secret...", "icon", "random", true, songLength - Conductor.songPosition - ClientPrefs.data.noteOffset);
				default: DiscordClient.changePresence(discordTxt[0], (isDisplayingScore ? scoreTxt.text : discordTxt[1]), CoolUtil.spaceToDash(discordIcon), "random", true, songLength - Conductor.songPosition - ClientPrefs.data.noteOffset);
			}
	}

	public function setSongTime(time:Float)
	{
		if(time < 0) time = 0;

		FlxG.sound.music.pause();
		vocals.pause();
		opponentVocals.pause();

		FlxG.sound.music.time = time;
		#if FLX_PITCH FlxG.sound.music.pitch = playbackRate; #end
		FlxG.sound.music.play();

		if (Conductor.songPosition <= vocals.length)
		{
			vocals.time = time;
			opponentVocals.time = time;
			#if FLX_PITCH
			vocals.pitch = playbackRate;
			opponentVocals.pitch = playbackRate;
			#end
		}
		vocals.play();
		opponentVocals.play();
		Conductor.songPosition = time;
	}

	function startSong():Void
	{
		startingSong = false;

		@:privateAccess
		FlxG.sound.playMusic(inst._sound, 1, false);
		#if FLX_PITCH FlxG.sound.music.pitch = playbackRate; #end
		FlxG.sound.music.onComplete = finishSong.bind();
		vocals.play();
		opponentVocals.play();

		if(startOnTime > 0) setSongTime(startOnTime - 500);
		startOnTime = 0;

		if(paused) {
			//trace('Oopsie doopsie! Paused sound');
			FlxG.sound.music.pause();
			vocals.pause();
			opponentVocals.pause();
		}

		if (songCard.isLegacy && ClientPrefs.data.songCards)
			songCard.playCardAnim(0);

		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;

		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence (with Time Left)
		if(autoUpdateRPC) 
			switch (SONG.song)
			{
				case "Joygrim" | "Neglection" | "Scrapped": DiscordClient.changePresence("Playing a song", "It's a secret...", "icon", "random", true, songLength);
				default: DiscordClient.changePresence(discordTxt[0], discordTxt[1], CoolUtil.spaceToDash(discordIcon), "random", true, songLength);
			}
		#end
		setOnScripts('songLength', songLength);
		callOnScripts('onSongStart');
	}

	var debugNum:Int = 0;
	private var noteTypes:Array<String> = [];
	private var eventsPushed:Array<String> = [];
	private function generateSong(dataPath:String):Void
	{
		// FlxG.log.add(ChartParser.parse());
		songSpeed = PlayState.SONG.speed;
		songSpeedType = ClientPrefs.getGameplaySetting('scrolltype');
		switch(songSpeedType)
		{
			case "multiplicative":
				songSpeed = SONG.speed * ClientPrefs.getGameplaySetting('scrollspeed');
			case "constant":
				songSpeed = ClientPrefs.getGameplaySetting('scrollspeed');
		}

		var songData = SONG;
		Conductor.bpm = songData.bpm;

		curSong = songData.song;

		vocals = new FlxSound();
		opponentVocals = new FlxSound();
		try
		{
			if (songData.needsVoices)
			{
				var playerVocals = Paths.voices(songData.song, (boyfriend.vocalsFile == null || boyfriend.vocalsFile.length < 1) ? 'Player' : boyfriend.vocalsFile);
				vocals.loadEmbedded(playerVocals != null ? playerVocals : Paths.voices(songData.song));
				
				var oppVocals = Paths.voices(songData.song, (dad.vocalsFile == null || dad.vocalsFile.length < 1) ? 'Opponent' : dad.vocalsFile);
				if(oppVocals != null) opponentVocals.loadEmbedded(oppVocals);
			}
		}
		catch(e:Dynamic) {}

		#if FLX_PITCH
		vocals.pitch = playbackRate;
		opponentVocals.pitch = playbackRate;
		#end
		FlxG.sound.list.add(vocals);
		FlxG.sound.list.add(opponentVocals);

		inst = new FlxSound();
		try {
			switch (SONG.song)
			{
				case "Rotten Petals":
					inst.loadEmbedded(Paths.music("aviOST/rottenPetals"));
				case "Seeking Freedom":
					inst.loadEmbedded(Paths.music("aviOST/seekingFreedom"));
				case "Curtain Call":
					inst.loadEmbedded(Paths.music("aviOST/curtainCall"));
				case "Mistful Wind":
					inst.loadEmbedded(Paths.music("aviOST/gameOver/mistfulWind"));
				case "Am I Real?":
					inst.loadEmbedded(Paths.music("aviOST/gameOver/amIReal"));
				case "Your Final Bow":
					inst.loadEmbedded(Paths.music("aviOST/gameOver/yourFinalBow"));
				case "The Wretched Tilezones (Simple Life)":
					inst.loadEmbedded(Paths.music("aviOST/pause/theWretchedTilezones"));
				case "Ahh the Scary (Somber Night)":
					inst.loadEmbedded(Paths.music("aviOST/pause/somberNight"));
				case "Ship the Fart Yay Hooray <3 (Distant Stars)":
					inst.loadEmbedded(Paths.music("aviOST/pause/shipTheFartYayHoorayv3v"));
				case "Alone":
					inst.loadEmbedded(Paths.music("aviOST/alone"));
				default:
					inst.loadEmbedded(Paths.inst(songData.song));
			}
		}
		catch(e:Dynamic) {}
		FlxG.sound.list.add(inst);

		notes = new FlxTypedGroup<Note>();
		noteGroup.add(notes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var songName:String = Paths.formatToSongPath(SONG.song);
		var fuckYou:String = "dont-cross";
		var file:String = Paths.json((SONG.song == "Dont Cross" ? fuckYou : songName) + '/events');
		var eventsData:Array<Dynamic>;

		if (OpenFlAssets.exists(file) || SONG.song == "Dont Cross" || (SONG.song == "Twisted Grins" && ClientPrefs.data.mechanics)) 
		{
			eventsData = Song.loadFromJson('events', (SONG.song == "Dont Cross" ? fuckYou : songName) ).events;
			for (event in eventsData) //Event Notes
			{
				for (i in 0...event[1].length)
				{
					var newEventNote:Array<Dynamic> = [event[0], event[1][i][0], event[1][i][1], event[1][i][2]];
					var subEvent:EventNote = {
						strumTime: newEventNote[0] + ClientPrefs.data.noteOffset,
						event: newEventNote[1],
						value1: newEventNote[2],
						value2: newEventNote[3]
					};
					subEvent.strumTime -= eventEarlyTrigger(subEvent);
					eventNotes.push(subEvent);
					eventPushed(subEvent);
				}
			}
		}

		for (section in noteData)
		{
			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0];
				var daNoteData:Int = Std.int(songNotes[1] % 4);
				var gottaHitNote:Bool = section.mustHitSection;

				if (songNotes[1] > 3)
				{
					gottaHitNote = !section.mustHitSection;
				}

				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;

				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote);
				swagNote.mustPress = gottaHitNote;
				swagNote.sustainLength = songNotes[2];
				swagNote.gfNote = (section.gfSection && (songNotes[1]<4));
				swagNote.noteType = songNotes[3];
				if(!Std.isOfType(songNotes[3], String)) swagNote.noteType = ChartingState.noteTypeList[songNotes[3]]; //Backward compatibility + compatibility with Week 7 charts

				swagNote.scrollFactor.set();

				unspawnNotes.push(swagNote);

				final susLength:Float = swagNote.sustainLength / Conductor.stepCrochet;
				final floorSus:Int = Math.floor(susLength);

				if(floorSus > 0) {
					for (susNote in 0...floorSus+1)
					{
						oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

						var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + (Conductor.stepCrochet / FlxMath.roundDecimal(songSpeed, 2)), daNoteData, oldNote, true);
						sustainNote.mustPress = gottaHitNote;
						sustainNote.gfNote = (section.gfSection && (songNotes[1]<4));
						sustainNote.noteType = swagNote.noteType;
						sustainNote.scrollFactor.set();
						swagNote.tail.push(sustainNote);
						sustainNote.parent = swagNote;
						unspawnNotes.push(sustainNote);

						if (sustainNote.mustPress)
						{
							sustainNote.x += FlxG.width / 2; // general offset
						}
						else if(middlescroll)
						{
							sustainNote.x += 310;
							if(daNoteData > 1) //Up and Right
							{
								sustainNote.x += FlxG.width / 2 + 25;
							}
						}
					}
				}

				if (swagNote.mustPress)
				{
					swagNote.x += FlxG.width / 2; // general offset
				}
				else if(middlescroll)
				{
					swagNote.x += 310;
					if(daNoteData > 1) //Up and Right
					{
						swagNote.x += FlxG.width / 2 + 25;
					}
				}

				if(!noteTypes.contains(swagNote.noteType)) {
					noteTypes.push(swagNote.noteType);
				}
			}
		}
		for (event in songData.events) //Event Notes
			for (i in 0...event[1].length)
				makeEvent(event, i);

		unspawnNotes.sort(sortByTime);
		generatedMusic = true;
	}

	// called only once per different event (Used for precaching)
	function eventPushed(event:EventNote) {
		eventPushedUnique(event);
		if(eventsPushed.contains(event.event)) {
			return;
		}

		stagesFunc(function(stage:BaseStage) stage.eventPushed(event));
		eventsPushed.push(event.event);
	}

	// called by every event with the same name
	function eventPushedUnique(event:EventNote) {
		switch(event.event) {
			case "Change Character":
				var charType:Int = 0;
				switch(event.value1.toLowerCase()) {
					case 'gf' | 'girlfriend' | '1':
						charType = 2;
					case 'dad' | 'opponent' | '0':
						charType = 1;
					default:
						var val1:Int = Std.parseInt(event.value1);
						if(Math.isNaN(val1)) val1 = 0;
						charType = val1;
				}

				var newCharacter:String = event.value2;
				addCharacterToList(newCharacter, charType);

			case 'Play Sound':
				Paths.sound(event.value1); //Precache sound
			case "Camera Event":
				if (event.value1.toLowerCase().trim() == "starthidden" || event.value1.toLowerCase().trim() == "start hidden")
				{
					camHUD.alpha = 0.001;
					camBars.fade(FlxColor.BLACK, 0.001);
				}
		}
		stagesFunc(function(stage:BaseStage) stage.eventPushedUnique(event));
	}

	function eventEarlyTrigger(event:EventNote):Float {
		var returnedValue:Null<Float> = callOnScripts('eventEarlyTrigger', [event.event, event.value1, event.value2, event.strumTime], true, [], [0]);
		if(returnedValue != null && returnedValue != 0 && returnedValue != LuaUtils.Function_Continue) {
			return returnedValue;
		}

		switch(event.event) {
			case 'Kill Henchmen': //Better timing so that the kill sound matches the beat intended
				return 280; //Plays 280ms before the actual position
		}
		return 0;
	}

	public static function sortByTime(Obj1:Dynamic, Obj2:Dynamic):Int
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);

	function makeEvent(event:Array<Dynamic>, i:Int)
	{
		var subEvent:EventNote = {
			strumTime: event[0] + ClientPrefs.data.noteOffset,
			event: event[1][i][0],
			value1: event[1][i][1],
			value2: event[1][i][2]
		};
		eventNotes.push(subEvent);
		eventPushed(subEvent);
		callOnScripts('onEventPushed', [subEvent.event, subEvent.value1 != null ? subEvent.value1 : '', subEvent.value2 != null ? subEvent.value2 : '', subEvent.strumTime]);
	}

	public var skipArrowStartTween:Bool = false; //for lua
	private function generateStaticArrows(player:Int, ?texture:String = null, ?tween:Bool = true):Void
	{

		var strumLineX:Float = middlescroll ? STRUM_X_MIDDLESCROLL : STRUM_X;
		var strumLineY:Float = ClientPrefs.data.downScroll ? (FlxG.height - 150) : 50;
		for (i in 0...4)
		{
			// FlxG.log.add(i);
			var targetAlpha:Float = 1;
			if (player < 1)
			{
				if(!ClientPrefs.data.opponentStrums) targetAlpha = 0;
				else if(middlescroll) targetAlpha = 0.35;
			}

			var babyArrow:StrumNote = new StrumNote(strumLineX, strumLineY, i, player);
			if (texture != null)
				babyArrow.texture = texture;
			babyArrow.downScroll = ClientPrefs.data.downScroll;
			if (!isStoryMode && tween)
			{
				//babyArrow.y -= 10;
				babyArrow.alpha = 0;
				FlxTween.tween(babyArrow, {/*y: babyArrow.y + 10,*/ alpha: targetAlpha}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}
			else
				babyArrow.alpha = targetAlpha;

			if (player == 1)
				playerStrums.add(babyArrow);
			else
			{
				if(middlescroll)
				{
					babyArrow.x += 310;
					if(i > 1) { //Up and Right
						babyArrow.x += FlxG.width / 2 + 25;
					}
				}
				opponentStrums.add(babyArrow);
			}

			strumLineNotes.add(babyArrow);
			babyArrow.postAddedToGroup();
		}
	}

	override function openSubState(SubState:FlxSubState)
	{
		stagesFunc(function(stage:BaseStage) stage.openSubState(SubState));
		if (paused)
		{
			if (inst != null)
			{
				inst.pause();
				vocals.pause();
				opponentVocals.pause();
			}

			if (startTimer != null && !startTimer.finished)
				startTimer.active = false;
			if (finishTimer != null && !finishTimer.finished)
				finishTimer.active = false;
			if (songSpeedTween != null)
				songSpeedTween.active = false;

			var chars:Array<Character> = [boyfriend, gf, dad];
			for (char in chars) {
				if(char != null && char.colorTween != null) {
					char.colorTween.active = false;
				}
			}

			for (barTwns in shittyTwns) {
				if(barTwns != null) {
					barTwns.active = false;
				}
			}

			for (subtitleTwns in subtitleTwnHandler) {
				if(subtitleTwns != null) {
					subtitleTwns.active = false;
				}
			}

			for (lyricIconTwns in iconHandler) {
				if(lyricIconTwns != null) {
					lyricIconTwns.active = false;
				}
			}

			for (tween in modchartTweens) {
				tween.active = false;
			}
			for (timer in modchartTimers) {
				timer.active = false;
			}
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		super.closeSubState();
		
		stagesFunc(function(stage:BaseStage) stage.closeSubState());
		if (paused)
		{
			if (FlxG.sound.music != null && !startingSong)
			{
				resyncVocals();
			}

			if (startTimer != null && !startTimer.finished)
				startTimer.active = true;
			if (finishTimer != null && !finishTimer.finished)
				finishTimer.active = true;
			if (songSpeedTween != null)
				songSpeedTween.active = true;

			var chars:Array<Character> = [boyfriend, gf, dad];
			for (char in chars) {
				if(char != null && char.colorTween != null) {
					char.colorTween.active = true;
				}
			}

			for (barTwns in shittyTwns) {
				if(barTwns != null) {
					barTwns.active = true;
				}
			}

			for (lyricIconTwns in iconHandler) {
				if(lyricIconTwns != null) {
					lyricIconTwns.active = true;
				}
			}

			for (subtitleTwns in subtitleTwnHandler) {
				if(subtitleTwns != null) {
					subtitleTwns.active = true;
				}
			}

			for (tween in modchartTweens) {
				tween.active = true;
			}
			for (timer in modchartTimers) {
				timer.active = true;
			}

			paused = false;
			callOnScripts('onResume');
			resetRPC(startTimer != null && startTimer.finished);
		}

		Lib.application.window.onClose.removeAll();
		Lib.application.window.onClose.add(function() {
			persistentUpdate = false;
			persistentDraw = true;
			instance.paused = true;

			if(inst != null) {
				inst.pause();
				vocals.pause();
				opponentVocals.pause();
			}

			openSubState(new gameObjects.ui.customEditorUI.Prompt('Are you sure you want to quit?\n\nYour data will still save if you do.', 0, function(){
				System.exit(0);
				DiscordClient.shutdown();
			}, function(){
				persistentUpdate = true;
				persistentDraw = true;
			},false, camOther));
			Lib.application.window.onClose.cancel();
		});
	}

	override public function onFocus():Void
	{
		if (healthThing > 0 && !paused) resetRPC(Conductor.songPosition > 0.0);

		stagesFunc(function(stage:BaseStage) stage.onFocus());

		super.onFocus();
	}

	override public function onFocusLost():Void
	{
		#if DISCORD_ALLOWED
		if (healthThing > 0 && !paused && autoUpdateRPC)
			switch (SONG.song)
			{
				case "Joygrim" | "Neglection" | "Scrapped": DiscordClient.changePresence("PAUSED", "It's a secret...", "icon", "random", true, songLength - Conductor.songPosition - ClientPrefs.data.noteOffset);
				default: DiscordClient.changePresence("PAUSED", "Unfocused...", CoolUtil.spaceToDash(discordIcon), "random", true, songLength - Conductor.songPosition - ClientPrefs.data.noteOffset);
			}
		#end

		stagesFunc(function(stage:BaseStage) stage.onFocusLost());

		super.onFocusLost();
	}

	// Updating Discord Rich Presence.
	public var autoUpdateRPC:Bool = true; //performance setting for custom RPC things
	function resetRPC(?showTime:Bool = false)
	{
		if (discordIcon == null)
		{
			discordIcon = SONG.song.toLowerCase().trim();

			if (FreeplayState.freeplayMenuList == 3)
				discordIcon = SONG.song == "Alone" ? "volume1" : "volume2";
			
			if (FreeplayState.freeplayMenuList == 2)
				discordIcon = "volume1";
		}

		if (discordTxt[0] == null)
			discordTxt[0] = detailsText;

		if (discordTxt[1] == null)
			discordTxt[1] = scoreTxt.text;

		#if DISCORD_ALLOWED
		if(!autoUpdateRPC) return;

		if (showTime)
			switch (SONG.song)
			{
				case "Joygrim" | "Neglection" | "Scrapped": DiscordClient.changePresence("Playing a song", "It's a secret...", "icon", "random", true, songLength - Conductor.songPosition - ClientPrefs.data.noteOffset);
				default: DiscordClient.changePresence(discordTxt[0], discordTxt[1], CoolUtil.spaceToDash(discordIcon), "random", true, songLength - Conductor.songPosition - ClientPrefs.data.noteOffset);
			}
		else
			switch (SONG.song)
			{
				case "Joygrim" | "Neglection" | "Scrapped": DiscordClient.changePresence("Playing a song", "It's a secret...", "icon", "random");
				default: DiscordClient.changePresence(discordTxt[0], discordTxt[1], CoolUtil.spaceToDash(discordIcon), "random");
			}
		#end
	}

	function resyncVocals():Void
	{
		if(finishTimer != null) return;

		vocals.pause();
		opponentVocals.pause();

		FlxG.sound.music.play();
		#if FLX_PITCH FlxG.sound.music.pitch = playbackRate; #end
		Conductor.songPosition = FlxG.sound.music.time;
		if (Conductor.songPosition <= vocals.length)
		{
			vocals.time = Conductor.songPosition;
			#if FLX_PITCH vocals.pitch = playbackRate; #end
		}

		if (Conductor.songPosition <= opponentVocals.length)
		{
			opponentVocals.time = Conductor.songPosition;
			#if FLX_PITCH opponentVocals.pitch = playbackRate; #end
		}
		vocals.play();
		opponentVocals.play();
	}

	public var paused:Bool = false;
	public var canReset:Bool = true;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;
	var freezeCamera:Bool = false;

	function updateHealthBar():Void
	{
		healthLerp = FlxMath.lerp(healthLerp, healthThing, .2 / (ClientPrefs.data.framerate / 60));
	}

	var cameraOnDad = false;

	override public function update(elapsed:Float)
	{
		callOnScripts('onUpdate', [elapsed]);

		flashSprite.alpha = FlxMath.lerp(0, flashSprite.alpha, Math.exp(-elapsed * flashSpeed));

		if (boyfriend.curCharacter == "everett-ghost")
		{
			iconP1.blend = ADD;
			boyfriend.blend = ADD;
		}
		else
		{
			iconP1.blend = NORMAL;
			boyfriend.blend = NORMAL;
		}
		
		// shitty system for the camera to stay updated
		var wn_r:Float = 70;
		var rotRateWn = curStep / 9.5;
		var wn_toy = 450 + -Math.sin(rotRateWn * 2) * wn_r * 0.45;
		var bfg_toy = 1050 + Math.sin(rotRateWn * 2) * wn_r * 0.45;

		if (boyfriend.curCharacter == "everett-ghost")
		{
			boyfriend.y += (bfg_toy - boyfriend.y) / 12;
			iconP1.y += (((healthBar.y - 85) + Math.sin(rotRateWn * 2) * 20 * 0.45) - iconP1.y) / 12;
			if (camGame.visible) moveCamera(SONG.notes[curSection].mustHitSection); // so it moves properly !!
		}

		if (dad.curCharacter == "white-noise-new")
		{
			dad.y += (wn_toy - dad.y) / 12;
			iconP2.y += (((healthBar.y - 85) + -Math.sin(rotRateWn * 2) * 20 * 0.45) - iconP2.y) / 12;
			if (camGame.visible) moveCamera(!SONG.notes[curSection].mustHitSection); // so it moves properly !!
		}
		else if (dad.curCharacter == "glitched-mickey-new-pixel" || dad.curCharacter == "malsquare-withFace")
		{
			if(camGame.visible) moveCamera(!SONG.notes[curSection].mustHitSection); // so it moves properly !!
		}
		
		if(!inCutscene) {
			var lerpVal:Float = CoolUtil.boundTo(elapsed * 2.4 * cameraSpeed * playbackRate, 0, 1);
			camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));
			if(!startingSong && !endingSong && boyfriend.animation.curAnim != null && boyfriend.animation.curAnim.name.startsWith('idle')) {
				boyfriendIdleTime += elapsed;
				if(boyfriendIdleTime >= 0.15) { // Kind of a mercy thing for making the achievement easier to get as it's apparently frustrating to some playerss
					boyfriendIdled = true;
				}
			} else {
				boyfriendIdleTime = 0;
			}
		}

		updateHealthBar();

		super.update(elapsed);

		if (boyfriend.curCharacter == "Mickey-Bedroom")
			boyfriend.cameras = [camVideo];
		else
			boyfriend.cameras = [camGame];

		if (cpuControlled)
		{
			scoreTxt.visible = false;
		}

		//Shitty thing so that the camera doesn't bug in some instances.
		if (generatedMusic && !endingSong && !isCameraOnForcedPos)
		{
			moveCameraSection();
		}

		setOnScripts('curDecStep', curDecStep);
		setOnScripts('curDecBeat', curDecBeat);

		if (controls.PAUSE && startedCountdown && canPause)
		{
			var ret:Dynamic = callOnScripts('onPause', null, true);
			if(ret != LuaUtils.Function_Stop) {
				openPauseMenu();
			}
		}

		if (controls.justPressed('debug_1') && !endingSong && !inCutscene)
		{
			openChartEditor();
		}

		if (controls.justPressed('debug_2') && !endingSong && !inCutscene)
		{			
			openCharacterEditor();
		}

		if (controls.justPressed('debug_3') && !endingSong && !inCutscene)
		{
			openModchartEditor(); 
		}

		var mult:Float = FlxMath.lerp(1, iconP1.scale.x, CoolUtil.boundTo(1 - (elapsed * 9 * playbackRate), 0, 1));
		iconP1.scale.set(mult, mult);
		iconP1.updateHitbox();

		var fuck:Float = SONG.song == "Cycled Sins" ? 0.85 : 1;
		var mult:Float = FlxMath.lerp(fuck, iconP2.scale.x, CoolUtil.boundTo(1 - (elapsed * 9 * playbackRate), 0, 1));
		iconP2.scale.set(mult, mult);
		iconP2.updateHitbox();

		if (healthThing > 2)
			healthThing = 2;

		if (iconP1.frames.frames.length >= 3 && healthBar.percent > 80)
		{
			if (SONG.song == "Isolated") 
				AbandonedStreet.demonBFIcon.animation.curAnim.curFrame = 2;
			iconP1.animation.curAnim.curFrame = 2;
		}
		else if (iconP1.frames.frames.length >= 2 && healthBar.percent < 20)
		{
			if (SONG.song == "Isolated") 
				AbandonedStreet.demonBFIcon.animation.curAnim.curFrame = 1;
			iconP1.animation.curAnim.curFrame = 1;
		}
		else
		{
			if (SONG.song == "Isolated") 
				AbandonedStreet.demonBFIcon.animation.curAnim.curFrame = 1;
			iconP1.animation.curAnim.curFrame = 0;
		}
		
		if (iconP2.frames.frames.length >= 2 && healthBar.percent > 80)
		{
			if (SONG.song == "Isolated")
			{
				AbandonedStreet.lunacyIcon.animation.curAnim.curFrame = 1;
				AbandonedStreet.delusionalIcon.animation.curAnim.curFrame = 1;
			}
			iconP2.animation.curAnim.curFrame = 1;
		}
		else if (iconP2.frames.frames.length >= 3 && healthBar.percent < 20)
		{
			if (SONG.song == "Isolated")
			{
				AbandonedStreet.lunacyIcon.animation.curAnim.curFrame = 2;
				AbandonedStreet.delusionalIcon.animation.curAnim.curFrame = 2;
			}
			iconP2.animation.curAnim.curFrame = 2;
		}
		else
		{
			if (SONG.song == "Isolated")
			{
				AbandonedStreet.lunacyIcon.animation.curAnim.curFrame = 0;
				AbandonedStreet.delusionalIcon.animation.curAnim.curFrame = 0;
			}
			iconP2.animation.curAnim.curFrame = 0;
		}
		
		var iconOffset:Int = 26;

		if (curStage == "waltRoom")
		{
			iconP1.y = healthBar.y + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) + (150 * iconP1.scale.y - 150) / 2 - iconOffset * 11.85;
			iconP2.y = healthBar.y + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (150 * iconP2.scale.y) / 2 - iconOffset * 13.85;
		}
		else
		{
			iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) + (150 * iconP1.scale.x - 150) / 2 - iconOffset;
			iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (150 * iconP2.scale.x) / 2 - iconOffset * 2;
			if (SONG.song == "Devilish Deal")
			{
				DDStage.minnieIcon.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(-healthBar.percent, 0, 100, 100, 0) * 0.01)) - (150 * iconP2.scale.x) / 2 - iconOffset * 25;
				DDStage.satanIcon.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(-healthBar.percent, 0, 100, 100, 0) * 0.01)) + (150 * iconP1.scale.x - 150) / 2 - iconOffset * 24;
				DDStage.satanIconPulse.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(-healthBar.percent, 0, 100, 100, 0) * 0.01)) + (150 * iconP1.scale.x - 150) / 2 - iconOffset * 24;
			}
		}

		if (startedCountdown && !paused)
			Conductor.songPosition += FlxG.elapsed * 1000 * playbackRate;

		if (startingSong)
		{
			if (startedCountdown && Conductor.songPosition >= 0)
				startSong();
			else if(!startedCountdown)
				Conductor.songPosition = -Conductor.crochet * 5;
		}
		else if (!paused && updateTime)
		{
			var curTime:Float = Math.max(0, Conductor.songPosition - ClientPrefs.data.noteOffset);
			songPercent = (curTime / songLength);

			var songCalc:Float = (songLength - curTime);
			if(ClientPrefs.data.timeBarType == 'Time Elapsed') songCalc = curTime;

			var secondsTotal:Int = Math.floor(songCalc / 1000);
			if(secondsTotal < 0) secondsTotal = 0;

			if(ClientPrefs.data.timeBarType != 'Song Name')
				timeTxt.text = FlxStringUtil.formatTime(secondsTotal, false);

			if (curStage == "menuSongs")
				songTxt.text = SONG.song + " - " + FlxStringUtil.formatTime(secondsTotal, false);
		}

		if (camZooming)
		{
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, Math.exp(-elapsed * 3.125 * camZoomingDecay * playbackRate));
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, Math.exp(-elapsed * 3.125 * camZoomingDecay * playbackRate));
		}

		FlxG.watch.addQuick("secShit", curSection);
		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);

		// RESET = Quick Game Over Screen
		if (!ClientPrefs.data.noReset && controls.RESET && canReset && !inCutscene && startedCountdown && !endingSong)
		{
			healthThing = 0;
			trace("RESET = True");
		}
		doDeathCheck();

		if (unspawnNotes[0] != null)
		{
			var time:Float = spawnTime * playbackRate;
			if(songSpeed < 1) time /= songSpeed;
			if(unspawnNotes[0].multSpeed < 1) time /= unspawnNotes[0].multSpeed;

			while (unspawnNotes.length > 0 && unspawnNotes[0].strumTime - Conductor.songPosition < time)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.insert(0, dunceNote);
				dunceNote.spawned = true;

				callOnLuas('onSpawnNote', [notes.members.indexOf(dunceNote), dunceNote.noteData, dunceNote.noteType, dunceNote.isSustainNote, dunceNote.strumTime]);
				callOnHScript('onSpawnNote', [dunceNote]);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		if (generatedMusic)
		{
			if(!inCutscene)
			{
				if(!cpuControlled)
					keysCheck();
				else
					playerDance();

				if(notes.length > 0)
				{
					if(startedCountdown)
					{
						var fakeCrochet:Float = (60 / SONG.bpm) * 1000;
						notes.forEachAlive(function(daNote:Note)
						{
							var strumGroup:FlxTypedGroup<StrumNote> = playerStrums;
							if(!daNote.mustPress) strumGroup = opponentStrums;

							var strumX:Float = strumGroup.members[daNote.noteData].x;
							var strumY:Float = strumGroup.members[daNote.noteData].y;
							var strumAngle:Float = strumGroup.members[daNote.noteData].angle;
							var strumDirection:Float = strumGroup.members[daNote.noteData].direction;
							var strumAlpha:Float = strumGroup.members[daNote.noteData].alpha;
							var strumScroll:Bool = strumGroup.members[daNote.noteData].downScroll;

							strumX += daNote.offsetX;
							strumY += daNote.offsetY;
							strumAngle += daNote.offsetAngle;
							strumAlpha *= daNote.multAlpha;

							if (strumScroll) //Downscroll
							{
								daNote.y = (strumY + 0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeed);
								daNote.distance = (0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeed);
							}
							else //Upscroll
							{
								daNote.y = (strumY - 0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeed);
								daNote.distance = (-0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeed);
							}

							var angleDir = strumDirection * Math.PI / 180;
							if (daNote.copyAngle){
								daNote.angle = strumAngle;
								daNote.angle += strumDirection - 90;
								if(Math.abs(strumDirection) % 90 == 0 ) daNote.angle -= strumDirection - 90;
							}
							if(daNote.isSustainNote){
								daNote.angle = strumDirection + 90;
								if(daNote.angle == 180 && strumScroll == true){
									daNote.angle = 0;
								}
							}

							if(daNote.copyAlpha)
								daNote.alpha = strumAlpha;

							if(daNote.copyX)
								daNote.x = strumX + Math.cos(angleDir) * daNote.distance;

							if(daNote.copyY)
							{
								daNote.y = strumY + Math.sin(angleDir) * daNote.distance;

								//Jesus fuck this took me so much mother fucking time AAAAAAAAAA
								if(strumScroll && daNote.isSustainNote)
								{
									if (daNote.animation.curAnim.name.endsWith('end')) {
										daNote.y += 10.5 * (fakeCrochet / 400) * 1.5 * songSpeed + (46 * (songSpeed - 1));
										daNote.y -= 46 * (1 - (fakeCrochet / 600)) * songSpeed;
										if(PlayState.isPixelStage) {
											daNote.y += 8 + (6 - daNote.originalHeight) * PlayState.daPixelZoom;
										} else {
											daNote.y -= 19;
										}
									}
									daNote.y += (Note.swagWidth / 2) - (60.5 * (songSpeed - 1));
									daNote.y += 27.5 * ((SONG.bpm / 100) - 1) * (songSpeed - 1);
								}
							}

							if (!daNote.mustPress && daNote.wasGoodHit && !daNote.hitByOpponent && !daNote.ignoreNote)
							{
								opponentNoteHit(daNote);
							}

							if (daNote.noteType == "Mal Must Miss These" || daNote.noteType == "Mal Must Miss These (Error Edition)")
							{
								opponentVocals.volume = 0;
								camZooming = true;
							}

							if(!daNote.blockHit && daNote.mustPress && cpuControlled && daNote.canBeHit) {
								if(daNote.isSustainNote) {
									if(daNote.canBeHit) {
										goodNoteHit(daNote);
									}
								} else if(daNote.strumTime <= Conductor.songPosition || daNote.isSustainNote) {
									goodNoteHit(daNote);
								}
							}

							var center:Float = strumY + Note.swagWidth / 2;
							if(strumGroup.members[daNote.noteData].sustainReduce && daNote.isSustainNote && (daNote.mustPress || !daNote.ignoreNote) &&
								(!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
							{
								if (strumScroll)
								{
									if(daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= center)
									{
										var swagRect = new FlxRect(0, 0, daNote.frameWidth, daNote.frameHeight);
										swagRect.height = (center - daNote.y) / daNote.scale.y;
										swagRect.y = daNote.frameHeight - swagRect.height;

										daNote.clipRect = swagRect;
									}
								}
								else
								{
									if (daNote.y + daNote.offset.y * daNote.scale.y <= center)
									{
										var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
										swagRect.y = (center - daNote.y) / daNote.scale.y;
										swagRect.height -= swagRect.y;

										daNote.clipRect = swagRect;
									}
								}
							}

							// Kill extremely late notes and cause misses
							if (Conductor.songPosition > noteKillOffset + daNote.strumTime)
							{
								if (daNote.mustPress && !cpuControlled &&!daNote.ignoreNote && !endingSong && (daNote.tooLate || !daNote.wasGoodHit)) {
									noteMiss(daNote);
								}

								daNote.active = false;
								daNote.visible = false;

								daNote.kill();
								notes.remove(daNote, true);
								daNote.destroy();
							}
						});
					}
					else
					{
						notes.forEachAlive(function(daNote:Note)
						{
							daNote.canBeHit = false;
							daNote.wasGoodHit = false;
						});
					}
				}
			}
			checkEventNote();
		}

		if (Main.debug)
		{
			if(!endingSong && !startingSong) 
			{
				if (FlxG.keys.justPressed.ONE) {
					KillNotes();
					FlxG.sound.music.onComplete();
				}
				if(FlxG.keys.justPressed.TWO) { //Go 10 seconds into the future :O
					setSongTime(Conductor.songPosition + 10000);
					clearNotesBefore(Conductor.songPosition);
				}
			}
		}

		// the COOLER cam pos thing or whatever
		// x, y, angle
		var camOffset = [0.0, 0.0, 0];

		var char = cameraOnDad ? dad : boyfriend;

		if (char.animation.curAnim != null && !isCameraOnForcedPos && curStage != "menuSongs") 
		{
			switch (char.animation.curAnim.name.substring(4))
			{
				case 'UP' | 'UP-alt' | 'UPmiss' | 'UP-loop' | 'endingAnim':
					camOffset[1] -= 40;

				case 'RIGHT' | 'RIGHT-alt' | 'RIGHTmiss' | 'RIGHT-loop':
					camOffset[0] += 40;
					if (FreeplayState.freeplayMenuList != 2) camOffset[2] += 1.3;

				case 'LEFT' | 'LEFT-alt' | 'LEFTmiss' | 'LEFT-loop':
					camOffset[0] -= 40;
					if (FreeplayState.freeplayMenuList != 2) camOffset[2] -= 1.3;

				case 'DOWN' | 'DOWN-alt' | 'DOWNmiss' | 'DOWN-loop':
					camOffset[1] += 40;
			}
		}

		if(!inCutscene) {
			var lerpVal:Float = CoolUtil.boundTo(elapsed * 2.4 * cameraSpeed, 0, 1);
			camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x + camOffset[0], lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y + camOffset[1], lerpVal));
			camGame.angle = FlxMath.lerp(camGame.angle, 0 + camOffset[2], CoolUtil.boundTo(CoolUtil.boundTo(elapsed * 2.4 / 0.4, 0, 1) * cameraSpeed , 0, 1));
		}

		if (startedCountdown && SONG.song == "Birthday") {
			for (i in 0...8) {
				strumLineNotes.members[i].scale.set(FlxMath.lerp(strumLineNotes.members[i].scale.x, forceAutismIntoThisNoteLikeAnAverageAmericanDoctor, (autisticDesires * playbackRate) * elapsed), FlxMath.lerp(strumLineNotes.members[i].scale.y,  forceAutismIntoThisNoteLikeAnAverageAmericanDoctor, (autisticDesires * playbackRate) * elapsed));
			}
		}

		backend.CamUtils.updateCamera(camGame, elapsed);
		backend.CamUtils.updateCamera(camHUD, elapsed);
		backend.CamUtils.updateCamera(camOther, elapsed);
		backend.CamUtils.updateCamera(malThing, elapsed);


		setOnScripts('cameraX', camFollowPos.x);
		setOnScripts('cameraY', camFollowPos.y);
		setOnScripts('botPlay', cpuControlled);
		callOnScripts('onUpdatePost', [elapsed]);
	}

	/**
	* # Stage Background Flash Function
	*
	* Basically the BG Flash used in Isolated but it's now hardcoded and can be used globally now.
	* The reasoning for this is cause I'm NOT gonna go and duplicate the flash assets from the episode 1
	* stage onto other stages I want to use it at, too much work!
	*
	* @param flashType - Defines how you want the BG flash handler to behave
	* @param settings - A structure with the flashing options.
	*
	* @author DEMOLITIONDON96 ft. Jason
	*/
	public function backgroundControls(flashType:FlashType, settings:FlashingSettings)
	{
		// null checkes
		if (settings.colors == null) settings.colors = [255, 255, 255];
		if (settings.timer == null) settings.timer = 3;
		if (settings.ease == null) settings.ease = FlxEase.linear;
		if (settings.alpha == null) settings.alpha = .5;

		// due to the fact that some silly 19 year old guy called demo overuses the shit
		// out of the zooms this has to exist in cases of emergency   - jason the silly !!
		// stageBGFlash.setPosition(-FlxG.width * FlxG.camera.zoom, -FlxG.height * FlxG.camera.zoom);

		if (stageBGFlash != null)
		{
			switch (flashType)
			{
				case BG_FLASH:
					if (ClientPrefs.data.flashing)
					{
						if (settings.alpha > 1 || settings.alpha < 0) // prevents a crash from making a dumb mistake
							stageBGFlash.alpha = 0.5;
						else
							stageBGFlash.alpha = settings.alpha;

						if (settings.timer <= 0) // another check to prevent a crash
							settings.timer = 1;

						if (settings.colors[0] == 0 && settings.colors[1] == 0 && settings.colors[2] == 0) // blend check cause it makes it look cool
							stageBGFlash.blend = NORMAL;
						else
							stageBGFlash.blend = ADD;

						stageBGFlash.color = FlxColor.fromRGB(settings.colors[0], settings.colors[1], settings.colors[2], 255);

						if (BGFlashTween != null) // makes it so it won't look wonky, visually
							BGFlashTween.cancel();

						BGFlashTween = FlxTween.tween(stageBGFlash, {alpha: 0}, settings.timer, {
							ease: settings.ease,
							onComplete: function(twn:FlxTween)
							{
								BGFlashTween = null;
							}
						});
					}

				case BG_DARK:
					if (stageBGDark != null)
					{
						if (BGDarkTween != null)
							BGDarkTween.cancel();

						if (stageBGDark.blend != NORMAL)
							stageBGDark.blend = NORMAL;

						if (settings.timer <= 0)
							settings.timer = 1;

						stageBGDark.color = FlxColor.BLACK; // hardcoded to be black

						BGDarkTween = FlxTween.tween(stageBGDark, {alpha: settings.alpha}, settings.timer, {
							ease: settings.ease,
							onComplete: function(twn:FlxTween)
							{
								BGDarkTween = null;
							}
						});
					}
						
				case SET_COLOR:
					if (stageBGColor != null)
					{
						stageBGColor.color = FlxColor.fromRGB(settings.colors[0], settings.colors[1], settings.colors[2], 255);

						stageBGColor.alpha = settings.alpha;
					}
				
				case TWEEN_COLOR:
					if (stageBGColor != null)
					{
						if (BGTweenColor != null)
							BGTweenColor.cancel();

						if (stageBGColor.blend != NORMAL)
							stageBGColor.blend = NORMAL;

						if (settings.timer <= 0)
							settings.timer = 1;

						stageBGColor.color = FlxColor.fromRGB(settings.colors[0], settings.colors[1], settings.colors[2], 255);

						BGTweenColor = FlxTween.tween(stageBGColor, {alpha: settings.alpha}, settings.timer, {
							ease: settings.ease,
							onComplete: function(twn:FlxTween)
							{
								BGTweenColor = null;
							}
						});
					}

				//This is needed only because mercy exists
				case CAM_FLASH_FANCY:
					if (blendFlash != null)
					{
						if (settings.alpha > 1 || settings.alpha < 0) // prevents a crash from making a dumb mistake
							blendFlash.alpha = 0.5;
						else
							blendFlash.alpha = settings.alpha;

						if (settings.timer <= 0) // another check to prevent a crash
							settings.timer = 1;

						if (settings.colors[0] == 0 && settings.colors[1] == 0 && settings.colors[2] == 0) // turn it to white, cause I can
							blendFlash.blend = NORMAL;
						else
							blendFlash.blend = ADD;

						if (flashTween != null)
							flashTween.cancel();

						blendFlash.color = FlxColor.fromRGB(settings.colors[0], settings.colors[1], settings.colors[2], 255);

						flashTween = FlxTween.tween(blendFlash, {alpha: 0}, settings.timer, {
							ease: settings.ease,
							onComplete: function(twn:FlxTween)
							{
								flashTween = null;
							}
						});
					}
			}
		}
	}

	public static function returnAlignType(align:String = '')
	{
		switch (align.toLowerCase())
		{
			case 'center':
				return FlxTextAlign.CENTER;
			case 'justify':
				return FlxTextAlign.JUSTIFY;
			case 'left':
				return FlxTextAlign.LEFT;
			case 'right':
				return FlxTextAlign.RIGHT;
		}
		return FlxTextAlign.CENTER;
	}

	public static function returnTweenEase(ease:String = '')
	{
		switch (ease.toLowerCase())
		{
			case 'linear':
				return FlxEase.linear;
			case 'backin':
				return FlxEase.backIn;
			case 'backinout':
				return FlxEase.backInOut;
			case 'backout':
				return FlxEase.backOut;
			case 'bouncein':
				return FlxEase.bounceIn;
			case 'bounceinout':
				return FlxEase.bounceInOut;
			case 'bounceout':
				return FlxEase.bounceOut;
			case 'circin':
				return FlxEase.circIn;
			case 'circinout':
				return FlxEase.circInOut;
			case 'circout':
				return FlxEase.circOut;
			case 'cubein':
				return FlxEase.cubeIn;
			case 'cubeinout':
				return FlxEase.cubeInOut;
			case 'cubeout':
				return FlxEase.cubeOut;
			case 'elasticin':
				return FlxEase.elasticIn;
			case 'elasticinout':
				return FlxEase.elasticInOut;
			case 'elasticout':
				return FlxEase.elasticOut;
			case 'expoin':
				return FlxEase.expoIn;
			case 'expoinout':
				return FlxEase.expoInOut;
			case 'expoout':
				return FlxEase.expoOut;
			case 'quadin':
				return FlxEase.quadIn;
			case 'quadinout':
				return FlxEase.quadInOut;
			case 'quadout':
				return FlxEase.quadOut;
			case 'quartin':
				return FlxEase.quartIn;
			case 'quartinout':
				return FlxEase.quartInOut;
			case 'quartout':
				return FlxEase.quartOut;
			case 'quintin':
				return FlxEase.quintIn;
			case 'quintinout':
				return FlxEase.quintInOut;
			case 'quintout':
				return FlxEase.quintOut;
			case 'sinein':
				return FlxEase.sineIn;
			case 'sineinout':
				return FlxEase.sineInOut;
			case 'sineout':
				return FlxEase.sineOut;
			case 'smoothstepin':
				return FlxEase.smoothStepIn;
			case 'smoothstepinout':
				return FlxEase.smoothStepInOut;
			case 'smoothstepout':
				return FlxEase.smoothStepInOut;
			case 'smootherstepin':
				return FlxEase.smootherStepIn;
			case 'smootherstepinout':
				return FlxEase.smootherStepInOut;
			case 'smootherstepout':
				return FlxEase.smootherStepOut;
		}
		return FlxEase.linear;
	}

	var shittyTwns:Array<FlxTween> = [];
	public function cinematicBarControls(controlType:CinematicControls, settings:CinematicSettings)
	{
		// null checkes
		if (settings.colors == null) settings.colors = [0, 0, 0];
		if (settings.timer == null) settings.timer = 3;
		if (settings.ease == null) settings.ease = "linear";
		if (settings.valueInput == null) settings.valueInput = 50;

		switch (controlType)
		{		
			case MOVE:
				if (cinematicBars["top"] == null)
				{
					cinematicBars["top"] = new FlxSprite(0, 0).makeGraphic(FlxG.width * 3, FlxG.height, FlxColor.WHITE);
					cinematicBars["top"].screenCenter(X);
					cinematicBars["top"].cameras = [camBars];
					cinematicBars["top"].y = 0 - cinematicBars["top"].height; // offscreen
					add(cinematicBars["top"]);
					cinematicBars["top"].color = FlxColor.BLACK;
				}
		
				if (cinematicBars["bottom"] == null)
				{
					cinematicBars["bottom"] = new FlxSprite(0, 0).makeGraphic(FlxG.width * 3, FlxG.height, FlxColor.WHITE);
					cinematicBars["bottom"].screenCenter(X);
					cinematicBars["bottom"].cameras = [camBars];
					cinematicBars["bottom"].y = FlxG.height; // offscreen
					add(cinematicBars["bottom"]);
					cinematicBars["bottom"].color = FlxColor.BLACK;
				}

				if (shittyTwns[0] != null)
					shittyTwns[0].cancel();
				if (shittyTwns[1] != null)
					shittyTwns[1].cancel();

				shittyTwns[0] = FlxTween.tween(cinematicBars["top"], {y: settings.valueInput - FlxG.height}, settings.timer, {ease: returnTweenEase(settings.ease.toLowerCase().trim()), onComplete: function(twn:FlxTween)
				{
					shittyTwns[0] = null;
				}});
				shittyTwns[1] = FlxTween.tween(cinematicBars["bottom"], {y: FlxG.height - settings.valueInput}, settings.timer, {ease: returnTweenEase(settings.ease.toLowerCase().trim()), onComplete: function(twn:FlxTween)
				{
					shittyTwns[1] = null;
				}});
						
			case BOP:
				if (cinematicBars["top"] != null && cinematicBars["bottom"] != null)
				{
					if (shittyTwns[2] != null)
						shittyTwns[2].cancel();
					if (shittyTwns[3] != null)
						shittyTwns[3].cancel();
		
					cinematicBars["top"].y -= settings.valueInput;
					cinematicBars["bottom"].y += settings.valueInput;
					shittyTwns[2] = FlxTween.tween(cinematicBars["top"], {y: cinematicBars["top"].y + settings.valueInput}, settings.timer, {ease: returnTweenEase(settings.ease.toLowerCase().trim()), onComplete: function(twn:FlxTween)
					{
						shittyTwns[2] = null;
					}});
					shittyTwns[3] = FlxTween.tween(cinematicBars["bottom"], {y: cinematicBars["bottom"].y - settings.valueInput}, settings.timer, {ease: returnTweenEase(settings.ease.toLowerCase().trim()), onComplete: function(twn:FlxTween)
					{
						shittyTwns[3] = null;
					}});
				}

			case FLASH:
				if (cinematicBars["top"] != null && cinematicBars["bottom"] != null)
				{
					if (shittyTwns[4] != null)
						shittyTwns[4].cancel();
					if (shittyTwns[5] != null)
						shittyTwns[5].cancel();

					var lastColor:FlxColor = cinematicBars["top"].color;
					cinematicBars["top"].color = FlxColor.fromRGB(settings.colors[0], settings.colors[1], settings.colors[2]);
					cinematicBars["bottom"].color = FlxColor.fromRGB(settings.colors[0], settings.colors[1], settings.colors[2]);

					shittyTwns[4] = FlxTween.color(cinematicBars["top"], settings.timer, FlxColor.fromRGB(settings.colors[0], settings.colors[1], settings.colors[2]), lastColor, {ease: returnTweenEase(settings.ease.toLowerCase().trim()), onComplete: function(twn:FlxTween)
					{
						shittyTwns[4] = null;
					}});
					shittyTwns[5] = FlxTween.color(cinematicBars["bottom"], settings.timer, FlxColor.fromRGB(settings.colors[0], settings.colors[1], settings.colors[2]), lastColor, {ease: returnTweenEase(settings.ease.toLowerCase().trim()), onComplete: function(twn:FlxTween)
					{
						shittyTwns[5] = null;
					}});
				}

			case ANGLE:
				if (cinematicBars["top"] != null && cinematicBars["bottom"] != null)
				{
					if (shittyTwns[6] != null)
						shittyTwns[6].cancel();

					shittyTwns[6] = FlxTween.tween(camBars, {angle: settings.valueInput}, settings.timer, {ease: returnTweenEase(settings.ease.toLowerCase().trim()), onComplete: function(twn:FlxTween)
					{
						shittyTwns[6] = null;
					}});
				}

			case COLOR:
				if (cinematicBars["top"] != null && cinematicBars["bottom"] != null)
				{
					if (shittyTwns[7] != null)
						shittyTwns[7].cancel();
					if (shittyTwns[8] != null)
						shittyTwns[8].cancel();

					shittyTwns[7] = FlxTween.color(cinematicBars["top"], settings.timer, cinematicBars["top"].color, FlxColor.fromRGB(settings.colors[0], settings.colors[1], settings.colors[2]), {ease: returnTweenEase(settings.ease.toLowerCase().trim()), onComplete: function(twn:FlxTween)
					{
						shittyTwns[7] = null;
					}});
					shittyTwns[8] = FlxTween.color(cinematicBars["bottom"], settings.timer, cinematicBars["bottom"].color, FlxColor.fromRGB(settings.colors[0], settings.colors[1], settings.colors[2]), {ease: returnTweenEase(settings.ease.toLowerCase().trim()), onComplete: function(twn:FlxTween)
					{
						shittyTwns[8] = null;
					}});
				}
					
			case ALPHA:
				if (cinematicBars["top"] != null && cinematicBars["bottom"] != null)
				{
					if (settings.valueInput > 1 || settings.valueInput < 0)
						settings.valueInput = 1;

					if (shittyTwns[9] != null)
						shittyTwns[9].cancel();

					shittyTwns[9] = FlxTween.tween(camBars, {alpha: settings.valueInput}, settings.timer, {ease: returnTweenEase(settings.ease.toLowerCase().trim()), onComplete: function(twn:FlxTween)
					{
						shittyTwns[9] = null;
					}});
				}
		}
	}

	function openPauseMenu()
	{
		persistentUpdate = false;
		persistentDraw = true;
		paused = true;

		if(FlxG.sound.music != null) {
			FlxG.sound.music.pause();
			vocals.pause();
			opponentVocals.pause();
		}
		if(!cpuControlled)
		{
			for (note in playerStrums)
				if(note.animation.curAnim != null && note.animation.curAnim.name != 'static')
				{
					note.playAnim('static');
					note.resetAnim = 0;
				}
		}
		if (chartingMode || modchartingMode || FreeplayState.freeplayMenuList == 2)
			openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		else
			openSubState(FreeplayState.freeplayMenuList != 3 ? new FAVIPauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y) : new PauseManiaSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

		#if DISCORD_ALLOWED
		if(autoUpdateRPC) 
			switch (SONG.song)
			{
				case "Joygrim" | "Neglection" | "Scrapped": DiscordClient.changePresence("Playing a song", "It's a secret...", "icon", "random");
				default: DiscordClient.changePresence('Paused - ' + discordTxt[0], discordTxt[1], CoolUtil.spaceToDash(discordIcon), "random");
			}
		#end
	}

	function openChartEditor()
	{
		FlxG.camera.followLerp = 0;
		persistentUpdate = false;
		paused = true;
		if(FlxG.sound.music != null)
			FlxG.sound.music.stop();
		chartingMode = true;

		#if DISCORD_ALLOWED
		DiscordClient.changePresence("Chart Editor", null, null, true);
		DiscordClient.resetClientID();
		#end

		MusicBeatState.switchState(new ChartingState());
		FlxG.mouse.load(Paths.image('favi/ui/Cursor').bitmap);
	}

	function openCharacterEditor()
	{
		FlxG.camera.followLerp = 0;
		persistentUpdate = false;
		paused = true;
		if(FlxG.sound.music != null)
			FlxG.sound.music.stop();
		#if DISCORD_ALLOWED DiscordClient.resetClientID(); #end

		MusicBeatState.switchState(new CharacterEditorState(SONG.player2));
		FlxG.mouse.load(Paths.image('favi/ui/Cursor').bitmap);
	}

	function openModchartEditor()
	{
		FlxG.camera.followLerp = 0;
		persistentUpdate = false;
		paused = true;
		if(FlxG.sound.music != null)
			FlxG.sound.music.stop();
		modchartingMode = true;
		#if DISCORD_ALLOWED DiscordClient.resetClientID(); #end


		MusicBeatState.switchState(new modcharting.ModchartEditorState());
		FlxG.mouse.load(Paths.image('favi/ui/Cursor').bitmap);
	}

	public var isDead:Bool = false; //Don't mess with this on Lua!!!
	function doDeathCheck(?skipHealthCheck:Bool = false) {
		if (((skipHealthCheck && instakillOnMiss) || healthThing <= 0) && !practiceMode && !isDead && SONG.song != "Devilish Deal")
		{
			var ret:Dynamic = callOnScripts('onGameOver', null, true);
			if(ret != LuaUtils.Function_Stop) {
				FlxG.animationTimeScale = 1;
				boyfriend.stunned = true;
				deathCounter++;

				if (SONG.song == "Malfunction")
					malfunctionTrollCounter++;

				// kills any stuff that may cause lag during the process
				for (cams in [camGame, camHUD])
					cams.setFilters([]); // kills the shaders if any exists

				for (highEndShit in [scratch, scratchButLessVisible, fancyBarOverlay])
					if (highEndShit != null)
					{
						remove(highEndShit);
						highEndShit.kill();
						highEndShit.destroy();
						highEndShit = null;
					}

				paused = true;
				Application.current.window.title = 'Funkin.avi - Game Over - Deaths : ${deathCounter}';

				Lib.application.window.onClose.removeAll(); // goes back to normal hopefully
				Lib.application.window.onClose.add(function() {
					DiscordClient.shutdown();
				});

				if (FreeplayState.freeplayMenuList != 3)
				{
					vocals.stop();
					opponentVocals.stop();
					FlxG.sound.music.stop();

					persistentUpdate = false;
					persistentDraw = false;
					FlxTimer.globalManager.clear();
					FlxTween.globalManager.clear();
					
					modchartTimers.clear();
					modchartTweens.clear();

					switch (SONG.gameOverStyle)
					{
						case "Episode 1":
							openSubState(new Episode1Death());
						case "Delusional":
							openSubState(new DelusionalDeath());
						case "Cross":
							openSubState(new EpicFailLmao());
						case "War":
							openSubState(new WarGameOver());
						case "Malfunction":
							if (((malfunctionTrollCounter >= 10 && malfunctionTrollCounter <= 19) && FlxG.random.bool(15)) || (malfunctionTrollCounter >= 20 && FlxG.random.bool(25)))
								openSubState(new MalsquareTrollScreen());
							else
								openSubState(new MalsquareDeath());
						case "Birthday":
							openSubState(new WompWompSadMan());
						case "Default":
							openSubState(new EverettBaseDeath());
						case 'Base Game':
							openSubState(new BaseGameOver());
					}
				}
				else
				{
					FlxTween.tween(this, {playbackRate: 0.001}, 7, {ease: FlxEase.expoOut});
					FlxTween.tween(FlxG.sound.music, {pitch: 0.001}, 7, {ease: FlxEase.expoOut, onComplete: function(twn:FlxTween)
					{
						persistentUpdate = false;
						persistentDraw = false;
						FlxTimer.globalManager.clear();
						FlxTween.globalManager.clear();
						
						modchartTimers.clear();
						modchartTweens.clear();
					}});

					openSubState(new ManiaLoseScreen());
				}

				#if DISCORD_ALLOWED
				// Game Over doesn't get his its variable because it's only used here
				if(autoUpdateRPC)
					switch (SONG.song)
					{
						case "Joygrim" | "Neglection" | "Scrapped": DiscordClient.changePresence("Game Over", 'Deaths: ${deathCounter}', "icon", "random");
						default: DiscordClient.changePresence("Game Over - " + discordTxt[0], 'Deaths: ${deathCounter}', CoolUtil.spaceToDash(discordIcon), "random");
					}
				#end
				isDead = true;
				return true;
			}
		}
		return false;
	}

	public function checkEventNote() {
		while(eventNotes.length > 0) {
			var leStrumTime:Float = eventNotes[0].strumTime;
			if(Conductor.songPosition < leStrumTime) {
				return;
			}

			var value1:String = '';
			if(eventNotes[0].value1 != null)
				value1 = eventNotes[0].value1;

			var value2:String = '';
			if(eventNotes[0].value2 != null)
				value2 = eventNotes[0].value2;

			triggerEvent(eventNotes[0].event, value1, value2, leStrumTime);
			eventNotes.shift();
		}
	}

	public function triggerEvent(eventName:String, value1:String, value2:String, strumTime:Float) {
		var flValue1:Null<Float> = Std.parseFloat(value1);
		var flValue2:Null<Float> = Std.parseFloat(value2);
		if(Math.isNaN(flValue1)) flValue1 = null;
		if(Math.isNaN(flValue2)) flValue2 = null;

		switch(eventName) {
			case 'Hey!':
				var value:Int = 2;
				switch(value1.toLowerCase().trim()) {
					case 'bf' | 'boyfriend' | '0':
						value = 0;
					case 'gf' | 'girlfriend' | '1':
						value = 1;
				}

				if(flValue2 == null || flValue2 <= 0) flValue2 = 0.6;

				if(value != 0) {
					if(dad.curCharacter.startsWith('gf')) { //Tutorial GF is actually Dad! The GF is an imposter!! ding ding ding ding ding ding ding, dindinding, end my suffering
						dad.playAnim('cheer', true);
						dad.specialAnim = true;
						dad.heyTimer = flValue2;
					} else if (gf != null) {
						gf.playAnim('cheer', true);
						gf.specialAnim = true;
						gf.heyTimer = flValue2;
					}
				}
				if(value != 1) {
					boyfriend.playAnim('hey', true);
					boyfriend.specialAnim = true;
					boyfriend.heyTimer = flValue2;
				}

			case 'Set GF Speed':
				if(flValue1 == null || flValue1 < 1) flValue1 = 1;
				gfSpeed = Math.round(flValue1);

			case 'Add Camera Zoom':
				if(ClientPrefs.data.camZooms && FlxG.camera.zoom < 1.35) {
					var camZoom:Float = Std.parseFloat(value1);
					var hudZoom:Float = Std.parseFloat(value2);
					if(Math.isNaN(camZoom)) camZoom = 0.015;
					if(Math.isNaN(hudZoom)) hudZoom = 0.03;

					FlxG.camera.zoom += camZoom;
					camHUD.zoom += hudZoom;
				}

			case 'Add Camera Zoom Chain':
				gameBopIntensity = flValue1;
				uiBopIntensity = flValue2;
			case 'Play Animation':
				//trace('Anim to play: ' + value1);
				var char:Character = dad;
				switch(value2.toLowerCase().trim()) {
					case 'bf' | 'boyfriend':
						char = boyfriend;
					case 'gf' | 'girlfriend':
						char = gf;
					default:
						if(flValue2 == null) flValue2 = 0;
						switch(Math.round(flValue2)) {
							case 1: char = boyfriend;
							case 2: char = gf;
						}
				}

				if (char != null)
				{
					char.playAnim(value1, true);
					char.specialAnim = true;
				}

			case 'Show Song Card':
			/*	var triggerInfo:Array<String> = value2.split(',');

				if (!songCard.isLegacy && ClientPrefs.data.songCards)
				{
					if (value1.toLowerCase().trim() == "true")
						songCard.playCardAnim(Std.parseFloat(triggerInfo[0]), Std.parseFloat(triggerInfo[1]), triggerInfo[2]);
					else
						songCard.removeCardAnim(Std.parseFloat(triggerInfo[0]), Std.parseFloat(triggerInfo[1]), triggerInfo[2]);
				}
*/
			case 'Alt Idle Animation':
				var char:Character = dad;
				switch(value1.toLowerCase().trim()) {
					case 'gf' | 'girlfriend':
						char = gf;
					case 'boyfriend' | 'bf':
						char = boyfriend;
					default:
						var val:Int = Std.parseInt(value1);
						if(Math.isNaN(val)) val = 0;

						switch(val) {
							case 1: char = boyfriend;
							case 2: char = gf;
						}
				}

				if (char != null)
				{
					char.idleSuffix = value2;
					char.recalculateDanceIdle();
				}

			case 'Change Strumline Style':
				var getStyle:Array<String> = value1.split(',');
				if (getStyle[0] == '' || getStyle[0] == null)
					return;

				var tweenBool:Bool = false;
				if (value2 == 'true')
					tweenBool = true;

				noteGroup.remove(playfieldRenderer);
				playfieldRenderer.destroy();
				noteGroup.remove(strumLineNotes);
				strumLineNotes = new FlxTypedGroup<StrumNote>();
				noteGroup.add(strumLineNotes);

				playerStrums = new FlxTypedGroup<StrumNote>();
				opponentStrums = new FlxTypedGroup<StrumNote>();

				var i:Int = unspawnNotes.length - 1;
				if (unspawnNotes[i].mustPress)
					unspawnNotes[i].texture = getStyle[1].trim();
				else
					unspawnNotes[i].texture = getStyle[0].trim();

				playfieldRenderer = new PlayfieldRenderer(strumLineNotes, notes, this);
				noteGroup.add(playfieldRenderer);
				noteGroup.add(grpNoteSplashes);

				generateStaticArrows(0, getStyle[0].trim(), tweenBool);
				generateStaticArrows(1, getStyle[1].trim(), tweenBool);
				NoteMovement.getDefaultStrumPos(this);

			case 'Change Character':
				var charType:Int = 0;
				switch(value1.toLowerCase().trim()) {
					case 'gf' | 'girlfriend':
						charType = 2;
					case 'dad' | 'opponent':
						charType = 1;
					default:
						charType = Std.parseInt(value1);
						if(Math.isNaN(charType)) charType = 0;
				}

				switch(charType) {
					case 0:
						if(boyfriend.curCharacter != value2) {
							if(!boyfriendMap.exists(value2)) {
								addCharacterToList(value2, charType);
							}

							var lastAlpha:Float = boyfriend.alpha;
							boyfriend.alpha = 0.00001;
							boyfriend = boyfriendMap.get(value2);
							boyfriend.alpha = lastAlpha;
							iconP1.changeIcon(boyfriend.healthIcon, false, false, true);
						}
						setOnScripts('boyfriendName', boyfriend.curCharacter);

					case 1:
						if(dad.curCharacter != value2) {
							if(!dadMap.exists(value2)) {
								addCharacterToList(value2, charType);
							}

							var wasGf:Bool = dad.curCharacter.startsWith('gf-') || dad.curCharacter == 'gf';
							var lastAlpha:Float = dad.alpha;
							dad.alpha = 0.00001;
							dad = dadMap.get(value2);
							if(!dad.curCharacter.startsWith('gf-') && dad.curCharacter != 'gf') {
								if(wasGf && gf != null) {
									gf.visible = true;
								}
							} else if(gf != null) {
								gf.visible = false;
							}
							dad.alpha = lastAlpha;
							iconP2.changeIcon(dad.healthIcon, false, false, true);
						}
						setOnScripts('dadName', dad.curCharacter);

					case 2:
						if(gf != null)
						{
							if(gf.curCharacter != value2)
							{
								if(!gfMap.exists(value2)) {
									addCharacterToList(value2, charType);
								}

								var lastAlpha:Float = gf.alpha;
								gf.alpha = 0.00001;
								gf = gfMap.get(value2);
								gf.alpha = lastAlpha;
							}
							setOnScripts('gfName', gf.curCharacter);
						}
				}
				reloadHealthBarColors();

			case 'Change Scroll Speed':
				if (songSpeedType != "constant")
				{
					if(flValue1 == null) flValue1 = 1;
					if(flValue2 == null) flValue2 = 0;

					var newValue:Float = SONG.speed * ClientPrefs.getGameplaySetting('scrollspeed') * flValue1;
					if(flValue2 <= 0)
						songSpeed = newValue;
					else
						songSpeedTween = FlxTween.tween(this, {songSpeed: newValue}, flValue2 / playbackRate, {ease: FlxEase.linear, onComplete:
							function (twn:FlxTween)
							{
								songSpeedTween = null;
							}
						});
				}

			case 'Set Property':
				try
				{
					var split:Array<String> = value1.split('.');
					if(split.length > 1) {
						LuaUtils.setVarInArray(LuaUtils.getPropertyLoop(split), split[split.length-1], value2);
					} else {
						LuaUtils.setVarInArray(this, value1, value2);
					}
				}
				catch(e:Dynamic)
				{
					var len:Int = e.message.indexOf('\n') + 1;
					if(len <= 0) len = e.message.length;
					#if HSCRIPT_ALLOWED
					addTextToDebug('ERROR ("Set Property" Event) - ' + e.message.substr(0, len), FlxColor.RED);
					#else
					FlxG.log.warn('ERROR ("Set Property" Event) - ' + e.message.substr(0, len));
					#end
				}

			//thx KutikiPlayz for letting me use this
			case 'Scroll Type':
				if(ClientPrefs.data.mechanics)
				{
					var playerLeft:Bool = false;
					var playerDown:Bool = false;
					var playerUp:Bool = false;
					var playerRight:Bool = false;
					var playerDefault:Bool = false;
					var playerFlip:Bool = false;
					var undyne:Bool = false;

					switch(value1) 
					{
						case 'left' | 'Left':
							undyne = false;
							playerDefault = false;
							playerLeft = true;
							playerDown = false;
							playerUp = false;
							playerRight = false;
							playerFlip = false;
						case 'down' | 'Down':
							undyne = false;
							playerDefault = false;
							playerLeft = false;
							playerDown = true;
							playerUp = false;
							playerRight = false;
							playerFlip = false;
						case 'up' | 'Up':
							undyne = false;
							playerDefault = false;
							playerLeft = false;
							playerDown = false;
							playerUp = true;
							playerRight = false;
							playerFlip = false;
						case 'right' | 'Right':
							undyne = false;
							playerDefault = false;
							playerLeft = false;
							playerDown = false;
							playerUp = false;
							playerRight = true;
							playerFlip = false;
						case 'default' | 'Default':
							undyne = false;
							playerDefault = true;
							playerLeft = false;
							playerDown = false;
							playerUp = false;
							playerRight = false;
							playerFlip = false;
						case 'flip' | 'Flip':
							undyne = false;
							playerDefault = false;
							playerLeft = false;
							playerDown = false;
							playerUp = false;
							playerRight = false;
							playerFlip = true;
						case 'undyne' | 'Undyne':
							undyne = true;
							playerDefault = false;
							playerLeft = false;
							playerDown = false;
							playerUp = false;
							playerRight = false;
							playerFlip = false;
					}

					for (i in 0...playerStrums.length) 
					{
						for(j in 0...opponentStrums.length) 
						{
							if(playerLeft) 
							{
								FlxTween.tween(playerStrums.members[i], {direction: 180, x: FlxG.width - 150, angle: 90}, 0.2, {ease: FlxEase.quartInOut});
								FlxTween.tween(playerStrums.members[0], {y: 144}, 0.2, {ease: FlxEase.quartInOut});
								FlxTween.tween(playerStrums.members[1], {y: 256}, 0.25, {ease: FlxEase.quartInOut});
								FlxTween.tween(playerStrums.members[2], {y: 368}, 0.3, {ease: FlxEase.quartInOut});
								FlxTween.tween(playerStrums.members[3], {y: 480}, 0.35, {ease: FlxEase.quartInOut});
								playerStrums.members[i].downScroll = false;

								FlxTween.tween(opponentStrums.members[j], {alpha: 1}, 0.2, {ease: FlxEase.quartInOut});
							} 
							else if(playerDown) 
							{
								FlxTween.tween(playerStrums.members[i], {direction: 90, y: FlxG.height - 150, angle: 0}, 0.2, {ease: FlxEase.quartInOut});
								FlxTween.tween(playerStrums.members[0], {x: 732}, 0.2, {ease: FlxEase.quartInOut});
								FlxTween.tween(playerStrums.members[1], {x: 844}, 0.3, {ease: FlxEase.quartInOut});
								FlxTween.tween(playerStrums.members[2], {x: 956}, 0.35, {ease: FlxEase.quartInOut});
								FlxTween.tween(playerStrums.members[3], {x: 1068}, 0.2, {ease: FlxEase.quartInOut});
								playerStrums.members[i].downScroll = true;

								FlxTween.tween(opponentStrums.members[j], {alpha: 1}, 0.2, {ease: FlxEase.quartInOut});
							} 
							else if(playerUp) 
							{
								FlxTween.tween(playerStrums.members[i], {direction: 90, y: 50, angle: 0}, 0.2, {ease: FlxEase.quartInOut});
								FlxTween.tween(playerStrums.members[0], {x: 732}, 0.2, {ease: FlxEase.quartInOut});
								FlxTween.tween(playerStrums.members[1], {x: 844}, 0.35, {ease: FlxEase.quartInOut});
								FlxTween.tween(playerStrums.members[2], {x: 956}, 0.3, {ease: FlxEase.quartInOut});
								FlxTween.tween(playerStrums.members[3], {x: 1068}, 0.2, {ease: FlxEase.quartInOut});
								playerStrums.members[i].downScroll = false;

								FlxTween.tween(opponentStrums.members[j], {alpha: 1}, 0.2, {ease: FlxEase.quartInOut});
							}
							else if(playerRight) 
							{
								FlxTween.tween(playerStrums.members[i], {direction: 0, x: 50, angle: 270}, 0.2, {ease: FlxEase.quartInOut});
								FlxTween.tween(playerStrums.members[0], {y: 480}, 0.2, {ease: FlxEase.quartInOut});
								FlxTween.tween(playerStrums.members[1], {y: 368}, 0.25, {ease: FlxEase.quartInOut});
								FlxTween.tween(playerStrums.members[2], {y: 256}, 0.3, {ease: FlxEase.quartInOut});
								FlxTween.tween(playerStrums.members[3], {y: 144}, 0.35, {ease: FlxEase.quartInOut});
								playerStrums.members[i].downScroll = false;

								FlxTween.tween(opponentStrums.members[j], {alpha: 1}, 0.2, {ease: FlxEase.quartInOut});
							} 
							else if(playerDefault) 
							{
								if(ClientPrefs.data.downScroll) 
								{
									FlxTween.tween(playerStrums.members[i], {direction: 90, y: FlxG.height - 150, angle: 0}, 0.2, {ease: FlxEase.quartInOut});
									FlxTween.tween(playerStrums.members[0], {x: 732}, 0.2, {ease: FlxEase.quartInOut});
									FlxTween.tween(playerStrums.members[1], {x: 844}, 0.3, {ease: FlxEase.quartInOut});
									FlxTween.tween(playerStrums.members[2], {x: 956}, 0.35, {ease: FlxEase.quartInOut});
									FlxTween.tween(playerStrums.members[3], {x: 1068}, 0.2, {ease: FlxEase.quartInOut});
									playerStrums.members[i].downScroll = true;
								} 
								else 
								{
									FlxTween.tween(playerStrums.members[i], {direction: 90, y: 50, angle: 0}, 0.2, {ease: FlxEase.quartInOut});
									FlxTween.tween(playerStrums.members[0], {x: 732}, 0.2, {ease: FlxEase.quartInOut});
									FlxTween.tween(playerStrums.members[1], {x: 844}, 0.35, {ease: FlxEase.quartInOut});
									FlxTween.tween(playerStrums.members[2], {x: 956}, 0.3, {ease: FlxEase.quartInOut});
									FlxTween.tween(playerStrums.members[3], {x: 1068}, 0.2, {ease: FlxEase.quartInOut});
									playerStrums.members[i].downScroll = false;
								}

								FlxTween.tween(opponentStrums.members[j], {alpha: 1}, 0.2, {ease: FlxEase.quartInOut});
								} 
								else if(playerFlip) 
								{
									if(ClientPrefs.data.downScroll) 
									{
										FlxTween.tween(playerStrums.members[i], {direction: 90, y: 50, angle: 0}, 0.2, {ease: FlxEase.quartInOut});
										FlxTween.tween(playerStrums.members[0], {x: 732}, 0.2, {ease: FlxEase.quartInOut});
										FlxTween.tween(playerStrums.members[1], {x: 844}, 0.35, {ease: FlxEase.quartInOut});
										FlxTween.tween(playerStrums.members[2], {x: 956}, 0.3, {ease: FlxEase.quartInOut});
										FlxTween.tween(playerStrums.members[3], {x: 1068}, 0.2, {ease: FlxEase.quartInOut});
										playerStrums.members[i].downScroll = false;
									} 
									else 
									{
										FlxTween.tween(playerStrums.members[i], {direction: 90, y: FlxG.height - 150, angle: 0}, 0.2, {ease: FlxEase.quartInOut});
										FlxTween.tween(playerStrums.members[0], {x: 732}, 0.2, {ease: FlxEase.quartInOut});
										FlxTween.tween(playerStrums.members[1], {x: 844}, 0.3, {ease: FlxEase.quartInOut});
										FlxTween.tween(playerStrums.members[2], {x: 956}, 0.35, {ease: FlxEase.quartInOut});
										FlxTween.tween(playerStrums.members[3], {x: 1068}, 0.2, {ease: FlxEase.quartInOut});
										playerStrums.members[i].downScroll = true;
									}

									FlxTween.tween(opponentStrums.members[j], {alpha: 1}, 0.2, {ease: FlxEase.quartInOut});
								} 
								else if(undyne) 
								{
									FlxTween.tween(playerStrums.members[0], {direction: 180, x: 585 - 75, y: 305, angle: 0}, 0.3, {ease: FlxEase.quartInOut});
									playerStrums.members[0].downScroll = false;
									FlxTween.tween(playerStrums.members[1], {direction: 90, x: 586, y: 305 + 75, angle: 0}, 0.2, {ease: FlxEase.quartInOut});
									playerStrums.members[1].downScroll = false;
									FlxTween.tween(playerStrums.members[2], {direction: 90, x: 586, y: 305 - 75, angle: 0}, 0.36, {ease: FlxEase.quartInOut});
									playerStrums.members[2].downScroll = true;
									FlxTween.tween(playerStrums.members[3], {direction: 0, x: 585 + 75, y: 305, angle: 0}, 0.43, {ease: FlxEase.quartInOut});
									playerStrums.members[3].downScroll = false;

									FlxTween.tween(opponentStrums.members[j], {alpha: 0}, 0.2, {ease: FlxEase.quartInOut});
								}
						}
					}

					var opponentLeft:Bool = false;
					var opponentDown:Bool = false;
					var opponentUp:Bool = false;
					var opponentRight:Bool = false;
					var opponentDefault:Bool = false;
					var opponentFlip:Bool = false;

					switch(value2) 
					{
						case 'left' | 'Left':
							undyne = false;
							opponentDefault = false;
							opponentLeft = true;
							opponentDown = false;
							opponentUp = false;
							opponentRight = false;
							opponentFlip = false;
						case 'down' | 'Down':
							undyne = false;
							opponentDefault = false;
							opponentLeft = false;
							opponentDown = true;
							opponentUp = false;
							opponentRight = false;
							opponentFlip = false;
						case 'up' | 'Up':
							undyne = false;
							opponentDefault = false;
							opponentLeft = false;
							opponentDown = false;
							opponentUp = true;
							opponentRight = false;
							opponentFlip = false;
						case 'right' | 'Right':
							undyne = false;
							opponentDefault = false;
							opponentLeft = false;
							opponentDown = false;
							opponentUp = false;
							opponentRight = true;
							opponentFlip = false;
						case 'default' | 'Default':
							undyne = false;
							opponentDefault = true;
							opponentLeft = false;
							opponentDown = false;
							opponentUp = false;
							opponentRight = false;
							opponentFlip = false;
						case 'flip' | 'Flip':
							undyne = false;
							opponentDefault = false;
							opponentLeft = false;
							opponentDown = false;
							opponentUp = false;
							opponentRight = false;
							opponentFlip = true;
					}

					for (i in 0...opponentStrums.length) 
					{
						if(opponentLeft) 
						{
							FlxTween.tween(opponentStrums.members[i], {direction: 180, x: FlxG.width - 150, angle: 90, alpha: 1}, 0.2, {ease: FlxEase.quartInOut});
							FlxTween.tween(opponentStrums.members[0], {y: 144}, 0.2, {ease: FlxEase.quartInOut});
							FlxTween.tween(opponentStrums.members[1], {y: 256}, 0.25, {ease: FlxEase.quartInOut});
							FlxTween.tween(opponentStrums.members[2], {y: 368}, 0.3, {ease: FlxEase.quartInOut});
							FlxTween.tween(opponentStrums.members[3], {y: 480}, 0.35, {ease: FlxEase.quartInOut});
							opponentStrums.members[i].downScroll = false;
						} 
						else if(opponentDown) 
						{
							FlxTween.tween(opponentStrums.members[i], {direction: 90, y: FlxG.height - 150, angle: 0, alpha: 1}, 0.2, {ease: FlxEase.quartInOut});
							FlxTween.tween(opponentStrums.members[0], {x: 92}, 0.2, {ease: FlxEase.quartInOut});
							FlxTween.tween(opponentStrums.members[1], {x: 204}, 0.3, {ease: FlxEase.quartInOut});
							FlxTween.tween(opponentStrums.members[2], {x: 316}, 0.35, {ease: FlxEase.quartInOut});
							FlxTween.tween(opponentStrums.members[3], {x: 428}, 0.2, {ease: FlxEase.quartInOut});
							opponentStrums.members[i].downScroll = true;
						} 
						else if(opponentUp) 
						{
							FlxTween.tween(opponentStrums.members[i], {direction: 90, y: 50, angle: 0, alpha: 1}, 0.2, {ease: FlxEase.quartInOut});
							FlxTween.tween(opponentStrums.members[0], {x: 92}, 0.2, {ease: FlxEase.quartInOut});
							FlxTween.tween(opponentStrums.members[1], {x: 204}, 0.35, {ease: FlxEase.quartInOut});
							FlxTween.tween(opponentStrums.members[2], {x: 316}, 0.3, {ease: FlxEase.quartInOut});
							FlxTween.tween(opponentStrums.members[3], {x: 428}, 0.2, {ease: FlxEase.quartInOut});
							opponentStrums.members[i].downScroll = false;
						} 
						else if(opponentRight) 
						{
							FlxTween.tween(opponentStrums.members[i], {direction: 0, x: 50, angle: 270, alpha: 1}, 0.2, {ease: FlxEase.quartInOut});
							FlxTween.tween(opponentStrums.members[0], {y: 480}, 0.2, {ease: FlxEase.quartInOut});
							FlxTween.tween(opponentStrums.members[1], {y: 368}, 0.25, {ease: FlxEase.quartInOut});
							FlxTween.tween(opponentStrums.members[2], {y: 256}, 0.3, {ease: FlxEase.quartInOut});
							FlxTween.tween(opponentStrums.members[3], {y: 144}, 0.35, {ease: FlxEase.quartInOut});
							opponentStrums.members[i].downScroll = false;
						} 
						else if(opponentDefault) 
						{
							if(ClientPrefs.data.downScroll) 
							{
								FlxTween.tween(opponentStrums.members[i], {direction: 90, y: FlxG.height - 150, angle: 0, alpha: 1}, 0.2, {ease: FlxEase.quartInOut});
								FlxTween.tween(opponentStrums.members[0], {x: 92}, 0.2, {ease: FlxEase.quartInOut});
								FlxTween.tween(opponentStrums.members[1], {x: 204}, 0.3, {ease: FlxEase.quartInOut});
								FlxTween.tween(opponentStrums.members[2], {x: 316}, 0.35, {ease: FlxEase.quartInOut});
								FlxTween.tween(opponentStrums.members[3], {x: 428}, 0.2, {ease: FlxEase.quartInOut});
								opponentStrums.members[i].downScroll = true;
							} 
							else 
							{
								FlxTween.tween(opponentStrums.members[i], {direction: 90, y: 50, angle: 0, alpha: 1}, 0.2, {ease: FlxEase.quartInOut});
								FlxTween.tween(opponentStrums.members[0], {x: 92}, 0.2, {ease: FlxEase.quartInOut});
								FlxTween.tween(opponentStrums.members[1], {x: 204}, 0.35, {ease: FlxEase.quartInOut});
								FlxTween.tween(opponentStrums.members[2], {x: 316}, 0.3, {ease: FlxEase.quartInOut});
								FlxTween.tween(opponentStrums.members[3], {x: 428}, 0.2, {ease: FlxEase.quartInOut});
								opponentStrums.members[i].downScroll = false;
							}
						} 
						else if(opponentFlip) 
						{
							if(ClientPrefs.data.downScroll) 
							{
								FlxTween.tween(opponentStrums.members[i], {direction: 90, y: 50, angle: 0, alpha: 1}, 0.2, {ease: FlxEase.quartInOut});
								FlxTween.tween(opponentStrums.members[0], {x: 92}, 0.2, {ease: FlxEase.quartInOut});
								FlxTween.tween(opponentStrums.members[1], {x: 204}, 0.35, {ease: FlxEase.quartInOut});
								FlxTween.tween(opponentStrums.members[2], {x: 316}, 0.3, {ease: FlxEase.quartInOut});
								FlxTween.tween(opponentStrums.members[3], {x: 428}, 0.2, {ease: FlxEase.quartInOut});
								opponentStrums.members[i].downScroll = false;
							} 
							else 
							{
								FlxTween.tween(opponentStrums.members[i], {direction: 90, y: FlxG.height - 150, angle: 0, alpha: 1}, 0.2, {ease: FlxEase.quartInOut});
								FlxTween.tween(opponentStrums.members[0], {x: 92}, 0.2, {ease: FlxEase.quartInOut});
								FlxTween.tween(opponentStrums.members[1], {x: 204}, 0.3, {ease: FlxEase.quartInOut});
								FlxTween.tween(opponentStrums.members[2], {x: 316}, 0.35, {ease: FlxEase.quartInOut});
								FlxTween.tween(opponentStrums.members[3], {x: 428}, 0.2, {ease: FlxEase.quartInOut});
								opponentStrums.members[i].downScroll = true;
							}
						}
					} //T O O  M U C H  C O D E
				}

			case 'Manage Lyrics':
				var triggerInfo:Array<String> = value2.split(',');

				switch(value1.trim().toLowerCase())
				{
					case "move":
						subtitles.manageLyrics(
							MOVE,
							{
								startTimer: Std.parseFloat(triggerInfo[1]), //Start Timer
								delayTimer: Std.parseFloat(triggerInfo[2]), //Delay Timer
								endTimer: Std.parseFloat(triggerInfo[3]), //End Timer
								easeStart: returnTweenEase(triggerInfo[4].trim()), //Ease Start Value
								easeEnd: returnTweenEase(triggerInfo[5].trim()), //Ease End Value
							},
							Std.parseInt(triggerInfo[0]) //Which Lyrics to use on
						);
					case "tween data" | "tweendata":
						subtitles.manageLyrics(
							TWEEN_DATA,
							{
								tweenData: [
									Std.parseInt(triggerInfo[0]), //Add X Start
									Std.parseInt(triggerInfo[1]), //Add Y Start
									Std.parseInt(triggerInfo[2]), //Add Angle Start
									Std.parseFloat(triggerInfo[3]), //Add Scale X Start
									Std.parseFloat(triggerInfo[4]), //Add Scale Y Start
									Std.parseFloat(triggerInfo[5]), //Alpha Start
									Std.parseInt(triggerInfo[6]), //Add X End
									Std.parseInt(triggerInfo[7]), //Add Y End
									Std.parseInt(triggerInfo[8]), //Add Angle End
									Std.parseFloat(triggerInfo[9]), //Add Scale X End
									Std.parseFloat(triggerInfo[10]), //Add Scale Y End
									Std.parseFloat(triggerInfo[11]), //Alpha End
								]
							}
						);
					case "data":
						subtitles.manageLyrics(
							DATA,
							{
								width: Std.parseInt(triggerInfo[1]), //Textfield Width
								icon: triggerInfo[2].trim(), //Icon Name
							},
							Std.parseInt(triggerInfo[0]) //Which Lyrics to use on
						);
					case "text data" | "textdata":
						subtitles.manageLyrics(
							TEXT_DATA,
							{
								font: triggerInfo[1].trim(), //Font File
								size: Std.parseInt(triggerInfo[2]), //Text Size
								color: [Std.parseInt(triggerInfo[3]), Std.parseInt(triggerInfo[4]), Std.parseInt(triggerInfo[5])], //Text (R G B)
								align: returnAlignType(triggerInfo[6].trim()), //Align Type
								colorB: [Std.parseInt(triggerInfo[7]), Std.parseInt(triggerInfo[8]), Std.parseInt(triggerInfo[9])], //Border (R G B)
								sizeB: Std.parseInt(triggerInfo[10]) //Border Size
							},
							Std.parseInt(triggerInfo[0]) //Which Lyrics to use on
						);
					case "position":
						subtitles.manageLyrics(
							POSITION,
							{
								positionData: [
									Std.parseInt(triggerInfo[1]), //Add X
									Std.parseInt(triggerInfo[2]) //Add Y
								]
							},
							Std.parseInt(triggerInfo[0]) //Which Lyrics to use on
						);
					case "text":
					subtitles.manageLyrics(
						TEXT,
						{
							text: triggerInfo[1].trim(), //String Text
							textDelay: Std.parseFloat(triggerInfo[2]), //Delay Timer
						},
						Std.parseInt(triggerInfo[0]) //Which Lyrics to use on
					);
				}

			case 'Background Controls':
				var triggerInfo:Array<String> = value2.split(',');
				switch (value1.toLowerCase())
				{
					case 'flash':
						backgroundControls(BG_FLASH, {
							timer: Std.parseFloat(triggerInfo[0]), 
							ease: returnTweenEase(triggerInfo[1]), 
							alpha: Std.parseFloat(triggerInfo[2]), 
							colors: [Std.parseInt(triggerInfo[3]), Std.parseInt(triggerInfo[4]), Std.parseInt(triggerInfo[5])]
						});
					case 'darken' | 'dark':
						backgroundControls(BG_DARK, {
							alpha: Std.parseFloat(triggerInfo[0]), 
							timer: Std.parseFloat(triggerInfo[1]), 
							ease: returnTweenEase(triggerInfo[2])});
					case 'setcolor' | 'set color':
						backgroundControls(SET_COLOR, {
							alpha: Std.parseFloat(triggerInfo[0]), 
							colors: [Std.parseInt(triggerInfo[1]), Std.parseInt(triggerInfo[2]), Std.parseInt(triggerInfo[3])]
						});
					case 'tweencolor' | 'tween color':
						backgroundControls(TWEEN_COLOR, {
							alpha: Std.parseFloat(triggerInfo[0]), 
							timer: Std.parseFloat(triggerInfo[1]), 
							ease: returnTweenEase(triggerInfo[2]),
							colors: [Std.parseInt(triggerInfo[3]), Std.parseInt(triggerInfo[4]), Std.parseInt(triggerInfo[5])]
						});
				}

			case 'Cinematic Event':
				var triggerInfo:Array<String> = value2.split(',');
				switch (value1.toLowerCase().trim())
				{
					case "move": 
						cinematicBarControls(MOVE, 
						{
							valueInput: Std.parseFloat(triggerInfo[0]), //Thickness of the bars
							timer: Std.parseFloat(triggerInfo[1]), //Duration
							ease: triggerInfo[2] //Ease name
						});
					case "angle": 
						cinematicBarControls(ANGLE, 
						{
							valueInput: Std.parseFloat(triggerInfo[0]), //Camera angle of the bars
							timer: Std.parseFloat(triggerInfo[1]), //Duration
							ease: triggerInfo[2] //Ease name
						});
					case "color": 
						cinematicBarControls(COLOR, 
						{
							colors: //Color the bars change to
							[
								Std.parseInt(triggerInfo[0]), //R
								Std.parseInt(triggerInfo[1]), //G
								Std.parseInt(triggerInfo[2]) //B
							], 
							timer: Std.parseFloat(triggerInfo[3]), //Duration
							ease: triggerInfo[4] //Ease name
						});
					case "flash": 
						cinematicBarControls(FLASH, 
							{
								colors: //Flash color of the bars
								[
									Std.parseInt(triggerInfo[0]), //R
									Std.parseInt(triggerInfo[1]), //G
									Std.parseInt(triggerInfo[2]) //B
								], 
								timer: Std.parseFloat(triggerInfo[3]), //Duration
								ease: triggerInfo[4] //Ease name
							});
					case "alpha": 
						cinematicBarControls(ALPHA, 
							{
								valueInput: Std.parseFloat(triggerInfo[0]), //Alpha value of the camera the bars are on
								timer: Std.parseFloat(triggerInfo[1]), //Duration
								ease: triggerInfo[2] //Ease name
							});
					case "bop": 
							cinematicBarControls(BOP, 
							{
								valueInput: Std.parseFloat(triggerInfo[0]), //How intense the bars will bop
								timer: Std.parseFloat(triggerInfo[1]), //Duration
								ease: triggerInfo[2] //Ease name
							});
				}

			case "Meta Event": //we love 4th wall breaks
				var triggerInfo:Array<String> = value2.split(',');

				switch (value1.toLowerCase().trim())
				{
					case "windowtitle" | "window title":
						var checkExtraText:Bool = triggerInfo[0].toLowerCase().trim() == "true";

						windowName = triggerInfo[1] + (checkExtraText ? (isStoryMode ? PlayState.curEpisode + " - " : "Freeplay - ") + triggerInfo[2].trim() : "");
						Application.current.window.title = windowName;

					case "shakewindow" | "shake window":
						CppAPI.shakeWindows(Std.parseInt(triggerInfo[0]), Std.parseInt(triggerInfo[1]));

					case "togglewindowtransparency" | "toggle window transparency":
						var checkToggle:Bool = triggerInfo[0].toLowerCase().trim() == "true";

						if(checkToggle)
							Transparency.getWindowsTransparent();
						else
							Transparency.getWindowsbackward();

					case "togglefakecloseout" | "toggle fake closeout":
						var checkclosefakeout:Bool = triggerInfo[0].toLowerCase().trim() == "true";

						if (checkclosefakeout)
							CppAPI.hideWindows();
						else
							CppAPI.restoreWindows();

					case "toggle fullscreen" | "togglefullscreen":
						var checkFullscreen:Bool = triggerInfo[0].toLowerCase().trim() == "true";

						if (checkFullscreen)
							FlxG.fullscreen = true;
						else
							FlxG.fullscreen = false;

					case "windowposition" | "window position" | "windowpos" | "window pos":
						FlxTween.tween(this, {winX: Std.int((Lib.application.window.display.bounds.width - Lib.application.window.width) * 0.5) + Std.parseInt(triggerInfo[0]), winY: Std.int((Lib.application.window.display.bounds.height - Lib.application.window.height) * 0.5) + Std.parseInt(triggerInfo[1])}, Std.parseFloat(triggerInfo[2]), //Time
						{
							ease: returnTweenEase(triggerInfo[3].toLowerCase().trim()) //Ease
						});

					case "discord" | "richpresence" | "rich presence" | "activity":
						if (triggerInfo[0].trim() != null)
							discordTxt[0] = triggerInfo[0].trim();
		
						if (triggerInfo[1].trim() != null)
						{
							discordTxt[1] = triggerInfo[1].trim();
							isDisplayingScore = false;
						}
		
						if (triggerInfo[2].toLowerCase().trim() != null)
							discordIcon = triggerInfo[2].toLowerCase().trim();
		
						if (triggerInfo[0].toLowerCase().trim() == "default") //this is by far the worst way I have ever improvised for a stupid null check not working (don)
							discordTxt[0] = detailsText;
		
						if (triggerInfo[1].toLowerCase().trim() == "default")
						{
							discordTxt[1] = scoreTxt.text;
							isDisplayingScore = true;
						}
		
						if (triggerInfo[2].toLowerCase().trim() == "default")
						{
							discordIcon = SONG.song.toLowerCase().trim();
		
							if (FreeplayState.freeplayMenuList == 3)
								discordIcon = SONG.song == "Alone" ? "volume1" : "volume2";
							
							if (FreeplayState.freeplayMenuList == 2)
								discordIcon = "volume1";
						}
		
						switch (SONG.song)
						{
							case "Joygrim" | "Neglection" | "Scrapped": DiscordClient.changePresence("Playing a song", "It's a secret...", "icon", "random", true, songLength - Conductor.songPosition - ClientPrefs.data.noteOffset);
							default: DiscordClient.changePresence(discordTxt[0], discordTxt[1], CoolUtil.spaceToDash(discordIcon), "random", true, songLength - Conductor.songPosition - ClientPrefs.data.noteOffset);
						}		
				}

			case 'Camera Event':	
				var triggerInfo:Array<String> = value2.split(',');
				switch (value1.toLowerCase())
				{
					case "tweenvalue" | "tween value":
						switch (triggerInfo[0].toLowerCase())
						{
							case "zoom":
								if (camTwn[0] != null)
									camTwn[0].cancel();

								camTwn[0] = FlxTween.tween(camGame, {zoom: Std.parseFloat(triggerInfo[1])}, Std.parseFloat(triggerInfo[2]), {ease: returnTweenEase(triggerInfo[3].trim()), onComplete: function(twn:FlxTween)
								{
									defaultCamZoom = Std.parseFloat(triggerInfo[1]);
									camTwn[0] = null;
								}});
							
							case "cameraspeed" | "camera speed" | "cam speed" | "camspeed" | "speed":
								if (camTwn[1] != null)
									camTwn[1].cancel();

								camTwn[1] = FlxTween.tween(this, {cameraSpeed: Std.parseFloat(triggerInfo[1])}, Std.parseFloat(triggerInfo[2]), {ease: returnTweenEase(triggerInfo[3].trim()), onComplete: function(twn:FlxTween)
								{
									camTwn[1] = null;
								}});

							case "alpha":
								if (camTwn[2] != null)
									camTwn[2].cancel();

								if (Std.parseFloat(triggerInfo[1]) > 1 || Std.parseFloat(triggerInfo[1]) < 0)
									triggerInfo[1] = "1";

								camTwn[2] = FlxTween.tween(camGame, {alpha: Std.parseFloat(triggerInfo[1])}, Std.parseFloat(triggerInfo[2]), {ease: returnTweenEase(triggerInfo[3].trim()), onComplete: function(twn:FlxTween)
								{
									camTwn[2] = null;
								}});

							case "hudalpha" | "hud alpha":
								if (camTwn[3] != null)
									camTwn[3].cancel();

								if (Std.parseFloat(triggerInfo[1]) > 1 || Std.parseFloat(triggerInfo[1]) < 0)
									triggerInfo[1] = "1";

								camTwn[3] = FlxTween.tween(camHUD, {alpha: Std.parseFloat(triggerInfo[1])}, Std.parseFloat(triggerInfo[2]), {ease: returnTweenEase(triggerInfo[3].trim()), onComplete: function(twn:FlxTween)
								{
									camTwn[3] = null;
								}});

							case "angle":
								if (camTwn[4] != null)
									camTwn[4].cancel();

								camTwn[4] = FlxTween.tween(camGame, {angle: Std.parseFloat(triggerInfo[1])}, Std.parseFloat(triggerInfo[2]), {ease: returnTweenEase(triggerInfo[3].trim()), onComplete: function(twn:FlxTween)
								{
									camTwn[4] = null;
								}});

							case "hudangle" | "hud angle":
								if (camTwn[5] != null)
									camTwn[5].cancel();

								camTwn[5] = FlxTween.tween(camHUD, {angle: Std.parseFloat(triggerInfo[1])}, Std.parseFloat(triggerInfo[2]), {ease: returnTweenEase(triggerInfo[3].trim()), onComplete: function(twn:FlxTween)
								{
									camTwn[5] = null;
								}});

							case "vidalpha" | "vid alpha":
								if (camTwn[6] != null)
									camTwn[6].cancel();

								if (Std.parseFloat(triggerInfo[1]) > 1 || Std.parseFloat(triggerInfo[1]) < 0)
									triggerInfo[1] = "1";

								camTwn[6] = FlxTween.tween(camVideo, {alpha: Std.parseFloat(triggerInfo[1])}, Std.parseFloat(triggerInfo[2]), {ease: returnTweenEase(triggerInfo[3].trim()), onComplete: function(twn:FlxTween)
								{
									camTwn[6] = null;
								}});

							default:
								#if HSCRIPT_ALLOWED
								addTextToDebug('ERROR ("Camera Event" Event) - Value data type does not exist!', FlxColor.RED);
								#else
								FlxG.log.warn('ERROR ("Camera Event" Event) - Value data type does not exist!');
								#end
						}

					case "starthidden" | "start hidden":
						//do nothing cause it's already doing something

					case "changevalue" | "change value":
						switch (triggerInfo[0].toLowerCase())
						{
							case "staticzoom" | "static zoom": camGame.zoom = defaultCamZoom = Std.parseFloat(triggerInfo[1]);
							case "addzoom" | "add zoom": camGame.zoom += Std.parseFloat(triggerInfo[1]);
							case "addhudzoom" | "add hud zoom": camHUD.zoom += Std.parseFloat(triggerInfo[1]);
							case "defaultcamzoom" | "default cam zoom" | "default camera zoom": defaultCamZoom = Std.parseFloat(triggerInfo[1]);
							case "alpha": camGame.alpha = Std.parseFloat(triggerInfo[1]);
							case "cameraspeed" | "cam speed" | "camspeed" | "camera speed" | "speed": cameraSpeed = Std.parseFloat(triggerInfo[1]);
							case "hudalpha" | "hud alpha": camHUD.alpha = Std.parseFloat(triggerInfo[1]);
							case "vidalpha" | "vid alpha": camVideo.alpha = Std.parseFloat(triggerInfo[1]);
							case "angle": camGame.angle = Std.parseFloat(triggerInfo[1]);
							case "hudangle" | "hud angle": camHUD.angle = Std.parseFloat(triggerInfo[1]);
							case "adddefaultcamzoom" | "add default cam zoom" | "add default camera zoom": defaultCamZoom += Std.parseFloat(triggerInfo[1]);
							default:
								#if HSCRIPT_ALLOWED
								addTextToDebug('ERROR ("Camera Event" Event) - Value data type does not exist!', FlxColor.RED);
								#else
								FlxG.log.warn('ERROR ("Camera Event" Event) - Value data type does not exist!');
								#end
						}

					case "shake":
						if (triggerInfo[2] == "hud")
							camHUD.shake(Std.parseFloat(triggerInfo[0]), Std.parseFloat(triggerInfo[1]));
						else
							camGame.shake(Std.parseFloat(triggerInfo[0]), Std.parseFloat(triggerInfo[1]));

					case "flash":
						if (ClientPrefs.data.flashing)
						{
							if (triggerInfo[0] == null) triggerInfo[0] = "255";
							if (triggerInfo[1] == null) triggerInfo[1] = "255";
							if (triggerInfo[2] == null) triggerInfo[2] = "255";
							if (triggerInfo[3] == null) triggerInfo[3] = "1";
							if (triggerInfo[4] == null) triggerInfo[4] = "1";
							if (triggerInfo[5] == null) triggerInfo[5] = "false";
				
							var boolShit:Bool = false;
				
							if (triggerInfo[5].toLowerCase().trim() == "true")
								boolShit = true;
				
							flashSprite.color = FlxColor.fromRGB(Std.parseInt(triggerInfo[0]), Std.parseInt(triggerInfo[1]), Std.parseInt(triggerInfo[2]));
							flashSpeed = Std.parseFloat(triggerInfo[3]);
							flashSprite.alpha = Std.parseFloat(triggerInfo[4]);
							flashSprite.blend = (boolShit ? ADD : NORMAL);
						}

					case "fade":
						if (triggerInfo[0] == null) triggerInfo[0] = "0";
						if (triggerInfo[1] == null) triggerInfo[1] = "0";
						if (triggerInfo[2] == null) triggerInfo[2] = "0";
						if (triggerInfo[3] == null) triggerInfo[3] = "1";
						if (triggerInfo[4] == null) triggerInfo[4] = "false";

						var boolShit:Bool = false;
		
						if (triggerInfo[4].toLowerCase().trim() == "true")
							boolShit = true;

						camBars.fade(FlxColor.fromRGB(Std.parseInt(triggerInfo[0]), Std.parseInt(triggerInfo[1]), Std.parseInt(triggerInfo[2])), Std.parseFloat(triggerInfo[3]), boolShit);
					case "changepos" | "change pos" | "set position" | "setposition":
						if(camFollow != null)
						{
							isCameraOnForcedPos = false;
							if(triggerInfo[0] != null || triggerInfo[1] != null)
							{
								isCameraOnForcedPos = true;
								if(triggerInfo[0] == null) triggerInfo[0] = "0";
								if(triggerInfo[1] == null) triggerInfo[1] = "0";
								camFollow.x = Std.parseFloat(triggerInfo[0]);
								camFollow.y = Std.parseFloat(triggerInfo[1]);
							}
						}

					case "tweenpos" | "tween pos" | "tweenposition" | "tween position":
						if (camFollow != null)
						{
							if (camTwn[7] != null)
								camTwn[7].cancel();

							isCameraOnForcedPos = false;
							if(triggerInfo[0] != null || triggerInfo[1] != null)
							{
								isCameraOnForcedPos = true;
								if(triggerInfo[0] == null) triggerInfo[0] = "0";
								if(triggerInfo[1] == null) triggerInfo[1] = "0";
								camTwn[7] = FlxTween.tween(camFollow, {x: Std.parseFloat(triggerInfo[0]), y: Std.parseFloat(triggerInfo[1])}, Std.parseFloat(triggerInfo[2]), {ease: returnTweenEase(triggerInfo[3].trim().toLowerCase()), onComplete: function(twn:FlxTween)
								{
									camTwn[7] = null;
								}});
							}
						}
					case "snappos" | "snap pos" | "snap position" | "snapposition":
						if(camFollow != null)
						{
							isCameraOnForcedPos = false;
							if(triggerInfo[0] != null || triggerInfo[1] != null)
							{
								isCameraOnForcedPos = true;
								if(triggerInfo[0] == null) triggerInfo[0] = "0";
								if(triggerInfo[1] == null) triggerInfo[1] = "0";
								
								snapCamFollowToPos(Std.parseFloat(triggerInfo[0]), Std.parseFloat(triggerInfo[1]));
							}
						}
				}
			
			case 'Play Sound':
				if(flValue2 == null) flValue2 = 1;
				FlxG.sound.play(Paths.sound(value1), flValue2);
		}

		stagesFunc(function(stage:BaseStage) stage.eventCalled(eventName, value1, value2, flValue1, flValue2, strumTime));
		callOnScripts('onEvent', [eventName, value1, value2, strumTime]);
	}

	function moveCameraSection():Void {
		if(SONG.notes[curSection] == null) return;

		if (gf != null && SONG.notes[curSection].gfSection)
		{
			camFollow.set(gf.getMidpoint().x, gf.getMidpoint().y);
			camFollow.x += gf.cameraPosition[0] + girlfriendCameraOffset[0];
			camFollow.y += gf.cameraPosition[1] + girlfriendCameraOffset[1];
			tweenCamIn();
			callOnScripts('onMoveCamera', ['gf']);
			return;
		}

		if (!SONG.notes[curSection].mustHitSection)
		{
			cameraOnDad = true;
			moveCamera(true);
			callOnScripts('onMoveCamera', ['dad']);
		}
		else
		{
			cameraOnDad = false;
			moveCamera(false);
			callOnScripts('onMoveCamera', ['boyfriend']);
		}
	}
	
	var cameraTwn:FlxTween;
	public function moveCamera(isDad:Bool)
	{
		if (!isCameraOnForcedPos)
		{
			if(isDad)
			{
				camFollow.set(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);
				camFollow.x += dad.cameraPosition[0] + opponentCameraOffset[0];
				camFollow.y += dad.cameraPosition[1] + opponentCameraOffset[1];
				tweenCamIn();
			}
			else
			{
				camFollow.set(boyfriend.getMidpoint().x - 100, boyfriend.getMidpoint().y - 100);
				camFollow.x -= boyfriend.cameraPosition[0] - boyfriendCameraOffset[0];
				camFollow.y += boyfriend.cameraPosition[1] + boyfriendCameraOffset[1];

				if (Paths.formatToSongPath(SONG.song) == 'tutorial' && cameraTwn == null && FlxG.camera.zoom != 1)
				{
					cameraTwn = FlxTween.tween(FlxG.camera, {zoom: 1}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut, onComplete:
						function (twn:FlxTween)
						{
							cameraTwn = null;
						}
					});
				}
			}
		}
	}

	function tweenCamIn() {
		if (Paths.formatToSongPath(SONG.song) == 'tutorial' && cameraTwn == null && FlxG.camera.zoom != 1.3) {
			cameraTwn = FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut, onComplete:
				function (twn:FlxTween) {
					cameraTwn = null;
				}
			});
		}
	}

	function snapCamFollowToPos(x:Float, y:Float) {
		camFollow.set(x, y);
		camFollowPos.setPosition(x, y);
	}

	public function finishSong(?ignoreNoteOffset:Bool = false):Void
	{
		updateTime = false;
		FlxG.sound.music.volume = 0;

		vocals.volume = 0;
		vocals.pause();
		opponentVocals.volume = 0;
		opponentVocals.pause();

		if(ClientPrefs.data.noteOffset <= 0 || ignoreNoteOffset) {
			endCallback();
		} else {
			finishTimer = new FlxTimer().start(ClientPrefs.data.noteOffset / 1000, function(tmr:FlxTimer) {
				endCallback();
			});
		}
	}


	public var transitioning = false;
	public function endSong()
	{
		//Should kill you if you tried to cheat
		if(!startingSong) {
			notes.forEach(function(daNote:Note) {
				if(daNote.strumTime < songLength - Conductor.safeZoneOffset) {
					healthThing -= 0.05 * healthLoss;
				}
			});
			for (daNote in unspawnNotes) {
				if(daNote.strumTime < songLength - Conductor.safeZoneOffset) {
					healthThing -= 0.05 * healthLoss;
				}
			}

			if(doDeathCheck()) {
				return false;
			}
		}
		pauseCountEnabled = false;

		Lib.application.window.onClose.removeAll(); // goes back to normal hopefully
		Lib.application.window.onClose.add(function() {
			DiscordClient.shutdown();
		});

		timeBar.visible = false;
		timeTxt.visible = false;
		canPause = false;
		endingSong = true;
		camZooming = false;
		inCutscene = false;
		updateTime = false;

		if (GameData.canOverrideCPU)
		{
			cpuControlled = false;
			ClientPrefs.data.gameplaySettings["botplay"] = false;
		}

		deathCounter = 0;
		seenCutscene = false;

		var ret:Dynamic = callOnScripts('onEndSong', null, true);
		if(ret != LuaUtils.Function_Stop && !transitioning)
		{
			#if !switch
			var percent:Float = ratingPercent;
			if(Math.isNaN(percent)) percent = 0;

			var songName:String = SONG.song; //fixes the song scores not displaying for some songs in freeplay due to them having different name formats and id from freeplay and in-game (don)
			switch (SONG.song)
			{
				case "Dont Cross": songName = "Don't Cross!";
				case "The Wretched Tilezones (Simple Life)": songName = "Simple Life";
				case "Ship the Fart Yay Hooray <3 (Distant Stars)": songName = "Distant Stars";
				case "Ahh the Scary (Somber Night)": songName = "Somber Night";
			}
			Highscore.saveScore(songName, songScore, storyDifficulty, percent);
			#end
			playbackRate = 1;

			if (chartingMode)
			{
				openChartEditor();
				return false;
			}

			if (isStoryMode)
			{
				campaignScore += songScore;
				campaignMisses += songMisses;

				storyPlaylist.remove(storyPlaylist[0]);

				if (storyPlaylist.length <= 0)
				{
					if (ClientPrefs.data.mechanics && SONG.song == "Delusional")
					{
						//hasEndingScene = true;
						GameData.episode1FPLock = "unlocked";
						GameData.deluluSong = true;
						GameData.storySong = "Devilish-Deal";
						GameData.saveShit();
					}
					if (SONG.song == "Birthday")
					{
						GameData.birthdayLocky = 'beaten';
						GameData.saveShit();
					}
					FlxG.sound.playMusic(Paths.music('aviOST/rottenPetals'));
					#if DISCORD_ALLOWED DiscordClient.resetClientID(); #end

					MusicBeatState.switchState(new StoryMenuState());

					// if ()
					if(!ClientPrefs.getGameplaySetting('practice') && !ClientPrefs.getGameplaySetting('botplay')) {
						StoryMenuState.weekCompleted.set(WeekData.weeksList[storyWeek], true);
						Highscore.saveWeekScore(WeekData.getWeekFileName(), campaignScore, storyDifficulty);

						FlxG.save.data.weekCompleted = StoryMenuState.weekCompleted;
						FlxG.save.flush();
					}
					changedDifficulty = false;
				}
				else
				{
					var difficulty:String = Difficulty.getFilePath();

					if (SONG.song == "Devilish Deal")
					{
						//hasEndingScene = true;
						GameData.devilSong = true;
						GameData.storySong = "Isolated";
						GameData.saveShit();
					}
					if (SONG.song == "Isolated")
					{
						//hasEndingScene = true;
						GameData.isoSong = true;
						GameData.storySong = "Lunacy";
						GameData.saveShit();
					}
					if (SONG.song == "Lunacy")
					{
						//hasEndingScene = true;
						GameData.lunaSong = true;
						GameData.storySong = "Delusional";
						GameData.saveShit();
					}
					if (SONG.song == "Delusional")
					{
						//hasEndingScene = true;
						GameData.episode1FPLock = "unlocked";
						GameData.deluluSong = true;
						GameData.storySong = "Devilish-Deal";
						GameData.saveShit();

						FlxG.sound.playMusic(Paths.music('aviOST/rottenPetals'));
						#if DISCORD_ALLOWED DiscordClient.resetClientID(); #end

						MusicBeatState.switchState(new StoryMenuState());

						// if ()
						if(!ClientPrefs.getGameplaySetting('practice') && !ClientPrefs.getGameplaySetting('botplay')) {
							StoryMenuState.weekCompleted.set(WeekData.weeksList[storyWeek], true);
							Highscore.saveWeekScore(WeekData.getWeekFileName(), campaignScore, storyDifficulty);

							FlxG.save.data.weekCompleted = StoryMenuState.weekCompleted;
							FlxG.save.flush();
						}
						changedDifficulty = false;
					}

					if (SONG.song != "Delusional")
					{
						trace('LOADING NEXT SONG');
						trace(Paths.formatToSongPath(storyPlaylist[0]) + difficulty);

						FlxTransitionableState.skipNextTransIn = true;
						FlxTransitionableState.skipNextTransOut = true;
						
						prevCamFollow = camFollow;
						prevCamFollowPos = camFollowPos;

						var songLowercase:String = Paths.formatToSongPath(storyPlaylist[0]);

						if (!GameData.devilSong)
							SONG = Song.loadFromJson(storyPlaylist[0], songLowercase);
						else if (GameData.devilSong)
							SONG = Song.loadFromJson(GameData.storySong.toLowerCase(), GameData.storySong.toLowerCase());
						FlxG.sound.music.stop();

						LoadingState.loadAndSwitchState(new PlayState());
					}
				}
			}
			else
			{
				trace('WENT BACK TO FREEPLAY??');
				#if DISCORD_ALLOWED DiscordClient.resetClientID(); #end

				GameData.completeFPSong();
				MusicBeatState.switchState(new FreeplayState());
				FlxG.sound.playMusic(Paths.music('aviOST/seekingFreedom'));
				FlxG.mouse.load(Paths.image('favi/ui/Cursor').bitmap);
				changedDifficulty = false;
			}
			transitioning = true;
		}
		return true;
	}

	public function KillNotes() {
		while(notes.length > 0) {
			var daNote:Note = notes.members[0];
			daNote.active = false;
			daNote.visible = false;
			invalidateNote(daNote);
		}
		unspawnNotes = [];
		eventNotes = [];
	}

	public var totalPlayed:Int = 0;
	public var totalNotesHit:Float = 0.0;

	public var showCombo:Bool = false;
	public var showComboNum:Bool = true;
	public var showRating:Bool = true;

	// Stores Ratings and Combo Sprites in a group
	public var comboGroup:FlxSpriteGroup;
	// Stores HUD Objects in a Group
	public var uiGroup:FlxSpriteGroup;
	// Stores Note Objects in a Group
	public var noteGroup:FlxTypedGroup<FlxBasic>;

	private function cachePopUpScore()
	{
		var uiPrefix:String = '';
		var uiSuffix:String = '';
		if (stageUI != "normal")
		{
			uiPrefix = '${stageUI}UI/';
			if (PlayState.isPixelStage) uiSuffix = '-pixel';
		}

		for (rating in ratingsData)
			Paths.image(uiPrefix + rating.image + uiSuffix);
		for (i in 0...10)
			Paths.image(uiPrefix + 'num' + i + uiSuffix);
	}

	private function popUpScore(note:Note = null):Void
	{
		var noteDiff:Float = Math.abs(note.strumTime - Conductor.songPosition + ClientPrefs.data.ratingOffset);
		vocals.volume = 1;

		if (!ClientPrefs.data.comboStacking && comboGroup.members.length > 0) {
			for (spr in comboGroup) {
				spr.destroy();
				comboGroup.remove(spr);
			}
		}

		var placement:String = Std.string(combo);

		var rating:FlxSprite = new FlxSprite();
		var score:Int = 350;

		var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
		coolText.screenCenter();
		coolText.x = FlxG.width * 0.35;

		//tryna do MS based judgment due to popular demand
		var daRating:Rating = Conductor.judgeNote(ratingsData, noteDiff / playbackRate);

		totalNotesHit += daRating.ratingMod;
		note.ratingMod = daRating.ratingMod;
		if(!note.ratingDisabled) daRating.hits++;
		note.rating = daRating.name;
		score = daRating.score;

		if(daRating.noteSplash && !note.noteSplashData.disabled && curStage != "menuSongs")
		{
			spawnNoteSplashOnNote(note);
		}

		if(!practiceMode && !cpuControlled) {
			songScore += score;
			if(!note.ratingDisabled)
			{
				songHits++;
				totalPlayed++;
				RecalculateRating(false);
			}
		}

		var pixelShitPart1:String = "";
		var pixelShitPart2:String = '';

		if (isPixelStage)
		{
			pixelShitPart1 = 'pixelUI/';
			pixelShitPart2 = '-pixel';
		}

		if (FreeplayState.freeplayMenuList == 2)
		{
			pixelShitPart1 = 'legacyUI/';
			if (isPixelStage)
				pixelShitPart2 = '-pixel';
			else 
				pixelShitPart2 = '';
		}

		rating.loadGraphic(Paths.image(pixelShitPart1 + (((ratingPercent == 1 || cpuControlled) && SONG.song != "Cycled Sins") ? "marvelous" : daRating.image) + (SONG.song == "Malfunction" ? '-mal' : '') + pixelShitPart2));
		rating.scale.set(0.4, 0.4);
		rating.screenCenter();
		rating.x = FlxG.width * 0.8;
		rating.y = 100;
		rating.acceleration.y = 550 * playbackRate * playbackRate;
		rating.velocity.y -= FlxG.random.int(140, 175) * playbackRate;
		rating.velocity.x -= FlxG.random.int(0, 10) * playbackRate;
		rating.visible = (!ClientPrefs.data.hideHud && showRating);
		if (!ClientPrefs.data.downScroll)
			rating.y += 495 + (SONG.song == "Malfunction" ? ((daRating.image == "sick" && ratingPercent != 1) ? -50 : -35) : 0);
		if (SONG.song == "War Dilemma" && !ClientPrefs.data.downScroll)
			rating.y -= 120;
		
		var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'combo' + pixelShitPart2));
		comboSpr.screenCenter();
		comboSpr.x = coolText.x;
		comboSpr.acceleration.y = FlxG.random.int(200, 300) * playbackRate * playbackRate;
		comboSpr.velocity.y -= FlxG.random.int(140, 160) * playbackRate;
		comboSpr.visible = (!ClientPrefs.data.hideHud && showCombo);
		comboSpr.x += ClientPrefs.data.comboOffset[0];
		comboSpr.y -= ClientPrefs.data.comboOffset[1];
		comboSpr.y += 60;
		comboSpr.velocity.x += FlxG.random.int(1, 10) * playbackRate;

		comboGroup.add(rating);
		
		if (!ClientPrefs.data.comboStacking)
		{
			if (lastRating != null) lastRating.kill();
			lastRating = rating;
		}

		if (!isPixelStage)
		{
			comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
			comboSpr.antialiasing = ClientPrefs.data.antialiasing;
		}
		else
		{
			rating.setGraphicSize(Std.int(rating.width * daPixelZoom * (SONG.song == "Malfunction" ? 0.25 : 0.36)));
			comboSpr.setGraphicSize(Std.int(comboSpr.width * daPixelZoom * 0.85));
		}

		comboSpr.updateHitbox();
		rating.updateHitbox();

		var seperatedScore:Array<Int> = [];

		if(combo >= 1000) {
			seperatedScore.push(Math.floor(combo / 1000) % 10);
		}
		seperatedScore.push(Math.floor(combo / 100) % 10);
		seperatedScore.push(Math.floor(combo / 10) % 10);
		seperatedScore.push(combo % 10);

		var daLoop:Int = 0;
		var xThing:Float = 0;
		if (showCombo)
			comboGroup.add(comboSpr);
		if (!ClientPrefs.data.comboStacking)
		{
			if (lastCombo != null) lastCombo.kill();
			lastCombo = comboSpr;
		}
		if (lastScore != null)
		{
			while (lastScore.length > 0)
			{
				lastScore[0].kill();
				lastScore.remove(lastScore[0]);
			}
		}

		for (i in seperatedScore)
		{
			var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'num' + Std.int(i) + (((ratingPercent == 1 || cpuControlled) && SONG.song != "Cycled Sins") ? (SONG.song == "Malfunction" ? '-malgold' : '-gold') : (SONG.song == "Malfunction" ? '-mal' : '')) + pixelShitPart2));
			numScore.scale.set(0.22, 0.22);
			numScore.screenCenter();
			numScore.x = (32 * daLoop) - 90;
			numScore.x += FlxG.width * 0.92;
			numScore.y = rating.y + (SONG.song == "Malfunction" ? ((daRating.image == "sick" && ratingPercent != 1) ? 80 : 56) : 45);

			if (!ClientPrefs.data.comboStacking)
				lastScore.push(numScore);

			if (!isPixelStage)
			{
				//nothing
			}
			else
			{
				numScore.setGraphicSize(Std.int(numScore.width * daPixelZoom * 0.28));
			}
			numScore.updateHitbox();

			numScore.acceleration.y = FlxG.random.int(200, 300) * playbackRate * playbackRate;
			numScore.velocity.y -= FlxG.random.int(140, 160) * playbackRate;
			numScore.velocity.x = FlxG.random.float(-5, 5) * playbackRate;
			numScore.visible = !ClientPrefs.data.hideHud;

			//if (combo >= 10 || combo == 0)
			if(showComboNum)
				comboGroup.add(numScore);

			FlxTween.tween(numScore, {alpha: 0}, 0.2 / playbackRate, {
				onComplete: function(tween:FlxTween)
				{
					numScore.destroy();
				},
				startDelay: Conductor.crochet * 0.002 / playbackRate
			});

			daLoop++;
			if(numScore.x > xThing) xThing = numScore.x;
		}
		comboSpr.x = xThing + 50;

		coolText.text = Std.string(seperatedScore);
		// add(coolText);

		FlxTween.tween(rating, {alpha: 0}, 0.2 / playbackRate, {
			startDelay: Conductor.crochet * 0.001 / playbackRate
		});

		FlxTween.tween(comboSpr, {alpha: 0}, 0.2 / playbackRate, {
			onComplete: function(tween:FlxTween)
			{
				coolText.destroy();
				comboSpr.destroy();
				rating.destroy();
			},
			startDelay: Conductor.crochet * 0.002 / playbackRate
		});
	}

	public var strumsBlocked:Array<Bool> = [];
	private function onKeyPress(event:KeyboardEvent):Void
	{

		var eventKey:FlxKey = event.keyCode;
		var key:Int = getKeyFromEvent(keysArray, eventKey);

		if (!controls.controllerMode)
		{
			#if debug
			//Prevents crash specifically on debug without needing to try catch shit
			@:privateAccess if (!FlxG.keys._keyListMap.exists(eventKey)) return;
			#end

			if(FlxG.keys.checkStatus(eventKey, JUST_PRESSED)) keyPressed(key);
		}
	}

	private function keyPressed(key:Int)
	{
		if(cpuControlled || paused || inCutscene || key < 0 || key >= playerStrums.length || !generatedMusic || endingSong || boyfriend.stunned) return;

		var ret:Dynamic = callOnScripts('onKeyPressPre', [key]);
		if(ret == LuaUtils.Function_Stop) return;

		// more accurate hit time for the ratings?
		var lastTime:Float = Conductor.songPosition;
		if(Conductor.songPosition >= 0) Conductor.songPosition = FlxG.sound.music.time;

		// obtain notes that the player can hit
		var plrInputNotes:Array<Note> = notes.members.filter(function(n:Note):Bool {
			var canHit:Bool = !strumsBlocked[n.noteData] && n.canBeHit && n.mustPress && !n.tooLate && !n.wasGoodHit && !n.blockHit;
			return n != null && canHit && !n.isSustainNote && n.noteData == key;
		});
		plrInputNotes.sort(sortHitNotes);

		var shouldMiss:Bool = !ClientPrefs.data.ghostTapping;

		if (plrInputNotes.length != 0) { // slightly faster than doing `> 0` lol
			var funnyNote:Note = plrInputNotes[0]; // front note

			if (plrInputNotes.length > 1) {
				var doubleNote:Note = plrInputNotes[1];

				if (doubleNote.noteData == funnyNote.noteData) {
					// if the note has a 0ms distance (is on top of the current note), kill it
					if (Math.abs(doubleNote.strumTime - funnyNote.strumTime) < 1.0)
						invalidateNote(doubleNote);
					else if (doubleNote.strumTime < funnyNote.strumTime)
					{
						// replace the note if its ahead of time (or at least ensure "doubleNote" is ahead)
						funnyNote = doubleNote;
					}
				}
			}
			goodNoteHit(funnyNote);
		}
		else if(shouldMiss)
		{
			callOnScripts('onGhostTap', [key]);
			noteMissPress(key);
		}

		// Needed for the  "Just the Two of Us" achievement.
		//									- Shadow Mario
		if(!keysPressed.contains(key)) keysPressed.push(key);

		//more accurate hit time for the ratings? part 2 (Now that the calculations are done, go back to the time it was before for not causing a note stutter)
		Conductor.songPosition = lastTime;

		var spr:StrumNote = playerStrums.members[key];
		if(strumsBlocked[key] != true && spr != null && spr.animation.curAnim.name != 'confirm')
		{
			if (SONG.song == "Birthday")
				spr.scale.set(forceAutismIntoThisNoteLikeAnAverageAmericanDoctor + autism * forceAutismIntoThisNoteLikeAnAverageAmericanDoctor, forceAutismIntoThisNoteLikeAnAverageAmericanDoctor - autism * forceAutismIntoThisNoteLikeAnAverageAmericanDoctor);
			spr.playAnim('pressed');
			spr.resetAnim = 0;
		}
		callOnScripts('onKeyPress', [key]);
	}

	public static function sortHitNotes(a:Note, b:Note):Int
	{
		if (a.lowPriority && !b.lowPriority)
			return 1;
		else if (!a.lowPriority && b.lowPriority)
			return -1;

		return FlxSort.byValues(FlxSort.ASCENDING, a.strumTime, b.strumTime);
	}

	private function onKeyRelease(event:KeyboardEvent):Void
	{
		var eventKey:FlxKey = event.keyCode;
		var key:Int = getKeyFromEvent(keysArray, eventKey);
		if(!controls.controllerMode && key > -1) keyReleased(key);
	}

	private function keyReleased(key:Int)
	{
		if(cpuControlled || !startedCountdown || paused || key < 0 || key >= playerStrums.length) return;

		var ret:Dynamic = callOnScripts('onKeyReleasePre', [key]);
		if(ret == LuaUtils.Function_Stop) return;

		var spr:StrumNote = playerStrums.members[key];
		if(spr != null)
		{
			if(SONG.song == "Birthday")
				spr.scale.set(forceAutismIntoThisNoteLikeAnAverageAmericanDoctor - (autism * forceAutismIntoThisNoteLikeAnAverageAmericanDoctor / 2), forceAutismIntoThisNoteLikeAnAverageAmericanDoctor + (autism * forceAutismIntoThisNoteLikeAnAverageAmericanDoctor / 2));
			spr.playAnim('static');
			spr.resetAnim = 0;
		}
		callOnScripts('onKeyRelease', [key]);
	}

	public static function getKeyFromEvent(arr:Array<String>, key:FlxKey):Int
	{
		if(key != NONE)
		{
			for (i in 0...arr.length)
			{
				var note:Array<FlxKey> = Controls.instance.keyboardBinds[arr[i]];
				for (noteKey in note)
					if(key == noteKey)
						return i;
			}
		}
		return -1;
	}

	// Hold notes
	private function keysCheck():Void
	{
		// HOLDING
		var holdArray:Array<Bool> = [];
		var pressArray:Array<Bool> = [];
		var releaseArray:Array<Bool> = [];
		for (key in keysArray)
		{
			holdArray.push(controls.pressed(key));
			if(controls.controllerMode)
			{
				pressArray.push(controls.justPressed(key));
				releaseArray.push(controls.justReleased(key));
			}
		}

		// TO DO: Find a better way to handle controller inputs, this should work for now
		if(controls.controllerMode && pressArray.contains(true))
			for (i in 0...pressArray.length)
				if(pressArray[i] && strumsBlocked[i] != true)
					keyPressed(i);

		if (startedCountdown && !inCutscene && !boyfriend.stunned && generatedMusic)
		{
			if (notes.length > 0) {
				for (n in notes) { // I can't do a filter here, that's kinda awesome
					var canHit:Bool = (n != null && !strumsBlocked[n.noteData] && n.canBeHit
						&& n.mustPress && !n.tooLate && !n.wasGoodHit && !n.blockHit);

					canHit = canHit && n.parent != null && n.parent.wasGoodHit;

					if (canHit && n.isSustainNote) {
						var released:Bool = !holdArray[n.noteData];

						if (!released)
							goodNoteHit(n);
					}
				}
			}

			if (!holdArray.contains(true) || endingSong)
				playerDance();
		}

		// TO DO: Find a better way to handle controller inputs, this should work for now
		if((controls.controllerMode || strumsBlocked.contains(true)) && releaseArray.contains(true))
			for (i in 0...releaseArray.length)
				if(releaseArray[i] || strumsBlocked[i] == true)
					keyReleased(i);
	}

	function noteMiss(daNote:Note):Void { //You didn't hit the key and let it go offscreen, also used by Hurt Notes
		//Dupe note remove
		notes.forEachAlive(function(note:Note) {
			if (daNote != note && daNote.mustPress && daNote.noteData == note.noteData && daNote.isSustainNote == note.isSustainNote && Math.abs(daNote.strumTime - note.strumTime) < 1)
				invalidateNote(note);
		});

		noteMissCommon(daNote.noteData, daNote);
		var result:Dynamic = callOnLuas('noteMiss', [notes.members.indexOf(daNote), daNote.noteData, daNote.noteType, daNote.isSustainNote]);
		if(result != LuaUtils.Function_Stop && result != LuaUtils.Function_StopHScript && result != LuaUtils.Function_StopAll) callOnHScript('noteMiss', [daNote]);
	}

	function noteMissPress(direction:Int = 1):Void //You pressed a key when there was no notes to press for this key
	{
		if(ClientPrefs.data.ghostTapping) return; //fuck it

		noteMissCommon(direction);
		FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
		callOnScripts('noteMissPress', [direction]);
	}

	function noteMissCommon(direction:Int, note:Note = null)
	{
		// score and data
		var subtract:Float = 0.05;
		if(note != null) subtract = note.missHealth;

		// GUITAR HERO SUSTAIN CHECK LOL!!!!
		if (note != null && note.parent == null) {
			if(note.tail.length > 0) {
				note.alpha = 0.35;
				for(childNote in note.tail) {
					childNote.alpha = note.alpha;
					childNote.canBeHit = false;
					childNote.ignoreNote = true;
					childNote.tooLate = true;
				}
				note.canBeHit = false;

				//subtract += 0.385; // you take more damage if playing with this gameplay changer enabled.
				// i mean its fair :p -Crow
				subtract *= note.tail.length + 1;
				// i think it would be fair if damage multiplied based on how long the sustain is -Tahir
			}
		}
		if (note != null && note.parent != null && note.isSustainNote) {
			
			var parentNote:Note = note.parent;
			if (parentNote.wasGoodHit && parentNote.tail.length > 0) {
				for (child in parentNote.tail) if (child != note) {
					child.canBeHit = false;
					child.ignoreNote = true;
					child.tooLate = true;
				}
			}
		}

		if(instakillOnMiss)
		{
			vocals.volume = 0;
			opponentVocals.volume = 0;
			doDeathCheck(true);
		}

		combo = 0;
		healthThing -= note.missHealth * healthLoss;

		if(!practiceMode) songScore -= 10;
		if(!endingSong) songMisses++;
		totalPlayed++;
		RecalculateRating(true);

		// play character anims
		var char:Character = boyfriend;
		if((note != null && note.gfNote) || (SONG.notes[curSection] != null && SONG.notes[curSection].gfSection)) char = gf;

		if(char != null && (note == null || !note.noMissAnimation) && char.hasMissAnimations)
		{
			var suffix:String = '';
			if(note != null) suffix = note.animSuffix;

			var animToPlay:String = singAnimations[Std.int(Math.abs(Math.min(singAnimations.length-1, direction)))] + 'miss' + suffix;
			char.playAnim(animToPlay, true);

			if(spawnShadow[1] && shadowBF != null)
			{
				shadowBF.playAnim(animToPlay, true);
			}

			if(char != gf && gf != null && gf.animOffsets.exists('sad'))
			{
				gf.playAnim('sad');
				gf.specialAnim = true;
			}
		}
		vocals.volume = 0;
	}

	function opponentNoteHit(note:Note):Void
	{
		var result:Dynamic = callOnLuas('opponentNoteHitPre', [notes.members.indexOf(note), Math.abs(note.noteData), note.noteType, note.isSustainNote]);
		if(result != LuaUtils.Function_Stop && result != LuaUtils.Function_StopHScript && result != LuaUtils.Function_StopAll) callOnHScript('opponentNoteHitPre', [note]);

		opponentStrums.members[note.noteData].rgbShader.r = note.rgbShader.r;
		opponentStrums.members[note.noteData].rgbShader.g = note.rgbShader.g;
		opponentStrums.members[note.noteData].rgbShader.b = note.rgbShader.b;

		if (SONG.song == "Birthday")
			opponentStrums.members[note.noteData].scale.set(forceAutismIntoThisNoteLikeAnAverageAmericanDoctor + (autism * forceAutismIntoThisNoteLikeAnAverageAmericanDoctor / (!note.isSustainNote ? 2 : 4) + 0.12), forceAutismIntoThisNoteLikeAnAverageAmericanDoctor - (autism * forceAutismIntoThisNoteLikeAnAverageAmericanDoctor / (!note.isSustainNote ? 2 : 4) + 0.12));

		if (SONG.song != "Bless")
			camZooming = true;

		if(note.noteType == 'Hey!' && dad.animOffsets.exists('hey')) {
			dad.playAnim('hey', true);
			dad.specialAnim = true;
			dad.heyTimer = 0.6;
		} else if(!note.noAnimation) {
			var altAnim:String = note.animSuffix;

			if (SONG.notes[curSection] != null)
				if (SONG.notes[curSection].altAnim && !SONG.notes[curSection].gfSection)
					altAnim = '-alt';

			if (note.noteType == "Error Note" && SONG.song != "Malfunction Legacy") // Makes Malsquare use his alt animations when he hits error notes cause I don't wanna rechart the entire damn thing just for his alt set to be used
				altAnim = '-alt';

			var char:Character = dad;
			var animToPlay:String = singAnimations[Std.int(Math.abs(Math.min(singAnimations.length-1, note.noteData)))] + altAnim;
			if(note.gfNote) char = gf;

			if(char != null)
			{
				char.playAnim(animToPlay, true);
				char.holdTimer = 0;
			}

			if (spawnShadow[0] && shadowDad != null)
			{
				shadowDad.playAnim(animToPlay, true);
				shadowDad.holdTimer = 0;
			}
		}

		stagesFunc(function(stage:BaseStage) stage.opponentNoteHit(note));
		if(opponentVocals.length <= 0) vocals.volume = 1;
		strumPlayAnim(true, Std.int(Math.abs(note.noteData)), Conductor.stepCrochet * 1.25 / 1000 / playbackRate);
		note.hitByOpponent = true;

		var result:Dynamic = callOnLuas('opponentNoteHit', [notes.members.indexOf(note), Math.abs(note.noteData), note.noteType, note.isSustainNote]);
		if(result != LuaUtils.Function_Stop && result != LuaUtils.Function_StopHScript && result != LuaUtils.Function_StopAll) callOnHScript('opponentNoteHit', [note]);

		if (!note.isSustainNote) invalidateNote(note);
	}

	var malfunctionComboCheck:Int = 0;
	
	public function goodNoteHit(note:Note):Void
	{
		if(note.wasGoodHit) return;
		if(cpuControlled && note.ignoreNote) return;

		var isSus:Bool = note.isSustainNote; //GET OUT OF MY HEAD, GET OUT OF MY HEAD, GET OUT OF MY HEAD
		var leData:Int = Math.round(Math.abs(note.noteData));
		var leType:String = note.noteType;

		stagesFunc(function(stage:BaseStage) stage.goodNoteHit(note));
		var result:Dynamic = callOnLuas('goodNoteHitPre', [notes.members.indexOf(note), leData, leType, isSus]);
		if(result != LuaUtils.Function_Stop && result != LuaUtils.Function_StopHScript && result != LuaUtils.Function_StopAll) callOnHScript('goodNoteHitPre', [note]);

		note.wasGoodHit = true;

		playerStrums.members[note.noteData].rgbShader.r = note.rgbShader.r;
		playerStrums.members[note.noteData].rgbShader.g = note.rgbShader.g;
		playerStrums.members[note.noteData].rgbShader.b = note.rgbShader.b;
		
		if(SONG.song == "Birthday")
			playerStrums.members[note.noteData].scale.set(forceAutismIntoThisNoteLikeAnAverageAmericanDoctor + (!note.isSustainNote ? autism : autism * forceAutismIntoThisNoteLikeAnAverageAmericanDoctor / 2), forceAutismIntoThisNoteLikeAnAverageAmericanDoctor - (!note.isSustainNote ? autism : autism * forceAutismIntoThisNoteLikeAnAverageAmericanDoctor / 2));

		if (SONG.song == "Bless")
			camZooming = true;
		
		if (ClientPrefs.data.hitsoundVolume > 0 && !note.hitsoundDisabled)
		{
			FlxG.sound.play(Paths.sound('hitsound'), ClientPrefs.data.hitsoundVolume);
		}

		if(note.hitCausesMiss) {
			if(!note.noMissAnimation) {
				switch(note.noteType) {
					case 'Hurt Note': //Hurt note
						if(boyfriend.animOffsets.exists('hurt')) {
							boyfriend.playAnim('hurt', true);
							boyfriend.specialAnim = true;
						}
				}
			}

			noteMiss(note);
			if(!note.noteSplashData.disabled && !note.isSustainNote) {
				spawnNoteSplashOnNote(note);
			}
			if(!note.isSustainNote) invalidateNote(note);
			return;
		}

		if(!note.noAnimation) {
			var animToPlay:String = singAnimations[Std.int(Math.abs(Math.min(singAnimations.length-1, note.noteData)))];

			var char:Character = boyfriend;
			var animCheck:String = 'hey';
			if(note.gfNote)
			{
				char = gf;
				animCheck = 'cheer';
			}

			if(char != null)
			{
				char.playAnim(animToPlay + note.animSuffix, true);
				char.holdTimer = 0;

				if(note.noteType == 'Hey!') {
					if(char.animOffsets.exists(animCheck)) {
						char.playAnim(animCheck, true);
						char.specialAnim = true;
						char.heyTimer = 0.6;
					}
				}
			}

			if(spawnShadow[1] && shadowBF != null)
			{
				shadowBF.playAnim(animToPlay, true);
				shadowBF.holdTimer = 0;
			}
		}

		if(!cpuControlled)
		{
			var spr = playerStrums.members[note.noteData];
			if(spr != null) spr.playAnim('confirm', true);
		}
		else strumPlayAnim(false, Std.int(Math.abs(note.noteData)), Conductor.stepCrochet * 1.25 / 1000 / playbackRate);
		vocals.volume = 1;

		if (!note.isSustainNote)
		{
			combo += 1;
			if(combo > 9999) combo = 9999;
			popUpScore(note);
		}
		healthThing += note.hitHealth * 0.55;

		var result:Dynamic = callOnLuas('goodNoteHit', [notes.members.indexOf(note), leData, leType, isSus]);
		if(result != LuaUtils.Function_Stop && result != LuaUtils.Function_StopHScript && result != LuaUtils.Function_StopAll) callOnHScript('goodNoteHit', [note]);

		if(!note.isSustainNote) 
			invalidateNote(note);
	}

	public function invalidateNote(note:Note):Void {
		note.kill();
		notes.remove(note, true);
		note.destroy();
	}

	public function spawnNoteSplashOnNote(note:Note) {
		if(note != null) {
			var strum:StrumNote = playerStrums.members[note.noteData];
			if(strum != null) {
				spawnNoteSplash(strum.x, strum.y, note.noteData, note);
			}
		}
	}

	public function spawnNoteSplash(x:Float, y:Float, data:Int, ?note:Note = null) {
		var splash:NoteSplash = grpNoteSplashes.recycle(NoteSplash);
		splash.setupNoteSplash(x, y, data, note);
		grpNoteSplashes.add(splash);
	}

	override function destroy() {
		#if HSCRIPT_ALLOWED
		for (script in hscriptArray)
			if(script != null)
			{
				if(script.exists('onDestroy')) script.call('onDestroy');
				script.destroy();
			}

		hscriptArray = null;
		#end

		FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
		FlxG.animationTimeScale = 1;
		#if FLX_PITCH FlxG.sound.music.pitch = 1; #end
		ClientPrefs.data.cacheOnGPU = backupGpu;
		if (curStage == "menuSongs") 
			ClientPrefs.data.middleScroll = backupMiddlescroll;
		
		Transparency.getWindowsbackward();
		if (!FlxG.fullscreen)
		{
			FlxG.fullscreen = false;
			Lib.application.window.resize(1280, 720);
			Lib.application.window.x = Std.int((Lib.application.window.display.bounds.width - Lib.application.window.width) * 0.5);
			Lib.application.window.y = Std.int((Lib.application.window.display.bounds.height - Lib.application.window.height) * 0.5);
		}
		backend.NoteTypesConfig.clearNoteTypesData();
		spawnShadow[0] = spawnShadow[1] = spawnShadow[2] = false;
		instance = null;
		super.destroy();
	}

	var lastStepHit:Int = -1;
	override function stepHit()
	{
		if (SONG.needsVoices && FlxG.sound.music.time >= -ClientPrefs.data.noteOffset)
		{
			var timeSub:Float = Conductor.songPosition - Conductor.offset;
			var syncTime:Float = 20 * playbackRate;
			if (Math.abs(FlxG.sound.music.time - timeSub) > syncTime ||
			(vocals.length > 0 && Math.abs(vocals.time - timeSub) > syncTime) ||
			(opponentVocals.length > 0 && Math.abs(opponentVocals.time - timeSub) > syncTime))
			{
				resyncVocals();
			}
		}

		super.stepHit();

		if(curStep == lastStepHit) {
			return;
		}

		lastStepHit = curStep;
		setOnScripts('curStep', curStep);
		callOnScripts('onStepHit');
	}

	var lastBeatHit:Int = -1;

	override function beatHit()
	{
		if(lastBeatHit >= curBeat) {
			//trace('BEAT HIT: ' + curBeat + ', LAST HIT: ' + lastBeatHit);
			return;
		}

		if (generatedMusic)
			notes.sort(FlxSort.byY, ClientPrefs.data.downScroll ? FlxSort.ASCENDING : FlxSort.DESCENDING);

		// why is this even a fucking thing ???????? --- because it is jason lmao
		/*if (boyfriend.boppingIcon) iconP1.scale.set(1.2, 1.2);
		if (dad.boppingIcon) iconP2.scale.set(1.2, 1.2);*/

		// ok ok i need a plan b
		// retarded code AND untested because monthly motel shit bla bla bla
		// just know that we are NOT sonic legacy :sob:
		if (introSoundsSuffix != "-sins")
		{
			if (boyfriend.curCharacter != 'etherealMickey' || boyfriend.curCharacter != 'everett-relapse') iconP1.scale.set(1.2, 1.2);
			if (dad.curCharacter != 'white-noise-new' || dad.curCharacter != 'etherealGoofy' || dad.curCharacter != 'walt-new'
				|| dad.curCharacter != 'walt-true' || dad.curCharacter != 'relapsedNEW') iconP2.scale.set(1.2, 1.2);
		}

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		characterBopper(curBeat);

		super.beatHit();
		lastBeatHit = curBeat;

		if (canBopCam)
		{
			camGame.zoom += SONG.song == "Bless" ? 0.06 : 0.15;
			camHUD.zoom += SONG.song == "Bless" ? 0.02 : 0.1;
		}

		camGame.zoom += gameBopIntensity;
		camHUD.zoom +=  uiBopIntensity;

		setOnScripts('curBeat', curBeat);
		callOnScripts('onBeatHit');
	}

	public function characterBopper(beat:Int):Void
	{
		if (gf != null && beat % Math.round(gfSpeed * gf.danceEveryNumBeats) == 0 && !gf.getAnimationName().startsWith('sing') && !gf.stunned)
			gf.dance();
		if (boyfriend != null && beat % boyfriend.danceEveryNumBeats == 0 && !boyfriend.getAnimationName().startsWith('sing') && !boyfriend.stunned)
			boyfriend.dance();
		if (dad != null && beat % dad.danceEveryNumBeats == 0 && !dad.getAnimationName().startsWith('sing') && !dad.stunned)
			dad.dance();

		// literal shadow dancing lmfao
		if (spawnShadow[0] && shadowDad != null && beat % shadowDad.danceEveryNumBeats == 0 && !shadowDad.getAnimationName().startsWith('sing') && !dad.stunned)
			shadowDad.dance();
		if (spawnShadow[1] && shadowBF != null && beat % shadowBF.danceEveryNumBeats == 0 && !shadowBF.getAnimationName().startsWith('sing') && !shadowBF.stunned)
			shadowBF.dance();
		if (spawnShadow[2] && shadowGF != null && beat % Math.round(gfSpeed * gf.danceEveryNumBeats) == 0 && !shadowGF.getAnimationName().startsWith('sing') && !shadowGF.stunned)
			shadowGF.dance();
	}

	public function playerDance():Void
	{
		var anim:String = boyfriend.getAnimationName();
		if(boyfriend.holdTimer > Conductor.stepCrochet * (0.0011 #if FLX_PITCH / FlxG.sound.music.pitch #end) * boyfriend.singDuration && anim.startsWith('sing') && !anim.endsWith('miss'))
			boyfriend.dance();
	}

	override function sectionHit()
	{
		if (SONG.notes[curSection] != null)
		{
			if (generatedMusic && !endingSong && !isCameraOnForcedPos)
				moveCameraSection();

			if (camZooming && FlxG.camera.zoom < 1.35 && ClientPrefs.data.camZooms && SONG.song != "Cycled Sins")
			{
				FlxG.camera.zoom += 0.015 * camZoomingMult;
				camHUD.zoom += 0.03 * camZoomingMult;
			}

			if (SONG.notes[curSection].changeBPM)
			{
				Conductor.bpm = SONG.notes[curSection].bpm;
				setOnScripts('curBpm', Conductor.bpm);
				setOnScripts('crochet', Conductor.crochet);
				setOnScripts('stepCrochet', Conductor.stepCrochet);
			}
			setOnScripts('mustHitSection', SONG.notes[curSection].mustHitSection);
			setOnScripts('altAnim', SONG.notes[curSection].altAnim);
			setOnScripts('gfSection', SONG.notes[curSection].gfSection);
		}
		super.sectionHit();

		setOnScripts('curSection', curSection);
		callOnScripts('onSectionHit');
	}

	#if HSCRIPT_ALLOWED
	public function startHScriptsNamed(scriptFile:String)
	{
		var scriptToLoad:String = Paths.getSharedPath(scriptFile);

		if(FileSystem.exists(scriptToLoad))
		{
			if (Iris.instances.exists(scriptToLoad)) return false;

			initHScript(scriptToLoad);
			return true;
		}
		return false;
	}

	public function initHScript(file:String)
	{
		var newScript:HScript = null;
		try
		{
			newScript = new HScript(null, file);
			if (newScript.exists('onCreate')) newScript.call('onCreate');
			trace('initialized hscript interp successfully: $file');
			hscriptArray.push(newScript);
		}
		catch(e:IrisError)
		{
			var pos:HScriptInfos = cast {fileName: file, showLine: false};
			Iris.error(Printer.errorToString(e, false), pos);
			var newScript:HScript = cast (Iris.instances.get(file), HScript);
			if(newScript != null)
				newScript.destroy();
		}
	}
	#end

	public function callOnScripts(funcToCall:String, args:Array<Dynamic> = null, ignoreStops = false, exclusions:Array<String> = null, excludeValues:Array<Dynamic> = null):Dynamic {
		var returnVal:Dynamic = LuaUtils.Function_Continue;
		if(args == null) args = [];
		if(exclusions == null) exclusions = [];
		if(excludeValues == null) excludeValues = [LuaUtils.Function_Continue];

		var result:Dynamic = callOnLuas(funcToCall, args, ignoreStops, exclusions, excludeValues);
		if(result == null || excludeValues.contains(result)) result = callOnHScript(funcToCall, args, ignoreStops, exclusions, excludeValues);
		return result;
	}

	public function callOnLuas(funcToCall:String, args:Array<Dynamic> = null, ignoreStops = false, exclusions:Array<String> = null, excludeValues:Array<Dynamic> = null):Dynamic {
		var returnVal:Dynamic = LuaUtils.Function_Continue;
		
		return returnVal;
	}

	public function callOnHScript(funcToCall:String, args:Array<Dynamic> = null, ?ignoreStops:Bool = false, exclusions:Array<String> = null, excludeValues:Array<Dynamic> = null):Dynamic {
		var returnVal:Dynamic = LuaUtils.Function_Continue;

		#if HSCRIPT_ALLOWED
		if(exclusions == null) exclusions = new Array();
		if(excludeValues == null) excludeValues = new Array();
		excludeValues.push(LuaUtils.Function_Continue);

		var len:Int = hscriptArray.length;
		if (len < 1)
			return returnVal;

		for(script in hscriptArray)
		{
			@:privateAccess
			if(script == null || !script.exists(funcToCall) || exclusions.contains(script.origin))
				continue;

			var callValue = script.call(funcToCall, args);
			if(callValue != null)
			{
				var myValue:Dynamic = callValue.returnValue;

				if((myValue == LuaUtils.Function_StopHScript || myValue == LuaUtils.Function_StopAll) && !excludeValues.contains(myValue) && !ignoreStops)
				{
					returnVal = myValue;
					break;
				}

				if(myValue != null && !excludeValues.contains(myValue))
					returnVal = myValue;
			}
		}
		#end

		return returnVal;
	}

	public function setOnScripts(variable:String, arg:Dynamic, exclusions:Array<String> = null) {
		if(exclusions == null) exclusions = [];
		setOnHScript(variable, arg, exclusions);
	}

	public function setOnHScript(variable:String, arg:Dynamic, exclusions:Array<String> = null) {
		#if HSCRIPT_ALLOWED
		if(exclusions == null) exclusions = [];
		for (script in hscriptArray) {
			if(exclusions.contains(script.origin))
				continue;

			script.set(variable, arg);
		}
		#end
	}

	function strumPlayAnim(isDad:Bool, id:Int, time:Float) {
		var spr:StrumNote = null;
		if(isDad) {
			spr = opponentStrums.members[id];
		} else {
			spr = playerStrums.members[id];
		}

		if(spr != null) {
			spr.playAnim('confirm', true);
			spr.resetAnim = time;
		}
	}

	public var ratingName:String = '?';
	public var ratingPercent:Float;
	public var ratingFC:String;
	public function RecalculateRating(badHit:Bool = false) {
		setOnScripts('score', songScore);
		setOnScripts('misses', songMisses);
		setOnScripts('hits', songHits);
		setOnScripts('combo', combo);

		var ret:Dynamic = callOnScripts('onRecalculateRating', null, true);
		if(ret != LuaUtils.Function_Stop)
		{
			ratingName = '?';
			if(totalPlayed != 0) //Prevent divide by 0
			{
				// Rating Percent
				ratingPercent = Math.min(1, Math.max(0, totalNotesHit / totalPlayed));
				//trace((totalNotesHit / totalPlayed) + ', Total: ' + totalPlayed + ', notes hit: ' + totalNotesHit);

				// Rating Name
				ratingName = ratingStuff[ratingStuff.length-1][0]; //Uses last string
				if(ratingPercent < 1)
					for (i in 0...ratingStuff.length-1)
						if(ratingPercent < ratingStuff[i][1])
						{
							ratingName = ratingStuff[i][0];
							break;
						}
			}
			fullComboFunction();
		}
		updateScore(badHit); // score will only update after rating is calculated, if it's a badHit, it shouldn't bounce
		setOnScripts('rating', ratingPercent);
		setOnScripts('ratingName', ratingName);
		setOnScripts('ratingFC', ratingFC);
	}
}
