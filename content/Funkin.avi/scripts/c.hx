import funkin.utils.CoolUtil;

using StringTools;

typedef CinematicSettings =
{
	@:optional var valueInput:Float;
	
	@:optional var timer:Float;
	
	@:optional var ease:String;
	
	@:optional var colors:Array<Int>;
}

public var cinematicBars:Map<String, FlxSprite> = ["top" => null, "bottom" => null];

public function cinematicBarControls(controlType:String, settings:CinematicSettings)
{
	// null checkes
	if (settings.colors == null) settings.colors = [0, 0, 0];
	if (settings.timer == null) settings.timer = 3;
	if (settings.ease == null) settings.ease = "linear";
	if (settings.valueInput == null) settings.valueInput = 50;
	
	switch (controlType.toLowerCase().trim())
	{
		case "move":
			if (shittyTwns[0] != null) shittyTwns[0].cancel();
			if (shittyTwns[1] != null) shittyTwns[1].cancel();
			
			shittyTwns[0] = FlxTween.tween(cinematicBars["top"], {y: settings.valueInput - FlxG.height}, settings.timer,
				{
					ease: CoolUtil.getEaseFromString(settings.ease.toLowerCase().trim()),
					onComplete: function(twn:FlxTween) {
						shittyTwns[0] = null;
					}
				});
			shittyTwns[1] = FlxTween.tween(cinematicBars["bottom"], {y: FlxG.height - settings.valueInput}, settings.timer,
				{
					ease: CoolUtil.getEaseFromString(settings.ease.toLowerCase().trim()),
					onComplete: function(twn:FlxTween) {
						shittyTwns[1] = null;
					}
				});
				
		case "bop":
			if (cinematicBars["top"] != null && cinematicBars["bottom"] != null)
			{
				if (shittyTwns[2] != null) shittyTwns[2].cancel();
				if (shittyTwns[3] != null) shittyTwns[3].cancel();
				
				cinematicBars["top"].y -= settings.valueInput;
				cinematicBars["bottom"].y += settings.valueInput;
				shittyTwns[2] = FlxTween.tween(cinematicBars["top"], {y: cinematicBars["top"].y + settings.valueInput}, settings.timer,
					{
						ease: CoolUtil.getEaseFromString(settings.ease.toLowerCase().trim()),
						onComplete: function(twn:FlxTween) {
							shittyTwns[2] = null;
						}
					});
				shittyTwns[3] = FlxTween.tween(cinematicBars["bottom"], {y: cinematicBars["bottom"].y - settings.valueInput}, settings.timer,
					{
						ease: CoolUtil.getEaseFromString(settings.ease.toLowerCase().trim()),
						onComplete: function(twn:FlxTween) {
							shittyTwns[3] = null;
						}
					});
			}
			
		case "flash":
			if (cinematicBars["top"] != null && cinematicBars["bottom"] != null)
			{
				if (shittyTwns[4] != null) shittyTwns[4].cancel();
				if (shittyTwns[5] != null) shittyTwns[5].cancel();
				
				var lastColor:FlxColor = cinematicBars["top"].color;
				cinematicBars["top"].color = FlxColor.fromRGB(settings.colors[0], settings.colors[1], settings.colors[2]);
				cinematicBars["bottom"].color = FlxColor.fromRGB(settings.colors[0], settings.colors[1], settings.colors[2]);
				
				shittyTwns[4] = FlxTween.color(cinematicBars["top"], settings.timer, FlxColor.fromRGB(settings.colors[0], settings.colors[1], settings.colors[2]), lastColor, {
					ease: CoolUtil.getEaseFromString(settings.ease.toLowerCase().trim()),
					onComplete: function(twn:FlxTween) {
						shittyTwns[4] = null;
					}
				});
				shittyTwns[5] = FlxTween.color(cinematicBars["bottom"], settings.timer, FlxColor.fromRGB(settings.colors[0], settings.colors[1], settings.colors[2]), lastColor, {
					ease: CoolUtil.getEaseFromString(settings.ease.toLowerCase().trim()),
					onComplete: function(twn:FlxTween) {
						shittyTwns[5] = null;
					}
				});
			}
			
		case "angle":
			if (cinematicBars["top"] != null && cinematicBars["bottom"] != null)
			{
				if (shittyTwns[6] != null) shittyTwns[6].cancel();
				
				shittyTwns[6] = FlxTween.tween(camBars, {angle: settings.valueInput}, settings.timer,
					{
						ease: CoolUtil.getEaseFromString(settings.ease.toLowerCase().trim()),
						onComplete: function(twn:FlxTween) {
							shittyTwns[6] = null;
						}
					});
			}
			
		case "color":
			if (cinematicBars["top"] != null && cinematicBars["bottom"] != null)
			{
				if (shittyTwns[7] != null) shittyTwns[7].cancel();
				if (shittyTwns[8] != null) shittyTwns[8].cancel();
				
				shittyTwns[7] = FlxTween.color(cinematicBars["top"], settings.timer, cinematicBars["top"].color, FlxColor.fromRGB(settings.colors[0], settings.colors[1], settings.colors[2]), {
					ease: CoolUtil.getEaseFromString(settings.ease.toLowerCase().trim()),
					onComplete: function(twn:FlxTween) {
						shittyTwns[7] = null;
					}
				});
				shittyTwns[8] = FlxTween.color(cinematicBars["bottom"], settings.timer, cinematicBars["bottom"].color, FlxColor.fromRGB(settings.colors[0], settings.colors[1], settings.colors[2]), {
					ease: CoolUtil.getEaseFromString(settings.ease.toLowerCase().trim()),
					onComplete: function(twn:FlxTween) {
						shittyTwns[8] = null;
					}
				});
			}
			
		case "alpha":
			if (cinematicBars["top"] != null && cinematicBars["bottom"] != null)
			{
				if (settings.valueInput > 1 || settings.valueInput < 0) settings.valueInput = 1;
				
				if (shittyTwns[9] != null) shittyTwns[9].cancel();
				
				shittyTwns[9] = FlxTween.tween(camBars, {alpha: settings.valueInput}, settings.timer,
					{
						ease: CoolUtil.getEaseFromString(settings.ease.toLowerCase().trim()),
						onComplete: function(twn:FlxTween) {
							shittyTwns[9] = null;
						}
					});
			}
	}
}
