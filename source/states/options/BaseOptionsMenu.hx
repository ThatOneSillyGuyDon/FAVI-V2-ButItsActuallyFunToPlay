package states.options;

import flixel.text.FlxText.FlxTextFormat;
import flixel.text.FlxText.FlxTextFormatMarkerPair;
import flash.text.TextField;
import lime.utils.Assets;
import haxe.Json;
import flixel.input.keyboard.FlxKey;
import backend.FlxTextAlphabet;
import gameObjects.utils.AttachedFlxText;
class BaseOptionsMenu extends MusicBeatSubstate
{
	private var curOption:Option = null;
	private var curSelected:Int = 0;
	private var optionsArray:Array<Option>;

	private var grpOptions:FlxTypedGroup<FlxTextAlphabet>;
	private var checkboxGroup:FlxTypedGroup<CheckboxThingie>;
	private var grpTexts:FlxTypedGroup<AttachedFlxText>;

	private var boyfriend:Character = null;
	private var descBox:FlxSprite;
	private var descText:FlxText;

	public var title:String;
	public var rpcTitle:String;

	var selectorLeft:FlxSprite;
	var selectorRight:FlxSprite;

	var spamCounter:Float = 0;

	var dogshitPath:String = 'Funkin_avi/options';

	var redTextMarker = new FlxTextFormatMarkerPair(new FlxTextFormat(FlxColor.RED, true, true), '^^');
	
	public function new()
	{
		super();

		if(title == null) title = 'Options';
		if(rpcTitle == null) rpcTitle = 'Options Menu';
		
		#if desktop
		DiscordClient.changePresence(rpcTitle, "Changing settings...", "icon", "gear");
		#end
		
		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('Funkin_avi/options/background'));
		bg.setGraphicSize(FlxG.width, FlxG.height);
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		bg.color = 0x343434;
		add(bg);

		// avoids lagspikes while scrolling through menus!
		grpOptions = new FlxTypedGroup<FlxTextAlphabet>();
		add(grpOptions);

		grpTexts = new FlxTypedGroup<AttachedFlxText>();
		add(grpTexts);

		checkboxGroup = new FlxTypedGroup<CheckboxThingie>();
		add(checkboxGroup);

		descBox = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);

		var shit = new FlxText(0, FlxG.height * 0.05, 0, title);
		shit.setFormat(Paths.font("disneyFreeplayFont.ttf"), 25, FlxColor.fromRGB(255, 255, 255, Std.int(255 * .5)), CENTER, OUTLINE, FlxColor.BLACK);
		shit.screenCenter(X);
		add(shit);

		var selectorLeft = new FlxText(shit.x - 310, shit.y + 70, 0, '< ');
		selectorLeft.setFormat(Paths.font("disneyFreeplayFont.ttf"), 150, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		selectorLeft.scale.set(.6, .6);
		selectorLeft.antialiasing = ClientPrefs.globalAntialiasing;
		//FlxTween.tween(selectorLeft, {x: 176.5}, 1, {ease: FlxEase.expoOut});
		add(selectorLeft);

		var selectorRight = new FlxText(shit.x + 320, shit.y + 70, 0, ' >');
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
			//optionText.snapToPosition(); //Don't ignore me when i ask for not making a fucking pull request to uncomment this line ok

			if(optionsArray[i].showBoyfriend && boyfriend == null)
			{
				reloadBoyfriend();
			}
			updateTextFrom(optionsArray[i]);
		}

		var graphic:FlxSprite = new FlxSprite().loadGraphic(Paths.image('$dogshitPath/IMG_1017'));
		graphic.setGraphicSize(FlxG.width, FlxG.height);
		graphic.updateHitbox();
		graphic.screenCenter();
		graphic.antialiasing = ClientPrefs.globalAntialiasing;
		add(graphic);

		var graphic:FlxSprite = new FlxSprite().loadGraphic(Paths.image('$dogshitPath/Untitled1595_20240710134131'));
		graphic.setGraphicSize(FlxG.width, FlxG.height);
		graphic.updateHitbox();
		graphic.screenCenter();
		graphic.antialiasing = ClientPrefs.globalAntialiasing;
		add(graphic);

		if (!ClientPrefs.lowQuality)
		{
			var gradient:FlxSprite = new FlxSprite().loadGraphic(Paths.image('Funkin_avi/filters/gradient'));
			gradient.scrollFactor.set(0, 0);
			gradient.setGraphicSize(Std.int(gradient.width * 0.75));
			gradient.updateHitbox();
			gradient.screenCenter();
			gradient.antialiasing = true;
			gradient.scale.x += .1;
			add(gradient);

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
		if (controls.UI_LEFT_P)
		{
			changeSelection(-1);
		}
		if (controls.UI_RIGHT_P)
		{
			changeSelection(1);
		}

		if (controls.BACK) {
			close();
			FlxG.sound.play(Paths.sound('cancelMenu'));
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

		if (boyfriend != null && boyfriend.visible)
		{
			if (controls.NOTE_UP_P)
			{
				boyfriend.playAnim("singUP");
				spamCounter += 1;
			}
			if (controls.NOTE_DOWN_P)
			{
				boyfriend.playAnim("singDOWN");
				spamCounter += 1;
			}
			if (controls.NOTE_LEFT_P)
			{
				boyfriend.playAnim("singLEFT");
				spamCounter += 1;
			}
			if (controls.NOTE_RIGHT_P)
			{
				boyfriend.playAnim("singRIGHT");
				spamCounter += 1;
			}
		}

		if (spamCounter >= 150 && GameData.episode1FPLock == "unlocked")
		{
			FlxG.sound.playMusic(Paths.music('aviOST/seekingFreedom'));
			FreeplayState.freeplayMenuList = 3;
			MusicBeatState.switchState(new FreeplayState());
		}

		if(boyfriend != null && boyfriend.animation.curAnim.finished) {
			boyfriend.dance();
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

		if(boyfriend != null)
		{
			boyfriend.visible = optionsArray[curSelected].showBoyfriend;
		}

		curOption = optionsArray[curSelected]; //shorter lol
		FlxG.sound.play(Paths.sound('funkinAVI/menu/scrollSfx'));
	}

	override function closeSubState() {
		super.closeSubState();
	}

	public function reloadBoyfriend()
	{
		var wasVisible:Bool = false;
		if(boyfriend != null) {
			wasVisible = boyfriend.visible;
			boyfriend.kill();
			remove(boyfriend);
			boyfriend.destroy();
		}

		boyfriend = new Character(440, 220, 'everett-modern', true);
		boyfriend.setGraphicSize(Std.int(boyfriend.width * 0.75));
		boyfriend.addOffset("singLEFT", 18, 0);
		boyfriend.addOffset("singRIGHT", -36, 0);
		boyfriend.addOffset("singUP", -33, 23);
		boyfriend.addOffset("singDOWN", -7, -22);
		boyfriend.updateHitbox();
		boyfriend.dance();
		insert(1, boyfriend);
		boyfriend.visible = wasVisible;
	}

	function reloadCheckboxes() {
		for (checkbox in checkboxGroup) {
			checkbox.daValue = (optionsArray[checkbox.ID].getValue() == true);
		}
	}
}