package states.stages;

import states.stages.objects.*;

#if !flash 
import openfl.filters.ShaderFilter;
#end

class Episode1Street extends BaseStage
{
	// Icons for Modchart Reasons
	public var demonBFIcon:HealthIcon;
	public var lunacyIcon:HealthIcon;
	public var delusionalIcon:HealthIcon;
	public var isolatedHappy:HealthIcon;
	public var fakeBFLosingFrame:HealthIcon;
	public var demonBFScary:HealthIcon;

	var isolatedIntro:VideoSprite;

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
	 public var mickeySpirit:Character;
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
	}
	
	override function createPost()
	{
		// Hardcoded Icons
		if (PlayState.SONG.song == "Isolated")
		{
			demonBFIcon = new HealthIcon('evilcy', true, false, true, false);
			demonBFIcon.y = game.healthBar.y - 75;
			demonBFIcon.x = FlxG.width * 0.87;
			demonBFIcon.visible = false;
			game.uiGroup.add(demonBFIcon);
		
			demonBFScary = new HealthIcon('evildelu', true, false, true, false);
			demonBFScary.animation.curAnim.curFrame = 1;
			demonBFScary.y = game.healthBar.y - 75;
			demonBFScary.x = FlxG.width * 0.87;
			demonBFScary.visible = false;
			game.uiGroup.add(demonBFScary);
		
			fakeBFLosingFrame = new HealthIcon('evilrett', true, false, true, false);
			fakeBFLosingFrame.animation.curAnim.curFrame = 1;
			fakeBFLosingFrame.y = game.healthBar.y - 75;
			fakeBFLosingFrame.x = FlxG.width * 0.87;
			fakeBFLosingFrame.visible = false;
			game.uiGroup.add(fakeBFLosingFrame);
		
			isolatedHappy = new HealthIcon('lunaavier', false, false, false, true);
			isolatedHappy.animation.curAnim.curFrame = 2;
			isolatedHappy.y = game.healthBar.y - 75;
			isolatedHappy.visible = false;
			game.uiGroup.add(isolatedHappy);
			
			lunacyIcon = new HealthIcon('lunaavier', false, false, true, false);
			lunacyIcon.y = game.healthBar.y - 75;
			lunacyIcon.visible = false;
			game.uiGroup.add(lunacyIcon);
			
			delusionalIcon = new HealthIcon('deluavier', false, false, true, false);
			delusionalIcon.y = game.healthBar.y - 75;
			delusionalIcon.visible = false;
			game.uiGroup.add(delusionalIcon);
		}

		switch (PlayState.SONG.song)
		{
			case 'Isolated' | 'Lunacy':
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

		switch (PlayState.SONG.song)
		{
			case 'Isolated' | 'Lunacy':
				game.camBars.fade(FlxColor.BLACK, 0.0001);
				camHUD.alpha = 0.001;
		}
		add(tumbleGrp);
		add(atmosphereParticle);
		add(ashParticle);
		add(stageFront);

		add(rain);
		add(heavyRain);
	}

	override function update(elapsed:Float)
	{
		switch (PlayState.SONG.song)
		{
			case 'Isolated' | 'Lunacy':
				chromZoomShader.setFloat('aberration', chromEffect);
				chromZoomShader.setFloat('effectTime', chromEffect);
				chromNormalShader.setFloat('rOffset', chromEffect / 45);
				chromNormalShader.setFloat('bOffset', -chromEffect / 45);
				dramaticCamMovement.setFloat('time', shaderAnim);
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
			fakeBFLosingFrame.x = game.healthBar.x + (game.healthBar.width * (FlxMath.remapToRange(game.healthBar.percent, 0, 100, 100, 0) * 0.01)) + (150 * fakeBFLosingFrame.scale.x - 150) / 2 - game.iconOffset;
			demonBFIcon.x = game.healthBar.x + (game.healthBar.width * (FlxMath.remapToRange(game.healthBar.percent, 0, 100, 100, 0) * 0.01)) + (150 * demonBFIcon.scale.x - 150) / 2  - game.iconOffset;
			demonBFScary.x = game.healthBar.x + (game.healthBar.width * (FlxMath.remapToRange(game.healthBar.percent, 0, 100, 100, 0) * 0.01)) + (150 * demonBFScary.scale.x - 150) / 2 - game.iconOffset;
			isolatedHappy.x = game.healthBar.x + (game.healthBar.width * (FlxMath.remapToRange(game.healthBar.percent, 0, 100, 100, 0) * 0.01)) - (150 * isolatedHappy.scale.x) / 2 - game.iconOffset * 2;
			lunacyIcon.x = game.healthBar.x + (game.healthBar.width * (FlxMath.remapToRange(game.healthBar.percent, 0, 100, 100, 0) * 0.01)) - (150 * lunacyIcon.scale.x) / 2 - game.iconOffset * 2;
			delusionalIcon.x = game.healthBar.x + (game.healthBar.width * (FlxMath.remapToRange(game.healthBar.percent, 0, 100, 100, 0) * 0.01)) - (150 * delusionalIcon.scale.x) / 2 - game.iconOffset * 2;
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
						defaultCamZoom = camGame.zoom = 1.2;
						cinematicBarControls('moveboth', 0.0001, 'linear', 155);
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
						tweenCamera(1.4, 3, 'sineInOut');
						game.camFlashSystem(BG_FLASH, {alpha: 0.32, timer: 1.2, colors: [194, 194, 194]});

					case 95: 
						cameraSpeed += 3;
						isCameraOnForcedPos = true;
						camFollow.x -= 950;
						//updateSectionCamera('dad', false);

					case 96:
						isCameraOnForcedPos = false;
						cameraSpeed -= 3;
						defaultCamZoom = 0.85;
						tweenCamera(0.85, 0.4, 'expoOut');

						if (ClientPrefs.data.flashing)
							camGame.flash(FlxColor.WHITE, 1.5);
						game.camFlashSystem(BG_FLASH, {alpha: 0.4, timer: 0.35});

					case 160: 
						tweenCamera(1.3, 2, 'sineInOut');
						game.camFlashSystem(BG_DARK, {alpha: 0.85, timer: 0.5, ease: FlxEase.quartOut});

					case 184:
						game.camFlashSystem(BG_DARK, {alpha: 0.77, timer: 0.5, ease: FlxEase.quartOut});

					case 188:
						game.camFlashSystem(BG_DARK, {alpha: 0.6, timer: 0.5, ease: FlxEase.quartOut});

					case 192: 
						if (ClientPrefs.data.flashing)
							camGame.flash(FlxColor.WHITE, 1.5);
						game.camFlashSystem(BG_FLASH, {alpha: 0.32, timer: 0.35, colors: [194, 194, 194]});
						
						defaultCamZoom = 1.25;

					// same as dad
					// case 199: updateSectionCamera('bf', true);

					// update after testing without the cam thing they rarely still stunned so idk what to do lmao

					case 220: 
						tweenCamera(0.85, 2, 'sineInOut');
						game.camFlashSystem(BG_FLASH, {alpha: 0.32, timer: 0.1, colors: [194, 194, 194]});

					case 288:
						defaultCamZoom = 0.85;

						if (ClientPrefs.data.flashing)
							camGame.flash(FlxColor.WHITE, 1.5);
						game.camFlashSystem(BG_FLASH, {alpha: 0.4, timer: 0.35, colors: [194, 194, 194]});

					case 352:
						game.camFlashSystem(BG_DARK, {alpha: 0.85, timer: 0.5, ease: FlxEase.quartOut});
						tweenCamera(1.07, 5, 'quadInOut');
						cameraSpeed -= 0.25;

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
					cinematicBarControls("add", 0.0001, 'linear', 0);
					cinematicBarControls("moveboth", 0.0001, 'linear', 130);
				}
				if (curBeat == 28)
					cinematicBarControls("moveboth", 1, 'circInOut', 65);
				for (i in 0...beatBopArray.length)
					if (curBeat == beatBopArray[i])
						cinematicBarControls('bopboth', 1, 'quartOut', 32, 33);
				if (curBeat == 96)
					cinematicBarControls('moveboth', 0.3, 'sineOut', 0);
				if (curBeat == 160 || curBeat == 352)
					cinematicBarControls('moveboth', 1, 'circOut', 140);
				if (curBeat == 164 || curBeat == 180)
					cinematicBarControls('bopboth', 0.85, 'quartOut', 125, 15);
				for (i in 0...beatBopArray2.length)
					if (curBeat == beatBopArray2[i])
						cinematicBarControls('bopboth', 1, 'quartOut', 90, 60);
				if (curBeat == 192)
					cinematicBarControls('moveboth', 0.7, 'sineOut', 85);
				for (i in 0...beatBopArray3.length)
					if (curBeat == beatBopArray3[i])
						cinematicBarControls('bopboth', 0.3, 'sineOut', 40, 45);
				if (curBeat == 224)
					cinematicBarControls('moveboth', 0.3, 'quartOut', 0);
				if (curBeat == 287)
					cinematicBarControls('moveboth', 0.0001, 'linear', 100);
				if (curBeat == 288)
					cinematicBarControls('moveboth', 0.75, 'circOut', 0);
				if (curBeat == 376)
					cinematicBarControls('moveboth', 3, 'sineInOut', 0);
				if (curBeat == 415)
					cinematicBarControls('moveboth', 0.63, 'circInOut', 600);

				if ((curBeat > 96 && curBeat < 160) || (curBeat > 224 && curBeat < 352))
				{
					if (curBeat % 2 == 0)
					{
						camGame.zoom += 0.05;
						camHUD.zoom += 0.06;
					}
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
	// For events
	override function eventCalled(eventName:String, value1:String, value2:String, flValue1:Null<Float>, flValue2:Null<Float>, strumTime:Float)
	{
		switch(eventName)
		{
			case "My Event":
		}
	}
}