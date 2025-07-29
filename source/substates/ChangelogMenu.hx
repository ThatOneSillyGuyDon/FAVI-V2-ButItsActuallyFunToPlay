package substates;

import openfl.Assets;

class ChangelogMenu extends MusicBeatSubstate
{
    var changelogText:FlxText;
    var imBouttaStrangleYou:FlxText;
    var theChanges:FlxText;

    var bg:FlxSprite;
	var tiles:FlxBackdrop;

    var canScroll:Bool = false;

    public function new()
    {
        super();

        tiles = new FlxBackdrop(Paths.image("Funkin_avi/pause/ui/mickeyTiles"), XY, 0, 0);
		tiles.alpha = 0;
		tiles.velocity.set(-50, -30);
		tiles.color = FlxColor.fromRGB(65, 88, 94);
		tiles.blend = OVERLAY;
		add(tiles);
        
        bg = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
        bg.scale.set((FlxG.width * 2) / 2.5, FlxG.height * 5);
		bg.alpha = 1;
        bg.x = -240;
		bg.scrollFactor.set();
		add(bg);
        FlxTween.tween(bg, {x: 0}, 1, {ease: FlxEase.circOut});
        
        changelogText = new FlxText(-240, 10, 600, "Changelog", 32);
        changelogText.setFormat(Paths.font("DisneyFont.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        add(changelogText);
        FlxTween.tween(changelogText, {x: -50}, 1, {ease: FlxEase.circOut});

        imBouttaStrangleYou = new FlxText(-240, 40, 600, "- V2.5.0 (never coming out)", 40);
        imBouttaStrangleYou.setFormat(Paths.font("DisneyFont.ttf"), 40, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        add(imBouttaStrangleYou);
        FlxTween.tween(imBouttaStrangleYou, {x: 0}, 1, {ease: FlxEase.circOut});

        theChanges = new FlxText(-240, 90, 600, Assets.getText(Paths.txt('changelog')), 32);
        theChanges.setFormat(Paths.font("DisneyFont.ttf"), 32, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        add(theChanges);
        FlxTween.tween(theChanges, {x: 25}, 1, {ease: FlxEase.circOut});

        if(theChanges.height > FlxG.height)
        {
            canScroll = true;
        }
        trace(canScroll);

        super.create();
    }

    override function update(elapsed:Float)
    {
        tiles.alpha += elapsed * 1.5;
		if(tiles.alpha > 0.2) tiles.alpha = 0.2;
        
        if (controls.BACK)
        {
            FlxG.sound.play(Paths.sound('cancelMenu'));
            close();
        }

        if (canScroll)
        {
            if (FlxG.mouse.wheel != 0)
            {
                changelogText.y += (FlxG.mouse.wheel * 50);
                imBouttaStrangleYou.y += (FlxG.mouse.wheel * 50);
                theChanges.y += (FlxG.mouse.wheel * 50);
            }
        }

        super.update(elapsed);
    }
}