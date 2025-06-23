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
		light.alpha = 0.001;
		light.scrollFactor.set(0.95, 1);
		light.scale.set(2.45, 2.3);

		flair = new FlxSprite(-200, -100).loadGraphic(Paths.image(PlayState.pathway + 'lightFlair'));
		flair.blend = SCREEN;
		flair.alpha = 0.001;
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
		
		if (ClientPrefs.data.shaders)
			othershader.setFloat('iTime', shaderAnim);
	}

	// For events
	override function eventCalled(eventName:String, value1:String, value2:String, flValue1:Null<Float>, flValue2:Null<Float>, strumTime:Float)
	{
		switch(eventName)
		{
			case 'Bless Events':
				switch (flValue1)
				{
					case 1:
						FlxTween.tween(light, {alpha: .37}, 2, {ease: FlxEase.circOut});
						FlxTween.tween(flair, {alpha: .6}, 2, {ease: FlxEase.circOut});
					case 2:
						FlxTween.tween(light, {alpha: 0}, .3, {ease: FlxEase.circOut});
						FlxTween.tween(flair, {alpha: 0}, .3, {ease: FlxEase.circOut});
					case 3:
						FlxTween.tween(light, {alpha: .37}, .2, {ease: FlxEase.circOut});
						FlxTween.tween(flair, {alpha: .6}, .2, {ease: FlxEase.circOut});
					case 4:
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
					case 5:
						light.visible = true;
						flair.visible = true;
						lightI.visible = false;
						flairI.visible = false;
						game.playfieldRenderer.isInvertColors = false;
						FlxTween.tween(camHUD, {alpha: 1}, 3);
						for (blessableObjects in [game.dad, game.boyfriend, vault, chains, thingy, chains, chains2, chains3, game.iconP1, game.iconP2, game.healthBar, game.healthBarBG, game.fancyBarOverlay])
							blessableObjects.setColorTransform(1, 1, 1, 1, 0, 0, 0, 0);
						for (textShit in [game.songTxt, game.watermarkTxt, game.scoreTxt])
						{
							textShit.color = FlxColor.WHITE;
							textShit.borderColor = FlxColor.BLACK;
						}
						AppIcon.changeIcon("newIcon");
						CppAPI.darkMode();
					case 6:
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
					case 7:
						AppIcon.changeIcon("newIcon");
						CppAPI.darkMode();
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
					case 8:
						if (ClientPrefs.data.shaders)
						{
							// We make ur Laptop fry till the end of the song :fire: - MalyPlus
							camGame.setFilters([new ShaderFilter(othershader)]);
						}
					case 9:
						lightI.visible = false;
						thingy.visible = false;
						flairI.visible = false;
						game.playfieldRenderer.isInvertColors = false;
						if (ClientPrefs.data.shaders)
						{
							camGame.setFilters([]);
						}
				}
		}
	}
}