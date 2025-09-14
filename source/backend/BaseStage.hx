package backend;

import flixel.FlxBasic;
import flixel.FlxObject;
import flixel.FlxSubState;
import backend.MusicBeatState;
import states.PlayState;

import objects.notes.Note.EventNote;
import objects.Character;

enum Countdown
{
	THREE;
	TWO;
	ONE;
	GO;
	START;
}

typedef StageAssetData = {
	path:String,
	type:AssetType,
	priority:AssetPriority,
	song:String,
	folder:Null<String>
}

enum AssetType {
	IMAGE;
	ATLAS;
	VIDEO;
	CHARACTER;
	ICON;
	SOUND;
}

enum abstract AssetPriority(Int) from Int to Int {
	var HIGH = 0;
	var MEDIUM = 1;
	var LOW = 2;
}

class BaseStage extends FlxBasic
{
	private var game(default, set):Dynamic = PlayState.instance;
	public var onPlayState:Bool = false;

	// some variables for convenience
	public var paused(get, never):Bool;
	public var songName(get, never):String;
	public var isStoryMode(get, never):Bool;
	public var seenCutscene(get, never):Bool;
	public var inCutscene(get, set):Bool;
	public var canPause(get, set):Bool;
	public var members(get, never):Dynamic;

	public var boyfriend(get, never):Character;
	public var dad(get, never):Character;
	public var gf(get, never):Character;
	public var boyfriendGroup(get, never):FlxSpriteGroup;
	public var dadGroup(get, never):FlxSpriteGroup;
	public var gfGroup(get, never):FlxSpriteGroup;
	
	public var camGame(get, never):FlxCamera;
	public var camHUD(get, never):FlxCamera;
	public var camOther(get, never):FlxCamera;

	public var defaultCamZoom(get, set):Float;
	public var camFollow(get, never):FlxObject;

	public function new()
	{
		this.game = MusicBeatState.getState();
		if(this.game == null)
		{
			FlxG.log.warn('Invalid state for the stage added!');
			destroy();
		}
		else 
		{
			this.game.stages.push(this);
			super();
			create();
		}
	}

	//main callbacks
	public function create() {}
	public function createPost() {}
	//public function update(elapsed:Float) {}
	public function countdownTick(count:Countdown, num:Int) {}

	// FNF steps, beats and sections
	public var curBeat:Int = 0;
	public var curDecBeat:Float = 0;
	public var curStep:Int = 0;
	public var curDecStep:Float = 0;
	public var curSection:Int = 0;
	public function beatHit() {}
	public function stepHit() {}
	public function sectionHit() {}

	// Substate close/open, for pausing Tweens/Timers
	public function closeSubState() {}
	public function openSubState(SubState:FlxSubState) {}

	// Events
	public function eventCalled(eventName:String, value1:String, value2:String, flValue1:Null<Float>, flValue2:Null<Float>, strumTime:Float) {}
	public function eventPushed(event:EventNote) {}
	public function eventPushedUnique(event:EventNote) {}

	// Things to replace FlxGroup stuff and inject sprites directly into the state
	function add(object:FlxBasic) game.add(object);
	function remove(object:FlxBasic) game.remove(object);
	function insert(position:Int, object:FlxBasic) game.insert(position, object);
	
	public function addBehindGF(obj:FlxBasic) insert(members.indexOf(game.gfGroup), obj);
	public function addBehindBF(obj:FlxBasic) insert(members.indexOf(game.boyfriendGroup), obj);
	public function addBehindDad(obj:FlxBasic) insert(members.indexOf(game.dadGroup), obj);
	public function setDefaultGF(name:String) //Fix for the Chart Editor on Base Game stages
	{
		var gfVersion:String = PlayState.SONG.gfVersion;
		if(gfVersion == null || gfVersion.length < 1)
		{
			gfVersion = name;
			PlayState.SONG.gfVersion = gfVersion;
		}
	}

	public function onFocus():Void {}

	public function onFocusLost():Void {}

	//start/end callback functions
	public function setStartCallback(myfn:Void->Void)
	{
		if(!onPlayState) return;
		PlayState.instance.startCallback = myfn;
	}
	public function setEndCallback(myfn:Void->Void)
	{
		if(!onPlayState) return;
		PlayState.instance.endCallback = myfn;
	}

	/*
	===== CACHE SYSTEM ===== by mr_chaosss
	*/

	public function getStageAssets(?song:String):Array<StageAssetData> {
		return [];
	}

	public static function getAssetsForStage(stageClass:Class<BaseStage>, ?song:String):Array<StageAssetData>
	{
		var fn = Reflect.field(stageClass, "getStaticAssets");
		if (fn != null)
		{
			return Reflect.callMethod(stageClass, fn, [song]);
		}

		trace('No asset definition found for stage class: ' + Type.getClassName(stageClass));
		return [];
	}


	/**
	 * [Creating a multiple assets with same settings]
	 * @param path Asset file name (without extension)
	 * @param type Asset type (IMAGE, ATLAS, VIDEO, etc.)
	 * @param priority Loading priority (HIGH, MEDIUM, LOW)
	 * @param song Song this asset is for ("ALL" for all songs)
	 * @param folder Subfolder path if needed
	 * @return StageAssetData object
	 */

	public static function asset(path:String, type:AssetType, priority:AssetPriority = MEDIUM, ?song:String, ?folder:String) {
		return {
			path: PlayState.pathway + path, //path, .. chaos fucked my wife,,,,,,deserved (don)
			type: type,
			priority: priority,
			song: song,
			folder: folder
		};
	}

	// Chaos lowkey carrying but we are fucking suffering asbufsdihbtejdsfhbaijFUdbDfxbsfez XHBv cxjhszrhbkv ghjacwefa#Jvszfadfh j - don :))
	// but you forgot i exist lowkey -(malyplus)
	// im making shit for mod 🤓 -- mr_chaoss
	// shit shit shit shit shit siht shit shit shit sthis shits
	// delusio
	// fuckfuckfuckfuckfuckcfukccifuckad yfousyuafejhjwdcojklGJnbkjwesvncsdfkjxvbdfnv kzdvnckjdi bizdcgbvkiz vkjwves gigijo iogbzuidcfhu ceszov4ijfb 2ui4es rgacire f1r2w - don :)))))))
	/**
	 * [Helper method to create multiple assets with the same settings]
	 * @param paths Array of asset file names
	 * @param type Asset type for all assets
	 * @param priority Loading priority for all assets
	 * @param song Song these assets are for
	 * @param folder Subfolder path for all assets
	 * @return Array of StageAssetData objects
	 */
	public static function assets(paths:Array<String>, type:AssetType, priority:AssetPriority = MEDIUM, ?song:String = "ALL", ?folder:String):Array<StageAssetData>
	{
		return paths.map(path -> asset(path, type, priority, song, folder));
	}

	public static function characters(characters:Array<String>, priority:AssetPriority = HIGH, ?song:String = "ALL"):Array<StageAssetData>
	{
		return assets(characters, CHARACTER, priority, song, "characters");
	}

	public static function icons(icons:Array<String>, priority:AssetPriority = MEDIUM, ?song:String = "ALL"):Array<StageAssetData>
	{
		return assets(icons, ICON, priority, song, "icons");
	}

	public static function videos(videos:Array<String>, priority:AssetPriority = MEDIUM, ?song:String = "ALL"):Array<StageAssetData>
	{
		return assets(videos, VIDEO, priority, song, "videos");
	}

	public static function filterByQuality(assets:Array<StageAssetData>):Array<StageAssetData> {
		if (!ClientPrefs.data.lowQuality) {
			return assets;
		}

		return assets.filter(asset -> {
			if(asset.type == CHARACTER || asset.type == VIDEO || asset.type == ICON) {
				return true;
			}

			return asset.priority != LOW;
		});
	}

	public function getCurrentSongAssets():Array<StageAssetData> {
		var songName = game.SONG != null ? game.SONG.song : "ALL";
		var assets = getStageAssets(songName);
		return filterByQuality(assets);
	}

	// Note Hit/Miss
	public function goodNoteHit(note:Note) {}
	public function opponentNoteHit(note:Note) {}
	public function noteMiss(note:Note) {}
	public function noteMissPress(direction:Int) {}

	// overrides
	function startCountdown() if(onPlayState) return PlayState.instance.startCountdown(); else return false;
	function endSong() if(onPlayState)return PlayState.instance.endSong(); else return false;
	function moveCameraSection() if(onPlayState) moveCameraSection();
	function moveCamera(isDad:Bool) if(onPlayState) moveCamera(isDad);
	inline private function get_paused() return game.paused;
	inline private function get_songName() return game.songName;
	inline private function get_isStoryMode() return PlayState.isStoryMode;
	inline private function get_seenCutscene() return PlayState.seenCutscene;
	inline private function get_inCutscene() return game.inCutscene;
	inline private function set_inCutscene(value:Bool)
	{
		game.inCutscene = value;
		return value;
	}
	inline private function get_canPause() return game.canPause;
	inline private function set_canPause(value:Bool)
	{
		game.canPause = value;
		return value;
	}
	inline private function get_members() return game.members;
	inline private function set_game(value:MusicBeatState)
	{
		onPlayState = (Std.isOfType(value, states.PlayState));
		game = value;
		return value;
	}

	inline private function get_boyfriend():Character return game.boyfriend;
	inline private function get_dad():Character return game.dad;
	inline private function get_gf():Character return game.gf;

	inline private function get_boyfriendGroup():FlxSpriteGroup return game.boyfriendGroup;
	inline private function get_dadGroup():FlxSpriteGroup return game.dadGroup;
	inline private function get_gfGroup():FlxSpriteGroup return game.gfGroup;
	
	inline private function get_camGame():FlxCamera return game.camGame;
	inline private function get_camHUD():FlxCamera return game.camHUD;
	inline private function get_camOther():FlxCamera return game.camOther;

	inline private function get_defaultCamZoom():Float return game.defaultCamZoom;
	inline private function set_defaultCamZoom(value:Float):Float
	{
		game.defaultCamZoom = value;
		return game.defaultCamZoom;
	}
	inline private function get_camFollow():FlxObject return game.camFollow;
}