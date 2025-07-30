package substates;

import openfl.Assets;

class ChangelogMenu extends MusicBeatSubstate
{
    var changelogText:FlxText;
    var imBouttaStrangleYou:FlxText;
    var theChanges:FlxText;

    var bg:FlxSprite;
    var bgOverlay:FlxSprite;
	var tiles:FlxBackdrop;

    var stupidLerp:Array<Float> = [10, 40, 90];

    var canScroll:Bool = false;

    public function new()
    {
        super();

        bgOverlay = new FlxSprite().loadGraphic(Paths.image("Funkin_avi/pause/ui/coolBGOverlay"));
        bgOverlay.alpha = 0;
        bgOverlay.color = FlxColor.fromRGB(65, 88, 94);
        bgOverlay.blend = ADD;
        add(bgOverlay);

        tiles = new FlxBackdrop(Paths.image("Funkin_avi/pause/ui/mickeyTiles"), XY, 0, 0);
		tiles.alpha = 0;
		tiles.velocity.set(-50, -30);
		tiles.color = FlxColor.fromRGB(65, 88, 94);
		tiles.blend = OVERLAY;
		add(tiles);
        
        bg = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
        bg.scale.set((FlxG.width * 2) / 1.9, FlxG.height * 5);
		bg.alpha = 1;
        bg.x = -240;
		bg.scrollFactor.set();
		add(bg);
        FlxTween.tween(bg, {x: 0}, 1, {ease: FlxEase.circOut});
        
        changelogText = new FlxText(-240, 10, 600, "Changelog", 32);
        changelogText.setFormat(Paths.font("DisneyFont.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        add(changelogText);
        FlxTween.tween(changelogText, {x: -50}, 1, {ease: FlxEase.circOut});

        imBouttaStrangleYou = new FlxText(-240, 40, 600, "- Dev Build #44", 40);
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
        bgOverlay.alpha += elapsed * 1.5;
		if(tiles.alpha > 0.2) tiles.alpha = 0.2;
        if(bgOverlay.alpha > 0.5) bgOverlay.alpha = 0.5;

        changelogText.y = FlxMath.lerp(stupidLerp[0], changelogText.y, CoolUtil.boundTo(1 - (elapsed * 10), 0, 1));
        imBouttaStrangleYou.y = FlxMath.lerp(stupidLerp[1], imBouttaStrangleYou.y, CoolUtil.boundTo(1 - (elapsed * 10), 0, 1));
        theChanges.y = FlxMath.lerp(stupidLerp[2], theChanges.y, CoolUtil.boundTo(1 - (elapsed * 10), 0, 1));

        if (stupidLerp[0] > 10)
        {
            stupidLerp[0] = 10;
            stupidLerp[1] = 40;
            stupidLerp[2] = 90;
        }
        
        if (controls.BACK)
        {
            MainMenuState.selectedSomethin = false;
            FlxG.sound.play(Paths.sound('cancelMenu'));
            close();
        }

        if (canScroll)
        {
            if (FlxG.mouse.wheel != 0)
            {
                stupidLerp[0] += (FlxG.mouse.wheel * 50);
                stupidLerp[1] += (FlxG.mouse.wheel * 50);
                stupidLerp[2] += (FlxG.mouse.wheel * 50);
            }
            if (controls.UI_DOWN_P || controls.UI_UP_P)
            {
                stupidLerp[0] += controls.UI_UP_P ? 100 : -100;
                stupidLerp[1] += controls.UI_UP_P ? 100 : -100;
                stupidLerp[2] += controls.UI_UP_P ? 100 : -100;
            }
        }

        super.update(elapsed);
    }
}