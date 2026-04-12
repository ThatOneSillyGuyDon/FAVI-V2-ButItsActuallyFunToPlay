package gameObjects.stages;

#if !flash 
import openfl.filters.ShaderFilter;
#end

class AbandonedStreet extends BaseStage
{
	//AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
	var lununuIntro:VideoSprite;
	var isolatedIntro:VideoSprite;

	var skipSceneTxt:FlxText;
    var skipDial:FlxPieDial;
    var skipLerp:Float = 0.0;
    var skipTmr:FlxTimer;

	//MICKEY STAGE ASSETS
	public static var colorsOrSmthElse:FlxSprite;
	public static var floor:FlxSprite;
	public static var stageCurtains:FlxSprite;
	public static var stageFront:FlxSprite;
	public static var atmosphereParticle:FlxEmitter;
	public static var ashParticle:FlxEmitter;
	public static var rain:FlxSprite;
	public static var tumbleWeed:FlxSprite;
	public static var tumbleGrp:FlxTypedGroup<FlxSprite>;
	public static var fireThing:FlxSprite;
	public static var fireTweenHandler:FlxTween;
	public static var rainTween:FlxTween;

	//Shader stuff
	public static var chromZoomShader:FlxRuntimeShader = new FlxRuntimeShader(Shaders.aberration, null, 150);
	public static var chromNormalShader:FlxRuntimeShader = new FlxRuntimeShader(Shaders.aberrationDefault, null, 150);
	public static var dramaticCamMovement:FlxRuntimeShader = new FlxRuntimeShader(Shaders.cameraMovement, null, 150);
	public static var monitorFilter:FlxRuntimeShader = new FlxRuntimeShader(Shaders.monitorFilter, null, 140);

	public var shaderAnim:Float = 0;

	//Icon shits
	public static var demonBFIcon:HealthIcon;
	public static var lunacyIcon:HealthIcon;
	public static var delusionalIcon:HealthIcon;
	public static var isolatedHappy:HealthIcon;
	public static var fakeBFLosingFrame:HealthIcon;
	public static var demonBFScary:HealthIcon;

	public static var pathWay:String;

	override function create()
	{
		pathWay = "abandonedStreet";

		game.defaultCamZoom = 0.87;
		game.cameraSpeed = 1;
		PlayState.isGreyscale = true;
		
		colorsOrSmthElse = new FlxSprite(-990, 1600).loadGraphic(Paths.image(PlayState.pathway + 'randomColors'));
		colorsOrSmthElse.setGraphicSize(Std.int(colorsOrSmthElse.width * 4));
		colorsOrSmthElse.updateHitbox();
		colorsOrSmthElse.antialiasing = ClientPrefs.data.antialiasing;
		colorsOrSmthElse.screenCenter();
		colorsOrSmthElse.scale.set(3, 3);
		colorsOrSmthElse.scrollFactor.set(0.9, 0.9);
		colorsOrSmthElse.active = false;
		add(colorsOrSmthElse);

		if (!ClientPrefs.data.lowQuality && PlayState.SONG.song != "Isolated")
		{
			fireThing = new FlxSprite(0, -80);
			fireThing.scale.set(5.85, 3);
			fireThing.alpha = 0.0001;
			fireThing.antialiasing = ClientPrefs.data.antialiasing;
			fireThing.frames = Paths.getSparrowAtlas(PlayState.pathway + 'delusional-fire');
			fireThing.animation.addByPrefix('burning', 'delusional-fire fire-idle', 16, true);
			fireThing.scrollFactor.set(0.8, 0.8);
			add(fireThing);
			fireThing.animation.play('burning');
		}

		floor = new FlxSprite(-20, 200).loadGraphic(Paths.image(PlayState.pathway + 'street'));
		floor.antialiasing = ClientPrefs.data.antialiasing;
		floor.scale.set(2.8, 2.5);
		floor.scrollFactor.set(1, 1);
		floor.active = false;
		add(floor);	
		
		tumbleGrp = new FlxTypedGroup();

		if(!ClientPrefs.data.lowQuality)
		{
			stageCurtains = new FlxSprite(0, 0).loadGraphic(Paths.image(PlayState.pathway + 'i_forgor'));
			stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
			stageCurtains.updateHitbox();
			stageCurtains.screenCenter();
			stageCurtains.scale.set(1.3,1.3);
			stageCurtains.antialiasing = ClientPrefs.data.antialiasing;
			stageCurtains.cameras = [camOther];
			stageCurtains.scrollFactor.set(1.3, 1.3);
			add(stageCurtains);	

			atmosphereParticle = new FlxEmitter(-2080.5, 2000);
			atmosphereParticle.launchMode = SQUARE;
			atmosphereParticle.velocity.set(-50, -200, 50, -600, -90, 0, 90, -600);
			atmosphereParticle.scale.set(4, 4, 4, 4, 0, 0, 0, 0);
			atmosphereParticle.drag.set(0, 0, 0, 0, 5, 5, 10, 10);
			atmosphereParticle.width = 4787.45;
			atmosphereParticle.alpha.set(1, 0.3);
			atmosphereParticle.lifespan.set(1.9, 4.9);
			atmosphereParticle.loadParticles(Paths.image(PlayState.pathway + 'dustParticle'), 500, 16, true);
			atmosphereParticle.start(false, FlxG.random.float(.0521, .1060), 1000000);

			ashParticle = new FlxEmitter(-2080.5, 2150.4);
			for (i in 0 ... 100)
				{
					var blackParticle = new FlxParticle();
					blackParticle.frames = Paths.getSparrowAtlas(PlayState.pathway + 'ashParticle');
					blackParticle.animation.addByPrefix('idle', 'ashParticle idle', 5, true);
					blackParticle.animation.play('idle');
					blackParticle.antialiasing = ClientPrefs.data.antialiasing;
					blackParticle.exists = false;
					ashParticle.add(blackParticle);
				}
			ashParticle.launchMode = SQUARE;
			ashParticle.velocity.set(-50, -200, 50, -600, -90, 0, 90, -600);
			ashParticle.scale.set(4, 4, 4, 4, 0, 0, 0, 0);
			ashParticle.drag.set(0, 0, 0, 0, 5, 5, 10, 10);
			ashParticle.width = 4787.45;
			ashParticle.alpha.set(1, 1);
			ashParticle.lifespan.set(1.9, 4.9);
			ashParticle.start(false, FlxG.random.float(.0521, .1060), 1000000);
			ashParticle.angle.set(290, 0);
			ashParticle.launchAngle.set(0, 280);

			stageFront = new FlxSprite(-3000, 130).loadGraphic(Paths.image(PlayState.pathway + 'cables'));
			stageFront.scale.set(9, 2.1);
			stageFront.updateHitbox();
			stageFront.antialiasing = ClientPrefs.data.antialiasing;
			stageFront.scrollFactor.set(2.3, 1.7);
			stageFront.active = false;

			if (PlayState.SONG.song != "Isolated")
			{
				rain = new FlxSprite(-550, -900);
				rain.frames = Paths.getSparrowAtlas(PlayState.pathway + 'rain');
				rain.animation.addByPrefix('drippin', 'Rain', 30, true);
				rain.scale.set(2, 2);
				rain.antialiasing = ClientPrefs.data.antialiasing;
				rain.alpha = 0.0001;
				rain.animation.play('drippin');
			}
		}

		if (isStoryMode && !seenCutscene)
		{
			switch (PlayState.SONG.song)
			{
				case "Isolated":
					setStartCallback(isoIntro);
				case "Lunacy":
					setStartCallback(lunaIntro);
			}
		}
	}
	
	override function createPost()
	{
		if (ClientPrefs.data.shaders)
		{
			switch (PlayState.SONG.song)
			{
				case 'Isolated' | 'Lunacy':
					if (!ClientPrefs.data.lowQuality)
					{
						camGame.setFilters([
							new ShaderFilter(dramaticCamMovement),
							new ShaderFilter(monitorFilter),
							new ShaderFilter(chromZoomShader),
							new ShaderFilter(chromNormalShader)
						]);
						camHUD.setFilters([new ShaderFilter(chromNormalShader)]);
					}
					else
					{
						camGame.setFilters([
							new ShaderFilter(monitorFilter),
							new ShaderFilter(chromNormalShader)
						]);
						camHUD.setFilters([new ShaderFilter(chromNormalShader)]);
					}
			}
		}
		add(tumbleGrp);

		add(atmosphereParticle);
		add(ashParticle);
		add(stageFront);

		add(rain);

		game.gf.visible = false;

		// Hardcoded Icons
		if (PlayState.SONG.song == "Isolated")
		{
			demonBFIcon = new HealthIcon('evilcy', true, false, true, false);
		
			demonBFScary = new HealthIcon('evildelu', true, false, true, false);
			demonBFScary.animation.curAnim.curFrame = 1;
		
			fakeBFLosingFrame = new HealthIcon('evilrett', true, false, true, false);
			fakeBFLosingFrame.animation.curAnim.curFrame = 1;
		
			isolatedHappy = new HealthIcon('lunaavier', false, false, false, true);
			isolatedHappy.animation.curAnim.curFrame = 2;
			
			lunacyIcon = new HealthIcon('lunaavier', false, false, true, false);
			
			delusionalIcon = new HealthIcon('deluavier', false, false, true, false);

			for (i in [demonBFIcon, demonBFScary, fakeBFLosingFrame, isolatedHappy, lunacyIcon, delusionalIcon])
			{
				i.visible = false;
				i.cameras = [camHUD];
			}
		}
	}

	// New function but not really optimized, but it has soem function for calling videos
	private function makeVideo(videoObject:VideoSprite, name:String):VideoSprite {
		videoObject = cast Paths.getCachedVideo(name);
		if (videoObject == null) {
			videoObject = new VideoSprite(false);
			videoObject.visible = false;
			// videoObject.active = false; i dunno if that works -- mr_chaoss
			if (name == 'mickeyDeath')
				videoObject.load(Paths.video(name));
			else
				videoObject.load(Paths.video(name), [VideoSprite.muted]);
			videoObject.cameras = [game.camVideo];
			videoObject.addCallback("onEnd", () -> {
				videoObject.visible = false;
			});
			videoObject.play(); // this loads the video before pausing it immedeatly, that way the vid can actually sync with the part it needs to play at
			videoObject.pause();
			videoObject.setVideoTime(0);
			Paths.cacheVideo(name, videoObject);
		} else {
			videoObject.visible = false;
			videoObject.setVideoTime(0);
		}
		trace("Video Created, calling "+ name);
		return videoObject;
	}
	
	override function beatHit()
	{
		if (!ClientPrefs.data.lowQuality)
		{
			if (PlayState.SONG.song != "Delusional" && FlxG.random.bool(3) && tumbleWeed == null)
				summonWeedMakerLmfao();
		}

		if (PlayState.SONG.song == "Isolated")
		{
			lunacyIcon.scale.set(1.2, 1.2);
			lunacyIcon.updateHitbox();

			isolatedHappy.scale.set(1.2, 1.2);
			isolatedHappy.updateHitbox();

			demonBFIcon.scale.set(1.2, 1.2);
			demonBFIcon.updateHitbox();

			fakeBFLosingFrame.scale.set(1.2, 1.2);
			fakeBFLosingFrame.updateHitbox();
		}
	}

	override function update(elapsed:Float)
	{
		shaderAnim = Conductor.songPosition / 1000;
		
		switch (PlayState.SONG.song)
		{
			case 'Isolated' | 'Lunacy':
				if (ClientPrefs.data.shaders)
				{
					chromZoomShader.setFloat('aberration', game.chromEffect);
					chromZoomShader.setFloat('effectTime', game.chromEffect);
					chromNormalShader.setFloat('rOffset', game.chromEffect / 45);
					chromNormalShader.setFloat('bOffset', -game.chromEffect / 45);
					dramaticCamMovement.setFloat('time', shaderAnim);
				}
		}

		switch (game.dad.curCharacter)
		{
			case 'delusional-mickey':
				game.dad.setPosition(-260, 120);
			case 'mickey-delu-intro':
				game.dad.setPosition(-210, 180);
			case 'death-part-1':
				game.dad.setPosition(-450, 100);
			case 'death-part-2':
				game.dad.setPosition(-430, 100);
			case 'delumickey' | 'deluMick-eyeless':
				game.dad.setPosition(-870, -185);
			default:
				game.dad.setPosition(-870, -190);
		}
		switch (game.boyfriend.curCharacter)
		{
			case 'evildelu': game.boyfriend.setPosition(550, 190);
			case 'bf-delu-intro': game.boyfriend.setPosition(750, 350);
			case 'bf-demon': game.boyfriend.setPosition(275, 65);
			case 'Mickey-Bedroom': game.boyfriend.setPosition(575, 50);
			default: game.boyfriend.setPosition(275, 50);
		}

		if (PlayState.SONG.song == "Isolated")
		{
			var mult:Float = FlxMath.lerp(1, demonBFIcon.scale.x, CoolUtil.boundTo(1 - (elapsed * 9 * game.playbackRate), 0, 1));
			demonBFIcon.scale.set(mult, mult);
			demonBFIcon.updateHitbox();

			var mult:Float = FlxMath.lerp(1, lunacyIcon.scale.x, CoolUtil.boundTo(1 - (elapsed * 9 * game.playbackRate), 0, 1));
			lunacyIcon.scale.set(mult, mult);
			lunacyIcon.updateHitbox();

			var mult:Float = FlxMath.lerp(1, isolatedHappy.scale.x, CoolUtil.boundTo(1 - (elapsed * 9 * game.playbackRate), 0, 1));
			isolatedHappy.scale.set(mult, mult);
			isolatedHappy.updateHitbox();

			var mult:Float = FlxMath.lerp(1, fakeBFLosingFrame.scale.x, CoolUtil.boundTo(1 - (elapsed * 9 * game.playbackRate), 0, 1));
			fakeBFLosingFrame.scale.set(mult, mult);
			fakeBFLosingFrame.updateHitbox();
		}

		if (PlayState.SONG.song == "Isolated")
		{
			fakeBFLosingFrame.x = demonBFIcon.x = demonBFScary.x = game.iconP1.x;
			fakeBFLosingFrame.y = demonBFIcon.y = demonBFScary.y = game.iconP1.y;

			isolatedHappy.x = lunacyIcon.x = delusionalIcon.x = game.iconP2.x;
			isolatedHappy.y = lunacyIcon.y = delusionalIcon.y = game.iconP2.y;
		}

		if (isStoryMode && !seenCutscene && PlayState.SONG.song != "Delusional")
		{
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
				if (isolatedIntro != null)
				{
					isolatedIntro.pause();
					isolatedIntro.visible = false;
					game.camVideo.visible = false;
					camGame.visible = true;
					game.camBars.fade(FlxColor.BLACK, 0.001);
					trace("video gone");
					remove(isolatedIntro);
					isolatedIntro.kill();
					isolatedIntro = null;
				}
				if (lununuIntro != null)
				{
					lununuIntro.pause();
					lununuIntro.visible = false;
					game.camVideo.visible = false;
					game.camBars.visible = true;
					camGame.visible = true;
					game.camBars.fade(FlxColor.BLACK, 0.0001);
					trace("video gone");
					remove(lununuIntro);
					lununuIntro.kill();
					lununuIntro = null;
				}
				skipDial.visible = false;
				skipSceneTxt.visible = false;
				startCountdown();
			}

			if (skipSceneTxt != null)
				for (skipper in [skipSceneTxt, skipDial])
					skipper.alpha = FlxMath.lerp(skipLerp, skipper.alpha, CoolUtil.boundTo(1 - (elapsed * 9), 0, 1));
		}
	}

	// Substates for pausing/resuming tweens and timers
	override function closeSubState()
	{
		if(paused)
		{
			if (isolatedIntro != null && isolatedIntro.visible)
				isolatedIntro.resume();
			if (lununuIntro != null && lununuIntro.visible)
				lununuIntro.resume();
		}
	}

	override function openSubState(SubState:flixel.FlxSubState)
	{
		if(paused)
		{
			if (isolatedIntro != null && isolatedIntro.visible)
				isolatedIntro.pause();
			if (lununuIntro != null && lununuIntro.visible)
				lununuIntro.pause();
		}
	}

	// For events
	override function eventCalled(eventName:String, value1:String, value2:String, flValue1:Null<Float>, flValue2:Null<Float>, strumTime:Float)
	{
		switch(eventName)
		{
			case 'Icon Handler':
				var eventData:Float = Std.parseFloat(value1);
				if (PlayState.SONG.song == "Isolated")
				{
					switch (eventData)
					{
						case 1:
							game.iconP2.alpha = 0;
							isolatedHappy.visible = true;
							FlxTween.tween(isolatedHappy, {alpha: 0}, 1);
							FlxTween.tween(game.iconP2, {alpha: 1}, 0.6);
							add(isolatedHappy);
					
						case 2:
							lunacyIcon.visible = true;
							game.iconP2.alpha = 0;
							FlxTween.tween(lunacyIcon, {alpha: 0}, 1);
							FlxTween.tween(game.iconP2, {alpha: 1}, 0.6);
							add(lunacyIcon);

						case 3:
							delusionalIcon.visible = true;
							game.iconP2.alpha = 0;
							FlxTween.tween(delusionalIcon, {alpha: 0}, 1);
							FlxTween.tween(game.iconP2, {alpha: 1}, 0.6);
							add(delusionalIcon);

						case 4:
							fakeBFLosingFrame.visible = true;
							game.iconP1.alpha = 0;
							FlxTween.tween(fakeBFLosingFrame, {alpha: 0}, 1);
							FlxTween.tween(game.iconP1, {alpha: 1}, 0.6);
							add(fakeBFLosingFrame);

						case 5:
							demonBFIcon.visible = true;
							game.iconP1.alpha = 0;
							FlxTween.tween(demonBFIcon, {alpha: 0}, 1);
							FlxTween.tween(game.iconP1, {alpha: 1}, 0.6);
							add(demonBFIcon);
				
						//Made a typo and never fixed it soooo, oops?
						case 188:
							demonBFScary.visible = true;
							game.iconP1.alpha = 0;
							FlxTween.tween(demonBFScary, {alpha: 0}, 1);
							FlxTween.tween(game.iconP1, {alpha: 1}, 0.6);
							add(demonBFScary);
					}
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
			case 'Lunacy Event Thing idk':
				FlxTween.tween(game, {healthThing: 0.01}, 20);
				if (game.globalGradient != null)
					FlxTween.tween(game.globalGradient, {alpha: 0.8}, 10);
			case 'Fire Handler':
				var triggerInfo:Array<String> = value1.split(',');
				if (!ClientPrefs.data.lowQuality)
				{
					if (fireTweenHandler != null)
						fireTweenHandler.cancel();

					fireTweenHandler = FlxTween.tween(fireThing, {alpha: Std.parseFloat(triggerInfo[0]), y: Std.parseFloat(triggerInfo[1])}, Std.parseFloat(triggerInfo[2]), {ease: PlayState.returnTweenEase(value2), onComplete: function(twn:FlxTween)
						{
							fireTweenHandler = null;
						}
					});
				}

			case 'Rain Handler':
				var triggerInfo:Array<String> = value1.split(',');
				if (!ClientPrefs.data.lowQuality)
				{
					if (rainTween != null)
						rainTween.cancel();

					if (rain != null)
					{
						rainTween = FlxTween.tween(rain, {alpha: Std.parseFloat(triggerInfo[0])}, Std.parseFloat(triggerInfo[1]), {ease: PlayState.returnTweenEase(value2), onComplete: function(twn:FlxTween)
						{
							rainTween = null;
						}});
					}
				}
		}
	}

	function summonWeedMakerLmfao()
	{
		tumbleWeed = new FlxSprite(1800, 600);
		tumbleWeed.antialiasing = ClientPrefs.data.antialiasing;
		var velocityX:Float = 0;
		var bounceVal:Int = 735;
		var loopTime:Array<Float> = [];
		if (FlxG.random.bool(1))
		{
			tumbleWeed.loadGraphic(Paths.image(PlayState.pathway + 'THELEGENDARYTUMBLEWEED'));
			tumbleWeed.scale.set(0.6, 0.6);
			velocityX = -1270;
			bounceVal = 50;
			loopTime[0] = 0.5;
			loopTime[1] = 0.1;
			loopTime[2] = 4;
		}
		else
		{
			tumbleWeed.loadGraphic(Paths.image(PlayState.pathway + 'Tumble_' + FlxG.random.int(0,1)));
			velocityX = -520;
			loopTime[0] = 1.7;
			loopTime[1] = 0.75;
			loopTime[2] = 5.6;
		}
		tumbleWeed.velocity.set(velocityX, 0);
		tumbleGrp.add(tumbleWeed);
		FlxTween.tween(tumbleWeed, {angle: -360}, loopTime[0], {type: LOOPING});
		FlxTween.tween(tumbleWeed, {y: bounceVal}, loopTime[1], {ease: FlxEase.sineInOut, type: PINGPONG});
		new FlxTimer().start(loopTime[2], function(tmr:FlxTimer)
		{
			tumbleWeed.kill();
			tumbleWeed = null;
		});
	}

	function isoIntro()
	{
		camGame.visible = false;
		isolatedIntro = new VideoSprite(false);
		isolatedIntro.load(Paths.video('isolatedIntro'));
		isolatedIntro.cameras = [game.camOther];
		isolatedIntro.play();
		add(isolatedIntro);
		game.camVideo.visible = true;
		isolatedIntro.addCallback("onStart", () -> {
			game.camVideo.visible = true;
			isolatedIntro.visible = true;
		});
		isolatedIntro.addCallback("onEnd", () -> {
			trace("video gone");
			remove(isolatedIntro);
			isolatedIntro.kill();
			isolatedIntro = null;
			game.camVideo.visible = false;
			camGame.visible = true;
			game.camBars.fade(FlxColor.BLACK, 0.001);
			startCountdown();
		});

		skipSceneTxt = new FlxText(0, 25, 1280, "Spam SPACE to skip this cutscene.");
		skipSceneTxt.setFormat(Paths.font("MagicOwlFont.otf"), 32, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		skipSceneTxt.alpha = 0.0001;
		skipSceneTxt.cameras = [game.camOther];
		add(skipSceneTxt);

		skipDial = new FlxPieDial(0, 0, 45, FlxColor.WHITE, 10, CIRCLE, true, 30);
		skipDial.screenCenter();
		skipDial.amount = 0.0;
		skipDial.alpha = 0.0001;
		skipDial.cameras = [game.camOther];
		add(skipDial);
	}

	function lunaIntro()
	{
		camGame.visible = false;
		lununuIntro = new VideoSprite(false);
		lununuIntro.load(Paths.video("lunacyIntro"));
		lununuIntro.cameras = [game.camOther];
		lununuIntro.play();
		game.camVideo.visible = true;
		add(lununuIntro);
		lununuIntro.addCallback("onStart", () -> {
			game.camVideo.visible = true;
			lununuIntro.visible = true;
			game.camBars.visible = false;
		});
		lununuIntro.addCallback("onEnd", () -> {
			game.camVideo.visible = false;
			game.camBars.visible = true;
			camGame.visible = true;
			game.camBars.fade(FlxColor.BLACK, 0.0001);
			startCountdown();
			trace("video gone");
			remove(lununuIntro);
			lununuIntro.kill();
			lununuIntro = null;
		});

		skipSceneTxt = new FlxText(0, 25, 1280, "Spam SPACE to skip this cutscene.");
		skipSceneTxt.setFormat(Paths.font("MagicOwlFont.otf"), 32, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		skipSceneTxt.alpha = 0.0001;
		skipSceneTxt.cameras = [game.camOther];
		add(skipSceneTxt);

		skipDial = new FlxPieDial(0, 0, 45, FlxColor.WHITE, 10, CIRCLE, true, 30);
		skipDial.screenCenter();
		skipDial.amount = 0.0;
		skipDial.alpha = 0.0001;
		skipDial.cameras = [game.camOther];
		add(skipDial);
	}

	override function opponentNoteHit(note:Note)
	{
		switch (PlayState.SONG.song)
        {  
			case 'Isolated':
				if (dad.curCharacter == "avier-whistle" && !note.isSustainNote) whistleNotes(dadGroup);
			case 'Lunacy':
				if (ClientPrefs.data.mechanics)
				{
					if (game.healthThing > game.boundValue)
						game.healthThing -= game.drainValue;
				}
		}
	}

	public function whistleNotes(targetGroup:FlxSpriteGroup) {
		var path:String = 'favi/ui/bdaynotes';
		var particleNote:FlxSprite = new FlxSprite().loadGraphic(Paths.image('$path/note_${FlxG.random.int(1, 3)}'));
		particleNote.setGraphicSize(Std.int(particleNote.width * 0.5));
		particleNote.updateHitbox();
		particleNote.angle = FlxG.random.float(-15, 18);
		particleNote.setColorTransform(-1, -1, -1, 1, 128, 128, 128, 0);
		particleNote.x = targetGroup.x - 175;
		particleNote.y = targetGroup.y + 375;
		particleNote.alpha = 0.0001;
		particleNote.velocity.x -= targetGroup.y - 475;
		FlxTween.tween(particleNote, {alpha: 1}, .5, {ease: FlxEase.sineInOut});
		
		FlxTween.tween(particleNote, {y: particleNote.y - 70}, FlxG.random.float(0.5, 2), {ease: FlxEase.sineInOut, type: 4});

		FlxTween.tween(particleNote, {alpha: 0.0001}, 1, {ease: FlxEase.sineInOut, startDelay: 0.75,
			onComplete: function(tween:FlxTween)
			{
				particleNote.destroy();
			}
		});
		addBehindDad(particleNote);
	}
} // hehe 7/11