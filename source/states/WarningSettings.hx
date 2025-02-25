package states;

import lime.app.Application;
import flixel.text.FlxText.FlxTextFormat;
import flixel.text.FlxText.FlxTextFormatMarkerPair;
import backend.FlxTextAlphabet;
import gameObjects.utils.AttachedFlxText;
import flixel.addons.transition.FlxTransitionableState;

class WarningSettings extends MusicBeatState {
    var menuCam:FlxCamera;
    var superCoolIntroCam:FlxCamera;

    // yup, just a direct copy + paste but with some changes so it cna act as a normal state and some other silly things
    private var curOption:Option = null;
	private var curSelected:Int = 0;
	private var optionsArray:Array<Option>;

	private var grpOptions:FlxTypedGroup<FlxTextAlphabet>;
	private var checkboxGroup:FlxTypedGroup<CheckboxThingie>;
	private var grpTexts:FlxTypedGroup<AttachedFlxText>;

    private var descBox:FlxSprite;
	private var descText:FlxText;

    var selectorLeft:FlxSprite;
	var selectorRight:FlxSprite;

	var redTextMarker = new FlxTextFormatMarkerPair(new FlxTextFormat(FlxColor.RED, true, true), '^^');

    override public function create()
    {
        var option:Option = new Option('Low Quality', //Name
        'If checked, ^^disables^^ some background details,\ndecreases loading times and improves performance.', //Description
        'lowQuality', //Save data variable name
        'bool', //Variable type
        false); //Default value
        addOption(option);

        var option:Option = new Option('Anti-Aliasing',
            'If unchecked, disables anti-aliasing, increases performance\nat the cost of sharper visuals.',
            'globalAntialiasing',
            'bool',
            true);
        addOption(option);

        var option:Option = new Option('Shaders', //Name
            'If unchecked, disables shaders.\nIt\'s used for some visual effects, ^^and also CPU intensive for weaker PCs.^^', //Description
            'shaders', //Save data variable name
            'bool', //Variable type
            true); //Default value
        addOption(option);

		var option:Option = new Option('Flashing Lights',
        "Uncheck this if you're sensitive to flashing lights!",
        'flashing',
        'bool',
        true);
        addOption(option);

        var option:Option = new Option('Malfunction Effects',
            "Uncheck this to reduce amount of flashing lights on\nMalfunction!",
            'epilepsy',
            'bool',
            true);
        addOption(option);

        var option:Option = new Option('Camera Zooms',
            "If unchecked, the camera won't zoom in on a beat hit.",
            'camZooms',
            'bool',
            true);
        addOption(option);
        
        grpOptions = new FlxTypedGroup<FlxTextAlphabet>();
		add(grpOptions);

		grpTexts = new FlxTypedGroup<AttachedFlxText>();
		add(grpTexts);

		checkboxGroup = new FlxTypedGroup<CheckboxThingie>();
		add(checkboxGroup);

        menuCam = new FlxCamera();
        superCoolIntroCam = new FlxCamera();

        superCoolIntroCam.bgColor.alpha = 0;

		FlxG.cameras.reset(menuCam);
		FlxG.cameras.add(superCoolIntroCam, false);        

        FlxG.cameras.setDefaultDrawTarget(menuCam, true);
		CustomFadeTransition.nextCamera = menuCam;

        FlxTransitionableState.skipNextTransIn = false;
		FlxTransitionableState.skipNextTransOut = false;

        menuCam.alpha = 0.001;
        menuCam.zoom = 0.4;
        superCoolIntroCam.zoom = 0.001;
        superCoolIntroCam.alpha = 0.001;

        var introTxt:FlxText = new FlxText(0, 0, 1280, "This mod uses some high-intense graphics!\nCheck your settings before proceeding!", 0);
        introTxt.setFormat(Paths.font("disneyFreeplayFont.ttf"), 50, FlxColor.WHITE, CENTER);
        introTxt.screenCenter();
        introTxt.cameras = [superCoolIntroCam];
        add(introTxt);

        var shit = new FlxText(0, FlxG.height * 0.05, 0, "Press ESCAPE when done checking your settings.");
		shit.setFormat(Paths.font("disneyFreeplayFont.ttf"), 25, FlxColor.fromRGB(255, 255, 255, Std.int(255 * .5)), CENTER, OUTLINE, FlxColor.BLACK);
		shit.screenCenter(X);
		add(shit);

        var selectorLeft = new FlxText(shit.x - 45, shit.y + 70, 0, '< ');
        selectorLeft.setFormat(Paths.font("disneyFreeplayFont.ttf"), 150, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		selectorLeft.scale.set(.6, .6);
		selectorLeft.antialiasing = ClientPrefs.globalAntialiasing;
		//FlxTween.tween(selectorLeft, {x: 176.5}, 1, {ease: FlxEase.expoOut});
		add(selectorLeft);

		var selectorRight = new FlxText(shit.x + 555, shit.y + 70, 0, ' >');
		selectorRight.scale.set(.6, .6);
		selectorRight.antialiasing = ClientPrefs.globalAntialiasing;
		selectorRight.setFormat(Paths.font("disneyFreeplayFont.ttf"), 150, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		add(selectorRight);

		descText = new FlxText(50, 900, 1180, "", 32);
		descText.setFormat(Paths.font("DisneyFont.ttf"), 30, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		descText.scrollFactor.set();
		descText.borderSize = 2.4;
		descText.applyMarkup(descText.text, [redTextMarker]);
		add(descText);

		for (i in 0...optionsArray.length)
		{
			var optionText:FlxTextAlphabet = new FlxTextAlphabet(480, 135, 0, optionsArray[i].name);
			optionText.setFormat(Paths.font("BROUGHTTHESTYLE.otf"), 90, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			optionText.isMenuItem = true;
			optionText.changeY = false;
			optionText.changeLerp = true;
			optionText.lerpVal = 1;
			optionText.distancePerItem.x += 200;
			/*optionText.forceX = 300;
			optionText.yMult = 90;*/
			optionText.targetY = i;
			optionText.screenCenter(X).x -= 50;
			grpOptions.add(optionText);

			if(optionsArray[i].type == 'bool') {
				var checkbox:CheckboxThingie = new CheckboxThingie(optionText.x + optionText.width + 100, optionText.y, optionsArray[i].getValue() == true);
				checkbox.sprTracker = optionText;
				checkbox.offsetY = -50;
				checkbox.ID = i;
				checkboxGroup.add(checkbox);
			} else {
				//optionText.xAdd -= 80;
				var valueText:AttachedFlxText = new AttachedFlxText('' + optionsArray[i].getValue(), optionText.width + 80, 0);
				valueText.setFormat(Paths.font("BROUGHTTHESTYLE.otf"), 90, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				valueText.sprTracker = optionText;
				//valueText.offsetY = -50;
				valueText.offsetX = -120;
				valueText.copyAlpha = true;
				valueText.ID = i;
				grpTexts.add(valueText);
				optionsArray[i].setChild(valueText);
			}
            updateTextFrom(optionsArray[i]);
		}

        FlxTween.tween(superCoolIntroCam, {zoom: 1, alpha: 1}, 1.2, {ease: FlxEase.sineOut});
        new FlxTimer().start(3.5, function(tmr)
        {
            FlxTween.tween(superCoolIntroCam, {zoom: 3, alpha: 0}, 1, {ease: FlxEase.circInOut});
            FlxTween.tween(menuCam, {zoom: 1, alpha: 1}, 1, {ease: FlxEase.circInOut});
        });

        changeSelection();
		reloadCheckboxes();
    }

    public function addOption(option:Option) {
		if(optionsArray == null || optionsArray.length < 1) optionsArray = [];
		optionsArray.push(option);
	}

    var nextAccept:Int = 5;
	var holdTime:Float = 0;
	var holdValue:Float = 0;
	override function update(elapsed:Float)
	{
        if (menuCam.alpha >= 0.75)
        {
            if (controls.UI_LEFT_P)
            {
                changeSelection(-1);
            }
            if (controls.UI_RIGHT_P)
            {
                changeSelection(1);
            }

            if (controls.BACK) {
                FlxTween.tween(menuCam, {zoom: 0.6, alpha: 0}, 1, {ease: FlxEase.circOut, onComplete: function(twn:FlxTween)
                {
                    GameData.hasSeenWarning = true;
                    GameData.saveShit();
                    ClientPrefs.saveSettings();
                    MusicBeatState.switchState(new TitleState());
                    FlxG.sound.music.pitch = 1;
                }});
                FlxG.sound.music.fadeOut(0.85, 0);
                FlxG.sound.play(Paths.sound('funkinAVI/menu/selectSfx'));
            }

            if(nextAccept <= 0)
            {
                var usesCheckbox = true;
                if(curOption.type != 'bool')
                {
                    usesCheckbox = false;
                }

                if(usesCheckbox)
                {
                    if(controls.ACCEPT)
                    {
                        FlxG.sound.play(Paths.sound('funkinAVI/menu/scrollSfx'));
                        curOption.setValue((curOption.getValue() == true) ? false : true);
                        curOption.change();
                        reloadCheckboxes();
                    }
                } else {
                    if(controls.UI_UP || controls.UI_DOWN) {
                        var pressed = (controls.UI_UP_P || controls.UI_DOWN_P);
                        if(holdTime > 0.5 || pressed) {
                            if(pressed) {
                                var add:Dynamic = null;
                                if(curOption.type != 'string') {
                                    add = controls.UI_UP ? -curOption.changeValue : curOption.changeValue;
                                }

                                switch(curOption.type)
                                {
                                    case 'int' | 'float' | 'percent':
                                        holdValue = curOption.getValue() + add;
                                        if(holdValue < curOption.minValue) holdValue = curOption.minValue;
                                        else if (holdValue > curOption.maxValue) holdValue = curOption.maxValue;

                                        switch(curOption.type)
                                        {
                                            case 'int':
                                                holdValue = Math.round(holdValue);
                                                curOption.setValue(holdValue);

                                            case 'float' | 'percent':
                                                holdValue = FlxMath.roundDecimal(holdValue, curOption.decimals);
                                                curOption.setValue(holdValue);
                                        }

                                    case 'string':
                                        var num:Int = curOption.curOption; //lol
                                        if(controls.UI_UP_P) --num;
                                        else num++;

                                        if(num < 0) {
                                            num = curOption.options.length - 1;
                                        } else if(num >= curOption.options.length) {
                                            num = 0;
                                        }

                                        curOption.curOption = num;
                                        curOption.setValue(curOption.options[num]); //lol
                                        //trace(curOption.options[num]);
                                }
                                updateTextFrom(curOption);
                                curOption.change();
                                FlxG.sound.play(Paths.sound('funkinAVI/menu/scrollSfx'));
                            } else if(curOption.type != 'string') {
                                holdValue += curOption.scrollSpeed * elapsed * (controls.UI_UP ? -1 : 1);
                                if(holdValue < curOption.minValue) holdValue = curOption.minValue;
                                else if (holdValue > curOption.maxValue) holdValue = curOption.maxValue;

                                switch(curOption.type)
                                {
                                    case 'int':
                                        curOption.setValue(Math.round(holdValue));
                                    
                                    case 'float' | 'percent':
                                        curOption.setValue(FlxMath.roundDecimal(holdValue, curOption.decimals));
                                }
                                updateTextFrom(curOption);
                                curOption.change();
                            }
                        }

                        if(curOption.type != 'string') {
                            holdTime += elapsed;
                        }
                    } else if(controls.UI_UP_R || controls.UI_DOWN_R) {
                        clearHold();
                    }
                }

                if(controls.RESET)
                {
                    for (i in 0...optionsArray.length)
                    {
                        var leOption:Option = optionsArray[i];
                        leOption.setValue(leOption.defaultValue);
                        if(leOption.type != 'bool')
                        {
                            if(leOption.type == 'string')
                            {
                                leOption.curOption = leOption.options.indexOf(leOption.getValue());
                            }
                            updateTextFrom(leOption);
                        }
                        leOption.change();
                    }
                    FlxG.sound.play(Paths.sound('cancelMenu'));
                    reloadCheckboxes();
                }
            }
        }

		if(nextAccept > 0) {
			nextAccept -= 1;
		}
		super.update(elapsed);
	}

	function updateTextFrom(option:Option) {
		var text:String = option.displayFormat;
		var val:Dynamic = option.getValue();
		if(option.type == 'percent') val *= 100;
		var def:Dynamic = option.defaultValue;
		option.text = text.replace('%v', val).replace('%d', def);
	}

	function clearHold()
	{
		if(holdTime > 0.5) {
			FlxG.sound.play(Paths.sound('funkinAVI/menu/scrollSfx'));
		}
		holdTime = 0;
	}
	
	function changeSelection(change:Int = 0)
	{
		curSelected += change;
		if (curSelected < 0)
			curSelected = optionsArray.length - 1;
		if (curSelected >= optionsArray.length)
			curSelected = 0;

		grpOptions.members[curSelected].screenCenter(X);

		descText.text = optionsArray[curSelected].description;
		descText.screenCenter(Y);
		descText.y += 270;
		descText.applyMarkup(descText.text, [redTextMarker]);

		var bullShit:Int = 0;

		for (item in grpOptions.members) {
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0;
			if (item.targetY == 0) {
				item.alpha = 1;
			}
		}
		for (text in grpTexts) {
			text.alpha = 0;
			if(text.ID == curSelected) {
				text.alpha = 1;
			}
		}

		curOption = optionsArray[curSelected]; //shorter lol
		FlxG.sound.play(Paths.sound('funkinAVI/menu/scrollSfx'));
	}

	function reloadCheckboxes() {
		for (checkbox in checkboxGroup) {
			checkbox.daValue = (optionsArray[checkbox.ID].getValue() == true);
		}
	}
}