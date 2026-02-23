package backend.data;

import flixel.FlxG;
import flixel.util.FlxSave;

using StringTools;
private enum DATA_CHECK_TYPE
{
	NO_MALFUNCTION;
	ALL;
}

class SaveData {

    public static var unlockFreeplay:Bool = false;

    public static var storySongs:Array<Array<Dynamic>> = [ 
        // unlocked, locked, beaten
        ['Devilish Deal'],
        ['Isolated'],
        ['Lunacy'],
        ['Delusional']
    ];

    // unlocked locked beaten
    public static var freeplaySongs:Array<Array<Dynamic>> = [
        ['Hunted','locked', 'Musican'],
        ['Malfunction','locked'],
        ['Bless','locked'],
        ['Scrapped','locked'],
        ["Don't Cross!",'locked'],
        ['War Dilemma','locked'],
        ['Twisted Grins','locked'],
        ['Mercy','locked'],
        ['Neglection','locked'],
        ['Cycled Sins','locked'],
        ['Whimsical Bar Blues','locked'],
        ['Malfunction', 'locked'],
        ['Birthday','locked']
    ];

    public static function saveData() {
		
		for (i in 0...freeplaySongs.length) { 
            FlxG.save.data.freeplaySongs = freeplaySongs;
        }
        
		FlxG.save.flush();
	}

    	
	public static function loadData() {
		if (freeplaySongs != null) {
			for (i in 0...freeplaySongs.length){
				if(FlxG.save.data.freeplaySongs != null &&  i < FlxG.save.data.freeplaySongs.length && FlxG.save.data.freeplaySongs[i] != null && FlxG.save.data.freeplaySongs[i][1] != null) {
					freeplaySongs[i][1] = FlxG.save.data.freeplaySongs[i][1];
				}
			}
		}
    }
}