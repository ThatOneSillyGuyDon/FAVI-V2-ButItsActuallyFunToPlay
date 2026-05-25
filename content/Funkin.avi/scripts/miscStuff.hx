import funkin.utils.MathUtil;

var cameraOnDad = false;

public var isCartoon:Bool = false;
public var globalGradient:FlxSprite;
public var scratch:FlxSprite;

public var camVideo:FlxCamera;

public var foregroundStuff:FlxTypedGroup;

function onMoveCamera(char)
{
    if (!PlayState.SONG.notes[curSection].mustHitSection)
        cameraOnDad = true;
    else
        cameraOnDad = false;
}

function onLoad()
{
    camVideo = new FlxCamera();
	camVideo.bgColor = 0x0;
    FlxG.cameras.insert(camVideo, FlxG.cameras.list.indexOf(PlayState.camBars) - 1, false);

	foregroundStuff = new FlxTypedGroup();
}

function onCreatePost()
{
	if (playerStrums._skin.data.arrowRGBQuant != null) playerStrums.quants = false;
	
	if (opponentStrums._skin.data.arrowRGBQuant != null) opponentStrums.quants = false;
	
	if (!ClientPrefs.lowQuality)
	{
		globalGradient = new FlxSprite().loadGraphic(Paths.image('UI/filters/gradient'));
		globalGradient.screenCenter();
		globalGradient.setGraphicSize(Std.int(globalGradient.width * 0.68));
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

	for (grp in [gfGroup, dadGroup, boyfriendGroup]) // fixes layering issue with the bg flash overlaying the characters
	{
		remove(grp);
		add(grp);
	}

	add(foregroundStuff);
}

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
	
	if (!inCutscene)
	{
		camGame.angle = FlxMath.lerp(camGame.angle, 0 + angleOffset, 0.04 * cameraSpeed);
	}
}
