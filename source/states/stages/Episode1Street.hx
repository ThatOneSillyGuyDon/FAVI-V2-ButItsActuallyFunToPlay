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
					//blackParticle.animation.curAnim.curFrame = FlxG.random.int(0, 9);
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
			}
		}
	}
	
	override function createPost()
	{
		switch (PlayState.SONG.song)
		{
			case 'Isolated' | 'Lunacy':
				game.camBars.fade(FlxColor.BLACK, 0.0001);
				camHUD.alpha = 0.001;
			case "Delusional":
				deluSing = new VideoSprite(false);
				deluSing.visible = false;
				deluSing.load(Paths.video("deluLyrics"), [VideoSprite.muted]);
				deluSing.cameras = [game.camVideo];
				deluSing.play();
				deluSing.pause();
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
				minnieJumpscare = new VideoSprite(false);
				minnieJumpscare.visible = false;
				minnieJumpscare.load(Paths.video("minniePart"), [VideoSprite.muted]);
				minnieJumpscare.cameras = [game.camVideo];
				minnieJumpscare.play();
				minnieJumpscare.pause();
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
			add(demonBFIcon);
		
			demonBFScary = new HealthIcon('evildelu', true, false, true, false);
			demonBFScary.animation.curAnim.curFrame = 1;
			demonBFScary.visible = false;
			add(demonBFScary);
		
			fakeBFLosingFrame = new HealthIcon('evilrett', true, false, true, false);
			fakeBFLosingFrame.animation.curAnim.curFrame = 1;
			fakeBFLosingFrame.visible = false;
			add(fakeBFLosingFrame);
		
			isolatedHappy = new HealthIcon('lunaavier', false, false, false, true);
			isolatedHappy.animation.curAnim.curFrame = 2;
			isolatedHappy.visible = false;
			add(isolatedHappy);
			
			lunacyIcon = new HealthIcon('lunaavier', false, false, true, false);
			lunacyIcon.visible = false;
			add(lunacyIcon);
			
			delusionalIcon = new HealthIcon('deluavier', false, false, true, false);
			delusionalIcon.visible = false;
			add(delusionalIcon);

			demonBFIcon.cameras = [camHUD];
			demonBFScary.cameras = [camHUD];
			fakeBFLosingFrame.cameras = [camHUD];
			isolatedHappy.cameras = [camHUD];
			lunacyIcon.cameras = [camHUD];
			delusionalIcon.cameras = [camHUD];
		}
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
			default: game.boyfriend.setPosition(275, 50);
		}
	}

	override function stepHit()
	{
		switch (PlayState.SONG.song)
		{
			case 'Isolated': 
				switch (curStep)
				{
					case 1150: 
						game.defaultCamZoom = camGame.zoom = 1.2;
						game.cinematicBarControls('moveboth', 0.0001, 'linear', 155);
				}
		}
	}
	override function beatHit()
	{
		if (PlayState.SONG.song == "Isolated")
			switch (curBeat)
			{
				case 160:
					game.iconP2.alpha = 0;
					isolatedHappy.visible = true;
					FlxTween.tween(isolatedHappy, {alpha: 0}, 1);
					FlxTween.tween(game.iconP2, {alpha: 1}, 0.6);

				case 168:
					lunacyIcon.visible = true;
					game.iconP2.alpha = 0;
					FlxTween.tween(lunacyIcon, {alpha: 0}, 1);
					FlxTween.tween(game.iconP2, {alpha: 1}, 0.6);

				case 172:
					delusionalIcon.visible = true;
					game.iconP2.alpha = 0;
					FlxTween.tween(delusionalIcon, {alpha: 0}, 1);
					FlxTween.tween(game.iconP2, {alpha: 1}, 0.6);

				case 176:
					fakeBFLosingFrame.visible = true;
					game.iconP1.alpha = 0;
					FlxTween.tween(fakeBFLosingFrame, {alpha: 0}, 1);
					FlxTween.tween(game.iconP1, {alpha: 1}, 0.6);

				case 184:
					demonBFIcon.visible = true;
					game.iconP1.alpha = 0;
					FlxTween.tween(demonBFIcon, {alpha: 0}, 1);
					FlxTween.tween(game.iconP1, {alpha: 1}, 0.6);

				case 188:
					demonBFScary.visible = true;
					game.iconP1.alpha = 0;
					FlxTween.tween(demonBFScary, {alpha: 0}, 1);
					FlxTween.tween(game.iconP1, {alpha: 1}, 0.6);
			}
		
		switch (PlayState.SONG.song)
		{
			case 'Isolated':
				var beatBopArray:Array<Int> = [32, 36, 40, 44, 48, 52, 56, 60, 64, 68, 72, 76, 80, 84, 88, 92];
				var beatBopArray2:Array<Int> = [168, 172, 176, 184, 188];
				var beatBopArray3:Array<Int> = [194, 196, 198, 200, 202, 204, 206, 208, 210, 212, 214, 216, 217, 218, 219, 220, 221, 222, 223];

				switch (curBeat)
				{
					case 12: game.camBars.fade(FlxColor.BLACK, 3, true);

					case 30:
						FlxTween.tween(camHUD, {alpha: 1}, 3, {ease: FlxEase.quadOut});

					case 88: 
						game.tweenCamera(1.4, 3, 'sineInOut');
						game.camFlashSystem(BG_FLASH, {alpha: 0.32, timer: 1.2, colors: [194, 194, 194]});

					case 95: 
						game.cameraSpeed += 3;
						game.isCameraOnForcedPos = true;
						game.camFollow.x -= 950;
						//updateSectionCamera('dad', false);

					case 96:
						game.isCameraOnForcedPos = false;
						game.cameraSpeed -= 3;
						game.defaultCamZoom = 0.85;
						game.tweenCamera(0.85, 0.4, 'expoOut');

						if (ClientPrefs.data.flashing)
							camGame.flash(FlxColor.WHITE, 1.5);
						game.camFlashSystem(BG_FLASH, {alpha: 0.4, timer: 0.35});
					
						case 160: 
						game.tweenCamera(1.3, 2, 'sineInOut');
						game.camFlashSystem(BG_DARK, {alpha: 0.85, timer: 0.5, ease: FlxEase.quartOut});
					case 184:
						game.camFlashSystem(BG_DARK, {alpha: 0.77, timer: 0.5, ease: FlxEase.quartOut});

					case 188:
						game.camFlashSystem(BG_DARK, {alpha: 0.6, timer: 0.5, ease: FlxEase.quartOut});

					case 192: 
						if (ClientPrefs.data.flashing)
							camGame.flash(FlxColor.WHITE, 1.5);
						game.camFlashSystem(BG_FLASH, {alpha: 0.32, timer: 0.35, colors: [194, 194, 194]});
						
						game.defaultCamZoom = 1.25;

					// same as dad
					// case 199: updateSectionCamera('bf', true);

					// update after testing without the cam thing they rarely still stunned so idk what to do lmao

					case 220: 
						game.tweenCamera(0.85, 2, 'sineInOut');
						game.camFlashSystem(BG_FLASH, {alpha: 0.32, timer: 0.1, colors: [194, 194, 194]});

					case 288:
						game.defaultCamZoom = 0.85;

						if (ClientPrefs.data.flashing)
							camGame.flash(FlxColor.WHITE, 1.5);
						game.camFlashSystem(BG_FLASH, {alpha: 0.4, timer: 0.35, colors: [194, 194, 194]});

					case 352:
						game.camFlashSystem(BG_DARK, {alpha: 0.85, timer: 0.5, ease: FlxEase.quartOut});
						game.tweenCamera(1.07, 5, 'quadInOut');
						game.cameraSpeed -= 0.25;

					case 376:
						game.camFlashSystem(BG_DARK, {alpha: 0, timer: 4, ease: FlxEase.quartInOut});

					case 36 | 40 | 44 | 52 | 56 | 60 | 64 | 68 | 72 | 76 | 80 | 84 | 92:
						game.camFlashSystem(BG_FLASH, {alpha: 0.32, timer: 1.2, colors: [194, 194, 194]});

					case 100 | 104 | 108 | 116 | 120 | 124 | 132 | 136 | 140 | 148 | 152 | 156 | 228 | 232 | 236 | 240 | 244 | 252 | 260 | 264 | 268 | 276 |
						280 | 284 | 292 | 296 | 300 | 308 | 312 | 316 | 324 | 328 | 332 | 340 | 344 | 348:
						game.camFlashSystem(BG_FLASH, {alpha: 0.2, timer: 0.35, colors: [194, 194, 194]});

					case 98 | 102 | 106 | 110 | 114 | 118 | 122 | 126 | 130 | 134 | 138 | 142 | 146 | 150 | 154 | 158 | 226 | 230 | 234 | 238 | 242 | 246 |
						250 | 254 | 258 | 262 | 266 | 270 | 274 | 278 | 282 | 286 | 290 | 294 | 298 | 302 | 306 | 310 | 314 | 318 | 322 | 326 | 330 | 334 |
						338 | 342 | 346 | 350:
						game.camFlashSystem(BG_FLASH, {alpha: 0.55, timer: 0.35, colors: [194, 194, 194]});

					case 194 | 196 | 198 | 200 | 202 | 204 | 206 | 210 | 212 | 214 | 222:
						game.camFlashSystem(BG_FLASH, {alpha: 0.32, timer: 0.35, colors: [194, 194, 194]});

					case 216 | 217 | 218 | 219:
						game.camFlashSystem(BG_FLASH, {alpha: 0.32, timer: 0.1, colors: [194, 194, 194]});
						camHUD.zoom += 0.04;

					case 128 | 256:
						if (ClientPrefs.data.flashing)
							camGame.flash(FlxColor.WHITE, 1.5);
						game.camFlashSystem(BG_FLASH, {alpha: 0.4, timer: 0.35, colors: [194, 194, 194]});

					case 48 | 336 | 304 | 272 | 112 | 144:
						if (ClientPrefs.data.flashing)
							camGame.flash(FlxColor.BLACK, 1.5);
						game.camFlashSystem(BG_FLASH, {alpha: 0.32, timer: 1.2, colors: [194, 194, 194]});

					case 32:
						if (ClientPrefs.data.flashing) camGame.flash(FlxColor.WHITE, 1.5);

					case 416:
						camGame.visible = false;
						camHUD.visible = false;

					case 224:
						game.camFlashSystem(BG_FLASH, {alpha: 0.4, timer: 0.35, colors: [194, 194, 194]});
						if (ClientPrefs.data.flashing) camGame.flash(FlxColor.WHITE, 1.5);

					case 320:
						game.camFlashSystem(BG_FLASH, {alpha: 0.4, timer: 0.35, colors: [194, 194, 194]});
						if (ClientPrefs.data.flashing) camGame.flash(FlxColor.WHITE, 1.5);
				}

				if (curBeat == 1)
				{
					game.cinematicBarControls("add", 0.0001, 'linear', 0);
					game.cinematicBarControls("moveboth", 0.0001, 'linear', 130);
				}
				if (curBeat == 28)
					game.cinematicBarControls("moveboth", 1, 'circInOut', 65);
				for (i in 0...beatBopArray.length)
					if (curBeat == beatBopArray[i])
						game.cinematicBarControls('bopboth', 1, 'quartOut', 32, 33);
				if (curBeat == 96)
					game.cinematicBarControls('moveboth', 0.3, 'sineOut', 0);
				if (curBeat == 160 || curBeat == 352)
					game.cinematicBarControls('moveboth', 1, 'circOut', 140);
				if (curBeat == 164 || curBeat == 180)
					game.cinematicBarControls('bopboth', 0.85, 'quartOut', 125, 15);
				for (i in 0...beatBopArray2.length)
					if (curBeat == beatBopArray2[i])
						game.cinematicBarControls('bopboth', 1, 'quartOut', 90, 60);
				if (curBeat == 192)
					game.cinematicBarControls('moveboth', 0.7, 'sineOut', 85);
				for (i in 0...beatBopArray3.length)
					if (curBeat == beatBopArray3[i])
						game.cinematicBarControls('bopboth', 0.3, 'sineOut', 40, 45);
				if (curBeat == 224)
					game.cinematicBarControls('moveboth', 0.3, 'quartOut', 0);
				if (curBeat == 287)
					game.cinematicBarControls('moveboth', 0.0001, 'linear', 100);
				if (curBeat == 288)
					game.cinematicBarControls('moveboth', 0.75, 'circOut', 0);
				if (curBeat == 376)
					game.cinematicBarControls('moveboth', 3, 'sineInOut', 0);
				if (curBeat == 415)
					game.cinematicBarControls('moveboth', 0.63, 'circInOut', 600);

				if ((curBeat > 96 && curBeat < 160) || (curBeat > 224 && curBeat < 352))
				{
					if (curBeat % 2 == 0)
					{
						camGame.zoom += 0.05;
						camHUD.zoom += 0.06;
					}
				}

			case 'Lunacy':
				var beatArray1:Array<Int> = [38, 40, 46, 48, 54, 56, 62];
				var beatArray2:Array<Int> = [70, 72, 78, 80, 86, 88];
				var beatArray3:Array<Int> = [224, 230, 240, 248, 256, 262, 272, 280, 288, 296, 304, 312, 320, 328, 336, 344];
				var beatArray4:Array<Int> = [228, 238, 244, 252, 260, 270, 276, 284, 292, 300, 308, 316, 324, 332, 340, 348];

				if (curBeat == 1)
					{
						game.cinematicBarControls("add", 0.0001, 'linear', 0);
						game.cinematicBarControls("moveboth", 0.0001, 'linear', 60);
					}
					if (curBeat == 32)
						game.cinematicBarControls("moveboth", 1.2, "circOut", 120);
					if (curBeat == 64)
						game.cinematicBarControls("moveboth", 1.2, "circOut", 190);
					if (curBeat == 90)
						game.cinematicBarControls("moveboth", 2, "circInOut", 0);
					for (i in 0...beatArray1.length)
						if (curBeat == beatArray1[i])
							game.cinematicBarControls("bopboth", 0.5, "quartOut", 100, 20);
					for (i in 0...beatArray2.length)
						if (curBeat == beatArray2[i])
							game.cinematicBarControls("bopboth", 0.5, "quartOut", 170, 20);
					if (curBeat == 156)
						game.cinematicBarControls("moveboth", 0.4, "circOut", 120);
					if (curBeat == 160)
						game.cinematicBarControls("moveboth", 1, "circOut", 80);
					if (curBeat == 192)
						game.cinematicBarControls("moveboth", 10, "circInOut", 180);
					for (i in 0...beatArray3.length)
						if (curBeat == beatArray3[i])
							game.cinematicBarControls("moveboth", 0.5, "circOut", 60);
					for (i in 0...beatArray4.length)
						if (curBeat == beatArray4[i])
							game.cinematicBarControls("moveboth", 0.15, "circOut", 130);
					if (curBeat == 352)
						game.cinematicBarControls("moveboth", 2, "circOut", 50);
					if (curBeat == 480)
						game.cinematicBarControls("moveboth", 0.0001, 'linear', 110);

				if (curBeat == 100 || curBeat == 108 || curBeat == 116 || curBeat == 124 || curBeat == 132 || curBeat == 140 || curBeat == 148)
				{
					game.camFlashSystem(BG_FLASH, {alpha: 0.5, timer: 0.5, ease: FlxEase.sineOut});
				}

				if (curBeat == 160 || curBeat == 230 || curBeat == 240 || curBeat == 248 || curBeat == 256 || curBeat == 262 || curBeat == 272
					|| curBeat == 280 || curBeat == 280 || curBeat == 288 || curBeat == 296 || curBeat == 304 || curBeat == 312 || curBeat == 320
					|| curBeat == 328 || curBeat == 336 || curBeat == 344 || curBeat == 352)
				{
					game.camFlashSystem(BG_DARK, {alpha: 0, timer: 0.5, ease: FlxEase.quadOut});
				}

				// Darkens BG
				if (curBeat == 156 || curBeat == 228 || curBeat == 238 || curBeat == 244 || curBeat == 252 || curBeat == 260 || curBeat == 270
					|| curBeat == 276 || curBeat == 284 || curBeat == 292 || curBeat == 300 || curBeat == 308 || curBeat == 316 || curBeat == 324
					|| curBeat == 332 || curBeat == 340 || curBeat == 348)
				{
					game.camFlashSystem(BG_DARK, {alpha: 0.77, timer: 0.5, ease: FlxEase.quadOut});
				}

				if (curBeat == 424 || curBeat == 432 || curBeat == 440 || curBeat == 448 || curBeat == 456 || curBeat == 464 || curBeat == 472)
				{
					game.camFlashSystem(BG_FLASH, {alpha: 0.65, timer: 0.6, ease: FlxEase.sineOut});
				}

				if (curBeat == 32 || curBeat == 64)
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

				if (curBeat == 38 || curBeat == 40 || curBeat == 46 || curBeat == 48 || curBeat == 54 || curBeat == 56 || curBeat == 62 || curBeat == 70
					|| curBeat == 72 || curBeat == 78 || curBeat == 80 || curBeat == 86 || curBeat == 88 || curBeat == 102 || curBeat == 110
					|| curBeat == 118 || curBeat == 126 || curBeat == 134 || curBeat == 142 || curBeat == 150)
				{
					if (game.chromTween != null)
						game.chromTween.cancel();

					game.chromEffect = 0.12;

					game.chromTween = FlxTween.tween(game, {
						chromEffect: 0.0001
					}, 0.3, {
						ease: FlxEase.sineOut,
						onComplete: function(twn:FlxTween)
						{
							game.chromTween = null;
						}
					});
				}

				if (curBeat == 96 || curBeat == 104 || curBeat == 112 || curBeat == 120 || curBeat == 128 || curBeat == 136 || curBeat == 144 || curBeat == 152)
				{
					if (game.chromTween != null)
						game.chromTween.cancel();

					game.chromEffect = 0.32;

					game.chromTween = FlxTween.tween(game, {
						chromEffect: 0.0001
					}, 2.1, {
						ease: FlxEase.sineOut,
						onComplete: function(twn:FlxTween)
						{
							game.chromTween = null;
						}
					});
				}

				if (curBeat == 100 || curBeat == 108 || curBeat == 116 || curBeat == 124 || curBeat == 132 || curBeat == 140 || curBeat == 148)
				{
					if (game.chromTween != null)
						game.chromTween.cancel();
	
					game.chromEffect = 0.4;
	
					game.chromTween = FlxTween.tween(game, {
						chromEffect: 0.0001
					}, 1, {
						ease: FlxEase.sineOut,
						onComplete: function(twn:FlxTween)
						{
							game.chromTween = null;
						}
					});
				}

				if (curBeat == 156)
				{
					if (game.chromTween != null)
						game.chromTween.cancel();

					game.chromTween = FlxTween.tween(game, {
						chromEffect: 0.33
					}, 0.2, {
						ease: FlxEase.sineOut,
						onComplete: function(twn:FlxTween)
						{
							game.chromTween = null;
						}
					});
				}

				if (curBeat == 158)
				{
					if (game.chromTween != null)
						game.chromTween.cancel();

					game.chromEffect = 0.4;

					game.chromTween = FlxTween.tween(game, {
						chromEffect: 0.0001
					}, 0.2, {
						ease: FlxEase.sineOut,
						onComplete: function(twn:FlxTween)
						{
							game.chromTween = null;
						}
					});
				}

				if (curBeat == 160 || curBeat == 168 || curBeat == 176 || curBeat == 184 || curBeat == 192 || curBeat == 200 || curBeat == 208
					|| curBeat == 216 || curBeat == 224 || curBeat == 232 || curBeat == 240 || curBeat == 248 || curBeat == 256 || curBeat == 264
					|| curBeat == 272 || curBeat == 280 || curBeat == 288 || curBeat == 296 || curBeat == 304 || curBeat == 312 || curBeat == 320
					|| curBeat == 328 || curBeat == 336 || curBeat == 344)
				{
					if (game.chromTween != null)
						game.chromTween.cancel();

					game.chromEffect = 0.55;

					game.chromTween = FlxTween.tween(game, {
						chromEffect: 0.0001
					}, 0.6, {
						ease: FlxEase.sineOut,
						onComplete: function(twn:FlxTween)
						{
							game.chromTween = null;
						}
					});
				}

				if (curBeat == 162 || curBeat == 170 || curBeat == 178 || curBeat == 186 || curBeat == 194 || curBeat == 202 || curBeat == 210
					|| curBeat == 218 || curBeat == 226 || curBeat == 234 || curBeat == 242 || curBeat == 250 || curBeat == 258 || curBeat == 266
					|| curBeat == 274 || curBeat == 282 || curBeat == 290 || curBeat == 298 || curBeat == 306 || curBeat == 314 || curBeat == 322
					|| curBeat == 330 || curBeat == 338 || curBeat == 346)
				{
					if (game.chromTween != null)
						game.chromTween.cancel();

					game.chromEffect = 0.6;

					game.chromTween = FlxTween.tween(game, {
						chromEffect: 0.0001
					}, 0.25, {
						ease: FlxEase.sineOut,
						onComplete: function(twn:FlxTween)
						{
							game.chromTween = null;
						}
					});
				}

				if (curBeat == 163 || curBeat == 171 || curBeat == 179 || curBeat == 187 || curBeat == 195 || curBeat == 203 || curBeat == 211
					|| curBeat == 219 || curBeat == 227 || curBeat == 235 || curBeat == 243 || curBeat == 251 || curBeat == 259 || curBeat == 267
					|| curBeat == 275 || curBeat == 283 || curBeat == 291 || curBeat == 299 || curBeat == 307 || curBeat == 315 || curBeat == 323
					|| curBeat == 331 || curBeat == 339 || curBeat == 347)
				{
					if (game.chromTween != null)
						game.chromTween.cancel();

					game.chromTween = FlxTween.tween(game, {
						chromEffect: 0.5
					}, 0.22, {
						ease: FlxEase.sineOut,
						onComplete: function(twn:FlxTween)
						{
							game.chromTween = null;
							game.chromEffect = 0.00001;
						}
					});
				}

				if (curBeat == 165 || curBeat == 173 || curBeat == 181 || curBeat == 189 || curBeat == 197 || curBeat == 205 || curBeat == 213
					|| curBeat == 221)
				{
					if (game.chromTween != null)
						game.chromTween.cancel();

					game.chromTween = FlxTween.tween(game, {
						chromEffect: 0.35
					}, 0.2, {
						ease: FlxEase.sineOut,
						onComplete: function(twn:FlxTween)
						{
							game.chromTween = null;
							game.chromEffect = 0.00001;
						}
					});
				}

				if (curBeat == 166 || curBeat == 174 || curBeat == 182 || curBeat == 190 || curBeat == 198 || curBeat == 206 || curBeat == 214
					|| curBeat == 222)
				{
					if (game.chromTween != null)
						game.chromTween.cancel();

					game.chromEffect = 0.45;

					game.chromTween = FlxTween.tween(game, {
						chromEffect: 0.0001
					}, 0.2, {
						ease: FlxEase.sineOut,
						onComplete: function(twn:FlxTween)
						{
							game.chromTween = null;
						}
					});
				}

				if (curBeat == 167 || curBeat == 175 || curBeat == 183 || curBeat == 191 || curBeat == 199 || curBeat == 207 || curBeat == 215
					|| curBeat == 223)
				{
					if (game.chromTween != null)
						game.chromTween.cancel();

					game.chromEffect = 0.56;

					game.chromTween = FlxTween.tween(game, {
						chromEffect: 0.0001
					}, 0.2, {
						ease: FlxEase.sineOut,
						onComplete: function(twn:FlxTween)
						{
							game.chromTween = null;
						}
					});
				}

				if (curBeat >= 228 && curBeat <= 231 || curBeat >= 236 && curBeat <= 239 || curBeat >= 244 && curBeat <= 247 || curBeat >= 252
					&& curBeat <= 255 || curBeat >= 260 && curBeat <= 263 || curBeat >= 168 && curBeat <= 171 || curBeat >= 276 && curBeat <= 279
					|| curBeat >= 284 && curBeat <= 287 || curBeat >= 292 && curBeat <= 295 || curBeat >= 300 && curBeat <= 303 || curBeat >= 308
					&& curBeat <= 311 || curBeat >= 316 && curBeat <= 319 || curBeat >= 324 && curBeat <= 327 || curBeat >= 332 && curBeat <= 335
					|| curBeat >= 340 && curBeat <= 343 || curBeat >= 348 && curBeat <= 351)
				{
					if (game.chromTween != null)
						game.chromTween.cancel();

					game.chromEffect = 0.32;

					game.chromTween = FlxTween.tween(game, {
						chromEffect: 0.00001
					}, 0.22, {
						ease: FlxEase.sineOut,
						onComplete: function(twn:FlxTween)
						{
							game.chromTween = null;
						}
					});
				}

				if (curBeat == 352 || curBeat == 354 || curBeat == 356 || curBeat == 358 || curBeat == 360 || curBeat == 362 || curBeat == 364
					|| curBeat == 366 || curBeat == 368 || curBeat == 370 || curBeat == 372 || curBeat == 374 || curBeat == 376 || curBeat == 378
					|| curBeat == 380 || curBeat == 382 || curBeat == 384 || curBeat == 386 || curBeat == 388 || curBeat == 390 || curBeat == 392
					|| curBeat == 394 || curBeat == 396 || curBeat == 398 || curBeat == 400 || curBeat == 402 || curBeat == 404 || curBeat == 406
					|| curBeat == 408 || curBeat == 410 || curBeat == 416 || curBeat == 418 || curBeat == 420 || curBeat == 422 || curBeat == 424
					|| curBeat == 426 || curBeat == 428 || curBeat == 430 || curBeat == 432 || curBeat == 434 || curBeat == 436 || curBeat == 438
					|| curBeat == 440 || curBeat == 442 || curBeat == 444 || curBeat == 446 || curBeat == 448 || curBeat == 450 || curBeat == 452
					|| curBeat == 454 || curBeat == 456 || curBeat == 458 || curBeat == 460 || curBeat == 462 || curBeat == 464 || curBeat == 466
					|| curBeat == 468 || curBeat == 470 || curBeat == 472 || curBeat == 474)
				{
					if (game.chromTween != null)
						game.chromTween.cancel();

					game.chromEffect = 0.3;

					game.chromTween = FlxTween.tween(game, {
						chromEffect: 0.00001
					}, 0.5, {
						ease: FlxEase.sineOut,
						onComplete: function(twn:FlxTween)
						{
							game.chromTween = null;
						}
					});
				}

				if (curBeat == 412)
				{
					if (game.chromTween != null)
						game.chromTween.cancel();

					game.chromEffect = 0.36;

					game.chromTween = FlxTween.tween(game, {
						chromEffect: 0.00001
					}, 1, {
						ease: FlxEase.sineOut,
						onComplete: function(twn:FlxTween)
						{
							game.chromTween = null;
						}
					});
				}

				if (curBeat == 476)
				{
					if (game.chromTween != null)
						game.chromTween.cancel();

					game.chromTween = FlxTween.tween(game, {
						chromEffect: 0.85
					}, 1.6, {
						ease: FlxEase.sineOut,
						onComplete: function(twn:FlxTween)
						{
							game.chromTween = null;
						}
					});
				}

				if (curBeat == 480)
				{
					game.chromTween.cancel();

					game.chromEffect = 0.00001;
				}

				switch (curBeat)
				{
					// I'm NOT gonna have a fun time recoding all this for the BG dimming in and out later lmao

					case 16: game.camBars.fade(FlxColor.BLACK, 3, true);

					case 32:
						if (ClientPrefs.data.flashing) game.camBars.flash(FlxColor.BLACK, 1.5);
						//game.tweenCamera(game.camGame.zoom + .5, 16.5, 'sineInOut');

					case 64:
						if (ClientPrefs.data.flashing)
							game.camBars.flash(FlxColor.BLACK, 0.9);

					case 88:
						game.tweenCamera(.75, 2.2, 'sineInOut');

						FlxTween.tween(camHUD, {alpha: 1}, 5, {ease: FlxEase.sineOut});

					case 96:
						game.defaultCamZoom = 0.75;
						if (ClientPrefs.data.flashing)
							game.camBars.flash(FlxColor.WHITE, 1.5);

					case 128 | 256:
						if (ClientPrefs.data.flashing) game.camBars.flash(FlxColor.WHITE, 1.5);

					case 156:
						game.defaultCamZoom = 1.05;

					case 160:
						game.boundValue = 1.25;
						game.drainValue = 0.015;
						game.defaultCamZoom = 0.7;
						if (ClientPrefs.data.flashing) game.camBars.flash(FlxColor.BLACK, 1.5);

					case 192:
						game.defaultCamZoom = 0.75;
					case 200 | 238 | 270 | 316 | 332 | 344:
						game.defaultCamZoom = 0.8;
					case 208:
						game.defaultCamZoom = 0.85;
					case 216 | 252 | 284:
						game.defaultCamZoom = 0.9;
					case 220:
						game.defaultCamZoom = 0.95;
					case 222 | 267 | 239 | 271 | 334:
						game.defaultCamZoom = 1;

					case 224 | 288:
						game.defaultCamZoom = 0.75;
						if (ClientPrefs.data.flashing)
							game.camBars.flash(FlxColor.WHITE, 1.5);
						FlxTween.tween(camHUD, {alpha: 0}, 3, {ease: FlxEase.sineInOut});

					case 228 | 260 | 292 | 286:
						game.defaultCamZoom = 1.1;

					case 230 | 262 | 296 | 312 | 236 | 268:
						game.defaultCamZoom = 0.65;

					case 232 | 264:
						if (ClientPrefs.data.flashing)
							game.camBars.flash(FlxColor.WHITE, 1.5);
						game.defaultCamZoom = 0.7;

					case 412 | 240 | 272 | 300 | 304 | 336 | 248 | 280 | 328:
						game.defaultCamZoom = 0.7;

					case 320:
						if (ClientPrefs.data.flashing)
							game.camBars.flash(FlxColor.WHITE, 1.5);
						game.defaultCamZoom = 0.7;

					case 254:
						game.defaultCamZoom = 1.1;
						FlxTween.tween(camHUD, {alpha: 1}, 1, {ease: FlxEase.sineInOut});

					case 318:
						game.defaultCamZoom = 1.25;
						FlxTween.tween(camHUD, {alpha: 1}, 1, {ease: FlxEase.sineInOut});

					case 310 | 342 | 350:
						game.defaultCamZoom = 1.25;

					case 352:
						game.defaultCamZoom = 0.65;
						FlxTween.tween(camHUD, {alpha: 0.25}, 8, {ease: FlxEase.sineInOut});
						FlxTween.tween(game, {healthThing: 0.01}, 20);
						if (game.globalGradient != null)
							FlxTween.tween(game.globalGradient, {alpha: 0.8}, 10);
						FlxTween.tween(FlxG.camera, {zoom: 1.1}, 18, {startDelay: 2});

					case 408:
						game.defaultCamZoom = 0.9;
						FlxTween.tween(camHUD, {alpha: 0.36}, 4, {ease: FlxEase.sineInOut});

					case 416: if (ClientPrefs.data.flashing) game.camBars.flash(FlxColor.WHITE, 1.5);

					case 480:
						game.boundValue = 1;
						game.drainValue = 0.02;
						if (ClientPrefs.data.flashing)
							game.camBars.flash(FlxColor.BLACK, 1.5);
						camHUD.alpha = 0;

					case 481:
						game.camFollow.x += 100;
	
					case 506:
						FlxTween.tween(camHUD, {alpha: 0.5}, 4, {ease: FlxEase.sineInOut});

					case 536:
						FlxTween.tween(camHUD, {alpha: 0}, 2, {ease: FlxEase.sineInOut});

					case 540:
						game.camBars.fade(FlxColor.BLACK, 5);
				}

				if (!ClientPrefs.data.lowQuality)
				{
					if (curBeat == 228 || curBeat == 238 || curBeat == 244 || curBeat == 252 || curBeat == 260 || curBeat == 270 || curBeat == 276 || curBeat == 284 || curBeat == 292 || curBeat == 300 || curBeat == 308 || curBeat == 316 || curBeat == 324 || curBeat == 332 || curBeat == 340 || curBeat == 248)
					{
						if (fireTweenHandler != null)
							fireTweenHandler.cancel();
						if (rainTween != null)
							rainTween.cancel();
		
						if (rain != null)
							rainTween = FlxTween.tween(rain, {alpha: 0.5}, 0.35, {ease: FlxEase.sineOut, onComplete: function(twn:FlxTween)
							{
								rainTween = null;
							}});

						fireTweenHandler = FlxTween.tween(fireThing, {alpha: 0.75, y: -250}, 0.35, {ease: FlxEase.sineOut, onComplete: function(twn:FlxTween)
							{
								fireTweenHandler = null;
							}
						});
					}
					if (curBeat == 230 || curBeat == 240 || curBeat == 248 || curBeat == 256 || curBeat == 262 || curBeat == 272 || curBeat == 280 || curBeat == 288 || curBeat == 296 || curBeat == 304 || curBeat == 312 || curBeat == 320 || curBeat == 328 || curBeat == 336 || curBeat == 344 || curBeat == 352)
					{
						if (fireTweenHandler != null)
							fireTweenHandler.cancel();
						if (rainTween != null)
							rainTween.cancel();
		
						fireTweenHandler = FlxTween.tween(fireThing, {alpha: 0.0001, y: -80}, 0.35, {ease: FlxEase.sineOut, onComplete: function(twn:FlxTween)
							{
								fireTweenHandler = null;
							}
						});

						if (rain != null)
							rainTween = FlxTween.tween(rain, {alpha: 0.0001}, 0.35, {ease: FlxEase.sineOut, onComplete: function(twn:FlxTween)
								{
									rainTween = null;
								}});
					}
					if (curBeat == 416)
					{
						if (fireTweenHandler != null)
							fireTweenHandler.cancel();
		
						fireTweenHandler = FlxTween.tween(fireThing, {alpha: 1, y: -350}, 19.5, {ease: FlxEase.sineInOut, onComplete: function(twn:FlxTween)
							{
								fireTweenHandler = null;
							}
						});
					}
					if (curBeat == 480)
					{
						if (rain != null) rain.alpha = 1;
						fireThing.alpha = 0.35;
						fireThing.y = -120;
					}
					if (curBeat == 536)
					{
						fireTweenHandler = FlxTween.tween(fireThing, {alpha: 0, y: 0}, 1, {ease: FlxEase.sineOut, onComplete: function(twn:FlxTween)
							{
								fireTweenHandler = null;
							}
						});
					}
				}
			case 'Delusional':
				var beatShit1:Array<Int> = [752, 760, 768, 772, 776, 784, 792, 800, 804, 808, 824, 836, 856, 868];
				var beatShit2:Array<Int> = [812, 828, 844, 860];
				var beatShit3:Array<Int> = [816, 832, 848, 864];
				if (curBeat == 1)
				{
					game.cinematicBarControls("create", 1);
					game.cinematicBarControls("moveboth", 0.0001, 'linear', 100);
				}
				if (curBeat == 32)
					game.cinematicBarControls("moveboth", 2, 'circOut', 120);
				if (curBeat == 64)
					game.cinematicBarControls("moveboth", 2, 'circInOut', 75);
				if (curBeat ==128 || curBeat == 1072)
					game.cinematicBarControls("moveboth", 1, "circOut", 90);
				if (curBeat == 132)
					game.cinematicBarControls("moveboth", 2, "circOut", 180);
				if (curBeat == 144)
					game.cinematicBarControls("moveboth", 0.0001, 'linear', 70);
				if (curBeat == 152 || curBeat == 168)
					game.cinematicBarControls("moveboth", 0.5, 'circOut', 80);
				if (curBeat == 154 || curBeat == 172)
					game.cinematicBarControls("moveboth", 0.5, 'circOut', 90);
				if (curBeat == 156 || curBeat == 288 || curBeat == 320)
					game.cinematicBarControls("moveboth", 0.5, 'circOut', 100);
				if (curBeat == 158 || curBeat == 296 || curBeat == 328)
					game.cinematicBarControls("moveboth", 0.5, 'circOut', 110);
				if (curBeat == 160)
					game.cinematicBarControls("moveboth", 1, 'circOut', 70);
				if (curBeat == 176)
					game.cinematicBarControls("moveboth", 2, 'circOut', 0);
				if (curBeat == 280 || curBeat == 312)
					game.cinematicBarControls("moveboth", 1.5, 'circOut', 90);
				if (curBeat == 304 || curBeat == 336 || curBeat == 356 || curBeat == 388)
					game.cinematicBarControls("moveboth", 0.5, 'circOut', 120);
				if (curBeat == 308 || curBeat == 358 || curBeat == 390)
					game.cinematicBarControls("moveboth", 0.5, 'circOut', 130);
				if (curBeat == 338)
					game.cinematicBarControls("moveboth", 1, 'circOut', 80);
				if (curBeat == 344 || curBeat == 360 || curBeat == 392)
					game.cinematicBarControls("moveboth", 1, 'circOut', 100);
				if (curBeat == 408)
					game.cinematicBarControls("moveboth", 2, 'circOut', 140);
				if (curBeat == 470)
					game.cinematicBarControls("moveboth", 0.65, 'backIn', 380);
				if (curBeat == 480)
					game.cinematicBarControls("moveboth", 10, 'linear', 70);
				if (curBeat == 744)
					game.cinematicBarControls("moveboth", 0.0001, 'linear', 120);
				for (bounceYouStupidBitch in 0...beatShit1.length)
					if (curBeat == beatShit1[bounceYouStupidBitch])
						game.cinematicBarControls("bopboth", 0.5, "circOut", 90, 30);
				for (helloEverybodyMyNameIsMarkiplierAndWelcomeToFiveNightsAtFreddysAnIndieHorrorGameThatYouGuysSuggestedInMassAndISawYamimashPlayedItAndHeSaidItWasReallyReallyGoodSoImEagerToSeeWhatIsUp in 0...beatShit2.length)
					if (curBeat == beatShit2[helloEverybodyMyNameIsMarkiplierAndWelcomeToFiveNightsAtFreddysAnIndieHorrorGameThatYouGuysSuggestedInMassAndISawYamimashPlayedItAndHeSaidItWasReallyReallyGoodSoImEagerToSeeWhatIsUp])
						game.cinematicBarControls("moveboth", 0.8, "circIn", 185);
				for (youreCringe in 0...beatShit3.length)
					if (curBeat == beatShit3[youreCringe])
						game.cinematicBarControls("moveboth", 0.8, "circOut", 120);
				if (curBeat == 872)
					game.cinematicBarControls("moveboth", 2.5, "circInOut", 180);
				if (curBeat == 880 || curBeat == 1040)
					game.cinematicBarControls("moveboth", 1, "circOut", 100);
				if (curBeat == 944 || curBeat == 1056)
					game.cinematicBarControls("moveboth", 1.5, "circOut", 120);
				if (curBeat == 1008 || curBeat == 1064)
					game.cinematicBarControls("moveboth", 1, "circOut", 140);
				if (curBeat == 1024)
					game.cinematicBarControls("moveboth", 1, "circOut", 80);
				if (curBeat == 1030)
					game.cinematicBarControls("moveboth", 1, "circOut", 100);
				if (curBeat == 1136)
					game.cinematicBarControls("kill", 0);

				if (curBeat == 146)
					game.manageLyrics('evilpredelu', 'Count the minutes...', 'disneyFreeplayFont.ttf', 30, 1.1, 'sineInOut', .05);
				if (curBeat == 150)
					game.manageLyrics('evilpredelu', "...of how long...", 'disneyFreeplayFont.ttf', 30, 1, 'sineInOut', 0.04);
				if (curBeat == 154)
					game.manageLyrics('evilpredelu', "...this show will play!", 'disneyFreeplayFont.ttf', 30, 2.2, 'quartInOut', .07);
				if (curBeat == 162)
					game.manageLyrics('evilpredelu', "And remind yourself...", 'disneyFreeplayFont.ttf', 30, 1.3, 'sineInOut', .05);
				if (curBeat == 167)
					game.manageLyrics('evilpredelu', "...no matter what's in...", 'disneyFreeplayFont.ttf', 30, 2, 'sineInOut', .06);
				if (curBeat == 174)
					game.manageLyrics('evildelu', "...THE WAY!", 'disneyFreeplayFont.ttf', 30, 1, 'circOut', .035);
				if (curBeat == 178)
					game.manageLyrics('evildelu', "All your dreams...", 'disneyFreeplayFont.ttf', 30, 1, 'sineInOut', .04);
				if (curBeat == 182)
					game.manageLyrics('evildelu', "...ARE SO FAR OUT OF REACH!", 'disneyFreeplayFont.ttf', 30, 4, 'quartInOut', .055);
				if (curBeat == 190)
					game.manageLyrics('evildelu', "But if YOUR delusions...", 'disneyFreeplayFont.ttf', 30, 2.2, 'sineInOut', .045);
				if (curBeat == 196)
					game.manageLyrics('evildelu', "...still surround ya.", 'disneyFreeplayFont.ttf', 30, 1.3, "quartOut", .045);
				if (curBeat == 200)
					game.manageLyrics('evildelu', "Let's LOOP 'ROUND ONCE MORE.", 'disneyFreeplayFont.ttf', 30, 3, "sineInOut", .065);

				switch (curBeat)
				{
					case 1: 
						game.boundValue = 1;
						game.drainValue = 0.02;
						game.camBars.fade(FlxColor.BLACK, 2, true);
					case 132: game.defaultCamZoom = 1.3;
					case 136:
						game.camBars.fade(FlxColor.BLACK, 0.6);
						for (daUIs in [camHUD])
							FlxTween.tween(daUIs, {alpha: 0}, 3);
					// BF Starts Singing Some Lyrics
					case 143:
						game.camVideo.fade(FlxColor.BLACK, 5, true);
						game.camVideo.visible = true;
						deluSing.visible = true;
						deluSing.setVideoTime(0);
						deluSing.resume();
						//it's bugged :(
						//if (game.vocals.volume != 1) game.vocals.volume = 1; // it should be fixed then
					case 144:
						game.defaultCamZoom = 0.8;
						game.camBars.fade(0x000000, 5, true);
						game.camFlashSystem(BG_DARK, {alpha: 1, timer: 0.3, ease: FlxEase.quartInOut});
						game.defaultCamZoom = 1.2;
						game.camFollow.x -= 100;
						//game.boyfriend.alpha = 0.0001;
						//FlxTween.tween(game.boyfriend, {alpha: 1}, 6, {ease: game.returnTweenEase('sineInOut')});
						FlxTween.tween(game.camFollow, {x: game.camFollow.x + 100}, 12, {ease: FlxEase.sineInOut});
					case 176:
						game.camFlashSystem(BG_DARK, {alpha: 0, timer: 0.3, ease: FlxEase.quartInOut});
						game.defaultCamZoom = 0.75;
						game.camGame.flash(FlxColor.WHITE, 1);

						// today in super r slur shit we have this cus i hate my life
						FlxTween.tween(game.camFollow, {y: game.camFollow.y - 300}, .00000001, {onComplete: bensonFromRegularShow -> {
							FlxTween.tween(game.camFollow, {y: game.camFollow.y + 300}, 7, {ease: FlxEase.sineInOut});
						}});
					case 180 | 188 | 196:
						camGame.zoom += 0.3;
						game.camFlashSystem(BG_FLASH, {alpha: 0.5, timer: 0.35});
					case 184 | 192 | 200:
						camGame.zoom += 0.15;
						game.camFlashSystem(BG_FLASH, {alpha: 0.25, timer: 0.35});
					case 204: game.defaultCamZoom = 1;
					case 208:
						game.camBars.fade(0x00000, .000001);
						game.defaultCamZoom = 1.3;

					// Mickey Screams Like A Bitch
					case 212:
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
					case 216:
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
					case 228:
						game.chromTween = null;
						game.defaultCamZoom = 0.85;
					case 230: game.defaultCamZoom = 1;
					case 232: game.defaultCamZoom = 0.75;
					case 278: game.defaultCamZoom = 1;
					case 280 | 312 | 344: game.defaultCamZoom = 0.7;
					case 288 | 296 | 304 | 320 | 328 | 336: game.defaultCamZoom += 0.1;
					case 308: game.defaultCamZoom += 0.2;
					case 340: game.defaultCamZoom += 0.3;
					case 356 | 388: game.defaultCamZoom = 1.2;
					case 358 | 390: game.defaultCamZoom = 1.3;
					case 360: game.defaultCamZoom = 0.75;
					case 375:
						game.chromTween = FlxTween.tween(game, {chromEffect: 1}, 0.1, {ease: FlxEase.sineInOut});
						game.tweenCamera(1.5, 0.1, 'sineInOut');
					case 376:
						if (game.chromTween != null) game.chromTween.cancel();
						game.chromTween = null;
						camGame.visible = false;
						game.uiGroup.visible = false;
					case 377:
						camGame.visible = true;
						game.uiGroup.visible = true;
						if (ClientPrefs.data.flashing)
							camGame.flash(FlxColor.WHITE, 1);
						game.defaultCamZoom = 0.8;
						game.chromTween = FlxTween.tween(game, {chromEffect: 0.1}, 0.6, {ease: FlxEase.quadOut});
					case 472:
						//game.useFakeDeluName = true;
						if (isStoryMode)
						{
							PlayState.detailsText = "Episode 1 - Regret (PEACEFUL)";
						}
						else
						{
							PlayState.detailsText = "Freeplay - Regret (PEACEFUL)";
						}
						PlayState.windowName = "...";
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
					case 473:
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
					case 476:
						PlayState.windowName = "Where am I...?";
						lime.app.Application.current.window.title = PlayState.windowName;
					case 480:
						PlayState.windowName = "Funkin.avi - " + (isStoryMode ? PlayState.curEpisode + " - " : "Freeplay - ") + "Regret [________]";
						lime.app.Application.current.window.title = PlayState.windowName;
						camGame.visible = true;
						game.noteGroup.visible = true;
						game.comboGroup.visible = false;
					case 484:
						PlayState.windowName = "Funkin.avi - " + (isStoryMode ? PlayState.curEpisode + " - " : "Freeplay - ") + "Regret [P_______]";
						lime.app.Application.current.window.title = PlayState.windowName;
					case 488:
						PlayState.windowName = "Funkin.avi - " + (isStoryMode ? PlayState.curEpisode + " - " : "Freeplay - ") + "Regret [PE______]";
						lime.app.Application.current.window.title = PlayState.windowName;
					case 492:
						PlayState.windowName = "Funkin.avi - " + (isStoryMode ? PlayState.curEpisode + " - " : "Freeplay - ") + "Regret [PEA_____]";
						lime.app.Application.current.window.title = PlayState.windowName;
					case 496:
						PlayState.windowName = "Funkin.avi - " + (isStoryMode ? PlayState.curEpisode + " - " : "Freeplay - ") + "Regret [PEAC____]";
						lime.app.Application.current.window.title = PlayState.windowName;
					case 500:
						PlayState.windowName = "Funkin.avi - " + (isStoryMode ? PlayState.curEpisode + " - " : "Freeplay - ") + "Regret [PEACE___]";
						lime.app.Application.current.window.title = PlayState.windowName;
					case 504:
						PlayState.windowName = "Funkin.avi - " + (isStoryMode ? PlayState.curEpisode + " - " : "Freeplay - ") + "Regret [PEACEF__]";
						lime.app.Application.current.window.title = PlayState.windowName;
					case 508:
						PlayState.windowName = "Funkin.avi - " + (isStoryMode ? PlayState.curEpisode + " - " : "Freeplay - ") + "Regret [PEACEFU_]";
						lime.app.Application.current.window.title = PlayState.windowName;
						FlxTween.tween(game.boyfriend, {alpha: 0.45}, 2.5, {ease: FlxEase.expoOut});
					case 512:
						PlayState.windowName = "Funkin.avi - " + (isStoryMode ? PlayState.curEpisode + " - " : "Freeplay - ") + "Regret [PEACEFUL]";
						lime.app.Application.current.window.title = PlayState.windowName;
					case 672:
						game.camFlashSystem(CAM_FLASH_FANCY, {alpha: 0.38, timer: 0.85, colors: [255, 255, 255]});
						minnieJumpscare.resume();
						minnieJumpscare.visible = true;
					case 720:
						FlxTween.tween(camGame, {alpha: 0.0001}, 5, {ease: FlxEase.quartInOut});
					case 728:
						PlayState.windowName = "...";
						lime.app.Application.current.window.title = PlayState.windowName;
					case 736:
						PlayState.windowName = "Welcome back.... Little mouse.";
						lime.app.Application.current.window.title = PlayState.windowName;
						PlayState.blendFlash.cameras = [camGame];
					case 740:
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
					case 744:
						//game.useFakeDeluName = false;
						if (isStoryMode)
						{
							PlayState.detailsText = "Episode 1 - " + PlayState.SONG.song + " (" + FreeplayState.getDiffRank() + ")";
						}
						else
						{
							PlayState.detailsText = "Freeplay - " + PlayState.SONG.song + " (" + FreeplayState.getDiffRank() + ")";
						}
						PlayState.windowName = "Funkin.avi - " + (isStoryMode ? PlayState.curEpisode + " - " : "Freeplay - ") + PlayState.SONG.song + " [" + FreeplayState.getDiffRank() + "]";
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
					case 880 | 884 | 888 | 892 | 896 | 900 | 904 | 908 | 913 | 916 | 920 | 924 | 929 | 933 | 936 | 940 | 944 | 948 | 952 | 956 | 960 | 964 | 968 | 972 | 976 | 980 | 984 | 988 | 993 | 997 | 1000 | 1004:
						game.camFlashSystem(CAM_FLASH_FANCY, {alpha: 0.135, timer: 0.85, colors: [255, 0, 0]});
					// The part where shit gets serious, Evilrette/Satan starts the solo
					case 1008:
						game.boundValue = 1.5;
						game.drainValue = 0.01;
						game.tweenCamera(1.35, 7, "quartInOut");
						game.camFlashSystem(CAM_FLASH_FANCY, {alpha: 0.4, timer: 2, colors: [255, 0, 0]});
						game.camFlashSystem(BG_DARK, {alpha: 0.8, timer: 6, ease: FlxEase.quartInOut});
						game.isCameraOnForcedPos = true;
						FlxTween.tween(game.camFollow, {x: game.camFollow.x + 150, y: game.camFollow.y + 50}, 4.3, {ease: FlxEase.quartInOut});
					// camera moves over to Mickey realizing he was never gonna win
					case 1024:
						FlxTween.tween(game.camFollow, {x: game.camFollow.x - 950, y: game.camFollow.y - 70}, 1.5, {ease: FlxEase.circInOut});
					case 1040:
						game.camFollow.x = 440;
						game.camFollow.y = 360;
						FlxTween.tween(mickeySpirit, {alpha: 0.6}, 2, {ease: FlxEase.sineOut});
						game.defaultCamZoom = 0.5;
						game.camFlashSystem(BG_DARK, {alpha: 0, timer: 1, ease: FlxEase.circOut});
					case 1072:
						FlxTween.tween(mickeySpirit, {alpha: 0}, 4, {ease: FlxEase.quartOut});
						game.isCameraOnForcedPos = false;
						game.defaultCamZoom = 0.9;
					case 1082:
						FlxTween.tween(camGame, {zoom: 1.6}, 1, {ease: FlxEase.sineInOut});
						game.camVideo.visible = true;
						game.camVideo.fade(FlxColor.BLACK, 0.7);
					case 1086:
						camGame.visible = false;
						FlxTween.tween(camHUD, {alpha: 0}, 2);
						game.camVideo.zoom += 0.3;
						game.camVideo.fade(FlxColor.BLACK, 0.2, true);
						FlxTween.tween(game.camVideo, {zoom: 1}, 0.5, {ease: FlxEase.sineOut});
						game.camFlashSystem(BG_DARK, {timer: 5});
						death.setVideoTime(0);
						death.resume();
						death.visible = true;
					case 1134:
						game.camFlashSystem(BG_DARK, {alpha: 1, timer: 0.5, ease: FlxEase.sineOut});
					case 1136:
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
					case 1144:
						FlxTween.tween(game.camVideo, {alpha: 0}, 4);
				}

			if ((curBeat >= 216 && curBeat < 340) || (curBeat >= 344 && curBeat < 356) || (curBeat >= 360 && curBeat < 388) || 
				(curBeat >= 392 && curBeat < 408) || (curBeat >= 880 && curBeat < 1072))
			{
				FlxG.camera.zoom += .015;
				for (mridk in [camHUD]) mridk.zoom += .03;
			}

			if (curBeat == 1)
			{
				if (rain != null) rain.alpha = 1;
			}
			if (curBeat == 64)
			{
				FlxTween.tween(fakeLightOfHope, {alpha: 0.001}, 1.7);
				if (!ClientPrefs.data.lowQuality) FlxTween.tween(stageFront, {alpha: 1}, 1.5);
			}
			if (curBeat == 176)
			{
				if (rain != null) 
				{
					rain.kill();
					rain.destroy();
					rain = null;
				}
				if (heavyRain != null && !ClientPrefs.data.lowQuality)
					heavyRain.alpha = 0.34;
			}
			if (curBeat == 280)
			{
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
			}
			if (curBeat == 312 && !ClientPrefs.data.lowQuality)
			{
				FlxTween.tween(fireThing, {alpha: 1}, 1);
				//smokeParticles.emitting = true;
			} 
			if (curBeat == 336)
			{
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
			}
			if (curBeat == 474) // load daytime street assets
			{
				colorsOrSmthElse.kill();
				colorsOrSmthElse.destroy();
				colorsOrSmthElse = null;
				//smokeParticles.emitting = false;
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
			}

			if (curBeat == 679 && !ClientPrefs.data.lowQuality)
			{
				stageCurtains.alpha = 0.0001;
				stageCurtains.visible = true;
			}

			if (curBeat == 680 || curBeat == 688 || curBeat == 696 || curBeat == 700 || curBeat == 704 || curBeat == 712 || curBeat == 720)
			{
				if (!ClientPrefs.data.lowQuality)
				{
					stageCurtains.alpha = 1;
					FlxTween.tween(stageCurtains, {alpha: 0}, 1, {ease: FlxEase.circOut});
				}
			}

			if (curBeat == 728 && !ClientPrefs.data.lowQuality)
				FlxTween.tween(stageCurtains, {alpha: 1}, 5);

			if (curBeat == 740) // go back to the street in a even more decayed state
			{
				//smokeParticles.emitting = true;
				//fireParticles.emitting = true;
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
			}
			if (curBeat == 744 || curBeat == 752 || curBeat == 760 || curBeat == 768 || curBeat == 772 || curBeat == 776 || curBeat == 784 || curBeat == 792 || curBeat == 800 || curBeat == 804 ||
				curBeat == 808 || curBeat == 816 || curBeat == 824 || curBeat == 832 || curBeat == 836 || curBeat == 840 || curBeat == 848 || curBeat == 856 || curBeat == 864 || curBeat == 868 ||
				curBeat == 880 || curBeat == 884 || curBeat == 888 || curBeat == 892 || curBeat == 896 || curBeat == 900 || curBeat == 904 || curBeat == 908 || curBeat == 913 || curBeat == 916 ||
				curBeat == 920 || curBeat == 924 || curBeat == 929 || curBeat == 933 || curBeat == 936 || curBeat == 940 || curBeat == 944 || curBeat == 948 || curBeat == 952 || curBeat == 956 ||
				curBeat == 960 || curBeat == 964 || curBeat == 968 || curBeat == 972 || curBeat == 976 || curBeat == 980 || curBeat == 984 || curBeat == 988 || curBeat == 993 || curBeat == 997 ||
				curBeat == 1000 || curBeat == 1004)
			{
				fakeLightOfHope.alpha = 1;
				FlxTween.tween(fakeLightOfHope, {alpha: 0.5}, 0.85);
			}
			if (curBeat == 872)
			{
				FlxTween.tween(fakeLightOfHope, {alpha: 1, color: FlxColor.RED}, 2, {ease: FlxEase.circInOut});
				if (!ClientPrefs.data.lowQuality) FlxTween.tween(fireThing2, {color: FlxColor.RED}, 2, {ease: FlxEase.circInOut});
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
			}
			if (curBeat == 880)
			{
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
			}
			if (curBeat == 1008)
			{
				FlxTween.tween(fakeLightOfHope, {alpha: 0}, 2);
				if (!ClientPrefs.data.lowQuality) FlxTween.tween(fireThing2, {alpha: 1}, 2);
			}
			if (curBeat == 1087)
			{
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
			//finishedScene = true;
			game.camBars.fade(FlxColor.BLACK, 0.001);
			startCountdown();
			//canSkip = false;
		});
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
			//finishedScene = true;
			//canSkip = false;
			game.camBars.fade(FlxColor.BLACK, 0.0001);
			startCountdown();
			trace("video gone");
			remove(lununuIntro);
			lununuIntro.kill();
			lununuIntro = null;
		});
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
}