package substates;

import backend.data.WeekData;

import gameObjects.Character;
import flixel.FlxObject;
import flixel.FlxSubState;
import openfl.Lib;

enum abstract Image(String) from String to String {
	var EPISODE_1 = "favi/ui/gameOvers/episode1/episode1Death";
	var DELUSIONAL = "favi/ui/gameOvers/episode1/delusional/delusionalDeath";
	var DONT_CROSS = "favi/ui/gameOvers/DontCrossGameOver";
	var BIRTHDAY = "favi/ui/gameOvers/birthday/birthdayGameOver";
	var WAR_DILEMMA = "favi/ui/gameOvers/warDilemma/warGameOver";
	var MALFUNCTION = "favi/ui/gameOvers/malfunction/malDeathBG";
	var EVERETT_DEFAULT = "favi/ui/gameOvers/everett/everettDeath";
}

class BaseGameOver extends MusicBeatSubstate {
	public var boyfriend:Character;
	var camFollow:FlxObject;
	var moveCamera:Bool = false;
	var playingDeathSound:Bool = false;

	var stageSuffix:String = "";

	public static var characterName:String = 'bf-dead';
	public static var deathSoundName:String = 'fnf_loss_sfx';
	public static var loopSoundName:String = 'gameOver';
	public static var endSoundName:String = 'gameOverEnd';

	public static var instance:BaseGameOver;

	public static function resetVariables() {
		characterName = 'bf-dead';
		deathSoundName = 'fnf_loss_sfx';
		loopSoundName = 'gameOver';
		endSoundName = 'gameOverEnd';
	}

	var charX:Float = 0;
	var charY:Float = 0;
	override function create()
	{
		instance = this;

		Conductor.songPosition = 0;

		boyfriend = new Character(PlayState.instance.boyfriend.getScreenPosition().x, PlayState.instance.boyfriend.getScreenPosition().y, characterName, true);
		boyfriend.x += boyfriend.positionArray[0] - PlayState.instance.boyfriend.positionArray[0];
		boyfriend.y += boyfriend.positionArray[1] - PlayState.instance.boyfriend.positionArray[1];
		add(boyfriend);

		FlxG.sound.play(Paths.sound(deathSoundName));
		FlxG.camera.scroll.set();
		FlxG.camera.target = null;

		boyfriend.playAnim('firstDeath');

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollow.setPosition(boyfriend.getGraphicMidpoint().x + boyfriend.cameraPosition[0], boyfriend.getGraphicMidpoint().y + boyfriend.cameraPosition[1]);
		FlxG.camera.focusOn(new FlxPoint(FlxG.camera.scroll.x + (FlxG.camera.width / 2), FlxG.camera.scroll.y + (FlxG.camera.height / 2)));
		add(camFollow);
		
		PlayState.instance.setOnScripts('inGameOver', true);
		PlayState.instance.callOnScripts('onGameOverStart', []);

		super.create();
	}

	public var startedDeath:Bool = false;
	override function update(elapsed:Float)
	{
		super.update(elapsed);

		PlayState.instance.callOnScripts('onUpdate', [elapsed]);

		if (controls.ACCEPT)
		{
			endBullshit();
		}

		if (controls.BACK)
		{
			#if DISCORD_ALLOWED DiscordClient.resetClientID(); #end
			PlayState.deathCounter = 0;
			PlayState.seenCutscene = false;
			PlayState.chartingMode = false;
			Lib.application.window.onClose.removeAll(); // goes back to normal hopefully
			Lib.application.window.onClose.add(function() {
			DiscordClient.shutdown();
			});

			if (PlayState.isStoryMode)
			{
				MusicBeatState.switchState(new StoryMenuState());
				FlxG.sound.playMusic(Paths.music('aviOST/gameOver/rottenPetals'));
			}
			else
			{
				MusicBeatState.switchState(new FreeplayState());
				FlxG.sound.playMusic(Paths.music('aviOST/seekingFreedom'));
			}
			PlayState.instance.callOnScripts('onGameOverConfirm', [false]);
		}
		
		if (boyfriend.animation.curAnim != null)
		{
			if (boyfriend.animation.curAnim.name == 'firstDeath' && boyfriend.animation.curAnim.finished && startedDeath)
				boyfriend.playAnim('deathLoop');

			if(boyfriend.animation.curAnim.name == 'firstDeath')
			{
				if(boyfriend.animation.curAnim.curFrame >= 12 && !moveCamera)
				{
					FlxG.camera.follow(camFollow, LOCKON, 0.6);
					moveCamera = true;
				}

				if (boyfriend.animation.curAnim.finished && !playingDeathSound)
				{
					startedDeath = true;
					if (PlayState.SONG.stage == 'tank')
					{
						playingDeathSound = true;
						coolStartDeath(0.2);
						
						var exclude:Array<Int> = [];
						//if(!ClientPrefs.cursing) exclude = [1, 3, 8, 13, 17, 21];

						FlxG.sound.play(Paths.sound('jeffGameover/jeffGameover-' + FlxG.random.int(1, 25, exclude)), 1, false, null, true, function() {
							if(!isEnding)
							{
								FlxG.sound.music.fadeIn(0.2, 1, 4);
							}
						});
					}
					else coolStartDeath();
				}
			}
		}
		
		if (FlxG.sound.music.playing)
		{
			Conductor.songPosition = FlxG.sound.music.time;
		}
		PlayState.instance.callOnScripts('onUpdatePost', [elapsed]);
	}

	var isEnding:Bool = false;

	function coolStartDeath(?volume:Float = 1):Void
	{
		FlxG.sound.playMusic(Paths.music(loopSoundName), volume);
	}

	function endBullshit():Void
	{
		if (!isEnding)
		{
			isEnding = true;
			boyfriend.playAnim('deathConfirm', true);
			FlxG.sound.music.stop();
			FlxG.sound.play(Paths.music(endSoundName));
			new FlxTimer().start(0.7, function(tmr:FlxTimer)
			{
				FlxG.camera.fade(FlxColor.BLACK, 2, false, function()
				{
					MusicBeatState.resetState();
				});
			});
			PlayState.instance.callOnScripts('onGameOverConfirm', [true]);
		}
	}

	override function destroy()
	{
		instance = null;
		super.destroy();
	}
}

class ManiaLoseScreen extends MusicBeatSubstate {
	public static var instance:ManiaLoseScreen;
	var retryBtn:FlxSprite;
	var quitBtn:FlxSprite;
	var canUseCtrls:Bool = false;

	var stupidLerps:Array<Float> = [1, .35];
	var maniaMusic:FlxSound = new FlxSound().loadEmbedded(Paths.music('aviOST/gameOver/mistfulWind'), true, false);

	override function create()
	{
		instance = this;

		var red = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.RED);
		red.blend = ADD;
		red.alpha = 0.85;
		add(red);
		FlxTween.tween(red, {alpha: 0}, 1);

		var black = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		black.alpha = 0.001;
		add(black);
		FlxTween.tween(black, {alpha: 1}, 3, {startDelay: 2.5});

		var results = new FlxSprite().loadGraphic(Paths.image("favi/ui/gameOvers/mania/deathResults"));
		results.alpha = 0.001;
		add(results);

		var resultsTxt = new FlxText(65, 70, 850, "Level Failed\nSicks: " + PlayState.instance.sicks + "                  Goods: " + PlayState.instance.goods + "\nBads: " + PlayState.instance.bads + "                  Shits: " + PlayState.instance.shits + "\nMisses: " + PlayState.instance.songMisses + "                  Hits: " + PlayState.instance.songHits + "\n\nScore: " + PlayState.instance.songScore + "\n\nAccuracy: " + CoolUtil.floorDecimal(PlayState.instance.ratingPercent * 100, 2) + "%", 0);
		resultsTxt.setFormat(Paths.font("resultsFont.ttf"), 40, FlxColor.WHITE, CENTER);
		resultsTxt.alpha = 0.001;
		add(resultsTxt);

		var songLength:Float = PlayState.instance.inst.length;
		var curTime:Float = Conductor.songPosition - ClientPrefs.data.noteOffset;
		if(curTime < 0) curTime = 0;

		var songName = new FlxText(890, 60, 450, PlayState.SONG.song + "\n\n\n\n\n\n\n\n\n\n\n" + FlxStringUtil.formatTime(Math.floor(curTime / 1000), false) + "/" + FlxStringUtil.formatTime(Math.floor(songLength / 1000)), 0);
		songName.setFormat(Paths.font("resultsFont.ttf"), 22, FlxColor.WHITE, CENTER);
		songName.alpha = 0.001;
		add(songName);

		var album = new FlxSprite(0, -190).loadGraphic(Paths.imageAlbum(PlayState.SONG.song == "Alone" ? "volume1Album" : "volume2Album"));
		album.scale.set(0.3, 0.3);
		album.screenCenter(X);
		album.x += 475;
		album.alpha = 0.001;
		add(album);

		for (i in [results, resultsTxt, songName, album])
			FlxTween.tween(i, {alpha: 1}, 3, {startDelay: 2.7});

		retryBtn = new FlxSprite().loadGraphic(Paths.image("favi/ui/gameOvers/mania/deathRetry"));
		retryBtn.alpha = 0.001;
		add(retryBtn);

		quitBtn = new FlxSprite().loadGraphic(Paths.image("favi/ui/gameOvers/mania/deathQuit"));
		quitBtn.alpha = 0.001;
		add(quitBtn);

		FlxG.sound.list.add(maniaMusic);
		new FlxTimer().start(5, function(tmr:FlxTimer){
			FlxG.sound.music.stop();
			FlxG.sound.music.volume = 0;
			PlayState.instance.inst.stop();
			maniaMusic.play();
			maniaMusic.fadeIn(3, 0, 1);
			canUseCtrls = true;
		});

		cameras = [PlayState.instance.camOther];

		super.create();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.sound.music.playing)
		{
			Conductor.songPosition = FlxG.sound.music.time;
		}

		if (canUseCtrls)
		{
			retryBtn.alpha = FlxMath.lerp(stupidLerps[0], retryBtn.alpha, CoolUtil.boundTo(1 - (elapsed * 15), 0, 1));
			quitBtn.alpha = FlxMath.lerp(stupidLerps[1], quitBtn.alpha, CoolUtil.boundTo(1 - (elapsed * 15), 0, 1));
			if (controls.UI_LEFT_P || controls.UI_RIGHT_P)
			{
				FlxG.sound.play(Paths.sound("funkinAVI/menu/scrollSfx"));
				stupidLerps[0] = stupidLerps[0] == 1 ? 0.35 : 1;
				stupidLerps[1] = stupidLerps[1] == 1 ? 0.35 : 1;
			}

			if (controls.ACCEPT)
			{
				FlxG.sound.play(Paths.sound("funkinAVI/menu/selectSfx"));
				maniaMusic.fadeOut(2, 0);
				if (stupidLerps[0] == 1)
				{
					PlayState.instance.camOther.fade(FlxColor.BLACK, 2, false, function()
					{
						MusicBeatState.resetState();
					});
				}
				else
				{
					PlayState.instance.camOther.fade(FlxColor.BLACK, 2, false, function()
					{
						MusicBeatState.switchState(new FreeplayState());
						FlxG.sound.playMusic(Paths.music('aviOST/seekingFreedom'));
					});
				}
			}
		}
	}
}

class Episode1Death extends MusicBeatSubstate {
	public static var instance:Episode1Death;

	var stupidAssCam:FlxCamera;

	var uiArrowUp:FlxSprite;
	var uiArrowDown:FlxSprite;
	var uiRetry:FlxSprite;
	var uiLeave:FlxSprite;

	var quitLerp:Float = 0.5;
	var tryLerp:Float = 1;
	var arrowLerp:Float = 0.0001;

	var isEnding:Bool = false;

	var scratch:FlxSprite;

	override function create()
	{
		instance = this;

		stupidAssCam = new FlxCamera();
		FlxG.cameras.add(stupidAssCam);

		Conductor.songPosition = 0;

		var deathImage:FlxSprite = new FlxSprite().loadGraphic(Paths.image(Image.EPISODE_1));
		deathImage.screenCenter();
		deathImage.scrollFactor.set(0, 0);
		deathImage.cameras = [stupidAssCam];
		deathImage.alpha = 0.001;
		deathImage.setGraphicSize(0, FlxG.height);
		add(deathImage);

		quitLerp = 0.0001;
		tryLerp = 0.0001;

		uiArrowDown = new FlxSprite().loadGraphic(Paths.image("favi/ui/gameOvers/arrowEverett"));
		uiArrowUp = new FlxSprite().loadGraphicFromSprite(uiArrowDown);
		uiRetry = new FlxSprite().loadGraphic(Paths.image("favi/ui/gameOvers/episode1/episode1Retry"));
		uiLeave = new FlxSprite().loadGraphic(Paths.image("favi/ui/gameOvers/episode1/episode1Leave"));

		for (epiUI in [uiRetry, uiLeave])
		{
			epiUI.cameras = [stupidAssCam];
			epiUI.screenCenter();
			epiUI.scrollFactor.set(0, 0);
			epiUI.scale.set(0.3, 0.3);
			epiUI.alpha = 0.001;
			epiUI.x -= 295;
			epiUI.y -= 164;
			epiUI.angle = -65;
			add(epiUI);
		}

		for (evilrettArrows in [uiArrowDown, uiArrowUp])
		{
			evilrettArrows.cameras = [stupidAssCam];
			evilrettArrows.screenCenter();
			evilrettArrows.scrollFactor.set(0, 0);
			evilrettArrows.scale.set(0.37, 0.37);
			evilrettArrows.alpha = 0.001;
			evilrettArrows.x -= 524;
			evilrettArrows.y -= 172;
			add(evilrettArrows);
		}

		uiArrowDown.angle = 180;
		uiArrowUp.angle = -6;
		uiArrowDown.x += 50;
		uiArrowUp.x += 400;
		uiArrowDown.y += 62;
		uiArrowUp.y -= 40;

		new flixel.util.FlxTimer().start(0.5, function(tmr)
		{
			FlxTween.tween(deathImage, {alpha: 1}, 3);
		});

		stupidAssCam.scroll.set();

		new FlxTimer().start(2.5, function(tmr:FlxTimer)
		{
			FlxG.sound.playMusic(Paths.music("aviOST/gameOver/yourFinalBow"), 1);
			FlxG.sound.music.fadeIn(2, 0, 1);
			arrowLerp = 1;
			tryLerp = 1;
		});

		super.create();

		if (!ClientPrefs.data.lowQuality)
		{
			scratch = new FlxSprite();
			scratch.frames = Paths.getSparrowAtlas('favi/filters/scratchShit');
			scratch.animation.addByPrefix('e', 'scratch thing', 24, true);
			scratch.animation.play('e');
			scratch.cameras = [stupidAssCam];
			scratch.scrollFactor.set(0, 0);
			add(scratch);
		}
	}

	override function update(elapsed:Float)
	{
		uiRetry.alpha = FlxMath.lerp(tryLerp, uiRetry.alpha, CoolUtil.boundTo(1 - (elapsed * 8), 0, 1));
		uiLeave.alpha = FlxMath.lerp(quitLerp, uiLeave.alpha, CoolUtil.boundTo(1 - (elapsed * 8), 0, 1));
		uiArrowDown.alpha = FlxMath.lerp(arrowLerp, uiArrowDown.alpha, CoolUtil.boundTo(1 - (elapsed * 9), 0, 1));
		uiArrowUp.alpha = FlxMath.lerp(arrowLerp, uiArrowUp.alpha, CoolUtil.boundTo(1 - (elapsed * 9), 0, 1));

		if (FlxG.sound.music.playing)
		{
			Conductor.songPosition = FlxG.sound.music.time;
		}

		if ((controls.UI_LEFT_P || controls.UI_RIGHT_P) && arrowLerp == 1)
		{
			quitLerp = quitLerp == 1 ? 0.001 : 1;
			tryLerp = tryLerp == 1 ? 0.001 : 1;
			FlxG.sound.play(Paths.sound('funkinAVI/menu/scrollSfx'));
			if (controls.UI_LEFT_P)
				uiArrowDown.alpha = 0.3;
			if (controls.UI_RIGHT_P)
				uiArrowUp.alpha = 0.3;
		}

		if (controls.ACCEPT && arrowLerp == 1 && !isEnding)
		{
			FlxG.sound.music.stop();
			FlxG.sound.play(Paths.music('aviOST/gameOver/bellToll'));
			PlayState.pauseCountEnabled = false;
			if (tryLerp == 1)
			{	
				FlxTween.tween(stupidAssCam, {zoom: stupidAssCam.zoom + 0.5}, 4, {ease: FlxEase.expoInOut});
				new FlxTimer().start(0.7, function(tmr:FlxTimer)
				{
					stupidAssCam.fade(FlxColor.BLACK, 2, false, function()
					{
						if (PlayState.deathCounter == 3)
							MusicBeatState.switchState(new BotplayScreen());
						else
							MusicBeatState.resetState();
					});
				});
			}

			if (quitLerp == 1)
			{
				PlayState.deathCounter = 0;
				PlayState.seenCutscene = false;
				PlayState.chartingMode = false;
				Lib.application.window.onClose.removeAll(); // goes back to normal hopefully
				Lib.application.window.onClose.add(function() {
				DiscordClient.shutdown();
				});

				if (PlayState.isStoryMode)
				{
					stupidAssCam.fade(FlxColor.BLACK, 1.4, false, function()
					{
						MusicBeatState.switchState(new StoryMenuState());
						FlxG.sound.playMusic(Paths.music('aviOST/gameOver/rottenPetals'));
					});
				}
				else
				{
					stupidAssCam.fade(FlxColor.BLACK, 1.4, false, function()
					{
						MusicBeatState.switchState(new FreeplayState());
						FlxG.sound.playMusic(Paths.music('aviOST/seekingFreedom'));
					});
				}
				FlxG.mouse.load(Paths.image('favi/ui/Cursor').bitmap);
			}
			arrowLerp = quitLerp = tryLerp = 0;
			isEnding = true;
		}
	}
}

class DelusionalDeath extends MusicBeatSubstate {
	public static var instance:DelusionalDeath;

	var stupidAssCam:FlxCamera;

	var uiArrowUp:FlxSprite;
	var uiArrowDown:FlxSprite;
	var uiRetry:FlxSprite;
	var uiLeave:FlxSprite;

	var quitLerp:Float = 0.5;
	var tryLerp:Float = 1;
	var arrowLerp:Float = 0.0001;

	var isEnding:Bool = false;

	var scratch:FlxSprite;

	override function create()
	{
		instance = this;

		stupidAssCam = new FlxCamera();
		FlxG.cameras.add(stupidAssCam);

		Conductor.songPosition = 0;

		if (PlayState.useFakeDeluName)
			PlayState.useFakeDeluName = false;

		var deathImage:FlxSprite = new FlxSprite().loadGraphic(Paths.image(Image.DELUSIONAL));
		deathImage.screenCenter();
		deathImage.scrollFactor.set(0, 0);
		deathImage.cameras = [stupidAssCam];
		deathImage.alpha = 0.001;
		deathImage.setGraphicSize(0, FlxG.height);
		add(deathImage);

		quitLerp = 0.0001;
		tryLerp = 0.0001;

		uiRetry = new FlxSprite().loadGraphic(Paths.image("favi/ui/gameOvers/episode1/delusional/retryDelu"));
		uiLeave = new FlxSprite().loadGraphic(Paths.image("favi/ui/gameOvers/episode1/delusional/deluLeave"));

		for (deluUI in [uiRetry, uiLeave])
		{
			deluUI.screenCenter();
			deluUI.x += 440;
			deluUI.scrollFactor.set(0, 0);
			deluUI.setGraphicSize(0, FlxG.height);
			deluUI.cameras = [stupidAssCam];
			deluUI.alpha = 0.0001;
			add(deluUI);
		}

		uiArrowDown = new FlxSprite().loadGraphic(Paths.image("favi/ui/gameOvers/arrowEverett"));
		uiArrowUp = new FlxSprite().loadGraphicFromSprite(uiArrowDown);

		for (everettUI in [uiArrowDown, uiArrowUp])
		{
			everettUI.cameras = [stupidAssCam];
			everettUI.screenCenter();
			everettUI.scrollFactor.set(0, 0);
			everettUI.scale.set(0.37, 0.37);
			everettUI.alpha = 0.001;
			everettUI.x += 200;
			add(everettUI);
		}

		uiArrowDown.angle = 194;
		uiArrowUp.angle = 8;
		uiArrowDown.x += 50;
		uiArrowUp.x += 400;

		stupidAssCam.scroll.set();

		new flixel.util.FlxTimer().start(0.5, function(tmr)
		{
			FlxTween.tween(deathImage, {alpha: 1}, 3);
		});

		new FlxTimer().start(2.5, function(tmr:FlxTimer)
		{
			FlxG.sound.playMusic(Paths.music("aviOST/gameOver/yourFinalBow"), 1);
			FlxG.sound.music.fadeIn(2, 0, 1);
			arrowLerp = 1;
			tryLerp = 1;
		});

		super.create();

		if (!ClientPrefs.data.lowQuality)
		{
			scratch = new FlxSprite();
			scratch.frames = Paths.getSparrowAtlas('favi/filters/scratchShit');
			scratch.animation.addByPrefix('e', 'scratch thing', 24, true);
			scratch.animation.play('e');
			scratch.cameras = [stupidAssCam];
			scratch.scrollFactor.set(0, 0);
			add(scratch);
		}
	}

	override function update(elapsed:Float)
	{
		uiRetry.alpha = FlxMath.lerp(tryLerp, uiRetry.alpha, CoolUtil.boundTo(1 - (elapsed * 8), 0, 1));
		uiLeave.alpha = FlxMath.lerp(quitLerp, uiLeave.alpha, CoolUtil.boundTo(1 - (elapsed * 8), 0, 1));
		uiArrowDown.alpha = FlxMath.lerp(arrowLerp, uiArrowDown.alpha, CoolUtil.boundTo(1 - (elapsed * 9), 0, 1));
		uiArrowUp.alpha = FlxMath.lerp(arrowLerp, uiArrowUp.alpha, CoolUtil.boundTo(1 - (elapsed * 9), 0, 1));

		if (FlxG.sound.music.playing)
		{
			Conductor.songPosition = FlxG.sound.music.time;
		}

		if ((controls.UI_LEFT_P || controls.UI_RIGHT_P) && arrowLerp == 1)
		{
			quitLerp = quitLerp == 1 ? 0.001 : 1;
			tryLerp = tryLerp == 1 ? 0.001 : 1;
			FlxG.sound.play(Paths.sound('funkinAVI/menu/scrollSfx'));
			if (controls.UI_LEFT_P)
				uiArrowDown.alpha = 0.3;
			if (controls.UI_RIGHT_P)
				uiArrowUp.alpha = 0.3;
		}

		if (controls.ACCEPT && arrowLerp == 1 && !isEnding)
		{
			FlxG.sound.music.stop();
			FlxG.sound.play(Paths.music('aviOST/gameOver/bellToll'));
			PlayState.pauseCountEnabled = false;
			if (tryLerp == 1)
			{	
				FlxTween.tween(stupidAssCam, {zoom: stupidAssCam.zoom + 0.5}, 4, {ease: FlxEase.expoInOut});
				new FlxTimer().start(0.7, function(tmr:FlxTimer)
				{
					stupidAssCam.fade(FlxColor.BLACK, 2, false, function()
					{
						if (PlayState.deathCounter == 3)
							MusicBeatState.switchState(new BotplayScreen());
						else
							MusicBeatState.resetState();
					});
				});
			}

			if (quitLerp == 1)
			{
				PlayState.deathCounter = 0;
				PlayState.seenCutscene = false;
				PlayState.chartingMode = false;
				Lib.application.window.onClose.removeAll(); // goes back to normal hopefully
				Lib.application.window.onClose.add(function() {
				DiscordClient.shutdown();
				});

				if (PlayState.isStoryMode)
				{
					stupidAssCam.fade(FlxColor.BLACK, 1.4, false, function()
					{
						MusicBeatState.switchState(new StoryMenuState());
						FlxG.sound.playMusic(Paths.music('aviOST/gameOver/rottenPetals'));
					});
				}
				else
				{
					stupidAssCam.fade(FlxColor.BLACK, 1.4, false, function()
					{
						MusicBeatState.switchState(new FreeplayState());
						FlxG.sound.playMusic(Paths.music('aviOST/seekingFreedom'));
					});
				}
				FlxG.mouse.load(Paths.image('favi/ui/Cursor').bitmap);
			}
			arrowLerp = quitLerp = tryLerp = 0;
			isEnding = true;
		}
	}
}

class EpicFailLmao extends MusicBeatSubstate {
	public static var instance:EpicFailLmao;

	var stupidAssCam:FlxCamera;
	var deathHUD:FlxCamera;

	var tryTxt:Array<String> = [
		"Try Again",
		"Get Up",
		"Don't Stop",
		"Revive",
		"Restart",
		"Retry",
		"Finish It",
		"Continue",
		"Play Again",
		"Rise"
	];

	var quitTxt:Array<String> = [
		"Give Up",
		"Quit",
		"Stop Trying",
		"Leave",
		"Run Away",
		"You Coward",
		"Give In",
		"Surrender",
		"Plead Mercy",
		"Rot Away"
	];

	var game:FlxText;
	var over:FlxText;
	var tryAgain:FlxText;
	var quit:FlxText;

	var quitCol:FlxTween;
	var tryCol:FlxTween;

	var quitLerp:Float = 0.5;
	var tryLerp:Float = 1;
	var camLerpBullshit:Float = 0.0001;

	var isEnding:Bool = false;

	override function create()
	{
		instance = this;

		stupidAssCam = new FlxCamera();
		deathHUD = new FlxCamera();
		deathHUD.bgColor.alpha = 0;

		FlxG.cameras.add(stupidAssCam);
		FlxG.cameras.add(deathHUD, false);
		deathHUD.alpha = 0.0001;

		Conductor.songPosition = 0;

		var deathImage:FlxSprite = new FlxSprite().loadGraphic(Paths.image(Image.DONT_CROSS));
		deathImage.screenCenter();
		deathImage.scrollFactor.set(0, 0);
		deathImage.cameras = [stupidAssCam];
		deathImage.setGraphicSize(0, FlxG.height);
		add(deathImage);

		game = new FlxText(180, 50, 0, "G  A  M  E");
		over = new FlxText(850, 50, 0, "O  V  E  R");
		tryAgain = new FlxText(160, 560, 320, tryTxt[FlxG.random.int(0, tryTxt.length - 1)]);
		quit = new FlxText(780, 560, 320, quitTxt[FlxG.random.int(0, quitTxt.length - 1)]);

		game.angle = -13;
		over.angle = 13;

		for (txt in [game, over, tryAgain, quit])
		{
			txt.setFormat(Paths.font("DisneyFont.ttf"), 70, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			txt.cameras = [deathHUD];
			txt.borderSize = 6;
			add(txt);
		}

		tryAgain.color = FlxColor.YELLOW;
		FlxG.sound.play(Paths.sound("wompWomp"));

		stupidAssCam.scroll.set();

		new FlxTimer().start(3.5, function(tmr:FlxTimer)
		{
			camLerpBullshit = 1;
			FlxG.sound.playMusic(Paths.music("aviOST/gameOver/amIReal"), 1);
			FlxG.sound.music.fadeIn(2, 0, 1);
		});

		super.create();
	}

	override function update(elapsed:Float)
	{
		tryAgain.alpha = FlxMath.lerp(tryLerp, tryAgain.alpha, CoolUtil.boundTo(1 - (elapsed * 15), 0, 1));
		quit.alpha = FlxMath.lerp(quitLerp, quit.alpha, CoolUtil.boundTo(1 - (elapsed * 15), 0, 1));
		deathHUD.alpha = FlxMath.lerp(camLerpBullshit, deathHUD.alpha, CoolUtil.boundTo(1 - (elapsed * 11), 0, 1));


		if (FlxG.sound.music.playing)
		{
			Conductor.songPosition = FlxG.sound.music.time;
		}

		if (deathHUD.alpha >= 0.5 && !isEnding)
		{
			if (controls.UI_LEFT_P && tryLerp != 1)
			{
				if (quitCol != null) quitCol.cancel();
				if (tryCol != null) tryCol.cancel();
				quitLerp = 0.5;
				tryLerp = 1;
				quitCol = FlxTween.color(quit, 0.15, quit.color, FlxColor.WHITE, {ease: FlxEase.sineOut,
					onComplete: function(twn:FlxTween) {
						quitCol = null;
					}
				});
				tryCol = FlxTween.color(tryAgain, 0.15, tryAgain.color, FlxColor.YELLOW, {ease: FlxEase.sineOut,
					onComplete: function(twn:FlxTween) {
						tryCol = null;
					}
				});
				FlxG.sound.play(Paths.sound('funkinAVI/menu/scrollSfx'));
			}

			if (controls.UI_RIGHT_P && quitLerp != 1)
			{
				if (quitCol != null) quitCol.cancel();
				if (tryCol != null) tryCol.cancel();
				quitLerp = 1;
				tryLerp = 0.5;
				quitCol = FlxTween.color(quit, 0.15, quit.color, FlxColor.RED, {ease: FlxEase.sineOut,
					onComplete: function(twn:FlxTween) {
						quitCol = null;
					}
				});
				tryCol = FlxTween.color(tryAgain, 0.15, tryAgain.color, FlxColor.WHITE, {ease: FlxEase.sineOut,
					onComplete: function(twn:FlxTween) {
						tryCol = null;
					}
				});
				FlxG.sound.play(Paths.sound('funkinAVI/menu/scrollSfx'));
			}

			if (controls.ACCEPT)
			{
				FlxG.sound.music.stop();
				FlxG.sound.play(Paths.music('gameOverEnd'));
				PlayState.pauseCountEnabled = false;

				if (quitLerp == 1)
				{
					PlayState.deathCounter = 0;
					PlayState.seenCutscene = false;
					PlayState.chartingMode = false;
					Lib.application.window.onClose.removeAll(); // goes back to normal hopefully
					Lib.application.window.onClose.add(function() {
						DiscordClient.shutdown();
					});

					new FlxTimer().start(0.7, function(tmr:FlxTimer)
					{
						stupidAssCam.fade(FlxColor.BLACK, 2, false, function()
						{
							if (PlayState.isStoryMode)
							{
								MusicBeatState.switchState(new StoryMenuState());
								FlxG.sound.playMusic(Paths.music('aviOST/rottenPetals'));
							}
							else
							{
								MusicBeatState.switchState(new FreeplayState());
								FlxG.sound.playMusic(Paths.music('aviOST/seekingFreedom'));
							}
						});
					});

					FlxG.mouse.load(Paths.image('favi/ui/Cursor').bitmap);
				}

				if (tryLerp == 1)
				{
					FlxTween.tween(stupidAssCam, {zoom: stupidAssCam.zoom + 0.5}, 4, {ease: FlxEase.expoInOut});
					FlxTween.tween(deathHUD, {zoom: 1.7}, 1.2, {ease: FlxEase.expoOut});

					new FlxTimer().start(0.7, function(tmr:FlxTimer)
					{
						var random:Int = FlxG.random.int(1, 11);
						stupidAssCam.fade(FlxColor.BLACK, 2, false, function()
						{
							var songName:Array<String> = ['Dont Cross', "Dont-Cross", "dont cross", "dont-cross"];

							for (i in songName)
								if (PlayState.SONG.song == i)
								{
									var songLowercase:String = "dont-cross";
									var poop:String = "dont-cross-hard" + '${random}'; //fuck fuck fuck fuck fuck fuck
									PlayState.SONG = Song.loadFromJson(poop, songLowercase, random);
								}
				
							if (PlayState.deathCounter == 15)
								MusicBeatState.switchState(new BotplayScreen());
							else
								MusicBeatState.resetState();
						});
					});
				}
				camLerpBullshit = 0;
				isEnding = true;
			}
		}
	}
}

class EverettBaseDeath extends MusicBeatSubstate {
	public static var instance:EverettBaseDeath;

	var stupidAssCam:FlxCamera;

	var uiArrowUp:FlxSprite;
	var uiArrowDown:FlxSprite;
	var uiRetry:FlxSprite;
	var uiLeave:FlxSprite;

	var quitLerp:Float = 0.5;
	var tryLerp:Float = 1;
	var arrowLerp:Float = 0.0001;

	var isEnding:Bool = false;

	var scratch:FlxSprite;

	override function create()
	{
		instance = this;

		stupidAssCam = new FlxCamera();
		FlxG.cameras.add(stupidAssCam);

		Conductor.songPosition = 0;

		var deathImage:FlxSprite = new FlxSprite().loadGraphic(Paths.image(Image.EVERETT_DEFAULT));
		deathImage.screenCenter();
		deathImage.scrollFactor.set(0, 0);
		deathImage.cameras = [stupidAssCam];
		deathImage.alpha = 0.001;
		deathImage.setGraphicSize(0, FlxG.height);
		add(deathImage);

		quitLerp = 0.0001;
		tryLerp = 0.0001;

		uiArrowDown = new FlxSprite().loadGraphic(Paths.image("favi/ui/gameOvers/arrowEverett"));
		uiArrowUp = new FlxSprite().loadGraphicFromSprite(uiArrowDown);
		uiRetry = new FlxSprite().loadGraphic(Paths.image("favi/ui/gameOvers/everett/retryEverett"));
		uiLeave = new FlxSprite().loadGraphic(Paths.image("favi/ui/gameOvers/everett/leaveEverett"));

		for (everettUI in [uiArrowDown, uiArrowUp, uiRetry, uiLeave])
		{
			everettUI.cameras = [stupidAssCam];
			everettUI.screenCenter();
			everettUI.scrollFactor.set(0, 0);
			everettUI.scale.set(0.37, 0.37);
			everettUI.alpha = 0.001;
			everettUI.x += 200;
			everettUI.y -= 54;
			add(everettUI);
		}

		uiArrowDown.angle = 186;
		uiArrowDown.x -= 180;
		uiArrowDown.y += 10;
		uiArrowUp.x += 50;
		uiArrowUp.y -= 70;

		stupidAssCam.scroll.set();

		deathImage.alpha = 0.0001;
		new flixel.util.FlxTimer().start(0.5, function(tmr)
		{
			FlxTween.tween(deathImage, {alpha: 1}, 3);
		});

		new FlxTimer().start(2.5, function(tmr:FlxTimer)
		{
			FlxG.sound.playMusic(Paths.music("aviOST/gameOver/amIReal"), 1);
			FlxG.sound.music.fadeIn(2, 0, 1);
			arrowLerp = 1;
			tryLerp = 1;
		});

		super.create();

		if (!ClientPrefs.data.lowQuality)
		{
			scratch = new FlxSprite();
			scratch.frames = Paths.getSparrowAtlas('favi/filters/scratchShit');
			scratch.animation.addByPrefix('e', 'scratch thing', 24, true);
			scratch.animation.play('e');
			scratch.cameras = [stupidAssCam];
			scratch.scrollFactor.set(0, 0);
			add(scratch);
		}
	}

	override function update(elapsed:Float)
	{
		uiRetry.alpha = FlxMath.lerp(tryLerp, uiRetry.alpha, CoolUtil.boundTo(1 - (elapsed * 8), 0, 1));
		uiLeave.alpha = FlxMath.lerp(quitLerp, uiLeave.alpha, CoolUtil.boundTo(1 - (elapsed * 8), 0, 1));
		uiArrowDown.alpha = FlxMath.lerp(arrowLerp, uiArrowDown.alpha, CoolUtil.boundTo(1 - (elapsed * 9), 0, 1));
		uiArrowUp.alpha = FlxMath.lerp(arrowLerp, uiArrowUp.alpha, CoolUtil.boundTo(1 - (elapsed * 9), 0, 1));

		if (FlxG.sound.music.playing)
		{
			Conductor.songPosition = FlxG.sound.music.time;
		}

		if ((controls.UI_DOWN_P || controls.UI_UP_P) && arrowLerp == 1)
		{
			quitLerp = quitLerp == 1 ? 0.001 : 1;
			tryLerp = tryLerp == 1 ? 0.001 : 1;
			FlxG.sound.play(Paths.sound('funkinAVI/menu/scrollSfx'));
			if (controls.UI_DOWN_P)
				uiArrowDown.alpha = 0.3;
			if (controls.UI_UP_P)
				uiArrowUp.alpha = 0.3;
		}

		if (controls.ACCEPT && arrowLerp == 1 && !isEnding)
		{
			FlxG.sound.music.stop();
			FlxG.sound.play(Paths.music('aviOST/gameOver/bellToll'));
			PlayState.pauseCountEnabled = false;

			if (tryLerp == 1)
			{	
				FlxTween.tween(stupidAssCam, {zoom: stupidAssCam.zoom + 0.5}, 4, {ease: FlxEase.expoInOut});
				new FlxTimer().start(0.7, function(tmr:FlxTimer)
				{
					stupidAssCam.fade(FlxColor.BLACK, 2, false, function()
					{
						if (PlayState.deathCounter == 3)
							MusicBeatState.switchState(new BotplayScreen());
						else
							MusicBeatState.resetState();
					});
				});
			}

			if (quitLerp == 1)
			{
				PlayState.deathCounter = 0;
				PlayState.seenCutscene = false;
				PlayState.chartingMode = false;
				Lib.application.window.onClose.removeAll(); // goes back to normal hopefully
				Lib.application.window.onClose.add(function() {
				DiscordClient.shutdown();
				});

				if (PlayState.isStoryMode)
				{
					stupidAssCam.fade(FlxColor.BLACK, 1.4, false, function()
					{
						MusicBeatState.switchState(new StoryMenuState());
						FlxG.sound.playMusic(Paths.music('aviOST/gameOver/rottenPetals'));
					});
				}
				else
				{
					stupidAssCam.fade(FlxColor.BLACK, 1.4, false, function()
					{
						MusicBeatState.switchState(new FreeplayState());
						FlxG.sound.playMusic(Paths.music('aviOST/seekingFreedom'));
					});
				}
				FlxG.mouse.load(Paths.image('favi/ui/Cursor').bitmap);
			}
			arrowLerp = quitLerp = tryLerp = 0;
			isEnding = true;
		}
	}
}

class WarGameOver extends MusicBeatSubstate {
	public static var instance:WarGameOver;

	var stupidAssCam:FlxCamera;
	var deathHUD:FlxCamera;

	var uiArrowUp:FlxSprite;
	var uiArrowDown:FlxSprite;
	var uiRetry:FlxSprite;
	var uiLeave:FlxSprite;

	var quitLerp:Float = 0.5;
	var tryLerp:Float = 1;
	var arrowLerp:Float = 0.0001;

	var isEnding:Bool = false;

	var scratch:FlxSprite;

	override function create()
	{
		instance = this;

		stupidAssCam = new FlxCamera();
		deathHUD = new FlxCamera();
		deathHUD.bgColor.alpha = 0;

		FlxG.cameras.add(stupidAssCam);
		FlxG.cameras.add(deathHUD, false);
		deathHUD.alpha = 0.25;

		Conductor.songPosition = 0;

		var deathImage:FlxSprite = new FlxSprite().loadGraphic(Paths.image(Image.WAR_DILEMMA));
		deathImage.screenCenter();
		deathImage.scrollFactor.set(0, 0);
		deathImage.cameras = [stupidAssCam];
		deathImage.alpha = 0.001;
		deathImage.setGraphicSize(0, FlxG.height);
		add(deathImage);

		quitLerp = 0.0001;
		tryLerp = 0.0001;

		uiArrowDown = new FlxSprite().loadGraphic(Paths.image("favi/ui/gameOvers/warDilemma/warArrowD"));
		uiArrowUp = new FlxSprite().loadGraphic(Paths.image("favi/ui/gameOvers/warDilemma/warArrowU"));
		uiRetry = new FlxSprite().loadGraphic(Paths.image("favi/ui/gameOvers/warDilemma/warRetry"));
		uiLeave = new FlxSprite().loadGraphic(Paths.image("favi/ui/gameOvers/warDilemma/warLeave"));

		for (warUI in [uiArrowDown, uiArrowUp, uiRetry, uiLeave])
		{
			warUI.screenCenter();
			warUI.scrollFactor.set(0, 0);
			warUI.cameras = [stupidAssCam];
			warUI.setGraphicSize(0, FlxG.height);
			warUI.alpha = 0.0001;
			add(warUI);
		}

		deathImage.alpha = 0.0001;
		deathHUD.fade(FlxColor.WHITE, 1, true);
		FlxG.sound.play(Paths.sound("gunSfx"));
		new flixel.util.FlxTimer().start(1.15, function(tmr)
		{
			FlxTween.tween(deathImage, {alpha: 1}, 3);
		});

		new FlxTimer().start(4, function(tmr:FlxTimer)
		{
			FlxG.sound.playMusic(Paths.music("aviOST/gameOver/amIReal"), 1);
			FlxG.sound.music.fadeIn(2, 0, 1);
			arrowLerp = 1;
			tryLerp = 1;
		});

		super.create();

		if (!ClientPrefs.data.lowQuality)
		{
			scratch = new FlxSprite();
			scratch.frames = Paths.getSparrowAtlas('favi/filters/scratchShit');
			scratch.animation.addByPrefix('e', 'scratch thing', 24, true);
			scratch.animation.play('e');
			scratch.cameras = [stupidAssCam];
			scratch.scrollFactor.set(0, 0);
			add(scratch);
		}
	}

	override function update(elapsed:Float)
	{
		uiRetry.alpha = FlxMath.lerp(tryLerp, uiRetry.alpha, CoolUtil.boundTo(1 - (elapsed * 8), 0, 1));
		uiLeave.alpha = FlxMath.lerp(quitLerp, uiLeave.alpha, CoolUtil.boundTo(1 - (elapsed * 8), 0, 1));
		uiArrowDown.alpha = FlxMath.lerp(arrowLerp, uiArrowDown.alpha, CoolUtil.boundTo(1 - (elapsed * 9), 0, 1));
		uiArrowUp.alpha = FlxMath.lerp(arrowLerp, uiArrowUp.alpha, CoolUtil.boundTo(1 - (elapsed * 9), 0, 1));

		if (FlxG.sound.music.playing)
		{
			Conductor.songPosition = FlxG.sound.music.time;
		}

		if ((controls.UI_DOWN_P || controls.UI_UP_P) && arrowLerp == 1)
		{
			quitLerp = quitLerp == 1 ? 0.001 : 1;
			tryLerp = tryLerp == 1 ? 0.001 : 1;
			FlxG.sound.play(Paths.sound('funkinAVI/menu/scrollSfx'));
			if (controls.UI_DOWN_P)
				uiArrowDown.alpha = 0.3;
			if (controls.UI_UP_P)
				uiArrowUp.alpha = 0.3;
		}

		if (controls.ACCEPT && arrowLerp == 1 && !isEnding)
		{
			FlxG.sound.music.stop();
			FlxG.sound.play(Paths.music('aviOST/gameOver/bellToll'));
			PlayState.pauseCountEnabled = false;

			if (tryLerp == 1)
			{	
				FlxTween.tween(stupidAssCam, {zoom: stupidAssCam.zoom + 0.5}, 4, {ease: FlxEase.expoInOut});
				new FlxTimer().start(0.7, function(tmr:FlxTimer)
				{
					stupidAssCam.fade(FlxColor.BLACK, 2, false, function()
					{
						if (PlayState.deathCounter == 3)
							MusicBeatState.switchState(new BotplayScreen());
						else
							MusicBeatState.resetState();
					});
				});
			}

			if (quitLerp == 1)
			{
				PlayState.deathCounter = 0;
				PlayState.seenCutscene = false;
				PlayState.chartingMode = false;
				Lib.application.window.onClose.removeAll(); // goes back to normal hopefully
				Lib.application.window.onClose.add(function() {
				DiscordClient.shutdown();
				});

				if (PlayState.isStoryMode)
				{
					stupidAssCam.fade(FlxColor.BLACK, 1.4, false, function()
					{
						MusicBeatState.switchState(new StoryMenuState());
						FlxG.sound.playMusic(Paths.music('aviOST/gameOver/rottenPetals'));
					});
				}
				else
				{
					stupidAssCam.fade(FlxColor.BLACK, 1.4, false, function()
					{
						MusicBeatState.switchState(new FreeplayState());
						FlxG.sound.playMusic(Paths.music('aviOST/seekingFreedom'));
					});
				}
				FlxG.mouse.load(Paths.image('favi/ui/Cursor').bitmap);
			}
			arrowLerp = quitLerp = tryLerp = 0;
			isEnding = true;
		}
	}
}

class WompWompSadMan extends MusicBeatSubstate {
	public static var instance:WompWompSadMan;

	var stupidAssCam:FlxCamera;

	var uiRetry:FlxSprite;
	var uiLeave:FlxSprite;

	var quitLerp:Float = 0.5;
	var tryLerp:Float = 1;

	var isEnding:Bool = false;

	var scratch:FlxSprite;

	override function create()
	{
		instance = this;

		stupidAssCam = new FlxCamera();
		FlxG.cameras.add(stupidAssCam);

		Conductor.songPosition = 0;

		var deathImage:FlxSprite = new FlxSprite().loadGraphic(Paths.image(Image.BIRTHDAY));
		deathImage.screenCenter();
		deathImage.scrollFactor.set(0, 0);
		deathImage.cameras = [stupidAssCam];
		deathImage.alpha = 0.001;
		deathImage.setGraphicSize(0, FlxG.height);
		add(deathImage);

		quitLerp = 0.0001;
		tryLerp = 0.0001;

		uiRetry = new FlxSprite().loadGraphic(Paths.image("favi/ui/gameOvers/birthday/birthdayRetry"));
		uiLeave = new FlxSprite().loadGraphic(Paths.image("favi/ui/gameOvers/birthday/birthdayLeave"));

		for (bUI in [uiRetry, uiLeave])
		{
			bUI.screenCenter();
			bUI.scrollFactor.set(0, 0);
			bUI.cameras = [stupidAssCam];
			bUI.setGraphicSize(0, FlxG.height);
			bUI.alpha = 0.0001;
			add(bUI);
		}

		stupidAssCam.scroll.set();

		deathImage.alpha = 0.0001;
		new flixel.util.FlxTimer().start(0.85, function(tmr)
		{
			FlxG.sound.play(Paths.sound("spotlightSfx"));
			deathImage.alpha = 1;
		});

		new FlxTimer().start(3, function(tmr:FlxTimer)
		{
			FlxG.sound.playMusic(Paths.music("aviOST/gameOver/amIReal"), 1);
			FlxG.sound.music.fadeIn(2, 0, 1);
			quitLerp = 0.18;
			tryLerp = 1;
		});

		super.create();

		if (!ClientPrefs.data.lowQuality)
		{
			scratch = new FlxSprite();
			scratch.frames = Paths.getSparrowAtlas('favi/filters/scratchShit');
			scratch.animation.addByPrefix('e', 'scratch thing', 24, true);
			scratch.animation.play('e');
			scratch.cameras = [stupidAssCam];
			scratch.scrollFactor.set(0, 0);
			add(scratch);
		}
	}

	override function update(elapsed:Float)
	{
		uiRetry.alpha = FlxMath.lerp(tryLerp, uiRetry.alpha, CoolUtil.boundTo(1 - (elapsed * 8), 0, 1));
		uiLeave.alpha = FlxMath.lerp(quitLerp, uiLeave.alpha, CoolUtil.boundTo(1 - (elapsed * 8), 0, 1));

		if (FlxG.sound.music.playing)
		{
			Conductor.songPosition = FlxG.sound.music.time;
		}

		if ((controls.UI_LEFT_P || controls.UI_RIGHT_P) && quitLerp > 0.1)
		{
			quitLerp = quitLerp == 1 ? 0.18 : 1;
			tryLerp = tryLerp == 1 ? 0.18 : 1;
			FlxG.sound.play(Paths.sound('funkinAVI/menu/scrollSfx'));
		}

		if (controls.ACCEPT && quitLerp > 0.1 && !isEnding)
		{
			FlxG.sound.music.stop();
			FlxG.sound.play(Paths.music('aviOST/gameOver/bellToll'));
			PlayState.pauseCountEnabled = false;

			if (tryLerp == 1)
			{	
				FlxTween.tween(stupidAssCam, {zoom: stupidAssCam.zoom + 0.5}, 4, {ease: FlxEase.expoInOut});
				new FlxTimer().start(0.7, function(tmr:FlxTimer)
				{
					stupidAssCam.fade(FlxColor.BLACK, 2, false, function()
					{
						if (PlayState.deathCounter == 3)
							MusicBeatState.switchState(new BotplayScreen());
						else
							MusicBeatState.resetState();
					});
				});
			}

			if (quitLerp == 1)
			{
				stupidAssCam.fade(FlxColor.BLACK, 1.4, false, function()
				{
					MusicBeatState.switchState(new ManIHateYouSoMuchYouMadeMuckneySad());
				});
			}
			quitLerp = tryLerp = 0;
			isEnding = true;
		}
	}
}

class MalsquareDeath extends MusicBeatSubstate {
	public static var instance:MalsquareDeath;

	var stupidAssCam:FlxCamera;

	var uiRetry:FlxSprite;
	var uiLeave:FlxSprite;

	var quitLerp:Float = 0.5;
	var tryLerp:Float = 1;

	var quitCol:FlxTween;
	var tryCol:FlxTween;

	var isEnding:Bool = false;

	override function create()
	{
		instance = this;

		stupidAssCam = new FlxCamera();
		FlxG.cameras.add(stupidAssCam);

		Conductor.songPosition = 0;

		var deathImage:FlxSprite = new FlxSprite().loadGraphic(Paths.image(Image.MALFUNCTION));
		deathImage.screenCenter();
		deathImage.scrollFactor.set(0, 0);
		deathImage.cameras = [stupidAssCam];
		deathImage.alpha = 0.45;
		deathImage.setGraphicSize(0, FlxG.height);
		add(deathImage);

		quitLerp = 0.0001;
		tryLerp = 0.0001;

		if (PlayState.instance.dad.curCharacter == "glitched-mickey-new-pixel" || PlayState.instance.dad.curCharacter == "malsquare-withFace")
		{
			var malsquare:FlxSprite = new FlxSprite().loadGraphic(Paths.image("favi/ui/gameOvers/malfunction/malsquareDeath"));
			malsquare.screenCenter();
			malsquare.scrollFactor.set(0, 0);
			malsquare.cameras = [stupidAssCam];
			malsquare.setGraphicSize(0, FlxG.height);
			add(malsquare);
		}

		if (PlayState.instance.dad.curCharacter == "malsquare-withFace")
		{
			var malsquare:FlxSprite = new FlxSprite().loadGraphic(Paths.image("favi/ui/gameOvers/malfunction/malDeathEye"));
			malsquare.screenCenter();
			malsquare.scrollFactor.set(0, 0);
			malsquare.cameras = [stupidAssCam];
			malsquare.setGraphicSize(0, FlxG.height);
			add(malsquare);
		}

		var bf:FlxSprite = new FlxSprite().loadGraphic(Paths.image("favi/ui/gameOvers/malfunction/everettMal"));
		uiRetry = new FlxSprite().loadGraphic(Paths.image("favi/ui/gameOvers/malfunction/malRetry"));
		uiLeave = new FlxSprite().loadGraphic(Paths.image("favi/ui/gameOvers/malfunction/malLeave"));

		for (bUI in [bf, uiRetry, uiLeave])
		{
			bUI.screenCenter();
			bUI.scrollFactor.set(0, 0);
			bUI.cameras = [stupidAssCam];
			bUI.setGraphicSize(0, FlxG.height);
			bUI.alpha = 0.0001;
			add(bUI);
		}
		bf.alpha = 1;
		uiRetry.color = FlxColor.RED;

		var stupidBlackGraphic = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
		stupidBlackGraphic.setGraphicSize(FlxG.width*1.5, FlxG.height*1.5);
		stupidBlackGraphic.screenCenter();
		add(stupidBlackGraphic);
		FlxTween.tween(stupidBlackGraphic, {alpha: 0}, 4);

		new FlxTimer().start(3, function(tmr:FlxTimer)
		{
			FlxG.sound.playMusic(Paths.music("aviOST/gameOver/amIReal"), 1);
			FlxG.sound.music.fadeIn(2, 0, 1);
			quitLerp = 0.5;
			tryLerp = 1;
		});

		super.create();
	}

	override function update(elapsed:Float)
	{
		uiRetry.alpha = FlxMath.lerp(tryLerp, uiRetry.alpha, CoolUtil.boundTo(1 - (elapsed * 8), 0, 1));
		uiLeave.alpha = FlxMath.lerp(quitLerp, uiLeave.alpha, CoolUtil.boundTo(1 - (elapsed * 8), 0, 1));

		if (FlxG.sound.music.playing)
		{
			Conductor.songPosition = FlxG.sound.music.time;
		}

		if ((controls.UI_LEFT_P || controls.UI_RIGHT_P) && quitLerp > 0.35)
		{
			if (quitCol != null) quitCol.cancel();
			if (tryCol != null) tryCol.cancel();
			quitLerp = quitLerp == 1 ? 0.5 : 1;
			tryLerp = tryLerp == 1 ? 0.5 : 1;
			quitCol = FlxTween.color(uiLeave, 0.15, uiLeave.color, (quitLerp == 1 ? FlxColor.RED : FlxColor.WHITE), {ease: FlxEase.sineOut,
				onComplete: function(twn:FlxTween) {
					quitCol = null;
				}
			});
			tryCol = FlxTween.color(uiRetry, 0.15, uiRetry.color, (tryLerp == 1 ? FlxColor.RED : FlxColor.WHITE), {ease: FlxEase.sineOut,
				onComplete: function(twn:FlxTween) {
					tryCol = null;
				}
			});
			FlxG.sound.play(Paths.sound('funkinAVI/menu/scrollSfx'));
		}

		if (controls.ACCEPT && quitLerp > 0.35 && !isEnding)
		{
			FlxG.sound.music.stop();
			FlxG.sound.play(Paths.music('aviOST/gameOver/bellToll'));
			PlayState.pauseCountEnabled = false;

			if (tryLerp == 1)
			{	
				FlxTween.tween(stupidAssCam, {zoom: stupidAssCam.zoom + 0.5}, 4, {ease: FlxEase.expoInOut});
				new FlxTimer().start(0.7, function(tmr:FlxTimer)
				{
					stupidAssCam.fade(FlxColor.BLACK, 2, false, function()
					{
						if (PlayState.deathCounter == 3)
							MusicBeatState.switchState(new BotplayScreen());
						else
							MusicBeatState.resetState();
					});
				});
			}

			if (quitLerp == 1)
			{
				PlayState.deathCounter = 0;
				PlayState.seenCutscene = false;
				PlayState.chartingMode = false;
				Lib.application.window.onClose.removeAll(); // goes back to normal hopefully
				Lib.application.window.onClose.add(function() {
				DiscordClient.shutdown();
				});

				if (PlayState.isStoryMode)
				{
					stupidAssCam.fade(FlxColor.BLACK, 1.4, false, function()
					{
						MusicBeatState.switchState(new StoryMenuState());
						FlxG.sound.playMusic(Paths.music('aviOST/gameOver/rottenPetals'));
					});
				}
				else
				{
					stupidAssCam.fade(FlxColor.BLACK, 1.4, false, function()
					{
						MusicBeatState.switchState(new FreeplayState());
						FlxG.sound.playMusic(Paths.music('aviOST/seekingFreedom'));
					});
				}
				FlxG.mouse.load(Paths.image('favi/ui/Cursor').bitmap);
			}
			quitLerp = tryLerp = 0;
			isEnding = true;
		}
	}
}

class MalsquareTrollScreen extends MusicBeatSubstate {
	public static var instance:MalsquareTrollScreen;
	var stupidAssCam:FlxCamera;
	var currentFPS:Int;
	var isEnding:Bool = false;

	//da sprite
	var bg:FlxSprite;
	var tiles:FlxBackdrop;
	var jerk:FlxSprite;
	var insult:FlxText;
	var selector:FlxText;

	override function create()
	{
		instance = this;

		stupidAssCam = new FlxCamera();
		FlxG.cameras.add(stupidAssCam);
		//stupidAssCam.fade(FlxColor.BLACK, 0.55, true);

		currentFPS = ClientPrefs.data.framerate;
		ClientPrefs.data.framerate = 15; //least annoying gimmick
		FlxG.updateFramerate = ClientPrefs.data.framerate;
		FlxG.drawFramerate = ClientPrefs.data.framerate;

		Conductor.songPosition = 0;

		bg = new FlxSprite().loadGraphic(Paths.image("favi/ui/gameOvers/malfunction/troll/trollBG"));
		bg.antialiasing = false;
		bg.screenCenter();
		bg.alpha = 0.001;
		bg.cameras = [stupidAssCam];
		add(bg);

		tiles = new FlxBackdrop(Paths.image("favi/ui/gameOvers/malfunction/troll/trollTiles")/*, XY, 0, 0*/);
		tiles.antialiasing = false;
		tiles.velocity.set(0, 0);
		tiles.scale.set(0.1, 0.1);
		tiles.alpha = 0;
		tiles.cameras = [stupidAssCam];
		add(tiles);

		jerk = new FlxSprite();
		jerk.frames = Paths.getSparrowAtlas("favi/ui/gameOvers/malfunction/troll/asshole");
		jerk.animation.addByIndices("static", "idle", [1], "", 24, true); //to make him look like he's waiting to pull the biggest troll ever
		jerk.animation.addByPrefix("idle", "idle", 45, true);
		jerk.antialiasing = false;
		jerk.screenCenter();
		jerk.y += 1200;
		jerk.scale.set(2.1, 2.1);
		jerk.cameras = [stupidAssCam];
		add(jerk);

		insult = new FlxText(0, 15, 1280, "Holy shit you're bad lmao!", 0);
		insult.setFormat(Paths.font("Retro Gaming.ttf"), 70, FlxColor.BLACK, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.WHITE);
		insult.screenCenter(X);
		insult.borderSize = 3;
		insult.visible = false;
		insult.cameras = [stupidAssCam];
		add(insult);

		selector = new FlxText(0, 550, 1280, "<  Suffer More!  >", 0);
		selector.setFormat(Paths.font("Retro Gaming.ttf"), 75, FlxColor.BLACK, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.WHITE);
		selector.screenCenter(X);
		selector.cameras = [stupidAssCam];
		selector.borderSize = 3;
		selector.visible = false;
		add(selector);

		super.create();

		jerk.animation.play("static");
		FlxTween.tween(jerk, {y: jerk.y - 1280}, 1, {ease: FlxEase.sineOut});
		FlxG.sound.play(Paths.sound("stupidWhooshSfx"));

		FlxTween.tween(bg, {alpha: 0.35}, 3);
		new FlxTimer().start(3, function(tmr:FlxTimer)
		{
			stupidAssCam.flash(FlxColor.WHITE, 1);
			selector.visible = true;
			FlxG.sound.playMusic(Paths.music("internetTheme"), 1);
			jerk.animation.play("idle");
			tiles.velocity.set(40, -40);
			insult.visible = true;
			FlxTween.tween(tiles, {alpha: 0.65}, 1);
			FlxTween.tween(bg, {angle: 360}, 4.5, {type: LOOPING});
		});
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		
		if (FlxG.sound.music.playing)
		{
			Conductor.songPosition = FlxG.sound.music.time;
		}

		if (selector.visible && !isEnding)
		{
			if (controls.UI_LEFT_P || controls.UI_RIGHT_P)
			{
				if (selector.text == "<  Suffer More!  >")
					selector.text = "<  Ragequit Lmao!  >";
				else
					selector.text = "<  Suffer More!  >";

				FlxG.sound.play(Paths.sound('funkinAVI/menu/scrollSfx'));
			}

			if (controls.ACCEPT)
			{
				FlxG.sound.music.stop();
				FlxG.sound.play(Paths.music('aviOST/gameOver/bellToll'));
				PlayState.pauseCountEnabled = false;
				PlayState.malfunctionTrollCounter = 0;

				stupidAssCam.fade(FlxColor.BLACK, 3, false);
				new FlxTimer().start(3, function(tmr:FlxTimer)
				{
					if (selector.text == "<  Suffer More!  >")
					{
						MusicBeatState.resetState();
						PlayState.instance.callOnScripts('onGameOverConfirm', [true]);
					}
					else 
					{
						PlayState.deathCounter = 0;
						PlayState.seenCutscene = false;
						PlayState.chartingMode = false;
						Lib.application.window.onClose.removeAll(); // goes back to normal hopefully
						Lib.application.window.onClose.add(function() {
						DiscordClient.shutdown();
						});
		
						if (PlayState.isStoryMode)
						{
							MusicBeatState.switchState(new StoryMenuState());
							FlxG.sound.playMusic(Paths.music('aviOST/gameOver/rottenPetals'));
						}
						else
						{
							MusicBeatState.switchState(new FreeplayState());
							FlxG.sound.playMusic(Paths.music('aviOST/seekingFreedom'));
						}
						FlxG.mouse.load(Paths.image('favi/ui/Cursor').bitmap);
					}
					remove(bg);
					remove(tiles);
					remove(jerk);
					remove(insult);
					remove(selector);
					ClientPrefs.data.framerate = currentFPS; //changes back to normal
					FlxG.updateFramerate = ClientPrefs.data.framerate;
					FlxG.drawFramerate = ClientPrefs.data.framerate;
				});
				isEnding = true;
			}
		}
	}

	override function destroy()
	{
		instance = null;
		super.destroy();
	}
}