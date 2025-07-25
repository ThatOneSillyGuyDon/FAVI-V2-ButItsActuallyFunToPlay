package objects;

import haxe.Json;
import haxe.format.JsonParser;
import lime.utils.Assets;

typedef ShadowData =
{
    var color:Array<Int>;
    var alpha:Float;
    var scaleData:Array<Float>;
    var offsetData:Array<Float>;
    var skewData:Array<Float>;
}

class Shadow extends Character // because I'm a lazy piece of shit who loves to handle less work!!!! (don)
{
    public var data:ShadowData;
    public var hasData:Bool = false;

    public function new(sprite:Character) {
        super(sprite.x, sprite.y, sprite.curCharacter, sprite.isPlayer);
    }

    public function parseData(fileName:String) {
        var rawJson = null;
        var filePath = Paths.json(Paths.formatToSongPath(PlayState.SONG.song) + '/' + fileName);

        if(FileSystem.exists(filePath))
            rawJson = File.getContent(filePath).trim();
        else if (Assets.exists(filePath))
            rawJson = Assets.getText(filePath).trim();
        else
        {
            hasData = false;
            return;
        }

        data = cast Json.parse(rawJson);
        hasData = true;
    }
}