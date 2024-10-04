package objects;

import base.dependency.FeatherDeps.ScriptHandler;
import flixel.FlxBasic;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxParticle;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxGradient;
import base.song.Conductor;
import openfl.filters.ShaderFilter;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import states.PlayState;

class Stage extends FlxTypedGroup<FlxBasic>
{
	//

	/**
	 * FUNKIN.AVI STAGE ASSETS
	 */

	 //DEVILISH DEAL
	 var gradient:FlxSprite;
	 var bg:FlxSprite;
	 var overlay:FlxSprite;

	 //MICKEY STAGE ASSETS
	 public static var colorsOrSmthElse:FlxSprite;
	 public static var floor:FlxSprite;
	 public static var stageCurtains:FlxSprite;
	 public static var stageFront:FlxSprite;
	 public static var atmosphereParticle:FlxEmitter;
	 public static var ashParticle:FlxEmitter;
	 public static var rain:FlxSprite;
	 public static var tumbleWeed:FlxSprite;
	 public static var streetDaytime:FlxSprite;
	 public static var clouds:FlxSprite;
	 public static var brightSky:FlxSprite;
	 public static var streetRuins:FlxSprite;
	 public static var fakeLightOfHope:FlxSprite;
	 public static var fireThing:FlxSprite;
	 public static var fireThing2:FlxSprite; // what the fuck what the fuck what the fuck what the fuck what the fuck what the fuck
	 public static var fireForeground:FlxSprite;
	 public static var fireTweenHandler:FlxTween;
	 public static var fireParticle:FlxEmitter;
	 public static var smokeShit:FlxTypedGroup<FlxSprite>;
	 public static var smokeFore:FlxTypedGroup<FlxSprite>;
	 public static var spriteShit:Array<String> = ['bigSmoke', 'smallSmoke', 'smallSmoke', 'bigSmoke'];
	 public static var spriteShitForeground:Array<String> = ['bigSmoke', 'bigSmoke', 'smallSmoke', 'bigSmoke'];
	 public static var pathWay:String = 'stages/abandonedStreet/images';

	//HUNTED FNF
	var wobblyBG:FlxRuntimeShader;
	var treesFront:FlxSprite;
	var goofyStreet:FlxSprite;
	var treesBack:FlxSprite;
	var goofyBG:FlxSprite;

	//WAR DILEMMA
	var defaultPath:String = 'stages/war/stuff';

	//LAUGH TRACK
	var circusPath:String = 'stages/circus/e';

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
	var lightI:FlxSprite;
	var flairI:FlxSprite;

	//NEGLECTION
	var mascotRoom:FlxSprite;
	var mascotRoomPOV:FlxSprite;

	//MALFUNCTION
	var mickeyEmitter:FlxEmitter;
	var fuckingsquares:FlxSprite;
	var whiteBG:FlxSprite;
	var glitchBG:FlxRuntimeShader;
	var staticBG:FlxRuntimeShader;
	var accessPath:String;

	//MERCY
	var pissOfGlory:FlxSprite;
	var greaterPiss:FlxSprite;

	//DELUTRANCE SHADER LMFAO
	var totallyAwsomeShader:FlxRuntimeShader;

	//OLD CYCLED SINS
	var bg1:FlxSprite;
	var bg2:FlxSprite;

	//SCRAPPED
	var datTV:FlxSprite;
	var redGradThing:FlxSprite = new FlxSprite(-1200, 0).makeGraphic(FlxG.width, 1, 0xFFAA00AA);
	var canZoom:Bool = false;

	//SHADER UPDATE SHIT
	var updateShader:Float = 0;

	/**
	 * END OF STAGE ASSETS
	 */

	 //BASE STAGE SCRIPT SHIT
	public var gfVersion:String = 'gf';

	public var curStage:String;

	public var foreground:FlxTypedGroup<FlxBasic>;
	public var layers:FlxTypedGroup<FlxBasic>;

	public var spawnGirlfriend:Bool = true;
	public var spawnSecondaryOpponent:Bool = false;
	public var hideBoyfriend:Bool = false;
	public static var lowQuality:Bool = false;

	public var stageScript:ScriptHandler;

	public var sendMessage:Bool = false;
	public var messageText:String = '';

	public function new(curStage:String)
	{
		super();

		this.curStage = curStage;

		// to apply to foreground use foreground.add(); instead of add();
		foreground = new FlxTypedGroup<FlxBasic>();
		layers = new FlxTypedGroup<FlxBasic>();

		setStage(curStage);
	}

	public function setStage(curStage:String)
	{
		if (curStage == null || curStage.length < 1)
		{
			if (PlayState.SONG.stage == null || PlayState.SONG.stage.length < 1)
				curStage = 'stage';
			else
				curStage = PlayState.SONG.stage;
		}

		//
		createStage(curStage);
		reloadGroups();

		/*try
		{
			//
			callStageScript();
		}
		catch (e)
		{
			sendMessage = true;
			messageText = '[GAME STAGE]: Uncaught Error: $e';
		}*/
	}

	public function createStage(curStage:String)
	{
		lowQuality = ClientPrefs.lowQuality; //pissy wissy

		switch (curStage)
		{
			case 'abandonedStreet':
				spawnGirlfriend = false;
				PlayState.defaultCamZoom = 0.87;
				PlayState.cameraSpeed = 1;
				
				colorsOrSmthElse = new FlxSprite(-990, 1600).loadGraphic(Paths.image('randomColors', pathWay));
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
				fireThing.antialiasing = ClientPrefs.globalAntialiasing;
				fireThing.animation.play('burning');
				
				floor = new FlxSprite(-20, 200).loadGraphic(Paths.image('street', pathWay));
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
					fireThing.antialiasing = ClientPrefs.globalAntialiasing;
					fireThing2.animation.play('burning');

					streetRuins = new FlxSprite(-20, 200).loadGraphic(Paths.image('streetDestroyed', pathWay));
					streetRuins.antialiasing = true;
					streetRuins.scale.set(2.5, 2.3);
					streetRuins.scrollFactor.set(1, 1);
					streetRuins.antialiasing = ClientPrefs.globalAntialiasing;
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
							smoke.antialiasing = ClientPrefs.globalAntialiasing;
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
							smoke.antialiasing = ClientPrefs.globalAntialiasing;
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
						fireForeground.antialiasing = ClientPrefs.globalAntialiasing;

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
						stageCurtains = new FlxSprite(0, 0).loadGraphic(Paths.image('i_forgor', pathWay));
						stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
						stageCurtains.updateHitbox();
						stageCurtains.screenCenter();
						stageCurtains.scale.set(1.3,1.3);
						stageCurtains.antialiasing = true;
						stageCurtains.cameras = [PlayState.camAlt];
						stageCurtains.scrollFactor.set(1.3, 1.3);
						add(stageCurtains);	

						atmosphereParticle = new FlxEmitter(-2080.5, 2000);
						atmosphereParticle.launchMode = SQUARE;
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
						ashParticle.launchMode = SQUARE;
						ashParticle.velocity.set(-50, -200, 50, -600, -90, 0, 90, -600);
						ashParticle.scale.set(4, 4, 4, 4, 0, 0, 0, 0);
						ashParticle.drag.set(0, 0, 0, 0, 5, 5, 10, 10);
						ashParticle.width = 4787.45;
						ashParticle.alpha.set(1, 1);
						ashParticle.lifespan.set(1.9, 4.9);
						ashParticle.start(false, FlxG.random.float(.0521, .1060), 1000000);
						ashParticle.angle.set(290, 0);
						ashParticle.launchAngle.set(0, 280);
						foreground.add(ashParticle);

						stageFront = new FlxSprite(-3000, 130).loadGraphic(Paths.image('cables', pathWay));
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
						rain.antialiasing = ClientPrefs.globalAntialiasing;
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
						PlayState.camBars.fade(0x000000, .0001);
					}
			case 'forestNew':
				// Literally what Goofy is seeing right about now lmfao
				wobblyBG = new FlxRuntimeShader(Shaders.acidTrip, null, 120);

				wobblyBG.setFloat('uSpeed', 1.0);
				wobblyBG.setFloat('uFrequency', 1.0);
				wobblyBG.setFloat('uWaveAmplitude', 0.5);

				spawnGirlfriend = false;
				PlayState.cameraSpeed = 0.9;
				PlayState.defaultCamZoom = 0.65;

				if(!lowQuality)
					{
						goofyBG = new FlxSprite(-600, -650).loadGraphic(Paths.image('bg', 'data/stages/forestNew/images'));
						goofyBG.scrollFactor.set(0.7, 0.7);
						goofyBG.scale.set(1.2, 1.2);
						goofyBG.screenCenter();
						goofyBG.antialiasing = ClientPrefs.globalAntialiasing;
						add(goofyBG);
					}

				treesBack = new FlxSprite(-550, -650).loadGraphic(Paths.image('treesBack', 'data/stages/forestNew/images'));
				treesBack.scale.set(1.3, 1.2);
				treesBack.scrollFactor.set(1, 0.8);
				treesBack.antialiasing = ClientPrefs.globalAntialiasing;
				add(treesBack);

				goofyStreet = new FlxSprite(-700, -950).loadGraphic(Paths.image('ground', 'data/stages/forestNew/images'));
				goofyStreet.scale.set(2, 1.9);
				goofyStreet.scrollFactor.set(1, 1);
				goofyStreet.antialiasing = ClientPrefs.globalAntialiasing;
				add(goofyStreet);

				if(!lowQuality)
					{
						treesFront = new FlxSprite(-550, -650).loadGraphic(Paths.image('treesFront', 'data/stages/forestNew/images'));
						treesFront.scale.set(1.5, 1.5);
						treesFront.scrollFactor.set(1.2, 1.2);
						foreground.add(treesFront);
						treesFront.antialiasing = ClientPrefs.globalAntialiasing;
					}
			case 'forestOld':
				spawnGirlfriend = false;

				var forest:FlxSprite = new FlxSprite(-180, -350).loadGraphic(Paths.image('forest', 'data/stages/forestOld'));
				forest.antialiasing = ClientPrefs.globalAntialiasing;
				add(forest);
			case 'theLoop':
				spawnGirlfriend = false;
				PlayState.defaultCamZoom = 0.85;
			
				var street:FlxSprite = new FlxSprite(-500, -700).loadGraphic(Paths.image('Mickeybg', 'data/stages/theLoop/images'));
				street.antialiasing = ClientPrefs.globalAntialiasing;
				add(street);
			
				if(!lowQuality)
					{
						var grainstuff:FlxSprite = new FlxSprite(0, 0);
						grainstuff.frames = Paths.getSparrowAtlas('Grainshit', 'data/stages/theLoop/images');
						grainstuff.animation.addByPrefix('yucky', 'grains 1', 24, true);
						grainstuff.animation.play('yucky');
						grainstuff.cameras = [PlayState.camHUD];
						grainstuff.scale.set(3, 3);
						grainstuff.screenCenter();
						grainstuff.antialiasing = ClientPrefs.globalAntialiasing;
						add(grainstuff);
					}
			case 'war':
				PlayState.defaultCamZoom = .6;
				PlayState.cameraSpeed = .67;
			
				var sky = new FlxSprite(-1280 * PlayState.defaultCamZoom, -720 * PlayState.defaultCamZoom, Paths.image('sky', defaultPath));
				sky.scrollFactor.set(.07, .05);
				sky.antialiasing = ClientPrefs.globalAntialiasing;
				add(sky);
			
				var sun = new FlxSprite(-1280 * PlayState.defaultCamZoom, -720 * PlayState.defaultCamZoom, Paths.image('sun', defaultPath));
				sun.scrollFactor.set(.13, .09);
				sun.antialiasing = ClientPrefs.globalAntialiasing;
				add(sun);
			
				var bg = new FlxSprite(-1280 * PlayState.defaultCamZoom, -720 * PlayState.defaultCamZoom, Paths.image('bg', defaultPath));
				bg.scrollFactor.set(.32, .27);
				bg.antialiasing = ClientPrefs.globalAntialiasing;
				add(bg);
			
				var semibg = new FlxSprite(-1280 * PlayState.defaultCamZoom, -720 * PlayState.defaultCamZoom, Paths.image('semibackground', defaultPath));
				semibg.scrollFactor.set(.52, .48);
				semibg.scale.set(1.23, 1.23);
				semibg.updateHitbox();
				semibg.antialiasing = ClientPrefs.globalAntialiasing;
				add(semibg);
			
				var things = new FlxSprite(-1280 * PlayState.defaultCamZoom, -720 * PlayState.defaultCamZoom, Paths.image('things', defaultPath));
				things.scrollFactor.set(.73, .64);
				things.scale.set(1.25, 1.25);
				things.updateHitbox();
				things.antialiasing = ClientPrefs.globalAntialiasing;
				add(things);
			
				var ground = new FlxSprite(-1280 * PlayState.defaultCamZoom, -720 * PlayState.defaultCamZoom, Paths.image('ground', defaultPath));
				ground.scrollFactor.set(1, 1);
				ground.scale.set(1.35, 1.35);
				ground.updateHitbox();
				ground.antialiasing = ClientPrefs.globalAntialiasing;
				add(ground);
			
				spawnGirlfriend = false;
			case 'circus' | 'my name is caine and welcome to the amazing digital circus':
				PlayState.defaultCamZoom = 2.1;

				var sky = new FlxSprite(-1280 * .25,  -720 * .2, Paths.image('sky', defaultPath));
				sky.scrollFactor.set(.05, .05);
				sky.scale.set(.75, .75);
				sky.updateHitbox();
				sky.antialiasing = ClientPrefs.globalAntialiasing;
				add(sky);
			
				var floor = new FlxSprite(-1280, -720, Paths.image('floor', defaultPath));
				floor.scale.set(1.1, 1.1);
				floor.antialiasing = ClientPrefs.globalAntialiasing;
				add(floor);
			
				var tent = new FlxSprite(-1280, -720, Paths.image('tent', defaultPath));
				tent.antialiasing = ClientPrefs.globalAntialiasing;
				add(tent);
				
				var tentsfront = new FlxSprite(-1280 * 1.2, -720, Paths.image('tentsfront', defaultPath));
				tentsfront.scrollFactor.set(1.25, 1.25);
				tentsfront.scale.set(1.15, 1.15);
				tentsfront.antialiasing = ClientPrefs.globalAntialiasing;
				foreground.add(tentsfront);
			case 'treasureIsland':
				spawnGirlfriend = false;

				mascotRoom = new FlxSprite(0, 0).loadGraphic(Paths.image("mascotRoom", "data/stages/treasureIsland/images"));
				mascotRoom.scale.set(1.4, 1.4);
				mascotRoom.antialiasing = ClientPrefs.globalAntialiasing;
				add(mascotRoom);

				mascotRoomPOV = new FlxSprite(-500, 0).loadGraphic(Paths.image("mascotRoomPOV", "data/stages/treasureIsland/images"));
				mascotRoomPOV.scale.set(1.4, 1.4);
				mascotRoomPOV.alpha = 0.0001;
				mascotRoomPOV.antialiasing = ClientPrefs.globalAntialiasing;
				add(mascotRoomPOV);
			case 'clubhouse':
				PlayState.defaultCamZoom = 1.25;
				PlayState.cameraSpeed = 50;

				var clubhouse:FlxSprite = new FlxSprite(-410, -100);
				clubhouse.frames = Paths.getSparrowAtlas('daHouse', 'data/stages/clubhouse/images');
				clubhouse.animation.addByPrefix('balloons bounce', 'daHouse idle', 12, true);
				clubhouse.animation.play('balloons bounce');
				clubhouse.scale.set(1.15, 1.15);
				clubhouse.updateHitbox();
				clubhouse.antialiasing = true;
				clubhouse.scrollFactor.set(1, 1);
				clubhouse.antialiasing = ClientPrefs.globalAntialiasing;
				add(clubhouse);

				var vignette:FlxSprite = new FlxSprite(-250, -140).loadGraphic(Paths.image('vignetteOverlay', 'data/stages/clubhouse/images'));
				vignette.cameras = [PlayState.camAlt];
				vignette.scale.set(0.75, 0.75);
				vignette.antialiasing = true;
				vignette.scrollFactor.set();
				vignette.active = false;
				vignette.antialiasing = ClientPrefs.globalAntialiasing;
				add(vignette);
			case 'desktop':
				PlayState.defaultCamZoom = 0.9;

				var desktopThing:FlxSprite = new FlxSprite(-500, -100).loadGraphic(Paths.image('desktop', 'data/stages/desktop'));
				desktopThing.scale.set(1.3, 1);
				desktopThing.antialiasing = ClientPrefs.globalAntialiasing;
				add(desktopThing);
			case 'forbiddenRealm':
				PlayState.defaultCamZoom = 0.8;
				spawnGirlfriend = false;

				accessPath = PlayState.SONG.song == 'Malfunction Legacy' ? 'PixelMouse' : 'malfunctionBG-NEW';
				
				staticBG = new FlxRuntimeShader(Shaders.tvStatic, null, 120);
				glitchBG = new FlxRuntimeShader(Shaders.vignetteGlitch, null, 130);

				fuckingsquares = new FlxSprite(-750, -850);
				fuckingsquares.loadGraphic(Paths.image(accessPath, 'data/stages/forbiddenRealm/images'));
				fuckingsquares.scale.set(1.2, 1);
				fuckingsquares.updateHitbox();
				fuckingsquares.antialiasing = false;
				fuckingsquares.scrollFactor.set(1, 1);
				fuckingsquares.active = false;
				fuckingsquares.antialiasing = ClientPrefs.globalAntialiasing;
				add(fuckingsquares);

				var greyParticles:FlxEmitter = new FlxEmitter(-2080.5, 650.4);
				greyParticles.launchMode = SQUARE;
				greyParticles.velocity.set(-50, -200, 50, -600, -90, 0, 90, -600);
				greyParticles.scale.set(4, 4, 4, 4, 0, 0, 0, 0);
				greyParticles.drag.set(0, 0, 0, 0, 5, 5, 10, 10);
				greyParticles.width = 4787.45;
				greyParticles.alpha.set(1, 1);
				greyParticles.lifespan.set(1.9, 4.9);
				greyParticles.loadParticles(Paths.image('greyParticle', 'data/stages/forbiddenRealm/images'), 500, 16, true);
				greyParticles.start(false, FlxG.random.float(.0521, .1060), 1000000);
				greyParticles.antialiasing = ClientPrefs.globalAntialiasing;

				var blackParticles:FlxEmitter = new FlxEmitter(-2080.5, 912.4);
				blackParticles.launchMode = SQUARE;
				blackParticles.velocity.set(-70, -220, 70, -620, -110, 20, 110, -620);
				blackParticles.scale.set(6, 6, 6, 6, 2, 2, 2, 2);
				blackParticles.drag.set(2, 2, 2, 2, 7, 7, 12, 12);
				blackParticles.width = 4787.45;
				blackParticles.alpha.set(1, 1);
				blackParticles.lifespan.set(1.9, 4.9);
				blackParticles.loadParticles(Paths.image('particleBlack', 'data/stages/forbiddenRealm/images'), 500, 16, true);
				blackParticles.start(false, FlxG.random.float(.0821, .1460), 1000000);
				blackParticles.antialiasing = ClientPrefs.globalAntialiasing;
				
				mickeyEmitter = new FlxEmitter(-2099.8, 1620.4);
				for (i in 0 ... 100)
				{
					var mickeyParticle = new FlxParticle();
					mickeyParticle.frames = Paths.getSparrowAtlas('mickParticle', 'data/stages/forbiddenRealm/images');
					mickeyParticle.animation.addByPrefix('mickParticle idle', 'mickParticle idle', 12, true);
					mickeyParticle.animation.play('mickParticle idle');
					mickeyParticle.exists = false;
					mickeyParticle.animation.curAnim.curFrame = FlxG.random.int(0, 3);
					mickeyParticle.antialiasing = ClientPrefs.globalAntialiasing;
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
				mickeyEmitter.antialiasing = ClientPrefs.globalAntialiasing;
				
				whiteBG = new FlxSprite(-800, -200).makeGraphic(1, 1, 0xFFFFFFFF);
				whiteBG.scale.set(FlxG.width, FlxG.height);
				whiteBG.alpha = 0.001;
				whiteBG.active = false;
				add(whiteBG);
				
				if (PlayState.SONG.song != 'Malfunction Legacy')
				{
					add(greyParticles);
					foreground.add(blackParticles);
					foreground.add(mickeyEmitter);
				}
			case 'trueGrinsOfSins':
				PlayState.defaultCamZoom = 0.75;
				PlayState.cameraSpeed = 2.5;

				var office:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.image('office', 'data/stages/trueGrinsOfSins/images'));
				office.antialiasing = true;
				office.scrollFactor.set(1, 1);
				office.active = false;
				add(office);

				var chair:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.image('chair', 'data/stages/trueGrinsOfSins/images'));
				chair.antialiasing = true;
				chair.scrollFactor.set(1, 1);
				chair.active = false;
				add(chair);

				var funiLight:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.image('light', 'data/stages/trueGrinsOfSins/images'));
				funiLight.antialiasing = true;
				funiLight.scrollFactor.set(1, 1);
				funiLight.alpha = 0.6;
				funiLight.blend = ADD;
				funiLight.active = false;
				foreground.add(funiLight);

				office.scale.set(0.85, 0.8);
				chair.scale.set(0.9, 0.85);
				funiLight.scale.set(0.85, 0.8);
			case 'vaultRoom':
				spawnGirlfriend = false;

				vault = new FlxSprite(-200, -100).loadGraphic(Paths.image('vault', 'data/stages/vaultRoom/images'));
				vault.scale.set(2.45, 2.3);
				vault.antialiasing = ClientPrefs.globalAntialiasing;
				add(vault);

				chains = new FlxSprite(-225, -100).loadGraphic(Paths.image('chains1', 'data/stages/vaultRoom/images'));
				chains.scale.set(2.5, 2.3);
				chains.scrollFactor.set(1.2, 1.25);
				chains.antialiasing = ClientPrefs.globalAntialiasing;

				chains2 = new FlxSprite(-225, -100).loadGraphic(Paths.image('chains2', 'data/stages/vaultRoom/images'));
				chains2.scale.set(2.5, 2.3);
				chains2.scrollFactor.set(1.1, 1.2);
				chains2.antialiasing = ClientPrefs.globalAntialiasing;

				chains3 = new FlxSprite(-225, -100).loadGraphic(Paths.image('chains3', 'data/stages/vaultRoom/images'));
				chains3.scale.set(2.5, 2.3);
				chains3.scrollFactor.set(1, 1.15);
				chains3.antialiasing = ClientPrefs.globalAntialiasing;

				light = new FlxSprite(-200, -100).loadGraphic(Paths.image('lightSource', 'data/stages/vaultRoom/images'));
				light.blend = DIFFERENCE;
				light.alpha = 0.37;
				light.scrollFactor.set(0.95, 1);
				light.scale.set(2.45, 2.3);
				light.antialiasing = ClientPrefs.globalAntialiasing;

				flair = new FlxSprite(-200, -100).loadGraphic(Paths.image('lightFlair', 'data/stages/vaultRoom/images'));
				flair.blend = SCREEN;
				flair.alpha = 0.6;
				flair.scrollFactor.set(1.4, 1.25);
				flair.scale.set(2.5, 2.4);
				flair.antialiasing = ClientPrefs.globalAntialiasing;

				thingy = new FlxSprite(-200, -100).loadGraphic(Paths.image('darkness', 'data/stages/vaultRoom/images'));
				thingy.scale.set(2.45, 2.3);
				thingy.antialiasing = ClientPrefs.globalAntialiasing;

				foreground.add(chains3);
				foreground.add(chains2);
				foreground.add(chains);
				foreground.add(light);
				foreground.add(flair);
				foreground.add(thingy);

				vaultI = new FlxSprite(-200, -100).loadGraphic(Paths.image('vaultInvert', 'data/stages/vaultRoom/images'));
				vaultI.scale.set(2.45, 2.3);
				vaultI.visible = false;
				add(vaultI);

				chainsI = new FlxSprite(-225, -100).loadGraphic(Paths.image('chainsI1', 'data/stages/vaultRoom/images'));
				chainsI.scale.set(2.5, 2.3);
				chainsI.scrollFactor.set(1.2, 1.25);
				chainsI.visible = false;
				chainsI.antialiasing = ClientPrefs.globalAntialiasing;

				chainsI2 = new FlxSprite(-225, -100).loadGraphic(Paths.image('chainsI2', 'data/stages/vaultRoom/images'));
				chainsI2.scale.set(2.5, 2.3);
				chainsI2.scrollFactor.set(1.1, 1.2);
				chainsI2.visible = false;
				chainsI2.antialiasing = ClientPrefs.globalAntialiasing;

				chainsI3 = new FlxSprite(-225, -100).loadGraphic(Paths.image('chainsI3', 'data/stages/vaultRoom/images'));
				chainsI3.scale.set(2.5, 2.3);
				chainsI3.scrollFactor.set(1, 1.15);
				chainsI3.visible = false;
				chainsI3.antialiasing = ClientPrefs.globalAntialiasing;

				lightI = new FlxSprite(-200, -100).loadGraphic(Paths.image('lightInvert', 'data/stages/vaultRoom/images'));
				lightI.blend = DIFFERENCE;
				lightI.alpha = 0.37;
				lightI.scrollFactor.set(0.95, 1);
				lightI.scale.set(2.45, 2.3);
				lightI.visible = false;
				lightI.antialiasing = ClientPrefs.globalAntialiasing;

				flairI = new FlxSprite(-200, -100).loadGraphic(Paths.image('flairInvert', 'data/stages/vaultRoom/images'));
				flairI.blend = SCREEN;
				flairI.alpha = 0.6;
				flairI.scrollFactor.set(1.4, 1.25);
				flairI.scale.set(2.5, 2.4);
				flairI.visible = false;
				flairI.antialiasing = ClientPrefs.globalAntialiasing;

				thingyI = new FlxSprite(-200, -100).loadGraphic(Paths.image('brighter', 'data/stages/vaultRoom/images'));
				thingyI.scale.set(2.45, 2.3);
				thingyI.visible = false;
				thingyI.antialiasing = ClientPrefs.globalAntialiasing;

				foreground.add(chainsI3);
				foreground.add(chainsI2);
				foreground.add(chainsI);
				foreground.add(lightI);
				foreground.add(flairI);
				foreground.add(thingyI);
			case 'waltRoom':
				spawnGirlfriend = false;
				hideBoyfriend = true;
				
				PlayState.health = 1; // Coding it in PlayState.hx breaks for some reason
				PlayState.defaultCamZoom = 0.75;

				if (PlayState.SONG.song == 'Mercy')
				{
					PlayState.camGame.alpha = 0;
					PlayState.camHUD.alpha = 0;
					//PlayState.dadStrums.visible = false;

					pissOfGlory = new FlxSprite(-470, -280);
					pissOfGlory.loadGraphic(Paths.image('newWaltBG', 'data/stages/waltRoom/images'));
					pissOfGlory.scale.set(1.7, 1.7);
				}else{
					pissOfGlory = new FlxSprite(-450, -300);
					pissOfGlory.loadGraphic(Paths.image('walt-bg', 'data/stages/waltRoom/images'));
					pissOfGlory.scale.set(1, 1);
				}
				pissOfGlory.updateHitbox();
				pissOfGlory.antialiasing = true;
				pissOfGlory.scrollFactor.set(1, 1);
				pissOfGlory.active = false;
				add(pissOfGlory);

				greaterPiss = new FlxSprite(-60, -70);
				greaterPiss.loadGraphic(Paths.image('inkWaltBG', 'data/stages/waltRoom/images'));
				greaterPiss.scale.set(1.7, 1.7);
				greaterPiss.alpha = 0;
				greaterPiss.antialiasing = ClientPrefs.globalAntialiasing;
				add(greaterPiss);

				if(!lowQuality)
					{
						var vignette:FlxSprite = new FlxSprite(-250, -140).loadGraphic(Paths.image('vignetteOverlay', 'data/stages/waltRoom/images'));
						vignette.cameras = [PlayState.camAlt];
						vignette.scale.set(0.75, 0.75);
						vignette.antialiasing = true;
						vignette.scrollFactor.set();
						vignette.active = false;
						vignette.antialiasing = ClientPrefs.globalAntialiasing;
						add(vignette);
					}
			case 'trance':
				spawnGirlfriend = false;
				PlayState.defaultCamZoom = 1;

				var bg:FlxSprite = new FlxSprite();
				bg.frames = Paths.getSparrowAtlas('background', "data/stages/trance");
				bg.animation.addByPrefix("lmao", "background lmao", 24, true);
				bg.scale.set(5, 5);
				bg.antialiasing = ClientPrefs.globalAntialiasing;
				add(bg);
				bg.animation.play("lmao");

				totallyAwsomeShader = new FlxRuntimeShader(Shaders.unregisteredHyperCam2Quality, null, 140);
				totallyAwsomeShader.setFloat('size', 7.5);
				if(!Init.trueSettings.get('Disable Screen Shaders')) FlxG.game.setFilters([new ShaderFilter(totallyAwsomeShader)]);
			case 'apartment':
				spawnGirlfriend = false;
				PlayState.defaultCamZoom = 0.6;
				PlayState.cameraSpeed = 0.9;

				//Phase 2 shaders
				glitchBG = new FlxRuntimeShader(Shaders.vignetteGlitch, null, 130);

				bg1 = new FlxSprite(0, 50);
				bg1.frames = Paths.getSparrowAtlas('relapse1', 'data/stages/apartment/images');
				bg1.animation.addByPrefix('idle', 'Bg bg', 10, true);
				bg1.scale.set(7, 7);
				bg1.antialiasing = false;
				bg1.animation.play('idle');
				bg1.antialiasing = ClientPrefs.globalAntialiasing;
				add(bg1);

				bg2 = new FlxSprite(0, 50).loadGraphic(Paths.image('relapse2', 'data/stages/apartment/images'));
				bg2.scale.set(7, 7);
				bg2.antialiasing = false;
				bg2.visible = false;
				bg2.antialiasing = ClientPrefs.globalAntialiasing;
				add(bg2);
			case 'staticVoid':
				spawnGirlfriend = false;
				hideBoyfriend = true;
				
				PlayState.defaultCamZoom = 0.45;	
			
				var thePath:String = 'data/stages/staticVoid/images';

				var whoaBlackBG:FlxSprite = new FlxSprite(0, 0).makeGraphic(1, 1, 0x000000);
				whoaBlackBG.scale.set(FlxG.width * 4, FlxG.height * 4);
				whoaBlackBG.screenCenter();
				add(whoaBlackBG);

				datTV = new FlxSprite(-250, -160);
				datTV.frames = Paths.getSparrowAtlas('white', thePath);
				datTV.animation.addByPrefix('idle', 'white idle');
				datTV.animation.play('idle');
				datTV.scale.set(0.6, 0.6);
				datTV.alpha = 0.001;
				datTV.antialiasing = ClientPrefs.globalAntialiasing;
				add(datTV);

				if(!lowQuality)
					{
						redGradThing = FlxGradient.createGradientFlxSprite(2130, 512, [0x00940606, 0x55BF0606, 0xAAFC0505], 1, 90, true);
						redGradThing.x = -740;
						redGradThing.y = 770;
						redGradThing.scale.y = 0;
						redGradThing.updateHitbox();
						//add(redGradThing);
					}
			case 'smilesOffice':
				spawnGirlfriend = false;
				PlayState.defaultCamZoom = 0.9;
				PlayState.cameraSpeed = 2;

				var office:FlxSprite = new FlxSprite(-100, -100).loadGraphic(Paths.image('office', 'data/stages/smilesOffice/images'));
				office.scale.set(1, 1);
				office.updateHitbox();
				office.antialiasing = true;
				office.scrollFactor.set(1, 1);
				office.active = false;
				add(office);

				var funiLight:FlxSprite = new FlxSprite(-100, -100).loadGraphic(Paths.image('officeLight', 'data/stages/smilesOffice/images'));
				funiLight.scale.set(1, 1);
				funiLight.updateHitbox();
				funiLight.antialiasing = true;
				funiLight.scrollFactor.set(1, 1);
				funiLight.alpha = 0.6;
				funiLight.blend = ADD;
				funiLight.active = false;
				foreground.add(funiLight);
			case 'fuckingLine':
				spawnGirlfriend = false;

				var whiteVoid:FlxSprite = new FlxSprite().makeGraphic(FlxG.width * 5, FlxG.height * 5, EngineTools.returnColor('white'));
				whiteVoid.screenCenter();
				add(whiteVoid);

				var line:FlxSprite = new FlxSprite(-80, 0).loadGraphic(Paths.image('theLine', 'data/stages/fuckingLine'));
				line.scale.set(1.3, 1.3);
				line.antialiasing = ClientPrefs.globalAntialiasing;
				add(line);
			case 'alleyway' | 'ddStage':
				spawnGirlfriend = false;   

				bg = new FlxSprite(-600, 130).loadGraphic(Paths.image("dd-bg", "data/stages/ddStage/images"));
				bg.scale.set(0.75, 0.75);
				bg.antialiasing = ClientPrefs.globalAntialiasing;
				add(bg);
			
				overlay = new FlxSprite(-640, 170).loadGraphic(Paths.image("dd-overlay", "data/stages/ddStage/images"));
				overlay.scrollFactor.set(1.15, 1.15);
				overlay.antialiasing = ClientPrefs.globalAntialiasing;
				foreground.add(overlay);
				
				gradient = new FlxSprite().loadGraphic(Paths.image('UI/gimmicks/gradient'));
				gradient.cameras = [PlayState.camAlt];
				gradient.screenCenter();
				gradient.scale.set(0.5, 0.5);
				gradient.alpha = 0;
				gradient.antialiasing = ClientPrefs.globalAntialiasing;
				add(gradient);
			default:
				curStage = 'stage';
				PlayState.defaultCamZoom = 0.9;
				PlayState.cameraSpeed = 1;
			
				var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('stageback', 'data/stages/stage/images'));
				bg.antialiasing = true;
				bg.scrollFactor.set(0.9, 0.9);
				bg.active = false;
				add(bg);
			
				var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.image('stagefront', 'data/stages/stage/images'));
				stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
				stageFront.updateHitbox();
				stageFront.antialiasing = true;
				stageFront.scrollFactor.set(0.9, 0.9);
				stageFront.active = false;
				add(stageFront);
			
				var stageCurtains:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.image('stagecurtains', 'data/stages/stage/images'));
				stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
				stageCurtains.updateHitbox();
				stageCurtains.antialiasing = true;
				stageCurtains.scrollFactor.set(1.3, 1.3);
				stageCurtains.active = false;
				add(stageCurtains);
		}
	}

	public function reloadGroups()
	{
		foreground.forEach(function(a:Dynamic)
		{
			if (a != null && !Std.isOfType(a, #if (flixel <= "5.2.2") flixel.system.FlxSound #else flixel.sound.FlxSound #end))
				remove(a);
		});

		layers.forEach(function(a:Dynamic)
		{
			if (a != null && !Std.isOfType(a, #if (flixel <= "5.2.2") flixel.system.FlxSound #else flixel.sound.FlxSound #end))
				remove(a);
		});
	}

	public function dadPosition(curStage:String, boyfriend:Character, gf:Character, dad:Character, mom:Character, camPos:FlxPoint):Void

	public function repositionPlayers(curStage:String, boyfriend:Character, gf:Character, dad:Character, mom:Character)
	{
		switch (curStage)
		{
			case 'abandonedStreet':
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
			case 'forestNew':
				dad.setPosition(-290, 90);
				boyfriend.setPosition(850, 0);
			case 'forestOld':
				dad.setPosition(0, 0);
    			boyfriend.setPosition(900, -20);
			case 'theLoop':
				dad.setPosition(0, 0);
				if (boyfriend.curCharacter == 'bf')
				{
					boyfriend.setPosition(1000, 130);
				}else{
					boyfriend.setPosition(500, -320);
				}
			case 'war':
				dad.setPosition(-140, 30);
   	 			boyfriend.setPosition(1450, 650);
			case 'circus' | 'my name is caine and welcome to the amazing digital circus':
				dad.setPosition(-990, -100);
				boyfriend.setPosition(200, 100);
				gf.setPosition(-300, -200);
			case 'treasureIsland':
				boyfriend.setPosition(1080, 310);
				dad.setPosition(0, 190);
			case 'clubhouse':
				switch (dad.curCharacter)
				{
					case 'munpet':
						dad.setPosition(-240, 0);
					default:
						dad.setPosition(-240, -260);
				}
				switch (boyfriend.curCharacter)
				{
					case 'xyloboy':
						boyfriend.setPosition(650, -100);
					default:
						boyfriend.setPosition(650, -360);
				}
				gf.setPosition(280, -410);
			case 'desktop':
				boyfriend.setPosition(300, 400);
				gf.setPosition(250, 600);
				dad.setPosition(-1100, 350);
			case 'forbiddenRealm':
				if (dad.curCharacter == 'gm-calm-pixel')
					dad.setPosition(-130, 50);
				else
					dad.setPosition(-100, 150);
				
				boyfriend.setPosition(1300, 600);
			case 'trueGrinsOfSins':
				boyfriend.setPosition(1300, 400);
				dad.setPosition(0, 0);
			case 'vaultRoom':
				boyfriend.setPosition(960, 530);
				if (dad.curCharacter == 'white-noise-new') dad.setPosition(-680, -520); else dad.setPosition(90, 60);
			case 'waltRoom':
				switch (dad.curCharacter)
				{
					case 'walt-true':
						dad.setPosition(240, -200);
					case 'walt-new':
						dad.setPosition(220, -50);
					default:
						dad.setPosition(0, 0);
				}
				boyfriend.setPosition(330, 300);
			case 'trance':
				dad.setPosition(-861, -259);
				boyfriend.setPosition(260, 0);
			case 'apartment':
				dad.setPosition(-1000, 270);
    			boyfriend.setPosition(590, 250);
			case 'smilesOffice':
				boyfriend.setPosition(1000, 300);
				dad.setPosition(200, 400);
			case 'fuckingLine':
				dad.setPosition(-400, -150);
				boyfriend.setPosition(900, 300);
			case 'alleyway' | 'ddStage':
				boyfriend.setPosition(250, -30);
				dad.setPosition(1660, 120);
			default:
				boyfriend.setPosition(770, 450);
				dad.setPosition(100, 100);
				mom.setPosition(150, 50);
				gf.setPosition(300, 100);
		}
	}

	public function stageUpdate(curBeat:Int, boyfriend:Character, gf:Character, dad:Character, mom:Character)
	{
		switch (curStage)
		{
			case 'abandonedStreet':
				switch (PlayState.SONG.song)
					{
						case 'Lunacy':
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
						case 'Delusional':
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
								if (curBeat == 744 || curBeat == 752 || curBeat == 760 || curBeat == 768 || curBeat == 772 || curBeat == 776 || curBeat == 784 || curBeat == 792 || curBeat == 800 || curBeat == 804 ||
									curBeat == 808 || curBeat == 816 || curBeat == 824 || curBeat == 832 || curBeat == 836 || curBeat == 840 || curBeat == 848 || curBeat == 856 || curBeat == 864 || curBeat == 868 ||
									curBeat == 880 || curBeat == 884 || curBeat == 888 || curBeat == 892 || curBeat == 896 || curBeat == 900 || curBeat == 904 || curBeat == 908 || curBeat == 913 || curBeat == 916 ||
									curBeat == 920 || curBeat == 924 || curBeat == 929 || curBeat == 933 || curBeat == 936 || curBeat == 940 || curBeat == 944 || curBeat == 948 || curBeat == 952 || curBeat == 956 ||
									curBeat == 960 || curBeat == 964 || curBeat == 968 || curBeat == 972 || curBeat == 976 || curBeat == 980 || curBeat == 984 || curBeat == 988 || curBeat == 993 || curBeat == 997 ||
									curBeat == 1000 || curBeat == 1004)
								{
									fakeLightOfHope.alpha = 1;
									FlxTween.tween(fakeLightOfHope, {alpha: 0.5}, 0.85);
								}
								if (curBeat == 872)
								{
									FlxTween.tween(fakeLightOfHope, {alpha: 1, color: FlxColor.RED}, 2, {ease: FlxEase.circInOut});
									FlxTween.tween(fireThing2, {color: FlxColor.RED}, 2, {ease: FlxEase.circInOut});
									FlxTween.tween(streetRuins, {color: FlxColor.RED}, 2, {ease: FlxEase.circInOut});
									if (!lowQuality)
									{
										FlxTween.tween(fireForeground, {color: FlxColor.RED}, 2, {ease: FlxEase.circInOut});
										FlxTween.tween(rain, {color: FlxColor.RED}, 2, {ease: FlxEase.circInOut});
										smokeShit.forEach(function(spr:FlxSprite)
										{
											FlxTween.tween(spr, {color: FlxColor.RED}, 2, {ease: FlxEase.circInOut});
										});
										smokeFore.forEach(function(spr:FlxSprite)
										{
											FlxTween.tween(spr, {color: FlxColor.RED}, 2, {ease: FlxEase.circInOut});
										});
									}
								}
								if (curBeat == 880)
								{
									FlxTween.tween(fakeLightOfHope, {color: FlxColor.WHITE}, 0.5, {ease: FlxEase.circOut});
									FlxTween.tween(fireThing2, {color: FlxColor.fromRGB(252, 193, 141)}, 0.5, {ease: FlxEase.circOut});
									FlxTween.tween(streetRuins, {color: FlxColor.WHITE}, 0.5, {ease: FlxEase.circOut});
									if (!lowQuality)
									{
										FlxTween.tween(fireForeground, {color: FlxColor.fromRGB(255, 171, 138)}, 0.5, {ease: FlxEase.circOut});
										FlxTween.tween(rain, {color: FlxColor.fromRGB(252, 141, 141)}, 0.5, {ease: FlxEase.circOut});
										smokeShit.forEach(function(spr:FlxSprite)
										{
											FlxTween.tween(spr, {color: FlxColor.WHITE}, 0.5, {ease: FlxEase.circOut});
										});
										smokeFore.forEach(function(spr:FlxSprite)
										{
											FlxTween.tween(spr, {color: FlxColor.WHITE}, 0.5, {ease: FlxEase.circOut});
										});
									}
								}
								if (curBeat == 1008)
								{
									FlxTween.tween(fakeLightOfHope, {alpha: 0}, 2);
									FlxTween.tween(fireThing2, {alpha: 1}, 2);
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
				
					/*if (PlayState.SONG.song == 'Delusion')
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
					}*/
			case 'forestNew':
				if (!Init.trueSettings.get('Disable Screen Shaders'))
					{
						if (curBeat == 192)
						{	
							if(!lowQuality && goofyBG != null && treesFront != null)
								{
									goofyBG.shader = wobblyBG;
									goofyStreet.shader = wobblyBG;
									treesBack.shader = wobblyBG;
									treesFront.shader = wobblyBG;
								}
						}
					}
					
				if (curBeat == 256)
					{
						if(!lowQuality && treesFront != null && goofyBG != null)
							{
								goofyBG.shader = null;
								goofyStreet.shader = null;
								treesBack.shader = null;
								treesFront.shader = null;
							}
					}
			case 'treasureIsland':
				if (curBeat == 256)
					FlxTween.tween(mascotRoom, {alpha: 0}, 1.5);
				if (curBeat == 264)
					FlxTween.tween(mascotRoomPOV, {alpha: 1}, 1.5);
				if (curBeat == 332)
				{
					mascotRoom.alpha = 1;
					mascotRoomPOV.visible = false;
				}
			case 'forbiddenRealm':
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
			case 'vaultRoom':
				if(curBeat == 544)
					{
						vault.visible = false;
						chains.visible = false;
						thingy.visible = false;
						chains2.visible = false;
						chains3.visible = false;
						light.visible = false;
						flair.visible = false;
				
						vaultI.visible = true;
						chainsI.visible = true;
						thingyI.visible = true;
						chainsI2.visible = true;
						chainsI3.visible = true;
						lightI.visible = true;
						flairI.visible = true;
					}
				
					if(curBeat == 608)
					{
						vault.visible = true;
						chains.visible = true;
						thingy.visible = true;
						chains2.visible = true;
						chains3.visible = true;
						light.visible = true;
						flair.visible = true;
				
						vaultI.visible = false;
						chainsI.visible = false;
						thingyI.visible = false;
						chainsI2.visible = false;
						chainsI3.visible = false;
						lightI.visible = false;
						flairI.visible = false;
					}
			case 'apartment':
				if (PlayState.SONG.song == "Cycled Sins Legacy")
					{
						if (curBeat == 144)
						{
							bg1.visible = false;
							bg2.visible = true;
							bg2.shader = glitchBG;
						}
					}
			case 'staticVoid':
				if(curBeat == 32)
					{
						PlayState.defaultCamZoom = 0.85;
					}
				
				if (curBeat == 104)
				{
					datTV.alpha = 1;
			
					if(!Init.trueSettings.get('Reduced Movements'))
					canZoom = true;
			
					if(!Init.trueSettings.get('Disable Flashing Lights'))
					PlayState.camGame.flash(EngineTools.returnColor("white"), 1);
				}
			
				if(curBeat == 168)
					canZoom = false;
			
				if(curBeat == 232) {
					if(!Init.trueSettings.get('Reduced Movements'))
					canZoom = true;
			
					if(!Init.trueSettings.get('Disable Flashing Lights'))
					PlayState.camGame.flash(EngineTools.returnColor("white"), 1);
				}
			
				if(curBeat == 356)
					{
						PlayState.defaultCamZoom = 0.95;
					}
			
				if(curBeat == 360)
					{
						PlayState.defaultCamZoom = 0.85;
			
						if(!Init.trueSettings.get('Disable Flashing Lights'))
						PlayState.camGame.flash(EngineTools.returnColor("white"), 1);
					}
			
				if(curBeat == 424)
					{
						FlxTween.tween(PlayState.camHUD, {alpha: 0}, 2, {ease: FlxEase.cubeInOut});
						for(bullShit in PlayState.strumHUD)
							FlxTween.tween(bullShit, {alpha: 0}, 2.3, {ease: FlxEase.cubeInOut});
					}
				
				/*if (curBeat == 136 || curBeat == 140 || curBeat == 144 || curBeat == 148 || curBeat == 152 || curBeat == 156 || curBeat == 160 || curBeat == 164)
					if(!lowQuality && redGradThing != null)
						FlxTween.tween(redGradThing.scale, {y: 1.5}, 0.5, {ease: FlxEase.quadInOut});
				
				if (curBeat == 138 || curBeat == 142 || curBeat == 146 || curBeat == 150 || curBeat == 154 || curBeat == 158 || curBeat == 162 || curBeat == 166)
					if(!lowQuality && redGradThing != null)
						FlxTween.tween(redGradThing.scale, {y: 0}, 0.5, {ease: FlxEase.quadInOut});*/
			
				if(canZoom && curBeat % 1 == 0)
					{
						PlayState.camGame.zoom += 0.015;
						PlayState.camHUD.zoom += 0.04;
			
						for(_strumHUD in PlayState.strumHUD)
							_strumHUD.zoom += 0.04;
					}
			case 'alleyway' | 'ddStage':
				 // me when zoom gets higher or whatever -jason
				 if(curBeat >= 64 && curBeat < 95)
					{
						FlxG.camera.zoom += 0.025;
						PlayState.camHUD.zoom += 0.042;
						for(whyIsItAnArray in PlayState.strumHUD) whyIsItAnArray.zoom = PlayState.camHUD.zoom;
						FlxTween.tween(gradient, {alpha: 0.3}, 2);
					}
		
				if(curBeat >= 96 && curBeat < 111)
					{
						FlxG.camera.zoom += 0.04;
						PlayState.camHUD.zoom += 0.053;
						for(whyIsItAnArray in PlayState.strumHUD) whyIsItAnArray.zoom = PlayState.camHUD.zoom;
						FlxTween.tween(gradient, {alpha: 0.6}, 2);
					}
		
				if(curBeat == 112)
					{
						FlxTween.tween(FlxG.camera, {zoom: 2}, 14, {ease: FlxEase.sineInOut});
						FlxTween.tween(gradient, {alpha: 0.9}, 2);
					}
		
				if(curBeat >= 112) // doesn't make sense to but a "&& curBeat < idk"
					{
						// not including camGame cus it bugs out
						PlayState.camHUD.zoom += 0.053;
						for(whyIsItAnArray in PlayState.strumHUD) whyIsItAnArray.zoom = PlayState.camHUD.zoom;
					}
		}
	}

	public function stageUpdateSteps(curStep:Int, boyfriend:Character, gf:Character, dad:Character, mom:Character)
	{

	}

	public function stageUpdateConstant(elapsed:Float, boyfriend:Character, gf:Character, dad:Character, mom:Character)
	{
		updateShader = Conductor.songPosition / 1000;
		switch (curStage)
		{
			case 'forestNew':
				wobblyBG.setFloat('uTime', updateShader);
			case 'forbiddenRealm':
				glitchBG.setFloat('time', updateShader);
				glitchBG.setFloat('prob', updateShader);
				staticBG.setFloat('uTime', updateShader);
				staticBG.setFloat('iTime', updateShader);
			case 'apartment':
				glitchBG.setFloat('time', updateShader);
				glitchBG.setFloat('prob', updateShader);
		}
	}

	override public function add(Object:FlxBasic):FlxBasic
	{
		if (Init.trueSettings.get('Disable Antialiasing') && Std.isOfType(Object, FlxSprite))
			cast(Object, FlxSprite).antialiasing = false;
		return super.add(Object);
	}

	function summonWeedMakerLmfao()
		{
			if (FlxG.random.bool(1))
			{
				tumbleWeed = new FlxSprite(1800, 490).loadGraphic(Paths.image('THELEGENDARYTUMBLEWEED', pathWay));
				tumbleWeed.scale.set(0.6, 0.6);
				FlxTween.tween(tumbleWeed, {angle: -360}, 0.5, {type: EngineTools.returnTweenType('looping')});
				foreground.add(tumbleWeed);
				tumbleWeed.antialiasing = ClientPrefs.globalAntialiasing;
		
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
				tumbleWeed.antialiasing = ClientPrefs.globalAntialiasing;
		
				FlxTween.tween(tumbleWeed, {y: 735}, 0.75, {ease: EngineTools.returnTweenEase('sineIn'), type: EngineTools.returnTweenType('pingpong')});
		
				FlxTween.tween(tumbleWeed, {x: -1200}, 5.6, {onComplete: function(twn:FlxTween)
				{
					tumbleWeed.kill();
				}});
			}
		}
}
