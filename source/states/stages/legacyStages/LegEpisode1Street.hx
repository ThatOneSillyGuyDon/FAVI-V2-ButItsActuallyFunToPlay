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

	override function beatHit()
		{
			switch (PlayState.SONG.song)
			{
				case 'Delusional Legacy':
					switch (curBeat)
					{
						case 180:
							FlxTween.tween(waltScreenThing, {alpha: 0.7}, 18, {ease: FlxEase.sineInOut});
						case 240:
							FlxTween.tween(waltScreenThing, {alpha: 0.0001}, 1, {ease: FlxEase.sineOut});
						case 372:
							FlxTween.tween(waltScreenThing, {alpha: 1}, 2, {ease: FlxEase.expoOut});
						case 396:
							FlxTween.tween(waltScreenThing, {alpha: 0.001}, 4, {ease: FlxEase.quartInOut});
						case 592:
							FlxTween.tween(waltScreenThing, {alpha: 1}, 8, {ease: FlxEase.expoInOut});
						case 628:
							waltScreenThing.alpha = 0.001;

						case 796:
							FlxTween.tween(waltScreenThing, {alpha: 0.75}, 28, {ease: FlxEase.quartInOut});
						case 892:
							FlxTween.tween(waltScreenThing, {alpha: 0}, 1, {ease: FlxEase.sineOut});
						case 896:
							FlxTween.tween(waltScreenThing, {alpha: 1}, 5, {ease: FlxEase.expoOut});
						case 920:
							FlxTween.tween(waltScreenThing, {alpha: 0}, 3);
						case 960:
							FlxTween.tween(waltScreenThing, {alpha: 1}, 5, {ease: FlxEase.expoOut});
					}
				/*
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
							game.uiGroup.visible = false;
							game.noteGroup.visible = false;
							game.comboGroup.visible = false;
					}
				*/
		}
	}

}