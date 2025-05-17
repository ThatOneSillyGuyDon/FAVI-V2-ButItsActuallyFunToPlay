package states.stages;

import states.stages.objects.*;

class MenuSongs extends BaseStage
{
	var skyFlash:FlxSprite;

	override function create()
	{
		game.defaultCamZoom = 1;

		var sky = new FlxSprite().loadGraphic(Paths.image(PlayState.pathway + "secretBG"));
		sky.scrollFactor.set(0, 0);
		add(sky);

		var stars1 = new FlxSprite().loadGraphic(Paths.image(PlayState.pathway + "secretStars1"));
		stars1.scrollFactor.set(0, 0);
		add(stars1);
		
		var stars2 = new FlxSprite().loadGraphic(Paths.image(PlayState.pathway + "secretStars2"));
		stars2.scrollFactor.set(0, 0);
		stars2.alpha = 0.001;
		add(stars2);

		skyFlash = new FlxSprite().makeGraphic(FlxG.width*5, FlxG.height*5, FlxColor.WHITE);
		skyFlash.screenCenter();
		skyFlash.scrollFactor.set(0, 0);
		skyFlash.alpha = 0.001;
		add(skyFlash);

		var street = new FlxSprite().loadGraphic(Paths.image(PlayState.pathway + "secretStreet"));
		street.scrollFactor.set(0, 0);
		add(street);

		var underlay = new FlxSprite().loadGraphic(Paths.image(PlayState.pathway + "secretNoteUnderlay"));
		underlay.cameras = [camHUD];
		add(underlay);

		var overlay = new FlxSprite().loadGraphic(Paths.image(PlayState.pathway + "secretOverlay"));
		overlay.cameras = [camOther];
		add(overlay);

		FlxTween.tween(stars1, {alpha: 0}, 3, {type: 4});
		FlxTween.tween(stars2, {alpha: 1}, 3, {type: 4});
	}
	
	override function createPost()
	{
		game.boyfriend.visible = false;
		game.dad.visible = false;
		game.gf.visible = false;
	}

	var skyTwn:FlxTween;
	// For events
	override function eventCalled(eventName:String, value1:String, value2:String, flValue1:Null<Float>, flValue2:Null<Float>, strumTime:Float)
	{
		switch(eventName)
		{
			case "Mania BG Flash":
				var triggerVars:Array<String> = value1.split(',');
				if (ClientPrefs.data.flashing)
				{
					switch (value2.toLowerCase())
					{
						case "sky":
							if (skyTwn != null)
								skyTwn.cancel();

							if (skyFlash != null)
							{
								skyFlash.color = FlxColor.fromRGB(Std.parseInt(triggerVars[3]), Std.parseInt(triggerVars[4]), Std.parseInt(triggerVars[5]));
								skyFlash.alpha = Std.parseFloat(triggerVars[2]);
								skyTwn = FlxTween.tween(skyFlash, {alpha: 0}, Std.parseFloat(triggerVars[0]), {ease: PlayState.returnTweenEase(triggerVars[1]), onComplete: function(twn:FlxTween)
								{
									skyTwn = null;
								}});
							}
						case "all": 
							game.camFlashSystem(BG_FLASH, {
								timer: Std.parseFloat(triggerVars[0]), 
								ease: PlayState.returnTweenEase(triggerVars[1]), 
								alpha: Std.parseFloat(triggerVars[2]), 
								colors: [Std.parseInt(triggerVars[3]), Std.parseInt(triggerVars[4]), Std.parseInt(triggerVars[5])]
							});
					}
				}
		}
	}
}