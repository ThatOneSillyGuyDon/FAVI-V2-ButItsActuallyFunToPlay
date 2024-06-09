package states.menus;

import flixel.tweens.FlxTween;
import base.dependency.Discord;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxCamera;
import sys.io.File;
import haxe.Json;
import flixel.text.FlxText;
import flixel.FlxSprite;

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

    var path = 'images/menus/Funkin_avi/information';

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

        var bg = new FlxSprite().loadGraphic(Paths.image('Background', path));
        bg.screenCenter();
        bg.setGraphicSize(Std.int(bg.width * .9));
        add(bg);

        book1 = new FlxSprite().loadGraphic(Paths.image('Book (1)', path));
        book1.screenCenter().x -= 300;
        book1.setGraphicSize(Std.int(book1.width * .75));
        add(book1);

        book2 = new FlxSprite().loadGraphic(Paths.image('Book (2)', path));
        book2.screenCenter().x += 400;
        book2.setGraphicSize(Std.int(book2.width * .75));
        add(book2);

        character = new FlxSprite().loadGraphic(Paths.image('characters/isolatedMick', path));
        character.screenCenter().x -= 300;
        character.setGraphicSize(Std.int(character.width * .75));
        character.angle = 1;
        add(character);
        
        var omgIsThatRaiperStyleVFX = new FlxSprite().loadGraphic(Paths.image('Spot Light', path));
        omgIsThatRaiperStyleVFX.screenCenter();
        omgIsThatRaiperStyleVFX.setGraphicSize(Std.int(omgIsThatRaiperStyleVFX.width * .76));
        add(omgIsThatRaiperStyleVFX);

        var omgIsThatRaiperStyleVFX = new FlxSprite().loadGraphic(Paths.image('Particles of Light', path));
        omgIsThatRaiperStyleVFX.screenCenter();
        omgIsThatRaiperStyleVFX.setGraphicSize(Std.int(omgIsThatRaiperStyleVFX.width * .76));
        add(omgIsThatRaiperStyleVFX);

        ui = new FlxSprite().loadGraphic(Paths.image('UI', path));
        ui.screenCenter();
        ui.setGraphicSize(Std.int(ui.width * .76));
        ui.cameras = [hud];
        add(ui);

        name = new FlxText(0, 10).setFormat(Paths.font('infoMenu'), 30, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
        name.screenCenter(X).x -= 150;
        name.camera = hud;
        add(name);

        control = new FlxSprite(0, FlxG.height * .92).loadGraphic(Paths.image('_Help_ Buttons', path));
        control.screenCenter(X);
        control.camera = hud;
        add(control);

        super.create();

        control.y -= 5;
        name.y -= 2;

        FlxTween.tween(control, {y: control.y + 10}, 3, {type: 4});
        FlxTween.tween(name, {y: name.y + 4}, 2, {type: 4});

        changeSelection();
    }

    override public function update(elapsed:Float) {
        super.update(elapsed);

        if (Controls.getPressEvent('back')) Main.switchState(this, new MainMenu());

        if (Controls.getPressEvent("ui_left"))
			changeSelection(-1);
		if (Controls.getPressEvent("ui_right"))
			changeSelection(1);

        if (FlxG.keys.justPressed.F5) FlxG.resetState();
    }

    function changeSelection(hmmm:Int = 0) 
    {
        curSelected += hmmm;

        if (curSelected < 0)
			curSelected = charArray.length - 1;
		if (curSelected >= charArray.length)
			curSelected = 0;

        FlxG.sound.play(Paths.sound('base/menus/scrollMenu'), 0.6);
        
        character.loadGraphic(Paths.image('characters/${charArray[curSelected][1]}', path));
        character.offset.set(charArray[curSelected][2], charArray[curSelected][3]);
        character.setGraphicSize(Std.int(character.width * charArray[curSelected][4]));
        name.text = '< ${charArray[curSelected][0]} >';

        #if DISCORD_RPC
        Discord.changePresence('CHARACTER MENU', 'Checking ${charArray[curSelected][0]}', 'icon', 'mouse');
        #end
    }

    private function thejofsons() 
    {
        jsonString = File.getContent(Paths.getPath('data/charMenu.json', TEXT, null));

        if (jsonString != null && jsonString.length > 0) {
            return cast Json.parse(jsonString);
        }

        return null;
    }
}