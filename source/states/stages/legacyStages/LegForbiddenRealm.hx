package states.stages.legacyStages;

#if !flash 
import openfl.filters.ShaderFilter;
#end

class LegForbiddenRealm extends BaseStage
{
	//MALFUNCTION
	var mickeyEmitter:FlxEmitter;
	var fuckingsquares:FlxSprite;
	var whiteBG:FlxSprite;
	var glitchBG:FlxRuntimeShader;
	var staticBG:FlxRuntimeShader;
	var accessPath:String;

	public static var malFreakG:FlxRuntimeShader = new FlxRuntimeShader(Shaders.freakyGlitch, null, 120);
	public static var malBG:FlxRuntimeShader = new FlxRuntimeShader(Shaders.malfunctionBGEffect, null, 120);

	//SHADERS WOOOOOOOOOOOOOOOOO
	public static var chromZoomShader:FlxRuntimeShader = new FlxRuntimeShader(Shaders.aberration, null, 150);
	public static var chromNormalShader:FlxRuntimeShader = new FlxRuntimeShader(Shaders.aberrationDefault, null, 150);
	public static var blurShader:FlxRuntimeShader = new FlxRuntimeShader(Shaders.tiltShift, null, 120);

	public static var blurEffect:Float = 0.0;
	public var shaderAnim:Float = 0;

	public static var blurTween:FlxTween;

	override function create()
	{
		game.defaultCamZoom = 0.8;

		accessPath = PlayState.SONG.song == 'Malfunction Legacy' ? 'PixelMouse' : 'malfunctionBG-NEW';
		
		staticBG = new FlxRuntimeShader(Shaders.tvStatic, null, 120);
		glitchBG = new FlxRuntimeShader(Shaders.vignetteGlitch, null, 130);

		fuckingsquares = new FlxSprite(-750, -850);
		fuckingsquares.loadGraphic(Paths.image(PlayState.pathway + accessPath));
		fuckingsquares.scale.set(1.2, 1);
		fuckingsquares.updateHitbox();
		fuckingsquares.antialiasing = false;
		fuckingsquares.scrollFactor.set(1, 1);
		fuckingsquares.active = false;
		if (ClientPrefs.data.shaders && !ClientPrefs.data.lowQuality)
			fuckingsquares.shader = malBG;
		add(fuckingsquares);

		var greyParticles:FlxEmitter = new FlxEmitter(-2080.5, 650.4);
		greyParticles.launchMode = SQUARE;
		greyParticles.velocity.set(-50, -200, 50, -600, -90, 0, 90, -600);
		greyParticles.scale.set(4, 4, 4, 4, 0, 0, 0, 0);
		greyParticles.drag.set(0, 0, 0, 0, 5, 5, 10, 10);
		greyParticles.width = 4787.45;
		greyParticles.alpha.set(1, 1);
		greyParticles.lifespan.set(1.9, 4.9);
		greyParticles.loadParticles(Paths.image(PlayState.pathway + 'greyParticle'), 500, 16, true);
		greyParticles.start(false, FlxG.random.float(.0521, .1060), 1000000);
		
		whiteBG = new FlxSprite(-800, -200).makeGraphic(1, 1, 0xFFFFFFFF);
		whiteBG.scale.set(FlxG.width, FlxG.height);
		whiteBG.alpha = 0.001;
		whiteBG.active = false;
		add(whiteBG);
		
		if (PlayState.SONG.song != 'Malfunction Legacy')
		{
			add(greyParticles);
		}
	}
	
	override function createPost()
	{
		var blackParticles:FlxEmitter = new FlxEmitter(-2080.5, 912.4);
		blackParticles.launchMode = SQUARE;
		blackParticles.velocity.set(-70, -220, 70, -620, -110, 20, 110, -620);
		blackParticles.scale.set(6, 6, 6, 6, 2, 2, 2, 2);
		blackParticles.drag.set(2, 2, 2, 2, 7, 7, 12, 12);
		blackParticles.width = 4787.45;
		blackParticles.alpha.set(1, 1);
		blackParticles.lifespan.set(1.9, 4.9);
		blackParticles.loadParticles(Paths.image(PlayState.pathway + 'particleBlack'), 500, 16, true);
		blackParticles.start(false, FlxG.random.float(.0821, .1460), 1000000);
		
		mickeyEmitter = new FlxEmitter(-2099.8, 1620.4);
		for (i in 0 ... 100)
		{
			var mickeyParticle = new FlxParticle();
			mickeyParticle.frames = Paths.getSparrowAtlas(PlayState.pathway + 'mickParticle');
			mickeyParticle.animation.addByPrefix('mickParticle idle', 'mickParticle idle', 12, true);
			mickeyParticle.animation.play('mickParticle idle');
			mickeyParticle.exists = false;
			mickeyEmitter.add(mickeyParticle);
		}
		mickeyEmitter.launchMode = SQUARE;
		mickeyEmitter.velocity.set(-50, -400, 50, -800, -100, 0, 100, -800);
		mickeyEmitter.scale.set(3.4, 3.4, 3.4, 3.4, 0, 0, 0, 0);
		mickeyEmitter.drag.set(0, 0, 0, 0, 5, 5, 10, 10);
		mickeyEmitter.width = 4200.45;
		mickeyEmitter.alpha.set(1, 1);
		mickeyEmitter.lifespan.set(4, 4.5);
		mickeyEmitter.start(false, FlxG.random.float(.125, .287), 100000);
		mickeyEmitter.emitting = false;
		
		if (PlayState.SONG.song != 'Malfunction Legacy')
			add(blackParticles);
			add(mickeyEmitter);

		if (game.dad.curCharacter == 'gm-calm-pixel')
			game.dad.setPosition(-130, 50);
		else
			game.dad.setPosition(-100, 150);
		
		game.boyfriend.setPosition(1300, 600);
		game.gf.visible = false;

		if (ClientPrefs.data.shaders)
		{
			if(!ClientPrefs.data.lowQuality)
			{
				camGame.setFilters(
				[
					new ShaderFilter(chromNormalShader),
					new ShaderFilter(blurShader)
				]);
				camHUD.setFilters(
				[
					new ShaderFilter(chromNormalShader),
					new ShaderFilter(blurShader)
				]);
			}
		}
	}

	override function update(elapsed:Float)
	{
		if (ClientPrefs.data.shaders)
		{
			chromNormalShader.setFloat('rOffset', game.chromEffect / 20);
			chromNormalShader.setFloat('bOffset', -game.chromEffect / 20);
			if (ClientPrefs.data.epilepsy)
				blurShader.setFloat('bluramount', blurEffect);
		}
	}

	
	override function stepHit()
	{
		// Code here
	}
	override function beatHit()
	{
		if (PlayState.SONG.song == 'Malfunction')
		{
			if (curBeat == 160)
			{
				whiteBG.alpha = 1;
				FlxTween.tween(whiteBG, {alpha: 0}, 2);
				FlxTween.tween(fuckingsquares, {alpha: 0}, 5, {ease: FlxEase.sineOut});
			}
	
			if (curBeat == 184)
			{
				FlxTween.tween(fuckingsquares, {alpha: 1}, 1.5, {ease: FlxEase.sineOut});
			}
		}

		switch (curBeat)
		{
			case 136 | 140:
				for (cam in [camGame, camHUD])
					cam.visible = !cam.visible;
				if (camGame.visible)
				{
					game.camFlashSystem(CAM_FLASH_FANCY, {alpha: 0.85, timer: 1.2, colors: [255, 255, 255]});
					FlxG.camera.zoom += 0.1;
				}
			case 206:
				game.camFlashSystem(CAM_FLASH_FANCY, {alpha: 0.85, timer: 1.2, colors: [255, 0, 0]});
			case 398:
				game.camFlashSystem(CAM_FLASH_FANCY, {alpha: 0.85, timer: 1.2, colors: [255, 255, 255]});
				for (cam in [camHUD])
					FlxTween.tween(cam, {alpha: 0}, 1);
				FlxG.camera.zoom += 0.1;
		}
	}
	override function sectionHit()
	{
		// Code here
	}

	// Substates for pausing/resuming tweens and timers
	override function closeSubState()
	{
		if(paused)
		{
			//timer.active = true;
			//tween.active = true;
		}
	}

	override function openSubState(SubState:flixel.FlxSubState)
	{
		if(paused)
		{
			//timer.active = false;
			//tween.active = false;
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
	override function eventPushed(event:objects.Note.EventNote)
	{
		// used for preloading assets used on events that doesn't need different assets based on its values
		switch(event.event)
		{
			case "My Event":
				//precacheImage('myImage') //preloads images/myImage.png
				//precacheSound('mySound') //preloads sounds/mySound.ogg
				//precacheMusic('myMusic') //preloads music/myMusic.ogg
		}
	}
	override function eventPushedUnique(event:objects.Note.EventNote)
	{
		// used for preloading assets used on events where its values affect what assets should be preloaded
		switch(event.event)
		{
			case "My Event":
				switch(event.value1)
				{
					// If value 1 is "blah blah", it will preload these assets:
					case 'blah blah':
						//precacheImage('myImageOne') //preloads images/myImageOne.png
						//precacheSound('mySoundOne') //preloads sounds/mySoundOne.ogg
						//precacheMusic('myMusicOne') //preloads music/myMusicOne.ogg

					// If value 1 is "coolswag", it will preload these assets:
					case 'coolswag':
						//precacheImage('myImageTwo') //preloads images/myImageTwo.png
						//precacheSound('mySoundTwo') //preloads sounds/mySoundTwo.ogg
						//precacheMusic('myMusicTwo') //preloads music/myMusicTwo.ogg
					
					// If value 1 is not "blah blah" or "coolswag", it will preload these assets:
					default:
						//precacheImage('myImageThree') //preloads images/myImageThree.png
						//precacheSound('mySoundThree') //preloads sounds/mySoundThree.ogg
						//precacheMusic('myMusicThree') //preloads music/myMusicThree.ogg
				}
		}
	}
}