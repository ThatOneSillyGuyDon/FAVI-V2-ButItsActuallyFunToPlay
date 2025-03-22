package states.menus;

import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxCamera;
import sys.io.File;
import haxe.Json;
import flixel.text.FlxText;
import flixel.FlxSprite;

// prob gonna keep jsons and then hardcode it cus thats pretty smart
typedef CharMenuThing = { info:Array<Dynamic> };

// DEMOLITION IF YOU READ THIS DONT PUT ANY SHADER IT LOOKS PERFECT ALREADY RAHAHH
class CharacterMenu extends MusicBeatState 
{
    var curCharacter:String = null;
    var name:FlxText;
    var control:FlxSprite;
    var control2:FlxSprite;
    var description:String;
    var descText:FlxText;
    var book1:FlxSprite;
    var book2:FlxSprite;
    var character:FlxSprite;
    var ui:FlxSprite;
    
    var jsonString:String;
    var theJson:CharMenuThing;
    var charArray:Array<Dynamic>;

    var curSelected:Int = 0;

    var path = 'Funkin_avi/information/';

    var hud:FlxCamera;
    var cam:FlxCamera;

    override public function create() {
        theJson = thejofsons();
        charArray = theJson.info;

        openfl.Lib.application.window.title = 'Funkin.avi - Character Menu';

        hud = cam = new FlxCamera();
        hud.bgColor.alpha = 0;

        FlxG.cameras.reset(cam);
        FlxG.cameras.add(hud, false);
        FlxG.cameras.setDefaultDrawTarget(cam, true);

        var bg = new FlxSprite().loadGraphic(Paths.image(path + 'infoBase'));
        bg.screenCenter();
        bg.antialiasing = ClientPrefs.globalAntialiasing;
        add(bg);

        character = new FlxSprite().loadGraphic(Paths.image(path + 'characters/isolatedMick'));
        character.screenCenter().x -= 300;
        character.setGraphicSize(Std.int(character.width * .75));
        character.angle = 6;
        character.antialiasing = ClientPrefs.globalAntialiasing;
        add(character);

        book1 = new FlxSprite().loadGraphic(Paths.image(path + 'god\'sFuckingLight'));
        book1.screenCenter();
        book1.blend = ADD;
        FlxTween.tween(book1, {alpha: .65}, 3, {type: 4});
        book1.antialiasing = ClientPrefs.globalAntialiasing;
        add(book1);

        descText = new FlxText(FlxG.width * .688, 150, 280).setFormat(Paths.font('Oceanic_Cocktail_Demo.otf'), 23, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
        descText.x -= 28;
        descText.antialiasing = ClientPrefs.globalAntialiasing;
        add(descText);

        book2 = new FlxSprite().loadGraphic(Paths.image(path + 'infoUI'));
        book2.screenCenter();
        book2.antialiasing = ClientPrefs.globalAntialiasing;
        add(book2);
        
        ui = new FlxSprite().loadGraphic(Paths.image(path + 'buttonLeave'));
        ui.screenCenter();
        ui.antialiasing = ClientPrefs.globalAntialiasing;
        add(ui);

        control = new FlxSprite().loadGraphic(Paths.image(path + 'leftButton0'));
        control.screenCenter();
        control.antialiasing = ClientPrefs.globalAntialiasing;
        add(control);

        control2 = new FlxSprite().loadGraphic(Paths.image(path + 'rightButton0'));
        control2.screenCenter();
        control2.antialiasing = ClientPrefs.globalAntialiasing;
        add(control2);

        var spotlight = new FlxSprite().loadGraphic(Paths.image(path + 'infoTutorial'));
        spotlight.screenCenter();
        spotlight.antialiasing = ClientPrefs.globalAntialiasing;
        add(spotlight);
        new FlxTimer().start(5, function(tmr)
        {
            FlxTween.tween(spotlight, {alpha: 0.15}, 2, {ease: FlxEase.circInOut});
        });

        name = new FlxText(0, 40, 1280).setFormat(Paths.font('infoMenu.ttf'), 33, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
        name.screenCenter(X);
        name.alignment = CENTER;
        name.camera = hud;
        name.antialiasing = ClientPrefs.globalAntialiasing;
        add(name);

        super.create();

        name.y -= 10;

        changeSelection();
    }

    var holdTime:Float = 0;
    var leftTmr:FlxTimer;
    var riteTmr:FlxTimer;
    override public function update(elapsed:Float) {
        super.update(elapsed);

        name.y = FlxMath.lerp(40, name.y, CoolUtil.boundTo(1 - (elapsed * 15), 0, 1));

        if (controls.BACK) MusicBeatState.switchState(new MainMenuState());

        if (controls.UI_LEFT_P)
        {
            if (leftTmr != null)
                leftTmr.cancel();

            control.loadGraphic(Paths.image(path + 'leftButton1'));
            leftTmr = new FlxTimer().start(0.08, function(tmr) {
                control.loadGraphic(Paths.image(path + 'leftButton0'));
                leftTmr = null;
            });
            changeSelection(-1);
            holdTime = 0;
        }
		if (controls.UI_RIGHT_P)
        {
            if (riteTmr != null)
                riteTmr.cancel();

            control2.loadGraphic(Paths.image(path + 'rightButton1'));
            riteTmr = new FlxTimer().start(0.08, function(tmr) {
                control2.loadGraphic(Paths.image(path + 'rightButton0'));
                riteTmr = null;
            });
            changeSelection(1);
            holdTime = 0;
        }

        if(controls.UI_LEFT || controls.UI_RIGHT)
        {
            var checkLastHold:Int = Math.floor((holdTime - 0.5) * 10);
            holdTime += elapsed;
            var checkNewHold:Int = Math.floor((holdTime - 0.5) * 10);

            if(holdTime > 0.5 && checkNewHold - checkLastHold > 0)
            {
                if (controls.UI_LEFT)
                {
                    if (leftTmr != null)
                        leftTmr.cancel();
        
                    control.loadGraphic(Paths.image(path + 'leftButton1'));
                    leftTmr = new FlxTimer().start(0.15, function(tmr) {
                        control.loadGraphic(Paths.image(path + 'leftButton0'));
                        leftTmr = null;
                    });
                }
                else
                {
                    if (riteTmr != null)
                        riteTmr.cancel();
        
                    control2.loadGraphic(Paths.image(path + 'rightButton1'));
                    riteTmr = new FlxTimer().start(0.15, function(tmr) {
                        control2.loadGraphic(Paths.image(path + 'rightButton0'));
                        riteTmr = null;
                    });
                }
                changeSelection((checkNewHold - checkLastHold));
                //changeDiff();
            }
        }

        if (FlxG.keys.justPressed.F5) FlxG.resetState();
    }

    function changeSelection(hmmm:Int = 0) 
    {
        curSelected += hmmm;

        if (curSelected < 0)
			curSelected = charArray.length - 1;
		if (curSelected >= charArray.length)
			curSelected = 0;

        FlxG.sound.play(Paths.sound('funkinAVI/menu/scrollSfx'), 0.6);
        
        character.loadGraphic(Paths.image(path + 'characters/${charArray[curSelected][1]}'));
        character.offset.set(charArray[curSelected][2], charArray[curSelected][3]);
        character.setGraphicSize(Std.int(character.width * charArray[curSelected][4]));
        name.text = '${charArray[curSelected][0]}';
        descText.text = charArray[curSelected][5];
        name.y -= 10;

        #if DISCORD_RPC
        #if DEV_BUILD
        DiscordClient.changePresence('???????? ??????', 'Stop checking here for leaks fool.', 'icon', 'mouse');
        #else
        DiscordClient.changePresence('Character Gallery', 'Checking ${charArray[curSelected][0]}', 'icon', 'mouse');
        #end
        #end
    }

    private function thejofsons() 
    {
        jsonString = File.getContent(Paths.json('charMenu'));

        if (jsonString != null && jsonString.length > 0) {
            return cast Json.parse(jsonString);
        }

        return null;
    }
}