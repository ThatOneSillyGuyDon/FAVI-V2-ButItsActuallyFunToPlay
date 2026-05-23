package funkin.data;

import flixel.FlxG;
import flixel.util.FlxSave;

import funkin.backend.Difficulty;

class Highscore
{
	static var scores:FlxSave;
	
	public static var weekScores:Map<String, Int> = new Map();
	public static var songScores:Map<String, Int> = new Map();
	public static var songRating:Map<String, Float> = new Map();
	
	public static function resetSong(song:String, diff:Int = 0):Void
	{
		var daSong:String = formatSong(song, diff);
		setScore(daSong, 0);
		setRating(daSong, 0);
	}
	
	public static function resetWeek(week:String, diff:Int = 0):Void
	{
		var daWeek:String = formatSong(week, diff);
		setWeekScore(daWeek, 0);
	}
	
	public static function saveScore(song:String, score:Int = 0, ?diff:Int = 0, ?rating:Float = -1):Void
	{
		var daSong:String = formatSong(song, diff);
		
		if (songScores.exists(daSong))
		{
			if (songScores.get(daSong) < score)
			{
				setScore(daSong, score);
				if (rating >= 0) setRating(daSong, rating);
			}
		}
		else
		{
			setScore(daSong, score);
			if (rating >= 0) setRating(daSong, rating);
		}
	}
	
	public static function saveWeekScore(week:String, score:Int = 0, ?diff:Int = 0):Void
	{
		var daWeek:String = formatSong(week, diff);
		
		if (weekScores.exists(daWeek))
		{
			if (weekScores.get(daWeek) < score) setWeekScore(daWeek, score);
		}
		else setWeekScore(daWeek, score);
	}
	
	/**
	 * YOU SHOULD FORMAT SONG WITH formatSong() BEFORE TOSSING IN SONG VARIABLE
	 */
	static function setScore(song:String, score:Int):Void
	{
		// Reminder that I don't need to format this song, it should come formatted!
		songScores.set(song, score);
		scores.data.songScores = songScores;
		scores.flush();
	}
	
	static function setWeekScore(week:String, score:Int):Void
	{
		// Reminder that I don't need to format this song, it should come formatted!
		weekScores.set(week, score);
		scores.data.weekScores = weekScores;
		scores.flush();
	}
	
	static function setRating(song:String, rating:Float):Void
	{
		// Reminder that I don't need to format this song, it should come formatted!
		songRating.set(song, rating);
		scores.data.songRating = songRating;
		scores.flush();
	}
	
	public static function formatSong(song:String, diff:Int):String
	{
		return Paths.sanitize(song) + '-' + Difficulty.getDifficultyFilePath(diff);
	}
	
	public static function getScore(song:String, diff:Int):Int
	{
		var daSong:String = formatSong(song, diff);
		if (!songScores.exists(daSong)) setScore(daSong, 0);
		
		return songScores.get(daSong);
	}
	
	public static function getRating(song:String, diff:Int):Float
	{
		var daSong:String = formatSong(song, diff);
		if (!songRating.exists(daSong)) setRating(daSong, 0);
		
		return songRating.get(daSong);
	}
	
	public static function getWeekScore(week:String, diff:Int):Int
	{
		var daWeek:String = formatSong(week, diff);
		if (!weekScores.exists(daWeek)) setWeekScore(daWeek, 0);
		
		return weekScores.get(daWeek);
	}
	
	public static function load():Void
	{
		if (scores.data.weekScores != null)
		{
			weekScores = scores.data.weekScores;
		}
		if (scores.data.songScores != null)
		{
			songScores = scores.data.songScores;
		}
		if (scores.data.songRating != null)
		{
			songRating = scores.data.songRating;
		}
	}
	
	public static function initSave():Void
	{
		scores = new FlxSave();
		
		if (scores.bind('scoreData', CoolUtil.getSavePath()) == false)
		{
			@:privateAccess
			{
				final file = FlxSave.validate(FlxG.stage.application.meta.get('file'));
				final path = SaveUtil.getPath('', '$file/scoreData');
				
				if (FileSystem.exists(path))
				{
					final corruptedPath = path.withoutExtension() + ' (corrupted) ${Date.now().toString().replace(':', '_')}.sol';
					FileSystem.rename(path, corruptedPath);
					
					trace('Save was corrupted. corrupted save was placed at $corruptedPath');
				}
			}
			
			scores.bind('scoreData', CoolUtil.getSavePath());
		}
	}
}

@:access(flixel.util.FlxSave)
private class SaveUtil
{
	static function getPath(localPath:String, name:String):String
	{
		// Avoid ever putting .sol files directly in AppData
		if (localPath == "") localPath = getDefaultLocalPath();
		
		var directory = lime.system.System.applicationStorageDirectory;
		var path = haxe.io.Path.normalize('$directory/../../../$localPath') + "/";
		
		name = StringTools.replace(name, "//", "/");
		name = StringTools.replace(name, "//", "/");
		
		if (StringTools.startsWith(name, "/"))
		{
			name = name.substr(1);
		}
		
		if (StringTools.endsWith(name, "/"))
		{
			name = name.substring(0, name.length - 1);
		}
		
		if (name.indexOf("/") > -1)
		{
			var split = name.split("/");
			name = "";
			
			for (i in 0...(split.length - 1))
			{
				name += split[i] + "/";
			}
			
			name += split[split.length - 1];
		}
		
		return path + name + ".sol";
	}
	
	static function getDefaultLocalPath()
	{
		var meta = openfl.Lib.current.stage.application.meta;
		var path = meta["company"];
		if (path == null || path == "") path = "HaxeFlixel";
		else path = FlxSave.validate(path);
		
		return path;
	}
}
