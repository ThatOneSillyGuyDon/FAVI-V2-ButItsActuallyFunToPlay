package substates;

import flixel.addons.transition.FlxTransitionableState;
import openfl.Lib;

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

	var image:String;

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

	// Custom UI Graphics
	var uiArrowUp:FlxSprite;
	var uiArrowDown:FlxSprite;
	var uiRetry:FlxSprite;
	var uiLeave:FlxSprite;

	// Default UI
	var game:FlxText;
	var over:FlxText;
	var tryAgain:FlxText;
	var quit:FlxText;

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
		deathHUD.alpha = PlayState.SONG.song == "War Dilemma" ? 0.25 : 0.0001;

		Conductor.songPosition = 0;

		boyfriend = new Boyfriend(x, y, characterName);
		boyfriend.x += boyfriend.positionArray[0];
		boyfriend.y += boyfriend.positionArray[1];
		boyfriend.visible = false;
		boyfriend.cameras = [stupidAssCam];
		add(boyfriend);

		switch (PlayState.SONG.song)
		{
			case "Isolated" | "Lunacy": image = "favi/ui/gameOvers/episode1/episode1Death";
			case "Delusional": image = "favi/ui/gameOvers/episode1/delusional/delusionalDeath";
			case "Dont Cross": image = "favi/ui/gameOvers/DontCrossGameOver";
			case "Birthday": image = "favi/ui/gameOvers/birthday/birthdayGameOver";
			case "War Dilemma": image = "favi/ui/gameOvers/warDilemma/warGameOver";
			case "Malfunction": image = "favi/ui/gameOvers/malfunction/malDeathBG";
			default: image = "favi/ui/gameOvers/everett/everettDeath";
		}

		var deathImage:FlxSprite = new FlxSprite().loadGraphic(Paths.image(image));
		deathImage.screenCenter();
		deathImage.scrollFactor.set(0, 0);
		deathImage.cameras = [stupidAssCam];
		if (PlayState.SONG.song == "Malfunction")
			deathImage.alpha = 0.45;
		deathImage.setGraphicSize(0, FlxG.height);
		add(deathImage);

		switch(image)
		{
			case "favi/ui/gameOvers/malfunction/malDeathBG":
				quitLerp = 0.0001;
				tryLerp = 0.0001;

				if (PlayState.dad.curCharacter == "glitched-mickey-new-pixel" || PlayState.dad.curCharacter == "malsquare-withFace")
				{
					var malsquare:FlxSprite = new FlxSprite().loadGraphic(Paths.image("favi/ui/gameOvers/malfunction/malsquareDeath"));
					malsquare.screenCenter();
					malsquare.scrollFactor.set(0, 0);
					malsquare.cameras = [stupidAssCam];
					malsquare.setGraphicSize(0, FlxG.height);
					add(malsquare);
				}

				if (PlayState.dad.curCharacter == "malsquare-withFace")
				{
					var malsquare:FlxSprite = new FlxSprite().loadGraphic(Paths.image("favi/ui/gameOvers/malfunction/malDeathEye"));
					malsquare.screenCenter();
					malsquare.scrollFactor.set(0, 0);
					malsquare.cameras = [stupidAssCam];
					malsquare.setGraphicSize(0, FlxG.height);
					add(malsquare);
				}

				var bf:FlxSprite = new FlxSprite().loadGraphic(Paths.image("favi/ui/gameOvers/malfunction/everettMal"));
				uiArrowDown = new FlxSprite().loadGraphic(Paths.image("favi/ui/gameOvers/arrowEverett"));
				uiArrowUp = new FlxSprite().loadGraphicFromSprite(uiArrowDown);
				uiRetry = new FlxSprite().loadGraphic(Paths.image("favi/ui/gameOvers/malfunction/malRetry"));
				uiLeave = new FlxSprite().loadGraphic(Paths.image("favi/ui/gameOvers/malfunction/malLeave"));

				for (bUI in [bf, uiArrowDown, uiArrowUp, uiRetry, uiLeave])
				{
					bUI.screenCenter();
					bUI.scrollFactor.set(0, 0);
					bUI.cameras = [stupidAssCam];
					bUI.setGraphicSize(0, FlxG.height);
					bUI.alpha = 0.0001;
					add(bUI);
				}
				bf.alpha = 1;
				uiArrowDown.y = -9999;
				uiArrowUp.y = uiArrowDown.y;
				uiRetry.color = FlxColor.RED;
				

			case "favi/ui/gameOvers/birthday/birthdayGameOver":
				quitLerp = 0.0001;
				tryLerp = 0.0001;
				uiArrowDown = new FlxSprite().loadGraphic(Paths.image("favi/ui/gameOvers/arrowEverett"));
				uiArrowUp = new FlxSprite().loadGraphicFromSprite(uiArrowDown);
				uiRetry = new FlxSprite().loadGraphic(Paths.image("favi/ui/gameOvers/birthday/birthdayRetry"));
				uiLeave = new FlxSprite().loadGraphic(Paths.image("favi/ui/gameOvers/birthday/birthdayLeave"));

				for (bUI in [uiArrowDown, uiArrowUp, uiRetry, uiLeave])
				{
					bUI.screenCenter();
					bUI.scrollFactor.set(0, 0);
					bUI.cameras = [stupidAssCam];
					bUI.setGraphicSize(0, FlxG.height);
					bUI.alpha = 0.0001;
					add(bUI);
				}
				uiArrowDown.y = -9999;
				uiArrowUp.y = uiArrowDown.y;

			case "favi/ui/gameOvers/warDilemma/warGameOver":
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

			case "favi/ui/gameOvers/episode1/episode1Death":
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
				for (everettUI in [uiArrowDown, uiArrowUp])
				{
					everettUI.cameras = [stupidAssCam];
					everettUI.screenCenter();
					everettUI.scrollFactor.set(0, 0);
					everettUI.scale.set(0.37, 0.37);
					everettUI.alpha = 0.001;
					everettUI.x -= 524;
					everettUI.y -= 172;
					add(everettUI);
				}
				uiArrowDown.angle = 180;
				uiArrowUp.angle = -6;
				uiArrowDown.x += 50;
				uiArrowUp.x += 400;
				uiArrowDown.y += 62;
				uiArrowUp.y -= 40;
				
			case "favi/ui/gameOvers/everett/everettDeath":
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

			case "favi/ui/gameOvers/episode1/delusional/delusionalDeath":
				tryLerp = 0.001;
				quitLerp = 0.001;

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
		}

		if (uiRetry == null)
		{
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
		}

		camFollow = new FlxPoint(boyfriend.getGraphicMidpoint().x, boyfriend.getGraphicMidpoint().y);

		switch (PlayState.SONG.song)
		{
			case "Malfunction":
				stupidAssCam.fade(FlxColor.BLACK, 4, true);
			case "Birthday":
				deathImage.alpha = 0.0001;
				new flixel.util.FlxTimer().start(0.85, function(tmr)
				{
					FlxG.sound.play(Paths.sound("spotlightSfx"));
					deathImage.alpha = 1;
				});
			case "War Dilemma":
				deathImage.alpha = 0.0001;
				deathHUD.fade(FlxColor.WHITE, 1, true);
				FlxG.sound.play(Paths.sound("gunSfx"));
				new flixel.util.FlxTimer().start(1.15, function(tmr)
				{
					FlxTween.tween(deathImage, {alpha: 1}, 3);
				});
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

		// i fucking pasted this code from PlayState cause i'm lazy lmfaoooooo
		if (!ClientPrefs.lowQuality)
		{
			switch (PlayState.curStage)
			{
				case 'stage' | 'desktop' | 'waltRoom' | 'apartment' | 'treasureIsland' | 'forbiddenRealm' | 'fuckingLine' | 'staticVoid' | 'vaultRoom' | 'grassNation':
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

	var arrowLerp:Float = 0.0001;

	var isFollowingAlready:Bool = false;
	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (tryAgain != null)
		{
			tryAgain.alpha = FlxMath.lerp(tryLerp, tryAgain.alpha, CoolUtil.boundTo(1 - (elapsed * 15), 0, 1));
			quit.alpha = FlxMath.lerp(quitLerp, quit.alpha, CoolUtil.boundTo(1 - (elapsed * 15), 0, 1));
			deathHUD.alpha = FlxMath.lerp(camLerpBullshit, deathHUD.alpha, CoolUtil.boundTo(1 - (elapsed * 11), 0, 1));
		}

		if (uiRetry != null)
		{
			uiRetry.alpha = FlxMath.lerp(tryLerp, uiRetry.alpha, CoolUtil.boundTo(1 - (elapsed * 8), 0, 1));
			uiLeave.alpha = FlxMath.lerp(quitLerp, uiLeave.alpha, CoolUtil.boundTo(1 - (elapsed * 8), 0, 1));
			uiArrowDown.alpha = FlxMath.lerp(arrowLerp, uiArrowDown.alpha, CoolUtil.boundTo(1 - (elapsed * 9), 0, 1));
			uiArrowUp.alpha = FlxMath.lerp(arrowLerp, uiArrowUp.alpha, CoolUtil.boundTo(1 - (elapsed * 9), 0, 1));
		}

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

		if ((controls.UI_DOWN_P || controls.UI_UP_P) && arrowLerp == 1 && uiRetry != null && (image == "favi/ui/gameOvers/warDilemma/warGameOver" || image == "favi/ui/gameOvers/everett/everettDeath"))
		{
			quitLerp = quitLerp == 1 ? 0.001 : 1;
			tryLerp = tryLerp == 1 ? 0.001 : 1;
			FlxG.sound.play(Paths.sound('funkinAVI/menu/scrollSfx'));
			if (controls.UI_DOWN_P)
				uiArrowDown.alpha = 0.3;
			if (controls.UI_UP_P)
				uiArrowUp.alpha = 0.3;
		}

		if ((controls.UI_LEFT_P || controls.UI_RIGHT_P) && arrowLerp == 1 && uiRetry != null && image != "favi/ui/gameOvers/everett/everettDeath")
		{
			if (image == "favi/ui/gameOvers/malfunction/malDeathBG")
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
			}
			else
			{
				quitLerp = quitLerp == 1 ? (PlayState.SONG.song == "Birthday" ? 0.18 : 0.001) : 1;
				tryLerp = tryLerp == 1 ? (PlayState.SONG.song == "Birthday" ? 0.18 : 0.001) : 1;
			}
			FlxG.sound.play(Paths.sound('funkinAVI/menu/scrollSfx'));
			if (controls.UI_LEFT_P)
				uiArrowDown.alpha = 0.3;
			if (controls.UI_RIGHT_P)
				uiArrowUp.alpha = 0.3;
		}

		if (controls.ACCEPT)
		{
			if ((tryLerp == 1 && deathHUD.alpha >= 0.5) || boyfriend.visible || (uiRetry != null && uiRetry.alpha >= 0.55))
				endBullshit();
	
			if (quitLerp == 1 && !boyfriend.visible)
				quitScreenShit();
		}

		if (controls.BACK && boyfriend.visible)
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

	function quitScreenShit()
	{
			FlxG.sound.music.stop();
			PlayState.deathCounter = 0;
			PlayState.seenCutscene = false;
			PlayState.chartingMode = false;
			PlayState.pauseCountEnabled = false;
			Lib.application.window.onClose.removeAll(); // goes back to normal hopefully
			Lib.application.window.onClose.add(function() {
				DiscordClient.shutdown();
			});

			WeekData.loadTheFirstEnabledMod();
			if (PlayState.SONG.song == "Birthday")
			{
				FlxG.sound.music.stop();
				FlxG.sound.play(Paths.music(endSoundName));
				camLerpBullshit = arrowLerp = quitLerp = tryLerp = 0;
				stupidAssCam.fade(FlxColor.BLACK, 1.4, false, function()
				{
					MusicBeatState.switchState(new ManIHateYouSoMuchYouMadeMuckneySad());
				});
			}
			else
			{
				if (PlayState.isStoryMode)
				{
						if (!boyfriend.visible)
						{
							FlxG.sound.music.stop();
							FlxG.sound.play(Paths.music(endSoundName));
							camLerpBullshit = arrowLerp = quitLerp = tryLerp = 0;
							stupidAssCam.fade(FlxColor.BLACK, 1.4, false, function()
							{
								MusicBeatState.switchState(new StoryMenu());
								FlxG.sound.playMusic(Paths.music('aviOST/rottenPetals'));
							});
						}
						else
						{
							MusicBeatState.switchState(new StoryMenu());
							FlxG.sound.playMusic(Paths.music('aviOST/rottenPetals'));
						}
				}
				else
				{
						if (!boyfriend.visible)
						{
							FlxG.sound.music.stop();
							FlxG.sound.play(Paths.music(endSoundName));
							camLerpBullshit = arrowLerp = quitLerp = tryLerp = 0;
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
			default: FlxG.sound.playMusic(Paths.music("aviOST/gameOver/amIReal"), volume);
		}
		FlxG.sound.music.fadeIn(2, 0, 1);
		if (!boyfriend.visible)
			camLerpBullshit = 1;
		if ((uiRetry != null || uiLeave != null) && !boyfriend.visible)
		{
			camLerpBullshit = 0;
			arrowLerp = 1;
			tryLerp = 1;
			if (PlayState.SONG.song == "Birthday")
				quitLerp = 0.18;
			else if (PlayState.SONG.song == "Malfunction")
				quitLerp = 0.5;
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
				camLerpBullshit = arrowLerp = quitLerp = tryLerp = 0;
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
					
					if (PlayState.deathCounter == 3)
						MusicBeatState.switchState(new BotplayScreen());
					else
						MusicBeatState.resetState();
				});
			});
			PlayState.instance.callOnLuas('onGameOverConfirm', [true]);
		}
	}
}

class ManiaLoseSubstate extends MusicBeatSubstate
{
	public static var instance:ManiaLoseSubstate;
	var retryBtn:FlxSprite;
	var quitBtn:FlxSprite;
	var canUseCtrls:Bool = false;

	var stupidLerps:Array<Float> = [1, .35];

	override function create()
		{
			instance = this;
			PlayState.instance.callOnLuas('onGameOverStart', []);
	
			super.create();
		}
	
	public function new(x:Float, y:Float, camX:Float, camY:Float)
	{
		super();

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

		var resultsTxt = new FlxText(65, 70, 850, "Level Failed\nSicks: " + PlayState.instance.sicks + "                  Goods: " + PlayState.instance.goods + "\nBads: " + PlayState.instance.bads + "                  Shits: " + PlayState.instance.shits + "\nMisses: " + PlayState.instance.songMisses + "                  Hits: " + PlayState.instance.songHits + "\n\nScore: " + PlayState.instance.songScore + "\n\nAccuracy: " + Highscore.floorDecimal(PlayState.instance.ratingPercent * 100, 2) + "%", 0);
		resultsTxt.setFormat(Paths.font("resultsFont.ttf"), 40, FlxColor.WHITE, CENTER);
		resultsTxt.alpha = 0.001;
		add(resultsTxt);

		var songLength:Float = PlayState.instance.inst.length;
		var curTime:Float = Conductor.songPosition - ClientPrefs.noteOffset;
		if(curTime < 0) curTime = 0;

		var songName = new FlxText(890, 60, 450, PlayState.SONG.song + "\n\n\n\n\n\n\n\n\n\n\n" + FlxStringUtil.formatTime(Math.floor(curTime / 1000), false) + "/" + FlxStringUtil.formatTime(Math.floor(songLength / 1000)), 0);
		songName.setFormat(Paths.font("resultsFont.ttf"), 22, FlxColor.WHITE, CENTER);
		songName.alpha = 0.001;
		add(songName);

		var album = new FlxSprite(0, -190).loadGraphic(Paths.imageAlbum("volume2Album"));
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

		new FlxTimer().start(5, function(tmr:FlxTimer){
			FlxG.sound.music.stop();
			FlxG.sound.music.volume = 0;
			PlayState.instance.inst.stop();
			FlxG.sound.playMusic(Paths.music('aviOST/gameOver/mistfulWind'));
			FlxG.sound.music.fadeIn(2, 0, 1);
			canUseCtrls = true;
		});

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

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
				if (stupidLerps[0] == 1)
				{
					PlayState.camOther.fade(FlxColor.BLACK, 2, false, function()
					{
						MusicBeatState.resetState();
					});
				}
				else
				{
					PlayState.camOther.fade(FlxColor.BLACK, 2, false, function()
					{
						MusicBeatState.switchState(new FreeplayState());
						FlxG.sound.playMusic(Paths.music('aviOST/seekingFreedom'));
					});
				}
			}
		}
	}
}