import flixel.effects.particles.FlxEmitter.FlxEmitterMode;
import flixel.effects.particles.FlxParticle;

import funkin.FunkinAssets;
import funkin.game.shaders.MadnessShaders.NTSCGlitch;

import openfl.filters.ShaderFilter;

var overlay;
var street;
var bg;
var cables;
var tumbleWeed;
var rain;
var falseLight;
var ruinsFore;
var lightning;
var fire;
var fog:Map<String, FlxSprite> = ["back1" => null, "back2" => null, "front1" => null, "front2" => null];
var dustEmitter:FlxEmitter;
var ashEmitter:FlxEmitter;
var weedGrp:FlxTypedGroup;
var path = "stages/abandonedStreet/";
var subpath = "delusional/";
var rainShader:FlxRuntimeShader = newShader('rain');
var chromZoomShader:FlxRuntimeShader = newShader('aberration');
var chromNormalShader:FlxRuntimeShader = newShader('aberrationDefault');
var dramaticCamMovement:FlxRuntimeShader = newShader('cameraMovement');
var monitorFilter:FlxRuntimeShader = newShader('monitorFilter');
var glitchFX:NTSCGlitch = new NTSCGlitch();
var glitchIntensity:Float = .1;
var prevIntensity:Float = 1;
var shaderAnim:Float = 0;
var rainTime:Float = 0;
var toggle = false;
var canSpawn = true;
var lyricsVideo;
var minnieVideo;
var deathVideo;

function onLoad()
{
	switch (PlayState.SONG.song) // precache images and characters
	{
		case 'Lunacy':
			addCharacterToList('evilrett-lunacy', 0);
			addCharacterToList('avier-lunaEnd', 1);
			
		case 'Delusional':
			addCharacterToList('evilrett-delusional', 0);
			addCharacterToList('avier-illusion', 0);
			addCharacterToList('avier-delusional', 1);
			addCharacterToList('avier-eyeless', 1);
			addCharacterToList('minnie-false', 1);
			
			FunkinAssets.getGraphicUnsafe(Paths.image(path + subpath + "street-delusional"));
			FunkinAssets.getGraphicUnsafe(Paths.image(path + subpath + "street-bg"));
			FunkinAssets.getGraphicUnsafe(Paths.image(path + subpath + "background"));
			if (!ClientPrefs.shaders) FunkinAssets.getGraphicUnsafe(Paths.image(path + subpath + "heavyRain")); // WHAT THE FUCK????
			FunkinAssets.getGraphicUnsafe(Paths.image(path + subpath + "shading"));
			
			lyricsVideo = new FunkinVideoSprite();
			minnieVideo = new FunkinVideoSprite();
			deathVideo = new FunkinVideoSprite();
			
			lyricsVideo.load(Paths.video('deluLyrics'), [FunkinVideoSprite.muted]);
			minnieVideo.load(Paths.video('minniePart'), [FunkinVideoSprite.muted]);
			deathVideo.load(Paths.video('mickeyDeath'));
			
			falseLight = new FlxSprite().loadGraphic(Paths.image(path + subpath + "falseHope"));
			
			if (!ClientPrefs.lowQuality)
			{
				ruinsFore = new FlxSprite().loadGraphic(Paths.image(path + subpath + "street-foreground"));
				lightning = new FlxSprite();
				lightning.frames = Paths.getSparrowAtlas(path + subpath + "lightning");
				lightning.animation.addByPrefix('lightning', 'lightning', 10, true);
				lightning.animation.play('lightning');
				
				fog["back1"] = new FlxBackdrop(Paths.image(path + subpath + 'smokeBBack'), 0x01, 0, 0);
				fog["back2"] = new FlxBackdrop(Paths.image(path + subpath + 'smokeTBack'), 0x01, 0, 0);
				fog["front1"] = new FlxBackdrop(Paths.image(path + subpath + 'smokeBFore'), 0x01, 0, 0);
				fog["front2"] = new FlxBackdrop(Paths.image(path + subpath + 'smokeTFore'), 0x01, 0, 0);
				
				fog['back1'].velocity.x = 550;
				fog['back2'].velocity.x = -710;
				fog['front1'].velocity.x = 280;
				fog['front2'].velocity.x = -860;
			}
	}
	
	overlay = new FlxSprite().loadGraphic(Paths.image(path + 'i_forgor'));
	overlay.screenCenter();
	overlay.setGraphicSize(FlxG.width, FlxG.height);
	overlay.camera = camOther;
	
	bg = new FlxSprite().loadGraphic(Paths.image(path + 'randomColors'));
	street = new FlxSprite().loadGraphic(Paths.image(path + 'street'));
	weedGrp = new FlxTypedGroup();
	cables = new FlxSprite().loadGraphic(Paths.image(path + 'cables'));
	
	if (!ClientPrefs.lowQuality)
	{
		dustEmitter = new FlxEmitter().loadParticles(Paths.image(path + 'dustParticle'), 500, 16, true);
		ashEmitter = new FlxEmitter();
		
		for (i in 0...100)
		{
			var blackParticle = new FlxParticle();
			blackParticle.frames = Paths.getSparrowAtlas(path + 'ashParticle');
			blackParticle.animation.addByPrefix('idle', 'ashParticle idle', 5, true);
			blackParticle.animation.play('idle');
			blackParticle.exists = false;
			ashEmitter.add(blackParticle);
		}
	}
	
	if (PlayState.SONG.song != 'Isolated')
	{
		if (!ClientPrefs.shaders)
		{
			rain = new FlxSprite();
			rain.frames = Paths.getSparrowAtlas(path + 'rain');
			rain.animation.addByPrefix('Rain', 'Rain', 24, true);
			rain.animation.play('Rain');
		}
		
		fire = new FlxSprite();
		fire.frames = Paths.getSparrowAtlas(path + subpath + 'delusional-fire');
		fire.animation.addByPrefix('fire', 'delusional-fire fire-idle', 24, true);
		fire.animation.play('fire');
	}
	
	add(overlay);
	if (PlayState.SONG.song == 'Delusional') add(falseLight);
	add(bg);
	if (PlayState.SONG.song != 'Isolated') add(fire);
	add(street);
	if (PlayState.SONG.song == 'Delusional')
	{
		add(fog['back1']);
		add(fog['back2']);
	}
}

function onCreatePost()
{
	for (obj in [bg, street, cables])
		obj.scale.set(2.3, 2.3);
		
	bg.y -= 200;
	cables.scale.x += 2;
	cables.scrollFactor.set(2.5, 1.9);
	bg.scrollFactor.set(0.3, 0.3);
	
	if (PlayState.SONG.song != 'Isolated')
	{
		fire.scale.set(4.8, 2.8);
		fire.blend = 11;
		fire.alpha = 0.001;
	}
	
	add(weedGrp);
	if (!ClientPrefs.lowQuality)
	{
		for (emitter in [dustEmitter, ashEmitter])
		{
			emitter.launchMode = FlxEmitterMode.SQUARE;
			emitter.velocity.set(-50, -200, 50, -600, -90, 0, 90, -600);
			emitter.scale.set(4, 4, 4, 4, 0, 0, 0, 0);
			emitter.drag.set(0, 0, 0, 0, 5, 5, 10, 10);
			emitter.width = 4787.45;
			emitter.alpha.set(1, 0.3);
			emitter.lifespan.set(1.9, 4.9);
			emitter.start(false, FlxG.random.float(.0521, .1060), 1000000);
			emitter.setPosition(-1680, 2050);
		}
		ashEmitter.angle.set(290, 0);
		ashEmitter.launchAngle.set(0, 280);
		add(dustEmitter);
		add(ashEmitter);
	}
	add(cables);
	
	if (PlayState.SONG.song == 'Delusional')
	{
		if (ClientPrefs.shaders) rainIntensity = .09;
		canSpawn = false;
		for (i in [bg, street, cables])
			i.alpha = 0.001;
		falseLight.scale.set(2.3, 2.3);
		falseLight.scrollFactor.set(0.3, 0.3);
		if (!ClientPrefs.lowQuality)
		{
			for (i in [fog['back1'], fog['back2'], fog['front1'], fog['front2']])
			{
				i.scrollFactor.set(1.4, 1.2);
				i.scale.set(2.1, 2.1);
				i.alpha = 0.75;
				i.blend = 8;
			}
			lightning.scale.set(1.6, 2.85);
			ruinsFore.scale.set(2.4, 2.4);
			lightning.scrollFactor.set(1.55, 1.55);
			ruinsFore.scrollFactor.set(1.2, 1.2);
			ruinsFore.x -= 200;
			add(fog['front1']);
			add(fog['front2']);
			add(lightning);
			add(ruinsFore);
			fog['front1'].visible = fog['front2'].visible = fog['back1'].visible = fog['back2'].visible = lightning.visible = ruinsFore.visible = false;
		}
		
		for (video in [lyricsVideo, minnieVideo, deathVideo])
		{
			video.onFormat(() -> {
				video.camera = camVideo;
				video.fitToScreen();
			});
			add(video);
		}
	}
	
	if (!ClientPrefs.shaders)
	{
		rain.blend = 0;
		rain.alpha = PlayState.SONG.song == 'Lunacy' ? 0.001 : 0.35;
		add(rain);
	}
	
	if (ClientPrefs.shaders)
	{
		rainShader.setFloatArray('uScreenResolution', [FlxG.width, FlxG.height]);
		rainShader.setFloat('uTime', 0);
		rainShader.setFloat('uScale', FlxG.height / 200);
		rainShader.setFloatArray('rainColor', [0.034, 0.0078, 0.0445]);
		rainShader.setFloat('uIntensity', rainIntensity);
		
		if (!ClientPrefs.lowQuality)
		{
			camGame.filters = [
				new ShaderFilter(dramaticCamMovement),
				new ShaderFilter(monitorFilter),
				new ShaderFilter(chromZoomShader),
				new ShaderFilter(chromNormalShader),
				new ShaderFilter(rainShader)
			];
			camHUD.filters = [new ShaderFilter(chromNormalShader)];
		}
		else
		{
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
		
		if (PlayState.SONG.song == 'Delusional')
		{
			glitchFX.update(elapsed);
			glitchFX.setGlitch(prevIntensity);
			
			prevIntensity = FlxMath.lerp(glitchIntensity, prevIntensity, Math.exp(-elapsed * 1.6));
		}
	}
}

function onSongStart()
{
	switch (PlayState.SONG.song)
	{
		case 'Isolated':
			modManager.queueFuncOnce(159 * 4, (s, s2) -> {
				dad.animSuffix = '-whistle';
			});
			modManager.queueFuncOnce(180 * 4, (s, s2) -> {
				dad.animSuffix = '';
			});
			modManager.queueFuncOnce(351 * 4, (s, s2) -> {
				dad.animSuffix = '-whistle';
			});
			modManager.queueFuncOnce(372 * 4, (s, s2) -> {
				dad.animSuffix = '';
			});
			
		case 'Lunacy':
			modManager.queueFuncOnce(88 * 4, (s, s2) -> {
				dad.playAnim('transition', true);
				dad.specialAnim = true;
			});
			modManager.queueFuncOnce(90 * 4, (s, s2) -> {
				dad.idleSuffix = '-insane';
			});
			modManager.queueFuncOnce(156 * 4, (s, s2) -> {
				changeCharacter('evilrett-lunacy', 0);
			});
			modManager.queueFuncOnce(480 * 4, (s, s2) -> {
				camBars.flash(FlxColor.BLACK, 2);
				if (ClientPrefs.shaders) rainIntensity = .12;
				else rain.alpha = 0.35;
				changeCharacter('avier-lunaEnd', 1);
				dad.idleSuffix = '';
			});
			modManager.queueFuncOnce(536 * 4, (s, s2) -> {
				boyfriend.playAnim('endingAnim', true);
				boyfriend.specialAnim = true;
				boyfriend.idleSuffix = '-end';
			});
			
		case 'Delusional':
			modManager.queueFuncOnce(64 * 4, (s, s2) -> {
				canSpawn = true;
				FlxTween.tween(falseLight, {alpha: 0.001}, 10, {ease: FlxEase.expoOut});
				for (i in [bg, street, cables])
					FlxTween.tween(i, {alpha: 1}, 10, {ease: FlxEase.expoOut});
			});
			modManager.queueFuncOnce(132 * 4, (s, s2) -> {
				FlxTween.tween(camHUD, {alpha: 0.001}, 5, {ease: FlxEase.sineInOut});
				camBars.fade(FlxColor.BLACK, 2.6);
			});
			modManager.queueFuncOnce(142 * 4, (s, s2) -> {
				lyricsVideo.play();
				if (ClientPrefs.shaders) rainIntensity = .33;
				else
				{
					rain.frames = Paths.getSparrowAtlas(path + subpath + 'heavyRain');
					rain.animation.addByPrefix('Rain full', 'Rain full', 24, true);
					rain.animation.play('Rain full');
				}
				camGame.visible = false;
				camBars.fade(FlxColor.BLACK, 3, true);
				fog['front1'].visible = fog['front2'].visible = fog['back1'].visible = fog['back2'].visible = true;
				changeCharacter('avier-delusional', 1);
				changeCharacter('evilrett-delusional', 0);
			});
			modManager.queueFuncOnce(212 * 4, (s, s2) -> {
				camGame.visible = true;
			});
			modManager.queueFuncOnce(216 * 4, (s, s2) -> {
				FlxTween.tween(camHUD, {alpha: 1}, 8, {ease: FlxEase.expoOut});
			});
			modManager.queueFuncOnce(408 * 4, (s, s2) -> {
				canSpawn = false;
				if (ClientPrefs.shaders) FlxTween.tween(game, {rainIntensity: .2}, 2, {ease: FlxEase.sineInOut});
			});
			modManager.queueFuncOnce(472 * 4, (s, s2) -> {
				if (ClientPrefs.shaders) rainIntensity = 0;
				else
				{
					rain.visible = false;
				}
				camGame.visible = false;
				camHUD.alpha = .001;
				cables.visible = false;
				defaultCamZoom = .45;
				fog['front1'].visible = fog['front2'].visible = fog['back1'].visible = fog['back2'].visible = false;
				changeCharacter('avier-illusion', 0);
				changeCharacter('minnie-false', 1);
				bg.loadGraphic(Paths.image(path + subpath + "background"));
				street.loadGraphic(Paths.image(path + subpath + "shading"));
				
				boyfriend.alpha = .001;
				boyfriend.camera = boyfriendGroup.camera = camVideo;
				boyfriend.blend = 12;
				dad.shader = glitchFX;
				for (bg in [bg, street])
				{
					bg.scrollFactor.set(1, 1);
					bg.scale.set(2.8, 2.8);
				}
				street.y -= 300;
				
				timeBar.visible = timeTxt.visible = iconP2.visible = iconP1.visible = healthBar.visible = scoreTxt.visible = false;
			});
			modManager.queueFuncOnce(476 * 4, (s, s2) -> {
				FlxTween.tween(camHUD, {alpha: 1}, 3, {ease: FlxEase.sineInOut});
			});
			modManager.queueFuncOnce(480 * 4, (s, s2) -> {
				camGame.visible = true;
			});
			modManager.queueFuncOnce(508 * 4, (s, s2) -> {
				FlxTween.tween(boyfriend, {alpha: 0.35}, 8, {ease: FlxEase.expoOut});
			});
			modManager.queueFuncOnce(544 * 4, (s, s2) -> {
				if (ClientPrefs.shaders) glitchIntensity = .8;
			});
			modManager.queueFuncOnce(608 * 4, (s, s2) -> {
				bg.shader = street.shader = glitchFX;
				if (ClientPrefs.shaders) glitchIntensity = 1.1;
			});
			modManager.queueFuncOnce(640 * 4, (s, s2) -> {
				if (ClientPrefs.shaders) glitchIntensity = 1.6;
			});
			modManager.queueFuncOnce(656 * 4, (s, s2) -> {
				if (ClientPrefs.shaders) glitchIntensity = 2.1;
			});
			modManager.queueFuncOnce(668 * 4, (s, s2) -> {
				if (ClientPrefs.shaders) glitchIntensity = 2.8;
			});
			modManager.queueFuncOnce(672 * 4, (s, s2) -> {
				minnieVideo.play();
				camGame.visible = false;
				FlxTween.tween(camHUD, {alpha: 0.001}, 5, {ease: FlxEase.sineInOut});
				boyfriend.camera = boyfriendGroup.camera = camGame;
				boyfriend.blend = 10;
				boyfriend.alpha = 1;
				defaultCamZoom = .9;
				falseLight.alpha = .75;
				falseLight.blend = 0;
				if (ClientPrefs.shaders) rainIntensity = .33;
				else
				{
					rain.visible = true;
				}
				if (!ClientPrefs.lowQuality)
				{
					fog['front1'].visible = fog['front2'].visible = fog['back1'].visible = fog['back2'].visible = true;
					fog['front1'].blend = fog['front2'].blend = fog['back1'].blend = fog['back2'].blend = 14;
				}
				dad.shader = bg.shader = street.shader = null;
				bg.loadGraphic(Paths.image(path + subpath + "street-bg"));
				street.loadGraphic(Paths.image(path + subpath + "street-delusional"));
				street.y += 300;
				bg.y += 350;
				for (bg in [bg, street])
					bg.scale.set(2.4, 2.4);
				bg.scrollFactor.set(0.4, 0.4);
				ruinsFore.visible = true;
				changeCharacter('avier-eyeless', 1);
				changeCharacter('evilrett-delusional', 0);
			});
			modManager.queueFuncOnce(744 * 4, (s, s2) -> {
				camGame.visible = true;
				timeBar.visible = timeTxt.visible = iconP2.visible = iconP1.visible = healthBar.visible = scoreTxt.visible = true;
				camHUD.alpha = 1;
			});
			modManager.queueFuncOnce(880 * 4, (s, s2) -> {
				if (ClientPrefs.shaders)
				{
					rainIntensity = .56;
					rainShader.setFloatArray('rainColor', [1.534, 0.1078, 0.2445]);
				}
				lightning.visible = true;
				FlxTween.tween(fire, {alpha: 1}, 10, {ease: FlxEase.expoOut});
			});
	}
}

function onBeatHit()
{
	if (!ClientPrefs.lowQuality && tumbleWeed == null && FlxG.random.bool(3) && canSpawn) summonWeedMakerLmfao();
	if (PlayState.SONG.song == 'Delusional' && ClientPrefs.shaders && curBeat % 4 == 0) prevIntensity += .8;
}

function lunacyRain()
{
	toggle = !toggle;
	
	if (toggle)
	{
		if (ClientPrefs.shaders) FlxTween.tween(game, {rainIntensity: .12}, 0.2, {ease: FlxEase.expoOut});
		else FlxTween.tween(rain, {alpha: .35}, 0.2, {ease: FlxEase.expoOut});
	}
	else
	{
		if (ClientPrefs.shaders) FlxTween.tween(game, {rainIntensity: 0}, 0.2, {ease: FlxEase.expoOut});
		else FlxTween.tween(rain, {alpha: .001}, 0.2, {ease: FlxEase.expoOut});
	}
}

function summonWeedMakerLmfao()
{
	tumbleWeed = new FlxSprite(1800, 520);
	var velocityX:Float = 0;
	var bounceVal:Int = 735;
	var loopTime:Array<Float> = [];
	if (FlxG.random.bool(1))
	{
		tumbleWeed.loadGraphic(Paths.image(path + 'THELEGENDARYTUMBLEWEED'));
		tumbleWeed.scale.set(0.6, 0.6);
		velocityX = -1270;
		bounceVal = 50;
		loopTime[0] = 0.5;
		loopTime[1] = 0.1;
		loopTime[2] = 4;
	}
	else
	{
		tumbleWeed.loadGraphic(Paths.image(path + 'Tumble_' + FlxG.random.int(0, 1)));
		velocityX = -520;
		loopTime[0] = 1.7;
		loopTime[1] = 0.75;
		loopTime[2] = 5.6;
	}
	tumbleWeed.velocity.set(velocityX, 0);
	weedGrp.add(tumbleWeed);
	FlxTween.tween(tumbleWeed, {angle: -360}, loopTime[0], {type: 2});
	FlxTween.tween(tumbleWeed, {y: bounceVal}, loopTime[1], {ease: FlxEase.sineInOut, type: 4});
	new FlxTimer().start(loopTime[2], function(tmr:FlxTimer) {
		tumbleWeed.kill();
		tumbleWeed = null;
	});
}

function opponentNoteHit(note) if (dad.animSuffix == "-whistle" && !note.isSustainNote) whistleNotes();

function onEvent(eventName, value1, valuw2)
{
	switch (eventName)
	{
		case 'Lunacy Rain':
			lunacyRain();
	}
}

function whistleNotes()
{
	var path:String = 'UI/bdaynotes';
	var particleNote:FlxSprite = new FlxSprite().loadGraphic(Paths.image('$path/note_${FlxG.random.int(1, 3)}'));
	particleNote.setGraphicSize(Std.int(particleNote.width * 0.5));
	particleNote.updateHitbox();
	particleNote.angle = FlxG.random.float(-15, 18);
	particleNote.setColorTransform(-1, -1, -1, 1, 128, 128, 128, 0);
	particleNote.x = dadGroup.x + 450;
	particleNote.y = dadGroup.y + 500;
	particleNote.alpha = 0.0001;
	particleNote.velocity.x -= dadGroup.y - 475;
	particleNote.angularDrag = FlxG.random.float(-100, 100);
	particleNote.angularAcceleration = FlxG.random.float(-100, 100);
	particleNote.acceleration.x = FlxG.random.int(-160, -250);
	FlxTween.tween(particleNote, {alpha: 1}, .5, {ease: FlxEase.sineInOut});
	
	FlxTween.tween(particleNote, {y: particleNote.y - FlxG.random.int(70, 130)}, FlxG.random.float(0.5, 2), {ease: FlxEase.sineInOut, type: 4});
	
	FlxTween.tween(particleNote, {alpha: 0.0001}, 1,
		{
			ease: FlxEase.sineInOut,
			startDelay: 0.75,
			onComplete: function(tween:FlxTween) {
				particleNote.destroy();
			}
		});
	dadGroup.insert(0, particleNote);
}
