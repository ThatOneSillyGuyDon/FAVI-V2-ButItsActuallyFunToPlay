package gameObjects.stages;

//world's most basic testing room
class TestStage extends BaseStage {
    override function create()
    {
        var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.fromRGB(19, 19, 19));
        if (game.defaultCamZoom < 1)
        {
            bg.scale.scale(1 / game.defaultCamZoom);
        }
        bg.scrollFactor.set();
        add(bg);
    }
}