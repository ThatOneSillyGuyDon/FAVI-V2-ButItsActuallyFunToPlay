package states.stages;

import states.stages.objects.*;

class LaughyTracky extends BaseStage
{
	//Laughy Taffys are goated as fuck why are they hated so much?
	var circusPath:String = 'favi/stages/circus/e/';
	
	override function create()
	{
		game.defaultCamZoom = 2.1;
	
		var sky = new FlxSprite(-1280 * .25,  -720 * .2, Paths.image(circusPath + 'sky'));
		sky.scrollFactor.set(.05, .05);
		sky.scale.set(.75, .75);
		sky.updateHitbox();
		add(sky);
	
		var floor = new FlxSprite(-1280, -720, Paths.image(circusPath + 'floor'));
		floor.scale.set(1.1, 1.1);
		add(floor);
	
		var tent = new FlxSprite(-1280, -720, Paths.image(circusPath + 'tent'));
		add(tent);
	}
	
	override function createPost()
	{
		var tentsfront = new FlxSprite(-1280 * 1.2, -720, Paths.image(circusPath + 'tentsfront'));
		tentsfront.scrollFactor.set(1.25, 1.25);
		tentsfront.scale.set(1.15, 1.15);
		add(tentsfront);

		game.dad.setPosition(-990, -100);
		game.boyfriend.setPosition(0,-360);
		game.gf.setPosition(-300, -200);

		game.camBars.fade(FlxColor.BLACK, 0.0001);
		camHUD.alpha = 0.001;
	}

	override function stepHit()
	{
		switch (curStep)
		{
			case 262 | 294 | 326 | 358: 
				FlxG.camera.zoom += 0.015;
		}
	}
	override function beatHit()
	{
		switch (curBeat)
		{
			case 7:
				game.cameraSpeed = 50;
			case 8:
				game.camBars.fade(FlxColor.BLACK, 5, true);
			case 32:
				game.defaultCamZoom = 1.5;
			case 56:
				game.tweenCamera(1, 1.5, 'circInOut');
				FlxTween.tween(camHUD, {alpha: 1}, 1.5, {ease: FlxEase.circInOut});
				game.cameraSpeed = 2;
			case 64 | 67 | 72 | 75 | 80 | 83 | 88 | 91: 
				FlxG.camera.zoom += 0.015;
				game.camHUD.zoom += 0.03;
				//camFlashSystem(CAM_FLASH_FANCY, {alpha: 0.25, ease: FlxEase.sineOut, timer: 0.6});
			case 96:
				game.camFlashSystem(CAM_FLASH_FANCY, {alpha: 0.6, ease: FlxEase.sineOut, timer: 1});
				game.cameraSpeed = 2.3;
				game.defaultCamZoom = .78;
			case 152:
				game.defaultCamZoom = 1;
				game.opponentCameraOffset[0] -= 50;
				game.moveCamera(true);
			case 156:
				game.defaultCamZoom = 1.2;
				game.opponentCameraOffset[0] -= 50;
				game.moveCamera(true);
			case 160:
				game.defaultCamZoom = .78;
				game.opponentCameraOffset[0] += 100;
			case 184:
				game.defaultCamZoom = 1;
				game.boyfriendCameraOffset[0] += 50;
				game.moveCamera(false);
			case 188:
				game.defaultCamZoom = 1.2;
				game.boyfriendCameraOffset[0] += 50;
				game.moveCamera(false);
			case 192:
				game.defaultCamZoom = .78;
				game.boyfriendCameraOffset[0] -= 100;
				game.opponentCameraOffset[0] -= 70;
				game.isCameraOnForcedPos = true;
				FlxTween.tween(FlxG.camera, {zoom: 1.1}, 3.5, {startDelay: .9, ease: FlxEase.sineInOut, onComplete: a -> game.defaultCamZoom = 1.1});
				FlxTween.tween(game.camFollow, {x: game.camFollow.x - 750}, 3.5, {startDelay: .9, ease: FlxEase.sineInOut, onComplete: s -> game.isCameraOnForcedPos = false});
			case 256:
				game.boyfriendCameraOffset[0] += 100;
				game.opponentCameraOffset[0] += 70;
				game.moveCamera(true);
				// only time this actually works fine dear god
				game.camFlashSystem(CAM_FLASH_FANCY, {alpha: 0.6, ease: FlxEase.sineOut, timer: 1});
				game.defaultCamZoom = .78;
			case 384:
				game.triggerEvent('Change Scroll Speed', '0.7', '2');
				game.cameraSpeed = 1;
			case 484:
				game.triggerEvent('Change Scroll Speed', '1.1', '2');
				game.cameraSpeed = 1.8;
				game.defaultCamZoom = 1;
				game.boyfriendCameraOffset[0] += 50;
				game.moveCamera(false);
			case 488:
				game.boyfriendCameraOffset[0] -= 50;
				game.moveCamera(true);
				game.camFlashSystem(CAM_FLASH_FANCY, {alpha: 0.6, ease: FlxEase.sineOut, timer: 1});
				game.defaultCamZoom = .78;
				game.cameraSpeed = 2.3;
			case 616:
				game.defaultCamZoom = 1;
				game.boyfriendCameraOffset[0] += 30;
				game.moveCamera(false);
			case 618:
				game.defaultCamZoom = 1.2;
				game.boyfriendCameraOffset[0] += 30;
				game.opponentCameraOffset[0] += 60;
				game.cameraSpeed = 1.6;
				game.moveCamera(false);
			case 684:
				game.defaultCamZoom = 1.35;
				game.boyfriendCameraOffset[0] += 30;
				game.moveCamera(false);
		}

		if ((curBeat >= 96 && curBeat <= 128) || (curBeat >= 256 && curBeat <= 384) || (curBeat >= 488 && curBeat <= 616))
		{
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;
		}

		if (curBeat >= 192 && curBeat <= 256 && curBeat % 2 == 0)
		{
			FlxG.camera.zoom += curBeat >= 209 ? .015 : 0;
			camHUD.zoom += 0.03;
		}
	}
}