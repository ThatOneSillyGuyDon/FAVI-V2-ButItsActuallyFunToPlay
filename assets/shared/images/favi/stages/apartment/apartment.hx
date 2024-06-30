var bg1:FlxSprite;
var bg2:FlxSprite;

var glitchBG:FlxRuntimeShader;

var shaderTime:Float = 0;

function onCreate()
{
    spawnGirlfriend(false);
    PlayState.defaultCamZoom = 0.6;
	PlayState.cameraSpeed = 0.9;

    //Phase 2 shaders
    glitchBG = new FlxRuntimeShader(File.getContent('./assets/shaders/vignetteGlitch.frag'), null, 130);

    bg1 = new FlxSprite(0, 50);
    bg1.frames = Paths.getSparrowAtlas('relapse1', 'data/stages/apartment/images');
    bg1.animation.addByPrefix('idle', 'Bg bg', 10, true);
    bg1.scale.set(7, 7);
    bg1.antialiasing = false;
    bg1.animation.play('idle');
    add(bg1);

    bg2 = new FlxSprite(0, 50).loadGraphic(Paths.image('relapse2', 'data/stages/apartment/images'));
    bg2.scale.set(7, 7);
    bg2.antialiasing = false;
    bg2.visible = false;
    add(bg2);
}

function onBeat(curBeat:Int, boyfriend:Character, gf:Character, dad:Character)
{
    if (PlayState.SONG.song == "Cycled Sins Legacy")
    {
        if (curBeat == 144)
        {
            bg1.visible = false;
            bg2.visible = true;
            bg2.shader = glitchBG;
        }
    }
}

function onUpdate(elapsed:Float, boyfriend:Character, gf:Character, dad:Character)
{
    shaderTime = Conductor.songPosition / 1000;

    glitchBG.setFloat('time', shaderTime);
    glitchBG.setFloat('prob', shaderTime);
}

function charStagePos(boyfriend:Character, gf:Character, dad:Character)
{
    dad.setPosition(-1000, 270);
    boyfriend.setPosition(590, 250);
}    