package states.stages.legacyStages;

#if !flash 
import openfl.filters.ShaderFilter;
#end
import openfl.Lib;

class LegEpisode1Street extends BaseStage
{
	public static var grayScale:FlxRuntimeShader = new FlxRuntimeShader(Shaders.grayScale, null, 120);
	public static var legacyChrom:FlxRuntimeShader = new FlxRuntimeShader(LegacyShaders.chromaticAberration, null, 120);
	public static var legacyDistort:FlxRuntimeShader = new FlxRuntimeShader(LegacyShaders.vcrDistortion, null, 120);
	public static var legacyDefaultDistort:FlxRuntimeShader = new FlxRuntimeShader(LegacyShaders.vcrDistortion, null, 120);
	public static var legacyTiltshift:FlxRuntimeShader = new FlxRuntimeShader(LegacyShaders.tiltshift, null, 120);
	public static var legacyTiltshiftHUD:FlxRuntimeShader = new FlxRuntimeShader(LegacyShaders.tiltshift, null, 120);
	public static var legacyGreyscale:FlxRuntimeShader = new FlxRuntimeShader(LegacyShaders.greyscale, null, 120);

	public var shaderAnim:Float = 0;

	public var waltScreenThing:FlxSprite; // idk, this is needed too for some reason

	override function create()
	{
		game.defaultCamZoom = 0.85;
				
		var street:FlxSprite = new FlxSprite(-500, -700).loadGraphic(Paths.image(PlayState.pathway + 'Mickeybg'));
		add(street);
	
		if(!ClientPrefs.data.lowQuality)
		{
			var grainstuff:FlxSprite = new FlxSprite(0, 0);
			grainstuff.frames = Paths.getSparrowAtlas('favi/filters/Grainshit');
			grainstuff.animation.addByPrefix('yucky', 'grains 1', 24, true);
			grainstuff.animation.play('yucky');
			grainstuff.cameras = [camHUD];
			grainstuff.scale.set(3, 3);
			grainstuff.screenCenter();
			add(grainstuff);
		}
	}
	
	override function createPost()
	{
		game.gf.visible = false;

		if (ClientPrefs.data.shaders)
		{
			switch (PlayState.SONG.song)
			{
				case 'Isolated Old' | 'Isolated Legacy' | 'Isolated Beta' | 'Lunacy Legacy' | 'Delusional Legacy':
					for (sigmas in ['r', 'g', 'b']) legacyChrom.setFloat('${sigmas}Offset', 0.005);

					legacyDistort.setFloat('glitchModifier', 1);
					legacyDistort.setFloat('iTime', 0);
					legacyDistort.setBool('perspectiveOn', true);
					legacyDistort.setBool('vignetteMoving', true);
					legacyDistort.setBool('scanlinesOn', true);
					legacyDistort.setBool('vignetteOn', true);
					legacyDistort.setBool('distortionOn', false);
					legacyDistort.setFloatArray('iResolution', [Lib.current.stage.stageWidth, Lib.current.stage.stageHeight]);

					legacyDefaultDistort.setFloat('glitchModifier', 0);
					legacyDefaultDistort.setFloat('iTime', 0);
					legacyDefaultDistort.setBool('perspectiveOn', true);
					legacyDefaultDistort.setBool('vignetteMoving', true);
					legacyDefaultDistort.setBool('scanlinesOn', true);
					legacyDefaultDistort.setBool('vignetteOn', true);
					legacyDefaultDistort.setBool('distortionOn', true);
					legacyDefaultDistort.setFloatArray('iResolution', [Lib.current.stage.stageWidth, Lib.current.stage.stageHeight]);

					legacyTiltshift.setFloat('bluramount', .5);
					legacyTiltshiftHUD.setFloat('bluramount', .6);

					legacyTiltshift.setFloat('center', 0);
					legacyTiltshiftHUD.setFloat('center', 0);

					if (!ClientPrefs.data.lowQuality)
					{
						camGame.setFilters([
							new ShaderFilter(legacyChrom),
							new ShaderFilter(legacyDistort),
							new ShaderFilter(legacyGreyscale),
						]);
						
						camHUD.setFilters([
							new ShaderFilter(legacyChrom),
							new ShaderFilter(legacyDefaultDistort),
							new ShaderFilter(legacyTiltshiftHUD),
							new ShaderFilter(legacyGreyscale),
						]);
					}
					else
					{
						camGame.setFilters([new ShaderFilter(grayScale)]);
						camHUD.setFilters([new ShaderFilter(grayScale)]);
					}
			}
		}

		waltScreenThing = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
		waltScreenThing.scrollFactor.set();
		waltScreenThing.cameras = [camOther];
		waltScreenThing.alpha = 0.001;

		if (PlayState.SONG.song == "Delusional Legacy")
				add(waltScreenThing);
	}

	override function update(elapsed:Float)
	{
		shaderAnim = Conductor.songPosition / 1000;
		
		game.dad.setPosition(0, 0);
		if (game.boyfriend.curCharacter == 'bf')
		{
			game.boyfriend.setPosition(1000, 130);
		}else{
			game.boyfriend.setPosition(500, -320);
		}

		if (ClientPrefs.data.shaders)
		{
			switch(PlayState.SONG.song)
			{
				case 'Isolated Beta' | 'Isolated Legacy' | 'Isolated Old' | 'Lunacy Legacy' | 'Delusional Legacy':
					legacyDistort.setFloat('iTime', shaderAnim);
					legacyDistort.setFloatArray('iResolution', [Lib.current.stage.stageWidth, Lib.current.stage.stageHeight]);

					legacyDefaultDistort.setFloat('iTime', shaderAnim);
					legacyDefaultDistort.setFloatArray('iResolution', [Lib.current.stage.stageWidth, Lib.current.stage.stageHeight]);
			}
		}
	}

	override function stepHit()
	{
		switch (PlayState.SONG.song)
		{
			case 'Isolated Beta':
				// why tf did this version have so much fucking zoom events?????
				switch (curStep)
				{
					case 32 | 48 | 96 | 112 | 160 | 176 | 208 | 224 | 240 | 304 | 336 | 352 | 368 | 387 | 388 | 434 | 436 | 440 | 444 | 451 | 452 | 496 | 500 | 504 | 508 | 528 | 532 | 536 | 540 | 592 | 596 | 600 | 604 | 642 | 643 | 644 | 688 | 692 | 696 | 700 | 706 | 707 | 708 | 752 | 756 | 760 | 764 | 784 | 788 | 792 | 796 | 848 | 852 | 956 | 860 | 1056 | 1072 | 1088 | 1104 | 1120 | 1136 | 1152 | 1184 | 1200 | 1216 | 1232 | 1248 | 1264:
						game.defaultCamZoom += 0.1;
					case 64 | 192 | 390 | 416 | 424 | 454 | 480 | 488 | 672 | 680 | 736 | 744:
						game.defaultCamZoom -= 0.2;
					case 120:
						game.defaultCamZoom = 1.5;
					case 128 | 256 | 320 | 384 | 448 | 512 | 544 | 608 | 646 | 704 | 710 | 768 | 800 | 864 | 1280:
						game.defaultCamZoom = 0.8;
					case 412 | 420 | 476 | 484 | 668 | 676 | 732 | 740:
						game.defaultCamZoom += 0.2;
					case 896:
						//fuck you, i am NOT doing the rest of those fuck ass zoom events
						game.tweenCamera(1.6, 15, "sineInOut");
					case 1024:
						game.defaultCamZoom = 0.2;
				}
		}
	}

	override function beatHit()
	{
		switch (PlayState.SONG.song)
		{
			case 'Delusional Legacy':
				switch (curBeat)
				{
					case 32 | 64: 
						camGame.flash(FlxColor.WHITE, 3);
					case 48 | 80:
						game.camBars.fade(FlxColor.BLACK, 3, true);
					case 96:
						game.camBars.fade(FlxColor.BLACK, 6, true);
						camHUD.visible = false;
						game.tweenCamera(1.35, 6.2, "circInOut");
					case 116:
						camGame.flash(FlxColor.WHITE, 3);
						camHUD.visible = true;
						game.defaultCamZoom = 0.9;
					case 128 | 130 | 144 | 146 | 756:
						game.defaultCamZoom += 0.1;
					case 132 | 148 | 724 | 758 | 760:
						game.defaultCamZoom -= 0.2;
					case 178 | 692:
						game.defaultCamZoom += 0.2;
					case 180:
						game.defaultCamZoom -= 0.2;
						FlxTween.tween(waltScreenThing, {alpha: 0.7}, 18, {ease: FlxEase.sineInOut});
						camGame.flash(FlxColor.WHITE, 3);
					case 240:
						FlxTween.tween(waltScreenThing, {alpha: 0.0001}, 1, {ease: FlxEase.sineOut});
						game.defaultCamZoom += 0.2;
					case 244:
						game.defaultCamZoom -= 0.2;
						camGame.flash(FlxColor.WHITE, 3);
					case 308 | 340:
						game.defaultCamZoom = 1.3;
					case 324 | 328 | 332 | 336:
						game.defaultCamZoom -= 0.1;
					case 372:
						camGame.flash(FlxColor.WHITE, 3);
						FlxTween.tween(waltScreenThing, {alpha: 1}, 2, {ease: FlxEase.expoOut});
						camHUD.visible = false;
					case 396:
						game.tweenCamera(0.85, 4, "quartInOut");
						FlxTween.tween(waltScreenThing, {alpha: 0.001}, 4, {ease: FlxEase.quartInOut});
						camHUD.visible = true;
					case 564:
						game.camBars.fade(FlxColor.BLACK, 2, true);
						camHUD.visible = false;
					case 592:
						FlxTween.tween(waltScreenThing, {alpha: 1}, 8, {ease: FlxEase.expoInOut});
					case 628:
						camGame.flash(FlxColor.WHITE, 3);
						waltScreenThing.alpha = 0.001;
						camHUD.visible = true;
						game.defaultCamZoom = 0.9;
					case 636:
						game.tweenCamera(1.2, 10, "quartInOut");
					case 660:
						game.tweenCamera(0.9, 2, "expoOut");
					case 764:
						camGame.flash(FlxColor.WHITE, 3);
						game.defaultCamZoom = 0.9;
					case 796:
						game.tweenCamera(1.3, 15, "expoInOut");
						FlxTween.tween(waltScreenThing, {alpha: 0.75}, 28, {ease: FlxEase.quartInOut});
					case 892:
						game.tweenCamera(0.8, 2, "expoIn");
						FlxTween.tween(waltScreenThing, {alpha: 0}, 1, {ease: FlxEase.sineOut});
					case 896:
						camGame.flash(FlxColor.WHITE, 3);
						FlxTween.tween(waltScreenThing, {alpha: 1}, 5, {ease: FlxEase.expoOut});
						camHUD.visible = false;
					case 920:
						FlxTween.tween(waltScreenThing, {alpha: 0}, 3);
						game.camFlashSystem(BG_DARK, {alpha: 1, timer: 0.001});
						camHUD.visible = true;
						game.isCameraOnForcedPos = true;
						game.camFollow.x = 200;
						game.camFollow.y = 300;
						game.boyfriend.visible = false;
					case 960:
						game.tweenCamera(0.2, 5, "sineInOut");
						FlxTween.tween(waltScreenThing, {alpha: 1}, 5, {ease: FlxEase.expoOut});
				}
			case 'Isolated Legacy':
				switch (curBeat)
				{
					case 1 | 16 | 352 | 368: game.tweenCamera(1.3, 5, 'sineInOut');
					case 14 | 30 | 46 | 64 | 80 | 84: game.defaultCamZoom = 0.9;
					case 32 | 48: game.tweenCamera(1.2, 3, 'sineInOut');
					case 40 | 42 | 44 | 56 | 58 | 60 | 62 | 82: game.defaultCamZoom += 0.12;
					case 66 | 86: game.defaultCamZoom += 0.2;
					case 68 | 88: game.defaultCamZoom -= 0.15;
					case 72 | 74 | 76 | 78 | 90 | 92 | 94: game.defaultCamZoom += 0.09;
					case 96 | 224:
						game.camFlashSystem(BG_DARK, {alpha: 0, timer: 0.001, ease: FlxEase.sineInOut});
						if (ClientPrefs.data.flashing) camGame.flash(FlxColor.WHITE, 1);
						game.defaultCamZoom = 0.9;
					case 98 | 106 | 114 | 122 | 130 | 138 | 146 | 154 | 226 | 234 | 242 | 250 | 258 | 266 | 274 | 282 | 290 | 298 | 306 | 314 | 322 | 330 | 338 | 346:
						game.camFlashSystem(BG_FLASH, {alpha: 0.75, timer: 0.5, ease: FlxEase.circOut});
						FlxG.camera.zoom += 0.2;
						camHUD.zoom += 0.23;
					case 99 | 107 | 115 | 123 | 131 | 139 | 147 | 155 | 227 | 235 | 243 | 251 | 259 | 267 | 275 | 283 | 291 | 299 | 307 | 315 | 323 | 331 | 339 | 347:
						game.camFlashSystem(BG_FLASH, {alpha: 0.3, timer: 0.5, ease: FlxEase.circOut});
						FlxG.camera.zoom += 0.08;
						camHUD.zoom += 0.11;
					case 101 | 109 | 117 | 125 | 133 | 141 | 149 | 157 | 229 | 237 | 245 | 253 | 261 | 269 | 277 | 285 | 293 | 301 | 309 | 317 | 325 | 333 | 341 | 349:
						game.camFlashSystem(BG_FLASH, {alpha: 0.4, timer: 0.5, ease: FlxEase.circOut});
						FlxG.camera.zoom += 0.1;
						camHUD.zoom += 0.13;
					case 102 | 110 | 118 | 126 | 134 | 142 | 150 | 230 | 238 | 246 | 254 | 262 | 270 | 278 | 286 | 294 | 302 | 310 | 318 | 326 | 334 | 342 | 350:
						game.camFlashSystem(BG_FLASH, {alpha: 0.55, timer: 0.5, ease: FlxEase.circOut});
						FlxG.camera.zoom += 0.12;
						camHUD.zoom += 0.15;
					case 104 | 112 | 120 | 128 | 136 | 144 | 152 | 232 | 240 | 248 | 256 | 264 | 272 | 280 | 288 | 296 | 304 | 312 | 320 | 328 | 336 | 344:
						game.camFlashSystem(BG_FLASH, {alpha: 0.3, timer: 0.5, ease: FlxEase.circOut});
						FlxG.camera.zoom += 0.23;
						camHUD.zoom += 0.26;
					case 158:
						game.camFlashSystem(BG_DARK, {alpha: 0.85, timer: 1.2, ease: FlxEase.sineInOut});
						FlxG.camera.zoom += 0.23;
						camHUD.zoom += 0.26;
					case 192 | 200 | 208 | 216:
						game.defaultCamZoom += 0.1;
					case 366 | 382:
						game.defaultCamZoom -= 0.1;
					case 367 | 383:
						game.defaultCamZoom -= 0.25;
					case 412:
						game.tweenCamera(2, 2, "sineIn");
					case 416:
						camGame.visible = false;
						camHUD.visible = false;
				}
			case 'Lunacy Legacy':
				switch (curBeat)
				{
					case 4 | 8 | 12 | 14 | 40 | 56 | 104 | 112 | 120 | 124 | 126: game.defaultCamZoom += 0.1;
					case 16 | 48: 
						game.defaultCamZoom = 0.9;
						camHUD.zoom += 0.02;
					case 20 | 44 | 60 | 132 | 142 | 164 | 174: game.defaultCamZoom += 0.2;
					case 24:
						game.tweenCamera(0.7, 2, "quartInOut");
						FlxTween.tween(camGame, {alpha: 0}, 1.5, {ease: FlxEase.quartInOut});
						FlxTween.tween(camHUD, {alpha: 0.15}, 2, {ease: FlxEase.quartInOut});
					case 32:
						camGame.alpha = 1;
						if (ClientPrefs.data.flashing) camGame.flash(FlxColor.WHITE, 1.5);
						camHUD.alpha = 1;
						camHUD.zoom += 0.02;
						game.defaultCamZoom = 0.9;
					case 68 | 76 | 176: game.defaultCamZoom -= 0.1;
					case 72 | 134 | 144: game.defaultCamZoom -= 0.15;
					case 80: game.defaultCamZoom = 1.1;
					case 88 | 166 | 224: game.defaultCamZoom = 0.8;
					case 128 | 256:
						game.defaultCamZoom = 0.78;
						if (ClientPrefs.data.flashing) camGame.flash(FlxColor.WHITE, 1.5);
						camHUD.alpha = 0.0001;
					case 156 | 284:
						game.tweenCamera(1, 1, "sineInOut");
						FlxTween.tween(camHUD, {alpha: 1}, 1.5, {ease: FlxEase.quartInOut});
					case 160: if (ClientPrefs.data.flashing) camGame.fade(FlxColor.BLACK, 1.5, true);
					case 192: game.defaultCamZoom += 0.25;
					case 320:
						if (ClientPrefs.data.flashing) camGame.fade(FlxColor.BLACK, 1, true);
						game.camFlashSystem(BG_DARK, {alpha: 0.85, timer: 1, ease: FlxEase.quartInOut});
						game.defaultCamZoom += 0.2;
					case 336: game.defaultCamZoom -= 0.35;
					case 368: game.tweenCamera(1.3, 8, "quartInOut");
					case 400:
						if (ClientPrefs.data.flashing) camGame.fade(FlxColor.BLACK, 1.5, true);
						game.camFlashSystem(BG_DARK, {alpha: 0, timer: 1, ease: FlxEase.sineOut});
					case 404:
						FlxTween.tween(camGame, {alpha: 0}, 1.5, {ease: FlxEase.quartInOut});
						FlxTween.tween(camHUD, {alpha: 0}, 1.5, {ease: FlxEase.quartInOut});
				}
		}
	}
}