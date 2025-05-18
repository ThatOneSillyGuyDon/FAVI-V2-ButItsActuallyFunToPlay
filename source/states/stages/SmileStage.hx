package states.stages;

import states.stages.objects.*;

#if !flash 
import openfl.filters.ShaderFilter;
#end

class SmileStage extends BaseStage
{
	public static var staticEffect:FlxRuntimeShader = new FlxRuntimeShader(Shaders.tvStatic, null, 120);

	public var shaderAnim:Float = 0;

	override function create()
	{
		game.defaultCamZoom = 0.75;
		game.cameraSpeed = 2.5;

		var office:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.image(PlayState.pathway + 'office'));
		office.antialiasing = true;
		office.scrollFactor.set(1, 1);
		office.active = false;
		add(office);

		var chair:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.image(PlayState.pathway + 'chair'));
		chair.antialiasing = true;
		chair.scrollFactor.set(1, 1);
		chair.active = false;
		add(chair);

		office.scale.set(0.85, 0.8);
		chair.scale.set(0.9, 0.85);
	}
	
	override function createPost()
	{
		var funiLight:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.image(PlayState.pathway + 'light'));
		funiLight.antialiasing = true;
		funiLight.scrollFactor.set(1, 1);
		funiLight.alpha = 0.6;
		funiLight.blend = ADD;
		funiLight.active = false;
		add(funiLight);
		funiLight.scale.set(0.85, 0.8);

		game.boyfriend.setPosition(1300, 400);
		game.dad.setPosition(0, 0);
		game.gf.setPosition(1100, 560);

		if (ClientPrefs.data.shaders)
		{
			if (!ClientPrefs.data.lowQuality)
			{
				camGame.setFilters([
					new ShaderFilter(staticEffect)
				]);
			}
		}

		camHUD.visible = false;
		game.camBars.fade(FlxColor.BLACK, 0.0001);
	}

	override function update(elapsed:Float)
	{
		shaderAnim = Conductor.songPosition / 1000;
		
		staticEffect.setFloat('uTime', shaderAnim);
		staticEffect.setFloat('iTime', shaderAnim);
	}

	override function beatHit()
	{
		switch (curBeat)
		{
			case 1:
				game.defaultCamZoom += 0.25;
				game.opponentCameraOffset[0] -= 80;
				game.manageLyrics("smile", "Give me your smile!", 'disneyFreeplayFont.ttf', 30, 3.5, 'sineInOut', 0.08);
				game.camBars.fade(FlxColor.BLACK, 2, true);
			case 8:
				game.defaultCamZoom -= 0.25;
				game.opponentCameraOffset[0] += 80;
				for (hud in [camHUD])
				{
					hud.zoom += 5;
					hud.visible = true;
				}
			case 20 | 32 | 36 | 52 | 64 | 68 | 102 | 120 | 128 | 132 | 252 | 304 | 308 | 336 | 340 | 360 | 364 | 368 | 372 | 404 | 414 | 508 | 528 | 544: 
				game.defaultCamZoom += 0.1;
			case 24 | 56 | 104 | 373 | 374 | 375 | 532:
				game.defaultCamZoom -= 0.1;
			case 40 | 72 | 312 | 328:
				game.defaultCamZoom -= 0.2;
			case 136:
				game.defaultCamZoom -= 0.3;
				FlxTween.tween(camHUD, {alpha: 0}, 1.5, {ease: FlxEase.sineInOut});
			case 143:
				FlxTween.tween(camHUD, {alpha: 1}, 0.8, {ease: FlxEase.sineOut});
			case 144 | 152:
				game.defaultCamZoom += 0.06;
			case 160:
				game.defaultCamZoom -= 0.12;
			case 172 | 248 | 268 | 396 | 412 | 512 | 540:
				game.defaultCamZoom += 0.2;
			case 176 | 256 | 500 | 516:
				game.defaultCamZoom -= 0.3;
			case 184:
				game.tweenCamera(1.35, 5, "sineInOut");
			case 208:
				game.defaultCamZoom = 0.75;
				game.cameraSpeed = 0.5;
			case 272:
				game.defaultCamZoom -= 0.2;
				game.cameraSpeed = 100; //lmao
				for (cams in [camHUD, camGame])
					cams.visible = false;
			case 280:
				for (cams in [camHUD, camGame])
					cams.visible = true;
				game.opponentCameraOffset[0] -= 100;
			case 282:
				game.cameraSpeed = 2.5;
			case 324:
				game.opponentCameraOffset[0] += 100;
				game.boyfriendCameraOffset[0] += 100;
				game.defaultCamZoom += 0.3;
			case 344:
				game.boyfriendCameraOffset[0] -= 100;
				game.defaultCamZoom -= 0.1;
			case 408:
				game.defaultCamZoom = 0.75;
				game.cameraSpeed = 4;
			case 411:
				game.manageLyrics("smile", "Keep it DOWN you runt!", 'disneyFreeplayFont.ttf', 30, 2.5, 'sineInOut', 0.08);
			case 416:
				game.defaultCamZoom -= 0.3;
				game.cameraSpeed = 1.65;
			case 448:
				game.tweenCamera(1.3, 10, "expoInOut");
				game.camFlashSystem(BG_DARK, {alpha: 0.9, timer: 12.5, ease: FlxEase.expoInOut});
			case 480:
				game.defaultCamZoom = 0.75;
				game.camFlashSystem(BG_DARK, {alpha: 0, timer: 1, ease: FlxEase.expoOut});
			case 496:
				game.defaultCamZoom += 0.3;
			case 548:
				game.defaultCamZoom -= 0.3;
				FlxTween.tween(camHUD, {alpha: 0}, 3, {ease: FlxEase.expoInOut});
			case 551:
				game.manageLyrics("smile", "You might've think you've won...", 'disneyFreeplayFont.ttf', 30, 4, 'sineInOut', 0.1);
			case 559:
				game.manageLyrics("smile", "...But in reality...", 'disneyFreeplayFont.ttf', 30, 4, 'sineInOut', 0.07);
			case 563:
				game.manageLyrics("smile", "..YOU LOST.", 'disneyFreeplayFont.ttf', 30, 3, 'sineInOut', 0.12);
			case 588:
				game.camBars.fade(FlxColor.BLACK, 5);
			
		}
	}
}