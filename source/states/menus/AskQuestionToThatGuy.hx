package states.menus;

class AskQuestionToThatGuy extends MusicBeatState
{
    var camFollow:FlxPoint;

    var askingBox:FlxUIInputText;

    var jaysun:Character;

    override function create() {
        var bg = new FlxSprite().loadGraphic(Paths.image('Funkin_avi/jaysun/background'));
        bg.setGraphicSize(1280, 720);
        bg.updateHitbox();
        bg.screenCenter();
        add(bg);

        super.create();

        FlxG.camera.fade(FlxColor.BLACK, 1, true);
    }
}