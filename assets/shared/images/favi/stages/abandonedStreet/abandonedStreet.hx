// Base Assets
var colorsOrSmthElse:FNFSprite;
var floor:FNFSprite;
var stageCurtains:FNFSprite;
var stageFront:FNFSprite;

var atmosphereParticle:FlxEmitter;
var ashParticle:FlxEmitter;

var rain:FlxSprite;
var tumbleWeed:FlxSprite;

var streetDaytime:FlxSprite;
var clouds:FlxSprite;
var brightSky:FlxSprite;

var streetRuins:FlxSprite;
var fakeLightOfHope:FlxSprite;

var fireThing:FlxSprite;
var fireThing2:FlxSprite; // what the fuck what the fuck what the fuck what the fuck what the fuck what the fuck
var fireForeground:FlxSprite;

var fireTweenHandler:FlxTween;

var fireParticle:FlxEmitter;

var smokeShit:FlxTypedGroup<FlxSprite>;
var smokeFore:FlxTypedGroup<FlxSprite>;

var spriteShit:Array<String> = ['bigSmoke', 'smallSmoke', 'smallSmoke', 'bigSmoke'];
var spriteShitForeground:Array<String> = ['bigSmoke', 'bigSmoke', 'smallSmoke', 'bigSmoke'];

var pathWay:String = 'data/stages/abandonedStreet/images';

function onCreate()
{
	spawnGirlfriend(false);
	PlayState.defaultCamZoom = 0.87;
	PlayState.cameraSpeed = 1;
	
	colorsOrSmthElse = new FNFSprite(-990, 1600).loadGraphic(Paths.image('randomColors', pathWay));
	colorsOrSmthElse.setGraphicSize(Std.int(colorsOrSmthElse.width * 4));
	colorsOrSmthElse.updateHitbox();
	colorsOrSmthElse.antialiasing = true;
	colorsOrSmthElse.screenCenter();
	colorsOrSmthElse.scale.set(3, 3);
	colorsOrSmthElse.scrollFactor.set(0.9, 0.9);
	colorsOrSmthElse.active = false;
	add(colorsOrSmthElse);

	fireThing = new FlxSprite(0, -80);
	fireThing.scale.set(5.85, 3);
	fireThing.alpha = 0.0001;
	fireThing.frames = Paths.getSparrowAtlas('delusional-fire', pathWay);
	fireThing.animation.addByPrefix('burning', 'delusional-fire fire-idle', 16, true);
	fireThing.scrollFactor.set(0.8, 0.8);
	add(fireThing);
	fireThing.animation.play('burning');
	
	floor = new FNFSprite(-20, 200).loadGraphic(Paths.image('street', pathWay));
	floor.antialiasing = true;
	floor.scale.set(2.5, 2.3);
	floor.scrollFactor.set(1, 1);
	floor.active = false;
	add(floor);	

	if (PlayState.SONG.song == 'Delusional' || PlayState.SONG.song == 'Delusion')
	{
		brightSky = new FlxSprite(-990, 1600).loadGraphic(Paths.image('brightSky', pathWay));
		brightSky.setGraphicSize(Std.int(brightSky.width * 4));
		brightSky.updateHitbox();
		brightSky.antialiasing = true;
		brightSky.screenCenter();
		brightSky.scale.set(3, 3);
		brightSky.scrollFactor.set(0.9, 0.9);
		add(brightSky);

		if (!lowQuality)
		{
			clouds = new FlxSprite(-990, 1600).loadGraphic(Paths.image('clouds', pathWay));
			clouds.setGraphicSize(Std.int(clouds.width * 4));
			clouds.updateHitbox();
			clouds.antialiasing = true;
			clouds.screenCenter();
			clouds.scale.set(3, 3);
			clouds.scrollFactor.set(1.1, 1.1);
			add(clouds);
			clouds.visible = false;
		}

		streetDaytime = new FlxSprite(-20, 200).loadGraphic(Paths.image('streetDay', pathWay));
		streetDaytime.antialiasing = true;
		streetDaytime.scale.set(2.5, 2.3);
		streetDaytime.scrollFactor.set(1, 1);
		add(streetDaytime);

		fakeLightOfHope = new FlxSprite(-990, 1600).loadGraphic(Paths.image('falseHope', pathWay));
		fakeLightOfHope.setGraphicSize(Std.int(fakeLightOfHope.width * 4));
		fakeLightOfHope.updateHitbox();
		fakeLightOfHope.antialiasing = true;
		fakeLightOfHope.screenCenter();
		fakeLightOfHope.scale.set(3, 3);
		fakeLightOfHope.scrollFactor.set(0.9, 0.9);
		add(fakeLightOfHope);

		fireThing2 = new FlxSprite(0, -80);
		fireThing2.scale.set(5.85, 3);
		fireThing2.alpha = 0.0001;
		fireThing2.frames = Paths.getSparrowAtlas('delusional-fire', pathWay);
		fireThing2.animation.addByPrefix('burning', 'delusional-fire fire-idle', 16, true);
		fireThing2.scrollFactor.set(0.8, 0.8);
		fireThing2.blend = EngineTools.returnBlendMode('add');
		add(fireThing2);
		fireThing2.animation.play('burning');

		streetRuins = new FlxSprite(-20, 200).loadGraphic(Paths.image('streetDestroyed', pathWay));
		streetRuins.antialiasing = true;
		streetRuins.scale.set(2.5, 2.3);
		streetRuins.scrollFactor.set(1, 1);
		add(streetRuins);

		if (!lowQuality)
		{
			smokeShit = new FlxTypedGroup();
			add(smokeShit);

			for (i in 0...spriteShit.length)
			{
				var smoke:FlxSprite = new FlxSprite(0, 550);
				smoke.ID = i;
				smoke.frames = Paths.getSparrowAtlas(spriteShit[i], pathWay);
				smoke.animation.addByPrefix('smoke', spriteShit[i] + ' idle', 4, true);
				smoke.scale.set(1.3, 1.35);
				smoke.alpha = 0.001;
				smoke.blend = EngineTools.returnBlendMode('add');
				smoke.animation.play('smoke');
				switch (smoke.ID)
				{
					case 0: smoke.x -= 620;
					case 1: smoke.x += 650;
					case 2: smoke.x -= 60;
					case 3: smoke.x += 1100;
				}
				smokeShit.add(smoke);
			}

			smokeFore = new FlxTypedGroup();
			foreground.add(smokeFore);

			for (i in 0...spriteShitForeground.length)
			{
				var smoke:FlxSprite = new FlxSprite(0, 670);
				smoke.ID = i;
				smoke.frames = Paths.getSparrowAtlas(spriteShitForeground[i], pathWay);
				smoke.animation.addByPrefix('smoke', spriteShitForeground[i] + ' idle', 4, true);
				smoke.scale.set(1.6, 1.4);
				smoke.alpha = 0.001;
				smoke.blend = EngineTools.returnBlendMode('add');
				smoke.animation.play('smoke');
				switch (smoke.ID)
				{
					case 0: smoke.x -= 620;
					case 1: smoke.x += 540;
					case 2: smoke.x -= 60;
					case 3: smoke.x += 1100;
				}
				smokeFore.add(smoke);
			}

			fireForeground = new FlxSprite(0, 550);
			fireForeground.scale.set(7.8, 5);
			fireForeground.alpha = 0.001;
			fireForeground.frames = Paths.getSparrowAtlas('delusional-fire', pathWay);
			fireForeground.animation.addByPrefix('burningShit', 'delusional-fire fire-idle', 16, true);
			fireForeground.scrollFactor.set(1.35, 1.18);
			fireForeground.blend = EngineTools.returnBlendMode('add');
			foreground.add(fireForeground);
			fireForeground.animation.play('burningShit');

			/*fireParticle = new FlxEmitter(-2080.5, 2150.4);
			fireParticle.launchMode = 'square';
			fireParticle.velocity.set(-50, -200, 50, -600, -90, 0, 90, -600);
			fireParticle.scale.set(4, 4, 4, 4, 0, 0, 0, 0);
			fireParticle.drag.set(0, 0, 0, 0, 5, 5, 10, 10);
			fireParticle.width = 4787.45;
			fireParticle.alpha.set(1, 1);
			fireParticle.lifespan.set(1.9, 4.9);
			fireParticle.loadParticles(Paths.image('fireParticle', pathWay), 500, 16, true);
			fireParticle.start(false, FlxG.random.float(.0521, .1060), 1000000);
			foreground.add(fireParticle);*/
		}

		brightSky.visible = false;
		streetDaytime.visible = false;
		streetRuins.visible = false;
	}
	
	if(!lowQuality)
		{
			stageCurtains = new FNFSprite(0, 0).loadGraphic(Paths.image('i_forgor', pathWay));
			stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
			stageCurtains.updateHitbox();
			stageCurtains.screenCenter();
			stageCurtains.scale.set(1.3,1.3);
			stageCurtains.antialiasing = true;
			stageCurtains.cameras = [PlayState.camAlt];
			stageCurtains.scrollFactor.set(1.3, 1.3);
			add(stageCurtains);	

			atmosphereParticle = new FlxEmitter(-2080.5, 2000);
			atmosphereParticle.launchMode = 'square';
			atmosphereParticle.velocity.set(-50, -200, 50, -600, -90, 0, 90, -600);
			atmosphereParticle.scale.set(4, 4, 4, 4, 0, 0, 0, 0);
			atmosphereParticle.drag.set(0, 0, 0, 0, 5, 5, 10, 10);
			atmosphereParticle.width = 4787.45;
			atmosphereParticle.alpha.set(1, 0.3);
			atmosphereParticle.lifespan.set(1.9, 4.9);
			atmosphereParticle.loadParticles(Paths.image('dustParticle', pathWay), 500, 16, true);
			atmosphereParticle.start(false, FlxG.random.float(.0521, .1060), 1000000);
			foreground.add(atmosphereParticle);

			ashParticle = new FlxEmitter(-2080.5, 2150.4);
			for (i in 0 ... 100)
				{
					var blackParticle = new FlxParticle();
					blackParticle.frames = Paths.getSparrowAtlas('ashParticle', pathWay);
					blackParticle.animation.addByPrefix('idle', 'ashParticle idle', 5, true);
					blackParticle.animation.play('idle');
					blackParticle.exists = false;
					blackParticle.animation.curAnim.curFrame = FlxG.random.int(0, 9);
					ashParticle.add(blackParticle);
				}
			ashParticle.launchMode = 'circle';
			ashParticle.velocity.set(-50, -200, 50, -600, -90, 0, 90, -600);
			ashParticle.scale.set(4, 4, 4, 4, 0, 0, 0, 0);
			ashParticle.drag.set(0, 0, 0, 0, 5, 5, 10, 10);
			ashParticle.width = 4787.45;
			ashParticle.alpha.set(1, 1);
			ashParticle.lifespan.set(1.9, 4.9);
			ashParticle.start(false, FlxG.random.float(.0521, .1060), 1000000);
			ashParticle.angle.set(290, 0);
			ashParticle.launchAngle.set(250, 210, 270, 290, 300);
			foreground.add(ashParticle);

			stageFront = new FNFSprite(-3000, 130).loadGraphic(Paths.image('cables', pathWay));
			stageFront.scale.set(9, 2.1);
			stageFront.updateHitbox();
			stageFront.antialiasing = true;
			stageFront.scrollFactor.set(5, 2.6);
			stageFront.active = false;
			foreground.add(stageFront);
			
			rain = new FlxSprite(-550, -900);
			rain.frames = Paths.getSparrowAtlas('rain', pathWay);
			rain.animation.addByPrefix('drippin', 'Rain', 30, true);
			rain.scale.set(2, 2);
			rain.alpha = 0.0001;
			foreground.add(rain);
			rain.animation.play('drippin');

			if (PlayState.SONG.song == 'Delusion')
			{
				streetDaytime.visible = true;
				clouds.visible = true;
				brightSky.visible = true;
			}

			if (PlayState.SONG.song == 'Delusional') stageFront.alpha = 0.001;
		}

		if (PlayState.SONG.song == 'Delusional') {
			PlayState.camGame.fade(0x000000, .0001);
		}
}

function onBeat(curBeat:Int, boyfriend:Character, gf:Character, dad:Character)
{
	if (!lowQuality)
	{
		if (FlxG.random.bool(3))
		{
			if (PlayState.SONG.song == 'Delusional')
			{
				if (curBeat < 474)
					summonWeedMakerLmfao();
			}
			else
			{
				summonWeedMakerLmfao();
			}
		}
	}

	if (PlayState.SONG.song == 'Lunacy')
	{
		if (!lowQuality)
		{
			if (curBeat == 228 || curBeat == 238 || curBeat == 244 || curBeat == 252 || curBeat == 260 || curBeat == 270 || curBeat == 276 || curBeat == 284 || curBeat == 292 || curBeat == 300 || curBeat == 308 || curBeat == 316 || curBeat == 324 || curBeat == 332 || curBeat == 340 || curBeat == 248)
			{
				if (fireTweenHandler != null)
					fireTweenHandler.cancel();

				fireTweenHandler = FlxTween.tween(fireThing, {alpha: 0.75, y: -250}, 0.35, {ease: EngineTools.returnTweenEase('sineOut'), onComplete: function(twn:FlxTween)
					{
						fireTweenHandler = null;
					}
				});
			}
			if (curBeat == 230 || curBeat == 240 || curBeat == 248 || curBeat == 256 || curBeat == 262 || curBeat == 272 || curBeat == 280 || curBeat == 288 || curBeat == 296 || curBeat == 304 || curBeat == 312 || curBeat == 320 || curBeat == 328 || curBeat == 336 || curBeat == 344 || curBeat == 352)
			{
				if (fireTweenHandler != null)
					fireTweenHandler.cancel();

				fireTweenHandler = FlxTween.tween(fireThing, {alpha: 0.0001, y: -80}, 0.35, {ease: EngineTools.returnTweenEase('sineOut'), onComplete: function(twn:FlxTween)
					{
						fireTweenHandler = null;
					}
				});
			}
			if (curBeat == 416)
			{
				if (fireTweenHandler != null)
					fireTweenHandler.cancel();

				fireTweenHandler = FlxTween.tween(fireThing, {alpha: 1, y: -350}, 19.5, {ease: EngineTools.returnTweenEase('sineInOut'), onComplete: function(twn:FlxTween)
					{
						fireTweenHandler = null;
					}
				});
			}
			if (curBeat == 480)
			{
				fireThing.alpha = 0.35;
				fireThing.y = -120;
			}
			if (curBeat == 536)
			{
				fireTweenHandler = FlxTween.tween(fireThing, {alpha: 0, y: 0}, 1, {ease: EngineTools.returnTweenEase('sineOut'), onComplete: function(twn:FlxTween)
					{
						fireTweenHandler = null;
					}
				});
			}
		}
	}
	if (PlayState.SONG.song == 'Delusion')
	{
		if (curBeat == 24)
		{
			FlxTween.tween(streetDaytime, {alpha: 0}, 5);
			FlxTween.tween(clouds, {alpha: 0}, 5);
			FlxTween.tween(brightSky, {alpha: 0}, 5);
		}
		if (curBeat == 232)
		{
			fakeLightOfHope.visible = true;
			streetRuins.visible = true;
		}
	}
	if (PlayState.SONG.song == 'Delusional')
	{
		if (curBeat == 1)
		{
			PlayState.camGame.fade(0x000000, 3, true);
		}
		if (curBeat == 64)
		{
			FlxTween.tween(fakeLightOfHope, {alpha: 0.001}, 1.7);
			if (!lowQuality) FlxTween.tween(stageFront, {alpha: 1}, 1.5);
		}
		if (curBeat == 176)
		{
			if (rain != null && !lowQuality)
				rain.alpha = 1;
		}
		if (curBeat == 280)
		{
			if (!lowQuality)
			{
				smokeShit.forEach(function(spr:FlxSprite)
				{
					FlxTween.tween(spr, {alpha: 0.55}, 1.5);
				});
				smokeFore.forEach(function(spr:FlxSprite)
					{
						FlxTween.tween(spr, {alpha: 0.55}, 1.5);
				});
			}
		}
		if (curBeat == 312)
		{
			FlxTween.tween(fireThing, {alpha: 1}, 1);
			//smokeParticles.emitting = true;
		} 
		if (curBeat == 336)
		{
			if (!lowQuality)
			{
				smokeShit.forEach(function(spr:FlxSprite)
				{
					FlxTween.tween(spr, {alpha: 0.25}, 1.5);
				});
				smokeFore.forEach(function(spr:FlxSprite)
				{
						FlxTween.tween(spr, {alpha: 0.25}, 1.5);
				});
			}
		}
		if (curBeat == 474) // load daytime street assets
		{
			colorsOrSmthElse.visible = false;
			//smokeParticles.emitting = false;
			fireThing.alpha = 0;
			floor.visible = false;
			if (!lowQuality)
			{
				smokeShit.forEach(function(spr:FlxSprite)
					{
						spr.alpha = 0;
					});
					smokeFore.forEach(function(spr:FlxSprite)
					{
						spr.alpha = 0;
					});
				rain.visible = false;
				clouds.visible = true;
				stageCurtains.visible = false;
				stageFront.visible = false;
			}
			brightSky.visible = true;
			streetDaytime.visible = true;
		}
		if (curBeat == 740) // go back to the street in a even more decayed state
		{
			fireThing2.alpha = 0.75;
			//smokeParticles.emitting = true;
			//fireParticles.emitting = true;
			if (!lowQuality)
			{
				fireForeground.alpha = 0.6;
				smokeShit.forEach(function(spr:FlxSprite)
					{
						spr.alpha = 0.7;
					});
					smokeFore.forEach(function(spr:FlxSprite)
					{
						spr.alpha = 0.74;
					});
				rain.visible = true;
				clouds.visible = false;
				stageCurtains.visible = true;
			}
			streetRuins.visible = true;
			fakeLightOfHope.alpha = 0.5;
			brightSky.visible = false;
			streetDaytime.visible = false;
		}
		if (curBeat == 1136)
		{
			fireThing2.alpha = 0;
			if (!lowQuality)
				{
					fireForeground.alpha = 0;
					smokeShit.forEach(function(spr:FlxSprite)
						{
							spr.alpha = 0;
						});
						smokeFore.forEach(function(spr:FlxSprite)
						{
							spr.alpha = 0;
						});
					rain.visible = false;
					clouds.visible = false;
					stageCurtains.visible = true;
				}
				streetRuins.visible = false;
				fakeLightOfHope.alpha = 0;
				brightSky.visible = false;
				streetDaytime.visible = false;
		}
	}
}
	
function charStagePos(boyfriend:Character, gf:Character, dad:Character)
{
	switch (dad.curCharacter)
	{
		case 'delusional-mickey':
			dad.setPosition(-260, 120);
		case 'mickey-delu-intro':
			dad.setPosition(-210, 180);
		case 'death-part-1':
			dad.setPosition(-450, 100);
		case 'death-part-2':
			dad.setPosition(-430, 100);
		default:
			dad.setPosition(-870, -190);
	}

	switch (boyfriend.curCharacter)
	{
		case 'bf-demon': boyfriend.setPosition(550, 190);
		case 'bf-delu-intro': boyfriend.setPosition(750, 350);
		default: boyfriend.setPosition(275, 50);
	}
}

function summonWeedMakerLmfao()
{
	if (FlxG.random.bool(1))
	{
		tumbleWeed = new FlxSprite(1800, 490).loadGraphic(Paths.image('THELEGENDARYTUMBLEWEED', pathWay));
		tumbleWeed.scale.set(0.6, 0.6);
		FlxTween.tween(tumbleWeed, {angle: -360}, 0.5, {type: EngineTools.returnTweenType('looping')});
		foreground.add(tumbleWeed);

		FlxTween.tween(tumbleWeed, {y: 825}, 0.1, {ease: EngineTools.returnTweenEase('sineInOut'), type: EngineTools.returnTweenType('pingpong')});

		FlxTween.tween(tumbleWeed, {x: -1200}, 2, {onComplete: function(twn:FlxTween)
		{
			tumbleWeed.kill();
		}});
	}
	else
	{
		tumbleWeed = new FlxSprite(1800, 600).loadGraphic(Paths.image('Tumble_' + FlxG.random.int(0,1), pathWay));
		FlxTween.tween(tumbleWeed, {angle: -360}, 1.7, {type: EngineTools.returnTweenType('looping')});
		foreground.add(tumbleWeed);

		FlxTween.tween(tumbleWeed, {y: 735}, 0.75, {ease: EngineTools.returnTweenEase('sineIn'), type: EngineTools.returnTweenType('pingpong')});

		FlxTween.tween(tumbleWeed, {x: -1200}, 5.6, {onComplete: function(twn:FlxTween)
		{
			tumbleWeed.kill();
		}});
	}
}