// Will work on it tommorow.
package states.menus.freeplay;

import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import lime.app.Application;
import flixel.input.keyboard.FlxKey;

class RemakedFreeplayMenu extends MusicBeatState
{
	var curSelected:Int = 0;
	var songslimit:Int = 0; // basicaly it will make the choosing freeplay songs loop 
	
	/* Example code
		if (curSelected == songslimit || curSelected > songslimit)
		{
			curSelected = 0;
		}
	*/

	var storyMenuSongs:Array<Array<Dynamic>> = [
		['Devilish Deal', 1, "minnie", FlxColor.fromRGB(65, 88, 94), 'obscurity', 'EASY', FlxColor.WHITE],
		['Isolated', 1, "avier", FlxColor.fromRGB(60, 60, 60), 'obscurity', 'EASY', FlxColor.WHITE],
		['Lunacy', 1, "lunaavier", FlxColor.fromRGB(69, 54, 54), 'obscurity', 'NORMAL', FlxColor.fromRGB(255, 220, 220)],
		['Delusional', 3, 'deluavier', FlxColor.fromRGB(79, 32, 32), 'FR3SHMoure', 'INSANE', FlxColor.fromRGB(255, 110, 110)]
	];

	//i think you get the idea
	var legacySongs:Array<Array<Dynamic>> = [
		['Isolated-Legacy', 3, (GameData.legacyILock != 'unlocked' && GameData.legacyILock != 'beaten' ? 'untouched-song' : 'mickey-legacy'), FlxColor.fromRGB(60, 60, 60), 'Toko & obscurity', 'NORMAL', FlxColor.fromRGB(255, 220, 220)]
	];

	var freeplaySongs:Array<Array<Dynamic>> = [
		['Hunted', 3, (GameData.huntedLock != 'unlocked' && GameData.huntedLock != 'beaten' ? 'mysteryfp' : 'goofy'), FlxColor.fromRGB(94, 28, 35), 'JBlitz', 'NORMAL', FlxColor.fromRGB(255, 220, 220)]
	];


	override function create()
	{

		super.create();
	}


	override function update(elapsed:Float)
	{

		super.update(elapsed);

	}

}
