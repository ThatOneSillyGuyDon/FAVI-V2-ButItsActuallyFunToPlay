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

        var bg = new FlxSprite().loadGraphic(Paths.image(path + 'Background'));
        bg.screenCenter();
        bg.setGraphicSize(Std.int(bg.width * .9));
        bg.antialiasing = ClientPrefs.globalAntialiasing;
        add(bg);

        book1 = new FlxSprite().loadGraphic(Paths.image(path + 'Book (1)'));
        book1.screenCenter().x -= 300;
        book1.setGraphicSize(Std.int(book1.width * .75));
        book1.antialiasing = ClientPrefs.globalAntialiasing;
        add(book1);

        book2 = new FlxSprite().loadGraphic(Paths.image(path + 'Book (2)'));
        book2.screenCenter().x += 400;
        book2.setGraphicSize(Std.int(book2.width * .75));
        book2.antialiasing = ClientPrefs.globalAntialiasing;
        add(book2);

        character = new FlxSprite().loadGraphic(Paths.image(path + 'characters/isolatedMick'));
        character.screenCenter().x -= 300;
        character.setGraphicSize(Std.int(character.width * .75));
        character.angle = 1;
        character.antialiasing = ClientPrefs.globalAntialiasing;
        add(character);
        
        var spotlight = new FlxSprite().loadGraphic(Paths.image(path + 'Spot Light'));
        spotlight.screenCenter();
        spotlight.setGraphicSize(Std.int(spotlight.width * .76));
        spotlight.antialiasing = ClientPrefs.globalAntialiasing;
        FlxTween.tween(spotlight, {alpha: .4}, 3, {type: 4});
        add(spotlight);

        // todo: replace flxsprite with flxparticle
        var particles = new FlxSprite().loadGraphic(Paths.image(path + 'Particles of Light'));
        particles.screenCenter();
        particles.setGraphicSize(Std.int(particles.width * .76));
        particles.antialiasing = ClientPrefs.globalAntialiasing;
        add(particles);

        ui = new FlxSprite().loadGraphic(Paths.image(path + 'UI'));
        ui.screenCenter();
        ui.setGraphicSize(Std.int(ui.width * .76));
        ui.cameras = [hud];
        ui.antialiasing = ClientPrefs.globalAntialiasing;
        add(ui);

        name = new FlxText(0, 10, 1280).setFormat(Paths.font('infoMenu.ttf'), 30, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
        name.screenCenter(X);
        name.alignment = CENTER;
        name.camera = hud;
        name.antialiasing = ClientPrefs.globalAntialiasing;
        add(name);

        control = new FlxSprite(0, FlxG.height * .92).loadGraphic(Paths.image(path + '_Help_ Buttons'));
        control.screenCenter(X);
        control.camera = hud;
        control.antialiasing = ClientPrefs.globalAntialiasing;
        add(control);

        descText = new FlxText(FlxG.width * .688, 115, 280).setFormat(Paths.font('Oceanic_Cocktail_Demo.otf'), 25, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
        descText.angle = -2;
        descText.antialiasing = ClientPrefs.globalAntialiasing;
        add(descText);

        super.create();

        control.y -= 5;
        name.y -= 2;

        FlxTween.tween(control, {y: control.y + 10}, 3, {type: 4});
        FlxTween.tween(name, {y: name.y + 4}, 2, {type: 4});

        changeSelection();
    }

    var holdTime:Float = 0;
    override public function update(elapsed:Float) {
        super.update(elapsed);

        if (controls.BACK) MusicBeatState.switchState(new MainMenu());

        if (controls.UI_LEFT_P)
        {
            changeSelection(-1);
            holdTime = 0;
        }
		if (controls.UI_RIGHT_P)
        {
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
        name.text = '< ${charArray[curSelected][0]} >';
        descText.text = charArray[curSelected][5];

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