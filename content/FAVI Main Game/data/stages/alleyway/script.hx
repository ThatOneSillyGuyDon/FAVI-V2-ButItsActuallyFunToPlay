import flixel.effects.particles.FlxEmitter.FlxEmitterMode;
import flixel.effects.particles.FlxParticle;

import funkin.utils.MathUtil;

import openfl.filters.ShaderFilter;

var overlay;
var bg;
var buildings;
var alleyway;
var satan;
var wall;
var rain;
var path = "stages/alleyway/";
var rainShader:FlxRuntimeShader = newShader('rain');
var chromZoomShader:FlxRuntimeShader = newShader('aberration');
var chromNormalShader:FlxRuntimeShader = newShader('aberrationDefault');
var dramaticCamMovement:FlxRuntimeShader = newShader('cameraMovement');
var monitorFilter:FlxRuntimeShader = newShader('monitorFilter');
var shaderAnim:Float = 0;
var rainTime:Float = 0;
var wallCam:FlxCamera;

function onLoad()
{
	wallCam = new FlxCamera();
	wallCam.bgColor = 0x0;
	FlxG.cameras.insert(wallCam, FlxG.cameras.list.indexOf(PlayState.camGame) - 1, false);
	
	overlay = new FlxSprite().loadGraphic(Paths.image('stages/abandonedStreet/i_forgor'));
	overlay.screenCenter();
	overlay.setGraphicSize(FlxG.width, FlxG.height);
	overlay.camera = camOther;
	
	bg = new FlxBackdrop(Paths.image(path + 'sky'), 0x01, 0, 0);
	buildings = new FlxSprite().loadGraphic(Paths.image(path + 'buildings'));
	alleyway = new FlxSprite().loadGraphic(Paths.image(path + 'alley'));
	satan = new FlxSprite().loadGraphic(Paths.image(path + 'satan'));
	wall = new FlxSprite().loadGraphic(Paths.image(path + 'wall'));
	
	if (!ClientPrefs.shaders)
	{
		rain = new FlxSprite();
		rain.frames = Paths.getSparrowAtlas(path + 'rain');
		rain.animation.addByPrefix('rain but the side', 'rain but the side', 24, true);
		rain.animation.play('rain but the side');
	}
	
	for (i in [overlay, bg, buildings, alleyway, satan])
		add(i);
}

function onCreatePost()
{
	wallCam.zoom = defaultCamZoom;
	wallCam.follow(camFollow, FlxCameraFollowStyle.LOCKON, 0);
	
	rainIntensity = .33;
	
	satan.scale.set(1.3, 1.3);
	
	bg.scrollFactor.set(0.3, 0.3);
	buildings.scrollFactor.set(0.95, 0.95);
	wall.scrollFactor.set(1.25, 1.25);
	
	satan.setPosition(2600, 1360);
	dadGroup.visible = false;
	
	iconP2.changeIcon('satandd');
	playHUD.flipBar();
	healthBar.setColors(boyfriend.healthColours, [130, 130, 130]);
	
	satan.setColorTransform(-1, -1, -1, 1, 0, 0, 0, 0);
	
	buildings.setPosition(-250, -50);
	bg.setPosition(0, -650);
	wall.setPosition(60, 285);
	
	if (!ClientPrefs.shaders)
	{
		rain.blend = 0;
		rain.alpha = 0.35;
		rain.scale.set(3, 3);
		rain.setPosition(1480, 100);
		add(rain);
	}
	
	wall.camera = wallCam;
	add(wall);
	
	bg.velocity.x = 350;
	
	if (ClientPrefs.shaders)
	{
		rainShader.setFloatArray('uScreenResolution', [FlxG.width, FlxG.height]);
		rainShader.setFloat('uTime', 0);
		rainShader.setFloat('uScale', FlxG.height / 200);
		rainShader.setFloat('uIntensity', rainIntensity);
		rainShader.setFloatArray('rainColor', [0.034, 0.0078, 0.0445]);
		
		if (!ClientPrefs.lowQuality)
		{
			wallCam.filters = [
				new ShaderFilter(chromNormalShader)
			];
			camGame.filters = [
				new ShaderFilter(monitorFilter),
				new ShaderFilter(chromZoomShader),
				new ShaderFilter(chromNormalShader),
				new ShaderFilter(rainShader)
			];
			camHUD.filters = [new ShaderFilter(chromNormalShader)];
		}
		else
		{
			wallCam.filters = [
				new ShaderFilter(chromNormalShader)
			];
			camGame.filters = [
				new ShaderFilter(monitorFilter),
				new ShaderFilter(chromNormalShader),
				new ShaderFilter(rainShader)
			];
			camHUD.filters = [new ShaderFilter(chromNormalShader)];
		}
	}
}

function onUpdate(elapsed)
{
	final lerpRate = 0.04 * (cameraSpeed * 1.15) * playbackRate;
	wallCam.followLerp = lerpRate;
	
	wallCam.zoom = MathUtil.decayLerp(wallCam.zoom, defaultCamZoom + defaultCamZoomAdd, 6.25 * camZoomingDecay, elapsed);
	
	if (ClientPrefs.shaders)
	{
		shaderAnim = Conductor.songPosition / 1000;
		rainTime += elapsed;
		
		rainShader.setFloatArray('uCameraBounds', [
			camGame.scroll.x + camGame.viewMarginX, camGame.scroll.y + camGame.viewMarginY, camGame.scroll.x + camGame.viewMarginX + camGame.width, camGame.scroll.y + camGame.viewMarginY +
			camGame.height
		]);
		rainShader.setFloat('uTime', rainTime);
		rainShader.setFloat('uIntensity', rainIntensity);
		
		chromZoomShader.setFloat('aberration', 0.0001);
		chromZoomShader.setFloat('effectTime', 0.0001);
		chromNormalShader.setFloat('rOffset', 0.0001 / 45);
		chromNormalShader.setFloat('bOffset', -0.0001 / 45);
		dramaticCamMovement.setFloat('time', shaderAnim);
	}
}

function onSongStart()
{
	modManager.queueFuncOnce(61 * 4, (s, s2) -> {
		FlxTween.tween(satan.colorTransform, {redMultiplier: 1, blueMultiplier: 1, greenMultiplier: 1}, 2, {ease: FlxEase.sineInOut});
	});
}

function onBeatHit() if (camZooming && ClientPrefs.camZooms && curBeat % beatsPerZoom == 0) wallCam.zoom += 0.015 * camZoomingMult;
