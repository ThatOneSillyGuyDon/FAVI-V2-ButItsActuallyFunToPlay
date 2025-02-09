package states.menus;

import lime.ui.MouseCursor;
import openfl.ui.Mouse;
import openfl.events.MouseEvent;
import lime.app.Application;
import flash.system.System;
import flixel.input.mouse.FlxMouseEvent;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.input.keyboard.FlxKey;
import flixel.input.keyboard.FlxKeyboard;
import haxe.io.Path;
import openfl.net.SharedObject;
import openfl.net.SharedObjectFlushStatus;
import sys.io.File;
import flixel.addons.effects.FlxSkewedSprite;
import flixel.FlxSprite;
import flixel.FlxG;

using StringTools;

class GeneralMenu extends MusicBeatState {
    var camMain:FlxCamera;
    var camHUD:FlxCamera;

    var bg:FlxSprite;
    var bottom:FlxSprite;
    var dark:FlxSprite;

    var item:Array<String> = ['extra', 'story', 'tape'];
    var itemGroup:FlxTypedGroup<FlxSprite>;

    private static var curSelected:Int = 0;
    private static var allowInputs:Bool;
    private var mouseOnButtons:Bool = false;

    override function create() {

        camMain = new FlxCamera();
        FlxG.cameras.reset(camMain);
        FlxG.cameras.setDefaultDrawTarget(camMain, true);

        bg = new FlxSprite().loadGraphic(Paths.image('menu/menuBG'));
        bg.screenCenter();
        add(bg);

        itemGroup = new FlxTypedGroup<FlxSprite>();
        add(itemGroup);

        FlxG.mouse.visible = true;

        for (i in 0...item.length) {
            var itemSprite = new FlxSprite();
            itemSprite.loadGraphic(Paths.image('menu/item/' + item[i] + '0'));
            itemGroup.add(itemSprite);
            itemSprite.scale.set(0.95, 0.95);
            itemSprite.ID = i;
            #if desktop
            FlxMouseEvent.add(itemSprite, onClick, null, mouseHandlerOver, mouseHandlerOut, true, true, true);
            #end
        }

        bottom = new FlxSprite(0, 50).loadGraphic(Paths.image('menu/bottom'));
        bottom.scale.set(1.25, 1);
        add(bottom);

        dark = new FlxSprite().loadGraphic(Paths.image('menu/vingnette'));
        dark.screenCenter();
        add(dark);

        super.create();
        updateSelection();
        FlxG.mouse.load(Paths.image('UI/funkinAVI/mouses/Hand').bitmap);
    }

    override function update(elapsed:Float) {
        if (controls.UI_LEFT_P) {
            allowInputs = true;
            mouseOnButtons = false;
            changeItem(1);
        }
        if (controls.UI_RIGHT_P) {
            allowInputs = true;
            mouseOnButtons = false;
            changeItem(-1);
        }
				if (controls.BACK) {
						MusicBeatState.switchState(new MainMenu());
				}

        checkMousePosition();
        super.update(elapsed);
    }

    function checkMousePosition():Void {
        if (FlxG.mouse.justMoved) {
            for (i in 0...itemGroup.members.length) {
                var spr:FlxSprite = itemGroup.members[i];
                if (i == curSelected && !FlxG.mouse.overlaps(spr) || !mouseOnButtons) {
                    spr.loadGraphic(Paths.image('menu/item/' + item[i] + '0'));
                }
            }
        }
    }

    function mouseHandlerOver(object:FlxSprite) {
        mouseOnButtons = true;
        curSelected = object.ID;
        updateSelection();
    }

    function mouseHandlerOut(object:FlxSprite) {
        mouseOnButtons = false;
    }

    function onClick(object:FlxSprite) {
        selectItem(object.ID);
    }

    function selectItem(id:Int) {
	      FreeplayState.freeplayMenuList = id;
				MenuBeatState.switchState(new FreeplayState());
    }

    function changeItem(change:Int = 0) {
        if (change != 0) {
            curSelected = flixel.math.FlxMath.wrap(curSelected + change, 0, item.length - 1);
        }
        updateSelection();
    }

    function updateSelection() {
        for (i in 0...item.length) {
            var spr:FlxSprite = itemGroup.members[i];
            spr.loadGraphic(Paths.image('menu/item/' + item[i] + (i == curSelected ? '1' : '0')));
        }
    }

}