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

	var path:String = 'Funkin_avi/freeplay/';

	private var grpSongs:FlxTypedGroup<Alphabet>;

	private var songDisplay:Array<FlxText> = [];
	private var curPlaying:Bool = false;

	private var iconArray:Array<HealthIcon> = [];

	private var bg:Null<FlxSprite>;
	private var delutranceBg:Null<FlxSprite>;

	var bgslider:FlxSprite;
	var musicPlayer:FlxSprite;
	var musicNotes:FlxSprite;
	var disc:FlxSprite;
	var arrows:FlxSprite;

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

	public static var freeplayMenuList = 0;

	public static var difficultyRank:String = 'HARD';
	public static var songArtist:String = "Unknown";

	var intendedColor:Int;
	var colorTween:FlxTween;
	var crossRandom:Int = FlxG.random.int(1, 5);

	var freeplayMusic:FlxSound;

	var songText2:FlxText;
	var songText:Alphabet;

	override function create()
	{
		//Paths.clearStoredMemory();
		//Paths.clearUnusedMemory();

		lime.app.Application.current.window.title = "Funkin.avi - Freeplay: Setting Up Category...";

		// Categories, Shaders, and Songlist Setup
		switch (freeplayMenuList)
		{
			case 0: // Story Songs Menu
				{
					defaultShader2 = new FlxRuntimeShader(Shaders.monitorFilter, null, 140);
					chromAberration = new FlxRuntimeShader(Shaders.aberration, null, 150);
					chromAberration.setFloat('aberration', 0.07);
					chromAberration.setFloat('effectTime', 0.005);

					//if (GameData.episode1FPLock == 'unlocked')
					//{
						addSong('Devilish Deal', 3, 'satandd', FlxColor.fromRGB(65, 88, 94), 'obscurity', 'EASY', FlxColor.WHITE);
						addSong('Isolated', 3, 'avier', FlxColor.fromRGB(60, 60, 60), 'obscurity', 'NORMAL', FlxColor.fromRGB(255, 220, 220));
						addSong('Lunacy', 3, 'lunaavier', FlxColor.fromRGB(69, 54, 54), 'obscurity', 'HARD', FlxColor.fromRGB(255, 187, 187));
						addSong('Delusional', 3, 'deluavier', FlxColor.fromRGB(79, 32, 32), 'FR3SHMoure', 'INSANE', FlxColor.fromRGB(255, 110, 110));
					//}
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

					//if (GameData.episode1FPLock == 'unlocked')
					//{
						//addSong('Resentment', 3, 'mr-smiles', FlxColor.fromRGB(99, 66, 66), 'obscurity', 'NORMAL', FlxColor.fromRGB(255, 220, 220));
						//addSong('Mortiferum-Risus', 3, 'mr-smiles', FlxColor.fromRGB(143, 91, 91), 'Sayan Sama', 'NORMAL', FlxColor.fromRGB(255, 220, 220));
						addSong('Hunted', 3, (GameData.huntedLock != 'unlocked' && GameData.huntedLock != 'beaten' ? 'mysteryfp' : 'goofy'), FlxColor.fromRGB(94, 28, 35), 'JBlitz', 'NORMAL', FlxColor.fromRGB(255, 220, 220));
						//addSong('Delusion', 3, 'insanemick', FlxColor.fromRGB(25, 25, 25), 'I forgor', 'NORMAL', FlxColor.fromRGB(255, 220, 220));
						addSong('Laugh Track', 3, (GameData.rickyLock != 'unlocked' && GameData.rickyLock != 'beaten' ? 'mysteryfp' : 'ricky'), FlxColor.fromRGB(181, 0, 0), 'PualTheUnTruest', 'HARD', FlxColor.fromRGB(255, 187, 187));
						addSong('Bless', 3, (GameData.blessLock != 'unlocked' && GameData.blessLock != 'beaten' ? 'mysteryfp' : 'noise'), FlxColor.WHITE, 'PualTheUnTruest', 'HARD', FlxColor.fromRGB(255, 187, 187));
						//addSong('Scrapped', 3, (GameData.scrappedLock != 'unlocked' && GameData.scrappedLock != 'beaten' ? 'mysteryfp' : 'rs'), FlxColor.fromRGB(0, 0, 0), 'FR3SHMoure', 'HARD', FlxColor.fromRGB(255, 187, 187));
						addSong("Don't Cross!", 3, (GameData.crossinLock != 'unlocked' && GameData.crossinLock != 'beaten' ? 'mysteryfp' : 'cross'), FlxColor.fromRGB(255, 0, 0), 'PualTheUnTruest', 'GOOD LUCK', FlxColor.fromRGB(201, 0, 0));
						addSong('War Dilemma', 3, (GameData.warLock != 'unlocked' && GameData.warLock != 'beaten' ? 'mysteryfp' : 'ethernalg'), FlxColor.fromRGB(204, 41, 103), 'Sayan Sama & obscurity', 'HARD', FlxColor.fromRGB(255, 187, 187));
						addSong('Twisted Grins', 3, 'smile', FlxColor.fromRGB(54, 38, 38), 'ForFutherNotice', 'HARD', FlxColor.fromRGB(255, 187, 187));
						addSong('Mercy', 3, 'walt', FlxColor.fromRGB(176, 169, 116), 'Ophomix24', 'INSANE', FlxColor.fromRGB(255, 110, 110));
						//addSong('Neglection', 3, (GameData.pnmLock != 'unlocked' && GameData.pnmLock != 'beaten' ? 'mysteryfp' : 'pnm'), FlxColor.fromRGB(117, 86, 27), 'AttackPan', 'NORMAL', FlxColor.fromRGB(255, 220, 220));
						addSong('Cycled Sins', 3, (GameData.sinsLock != 'unlocked' && GameData.sinsLock != 'beaten' ? 'mysteryfp' : 'relapse-pixel'), FlxColor.fromRGB(105, 30, 30), 'JBlitz', 'HARD', FlxColor.fromRGB(255, 187, 187)); //messing with the saves for this later
						//addSong('Whimsical-Bar-Blues', 3, 'mick-isolated-new', FlxColor.fromRGB(133, 190, 255), 'inneaux & Sayan Sama', 'NORMAL', FlxColor.fromRGB(255, 220, 220));
					//}
					
					//if (GameData.canAddMalfunction)
					//{
						addSong('Malfunction', 3, (GameData.malfunctionLock != 'unlocked' && GameData.malfunctionLock != 'beaten' ? 'mysteryfp' : 'mal-pixel'), FlxColor.fromRGB(150, 149, 186), 'obscurity', null, FlxColor.WHITE); // Because Malfunction is getting some major upgrades later
					//}
					
					//if (GameData.muckneyLock == 'beaten')
					//{
						addSong('Birthday', 3, 'muckney', FlxColor.fromRGB(84, 255, 181), 'FR3SHMoure', 'PARTY', FlxColor.fromRGB(250, 234, 92));
					//}
					
					//if (GameData.highOnCrackLock == 'completed')
					//{
						addSong('Delutrance', 3, 'delucrack', FlxColor.fromRGB(0, 16, 245), 'JogadorRetro', 'DELUSIONAL', FlxColor.fromRGB(5, 139, 242)); // It's still gonna force ya to fully play it if you replay the song lmfao
					//}
				}
			case 2: // Legacy Menu
				{
					//if (GameData.episode1FPLock == 'unlocked')
					//{
						addSong('Isolated Old', 3, (GameData.oldisolateLock != 'unlocked' && GameData.oldisolateLock != 'beaten' ? 'mysteryfp' : 'avierlegacy'), FlxColor.fromRGB(60, 60, 60), 'Toko', 'EASY', FlxColor.WHITE);
						addSong('Isolated Beta', 3, (GameData.betaisolateLock != 'unlocked' && GameData.betaisolateLock != 'beaten' ? 'mysteryfp' : 'avierlegacy'), FlxColor.fromRGB(60, 60, 60), 'Toko', 'EASY', FlxColor.WHITE);
						addSong('Isolated Legacy', 3, (GameData.legacyILock != 'unlocked' && GameData.legacyILock != 'beaten' ? 'mysteryfp' : 'avierlegacy'), FlxColor.fromRGB(60, 60, 60), 'Toko & obscurity', 'NORMAL', FlxColor.fromRGB(255, 220, 220));
						addSong('Lunacy Legacy', 3, (GameData.legacyLLock != 'unlocked' && GameData.legacyLLock != 'beaten' ? 'mysteryfp' : 'lunaold'), FlxColor.fromRGB(60, 60, 60), 'obscurity', 'NORMAL', FlxColor.fromRGB(255, 220, 220));
						addSong('Delusional Legacy', 3, (GameData.legacyDLock != 'unlocked' && GameData.legacyDLock != 'beaten' ? 'mysteryfp' : 'deluold'), FlxColor.fromRGB(60, 60, 60), 'FR3SHMoure', 'HARD', FlxColor.fromRGB(255, 187, 187));
						addSong('Hunted Legacy', 3, (GameData.legacyHLock != 'unlocked' && GameData.legacyHLock != 'beaten' ? 'mysteryfp' : 'goofyold'), FlxColor.fromRGB(0, 60, 40), 'JBlitz', 'EASY', FlxColor.WHITE);
						addSong('Twisted Grins Legacy', 3, (GameData.legacyTLock != 'unlocked' && GameData.legacyTLock != 'beaten' ? 'mysteryfp' : 'smile'), FlxColor.fromRGB(115, 86, 86), 'Sayan Sama', 'HARD', FlxColor.fromRGB(255, 187, 187));
						//addSong('Facade', 3, (GameData.legacyRLock != 'unlocked' && GameData.legacyRLock != 'beaten' ? 'mysteryfp' : 'mr-smiles'), FlxColor.fromRGB(115, 86, 86), 'obscurity', 'NORMAL', FlxColor.fromRGB(255, 220, 220));
						//addSong('Bless-Legacy', 3, (GameData.legacyBLock != 'unlocked' && GameData.legacyBLock != 'beaten' ? 'mysteryfp' : 'white-noise'), FlxColor.WHITE, 'END_SELLA', 'HARD', FlxColor.fromRGB(255, 187, 187));
						addSong('Mercy Legacy', 3, (GameData.legacyWLock != 'unlocked' && GameData.legacyWLock != 'beaten' ? 'mysteryfp' : 'walt'), FlxColor.fromRGB(153, 148, 112), 'obscurity', 'HARD', FlxColor.fromRGB(255, 187, 187));
						//addSong('Neglection-Legacy', 3, (GameData.legacyNLock != 'unlocked' && GameData.legacyNLock != 'beaten' ? 'mysteryfp' : 'pnm'), FlxColor.CYAN, 'AttackPan', 'NORMAL', FlxColor.fromRGB(255, 220, 220));
						addSong('Cycled Sins Legacy', 3, (GameData.legacySLock != 'unlocked' && GameData.legacySLock != 'beaten' ? 'mysteryfp' : 'relapse-pixel'), FlxColor.fromRGB(115, 86, 86), 'JBlitz', 'HARD', FlxColor.fromRGB(255, 187, 187));
					//}
					
					//if (GameData.canAddMalfunction)
					//{
						addSong('Malfunction Legacy', 3, (GameData.legacyMLock != 'unlocked' && GameData.legacyMLock != 'beaten' ? 'mysteryfp' : 'mallegacy-pixel'), FlxColor.fromRGB(140, 120, 180), 'obscurity', 'INSANE', FlxColor.fromRGB(255, 110, 110));
					//}
				}
		}

		persistentUpdate = true;
		PlayState.isStoryMode = false;
		WeekData.reloadWeekFiles(false);

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		/*for (i in 0...WeekData.weeksList.length) {
			if(weekIsLocked(WeekData.weeksList[i])) continue;

			var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[i]);
			var leSongs:Array<String> = [];
			var leChars:Array<String> = [];

			for (j in 0...leWeek.songs.length)
			{
				leSongs.push(leWeek.songs[j][0]);
				leChars.push(leWeek.songs[j][1]);
			}

			WeekData.setDirectoryFromWeek(leWeek);
			for (song in leWeek.songs)
			{
				var colors:Array<Int> = song[2];
				if(colors == null || colors.length < 3)
				{
					colors = [146, 113, 253];
				}
				addSong(song[0], i, song[1], FlxColor.fromRGB(colors[0], colors[1], colors[2]), song[3], song[4], song[5]);
			}
		}
		WeekData.loadTheFirstEnabledMod();

		/*		//KIND OF BROKEN NOW AND ALSO PRETTY USELESS//

		var initSonglist = CoolUtil.coolTextFile(Paths.txt('freeplaySonglist'));
		for (i in 0...initSonglist.length)
		{
			if(initSonglist[i] != null && initSonglist[i].length > 0) {
				var songArray:Array<String> = initSonglist[i].split(":");
				addSong(songArray[0], 0, songArray[1], Std.parseInt(songArray[2]));
			}
		}*/

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
		delutranceBg.frames = Paths.getSparrowAtlas('favi/stages/trance/background');
		delutranceBg.animation.addByPrefix("lmao", "background lmao", 24, true);
		delutranceBg.scale.set(5, 5);
		delutranceBg.animation.play("lmao");
		delutranceBg.antialiasing = ClientPrefs.globalAntialiasing;

		if (freeplayMenuList != 2)
		{
			bgslider = new FlxSprite().loadGraphic(Paths.image(path + 'foreground-fp'));
			bgslider.antialiasing = ClientPrefs.globalAntialiasing;
			add(bgslider);

			musicPlayer = new FlxSprite().loadGraphic(Paths.image(path + 'music-player'));
			musicPlayer.blend = ADD;
			musicPlayer.antialiasing = ClientPrefs.globalAntialiasing;
			add(musicPlayer);

			musicNotes = new FlxSprite().loadGraphic(Paths.image(path + 'music-notes'));
			musicNotes.blend = ADD;
			musicNotes.antialiasing = ClientPrefs.globalAntialiasing;
			add(musicNotes);

			arrows = new FlxSprite().loadGraphic(Paths.image(path + 'arrows'));
			arrows.antialiasing = ClientPrefs.globalAntialiasing;
			add(arrows);

			disc = new FlxSprite().loadGraphic(Paths.image(path + 'disc'));
			disc.antialiasing = ClientPrefs.globalAntialiasing;
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

			FlxTween.tween(bg, {alpha: 1}, 1, {ease: FlxEase.expoOut});
			FlxTween.tween(disc, {x: disc.x - 700}, 1, {ease: FlxEase.expoOut});
			FlxTween.tween(arrows, {alpha: 1}, 1);
			FlxTween.tween(musicPlayer, {x: musicPlayer.x + 700}, 1, {ease: FlxEase.expoOut});
			FlxTween.tween(musicNotes, {x: musicNotes.x + 700}, 1, {ease: FlxEase.expoOut});
			FlxTween.tween(bgslider, {x: bgslider.x + 700}, 1, {ease: FlxEase.expoOut});
		}

		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		for (i in 0...songs.length)
		{
			songText2 = new FlxText(0, 0, 470, songs[i].songName);
			songText = new Alphabet(100, (50 * i) + 30, songs[i].songName, true);
			
			var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);

			if (freeplayMenuList == 2)
			{
				songText.isMenuItem = true;

				// I FORGOT THAT SCREENCENTER X EXITS LMFAO - malyplus
				songText.screenCenter(X); 			
				songText.changeX = false;
				
				//songText.alignment = CENTER; // fuck you haxeflixel your making me suffer ugh
				
				icon.sprTracker = songText;
			}
			else 
			{
				songText.isMenuItem = true;

				songText2.setFormat(Paths.font("whiteDream.otf"), 65, FlxColor.WHITE);
				songText2.setBorderStyle(OUTLINE, FlxColor.BLACK, 8);

				icon.x = 880;
				icon.screenCenter(Y);
				icon.setGraphicSize(Std.int(icon.width * 2.1));
				icon.antialiasing = ClientPrefs.globalAntialiasing;
				icon.x += 700;

				songText2.x = icon.x - 130;
				songText2.y = icon.y - 250;
				songText2.alignment = CENTER;
				songText2.antialiasing = ClientPrefs.globalAntialiasing;
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
			FlxTween.tween(icon, {x: icon.x - 700}, 1, {ease: FlxEase.expoOut});
			FlxTween.tween(songText2, {x: songText2.x - 700}, 1, {ease: FlxEase.expoOut});
			FlxTween.tween(songText2, {y: songText2.y + 300}, 1, {ease: FlxEase.expoOut});
		}
			
		// Basically an exact replica of the Funkin.avi V1 Freeplay Menu lol
		if (freeplayMenuList == 2)
		{
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
		else //The Newer, Better, Cooler Menu
		{
			scoreText = new FlxText(FlxG.width * 0.7, 5, 450, "", 32);
			scoreBG = new FlxSprite(scoreText.x - scoreText.width, 0).makeGraphic(Std.int(FlxG.width * 0.35), 66, 0xFF000000);
			diffText = new FlxText(scoreText.x, scoreText.y + 36, 500, "", 40);
			freeplayCtrlTxt = new FlxText(30, 550, 0, "Left & Right Keybinds - Change Song Choice\n\nESC - Exit Menu\n\nENTER - Play Song", 36);
			scoreText.setFormat(Paths.font("disneyFreeplayFont.ttf"), 45, FlxColor.WHITE, CENTER);
			scoreText.setBorderStyle(OUTLINE, FlxColor.BLACK, 8);
			scoreBG.alpha = 0;
			scoreText.alpha = 0.0001;
			diffText.alpha = 0.0001;
			diffText.alignment = CENTER;
			diffText.font = scoreText.font;
			diffText.setBorderStyle(OUTLINE, FlxColor.BLACK, 8);
			freeplayCtrlTxt.setFormat(Paths.font('whiteDream.otf'), 20, FlxColor.WHITE, LEFT);
			freeplayCtrlTxt.setBorderStyle(OUTLINE, FlxColor.BLACK, 8);
			freeplayCtrlTxt.alpha = 0.0001;
			freeplayCtrlTxt.antialiasing = ClientPrefs.globalAntialiasing;
			diffText.antialiasing = ClientPrefs.globalAntialiasing;
			scoreText.antialiasing = ClientPrefs.globalAntialiasing;
			add(scoreBG);
			add(diffText);
			add(scoreText);
			add(freeplayCtrlTxt);
			freeplayCtrlTxt.cameras = [camHUD];
			FlxTween.tween(freeplayCtrlTxt, {alpha: 1}, 1.5, {ease: FlxEase.sineInOut, startDelay: 1});
			FlxTween.tween(scoreText, {alpha: 1}, 1.5, {ease: FlxEase.sineInOut, startDelay: 1});
			FlxTween.tween(diffText, {alpha: 1}, 1.5, {ease: FlxEase.sineInOut, startDelay: 1});
		}

		if(curSelected >= songs.length) curSelected = 0;
		bg.color = songs[curSelected].color;
		intendedColor = bg.color;
		FAVIPauseSubState.colorSetup = intendedColor;

		if(lastDifficultyName == '')
		{
			lastDifficultyName = CoolUtil.defaultDifficulty;
		}
		curDifficulty = Math.round(Math.max(0, CoolUtil.defaultDifficulties.indexOf(lastDifficultyName)));
		
		changeSelection();
		changeDiff();

		var swag:Alphabet = new Alphabet(1, 0, "swag");

		// JUST DOIN THIS SHIT FOR TESTING!!!
		/* 
			var md:String = Markdown.markdownToHtml(Assets.getText('CHANGELOG.md'));

			var texFel:TextField = new TextField();
			texFel.width = FlxG.width;
			texFel.height = FlxG.height;
			// texFel.
			texFel.htmlText = md;

			FlxG.stage.addChild(texFel);

			// scoreText.textField.htmlText = md;

			trace(md);
		 */

		var textBG:FlxSprite = new FlxSprite(0, FlxG.height - 26).makeGraphic(FlxG.width, 26, 0xFF000000);
		textBG.alpha = 0.6;
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
	
					coolFilter = new FlxSprite().loadGraphic(Paths.image(path + 'thing'));
					coolFilter.screenCenter();
					coolFilter.antialiasing = ClientPrefs.globalAntialiasing;
					add(coolFilter);
	
					gradient.cameras = [camHUD];
					coolFilter.cameras = [camHUD];
				}
	
				scratchStuff.cameras = [camHUD];
				grain.cameras = [camHUD];
			}
		super.create();

		FlxG.sound.music.pause();
		freeplayMusic = new FlxSound();
		freeplayMusic.loadEmbedded(Paths.music('funkinAVI/seekingFreedom'), true);
		FlxG.sound.list.add(freeplayMusic);
		freeplayMusic.play(false, 15 * 1000);
		freeplayMusic.volume = 0;
		freeplayMusic.fadeIn(2, 0, .7);
	}

	override function closeSubState() {
		changeSelection(0, false);
		persistentUpdate = true;
		super.closeSubState();
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String, color:Int, composer:String, rankName:String, rankColor:FlxColor)
	{
		songs.push(new SongMetadata(songName, weekNum, songCharacter, color, composer, rankName, rankColor));
	}

	function weekIsLocked(name:String):Bool {
		var leWeek:WeekData = WeekData.weeksLoaded.get(name);
		return (!leWeek.startUnlocked && leWeek.weekBefore.length > 0 && (!StoryMenuState.weekCompleted.exists(leWeek.weekBefore) || !StoryMenuState.weekCompleted.get(leWeek.weekBefore)));
	}

	/*public function addWeek(songs:Array<String>, weekNum:Int, weekColor:Int, ?songCharacters:Array<String>)
	{
		if (songCharacters == null)
			songCharacters = ['bf'];

		var num:Int = 0;
		for (song in songs)
		{
			addSong(song, weekNum, songCharacters[num]);
			this.songs[this.songs.length-1].color = weekColor;

			if (songCharacters.length != 1)
				num++;
		}
	}*/

	var instPlaying:Int = -1;
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

		Conductor.songPosition = freeplayMusic != null ? freeplayMusic.time : 0;

		var isDontCross:Bool = songs[curSelected].songName == "Don't Cross!";

		if (musicNotes != null)
			{
				musicNotes.y = -110 + Math.sin(Conductor.songPosition/850)*((FlxG.height * 0.015));
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

		if(songs[curSelected].songName != "Don't Cross!" && grpSongs.members[6] != null && grpSongs.members[6].exists)
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

			if(controls.UI_DOWN || controls.UI_UP)
			{
				var checkLastHold:Int = Math.floor((holdTime - 0.5) * 10);
				holdTime += elapsed;
				var checkNewHold:Int = Math.floor((holdTime - 0.5) * 10);

				if(holdTime > 0.5 && checkNewHold - checkLastHold > 0)
				{
					changeSelection((checkNewHold - checkLastHold) * (controls.UI_UP ? -shiftMult : shiftMult));
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

		/*if (controls.UI_LEFT_P)
			changeDiff(-1);
		else if (controls.UI_RIGHT_P)
			changeDiff(1);
		else if (upP || downP) changeDiff();*/

		if (controls.BACK)
		{
			persistentUpdate = false;
			if(colorTween != null) {
				colorTween.cancel();
			}
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new FreeplayCategories());
		}

		if(ctrl)
		{
			persistentUpdate = false;
			openSubState(new GameplayChangersSubstate());
		}
		else if(space)
		{
			if(instPlaying != curSelected)
			{
				#if PRELOAD_ALL

				destroyFreeplayVocals();
				FlxG.sound.music.volume = 0;
				Paths.currentModDirectory = songs[curSelected].folder;
				var songLowercase:String = Paths.formatToSongPath(songs[curSelected].songName);
				if (isDontCross) // I've been suffering trying to get the randomizer to work with hardcoded charts only to find out this piece of shit was causing the crash oh my FUCKING GOD I'M GONNA RIP MY FUCKING HEAD OFF!!!!! (don)
					songLowercase = "dont-cross";
				var poop:String = Highscore.formatSong(songLowercase, curDifficulty);
				PlayState.SONG = Song.loadFromJson(poop, songLowercase);
				if (PlayState.SONG.needsVoices)
				{
					vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
					bf_vocals = new FlxSound().loadEmbedded(Paths.voicesPlayer(PlayState.SONG.song, if (PlayState.SONG.voiceSfx1 == null) "Player" else PlayState.SONG.voiceSfx1, CoolUtil.difficulties[curDifficulty]));
					opp_vocals = new FlxSound().loadEmbedded(Paths.voicesOpp(PlayState.SONG.song, if (PlayState.SONG.voiceSfx2 == null) "Opponent" else PlayState.SONG.voiceSfx2, CoolUtil.difficulties[curDifficulty]));
				}
				else
				{
					vocals = new FlxSound();
					bf_vocals = new FlxSound();
					opp_vocals = new FlxSound();
				}

				FlxG.sound.list.add(vocals);
				FlxG.sound.list.add(bf_vocals);
				FlxG.sound.list.add(opp_vocals);
				FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song, CoolUtil.difficulties[curDifficulty]), 0.7);
				vocals.play();
				bf_vocals.play();
				opp_vocals.play();
				vocals.persist = true;
				bf_vocals.persist = true;
				opp_vocals.persist = true;
				vocals.looped = true;
				bf_vocals.looped = true;
				opp_vocals.looped = true;
				vocals.volume = 0.7;
				bf_vocals.volume = 0.7;
				opp_vocals.volume = 0.7;
				instPlaying = curSelected;
				#end
			}
		}

		else if (accepted)
		{
			persistentUpdate = false;
			var songLowercase:String = Paths.formatToSongPath(songs[curSelected].songName);
			if (isDontCross) // I've been suffering trying to get the randomizer to work with hardcoded charts only to find out this piece of shit was causing the crash oh my FUCKING GOD I'M GONNA RIP MY FUCKING HEAD OFF!!!!! (don)
				songLowercase = "dont-cross";
			var poop:String = Highscore.formatSong(songLowercase, curDifficulty); //fuck fuck fuck fuck fuck fuck
			/*#if MODS_ALLOWED
			if(!sys.FileSystem.exists(Paths.modsJson(songLowercase + '/' + poop)) && !sys.FileSystem.exists(Paths.json(songLowercase + '/' + poop))) {
			#else
			if(!OpenFlAssets.exists(Paths.json(songLowercase + '/' + poop))) {
			#end
				poop = songLowercase;
				curDifficulty = 1;
				trace('Couldnt find file');
			}*/
			trace(poop);

			PlayState.SONG = Song.loadFromJson(poop, songLowercase, crossRandom);
			PlayState.isStoryMode = false;
			PlayState.storyDifficulty = curDifficulty;

			trace('CURRENT WEEK: ' + WeekData.getWeekFileName());
			if(colorTween != null) {
				colorTween.cancel();
			}
			
			FlxTween.tween(bg, {alpha: 0}, 1, {ease: FlxEase.sineInOut});
			FlxTween.tween(disc, {x: disc.x + 700}, 1, {ease: FlxEase.sineInOut});
			FlxTween.tween(arrows, {alpha: 0}, 1);
			FlxTween.tween(musicPlayer, {x: musicPlayer.x - 700}, 1, {ease: FlxEase.sineInOut});
			FlxTween.tween(musicNotes, {x: musicNotes.x - 700}, 1, {ease: FlxEase.sineInOut});
			FlxTween.tween(bgslider, {x: bgslider.x - 700}, 1, {ease: FlxEase.sineInOut});
			for (i in 0...songs.length) FlxTween.tween(iconArray[i], {x: iconArray[i].x + 700}, 1, {ease: FlxEase.sineInOut});
			FlxTween.tween(songText2, {x: songText2.x + 700}, 1, {ease: FlxEase.sineInOut});
			FlxTween.tween(songText2, {y: songText2.y - 300}, 1, {ease: FlxEase.sineInOut});
			FlxTween.tween(freeplayCtrlTxt, {alpha: 0}, 1.5, {ease: FlxEase.sineInOut});
			FlxTween.tween(scoreText, {alpha: 0}, 1.5, {ease: FlxEase.sineInOut});
			FlxTween.tween(diffText, {alpha: 0}, 1.5, {ease: FlxEase.sineInOut});
			FlxTween.tween(songText2, {alpha: 0}, 1.5, {ease: FlxEase.sineInOut});
			freeplayMusic.fadeOut();

			new flixel.util.FlxTimer().start(freeplayMenuList == 2 ? 0.0001 : 1.5, function(e)
			{
				LoadingState.loadAndSwitchState(new PlayState());
			});

			FlxG.sound.music.volume = 0;
					
			destroyFreeplayVocals();
		}
		else if(controls.RESET)
		{
			persistentUpdate = false;
			openSubState(new ResetScoreSubState(songs[curSelected].songName, curDifficulty, songs[curSelected].songCharacter));
			FlxG.sound.play(Paths.sound('funkinAVI/menu/scrollSfx'));
		}
		super.update(elapsed);
	}

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

	function changeSelection(change:Int = 0, playSound:Bool = true)
	{
		if(playSound) FlxG.sound.play(Paths.sound('funkinAVI/menu/scrollSfx'), 0.4);

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
					lime.app.Application.current.window.title = "Funkin.avi - Freeplay: Episode Songs - " + songName + ' - Composed by: ' + songArtist;
				}
			case 1:
				{
					lime.app.Application.current.window.title = "Funkin.avi - Freeplay: Extra Songs - " + songName + " - Composed by: " + songArtist;
				}
			case 2:
				{
					lime.app.Application.current.window.title = "Funkin.avi - Freeplay: Legacy Songs - " + songName + " - Composed by: " + songArtist;
				}
			case 3:
				{
					lime.app.Application.current.window.title = "Funkin.avi - Freeplay: ??? - " + songName + " - Composed by: " + songArtist;
				}
		}
			
		var newColor:Int = songs[curSelected].color;
		if(newColor != intendedColor) {
			if(colorTween != null) {
				colorTween.cancel();
			}
			intendedColor = newColor;
			FAVIPauseSubState.colorSetup = intendedColor;
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
			scoreText.x = 770;
			scoreText.y = 560;
			diffText.x = scoreText.x - 20;
			diffText.y = scoreText.y + 70;
		}
	}

	override function destroy() {
		freeplayMusic.destroy();
		freeplayMusic.kill();
		freeplayMusic = null;
		FlxG.sound.music.play();
		super.destroy();
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
				case 'delutrance': difficultyRank = 'DELUSIONAL';
				default: difficultyRank = 'HARD';
			}
			return difficultyRank;
		}

		public static function getArtistName():String
		{
			switch (PlayState.SONG.song)
			{
				case "Devilish Deal" | "Isolated" | "Lunacy" | "Malfunction" | "Lunacy Legacy" | "Malfunction Legacy" | "Mercy Legacy": songArtist = "obscurity.";
				case "Delusional" | "Birthday" | "Delusional Legacy": songArtist = "FR3SHMoure";
				case "Hunted" | "Hunted Legacy" | "Cycled Sins" | "Cycled Sins Legacy": songArtist = "JBlitz";
				case "Laugh Track" | "Dont Cross" | "Bless": songArtist = "PualTheUnTruest";
				case "Isolated Beta" | "Isolated Old": songArtist = "Toko";
				case "Isolated Legacy": songArtist = "Toko & obscurity.";
				case "War Dilemma": songArtist = "Sayan Sama & obscurity.";
				case "Twisted Grins": songArtist = "ForFurtherNotice";
				case "Mercy": songArtist = "Ophomix24";
				case "Delutrance": songArtist = "RetroJogador";
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