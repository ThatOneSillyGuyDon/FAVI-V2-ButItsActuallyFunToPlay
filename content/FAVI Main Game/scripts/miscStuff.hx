import funkin.utils.MathUtil;

var cameraOnDad = false;
var stageList = ['street', 'forest', 'alleyway', 'muckney', 'war']; // script decided to be a dick, so here's the workaround
public var isCartoon:Bool = false;
public var globalGradient:FlxSprite;
public var scratch:FlxSprite;
public var camVideo:FlxCamera;
public var healthDrain:Float = 0;
public var healthLimit:Float = 0;
public var healthLerp:Float = 1;

public function numericForInterval(start, end, interval, func)
{
	var index = start;
	while (index < end)
	{
		func(index);
		index += interval;
	}
}

function onMoveCamera(char)
{
	if (!PlayState.SONG.notes[curSection].mustHitSection) cameraOnDad = true;
	else cameraOnDad = false;
}

function onLoad()
{
	camVideo = new FlxCamera();
	camVideo.bgColor = 0x0;
	FlxG.cameras.insert(camVideo, FlxG.cameras.list.indexOf(PlayState.camBars) - 1, false);
}

function onCreatePost()
{
	for (i in stageList)
		if (PlayState.SONG.stage == stageList[i]) isCartoon = true;
		
	if (playerStrums._skin.data.arrowRGBQuant != null) playerStrums.quants = false;
	
	if (opponentStrums._skin.data.arrowRGBQuant != null) opponentStrums.quants = false;
	
	if (!ClientPrefs.lowQuality)
	{
		globalGradient = new FlxSprite().loadGraphic(Paths.image('UI/filters/gradient'));
		globalGradient.screenCenter();
		globalGradient.setGraphicSize(Std.int(globalGradient.width * 4));
		globalGradient.cameras = [camOther];
		globalGradient.alpha = 0;
		add(globalGradient);
	}
	
	if (isCartoon && !ClientPrefs.lowQuality)
	{
		scratch = new FlxSprite();
		scratch.frames = Paths.getSparrowAtlas('UI/filters/scratchShit');
		scratch.setGraphicSize(Std.int(scratch.width * 6));
		scratch.animation.addByPrefix('e', 'scratch thing', 24, true);
		scratch.animation.play('e');
		scratch.cameras = [camOther];
		add(scratch);
	}
	
	healthBar.valueFunction = function() {
		return healthLerp;
	};
	healthGain = 0.28;
	healthLoss = 1.2;
}

function opponentNoteHit(note) if (health >= healthLimit && ClientPrefs.mechanics) health -= healthDrain;

function onUpdate(elapsed)
{
	var angleOffset = 0;
	
	var char = cameraOnDad ? dad : boyfriend;
	
	if (char.animation.curAnim != null && !isCameraOnForcedPos && ClientPrefs.camFollowsCharacters)
	{
		switch (char.animation.curAnim.name.substring(4))
		{
			case 'RIGHT', 'RIGHT-alt':
				angleOffset += 1.3;
			case 'LEFT', 'LEFT-alt':
				angleOffset -= 1.45;
		}
	}
	
	healthLerp = FlxMath.lerp(healthLerp, health, .2 / (ClientPrefs.framerate / 60));
	
	if (!inCutscene)
	{
		camGame.angle = FlxMath.lerp(camGame.angle, 0 + angleOffset, 0.04 * cameraSpeed);
	}
}
