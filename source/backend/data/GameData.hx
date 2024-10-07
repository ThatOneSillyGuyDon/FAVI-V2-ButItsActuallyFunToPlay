package backend.data;

private enum DATA_CHECK_TYPE
{
	NO_MALFUNCTION;
	ALL;
}

/**
 * **lmao you ain't gonna play malfunction so easly**.
 * 
 *  Anyways the data thing which is useful for stuff such like:
 * - the birthday song been in the extras section after beating it
 * - var progression:FlxSave = new FlxSave();
 * progression for cool ass stuff
 * - etc
 * 
 * Also this is like the [**Psych Engine ClientPrefs file**](https://github.com/ShadowMario/FNF-PsychEngine/blob/main/source/ClientPrefs.hx),
 * 
 * but with game data instead of option data (that one is on **Init** file and some others)
 */
class GameData
{
	// Progression Shit
	public static var episode1FPLock:String = 'locked';

	public static var episodeSFPLock:String = 'locked';
	public static var episodeWFPLock:String = 'locked';

	// Alters the icons in freeplay
	public static var huntedLock:String = 'locked';
	public static var oldisolateLock:String = 'locked';
	public static var betaisolateLock:String = 'locked';
	public static var malfunctionLock:String = 'locked';
	public static var blessLock:String = 'locked';
	public static var scrappedLock:String = 'locked';
	public static var sinsLock:String = 'locked';
	public static var warLock:String = 'locked';
	public static var crossinLock:String = 'locked';
	public static var mercyLock:String = 'locked';
	public static var tgLock:String = 'locked';
	public static var pnmLock:String = 'locked';
	public static var rickyLock:String = 'locked';

	public static var legacyILock:String = 'locked'; // Isolated
	public static var legacyLLock:String = 'locked'; // Lunacy
	public static var legacyDLock:String = 'locked'; // Delusional
	public static var legacyHLock:String = 'locked'; // Hunted
	public static var legacyMLock:String = 'locked'; // Malfunction
	public static var legacyWLock:String = 'locked'; // Mercy
	public static var legacyBLock:String = 'locked'; // Bless
	public static var legacyNLock:String = 'locked'; // Neglection
	public static var legacySLock:String = 'locked'; // Cycled Sins
	public static var legacyTLock:String = 'locked'; // Twisted Grins
	public static var legacyRLock:String = 'locked'; // Resentment

	// Gamejolt Stuff
	public static var GJ_username:String = "";
	public static var GJ_token:String = "";

	// Intro Stuff
	public static var hasSeenWarning:Bool = false;
	public static var hasSeenFlxSplash:Bool = false;

	// Hidden Songs
	public static var canAddMalfunction:Bool = false;
	public static var muckneyLock:String = "uncompleted";
	public static var highOnCrackLock:String = "undiscovered";

	public static function lockinIt():Void
	{
		var progression:FlxSave = new FlxSave();
		progression.bind("gameProgression", CoolUtil.getSavePath());

		if (progression.data.episode1FPLock == null)
			progression.data.episode1FPLock = 'locked';

		if (progression.data.huntedLock == null)
			progression.data.huntedLock = 'locked';
		if (progression.data.oldisolateLock == null)
			progression.data.oldisolateLock = 'locked';
		if (progression.data.betaisolateLock == null)
			progression.data.betaisolateLock = 'locked';
		if (progression.data.malfunctionLock == null)
			progression.data.malfunctionLock = 'locked';
		if (progression.data.blessLock == null)
			progression.data.blessLock = 'locked';
		if (progression.data.scrappedLock == null)
			progression.data.scrappedLock = 'locked';
		if (progression.data.sinsLock == null)
			progression.data.sinsLock = 'locked';
		if (progression.data.warLock == null)
			progression.data.warLock = 'locked';
		if (progression.data.crossinLock == null)
			progression.data.crossinLock = 'locked';
		if (progression.data.mercyLock == null)
			progression.data.mercyLock = 'locked';
		if (progression.data.tgLock == null)
			progression.data.tgLock = 'locked';
		if (progression.data.pnmLock == null)
			progression.data.pnmLock = 'locked';
		if (progression.data.rickyLock == null)
			progression.data.rickyLock = 'locked';

		if (progression.data.gjUser == null)
			progression.data.gjUser = "";
		if (progression.data.gjToken == null)
			progression.data.gjToken = "";

		if (progression.data.hasSeenWarning == null)
			progression.data.hasSeenWarning = false;
		if (progression.data.hasSeenFlxSplash == null)
			progression.data.hasSeenFlxSplash = false;

		if (progression.data.legacyILock == null)
			progression.data.legacyILock = 'locked';
		if (progression.data.legacyLLock == null)
			progression.data.legacyLLock = 'locked';
		if (progression.data.legacyDLock == null)
			progression.data.legacyDLock = 'locked';
		if (progression.data.legacyHLock == null)
			progression.data.legacyHLock = 'locked';
		if (progression.data.legacyMLock == null)
			progression.data.legacyMLock = 'locked';
		if (progression.data.legacyWLock == null)
			progression.data.legacyWLock = 'locked';
		if (progression.data.legacyBLock == null)
			progression.data.legacyBLock = 'locked';
		if (progression.data.legacySLock == null)
			progression.data.legacySLock = 'locked';
		if (progression.data.legacyNLock == null)
			progression.data.legacyNLock = 'locked';
		if (progression.data.legacyTLock == null)
			progression.data.legacyYLock = 'locked';
		if (progression.data.legacyRLock == null)
			progression.data.legacyRLock = 'locked';

		if (progression.data.canAddMalfunction == null)
			progression.data.canAddMalfunction = false;
		if (progression.data.muckneyLock == null)
			progression.data.muckneyLock = "uncompleted";
		if (progression.data.highOnCrackLock == null)
			progression.data.highOnCrackLock = "undiscovered";

		progression.flush();
	}

	public static function saveShit():Void
	{
		var progression:FlxSave = new FlxSave();
		progression.bind("gameProgression", CoolUtil.getSavePath());
		trace('saving data');

		progression.data.episode1FPLock = episode1FPLock;

		progression.data.episodeSFPLock = episodeSFPLock;
		progression.data.episodeWFPLock = episodeWFPLock;

		progression.data.huntedLock = huntedLock;
		progression.data.oldisolateLock = oldisolateLock;
		progression.data.betaisolateLock = betaisolateLock;
		progression.data.malfunctionLock = malfunctionLock;
		progression.data.blessLock = blessLock;
		progression.data.scrappedLock = scrappedLock;
		progression.data.sinsLock = sinsLock;
		progression.data.warLock = warLock;
		progression.data.crossinLock = crossinLock;
		progression.data.mercyLock = mercyLock;
		progression.data.tgLock = tgLock;
		progression.data.pnmLock = pnmLock;
		progression.data.rickyLock = rickyLock;

		progression.data.legacyILock = legacyILock;
		progression.data.legacyLLock = legacyLLock;
		progression.data.legacyDLock = legacyDLock;
		progression.data.legacyHLock = legacyHLock;
		progression.data.legacyMLock = legacyMLock;
		progression.data.legacyWLock = legacyWLock;
		progression.data.legacyBLock = legacyBLock;
		progression.data.legacySLock = legacySLock;
		progression.data.legacyNLock = legacyNLock;
		progression.data.legacyTLock = legacyTLock;
		progression.data.legacyRLock = legacyRLock;

		progression.data.gjUser = GJ_username;
		progression.data.gjToken = GJ_token;

		progression.data.hasSeenWarning = hasSeenWarning;
		progression.data.hasSeenFlxSplash = hasSeenFlxSplash;

		progression.data.canAddMalfunction = canAddMalfunction;
		progression.data.muckneyLock = muckneyLock;
		progression.data.highOnCrackLock = highOnCrackLock;

		progression.flush();
	}

	public static function loadShit():Void
	{
		var progression:FlxSave = new FlxSave();
		progression.bind("gameProgression", CoolUtil.getSavePath());

		trace('loading data');

		episode1FPLock = progression.data.episode1FPLock;

		//episodeSFPLock = progression.data.episodeSFPLock;
		//episodeWFPLock = progression.data.episodeWFPLock;

		huntedLock = progression.data.huntedLock;
		oldisolateLock = progression.data.oldisolateLock;
		betaisolateLock = progression.data.betaisolateLock;
		malfunctionLock = progression.data.malfunctionLock;
		blessLock = progression.data.blessLock;
		scrappedLock = progression.data.scrappedLock;
		sinsLock = progression.data.sinsLock;
		warLock = progression.data.warLock;
		crossinLock = progression.data.crossinLock;
		mercyLock = progression.data.mercyLock;
		tgLock = progression.data.tgLock;
		pnmLock = progression.data.pnmLock;
		rickyLock = progression.data.rickyLock;

		legacyILock = progression.data.legacyILock;
		legacyLLock = progression.data.legacyLLock;
		legacyDLock = progression.data.legacyDLock;
		legacyHLock = progression.data.legacyHLock;
		legacyMLock = progression.data.legacyMLock;
		legacyWLock = progression.data.legacyWLock;
		legacyBLock = progression.data.legacyBLock;
		legacySLock = progression.data.legacySLock;
		legacyNLock = progression.data.legacyNLock;
		legacyTLock = progression.data.legacyTLock;
		legacyRLock = progression.data.legacyRLock;

		GJ_username = progression.data.gjUser;
		GJ_token = progression.data.gjToken;

		hasSeenWarning = progression.data.hasSeenWarning;
		hasSeenFlxSplash = progression.data.hasSeenFlxSplash;

		canAddMalfunction = progression.data.canAddMalfunction;
		muckneyLock = progression.data.muckneyLock;
		highOnCrackLock = progression.data.highOnCrackLock;

		saveShit();
	}

	public static function unlockEverything():Void
	{
		var progression:FlxSave = new FlxSave();
		progression.bind("gameProgression", CoolUtil.getSavePath());

		episode1FPLock = 'unlocked';

		episodeSFPLock = 'unlocked';
		episodeWFPLock = 'unlocked';

		huntedLock = 'beaten';
		oldisolateLock = 'beaten';
		betaisolateLock = 'beaten';
		malfunctionLock = 'beaten';
		blessLock = 'beaten';
		scrappedLock = 'beaten';
		sinsLock = 'beaten';
		warLock = 'beaten';
		crossinLock = 'beaten';
		mercyLock = 'beaten';
		tgLock = 'beaten';
		pnmLock = 'beaten';
		rickyLock = 'beaten';

		legacyILock = 'beaten';
		legacyLLock = 'beaten';
		legacyDLock = 'beaten';
		legacyHLock = 'beaten';
		legacyMLock = 'beaten';
		legacyWLock = 'beaten';
		legacyBLock = 'beaten';
		legacySLock = 'beaten';
		legacyNLock = 'beaten';
		legacyTLock = 'beaten';
		legacyRLock = 'beaten';

		canAddMalfunction = true;
		muckneyLock = 'beaten';
		highOnCrackLock = 'completed';

		saveShit();
	}

	public static function checkBotplay(lockValue:Null<String>)
	{
		if (lockValue == null)
			lockValue = 'unlocked';

		if ((lockValue == 'unlocked' || lockValue == 'obtained') || PlayState.isStoryMode)
			PlayState.instance.cpuControlled = false;
	}

	public static function setFreeplayData()
	{
		var progression:FlxSave = new FlxSave();
		progression.bind("gameProgression", CoolUtil.getSavePath());

		var curLock:String;

		if (PlayState.SONG.song == "Delutrance")
			curLock = 'completed';
		else
			curLock = 'beaten';

		switch (PlayState.SONG.song.toLowerCase())
		{
			case 'hunted':
				if (progression.data.huntedLock != 'beaten')
					curLock = huntedLock = 'unlocked';
			case 'isolated old':
				if (progression.data.oldisolateLock != 'beaten')
					curLock = oldisolateLock = 'unlocked';
			case 'isolated beta':
				if (progression.data.betaisolateLock != 'beaten')
					curLock = betaisolateLock = 'unlocked';
			case 'neglection':
				if (progression.data.pnmLock != 'beaten')
					curLock = pnmLock = 'unlocked';
			case "dont cross":
				if (progression.data.crossinLock != 'beaten')
					curLock = crossinLock = 'unlocked';
			case 'war dilemma':
				if (progression.data.warLock != 'beaten')
					curLock = warLock = 'unlocked';
			case 'twisted grins':
				if (progression.data.tgLock != 'beaten')
					curLock = tgLock = 'unlocked';
			case 'birthday':
				if (progression.data.muckneyLock != 'beaten')
					curLock = muckneyLock = 'beaten';
			case 'mercy':
				if (progression.data.mercyLock != 'beaten')
					curLock = mercyLock = 'unlocked';
			case 'cycled sins':
				if (progression.data.sinsLock != 'beaten')
					curLock = sinsLock = 'unlocked';
			case 'malfunction':
				if (progression.data.malfunctionLock != 'beaten')
					curLock = malfunctionLock = 'unlocked';
			case 'scrapped':
				if (progression.data.scrappedLock != 'beaten')
					curLock = scrappedLock = 'unlocked';
			case 'bless':
				if (progression.data.blessLock != 'beaten')
					curLock = blessLock = 'unlocked';
			case 'laugh track':
				if (progression.data.rickyLock != 'beaten')
					curLock = rickyLock = 'unlocked';
			case 'mercy legacy':
				if (progression.data.legacyWLock != 'beaten')
					curLock = legacyWLock = 'unlocked';
			case 'isolated legacy':
				if (progression.data.legacyILock != 'beaten')
					curLock = legacyILock = 'unlocked';
			case 'lunacy legacy':
				if (progression.data.legacyLLock != 'beaten')
					curLock = legacyLLock = 'unlocked';
			case 'delusional legacy':
				if (progression.data.legacyDLock != 'beaten')
					curLock = legacyDLock = 'unlocked';
			case 'hunted legacy':
				if (progression.data.legacyHLock != 'beaten')
					curLock = legacyHLock = 'unlocked';
			case 'malfunction legacy':
				if (progression.data.legacyMLock != 'beaten')
					curLock = legacyMLock = 'unlocked';
			case 'cycled sins legacy':
				if (progression.data.legacySLock != 'beaten')
					curLock = legacySLock = 'unlocked';
			case 'bless legacy':
				if (progression.data.legacyBLock != 'beaten')
					curLock = legacyBLock = 'unlocked';
			case 'twisted grins legacy':
				if (progression.data.legacyTLock != 'beaten')
					curLock = legacyTLock = 'unlocked';
			case 'neglection legacy':
				if (progression.data.legacyNLock != 'beaten')
					curLock = legacyNLock = 'unlocked';
			case 'resentment legacy':
				if (progression.data.legacyRLock != 'beaten')
					curLock = legacyRLock = 'unlocked';
			case 'delutrance':
				if (progression.data.highOnCrack != 'completed')
					curLock = highOnCrackLock = 'unlocked';
		}
		saveShit();
		checkBotplay(curLock); // just to double check :)))))))
	}

	public static function completeFPSong()
	{
		var progression:FlxSave = new FlxSave();
		progression.bind("gameProgression", CoolUtil.getSavePath());
		
		switch (PlayState.SONG.song.toLowerCase())
		{
			case 'hunted':
				if (ClientPrefs.mechanics)
					huntedLock = 'beaten';
			case 'isolated old':
				oldisolateLock = 'beaten';
			case 'isolated beta':
				betaisolateLock = 'beaten';
			case 'neglection':
				if (ClientPrefs.mechanics)
					pnmLock = 'beaten';
			case "dont cross":
				if (ClientPrefs.mechanics)
					crossinLock = 'beaten';
			case 'war dilemma':
				warLock = 'beaten';
			case 'twisted grins':
				tgLock = 'beaten';
			case 'mercy':
				if (ClientPrefs.mechanics)
					mercyLock = 'beaten';
			case 'cycled sins':
				if (ClientPrefs.mechanics)
					sinsLock = 'beaten';
			case 'malfunction':
				if (ClientPrefs.mechanics)
					malfunctionLock = 'beaten';
			case 'scrapped':
				scrappedLock = 'beaten';
			case 'bless':
				blessLock = 'beaten';
			case 'laugh track':
				if (ClientPrefs.mechanics)
					rickyLock = 'beaten';
			case 'birthday':
				muckneyLock = 'beaten';
			case 'mercy legacy':
				if (ClientPrefs.mechanics)
					legacyWLock = 'beaten';
			case 'isolated legacy':
				legacyILock = 'beaten';
			case 'lunacy legacy':
				legacyLLock = 'beaten';
			case 'delusional legacy':
				if (ClientPrefs.mechanics)
					legacyDLock = 'beaten';
			case 'hunted legacy':
				legacyHLock = 'beaten';
			case 'malfunction legacy':
				if (ClientPrefs.mechanics)
					legacyMLock = 'beaten';
			case 'cycled sins legacy':
				if (ClientPrefs.mechanics)
					legacySLock = 'beaten';
			case 'bless legacy':
				legacyBLock = 'beaten';
			case 'neglection legacy':
				if (ClientPrefs.mechanics)
					legacyNLock = 'beaten';
			case 'twisted grins legacy':
				if (ClientPrefs.mechanics)
					legacyTLock = 'beaten';
			case 'resentment legacy':
				legacyRLock = 'beaten';
			case 'delutrance':
				highOnCrackLock = 'completed';
		}
		saveShit();
	}

	public static function check(type:DATA_CHECK_TYPE):Dynamic
	{
		switch (type)
		{
			case NO_MALFUNCTION:
				return (GameData.huntedLock == 'beaten'
					&& GameData.rickyLock == 'beaten'
					&& GameData.blessLock == 'beaten'
					&& GameData.crossinLock == 'beaten'
					&& GameData.warLock == 'beaten'
					&& GameData.tgLock == 'beaten'
					&& GameData.mercyLock == 'beaten'
					&& GameData.sinsLock == 'beaten'
					&& !GameData.canAddMalfunction);

			case ALL:
				return (GameData.huntedLock == 'beaten'
				&& GameData.rickyLock == 'beaten'
				&& GameData.blessLock == 'beaten'
				&& GameData.crossinLock == 'beaten'
				&& GameData.warLock == 'beaten'
				&& GameData.tgLock == 'beaten'
				&& GameData.mercyLock == 'beaten'
				&& GameData.sinsLock == 'beaten'
				&& GameData.canAddMalfunction);
		}

		// tragic
		return false;
	}

	public static function completeEpisode()
	{
		switch (PlayState.SONG.song.toLowerCase())
		{
			case 'delusional':
				episode1FPLock = 'unlocked';
			case 'mortiferum risus':
				episodeSFPLock = 'unlocked';
			case 'affliction':
				if (ClientPrefs.mechanics)
					episodeWFPLock = 'unlocked';
		}
		saveShit();
	}
}
