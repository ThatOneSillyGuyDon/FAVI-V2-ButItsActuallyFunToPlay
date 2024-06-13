package substates;

import sys.FileSystem;
import haxe.Json;
#if (flixel <= "5.2.2")
	import flixel.system.FlxSound;
#else
	import flixel.sound.FlxSound;
#end
import sys.thread.Mutex;
import sys.thread.Thread;
import openfl.filters.BitmapFilter;
import openfl.filters.ShaderFilter;
import lime.app.Application;
import openfl.system.System;
import sys.io.File;

class PauseSubState extends MusicBeatSubstate
{
	public static var colorSetup:Null<FlxColor> = FlxColor.WHITE;
	public static var toOptions:Bool = false;
	#if desktop
	public static var getPropertyFromDesktop = Sys.getEnv(Sys.systemName() == "Windows" ? "UserProfile" : "HOME") + "\\Desktop";
	public static var yourName = Sys.environment()["USERNAME"];
    #end
	var bg:FlxSprite;
	var bgOverlay:FlxSprite;
	var menuHUD:FlxSprite;
	var daSelector:FlxSprite;
	var albumHolder:FlxSprite;
	var tiles:FlxBackdrop;
	var levelInfo:FlxText;
	var menuItems:Array<String>;
	var curSelected:Int = 0;
	var buttonGroup:FlxTypedGroup<FlxSprite>;
	var songText:FlxSprite;
	var pauseMusic:FlxSound;
	var mutex:Mutex;
	var disc:FlxSprite;
	var songArt:FlxSprite;
	var songArtOutline:FlxSprite;
	public static var songName:FlxText;
	var countDown:FlxText;
	var hasResumed:Bool = false;
	var hasFinishedAnim:Bool = false;
	var satanTxt:FlxText;
	var satanQuotes:Array<String> = [
		"You can't leave now...",
		"Not so fast, little one...",
		"You've come too far to leave now...",
		"The fun has just begun...",
		"Don't be afraid of a little mouse...",
		"He's already died many times...",
		"What difference will you leaving do?",
		"Leaving so soon?",
		"Something wrong, " + yourName + "?",
		"Are you scared?",
		"You've seen too much, I won't let you go yet...",
		"Do you know who I am?"
	];

	var json:String = null;
	var array:Array<Dynamic>;
	var data:PauseData;
	
	public function new(x:Float, y:Float, ?itemStack:Array<String>)
	{
		super();

		if (itemStack == null)
			itemStack = ['continue', 'restart', 'options', PlayState.SONG.song == "Birthday" ? 'leave' : PlayState.SONG.song == "Delusional" ? 'no-hope' : 'escape'];

		// cool stuff
		var getArt:String = 'Funkin_avi/pause/songs/';
		var pauseArtAsset:String = CoolUtil.spaceToDash(PlayState.SONG.song.toLowerCase());
		toOptions = false;
		menuItems = itemStack;

		if (PlayState.chartingMode)
		{
			if (!menuItems.contains("Back to Charter"))
				menuItems.insert(2, "Back to Charter");
			if (!menuItems.contains("Leave Charter Mode"))
				menuItems.insert(3, "Leave Charter Mode");
		}

		mutex = new Mutex();
		Thread.create(function()
		{
			mutex.acquire();
			pauseMusic = new FlxSound().loadEmbedded(Paths.music('funkinAVI/calmlyWinds'), true, true);
			pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));
			FlxG.sound.list.add(pauseMusic);
			pauseMusic.volume = 0;
			mutex.release();
		});

		data = jsonStuff();

		if (data != null)
		{
			array = data.settings;
			trace("Current Song: " + PlayState.SONG.song + " / Info Text: " + array[0] + " / Offsets : [" + array[1] + ", " + array[2] + "]");
		}
		else
		{
			trace("Current Song: " + PlayState.SONG.song + " / DATA FILE MISSING! - USING PLACEHOLDER VARIABLES!");
			array = ["PLACEHOLDER\nCREDIT\nTEXT", 0, 0];
		}

		// all variable initial setups
		bg = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
		bgOverlay = new FlxSprite().loadGraphic(Paths.image("Funkin_avi/pause/ui/coolBGOverlay"));
		tiles = new FlxBackdrop(Paths.image("Funkin_avi/pause/ui/mickeyTiles"), XY, 0, 0);
		menuHUD = new FlxSprite().loadGraphic(Paths.image("Funkin_avi/pause/ui/selectionBG"));
		albumHolder = new FlxSprite().loadGraphic(Paths.image("Funkin_avi/pause/ui/albumHolder"));
		levelInfo = new FlxText(FlxG.width * 0.75 + array[2], 100, 0, "", 32);
		songArt = new FlxSprite(780, 110);
		songArtOutline = new FlxSprite(songArt.x - 20, songArt.y - 20 /*POV: you're lazy to do the math yourself*/).makeGraphic(890, 890, FlxColor.WHITE);
		disc = new FlxSprite(songArt.x, songArt.y - 12).loadGraphic(Paths.image('Funkin_avi/pause/disc'));
		songName = new FlxText(FlxG.width * 0.78 + array[1], 10, 0, PlayState.SONG.song, 32);
		daSelector = new FlxSprite().loadGraphic(Paths.image("Funkin_avi/pause/buttonSelector"));
		countDown = new FlxText(0, 0, 0, "", 0);
		satanTxt = new FlxText(0, 650, 0, "", 0);

		// text stuff
		// I'M NOT DELUSIONAL, YOU'RE DELUSIONAL !!!!!!
		levelInfo.setFormat(Paths.font("disneyFreeplayFont"), 18, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		songName.setFormat(Paths.font("disneyFreeplayFont"), 46, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		countDown.setFormat(Paths.font("betterSatanFont"), 90, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		satanTxt.setFormat(Paths.font("betterSatanFont"), 40, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);

		// cool file check system so we don't need to compile the game everytime for this
		if (sys.FileSystem.exists('./assets/images/' + getArt + pauseArtAsset + '.png'))
			songArt.loadGraphic(Paths.image(getArt + pauseArtAsset));
		else
			songArt.loadGraphic(Paths.image(getArt + 'unknown-song'));

		// scales
		bg.scale.set(FlxG.width * 4, FlxG.height * 4);
		for (objects in [daSelector, disc])
			objects.scale.set(0.35, 0.35);
		songArt.scale.set(0.36, 0.36);
		songArtOutline.scale.set(0.36, 0.36); // this was easier for me to scale it off the ORIGINAL image size instead of just trying to get the exact graphic size of the song art being SCALED

		levelInfo.text = array[0];

		levelInfo.scrollFactor.set();
		bg.scrollFactor.set();
		songName.scrollFactor.set();
		countDown.scrollFactor.set();

		tiles.velocity.set(50, 30);

		countDown.screenCenter();
		bgOverlay.screenCenter();
		menuHUD.screenCenter();
		albumHolder.screenCenter();
		satanTxt.screenCenter(X);

		menuHUD.x -= 850;
		albumHolder.x += 500;

		// alpha value setup
		bg.alpha = 0.0001;
		bgOverlay.alpha = 0.0001;
		tiles.alpha = 0.0001;
		levelInfo.alpha = 0.0001;
		songName.alpha = 0.0001;
		daSelector.alpha = 0.0001;
		countDown.visible = false;

		// fuck it. add everything
		add(bg);
		add(bgOverlay);
		add(tiles);
		add(menuHUD);
		add(albumHolder);
		add(songName);
		add(levelInfo);
		add(disc);
		add(songArtOutline);
		add(songArt);
		add(daSelector);

		bgOverlay.color = colorSetup;
		tiles.color = colorSetup;

		bgOverlay.blend = ADD;
		tiles.blend = OVERLAY;

		// menu buttons
		buttonGroup = new FlxTypedGroup<FlxSprite>();
		add(buttonGroup);

		for (i in 0...menuItems.length)
		{
			songText = new FlxSprite(0, 0).loadGraphic(Paths.image('Funkin_avi/pause/menuButtons/${menuItems[i]}'));
			songText.alpha = 0;
			songText.ID = i;
			songText.screenCenter();
			FlxTween.tween(songText, {alpha: 1}, 0.45, {ease: FlxEase.quartInOut});
			buttonGroup.add(songText);
		}

		add(satanTxt);
		add(countDown);

		// tweens (bruh moment)
		FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartOut});
		FlxTween.tween(bgOverlay, {alpha: 1}, 0.56, {ease: FlxEase.quartOut, onComplete: function(twn:FlxTween){hasFinishedAnim = true;}});
		FlxTween.tween(daSelector, {alpha: 1}, 0.5, {ease: FlxEase.quartInOut, startDelay: 0.5});
		FlxTween.tween(tiles, {alpha: 0.2}, 1, {ease: FlxEase.quartInOut});
		FlxTween.tween(menuHUD, {x: menuHUD.x + 850}, 0.95, {ease: FlxEase.quartOut});
		FlxTween.tween(albumHolder, {x: albumHolder.x - 500}, 0.95, {ease: FlxEase.quartOut});
		FlxTween.tween(levelInfo, {alpha: 1}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3});
		FlxTween.tween(songName, {alpha: 1}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.2});
		FlxTween.tween(disc, {x: disc.x - 300}, 0.8, {ease: FlxEase.quartOut});
		FlxTween.tween(disc, {angle: 360}, 2, {type: LOOPING});
		FlxTween.tween(songArt, {x: songArt.x - 110}, 0.8, {ease: FlxEase.quartOut});
		FlxTween.tween(songArtOutline, {x: songArtOutline.x - 110}, 0.8, {ease: FlxEase.quartOut});

		changeSelection();
		PlayStateUtils.instance.loadWindowTitleData();
		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}

	var arrowX:Float = 0;
	var arrowY:Float = 0;

	override function update(elapsed:Float)
	{
		updateSelection();

		super.update(elapsed);

		updateBitch = elapsed;

		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;
		//var leftP = Controls.getPressEvent("ui_left");
		//var rightP = Controls.getPressEvent("ui_right");
		var accepted = controls.ACCEPT;

		if (daSelector != null) daSelector.setPosition(FlxMath.lerp(arrowX, daSelector.x, CoolUtil.boundTo(1 - (elapsed * 15), 0, 1)), FlxMath.lerp(arrowY, daSelector.y, CoolUtil.boundTo(1 - (elapsed * 15), 0, 1)));

		if (!hasResumed && hasFinishedAnim)
		{
			if (upP)
				changeSelection(-1);
			if (downP)
				changeSelection(1);
			/*if (leftP)
				changeSelection(-2);
			if (rightP)
				changeSelection(2);*/
			if (accepted)
			{
				var daSelected:String = menuItems[curSelected];

				switch (daSelected)
				{
					case "continue":
						resumeGame();
					case "restart":
						LoadingState.loadAndSwitchState(new PlayState());
					case "Back to Charter":
						MusicBeatState.switchState(new ChartingState());
					case "Leave Charter Mode":
						PlayState.chartingMode = false;
						LoadingState.loadAndSwitchState(new PlayState());
					case "options":
						toOptions = true;
						LoadingState.loadAndSwitchState(new OptionsState());
					case 'no-hope':
						satanTxt.text = satanQuotes[FlxG.random.int(0, satanQuotes.length - 1)];
					case 'leave':
						MusicBeatState.switchState(new ManIHateYouSoMuchYouMadeMuckneySad()); // grah
					case "escape":
							PlayState.deathCounter = 0;

							if (PlayState.isStoryMode)
								MusicBeatState.switchState(new StoryMenu());
							else
								switch (CoolUtil.dashToSpace(PlayState.SONG.song))
								{
									case 'Devilish Deal' | 'Isolated' | 'Lunacy' | 'Delusional' | 'Twisted Grins' | 'Resentment' | 'Mortiferum Risus' | 'Mercy' | 'Affliction':
										FreeplaySongs.freeplayMenuList = 0;
										MusicBeatState.switchState(new FreeplaySongs());
									case 'Delutrance': // hahaha, you FOOL, you're obligated to play till you beat it!
										if (FlxG.save.data.highOnCrackLock == 'forceBackToSong')
										{
											LoadingState.loadAndSwitchState(new PlayState());
										}
										else
										{
											FreeplaySongs.freeplayMenuList = 1;
											MusicBeatState.switchState(new FreeplaySongs());
										}
									default:
										FreeplaySongs.freeplayMenuList = PlayState.SONG.song.toLowerCase().endsWith('legacy') ? 2 : 1;
										MusicBeatState.switchState(new FreeplaySongs()); // yeah, there's no way I'm making a case for EVERY fucking song in that menu, too much work!
								}
				}
			}
		}

		if (pauseMusic != null && pauseMusic.playing)
		{
			if (pauseMusic.volume < 0.5)
				pauseMusic.volume += 0.1 * elapsed;
		}
	}

	override function destroy()
	{
		if (pauseMusic != null)
			pauseMusic.destroy();

		super.destroy();
	}

	function changeSelection(change:Int = 0):Void
	{
		FlxG.sound.play(Paths.sound('base/menus/scrollMenu'), 0.6);

		if (menuItems != null)
			curSelected = FlxMath.wrap(curSelected + change, 0, menuItems.length - 1);

		switch (curSelected)
		{
			case 0:
				arrowX = 380;
				arrowY = 60;
			case 1:
				arrowX = 320;
				arrowY = 190;
			case 2:
				arrowX = 320;
				arrowY = 310;
			case 3:
				arrowX = 290;
				arrowY = 440;
		}

		var bullShit:Int = 0;
	}

	function resumeGame()
	{
		hasResumed = true;
		songName.alpha = 0;
		levelInfo.alpha = 0;
		satanTxt.text = "";
		if (PlayState.pauseCountEnabled)
		{
			FlxG.sound.play(Paths.sound('dialogue/clickText'), 0.6);
			FlxTween.tween(disc, {x: disc.x + 800}, 0.8, {ease: FlxEase.quartOut});
			FlxTween.tween(daSelector, {alpha: 0}, 0.3, {ease: FlxEase.quartOut});
			FlxTween.tween(songArt, {x: songArt.x + 510}, 0.8, {ease: FlxEase.quartOut});
			FlxTween.tween(songArtOutline, {x: songArtOutline.x + 510}, 0.8, {ease: FlxEase.quartOut});
			FlxTween.tween(tiles, {alpha: 0}, 1, {ease: FlxEase.quartInOut});
			FlxTween.tween(menuHUD, {x: menuHUD.x - 850}, 0.95, {ease: FlxEase.quartOut});
			FlxTween.tween(albumHolder, {x: albumHolder.x + 500}, 0.95, {ease: FlxEase.quartOut});

			new FlxTimer().start(0.4, function(tmr:FlxTimer)
			{
				FlxG.sound.play(Paths.sound('base/menus/scrollMenu'), 0.6);
				countDown.visible = true;
				countDown.text = "3";
				new FlxTimer().start(1, function(tmr:FlxTimer)
				{
					FlxG.sound.play(Paths.sound('base/menus/scrollMenu'), 0.6);
					countDown.text = "2";
					new FlxTimer().start(1, function(tmr:FlxTimer)
					{
						FlxG.sound.play(Paths.sound('base/menus/scrollMenu'), 0.6);
						countDown.text = "1";
						FlxTween.tween(bg, {alpha: 0}, 1.2, {ease: FlxEase.quartInOut});
						new FlxTimer().start(1, function(tmr:FlxTimer)
						{
							FlxG.sound.play(Paths.sound('base/menus/scrollMenu'), 0.6);
							countDown.text = "Go!";
							FlxTween.tween(bgOverlay, {alpha: 0}, 0.3, {ease: FlxEase.quartOut});
							FlxTween.tween(countDown, {alpha: 0}, 0.4);
							new FlxTimer().start(0.55, function(tmr:FlxTimer)
							{
								close();
								remove(disc);
								PlayStateUtils.instance.loadWindowTitleData(); // resets the title bar to the PlayState info
							});
						});
					});
				});
			});
		}
		else
		{
			FlxG.sound.play(Paths.sound('dialogue/clickText'), 0.6);
			FlxTween.tween(disc, {x: disc.x + 800}, 0.4, {ease: FlxEase.quartOut});
			FlxTween.tween(songArt, {x: songArt.x + 510}, 0.4, {ease: FlxEase.quartOut});
			FlxTween.tween(songArtOutline, {x: songArtOutline.x + 510}, 0.4, {ease: FlxEase.quartOut});
			FlxTween.tween(tiles, {alpha: 0}, 0.4, {ease: FlxEase.quartOut});
			FlxTween.tween(menuHUD, {x: menuHUD.x - 850}, 0.4, {ease: FlxEase.quartOut});
			FlxTween.tween(albumHolder, {x: albumHolder.x + 500}, 0.4, {ease: FlxEase.quartOut});
			FlxTween.tween(bg, {alpha: 0}, 0.4, {ease: FlxEase.quartOut});
			FlxTween.tween(bgOverlay, {alpha: 0}, 0.4, {ease: FlxEase.quartOut});
			FlxTween.tween(daSelector, {alpha: 0}, 0.4, {ease: FlxEase.quartOut});

			new FlxTimer().start(0.5, function(tmr:FlxTimer)
			{
				close();
				remove(disc);
				PlayStateUtils.instance.loadWindowTitleData(); // resets the title bar to the PlayState info
			});
		}
	}	

	var updateBitch:Float = 0;
	function updateSelection()
	{
		if (hasFinishedAnim)
		{
			buttonGroup.forEach(function(spr:FlxSprite)
			{
				spr.alpha = hasResumed ? 0 : 0.45;
			});
		
			if (buttonGroup.members[curSelected].alpha == 0.45)
				buttonGroup.members[curSelected].alpha = hasResumed ? 0 : 1;
		}
	}

	function jsonStuff()
	{
		if (sys.FileSystem.exists('./assets/songs/${PlayState.SONG.song.toLowerCase()}/data.json'))
			json = File.getContent(Paths.getPath('songs/${PlayState.SONG.song.toLowerCase()}/data.json', TEXT, null));
	
		if (json != null && json.length > 0)
			return cast Json.parse(json);
		else 
			return null;
	}
}