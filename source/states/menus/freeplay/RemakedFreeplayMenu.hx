package states.menus.freeplay;

import openfl.media.Sound;
import sys.thread.Thread;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import lime.app.Application;
import flixel.input.keyboard.FlxKey;
import sys.thread.Mutex;

enum Category {
	STORY;
	FREEPLAY;
	LEGACY;
}

//TO-DO: use newer haxe shit in the next updates, keeping this here to remind myself (don)

class RemakedFreeplayMenu extends MusicBeatState
{
	var curSelected:Int = 0;
	public static var category:Category = STORY;

	// js some heads up 'bout this 
	/**
	   	trace(songList[STORY][0][1]); // prints the icon name on the story section
		trace(songList[FREEPLAY][1][0]); // prints the song name (laugh track) on the freeplay section

		so basically
		songList[CURRENT SECTION][CURRENT SELECRED][DATA]
		
		hope this helps !
	 */
	// TODO: ADD MECHANIC WARNING
	// EXAMPLE: 
	/**
	 * no mechanics -> "This Song Has No Mechanics".
	 * otherwise there'll be a list of all the mechanics of a song
	 * (including those sloppy and shitty (most of the time) unnecesarry modcharts)
	 */
	var songList:Map<Category, Array<Dynamic>> = [
		STORY => [
			['Devilish Deal', 'satanddNEW', 'obscurity',  'EASY',   FlxColor.WHITE, 			     [25, -18]], 
			['Isolated', 	  'avier',      'obscurity',  'NORMAL', FlxColor.fromRGB(255, 220, 220), [0, 0]], 
			['Lunacy', 		  'lunaavier',  'obscurity',  'HARD',   FlxColor.fromRGB(255, 187, 187), [0, 0]], 
			['Delusional', 	  'deluavier',  'FR3SHMoure', 'INSANE', FlxColor.fromRGB(255, 110, 110), [0, 0]]
		],

		FREEPLAY => [
			['Hunted', 		  (GameData.huntedLock != 'unlocked' && GameData.huntedLock != 'beaten' ? 'mysteryfp' : 'goofy'), 	  'JBlitz', 				'NORMAL', 	 FlxColor.fromRGB(255, 220, 220), (GameData.huntedLock == "beaten" || GameData.huntedLock == "unlocked" ? [24, -8] : [25, 0])], 
			['Laugh Track',   (GameData.rickyLock != 'unlocked' && GameData.rickyLock != 'beaten' ? 'mysteryfp' : 'ricky'), 	  'PualTheUnTruest', 		'HARD', 	 FlxColor.fromRGB(255, 187, 187), (GameData.rickyLock == "beaten" || GameData.rickyLock == "unlocked" ? [20, -15] : [25, 0])],
			['Bless', 		  (GameData.blessLock != 'unlocked' && GameData.blessLock != 'beaten' ? 'mysteryfp' : 'noise'), 	  'PualTheUnTruest', 		'HARD', 	 FlxColor.fromRGB(255, 187, 187), (GameData.blessLock == "beaten" || GameData.blessLock == "unlocked" ? [40, -10] : [25, 0])], 
			["Don't Cross!",  (GameData.crossinLock != 'unlocked' && GameData.crossinLock != 'beaten' ? 'mysteryfp' : 'cross'),   'PualTheUnTruest', 		'GOOD LUCK', FlxColor.fromRGB(201, 0, 0), 	  (GameData.crossinLock == "beaten" || GameData.crossinLock == "unlocked" ? [23, 0] : [25, 0])], 
			['War Dilemma',	  (GameData.warLock != 'unlocked' && GameData.warLock != 'beaten' ? 'mysteryfp' : 'ethernalg'), 	  'Sayan Sama & obscurity', 'HARD', 	 FlxColor.fromRGB(255, 187, 187), (GameData.warLock == "beaten" || GameData.warLock == "unlocked" ? [24, 1] : [25, 0])],
			['Twisted Grins', (GameData.tgLock != 'unlocked' && GameData.tgLock != 'beaten' ? 'mysteryfp' : 'smile'), 			  'PualTheUnTruest', 		'HARD', 	 FlxColor.fromRGB(255, 187, 187), (GameData.tgLock == "beaten" || GameData.tgLock == "unlocked" ? [25, 0] : [25, 0])], 
			['Mercy', 		  (GameData.mercyLock != 'beaten' && GameData.mercyLock != 'beaten' ? 'mysteryfp' : 'walt'), 		  'Ophomix24', 				'INSANE', 	 FlxColor.fromRGB(255, 110, 110), (GameData.mercyLock == "beaten" || GameData.mercyLock == "unlocked" ? [32, -20] : [25, 0])], 
			['Cycled Sins',   (GameData.sinsLock != 'unlocked' && GameData.sinsLock != 'beaten' ? 'mysteryfp' : 'relapse-pixel'), 'JBlitz', 				'HARD', 	 FlxColor.fromRGB(255, 187, 187), (GameData.sinsLock == "beaten" || GameData.sinsLock == "unlocked" ? [24, -21] : [25, 0])] 
		]/*,
		LEGACY => [
			'Isolated Legacy', 
			'Lunacy Legacy', 
			'Delusional Legacy', 
			'Hunted Legacy', 
			'Twisted Grins Legacy', 
			'Mercy Legacy', 
			'Cycled Sins Legacy', 
			'Isolated Old', 
			'Isolated Beta'
		]*/
	];

	var songThread:Thread;
	var threadActive:Bool = true;
	var mutex:Mutex;
	var songToPlay:Sound = null;

	var instPlaying:Int = -1;

	public function new(?category:Null<Category>) 
	{
		super();
		if (category == null) 
			category = FREEPLAY;

		this.category = category;
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String, color:Int, composer:String, rankName:String, rankColor:FlxColor, iconOffset:Array<Int>)
	{
		songs.push(new SongMetadata(songName, weekNum, songCharacter, color, composer, rankName, rankColor, iconOffset));
	}

	final path = 'Funkin_avi/freeplay';

	var disc:FlxSprite;
	override public function create() 
	{
		for (i in songList.length)
		{
			addSong(songList[category][i]);
		}
		final bg = new FlxSprite().loadGraphic(Paths.image('$path/background'));
		bg.updateHitbox();
		bg.setPosition(-150, -200);
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		final table = new FlxSprite().loadGraphic(Paths.image('$path/table1'));
		table.updateHitbox();
		table.setPosition(-130, (FlxG.height * .5) - 10);
		table.antialiasing = ClientPrefs.globalAntialiasing;
		add(table);

		final albumCover = new FlxSprite().loadGraphic(Paths.image('$path/albumcoverframe2'));
		albumCover.scale.set(1.1, 1.1);
		albumCover.updateHitbox();
		albumCover.setPosition(50, 80);
		albumCover.antialiasing = ClientPrefs.globalAntialiasing;
		add(albumCover);

		final book = new FlxSprite().loadGraphic(Paths.image('$path/book'));
		book.scale.set(1.2, 1.2);
		book.updateHitbox();
		book.setPosition(-30, FlxG.height - (book.height * .45));
		book.antialiasing = ClientPrefs.globalAntialiasing;
		add(book);

		final rug = new FlxSprite().loadGraphic(Paths.image('$path/rugthing'));
		rug.scale.set(2, 2);
		rug.updateHitbox();
		rug.setPosition(FlxG.width - (rug.frameWidth * 1.485), -130);
		rug.antialiasing = ClientPrefs.globalAntialiasing;
		add(rug);

		final gramo = new FlxSprite().loadGraphic(Paths.image('$path/gramo11'));
		gramo.scale.set(1.35, 1.35);
		gramo.updateHitbox();
		gramo.setPosition(FlxG.width - (gramo.frameWidth * 1.2), -50);
		gramo.antialiasing = ClientPrefs.globalAntialiasing;
		add(gramo);

		disc = new FlxSprite().loadGraphic(Paths.image('$path/discfull'));
		disc.scale.set(1.35, 1.35);
		disc.updateHitbox();
		disc.setPosition(FlxG.width * .7, ((gramo.height - disc.height) * .5) + 20);
		disc.antialiasing = ClientPrefs.globalAntialiasing;
		insert(members.indexOf(gramo), disc);

		final overlay = new FlxSprite().loadGraphic(Paths.image('$path/overlay'));
		overlay.setGraphicSize(FlxG.width * 1.135, FlxG.height * 1.135);
		overlay.updateHitbox();
		overlay.screenCenter();
		overlay.antialiasing = ClientPrefs.globalAntialiasing;
		add(overlay);

		super.create();

		persistentUpdate = true;
		PlayState.isStoryMode = false;
	}

	override public function update(elapsed:Float)
	{
		Conductor.songPosition = FlxG.sound.music.time;
		super.update(elapsed);

		disc.angle += Conductor.crochet / 1000 * 2;

		if (controls.BACK)
		{
			persistentUpdate = false;
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new GeneralMenu());
			FlxG.mouse.visible = true;
		}

		if(FlxG.keys.justPressed.SPACE)
		{
			if(instPlaying != curSelected && !disableSpace)
			{
				if (songs[curSelected].songName == "Don't Cross!")
					FlxG.sound.playMusic(Paths.inst("dont-cross", CoolUtil.difficulties[curDifficulty]));
				else
					FlxG.sound.playMusic(Paths.inst(songs[curSelected].songName, CoolUtil.difficulties[curDifficulty]));
	
				if (FlxG.sound.music.fadeTween != null)
					FlxG.sound.music.fadeTween.cancel();
	
				FlxG.sound.music.volume = 0.0;
				FlxG.sound.music.fadeIn(1.0, 0.0, 0.7);
				songInstPlaying = true;
				getBPM();
				FlxTween.num(Conductor.bpm, bpm, 2, null, shitshitfuckfuck -> Conductor.bpm = shitshitfuckfuck);
				instPlaying = curSelected;
			}
		}
	}

	override function beatHit() {
		super.beatHit();

		if (curBeat % 2 == 0)
			spawnMusicalNote();
	}

	// this code is fucking stupid i hate it i hate it i hate it i hate it i hate it i hate it i hate it i hate it i hate it i hate it i hate it
	function spawnMusicalNote()
	{
		final musicNote = new FlxSprite(800, 130, Paths.image('favi/ui/bdaynotes/note_${FlxG.random.int(1, 3)}', 'shared'));
		musicNote.scale.set(.65, .65);
		musicNote.updateHitbox();
		musicNote.antialiasing = ClientPrefs.globalAntialiasing;
		musicNote.setColorTransform(-1, -1, -1, 1, 255, 255, 255, 0);
		insert(members.indexOf(disc), musicNote);

		musicNote.alpha = 0;
		FlxTween.tween(musicNote, {alpha: 1}, .5, {ease: FlxEase.sineInOut});

		final randomTimer = FlxG.random.float(3.5, 7);

		musicNote.velocity.x = -FlxG.random.float(120, 230);

		FlxTween.tween(musicNote, {y: musicNote.y - 70}, FlxG.random.float(1, 4), {ease: FlxEase.sineInOut, type: 4});
		FlxTween.tween(musicNote, {alpha: 0}, randomTimer, {ease: FlxEase.sineInOut, startDelay: 1.5, onComplete: tweeeeeee -> {
			remove(musicNote);
			musicNote.destroy();
		}});
	}

	function getBPM():Float
	{
		var bpm:Float = 100;

		switch (CoolUtil.spaceToDash(songList[category][1][0].toLowerCase()))
		{
			case 'devilish-deal': bpm = 90;
			case 'isolated' | 'isolated-legacy': bpm = 165;
			case 'lunacy': bpm = 188;
			case 'delusional' | 'bless': bpm = 175;
			case 'hunted' | 'malfunction-legacy' | 'war-dilemma' | 'mercy' | 'mercy-legacy' | 'hunted-legacy': bpm = 160;
			case 'laugh-track' | 'birthday': bpm = 180;
			case 'malfunction': bpm = 166;
			case 'twisted-grins' | "don't-cross!": bpm = 140;
			case 'delutrance': bpm = 123;
			case 'cycled-sins': bpm = 161;
			case 'isolated-beta' | 'isolated-old': bpm = 120;
		}
		return bpm;
	}
}

class SongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";
	public var color:Int = -7179779;
	public var composer:String = "Unknown";
	public var rankName:String = "";
	public var rankColor:FlxColor = FlxColor.WHITE;
	public var iconOffset:Array<Int> = [0, 0];
	public var folder:String = "";

	public function new(song:String, week:Int, songCharacter:String, color:Int, composer:String, rankName:String, rankColor:FlxColor, iconOffset:Array<Int>)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
		this.color = color;
		this.composer = composer;
		this.rankName = rankName;
		this.rankColor = rankColor;
		this.iconOffset = iconOffset;
		this.folder = Paths.currentModDirectory;
		if(this.folder == null) this.folder = '';
	}
}