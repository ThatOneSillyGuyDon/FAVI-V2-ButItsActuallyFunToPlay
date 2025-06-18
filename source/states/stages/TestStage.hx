package states.stages;

import states.stages.objects.*;

//world's most basic testing room
class TestStage extends BaseStage {
    override function create()
    {
        var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.fromRGB(1, 1, 1));
        if (game.defaultCamZoom < 1)
        {
            bg.scale.scale(1 / game.defaultCamZoom);
        }
        bg.scrollFactor.set();
        add(bg);
    }
}