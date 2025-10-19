package backend;

import flixel.FlxG;
import flixel.util.FlxSave;
import flixel.input.keyboard.FlxKey;
import flixel.graphics.FlxGraphic;

class SaveProgress {

	public static var curStorySong:String = ""; // Episode 1
	public static var curStoryWeek2:String = ""; // Episode 2

	public static function saveThing() {
		
		FlxG.save.data.curStorySong = curStorySong;

		FlxG.save.data.curStoryWeek2 = curStoryWeek2;
		FlxG.save.flush();
	}
	
	public static function loadProgress() {
		if(FlxG.save.data.curStorySong != null)
			curStorySong = FlxG.save.data.curStorySong;

		if(FlxG.save.data.curStoryWeek2 != null)
			curStoryWeek2 = FlxG.save.data.curStoryWeek2;
	}
}