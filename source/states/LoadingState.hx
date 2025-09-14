package states;

import lime.app.Promise;
import lime.app.Future;
import flixel.FlxState;

import openfl.utils.Assets;
import openfl.utils.AssetType as OFAssetType;

import lime.utils.Assets as LimeAssets;
import lime.utils.AssetLibrary;
import lime.utils.AssetManifest;

import backend.StageData;
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
		loadingScreens = FlxG.random.int(1, 4);
		lime.app.Application.current.window.title = 'Funkin.avi - ${funi[FlxG.random.int(0, funi.length-1)]}';
		
		setupLoadingUI();
		
		initSongsManifest().onComplete(function (lib) {
			callbacks = new MultiCallback(onLoad);
			var introComplete = callbacks.add("introComplete");
			
			if (PlayState.SONG != null) {
				preloadStageAssets();
			}
			
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
	}

	var textThing:FlxText;
	private function setupLoadingUI():Void
	{
		loadingImage = new FlxSprite(0, 0);
		loadingImage.loadGraphic(Paths.image('Funkin_avi/loadingScreen/loadingScreen${loadingScreens}'));
		loadingImage.screenCenter();
		loadingImage.antialiasing = ClientPrefs.data.antialiasing;
		add(loadingImage);

		trace('loading image ${loadingScreens} loaded');

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

		progressText = new FlxText(0, FlxG.height - 100, FlxG.width, "Initializing...");
		progressText.setFormat(null, 20, FlxColor.WHITE, CENTER);
		progressText.alpha = 0.7;
		add(progressText);
		
		textThing = new FlxText(0,progressText.x,progressText.y - 30, ""+funi[FlxG.random.int(0,funi.length-1)]);
		textThing.screenCenter();
		textThing.y += 20;
		textThing.setFormat(null, 20, FlxColor.WHITE, CENTER);
		textThing.alpha = 0.7;
		add(textThing);
		FlxTween.tween(textThing, {alpha:0.001},3,{ease:FlxEase.cubeInOut, onComplete: (_) -> changeText()});
		

		loadBar = new FlxSprite(FlxG.width * 0.2, FlxG.height - 50);
		loadBar.makeGraphic(Std.int(FlxG.width * 0.6), 6, FlxColor.WHITE);
		loadBar.scale.x = 0;
		add(loadBar);
	}
	
	function changeText(){
		var blameGooberForMakingMeDelusional:String = funi[FlxG.random.int(0,funi.length-1)];

		textThing.text = blameGooberForMakingMeDelusional;				
		FlxTween.tween(textThing, {alpha:0.7},2,{ease:FlxEase.cubeInOut, onComplete:(_) -> vANISHFUCKYOU()}); //maly we will now execute you for fucking making the compiling session even more hellish than it was ahfsdiijzvkjrfndgbiqrhjwo4 - don
	}																								// no thanks :) (malyplus)
																									// chees burger -- mr_chaoss
	function vANISHFUCKYOU(){
		FlxTween.tween(textThing, {alpha:0.001},3,{ease:FlxEase.cubeInOut, onComplete:(_) -> changeText()});
	}
	

	private function preloadStageAssets():Void
	{
		var stageClass:Class<BaseStage> = getStageClass(PlayState.SONG.song);
		if (stageClass == null) { trace('No stage class found for song: ${PlayState.SONG.song}'); return; }

		var assetsToLoad:Array<StageAssetData> = BaseStage.getAssetsForStage(stageClass, PlayState.SONG.song);
		if (assetsToLoad == null || assetsToLoad.length == 0) { trace('No assets to preload for ${PlayState.SONG.song}'); return; }

		totalAssets = assetsToLoad.length;
		loadedAssets = 0;
		isPreloadingAssets = true;

		// LOW last
		assetsToLoad.sort(function(a, b) return a.priority - b.priority);

		trace('Preloading ${totalAssets} assets for ${PlayState.SONG.song}');
		updateProgressText("Loading stage assets...");

		for (asset in assetsToLoad) {
			loadAssetAsync(asset);
		}
	}

	private function getStageClass(songName:String):Class<BaseStage>
	{
		// Map songs to their stage classes
		// Add more mappings as you create new stages
		switch (songName) {
			case "Isolated" | "Lunacy" | "Delusional": 
				return cast states.stages.Episode1Street;
			default: 
				return cast states.stages.Episode1Street; // Default fallback
		}
	}

	private function loadAssetAsync(asset:StageAssetData):Void
	{
		var callback = callbacks.add('asset:${asset.path}');
		var fullPath = getAssetPath(asset);
		
		switch (asset.type) {
			case IMAGE:
				if (!checkAssetExists(fullPath, IMAGE)) { onAssetLoaded(asset, false); callback(); return; }
				Assets.loadBitmapData(Paths.getPath(fullPath, IMAGE))
					.onComplete(function(bd) {
						if (bd != null) Paths.cacheBitmap(fullPath, asset.folder, bd);
						onAssetLoaded(asset, bd != null); callback();
					})
					.onError(function(_) { onAssetLoaded(asset, false); callback(); });
				
			case ATLAS:
				var imagePath = fullPath;
				var xmlPath = StringTools.replace(fullPath, '.png', '.xml');
				var jsonPath = StringTools.replace(fullPath, '.png', '.json');

				var needed = 2; // image + data
				var done = 0;
				inline function mark() {
					done++;
					if (done >= needed) { onAssetLoaded(asset, true); callback(); }
				}

				// image
				if (checkAssetExists(imagePath, IMAGE)) {
					Assets.loadBitmapData(Paths.getPath(imagePath, IMAGE))
						.onComplete(function(bd) {
							if (bd != null) Paths.cacheBitmap(imagePath, asset.folder, bd);
							mark();
						})
						.onError(function(_) mark());
				} else mark();

				// atlas data (xml or json)
				var xmlId = Paths.getPath(xmlPath, TEXT);
				var jsonId = Paths.getPath(jsonPath, TEXT);

				if (Assets.exists(xmlId, TEXT)) {
					Assets.loadText(xmlId).onComplete(function(_) mark()).onError(function(_) mark());
				} else if (Assets.exists(jsonId, TEXT)) {
					Assets.loadText(jsonId).onComplete(function(_) mark()).onError(function(_) mark());
				} else {
					// no data present; still let it finish to avoid deadlock
					mark();
				}
				
			case CHARACTER:
				var charImagePath = 'images/characters/${asset.path}.png';
				if (checkAssetExists(charImagePath, IMAGE)) {
					Assets.loadBitmapData(Paths.getPath(charImagePath, IMAGE))
						.onComplete(function(bd) {
							if (bd != null) Paths.cacheBitmap(charImagePath, null, bd);
							onAssetLoaded(asset, bd != null); callback();
						})
						.onError(function(_) { onAssetLoaded(asset, false); callback(); });
				} else { onAssetLoaded(asset, false); callback(); }
				
			case ICON:
				var iconPath = 'images/icons/${asset.path}.png';
				if (checkAssetExists(iconPath, IMAGE)) {
					Assets.loadBitmapData(Paths.getPath(iconPath, IMAGE))
						.onComplete(function(bd) {
							if (bd != null) Paths.cacheBitmap(iconPath, null, bd);
							onAssetLoaded(asset, bd != null); callback();
						})
						.onError(function(_) { onAssetLoaded(asset, false); callback(); });
				} else { onAssetLoaded(asset, false); callback(); }
				
			case VIDEO:
				var exists = Paths.fileExists('videos/${asset.path}.${Paths.VIDEO_EXT}', BINARY);
				onAssetLoaded(asset, exists); callback();

			case SOUND:
				var soundPath = getAssetPath(asset); // e.g., sounds/...
				if (checkAssetExists(soundPath, SOUND)) {
					Assets.loadSound(Paths.getPath(soundPath, SOUND))
						.onComplete(function(_) { onAssetLoaded(asset, true); callback(); })
						.onError(function(_) { onAssetLoaded(asset, false); callback(); });
				} else { onAssetLoaded(asset, false); callback(); }
		}
	}

	private function checkAssetExists(path:String, type:AssetType):Bool
	{
		var ofType:OFAssetType = switch (type)
		{
			case IMAGE | CHARACTER | ICON: OFAssetType.IMAGE;
			case ATLAS: OFAssetType.TEXT; // atlas data is usually text (xml/json)
			case VIDEO: OFAssetType.BINARY;
			case SOUND: OFAssetType.SOUND;
		}

		return Paths.fileExists(path, ofType);
	}
	
	private function getAssetPath(asset:StageAssetData):String
	{
		var basePath = PlayState.pathway != null ? PlayState.pathway : "abandonedStreet"; // we have to fix it
		trace(basePath);
		
		switch (asset.type) {
			case IMAGE | ATLAS:
				if (asset.folder != null) {
					return 'images/${asset.folder}/${basePath}${asset.path}.png';
				}
				trace("Assets Path: " + asset.path + " Base path: " + basePath);
				return asset.path + basePath + '.png';
				
			case CHARACTER:
				return 'images/characters/${asset.path}.png';
				
			case ICON:
				return 'images/icons/${asset.path}.png';
				
			case VIDEO:
				return asset.path;

			case SOUND:
				if (asset.folder != null) {
					return 'sounds/${asset.folder}/${asset.path}.${Paths.SOUND_EXT}';
				}
				return 'sounds/${asset.path}.${Paths.SOUND_EXT}';
				
			default:
				trace("Assets Path: " + asset.path + " Base path: " + basePath);
				return basePath + asset.path;
		}
	}

	private function onAssetLoaded(asset:StageAssetData, success:Bool):Void
	{
		if (!isPreloadingAssets) return;
		
		loadedAssets++;
		loadingProgress = totalAssets > 0 ? loadedAssets / totalAssets : 1;
		
		updateLoadingUI();
		
		var status = success ? "loaded" : "failed";
		trace('Asset ${asset.path} $status (${loadedAssets}/${totalAssets})');
	}

	private function updateLoadingUI():Void
	{
		if (!isPreloadingAssets || totalAssets == 0) return;
		
		// Update progress bar
		if (loadBar != null) {
			FlxTween.tween(loadBar.scale, {x: loadingProgress}, 0.1);
		}
		
		// Update progress text
		var percentage = Math.floor(loadingProgress * 100);
		updateProgressText('Loading stage assets... ${percentage}%');
		
		// Update window title
		lime.app.Application.current.window.title = 'Funkin.avi - Loading ${percentage}%';
		
		// When loading is complete
		if (loadingProgress >= 1.0) {
			updateProgressText("Assets loaded! Starting game...");
			isPreloadingAssets = false;
		}
	}

	private function updateProgressText(text:String):Void
	{
		if (progressText != null) {
			progressText.text = text;
		}
	}
	
	function checkLoadSong(path:String)
	{
		if (!Assets.cache.hasSound(path))
		{
			var library = Assets.getLibrary("songs");
			final symbolPath = path.split(":").pop();
			var callback = callbacks.add("song:" + path);
			Assets.loadSound(path).onComplete(function (_) { callback(); });
		}
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

		if(weekDir != null && weekDir.length > 0 && weekDir != '') directory = weekDir;

		Paths.setCurrentLevel(directory);
		trace('Setting asset folder to ' + directory);

		var loaded:Bool = false;
		if (PlayState.SONG != null) {
			loaded = isSoundLoaded(getSongPath()) && (!PlayState.SONG.needsVoices || isSoundLoaded(getVocalPath())) && isLibraryLoaded('week_assets');
		}
		
		if (!loaded)
			return new LoadingState(target, stopMusic, directory);
		
		if (stopMusic && FlxG.sound.music != null)
			FlxG.sound.music.stop();
		
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