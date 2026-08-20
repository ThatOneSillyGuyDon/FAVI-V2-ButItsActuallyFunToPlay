package states.menus;

import flixel.addons.transition.FlxTransitionableState;
import lime.utils.Assets;
import openfl.utils.Assets as OpenFlAssets;
import openfl.media.Sound;

class FreeplayState extends MusicBeatState
{
	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var albumHolder:FlxTypedGroup<FlxSprite>;
	private var iconArray:Array<HealthIcon> = [];
	private var songDisplay:Array<FlxText> = [];
	private var curPlaying:Bool = false;
	private var bg:Null<FlxSprite>;

	var songs:Array<SongMetadata> = [];
	var scoreText:FlxText;
	var diffText:FlxText;
	var freeplayCtrlTxt:FlxText;
	var botplaytext:FlxText;
	var gimmickInfo:FlxText;
	var offandon:FlxSprite;
	var scoreBG:FlxSprite;
	var maniaSkinSpr:FlxSprite;
	var disc:FlxSprite;
	var spectrum:SpectrumWaveform;
	var player:MusicPlayer;
	var intendedColor:Int;
	var lerpScore:Int = 0;
	var intendedScore:Int = 0;
	var curDifficulty:Int = -1;
	private static var lastDifficultyName:String = Difficulty.getDefault();
	var instPlaying:Int = -1;
	var holdTime:Float = 0;
	var lerpRating:Float = 0;
	var intendedRating:Float = 0;
	var selectedSomethin:Bool = false;
	var disableSpace:Bool = false;
	var colorTween:FlxTween;
	var spectrumTwn:FlxTween;
	var camGame:FlxCamera;
	var camHUD:FlxCamera;

	var missingTextBG:FlxSprite;
	var missingText:FlxText;

	public static var freeplayMenuList = 0;
	public static var curSelected:Int = 0;
	public static var vocals:FlxSound = null;
	public static var vocalsOpp:FlxSound = null;
	public static var songInstPlaying:Bool = false;
	public static var confirmSound:FlxSound;
	public static var maniaSkin:Int = 0;

	public function new() 
		super();

	public function addSong(songName:String, weekNum:Int, songCharacter:String, color:Int, composer:String, rankName:String, rankColor:FlxColor, iconOffset:Array<Int>, mechanic:String)
		songs.push(new SongMetadata(songName, weekNum, songCharacter, color, composer, rankName, rankColor, iconOffset, mechanic));

	final path = 'Funkin_avi/freeplay';
	override public function create()
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		lime.app.Application.current.window.title = "Funkin.avi - Freeplay: Setting Up Category...";
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Freeplay Menu", "Loading Category...", "icon", "disc-player");
		#end

		switch (freeplayMenuList)
		{
			case 0: // Story Songs Menu
				{
					addSong('Devilish Deal', 3, 'satanddNEW', FlxColor.fromRGB(65, 88, 94), 'obscurity', 'EASY', FlxColor.WHITE, [25, -18], "None");
					addSong('Isolated', 3, 'avier', FlxColor.fromRGB(60, 60, 60), 'obscurity', 'NORMAL', FlxColor.fromRGB(255, 220, 220), [15, 0], "Modcharts that move notes on occasion.");
					addSong('Lunacy', 3, 'lunaavier', FlxColor.fromRGB(69, 54, 54), 'obscurity', 'HARD', FlxColor.fromRGB(255, 187, 187), [15, 0], "Modcharts that may cause visual distortion.");
					addSong('Delusional', 3, 'deluavier', FlxColor.fromRGB(79, 32, 32), 'FR3SHMoure', 'INSANE', FlxColor.fromRGB(255, 110, 110), [15, 0], "Modcharts that may cause visual distortion");
				}
			case 1: // Extras Menu
				{		
					addSong('Hunted', 3, (GameData.huntedLock != 'unlocked' && GameData.huntedLock != 'beaten' ? 'mysteryfp' : 'goofy'), FlxColor.fromRGB(94, 28, 35), 'JBlitz', 'NORMAL', FlxColor.fromRGB(255, 220, 220), (GameData.huntedLock == "beaten" || GameData.huntedLock == "unlocked" ? [24, -8] : [25, 0]), "Modcharts that may cause visual distortion.");
					addSong('Bless', 3, (GameData.blessLock != 'unlocked' && GameData.blessLock != 'beaten' ? 'mysteryfp' : 'noise'), FlxColor.WHITE, 'Lasagnacat', 'HARD', FlxColor.fromRGB(255, 187, 187), (GameData.blessLock == "beaten" || GameData.blessLock == "unlocked" ? [30, -10] : [25, 0]), "None");
					addSong('Scrapped', 3, (GameData.scrappedLock != 'unlocked' && GameData.scrappedLock != 'beaten' ? 'mysteryfp' : 'rs'), FlxColor.fromRGB(0, 0, 0), 'Lasagnacat', 'HARD', FlxColor.fromRGB(255, 187, 187), (GameData.scrappedLock == "beaten" || GameData.scrappedLock == "unlocked" ? [30, -10] : [25, 0]), "None");
					addSong("Don't Cross!", 3, (GameData.crossinLock != 'unlocked' && GameData.crossinLock != 'beaten' ? 'mysteryfp' : 'cross'), FlxColor.fromRGB(255, 0, 0), 'Lasagnacat', 'GOOD LUCK', FlxColor.fromRGB(201, 0, 0), (GameData.crossinLock == "beaten" || GameData.crossinLock == "unlocked" ? [23, -10] : [25, 0]), "Chart is randomized every attempt.");
					addSong('War Dilemma', 3, (GameData.warLock != 'unlocked' && GameData.warLock != 'beaten' ? 'mysteryfp' : 'ethernalg'), FlxColor.fromRGB(204, 41, 103), 'Sayan Sama & obscurity', 'HARD', FlxColor.fromRGB(255, 187, 187), (GameData.warLock == "beaten" || GameData.warLock == "unlocked" ? [24, 1] : [25, 0]), "Modcharts that may cause visual distortion.");
					addSong('Twisted Grins', 3, (GameData.tgLock != 'unlocked' && GameData.tgLock != 'beaten' ? 'mysteryfp' : 'smile'), FlxColor.fromRGB(54, 38, 38), 'Lasagnacat', 'HARD', FlxColor.fromRGB(255, 187, 187), (GameData.tgLock == "beaten" || GameData.tgLock == "unlocked" ? [25, -10] : [25, 0]), "Scroll speed changes.");
					addSong('Mercy', 3, (GameData.mercyLock != 'beaten' && GameData.mercyLock != 'beaten' ? 'mysteryfp' : 'walt'), FlxColor.fromRGB(176, 169, 116), 'Ophomix24', 'INSANE', FlxColor.fromRGB(255, 110, 110), (GameData.mercyLock == "beaten" || GameData.mercyLock == "unlocked" ? [27, -20] : [25, 0]), "Drains your health until death. Utilizes the SPACEBAR, highly recommend checking your controls setting before playing.");
					//addSong('Neglection', 3, 'mysteryfp', FlxColor.WHITE, 'FR3SHMoure', 'Man idk', FlxColor.WHITE, [25, 0], "None");
					addSong('Cycled Sins', 3, (GameData.sinsLock != 'unlocked' && GameData.sinsLock != 'beaten' ? 'mysteryfp' : 'relapseNEW-pixel'), FlxColor.fromRGB(105, 30, 30), 'JBlitz', 'HARD', FlxColor.fromRGB(255, 187, 187), (GameData.sinsLock == "beaten" || GameData.sinsLock == "unlocked" ? [24, -21] : [25, 0]), "Dodge Relapse Mouse's gunshots. Utilizes the SPACEBAR, highly recommend checking your controls setting before playing.");
					//addSong('Whimsical Bar Blues', 3, 'mysteryfp', FlxColor.fromRGB(133, 190, 255), 'inneaux & Sayan Sama', 'NORMAL', FlxColor.fromRGB(255, 220, 220), [25, 0], "None");		
					if (GameData.canAddMalfunction)
						addSong('Malfunction', 3, (GameData.malfunctionLock != 'unlocked' && GameData.malfunctionLock != 'beaten' ? 'mysteryfp' : 'malNEW-pixel'), FlxColor.fromRGB(150, 149, 186), 'obscurity', null, FlxColor.WHITE, (GameData.malfunctionLock == "beaten" || GameData.malfunctionLock == "unlocked" ? [27, 0] : [25, 0]), "Contains extreme flashing lights, very unforgiving modcharts, life system & note gimmicks. Mechanics are enabled by default upon playing.\nGood luck.");		
					if ((GameData.birthdayLocky == 'beaten' || GameData.birthdayLocky == 'obtained') && GameData.birthdayLocky != "uninvited")
						addSong('Birthday', 3, 'muckney', FlxColor.fromRGB(84, 255, 181), 'FR3SHMoure', 'PARTY', FlxColor.fromRGB(250, 234, 92), [15, -5], "Don't leave his party, you'll make him sad.");
				}
			case 2: // Legacy Menu
				{
					addSong('Isolated Old', 3, (GameData.oldisolateLock != 'unlocked' && GameData.oldisolateLock != 'beaten' ? 'mysteryfp' : 'avierlegacy'), FlxColor.fromRGB(60, 60, 60), 'Toko', 'EASY', FlxColor.WHITE, [0, 0], "");
					addSong('Isolated Beta', 3, (GameData.betaisolateLock != 'unlocked' && GameData.betaisolateLock != 'beaten' ? 'mysteryfp' : 'avierlegacy'), FlxColor.fromRGB(60, 60, 60), 'Toko', 'EASY', FlxColor.WHITE, [0, 0], "");
					addSong('Isolated Legacy', 3, (GameData.legacyILock != 'unlocked' && GameData.legacyILock != 'beaten' ? 'mysteryfp' : 'avierlegacy'), FlxColor.fromRGB(60, 60, 60), 'Toko & obscurity', 'NORMAL', FlxColor.fromRGB(255, 220, 220), [0, 0], "");
					addSong('Lunacy Legacy', 3, (GameData.legacyLLock != 'unlocked' && GameData.legacyLLock != 'beaten' ? 'mysteryfp' : 'lunaold'), FlxColor.fromRGB(60, 60, 60), 'obscurity', 'NORMAL', FlxColor.fromRGB(255, 220, 220), [0, 0], "");
					addSong('Delusional Legacy', 3, (GameData.legacyDLock != 'unlocked' && GameData.legacyDLock != 'beaten' ? 'mysteryfp' : 'deluold'), FlxColor.fromRGB(60, 60, 60), 'FR3SHMoure', 'HARD', FlxColor.fromRGB(255, 187, 187), [0, 0], "");
					addSong('Hunted Legacy', 3, (GameData.legacyHLock != 'unlocked' && GameData.legacyHLock != 'beaten' ? 'mysteryfp' : 'goofyold'), FlxColor.fromRGB(0, 60, 40), 'JBlitz', 'EASY', FlxColor.WHITE, [0, 0], "");
					addSong('Twisted Grins Legacy', 3, (GameData.legacyTLock != 'unlocked' && GameData.legacyTLock != 'beaten' ? 'mysteryfp' : 'smileold'), FlxColor.fromRGB(115, 86, 86), 'Sayan Sama', 'HARD', FlxColor.fromRGB(255, 187, 187), [0, 0], "");
					addSong('Mercy Legacy', 3, (GameData.legacyWLock != 'unlocked' && GameData.legacyWLock != 'beaten' ? 'mysteryfp' : 'waltold'), FlxColor.fromRGB(153, 148, 112), 'obscurity', 'HARD', FlxColor.fromRGB(255, 187, 187), [0, 0], "");
					addSong('Cycled Sins Legacy', 3, (GameData.legacySLock != 'unlocked' && GameData.legacySLock != 'beaten' ? 'mysteryfp' : 'relapseold-pixel'), FlxColor.fromRGB(115, 86, 86), 'JBlitz', 'HARD', FlxColor.fromRGB(255, 187, 187), [0, 0], "");
					addSong('Malfunction Legacy', 3, (GameData.legacyMLock != 'unlocked' && GameData.legacyMLock != 'beaten' ? 'mysteryfp' : 'mallegacy-pixel'), FlxColor.fromRGB(140, 120, 180), 'obscurity', 'INSANE', FlxColor.fromRGB(255, 110, 110), [0, 0], "");
				}
			case 3: // Secret Mania Menu
				{
					addSong("Alone", 3, "avier", FlxColor.WHITE, 'JBlitz', "BASIC", FlxColor.fromRGB(67, 247, 121), [15, 0], "None");
					addSong("Am I Real?", 3, "avier", FlxColor.WHITE, 'Yama Haki/Toko', "BASIC", FlxColor.fromRGB(67, 247, 121), [15, 0], "None");
					addSong("Mistful Wind", 3, "avier", FlxColor.WHITE, 'Lasagnacat', "BASIC", FlxColor.fromRGB(67, 247, 121), [15, 0], "None");
					addSong("Distant Stars", 3, "avier", FlxColor.WHITE, 'ForFurtherNotice', "INTERMEDIATE", FlxColor.fromRGB(67, 247, 205), [15, 0], "None");
					addSong("Somber Night", 3, "avier", FlxColor.WHITE, 'ForFurtherNotice', "INTERMEDIATE", FlxColor.fromRGB(67, 247, 205), [15, 0], "None");
					addSong("Your Final Bow", 3, "avier", FlxColor.WHITE, 'Yama Haki/Toko', "INTERMEDIATE", FlxColor.fromRGB(67, 247, 205), [15, 0], "None");
					addSong("Simple Life", 3, "avier", FlxColor.WHITE, 'ForFurtherNotice', "CHALLENGING", FlxColor.fromRGB(67, 235, 247), [15, 0], "None");
					addSong('Rotten Petals', 3, "avier", FlxColor.WHITE, 'Yama Haki/Toko', "CHALLENGING", FlxColor.fromRGB(67, 235, 247), [15, 0], "None");
					addSong('Seeking Freedom', 3, "avier", FlxColor.WHITE, 'Yama Haki/Toko', "EXPERT", FlxColor.fromRGB(224, 129, 252), [15, 0], "None");
					addSong('Curtain Call', 3, "avier", FlxColor.WHITE, 'Sayan Sama', "EXPERT", FlxColor.fromRGB(224, 129, 252), [15, 0], "None");
				}
		}

        camGame = new FlxCamera();
		camHUD = new FlxCamera();

		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD, false);

		FlxG.cameras.setDefaultDrawTarget(camGame, true);

		createMenuBG();
		createUIComponents();

        curDifficulty = Math.round(Math.max(0, Difficulty.defaultList.indexOf(lastDifficultyName)));

		player = new MusicPlayer(this);
		player.cameras = [camHUD];
		add(player);

        if(!ClientPrefs.data.lowQuality)
		{
			var scratchStuff:FlxSprite = new FlxSprite();
			scratchStuff.frames = Paths.getSparrowAtlas('Funkin_avi/filters/scratchShit');
			scratchStuff.animation.addByPrefix('idle', 'scratch thing 1', 24, true);
			scratchStuff.animation.play('idle');
			scratchStuff.screenCenter();
			scratchStuff.scale.x = 1.1;
			scratchStuff.scale.y = 1.1;
			add(scratchStuff);
	
			var grain:FlxSprite = new FlxSprite();
			grain.frames = Paths.getSparrowAtlas('Funkin_avi/filters/Grainshit');
			grain.animation.addByPrefix('idle', 'grains 1', 24, true);
			grain.animation.play('idle');
			grain.screenCenter();
			grain.scale.x = 1.1;
			grain.scale.y = 1.1;
			add(grain);
	
			if (freeplayMenuList != 2)
			{
				var gradient = new FlxSprite().loadGraphic(Paths.image('favi/filters/gradient'));
				gradient.screenCenter();
				gradient.setGraphicSize(Std.int(gradient.width * 0.8));
				gradient.alpha = .45;
				gradient.antialiasing = ClientPrefs.data.antialiasing;
				add(gradient);
				gradient.cameras = [camHUD];
			}
	
			scratchStuff.cameras = [camHUD];
			grain.cameras = [camHUD];
		}

        if (!songInstPlaying) 
			Conductor.bpm = 98;

		confirmSound = new FlxSound();
		if (freeplayMenuList != 2) confirmSound.loadEmbedded(Paths.sound('funkinAVI/menu/confirmEpisode'));

		super.create();

        persistentUpdate = true;
		PlayState.isStoryMode = false;
		
		changeSelection();
	}

	override public function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.7)
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;

        Conductor.songPosition = FlxG.sound.music.time;

		if (freeplayMenuList != 2)
			for (icon in iconArray) icon.scale.set(FlxMath.lerp(0.8, icon.scale.x, CoolUtil.boundTo(1 - (elapsed * 9.6), 0, 1)), FlxMath.lerp(0.8, icon.scale.y, CoolUtil.boundTo(1 - (elapsed * 9.6), 0, 1)));

		var isDontCross:Bool = songs[curSelected].songName == "Don't Cross!";

		if (disc != null && songInstPlaying) 
			disc.angle += Conductor.crochet / 1000 * 2;

		if (FlxG.keys.justPressed.B && !selectedSomethin)
			changeBotPlay();

        super.update(elapsed);

        if(songs[curSelected].songName == "Don't Cross!")
			iconArray[3].shake(4, 30, 0.1);

        lerpScore = Math.floor(FlxMath.lerp(intendedScore, lerpScore, Math.exp(-elapsed * 24)));
		lerpRating = FlxMath.lerp(intendedRating, lerpRating, Math.exp(-elapsed * 12));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;
		if (Math.abs(lerpRating - intendedRating) <= 0.01)
			lerpRating = intendedRating;

		var ratingSplit:Array<String> = Std.string(CoolUtil.floorDecimal(lerpRating * 100, 2)).split('.');
		if(ratingSplit.length < 2) { //No decimals, add an empty space
			ratingSplit.push('');
		}
		
		while(ratingSplit[1].length < 2) { //Less than 2 decimals in it, add decimals then
			ratingSplit[1] += '0';
		}

        if (!player.playingMusic)
		{
			if (freeplayMenuList == 2)
				scoreText.text = 'PERSONAL BEST: ' + lerpScore + ' (' + ratingSplit.join('.') + '%)';
			else
				scoreText.text = "Score: " + FlxStringUtil.formatMoney(lerpScore, false, true);
			positionHighscore();
		}

		var upP = freeplayMenuList == 2 ? controls.UI_UP_P : controls.UI_LEFT_P;
		var downP = freeplayMenuList == 2 ? controls.UI_DOWN_P : controls.UI_RIGHT_P;
		var accepted = controls.ACCEPT;
		var space = FlxG.keys.justPressed.SPACE;
		var ctrl = FlxG.keys.justPressed.CONTROL;

		var shiftMult:Int = 1;
		if(FlxG.keys.pressed.SHIFT) shiftMult = 3;

		if (!selectedSomethin)
		{
			if (!player.playingMusic)
			{
				if(songs.length > 1)
				{
					if (upP)
					{
						changeSelection(-shiftMult);
						holdTime = 0;
					}
					if (downP)
					{
						changeSelection(shiftMult);
						holdTime = 0;
					}

					if((freeplayMenuList == 2 ? controls.UI_UP : controls.UI_LEFT) || (freeplayMenuList == 2 ? controls.UI_DOWN : controls.UI_RIGHT))
					{
						var checkLastHold:Int = Math.floor((holdTime - 0.5) * 10);
						holdTime += elapsed;
						var checkNewHold:Int = Math.floor((holdTime - 0.5) * 10);

						if(holdTime > 0.5 && checkNewHold - checkLastHold > 0)
							changeSelection((checkNewHold - checkLastHold) * ((freeplayMenuList == 2 ? controls.UI_UP : controls.UI_LEFT) ? -shiftMult : shiftMult));
					}

					if(FlxG.mouse.wheel != 0)
					{
						FlxG.sound.play(Paths.sound('funkinAVI/menu/scrollSfx'), 0.2);
						changeSelection(-shiftMult * FlxG.mouse.wheel, false);
					}
				}
			}

			if (controls.BACK)
			{
				if (player.playingMusic)
				{
					FlxG.sound.music.stop();
					FlxG.sound.music.volume = 0;

					if(vocals != null) //Sync vocals to Inst
					{
						vocals.stop();
						vocals.volume = 0;
						vocals.destroy();
						vocals = null;
					}

					if (vocalsOpp != null)
					{
						vocalsOpp.stop();
						vocalsOpp.volume = 0;
						vocalsOpp.destroy();
						vocalsOpp = null;
					}
					instPlaying = -1;
					songInstPlaying = false;

					player.playingMusic = false;
					player.switchPlayMusic();

					FlxG.sound.playMusic(Paths.music('aviOST/seekingFreedom'), 0);
					FlxTween.tween(FlxG.sound.music, {volume: 1}, 1);
				}
				else
				{
					persistentUpdate = false;
					if(colorTween != null) {
						colorTween.cancel();
					}
					FlxG.sound.play(Paths.sound('cancelMenu'));
					MusicBeatState.switchState(new GeneralMenu());
					FlxG.mouse.visible = true;
				}
			}

			if(ctrl && maniaSkinSpr != null && !player.playingMusic)
			{
				if (maniaSkin == 2)
					maniaSkin = 0;
				else
					maniaSkin += 1;
				maniaSkinSpr.loadGraphic(Paths.image('$path/maniaSkins/skin$maniaSkin'));
			}
			else if(space && freeplayMenuList != 3)
			{
				if(instPlaying != curSelected && !disableSpace && !player.playingMusic)
				{
					FlxG.sound.music.volume = 0;
					FlxG.sound.music.fadeIn(1.0, 0.0, 0.7);
					songInstPlaying = true;

					if (songs[curSelected].songName == "Don't Cross!")
					{
						FlxG.sound.playMusic(Paths.inst("dont-cross"));
						vocals = new FlxSound().loadEmbedded(Paths.voices("dont-cross", 'Player'));
						FlxG.sound.list.add(vocals);
						vocals.persist = true;
						vocals.looped = true;

						vocalsOpp = new FlxSound().loadEmbedded(Paths.voices("dont-cross", 'Opponent'));
						FlxG.sound.list.add(vocalsOpp);
						vocalsOpp.persist = true;
						vocalsOpp.looped = true;
					}
					else
					{
						FlxG.sound.playMusic(Paths.inst(songs[curSelected].songName));
						var file:Dynamic = Paths.voices(songs[curSelected].songName, 'Player');
						var fileBackup:Dynamic = Paths.voices(songs[curSelected].songName);
						if (Std.isOfType(file, Sound) || OpenFlAssets.exists(file))
						{
							vocals = new FlxSound().loadEmbedded(file);
							FlxG.sound.list.add(vocals);
							vocals.persist = true;
							vocals.looped = true;
						}

						if (Std.isOfType(fileBackup, Sound) || OpenFlAssets.exists(fileBackup))
						{
							vocals = new FlxSound().loadEmbedded(fileBackup);
							FlxG.sound.list.add(vocals);
							vocals.persist = true;
							vocals.looped = true;
						}

						var file2:Dynamic = Paths.voices(songs[curSelected].songName, 'Opponent');
						if (Std.isOfType(file2, Sound) || OpenFlAssets.exists(file2))
						{
							vocalsOpp = new FlxSound().loadEmbedded(file2);
							FlxG.sound.list.add(vocalsOpp);
							vocalsOpp.persist = true;
							vocalsOpp.looped = true;
						}
					}

					if(vocals != null) //Sync vocals to Inst
					{
						vocals.play();
						vocals.volume = 0;
					}

					if (vocalsOpp != null)
					{
						vocalsOpp.play();
						vocalsOpp.volume = 0;
					}

					if (FlxG.sound.music.fadeTween != null)
						FlxG.sound.music.fadeTween.cancel();

					FlxTween.num(Conductor.bpm, getBPM(), 2, null, shitshitfuckfuck -> Conductor.bpm = shitshitfuckfuck);
					instPlaying = curSelected;

					player.playingMusic = true;
					player.curTime = 0;
					player.switchPlayMusic();
				}
				else if (instPlaying == curSelected && player.playingMusic)
				{
					player.pauseOrResume(player.paused);
				}
			}
			else if (accepted && !player.playingMusic)
			{
				songInstPlaying = false;
				persistentUpdate = false;
				selectedSomethin = true;
				var songLowercase:String = Paths.formatToSongPath(songs[curSelected].songName);
				if (isDontCross) // I've been suffering trying to get the randomizer to work with hardcoded charts only to find out this piece of shit was causing the crash oh my FUCKING GOD I'M GONNA RIP MY FUCKING HEAD OFF!!!!! (don)
					songLowercase = "dont-cross";
				var poop:String = Highscore.formatSong(songLowercase, curDifficulty); //fuck fuck fuck fuck fuck fuck
				trace(poop);
				
				try
				{
					PlayState.SONG = Song.loadFromJson(poop, songLowercase, FlxG.random.int(1, 11));
					PlayState.isStoryMode = false;
					PlayState.storyDifficulty = curDifficulty;

					for (icon in iconArray) if (freeplayMenuList != 2) icon.scale.set(1.25, 1.25);

					if(colorTween != null) {
						colorTween.cancel();
					}
				}
				catch(e:Dynamic)
				{
					trace('ERROR! $e');

					var errorStr:String = e.toString();
					if(errorStr.startsWith('[file_contents,assets/data/')) errorStr = 'Missing file: ' + errorStr.substring(34, errorStr.length-1); //Missing chart
					missingText.text = 'ERROR WHILE LOADING CHART:\n$errorStr';
					missingText.screenCenter(Y);
					missingText.visible = true;
					missingTextBG.visible = true;
					FlxG.sound.play(Paths.sound('cancelMenu'));

					super.update(elapsed);
					return;
				}

				if (freeplayMenuList == 2)
				{
					FlxG.sound.music.stop();
					LoadingState.loadAndSwitchState(new PlayState());
				} else {
					FlxG.sound.music.fadeOut(2.3, 0, tw -> LoadingState.loadAndSwitchState(new PlayState()));
					FlxG.camera.shake(.005, 5);
					FlxG.camera.zoom += .25;
					FlxTween.tween(FlxG.camera, {zoom: 1}, .35, {ease: FlxEase.cubeOut});
					camHUD.fade(FlxColor.BLACK, 2);
					confirmSound.play(false, 0, 4);
					confirmSound.fadeOut(4);
				}
				FlxG.sound.music.volume = 0;
			}
			else if(controls.RESET && !player.playingMusic)
			{
				persistentUpdate = false;
				openSubState(new ResetScoreSubState(songs[curSelected].songName, curDifficulty, songs[curSelected].songCharacter));
				FlxG.sound.play(Paths.sound('funkinAVI/menu/scrollSfx'));
			}
		}
	}

    override function beatHit() {
		super.beatHit();

		if (curBeat % 2 == 0 && freeplayMenuList != 2)
		{
			spawnMusicalNote();
			if (songInstPlaying)
				for (icon in iconArray) icon.scale.set(0.9, 0.9);
		}
	}

    function createMenuBG()
	{
		if (freeplayMenuList != 2)
		{
			AppIcon.changeIcon("newIcon");
			bg = new FlxSprite().loadGraphic(Paths.image('$path/background'));
			bg.alpha = 0.5;
			bg.updateHitbox();
			bg.setPosition(-150, -200);
			bg.antialiasing = ClientPrefs.data.antialiasing;
			add(bg);

			if (!ClientPrefs.data.lowQuality)
			{
				spectrum = new SpectrumWaveform(0, 370, FlxG.sound.music, 700, FlxG.height, TO_UP_FROM_DOWN, ROUNDED, FlxColor.WHITE);
				spectrum.design = ROUNDED;
				spectrum.roundValue = 30;
				spectrum.barWidth = 6;
				spectrum.barSpacing = 9;
				add(spectrum);
			}

			final table = new FlxSprite().loadGraphic(Paths.image('$path/table1'));
			table.updateHitbox();
			table.setPosition(-130, (FlxG.height * .5) - 10);

			final albumCover = new FlxSprite().loadGraphic(Paths.image('$path/albumcoverframe2'));
			albumCover.scale.set(1.1, 1.1);
			albumCover.updateHitbox();
			albumCover.setPosition(50, 80);

			final book = new FlxSprite().loadGraphic(Paths.image('$path/book'));
			book.scale.set(1.2, 1.2);
			book.updateHitbox();
			book.setPosition(-30, FlxG.height - (book.height * .45));

			final rug = new FlxSprite().loadGraphic(Paths.image('$path/rugthing'));
			rug.scale.set(2, 2);
			rug.updateHitbox();
			rug.setPosition(FlxG.width - (rug.frameWidth * 1.485), -130);

			final gramo = new FlxSprite().loadGraphic(Paths.image('$path/gramo11'));
			gramo.scale.set(1.35, 1.35);
			gramo.updateHitbox();
			gramo.setPosition(FlxG.width - (gramo.frameWidth * 1.2), -50);

			disc = new FlxSprite().loadGraphic(Paths.image('$path/discfull'));
			disc.scale.set(1.35, 1.35);
			disc.updateHitbox();
			disc.setPosition(FlxG.width * .7, ((gramo.height - disc.height) * .5) + 20);
			disc.cameras = [camHUD];
			disc.antialiasing = ClientPrefs.data.antialiasing;

			final shade = new FlxSprite().loadGraphic(Paths.image('$path/songtextshade'));
			shade.scale.set(1.2, 1.2);
			shade.x = disc.x - 60;
			shade.y = disc.y + 140;

			final overlay = new FlxSprite().loadGraphic(Paths.image('$path/overlay'));
			overlay.setGraphicSize(FlxG.width * 1.135, FlxG.height * 1.135);
			overlay.updateHitbox();
			overlay.screenCenter();

			for (i in [table, albumCover, book, rug, gramo, shade, overlay])
			{
				i.antialiasing = ClientPrefs.data.antialiasing;
				i.cameras = [camHUD];
				add(i);
			}
			insert(members.indexOf(gramo), disc);
		}
		else {
			AppIcon.changeIcon("legacyIcon");
			bg = new FlxSprite().loadGraphic(Paths.image(path + '/menuFreeplay'));
			bg.screenCenter();
			add(bg);
		}
	}

	function createUIComponents()
	{
		if (freeplayMenuList != 2)
		{
			scoreText = new FlxText(FlxG.width * 0.7, 5, 450, "", 32);
			scoreText.x += 350;
			diffText = new FlxText(scoreText.x, scoreText.y, 500, "", 24);
			gimmickInfo = new FlxText(30, 510, 290, "Mechanics - None");
			freeplayCtrlTxt = new FlxText(370, 510, 260, "Left & Right Keybinds - Change Song Choice\n\nESC - Exit Menu\n\nENTER - Play Song (Game)\n\nSPACE - Play Song (Music Player)", 36);
			final boxBot = new FlxSprite().loadGraphic(Paths.image('$path/botplayBtn/botplayUI'));
			offandon = new FlxSprite().loadGraphic(Paths.image('$path/botplayBtn/off'));

			offandon.screenCenter(X);
			boxBot.screenCenter(X);
	
			if(ClientPrefs.data.gameplaySettings["botplay"] == true)  offandon.loadGraphic(Paths.image('$path/botplayBtn/on'));
			scoreText.setFormat(Paths.font("newFreeplayFont.ttf"), 32, FlxColor.WHITE, CENTER);
			gimmickInfo.setFormat(Paths.font("newFreeplayFont.ttf"), 20, FlxColor.BLACK, CENTER);
			diffText.alignment = CENTER;
			diffText.font = scoreText.font;
			freeplayCtrlTxt.setFormat(Paths.font('newFreeplayFont.ttf'), 16, FlxColor.BLACK, LEFT);

			for (i in [scoreText, diffText, gimmickInfo, freeplayCtrlTxt, boxBot, offandon])
			{
				i.antialiasing = ClientPrefs.data.antialiasing;
				i.cameras = [camHUD];
				add(i);
			}
			albumHolder = new FlxTypedGroup<FlxSprite>();
			add(albumHolder);
		}
		else {
			grpSongs = new FlxTypedGroup<Alphabet>();
			add(grpSongs);

			var textBG:FlxSprite = new FlxSprite(0, FlxG.height - 26).makeGraphic(FlxG.width, 26, 0xFF000000);
			botplaytext = new FlxText(textBG.x, textBG.y + 4, FlxG.width, 'Press B to toggle Botplay. Botplay: ${ClientPrefs.data.gameplaySettings["botplay"] == true ? 'ON' : 'OFF'}', 18);
			scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
			scoreBG = new FlxSprite(scoreText.x - 6, 0).makeGraphic(1, 66, 0xFF000000);
			diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
			scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);
			scoreBG.alpha = 0.6;
			diffText.alignment = CENTER;
			diffText.font = scoreText.font;
			diffText.x = scoreBG.getGraphicMidpoint().x;
			textBG.alpha = freeplayMenuList == 2 ? 0.6 : 0;
			botplaytext.setFormat(Paths.font("vcr.ttf"), 18, FlxColor.WHITE, CENTER);
			botplaytext.scrollFactor.set();

			for (i in [scoreBG, scoreText, diffText, textBG, botplaytext])
			{
				i.cameras = [camHUD];
				add(i);
			}
		}

		for (i in 0...songs.length)
		{
			var songText:FlxText;
			var album:FlxSprite;
			var songTextA:Alphabet;
			var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);

			if (freeplayMenuList != 2)
			{
				songText = new FlxText(0, 0, 570, songs[i].songName);
				album = new FlxSprite(-130, -160);
				if (songs[i].songCharacter != "mysteryfp")
					album.loadGraphic(Paths.imageAlbum((freeplayMenuList == 3 ? (songs[i].songName == "Alone" ? "volume1Album" : "volume2Album") : CoolUtil.spaceToDash(songs[i].songName.toLowerCase()))));
				else
					album.loadGraphic(Paths.imageAlbum("unknown-song"));

				songText.setFormat(Paths.font("newFreeplayFont.ttf"), 50, FlxColor.WHITE, CENTER);
				songText.setBorderStyle(OUTLINE, FlxColor.BLACK, 5);

				icon.x = 950;
				icon.screenCenter(Y);
				icon.setGraphicSize(Std.int(icon.width * 0.8));
				icon.antialiasing = ClientPrefs.data.antialiasing;
				icon.y += 150;
				icon.cameras = [camHUD];

				songText.screenCenter();
				songText.x -= 346;
				songText.y -= 280;
				songText.antialiasing = ClientPrefs.data.antialiasing;
				songText.cameras = [camHUD];

				songDisplay.push(songText);
				add(songText);

				album.scale.set(0.31, 0.3);
				album.antialiasing = ClientPrefs.data.antialiasing;
				album.cameras = [camHUD];
				albumHolder.add(album);

				icon.x += songs[i].iconOffset[0];
				icon.y += songs[i].iconOffset[1];

				if (freeplayMenuList == 3) // Hide icons in mania menu
					icon.visible = false;
			}
			else {
				songTextA = new Alphabet(100, (43 * i) + 120, songs[i].songName, true);

				songTextA.isMenuItem = true;
				songTextA.screenCenter(X); 			
				songTextA.changeX = false;
				icon.sprTracker = songTextA;

				songTextA.targetY = 5;
				grpSongs.add(songTextA);
			}

			iconArray.push(icon);
			add(icon);
		}

		if (freeplayMenuList == 3)
		{
			var maniaTab = new FlxSprite().loadGraphic(Paths.image('$path/maniaSkins/maniaTab'));
			maniaTab.cameras = [camHUD];
			add(maniaTab);
			maniaSkinSpr = new FlxSprite().loadGraphic(Paths.image('$path/maniaSkins/skin$maniaSkin'));
			maniaSkinSpr.cameras = [camHUD];
			add(maniaSkinSpr);
		}

		missingTextBG = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		missingTextBG.alpha = 0.6;
		missingTextBG.visible = false;
		missingTextBG.cameras = [camHUD];
		add(missingTextBG);
		
		missingText = new FlxText(50, 0, FlxG.width - 100, '', 24);
		missingText.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		missingText.scrollFactor.set();
		missingText.visible = false;
		missingText.cameras = [camHUD];
		add(missingText);
	}

	function changeDiff(change:Int = 0)
	{
		if (player.playingMusic)
			return;

		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = Difficulty.list.length-1;
		if (curDifficulty >= Difficulty.list.length)
			curDifficulty = 0;

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		intendedRating = Highscore.getRating(songs[curSelected].songName, curDifficulty);
		#end

		lastDifficultyName = Difficulty.getString(curDifficulty);

		positionHighscore();
	}

	var shittyTmr:FlxTimer;
	function changeSelection(change:Int = 0, playSound:Bool = true)
	{
		if(playSound) FlxG.sound.play(Paths.sound('funkinAVI/menu/scrollSfx'), 0.4);

		if (player.playingMusic)
			return;

		disableSpace = true;

		if (shittyTmr != null)
			shittyTmr.cancel();

		shittyTmr = new FlxTimer().start(0.88, function(tmr:FlxTimer) {
			disableSpace = false;
			shittyTmr = null;
		});

		if(ClientPrefs.data.flashing && freeplayMenuList != 3)
			FlxG.camera.flash(FlxColor.BLACK, 0.1);

		var lastList:Array<String> = Difficulty.list;
		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;

		var songName:String = songs[curSelected].songName;
		var categoryName:String = "???";
		var songArtist:String = songs[curSelected].composer;

		switch (freeplayMenuList)
		{
			case 0:
				{
					lime.app.Application.current.window.title = "Funkin.avi - Freeplay: Story Menu - " + songName + ' - Composed by: ' + songArtist;
					categoryName = "Story Songs";
				}
			case 1:
				{
					lime.app.Application.current.window.title = "Funkin.avi - Freeplay: Extras Menu - " + songName + " - Composed by: " + songArtist;
					categoryName = "Extra Songs";
				}
			case 2:
				{
					lime.app.Application.current.window.title = "Funkin.avi - Freeplay: Legacy Menu - " + songName + " - Composed by: " + songArtist;
					categoryName = "Legacy Songs";
				}
			case 3:
				{
					lime.app.Application.current.window.title = "Funkin.avi - Freeplay: Mania Menu - " + songName + " - Composed by: " + songArtist;
					categoryName = "Mania Songs";
				}
		}

		#if DISCORD_ALLOWED
		switch (songs[curSelected].songName)
		{
			case "Joygrim" | "Dentophobia" | "Scrapped" | "Neglection" | "Whimsical Bar Blues": DiscordClient.changePresence("Freeplay Menu", "It's a secret...", "icon", "disc-player");
			default: DiscordClient.changePresence("Freeplay Menu: " + categoryName, "Picking Song: " + songs[curSelected].songName, "icon", "disc-player");
		}
		#end
			
		var newColor:Int = songs[curSelected].color;
		if(newColor != intendedColor) {
			if(colorTween != null) {
				colorTween.cancel();
			}
			if (spectrumTwn != null) {
				spectrumTwn.cancel();
			}
			intendedColor = newColor;

			//Isn't ported yet, sorry!
			FAVIPauseSubState.colorSetup = intendedColor;

			if (spectrum != null)
			{
				spectrumTwn = FlxTween.color(spectrum, 1, spectrum.color, intendedColor, {
					onComplete: function(twn:FlxTween) {
						spectrumTwn = null;
					}
				});
			}
			colorTween = FlxTween.color(bg, 1, bg.color, intendedColor, {
				onComplete: function(twn:FlxTween) {
					colorTween = null;
				}
			});
		}

		var bullShit:Int = 0;

		if (freeplayMenuList != 2)
		{
			for (i in 0...iconArray.length)
			{
				iconArray[i].alpha = 0.001;
				iconArray[i].animation.curAnim.curFrame = 0;			
			}
			iconArray[curSelected].alpha = 1;
	
			if(songs[curSelected].songName == "Birthday")
				iconArray[curSelected].animation.curAnim.curFrame = 1;
			else if(songs[curSelected].songName.toLowerCase().replace(' ', '-').replace("'", '').replace('!', '') == "dont-cross")
				iconArray[curSelected].animation.curAnim.curFrame = 0;
			else
				iconArray[curSelected].animation.curAnim.curFrame = 2;
	
			for (s in 0...songDisplay.length)
				songDisplay[s].alpha = 0.001;

			for (a in albumHolder.members)
				a.visible = false;

			albumHolder.members[curSelected].visible = true;
			songDisplay[curSelected].alpha = 1;
			gimmickInfo.text = "Mechanics - " + songs[curSelected].mechanic;
		}
		else
		{
			for (i in 0...iconArray.length)
				iconArray[i].alpha = 0.6;
		
			iconArray[curSelected].alpha = 1;
		
			for (item in grpSongs.members)
			{
				item.targetY = bullShit - curSelected;
				bullShit++;
							
				item.alpha = 0.6;
				if (item.targetY == 0)
					item.alpha = 1;
			}
		}

		PlayState.storyWeek = songs[curSelected].week;
		Difficulty.loadFromWeek();

		if (freeplayMenuList != 2)
		{
			switch (CoolUtil.spaceToDash(songs[curSelected].songName.toLowerCase()))
			{
				case "don't-cross!":
					if(ClientPrefs.data.shaking) FlxG.camera.shake(0.015, FlxMath.MAX_VALUE_FLOAT);
	
				default:
					FlxG.camera.shake(0.01, 0.001);
			}
		}

		PlayState.storyDifficulty = curDifficulty;
		var difficultyRank = songs[curSelected].rankName;
		diffText.color = songs[curSelected].rankColor;

		if (freeplayMenuList == 2) diffText.text = 'RANK: ' + difficultyRank; else diffText.text = "Difficulty: " + difficultyRank;// display the text
		positionHighscore();

		var savedDiff:String = songs[curSelected].lastDifficulty;
		var lastDiff:Int = Difficulty.list.indexOf(lastDifficultyName);
		if(savedDiff != null && !lastList.contains(savedDiff) && Difficulty.list.contains(savedDiff))
			curDifficulty = Math.round(Math.max(0, Difficulty.list.indexOf(savedDiff)));
		else if(lastDiff > -1)
			curDifficulty = lastDiff;
		else if(Difficulty.list.contains(Difficulty.getDefault()))
			curDifficulty = Math.round(Math.max(0, Difficulty.defaultList.indexOf(Difficulty.getDefault())));
		else
			curDifficulty = 0;

		changeDiff();
		_updateSongLastDifficulty();
	}

	inline private function _updateSongLastDifficulty()
	{
		songs[curSelected].lastDifficulty = Difficulty.getString(curDifficulty);
	}

	private function positionHighscore() {
		if (freeplayMenuList == 2)
		{
			scoreText.x = FlxG.width - scoreText.width - 6;
			scoreBG.scale.x = FlxG.width - scoreText.x + 6;
			scoreBG.x = FlxG.width - (scoreBG.scale.x / 2);
			diffText.x = Std.int(scoreBG.x + (scoreBG.width / 2));
			diffText.x -= diffText.width / 2;
		}
		else
		{
			scoreText.x = 820;
			scoreText.y = 570;
			diffText.x = scoreText.x - 20;
			diffText.y = scoreText.y + 60;
		}
	}

	function changeBotPlay(){
		ClientPrefs.data.gameplaySettings["botplay"] = (ClientPrefs.data.gameplaySettings["botplay"] == true) ? false : true;
		if (freeplayMenuList != 2)
			if (ClientPrefs.data.gameplaySettings["botplay"] == true)
				offandon.loadGraphic(Paths.image('$path/botplayBtn/on'));
			else
				offandon.loadGraphic(Paths.image('$path/botplayBtn/off'));
		else
			if (ClientPrefs.data.gameplaySettings["botplay"] == true)
				botplaytext.text = 'Press B to toggle Botplay. Botplay: ON';
			else
				botplaytext.text = 'Press B to toggle Botplay. Botplay: OFF';
		return;
	}

	function spawnMusicalNote()
	{
		final musicNote = new FlxSprite(800, 130, Paths.image('favi/ui/bdaynotes/note_${FlxG.random.int(1, 3)}', 'shared'));
		musicNote.scale.set(.65, .65);
		musicNote.updateHitbox();
		musicNote.antialiasing = ClientPrefs.data.antialiasing;
		musicNote.setColorTransform(-1, -1, -1, 1, 255, 255, 255, 0);
		musicNote.cameras = [camHUD];
		add(musicNote);

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
		switch (CoolUtil.spaceToDash(songs[curSelected].songName.toLowerCase()))
		{
			case 'devilish-deal': bpm = 90;
			case 'isolated' | 'isolated-legacy': bpm = 165;
			case 'lunacy': bpm = 188;
			case 'delusional' | 'bless': bpm = 175;
			case 'hunted' | 'malfunction-legacy' | 'war-dilemma' | 'mercy' | 'mercy-legacy' | 'hunted-legacy': bpm = 160;
			case 'laugh-track' | 'birthday' | 'scrapped': bpm = 180;
			case 'malfunction': bpm = 166;
			case 'twisted-grins' | "don't-cross!": bpm = 140;
			case 'cycled-sins': bpm = 161;
			case 'isolated-beta' | 'isolated-old': bpm = 120;
			case 'whimsical-bar-blues': bpm = 110;
		}
		return bpm;
	}

	public static function getDiffRank():String
	{
		var difficultyRank:String = 'HARD';
		switch (CoolUtil.spaceToDash(PlayState.SONG.song.toLowerCase()))
		{
			case 'devilish-deal' | 'hunted-legacy' | 'isolated-beta' | 'isolated-old': difficultyRank = 'EASY';
			case 'isolated' | 'neglection' | 'resentment' | 'lunacy-legacy' | 'hunted' | 'mortiferum-risus' | 'isolated-legacy' | 'whimsical-bar-blues': difficultyRank = 'NORMAL';
			case 'delusional' | 'mercy' | 'malfunction-legacy': difficultyRank = 'INSANE';
			case 'malfunction': difficultyRank = 'null';
			case "dont-cross": difficultyRank = 'GOOD LUCK';
			case 'birthday': difficultyRank = 'PARTY';
			case "alone" | "am-i-real?" | 'mistful-wind': difficultyRank = "BASIC";
			case "ship-the-fart-yay-hooray-<3-(distant-stars)" | "ahh-the-scary-(somber-night)" | "your-final-bow": difficultyRank = "INTERMEDIATE";
			case "rotten-petals" | "the-wretched-tilezones-(simple-life)": difficultyRank = "CHALLENGING";
			case "seeking-freedom" | "curtain-call": difficultyRank = "EXPERT";
			default: difficultyRank = 'HARD';
		}
		return difficultyRank;
	}

	public static function getArtistName():String
	{
		var songArtist:String = 'Unknown';
		switch (PlayState.SONG.song)
		{
			case "Devilish Deal" | "Isolated" | "Lunacy" | "Malfunction" | "Lunacy Legacy" | "Malfunction Legacy" | "Mercy Legacy": songArtist = "obscurity.";
			case "Delusional" | "Birthday" | "Delusional Legacy": songArtist = "FR3SHMoure";
			case "Hunted" | "Hunted Legacy" | "Cycled Sins" | "Cycled Sins Legacy" | "Alone": songArtist = "JBlitz";
			case "Laugh Track" | "Dont Cross" | "Bless" | "Twisted Grins" | "Scrapped" | "Mistful Wind": songArtist = "Lasagnacat";
			case "Isolated Beta" | "Isolated Old" | "Rotten Petals" | "Seeking Freedom" | "Your Final Bow" | "Am I Real?": songArtist = "Yama Haki/Toko";
			case "Twisted Grins Legacy" | "Curtain Call": songArtist = "Sayan Sama";
			case "Isolated Legacy": songArtist = "Toko & obscurity.";
			case "War Dilemma": songArtist = "Sayan Sama & obscurity.";
			case "Mercy": songArtist = "Ophomix24";
			case "Ship the Fart Yay Hooray <3 (Distant Stars)" | "Ahh the Scary (Somber Night)" | "The Wretched Tilezones (Simple Life)": songArtist = "ForFurtherNotice";
			case "Whimsical Bar Blues": songArtist = "inneaux & Sayan Sama";
			default: songArtist = "Unknown";
		}
		return songArtist;
	}

	override function closeSubState() {
		changeSelection(0, false);
		persistentUpdate = true;
		super.closeSubState();
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
	public var mechanic:String = "";
	public var iconOffset:Array<Int> = [0, 0];
	public var folder:String = "";
	public var lastDifficulty:String = null;

	public function new(song:String, week:Int, songCharacter:String, color:Int, composer:String, rankName:String, rankColor:FlxColor, iconOffset:Array<Int>, mechanic:String)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
		this.color = color;
		this.composer = composer;
		this.rankName = rankName;
		this.rankColor = rankColor;
		this.iconOffset = iconOffset;
		this.mechanic = mechanic;
		if(this.folder == null) this.folder = '';
	}
}