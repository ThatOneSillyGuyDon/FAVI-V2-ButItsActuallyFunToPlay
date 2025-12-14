package states.options.backend;

class LilStage extends BaseStage
{
	//MICKEY STAGE ASSETS
	public static var colorsOrSmthElse:FlxSprite;
	public static var floor:FlxSprite;
	public static var stageCurtains:FlxSprite;
	public static var stageFront:FlxSprite;
	public static var atmosphereParticle:FlxEmitter;
	public static var ashParticle:FlxEmitter;
	public static var tumbleWeed:FlxSprite;
	public static var tumbleGrp:FlxTypedGroup<FlxSprite>;

	public static var pathWay:String;

	override function create()
	{
		colorsOrSmthElse = new FlxSprite(-990, 1600).loadGraphic(Paths.image('favi/stages/abandonedStreet/images/randomColors'));
		colorsOrSmthElse.setGraphicSize(Std.int(colorsOrSmthElse.width * 4));
		colorsOrSmthElse.updateHitbox();
		colorsOrSmthElse.antialiasing = ClientPrefs.data.antialiasing;
		colorsOrSmthElse.screenCenter();
		colorsOrSmthElse.scale.set(3, 3);
		colorsOrSmthElse.scrollFactor.set(0.9, 0.9);
		colorsOrSmthElse.active = false;
		add(colorsOrSmthElse);

		floor = new FlxSprite(-20, 200).loadGraphic(Paths.image('favi/stages/abandonedStreet/images/street'));
		floor.antialiasing = ClientPrefs.data.antialiasing;
		floor.scale.set(2.8, 2.5);
		floor.scrollFactor.set(1, 1);
		floor.active = false;
		add(floor);	
		
		tumbleGrp = new FlxTypedGroup();

		if(!ClientPrefs.data.lowQuality)
		{
			stageCurtains = new FlxSprite(0, 0).loadGraphic(Paths.image('favi/stages/abandonedStreet/images/i_forgor'));
			stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
			stageCurtains.updateHitbox();
			stageCurtains.screenCenter();
			stageCurtains.scale.set(1.3,1.3);
			stageCurtains.antialiasing = ClientPrefs.data.antialiasing;
			stageCurtains.cameras = [camOther];
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
			atmosphereParticle.loadParticles(Paths.image('favi/stages/abandonedStreet/images/dustParticle'), 500, 16, true);
			atmosphereParticle.start(false, FlxG.random.float(.0521, .1060), 1000000);

			ashParticle = new FlxEmitter(-2080.5, 2150.4);
			for (i in 0 ... 100)
			{
				var blackParticle = new FlxParticle();
				blackParticle.frames = Paths.getSparrowAtlas('favi/stages/abandonedStreet/images/ashParticle');
				blackParticle.animation.addByPrefix('idle', 'ashParticle idle', 5, true);
				blackParticle.animation.play('idle');
				blackParticle.antialiasing = ClientPrefs.data.antialiasing;
				blackParticle.exists = false;
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

			stageFront = new FlxSprite(-3000, 130).loadGraphic(Paths.image('favi/stages/abandonedStreet/images/cables'));
			stageFront.scale.set(9, 2.1);
			stageFront.updateHitbox();
			stageFront.antialiasing = ClientPrefs.data.antialiasing;
			stageFront.scrollFactor.set(2.3, 1.7);
			stageFront.active = false;
		}
	}
	
	override function createPost()
	{
		add(tumbleGrp);
		add(atmosphereParticle);
		add(ashParticle);
		add(stageFront);
	}

	override function beatHit()
	{
		if (!ClientPrefs.data.lowQuality)
		{
			if (FlxG.random.bool(3) && tumbleWeed == null)
				summonWeedMakerLmfao();
		}
	}

	function summonWeedMakerLmfao()
	{
		tumbleWeed = new FlxSprite(1800, 600);
		tumbleWeed.antialiasing = ClientPrefs.data.antialiasing;
		var velocityX:Float = 0;
		var loopTime:Array<Float> = [];
		if (FlxG.random.bool(1))
		{
			tumbleWeed.loadGraphic(Paths.image('favi/stages/abandonedStreet/images/THELEGENDARYTUMBLEWEED'));
			tumbleWeed.scale.set(0.6, 0.6);
			velocityX = -970;
			loopTime[0] = 0.5;
			loopTime[1] = 0.1;
			loopTime[2] = 2;
		}
		else
		{
			tumbleWeed.loadGraphic(Paths.image('favi/stages/abandonedStreet/images/Tumble_' + FlxG.random.int(0,1)));
			velocityX = -520;
			loopTime[0] = 1.7;
			loopTime[1] = 0.75;
			loopTime[2] = 5.6;
		}
		tumbleWeed.velocity.set(velocityX, 0);
		tumbleGrp.add(tumbleWeed);
		FlxTween.tween(tumbleWeed, {angle: -360}, loopTime[0], {type: LOOPING});
		FlxTween.tween(tumbleWeed, {y: 735}, loopTime[1], {ease: FlxEase.sineInOut, type: PINGPONG});
		new FlxTimer().start(loopTime[2], function(tmr:FlxTimer)
		{
			tumbleWeed.kill();
			tumbleWeed = null;
		});
	}
}