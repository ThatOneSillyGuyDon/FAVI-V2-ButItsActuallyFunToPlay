package gameObjects.stages;

#if !flash 
import openfl.filters.ShaderFilter;
#end

class AbandonedStreet extends BaseStage
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
	public static var fakeLightOfHope:FlxSprite;
	public static var fireThing:FlxSprite;
	public static var fireForeground:FlxSprite;
	public static var fireTweenHandler:FlxTween;
	public static var rainTween:FlxTween;
	public static var mickeySpirit:Character;
	public static var memoryMickey:Character;
	public static var smokeShit:FlxTypedGroup<FlxSprite>;
	public static var smokeFore:FlxTypedGroup<FlxSprite>;
	public static var spriteShit:Array<String> = ['smokeBBack', 'smokeTBack'];
	public static var spriteShitForeground:Array<String> = ['smokeBFore', 'smokeTFore'];
	  
	// Mickey being delusional and minnie appearing Scene For Delusional aaaa
	public static var minnieBackground:FlxSprite; 
	public static var totallyanoriginalname:FlxSprite; // .. i have no idea what to say

	//Shader stuff
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

	var mickeyShader = new DropShadowShader();
	var satanShader = new DropShadowShader();

	public static var pathWay:String;
	var blackBG:FlxSprite;
	public static var newTextShi:FlxText;
	public static var satzText:FlxText;

	// SEE MY VISION RAGH
	var anniversaryArray:Array<String> = [
		'',
		'And Here Lies Mickey Mouse',
		'Stuck in an endless cycle',
		'of dying over and over again.',
		'No matter what he does',
		'the poor little mouse',
		'Just cant find a way to save himself',
		'from this cruel and unusual pugatory!',
		'Pfh, you should just give up now, mouse.',
		"Need I remind you of what you've lost?",
		"What you've RUINED?",
		''
	];
	var fuckingManage:Int = 0;


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

		if (PlayState.SONG.song == 'Delusional')
		{	
			fakeLightOfHope = new FlxSprite(-990, 1600).loadGraphic(Paths.image(PlayState.pathway + 'falseHope'));
			fakeLightOfHope.setGraphicSize(Std.int(fakeLightOfHope.width * 4));
			fakeLightOfHope.updateHitbox();
			fakeLightOfHope.antialiasing = ClientPrefs.data.antialiasing;
			fakeLightOfHope.screenCenter();
			fakeLightOfHope.scale.set(3, 3);
			fakeLightOfHope.scrollFactor.set(0.9, 0.9);
			add(fakeLightOfHope);
		}

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
		if (!ClientPrefs.data.lowQuality && PlayState.SONG.song == 'Delusional'){
			mickeySpirit = new Character(-200, -700, "avier-bg");
			mickeySpirit.alpha = 0.0001;
			add(mickeySpirit);
		}

		floor = new FlxSprite(-20, 200).loadGraphic(Paths.image(PlayState.pathway + 'street'));
		floor.antialiasing = ClientPrefs.data.antialiasing;
		floor.scale.set(2.8, 2.5);
		floor.scrollFactor.set(1, 1);
		floor.active = false;
		add(floor);	
		
		if (!ClientPrefs.data.lowQuality && PlayState.SONG.song == "Delusional" || PlayState.SONG.song == 'delusional-anniversary')
		{
			lightning = new FlxSprite(-25, -175);
			lightning.frames = Paths.getSparrowAtlas(PlayState.pathway + "lightning");
			lightning.antialiasing = ClientPrefs.data.antialiasing;
			lightning.animation.addByPrefix('boom', 'lightning1', 12);
			lightning.animation.addByPrefix('boom2', 'lightning2', 12);
			lightning.scale.set(2, 2);
			lightning.scrollFactor.set(0.8, 0.8);
			add(lightning);
		}

		if (PlayState.SONG.song == "Delusional" || PlayState.SONG.song == 'delusional-anniversary')
		{
			memoryMickey = new Character(575, 50, "Mickey-Bedroom", true);
			memoryMickey.alpha = 0.0001;
			memoryMickey.cameras = [game.camVideo];
			add(memoryMickey);

			// Bedroom Grah :fire: - MalyPlus
			minnieBackground = new FlxSprite(-20, 200).loadGraphic(Paths.image(PlayState.pathway + 'background'));
			minnieBackground.scale.set(2,2);
			minnieBackground.scrollFactor.set(1, 1);
			minnieBackground.antialiasing = ClientPrefs.data.antialiasing;
			minnieBackground.visible = false;
			add(minnieBackground);


			if (!ClientPrefs.data.lowQuality)
			{
				totallyanoriginalname = new FlxSprite(-20, 200).loadGraphic(Paths.image(PlayState.pathway + 'shading'));
				totallyanoriginalname.scale.set(2,2);
				totallyanoriginalname.scrollFactor.set(1,1);
				totallyanoriginalname.visible = false;
				totallyanoriginalname.antialiasing = ClientPrefs.data.antialiasing;
				add(totallyanoriginalname);

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

			if (PlayState.SONG.song != "Isolated")
			{
				rain = new FlxSprite(-550, -900);
				rain.frames = Paths.getSparrowAtlas(PlayState.pathway + 'rain');
				rain.animation.addByPrefix('drippin', 'Rain', 30, true);
				rain.scale.set(2, 2);
				rain.antialiasing = ClientPrefs.data.antialiasing;
				rain.alpha = 0.0001;
				rain.animation.play('drippin');

				if (PlayState.SONG.song == "Delusional" || PlayState.SONG.song == 'delusional-anniversary')
				{
					heavyRain = new FlxSprite(-550, -900);
					heavyRain.frames = Paths.getSparrowAtlas(PlayState.pathway + 'heavyRain');
					heavyRain.animation.addByPrefix('god is pissing omg', 'Rain full', 30, true);
					heavyRain.scale.set(2, 2);
					heavyRain.antialiasing = ClientPrefs.data.antialiasing;
					heavyRain.alpha = 0.0001;
					heavyRain.animation.play('god is pissing omg');
				}
			}
		}
		if (PlayState.SONG.song == "Delusional" || PlayState.SONG.song == 'delusional-anniversary'){
			blackBG = new FlxSprite().makeGraphic(3200,2000, FlxColor.BLACK);
			add(blackBG);
			blackBG.alpha=0.001;
			blackBG.scrollFactor.set(0,0);
			blackBG.screenCenter();
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
			case "Delusional":
				death = makeVideo(death, "mickeyDeath");
				add(death);
				
				deluSing = makeVideo(deluSing, "deluLyrics");
				add(deluSing);
				
				minnieJumpscare = makeVideo(minnieJumpscare, "minniePart");
				add(minnieJumpscare);
		}
		
		if (ClientPrefs.data.shaders)
		{
			switch (PlayState.SONG.song)
			{
				case 'Isolated' | 'Lunacy' | 'Delusional':
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

		if (PlayState.SONG.song == 'Delusional')
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

				for (s in [mickeyShader,satanShader])
				{
					s.setAdjustColor(-60, -32, -20, -25);
					s.color = 0xFFFFFFFF;
					s.distance = 30;
					s.maskThreshold = 0.75;
				}

				mickeyShader.angle = 40;
				satanShader.angle = 140;
			}
		}

		add(atmosphereParticle);
		add(ashParticle);
		add(stageFront);

		if (PlayState.SONG.song == "Delusional")
		{
			if (!ClientPrefs.data.lowQuality)
			{
				stageFront.y -= 250;
				stageFront.alpha = 0.001;
				floor.alpha = 0.001;
			}
			game.camBars.fade(0x000000, .0001);
			// i dont know what caused to Manage Lyrics to happen but, new text for this only ^^
			// also blame goober for everything actually
				newTextShi = new FlxText(0,((ClientPrefs.data.downScroll) ? -100 :Std.int(FlxG.height + 100))).setFormat("disneyFreeplayFont.ttf", 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				newTextShi.scrollFactor.set(0,0);
				newTextShi.text = anniversaryArray[8];
				add(newTextShi);
				newTextShi.alpha = 0.0001;
				newTextShi.cameras = [camOther];

				satzText = new FlxText(0,((ClientPrefs.data.downScroll) ? -100 :Std.int(FlxG.height + 100))).setFormat("disneyFreeplayFont.ttf", 32, FlxColor.RED, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				satzText.scrollFactor.set(0,0);
				satzText.text = anniversaryArray[8];
				add(satzText);
				satzText.alpha = 0.0001;
				satzText.cameras = [camOther];
			
		}

		add(rain);
		add(heavyRain);

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

	override function update(elapsed:Float)
	{
		shaderAnim = Conductor.songPosition / 1000;
		
		switch (PlayState.SONG.song)
		{
			case 'Isolated' | 'Lunacy' | 'Delusional':
				if (ClientPrefs.data.shaders)
				{
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

	override function eventPushedUnique(event:EventNote)
	{
		// preload the ruined street asset
		switch(event.event)
		{ 
			case 'Delusional Events':
				var eventData:Float = Std.parseFloat(event.value1);
				switch (eventData)
				{
					case 24: Paths.image(PlayState.pathway + "streetDestroyed");
				}
		}
	}
	var g_:Int = 0;

	// For events
	override function eventCalled(eventName:String, value1:String, value2:String, flValue1:Null<Float>, flValue2:Null<Float>, strumTime:Float)
	{
		switch(eventName)
		{
			case 'Toggle Shadow Drop':
				if (!ClientPrefs.data.lowQuality)
				{
					game.dad.shader = game.dad.shader == mickeyShader ? null : mickeyShader;
					game.boyfriend.shader = game.boyfriend.shader == satanShader ? null : satanShader;

					mickeyShader.attachedSprite = game.dad;
					satanShader.attachedSprite = game.boyfriend;

					game.dad.animation.onFrameChange.add(function(name, frameNum, frameIndex) { //this took fucking ages to figure out only to realize i'm a stupid fucking moron (don)
					mickeyShader.updateFrameInfo(game.dad.frame);
					});
					game.boyfriend.animation.onFrameChange.add(function(name, frameNum, frameIndex) {
						satanShader.updateFrameInfo(game.boyfriend.frame);
					});
				}
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
			case 'Delusional Events':
				var eventData:Float = Std.parseFloat(value1);
				switch (eventData)
				{
					case 1:
						if (rain != null) rain.alpha = 1;
						game.boundValue = 1;
						game.drainValue = 0.02;
					case 2:
						game.camVideo.fade(FlxColor.BLACK, 5, true);
						game.camVideo.alpha = 1;
						deluSing.visible = true;
						deluSing.play();
						//I FIXED IT!!!!!!!!!!!!!!!!!! :)
						if (PlayState.instance.vocals.volume != 1) PlayState.instance.vocals.volume = 1; // it should be fixed then
					case 3:
						//Stuff For the Rain
						if (rain != null) 
						{
							rain.kill();
							rain.destroy();
							rain = null;
						}
						if (heavyRain != null && !ClientPrefs.data.lowQuality)
							heavyRain.alpha = 0.21;
					case 4:
						game.camVideo.alpha = 0.0001;
						game.boundValue = 0.6;
						game.drainValue = 0.025;
						game.chromEffect = 0.3;
						game.chromTween = FlxTween.tween(game, {chromEffect: 1}, 1.2);
						game.camBars.fade(0x00000, .000001, true);
						game.defaultCamZoom = 0.75;
						camGame.shake(0.01, 1.2);
						camGame.visible = true;
						camGame.alpha = 1;
					case 5:
						if (game.chromTween != null) game.chromTween.cancel();
						game.chromTween = FlxTween.tween(game, {chromEffect: 0.18}, 0.6, {ease: FlxEase.sineOut});
						game.camVideo.alpha = 0.0001;
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
									new ShaderFilter(chromNormalShader), 
									new ShaderFilter(delusionalShift)]);
                            }
						}
					case 6:
						game.chromTween = null;
					case 7:
						game.chromTween = FlxTween.tween(game, {chromEffect: 1}, 0.1, {ease: FlxEase.sineInOut});
					case 8:
						if (game.chromTween != null) game.chromTween.cancel();
						game.chromTween = null;
					case 9:
						game.chromTween = FlxTween.tween(game, {chromEffect: 0.1}, 0.6, {ease: FlxEase.quadOut});
					case 10:
						game.boundValue = 2;
						game.drainValue = 0;
						if (!ClientPrefs.data.lowQuality)
						{
							atmosphereParticle.visible = false;
							ashParticle.visible = false;
						}
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
						PlayState.useFakeDeluName = true;
						game.chromEffect = 0.00001;
						dad.alpha = 0.0001;

						game.boyfriend.x += 1000;
						boyfriend.alpha = 0.0001;
					case 11:
						FlxTween.tween(boyfriend, {alpha: 0.45}, 2.5, {ease: FlxEase.expoOut});
					case 12:
						minnieJumpscare.play();
						minnieJumpscare.visible = true;
						game.boyfriend.alpha = 0.0001; 
					case 57:
						var previousY:Int = Std.int(boyfriend.y);
						if (blackBG.alpha == 0.001){
							blackBG.alpha = 1;
							boyfriend.y = previousY + 50; 
							FlxTween.tween(boyfriend, {alpha: 1, y:previousY}, 2.4, {ease: FlxEase.expoOut});
							FlxTween.tween(camGame, {alpha: 1}, 2.4);

						} 
						else {
							blackBG.alpha =0;
						}
					case 50: // doing ts cause lazy
						FlxTween.tween(boyfriend, {alpha: 0.001}, 11, {ease: FlxEase.cubeInOut});

					case 53:
						dad.alpha = 1; 
						blackBG.alpha = 0;
					case 13:
						dad.alpha = 1;
						blackBG.alpha = 0;
						game.chromEffect = 0.1;
						game.boundValue = 0.45;
						game.drainValue = 0.032;
						PlayState.useFakeDeluName = false;
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
                                camHUD.setFilters([new ShaderFilter(chromNormalShader), new ShaderFilter(delusionalShift)]);
                            }
                            else
                            {
                                camGame.setFilters([
                                    new ShaderFilter(monitorFilter),
                                    new ShaderFilter(chromZoomShader),
                                    new ShaderFilter(chromNormalShader),
                                    new ShaderFilter(delusionalShift)
                                ]);
                                camHUD.setFilters([new ShaderFilter(chromNormalShader), new ShaderFilter(delusionalShift)]);
                            }
						}
					case 14:
						FlxTween.tween(mickeySpirit, {alpha: 0.6}, 2, {ease: FlxEase.sineOut});
					case 15:
						FlxTween.tween(mickeySpirit, {alpha: 0}, 4, {ease: FlxEase.quartOut});
					
					case 16:
						FlxTween.tween(fakeLightOfHope, {alpha: 0.001}, 1.7);
						FlxTween.tween(floor, {alpha: 1}, 1.7);
						if (!ClientPrefs.data.lowQuality) FlxTween.tween(stageFront, {alpha: 1}, 1.5);
					
					case 17:
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

					case 18:
						if (!ClientPrefs.data.lowQuality)
						{
							FlxTween.tween(fireThing, {alpha: 1}, 1);
						}
					case 19:
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
					case 20:
						colorsOrSmthElse.kill();
						colorsOrSmthElse.destroy();
						colorsOrSmthElse = null;
						if (!ClientPrefs.data.lowQuality)
						{
							fireThing.visible = false;
							smokeShit.forEach(function(spr:FlxSprite)
							{
								spr.visible = false;
							});
							smokeFore.forEach(function(spr:FlxSprite)
							{
								spr.visible = false;
							});
							heavyRain.visible = false;
							totallyanoriginalname.visible = true;
							stageCurtains.visible = false;
							stageFront.kill();
							stageFront.destroy();
							stageFront = null;
						}
						floor.visible = false;
						minnieBackground.visible = false; // not gonna be used for this ok
					case 21:
						if (!ClientPrefs.data.lowQuality)
						{
							stageCurtains.alpha = 0.0001;
							stageCurtains.visible = true;
						}
					case 22:
						if (!ClientPrefs.data.lowQuality)
						{
							stageCurtains.alpha = 1;
							FlxTween.tween(stageCurtains, {alpha: 0}, 1, {ease: FlxEase.circOut});
						}
					case 23:
						if (!ClientPrefs.data.lowQuality)
							FlxTween.tween(stageCurtains, {alpha: 1}, 5);
					case 24:
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
							fireThing.visible = true;
							fireThing.alpha = 0.55;
						}
						floor.loadGraphic(Paths.image(PlayState.pathway + "streetDestroyed"));
						floor.visible = true;
						fakeLightOfHope.alpha = 0.5;
						minnieBackground.kill();
						minnieBackground.destroy();
						minnieBackground = null;
					case 25:
						fakeLightOfHope.alpha = 1;
						FlxTween.tween(fakeLightOfHope, {alpha: 0.5}, 0.85);
					case 26:
						FlxTween.tween(fakeLightOfHope, {alpha: 1, color: FlxColor.RED}, 2, {ease: FlxEase.circInOut});
						if (!ClientPrefs.data.lowQuality) 
							FlxTween.tween(fireThing, {color: FlxColor.RED}, 2, {ease: FlxEase.circInOut});
						FlxTween.tween(floor, {color: FlxColor.RED}, 2, {ease: FlxEase.circInOut});
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
					case 27:
						FlxTween.tween(fakeLightOfHope, {color: FlxColor.WHITE}, 0.5, {ease: FlxEase.circOut});
						if (!ClientPrefs.data.lowQuality) FlxTween.tween(fireThing, {color: FlxColor.WHITE, alpha: 0.75}, 1.2, {ease: FlxEase.circOut});
						FlxTween.tween(floor, {color: FlxColor.WHITE}, 0.5, {ease: FlxEase.circOut});
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
					case 28:
						FlxTween.tween(fakeLightOfHope, {alpha: 0}, 2);
						if (!ClientPrefs.data.lowQuality) FlxTween.tween(fireThing, {alpha: 1}, 2);
					case 29:
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
							fireThing.kill();
							fireThing.destroy();
							fireThing = null;
							heavyRain.kill();
							heavyRain.destroy();
							heavyRain = null;
							stageCurtains.visible = true;
						}
						floor.kill();
						floor.destroy();
						floor = null;
						fakeLightOfHope.kill();
						fakeLightOfHope.destroy();
						fakeLightOfHope = null;
					case 30:
						game.camVideo.zoom += 0.3;
						game.camVideo.fade(FlxColor.BLACK, 0.2, true);
						FlxTween.tween(game.camVideo, {zoom: 1}, 0.5, {ease: FlxEase.sineOut});
						death.play();
						death.visible = true;
					case 60:
						newTextShi.y = ((ClientPrefs.data.downScroll) ? -100 :Std.int(FlxG.height + 100));
						satzText.y = ((ClientPrefs.data.downScroll) ? -100 :Std.int(FlxG.height + 100));
						fuckingManage++;
						newTextShi.alpha = 0.001;
						newTextShi.text = anniversaryArray[fuckingManage];
						satzText.text = anniversaryArray[fuckingManage];
						newTextShi.screenCenter(X);
						satzText.screenCenter(X);

						FlxTween.tween(newTextShi, {y: ((ClientPrefs.data.downScroll) ? 100 :Std.int(FlxG.height - 100)),alpha:1}, 0.4, {ease: FlxEase.quadInOut});	
						FlxTween.tween(satzText, {y: ((ClientPrefs.data.downScroll) ? 100 :Std.int(FlxG.height - 100))}, 0.4, {ease: FlxEase.quadInOut});	
						if (anniversaryArray[fuckingManage] == 'Pfh, you should just give up now, mouse.') FlxTween.tween(satzText, {alpha:1}, 2, {ease: FlxEase.quadInOut});	

					case 61: 
						g_++;
						var fuckassBlastMemoryFuckYou:FlxSprite = new FlxSprite(0,200).loadGraphic(Paths.image(PlayState.pathway + value2));
						add(fuckassBlastMemoryFuckYou);
						fuckassBlastMemoryFuckYou.scale.set(0.6,0.6);
						fuckassBlastMemoryFuckYou.updateHitbox();
						if (g_ % 2 == 0)fuckassBlastMemoryFuckYou.x += 900;
						else fuckassBlastMemoryFuckYou.x -= 200;
						fuckassBlastMemoryFuckYou.y -= 140;
						FlxTween.tween(fuckassBlastMemoryFuckYou, {alpha: 0}, 4, {ease:FlxEase.sineInOut, onComplete: function(_:FlxTween){
							fuckassBlastMemoryFuckYou.destroy();
							remove(fuckassBlastMemoryFuckYou);
						}});
					case 62:
						if (game.camVideo.visible)
							game.camVideo.visible = false;
						else
							game.camVideo.visible = true;
					case 63:
						var fuckassBlastMemoryFuckYou:FlxSprite = new FlxSprite(200,200).loadGraphic(Paths.image(PlayState.pathway + "AHHH_FUCK_YOU_MINNIE"));
						add(fuckassBlastMemoryFuckYou);
						fuckassBlastMemoryFuckYou.alpha = 0.001;
						fuckassBlastMemoryFuckYou.scale.set(0.6,0.6);
						fuckassBlastMemoryFuckYou.updateHitbox();
						fuckassBlastMemoryFuckYou.y -= 140;
						FlxTween.tween(fuckassBlastMemoryFuckYou, {alpha: 1}, 4, {ease:FlxEase.sineInOut, onComplete: function(_:FlxTween){
							FlxTween.tween(fuckassBlastMemoryFuckYou, {alpha:0}, 2, {ease:FlxEase.sineInOut, onComplete: function(__:FlxTween){
								fuckassBlastMemoryFuckYou.destroy();
								remove(fuckassBlastMemoryFuckYou);
							}});
						}}); 
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

	function lightningStrike()
	{
		lightning.alpha = 1;
		if (FlxG.random.bool(50))
			lightning.animation.play('boom');
		else
			lightning.animation.play('boom2');
		new FlxTimer().start(1.5, function(tmr:FlxTimer) {lightning.alpha = 0.001;});
	}

	function lightningStrikeFore()
	{
		lightningFore.alpha = 1;
		if (FlxG.random.bool(50))
			lightningFore.animation.play('boom');
		else
			lightningFore.animation.play('boom2');
		new FlxTimer().start(1.5, function(tmr:FlxTimer) {lightningFore.alpha = 0.001;});
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
			case 'Lunacy' | 'Delusional':
				if (ClientPrefs.data.mechanics)
				{
					if (game.healthThing > game.boundValue)
						game.healthThing -= game.drainValue;
				}
		}

		// forces the 3rd character in the background in Delusional to work
		if(mickeySpirit != null && PlayState.SONG.song == "Delusional")
		{
			mickeySpirit.playAnim(game.singAnimations[Std.int(Math.abs(Math.min(game.singAnimations.length-1, note.noteData)))], true);
			mickeySpirit.holdTimer = 0;
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
}