package substates;

import flixel.addons.transition.FlxTransitionableState;
import flixel.input.keyboard.FlxKey;
import flixel.system.FlxSound;
import openfl.system.System;
import sys.io.File;
import haxe.Json;
import openfl.Lib;
import flixel.text.FlxText.FlxTextFormat;
import flixel.text.FlxText.FlxTextFormatMarkerPair;

/**
 * Pause Menu Data
 */
 typedef PauseData =
 {
	 var settings:Array<Dynamic>;
 }
class PauseSubState extends MusicBeatSubstate
{
	var grpMenuShit:FlxTypedGroup<Alphabet>;

	var menuItems:Array<String> = [];
	var menuItemsOG:Array<String> = ['Resume', 'Restart Song', 'Change Difficulty', 'Exit to menu'];
	var difficultyChoices = [];
	var curSelected:Int = 0;

	var pauseMusic:FlxSound;
	var practiceText:FlxText;
	var skipTimeText:FlxText;
	var skipTimeTracker:Alphabet;
	var curTime:Float = Math.max(0, Conductor.songPosition);
	//var botplayText:FlxText;

	public static var songName:String = '';

	public function new(x:Float, y:Float)
	{
		super();
		if(CoolUtil.difficulties.length < 2) menuItemsOG.remove('Change Difficulty'); //No need to change difficulty if there is only one!

		Lib.application.window.onClose.removeAll(); // goes back to normal hopefully
		Lib.application.window.onClose.add(function() {
			DiscordClient.shutdown();
		});

		lime.app.Application.current.window.title += " - {Paused}";
		PlayState.windowTimer.active = false;
		if(PlayState.chartingMode)
		{
			menuItemsOG.insert(2, 'Leave Charting Mode');
			
			var num:Int = 0;
			if(!PlayState.instance.startingSong)
			{
				num = 1;
				menuItemsOG.insert(3, 'Skip Time');
			}
			menuItemsOG.insert(3 + num, 'End Song');
			menuItemsOG.insert(4 + num, 'Toggle Practice Mode');
			menuItemsOG.insert(5 + num, 'Toggle Botplay');
		}
		menuItems = menuItemsOG;

		for (i in 0...CoolUtil.difficulties.length) {
			var diff:String = '' + CoolUtil.difficulties[i];
			difficultyChoices.push(diff);
		}
		difficultyChoices.push('BACK');

		var randomPauseSong:String = "";
		var randomizer:Int = FlxG.random.int(1, 3);

		switch (randomizer)
		{
			case 1: randomPauseSong = "shipTheFartYayHoorayv3v";
			case 2: randomPauseSong = "somberNight";
			case 3: randomPauseSong = "theWretchedTilezones";
		}

		pauseMusic = new FlxSound();
		pauseMusic.loadEmbedded(Paths.music("aviOST/pause/" + randomPauseSong), true, true);
		pauseMusic.volume = 0;
		pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));

		FlxG.sound.list.add(pauseMusic);

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		var levelInfo:FlxText = new FlxText(20, 15, 0, "", 32);
		levelInfo.text += PlayState.SONG.song == "Dont Cross" ? "Don't Cross!" : PlayState.SONG.song;
		levelInfo.scrollFactor.set();
		levelInfo.setFormat(Paths.font("vcr.ttf"), 32);
		levelInfo.updateHitbox();
		add(levelInfo);

		var levelDifficulty:FlxText = new FlxText(20, 15 + 32, 0, "", 32);
		levelDifficulty.text += CoolUtil.difficultyString();
		levelDifficulty.scrollFactor.set();
		levelDifficulty.setFormat(Paths.font('vcr.ttf'), 32);
		levelDifficulty.updateHitbox();
		add(levelDifficulty);

		var blueballedTxt:FlxText = new FlxText(20, 15 + 64, 0, "", 32);
		blueballedTxt.text = "Blueballed: " + PlayState.deathCounter;
		blueballedTxt.scrollFactor.set();
		blueballedTxt.setFormat(Paths.font('vcr.ttf'), 32);
		blueballedTxt.updateHitbox();
		add(blueballedTxt);

		practiceText = new FlxText(20, 15 + 101, 0, "PRACTICE MODE", 32);
		practiceText.scrollFactor.set();
		practiceText.setFormat(Paths.font('vcr.ttf'), 32);
		practiceText.x = FlxG.width - (practiceText.width + 20);
		practiceText.updateHitbox();
		practiceText.visible = PlayState.instance.practiceMode;
		add(practiceText);

		var chartingText:FlxText = new FlxText(20, 15 + 101, 0, "CHARTING MODE", 32);
		chartingText.scrollFactor.set();
		chartingText.setFormat(Paths.font('vcr.ttf'), 32);
		chartingText.x = FlxG.width - (chartingText.width + 20);
		chartingText.y = FlxG.height - (chartingText.height + 20);
		chartingText.updateHitbox();
		chartingText.visible = PlayState.chartingMode;
		add(chartingText);

		blueballedTxt.alpha = 0;
		levelDifficulty.alpha = 0;
		levelInfo.alpha = 0;

		levelInfo.x = FlxG.width - (levelInfo.width + 20);
		levelDifficulty.x = FlxG.width - (levelDifficulty.width + 20);
		blueballedTxt.x = FlxG.width - (blueballedTxt.width + 20);

		FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(levelInfo, {alpha: 1, y: 20}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3});
		FlxTween.tween(levelDifficulty, {alpha: 1, y: levelDifficulty.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.5});
		FlxTween.tween(blueballedTxt, {alpha: 1, y: blueballedTxt.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.7});

		grpMenuShit = new FlxTypedGroup<Alphabet>();
		add(grpMenuShit);

		regenMenu();
		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}

	var holdTime:Float = 0;
	var cantUnpause:Float = 0.1;
	override function update(elapsed:Float)
	{
		cantUnpause -= elapsed;
		if (pauseMusic.volume < 0.5)
			pauseMusic.volume += 0.01 * elapsed;

		super.update(elapsed);
		updateSkipTextStuff();

		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;
		var accepted = controls.ACCEPT;

		if (upP)
		{
			changeSelection(-1);
		}
		if (downP)
		{
			changeSelection(1);
		}

		var daSelected:String = menuItems[curSelected];
		switch (daSelected)
		{
			case 'Skip Time':
				if (controls.UI_LEFT_P)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
					curTime -= 1000;
					holdTime = 0;
				}
				if (controls.UI_RIGHT_P)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
					curTime += 1000;
					holdTime = 0;
				}

				if(controls.UI_LEFT || controls.UI_RIGHT)
				{
					holdTime += elapsed;
					if(holdTime > 0.5)
					{
						curTime += 45000 * elapsed * (controls.UI_LEFT ? -1 : 1);
					}

					if(curTime >= FlxG.sound.music.length) curTime -= FlxG.sound.music.length;
					else if(curTime < 0) curTime += FlxG.sound.music.length;
					updateSkipTimeText();
				}
		}

		if (accepted && (cantUnpause <= 0 || !ClientPrefs.controllerMode))
		{
			if (menuItems == difficultyChoices)
			{
				if(menuItems.length - 1 != curSelected && difficultyChoices.contains(daSelected)) {
					var name:String = PlayState.SONG.song;
					var poop = Highscore.formatSong(name, curSelected);
					PlayState.SONG = Song.loadFromJson(poop, name);
					PlayState.storyDifficulty = curSelected;
					MusicBeatState.resetState();
					FlxG.sound.music.volume = 0;
					PlayState.changedDifficulty = true;
					PlayState.chartingMode = false;
					return;
				}

				menuItems = menuItemsOG;
				regenMenu();
			}

			switch (daSelected)
			{
				case "Resume":
					lime.app.Application.current.window.title = PlayState.windowName;
					PlayState.windowTimer.active = true;
					close();
				case 'Change Difficulty':
					menuItems = difficultyChoices;
					deleteSkipTimeText();
					regenMenu();
				case 'Toggle Practice Mode':
					PlayState.instance.practiceMode = !PlayState.instance.practiceMode;
					PlayState.changedDifficulty = true;
					practiceText.visible = PlayState.instance.practiceMode;
				case "Restart Song":
					restartSong();
				case "Leave Charting Mode":
					restartSong();
					PlayState.chartingMode = false;
				case 'Skip Time':
					if(curTime < Conductor.songPosition)
					{
						PlayState.startOnTime = curTime;
						restartSong(true);
					}
					else
					{
						if (curTime != Conductor.songPosition)
						{
							PlayState.instance.clearNotesBefore(curTime);
							PlayState.instance.setSongTime(curTime);
						}
						close();
					}
				case "End Song":
					close();
					PlayState.instance.finishSong(true);
				case 'Toggle Botplay':
					PlayState.instance.cpuControlled = !PlayState.instance.cpuControlled;
					PlayState.changedDifficulty = true;
					PlayState.instance.botplayTxt.visible = PlayState.instance.cpuControlled;
					PlayState.instance.botplayTxt.alpha = 1;
					PlayState.instance.botplaySine = 0;
				case "Exit to menu":
					Lib.application.window.onClose.removeAll(); // goes back to normal hopefully
					Lib.application.window.onClose.add(function() {
						DiscordClient.shutdown();
					});
					PlayState.deathCounter = 0;
					PlayState.seenCutscene = false;

					WeekData.loadTheFirstEnabledMod();
					if(PlayState.isStoryMode) {
						MusicBeatState.switchState(new StoryMenu());
						FlxG.sound.playMusic(Paths.music('aviOST/rottenPetals'));
					} else {
						MusicBeatState.switchState(new FreeplayState());
						FlxG.sound.playMusic(Paths.music('aviOST/seekingFreedom'));
					}
					PlayState.cancelMusicFadeTween();
					PlayState.changedDifficulty = false;
					PlayState.chartingMode = false;
					FlxG.mouse.load(Paths.image('UI/funkinAVI/mouses/Hand').bitmap);
			}
		}
	}

	function deleteSkipTimeText()
	{
		if(skipTimeText != null)
		{
			skipTimeText.kill();
			remove(skipTimeText);
			skipTimeText.destroy();
		}
		skipTimeText = null;
		skipTimeTracker = null;
	}

	public static function restartSong(noTrans:Bool = false)
	{
		PlayState.instance.paused = true; // For lua
		FlxG.sound.music.volume = 0;
		PlayState.instance.vocals.volume = 0;
		PlayState.instance.opp_vocals.volume = 0;
		PlayState.instance.bf_vocals.volume = 0;

		Lib.application.window.onClose.removeAll(); // goes back to normal hopefully
		Lib.application.window.onClose.add(function() {
			DiscordClient.shutdown();
		});

		var songName:Array<String> = ['Dont Cross', "Dont-Cross", "dont cross", "dont-cross"];

		for (i in songName)
			if (PlayState.SONG.song == i)
			{
				var songLowercase:String = "dont-cross";
				var poop:String = "dont-cross-hard" + '${FlxG.random.int(1, 4)}'; //fuck fuck fuck fuck fuck fuck
				PlayState.SONG = Song.loadFromJson(poop, songLowercase, FlxG.random.int(1, 5));
			}

		if(noTrans)
		{
			FlxTransitionableState.skipNextTransOut = true;
			FlxG.resetState();
		}
		else
		{
			MusicBeatState.resetState();
		}
	}

	override function destroy()
	{
		pauseMusic.destroy();
		pauseMusic.kill();
		pauseMusic = null;

		super.destroy();
	}

	function changeSelection(change:Int = 0):Void
	{
		curSelected += change;

		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		if (curSelected < 0)
			curSelected = menuItems.length - 1;
		if (curSelected >= menuItems.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpMenuShit.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));

				if(item == skipTimeTracker)
				{
					curTime = Math.max(0, Conductor.songPosition);
					updateSkipTimeText();
				}
			}
		}
	}

	function regenMenu():Void {
		for (i in 0...grpMenuShit.members.length) {
			var obj = grpMenuShit.members[0];
			obj.kill();
			grpMenuShit.remove(obj, true);
			obj.destroy();
		}

		for (i in 0...menuItems.length) {
			var item = new Alphabet(90, 320, menuItems[i], true);
			item.isMenuItem = true;
			item.targetY = i;
			grpMenuShit.add(item);

			if(menuItems[i] == 'Skip Time')
			{
				skipTimeText = new FlxText(0, 0, 0, '', 64);
				skipTimeText.setFormat(Paths.font("vcr.ttf"), 64, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				skipTimeText.scrollFactor.set();
				skipTimeText.borderSize = 2;
				skipTimeTracker = item;
				add(skipTimeText);

				updateSkipTextStuff();
				updateSkipTimeText();
			}
		}
		curSelected = 0;
		changeSelection();
	}
	
	function updateSkipTextStuff()
	{
		if(skipTimeText == null || skipTimeTracker == null) return;

		skipTimeText.x = skipTimeTracker.x + skipTimeTracker.width + 60;
		skipTimeText.y = skipTimeTracker.y;
		skipTimeText.visible = (skipTimeTracker.alpha >= 1);
	}

	function updateSkipTimeText()
	{
		skipTimeText.text = FlxStringUtil.formatTime(Math.max(0, Math.floor(curTime / 1000)), false) + ' / ' + FlxStringUtil.formatTime(Math.max(0, Math.floor(FlxG.sound.music.length / 1000)), false);
	}
}

class FAVIPauseSubState extends MusicBeatSubstate
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
	var disc:FlxSprite;
	var songArt:FlxSprite;
	var songArtOutline:FlxSprite;
	var songName:FlxText;
	var countDown:FlxText;
	var hasResumed:Bool = false;
	var hasFinishedAnim:Bool = false;
	var pauseNameTxt:FlxText;
	var pauseSongStr:String;
	var satanTxt:FlxTypeText;
	var satanQuotes:Array<String> = [];

	var json:String = null;
	var array:Array<Dynamic>;
	var data:PauseData;

	var fuckingName:String;

	var creepyRed = new FlxTextFormatMarkerPair(new FlxTextFormat(FlxColor.RED, true, false, FlxColor.fromRGB(46, 0, 0)), '*');

	public function new(x:Float, y:Float, ?itemStack:Array<String>)
		{
			super();
	
			if (itemStack == null)
				itemStack = ['continue', 'restart', 'options', PlayState.SONG.song == "Birthday" ? 'leave' : PlayState.SONG.song == "Delusional" ? 'no-hope' : 'escape'];
	
			PlayState.windowTimer.active = false;

			Lib.application.window.onClose.removeAll(); // goes back to normal hopefully
			Lib.application.window.onClose.add(function() {
				DiscordClient.shutdown();
			});
		

			// cool stuff
			toOptions = false;
			menuItems = itemStack;

			// Will use your discord username if you're connected while playing lmao
			if (DiscordClient.isInitialized && DiscordClient.discordName != "None")
				yourName = DiscordClient.discordName;

			satanQuotes = [
				"No, it is forbidden...",
				"You can't leave now...",
				"You're not going anywhere...",
				"You've come too far to leave now...",
				"The fun has just begun...",
				"Don't be afraid of a little mouse...",
				"Stay right where you are, " + yourName + "...",
				"He's already died many times...",
				"What difference will you leaving do?",
				"Leaving so soon?",
				"Something wrong, " + yourName + "?",
				"Are you scared?",
				"You've seen too much, I won't let you go yet...",
				"Do you know who I am?",
				"You're a coward, " + yourName + "...",
				"Not so fast, friend...",
				"Not so fast, " + yourName + "...",
				"Why leave so soon? You'll be back. *And we'll be waiting...*"
			];
	
			var randomPauseSong:String = "";
			var randomizer:Int = FlxG.random.int(1, 3);

			switch (randomizer)
			{
				case 1: 
					randomPauseSong = "shipTheFartYayHoorayv3v";
					pauseSongStr = "Ship The Fart Hooray < 3 (Distant Stars)";
				case 2: 
					randomPauseSong = "somberNight";
					pauseSongStr = "Ahh The Scary (Somber Night)";
				case 3: 
					randomPauseSong = "theWretchedTilezones";
					pauseSongStr = "The Wretched Tilezones (Simple Life)";
			}

			fuckingName = (PlayState.useFakeDeluName ? "Regret" : PlayState.SONG.song);

			// stupid ass fix for story mode and getting secret songs
			switch (fuckingName)
			{
				case "Devilish Deal": if (colorSetup != FlxColor.fromRGB(65, 88, 94)) colorSetup = FlxColor.fromRGB(65, 88, 94);
				case "Isolated": if (colorSetup != FlxColor.fromRGB(60, 60, 60)) colorSetup = FlxColor.fromRGB(60, 60, 60);
				case "Lunacy": if (colorSetup != FlxColor.fromRGB(69, 54, 54)) colorSetup = FlxColor.fromRGB(69, 54, 54);
				case "Delusional": if (colorSetup != FlxColor.fromRGB(79, 32, 32)) colorSetup = FlxColor.fromRGB(79, 32, 32);
				case "Regret": if (colorSetup != FlxColor.WHITE) colorSetup = FlxColor.WHITE;
				case "Birthday": if (colorSetup != FlxColor.fromRGB(84, 255, 181)) colorSetup = FlxColor.fromRGB(84, 255, 181);
			}

			var pauseArtAsset:String = CoolUtil.spaceToDash(fuckingName.toLowerCase());

			pauseMusic = new FlxSound();
			pauseMusic.loadEmbedded(Paths.music("aviOST/pause/" + randomPauseSong), true, true);
			pauseMusic.volume = 0;
			pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));

			FlxG.sound.list.add(pauseMusic);
	
			data = jsonStuff();
	
			if (data != null)
			{
				array = data.settings;
				//trace("Current Song: " + PlayState.SONG.song + " / Info Text: " + array[0] + " / Offsets : [" + array[1] + ", " + array[2] + "]");
			}
			else
			{
				//trace("Current Song: " + PlayState.SONG.song + " / DATA FILE MISSING! - USING PLACEHOLDER VARIABLES!");
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
			songName = new FlxText(FlxG.width * 0.78 + array[1], 10, 0, (PlayState.SONG.song == "Dont Cross" ? "Don't Cross!" : (PlayState.useFakeDeluName ? "Regret" : PlayState.SONG.song)), 32);
			daSelector = new FlxSprite().loadGraphic(Paths.image("Funkin_avi/pause/buttonSelector"));
			countDown = new FlxText(0, 0, 1280, "", 0);
			satanTxt = new FlxTypeText(0, 25, 1280, "");
			pauseNameTxt = new FlxText(5, 700, 1280, "Now Playing: " + pauseSongStr + " - ForFurtherNotice");
	
			// text stuff
			// I'M NOT DELUSIONAL, YOU'RE DELUSIONAL !!!!!!
			levelInfo.setFormat(Paths.font("disneyFreeplayFont.ttf"), 18, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			songName.setFormat(Paths.font("disneyFreeplayFont.ttf"), 46, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			countDown.setFormat(Paths.font("disneyFreeplayFont.ttf"), 90, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			satanTxt.setFormat(Paths.font("disneyFreeplayFont.ttf"), 32, FlxColor.fromRGB(255, 117, 107), CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.fromRGB(92, 0, 26));
			satanTxt.borderSize = 2;
			pauseNameTxt.setFormat(Paths.font("disneyFreeplayFont.ttf"), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
	
			songArt.loadGraphic(Paths.imageAlbum(pauseArtAsset));
	
			// scales
			bg.scale.set(FlxG.width * 4, FlxG.height * 4);
			for (objects in [daSelector, disc])
				objects.scale.set(0.35, 0.35);
			songArt.scale.set(0.36, 0.36);
			songArtOutline.scale.set(0.36, 0.36); // this was easier for me to scale it off the ORIGINAL image size instead of just trying to get the exact graphic size of the song art being SCALED
	
			levelInfo.text = array[0];
	
			for (obj in [levelInfo, bg, songName, countDown])
				obj.scrollFactor.set();
	
			tiles.velocity.set(50, 30);
	
			for (obj in [countDown, bgOverlay, menuHUD, albumHolder])
				obj.screenCenter();

			satanTxt.screenCenter(X);
	
			menuHUD.x -= 850;
			albumHolder.x += 500;
	
			// alpha value setup
			for (obj in [bg, bgOverlay, tiles, levelInfo, songName, daSelector, pauseNameTxt])
				obj.alpha = 0.0001;

			countDown.visible = false;
	
			// fuck it. add everything
			for (obj in [bg, bgOverlay, tiles, menuHUD, albumHolder, songName, levelInfo, pauseNameTxt, disc, songArtOutline, songArt, daSelector])
				add(obj);
	
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
			FlxTween.tween(pauseNameTxt, {alpha: 1}, 1, {ease:FlxEase.quartOut});
	
			changeSelection();
			lime.app.Application.current.window.title += " - {Paused}";
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
			var accepted = controls.ACCEPT;
	
			if (daSelector != null) daSelector.setPosition(FlxMath.lerp(arrowX, daSelector.x, CoolUtil.boundTo(1 - (elapsed * 15), 0, 1)), FlxMath.lerp(arrowY, daSelector.y, CoolUtil.boundTo(1 - (elapsed * 15), 0, 1)));
	
			if (!hasResumed && hasFinishedAnim)
			{
				if (upP)
					changeSelection(-1);
				if (downP)
					changeSelection(1);
				if (accepted)
				{
					var daSelected:String = menuItems[curSelected];
	
					switch (daSelected)
					{
						case "continue":
							resumeGame();
						case "restart":
							remove(disc);
							restartSong();
						case "Back to Charter":
							remove(disc);
							MusicBeatState.switchState(new states.editors.ChartingState());
						case "Leave Charter Mode":
							remove(disc);
							PlayState.chartingMode = false;
							restartSong();
						case "options":
							remove(disc);
							if (PlayState.useFakeDeluName)
								PlayState.useFakeDeluName = false;
							PlayState.pauseCountEnabled = false;
							toOptions = true;
							FlxG.mouse.load(Paths.image('UI/funkinAVI/mouses/Hand').bitmap);
							FlxG.mouse.visible = true;
							MusicBeatState.switchState(new states.options.OptionsState());
							FlxG.sound.playMusic(Paths.music('aviOST/rottenPetals'));
						case 'no-hope':
							songText.shake(0.5, 1, 1);
							satanTxt.applyMarkup(satanQuotes[FlxG.random.int(0, satanQuotes.length - 1)], [creepyRed]);
							satanTxt.start(0.02, true);
						case 'leave':
							remove(disc);
							MusicBeatState.switchState(new states.ManIHateYouSoMuchYouMadeMuckneySad()); // grah
						case "escape":
							remove(disc);
							if (PlayState.useFakeDeluName)
								PlayState.useFakeDeluName = false;
							if (PlayState.pauseCountEnabled)
								PlayState.pauseCountEnabled = false;
							PlayState.seenCutscene = false;
							Lib.application.window.onClose.removeAll(); // goes back to normal hopefully
							Lib.application.window.onClose.add(function() {
								DiscordClient.shutdown();
							});
							PlayState.cancelMusicFadeTween();
							PlayState.changedDifficulty = false;
							PlayState.chartingMode = false;
							PlayState.deathCounter = 0;
	
								if (PlayState.isStoryMode)
								{
										MusicBeatState.switchState(new StoryMenu());
										FlxG.sound.playMusic(Paths.music('aviOST/rottenPetals'));
								}
								else
								{
									switch (CoolUtil.dashToSpace(PlayState.SONG.song))
									{
										case "Rotten Petals" | "Curtain Call" | "Am I Real?" | "Your Final Bow" | "Seeking Freedom" | "Ahh the Scary (Somber Night)" | "Ship the Fart Yay Hooray <3 (Distant Stars)" | "The Wretched Tilezones (Simple Life)" | "A True Monster":
											FreeplayState.freeplayMenuList = 3;
											MusicBeatState.switchState(new FreeplayState());
										case 'Devilish Deal' | 'Isolated' | 'Lunacy' | 'Delusional':
											states.menus.FreeplayState.freeplayMenuList = 0;
											MusicBeatState.switchState(new states.menus.FreeplayState());
										default:
											states.menus.FreeplayState.freeplayMenuList = (PlayState.SONG.song.toLowerCase().endsWith('legacy') || PlayState.SONG.song == "Isolated Beta" || PlayState.SONG.song == "Isolated Old") ? 2 : 1;
											MusicBeatState.switchState(new states.menus.FreeplayState()); // yeah, there's no way I'm making a case for EVERY fucking song in that menu, too much work!
									}
									FlxG.sound.playMusic(Paths.music('aviOST/seekingFreedom'));
								}
									FlxG.mouse.load(Paths.image('UI/funkinAVI/mouses/Hand').bitmap);
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
			FlxG.sound.play(Paths.sound('funkinAVI/menu/scrollSfx'), 0.6);
	
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

		public static function restartSong(noTrans:Bool = false)
			{
				if (PlayState.useFakeDeluName)
					PlayState.useFakeDeluName = false;
				if (PlayState.pauseCountEnabled)
					PlayState.pauseCountEnabled = false;
				PlayState.instance.paused = true; // For lua
				FlxG.sound.music.volume = 0;
				PlayState.instance.vocals.volume = 0;
				PlayState.instance.bf_vocals.volume = 0;
				PlayState.instance.opp_vocals.volume = 0;
				Lib.application.window.onClose.removeAll(); // goes back to normal hopefully
				Lib.application.window.onClose.add(function() {
					DiscordClient.shutdown();
				});
		
				var random:Int = FlxG.random.int(1, 11);
				var songName:Array<String> = ['Dont Cross', "Dont-Cross", "dont cross", "dont-cross"];
		
				for (i in songName)
					if (PlayState.SONG.song == i)
					{
						var songLowercase:String = "dont-cross";
						var poop:String = "dont-cross-hard" + '${random}'; //fuck fuck fuck fuck fuck fuck
						PlayState.SONG = Song.loadFromJson(poop, songLowercase, random);
					}
		
				if(noTrans)
				{
					FlxTransitionableState.skipNextTransOut = true;
					FlxG.resetState();
				}
				else
				{
					MusicBeatState.resetState();
				}
			}

		function resumeGame()
		{
			hasResumed = true;
			songName.alpha = 0;
			levelInfo.alpha = 0;
			satanTxt.text = "";
			if (PlayState.pauseCountEnabled)
			{
				FlxG.sound.play(Paths.sound('clickText'), 0.6);
				FlxTween.tween(disc, {x: disc.x + 800}, 0.8, {ease: FlxEase.quartOut});
				FlxTween.tween(daSelector, {alpha: 0}, 0.3, {ease: FlxEase.quartOut});
				FlxTween.tween(songArt, {x: songArt.x + 510}, 0.8, {ease: FlxEase.quartOut});
				FlxTween.tween(songArtOutline, {x: songArtOutline.x + 510}, 0.8, {ease: FlxEase.quartOut});
				FlxTween.tween(tiles, {alpha: 0}, 1, {ease: FlxEase.quartInOut});
				FlxTween.tween(menuHUD, {x: menuHUD.x - 850}, 0.95, {ease: FlxEase.quartOut});
				FlxTween.tween(albumHolder, {x: albumHolder.x + 500}, 0.95, {ease: FlxEase.quartOut});
				FlxTween.tween(pauseNameTxt, {alpha: 0}, 0.75, {ease: FlxEase.quartOut});
	
				new FlxTimer().start(0.4, function(tmr:FlxTimer)
				{
					FlxG.sound.play(Paths.sound('funkinAVI/menu/scrollSfx'), 0.6);
					countDown.visible = true;
					countDown.text = "3";
					new FlxTimer().start(1, function(tmr:FlxTimer)
					{
						FlxG.sound.play(Paths.sound('funkinAVI/menu/scrollSfx'), 0.6);
						countDown.text = "2";
						new FlxTimer().start(1, function(tmr:FlxTimer)
						{
							FlxG.sound.play(Paths.sound('funkinAVI/menu/scrollSfx'), 0.6);
							countDown.text = "1";
							FlxTween.tween(bg, {alpha: 0}, 1.2, {ease: FlxEase.quartInOut});
							new FlxTimer().start(1, function(tmr:FlxTimer)
							{
								FlxG.sound.play(Paths.sound('funkinAVI/menu/scrollSfx'), 0.6);
								countDown.text = "Go!";
								FlxTween.tween(bgOverlay, {alpha: 0}, 0.3, {ease: FlxEase.quartOut});
								FlxTween.tween(countDown, {alpha: 0}, 0.4);
								new FlxTimer().start(0.55, function(tmr:FlxTimer)
								{
									close();
									remove(disc);
									lime.app.Application.current.window.title = PlayState.windowName;
									PlayState.windowTimer.active = true;
								});
							});
						});
					});
				});
			}
			else
			{
				FlxG.sound.play(Paths.sound('clickText'), 0.6);
				FlxTween.tween(disc, {x: disc.x + 800}, 0.4, {ease: FlxEase.quartOut});
				FlxTween.tween(songArt, {x: songArt.x + 510}, 0.4, {ease: FlxEase.quartOut});
				FlxTween.tween(songArtOutline, {x: songArtOutline.x + 510}, 0.4, {ease: FlxEase.quartOut});
				FlxTween.tween(tiles, {alpha: 0}, 0.4, {ease: FlxEase.quartOut});
				FlxTween.tween(menuHUD, {x: menuHUD.x - 850}, 0.4, {ease: FlxEase.quartOut});
				FlxTween.tween(albumHolder, {x: albumHolder.x + 500}, 0.4, {ease: FlxEase.quartOut});
				FlxTween.tween(bg, {alpha: 0}, 0.4, {ease: FlxEase.quartOut});
				FlxTween.tween(bgOverlay, {alpha: 0}, 0.4, {ease: FlxEase.quartOut});
				FlxTween.tween(daSelector, {alpha: 0}, 0.4, {ease: FlxEase.quartOut});
				FlxTween.tween(pauseNameTxt, {alpha: 0}, 0.04, {ease: FlxEase.quartOut});
	
				new FlxTimer().start(0.5, function(tmr:FlxTimer)
				{
					close();
					remove(disc);
					lime.app.Application.current.window.title = PlayState.windowName;
					PlayState.windowTimer.active = true;
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
			switch (fuckingName)
			{
				case "Devilish Deal": json = CreditsData.devilishDeal;
				case "Isolated": json = CreditsData.isolated;
				case "Lunacy": json = CreditsData.lunacy;
				case "Delusional": json = CreditsData.delusional;
				case "Regret": json = CreditsData.regret;
				case "Hunted": json = CreditsData.hunted;
				case "Laugh Track": json = CreditsData.laughTrack;
				case "Bless": json = CreditsData.bless;
				case "Dont Cross":
					switch(Song.getCharterCredits())
					{
						case "ThatOneSillyGuy": json = CreditsData.dontCross3;
						case "Dreupy": json = CreditsData.dontCross1;
						case "Purg": json = CreditsData.dontCross2;
						case "MalyPlus": json = CreditsData.dontCross4;
						case "rezeo285": json = CreditsData.dontCross5;
					}
				case "War Dilemma": json = CreditsData.warDilemma;
				case "Twisted Grins": json = CreditsData.twistedGrins;
				case "Mercy": json = CreditsData.mercy;
				case "Cycled Sins": json = CreditsData.cycledSins;
				case "Malfunction": json = CreditsData.malfunction;
				case "Birthday": json = CreditsData.birthday;
			}
		
			if (json != null && json.length > 0)
				return cast Json.parse(json);
			else 
				return null;
		}
}

class PauseManiaSubstate extends MusicBeatSubstate
{
	var menuItems:Array<String>;
	var curSelected:Int = 0;
	var buttonGroup:FlxTypedGroup<FlxSprite>;
	var pauseMusic:FlxSound;
	var hasFinishedAnim:Bool = false;
	var canQuit:Bool = false;
	var songText:FlxSprite;

	public function new(x:Float, y:Float, ?itemStack:Array<String>)
		{
			super();
	
			if (itemStack == null)
				itemStack = ['maniaResume', 'maniaRetry', 'maniaOptions', 'maniaQuit'];
	
			PlayState.windowTimer.active = false;

			Lib.application.window.onClose.removeAll(); // goes back to normal hopefully
			Lib.application.window.onClose.add(function() {
				DiscordClient.shutdown();
			});
		

			// cool stuff
			FAVIPauseSubState.toOptions = false;
			menuItems = itemStack;

			var randomPauseSong:String = "";
			var randomizer:Int = FlxG.random.int(1, 3);

			switch (randomizer)
			{
				case 1: 
					randomPauseSong = "shipTheFartYayHoorayv3v";
				case 2: 
					randomPauseSong = "somberNight";
				case 3: 
					randomPauseSong = "theWretchedTilezones";
			}

			pauseMusic = new FlxSound();
			pauseMusic.loadEmbedded(Paths.music("aviOST/pause/" + randomPauseSong), true, true);
			pauseMusic.volume = 0;
			pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));

			FlxG.sound.list.add(pauseMusic);

			var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
			bg.alpha = 0;
			bg.scrollFactor.set();
			add(bg);

			// menu buttons
			buttonGroup = new FlxTypedGroup<FlxSprite>();
			add(buttonGroup);
	
			for (i in 0...menuItems.length)
			{
				songText = new FlxSprite(0, 0).loadGraphic(Paths.image('Funkin_avi/pause/menuButtons/${menuItems[i]}'));
				songText.alpha = 0;
				songText.scale.set(0.55, 0.55);
				songText.ID = i;
				songText.screenCenter();
				FlxTween.tween(songText, {alpha: 1}, 0.45, {ease: FlxEase.quartInOut, onComplete: function(twn:FlxTween)
				{
					hasFinishedAnim = true;
				}});
				buttonGroup.add(songText);
			}

			FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});

			changeSelection();
			lime.app.Application.current.window.title += " - {Paused}";
			cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
		}

		override function update(elapsed:Float)
		{
			updateSelection();
	
			super.update(elapsed);

			var upP = controls.UI_UP_P;
			var downP = controls.UI_DOWN_P;
			var accepted = controls.ACCEPT;
			
			if (hasFinishedAnim)
				{
					if (upP)
						changeSelection(-1);
					if (downP)
						changeSelection(1);
					if (accepted)
					{
						var daSelected:String = menuItems[curSelected];
		
						switch (daSelected)
						{
							case "maniaResume":
								close();
								lime.app.Application.current.window.title = PlayState.windowName;
								PlayState.windowTimer.active = true;
							case "maniaRetry":
								restartSong();
							case "maniaOptions":
								FAVIPauseSubState.toOptions = true;
								FlxG.mouse.load(Paths.image('UI/funkinAVI/mouses/Hand').bitmap);
								FlxG.mouse.visible = true;
								MusicBeatState.switchState(new states.options.OptionsState());
								FlxG.sound.playMusic(Paths.music('aviOST/rottenPetals'));
							case "maniaQuit":
								if (!canQuit)
								{
									songText.loadGraphic(Paths.image('Funkin_avi/pause/menuButtons/quitConfirm'));
									canQuit = true;
								}
								else
								{
									Lib.application.window.onClose.removeAll(); // goes back to normal hopefully
									Lib.application.window.onClose.add(function() {
										DiscordClient.shutdown();
									});
									PlayState.cancelMusicFadeTween();
									PlayState.changedDifficulty = false;
									PlayState.chartingMode = false;
									PlayState.deathCounter = 0;
			
									FreeplayState.freeplayMenuList = 3;
									MusicBeatState.switchState(new FreeplayState());
									FlxG.sound.playMusic(Paths.music('aviOST/seekingFreedom'));
									FlxG.mouse.load(Paths.image('UI/funkinAVI/mouses/Hand').bitmap);
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

			public static function restartSong(noTrans:Bool = false)
				{
					if (PlayState.useFakeDeluName)
						PlayState.useFakeDeluName = false;
					if (PlayState.pauseCountEnabled)
						PlayState.pauseCountEnabled = false;
					PlayState.instance.paused = true; // For lua
					FlxG.sound.music.volume = 0;
					PlayState.instance.vocals.volume = 0;
					PlayState.instance.bf_vocals.volume = 0;
					PlayState.instance.opp_vocals.volume = 0;
					Lib.application.window.onClose.removeAll(); // goes back to normal hopefully
					Lib.application.window.onClose.add(function() {
						DiscordClient.shutdown();
					});

					if(noTrans)
					{
						FlxTransitionableState.skipNextTransOut = true;
						FlxG.resetState();
					}
					else
					{
						MusicBeatState.resetState();
					}
				}

			function changeSelection(change:Int = 0):Void
			{
					FlxG.sound.play(Paths.sound('funkinAVI/menu/scrollSfx'), 0.6);
			
					if (menuItems != null)
						curSelected = FlxMath.wrap(curSelected + change, 0, menuItems.length - 1);
			}

			function updateSelection()
			{
				if (hasFinishedAnim)
				{
					buttonGroup.forEach(function(spr:FlxSprite)
					{
						spr.alpha = 0.45;
					});
				
					if (buttonGroup.members[curSelected].alpha == 0.45)
						buttonGroup.members[curSelected].alpha = 1;
				}
			}
}