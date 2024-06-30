var mickeyEmitter:FlxEmitter;
var fuckingsquares:FlxSprite;

var whiteBG:FlxSprite;

var glitchBG:FlxRuntimeShader;
var staticBG:FlxRuntimeShader;

var shaderTime:Float = 0;

var accessPath:String;

function onCreate()
{
	PlayState.defaultCamZoom = 0.8;
	spawnGirlfriend(false);

	accessPath = PlayState.SONG.song == 'Malfunction Legacy' ? 'PixelMouse' : 'malfunctionBG-NEW';
	
	staticBG = new FlxRuntimeShader(File.getContent('./assets/shaders/tvStatic.frag'), null, 120);
	glitchBG = new FlxRuntimeShader(File.getContent('./assets/shaders/vignetteGlitch.frag'), null, 130);

	fuckingsquares = new FlxSprite(-750, -850);
	fuckingsquares.loadGraphic(Paths.image(accessPath, 'data/stages/forbiddenRealm/images'));
	fuckingsquares.scale.set(1.2, 1);
	fuckingsquares.updateHitbox();
	fuckingsquares.antialiasing = false;
	fuckingsquares.scrollFactor(1, 1);
	fuckingsquares.active = false;
	add(fuckingsquares);

	var greyParticles:FlxEmitter = new FlxEmitter(-2080.5, 650.4);
    	greyParticles.launchMode = 'square';
    	greyParticles.velocity.set(-50, -200, 50, -600, -90, 0, 90, -600);
    	greyParticles.scale.set(4, 4, 4, 4, 0, 0, 0, 0);
    	greyParticles.drag.set(0, 0, 0, 0, 5, 5, 10, 10);
    	greyParticles.width = 4787.45;
    	greyParticles.alpha.set(1, 1);
    	greyParticles.lifespan.set(1.9, 4.9);
    	greyParticles.loadParticles(Paths.image('greyParticle', 'data/stages/forbiddenRealm/images'), 500, 16, true);
    	greyParticles.start(false, FlxG.random.float(.0521, .1060), 1000000);

    	var blackParticles:FlxEmitter = new FlxEmitter(-2080.5, 912.4);
    	blackParticles.launchMode = 'square';
    	blackParticles.velocity.set(-70, -220, 70, -620, -110, 20, 110, -620);
    	blackParticles.scale.set(6, 6, 6, 6, 2, 2, 2, 2);
    	blackParticles.drag.set(2, 2, 2, 2, 7, 7, 12, 12);
    	blackParticles.width = 4787.45;
    	blackParticles.alpha.set(1, 1);
    	blackParticles.lifespan.set(1.9, 4.9);
    	blackParticles.loadParticles(Paths.image('particleBlack', 'data/stages/forbiddenRealm/images'), 500, 16, true);
		blackParticles.start(false, FlxG.random.float(.0821, .1460), 1000000);
	
	mickeyEmitter = new FlxEmitter(-2099.8, 1620.4);
	for (i in 0 ... 100)
	{
		var mickeyParticle = new FlxParticle();
		mickeyParticle.frames = Paths.getSparrowAtlas('mickParticle', 'data/stages/forbiddenRealm/images');
		mickeyParticle.animation.addByPrefix('mickParticle idle', 'mickParticle idle', 12, true);
		mickeyParticle.animation.play('mickParticle idle');
		mickeyParticle.exists = false;
		mickeyParticle.animation.curAnim.curFrame = FlxG.random.int(0, 3);
		mickeyEmitter.add(mickeyParticle);
	}
	mickeyEmitter.launchMode = 'square';
	mickeyEmitter.velocity.set(-50, -400, 50, -800, -100, 0, 100, -800);
	mickeyEmitter.scale.set(3.4, 3.4, 3.4, 3.4, 0, 0, 0, 0);
	mickeyEmitter.drag.set(0, 0, 0, 0, 5, 5, 10, 10);
	mickeyEmitter.width = 4200.45;
	mickeyEmitter.alpha.set(1, 1);
	mickeyEmitter.lifespan.set(4, 4.5);
	mickeyEmitter.start(false, FlxG.random.float(.125, .287), 100000);
	mickeyEmitter.emitting = false;
	
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
}

function onBeat(curBeat:Int, boyfriend:Character, gf:Character, dad:Character)
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
}

function onUpdate(elapsed:Float, boyfriend:Character, gf:Character, dad:Character)
{
    	shaderTime = Conductor.songPosition / 1000;

    	glitchBG.setFloat('time', shaderTime);
    	glitchBG.setFloat('prob', shaderTime);

    	staticBG.setFloat('uTime', shaderTime);
    	staticBG.setFloat('iTime', shaderTime);
}

function charStagePos(boyfriend:Character, gf:Character, dad:Character)
{
	if (dad.curCharacter == 'gm-calm-pixel')
		dad.setPosition(-130, 50);
	else
		dad.setPosition(-100, 150);
	
	boyfriend.setPosition(1300, 600);
}