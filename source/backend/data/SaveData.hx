package backend.data;

using StringTools;
private enum DATA_CHECK_TYPE
{
	NO_MALFUNCTION;
	ALL;
}

/**
 * So Basicaly, GameData kinda had some problems in V2 release, and just to make it clear etc,
 * i decided to remake it all -- (MalyPlus)
 * 
 * Blame goober for making me delusional.
 */

class SaveData {
    
    public static var unlockFreeplay:String = 'locked';
    public static var currentStorySong:String = "Devilish Deal";
    public static var storySongs:Array<Array<Dynamic>> = [ 
        // unlocked, locked, beaten
        ['Devilish Deal'],
        ['Isolated'],
        ['Lunacy'],
        ['Delusional']
    ];

    public static var addMalfunction:Bool = false;
    public static var addBirthday:String = 'invited';
    public static var seenWarning:Bool = false;

    // unlocked locked beaten
    public static var freeplaySongs:Array<Array<String>> = [
        ['Hunted','locked'],
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
        FlxG.save.data.currentStorySong = currentStorySong;
        FlxG.save.data.unlockFreeplay = unlockFreeplay;
        FlxG.save.data.addBirthday = addBirthday;
        FlxG.save.data.seenWarning = seenWarning;
        
		FlxG.save.flush();
	}

    // yeah
    // you're both fired
   /* public static function setthefreeplayData(){
        var progression:FlxSave = new FlxSave();
		progression.bind("gameProgression", CoolUtil.getSavePath());

        for (i in 0...freeplaySongs.length)
        {
            if (PlayState.SONG.song.toLowerCase() == freeplaySongs[i][0].toLowerCase()){
                if (FlxG.save.data.freeplaySongs[i] != 'beaten')
					curLock = huntedLock = 'unlocked';
            }
        }
        saveData();
		
    } */

    	
	public static function loadData() {
		if (freeplaySongs != null) {
			for (i in 0...freeplaySongs.length){
				if(FlxG.save.data.freeplaySongs != null &&  i < FlxG.save.data.freeplaySongs.length && FlxG.save.data.freeplaySongs[i] != null && FlxG.save.data.freeplaySongs[i][1] != null) {
					freeplaySongs[i][1] = FlxG.save.data.freeplaySongs[i][1];
				}
			}
		}

        if(FlxG.save.data.addBirthday != null)
            addBirthday = FlxG.save.data.addBirthday;
        if(FlxG.save.data.seenWarning != null)
            seenWarning = FlxG.save.data.seenWarning;

        if(FlxG.save.data.addMalfunction != null)
            addMalfunction = FlxG.save.data.addMalfunction;

       if(FlxG.save.data.currentStorySong != null)
			currentStorySong = FlxG.save.data.currentStorySong;

        if(FlxG.save.data.unlockFreeplay != null)
            unlockFreeplay = FlxG.save.data.unlockFreeplay;


    }

    public static var canOverrideCPU:Bool = false;
    public static function overrideBotplay()
	{
		canOverrideCPU = true;
		ClientPrefs.data.gameplaySettings["botplay"] = true;
		MusicBeatState.switchState(new PlayState());
	}

    /*public static function check(type:DATA_CHECK_TYPE):Dynamic
	{
		switch (type)
		{
			case NO_MALFUNCTION:
				return (for (i in 0...SaveData.freeplaySongs.length){
				if(FlxG.save.data.freeplaySongs != null &&  i < FlxG.save.data.freeplaySongs.length && FlxG.save.data.freeplaySongs[i] != null && FlxG.save.data.freeplaySongs[i][1] != null) {
					SaveData.freeplaySongs[i][1] = "beaten";
				}});
			
    

			case ALL:
				return (for (i in 0...SaveData.freeplaySongs.length){
				if(FlxG.save.data.freeplaySongs != null &&  i < FlxG.save.data.freeplaySongs.length && FlxG.save.data.freeplaySongs[i] != null && FlxG.save.data.freeplaySongs[i][1] != null) {
					SaveData.freeplaySongs[i][1] = "beaten";
                    SaveData.addMalfunction = true;
				}});
		}

		// tragic
		return false;
	}*/
}