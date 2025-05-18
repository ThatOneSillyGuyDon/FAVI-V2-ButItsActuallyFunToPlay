package states.stages;

import states.stages.objects.*;

#if !flash 
import openfl.filters.ShaderFilter;
#end

class YouveBeenBlessed extends BaseStage
{
	//BLESS
	var chains:FlxSprite;
	var vault:FlxSprite;
	var thingy:FlxSprite;
	var chains2:FlxSprite;
	var chains3:FlxSprite;
	var light:FlxSprite;
	var flair:FlxSprite;
	var chainsI:FlxSprite;
	var vaultI:FlxSprite;
	var thingyI:FlxSprite;
	var chainsI2:FlxSprite;
	var chainsI3:FlxSprite;
	public static var lightI:FlxSprite;
	var flairI:FlxSprite;

	// SHADER FOR BLESS ONLY CUZ IM DUMBASS - MalyPlus
	var othershader:FlxRuntimeShader = new FlxRuntimeShader(Shaders.blessLightsShit);
	public var shaderAnim:Float = 0;

	override function create()
	{
		vault = new FlxSprite(-200, -100).loadGraphic(Paths.image(PlayState.pathway + 'vault'));
		vault.scale.set(2.45, 2.3);
		add(vault);

		chains = new FlxSprite(-225, -100).loadGraphic(Paths.image(PlayState.pathway + 'chains1'));
		chains.scale.set(2.5, 2.3);
		chains.scrollFactor.set(1.2, 1.25);
		chains2 = new FlxSprite(-225, -100).loadGraphic(Paths.image(PlayState.pathway + 'chains2'));
		chains2.scale.set(2.5, 2.3);
		chains2.scrollFactor.set(1.1, 1.2);
		chains3 = new FlxSprite(-225, -100).loadGraphic(Paths.image(PlayState.pathway + 'chains3'));
		chains3.scale.set(2.5, 2.3);
		chains3.scrollFactor.set(1, 1.15);

		light = new FlxSprite(-200, -100).loadGraphic(Paths.image(PlayState.pathway + 'lightSource'));
		light.blend = DIFFERENCE;
		light.alpha = 0.37;
		light.scrollFactor.set(0.95, 1);
		light.scale.set(2.45, 2.3);

		flair = new FlxSprite(-200, -100).loadGraphic(Paths.image(PlayState.pathway + 'lightFlair'));
		flair.blend = SCREEN;
		flair.alpha = 0.6;
		flair.scrollFactor.set(1.4, 1.25);
		flair.scale.set(2.5, 2.4);

		thingy = new FlxSprite(-200, -100).loadGraphic(Paths.image(PlayState.pathway + 'darkness'));
		thingy.scale.set(2.45, 2.3);

		lightI = new FlxSprite(-200, -100).loadGraphic(Paths.image(PlayState.pathway + 'lightInvert'));
		lightI.blend = DIFFERENCE;
		lightI.alpha = 0.37;
		lightI.scrollFactor.set(0.95, 1);
		lightI.scale.set(2.45, 2.3);
		lightI.visible = false;
		flairI = new FlxSprite(-200, -100).loadGraphic(Paths.image(PlayState.pathway + 'flairInvert'));
		flairI.blend = SCREEN;
		flairI.alpha = 0.6;
		flairI.scrollFactor.set(1.4, 1.25);
		flairI.scale.set(2.5, 2.4);
		flairI.visible = false;

		camGame.alpha = 0.001;
		camHUD.alpha = 0.001;
	}
	
	override function createPost()
	{
		game.boyfriend.setPosition(960, 530);
		if (game.dad.curCharacter == 'white-noise-new') 
			game.dad.setPosition(-680, -520); 
		else 
			game.dad.setPosition(90, 60);
		game.gf.visible = false;
		
		add(chains3);
		add(chains2);
		add(chains);
		add(light);
		add(flair);
		add(thingy);

		add(lightI);
		add(flairI);

		if (ClientPrefs.data.shaders)
		{
			camGame.setFilters(
				[
					new ShaderFilter(othershader)
				]
			);
			new flixel.util.FlxTimer().start(1, function(tmr)
				{
					camGame.setFilters([/*that's right, nothing*/]);
				});
		}
	}

	override function update(elapsed:Float)
	{
		shaderAnim = Conductor.songPosition / 1000;
		
		othershader.setFloat('iTime', shaderAnim);
	}

	
	override function beatHit()
	{
		switch (curBeat)
		{
			case 1:
				game.cinematicBarControls("create", 1);
				for (i in [light, flair])
					i.alpha = 0.001;
				FlxTween.tween(camGame, {alpha: 1}, 2);
			case 7:
				for (hud in [camHUD])
					FlxTween.tween(hud, {alpha: 1}, 3);
			case 16:
				FlxTween.tween(light, {alpha: .37}, 2, {ease: FlxEase.circOut});
				FlxTween.tween(flair, {alpha: .6}, 2, {ease: FlxEase.circOut});
			case 24 | 28 | 30 | 146 | 147 | 164 | 172 | 396 | 398 | 399 | 414 | 415 | 548 | 551 | 744 | 748:
				game.defaultCamZoom += 0.1;
			case 32 | 100 | 400:
				game.defaultCamZoom -= 0.3;
			case 48:
				game.canBopCam = true;
			case 80 | 116 | 384 | 464:
				game.canBopCam = false;
				FlxTween.tween(light, {alpha: 0}, .3, {ease: FlxEase.circOut});
				FlxTween.tween(flair, {alpha: 0}, .3, {ease: FlxEase.circOut});
				game.defaultCamZoom += 0.25;
				game.camFlashSystem(BG_DARK, {alpha: 1, timer: 0.5, ease: FlxEase.expoOut});
			case 84 | 118 | 386 | 465:
				FlxTween.tween(light, {alpha: .37}, .2, {ease: FlxEase.circOut});
				FlxTween.tween(flair, {alpha: .6}, .2, {ease: FlxEase.circOut});
				game.canBopCam = true;
				game.defaultCamZoom -= 0.25;
				game.camFlashSystem(BG_FLASH, {alpha: 1, timer: 1.5, ease: FlxEase.expoOut});
			case 99:
				game.defaultCamZoom += 0.3;
			case 148:
				game.defaultCamZoom -= 0.2;
				game.cinematicBarControls("moveboth", 2, "circOut", 90);
			case 180:
				game.defaultCamZoom -= 0.2;
			case 212:
				AppIcon.changeIcon("blessIcon");
				CppAPI.lightMode();
				for (blessableObjects in [game.dad, game.boyfriend, vault, chains, thingy, chains, chains2, chains3, game.iconP1, game.iconP2, game.healthBar, game.healthBarBG, game.fancyBarOverlay])
					blessableObjects.setColorTransform(-1, -1, -1, 1, 255, 255, 255, 0);
				for (textShit in [game.songTxt, game.watermarkTxt, game.scoreTxt])
				{
					textShit.color = FlxColor.BLACK;
					textShit.borderColor = FlxColor.WHITE;
				}
				light.visible = false;
				flair.visible = false;
				lightI.visible = true;
				flairI.visible = true;
				game.playfieldRenderer.isInvertColors = true;
				game.camBars.flash(FlxColor.BLACK, 2);
				game.cinematicBarControls("moveboth", 1.2, 'expoOut', 130);
				game.canBopCam = false;
			case 220 | 228 | 236 | 244 | 252 | 260 | 268 | 284 | 292 | 300 | 308 | 316 | 324 | 332 | 484 | 488 | 492 | 496 | 500 | 504 | 508 | 516 | 520 | 524 | 528 | 532 | 536 | 540:
				game.camFlashSystem(BG_FLASH, {alpha: 0.45, timer: 1});
			case 276:
				game.camFlashSystem(BG_FLASH, {alpha: 0.45, timer: 1});
				game.canBopCam = true;
			case 340:
				camGame.visible = false;
				for (i in [camHUD])
					FlxTween.tween(i, {alpha: 0}, 1);
			case 348:
				light.visible = true;
				flair.visible = true;
				lightI.visible = false;
				flairI.visible = false;
				game.playfieldRenderer.isInvertColors = false;
				for (i in [camHUD])
					FlxTween.tween(i, {alpha: 1}, 3);
				for (blessableObjects in [game.dad, game.boyfriend, vault, chains, thingy, chains, chains2, chains3, game.iconP1, game.iconP2, game.healthBar, game.healthBarBG, game.fancyBarOverlay])
					blessableObjects.setColorTransform(1, 1, 1, 1, 0, 0, 0, 0);
				for (textShit in [game.songTxt, game.watermarkTxt, game.scoreTxt])
				{
					textShit.color = FlxColor.WHITE;
					textShit.borderColor = FlxColor.BLACK;
				}
				AppIcon.changeIcon("newIcon");
				CppAPI.darkMode();
			case 352:
				camGame.visible = true;
				game.defaultCamZoom = 0.9;
				game.camVideo.visible = false;
				camGame.zoom += 0.15;
				game.camFlashSystem(CAM_FLASH_FANCY, {alpha: 0.7, timer: 0.25});
				game.cinematicBarControls("moveboth", 1.2, "expoOut", 0);
			case 416:
				game.isCameraOnForcedPos = true;
				game.camFollow.x = 450;
				game.camFollow.y = 250;
				game.defaultCamZoom = 0.5;
			case 480:
				AppIcon.changeIcon("blessIcon");
				CppAPI.lightMode();
				game.defaultCamZoom = 0.95;
				game.camFollow.x = 0;
				game.camFollow.y = 0;
				game.isCameraOnForcedPos = false;
				for (blessableObjects in [game.dad, game.boyfriend, vault, chains, thingy, chains, chains2, chains3, game.iconP1, game.iconP2, game.healthBar, game.healthBarBG, game.fancyBarOverlay])
					blessableObjects.setColorTransform(-1, -1, -1, 1, 255, 255, 255, 0);
				for (textShit in [game.songTxt, game.watermarkTxt, game.scoreTxt])
				{
					textShit.color = FlxColor.BLACK;
					textShit.borderColor = FlxColor.WHITE;
				}
				light.visible = false;
				flair.visible = false;
				lightI.visible = true;
				flairI.visible = true;
				game.playfieldRenderer.isInvertColors = true;
				game.camBars.flash(FlxColor.BLACK, 2);
				game.cinematicBarControls("moveboth", 1.5, 'sineout', 130);
			case 544:
				game.canBopCam = false;
				AppIcon.changeIcon("newIcon");
				CppAPI.darkMode();
				game.cinematicBarControls("moveboth", 2.5, 'circOut', 0);
				for (blessableObjects in [game.dad, game.boyfriend, vault, chains, thingy, chains, chains2, chains3, game.iconP1, game.iconP2, game.healthBar, game.healthBarBG, game.fancyBarOverlay])
					FlxTween.tween(blessableObjects.colorTransform, {
						redOffset: 0,
						blueOffset: 0,
						greenOffset: 0,
						redMultiplier: 1,
						blueMultiplier: 1,
						greenMultiplier: 1
					}, 2, {ease: FlxEase.quartOut});
				for (textShit in [game.songTxt, game.watermarkTxt, game.scoreTxt])
				{
					textShit.color = FlxColor.WHITE;
					textShit.borderColor = FlxColor.BLACK;
					textShit.alpha = 0;
					FlxTween.tween(textShit, {alpha: 1}, 2, {ease: FlxEase.quartOut});
				}
			case 552:
				game.canBopCam = true;
				game.defaultCamZoom -= 0.2;
				game.camBars.flash(FlxColor.WHITE, 2);
				if (ClientPrefs.data.shaders)
				{
					// We make ur Laptop fry till the end of the song :fire: - MalyPlus
					camGame.setFilters([new ShaderFilter(othershader)]);
				}
			case 620:
				lightI.visible = false;
				thingy.visible = false;
				flairI.visible = false;
				game.canBopCam = false;
				game.playfieldRenderer.isInvertColors = false;
				game.camBars.flash(FlxColor.BLACK, 3);
				if (ClientPrefs.data.shaders)
				{
					camGame.setFilters([]);
				}
				game.camFlashSystem(BG_DARK, {alpha: 0.85, timer: 0.0001, ease: FlxEase.expoOut});
				game.cinematicBarControls("moveboth", 1.5, 'sineout', 60);
				game.cameraSpeed = 0.6;
			case 684:
				game.canBopCam = true;
			case 752:
				game.camBars.flash(FlxColor.WHITE, 2);
				for (cam in [camGame, camHUD])
					cam.visible = false;
		}
	}
}