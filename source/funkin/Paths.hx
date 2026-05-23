package funkin;

import haxe.io.Path;

import openfl.media.Sound;

import flixel.FlxG;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.FlxGraphic;

/**
 * Primary class used to simplify retrieving and finding assets.
 */
class Paths
{
	#if ASSET_REDIRECT
	public static inline final trail = #if macos '../../../../../../../' #else '../../../../' #end;
	#end
	
	/**
	 * Primary asset directory
	 */
	public static inline final CORE_DIRECTORY = #if ASSET_REDIRECT trail + 'assets/game' #else 'assets' #end;
	
	/**
	 * Mod directory
	 */
	public static inline final MODS_DIRECTORY = #if ASSET_REDIRECT trail + 'content' #else 'content' #end;
	
	/**
	 * Default font used by the game for most things.
	 * 
	 * Can be changed
	 */
	public static var DEFAULT_FONT:String = 'vcr.ttf';
	
	/**
	 * Prefix that tells the game where certain UI elements are located.
	 */
	public static var COMBO_PREFIX:String = 'UI/combo/';
	
	public static var RATINGS_PREFIX:String = 'UI/ratings/';
	public static var COUNTDOWN_PREFIX:String = 'UI/countdown/';
	public static var UI_PREFIX:String = 'UI/';
	
	// , , ,
	@:allow(funkin.backend.FunkinCache)
	static var tempAtlasFramesCache:Map<String, FlxAtlasFrames> = []; // maybe instead of this make a txt cache ?
	
	/**
	 * Primary function used for pathing. In order it will check (Primary Mod Directory, Mods directory, Assets directory)
	 * @param file The Path to the file. extension included.
	 * @param parentFolder Parent folder to the file
	 * @param checkMods If true, will search through Mod directories
	 * @return The path to the file.
	 */
	public static function getPath(file:String, ?parentFolder:String, checkMods:Bool = false):String
	{
		if (parentFolder != null) file = '$parentFolder/$file';
		
		#if MODS_ALLOWED
		if (checkMods)
		{
			final modPath:String = modFolders(file);
			
			if (FileSystem.exists(modPath)) return modPath;
		}
		#end
		
		#if ASSET_REDIRECT
		final embedPath = getCorePath().replace(CORE_DIRECTORY, trail + 'assets/embeds') + file;
		if (FunkinAssets.exists(embedPath)) return embedPath;
		#end
		
		return getCorePath(file);
	}
	
	/**
	 * Inserts the primary asset path to the given file path
	 */
	public static inline function getCorePath(file:String = ''):String
	{
		return '$CORE_DIRECTORY/$file';
	}
	
	/**
	 * Searches for a .txt file within the `data` directory.
	 */
	public static inline function txt(key:String, ?parentFolder:String, checkMods:Bool = true):String
	{
		return getPath('data/$key.txt', parentFolder, checkMods);
	}
	
	/**
	 * Searches for a .xml file within the `data` directory.
	 */
	public static inline function xml(key:String, ?parentFolder:String, checkMods:Bool = true):String
	{
		return getPath('data/$key.xml', parentFolder, checkMods);
	}
	
	/**
	 * Searches for a .json file within the `songs` directory.
	 */
	public static inline function json(key:String, ?parentFolder:String, checkMods:Bool = true):String
	{
		return getPath('songs/$key.json', parentFolder, checkMods);
	}
	
	public static inline function noteskin(key:String, ?parentFolder:String, checkMods:Bool = true):String
	{
		var path = getPath('data/noteskins/$key.json', parentFolder, checkMods);
		if (!FunkinAssets.exists(path, TEXT)) path = getPath('noteskins/$key.json', parentFolder, checkMods);
		
		return path;
	}
	
	/**
	 * Searches for a .frag file within the `shaders` directory.
	 */
	public static inline function fragment(key:String, checkMods:Bool = true):String
	{
		return getPath('shaders/$key.frag', null, checkMods);
	}
	
	/**
	 * Searches for a .vert file within the `shaders` directory.
	 */
	public static inline function vertex(key:String, checkMods:Bool = true):String
	{
		return getPath('shaders/$key.vert', null, checkMods);
	}
	
	/**
	 * Searches for a video file wihin the `videos` directory.
	 * 
	 * Automatically will attempt to append .mp4, .mov, and .webm extensions.
	 */
	public static function video(key:String, ?ext:String, checkMods:Bool = true):String
	{
		final exts = ext != null ? [ext, 'mp4', 'mov', 'webm'] : ['mp4', 'mov', 'webm'];
		return findFileWithExts('videos/$key', exts, null, checkMods);
	}
	
	public static function textureAtlas(key:String, ?parentFolder:String, checkMods:Bool = true):String
	{
		return getPath('images/$key', parentFolder, checkMods);
	}
	
	/**
	 * Searches for a file within the `sounds` directory and caches a `Sound` instance.
	 * 
	 * Automatically will attempt to append .ogg and .wav extensions.
	 */
	public static function sound(key:String, ?parentFolder:String, checkMods:Bool = true):Sound
	{
		final key = findFileWithExts('sounds/$key', ['ogg', 'wav'], parentFolder, checkMods);
		
		return FunkinAssets.getSound(key);
	}
	
	public static inline function soundRandom(key:String, min:Int = 0, max:Int = 0, ?parentFolder:String, checkMods:Bool = true):Sound
	{
		return sound(key + FlxG.random.int(min, max), parentFolder, checkMods);
	}
	
	/**
	 * Searches for a file within the `music` directory and caches a `Sound` instance.
	 * 
	 * Automatically will attempt to append .ogg and .wav extensions.
	 */
	public static inline function music(key:String, ?parentFolder:String, checkMods:Bool = true):Sound
	{
		final key = findFileWithExts('music/$key', ['ogg', 'wav'], parentFolder, checkMods);
		
		return FunkinAssets.getSound(key);
	}
	
	public static inline function trackSwap(song:String, ?postFix:String, checkMods:Bool = true):Null<Sound> // not sure if this should be here
	{
		var name = sanitize(song);
		
		var songKey:String = '$name/Track';
		if (FunkinAssets.isDirectory(getPath('songs/$name/audio', null, checkMods))) songKey = '$name/audio/Track';
		
		if (postFix != null) songKey += '-$postFix';
		
		songKey = findFileWithExts('songs/$songKey', ['ogg', 'wav'], null, checkMods);
		
		trace(songKey);
		
		if (ClientPrefs.streamedMusic) return FunkinAssets.getVorbisSound(songKey);
		
		return FunkinAssets.getSoundUnsafe(songKey);
	}
	
	public static inline function voices(song:String, ?postFix:String, checkMods:Bool = true):Null<Sound>
	{
		var name = sanitize(song);
		
		var songKey:String = '$name/Voices';
		if (FunkinAssets.isDirectory(getPath('songs/$name/audio', null, checkMods))) songKey = '$name/audio/Voices';
		
		if (postFix != null) songKey += '-$postFix';
		
		songKey = findFileWithExts('songs/$songKey', ['ogg', 'wav'], null, checkMods);
		
		if (ClientPrefs.streamedMusic) return FunkinAssets.getVorbisSound(songKey);
		
		return FunkinAssets.getSoundUnsafe(songKey);
	}
	
	public static inline function inst(song:String, ?postFix:String, checkMods:Bool = true):Sound
	{
		var name = sanitize(song);
		
		var songKey:String = '$name/Inst';
		if (FunkinAssets.isDirectory(getPath('songs/$name/audio', null, checkMods))) songKey = '$name/audio/Inst';
		
		if (postFix != null) songKey += '-$postFix';
		
		songKey = findFileWithExts('songs/$songKey', ['ogg', 'wav'], null, checkMods);
		
		if (ClientPrefs.streamedMusic) return FunkinAssets.getVorbisSound(songKey) ?? FunkinAssets.getSound(songKey);
		
		return FunkinAssets.getSound(songKey);
	}
	
	/**
	 * Searches for a file within the `images` directory and caches a `FlxGraphic` instance.
	 */
	public static inline function image(key:String, ?parentFolder:String, allowGPU:Bool = true, checkMods:Bool = true):FlxGraphic
	{
		return FunkinAssets.getGraphic(getPath('images/$key.png', parentFolder, checkMods), true, allowGPU);
	}
	
	/**
	 * Searches for a font file wihin the `fonts` directory.
	 * 
	 * Automatically will attempt to append .ttf and .otf extensions.
	 */
	public static inline function font(key:String, checkMods:Bool = true):String
	{
		return findFileWithExts('fonts/$key', ['ttf', 'otf'], null, checkMods);
	}
	
	public static function findFileWithExts(key:String, exts:Array<String>, ?parentFolder:String, checkMods:Bool = true):String
	{
		for (ext in exts)
		{
			final joined = getPath('$key.$ext', parentFolder, checkMods);
			if (FunkinAssets.exists(joined)) return joined;
		}
		
		return getPath(key, parentFolder, checkMods); // assuming u mightve added a ext already
	}
	
	/**
	 * Attemps to get the text from a file. 
	 * 
	 * Will return a empty string if the file could not be found.
	 */
	public static function getTextFromFile(key:String, ?parentFolder:String, checkMods:Bool = true):String
	{
		key = getPath(key, parentFolder, checkMods);
		
		return FunkinAssets.exists(key) ? FunkinAssets.getContent(key) : '';
	}
	
	/**
	 * Convenience function to check if a file exists. handles getPath for you
	 */
	public static inline function fileExists(key:String, ?parentFolder:String, checkMods:Bool = true):Bool
	{
		return FunkinAssets.exists(getPath(key, parentFolder, checkMods));
	}
	
	public static inline function getMultiAtlas(keys:Array<String>, ?parentFolder:String, allowGPU:Bool = true, checkMods:Bool = true):FlxAtlasFrames // from psych
	{
		if (keys.length == 0) return null;
		
		final firstKey:Null<String> = keys.shift()?.trim();
		
		if (firstKey == null) return null;
		
		var frames = getAtlasFrames(firstKey, parentFolder, allowGPU, checkMods);
		
		if (keys.length != 0)
		{
			final originalCollection = frames;
			frames = new FlxAtlasFrames(originalCollection.parent);
			frames.addAtlas(originalCollection, true);
			for (i in keys)
			{
				final newFrames = getAtlasFrames(i.trim(), parentFolder, allowGPU, checkMods);
				if (newFrames != null)
				{
					frames.addAtlas(newFrames, false);
				}
			}
		}
		return frames;
	}
	
	/**
	 * Retrieves atlas frames from either `Sparrow`, `Aseprite` or `Packer` 
	 * 
	 * `Sparrow` has priority.
	 */
	public static inline function getAtlasFrames(key:String, ?parentFolder:String, allowGPU:Bool = true, checkMods:Bool = true):FlxAtlasFrames
	{
		final directPath = getPath('images/$key.png', parentFolder, checkMods).withoutExtension();
		
		final tempFrames = tempAtlasFramesCache.get(directPath);
		if (tempFrames != null)
		{
			return tempFrames;
		}
		
		final xmlPath = getPath('images/$key.xml', parentFolder, checkMods);
		final txtPath = getPath('images/$key.txt', parentFolder, checkMods);
		final jsonPath = getPath('images/$key.json', parentFolder, checkMods);
		
		final graphic = image(key, parentFolder, allowGPU, checkMods);
		
		// sparrow
		if (FunkinAssets.exists(xmlPath))
		{
			// until flixel does null safety
			@:nullSafety(Off)
			{
				final frames = FlxAtlasFrames.fromSparrow(graphic, FunkinAssets.getContent(xmlPath));
				if (frames != null) tempAtlasFramesCache.set(directPath, frames);
				return frames;
			}
		}
		
		if (FunkinAssets.exists(jsonPath))
		{
			//
			@:nullSafety(Off) // until flixel does null safety
			{
				final frames = FlxAtlasFrames.fromAseprite(graphic, FunkinAssets.getContent(jsonPath));
				if (frames != null) tempAtlasFramesCache.set(directPath, frames);
				return frames;
			}
		}
		
		@:nullSafety(Off) // until flixel does null safety
		{
			final frames = FlxAtlasFrames.fromSpriteSheetPacker(graphic, FunkinAssets.exists(txtPath) ? FunkinAssets.getContent(txtPath) : null);
			if (frames != null) tempAtlasFramesCache.set(directPath, frames);
			return frames;
		}
	}
	
	public static inline function getSparrowAtlas(key:String, ?parentFolder:String, ?allowGPU:Bool = true, checkMods:Bool = true):FlxAtlasFrames
	{
		final directPath = getPath('images/$key.png', parentFolder, checkMods).withoutExtension();
		final tempFrames = tempAtlasFramesCache.get(directPath);
		if (tempFrames != null)
		{
			return tempFrames;
		}
		
		final xmlPath = getPath('images/$key.xml', parentFolder, checkMods);
		@:nullSafety(Off) // until flixel does null safety
		{
			final frames = FlxAtlasFrames.fromSparrow(image(key, parentFolder, allowGPU, checkMods), FunkinAssets.exists(xmlPath) ? FunkinAssets.getContent(xmlPath) : null);
			if (frames != null) tempAtlasFramesCache.set(directPath, frames);
			return frames;
		}
	}
	
	public static inline function getPackerAtlas(key:String, ?parentFolder:String, ?allowGPU:Bool = true, checkMods:Bool = true)
	{
		final directPath = getPath('images/$key.png', parentFolder, checkMods).withoutExtension();
		final tempFrames = tempAtlasFramesCache.get(directPath);
		if (tempFrames != null)
		{
			return tempFrames;
		}
		
		final txtPath = getPath('images/$key.txt', parentFolder, checkMods);
		@:nullSafety(Off) // until flixel does null safety
		{
			final frames = FlxAtlasFrames.fromSpriteSheetPacker(image(key, parentFolder, allowGPU, checkMods), FunkinAssets.exists(txtPath) ? FunkinAssets.getContent(txtPath) : null);
			if (frames != null) tempAtlasFramesCache.set(directPath, frames);
			return frames;
		}
	}
	
	/**
	 * Removes all non alpha numeric chars and replaces spaces with `-` to lower in a given String.
	 * 
	 * Example: My Song Path! == my-song-path
	 */
	public static inline function sanitize(path:String):String
	{
		return ~/[^- a-zA-Z0-9..\/]+\//g.replace(path, '').replace(' ', '-').trim().toLowerCase();
	}
	
	/**
	 * Lists all files found within a given directory
	 * 
	 * if `checkMods`, they will be loaded in order of
	 * 
	 * `content/globalMods/`, `content/`, `content/currentMod/`.
	 */
	public static function listAllFilesInDirectory(directory:String, checkMods:Bool = true) // based of psychs Mods.directoriesWithFile
	{
		// todo maybe make this recursive ?
		var folders:Array<String> = [];
		var files:Array<String> = [];
		
		if (FunkinAssets.exists(getCorePath(directory))) folders.push(getCorePath(directory));
		
		#if MODS_ALLOWED
		if (checkMods)
		{
			for (mod in Mods.globalMods)
			{
				final folder = mods('$mod/$directory');
				if (FileSystem.exists(folder) && !folders.contains(folder)) folders.push(folder);
			}
			
			final folder = mods(directory);
			if (FileSystem.exists(folder) && !folders.contains(folder)) folders.push(folder);
			
			if (Mods.currentModDirectory != null && Mods.currentModDirectory.length > 0)
			{
				final folder = mods('${Mods.currentModDirectory}/$directory');
				if (FileSystem.exists(folder) && !folders.contains(folder)) folders.push(folder);
			}
		}
		#end
		
		for (folder in folders)
		{
			for (file in FunkinAssets.readDirectory(folder))
			{
				final path = Path.join([folder, file]);
				if (!files.contains(path)) files.push(path);
			}
		}
		
		return files;
	}
	
	#if MODS_ALLOWED
	/**
	 * Inserts the mod asset path to the given file path
	 */
	public static inline function mods(key:String = ''):String
	{
		return '$MODS_DIRECTORY/' + key;
	}
	
	/**
	 * Searches the primary loaded mod path and general mod path for a given file
	 */
	public static function modFolders(key:String):String
	{
		if (Mods.currentModDirectory != null && Mods.currentModDirectory.length > 0)
		{
			final fileToCheck:String = mods(Mods.currentModDirectory + '/' + key);
			// trace(fileToCheck);
			if (FileSystem.exists(fileToCheck))
			{
				return fileToCheck;
			}
		}
		
		for (mod in Mods.globalMods)
		{
			final fileToCheck:String = mods(mod + '/' + key);
			if (FileSystem.exists(fileToCheck)) return fileToCheck;
		}
		return mods(key);
	}
	#end
}
