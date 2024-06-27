function stepHit()
{
    if (curStep == 1280)
    {
        FlxTween.tween(PlayState.camHUD, {alpha: 0.001}, 0.3);
        for (i in PlayState.strumHUD)
        {
            FlxTween.tween(i, {alpha: 0.001}, 0.35);
        }
    }
    if (curStep == 1292)
    {
        // Okay so basically, this is for the Sidescroll if BF's notes are on the right side
        moveThatFuckingStrum(false, 0.5, 90, 0.0001, 1060, 120, 0);
        moveThatFuckingStrum(false, 0.5, 90, 0.0001, 1060, 240, 1);
        moveThatFuckingStrum(false, 0.5, 90, 0.0001, 1060, 360, 2);
        moveThatFuckingStrum(false, 0.5, 90, 0.0001, 1060, 480, 3);

        PlayState.dadStrums.receptors.members[0].strumDirection = 270;
        PlayState.dadStrums.receptors.members[1].strumDirection = 270;
        PlayState.dadStrums.receptors.members[2].strumDirection = 270;
        PlayState.dadStrums.receptors.members[3].strumDirection = 270;

        PlayState.dadStrums.receptors.members[0].x = 50;
        PlayState.dadStrums.receptors.members[1].x = 50;
        PlayState.dadStrums.receptors.members[2].x = 50;
        PlayState.dadStrums.receptors.members[3].x = 50;

        PlayState.dadStrums.receptors.members[0].y = 120;
        PlayState.dadStrums.receptors.members[1].y = 240;
        PlayState.dadStrums.receptors.members[2].y = 360;
        PlayState.dadStrums.receptors.members[3].y = 480;

        PlayState.health = 2;
    }
    if (curStep == 1312)
    {
        FlxTween.tween(PlayState.camHUD, {alpha: 1}, 0.2);
        for (i in PlayState.strumHUD)
        {
            FlxTween.tween(i, {alpha: 1}, 0.15);
        }
    }
    if (curStep == 1440)
    {
        // both strums on top of each other wtffffffff????
        PlayState.bfStrums.receptors.members[0].strumDirection = 0;
        PlayState.bfStrums.receptors.members[1].strumDirection = 0;
        PlayState.bfStrums.receptors.members[2].strumDirection = 0;
        PlayState.bfStrums.receptors.members[3].strumDirection = 0;

        PlayState.bfStrums.receptors.members[0].x = 380;
        PlayState.bfStrums.receptors.members[1].x = 500;
        PlayState.bfStrums.receptors.members[2].x = 620;
        PlayState.bfStrums.receptors.members[3].x = 740;

        PlayState.bfStrums.receptors.members[0].y = 300;
        PlayState.bfStrums.receptors.members[1].y = 300;
        PlayState.bfStrums.receptors.members[2].y = 300;
        PlayState.bfStrums.receptors.members[3].y = 300;

        PlayState.dadStrums.receptors.members[0].strumDirection = 108;
        PlayState.dadStrums.receptors.members[1].strumDirection = 67;
        PlayState.dadStrums.receptors.members[2].strumDirection = 45;
        PlayState.dadStrums.receptors.members[3].strumDirection = 280;

        PlayState.dadStrums.receptors.members[0].x = 380;
        PlayState.dadStrums.receptors.members[1].x = 500;
        PlayState.dadStrums.receptors.members[2].x = 620;
        PlayState.dadStrums.receptors.members[3].x = 740;

        PlayState.dadStrums.receptors.members[0].y = 300;
        PlayState.dadStrums.receptors.members[1].y = 300;
        PlayState.dadStrums.receptors.members[2].y = 300;
        PlayState.dadStrums.receptors.members[3].y = 300;

        PlayState.strumHUD[0].alpha = 0.35;
    }
}

function moveThatFuckingStrum(isDad:Bool = false, timer:Float = 0.5, direction:Float = 0, alpha:Float = 1, x:Float, y:Float, strumID:Int)
{
    if (strumID > 3 || strumID < 0)
        strumID = 0;
    if (alpha > 1 || alpha < 0)
        alpha = 1;
    if (timer > 0)
        timer = 0.5;
    if (x == null)
        x = 0;
    if (y == null)
        y = 0;

    if (isDad)
    {
        FlxTween.tween(PlayState.dadStrums.receptors.members[strumID], 
            {
                strumDirection: direction,
                x: x,
                y: y
            },
            timer
        );
        FlxTween.tween(PlayState.strumHUD[0], {alpha: alpha}, timer);
    }
    else
    {
        FlxTween.tween(PlayState.bfStrums.receptors.members[strumID], 
            {
                strumDirection: direction,
                x: x,
                y: y
            },
            timer
        );
        FlxTween.tween(PlayState.strumHUD[1], {alpha: alpha}, timer);
    }
}