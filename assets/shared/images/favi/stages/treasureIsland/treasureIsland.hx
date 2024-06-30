var bg:FlxSprite;
var bg2:FlxSprite;

function onCreate()
{
    spawnGirlfriend(false);

    bg = new FlxSprite(0, 0).loadGraphic(Paths.image("mascotRoom", "data/stages/treasureIsland/images"));
    bg.scale.set(1.4, 1.4);
    add(bg);
}

function charStagePos(boyfriend:Character, gf:Character, dad:Character)
{
    boyfriend.setPosition(1080, 310);
    dad.setPosition(0, 190);
}