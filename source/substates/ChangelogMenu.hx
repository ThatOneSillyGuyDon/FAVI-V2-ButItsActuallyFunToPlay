package substates;

class ChangelogMenu extends MusicBeatSubstate
{
    var changelogText:FlxText;
    var imBouttaStrangleYou:FlxText;
    var theChanges:FlxText;

    var bg:FlxSprite;
	var tiles:FlxBackdrop;

    public function new()
    {
        super();

        bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		tiles = new FlxBackdrop(Paths.image("Funkin_avi/pause/ui/mickeyTiles"), XY, 0, 0);
		tiles.alpha = 0;
		tiles.velocity.set(50, 30);
		tiles.color = FlxColor.fromRGB(65, 88, 94);
		tiles.blend = OVERLAY;
		add(tiles);
        
        changelogText = new FlxText(0, 10, 600, "Changelog", 32);
        changelogText.setFormat(Paths.font("DisneyFont.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        changelogText.screenCenter(X);
        add(changelogText);

        imBouttaStrangleYou = new FlxText(0, 75, 600, "- V2.5.0 (1/2/3456)", 32);
        imBouttaStrangleYou.setFormat(Paths.font("DisneyFont.ttf"), 32, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        imBouttaStrangleYou.screenCenter(X).x -= 75;
        add(imBouttaStrangleYou);

        theChanges = new FlxText(0, 125, 600, "- Put the changes here or smth\n- And make sure they're in this layout", 32);
        theChanges.setFormat(Paths.font("DisneyFont.ttf"), 32, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        theChanges.screenCenter(X).x += 100;
        add(theChanges);

        super.create();
    }

    override function update(elapsed:Float)
    {
        bg.alpha += elapsed * 1.5;
		if(bg.alpha > 0.6) bg.alpha = 0.6;

        tiles.alpha += elapsed * 1.5;
		if(tiles.alpha > 0.2) tiles.alpha = 0.2;
        
        if (controls.BACK)
        {
            FlxG.sound.play(Paths.sound('cancelMenu'));
            close();
        }

        super.update(elapsed);
    }
}