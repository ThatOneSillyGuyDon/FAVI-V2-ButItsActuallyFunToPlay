package states.menus;

import flash.text.TextField;
import flixel.addons.transition.FlxTransitionableState;
import lime.utils.Assets;
import flixel.system.FlxSound;
import openfl.utils.Assets as OpenFlAssets;
import openfl.filters.BitmapFilter;
import openfl.filters.ShaderFilter;
#if MODS_ALLOWED
import sys.FileSystem;
#end
import sys.thread.Mutex;
import sys.thread.Thread;
import openfl.media.Sound;
import backend.data.ClientPrefs;

class FreeplayState extends MusicBeatState
{
	var songs:Array<SongMetadata> = [];

	var selector:FlxText;
	private static var curSelected:Int = 0;
	var curDifficulty:Int = -1;
	private static var lastDifficultyName:String = '';

	var scoreBG:FlxSprite;
	var scoreText:FlxText;
	var diffText:FlxText;
	var lerpScore:Int = 0;
	var lerpRating:Float = 0;
	var intendedScore:Int = 0;
	var intendedRating:Float = 0;

	var freeplayCtrlTxt:FlxText;
	var menuType:FlxText;

	var path:String = 'Funkin_avi/freeplay';

	private var grpSongs:FlxTypedGroup<Alphabet>;

	private var albumHolder:FlxTypedGroup<FlxSprite>;

	private var songDisplay:Array<FlxText> = [];
	private var curPlaying:Bool = false;

	private var iconArray:Array<HealthIcon> = [];

	private var bg:Null<FlxSprite>;

	var album:FlxSprite;

	var bgslider:FlxSprite;
	var musicPlayer:FlxSprite;
	var musicNotes:FlxSprite;
	var disc:FlxSprite;
	var arrows:FlxSprite;

	var camGame:FlxCamera; // Main camera (including shaders n shit)
	var camHUD:FlxCamera; // Objects
	var camOther:FlxCamera; // Gameplay Changers + Fade transitions

	var defaultCamZoom:Float = 1;
	var camZoomTween:FlxTween;

	var defaultShader2:FlxRuntimeShader;
	var smilesShader:FlxRuntimeShader;
	var mercyShader:FlxRuntimeShader;
	var mercyShader2:FlxRuntimeShader;	
	var getBlessed:FlxRuntimeShader;
	var glitchyStuff:FlxRuntimeShader;
	var chromAberration:FlxRuntimeShader;
	var urFucked:FlxRuntimeShader;
	var pixelShader:FlxRuntimeShader;
	var shaderTime:Float = 0;
	
	var gradient:FlxSprite;
	var coolFilter:FlxSprite;

	var spectrum:SpectrumWaveform;

	public static var freeplayMenuList = 0;

	public static var difficultyRank:String = 'HARD';
	public static var songArtist:String = "Unknown";

	var intendedColor:Int;
	var colorTween:FlxTween;
	var spectrumTwn:FlxTween;
	var crossRandom:Int = FlxG.random.int(1, 11);

	public static var maniaSkin:Int = 0;
	var maniaSkinSpr:FlxSprite;

	var songText2:FlxText;
	var songText:Alphabet;
	var gimmickInfo:FlxText;

	var offandon:FlxSprite;

	// making this a public static var so the disc just doesn't stop moving at all when going in and out of this menu
	public static var bpm:Float = 1;

	public static var songInstPlaying:Bool = false;

	// this is only so it can fade because this fucking shit is 6 seconds long
	public static var confirmSound:FlxSound;

	override function create()
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		lime.app.Application.current.window.title = "Funkin.avi - Freeplay: Setting Up Category...";

		/**
		 * how addSong() function works here:
		 * 
		 * Song Name - Week ID - Freeplay Icon Name - BG Color - Composer Name - Rank Name - Rank Color - Freeplay Icon Offset (only applies in the new menu UI, gimmicks description)
		 */

		// Categories, Shaders, and Songlist Setup
		switch (freeplayMenuList)
		{
			case 0: // Story Songs Menu
				{
					defaultShader2 = new FlxRuntimeShader(Shaders.monitorFilter, null, 140);
					chromAberration = new FlxRuntimeShader(Shaders.aberration, null, 150);
					chromAberration.setFloat('aberration', 0.07);
					chromAberration.setFloat('effectTime', 0.005);

					addSong('Devilish Deal', 3, 'satanddNEW', FlxColor.fromRGB(65, 88, 94), 'obscurity', 'EASY', FlxColor.WHITE, [25, -18], "None");
					addSong('Isolated', 3, 'avier', FlxColor.fromRGB(60, 60, 60), 'obscurity', 'NORMAL', FlxColor.fromRGB(255, 220, 220), [15, 0], "Modcharts that move notes on occasion.");
					addSong('Lunacy', 3, 'lunaavier', FlxColor.fromRGB(69, 54, 54), 'obscurity', 'HARD', FlxColor.fromRGB(255, 187, 187), [15, 0], "Modcharts that may cause visual distortion.");
					addSong('Delusional', 3, 'deluavier', FlxColor.fromRGB(79, 32, 32), 'FR3SHMoure', 'INSANE', FlxColor.fromRGB(255, 110, 110), [15, 0], "Modcharts that may cause visual distortion");
				}
			case 1: // Extras Menu
				{		
					getBlessed = new FlxRuntimeShader(Shaders.bloom_alt, null, 120);
					glitchyStuff = new FlxRuntimeShader(Shaders.vignetteGlitch, null, 130);
					chromAberration = new FlxRuntimeShader(Shaders.aberration, null, 150);
					chromAberration.setFloat('aberration', 0.07);
					chromAberration.setFloat('effectTime', 0.005);
					mercyShader = new FlxRuntimeShader(Shaders.vhsFilter, null, 130);
					mercyShader2 = new FlxRuntimeShader(Shaders.cameraMovement, null, 150);
					urFucked = new FlxRuntimeShader(Shaders.theBlurOf87, null, 150);
					urFucked.setFloat('amount', 1);
					smilesShader = new FlxRuntimeShader(Shaders.tvStatic, null, 120);
					defaultShader2 = new FlxRuntimeShader(Shaders.monitorFilter, null, 140);
					pixelShader = new FlxRuntimeShader(Shaders.unregisteredHyperCam2Quality, null, 140);
					pixelShader.setFloat('size', 7.5);

					//if (GameData.episode1FPLock == 'unlocked')
					//{
						addSong('Hunted', 3, (GameData.huntedLock != 'unlocked' && GameData.huntedLock != 'beaten' ? 'mysteryfp' : 'goofy'), FlxColor.fromRGB(94, 28, 35), 'JBlitz', 'NORMAL', FlxColor.fromRGB(255, 220, 220), (GameData.huntedLock == "beaten" || GameData.huntedLock == "unlocked" ? [24, -8] : [25, 0]), "Modcharts that may cause visual distortion.");
						addSong('Laugh Track', 3, (GameData.rickyLock != 'unlocked' && GameData.rickyLock != 'beaten' ? 'mysteryfp' : 'ricky'), FlxColor.fromRGB(181, 0, 0), 'PualTheUnTruest', 'HARD', FlxColor.fromRGB(255, 187, 187), (GameData.rickyLock == "beaten" || GameData.rickyLock == "unlocked" ? [20, -15] : [25, 0]), "None");
						addSong('Bless', 3, (GameData.blessLock != 'unlocked' && GameData.blessLock != 'beaten' ? 'mysteryfp' : 'noise'), FlxColor.WHITE, 'PualTheUnTruest', 'HARD', FlxColor.fromRGB(255, 187, 187), (GameData.blessLock == "beaten" || GameData.blessLock == "unlocked" ? [30, -10] : [25, 0]), "None");
						//addSong('Scrapped', 3, (GameData.scrappedLock != 'unlocked' && GameData.scrappedLock != 'beaten' ? 'mysteryfp' : 'rs'), FlxColor.fromRGB(0, 0, 0), 'FR3SHMoure', 'HARD', FlxColor.fromRGB(255, 187, 187));
						addSong("Don't Cross!", 3, (GameData.crossinLock != 'unlocked' && GameData.crossinLock != 'beaten' ? 'mysteryfp' : 'cross'), FlxColor.fromRGB(255, 0, 0), 'PualTheUnTruest', 'GOOD LUCK', FlxColor.fromRGB(201, 0, 0), (GameData.crossinLock == "beaten" || GameData.crossinLock == "unlocked" ? [23, -10] : [25, 0]), "Chart is randomized every attempt.");
						addSong('War Dilemma', 3, (GameData.warLock != 'unlocked' && GameData.warLock != 'beaten' ? 'mysteryfp' : 'ethernalg'), FlxColor.fromRGB(204, 41, 103), 'Sayan Sama & obscurity', 'HARD', FlxColor.fromRGB(255, 187, 187), (GameData.warLock == "beaten" || GameData.warLock == "unlocked" ? [24, 1] : [25, 0]), "Modcharts that may cause visual distortion.");
						addSong('Twisted Grins', 3, (GameData.tgLock != 'unlocked' && GameData.tgLock != 'beaten' ? 'mysteryfp' : 'smile'), FlxColor.fromRGB(54, 38, 38), 'PualTheUnTruest', 'HARD', FlxColor.fromRGB(255, 187, 187), (GameData.tgLock == "beaten" || GameData.tgLock == "unlocked" ? [25, -10] : [25, 0]), "Scroll speed changes & Modcharts that may cause visual distortion");
						addSong('Mercy', 3, (GameData.mercyLock != 'beaten' && GameData.mercyLock != 'beaten' ? 'mysteryfp' : 'walt'), FlxColor.fromRGB(176, 169, 116), 'Ophomix24', 'INSANE', FlxColor.fromRGB(255, 110, 110), (GameData.mercyLock == "beaten" || GameData.mercyLock == "unlocked" ? [27, -20] : [25, 0]), "Drains your health until death. Utilizes the mechanic keybind, highly recommend checking your controls setting before playing.");
						//addSong('Neglection', 3, (GameData.pnmLock != 'unlocked' && GameData.pnmLock != 'beaten' ? 'mysteryfp' : 'pnm'), FlxColor.fromRGB(117, 86, 27), 'AttackPan', 'NORMAL', FlxColor.fromRGB(255, 220, 220));
						addSong('Cycled Sins', 3, (GameData.sinsLock != 'unlocked' && GameData.sinsLock != 'beaten' ? 'mysteryfp' : 'relapseNEW-pixel'), FlxColor.fromRGB(105, 30, 30), 'JBlitz', 'HARD', FlxColor.fromRGB(255, 187, 187), (GameData.sinsLock == "beaten" || GameData.sinsLock == "unlocked" ? [24, -21] : [25, 0]), "Dodge Relapse Mouse's gunshots. Utilizes the mechanic keybind, highly recommend checking your controls setting before playing."); //messing with the saves for this later
						//addSong('Whimsical-Bar-Blues', 3, 'mick-isolated-new', FlxColor.fromRGB(133, 190, 255), 'inneaux & Sayan Sama', 'NORMAL', FlxColor.fromRGB(255, 220, 220));
					//}
					/*
					if (GameData.episode2FPLock == 'unlocked')
					{
						addSong('Scrapped', 3, (GameData.scrappedLock != 'unlocked' && GameData.scrappedLock != 'beaten' ? 'mysteryfp' : 'rs'), FlxColor.fromRGB(0, 0, 0), 'FR3SHMoure', 'HARD', FlxColor.fromRGB(255, 187, 187), [0, 0], "None");
					}
					*/
					
					if (GameData.canAddMalfunction)
					{
						addSong('Malfunction', 3, (GameData.malfunctionLock != 'unlocked' && GameData.malfunctionLock != 'beaten' ? 'mysteryfp' : 'mal-pixel'), FlxColor.fromRGB(150, 149, 186), 'obscurity', null, FlxColor.WHITE, (GameData.malfunctionLock == "beaten" || GameData.malfunctionLock == "unlocked" ? [27, 0] : [25, 0]), "Contains extreme flashing lights, very unforgiving modcharts, life system & note gimmicks. Mechanics are enabled by default upon playing.\nGood luck."); // Because Malfunction is getting some major upgrades later
					}
					
					if ((GameData.birthdayLocky == 'beaten' || GameData.birthdayLocky == 'obtained') && GameData.birthdayLocky != "uninvited")
					{
						addSong('Birthday', 3, 'muckney', FlxColor.fromRGB(84, 255, 181), 'FR3SHMoure', 'PARTY', FlxColor.fromRGB(250, 234, 92), [15, -5], "Don't leave his party, you'll make him sad.");
					}
				}
			case 2: // Legacy Menu
				{
					//if (GameData.episode1FPLock == 'unlocked')
					//{
						addSong('Isolated Old', 3, (GameData.oldisolateLock != 'unlocked' && GameData.oldisolateLock != 'beaten' ? 'mysteryfp' : 'avierlegacy'), FlxColor.fromRGB(60, 60, 60), 'Toko', 'EASY', FlxColor.WHITE, [0, 0], "");
						addSong('Isolated Beta', 3, (GameData.betaisolateLock != 'unlocked' && GameData.betaisolateLock != 'beaten' ? 'mysteryfp' : 'avierlegacy'), FlxColor.fromRGB(60, 60, 60), 'Toko', 'EASY', FlxColor.WHITE, [0, 0], "");
						addSong('Isolated Legacy', 3, (GameData.legacyILock != 'unlocked' && GameData.legacyILock != 'beaten' ? 'mysteryfp' : 'avierlegacy'), FlxColor.fromRGB(60, 60, 60), 'Toko & obscurity', 'NORMAL', FlxColor.fromRGB(255, 220, 220), [0, 0], "");
						addSong('Lunacy Legacy', 3, (GameData.legacyLLock != 'unlocked' && GameData.legacyLLock != 'beaten' ? 'mysteryfp' : 'lunaold'), FlxColor.fromRGB(60, 60, 60), 'obscurity', 'NORMAL', FlxColor.fromRGB(255, 220, 220), [0, 0], "");
						addSong('Delusional Legacy', 3, (GameData.legacyDLock != 'unlocked' && GameData.legacyDLock != 'beaten' ? 'mysteryfp' : 'deluold'), FlxColor.fromRGB(60, 60, 60), 'FR3SHMoure', 'HARD', FlxColor.fromRGB(255, 187, 187), [0, 0], "");
						addSong('Hunted Legacy', 3, (GameData.legacyHLock != 'unlocked' && GameData.legacyHLock != 'beaten' ? 'mysteryfp' : 'goofyold'), FlxColor.fromRGB(0, 60, 40), 'JBlitz', 'EASY', FlxColor.WHITE, [0, 0], "");
						addSong('Twisted Grins Legacy', 3, (GameData.legacyTLock != 'unlocked' && GameData.legacyTLock != 'beaten' ? 'mysteryfp' : 'smileold'), FlxColor.fromRGB(115, 86, 86), 'Sayan Sama', 'HARD', FlxColor.fromRGB(255, 187, 187), [0, 0], "");
						//addSong('Facade', 3, (GameData.legacyRLock != 'unlocked' && GameData.legacyRLock != 'beaten' ? 'mysteryfp' : 'mr-smiles'), FlxColor.fromRGB(115, 86, 86), 'obscurity', 'NORMAL', FlxColor.fromRGB(255, 220, 220));
						//addSong('Bless-Legacy', 3, (GameData.legacyBLock != 'unlocked' && GameData.legacyBLock != 'beaten' ? 'mysteryfp' : 'white-noise'), FlxColor.WHITE, 'END_SELLA', 'HARD', FlxColor.fromRGB(255, 187, 187));
						addSong('Mercy Legacy', 3, (GameData.legacyWLock != 'unlocked' && GameData.legacyWLock != 'beaten' ? 'mysteryfp' : 'waltold'), FlxColor.fromRGB(153, 148, 112), 'obscurity', 'HARD', FlxColor.fromRGB(255, 187, 187), [0, 0], "");
						//addSong('Neglection-Legacy', 3, (GameData.legacyNLock != 'unlocked' && GameData.legacyNLock != 'beaten' ? 'mysteryfp' : 'pnm'), FlxColor.CYAN, 'AttackPan', 'NORMAL', FlxColor.fromRGB(255, 220, 220));
						addSong('Cycled Sins Legacy', 3, (GameData.legacySLock != 'unlocked' && GameData.legacySLock != 'beaten' ? 'mysteryfp' : 'relapseold-pixel'), FlxColor.fromRGB(115, 86, 86), 'JBlitz', 'HARD', FlxColor.fromRGB(255, 187, 187), [0, 0], "");
					//}
					
					//if (GameData.canAddMalfunction)
					//{
						addSong('Malfunction Legacy', 3, (GameData.legacyMLock != 'unlocked' && GameData.legacyMLock != 'beaten' ? 'mysteryfp' : 'mallegacy-pixel'), FlxColor.fromRGB(140, 120, 180), 'obscurity', 'INSANE', FlxColor.fromRGB(255, 110, 110), [0, 0], "");
					//}
				}
			case 3: // Secret Mania Menu
				{
					addSong('Rotten Petals', 3, "avier", FlxColor.WHITE, 'Yama Haki/Toko', "MANIA", FlxColor.CYAN, [15, 0], "None");
					//addSong('Seeking Freedom', 3, "avier", FlxColor.WHITE, 'Yama Haki/Toko', "MANIA", FlxColor.CYAN, [15, 0], "None");
					//addSong('Curtain Call', 3, "avier", FlxColor.WHITE, 'Sayan Sama', "MANIA", FlxColor.CYAN, [15, 0], "None");
					//addSong("Distant Stars", 3, "avier", FlxColor.WHITE, 'ForFurtherNotice', "MANIA", FlxColor.CYAN, [15, 0], "None");
					addSong("Somber Night", 3, "avier", FlxColor.WHITE, 'ForFurtherNotice', "MANIA", FlxColor.CYAN, [15, 0], "None");
					addSong("Simple Life", 3, "avier", FlxColor.WHITE, 'ForFurtherNotice', "MANIA", FlxColor.CYAN, [15, 0], "None");
				}
		}

		persistentUpdate = true;
		PlayState.isStoryMode = false;
		WeekData.reloadWeekFiles(false);

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Freeplay Menu", "Loading Category...", "icon", "disc-player");
		#end

		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camOther = new FlxCamera();

		camHUD.bgColor.alpha = 0;
		camOther.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD, false);
		FlxG.cameras.add(camOther, false);

		FlxG.cameras.setDefaultDrawTarget(camGame, true);

		CustomFadeTransition.nextCamera = camOther;

		bg = new FlxSprite();
		if (freeplayMenuList != 2)
			bg.loadGraphic(Paths.image('$path/background'));
		else
			bg.loadGraphic(Paths.image(path + '/menuFreeplay'));
		add(bg);

		if (freeplayMenuList != 2)
		{
			AppIcon.changeIcon("newIcon");
			// SORRY IT'S JUST LAGGY AS FUCK LOL :SOB:
			if (!ClientPrefs.lowQuality)
			{
				spectrum = new SpectrumWaveform(0, 370, FlxG.sound.music, 700, FlxG.height, TO_UP_FROM_DOWN, ROUNDED, 0xff001aff);
				spectrum.design = ROUNDED;
				spectrum.roundValue = 30;
				spectrum.barWidth = 6;
				spectrum.barSpacing = 9;
				add(spectrum);
			}

			bg.alpha = 0.5;

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
			book.cameras = [camHUD];
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

			final shade = new FlxSprite().loadGraphic(Paths.image('$path/songtextshade'));
			shade.scale.set(1.2, 1.2);
			shade.x = disc.x - 60;
			shade.y = disc.y + 140;
			add(shade);

			final overlay = new FlxSprite().loadGraphic(Paths.image('$path/overlay'));
			overlay.setGraphicSize(FlxG.width * 1.135, FlxG.height * 1.135);
			overlay.updateHitbox();
			overlay.screenCenter();
			overlay.cameras = [camOther];
			overlay.antialiasing = ClientPrefs.globalAntialiasing;
			add(overlay);

			final boxBot = new FlxSprite().loadGraphic(Paths.image('$path/botplaybox'));
			add(boxBot);
			boxBot.antialiasing = ClientPrefs.globalAntialiasing;
			boxBot.cameras = [camHUD];

			offandon = new FlxSprite().loadGraphic(Paths.image('$path/off'));
			if(ClientPrefs.gameplaySettings["botplay"] == true)  offandon.loadGraphic(Paths.image('$path/on'));
			add(offandon);
			offandon.antialiasing = ClientPrefs.globalAntialiasing;
			offandon.cameras = [camHUD];

			if (!ClientPrefs.lowQuality)
				for (obj in [spectrum, table, albumCover, book, rug, gramo, disc, shade])
					obj.cameras = [camHUD];
			else
				for (obj in [table, albumCover, book, rug, gramo, disc, shade])
					obj.cameras = [camHUD];
		}

		albumHolder = new FlxTypedGroup<FlxSprite>();
		add(albumHolder);
		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		confirmSound = new FlxSound();
		if (freeplayMenuList != 2) confirmSound.loadEmbedded(Paths.sound('funkinAVI/menu/confirmEpisode'));

		for (i in 0...songs.length)
		{
			songText2 = new FlxText(0, 0, 570, songs[i].songName);
			songText = new Alphabet(100, (43 * i) + 120, songs[i].songName, true);
			album = new FlxSprite(-130, -160);
			if (songs[i].songCharacter != "mysteryfp")
				album.loadGraphic(Paths.imageAlbum((freeplayMenuList == 3 ? "volume2Album" : CoolUtil.spaceToDash(songs[i].songName.toLowerCase()))));
			else
				album.loadGraphic(Paths.imageAlbum("unknown-song"));
		
			var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);

			if (freeplayMenuList == 2)
			{
				songText.isMenuItem = true;
				songText.screenCenter(X); 			
				songText.changeX = false;
				album.visible = false;
				icon.sprTracker = songText;
			}
			else 
			{
				songText.isMenuItem = true;

				songText2.setFormat(Paths.font("newFreeplayFont.ttf"), 50, FlxColor.WHITE, CENTER);
				songText2.setBorderStyle(OUTLINE, FlxColor.BLACK, 5);

				icon.x = 950;
				icon.screenCenter(Y);
				icon.setGraphicSize(Std.int(icon.width * 0.8));
				icon.antialiasing = ClientPrefs.globalAntialiasing;
				icon.y += 150;
				icon.cameras = [camHUD];

				songText2.screenCenter();
				songText2.x -= 346;
				songText2.y -= 280;
				songText2.antialiasing = ClientPrefs.globalAntialiasing;
				songText2.cameras = [camHUD];

				album.scale.set(0.31, 0.3);
				album.antialiasing = ClientPrefs.globalAntialiasing;
				album.cameras = [camHUD];
				albumHolder.add(album);

				// really dumb way of fixing the offsets but eh, whetever -demo
				// i mean, it could be worst but that looks good -jason
				icon.x += songs[i].iconOffset[0];
				icon.y += songs[i].iconOffset[1];
			}
			songText.targetY = 5;
			grpSongs.add(songText);

			songDisplay.push(songText2);
			add(songText2);

			// using a FlxGroup is too much fuss!
			iconArray.push(icon);
			add(icon);
		}
			
		// Basically an exact replica of the Funkin.avi V1 Freeplay Menu lol
		if (freeplayMenuList == 2)
		{
			AppIcon.changeIcon("legacyIcon");
			scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
			scoreBG = new FlxSprite(scoreText.x - scoreText.width, 0).makeGraphic(Std.int(FlxG.width * 0.35), 66, 0xFF000000);
			diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
			scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);
			scoreBG.alpha = 0.6;
			diffText.alignment = CENTER;
			diffText.font = scoreText.font;
			diffText.x = scoreBG.getGraphicMidpoint().x;
			scoreText.cameras = [camHUD];
			scoreBG.cameras = [camHUD];
			diffText.cameras = [camHUD];
			add(scoreBG);
			add(diffText);
			add(scoreText);
		}
		else //The Newer, Better, With terrible ass code which i didn't made but can't complain because it works so it's fine, Cooler Menu
		{
			scoreText = new FlxText(FlxG.width * 0.7, 5, 450, "", 32);
			scoreText.x += 350;
			scoreBG = new FlxSprite(scoreText.x - scoreText.width, 0).makeGraphic(Std.int(FlxG.width * 0.35), 66, 0xFF000000);
			diffText = new FlxText(scoreText.x, scoreText.y, 500, "", 24);
			gimmickInfo = new FlxText(30, 510, 290, "Mechanics - None");
			freeplayCtrlTxt = new FlxText(370, 530, 240, "Left & Right Keybinds - Change Song Choice\n\nESC - Exit Menu\n\nENTER - Play Song", 36);
			
			scoreText.setFormat(Paths.font("newFreeplayFont.ttf"), 32, FlxColor.WHITE, CENTER);
			gimmickInfo.setFormat(Paths.font("newFreeplayFont.ttf"), 20, FlxColor.BLACK, CENTER);
			diffText.alignment = CENTER;
			diffText.font = scoreText.font;
			freeplayCtrlTxt.setFormat(Paths.font('newFreeplayFont.ttf'), 20, FlxColor.BLACK, LEFT);

			freeplayCtrlTxt.antialiasing = ClientPrefs.globalAntialiasing;
			diffText.antialiasing = ClientPrefs.globalAntialiasing;
			scoreText.antialiasing = ClientPrefs.globalAntialiasing;

			add(diffText);
			add(scoreText);
			add(freeplayCtrlTxt);
			add(gimmickInfo);
			scoreText.cameras = [camHUD];
			diffText.cameras = [camHUD];
			freeplayCtrlTxt.cameras = [camHUD];
			gimmickInfo.cameras = [camHUD];
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

		if(curSelected >= songs.length) curSelected = 0;
		bg.color = songs[curSelected].color;
		intendedColor = bg.color;
		FAVIPauseSubState.colorSetup = intendedColor;
		if (spectrum != null) spectrum.color = intendedColor;

		if(lastDifficultyName == '')
		{
			lastDifficultyName = CoolUtil.defaultDifficulty;
		}
		curDifficulty = Math.round(Math.max(0, CoolUtil.defaultDifficulties.indexOf(lastDifficultyName)));
		
		changeSelection();
		changeDiff();

		var swag:Alphabet = new Alphabet(1, 0, "swag");

		var textBG:FlxSprite = new FlxSprite(0, FlxG.height - 26).makeGraphic(FlxG.width, 26, 0xFF000000);
		textBG.alpha = freeplayMenuList == 2 ? 0.6 : 0;
		add(textBG);

		#if PRELOAD_ALL
		var leText:String = "Press SPACE to listen to the Song / Press CTRL to open the Gameplay Changers Menu / Press RESET to Reset your Score and Accuracy.";
		var size:Int = 16;
		#else
		var leText:String = "Press CTRL to open the Gameplay Changers Menu / Press RESET to Reset your Score and Accuracy.";
		var size:Int = 18;
		#end
		var text:FlxText = new FlxText(textBG.x, textBG.y + 4, FlxG.width, leText, size);
		text.setFormat(Paths.font("vcr.ttf"), size, FlxColor.WHITE, RIGHT);
		text.scrollFactor.set();
		//add(text);

		if(!ClientPrefs.lowQuality)
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
					gradient = new FlxSprite().loadGraphic(Paths.image('UI/gimmicks/gradient'));
					gradient.screenCenter();
					gradient.setGraphicSize(Std.int(gradient.width * 0.8));
					gradient.alpha = .45;
					gradient.antialiasing = ClientPrefs.globalAntialiasing;
					add(gradient);
					gradient.cameras = [camHUD];
				}
	
				scratchStuff.cameras = [camHUD];
				grain.cameras = [camHUD];
			}
		
		if (!songInstPlaying) 
			Conductor.bpm = 98;

		super.create();
	}

	override function closeSubState() {
		changeSelection(0, false);
		persistentUpdate = true;
		super.closeSubState();
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String, color:Int, composer:String, rankName:String, rankColor:FlxColor, iconOffset:Array<Int>, gimmick:String)
	{
		songs.push(new SongMetadata(songName, weekNum, songCharacter, color, composer, rankName, rankColor, iconOffset, gimmick));
	}

	function weekIsLocked(name:String):Bool {
		var leWeek:WeekData = WeekData.weeksLoaded.get(name);
		return (!leWeek.startUnlocked && leWeek.weekBefore.length > 0 && (!StoryMenuState.weekCompleted.exists(leWeek.weekBefore) || !StoryMenuState.weekCompleted.get(leWeek.weekBefore)));
	}

	function changeBotPlay(){
		ClientPrefs.gameplaySettings["botplay"] = (ClientPrefs.gameplaySettings["botplay"] == true) ? false : true;
		if (ClientPrefs.gameplaySettings["botplay"] == true) {
			offandon.loadGraphic(Paths.image('$path/on'));
		} else {
			offandon.loadGraphic(Paths.image('$path/off'));
		}
		return;
	}

	var instPlaying:Int = -1;
	var disableSpace:Bool = false;
	public static var vocals:FlxSound = null;
	public static var bf_vocals:FlxSound = null;
	public static var opp_vocals:FlxSound = null;
	var holdTime:Float = 0;
	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		Conductor.songPosition = FlxG.sound.music.time;

		if (freeplayMenuList != 2)
		{
			for (icon in iconArray) icon.scale.set(FlxMath.lerp(0.8, icon.scale.x, CoolUtil.boundTo(1 - (elapsed * 9.6), 0, 1)), FlxMath.lerp(0.8, icon.scale.y, CoolUtil.boundTo(1 - (elapsed * 9.6), 0, 1)));
		}

		var isDontCross:Bool = songs[curSelected].songName == "Don't Cross!";

		if (musicNotes != null)
		{
			musicNotes.y = -110 + Math.sin(Conductor.songPosition/850)*((FlxG.height * 0.015));
			musicNotes.scale.set(FlxMath.lerp(.78, musicNotes.scale.x, CoolUtil.boundTo(1 - (elapsed * 9.6), 0, 1)), FlxMath.lerp(.78, musicNotes.scale.y, CoolUtil.boundTo(1 - (elapsed * 9.6), 0, 1)));
		}

		if (disc != null && songInstPlaying) 
		{
			disc.angle += Conductor.crochet / 1000 * 2;
		}

		if (FlxG.keys.justPressed.B) {
			changeBotPlay();
		}

		if (ClientPrefs.shaders) // bye bye lag
		{
			if (freeplayMenuList == 1)
			{
				shaderTime = Conductor.songPosition / 1000;

				glitchyStuff.setFloat('time', shaderTime);
				glitchyStuff.setFloat('prob', shaderTime);

				mercyShader.setFloat('time', shaderTime);
				mercyShader2.setFloat('time', shaderTime);

				smilesShader.setFloat('iTime', shaderTime);
				smilesShader.setFloat('uTime', shaderTime);
			}
		}

		if(songs[curSelected].songName == "Don't Cross!" && grpSongs.members[6] != null && grpSongs.members[6].exists)
			{
				grpSongs.members[3].shake(11, 10, 0.1);
				iconArray[3].shake(4, 30, 0.1);
			}

		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, CoolUtil.boundTo(elapsed * 24, 0, 1)));
		lerpRating = FlxMath.lerp(lerpRating, intendedRating, CoolUtil.boundTo(elapsed * 12, 0, 1));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;
		if (Math.abs(lerpRating - intendedRating) <= 0.01)
			lerpRating = intendedRating;

		var ratingSplit:Array<String> = Std.string(Highscore.floorDecimal(lerpRating * 100, 2)).split('.');
		if(ratingSplit.length < 2) { //No decimals, add an empty space
			ratingSplit.push('');
		}
		
		while(ratingSplit[1].length < 2) { //Less than 2 decimals in it, add decimals then
			ratingSplit[1] += '0';
		}

		if (freeplayMenuList == 2)
			scoreText.text = 'PERSONAL BEST: ' + lerpScore + ' (' + ratingSplit.join('.') + '%)';
		else
			scoreText.text = "Score: " + lerpScore;
		positionHighscore();

		var upP = freeplayMenuList == 2 ? controls.UI_UP_P : controls.UI_LEFT_P;
		var downP = freeplayMenuList == 2 ? controls.UI_DOWN_P : controls.UI_RIGHT_P;
		var accepted = controls.ACCEPT;
		var space = FlxG.keys.justPressed.SPACE;
		var ctrl = FlxG.keys.justPressed.CONTROL;

		var shiftMult:Int = 1;
		if(FlxG.keys.pressed.SHIFT) shiftMult = 3;

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
				{
					changeSelection((checkNewHold - checkLastHold) * ((freeplayMenuList == 2 ? controls.UI_UP : controls.UI_LEFT) ? -shiftMult : shiftMult));
					changeDiff();
				}
			}

			if(FlxG.mouse.wheel != 0)
			{
				FlxG.sound.play(Paths.sound('funkinAVI/menu/scrollSfx'), 0.2);
				changeSelection(-shiftMult * FlxG.mouse.wheel, false);
				changeDiff();
			}
		}

		if (controls.BACK)
		{
			persistentUpdate = false;
			if(colorTween != null) {
				colorTween.cancel();
			}
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new GeneralMenu());
			FlxG.mouse.visible = true;
		}

		if(ctrl && maniaSkinSpr != null)
		{
			if (maniaSkin == 2)
				maniaSkin = 0;
			else
				maniaSkin += 1;
			maniaSkinSpr.loadGraphic(Paths.image('$path/maniaSkins/skin$maniaSkin'));
		}
		else if(space && freeplayMenuList != 3)
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

		else if (accepted)
		{
			songInstPlaying = false;
			persistentUpdate = false;
			var songLowercase:String = Paths.formatToSongPath(songs[curSelected].songName);
			if (isDontCross) // I've been suffering trying to get the randomizer to work with hardcoded charts only to find out this piece of shit was causing the crash oh my FUCKING GOD I'M GONNA RIP MY FUCKING HEAD OFF!!!!! (don)
				songLowercase = "dont-cross";
			var poop:String = Highscore.formatSong(songLowercase, curDifficulty); //fuck fuck fuck fuck fuck fuck
			trace(poop);

			PlayState.SONG = Song.loadFromJson(poop, songLowercase, crossRandom);
			PlayState.isStoryMode = false;
			PlayState.storyDifficulty = curDifficulty;

			for (icon in iconArray) if (freeplayMenuList != 2) icon.scale.set(1.25, 1.25);

			trace('CURRENT WEEK: ' + WeekData.getWeekFileName());
			if(colorTween != null) {
				colorTween.cancel();
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
				camOther.fade(FlxColor.BLACK, 2);
				confirmSound.play(false, 0, 4);
				confirmSound.fadeOut(4);
			}

			FlxG.sound.music.volume = 0;
		}
		else if(controls.RESET)
		{
			persistentUpdate = false;
			openSubState(new ResetScoreSubState(songs[curSelected].songName, curDifficulty, songs[curSelected].songCharacter));
			FlxG.sound.play(Paths.sound('funkinAVI/menu/scrollSfx'));
		}
		super.update(elapsed);
	}

	function spawnMusicalNote()
		{
			final musicNote = new FlxSprite(800, 130, Paths.image('favi/ui/bdaynotes/note_${FlxG.random.int(1, 3)}', 'shared'));
			musicNote.scale.set(.65, .65);
			musicNote.updateHitbox();
			musicNote.antialiasing = ClientPrefs.globalAntialiasing;
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

	// i would remove this but too lazy to remove this function from other menus rn so I don't get any compiling errors lol
	public static function destroyFreeplayVocals() {
		if(vocals != null) {
			vocals.stop();
			vocals.destroy();
		}
		if(bf_vocals != null) {
			bf_vocals.stop();
			bf_vocals.destroy();
		}
		if(opp_vocals != null) {
			opp_vocals.stop();
			opp_vocals.destroy();
		}
		vocals = null;
		bf_vocals = null;
		opp_vocals = null;
	}

	function changeDiff(change:Int = 0)
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = CoolUtil.difficulties.length-1;
		if (curDifficulty >= CoolUtil.difficulties.length)
			curDifficulty = 0;

		lastDifficultyName = CoolUtil.difficulties[curDifficulty];

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		intendedRating = Highscore.getRating(songs[curSelected].songName, curDifficulty);
		#end

		difficultyRank = songs[curSelected].rankName;
		diffText.color = songs[curSelected].rankColor;

		PlayState.storyDifficulty = curDifficulty;
		if (freeplayMenuList == 2) diffText.text = 'RANK: ' + difficultyRank; else diffText.text = "Difficulty: " + difficultyRank;// display the text
		positionHighscore();
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

	var shittyTmr:FlxTimer;
	function changeSelection(change:Int = 0, playSound:Bool = true)
	{
		if(playSound) FlxG.sound.play(Paths.sound('funkinAVI/menu/scrollSfx'), 0.4);

		disableSpace = true;

		if (shittyTmr != null)
			shittyTmr.cancel();

		shittyTmr = new FlxTimer().start(0.88, function(tmr:FlxTimer) {
			disableSpace = false;
			shittyTmr = null;
		});

		if(ClientPrefs.flashing)
			FlxG.camera.flash(FlxColor.BLACK, 0.1);

		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;

		var songName:String = songs[curSelected].songName;
		songArtist = songs[curSelected].composer;

		switch (freeplayMenuList)
		{
			case 0: 
				{
					lime.app.Application.current.window.title = "Funkin.avi - Freeplay: Story Menu- " + songName + ' - Composed by: ' + songArtist;
				}
			case 1:
				{
					lime.app.Application.current.window.title = "Funkin.avi - Freeplay: Extras Menu - " + songName + " - Composed by: " + songArtist;
				}
			case 2:
				{
					lime.app.Application.current.window.title = "Funkin.avi - Freeplay: Legacy Menu - " + songName + " - Composed by: " + songArtist;
				}
			case 3:
				{
					lime.app.Application.current.window.title = "Funkin.avi - Freeplay: Mania Menu - " + songName + " - Composed by: " + songArtist;
				}
		}

		#if DISCORD_ALLOWED
		#if DEV_BUILD
		DiscordClient.changePresence("Freeplay Menu", "It's a secret...", "icon", "disc-player");
		#else
		DiscordClient.changePresence("Freeplay Menu", "Picking Song: " + songs[curSelected].songName, "icon", "disc-player");
		#end
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

		// selector.y = (70 * curSelected) + 30;

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		intendedRating = Highscore.getRating(songs[curSelected].songName, curDifficulty);
		#end

		var bullShit:Int = 0;

		if (freeplayMenuList != 2)
			{
						for (i in 0...iconArray.length)
						{
							iconArray[i].alpha = 0;
							iconArray[i].animation.curAnim.curFrame = 0;
							
						}
	
						iconArray[curSelected].alpha = 1;
	
						if(songs[curSelected].songName == "Birthday")
							iconArray[curSelected].animation.curAnim.curFrame = 1; // funi
						//i swear to god theres too much .replace
						else if(songs[curSelected].songName.toLowerCase().replace(' ', '-').replace("'", '').replace('!', '') == "dont-cross")
							iconArray[curSelected].animation.curAnim.curFrame = 0;
						else
							iconArray[curSelected].animation.curAnim.curFrame = 2;
	
						for (item in grpSongs.members)
						{
							item.targetY = bullShit - curSelected;
							bullShit++;
	
							item.alpha = 0;
						}
	
						for (s in 0...songDisplay.length)
							songDisplay[s].alpha = 0;

						for (a in albumHolder.members)
							a.visible = false;

						albumHolder.members[curSelected].visible = true;
	
						songDisplay[curSelected].alpha = 1;

						gimmickInfo.text = "Mechanics - " + songs[curSelected].gimmicksTxt;
			}
			else
			{
				for (i in 0...iconArray.length)
					iconArray[i].alpha = 0.6;
		
				iconArray[curSelected].alpha = 1;
	
				for (s in 0...songDisplay.length)
					songDisplay[s].alpha = 0;
		
				for (item in grpSongs.members)
				{
					item.targetY = bullShit - curSelected;
					bullShit++;
		
					
						item.alpha = 0.6;
					if (item.targetY == 0)
						item.alpha = 1;
				}
			}

		Paths.currentModDirectory = songs[curSelected].folder;
		PlayState.storyWeek = songs[curSelected].week;

		if (ClientPrefs.shaders) // to prevent lag
			{
				// ah yes, formatting made by vsc itself - jason
				if (freeplayMenuList != 2)
				{
					switch (CoolUtil.spaceToDash(songs[curSelected].songName.toLowerCase()))
					{
						case 'bless':
							FlxG.camera.shake(0.01, 0.001);
							if(!ClientPrefs.lowQuality) {
								FlxG.camera.setFilters(
									[
										new ShaderFilter(getBlessed), 
									]);
							}
	
						case 'malfunction':
							if(!ClientPrefs.lowQuality) {
								FlxG.camera.setFilters(
									[
										new ShaderFilter(glitchyStuff), 
										new ShaderFilter(chromAberration),
									]);
							}
							FlxG.camera.shake(0.01, 0.001);
	
						case "don't-cross!":
							if(!ClientPrefs.lowQuality) {
								FlxG.camera.setFilters(
									[
										new ShaderFilter(chromAberration)
									]);
							}
	
							if(ClientPrefs.shaking)
							FlxG.camera.shake(0.015, FlxMath.MAX_VALUE_FLOAT);
	
						case 'scrapped':
							if(!ClientPrefs.lowQuality) {
								FlxG.camera.setFilters(
									[
										new ShaderFilter(smilesShader),
										new ShaderFilter(chromAberration),
									]);
							}
							FlxG.camera.shake(0.01, 0.001);
	
						case 'cycled-sins':
							if(!ClientPrefs.lowQuality) {
								FlxG.camera.setFilters(
									[
										new ShaderFilter(chromAberration),
										new ShaderFilter(mercyShader2),
									]);
							}

						case 'twisted-grins' | 'resentment' | 'mortiferum-risus':
							if(!ClientPrefs.lowQuality)
								FlxG.camera.setFilters([new ShaderFilter(smilesShader)]);
	
						case 'mercy' | 'affliction':
							if(!ClientPrefs.lowQuality) {
							FlxG.camera.setFilters(
								[
									new ShaderFilter(mercyShader),
									new ShaderFilter(mercyShader2)
								]);
							}
						
						case 'birthday':
							if (freeplayMenuList == 3)
							{
								if (!ClientPrefs.lowQuality)
								{
									FlxG.camera.setFilters(
									[
										new ShaderFilter(chromAberration)
									]);
								}
							}
							else
							{
								FlxG.camera.setFilters([]);
								FlxG.camera.shake(0.01, 0.001);
							}
						
						case 'devilish-deal' | 'delusional':
							if(!ClientPrefs.lowQuality)
								FlxG.camera.setFilters([new ShaderFilter(chromAberration)]);
							FlxG.camera.shake(0.01, 0.001);
	
						default:
							FlxG.camera.setFilters([]); // fixed it yay
							FlxG.camera.shake(0.01, 0.001);
					}
				}
			}

		CoolUtil.difficulties = CoolUtil.defaultDifficulties.copy();
		var diffStr:String = "Hard";
		if(diffStr != null) diffStr = diffStr.trim(); //Fuck you HTML5

		if(diffStr != null && diffStr.length > 0)
		{
			var diffs:Array<String> = diffStr.split(',');
			var i:Int = diffs.length - 1;
			while (i > 0)
			{
				if(diffs[i] != null)
				{
					diffs[i] = diffs[i].trim();
					if(diffs[i].length < 1) diffs.remove(diffs[i]);
				}
				--i;
			}

			if(diffs.length > 0 && diffs[0].length > 0)
			{
				CoolUtil.difficulties = diffs;
			}
		}
		
		if(CoolUtil.difficulties.contains(CoolUtil.defaultDifficulty))
		{
			curDifficulty = Math.round(Math.max(0, CoolUtil.defaultDifficulties.indexOf(CoolUtil.defaultDifficulty)));
		}
		else
		{
			curDifficulty = 0;
		}

		difficultyRank = songs[curSelected].rankName;
		diffText.color = songs[curSelected].rankColor;

		if (freeplayMenuList == 2) diffText.text = 'RANK: ' + difficultyRank; else diffText.text = "Difficulty: " + difficultyRank;// display the text
		positionHighscore();

		var newPos:Int = CoolUtil.difficulties.indexOf(lastDifficultyName);
		//trace('Pos of ' + lastDifficultyName + ' is ' + newPos);
		if(newPos > -1)
		{
			curDifficulty = newPos;
		}
	}

	private function positionHighscore() {
		if (freeplayMenuList == 2)
		{
			scoreText.x = FlxG.width - scoreText.width - 5;
			scoreBG.width = scoreText.width + 8;
			scoreBG.x = FlxG.width - scoreBG.width;
			diffText.x = scoreBG.x + (scoreBG.width / 2) - (diffText.width / 2);
		}
		else
		{
			scoreText.x = 830;
			scoreText.y = 570;
			diffText.x = scoreText.x - 20;
			diffText.y = scoreText.y + 60;
		}
	}

	function getBPM():Float
	{
		switch (CoolUtil.spaceToDash(songs[curSelected].songName.toLowerCase()))
		{
			case 'devilish-deal': bpm = 90;
			case 'isolated' | 'isolated-legacy': bpm = 165;
			case 'lunacy': bpm = 188;
			case 'delusional' | 'bless': bpm = 175;
			case 'hunted' | 'malfunction-legacy' | 'war-dilemma' | 'mercy' | 'mercy-legacy' | 'hunted-legacy': bpm = 160;
			case 'laugh-track' | 'birthday': bpm = 180;
			case 'malfunction': bpm = 166;
			case 'twisted-grins' | "don't-cross!": bpm = 140;
			case 'cycled-sins': bpm = 161;
			case 'isolated-beta' | 'isolated-old': bpm = 120;
		}
		return bpm;
	}

	public static function getDiffRank():String
		{
			switch (CoolUtil.spaceToDash(PlayState.SONG.song.toLowerCase()))
			{
				case 'devilish-deal' | 'hunted-legacy' | 'isolated-beta' | 'isolated-old': difficultyRank = 'EASY';
				case 'isolated' | 'neglection' | 'resentment' | 'lunacy-legacy' | 'hunted' | 'mortiferum-risus' | 'isolated-legacy': difficultyRank = 'NORMAL';
				case 'delusional' | 'mercy' | 'malfunction-legacy': difficultyRank = 'INSANE';
				case 'malfunction': difficultyRank = 'null';
				case "dont-cross": difficultyRank = 'GOOD LUCK';
				case 'birthday': difficultyRank = 'PARTY';
				case "rotten-petals" | "seeking-freedom" | "your-final-bow" | "curtain-call" |"am-i-real?" | "a-true-monster" | "ship-the-fart-yay-hooray-<3-(distant-stars)" | "ahh-the-scary-(somber-night)" | "the-wretched-tilezones-(simple-life)": difficultyRank = "MANIA";
				default: difficultyRank = 'HARD';
			}
			return difficultyRank;
		}

		public static function getArtistName():String
		{
			switch (PlayState.SONG.song)
			{
				case "Devilish Deal" | "Isolated" | "Lunacy" | "Malfunction" | "Lunacy Legacy" | "Malfunction Legacy" | "Mercy Legacy": songArtist = "obscurity.";
				case "Delusional" | "Birthday" | "Delusional Legacy" | "A True Monster": songArtist = "FR3SHMoure";
				case "Hunted" | "Hunted Legacy" | "Cycled Sins" | "Cycled Sins Legacy": songArtist = "JBlitz";
				case "Laugh Track" | "Dont Cross" | "Bless" | "Twisted Grins": songArtist = "PualTheUnTruest";
				case "Isolated Beta" | "Isolated Old" | "Rotten Petals" | "Seeking Freedom" | "Your Final Bow": songArtist = "Yama Haki/Toko";
				case "Twisted Grins Legacy" | "Curtain Call": songArtist = "Sayan Sama";
				case "Isolated Legacy": songArtist = "Toko & obscurity.";
				case "War Dilemma": songArtist = "Sayan Sama & obscurity.";
				case "Mercy": songArtist = "Ophomix24";
				case "Ship the Fart Yay Hooray <3 (Distant Stars)" | "Ahh the Scary (Somber Night)" | "The Wretched Tilezones (Simple Life)": songArtist = "ForFurtherNotice";
				default: songArtist = "Unknown";
			}
			return songArtist;
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
	public var gimmicksTxt:String = "Unknown";
	public var folder:String = "";

	public function new(song:String, week:Int, songCharacter:String, color:Int, composer:String, rankName:String, rankColor:FlxColor, iconOffset:Array<Int>, gimmicksTxt:String)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
		this.color = color;
		this.composer = composer;
		this.rankName = rankName;
		this.rankColor = rankColor;
		this.iconOffset = iconOffset;
		this.gimmicksTxt = gimmicksTxt;
		this.folder = Paths.currentModDirectory;
		if(this.folder == null) this.folder = '';
	}
}