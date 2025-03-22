package states;

import flixel.effects.FlxFlicker;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.system.FlxSound;
import haxe.Json;
import lime.utils.Assets;
import flash.system.System;
import openfl.Lib;
import openfl.display.BlendMode;
import openfl.display.StageQuality;
import openfl.filters.BitmapFilter;
import openfl.utils.Assets as OpenFlAssets;
import flixel.group.FlxSpriteGroup;
import flixel.input.keyboard.FlxKey;
import openfl.events.KeyboardEvent;
import flixel.animation.FlxAnimationController;
import animateatlas.AtlasFrameMaker;
import lime.app.Application;
import flixel.addons.effects.FlxSkewedSprite;
import flixel.math.FlxMatrix;

#if !flash 
import openfl.filters.ShaderFilter;
#end

#if sys
import sys.FileSystem;
import sys.io.File;
#end

enum FlashType
{
	BG_FLASH;
	BG_DARK;
	CAM_FLASH_FANCY;
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
}

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

	#if (haxe >= "4.0.0")
	public var boyfriendMap:Map<String, Boyfriend> = new Map();
	public var dadMap:Map<String, Character> = new Map();
	public var gfMap:Map<String, Character> = new Map();
	public var variables:Map<String, Dynamic> = new Map();
	public var modchartTweens:Map<String, FlxTween> = new Map<String, FlxTween>();
	public var modchartSprites:Map<String, ModchartSprite> = new Map<String, ModchartSprite>();
	public var modchartTimers:Map<String, FlxTimer> = new Map<String, FlxTimer>();
	public var modchartSounds:Map<String, FlxSound> = new Map<String, FlxSound>();
	public var modchartTexts:Map<String, ModchartText> = new Map<String, ModchartText>();
	public var modchartSaves:Map<String, FlxSave> = new Map<String, FlxSave>();
	#else
	public var boyfriendMap:Map<String, Boyfriend> = new Map<String, Boyfriend>();
	public var dadMap:Map<String, Character> = new Map<String, Character>();
	public var gfMap:Map<String, Character> = new Map<String, Character>();
	public var variables:Map<String, Dynamic> = new Map<String, Dynamic>();
	public var modchartTweens:Map<String, FlxTween> = new Map();
	public var modchartSprites:Map<String, ModchartSprite> = new Map();
	public var modchartTimers:Map<String, FlxTimer> = new Map();
	public var modchartSounds:Map<String, FlxSound> = new Map();
	public var modchartTexts:Map<String, ModchartText> = new Map();
	public var modchartSaves:Map<String, FlxSave> = new Map();
	#end

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
	public static var isPixelStage:Bool = false;
	public static var SONG:SwagSong = null;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;

	public var spawnTime:Float = 2000;

	public var vocals:FlxSound;
	public var bf_vocals:FlxSound;
	public var opp_vocals:FlxSound;
	public var inst:FlxSound;

	public static var dad:Character = null;
	public static var gf:Character = null;
	public static var boyfriend:Boyfriend = null;

	public var notes:FlxTypedGroup<Note>;
	public var unspawnNotes:Array<Note> = [];
	public var eventNotes:Array<EventNote> = [];

	private var strumLine:FlxSprite;

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

	public var gfSpeed:Int = 1;
	public var healthThing:Float = 1;
	public var healthLerp:Float = 1;
	public var combo:Int = 0;

	private var healthBarBG:AttachedSprite;
	public var healthBar:FlxBar;
	var songPercent:Float = 0;

	private var timeBarBG:AttachedSprite;
	public var timeBar:FlxBar;

	public var ratingsData:Array<Rating> = [];
	public var sicks:Int = 0;
	public var goods:Int = 0;
	public var bads:Int = 0;
	public var shits:Int = 0;

	private var generatedMusic:Bool = false;
	public var endingSong:Bool = false;
	public var startingSong:Bool = false;
	private var updateTime:Bool = true;
	public static var changedDifficulty:Bool = false;
	public static var chartingMode:Bool = false;

	//Gameplay settings
	public var healthGain:Float = 1;
	public var healthLoss:Float = 1;
	public var instakillOnMiss:Bool = false;
	public var cpuControlled:Bool = false;
	public var practiceMode:Bool = false;

	public var botplaySine:Float = 0;
	public var botplayTxt:FlxText;

	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;
	public static var camHUD:FlxCamera;
	public static var camGame:FlxCamera;
	public static var camOther:FlxCamera;
	public static var camVideo:FlxCamera;
	public static var camNotes:FlxCamera;
	public static var cameraSpeed:Float = 1;

	var dialogue:Array<String> = ['blah blah blah', 'coolswag'];
	var dialogueJson:DialogueFile = null;

	var dadbattleBlack:BGSprite;
	var dadbattleLight:BGSprite;
	var dadbattleSmokes:FlxSpriteGroup;

	var halloweenBG:BGSprite;
	var halloweenWhite:BGSprite;

	var phillyLightsColors:Array<FlxColor>;
	var phillyWindow:BGSprite;
	var phillyStreet:BGSprite;
	var phillyTrain:BGSprite;
	var blammedLightsBlack:FlxSprite;
	var phillyWindowEvent:BGSprite;
	var trainSound:FlxSound;

	var phillyGlowGradient:PhillyGlow.PhillyGlowGradient;
	var phillyGlowParticles:FlxTypedGroup<PhillyGlow.PhillyGlowParticle>;

	var limoKillingState:Int = 0;
	var limo:BGSprite;
	var limoMetalPole:BGSprite;
	var limoLight:BGSprite;
	var limoCorpse:BGSprite;
	var limoCorpseTwo:BGSprite;
	var bgLimo:BGSprite;
	var grpLimoParticles:FlxTypedGroup<BGSprite>;
	var grpLimoDancers:FlxTypedGroup<BackgroundDancer>;
	var fastCar:BGSprite;

	var upperBoppers:BGSprite;
	var bottomBoppers:BGSprite;
	var santa:BGSprite;
	var heyTimer:Float;

	var bgGirls:BackgroundGirls;
	var wiggleShit:WiggleEffect = new WiggleEffect();
	var bgGhouls:BGSprite;

	var tankWatchtower:BGSprite;
	var tankGround:BGSprite;
	var tankmanRun:FlxTypedGroup<TankmenBG>;
	var foregroundSprites:FlxTypedGroup<BGSprite>;

	public var songScore:Int = 0;
	public var songHits:Int = 0;
	public var songMisses:Int = 0;
	public var scoreTxt:FlxText;
	var timeTxt:FlxText;
	var scoreTxtTween:FlxTween;

	public var videoSprite:VideoSprite;

	public static var campaignScore:Int = 0;
	public static var campaignMisses:Int = 0;
	public static var seenCutscene:Bool = false;
	public static var finishedScene:Bool = false;
	public static var deathCounter:Int = 0;

	public static var defaultCamZoom:Float = 1.05;

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
	public static var iconRPC:String = "";
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end

	//Achievement shit
	var keysPressed:Array<Bool> = [];
	var boyfriendIdleTime:Float = 0.0;
	var boyfriendIdled:Bool = false;

	// Lua shit
	public static var instance:PlayState;
	public var luaArray:Array<FunkinLua> = [];
	private var luaDebugGroup:FlxTypedGroup<DebugLuaText>;
	public var introSoundsSuffix:String = '';

	// Debug buttons
	private var debugKeysChart:Array<FlxKey>;
	private var debugKeysCharacter:Array<FlxKey>;

	// Less laggy controls
	private var keysArray:Array<Dynamic>;
	private var controlArray:Array<String>;

	var precacheList:Map<String, String> = new Map<String, String>();
	
	// stores the last judgement object
	public static var lastRating:FlxSprite;
	// stores the last combo sprite object
	public static var lastCombo:FlxSprite;
	// stores the last combo score objects in an array
	public static var lastScore:Array<FlxSprite> = [];

	public static var lowQuality:Bool = ClientPrefs.lowQuality;

	public static var camBars:FlxCamera;

	//FUNKIN.AVI V2
	var drainValue:Float = 0;
	var boundValue:Float = 0;
	//public var smoothyHealth:Float = 1; // IF YOU READ THIS ITS ONLY FOR MERCY !!
	public static var thing:Int;

	public var canaddshaders = ClientPrefs.shaders;

	public var cinematicBars:Map<String, FlxSprite> = ["top" => null, "bottom" => null];

	public var scratch:FlxSprite; // Peter Griffin: This reminds me of the time I met the Scratch cat
	public var scratchButLessVisible:FlxSprite;

	var lyricsIcon:HealthIcon;
	var lyrics:FlxTypeText;
	var lyricsTween:FlxTween;
	var iconTween:FlxTween;

	// Display Texts
	public var infoDisplay:String = CoolUtil.dashToSpace(SONG.song);
	public var diffDisplay:String = '[${CoolUtil.difficultyString}]';
	public var engineDisplay:String = '~ Episode 1 ~';

	 // Icons for Modchart Reasons
	 public var demonBFIcon:HealthIcon;
	 public var lunacyIcon:HealthIcon;
	 public var delusionalIcon:HealthIcon;
	 public var isolatedHappy:HealthIcon;
	 public var fakeBFLosingFrame:HealthIcon;
	 public var demonBFScary:HealthIcon;
   
	 // Hardcoded Devilish Deal Icon Frames
	 public var minnieIcon:HealthIcon;
	 public var satanIcon:HealthIcon;
	 public var satanIconPulse:HealthIcon;
	 public var iconPulseTween:FlxTween;
	 public var satanTween:FlxTween;

	 public var relapseIconLol:HealthIcon;

	 public var fancyBarOverlay:FlxSprite;

	 public var watermarkTxt:FlxText;
	 public var songTxt:FlxText;

	public var crashLives:FlxText;
	public var crashLivesIcon:FlxSprite;

	public var crashLivesCounter:Int = 0;

	var heartTween:FlxTween;
	var malfunctionTxt:FlxTween;

	public var waltScreenThing:FlxSprite; // idk, this is needed too for some reason
	public var inkFormWarning:FlxText;
	public var spaceBarCounter:FlxText;
	public var mercyBoostIcon:FlxSprite;
	public var limitThing:Int = 0; // Default Value

	var stageBGFlash:FlxSprite;
	var BGFlashTween:FlxTween;

	var blendFlash:FlxSprite;
	var flashTween:FlxTween;

	var skyFlash:FlxSprite;

	public static var windowTimer:FlxTimer;

	public var camHudMoves:Bool = false;
	public var fade:FlxSprite;

	public static var grayScale:FlxRuntimeShader = new FlxRuntimeShader(Shaders.grayScale, null, 120);
	public static var andromeda:FlxRuntimeShader = new FlxRuntimeShader(Shaders.andromedaVCR, null, 140);
	public static var chromZoomShader:FlxRuntimeShader = new FlxRuntimeShader(Shaders.aberration, null, 150);
	public static var chromNormalShader:FlxRuntimeShader = new FlxRuntimeShader(Shaders.aberrationDefault, null, 150);
	public static var blurShader:FlxRuntimeShader = new FlxRuntimeShader(Shaders.tiltShift, null, 120);
	public static var blurShaderHUD:FlxRuntimeShader = new FlxRuntimeShader(Shaders.tiltShift, null, 120);
	public static var bloomEffect:FlxRuntimeShader = new FlxRuntimeShader(Shaders.bloom_alt, null, 120);
	public static var dramaticCamMovement:FlxRuntimeShader = new FlxRuntimeShader(Shaders.cameraMovement, null, 150);
	public static var monitorFilter:FlxRuntimeShader = new FlxRuntimeShader(Shaders.monitorFilter, null, 140);
	public static var staticEffect:FlxRuntimeShader = new FlxRuntimeShader(Shaders.tvStatic, null, 120);
	public static var delusionalShift:FlxRuntimeShader = new FlxRuntimeShader(Shaders.delusionalShift, null, 120);
	public static var redVignette:FlxRuntimeShader = new FlxRuntimeShader(Shaders.redFromAngryBirds, null, 120);
	public static var waltStatic:FlxRuntimeShader = new FlxRuntimeShader(Shaders.vhsFilter, null, 130);
	public static var heatWaveEffect:FlxRuntimeShader = new FlxRuntimeShader(Shaders.heatWave, null, 120);
	public static var pixelizeUI:FlxRuntimeShader = new FlxRuntimeShader(Shaders.unregisteredHyperCam2Quality, null, 140);

	public static var malFreakG:FlxRuntimeShader = new FlxRuntimeShader(Shaders.freakyGlitch, null, 120);
	public static var malBG:FlxRuntimeShader = new FlxRuntimeShader(Shaders.malfunctionBGEffect, null, 120);

	public static var legacyChrom:FlxRuntimeShader = new FlxRuntimeShader(LegacyShaders.chromaticAberration, null, 120);
	public static var legacyDistort:FlxRuntimeShader = new FlxRuntimeShader(LegacyShaders.vcrDistortion, null, 120);
	public static var legacyDefaultDistort:FlxRuntimeShader = new FlxRuntimeShader(LegacyShaders.vcrDistortion, null, 120);
	public static var legacyTiltshift:FlxRuntimeShader = new FlxRuntimeShader(LegacyShaders.tiltshift, null, 120);
	public static var legacyTiltshiftHUD:FlxRuntimeShader = new FlxRuntimeShader(LegacyShaders.tiltshift, null, 120);
	public static var legacyGreyscale:FlxRuntimeShader = new FlxRuntimeShader(LegacyShaders.greyscale, null, 120);

	public var chromEffect:Float = 0.0001;
	public var blurEffect:Float = 0.0;
	public var blurHUD:Float = 0.0;
	public var staticModifer:Float = 0.0;
	public var effectRed:Float = 0.0;

	public var shaderAnim:Float = 0;

	public var blurTween:FlxTween;
	public var chromTween:FlxTween;
	public var blurHUDTween:FlxTween;
	public var staticTween:FlxTween;
	public var vignetteTween:FlxTween;
	public var offsetTwn:FlxTween;

	public var globalGradient:FlxSprite;
	public static var pauseCountEnabled:Bool = false;

	public var dodged:Bool;
	public var shootin:Bool;

	var staticSpr:FlxSprite;
	var fuckedBG:FlxSprite;
	var noSignalBG:FlxSprite;
	var noSignalLogo:FlxSprite;

	/**
	 * FUNKIN.AVI STAGE ASSETS
	 */

	 //DEVILISH DEAL
	 var gradient:FlxSprite;
	 var bg:FlxSprite;
	 var overlay:FlxSprite;

	 //MICKEY STAGE ASSETS
	 public static var colorsOrSmthElse:FlxSprite;
	 public static var floor:FlxSprite;
	 public static var stageCurtains:FlxSprite;
	 public static var stageFront:FlxSprite;
	 public static var atmosphereParticle:FlxEmitter;
	 public static var ashParticle:FlxEmitter;
	 public static var rain:FlxSprite;
	 public static var heavyRain:FlxSprite;
	 public static var tumbleWeed:FlxSprite;
	 public static var tumbleGrp:FlxTypedGroup<FlxSprite>;
	 public static var lightning:FlxSprite;
	 public static var lightningFore:FlxSprite;
	 public static var streetDaytime:FlxSprite;
	 public static var clouds:FlxSprite;
	 public static var brightSky:FlxSprite;
	 public static var streetRuins:FlxSprite;
	 public static var fakeLightOfHope:FlxSprite;
	 public static var fireThing:FlxSprite;
	 public static var fireThing2:FlxSprite; // what the fuck what the fuck what the fuck what the fuck what the fuck what the fuck
	 public static var fireForeground:FlxSprite;
	 public static var fireTweenHandler:FlxTween;
	 public static var rainTween:FlxTween;
	 public static var fireParticle:FlxEmitter;
	 public var mickeySpirit:Character;
	 public static var smokeShit:FlxTypedGroup<FlxSprite>;
	 public static var smokeFore:FlxTypedGroup<FlxSprite>;
	 public static var spriteShit:Array<String> = ['smokeBBack', 'smokeTBack'];
	 public static var spriteShitForeground:Array<String> = ['smokeBFore', 'smokeTFore'];
	 public static var pathway:String = 'favi/stages/' + curStage + '/images/';
	  
	// Mickey being delusional and minnie appearing Scene For Delusional aaaa
	  public static var minnieBackground:FlxSprite; 
	  public static var totallyanoriginalname:FlxSprite; // .. i have no idea what to say
	   

	//HUNTED FNF
	var wobblyBG:FlxRuntimeShader = new FlxRuntimeShader(Shaders.acidTrip, null, 120);
	var treesFront:FlxSprite;
	var goofyStreet:FlxSprite;
	var treesBack:FlxSprite;
	var otherBack:FlxSprite;
	var goofyBG:FlxSprite;

	//WAR DILEMMA
	var defaultPath:String = 'favi/stages/war/stuff/';

	//LAUGH TRACK
	var circusPath:String = 'favi/stages/circus/e/';

	//BLESS
	var chains:FlxSprite;
	var vault:FlxSprite;
	var thingy:FlxSprite;
	var chains2:FlxSprite;
	var chains3:FlxSprite;
	var light:FlxSprite;
	var flair:FlxSprite;
	var chainsI:FlxSprite;
	var vaultI:FlxSprite;
	var thingyI:FlxSprite;
	var chainsI2:FlxSprite;
	var chainsI3:FlxSprite;
	var lightI:FlxSprite;
	var flairI:FlxSprite;

	//NEGLECTION
	var mascotRoom:FlxSprite;
	var mascotRoomPOV:FlxSprite;

	// MID-SONG VIDEO SCENES
	var death:VideoSprite;
	var devilishGaming:VideoSprite;
	var deluSing:VideoSprite;
	var lununuIntro:VideoSprite;
	var episodeIntro:VideoSprite;
	var isolatedIntro:VideoSprite;
	var minnieJumpscare:VideoSprite;
	var deluOutro:VideoSprite;

	var skipSceneTxt:FlxText;
    var skipDial:FlxPieDial;
    var skipLerp:Float = 0.0;
    var skipTmr:FlxTimer;
	var canSkip:Bool = false;

	//MALFUNCTION
	var mickeyEmitter:FlxEmitter;
	var fuckingsquares:FlxSprite;
	var whiteBG:FlxSprite;
	var glitchBG:FlxRuntimeShader;
	var staticBG:FlxRuntimeShader;
	var accessPath:String;

	//MERCY
	var pissOfGlory:FlxSprite;
	var greaterPiss:FlxSprite;

	var retardedButPissBehind:FlxSprite;
	var sameAsAdobe:FlxSprite;
	var waltGoop:FlxSprite;

	//DELUTRANCE SHADER LMFAO
	var totallyAwsomeShader:FlxRuntimeShader;

	//OLD CYCLED SINS
	var bg1:FlxSprite;
	var bg2:FlxSprite;

	//RELAPSE GIMMICK
	var dodgeWarning:FlxSprite;

	//SCRAPPED
	var datTV:FlxSprite;
	var redGradThing:FlxSprite = new FlxSprite(-1200, 0).makeGraphic(FlxG.width, 1, 0xFFAA00AA);
	var canZoom:Bool = false;

	// BIRTHDAY NOTES
	// you welcome
	var spawnNotes:Map<String, Bool> = [
		"muckney" => false,
		"bf" => false
	];

	var relapseEndNotes:Array<String> = [
		"ah",
		"eh",
		"ah",
		"eh",
		"oo",
		"o",
		"o",
		"ah",
		"ehh",
		"ooo",
		"ahh",
		"eee",
		"ah",
		"ah",
		"e",
		"ah",
		"ah",
		"ah",
		"ee",
		"o",
		"eh",
		"o",
		"e",
		"oh",
		"e",
		"oh",
		"e",
		"ah",
		"ehh",
		"ahh",
		"ahh",
		"ee",
		"ohhh"
	];

	var sinsEnd:Bool = false;

	//SHADER UPDATE SHIT
	var updateShader:Float = 0;

	var curEpisode:String;

	public static var windowName:String = "";

	public var foreground:FlxTypedGroup<FlxBasic>;

	// SHADER FOR BLESS ONLY CUZ IM DUMBASS - MalyPlus
	var othershader:FlxRuntimeShader = new FlxRuntimeShader(Shaders.blessLightsShit);

	override public function create()
	{
		//trace('Playback Rate: ' + playbackRate);
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		// for lua
		instance = this;

		debugKeysChart = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_1'));
		debugKeysCharacter = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_2'));
		PauseSubState.songName = null; //Reset to default
		playbackRate = ClientPrefs.getGameplaySetting('songspeed', 1);

		keysArray = [
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_left')),
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_down')),
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_up')),
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_right'))
		];

		controlArray = [
			'NOTE_LEFT',
			'NOTE_DOWN',
			'NOTE_UP',
			'NOTE_RIGHT'
		];

		//Ratings
		ratingsData.push(new Rating('sick')); //default rating

		var rating:Rating = new Rating('good');
		rating.ratingMod = 0.7;
		rating.score = 200;
		rating.noteSplash = false;
		ratingsData.push(rating);

		var rating:Rating = new Rating('bad');
		rating.ratingMod = 0.4;
		rating.score = 100;
		rating.noteSplash = false;
		ratingsData.push(rating);

		var rating:Rating = new Rating('shit');
		rating.ratingMod = 0;
		rating.score = 50;
		rating.noteSplash = false;
		ratingsData.push(rating);

		// For the "Just the Two of Us" achievement
		for (i in 0...keysArray.length)
		{
			keysPressed.push(false);
		}

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		// Gameplay settings
		healthGain = ClientPrefs.getGameplaySetting('healthgain', 1);
		healthLoss = ClientPrefs.getGameplaySetting('healthloss', 1);
		instakillOnMiss = ClientPrefs.getGameplaySetting('instakill', false);
		practiceMode = ClientPrefs.getGameplaySetting('practice', false);
		cpuControlled = ClientPrefs.getGameplaySetting('botplay', false);

		// var gameCam:FlxCamera = FlxG.camera;
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camNotes = new FlxCamera();
		camBars = new FlxCamera();
		camVideo = new FlxCamera();
		camOther = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		camNotes.bgColor.alpha = 0;
		camBars.bgColor.alpha = 0;
		camVideo.bgColor.alpha = 0;
		camOther.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camVideo, false);
		FlxG.cameras.add(camBars, false);
		FlxG.cameras.add(camHUD, false);
		FlxG.cameras.add(camNotes, false);
		FlxG.cameras.add(camOther, false);
		grpNoteSplashes = new FlxTypedGroup<NoteSplash>();

		FlxG.cameras.setDefaultDrawTarget(camGame, true);
		CustomFadeTransition.nextCamera = camOther;

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial');

		Conductor.mapBPMChanges(SONG);
		Conductor.bpm = (SONG.bpm);

		pixelizeUI.setFloat('size', 5);

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
		storyDifficultyText = CoolUtil.difficulties[storyDifficulty];

		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		if (isStoryMode)
		{
			detailsText = "Episode 1 - " + SONG.song + " (" + FreeplayState.getDiffRank() + ")";
		}
		else
		{
			detailsText = "Freeplay - " + SONG.song + " (" + FreeplayState.getDiffRank() + ")";
		}

		// String for when the game is paused
		detailsPausedText = "Paused - " + detailsText;
		#end

		GameOverSubstate.resetVariables();
		var songName:String = Paths.formatToSongPath(SONG.song);

		curStage = SONG.stage;
		//trace('stage is: ' + curStage);
		if(SONG.stage == null || SONG.stage.length < 1) {
			switch (songName)
			{
				case 'spookeez' | 'south' | 'monster':
					curStage = 'spooky';
				case 'pico' | 'blammed' | 'philly' | 'philly-nice':
					curStage = 'philly';
				case 'milf' | 'satin-panties' | 'high':
					curStage = 'limo';
				case 'cocoa' | 'eggnog':
					curStage = 'mall';
				case 'winter-horrorland':
					curStage = 'mallEvil';
				case 'senpai' | 'roses':
					curStage = 'school';
				case 'thorns':
					curStage = 'schoolEvil';
				case 'ugh' | 'guns' | 'stress':
					curStage = 'tank';
				default:
					curStage = 'stage';
			}
		}
		SONG.stage = curStage;

		pathway = 'favi/stages/' + curStage + (SONG.song == "Malfunction" ? '/stupidShit/' : '/images/');
		if (SONG.song == "Cycled Sins")
			daPixelZoom = 5;
		else
			daPixelZoom = 6;

		var stageData:StageFile = StageData.getStageFile(curStage);
		if(stageData == null) { //Stage couldn't be found, create a dummy stage for preventing a crash
			stageData = {
				directory: "",
				defaultZoom: 0.9,
				isPixelStage: false,

				boyfriend: [770, 100],
				girlfriend: [400, 130],
				opponent: [100, 100],
				hide_girlfriend: false,

				camera_boyfriend: [0, 0],
				camera_opponent: [0, 0],
				camera_girlfriend: [0, 0],
				camera_speed: 1
			};
		}

		defaultCamZoom = stageData.defaultZoom;
		isPixelStage = stageData.isPixelStage;
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

		foreground = new FlxTypedGroup<FlxBasic>();

		lowQuality = ClientPrefs.lowQuality; //updates it now I think

		if (curStage != "waltRoom") healthThing = 0.5;

		switch (curStage)
		{
			case 'stage': //Week 1
				var bg:BGSprite = new BGSprite('stageback', -600, -200, 0.9, 0.9);
				add(bg);

				var stageFront:BGSprite = new BGSprite('stagefront', -650, 600, 0.9, 0.9);
				stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
				stageFront.updateHitbox();
				add(stageFront);
				if(!ClientPrefs.lowQuality) {
					var stageLight:BGSprite = new BGSprite('stage_light', -125, -100, 0.9, 0.9);
					stageLight.setGraphicSize(Std.int(stageLight.width * 1.1));
					stageLight.updateHitbox();
					add(stageLight);
					var stageLight:BGSprite = new BGSprite('stage_light', 1225, -100, 0.9, 0.9);
					stageLight.setGraphicSize(Std.int(stageLight.width * 1.1));
					stageLight.updateHitbox();
					stageLight.flipX = true;
					add(stageLight);

					var stageCurtains:BGSprite = new BGSprite('stagecurtains', -500, -300, 1.3, 1.3);
					stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
					stageCurtains.updateHitbox();
					add(stageCurtains);
				}
				dadbattleSmokes = new FlxSpriteGroup(); //troll'd

			case 'abandonedStreet':
					defaultCamZoom = 0.87;
					cameraSpeed = 1;
					
					colorsOrSmthElse = new FlxSprite(-990, 1600).loadGraphic(Paths.image(pathway + 'randomColors'));
					colorsOrSmthElse.setGraphicSize(Std.int(colorsOrSmthElse.width * 4));
					colorsOrSmthElse.updateHitbox();
					colorsOrSmthElse.antialiasing = ClientPrefs.globalAntialiasing;
					colorsOrSmthElse.screenCenter();
					colorsOrSmthElse.scale.set(3, 3);
					colorsOrSmthElse.scrollFactor.set(0.9, 0.9);
					colorsOrSmthElse.active = false;
					add(colorsOrSmthElse);
	
					if (!lowQuality)
					{
						fireThing = new FlxSprite(0, -80);
						fireThing.scale.set(5.85, 3);
						fireThing.alpha = 0.0001;
						fireThing.antialiasing = ClientPrefs.globalAntialiasing;
						fireThing.frames = Paths.getSparrowAtlas(pathway + 'delusional-fire');
						fireThing.animation.addByPrefix('burning', 'delusional-fire fire-idle', 16, true);
						fireThing.scrollFactor.set(0.8, 0.8);
						add(fireThing);
						fireThing.animation.play('burning');
					}
					
					floor = new FlxSprite(-20, 200).loadGraphic(Paths.image(pathway + 'street'));
					floor.antialiasing = ClientPrefs.globalAntialiasing;
					floor.scale.set(2.8, 2.5);
					floor.scrollFactor.set(1, 1);
					floor.active = false;
					add(floor);	
	
					if (SONG.song == 'Delusional' || SONG.song == 'Delusion')
					{	
						fakeLightOfHope = new FlxSprite(-990, 1600).loadGraphic(Paths.image(pathway + 'falseHope'));
						fakeLightOfHope.setGraphicSize(Std.int(fakeLightOfHope.width * 4));
						fakeLightOfHope.updateHitbox();
						fakeLightOfHope.antialiasing = ClientPrefs.globalAntialiasing;
						fakeLightOfHope.screenCenter();
						fakeLightOfHope.scale.set(3, 3);
						fakeLightOfHope.scrollFactor.set(0.9, 0.9);
						add(fakeLightOfHope);
						
						if (!lowQuality)
						{
							fireThing2 = new FlxSprite(0, -80);
							fireThing2.scale.set(5.85, 3);
							fireThing2.alpha = 0.0001;
							fireThing2.frames = Paths.getSparrowAtlas(pathway + 'delusional-fire');
							fireThing2.animation.addByPrefix('burning', 'delusional-fire fire-idle', 16, true);
							fireThing2.scrollFactor.set(0.8, 0.8);
							fireThing2.antialiasing = ClientPrefs.globalAntialiasing;
							fireThing2.blend = ADD;
							add(fireThing2);
							fireThing2.animation.play('burning');

							lightning = new FlxSprite(-25, -175);
							lightning.frames = Paths.getSparrowAtlas(pathway + "lightning");
							lightning.antialiasing = ClientPrefs.globalAntialiasing;
							lightning.animation.addByPrefix('boom', 'lightning1', 12);
							lightning.animation.addByPrefix('boom2', 'lightning2', 12);
							lightning.scale.set(2, 2);
							lightning.scrollFactor.set(0.8, 0.8);
							add(lightning);
						}

						mickeySpirit = new Character(-200, -700, "avier-bg");
						mickeySpirit.alpha = 0.0001;
						add(mickeySpirit);
	
						streetRuins = new FlxSprite(-20, 200).loadGraphic(Paths.image(pathway + 'streetDestroyed'));
						streetRuins.antialiasing = ClientPrefs.globalAntialiasing;
						streetRuins.scale.set(2.8, 2.5);
						streetRuins.scrollFactor.set(1, 1);
						add(streetRuins);

						// Bedroom Grah :fire: - MalyPlus
						minnieBackground = new FlxSprite(-20, 200).loadGraphic(Paths.image(pathway + 'background'));
						minnieBackground.scale.set(2,2);
						minnieBackground.scrollFactor.set(1, 1);
						minnieBackground.antialiasing = ClientPrefs.globalAntialiasing;
						minnieBackground.visible = false;
						add(minnieBackground);

						totallyanoriginalname = new FlxSprite(-20, 200).loadGraphic(Paths.image(pathway + 'shading'));
						totallyanoriginalname.scale.set(2,2);
						totallyanoriginalname.scrollFactor.set(1,1);
						totallyanoriginalname.visible = false;
						totallyanoriginalname.antialiasing = ClientPrefs.globalAntialiasing;
						add(totallyanoriginalname);

	
						if (!lowQuality)
						{
							smokeShit = new FlxTypedGroup();
							add(smokeShit);
	
							for (i in 0...spriteShit.length)
							{
								var smoke:FlxBackdrop = new FlxBackdrop(Paths.image(pathway + spriteShit[i]), X, 0, 0);
								smoke.ID = i;
								smoke.x = -20;
								smoke.y = 200;
								smoke.scale.set(2.8, 2.5);
								smoke.scrollFactor.set(1.2, 1.1);
								smoke.alpha = 0.001;
								smoke.antialiasing = ClientPrefs.globalAntialiasing;
								switch (smoke.ID)
								{
									case 0: smoke.velocity.set(-160, 0);
									case 1: smoke.velocity.set(160, 0);
								}
								smokeShit.add(smoke);
							}
						}
					}

					tumbleGrp = new FlxTypedGroup();
					foreground.add(tumbleGrp);

					if (SONG.song == 'Delusional' || SONG.song == 'Delusion')
					{	
						if (!lowQuality)
						{
							smokeFore = new FlxTypedGroup();
							foreground.add(smokeFore);
	
							for (i in 0...spriteShitForeground.length)
							{
								var smoke:FlxBackdrop = new FlxBackdrop(Paths.image(pathway + spriteShitForeground[i]), X, 0, 0);
								smoke.ID = i;
								smoke.x = -20;
								smoke.y = 200;
								smoke.scale.set(2.8, 2.5);
								smoke.scrollFactor.set(1.55, 1.32);
								smoke.alpha = 0.001;
								smoke.antialiasing = ClientPrefs.globalAntialiasing;
								switch (smoke.ID)
								{
									case 0: smoke.velocity.set(230, 0);
									case 1: smoke.velocity.set(-230, 0);
								}
								smokeFore.add(smoke);
							}

							lightningFore = new FlxSprite(-60, -90);
							lightningFore.frames = Paths.getSparrowAtlas(pathway + "lightning");
							lightningFore.animation.addByPrefix('boom', 'lightning1', 12);
							lightningFore.animation.addByPrefix('boom2', 'lightning2', 12);
							lightningFore.scale.set(2.45, 2.45);
							lightningFore.scrollFactor.set(1.32, 1.32);
							lightningFore.antialiasing = ClientPrefs.globalAntialiasing;
							foreground.add(lightningFore);
	
							fireForeground = new FlxSprite(0, 550);
							fireForeground.scale.set(7.8, 5);
							fireForeground.alpha = 0.001;
							fireForeground.frames = Paths.getSparrowAtlas(pathway + 'delusional-fire');
							fireForeground.animation.addByPrefix('burningShit', 'delusional-fire fire-idle', 16, true);
							fireForeground.scrollFactor.set(1.35, 1.18);
							fireForeground.antialiasing = ClientPrefs.globalAntialiasing;
							fireForeground.blend = ADD;
							foreground.add(fireForeground);
							fireForeground.animation.play('burningShit');
	
							/*fireParticle = new FlxEmitter(-2080.5, 2150.4);
							fireParticle.launchMode = 'square';
							fireParticle.velocity.set(-50, -200, 50, -600, -90, 0, 90, -600);
							fireParticle.scale.set(4, 4, 4, 4, 0, 0, 0, 0);
							fireParticle.drag.set(0, 0, 0, 0, 5, 5, 10, 10);
							fireParticle.width = 4787.45;
							fireParticle.alpha.set(1, 1);
							fireParticle.lifespan.set(1.9, 4.9);
							fireParticle.loadParticles(Paths.image('fireParticle'), 500, 16, true);
							fireParticle.start(false, FlxG.random.float(.0521, .1060), 1000000);
							foreground.add(fireParticle);*/
						}
						streetRuins.visible = false;
					}
					
					if(!lowQuality)
						{
							stageCurtains = new FlxSprite(0, 0).loadGraphic(Paths.image(pathway + 'i_forgor'));
							stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
							stageCurtains.updateHitbox();
							stageCurtains.screenCenter();
							stageCurtains.scale.set(1.3,1.3);
							stageCurtains.antialiasing = ClientPrefs.globalAntialiasing;
							stageCurtains.cameras = [camOther];
							stageCurtains.scrollFactor.set(1.3, 1.3);
							add(stageCurtains);	
	
							atmosphereParticle = new FlxEmitter(-2080.5, 2000);
							atmosphereParticle.launchMode = SQUARE;
							atmosphereParticle.velocity.set(-50, -200, 50, -600, -90, 0, 90, -600);
							atmosphereParticle.scale.set(4, 4, 4, 4, 0, 0, 0, 0);
							atmosphereParticle.drag.set(0, 0, 0, 0, 5, 5, 10, 10);
							atmosphereParticle.width = 4787.45;
							atmosphereParticle.alpha.set(1, 0.3);
							atmosphereParticle.lifespan.set(1.9, 4.9);
							atmosphereParticle.loadParticles(Paths.image(pathway + 'dustParticle'), 500, 16, true);
							atmosphereParticle.start(false, FlxG.random.float(.0521, .1060), 1000000);
							foreground.add(atmosphereParticle);
	
							ashParticle = new FlxEmitter(-2080.5, 2150.4);
							for (i in 0 ... 100)
								{
									var blackParticle = new FlxParticle();
									blackParticle.frames = Paths.getSparrowAtlas(pathway + 'ashParticle');
									blackParticle.animation.addByPrefix('idle', 'ashParticle idle', 5, true);
									blackParticle.animation.play('idle');
									blackParticle.antialiasing = ClientPrefs.globalAntialiasing;
									blackParticle.exists = false;
									//blackParticle.animation.curAnim.curFrame = FlxG.random.int(0, 9);
									ashParticle.add(blackParticle);
								}
							ashParticle.launchMode = SQUARE;
							ashParticle.velocity.set(-50, -200, 50, -600, -90, 0, 90, -600);
							ashParticle.scale.set(4, 4, 4, 4, 0, 0, 0, 0);
							ashParticle.drag.set(0, 0, 0, 0, 5, 5, 10, 10);
							ashParticle.width = 4787.45;
							ashParticle.alpha.set(1, 1);
							ashParticle.lifespan.set(1.9, 4.9);
							ashParticle.start(false, FlxG.random.float(.0521, .1060), 1000000);
							ashParticle.angle.set(290, 0);
							ashParticle.launchAngle.set(0, 280);
							foreground.add(ashParticle);
	
							stageFront = new FlxSprite(-3000, 130).loadGraphic(Paths.image(pathway + 'cables'));
							stageFront.scale.set(9, 2.1);
							stageFront.updateHitbox();
							stageFront.antialiasing = ClientPrefs.globalAntialiasing;
							stageFront.scrollFactor.set(2.3, 1.7);
							stageFront.active = false;
							foreground.add(stageFront);

							if (SONG.song == "Delusional")
								stageFront.y -= 250;
							
							rain = new FlxSprite(-550, -900);
							rain.frames = Paths.getSparrowAtlas(pathway + 'rain');
							rain.animation.addByPrefix('drippin', 'Rain', 30, true);
							rain.scale.set(2, 2);
							rain.antialiasing = ClientPrefs.globalAntialiasing;
							rain.alpha = 0.0001;
							rain.animation.play('drippin');
							foreground.add(rain);

							heavyRain = new FlxSprite(-550, -900);
							heavyRain.frames = Paths.getSparrowAtlas(pathway + 'heavyRain');
							heavyRain.animation.addByPrefix('god is pissing omg', 'Rain full', 30, true);
							heavyRain.scale.set(2, 2);
							heavyRain.antialiasing = ClientPrefs.globalAntialiasing;
							heavyRain.alpha = 0.0001;
							heavyRain.animation.play('god is pissing omg');
							foreground.add(heavyRain);
	
							if (SONG.song == 'Delusion')
							{
								streetDaytime.visible = true;
								clouds.visible = true;
								brightSky.visible = true;
							}
	
							if (SONG.song == 'Delusional') stageFront.alpha = 0.001;
						}
	
						if (SONG.song == 'Delusional') {
							camBars.fade(0x000000, .0001);
						}
				case 'forestNew':
					// Literally what Goofy is seeing right about now lmfao
					wobblyBG.setFloat('uSpeed', 1.0);
					wobblyBG.setFloat('uFrequency', 1.0);
					wobblyBG.setFloat('uWaveAmplitude', 0.5);

					cameraSpeed = 0.9;
					defaultCamZoom = 0.65;
	
					if(!lowQuality)
						{
							goofyBG = new FlxSprite(-600, -450).loadGraphic(Paths.image(pathway + 'actualNew/sky'));
							goofyBG.scrollFactor.set(0.7, 0.7);
							goofyBG.screenCenter();
							add(goofyBG);
						}
	
					otherBack = new FlxSprite(-600, -450).loadGraphic(Paths.image(pathway + 'actualNew/bushes'));
					otherBack.scale.set(1.3, 1.2);
					add(otherBack);
	
					treesBack = new FlxSprite(-600, -450).loadGraphic(Paths.image(pathway + 'actualNew/treesBG'));
					treesBack.scrollFactor.set(1, 0.8);
					add(treesBack);
	
					goofyStreet = new FlxSprite(-600, -450).loadGraphic(Paths.image(pathway + 'actualNew/road'));
					goofyStreet.scrollFactor.set(1, 1);
					add(goofyStreet);
	
					if(!lowQuality)
						{
							treesFront = new FlxSprite(-600, -450).loadGraphic(Paths.image(pathway + 'actualNew/treesFG'));
							treesFront.scrollFactor.set(1.2, 1.2);
						}
				case 'forestOld':
					//spawnGirlfriend = false;
	
					var forest:FlxSprite = new FlxSprite(-180, -350).loadGraphic(Paths.image('favi/stages/forestOld/forest'));
					add(forest);
				case 'theLoop':
					//spawnGirlfriend = false;
					defaultCamZoom = 0.85;
				
					var street:FlxSprite = new FlxSprite(-500, -700).loadGraphic(Paths.image(pathway + 'Mickeybg'));
					add(street);
				
					if(!lowQuality)
						{
							var grainstuff:FlxSprite = new FlxSprite(0, 0);
							grainstuff.frames = Paths.getSparrowAtlas('favi/filters/Grainshit');
							grainstuff.animation.addByPrefix('yucky', 'grains 1', 24, true);
							grainstuff.animation.play('yucky');
							grainstuff.cameras = [camHUD];
							grainstuff.scale.set(3, 3);
							grainstuff.screenCenter();
							add(grainstuff);
						}
				case 'war':
					defaultCamZoom = .6;
					cameraSpeed = .67;
				
					var sky = new FlxSprite(-1280 * defaultCamZoom, -720 * defaultCamZoom, Paths.image(defaultPath + 'sky'));
					sky.scrollFactor.set(.07, .05);
					add(sky);
				
					if (!lowQuality)
					{
						var sun = new FlxSprite(-1280 * defaultCamZoom, -720 * defaultCamZoom, Paths.image(defaultPath + 'sun'));
						sun.scrollFactor.set(.22, .12);
						sun.y += 200;
						add(sun);
					
						var bg = new FlxSprite(-1280 * defaultCamZoom, -720 * defaultCamZoom, Paths.image(defaultPath + 'bg'));
						bg.scrollFactor.set(.32, .27);
						bg.x += 150;
						bg.y += 250;
						add(bg);
					
						var semibg = new FlxSprite(-1280 * defaultCamZoom, -720 * defaultCamZoom, Paths.image(defaultPath + 'semibackground'));
						semibg.scrollFactor.set(.52, .48);
						semibg.scale.set(1.23, 1.23);
						semibg.updateHitbox();
						add(semibg);
					}
				
					var things = new FlxSprite(-1280 * defaultCamZoom, (-720 * defaultCamZoom) + 150, Paths.image(defaultPath + 'things'));
					things.scrollFactor.set(.73, .64);
					things.scale.set(1.25, 1.25);
					things.updateHitbox();
					add(things);

					if (!lowQuality)
					{
						var grassBack = new FlxSprite(-1280 * defaultCamZoom, -720 * defaultCamZoom, Paths.image(defaultPath + "groundBack"));
						grassBack.scrollFactor.set(.86, .76);
						grassBack.scale.set(1.3, 1.3);
						grassBack.y += 70;
						grassBack.updateHitbox();
						add(grassBack);
					}
				
					var ground = new FlxSprite(-1280 * defaultCamZoom, -720 * defaultCamZoom, Paths.image(defaultPath + 'ground'));
					ground.scrollFactor.set(1, 1);
					ground.scale.set(1.35, 1.35);
					ground.updateHitbox();
					add(ground);

					if (!lowQuality)
					{
						var goofy = new FlxSprite(-1280 * defaultCamZoom, -720 * defaultCamZoom, Paths.image(defaultPath + "goofySpot"));
						goofy.scrollFactor.set(1, 1);
						goofy.scale.set(1.35, 1.35);
						goofy.updateHitbox();
						add(goofy);

						var mickey = new FlxSprite(-1280 * defaultCamZoom, -720 * defaultCamZoom, Paths.image(defaultPath + "mickeySpot"));
						mickey.scrollFactor.set(1, 1);
						mickey.scale.set(1.35, 1.35);
						mickey.updateHitbox();
						add(mickey);
						
						var fore = new FlxSprite(-1280 * defaultCamZoom, -720 * defaultCamZoom, Paths.image(defaultPath + "grassFore"));
						fore.scale.set(1.4, 1.4);
						fore.scrollFactor.set(1.15, 1.15);
						fore.y -= 180;
						fore.x -= 80;
						fore.updateHitbox();
						foreground.add(fore);
					}

				case 'circus' | 'my name is caine and welcome to the amazing digital circus':
					defaultCamZoom = 2.1;
	
					var sky = new FlxSprite(-1280 * .25,  -720 * .2, Paths.image(circusPath + 'sky'));
					sky.scrollFactor.set(.05, .05);
					sky.scale.set(.75, .75);
					sky.updateHitbox();
					add(sky);
				
					var floor = new FlxSprite(-1280, -720, Paths.image(circusPath + 'floor'));
					floor.scale.set(1.1, 1.1);
					add(floor);
				
					var tent = new FlxSprite(-1280, -720, Paths.image(circusPath + 'tent'));
					add(tent);
					
					var tentsfront = new FlxSprite(-1280 * 1.2, -720, Paths.image(circusPath + 'tentsfront'));
					tentsfront.scrollFactor.set(1.25, 1.25);
					tentsfront.scale.set(1.15, 1.15);
					foreground.add(tentsfront);
				case 'treasureIsland':
					//spawnGirlfriend = false;
	
					mascotRoom = new FlxSprite(0, 0).loadGraphic(Paths.image(pathway + "mascotRoom"));
					mascotRoom.scale.set(1.4, 1.4);
					add(mascotRoom);
	
					mascotRoomPOV = new FlxSprite(-500, 0).loadGraphic(Paths.image(pathway + "mascotRoomPOV"));
					mascotRoomPOV.scale.set(1.4, 1.4);
					mascotRoomPOV.alpha = 0.0001;
					add(mascotRoomPOV);
				case 'clubhouse':
					defaultCamZoom = 1.25;
					cameraSpeed = 50;
	
					var clubhouse:FlxSprite = new FlxSprite(-470, -150).loadGraphic(Paths.image(pathway + 'clubhouse'));
					add(clubhouse);

					if (!ClientPrefs.lowQuality)
					{
						var ballon1 = new FlxSprite(-250, -310);
						ballon1.frames = Paths.getSparrowAtlas(pathway + "Balloon_assets");
						ballon1.animation.addByPrefix("bop", "idle", 24, true);
						ballon1.animation.play("bop");
						add(ballon1);

						var ballon2 = new FlxSprite(350, -310);
						ballon2.frames = Paths.getSparrowAtlas(pathway + "Balloon_assets");
						ballon2.animation.addByPrefix("bop", "idle", 24, true);
						ballon2.animation.play("bop");
						add(ballon2);

						for (i in [ballon1, ballon2])
						{
							i.scale.set(0.45, 0.45);
							i.y -= 280; // i got lazy
						}

						var banners = new FlxSprite(-480, -110).loadGraphic(Paths.image(pathway + "birthdayBanners"));
						banners.scrollFactor.set(1.2, 1.2);
						foreground.add(banners);

						var foreObj = new FlxSprite(-470, -400).loadGraphic(Paths.image(pathway + 'foreBG'));
						foreObj.scrollFactor.set(1.4, 1.4);
						foreground.add(foreObj);
					}
	
					var vignette:FlxSprite = new FlxSprite(-250, -140).loadGraphic(Paths.image(pathway + 'vignetteOverlay'));
					vignette.cameras = [camOther];
					vignette.scale.set(0.75, 0.75);
					vignette.antialiasing = true;
					vignette.scrollFactor.set();
					vignette.active = false;
					add(vignette);
				case 'desktop':
					defaultCamZoom = 0.9;
	
					var desktopThing:FlxSprite = new FlxSprite(-500, -100).loadGraphic(Paths.image(pathway + 'desktop'));
					desktopThing.scale.set(1.3, 1);
					add(desktopThing);
				case 'grassNation':
					isPixelStage = true;
					defaultCamZoom = 0.8;
					
					if (!lowQuality)
					{
						var white:FlxSprite = new FlxSprite().makeGraphic(FlxG.width*5, FlxG.height*5, FlxColor.WHITE);
						white.scrollFactor.set(0, 0);
						white.antialiasing = ClientPrefs.globalAntialiasing;
						white.screenCenter();
						add(white);

						var grass1:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image(pathway + 'grass4'));
						grass1.scrollFactor.set(0.45, 0.45);
						grass1.antialiasing = false;
						if (ClientPrefs.shaders && !lowQuality)
							grass1.shader = malBG;
						add(grass1);

						var grass2:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image(pathway + 'grass3'));
						grass2.scrollFactor.set(0.57, 0.57);
						grass2.antialiasing = false;
						if (ClientPrefs.shaders && !lowQuality)
							grass2.shader = malBG;
						add(grass2);

						var grass3:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image(pathway + 'grass2'));
						grass3.scrollFactor.set(0.65, 0.65);
						grass3.antialiasing = false;
						if (ClientPrefs.shaders && !lowQuality)
							grass3.shader = malBG;
						add(grass3);

						var grass4:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image(pathway + 'grass1'));
						grass4.scrollFactor.set(0.75, 0.75);
						grass4.antialiasing = false;
						if (ClientPrefs.shaders && !lowQuality)
							grass4.shader = malBG;
						add(grass4);

						var ground:FlxBackdrop = new FlxBackdrop(Paths.image(pathway + 'ground'), X, 0, 0);
						ground.antialiasing = false;
						add(ground);

						var cloudClutters:FlxBackdrop = new FlxBackdrop(Paths.image(pathway + 'cloudClutters'), X, 0, 0);
						cloudClutters.antialiasing = false;
						cloudClutters.scrollFactor.set(0.92, 0.92);
						cloudClutters.velocity.set(100, 0);
						add(cloudClutters);

						whiteBG = new FlxSprite().makeGraphic(1, 1, 0xFFFFFFFF);
						whiteBG.scale.set(FlxG.width*5, FlxG.height*5);
						whiteBG.scrollFactor.set(0, 0);
						whiteBG.screenCenter();
						whiteBG.alpha = 0.001;
						whiteBG.active = false;
						add(whiteBG);

						if (ClientPrefs.epilepsy)
						{
							fuckedBG = new FlxSprite();
							fuckedBG.frames = Paths.getSparrowAtlas(pathway + 'screenFucker/fuckedUpBG');
							fuckedBG.animation.addByPrefix('bg1', 'bg1', 24, true);
							fuckedBG.animation.addByPrefix('bg2', 'bg2', 24, true);
							fuckedBG.animation.addByPrefix('bg3', 'bg3', 24, true);
							fuckedBG.animation.addByPrefix('bg4', 'bg4', 24, true);
							fuckedBG.animation.play('bg1');
							fuckedBG.antialiasing = false;
							fuckedBG.alpha = 0.0001;
							fuckedBG.scale.set(1.75, 1.75);
							fuckedBG.x -= 250;
							fuckedBG.y += 50;
							add(fuckedBG);
						}

						var fog1:FlxBackdrop = new FlxBackdrop(Paths.image(pathway + 'fogBack'), X, 0, 0);
						fog1.antialiasing = false;
						fog1.scrollFactor.set(1.1, 1.1);
						fog1.velocity.set(87, 0);
						add(fog1);

						var fog2:FlxBackdrop = new FlxBackdrop(Paths.image(pathway + 'fogFore'), X, 0, 0);
						fog2.antialiasing = false;
						fog2.scrollFactor.set(1.32, 1.32);
						fog2.velocity.set(-173, 0);
						foreground.add(fog2);

						for (shit in [grass1, grass2, grass3, grass4, ground, cloudClutters, fog1, fog2])
						{
							shit.scale.set(1.75, 1.75);
							shit.x -= 250;
							shit.y += 50;
						}

						if (ClientPrefs.epilepsy)
						{
							noSignalBG = new FlxSprite();
							noSignalBG.frames = Paths.getSparrowAtlas(pathway + 'screenFucker/noSignalBG');
							noSignalBG.animation.addByPrefix('signal1', 'signal1', 24, true);
							noSignalBG.animation.addByPrefix('signal2', 'signal2', 24, true);
							noSignalBG.animation.addByPrefix('signal3', 'signal3', 24, true);
							noSignalBG.animation.addByPrefix('signal4', 'signal4', 24, true);
							noSignalBG.animation.play('signal1');

							staticSpr = new FlxSprite();
							staticSpr.frames = Paths.getSparrowAtlas(pathway + 'screenFucker/TVstatic');
							staticSpr.animation.addByPrefix('TVstatic idle', 'TVstatic idle', 20, true);
							staticSpr.animation.play('TVstatic idle');

							noSignalLogo = new FlxSprite().loadGraphic(Paths.image(pathway + 'screenFucker/noSignalLogo'));

							for (screenShit in [noSignalBG, staticSpr, noSignalLogo])
							{
								screenShit.cameras = [camHUD];
								screenShit.screenCenter();
								screenShit.alpha = 0.001;
								screenShit.antialiasing = false;
							}
						}
					}
					else
					{
						var white:FlxSprite = new FlxSprite().makeGraphic(FlxG.width*5, FlxG.height*5, FlxColor.WHITE);
						white.scrollFactor.set(0, 0);
						white.antialiasing = ClientPrefs.globalAntialiasing;
						white.screenCenter();
						add(white);
						
						var lowQualityBG:FlxSprite = new FlxSprite(-250, 50).loadGraphic(Paths.image('favi/stages/grassNation/bgLowQuality'));
						lowQualityBG.antialiasing = false;
						lowQualityBG.scale.set(1.75, 1.75);
						add(lowQualityBG);

						if (ClientPrefs.epilepsy)
						{
							fuckedBG = new FlxSprite(-250, 50).loadGraphic(Paths.image(pathway + 'fuckedBGLow'));
							fuckedBG.antialiasing = false;
							fuckedBG.scale.set(1.75, 1.75);
							fuckedBG.alpha = 0.001;
							add(fuckedBG);
						}

						whiteBG = new FlxSprite(-800, -200).makeGraphic(1, 1, 0xFFFFFFFF);
						whiteBG.scale.set(FlxG.width*5, FlxG.height*5);
						whiteBG.scrollFactor.set(0, 0);
						whiteBG.screenCenter();
						whiteBG.alpha = 0.001;
						whiteBG.active = false;
						add(whiteBG);

						if (ClientPrefs.epilepsy)
						{
							noSignalBG = new FlxSprite().loadGraphic(Paths.image(pathway + 'screenFucker/noSignalLow'));
							staticSpr = new FlxSprite().loadGraphic(Paths.image(pathway + 'screenFucker/staticLow'));
							noSignalLogo = new FlxSprite().loadGraphic(Paths.image(pathway + 'screenFucker/noSignalLogo'));

							for (screenShit in [noSignalBG, staticSpr, noSignalLogo])
							{
								screenShit.cameras = [camHUD];
								screenShit.screenCenter();
								screenShit.alpha = 0.001;
								screenShit.antialiasing = false;
							}
						}
					}
				case 'forbiddenRealm':
					isPixelStage = true;
					defaultCamZoom = 0.8;
					//spawnGirlfriend = false;
	
					accessPath = SONG.song == 'Malfunction Legacy' ? 'PixelMouse' : 'malfunctionBG-NEW';
					
					staticBG = new FlxRuntimeShader(Shaders.tvStatic, null, 120);
					glitchBG = new FlxRuntimeShader(Shaders.vignetteGlitch, null, 130);
	
					fuckingsquares = new FlxSprite(-750, -850);
					fuckingsquares.loadGraphic(Paths.image(pathway + accessPath));
					fuckingsquares.scale.set(1.2, 1);
					fuckingsquares.updateHitbox();
					fuckingsquares.antialiasing = false;
					fuckingsquares.scrollFactor.set(1, 1);
					fuckingsquares.active = false;
					if (ClientPrefs.shaders && !ClientPrefs.lowQuality)
						fuckingsquares.shader = malBG;
					add(fuckingsquares);
	
					var greyParticles:FlxEmitter = new FlxEmitter(-2080.5, 650.4);
						greyParticles.launchMode = SQUARE;
						greyParticles.velocity.set(-50, -200, 50, -600, -90, 0, 90, -600);
						greyParticles.scale.set(4, 4, 4, 4, 0, 0, 0, 0);
						greyParticles.drag.set(0, 0, 0, 0, 5, 5, 10, 10);
						greyParticles.width = 4787.45;
						greyParticles.alpha.set(1, 1);
						greyParticles.lifespan.set(1.9, 4.9);
						greyParticles.loadParticles(Paths.image(pathway + 'greyParticle'), 500, 16, true);
						greyParticles.start(false, FlxG.random.float(.0521, .1060), 1000000);
	
						var blackParticles:FlxEmitter = new FlxEmitter(-2080.5, 912.4);
						blackParticles.launchMode = SQUARE;
						blackParticles.velocity.set(-70, -220, 70, -620, -110, 20, 110, -620);
						blackParticles.scale.set(6, 6, 6, 6, 2, 2, 2, 2);
						blackParticles.drag.set(2, 2, 2, 2, 7, 7, 12, 12);
						blackParticles.width = 4787.45;
						blackParticles.alpha.set(1, 1);
						blackParticles.lifespan.set(1.9, 4.9);
						blackParticles.loadParticles(Paths.image(pathway + 'particleBlack'), 500, 16, true);
						blackParticles.start(false, FlxG.random.float(.0821, .1460), 1000000);
					
					mickeyEmitter = new FlxEmitter(-2099.8, 1620.4);
					for (i in 0 ... 100)
					{
						var mickeyParticle = new FlxParticle();
						mickeyParticle.frames = Paths.getSparrowAtlas(pathway + 'mickParticle');
						mickeyParticle.animation.addByPrefix('mickParticle idle', 'mickParticle idle', 12, true);
						mickeyParticle.animation.play('mickParticle idle');
						mickeyParticle.exists = false;
						//mickeyParticle.animation.curAnim.curFrame = FlxG.random.int(0, 3);
						mickeyEmitter.add(mickeyParticle);
					}
					mickeyEmitter.launchMode = SQUARE;
					mickeyEmitter.velocity.set(-50, -400, 50, -800, -100, 0, 100, -800);
					mickeyEmitter.scale.set(3.4, 3.4, 3.4, 3.4, 0, 0, 0, 0);
					mickeyEmitter.drag.set(0, 0, 0, 0, 5, 5, 10, 10);
					mickeyEmitter.width = 4200.45;
					mickeyEmitter.alpha.set(1, 1);
					mickeyEmitter.lifespan.set(4, 4.5);
					mickeyEmitter.start(false, FlxG.random.float(.125, .287), 100000);
					mickeyEmitter.emitting = false;
					
					whiteBG = new FlxSprite(-800, -200).makeGraphic(1, 1, 0xFFFFFFFF);
					whiteBG.scale.set(FlxG.width, FlxG.height);
					whiteBG.alpha = 0.001;
					whiteBG.active = false;
					add(whiteBG);
					
					if (SONG.song != 'Malfunction Legacy')
					{
						add(greyParticles);
						foreground.add(blackParticles);
						foreground.add(mickeyEmitter);
					}
				case 'trueGrinsOfSins':
					defaultCamZoom = 0.75;
					cameraSpeed = 2.5;
	
					var office:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.image(pathway + 'office'));
					office.antialiasing = true;
					office.scrollFactor.set(1, 1);
					office.active = false;
					add(office);
	
					var chair:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.image(pathway + 'chair'));
					chair.antialiasing = true;
					chair.scrollFactor.set(1, 1);
					chair.active = false;
					add(chair);
	
					var funiLight:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.image(pathway + 'light'));
					funiLight.antialiasing = true;
					funiLight.scrollFactor.set(1, 1);
					funiLight.alpha = 0.6;
					funiLight.blend = ADD;
					funiLight.active = false;
					foreground.add(funiLight);
	
					office.scale.set(0.85, 0.8);
					chair.scale.set(0.9, 0.85);
					funiLight.scale.set(0.85, 0.8);
				case 'vaultRoom':
					//spawnGirlfriend = false;
	
					vault = new FlxSprite(-200, -100).loadGraphic(Paths.image(pathway + 'vault'));
					vault.scale.set(2.45, 2.3);
					add(vault);
					chains = new FlxSprite(-225, -100).loadGraphic(Paths.image(pathway + 'chains1'));
					chains.scale.set(2.5, 2.3);
					chains.scrollFactor.set(1.2, 1.25);
					chains2 = new FlxSprite(-225, -100).loadGraphic(Paths.image(pathway + 'chains2'));
					chains2.scale.set(2.5, 2.3);
					chains2.scrollFactor.set(1.1, 1.2);
					chains3 = new FlxSprite(-225, -100).loadGraphic(Paths.image(pathway + 'chains3'));
					chains3.scale.set(2.5, 2.3);
					chains3.scrollFactor.set(1, 1.15);
					light = new FlxSprite(-200, -100).loadGraphic(Paths.image(pathway + 'lightSource'));
					light.blend = DIFFERENCE;
					light.alpha = 0.37;
					light.scrollFactor.set(0.95, 1);
					light.scale.set(2.45, 2.3);
					flair = new FlxSprite(-200, -100).loadGraphic(Paths.image(pathway + 'lightFlair'));
					flair.blend = SCREEN;
					flair.alpha = 0.6;
					flair.scrollFactor.set(1.4, 1.25);
					flair.scale.set(2.5, 2.4);
					thingy = new FlxSprite(-200, -100).loadGraphic(Paths.image(pathway + 'darkness'));
					thingy.scale.set(2.45, 2.3);
	
					foreground.add(chains3);
					foreground.add(chains2);
					foreground.add(chains);
					foreground.add(light);
					foreground.add(flair);
					foreground.add(thingy);

					lightI = new FlxSprite(-200, -100).loadGraphic(Paths.image(pathway + 'lightInvert'));
					lightI.blend = DIFFERENCE;
					lightI.alpha = 0.37;
					lightI.scrollFactor.set(0.95, 1);
					lightI.scale.set(2.45, 2.3);
					lightI.visible = false;
					flairI = new FlxSprite(-200, -100).loadGraphic(Paths.image(pathway + 'flairInvert'));
					flairI.blend = SCREEN;
					flairI.alpha = 0.6;
					flairI.scrollFactor.set(1.4, 1.25);
					flairI.scale.set(2.5, 2.4);
					flairI.visible = false;

					foreground.add(lightI);
					foreground.add(flairI);
				case 'waltRoom':
					//spawnGirlfriend = false;
					
					defaultCamZoom = 0.75;
	
					if (SONG.song == 'Mercy')
					{
						camGame.alpha = 0;
						camHUD.alpha = 0;
						//dadStrums.visible = false;
	
						pissOfGlory = new FlxSprite(-470, -280);
						pissOfGlory.loadGraphic(Paths.image(pathway + 'newWaltBG'));
						pissOfGlory.scale.set(1.7, 1.7);
					}else{
						pissOfGlory = new FlxSprite(-450, -300);
						pissOfGlory.loadGraphic(Paths.image(pathway + 'walt-bg'));
						pissOfGlory.scale.set(1, 1);
					}
					pissOfGlory.updateHitbox();
					pissOfGlory.antialiasing = true;
					pissOfGlory.scrollFactor.set(1, 1);
					pissOfGlory.active = false;
					pissOfGlory.blend = ADD;
					//add(pissOfGlory);

					retardedButPissBehind = new FlxSprite().loadGraphicFromSprite(pissOfGlory);
					add(retardedButPissBehind);
					if (SONG.song == 'Mercy')
					{
						retardedButPissBehind.scale.set(1.7, 1.7);
						retardedButPissBehind.updateHitbox();
						retardedButPissBehind.setPosition(pissOfGlory.x, pissOfGlory.y);
					}
					else
					{
						retardedButPissBehind.updateHitbox();
						retardedButPissBehind.setPosition(pissOfGlory.x, pissOfGlory.y);
					}
	
					greaterPiss = new FlxSprite(-60, -70);
					greaterPiss.loadGraphic(Paths.image(pathway + 'inkWaltBG'));
					greaterPiss.scale.set(1.7, 1.7);
					greaterPiss.blend = ADD;
					greaterPiss.visible = false;

					sameAsAdobe = new FlxSprite().loadGraphicFromSprite(greaterPiss);
					sameAsAdobe.visible = false;
					sameAsAdobe.setPosition(greaterPiss.x, greaterPiss.y);
					sameAsAdobe.scale.set(1.7, 1.7);
					add(sameAsAdobe);

					waltGoop = new FlxSprite(-800, 410).loadGraphic(Paths.image(pathway + 'melted'));
					waltGoop.scale.set(0.3, 0.3);
					//waltGoop.screenCenter();
					waltGoop.alpha = 0.001;
					foreground.add(waltGoop);
	
					if(!lowQuality)
						{
							var vignette:FlxSprite = new FlxSprite(-250, -140).loadGraphic(Paths.image(pathway + 'vignetteOverlay'));
							vignette.cameras = [camOther];
							vignette.scale.set(0.75, 0.75);
							vignette.antialiasing = true;
							vignette.scrollFactor.set();
							vignette.active = false;
							add(vignette);
						}
				case 'trance':
					//spawnGirlfriend = false;
					defaultCamZoom = 1;
	
					var bg:FlxSprite = new FlxSprite();
					bg.frames = Paths.getSparrowAtlas('favi/stages/trance/background');
					bg.animation.addByPrefix("lmao", "background lmao", 24, true);
					bg.scale.set(5, 5);
					add(bg);
					bg.animation.play("lmao");
	
					totallyAwsomeShader = new FlxRuntimeShader(Shaders.unregisteredHyperCam2Quality, null, 140);
					totallyAwsomeShader.setFloat('size', 7.5);
					if(ClientPrefs.shaders) 
						for (cam in [camGame, camNotes, camHUD])
							cam.setFilters([new ShaderFilter(totallyAwsomeShader)]);
				case 'apartment':
					isPixelStage = true;
					//spawnGirlfriend = false;
					defaultCamZoom = SONG.song == "Cycled Sins" ? 0.46 : 0.6;
					cameraSpeed = 0.9;
	
					//Phase 2 shaders
					glitchBG = new FlxRuntimeShader(Shaders.vignetteGlitch, null, 130);
	
					bg1 = new FlxSprite(0, 50);
					if (SONG.song == "Cycled Sins Legacy") 
					{
						bg1.frames = Paths.getSparrowAtlas(pathway + 'relapse1');
					 	bg1.animation.addByPrefix('idle', 'Bg bg', 10, true);
					}
					else
						bg1.loadGraphic(Paths.image(pathway + 'relapseBG-nominnie'));
					bg1.scale.set(7, 7);
					bg1.antialiasing = false;
					if (SONG.song == "Cycled Sins Legacy") bg1.animation.play('idle');
					add(bg1);
	
					bg2 = new FlxSprite(0, 50).loadGraphic(Paths.image(pathway + 'relapse2'));
					bg2.scale.set(7, 7);
					bg2.antialiasing = false;
					bg2.visible = false;
					add(bg2);
				case 'staticVoid':
					defaultCamZoom = 0.45;	
	
					var whoaBlackBG:FlxSprite = new FlxSprite(0, 0).makeGraphic(1, 1, 0x000000);
					whoaBlackBG.scale.set(FlxG.width * 4, FlxG.height * 4);
					whoaBlackBG.screenCenter();
					add(whoaBlackBG);
	
					datTV = new FlxSprite(-250, -160);
					datTV.frames = Paths.getSparrowAtlas(pathway + 'white');
					datTV.animation.addByPrefix('idle', 'white idle');
					datTV.animation.play('idle');
					datTV.scale.set(0.6, 0.6);
					datTV.alpha = 0.001;
					add(datTV);
	
					if(!lowQuality)
						{
							redGradThing = FlxGradient.createGradientFlxSprite(2130, 512, [0x00940606, 0x55BF0606, 0xAAFC0505], 1, 90, true);
							redGradThing.x = -740;
							redGradThing.y = 770;
							redGradThing.scale.y = 0;
							redGradThing.updateHitbox();
							//add(redGradThing);
						}
				case 'smilesOffice':
					//spawnGirlfriend = false;
					defaultCamZoom = 0.9;
					cameraSpeed = 2;
	
					var office:FlxSprite = new FlxSprite(-100, -100).loadGraphic(Paths.image(pathway + 'office'));
					office.scale.set(1, 1);
					office.updateHitbox();
					office.antialiasing = true;
					office.scrollFactor.set(1, 1);
					office.active = false;
					add(office);
	
					var funiLight:FlxSprite = new FlxSprite(-100, -100).loadGraphic(Paths.image(pathway + 'officeLight'));
					funiLight.scale.set(1, 1);
					funiLight.updateHitbox();
					funiLight.antialiasing = true;
					funiLight.scrollFactor.set(1, 1);
					funiLight.alpha = 0.6;
					funiLight.blend = ADD;
					funiLight.active = false;
					foreground.add(funiLight);
				case 'fuckingLine':
					//spawnGirlfriend = false;
	
					var whiteVoid:FlxSprite = new FlxSprite().makeGraphic(FlxG.width * 5, FlxG.height * 5, FlxColor.WHITE);
					whiteVoid.screenCenter();
					add(whiteVoid);
	
					var line:FlxSprite = new FlxSprite(-80, 0).loadGraphic(Paths.image('favi/stages/fuckingLine/theLine'));
					line.scale.set(1.3, 1.3);
					add(line);
				case 'alleyway' | 'ddStage':
					//spawnGirlfriend = false;   
	
					bg = new FlxSprite(-600, 130).loadGraphic(Paths.image(pathway + "sky"));
					bg.scale.set(0.84, 0.84);
					bg.scrollFactor.set(0.8, 0.8);
					add(bg);

					var buildings:FlxSprite = new FlxSprite(-600, 130).loadGraphic(Paths.image(pathway + "back-buildings"));
					buildings.scale.set(0.84, 0.84);
					buildings.scrollFactor.set(0.9, 0.9);
					add(buildings);

					var alley:FlxSprite = new FlxSprite(-600, 130).loadGraphic(Paths.image(pathway + "alley_and_bench"));
					alley.scale.set(0.84, 0.84);
					add(alley);

					var rain:FlxSprite = new FlxSprite(-600, 130);
					rain.frames = Paths.getSparrowAtlas(pathway + "Rain");
					rain.animation.addByPrefix("crying bitch", "rain but the side", 30, true);
					rain.scale.set(2.1, 2.1);
					rain.scrollFactor.set(1.1, 1.1);
					rain.animation.play("crying bitch");
					rain.alpha = 0.5;
					foreground.add(rain);

					var fgWall:FlxSprite = new FlxSprite(-600, 290).loadGraphic(Paths.image(pathway + "big-ass-wall"));
					fgWall.scale.set(0.84, 0.84);
					fgWall.scrollFactor.set(1.18, 1.18);
					foreground.add(fgWall);
					
					gradient = new FlxSprite().loadGraphic(Paths.image('favi/filters/gradient'));
					gradient.cameras = [camOther];
					gradient.screenCenter();
					gradient.scale.set(0.5, 0.5);
					gradient.alpha = 0;
					add(gradient);
				case "menuSongs":
					defaultCamZoom = 1;

					var sky = new FlxSprite().loadGraphic(Paths.image(pathway + "secretBG"));
					sky.scrollFactor.set(0, 0);
					add(sky);

					var stars1 = new FlxSprite().loadGraphic(Paths.image(pathway + "secretStars1"));
					stars1.scrollFactor.set(0, 0);
					add(stars1);
					
					var stars2 = new FlxSprite().loadGraphic(Paths.image(pathway + "secretStars2"));
					stars2.scrollFactor.set(0, 0);
					stars2.alpha = 0.001;
					add(stars2);

					skyFlash = new FlxSprite().makeGraphic(FlxG.width*5, FlxG.height*5, FlxColor.WHITE);
					skyFlash.screenCenter();
					skyFlash.scrollFactor.set(0, 0);
					skyFlash.alpha = 0.001;
					add(skyFlash);

					var street = new FlxSprite().loadGraphic(Paths.image(pathway + "secretStreet"));
					street.scrollFactor.set(0, 0);
					add(street);

					var underlay = new FlxSprite().loadGraphic(Paths.image(pathway + "secretNoteUnderlay"));
					underlay.cameras = [camNotes];
					add(underlay);

					var overlay = new FlxSprite().loadGraphic(Paths.image(pathway + "secretOverlay"));
					overlay.cameras = [camOther];
					add(overlay);

					FlxTween.tween(stars1, {alpha: 0}, 3, {type: 4});
					FlxTween.tween(stars2, {alpha: 1}, 3, {type: 4});
		}

		stageBGFlash = new FlxSprite().makeGraphic(1, 1, 0xFFFFFFFF);
		stageBGFlash.scale.set(FlxG.width * 5, FlxG.height * 5);
		stageBGFlash.alpha = 0.0001; // it's at this value so the game doesn't lag when it becomes visible
		stageBGFlash.x -= 750;
		stageBGFlash.y -= 450;
		stageBGFlash.scrollFactor.set();
		add(stageBGFlash);

		switch(Paths.formatToSongPath(SONG.song))
		{
			case 'stress':
				GameOverSubstate.characterName = 'bf-holding-gf-dead';
		}

		switch (SONG.song)
		{
			case "Isolated" | "Devilish Deal" | "Lunacy" | "Delusional" | "Hunted" | "Twisted Grins" | "Twisted Grins Legacy" | "Laugh Track" |  "Isolated Old" | "Isolated Beta" | "Isolated Legacy" | "Lunacy Legacy" | "Delusional Legacy" | "Hunted Legacy" | "Birthday" | "Rotten Petals" | "Seeking Freedom" | "Am I Real?" | "Curtain Call" | "Your Final Bow" | "A True Monster" | "The Wretched Tilezones (Simple Life)" | "Ship the Fart Yay Hooray <3 (Distant Stars)" | "Ahh the Scary (Somber Night)":
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

		add(gfGroup); //Needed for blammed lights

		// Shitty layering but whatev it works LOL
		if (curStage == 'limo')
			add(limo);

		add(dadGroup);
		add(boyfriendGroup);

		// more shitty layering lol
		if (curStage == 'waltRoom')
			{
				add(pissOfGlory);
				add(greaterPiss);
			}

		switch(curStage)
		{
			case 'spooky':
				add(halloweenWhite);
			case 'tank':
				add(foregroundSprites);
			case "forestNew":
				add(treesFront);
		}

		add(foreground);

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
			windowName = "Funkin.avi - Episode 1 - Isolated (Composed by: obscurity) - Chart by: Purg [NORMAL] - Mechanics: " + (ClientPrefs.mechanics ? "Enabled" : "Disabled"); // shitty long ass name that credits literally every fucking thing
		else
			windowName = "Funkin.avi - " + 
			(isStoryMode ? curEpisode + " - " : "Freeplay - ") + 
			(SONG.song == "Dont Cross" ? "Don't Cross!" : SONG.song) + 
			" (Composed by: " + FreeplayState.getArtistName() + 
			") - Chart by: " + Song.getCharterCredits() + 
			" [" + FreeplayState.getDiffRank() + "]" + 
			(checkMechanics ? ' - Mechanics: ' + (ClientPrefs.mechanics ? "Enabled" : "Disabled") : ""); // shitty long ass name that credits literally every fucking thing


		#if LUA_ALLOWED
		luaDebugGroup = new FlxTypedGroup<DebugLuaText>();
		luaDebugGroup.cameras = [camOther];
		add(luaDebugGroup);
		#end

		// "GLOBAL" SCRIPTS
		#if LUA_ALLOWED
		var filesPushed:Array<String> = [];
		var foldersToCheck:Array<String> = [Paths.getPreloadPath('scripts/')];

		#if MODS_ALLOWED
		foldersToCheck.insert(0, Paths.mods('scripts/'));
		if(Paths.currentModDirectory != null && Paths.currentModDirectory.length > 0)
			foldersToCheck.insert(0, Paths.mods(Paths.currentModDirectory + '/scripts/'));

		for(mod in Paths.getGlobalMods())
			foldersToCheck.insert(0, Paths.mods(mod + '/scripts/'));
		#end

		for (folder in foldersToCheck)
		{
			if(FileSystem.exists(folder))
			{
				for (file in FileSystem.readDirectory(folder))
				{
					if(file.endsWith('.lua') && !filesPushed.contains(file))
					{
						luaArray.push(new FunkinLua(folder + file));
						filesPushed.push(file);
					}
				}
			}
		}
		#end


		// STAGE SCRIPTS
		#if (MODS_ALLOWED && LUA_ALLOWED)
		var doPush:Bool = false;
		var luaFile:String = 'stages/' + curStage + '.lua';
		if(FileSystem.exists(Paths.modFolders(luaFile))) {
			luaFile = Paths.modFolders(luaFile);
			doPush = true;
		} else {
			luaFile = Paths.getPreloadPath(luaFile);
			if(FileSystem.exists(luaFile)) {
				doPush = true;
			}
		}

		if(doPush)
			luaArray.push(new FunkinLua(luaFile));
		#end

		var gfVersion:String = SONG.gfVersion;
		if(gfVersion == null || gfVersion.length < 1)
		{
			switch (curStage)
			{
				case 'limo':
					gfVersion = 'gf-car';
				case 'mall' | 'mallEvil':
					gfVersion = 'gf-christmas';
				case 'school' | 'schoolEvil':
					gfVersion = 'gf-pixel';
				case 'tank':
					gfVersion = 'gf-tankmen';
				default:
					gfVersion = 'gf';
			}

			switch(Paths.formatToSongPath(SONG.song))
			{
				case 'stress':
					gfVersion = 'pico-speaker';
			}
			SONG.gfVersion = gfVersion; //Fix for the Chart Editor
		}

		if (!stageData.hide_girlfriend)
		{
			gf = new Character(0, 0, gfVersion);
			startCharacterPos(gf);
			gf.scrollFactor.set(0.95, 0.95);
			gfGroup.add(gf);
			startCharacterLua(gf.curCharacter);

			if(gfVersion == 'pico-speaker')
			{
				if(!ClientPrefs.lowQuality)
				{
					var firstTank:TankmenBG = new TankmenBG(20, 500, true);
					firstTank.resetShit(20, 600, true);
					firstTank.strumTime = 10;
					tankmanRun.add(firstTank);

					for (i in 0...TankmenBG.animationNotes.length)
					{
						if(FlxG.random.bool(16)) {
							var tankBih = tankmanRun.recycle(TankmenBG);
							tankBih.strumTime = TankmenBG.animationNotes[i][0];
							tankBih.resetShit(500, 200 + FlxG.random.int(50, 100), TankmenBG.animationNotes[i][1] < 2);
							tankmanRun.add(tankBih);
						}
					}
				}
			}
		}

		dad = new Character(0, 0, SONG.player2);
		startCharacterPos(dad, true);
		dadGroup.add(dad);
		startCharacterLua(dad.curCharacter);

		boyfriend = new Boyfriend(0, 0, SONG.player1);
		startCharacterPos(boyfriend);
		boyfriendGroup.add(boyfriend);
		startCharacterLua(boyfriend.curCharacter);
		if (curStage == "waltRoom") boyfriend.visible = false;

		// pathetic attempts at trying to create shadows, will probably come back to this once I figure this shit out
		/*if (curStage == "trueGrinsOfSins")
		{
			var bfShadow:FlxSkewedSprite = new FlxSkewedSprite(650, 650, boyfriend.imageFile);
			bfShadow.alpha = 0.85;
			bfShadow.matrixExposed = true;
			var lol = new FlxMatrix(1, 0, 1, 0.6, 523, -825);
			lol.rotate(0.03);
			@:privateAccess bfShadow.transformMatrix = lol;
			addBehindBF(bfShadow);
		}

		for (c in [boyfriend, dad]) {
			var s = new FlxSkewedSprite(c);
			s.alpha = 0.85;
			s.shader = blur;
			s.matrixExposed = true;
	
			switch(c) {
				case boyfriend:
					var lol = new FlxMatrix(1, 0, 1, 0.6, 523, -825);
					lol.rotate(0.03);
					s.transformMatrix = lol;
					addBehindBF(s);
	
				case dad: 
					s.transformMatrix = new FlxMatrix(1, 0, -1, 0.6, -1600, -120);
					addBehindDad(s);
			}
		}*/

		var camPos:FlxPoint = new FlxPoint(girlfriendCameraOffset[0], girlfriendCameraOffset[1]);
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

		switch(curStage)
		{
			case 'limo':
				resetFastCar();
				addBehindGF(fastCar);

			case 'schoolEvil':
				var evilTrail = new FlxTrail(dad, null, 4, 24, 0.3, 0.069); //nice
				addBehindDad(evilTrail);
			case "vaultRoom":
				dad.blend = ADD;
		}

		resetCharPos();

		
		blendFlash = new FlxSprite().makeGraphic(1, 1, 0xFFFFFFFF);
		blendFlash.scale.set(FlxG.width * 5, FlxG.height * 5);
		blendFlash.alpha = 0.0001;
		blendFlash.blend = ADD;
		blendFlash.x -= 750;
		blendFlash.y -= 450;
		blendFlash.scrollFactor.set();
		add(blendFlash);

		var file:String = Paths.json(songName + '/dialogue'); //Checks for json/Psych Engine dialogue
		if (OpenFlAssets.exists(file)) {
			dialogueJson = DialogueBoxPsych.parseDialogue(file);
		}

		var file:String = Paths.txt(songName + '/' + songName + 'Dialogue'); //Checks for vanilla/Senpai dialogue
		if (OpenFlAssets.exists(file)) {
			dialogue = CoolUtil.coolTextFile(file);
		}
		var doof:DialogueBox = new DialogueBox(false, dialogue);
		// doof.x += 70;
		// doof.y = FlxG.height * 0.5;
		doof.scrollFactor.set();
		doof.finishThing = startCountdown;
		doof.nextDialogueThing = startNextDialogue;
		doof.skipDialogueThing = skipDialogue;

		Conductor.songPosition = -5000 / Conductor.songPosition;

		middlescroll = SONG.song.toLowerCase() == 'cycled sins' || ClientPrefs.middleScroll || curStage == "menuSongs";

		strumLine = new FlxSprite(middlescroll ? STRUM_X_MIDDLESCROLL : STRUM_X, 50).makeGraphic(FlxG.width, 10);
		if(ClientPrefs.downScroll) strumLine.y = FlxG.height - 150;
		strumLine.scrollFactor.set();

		var showTime:Bool = (ClientPrefs.timeBarType != 'Disabled');
		timeTxt = new FlxText(STRUM_X + (FlxG.width / 2) - 248, 19, 400, "", 32);
		timeTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		timeTxt.scrollFactor.set();
		timeTxt.alpha = 0;
		timeTxt.borderSize = 2;
		timeTxt.visible = false;
		if(ClientPrefs.downScroll) timeTxt.y = FlxG.height - 44;

		if(ClientPrefs.timeBarType == 'Song Name')
		{
			timeTxt.text = SONG.song;
		}
		updateTime = showTime;

		timeBarBG = new AttachedSprite('timeBar');
		timeBarBG.x = timeTxt.x;
		timeBarBG.y = timeTxt.y + (timeTxt.height / 4);
		timeBarBG.scrollFactor.set();
		timeBarBG.alpha = 0;
		timeBarBG.visible = false;
		timeBarBG.color = FlxColor.BLACK;
		timeBarBG.xAdd = -4;
		timeBarBG.yAdd = -4;
		add(timeBarBG);

		timeBar = new FlxBar(timeBarBG.x + 4, timeBarBG.y + 4, LEFT_TO_RIGHT, Std.int(timeBarBG.width - 8), Std.int(timeBarBG.height - 8), this,
			'songPercent', 0, 1);
		timeBar.scrollFactor.set();
		timeBar.createFilledBar(0xFF000000, 0xFFFFFFFF);
		timeBar.numDivisions = 800; //How much lag this causes?? Should i tone it down to idk, 400 or 200?
		timeBar.alpha = 0;
		timeBar.visible = false;
		add(timeBar);
		add(timeTxt);
		timeBarBG.sprTracker = timeBar;

		strumLineNotes = new FlxTypedGroup<StrumNote>();
		add(strumLineNotes);

		if(ClientPrefs.timeBarType == 'Song Name')
		{
			timeTxt.size = 24;
			timeTxt.y += 3;
		}

		var splash:NoteSplash = new NoteSplash(100, 100, 0);
		grpNoteSplashes.add(splash);
		splash.alpha = 0.0;

		opponentStrums = new FlxTypedGroup<StrumNote>();
		playerStrums = new FlxTypedGroup<StrumNote>();

		// startCountdown();

		generateSong(SONG.song);

		// After all characters being loaded, it makes then invisible 0.01s later so that the player won't freeze when you change characters
		// add(strumLine);

		playfieldRenderer = new PlayfieldRenderer(strumLineNotes, notes, this);
		playfieldRenderer.cameras = [camNotes];
		add(playfieldRenderer);

		add(grpNoteSplashes);


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

		healthBarBG = new AttachedSprite('healthBar');
		healthBarBG.y = FlxG.height * 0.89;
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		healthBarBG.visible = !ClientPrefs.hideHud;
		healthBarBG.xAdd = -4;
		healthBarBG.yAdd = -4;
		add(healthBarBG);
		if(ClientPrefs.downScroll || curStage == "waltRoom" || curStage == "menuSongs") healthBarBG.y = 0.11 * FlxG.height;

		fancyBarOverlay = new FlxSprite(healthBarBG.x, healthBarBG.y).loadGraphic(Paths.image('episode1Overlay'));
		fancyBarOverlay.scale.set(1.01, 1);
		fancyBarOverlay.cameras = [camHUD];
		fancyBarOverlay.screenCenter(X);
		fancyBarOverlay.scrollFactor.set();
		if (ClientPrefs.downScroll || curStage == "waltRoom" || curStage == "menuSongs")
		{
			fancyBarOverlay.y -= 10;
		}
		else
		{
			fancyBarOverlay.y -= 117;
			fancyBarOverlay.flipY = true;
		}
		fancyBarOverlay.visible = SONG.song.toLowerCase() != 'cycled sins';
		add(fancyBarOverlay);

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 5, (SONG.song == "Devilish Deal" ? LEFT_TO_RIGHT : RIGHT_TO_LEFT), Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 7), this,
			'healthLerp', 0, 2);
		healthBar.scrollFactor.set();
		healthBar.percent = healthThing;
		// healthBar
		healthBar.visible = !ClientPrefs.hideHud;
		healthBar.alpha = ClientPrefs.healthBarAlpha;
		add(healthBar);
		healthBarBG.sprTracker = healthBar;

		iconP1 = new HealthIcon((SONG.song == "Mercy" ? "everettmercy" : boyfriend.healthIcon), (SONG.song == "Mercy" ? false : true), boyfriend.animatedIcon, boyfriend.intenseIcon, boyfriend.boppingIcon);
		iconP1.y = healthBar.y - 75;

		// reposition specific icons on the healthbar properly
		switch (boyfriend.healthIcon)
		{
			case "everett" | "maleverett-pixel": iconP1.y -= 20;
			case "everettmodern": iconP1.y -= 10;
			case "everettb": iconP1.y -= 5;
		}

		iconP1.visible = !ClientPrefs.hideHud;
		iconP1.alpha = ClientPrefs.healthBarAlpha;
		add(iconP1);

		iconP2 = new HealthIcon(dad.healthIcon, false, dad.animatedIcon, dad.intenseIcon, dad.boppingIcon);
		iconP2.y = healthBar.y - 75;

		// reposition specific icons on the healthbar properly
		switch (dad.healthIcon)
		{
			case "walt" | "ricky" | "noise": iconP2.y -= 20;
			case "goofy" | "smile" | "relapseNEW-pixel": iconP2.y -= 10;
			case "cross": iconP2.y -= 15;
		}

		iconP2.visible = !ClientPrefs.hideHud;
		iconP2.alpha = ClientPrefs.healthBarAlpha;
		add(iconP2);
		reloadHealthBarColors();
		if (curStage == 'vaultRoom') iconP2.blend = ADD;

		if (curStage == "waltRoom" || curStage == "menuSongs")
		{
			fancyBarOverlay.flipY = true;
			for (bar in [healthBar, healthBarBG, fancyBarOverlay])
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
			
		// Hardcoded Icons
		if (SONG.song == "Isolated")
		{
			demonBFIcon = new HealthIcon('evilcy', true, false, true, false);
			demonBFIcon.y = healthBar.y - 75;
			demonBFIcon.x = FlxG.width * 0.87;
			demonBFIcon.visible = false;
			add(demonBFIcon);
		
			demonBFScary = new HealthIcon('evildelu', true, false, true, false);
			demonBFScary.animation.curAnim.curFrame = 1;
			demonBFScary.y = healthBar.y - 75;
			demonBFScary.x = FlxG.width * 0.87;
			demonBFScary.visible = false;
			add(demonBFScary);
		
			fakeBFLosingFrame = new HealthIcon('evilrett', true, false, true, false);
			fakeBFLosingFrame.animation.curAnim.curFrame = 1;
			fakeBFLosingFrame.y = healthBar.y - 75;
			fakeBFLosingFrame.x = FlxG.width * 0.87;
			fakeBFLosingFrame.visible = false;
			add(fakeBFLosingFrame);
		
			isolatedHappy = new HealthIcon('lunaavier', false, false, false, true);
			isolatedHappy.animation.curAnim.curFrame = 2;
			isolatedHappy.y = healthBar.y - 75;
			isolatedHappy.visible = false;
			add(isolatedHappy);
			
			lunacyIcon = new HealthIcon('lunaavier', false, false, true, false);
			lunacyIcon.y = healthBar.y - 75;
			lunacyIcon.visible = false;
			add(lunacyIcon);
			
			delusionalIcon = new HealthIcon('deluavier', false, false, true, false);
			delusionalIcon.y = healthBar.y - 75;
			delusionalIcon.visible = false;
			add(delusionalIcon);

			demonBFIcon.cameras = [camHUD];
			demonBFScary.cameras = [camHUD];
			fakeBFLosingFrame.cameras = [camHUD];
			isolatedHappy.cameras = [camHUD];
			lunacyIcon.cameras = [camHUD];
			delusionalIcon.cameras = [camHUD];
		}
	
		if (SONG.song == "Devilish Deal")
		{
			minnieIcon = new HealthIcon('minnie', false, false, false, true);
			minnieIcon.y = healthBar.y - 75;
			minnieIcon.animation.curAnim.curFrame = 2;
			minnieIcon.visible = false;
			add(minnieIcon);
			
			satanIcon = new HealthIcon('satanddNEW', true, false, true, false);
			satanIcon.y = healthBar.y - 90;
			satanIcon.animation.curAnim.curFrame = 0;
			satanIcon.visible = false;
			add(satanIcon);
		
			satanIconPulse = new HealthIcon('satan', true, false, true, true);
			satanIconPulse.y = healthBar.y - 90;
			satanIconPulse.animation.curAnim.curFrame = 1;
			satanIconPulse.visible = false;
			add(satanIconPulse);

			minnieIcon.cameras = [camHUD];
			satanIcon.cameras = [camHUD];
			satanIconPulse.cameras = [camHUD];

			iconP1.visible = false;
			iconP2.visible = false;
			minnieIcon.visible = true;
			satanIcon.visible = true;
		}

		if (SONG.song == "Cycled Sins")
		{
			relapseIconLol = new HealthIcon('relapse2NEW-pixel', false, false, false, false);
			relapseIconLol.y = healthBar.y - 90;
			relapseIconLol.scale.set(0.85, 0.85);
			relapseIconLol.alpha = 0.001;
			add(relapseIconLol);
			relapseIconLol.cameras = [camHUD];
		}

		scoreTxt = new FlxText(0, ((curStage == "menuSongs" || curStage == "waltRoom") ? (ClientPrefs.downScroll ? 15 : 675) : healthBarBG.y + 36), FlxG.width, "", 20);
		scoreTxt.setFormat(Paths.font("DisneyFont.ttf"), 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreTxt.scrollFactor.set();
		scoreTxt.borderSize = 1.25;
		scoreTxt.visible = (!ClientPrefs.hideHud || !cpuControlled);
		add(scoreTxt);


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
		if (ClientPrefs.downScroll) watermarkTxt.setPosition(0, 655); else watermarkTxt.setPosition(0, 8);
		watermarkTxt.screenCenter(X);
		add(watermarkTxt);

		songTxt = new FlxText(watermarkTxt.x, watermarkTxt.y + 30, 1280, (SONG.song == "Dont Cross" ? "Don't Cross!" : '$infoDisplay'));
		songTxt.setFormat(Paths.font('DisneyFont.ttf'), 22, FlxColor.WHITE, CENTER);
		songTxt.setBorderStyle(OUTLINE, FlxColor.BLACK, 2);
		songTxt.alpha = 0.6;
		songTxt.screenCenter(X);
		add(songTxt);

		watermarkTxt.cameras = [camHUD];
		songTxt.cameras = [camHUD];

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

		botplayTxt = new FlxText(400, timeBarBG.y + 55, FlxG.width - 800, "BOTPLAY", 32);
		botplayTxt.setFormat(Paths.font("disneyFont.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		botplayTxt.scrollFactor.set();
		botplayTxt.borderSize = 1.25;
		botplayTxt.visible = false;
		add(botplayTxt);
		if(ClientPrefs.downScroll) {
			botplayTxt.y = timeBarBG.y - 78;
		}

		if (ClientPrefs.downScroll)
			{
				crashLives = new FlxText(600, 170, 0, "", 20);
				crashLivesIcon = new FlxSprite(550, 170);
			}
			else
			{
				crashLives = new FlxText(600, 500, 0, "", 20);
				crashLivesIcon = new FlxSprite(550, 500);
			}
	
			crashLives.setFormat(Paths.font("Retro Gaming.ttf"), 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			crashLives.borderSize = 2;
			crashLives.borderQuality = 2;
			crashLives.antialiasing = false;
			crashLives.scrollFactor.set();
			crashLives.cameras = [camHUD];
	
			crashLivesIcon.frames = Paths.getSparrowAtlas('UI/funkinAVI/gimmicks/malfunctionGimmickIcon');
			crashLivesIcon.animation.addByPrefix('idle', 'lives-icon idle', 15);
			crashLivesIcon.animation.addByPrefix('OMFG IT GLITCHES', 'lives-icon glitchin', 15);
			crashLivesIcon.animation.play('idle');
			crashLivesIcon.scale.set(2.2, 2.2);
			crashLivesIcon.antialiasing = false;
			crashLivesIcon.cameras = [camHUD];

			waltScreenThing = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
			waltScreenThing.scrollFactor.set();
			waltScreenThing.cameras = [camOther];
			waltScreenThing.alpha = 0.001;

			dodgeWarning = new FlxSprite(1080, 540).loadGraphic(Paths.image('favi/ui/dodgeSins/cycledWarn' + (FlxG.random.bool(2) ? "-alt" : "")));
			dodgeWarning.antialiasing = false;
			dodgeWarning.scale.set(4, 4);
			dodgeWarning.cameras = [camOther];
			dodgeWarning.screenCenter();
			dodgeWarning.alpha = 0.001;
			if (curStage == "apartment")
			{
				if (SONG.song == "Cycled Sins")
				{
					dodgeWarning.scale.set(3, 3);
					dodgeWarning.x += 450;
				}
				add(dodgeWarning);
			}

			if (curStage == "waltRoom" || SONG.song == "Delusional Legacy")
				add(waltScreenThing);
	
			if (!ClientPrefs.lowQuality)
			{
				switch (curStage)
				{
					case 'stage' | 'desktop' | 'waltRoom' | 'apartment' | 'treasureIsland' | 'forbiddenRealm' | 'fuckingLine' | 'staticVoid' | 'vaultRoom' | 'war' | 'grassNation':
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

			switch (curStage)
			{
				case "forestNew" | "desktop" | "circus" | 'clubhouse' | 'trueGrinsOfSins':
					//do nothing, gf exists
				case "menuSongs":
					boyfriend.visible = false;
					dad.visible = false;
					gf.visible = false;
				case 'apartment':
					if (SONG.song == "Cycled Sins Legacy") gf.visible = false;
				default:
					gf.visible = false;
			}

			var waltInstructionsMain:FlxText = new FlxText(370, 500, 0, "Take Advantage of the SPACEBAR!", 30);
			waltInstructionsMain.cameras = [camOther];
			waltInstructionsMain.setFormat(Paths.font("splatter.otf"), 30);
			waltInstructionsMain.scrollFactor.set();
	
			var waltSubTxt:FlxText = new FlxText(waltInstructionsMain.x + 66, waltInstructionsMain.y + 40, 0,
				"(It will help you regain health when critically low)", 15);
			waltSubTxt.setFormat(Paths.font("splatter.otf"), 15);
			waltSubTxt.cameras = [camOther];
			waltSubTxt.alpha = 0;
			waltSubTxt.scrollFactor.set();
	
			inkFormWarning = new FlxText(0, 0, 0, "PRESS SPACE!", 15);
			inkFormWarning.setFormat(Paths.font("splatter.otf"), 50);
			inkFormWarning.cameras = [camOther];
			inkFormWarning.alpha = 0;
			inkFormWarning.scrollFactor.set();
			inkFormWarning.screenCenter();
	
			mercyBoostIcon = new FlxSprite(-10, 600);
			mercyBoostIcon.frames = Paths.getSparrowAtlas("favi/ui/mercyIcon");
			mercyBoostIcon.animation.addByPrefix("full", "full", 7, true);
			mercyBoostIcon.animation.addByPrefix("hmm", "hmm", 7, true);
			mercyBoostIcon.animation.addByPrefix("halfway", "halfway", 7, true);
			mercyBoostIcon.animation.addByPrefix("thatsBad", "thatsBad", 7, true);
			mercyBoostIcon.animation.addByPrefix("almostOut", "almostOut", 7, true);
			mercyBoostIcon.animation.addByPrefix("empty", "empty", 7, true);
			mercyBoostIcon.animation.play("full");
			mercyBoostIcon.scale.set(0.75, 0.75);
			mercyBoostIcon.scrollFactor.set();			

			spaceBarCounter = new FlxText(0, 650, 140, '${limitThing}', 15);
			spaceBarCounter.setFormat(Paths.font("splatter.otf"), 30, FlxColor.BLACK, CENTER, OUTLINE, FlxColor.WHITE);
			spaceBarCounter.cameras = [camOther];
			//spaceBarCounter.alpha = 0;
			spaceBarCounter.scrollFactor.set();

			if (!ClientPrefs.lowQuality)
				{
					globalGradient = new FlxSprite().loadGraphic(Paths.image('UI/gimmicks/gradient'));
					globalGradient.screenCenter();
					globalGradient.setGraphicSize(Std.int(globalGradient.width * 0.68));
					globalGradient.cameras = [camOther];
					globalGradient.alpha = 0;
					add(globalGradient);
				}
		
			if (curStage == 'waltRoom')
			{
				if (ClientPrefs.mechanics)
				{
					add(waltInstructionsMain);
					add(waltSubTxt);
					add(mercyBoostIcon);
					add(spaceBarCounter);
		
					FlxTween.tween(waltInstructionsMain, {alpha: 0}, 1, {ease: FlxEase.quadInOut, startDelay: 8});
					FlxTween.tween(waltSubTxt, {alpha: 0}, 1, {ease: FlxEase.quadInOut, startDelay: 8});
					FlxTween.tween(waltSubTxt, {alpha: 1}, 0.7, {ease: FlxEase.quadInOut, startDelay: 3});
				}
			}

		strumLineNotes.cameras = [camHUD];
		grpNoteSplashes.cameras = [camNotes];
		notes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		botplayTxt.cameras = [camHUD];
		timeBar.cameras = [camHUD];
		timeBarBG.cameras = [camHUD];
		timeTxt.cameras = [camHUD];
		doof.cameras = [camHUD];

		// shitty thing to make it so the health bar is visible at all times
		if (curStage == "waltRoom")
		{
			var fakeCam:FlxCamera = new FlxCamera();
			fakeCam.bgColor.alpha = 0;
			FlxG.cameras.add(fakeCam, false);
			for (funny in [healthBar, healthBarBG, fancyBarOverlay, iconP1, iconP2, spaceBarCounter, mercyBoostIcon])
				funny.cameras = [fakeCam];
		}

		startingSong = true;

		lime.app.Application.current.window.title = windowName;

		windowTimer = new FlxTimer().start(5, function(tmr:FlxTimer)
		{
			if (GameData.episode1FPLock != "unlocked")
				windowName = "Funkin.avi - Episode 1 - Isolated [NORMAL]"
			else
				windowName = "Funkin.avi - " + 
				(isStoryMode ? curEpisode + " - " : "Freeplay - ") + 
				(SONG.song == "Dont Cross" ? "Don't Cross!" : SONG.song) + 
				" [" + FreeplayState.getDiffRank() + "]"; // short version that displays after 5 seconds yayaya

			lime.app.Application.current.window.title = windowName;
		});
		
		#if LUA_ALLOWED
		for (notetype in noteTypeMap.keys())
		{
			#if MODS_ALLOWED
			var luaToLoad:String = Paths.modFolders('custom_notetypes/' + notetype + '.lua');
			if(FileSystem.exists(luaToLoad))
			{
				luaArray.push(new FunkinLua(luaToLoad));
			}
			else
			{
				luaToLoad = Paths.getPreloadPath('custom_notetypes/' + notetype + '.lua');
				if(FileSystem.exists(luaToLoad))
				{
					luaArray.push(new FunkinLua(luaToLoad));
				}
			}
			#elseif sys
			var luaToLoad:String = Paths.getPreloadPath('custom_notetypes/' + notetype + '.lua');
			if(OpenFlAssets.exists(luaToLoad))
			{
				luaArray.push(new FunkinLua(luaToLoad));
			}
			#end
		}
		for (event in eventPushedMap.keys())
		{
			#if MODS_ALLOWED
			var luaToLoad:String = Paths.modFolders('custom_events/' + event + '.lua');
			if(FileSystem.exists(luaToLoad))
			{
				luaArray.push(new FunkinLua(luaToLoad));
			}
			else
			{
				luaToLoad = Paths.getPreloadPath('custom_events/' + event + '.lua');
				if(FileSystem.exists(luaToLoad))
				{
					luaArray.push(new FunkinLua(luaToLoad));
				}
			}
			#elseif sys
			var luaToLoad:String = Paths.getPreloadPath('custom_events/' + event + '.lua');
			if(OpenFlAssets.exists(luaToLoad))
			{
				luaArray.push(new FunkinLua(luaToLoad));
			}
			#end
		}
		#end
		noteTypeMap.clear();
		noteTypeMap = null;
		eventPushedMap.clear();
		eventPushedMap = null;

		// SONG SPECIFIC SCRIPTS
		#if LUA_ALLOWED
		var filesPushed:Array<String> = [];
		var foldersToCheck:Array<String> = [Paths.getPreloadPath('data/' + Paths.formatToSongPath(SONG.song) + '/')];

		#if MODS_ALLOWED
		foldersToCheck.insert(0, Paths.mods('data/' + Paths.formatToSongPath(SONG.song) + '/'));
		if(Paths.currentModDirectory != null && Paths.currentModDirectory.length > 0)
			foldersToCheck.insert(0, Paths.mods(Paths.currentModDirectory + '/data/' + Paths.formatToSongPath(SONG.song) + '/'));

		for(mod in Paths.getGlobalMods())
			foldersToCheck.insert(0, Paths.mods(mod + '/data/' + Paths.formatToSongPath(SONG.song) + '/' ));// using push instead of insert because these should run after everything else
		#end

		for (folder in foldersToCheck)
		{
			if(FileSystem.exists(folder))
			{
				for (file in FileSystem.readDirectory(folder))
				{
					if(file.endsWith('.lua') && !filesPushed.contains(file))
					{
						luaArray.push(new FunkinLua(folder + file));
						filesPushed.push(file);
					}
				}
			}
		}
		#end

		var daSong:String = Paths.formatToSongPath(curSong);
		if (isStoryMode && !seenCutscene)
		{
			switch (daSong)
			{
				case "monster":
					var whiteScreen:FlxSprite = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.WHITE);
					add(whiteScreen);
					whiteScreen.scrollFactor.set();
					whiteScreen.blend = ADD;
					camHUD.visible = false;
					snapCamFollowToPos(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);
					inCutscene = true;

					FlxTween.tween(whiteScreen, {alpha: 0}, 1, {
						startDelay: 0.1,
						ease: FlxEase.linear,
						onComplete: function(twn:FlxTween)
						{
							camHUD.visible = true;
							remove(whiteScreen);
							startCountdown();
						}
					});
					FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
					if(gf != null) gf.playAnim('scared', true);
					boyfriend.playAnim('scared', true);

				case "winter-horrorland":
					var blackScreen:FlxSprite = new FlxSprite().makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
					add(blackScreen);
					blackScreen.scrollFactor.set();
					camHUD.visible = false;
					inCutscene = true;

					FlxTween.tween(blackScreen, {alpha: 0}, 0.7, {
						ease: FlxEase.linear,
						onComplete: function(twn:FlxTween) {
							remove(blackScreen);
						}
					});
					FlxG.sound.play(Paths.sound('Lights_Turn_On'));
					snapCamFollowToPos(400, -2050);
					FlxG.camera.focusOn(camFollow);
					FlxG.camera.zoom = 1.5;

					new FlxTimer().start(0.8, function(tmr:FlxTimer)
					{
						camHUD.visible = true;
						remove(blackScreen);
						FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 2.5, {
							ease: FlxEase.quadInOut,
							onComplete: function(twn:FlxTween)
							{
								startCountdown();
							}
						});
					});
				case 'senpai' | 'roses' | 'thorns':
					if(daSong == 'roses') FlxG.sound.play(Paths.sound('ANGRY'));
					schoolIntro(doof);

				case 'ugh' | 'guns' | 'stress':
					tankIntro();

				// this whole video shit is retarded lol sorry i barely know this dogshit :sob:
				// please help
				case 'devilish-deal':
					camGame.visible = false;
					episodeIntro = new VideoSprite(false);
					episodeIntro.load(Paths.video('episodeStart'));
					episodeIntro.cameras = [camVideo];
					episodeIntro.play();
					camVideo.visible = true;
					add(episodeIntro);
					episodeIntro.addCallback("onStart", () -> {
						camVideo.visible = true;
						episodeIntro.visible = true;
					});
					episodeIntro.addCallback("onEnd", () -> {
						if (SONG.song == "Devilish Deal" && isStoryMode && GameData.episode1FPLock != "unlocked")
						{
							windowName = "Funkin.avi - " + 
							(isStoryMode ? curEpisode + " - " : "Freeplay - ") + 
							(SONG.song == "Dont Cross" ? "Don't Cross!" : SONG.song) + 
							" (Composed by: " + FreeplayState.getArtistName() + 
							") - Chart by: " + Song.getCharterCredits() + 
							" [" + FreeplayState.getDiffRank() + "]"; // shitty long ass name that credits literally every fucking thing
							lime.app.Application.current.window.title = windowName;

							windowTimer = new FlxTimer().start(5, function(tmr:FlxTimer)
							{
								windowName = "Funkin.avi - " + 
								(isStoryMode ? curEpisode + " - " : "Freeplay - ") + 
								(SONG.song == "Dont Cross" ? "Don't Cross!" : SONG.song) + 
								" [" + FreeplayState.getDiffRank() + "]"; // short version that displays after 5 seconds yayaya
					
								lime.app.Application.current.window.title = windowName;
							});
						}
						finishedScene = true;
						devilishGaming = new VideoSprite(false);
						devilishGaming.load(Paths.video("devilishIntro"), [VideoSprite.muted]);
						add(devilishGaming);
						devilishGaming.cameras = [camVideo];
						devilishGaming.play();
						devilishGaming.visible = false;
						camVideo.visible = true;
						camGame.visible = true;
						new FlxTimer().start(0.001, function(tmr:FlxTimer)
						{
							devilishGaming.pause();
							devilishGaming.setVideoTime(0);
						});
						startCountdown();
						canSkip = false;
						trace("video gone");
						remove(episodeIntro);
						episodeIntro.kill();
						episodeIntro = null;
					});
				case 'isolated':
					camGame.visible = false;
					isolatedIntro = new VideoSprite(false);
					isolatedIntro.load(Paths.video('isolatedIntro'));
					isolatedIntro.cameras = [camVideo];
					isolatedIntro.play();
					add(isolatedIntro);
					camVideo.visible = true;
					isolatedIntro.addCallback("onStart", () -> {
						camVideo.visible = true;
						isolatedIntro.visible = true;
					});
					isolatedIntro.addCallback("onEnd", () -> {
						camVideo.visible = false;
						camGame.visible = true;
						finishedScene = true;
						camBars.fade(FlxColor.BLACK, 0.001);
						startCountdown();
						canSkip = false;
						trace("video gone");
						remove(isolatedIntro);
						isolatedIntro.kill();
						isolatedIntro = null;
					});
				case 'lunacy':
					camGame.visible = false;
					lununuIntro = new VideoSprite(false);
					lununuIntro.load(Paths.video("lunacyIntro"));
					lununuIntro.cameras = [camVideo];
					lununuIntro.play();
					camVideo.visible = true;
					add(lununuIntro);
					lununuIntro.addCallback("onStart", () -> {
						camVideo.visible = true;
						lununuIntro.visible = true;
						camBars.visible = false;
					});
					lununuIntro.addCallback("onEnd", () -> {
						camVideo.visible = false;
						camBars.visible = true;
						camGame.visible = true;
						finishedScene = true;
						canSkip = false;
						camBars.fade(FlxColor.BLACK, 0.0001);
						startCountdown();
						trace("video gone");
						remove(lununuIntro);
						lununuIntro.kill();
						lununuIntro = null;
					});

				default:
					startCountdown();
			}
			seenCutscene = true;
			canSkip = true;

			skipSceneTxt = new FlxText(0, 25, 1280, "Spam SPACE to skip this cutscene.");
			skipSceneTxt.setFormat(Paths.font("MagicOwlFont.otf"), 32, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
			skipSceneTxt.alpha = 0.0001;
			skipSceneTxt.cameras = [camVideo];
			add(skipSceneTxt);
	
			skipDial = new FlxPieDial(0, 0, 45, FlxColor.WHITE, 10, CIRCLE, true, 30);
			skipDial.screenCenter();
			skipDial.amount = 0.0;
			skipDial.alpha = 0.0001;
			skipDial.cameras = [camVideo];
			add(skipDial);
		}
		else
		{
			startCountdown();
		}
		RecalculateRating();

		//PRECACHING MISS SOUNDS BECAUSE I THINK THEY CAN LAG PEOPLE AND FUCK THEM UP IDK HOW HAXE WORKS
		if(ClientPrefs.hitsoundVolume > 0) precacheList.set('hitsound', 'sound');
		precacheList.set('missnote1', 'sound');
		precacheList.set('missnote2', 'sound');
		precacheList.set('missnote3', 'sound');

		if (PauseSubState.songName != null) {
			precacheList.set(PauseSubState.songName, 'music');
		} else if(ClientPrefs.pauseMusic != 'None') {
			precacheList.set(Paths.formatToSongPath(ClientPrefs.pauseMusic), 'music');
		}

		precacheList.set('alphabet', 'image');

		switch (FreeplayState.freeplayMenuList)
		{
			case 2: iconRPC = "volume1";
			case 3: iconRPC = "volume2";
			default: iconRPC = CoolUtil.spaceToDash(SONG.song.toLowerCase());
		}
	
		#if DISCORD_ALLOWED
		#if DEV_BUILD
		DiscordClient.changePresence("Starting song.", "It's a secret...", "icon", "random");
		#else
		// Updating Discord Rich Presence.
		DiscordClient.changePresence(detailsText, "Starting song...", iconRPC, "random");
		#end
		#end

		if(!ClientPrefs.controllerMode)
		{
			FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
			FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
		}

		ModchartFuncs.loadLuaFunctions();

		
		if (canaddshaders)
		{
			switch (SONG.song)
			{
				case 'Bless':
					camGame.setFilters(
						[
							new ShaderFilter(othershader)
						]
					);
					new flixel.util.FlxTimer().start(1, function(tmr)
						{
							camGame.setFilters([/*that's right, nothing*/]);
						});
				case 'Malfunction':
					if(!ClientPrefs.lowQuality)
					{
						camGame.setFilters(
						[
							new ShaderFilter(chromZoomShader),
							new ShaderFilter(blurShader),
						]);
						camHUD.setFilters(
						[
							new ShaderFilter(chromNormalShader),
							new ShaderFilter(blurShader)
						]);
							camNotes.setFilters(
							[
								new ShaderFilter(chromNormalShader),
								new ShaderFilter(blurShader)
							]);

						new flixel.util.FlxTimer().start(5, function(tmr)
						{
							camGame.setFilters([new ShaderFilter(chromZoomShader)]);
							camHUD.setFilters([new ShaderFilter(chromNormalShader)]);
							camNotes.setFilters([new ShaderFilter(chromNormalShader)]);
						});
					}
				case 'Malfunction Legacy':
					if(!ClientPrefs.lowQuality)
					{
						camGame.setFilters(
						[
							new ShaderFilter(chromNormalShader),
							new ShaderFilter(blurShader)
						]);
						camHUD.setFilters(
						[
							new ShaderFilter(chromNormalShader),
							new ShaderFilter(blurShader)
						]);
						camNotes.setFilters(
							[
								new ShaderFilter(chromNormalShader),
								new ShaderFilter(blurShader)
							]);
					}
				case 'Devilish Deal' | 'Isolated' | 'Lunacy' | 'Delusional' | 'Delusion':
					redVignette.setFloat('time', 0.0);
					if (!ClientPrefs.lowQuality)
					{
						camGame.setFilters([
							new ShaderFilter(dramaticCamMovement),
							new ShaderFilter(monitorFilter),
							new ShaderFilter(chromZoomShader),
							new ShaderFilter(chromNormalShader)
						]);
						camHUD.setFilters([new ShaderFilter(chromNormalShader)]);
						camNotes.setFilters([new ShaderFilter(chromNormalShader)]);
					}
					else
					{
						camGame.setFilters([
							new ShaderFilter(monitorFilter),
							new ShaderFilter(chromNormalShader)
						]);
						camHUD.setFilters([new ShaderFilter(chromNormalShader)]);
						camNotes.setFilters([new ShaderFilter(grayScale)]);
					}
				case 'Isolated Old' | 'Isolated Legacy' | 'Isolated Beta' | 'Lunacy Legacy' | 'Delusional Legacy':
					for (sigmas in ['r', 'g', 'b']) legacyChrom.setFloat('${sigmas}Offset', 0.005);

					legacyDistort.setFloat('glitchModifier', 1);
					legacyDistort.setFloat('iTime', 0);
					legacyDistort.setBool('perspectiveOn', true);
					legacyDistort.setBool('vignetteMoving', true);
					legacyDistort.setBool('scanlinesOn', true);
					legacyDistort.setBool('vignetteOn', true);
					legacyDistort.setBool('distortionOn', false);
					legacyDistort.setFloatArray('iResolution', [Lib.current.stage.stageWidth, Lib.current.stage.stageHeight]);

					legacyDefaultDistort.setFloat('glitchModifier', 0);
					legacyDefaultDistort.setFloat('iTime', 0);
					legacyDefaultDistort.setBool('perspectiveOn', true);
					legacyDefaultDistort.setBool('vignetteMoving', true);
					legacyDefaultDistort.setBool('scanlinesOn', true);
					legacyDefaultDistort.setBool('vignetteOn', true);
					legacyDefaultDistort.setBool('distortionOn', true);
					legacyDefaultDistort.setFloatArray('iResolution', [Lib.current.stage.stageWidth, Lib.current.stage.stageHeight]);

					legacyTiltshift.setFloat('bluramount', .5);
					legacyTiltshiftHUD.setFloat('bluramount', .6);

					legacyTiltshift.setFloat('center', 0);
					legacyTiltshiftHUD.setFloat('center', 0);

					if (!ClientPrefs.lowQuality)
					{
						camGame.setFilters([
							new ShaderFilter(legacyChrom),
							new ShaderFilter(legacyDistort),
							new ShaderFilter(legacyGreyscale),
						]);
						
						camHUD.setFilters([
							new ShaderFilter(legacyChrom),
							new ShaderFilter(legacyDefaultDistort),
							new ShaderFilter(legacyTiltshiftHUD),
							new ShaderFilter(legacyGreyscale),
						]);
						camNotes.filters = camHUD.filters;
					}
					else
					{
						camGame.setFilters([new ShaderFilter(grayScale)]);
						camHUD.setFilters([new ShaderFilter(grayScale)]);
					}
				case 'Hunted Legacy':
					blurShader.setFloat('bluramount', 0.6);
					blurShaderHUD.setFloat('bluramount', 0.1);
					andromeda.setFloat('glitchModifier', 0.2);
					andromeda.setBool('perspectiveOn', true);
					andromeda.setBool('vignetteMoving', true);
					if (!ClientPrefs.lowQuality)
					{
						camGame.setFilters([
							new ShaderFilter(grayScale),
							new ShaderFilter(blurShader),
						]);
						@:privateAccess for(_camHUD in [camHUD, camNotes]) _camHUD.setFilters([
							new ShaderFilter(grayScale),
							new ShaderFilter(blurShaderHUD),
							new ShaderFilter(andromeda)
						]);
					}
					else
					{
						camGame.setFilters([new ShaderFilter(grayScale)]);
						camHUD.setFilters([new ShaderFilter(grayScale)]);
					}				
				case 'Scrapped':
					if (!ClientPrefs.lowQuality)
					{
						camGame.setFilters([
							new ShaderFilter(staticEffect),
							new ShaderFilter(blurShader),
							new ShaderFilter(chromNormalShader),
							new ShaderFilter(chromZoomShader)
						]);
						camHUD.setFilters([
							new ShaderFilter(blurShaderHUD),
							new ShaderFilter(chromNormalShader)
						]);
							camNotes.setFilters([
								new ShaderFilter(blurShaderHUD),
								new ShaderFilter(chromNormalShader)
							]);
					}
					else
					{
						camGame.setFilters([new ShaderFilter(chromNormalShader)]);
						camHUD.setFilters([new ShaderFilter(chromNormalShader)]);
						camNotes.setFilters([new ShaderFilter(chromNormalShader)]);
					}
                case 'Twisted Grins' | 'Twisted Grins Legacy':
                    if (!ClientPrefs.lowQuality)
                    {
                        camGame.setFilters([
                            new ShaderFilter(staticEffect)
                        ]);
                    }
                case 'Hunted':
                    if (!ClientPrefs.lowQuality)
                    {
                        camGame.setFilters([
                            new ShaderFilter(dramaticCamMovement),
                            new ShaderFilter(monitorFilter),
                        ]);
                    }
                    else
                    {
                        camGame.setFilters([new ShaderFilter(monitorFilter)]);
                    }
                    camNotes.setFilters([new ShaderFilter(grayScale)]);
                case 'Mercy' | 'Mercy Legacy':
                    if (!ClientPrefs.lowQuality)
                    {
                        camGame.setFilters([
                            new ShaderFilter(waltStatic),
                            new ShaderFilter(dramaticCamMovement)
                        ]);
                    }
                    else
                    {
                        camGame.setFilters([new ShaderFilter(dramaticCamMovement)]);
                    }
                    camHUD.setFilters([new ShaderFilter(dramaticCamMovement)]);
                    camNotes.setFilters([new ShaderFilter(dramaticCamMovement)]);
				case 'Cycled Sins Legacy':
					chromZoomShader.setFloat('aberration', 0.12);
   		 			chromZoomShader.setFloat('effectTime', 0.24);
					camGame.setFilters(
					[
						new ShaderFilter(dramaticCamMovement)
					]);
					camNotes.setFilters([new ShaderFilter(grayScale)]);
			}
		}

		switch (SONG.song)
		{
			case 'Devilish Deal':
				if (!isStoryMode)
				{
					devilishGaming = new VideoSprite(false);
					devilishGaming.load(Paths.video("devilishIntro"), [VideoSprite.muted]);
					add(devilishGaming);
					devilishGaming.cameras = [camVideo];
					devilishGaming.play();
					devilishGaming.visible = false;
					camVideo.visible = true;
					new FlxTimer().start(0.001, function(tmr:FlxTimer)
					{
						devilishGaming.pause();
						devilishGaming.setVideoTime(0);
					});
				}
				dad.setColorTransform(-1, -1, -1, 1, 0, 0, 0, 0);
				camGame.alpha = 0.001;
				camHUD.alpha = 0.001;
				camNotes.alpha = 0.001; // 0.001 doesn't cause lag when setting alpha above 0 for some reason, yet it's still invisible

			case "Delusional":
				deluSing = new VideoSprite(false);
				deluSing.visible = false;
				deluSing.load(Paths.video("deluLyrics"), [VideoSprite.muted]);
				deluSing.cameras = [camVideo];
				deluSing.play();
				deluSing.addCallback("onEnd", () -> {
					deluSing.kill();
					deluSing.destroy();
					deluSing = null;
				});
				death = new VideoSprite(false);
				death.visible = false;
				death.load(Paths.video("mickeyDeath"));
				death.cameras = [camVideo];
				death.play();
				minnieJumpscare = new VideoSprite(false);
				minnieJumpscare.visible = false;
				minnieJumpscare.load(Paths.video("minniePart"), [VideoSprite.muted]);
				minnieJumpscare.cameras = [camVideo];
				minnieJumpscare.play();
				minnieJumpscare.addCallback("onEnd", () -> {
					minnieJumpscare.kill();
					minnieJumpscare.destroy();
					minnieJumpscare = null;
				});
				add(death);
				add(deluSing);
				add(minnieJumpscare);
				new FlxTimer().start(0.001, function(tmr:FlxTimer)
				{
					death.pause();
					deluSing.pause();
					minnieJumpscare.pause();
				});

			case "Twisted Grins":
				for (hud in [camHUD, camNotes])
					hud.visible = false;
				camBars.fade(FlxColor.BLACK, 0.0001);

			case 'Isolated' | 'Lunacy' | 'Cycled Sins' | 'Delusion' | 'Laugh Track':
				camNotes.alpha = 0.001;
				if (finishedScene) camBars.fade(FlxColor.BLACK, 0.0001);
				camHUD.alpha = 0.001;

			case "War Dilemma":
				cinematicBarControls("create", 1);
				cinematicBarControls("moveboth", 0.0001, 'linear', 420);
				camNotes.alpha = 0.001;
				camHUD.alpha = 0.001;

			case 'Mercy Legacy':
				if (ClientPrefs.mechanics)
				{
					limitThing += 25;
					initialCount = limitThing;
				}

			case 'Mercy':
				if (ClientPrefs.mechanics)
				{
					limitThing += 20;
					initialCount = limitThing;
				}

			// Glitched Mickey will give you a big fat middle finger for disabling the mechanics lmao
			case 'Malfunction Legacy':
				add(crashLives);
				add(crashLivesIcon);
				crashLivesCounter += 30;
				crashLives.text = 'Lives: ${crashLivesCounter}';
			case 'Malfunction':
				add(crashLives);
				add(crashLivesIcon);
				if (ClientPrefs.epilepsy)
				{
					for (stuf in [noSignalBG, staticSpr, noSignalLogo])
						add(stuf);
				}
				camNotes.alpha = 0.001;
				camBars.fade(FlxColor.BLACK, 0.0001);
				camHUD.alpha = 0.001;
				crashLivesCounter += 25;
				crashLives.text = 'Lives: ${crashLivesCounter}';
			case 'Birthday':
				camNotes.alpha = 0.001;
				camBars.fade(FlxColor.BLACK, 0.0001);
				camHUD.alpha = 0.001;
			case "Bless":
				camGame.alpha = 0.001;
				camHUD.alpha = 0.001;
				camNotes.alpha = 0.001;
				var letsFight:VideoSprite = new VideoSprite(false);
				letsFight.visible = false;
				letsFight.load(Paths.video("blessCountdown"), [VideoSprite.muted]);
				letsFight.cameras = [camVideo];
				letsFight.addCallback("onEnd", () -> camVideo.visible = false);
				letsFight.play();
				add(letsFight);
				
			default:
				trace("no events");
				//nothing
		}

		lyrics = new FlxTypeText(0, FlxG.height - 65, 0, '', 15);
		lyrics.setFormat(Paths.font('vcr'), 30, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		lyrics.cameras = [camOther];
		lyrics.alpha = 0;
		lyrics.borderSize = 4;
		lyrics.scrollFactor.set();
		lyrics.screenCenter(X).x -= 90;
		add(lyrics);

		lyricsIcon = new HealthIcon('bf', false);
		lyricsIcon.x = lyrics.x - 150;
		lyricsIcon.y = lyrics.y - 65;
		lyricsIcon.visible = false;
		lyricsIcon.cameras = [camOther];
		add(lyricsIcon);

		callOnLuas('onCreatePost', []);

		super.create();

		cacheCountdown();
		cachePopUpScore();
		for (key => type in precacheList)
		{
			//trace('Key $key is type $type');
			switch(type)
			{
				case 'image':
					Paths.image(key);
				case 'sound':
					Paths.sound(key);
				case 'music':
					Paths.music(key);
			}
		}

		//for(i in  0...unspawnNotes.length-1) if(unspawnNotes[i].isSustainNote) unspawnNotes[i].noAnimation = true;
	}

	#if (!flash && sys)
	public var runtimeShaders:Map<String, Array<String>> = new Map<String, Array<String>>();
	public function createRuntimeShader(name:String):FlxRuntimeShader
	{
		if(!ClientPrefs.shaders) return new FlxRuntimeShader();

		#if (!flash && MODS_ALLOWED && sys)
		if(!runtimeShaders.exists(name) && !initLuaShader(name))
		{
			FlxG.log.warn('Shader $name is missing!');
			return new FlxRuntimeShader();
		}

		var arr:Array<String> = runtimeShaders.get(name);
		return new FlxRuntimeShader(arr[0], arr[1]);
		#else
		FlxG.log.warn("Platform unsupported for Runtime Shaders!");
		return null;
		#end
	}

	public function initLuaShader(name:String, ?glslVersion:Int = 120)
	{
		if(!ClientPrefs.shaders) return false;

		if(runtimeShaders.exists(name))
		{
			FlxG.log.warn('Shader $name was already initialized!');
			return true;
		}

		var foldersToCheck:Array<String> = [Paths.mods('shaders/')];
		if(Paths.currentModDirectory != null && Paths.currentModDirectory.length > 0)
			foldersToCheck.insert(0, Paths.mods(Paths.currentModDirectory + '/shaders/'));

		for(mod in Paths.getGlobalMods())
			foldersToCheck.insert(0, Paths.mods(mod + '/shaders/'));
		
		for (folder in foldersToCheck)
		{
			if(FileSystem.exists(folder))
			{
				var frag:String = folder + name + '.frag';
				var vert:String = folder + name + '.vert';
				var found:Bool = false;
				if(FileSystem.exists(frag))
				{
					frag = File.getContent(frag);
					found = true;
				}
				else frag = null;

				if (FileSystem.exists(vert))
				{
					vert = File.getContent(vert);
					found = true;
				}
				else vert = null;

				if(found)
				{
					runtimeShaders.set(name, [frag, vert]);
					//trace('Found shader $name!');
					return true;
				}
			}
		}
		FlxG.log.warn('Missing shader $name .frag AND .vert files!');
		return false;
	}
	#end

	function resetCharPos()
	{
		switch (curStage)
		{
			case 'abandonedStreet':
				switch (dad.curCharacter)
				{
					case 'delusional-mickey':
						dad.setPosition(-260, 120);
					case 'mickey-delu-intro':
						dad.setPosition(-210, 180);
					case 'death-part-1':
						dad.setPosition(-450, 100);
					case 'death-part-2':
						dad.setPosition(-430, 100);
					case 'delumickey' | 'deluMick-eyeless':
						dad.setPosition(-870, -185);
					default:
						dad.setPosition(-870, -190);
				}
				switch (boyfriend.curCharacter)
				{
					case 'evildelu': boyfriend.setPosition(550, 190);
					case 'bf-delu-intro': boyfriend.setPosition(750, 350);
					case 'bf-demon': boyfriend.setPosition(275, 65);
					default: boyfriend.setPosition(275, 50);
				}
			case 'forestNew':
				// It was before perfect but then Jason had put the new spritesheet... im gonna explode :) - MalyPlus
				// lol - jason the jasenous
				dad.setPosition(-110, -15); // goofy ahh goofy offsets - malyplus
				boyfriend.setPosition(480, -220);
				gf.setPosition(170, -70);
			case 'forestOld':
				dad.setPosition(0, 0);
    			boyfriend.setPosition(900, -20);
			case 'theLoop':
				dad.setPosition(0, 0);
				if (boyfriend.curCharacter == 'bf')
				{
					boyfriend.setPosition(1000, 130);
				}else{
					boyfriend.setPosition(500, -320);
				}
			case 'war':
				dad.setPosition(-140, 80);
   	 			boyfriend.setPosition(1500, 650);
			case 'circus' | 'my name is caine and welcome to the amazing digital circus':
				dad.setPosition(-990, -100);
				boyfriend.setPosition(0,-360);
				gf.setPosition(-300, -200);
			case 'treasureIsland':
				boyfriend.setPosition(1080, 310);
				dad.setPosition(0, 190);
			case 'clubhouse':
				switch (dad.curCharacter)
				{
					case 'munpet':
						dad.setPosition(-240, 0);
					default:
						dad.setPosition(-240, -260);
				}
				switch (boyfriend.curCharacter)
				{
					case 'xyloboy':
						boyfriend.setPosition(650, -100);
					default:
						boyfriend.setPosition(650, -360);
				}
				gf.setPosition(280, -410);
			case 'desktop':
				boyfriend.setPosition(300, 400);
				gf.setPosition(250, 600);
				dad.setPosition(-1100, 350);
			case 'forbiddenRealm':
				if (dad.curCharacter == 'gm-calm-pixel')
					dad.setPosition(-130, 50);
				else
					dad.setPosition(-100, 150);
				
				boyfriend.setPosition(1300, 600);
			case 'trueGrinsOfSins':
				boyfriend.setPosition(1300, 400);
				dad.setPosition(0, 0);
				gf.setPosition(1100, 560);
			case 'vaultRoom':
				boyfriend.setPosition(960, 530);
				if (dad.curCharacter == 'white-noise-new') dad.setPosition(-680, -520); else dad.setPosition(90, 60);
			case 'waltRoom':
				switch (dad.curCharacter)
				{
					case 'walt-true':
						dad.setPosition(240, -200);
					case 'walt-new':
						dad.setPosition(220, -50);
					default:
						dad.setPosition(0, 0);
				}
				boyfriend.setPosition(330, 300);
			case 'trance':
				dad.setPosition(-861, -259);
				boyfriend.setPosition(260, 0);
			case 'apartment':
				dad.setPosition(-1000, 270);
    			boyfriend.setPosition(590, 250);
			case 'smilesOffice':
				boyfriend.setPosition(1000, 300);
				dad.setPosition(200, 400);
			case 'fuckingLine':
				dad.setPosition(-400, -150);
				boyfriend.setPosition(900, 300);
			case 'alleyway' | 'ddStage':
				boyfriend.setPosition(770, 450);
				dad.setPosition(1660, 120);
			default:
				boyfriend.setPosition(770, 450);
				dad.setPosition(100, 100);
				gf.setPosition(300, 100);
		}
	}

	function set_songSpeed(value:Float):Float
	{
		if(generatedMusic)
		{
			var ratio:Float = value / songSpeed; //funny word huh
			for (note in notes) note.resizeByRatio(ratio);
			for (note in unspawnNotes) note.resizeByRatio(ratio);
		}
		songSpeed = value;
		noteKillOffset = 350 / songSpeed;
		return value;
	}

	function set_playbackRate(value:Float):Float
	{
		if(generatedMusic)
		{
			if(vocals != null) vocals.pitch = value;
			if(bf_vocals != null) bf_vocals.pitch = value;
			if(opp_vocals != null)opp_vocals.pitch = value;
			inst.pitch = value;
		}
		playbackRate = value;
		FlxAnimationController.globalSpeed = value;
		trace('Anim speed: ' + FlxAnimationController.globalSpeed);
		Conductor.safeZoneOffset = (ClientPrefs.safeFrames / 60) * 1000 * value;
		setOnLuas('playbackRate', playbackRate);
		return value;
	}

	public function addTextToDebug(text:String, color:FlxColor) {
		#if LUA_ALLOWED
		luaDebugGroup.forEachAlive(function(spr:DebugLuaText) {
			spr.y += 20;
		});

		if(luaDebugGroup.members.length > 34) {
			var blah = luaDebugGroup.members[34];
			blah.destroy();
			luaDebugGroup.remove(blah);
		}
		luaDebugGroup.insert(0, new DebugLuaText(text, luaDebugGroup, color));
		#end
	}

	public function reloadHealthBarColors() {
		switch (SONG.song)
		{
			case "Mercy":
				healthBar.createFilledBar(FlxColor.fromRGB(97, 72, 52), FlxColor.fromRGB(255, 239, 176));
			case "Devilish Deal":
				healthBar.createFilledBar(FlxColor.fromRGB(135, 99, 99), FlxColor.fromRGB(158, 158, 158));
			default:
				healthBar.createFilledBar(FlxColor.fromRGB(dad.healthColorArray[0], dad.healthColorArray[1], dad.healthColorArray[2]),
				FlxColor.fromRGB(boyfriend.healthColorArray[0], boyfriend.healthColorArray[1], boyfriend.healthColorArray[2]));
		}
		healthBar.updateBar();
	}

	public function addCharacterToList(newCharacter:String, type:Int) {
		switch(type) {
			case 0:
				if(!boyfriendMap.exists(newCharacter)) {
					var newBoyfriend:Boyfriend = new Boyfriend(0, 0, newCharacter);
					boyfriendMap.set(newCharacter, newBoyfriend);
					boyfriendGroup.add(newBoyfriend);
					startCharacterPos(newBoyfriend);
					newBoyfriend.alpha = 0.00001;
					startCharacterLua(newBoyfriend.curCharacter);
				}

			case 1:
				if(!dadMap.exists(newCharacter)) {
					var newDad:Character = new Character(0, 0, newCharacter);
					dadMap.set(newCharacter, newDad);
					dadGroup.add(newDad);
					startCharacterPos(newDad, true);
					newDad.alpha = 0.00001;
					startCharacterLua(newDad.curCharacter);
				}

			case 2:
				if(gf != null && !gfMap.exists(newCharacter)) {
					var newGf:Character = new Character(0, 0, newCharacter);
					newGf.scrollFactor.set(0.95, 0.95);
					gfMap.set(newCharacter, newGf);
					gfGroup.add(newGf);
					startCharacterPos(newGf);
					newGf.alpha = 0.00001;
					startCharacterLua(newGf.curCharacter);
				}
		}
	}

	function startCharacterLua(name:String)
	{
		#if LUA_ALLOWED
		var doPush:Bool = false;
		var luaFile:String = 'characters/' + name + '.lua';
		#if MODS_ALLOWED
		if(FileSystem.exists(Paths.modFolders(luaFile))) {
			luaFile = Paths.modFolders(luaFile);
			doPush = true;
		} else {
			luaFile = Paths.getPreloadPath(luaFile);
			if(FileSystem.exists(luaFile)) {
				doPush = true;
			}
		}
		#else
		luaFile = Paths.getPreloadPath(luaFile);
		if(Assets.exists(luaFile)) {
			doPush = true;
		}
		#end

		if(doPush)
		{
			for (script in luaArray)
			{
				if(script.scriptName == luaFile) return;
			}
			luaArray.push(new FunkinLua(luaFile));
		}
		#end
	}

	public function getLuaObject(tag:String, text:Bool=true):FlxSprite {
		if(modchartSprites.exists(tag)) return modchartSprites.get(tag);
		if(text && modchartTexts.exists(tag)) return modchartTexts.get(tag);
		if(variables.exists(tag)) return variables.get(tag);
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

	public function playVideoSprite(name:String, ?vis:Bool = true, finishCallback:()->Void, x:Float = 0, y:Float = 0, scaleX:Float = 1, scaleY:Float = 1){
		videoSprite = new VideoSprite(false);
		videoSprite.scrollFactor.set();
		videoSprite.scale.set(scaleX, scaleY);
		videoSprite.x = x;
		videoSprite.y = y;
		videoSprite.cameras = [camVideo];
		videoSprite.visible = vis;
		videoSprite.onEndCallback = ()->{
			trace("video gone");
			remove(videoSprite);
			videoSprite.kill();
		};

		camVideo.visible = true;

		videoSprite.onStartCallback = ()->{
			//im pr sure this is redundant now with hxvlc not starting vid until play is called but whatyever lol
			if(vis) videoSprite.visible=true;
		};

		// this is weird but oh well! it works tho!
		videoSprite.addCallback("onEnd", () -> {
			camVideo.visible = false;
			if (finishCallback != null) finishCallback();
		});

		videoSprite.load(Paths.video(name));
		videoSprite.play();
		add(videoSprite);
	}

	function startAndEnd()
	{
		if(endingSong)
			endSong();
		else
			startCountdown();
	}

	var dialogueCount:Int = 0;
	public var psychDialogue:DialogueBoxPsych;
	//You don't have to add a song, just saying. You can just do "startDialogue(dialogueJson);" and it should work
	public function startDialogue(dialogueFile:DialogueFile, ?song:String = null):Void
	{
		// TO DO: Make this more flexible, maybe?
		if(psychDialogue != null) return;

		if(dialogueFile.dialogue.length > 0) {
			inCutscene = true;
			precacheList.set('dialogue', 'sound');
			precacheList.set('dialogueClose', 'sound');
			psychDialogue = new DialogueBoxPsych(dialogueFile, song);
			psychDialogue.scrollFactor.set();
			if(endingSong) {
				psychDialogue.finishThing = function() {
					psychDialogue = null;
					endSong();
				}
			} else {
				psychDialogue.finishThing = function() {
					psychDialogue = null;
					startCountdown();
				}
			}
			psychDialogue.nextDialogueThing = startNextDialogue;
			psychDialogue.skipDialogueThing = skipDialogue;
			psychDialogue.cameras = [camHUD];
			add(psychDialogue);
		} else {
			FlxG.log.warn('Your dialogue file is badly formatted!');
			if(endingSong) {
				endSong();
			} else {
				startCountdown();
			}
		}
	}

	function schoolIntro(?dialogueBox:DialogueBox):Void
	{
		inCutscene = true;
		var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		black.scrollFactor.set();
		add(black);

		var red:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFff1b31);
		red.scrollFactor.set();

		var senpaiEvil:FlxSprite = new FlxSprite();
		senpaiEvil.frames = Paths.getSparrowAtlas('weeb/senpaiCrazy');
		senpaiEvil.animation.addByPrefix('idle', 'Senpai Pre Explosion', 24, false);
		senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * 6));
		senpaiEvil.scrollFactor.set();
		senpaiEvil.updateHitbox();
		senpaiEvil.screenCenter();
		senpaiEvil.x += 300;

		var songName:String = Paths.formatToSongPath(SONG.song);
		if (songName == 'roses' || songName == 'thorns')
		{
			remove(black);

			if (songName == 'thorns')
			{
				add(red);
				camHUD.visible = false;
			}
		}

		new FlxTimer().start(0.3, function(tmr:FlxTimer)
		{
			black.alpha -= 0.15;

			if (black.alpha > 0)
			{
				tmr.reset(0.3);
			}
			else
			{
				if (dialogueBox != null)
				{
					if (Paths.formatToSongPath(SONG.song) == 'thorns')
					{
						add(senpaiEvil);
						senpaiEvil.alpha = 0;
						new FlxTimer().start(0.3, function(swagTimer:FlxTimer)
						{
							senpaiEvil.alpha += 0.15;
							if (senpaiEvil.alpha < 1)
							{
								swagTimer.reset();
							}
							else
							{
								senpaiEvil.animation.play('idle');
								FlxG.sound.play(Paths.sound('Senpai_Dies'), 1, false, null, true, function()
								{
									remove(senpaiEvil);
									remove(red);
									FlxG.camera.fade(FlxColor.WHITE, 0.01, true, function()
									{
										add(dialogueBox);
										camHUD.visible = true;
									}, true);
								});
								new FlxTimer().start(3.2, function(deadTime:FlxTimer)
								{
									FlxG.camera.fade(FlxColor.WHITE, 1.6, false);
								});
							}
						});
					}
					else
					{
						add(dialogueBox);
					}
				}
				else
					startCountdown();

				remove(black);
			}
		});
	}

	function tankIntro()
	{
		var cutsceneHandler:CutsceneHandler = new CutsceneHandler();

		var songName:String = Paths.formatToSongPath(SONG.song);
		dadGroup.alpha = 0.00001;
		camHUD.visible = false;
		//inCutscene = true; //this would stop the camera movement, oops

		var tankman:FlxSprite = new FlxSprite(-20, 320);
		tankman.frames = Paths.getSparrowAtlas('cutscenes/' + songName);
		tankman.antialiasing = ClientPrefs.globalAntialiasing;
		addBehindDad(tankman);
		cutsceneHandler.push(tankman);

		var tankman2:FlxSprite = new FlxSprite(16, 312);
		tankman2.antialiasing = ClientPrefs.globalAntialiasing;
		tankman2.alpha = 0.000001;
		cutsceneHandler.push(tankman2);
		var gfDance:FlxSprite = new FlxSprite(gf.x - 107, gf.y + 140);
		gfDance.antialiasing = ClientPrefs.globalAntialiasing;
		cutsceneHandler.push(gfDance);
		var gfCutscene:FlxSprite = new FlxSprite(gf.x - 104, gf.y + 122);
		gfCutscene.antialiasing = ClientPrefs.globalAntialiasing;
		cutsceneHandler.push(gfCutscene);
		var picoCutscene:FlxSprite = new FlxSprite(gf.x - 849, gf.y - 264);
		picoCutscene.antialiasing = ClientPrefs.globalAntialiasing;
		cutsceneHandler.push(picoCutscene);
		var boyfriendCutscene:FlxSprite = new FlxSprite(boyfriend.x + 5, boyfriend.y + 20);
		boyfriendCutscene.antialiasing = ClientPrefs.globalAntialiasing;
		cutsceneHandler.push(boyfriendCutscene);

		cutsceneHandler.finishCallback = function()
		{
			var timeForStuff:Float = Conductor.crochet / 1000 * 4.5;
			FlxG.sound.music.fadeOut(timeForStuff);
			FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, timeForStuff, {ease: FlxEase.quadInOut});
			moveCamera(true);
			startCountdown();

			dadGroup.alpha = 1;
			camHUD.visible = true;
			boyfriend.animation.finishCallback = null;
			gf.animation.finishCallback = null;
			gf.dance();
		};

		camFollow.set(dad.x + 280, dad.y + 170);
		switch(songName)
		{
			case 'ugh':
				cutsceneHandler.endTime = 12;
				cutsceneHandler.music = 'DISTORTO';
				precacheList.set('wellWellWell', 'sound');
				precacheList.set('killYou', 'sound');
				precacheList.set('bfBeep', 'sound');

				var wellWellWell:FlxSound = new FlxSound().loadEmbedded(Paths.sound('wellWellWell'));
				FlxG.sound.list.add(wellWellWell);

				tankman.animation.addByPrefix('wellWell', 'TANK TALK 1 P1', 24, false);
				tankman.animation.addByPrefix('killYou', 'TANK TALK 1 P2', 24, false);
				tankman.animation.play('wellWell', true);
				FlxG.camera.zoom *= 1.2;

				// Well well well, what do we got here?
				cutsceneHandler.timer(0.1, function()
				{
					wellWellWell.play(true);
				});

				// Move camera to BF
				cutsceneHandler.timer(3, function()
				{
					camFollow.x += 750;
					camFollow.y += 100;
				});

				// Beep!
				cutsceneHandler.timer(4.5, function()
				{
					boyfriend.playAnim('singUP', true);
					boyfriend.specialAnim = true;
					FlxG.sound.play(Paths.sound('bfBeep'));
				});

				// Move camera to Tankman
				cutsceneHandler.timer(6, function()
				{
					camFollow.x -= 750;
					camFollow.y -= 100;

					// We should just kill you but... what the hell, it's been a boring day... let's see what you've got!
					tankman.animation.play('killYou', true);
					FlxG.sound.play(Paths.sound('killYou'));
				});

			case 'guns':
				cutsceneHandler.endTime = 11.5;
				cutsceneHandler.music = 'DISTORTO';
				tankman.x += 40;
				tankman.y += 10;
				precacheList.set('tankSong2', 'sound');

				var tightBars:FlxSound = new FlxSound().loadEmbedded(Paths.sound('tankSong2'));
				FlxG.sound.list.add(tightBars);

				tankman.animation.addByPrefix('tightBars', 'TANK TALK 2', 24, false);
				tankman.animation.play('tightBars', true);
				boyfriend.animation.curAnim.finish();

				cutsceneHandler.onStart = function()
				{
					tightBars.play(true);
					FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom * 1.2}, 4, {ease: FlxEase.quadInOut});
					FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom * 1.2 * 1.2}, 0.5, {ease: FlxEase.quadInOut, startDelay: 4});
					FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom * 1.2}, 1, {ease: FlxEase.quadInOut, startDelay: 4.5});
				};

				cutsceneHandler.timer(4, function()
				{
					gf.playAnim('sad', true);
					gf.animation.finishCallback = function(name:String)
					{
						gf.playAnim('sad', true);
					};
				});

			case 'stress':
				cutsceneHandler.endTime = 35.5;
				tankman.x -= 54;
				tankman.y -= 14;
				gfGroup.alpha = 0.00001;
				boyfriendGroup.alpha = 0.00001;
				camFollow.set(dad.x + 400, dad.y + 170);
				FlxTween.tween(FlxG.camera, {zoom: 0.9 * 1.2}, 1, {ease: FlxEase.quadInOut});
				foregroundSprites.forEach(function(spr:BGSprite)
				{
					spr.y += 100;
				});
				precacheList.set('stressCutscene', 'sound');

				tankman2.frames = Paths.getSparrowAtlas('cutscenes/stress2');
				addBehindDad(tankman2);

				if (!ClientPrefs.lowQuality)
				{
					gfDance.frames = Paths.getSparrowAtlas('characters/gfTankmen');
					gfDance.animation.addByPrefix('dance', 'GF Dancing at Gunpoint', 24, true);
					gfDance.animation.play('dance', true);
					addBehindGF(gfDance);
				}

				gfCutscene.frames = Paths.getSparrowAtlas('cutscenes/stressGF');
				gfCutscene.animation.addByPrefix('dieBitch', 'GF STARTS TO TURN PART 1', 24, false);
				gfCutscene.animation.addByPrefix('getRektLmao', 'GF STARTS TO TURN PART 2', 24, false);
				gfCutscene.animation.play('dieBitch', true);
				gfCutscene.animation.pause();
				addBehindGF(gfCutscene);
				if (!ClientPrefs.lowQuality)
				{
					gfCutscene.alpha = 0.00001;
				}

				picoCutscene.frames = AtlasFrameMaker.construct('cutscenes/stressPico');
				picoCutscene.animation.addByPrefix('anim', 'Pico Badass', 24, false);
				addBehindGF(picoCutscene);
				picoCutscene.alpha = 0.00001;

				boyfriendCutscene.frames = Paths.getSparrowAtlas('characters/BOYFRIEND');
				boyfriendCutscene.animation.addByPrefix('idle', 'BF idle dance', 24, false);
				boyfriendCutscene.animation.play('idle', true);
				boyfriendCutscene.animation.curAnim.finish();
				addBehindBF(boyfriendCutscene);

				var cutsceneSnd:FlxSound = new FlxSound().loadEmbedded(Paths.sound('stressCutscene'));
				FlxG.sound.list.add(cutsceneSnd);

				tankman.animation.addByPrefix('godEffingDamnIt', 'TANK TALK 3', 24, false);
				tankman.animation.play('godEffingDamnIt', true);

				var calledTimes:Int = 0;
				var zoomBack:Void->Void = function()
				{
					var camPosX:Float = 630;
					var camPosY:Float = 425;
					camFollow.set(camPosX, camPosY);
					camFollowPos.setPosition(camPosX, camPosY);
					FlxG.camera.zoom = 0.8;
					cameraSpeed = 1;

					calledTimes++;
					if (calledTimes > 1)
					{
						foregroundSprites.forEach(function(spr:BGSprite)
						{
							spr.y -= 100;
						});
					}
				}

				cutsceneHandler.onStart = function()
				{
					cutsceneSnd.play(true);
				};

				cutsceneHandler.timer(15.2, function()
				{
					FlxTween.tween(camFollow, {x: 650, y: 300}, 1, {ease: FlxEase.sineOut});
					FlxTween.tween(FlxG.camera, {zoom: 0.9 * 1.2 * 1.2}, 2.25, {ease: FlxEase.quadInOut});

					gfDance.visible = false;
					gfCutscene.alpha = 1;
					gfCutscene.animation.play('dieBitch', true);
					gfCutscene.animation.finishCallback = function(name:String)
					{
						if(name == 'dieBitch') //Next part
						{
							gfCutscene.animation.play('getRektLmao', true);
							gfCutscene.offset.set(224, 445);
						}
						else
						{
							gfCutscene.visible = false;
							picoCutscene.alpha = 1;
							picoCutscene.animation.play('anim', true);

							boyfriendGroup.alpha = 1;
							boyfriendCutscene.visible = false;
							boyfriend.playAnim('bfCatch', true);
							boyfriend.animation.finishCallback = function(name:String)
							{
								if(name != 'idle')
								{
									boyfriend.playAnim('idle', true);
									boyfriend.animation.curAnim.finish(); //Instantly goes to last frame
								}
							};

							picoCutscene.animation.finishCallback = function(name:String)
							{
								picoCutscene.visible = false;
								gfGroup.alpha = 1;
								picoCutscene.animation.finishCallback = null;
							};
							gfCutscene.animation.finishCallback = null;
						}
					};
				});

				cutsceneHandler.timer(17.5, function()
				{
					zoomBack();
				});

				cutsceneHandler.timer(19.5, function()
				{
					tankman2.animation.addByPrefix('lookWhoItIs', 'TANK TALK 3', 24, false);
					tankman2.animation.play('lookWhoItIs', true);
					tankman2.alpha = 1;
					tankman.visible = false;
				});

				cutsceneHandler.timer(20, function()
				{
					camFollow.set(dad.x + 500, dad.y + 170);
				});

				cutsceneHandler.timer(31.2, function()
				{
					boyfriend.playAnim('singUPmiss', true);
					boyfriend.animation.finishCallback = function(name:String)
					{
						if (name == 'singUPmiss')
						{
							boyfriend.playAnim('idle', true);
							boyfriend.animation.curAnim.finish(); //Instantly goes to last frame
						}
					};

					camFollow.set(boyfriend.x + 280, boyfriend.y + 200);
					cameraSpeed = 12;
					FlxTween.tween(FlxG.camera, {zoom: 0.9 * 1.2 * 1.2}, 0.25, {ease: FlxEase.elasticOut});
				});

				cutsceneHandler.timer(32.2, function()
				{
					zoomBack();
				});
		}
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
		introAssets.set('sins', ['favi/countdown/relapse2NEW-prepare', 'favi/countdown/relapse2NEW-ready', 'favi/countdown/relapse2NEW-set', 'favi/countdown/relapse2NEW-go']);

		var introAlts:Array<String> = introAssets.get('default');
		switch (SONG.song)
		{
			case "Isolated" | "Devilish Deal" | "Lunacy" | "Delusional" | "Hunted" | "Twisted Grins" | "Laugh Track" |  "Isolated Old" | "Isolated Beta" | "Isolated Legacy" | "Lunacy Legacy" | "Delusional Legacy" | "Hunted Legacy" | "Birthday" | "Rotten Petals" | "Curtain Call" | "Seeking Freedom" | "A True Monster" | "Am I Real?" | "Your Final Bow" | "Ship the Fart Yay Hooray <3 (Distant Stars)" | "The Wretched Tilezones (Simple Life)" | "Ahh the Scary (Somber Night)":
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

	public function startCountdown():Void
	{
		if(startedCountdown) {
			callOnLuas('onStartCountdown', []);
			return;
		}

		inCutscene = false;
		var ret:Dynamic = callOnLuas('onStartCountdown', [], false);
		if(ret != FunkinLua.Function_Stop) {
			if (skipCountdown || startOnTime > 0) skipArrowStartTween = true;

			generateStaticArrows(0);
			generateStaticArrows(1);

			NoteMovement.getDefaultStrumPos(this);

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
					bf_vocals.pause();
					opp_vocals.pause();
				}
	
				openSubState(new Prompt('Are you sure you want to quit?\n\nYou will lose your unsaved progress.', 0, function(){
					System.exit(0);
					DiscordClient.shutdown();
				}, function(){
					persistentUpdate = true;
					persistentDraw = true;
				},false, camOther));
				Lib.application.window.onClose.cancel();
			});

			for (i in 0...playerStrums.length) {
				setOnLuas('defaultPlayerStrumX' + i, playerStrums.members[i].x);
				setOnLuas('defaultPlayerStrumY' + i, playerStrums.members[i].y);
			}
			for (i in 0...opponentStrums.length) {
				setOnLuas('defaultOpponentStrumX' + i, opponentStrums.members[i].x);
				setOnLuas('defaultOpponentStrumY' + i, opponentStrums.members[i].y);
				if(middlescroll) 
				{
					opponentStrums.members[i].x -= 99999999;
					opponentStrums.members[i].visible = false;
				}
			}

			startedCountdown = true;
			Conductor.songPosition = SONG.song == "Cycled Sins" ? ((-.8 * 5) * 1000) : -Conductor.crochet * 5;
			setOnLuas('startedCountdown', true);
			callOnLuas('onCountdownStarted', []);

			var swagCounter:Int = 0;

			if(startOnTime < 0) startOnTime = 0;

			if (startOnTime > 0) {
				clearNotesBefore(startOnTime);
				setSongTime(startOnTime - 350);
				return;
			}
			else if (skipCountdown)
			{
				setSongTime(0);
				return;
			}

			startTimer = new FlxTimer().start(SONG.song == "Cycled Sins" ? .8 : Conductor.crochet / 1000 / playbackRate, function(tmr:FlxTimer)
			{
				if (gf != null && tmr.loopsLeft % Math.round(gfSpeed * gf.danceEveryNumBeats) == 0 && gf.animation.curAnim != null && !gf.animation.curAnim.name.startsWith("sing") && !gf.stunned)
				{
					gf.dance();
				}
				if (tmr.loopsLeft % boyfriend.danceEveryNumBeats == 0 && boyfriend.animation.curAnim != null && !boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.stunned)
				{
					boyfriend.dance();
				}
				if (tmr.loopsLeft % dad.danceEveryNumBeats == 0 && dad.animation.curAnim != null && !dad.animation.curAnim.name.startsWith('sing') && !dad.stunned)
				{
					dad.dance();
				}

				var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
				introAssets.set('default', ['ready', 'set', 'go']);
				introAssets.set('pixel', ['pixelUI/ready-pixel', 'pixelUI/set-pixel', 'pixelUI/date-pixel']);
				introAssets.set('cartoon', ['favi/countdown/prepare', 'favi/countdown/ready', 'favi/countdown/set', 'favi/countdown/go']);
				introAssets.set('malfunction', ['favi/countdown/mal-prepare', 'favi/countdown/mal-ready', 'favi/countdown/mal-set', 'favi/countdown/mal-go']);
				introAssets.set('sins', ['favi/countdown/relapse2NEW-prepare', 'favi/countdown/relapse2NEW-ready', 'favi/countdown/relapse2NEW-set', 'favi/countdown/relapse2NEW-go']);

				var introAlts:Array<String> = introAssets.get('default');
				var antialias:Bool = ClientPrefs.globalAntialiasing;
				switch (SONG.song)
				{
					case "Isolated" | "Devilish Deal" | "Lunacy" | "Delusional" | "Hunted" | "Twisted Grins" | "Laugh Track" |  "Isolated Old" | "Isolated Beta" | "Isolated Legacy" | "Lunacy Legacy" | "Delusional Legacy" | "Hunted Legacy" | "Birthday" | "Rotten Petals" | "Curtain Call" | "Seeking Freedom" | "A True Monster" | "Am I Real?" | "Your Final Bow" | "Ship the Fart Yay Hooray <3 (Distant Stars)" | "The Wretched Tilezones (Simple Life)" | "Ahh the Scary (Somber Night)":
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

				// head bopping for bg characters on Mall
				if(curStage == 'mall') {
					if(!ClientPrefs.lowQuality)
						upperBoppers.dance(true);

					bottomBoppers.dance(true);
					santa.dance(true);
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
									case "War Dilemma" | "Dont Cross" | "Bless" | "Mercy" | "Mercy Legacy" | "Delutrance":
										//nothing
									default:
										insert(members.indexOf(notes), countdownIntro);
										FlxTween.tween(countdownIntro, {alpha: 0}, Conductor.crochet / 1000, {
											ease: FlxEase.cubeInOut,
											onComplete: function(twn:FlxTween)
											{
												remove(countdownIntro);
												countdownIntro.destroy();
											}
										});
								}

						count3.play();
					case 1:
						switch (SONG.song)
						{
							case "War Dilemma" | "Dont Cross" | "Bless" | "Mercy" | "Mercy Legacy" | "Delutrance":
								countdownReady = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
							default:
								countdownReady = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
						}
						countdownReady.cameras = [camOther];
						countdownReady.scrollFactor.set();
						countdownReady.updateHitbox();

						if (isPixelStage)
							countdownReady.setGraphicSize(Std.int(countdownReady.width * daPixelZoom));

						countdownReady.screenCenter();
						countdownReady.antialiasing = antialias;
						insert(members.indexOf(notes), countdownReady);
						FlxTween.tween(countdownReady, {/*y: countdownReady.y + 100,*/ alpha: 0}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								remove(countdownReady);
								countdownReady.destroy();
							}
						});
						count2.play();
					case 2:
						switch (SONG.song)
						{
							case "War Dilemma" | "Dont Cross" | "Bless" | "Mercy" | "Mercy Legacy" | "Delutrance":
								countdownSet = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
							default:
								countdownSet = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
						}
						
						countdownSet.cameras = [camOther];
						countdownSet.scrollFactor.set();

						if (isPixelStage)
							countdownSet.setGraphicSize(Std.int(countdownSet.width * daPixelZoom));

						countdownSet.screenCenter();
						countdownSet.antialiasing = antialias;
						insert(members.indexOf(notes), countdownSet);
						FlxTween.tween(countdownSet, {/*y: countdownSet.y + 100,*/ alpha: 0}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								remove(countdownSet);
								countdownSet.destroy();
							}
						});
						count1.play();
					case 3:
						switch (SONG.song)
						{
							case "War Dilemma" | "Dont Cross" | "Bless" | "Mercy" | "Mercy Legacy" | "Delutrance":
								countdownGo = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
							default:
								countdownGo = new FlxSprite().loadGraphic(Paths.image(introAlts[3]));
						}
						countdownGo.cameras = [camOther];
						countdownGo.scrollFactor.set();

						if (isPixelStage)
							countdownGo.setGraphicSize(Std.int(countdownGo.width * daPixelZoom));

						countdownGo.updateHitbox();

						countdownGo.screenCenter();
						countdownGo.antialiasing = antialias;
						insert(members.indexOf(notes), countdownGo);
						FlxTween.tween(countdownGo, {/*y: countdownGo.y + 100,*/ alpha: 0}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								remove(countdownGo);
								countdownGo.destroy();
							}
						});
						countGo.play();
					case 4:
						if (ClientPrefs.pauseCountdown)
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
					if(ClientPrefs.opponentStrums || note.mustPress)
					{
						note.copyAlpha = false;
						note.alpha = note.multAlpha;
						if(middlescroll && !note.mustPress) {
							note.alpha *= 0.35;
						}
					}
				});
				callOnLuas('onCountdownTick', [swagCounter]);

				swagCounter += 1;
				// generateSong('fresh');
			}, 6);
		}
	}

	public function addBehindGF(obj:FlxObject)
	{
		insert(members.indexOf(gfGroup), obj);
	}
	public function addBehindBF(obj:FlxObject)
	{
		insert(members.indexOf(boyfriendGroup), obj);
	}
	public function addBehindDad (obj:FlxObject)
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

				daNote.kill();
				notes.remove(daNote, true);
				daNote.destroy();
			}
			--i;
		}
	}

	public function updateScore(miss:Bool = false)
	{
		scoreTxt.text = 'Score: ' + songScore
		+ ' | Combo Breaks: ' + songMisses
		+ ' | Rank: ' + (ratingName != '?' ? '$ratingFC (${Highscore.floorDecimal(ratingPercent * 100, 2)}%)' : '?');

		#if desktop
		#if DEV_BUILD
		DiscordClient.changePresence("Playing a song", scoreTxt.text, "icon", "random");
		#else
		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText, scoreTxt.text, (useFakeDeluName ? "regret" : iconRPC), "random", true, songLength - Conductor.songPosition - ClientPrefs.noteOffset);
		#end
		#end

		if(ClientPrefs.scoreZoom && !miss && !cpuControlled)
		{
			if(scoreTxtTween != null) {
				scoreTxtTween.cancel();
			}
			scoreTxt.scale.x = 1.075;
			scoreTxt.scale.y = 1.075;
			scoreTxtTween = FlxTween.tween(scoreTxt.scale, {x: 1, y: 1}, 0.2, {
				onComplete: function(twn:FlxTween) {
					scoreTxtTween = null;
				}
			});
		}
		callOnLuas('onUpdateScore', [miss]);
	}

	public function setSongTime(time:Float)
	{
		if(time < 0) time = 0;

		inst.pause();
		vocals.pause();
		bf_vocals.pause();
		opp_vocals.pause();

		inst.time = time;
		inst.pitch = playbackRate;
		inst.play();

		if (Conductor.songPosition <= vocals.length)
		{
			vocals.time = time;
			vocals.pitch = playbackRate;
		}
		if (Conductor.songPosition <= bf_vocals.length)
		{
			bf_vocals.time = time;
			bf_vocals.pitch = playbackRate;
		}
		if (Conductor.songPosition <= opp_vocals.length)
		{
			opp_vocals.time = time;
			opp_vocals.pitch = playbackRate;
		}
		vocals.play();
		bf_vocals.play();
		opp_vocals.play();
		Conductor.songPosition = time;
		songTime = time;
	}

	function startNextDialogue() {
		dialogueCount++;
		callOnLuas('onNextDialogue', [dialogueCount]);
	}

	function skipDialogue() {
		callOnLuas('onSkipDialogue', [dialogueCount]);
	}

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	function startSong():Void
	{
		startingSong = false;

		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		inst.play();
		inst.pitch = playbackRate;
		inst.onComplete = finishSong.bind();
		vocals.play();
		bf_vocals.play();
		opp_vocals.play();

		if(startOnTime > 0)
		{
			setSongTime(startOnTime - 500);
		}
		startOnTime = 0;

		if(paused) {
			//trace('Oopsie doopsie! Paused sound');
			inst.pause();
			vocals.pause();
			bf_vocals.pause();
			opp_vocals.pause();
		}

		// Song duration in a float, useful for the time left feature
		songLength = inst.length;
		FlxTween.tween(timeBar, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
		FlxTween.tween(timeTxt, {alpha: 1}, 0.5, {ease: FlxEase.circOut});

		switch(curStage)
		{
			case 'tank':
				if(!ClientPrefs.lowQuality) tankWatchtower.dance();
				foregroundSprites.forEach(function(spr:BGSprite)
				{
					spr.dance();
				});
		}
		

		#if DISCORD_ALLOWED
		#if DEV_BUILD
		DiscordClient.changePresence("Playing a song", scoreTxt.text, "icon", "random");
		#else
		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText, scoreTxt.text, (useFakeDeluName ? "regret" : iconRPC), "random", true, songLength);
		#end
		#end
		setOnLuas('songLength', songLength);
		callOnLuas('onSongStart', []);
	}

	var debugNum:Int = 0;
	private var noteTypeMap:Map<String, Bool> = new Map<String, Bool>();
	private var eventPushedMap:Map<String, Bool> = new Map<String, Bool>();
	private function generateSong(dataPath:String):Void
	{
		// FlxG.log.add(ChartParser.parse());
		songSpeedType = ClientPrefs.getGameplaySetting('scrolltype','multiplicative');

		if (SONG.voiceSfx1 == null)
			SONG.voiceSfx1 = "Player";
		if (SONG.voiceSfx2 == null)
			SONG.voiceSfx2 = 'Opponent';

		switch(songSpeedType)
		{
			case "multiplicative":
				songSpeed = SONG.speed * ClientPrefs.getGameplaySetting('scrollspeed', 1);
			case "constant":
				songSpeed = ClientPrefs.getGameplaySetting('scrollspeed', 1);
		}

		var songData = SONG;
		Conductor.bpm = (songData.bpm);

		curSong = songData.song;

		switch (SONG.song)
		{
			case "Rotten Petals":
				inst = new FlxSound().loadEmbedded(Paths.music("aviOST/rottenPetals"));
			case "Seeking Freedom":
				inst = new FlxSound().loadEmbedded(Paths.music("aviOST/seekingFreedom"));
			case "Curtain Call":
				inst = new FlxSound().loadEmbedded(Paths.music("aviOST/curtainCall"));
			case "A True Monster":
				inst = new FlxSound().loadEmbedded(Paths.music("aviOST/aTrueMonster"));
			case "Am I Real?":
				inst = new FlxSound().loadEmbedded(Paths.music("aviOST/gameOver/amIReal"));
			case "Your Final Bow":
				inst = new FlxSound().loadEmbedded(Paths.music("aviOST/gameOver/yourFinalBow"));
			case "The Wretched Tilezones (Simple Life)":
				inst = new FlxSound().loadEmbedded(Paths.music("aviOST/pause/theWretchedTilezones"));
			case "Ahh the Scary (Somber Night)":
				inst = new FlxSound().loadEmbedded(Paths.music("aviOST/pause/somberNight"));
			case "Ship the Fart Yay Hooray <3 (Distant Stars)":
				inst = new FlxSound().loadEmbedded(Paths.music("aviOST/pause/shipTheFartYayHoorayv3v"));
			default:
				inst = new FlxSound().loadEmbedded(Paths.inst(SONG.song, CoolUtil.difficulties[storyDifficulty]));
		}

		if (SONG.needsVoices)
		{
			vocals = new FlxSound().loadEmbedded(Paths.voices(SONG.song));
			bf_vocals = new FlxSound().loadEmbedded(Paths.voicesPlayer(SONG.song, SONG.voiceSfx1, CoolUtil.difficulties[storyDifficulty]));
			opp_vocals = new FlxSound().loadEmbedded(Paths.voicesOpp(SONG.song, SONG.voiceSfx2, CoolUtil.difficulties[storyDifficulty]));
		}
		else
		{
			vocals = new FlxSound();
			bf_vocals = new FlxSound();
			opp_vocals = new FlxSound();
		}

		vocals.pitch = playbackRate;
		bf_vocals.pitch = playbackRate;
		opp_vocals.pitch = playbackRate;
		inst.pitch = playbackRate;
		FlxG.sound.list.add(vocals);
		FlxG.sound.list.add(bf_vocals);
		FlxG.sound.list.add(opp_vocals);
		FlxG.sound.list.add(inst);

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var playerCounter:Int = 0;

		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped

		var songName:String = Paths.formatToSongPath(SONG.song);
		var fuckYou:String = "dont-cross";
		var file:String = Paths.json((SONG.song == "Dont Cross" ? fuckYou : songName) + '/events');
		var eventsData:Array<Dynamic>;

		if (OpenFlAssets.exists(file) || SONG.song == "Dont Cross" || (SONG.song == "Twisted Grins" && ClientPrefs.mechanics)) {
			eventsData = Song.loadFromJson('events', (SONG.song == "Dont Cross" ? fuckYou : songName) ).events;
			for (event in eventsData) //Event Notes
			{
				for (i in 0...event[1].length)
				{
					var newEventNote:Array<Dynamic> = [event[0], event[1][i][0], event[1][i][1], event[1][i][2]];
					var subEvent:EventNote = {
						strumTime: newEventNote[0] + ClientPrefs.noteOffset,
						event: newEventNote[1],
						value1: newEventNote[2],
						value2: newEventNote[3]
					};
					subEvent.strumTime -= eventNoteEarlyTrigger(subEvent);
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

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				unspawnNotes.push(swagNote);

				var floorSus:Int = Math.floor(susLength);
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

				if(!noteTypeMap.exists(swagNote.noteType)) {
					noteTypeMap.set(swagNote.noteType, true);
				}
			}
			daBeats += 1;
		}
		for (event in songData.events) //Event Notes
		{
			for (i in 0...event[1].length)
			{
				var newEventNote:Array<Dynamic> = [event[0], event[1][i][0], event[1][i][1], event[1][i][2]];
				var subEvent:EventNote = {
					strumTime: newEventNote[0] + ClientPrefs.noteOffset,
					event: newEventNote[1],
					value1: newEventNote[2],
					value2: newEventNote[3]
				};
				subEvent.strumTime -= eventNoteEarlyTrigger(subEvent);
				eventNotes.push(subEvent);
				eventPushed(subEvent);
			}
		}

		// trace(unspawnNotes.length);
		// playerCounter += 1;

		unspawnNotes.sort(sortByShit);
		if(eventNotes.length > 1) { //No need to sort if there's a single one or none at all
			eventNotes.sort(sortByTime);
		}
		checkEventNote();
		generatedMusic = true;
	}

	function eventPushed(event:EventNote) {
		switch(event.event) {
			case 'Change Character':
				var charType:Int = 0;
				switch(event.value1.toLowerCase()) {
					case 'gf' | 'girlfriend' | '1':
						charType = 2;
					case 'dad' | 'opponent' | '0':
						charType = 1;
					default:
						charType = Std.parseInt(event.value1);
						if(Math.isNaN(charType)) charType = 0;
				}

				var newCharacter:String = event.value2;
				addCharacterToList(newCharacter, charType);

			case 'Dadbattle Spotlight':
				dadbattleBlack = new BGSprite(null, -800, -400, 0, 0);
				dadbattleBlack.makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
				dadbattleBlack.alpha = 0.25;
				dadbattleBlack.visible = false;
				add(dadbattleBlack);

				dadbattleLight = new BGSprite('spotlight', 400, -400);
				dadbattleLight.alpha = 0.375;
				dadbattleLight.blend = ADD;
				dadbattleLight.visible = false;

				dadbattleSmokes.alpha = 0.7;
				dadbattleSmokes.blend = ADD;
				dadbattleSmokes.visible = false;
				add(dadbattleLight);
				add(dadbattleSmokes);

				var offsetX = 200;
				var smoke:BGSprite = new BGSprite('smoke', -1550 + offsetX, 660 + FlxG.random.float(-20, 20), 1.2, 1.05);
				smoke.setGraphicSize(Std.int(smoke.width * FlxG.random.float(1.1, 1.22)));
				smoke.updateHitbox();
				smoke.velocity.x = FlxG.random.float(15, 22);
				smoke.active = true;
				dadbattleSmokes.add(smoke);
				var smoke:BGSprite = new BGSprite('smoke', 1550 + offsetX, 660 + FlxG.random.float(-20, 20), 1.2, 1.05);
				smoke.setGraphicSize(Std.int(smoke.width * FlxG.random.float(1.1, 1.22)));
				smoke.updateHitbox();
				smoke.velocity.x = FlxG.random.float(-15, -22);
				smoke.active = true;
				smoke.flipX = true;
				dadbattleSmokes.add(smoke);


			case 'Philly Glow':
				blammedLightsBlack = new FlxSprite(FlxG.width * -0.5, FlxG.height * -0.5).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
				blammedLightsBlack.visible = false;
				insert(members.indexOf(phillyStreet), blammedLightsBlack);

				phillyWindowEvent = new BGSprite('philly/window', phillyWindow.x, phillyWindow.y, 0.3, 0.3);
				phillyWindowEvent.setGraphicSize(Std.int(phillyWindowEvent.width * 0.85));
				phillyWindowEvent.updateHitbox();
				phillyWindowEvent.visible = false;
				insert(members.indexOf(blammedLightsBlack) + 1, phillyWindowEvent);


				phillyGlowGradient = new PhillyGlow.PhillyGlowGradient(-400, 225); //This shit was refusing to properly load FlxGradient so fuck it
				phillyGlowGradient.visible = false;
				insert(members.indexOf(blammedLightsBlack) + 1, phillyGlowGradient);
				if(!ClientPrefs.flashing) phillyGlowGradient.intendedAlpha = 0.7;

				precacheList.set('philly/particle', 'image'); //precache particle image
				phillyGlowParticles = new FlxTypedGroup<PhillyGlow.PhillyGlowParticle>();
				phillyGlowParticles.visible = false;
				insert(members.indexOf(phillyGlowGradient) + 1, phillyGlowParticles);
		}

		if(!eventPushedMap.exists(event.event)) {
			eventPushedMap.set(event.event, true);
		}
	}

	function eventNoteEarlyTrigger(event:EventNote):Float {
		var returnedValue:Float = callOnLuas('eventEarlyTrigger', [event.event]);
		if(returnedValue != 0) {
			return returnedValue;
		}

		switch(event.event) {
			case 'Kill Henchmen': //Better timing so that the kill sound matches the beat intended
				return 280; //Plays 280ms before the actual position
		}
		return 0;
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	function sortByTime(Obj1:EventNote, Obj2:EventNote):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	public var skipArrowStartTween:Bool = false; //for lua
	private function generateStaticArrows(player:Int):Void
	{
		for (i in 0...4)
		{
			// FlxG.log.add(i);
			var targetAlpha:Float = 1;
			if (player < 1)
			{
				if(!ClientPrefs.opponentStrums) targetAlpha = 0;
				else if(middlescroll) targetAlpha = 0.35;
			}

			var babyArrow:StrumNote = new StrumNote(middlescroll ? STRUM_X_MIDDLESCROLL : STRUM_X, strumLine.y, i, player);
			babyArrow.downScroll = ClientPrefs.downScroll;
			if (!isStoryMode && !skipArrowStartTween)
			{
				//babyArrow.y -= 10;
				babyArrow.alpha = 0;
				FlxTween.tween(babyArrow, {/*y: babyArrow.y + 10,*/ alpha: targetAlpha}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}
			else
			{
				babyArrow.alpha = targetAlpha;
			}

			if (player == 1)
			{
				playerStrums.add(babyArrow);
			}
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
		if (paused)
		{
			if (death != null && death.visible)
				death.pause();
			if (devilishGaming != null && devilishGaming.visible)
				devilishGaming.pause();
			if (deluSing != null && deluSing.visible)
				deluSing.pause();
			if (minnieJumpscare != null && minnieJumpscare.visible)
				minnieJumpscare.pause();


			if (inst != null)
			{
				inst.pause();
				vocals.pause();
				bf_vocals.pause();
				opp_vocals.pause();
			}

			if (startTimer != null && !startTimer.finished)
				startTimer.active = false;
			if (finishTimer != null && !finishTimer.finished)
				finishTimer.active = false;
			if (songSpeedTween != null)
				songSpeedTween.active = false;

			if(carTimer != null) carTimer.active = false;

			var chars:Array<Character> = [boyfriend, gf, dad];
			for (char in chars) {
				if(char != null && char.colorTween != null) {
					char.colorTween.active = false;
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
		if (paused)
		{
			if (death != null && death.visible)
				death.resume();
			if (devilishGaming != null && devilishGaming.visible)
				devilishGaming.resume();
			if (deluSing != null && deluSing.visible)
				deluSing.resume();
			if (minnieJumpscare != null && minnieJumpscare.visible)
				minnieJumpscare.resume();

			if (inst != null && !startingSong)
			{
				resyncVocals();
			}

			if (startTimer != null && !startTimer.finished)
				startTimer.active = true;
			if (finishTimer != null && !finishTimer.finished)
				finishTimer.active = true;
			if (songSpeedTween != null)
				songSpeedTween.active = true;

			if(carTimer != null) carTimer.active = true;

			var chars:Array<Character> = [boyfriend, gf, dad];
			for (char in chars) {
				if(char != null && char.colorTween != null) {
					char.colorTween.active = true;
				}
			}

			for (tween in modchartTweens) {
				tween.active = true;
			}
			for (timer in modchartTimers) {
				timer.active = true;
			}
			paused = false;
			callOnLuas('onResume', []);

			#if DISCORD_ALLOWED
			if (startTimer != null && startTimer.finished)
			{
				#if DEV_BUILD
				DiscordClient.changePresence("Playing a song", "It's a secret...", "icon", "random");
				#else
				DiscordClient.changePresence(detailsText, scoreTxt.text, (useFakeDeluName ? "regret" : iconRPC), "random", true, songLength - Conductor.songPosition - ClientPrefs.noteOffset);
				#end
			}
			else
			{
				#if DEV_BUILD
				// Game Over doesn't get his own variable because it's only used here
				DiscordClient.changePresence("Playing a song", "It's a secret...", "icon", "random");
				#else
				DiscordClient.changePresence(detailsText, scoreTxt.text, (useFakeDeluName ? "regret" : iconRPC), "random");
				#end
			}
			#end
		}

		Lib.application.window.onClose.removeAll();
		Lib.application.window.onClose.add(function() {
			persistentUpdate = false;
			persistentDraw = true;
			instance.paused = true;

			if(inst != null) {
				inst.pause();
				vocals.pause();
				bf_vocals.pause();
				opp_vocals.pause();
			}

			openSubState(new Prompt('Are you sure you want to quit?\n\nYour data will still save if you do.', 0, function(){
				System.exit(0);
				DiscordClient.shutdown();
			}, function(){
				persistentUpdate = true;
				persistentDraw = true;
			},false, camOther));
			Lib.application.window.onClose.cancel();
		});

		super.closeSubState();
	}

	override public function onFocus():Void
	{
		if (FlxG.autoPause)
		{
			if (death != null && death.visible)
				death.resume();
			if (devilishGaming != null && devilishGaming.visible)
				devilishGaming.resume();
			if (deluSing != null && deluSing.visible)
				deluSing.resume();
			if (minnieJumpscare != null && minnieJumpscare.visible)
				minnieJumpscare.resume();
			if (episodeIntro != null && episodeIntro.visible)
				episodeIntro.resume();
			if (isolatedIntro != null && isolatedIntro.visible)
				isolatedIntro.resume();
			if (lununuIntro != null && lununuIntro.visible)
				lununuIntro.resume();
		}
	
		#if DISCORD_ALLOWED
		if (healthThing > 0 && !paused)
		{
			if (Conductor.songPosition > 0.0)
			{
				#if DEV_BUILD
				DiscordClient.changePresence("Playing a song", scoreTxt.text, "icon", "random");
				#else
				DiscordClient.changePresence(detailsText, scoreTxt.text, (useFakeDeluName ? "regret" : iconRPC), "random", true, songLength - Conductor.songPosition - ClientPrefs.noteOffset);
				#end
			}
			else
			{
				#if DEV_BUILD
				DiscordClient.changePresence("Playing a song", scoreTxt.text, "icon", "random");
				#else
				DiscordClient.changePresence(detailsText, scoreTxt.text, (useFakeDeluName ? "regret" : iconRPC), "random");
				#end
			}
		}
		#end

		super.onFocus();
	}

	override public function onFocusLost():Void
	{
		if (FlxG.autoPause)
			{
				if (death != null && death.visible)
					death.pause();
				if (devilishGaming != null && devilishGaming.visible)
					devilishGaming.pause();
				if (deluSing != null && deluSing.visible)
					deluSing.pause();
				if (minnieJumpscare != null && minnieJumpscare.visible)
					minnieJumpscare.pause();
				if (episodeIntro != null && episodeIntro.visible)
					episodeIntro.pause();
				if (isolatedIntro != null && isolatedIntro.visible)
					isolatedIntro.pause();
				if (lununuIntro != null && lununuIntro.visible)
					lununuIntro.pause();
			}

		#if DISCORD_ALLOWED
		if (healthThing > 0 && !paused)
		{
			#if DEV_BUILD
			DiscordClient.changePresence("Paused", scoreTxt.text, "icon", "random");
			#else
			DiscordClient.changePresence(detailsPausedText, scoreTxt.text, (useFakeDeluName ? "regret" : iconRPC), "random");
			#end
		}
		#end

		super.onFocusLost();
	}

	function resyncVocals():Void
	{
		if(finishTimer != null) return;

		vocals.pause();
		bf_vocals.pause();
		opp_vocals.pause();

		inst.play();
		inst.pitch = playbackRate;
		Conductor.songPosition = inst.time;
		if (Conductor.songPosition <= vocals.length)
		{
			vocals.time = Conductor.songPosition;
			vocals.pitch = playbackRate;
		}
		if (Conductor.songPosition <= bf_vocals.length)
		{
			bf_vocals.time = Conductor.songPosition;
			bf_vocals.pitch = playbackRate;
		}
		if (Conductor.songPosition <= opp_vocals.length)
		{
			opp_vocals.time = Conductor.songPosition;
			opp_vocals.pitch = playbackRate;
		}
		vocals.play();
		bf_vocals.play();
		opp_vocals.play();
	}

	public var paused:Bool = false;
	public var canReset:Bool = true;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;
	var limoSpeed:Float = 0;

	function updateHealthBar():Void
		{
			healthLerp = FlxMath.lerp(healthLerp, healthThing, .2 / (ClientPrefs.framerate / 60));
		}

	var colTimer:Float = 0;

	override public function update(elapsed:Float)
	{
		callOnLuas('onUpdate', [elapsed]);

		updateHealthBar();

		shaderAnim = Conductor.songPosition / 1000;

		if (canaddshaders)
		{
			switch (SONG.song)
			{
				case "Bless":
					othershader.setFloat('iTime', shaderAnim);

				case 'Devilish Deal':
					chromZoomShader.setFloat('aberration', chromEffect);
					chromZoomShader.setFloat('effectTime', chromEffect);
					chromNormalShader.setFloat('rOffset', chromEffect / 70);
					chromNormalShader.setFloat('bOffset', -chromEffect / 70);
					dramaticCamMovement.setFloat('time', shaderAnim);

				case 'Isolated' | 'Lunacy' | 'Delusional':
					chromZoomShader.setFloat('aberration', chromEffect);
					chromZoomShader.setFloat('effectTime', chromEffect);
					chromNormalShader.setFloat('rOffset', chromEffect / 45);
					chromNormalShader.setFloat('bOffset', -chromEffect / 45);
					dramaticCamMovement.setFloat('time', shaderAnim);
					if (SONG.song == "Delusional")
					{
						delusionalShift.setFloat('iTime', shaderAnim);
						delusionalShift.setFloat('uTime', shaderAnim);
						heatWaveEffect.setFloat("iTime", shaderAnim);
					}

				case 'Malfunction':
					chromNormalShader.setFloat('rOffset', chromEffect / 20);
					chromNormalShader.setFloat('bOffset', -chromEffect / 20);
					if (!ClientPrefs.lowQuality)
					{
						chromZoomShader.setFloat('aberration', chromEffect);
						chromZoomShader.setFloat('effectTime', chromEffect);
						malFreakG.setFloat("iTime", shaderAnim);
						malBG.setFloat("iTime", shaderAnim);
						if (ClientPrefs.epilepsy)
						{
							blurShader.setFloat('bluramount', blurEffect);
						}
					}

				case 'Malfunction Legacy':
					chromNormalShader.setFloat('rOffset', chromEffect / 20);
					chromNormalShader.setFloat('bOffset', -chromEffect / 20);
					if (ClientPrefs.epilepsy)
						blurShader.setFloat('bluramount', blurEffect);

				case 'Isolated Beta' | 'Isolated Legacy' | 'Isolated Old' | 'Lunacy Legacy' | 'Delusional Legacy':
					legacyDistort.setFloat('iTime', shaderAnim);
					legacyDistort.setFloatArray('iResolution', [Lib.current.stage.stageWidth, Lib.current.stage.stageHeight]);

					legacyDefaultDistort.setFloat('iTime', shaderAnim);
					legacyDefaultDistort.setFloatArray('iResolution', [Lib.current.stage.stageWidth, Lib.current.stage.stageHeight]);

				case 'Scrapped':
					if (ClientPrefs.epilepsy)
					{
						blurShader.setFloat('bluramount', blurEffect);
						blurShaderHUD.setFloat('bluramount', blurHUD);
					}
					chromZoomShader.setFloat('aberration', chromEffect);
					chromZoomShader.setFloat('effectTime', chromEffect);
					chromNormalShader.setFloat('rOffset', chromEffect / 35);
					chromNormalShader.setFloat('bOffset', -chromEffect / 35);
					staticEffect.setFloat('uTime', shaderAnim);
					staticEffect.setFloat('iTime', shaderAnim);

				case 'Twisted Grins' | 'Twisted Grins Legacy':
					staticEffect.setFloat('uTime', shaderAnim);
					staticEffect.setFloat('iTime', shaderAnim);

				case 'Hunted':
					wobblyBG.setFloat('uTime', shaderAnim);
					redVignette.setFloat('time', shaderAnim);

				case 'Mercy' | 'Mercy Legacy':
					waltStatic.setFloat('time', shaderAnim);
					dramaticCamMovement.setFloat('time', shaderAnim);

				case 'Cycled Sins Legacy':
					redVignette.setFloat('time', shaderAnim);
					dramaticCamMovement.setFloat('time', shaderAnim);
					staticEffect.setFloat('uTime', shaderAnim);
					staticEffect.setFloat('iTime', shaderAnim);
			}
		}

		if (curStage == 'waltRoom') {
			/*if (rtxMode)
			{
				pissOfGlory.alpha = FlxMath.lerp(pissOfGlory.alpha, FlxG.random.float(0.35, .75), .35);
				greaterPiss.alpha = FlxMath.lerp(greaterPiss.alpha, FlxG.random.float(0.35, .75), .35);
			}
			else
			{*/
				pissOfGlory.alpha = FlxMath.lerp(pissOfGlory.alpha, FlxG.random.float(0.01, .37), .2);
				greaterPiss.alpha = FlxMath.lerp(greaterPiss.alpha, FlxG.random.float(0.01, .37), .2);
			//}
		}

		detectSpace(cpuControlled);

		if (curStage == "waltRoom")
		{
			if (ClientPrefs.mechanics)
			{
				spaceBarCounter.text = '${limitThing}';
			
						/*
						 * This set monitors the brightness of the screen based on the percentage of your health
						 * The original code was unoptimized asf, you can go see for yourself through the commit
						 * history, thx @Wither362 for the more simplified code!
						 *
						 * -DEMOLITIONDON96
						 */
			
						var healths:Array<Float> = [for (i in 1...21) i / 10]; // i dont really remember how were this done...
						var alphas:Array<Float> = [
							0.95, 0.90, 0.85, 0.80, 0.75, 0.70, 0.65, 0.60, 0.55, 0.50, 0.45, 0.40, 0.35, 0.30, 0.25, 0.20, 0.15, 0.10, 0.05, 0.0
						];
						var lastOne:Bool = true;
						for (i in 0...healths.length)
						{
							if (lastOne)
							{
								lastOne = tweenWaltScreen(healths[i], alphas[i]);
							}
						}
					}
		}

		if (canSkip)
		{
			if (FlxG.keys.justPressed.ANY)
			{
				if (skipTmr != null)
					skipTmr.cancel();
	
				skipTmr = new FlxTimer().start(2.5, function(tmr) {
					skipLerp = 0.0;
					skipDial.amount = 0;
				});
				skipLerp = 1.0;
			}
	
			if (FlxG.keys.justPressed.SPACE)
			{
				skipDial.amount += 0.1;
			}
	
			if (skipDial.amount >= 1)
			{
				if (episodeIntro != null)
				{
					finishedScene = true;
					episodeIntro.pause();
					episodeIntro.visible = false;
					if (SONG.song == "Devilish Deal" && isStoryMode && GameData.episode1FPLock != "unlocked")
					{
						windowName = "Funkin.avi - " + 
						(isStoryMode ? curEpisode + " - " : "Freeplay - ") + 
						(SONG.song == "Dont Cross" ? "Don't Cross!" : SONG.song) + 
						" (Composed by: " + FreeplayState.getArtistName() + 
						") - Chart by: " + Song.getCharterCredits() + 
						" [" + FreeplayState.getDiffRank() + "]"; // shitty long ass name that credits literally every fucking thing
						lime.app.Application.current.window.title = windowName;

						windowTimer = new FlxTimer().start(5, function(tmr:FlxTimer)
						{
							windowName = "Funkin.avi - " + 
							(isStoryMode ? curEpisode + " - " : "Freeplay - ") + 
							(SONG.song == "Dont Cross" ? "Don't Cross!" : SONG.song) + 
							" [" + FreeplayState.getDiffRank() + "]"; // short version that displays after 5 seconds yayaya
				
							lime.app.Application.current.window.title = windowName;
						});
					}
					devilishGaming = new VideoSprite(false);
					devilishGaming.load(Paths.video("devilishIntro"), [VideoSprite.muted]);
					add(devilishGaming);
					devilishGaming.cameras = [camVideo];
					devilishGaming.play();
					devilishGaming.visible = false;
					camVideo.visible = true;
					camGame.visible = true;
					new FlxTimer().start(0.001, function(tmr:FlxTimer)
					{
						devilishGaming.pause();
						devilishGaming.setVideoTime(0);
					});
					trace("video gone");
					remove(episodeIntro);
					episodeIntro.kill();
					episodeIntro = null;
				}
				if (isolatedIntro != null)
				{
					finishedScene = true;
					isolatedIntro.pause();
					isolatedIntro.visible = false;
					camVideo.visible = false;
					camGame.visible = true;
					camBars.fade(FlxColor.BLACK, 0.001);
					trace("video gone");
					remove(isolatedIntro);
					isolatedIntro.kill();
					isolatedIntro = null;
				}
				if (lununuIntro != null)
				{
					finishedScene = true;
					lununuIntro.pause();
					lununuIntro.visible = false;
					camVideo.visible = false;
					camBars.visible = true;
					camGame.visible = true;
					camBars.fade(FlxColor.BLACK, 0.0001);
					trace("video gone");
					remove(lununuIntro);
					lununuIntro.kill();
					lununuIntro = null;
				}
				skipDial.visible = false;
				skipSceneTxt.visible = false;
				canSkip = false;
				startCountdown();
			}
		}
	
		if (skipSceneTxt != null)
			for (skipper in [skipSceneTxt, skipDial])
				skipper.alpha = FlxMath.lerp(skipLerp, skipper.alpha, CoolUtil.boundTo(1 - (elapsed * 9), 0, 1));
		
		// shitty system for the camera to stay updated
		var wn_r:Float = 70;
		var rotRateWn = curStep / 9.5;
		var wn_toy = -640 + -Math.sin(rotRateWn * 2) * wn_r * 0.45;

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

		super.update(elapsed);

		setOnLuas('curDecStep', curDecStep);
		setOnLuas('curDecBeat', curDecBeat);

		if(botplayTxt.visible) {
			botplaySine += 180 * elapsed;
			botplayTxt.alpha = 1 - Math.sin((Math.PI * botplaySine) / 180);
		}

		if (cpuControlled)
		{
			scoreTxt.visible = false;
		}

		if (controls.PAUSE && startedCountdown && canPause)
		{
			var ret:Dynamic = callOnLuas('onPause', [], false);
			if(ret != FunkinLua.Function_Stop) {
				openPauseMenu();
			}
		}

		if (FlxG.keys.anyJustPressed(debugKeysChart) && !endingSong && !inCutscene)
		{
			openChartEditor();
		}

		// FlxG.watch.addQuick('VOL', vocals.amplitudeLeft);
		// FlxG.watch.addQuick('VOLRight', vocals.amplitudeRight);

		var mult:Float = FlxMath.lerp(1, iconP1.scale.x, CoolUtil.boundTo(1 - (elapsed * 9 * playbackRate), 0, 1));
		iconP1.scale.set(mult, mult);
		iconP1.updateHitbox();

		var fuck:Float = SONG.song == "Cycled Sins" ? 0.85 : 1;
		var mult:Float = FlxMath.lerp(fuck, iconP2.scale.x, CoolUtil.boundTo(1 - (elapsed * 9 * playbackRate), 0, 1));
		iconP2.scale.set(mult, mult);
		iconP2.updateHitbox();

		if (SONG.song == "Devilish Deal")
		{
			var mult:Float = FlxMath.lerp(1, minnieIcon.scale.x, CoolUtil.boundTo(1 - (elapsed * 9 * playbackRate), 0, 1));
			minnieIcon.scale.set(mult, mult);
			minnieIcon.updateHitbox();

			var mult:Float = FlxMath.lerp(1, satanIconPulse.scale.x, CoolUtil.boundTo(1 - (elapsed * 9 * playbackRate), 0, 1));
			satanIconPulse.scale.set(mult, mult);
			satanIconPulse.updateHitbox();
		}

		if (SONG.song == "Isolated")
		{
			var mult:Float = FlxMath.lerp(1, demonBFIcon.scale.x, CoolUtil.boundTo(1 - (elapsed * 9 * playbackRate), 0, 1));
			demonBFIcon.scale.set(mult, mult);
			demonBFIcon.updateHitbox();

			var mult:Float = FlxMath.lerp(1, lunacyIcon.scale.x, CoolUtil.boundTo(1 - (elapsed * 9 * playbackRate), 0, 1));
			lunacyIcon.scale.set(mult, mult);
			lunacyIcon.updateHitbox();

			var mult:Float = FlxMath.lerp(1, isolatedHappy.scale.x, CoolUtil.boundTo(1 - (elapsed * 9 * playbackRate), 0, 1));
			isolatedHappy.scale.set(mult, mult);
			isolatedHappy.updateHitbox();

			var mult:Float = FlxMath.lerp(1, fakeBFLosingFrame.scale.x, CoolUtil.boundTo(1 - (elapsed * 9 * playbackRate), 0, 1));
			fakeBFLosingFrame.scale.set(mult, mult);
			fakeBFLosingFrame.updateHitbox();
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
		}

		if (SONG.song == "Isolated")
		{
			fakeBFLosingFrame.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) + (150 * fakeBFLosingFrame.scale.x - 150) / 2 - iconOffset;
			demonBFIcon.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) + (150 * demonBFIcon.scale.x - 150) / 2  - iconOffset;
			demonBFScary.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) + (150 * demonBFScary.scale.x - 150) / 2 - iconOffset;
			isolatedHappy.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (150 * isolatedHappy.scale.x) / 2 - iconOffset * 2;
			lunacyIcon.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (150 * lunacyIcon.scale.x) / 2 - iconOffset * 2;
			delusionalIcon.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (150 * delusionalIcon.scale.x) / 2 - iconOffset * 2;
		}

		if (SONG.song == "Devilish Deal")
		{
			minnieIcon.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(-healthBar.percent, 0, 100, 100, 0) * 0.01)) - (150 * minnieIcon.scale.x) / 2 - iconOffset * 25;
			satanIcon.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(-healthBar.percent, 0, 100, 100, 0) * 0.01)) + (150 * satanIcon.scale.x - 150) / 2 - iconOffset * 24;
			satanIconPulse.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(-healthBar.percent, 0, 100, 100, 0) * 0.01)) + (150 * satanIconPulse.scale.x - 150) / 2 - iconOffset * 24;
		}

		if (SONG.song == "Cycled Sins")
		{
			relapseIconLol.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (150 * relapseIconLol.scale.x) / 2 - iconOffset * 2;
		}

		if (healthThing > 2)
			healthThing = 2;

		if (!boyfriend.animatedIcon)
			if (iconP1.frames.frames.length >= 3 && healthBar.percent > 80)
			{
				if (SONG.song == "Isolated") demonBFIcon.animation.curAnim.curFrame = 2;
				iconP1.animation.curAnim.curFrame = 2;
			}
			else if (iconP1.frames.frames.length >= 2 && healthBar.percent < 20)
			{
				if (SONG.song == "Isolated") demonBFIcon.animation.curAnim.curFrame = 1;
				iconP1.animation.curAnim.curFrame = 1;
			}
			else
			{
				if (SONG.song == "Isolated") demonBFIcon.animation.curAnim.curFrame = 1;
				iconP1.animation.curAnim.curFrame = 0;
			}
		else
			if (healthBar.percent < 20 && iconP1.animation.name != '${boyfriend.healthIcon}Losing')
				iconP1.animation.play(boyfriend.healthIcon + "Losing");
			else if (healthBar.percent >= 20 && iconP1.animation.name != '${boyfriend.healthIcon}Neutral')
				iconP1.animation.play(boyfriend.healthIcon + "Neutral");

		if (!dad.animatedIcon)
			if (iconP2.frames.frames.length >= 2 && healthBar.percent > 80)
			{
				if (SONG.song == "Isolated")
				{
					lunacyIcon.animation.curAnim.curFrame = 1;
					delusionalIcon.animation.curAnim.curFrame = 1;
				}
				iconP2.animation.curAnim.curFrame = 1;
			}
			else if (iconP2.frames.frames.length >= 3 && healthBar.percent < 20)
			{
				if (SONG.song == "Isolated")
				{
					lunacyIcon.animation.curAnim.curFrame = 2;
					delusionalIcon.animation.curAnim.curFrame = 2;
				}
				iconP2.animation.curAnim.curFrame = 2;
			}
			else
			{
				if (SONG.song == "Isolated")
				{
					lunacyIcon.animation.curAnim.curFrame = 0;
					delusionalIcon.animation.curAnim.curFrame = 0;
				}
				iconP2.animation.curAnim.curFrame = 0;
			}
		else
			if (healthBar.percent > 80 && iconP2.animation.name != '${dad.healthIcon}Losing')
				iconP2.animation.play(dad.healthIcon + "Losing");
			else if (healthBar.percent <= 80 && iconP2.animation.name != '${dad.healthIcon}Neutral')
				iconP2.animation.play(dad.healthIcon + "Neutral");

		if (FlxG.keys.anyJustPressed(debugKeysCharacter) && !endingSong && !inCutscene) {
			persistentUpdate = false;
			paused = true;
			cancelMusicFadeTween();
			
			MusicBeatState.switchState(new CharacterEditorState(dad.curCharacter));
			FlxG.mouse.load(Paths.image('UI/funkinAVI/mouses/Hand').bitmap);
		}
		
		if (FlxG.keys.justPressed.NINE && !endingSong && !inCutscene) {
			persistentUpdate = false;
			paused = true;
			cancelMusicFadeTween();
			MusicBeatState.switchState(new modcharting.ModchartEditorState());
			FlxG.mouse.load(Paths.image('UI/funkinAVI/mouses/Hand').bitmap);
		}

		if (startedCountdown)
		{
			Conductor.songPosition += FlxG.elapsed * 1000 * playbackRate;
		}

		if (startingSong)
		{
			if (startedCountdown && Conductor.songPosition >= 0)
				startSong();
			else if(!startedCountdown)
				Conductor.songPosition = -Conductor.crochet * 5;
		}
		else
		{
			if (!paused)
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				// Interpolation type beat
				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
					// Conductor.songPosition += FlxG.elapsed * 1000;
					// trace('MISSED FRAME');
				}

				if(updateTime) {
					var curTime:Float = Conductor.songPosition - ClientPrefs.noteOffset;
					if(curTime < 0) curTime = 0;
					songPercent = (curTime / songLength);

					var songCalc:Float = (songLength - curTime);
					if(ClientPrefs.timeBarType == 'Time Elapsed') songCalc = curTime;

					var secondsTotal:Int = Math.floor(songCalc / 1000);
					if(secondsTotal < 0) secondsTotal = 0;

					if(ClientPrefs.timeBarType != 'Song Name')
						timeTxt.text = FlxStringUtil.formatTime(secondsTotal, false);

					if (curStage == "menuSongs")
						songTxt.text = SONG.song + " - " + FlxStringUtil.formatTime(secondsTotal, false);
				}
			}

			// Conductor.lastSongPos = FlxG.sound.music.time;
		}

		if (camZooming)
		{
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125 * camZoomingDecay * playbackRate), 0, 1));
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125 * camZoomingDecay * playbackRate), 0, 1));
			camNotes.zoom = FlxMath.lerp(1, camNotes.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125 * camZoomingDecay * playbackRate), 0, 1));
		}

		FlxG.watch.addQuick("secShit", curSection);
		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);

		// RESET = Quick Game Over Screen
		if (!ClientPrefs.noReset && controls.RESET && canReset && !inCutscene && startedCountdown && !endingSong)
		{
			healthThing = 0;
			trace("RESET = True");
		}
		doDeathCheck();

		if (unspawnNotes[0] != null)
		{
			var time:Float = spawnTime;
			if(songSpeed < 1) time /= songSpeed;
			if(unspawnNotes[0].multSpeed < 1) time /= unspawnNotes[0].multSpeed;

			while (unspawnNotes.length > 0 && unspawnNotes[0].strumTime - Conductor.songPosition < time)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.insert(0, dunceNote);
				dunceNote.spawned=true;
				callOnLuas('onSpawnNote', [notes.members.indexOf(dunceNote), dunceNote.noteData, dunceNote.noteType, dunceNote.isSustainNote]);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		if (generatedMusic && !inCutscene)
		{
			if(!cpuControlled) {
				keyShit();
			} else if(boyfriend.animation.curAnim != null && boyfriend.holdTimer > Conductor.stepCrochet * (0.0011 / inst.pitch) * boyfriend.singDuration && boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss')) {
				boyfriend.dance();
				//boyfriend.animation.curAnim.finish();
			}

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
						//daNote.y = (strumY + 0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeed);
						daNote.distance = (0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeed * daNote.multSpeed);
					}
					else //Upscroll
					{
						//daNote.y = (strumY - 0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeed);
						daNote.distance = (-0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeed * daNote.multSpeed);
					}

					var angleDir = strumDirection * Math.PI / 180;
					if (daNote.copyAngle)
						daNote.angle = strumDirection - 90 + strumAngle;

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
								if(isPixelStage) {
									daNote.y += 8 + (6 - daNote.originalHeightForCalcs) * daPixelZoom;
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
		checkEventNote();

		if (Main.debug)
		{
			if(!endingSong && !startingSong) {
				if (FlxG.keys.justPressed.ONE) {
					KillNotes();
					inst.onComplete();
				}
			}
	
			if(FlxG.keys.justPressed.TWO) { //Go 10 seconds into the future :O
				setSongTime(Conductor.songPosition + 10000);
				clearNotesBefore(Conductor.songPosition);
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
				case 'UP' | 'UP-alt' | 'UPmiss':
					camOffset[1] -= 40;

				case 'RIGHT' | 'RIGHT-alt' | 'RIGHTmiss':
					camOffset[0] += 40;
					if (!CoolUtil.spaceToDash(SONG.song.toLowerCase()).endsWith('-legacy')) camOffset[2] += 1.3;

				case 'LEFT' | 'LEFT-alt' | 'LEFTmiss':
					camOffset[0] -= 40;
					if (!CoolUtil.spaceToDash(SONG.song.toLowerCase()).endsWith('-legacy')) camOffset[2] -= 1.3;

				case 'DOWN' | 'DOWN-alt' | 'DOWNmiss':
					camOffset[1] += 40;
			}
		}

		if(!inCutscene) {
			var lerpVal:Float = CoolUtil.boundTo(elapsed * 2.4 * cameraSpeed, 0, 1);
			camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x + camOffset[0], lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y + camOffset[1], lerpVal));
			camGame.angle = FlxMath.lerp(camGame.angle, 0 + camOffset[2], CoolUtil.boundTo(CoolUtil.boundTo(elapsed * 2.4 / 0.4, 0, 1) * cameraSpeed , 0, 1));
		}

		CamUtils.updateCamera(camGame, elapsed);
		CamUtils.updateCamera(camHUD, elapsed);
		CamUtils.updateCamera(camNotes, elapsed);
		CamUtils.updateCamera(camOther, elapsed);

		// yk i sometimes ask why we put sum stuff there n shit
		uhhTurnBackNormalOrSmth = function () {
			for (goofyAhhUIS in [camHUD, camNotes])
				{
					goofyAhhUIS.x += 80;
					goofyAhhUIS.y = FlxMath.lerp(0, goofyAhhUIS.y, CoolUtil.boundTo(elapsed * 2.4, 0, 1));
				}
				FlxTween.tween(PlayState, {healthThing: 2}, 1);
		}

		setOnLuas('cameraX', camFollowPos.x);
		setOnLuas('cameraY', camFollowPos.y);
		setOnLuas('botPlay', cpuControlled);
		callOnLuas('onUpdatePost', [elapsed]);
	}

	var cameraOnDad = false;

	public var uhhTurnBackNormalOrSmth:Void->Void;
	
		/**
		 * # **The Cycled Sins Gimmick**
		 *
		 * As you can see, it's different than how it was before, it can actually be
		 * used now without the need of a fucking event or some shit, so, have fun lol
		 *
		 * @param reactionTime - Amount of time you have to react before he shoots you
		 * @param damageAmount - how much health it'll remove if you fail to dodge
		 *  @param doubleBarrel - if Relapse Mouse shoots twice instead of once
		 *
		 * @author DEMOLITIONDON96
		 */
		public function relapseGimmick(reactionTime:Float = 2, damageAmount:Float = 0.4, ?doubleBarrel:Bool = false)
		{
			dodged = false;
			shootin = true;
			FlxG.sound.play(Paths.sound('funkinAVI/relapseMechs/Reload'), 0.4);
			dodgeWarning.visible = true;
			if (SONG.song == "Cycled Sins Legacy") dad.playAnim("reload", true);
			dad.specialAnim = true;
			FlxTween.color(dodgeWarning, reactionTime - 0.2, FlxColor.WHITE, (doubleBarrel ? FlxColor.YELLOW : FlxColor.RED));

			new FlxTimer().start(reactionTime, function(tmr:FlxTimer)
			{
				FlxG.sound.play(Paths.sound('funkinAVI/relapseMechs/Shoot'), 0.4);
				dad.playAnim("attack", true);
				dad.specialAnim = true;
				if (!doubleBarrel) dodgeWarning.visible = false;
				//checkCamPosition();
				new FlxTimer().start(0.1, function(tmr:FlxTimer)
				{
					if(dodged)
					{
						boyfriend.playAnim('dodge');
						healthThing += 0.05;
					}
					else
					{
						FlxG.camera.shake(0.05, 0.05);
						healthThing -= damageAmount;
					}

					if(doubleBarrel)
					{
						FlxTween.color(dodgeWarning, 0.12, FlxColor.YELLOW, FlxColor.RED);
						new FlxTimer().start(0.275, function(tmr:FlxTimer)
						{
							dodgeWarning.visible = false;
							FlxG.sound.play(Paths.sound('funkinAVI/relapseMechs/Shoot'), 0.4);
							dad.playAnim("attack", true);
							dad.specialAnim = true;
							if(dodged)
							{
								boyfriend.playAnim('dodge');
								healthThing += 0.05;
							}
							else
							{
								FlxG.camera.shake(0.05, 0.05);
								healthThing -= damageAmount / 2;
							}
							dodged = false;
							shootin = false;
							dodgeWarning.color = FlxColor.WHITE;
						});
					}
					else
					{
						dodged = false;
						shootin = false;
						dodgeWarning.color = FlxColor.WHITE;
					}
				});
			});
		}
	
		/**
		 * Manages the `lyrics` of the song in-game
		 * @param icon Lyrics icon as string
		 * @param text The lyrics text
		 * @param font Lyric font
		 * @param size Lyric size
		 * @param duration Delay time to disappear
		 * @param tweenType Tween ease (as string)
		 * @param textDelay Text delay. The amount of seconds to type the next word
		 * 
		 * @author DEMOLITIONDON96 Ft. Jason
		 */
		public function manageLyrics(icon:String = 'bf', text:String = 'swaggers', font:String = 'vcr', size:Int = 15, duration:Float = 5,
				tweenType:String = 'linear', textDelay:Float = 0.03)
		{
			if (!lyricsIcon.visible)
			{
				lyricsIcon.visible = true;
				lyricsIcon.alpha = 0;
			}

			lyricsIcon.changeIcon(icon, false, false, false);

			if (icon == "satanddNEW")
				lyricsIcon.y = lyrics.y - 80;
			else
				lyricsIcon.y = lyrics.y - 65;
	
			lyrics.font = Paths.font(font);
			lyrics.resetText(text);
			lyrics.start(textDelay); // currently placeholder time !!
	
			if (lyricsTween != null)
				lyricsTween.cancel();
	
			if (iconTween != null)
				iconTween.cancel();
	
			iconTween = FlxTween.tween(lyricsIcon, {
				'scale.x': 1,
				'scale.y': 1,
				alpha: 1
			}, 0.5, {
				ease: returnTweenEase(tweenType),
				onComplete: function(twn:FlxTween)
				{
					iconTween = FlxTween.tween(lyricsIcon, {alpha: 0, 'scale.x': 0, 'scale.y': 0}, 0.25, {
						startDelay: duration,
						ease: returnTweenEase(tweenType),
						onComplete: function(twn:FlxTween)
						{
							iconTween = null;
						}
					});
				}
			});
	
			lyricsTween = FlxTween.tween(lyrics, {
				size: size,
				alpha: 1
			}, 0.5, {
				ease: returnTweenEase(tweenType),
				onComplete: function(twn:FlxTween)
				{
					lyricsTween = FlxTween.tween(lyrics, {alpha: 0, size: 0}, 0.25, {
						startDelay: duration,
						ease: returnTweenEase(tweenType),
						onComplete: function(twn:FlxTween)
						{
							lyricsTween = null;
						}
					});
				}
			});
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
		public function camFlashSystem(flashType:FlashType, settings:FlashingSettings)
		{
			// null checkes
			if (settings.colors == null) settings.colors = [255, 255, 255];
			if (settings.timer == null) settings.timer = 3;
			if (settings.ease == null) settings.ease = FlxEase.linear;
			if (settings.alpha == null) settings.alpha = .5;
	
			// due to the fact that some silly 19 year old guy called demo overuses the shit
			// out of the zooms this has to exist in cases of emergency   - jason the silly !!
			// stageBGFlash.setPosition(-FlxG.width * FlxG.camera.zoom, -FlxG.height * FlxG.camera.zoom);
	
			if (ClientPrefs.flashing && stageBGFlash != null)
			{
				switch (flashType)
				{
					case BG_FLASH:
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
	
					case BG_DARK:
						if (stageBGFlash != null)
						{
							if (BGFlashTween != null)
								BGFlashTween.cancel();
	
							if (stageBGFlash.blend != NORMAL)
								stageBGFlash.blend = NORMAL;
	
							if (settings.timer <= 0)
								settings.timer = 1;
	
							stageBGFlash.color = FlxColor.BLACK; // hardcoded to be black
	
							BGFlashTween = FlxTween.tween(stageBGFlash, {alpha: settings.alpha}, settings.timer, {
								ease: settings.ease,
								onComplete: function(twn:FlxTween)
								{
									BGFlashTween = null;
								}
							});
						}
					
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

		   /**
	* The better and simplified Walt gimmick
	*
	* @author Wither362
	*/
	public function tweenWaltScreen(percentage:Float, alpha:Float):Bool {
		if (healthThing <= percentage)
			FlxTween.tween(waltScreenThing, {alpha: alpha}, 0.15, {ease: FlxEase.sineInOut});
		else
			return true;
		return false;
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

		public var topBarTwn:FlxTween;
	public var bottomBarTwn:FlxTween;

	public function cinematicBarControls(controlType:String = "add", speed:Float, ease:String = "circInOut", position:Float = 0, bopValue:Float = 0)
        {
            switch (controlType.toLowerCase())
            {
                case "add" | "create":
					// idk if i should change this cus i dont wanna fuck up and i lazy to test them lol -sylinpix (jason)
                    if (cinematicBars["top"] == null)
                    {
                        cinematicBars["top"] = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
                        cinematicBars["top"].screenCenter(X);
                        cinematicBars["top"].cameras = [camBars];
                        cinematicBars["top"].y = 0 - cinematicBars["top"].height; // offscreen
                        add(cinematicBars["top"]);
                    }
    
                    if (cinematicBars["bottom"] == null)
                    {
                        cinematicBars["bottom"] = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
                        cinematicBars["bottom"].screenCenter(X);
                        cinematicBars["bottom"].cameras = [camBars];
                        cinematicBars["bottom"].y = FlxG.height; // offscreen
                        add(cinematicBars["bottom"]);
                    }
                    
                case "remove" | "kill" | "delete":
                    if (cinematicBars["top"] != null)
					{
                        cinematicBars["top"].kill();
						cinematicBars["top"] = null;
					}
                    if (cinematicBars["bottom"] != null)
					{
                        cinematicBars["bottom"].kill();
						cinematicBars["bottom"] = null;
					}
                    
                case "movetop" | "move top":
					if (topBarTwn != null)
						topBarTwn.cancel();

                    topBarTwn = FlxTween.tween(cinematicBars["top"], {y: position - FlxG.height}, speed, {ease: returnTweenEase(ease), onComplete: function(twn:FlxTween)
					{
						topBarTwn = null;
					}});
                    
                case "movebottom" | "move bottom":
					if (bottomBarTwn != null)
						bottomBarTwn.cancel();

                    bottomBarTwn = FlxTween.tween(cinematicBars["bottom"], {y: FlxG.height - position}, speed, {ease: returnTweenEase(ease), onComplete: function(twn:FlxTween)
					{
						bottomBarTwn = null;
					}});
                    
                case "moveboth" | "move both":
					if (topBarTwn != null)
						topBarTwn.cancel();
					if (bottomBarTwn != null)
						bottomBarTwn.cancel();

                    topBarTwn = FlxTween.tween(cinematicBars["top"], {y: position - FlxG.height}, speed, {ease: returnTweenEase(ease), onComplete: function(twn:FlxTween)
					{
						topBarTwn = null;
					}});
                    bottomBarTwn = FlxTween.tween(cinematicBars["bottom"], {y: FlxG.height - position}, speed, {ease: returnTweenEase(ease), onComplete: function(twn:FlxTween)
					{
						bottomBarTwn = null;
					}});
                    
                case "boptop" | "bop top":
                    cinematicBars["top"].y = position - FlxG.height;
					FlxTween.tween(cinematicBars["top"], {y: (position - FlxG.height) + bopValue}, speed, {ease: returnTweenEase(ease)});
                    
                case "bopbottom" | "bop bottom":
                    cinematicBars["bottom"].y = FlxG.height - position;
					FlxTween.tween(cinematicBars["bottom"], {y: (FlxG.height - position) - bopValue}, speed, {ease: returnTweenEase(ease)});
                    
                case "bopboth" | "bop both":
					if (topBarTwn != null)
						topBarTwn.cancel();
					if (bottomBarTwn != null)
						bottomBarTwn.cancel();

                    cinematicBars["top"].y = position - FlxG.height;
                    cinematicBars["bottom"].y = FlxG.height - position;
					topBarTwn = FlxTween.tween(cinematicBars["top"], {y: (position - FlxG.height) + bopValue}, speed, {ease: returnTweenEase(ease), onComplete: function(twn:FlxTween)
					{
						topBarTwn = null;
					}});
					bottomBarTwn = FlxTween.tween(cinematicBars["bottom"], {y: (FlxG.height - position) - bopValue}, speed, {ease: returnTweenEase(ease), onComplete: function(twn:FlxTween)
					{
						bottomBarTwn = null;
					}});
            }
        }
    
		public var dumbCamTwn:FlxTween;
        /**
        * ## Camera Zoom Tween Fix
        * 
        * Don't know why, but this was NEEDED to fix the zooming from breaking, smh.
        *
        * @param zoom - Sets the zoom value of the camera
        * @param time - How long you want the tween to take
        * @param ease - I suggest reading the HaxeFlixel API on this one, this uses FlxEase's library components if you don't know how to use this
        *
        * @author JustJasonLol
        */
        public function tweenCamera(zoom:Float = 0.9, time:Float = 0.6, ease:Null<String>):Void
        {
			if (dumbCamTwn != null)
				dumbCamTwn.cancel();
			
            dumbCamTwn = FlxTween.tween(camGame, {zoom: zoom}, time, {ease: returnTweenEase(ease), onComplete: function(twn:FlxTween)
			{
				defaultCamZoom = zoom;
				dumbCamTwn = null;
			}});
        }

	/**
	 * # SPACEBAR Gimmick Checker
	 * 
	* Checks on the spacebar if there's a spacebar mechanic required
	* if you have a mechanic you want to add with the spacebar
	* simply tag in your gimmick here with the stage/song you want it
	* to occur at, in other words, go nuts
	*
	* @param isAutoplay - Do I REALLY need to explain this one?
	*
	* @author DEMOLITIONDON96
	*/

	var mercyTmr:FlxTimer;
	var disabledDrain:Bool = false;
	var initialCount:Int = 0;
	public function detectSpace(isAutoplay:Bool = false)
		{
			if (!isAutoplay)
			{
				if (FlxG.keys.justPressed.SPACE)
				{
					/*
					* This set is for song-specific gimmicks
					* Try messing around with it
					*
					* - DEMOLITIONDON96
					*/
	
					switch (SONG.song)
					{
						default:
							// nothing
					}
	
					/*
					* This is if you want the gimmicks to affect
					* ALL songs globally, if they use a certain stage
					* 2 examples are already provided below
					*
					* - DEMOLITIOONDON96
					*/
	
					switch (curStage)
					{
						case 'waltRoom':
							if (limitThing > 0)
							{
								if (mercyTmr != null)
									mercyTmr.cancel();

								disabledDrain = true;
								mercyTmr = new FlxTimer().start(1.2, function(tmr:FlxTimer)
								{
									disabledDrain = false;
									mercyTmr = null;
								});
								healthThing += 1.25;
								limitThing -= 1;
								var mathShit:Float = limitThing / initialCount;
								switch (mathShit)
								{
									case 0.75: mercyBoostIcon.animation.play("hmm");
									case 0.5: mercyBoostIcon.animation.play("halfway");
									case 0.25: mercyBoostIcon.animation.play("thatsBad");
									case 0.1 | 0.12: mercyBoostIcon.animation.play("almostOut");
									case 0: mercyBoostIcon.animation.play("empty");
								}
							}
						
						case 'apartment':
							if (shootin)
								dodged = true;
	
						default:
							// nothing
					}
				}
			} else {
				switch (SONG.song)
				{
					default:
						//nothing
				}
				
				switch (curStage)
				{
					case 'waltRoom':
						if (healthThing < 0.3 && limitThing > 0)
						{
							if (mercyTmr != null)
								mercyTmr.cancel();

							disabledDrain = true;
							mercyTmr = new FlxTimer().start(1.2, function(tmr:FlxTimer)
							{
								disabledDrain = false;
								mercyTmr = null;
							});
							healthThing += 1.25;
							limitThing -= 1;
							var mathShit:Float = limitThing / initialCount;
							switch (mathShit)
							{
								case 0.75: mercyBoostIcon.animation.play("hmm");
								case 0.5: mercyBoostIcon.animation.play("halfway");
								case 0.25: mercyBoostIcon.animation.play("thatsBad");
								case 0.1 | 0.12: mercyBoostIcon.animation.play("almostOut");
								case 0: mercyBoostIcon.animation.play("empty");
							}
						}
						
					case 'apartment':
						if (shootin)
							dodged = true;
					
					default:
						// nothing
				}
			}
		}

	function openPauseMenu()
	{
		persistentUpdate = false;
		persistentDraw = true;
		paused = true;

		// 1 / 1000 chance for Gitaroo Man easter egg
		/*if (FlxG.random.bool(0.1))
		{
			// gitaroo man easter egg
			cancelMusicFadeTween();
			MusicBeatState.switchState(new GitarooPause());
		}
		else {*/
		if(inst != null) {
			inst.pause();
			vocals.pause();
			bf_vocals.pause();
			opp_vocals.pause();
		}
		openSubState((SONG.song.toLowerCase().endsWith('legacy') || SONG.song == "Isolated Beta" || SONG.song == "Isolated Old" ? new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y) : (FreeplayState.freeplayMenuList != 3 ? new FAVIPauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y) : new PauseManiaSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y))));
		//}

		#if DISCORD_ALLOWED
		#if DEV_BUILD
		DiscordClient.changePresence("Paused", scoreTxt.text, "icon", "random");
		#else
		DiscordClient.changePresence(detailsPausedText + " (" + FreeplayState.getDiffRank() + ")", scoreTxt.text, (useFakeDeluName ? "regret" : iconRPC), "random");
		#end
		#end
	}

	function openChartEditor()
	{
		persistentUpdate = false;
		paused = true;
		cancelMusicFadeTween();
		MusicBeatState.switchState(new ChartingState());
		chartingMode = true;
		FlxG.mouse.load(Paths.image('UI/funkinAVI/mouses/Hand').bitmap);

		#if DISCORD_ALLOWED
		#if DEV_BUILD
		DiscordClient.changePresence("Chart Editor", "It's a secret...", "icon", "toolbox", true);
		#else
		DiscordClient.changePresence("Chart Editor", "Editing Chart: " + SONG.song, "icon", "toolbox", true);
		#end
		#end
	}

	public var isDead:Bool = false; //Don't mess with this on Lua!!!
	function doDeathCheck(?skipHealthCheck:Bool = false) {
		if (((skipHealthCheck && instakillOnMiss) || healthThing <= 0) && !practiceMode && !isDead && SONG.song != "Devilish Deal")
		{
			var ret:Dynamic = callOnLuas('onGameOver', [], false);
			if(ret != FunkinLua.Function_Stop) {
				boyfriend.stunned = true;
				deathCounter++;

				// kills any stuff that may cause lag during the process
				for (cams in [camGame, camHUD, camNotes])
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

				Lib.application.window.onClose.removeAll(); // goes back to normal hopefully
				Lib.application.window.onClose.add(function() {
					DiscordClient.shutdown();
				});

				if (FreeplayState.freeplayMenuList != 3)
				{
					vocals.stop();
					bf_vocals.stop();
					opp_vocals.stop();
					inst.stop();

					persistentUpdate = false;
					persistentDraw = false;
					for (tween in modchartTweens) {
						tween.active = true;
					}
					for (timer in modchartTimers) {
						timer.active = true;
					}
					openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x - boyfriend.positionArray[0], boyfriend.getScreenPosition().y - boyfriend.positionArray[1], camFollowPos.x, camFollowPos.y));
				}
				else
				{
					vocals.stop();
					bf_vocals.stop();
					opp_vocals.stop();
					FlxTween.tween(this, {playbackRate: 0.001}, 7, {ease: FlxEase.expoOut});
					FlxTween.tween(inst, {pitch: 0.001}, 7, {ease: FlxEase.expoOut, onComplete: function(twn:FlxTween)
					{
						persistentUpdate = false;
						persistentDraw = false;
						for (tween in modchartTweens) {
							tween.active = true;
						}
						for (timer in modchartTimers) {
							timer.active = true;
						}
					}});
					openSubState(new ManiaLoseSubstate(boyfriend.getScreenPosition().x - boyfriend.positionArray[0], boyfriend.getScreenPosition().y - boyfriend.positionArray[1], camFollowPos.x, camFollowPos.y));
				}

				// MusicBeatState.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

				#if DISCORD_ALLOWED
				#if DEV_BUILD
				// Game Over doesn't get his own variable because it's only used here
				DiscordClient.changePresence("Game Over", "Deaths: " + deathCounter, "icon", "random");
				#else
				// Game Over doesn't get his own variable because it's only used here
				DiscordClient.changePresence("Game Over - " + detailsText, "Deaths: " + deathCounter, (useFakeDeluName ? "regret" : iconRPC), "random");
				#end
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
				break;
			}

			var value1:String = '';
			if(eventNotes[0].value1 != null)
				value1 = eventNotes[0].value1;

			var value2:String = '';
			if(eventNotes[0].value2 != null)
				value2 = eventNotes[0].value2;

			triggerEventNote(eventNotes[0].event, value1, value2);
			eventNotes.shift();
		}
	}

	public function getControl(key:String) {
		var pressed:Bool = Reflect.getProperty(controls, key);
		//trace('Control result: ' + pressed);
		return pressed;
	}

	var hasVocals:Bool = false;

	var staticTwn:FlxTween;
	var staticTmr:Float = 1;

	var skyTwn:FlxTween;

	public function triggerEventNote(eventName:String, value1:String, value2:String) {
		switch(eventName) {
			case 'Hey!':
				var value:Int = 2;
				switch(value1.toLowerCase().trim()) {
					case 'bf' | 'boyfriend' | '0':
						value = 0;
					case 'gf' | 'girlfriend' | '1':
						value = 1;
				}

				var time:Float = Std.parseFloat(value2);
				if(Math.isNaN(time) || time <= 0) time = 0.6;

				if(value != 0) {
					if(dad.curCharacter.startsWith('gf')) { //Tutorial GF is actually Dad! The GF is an imposter!! ding ding ding ding ding ding ding, dindinding, end my suffering
						dad.playAnim('cheer', true);
						dad.specialAnim = true;
						dad.heyTimer = time;
					} else if (gf != null) {
						gf.playAnim('cheer', true);
						gf.specialAnim = true;
						gf.heyTimer = time;
					}

					if(curStage == 'mall') {
						bottomBoppers.animation.play('hey', true);
						heyTimer = time;
					}
				}
				if(value != 1) {
					boyfriend.playAnim('hey', true);
					boyfriend.specialAnim = true;
					boyfriend.heyTimer = time;
				}

			case 'Set GF Speed':
				var value:Int = Std.parseInt(value1);
				if(Math.isNaN(value) || value < 1) value = 1;
				gfSpeed = value;

			case 'Add Camera Zoom':
				if(ClientPrefs.camZooms && FlxG.camera.zoom < 1.35) {
					var camZoom:Float = Std.parseFloat(value1);
					var hudZoom:Float = Std.parseFloat(value2);
					if(Math.isNaN(camZoom)) camZoom = 0.015;
					if(Math.isNaN(hudZoom)) hudZoom = 0.03;

					FlxG.camera.zoom += camZoom;
					camHUD.zoom += hudZoom;
					camNotes.zoom += hudZoom;
				}

			case 'Play Animation':
				//trace('Anim to play: ' + value1);
				var char:Character = dad;
				switch(value2.toLowerCase().trim()) {
					case 'bf' | 'boyfriend':
						char = boyfriend;
					case 'gf' | 'girlfriend':
						char = gf;
					default:
						var val2:Int = Std.parseInt(value2);
						if(Math.isNaN(val2)) val2 = 0;

						switch(val2) {
							case 1: char = boyfriend;
							case 2: char = gf;
						}
				}

				if (char != null)
				{
					char.playAnim(value1, true);
					char.specialAnim = true;
				}

			case 'Camera Follow Pos':
				if(camFollow != null)
				{
					var val1:Float = Std.parseFloat(value1);
					var val2:Float = Std.parseFloat(value2);
					if(Math.isNaN(val1)) val1 = 0;
					if(Math.isNaN(val2)) val2 = 0;

					isCameraOnForcedPos = false;
					if(!Math.isNaN(Std.parseFloat(value1)) || !Math.isNaN(Std.parseFloat(value2))) {
						camFollow.x = val1;
						camFollow.y = val2;
						isCameraOnForcedPos = true;
					}
				}

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

			case 'Screen Shake':
				var valuesArray:Array<String> = [value1, value2];
				var targetsArray:Array<FlxCamera> = [camGame, camHUD];
				for (i in 0...targetsArray.length) {
					var split:Array<String> = valuesArray[i].split(',');
					var duration:Float = 0;
					var intensity:Float = 0;
					if(split[0] != null) duration = Std.parseFloat(split[0].trim());
					if(split[1] != null) intensity = Std.parseFloat(split[1].trim());
					if(Math.isNaN(duration)) duration = 0;
					if(Math.isNaN(intensity)) intensity = 0;

					if(duration > 0 && intensity != 0) {
						targetsArray[i].shake(intensity, duration);
					}
				}


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

							//if (Assets.exists(Paths.getPreloadPath('characters/' + boyfriend.curCharacter + '.json')) && Assets.exists(Paths.voicesPlayer(SONG.song, boyfriend.curCharacter, CoolUtil.difficulties[storyDifficulty])))
								//hasVocals = true;

							var lastAlpha:Float = boyfriend.alpha;
							boyfriend.alpha = 0.00001;
							boyfriend = boyfriendMap.get(value2);
							boyfriend.alpha = lastAlpha;
							iconP1.changeIcon(boyfriend.healthIcon, boyfriend.animatedIcon, boyfriend.intenseIcon, boyfriend.boppingIcon);
							//bf_vocals.destroy();
							//bf_vocals = null;
							//if (SONG.needsVoices)
								//bf_vocals = new FlxSound().loadEmbedded(Paths.voicesPlayer(SONG.song, !hasVocals ? "Player" : boyfriend.curCharacter, CoolUtil.difficulties[storyDifficulty]));
							//else
								//bf_vocals = new FlxSound();
						}
						setOnLuas('boyfriendName', boyfriend.curCharacter);

					case 1:
						if(dad.curCharacter != value2) {
							if(!dadMap.exists(value2)) {
								addCharacterToList(value2, charType);
							}

							//if (Assets.exists(Paths.getPreloadPath('characters/' + dad.curCharacter + '.json')) && Assets.exists(Paths.voicesOpp(SONG.song, dad.curCharacter, CoolUtil.difficulties[storyDifficulty])))
								//hasVocals = true;

							var wasGf:Bool = dad.curCharacter.startsWith('gf');
							var lastAlpha:Float = dad.alpha;
							dad.alpha = 0.00001;
							dad = dadMap.get(value2);
							if(!dad.curCharacter.startsWith('gf')) {
								if(wasGf && gf != null) {
									gf.visible = true;
								}
							} else if(gf != null) {
								gf.visible = false;
							}
							dad.alpha = lastAlpha;
							iconP2.changeIcon(dad.healthIcon, dad.animatedIcon, dad.intenseIcon, dad.boppingIcon);
							//opp_vocals.destroy();
							//opp_vocals = null;
							//if (SONG.needsVoices)
								//opp_vocals = new FlxSound().loadEmbedded(Paths.voicesOpp(SONG.song, !hasVocals ? "Opponent" : dad.curCharacter, CoolUtil.difficulties[storyDifficulty]));
							//else
								//opp_vocals = new FlxSound();
						}
						setOnLuas('dadName', dad.curCharacter);

					case 2:
						if(gf != null)
						{
							if(gf.curCharacter != value2)
							{
								if(!gfMap.exists(value2))
								{
									addCharacterToList(value2, charType);
								}

								var lastAlpha:Float = gf.alpha;
								gf.alpha = 0.00001;
								gf = gfMap.get(value2);
								gf.alpha = lastAlpha;
							}
							setOnLuas('gfName', gf.curCharacter);
						}
				}
				reloadHealthBarColors();
				resyncVocals();
				if (hasVocals) hasVocals = false;
				resetCharPos();

			case 'Change Scroll Speed':
				if (songSpeedType == "constant")
					return;
				var val1:Float = Std.parseFloat(value1);
				var val2:Float = Std.parseFloat(value2);
				if(Math.isNaN(val1)) val1 = 1;
				if(Math.isNaN(val2)) val2 = 0;

				var newValue:Float = SONG.speed * ClientPrefs.getGameplaySetting('scrollspeed', 1) * val1;

				if(val2 <= 0)
				{
					songSpeed = newValue;
				}
				else
				{
					songSpeedTween = FlxTween.tween(this, {songSpeed: newValue}, val2 / playbackRate, {ease: FlxEase.linear, onComplete:
						function (twn:FlxTween)
						{
							songSpeedTween = null;
						}
					});
				}

			case 'Static Event':
				if (ClientPrefs.epilepsy)
				{
					switch(value1.toLowerCase().trim())
					{
						case 'togglevis':
							staticSpr.visible = !staticSpr.visible;
						case 'setalpha':
							staticSpr.alpha = Std.parseFloat(value2);
						case 'twnalpha':
							if (staticTwn != null)
								staticTwn.cancel();
							staticTwn = FlxTween.tween(staticSpr, {alpha: Std.parseFloat(value2)}, staticTmr, {ease: FlxEase.circIn});
						case 'settime':
							staticTmr = Std.parseFloat(value2);
					}
				}
		
			case 'Change Mal BG':
				if (ClientPrefs.epilepsy)
				{
					switch(value1.toLowerCase().trim())
					{
						case 'togglevis':
							fuckedBG.visible = !fuckedBG.visible;
						case 'setalpha':
							fuckedBG.alpha = Std.parseFloat(value2);
						case 'changebg':
							if (!ClientPrefs.lowQuality) fuckedBG.animation.play('bg${Std.parseFloat(value2)}');
					}
				}

			case 'No Signal Event':
				if (ClientPrefs.epilepsy)
				{
					switch(value1.toLowerCase().trim())
					{
						case 'togglevis':
							noSignalBG.visible = !noSignalBG.visible;
							noSignalLogo.visible = !noSignalLogo.visible;
						case 'setalpha':
							noSignalLogo.alpha = Std.parseFloat(value2);
							noSignalBG.alpha = Std.parseFloat(value2);
						case 'changebg':
							if (!ClientPrefs.lowQuality) noSignalBG.animation.play('signal${Std.parseFloat(value2)}');
					}
				}	

			case "Mania BG Flash":
				var triggerVars:Array<String> = value1.split(',');
				if (ClientPrefs.flashing)
				{
					switch (value2.toLowerCase())
					{
						case "sky":
							if (skyTwn != null)
								skyTwn.cancel();

							if (skyFlash != null)
							{
								skyFlash.color = FlxColor.fromRGB(Std.parseInt(triggerVars[3]), Std.parseInt(triggerVars[4]), Std.parseInt(triggerVars[5]));
								skyFlash.alpha = Std.parseFloat(triggerVars[2]);
								skyTwn = FlxTween.tween(skyFlash, {alpha: 0}, Std.parseFloat(triggerVars[0]), {ease: returnTweenEase(triggerVars[1]), onComplete: function(twn:FlxTween)
								{
									skyTwn = null;
								}});
							}
						case "all": 
							camFlashSystem(BG_FLASH, {
								timer: Std.parseFloat(triggerVars[0]), 
								ease: returnTweenEase(triggerVars[1]), 
								alpha: Std.parseFloat(triggerVars[2]), 
								colors: [Std.parseInt(triggerVars[3]), Std.parseInt(triggerVars[4]), Std.parseInt(triggerVars[5])]
							});
					}
				}

			case "Mercy Transition":
				switch (value1.toLowerCase())
				{
					case "start":
						defaultCamZoom = 0.75;
						retardedButPissBehind.visible = false;
						sameAsAdobe.visible = false;
						pissOfGlory.visible = false;
						greaterPiss.visible = false;
						camFlashSystem(CAM_FLASH_FANCY, {alpha: 0.5, ease: FlxEase.sineOut, timer: 0.2, colors: [247, 230, 166]});

					case "finish":
						for (bullshit in [retardedButPissBehind, sameAsAdobe, pissOfGlory, greaterPiss])
							bullshit.visible = true;
						camFlashSystem(CAM_FLASH_FANCY, {alpha: 0.5, ease: FlxEase.sineOut, timer: 0.2, colors: [247, 230, 166]});
						FlxTween.tween(sameAsAdobe, {alpha: 0}, 0.25, {ease: FlxEase.sineOut});
						FlxTween.tween(camHUD, {alpha: 1}, 0.31, {ease: FlxEase.sineInOut});
						FlxTween.tween(camNotes, {alpha: 1}, 0.31, {ease: FlxEase.sineInOut});
				}

			case 'Set Property':
				var killMe:Array<String> = value1.split('.');
				if(killMe.length > 1) {
					FunkinLua.setVarInArray(FunkinLua.getPropertyLoopThingWhatever(killMe, true, true), killMe[killMe.length-1], value2);
				} else {
					FunkinLua.setVarInArray(this, value1, value2);
				}
			case 'Tween Camera Zoom':
				var zoom:Float = Std.parseFloat(value1);
				var time:Float = Std.parseFloat(value2);
				if(Math.isNaN(time) || time <= 0) time = 0;
	
				if ((time) > 0) {
					modchartTweens.set("TweenCamZoom", FlxTween.tween(FlxG.camera, {zoom: (zoom)}, (time), {
						ease: FlxEase.quadInOut,
						onComplete: function(twn:FlxTween)
						{
							defaultCamZoom = (zoom);
						}
					}));	
				} else {
					defaultCamZoom = (zoom);
				}
			case 'Tween Camera Pos':
				var split = value1.split("%%");

				var xxx:Float = 0;
				var yyy:Float = 0;

				if(split[0] != null) xxx = Std.parseFloat(split[0].trim());
				if(split[1] != null) yyy = Std.parseFloat(split[1].trim());
				if(Math.isNaN(xxx)) xxx = 0;
				if(Math.isNaN(yyy)) yyy = 0;

				var time:Float = Std.parseFloat(value2);

				if(Math.isNaN(time) || time <= 0) time = 0;
	
				if ((time) > 0) {
					modchartTweens.set("TweenCamX", FlxTween.tween(camFollow, {x: xxx}, (time), {
						ease: FlxEase.quadInOut,
						onComplete: function(twn:FlxTween)
						{
							camFollow.x = xxx;
						}
					}));	
					modchartTweens.set("TweenCamY", FlxTween.tween(camFollow, {y: yyy}, (time), {
						ease: FlxEase.quadInOut,
						onComplete: function(twn:FlxTween)
						{
							camFollow.y = yyy;
						}
					}));
				} else {
					camFollow.x = (yyy);
				}			
		}
		callOnLuas('onEvent', [eventName, value1, value2]);
	}

	function moveCameraSection():Void {
		if(SONG.notes[curSection] == null) return;

		if (gf != null && SONG.notes[curSection].gfSection)
		{
			camFollow.set(gf.getMidpoint().x, gf.getMidpoint().y);
			camFollow.x += gf.cameraPosition[0] + girlfriendCameraOffset[0];
			camFollow.y += gf.cameraPosition[1] + girlfriendCameraOffset[1];
			tweenCamIn();
			callOnLuas('onMoveCamera', ['gf']);
			return;
		}

		if (!SONG.notes[curSection].mustHitSection)
		{
			cameraOnDad = true;
			moveCamera(true);
			callOnLuas('onMoveCamera', ['dad']);
		}
		else
		{
			cameraOnDad = false;
			moveCamera(false);
			callOnLuas('onMoveCamera', ['boyfriend']);
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
		var finishCallback:Void->Void = endSong; //In case you want to change it in a specific song.

		updateTime = false;
		for (music in [vocals, bf_vocals, opp_vocals, inst])
		{
			music.volume = 0;
			music.pause();
		}
		
		if(ClientPrefs.noteOffset <= 0 || ignoreNoteOffset) {
			finishCallback();
		} else {
			finishTimer = new FlxTimer().start(ClientPrefs.noteOffset / 1000, function(tmr:FlxTimer) {
				finishCallback();
			});
		}
	}


	public var transitioning = false;
	public var hasEndingScene:Bool = false;
	public function endSong():Void
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
				return;
			}
		}
		pauseCountEnabled = false;

		Lib.application.window.onClose.removeAll(); // goes back to normal hopefully
		Lib.application.window.onClose.add(function() {
			DiscordClient.shutdown();
		});

		timeBarBG.visible = false;
		timeBar.visible = false;
		timeTxt.visible = false;
		canPause = false;
		endingSong = true;
		camZooming = false;
		inCutscene = false;
		updateTime = false;

		deathCounter = 0;
		seenCutscene = false;
		finishedScene = false;

		if (GameData.canOverrideCPU)
			GameData.canOverrideCPU = false;

		/*#if ACHIEVEMENTS_ALLOWED
		if(achievementObj != null) {
			return;
		} else {
			var achieve:String = checkForAchievement(['week1_nomiss', 'week2_nomiss', 'week3_nomiss', 'week4_nomiss',
				'week5_nomiss', 'week6_nomiss', 'week7_nomiss', 'ur_bad',
				'ur_good', 'hype', 'two_keys', 'toastie', 'debugger']);

			if(achieve != null) {
				startAchievement(achieve);
				return;
			}
		}
		#end*/

		var ret:Dynamic = callOnLuas('onEndSong', [], false);
		if(ret != FunkinLua.Function_Stop && !transitioning) {
			if (SONG.validScore)
			{
				#if !switch
				var percent:Float = ratingPercent;
				if(Math.isNaN(percent)) percent = 0;
				Highscore.saveScore(SONG.song, songScore, storyDifficulty, percent);
				#end
			}
			playbackRate = 1;

			if (chartingMode)
			{
				openChartEditor();
				return;
			}

			if (isStoryMode)
			{
				campaignScore += songScore;
				campaignMisses += songMisses;

				storyPlaylist.remove(storyPlaylist[0]);

				if (storyPlaylist.length <= 0)
				{
					if (ClientPrefs.mechanics && SONG.song == "Delusional")
					{
						hasEndingScene = true;
						GameData.episode1FPLock = "unlocked";
						GameData.saveShit();
					}
					if (SONG.song == "Birthday")
					{
						GameData.birthdayLocky = 'beaten';
						GameData.saveShit();
					}
					WeekData.loadTheFirstEnabledMod();

					cancelMusicFadeTween();
					if(FlxTransitionableState.skipNextTransIn) {
						CustomFadeTransition.nextCamera = null;
					}

					//if (!hasEndingScene) 
					//{
						FlxG.sound.playMusic(Paths.music('aviOST/rottenPetals'));
						MusicBeatState.switchState(new StoryMenu());
					//}
					/*else
					{
						switch (SONG.song)
						{
							case "Delusional":
								for (i in [camNotes, camHUD, camGame, camBars])
									if (i.visible)
										i.visible = false;

								deluOutro = new VideoSprite(false);
								deluOutro.load(Paths.video("Binary"));
								deluOutro.cameras = [camVideo];
								deluOutro.play();
								add(deluOutro);
								deluOutro.addCallback("onStart", () -> {
									camVideo.alpha = 1;
									deluOutro.visible = true;
									death.visible = false;
								});
								deluOutro.addCallback("onEnd", () -> {
									FlxG.sound.playMusic(Paths.music('aviOST/rottenPetals'));
									MusicBeatState.switchState(new StoryMenu());
								});
						}
					}*/

					// if ()
					if(!ClientPrefs.getGameplaySetting('practice', false) && !ClientPrefs.getGameplaySetting('botplay', false)) {
						StoryMenuState.weekCompleted.set(WeekData.weeksList[storyWeek], true);

						if (SONG.validScore)
						{
							Highscore.saveWeekScore(WeekData.getWeekFileName(), campaignScore, storyDifficulty);
						}

						FlxG.save.data.weekCompleted = StoryMenuState.weekCompleted;
						FlxG.save.flush();
					}
					changedDifficulty = false;
				}
				else
				{
					var difficulty:String = CoolUtil.getDifficultyFilePath();

					trace('LOADING NEXT SONG');
					trace(Paths.formatToSongPath(storyPlaylist[0]) + difficulty);

					var winterHorrorlandNext = (Paths.formatToSongPath(SONG.song) == "eggnog");
					if (winterHorrorlandNext)
					{
						var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
							-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
						blackShit.scrollFactor.set();
						add(blackShit);
						camHUD.visible = false;

						FlxG.sound.play(Paths.sound('Lights_Shut_off'));
					}

					FlxTransitionableState.skipNextTransIn = true;
					FlxTransitionableState.skipNextTransOut = true;

					prevCamFollow = camFollow;
					prevCamFollowPos = camFollowPos;

					var songLowercase:String = Paths.formatToSongPath(storyPlaylist[0]);

					SONG = Song.loadFromJson(storyPlaylist[0] + difficulty, songLowercase);
					inst.stop();

					if(winterHorrorlandNext) {
						new FlxTimer().start(1.5, function(tmr:FlxTimer) {
							cancelMusicFadeTween();
							LoadingState.loadAndSwitchState(new PlayState());
						});
					} else {
						cancelMusicFadeTween();
						LoadingState.loadAndSwitchState(new PlayState());
					}
				}
			}
			else
			{
				trace('WENT BACK TO FREEPLAY??');
				WeekData.loadTheFirstEnabledMod();
				cancelMusicFadeTween();
				if(FlxTransitionableState.skipNextTransIn) {
					CustomFadeTransition.nextCamera = null;
				}
				GameData.completeFPSong();
				MusicBeatState.switchState(new FreeplayState());
				FlxG.sound.playMusic(Paths.music('aviOST/seekingFreedom'));
				FlxG.mouse.load(Paths.image('UI/funkinAVI/mouses/Hand').bitmap);
				changedDifficulty = false;
			}
			transitioning = true;
		}
	}

	#if ACHIEVEMENTS_ALLOWED
	var achievementObj:AchievementObject = null;
	function startAchievement(achieve:String) {
		achievementObj = new AchievementObject(achieve, camOther);
		achievementObj.onFinish = achievementEnd;
		add(achievementObj);
		trace('Giving achievement ' + achieve);
	}
	function achievementEnd():Void
	{
		achievementObj = null;
		if(endingSong && !inCutscene) {
			endSong();
		}
	}
	#end

	public function KillNotes() {
		while(notes.length > 0) {
			var daNote:Note = notes.members[0];
			daNote.active = false;
			daNote.visible = false;

			daNote.kill();
			notes.remove(daNote, true);
			daNote.destroy();
		}
		unspawnNotes = [];
		eventNotes = [];
	}

	public var totalPlayed:Int = 0;
	public var totalNotesHit:Float = 0.0;

	public var showCombo:Bool = false;
	public var showComboNum:Bool = true;
	public var showRating:Bool = true;

	private function cachePopUpScore()
	{
		var pixelShitPart1:String = '';
		var pixelShitPart2:String = '';
		if (isPixelStage)
		{
			pixelShitPart1 = 'pixelUI/';
			pixelShitPart2 = '-pixel';
		}

		Paths.image(pixelShitPart1 + "sick" + pixelShitPart2);
		Paths.image(pixelShitPart1 + "good" + pixelShitPart2);
		Paths.image(pixelShitPart1 + "bad" + pixelShitPart2);
		Paths.image(pixelShitPart1 + "shit" + pixelShitPart2);
		Paths.image(pixelShitPart1 + "combo" + pixelShitPart2);
		
		for (i in 0...10) {
			Paths.image(pixelShitPart1 + 'num' + i + pixelShitPart2);
		}
	}

	private function popUpScore(note:Note = null):Void
	{
		var noteDiff:Float = Math.abs(note.strumTime - Conductor.songPosition + ClientPrefs.ratingOffset);
		//trace(noteDiff, ' ' + Math.abs(note.strumTime - Conductor.songPosition));

		// boyfriend.playAnim('hey');
		vocals.volume = 1;

		var placement:String = Std.string(combo);

		var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
		coolText.screenCenter();
		coolText.x = FlxG.width * 0.35;
		//

		var rating:FlxSprite = new FlxSprite();
		var score:Int = 350;

		//tryna do MS based judgment due to popular demand
		var daRating:Rating = Conductor.judgeNote(note, noteDiff / playbackRate);

		totalNotesHit += daRating.ratingMod;
		note.ratingMod = daRating.ratingMod;
		if(!note.ratingDisabled) daRating.increase();
		note.rating = daRating.name;
		score = daRating.score;

		if(daRating.noteSplash && !note.noteSplashDisabled && curStage != "menuSongs")
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

		rating.loadGraphic(Paths.image(pixelShitPart1 + (((ratingPercent == 1 || cpuControlled) && SONG.song != "Cycled Sins") ? "marvelous" : daRating.image) + (SONG.song == "Malfunction" ? '-mal' : '') + pixelShitPart2));
		rating.cameras = [camHUD];
		rating.scale.set(0.4, 0.4);
		rating.screenCenter();
		rating.x = FlxG.width * 0.8;
		rating.y = 100;
		rating.acceleration.y = 550 * playbackRate * playbackRate;
		rating.velocity.y -= FlxG.random.int(140, 175) * playbackRate;
		rating.velocity.x -= FlxG.random.int(0, 10) * playbackRate;
		rating.visible = (!ClientPrefs.hideHud && showRating);
		if (!ClientPrefs.downScroll)
			rating.y += 495 + (SONG.song == "Malfunction" ? ((daRating.image == "sick" && ratingPercent != 1) ? -50 : -35) : 0);
		if (SONG.song == "War Dilemma" && !ClientPrefs.downScroll)
			rating.y -= 120;

		var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'combo' + pixelShitPart2));
		comboSpr.cameras = [camHUD];
		comboSpr.screenCenter();
		comboSpr.x = coolText.x;
		comboSpr.acceleration.y = FlxG.random.int(200, 300) * playbackRate * playbackRate;
		comboSpr.velocity.y -= FlxG.random.int(140, 160) * playbackRate;
		comboSpr.visible = (!ClientPrefs.hideHud && showCombo);
		comboSpr.x += ClientPrefs.comboOffset[0];
		comboSpr.y -= ClientPrefs.comboOffset[1];
		comboSpr.y += 60;
		comboSpr.velocity.x += FlxG.random.int(1, 10) * playbackRate;

		if (SONG.song == "Bless")
			if (lightI.visible)
				rating.setColorTransform(-1, -1, -1, 1, 255, 255, 255, 0);

		insert(members.indexOf(strumLineNotes), rating);
		
		if (!ClientPrefs.comboStacking)
		{
			if (lastRating != null) lastRating.kill();
			lastRating = rating;
		}

		if (!isPixelStage)
		{
			comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
			comboSpr.antialiasing = ClientPrefs.globalAntialiasing;
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
		{
			insert(members.indexOf(strumLineNotes), comboSpr);
		}
		if (!ClientPrefs.comboStacking)
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
			numScore.cameras = [camHUD];
			numScore.scale.set(0.22, 0.22);
			numScore.screenCenter();
			numScore.x = (32 * daLoop) - 90;
			numScore.x += FlxG.width * 0.92;
			numScore.y = rating.y + (SONG.song == "Malfunction" ? ((daRating.image == "sick" && ratingPercent != 1) ? 80 : 56) : 45);
			
			if (!ClientPrefs.comboStacking)
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
			numScore.visible = !ClientPrefs.hideHud;

			if (SONG.song == "Bless")
				if (lightI.visible)
					numScore.setColorTransform(-1, -1, -1, 1, 255, 255, 255, 0);

			//if (combo >= 10 || combo == 0)
			if(showComboNum)
				insert(members.indexOf(strumLineNotes), numScore);

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
		/*
			trace(combo);
			trace(seperatedScore);
		 */

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
		var key:Int = getKeyFromEvent(eventKey);
		//trace('Pressed: ' + eventKey);

		if (!cpuControlled && startedCountdown && !paused && key > -1 && (FlxG.keys.checkStatus(eventKey, JUST_PRESSED) || ClientPrefs.controllerMode))
		{
			if(!boyfriend.stunned && generatedMusic && !endingSong)
			{
				//more accurate hit time for the ratings?
				var lastTime:Float = Conductor.songPosition;
				Conductor.songPosition = inst.time;

				var canMiss:Bool = !ClientPrefs.ghostTapping;

				// heavily based on my own code LOL if it aint broke dont fix it
				var pressNotes:Array<Note> = [];
				//var notesDatas:Array<Int> = [];
				var notesStopped:Bool = false;

				var sortedNotesList:Array<Note> = [];
				notes.forEachAlive(function(daNote:Note)
				{
					if (strumsBlocked[daNote.noteData] != true && daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit && !daNote.isSustainNote && !daNote.blockHit)
					{
						if(daNote.noteData == key)
						{
							sortedNotesList.push(daNote);
							//notesDatas.push(daNote.noteData);
						}
						canMiss = true;
					}
				});
				sortedNotesList.sort(sortHitNotes);

				if (sortedNotesList.length > 0) {
					for (epicNote in sortedNotesList)
					{
						for (doubleNote in pressNotes) {
							var leData:Int = Math.round(Math.abs(doubleNote.noteData));
							if (Math.abs(doubleNote.strumTime - epicNote.strumTime) < 1) {
								doubleNote.kill();
								notes.remove(doubleNote, true);
								doubleNote.destroy();
							} else
								notesStopped = true;
						}

						// eee jack detection before was not super good
						if (!notesStopped) {
							goodNoteHit(epicNote);
							pressNotes.push(epicNote);
						}

					}
				}
				else{
					callOnLuas('onGhostTap', [key]);
					if (canMiss) {
						noteMissPress(key);
					}
				}

				// I dunno what you need this for but here you go
				//									- Shubs

				// Shubs, this is for the "Just the Two of Us" achievement lol
				//									- Shadow Mario
				keysPressed[key] = true;

				//more accurate hit time for the ratings? part 2 (Now that the calculations are done, go back to the time it was before for not causing a note stutter)
				Conductor.songPosition = lastTime;
			}

			var spr:StrumNote = playerStrums.members[key];
			if(strumsBlocked[key] != true && spr != null && spr.animation.curAnim.name != 'confirm')
			{
				spr.playAnim('pressed');
				spr.resetAnim = 0;
			}
			callOnLuas('onKeyPress', [key]);
		}
		//trace('pressed: ' + controlArray);
	}

	function sortHitNotes(a:Note, b:Note):Int
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
		var key:Int = getKeyFromEvent(eventKey);
		if(!cpuControlled && startedCountdown && !paused && key > -1)
		{
			var spr:StrumNote = playerStrums.members[key];
			if(spr != null)
			{
				spr.playAnim('static');
				spr.resetAnim = 0;
			}
			callOnLuas('onKeyRelease', [key]);
		}
		//trace('released: ' + controlArray);
	}

	private function getKeyFromEvent(key:FlxKey):Int
	{
		if(key != NONE)
		{
			for (i in 0...keysArray.length)
			{
				for (j in 0...keysArray[i].length)
				{
					if(key == keysArray[i][j])
					{
						return i;
					}
				}
			}
		}
		return -1;
	}

	// Hold notes
	private function keyShit():Void
	{
		// HOLDING
		var parsedHoldArray:Array<Bool> = parseKeys();

		// TO DO: Find a better way to handle controller inputs, this should work for now
		if(ClientPrefs.controllerMode)
		{
			var parsedArray:Array<Bool> = parseKeys('_P');
			if(parsedArray.contains(true))
			{
				for (i in 0...parsedArray.length)
				{
					if(parsedArray[i] && strumsBlocked[i] != true)
						onKeyPress(new KeyboardEvent(KeyboardEvent.KEY_DOWN, true, true, -1, keysArray[i][0]));
				}
			}
		}

		// FlxG.watch.addQuick('asdfa', upP);
		if (startedCountdown && !boyfriend.stunned && generatedMusic)
		{
			// rewritten inputs???
			notes.forEachAlive(function(daNote:Note)
			{
				// hold note functions
				if (strumsBlocked[daNote.noteData] != true && daNote.isSustainNote && parsedHoldArray[daNote.noteData] && daNote.canBeHit
				&& daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit && !daNote.blockHit) {
					goodNoteHit(daNote);
				}
			});

			if (parsedHoldArray.contains(true) && !endingSong) {
				/*#if ACHIEVEMENTS_ALLOWED
				var achieve:String = checkForAchievement(['oversinging']);
				if (achieve != null) {
					startAchievement(achieve);
				}
				#end*/
			}
			else if (boyfriend.animation.curAnim != null && boyfriend.holdTimer > Conductor.stepCrochet * (0.0011 / inst.pitch) * boyfriend.singDuration && boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss'))
			{
				boyfriend.dance();
				//boyfriend.animation.curAnim.finish();
			}
		}

		// TO DO: Find a better way to handle controller inputs, this should work for now
		if(ClientPrefs.controllerMode || strumsBlocked.contains(true))
		{
			var parsedArray:Array<Bool> = parseKeys('_R');
			if(parsedArray.contains(true))
			{
				for (i in 0...parsedArray.length)
				{
					if(parsedArray[i] || strumsBlocked[i] == true)
						onKeyRelease(new KeyboardEvent(KeyboardEvent.KEY_UP, true, true, -1, keysArray[i][0]));
				}
			}
		}
	}

	private function parseKeys(?suffix:String = ''):Array<Bool>
	{
		var ret:Array<Bool> = [];
		for (i in 0...controlArray.length)
		{
			ret[i] = Reflect.getProperty(controls, controlArray[i] + suffix);
		}
		return ret;
	}

	function noteMiss(daNote:Note):Void { //You didn't hit the key and let it go offscreen, also used by Hurt Notes
		//Dupe note remove
		notes.forEachAlive(function(note:Note) {
			if (daNote != note && daNote.mustPress && daNote.noteData == note.noteData && daNote.isSustainNote == note.isSustainNote && Math.abs(daNote.strumTime - note.strumTime) < 1) {
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
		});
		malfunctionComboCheck = 0;
		combo = 0;
		healthThing -= daNote.missHealth * healthLoss;
		
		if(instakillOnMiss)
		{
			for (music in [vocals, bf_vocals, opp_vocals, inst])
				music.volume = 0;

			doDeathCheck(true);
		}

		//For testing purposes
		//trace(daNote.missHealth);
		songMisses++;
		vocals.volume = 0;
		bf_vocals.volume = 0;
		if(!practiceMode) songScore -= 10;

		totalPlayed++;
		RecalculateRating(true);

		var char:Character = boyfriend;
		if(daNote.gfNote) {
			char = gf;
		}

		if(char != null && !daNote.noMissAnimation && char.hasMissAnimations)
		{
			var animToPlay:String = singAnimations[Std.int(Math.abs(daNote.noteData))] + 'miss' + daNote.animSuffix;
			char.playAnim(animToPlay, true);
		}

		callOnLuas('noteMiss', [notes.members.indexOf(daNote), daNote.noteData, daNote.noteType, daNote.isSustainNote]);
	}

	function noteMissPress(direction:Int = 1):Void //You pressed a key when there was no notes to press for this key
	{
		if(ClientPrefs.ghostTapping) return; //fuck it

		if (!boyfriend.stunned)
		{
			healthThing -= 0.05 * healthLoss;
			if(instakillOnMiss)
			{
				for (music in [vocals, bf_vocals, opp_vocals, inst])
					music.volume = 0;

				doDeathCheck(true);
			}

			if (combo > 5 && gf != null && gf.animOffsets.exists('sad'))
			{
				gf.playAnim('sad');
			}
			combo = 0;

			if(!practiceMode) songScore -= 10;
			if(!endingSong) {
				songMisses++;
			}
			totalPlayed++;
			RecalculateRating(true);

			FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
			// FlxG.sound.play(Paths.sound('missnote1'), 1, false);
			// FlxG.log.add('played imss note');

			/*boyfriend.stunned = true;

			// get stunned for 1/60 of a second, makes you able to
			new FlxTimer().start(1 / 60, function(tmr:FlxTimer)
			{
				boyfriend.stunned = false;
			});*/

			if(boyfriend.hasMissAnimations) {
				boyfriend.playAnim(singAnimations[Std.int(Math.abs(direction))] + 'miss', true);
			}
			vocals.volume = 0;
			bf_vocals.volume = 0;
		}
		callOnLuas('noteMissPress', [direction]);
	}

	var visiblehold:Array<Bool> = [];

	function opponentNoteHit(note:Note):Void
	{
		if (Paths.formatToSongPath(SONG.song) != 'tutorial')
			camZooming = true;

		if(note.noteType == 'Hey!' && dad.animOffsets.exists('hey')) {
			dad.playAnim('hey', true);
			dad.specialAnim = true;
			dad.heyTimer = 0.6;
		} else if(!note.noAnimation) {
			var altAnim:String = note.animSuffix;

			if (SONG.notes[curSection] != null)
			{
				if (SONG.notes[curSection].altAnim && !SONG.notes[curSection].gfSection) {
					altAnim = '-alt';
				}
			}

			if (note.noteType == "Error Note" && SONG.song != "Malfunction Legacy") // Makes Malsquare use his alt animations when he hits error notes cause I don't wanna rechart the entire damn thing just for his alt set to be used
				altAnim = '-alt';

			var char:Character = dad;
			var animToPlay:String = singAnimations[Std.int(Math.abs(note.noteData))] + altAnim;
			if(note.gfNote) {
				char = gf;
			}

			if(char != null)
			{
				char.playAnim(animToPlay, true);
				char.holdTimer = 0;
			}

			// forces the 3rd character in the background in Delusional to work
			if(mickeySpirit != null)
			{
				mickeySpirit.playAnim(animToPlay, true);
				mickeySpirit.holdTimer = 0;
			}
		}

		if (sinsEnd && !note.isSustainNote)
		{
			var text:FlxText = new FlxText(-750, 490, 150, relapseEndNotes[0]);
			text.setFormat(Paths.font("freeplayDisneyFont.ttf"), 70, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			//trace(relapseEndNotes);
			addBehindDad(text);
			FlxTween.tween(text, {x: text.x - FlxG.random.int(-150, 150), y: text.y - 700, alpha: 0, angle: FlxG.random.int(-20, 20)}, 2, {ease: FlxEase.sineOut});
			relapseEndNotes.shift();
		}

		if (SONG.needsVoices)
		{
			vocals.volume = 1;
			opp_vocals.volume = 1;
		}

		switch (SONG.song)
        {  
            case 'Lunacy' | 'Delusional':
                if (ClientPrefs.mechanics)
                     if (healthThing > boundValue)
                        healthThing -= drainValue;
                
            case 'Laugh Track':
                if (ClientPrefs.shaking)
                {
                    if (healthThing > 0.4)
                        healthThing -= 0.01;

					camNotes.angle = camHUD.angle = FlxG.random.float(-1.5, 1.5);
					FlxTween.tween(camNotes, {angle: 0}, .025);
					camGame.shake(0.0035, 0.05);
					camHUD.shake(0.002, 0.035);
					FlxTween.tween(camHUD, {angle: 0}, .025);
                    camNotes.shake(0.002, 0.035);
                }
                
            case 'Malfunction':
                if (dad.curCharacter == 'glitched-mickey-new-pixel')
                {
                    if (healthThing > 0.05)
                        healthThing -= 0.01;
                    if (ClientPrefs.shaking)
                    {
                        camGame.shake(0.008, 0.07);
                        for (i in [camHUD, camNotes])
                            i.shake(0.015, 0.07);
                    }
                    if (canaddshaders)
                    {			
                        if(!ClientPrefs.lowQuality && ClientPrefs.epilepsy)
                        {
                            camGame.setFilters([
                                new ShaderFilter(chromZoomShader),
                                new ShaderFilter(chromNormalShader),
                                new ShaderFilter(blurShader)
                            ]);
                            camHUD.setFilters([
                                new ShaderFilter(chromNormalShader),
                                new ShaderFilter(blurShader)
                            ]);
                            camNotes.setFilters([
                                    new ShaderFilter(chromNormalShader),
                                    new ShaderFilter(blurShader)
                                ]);
                        }
                        
                        chromEffect += 0.2;
                        blurEffect += 2.5;
                        
                        if (chromTween != null)
                            chromTween.cancel();
                        if (blurTween != null)
                            blurTween.cancel();

                        chromTween = FlxTween.tween(
                            instance,
                            {
                                chromEffect: 0.0001
                            },
                            0.1,
                            {
                                ease: FlxEase.sineOut,
                                onComplete: function(twn:FlxTween)
                                {
                                    chromTween = null;
                                }
                            }
                        );
                        blurTween = FlxTween.tween(
                            instance,
                            {
                                blurEffect: 0.0
                            },
                            0.1,
                            {
                                ease: FlxEase.sineOut,
                                onComplete: function(twn:FlxTween)
                                {
                                
                                    if(!ClientPrefs.lowQuality)
                                    {
                                        camGame.setFilters([new ShaderFilter(chromZoomShader), new ShaderFilter(chromNormalShader)]);
                                        camHUD.setFilters([new ShaderFilter(chromNormalShader)]);
                                        camNotes.setFilters([new ShaderFilter(chromNormalShader)]);
                                    }
                                    blurTween = null;
                                }
                            }
                        );
                    }
                }
				else if (dad.curCharacter == 'malsquare-withFace')
                {
					if (healthThing > 0.05)
                        healthThing -= 0.015;
                    if (ClientPrefs.shaking)
                    {
                        camGame.shake(0.01, 0.07);
                        for (i in [camHUD, camNotes])
                            i.shake(0.018, 0.07);
                    }
                    if (canaddshaders)
                    {
                        if(!ClientPrefs.lowQuality && ClientPrefs.epilepsy)
                        {
                            camGame.setFilters([
                                new ShaderFilter(chromZoomShader),
                                new ShaderFilter(chromNormalShader),
                                new ShaderFilter(blurShader)
                            ]);
                            camHUD.setFilters([
                                new ShaderFilter(chromNormalShader),
                                new ShaderFilter(blurShader)
                            ]);
                            camNotes.setFilters([
                                    new ShaderFilter(chromNormalShader),
                                    new ShaderFilter(blurShader)
                                ]);
                        }
                        
                        chromEffect += 0.22;
                        blurEffect += 2.5;
                        
                        if (chromTween != null)
                            chromTween.cancel();
                        if (blurTween != null)
                            blurTween.cancel();

                        chromTween = FlxTween.tween(
                            instance,
                            {
                                chromEffect: 0.0001
                            },
                            0.1,
                            {
                                ease: FlxEase.sineOut,
                                onComplete: function(twn:FlxTween)
                                {
                                    chromTween = null;
                                }
                            }
                        );
                        blurTween = FlxTween.tween(
                            instance,
                            {
                                blurEffect: 0.0
                            },
                            0.1,
                            {
                                ease: FlxEase.sineOut,
                                onComplete: function(twn:FlxTween)
                                {
                                
                                    if(!ClientPrefs.lowQuality)
                                    {
                                        camGame.setFilters([new ShaderFilter(chromZoomShader), new ShaderFilter(chromNormalShader)]);
                                        camHUD.setFilters([new ShaderFilter(chromNormalShader)]);
                                        camNotes.setFilters([new ShaderFilter(chromNormalShader)]);
                                    }
                                    blurTween = null;
                                }
                            }
                        );
                    }
                }
                
            case 'Malfunction Legacy': // the reason this gets a separate case is cause shader effects are gonna be different
                if (healthThing > 0.05)
                       healthThing -= 0.016;
                if (ClientPrefs.shaking)
                {
                    camGame.shake(0.008, 0.07);
                    for (i in [camHUD, camNotes])
                        i.shake(0.015, 0.07);
                }
                if (canaddshaders)
                {
                    if(!ClientPrefs.lowQuality && ClientPrefs.epilepsy)
                    {
                        camGame.setFilters([
                            new ShaderFilter(chromNormalShader),
                            new ShaderFilter(blurShader)
                        ]);
                        camHUD.setFilters([
                            new ShaderFilter(chromNormalShader),
                            new ShaderFilter(blurShader)
                        ]);
                        camNotes.setFilters([
                                new ShaderFilter(chromNormalShader),
                                new ShaderFilter(blurShader)
                            ]);
                    }
                        
                    chromEffect += 0.3;
                    blurEffect += 1.5;
                        
                    if (chromTween != null)
                        chromTween.cancel();
                    if (blurTween != null)
                        blurTween.cancel();

                    chromTween = FlxTween.tween(
                        instance,
                        {
                            chromEffect: 0.0001
                        },
                        0.1,
                        {
                            ease: FlxEase.sineOut,
                            onComplete: function(twn:FlxTween)
                            {
                                chromTween = null;
                            }
                        }
                    );
                    blurTween = FlxTween.tween(
                        instance,
                        {
                            blurEffect: 0.0
                        },
                        0.1,
                        {
                            ease: FlxEase.sineOut,
                            onComplete: function(twn:FlxTween)
                            {
                                
                                if(!ClientPrefs.lowQuality)
                                {
                                    camGame.setFilters([new ShaderFilter(chromNormalShader)]);
                                    camHUD.setFilters([new ShaderFilter(chromNormalShader)]);
                                    camNotes.setFilters([new ShaderFilter(chromNormalShader)]);
                                }
                                blurTween = null;
                            }
                        }
                    );
                }
                
            case "Dont Cross":
                boyfriend.x += 1.2;
                boyfriend.y -= 1.2;
                boyfriend.scale.x -= 0.0012;
                boyfriend.scale.y -= 0.0012;

                if (ClientPrefs.mechanics)
                {
                    if(healthThing > 0.05) // trol
                        healthThing -= 0.015;
                }

				case 'Birthday':
					if (spawnNotes['muckney'] && !note.isSustainNote) birthdayParticles(dadGroup);
        }

		var time:Float = 0.15;
		if(note.isSustainNote && !note.animation.curAnim.name.endsWith('end')) {
			time += 0.15;
		}
		StrumPlayAnim(true, Std.int(Math.abs(note.noteData)), time);
		note.hitByOpponent = true;

		callOnLuas('opponentNoteHit', [notes.members.indexOf(note), Math.abs(note.noteData), note.noteType, note.isSustainNote]);

		if (!note.isSustainNote)
		{
			note.kill();
			notes.remove(note, true);
			note.destroy();
		}

		/*if (note.isSustainNote){
			dad.holdTimer = 0;
		}*/
	}
	
	var malfunctionComboCheck:Int = 0;

	function goodNoteHit(note:Note):Void
	{
		if (!note.wasGoodHit)
		{
			if(cpuControlled && (note.ignoreNote || note.hitCausesMiss)) return;

			if (ClientPrefs.hitsoundVolume > 0 && !note.hitsoundDisabled)
			{
				FlxG.sound.play(Paths.sound('hitsound'), ClientPrefs.hitsoundVolume);
			}

			if (note.noteType == "Error Note")
			{
				healthThing += note.hitHealth * 3.8;
				crashLivesCounter -= 1;

						crashLives.text = 'Lives: ${crashLivesCounter}';
	
						if (malfunctionTxt != null)
							malfunctionTxt.cancel();
				
						if (heartTween != null)
							heartTween.cancel();
				
						malfunctionTxt = FlxTween.tween(crashLives, {alpha: 1}, 0.6, {
							ease: FlxEase.sineOut,
							onComplete: function(twn:FlxTween)
							{
								malfunctionTxt = FlxTween.tween(crashLives, {alpha: 0.3}, 2, {
									ease: FlxEase.quartInOut,
									startDelay: 5,
									onComplete: function(twn:FlxTween)
									{
										malfunctionTxt = null;
									}
								});
							}
						});
				
						heartTween = FlxTween.tween(crashLivesIcon, {alpha: 1}, 0.6, {
							ease: FlxEase.sineOut,
							onComplete: function(twn:FlxTween)
							{
								heartTween = FlxTween.tween(crashLivesIcon, {alpha: 0.3}, 2, {
									ease: FlxEase.quartInOut,
									startDelay: 5,
									onComplete: function(twn:FlxTween)
									{
										heartTween = null;
									}
								});
							}
						});
				
						// to be honest we can just use shake
						//                                - jason
				
						FlxTween.tween(crashLives, {x: 620}, 0.01);
						FlxTween.tween(crashLivesIcon, {x: 570}, 0.01);
						FlxTween.tween(crashLives, {x: 585}, 0.01, {startDelay: 0.1});
						FlxTween.tween(crashLivesIcon, {x: 535}, 0.01, {startDelay: 0.1});
						FlxTween.tween(crashLives, {x: 610}, 0.01, {startDelay: 0.2});
						FlxTween.tween(crashLivesIcon, {x: 560}, 0.01, {startDelay: 0.2});
						FlxTween.tween(crashLives, {x: 595}, 0.01, {startDelay: 0.3});
						FlxTween.tween(crashLivesIcon, {x: 545}, 0.01, {startDelay: 0.3});
						FlxTween.tween(crashLives, {x: 600}, 0.01, {startDelay: 0.4});
						FlxTween.tween(crashLivesIcon, {x: 550}, 0.01, {startDelay: 0.4});
				
						crashLivesIcon.animation.play("OMFG IT GLITCHES");
				
						new FlxTimer().start(0.25, function(tmr:FlxTimer)
						{
							crashLivesIcon.animation.play('idle');
						});
				
						if (crashLivesCounter == -1)
						{
							finishSong();
							trace('0 lives left, closing game...');
							FlxG.sound.play(Paths.sound('funkinAVI/wiiCrash'), 1);
				
							if (FlxG.random.bool(10))
																																																										
								Application.current.window.alert("You Suck LMAO\n\n\nmaybe actually be good at the game for once instead of killing yourself so many times bro.", 'Note About Your Skill:'); // 10% of probability
							else																																																																					/**corny ass shit no offense**/
								Application.current.window.alert("<Message Log>\n========================                                                                                        \n\nPlayState.hx (7504):\n   if(crashLivesCounter == -1)\n   {trace('0 lives left, closing game...')}\n\n\njust give up, you stand no chance against me, everett.",
									'Error On Funkin.avi.exe!:');
				
							Sys.exit(0);
						}
			}

			if(note.hitCausesMiss) {
				noteMiss(note);
				if(!note.noteSplashDisabled && !note.isSustainNote) {
					spawnNoteSplashOnNote(note);
				}

				switch(note.noteType) {
					case 'Hurt Note': //Hurt note
						if(boyfriend.animation.getByName('hurt') != null) {
							boyfriend.playAnim('hurt', true);
							boyfriend.specialAnim = true;
						}
				}

				note.wasGoodHit = true;
				if (!note.isSustainNote)
				{
					note.kill();
					notes.remove(note, true);
					note.destroy();
				}
				return;
			}

			if (!note.isSustainNote)
			{
				if (SONG.song == "Malfunction") malfunctionComboCheck += 1;
				combo += 1;
				if (malfunctionComboCheck == 100 && SONG.song == "Malfunction")
				{
					malfunctionComboCheck = 0;
					if (ratingPercent == 1)
						crashLivesCounter += 5;
					else if (ratingPercent >= 0.9)
						crashLivesCounter += 3;
					else
						crashLivesCounter += 1;
					crashLives.text = 'Lives: ${crashLivesCounter}';
					crashLivesIcon.y -= 20;
					FlxTween.tween(crashLivesIcon, {y: crashLivesIcon.y + 20}, 0.3, {ease: FlxEase.sineOut});
				}
				if(combo > 9999) combo = 9999;
				popUpScore(note);

				if (spawnNotes['bf']) birthdayParticles(boyfriendGroup);
			}
			healthThing += note.hitHealth * 0.55;

			if(!note.noAnimation) {
				var animToPlay:String = singAnimations[Std.int(Math.abs(note.noteData))];

				if(note.gfNote)
				{
					if(gf != null)
					{
						gf.playAnim(animToPlay + note.animSuffix, true);
						gf.holdTimer = 0;
					}
				}
				else
				{
					boyfriend.playAnim(animToPlay + note.animSuffix, true);
					boyfriend.holdTimer = 0;
				}

				if(note.noteType == 'Hey!') {
					if(boyfriend.animOffsets.exists('hey')) {
						boyfriend.playAnim('hey', true);
						boyfriend.specialAnim = true;
						boyfriend.heyTimer = 0.6;
					}

					if(gf != null && gf.animOffsets.exists('cheer')) {
						gf.playAnim('cheer', true);
						gf.specialAnim = true;
						gf.heyTimer = 0.6;
					}
				}
			}

			if(cpuControlled) {
				var time:Float = 0.15;
				if(note.isSustainNote && !note.animation.curAnim.name.endsWith('end')) {
					time += 0.15;
				}
				StrumPlayAnim(false, Std.int(Math.abs(note.noteData)), time);
			} else {
				var spr = playerStrums.members[note.noteData];
				if(spr != null)
				{
					spr.playAnim('confirm', true);
				}
			}
			note.wasGoodHit = true;
			vocals.volume = 1;
			bf_vocals.volume = 1;

			if (SONG.song == "Dont Cross")
			{
				boyfriend.x -= 1.4;
				boyfriend.y += 1.4;
				boyfriend.scale.x += 0.0014;
				boyfriend.scale.y += 0.0014;
			}

			var isSus:Bool = note.isSustainNote; //GET OUT OF MY HEAD, GET OUT OF MY HEAD, GET OUT OF MY HEAD
			var leData:Int = Math.round(Math.abs(note.noteData));
			var leType:String = note.noteType;
			callOnLuas('goodNoteHit', [notes.members.indexOf(note), leData, leType, isSus]);

			if (!note.isSustainNote)
			{
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}

			/*if (note.isSustainNote){
				boyfriend.holdTimer = 0;
			}*/
		}
	}

	public function spawnNoteSplashOnNote(note:Note) {
		if(ClientPrefs.noteSplashes && note != null) {
			var strum:StrumNote = playerStrums.members[note.noteData];
			if(strum != null) {
				spawnNoteSplash(strum.x, strum.y, note.noteData, note);
			}
		}
	}

	public function spawnNoteSplash(x:Float, y:Float, data:Int, ?note:Note = null) {
		var skin:String = 'noteSplashes';
		switch (SONG.song)
		{
			case "Devilish Deal" | "Isolated" | "Lunacy" | "Delusional" | "Hunted" | "Laugh Track" | "Twisted Grins" | "Rotten Petals" | "Seeking Freedom" | "Am I Real?" | "Your Final Bow" | "The Wretched Tilezones (Simple Life)" | "Ship the Fart Yay Hooray <3 (Distant Stars)" | "Ahh the Scary (Somber Night)" | "Curtain Call": SONG.splashSkin = "NOTE_splashesCartoon";
			case "Mercy": SONG.splashSkin = "NOTE_splashWalt";
			case "Birthday": SONG.splashSkin = "Birthday_splash";
			default: SONG.splashSkin = "noteSplashes";
		}

		skin = SONG.splashSkin;

		var hue:Float = 0;
		var sat:Float = 0;
		var brt:Float = 0;
		if (data > -1 && data < ClientPrefs.arrowHSV.length)
		{
			hue = ClientPrefs.arrowHSV[data][0] / 360;
			sat = ClientPrefs.arrowHSV[data][1] / 100;
			brt = ClientPrefs.arrowHSV[data][2] / 100;
			if(note != null) {
				skin = note.noteSplashTexture;
				hue = note.noteSplashHue;
				sat = note.noteSplashSat;
				brt = note.noteSplashBrt;
			}
		}
		var offsetX:Int;
		var offsetY:Int;

		switch (skin)
		{
			case "noteSplashes":
				offsetX = 0;
				offsetY = 0;
			default:
				offsetX = 25;
				offsetY = 40;
		}
		var splash:NoteSplash = grpNoteSplashes.recycle(NoteSplash);
		splash.setupNoteSplash(x + offsetX, y + offsetY, data, skin, hue, sat, brt);
		if (lightI != null)
			if (lightI.visible) 
				splash.setColorTransform(-1, -1, -1, 1, 255, 255, 255, 0); 
			else 
				splash.setColorTransform(1, 1, 1, 1, 0, 0, 0, 0);
		if (isPixelStage && ClientPrefs.shaders)
			splash.shader = pixelizeUI;
		grpNoteSplashes.add(splash);
	}

	var fastCarCanDrive:Bool = true;

	function resetFastCar():Void
	{
		fastCar.x = -12600;
		fastCar.y = FlxG.random.int(140, 250);
		fastCar.velocity.x = 0;
		fastCarCanDrive = true;
	}

	var carTimer:FlxTimer;
	function fastCarDrive()
	{
		//trace('Car drive');
		FlxG.sound.play(Paths.soundRandom('carPass', 0, 1), 0.7);

		fastCar.velocity.x = (FlxG.random.int(170, 220) / FlxG.elapsed) * 3;
		fastCarCanDrive = false;
		carTimer = new FlxTimer().start(2, function(tmr:FlxTimer)
		{
			resetFastCar();
			carTimer = null;
		});
	}

	var trainMoving:Bool = false;
	var trainFrameTiming:Float = 0;

	var trainCars:Int = 8;
	var trainFinishing:Bool = false;
	var trainCooldown:Int = 0;

	function trainStart():Void
	{
		trainMoving = true;
		if (!trainSound.playing)
			trainSound.play(true);
	}

	var startedMoving:Bool = false;

	function updateTrainPos():Void
	{
		if (trainSound.time >= 4700)
		{
			startedMoving = true;
			if (gf != null)
			{
				gf.playAnim('hairBlow');
				gf.specialAnim = true;
			}
		}

		if (startedMoving)
		{
			phillyTrain.x -= 400;

			if (phillyTrain.x < -2000 && !trainFinishing)
			{
				phillyTrain.x = -1150;
				trainCars -= 1;

				if (trainCars <= 0)
					trainFinishing = true;
			}

			if (phillyTrain.x < -4000 && trainFinishing)
				trainReset();
		}
	}

	function trainReset():Void
	{
		if(gf != null)
		{
			gf.danced = false; //Sets head to the correct position once the animation ends
			gf.playAnim('hairFall');
			gf.specialAnim = true;
		}
		phillyTrain.x = FlxG.width + 200;
		trainMoving = false;
		// trainSound.stop();
		// trainSound.time = 0;
		trainCars = 8;
		trainFinishing = false;
		startedMoving = false;
	}

	function lightningStrikeShit():Void
	{
		FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
		if(!ClientPrefs.lowQuality) halloweenBG.animation.play('halloweem bg lightning strike');

		lightningStrikeBeat = curBeat;
		lightningOffset = FlxG.random.int(8, 24);

		if(boyfriend.animOffsets.exists('scared')) {
			boyfriend.playAnim('scared', true);
		}

		if(gf != null && gf.animOffsets.exists('scared')) {
			gf.playAnim('scared', true);
		}

		if(ClientPrefs.camZooms) {
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;

			if(!camZooming) { //Just a way for preventing it to be permanently zoomed until Skid & Pump hits a note
				FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 0.5);
				FlxTween.tween(camHUD, {zoom: 1}, 0.5);
			}
		}

		if(ClientPrefs.flashing) {
			halloweenWhite.alpha = 0.4;
			FlxTween.tween(halloweenWhite, {alpha: 0.5}, 0.075);
			FlxTween.tween(halloweenWhite, {alpha: 0}, 0.25, {startDelay: 0.15});
		}
	}

	function killHenchmen():Void
	{
		if(!ClientPrefs.lowQuality && ClientPrefs.violence && curStage == 'limo') {
			if(limoKillingState < 1) {
				limoMetalPole.x = -400;
				limoMetalPole.visible = true;
				limoLight.visible = true;
				limoCorpse.visible = false;
				limoCorpseTwo.visible = false;
				limoKillingState = 1;

				#if ACHIEVEMENTS_ALLOWED
				Achievements.henchmenDeath++;
				FlxG.save.data.henchmenDeath = Achievements.henchmenDeath;
				var achieve:String = checkForAchievement(['roadkill_enthusiast']);
				if (achieve != null) {
					startAchievement(achieve);
				} else {
					FlxG.save.flush();
				}
				FlxG.log.add('Deaths: ' + Achievements.henchmenDeath);
				#end
			}
		}
	}

	function resetLimoKill():Void
	{
		if(curStage == 'limo') {
			limoMetalPole.x = -500;
			limoMetalPole.visible = false;
			limoLight.x = -500;
			limoLight.visible = false;
			limoCorpse.x = -500;
			limoCorpse.visible = false;
			limoCorpseTwo.x = -500;
			limoCorpseTwo.visible = false;
		}
	}

	var tankX:Float = 400;
	var tankSpeed:Float = FlxG.random.float(5, 7);
	var tankAngle:Float = FlxG.random.int(-90, 45);

	function moveTank(?elapsed:Float = 0):Void
	{
		if(!inCutscene)
		{
			tankAngle += elapsed * tankSpeed;
			tankGround.angle = tankAngle - 90 + 15;
			tankGround.x = tankX + 1500 * Math.cos(Math.PI / 180 * (1 * tankAngle + 180));
			tankGround.y = 1300 + 1100 * Math.sin(Math.PI / 180 * (1 * tankAngle + 180));
		}
	}

	override function destroy() {
		for (lua in luaArray) {
			lua.call('onDestroy', []);
			lua.stop();
		}
		luaArray = [];

		#if hscript
		if(FunkinLua.hscript != null) FunkinLua.hscript = null;
		#end

		if(!ClientPrefs.controllerMode)
		{
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
		}
		FlxAnimationController.globalSpeed = 1;
		inst.pitch = 1;
		super.destroy();
	}

	public static function cancelMusicFadeTween() {
		if(FlxG.sound.music.fadeTween != null) {
			FlxG.sound.music.fadeTween.cancel();
		}
		FlxG.sound.music.fadeTween = null;
	}

	var cinematicValue:Float = 0;
	var lastStepHit:Int = -1;
	override function stepHit()
	{
		super.stepHit();

		switch (SONG.song)
		{
			case 'Isolated Old':
				switch (curStep)
				{
					case 1: tweenCamera(0.7, 0.5, "sineInOut");
					case 16 | 144: tweenCamera(1.2, 10, "sineInOut");
					case 96: tweenCamera(0.8, 0.3, "sineInOut");
					case 120: tweenCamera(1.5, 0.5, "sineInOut");
					case 128: tweenCamera(0.8, 0.5, "sineInOut");
					case 192: tweenCamera(0.85, 5, "sineInOut");
					case 256: tweenCamera(1.2, 8, "sineInOut");
					case 304: tweenCamera(0.8, 4, "sineInOut");
					case 336: tweenCamera(1.4, 9, "sineInOut");
					case 384 | 704: tweenCamera(0.8, 2, "sineInOut");
					case 576: tweenCamera(1.5, 12, "sineInOut");
					case 640: tweenCamera(0.85, 2, "sineInOut");
					case 656: tweenCamera(1.2, 9, "sineInOut");
					case 768: tweenCamera(1.5, 20, "sineInOut");
					case 896: tweenCamera(0.8, 5, "sineInOut");
					case 1024: tweenCamera(0.1, 1, "sineInOut");
					case 1040: tweenCamera(1.5, 30, "sineInOut");
					case 1280: tweenCamera(0.85, 1, "sineInOut");
				}
			case 'Isolated Beta':
				// why tf did this version have so much fucking zoom events?????
				switch (curStep)
				{
					case 32 | 48 | 96 | 112 | 160 | 176 | 208 | 224 | 240 | 304 | 336 | 352 | 368 | 387 | 388 | 434 | 436 | 440 | 444 | 451 | 452 | 496 | 500 | 504 | 508 | 528 | 532 | 536 | 540 | 592 | 596 | 600 | 604 | 642 | 643 | 644 | 688 | 692 | 696 | 700 | 706 | 707 | 708 | 752 | 756 | 760 | 764 | 784 | 788 | 792 | 796 | 848 | 852 | 956 | 860 | 1056 | 1072 | 1088 | 1104 | 1120 | 1136 | 1152 | 1184 | 1200 | 1216 | 1232 | 1248 | 1264:
						defaultCamZoom += 0.1;
					case 64 | 192 | 390 | 416 | 424 | 454 | 480 | 488 | 672 | 680 | 736 | 744:
						defaultCamZoom -= 0.2;
					case 120:
						defaultCamZoom = 1.5;
					case 128 | 256 | 320 | 384 | 448 | 512 | 544 | 608 | 646 | 704 | 710 | 768 | 800 | 864 | 1280:
						defaultCamZoom = 0.8;
					case 412 | 420 | 476 | 484 | 668 | 676 | 732 | 740:
						defaultCamZoom += 0.2;
					case 896:
						//fuck you, i am NOT doing the rest of those fuck ass zoom events
						tweenCamera(1.6, 15, "sineInOut");
					case 1024:
						defaultCamZoom = 0.2;
				}
			case "War Dilemma":
				switch (curStep)
				{
					case 1:
						defaultCamZoom += 0.5;
						cinematicBarControls("moveboth", 2, "backOut", 180);
						if (!ClientPrefs.downScroll && ClientPrefs.mechanics) 
						{
							for (ui in [healthBar, healthBarBG, scoreTxt, iconP1, iconP2])
								FlxTween.tween(ui, {y: ui.y - 120, "scale.x": 0.7, "scale.y": 0.7}, 1, {ease: FlxEase.backOut});
							FlxTween.tween(fancyBarOverlay, {y: fancyBarOverlay.y - 103, "scale.x": 0.7, "scale.y": 0.7}, 1, {ease: FlxEase.backOut});
						}
						if (ClientPrefs.downScroll && ClientPrefs.mechanics)
						{
							for (ui in [healthBar, healthBarBG, scoreTxt, iconP1, iconP2])
								FlxTween.tween(ui, {"scale.x": 0.7, "scale.y": 0.7}, 1, {ease: FlxEase.backOut});
							FlxTween.tween(fancyBarOverlay, {y: fancyBarOverlay.y - 15, "scale.x": 0.7, "scale.y": 0.7}, 1, {ease: FlxEase.backOut});
						}
						for (cam in [camHUD, camNotes])
							FlxTween.tween(cam, {alpha: 1}, 1, {ease: FlxEase.sineOut});
				}
			case 'Isolated': 
				switch (curStep)
				{
					case 1150: 
						defaultCamZoom = camGame.zoom = 1.2;
						cinematicBarControls('moveboth', 0.0001, 'linear', 155);
				}

			case 'Laugh Track':
				switch (curStep)
				{
					case 262 | 294 | 326 | 358: 
						FlxG.camera.zoom += 0.015;
						//camFlashSystem(CAM_FLASH_FANCY, {alpha: 0.35, ease: FlxEase.sineOut, timer: 0.6});
				}
			case "Birthday":
				switch (curStep)
				{
					case 1407:
						FlxTween.tween(dadGroup, {'scale.x': 1, 'scale.y': 1}, 0.3, {ease: FlxEase.quartOut});
				}
		}

		if (Math.abs(inst.time - (Conductor.songPosition - Conductor.offset)) > (20 * playbackRate)
			|| (SONG.needsVoices && Math.abs(vocals.time - (Conductor.songPosition - Conductor.offset)) > (20 * playbackRate)))
		{
			resyncVocals();
		}

		if(curStep == lastStepHit) {
			return;
		}

		lastStepHit = curStep;
		setOnLuas('curStep', curStep);
		callOnLuas('onStepHit', []);
	}

	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;

	var lastBeatHit:Int = -1;
	var canBopCam:Bool = false;

	public static var useFakeDeluName:Bool = false;

	override function beatHit()
	{
		super.beatHit();

		if (canBopCam)
		{
			camGame.zoom += SONG.song == "Bless" ? 0.06 : 0.15;
			camHUD.zoom += SONG.song == "Bless" ? 0.02 : 0.1;
			camNotes.zoom += SONG.song == "Bless" ? 0.025: 0.125;
		}

		if (SONG.song == "Isolated")
			switch (curBeat)
				{
					case 160:
						iconP2.alpha = 0;
						isolatedHappy.visible = true;
						FlxTween.tween(isolatedHappy, {alpha: 0}, 1);
						FlxTween.tween(iconP2, {alpha: 1}, 0.6);

					case 168:
						lunacyIcon.visible = true;
						iconP2.alpha = 0;
						FlxTween.tween(lunacyIcon, {alpha: 0}, 1);
						FlxTween.tween(iconP2, {alpha: 1}, 0.6);

					case 172:
						delusionalIcon.visible = true;
						iconP2.alpha = 0;
						FlxTween.tween(delusionalIcon, {alpha: 0}, 1);
						FlxTween.tween(iconP2, {alpha: 1}, 0.6);

					case 176:
						fakeBFLosingFrame.visible = true;
						iconP1.alpha = 0;
						FlxTween.tween(fakeBFLosingFrame, {alpha: 0}, 1);
						FlxTween.tween(iconP1, {alpha: 1}, 0.6);

					case 184:
						demonBFIcon.visible = true;
						iconP1.alpha = 0;
						FlxTween.tween(demonBFIcon, {alpha: 0}, 1);
						FlxTween.tween(iconP1, {alpha: 1}, 0.6);

					case 188:
						demonBFScary.visible = true;
						iconP1.alpha = 0;
						FlxTween.tween(demonBFScary, {alpha: 0}, 1);
						FlxTween.tween(iconP1, {alpha: 1}, 0.6);
				}

		if (SONG.song == "Devilish Deal")
		{
			switch (curBeat)
				{
					case 1:
						minnieIcon.visible = true;
						satanIcon.visible = true;
					case 62: satanIcon.animation.curAnim.curFrame = 2;
					case 63: minnieIcon.animation.curAnim.curFrame = 1;
					case 64:
						satanIconPulse.visible = true;
						satanIconPulse.alpha = 0.001;
					case 96: minnieIcon.animation.curAnim.curFrame = 2;
					case 112: minnieIcon.animation.curAnim.curFrame = 0;
					case 128:
						healthBarBG.visible = false;
						healthBar.visible = false;
						minnieIcon.visible = false;
						satanIcon.visible = false;
						fancyBarOverlay.visible = false;
						scoreTxt.visible = false;
						watermarkTxt.visible = false;
						songTxt.visible = false;
				}
				if (curBeat >= 64 && curBeat <= 79)
				{
					if (iconPulseTween != null)
						iconPulseTween.cancel();
					if (satanTween != null)
						satanTween.cancel();

					satanIconPulse.alpha = 0.25;
					satanIcon.alpha = 0.75;

					iconPulseTween = FlxTween.tween(satanIconPulse, {alpha: 0}, 0.65, {onComplete: function(twn:FlxTween)
						{
							iconPulseTween = null;
						}
					});

					satanTween = FlxTween.tween(satanIcon, {alpha: 1}, 0.65, {onComplete: function(twn:FlxTween)
						{
							satanTween = null;
						}
					});
				}
				if (curBeat >= 80 && curBeat <= 95)
				{
					if (iconPulseTween != null)
						iconPulseTween.cancel();
					if (satanTween != null)
						satanTween.cancel();

					satanIconPulse.alpha = 0.35;
					satanIcon.alpha = 0.65;

					iconPulseTween = FlxTween.tween(satanIconPulse, {alpha: 0}, 0.65, {onComplete: function(twn:FlxTween)
						{
							iconPulseTween = null;
						}
					});

					satanTween = FlxTween.tween(satanIcon, {alpha: 1}, 0.65, {onComplete: function(twn:FlxTween)
						{
							satanTween = null;
						}
					});
				}
				if (curBeat >= 96 && curBeat <= 111)
				{
					if (iconPulseTween != null)
						iconPulseTween.cancel();
					if (satanTween != null)
						satanTween.cancel();

					satanIconPulse.alpha = 0.5;
					satanIcon.alpha = 0.5;

					iconPulseTween = FlxTween.tween(satanIconPulse, {alpha: 0}, 0.65, {onComplete: function(twn:FlxTween)
						{
							iconPulseTween = null;
						}
					});

					satanTween = FlxTween.tween(satanIcon, {alpha: 1}, 0.65, {onComplete: function(twn:FlxTween)
						{
							satanTween = null;
						}
					});
				}
				if (curBeat >= 112 && curBeat <= 130)
				{
					if (iconPulseTween != null)
						iconPulseTween.cancel();
					if (satanTween != null)
						satanTween.cancel();

					satanIconPulse.alpha = 0.75;
					satanIcon.alpha = 0.25;

					iconPulseTween = FlxTween.tween(satanIconPulse, {alpha: 0}, 0.65, {onComplete: function(twn:FlxTween)
						{
							iconPulseTween = null;
						}
					});

					satanTween = FlxTween.tween(satanIcon, {alpha: 1}, 0.65, {onComplete: function(twn:FlxTween)
						{
							satanTween = null;
						}
					});
				}	
		}
		switch (SONG.song)
		{
			case 'Delusional Legacy':
				switch (curBeat)
				{
					case 32 | 64: 
						camGame.flash(FlxColor.WHITE, 3);
					case 48 | 80:
						camBars.fade(FlxColor.BLACK, 3, true);
					case 96:
						camBars.fade(FlxColor.BLACK, 6, true);
						camNotes.visible = false;
						camHUD.visible = false;
						tweenCamera(1.35, 6.2, "circInOut");
					case 116:
						camGame.flash(FlxColor.WHITE, 3);
						camNotes.visible = true;
						camHUD.visible = true;
						defaultCamZoom = 0.9;
					case 128 | 130 | 144 | 146 | 756:
						defaultCamZoom += 0.1;
					case 132 | 148 | 724 | 758 | 760:
						defaultCamZoom -= 0.2;
					case 178 | 692:
						defaultCamZoom += 0.2;
					case 180:
						defaultCamZoom -= 0.2;
						FlxTween.tween(waltScreenThing, {alpha: 0.7}, 18, {ease: FlxEase.sineInOut});
						camGame.flash(FlxColor.WHITE, 3);
					case 240:
						FlxTween.tween(waltScreenThing, {alpha: 0.0001}, 1, {ease: FlxEase.sineOut});
						defaultCamZoom += 0.2;
					case 244:
						defaultCamZoom -= 0.2;
						camGame.flash(FlxColor.WHITE, 3);
					case 308 | 340:
						defaultCamZoom = 1.3;
					case 324 | 328 | 332 | 336:
						defaultCamZoom -= 0.1;
					case 372:
						camGame.flash(FlxColor.WHITE, 3);
						FlxTween.tween(waltScreenThing, {alpha: 1}, 2, {ease: FlxEase.expoOut});
						camHUD.visible = false;
						camNotes.visible = false;
					case 396:
						tweenCamera(0.85, 4, "quartInOut");
						FlxTween.tween(waltScreenThing, {alpha: 0.001}, 4, {ease: FlxEase.quartInOut});
						camHUD.visible = true;
						camNotes.visible = true;
					case 564:
						camBars.fade(FlxColor.BLACK, 2, true);
						camHUD.visible = false;
						camNotes.visible = false;
					case 592:
						FlxTween.tween(waltScreenThing, {alpha: 1}, 8, {ease: FlxEase.expoInOut});
					case 628:
						camGame.flash(FlxColor.WHITE, 3);
						waltScreenThing.alpha = 0.001;
						camNotes.visible = true;
						camHUD.visible = true;
						defaultCamZoom = 0.9;
					case 636:
						tweenCamera(1.2, 10, "quartInOut");
					case 660:
						tweenCamera(0.9, 2, "expoOut");
					case 764:
						camGame.flash(FlxColor.WHITE, 3);
						defaultCamZoom = 0.9;
					case 796:
						tweenCamera(1.3, 15, "expoInOut");
						FlxTween.tween(waltScreenThing, {alpha: 0.75}, 28, {ease: FlxEase.quartInOut});
					case 892:
						tweenCamera(0.8, 2, "expoIn");
						FlxTween.tween(waltScreenThing, {alpha: 0}, 1, {ease: FlxEase.sineOut});
					case 896:
						camGame.flash(FlxColor.WHITE, 3);
						FlxTween.tween(waltScreenThing, {alpha: 1}, 5, {ease: FlxEase.expoOut});
						camHUD.visible = false;
						camNotes.visible = false;
					case 920:
						FlxTween.tween(waltScreenThing, {alpha: 0}, 3);
						camFlashSystem(BG_DARK, {alpha: 1, timer: 0.001});
						camHUD.visible = true;
						camNotes.visible = true;
						isCameraOnForcedPos = true;
						camFollow.x = 200;
						camFollow.y = 300;
						boyfriend.visible = false;
					case 960:
						tweenCamera(0.2, 5, "sineInOut");
						FlxTween.tween(waltScreenThing, {alpha: 1}, 5, {ease: FlxEase.expoOut});
				}
			case 'Isolated Legacy':
				switch (curBeat)
				{
					case 1 | 16 | 352 | 368: tweenCamera(1.3, 5, 'sineInOut');
					case 14 | 30 | 46 | 64 | 80 | 84: defaultCamZoom = 0.9;
					case 32 | 48: tweenCamera(1.2, 3, 'sineInOut');
					case 40 | 42 | 44 | 56 | 58 | 60 | 62 | 82: defaultCamZoom += 0.12;
					case 66 | 86: defaultCamZoom += 0.2;
					case 68 | 88: defaultCamZoom -= 0.15;
					case 72 | 74 | 76 | 78 | 90 | 92 | 94: defaultCamZoom += 0.09;
					case 96 | 224:
						camFlashSystem(BG_DARK, {alpha: 0, timer: 0.001, ease: FlxEase.sineInOut});
						if (ClientPrefs.flashing) camGame.flash(FlxColor.WHITE, 1);
						defaultCamZoom = 0.9;
					case 98 | 106 | 114 | 122 | 130 | 138 | 146 | 154 | 226 | 234 | 242 | 250 | 258 | 266 | 274 | 282 | 290 | 298 | 306 | 314 | 322 | 330 | 338 | 346:
						camFlashSystem(BG_FLASH, {alpha: 0.75, timer: 0.5, ease: FlxEase.circOut});
						FlxG.camera.zoom += 0.2;
						camHUD.zoom += 0.23;
					case 99 | 107 | 115 | 123 | 131 | 139 | 147 | 155 | 227 | 235 | 243 | 251 | 259 | 267 | 275 | 283 | 291 | 299 | 307 | 315 | 323 | 331 | 339 | 347:
						camFlashSystem(BG_FLASH, {alpha: 0.3, timer: 0.5, ease: FlxEase.circOut});
						FlxG.camera.zoom += 0.08;
						camHUD.zoom += 0.11;
					case 101 | 109 | 117 | 125 | 133 | 141 | 149 | 157 | 229 | 237 | 245 | 253 | 261 | 269 | 277 | 285 | 293 | 301 | 309 | 317 | 325 | 333 | 341 | 349:
						camFlashSystem(BG_FLASH, {alpha: 0.4, timer: 0.5, ease: FlxEase.circOut});
						FlxG.camera.zoom += 0.1;
						camHUD.zoom += 0.13;
					case 102 | 110 | 118 | 126 | 134 | 142 | 150 | 230 | 238 | 246 | 254 | 262 | 270 | 278 | 286 | 294 | 302 | 310 | 318 | 326 | 334 | 342 | 350:
						camFlashSystem(BG_FLASH, {alpha: 0.55, timer: 0.5, ease: FlxEase.circOut});
						FlxG.camera.zoom += 0.12;
						camHUD.zoom += 0.15;
					case 104 | 112 | 120 | 128 | 136 | 144 | 152 | 232 | 240 | 248 | 256 | 264 | 272 | 280 | 288 | 296 | 304 | 312 | 320 | 328 | 336 | 344:
						camFlashSystem(BG_FLASH, {alpha: 0.3, timer: 0.5, ease: FlxEase.circOut});
						FlxG.camera.zoom += 0.23;
						camHUD.zoom += 0.26;
					case 158:
						camFlashSystem(BG_DARK, {alpha: 0.85, timer: 1.2, ease: FlxEase.sineInOut});
						FlxG.camera.zoom += 0.23;
						camHUD.zoom += 0.26;
					case 192 | 200 | 208 | 216:
						defaultCamZoom += 0.1;
					case 366 | 382:
						defaultCamZoom -= 0.1;
					case 367 | 383:
						defaultCamZoom -= 0.25;
					case 412:
						tweenCamera(2, 2, "sineIn");
					case 416:
						camGame.visible = false;
						camHUD.visible = false;
				}
			case 'Lunacy Legacy':
				switch (curBeat)
				{
					case 4 | 8 | 12 | 14 | 40 | 56 | 104 | 112 | 120 | 124 | 126: defaultCamZoom += 0.1;
					case 16 | 48: 
						defaultCamZoom = 0.9;
						camHUD.zoom += 0.02;
						camNotes.zoom += .02;
					case 20 | 44 | 60 | 132 | 142 | 164 | 174: defaultCamZoom += 0.2;
					case 24:
						tweenCamera(0.7, 2, "quartInOut");
						FlxTween.tween(camGame, {alpha: 0}, 1.5, {ease: FlxEase.quartInOut});
						FlxTween.tween(camHUD, {alpha: 0.15}, 2, {ease: FlxEase.quartInOut});
					case 32:
						camGame.alpha = 1;
						if (ClientPrefs.flashing) camGame.flash(FlxColor.WHITE, 1.5);
						camHUD.alpha = 1;
						camHUD.zoom += 0.02;
						camNotes.zoom += .02;
						defaultCamZoom = 0.9;
					case 68 | 76 | 176: defaultCamZoom -= 0.1;
					case 72 | 134 | 144: defaultCamZoom -= 0.15;
					case 80: defaultCamZoom = 1.1;
					case 88 | 166 | 224: defaultCamZoom = 0.8;
					case 128 | 256:
						defaultCamZoom = 0.78;
						if (ClientPrefs.flashing) camGame.flash(FlxColor.WHITE, 1.5);
						camHUD.alpha = 0.0001;
						camNotes.alpha = 0;
					case 156 | 284:
						tweenCamera(1, 1, "sineInOut");
						FlxTween.tween(camHUD, {alpha: 1}, 1.5, {ease: FlxEase.quartInOut});
						FlxTween.tween(camNotes, {alpha: 1}, 1.5, {ease: FlxEase.quartInOut});
					case 160: if (ClientPrefs.flashing) camGame.fade(FlxColor.BLACK, 1.5, true);
					case 192: defaultCamZoom += 0.25;
					case 320:
						if (ClientPrefs.flashing) camGame.fade(FlxColor.BLACK, 1, true);
						camFlashSystem(BG_DARK, {alpha: 0.85, timer: 1, ease: FlxEase.quartInOut});
						defaultCamZoom += 0.2;
					case 336: defaultCamZoom -= 0.35;
					case 368: tweenCamera(1.3, 8, "quartInOut");
					case 400:
						if (ClientPrefs.flashing) camGame.fade(FlxColor.BLACK, 1.5, true);
						camFlashSystem(BG_DARK, {alpha: 0, timer: 1, ease: FlxEase.sineOut});
					case 404:
						FlxTween.tween(camGame, {alpha: 0}, 1.5, {ease: FlxEase.quartInOut});
						FlxTween.tween(camHUD, {alpha: 0}, 1.5, {ease: FlxEase.quartInOut});
						FlxTween.tween(camNotes, {alpha: 0}, 1.5, {ease: FlxEase.quartInOut});
				}
			case "Twisted Grins Legacy":
				switch (curBeat)
				{
					case 62:
						FlxTween.tween(camGame, {alpha: 0}, 3, {ease: FlxEase.quartInOut});
						FlxTween.tween(camHUD, {alpha: 0}, 3, {ease: FlxEase.quartInOut});
						FlxTween.tween(camNotes, {alpha: 0}, 3, {ease: FlxEase.quartInOut});
					case 72:
						camGame.alpha = 1;
						if (ClientPrefs.flashing) camGame.flash(FlxColor.WHITE, 1.5);
						camHUD.alpha = 1;
						camNotes.alpha = 1;
					case 120 | 122 | 125 | 324 | 320 | 332 | 356 | 360 | 364: defaultCamZoom += 0.15;
					case 128: tweenCamera(0.9, 1, "sineInOut");
					case 156 | 400: defaultCamZoom += 0.35;
					case 159 | 308 | 340 | 376: defaultCamZoom = 0.9;
					case 160 | 228 | 404 | 472:
						defaultCamZoom = 0.9;
						camFlashSystem(BG_DARK, {alpha: 0, timer: 0.5, ease: FlxEase.quartOut});
						if (ClientPrefs.shaking)
						{
							camGame.shake(0.01, 24);
							camHUD.shake(0.004, 24);
							camNotes.shake(0.004, 24);
						}
					case 224 | 468:
						camFlashSystem(BG_DARK, {alpha: 0.8, timer: 0.5, ease: FlxEase.quartOut});
						defaultCamZoom += 0.35;
					case 292: defaultCamZoom = 1.3;
					case 336: defaultCamZoom -= 0.1;
					case 536:
						if (ClientPrefs.flashing) camGame.flash(FlxColor.WHITE, 1.5);
						camHUD.visible = false;
						camNotes.visible = false;
					case 575: camGame.visible = false;
				}
			case 'Cycled Sins Legacy':
				switch (curBeat)
				{
					case 128:
						FlxTween.tween(camHUD, {alpha: 0}, 1, {ease: FlxEase.sineInOut});
						FlxTween.tween(camNotes, {alpha: 0}, 1, {ease: FlxEase.sineInOut});
						FlxTween.tween(camGame, {alpha: 0}, 1.5, {ease: FlxEase.sineInOut});
						//FlxTween.tween(dadStrums, {alpha: 0}, 1, {ease: FlxEase.sineInOut});
					case 138: FlxTween.tween(camGame, {alpha: 1}, 1, {ease: FlxEase.sineInOut});
					case 142: camGame.visible = false;
					case 144:
						if (ClientPrefs.shaders)
						{
							camGame.setFilters(
							[
								new ShaderFilter(staticEffect),
								new ShaderFilter(redVignette),
								new ShaderFilter(chromZoomShader),
								new ShaderFilter(dramaticCamMovement),
							]);
						}
						camGame.visible = true;
						camHUD.alpha = 1;
						camNotes.alpha = 1;
						camGame.flash(FlxColor.RED, 1.2);
						FlxTween.tween(this, {healthThing: 0.1}, 1, {ease: FlxEase.sineInOut});
					case 272:
						FlxTween.tween(this, {healthThing: 0.1}, 20, {ease: FlxEase.quartInOut});
						FlxTween.tween(camHUD, {alpha: 0}, 1, {ease: FlxEase.sineInOut});
						FlxTween.tween(camNotes, {alpha: 0}, 1, {ease: FlxEase.sineInOut, startDelay: 0.5});
					case 332:
						FlxTween.tween(camHUD, {alpha: 1}, 1, {ease: FlxEase.sineInOut});
           	 			FlxTween.tween(camNotes, {alpha: 1}, 1, {ease: FlxEase.sineInOut});
					case 544:
						camBars.flash(FlxColor.BLACK, 1.5);
						camHUD.visible = false;
						camNotes.visible = false;
					//gunshots pew pew
					case 158 | 172 | 190 | 204 | 212 | 220 | 222 | 228 | 236 | 244 | 252 | 254 | 260 | 268 | 334 | 398 | 422 | 428 | 430 | 436 | 446 | 452 | 462 | 468 | 472 | 478 | 486 | 492 | 494 | 500 | 510 | 514 | 520 | 524 | 526 | 532 | 540 | 542:
						if (ClientPrefs.mechanics)
						{
							relapseGimmick(0.7, 0.3);
						}
				}
			case 'Devilish Deal':
				switch (curBeat)
				{
					// Intro
					case 1: 
						devilishGaming.resume();
						devilishGaming.visible = true;

					case 8: FlxTween.tween(camGame, {alpha: 1}, 4.5, {ease: FlxEase.sineOut});

					case 16:
						FlxTween.tween(camVideo, {alpha: 0}, 3, {ease: FlxEase.sineOut});
						defaultCamZoom = 1.3;
						manageLyrics('satanddNEW', 'In the rain...', 'betterSatanFont.ttf', 30, 2, 'sineInOut', 0.1);

					case 20:
						manageLyrics('satanddNEW', '...Looking so blue...', 'betterSatanFont.ttf', 30, 3.2, 'sineInOut', 0.08);

					case 26:
						manageLyrics('satanddNEW', '...SPEAK...', 'betterSatanFont.ttf', 30, 0.7, 'sineInOut', 0.05);

					case 28:
						defaultCamZoom = 0.55;
						manageLyrics('satanddNEW', '...What is on your mind?', 'betterSatanFont.ttf', 30, 2.5, 'sineInOut', 0.06);

					case 30:
						FlxTween.tween(camHUD, {alpha: 1}, 2, {ease: FlxEase.sineOut});
						FlxTween.tween(camNotes, {alpha: 1}, 2, {ease: FlxEase.sineOut});

					case 32 | 34 | 36 | 38 | 40 | 42 | 44 | 46 | 48 | 50 | 52 | 54 | 56 | 58:
						if (canaddshaders)
						{
							if (chromTween != null)
								chromTween.cancel();

							chromEffect = 0.32;

							chromTween = FlxTween.tween(instance, {
								chromEffect: 0.0001
							}, 1.2, {
								ease: FlxEase.sineOut,
								onComplete: function(twn:FlxTween)
								{
									chromTween = null;
								}
							});
						}

					case 60:
						defaultCamZoom = 1.2;
						FlxTween.tween(camHUD, {alpha: 0.4}, 0.75, {ease: FlxEase.quartInOut});
						FlxTween.tween(camNotes, {alpha: 0.4}, 0.75, {ease: FlxEase.quartInOut});
						FlxTween.tween(dad.colorTransform, {redMultiplier: 1, blueMultiplier: 1, greenMultiplier: 1}, 2, {ease: FlxEase.circInOut});
						if (canaddshaders)
						{
							if (chromTween != null)
								chromTween.cancel();

							chromEffect = 0.15;

							chromTween = FlxTween.tween(instance, {
								chromEffect: 0.00001
							}, 1.2, {
								ease: FlxEase.sineOut,
								onComplete: function(twn:FlxTween)
								{
									chromTween = null;
								}
							});
						}

					case 62:
						if (canaddshaders)
						{
							if (chromTween != null)
								chromTween.cancel();

							chromEffect = 0.15;

							chromTween = FlxTween.tween(instance, {
								chromEffect: 0.00001
							}, 2, {
								ease: FlxEase.sineOut,
								onComplete: function(twn:FlxTween)
								{
									chromTween = null;
								}
							});
						}

					case 64:
						defaultCamZoom = 0.55;
						FlxTween.tween(camHUD, {alpha: 1}, 1.2, {ease: FlxEase.quartInOut});
						FlxTween.tween(camNotes, {alpha: 1}, 1.2, {ease: FlxEase.quartInOut});

					case 128:
						camGame.visible = false;
						camNotes.visible = false;
						if (ClientPrefs.flashing)
							camOther.flash(FlxColor.WHITE, 1);
						if (canaddshaders)
						{
							if (chromTween != null)
								chromTween.cancel();

							chromEffect = 0.4;

							chromTween = FlxTween.tween(instance, {
								chromEffect: 0.00001
							}, 2.3, {
								ease: FlxEase.sineOut,
								onComplete: function(twn:FlxTween)
								{
									chromTween = null;
								}
							});
						}
				}

				if (curBeat >= 64 && curBeat <= 95 && canaddshaders)
				{
					if (chromTween != null)
						chromTween.cancel();

					chromEffect = 0.23;

					chromTween = FlxTween.tween(instance, {
						chromEffect: 0.00001
					}, 1.5, {
						ease: FlxEase.sineOut,
						onComplete: function(twn:FlxTween)
						{
							chromTween = null;
						}
					});
				}

				if (curBeat >= 96 && curBeat <= 111 && canaddshaders)
				{
					if (chromTween != null)
						chromTween.cancel();

					chromEffect = 0.27;

					chromTween = FlxTween.tween(instance, {
						chromEffect: 0.0001
					}, 1.5, {
						ease: FlxEase.sineOut,
						onComplete: function(twn:FlxTween)
						{
							chromTween = null;
						}
					});
				}

				if (curBeat >= 112 && curBeat <= 127 && canaddshaders)
				{
					if (chromTween != null)
						chromTween.cancel();

					chromEffect = 0.32;

					chromTween = FlxTween.tween(instance, {
						chromEffect: 0.00001
					}, 1.5, {
						ease: FlxEase.sineOut,
						onComplete: function(twn:FlxTween)
						{
							chromTween = null;
						}
					});
				}
			case 'Isolated':
				var beatBopArray:Array<Int> = [32, 36, 40, 44, 48, 52, 56, 60, 64, 68, 72, 76, 80, 84, 88, 92];
				var beatBopArray2:Array<Int> = [168, 172, 176, 184, 188];
				var beatBopArray3:Array<Int> = [194, 196, 198, 200, 202, 204, 206, 208, 210, 212, 214, 216, 217, 218, 219, 220, 221, 222, 223];

				switch (curBeat)
				{
					case 12: camBars.fade(FlxColor.BLACK, 3, true);

					case 30:
						FlxTween.tween(camHUD, {alpha: 1}, 3, {ease: FlxEase.quadOut});
						FlxTween.tween(camNotes, {alpha: 1}, 3, {ease: FlxEase.quadOut});

					case 88: 
						tweenCamera(1.4, 3, 'sineInOut');
						camFlashSystem(BG_FLASH, {alpha: 0.32, timer: 1.2, colors: [194, 194, 194]});

					case 95: 
						cameraSpeed += 3;
						isCameraOnForcedPos = true;
						camFollow.x -= 950;
						//updateSectionCamera('dad', false);

					case 96:
						isCameraOnForcedPos = false;
						cameraSpeed -= 3;
						defaultCamZoom = 0.85;
						tweenCamera(0.85, 0.4, 'expoOut');

						if (ClientPrefs.flashing)
							camGame.flash(FlxColor.WHITE, 1.5);
						camFlashSystem(BG_FLASH, {alpha: 0.4, timer: 0.35});

					case 160: 
						tweenCamera(1.3, 2, 'sineInOut');
						camFlashSystem(BG_DARK, {alpha: 0.85, timer: 0.5, ease: FlxEase.quartOut});

					case 184:
						camFlashSystem(BG_DARK, {alpha: 0.77, timer: 0.5, ease: FlxEase.quartOut});

					case 188:
						camFlashSystem(BG_DARK, {alpha: 0.6, timer: 0.5, ease: FlxEase.quartOut});

					case 192: 
						if (ClientPrefs.flashing)
							camGame.flash(FlxColor.WHITE, 1.5);
						camFlashSystem(BG_FLASH, {alpha: 0.32, timer: 0.35, colors: [194, 194, 194]});
						
						defaultCamZoom = 1.25;

					// same as dad
					// case 199: updateSectionCamera('bf', true);

					// update after testing without the cam thing they rarely still stunned so idk what to do lmao

					case 220: 
						tweenCamera(0.85, 2, 'sineInOut');
						camFlashSystem(BG_FLASH, {alpha: 0.32, timer: 0.1, colors: [194, 194, 194]});

					case 288:
						defaultCamZoom = 0.85;

						if (ClientPrefs.flashing)
							camGame.flash(FlxColor.WHITE, 1.5);
						camFlashSystem(BG_FLASH, {alpha: 0.4, timer: 0.35, colors: [194, 194, 194]});

					case 352:
						camFlashSystem(BG_DARK, {alpha: 0.85, timer: 0.5, ease: FlxEase.quartOut});
						tweenCamera(1.07, 5, 'quadInOut');
						cameraSpeed -= 0.25;

					case 376:
						camFlashSystem(BG_DARK, {alpha: 0, timer: 4, ease: FlxEase.quartInOut});

					case 36 | 40 | 44 | 52 | 56 | 60 | 64 | 68 | 72 | 76 | 80 | 84 | 92:
						camFlashSystem(BG_FLASH, {alpha: 0.32, timer: 1.2, colors: [194, 194, 194]});

					case 100 | 104 | 108 | 116 | 120 | 124 | 132 | 136 | 140 | 148 | 152 | 156 | 228 | 232 | 236 | 240 | 244 | 252 | 260 | 264 | 268 | 276 |
						280 | 284 | 292 | 296 | 300 | 308 | 312 | 316 | 324 | 328 | 332 | 340 | 344 | 348:
						camFlashSystem(BG_FLASH, {alpha: 0.2, timer: 0.35, colors: [194, 194, 194]});

					case 98 | 102 | 106 | 110 | 114 | 118 | 122 | 126 | 130 | 134 | 138 | 142 | 146 | 150 | 154 | 158 | 226 | 230 | 234 | 238 | 242 | 246 |
						250 | 254 | 258 | 262 | 266 | 270 | 274 | 278 | 282 | 286 | 290 | 294 | 298 | 302 | 306 | 310 | 314 | 318 | 322 | 326 | 330 | 334 |
						338 | 342 | 346 | 350:
						camFlashSystem(BG_FLASH, {alpha: 0.55, timer: 0.35, colors: [194, 194, 194]});

					case 194 | 196 | 198 | 200 | 202 | 204 | 206 | 210 | 212 | 214 | 222:
						camFlashSystem(BG_FLASH, {alpha: 0.32, timer: 0.35, colors: [194, 194, 194]});

					case 216 | 217 | 218 | 219:
						camFlashSystem(BG_FLASH, {alpha: 0.32, timer: 0.1, colors: [194, 194, 194]});
						camHUD.zoom += 0.04;
						camNotes.zoom += .04;

					case 128 | 256:
						if (ClientPrefs.flashing)
							camGame.flash(FlxColor.WHITE, 1.5);
						camFlashSystem(BG_FLASH, {alpha: 0.4, timer: 0.35, colors: [194, 194, 194]});

					case 48 | 336 | 304 | 272 | 112 | 144:
						if (ClientPrefs.flashing)
							camGame.flash(FlxColor.BLACK, 1.5);
						camFlashSystem(BG_FLASH, {alpha: 0.32, timer: 1.2, colors: [194, 194, 194]});

					case 32:
						if (ClientPrefs.flashing) camGame.flash(FlxColor.WHITE, 1.5);

					case 416:
						camGame.visible = false;
						camHUD.visible = false;
						camNotes.visible = false;

					case 224:
						camFlashSystem(BG_FLASH, {alpha: 0.4, timer: 0.35, colors: [194, 194, 194]});
						if (ClientPrefs.flashing) camGame.flash(FlxColor.WHITE, 1.5);

					case 320:
						camFlashSystem(BG_FLASH, {alpha: 0.4, timer: 0.35, colors: [194, 194, 194]});
						if (ClientPrefs.flashing) camGame.flash(FlxColor.WHITE, 1.5);
				}

				if (curBeat == 1)
				{
					cinematicBarControls("add", 0.0001, 'linear', 0);
					cinematicBarControls("moveboth", 0.0001, 'linear', 130);
				}
				if (curBeat == 28)
					cinematicBarControls("moveboth", 1, 'circInOut', 65);
				for (i in 0...beatBopArray.length)
					if (curBeat == beatBopArray[i])
						cinematicBarControls('bopboth', 1, 'quartOut', 32, 33);
				if (curBeat == 96)
					cinematicBarControls('moveboth', 0.3, 'sineOut', 0);
				if (curBeat == 160 || curBeat == 352)
					cinematicBarControls('moveboth', 1, 'circOut', 140);
				if (curBeat == 164 || curBeat == 180)
					cinematicBarControls('bopboth', 0.85, 'quartOut', 125, 15);
				for (i in 0...beatBopArray2.length)
					if (curBeat == beatBopArray2[i])
						cinematicBarControls('bopboth', 1, 'quartOut', 90, 60);
				if (curBeat == 192)
					cinematicBarControls('moveboth', 0.7, 'sineOut', 85);
				for (i in 0...beatBopArray3.length)
					if (curBeat == beatBopArray3[i])
						cinematicBarControls('bopboth', 0.3, 'sineOut', 40, 45);
				if (curBeat == 224)
					cinematicBarControls('moveboth', 0.3, 'quartOut', 0);
				if (curBeat == 287)
					cinematicBarControls('moveboth', 0.0001, 'linear', 100);
				if (curBeat == 288)
					cinematicBarControls('moveboth', 0.75, 'circOut', 0);
				if (curBeat == 376)
					cinematicBarControls('moveboth', 3, 'sineInOut', 0);
				if (curBeat == 415)
					cinematicBarControls('moveboth', 0.63, 'circInOut', 600);

				if ((curBeat > 96 && curBeat < 160) || (curBeat > 224 && curBeat < 352))
				{
					if (curBeat % 2 == 0)
					{
						camGame.zoom += 0.05;
						camHUD.zoom += 0.06;
						camNotes.zoom = camHUD.zoom;
					}
				}

			case 'Lunacy':
				var beatArray1:Array<Int> = [38, 40, 46, 48, 54, 56, 62];
				var beatArray2:Array<Int> = [70, 72, 78, 80, 86, 88];
				var beatArray3:Array<Int> = [224, 230, 240, 248, 256, 262, 272, 280, 288, 296, 304, 312, 320, 328, 336, 344];
				var beatArray4:Array<Int> = [228, 238, 244, 252, 260, 270, 276, 284, 292, 300, 308, 316, 324, 332, 340, 348];

				if (curBeat == 1)
					{
						cinematicBarControls("add", 0.0001, 'linear', 0);
						cinematicBarControls("moveboth", 0.0001, 'linear', 60);
					}
					if (curBeat == 32)
						cinematicBarControls("moveboth", 1.2, "circOut", 120);
					if (curBeat == 64)
						cinematicBarControls("moveboth", 1.2, "circOut", 190);
					if (curBeat == 90)
						cinematicBarControls("moveboth", 2, "circInOut", 0);
					for (i in 0...beatArray1.length)
						if (curBeat == beatArray1[i])
							cinematicBarControls("bopboth", 0.5, "quartOut", 100, 20);
					for (i in 0...beatArray2.length)
						if (curBeat == beatArray2[i])
							cinematicBarControls("bopboth", 0.5, "quartOut", 170, 20);
					if (curBeat == 156)
						cinematicBarControls("moveboth", 0.4, "circOut", 120);
					if (curBeat == 160)
						cinematicBarControls("moveboth", 1, "circOut", 80);
					if (curBeat == 192)
						cinematicBarControls("moveboth", 10, "circInOut", 180);
					for (i in 0...beatArray3.length)
						if (curBeat == beatArray3[i])
							cinematicBarControls("moveboth", 0.5, "circOut", 60);
					for (i in 0...beatArray4.length)
						if (curBeat == beatArray4[i])
							cinematicBarControls("moveboth", 0.15, "circOut", 130);
					if (curBeat == 352)
						cinematicBarControls("moveboth", 2, "circOut", 50);
					if (curBeat == 480)
						cinematicBarControls("moveboth", 0.0001, 'linear', 110);

				if (curBeat == 100 || curBeat == 108 || curBeat == 116 || curBeat == 124 || curBeat == 132 || curBeat == 140 || curBeat == 148)
				{
					camFlashSystem(BG_FLASH, {alpha: 0.5, timer: 0.5, ease: FlxEase.sineOut});
				}

				if (curBeat == 160 || curBeat == 230 || curBeat == 240 || curBeat == 248 || curBeat == 256 || curBeat == 262 || curBeat == 272
					|| curBeat == 280 || curBeat == 280 || curBeat == 288 || curBeat == 296 || curBeat == 304 || curBeat == 312 || curBeat == 320
					|| curBeat == 328 || curBeat == 336 || curBeat == 344 || curBeat == 352)
				{
					camFlashSystem(BG_DARK, {alpha: 0, timer: 0.5, ease: FlxEase.quadOut});
				}

				// Darkens BG
				if (curBeat == 156 || curBeat == 228 || curBeat == 238 || curBeat == 244 || curBeat == 252 || curBeat == 260 || curBeat == 270
					|| curBeat == 276 || curBeat == 284 || curBeat == 292 || curBeat == 300 || curBeat == 308 || curBeat == 316 || curBeat == 324
					|| curBeat == 332 || curBeat == 340 || curBeat == 348)
				{
					camFlashSystem(BG_DARK, {alpha: 0.77, timer: 0.5, ease: FlxEase.quadOut});
				}

				if (curBeat == 424 || curBeat == 432 || curBeat == 440 || curBeat == 448 || curBeat == 456 || curBeat == 464 || curBeat == 472)
				{
					camFlashSystem(BG_FLASH, {alpha: 0.65, timer: 0.6, ease: FlxEase.sineOut});
				}

				if (curBeat == 32 || curBeat == 64)
				{
					if (chromTween != null)
						chromTween.cancel();

					chromEffect = 0.27;

					chromTween = FlxTween.tween(instance, {
						chromEffect: 0.0001
					}, 1.5, {
						ease: FlxEase.sineOut,
						onComplete: function(twn:FlxTween)
						{
							chromTween = null;
						}
					});
				}

				if (curBeat == 38 || curBeat == 40 || curBeat == 46 || curBeat == 48 || curBeat == 54 || curBeat == 56 || curBeat == 62 || curBeat == 70
					|| curBeat == 72 || curBeat == 78 || curBeat == 80 || curBeat == 86 || curBeat == 88 || curBeat == 102 || curBeat == 110
					|| curBeat == 118 || curBeat == 126 || curBeat == 134 || curBeat == 142 || curBeat == 150)
				{
					if (chromTween != null)
						chromTween.cancel();

					chromEffect = 0.12;

					chromTween = FlxTween.tween(instance, {
						chromEffect: 0.0001
					}, 0.3, {
						ease: FlxEase.sineOut,
						onComplete: function(twn:FlxTween)
						{
							chromTween = null;
						}
					});
				}

				if (curBeat == 96 || curBeat == 104 || curBeat == 112 || curBeat == 120 || curBeat == 128 || curBeat == 136 || curBeat == 144 || curBeat == 152)
				{
					if (chromTween != null)
						chromTween.cancel();

					chromEffect = 0.32;

					chromTween = FlxTween.tween(instance, {
						chromEffect: 0.0001
					}, 2.1, {
						ease: FlxEase.sineOut,
						onComplete: function(twn:FlxTween)
						{
							chromTween = null;
						}
					});
				}

				if (curBeat == 100 || curBeat == 108 || curBeat == 116 || curBeat == 124 || curBeat == 132 || curBeat == 140 || curBeat == 148)
				{
					if (chromTween != null)
						chromTween.cancel();
	
					chromEffect = 0.4;
	
					chromTween = FlxTween.tween(instance, {
						chromEffect: 0.0001
					}, 1, {
						ease: FlxEase.sineOut,
						onComplete: function(twn:FlxTween)
						{
							chromTween = null;
						}
					});
				}

				if (curBeat == 156)
				{
					if (chromTween != null)
						chromTween.cancel();

					chromTween = FlxTween.tween(instance, {
						chromEffect: 0.33
					}, 0.2, {
						ease: FlxEase.sineOut,
						onComplete: function(twn:FlxTween)
						{
							chromTween = null;
						}
					});
				}

				if (curBeat == 158)
				{
					if (chromTween != null)
						chromTween.cancel();

					chromEffect = 0.4;

					chromTween = FlxTween.tween(instance, {
						chromEffect: 0.0001
					}, 0.2, {
						ease: FlxEase.sineOut,
						onComplete: function(twn:FlxTween)
						{
							chromTween = null;
						}
					});
				}

				if (curBeat == 160 || curBeat == 168 || curBeat == 176 || curBeat == 184 || curBeat == 192 || curBeat == 200 || curBeat == 208
					|| curBeat == 216 || curBeat == 224 || curBeat == 232 || curBeat == 240 || curBeat == 248 || curBeat == 256 || curBeat == 264
					|| curBeat == 272 || curBeat == 280 || curBeat == 288 || curBeat == 296 || curBeat == 304 || curBeat == 312 || curBeat == 320
					|| curBeat == 328 || curBeat == 336 || curBeat == 344)
				{
					if (chromTween != null)
						chromTween.cancel();

					chromEffect = 0.55;

					chromTween = FlxTween.tween(instance, {
						chromEffect: 0.0001
					}, 0.6, {
						ease: FlxEase.sineOut,
						onComplete: function(twn:FlxTween)
						{
							chromTween = null;
						}
					});
				}

				if (curBeat == 162 || curBeat == 170 || curBeat == 178 || curBeat == 186 || curBeat == 194 || curBeat == 202 || curBeat == 210
					|| curBeat == 218 || curBeat == 226 || curBeat == 234 || curBeat == 242 || curBeat == 250 || curBeat == 258 || curBeat == 266
					|| curBeat == 274 || curBeat == 282 || curBeat == 290 || curBeat == 298 || curBeat == 306 || curBeat == 314 || curBeat == 322
					|| curBeat == 330 || curBeat == 338 || curBeat == 346)
				{
					if (chromTween != null)
						chromTween.cancel();

					chromEffect = 0.6;

					chromTween = FlxTween.tween(instance, {
						chromEffect: 0.0001
					}, 0.25, {
						ease: FlxEase.sineOut,
						onComplete: function(twn:FlxTween)
						{
							chromTween = null;
						}
					});
				}

				if (curBeat == 163 || curBeat == 171 || curBeat == 179 || curBeat == 187 || curBeat == 195 || curBeat == 203 || curBeat == 211
					|| curBeat == 219 || curBeat == 227 || curBeat == 235 || curBeat == 243 || curBeat == 251 || curBeat == 259 || curBeat == 267
					|| curBeat == 275 || curBeat == 283 || curBeat == 291 || curBeat == 299 || curBeat == 307 || curBeat == 315 || curBeat == 323
					|| curBeat == 331 || curBeat == 339 || curBeat == 347)
				{
					if (chromTween != null)
						chromTween.cancel();

					chromTween = FlxTween.tween(instance, {
						chromEffect: 0.5
					}, 0.22, {
						ease: FlxEase.sineOut,
						onComplete: function(twn:FlxTween)
						{
							chromTween = null;
							chromEffect = 0.00001;
						}
					});
				}

				if (curBeat == 165 || curBeat == 173 || curBeat == 181 || curBeat == 189 || curBeat == 197 || curBeat == 205 || curBeat == 213
					|| curBeat == 221)
				{
					if (chromTween != null)
						chromTween.cancel();

					chromTween = FlxTween.tween(instance, {
						chromEffect: 0.35
					}, 0.2, {
						ease: FlxEase.sineOut,
						onComplete: function(twn:FlxTween)
						{
							chromTween = null;
							chromEffect = 0.00001;
						}
					});
				}

				if (curBeat == 166 || curBeat == 174 || curBeat == 182 || curBeat == 190 || curBeat == 198 || curBeat == 206 || curBeat == 214
					|| curBeat == 222)
				{
					if (chromTween != null)
						chromTween.cancel();

					chromEffect = 0.45;

					chromTween = FlxTween.tween(instance, {
						chromEffect: 0.0001
					}, 0.2, {
						ease: FlxEase.sineOut,
						onComplete: function(twn:FlxTween)
						{
							chromTween = null;
						}
					});
				}

				if (curBeat == 167 || curBeat == 175 || curBeat == 183 || curBeat == 191 || curBeat == 199 || curBeat == 207 || curBeat == 215
					|| curBeat == 223)
				{
					if (chromTween != null)
						chromTween.cancel();

					chromEffect = 0.56;

					chromTween = FlxTween.tween(instance, {
						chromEffect: 0.0001
					}, 0.2, {
						ease: FlxEase.sineOut,
						onComplete: function(twn:FlxTween)
						{
							chromTween = null;
						}
					});
				}

				if (curBeat >= 228 && curBeat <= 231 || curBeat >= 236 && curBeat <= 239 || curBeat >= 244 && curBeat <= 247 || curBeat >= 252
					&& curBeat <= 255 || curBeat >= 260 && curBeat <= 263 || curBeat >= 168 && curBeat <= 171 || curBeat >= 276 && curBeat <= 279
					|| curBeat >= 284 && curBeat <= 287 || curBeat >= 292 && curBeat <= 295 || curBeat >= 300 && curBeat <= 303 || curBeat >= 308
					&& curBeat <= 311 || curBeat >= 316 && curBeat <= 319 || curBeat >= 324 && curBeat <= 327 || curBeat >= 332 && curBeat <= 335
					|| curBeat >= 340 && curBeat <= 343 || curBeat >= 348 && curBeat <= 351)
				{
					if (chromTween != null)
						chromTween.cancel();

					chromEffect = 0.32;

					chromTween = FlxTween.tween(instance, {
						chromEffect: 0.00001
					}, 0.22, {
						ease: FlxEase.sineOut,
						onComplete: function(twn:FlxTween)
						{
							chromTween = null;
						}
					});
				}

				if (curBeat == 352 || curBeat == 354 || curBeat == 356 || curBeat == 358 || curBeat == 360 || curBeat == 362 || curBeat == 364
					|| curBeat == 366 || curBeat == 368 || curBeat == 370 || curBeat == 372 || curBeat == 374 || curBeat == 376 || curBeat == 378
					|| curBeat == 380 || curBeat == 382 || curBeat == 384 || curBeat == 386 || curBeat == 388 || curBeat == 390 || curBeat == 392
					|| curBeat == 394 || curBeat == 396 || curBeat == 398 || curBeat == 400 || curBeat == 402 || curBeat == 404 || curBeat == 406
					|| curBeat == 408 || curBeat == 410 || curBeat == 416 || curBeat == 418 || curBeat == 420 || curBeat == 422 || curBeat == 424
					|| curBeat == 426 || curBeat == 428 || curBeat == 430 || curBeat == 432 || curBeat == 434 || curBeat == 436 || curBeat == 438
					|| curBeat == 440 || curBeat == 442 || curBeat == 444 || curBeat == 446 || curBeat == 448 || curBeat == 450 || curBeat == 452
					|| curBeat == 454 || curBeat == 456 || curBeat == 458 || curBeat == 460 || curBeat == 462 || curBeat == 464 || curBeat == 466
					|| curBeat == 468 || curBeat == 470 || curBeat == 472 || curBeat == 474)
				{
					if (chromTween != null)
						chromTween.cancel();

					chromEffect = 0.3;

					chromTween = FlxTween.tween(instance, {
						chromEffect: 0.00001
					}, 0.5, {
						ease: FlxEase.sineOut,
						onComplete: function(twn:FlxTween)
						{
							chromTween = null;
						}
					});
				}

				if (curBeat == 412)
				{
					if (chromTween != null)
						chromTween.cancel();

					chromEffect = 0.36;

					chromTween = FlxTween.tween(instance, {
						chromEffect: 0.00001
					}, 1, {
						ease: FlxEase.sineOut,
						onComplete: function(twn:FlxTween)
						{
							chromTween = null;
						}
					});
				}

				if (curBeat == 476)
				{
					if (chromTween != null)
						chromTween.cancel();

					chromTween = FlxTween.tween(instance, {
						chromEffect: 0.85
					}, 1.6, {
						ease: FlxEase.sineOut,
						onComplete: function(twn:FlxTween)
						{
							chromTween = null;
						}
					});
				}

				if (curBeat == 480)
				{
					chromTween.cancel();

					chromEffect = 0.00001;
				}

				switch (curBeat)
				{
					// I'm NOT gonna have a fun time recoding all this for the BG dimming in and out later lmao

					case 16: camBars.fade(FlxColor.BLACK, 3, true);

					case 32:
						if (ClientPrefs.flashing) camBars.flash(FlxColor.BLACK, 1.5);
						tweenCamera(camGame.zoom + .5, 16.5, 'sineInOut');

					case 64:
						if (ClientPrefs.flashing)
							camBars.flash(FlxColor.BLACK, 0.9);

					case 88:
						tweenCamera(.75, 2.2, 'sineInOut');

						FlxTween.tween(camHUD, {alpha: 1}, 5, {ease: FlxEase.sineOut});
						FlxTween.tween(camNotes, {alpha: 1}, 5, {ease: FlxEase.sineOut});

					case 96:
						defaultCamZoom = 0.75;
						if (ClientPrefs.flashing)
							camBars.flash(FlxColor.WHITE, 1.5);

					case 128 | 256:
						if (ClientPrefs.flashing) camBars.flash(FlxColor.WHITE, 1.5);

					case 156:
						defaultCamZoom = 1.05;

					case 160:
						boundValue = 1.25;
						drainValue = 0.015;
						defaultCamZoom = 0.7;
						if (ClientPrefs.flashing) camBars.flash(FlxColor.BLACK, 1.5);

					case 192:
						defaultCamZoom = 0.75;
					case 200 | 238 | 270 | 316 | 332 | 344:
						defaultCamZoom = 0.8;
					case 208:
						defaultCamZoom = 0.85;
					case 216 | 252 | 284:
						defaultCamZoom = 0.9;
					case 220:
						defaultCamZoom = 0.95;
					case 222 | 267 | 239 | 271 | 334:
						defaultCamZoom = 1;

					case 224 | 288:
						defaultCamZoom = 0.75;
						if (ClientPrefs.flashing)
							camBars.flash(FlxColor.WHITE, 1.5);
						FlxTween.tween(camHUD, {alpha: 0}, 3, {ease: FlxEase.sineInOut});
						FlxTween.tween(camNotes, {alpha: 0}, 3, {ease: FlxEase.sineInOut});

					case 228 | 260 | 292 | 286:
						defaultCamZoom = 1.1;

					case 230 | 262 | 296 | 312 | 236 | 268:
						defaultCamZoom = 0.65;

					case 232 | 264:
						if (ClientPrefs.flashing)
							camBars.flash(FlxColor.WHITE, 1.5);
						defaultCamZoom = 0.7;

					case 412 | 240 | 272 | 300 | 304 | 336 | 248 | 280 | 328:
						defaultCamZoom = 0.7;

					case 320:
						if (ClientPrefs.flashing)
							camBars.flash(FlxColor.WHITE, 1.5);
						defaultCamZoom = 0.7;

					case 254:
						defaultCamZoom = 1.1;
						FlxTween.tween(camHUD, {alpha: 1}, 1, {ease: FlxEase.sineInOut});
						FlxTween.tween(camNotes, {alpha: 1}, 1, {ease: FlxEase.sineInOut});

					case 318:
						defaultCamZoom = 1.25;
						FlxTween.tween(camHUD, {alpha: 1}, 1, {ease: FlxEase.sineInOut});
						FlxTween.tween(camNotes, {alpha: 1}, 1, {ease: FlxEase.sineInOut});

					case 310 | 342 | 350:
						defaultCamZoom = 1.25;

					case 352:
						defaultCamZoom = 0.65;
						FlxTween.tween(camHUD, {alpha: 0.25}, 8, {ease: FlxEase.sineInOut});
						FlxTween.tween(camNotes, {alpha: 0.25}, 8, {ease: FlxEase.sineInOut});
						FlxTween.tween(this, {healthThing: 0.01}, 20);
						if (globalGradient != null)
							FlxTween.tween(globalGradient, {alpha: 0.8}, 10);
						FlxTween.tween(FlxG.camera, {zoom: 1.1}, 18, {startDelay: 2});

					case 408:
						defaultCamZoom = 0.9;
						FlxTween.tween(camHUD, {alpha: 0.36}, 4, {ease: FlxEase.sineInOut});
						FlxTween.tween(camNotes, {alpha: 0.36}, 4, {ease: FlxEase.sineInOut});

					case 416: if (ClientPrefs.flashing) camBars.flash(FlxColor.WHITE, 1.5);

					case 480:
						boundValue = 1;
						drainValue = 0.02;
						if (ClientPrefs.flashing)
							camBars.flash(FlxColor.BLACK, 1.5);
						camHUD.alpha = 0;
						camNotes.alpha = 0;

					case 481:
						camFollow.x += 100;
	
					case 506:
						FlxTween.tween(camHUD, {alpha: 0.5}, 4, {ease: FlxEase.sineInOut});
						FlxTween.tween(camNotes, {alpha: 0.5}, 4, {ease: FlxEase.sineInOut});

					case 536:
						FlxTween.tween(camHUD, {alpha: 0}, 2, {ease: FlxEase.sineInOut});
						FlxTween.tween(camNotes, {alpha: 0}, 2, {ease: FlxEase.sineInOut});

					case 540:
						camBars.fade(FlxColor.BLACK, 5);
				}

			case 'Delusional':
				var beatShit1:Array<Int> = [752, 760, 768, 772, 776, 784, 792, 800, 804, 808, 824, 836, 856, 868];
				var beatShit2:Array<Int> = [812, 828, 844, 860];
				var beatShit3:Array<Int> = [816, 832, 848, 864];
				if (curBeat == 1)
				{
					cinematicBarControls("create", 1);
					cinematicBarControls("moveboth", 0.0001, 'linear', 100);
				}
				if (curBeat == 32)
					cinematicBarControls("moveboth", 2, 'circOut', 120);
				if (curBeat == 64)
					cinematicBarControls("moveboth", 2, 'circInOut', 75);
				if (curBeat ==128 || curBeat == 1072)
					cinematicBarControls("moveboth", 1, "circOut", 90);
				if (curBeat == 132)
					cinematicBarControls("moveboth", 2, "circOut", 180);
				if (curBeat == 144)
					cinematicBarControls("moveboth", 0.0001, 'linear', 70);
				if (curBeat == 152 || curBeat == 168)
					cinematicBarControls("moveboth", 0.5, 'circOut', 80);
				if (curBeat == 154 || curBeat == 172)
					cinematicBarControls("moveboth", 0.5, 'circOut', 90);
				if (curBeat == 156 || curBeat == 288 || curBeat == 320)
					cinematicBarControls("moveboth", 0.5, 'circOut', 100);
				if (curBeat == 158 || curBeat == 296 || curBeat == 328)
					cinematicBarControls("moveboth", 0.5, 'circOut', 110);
				if (curBeat == 160)
					cinematicBarControls("moveboth", 1, 'circOut', 70);
				if (curBeat == 176)
					cinematicBarControls("moveboth", 2, 'circOut', 0);
				if (curBeat == 280 || curBeat == 312)
					cinematicBarControls("moveboth", 1.5, 'circOut', 90);
				if (curBeat == 304 || curBeat == 336 || curBeat == 356 || curBeat == 388)
					cinematicBarControls("moveboth", 0.5, 'circOut', 120);
				if (curBeat == 308 || curBeat == 358 || curBeat == 390)
					cinematicBarControls("moveboth", 0.5, 'circOut', 130);
				if (curBeat == 338)
					cinematicBarControls("moveboth", 1, 'circOut', 80);
				if (curBeat == 344 || curBeat == 360 || curBeat == 392)
					cinematicBarControls("moveboth", 1, 'circOut', 100);
				if (curBeat == 408)
					cinematicBarControls("moveboth", 2, 'circOut', 140);
				if (curBeat == 470)
					cinematicBarControls("moveboth", 0.65, 'backIn', 380);
				if (curBeat == 480)
					cinematicBarControls("moveboth", 10, 'linear', 70);
				if (curBeat == 744)
					cinematicBarControls("moveboth", 0.0001, 'linear', 120);
				for (bounceYouStupidBitch in 0...beatShit1.length)
					if (curBeat == beatShit1[bounceYouStupidBitch])
						cinematicBarControls("bopboth", 0.5, "circOut", 90, 30);
				for (helloEverybodyMyNameIsMarkiplierAndWelcomeToFiveNightsAtFreddysAnIndieHorrorGameThatYouGuysSuggestedInMassAndISawYamimashPlayedItAndHeSaidItWasReallyReallyGoodSoImEagerToSeeWhatIsUp in 0...beatShit2.length)
					if (curBeat == beatShit2[helloEverybodyMyNameIsMarkiplierAndWelcomeToFiveNightsAtFreddysAnIndieHorrorGameThatYouGuysSuggestedInMassAndISawYamimashPlayedItAndHeSaidItWasReallyReallyGoodSoImEagerToSeeWhatIsUp])
						cinematicBarControls("moveboth", 0.8, "circIn", 185);
				for (youreCringe in 0...beatShit3.length)
					if (curBeat == beatShit3[youreCringe])
						cinematicBarControls("moveboth", 0.8, "circOut", 120);
				if (curBeat == 872)
					cinematicBarControls("moveboth", 2.5, "circInOut", 180);
				if (curBeat == 880 || curBeat == 1040)
					cinematicBarControls("moveboth", 1, "circOut", 100);
				if (curBeat == 944 || curBeat == 1056)
					cinematicBarControls("moveboth", 1.5, "circOut", 120);
				if (curBeat == 1008 || curBeat == 1064)
					cinematicBarControls("moveboth", 1, "circOut", 140);
				if (curBeat == 1024)
					cinematicBarControls("moveboth", 1, "circOut", 80);
				if (curBeat == 1030)
					cinematicBarControls("moveboth", 1, "circOut", 100);
				if (curBeat == 1136)
					cinematicBarControls("kill", 0);

				if (curBeat == 146)
					manageLyrics('evilpredelu', 'Count the minutes...', 'disneyFreeplayFont.ttf', 30, 1.1, 'sineInOut', .05);
				if (curBeat == 150)
					manageLyrics('evilpredelu', "...of how long...", 'disneyFreeplayFont.ttf', 30, 1, 'sineInOut', 0.04);
				if (curBeat == 154)
					manageLyrics('evilpredelu', "...this show will play!", 'disneyFreeplayFont.ttf', 30, 2.2, 'quartInOut', .07);
				if (curBeat == 162)
					manageLyrics('evilpredelu', "And remind yourself...", 'disneyFreeplayFont.ttf', 30, 1.3, 'sineInOut', .05);
				if (curBeat == 167)
					manageLyrics('evilpredelu', "...no matter what's in...", 'disneyFreeplayFont.ttf', 30, 2, 'sineInOut', .06);
				if (curBeat == 174)
					manageLyrics('evildelu', "...THE WAY!", 'disneyFreeplayFont.ttf', 30, 1, 'circOut', .035);
				if (curBeat == 178)
					manageLyrics('evildelu', "All your dreams...", 'disneyFreeplayFont.ttf', 30, 1, 'sineInOut', .04);
				if (curBeat == 182)
					manageLyrics('evildelu', "...ARE SO FAR OUT OF REACH!", 'disneyFreeplayFont.ttf', 30, 4, 'quartInOut', .055);
				if (curBeat == 190)
					manageLyrics('evildelu', "But if YOUR delusions...", 'disneyFreeplayFont.ttf', 30, 2.2, 'sineInOut', .045);
				if (curBeat == 196)
					manageLyrics('evildelu', "...still surround ya.", 'disneyFreeplayFont.ttf', 30, 1.3, "quartOut", .045);
				if (curBeat == 200)
					manageLyrics('evildelu', "Let's LOOP 'ROUND ONCE MORE.", 'disneyFreeplayFont.ttf', 30, 3, "sineInOut", .065);

				switch (curBeat)
				{
					case 1: 
						boundValue = 1;
						drainValue = 0.02;
						camBars.fade(FlxColor.BLACK, 2, true);
					case 132: defaultCamZoom = 1.3;
					case 136:
						camBars.fade(FlxColor.BLACK, 0.6);
						for (daUIs in [camHUD, camNotes])
							FlxTween.tween(daUIs, {alpha: 0}, 3);
					// BF Starts Singing Some Lyrics
					case 143:
						camVideo.fade(FlxColor.BLACK, 5, true);
						camVideo.visible = true;
						deluSing.visible = true;
						deluSing.setVideoTime(0);
						deluSing.resume();
						if (vocals.volume != 1) vocals.volume = 1; // it should be fixed then
					case 144:
						defaultCamZoom = 0.8;
						camBars.fade(0x000000, 5, true);
						camFlashSystem(BG_DARK, {alpha: 1, timer: 0.3, ease: FlxEase.quartInOut});
						defaultCamZoom = 1.2;
						camFollow.x -= 100;
						boyfriend.alpha = 0.0001;
						FlxTween.tween(boyfriend, {alpha: 1}, 6, {ease: returnTweenEase('sineInOut')});
						FlxTween.tween(camFollow, {x: camFollow.x + 100}, 12, {ease: FlxEase.sineInOut});
					case 176:
						camFlashSystem(BG_DARK, {alpha: 0, timer: 0.3, ease: FlxEase.quartInOut});
						defaultCamZoom = 0.75;
						camGame.flash(FlxColor.WHITE, 1);

						// today in super r slur shit we have this cus i hate my life
						FlxTween.tween(camFollow, {y: camFollow.y - 300}, .00000001, {onComplete: bensonFromRegularShow -> {
							FlxTween.tween(camFollow, {y: camFollow.y + 300}, 7, {ease: FlxEase.sineInOut});
						}});
					case 180 | 188 | 196:
						camGame.zoom += 0.3;
						camFlashSystem(BG_FLASH, {alpha: 0.5, timer: 0.35});
					case 184 | 192 | 200:
						camGame.zoom += 0.15;
						camFlashSystem(BG_FLASH, {alpha: 0.25, timer: 0.35});
					case 204: defaultCamZoom = 1;
					case 208:
						camBars.fade(0x00000, .000001);
						defaultCamZoom = 1.3;

					// Mickey Screams Like A Bitch
					case 212:
						camVideo.visible = false;
						boundValue = 0.6;
						drainValue = 0.025;
						chromEffect = 0.3;
						chromTween = FlxTween.tween(instance, {chromEffect: 1}, 1.2);
						camBars.fade(0x00000, .000001, true);
						defaultCamZoom = 0.75;
						camGame.shake(0.01, 1.2);
					// The Drop Starts
					case 216:
						FlxTween.tween(camHUD, {alpha: 1}, 1, {ease: FlxEase.quadOut});
						FlxTween.tween(camNotes, {alpha: 1}, 1, {ease: FlxEase.quadOut});
						if (chromTween != null) chromTween.cancel();
						chromTween = FlxTween.tween(instance, {chromEffect: 0.18}, 0.6, {ease: FlxEase.sineOut});
						if (ClientPrefs.flashing)
							camGame.flash(FlxColor.WHITE, 0.5);
						if (canaddshaders)
						{
                            if (!ClientPrefs.lowQuality)
                            {
                                camGame.setFilters([
                                    new ShaderFilter(dramaticCamMovement),
                                    new ShaderFilter(monitorFilter),
                                    new ShaderFilter(chromZoomShader),
                                    new ShaderFilter(chromNormalShader),
                                    new ShaderFilter(delusionalShift)
                                ]);
                                camHUD.setFilters([new ShaderFilter(chromNormalShader), new ShaderFilter(delusionalShift)]);
                                camNotes.setFilters([
                                        new ShaderFilter(grayScale),
                                        new ShaderFilter(chromNormalShader),
                                        new ShaderFilter(delusionalShift)
                                    ]);
                            }
                            else
                            {
                                camGame.setFilters([
                                    new ShaderFilter(monitorFilter),
                                    new ShaderFilter(chromZoomShader),
                                    new ShaderFilter(chromNormalShader),
                                    new ShaderFilter(delusionalShift)
                                ]);
                                camHUD.setFilters([new ShaderFilter(chromNormalShader), new ShaderFilter(delusionalShift)]);
                                camNotes.setFilters([
                                        new ShaderFilter(grayScale),
                                        new ShaderFilter(chromNormalShader),
                                        new ShaderFilter(delusionalShift)
                                    ]);
                            }
						}
					case 228:
						chromTween = null;
						defaultCamZoom = 0.85;
					case 230: defaultCamZoom = 1;
					case 232: defaultCamZoom = 0.75;
					case 278: defaultCamZoom = 1;
					case 280 | 312 | 344: defaultCamZoom = 0.7;
					case 288 | 296 | 304 | 320 | 328 | 336: defaultCamZoom += 0.1;
					case 308: defaultCamZoom += 0.2;
					case 340: defaultCamZoom += 0.3;
					case 356 | 388: defaultCamZoom = 1.2;
					case 358 | 390: defaultCamZoom = 1.3;
					case 360: defaultCamZoom = 0.75;
					case 375:
						chromTween = FlxTween.tween(instance, {chromEffect: 1}, 0.1, {ease: FlxEase.sineInOut});
						tweenCamera(1.5, 0.1, 'sineInOut');
					case 376:
						if (chromTween != null) chromTween.cancel();
						chromTween = null;
						camGame.visible = false;
						camHUD.visible = false;
					case 377:
						camGame.visible = true;
						camHUD.visible = true;
						if (ClientPrefs.flashing)
							camGame.flash(FlxColor.WHITE, 1);
						defaultCamZoom = 0.8;
						chromTween = FlxTween.tween(instance, {chromEffect: 0.1}, 0.6, {ease: FlxEase.quadOut});
					case 472:
						useFakeDeluName = true;
						#if DISCORD_ALLOWED
						#if !DEV_BUILD
						DiscordClient.changePresence("...", "...", (useFakeDeluName ? "regret" : iconRPC), "random", true, songLength - Conductor.songPosition - ClientPrefs.noteOffset);
						#end
						#end
						if (isStoryMode)
						{
							detailsText = "Episode 1 - Regret (PEACEFUL)";
						}
						else
						{
							detailsText = "Freeplay - Regret (PEACEFUL)";
						}
						windowName = "...";
						lime.app.Application.current.window.title = windowName;
						boundValue = 2;
						drainValue = 0;
						camGame.visible = false;
						camHUD.visible = false;
						camNotes.visible = false;
						if (!lowQuality)
						{
							atmosphereParticle.visible = false;
							ashParticle.visible = false;
						}
					case 473:
						if (canaddshaders)
						{
                            if (!ClientPrefs.lowQuality)
                            {
                                camGame.setFilters([
                                    new ShaderFilter(dramaticCamMovement),
                                    new ShaderFilter(monitorFilter),
                                    new ShaderFilter(chromZoomShader),
                                    new ShaderFilter(chromNormalShader)
                                ]);
                               camHUD.setFilters([new ShaderFilter(chromNormalShader)]);
                                camNotes.setFilters([new ShaderFilter(grayScale), new ShaderFilter(chromNormalShader)]);
                            }
                            else
                            {
                                camGame.setFilters([
                                    new ShaderFilter(monitorFilter),
                                    new ShaderFilter(chromZoomShader),
                                    new ShaderFilter(chromNormalShader)
                                ]);
                                camHUD.setFilters([new ShaderFilter(chromNormalShader)]);
                                camNotes.setFilters([new ShaderFilter(grayScale), new ShaderFilter(chromNormalShader)]);
                            }
						}
						chromEffect = 0.00001;
						defaultCamZoom = 0.85;
					case 476:
						#if DISCORD_ALLOWED
						#if !DEV_BUILD
						DiscordClient.changePresence("Are You Satisfied?", "...", (useFakeDeluName ? "regret" : iconRPC), "random", true, songLength - Conductor.songPosition - ClientPrefs.noteOffset);
						#end
						#end
						windowName = "Where am I...?";
						lime.app.Application.current.window.title = windowName;
					case 478:
						camFollow.x = 630;
						camFollow.y = 750;
						isCameraOnForcedPos = true;
						defaultCamZoom = 0.5;
						boyfriend.cameras = [camVideo];
						boyfriend.x += 350;
						boyfriend.alpha = 0.0001;
						camVideo.visible = true;
					case 480:
						#if DISCORD_ALLOWED
						#if !DEV_BUILD
						DiscordClient.changePresence(detailsText, scoreTxt.text, (useFakeDeluName ? "regret" : iconRPC), "random", true, songLength - Conductor.songPosition - ClientPrefs.noteOffset);
						#end
						#end
						windowName = "Funkin.avi - " + (isStoryMode ? curEpisode + " - " : "Freeplay - ") + "Regret [________]";
						lime.app.Application.current.window.title = windowName;
						// no healthbar to add more onto the atmosphere of this section
						camGame.visible = true;
						camNotes.visible = true;
					case 484:
						windowName = "Funkin.avi - " + (isStoryMode ? curEpisode + " - " : "Freeplay - ") + "Regret [P_______]";
						lime.app.Application.current.window.title = windowName;
					case 488:
						windowName = "Funkin.avi - " + (isStoryMode ? curEpisode + " - " : "Freeplay - ") + "Regret [PE______]";
						lime.app.Application.current.window.title = windowName;
					case 492:
						windowName = "Funkin.avi - " + (isStoryMode ? curEpisode + " - " : "Freeplay - ") + "Regret [PEA_____]";
						lime.app.Application.current.window.title = windowName;
					case 496:
						windowName = "Funkin.avi - " + (isStoryMode ? curEpisode + " - " : "Freeplay - ") + "Regret [PEAC____]";
						lime.app.Application.current.window.title = windowName;
					case 500:
						windowName = "Funkin.avi - " + (isStoryMode ? curEpisode + " - " : "Freeplay - ") + "Regret [PEACE___]";
						lime.app.Application.current.window.title = windowName;
					case 504:
						windowName = "Funkin.avi - " + (isStoryMode ? curEpisode + " - " : "Freeplay - ") + "Regret [PEACEF__]";
						lime.app.Application.current.window.title = windowName;
					case 508:
						windowName = "Funkin.avi - " + (isStoryMode ? curEpisode + " - " : "Freeplay - ") + "Regret [PEACEFU_]";
						lime.app.Application.current.window.title = windowName;
						FlxTween.tween(boyfriend, {alpha: 0.45}, 2.5, {ease: FlxEase.expoOut});
					case 512:
						windowName = "Funkin.avi - " + (isStoryMode ? curEpisode + " - " : "Freeplay - ") + "Regret [PEACEFUL]";
						lime.app.Application.current.window.title = windowName;
					case 672:
						blendFlash.cameras = [camBars];
						boyfriend.alpha = 0.0001;
						camFlashSystem(CAM_FLASH_FANCY, {alpha: 0.38, timer: 0.85, colors: [255, 255, 255]});
						minnieJumpscare.resume();
						minnieJumpscare.visible = true;
					case 720:
						FlxTween.tween(camGame, {alpha: 0.0001}, 5, {ease: FlxEase.quartInOut});
						FlxTween.tween(camNotes, {alpha: 0.0001}, 5, {ease: FlxEase.quartInOut});
					case 728:
						windowName = "...";
						lime.app.Application.current.window.title = windowName;
					case 736:
						windowName = "Welcome back.... Little mouse.";
						lime.app.Application.current.window.title = windowName;
						blendFlash.cameras = [camGame];
					case 740:
						isCameraOnForcedPos = false;
						boundValue = 0.45;
						drainValue = 0.032;
						boyfriend.alpha = 1;
						camFollow.x = 0;
						camFollow.y = 0;
						if (!lowQuality)
						{
							atmosphereParticle.visible = true;
							ashParticle.visible = true;
						}
					case 744:
						useFakeDeluName = false;
						if (isStoryMode)
						{
							detailsText = "Episode 1 - " + SONG.song + " (" + FreeplayState.getDiffRank() + ")";
						}
						else
						{
							detailsText = "Freeplay - " + SONG.song + " (" + FreeplayState.getDiffRank() + ")";
						}
						#if DISCORD_ALLOWED
						#if !DEV_BUILD
						DiscordClient.changePresence(detailsText, scoreTxt.text, (useFakeDeluName ? "regret" : iconRPC), "random", true, songLength - Conductor.songPosition - ClientPrefs.noteOffset);
						#end
						#end
						windowName = "Funkin.avi - " + (isStoryMode ? curEpisode + " - " : "Freeplay - ") + SONG.song + " [" + FreeplayState.getDiffRank() + "]";
						lime.app.Application.current.window.title = windowName;
						camVideo.visible = false;
						camGame.alpha = 1;
						camHUD.visible = true;
						defaultCamZoom = 0.9;
						camNotes.alpha = 1;
						chromEffect = 0.1;
						if (ClientPrefs.flashing)
							camGame.flash(FlxColor.WHITE, 0.5);
						if (canaddshaders)
						{
                            if (!ClientPrefs.lowQuality)
                            {
                                camGame.setFilters([
                                    new ShaderFilter(dramaticCamMovement),
									new ShaderFilter(heatWaveEffect),
                                    new ShaderFilter(monitorFilter),
                                    new ShaderFilter(chromZoomShader),
                                    new ShaderFilter(chromNormalShader),
                                    new ShaderFilter(delusionalShift)
                                ]);
                                camHUD.setFilters([new ShaderFilter(chromNormalShader), new ShaderFilter(delusionalShift)]);
                                camNotes.setFilters([
                                        new ShaderFilter(grayScale),
                                        new ShaderFilter(chromNormalShader),
                                        new ShaderFilter(delusionalShift)
                                    ]);
                            }
                            else
                            {
                                camGame.setFilters([
                                    new ShaderFilter(monitorFilter),
                                    new ShaderFilter(chromZoomShader),
                                    new ShaderFilter(chromNormalShader),
                                    new ShaderFilter(delusionalShift)
                                ]);
                                camHUD.setFilters([new ShaderFilter(chromNormalShader), new ShaderFilter(delusionalShift)]);
                                camNotes.setFilters([
                                        new ShaderFilter(grayScale),
                                        new ShaderFilter(chromNormalShader),
                                        new ShaderFilter(delusionalShift)
                                    ]);
                            }
						}
					case 880 | 884 | 888 | 892 | 896 | 900 | 904 | 908 | 913 | 916 | 920 | 924 | 929 | 933 | 936 | 940 | 944 | 948 | 952 | 956 | 960 | 964 | 968 | 972 | 976 | 980 | 984 | 988 | 993 | 997 | 1000 | 1004:
						camFlashSystem(CAM_FLASH_FANCY, {alpha: 0.135, timer: 0.85, colors: [255, 0, 0]});
					// The part where shit gets serious, Evilrette/Satan starts the solo
					case 1008:
						boundValue = 1.5;
						drainValue = 0.01;
						tweenCamera(1.35, 7, "quartInOut");
						camFlashSystem(CAM_FLASH_FANCY, {alpha: 0.4, timer: 2, colors: [255, 0, 0]});
						camFlashSystem(BG_DARK, {alpha: 0.8, timer: 6, ease: FlxEase.quartInOut});
						isCameraOnForcedPos = true;
						FlxTween.tween(camFollow, {x: camFollow.x + 150, y: camFollow.y + 50}, 4.3, {ease: FlxEase.quartInOut});
					// camera moves over to Mickey realizing he was never gonna win
					case 1024:
						FlxTween.tween(camFollow, {x: camFollow.x - 950, y: camFollow.y - 70}, 1.5, {ease: FlxEase.circInOut});
					case 1040:
						camFollow.x = 440;
						camFollow.y = 360;
						FlxTween.tween(mickeySpirit, {alpha: 0.6}, 2, {ease: FlxEase.sineOut});
						defaultCamZoom = 0.5;
						camFlashSystem(BG_DARK, {alpha: 0, timer: 1, ease: FlxEase.circOut});
					case 1072:
						FlxTween.tween(mickeySpirit, {alpha: 0}, 4, {ease: FlxEase.quartOut});
						isCameraOnForcedPos = false;
						defaultCamZoom = 0.9;
					case 1082:
						FlxTween.tween(camGame, {zoom: 1.6}, 1, {ease: FlxEase.sineInOut});
						camVideo.visible = true;
						camVideo.fade(FlxColor.BLACK, 0.7);
					case 1086:
						camGame.visible = false;
						FlxTween.tween(camHUD, {alpha: 0}, 2);
						FlxTween.tween(camNotes, {alpha: 0}, 2);
						camVideo.zoom += 0.3;
						camVideo.fade(FlxColor.BLACK, 0.2, true);
						FlxTween.tween(camVideo, {zoom: 1}, 0.5, {ease: FlxEase.sineOut});
						camFlashSystem(BG_DARK, {timer: 5});
						death.setVideoTime(0);
						death.resume();
						death.visible = true;
					case 1134:
						camFlashSystem(BG_DARK, {alpha: 1, timer: 0.5, ease: FlxEase.sineOut});
					case 1136:
						camFlashSystem(BG_FLASH, {alpha: 1, timer: 0.3, ease: FlxEase.sineOut});
						if (canaddshaders)
							{
								if (!ClientPrefs.lowQuality)
								{
									camGame.setFilters([
										new ShaderFilter(dramaticCamMovement),
										new ShaderFilter(monitorFilter)
									]);
								}
								else
								{
									camGame.setFilters([
										new ShaderFilter(monitorFilter)
									]);
								}
							}
					case 1144:
						FlxTween.tween(camVideo, {alpha: 0}, 4);
				}

			if ((curBeat >= 216 && curBeat < 340) || (curBeat >= 344 && curBeat < 356) || (curBeat >= 360 && curBeat < 388) || 
				(curBeat >= 392 && curBeat < 408) || (curBeat >= 880 && curBeat < 1072))
			{
				FlxG.camera.zoom += .015;
				for (mridk in [camHUD, camNotes]) mridk.zoom += .03;
			}

			case "War Dilemma":
				switch (curBeat)
				{
					case 16:
						if (!ClientPrefs.downScroll && ClientPrefs.mechanics)
						{
							for (ui in [healthBar, healthBarBG, fancyBarOverlay, scoreTxt, iconP1, iconP2])
								FlxTween.tween(ui, {y: ui.y + 120}, 5, {ease: FlxEase.sineOut});
						}
						defaultCamZoom -= 0.5;
						cinematicBarControls("moveboth", 1, "circOut", 50);
						cinematicValue = 50;
					case 48 | 56 | 64 | 72:
						defaultCamZoom += 0.1;
						cinematicBarControls("moveboth", 1.5, "circOut", cinematicValue + 20);
						cinematicValue += 20;
					case 80:
						defaultCamZoom -= 0.4;
						cinematicBarControls("moveboth", 2, "backOut", 50);
						cinematicValue = 0;
					case 176:
						camBars.flash(FlxColor.BLACK, 8);
						for (cam in [camHUD, camNotes])
							cam.alpha = 0;
					case 208:
						for (hudShit in [camHUD, camNotes])
							FlxTween.tween(hudShit, {alpha: 1}, 2, {ease: FlxEase.quartOut});
					case 272 | 276 | 280 | 284:
						defaultCamZoom += .05;
					case 288:
						defaultCamZoom -= .2;
				}

				if (curBeat >= 240 && curBeat < 288 && curBeat % 2 == 0)
				{
					camGame.zoom += 0.015;
					camHUD.zoom += 0.03;
					camNotes.zoom += 0.03;
				}

				if (curBeat >= 288 && curBeat < 352)
				{
					camGame.zoom += 0.015;
					camHUD.zoom += 0.03;
					camNotes.zoom += 0.03;
				}
			case 'Scrapped':
				switch (curBeat)
				{
					case 64: FlxTween.tween(dad, {alpha: 1}, 10);
					case 424: FlxTween.tween(dad, {alpha: 0}, 5);
				}

			case "Twisted Grins":
				switch (curBeat)
				{
					case 1:
						defaultCamZoom += 0.25;
						opponentCameraOffset[0] -= 80;
						manageLyrics("smile", "Give me your smile!", 'disneyFreeplayFont.ttf', 30, 3.5, 'sineInOut', 0.08);
						camBars.fade(FlxColor.BLACK, 2, true);
					case 8:
						defaultCamZoom -= 0.25;
						opponentCameraOffset[0] += 80;
						for (hud in [camHUD, camNotes])
						{
							hud.zoom += 5;
							hud.visible = true;
						}
					case 20 | 32 | 36 | 52 | 64 | 68 | 102 | 120 | 128 | 132 | 252 | 304 | 308 | 336 | 340 | 360 | 364 | 368 | 372 | 404 | 414 | 508 | 528 | 544: 
						defaultCamZoom += 0.1;
					case 24 | 56 | 104 | 373 | 374 | 375 | 532:
						defaultCamZoom -= 0.1;
					case 40 | 72 | 312 | 328:
						defaultCamZoom -= 0.2;
					case 136:
						defaultCamZoom -= 0.3;
						FlxTween.tween(camHUD, {alpha: 0}, 1.5, {ease: FlxEase.sineInOut});
					case 143:
						FlxTween.tween(camHUD, {alpha: 1}, 0.8, {ease: FlxEase.sineOut});
					case 144 | 152:
						defaultCamZoom += 0.06;
					case 160:
						defaultCamZoom -= 0.12;
					case 172 | 248 | 268 | 396 | 412 | 512 | 540:
						defaultCamZoom += 0.2;
					case 176 | 256 | 500 | 516:
						defaultCamZoom -= 0.3;
					case 184:
						tweenCamera(1.35, 5, "sineInOut");
					case 208:
						defaultCamZoom = 0.75;
						cameraSpeed = 0.5;
					case 272:
						defaultCamZoom -= 0.2;
						cameraSpeed = 100; //lmao
						for (cams in [camHUD, camGame])
							cams.visible = false;
					case 280:
						for (cams in [camHUD, camGame])
							cams.visible = true;
						opponentCameraOffset[0] -= 100;
					case 282:
						cameraSpeed = 2.5;
					case 324:
						opponentCameraOffset[0] += 100;
						boyfriendCameraOffset[0] += 100;
						defaultCamZoom += 0.3;
					case 344:
						boyfriendCameraOffset[0] -= 100;
						defaultCamZoom -= 0.1;
					case 408:
						defaultCamZoom = 0.75;
						cameraSpeed = 4;
					case 411:
						manageLyrics("smile", "Keep it DOWN you runt!", 'disneyFreeplayFont.ttf', 30, 2.5, 'sineInOut', 0.08);
					case 416:
						defaultCamZoom -= 0.3;
						cameraSpeed = 1.65;
					case 448:
						tweenCamera(1.3, 10, "expoInOut");
						camFlashSystem(BG_DARK, {alpha: 0.9, timer: 12.5, ease: FlxEase.expoInOut});
					case 480:
						defaultCamZoom = 0.75;
						camFlashSystem(BG_DARK, {alpha: 0, timer: 1, ease: FlxEase.expoOut});
					case 496:
						defaultCamZoom += 0.3;
					case 548:
						defaultCamZoom -= 0.3;
						for (hud in [camHUD, camNotes])
							FlxTween.tween(hud, {alpha: 0}, 3, {ease: FlxEase.expoInOut});
					case 551:
						manageLyrics("smile", "You might've think you've won...", 'disneyFreeplayFont.ttf', 30, 4, 'sineInOut', 0.1);
					case 559:
						manageLyrics("smile", "...But in reality...", 'disneyFreeplayFont.ttf', 30, 4, 'sineInOut', 0.07);
					case 563:
						manageLyrics("smile", "..YOU LOST.", 'disneyFreeplayFont.ttf', 30, 3, 'sineInOut', 0.12);
					case 588:
						camBars.fade(FlxColor.BLACK, 5);
					
				}

			case "Bless":
				switch (curBeat)
				{
					case 1:
						cinematicBarControls("create", 1);
						for (i in [light, flair])
							i.alpha = 0.001;
						FlxTween.tween(camGame, {alpha: 1}, 2);
					case 7:
						for (hud in [camHUD, camNotes])
							FlxTween.tween(hud, {alpha: 1}, 3);
					case 16:
						FlxTween.tween(light, {alpha: .37}, 2, {ease: FlxEase.circOut});
						FlxTween.tween(flair, {alpha: .6}, 2, {ease: FlxEase.circOut});
					case 24 | 28 | 30 | 146 | 147 | 164 | 172 | 396 | 398 | 399 | 414 | 415 | 548 | 551 | 744 | 748:
						defaultCamZoom += 0.1;
					case 32 | 100 | 400:
						defaultCamZoom -= 0.3;
					case 48:
						canBopCam = true;
					case 80 | 116 | 384 | 464:
						canBopCam = false;
						FlxTween.tween(light, {alpha: 0}, .3, {ease: FlxEase.circOut});
						FlxTween.tween(flair, {alpha: 0}, .3, {ease: FlxEase.circOut});
						defaultCamZoom += 0.25;
						camFlashSystem(BG_DARK, {alpha: 1, timer: 0.5, ease: FlxEase.expoOut});
					case 84 | 118 | 386 | 465:
						FlxTween.tween(light, {alpha: .37}, .2, {ease: FlxEase.circOut});
						FlxTween.tween(flair, {alpha: .6}, .2, {ease: FlxEase.circOut});
						canBopCam = true;
						defaultCamZoom -= 0.25;
						camFlashSystem(BG_FLASH, {alpha: 1, timer: 1.5, ease: FlxEase.expoOut});
					case 99:
						defaultCamZoom += 0.3;
					case 148:
						defaultCamZoom -= 0.2;
						cinematicBarControls("moveboth", 2, "circOut", 90);
					case 180:
						defaultCamZoom -= 0.2;
					case 212:
						AppIcon.changeIcon("blessIcon");
						CppAPI.lightMode();
						for (blessableObjects in [dad, boyfriend, vault, chains, thingy, chains, chains2, chains3, iconP1, iconP2, healthBar, healthBarBG, fancyBarOverlay])
							blessableObjects.setColorTransform(-1, -1, -1, 1, 255, 255, 255, 0);
						for (textShit in [songTxt, watermarkTxt, scoreTxt])
						{
							textShit.color = FlxColor.BLACK;
							textShit.borderColor = FlxColor.WHITE;
						}
						light.visible = false;
						flair.visible = false;
						lightI.visible = true;
						flairI.visible = true;
						playfieldRenderer.isInvertColors = true;
						dad.blend = iconP2.blend = NORMAL;
						camBars.flash(FlxColor.BLACK, 2);
						cinematicBarControls("moveboth", 1.2, 'expoOut', 130);
						canBopCam = false;
					case 220 | 228 | 236 | 244 | 252 | 260 | 268 | 284 | 292 | 300 | 308 | 316 | 324 | 332 | 484 | 488 | 492 | 496 | 500 | 504 | 508 | 516 | 520 | 524 | 528 | 532 | 536 | 540:
						camFlashSystem(BG_FLASH, {alpha: 0.45, timer: 1});
					case 276:
						camFlashSystem(BG_FLASH, {alpha: 0.45, timer: 1});
						canBopCam = true;
					case 340:
						camGame.visible = false;
						for (i in [camHUD, camNotes])
							FlxTween.tween(i, {alpha: 0}, 1);
					case 348:
						light.visible = true;
						flair.visible = true;
						lightI.visible = false;
						flairI.visible = false;
						playfieldRenderer.isInvertColors = false;
						dad.blend = iconP2.blend = ADD;
						for (i in [camHUD, camNotes])
							FlxTween.tween(i, {alpha: 1}, 3);
						for (blessableObjects in [dad, boyfriend, vault, chains, thingy, chains, chains2, chains3, iconP1, iconP2, healthBar, healthBarBG, fancyBarOverlay])
							blessableObjects.setColorTransform(1, 1, 1, 1, 0, 0, 0, 0);
						for (textShit in [songTxt, watermarkTxt, scoreTxt])
						{
							textShit.color = FlxColor.WHITE;
							textShit.borderColor = FlxColor.BLACK;
						}
						AppIcon.changeIcon("newIcon");
						CppAPI.darkMode();
						var letsFight:VideoSprite = new VideoSprite(false);
						letsFight.load(Paths.video("blessCountdown"), [VideoSprite.muted]);
						letsFight.cameras = [camVideo];
						letsFight.addCallback("onEnd", () -> camVideo.visible = false);
						letsFight.play();
						add(letsFight);
					case 352:
						camGame.visible = true;
						defaultCamZoom = 0.9;
						camVideo.visible = false;
						camGame.zoom += 0.15;
						camFlashSystem(CAM_FLASH_FANCY, {alpha: 0.7, timer: 0.25});
						cinematicBarControls("moveboth", 1.2, "expoOut", 0);
					case 416:
						isCameraOnForcedPos = true;
						camFollow.x = 450;
						camFollow.y = 250;
						defaultCamZoom = 0.5;
					case 480:
						AppIcon.changeIcon("blessIcon");
						CppAPI.lightMode();
						defaultCamZoom = 0.95;
						camFollow.x = 0;
						camFollow.y = 0;
						isCameraOnForcedPos = false;
						for (blessableObjects in [dad, boyfriend, vault, chains, thingy, chains, chains2, chains3, iconP1, iconP2, healthBar, healthBarBG, fancyBarOverlay])
							blessableObjects.setColorTransform(-1, -1, -1, 1, 255, 255, 255, 0);
						for (textShit in [songTxt, watermarkTxt, scoreTxt])
						{
							textShit.color = FlxColor.BLACK;
							textShit.borderColor = FlxColor.WHITE;
						}
						light.visible = false;
						flair.visible = false;
						lightI.visible = true;
						flairI.visible = true;
						playfieldRenderer.isInvertColors = true;
						dad.blend = iconP2.blend = NORMAL;
						camBars.flash(FlxColor.BLACK, 2);
						cinematicBarControls("moveboth", 1.5, 'sineout', 130);
					case 544:
						canBopCam = false;
						AppIcon.changeIcon("newIcon");
						CppAPI.darkMode();
						cinematicBarControls("moveboth", 2.5, 'circOut', 0);
						for (blessableObjects in [dad, boyfriend, vault, chains, thingy, chains, chains2, chains3, iconP1, iconP2, healthBar, healthBarBG, fancyBarOverlay])
							FlxTween.tween(blessableObjects.colorTransform, {
								redOffset: 0,
								blueOffset: 0,
								greenOffset: 0,
								redMultiplier: 1,
								blueMultiplier: 1,
								greenMultiplier: 1
							}, 2, {ease: FlxEase.quartOut});
						for (textShit in [songTxt, watermarkTxt, scoreTxt])
						{
							textShit.color = FlxColor.WHITE;
							textShit.borderColor = FlxColor.BLACK;
							textShit.alpha = 0;
							FlxTween.tween(textShit, {alpha: 1}, 2, {ease: FlxEase.quartOut});
						}
					case 552:
						canBopCam = true;
						defaultCamZoom -= 0.2;
						camBars.flash(FlxColor.WHITE, 2);
						if (ClientPrefs.shaders)
						{
							// We make ur Laptop fry till the end of the song :fire: - MalyPlus
							camGame.setFilters([new ShaderFilter(othershader)]);
						}
					case 620:
						lightI.visible = false;
						thingy.visible = false;
						flairI.visible = false;
						canBopCam = false;
						playfieldRenderer.isInvertColors = false;
						dad.blend = iconP2.blend = ADD;
						camBars.flash(FlxColor.BLACK, 3);
						if (ClientPrefs.shaders)
						{
							camGame.setFilters([]);
						}
						camFlashSystem(BG_DARK, {alpha: 0.85, timer: 0.0001, ease: FlxEase.expoOut});
						cinematicBarControls("moveboth", 1.5, 'sineout', 60);
						cameraSpeed = 0.6;
					case 684:
						canBopCam = true;
					case 752:
						camBars.flash(FlxColor.WHITE, 2);
						for (cam in [camGame, camHUD, camNotes])
							cam.visible = false;
				}

			case 'Laugh Track':
				switch (curBeat)
				{
					case 7:
						cameraSpeed = 50;
						//camFollow.x += 100;
					case 8:
						camBars.fade(FlxColor.BLACK, 5, true);
						//FlxTween.tween(camFollow, {x: 0}, 3, {ease: FlxEase.circOut});
					case 32:
						defaultCamZoom = 1.5;
						//new FlxTimer().start(0.001, function(tmr) // what a load of crap lol
							//{
								//camFollow.x -= 100;
							//});
					//case 33: 
						//FlxTween.tween(camFollow, {x: 0}, 3, {ease: FlxEase.circInOut});
					case 56:
						tweenCamera(1, 1.5, 'circInOut');
						FlxTween.tween(camHUD, {alpha: 1}, 1.5, {ease: FlxEase.circInOut});
						FlxTween.tween(camNotes, {alpha: 1}, 1.5, {ease: FlxEase.circInOut});
						cameraSpeed = 2;
					case 64 | 67 | 72 | 75 | 80 | 83 | 88 | 91: 
						FlxG.camera.zoom += 0.015;
						camHUD.zoom += 0.03;
						camNotes.zoom += .03;
						//camFlashSystem(CAM_FLASH_FANCY, {alpha: 0.25, ease: FlxEase.sineOut, timer: 0.6});
					case 96:
						camFlashSystem(CAM_FLASH_FANCY, {alpha: 0.6, ease: FlxEase.sineOut, timer: 1});
						cameraSpeed = 2.3;
						defaultCamZoom = .78;
					case 152:
						defaultCamZoom = 1;
						opponentCameraOffset[0] -= 50;
						moveCamera(true);
					case 156:
						defaultCamZoom = 1.2;
						opponentCameraOffset[0] -= 50;
						moveCamera(true);
					case 160:
						defaultCamZoom = .78;
						opponentCameraOffset[0] += 100;
					case 184:
						defaultCamZoom = 1;
						boyfriendCameraOffset[0] += 50;
						moveCamera(false);
					case 188:
						defaultCamZoom = 1.2;
						boyfriendCameraOffset[0] += 50;
						moveCamera(false);
					case 192:
						defaultCamZoom = .78;
						boyfriendCameraOffset[0] -= 100;
						opponentCameraOffset[0] -= 70;
						isCameraOnForcedPos = true;
						FlxTween.tween(FlxG.camera, {zoom: 1.1}, 3.5, {startDelay: .9, ease: FlxEase.sineInOut, onComplete: a -> defaultCamZoom = 1.1});
						FlxTween.tween(camFollow, {x: camFollow.x - 750}, 3.5, {startDelay: .9, ease: FlxEase.sineInOut, onComplete: s -> isCameraOnForcedPos = false});
					case 256:
						boyfriendCameraOffset[0] += 100;
						opponentCameraOffset[0] += 70;
						moveCamera(true);
						// only time this actually works fine dear god
						camFlashSystem(CAM_FLASH_FANCY, {alpha: 0.6, ease: FlxEase.sineOut, timer: 1});
						defaultCamZoom = .78;
					case 384:
						triggerEventNote('Change Scroll Speed', '0.7', '2');
						cameraSpeed = 1;
					case 484:
						triggerEventNote('Change Scroll Speed', '1.1', '2');
						cameraSpeed = 1.8;
						defaultCamZoom = 1;
						boyfriendCameraOffset[0] += 50;
						moveCamera(false);
					case 488:
						boyfriendCameraOffset[0] -= 50;
						moveCamera(true);
						camFlashSystem(CAM_FLASH_FANCY, {alpha: 0.6, ease: FlxEase.sineOut, timer: 1});
						defaultCamZoom = .78;
						cameraSpeed = 2.3;
					case 616:
						defaultCamZoom = 1;
						boyfriendCameraOffset[0] += 30;
						moveCamera(false);
					case 618:
						defaultCamZoom = 1.2;
						boyfriendCameraOffset[0] += 30;
						opponentCameraOffset[0] += 60;
						cameraSpeed = 1.6;
						moveCamera(false);
					case 684:
						defaultCamZoom = 1.35;
						boyfriendCameraOffset[0] += 30;
						moveCamera(false);
				}

				if ((curBeat >= 96 && curBeat <= 128) || (curBeat >= 256 && curBeat <= 384) || (curBeat >= 488 && curBeat <= 616))
				{
					FlxG.camera.zoom += 0.015;
					camHUD.zoom += 0.03;
					camNotes.zoom += .03;
					//camFlashSystem(BG_FLASH, {alpha: 0.15, ease: FlxEase.sineOut, timer: 0.35, colors: [255, 0, 0]});
				}

				if (curBeat >= 192 && curBeat <= 256 && curBeat % 2 == 0)
				{
					FlxG.camera.zoom += curBeat >= 209 ? .015 : 0;
					camHUD.zoom += 0.03;
					camNotes.zoom += .03;
				}

			case 'Birthday':
				switch (curBeat)
				{
					case 2: camBars.fade(FlxColor.BLACK, 3, true);
					case 32: defaultCamZoom = 1.18;
					case 60:
						cameraSpeed = 0.5;
						defaultCamZoom = 0.85;
						FlxTween.tween(camHUD, {alpha: 1}, 3);
						FlxTween.tween(camNotes, {alpha: 1}, 3);
					case 64:
						camGame.flash(FlxColor.WHITE, 1);
						cameraSpeed = 1;
					case 128:
						defaultCamZoom = 0.73;
					case 192:
						camFlashSystem(BG_FLASH, {alpha: 0.7, timer: 1, colors: [66, 224, 245]});
						FlxG.camera.zoom += 0.09;
						camHUD.zoom += 0.08;
						camNotes.zoom += 0.08;
						defaultCamZoom = 1;
						cameraSpeed = 0.7;
					case 204 | 205 | 221 | 222 | 223 | 236 | 237 | 253 | 254 | 255: defaultCamZoom += 0.1;
					case 206 | 238: defaultCamZoom = 1;
					case 224:
						defaultCamZoom = 1;
						camFlashSystem(BG_FLASH, {alpha: 0.7, timer: 1, colors: [119, 247, 96]});
						FlxG.camera.zoom += 0.09;
						camHUD.zoom += 0.08;
						camNotes.zoom += 0.08;
					case 256: defaultCamZoom = 0.85;
					case 320: tweenCamera(1, 1.5, 'sineInOut');
					case 336:
						tweenCamera(1.3, 2.8, 'quartInOut');
						offsetTwn = FlxTween.tween(camFollow, {x: camFollow.x - 150}, 3, {ease: FlxEase.sineInOut, onComplete: function(twn:FlxTween)
						{
							offsetTwn = null;
						}});
					case 348:
						if (offsetTwn != null)
							offsetTwn.cancel();
						tweenCamera(0.75, 1.2, 'quartInOut');
						offsetTwn = FlxTween.tween(camFollow, {x: camFollow.x + 100}, 1.2, {ease: FlxEase.sineInOut, onComplete: function(twn:FlxTween)
							{
								offsetTwn = null;
							}});
					case 350: 
						dadGroup.scale.y = 0.6;
						dadGroup.scale.x = 0.6;
						FlxTween.tween(dadGroup, {'scale.x': 0}, 0.3, {ease: FlxEase.quartInOut});
					case 352:
						spawnNotes['muckney'] = true;
					case 416: 
						boyfriendGroup.scale.x = 0.9;
						boyfriendGroup.scale.y = 0.9;
						FlxTween.tween(boyfriendGroup, {'scale.y': 0}, 0.5, {ease: FlxEase.quartInOut, onComplete: function(twn:FlxTween)
						{
							boyfriendGroup.scale.x = 0.7;
							FlxTween.tween(boyfriendGroup, {'scale.y': 0.7}, 0.5, {ease: FlxEase.quartOut});
						}});
					case 418:
						spawnNotes['bf'] = true;
					case 476: tweenCamera(0.85, 2, 'quartInOut');
					case 477: FlxTween.tween(dadGroup, {'scale.x': 0}, 0.3, {ease: FlxEase.quartInOut, onComplete: function(twn:FlxTween)
						{
							dadGroup.scale.y = 0.6;
							FlxTween.tween(dadGroup, {'scale.x': 0.6}, 0.3, {ease: FlxEase.quartOut});
						}});
					case 479:
						spawnNotes['muckney'] = false;
					case 481: 
						FlxTween.tween(boyfriendGroup, {'scale.x': 0}, 0.7, {ease: FlxEase.quartInOut, onComplete: function(twn:FlxTween)
						{
							boyfriendGroup.scale.y = 0.9;
							FlxTween.tween(boyfriendGroup, {'scale.x': 0.9}, 0.7, {ease: FlxEase.quartOut});
						}});
						spawnNotes['bf'] = false;
					case 536 | 540 | 544: defaultCamZoom += 0.18;
					case 548: tweenCamera(0.8, 2, 'sineOut');
					case 552:
						camGame.visible = false;
						camHUD.visible = false;
						camNotes.visible = false;
						camOther.flash(FlxColor.WHITE, 3);
				}
				if ((curBeat >= 64 && curBeat <= 191) || (curBeat >= 256 && curBeat <= 319 && curBeat % 2 == 0))
				{
					FlxG.camera.zoom += 0.015;
					camHUD.zoom += 0.03;
					camNotes.zoom += 0.03;
				}

			case 'Mercy Legacy':
				if (ClientPrefs.mechanics)
				{
					if (curBeat >= 0 && curBeat <= 63)
						healthThing -= 0.02;
					else if (curBeat >= 64 && curBeat <= 95)
						healthThing -= 0.2;
					else if (curBeat >= 96 && curBeat <= 127)
						healthThing -= 0.06;
					else if (curBeat >= 128 && curBeat <= 191)
						healthThing -= 0.16;
					else if (curBeat >= 192 && curBeat <= 255)
						healthThing -= 0.1;
					else if (curBeat >= 256 && curBeat <= 319)
						healthThing -= 0.18;
					else if (curBeat >= 320)
						healthThing -= 0.01;
				}

			case 'Mercy':
				// Cam Stuff Handler
				switch (curBeat)
				{
					case 16:
						FlxTween.tween(camGame, {alpha: 1}, 5, {ease: FlxEase.sineInOut});
						FlxTween.tween(camHUD, {alpha: 1}, 5, {ease: FlxEase.sineInOut, startDelay: 1.5});
						defaultCamZoom = 1.3;

					case 32: defaultCamZoom = 1.2;
					case 40: defaultCamZoom = 1.1;
					case 48: defaultCamZoom = 1;
					case 56: defaultCamZoom = 0.9;
					case 64: defaultCamZoom = 0.75;

					case 128: tweenCamera(1.1, 9.7, 'quadInOut');

					// Very Spooky Phase 2 Walt (real)
					case 256:
						FlxTween.tween(camHUD, {alpha: 0}, 1, {ease: FlxEase.sineInOut});
						FlxTween.tween(camNotes, {alpha: 0}, 1, {ease: FlxEase.sineInOut});

					case 468:
						//FlxTween.tween(bfStrums, {alpha: 0}, 4, {ease: FlxEase.sineInOut});
						FlxTween.tween(camHUD, {alpha: 0}, 4, {ease: FlxEase.sineInOut});
						FlxTween.tween(camNotes, {alpha: 0}, 1, {ease: FlxEase.sineInOut, startDelay: 3});

					case 480:
						FlxTween.tween(dad, {alpha: 0}, 5);
						FlxTween.tween(waltGoop, {alpha: 1}, 5);

					// Final Stretch
					case 498:
						camGame.alpha = 0;
						camOther.flash(FlxColor.WHITE, 3);
				}

				if (ClientPrefs.mechanics && !disabledDrain)
				{
					// Health Drain Shit
					if (curBeat >= 0 && curBeat <= 63)
						healthThing -= 0.005;
					else if (curBeat >= 64 && curBeat <= 79)
						healthThing -= 0.025;
					else if (curBeat >= 80 && curBeat <= 87)
						healthThing -= 0.055;
					else if (curBeat >= 88 && curBeat <= 95)
						healthThing -= 0.015;
					else if (curBeat >= 96 && curBeat <= 127)
						healthThing -= 0.036;
					else if (curBeat >= 128 && curBeat <= 159)
						healthThing -= 0.14;
					else if (curBeat >= 160 && curBeat <= 191)
						healthThing -= 0.031;
					else if (curBeat >= 192 && curBeat <= 207)
						healthThing -= 0.015;
					else if (curBeat >= 208 && curBeat <= 239)
						healthThing -= 0.03;
					else if (curBeat >= 240 && curBeat <= 255)
						healthThing -= 0.005;
					else if (curBeat >= 256 && curBeat <= 291)
						healthThing -= 0.02;
					else if (curBeat >= 292 && curBeat <= 307)
						healthThing -= 0.03;
					else if (curBeat >= 308 && curBeat <= 339)
						healthThing -= 0.04;
					else if (curBeat >= 340 && curBeat <= 371)
						healthThing -= 0.055;
					else if (curBeat >= 372 && curBeat <= 387)
						healthThing -= 0.078;
					else if (curBeat >= 388 && curBeat <= 403)
						healthThing -= 0.09;
					else if (curBeat >= 404 && curBeat <= 451)
						healthThing -= 0.1;
					else if (curBeat >= 452 && curBeat <= 467)
						healthThing -= 0.115;
				}

			case 'Cycled Sins':
				if (ClientPrefs.mechanics)
				{
					switch (curBeat)
					{
						case 1:
							var warningTxt = new FlxText(0, 0, 1280, "Use the SPACEBAR to dodge\nwhen you see this warning\nappear on your screen.\nGood Luck.", 0);
							warningTxt.setFormat(Paths.font("randomNameToGetPlaceHolderFont.ttf"), 32, FlxColor.WHITE, CENTER);
							warningTxt.alpha = 0.001;
							warningTxt.screenCenter();
							warningTxt.x -= 200;
							warningTxt.cameras = [camOther];
							add(warningTxt);
							for (i in [warningTxt, dodgeWarning])
								FlxTween.tween(i, {alpha: 1}, 1.5, {onComplete: function(twn:FlxTween)
								{
									new FlxTimer().start(3.2, function(tmr:FlxTimer)
									{
										FlxTween.tween(i, {alpha: 0.001}, 1.5, {onComplete: function(twn:FlxTween)
										{
											dodgeWarning.visible = false;
											dodgeWarning.alpha = 1;
										}});
									});
								}});
						// Intro Cam Shit
						case 16: camBars.fade(0x000000, 0.0001, true);
						// because i dont know how to fucking use this goofy ass editor
						opponentStrums.forEach(s -> {s.scale.set(.95, .95); s.alpha = .5;});
						//case 32: tweenCamera(0.85, 5.5, 'quartInOut');
						case 46:
							//tweenCamera(0.6, 0.6, 'sineInOut');
							FlxTween.tween(camNotes, {alpha: 1}, 0.8, {ease: FlxEase.circInOut});
							FlxTween.tween(camHUD, {alpha: 1}, 0.8, {ease: FlxEase.circInOut});

						// Phase 1 Section
						case 174:
							relapseGimmick(0.7, 0.3);
						case 176:
							FlxTween.tween(iconP2, {alpha: 0}, 1, {ease: FlxEase.sineOut});
							FlxTween.tween(relapseIconLol, {alpha: 1}, 1, {ease: FlxEase.sineOut});
							camGame.fade(FlxColor.RED, 1, true);
						case 180 | 196 | 198 | 254 | 303:
							relapseGimmick(0.35, 0.15);
						case 188 | 204:
							relapseGimmick(1.4, 0.6);
						case 206:
							relapseGimmick(0.7, 0.54);
						case 214:
							relapseGimmick(0.7, 0.8);
						case 228 | 244:
							relapseGimmick(0.7, 1);
						case 248 | 262 | 276:
							relapseGimmick(1.4, 1.2);
						case 270 | 294:
							relapseGimmick(0.7, 1.5);

						// Cam Shit and Lyrics for intro to Phase 2
						case 366:
							FlxTween.tween(camNotes, {alpha: 0}, 1);
							FlxTween.tween(camHUD, {alpha: 0}, 1);

						case 381: manageLyrics('relapse2NEW-pixel', 'You REALLY think this is...', 'freeplayDisneyFont.ttf', 30, 1.1, 'sineInOut');
						case 384: manageLyrics('relapse2NEW-pixel', '...some kind of...', 'freeplayDisneyFont.ttf', 30, 1.4, 'sineInOut');
						case 388: manageLyrics('relapse2NEW-pixel', '...silly little GAME?', 'freeplayDisneyFont.ttf', 30, 1.15, 'sineInOut');
						case 394: manageLyrics('relapse2NEW-pixel', 'Soon enough...', 'freeplayDisneyFont.ttf', 30, 1.3, 'sineInOut');
						case 398: manageLyrics('relapse2NEW-pixel', "...you'll understand what ME...", 'freeplayDisneyFont.ttf', 30, 1.5, 'sineInOut');
						case 404: manageLyrics('relapse2NEW-pixel', '...AND MY FRIENDS...', 'freeplayDisneyFont.ttf', 30, 1.6, 'sineInOut');
						case 408: manageLyrics('relapse2NEW-pixel', '...HAVE TO GO THROUGH!', 'freeplayDisneyFont.ttf', 30, 1.1, 'sineInOut');
						case 413: manageLyrics('relapse2NEW-pixel', 'Sooner or later...', 'freeplayDisneyFont.ttf', 30, 1.1, 'sineInOut');
						case 417: manageLyrics('relapse2NEW-pixel', '...your DEATH will be nothing...', 'freeplayDisneyFont.ttf', 30, 1.1, 'sineInOut');
						case 421: manageLyrics('relapse2NEW-pixel', '...BUT CYCLED SINS!', 'freeplayDisneyFont.ttf', 30, 1.1, 'sineInOut');

						case 429:
							camGame.visible = false;
						case 432:
							camGame.visible = true;
							FlxTween.tween(camNotes, {alpha: 1}, 0.5, {ease: FlxEase.sineOut});
							FlxTween.tween(camHUD, {alpha: 1}, 0.5, {ease: FlxEase.sineOut});

						// Phase 2 Section
						case 438 | 540:
							relapseGimmick(0.35, 1, true);
						case 453 | 524:
							relapseGimmick(0.7, 1, true);
						case 460 | 498:
							relapseGimmick(0.7, 0.9);
						case 471:
							relapseGimmick(0.35, 1.1);
						case 484 | 503:
							relapseGimmick(0.35, 1.3);
						case 494 | 508:
							relapseGimmick(0.35, 1.3, true);

						case 560: manageLyrics('relapse2NEW-pixel', 'Why doesn\'t my torturous ways travail...', 'freeplayDisneyFont.ttf', 30, 5, 'sineInOut');
						case 576: manageLyrics('relapse2NEW-pixel', 'I\'m mental, indisposed and ill...', 'freeplayDisneyFont.ttf', 30, 5, 'sineInOut');
						case 592: manageLyrics('relapse2NEW-pixel', 'I\'m deranged, full of hatred...', 'freeplayDisneyFont.ttf', 30, 5, 'sineInOut');
						case 608: manageLyrics('relapse2NEW-pixel', 'This should\'ve been your termination... isn\'t it?', 'freeplayDisneyFont.ttf', 30, 5, 'sineInOut');

						case 632:
							sinsEnd = true;
					}
				}
				else
				{
					switch (curBeat)
					{
						case 1:
							var warningTxt = new FlxText(0, 0, 1280, "Use the SPACEBAR to dodge\nwhen you see this warning\nappear on your screen.\nGood Luck.", 0);
							warningTxt.setFormat(Paths.font("randomNameToGetPlaceHolderFont.ttf"), 32, FlxColor.WHITE, CENTER);
							warningTxt.alpha = 0.001;
							warningTxt.screenCenter();
							warningTxt.cameras = [camOther];
							add(warningTxt);
							for (i in [warningTxt, dodgeWarning])
								FlxTween.tween(i, {alpha: 1}, 1.5, {onComplete: function(twn:FlxTween)
								{
									new FlxTimer().start(3.2, function(tmr:FlxTimer)
									{
										FlxTween.tween(i, {alpha: 0.001}, 1.5);
									});
								}});
						// Intro Cam Shit
						case 16: camBars.fade(0x000000, 0.0001, true);
						//case 32: tweenCamera(0.85, 5.5, 'quartInOut');
						case 46:
							//tweenCamera(0.6, 0.6, 'sineInOut');
							FlxTween.tween(camNotes, {alpha: 1}, 0.8, {ease: FlxEase.circInOut});
							FlxTween.tween(camHUD, {alpha: 1}, 0.8, {ease: FlxEase.circInOut});
						case 366:
							FlxTween.tween(camNotes, {alpha: 0}, 1);
							FlxTween.tween(camHUD, {alpha: 0}, 1);

						case 381: manageLyrics('relapse2NEW-pixel', 'You REALLY think this is...', 'freeplayDisneyFont.ttf', 30, 1.1, 'sineInOut');
						case 384: manageLyrics('relapse2NEW-pixel', '...some kind of...', 'freeplayDisneyFont.ttf', 30, 1.4, 'sineInOut');
						case 388: manageLyrics('relapse2NEW-pixel', '...silly little GAME?', 'freeplayDisneyFont.ttf', 30, 1.15, 'sineInOut');
						case 394: manageLyrics('relapse2NEW-pixel', 'Soon enough...', 'freeplayDisneyFont.ttf', 30, 1.3, 'sineInOut');
						case 398: manageLyrics('relapse2NEW-pixel', "...you'll understand what ME...", 'freeplayDisneyFont.ttf', 30, 1.5, 'sineInOut');
						case 404: manageLyrics('relapse2NEW-pixel', '...AND MY FRIENDS...', 'freeplayDisneyFont.ttf', 30, 1.6, 'sineInOut');
						case 408: manageLyrics('relapse2NEW-pixel', '...HAVE TO GO THROUGH!', 'freeplayDisneyFont.ttf', 30, 1.1, 'sineInOut');
						case 413: manageLyrics('relapse2NEW-pixel', 'Sooner or later...', 'freeplayDisneyFont.ttf', 30, 1.1, 'sineInOut');
						case 417: manageLyrics('relapse2NEW-pixel', '...your DEATH will be nothing...', 'freeplayDisneyFont.ttf', 30, 1.1, 'sineInOut');
						case 421: manageLyrics('relapse2NEW-pixel', '...BUT CYCLED SINS!', 'freeplayDisneyFont.ttf', 30, 1.1, 'sineInOut');

						case 429:
							camGame.visible = false;
						case 432:
							camGame.visible = true;
							FlxTween.tween(camNotes, {alpha: 1}, 0.5, {ease: FlxEase.sineOut});
							FlxTween.tween(camHUD, {alpha: 1}, 0.5, {ease: FlxEase.sineOut});

						case 560: manageLyrics('relapse2NEW-pixel', 'Why doesn\'t my torturous ways travail...', 'freeplayDisneyFont.ttf', 30, 5, 'sineInOut');
						case 576: manageLyrics('relapse2NEW-pixel', 'I\'m mental, indisposed and ill...', 'freeplayDisneyFont.ttf', 30, 5, 'sineInOut');
						case 592: manageLyrics('relapse2NEW-pixel', 'I\'m deranged, full of hatred...', 'freeplayDisneyFont.ttf', 30, 5, 'sineInOut');
						case 608: manageLyrics('relapse2NEW-pixel', 'This should\'ve been your termination... isn\'t it?', 'freeplayDisneyFont.ttf', 30, 5, 'sineInOut');

						case 632:
							sinsEnd = true;
					}
				}

				if (curBeat == 400 || curBeat == 404 || curBeat == 408 || curBeat == 412 || curBeat == 416 || curBeat == 420 || curBeat == 424
					|| curBeat == 428)
				{
					camFlashSystem(BG_FLASH, {alpha: 0.32, timer: 1.2, colors: [255, 0, 0]});
					FlxG.camera.zoom += 0.1;
				}

			case 'Malfunction Legacy':
				switch (curBeat)
				{
					case 136 | 140:
						for (cam in [camGame, camHUD, camNotes])
							cam.visible = !cam.visible;
						if (camGame.visible)
						{
							camFlashSystem(CAM_FLASH_FANCY, {alpha: 0.85, timer: 1.2, colors: [255, 255, 255]});
							FlxG.camera.zoom += 0.1;
						}
					case 206:
						camFlashSystem(CAM_FLASH_FANCY, {alpha: 0.85, timer: 1.2, colors: [255, 0, 0]});
					case 398:
						camFlashSystem(CAM_FLASH_FANCY, {alpha: 0.85, timer: 1.2, colors: [255, 255, 255]});
						for (cam in [camHUD, camNotes])
							FlxTween.tween(cam, {alpha: 0}, 1);
						FlxG.camera.zoom += 0.1;
				}
				
			case 'Malfunction':
				switch (curBeat)
				{
					// Intro Cam Stuff
					case 1:
						camBars.fade(FlxColor.BLACK, 5, true);
					case 16: tweenCamera(1.2, 5, 'quartInOut');
					case 32:
						defaultCamZoom = 0.8;
						FlxTween.tween(camHUD, {alpha: 1}, 0.5, {ease: FlxEase.sineOut});
						FlxTween.tween(camNotes, {alpha: 1}, 0.5, {ease: FlxEase.sineOut});
					case 39 | 48 | 64 | 72 | 88 | 96 | 103 | 113 | 128 | 192: defaultCamZoom = 0.8;
					case 38 | 102: tweenCamera(1.5, 0.25, 'sineInOut');
					case 45 | 61 | 110 | 126 | 187: defaultCamZoom = 0.9;
					case 46 | 62 | 67 | 76 | 83 | 92 | 111 | 127 | 158 | 190: defaultCamZoom = 1;
					case 47 | 63 | 68 | 84 | 112 | 159: defaultCamZoom = 1.3;
					case 69 | 85: defaultCamZoom = 1.1;
					case 160: 
						defaultCamZoom = 0.75;
						whiteBG.alpha = 1;
						FlxTween.tween(whiteBG, {alpha: 0}, 2);
						camFlashSystem(BG_DARK, {alpha: 1, timer: 5, ease: FlxEase.expoInOut});
					case 164: tweenCamera(1.5, 6, 'sineInOut');
					case 184:
						defaultCamZoom = 0.8;
						camFlashSystem(BG_DARK, {alpha: 0, timer: 1, ease: FlxEase.sineOut});
					case 191:
						if (canaddshaders)
						{
							if (!ClientPrefs.lowQuality && ClientPrefs.epilepsy)
							{
								camGame.setFilters(
									[
										new ShaderFilter(chromZoomShader), 
										new ShaderFilter(blurShader)
									]);
								camHUD.setFilters([new ShaderFilter(chromNormalShader), new ShaderFilter(blurShader)]);
								camNotes.setFilters([new ShaderFilter(chromNormalShader), new ShaderFilter(blurShader)]);
							}
						}
					case 252:
						defaultCamZoom += 0.15;
					case 256:
						defaultCamZoom -= 0.15;
                    case 320:
                        FlxTween.tween(camHUD, {alpha: 0}, 0.5);
                        FlxTween.tween(camNotes, {alpha: 0}, 0.5);
					case 324:
						var count:FlxSprite = new FlxSprite().loadGraphic(Paths.image('UI/funkinAVI/intro/mal-prepare'));
						count.scrollFactor.set();
						count.updateHitbox();
						count.setGraphicSize(Std.int(count.width * daPixelZoom));
						count.antialiasing = false;
						count.screenCenter();
						add(count);
						FlxTween.tween(count, {y: count.y += 50, alpha: 0}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								count.destroy();
							}
						});
						FlxG.sound.play(Paths.sound('intro3-glitch'), 2);
					case 325:
						var count:FlxSprite = new FlxSprite().loadGraphic(Paths.image('UI/funkinAVI/intro/mal-ready'));
						count.scrollFactor.set();
						count.updateHitbox();
						count.setGraphicSize(Std.int(count.width * daPixelZoom));
						count.screenCenter();
						count.antialiasing = false;
						add(count);
						FlxTween.tween(count, {y: count.y += 50, alpha: 0}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								count.destroy();
							}
						});
						FlxG.sound.play(Paths.sound('intro2-glitch'), 2);
					case 326:
						var count:FlxSprite = new FlxSprite().loadGraphic(Paths.image('UI/funkinAVI/intro/mal-set'));
						count.scrollFactor.set();
						count.updateHitbox();
						count.setGraphicSize(Std.int(count.width * daPixelZoom));
						count.screenCenter();
						count.antialiasing = false;
						add(count);
						FlxTween.tween(count, {y: count.y += 50, alpha: 0}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								count.destroy();
							}
						});
						FlxG.sound.play(Paths.sound('intro1-glitch'), 2);
					case 327:
						var count:FlxSprite = new FlxSprite().loadGraphic(Paths.image('UI/funkinAVI/intro/mal-go'));
						count.scrollFactor.set();
						count.updateHitbox();
						count.setGraphicSize(Std.int(count.width * daPixelZoom));
						count.screenCenter();
						count.antialiasing = false;
						add(count);
						FlxTween.tween(count, {y: count.y += 50, alpha: 0}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								count.destroy();
							}
						});
						FlxG.sound.play(Paths.sound('introGo-glitch'), 2);
                    case 328:
                        FlxTween.tween(camHUD, {alpha: 1}, 0.5);
                        FlxTween.tween(camNotes, {alpha: 1}, 0.5);
					case 360:
						camFlashSystem(BG_DARK, {alpha: 0.3, timer: 0.25, ease: FlxEase.sineOut});
						opponentCameraOffset[0] -= 90;
						defaultCamZoom += 0.05;
					case 362:
						camFlashSystem(BG_DARK, {alpha: 0.6, timer: 0.25, ease: FlxEase.sineOut});
						opponentCameraOffset[0] -= 105;
						defaultCamZoom += 0.1;
					case 364:
						camFlashSystem(BG_DARK, {alpha: 0, timer: 0.5, ease: FlxEase.sineOut});
						opponentCameraOffset[0] += 195;
						defaultCamZoom -= 0.15;
						camFlashSystem(CAM_FLASH_FANCY, {alpha: 0.85, timer: 1.5, ease: FlxEase.quartOut, colors: [255, 0, 0]});
					case 378:
						boyfriendCameraOffset[0] += 80;
						defaultCamZoom += 0.1;
					case 380:
						defaultCamZoom += 0.1;
					case 384:
						boyfriendCameraOffset[0] -= 80;
						defaultCamZoom -= 0.2;
						camFlashSystem(BG_FLASH, {alpha: 0.85, timer: 1.5, ease: FlxEase.quartOut, colors: [66, 215, 245]});
					case 390 | 391:
						FlxG.camera.zoom += 0.1;
					case 392:
						camFlashSystem(BG_DARK, {alpha: 0.75, timer: 0.35, ease: FlxEase.sineOut});
						opponentCameraOffset[0] -= 200;
						defaultCamZoom += 0.15;
					case 394:
						camFlashSystem(BG_FLASH, {alpha: 0.85, timer: 1.5, ease: FlxEase.quartOut, colors: [255, 0, 0]});
						opponentCameraOffset[0] += 200;
						defaultCamZoom -= 0.15;
					case 396 | 397 | 398 | 399 | 404 | 405 | 406 | 407 | 412 | 413 | 414 | 415 | 420 | 421 | 422 | 444 | 445 | 446 | 447 | 452 | 453 | 454 | 455:
						camFlashSystem(BG_FLASH, {alpha: 0.15, timer: 0.3, ease: FlxEase.quartOut, colors: [255, 0, 0]});
						FlxG.camera.zoom += 0.1;
					case 456:
						camFlashSystem(BG_DARK, {alpha: 0.75, timer: 5, ease: FlxEase.sineInOut});
						tweenCamera(1.35, 7, "sineInOut");
						opponentCameraOffset[0] -= 25;
					case 460 | 464 | 468 | 472 | 476 | 480 | 484:
						opponentCameraOffset[0] -= 25;
					case 488:
						camFlashSystem(BG_FLASH, {alpha: 0.85, timer: 2, ease: FlxEase.sineOut, colors: [255, 255, 255]});
						defaultCamZoom = 0.9;
						opponentCameraOffset[0] += 200;
					case 504:
						FlxTween.tween(camFollow, {x: camFollow.x + 150}, 5, {ease: FlxEase.sineInOut});
					case 520 | 524 | 528 | 532 | 536 | 540 | 544 | 548:
						FlxG.camera.zoom += 0.16;
						camFlashSystem(CAM_FLASH_FANCY, {alpha: 0.7, timer: 1, ease: FlxEase.expoOut, colors: [FlxG.random.int(0, 255), FlxG.random.int(0, 255), FlxG.random.int(0, 255)]});
					case 552:
						canBopCam = true;
					case 584:
						canBopCam = false;
						FlxG.camera.zoom += 0.23;
						for (hud in [camHUD, camNotes])
							FlxTween.tween(hud, {alpha: 0}, 4.45, {ease: FlxEase.quartInOut});
					case 616:
						camGame.visible = false;
				}

			/*case 'Neglection':
				switch (curBeat)
				{
					case 256:
						FlxTween.tween(camHUD, {alpha: 0}, 0.5);
                    	FlxTween.tween(camNotes, {alpha: 0}, 0.5);
					case 257:
						FlxTween.tween(boyfriend, {alpha: 0.0001}, 0.5);
						camBars.fade(FlxColor.BLACK, 0.3);
					case 260:
						camBars.fade(FlxColor.BLACK, 1, true);
					case 264:
						FlxTween.tween(camHUD, {alpha: 1}, 0.5);
                        FlxTween.tween(camNotes, {alpha: 1}, 0.5);
					case 328: camGame.visible = false;
					case 332: 
						camGame.visible = true;
						boyfriend.alpha = 1;
				}*/

			case 'Hunted':
				if (curBeat == 176) {
					tweenCamera(1.1, 4.1, 'sineInOut');
					//dadStrums.forEach(strum -> FlxTween.tween(strum, {y: strum.y + 700}, 2.5, {ease: FlxEase.elasticIn}));
					//FlxTween.tween(camNotes[0], {alpha: 0.0001}, 2.5);
					//if (!Init.trueSettings.get('Centered Notefield')) bfStrums.forEach(strum -> FlxTween.tween(strum, {x: strum.x - 320}, 2.5, {ease: FlxEase.elasticInOut}));
				}
				if (curBeat == 184)
					defaultCamZoom = 1.4;
				if (curBeat == 190)
					defaultCamZoom = 0.65;
				if (curBeat == 192)
				{
					//camHudMoves = true;
					if (ClientPrefs.flashing)
						camGame.flash(FlxColor.WHITE, 1.5);
					if (ClientPrefs.shaders)
						if (!ClientPrefs.lowQuality)
						{
							camGame.setFilters([
								new ShaderFilter(redVignette),
								new ShaderFilter(dramaticCamMovement),
								new ShaderFilter(monitorFilter),
							]);
						}
						else
						{
							camGame.setFilters([new ShaderFilter(redVignette), new ShaderFilter(monitorFilter)]);
						}
				}
				if (curBeat == 256)
				{
					//camHudMoves = false;
					camBars.flash(FlxColor.BLACK, 2);
					if (!ClientPrefs.lowQuality)
					{
						camGame.setFilters([
							new ShaderFilter(dramaticCamMovement),
							new ShaderFilter(monitorFilter),
						]);
					}
					else
					{
						camGame.setFilters([new ShaderFilter(monitorFilter)]);
					}

					//dadStrums.forEach(strum -> FlxTween.tween(strum, {y: strum.y - 700}, 2.5, {ease: FlxEase.elasticOut}));
					//FlxTween.tween(camNotes[0], {alpha: 1}, 2.5);
					//if (!Init.trueSettings.get('Centered Notefield')) bfStrums.forEach(strum -> FlxTween.tween(strum, {x: strum.x + 320}, 2.5, {ease: FlxEase.elasticInOut}));

					//uhhTurnBackNormalOrSmth();
				}

				if (((curBeat >= 64 && curBeat < 128) && curBeat % 2 == 0) || (curBeat >= 128 && curBeat < 256))
				{
					FlxG.camera.zoom += ((curBeat > 176 && curBeat < 184) ? 0 : .05);
					camHUD.zoom += .04;
					camNotes.zoom += .04;
				}
		}

		if(lastBeatHit >= curBeat) {
			//trace('BEAT HIT: ' + curBeat + ', LAST HIT: ' + lastBeatHit);
			return;
		}

		if (generatedMusic)
		{
			notes.sort(FlxSort.byY, ClientPrefs.downScroll ? FlxSort.ASCENDING : FlxSort.DESCENDING);
		}

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

		if (SONG.song == "Isolated")
		{
			lunacyIcon.scale.set(1.2, 1.2);
			lunacyIcon.updateHitbox();

			isolatedHappy.scale.set(1.2, 1.2);
			isolatedHappy.updateHitbox();

			demonBFIcon.scale.set(1.2, 1.2);
			demonBFIcon.updateHitbox();

			fakeBFLosingFrame.scale.set(1.2, 1.2);
			fakeBFLosingFrame.updateHitbox();
		}

		if (SONG.song == "Devilish Deal")
		{
			minnieIcon.scale.set(1.2, 1.2);
			minnieIcon.updateHitbox();

			satanIconPulse.scale.set(1.35, 1.35);
			satanIconPulse.updateHitbox();
		}

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		if (gf != null && curBeat % Math.round(gfSpeed * gf.danceEveryNumBeats) == 0 && gf.animation.curAnim != null && !gf.animation.curAnim.name.startsWith("sing") && !gf.stunned)
		{
			gf.dance();
		}
		if (curBeat % boyfriend.danceEveryNumBeats == 0 && boyfriend.animation.curAnim != null && !boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.stunned)
		{
			boyfriend.dance();
		}
		if (curBeat % dad.danceEveryNumBeats == 0 && dad.animation.curAnim != null && !dad.animation.curAnim.name.startsWith('sing') && !dad.stunned)
		{
			dad.dance();
		}

		switch (curStage)
		{
			case 'abandonedStreet':
				switch (SONG.song)
					{
						case 'Lunacy':
							if (!lowQuality)
								{
									if (curBeat == 228 || curBeat == 238 || curBeat == 244 || curBeat == 252 || curBeat == 260 || curBeat == 270 || curBeat == 276 || curBeat == 284 || curBeat == 292 || curBeat == 300 || curBeat == 308 || curBeat == 316 || curBeat == 324 || curBeat == 332 || curBeat == 340 || curBeat == 248)
									{
										if (fireTweenHandler != null)
											fireTweenHandler.cancel();
										if (rainTween != null)
											rainTween.cancel();
						
										if (rain != null)
											rainTween = FlxTween.tween(rain, {alpha: 0.5}, 0.35, {ease: FlxEase.sineOut, onComplete: function(twn:FlxTween)
											{
												rainTween = null;
											}});

										fireTweenHandler = FlxTween.tween(fireThing, {alpha: 0.75, y: -250}, 0.35, {ease: FlxEase.sineOut, onComplete: function(twn:FlxTween)
											{
												fireTweenHandler = null;
											}
										});
									}
									if (curBeat == 230 || curBeat == 240 || curBeat == 248 || curBeat == 256 || curBeat == 262 || curBeat == 272 || curBeat == 280 || curBeat == 288 || curBeat == 296 || curBeat == 304 || curBeat == 312 || curBeat == 320 || curBeat == 328 || curBeat == 336 || curBeat == 344 || curBeat == 352)
									{
										if (fireTweenHandler != null)
											fireTweenHandler.cancel();
										if (rainTween != null)
											rainTween.cancel();
						
										fireTweenHandler = FlxTween.tween(fireThing, {alpha: 0.0001, y: -80}, 0.35, {ease: FlxEase.sineOut, onComplete: function(twn:FlxTween)
											{
												fireTweenHandler = null;
											}
										});

										if (rain != null)
											rainTween = FlxTween.tween(rain, {alpha: 0.0001}, 0.35, {ease: FlxEase.sineOut, onComplete: function(twn:FlxTween)
												{
													rainTween = null;
												}});
									}
									if (curBeat == 416)
									{
										if (fireTweenHandler != null)
											fireTweenHandler.cancel();
						
										fireTweenHandler = FlxTween.tween(fireThing, {alpha: 1, y: -350}, 19.5, {ease: FlxEase.sineInOut, onComplete: function(twn:FlxTween)
											{
												fireTweenHandler = null;
											}
										});
									}
									if (curBeat == 480)
									{
										if (rain != null) rain.alpha = 1;
										fireThing.alpha = 0.35;
										fireThing.y = -120;
									}
									if (curBeat == 536)
									{
										fireTweenHandler = FlxTween.tween(fireThing, {alpha: 0, y: 0}, 1, {ease: FlxEase.sineOut, onComplete: function(twn:FlxTween)
											{
												fireTweenHandler = null;
											}
										});
									}
								}
						case 'Delusional':
							if (curBeat == 1)
							{
								if (rain != null) rain.alpha = 1;
							}
							if (curBeat == 64)
								{
									FlxTween.tween(fakeLightOfHope, {alpha: 0.001}, 1.7);
									if (!lowQuality) FlxTween.tween(stageFront, {alpha: 1}, 1.5);
								}
								if (curBeat == 176)
								{
									if (rain != null) 
									{
										rain.kill();
										rain.destroy();
										rain = null;
									}
									if (heavyRain != null && !lowQuality)
										heavyRain.alpha = 0.34;
								}
								if (curBeat == 280)
								{
									if (!lowQuality)
									{
										smokeShit.forEach(function(spr:FlxSprite)
										{
											FlxTween.tween(spr, {alpha: 0.55}, 1.5);
										});
										smokeFore.forEach(function(spr:FlxSprite)
											{
												FlxTween.tween(spr, {alpha: 0.55}, 1.5);
										});
									}
								}
								if (curBeat == 312 && !lowQuality)
								{
									FlxTween.tween(fireThing, {alpha: 1}, 1);
									//smokeParticles.emitting = true;
								} 
								if (curBeat == 336)
								{
									if (!lowQuality)
									{
										smokeShit.forEach(function(spr:FlxSprite)
										{
											FlxTween.tween(spr, {alpha: 0.25}, 1.5);
										});
										smokeFore.forEach(function(spr:FlxSprite)
										{
												FlxTween.tween(spr, {alpha: 0.25}, 1.5);
										});
									}
								}
								if (curBeat == 474) // load daytime street assets
								{
									colorsOrSmthElse.kill();
									colorsOrSmthElse.destroy();
									colorsOrSmthElse = null;
									//smokeParticles.emitting = false;
									floor.kill();
									floor.destroy();
									floor = null;
									if (!lowQuality)
									{
										fireThing.kill();
										fireThing.destroy();
										fireThing = null;
										smokeShit.forEach(function(spr:FlxSprite)
											{
												spr.alpha = 0;
											});
											smokeFore.forEach(function(spr:FlxSprite)
											{
												spr.alpha = 0;
											});
										heavyRain.visible = false;
										totallyanoriginalname.visible = true;
										stageCurtains.visible = false;
										stageFront.kill();
										stageFront.destroy();
										stageFront = null;
									}
									minnieBackground.visible = true;
								}

								if (curBeat == 679 && !lowQuality)
								{
									stageCurtains.alpha = 0.0001;
									stageCurtains.visible = true;
								}

								if (curBeat == 680 || curBeat == 688 || curBeat == 696 || curBeat == 700 || curBeat == 704 || curBeat == 712 || curBeat == 720)
								{
									if (!lowQuality)
									{
										stageCurtains.alpha = 1;
										FlxTween.tween(stageCurtains, {alpha: 0}, 1, {ease: FlxEase.circOut});
									}
								}

								if (curBeat == 728 && !lowQuality)
									FlxTween.tween(stageCurtains, {alpha: 1}, 5);

								if (curBeat == 740) // go back to the street in a even more decayed state
								{
									//smokeParticles.emitting = true;
									//fireParticles.emitting = true;
									if (!lowQuality)
									{
										smokeShit.forEach(function(spr:FlxSprite)
											{
												spr.alpha = 0.7;
											});
											smokeFore.forEach(function(spr:FlxSprite)
											{
												spr.alpha = 0.74;
											});
										heavyRain.visible = true;
										totallyanoriginalname.kill();
										totallyanoriginalname.destroy();
										totallyanoriginalname = null;
									}
									streetRuins.visible = true;
									fakeLightOfHope.alpha = 0.5;
									minnieBackground.kill();
									minnieBackground.destroy();
									minnieBackground = null;
								}
								if (curBeat == 744 || curBeat == 752 || curBeat == 760 || curBeat == 768 || curBeat == 772 || curBeat == 776 || curBeat == 784 || curBeat == 792 || curBeat == 800 || curBeat == 804 ||
									curBeat == 808 || curBeat == 816 || curBeat == 824 || curBeat == 832 || curBeat == 836 || curBeat == 840 || curBeat == 848 || curBeat == 856 || curBeat == 864 || curBeat == 868 ||
									curBeat == 880 || curBeat == 884 || curBeat == 888 || curBeat == 892 || curBeat == 896 || curBeat == 900 || curBeat == 904 || curBeat == 908 || curBeat == 913 || curBeat == 916 ||
									curBeat == 920 || curBeat == 924 || curBeat == 929 || curBeat == 933 || curBeat == 936 || curBeat == 940 || curBeat == 944 || curBeat == 948 || curBeat == 952 || curBeat == 956 ||
									curBeat == 960 || curBeat == 964 || curBeat == 968 || curBeat == 972 || curBeat == 976 || curBeat == 980 || curBeat == 984 || curBeat == 988 || curBeat == 993 || curBeat == 997 ||
									curBeat == 1000 || curBeat == 1004)
								{
									fakeLightOfHope.alpha = 1;
									FlxTween.tween(fakeLightOfHope, {alpha: 0.5}, 0.85);
								}
								if (curBeat == 872)
								{
									FlxTween.tween(fakeLightOfHope, {alpha: 1, color: FlxColor.RED}, 2, {ease: FlxEase.circInOut});
									if (!lowQuality) FlxTween.tween(fireThing2, {color: FlxColor.RED}, 2, {ease: FlxEase.circInOut});
									FlxTween.tween(streetRuins, {color: FlxColor.RED}, 2, {ease: FlxEase.circInOut});
									if (!lowQuality)
									{
										FlxTween.tween(fireForeground, {color: FlxColor.RED}, 2, {ease: FlxEase.circInOut});
										FlxTween.tween(heavyRain, {color: FlxColor.RED}, 2, {ease: FlxEase.circInOut});
										smokeShit.forEach(function(spr:FlxSprite)
										{
											FlxTween.tween(spr, {color: FlxColor.RED}, 2, {ease: FlxEase.circInOut});
										});
										smokeFore.forEach(function(spr:FlxSprite)
										{
											FlxTween.tween(spr, {color: FlxColor.RED}, 2, {ease: FlxEase.circInOut});
										});
									}
								}
								if (curBeat == 880)
								{
									FlxTween.tween(fakeLightOfHope, {color: FlxColor.WHITE}, 0.5, {ease: FlxEase.circOut});
									if (!lowQuality) FlxTween.tween(fireThing2, {color: FlxColor.WHITE, alpha: 0.75}, 1.2, {ease: FlxEase.circOut});
									FlxTween.tween(streetRuins, {color: FlxColor.WHITE}, 0.5, {ease: FlxEase.circOut});
									if (!lowQuality)
									{
										lightningStrike();
										lightningStrikeFore();
										FlxTween.tween(fireForeground, {color: FlxColor.WHITE, alpha: 0.6}, 2, {ease: FlxEase.circOut});
										FlxTween.tween(heavyRain, {color: FlxColor.fromRGB(252, 141, 141)}, 0.5, {ease: FlxEase.circOut});
										smokeShit.forEach(function(spr:FlxSprite)
										{
											FlxTween.tween(spr, {color: FlxColor.WHITE}, 0.5, {ease: FlxEase.circOut});
										});
										smokeFore.forEach(function(spr:FlxSprite)
										{
											FlxTween.tween(spr, {color: FlxColor.WHITE}, 0.5, {ease: FlxEase.circOut});
										});
									}
								}
								if (curBeat == 1008)
								{
									FlxTween.tween(fakeLightOfHope, {alpha: 0}, 2);
									if (!lowQuality) FlxTween.tween(fireThing2, {alpha: 1}, 2);
								}
								if (curBeat == 1087)
								{
									if (!lowQuality)
										{
											fireForeground.kill();
											fireForeground.destroy();
											fireForeground = null;
											smokeShit.forEach(function(spr:FlxSprite)
												{
													spr.kill();
													spr.destroy();
													spr = null;
												});
												smokeFore.forEach(function(spr:FlxSprite)
												{
													spr.kill();
													spr.destroy();
													spr = null;
												});
											fireThing2.kill();
											fireThing2.destroy();
											fireThing2 = null;
											heavyRain.kill();
											heavyRain.destroy();
											heavyRain = null;
											stageCurtains.visible = true;
										}
										streetRuins.kill();
										streetRuins.destroy();
										streetRuins = null;
										fakeLightOfHope.kill();
										fakeLightOfHope.destroy();
										fakeLightOfHope = null;
								}
							}
					if (!lowQuality)
					{
						if (SONG.song == "Delusional" && FlxG.random.bool(3) && tumbleWeed == null && curBeat < 474)
							summonWeedMakerLmfao();
						else if (SONG.song != "Delusional" && FlxG.random.bool(3) && tumbleWeed == null)
							summonWeedMakerLmfao();

						if (SONG.song == "Delusional" && curBeat > 880 && !lowQuality)
						{
							if (FlxG.random.bool(45)) lightningStrike();
							if (FlxG.random.bool(36)) lightningStrikeFore();
						}
					}

			case 'forestNew':
				if (ClientPrefs.shaders)
					{
						if (curBeat == 192)
						{	
							if(!lowQuality && goofyBG != null && treesFront != null)
								{
									goofyBG.shader = wobblyBG;
									goofyStreet.shader = wobblyBG;
									treesBack.shader = wobblyBG;
									otherBack.shader = wobblyBG;
									treesFront.shader = wobblyBG;
								}
						}
					}
					
				if (curBeat == 256)
					{
						if(!lowQuality && treesFront != null && goofyBG != null)
							{
								goofyBG.shader = null;
								goofyStreet.shader = null;
								treesBack.shader = null;
								otherBack.shader = null;
								treesFront.shader = null;
							}
					}
			case 'treasureIsland':
				if (curBeat == 256)
					FlxTween.tween(mascotRoom, {alpha: 0}, 1.5);
				if (curBeat == 264)
					FlxTween.tween(mascotRoomPOV, {alpha: 1}, 1.5);
				if (curBeat == 332)
				{
					mascotRoom.alpha = 1;
					mascotRoomPOV.visible = false;
				}
			case 'forbiddenRealm':
				if (SONG.song == 'Malfunction')
					{
						if (curBeat == 160)
						{
							whiteBG.alpha = 1;
							FlxTween.tween(whiteBG, {alpha: 0}, 2);
							FlxTween.tween(fuckingsquares, {alpha: 0}, 5, {ease: FlxEase.sineOut});
						}
				
						if (curBeat == 184)
						{
							FlxTween.tween(fuckingsquares, {alpha: 1}, 1.5, {ease: FlxEase.sineOut});
						}
					}
			case 'apartment':
				if (SONG.song == "Cycled Sins Legacy")
					{
						if (curBeat == 144)
						{
							bg1.visible = false;
							bg2.visible = true;
							bg2.shader = glitchBG;
						}
					}
			case 'staticVoid':
				if(curBeat == 32)
					{
						defaultCamZoom = 0.85;
					}
				
				if (curBeat == 104)
				{
					datTV.alpha = 1;
			
					canZoom = true;
			
					if(ClientPrefs.flashing)
					camGame.flash(FlxColor.WHITE, 1);
				}
			
				if(curBeat == 168)
					canZoom = false;
			
				if(curBeat == 232) {
					canZoom = true;
			
					if(ClientPrefs.flashing)
					camGame.flash(FlxColor.WHITE, 1);
				}
			
				if(curBeat == 356)
					{
						defaultCamZoom = 0.95;
					}
			
				if(curBeat == 360)
					{
						defaultCamZoom = 0.85;
			
						if(ClientPrefs.flashing)
						camGame.flash(FlxColor.WHITE, 1);
					}
			
				if(curBeat == 424)
					{
						FlxTween.tween(camHUD, {alpha: 0}, 2, {ease: FlxEase.cubeInOut});
						FlxTween.tween(camNotes, {alpha: 0}, 2.3, {ease: FlxEase.cubeInOut});
					}
				
				/*if (curBeat == 136 || curBeat == 140 || curBeat == 144 || curBeat == 148 || curBeat == 152 || curBeat == 156 || curBeat == 160 || curBeat == 164)
					if(!lowQuality && redGradThing != null)
						FlxTween.tween(redGradThing.scale, {y: 1.5}, 0.5, {ease: FlxEase.quadInOut});
				
				if (curBeat == 138 || curBeat == 142 || curBeat == 146 || curBeat == 150 || curBeat == 154 || curBeat == 158 || curBeat == 162 || curBeat == 166)
					if(!lowQuality && redGradThing != null)
						FlxTween.tween(redGradThing.scale, {y: 0}, 0.5, {ease: FlxEase.quadInOut});*/
			
				if(canZoom && curBeat % 1 == 0)
					{
						camGame.zoom += 0.015;
						camHUD.zoom += 0.04;
						camNotes.zoom += 0.04;
					}
			case 'alleyway' | 'ddStage':
				 // me when zoom gets higher or whatever -jason
				 if(curBeat >= 64 && curBeat < 95)
					{
						FlxG.camera.zoom += 0.025;
						camHUD.zoom += 0.042;
						camNotes.zoom += 0.042;
						FlxTween.tween(gradient, {alpha: 0.3}, 2);
					}
		
				if(curBeat >= 96 && curBeat < 111)
					{
						FlxG.camera.zoom += 0.04;
						camHUD.zoom += 0.053;
						camNotes.zoom += 0.053;
						FlxTween.tween(gradient, {alpha: 0.6}, 2);
					}
		
				if(curBeat == 112)
					{
						isCameraOnForcedPos = true;
						FlxTween.tween(camFollow, {x: camFollow.x - 150, y: 1380}, 14, {ease: FlxEase.sineInOut});
						FlxTween.tween(FlxG.camera, {zoom: 2}, 14, {ease: FlxEase.sineInOut});
						FlxTween.tween(gradient, {alpha: 0.9}, 2);
					}
		
				if(curBeat >= 112) // doesn't make sense to but a "&& curBeat < idk"
				{
					// not including camGame cus it bugs out
					camHUD.zoom += 0.053;
					camNotes.zoom += 0.053;
				}
			case 'tank':
				if(!ClientPrefs.lowQuality) tankWatchtower.dance();
				foregroundSprites.forEach(function(spr:BGSprite)
				{
					spr.dance();
				});

			case 'school':
				if(!ClientPrefs.lowQuality) {
					bgGirls.dance();
				}

			case 'mall':
				if(!ClientPrefs.lowQuality) {
					upperBoppers.dance(true);
				}

				if(heyTimer <= 0) bottomBoppers.dance(true);
				santa.dance(true);

			case 'limo':
				if(!ClientPrefs.lowQuality) {
					grpLimoDancers.forEach(function(dancer:BackgroundDancer)
					{
						dancer.dance();
					});
				}

				if (FlxG.random.bool(10) && fastCarCanDrive)
					fastCarDrive();
			case "philly":
				if (!trainMoving)
					trainCooldown += 1;

				if (curBeat % 4 == 0)
				{
					curLight = FlxG.random.int(0, phillyLightsColors.length - 1, [curLight]);
					phillyWindow.color = phillyLightsColors[curLight];
					phillyWindow.alpha = 1;
				}

				if (curBeat % 8 == 4 && FlxG.random.bool(30) && !trainMoving && trainCooldown > 8)
				{
					trainCooldown = FlxG.random.int(-4, 0);
					trainStart();
				}
		}

		if (curStage == 'spooky' && FlxG.random.bool(10) && curBeat > lightningStrikeBeat + lightningOffset)
		{
			lightningStrikeShit();
		}
		lastBeatHit = curBeat;

		setOnLuas('curBeat', curBeat); //DAWGG?????
		callOnLuas('onBeatHit', []);
	}

	override function sectionHit()
	{
		super.sectionHit();

		if (SONG.notes[curSection] != null)
		{
			if (generatedMusic && !endingSong && !isCameraOnForcedPos)
			{
				moveCameraSection();
			}

			if (camZooming && FlxG.camera.zoom < 1.35 && ClientPrefs.camZooms && SONG.song != "Cycled Sins") // me when recreating the actual relapse game visuals lmao
			{
				FlxG.camera.zoom += 0.015 * camZoomingMult;
				camHUD.zoom += 0.03 * camZoomingMult;
				camNotes.zoom += .03 * camZoomingMult;
			}

			if (SONG.notes[curSection].changeBPM)
			{
				Conductor.bpm = (SONG.notes[curSection].bpm);
				setOnLuas('curBpm', Conductor.bpm);
				setOnLuas('crochet', Conductor.crochet);
				setOnLuas('stepCrochet', Conductor.stepCrochet);
			}
			setOnLuas('mustHitSection', SONG.notes[curSection].mustHitSection);
			setOnLuas('altAnim', SONG.notes[curSection].altAnim);
			setOnLuas('gfSection', SONG.notes[curSection].gfSection);
		}
		
		setOnLuas('curSection', curSection);
		callOnLuas('onSectionHit', []);
	}

	public function callOnLuas(event:String, args:Array<Dynamic>, ignoreStops = true, exclusions:Array<String> = null):Dynamic {
		var returnVal:Dynamic = FunkinLua.Function_Continue;
		#if LUA_ALLOWED
		if(exclusions == null) exclusions = [];
		for (script in luaArray) {
			if(exclusions.contains(script.scriptName))
				continue;

			var ret:Dynamic = script.call(event, args);
			if(ret == FunkinLua.Function_StopLua && !ignoreStops)
				break;
			
			// had to do this because there is a bug in haxe where Stop != Continue doesnt work
			var bool:Bool = ret == FunkinLua.Function_Continue;
			if(!bool && ret != 0) {
				returnVal = cast ret;
			}
		}
		#end
		//trace(event, returnVal);
		return returnVal;
	}

	public function birthdayParticles(targetGroup:FlxSpriteGroup) {
		var path:String = 'favi/ui/bdaynotes';
		var particleNote:FlxSprite = new FlxSprite().loadGraphic(Paths.image('$path/note_${FlxG.random.int(1, 3)}', 'shared'));
		particleNote.setGraphicSize(Std.int(particleNote.width * 0.7));
		particleNote.updateHitbox();
		particleNote.x = FlxG.random.int(Std.int(targetGroup.x - (targetGroup == boyfriendGroup ? 0 : 150)), Std.int(targetGroup.x + (targetGroup == boyfriendGroup ? 500 : 300)));
		particleNote.y = targetGroup.y - 170;
		particleNote.velocity.y += targetGroup.y - 400;
		particleNote.acceleration.y = 400 * playbackRate;
		particleNote.angle = FlxG.random.int(0, 360);
		
		FlxTween.tween(particleNote, {alpha: 0}, 3, {
			onComplete: function(tween:FlxTween)
			{
				particleNote.destroy();
			}
		});
		add(particleNote);
	}

	// prob use velocity.x someday for not time enough for that
	function summonWeedMakerLmfao()
		{
			if (FlxG.random.bool(1))
			{
				tumbleWeed = new FlxSprite(1800, 490).loadGraphic(Paths.image(pathway + 'THELEGENDARYTUMBLEWEED'));
				tumbleWeed.scale.set(0.6, 0.6);
				FlxTween.tween(tumbleWeed, {angle: -360}, 0.5, {type: LOOPING});
				tumbleGrp.add(tumbleWeed);
		
				FlxTween.tween(tumbleWeed, {y: 825}, 0.1, {ease: FlxEase.sineInOut, type: PINGPONG});
		
				FlxTween.tween(tumbleWeed, {x: -1200}, 2, {onComplete: function(twn:FlxTween)
				{
					tumbleWeed.kill();
					tumbleWeed = null;
				}});
			}
			else
			{
				tumbleWeed = new FlxSprite(1800, 600).loadGraphic(Paths.image(pathway + 'Tumble_' + FlxG.random.int(0,1)));
				FlxTween.tween(tumbleWeed, {angle: -360}, 1.7, {type: LOOPING});
				tumbleGrp.add(tumbleWeed);
		
				FlxTween.tween(tumbleWeed, {y: 735}, 0.75, {ease: FlxEase.sineIn, type: PINGPONG});
		
				FlxTween.tween(tumbleWeed, {x: -1200}, 5.6, {onComplete: function(twn:FlxTween)
				{
					tumbleWeed.kill();
					tumbleWeed = null;
				}});
			}
		}

	function lightningStrike()
	{
		lightning.alpha = 1;
		if (FlxG.random.bool(50))
		{
			lightning.animation.play('boom');
		}
		else
		{
			lightning.animation.play('boom2');
		}
		new FlxTimer().start(1.5, function(tmr:FlxTimer) {lightning.alpha = 0;});
	}

	function lightningStrikeFore()
		{
			lightningFore.alpha = 1;
			if (FlxG.random.bool(50))
			{
				lightningFore.animation.play('boom');
			}
			else
			{
				lightningFore.animation.play('boom2');
			}
			new FlxTimer().start(1.5, function(tmr:FlxTimer) {lightningFore.alpha = 0;});
		}

	public function setOnLuas(variable:String, arg:Dynamic) {
		#if LUA_ALLOWED
		for (i in 0...luaArray.length) {
			luaArray[i].set(variable, arg);
		}
		#end
	}

	function StrumPlayAnim(isDad:Bool, id:Int, time:Float) {
		var spr:StrumNote = null;
		if(isDad) {
			spr = strumLineNotes.members[id];
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
		setOnLuas('score', songScore);
		setOnLuas('misses', songMisses);
		setOnLuas('hits', songHits);

		var ret:Dynamic = callOnLuas('onRecalculateRating', [], false);
		if(ret != FunkinLua.Function_Stop)
		{
			if(totalPlayed < 1) //Prevent divide by 0
				ratingName = '?';
			else
			{
				// Rating Percent
				ratingPercent = Math.min(1, Math.max(0, totalNotesHit / totalPlayed));
				//trace((totalNotesHit / totalPlayed) + ', Total: ' + totalPlayed + ', notes hit: ' + totalNotesHit);

				// Rating Name
				if(ratingPercent >= 1)
				{
					ratingName = ratingStuff[ratingStuff.length-1][0]; //Uses last string
				}
				else
				{
					for (i in 0...ratingStuff.length-1)
					{
						if(ratingPercent < ratingStuff[i][1])
						{
							ratingName = ratingStuff[i][0];
							break;
						}
					}
				}
			}

			// Rating FC
			ratingFC = "";
			if (sicks > 0) ratingFC = "SFC";
			if (goods > 0) ratingFC = "GFC";
			if (bads > 0 || shits > 0) ratingFC = "FC";
			if (songMisses > 0 && songMisses < 10) ratingFC = "SDCB";
			else if (songMisses >= 10) ratingFC = "Clear";
		}
		updateScore(badHit); // score will only update after rating is calculated, if it's a badHit, it shouldn't bounce -Ghost
		setOnLuas('rating', ratingPercent);
		setOnLuas('ratingName', ratingName);
		setOnLuas('ratingFC', ratingFC);
	}

	#if ACHIEVEMENTS_ALLOWED
	private function checkForAchievement(achievesToCheck:Array<String> = null):String
	{
		if(chartingMode) return null;

		var usedPractice:Bool = (ClientPrefs.getGameplaySetting('practice', false) || ClientPrefs.getGameplaySetting('botplay', false));
		for (i in 0...achievesToCheck.length) {
			var achievementName:String = achievesToCheck[i];
			if(!Achievements.isAchievementUnlocked(achievementName) && !cpuControlled) {
				var unlock:Bool = false;
				
				if (achievementName.contains(WeekData.getWeekFileName()) && achievementName.endsWith('nomiss')) // any FC achievements, name should be "weekFileName_nomiss", e.g: "weekd_nomiss";
				{
					if(isStoryMode && campaignMisses + songMisses < 1 && CoolUtil.difficultyString() == 'HARD'
						&& storyPlaylist.length <= 1 && !changedDifficulty && !usedPractice)
						unlock = true;
				}
				switch(achievementName)
				{
					case 'ur_bad':
						if(ratingPercent < 0.2 && !practiceMode) {
							unlock = true;
						}
					case 'ur_good':
						if(ratingPercent >= 1 && !usedPractice) {
							unlock = true;
						}
					case 'roadkill_enthusiast':
						if(Achievements.henchmenDeath >= 100) {
							unlock = true;
						}
					case 'oversinging':
						if(boyfriend.holdTimer >= 10 && !usedPractice) {
							unlock = true;
						}
					case 'hype':
						if(!boyfriendIdled && !usedPractice) {
							unlock = true;
						}
					case 'two_keys':
						if(!usedPractice) {
							var howManyPresses:Int = 0;
							for (j in 0...keysPressed.length) {
								if(keysPressed[j]) howManyPresses++;
							}

							if(howManyPresses <= 2) {
								unlock = true;
							}
						}
					case 'toastie':
						if(/*ClientPrefs.framerate <= 60 &&*/ !ClientPrefs.shaders && ClientPrefs.lowQuality && !ClientPrefs.globalAntialiasing) {
							unlock = true;
						}
					case 'debugger':
						if(Paths.formatToSongPath(SONG.song) == 'test' && !usedPractice) {
							unlock = true;
						}
				}

				if(unlock) {
					Achievements.unlockAchievement(achievementName);
					return achievementName;
				}
			}
		}
		return null;
	}
	#end

	/*static function set_windowName(value:String):String
	{
		FlxG.stage.window.title = value;
		return value;
	}*/

	var curLight:Int = -1;
	var curLightEvent:Int = -1;
}