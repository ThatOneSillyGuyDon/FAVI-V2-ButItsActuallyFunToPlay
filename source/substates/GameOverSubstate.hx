package substates;

import flixel.addons.transition.FlxTransitionableState;

/**
 * ## This is the screen that plays when you die in a song! Sounds simple enough, right?
 * 
 * @param boyfriend Your Death Screen Sprite
 * @param camFollow An object that tells the camera where to center at
 * @param camFollowPos An object that gives the camera the smooth movement
 * @param updateCamera A bool value that tells the game when to start moving the camera
 * @param playingDeathSound Tells the game when to start the game over music
 * @param stageSuffix This variable is currently unused for now
 * @param characterName The name of the death sprite you want to use
 * @param deathSoundName The name of the death sound you want to use
 * @param loopSoundName The name of the game over music you want to use
 * @param endSoundname The name of the sound you want to use when the player hits retry
 * @param instance Static access varibale to call on to prevent the game from giving issues when accessing certain elements
 */
class GameOverSubstate extends MusicBeatSubstate
{
	public var boyfriend:Boyfriend;
	var camFollow:FlxPoint;
	var camFollowPos:FlxObject;
	var updateCamera:Bool = false;
	var playingDeathSound:Bool = false;

	var stageSuffix:String = "";

	public static var characterName:String = 'bf-dead';
	public static var deathSoundName:String = 'fnf_loss_sfx';
	public static var loopSoundName:String = 'gameOver';
	public static var endSoundName:String = 'gameOverEnd';

	public static var instance:GameOverSubstate;

	var game:FlxText;
	var over:FlxText;
	var tryAgain:FlxText;
	var quit:FlxText;

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

	public static var deathHUD:FlxCamera;
	public static var stupidAssCam:FlxCamera;

	// Everett Death Screen Buttons
	var everettArrowUp:FlxSprite;
	var everettArrowDown:FlxSprite;
	var everettRetry:FlxSprite;
	var everettLeave:FlxSprite;

	//Delusional Stuff
	var deluRetry:FlxSprite;
	var deluQuit:FlxSprite;

	/**
	 * ## Resets variables to the default values!
	 * 
	 * This function is fairly simple to modify if you're making a mod.
	 */
	public static function resetVariables() {
		characterName = 'bf-dead';
		deathSoundName = 'fnf_loss_sfx';
		loopSoundName = 'soaringHigh';
		endSoundName = 'gameOverEnd';
	}

	override function create()
	{
		instance = this;
		PlayState.instance.callOnLuas('onGameOverStart', []);

		super.create();
	}

	public function new(x:Float, y:Float, camX:Float, camY:Float)
	{
		super();

		PlayState.instance.setOnLuas('inGameOver', true);

		stupidAssCam = new FlxCamera();
		deathHUD = new FlxCamera();
		deathHUD.bgColor.alpha = 0;

		FlxG.cameras.add(stupidAssCam);
		FlxG.cameras.add(deathHUD, false);
		deathHUD.alpha = 0.0001;

		Conductor.songPosition = 0;

		boyfriend = new Boyfriend(x, y, characterName);
		boyfriend.x += boyfriend.positionArray[0];
		boyfriend.y += boyfriend.positionArray[1];
		boyfriend.visible = false;
		boyfriend.cameras = [stupidAssCam];
		add(boyfriend);

		var image:String;

		switch (PlayState.SONG.song)
		{
			case "Isolated" | "Lunacy": image = "favi/ui/gameOvers/episode1Death";
			case "Delusional": image = "favi/ui/gameOvers/delusionalDeath";
			case "Dont Cross": image = "favi/ui/gameOvers/DontCrossGameOver";
			default: image = "favi/ui/gameOvers/everettDeath";
		}

		var deathImage:FlxSprite = new FlxSprite().loadGraphic(Paths.image(image));
		deathImage.screenCenter();
		deathImage.scrollFactor.set(0, 0);
		deathImage.cameras = [stupidAssCam];
		deathImage.setGraphicSize(0, FlxG.height);
		add(deathImage);

		switch(image)
		{
			case "favi/ui/gameOvers/everettDeath":
				quitLerp = 0.0001;
				tryLerp = 0.0001;
				everettArrowDown = new FlxSprite().loadGraphic(Paths.image("favi/ui/gameOvers/arrowEverett"));
				everettArrowUp = new FlxSprite().loadGraphicFromSprite(everettArrowDown);
				everettRetry = new FlxSprite().loadGraphic(Paths.image("favi/ui/gameOvers/retryEverett"));
				everettLeave = new FlxSprite().loadGraphic(Paths.image("favi/ui/gameOvers/leaveEverett"));
				for (everettUI in [everettArrowDown, everettArrowUp, everettRetry, everettLeave])
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
				everettArrowDown.angle = 186;
				everettArrowDown.x -= 180;
				everettArrowDown.y += 10;
				everettArrowUp.x += 50;
				everettArrowUp.y -= 70;

			case "favi/ui/gameOvers/delusionalDeath":
				tryLerp = 0.001;
				quitLerp = 0.001;

				deluRetry = new FlxSprite().loadGraphic(Paths.image("favi/ui/gameOvers/retryDelu"));
				deluRetry.screenCenter();
				deluRetry.x += 440;
				deluRetry.scrollFactor.set(0, 0);
				deluRetry.setGraphicSize(0, FlxG.height);
				deluRetry.cameras = [stupidAssCam];
				deluRetry.alpha = 0.0001;
				add(deluRetry);

				deluQuit = new FlxSprite().loadGraphic(Paths.image("favi/ui/gameOvers/deluLeave"));
				deluQuit.screenCenter();
				deluQuit.x += 440;
				deluQuit.scrollFactor.set(0, 0);
				deluQuit.setGraphicSize(0, FlxG.height);
				deluQuit.cameras = [stupidAssCam];
				deluQuit.alpha = 0.0001;
				add(deluQuit);

				everettArrowDown = new FlxSprite().loadGraphic(Paths.image("favi/ui/gameOvers/arrowEverett"));
				everettArrowUp = new FlxSprite().loadGraphicFromSprite(everettArrowDown);
				for (everettUI in [everettArrowDown, everettArrowUp])
				{
					everettUI.cameras = [stupidAssCam];
					everettUI.screenCenter();
					everettUI.scrollFactor.set(0, 0);
					everettUI.scale.set(0.37, 0.37);
					everettUI.alpha = 0.001;
					everettUI.x += 200;
					add(everettUI);
				}
				everettArrowDown.angle = 194;
				everettArrowUp.angle = 8;
				everettArrowDown.x += 50;
				everettArrowUp.x += 400;
		}

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

		camFollow = new FlxPoint(boyfriend.getGraphicMidpoint().x, boyfriend.getGraphicMidpoint().y);

		switch (PlayState.SONG.song)
		{
			case "Isolated Beta" | "Isolated Old" | "Isolated Legacy" | "Lunacy Legacy" | "Delusional Legacy" | "Twisted Grins Legacy" | "Hunted Legacy" | "Cycled Sins Legacy" | "Mercy Legacy" | "Malfunction Legacy" | "Bless": 
				boyfriend.visible = true;
				deathImage.alpha = 0.0001;
				FlxG.sound.play(Paths.sound(deathSoundName));
			case "Dont Cross":
				FlxG.sound.play(Paths.sound("wompWomp"));
			default:
				deathImage.alpha = 0.0001;
				new flixel.util.FlxTimer().start(0.5, function(tmr)
				{
					FlxTween.tween(deathImage, {alpha: 1}, 3);
				});
		}

		if (!boyfriend.visible && PlayState.SONG.song != "Dont Cross")
			endSoundName = "aviOST/gameOver/bellToll";

		if (!ClientPrefs.lowQuality)
		{
			switch (PlayState.curStage)
			{
				case 'stage' | 'desktop' | 'waltRoom' | 'apartment' | 'treasureIsland' | 'forbiddenRealm' | 'fuckingLine' | 'staticVoid' | 'vaultRoom' | 'war':
				// don't add scratch assets
	
				default:
					var scratch:FlxSprite = new FlxSprite();
					scratch.frames = Paths.getSparrowAtlas('favi/filters/scratchShit');
					scratch.animation.addByPrefix('e', 'scratch thing', 24, true);
					scratch.animation.play('e');
					scratch.cameras = [stupidAssCam];
					scratch.scrollFactor.set(0, 0);
					add(scratch);
			}
		}

		Conductor.bpm = (100);
		// FlxG.camera.followLerp = 1;
		// FlxG.camera.focusOn(FlxPoint.get(FlxG.width / 2, FlxG.height / 2));
		stupidAssCam.scroll.set();
		FlxG.camera.target = null;

		boyfriend.playAnim('firstDeath');

		camFollowPos = new FlxObject(0, 0, 1, 1);
		camFollowPos.setPosition(stupidAssCam.scroll.x + (stupidAssCam.width / 2), stupidAssCam.scroll.y + (stupidAssCam.height / 2));
		add(camFollowPos);
	}

	var quitLerp:Float = 0.5;
	var tryLerp:Float = 1;
	var camLerpBullshit:Float = 0.0001;

	var quitCol:FlxTween;
	var tryCol:FlxTween;

	var everArrowLerp:Float = 0.0001;

	var isFollowingAlready:Bool = false;
	override function update(elapsed:Float)
	{
		super.update(elapsed);

		tryAgain.alpha = FlxMath.lerp(tryLerp, tryAgain.alpha, CoolUtil.boundTo(1 - (elapsed * 15), 0, 1));
		quit.alpha = FlxMath.lerp(quitLerp, quit.alpha, CoolUtil.boundTo(1 - (elapsed * 15), 0, 1));
		deathHUD.alpha = FlxMath.lerp(camLerpBullshit, deathHUD.alpha, CoolUtil.boundTo(1 - (elapsed * 11), 0, 1));

		if (deluRetry != null) 
			deluRetry.alpha = FlxMath.lerp(tryLerp, deluRetry.alpha, CoolUtil.boundTo(1 - (elapsed * 8), 0, 1));

		if (deluQuit != null)
			deluQuit.alpha = FlxMath.lerp(quitLerp, deluQuit.alpha, CoolUtil.boundTo(1 - (elapsed * 8), 0, 1));

		if (everettArrowDown != null && everettArrowUp != null)
		{
			everettArrowDown.alpha = FlxMath.lerp(everArrowLerp, everettArrowDown.alpha, CoolUtil.boundTo(1 - (elapsed * 9), 0, 1));
			everettArrowUp.alpha = FlxMath.lerp(everArrowLerp, everettArrowUp.alpha, CoolUtil.boundTo(1 - (elapsed * 9), 0, 1));
		}

		if (everettRetry != null)
			everettRetry.alpha = FlxMath.lerp(tryLerp, everettRetry.alpha, CoolUtil.boundTo(1 - (elapsed * 8), 0, 1));

		if (everettLeave != null)
			everettLeave.alpha = FlxMath.lerp(quitLerp, everettLeave.alpha, CoolUtil.boundTo(1 - (elapsed * 8), 0, 1));

		PlayState.instance.callOnLuas('onUpdate', [elapsed]);
		if(updateCamera) {
			var lerpVal:Float = CoolUtil.boundTo(elapsed * 0.6, 0, 1);
			camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));
		}

		if (deathHUD.alpha >= 0.5)
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
		}

		if ((controls.UI_DOWN_P || controls.UI_UP_P) && everArrowLerp == 1 && everettRetry != null)
		{
			quitLerp = quitLerp == 1 ? 0.001 : 1;
			tryLerp = tryLerp == 1 ? 0.001 : 1;
			FlxG.sound.play(Paths.sound('funkinAVI/menu/scrollSfx'));
			if (controls.UI_DOWN_P)
				everettArrowDown.alpha = 0.3;
			if (controls.UI_UP_P)
				everettArrowUp.alpha = 0.3;
		}

		if ((controls.UI_LEFT_P || controls.UI_RIGHT_P) && everArrowLerp == 1 && deluRetry != null)
		{
			quitLerp = quitLerp == 1 ? 0.001 : 1;
			tryLerp = tryLerp == 1 ? 0.001 : 1;
			FlxG.sound.play(Paths.sound('funkinAVI/menu/scrollSfx'));
			if (controls.UI_LEFT_P)
				everettArrowDown.alpha = 0.3;
			if (controls.UI_RIGHT_P)
				everettArrowUp.alpha = 0.3;
		}

		if (controls.ACCEPT)
		{
			if ((tryLerp == 1 && deathHUD.alpha >= 0.5) || boyfriend.visible || (deluRetry != null && deluRetry.alpha >= 0.2) || (everettRetry != null && everettRetry.alpha >= 0.2))
				endBullshit();
	
			if (quitLerp == 1 && !boyfriend.visible)
				quitScreenShit();
		}

		if (controls.BACK && (boyfriend.visible || (deluRetry != null && deluRetry.alpha >= 0.2)))
		{
			quitScreenShit();
		}

		if (boyfriend.animation.curAnim != null && boyfriend.animation.curAnim.name == 'firstDeath')
		{
			if(boyfriend.animation.curAnim.curFrame >= 12 && !isFollowingAlready)
			{
				stupidAssCam.follow(camFollowPos, LOCKON, 1);
				updateCamera = true;
				isFollowingAlready = true;
			}

			if (boyfriend.animation.curAnim.finished && !playingDeathSound)
			{
				coolStartDeath();
				boyfriend.startedDeath = true;
			}
		}

		if (FlxG.sound.music.playing)
		{
			Conductor.songPosition = FlxG.sound.music.time;
		}
		PlayState.instance.callOnLuas('onUpdatePost', [elapsed]);
	}

	function restartDelutrance(noTrans:Bool = false)
	{
		if (PlayState.useFakeDeluName)
			PlayState.useFakeDeluName = false;
		PlayState.instance.paused = true; // For lua
		FlxG.sound.music.volume = 0;
		PlayState.instance.vocals.volume = 0;

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

	function quitScreenShit()
	{
			FlxG.sound.music.stop();
			PlayState.deathCounter = 0;
			PlayState.seenCutscene = false;
			PlayState.chartingMode = false;
			PlayState.pauseCountEnabled = false;

			WeekData.loadTheFirstEnabledMod();
			if (PlayState.isStoryMode)
			{
				if (GameData.highOnCrackLock == 'forceBackToSong')
				{
					restartDelutrance();
				}
				else
				{
					if (!boyfriend.visible)
					{
						FlxG.sound.music.stop();
						FlxG.sound.play(Paths.music(endSoundName));
						camLerpBullshit = everArrowLerp = quitLerp = tryLerp = 0;
						stupidAssCam.fade(FlxColor.BLACK, 1.4, false, function()
						{
							MusicBeatState.switchState(new StoryMenu());
							FlxG.sound.playMusic(Paths.music('aviOST/soullessTown'));
						});
					}
					else
					{
						MusicBeatState.switchState(new StoryMenu());
						FlxG.sound.playMusic(Paths.music('aviOST/soullessTown'));
					}
				}
			}
			else
			{
				if (GameData.highOnCrackLock == 'forceBackToSong')
				{
					restartDelutrance();
				}
				else
				{
					if (!boyfriend.visible)
					{
						FlxG.sound.music.stop();
						FlxG.sound.play(Paths.music(endSoundName));
						camLerpBullshit = everArrowLerp = quitLerp = tryLerp = 0;
						stupidAssCam.fade(FlxColor.BLACK, 1.4, false, function()
						{
							MusicBeatState.switchState(new FreeplayState());
							FlxG.sound.playMusic(Paths.music('aviOST/seekingFreedom'));
						});
					}
					else
					{
						MusicBeatState.switchState(new FreeplayState());
						FlxG.sound.playMusic(Paths.music('aviOST/seekingFreedom'));
					}
				}
			}
			FlxG.mouse.load(Paths.image('UI/funkinAVI/mouses/Hand').bitmap);
			PlayState.instance.callOnLuas('onGameOverConfirm', [false]);
	}

	override function beatHit()
	{
		super.beatHit();

		//FlxG.log.add('beat');
	}

	var isEnding:Bool = false;

	function coolStartDeath(?volume:Float = 1):Void
	{
		switch (PlayState.SONG.song)
		{
			case "Isolated" | "Lunacy" | "Delusional": FlxG.sound.playMusic(Paths.music("aviOST/gameOver/yourFinalBow"), volume);
			default: FlxG.sound.playMusic(Paths.music("aviOST/gameOver/soaringHigh"), volume);
		}
		FlxG.sound.music.fadeIn(2, 0, 1);
		if (!boyfriend.visible)
			camLerpBullshit = 1;
		if (deluRetry != null && !boyfriend.visible)
		{
			camLerpBullshit = 0;
			everArrowLerp = 1;
			tryLerp = 1;
		}
		if ((everettRetry != null || everettLeave != null) && !boyfriend.visible)
		{
			camLerpBullshit = 0;
			everArrowLerp = 1;
			tryLerp = 1;
		}
	}

	function endBullshit():Void
	{
		if (!isEnding)
		{
			isEnding = true;
			if (!boyfriend.visible)
			{
				FlxTween.tween(stupidAssCam, {zoom: stupidAssCam.zoom + 0.5}, 4, {ease: FlxEase.expoInOut});
				FlxTween.tween(deathHUD, {zoom: 1.7}, 1.2, {ease: FlxEase.expoOut});
				camLerpBullshit = everArrowLerp = quitLerp = tryLerp = 0;
			}
			boyfriend.playAnim('deathConfirm', true);
			FlxG.sound.music.stop();
			FlxG.sound.play(Paths.music(endSoundName));
			PlayState.pauseCountEnabled = false;
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
						
					MusicBeatState.resetState();
				});
			});
			PlayState.instance.callOnLuas('onGameOverConfirm', [true]);
		}
	}
}