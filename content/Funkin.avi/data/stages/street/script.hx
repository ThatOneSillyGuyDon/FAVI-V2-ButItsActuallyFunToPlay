import flixel.effects.particles.FlxEmitter.FlxEmitterMode;
import flixel.effects.particles.FlxParticle;

var overlay;
var street;
var bg;
var cables;
var tumbleWeed;
var dustEmitter:FlxEmitter;
var ashEmitter:FlxEmitter;
var weedGrp:FlxTypedGroup;
var path = "stages/abandonedStreet/";

function onLoad()
{
	if (PlayState.SONG.song == 'Lunacy') addCharacterToList('evilrett-lunacy', 0);
	
	overlay = new FlxSprite().loadGraphic(Paths.image(path + 'i_forgor'));
	overlay.screenCenter();
	overlay.setGraphicSize(FlxG.width, FlxG.height);
	overlay.camera = camOther;
	
	bg = new FlxSprite().loadGraphic(Paths.image(path + 'randomColors'));
	street = new FlxSprite().loadGraphic(Paths.image(path + 'street'));
	weedGrp = new FlxTypedGroup();
	cables = new FlxSprite().loadGraphic(Paths.image(path + 'cables'));
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
	
	for (i in [overlay, bg, street, cables])
		add(i);
}

function onCreatePost()
{
	for (obj in [bg, street, cables])
		obj.scale.set(2.3, 2.3);
		
	bg.y -= 200;
	cables.scale.x += 2;
	cables.scrollFactor.set(2.5, 1.9);
	bg.scrollFactor.set(0.3, 0.3);
	
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
	
	for (i in [weedGrp, dustEmitter, ashEmitter])
		add(i);
}

function onSongStart()
{
	if (PlayState.SONG.song == 'Isolated')
	{
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
	}
	else
	{
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
	}
}

function onBeatHit() if (!ClientPrefs.lowQuality && tumbleWeed == null) summonWeedMakerLmfao();

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

function whistleNotes(targetGroup:FlxSpriteGroup)
{
	var path:String = 'favi/ui/bdaynotes';
	var particleNote:FlxSprite = new FlxSprite().loadGraphic(Paths.image('$path/note_${FlxG.random.int(1, 3)}'));
	particleNote.setGraphicSize(Std.int(particleNote.width * 0.5));
	particleNote.updateHitbox();
	particleNote.angle = FlxG.random.float(-15, 18);
	particleNote.setColorTransform(-1, -1, -1, 1, 128, 128, 128, 0);
	particleNote.x = targetGroup.x - 175;
	particleNote.y = targetGroup.y + 375;
	particleNote.alpha = 0.0001;
	particleNote.velocity.x -= targetGroup.y - 475;
	FlxTween.tween(particleNote, {alpha: 1}, .5, {ease: FlxEase.sineInOut});
	
	FlxTween.tween(particleNote, {y: particleNote.y - 70}, FlxG.random.float(0.5, 2), {ease: FlxEase.sineInOut, type: 4});
	
	FlxTween.tween(particleNote, {alpha: 0.0001}, 1,
		{
			ease: FlxEase.sineInOut,
			startDelay: 0.75,
			onComplete: function(tween:FlxTween) {
				particleNote.destroy();
			}
		});
	dadGroup.insert(particleNote, 0);
}
