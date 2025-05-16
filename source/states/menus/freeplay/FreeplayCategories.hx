package states.menus.freeplay;

import openfl.ui.Mouse;
import openfl.events.MouseEvent;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import lime.app.Application;
import flixel.input.keyboard.FlxKey;
import openfl.display.BlendMode;
import openfl.display.StageQuality;
import openfl.filters.BitmapFilter;
import openfl.utils.Assets as OpenFlAssets;
import openfl.filters.ShaderFilter;

class FreeplayCategories extends MusicBeatState {

	//var unfinishedText:FlxText;
    	var freeplayCats:Array<String>;
	var fpCateBanners:FlxSprite;
	var grpCats:FlxTypedGroup<FlxSprite>;
	var curSelected:Int = 0;
	var catDesc:FlxTypeText;
	var BG:FlxSprite;
	var textInk:FlxSprite;
	var welcome:FlxSprite;
	var backdrop:FlxBackdrop;
	var defaultShader2:FlxRuntimeShader;

	var arrowFlash:FlxRuntimeShader = new FlxRuntimeShader(Shaders.flashyFlash, null, 120);
	var flashThing:Float = 0;

	var selectTween:FlxTween;
	var unselectTween:FlxTween;

	var spectrum:SpectrumWaveform;

	var catDescString:Array<String> = [
		"Story Mode Songs: After the hell seen in our little story, here you will be given power to replay the pain all over again.",
		"Extra Songs: Danger lurks in every shadow, in every breath. An uncomfortable sense of unease takes hold as you venture through strange worlds where fear is a constant companion.",
		"Legacy Songs: A place where long forgotten memories emerge from the shadows, reeling in the past and its viewers back"
	];
	
   	 override function create(){
		FlxG.stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);

		super.create();

		if (!FlxG.mouse.visible)
			FlxG.mouse.visible = true;

		AppIcon.changeIcon("newIcon");
		
		defaultShader2 = new FlxRuntimeShader(Shaders.monitorFilter, null, 140);
		FlxG.camera.setFilters(
			[
				new openfl.filters.ShaderFilter(defaultShader2)
			]);
			
	    freeplayCats = ['episodes', 'extras', 'legacy'];

        BG = new FlxSprite().loadGraphic(Paths.image('Funkin_avi/freeplay/category/freeplayBG'));
		BG.screenCenter();
		add(BG);

		backdrop = new FlxBackdrop(FlxGridOverlay.createGrid(80, 80, 160, 160, true, 0xFFFFFF, 0x33FFFFFF));
		backdrop.velocity.set(40, 40);
		backdrop.alpha = 0;
        backdrop.setGraphicSize(Std.int(backdrop.width * 0.6));
		FlxTween.tween(backdrop, {alpha: 1}, 0.5, {ease: FlxEase.quadOut});
		add(backdrop);

		if (!ClientPrefs.lowQuality)
		{
			spectrum = new SpectrumWaveform(0, 730, FlxG.sound.music, FlxG.width, FlxG.height, TO_UP_FROM_DOWN, ROUNDED, 0xffff5e5e);
			spectrum.design = ROUNDED;
			spectrum.barWidth = 12;
			spectrum.barSpacing = 16;
			spectrum.blend = ADD;
			spectrum.alpha = 0.6;
			add(spectrum);
		}

		textInk = new FlxSprite().loadGraphic(Paths.image('Funkin_avi/freeplay/category/textBoxes'));
		textInk.screenCenter();
		add(textInk);

		welcome = new FlxSprite().loadGraphic(Paths.image('Funkin_avi/freeplay/category/freeplayTxt'));
		welcome.screenCenter();
		add(welcome);

		catDesc = new FlxTypeText(0, 640, 500, catDescString[curSelected]);
		catDesc.setFormat(Paths.font("Oceanic_Cocktail_Demo.otf"), 28, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		catDesc.borderSize = 1.2;
		catDesc.screenCenter(X);
		add(catDesc);


		BG.scale.set(0.76, 0.76);
		textInk.scale.set(0.76, 0.76);
		welcome.scale.set(0.76, 0.76);

		FlxG.mouse.load(Paths.image('UI/funkinAVI/mouses/Hand').bitmap);

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Freeplay Menu", "Choosing Category...", 'icon', 'disc-player');
		#end

		Application.current.window.title = "Funkin.avi - Freeplay: Category Menu";

       		grpCats = new FlxTypedGroup<FlxSprite>();
		add(grpCats);

		// so what if it's just a cheap copy and paste of the main menu items? if it works, it works bitch /jjjjjjjjjjj (don)
		for (i in 0...freeplayCats.length)
		{
			var offset:Float = 108 - (Math.max(freeplayCats.length, 4) - 4) * 80;
			var catsBanners:FlxSprite = new FlxSprite(0, 150).loadGraphic(Paths.image("Funkin_avi/freeplay/category/menuOptions/" + freeplayCats[i]));
			catsBanners.scale.set(0.6, 0.6);
			catsBanners.ID = i;
			grpCats.add(catsBanners);

			var scr:Float = (freeplayCats.length - 4) * 0.135;
			catsBanners.scrollFactor.set(0, scr);

			switch (catsBanners.ID)
			{
				case 0:
					catsBanners.x = 50;
				case 1:
					catsBanners.x = 450;
				case 2:
					catsBanners.x = 850;
			}

			catsBanners.antialiasing = true;
			catsBanners.updateHitbox();
		}

		grpCats.members[2].flipX = true; // man

		if(!ClientPrefs.lowQuality) {
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

        updateSelection();

		catDesc.start(0.02, true);

		flashThing = 0.6;
		FlxTween.tween(this, {flashThing: 0}, 1, {type: PINGPONG});
    }

	var counterControl:Float = 0;

    override public function update(elapsed:Float){

		var up = controls.UI_LEFT;
		var down = controls.UI_RIGHT;
		var up_p = controls.UI_LEFT_P;
		var down_p = controls.UI_RIGHT_P;
		var controlArray:Array<Bool> = [up, down, up_p, down_p];

		arrowFlash.setFloat('progress', flashThing);

		if ((controlArray.contains(true)))
		{

			for (i in 0...controlArray.length)
			{
				// here we check which keys are pressed
				if (controlArray[i] == true)
				{
					/*
						i > 1 is single pressá
						up is 2, down is 3
					 */

					var changeValue:Int = 0;

					if (i > 1)
					{
						if (i == 2)
							changeValue -= 1;
						else if (i == 3)
							changeValue += 1;

						if (curSelected < 0)
							curSelected = 2;
						if (curSelected >= 2)
							curSelected = -1; // WHY IS IT -1??!??!?!??!!??!?!

						FlxG.sound.play(Paths.sound('funkinAVI/menu/scrollSfx'));
					}

					curSelected = FlxMath.wrap(Math.floor(curSelected) + changeValue, 0, freeplayCats.length - 1);
				}
				//
			}
		}
		else
		{
			// reset variables
			counterControl = 0;
		}
		
		if (controls.BACK) {
			FreeplayState.songInstPlaying = false;
			FlxG.sound.play(Paths.sound("cancelMenu"));
			MusicBeatState.switchState(new MainMenu());
			FlxG.sound.playMusic(Paths.music('aviOST/rottenPetals'));
		}


        if (controls.ACCEPT){
			FlxG.sound.play(Paths.sound("funkinAVI/menu/selectSfx"));
			FlxG.mouse.visible = false;
            	FreeplayState.freeplayMenuList = curSelected;
				MusicBeatState.switchState(new FreeplayState());
        }

		if (curSelected != lastCurSelected)
			updateSelection();

		if (FlxG.mouse.justMoved)
			{
				for (i in 0...grpCats.length)
				{
					if (i != curSelected)
					{
						if (FlxG.mouse.overlaps(grpCats.members[i]) && !FlxG.mouse.overlaps(grpCats.members[curSelected]))
						{
							changeSelection(i);
						}
					}
				}
			}

			if (FlxG.mouse.justPressed)
			{
				if (FlxG.mouse.overlaps(grpCats.members[curSelected]))
				{
					FlxG.mouse.visible = false;
					FreeplayState.freeplayMenuList = curSelected;
					MusicBeatState.switchState(new FreeplayState());
				}
			}

        super.update(elapsed);
    }

	function changeSelection(selection:Int)
		{
			if (selection != curSelected)
			{
				FlxG.sound.play(Paths.sound('funkinAVI/menu/scrollSfx'));
			}
	
			if (curSelected < 0)
				curSelected = freeplayCats.length - 1;
			if (curSelected >= freeplayCats.length)
				curSelected = 0;
	
			for (i in 0...freeplayCats.length)
			{
				var menuItem:FlxSprite = grpCats.members[i];
				if (i == selection)
				{
					menuItem.alpha = 1.0;
				}
				else
				{
					menuItem.alpha = 0.45;
				}
			}
	
			curSelected = selection;
		}
		
	var lastCurSelected:Int = 0;

	private function updateSelection()
	{
		// reset all selections
		if (unselectTween != null)
			unselectTween.cancel();
		if (selectTween != null)
			selectTween.cancel();

		grpCats.forEach(function(spr:FlxSprite)
		{
			if (ClientPrefs.shaders) spr.shader = null;
			unselectTween = FlxTween.tween(
				spr, 
				{
					alpha: 0.45, 
					'scale.x': 0.55, 
					'scale.y': 0.55
				}, 
				0.1, 
				{
					ease: FlxEase.sineInOut, 
					onComplete: function(twn:FlxTween)
					{
						unselectTween = null;
					}
				});
		});

		if (ClientPrefs.shaders) grpCats.members[Math.floor(curSelected)].shader = arrowFlash;
		selectTween = FlxTween.tween(
		grpCats.members[Math.floor(curSelected)], 
		{
			alpha: 1, 
			'scale.x': 0.6, 
			'scale.y': 0.6
			}, 
			0.12, 
			{
				ease: FlxEase.sineInOut, 
				onComplete: function(twn:FlxTween)
				{
					selectTween = null;
				}
		});

		lastCurSelected = curSelected;

		catDesc.resetText(catDescString[curSelected]);
		catDesc.start(0.02, true);
	}

	override function destroy() {
		super.destroy();

		FlxG.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
	}

	function onMouseMove(r)
	{
		for (items in grpCats)
			if (FlxG.mouse.overlaps(items))
			{
				Mouse.cursor = BUTTON;
				return;
			}

		Mouse.cursor = AUTO;
	}
}
