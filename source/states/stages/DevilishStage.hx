package states.stages;

import states.stages.objects.*;

#if !flash 
import openfl.filters.ShaderFilter;
#end

class DevilishStage extends BaseStage
{
	//Stage vars
	var gradient:FlxSprite;
	var bg:FlxSprite;
	var overlay:FlxSprite;

	var devilishGaming:VideoSprite;
	var episodeIntro:VideoSprite;

	 // Hardcoded Devilish Deal Icon Frames
	 public var minnieIcon:HealthIcon;
	 public var satanIcon:HealthIcon;
	 public var satanIconPulse:HealthIcon;
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
		bg = new FlxSprite(-600, 130).loadGraphic(Paths.image(PlayState.pathway + "sky"));
		bg.scale.set(0.84, 0.84);
		bg.scrollFactor.set(0.8, 0.8);
		add(bg);

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

		if (isStoryMode && !seenCutscene)
		{
			setStartCallback(devilIntro);
		}
		else if (!isStoryMode)
		{
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

		game.boyfriend.setPosition(770, 450);
		game.dad.setPosition(1660, 120);

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
			//finishedScene = true;
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
			//canSkip = false;
			trace("video gone");
			remove(episodeIntro);
			episodeIntro.kill();
			episodeIntro = null;
		});
	}

	override function beatHit()
	{
		// me when zoom gets higher or whatever -jason
		if(curBeat >= 64 && curBeat < 95)
		{
			FlxG.camera.zoom += 0.025;
			camHUD.zoom += 0.042;
			FlxTween.tween(gradient, {alpha: 0.3}, 2);
		}

		if(curBeat >= 96 && curBeat < 111)
		{
			FlxG.camera.zoom += 0.04;
			camHUD.zoom += 0.053;
			FlxTween.tween(gradient, {alpha: 0.6}, 2);
		}

		if(curBeat == 112)
		{
			game.isCameraOnForcedPos = true;
			FlxTween.tween(camFollow, {x: camFollow.x - 150, y: 1380}, 14, {ease: FlxEase.sineInOut});
			FlxTween.tween(FlxG.camera, {zoom: 2}, 14, {ease: FlxEase.sineInOut});
			FlxTween.tween(gradient, {alpha: 0.9}, 2);
		}

		if(curBeat >= 112) // doesn't make sense to but a "&& curBeat < idk"
		{
			// not including camGame cus it bugs out
			camHUD.zoom += 0.053;
		}

		switch (curBeat)
		{
			case 1:
				minnieIcon.visible = true;
				satanIcon.visible = true;
				game.iconP1.visible = false;
				game.iconP2.visible = false;
				game.uiGroup.add(minnieIcon);
				game.uiGroup.add(satanIcon);
				game.uiGroup.add(satanIconPulse);
			case 62: satanIcon.animation.curAnim.curFrame = 2;
			case 63: minnieIcon.animation.curAnim.curFrame = 1;
			case 64:
				satanIconPulse.visible = true;
				satanIconPulse.alpha = 0.001;
			case 96: minnieIcon.animation.curAnim.curFrame = 2;
			case 112: minnieIcon.animation.curAnim.curFrame = 0;
			case 128:
				game.healthBar.visible = false;
				minnieIcon.visible = false;
				satanIcon.visible = false;
				game.noteGroup.visible = false;
				game.fancyBarOverlay.visible = false;
				game.scoreTxt.visible = false;
				game.watermarkTxt.visible = false;
				game.songTxt.visible = false;
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
		
		switch (curBeat)
		{
			// Intro
			case 1: 
				devilishGaming.play();
				devilishGaming.visible = true;
			
			case 8: FlxTween.tween(game.camGame, {alpha: 1}, 4.5, {ease: FlxEase.sineOut});

			case 16:
				FlxTween.tween(game.camVideo, {alpha: 0}, 3, {ease: FlxEase.sineOut});
				game.defaultCamZoom = 1.3;
				game.manageLyrics('satanddNEW', 'In the rain...', 'betterSatanFont.ttf', 30, 2, 'sineInOut', 0.1);

			case 20:
				game.manageLyrics('satanddNEW', '...Looking so blue...', 'betterSatanFont.ttf', 30, 3.2, 'sineInOut', 0.08);

			case 26:
				game.manageLyrics('satanddNEW', '...SPEAK...', 'betterSatanFont.ttf', 30, 0.7, 'sineInOut', 0.05);

			case 28:
				game.defaultCamZoom = 0.55;
				game.manageLyrics('satanddNEW', '...What is on your mind?', 'betterSatanFont.ttf', 30, 2.5, 'sineInOut', 0.06);

			case 30:
				FlxTween.tween(game.camHUD, {alpha: 1}, 2, {ease: FlxEase.sineOut});

			case 32 | 34 | 36 | 38 | 40 | 42 | 44 | 46 | 48 | 50 | 52 | 54 | 56 | 58:
					if (ClientPrefs.data.shaders)
					{
						if (game.chromTween != null)
							game.chromTween.cancel();

						game.chromEffect = 0.32;

						game.chromTween = FlxTween.tween(game, {
							chromEffect: 0.0001
						}, 1.2, {
							ease: FlxEase.sineOut,
							onComplete: function(twn:FlxTween)
							{
								game.chromTween = null;
							}
						});
					}

			case 60:
				game.defaultCamZoom = 1.2;
				FlxTween.tween(game.camHUD, {alpha: 0.4}, 0.75, {ease: FlxEase.quartInOut});
				FlxTween.tween(game.dad.colorTransform, {redMultiplier: 1, blueMultiplier: 1, greenMultiplier: 1}, 2, {ease: FlxEase.circInOut});
				if (ClientPrefs.data.shaders)
				{
					if (game.chromTween != null)
						game.chromTween.cancel();

					game.chromEffect = 0.15;

					game.chromTween = FlxTween.tween(game, {
						chromEffect: 0.00001
					}, 1.2, {
						ease: FlxEase.sineOut,
						onComplete: function(twn:FlxTween)
						{
							game.chromTween = null;
						}
					});
				}

			case 62:
				if (ClientPrefs.data.shaders)
				{
					if (game.chromTween != null)
						game.chromTween.cancel();

					game.chromEffect = 0.15;

					game.chromTween = FlxTween.tween(game, {
						chromEffect: 0.00001
					}, 2, {
						ease: FlxEase.sineOut,
						onComplete: function(twn:FlxTween)
						{
							game.chromTween = null;
						}
					});
				}

			case 64:
				game.defaultCamZoom = 0.55;
				FlxTween.tween(game.camHUD, {alpha: 1}, 1.2, {ease: FlxEase.quartInOut});

			case 128:
				camGame.visible = false;
				if (ClientPrefs.data.flashing)
					camOther.flash(FlxColor.WHITE, 1);
				if (ClientPrefs.data.shaders)
				{
					if (game.chromTween != null)
						game.chromTween.cancel();

					game.chromEffect = 0.4;

					game.chromTween = FlxTween.tween(game, {
						chromEffect: 0.00001
					}, 2.3, {
						ease: FlxEase.sineOut,
						onComplete: function(twn:FlxTween)
						{
							game.chromTween = null;
						}
					});
				}
		}

		if (curBeat >= 64 && curBeat <= 95 && ClientPrefs.data.shaders)
		{
			if (game.chromTween != null)
				game.chromTween.cancel();

			game.chromEffect = 0.23;

			game.chromTween = FlxTween.tween(game, {
				chromEffect: 0.00001
			}, 1.5, {
				ease: FlxEase.sineOut,
				onComplete: function(twn:FlxTween)
				{
					game.chromTween = null;
				}
			});
		}

		if (curBeat >= 96 && curBeat <= 111 && ClientPrefs.data.shaders)
		{
			if (game.chromTween != null)
				game.chromTween.cancel();

			game.chromEffect = 0.27;

			game.chromTween = FlxTween.tween(game, {
				chromEffect: 0.0001
			}, 1.5, {
				ease: FlxEase.sineOut,
				onComplete: function(twn:FlxTween)
				{
					game.chromTween = null;
				}
			});
		}

		if (curBeat >= 112 && curBeat <= 127 && ClientPrefs.data.shaders)
		{
			if (game.chromTween != null)
				game.chromTween.cancel();

			game.chromEffect = 0.32;

			game.chromTween = FlxTween.tween(game, {
				chromEffect: 0.00001
			}, 1.5, {
				ease: FlxEase.sineOut,
				onComplete: function(twn:FlxTween)
				{
					game.chromTween = null;
				}
			});
		}

		minnieIcon.scale.set(1.2, 1.2);
		minnieIcon.updateHitbox();

		satanIconPulse.scale.set(1.35, 1.35);
		satanIconPulse.updateHitbox();
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
		
		var mult:Float = FlxMath.lerp(1, minnieIcon.scale.x, CoolUtil.boundTo(1 - (elapsed * 9 * game.playbackRate), 0, 1));
		minnieIcon.scale.set(mult, mult);
		minnieIcon.updateHitbox();

		var mult:Float = FlxMath.lerp(1, satanIconPulse.scale.x, CoolUtil.boundTo(1 - (elapsed * 9 * game.playbackRate), 0, 1));
		satanIconPulse.scale.set(mult, mult);
		satanIconPulse.updateHitbox();

		minnieIcon.x = game.healthBar.x + (game.healthBar.width * (FlxMath.remapToRange(-game.healthBar.percent, 0, 100, 100, 0) * 0.01)) - (150 * minnieIcon.scale.x) / 2 - game.iconOffset * 25;
		satanIcon.x = game.healthBar.x + (game.healthBar.width * (FlxMath.remapToRange(-game.healthBar.percent, 0, 100, 100, 0) * 0.01)) + (150 * satanIcon.scale.x - 150) / 2 - game.iconOffset * 24;
		satanIconPulse.x = game.healthBar.x + (game.healthBar.width * (FlxMath.remapToRange(-game.healthBar.percent, 0, 100, 100, 0) * 0.01)) + (150 * satanIconPulse.scale.x - 150) / 2 - game.iconOffset * 24;

		if (ClientPrefs.data.shaders)
		{
			chromZoomShader.setFloat('aberration', game.chromEffect);
			chromZoomShader.setFloat('effectTime', game.chromEffect);
			chromNormalShader.setFloat('rOffset', game.chromEffect / 70);
			chromNormalShader.setFloat('bOffset', -game.chromEffect / 70);
			dramaticCamMovement.setFloat('time', shaderAnim);
		}
	}
}