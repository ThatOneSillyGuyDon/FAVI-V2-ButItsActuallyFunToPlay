package states;

import lime.app.Promise;
import lime.app.Future;
import flixel.FlxState;

import openfl.utils.Assets;
import openfl.utils.AssetType as OFAssetType;

import lime.utils.Assets as LimeAssets;
import lime.utils.AssetLibrary;
import lime.utils.AssetManifest;

import backend.data.StageData;
import backend.BaseStage;
import haxe.io.Path;

class LoadingState extends MusicBeatState
{
	inline static var MIN_TIME = 3.0;

	// Browsers will load create(), you can make your song load a custom directory there
	// If you're compiling to desktop (or something that doesn't use NO_PRELOAD_ALL), search for getNextState instead
	// I'd recommend doing it on both actually lol
	
	// TO DO: Make this easier

	var funi:Array<String> = [
		"Loading...",
		"Getting the stuff...",
		"Please wait...",
		"Wait please...",
		"Please hold...",
		"Loading content...",
		"Load...",
		"Please load...",
		"Can you wait...?",
		"Getting the shits...",
		"Grabbing da shits...",
		"Generating world...",
		"Hold your horses...",
		"For fuck sakes, wait damnit...",
		"Hold on, the game ain't going anywhere...",
		"Bitch, please wait...",
		"Just wait, please...",
		"Please wait on the line...",
		"Preparing some cool stuff...",
		"So cool...",
		"Loading some cool shit...",
		"Human, i remeber your loading...",
		"I am loading..."
	];

	var target:FlxState;
	var stopMusic = false;
	var directory:String;
	var callbacks:MultiCallback;
	var targetShit:Float = 0;

	var loadingImage:FlxSprite;
	var iconAnimated:FlxSprite;
	var loadBar:FlxSprite;
	var progressText:FlxText;
	var loadingScreens:Int = 1;

	// Asset loading system
	private var totalAssets:Int = 0;
	private var loadedAssets:Int = 0;
	private var loadingProgress:Float = 0;
	private var isPreloadingAssets:Bool = false;

	function new(target:FlxState, stopMusic:Bool, directory:String)
	{
		super();
		this.target = target;
		this.stopMusic = stopMusic;
		this.directory = directory;
	}

	override function create()
	{
		lime.app.Application.current.window.title = 'Funkin.avi - ${funi[FlxG.random.int(0, funi.length-1)]}';
		
		setupLoadingUI();
		
		initSongsManifest().onComplete(function (lib) {
			callbacks = new MultiCallback(onLoad);
			var introComplete = callbacks.add("introComplete");
			
			if (PlayState.SONG != null) {
				checkLoadSong(getSongPath());
				if (PlayState.SONG.needsVoices)
					checkLoadSong(getVocalPath());
			}
			
			if(directory != null && directory.length > 0 && directory != 'shared') {
				checkLibrary('week_assets');
			}

			var fadeTime = 0.5;
			FlxG.camera.fade(FlxG.camera.bgColor, fadeTime, true);
			new FlxTimer().start(fadeTime + MIN_TIME, function(_) introComplete());
		});
		callbacks = new MultiCallback(onLoad, "LoadingCallbacks");
	}

	var textThing:FlxText;
	private function setupLoadingUI():Void
	{
		loadingImage = new FlxSprite(0, 0);
		loadingImage.loadGraphic(Paths.image('Funkin_avi/loadingScreen/loadingScreen${loadingScreens}'));
		loadingImage.screenCenter();
		loadingImage.antialiasing = ClientPrefs.data.antialiasing;
		add(loadingImage);

		iconAnimated = new FlxSprite(0, 0);
		iconAnimated.antialiasing = ClientPrefs.data.antialiasing;
		iconAnimated.scrollFactor.set(0, 0);
		iconAnimated.scale.set(0.2, 0.2);
		iconAnimated.x += 880;
		iconAnimated.y += 330;
		iconAnimated.frames = Paths.getSparrowAtlas('Funkin_avi/loadingScreen/loadingicon');
		iconAnimated.animation.addByPrefix('loadBitch', "loadingicon", 16, true);
		iconAnimated.animation.play('loadBitch');
		add(iconAnimated);
	}
	
	function checkLoadSong(path:String)
	{
		if (Assets.cache.hasSound(path)) return;

		var callback = callbacks.add("song:" + path);

		// if the asset id is wrong, don't hang the loader
		if (!Assets.exists(path, OFAssetType.SOUND)) {
			trace('Sound does not exist: ' + path);
			callback();
			return;
		}

		Assets.loadSound(path)
			.onComplete(function(_) { callback(); })
			.onError(function(err) {
				trace('Failed to load sound: ' + path + ' -> ' + err);
				callback(); // important: always fire
			});
	}

	
	function checkLibrary(library:String) {
		trace(Assets.hasLibrary(library));
		if (Assets.getLibrary(library) == null)
		{
			@:privateAccess
			if (!LimeAssets.libraryPaths.exists(library))
				throw new haxe.Exception("Missing library: " + library);

			var callback = callbacks.add("library:" + library);
			Assets.loadLibrary(library).onComplete(function (_) { callback(); });
		}
	}
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
	}
	
	function onLoad()
	{
		if (stopMusic && FlxG.sound.music != null)
			FlxG.sound.music.stop();
		
		// Log cache statistics
		trace("Loading complete! Cache stats:", Paths.getCacheStats());
		
		MusicBeatState.switchState(target);
	}
	
	static function getSongPath()
	{
		return Paths.inst(PlayState.SONG.song);
	}
	
	static function getVocalPath()
	{
		return Paths.voices(PlayState.SONG.song);
	}
	
	inline static public function loadAndSwitchState(target:FlxState, stopMusic = false)
	{
		MusicBeatState.switchState(getNextState(target, stopMusic));
	}
	
	static function getNextState(target:FlxState, stopMusic = false):FlxState
	{
		var directory:String = 'shared';
		var weekDir:String = StageData.forceNextDirectory;
		StageData.forceNextDirectory = null;
		if (weekDir != null && weekDir.length > 0) directory = weekDir;

		Paths.setCurrentLevel(directory);
		trace('Setting asset folder to ' + directory);

		var loaded = false;
		if (PlayState.SONG != null) {
			loaded = isSoundLoaded(getSongPath())
				&& (!PlayState.SONG.needsVoices || isSoundLoaded(getVocalPath()));
			if (directory != 'shared') loaded = loaded && isLibraryLoaded('week_assets');
		}

		if (!loaded) return new LoadingState(target, stopMusic, directory);
		if (stopMusic && FlxG.sound.music != null) FlxG.sound.music.stop();
		return target;
	}
	
	static function isSoundLoaded(path:String):Bool
	{
		trace(path);
		return Assets.cache.hasSound(path);
	}
	
	static function isLibraryLoaded(library:String):Bool
	{
		return Assets.getLibrary(library) != null;
	}
	
	override function destroy()
	{
		super.destroy();
		
		callbacks = null;
	}
	
	static function initSongsManifest()
	{
		var id = "songs";
		var promise = new Promise<AssetLibrary>();

		var library = LimeAssets.getLibrary(id);

		if (library != null)
		{
			return Future.withValue(library);
		}

		var path = id;
		var rootPath = null;

		@:privateAccess
		var libraryPaths = LimeAssets.libraryPaths;
		if (libraryPaths.exists(id))
		{
			path = libraryPaths[id];
			rootPath = Path.directory(path);
		}
		else
		{
			if (StringTools.endsWith(path, ".bundle"))
			{
				rootPath = path;
				path += "/library.json";
			}
			else
			{
				rootPath = Path.directory(path);
			}
			@:privateAccess
			path = LimeAssets.__cacheBreak(path);
		}

		AssetManifest.loadFromFile(path, rootPath).onComplete(function(manifest)
		{
			if (manifest == null)
			{
				promise.error("Cannot parse asset manifest for library \"" + id + "\"");
				return;
			}

			var library = AssetLibrary.fromManifest(manifest);

			if (library == null)
			{
				promise.error("Cannot open library \"" + id + "\"");
			}
			else
			{
				@:privateAccess
				LimeAssets.libraries.set(id, library);
				library.onChange.add(LimeAssets.onChange.dispatch);
				promise.completeWith(Future.withValue(library));
			}
		}).onError(function(_)
		{
			promise.error("There is no asset library with an ID of \"" + id + "\"");
		});

		return promise.future;
	}
}

class MultiCallback
{
	public var callback:Void->Void;
	public var logId:String = null;
	public var length(default, null) = 0;
	public var numRemaining(default, null) = 0;
	
	var unfired = new Map<String, Void->Void>();
	var fired = new Array<String>();
	
	public function new (callback:Void->Void, logId:String = null)
	{
		this.callback = callback;
		this.logId = logId;
	}
	
	public function add(id = "untitled")
	{
		id = '$length:$id';
		length++;
		numRemaining++;
		var func:Void->Void = null;
		func = function ()
		{
			if (unfired.exists(id))
			{
				unfired.remove(id);
				fired.push(id);
				numRemaining--;
				
				if (logId != null)
					log('fired $id, $numRemaining remaining');
				
				if (numRemaining == 0)
				{
					if (logId != null)
						log('all callbacks fired');
					callback();
				}
			}
			else
				log('already fired $id');
		}
		unfired[id] = func;
		return func;
	}
	
	inline function log(msg):Void
	{
		if (logId != null)
			trace('$logId: $msg');
	}
	
	public function getFired() return fired.copy();
	public function getUnfired() return [for (id in unfired.keys()) id];
}