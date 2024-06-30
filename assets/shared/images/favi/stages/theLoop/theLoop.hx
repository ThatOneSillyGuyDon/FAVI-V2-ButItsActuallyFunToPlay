function onCreate()
{
    spawnGirlfriend(false);
    PlayState.defaultCamZoom = 0.85;

    var street:FlxSprite = new FlxSprite(-500, -700).loadGraphic(Paths.image('Mickeybg', 'data/stages/theLoop/images'));
    add(street);

    if(!lowQuality)
        {
            var grainstuff:FlxSprite = new FlxSprite(0, 0);
            grainstuff.frames = Paths.getSparrowAtlas('Grainshit', 'data/stages/theLoop/images');
            grainstuff.animation.addByPrefix('yucky', 'grains 1', 24, true);
            grainstuff.animation.play('yucky');
            grainstuff.cameras = [PlayState.camHUD];
            grainstuff.scale.set(3, 3);
            grainstuff.screenCenter();
            add(grainstuff);
        }
}

function charStagePos(boyfriend:Character, gf:Character, dad:Character)
{
    dad.setPosition(0, 0);

    if (boyfriend.curCharacter == 'bf')
    {
        boyfriend.setPosition(1000, 130);
    }else{
        boyfriend.setPosition(500, -320);
    }
}