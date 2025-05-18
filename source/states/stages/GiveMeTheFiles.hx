package states.stages;

import states.stages.objects.*;

class GiveMeTheFiles extends BaseStage
{
	//WAR DILEMMA
	var defaultPath:String = 'favi/stages/war/stuff/';
	
	override function create()
	{
		game.defaultCamZoom = .6;
		game.cameraSpeed = .67;
	
		var sky = new FlxSprite(-1280 * defaultCamZoom, -720 * defaultCamZoom, Paths.image(defaultPath + 'sky'));
		sky.scrollFactor.set(.07, .05);
		add(sky);
	
		if (!ClientPrefs.data.lowQuality)
		{
			var sun = new FlxSprite(-1280 * defaultCamZoom, -720 * defaultCamZoom, Paths.image(defaultPath + 'sun'));
			sun.scrollFactor.set(.22, .12);
			sun.y += 200;
			add(sun);
		
			var bg = new FlxSprite(-1280 * defaultCamZoom, -720 * defaultCamZoom, Paths.image(defaultPath + 'bg'));
			bg.scrollFactor.set(.32, .27);
			bg.x += 150;
			bg.y += 250;
			add(bg);
		
			var semibg = new FlxSprite(-1280 * defaultCamZoom, -720 * defaultCamZoom, Paths.image(defaultPath + 'semibackground'));
			semibg.scrollFactor.set(.52, .48);
			semibg.scale.set(1.23, 1.23);
			semibg.updateHitbox();
			add(semibg);
		}
	
		var things = new FlxSprite(-1280 * defaultCamZoom, (-720 * defaultCamZoom) + 150, Paths.image(defaultPath + 'things'));
		things.scrollFactor.set(.73, .64);
		things.scale.set(1.25, 1.25);
		things.updateHitbox();
		add(things);

		if (!ClientPrefs.data.lowQuality)
		{
			var grassBack = new FlxSprite(-1280 * defaultCamZoom, -720 * defaultCamZoom, Paths.image(defaultPath + "groundBack"));
			grassBack.scrollFactor.set(.86, .76);
			grassBack.scale.set(1.3, 1.3);
			grassBack.y += 70;
			grassBack.updateHitbox();
			add(grassBack);
		}
	
		var ground = new FlxSprite(-1280 * defaultCamZoom, -720 * defaultCamZoom, Paths.image(defaultPath + 'ground'));
		ground.scrollFactor.set(1, 1);
		ground.scale.set(1.35, 1.35);
		ground.updateHitbox();
		add(ground);

		if (!ClientPrefs.data.lowQuality)
		{
			var goofy = new FlxSprite(-1280 * defaultCamZoom, -720 * defaultCamZoom, Paths.image(defaultPath + "goofySpot"));
			goofy.scrollFactor.set(1, 1);
			goofy.scale.set(1.35, 1.35);
			goofy.updateHitbox();
			add(goofy);

			var mickey = new FlxSprite(-1280 * defaultCamZoom, -720 * defaultCamZoom, Paths.image(defaultPath + "mickeySpot"));
			mickey.scrollFactor.set(1, 1);
			mickey.scale.set(1.35, 1.35);
			mickey.updateHitbox();
			add(mickey);
		}
		camHUD.alpha = 0.001;
	}
	
	override function createPost()
	{
		game.dad.setPosition(-140, 80);
   	 	game.boyfriend.setPosition(1500, 650);
		game.gf.visible = false;
		
		if (!ClientPrefs.data.lowQuality)
		{
			var fore = new FlxSprite(-1280 * defaultCamZoom, -720 * defaultCamZoom, Paths.image(defaultPath + "grassFore"));
			fore.scale.set(1.4, 1.4);
			fore.scrollFactor.set(1.15, 1.15);
			fore.y -= 180;
			fore.x -= 80;
			fore.updateHitbox();
			add(fore);
		}

		game.cinematicBarControls("create", 1);
		game.cinematicBarControls("moveboth", 0.0001, 'linear', 420);
		camHUD.alpha = 0.001;
	}

	var cinematicValue:Float = 0;
	override function stepHit()
	{
		switch (curStep)
		{
			case 1:
				game.defaultCamZoom += 0.5;
				game.cinematicBarControls("moveboth", 2, "backOut", 180);
				if (!ClientPrefs.data.downScroll && ClientPrefs.data.mechanics) 
				{
					for (ui in [game.healthBar, game.healthBarBG, game.scoreTxt, game.iconP1, game.iconP2])
						FlxTween.tween(ui, {y: ui.y - 120, "scale.x": 0.7, "scale.y": 0.7}, 1, {ease: FlxEase.backOut});
					FlxTween.tween(game.fancyBarOverlay, {y: game.fancyBarOverlay.y - 103, "scale.x": 0.7, "scale.y": 0.7}, 1, {ease: FlxEase.backOut});
				}
				if (ClientPrefs.data.downScroll && ClientPrefs.data.mechanics)
				{
					for (ui in [game.healthBar, game.healthBarBG, game.scoreTxt, game.iconP1, game.iconP2])
						FlxTween.tween(ui, {"scale.x": 0.7, "scale.y": 0.7}, 1, {ease: FlxEase.backOut});
					FlxTween.tween(game.fancyBarOverlay, {y: game.fancyBarOverlay.y - 15, "scale.x": 0.7, "scale.y": 0.7}, 1, {ease: FlxEase.backOut});
				}
				FlxTween.tween(camHUD, {alpha: 1}, 1, {ease: FlxEase.sineOut});
		}
	}
	override function beatHit()
	{
		switch (curBeat)
		{
			case 16:
				if (!ClientPrefs.data.downScroll && ClientPrefs.data.mechanics)
				{
					for (ui in [game.healthBar, game.healthBarBG, game.fancyBarOverlay, game.scoreTxt, game.iconP1, game.iconP2])
						FlxTween.tween(ui, {y: ui.y + 120}, 5, {ease: FlxEase.sineOut});
				}
				game.defaultCamZoom -= 0.5;
				game.cinematicBarControls("moveboth", 1, "circOut", 50);
				cinematicValue = 50;
			case 48 | 56 | 64 | 72:
				game.defaultCamZoom += 0.1;
				game.cinematicBarControls("moveboth", 1.5, "circOut", cinematicValue + 20);
				cinematicValue += 20;
			case 80:
				game.defaultCamZoom -= 0.4;
				game.cinematicBarControls("moveboth", 2, "backOut", 50);
				cinematicValue = 0;
			case 176:
				game.camBars.flash(FlxColor.BLACK, 8);
				for (cam in [camHUD])
					cam.alpha = 0;
			case 208:
				for (hudShit in [camHUD])
					FlxTween.tween(hudShit, {alpha: 1}, 2, {ease: FlxEase.quartOut});
			case 272 | 276 | 280 | 284:
				game.defaultCamZoom += .05;
			case 288:
				game.defaultCamZoom -= .2;
		}

		if (curBeat >= 240 && curBeat < 288 && curBeat % 2 == 0)
		{
			camGame.zoom += 0.015;
			camHUD.zoom += 0.03;
		}

		if (curBeat >= 288 && curBeat < 352)
		{
			camGame.zoom += 0.015;
			camHUD.zoom += 0.03;
		}
	}
}