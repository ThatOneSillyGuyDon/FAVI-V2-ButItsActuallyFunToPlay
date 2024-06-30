function onCreate()
{
    spawnGirlfriend(false);

    var forest:FlxSprite = new FlxSprite(-180, -350).loadGraphic(Paths.image('forest', 'data/stages/forestOld'));
    add(forest);
}

function charStagePos(boyfriend:Character, gf:Character, dad:Character)
{
    dad.setPosition(0, 0);
    boyfriend.setPosition(900, -20);
}