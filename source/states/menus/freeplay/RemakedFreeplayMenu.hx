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

	var storyMenuSongs = [
		'delvish-deal',
		'isolated',
		'lunacy',
		'delusional'
	];

	var legacySongs = [
		''
	];

	var freeplaySongs = [
		''
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
