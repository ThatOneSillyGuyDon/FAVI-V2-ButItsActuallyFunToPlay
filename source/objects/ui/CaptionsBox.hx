package objects.ui;

import haxe.Exception;
import haxe.Json;
import haxe.format.JsonParser;
import lime.utils.Assets;

enum EventType
{
    POSITION;
    MOVE;
    TEXT;
    DATA;
}

typedef JsonPrepData =
{
    var totalCounter:Int;
    var loadIcon:Array<Bool>;
}

typedef CaptionUtils =
{
    //TEXT
    @:optional var text:String;
    @:optional var font:String;
    @:optional var size:Int;
    @:optional var color:Array<Int>;
    @:optional var colorB:Array<Int>;
    @:optional var sizeB:Int;
    @:optional var icon:String;
    @:optional var textDelay:Float;
    @:optional var align:FlxTextAlign;

    //DATA
    @:optional var width:Int;

    //MOVE
    @:optional var tweenData:Array<Dynamic>;
    @:optional var startTimer:Float;
    @:optional var delayTimer:Float;
    @:optional var endTimer:Float;
    @:optional var ease:String;

    //POSITION
    @:optional var positionData:Array<Dynamic>;
}

class CaptionsBox extends FlxTypedGroup<FlxBasic>
{
    var captionsGrp:FlxTypedGroup<FlxTypeText>;
    var iconGrp:Array<HealthIcon> = [];
    public var tween1:FlxTween;
    public var tween2:FlxTween;
    var rawJson:String = null;
    var json:JsonPrepData;

    public function new(camera:FlxCamera)
    {
        super();

        json = checkForData();

        if (json == null)
        {
            json.totalCounter = 1;
            json.loadIcon = [false];
        }

        captionsGrp = new FlxTypedGroup<FlxTypeText>();
        captionsGrp.camera = camera;
        add(captionsGrp);

        for (i in 0...json.totalCounter) //this is actually evil wtf
        {
            var captions = new FlxTypeText(0, FlxG.height - 65, 0, '', 15);
            captions.setFormat(Paths.font('vcr'), 30, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
            captions.alpha = 0.001;
            captions.borderSize = 4;
            captions.scrollFactor.set();
            captions.screenCenter(X).x -= 90;
            captions.ID = i;
            captions.camera = camera;
            captionsGrp.add(captions);

            if (json.loadIcon[i-1])
            {
                var speaker = new HealthIcon('bf', false);
                speaker.x = captions.x - 150;
                speaker.y = captions.y - 65;
                speaker.alpha = 0.001;
                speaker.camera = camera;
                iconGrp.push(speaker);
                add(speaker);
            }

            trace('loaded ${captionsGrp.length} captions');
        }
    }

    public function manageLyrics(event:EventType, data:CaptionUtils, captionCount:Int = 0)
	{
        switch (event)
        {
            case POSITION:
                if ((data.positionData[0] != null || data.positionData[0] != '') && captionsGrp.members[captionCount] != null)
                {
                    if (iconGrp[captionCount] != null)
                    {
                        iconGrp[captionCount].x += data.positionData[0];
                        iconGrp[captionCount].y += data.positionData[1];
                    }
                    captionsGrp.members[captionCount].x += data.positionData[0];
                    captionsGrp.members[captionCount].y += data.positionData[1];
                }
                else
                    return trace('Either you counted wrong or you forgot the input value.');

            case MOVE:
                if (tween1 != null)
                    tween1.cancel();
                    
                if (tween2 != null)
                    tween2.cancel();

                if ((data.tweenData[0] != null || data.tweenData[0] != '') && captionsGrp.members[captionCount] != null)
                {                    
                    if (iconGrp[captionCount] != null)
                    {
                        tween1 = FlxTween.tween(iconGrp[captionCount],
                            {
                                x: iconGrp[captionCount].x + data.tweenData[0],
                                y: iconGrp[captionCount].y + data.tweenData[1],
                                angle: iconGrp[captionCount].angle + data.tweenData[2],
                                "scale.x": iconGrp[captionCount].scale.x + data.tweenData[3],
                                "scale.y": iconGrp[captionCount].scale.y + data.tweenData[4],
                                alpha: data.tweenData[5]
                            },
                            data.startTimer,
                            {
                                startDelay: data.delayTimer,
                                onComplete: function(t:FlxTween)
                                {
                                    tween1 = FlxTween.tween(iconGrp[captionCount],
                                        {
                                            x: iconGrp[captionCount].x + data.tweenData[6],
                                            y: iconGrp[captionCount].y + data.tweenData[7],
                                            angle: iconGrp[captionCount].angle + data.tweenData[8],
                                            "scale.x": iconGrp[captionCount].scale.x + data.tweenData[9],
                                            "scale.y": iconGrp[captionCount].scale.y + data.tweenData[10],
                                            alpha: data.tweenData[11]
                                        },
                                        data.endTimer,
                                        {
                                            onComplete: function(t:FlxTween)
                                            {
                                                tween1 = null;
                                            }
                                        }
                                    );
                                }
                            }
                        );
                    }
                    tween2 = FlxTween.tween(captionsGrp.members[captionCount],
                        {
                            x: captionsGrp.members[captionCount].x + data.tweenData[0],
                            y: captionsGrp.members[captionCount].y + data.tweenData[1],
                            angle: captionsGrp.members[captionCount].angle + data.tweenData[2],
                            "scale.x": captionsGrp.members[captionCount].scale.x + data.tweenData[3],
                            "scale.y": captionsGrp.members[captionCount].scale.y + data.tweenData[4],
                            alpha: data.tweenData[5]
                        },
                        data.startTimer,
                        {
                            startDelay: data.delayTimer,
                            onComplete: function(t:FlxTween)
                            {
                                tween2 = FlxTween.tween(captionsGrp.members[captionCount],
                                    {
                                        x: captionsGrp.members[captionCount].x + data.tweenData[6],
                                        y: captionsGrp.members[captionCount].y + data.tweenData[7],
                                        angle: captionsGrp.members[captionCount].angle + data.tweenData[8],
                                        "scale.x": captionsGrp.members[captionCount].scale.x + data.tweenData[9],
                                        "scale.y": captionsGrp.members[captionCount].scale.y + data.tweenData[10],
                                        alpha: data.tweenData[11]
                                    },
                                    data.endTimer,
                                    {
                                        onComplete: function(twn:FlxTween)
                                        {
                                            tween2 = null;
                                        }
                                    }
                                );
                            }
                        }
                    );
                }
                else
                    return trace('Either you counted wrong or you forgot the input value.');

            case TEXT:
                if ((data.text != null || data.text != '') && captionsGrp.members[captionCount] != null)
                {
                    captionsGrp.members[captionCount].setFormat(
                        Paths.font(data.font), 
                        data.size, 
                        FlxColor.fromRGB(data.color[0], data.color[1], data.color[2]), 
                        data.align, 
                        FlxTextBorderStyle.OUTLINE, 
                        FlxColor.fromRGB(data.colorB[0], data.colorB[1], data.colorB[2])
                    );

                    captionsGrp.members[captionCount].borderSize = data.sizeB;
                    captionsGrp.members[captionCount].resetText(data.text);
                    captionsGrp.members[captionCount].start(data.textDelay);

                    if (iconGrp[captionCount] != null)
                        iconGrp[captionCount].changeIcon(data.icon, false, false, false);
                }
                else
                    return trace('Either you counted wrong or you forgot the input value.');
               
            case DATA:
                if ((data.width != null) && captionsGrp.members[captionCount] != null)
                    captionsGrp.members[captionCount].fieldWidth = data.width;
                else
                    return trace('Either you counted wrong or you forgot the input value.');

            default:
                return trace('EVENT DOES NOT EXIST!');
        }
	}

    function checkForData()
	{
		if (sys.FileSystem.exists('./assets/shared/data/${CoolUtil.spaceToDash(PlayState.SONG.song.toLowerCase())}/prepCaptions.json') || Assets.exists('./assets/shared/data/${CoolUtil.spaceToDash(PlayState.SONG.song.toLowerCase())}/prepCaptions.json'))
			rawJson = File.getContent(Paths.getPath('data/${CoolUtil.spaceToDash(PlayState.SONG.song.toLowerCase())}/prepCaptions.json', TEXT, null));

		if (rawJson != null && rawJson.length > 0)
        {
            trace('loaded captions data');
			return cast Json.parse(rawJson);
        }
		else 
        {
            trace('file does not exist');
			return null;
        }
	}
}