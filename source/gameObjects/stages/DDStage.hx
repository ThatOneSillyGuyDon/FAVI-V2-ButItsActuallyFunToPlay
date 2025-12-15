package gameObjects.stages;

#if !flash 
import openfl.filters.ShaderFilter;
#end

class DDStage extends BaseStage
{
	//Stage vars
	var gradient:FlxSprite;
	var bg:FlxSprite;
	var whiteBG:FlxSprite;
	var overlay:FlxSprite;
	var lightingSound:FlxSound;

	public static var devilishGaming:VideoSprite;
	public static var episodeIntro:VideoSprite;

	var skipSceneTxt:FlxText;
    var skipDial:FlxPieDial;
    var skipLerp:Float = 0.0;
    var skipTmr:FlxTimer;

	 // Hardcoded Devilish Deal Icon Frames
	 public static var minnieIcon:HealthIcon;
	 public static var satanIcon:HealthIcon;
	 public static var satanIconPulse:HealthIcon;
	 public var iconPulseTween:FlxTween;
	 public var satanTween:FlxTween;

	 public static var redVignette:FlxRuntimeShader = new FlxRuntimeShader(Shaders.redFromAngryBirds, null, 120);
	 public static var dramaticCamMovement:FlxRuntimeShader = new FlxRuntimeShader(Shaders.cameraMovement, null, 150);
	 public static var chromNormalShader:FlxRuntimeShader = new FlxRuntimeShader(Shaders.aberrationDefault, null, 150);
	 public static var monitorFilter:FlxRuntimeShader = new FlxRuntimeShader(Shaders.monitorFilter, null, 140);
	 public static var chromZoomShader:FlxRuntimeShader = new FlxRuntimeShader(Shaders.aberration, null, 150);

	 public var shaderAnim:Float = 0;

	override function create()
	{	
		PlayState.isGreyscale = true;

		bg = new FlxSprite(-600, 130).loadGraphic(Paths.image(PlayState.pathway + "sky"));
		bg.scale.set(0.84, 0.84);
		bg.scrollFactor.set(0.8, 0.8);
		add(bg);

		whiteBG = new FlxSprite().makeGraphic(1, 1, 0xFFFFFFFF);
		whiteBG.scale.set(FlxG.width*5, FlxG.height*5);
		whiteBG.scrollFactor.set(0, 0);
		whiteBG.screenCenter();
		whiteBG.alpha = 0.001;
		whiteBG.active = false;
		add(whiteBG);

		var buildings:FlxSprite = new FlxSprite(-600, 130).loadGraphic(Paths.image(PlayState.pathway + "back-buildings"));
		buildings.scale.set(0.84, 0.84);
		buildings.scrollFactor.set(0.9, 0.9);
		add(buildings);

		var alley:FlxSprite = new FlxSprite(-600, 130).loadGraphic(Paths.image(PlayState.pathway + "alley_and_bench"));
		alley.scale.set(0.84, 0.84);
		add(alley);
		
		gradient = new FlxSprite().loadGraphic(Paths.image('favi/filters/gradient'));
		gradient.cameras = [game.camOther];
		gradient.screenCenter();
		gradient.scale.set(0.5, 0.5);
		gradient.alpha = 0;
		add(gradient);

		setStartCallback(devilIntro);

		lightingSound = new FlxSound();
		FlxG.sound.list.add(lightingSound);
	}

	override function createPost()
	{
		var rain:FlxSprite = new FlxSprite(-600, 130);
		rain.frames = Paths.getSparrowAtlas(PlayState.pathway + "Rain");
		rain.animation.addByPrefix("crying bitch", "rain but the side", 30, true);
		rain.scale.set(2.1, 2.1);
		rain.scrollFactor.set(1.1, 1.1);
		rain.animation.play("crying bitch");
		rain.alpha = 0.5;
		add(rain);

		var fgWall:FlxSprite = new FlxSprite(-600, 290).loadGraphic(Paths.image(PlayState.pathway + "big-ass-wall"));
		fgWall.scale.set(0.84, 0.84);
		fgWall.scrollFactor.set(1.18, 1.18);
		add(fgWall);

		game.dad.setColorTransform(-1, -1, -1, 1, 0, 0, 0, 0);
		camGame.alpha = 0.001;
		camHUD.alpha = 0.001;

		//Icon bullshit
		minnieIcon = new HealthIcon('minnie', false, false, false, true);
		minnieIcon.y = FlxG.height * (!ClientPrefs.data.downScroll ? 0.89 : 0.11) - 75;
		minnieIcon.animation.curAnim.curFrame = 2;
		minnieIcon.visible = false;
		
		satanIcon = new HealthIcon('satanddNEW', true, false, true, false);
		satanIcon.y = FlxG.height * (!ClientPrefs.data.downScroll ? 0.89 : 0.11) - 90;
		satanIcon.animation.curAnim.curFrame = 0;
		satanIcon.visible = false;
	
		satanIconPulse = new HealthIcon('satan', true, false, true, true);
		satanIconPulse.y = FlxG.height * (!ClientPrefs.data.downScroll ? 0.89 : 0.11) - 90;
		satanIconPulse.animation.curAnim.curFrame = 1;
		satanIconPulse.visible = false;

		minnieIcon.visible = true;
		satanIcon.visible = true;

		//shit for shaders
		if (ClientPrefs.data.shaders)
		{
			redVignette.setFloat('time', 0.0);
			if (!ClientPrefs.data.lowQuality)
			{
				game.camGame.setFilters([
					new ShaderFilter(dramaticCamMovement),
					new ShaderFilter(monitorFilter),
					new ShaderFilter(chromZoomShader),
					new ShaderFilter(chromNormalShader)
				]);
				game.camHUD.setFilters([new ShaderFilter(chromNormalShader)]);
			}
			else
			{
				game.camGame.setFilters([
					new ShaderFilter(monitorFilter),
					new ShaderFilter(chromNormalShader)
				]);
				game.camHUD.setFilters([new ShaderFilter(chromNormalShader)]);
			}
		}

	}

	function devilIntro()
	{
		if (isStoryMode && !seenCutscene)
		{
			camGame.visible = false;
			episodeIntro = new VideoSprite(false);
			episodeIntro.load(Paths.video('episodeStart'));
			episodeIntro.cameras = [game.camVideo];
			episodeIntro.play();
			game.camVideo.visible = true;
			add(episodeIntro);
			episodeIntro.addCallback("onStart", () -> {
				game.camVideo.visible = true;
				episodeIntro.visible = true;
			});
			episodeIntro.addCallback("onEnd", () -> {
				camHUD.alpha = 0.001;
				game.camBars.fade(FlxColor.BLACK, 0.001);
				if (PlayState.SONG.song == "Devilish Deal" && isStoryMode && GameData.episode1FPLock != "unlocked")
				{
					PlayState.windowName = "Funkin.avi - " + 
					(isStoryMode ? "Episode 1" + " - " : "Freeplay - ") + 
					(PlayState.SONG.song == "Dont Cross" ? "Don't Cross!" : PlayState.SONG.song) + 
					" (Composed by: " + FreeplayState.getArtistName() + 
					") - Chart by: " + Song.getCharterCredits() + 
					" [" + FreeplayState.getDiffRank() + "]"; // shitty long ass name that credits literally every fucking thing
					lime.app.Application.current.window.title = PlayState.windowName;

					PlayState.windowTimer = new FlxTimer().start(5, function(tmr:FlxTimer)
					{
						PlayState.windowName = "Funkin.avi - " + 
						(isStoryMode ? "Episode 1" + " - " : "Freeplay - ") + 
						(PlayState.SONG.song == "Dont Cross" ? "Don't Cross!" : PlayState.SONG.song) + 
						" [" + FreeplayState.getDiffRank() + "]"; // short version that displays after 5 seconds yayaya
			
						lime.app.Application.current.window.title = PlayState.windowName;
					});
				}
				startCountdown();
				devilishGaming = new VideoSprite(false);
				devilishGaming.load(Paths.video("devilishIntro"), [VideoSprite.muted]);
				add(devilishGaming);
				devilishGaming.cameras = [game.camVideo];
				devilishGaming.visible = false;
				game.camVideo.visible = true;
				camGame.visible = true;
				new FlxTimer().start(0.001, function(tmr:FlxTimer)
				{
					devilishGaming.pause();
					devilishGaming.setVideoTime(0);
				});
				trace("video gone");
				remove(episodeIntro);
				episodeIntro.kill();
				episodeIntro = null;
			});
		}
		else
		{
			startCountdown();
			devilishGaming = new VideoSprite(false);
			devilishGaming.load(Paths.video("devilishIntro"), [VideoSprite.muted]);
			add(devilishGaming);
			devilishGaming.cameras = [game.camVideo];
			devilishGaming.play();
			devilishGaming.visible = false;
			game.camVideo.visible = true;
			new FlxTimer().start(0.001, function(tmr:FlxTimer)
			{
				devilishGaming.pause();
				devilishGaming.setVideoTime(0);
			});
		}

		skipSceneTxt = new FlxText(0, 25, 1280, "Spam SPACE to skip this cutscene.");
		skipSceneTxt.setFormat(Paths.font("MagicOwlFont.otf"), 32, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		skipSceneTxt.alpha = 0.0001;
		skipSceneTxt.cameras = [game.camVideo];
		if (isStoryMode && !seenCutscene)
			add(skipSceneTxt);

		skipDial = new FlxPieDial(0, 0, 45, FlxColor.WHITE, 10, CIRCLE, true, 30);
		skipDial.screenCenter();
		skipDial.amount = 0.0;
		skipDial.alpha = 0.0001;
		skipDial.cameras = [game.camVideo];
		if (isStoryMode && !seenCutscene)
			add(skipDial);
	}

	override function beatHit()
	{
		// me when zoom gets higher or whatever -jason
		if(curBeat >= 64 && curBeat < 95)
		{
			FlxTween.tween(gradient, {alpha: 0.3}, 2);
		}

		if(curBeat >= 96 && curBeat < 111)
		{
			FlxTween.tween(gradient, {alpha: 0.6}, 2);
		}
		if (curBeat >= 64 && curBeat <= 79)
		{
			if (iconPulseTween != null)
				iconPulseTween.cancel();
			if (satanTween != null)
				satanTween.cancel();

			satanIconPulse.alpha = 0.25;
			satanIcon.alpha = 0.75;

			iconPulseTween = FlxTween.tween(satanIconPulse, {alpha: 0}, 0.65, {onComplete: function(twn:FlxTween)
				{
					iconPulseTween = null;
				}
			});

			satanTween = FlxTween.tween(satanIcon, {alpha: 1}, 0.65, {onComplete: function(twn:FlxTween)
				{
					satanTween = null;
				}
			});
		}
		if (curBeat >= 80 && curBeat <= 95)
		{
			if (iconPulseTween != null)
				iconPulseTween.cancel();
			if (satanTween != null)
				satanTween.cancel();

			satanIconPulse.alpha = 0.35;
			satanIcon.alpha = 0.65;

			iconPulseTween = FlxTween.tween(satanIconPulse, {alpha: 0}, 0.65, {onComplete: function(twn:FlxTween)
				{
					iconPulseTween = null;
				}
			});

			satanTween = FlxTween.tween(satanIcon, {alpha: 1}, 0.65, {onComplete: function(twn:FlxTween)
				{
					satanTween = null;
				}
			});
		}
		if (curBeat >= 96 && curBeat <= 111)
		{
			if (iconPulseTween != null)
				iconPulseTween.cancel();
			if (satanTween != null)
				satanTween.cancel();

			satanIconPulse.alpha = 0.5;
			satanIcon.alpha = 0.5;

			iconPulseTween = FlxTween.tween(satanIconPulse, {alpha: 0}, 0.65, {onComplete: function(twn:FlxTween)
				{
					iconPulseTween = null;
				}
			});

			satanTween = FlxTween.tween(satanIcon, {alpha: 1}, 0.65, {onComplete: function(twn:FlxTween)
				{
					satanTween = null;
				}
			});
		}
		if (curBeat >= 112 && curBeat <= 130)
		{
			if (iconPulseTween != null)
				iconPulseTween.cancel();
			if (satanTween != null)
				satanTween.cancel();

			satanIconPulse.alpha = 0.75;
			satanIcon.alpha = 0.25;

			iconPulseTween = FlxTween.tween(satanIconPulse, {alpha: 0}, 0.65, {onComplete: function(twn:FlxTween)
				{
					iconPulseTween = null;
				}
			});

			satanTween = FlxTween.tween(satanIcon, {alpha: 1}, 0.65, {onComplete: function(twn:FlxTween)
				{
					satanTween = null;
				}
			});
		}

		//Cool thunderstorm thing cuz it rains like crazy in Devilish Deal
		if (!ClientPrefs.data.lowQuality && curBeat >= 32 && curBeat <= 128)
		{
			if (FlxG.random.bool(5))
			{
				lightingSound.loadEmbedded(Paths.soundRandom('lightning/Lightning', 1, 3));
				lightingSound.volume = 0.25;
				lightingSound.play();
				whiteBG.alpha = 0.75;
				FlxTween.tween(whiteBG, {alpha: 0.0001}, FlxG.random.float(1, 3), {ease: FlxEase.circOut});
			}
		}
		
		minnieIcon.scale.set(1.2, 1.2);
		minnieIcon.updateHitbox();

		satanIconPulse.scale.set(1.35, 1.35);
		satanIconPulse.updateHitbox();
	}

	// For events
	override function eventCalled(eventName:String, value1:String, value2:String, flValue1:Null<Float>, flValue2:Null<Float>, strumTime:Float)
	{
		switch(eventName)
		{
			case 'Change Screen Dimming':
				var triggerInfo:Array<String> = value1.split(',');
				FlxTween.tween(gradient, {alpha: Std.parseFloat(triggerInfo[0])}, Std.parseFloat(triggerInfo[1]));
			case 'Devilish Events':
				var eventData:Float = Std.parseFloat(value1);
				switch (eventData)
				{
					case 1:
						devilishGaming.play();
						devilishGaming.visible = true;
						minnieIcon.visible = true;
						satanIcon.visible = true;
						game.iconP1.visible = false;
						game.iconP2.visible = false;
						game.uiGroup.add(minnieIcon);
						game.uiGroup.add(satanIcon);
						game.uiGroup.add(satanIconPulse);
					case 2:
						FlxTween.tween(game.dad.colorTransform, {redMultiplier: 1, blueMultiplier: 1, greenMultiplier: 1}, 2, {ease: FlxEase.circInOut});
				}
			case 'Icon Handler':
				var eventData:Float = Std.parseFloat(value1);
				switch (eventData)
				{
					case 1: satanIcon.changeIcon('satandd2NEW', false, true, false);
					case 2: minnieIcon.animation.curAnim.curFrame = 1;
					case 3:
						satanIconPulse.visible = true;
						satanIconPulse.alpha = 0.001;
					case 4: minnieIcon.animation.curAnim.curFrame = 2;
					case 5: minnieIcon.animation.curAnim.curFrame = 0;
					case 6:
						game.healthBar.visible = false;
						minnieIcon.visible = false;
						satanIcon.visible = false;
						game.noteGroup.visible = false;
						game.fancyBarOverlay.visible = false;
						game.scoreTxt.visible = false;
						game.watermarkTxt.visible = false;
						game.songTxt.visible = false;
					case 7:
						FlxTween.tween(game.dad.colorTransform, {redMultiplier: 1, blueMultiplier: 1, greenMultiplier: 1}, 2, {ease: FlxEase.circInOut});
				}
			case 'Tween Chromatic Abberation':
				var triggerInfo:Array<String> = value2.split(',');
				if (ClientPrefs.data.shaders)
				{
					switch (value1.toLowerCase())
					{
						case 'tween':
							if (game.chromTween != null)
								game.chromTween.cancel();

							game.chromEffect = Std.parseFloat(triggerInfo[0]);

							game.chromTween = FlxTween.tween(game, {
								chromEffect: 0.0001
							}, Std.parseFloat(triggerInfo[1]), {
								ease: FlxEase.sineOut,
								onComplete: function(twn:FlxTween)
								{
									game.chromTween = null;
								}
							});
						case 'zoom':
							if (game.chromTween != null)
								game.chromTween.cancel();

							game.chromTween = FlxTween.tween(game, {
								chromEffect: Std.parseFloat(triggerInfo[0])
							}, Std.parseFloat(triggerInfo[1]), {
								ease: FlxEase.sineOut,
								onComplete: function(twn:FlxTween)
								{
									game.chromTween = null;
								}
							});
						case 'set':
							game.chromEffect = Std.parseFloat(triggerInfo[0]);
					}
				}
		}
	}

	// Substates for pausing/resuming tweens and timers
	override function closeSubState()
	{
		if(paused)
		{
			if (devilishGaming != null && devilishGaming.visible)
				devilishGaming.resume();
			if (episodeIntro != null && episodeIntro.visible)
				episodeIntro.resume();
		}
	}

	override function openSubState(SubState:flixel.FlxSubState)
	{
		if(paused)
		{
			if (devilishGaming != null && devilishGaming.visible)
				devilishGaming.pause();
			if (episodeIntro != null && episodeIntro.visible)
				episodeIntro.pause();
		}
	}

	override function update(elapsed:Float)
	{
		shaderAnim = Conductor.songPosition / 1000;

		game.boyfriend.setPosition(770, 450);
		game.dad.setPosition(1660, 120);
		game.gf.visible = false;
		
		var mult:Float = FlxMath.lerp(1, minnieIcon.scale.x, CoolUtil.boundTo(1 - (elapsed * 9 * game.playbackRate), 0, 1));
		minnieIcon.scale.set(mult, mult);
		minnieIcon.updateHitbox();

		var mult:Float = FlxMath.lerp(1, satanIconPulse.scale.x, CoolUtil.boundTo(1 - (elapsed * 9 * game.playbackRate), 0, 1));
		satanIconPulse.scale.set(mult, mult);
		satanIconPulse.updateHitbox();

		super.update(elapsed);

		if (ClientPrefs.data.shaders)
		{
			chromZoomShader.setFloat('aberration', game.chromEffect);
			chromZoomShader.setFloat('effectTime', game.chromEffect);
			chromNormalShader.setFloat('rOffset', game.chromEffect / 70);
			chromNormalShader.setFloat('bOffset', -game.chromEffect / 70);
			dramaticCamMovement.setFloat('time', shaderAnim);
		}

		//Cutscene stuff
		if (FlxG.keys.justPressed.ANY)
		{
			if (skipTmr != null)
				skipTmr.cancel();

			skipTmr = new FlxTimer().start(2.5, function(tmr) {
				skipLerp = 0.0;
				skipDial.amount = 0;
			});
			skipLerp = 1.0;
		}

		if (FlxG.keys.justPressed.SPACE)
		{
			skipDial.amount += 0.1;
		}

		if (skipDial.amount >= 1)
		{
			if (episodeIntro != null)
			{
				episodeIntro.pause();
				episodeIntro.visible = false;
				if (PlayState.SONG.song == "Devilish Deal" && isStoryMode && GameData.episode1FPLock != "unlocked")
				{
					PlayState.windowName = "Funkin.avi - " + 
					(isStoryMode ? "Episode 1" + " - " : "Freeplay - ") + 
					(PlayState.SONG.song == "Dont Cross" ? "Don't Cross!" : PlayState.SONG.song) + 
					" (Composed by: " + FreeplayState.getArtistName() + 
					") - Chart by: " + Song.getCharterCredits() + 
					" [" + FreeplayState.getDiffRank() + "]"; // shitty long ass name that credits literally every fucking thing
					lime.app.Application.current.window.title = PlayState.windowName;

					PlayState.windowTimer = new FlxTimer().start(5, function(tmr:FlxTimer)
					{
						PlayState.windowName = "Funkin.avi - " + 
						(isStoryMode ? "Episode 1" + " - " : "Freeplay - ") + 
						(PlayState.SONG.song == "Dont Cross" ? "Don't Cross!" : PlayState.SONG.song) + 
						" [" + FreeplayState.getDiffRank() + "]"; // short version that displays after 5 seconds yayaya
			
						lime.app.Application.current.window.title = PlayState.windowName;
					});
				}
				devilishGaming = new VideoSprite(false);
				devilishGaming.load(Paths.video("devilishIntro"), [VideoSprite.muted]);
				add(devilishGaming);
				devilishGaming.cameras = [game.camVideo];
				devilishGaming.visible = false;
				game.camVideo.visible = true;
				camGame.visible = true;
				new FlxTimer().start(0.001, function(tmr:FlxTimer)
				{
					devilishGaming.pause();
					devilishGaming.setVideoTime(0);
				});
				startCountdown();
				trace("video gone");
				remove(episodeIntro);
				episodeIntro.kill();
				episodeIntro = null;
			}
			skipDial.visible = false;
			skipSceneTxt.visible = false;
			startCountdown();
		}
	
		if (skipSceneTxt != null)
			for (skipper in [skipSceneTxt, skipDial])
				skipper.alpha = FlxMath.lerp(skipLerp, skipper.alpha, CoolUtil.boundTo(1 - (elapsed * 9), 0, 1));
	}

	override public function onFocus():Void 
	{
		if (FlxG.autoPause)
		{
			if (devilishGaming != null && devilishGaming.visible)
				devilishGaming.resume();
			if (episodeIntro != null && episodeIntro.visible)
				episodeIntro.resume();
		}
	}

	override public function onFocusLost():Void 
	{
		if (FlxG.autoPause)
		{
			if (devilishGaming != null && devilishGaming.visible)
				devilishGaming.pause();
			if (episodeIntro != null && episodeIntro.visible)
				episodeIntro.pause();
		}
	}
}