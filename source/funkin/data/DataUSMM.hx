package funkin.data;

import flixel.util.FlxSave;

class DataUSMM
{
	static var usmmData:FlxSave;
	
	public static var isFakeout:Bool;
	public static var hasSeenRandy:Bool;
	
	// for checkpoints, in the case the user decided to quit mid-game or crashed somehow (most likely the first scenario)
	public static var episode1Check:Array<Bool> = [];
	
	// first bool is for if you've seen the song title and art, second determines your completion + bio unlock
	public static var freeplayContent:Map<String, Array<Bool>> = [];
	
	// for bios menu, episode1Check & freeplayContent save variables will update this variable
	public static var unlockedBios:Array<Bool> = [];
	
	public static function prepareData()
	{
		usmmData = new FlxSave();
		
		if (usmmData.bind('usmmProgress', CoolUtil.getSavePath()) == false)
		{
			@:privateAccess
			{
				final file = FlxSave.validate(FlxG.stage.application.meta.get('file'));
				final path = SaveUtil.getPath('', '$file/usmmProgress');
				
				if (FileSystem.exists(path))
				{
					final corruptedPath = path.withoutExtension() + ' (corrupted) ${Date.now().toString().replace(':', '_')}.sol';
					FileSystem.rename(path, corruptedPath);
					
					trace('Save was corrupted. corrupted save was placed at $corruptedPath');
				}
			}
			
			usmmData.bind('usmmProgress', CoolUtil.getSavePath());
		}
	}
	
	public static function saveData()
	{
		if (usmmData != null)
		{
			usmmData.data.isFakeout = isFakeout;
			usmmData.data.hasSeenRandy = hasSeenRandy;
			usmmData.data.episode1Check = episode1Check;
			usmmData.data.freeplayContent = freeplayContent;
			usmmData.data.unlockedBios = unlockedBios;
			
			trace("data saved successfully");
		}
		
		usmmData.flush();
	}
	
	public static function loadData()
	{
		if (usmmData != null)
		{
			isFakeout = usmmData.data.isFakeout ?? true;
			hasSeenRandy = usmmData.data.hasSeenRandy ?? false;
			if (usmmData.data.episode1Check != null) episode1Check = usmmData.data.episode1Check;
			freeplayContent = usmmData.data.episode1Check ?? [
				"the jester" => [false, false],
				"repent your sins" => [false, false],
				"muckney's party bash" => [false, false],
				"odd encounter" => [false, false]
			];
			if (usmmData.data.unlockedBios != null) unlockedBios = usmmData.data.unlockedBios;
			
			trace("data loaded successfully");
		}
		
		saveData();
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
