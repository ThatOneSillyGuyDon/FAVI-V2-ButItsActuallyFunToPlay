package states.menus.freeplay;

import openfl.filters.BitmapFilter;
import openfl.filters.ShaderFilter;
import openfl.media.Sound;
import sys.FileSystem;
import sys.thread.Mutex;
import sys.thread.Thread;

class FreeplaySongs extends MusicBeatState
{
	var songs:Array<SongMetadata> = [];

	static var curSelected:Int = 0;
	var curSongPlaying:Int = -1;
	var curDifficulty:Int = 1;
	private static var lastDifficultyName:String = '';

	var scoreText:FlxText;
	var diffText:FlxText;
	var lerpScore:Int = 0;
	var intendedScore:Int = 0;

	var songThread:Thread;
	var threadActive:Bool = true;
	var mutex:Mutex;
	var songToPlay:Sound = null;

	var freeplayCtrlTxt:FlxText;
	var menuType:FlxText;

	private var grpSongs:FlxTypedGroup<Alphabet>;

	private var songDisplay:Array<FlxText> = [];

	private var iconArray:Array<HealthIcon> = [];

	private var mainColor:Null<FlxColor> = FlxColor.WHITE;

	var path:String = 'Funkin_avi/freeplay/';

	private var bg:Null<FlxSprite>;
	private var delutranceBg:Null<FlxSprite>;

	var bgslider:FlxSprite;
	var musicPlayer:FlxSprite;
	var musicNotes:FlxSprite;
	var disc:FlxSprite;
	var arrows:FlxSprite;

	private var scoreBG:FlxSprite;

	private var existingSongs:Array<String> = [];
	private var existingDifficulties:Array<Array<String>> = [];

	// The fact is i have to do this for organization and stuff -jason
	var camGame:FlxCamera; // Main camera
	var camHUD:FlxCamera; // Shaders and stuff

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

	public var loadCustom:Bool = true;
	public static var freeplayMenuList = 0;

	public static var difficultyRank:String = 'HARD';

	public function new(?loadCustom:Bool = false)
	{
		super();
		this.loadCustom = loadCustom;
	}

	override function create()
	{
		Paths.clearUnusedMemory();

		super.create();

		closedState = true;

		// i am pretty sure this is gonna work
		new FlxTimer().start(0.005, _->closedState = false);
		
		lime.app.Application.current.window.title = "Funkin.avi - Freeplay: Setting Up Category...";

		// Categories, Shaders, and Songlist Setup
		switch (freeplayMenuList)
		{
			case 0: // Story Songs Menu
				{
					smilesShader = new FlxRuntimeShader(Shaders.tvStatic, null, 120);
					defaultShader2 = new FlxRuntimeShader(Shaders.monitorFilter, null, 140);
					mercyShader = new FlxRuntimeShader(Shaders.vhsFilter, null, 130);
					mercyShader2 = new FlxRuntimeShader(Shaders.cameraMovement, null, 150);
					chromAberration = new FlxRuntimeShader(Shaders.aberration, null, 150);
					chromAberration.setFloat('aberration', 0.07);
					chromAberration.setFloat('effectTime', 0.005);

					if (GameData.episode1FPLock == 'unlocked')
					{
						addSong('Devilish-Deal', 3, 'minnie', FlxColor.fromRGB(65, 88, 94), 'obscurity', 'EASY', FlxColor.WHITE);
						addSong('Isolated', 3, 'mickey-new', FlxColor.fromRGB(60, 60, 60), 'obscurity', 'EASY', FlxColor.WHITE);
						addSong('Lunacy', 3, 'lunamick-new', FlxColor.fromRGB(69, 54, 54), 'obscurity', 'NORMAL', FlxColor.fromRGB(255, 220, 220));
						addSong('Delusional', 3, 'delusional-mickey', FlxColor.fromRGB(79, 32, 32), 'FR3SHMoure', 'INSANE', FlxColor.fromRGB(255, 110, 110));
					}

					if (GameData.episodeSFPLock == 'unlocked')
					{
						addSong('Twisted-Grins', 3, 'mr-smiles', FlxColor.fromRGB(54, 38, 38), 'ForFutherNotice', 'HARD', FlxColor.fromRGB(255, 187, 187));
						addSong('Resentment', 3, 'mr-smiles', FlxColor.fromRGB(99, 66, 66), 'obscurity', 'NORMAL', FlxColor.fromRGB(255, 220, 220));
						addSong('Mortiferum-Risus', 3, 'mr-smiles', FlxColor.fromRGB(143, 91, 91), 'Sayan Sama', 'NORMAL', FlxColor.fromRGB(255, 220, 220));
					}

					if (GameData.episodeWFPLock == 'unlocked')
					{
						addSong('Mercy', 3, 'walt', FlxColor.fromRGB(176, 169, 116), 'Ophomix24', 'INSANE', FlxColor.fromRGB(255, 110, 110));
						addSong('Affliction', 3, 'walt', FlxColor.fromRGB(66, 63, 36), 'ForFurtherNotice', 'HARD', FlxColor.fromRGB(255, 187, 187));
					}
				}
			case 1: // Extras Menu
				{		
					getBlessed = new FlxRuntimeShader(Shaders.bloom, null, 120);
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

					if (GameData.episode1FPLock == 'unlocked')
					{
						addSong('Hunted', 3, (GameData.huntedLock != 'unlocked' && GameData.huntedLock != 'beaten' ? 'untouched-song' : 'goofy-new'), FlxColor.fromRGB(94, 28, 35), 'JBlitz', 'NORMAL', FlxColor.fromRGB(255, 220, 220));
						addSong('Isolated-Old', 3, (GameData.oldisolateLock != 'unlocked' && GameData.oldisolateLock != 'beaten' ? 'untouched-song' : 'mickey-legacy'), FlxColor.fromRGB(60, 60, 60), 'Toko', 'EASY', FlxColor.WHITE);
						addSong('Isolated-Beta', 3, (GameData.betaisolateLock != 'unlocked' && GameData.betaisolateLock != 'beaten' ? 'untouched-song' : 'mickey-legacy'), FlxColor.fromRGB(60, 60, 60), 'Toko', 'EASY', FlxColor.WHITE);
						addSong('Delusion', 3, 'insanemick', FlxColor.fromRGB(25, 25, 25), 'I forgor', 'NORMAL', FlxColor.fromRGB(255, 220, 220));
					}
						
					if (GameData.episodeSFPLock == 'unlocked')
					{
						addSong('Laugh-Track', 3, (GameData.rickyLock != 'unlocked' && GameData.rickyLock != 'beaten' ? 'untouched-song' : 'placeholder'), FlxColor.fromRGB(181, 0, 0), 'PualTheUnTruest', 'HARD', FlxColor.fromRGB(255, 187, 187));
						addSong('Bless', 3, (GameData.blessLock != 'unlocked' && GameData.blessLock != 'beaten' ? 'untouched-song' : 'white-noise'), FlxColor.WHITE, 'END_SELLA', 'HARD', FlxColor.fromRGB(255, 187, 187));
						addSong('Scrapped', 3, (GameData.scrappedLock != 'unlocked' && GameData.scrappedLock != 'beaten' ? 'untouched-song' : 'rs'), FlxColor.fromRGB(0, 0, 0), 'FR3SHMoure', 'HARD', FlxColor.fromRGB(255, 187, 187));
						addSong("Don't-Cross!", 3, (GameData.crossinLock != 'unlocked' && GameData.crossinLock != 'beaten' ? 'untouched-song' : 'dctl-mickey'), FlxColor.fromRGB(255, 0, 0), 'Toko', 'GOOD LUCK', FlxColor.fromRGB(201, 0, 0));
					}
						
					if (GameData.episodeWFPLock == 'unlocked')
					{
						addSong('War-Dilemma', 3, (GameData.warLock != 'unlocked' && GameData.warLock != 'beaten' ? 'untouched-song' : 'placeholder'), FlxColor.fromRGB(204, 41, 103), 'Sayan Sama & obscurity', 'HARD', FlxColor.fromRGB(255, 187, 187));
						addSong('Neglection', 3, (GameData.pnmLock != 'unlocked' && GameData.pnmLock != 'beaten' ? 'untouched-song' : 'pnm'), FlxColor.fromRGB(117, 86, 27), 'AttackPan', 'NORMAL', FlxColor.fromRGB(255, 220, 220));
						addSong('Cycled-Sins', 3, (GameData.sinsLock != 'unlocked' && GameData.sinsLock != 'beaten' ? 'untouched-song' : 'relapse-new-pixel'), FlxColor.fromRGB(105, 30, 30), 'JBlitz', 'HARD', FlxColor.fromRGB(255, 187, 187)); //messing with the saves for this later
						addSong('Whimsical-Bar-Blues', 3, 'mick-isolated-new', FlxColor.fromRGB(133, 190, 255), 'inneaux & Sayan Sama', 'NORMAL', FlxColor.fromRGB(255, 220, 220));
					}
					
					if (GameData.canAddMalfunction)
					{
						addSong('Malfunction', 3, (GameData.malfunctionLock != 'unlocked' && GameData.malfunctionLock != 'beaten' ? 'untouched-song' : 'glitched-mickey-new-pixel'), FlxColor.fromRGB(150, 149, 186), 'obscurity', null, FlxColor.WHITE); // Because Malfunction is getting some major upgrades later
					}
					
					if (GameData.birthdayLocky == 'beaten')
					{
						addSong('Birthday', 3, 'muckney', FlxColor.fromRGB(84, 255, 181), 'FR3SHMoure', 'PARTY', FlxColor.fromRGB(250, 234, 92));
					}
					
					if (GameData.highOnCrackLock == 'completed')
					{
						addSong('Delutrance', 3, 'mick-trance', FlxColor.fromRGB(0, 16, 245), 'JogadorRetro', 'DELUSIONAL', FlxColor.fromRGB(5, 139, 242)); // It's still gonna force ya to fully play it if you replay the song lmfao
					}
				}
			case 2: // Legacy Menu
				{
					if (GameData.episode1FPLock == 'unlocked')
					{
						addSong('Isolated-Legacy', 3, (GameData.legacyILock != 'unlocked' && GameData.legacyILock != 'beaten' ? 'untouched-song' : 'mickey-legacy'), FlxColor.fromRGB(60, 60, 60), 'Toko & obscurity', 'NORMAL', FlxColor.fromRGB(255, 220, 220));
						addSong('Lunacy-Legacy', 3, (GameData.legacyLLock != 'unlocked' && GameData.legacyLLock != 'beaten' ? 'untouched-song' : 'mickey-lunacy-legacy'), FlxColor.fromRGB(60, 60, 60), 'obscurity', 'NORMAL', FlxColor.fromRGB(255, 220, 220));
						addSong('Delusional-Legacy', 3, (GameData.legacyDLock != 'unlocked' && GameData.legacyDLock != 'beaten' ? 'untouched-song' : 'mickey-delusional-unused'), FlxColor.fromRGB(60, 60, 60), 'FR3SHMoure', 'HARD', FlxColor.fromRGB(255, 187, 187));
						addSong('Hunted-Legacy', 3, (GameData.legacyHLock != 'unlocked' && GameData.legacyHLock != 'beaten' ? 'untouched-song' : 'goofy'), FlxColor.fromRGB(0, 60, 40), 'JBlitz', 'EASY', FlxColor.WHITE);
					}
						
					if (GameData.episodeSFPLock == 'unlocked')
					{
						addSong('Twisted-Grins-Legacy', 3, (GameData.legacyTLock != 'unlocked' && GameData.legacyTLock != 'beaten' ? 'untouched-song' : 'mr-smiles'), FlxColor.fromRGB(115, 86, 86), 'Sayan Sama', 'HARD', FlxColor.fromRGB(255, 187, 187));
						addSong('Facade', 3, (GameData.legacyRLock != 'unlocked' && GameData.legacyRLock != 'beaten' ? 'untouched-song' : 'mr-smiles'), FlxColor.fromRGB(115, 86, 86), 'obscurity', 'NORMAL', FlxColor.fromRGB(255, 220, 220));
						addSong('Bless-Legacy', 3, (GameData.legacyBLock != 'unlocked' && GameData.legacyBLock != 'beaten' ? 'untouched-song' : 'white-noise'), FlxColor.WHITE, 'END_SELLA', 'HARD', FlxColor.fromRGB(255, 187, 187));
					}
						
					if (GameData.episodeWFPLock == 'unlocked')
					{
						addSong('Mercy-Legacy', 3, (GameData.legacyWLock != 'unlocked' && GameData.legacyWLock != 'beaten' ? 'untouched-song' : 'walt'), FlxColor.fromRGB(153, 148, 112), 'obscurity', 'HARD', FlxColor.fromRGB(255, 187, 187));
						addSong('Neglection-Legacy', 3, (GameData.legacyNLock != 'unlocked' && GameData.legacyNLock != 'beaten' ? 'untouched-song' : 'pnm'), FlxColor.CYAN, 'AttackPan', 'NORMAL', FlxColor.fromRGB(255, 220, 220));
						addSong('Cycled-Sins-Legacy', 3, (GameData.legacySLock != 'unlocked' && GameData.legacySLock != 'beaten' ? 'untouched-song' : 'relapse-pixel'), FlxColor.fromRGB(115, 86, 86), 'JBlitz', 'HARD', FlxColor.fromRGB(255, 187, 187));
					}
					
					if (GameData.canAddMalfunction)
					{
						addSong('Malfunction-Legacy', 3, (GameData.legacyMLock != 'unlocked' && GameData.legacyMLock != 'beaten' ? 'untouched-song' : 'glitched-mickey-legacy-pixel'), FlxColor.fromRGB(140, 120, 180), 'obscurity', 'INSANE', FlxColor.fromRGB(255, 110, 110));
					}
				}
		}

		mutex = new Mutex();
		loadSongs(loadCustom); // set to false in case you don't want custom songs;

		camGame = new FlxCamera();
		camHUD = new FlxCamera();

		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD, false);

		FlxG.cameras.setDefaultDrawTarget(camGame, true);

		bg = new FlxSprite();
		if (freeplayMenuList == 2)
			bg.loadGraphic(Paths.image(path + 'menuFreeplay'));
		else
			bg.loadGraphic(Paths.image(path + 'fp-bg'));
		add(bg);

		delutranceBg = new FlxSprite();
		delutranceBg.frames = Paths.getSparrowAtlas('background', "data/stages/trance");
		delutranceBg.animation.addByPrefix("lmao", "background lmao", 24, true);
		delutranceBg.scale.set(5, 5);
		delutranceBg.animation.play("lmao");

		if (freeplayMenuList != 2)
		{
			bgslider = new FlxSprite().loadGraphic(Paths.image(path + 'foreground-fp'));
			add(bgslider);

			musicPlayer = new FlxSprite().loadGraphic(Paths.image(path + 'music-player'));
			musicPlayer.blend = ADD;
			add(musicPlayer);

			musicNotes = new FlxSprite().loadGraphic(Paths.image(path + 'music-notes'));
			musicNotes.blend = ADD;
			add(musicNotes);

			arrows = new FlxSprite().loadGraphic(Paths.image(path + 'arrows'));
			add(arrows);

			disc = new FlxSprite().loadGraphic(Paths.image(path + 'disc'));
			add(disc);

			bg.scale.set(0.78, 0.78);
			bgslider.scale.set(0.78, 0.78);
			musicPlayer.scale.set(0.78, 0.78);
			musicNotes.scale.set(0.78, 0.78);
			arrows.scale.set(0.78, 0.78);
			disc.scale.set(0.78, 0.78);

			bg.screenCenter();
			bgslider.screenCenter();
			musicPlayer.screenCenter();
			musicNotes.screenCenter();
			arrows.screenCenter();
			disc.screenCenter(Y);

			disc.x += 650;

			FlxTween.angle(disc, disc.angle, 360, 1.5, {type: LOOPING});

			disc.x += 700;
			arrows.alpha = 0.0001;
			musicPlayer.x -= 700;
			musicNotes.x -= 700;
			bgslider.x -= 700;
			bg.alpha = 0.0001;

			FlxTween.tween(bg, {alpha: 1}, 1.5, {ease: FlxEase.sineInOut});
			FlxTween.tween(disc, {x: disc.x - 700}, 2, {ease: FlxEase.sineInOut, startDelay: 1});
			FlxTween.tween(arrows, {alpha: 1}, 2, {startDelay: 3});
			FlxTween.tween(musicPlayer, {x: musicPlayer.x + 700}, 2.3, {ease: FlxEase.sineInOut, startDelay: 1});
			FlxTween.tween(musicNotes, {x: musicNotes.x + 700}, 2.2, {ease: FlxEase.sineInOut, startDelay: 1});
			FlxTween.tween(bgslider, {x: bgslider.x + 700}, 2, {ease: FlxEase.sineInOut, startDelay: 1});
		}

		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		for (i in 0...songs.length)
		{
			var songText2:FlxText = new FlxText(0, 0, 470, CoolUtil.swapSpaceDash(songs[i].songName));
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, CoolUtil.swapSpaceDash(songs[i].songName), true);
			var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);

			if (freeplayMenuList == 2)
			{
				songText.isMenuItem = true;
				songText.alignment = CENTERED;

				icon.sprTracker = songText;
			}
			else 
			{
				songText.isMenuItem = true;

				songText2.setFormat(Paths.font("whiteDream"), 65, FlxColor.WHITE);
				songText2.setBorderStyle(OUTLINE, FlxColor.BLACK, 8);

				icon.x = 880;
				icon.screenCenter(Y);
				icon.setGraphicSize(Std.int(icon.width * 2.1));
				icon.x += 700;

				songText2.x = icon.x - 130;
				songText2.y = icon.y - 250;
				songText2.alignment = CENTER;
				songText2.y -= 300;
			}
			songText.targetY = i;
			grpSongs.add(songText);

			songDisplay.push(songText2);
			add(songText2);

			// using a FlxGroup is too much fuss!
			iconArray.push(icon);
			add(icon);
			// when haces tus momos en geometry dash
			// la 2.2 es hoy oiste RobTop
			// but te terminan baneando
			// ooooh mi FIRE IN THE HOLE
			FlxTween.tween(icon, {x: icon.x - 700}, 2.2, {ease: FlxEase.sineInOut, startDelay: 1});
			FlxTween.tween(songText2, {x: songText2.x - 700}, 2.2, {ease: FlxEase.sineInOut, startDelay: 1});
			FlxTween.tween(songText2, {y: songText2.y + 300}, 1.5, {ease: FlxEase.sineInOut, startDelay: 3});
		}
			
		// Basically an exact replica of the Funkin.avi V1 Freeplay Menu lol
		if (freeplayMenuList == 2)
		{
			scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
			scoreBG = new FlxSprite(scoreText.x - scoreText.width, 0).makeGraphic(Std.int(FlxG.width * 0.35), 66, 0xFF000000);
			diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
			scoreText.setFormat(Paths.font("vcr"), 32, FlxColor.WHITE, RIGHT);
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
		else //The Newer, Better, Cooler Menu
		{
			scoreText = new FlxText(FlxG.width * 0.7, 5, 450, "", 32);
			scoreBG = new FlxSprite(scoreText.x - scoreText.width, 0).makeGraphic(Std.int(FlxG.width * 0.35), 66, 0xFF000000);
			diffText = new FlxText(scoreText.x, scoreText.y + 36, 500, "", 40);
			freeplayCtrlTxt = new FlxText(30, 550, 0, "Left & Right Keybinds - Change Song Choice\n\nESC - Exit Menu\n\nENTER - Play Song", 36);
			scoreText.setFormat(Paths.font("disneyFreeplayFont"), 45, FlxColor.WHITE, CENTER);
			scoreText.setBorderStyle(OUTLINE, FlxColor.BLACK, 8);
			scoreBG.alpha = 0;
			scoreText.alpha = 0.0001;
			diffText.alpha = 0.0001;
			diffText.alignment = CENTER;
			diffText.font = scoreText.font;
			diffText.setBorderStyle(OUTLINE, FlxColor.BLACK, 8);
			freeplayCtrlTxt.setFormat(Paths.font('whiteDream'), 20, FlxColor.WHITE, LEFT);
			freeplayCtrlTxt.setBorderStyle(OUTLINE, FlxColor.BLACK, 8);
			freeplayCtrlTxt.alpha = 0.0001;
			add(scoreBG);
			add(diffText);
			add(scoreText);
			add(freeplayCtrlTxt);
			FlxTween.tween(freeplayCtrlTxt, {alpha: 1}, 1.5, {ease: FlxEase.sineInOut, startDelay: 3});
			FlxTween.tween(scoreText, {alpha: 1}, 1.5, {ease: FlxEase.sineInOut, startDelay: 3});
			FlxTween.tween(diffText, {alpha: 1}, 1.5, {ease: FlxEase.sineInOut, startDelay: 3});
		}

		if(lastDifficultyName == '')
		{
			lastDifficultyName = CoolUtil.defaultDifficulty;
		}

		changeSelection();
		changeDiff();

		// this is probably the most retartded shit ever sorry man
		// camZoomTween = FlxTween.tween(this, {}, 0);
		
		if (GameData.check(NO_MALFUNCTION))
		{
			GameData.canAddMalfunction = true;
			GameData.saveShit();
		}

		if(!ClientPrefs.lowQuality)
		{
			var scratchStuff:FlxSprite = new FlxSprite();
			scratchStuff.frames = Paths.getSparrowAtlas('filters/scratchShit');
			scratchStuff.animation.addByPrefix('idle', 'scratch thing 1', 24, true);
			scratchStuff.animation.play('idle');
			scratchStuff.screenCenter();
			scratchStuff.scale.x = 1.1;
			scratchStuff.scale.y = 1.1;
			add(scratchStuff);

			var grain:FlxSprite = new FlxSprite();
			grain.frames = Paths.getSparrowAtlas('filters/Grainshit');
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
				add(gradient);

				coolFilter = new FlxSprite().loadGraphic(Paths.image(path + 'thing'));
				coolFilter.screenCenter();
				add(coolFilter);

				gradient.cameras = [camHUD];
				coolFilter.cameras = [camHUD];
			}

			scratchStuff.cameras = [camHUD];
			grain.cameras = [camHUD];
		}
	}

	function loadSongs(includeCustom:Bool)
	{
		// load in all songs that exist in folder
		var folderSongs:Array<String> = CoolUtil.returnAssetsLibrary('songs', 'assets');
			if (includeCustom)
			{
				for (i in folderSongs)
				{
					if (!existingSongs.contains(i.toLowerCase()))
					{
						var icon:String = 'gf';
						var castSong:SwagSong = Song.loadFromJson(i, i);
						icon = (castSong != null) ? castSong.player2 : 'gf';
						addSong(CoolUtil.spaceToDash(castSong.song), 1, icon, FlxColor.WHITE, 'NOT FOUND', 'UNKNOWN', FlxColor.WHITE);
					}
				}
			}
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String, songColor:FlxColor, composer:String, rankID:String, rankColor:FlxColor)
	{
		var coolDifficultyArray = [];
		for (i in CoolUtil.difficulties)
			if (FileSystem.exists(Paths.songJson(songName, songName + '-' + i))
				|| (FileSystem.exists(Paths.songJson(songName, songName)) && i == "HARD"))
				coolDifficultyArray.push(i);

		if (coolDifficultyArray.length > 0)
		{
			songs.push({
				songName: songName,
				week: weekNum,
				songCharacter: songCharacter,
				color: songColor,
				composer: composer,
				rankName: rankID,
				rankColor: rankColor
			});
			existingDifficulties.push(coolDifficultyArray);
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.sound.music != null && FlxG.sound.music.playing && !closedState && freeplayMenuList != 2)
			Conductor.songPosition = FlxG.sound.music.time;

		if (musicNotes != null)
			{
				musicNotes.y = -110 + Math.sin(Conductor.songPosition/850)*((FlxG.height * 0.015));
			}

		if (ClientPrefs.shaders) // bye bye lag
		{
			switch (freeplayMenuList)
			{
				case 2 | 3:
					{
						//nothing
					}
				default:
					{
						shaderTime = Conductor.songPosition / 1000;

						if (freeplayMenuList == 1)
						{
							glitchyStuff.setFloat('time', shaderTime);
							glitchyStuff.setFloat('prob', shaderTime);
						}
						mercyShader.setFloat('time', shaderTime);
						mercyShader2.setFloat('time', shaderTime);

						smilesShader.setFloat('iTime', shaderTime);
						smilesShader.setFloat('uTime', shaderTime);
					}
			}
		}

		if(songs[curSelected].songName != "Don't Cross!" && freeplayMenuList == 1 && grpSongs.members[6] != null && grpSongs.members[6].exists)
			{
				grpSongs.members[6].shake(11, 10, 0.1);
				iconArray[6].shake(4, 30, 0.1);
			}

		if (bg != null && mainColor != null)
			FlxTween.color(bg, 0.35, bg.color, mainColor);

		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, CoolUtil.boundTo(elapsed * 24, 0, 1)));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;
 
		var upP = freeplayMenuList == 2 ? controls.UI_UP_P : controls.UI_LEFT_P;
		var downP = freeplayMenuList == 2 ? controls.UI_DOWN_P : controls.UI_RIGHT_P;
		var accepted = controls.ACCEPT;

		if (upP)
			changeSelection(-1);
		else if (downP)
			changeSelection(1);

		if(FlxG.mouse.wheel != 0)
			{
				changeSelection(-1 * FlxG.mouse.wheel);
				changeDiff();
				changeSongPlaying();
			}

		if (controls.BACK)
		{
			if (!FlxG.keys.pressed.SHIFT)
			{
				FlxG.sound.play(Paths.sound('cancelMenu'));
				FlxG.sound.music.stop();
			}
			threadActive = false;
			FlxG.sound.playMusic(Paths.music('freakyMenu'), 1);
			MusicBeatState.switchState(new FreeplayCategories());
		}

		if (accepted)
		{
			var song:String = Paths.formatToSongPath(songs[curSelected].songName);
			var poop:String = Highscore.formatSong(song, curDifficulty);

			PlayState.SONG = Song.loadFromJson(song + "-hard", song);
			PlayState.storyWeek = songs[curSelected].week;

			PlayState.isStoryMode = false;
			PlayState.storyDifficulty = curDifficulty;

			threadActive = false;

			closedState = true;

			if (FlxG.keys.pressed.SHIFT)
			{
				if (FlxG.sound.music != null)
					FlxG.sound.music.stop();

				PlayState.SONG.validScore = false;
				LoadingState.loadAndSwitchState(new ChartingState());
			}
			else
			{
				// ignore that im using the short "if" thing is for less code stuff due to lazyness lol
				FlxTween.tween(FlxG.camera, {zoom: freeplayMenuList == 2 ? 1 : 2.5}, freeplayMenuList == 2 ? 0.0001 : 1.5, {ease: FlxEase.expoInOut});
				new flixel.util.FlxTimer().start(freeplayMenuList == 2 ? 0.0001 : 0.7, function(e)
				{
					if (FlxG.sound.music != null)
						FlxG.sound.music.stop();

					LoadingState.loadAndSwitchState(new PlayState());
				});
			}
		}

		// Adhere the position of all the things (I'm sorry it was just so ugly before I had to fix it Shubs)
		if (freeplayMenuList == 2)
		{
			scoreText.text = "PERSONAL BEST:" + lerpScore;
			scoreText.x = FlxG.width - scoreText.width - 5;
			scoreBG.width = scoreText.width + 8;
			scoreBG.x = FlxG.width - scoreBG.width;
			diffText.x = scoreBG.x + (scoreBG.width / 2) - (diffText.width / 2);
		}
		else
		{
			scoreText.text = "Score: " + lerpScore;
			scoreText.x = 770;
			scoreText.y = 560;
			diffText.x = scoreText.x - 20;
			diffText.y = scoreText.y + 70;
		}

		mutex.acquire();
		if (songToPlay != null)
		{
			FlxG.sound.playMusic(songToPlay);

			if (FlxG.sound.music.fadeTween != null)
				FlxG.sound.music.fadeTween.cancel();

			FlxG.sound.music.volume = 0.0;
			FlxG.sound.music.fadeIn(1.0, 0.0, 1.0);

			songToPlay = null;
		}
		mutex.release();
	}

	var lastDifficulty:String;

	function changeDiff(change:Int = 0)
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = CoolUtil.difficulties.length-1;
		if (curDifficulty >= CoolUtil.difficulties.length)
			curDifficulty = 0;

		lastDifficultyName = CoolUtil.difficulties[curDifficulty];

		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);

		
		difficultyRank = songs[curSelected].rankName;
		diffText.color = songs[curSelected].rankColor;
				
		if (freeplayMenuList == 2) diffText.text = 'RANK: ' + difficultyRank; else diffText.text = "Difficulty: " + difficultyRank;// display the text
		lastDifficulty = existingDifficulties[curSelected][curDifficulty];
	}

	var closedState:Bool = false;
	override function beatHit() {
		super.beatHit();
	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('base/menus/scrollMenu'), 0.4);

		if(ClientPrefs.flashing)
			FlxG.camera.flash(FlxColor.BLACK, 0.1);
		
		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;

		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		
		var songName:String = CoolUtil.dashToSpace(songs[curSelected].songName);
		var composerName:String = songs[curSelected].composer;
		
		switch (freeplayMenuList)
		{
			case 0: 
				{
					lime.app.Application.current.window.title = "Funkin.avi - Freeplay: Episode Songs - " + songName + ' - Composed by: ' + composerName;
				}
			case 1:
				{
					lime.app.Application.current.window.title = "Funkin.avi - Freeplay: Extra Songs - " + songName + " - Composed by: " + composerName;
				}
			case 2:
				{
					lime.app.Application.current.window.title = "Funkin.avi - Freeplay: Legacy Songs - " + songName + " - Composed by: " + composerName;
				}
			case 3:
				{
					lime.app.Application.current.window.title = "Funkin.avi - Freeplay: ??? - " + songName + " - Composed by: " + composerName;
				}
		}

		// set up color stuffs
		mainColor = songs[curSelected].color;
		//PauseSubState.colorSetup = songs[curSelected].color;

		// song switching stuffs
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

					songDisplay[curSelected].alpha = 1;
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

		changeDiff();
		changeSongPlaying();
		updateDiscord();

		if (ClientPrefs.shaders) // to prevent lag
		{
			// ah yes, formatting made by vsc itself - jason
			if (freeplayMenuList != 2)
			{
				switch (songs[curSelected].songName.toLowerCase())
				{
					case 'bless':
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
									new ShaderFilter(chromAberration),
									new ShaderFilter(urFucked)
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
						// pretty sure you know why
						remove(delutranceBg);
						add(bg);

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
						// fixing a bug of delulu bg not disappearing, and no, im not gonna use alpha
						remove(delutranceBg);
						add(bg);
					
					case 'devilish-deal' | 'delusional':
						if(!ClientPrefs.lowQuality)
							FlxG.camera.setFilters([new ShaderFilter(chromAberration)]);
						FlxG.camera.shake(0.01, 0.001);

					case 'delutrance': 
						FlxG.camera.setFilters([ new ShaderFilter(pixelShader)]);
						remove(bg);
						add(delutranceBg);

					default:
						FlxG.camera.setFilters([]); // fixed it yay
						FlxG.camera.shake(0.01, 0.001);
						remove(delutranceBg);
						add(bg);
				}
			}
		}

		CoolUtil.difficulties = CoolUtil.defaultDifficulties.copy();
		var diffStr:String = WeekData.getCurrentWeek().difficulties;
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

		var newPos:Int = CoolUtil.difficulties.indexOf(lastDifficultyName);
		//trace('Pos of ' + lastDifficultyName + ' is ' + newPos);
		if(newPos > -1)
		{
			curDifficulty = newPos;
		}

		changeSongBPM();
	}

	function changeSongBPM() 
	{
		switch (songs[curSelected].songName.toLowerCase().replace('-', ' '))
		{
			case 'cycled sins' | 'cycled sins legacy' | 'facade' | 'resentment' | 'scrapped':
				Conductor.bpm = (180);

			case 'hunted' | 'hunted legacy' | 'mercy' | 'mercy legacy' | 'war dilemma' | 'malfunction legacy' | 'twisted grins legacy':
				Conductor.bpm = (160);

			case 'neglection': 
				Conductor.bpm = (155);

			case 'birthday' | 'delusional':
				Conductor.bpm = (175);

			case 'bless legacy':
				Conductor.bpm = (120);

			case 'delusional legacy':
				Conductor.bpm = (185);

			case 'affliction':
				Conductor.bpm = (150);

			case 'isolated beta' | 'isolated old':
				Conductor.bpm = (120);

			case 'isolated' | "don't cross!" | 'isolated legacy':
				Conductor.bpm = (165);

			case 'devilish deal': 
				Conductor.bpm = (90);

			case 'lunacy': 
				Conductor.bpm = (188);

			case 'delutrance':
				Conductor.bpm = (123);

			case 'malfunction': 
				Conductor.bpm = (166);

			case 'twisted grins':
				Conductor.bpm = (390);

			default:
				Conductor.bpm = (100);
		}
	}

	function changeSongPlaying()
	{
		if (songThread == null)
		{
			songThread = Thread.create(function()
			{
				while (true)
				{
					if (!threadActive)
						return;

					var index:Null<Int> = Thread.readMessage(false);
					if (index != null)
					{
						if (index == curSelected && index != curSongPlaying)
						{
							var inst:Sound = Paths.inst(songs[curSelected].songName);

							if (index == curSelected && threadActive)
							{
								mutex.acquire();
								songToPlay = inst;
								mutex.release();

								curSongPlaying = curSelected;
							}
						}
					}
				}
			});
		}
		songThread.sendMessage(curSelected);
	}

	public static function getDiffRank()
	{
		switch (CoolUtil.spaceToDash(PlayState.SONG.song.toLowerCase()))
		{
			case 'devilish-deal' | 'hunted-legacy' | 'isolated-beta' | 'isolated-old' | 'isolated': difficultyRank = 'EASY';
			case 'lunacy' | 'neglection' | 'resentment' | 'lunacy-legacy' | 'hunted' | 'mortiferum-risus' | 'isolated-legacy': difficultyRank = 'NORMAL';
			case 'delusional' | 'mercy' | 'malfunction-legacy': difficultyRank = 'INSANE';
			case 'malfunction': difficultyRank = 'null';
			case "don't-cross!": difficultyRank = 'GOOD LUCK';
			case 'birthday': difficultyRank = 'PARTY';
			case 'delutrance': difficultyRank = 'DELUSIONAL';
			default: difficultyRank = 'HARD';
		}
	}

	function updateDiscord()
	{
		var mySong:String = ' [Listening to: ${songs[curSelected].songName}]';
		#if DISCORD_RPC
		#if DevBuild
		Discord.changePresence('CHOOSING A SONG', 'Freeplay Menu [CLASSIFIED]', 'icon', 'disc-player');
		#else
		switch (freeplayMenuList)
		{
			case 0:
				{
					Discord.changePresence('CHOOSING A SONG', 'Freeplay Menu (MAIN SONGS)' + mySong, 'icon', 'disc-player');
				}
			case 1:
				{
					Discord.changePresence('CHOOSING A SONG', 'Freeplay Menu (EXTRAS)' + mySong, 'icon', 'disc-player');
				}
			case 2:
				{
					Discord.changePresence('CHOOSING A SONG', 'Freeplay Menu (LEGACY)' + mySong, 'icon', 'disc-player');
				}
			case 3:
				{
					Discord.changePresence('???', 'Freeplay Menu (???)', 'icon', 'birthday-hat');
				}
		}
		#end
		#end
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
	public var folder:String = "";

	public function new(song:String, week:Int, songCharacter:String, color:Int, composer:String, rankName:String, rankColor:FlxColor)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
		this.color = color;
		this.composer = composer;
		this.rankName = rankName;
		this.rankColor = rankColor;
		this.folder = Paths.currentModDirectory;
		if(this.folder == null) this.folder = '';
	}
}