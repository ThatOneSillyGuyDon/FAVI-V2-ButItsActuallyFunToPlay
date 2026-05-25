import funkin.utils.CoolUtil;

import openfl.filters.ShaderFilter;

using StringTools;

public var shittyTwns:Array<FlxTween> = [];
var camTwn:Array<FlxTween> = [];

var flashSprite:FlxSprite;
var flashSpeed:Float = 0.0;

// once again, stolen from vs imposter legacy, i'm too lazy to figure ts out
public function nullBlank(val) return val.length == 0 || val.trim() == '';

function onCreatePost()
{
	flashSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.WHITE);
	flashSprite.scale.set(3, 3);
	flashSprite.screenCenter();
	flashSprite.alpha = 0.001;
	flashSprite.cameras = [camBars];
	add(flashSprite);
}

function onUpdate(elapsed)
{
	flashSprite.alpha = FlxMath.lerp(0, flashSprite.alpha, Math.exp(-elapsed * flashSpeed));
}

function onEventPush(event:EventNote)
{
	switch (event.event)
	{
		case 'Cinematic Event':
			if (cinematicBars["top"] == null)
			{
				cinematicBars["top"] = new FlxSprite(0, 0).makeGraphic(FlxG.width * 3, FlxG.height, FlxColor.WHITE);
				cinematicBars["top"].screenCenter(0x01);
				cinematicBars["top"].cameras = [camBars];
				cinematicBars["top"].y = 0 - cinematicBars["top"].height;
				add(cinematicBars["top"]);
				cinematicBars["top"].color = FlxColor.BLACK;
			}
			
			if (cinematicBars["bottom"] == null)
			{
				cinematicBars["bottom"] = new FlxSprite(0, 0).makeGraphic(FlxG.width * 3, FlxG.height, FlxColor.WHITE);
				cinematicBars["bottom"].screenCenter(0x01);
				cinematicBars["bottom"].cameras = [camBars];
				cinematicBars["bottom"].y = FlxG.height;
				add(cinematicBars["bottom"]);
				cinematicBars["bottom"].color = FlxColor.BLACK;
			}
			
		case "Camera Event":
			if (event.value1.toLowerCase().trim() == "starthidden")
			{
				camHUD.alpha = 0.001;
				camBars.fade(FlxColor.BLACK, 0.001);
			}
	}
}

function onEvent(eventName, value1, value2)
{
	var triggerInfo:Array<String> = value2.split(',');
	switch (eventName)
	{
		case 'Change Health Stat':
			var val:Float = Std.parseFloat(value2);
			switch (value1.toLowerCase().trim())
			{
				case "gain": healthGain = val;
				case "loss": healthLoss = val;
				case "drain": healthDrain = val;
				case "limit": healthLimit = val;
				case "health": health = val;
			}
			
		/*case 'BG Visual Event':
			var alpha:Float = Std.parseFloat(triggerInfo[0]);
			var speedVal:Float = Std.parseFloat(triggerInfo[1]);
			switch (value1.toLowerCase().trim())
			{
				case "flash":
					bgFlash.alpha = alpha;
					bgFlashS = speedVal;
					
				case "alpha":
					bgFlashV = alpha;
					bgFlashS = speedVal;
					
				case "color":
					var canFlash:String = triggerInfo[3];
					var prevColor:FlxColor = bgFlash.color;
					var curColor:FlxColor = FlxColor.fromString(triggerInfo[0].toLowerCase().trim());
					var timer:Float = Std.parseFloat(triggerInfo[1]);
					
					if (canFlash != null || canFlash == '') canFlash = "false";
					
					if (shittyTwns[10] != null) shittyTwns[10].cancel();
					
					if (timer > 0)
					{
						canFlash.toLowerCase().trim();
						if (canFlash == "true")
						{
							bgFlash.color = curColor;
							
							shittyTwns[10] = FlxTween.color(bgFlash, timer, curColor, prevColor,
								{
									ease: CoolUtil.getEaseFromString(triggerInfo[2].toLowerCase().trim()),
									onComplete: function(twn:FlxTween) {
										shittyTwns[10] = null;
									}
								});
						}
						else
						{
							shittyTwns[10] = FlxTween.color(bgFlash, timer, prevColor, curColor,
								{
									ease: CoolUtil.getEaseFromString(triggerInfo[2].toLowerCase().trim()),
									onComplete: function(twn:FlxTween) {
										shittyTwns[10] = null;
									}
								});
						}
					}
					else
					{
						bgFlash.color = curColor;
					}
		}*/
		
		case 'Camera Event':
			switch (value1.toLowerCase())
			{
				case "tweenvalue":
					switch (triggerInfo[0].toLowerCase())
					{
						case "zoom":
							if (camTwn[0] != null) camTwn[0].cancel();
							
							camTwn[0] = FlxTween.tween(camGame, {zoom: Std.parseFloat(triggerInfo[1])}, Std.parseFloat(triggerInfo[2]),
								{
									ease: CoolUtil.getEaseFromString(triggerInfo[3].trim()),
									onComplete: function(twn:FlxTween) {
										defaultCamZoom = Std.parseFloat(triggerInfo[1]);
										camTwn[0] = null;
									}
								});
								
						case "cameraspeed":
							if (camTwn[1] != null) camTwn[1].cancel();
							
							camTwn[1] = FlxTween.tween(this, {cameraSpeed: Std.parseFloat(triggerInfo[1])}, Std.parseFloat(triggerInfo[2]),
								{
									ease: CoolUtil.getEaseFromString(triggerInfo[3].trim()),
									onComplete: function(twn:FlxTween) {
										camTwn[1] = null;
									}
								});
								
						case "alpha":
							if (camTwn[2] != null) camTwn[2].cancel();
							
							if (Std.parseFloat(triggerInfo[1]) > 1 || Std.parseFloat(triggerInfo[1]) < 0) triggerInfo[1] = "1";
							
							camTwn[2] = FlxTween.tween(camGame, {alpha: Std.parseFloat(triggerInfo[1])}, Std.parseFloat(triggerInfo[2]),
								{
									ease: CoolUtil.getEaseFromString(triggerInfo[3].trim()),
									onComplete: function(twn:FlxTween) {
										camTwn[2] = null;
									}
								});
								
						case "hudalpha":
							if (camTwn[3] != null) camTwn[3].cancel();
							
							if (Std.parseFloat(triggerInfo[1]) > 1 || Std.parseFloat(triggerInfo[1]) < 0) triggerInfo[1] = "1";
							
							camTwn[3] = FlxTween.tween(camHUD, {alpha: Std.parseFloat(triggerInfo[1])}, Std.parseFloat(triggerInfo[2]),
								{
									ease: CoolUtil.getEaseFromString(triggerInfo[3].trim()),
									onComplete: function(twn:FlxTween) {
										camTwn[3] = null;
									}
								});
								
						case "angle":
							if (camTwn[4] != null) camTwn[4].cancel();
							
							camTwn[4] = FlxTween.tween(camGame, {angle: Std.parseFloat(triggerInfo[1])}, Std.parseFloat(triggerInfo[2]),
								{
									ease: CoolUtil.getEaseFromString(triggerInfo[3].trim()),
									onComplete: function(twn:FlxTween) {
										camTwn[4] = null;
									}
								});
								
						case "hudangle":
							if (camTwn[5] != null) camTwn[5].cancel();
							
							camTwn[5] = FlxTween.tween(camHUD, {angle: Std.parseFloat(triggerInfo[1])}, Std.parseFloat(triggerInfo[2]),
								{
									ease: CoolUtil.getEaseFromString(triggerInfo[3].trim()),
									onComplete: function(twn:FlxTween) {
										camTwn[5] = null;
									}
								});
								
						default:
							return;
					}
					
				case "starthidden":
					// do nothing cause it's already doing something
					
				case "changevalue":
					switch (triggerInfo[0].toLowerCase())
					{
						case "staticzoom": camGame.zoom = defaultCamZoom = Std.parseFloat(triggerInfo[1]);
						case "addzoom": camGame.zoom += Std.parseFloat(triggerInfo[1]);
						case "addhudzoom": camHUD.zoom += Std.parseFloat(triggerInfo[1]);
						case "defaultcamzoom": defaultCamZoom = Std.parseFloat(triggerInfo[1]);
						case "alpha": camGame.alpha = Std.parseFloat(triggerInfo[1]);
						case "cameraspeed": cameraSpeed = Std.parseFloat(triggerInfo[1]);
						case "hudalpha": camHUD.alpha = Std.parseFloat(triggerInfo[1]);
						case "angle": camGame.angle = Std.parseFloat(triggerInfo[1]);
						case "hudangle": camHUD.angle = Std.parseFloat(triggerInfo[1]);
						case "adddefaultcamzoom": defaultCamZoom += Std.parseFloat(triggerInfo[1]);
						default:
							return;
					}
					
				case "shake":
					if (triggerInfo[2] == "hud") camHUD.shake(Std.parseFloat(triggerInfo[0]),
						Std.parseFloat(triggerInfo[1])); else camGame.shake(Std.parseFloat(triggerInfo[0]), Std.parseFloat(triggerInfo[1]));
						
				case "flash":
					if (ClientPrefs.flashing)
					{
						if (triggerInfo[0] == null) triggerInfo[0] = "255";
						if (triggerInfo[1] == null) triggerInfo[1] = "255";
						if (triggerInfo[2] == null) triggerInfo[2] = "255";
						if (triggerInfo[3] == null) triggerInfo[3] = "1";
						if (triggerInfo[4] == null) triggerInfo[4] = "1";
						if (triggerInfo[5] == null) triggerInfo[5] = "false";
			
						var boolShit:Bool = false;
			
						if (triggerInfo[5].toLowerCase().trim() == "true")
							boolShit = true;
			
						flashSprite.color = FlxColor.fromRGB(Std.parseInt(triggerInfo[0]), Std.parseInt(triggerInfo[1]), Std.parseInt(triggerInfo[2]));
						flashSpeed = Std.parseFloat(triggerInfo[3]);
						flashSprite.alpha = Std.parseFloat(triggerInfo[4]);
						flashSprite.blend = (boolShit ? BlendMode.ADD : BlendMode.NORMAL);
					}

				case "fade":
					var boolShit = false;
					if (triggerInfo[0] == null) triggerInfo[0] = "0";
					if (triggerInfo[1] == null) triggerInfo[1] = "0";
					if (triggerInfo[2] == null) triggerInfo[2] = "0";
					if (triggerInfo[3] == null) triggerInfo[3] = "1";
					if (triggerInfo[4] == null) triggerInfo[4] = "false";
					
					if (triggerInfo[4].toLowerCase().trim() == "true") boolShit = true;
					
					camBars.fade(FlxColor.fromRGB(Std.parseInt(triggerInfo[0]), Std.parseInt(triggerInfo[1]), Std.parseInt(triggerInfo[2])), Std.parseFloat(triggerInfo[3]), boolShit);
				case "changepos":
					if (camFollow != null)
					{
						isCameraOnForcedPos = false;
						if (triggerInfo[0] != null || triggerInfo[1] != null)
						{
							isCameraOnForcedPos = true;
							if (triggerInfo[0] == null) triggerInfo[0] = "0";
							if (triggerInfo[1] == null) triggerInfo[1] = "0";
							camFollow.x = Std.parseFloat(triggerInfo[0]);
							camFollow.y = Std.parseFloat(triggerInfo[1]);
						}
					}
					
				case "tweenpos":
					if (camFollow != null)
					{
						if (camTwn[7] != null) camTwn[7].cancel();
						
						isCameraOnForcedPos = false;
						if (triggerInfo[0] != null || triggerInfo[1] != null)
						{
							isCameraOnForcedPos = true;
							if (triggerInfo[0] == null) triggerInfo[0] = "0";
							if (triggerInfo[1] == null) triggerInfo[1] = "0";
							camTwn[7] = FlxTween.tween(camFollow, {x: Std.parseFloat(triggerInfo[0]), y: Std.parseFloat(triggerInfo[1])}, Std.parseFloat(triggerInfo[2]), {
								ease: CoolUtil.getEaseFromString(triggerInfo[3].trim().toLowerCase()),
								onComplete: function(twn:FlxTween) {
									camTwn[7] = null;
								}
							});
						}
					}
				case "snappos":
					if (camFollow != null)
					{
						isCameraOnForcedPos = false;
						if (triggerInfo[0] != null || triggerInfo[1] != null)
						{
							isCameraOnForcedPos = true;
							if (triggerInfo[0] == null) triggerInfo[0] = "0";
							if (triggerInfo[1] == null) triggerInfo[1] = "0";
							
							snapCamToPos(Std.parseFloat(triggerInfo[0]), Std.parseFloat(triggerInfo[1]), true);
						}
					}
			}
			
		case 'Cinematic Event':
			switch (value1.toLowerCase().trim())
			{
				case "move":
					cinematicBarControls("move",
						{
							valueInput: Std.parseFloat(triggerInfo[0]), // Thickness of the bars
							timer: Std.parseFloat(triggerInfo[1]), // Duration
							ease: triggerInfo[2] // Ease name
						});
				case "angle":
					cinematicBarControls("angle",
						{
							valueInput: Std.parseFloat(triggerInfo[0]), // Camera angle of the bars
							timer: Std.parseFloat(triggerInfo[1]), // Duration
							ease: triggerInfo[2] // Ease name
						});
				case "color":
					cinematicBarControls("color",
						{
							colors: // Color the bars change to
							[
								Std.parseInt(triggerInfo[0]), // R
								Std.parseInt(triggerInfo[1]), // G
								Std.parseInt(triggerInfo[2]) // B
							],
							timer: Std.parseFloat(triggerInfo[3]), // Duration
							ease: triggerInfo[4] // Ease name
						});
				case "flash":
					cinematicBarControls("flash",
						{
							colors: // Flash color of the bars
							[
								Std.parseInt(triggerInfo[0]), // R
								Std.parseInt(triggerInfo[1]), // G
								Std.parseInt(triggerInfo[2]) // B
							],
							timer: Std.parseFloat(triggerInfo[3]), // Duration
							ease: triggerInfo[4] // Ease name
						});
				case "alpha":
					cinematicBarControls("alpha",
						{
							valueInput: Std.parseFloat(triggerInfo[0]), // Alpha value of the camera the bars are on
							timer: Std.parseFloat(triggerInfo[1]), // Duration
							ease: triggerInfo[2] // Ease name
						});
				case "bop":
					cinematicBarControls("bop",
						{
							valueInput: Std.parseFloat(triggerInfo[0]), // How intense the bars will bop
							timer: Std.parseFloat(triggerInfo[1]), // Duration
							ease: triggerInfo[2] // Ease name
						});
			}
	}
}
