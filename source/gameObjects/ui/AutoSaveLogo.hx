package gameObjects.ui;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxG;
import flixel.FlxSprite;

class AutoSaveLogo extends FlxSprite 
{
    @:noCompletion private var __path:String = "autoSave";

    public function new(path:String, xPos:Float = 0, yPos:Float = 0)
    {
        this.__path = path;
        super();

        loadGraphic(Paths.image(path));
        x = xPos;
        y = yPos;
        setGraphicSize(Std.int(width * 0.45));

        cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
    }

    public function saveAndLoad():AutoSaveLogo
        {
            GameData.saveShit(); 
            GameData.loadShit();
            return this;
        }

    public function saveOnly():Void
        {
            return GameData.saveShit(); 
        }

    override function update(elapsed:Float) {
        angle += 1;

        super.update(elapsed);
    }

    public function fade(__destroy:Bool = false):FlxTween
    {
        return FlxTween.tween(this, {alpha: 0, y: y + 40}, 2, {ease: FlxEase.quadInOut, onComplete: _->if(__destroy) destroy()});
    }
}