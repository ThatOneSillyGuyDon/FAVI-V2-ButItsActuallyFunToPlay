package gameObjects.ui;

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
    TWEEN_DATA;
    TEXT_DATA;
}

typedef JsonPrepData =
{
    var totalCounter:Int;
    var loadIcon:Array<Bool>;
}

typedef SubtitlesUtil =
{
    //TEXT
    @:optional var text:String;
    @:optional var textDelay:Float;
    //TEXT_DATA
    @:optional var font:String;
    @:optional var size:Int;
    @:optional var color:Array<Int>;
    @:optional var colorB:Array<Int>;
    @:optional var sizeB:Int;
    @:optional var align:FlxTextAlign;
    //DATA
    @:optional var width:Int;
    @:optional var icon:String;
    //TWEEN_DATA
    @:optional var tweenData:Array<Dynamic>;
    //MOVE
    @:optional var startTimer:Float;
    @:optional var delayTimer:Float;
    @:optional var endTimer:Float;
    @:optional var easeStart:EaseFunction;
    @:optional var easeEnd:EaseFunction;
    //POSITION
    @:optional var positionData:Array<Dynamic>;
}

class SubtitlesBox extends FlxTypedGroup<FlxBasic>
{
    public var tween1:Array<FlxTween> = [];
    public var tween2:Array<FlxTween> = [];
    var captionsGrp:FlxTypedGroup<FlxTypeText>;
    var iconGrp:Array<HealthIcon> = [];
    var rawJson:String = null;
    var json:JsonPrepData;
    var storedData:SubtitlesUtil;

    public function new(camera:FlxCamera, tweenHandler:Array<FlxTween>, tweenHandler2:Array<FlxTween>)
    {
        super();
        tween1 = tweenHandler;
        tween2 = tweenHandler2;
        json = checkForData();
        if (json == null)
            json = {totalCounter: 1, loadIcon: [true]};

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
            if (json.loadIcon[i])
            {
                var speaker = new HealthIcon('bf', false);
                speaker.x = captions.x - 150;
                speaker.y = captions.y - 65;
                speaker.alpha = 0.001;
                speaker.camera = camera;
                iconGrp.push(speaker);
                add(speaker);
            }
        }
    }

    public function manageLyrics(event:EventType, data:SubtitlesUtil, captionCount:Int = 0)
	{
        switch (event)
        {
            case DATA:
                if ((data.width != null) && captionsGrp.members[captionCount] != null)
                {
                    captionsGrp.members[captionCount].fieldWidth = data.width;
                   
                    var iconCount = captionCount-1;
                    if (iconGrp[captionCount] != null)
                    {
                        iconGrp[captionCount].changeIcon(data.icon, false, false, false);

                        if (data.icon == "satanddNEW")
                            iconGrp[captionCount].y = captionsGrp.members[captionCount].y - 80;
                        else
                            iconGrp[captionCount].y = captionsGrp.members[captionCount].y - 65;
                    }
                }
                else
                    return trace('Either you counted wrong or you forgot the input value.');
            case TEXT_DATA:
                if ((data.font != null || data.font != '') && captionsGrp.members[captionCount] != null)
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
                }
                else
                    return trace('Either you counted wrong or yu forgot the input value');
            case TWEEN_DATA:
                if (data.tweenData[0] != null)
                    storedData = {tweenData: data.tweenData};
                else
                    return trace('You forgot the input value.');
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
                if (tween1[captionCount] != null)
                    tween1[captionCount].cancel();
                if (tween2[captionCount] != null)
                    tween2[captionCount].cancel();
                if ((storedData.tweenData[0] != null || storedData.tweenData[0] != '') && captionsGrp.members[captionCount] != null)
                {
                    if (iconGrp[captionCount] != null)
                    {
                        tween1[captionCount] = FlxTween.tween(iconGrp[captionCount],
                            {
                                x: iconGrp[captionCount].x + storedData.tweenData[0],
                                y: iconGrp[captionCount].y + storedData.tweenData[1],
                                angle: iconGrp[captionCount].angle + storedData.tweenData[2],
                                "scale.x": iconGrp[captionCount].scale.x + storedData.tweenData[3],
                                "scale.y": iconGrp[captionCount].scale.y + storedData.tweenData[4],
                                alpha: storedData.tweenData[5]
                            },
                            data.startTimer,
                            {
                                ease: data.easeStart,
                                onComplete: function(t:FlxTween)
                                {
                                    tween1[captionCount] = FlxTween.tween(iconGrp[captionCount],
                                        {
                                            x: iconGrp[captionCount].x + storedData.tweenData[6],
                                            y: iconGrp[captionCount].y + storedData.tweenData[7],
                                            angle: iconGrp[captionCount].angle + storedData.tweenData[8],
                                            "scale.x": iconGrp[captionCount].scale.x + storedData.tweenData[9],
                                            "scale.y": iconGrp[captionCount].scale.y + storedData.tweenData[10],
                                            alpha: storedData.tweenData[11]
                                        },
                                        data.endTimer,
                                        {
                                            ease: data.easeEnd,
                                            startDelay: data.delayTimer,
                                            onComplete: function(t:FlxTween)
                                            {
                                                tween1[captionCount] = null;
                                            }
                                        }
                                    );
                                }
                            }
                        );
                    }
                    tween2[captionCount] = FlxTween.tween(captionsGrp.members[captionCount],
                        {
                            x: captionsGrp.members[captionCount].x + storedData.tweenData[0],
                            y: captionsGrp.members[captionCount].y + storedData.tweenData[1],
                            angle: captionsGrp.members[captionCount].angle + storedData.tweenData[2],
                            "scale.x": captionsGrp.members[captionCount].scale.x + storedData.tweenData[3],
                            "scale.y": captionsGrp.members[captionCount].scale.y + storedData.tweenData[4],
                            alpha: storedData.tweenData[5]
                        },
                        data.startTimer,
                        {
                            ease: data.easeStart,
                            onComplete: function(t:FlxTween)
                            {
                                tween2[captionCount] = FlxTween.tween(captionsGrp.members[captionCount],
                                    {
                                        x: captionsGrp.members[captionCount].x + storedData.tweenData[6],
                                        y: captionsGrp.members[captionCount].y + storedData.tweenData[7],
                                        angle: captionsGrp.members[captionCount].angle + storedData.tweenData[8],
                                        "scale.x": captionsGrp.members[captionCount].scale.x + storedData.tweenData[9],
                                        "scale.y": captionsGrp.members[captionCount].scale.y + storedData.tweenData[10],
                                        alpha: storedData.tweenData[11]
                                    },
                                    data.endTimer,
                                    {
                                        ease: data.easeEnd,
                                        startDelay: data.delayTimer,
                                        onComplete: function(twn:FlxTween)
                                        {
                                            tween2[captionCount] = null;
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
                    captionsGrp.members[captionCount].resetText(data.text);
                    captionsGrp.members[captionCount].start(data.textDelay);
                }
                else
                    return trace('Either you counted wrong or you forgot the input value.');
            default:
                return trace('EVENT DOES NOT EXIST!');
        }
	}

    function checkForData()
	{
		if (sys.FileSystem.exists('./assets/shared/data/${CoolUtil.spaceToDash(PlayState.SONG.song.toLowerCase())}/generateSubtitles.json') || Assets.exists('./assets/shared/data/${CoolUtil.spaceToDash(PlayState.SONG.song.toLowerCase())}/generateSubtitles.json'))
			rawJson = File.getContent(Paths.getPath('data/${CoolUtil.spaceToDash(PlayState.SONG.song.toLowerCase())}/generateSubtitles.json', TEXT, null));
		if (rawJson != null && rawJson.length > 0)
			return cast Json.parse(rawJson);
		else 
			return null;
	}
}