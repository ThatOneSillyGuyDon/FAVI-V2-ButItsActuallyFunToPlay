function onCreate()
{
    PlayState.defaultCamZoom = 0.9;

    var desktopThing:FlxSprite = new FlxSprite(-500, -100).loadGraphic(Paths.image('desktop', 'data/stages/desktop'));
    desktopThing.scale.set(1.3, 1);
    add(desktopThing);
}

function charStagePos(boyfriend:Character, gf:Character, dad:Character)
{
    boyfriend.setPosition(300, 400);
    gf.setPosition(250, 600);
    dad.setPosition(-1100, 350);
}