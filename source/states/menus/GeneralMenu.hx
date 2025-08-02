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
import lime.app.Application;
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

    var item:Array<String> = ['story', 'extra', 'legacy'];
    var itemGroup:FlxTypedGroup<FlxSprite>;

    var catDesc:FlxTypeText;
    var catTitle:FlxTypeText;
	var backdrop:FlxBackdrop;
	var defaultShader2:FlxRuntimeShader;

    var spectrum:SpectrumWaveform;

    var catDescInfo:Array<Array<String>> = [
		["Repeat the Story", "This little book contains all the songs that occurred in story mode, feel free to repeat their misery as much as you like."],
		["Unfamiliar Lands", "Everett & Lilith have had adventures of their own before the main story's events occurred, enter the portals that may lead to meeting some new faces."],
		["A Blast From the Past", "Relive the classic days of what this used to be back in 2022 - 2023! Oh so much has changed since then after all this time."]
	];

    private static var curSelected:Int = 0;
    private static var allowInputs:Bool;
    private var mouseOnButtons:Bool = false;

    override function create() {

        camMain = new FlxCamera();
        FlxG.cameras.reset(camMain);
        FlxG.cameras.setDefaultDrawTarget(camMain, true);

        #if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Freeplay Menu", "Choosing Category...", 'icon', 'disc-player');
		#end

		Application.current.window.title = "Funkin.avi - Freeplay: Category Menu";

        if (!FlxG.mouse.visible)
			FlxG.mouse.visible = true;

		AppIcon.changeIcon("newIcon");
		
		defaultShader2 = new FlxRuntimeShader(Shaders.monitorFilter, null, 140);
		FlxG.camera.setFilters(
			[
				new openfl.filters.ShaderFilter(defaultShader2)
			]);

        bg = new FlxSprite().loadGraphic(Paths.image('Funkin_avi/category/menuBG'));
        bg.screenCenter();
        add(bg);
        
        backdrop = new FlxBackdrop(FlxGridOverlay.createGrid(80, 80, 160, 160, true, 0xFFFFFF, 0x33FFFFFF));
		backdrop.velocity.set(40, 40);
		backdrop.alpha = 0.5;
        backdrop.setGraphicSize(Std.int(backdrop.width * 0.6));
		add(backdrop);

        if (!ClientPrefs.lowQuality)
        {
            var greyParticles:FlxEmitter = new FlxEmitter(-2080.5, 650.4);
			greyParticles.launchMode = SQUARE;
			greyParticles.velocity.set(-50, -200, 50, -600, -90, 0, 90, -600);
			greyParticles.scale.set(1, 2, 0.3, 0.5, 0, 0, 0, 0);
			greyParticles.drag.set(0, 0, 0, 0, 5, 5, 10, 10);
			greyParticles.width = 4787.45;
			greyParticles.alpha.set(1, 1);
			greyParticles.lifespan.set(1.9, 4.9);
			greyParticles.loadParticles(Paths.image('Funkin_avi/category/categoryParticle'), 500, 16, true);
			greyParticles.start(false, FlxG.random.float(.0521, .1060), 1000000);
            add(greyParticles);

            spectrum = new SpectrumWaveform(0, 630, FlxG.sound.music, FlxG.width, FlxG.height, TO_UP_FROM_DOWN, ROUNDED, 0xffff5e5e);
            spectrum.design = ROUNDED;
            spectrum.barWidth = 12;
            spectrum.barSpacing = 16;
            spectrum.roundValue = 25;
            spectrum.blend = ADD;
            spectrum.alpha = 0.6;
            add(spectrum);
        }

        itemGroup = new FlxTypedGroup<FlxSprite>();
        add(itemGroup);

        for (i in 0...item.length) {
            var itemSprite = new FlxSprite();
            itemSprite.loadGraphic(Paths.image('Funkin_avi/category/item/' + item[i] + '0'));
            itemGroup.add(itemSprite);
            itemSprite.ID = i;
            switch (itemSprite.ID)
            {
                case 0:
                    itemSprite.scale.set(0.9, 0.9);
                    itemSprite.x -= 80;
                case 1:
                    itemSprite.scale.set(0.92, 0.92);
                    itemSprite.x += 20;
                case 2:
                    itemSprite.scale.set(0.71, 0.71);
                    itemSprite.x += 70;
                    itemSprite.y -= 50;
            }
            #if desktop
            FlxMouseEvent.add(itemSprite, onClick, null, mouseHandlerOver, mouseHandlerOut, true, true, true);
            #end
        }

        bottom = new FlxSprite(0, 0).loadGraphic(Paths.image('Funkin_avi/category/bottom'));
        bottom.setGraphicSize(0, FlxG.height);
        bottom.screenCenter();
        add(bottom);

        catDesc = new FlxTypeText(0, 610, 500, '');
		catDesc.setFormat(Paths.font("Oceanic_Cocktail_Demo.otf"), 28, FlxColor.WHITE, CENTER);
		catDesc.screenCenter(X);
		add(catDesc);

        var fpTitle:FlxText = new FlxText(0, 40, 1280, "Freeplay Menu");
        fpTitle.setFormat(Paths.font('Oceanic_Cocktail_Demo.otf'), 65, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
        fpTitle.screenCenter(X);
        fpTitle.borderSize = 3;
        add(fpTitle);

        catTitle = new FlxTypeText(0, 100, 1280, "");
        catTitle.setFormat(Paths.font('Oceanic_Cocktail_Demo.otf'), 32, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
        catTitle.borderSize = 3;
        catTitle.screenCenter(X);
        add(catTitle);

        dark = new FlxSprite().loadGraphic(Paths.image('Funkin_avi/category/vingnette'));
        dark.screenCenter();
        add(dark);

        var frame = new FlxSprite().loadGraphic(Paths.image("Funkin_avi/category/categoryFrame"));
        frame.setGraphicSize(0, FlxG.height);
        frame.screenCenter();
        add(frame);
        FlxTween.tween(frame, {alpha: 0.25}, 3, {ease: FlxEase.quartInOut, type: 4});

        if(!ClientPrefs.lowQuality)
			{
				var scratchStuff:FlxSprite = new FlxSprite();
				scratchStuff.frames = Paths.getSparrowAtlas('Funkin_avi/filters/scratchShit');
				scratchStuff.animation.addByPrefix('idle', 'scratch thing 1', 24, true);
				scratchStuff.animation.play('idle');
				scratchStuff.screenCenter();
				scratchStuff.scale.x = 1.1;
				scratchStuff.scale.y = 1.1;
				add(scratchStuff);
	
				var grain:FlxSprite = new FlxSprite();
				grain.frames = Paths.getSparrowAtlas('Funkin_avi/filters/Grainshit');
				grain.animation.addByPrefix('idle', 'grains 1', 24, true);
				grain.animation.play('idle');
				grain.screenCenter();
				grain.scale.x = 1.1;
				grain.scale.y = 1.1;
				add(grain);
            }

        super.create();
        updateSelection();
        FlxG.mouse.load(Paths.image('UI/funkinAVI/mouses/Hand').bitmap);
    }

    override function update(elapsed:Float) {
        if (controls.UI_LEFT_P) {
            allowInputs = true;
            mouseOnButtons = false;
            changeItem(-1);
        }
        if (controls.UI_RIGHT_P) {
            allowInputs = true;
            mouseOnButtons = false;
            changeItem(1);
        }
		if (controls.BACK) {
            Conductor.bpm = 50;
			FreeplayState.songInstPlaying = false;
			FlxG.sound.play(Paths.sound("cancelMenu"));
			MusicBeatState.switchState(new MainMenuState());
			FlxG.sound.playMusic(Paths.music('aviOST/rottenPetals'));
		}
        if (controls.ACCEPT) {
            selectItem(curSelected);
        }

        checkMousePosition();
        super.update(elapsed);
    }

    function checkMousePosition():Void {
        if (FlxG.mouse.justMoved) {
            for (i in 0...itemGroup.members.length) {
                var spr:FlxSprite = itemGroup.members[i];
                if (i == curSelected && !FlxG.mouse.overlaps(spr) || !mouseOnButtons) {
                    spr.loadGraphic(Paths.image('Funkin_avi/category/item/' + item[i] + '0'));
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
        FlxG.mouse.visible = false;
	    FreeplayState.freeplayMenuList = id;
		MusicBeatState.switchState(new FreeplayState());
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
            spr.loadGraphic(Paths.image('Funkin_avi/category/item/' + item[i] + (i == curSelected ? '1' : '0')));
        }
        FlxG.sound.play(Paths.sound('funkinAVI/menu/scrollSfx'));
        catDesc.resetText(catDescInfo[curSelected][1]);
		catDesc.start(0.012, true);
        catTitle.resetText(catDescInfo[curSelected][0]);
        catTitle.start(0.017, true);
    }

}