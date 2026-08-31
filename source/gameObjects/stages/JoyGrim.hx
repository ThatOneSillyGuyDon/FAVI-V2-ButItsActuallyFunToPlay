package gameObjects.stages;

class JoyGrim extends BaseStage
{
	public var offsetTwn:FlxTween;
	var clubhouse:FlxSprite;
	override function create()
	{
		game.defaultCamZoom = 0.75;
		game.cameraSpeed = 1.2;
		PlayState.isGreyscale = false;

		// you may wonder why i did like that.. simple, PATHS IMAGES DIDNT WANT TO LOAD CORRECTLY ! 
		clubhouse = new FlxSprite(-770, -650).loadGraphic(Paths.image('favi/stages/clubhouse/images/clubhouse'));
		clubhouse.scale.set(1.4, 1.4);
		add(clubhouse);
	}

	override function update(elapsed:Float)
	{
		game.dad.setPosition(-140, 20);
		game.boyfriend.setPosition(650, -260);
		game.gf.setPosition(280, -410);

		super.update(elapsed);
	}

	override function createPost() {
		game.camBars.fade(FlxColor.BLACK, 0.0001);
		game.camHUD.alpha = 0;

	}
	// so like the event where the background goes insane right? i ate it.
	
	override function eventCalled(eventName:String, value1:String, value2:String, flValue1:Null<Float>, flValue2:Null<Float>, strumTime:Float){
		// so you may wonder why im not going to make an eventName instead?
		// simple, im fucking lazy + the mod aint going to use this function anyway
		switch(value1){
			case "evilShi":
				FlxTween.color(clubhouse, 0.2, FlxColor.WHITE, FlxColor.fromRGB(255, 17, 0));
				FlxTween.color(game.iconP2, 0.2, FlxColor.WHITE, FlxColor.fromRGB(255, 17, 0));

				for (i in 0...4) FlxTween.color(game.opponentStrums.members[i], 0.2, FlxColor.WHITE, FlxColor.fromRGB(255, 17, 0));
			case "yoMute":
				FlxG.sound.music.volume = 0;
            	game.camGame.visible = game.camHUD.visible = false;
			case 'yofuck':
				game.isCameraOnForcedPos = true;
            	FlxTween.tween(game.camFollow, {x: (game.dad.getMidpoint().x + 150) + (game.dad.cameraPosition[0] + game.opponentCameraOffset[0]) - 30}, 4, {ease: FlxEase.sineInOut});

		}

	}
}