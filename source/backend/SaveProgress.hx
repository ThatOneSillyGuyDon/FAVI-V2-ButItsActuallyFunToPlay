package backend;

import flixel.FlxG;
import flixel.util.FlxSave;
import flixel.input.keyboard.FlxKey;
import flixel.graphics.FlxGraphic;

class SaveProgress {

	public static var additionalHealth:Int = 0;
	// ["songName", "Locked"], 

	/* * Note To Myself:
	 * 3 variables for the sencond option:
	 * Locked, Unlocked, Beated.
	*/

	public static var songsStuff:Array<Array<Dynamic>> = [

		// Freeplay Mode
		["Critical-Hit", "Locked"], 
		
		["Illusioned-Place", "Locked"],
		["Cybernetic-Attack", "Locked"], 
		["Ink-and-Light", "Locked"], 
		["rebrushed", "Locked"],
		["Blotling-Malovence", "Locked"],
		["Book.", "Locked"],
		["Silver-Screen", "Locked"],
		["Legacy-and-Shame", "Locked"]
	];

	public static var curStorySong:String = ""; // Episode 1
	public static var curStoryWeek2:String = ""; // Episode 2

	public static var shopTickets:Int = 0;
	
	public static function saveThing() {
		
		for (i in 0...songsStuff.length) { 
            FlxG.save.data.songsStuff = songsStuff;
        }
        
		FlxG.save.data.shopTickets = shopTickets;
		FlxG.save.data.additionalHealth = additionalHealth;
		FlxG.save.data.curStorySong = curStorySong;

		FlxG.save.data.curStoryWeek2 = curStoryWeek2;
		FlxG.save.flush();
	}
	
	public static function loadProgress() {
		if (songsStuff != null) {
			for (i in 0...songsStuff.length){
				if(FlxG.save.data.songsStuff != null &&  i < FlxG.save.data.songsStuff.length && FlxG.save.data.songsStuff[i] != null && FlxG.save.data.songsStuff[i][1] != null) {
					songsStuff[i][1] = FlxG.save.data.songsStuff[i][1];
				}
			}
		}

		if(FlxG.save.data.shopTickets != null) // me when null when me when null when null when me when null when null when me when null when null when me when null when null when me when null when null when me when null 
			shopTickets = FlxG.save.data.shopTickets;

		if(FlxG.save.data.curStorySong != null)
			curStorySong = FlxG.save.data.curStorySong;

		if (FlxG.save.data.additionalHealth != null)
			additionalHealth = FlxG.save.data.additionalHealth;
		
		if(FlxG.save.data.curStoryWeek2 != null)
			curStoryWeek2 = FlxG.save.data.curStoryWeek2;
	}
}