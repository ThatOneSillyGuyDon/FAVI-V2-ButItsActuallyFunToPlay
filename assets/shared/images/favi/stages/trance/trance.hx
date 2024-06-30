var totallyAwsomeShader:FlxRuntimeShader;

function onCreate()
{
    spawnGirlfriend(false);
    PlayState.defaultCamZoom = 1;

    var bg:FlxSprite = new FlxSprite();
    bg.frames = Paths.getSparrowAtlas('background', "data/stages/trance");
    bg.animation.addByPrefix("lmao", "background lmao", 24, true);
    bg.scale.set(5, 5);
    add(bg);
    bg.animation.play("lmao");

    totallyAwsomeShader = new FlxRuntimeShader(File.getContent('./assets/shaders/pixelate.frag'), null, 140);
    totallyAwsomeShader.setFloat('size', 7.5);
    if(!Init.trueSettings.get('Disable Screen Shaders')) FlxG.game.setFilters([new ShaderFilter(totallyAwsomeShader)]);
}

function charStagePos(boyfriend:Character, gf:Character, dad:Character)
{
    dad.setPosition(-861, -259);
    boyfriend.setPosition(260, 0);
}   