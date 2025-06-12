package states.stages;

import states.stages.objects.*;

#if !flash 
import openfl.filters.ShaderFilter;
#end

class Episode1Street extends BaseStage
{
	//AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
	var death:VideoSprite;
	var deluSing:VideoSprite;
	var lununuIntro:VideoSprite;
	var isolatedIntro:VideoSprite;
	var minnieJumpscare:VideoSprite;

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
	 public static var heavyRain:FlxSprite;
	 public static var tumbleWeed:FlxSprite;
	 public static var tumbleGrp:FlxTypedGroup<FlxSprite>;
	 public static var lightning:FlxSprite;
	 public static var lightningFore:FlxSprite;
	 public static var streetDaytime:FlxSprite;
	 public static var clouds:FlxSprite;
	 public static var brightSky:FlxSprite;
	 public static var streetRuins:FlxSprite;
	 public static var fakeLightOfHope:FlxSprite;
	 public static var fireThing:FlxSprite;
	 public static var fireThing2:FlxSprite; // what the fuck what the fuck what the fuck what the fuck what the fuck what the fuck
	 public static var fireForeground:FlxSprite;
	 public static var fireTweenHandler:FlxTween;
	 public static var rainTween:FlxTween;
	 public static var fireParticle:FlxEmitter;
	 public static var mickeySpirit:Character;
	 public static var smokeShit:FlxTypedGroup<FlxSprite>;
	 public static var smokeFore:FlxTypedGroup<FlxSprite>;
	 public static var spriteShit:Array<String> = ['smokeBBack', 'smokeTBack'];
	 public static var spriteShitForeground:Array<String> = ['smokeBFore', 'smokeTFore'];
	  
	// Mickey being delusional and minnie appearing Scene For Delusional aaaa
	public static var minnieBackground:FlxSprite; 
	public static var totallyanoriginalname:FlxSprite; // .. i have no idea what to say

	//Shader stuff
	public static var redVignette:FlxRuntimeShader = new FlxRuntimeShader(Shaders.redFromAngryBirds, null, 120);
	public static var chromZoomShader:FlxRuntimeShader = new FlxRuntimeShader(Shaders.aberration, null, 150);
	public static var chromNormalShader:FlxRuntimeShader = new FlxRuntimeShader(Shaders.aberrationDefault, null, 150);
	public static var dramaticCamMovement:FlxRuntimeShader = new FlxRuntimeShader(Shaders.cameraMovement, null, 150);
	public static var monitorFilter:FlxRuntimeShader = new FlxRuntimeShader(Shaders.monitorFilter, null, 140);
	public static var delusionalShift:FlxRuntimeShader = new FlxRuntimeShader(Shaders.delusionalShift, null, 120);
	public static var heatWaveEffect:FlxRuntimeShader = new FlxRuntimeShader(Shaders.heatWave, null, 120);
	public static var grayScale:FlxRuntimeShader = new FlxRuntimeShader(Shaders.grayScale, null, 120);

	public var shaderAnim:Float = 0;

	//Icon shits
	public static var demonBFIcon:HealthIcon;
	public static var lunacyIcon:HealthIcon;
	public static var delusionalIcon:HealthIcon;
	public static var isolatedHappy:HealthIcon;
	public static var fakeBFLosingFrame:HealthIcon;
	public static var demonBFScary:HealthIcon;

	override function create()
	{
		game.defaultCamZoom = 0.87;
		game.cameraSpeed = 1;
		
		colorsOrSmthElse = new FlxSprite(-990, 1600).loadGraphic(Paths.image(PlayState.pathway + 'randomColors'));
		colorsOrSmthElse.setGraphicSize(Std.int(colorsOrSmthElse.width * 4));
		colorsOrSmthElse.updateHitbox();
		colorsOrSmthElse.antialiasing = ClientPrefs.data.antialiasing;
		colorsOrSmthElse.screenCenter();
		colorsOrSmthElse.scale.set(3, 3);
		colorsOrSmthElse.scrollFactor.set(0.9, 0.9);
		colorsOrSmthElse.active = false;
		add(colorsOrSmthElse);

		if (!ClientPrefs.data.lowQuality)
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

		if (PlayState.SONG.song == 'Delusional' || PlayState.SONG.song == 'Delusion')
		{	
			fakeLightOfHope = new FlxSprite(-990, 1600).loadGraphic(Paths.image(PlayState.pathway + 'falseHope'));
			fakeLightOfHope.setGraphicSize(Std.int(fakeLightOfHope.width * 4));
			fakeLightOfHope.updateHitbox();
			fakeLightOfHope.antialiasing = ClientPrefs.data.antialiasing;
			fakeLightOfHope.screenCenter();
			fakeLightOfHope.scale.set(3, 3);
			fakeLightOfHope.scrollFactor.set(0.9, 0.9);
			add(fakeLightOfHope);
			
			if (!ClientPrefs.data.lowQuality)
			{
				fireThing2 = new FlxSprite(0, -80);
				fireThing2.scale.set(5.85, 3);
				fireThing2.alpha = 0.0001;
				fireThing2.frames = Paths.getSparrowAtlas(PlayState.pathway + 'delusional-fire');
				fireThing2.animation.addByPrefix('burning', 'delusional-fire fire-idle', 16, true);
				fireThing2.scrollFactor.set(0.8, 0.8);
				fireThing2.antialiasing = ClientPrefs.data.antialiasing;
				fireThing2.blend = ADD;
				add(fireThing2);
				fireThing2.animation.play('burning');

				lightning = new FlxSprite(-25, -175);
				lightning.frames = Paths.getSparrowAtlas(PlayState.pathway + "lightning");
				lightning.antialiasing = ClientPrefs.data.antialiasing;
				lightning.animation.addByPrefix('boom', 'lightning1', 12);
				lightning.animation.addByPrefix('boom2', 'lightning2', 12);
				lightning.scale.set(2, 2);
				lightning.scrollFactor.set(0.8, 0.8);
				add(lightning);
			}

			mickeySpirit = new Character(-200, -700, "avier-bg");
			mickeySpirit.alpha = 0.0001;
			add(mickeySpirit);

			streetRuins = new FlxSprite(-20, 200).loadGraphic(Paths.image(PlayState.pathway + 'streetDestroyed'));
			streetRuins.antialiasing = ClientPrefs.data.antialiasing;
			streetRuins.scale.set(2.8, 2.5);
			streetRuins.scrollFactor.set(1, 1);
			add(streetRuins);

			// Bedroom Grah :fire: - MalyPlus
			minnieBackground = new FlxSprite(-20, 200).loadGraphic(Paths.image(PlayState.pathway + 'background'));
			minnieBackground.scale.set(2,2);
			minnieBackground.scrollFactor.set(1, 1);
			minnieBackground.antialiasing = ClientPrefs.data.antialiasing;
			minnieBackground.visible = false;
			add(minnieBackground);

			totallyanoriginalname = new FlxSprite(-20, 200).loadGraphic(Paths.image(PlayState.pathway + 'shading'));
			totallyanoriginalname.scale.set(2,2);
			totallyanoriginalname.scrollFactor.set(1,1);
			totallyanoriginalname.visible = false;
			totallyanoriginalname.antialiasing = ClientPrefs.data.antialiasing;
			add(totallyanoriginalname);


			if (!ClientPrefs.data.lowQuality)
			{
				smokeShit = new FlxTypedGroup();
				add(smokeShit);

				for (i in 0...spriteShit.length)
				{
					var smoke:FlxBackdrop = new FlxBackdrop(Paths.image(PlayState.pathway + spriteShit[i]), X, 0, 0);
					smoke.ID = i;
					smoke.x = -20;
					smoke.y = 200;
					smoke.scale.set(2.8, 2.5);
					smoke.scrollFactor.set(1.2, 1.1);
					smoke.alpha = 0.001;
					smoke.antialiasing = ClientPrefs.data.antialiasing;
					switch (smoke.ID)
					{
						case 0: smoke.velocity.set(-160, 0);
						case 1: smoke.velocity.set(160, 0);
					}
					smokeShit.add(smoke);
				}
			}
		}

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

			rain = new FlxSprite(-550, -900);
			rain.frames = Paths.getSparrowAtlas(PlayState.pathway + 'rain');
			rain.animation.addByPrefix('drippin', 'Rain', 30, true);
			rain.scale.set(2, 2);
			rain.antialiasing = ClientPrefs.data.antialiasing;
			rain.alpha = 0.0001;
			rain.animation.play('drippin');

			heavyRain = new FlxSprite(-550, -900);
			heavyRain.frames = Paths.getSparrowAtlas(PlayState.pathway + 'heavyRain');
			heavyRain.animation.addByPrefix('god is pissing omg', 'Rain full', 30, true);
			heavyRain.scale.set(2, 2);
			heavyRain.antialiasing = ClientPrefs.data.antialiasing;
			heavyRain.alpha = 0.0001;
			heavyRain.animation.play('god is pissing omg');
		}

		if (isStoryMode && !seenCutscene)
		{
			switch (PlayState.SONG.song)
			{
				case "Isolated":
					setStartCallback(isoIntro);
				case "Lunacy":
					setStartCallback(lunaIntro);
				default:
					startCountdown();
			}
		}
	}
	
	override function createPost()
	{
		switch (PlayState.SONG.song)
		{
			case "Delusional":
				deluSing = new VideoSprite(false);
				deluSing.visible = false;
				deluSing.load(Paths.video("deluLyrics"), [VideoSprite.muted]);
				deluSing.cameras = [game.camVideo];
				deluSing.play();
				deluSing.pause();
				deluSing.setVideoTime(0);
				deluSing.addCallback("onEnd", () -> {
					deluSing.kill();
					deluSing.destroy();
					deluSing = null;
				});
				death = new VideoSprite(false);
				death.visible = false;
				death.load(Paths.video("mickeyDeath"));
				death.cameras = [game.camVideo];
				death.play();
				death.pause();
				death.setVideoTime(0);
				minnieJumpscare = new VideoSprite(false);
				minnieJumpscare.visible = false;
				minnieJumpscare.load(Paths.video("minniePart"), [VideoSprite.muted]);
				minnieJumpscare.cameras = [game.camVideo];
				minnieJumpscare.play();
				minnieJumpscare.pause();
				minnieJumpscare.setVideoTime(0);
				minnieJumpscare.addCallback("onEnd", () -> {
					minnieJumpscare.kill();
					minnieJumpscare.destroy();
					minnieJumpscare = null;
				});
				add(death);
				add(deluSing);
				add(minnieJumpscare);
		}
		
		if (ClientPrefs.data.shaders)
		{
			switch (PlayState.SONG.song)
			{
				case 'Isolated' | 'Lunacy' | 'Delusional' | 'Delusion':
					redVignette.setFloat('time', 0.0);
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

		if (PlayState.SONG.song == 'Delusional' || PlayState.SONG.song == 'Delusion')
		{	
			if (!ClientPrefs.data.lowQuality)
			{
				smokeFore = new FlxTypedGroup();
				add(smokeFore);

				for (i in 0...spriteShitForeground.length)
				{
					var smoke:FlxBackdrop = new FlxBackdrop(Paths.image(PlayState.pathway + spriteShitForeground[i]), X, 0, 0);
					smoke.ID = i;
					smoke.x = -20;
					smoke.y = 200;
					smoke.scale.set(2.8, 2.5);
					smoke.scrollFactor.set(1.55, 1.32);
					smoke.alpha = 0.001;
					smoke.antialiasing = ClientPrefs.data.antialiasing;
					switch (smoke.ID)
					{
						case 0: smoke.velocity.set(230, 0);
						case 1: smoke.velocity.set(-230, 0);
					}
					smokeFore.add(smoke);
				}

				lightningFore = new FlxSprite(-60, -90);
				lightningFore.frames = Paths.getSparrowAtlas(PlayState.pathway + "lightning");
				lightningFore.animation.addByPrefix('boom', 'lightning1', 12);
				lightningFore.animation.addByPrefix('boom2', 'lightning2', 12);
				lightningFore.scale.set(2.45, 2.45);
				lightningFore.scrollFactor.set(1.32, 1.32);
				lightningFore.antialiasing = ClientPrefs.data.antialiasing;
				add(lightningFore);

				fireForeground = new FlxSprite(0, 550);
				fireForeground.scale.set(7.8, 5);
				fireForeground.alpha = 0.001;
				fireForeground.frames = Paths.getSparrowAtlas(PlayState.pathway + 'delusional-fire');
				fireForeground.animation.addByPrefix('burningShit', 'delusional-fire fire-idle', 16, true);
				fireForeground.scrollFactor.set(1.35, 1.18);
				fireForeground.antialiasing = ClientPrefs.data.antialiasing;
				fireForeground.blend = ADD;
				add(fireForeground);
				fireForeground.animation.play('burningShit');
			}
			streetRuins.visible = false;
		}


		add(atmosphereParticle);
		add(ashParticle);
		add(stageFront);

		if (PlayState.SONG.song == "Delusional")
		{
			stageFront.y -= 250;
			stageFront.alpha = 0.001;
			game.camBars.fade(0x000000, .0001);
		}

		add(rain);
		add(heavyRain);

		game.gf.visible = false;

		// Hardcoded Icons
		if (PlayState.SONG.song == "Isolated")
		{
			demonBFIcon = new HealthIcon('evilcy', true, false, true, false);
			demonBFIcon.visible = false;
		
			demonBFScary = new HealthIcon('evildelu', true, false, true, false);
			demonBFScary.animation.curAnim.curFrame = 1;
			demonBFScary.visible = false;
		
			fakeBFLosingFrame = new HealthIcon('evilrett', true, false, true, false);
			fakeBFLosingFrame.animation.curAnim.curFrame = 1;
			fakeBFLosingFrame.visible = false;
		
			isolatedHappy = new HealthIcon('lunaavier', false, false, false, true);
			isolatedHappy.animation.curAnim.curFrame = 2;
			isolatedHappy.visible = false;
			
			lunacyIcon = new HealthIcon('lunaavier', false, false, true, false);
			lunacyIcon.visible = false;
			
			delusionalIcon = new HealthIcon('deluavier', false, false, true, false);
			delusionalIcon.visible = false;

			demonBFIcon.cameras = [camHUD];
			demonBFScary.cameras = [camHUD];
			fakeBFLosingFrame.cameras = [camHUD];
			isolatedHappy.cameras = [camHUD];
			lunacyIcon.cameras = [camHUD];
			delusionalIcon.cameras = [camHUD];
		}
	}
	
	override function beatHit()
	{
		if (!ClientPrefs.data.lowQuality)
		{
			if (PlayState.SONG.song == "Delusional" && FlxG.random.bool(3) && tumbleWeed == null && curBeat < 474)
				summonWeedMakerLmfao();
			else if (PlayState.SONG.song != "Delusional" && FlxG.random.bool(3) && tumbleWeed == null)
				summonWeedMakerLmfao();

			if (PlayState.SONG.song == "Delusional" && curBeat > 880 && !ClientPrefs.data.lowQuality)
			{
				if (FlxG.random.bool(45)) lightningStrike();
				if (FlxG.random.bool(36)) lightningStrikeFore();
			}
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

	override function update(elapsed:Float)
	{
		shaderAnim = Conductor.songPosition / 1000;
		
		switch (PlayState.SONG.song)
		{
			case 'Isolated' | 'Lunacy' | 'Delusional':
				chromZoomShader.setFloat('aberration', game.chromEffect);
				chromZoomShader.setFloat('effectTime', game.chromEffect);
				chromNormalShader.setFloat('rOffset', game.chromEffect / 45);
				chromNormalShader.setFloat('bOffset', -game.chromEffect / 45);
				dramaticCamMovement.setFloat('time', shaderAnim);
				if (PlayState.SONG.song == "Delusional")
				{
					delusionalShift.setFloat('iTime', shaderAnim);
					delusionalShift.setFloat('uTime', shaderAnim);
					heatWaveEffect.setFloat("iTime", shaderAnim);
				}
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
			fakeBFLosingFrame.x = game.iconP1.x;
			fakeBFLosingFrame.y = game.iconP1.y;

			demonBFIcon.x = game.iconP1.x;
			demonBFIcon.y = game.iconP1.y;

			demonBFScary.x = game.iconP1.x;
			demonBFScary.y = game.iconP1.y;

			isolatedHappy.x = game.iconP2.x;
			isolatedHappy.y = game.iconP2.y;

			lunacyIcon.x = game.iconP2.x;
			lunacyIcon.y = game.iconP2.y;

			delusionalIcon.x = game.iconP2.x;
			delusionalIcon.y = game.iconP2.y;
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

		if (isStoryMode && !seenCutscene)
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
			if (lununuIntro != null && lununuIntro.visible)
				lununuIntro.resume();
			if (minnieJumpscare != null && minnieJumpscare.visible)
				minnieJumpscare.resume();
			if (deluSing != null && deluSing.visible)
				deluSing.resume();
			if (death != null && death.visible)
				death.resume();
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
			if (minnieJumpscare != null && minnieJumpscare.visible)
				minnieJumpscare.pause();
			if (deluSing != null && deluSing.visible)
				deluSing.pause();
			if (death != null && death.visible)
				death.pause();
		}
	}

	// prob use velocity.x someday for not time enough for that
	function summonWeedMakerLmfao()
	{
		if (FlxG.random.bool(1))
		{
			tumbleWeed = new FlxSprite(1800, 490).loadGraphic(Paths.image(PlayState.pathway + 'THELEGENDARYTUMBLEWEED'));
			tumbleWeed.scale.set(0.6, 0.6);
			FlxTween.tween(tumbleWeed, {angle: -360}, 0.5, {type: LOOPING});
			tumbleGrp.add(tumbleWeed);
	
			FlxTween.tween(tumbleWeed, {y: 825}, 0.1, {ease: FlxEase.sineInOut, type: PINGPONG});
	
			FlxTween.tween(tumbleWeed, {x: -1200}, 2, {onComplete: function(twn:FlxTween)
			{
				tumbleWeed.kill();
				tumbleWeed = null;
			}});
		}
		else
		{
			tumbleWeed = new FlxSprite(1800, 600).loadGraphic(Paths.image(PlayState.pathway + 'Tumble_' + FlxG.random.int(0,1)));
			FlxTween.tween(tumbleWeed, {angle: -360}, 1.7, {type: LOOPING});
			tumbleGrp.add(tumbleWeed);
	
			FlxTween.tween(tumbleWeed, {y: 735}, 0.75, {ease: FlxEase.sineIn, type: PINGPONG});
	
			FlxTween.tween(tumbleWeed, {x: -1200}, 5.6, {onComplete: function(twn:FlxTween)
			{
				tumbleWeed.kill();
				tumbleWeed = null;
			}});
		}
	}

	function lightningStrike()
	{
		lightning.alpha = 1;
		if (FlxG.random.bool(50))
		{
			lightning.animation.play('boom');
		}
		else
		{
			lightning.animation.play('boom2');
		}
		new FlxTimer().start(1.5, function(tmr:FlxTimer) {lightning.alpha = 0;});
	}

	function lightningStrikeFore()
	{
		lightningFore.alpha = 1;
		if (FlxG.random.bool(50))
		{
			lightningFore.animation.play('boom');
		}
		else
		{
			lightningFore.animation.play('boom2');
		}
		new FlxTimer().start(1.5, function(tmr:FlxTimer) {lightningFore.alpha = 0;});
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

					fireTweenHandler = FlxTween.tween(fireThing, {alpha: Std.parseFloat(triggerInfo[0]), y: Std.parseFloat(triggerInfo[1])}, Std.parseFloat(triggerInfo[2]), {ease: returnTweenEase(value2), onComplete: function(twn:FlxTween)
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
						rainTween = FlxTween.tween(rain, {alpha: Std.parseFloat(triggerInfo[0])}, Std.parseFloat(triggerInfo[1]), {ease: returnTweenEase(value2), onComplete: function(twn:FlxTween)
						{
							rainTween = null;
						}});
					}
				}
			case 'Delusional Events':
				var eventData:Float = Std.parseFloat(value1);
				switch (eventData)
				{
					case 1: 
						game.boundValue = 1;
						game.drainValue = 0.02;
						game.camBars.fade(FlxColor.BLACK, 2, true);
						if (rain != null) rain.alpha = 1;
					case 2: game.defaultCamZoom = 1.3;
					case 3:
						game.camBars.fade(FlxColor.BLACK, 0.6);
						for (daUIs in [camHUD])
							FlxTween.tween(daUIs, {alpha: 0}, 3);
					// BF Starts Singing Some Lyrics
					case 4:
						game.camVideo.fade(FlxColor.BLACK, 5, true);
						game.camVideo.visible = true;
						deluSing.visible = true;
						deluSing.setVideoTime(0);
						deluSing.resume();
						//it's bugged :(
						//if (game.vocals.volume != 1) game.vocals.volume = 1; // it should be fixed then
					case 5:
						game.defaultCamZoom = 0.8;
						game.camBars.fade(0x000000, 5, true);
						game.camFlashSystem(BG_DARK, {alpha: 1, timer: 0.3, ease: FlxEase.quartInOut});
						game.defaultCamZoom = 1.2;
						game.camFollow.x -= 100;
						FlxTween.tween(game.camFollow, {x: game.camFollow.x + 100}, 12, {ease: FlxEase.sineInOut});
					case 6:
						game.camFlashSystem(BG_DARK, {alpha: 0, timer: 0.3, ease: FlxEase.quartInOut});
						game.defaultCamZoom = 0.75;
						game.camGame.flash(FlxColor.WHITE, 1);

						// today in super r slur shit we have this cus i hate my life
						FlxTween.tween(game.camFollow, {y: game.camFollow.y - 300}, .00000001, {onComplete: bensonFromRegularShow -> {
							FlxTween.tween(game.camFollow, {y: game.camFollow.y + 300}, 7, {ease: FlxEase.sineInOut});
						}});
						
						//Stuff For the Rain
						if (rain != null) 
						{
							rain.kill();
							rain.destroy();
							rain = null;
						}
						if (heavyRain != null && !ClientPrefs.data.lowQuality)
							heavyRain.alpha = 0.34;
					case 7:
						camGame.zoom += 0.3;
						game.camFlashSystem(BG_FLASH, {alpha: 0.5, timer: 0.35});
					case 8:
						camGame.zoom += 0.15;
						game.camFlashSystem(BG_FLASH, {alpha: 0.25, timer: 0.35});
					case 9: game.defaultCamZoom = 1;
					case 10:
						game.camBars.fade(0x00000, .000001);
						game.defaultCamZoom = 1.3;

					// Mickey Screams Like A Bitch
					case 11:
						game.camVideo.visible = false;
						game.boundValue = 0.6;
						game.drainValue = 0.025;
						game.chromEffect = 0.3;
						game.chromTween = FlxTween.tween(game, {chromEffect: 1}, 1.2);
						game.camBars.fade(0x00000, .000001, true);
						game.defaultCamZoom = 0.75;
						camGame.shake(0.01, 1.2);
						camGame.visible = true;
						camGame.alpha = 1;
					// The Drop Starts
					case 12:
						FlxTween.tween(camHUD, {alpha: 1}, 1, {ease: FlxEase.quadOut});
						if (game.chromTween != null) game.chromTween.cancel();
						game.chromTween = FlxTween.tween(game, {chromEffect: 0.18}, 0.6, {ease: FlxEase.sineOut});
						if (ClientPrefs.data.flashing)
							camGame.flash(FlxColor.WHITE, 0.5);
						if (ClientPrefs.data.shaders)
						{
                            if (!ClientPrefs.data.lowQuality)
                            {
                                camGame.setFilters([
                                    new ShaderFilter(dramaticCamMovement),
                                    new ShaderFilter(monitorFilter),
                                    new ShaderFilter(chromZoomShader),
                                    new ShaderFilter(chromNormalShader),
                                    new ShaderFilter(delusionalShift)
                                ]);
                                camHUD.setFilters([
									new ShaderFilter(grayScale),
									new ShaderFilter(chromNormalShader), 
									new ShaderFilter(delusionalShift)]);
                            }
                            else
                            {
                                camGame.setFilters([
                                    new ShaderFilter(monitorFilter),
                                    new ShaderFilter(chromZoomShader),
                                    new ShaderFilter(chromNormalShader),
                                    new ShaderFilter(delusionalShift)
                                ]);
                                camHUD.setFilters([
									new ShaderFilter(grayScale),
									new ShaderFilter(chromNormalShader), 
									new ShaderFilter(delusionalShift)]);
                            }
						}
					case 13:
						game.chromTween = null;
						game.defaultCamZoom = 0.85;
					case 14: game.defaultCamZoom = 1;
					case 15: game.defaultCamZoom = 0.75;
					case 16: game.defaultCamZoom = 1;
					case 17: game.defaultCamZoom = 0.7;
					case 18: game.defaultCamZoom += 0.1;
					case 19: game.defaultCamZoom += 0.2;
					case 20: game.defaultCamZoom += 0.3;
					case 21: game.defaultCamZoom = 1.2;
					case 22: game.defaultCamZoom = 1.3;
					case 23: game.defaultCamZoom = 0.75;
					case 24:
						game.chromTween = FlxTween.tween(game, {chromEffect: 1}, 0.1, {ease: FlxEase.sineInOut});
						//game.tweenCamera(1.5, 0.1, 'sineInOut');
					case 25:
						if (game.chromTween != null) game.chromTween.cancel();
						game.chromTween = null;
						camGame.visible = false;
						game.uiGroup.visible = false;
					case 26:
						camGame.visible = true;
						game.uiGroup.visible = true;
						if (ClientPrefs.data.flashing)
							camGame.flash(FlxColor.WHITE, 1);
						game.defaultCamZoom = 0.8;
						game.chromTween = FlxTween.tween(game, {chromEffect: 0.1}, 0.6, {ease: FlxEase.quadOut});
					case 27:
						if (isStoryMode)
						{
							PlayState.detailsText = "Episode 1 - Regret (PEACEFUL)";
						}
						else
						{
							PlayState.detailsText = "Freeplay - Regret (PEACEFUL)";
						}
						PlayState.useFakeDeluName = true;
						PlayState.windowName = "...";
						DiscordClient.changePresence("Do you have any idea...", "", (PlayState.useFakeDeluName ? "regret" : CoolUtil.spaceToDash(game.SONG.song).toLowerCase()), "idkMan");
						lime.app.Application.current.window.title = PlayState.windowName;
						game.boundValue = 2;
						game.drainValue = 0;
						camGame.visible = false;
						game.uiGroup.visible = false;
						game.noteGroup.visible = false;
						if (!ClientPrefs.data.lowQuality)
						{
							atmosphereParticle.visible = false;
							ashParticle.visible = false;
						}
					case 28:
						if (ClientPrefs.data.shaders)
						{
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
                                    new ShaderFilter(chromZoomShader),
                                    new ShaderFilter(chromNormalShader)
                                ]);
                                camHUD.setFilters([new ShaderFilter(chromNormalShader)]);
                            }
						}
						game.chromEffect = 0.00001;
						game.defaultCamZoom = 0.85;
					case 29:
						PlayState.windowName = "Where am I...?";
						DiscordClient.changePresence("Do you have any idea...", "...what you're dealing with?", (PlayState.useFakeDeluName ? "regret" : CoolUtil.spaceToDash(PlayState.SONG.song).toLowerCase()), "idkMan");
						lime.app.Application.current.window.title = PlayState.windowName;
					case 30:
						DiscordClient.changePresence(PlayState.detailsText, game.scoreTxt.text, (PlayState.useFakeDeluName ? "regret" : CoolUtil.spaceToDash(PlayState.SONG.song).toLowerCase()), "idkMan");
						PlayState.windowName = "Funkin.avi - " + (isStoryMode ? PlayState.curEpisode + " - " : "Freeplay - ") + "Regret [________]";
						lime.app.Application.current.window.title = PlayState.windowName;
						camGame.visible = true;
						game.noteGroup.visible = true;
						game.comboGroup.visible = false;
						game.boyfriend.x += 1000;
					case 31:
						PlayState.windowName = "Funkin.avi - " + (isStoryMode ? PlayState.curEpisode + " - " : "Freeplay - ") + "Regret [P_______]";
						lime.app.Application.current.window.title = PlayState.windowName;
					case 32:
						PlayState.windowName = "Funkin.avi - " + (isStoryMode ? PlayState.curEpisode + " - " : "Freeplay - ") + "Regret [PE______]";
						lime.app.Application.current.window.title = PlayState.windowName;
					case 33:
						PlayState.windowName = "Funkin.avi - " + (isStoryMode ? PlayState.curEpisode + " - " : "Freeplay - ") + "Regret [PEA_____]";
						lime.app.Application.current.window.title = PlayState.windowName;
					case 34:
						PlayState.windowName = "Funkin.avi - " + (isStoryMode ? PlayState.curEpisode + " - " : "Freeplay - ") + "Regret [PEAC____]";
						lime.app.Application.current.window.title = PlayState.windowName;
					case 35:
						PlayState.windowName = "Funkin.avi - " + (isStoryMode ? PlayState.curEpisode + " - " : "Freeplay - ") + "Regret [PEACE___]";
						lime.app.Application.current.window.title = PlayState.windowName;
					case 36:
						PlayState.windowName = "Funkin.avi - " + (isStoryMode ? PlayState.curEpisode + " - " : "Freeplay - ") + "Regret [PEACEF__]";
						lime.app.Application.current.window.title = PlayState.windowName;
					case 37:
						PlayState.windowName = "Funkin.avi - " + (isStoryMode ? PlayState.curEpisode + " - " : "Freeplay - ") + "Regret [PEACEFU_]";
						lime.app.Application.current.window.title = PlayState.windowName;
						FlxTween.tween(game.boyfriend, {alpha: 0.45}, 2.5, {ease: FlxEase.expoOut});
					case 38:
						PlayState.windowName = "Funkin.avi - " + (isStoryMode ? PlayState.curEpisode + " - " : "Freeplay - ") + "Regret [PEACEFUL]";
						lime.app.Application.current.window.title = PlayState.windowName;
					case 39:
						game.camFlashSystem(CAM_FLASH_FANCY, {alpha: 0.38, timer: 0.85, colors: [255, 255, 255]});
						minnieJumpscare.resume();
						minnieJumpscare.visible = true;
					case 40:
						FlxTween.tween(camGame, {alpha: 0.0001}, 5, {ease: FlxEase.quartInOut});
					case 41:
						PlayState.windowName = "...";
						lime.app.Application.current.window.title = PlayState.windowName;
					case 42:
						PlayState.windowName = "Welcome back.... Little mouse.";
						lime.app.Application.current.window.title = PlayState.windowName;
						PlayState.blendFlash.cameras = [camGame];
					case 43:
						game.isCameraOnForcedPos = false;
						game.boundValue = 0.45;
						game.drainValue = 0.032;
						game.boyfriend.alpha = 1;
						game.camFollow.x = 0;
						game.camFollow.y = 0;
						if (!ClientPrefs.data.lowQuality)
						{
							atmosphereParticle.visible = true;
							ashParticle.visible = true;
						}
						game.uiGroup.visible = false;
						camGame.alpha = 1;
					case 44:
						PlayState.useFakeDeluName = false;
						if (isStoryMode)
						{
							PlayState.detailsText = "Episode 1 - " + PlayState.SONG.song + " (" + FreeplayState.getDiffRank() + ")";
						}
						else
						{
							PlayState.detailsText = "Freeplay - " + PlayState.SONG.song + " (" + FreeplayState.getDiffRank() + ")";
						}
						PlayState.windowName = "Funkin.avi - " + (isStoryMode ? PlayState.curEpisode + " - " : "Freeplay - ") + PlayState.SONG.song + " [" + FreeplayState.getDiffRank() + "]";
						DiscordClient.changePresence(PlayState.detailsText, game.scoreTxt.text, (PlayState.useFakeDeluName ? "regret" : CoolUtil.spaceToDash(PlayState.SONG.song).toLowerCase()), "idkMan");
						lime.app.Application.current.window.title = PlayState.windowName;
						game.camVideo.visible = false;
						camGame.alpha = 1;
						game.uiGroup.visible = true;
						game.noteGroup.visible = true;
						game.comboGroup.visible = true;
						game.defaultCamZoom = 0.9;
						game.chromEffect = 0.1;
						if (ClientPrefs.data.flashing)
							camGame.flash(FlxColor.WHITE, 0.5);
						if (ClientPrefs.data.shaders)
						{
                            if (!ClientPrefs.data.lowQuality)
                            {
                                camGame.setFilters([
                                    new ShaderFilter(dramaticCamMovement),
									new ShaderFilter(heatWaveEffect),
                                    new ShaderFilter(monitorFilter),
                                    new ShaderFilter(chromZoomShader),
                                    new ShaderFilter(chromNormalShader),
                                    new ShaderFilter(delusionalShift)
                                ]);
                                camHUD.setFilters([new ShaderFilter(grayScale), new ShaderFilter(chromNormalShader), new ShaderFilter(delusionalShift)]);
                            }
                            else
                            {
                                camGame.setFilters([
                                    new ShaderFilter(monitorFilter),
                                    new ShaderFilter(chromZoomShader),
                                    new ShaderFilter(chromNormalShader),
                                    new ShaderFilter(delusionalShift)
                                ]);
                                camHUD.setFilters([new ShaderFilter(grayScale), new ShaderFilter(chromNormalShader), new ShaderFilter(delusionalShift)]);
                            }
						}
					case 45:
						game.camFlashSystem(CAM_FLASH_FANCY, {alpha: 0.135, timer: 0.85, colors: [255, 0, 0]});
					// The part where shit gets serious, Evilrette/Satan starts the solo
					case 46:
						game.boundValue = 1.5;
						game.drainValue = 0.01;
						//game.tweenCamera(1.35, 7, "quartInOut");
						game.camFlashSystem(CAM_FLASH_FANCY, {alpha: 0.4, timer: 2, colors: [255, 0, 0]});
						game.camFlashSystem(BG_DARK, {alpha: 0.8, timer: 6, ease: FlxEase.quartInOut});
						game.isCameraOnForcedPos = true;
						FlxTween.tween(game.camFollow, {x: game.camFollow.x + 150, y: game.camFollow.y + 50}, 4.3, {ease: FlxEase.quartInOut});
					// camera moves over to Mickey realizing he was never gonna win
					case 47:
						FlxTween.tween(game.camFollow, {x: game.camFollow.x - 950, y: game.camFollow.y - 70}, 1.5, {ease: FlxEase.circInOut});
					case 48:
						game.camFollow.x = 440;
						game.camFollow.y = 360;
						FlxTween.tween(mickeySpirit, {alpha: 0.6}, 2, {ease: FlxEase.sineOut});
						game.defaultCamZoom = 0.5;
						game.camFlashSystem(BG_DARK, {alpha: 0, timer: 1, ease: FlxEase.circOut});
					case 49:
						FlxTween.tween(mickeySpirit, {alpha: 0}, 4, {ease: FlxEase.quartOut});
						game.isCameraOnForcedPos = false;
						game.defaultCamZoom = 0.9;
					case 50:
						FlxTween.tween(camGame, {zoom: 1.6}, 1, {ease: FlxEase.sineInOut});
						game.camVideo.visible = true;
						game.camVideo.fade(FlxColor.BLACK, 0.7);
					case 51:
						camGame.visible = false;
						FlxTween.tween(camHUD, {alpha: 0}, 2);
						game.camVideo.zoom += 0.3;
						game.camVideo.fade(FlxColor.BLACK, 0.2, true);
						FlxTween.tween(game.camVideo, {zoom: 1}, 0.5, {ease: FlxEase.sineOut});
						game.camFlashSystem(BG_DARK, {timer: 5});
						death.setVideoTime(0);
						death.resume();
						death.visible = true;
					case 52:
						game.camFlashSystem(BG_DARK, {alpha: 1, timer: 0.5, ease: FlxEase.sineOut});
					case 53:
						game.camFlashSystem(BG_FLASH, {alpha: 1, timer: 0.3, ease: FlxEase.sineOut});
						if (ClientPrefs.data.shaders)
							{
								if (!ClientPrefs.data.lowQuality)
								{
									camGame.setFilters([
										new ShaderFilter(dramaticCamMovement),
										new ShaderFilter(monitorFilter)
									]);
								}
								else
								{
									camGame.setFilters([
										new ShaderFilter(monitorFilter)
									]);
								}
							}
					case 54:
						FlxTween.tween(game.camVideo, {alpha: 0}, 4);

					case 55:
						FlxTween.tween(fakeLightOfHope, {alpha: 0.001}, 1.7);
						if (!ClientPrefs.data.lowQuality) FlxTween.tween(stageFront, {alpha: 1}, 1.5);
					
					case 56:
						if (!ClientPrefs.data.lowQuality)
						{
							smokeShit.forEach(function(spr:FlxSprite)
							{
								FlxTween.tween(spr, {alpha: 0.55}, 1.5);
							});
							smokeFore.forEach(function(spr:FlxSprite)
								{
									FlxTween.tween(spr, {alpha: 0.55}, 1.5);
							});
						}

					case 57:
						if (!ClientPrefs.data.lowQuality)
						{
							FlxTween.tween(fireThing, {alpha: 1}, 1);
						}
					case 58:
						if (!ClientPrefs.data.lowQuality)
						{
							smokeShit.forEach(function(spr:FlxSprite)
							{
								FlxTween.tween(spr, {alpha: 0.25}, 1.5);
							});
							smokeFore.forEach(function(spr:FlxSprite)
							{
									FlxTween.tween(spr, {alpha: 0.25}, 1.5);
							});
						}
					case 59:
						colorsOrSmthElse.kill();
						colorsOrSmthElse.destroy();
						colorsOrSmthElse = null;
						floor.kill();
						floor.destroy();
						floor = null;
						if (!ClientPrefs.data.lowQuality)
						{
							fireThing.kill();
							fireThing.destroy();
							fireThing = null;
							smokeShit.forEach(function(spr:FlxSprite)
								{
									spr.alpha = 0;
								});
								smokeFore.forEach(function(spr:FlxSprite)
								{
									spr.alpha = 0;
								});
							heavyRain.visible = false;
							totallyanoriginalname.visible = true;
							stageCurtains.visible = false;
							stageFront.kill();
							stageFront.destroy();
							stageFront = null;
						}
						minnieBackground.visible = true;
					case 60:
						if (!ClientPrefs.data.lowQuality)
						{
							stageCurtains.alpha = 0.0001;
							stageCurtains.visible = true;
						}
					case 61:
						if (!ClientPrefs.data.lowQuality)
						{
							stageCurtains.alpha = 1;
							FlxTween.tween(stageCurtains, {alpha: 0}, 1, {ease: FlxEase.circOut});
						}
					case 62:
						if (!ClientPrefs.data.lowQuality)
							FlxTween.tween(stageCurtains, {alpha: 1}, 5);
					case 63:
						if (!ClientPrefs.data.lowQuality)
						{
							smokeShit.forEach(function(spr:FlxSprite)
								{
									spr.alpha = 0.7;
								});
								smokeFore.forEach(function(spr:FlxSprite)
								{
									spr.alpha = 0.74;
								});
							heavyRain.visible = true;
							totallyanoriginalname.kill();
							totallyanoriginalname.destroy();
							totallyanoriginalname = null;
						}
						streetRuins.visible = true;
						fakeLightOfHope.alpha = 0.5;
						minnieBackground.kill();
						minnieBackground.destroy();
						minnieBackground = null;
					case 64:
						fakeLightOfHope.alpha = 1;
						FlxTween.tween(fakeLightOfHope, {alpha: 0.5}, 0.85);
					case 65:
						FlxTween.tween(fakeLightOfHope, {alpha: 1, color: FlxColor.RED}, 2, {ease: FlxEase.circInOut});
						if (!ClientPrefs.data.lowQuality) 
							FlxTween.tween(fireThing2, {color: FlxColor.RED}, 2, {ease: FlxEase.circInOut});
						FlxTween.tween(streetRuins, {color: FlxColor.RED}, 2, {ease: FlxEase.circInOut});
						if (!ClientPrefs.data.lowQuality)
						{
							FlxTween.tween(fireForeground, {color: FlxColor.RED}, 2, {ease: FlxEase.circInOut});
							FlxTween.tween(heavyRain, {color: FlxColor.RED}, 2, {ease: FlxEase.circInOut});
							smokeShit.forEach(function(spr:FlxSprite)
							{
								FlxTween.tween(spr, {color: FlxColor.RED}, 2, {ease: FlxEase.circInOut});
							});
							smokeFore.forEach(function(spr:FlxSprite)
							{
								FlxTween.tween(spr, {color: FlxColor.RED}, 2, {ease: FlxEase.circInOut});
							});
						}
					case 66:
						FlxTween.tween(fakeLightOfHope, {color: FlxColor.WHITE}, 0.5, {ease: FlxEase.circOut});
						if (!ClientPrefs.data.lowQuality) FlxTween.tween(fireThing2, {color: FlxColor.WHITE, alpha: 0.75}, 1.2, {ease: FlxEase.circOut});
						FlxTween.tween(streetRuins, {color: FlxColor.WHITE}, 0.5, {ease: FlxEase.circOut});
						if (!ClientPrefs.data.lowQuality)
						{
							lightningStrike();
							lightningStrikeFore();
							FlxTween.tween(fireForeground, {color: FlxColor.WHITE, alpha: 0.6}, 2, {ease: FlxEase.circOut});
							FlxTween.tween(heavyRain, {color: FlxColor.fromRGB(252, 141, 141)}, 0.5, {ease: FlxEase.circOut});
							smokeShit.forEach(function(spr:FlxSprite)
							{
								FlxTween.tween(spr, {color: FlxColor.WHITE}, 0.5, {ease: FlxEase.circOut});
							});
							smokeFore.forEach(function(spr:FlxSprite)
							{
								FlxTween.tween(spr, {color: FlxColor.WHITE}, 0.5, {ease: FlxEase.circOut});
							});
						}
					case 67:
						FlxTween.tween(fakeLightOfHope, {alpha: 0}, 2);
						if (!ClientPrefs.data.lowQuality) FlxTween.tween(fireThing2, {alpha: 1}, 2);
					case 68:
						if (!ClientPrefs.data.lowQuality)
						{
							fireForeground.kill();
							fireForeground.destroy();
							fireForeground = null;
							smokeShit.forEach(function(spr:FlxSprite)
								{
									spr.kill();
									spr.destroy();
									spr = null;
								});
								smokeFore.forEach(function(spr:FlxSprite)
								{
									spr.kill();
									spr.destroy();
									spr = null;
								});
							fireThing2.kill();
							fireThing2.destroy();
							fireThing2 = null;
							heavyRain.kill();
							heavyRain.destroy();
							heavyRain = null;
							stageCurtains.visible = true;
						}
						streetRuins.kill();
						streetRuins.destroy();
						streetRuins = null;
						fakeLightOfHope.kill();
						fakeLightOfHope.destroy();
						fakeLightOfHope = null;
				}
		}
	}

	public static function returnTweenEase(ease:String = '')
	{
		switch (ease.toLowerCase())
		{
			case 'linear':
				return FlxEase.linear;
			case 'backin':
				return FlxEase.backIn;
			case 'backinout':
				return FlxEase.backInOut;
			case 'backout':
				return FlxEase.backOut;
			case 'bouncein':
				return FlxEase.bounceIn;
			case 'bounceinout':
				return FlxEase.bounceInOut;
			case 'bounceout':
				return FlxEase.bounceOut;
			case 'circin':
				return FlxEase.circIn;
			case 'circinout':
				return FlxEase.circInOut;
			case 'circout':
				return FlxEase.circOut;
			case 'cubein':
				return FlxEase.cubeIn;
			case 'cubeinout':
				return FlxEase.cubeInOut;
			case 'cubeout':
				return FlxEase.cubeOut;
			case 'elasticin':
				return FlxEase.elasticIn;
			case 'elasticinout':
				return FlxEase.elasticInOut;
			case 'elasticout':
				return FlxEase.elasticOut;
			case 'expoin':
				return FlxEase.expoIn;
			case 'expoinout':
				return FlxEase.expoInOut;
			case 'expoout':
				return FlxEase.expoOut;
			case 'quadin':
				return FlxEase.quadIn;
			case 'quadinout':
				return FlxEase.quadInOut;
			case 'quadout':
				return FlxEase.quadOut;
			case 'quartin':
				return FlxEase.quartIn;
			case 'quartinout':
				return FlxEase.quartInOut;
			case 'quartout':
				return FlxEase.quartOut;
			case 'quintin':
				return FlxEase.quintIn;
			case 'quintinout':
				return FlxEase.quintInOut;
			case 'quintout':
				return FlxEase.quintOut;
			case 'sinein':
				return FlxEase.sineIn;
			case 'sineinout':
				return FlxEase.sineInOut;
			case 'sineout':
				return FlxEase.sineOut;
			case 'smoothstepin':
				return FlxEase.smoothStepIn;
			case 'smoothstepinout':
				return FlxEase.smoothStepInOut;
			case 'smoothstepout':
				return FlxEase.smoothStepInOut;
			case 'smootherstepin':
				return FlxEase.smootherStepIn;
			case 'smootherstepinout':
				return FlxEase.smootherStepInOut;
			case 'smootherstepout':
				return FlxEase.smootherStepOut;
		}
		return FlxEase.linear;
	}
}