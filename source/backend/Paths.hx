package backend;

import flixel.graphics.frames.FlxFrame.FlxFrameAngle;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.FlxGraphic;
import flixel.math.FlxRect;
import flixel.system.FlxAssets;

import openfl.display.BitmapData;
import openfl.display3D.textures.RectangleTexture;
import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;
import openfl.system.System;
import openfl.geom.Rectangle;

import lime.utils.Assets;
import flash.media.Sound;

import haxe.Json;

@:access(openfl.display.BitmapData)
class Paths
{
	inline public static var SOUND_EXT = "ogg";
	inline public static var VIDEO_EXT = "mp4";

	private static var pathCache:Map<String, String> = [];
	private static var bitmapDataCache:Map<String, BitmapData> = [];
	private static var atlasCache:Map<String, FlxAtlasFrames> = [];
	private static var videoCache:Map<String, Dynamic> = [];
	private static var videoPaths:Map<String, String> = [];
	
	public static var dumpExclusions:Array<String> = ['assets/shared/music/freakyMenu.$SOUND_EXT'];

	// Cache statistics
	public static var cacheHits:Int = 0;
	public static var cacheMisses:Int = 0;
	public static var maxCacheSize:Int = 1000;
	public static var maxVideoCacheSize:Int = 10;
	
	// Video cache access times for LRU cleanup
	private static var videoAccessTimes:Map<String, Float> = [];

	public static function excludeAsset(key:String) {
		if (!dumpExclusions.contains(key))
			dumpExclusions.push(key);
	}

	// Enhanced memory clearing with video cache support
	public static function clearUnusedMemory()
	{
		for (key in currentTrackedAssets.keys())
		{
			if (!localTrackedAssets.contains(key) && !dumpExclusions.contains(key))
			{
				destroyGraphic(currentTrackedAssets.get(key));
				currentTrackedAssets.remove(key);
				
				if (bitmapDataCache.exists(key)) {
					var bitmap = bitmapDataCache.get(key);
					if (bitmap != null) bitmap.dispose();
					bitmapDataCache.remove(key);
				}
			}
		}

		for (key in atlasCache.keys()) {
			if (!localTrackedAssets.contains(key)) {
				atlasCache.remove(key);
			}
		}

		// Clear unused videos - more aggressive cleanup due to size
		for (key in videoCache.keys()) {
			if (!localTrackedAssets.contains(key)) {
				var video = videoCache.get(key);
				destroyVideo(video);
				videoCache.remove(key);
				videoAccessTimes.remove(key);
			}
		}

		System.gc();
	}

	public static var localTrackedAssets:Array<String> = [];

	@:access(flixel.system.frontEnds.BitmapFrontEnd._cache)
	public static function clearStoredMemory()
	{
		// Clear FlxG bitmap cache
		for (key in FlxG.bitmap._cache.keys())
		{
			if (!currentTrackedAssets.exists(key))
				destroyGraphic(FlxG.bitmap.get(key));
		}

		// Clear sound cache
		for (key => asset in currentTrackedSounds)
		{
			if (!localTrackedAssets.contains(key) && !dumpExclusions.contains(key) && asset != null)
			{
				Assets.cache.clear(key);
				currentTrackedSounds.remove(key);
			}
		}
		
		// Clear all caches including video caches
		pathCache.clear();
		bitmapDataCache.clear();
		atlasCache.clear();
		clearVideoCache();
		
		localTrackedAssets = [];
		#if !html5 openfl.Assets.cache.clear("songs"); #end
	}

	// Video cache management functions
	public static function clearVideoCache():Void
	{
		for (key => video in videoCache) {
			destroyVideo(video);
		}
		videoCache.clear();
		videoPaths.clear();
		videoAccessTimes.clear();
	}

	private static function destroyVideo(video:Dynamic):Void
	{
		if (video == null) return;
		
		// Handle different video types - adjust based on your video implementation
		try {
			if (Reflect.hasField(video, "destroy")) {
				Reflect.callMethod(video, Reflect.field(video, "destroy"), []);
			} else if (Reflect.hasField(video, "kill")) {
				Reflect.callMethod(video, Reflect.field(video, "kill"), []);
			}
		} catch (e:Dynamic) {
			trace('Error destroying video: $e');
		}
	}

	private static function manageVideoCacheSize():Void
	{
		var cacheSize = Lambda.count(videoCache);
		
		if (cacheSize >= maxVideoCacheSize) {
			// Remove least recently used videos
			var sortedKeys = [for (key in videoCache.keys()) key];
			sortedKeys.sort((a, b) -> {
				var timeA = videoAccessTimes.exists(a) ? videoAccessTimes.get(a) : 0;
				var timeB = videoAccessTimes.exists(b) ? videoAccessTimes.get(b) : 0;
				return timeA < timeB ? -1 : (timeA > timeB ? 1 : 0);
			});
			
			// Remove oldest entries
			var removeCount = Math.ceil(cacheSize * 0.3); // Remove 30% when cache is full
			for (i in 0...removeCount) {
				if (i >= sortedKeys.length) break;
				var key = sortedKeys[i];
				
				if (!localTrackedAssets.contains(key)) {
					var video = videoCache.get(key);
					destroyVideo(video);
					videoCache.remove(key);
					videoAccessTimes.remove(key);
					videoPaths.remove(key);
				}
			}
		}
	}

	static public var currentLevel:String;
	static public function setCurrentLevel(name:String)
	{
		currentLevel = name.toLowerCase();
	}

	public static function getPath(file:String, ?type:AssetType = TEXT, ?library:Null<String> = null, ?modsAllowed:Bool = false):String
	{
		var cacheKey = '$file-$type-$library-$modsAllowed';
		
		if (pathCache.exists(cacheKey)) {
			cacheHits++;
			return pathCache.get(cacheKey);
		}
		
		cacheMisses++;
		var resolvedPath:String;

		if (library != null) {
			resolvedPath = getLibraryPath(file, library);
		} else if (currentLevel != null) {
			var levelPath:String = '';
			if(currentLevel != 'shared') {
				levelPath = getLibraryPathForce(file, 'week_assets', currentLevel);
				if (OpenFlAssets.exists(levelPath, type)) {
					resolvedPath = levelPath;
				} else {
					resolvedPath = getSharedPath(file);
				}
			} else {
				resolvedPath = getSharedPath(file);
			}
		} else {
			resolvedPath = getSharedPath(file);
		}
		
		pathCache.set(cacheKey, resolvedPath);
		return resolvedPath;
	}

	static public function getLibraryPath(file:String, library = "shared")
	{
		return if (library == "shared") getSharedPath(file); else getLibraryPathForce(file, library);
	}

	inline static function getLibraryPathForce(file:String, library:String, ?level:String)
	{
		if(level == null) level = library;
		var returnPath = '$library:assets/$level/$file';
		return returnPath;
	}

	inline public static function getSharedPath(file:String = '')
	{
		return 'assets/shared/$file';
	}

	inline static public function txt(key:String, ?library:String)
	{
		return getPath('data/$key.txt', TEXT, library);
	}

	inline static public function xml(key:String, ?library:String)
	{
		return getPath('data/$key.xml', TEXT, library);
	}

	inline static public function json(key:String, ?library:String)
	{
		return getPath('data/$key.json', TEXT, library);
	}

	inline static public function shaderFragment(key:String, ?library:String)
	{
		return getPath('shaders/$key.frag', TEXT, library);
	}
	
	inline static public function shaderVertex(key:String, ?library:String)
	{
		return getPath('shaders/$key.vert', TEXT, library);
	}
	
	inline static public function lua(key:String, ?library:String)
	{
		return getPath('$key.lua', TEXT, library);
	}

	// Enhanced video function with path caching
	static public function video(key:String):String
	{
		// Check video path cache first
		if (videoPaths.exists(key)) {
			cacheHits++;
			return videoPaths.get(key);
		}
		
		cacheMisses++;
		var resolvedPath:String;
		
		resolvedPath = 'assets/videos/$key.$VIDEO_EXT';
		
		// Cache the resolved path
		videoPaths.set(key, resolvedPath);
		return resolvedPath;
	}

	// New function to cache video objects (like VideoSprite instances)
	public static function cacheVideo(key:String, videoObject:Dynamic):Void
	{
		if (videoObject == null) return;
		
		// Update access time
		videoAccessTimes.set(key, Date.now().getTime());
		
		// Check if we need to clean up cache
		manageVideoCacheSize();
		
		// Cache the video object
		videoCache.set(key, videoObject);
		localTrackedAssets.push(key);
		
		trace('Cached video: $key');
	}

	// Function to retrieve cached video objects
	public static function getCachedVideo(key:String):Dynamic
	{
		if (!videoCache.exists(key)) {
			cacheMisses++;
			return null;
		}
		
		// Update access time for LRU
		videoAccessTimes.set(key, Date.now().getTime());
		cacheHits++;
		
		return videoCache.get(key);
	}

	// Function to remove specific video from cache
	public static function removeCachedVideo(key:String):Void
	{
		if (videoCache.exists(key)) {
			var video = videoCache.get(key);
			destroyVideo(video);
			videoCache.remove(key);
			videoAccessTimes.remove(key);
			videoPaths.remove(key);
			
			// Remove from local tracked assets
			if (localTrackedAssets.contains(key)) {
				localTrackedAssets.remove(key);
			}
		}
	}

	static public function soundString(key:String, ?library:String):String
	{
		return getPath('sounds/$key.$SOUND_EXT', SOUND, library);
	}

	static public function sound(key:String, ?library:String):Sound
	{
		var sound:Sound = returnSound('sounds', key, library);
		return sound;
	}

	inline static public function soundRandom(key:String, min:Int, max:Int, ?library:String)
	{
		return sound(key + FlxG.random.int(min, max), library);
	}

	inline static public function music(key:String, ?library:String):Sound
	{
		var file:Sound = returnSound('music', key, library);
		return file;
	}

	inline static public function voices(song:String, postfix:String = null, diff:String = null):Any
	{
		var songKey:String = '${formatToSongPath(song)}/Voices';
		if(postfix != null) songKey += '-' + postfix;
		if(diff != null) songKey += '-' + diff;
		var voices = returnSound(null, songKey, 'songs');
		return voices;
	}

	inline static public function inst(song:String, diff:String = null):Any
	{
		var songKey:String = '${formatToSongPath(song)}/Inst';
		if(diff != null) songKey += '-' + diff;
		var inst = returnSound(null, songKey, 'songs');
		return inst;
	}

	public static var currentTrackedAssets:Map<String, FlxGraphic> = [];
	
	static public function image(key:String, ?library:String = null, ?allowGPU:Bool = true):FlxGraphic
	{
		var bitmap:BitmapData = null;
		var file:String = null;

		{
			file = getPath('images/$key.png', IMAGE, library);
			if (currentTrackedAssets.exists(file))
			{
				localTrackedAssets.push(file);
				cacheHits++;
				return currentTrackedAssets.get(file);
			}
			else if (OpenFlAssets.exists(file, IMAGE))
				bitmap = OpenFlAssets.getBitmapData(file);
		}

		if (bitmap != null)
		{
			var retVal = cacheBitmap(file, library, bitmap, allowGPU);
			if(retVal != null) return retVal;
		}

		trace('oh no its returning null NOOOO ($file)');
		return null;
	}

	inline static public function imageAlbum(key:String, ?library:String):FlxGraphic
	{
		var returnAsset:FlxGraphic = returnAlbumGraphic('Funkin_avi/pause/songs/$key', library);
		return returnAsset;
	}

	public static function returnAlbumGraphic(key:String, ?library:String, ?allowGPU:Bool = true):FlxGraphic {
		var bitmap:BitmapData = null;
		var file:String = null;
		{
			file = getPath('images/$key.png', IMAGE, library);
			if (currentTrackedAssets.exists(file))
			{
				localTrackedAssets.push(file);
				cacheHits++;
				return currentTrackedAssets.get(file);
			}
			else if (OpenFlAssets.exists(file, IMAGE))
				bitmap = OpenFlAssets.getBitmapData(file);
		}

		if (bitmap != null)
		{
			var retVal = cacheBitmap(file, library, bitmap, allowGPU);
			if(retVal != null) return retVal;
		}

		trace('$file returned null, using placeholder album!');
		return imageAlbum('unknown-song');
	}

	public static function cacheBitmap(key:String, ?parentFolder:String = null, ?bitmap:BitmapData, ?allowGPU:Bool = true):FlxGraphic
	{
		// Check bitmap data cache first
		if (bitmap == null && bitmapDataCache.exists(key))
		{
			bitmap = bitmapDataCache.get(key);
			cacheHits++;
		}
		
		if (bitmap == null)
		{
			cacheMisses++;
			var file:String = getPath(key, IMAGE, parentFolder, true);
			
			if (OpenFlAssets.exists(file, IMAGE))
				bitmap = OpenFlAssets.getBitmapData(file);

			if (bitmap == null)
			{
				trace('oh no its returning null NOOOO ($file)');
				return null;
			}
			
			// Cache the bitmap data
			bitmapDataCache.set(key, bitmap);
			manageCacheSize();
		}

		// GPU optimization - Fixed to avoid readonly property assignment
		if (allowGPU && ClientPrefs.data.cacheOnGPU && bitmap.image != null)
		{
			bitmap.lock();
			if (bitmap.__texture == null)
			{
				bitmap.image.premultiplied = true;
				bitmap.getTexture(FlxG.stage.context3D);
			}
			bitmap.getSurface();
			bitmap.disposeImage();
			// Removed readonly property assignments: bitmap.image.data = null; bitmap.image = null;
			bitmap.readable = true;
		}

		var graph:FlxGraphic = FlxGraphic.fromBitmapData(bitmap, false, key);
		graph.persist = true;
		graph.destroyOnNoUse = false;

		currentTrackedAssets.set(key, graph);
		localTrackedAssets.push(key);

		//trace('cacheBitmap key=' + key + ' parentFolder=' + parentFolder);
		return graph;
	}

	private static function manageCacheSize() {
		var cacheSize = 0;
		for (key in bitmapDataCache.keys()) {
			cacheSize++;
		}
		
		if (cacheSize > maxCacheSize) {
			var keysToRemove = [];
			var count = 0;
			var removeCount = Math.floor(maxCacheSize * 0.25);
			
			for (key in bitmapDataCache.keys()) {
				if (count >= removeCount) break;
				if (!localTrackedAssets.contains(key)) {
					keysToRemove.push(key);
					count++;
				}
			}
			
			for (key in keysToRemove) {
				var bitmap = bitmapDataCache.get(key);
				if (bitmap != null) bitmap.dispose();
				bitmapDataCache.remove(key);
			}
		}
	}


	static public function getTextFromFile(key:String, ?ignoreMods:Bool = false):String
	{
		#if sys
		if (FileSystem.exists(getSharedPath(key)))
			return File.getContent(getSharedPath(key));

		if (currentLevel != null)
		{
			var levelPath:String = '';
			if(currentLevel != 'shared') {
				levelPath = getLibraryPathForce(key, 'week_assets', currentLevel);
				if (FileSystem.exists(levelPath))
					return File.getContent(levelPath);
			}
		}
		#end		
		var path:String = getPath(key, TEXT);
		if(OpenFlAssets.exists(path, TEXT)) {
			try {
				return Assets.getText(path);
			} catch (e:Dynamic) {
				trace('Failed to load text asset: $path - Error: $e');
				return null;
			}
		}
		
		//trace('Text file not found: $key (resolved path: $path)');
		return null;
	}

	inline static public function font(key:String)
	{
		return 'assets/fonts/$key';
	}

	inline static function destroyGraphic(graphic:FlxGraphic)
	{
		if (graphic != null && graphic.bitmap != null && graphic.bitmap.__texture != null)
			graphic.bitmap.__texture.dispose();
		FlxG.bitmap.remove(graphic);
	}

	public static function fileExists(key:String, type:AssetType, ?ignoreMods:Bool = false, ?library:String = null)
	{
		if(OpenFlAssets.exists(getPath(key, type, library, false))) {
			return true;
		}
		return false;
	}

	static public function getAtlas(key:String, ?library:String = null, ?allowGPU:Bool = true):FlxAtlasFrames
	{
		var cacheKey = '$key-$library-$allowGPU';
		
		if (atlasCache.exists(cacheKey)) {
			cacheHits++;
			return atlasCache.get(cacheKey);
		}
		
		cacheMisses++;
		var useMod = false;
		var imageLoaded:FlxGraphic = image(key, library, allowGPU);
		var atlas:FlxAtlasFrames = null;

		var myXml:Dynamic = getPath('images/$key.xml', TEXT, library, true);
		if(OpenFlAssets.exists(myXml))
		{
			atlas = FlxAtlasFrames.fromSparrow(imageLoaded, myXml);
		}
		else
		{
			var myJson:Dynamic = getPath('images/$key.json', TEXT, library, true);
			if(OpenFlAssets.exists(myJson))
			{
				atlas = FlxAtlasFrames.fromTexturePackerJson(imageLoaded, myJson);
			}
		}
		
		if (atlas == null) {
			atlas = getPackerAtlas(key, library);
		}
		
		// Cache the result
		if (atlas != null) {
			atlasCache.set(cacheKey, atlas);
		}
		
		return atlas;
	}

	inline static public function getSparrowAtlas(key:String, ?library:String = null, ?allowGPU:Bool = true):FlxAtlasFrames
	{
		var imageLoaded:FlxGraphic = image(key, library, allowGPU);
		
		return FlxAtlasFrames.fromSparrow(imageLoaded, getPath('images/$key.xml', library));
	}

	inline static public function getPackerAtlas(key:String, ?library:String = null, ?allowGPU:Bool = true):FlxAtlasFrames
	{
		var imageLoaded:FlxGraphic = image(key, library, allowGPU);
		
		return FlxAtlasFrames.fromSpriteSheetPacker(imageLoaded, getPath('images/$key.txt', library));
	}

	inline static public function getAsepriteAtlas(key:String, ?library:String = null, ?allowGPU:Bool = true):FlxAtlasFrames
	{
		var imageLoaded:FlxGraphic = image(key, library, allowGPU);
		
		return FlxAtlasFrames.fromTexturePackerJson(imageLoaded, getPath('images/$key.json', library));
	}

	inline static public function formatToSongPath(path:String) {
		final invalidChars = ~/[~&;:<>#\s]/g;
		final hideChars = ~/[.,'"%?!]/g;

		return hideChars.replace(invalidChars.replace(path, '-'), '').trim().toLowerCase();
	}

	public static var currentTrackedSounds:Map<String, Sound> = [];
	
	public static function returnSound(path:Null<String>, key:String, ?library:String):Sound {
		
		var gottenPath:String = '$key.$SOUND_EXT';
		if(path != null) gottenPath = '$path/$gottenPath';
		gottenPath = getPath(gottenPath, SOUND, library);
		gottenPath = gottenPath.substring(gottenPath.indexOf(':') + 1, gottenPath.length);
		
		if(!currentTrackedSounds.exists(gottenPath))
		{
			var retKey:String = (path != null) ? '$path/$key' : key;
			retKey = ((path == 'songs') ? 'songs:' : '') + getPath('$retKey.$SOUND_EXT', SOUND, library);
			if(OpenFlAssets.exists(retKey, SOUND))
			{
				currentTrackedSounds.set(gottenPath, OpenFlAssets.getSound(retKey));
			}
		}
		localTrackedAssets.push(gottenPath);
		return currentTrackedSounds.get(gottenPath);
	}

	// Enhanced cache statistics functions - now includes video cache stats
	public static function getCacheEfficiency():Float {
		var total = cacheHits + cacheMisses;
		return total > 0 ? (cacheHits / total) * 100 : 0;
	}
	
	public static function getCacheStats():{hits:Int, misses:Int, efficiency:Float, videoCacheSize:Int, videoCacheLimit:Int} {
		return {
			hits: cacheHits,
			misses: cacheMisses,
			efficiency: getCacheEfficiency(),
			videoCacheSize: Lambda.count(videoCache),
			videoCacheLimit: maxVideoCacheSize
		};
	}
	
	public static function resetCacheStats() {
		cacheHits = 0;
		cacheMisses = 0;
	}

	// Video cache configuration
	public static function setVideoCacheLimit(limit:Int):Void {
		maxVideoCacheSize = limit;
		manageVideoCacheSize(); // Clean up if current size exceeds new limit
	}

	#if flxanimate
	public static function loadAnimateAtlas(spr:FlxAnimate, folderOrImg:Dynamic, spriteJson:Dynamic = null, animationJson:Dynamic = null)
	{
		var changedAnimJson = false;
		var changedAtlasJson = false;
		var changedImage = false;
		
		if(spriteJson != null)
		{
			changedAtlasJson = true;
			spriteJson = File.getContent(spriteJson);
		}

		if(animationJson != null) 
		{
			changedAnimJson = true;
			animationJson = File.getContent(animationJson);
		}

		// is folder or image path
		if(Std.isOfType(folderOrImg, String))
		{
			var originalPath:String = folderOrImg;
			for (i in 0...10)
			{
				var st:String = '$i';
				if(i == 0) st = '';

				if(!changedAtlasJson)
				{
					spriteJson = getTextFromFile('images/$originalPath/spritemap$st.json');
					if(spriteJson != null)
					{
						changedImage = true;
						changedAtlasJson = true;
						folderOrImg = Paths.image('$originalPath/spritemap$st');
						break;
					}
				}
				else if(Paths.fileExists('images/$originalPath/spritemap$st.png', IMAGE))
				{
					changedImage = true;
					folderOrImg = Paths.image('$originalPath/spritemap$st');
					break;
				}
			}

			if(!changedImage)
			{
				changedImage = true;
				folderOrImg = Paths.image(originalPath);
			}

			if(!changedAnimJson)
			{
				changedAnimJson = true;
				animationJson = getTextFromFile('images/$originalPath/Animation.json');
			}
		}

		spr.loadAtlasEx(folderOrImg, spriteJson, animationJson);
	}
	#end
}