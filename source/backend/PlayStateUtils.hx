package backend;

import lime.app.Application;
import openfl.filters.ShaderFilter;

/**
 * A class made for organize and separate all `PlayState` content
*/
class PlayStateUtils// extending the class itself incase crashes
{
    public static var instance:PlayStateUtils;
	public var thingE:Float;
	var boundValue:Float = 0;
	var drainValue:Float = 0;
	var satanSpeaks:Array<String> = [
		"Have fun,",
		"Let's play one more game...",
		"Welcome to the end.",
		"Are you having fun?",
		"Hello, " + PauseSubState.yourName + ".",
		"And so, his fate is sealed once more...",
		"Good luck.",
		"The end is near...",
		"The sight of hell brings back its viewers...",
		"Let's make his death a worthy show.",
		"You've come far, " + PauseSubState.yourName + "...",
		"Don't think about quitting now, " + PauseSubState.yourName + "...",
		"Don't leave yet..."
	];

	public function new()
	{
		instance = this;
	}

    /*
    * A function made to initialize your shaders with, only for song-specific initiation atm
    * 
    *  @author DEMOLITIONDON96 ft. Jason
    */
    public static function initializeShaders()
		{
			switch (PlayState.SONG.song)
			{
				case 'Malfunction':
					if(!ClientPrefs.lowQuality)
					{
						PlayState.camGame.setFilters(
						[
							new ShaderFilter(PlayState.chromZoomShader),
							new ShaderFilter(PlayState.blurShader)
						]);
						PlayState.camHUD.setFilters(
						[
							new ShaderFilter(PlayState.chromNormalShader),
							new ShaderFilter(PlayState.blurShader)
						]);
							PlayState.camNotes.setFilters(
							[
								new ShaderFilter(PlayState.chromNormalShader),
								new ShaderFilter(PlayState.blurShader)
							]);

						new flixel.util.FlxTimer().start(5, function(tmr)
						{
							PlayState.camGame.setFilters([new ShaderFilter(PlayState.chromZoomShader)]);
							PlayState.camHUD.setFilters([new ShaderFilter(PlayState.chromNormalShader)]);
							PlayState.camNotes.setFilters([new ShaderFilter(PlayState.chromNormalShader)]);
						});
					}
				case 'Malfunction Legacy':
					if(!ClientPrefs.lowQuality)
					{
						PlayState.camGame.setFilters(
						[
							new ShaderFilter(PlayState.chromNormalShader),
							new ShaderFilter(PlayState.blurShader)
						]);
						PlayState.camHUD.setFilters(
						[
							new ShaderFilter(PlayState.chromNormalShader),
							new ShaderFilter(PlayState.blurShader)
						]);
						PlayState.camNotes.setFilters(
							[
								new ShaderFilter(PlayState.chromNormalShader),
								new ShaderFilter(PlayState.blurShader)
							]);
					}
				case 'Devilish Deal' | 'Isolated' | 'Lunacy' | 'Delusional' | 'Delusion':
					PlayState.redVignette.setFloat('time', 0.0);
					if (!ClientPrefs.lowQuality)
					{
						PlayState.camGame.setFilters([
                            new ShaderFilter(PlayState.redVignette),
							new ShaderFilter(PlayState.dramaticCamMovement),
							new ShaderFilter(PlayState.bloomEffect),
							new ShaderFilter(PlayState.monitorFilter),
							new ShaderFilter(PlayState.chromZoomShader),
							new ShaderFilter(PlayState.chromNormalShader)
						]);
						PlayState.camHUD.setFilters([new ShaderFilter(PlayState.chromNormalShader)]);
						PlayState.camNotes.setFilters([new ShaderFilter(PlayState.grayScale), new ShaderFilter(PlayState.chromNormalShader)]);
					}
					else
					{
						PlayState.camGame.setFilters([
							new ShaderFilter(PlayState.monitorFilter),
							new ShaderFilter(PlayState.chromNormalShader)
						]);
						PlayState.camHUD.setFilters([new ShaderFilter(PlayState.chromNormalShader)]);
						PlayState.camNotes.setFilters([new ShaderFilter(PlayState.grayScale)]);
					}
				case 'Isolated Old' | 'Isolated Legacy' | 'Isolated Beta' | 'Lunacy Legacy' | 'Delusional Legacy':
					PlayState.blurShader.setFloat('bluramount', 0.6);
					PlayState.blurShaderHUD.setFloat('bluramount', 0.1);
					PlayState.andromeda.setFloat('glitchModifier', 0.2);
					PlayState.andromeda.setBool('perspectiveOn', true);
					PlayState.andromeda.setBool('vignetteMoving', true);
					if (!ClientPrefs.lowQuality)
					{
						PlayState.camGame.setFilters([
							new ShaderFilter(PlayState.grayScale),
							new ShaderFilter(PlayState.blurShader),
							new ShaderFilter(PlayState.andromeda)
						]);
						PlayState.camHUD.setFilters([
							new ShaderFilter(PlayState.grayScale),
							new ShaderFilter(PlayState.blurShaderHUD),
							new ShaderFilter(PlayState.andromeda)
						]);
					}
					else
					{
						PlayState.camGame.setFilters([new ShaderFilter(PlayState.grayScale)]);
						PlayState.camHUD.setFilters([new ShaderFilter(PlayState.grayScale)]);
					}
				case 'Hunted Legacy':
					PlayState.blurShader.setFloat('bluramount', 0.6);
					PlayState.blurShaderHUD.setFloat('bluramount', 0.1);
					PlayState.andromeda.setFloat('glitchModifier', 0.2);
					PlayState.andromeda.setBool('perspectiveOn', true);
					PlayState.andromeda.setBool('vignetteMoving', true);
					if (!ClientPrefs.lowQuality)
					{
						PlayState.camGame.setFilters([
							new ShaderFilter(PlayState.grayScale),
							new ShaderFilter(PlayState.blurShader),
						]);
						@:privateAccess for(_camHUD in [PlayState.camHUD, PlayState.camNotes]) _camHUD.setFilters([
							new ShaderFilter(PlayState.grayScale),
							new ShaderFilter(PlayState.blurShaderHUD),
							new ShaderFilter(PlayState.andromeda)
						]);
					}
					else
					{
						PlayState.camGame.setFilters([new ShaderFilter(PlayState.grayScale)]);
						PlayState.camHUD.setFilters([new ShaderFilter(PlayState.grayScale)]);
					}				
				case 'Scrapped':
					if (!ClientPrefs.lowQuality)
					{
						PlayState.camGame.setFilters([
							new ShaderFilter(PlayState.staticEffect),
							new ShaderFilter(PlayState.blurShader),
							new ShaderFilter(PlayState.chromNormalShader),
							new ShaderFilter(PlayState.chromZoomShader)
						]);
						PlayState.camHUD.setFilters([
							new ShaderFilter(PlayState.blurShaderHUD),
							new ShaderFilter(PlayState.chromNormalShader)
						]);
							PlayState.camNotes.setFilters([
								new ShaderFilter(PlayState.blurShaderHUD),
								new ShaderFilter(PlayState.chromNormalShader)
							]);
					}
					else
					{
						PlayState.camGame.setFilters([new ShaderFilter(PlayState.chromNormalShader)]);
						PlayState.camHUD.setFilters([new ShaderFilter(PlayState.chromNormalShader)]);
						PlayState.camNotes.setFilters([new ShaderFilter(PlayState.chromNormalShader)]);
					}
                case 'Twisted Grins' | 'Twisted Grins Legacy':
                    if (!ClientPrefs.lowQuality)
                    {
                        PlayState.camGame.setFilters([
                            new ShaderFilter(PlayState.staticEffect),
                            new ShaderFilter(PlayState.grayScale)
                        ]);
                    }
                    else
                    {
                        PlayState.camGame.setFilters([new ShaderFilter(PlayState.grayScale)]);
                    }
                    PlayState.camHUD.setFilters([new ShaderFilter(PlayState.grayScale)]);
                    PlayState.camNotes.setFilters([new ShaderFilter(PlayState.grayScale)]);
                case 'Hunted':
                    if (!ClientPrefs.lowQuality)
                    {
                        PlayState.camGame.setFilters([
                            new ShaderFilter(PlayState.dramaticCamMovement),
                            new ShaderFilter(PlayState.monitorFilter),
                            new ShaderFilter(PlayState.bloomEffect)
                        ]);
                    }
                    else
                    {
                        PlayState.camGame.setFilters([new ShaderFilter(PlayState.monitorFilter)]);
                    }
                    PlayState.camNotes.setFilters([new ShaderFilter(PlayState.grayScale)]);
                case 'Mercy' | 'Mercy Legacy':
                    if (!ClientPrefs.lowQuality)
                    {
                        PlayState.camGame.setFilters([
                            new ShaderFilter(PlayState.waltStatic),
                            new ShaderFilter(PlayState.dramaticCamMovement)
                        ]);
                    }
                    else
                    {
                        PlayState.camGame.setFilters([new ShaderFilter(PlayState.dramaticCamMovement)]);
                    }
                    PlayState.camHUD.setFilters([new ShaderFilter(PlayState.dramaticCamMovement)]);
                    PlayState.camNotes.setFilters([new ShaderFilter(PlayState.dramaticCamMovement)]);
				case 'Cycled Sins Legacy':
					PlayState.chromZoomShader.setFloat('aberration', 0.12);
   		 			PlayState.chromZoomShader.setFloat('effectTime', 0.24);
					PlayState.camGame.setFilters(
					[
						new ShaderFilter(PlayState.dramaticCamMovement)
					]);
					PlayState.camNotes.setFilters([new ShaderFilter(PlayState.grayScale)]);
			}
		}

    /*
    * This code USED to be in PlayState, but it made the create function look like a mess, so now it's in here!
    * Took a while to modify and fix to prevent crashing, but it works!
    * YIPPPEEEEEEE!!!!!
    * 
    * @author DEMOLITIONDON96 ft. Jason
    */

    public function songSetup()
    {
        switch (PlayState.SONG.song)
		{
			case 'Devilish Deal':
				// Moves Player Notes on Opponent Side
				/*if (!Init.trueSettings.get('Centered Notefield'))
				{
					PlayState.strumLines.members[0].visible = false;
					PlayState.bfStrums.receptors.members[0].x = 75;
					PlayState.bfStrums.receptors.members[1].x = 185;
					PlayState.bfStrums.receptors.members[2].x = 300;
					PlayState.bfStrums.receptors.members[3].x = 415;
				}*/

				PlayState.camGame.alpha = 0.001;
				PlayState.camHUD.alpha = 0.001;
				PlayState.camNotes.alpha = 0.001; // 0.001 doesn't cause lag when setting alpha above 0 for some reason, yet it's still invisible

			case 'Isolated' | 'Lunacy' | 'Cycled Sins' | 'Delusion' | 'Laugh Track':
				PlayState.camNotes.alpha = 0.001;
				PlayState.camBars.fade(FlxColor.BLACK, 0.0001);
				PlayState.camHUD.alpha = 0.001;

			case 'Delusional':
				PlatformUtil.sendNotification('Hello.', satanSpeaks[FlxG.random.int(0, satanSpeaks.length - 1)], 1);

			case 'Mercy Legacy':
				if (ClientPrefs.mechanics)
					PlayState.instance.limitThing += 25;

			case 'Mercy':
				if (ClientPrefs.mechanics)
					PlayState.instance.limitThing += 20;

			// Glitched Mickey will give you a big fat middle finger for disabling the mechanics lmao
			case 'Malfunction Legacy':
				PlayState.instance.crashLivesCounter += 30;
			case 'Malfunction':
				PlayState.camNotes.alpha = 0.001;
				PlayState.camGame.alpha = 0.001;
				PlayState.camHUD.alpha = 0.001;
				PlayState.instance.crashLivesCounter += 45;
			case 'Birthday':
				PlayState.camNotes.alpha = 0.001;
				PlayState.camBars.fade(FlxColor.BLACK, 0.0001);
				PlayState.camHUD.alpha = 0.001;
				GameData.birthdayLocky = 'beaten'; // instantly gives you birthday lel
				GameData.saveShit();
		}

		switch (PlayState.curStage)
		{
			case 'forbiddenRealm':
				FlxTween.tween(PlayState.instance.crashLives, {alpha: 0.3}, 2, {ease: FlxEase.quartInOut, startDelay: 5});
				FlxTween.tween(PlayState.instance.crashLivesIcon, {alpha: 0.3}, 2, {ease: FlxEase.quartInOut, startDelay: 5});
				PlayState.instance.add(PlayState.instance.crashLives);
				PlayState.instance.add(PlayState.instance.crashLivesIcon);

			case 'waltRoom':
				if (ClientPrefs.mechanics)
				{
					PlayState.instance.add(PlayState.instance.waltScreenThing);
					PlayState.instance.add(PlayState.instance.inkFormWarning);
					PlayState.instance.add(PlayState.instance.spaceBarCounter);
				}
				/*PlayState.strumLines.members[0].visible = false;
				PlayState.bfStrums.receptors.members[0].x = 40;
				PlayState.bfStrums.receptors.members[1].x = 320;
				PlayState.bfStrums.receptors.members[2].x = 800;
				PlayState.bfStrums.receptors.members[3].x = 1090;*/

			case 'staticVoid':
				/*PlayState.strumLines.members[0].visible = false;
				PlayState.bfStrums.receptors.members[0].x = 40;
				PlayState.bfStrums.receptors.members[1].x = 320;
				PlayState.bfStrums.receptors.members[2].x = 800;
				PlayState.bfStrums.receptors.members[3].x = 1090;*/
		}
    }

    /**
     * The Events handling system for hardcoded stuff you want to trigger in-game
     * but don't want anyone to actually mess with
     * 
     * Pretty cool if I say so myself, ngl, fun as well
     * 
     *  @author DEMOLITIONDON96 ft. Jason
     */
    public function beatHitEvents(curBeat:Int)
    {
        switch (PlayState.SONG.song)
		{
			case 'Isolated Legacy':
				switch (curBeat)
				{
					case 1 | 16 | 352 | 368: tweenCamera(1.3, 5, 'sineInOut');
					case 14 | 30 | 46 | 64 | 80 | 84: PlayState.defaultCamZoom = 0.9;
					case 32 | 48: tweenCamera(1.2, 3, 'sinInOut');
					case 40 | 42 | 44 | 56 | 58 | 60 | 62 | 82: PlayState.defaultCamZoom += 0.12;
					case 66 | 86: PlayState.defaultCamZoom += 0.2;
					case 68 | 88: PlayState.defaultCamZoom -= 0.15;
					case 72 | 74 | 76 | 78 | 90 | 92 | 94: PlayState.defaultCamZoom += 0.09;
					case 96 | 224:
						PlayState.instance.camFlashSystem(BG_DARK, {alpha: 0, timer: 0.001, ease: FlxEase.sineInOut});
						if (ClientPrefs.flashing) PlayState.camGame.flash(FlxColor.WHITE, 1);
						PlayState.defaultCamZoom = 0.9;
					case 98 | 106 | 114 | 122 | 130 | 138 | 146 | 154 | 226 | 234 | 242 | 250 | 258 | 266 | 274 | 282 | 290 | 298 | 306 | 314 | 322 | 330 | 338 | 346:
						PlayState.instance.camFlashSystem(BG_FLASH, {alpha: 0.75, timer: 0.5, ease: FlxEase.circOut});
						FlxG.camera.zoom += 0.2;
						PlayState.camHUD.zoom += 0.23;
					case 99 | 107 | 115 | 123 | 131 | 139 | 147 | 155 | 227 | 235 | 243 | 251 | 259 | 267 | 275 | 283 | 291 | 299 | 307 | 315 | 323 | 331 | 339 | 347:
						PlayState.instance.camFlashSystem(BG_FLASH, {alpha: 0.3, timer: 0.5, ease: FlxEase.circOut});
						FlxG.camera.zoom += 0.08;
						PlayState.camHUD.zoom += 0.11;
					case 101 | 109 | 117 | 125 | 133 | 141 | 149 | 157 | 229 | 237 | 245 | 253 | 261 | 269 | 277 | 285 | 293 | 301 | 309 | 317 | 325 | 333 | 341 | 349:
						PlayState.instance.camFlashSystem(BG_FLASH, {alpha: 0.4, timer: 0.5, ease: FlxEase.circOut});
						FlxG.camera.zoom += 0.1;
						PlayState.camHUD.zoom += 0.13;
					case 102 | 110 | 118 | 126 | 134 | 142 | 150 | 230 | 238 | 246 | 254 | 262 | 270 | 278 | 286 | 294 | 302 | 310 | 318 | 326 | 334 | 342 | 350:
						PlayState.instance.camFlashSystem(BG_FLASH, {alpha: 0.55, timer: 0.5, ease: FlxEase.circOut});
						FlxG.camera.zoom += 0.12;
						PlayState.camHUD.zoom += 0.15;
					case 104 | 112 | 120 | 128 | 136 | 144 | 152 | 232 | 240 | 248 | 256 | 264 | 272 | 280 | 288 | 296 | 304 | 312 | 320 | 328 | 336 | 344:
						PlayState.instance.camFlashSystem(BG_FLASH, {alpha: 0.3, timer: 0.5, ease: FlxEase.circOut});
						FlxG.camera.zoom += 0.23;
						PlayState.camHUD.zoom += 0.26;
					case 158:
						PlayState.instance.camFlashSystem(BG_DARK, {alpha: 0.85, timer: 1.2, ease: FlxEase.sineInOut});
						FlxG.camera.zoom += 0.23;
						PlayState.camHUD.zoom += 0.26;
					case 192 | 200 | 208 | 216:
						PlayState.defaultCamZoom += 0.1;
					case 366 | 382:
						PlayState.defaultCamZoom -= 0.1;
					case 367 | 383:
						PlayState.defaultCamZoom -= 0.25;
					case 412:
						tweenCamera(2, 2, "sineIn");
					case 416:
						PlayState.camGame.visible = false;
						PlayState.camHUD.visible = false;
				}
			case 'Lunacy Legacy':
				switch (curBeat)
				{
					case 4 | 8 | 12 | 14 | 40 | 56 | 104 | 112 | 120 | 124 | 126: PlayState.defaultCamZoom += 0.1;
					case 16 | 48: 
						PlayState.defaultCamZoom = 0.9;
						PlayState.camHUD.zoom += 0.2;
					case 20 | 44 | 60 | 132 | 142 | 164 | 174: PlayState.defaultCamZoom += 0.2;
					case 24:
						tweenCamera(0.7, 2, "quartInOut");
						FlxTween.tween(PlayState.camGame, {alpha: 0}, 1.5, {ease: FlxEase.quartInOut});
						FlxTween.tween(PlayState.camHUD, {alpha: 0.15}, 2, {ease: FlxEase.quartInOut});
					case 32:
						PlayState.camGame.alpha = 1;
						if (ClientPrefs.flashing) PlayState.camGame.flash(FlxColor.WHITE, 1.5);
						PlayState.camHUD.alpha = 1;
						PlayState.camHUD.zoom += 0.2;
						PlayState.defaultCamZoom = 0.9;
					case 68 | 76 | 176: PlayState.defaultCamZoom -= 0.1;
					case 72 | 134 | 144: PlayState.defaultCamZoom -= 0.15;
					case 80: PlayState.defaultCamZoom = 1.1;
					case 88 | 166 | 224: PlayState.defaultCamZoom = 0.8;
					case 128 | 256:
						PlayState.defaultCamZoom = 0.78;
						if (ClientPrefs.flashing) PlayState.camGame.flash(FlxColor.WHITE, 1.5);
						PlayState.camHUD.alpha = 0.0001;
					case 156 | 284:
						tweenCamera(1, 1, "sineInOut");
						FlxTween.tween(PlayState.camHUD, {alpha: 1}, 1.5, {ease: FlxEase.quartInOut});
					case 160: if (ClientPrefs.flashing) PlayState.camGame.flash(FlxColor.BLACK, 1.5);
					case 192: PlayState.defaultCamZoom += 0.25;
					case 320:
						if (ClientPrefs.flashing) PlayState.camGame.flash(FlxColor.BLACK, 1);
						PlayState.instance.camFlashSystem(BG_DARK, {alpha: 0.85, timer: 1, ease: FlxEase.quartInOut});
						PlayState.defaultCamZoom += 0.2;
					case 336: PlayState.defaultCamZoom -= 0.35;
					case 368: tweenCamera(1.3, 8, "quartInOut");
					case 400:
						if (ClientPrefs.flashing) PlayState.camGame.flash(FlxColor.BLACK, 1.5);
						PlayState.instance.camFlashSystem(BG_DARK, {alpha: 0, timer: 1, ease: FlxEase.sineOut});
					case 404:
						FlxTween.tween(PlayState.camGame, {alpha: 0}, 1.5, {ease: FlxEase.quartInOut});
						FlxTween.tween(PlayState.camHUD, {alpha: 0}, 1.5, {ease: FlxEase.quartInOut});
				}
			case "Twisted Grins Legacy":
				switch (curBeat)
				{
					case 62:
						FlxTween.tween(PlayState.camGame, {alpha: 0}, 3, {ease: FlxEase.quartInOut});
						FlxTween.tween(PlayState.camHUD, {alpha: 0}, 3, {ease: FlxEase.quartInOut});
						FlxTween.tween(PlayState.camNotes, {alpha: 0}, 3, {ease: FlxEase.quartInOut});
					case 72:
						PlayState.camGame.alpha = 1;
						if (ClientPrefs.flashing) PlayState.camGame.flash(FlxColor.WHITE, 1.5);
						PlayState.camHUD.alpha = 1;
						PlayState.camNotes.alpha = 0.001;
					case 120 | 122 | 125 | 324 | 320 | 332 | 356 | 360 | 364: PlayState.defaultCamZoom += 0.15;
					case 128: tweenCamera(0.9, 1, "sineInOut");
					case 156 | 400: PlayState.defaultCamZoom += 0.35;
					case 159 | 308 | 340 | 376: PlayState.defaultCamZoom = 0.9;
					case 160 | 228 | 404 | 472:
						PlayState.defaultCamZoom = 0.9;
						PlayState.instance.camFlashSystem(BG_DARK, {alpha: 0, timer: 0.5, ease: FlxEase.quartOut});
						if (ClientPrefs.shaking)
						{
							PlayState.camGame.shake(0.01, 24);
							PlayState.camHUD.shake(0.004, 24);
							PlayState.camNotes.shake(0.004, 24);
						}
					case 224 | 468:
						PlayState.instance.camFlashSystem(BG_DARK, {alpha: 0.8, timer: 0.5, ease: FlxEase.quartOut});
						PlayState.defaultCamZoom += 0.35;
					case 292: PlayState.defaultCamZoom = 1.3;
					case 336: PlayState.defaultCamZoom -= 0.1;
					case 536:
						if (ClientPrefs.flashing) PlayState.camGame.flash(FlxColor.WHITE, 1.5);
						PlayState.camHUD.visible = false;
						PlayState.camNotes.visible = false;
					case 575: PlayState.camGame.visible = false;
				}
			case 'Cycled Sins Legacy':
				switch (curBeat)
				{
					case 128:
						FlxTween.tween(PlayState.camHUD, {alpha: 0}, 1, {ease: FlxEase.sineInOut});
						FlxTween.tween(PlayState.camGame, {alpha: 0}, 1.5, {ease: FlxEase.sineInOut});
						//FlxTween.tween(PlayState.dadStrums, {alpha: 0}, 1, {ease: FlxEase.sineInOut});
					case 138: FlxTween.tween(PlayState.camGame, {alpha: 1}, 1, {ease: FlxEase.sineInOut});
					case 144:
						PlayState.camGame.setFilters(
						[
							new ShaderFilter(PlayState.staticEffect),
							new ShaderFilter(PlayState.redVignette),
							new ShaderFilter(PlayState.chromZoomShader),
							new ShaderFilter(PlayState.dramaticCamMovement),
						]);
						PlayState.camGame.visible = true;
						PlayState.camHUD.alpha = 1;
						PlayState.camNotes.visible = true;
						PlayState.camGame.flash(FlxColor.RED, 1.2);
						FlxTween.tween(PlayState, {health: 0.1}, 1, {ease: FlxEase.sineInOut});
					case 272:
						FlxTween.tween(PlayState, {health: 0.1}, 20, {ease: FlxEase.quartInOut});
						FlxTween.tween(PlayState.camHUD, {alpha: 0}, 1, {ease: FlxEase.sineInOut});
						FlxTween.tween(PlayState.camNotes, {alpha: 0}, 1, {ease: FlxEase.sineInOut, startDelay: 0.5});
					case 332:
						FlxTween.tween(PlayState.camHUD, {alpha: 1}, 1, {ease: FlxEase.sineInOut});
           	 			FlxTween.tween(PlayState.camNotes, {alpha: 1}, 1, {ease: FlxEase.sineInOut});
					case 544:
						PlayState.camGame.flash(FlxColor.BLACK, 1.5);
						PlayState.camHUD.visible = false;
						PlayState.camNotes.visible = false;
					//gunshots pew pew
					case 158 | 172 | 190 | 204 | 212 | 220 | 222 | 228 | 236 | 244 | 252 | 254 | 260 | 268 | 334 | 398 | 422 | 428 | 430 | 436 | 446 | 452 | 462 | 468 | 472 | 478 | 486 | 492 | 494 | 500 | 510 | 514 | 520 | 524 | 526 | 532 | 540 | 542:
						if (ClientPrefs.mechanics)
						{
							PlayState.instance.relapseGimmick(0.7, 0.3);
						}
				}
			case 'Devilish Deal':
				switch (curBeat)
				{
					// Intro
					case 8: FlxTween.tween(PlayState.camGame, {alpha: 1}, 4.5, {ease: FlxEase.sineOut});

					case 16:
						PlayState.instance.manageLyrics('placeholder', 'In the rain...', 'satanFont', 30, 2, 'sineInOut', 0.1);

					case 20:
						PlayState.instance.manageLyrics('placeholder', '...Looking so blue...', 'satanFont', 30, 3.2, 'sineInOut', 0.08);

					case 26:
						PlayState.instance.manageLyrics('placeholder', '...SPEAK...', 'satanFont', 30, 0.7, 'sineInOut', 0.05);

					case 28:
						PlayState.instance.manageLyrics('placeholder', '...What is on your mind?', 'satanFont', 30, 2.5, 'sineInOut', 0.06);

					case 30:
						FlxTween.tween(PlayState.camHUD, {alpha: 1}, 2, {ease: FlxEase.sineOut});
						FlxTween.tween(PlayState.camNotes, {alpha: 1}, 2, {ease: FlxEase.sineOut});

					case 32 | 34 | 36 | 38 | 40 | 42 | 44 | 46 | 48 | 50 | 52 | 54 | 56 | 58:
						if (PlayState.instance.canaddshaders)
						{
							if (PlayState.instance.chromTween != null)
								PlayState.instance.chromTween.cancel();

							PlayState.instance.chromEffect = 0.32;

							PlayState.instance.chromTween = FlxTween.tween(PlayState.instance, {
								chromEffect: 0.0001
							}, 1.2, {
								ease: FlxEase.sineOut,
								onComplete: function(twn:FlxTween)
								{
									PlayState.instance.chromTween = null;
								}
							});
						}

					case 60:
						FlxTween.tween(PlayState.camHUD, {alpha: 0.4}, 0.75, {ease: FlxEase.quartInOut});
						FlxTween.tween(PlayState.camNotes, {alpha: 0.4}, 0.75, {ease: FlxEase.quartInOut});
						if (PlayState.instance.canaddshaders)
						{
							if (PlayState.instance.chromTween != null)
								PlayState.instance.chromTween.cancel();

							PlayState.instance.chromEffect = 0.15;

							PlayState.instance.chromTween = FlxTween.tween(PlayState.instance, {
								chromEffect: 0.00001
							}, 1.2, {
								ease: FlxEase.sineOut,
								onComplete: function(twn:FlxTween)
								{
									PlayState.instance.chromTween = null;
								}
							});
						}

					case 62:
						if (PlayState.instance.canaddshaders)
						{
							if (PlayState.instance.chromTween != null)
								PlayState.instance.chromTween.cancel();

							PlayState.instance.chromEffect = 0.15;

							PlayState.instance.chromTween = FlxTween.tween(PlayState.instance, {
								chromEffect: 0.00001
							}, 2, {
								ease: FlxEase.sineOut,
								onComplete: function(twn:FlxTween)
								{
									PlayState.instance.chromTween = null;
								}
							});
						}

					case 64:
						FlxTween.tween(PlayState.camHUD, {alpha: 1}, 1.2, {ease: FlxEase.quartInOut});
						FlxTween.tween(PlayState.camNotes, {alpha: 1}, 1.2, {ease: FlxEase.quartInOut});

					case 128:
						PlayState.camGame.visible = false;
						PlayState.camNotes.visible = false;
						if (ClientPrefs.flashing)
							PlayState.camOther.flash(FlxColor.WHITE, 1);
						if (PlayState.instance.canaddshaders)
						{
							if (PlayState.instance.chromTween != null)
								PlayState.instance.chromTween.cancel();

							PlayState.instance.chromEffect = 0.4;

							PlayState.instance.chromTween = FlxTween.tween(PlayState.instance, {
								chromEffect: 0.00001
							}, 2.3, {
								ease: FlxEase.sineOut,
								onComplete: function(twn:FlxTween)
								{
									PlayState.instance.chromTween = null;
								}
							});
						}
				}

				if (curBeat >= 64 && curBeat <= 95 && PlayState.instance.canaddshaders)
				{
					if (PlayState.instance.chromTween != null)
						PlayState.instance.chromTween.cancel();

					PlayState.instance.chromEffect = 0.23;

					PlayState.instance.chromTween = FlxTween.tween(PlayState.instance, {
						chromEffect: 0.00001
					}, 1.5, {
						ease: FlxEase.sineOut,
						onComplete: function(twn:FlxTween)
						{
							PlayState.instance.chromTween = null;
						}
					});
				}

				if (curBeat >= 96 && curBeat <= 111 && PlayState.instance.canaddshaders)
				{
					if (PlayState.instance.chromTween != null)
						PlayState.instance.chromTween.cancel();

					PlayState.instance.chromEffect = 0.27;

					PlayState.instance.chromTween = FlxTween.tween(PlayState.instance, {
						chromEffect: 0.0001
					}, 1.5, {
						ease: FlxEase.sineOut,
						onComplete: function(twn:FlxTween)
						{
							PlayState.instance.chromTween = null;
						}
					});
				}

				if (curBeat >= 112 && curBeat <= 127 && PlayState.instance.canaddshaders)
				{
					if (PlayState.instance.chromTween != null)
						PlayState.instance.chromTween.cancel();

					PlayState.instance.chromEffect = 0.32;

					PlayState.instance.chromTween = FlxTween.tween(PlayState.instance, {
						chromEffect: 0.00001
					}, 1.5, {
						ease: FlxEase.sineOut,
						onComplete: function(twn:FlxTween)
						{
							PlayState.instance.chromTween = null;
						}
					});
				}
			case 'Isolated':
				var beatBopArray:Array<Int> = [32, 36, 40, 44, 48, 52, 56, 60, 64, 68, 72, 76, 80, 84, 88, 92];
				var beatBopArray2:Array<Int> = [168, 172, 176, 184, 188];
				var beatBopArray3:Array<Int> = [194, 196, 198, 200, 202, 204, 206, 208, 210, 212, 214, 216, 217, 218, 219, 220, 221, 222, 223];

				switch (curBeat)
				{
					case 12: PlayState.camBars.fade(FlxColor.BLACK, 3, true);

					case 30:
						FlxTween.tween(PlayState.camHUD, {alpha: 1}, 3, {ease: FlxEase.quadOut});
						FlxTween.tween(PlayState.camNotes, {alpha: 1}, 3, {ease: FlxEase.quadOut});

					case 88: 
						tweenCamera(1.4, 3, 'sineInOut');
						PlayState.instance.camFlashSystem(BG_FLASH, {alpha: 0.32, timer: 1.2, colors: [194, 194, 194]});

					case 95: 
						PlayState.cameraSpeed += 3;
						//PlayState.instance.updateSectionCamera('dad', false);

					case 96:
						PlayState.cameraSpeed -= 3;
						PlayState.defaultCamZoom = 0.85;
						tweenCamera(0.85, 0.4, 'expoOut');

						if (ClientPrefs.flashing)
							PlayState.camGame.flash(FlxColor.WHITE, 1.5);
						PlayState.instance.camFlashSystem(BG_FLASH, {alpha: 0.4, timer: 0.35});

					case 160: 
						tweenCamera(1.3, 2, 'sineInOut');
						PlayState.instance.camFlashSystem(BG_DARK, {alpha: 0.85, timer: 0.5, ease: FlxEase.quartOut});

					case 184:
						PlayState.instance.camFlashSystem(BG_DARK, {alpha: 0.77, timer: 0.5, ease: FlxEase.quartOut});

					case 188:
						PlayState.instance.camFlashSystem(BG_DARK, {alpha: 0.6, timer: 0.5, ease: FlxEase.quartOut});

					case 192: 
						if (ClientPrefs.flashing)
							PlayState.camGame.flash(FlxColor.WHITE, 1.5);
						PlayState.instance.camFlashSystem(BG_FLASH, {alpha: 0.32, timer: 0.35, colors: [194, 194, 194]});
						
						PlayState.defaultCamZoom = 1.25;

					// same as dad
					// case 199: PlayState.instance.updateSectionCamera('bf', true);

					// update after testing without the cam thing they rarely still stunned so idk what to do lmao

					case 220: 
						tweenCamera(0.85, 2, 'sineInOut');
						PlayState.instance.camFlashSystem(BG_FLASH, {alpha: 0.32, timer: 0.1, colors: [194, 194, 194]});

					case 288:
						PlayState.defaultCamZoom = 0.85;

						if (ClientPrefs.flashing)
							PlayState.camGame.flash(FlxColor.WHITE, 1.5);
						PlayState.instance.camFlashSystem(BG_FLASH, {alpha: 0.4, timer: 0.35, colors: [194, 194, 194]});

					case 352:
						PlayState.instance.camFlashSystem(BG_DARK, {alpha: 0.85, timer: 0.5, ease: FlxEase.quartOut});
						tweenCamera(1.07, 5, 'quadInOut');
						PlayState.cameraSpeed -= 0.25;

					case 376:
						PlayState.instance.camFlashSystem(BG_DARK, {alpha: 0, timer: 4, ease: FlxEase.quartInOut});

					case 36 | 40 | 44 | 52 | 56 | 60 | 64 | 68 | 72 | 76 | 80 | 84 | 92:
						PlayState.instance.camFlashSystem(BG_FLASH, {alpha: 0.32, timer: 1.2, colors: [194, 194, 194]});

					case 100 | 104 | 108 | 116 | 120 | 124 | 132 | 136 | 140 | 148 | 152 | 156 | 228 | 232 | 236 | 240 | 244 | 252 | 260 | 264 | 268 | 276 |
						280 | 284 | 292 | 296 | 300 | 308 | 312 | 316 | 324 | 328 | 332 | 340 | 344 | 348:
						PlayState.instance.camFlashSystem(BG_FLASH, {alpha: 0.4, timer: 0.35, colors: [194, 194, 194]});

					case 98 | 102 | 106 | 110 | 114 | 118 | 122 | 126 | 130 | 134 | 138 | 142 | 146 | 150 | 154 | 158 | 226 | 230 | 234 | 238 | 242 | 246 |
						250 | 254 | 258 | 262 | 266 | 270 | 274 | 278 | 282 | 286 | 290 | 294 | 298 | 302 | 306 | 310 | 314 | 318 | 322 | 326 | 330 | 334 |
						338 | 342 | 346 | 350:
						PlayState.instance.camFlashSystem(BG_FLASH, {alpha: 0.67, timer: 0.35, colors: [194, 194, 194]});

					case 194 | 196 | 198 | 200 | 202 | 204 | 206 | 210 | 212 | 214 | 222:
						PlayState.instance.camFlashSystem(BG_FLASH, {alpha: 0.32, timer: 0.35, colors: [194, 194, 194]});

					case 216 | 217 | 218 | 219:
						PlayState.instance.camFlashSystem(BG_FLASH, {alpha: 0.32, timer: 0.1, colors: [194, 194, 194]});
						PlayState.camHUD.zoom += 0.04;

					case 128 | 256:
						if (ClientPrefs.flashing)
							PlayState.camGame.flash(FlxColor.WHITE, 1.5);
						PlayState.instance.camFlashSystem(BG_FLASH, {alpha: 0.4, timer: 0.35, colors: [194, 194, 194]});

					case 48 | 336 | 304 | 272 | 112 | 144:
						if (ClientPrefs.flashing)
							PlayState.camGame.flash(FlxColor.BLACK, 1.5);
						PlayState.instance.camFlashSystem(BG_FLASH, {alpha: 0.32, timer: 1.2, colors: [194, 194, 194]});

					case 32:
						if (ClientPrefs.flashing) PlayState.camGame.flash(FlxColor.WHITE, 1.5);

					case 416:
						PlayState.camGame.visible = false;
						PlayState.camHUD.visible = false;
						PlayState.camNotes.visible = false;

					case 224:
						PlayState.instance.camFlashSystem(BG_FLASH, {alpha: 0.4, timer: 0.35, colors: [194, 194, 194]});
						if (ClientPrefs.flashing) PlayState.camGame.flash(FlxColor.WHITE, 1.5);

					case 320:
						PlayState.instance.camFlashSystem(BG_FLASH, {alpha: 0.4, timer: 0.35, colors: [194, 194, 194]});
						if (ClientPrefs.flashing) PlayState.camGame.flash(FlxColor.WHITE, 1.5);
				}

				if (curBeat == 1)
				{
					cinematicBarControls("add", 0.0001, 'linear', 0);
					cinematicBarControls("moveboth", 0.0001, 'linear', 130);
				}
				if (curBeat == 28)
					cinematicBarControls("moveboth", 1, 'circInOut', 65);
				for (i in 0...beatBopArray.length)
					if (curBeat == beatBopArray[i])
						cinematicBarControls('bopboth', 1, 'quartOut', 32, 33);
				if (curBeat == 96)
					cinematicBarControls('moveboth', 0.3, 'sineOut', 0);
				if (curBeat == 160 || curBeat == 352)
					cinematicBarControls('moveboth', 1, 'circOut', 140);
				if (curBeat == 164 || curBeat == 180)
					cinematicBarControls('bopboth', 0.85, 'quartOut', 125, 15);
				for (i in 0...beatBopArray2.length)
					if (curBeat == beatBopArray2[i])
						cinematicBarControls('bopboth', 1, 'quartOut', 90, 60);
				if (curBeat == 192)
					cinematicBarControls('moveboth', 0.7, 'sineOut', 85);
				for (i in 0...beatBopArray3.length)
					if (curBeat == beatBopArray3[i])
						cinematicBarControls('bopboth', 0.3, 'sineOut', 40, 45);
				if (curBeat == 224)
					cinematicBarControls('moveboth', 0.3, 'quartOut', 0);
				if (curBeat == 287)
					cinematicBarControls('moveboth', 0.0001, 'linear', 100);
				if (curBeat == 288)
					cinematicBarControls('moveboth', 0.75, 'circOut', 0);
				if (curBeat == 376)
					cinematicBarControls('moveboth', 3, 'sineInOut', 0);
				if (curBeat == 415)
					cinematicBarControls('moveboth', 0.63, 'circInOut', 600);

				if ((curBeat > 96 && curBeat < 160) || (curBeat > 224 && curBeat < 352))
				{
					if (curBeat % 2 == 0)
					{
						PlayState.camGame.zoom += 0.05;
						PlayState.camHUD.zoom += 0.06;
						PlayState.camNotes.zoom = PlayState.camHUD.zoom;
					}
				}

			case 'Lunacy':
				var beatArray1:Array<Int> = [38, 40, 46, 48, 54, 56, 62];
				var beatArray2:Array<Int> = [70, 72, 78, 80, 86, 88];
				var beatArray3:Array<Int> = [224, 230, 240, 248, 256, 262, 272, 280, 288, 296, 304, 312, 320, 328, 336, 344];
				var beatArray4:Array<Int> = [228, 238, 244, 252, 260, 270, 276, 284, 292, 300, 308, 316, 324, 332, 340, 348];

				if (curBeat == 1)
					{
						cinematicBarControls("add", 0.0001, 'linear', 0);
						cinematicBarControls("moveboth", 0.0001, 'linear', 60);
					}
					if (curBeat == 32)
						cinematicBarControls("moveboth", 1.2, "circOut", 120);
					if (curBeat == 64)
						cinematicBarControls("moveboth", 1.2, "circOut", 190);
					if (curBeat == 90)
						cinematicBarControls("moveboth", 2, "circInOut", 0);
					for (i in 0...beatArray1.length)
						if (curBeat == beatArray1[i])
							cinematicBarControls("bopboth", 0.5, "quartOut", 100, 20);
					for (i in 0...beatArray2.length)
						if (curBeat == beatArray2[i])
							cinematicBarControls("bopboth", 0.5, "quartOut", 170, 20);
					if (curBeat == 156)
						cinematicBarControls("moveboth", 0.4, "circOut", 120);
					if (curBeat == 160)
						cinematicBarControls("moveboth", 1, "circOut", 80);
					if (curBeat == 192)
						cinematicBarControls("moveboth", 10, "circInOut", 180);
					for (i in 0...beatArray3.length)
						if (curBeat == beatArray3[i])
							cinematicBarControls("moveboth", 0.5, "circOut", 60);
					for (i in 0...beatArray4.length)
						if (curBeat == beatArray4[i])
							cinematicBarControls("moveboth", 0.15, "circOut", 130);
					if (curBeat == 352)
						cinematicBarControls("moveboth", 2, "circOut", 50);
					if (curBeat == 480)
						cinematicBarControls("moveboth", 0.0001, 'linear', 110);

				if (curBeat == 100 || curBeat == 108 || curBeat == 116 || curBeat == 124 || curBeat == 132 || curBeat == 140 || curBeat == 148)
				{
					PlayState.instance.camFlashSystem(BG_FLASH, {alpha: 0.5, timer: 0.5, ease: FlxEase.sineOut});
				}

				if (curBeat == 160 || curBeat == 230 || curBeat == 240 || curBeat == 248 || curBeat == 256 || curBeat == 262 || curBeat == 272
					|| curBeat == 280 || curBeat == 280 || curBeat == 288 || curBeat == 296 || curBeat == 304 || curBeat == 312 || curBeat == 320
					|| curBeat == 328 || curBeat == 336 || curBeat == 344 || curBeat == 352)
				{
					PlayState.instance.camFlashSystem(BG_DARK, {alpha: 0, timer: 0.5, ease: FlxEase.quadOut});
				}

				// Darkens BG
				if (curBeat == 156 || curBeat == 228 || curBeat == 238 || curBeat == 244 || curBeat == 252 || curBeat == 260 || curBeat == 270
					|| curBeat == 276 || curBeat == 284 || curBeat == 292 || curBeat == 300 || curBeat == 308 || curBeat == 316 || curBeat == 324
					|| curBeat == 332 || curBeat == 340 || curBeat == 348)
				{
					PlayState.instance.camFlashSystem(BG_DARK, {alpha: 0.77, timer: 0.5, ease: FlxEase.quadOut});
				}

				if (curBeat == 424 || curBeat == 432 || curBeat == 440 || curBeat == 448 || curBeat == 456 || curBeat == 464 || curBeat == 472)
				{
					PlayState.instance.camFlashSystem(BG_FLASH, {alpha: 0.65, timer: 0.6, ease: FlxEase.sineOut});
				}

				if (curBeat == 32 || curBeat == 64)
				{
					if (PlayState.instance.chromTween != null)
						PlayState.instance.chromTween.cancel();

					PlayState.instance.chromEffect = 0.27;

					PlayState.instance.chromTween = FlxTween.tween(PlayState.instance, {
						chromEffect: 0.0001
					}, 1.5, {
						ease: FlxEase.sineOut,
						onComplete: function(twn:FlxTween)
						{
							PlayState.instance.chromTween = null;
						}
					});
				}

				if (curBeat == 38 || curBeat == 40 || curBeat == 46 || curBeat == 48 || curBeat == 54 || curBeat == 56 || curBeat == 62 || curBeat == 70
					|| curBeat == 72 || curBeat == 78 || curBeat == 80 || curBeat == 86 || curBeat == 88 || curBeat == 102 || curBeat == 110
					|| curBeat == 118 || curBeat == 126 || curBeat == 134 || curBeat == 142 || curBeat == 150)
				{
					if (PlayState.instance.chromTween != null)
						PlayState.instance.chromTween.cancel();

					PlayState.instance.chromEffect = 0.12;

					PlayState.instance.chromTween = FlxTween.tween(PlayState.instance, {
						chromEffect: 0.0001
					}, 0.3, {
						ease: FlxEase.sineOut,
						onComplete: function(twn:FlxTween)
						{
							PlayState.instance.chromTween = null;
						}
					});
				}

				if (curBeat == 96 || curBeat == 104 || curBeat == 112 || curBeat == 120 || curBeat == 128 || curBeat == 136 || curBeat == 144 || curBeat == 152)
				{
					if (PlayState.instance.chromTween != null)
						PlayState.instance.chromTween.cancel();

					PlayState.instance.chromEffect = 0.32;

					PlayState.instance.chromTween = FlxTween.tween(PlayState.instance, {
						chromEffect: 0.0001
					}, 2.1, {
						ease: FlxEase.sineOut,
						onComplete: function(twn:FlxTween)
						{
							PlayState.instance.chromTween = null;
						}
					});
				}

				if (curBeat == 100 || curBeat == 108 || curBeat == 116 || curBeat == 124 || curBeat == 132 || curBeat == 140 || curBeat == 148)
				{
					if (PlayState.instance.chromTween != null)
						PlayState.instance.chromTween.cancel();
	
					PlayState.instance.chromEffect = 0.4;
	
					PlayState.instance.chromTween = FlxTween.tween(PlayState.instance, {
						chromEffect: 0.0001
					}, 1, {
						ease: FlxEase.sineOut,
						onComplete: function(twn:FlxTween)
						{
							PlayState.instance.chromTween = null;
						}
					});
				}

				if (curBeat == 156)
				{
					if (PlayState.instance.chromTween != null)
						PlayState.instance.chromTween.cancel();

					PlayState.instance.chromTween = FlxTween.tween(PlayState.instance, {
						chromEffect: 0.33
					}, 0.2, {
						ease: FlxEase.sineOut,
						onComplete: function(twn:FlxTween)
						{
							PlayState.instance.chromTween = null;
						}
					});
				}

				if (curBeat == 158)
				{
					if (PlayState.instance.chromTween != null)
						PlayState.instance.chromTween.cancel();

					PlayState.instance.chromEffect = 0.4;

					PlayState.instance.chromTween = FlxTween.tween(PlayState.instance, {
						chromEffect: 0.0001
					}, 0.2, {
						ease: FlxEase.sineOut,
						onComplete: function(twn:FlxTween)
						{
							PlayState.instance.chromTween = null;
						}
					});
				}

				if (curBeat == 160 || curBeat == 168 || curBeat == 176 || curBeat == 184 || curBeat == 192 || curBeat == 200 || curBeat == 208
					|| curBeat == 216 || curBeat == 224 || curBeat == 232 || curBeat == 240 || curBeat == 248 || curBeat == 256 || curBeat == 264
					|| curBeat == 272 || curBeat == 280 || curBeat == 288 || curBeat == 296 || curBeat == 304 || curBeat == 312 || curBeat == 320
					|| curBeat == 328 || curBeat == 336 || curBeat == 344)
				{
					if (PlayState.instance.chromTween != null)
						PlayState.instance.chromTween.cancel();

					PlayState.instance.chromEffect = 0.55;

					PlayState.instance.chromTween = FlxTween.tween(PlayState.instance, {
						chromEffect: 0.0001
					}, 0.6, {
						ease: FlxEase.sineOut,
						onComplete: function(twn:FlxTween)
						{
							PlayState.instance.chromTween = null;
						}
					});
				}

				if (curBeat == 162 || curBeat == 170 || curBeat == 178 || curBeat == 186 || curBeat == 194 || curBeat == 202 || curBeat == 210
					|| curBeat == 218 || curBeat == 226 || curBeat == 234 || curBeat == 242 || curBeat == 250 || curBeat == 258 || curBeat == 266
					|| curBeat == 274 || curBeat == 282 || curBeat == 290 || curBeat == 298 || curBeat == 306 || curBeat == 314 || curBeat == 322
					|| curBeat == 330 || curBeat == 338 || curBeat == 346)
				{
					if (PlayState.instance.chromTween != null)
						PlayState.instance.chromTween.cancel();

					PlayState.instance.chromEffect = 0.6;

					PlayState.instance.chromTween = FlxTween.tween(PlayState.instance, {
						chromEffect: 0.0001
					}, 0.25, {
						ease: FlxEase.sineOut,
						onComplete: function(twn:FlxTween)
						{
							PlayState.instance.chromTween = null;
						}
					});
				}

				if (curBeat == 163 || curBeat == 171 || curBeat == 179 || curBeat == 187 || curBeat == 195 || curBeat == 203 || curBeat == 211
					|| curBeat == 219 || curBeat == 227 || curBeat == 235 || curBeat == 243 || curBeat == 251 || curBeat == 259 || curBeat == 267
					|| curBeat == 275 || curBeat == 283 || curBeat == 291 || curBeat == 299 || curBeat == 307 || curBeat == 315 || curBeat == 323
					|| curBeat == 331 || curBeat == 339 || curBeat == 347)
				{
					if (PlayState.instance.chromTween != null)
						PlayState.instance.chromTween.cancel();

					PlayState.instance.chromTween = FlxTween.tween(PlayState.instance, {
						chromEffect: 0.5
					}, 0.22, {
						ease: FlxEase.sineOut,
						onComplete: function(twn:FlxTween)
						{
							PlayState.instance.chromTween = null;
							PlayState.instance.chromEffect = 0.00001;
						}
					});
				}

				if (curBeat == 165 || curBeat == 173 || curBeat == 181 || curBeat == 189 || curBeat == 197 || curBeat == 205 || curBeat == 213
					|| curBeat == 221)
				{
					if (PlayState.instance.chromTween != null)
						PlayState.instance.chromTween.cancel();

					PlayState.instance.chromTween = FlxTween.tween(PlayState.instance, {
						chromEffect: 0.35
					}, 0.2, {
						ease: FlxEase.sineOut,
						onComplete: function(twn:FlxTween)
						{
							PlayState.instance.chromTween = null;
							PlayState.instance.chromEffect = 0.00001;
						}
					});
				}

				if (curBeat == 166 || curBeat == 174 || curBeat == 182 || curBeat == 190 || curBeat == 198 || curBeat == 206 || curBeat == 214
					|| curBeat == 222)
				{
					if (PlayState.instance.chromTween != null)
						PlayState.instance.chromTween.cancel();

					PlayState.instance.chromEffect = 0.45;

					PlayState.instance.chromTween = FlxTween.tween(PlayState.instance, {
						chromEffect: 0.0001
					}, 0.2, {
						ease: FlxEase.sineOut,
						onComplete: function(twn:FlxTween)
						{
							PlayState.instance.chromTween = null;
						}
					});
				}

				if (curBeat == 167 || curBeat == 175 || curBeat == 183 || curBeat == 191 || curBeat == 199 || curBeat == 207 || curBeat == 215
					|| curBeat == 223)
				{
					if (PlayState.instance.chromTween != null)
						PlayState.instance.chromTween.cancel();

					PlayState.instance.chromEffect = 0.56;

					PlayState.instance.chromTween = FlxTween.tween(PlayState.instance, {
						chromEffect: 0.0001
					}, 0.2, {
						ease: FlxEase.sineOut,
						onComplete: function(twn:FlxTween)
						{
							PlayState.instance.chromTween = null;
						}
					});
				}

				if (curBeat >= 228 && curBeat <= 231 || curBeat >= 236 && curBeat <= 239 || curBeat >= 244 && curBeat <= 247 || curBeat >= 252
					&& curBeat <= 255 || curBeat >= 260 && curBeat <= 263 || curBeat >= 168 && curBeat <= 171 || curBeat >= 276 && curBeat <= 279
					|| curBeat >= 284 && curBeat <= 287 || curBeat >= 292 && curBeat <= 295 || curBeat >= 300 && curBeat <= 303 || curBeat >= 308
					&& curBeat <= 311 || curBeat >= 316 && curBeat <= 319 || curBeat >= 324 && curBeat <= 327 || curBeat >= 332 && curBeat <= 335
					|| curBeat >= 340 && curBeat <= 343 || curBeat >= 348 && curBeat <= 351)
				{
					if (PlayState.instance.chromTween != null)
						PlayState.instance.chromTween.cancel();

					PlayState.instance.chromEffect = 0.32;

					PlayState.instance.chromTween = FlxTween.tween(PlayState.instance, {
						chromEffect: 0.00001
					}, 0.22, {
						ease: FlxEase.sineOut,
						onComplete: function(twn:FlxTween)
						{
							PlayState.instance.chromTween = null;
						}
					});
				}

				if (curBeat == 352 || curBeat == 354 || curBeat == 356 || curBeat == 358 || curBeat == 360 || curBeat == 362 || curBeat == 364
					|| curBeat == 366 || curBeat == 368 || curBeat == 370 || curBeat == 372 || curBeat == 374 || curBeat == 376 || curBeat == 378
					|| curBeat == 380 || curBeat == 382 || curBeat == 384 || curBeat == 386 || curBeat == 388 || curBeat == 390 || curBeat == 392
					|| curBeat == 394 || curBeat == 396 || curBeat == 398 || curBeat == 400 || curBeat == 402 || curBeat == 404 || curBeat == 406
					|| curBeat == 408 || curBeat == 410 || curBeat == 416 || curBeat == 418 || curBeat == 420 || curBeat == 422 || curBeat == 424
					|| curBeat == 426 || curBeat == 428 || curBeat == 430 || curBeat == 432 || curBeat == 434 || curBeat == 436 || curBeat == 438
					|| curBeat == 440 || curBeat == 442 || curBeat == 444 || curBeat == 446 || curBeat == 448 || curBeat == 450 || curBeat == 452
					|| curBeat == 454 || curBeat == 456 || curBeat == 458 || curBeat == 460 || curBeat == 462 || curBeat == 464 || curBeat == 466
					|| curBeat == 468 || curBeat == 470 || curBeat == 472 || curBeat == 474)
				{
					if (PlayState.instance.chromTween != null)
						PlayState.instance.chromTween.cancel();

					PlayState.instance.chromEffect = 0.3;

					PlayState.instance.chromTween = FlxTween.tween(PlayState.instance, {
						chromEffect: 0.00001
					}, 0.5, {
						ease: FlxEase.sineOut,
						onComplete: function(twn:FlxTween)
						{
							PlayState.instance.chromTween = null;
						}
					});
				}

				if (curBeat == 412)
				{
					if (PlayState.instance.chromTween != null)
						PlayState.instance.chromTween.cancel();

					PlayState.instance.chromEffect = 0.36;

					PlayState.instance.chromTween = FlxTween.tween(PlayState.instance, {
						chromEffect: 0.00001
					}, 1, {
						ease: FlxEase.sineOut,
						onComplete: function(twn:FlxTween)
						{
							PlayState.instance.chromTween = null;
						}
					});
				}

				if (curBeat == 476)
				{
					if (PlayState.instance.chromTween != null)
						PlayState.instance.chromTween.cancel();

					PlayState.instance.chromTween = FlxTween.tween(PlayState.instance, {
						chromEffect: 0.85
					}, 1.6, {
						ease: FlxEase.sineOut,
						onComplete: function(twn:FlxTween)
						{
							PlayState.instance.chromTween = null;
						}
					});
				}

				if (curBeat == 480)
				{
					PlayState.instance.chromTween.cancel();

					PlayState.instance.chromEffect = 0.00001;
				}

				switch (curBeat)
				{
					// I'm NOT gonna have a fun time recoding all this for the BG dimming in and out later lmao

					case 16: PlayState.camBars.fade(FlxColor.BLACK, 3, true);

					case 32:
						if (ClientPrefs.flashing) PlayState.camBars.flash(FlxColor.BLACK, 1.5);
						tweenCamera(PlayState.camGame.zoom + .5, 16.5, 'sineInOut');

					case 64:
						if (ClientPrefs.flashing)
							PlayState.camBars.flash(FlxColor.BLACK, 0.9);

					case 88:
						tweenCamera(.75, 2.2, 'sineInOut');

						FlxTween.tween(PlayState.camHUD, {alpha: 1}, 5, {ease: FlxEase.sineOut});
						FlxTween.tween(PlayState.camNotes, {alpha: 1}, 5, {ease: FlxEase.sineOut});

					case 96:
						PlayState.defaultCamZoom = 0.75;
						if (ClientPrefs.flashing)
							PlayState.camBars.flash(FlxColor.WHITE, 1.5);

					case 128 | 256:
						if (ClientPrefs.flashing) PlayState.camBars.flash(FlxColor.WHITE, 1.5);

					case 156:
						PlayState.defaultCamZoom = 1.05;

					case 160:
						boundValue = 1.25;
						drainValue = 0.015;
						PlayState.defaultCamZoom = 0.7;
						if (ClientPrefs.flashing) PlayState.camBars.flash(FlxColor.BLACK, 1.5);

					case 192:
						PlayState.defaultCamZoom = 0.75;
					case 200 | 238 | 270 | 316 | 332 | 344:
						PlayState.defaultCamZoom = 0.8;
					case 208:
						PlayState.defaultCamZoom = 0.85;
					case 216 | 252 | 284:
						PlayState.defaultCamZoom = 0.9;
					case 220:
						PlayState.defaultCamZoom = 0.95;
					case 222 | 267 | 239 | 271 | 334:
						PlayState.defaultCamZoom = 1;

					case 224 | 288:
						PlayState.defaultCamZoom = 0.75;
						if (ClientPrefs.flashing)
							PlayState.camBars.flash(FlxColor.WHITE, 1.5);
						FlxTween.tween(PlayState.camHUD, {alpha: 0}, 3, {ease: FlxEase.sineInOut});
						FlxTween.tween(PlayState.camNotes, {alpha: 0}, 3, {ease: FlxEase.sineInOut});

					case 228 | 260 | 292 | 286:
						PlayState.defaultCamZoom = 1.1;

					case 230 | 262 | 296 | 312 | 236 | 268:
						PlayState.defaultCamZoom = 0.65;

					case 232 | 264:
						if (ClientPrefs.flashing)
							PlayState.camBars.flash(FlxColor.WHITE, 1.5);
						PlayState.defaultCamZoom = 0.7;

					case 412 | 240 | 272 | 300 | 304 | 336 | 248 | 280 | 328:
						PlayState.defaultCamZoom = 0.7;

					case 320:
						if (ClientPrefs.flashing)
							PlayState.camBars.flash(FlxColor.WHITE, 1.5);
						PlayState.defaultCamZoom = 0.7;

					case 254:
						PlayState.defaultCamZoom = 1.1;
						FlxTween.tween(PlayState.camHUD, {alpha: 1}, 1, {ease: FlxEase.sineInOut});
						FlxTween.tween(PlayState.camNotes, {alpha: 1}, 1, {ease: FlxEase.sineInOut});

					case 318:
						PlayState.defaultCamZoom = 1.25;
						FlxTween.tween(PlayState.camHUD, {alpha: 1}, 1, {ease: FlxEase.sineInOut});
						FlxTween.tween(PlayState.camNotes, {alpha: 1}, 1, {ease: FlxEase.sineInOut});

					case 310 | 342 | 350:
						PlayState.defaultCamZoom = 1.25;

					case 352:
						PlayState.defaultCamZoom = 0.65;
						FlxTween.tween(PlayState.camHUD, {alpha: 0.25}, 8, {ease: FlxEase.sineInOut});
						FlxTween.tween(PlayState.camNotes, {alpha: 0.25}, 8, {ease: FlxEase.sineInOut});
						FlxTween.tween(PlayState, {health: 0.01}, 20);
						if (PlayState.instance.globalGradient != null)
							FlxTween.tween(PlayState.instance.globalGradient, {alpha: 0.8}, 10);
						FlxTween.tween(FlxG.camera, {zoom: 1.1}, 18, {startDelay: 2});

					case 408:
						PlayState.defaultCamZoom = 0.9;
						FlxTween.tween(PlayState.camHUD, {alpha: 0.36}, 4, {ease: FlxEase.sineInOut});
						FlxTween.tween(PlayState.camNotes, {alpha: 0.36}, 4, {ease: FlxEase.sineInOut});

					case 416: if (ClientPrefs.flashing) PlayState.camBars.flash(FlxColor.WHITE, 1.5);

					case 480:
						boundValue = 1;
						drainValue = 0.02;
						if (ClientPrefs.flashing)
							PlayState.camBars.flash(FlxColor.BLACK, 1.5);
						PlayState.camHUD.alpha = 0;
						PlayState.camNotes.alpha = 0;

					case 481:
						PlayState.instance.camFollow.x += 100;
	
					case 506:
						FlxTween.tween(PlayState.camHUD, {alpha: 0.5}, 4, {ease: FlxEase.sineInOut});
						FlxTween.tween(PlayState.camNotes, {alpha: 0.5}, 4, {ease: FlxEase.sineInOut});

					case 536:
						FlxTween.tween(PlayState.camHUD, {alpha: 0}, 2, {ease: FlxEase.sineInOut});
						FlxTween.tween(PlayState.camNotes, {alpha: 0}, 2, {ease: FlxEase.sineInOut});

					case 540:
						PlayState.camBars.fade(FlxColor.BLACK, 5);
				}

			case 'Delusional':
				var beatShit1:Array<Int> = [752, 760, 768, 772, 776, 784, 792, 800, 804, 808, 824, 836, 856, 868];
				var beatShit2:Array<Int> = [812, 828, 844, 860];
				var beatShit3:Array<Int> = [816, 832, 848, 864];
				if (curBeat == 1)
				{
					cinematicBarControls("create", 1);
					cinematicBarControls("moveboth", 0.0001, 'linear', 100);
				}
				if (curBeat == 32)
					cinematicBarControls("moveboth", 2, 'circOut', 120);
				if (curBeat == 64)
					cinematicBarControls("moveboth", 2, 'circInOut', 75);
				if (curBeat ==128 || curBeat == 1072)
					cinematicBarControls("moveboth", 1, "circOut", 90);
				if (curBeat == 132)
					cinematicBarControls("moveboth", 2, "circOut", 180);
				if (curBeat == 144)
					cinematicBarControls("moveboth", 0.0001, 'linear', 70);
				if (curBeat == 152 || curBeat == 168)
					cinematicBarControls("moveboth", 0.5, 'circOut', 80);
				if (curBeat == 154 || curBeat == 172)
					cinematicBarControls("moveboth", 0.5, 'circOut', 90);
				if (curBeat == 156 || curBeat == 288 || curBeat == 320)
					cinematicBarControls("moveboth", 0.5, 'circOut', 100);
				if (curBeat == 158 || curBeat == 296 || curBeat == 328)
					cinematicBarControls("moveboth", 0.5, 'circOut', 110);
				if (curBeat == 160)
					cinematicBarControls("moveboth", 1, 'circOut', 70);
				if (curBeat == 176)
					cinematicBarControls("moveboth", 2, 'circOut', 0);
				if (curBeat == 280 || curBeat == 312)
					cinematicBarControls("moveboth", 1.5, 'circOut', 90);
				if (curBeat == 304 || curBeat == 336 || curBeat == 356 || curBeat == 388)
					cinematicBarControls("moveboth", 0.5, 'circOut', 120);
				if (curBeat == 308 || curBeat == 358 || curBeat == 390)
					cinematicBarControls("moveboth", 0.5, 'circOut', 130);
				if (curBeat == 338)
					cinematicBarControls("moveboth", 1, 'circOut', 80);
				if (curBeat == 344 || curBeat == 360 || curBeat == 392)
					cinematicBarControls("moveboth", 1, 'circOut', 100);
				if (curBeat == 408)
					cinematicBarControls("moveboth", 2, 'circOut', 140);
				if (curBeat == 470)
					cinematicBarControls("moveboth", 0.65, 'backIn', 380);
				if (curBeat == 480)
					cinematicBarControls("moveboth", 10, 'linear', 70);
				if (curBeat == 744)
					cinematicBarControls("moveboth", 0.0001, 'linear', 120);
				for (bounceYouStupidBitch in 0...beatShit1.length)
					if (curBeat == beatShit1[bounceYouStupidBitch])
						cinematicBarControls("bopboth", 0.5, "circOut", 90, 30);
				for (helloEverybodyMyNameIsMarkiplierAndWelcomeToFiveNightsAtFreddysAnIndieHorrorGameThatYouGuysSuggestedInMassAndISawYamimashPlayedItAndHeSaidItWasReallyReallyGoodSoImEagerToSeeWhatIsUp in 0...beatShit2.length)
					if (curBeat == beatShit2[helloEverybodyMyNameIsMarkiplierAndWelcomeToFiveNightsAtFreddysAnIndieHorrorGameThatYouGuysSuggestedInMassAndISawYamimashPlayedItAndHeSaidItWasReallyReallyGoodSoImEagerToSeeWhatIsUp])
						cinematicBarControls("moveboth", 0.8, "circIn", 185);
				for (youreCringe in 0...beatShit3.length)
					if (curBeat == beatShit3[youreCringe])
						cinematicBarControls("moveboth", 0.8, "circOut", 120);
				if (curBeat == 872)
					cinematicBarControls("moveboth", 2.5, "circInOut", 180);
				if (curBeat == 880 || curBeat == 1040)
					cinematicBarControls("moveboth", 1, "circOut", 100);
				if (curBeat == 944 || curBeat == 1056)
					cinematicBarControls("moveboth", 1.5, "circOut", 120);
				if (curBeat == 1008 || curBeat == 1064)
					cinematicBarControls("moveboth", 1, "circOut", 140);
				if (curBeat == 1024)
					cinematicBarControls("moveboth", 1, "circOut", 160);
				if (curBeat == 1030)
					cinematicBarControls("moveboth", 1, "circOut", 180);
				if (curBeat == 1136)
					cinematicBarControls("kill", 0);

				if (curBeat == 146)
					PlayState.instance.manageLyrics('bf-demon', 'Count the minutes...', 'disneyFreeplayFont', 30, 1.1, 'sineInOut', .05);
				if (curBeat == 150)
					PlayState.instance.manageLyrics('bf-demon', "...of how long...", 'disneyFreeplayFont', 30, 1, 'sineInOut', 0.04);
				if (curBeat == 154)
					PlayState.instance.manageLyrics('bf-demon', "...this show will play!", 'disneyFreeplayFont', 30, 2.2, 'quartInOut', .07);
				if (curBeat == 162)
					PlayState.instance.manageLyrics('bf-demon', "And remind yourself...", 'disneyFreeplayFont', 30, 1.3, 'sineInOut', .05);
				if (curBeat == 167)
					PlayState.instance.manageLyrics('bf-demon', "...no matter what's in...", 'disneyFreeplayFont', 30, 2, 'sineInOut', .06);
				if (curBeat == 174)
					PlayState.instance.manageLyrics('bf-demon', "...THE WAY!", 'disneyFreeplayFont', 30, 1, 'circOut', .035);
				if (curBeat == 178)
					PlayState.instance.manageLyrics('bf-demon', "All your dreams...", 'disneyFreeplayFont', 30, 1, 'sineInOut', .04);
				if (curBeat == 182)
					PlayState.instance.manageLyrics('bf-demon', "...ARE SO FAR OUT OF REACH!", 'disneyFreeplayFont', 30, 4, 'quartInOut', .055);
				if (curBeat == 190)
					PlayState.instance.manageLyrics('bf-demon', "But if YOUR delusions...", 'disneyFreeplayFont', 30, 2.2, 'sineInOut', .045);
				if (curBeat == 196)
					PlayState.instance.manageLyrics('bf-demon', "...still surround ya.", 'disneyFreeplayFont', 30, 1.3, "quartOut", .045);
				if (curBeat == 200)
					PlayState.instance.manageLyrics('bf-demon', "Let's LOOP 'ROUND ONCE MORE.", 'satanFont', 30, 3, "sineInOut", .065);

				switch (curBeat)
				{
					case 1: 
						boundValue = 1;
						drainValue = 0.02;
						PlayState.camBars.fade(FlxColor.BLACK, 2, true);
					case 132: PlayState.defaultCamZoom = 1.3;
					case 136:
						PlayState.camBars.fade();
						for (daUIs in [PlayState.camHUD, PlayState.camNotes])
							FlxTween.tween(daUIs, {alpha: 0}, 3);
					// BF Starts Singing Some Lyrics
					case 144:
						PlayState.defaultCamZoom = 0.8;
						PlayState.camBars.fade(0x000000, 5, true);
						PlayState.instance.camFlashSystem(BG_DARK, {alpha: 1, timer: 0.3, ease: FlxEase.quartInOut});
						PlayState.defaultCamZoom = 1.2;
						PlayState.instance.camFollow.x -= 100;
						PlayState.boyfriend.alpha = 0.0001;
						FlxTween.tween(PlayState.boyfriend, {alpha: 1}, 6, {ease: returnTweenEase('sineInOut')});
						FlxTween.tween(PlayState.instance.camFollow, {x: PlayState.instance.camFollow.x + 100}, 12, {ease: FlxEase.sineInOut});
					case 176:
						PlayState.instance.camFlashSystem(BG_DARK, {alpha: 0, timer: 0.3, ease: FlxEase.quartInOut});
						PlayState.defaultCamZoom = 0.75;
						PlayState.camGame.flash(FlxColor.WHITE, 1);

						// today in super r slur shit we have this cus i hate my life
						FlxTween.tween(PlayState.instance.camFollow, {y: PlayState.instance.camFollow.y - 300}, .00000001, {onComplete: bensonFromRegularShow -> {
							FlxTween.tween(PlayState.instance.camFollow, {y: PlayState.instance.camFollow.y + 300}, 7, {ease: FlxEase.sineInOut});
						}});
					case 180 | 188 | 196:
						PlayState.camGame.zoom += 0.3;
						PlayState.instance.camFlashSystem(BG_FLASH, {alpha: 0.5, timer: 0.35});
					case 184 | 192 | 200:
						PlayState.camGame.zoom += 0.15;
						PlayState.instance.camFlashSystem(BG_FLASH, {alpha: 0.25, timer: 0.35});
					case 204: PlayState.defaultCamZoom = 1;
					case 208:
						PlayState.camBars.fade(0x00000, .000001);
						PlayState.defaultCamZoom = 1.3;

					// Mickey Screams Like A Bitch
					case 212:
						boundValue = 0.6;
						drainValue = 0.025;
						PlayState.instance.chromEffect = 0.3;
						PlayState.instance.chromTween = FlxTween.tween(PlayState.instance, {chromEffect: 1}, 1.2);
						PlayState.camBars.fade(0x00000, .000001, true);
						PlayState.defaultCamZoom = 0.75;
						PlayState.camGame.shake(0.01, 1.2);
					// The Drop Starts
					case 216:
						FlxTween.tween(PlayState.camHUD, {alpha: 1}, 1, {ease: FlxEase.quadOut});
						FlxTween.tween(PlayState.camNotes, {alpha: 1}, 1, {ease: FlxEase.quadOut});
						PlayState.instance.chromTween.cancel();
						PlayState.instance.chromTween = FlxTween.tween(PlayState.instance, {chromEffect: 0.18}, 0.6, {ease: FlxEase.sineOut});
						if (ClientPrefs.flashing)
							PlayState.camGame.flash(FlxColor.WHITE, 0.5);
						if (PlayState.instance.canaddshaders)
						{
                            if (!ClientPrefs.lowQuality)
                            {
                                PlayState.camGame.setFilters([
                                    new ShaderFilter(PlayState.dramaticCamMovement),
                                    new ShaderFilter(PlayState.bloomEffect),
                                    new ShaderFilter(PlayState.monitorFilter),
                                    new ShaderFilter(PlayState.chromZoomShader),
                                    new ShaderFilter(PlayState.chromNormalShader),
                                    new ShaderFilter(PlayState.delusionalShift)
                                ]);
                                PlayState.camHUD.setFilters([new ShaderFilter(PlayState.chromNormalShader), new ShaderFilter(PlayState.delusionalShift)]);
                                PlayState.camNotes.setFilters([
                                        new ShaderFilter(PlayState.grayScale),
                                        new ShaderFilter(PlayState.chromNormalShader),
                                        new ShaderFilter(PlayState.delusionalShift)
                                    ]);
                            }
                            else
                            {
                                PlayState.camGame.setFilters([
                                    new ShaderFilter(PlayState.monitorFilter),
                                    new ShaderFilter(PlayState.chromZoomShader),
                                    new ShaderFilter(PlayState.chromNormalShader),
                                    new ShaderFilter(PlayState.delusionalShift)
                                ]);
                                PlayState.camHUD.setFilters([new ShaderFilter(PlayState.chromNormalShader), new ShaderFilter(PlayState.delusionalShift)]);
                                PlayState.camNotes.setFilters([
                                        new ShaderFilter(PlayState.grayScale),
                                        new ShaderFilter(PlayState.chromNormalShader),
                                        new ShaderFilter(PlayState.delusionalShift)
                                    ]);
                            }
						}
					case 228:
						PlayState.instance.chromTween = null;
						PlayState.defaultCamZoom = 0.85;
					case 230: PlayState.defaultCamZoom = 1;
					case 232: PlayState.defaultCamZoom = 0.75;
					case 278: PlayState.defaultCamZoom = 1;
					case 280 | 312 | 344: PlayState.defaultCamZoom = 0.7;
					case 288 | 296 | 304 | 320 | 328 | 336: PlayState.defaultCamZoom += 0.1;
					case 308: PlayState.defaultCamZoom += 0.2;
					case 340: PlayState.defaultCamZoom += 0.3;
					case 356 | 388: PlayState.defaultCamZoom = 1.2;
					case 358 | 390: PlayState.defaultCamZoom = 1.3;
					case 360: PlayState.defaultCamZoom = 0.75;
					case 375:
						PlayState.instance.chromTween = FlxTween.tween(PlayState.instance, {chromEffect: 1}, 0.1, {ease: FlxEase.sineInOut});
						tweenCamera(1.5, 0.1, 'sineInOut');
					case 376:
						PlayState.instance.chromTween.cancel();
						PlayState.instance.chromTween = null;
						PlayState.camGame.visible = false;
						PlayState.camHUD.visible = false;
					case 377:
						PlayState.camGame.visible = true;
						PlayState.camHUD.visible = true;
						if (ClientPrefs.flashing)
							PlayState.camGame.flash(FlxColor.WHITE, 1);
						PlayState.defaultCamZoom = 0.8;
						PlayState.instance.chromTween = FlxTween.tween(PlayState.instance, {chromEffect: 0.1}, 0.6, {ease: FlxEase.quadOut});
					case 472:
						boundValue = 2;
						drainValue = 0;
						PlayState.camGame.visible = false;
						PlayState.camHUD.visible = false;
						PlayState.camNotes.visible = false;
					case 473:
						if (PlayState.instance.canaddshaders)
						{
                            if (!ClientPrefs.lowQuality)
                            {
                                PlayState.camGame.setFilters([
                                    new ShaderFilter(PlayState.dramaticCamMovement),
                                    new ShaderFilter(PlayState.bloomEffect),
                                    new ShaderFilter(PlayState.monitorFilter),
                                    new ShaderFilter(PlayState.chromZoomShader),
                                    new ShaderFilter(PlayState.chromNormalShader)
                                ]);
                               PlayState.camHUD.setFilters([new ShaderFilter(PlayState.chromNormalShader)]);
                                PlayState.camNotes.setFilters([new ShaderFilter(PlayState.grayScale), new ShaderFilter(PlayState.chromNormalShader)]);
                            }
                            else
                            {
                                PlayState.camGame.setFilters([
                                    new ShaderFilter(PlayState.monitorFilter),
                                    new ShaderFilter(PlayState.chromZoomShader),
                                    new ShaderFilter(PlayState.chromNormalShader)
                                ]);
                                PlayState.camHUD.setFilters([new ShaderFilter(PlayState.chromNormalShader)]);
                                PlayState.camNotes.setFilters([new ShaderFilter(PlayState.grayScale), new ShaderFilter(PlayState.chromNormalShader)]);
                            }
						}
						PlayState.instance.chromEffect = 0.00001;
						PlayState.defaultCamZoom = 0.85;
                        /*PlayState.bfStrums.receptors.members[0].x = 77;
                        PlayState.bfStrums.receptors.members[1].x = 187;
                        PlayState.bfStrums.receptors.members[2].x = 302;
                        PlayState.bfStrums.receptors.members[3].x = 417;
                        //too fucking lazy to do the math in my head again so here's me doing the math in the code cause i'm sooo fucking lazy afjhsdgyfvhu (don)
                        PlayState.dadStrums.receptors.members[0].x = 77 + 640;
                        PlayState.dadStrums.receptors.members[1].x = 187 + 640;
                        PlayState.dadStrums.receptors.members[2].x = 302 + 640;
                        PlayState.dadStrums.receptors.members[3].x = 417 + 640;*/
					case 480:
						// no healthbar to add more onto the atmosphere of this section
						PlayState.camGame.visible = true;
						PlayState.camNotes.visible = true;
					case 720:
						FlxTween.tween(PlayState.camGame, {alpha: 0.0001}, 5, {ease: FlxEase.quartInOut});
						FlxTween.tween(PlayState.camNotes, {alpha: 0.0001}, 5, {ease: FlxEase.quartInOut});
					case 740:
						boundValue = 0.45;
						drainValue = 0.032;
						/*PlayState.defaultCamZoom = 0.5;
                        PlayState.dadStrums.receptors.members[0].x = 77;
                        PlayState.dadStrums.receptors.members[1].x = 187;
                        PlayState.dadStrums.receptors.members[2].x = 302;
                        PlayState.dadStrums.receptors.members[3].x = 417;
                        //too fucking lazy to do the math in my head again so here's me doing the math in the code cause i'm sooo fucking lazy afjhsdgyfvhu (don)
                        PlayState.bfStrums.receptors.members[0].x = 77 + 640;
                        PlayState.bfStrums.receptors.members[1].x = 187 + 640;
                        PlayState.bfStrums.receptors.members[2].x = 302 + 640;
                        PlayState.bfStrums.receptors.members[3].x = 417 + 640;*/
					case 744:
						PlayState.camGame.alpha = 1;
						PlayState.camHUD.visible = true;
						PlayState.defaultCamZoom = 0.9;
						PlayState.camNotes.alpha = 1;
						PlayState.instance.chromEffect = 0.1;
						if (ClientPrefs.flashing)
							PlayState.camGame.flash(FlxColor.WHITE, 0.5);
						if (PlayState.instance.canaddshaders)
						{
                            if (!ClientPrefs.lowQuality)
                            {
                                PlayState.camGame.setFilters([
                                    new ShaderFilter(PlayState.dramaticCamMovement),
									new ShaderFilter(PlayState.heatWaveEffect),
                                    new ShaderFilter(PlayState.bloomEffect),
                                    new ShaderFilter(PlayState.monitorFilter),
                                    new ShaderFilter(PlayState.chromZoomShader),
                                    new ShaderFilter(PlayState.chromNormalShader),
                                    new ShaderFilter(PlayState.delusionalShift)
                                ]);
                                PlayState.camHUD.setFilters([new ShaderFilter(PlayState.chromNormalShader), new ShaderFilter(PlayState.delusionalShift)]);
                                PlayState.camNotes.setFilters([
                                        new ShaderFilter(PlayState.grayScale),
                                        new ShaderFilter(PlayState.chromNormalShader),
                                        new ShaderFilter(PlayState.delusionalShift)
                                    ]);
                            }
                            else
                            {
                                PlayState.camGame.setFilters([
                                    new ShaderFilter(PlayState.monitorFilter),
                                    new ShaderFilter(PlayState.chromZoomShader),
                                    new ShaderFilter(PlayState.chromNormalShader),
                                    new ShaderFilter(PlayState.delusionalShift)
                                ]);
                                PlayState.camHUD.setFilters([new ShaderFilter(PlayState.chromNormalShader), new ShaderFilter(PlayState.delusionalShift)]);
                                PlayState.camNotes.setFilters([
                                        new ShaderFilter(PlayState.grayScale),
                                        new ShaderFilter(PlayState.chromNormalShader),
                                        new ShaderFilter(PlayState.delusionalShift)
                                    ]);
                            }
						}
					case 880 | 884 | 888 | 892 | 896 | 900 | 904 | 908 | 913 | 916 | 920 | 924 | 929 | 933 | 936 | 940 | 944 | 948 | 952 | 956 | 960 | 964 | 968 | 972 | 976 | 980 | 984 | 988 | 993 | 997 | 1000 | 1004:
						PlayState.instance.camFlashSystem(CAM_FLASH_FANCY, {alpha: 0.135, timer: 0.85, colors: [255, 0, 0]});
					// The part where shit gets serious, Evilrette/Satan starts the solo
					case 1008:
						boundValue = 1.5;
						drainValue = 0.01;
						tweenCamera(1.35, 7, "quartInOut");
						PlayState.instance.camFlashSystem(CAM_FLASH_FANCY, {alpha: 0.4, timer: 2, colors: [255, 0, 0]});
						PlayState.instance.camFlashSystem(BG_DARK, {alpha: 0.8, timer: 6, ease: FlxEase.quartInOut});
						FlxTween.tween(PlayState.instance.camFollow, {x: PlayState.instance.camFollow.x + 150, y: PlayState.instance.camFollow.y + 50}, 4.3, {ease: FlxEase.quartInOut});
					// camera moves over to Mickey realizing he was never gonna win
					case 1024:
						FlxTween.tween(PlayState.instance.camFollow, {x: PlayState.instance.camFollow.x - 950, y: PlayState.instance.camFollow.y - 70}, 1.5, {ease: FlxEase.circInOut});
					case 1040:
						PlayState.instance.camFlashSystem(BG_DARK, {alpha: 0, timer: 1, ease: FlxEase.circOut});
						PlayState.defaultCamZoom = 0.85;
					case 1086:
						FlxTween.tween(PlayState.camHUD, {alpha: 0}, 2);
						FlxTween.tween(PlayState.camNotes, {alpha: 0}, 2);
						FlxG.sound.play(Paths.sound('funkinAVI/Mickey_fuckin_dying'));
						PlayState.instance.camFlashSystem(BG_DARK, {timer: 5});
					case 1134:
						PlayState.instance.camFlashSystem(BG_DARK, {alpha: 1, timer: 0.5, ease: FlxEase.sineOut});
					case 1136:
						PlayState.instance.camFlashSystem(BG_FLASH, {alpha: 1, timer: 0.3, ease: FlxEase.sineOut});
						if (PlayState.instance.canaddshaders)
							{
								if (!ClientPrefs.lowQuality)
								{
									PlayState.camGame.setFilters([
										new ShaderFilter(PlayState.dramaticCamMovement),
										new ShaderFilter(PlayState.bloomEffect),
										new ShaderFilter(PlayState.monitorFilter)
									]);
								}
								else
								{
									PlayState.camGame.setFilters([
										new ShaderFilter(PlayState.monitorFilter)
									]);
								}
							}
					case 1144:
						FlxTween.tween(PlayState.camGame, {alpha: 0}, 4);
				}

			if ((curBeat >= 216 && curBeat < 340) || (curBeat >= 344 && curBeat < 356) || (curBeat >= 360 && curBeat < 388) || 
				(curBeat >= 392 && curBeat < 408) || (curBeat >= 880 && curBeat < 1072))
			{
				FlxG.camera.zoom += .015;
				for (mridk in [PlayState.camHUD, PlayState.camNotes]) mridk.zoom += .03;
			}

			case 'Delusion':
				switch (curBeat)
				{
					case 1:
						FlxTween.tween(PlayState.camGame, {alpha: 1}, 2);
					case 8:
						PlayState.defaultCamZoom -= 0.08;
						PlayState.instance.camFlashSystem(BG_FLASH, {timer: 0.35});
						FlxTween.tween(PlayState.camHUD, {alpha: 1}, 0.4);
						FlxTween.tween(PlayState.camNotes, {alpha: 1}, 0.3);
					case 16: PlayState.defaultCamZoom += 0.1;
					case 24:
						PlayState.camGame.zoom += 0.12;
						PlayState.defaultCamZoom -= 0.2;
						PlayState.instance.camFlashSystem(BG_FLASH, {alpha: 0.35, timer: 0.45, ease: FlxEase.circOut, colors: [255, 135, 135]});
					case 25 | 26 | 27 | 28 | 29 | 30 | 31 | 32 | 33 | 34 | 35 | 41 | 42 | 43 | 44 | 45 | 46 | 47 | 48 | 49 | 50 | 51 | 52 | 53 | 54 | 55 | 56 | 57 | 58 | 59 | 60 | 61 | 62 | 63 | 64 | 65 | 66 | 67 | 68 | 69 | 70 | 71 | 137 | 138 | 139 | 140 | 141 | 142 | 143 | 144 | 145 | 146 | 147 | 148 | 149 | 150 | 151 | 152 | 153 | 154 | 155 | 156 | 157 | 158 | 159 | 160 | 161 | 162 | 163 | 164 | 165 | 166 | 167 | 168 | 169 | 170 | 171 | 172 | 173 | 174 | 175 | 176 | 177 | 178 | 179 | 180 | 181 | 182 | 183 | 184 | 185 | 186 | 187 | 188 | 189 | 190 | 191 | 192:
						PlayState.instance.camFlashSystem(BG_FLASH, {alpha: 0.35, timer: 0.45, ease: FlxEase.circOut, colors: [255, 135, 135]});
						PlayState.camGame.zoom += 0.1;
					case 72 | 73 | 74 | 75 | 76 | 77 | 78 | 79 | 80 | 81 | 82 | 83 | 84 | 85 | 86 | 87:
						PlayState.instance.camFlashSystem(BG_FLASH, {alpha: 0.56, timer: 0.45, ease: FlxEase.circOut, colors: [255, 135, 135]});
						PlayState.camGame.zoom += 0.16;
					case 88 | 89 | 90 | 91 | 92 | 93 | 94 | 95 | 96 | 97 | 98 | 99 | 100 | 101:
						PlayState.instance.camFlashSystem(BG_FLASH, {alpha: 0.89, timer: 0.45, ease: FlxEase.circOut, colors: [255, 135, 135]});
						PlayState.camGame.zoom += 0.21;
					case 36 | 134:
						PlayState.instance.camFlashSystem(BG_DARK, {alpha: 0.8, timer: 0.21, ease: FlxEase.sineOut});
						PlayState.defaultCamZoom += 0.3;
					case 40:
						PlayState.defaultCamZoom -= 0.25;
						PlayState.instance.camFlashSystem(BG_FLASH, {alpha: 0.6, timer: 0.3, ease: FlxEase.circOut, colors: [255, 135, 135]});
						PlayState.camGame.zoom += 0.16;
					case 104 | 112 | 120 | 128:
						PlayState.camGame.zoom += 0.25;
						PlayState.instance.camFlashSystem(BG_FLASH, {alpha: 0.6, timer: 0.3, ease: FlxEase.circOut, colors: [255, 135, 135]});
					case 136:
						PlayState.instance.camFlashSystem(BG_FLASH, {alpha: 0.35, timer: 0.45, ease: FlxEase.circOut, colors: [255, 135, 135]});
						PlayState.camGame.zoom += 0.1;
						PlayState.defaultCamZoom += 0.11;
					case 108 | 116:
						PlayState.instance.camFlashSystem(BG_DARK, {alpha: 0.2, timer: 0.35, ease: FlxEase.sineOut});
					case 110 | 118:
						PlayState.instance.camFlashSystem(BG_DARK, {alpha: 0.5, timer: 0.35, ease: FlxEase.sineOut});
				}

				if (curBeat >= 72 && curBeat <= 87)
				{
					PlayState.instance.effectRed = 1;

					if (PlayState.instance.vignetteTween != null)
						PlayState.instance.vignetteTween.cancel();

					PlayState.instance.vignetteTween = FlxTween.tween(PlayState.instance, {effectRed: 0.0}, 0.4, {ease: FlxEase.sineOut, onComplete: 
						function(twn:FlxTween)
							{
								PlayState.instance.vignetteTween = null;
							}
						}
					);
				}

				if (curBeat >= 88 && curBeat <= 103)
					{
						PlayState.instance.effectRed = 1.2;
						
						if (PlayState.instance.vignetteTween != null)
							PlayState.instance.vignetteTween.cancel();
	
						PlayState.instance.vignetteTween = FlxTween.tween(PlayState.instance, {effectRed: 0.0}, 0.4, {ease: FlxEase.sineOut, onComplete: 
							function(twn:FlxTween)
								{
									PlayState.instance.vignetteTween = null;
								}
							}
						);
					}

			case 'Scrapped':
				switch (curBeat)
				{
					case 64: FlxTween.tween(PlayState.dad, {alpha: 1}, 10);
					case 424: FlxTween.tween(PlayState.dad, {alpha: 0}, 5);
				}

			case 'Laugh Track':
				switch (curBeat)
				{
					case 7:
						PlayState.cameraSpeed = 50;
						PlayState.instance.camFollow.x += 100;
					case 8:
						PlayState.camBars.fade(FlxColor.BLACK, 5, true);
						FlxTween.tween(PlayState.instance.camFollow, {x: 0}, 3, {ease: FlxEase.circOut});
					case 32:
						PlayState.defaultCamZoom = 1.5;
						new FlxTimer().start(0.001, function(tmr) // what a load of crap lol
							{
								PlayState.instance.camFollow.x -= 100;
							});
					case 33: 
						FlxTween.tween(PlayState.instance.camFollow, {x: 0}, 3, {ease: FlxEase.circInOut});
					case 56:
						tweenCamera(1, 1.5, 'circInOut');
						FlxTween.tween(PlayState.camHUD, {alpha: 1}, 1.5, {ease: FlxEase.circInOut});
						FlxTween.tween(PlayState.camNotes, {alpha: 1}, 1.5, {ease: FlxEase.circInOut});
					case 64 | 67 | 72 | 75 | 80 | 83 | 88 | 91: 
						//PlayState.instance.camFlashSystem(CAM_FLASH_FANCY, {alpha: 0.25, ease: FlxEase.sineOut, timer: 0.6});
						FlxG.camera.zoom += 0.21;
					case 96:
						PlayState.instance.camFlashSystem(CAM_FLASH_FANCY, {alpha: 0.6, ease: FlxEase.sineOut, timer: 1});
						PlayState.cameraSpeed = 2.3;
						PlayState.defaultCamZoom = .78;
				}

				if (curBeat >= 96 && curBeat <= 192)
				{
					FlxG.camera.zoom += 0.18;
					PlayState.instance.camFlashSystem(BG_FLASH, {alpha: 0.15, ease: FlxEase.sineOut, timer: 0.35, colors: [255, 0, 0]});
				}

			case 'Birthday':
				switch (curBeat)
				{
					case 2: PlayState.camBars.fade(FlxColor.BLACK, 3, true);
					case 32: PlayState.defaultCamZoom = 1.18;
					case 60:
						PlayState.cameraSpeed = 0.5;
						PlayState.defaultCamZoom = 0.85;
						FlxTween.tween(PlayState.camHUD, {alpha: 1}, 3);
						FlxTween.tween(PlayState.camNotes, {alpha: 1}, 3);
					case 64:
						PlayState.camGame.flash(FlxColor.WHITE, 1);
						PlayState.cameraSpeed = 1;
					case 192:
						PlayState.instance.camFlashSystem(BG_FLASH, {alpha: 0.7, timer: 1, colors: [66, 224, 245]});
						FlxG.camera.zoom += 0.09;
						PlayState.camHUD.zoom += 0.08;
						PlayState.camNotes.zoom += 0.08;
						PlayState.defaultCamZoom = 1;
						PlayState.cameraSpeed = 0.7;
					case 204 | 205 | 221 | 222 | 223 | 236 | 237 | 253 | 254 | 255: PlayState.defaultCamZoom += 0.1;
					case 206 | 238: PlayState.defaultCamZoom = 1;
					case 224:
						PlayState.defaultCamZoom = 1;
						PlayState.instance.camFlashSystem(BG_FLASH, {alpha: 0.7, timer: 1, colors: [119, 247, 96]});
						FlxG.camera.zoom += 0.09;
						PlayState.camHUD.zoom += 0.08;
						PlayState.camNotes.zoom += 0.08;
					case 256: PlayState.defaultCamZoom = 0.85;
					case 320: tweenCamera(1, 1.5, 'sineInOut');
					case 336:
						tweenCamera(1.3, 2.8, 'quartInOut');
						PlayState.instance.offsetTwn = FlxTween.tween(PlayState.instance.camFollow, {x: PlayState.instance.camFollow.x - 150}, 3, {ease: FlxEase.sineInOut, onComplete: function(twn:FlxTween)
						{
							PlayState.instance.offsetTwn = null;
						}});
					case 348:
						if (PlayState.instance.offsetTwn != null)
							PlayState.instance.offsetTwn.cancel();
						tweenCamera(1, 1.2, 'quartInOut');
						PlayState.instance.offsetTwn = FlxTween.tween(PlayState.instance.camFollow, {x: PlayState.instance.camFollow.x + 100}, 1.2, {ease: FlxEase.sineInOut, onComplete: function(twn:FlxTween)
							{
								PlayState.instance.offsetTwn = null;
							}});
					case 351: FlxTween.tween(PlayState.dad, {'scale.x': 0}, 0.3, {ease: FlxEase.quartInOut, onComplete: function(twn:FlxTween)
						{
							FlxTween.tween(PlayState.dad, {'scale.x': 1}, 0.3, {ease: FlxEase.quartOut});
						}});
					case 416: FlxTween.tween(PlayState.boyfriend, {'scale.y': 0}, 0.5, {ease: FlxEase.quartInOut, onComplete: function(twn:FlxTween)
						{
							FlxTween.tween(PlayState.boyfriend, {'scale.y': 1}, 0.5, {ease: FlxEase.quartOut});
						}});
					case 476: tweenCamera(0.85, 2, 'quartInOut');
					case 477: FlxTween.tween(PlayState.dad, {'scale.x': 0}, 0.3, {ease: FlxEase.quartInOut, onComplete: function(twn:FlxTween)
						{
							FlxTween.tween(PlayState.dad, {'scale.x': 0.6}, 0.3, {ease: FlxEase.quartOut});
						}});
					case 481: FlxTween.tween(PlayState.boyfriend, {'scale.y': 0}, 0.7, {ease: FlxEase.quartInOut, onComplete: function(twn:FlxTween)
						{
							FlxTween.tween(PlayState.boyfriend, {'scale.y': 0.6}, 0.7, {ease: FlxEase.quartOut});
						}});
					case 536 | 540 | 544: PlayState.defaultCamZoom += 0.18;
					case 548: tweenCamera(0.8, 2, 'sineOut');
					case 552:
						PlayState.camGame.visible = false;
						PlayState.camHUD.visible = false;
						PlayState.camNotes.visible = false;
						PlayState.camOther.flash(FlxColor.WHITE, 3);
				}
				if (curBeat >= 64 && curBeat <= 191 || curBeat >= 256 && curBeat <= 319)
				{
					FlxG.camera.zoom += 0.07;
					PlayState.camHUD.zoom += 0.06;
					PlayState.camNotes.zoom += 0.06;
				}

			case 'Mercy Legacy':
				if (ClientPrefs.mechanics)
				{
					if (curBeat >= 0 && curBeat <= 63)
						PlayState.health -= 0.02;
					else if (curBeat >= 64 && curBeat <= 95)
						PlayState.health -= 0.2;
					else if (curBeat >= 96 && curBeat <= 127)
						PlayState.health -= 0.06;
					else if (curBeat >= 128 && curBeat <= 191)
						PlayState.health -= 0.16;
					else if (curBeat >= 192 && curBeat <= 255)
						PlayState.health -= 0.1;
					else if (curBeat >= 256 && curBeat <= 319)
						PlayState.health -= 0.18;
					else if (curBeat >= 320)
						PlayState.health -= 0.01;
				}

			case 'Mercy':
				// Cam Stuff Handler
				switch (curBeat)
				{
					case 16:
						FlxTween.tween(PlayState.camGame, {alpha: 1}, 5, {ease: FlxEase.sineInOut});
						FlxTween.tween(PlayState.camHUD, {alpha: 1}, 5, {ease: FlxEase.sineInOut, startDelay: 1.5});
						PlayState.defaultCamZoom = 1.3;

					case 32: PlayState.defaultCamZoom = 1.2;
					case 40: PlayState.defaultCamZoom = 1.1;
					case 48: PlayState.defaultCamZoom = 1;
					case 56: PlayState.defaultCamZoom = 0.9;
					case 64: PlayState.defaultCamZoom = 0.75;

					case 128: tweenCamera(1.1, 9.7, 'quadInOut');

					// Very Spooky Phase 2 Walt (real)
					case 256:
						FlxTween.tween(PlayState.camGame, {alpha: 0}, 1, {ease: FlxEase.sineInOut});
						FlxTween.tween(PlayState.camHUD, {alpha: 0}, 1, {ease: FlxEase.sineInOut});
						FlxTween.tween(PlayState.camNotes, {alpha: 0}, 1, {ease: FlxEase.sineInOut});

					case 264:
						FlxTween.tween(PlayState.camGame, {alpha: 1}, 2, {ease: FlxEase.sineInOut});
						PlayState.defaultCamZoom = 1.3;

					case 275:
						PlayState.defaultCamZoom = 0.8;
						FlxTween.tween(PlayState.camHUD, {alpha: 1}, 0.31, {ease: FlxEase.sineInOut});
						FlxTween.tween(PlayState.camNotes, {alpha: 1}, 0.31, {ease: FlxEase.sineInOut});
						if (ClientPrefs.mechanics) PlayState.instance.inkFormWarning.alpha = 1;

					case 276:
						if (ClientPrefs.mechanics) FlxTween.tween(PlayState.instance.inkFormWarning, {alpha: 0}, 2, {ease: FlxEase.sineInOut});

					case 468:
						//FlxTween.tween(PlayState.bfStrums, {alpha: 0}, 4, {ease: FlxEase.sineInOut});
						FlxTween.tween(PlayState.camHUD, {alpha: 0}, 4, {ease: FlxEase.sineInOut});
						FlxTween.tween(PlayState.camNotes, {alpha: 0}, 1, {ease: FlxEase.sineInOut, startDelay: 3});
						if (ClientPrefs.mechanics) FlxTween.tween(PlayState.instance.spaceBarCounter, {alpha: 0}, 2, {ease: FlxEase.sineInOut});

					// Final Stretch
					case 498:
						PlayState.camGame.alpha = 0;
						PlayState.camOther.flash(FlxColor.WHITE, 3);
				}

				if (ClientPrefs.mechanics)
				{
					// Health Drain Shit
					if (curBeat >= 0 && curBeat <= 63)
						PlayState.health -= 0.005;
					else if (curBeat >= 64 && curBeat <= 79)
						PlayState.health -= 0.01;
					else if (curBeat >= 80 && curBeat <= 87)
						PlayState.health -= 0.07;
					else if (curBeat >= 88 && curBeat <= 95)
						PlayState.health -= 0.01;
					else if (curBeat >= 96 && curBeat <= 127)
						PlayState.health -= 0.03;
					else if (curBeat >= 128 && curBeat <= 159)
						PlayState.health -= 0.1;
					else if (curBeat >= 160 && curBeat <= 191)
						PlayState.health -= 0.06;
					else if (curBeat >= 192 && curBeat <= 207)
						PlayState.health -= 0.01;
					else if (curBeat >= 208 && curBeat <= 239)
						PlayState.health -= 0.04;
					else if (curBeat >= 240 && curBeat <= 255)
						PlayState.health -= 0.005;
					else if (curBeat >= 256 && curBeat <= 291)
						PlayState.health -= 0.03;
					else if (curBeat >= 292 && curBeat <= 307)
						PlayState.health -= 0.05;
					else if (curBeat >= 308 && curBeat <= 339)
						PlayState.health -= 0.085;
					else if (curBeat >= 340 && curBeat <= 371)
						PlayState.health -= 0.1;
					else if (curBeat >= 372 && curBeat <= 387)
						PlayState.health -= 0.11;
					else if (curBeat >= 388 && curBeat <= 403)
						PlayState.health -= 0.12;
					else if (curBeat >= 404 && curBeat <= 451)
						PlayState.health -= 0.14;
					else if (curBeat >= 452 && curBeat <= 467)
						PlayState.health -= 0.17;
									}

			case 'Cycled Sins':
				if (ClientPrefs.mechanics)
				{
					switch (curBeat)
					{
						// Intro Cam Shit
						case 16: PlayState.camBars.fade(0x000000, 0.0001, true);
						case 32: tweenCamera(0.85, 5.5, 'quartInOut');
						case 46:
							tweenCamera(0.6, 0.6, 'sineInOut');
							FlxTween.tween(PlayState.camNotes, {alpha: 1}, 0.8, {ease: FlxEase.circInOut});
							FlxTween.tween(PlayState.camHUD, {alpha: 1}, 0.8, {ease: FlxEase.circInOut});

						// Phase 1 Section
						case 174:
							PlayState.instance.relapseGimmick(0.7, 0.3);
						case 180 | 182 | 196 | 198 | 212 | 254 | 286 | 303:
							PlayState.instance.relapseGimmick(0.35, 0.15);
						case 188 | 204:
							PlayState.instance.relapseGimmick(1.4, 0.6);
						case 206:
							PlayState.instance.relapseGimmick(0.7, 0.54);
						case 214:
							PlayState.instance.relapseGimmick(0.7, 0.8);
						case 222 | 228 | 244:
							PlayState.instance.relapseGimmick(0.7, 1);
						case 236:
							PlayState.instance.relapseGimmick(0.7, 0.4);
						case 248 | 262 | 276:
							PlayState.instance.relapseGimmick(1.4, 1.2);
						case 270 | 294:
							PlayState.instance.relapseGimmick(0.7, 1.5);

						// Cam Shit and Lyrics for intro to Phase 2
						case 366:
							FlxTween.tween(PlayState.camNotes, {alpha: 0}, 1);
							FlxTween.tween(PlayState.camHUD, {alpha: 0}, 1);

						case 381: PlayState.instance.manageLyrics('relapse-gun-pixel', 'You REALLY think this is...', 'calibri-regular', 30, 1.1, 'sineInOut');
						case 384: PlayState.instance.manageLyrics('relapse-gun-pixel', '...some kind of...', 'calibri-regular', 30, 1.4, 'sineInOut');
						case 388: PlayState.instance.manageLyrics('relapse-gun-pixel', '...silly little GAME?', 'calibri-regular', 30, 1.15, 'sineInOut');
						case 394: PlayState.instance.manageLyrics('relapse-gun-pixel', 'Soon enough...', 'calibri-regular', 30, 1.3, 'sineInOut');
						case 398: PlayState.instance.manageLyrics('relapse-gun-pixel', "...you'll understand what ME...", 'calibri-regular', 30, 1.5, 'sineInOut');
						case 404: PlayState.instance.manageLyrics('relapse-gun-pixel', '...AND MY FRIENDS...', 'calibri-regular', 30, 1.6, 'sineInOut');
						case 408: PlayState.instance.manageLyrics('relapse-gun-pixel', '...HAVE TO GO THROUGH!', 'calibri-regular', 30, 1.1, 'sineInOut');
						case 413: PlayState.instance.manageLyrics('relapse-gun-pixel', 'Sooner or later...', 'calibri-regular', 30, 1.1, 'sineInOut');
						case 417: PlayState.instance.manageLyrics('relapse-gun-pixel', '...your DEATH will be nothing...', 'calibri-regular', 30, 1.1, 'sineInOut');
						case 420: PlayState.instance.manageLyrics('relapse-gun-pixel', '...BUT CYCLED SINS!', 'calibri-regular', 30, 1.1, 'sineInOut');

						case 432:
							FlxTween.tween(PlayState.camNotes, {alpha: 1}, 0.5, {ease: FlxEase.sineOut});
							FlxTween.tween(PlayState.camHUD, {alpha: 1}, 0.5, {ease: FlxEase.sineOut});

						// Phase 2 Section
						case 434:
							PlayState.instance.relapseGimmick(0.35, 0.5);
						case 438:
							PlayState.instance.relapseGimmick(0.35, 1, true);
						case 446:
							PlayState.instance.relapseGimmick(0.7, 0.35);
						case 453:
							PlayState.instance.relapseGimmick(0.7, 1, true);
						case 460:
							PlayState.instance.relapseGimmick(0.7, 0.9);
						case 467:
							PlayState.instance.relapseGimmick(0.35, 1.8, true);
						case 471:
							PlayState.instance.relapseGimmick(0.35, 1.1);
						case 474:
							PlayState.instance.relapseGimmick(0.35, 1.5);
						case 476:
							PlayState.instance.relapseGimmick(0.7, 1, true);
						case 484:
							PlayState.instance.relapseGimmick(0.35, 1.3);
						case 486:
							PlayState.instance.relapseGimmick(0.35, 2);
						case 494:
							PlayState.instance.relapseGimmick(0.35, 1.3, true);
					}
				}
				else
				{
					switch (curBeat)
					{
						// Intro Cam Shit
						case 16: PlayState.camGame.alpha = 1;
						case 32: tweenCamera(0.85, 5.5, 'quartInOut');
						case 46:
							tweenCamera(0.6, 0.6, 'sineInOut');
							FlxTween.tween(PlayState.camNotes, {alpha: 1}, 0.8, {ease: FlxEase.circInOut});
							FlxTween.tween(PlayState.camHUD, {alpha: 1}, 0.8, {ease: FlxEase.circInOut});
						case 366:
							FlxTween.tween(PlayState.camNotes, {alpha: 0}, 1);
							FlxTween.tween(PlayState.camHUD, {alpha: 0}, 1);

						case 381: PlayState.instance.manageLyrics('relapse-gun-pixel', 'You REALLY think this is...', 'calibri-regular', 30, 1.1, 'sineInOut');
						case 384: PlayState.instance.manageLyrics('relapse-gun-pixel', '...some kind of...', 'calibri-regular', 30, 1.4, 'sineInOut');
						case 388: PlayState.instance.manageLyrics('relapse-gun-pixel', '...silly little GAME?', 'calibri-regular', 30, 1.15, 'sineInOut');
						case 394: PlayState.instance.manageLyrics('relapse-gun-pixel', 'Soon enough...', 'calibri-regular', 30, 1.3, 'sineInOut');
						case 398: PlayState.instance.manageLyrics('relapse-gun-pixel', "...you'll understand what ME...", 'calibri-regular', 30, 1.5, 'sineInOut');
						case 404: PlayState.instance.manageLyrics('relapse-gun-pixel', '...AND MY FRIENDS...', 'calibri-regular', 30, 1.6, 'sineInOut');
						case 408: PlayState.instance.manageLyrics('relapse-gun-pixel', '...HAVE TO GO THROUGH!', 'calibri-regular', 30, 1.1, 'sineInOut');
						case 413: PlayState.instance.manageLyrics('relapse-gun-pixel', 'Sooner or later...', 'calibri-regular', 30, 1.1, 'sineInOut');
						case 417: PlayState.instance.manageLyrics('relapse-gun-pixel', '...your DEATH will be nothing...', 'calibri-regular', 30, 1.1, 'sineInOut');
						case 420: PlayState.instance.manageLyrics('relapse-gun-pixel', '...BUT CYCLED SINS!', 'calibri-regular', 30, 1.1, 'sineInOut');

						case 432:
							FlxTween.tween(PlayState.camNotes, {alpha: 1}, 0.5, {ease: FlxEase.sineOut});
							FlxTween.tween(PlayState.camHUD, {alpha: 1}, 0.5, {ease: FlxEase.sineOut});
					}
				}

				if (curBeat == 400 || curBeat == 404 || curBeat == 408 || curBeat == 412 || curBeat == 416 || curBeat == 420 || curBeat == 424
					|| curBeat == 428)
				{
					PlayState.instance.camFlashSystem(BG_FLASH, {alpha: 0.32, timer: 1.2, colors: [255, 0, 0]});
					FlxG.camera.zoom += 0.1;
				}

			case 'Malfunction':
				switch (curBeat)
				{
					// Intro Cam Stuff
					case 1: FlxTween.tween(PlayState.camGame, {alpha: 1}, 5, {ease: FlxEase.sineInOut});
					case 16: tweenCamera(1.2, 5, 'quartInOut');
					case 32:
						PlayState.defaultCamZoom = 0.8;
						FlxTween.tween(PlayState.camHUD, {alpha: 1}, 0.5, {ease: FlxEase.sineOut});
						FlxTween.tween(PlayState.camNotes, {alpha: 1}, 0.5, {ease: FlxEase.sineOut});
					case 39 | 48 | 64 | 72 | 88 | 96 | 103 | 113 | 128 | 184 | 192: PlayState.defaultCamZoom = 0.8;
					case 38 | 102: tweenCamera(1.5, 0.25, 'sineInOut');
					case 45 | 61 | 110 | 126 | 187: PlayState.defaultCamZoom = 0.9;
					case 46 | 62 | 67 | 76 | 83 | 92 | 111 | 127 | 158 | 190: PlayState.defaultCamZoom = 1;
					case 47 | 63 | 68 | 84 | 112 | 159: PlayState.defaultCamZoom = 1.3;
					case 69 | 85: PlayState.defaultCamZoom = 1.1;
					case 160: PlayState.defaultCamZoom = 0.65;
					case 164: tweenCamera(1.5, 6, 'sineInOut');
					case 191:
						if (PlayState.instance.canaddshaders)
						{
							if (!ClientPrefs.lowQuality && ClientPrefs.epilepsy)
							{
								PlayState.camGame.setFilters([new ShaderFilter(PlayState.chromZoomShader), new ShaderFilter(PlayState.blurShader)]);
								PlayState.camHUD.setFilters([new ShaderFilter(PlayState.chromNormalShader), new ShaderFilter(PlayState.blurShader)]);
								PlayState.camNotes.setFilters([new ShaderFilter(PlayState.chromNormalShader), new ShaderFilter(PlayState.blurShader)]);
							}
						}
                    case 320:
                        FlxTween.tween(PlayState.camHUD, {alpha: 0}, 0.5);
                        FlxTween.tween(PlayState.camNotes, {alpha: 0}, 0.5);
					case 324:
						// FUCK YOU, WE'RE USING THE SUPER COOL MODCHART EDITOR NOW WOOOOOO!!!
                        /*moveThatFuckingStrum(false, 0.5, 90, 0, 1060, 120, 0);
                        moveThatFuckingStrum(false, 0.5, 90, 0, 1060, 240, 1);
                        moveThatFuckingStrum(false, 0.5, 90, 0, 1060, 360, 2);
                        moveThatFuckingStrum(false, 0.5, 90, 0, 1060, 480, 3);
                        moveThatFuckingStrum(true, 0.5, 270, 0, 50, 120, 0);
                        moveThatFuckingStrum(true, 0.5, 270, 0, 50, 240, 1);
                        moveThatFuckingStrum(true, 0.5, 270, 0, 50, 360, 2);
                        moveThatFuckingStrum(true, 0.5, 270, 0, 50, 480, 3);*/
						var count:FlxSprite = new FlxSprite().loadGraphic(Paths.image('funkinAVI/intro/mal-prepare'));
						count.scrollFactor.set();
						count.updateHitbox();
						count.setGraphicSize(Std.int(count.width * PlayState.daPixelZoom));
						count.antialiasing = false;
						count.screenCenter();
						PlayState.instance.add(count);
						FlxTween.tween(count, {y: count.y += 50, alpha: 0}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								count.destroy();
							}
						});
						FlxG.sound.play(Paths.sound('funkinAVI/countdownSounds/intro3CORRUPT-pixel'), 2);
					case 325:
						var count:FlxSprite = new FlxSprite().loadGraphic(Paths.image('UI/funkinAVI/intro/mal-ready'));
						count.scrollFactor.set();
						count.updateHitbox();
						count.setGraphicSize(Std.int(count.width * PlayState.daPixelZoom));
						count.screenCenter();
						count.antialiasing = false;
						PlayState.instance.add(count);
						FlxTween.tween(count, {y: count.y += 50, alpha: 0}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								count.destroy();
							}
						});
						FlxG.sound.play(Paths.sound('funkinAVI/countdownSounds/intro2CORRUPT-pixel'), 2);
					case 326:
						var count:FlxSprite = new FlxSprite().loadGraphic(Paths.image('UI/funkinAVI/intro/mal-set'));
						count.scrollFactor.set();
						count.updateHitbox();
						count.setGraphicSize(Std.int(count.width * PlayState.daPixelZoom));
						count.screenCenter();
						count.antialiasing = false;
						PlayState.instance.add(count);
						FlxTween.tween(count, {y: count.y += 50, alpha: 0}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								count.destroy();
							}
						});
						FlxG.sound.play(Paths.sound('funkinAVI/countdownSounds/intro1CORRUPT-pixel'), 2);
					case 327:
						var count:FlxSprite = new FlxSprite().loadGraphic(Paths.image('UI/funkinAVI/intro/mal-go'));
						count.scrollFactor.set();
						count.updateHitbox();
						count.setGraphicSize(Std.int(count.width * PlayState.daPixelZoom));
						count.screenCenter();
						count.antialiasing = false;
						PlayState.instance.add(count);
						FlxTween.tween(count, {y: count.y += 50, alpha: 0}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								count.destroy();
							}
						});
						FlxG.sound.play(Paths.sound('funkinAVI/countdownSounds/introGoCORRUPT-pixel'), 2);
                    case 328:
                        FlxTween.tween(PlayState.camHUD, {alpha: 1}, 0.5);
                        FlxTween.tween(PlayState.camNotes, {alpha: 1}, 0.5);

						// Ight Jason, the fun part's all yours
						// The fun begins 0_0
				}

			case 'Neglection':
				switch (curBeat)
				{
					case 256:
						FlxTween.tween(PlayState.camHUD, {alpha: 0}, 0.5);
                    	FlxTween.tween(PlayState.camNotes, {alpha: 0}, 0.5);
					case 257:
						FlxTween.tween(PlayState.boyfriend, {alpha: 0.0001}, 0.5);
						PlayState.camBars.fade(FlxColor.BLACK, 0.3);
					case 260:
						PlayState.camBars.fade(FlxColor.BLACK, 1, true);
					case 264:
						FlxTween.tween(PlayState.camHUD, {alpha: 1}, 0.5);
                        FlxTween.tween(PlayState.camNotes, {alpha: 1}, 0.5);
					case 328: PlayState.camGame.visible = false;
					case 332: 
						PlayState.camGame.visible = true;
						PlayState.boyfriend.alpha = 1;
				}

			case 'Hunted':
				if (curBeat == 176) {
					tweenCamera(1.1, 4.1, 'sineInOut');
					//PlayState.dadStrums.forEach(strum -> FlxTween.tween(strum, {y: strum.y + 700}, 2.5, {ease: FlxEase.elasticIn}));
					//FlxTween.tween(PlayState.camNotes[0], {alpha: 0.0001}, 2.5);
					//if (!Init.trueSettings.get('Centered Notefield')) PlayState.bfStrums.forEach(strum -> FlxTween.tween(strum, {x: strum.x - 320}, 2.5, {ease: FlxEase.elasticInOut}));
				}
				if (curBeat == 184)
					PlayState.defaultCamZoom = 1.4;
				if (curBeat == 190)
					PlayState.defaultCamZoom = 0.65;
				if (curBeat == 192)
				{
					PlayState.instance.camHudMoves = true;
					if (ClientPrefs.flashing)
						PlayState.camGame.flash(FlxColor.WHITE, 1.5);
					if (!ClientPrefs.lowQuality)
					{
						PlayState.camGame.setFilters([
							new ShaderFilter(PlayState.redVignette),
							new ShaderFilter(PlayState.dramaticCamMovement),
							new ShaderFilter(PlayState.monitorFilter),
							new ShaderFilter(PlayState.bloomEffect)
						]);
					}
					else
					{
						PlayState.camGame.setFilters([new ShaderFilter(PlayState.redVignette), new ShaderFilter(PlayState.monitorFilter)]);
					}
				}
				if (curBeat == 256)
				{
					PlayState.instance.camHudMoves = false;
					PlayState.camGame.flash(FlxColor.BLACK, 2);
					if (!ClientPrefs.lowQuality)
					{
						PlayState.camGame.setFilters([
							new ShaderFilter(PlayState.dramaticCamMovement),
							new ShaderFilter(PlayState.monitorFilter),
							new ShaderFilter(PlayState.bloomEffect)
						]);
					}
					else
					{
						PlayState.camGame.setFilters([new ShaderFilter(PlayState.monitorFilter)]);
					}

					//PlayState.dadStrums.forEach(strum -> FlxTween.tween(strum, {y: strum.y - 700}, 2.5, {ease: FlxEase.elasticOut}));
					//FlxTween.tween(PlayState.camNotes[0], {alpha: 1}, 2.5);
					//if (!Init.trueSettings.get('Centered Notefield')) PlayState.bfStrums.forEach(strum -> FlxTween.tween(strum, {x: strum.x + 320}, 2.5, {ease: FlxEase.elasticInOut}));

					PlayState.instance.uhhTurnBackNormalOrSmth();
				}

				if (((curBeat >= 64 && curBeat < 128) && curBeat % 2 == 0) || (curBeat >= 128 && curBeat < 256))
				{
					FlxG.camera.zoom += ((curBeat > 176 && curBeat < 184) ? 0 : .05);
					PlayState.camHUD.zoom += .04;
					PlayState.camNotes.zoom += .04;
				}
		}
    }

	/**
	* Ditto as `beatHitEvents`, but with `curStep` use instead of `curBeat`
	*/
	public function stepHitEvents(curStep:Int)
	{
		switch (PlayState.SONG.song)
		{
			case 'Isolated': 
				switch (curStep)
				{
					case 1150: 
						PlayState.defaultCamZoom = PlayState.camGame.zoom = 1.2;
						cinematicBarControls('moveboth', 0.0001, 'linear', 155);
				}

			case 'Laugh Track':
				switch (curStep)
				{
					case 262 | 294 | 326 | 358: 
						//PlayState.instance.camFlashSystem(CAM_FLASH_FANCY, {alpha: 0.35, ease: FlxEase.sineOut, timer: 0.6});
						FlxG.camera.zoom += 0.015;
				}
		}
	}

    public function shaderAnims(elapsed:Float)
    {
        PlayState.instance.shaderAnim = Conductor.songPosition / 1000;
            switch (PlayState.SONG.song)
			{
				case 'Devilish Deal':
					PlayState.chromZoomShader.setFloat('aberration', PlayState.instance.chromEffect);
					PlayState.chromZoomShader.setFloat('effectTime', PlayState.instance.chromEffect);
					PlayState.chromNormalShader.setFloat('rOffset', PlayState.instance.chromEffect / 70);
					PlayState.chromNormalShader.setFloat('bOffset', -PlayState.instance.chromEffect / 70);
					PlayState.dramaticCamMovement.setFloat('time', PlayState.instance.shaderAnim);

				case 'Isolated' | 'Lunacy' | 'Delusional':
					PlayState.chromZoomShader.setFloat('aberration', PlayState.instance.chromEffect);
					PlayState.chromZoomShader.setFloat('effectTime', PlayState.instance.chromEffect);
					PlayState.chromNormalShader.setFloat('rOffset', PlayState.instance.chromEffect / 45);
					PlayState.chromNormalShader.setFloat('bOffset', -PlayState.instance.chromEffect / 45);
					PlayState.dramaticCamMovement.setFloat('time', PlayState.instance.shaderAnim);
					if (PlayState.SONG.song == "Delusional")
					{
						PlayState.delusionalShift.setFloat('iTime', PlayState.instance.shaderAnim);
						PlayState.delusionalShift.setFloat('uTime', PlayState.instance.shaderAnim);
						PlayState.heatWaveEffect.setFloat("iTime", PlayState.instance.shaderAnim);
					}

				case 'Delusion':
					PlayState.chromZoomShader.setFloat('aberration', PlayState.instance.chromEffect);
					PlayState.chromZoomShader.setFloat('effectTime', PlayState.instance.chromEffect);
					PlayState.chromNormalShader.setFloat('rOffset', PlayState.instance.chromEffect / 45);
					PlayState.chromNormalShader.setFloat('bOffset', -PlayState.instance.chromEffect / 45);
					PlayState.dramaticCamMovement.setFloat('time', PlayState.instance.shaderAnim);
					PlayState.delusionalShift.setFloat('iTime', PlayState.instance.shaderAnim);
					PlayState.delusionalShift.setFloat('uTime', PlayState.instance.shaderAnim);
					PlayState.redVignette.setFloat('time', PlayState.instance.effectRed);

				case 'Malfunction':
					PlayState.chromZoomShader.setFloat('aberration', PlayState.instance.chromEffect);
					PlayState.chromZoomShader.setFloat('effectTime', PlayState.instance.chromEffect);
					PlayState.chromNormalShader.setFloat('rOffset', PlayState.instance.chromEffect / 20);
					PlayState.chromNormalShader.setFloat('bOffset', -PlayState.instance.chromEffect / 20);
					if (ClientPrefs.epilepsy)
						PlayState.blurShader.setFloat('bluramount', PlayState.instance.blurEffect);

				case 'Malfunction Legacy':
					PlayState.chromNormalShader.setFloat('rOffset', PlayState.instance.chromEffect / 20);
					PlayState.chromNormalShader.setFloat('bOffset', -PlayState.instance.chromEffect / 20);
					if (ClientPrefs.epilepsy)
						PlayState.blurShader.setFloat('bluramount', PlayState.instance.blurEffect);

				case 'Isolated Beta' | 'Isolated Legacy' | 'Isolated Old' | 'Lunacy Legacy' | 'Delusional Legacy':
					PlayState.andromeda.setFloat('iTime', PlayState.instance.shaderAnim);

				case 'Scrapped':
					if (ClientPrefs.epilepsy)
					{
						PlayState.blurShader.setFloat('bluramount', PlayState.instance.blurEffect);
						PlayState.blurShaderHUD.setFloat('bluramount', PlayState.instance.blurHUD);
					}
					PlayState.chromZoomShader.setFloat('aberration', PlayState.instance.chromEffect);
					PlayState.chromZoomShader.setFloat('effectTime', PlayState.instance.chromEffect);
					PlayState.chromNormalShader.setFloat('rOffset', PlayState.instance.chromEffect / 35);
					PlayState.chromNormalShader.setFloat('bOffset', -PlayState.instance.chromEffect / 35);
					PlayState.staticEffect.setFloat('uTime', PlayState.instance.shaderAnim);
					PlayState.staticEffect.setFloat('iTime', PlayState.instance.shaderAnim);

				case 'Twisted Grins' | 'Twisted Grins Legacy':
					PlayState.staticEffect.setFloat('uTime', PlayState.instance.shaderAnim);
					PlayState.staticEffect.setFloat('iTime', PlayState.instance.shaderAnim);

				case 'Hunted':
					PlayState.redVignette.setFloat('time', PlayState.instance.shaderAnim);

				case 'Mercy' | 'Mercy Legacy':
					PlayState.waltStatic.setFloat('time', PlayState.instance.shaderAnim);
					PlayState.dramaticCamMovement.setFloat('time', PlayState.instance.shaderAnim);

				case 'Cycled Sins Legacy':
					PlayState.redVignette.setFloat('time', PlayState.instance.shaderAnim);
					PlayState.dramaticCamMovement.setFloat('time', PlayState.instance.shaderAnim);
					PlayState.staticEffect.setFloat('uTime', PlayState.instance.shaderAnim);
					PlayState.staticEffect.setFloat('iTime', PlayState.instance.shaderAnim);
			}
    }

    /**
	 * Loads all RPC's icons
	 */
	public function loadRPCIcon()
    {
        #if DevBuild
		switch (PlayState.SONG.song)
		{
			case 'Isolated' | 'Hunted' | 'Hunted Legacy':
				PlayState.iconRPC = CoolUtil.spaceToDash(PlayState.SONG.song.toLowerCase());
			default:
				PlayState.iconRPC = 'icon';
		}
        #else
        PlayState.iconRPC = CoolUtil.spaceToDash(PlayState.SONG.song.toLowerCase()); // basically, it'll now look for the icon in the RPC via song name, if it doesn't it'll just return with no icon
        #end
    }

   /* public function noteTriggerEvent(type:String, canTween:Bool = false, ?time:Float = 1, ?ease:String = 'sineinout')
    {
        switch (type.toLowerCase())
        {
            case 'swapnormal':
                if (!canTween)
                {
                    PlayState.bfStrums.receptors.members[0].x = 77;
                    PlayState.bfStrums.receptors.members[1].x = 187;
                    PlayState.bfStrums.receptors.members[2].x = 302;
                    PlayState.bfStrums.receptors.members[3].x = 417;
                    PlayState.dadStrums.receptors.members[0].x = 77 + 640;
                    PlayState.dadStrums.receptors.members[1].x = 187 + 640;
                    PlayState.dadStrums.receptors.members[2].x = 302 + 640;
                    PlayState.dadStrums.receptors.members[3].x = 417 + 640;
                }
                else
                {
                    FlxTween.tween(PlayState.bfStrums.receptors.members[0], {x: 77}, time, {ease: returnTweenEase(ease)});
                    FlxTween.tween(PlayState.bfStrums.receptors.members[1], {x: 187}, time, {ease: returnTweenEase(ease)});
                    FlxTween.tween(PlayState.bfStrums.receptors.members[2], {x: 382}, time, {ease: returnTweenEase(ease)});
                    FlxTween.tween(PlayState.bfStrums.receptors.members[3], {x: 417}, time, {ease: returnTweenEase(ease)});
                    FlxTween.tween(PlayState.dadStrums.receptors.members[0], {x: 77 + 640}, time, {ease: returnTweenEase(ease)});
                    FlxTween.tween(PlayState.dadStrums.receptors.members[1], {x: 187 + 640}, time, {ease: returnTweenEase(ease)});
                    FlxTween.tween(PlayState.dadStrums.receptors.members[2], {x: 382 + 640}, time, {ease: returnTweenEase(ease)});
                    FlxTween.tween(PlayState.dadStrums.receptors.members[3], {x: 417 + 640}, time, {ease: returnTweenEase(ease)});
                }
            case 'swaprevert':
                if (!canTween)
                {
                    PlayState.dadStrums.receptors.members[0].x = 77;
                    PlayState.dadStrums.receptors.members[1].x = 187;
                    PlayState.dadStrums.receptors.members[2].x = 302;
                    PlayState.dadStrums.receptors.members[3].x = 417;
                    PlayState.bfStrums.receptors.members[0].x = 77 + 640;
                    PlayState.bfStrums.receptors.members[1].x = 187 + 640;
                    PlayState.bfStrums.receptors.members[2].x = 302 + 640;
                    PlayState.bfStrums.receptors.members[3].x = 417 + 640;
                }
                else
                {
                    FlxTween.tween(PlayState.dadStrums.receptors.members[0], {x: 77}, time, {ease: returnTweenEase(ease)});
                    FlxTween.tween(PlayState.dadStrums.receptors.members[1], {x: 187}, time, {ease: returnTweenEase(ease)});
                    FlxTween.tween(PlayState.dadStrums.receptors.members[2], {x: 382}, time, {ease: returnTweenEase(ease)});
                    FlxTween.tween(PlayState.dadStrums.receptors.members[3], {x: 417}, time, {ease: returnTweenEase(ease)});
                    FlxTween.tween(PlayState.bfStrums.receptors.members[0], {x: 77 + 640}, time, {ease: returnTweenEase(ease)});
                    FlxTween.tween(PlayState.bfStrums.receptors.members[1], {x: 187 + 640}, time, {ease: returnTweenEase(ease)});
                    FlxTween.tween(PlayState.bfStrums.receptors.members[2], {x: 382 + 640}, time, {ease: returnTweenEase(ease)});
                    FlxTween.tween(PlayState.bfStrums.receptors.members[3], {x: 417 + 640}, time, {ease: returnTweenEase(ease)});
                }
            case 'rightscroll':
                if (!canTween)
                {
                    moveThatFuckingStrum(false, 0, 270, 1, 1060, 120, 0);
                    moveThatFuckingStrum(false, 0, 270, 1, 1060, 240, 1);
                    moveThatFuckingStrum(false, 0, 270, 1, 1060, 360, 2);
                    moveThatFuckingStrum(false, 0, 270, 1, 1060, 480, 3);
                    moveThatFuckingStrum(true, 0.5, 270, 1, 50, 120, 0);
                    moveThatFuckingStrum(true, 0.5, 270, 1, 50, 240, 1);
                    moveThatFuckingStrum(true, 0.5, 270, 1, 50, 360, 2);
                    moveThatFuckingStrum(true, 0.5, 270, 1, 50, 480, 3);
                }
                else
                {

                }
        }
    }

    public function moveThatFuckingStrum(isDad:Bool = false, timer:Float = 0.5, direction:Float = 0, alpha:Float = 1, x:Null<Float>, y:Null<Float>, strumID:Int)
    {
        if (strumID > 3 || strumID < 0)
            strumID = 0;
        if (alpha > 1 || alpha < 0)
            alpha = 1;
        if (timer > 0)
            timer = 0.5;
        if (x == null)
            x = 0;
        if (y == null)
            y = 0;

        if (isDad)
        {
            if (timer == 0)
            {
                PlayState.dadStrums.receptors.members[strumID].strumDirection = direction;
                PlayState.dadStrums.receptors.members[strumID].x = x;
                PlayState.dadStrums.receptors.members[strumID].y = y;
                PlayState.camNotes[0].alpha = alpha;
            }
            else
            {
                FlxTween.tween(PlayState.dadStrums.receptors.members[strumID], 
                    {
                        strumDirection: direction,
                        x: x,
                        y: y
                    },
                    timer
                );
                FlxTween.tween(PlayState.camNotes[0], {alpha: alpha}, timer);
            }
        }
        else
        {
            if (timer == 0)
            {
                PlayState.bfStrums.receptors.members[strumID].strumDirection = direction;
                PlayState.bfStrums.receptors.members[strumID].x = x;
                PlayState.bfStrums.receptors.members[strumID].y = y;
                PlayState.camNotes[1].alpha = alpha;
            }
            else
            {
            FlxTween.tween(PlayState.bfStrums.receptors.members[strumID], 
                {
                    strumDirection: direction,
                    x: x,
                    y: y
                },
                timer
            );
            FlxTween.tween(PlayState.camNotes[1], {alpha: alpha}, timer);
            }
        }
    }*/
		
	/**
	 * # SPACEBAR Gimmick Checker
	 * 
	* Checks on the spacebar if there's a spacebar mechanic required
	* if you have a mechanic you want to add with the spacebar
	* simply tag in your gimmick here with the stage/song you want it
	* to occur at, in other words, go nuts
	*
	* @param isAutoplay - Do I REALLY need to explain this one?
	*
	* @author DEMOLITIONDON96
	*/
	public function detectSpace(isAutoplay:Bool = false)
	{
		if (!isAutoplay)
		{
			if (FlxG.keys.justPressed.SPACE)
			{
				/*
				* This set is for song-specific gimmicks
				* Try messing around with it
				*
				* - DEMOLITIONDON96
				*/

				switch (PlayState.SONG.song)
				{
					default:
						// nothing
				}

				/*
				* This is if you want the gimmicks to affect
				* ALL songs globally, if they use a certain stage
				* 2 examples are already provided below
				*
				* - DEMOLITIOONDON96
				*/

				switch (PlayState.curStage)
				{
					case 'waltRoom':
						if (PlayState.instance.limitThing > 0)
						{
							PlayState.health += 1.25;
							PlayState.instance.limitThing -= 1;
						}
					
					case 'apartment':
						if (PlayState.instance.shootin)
							PlayState.instance.dodged = true;

					default:
						// nothing
				}
			}
		} else {
			switch (PlayState.SONG.song)
			{
				default:
					//nothing
			}
			
			switch (PlayState.curStage)
			{
				case 'waltRoom':
					if (PlayState.health < 0.3 && PlayState.instance.limitThing > 0)
					{
						PlayState.health += 1.25;
						PlayState.instance.limitThing -= 1;
					}
					
				case 'apartment':
					if (PlayState.instance.shootin)
						PlayState.instance.dodged = true;
				
				default:
					// nothing
			}
		}
	}

    /**
	* The better and simplified Walt gimmick
	*
	* @author Wither362
	*/
	public function tweenWaltScreen(percentage:Float, alpha:Float):Bool {
		if (PlayState.health <= percentage)
			FlxTween.tween(PlayState.instance.waltScreenThing, {alpha: alpha}, 0.15, {ease: FlxEase.sineInOut});
		else
			return true;
		return false;
	}

    /**
     * A function about all events that happend when the dad touches a note
     */
    public function opponentNoteEvent():Void
        {
        switch (PlayState.SONG.song)
        {  
            case 'Lunacy' | 'Delusional':
                if (ClientPrefs.mechanics)
                     if (PlayState.health > boundValue)
                        PlayState.health -= drainValue;
                
            case 'Laugh Track':
                if (ClientPrefs.shaking)
                {
                    if (PlayState.health > 0.4)
                        PlayState.health -= 0.01;

					PlayState.camNotes.angle = PlayState.camHUD.angle = FlxG.random.float(-1.5, 1.5);
					FlxTween.tween(PlayState.camNotes, {angle: 0}, .025);
					PlayState.camGame.shake(0.0035, 0.05);
					PlayState.camHUD.shake(0.002, 0.035);
					FlxTween.tween(PlayState.camHUD, {angle: 0}, .025);
                    PlayState.camNotes.shake(0.002, 0.035);
                    
					/*PlayState.camGame.shake(0.005, 0.07);
                    PlayState.camHUD.shake(0.010, 0.07);
                    PlayState.camNotes.
                        i.shake(0.010, 0.07);*/
                }
                
            case 'Malfunction':
                if (PlayState.dad.curCharacter == 'glitched-mickey-new-pixel')
                {
                    if (PlayState.health > 0.05)
                        PlayState.health -= 0.01;
                    if (ClientPrefs.shaking)
                    {
                        PlayState.camGame.shake(0.008, 0.07);
                        for (i in [PlayState.camHUD, PlayState.camNotes])
                            i.shake(0.015, 0.07);
                    }
                    if (PlayState.instance.canaddshaders)
                    {			
                        if(!ClientPrefs.lowQuality && ClientPrefs.epilepsy)
                        {
                            PlayState.camGame.setFilters([
                                new ShaderFilter(PlayState.chromZoomShader),
                                new ShaderFilter(PlayState.chromNormalShader),
                                new ShaderFilter(PlayState.blurShader)
                            ]);
                            PlayState.camHUD.setFilters([
                                new ShaderFilter(PlayState.chromNormalShader),
                                new ShaderFilter(PlayState.blurShader)
                            ]);
                            PlayState.camNotes.setFilters([
                                    new ShaderFilter(PlayState.chromNormalShader),
                                    new ShaderFilter(PlayState.blurShader)
                                ]);
                        }
                        
                        PlayState.instance.chromEffect += 0.5;
                        PlayState.instance.blurEffect += 5;
                        
                        if (PlayState.instance.chromTween != null)
                            PlayState.instance.chromTween.cancel();
                        if (PlayState.instance.blurTween != null)
                            PlayState.instance.blurTween.cancel();

                        PlayState.instance.chromTween = FlxTween.tween(
                            PlayState.instance,
                            {
                                chromEffect: 0.0001
                            },
                            0.1,
                            {
                                ease: FlxEase.sineOut,
                                onComplete: function(twn:FlxTween)
                                {
                                    PlayState.instance.chromTween = null;
                                }
                            }
                        );
                        PlayState.instance.blurTween = FlxTween.tween(
                            PlayState.instance,
                            {
                                blurEffect: 0.0
                            },
                            0.1,
                            {
                                ease: FlxEase.sineOut,
                                onComplete: function(twn:FlxTween)
                                {
                                
                                    if(!ClientPrefs.lowQuality)
                                    {
                                        PlayState.camGame.setFilters([new ShaderFilter(PlayState.chromZoomShader), new ShaderFilter(PlayState.chromNormalShader)]);
                                        PlayState.camHUD.setFilters([new ShaderFilter(PlayState.chromNormalShader)]);
                                        PlayState.camNotes.setFilters([new ShaderFilter(PlayState.chromNormalShader)]);
                                    }
                                    PlayState.instance.blurTween = null;
                                }
                            }
                        );
                    }
                }
                else if (PlayState.dad.curCharacter == 'gm-tired-pixel')
                {
                    if (PlayState.health > 0.36)
                        PlayState.health -= 0.01;
                    if (ClientPrefs.shaking)
                    {
                        PlayState.camGame.shake(0.004, 0.07);
                        PlayState.camHUD.shake(0.007, 0.07);
                        PlayState.camNotes.shake(0.07, 0.07);
                    }
                    if (PlayState.instance.canaddshaders)
                    {
                        if(!ClientPrefs.lowQuality && ClientPrefs.epilepsy)
                        {
                            PlayState.camGame.setFilters([
                                new ShaderFilter(PlayState.chromZoomShader),
                                new ShaderFilter(PlayState.chromNormalShader),
                                new ShaderFilter(PlayState.blurShader)
                            ]);
                            PlayState.camHUD.setFilters([
                                new ShaderFilter(PlayState.chromNormalShader),
                                new ShaderFilter(PlayState.blurShader)
                            ]);
                            PlayState.camNotes.setFilters([
                                    new ShaderFilter(PlayState.chromNormalShader),
                                    new ShaderFilter(PlayState.blurShader)
                                ]);
                        }
                        
                        PlayState.instance.chromEffect += 0.25;
                        PlayState.instance.blurEffect += 2.5;
                        
                        if (PlayState.instance.chromTween != null)
                            PlayState.instance.chromTween.cancel();
                        if (PlayState.instance.blurTween != null)
                            PlayState.instance.blurTween.cancel();

                        PlayState.instance.chromTween = FlxTween.tween(
                            PlayState.instance,
                            {
                                chromEffect: 0.0001
                            },
                            0.1,
                            {
                                ease: FlxEase.sineOut,
                                onComplete: function(twn:FlxTween)
                                {
                                    PlayState.instance.chromTween = null;
                                }
                            }
                        );
                        PlayState.instance.blurTween = FlxTween.tween(
                            PlayState.instance,
                            {
                                blurEffect: 0.0
                            },
                            0.1,
                            {
                                ease: FlxEase.sineOut,
                                onComplete: function(twn:FlxTween)
                                {
                                
                                    if(!ClientPrefs.lowQuality)
                                    {
                                        PlayState.camGame.setFilters([new ShaderFilter(PlayState.chromZoomShader), new ShaderFilter(PlayState.chromNormalShader)]);
                                        PlayState.camHUD.setFilters([new ShaderFilter(PlayState.chromNormalShader)]);
                                        PlayState.camNotes.setFilters([new ShaderFilter(PlayState.chromNormalShader)]);
                                    }
                                    PlayState.instance.blurTween = null;
                                }
                            }
                        );
                    }
                }
                
            case 'Malfunction Legacy': // the reason this gets a separate case is cause shader effects are gonna be different
                if (PlayState.health > 0.05)
                       PlayState.health -= 0.016;
                if (ClientPrefs.shaking)
                {
                    PlayState.camGame.shake(0.008, 0.07);
                    for (i in [PlayState.camHUD, PlayState.camNotes])
                        i.shake(0.015, 0.07);
                }
                if (PlayState.instance.canaddshaders)
                {
                    if(!ClientPrefs.lowQuality && ClientPrefs.epilepsy)
                    {
                        PlayState.camGame.setFilters([
                            new ShaderFilter(PlayState.chromNormalShader),
                            new ShaderFilter(PlayState.blurShader)
                        ]);
                        PlayState.camHUD.setFilters([
                            new ShaderFilter(PlayState.chromNormalShader),
                            new ShaderFilter(PlayState.blurShader)
                        ]);
                        PlayState.camNotes.setFilters([
                                new ShaderFilter(PlayState.chromNormalShader),
                                new ShaderFilter(PlayState.blurShader)
                            ]);
                    }
                        
                    PlayState.instance.chromEffect += 0.3;
                    PlayState.instance.blurEffect += 1.5;
                        
                    if (PlayState.instance.chromTween != null)
                        PlayState.instance.chromTween.cancel();
                    if (PlayState.instance.blurTween != null)
                        PlayState.instance.blurTween.cancel();

                    PlayState.instance.chromTween = FlxTween.tween(
                        PlayState.instance,
                        {
                            chromEffect: 0.0001
                        },
                        0.1,
                        {
                            ease: FlxEase.sineOut,
                            onComplete: function(twn:FlxTween)
                            {
                                PlayState.instance.chromTween = null;
                            }
                        }
                    );
                    PlayState.instance.blurTween = FlxTween.tween(
                        PlayState.instance,
                        {
                            blurEffect: 0.0
                        },
                        0.1,
                        {
                            ease: FlxEase.sineOut,
                            onComplete: function(twn:FlxTween)
                            {
                                
                                if(!ClientPrefs.lowQuality)
                                {
                                    PlayState.camGame.setFilters([new ShaderFilter(PlayState.chromNormalShader)]);
                                    PlayState.camHUD.setFilters([new ShaderFilter(PlayState.chromNormalShader)]);
                                    PlayState.camNotes.setFilters([new ShaderFilter(PlayState.chromNormalShader)]);
                                }
                                PlayState.instance.blurTween = null;
                            }
                        }
                    );
                }
                
            case "Don't Cross!":
                PlayState.boyfriend.x += 1.2;
                PlayState.boyfriend.y -= 1.2;
                PlayState.boyfriend.scale.x -= 0.0012;
                PlayState.boyfriend.scale.y -= 0.0012;

                if (ClientPrefs.mechanics)
                {
                    if(PlayState.health > 0.05) // trol
                        PlayState.health -= 0.015;
                }
        }
    }

	public static function returnTweenEase(ease:String = '')
		{
			switch (ease.toLowerCase())
			{
				case 'linear':
					return FlxEase.linear;
				case 'backin':
					return FlxEase.backIn;
				case 'backinout':
					return FlxEase.backInOut;
				case 'backout':
					return FlxEase.backOut;
				case 'bouncein':
					return FlxEase.bounceIn;
				case 'bounceinout':
					return FlxEase.bounceInOut;
				case 'bounceout':
					return FlxEase.bounceOut;
				case 'circin':
					return FlxEase.circIn;
				case 'circinout':
					return FlxEase.circInOut;
				case 'circout':
					return FlxEase.circOut;
				case 'cubein':
					return FlxEase.cubeIn;
				case 'cubeinout':
					return FlxEase.cubeInOut;
				case 'cubeout':
					return FlxEase.cubeOut;
				case 'elasticin':
					return FlxEase.elasticIn;
				case 'elasticinout':
					return FlxEase.elasticInOut;
				case 'elasticout':
					return FlxEase.elasticOut;
				case 'expoin':
					return FlxEase.expoIn;
				case 'expoinout':
					return FlxEase.expoInOut;
				case 'expoout':
					return FlxEase.expoOut;
				case 'quadin':
					return FlxEase.quadIn;
				case 'quadinout':
					return FlxEase.quadInOut;
				case 'quadout':
					return FlxEase.quadOut;
				case 'quartin':
					return FlxEase.quartIn;
				case 'quartinout':
					return FlxEase.quartInOut;
				case 'quartout':
					return FlxEase.quartOut;
				case 'quintin':
					return FlxEase.quintIn;
				case 'quintinout':
					return FlxEase.quintInOut;
				case 'quintout':
					return FlxEase.quintOut;
				case 'sinein':
					return FlxEase.sineIn;
				case 'sineinout':
					return FlxEase.sineInOut;
				case 'sineout':
					return FlxEase.sineOut;
				case 'smoothstepin':
					return FlxEase.smoothStepIn;
				case 'smoothstepinout':
					return FlxEase.smoothStepInOut;
				case 'smoothstepout':
					return FlxEase.smoothStepInOut;
				case 'smootherstepin':
					return FlxEase.smootherStepIn;
				case 'smootherstepinout':
					return FlxEase.smootherStepInOut;
				case 'smootherstepout':
					return FlxEase.smootherStepOut;
			}
			return FlxEase.linear;
		}

    	/**
	*  # Cinematic Bars
	*
	* WORK IN PROGRESS, NOT FINAL
	*/		

	public var topBarTwn:FlxTween;
	public var bottomBarTwn:FlxTween;

	public function cinematicBarControls(controlType:String = "add", speed:Float, ease:String = "circInOut", position:Float = 0, bopValue:Float = 0)
        {
            switch (controlType.toLowerCase())
            {
                case "add" | "create":
					// idk if i should change this cus i dont wanna fuck up and i lazy to test them lol -sylinpix
                    if (PlayState.instance.cinematicBars["top"] == null)
                    {
                        PlayState.instance.cinematicBars["top"] = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
                        PlayState.instance.cinematicBars["top"].screenCenter(X);
                        PlayState.instance.cinematicBars["top"].cameras = [PlayState.camBars];
                        PlayState.instance.cinematicBars["top"].y = 0 - PlayState.instance.cinematicBars["top"].height; // offscreen
                        PlayState.instance.add(PlayState.instance.cinematicBars["top"]);
                    }
    
                    if (PlayState.instance.cinematicBars["bottom"] == null)
                    {
                        PlayState.instance.cinematicBars["bottom"] = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
                        PlayState.instance.cinematicBars["bottom"].screenCenter(X);
                        PlayState.instance.cinematicBars["bottom"].cameras = [PlayState.camBars];
                        PlayState.instance.cinematicBars["bottom"].y = FlxG.height; // offscreen
                        PlayState.instance.add(PlayState.instance.cinematicBars["bottom"]);
                    }
                    
                case "remove" | "kill" | "delete":
                    if (PlayState.instance.cinematicBars["top"] != null)
					{
                        PlayState.instance.cinematicBars["top"].kill();
						PlayState.instance.cinematicBars["top"] = null;
					}
                    if (PlayState.instance.cinematicBars["bottom"] != null)
					{
                        PlayState.instance.cinematicBars["bottom"].kill();
						PlayState.instance.cinematicBars["bottom"] = null;
					}
                    
                case "movetop" | "move top":
					if (topBarTwn != null)
						topBarTwn.cancel();

                    topBarTwn = FlxTween.tween(PlayState.instance.cinematicBars["top"], {y: position - FlxG.height}, speed, {ease: returnTweenEase(ease), onComplete: function(twn:FlxTween)
					{
						topBarTwn = null;
					}});
                    
                case "movebottom" | "move bottom":
					if (bottomBarTwn != null)
						bottomBarTwn.cancel();

                    bottomBarTwn = FlxTween.tween(PlayState.instance.cinematicBars["bottom"], {y: FlxG.height - position}, speed, {ease: returnTweenEase(ease), onComplete: function(twn:FlxTween)
					{
						bottomBarTwn = null;
					}});
                    
                case "moveboth" | "move both":
					if (topBarTwn != null)
						topBarTwn.cancel();
					if (bottomBarTwn != null)
						bottomBarTwn.cancel();

                    topBarTwn = FlxTween.tween(PlayState.instance.cinematicBars["top"], {y: position - FlxG.height}, speed, {ease: returnTweenEase(ease), onComplete: function(twn:FlxTween)
					{
						topBarTwn = null;
					}});
                    bottomBarTwn = FlxTween.tween(PlayState.instance.cinematicBars["bottom"], {y: FlxG.height - position}, speed, {ease: returnTweenEase(ease), onComplete: function(twn:FlxTween)
					{
						bottomBarTwn = null;
					}});
                    
                case "boptop" | "bop top":
                    PlayState.instance.cinematicBars["top"].y = position - FlxG.height;
					FlxTween.tween(PlayState.instance.cinematicBars["top"], {y: (position - FlxG.height) + bopValue}, speed, {ease: returnTweenEase(ease)});
                    
                case "bopbottom" | "bop bottom":
                    PlayState.instance.cinematicBars["bottom"].y = FlxG.height - position;
					FlxTween.tween(PlayState.instance.cinematicBars["bottom"], {y: (FlxG.height - position) - bopValue}, speed, {ease: returnTweenEase(ease)});
                    
                case "bopboth" | "bop both":
					if (topBarTwn != null)
						topBarTwn.cancel();
					if (bottomBarTwn != null)
						bottomBarTwn.cancel();

                    PlayState.instance.cinematicBars["top"].y = position - FlxG.height;
                    PlayState.instance.cinematicBars["bottom"].y = FlxG.height - position;
					topBarTwn = FlxTween.tween(PlayState.instance.cinematicBars["top"], {y: (position - FlxG.height) + bopValue}, speed, {ease: returnTweenEase(ease), onComplete: function(twn:FlxTween)
					{
						topBarTwn = null;
					}});
					bottomBarTwn = FlxTween.tween(PlayState.instance.cinematicBars["bottom"], {y: (FlxG.height - position) - bopValue}, speed, {ease: returnTweenEase(ease), onComplete: function(twn:FlxTween)
					{
						bottomBarTwn = null;
					}});
            }
        }
    
        /**
        * ## Camera Zoom Tween Fix
        * 
        * Don't know why, but this was NEEDED to fix the zooming from breaking, smh.
        *
        * @param zoom - Sets the zoom value of the camera
        * @param time - How long you want the tween to take
        * @param ease - I suggest reading the HaxeFlixel API on this one, this uses FlxEase's library components if you don't know how to use this
        *
        * @author JustJasonLol
        */
        public function tweenCamera(zoom:Float = 0.9, time:Float = 0.6, ease:Null<String>):Void
        {
            FlxTween.tween(PlayState.camGame, {zoom: zoom}, time, {ease: returnTweenEase(ease), onComplete: e -> PlayState.defaultCamZoom = zoom});
        }

    public function loadWindowTitleData(isStory:Bool, isCharting:Bool)
    {
                if (isStory && !isCharting)
				{
                    switch (PlayState.SONG.song)
                    {
                        case 'Devilish Deal' | 'Isolated' | 'Lunacy' | 'Delusional':
                            Application.current.window.title = 'Funkin.AVI - Episode 1: ' + PlayState.SONG.song + " - Composed by: " + PlayState.SONG.composer + (PlayState.instance.paused ? ' {PAUSED}' : "");							
                        case 'Twisted Grins' | 'Resentment' | 'Mortiferum Risus':
                            Application.current.window.title = 'Funkin.AVI - Episode S: ' + PlayState.SONG.song + " - Composed by: " + PlayState.SONG.composer + (PlayState.instance.paused ? ' {PAUSED}' : "");					
                        case 'Mercy' | 'Affliction':
         	               Application.current.window.title = 'Funkin.AVI - Episode W: ' + PlayState.SONG.song + " - Composed by: " + PlayState.SONG.composer + (PlayState.instance.paused ? ' {PAUSED}' : "");			
                        default:
                            Application.current.window.title = 'Funkin.AVI - Episode ???: ' + PlayState.SONG.song + " - Composed by: " + PlayState.SONG.composer + (PlayState.instance.paused ? ' {PAUSED}' : "");
                    }	
				}		
				else if (isCharting)
				{
					if (PlayState.SONG.song == 'Malfunction')
						Application.current.window.title = 'malsquare.hx - CHEATER MODE ACTIVATED: ' + PlayState.SONG.song + " - Composed by: I CAN SEE YOU CHEATING! - [!CHEATER DETECTED!]" + (PlayState.instance.paused ? ' {PAUSED}' : "");
					else
						Application.current.window.title = 'Funkin.AVI - TESTING MODE: ' + PlayState.SONG.song + " - Composed by: " + PlayState.SONG.composer + (PlayState.instance.paused ? ' {PAUSED}' : "");
				}
				else if (!isStory && !isCharting)
				{
                    Application.current.window.title = 'Funkin.AVI - Freeplay: ' + PlayState.SONG.song + " - Composed by: " + PlayState.SONG.composer + (PlayState.instance.paused ? ' {PAUSED}' : "");
				}
    }

	/**
	 * ## Built-in Settings Fix
	 * 
	 * made in case the annoying bitches that played the v1.8 demo don't bother changing settings and assumed they're all good to go and have a skill issue crashing cause they didn't check
	 * 
	 * @author DEMOLITIONDON96
	 */
	/*public function migrateSettings()
	{
		switch (Init.trueSettings.get('HUD Style'))
		{
			case 'demoltion':
				Init.trueSettings.set('HUD Style', 'spectra');
			case 'forever' | 'default':
				Init.trueSettings.set('HUD Style', 'classic');
		}
		switch (Init.trueSettings.get('Timing Preset'))
		{
			case 'forever':
				Init.trueSettings.set('Timing Preset', 'default');
		}
		Init.saveSettings();
	}*/
}
