package gameObjects.stages;

class JoyGrim extends BaseStage
{
	public var offsetTwn:FlxTween;

	override function create()
	{
		game.defaultCamZoom = 0.75;
		game.cameraSpeed = 1.2;
		PlayState.isGreyscale = false;

		// you may wonder why i did like that.. simple, PATHS IMAGES DIDNT WANT TO LOAD CORRECTLY ! 
		var clubhouse:FlxSprite = new FlxSprite(-770, -650).loadGraphic('assets/shared/images/favi/stages/clubhouse/images/clubhouse.png');
		add(clubhouse);
		clubhouse.scale.set(1.4,1.4);
	}

	override function update(elapsed:Float)
	{
		game.dad.setPosition(-140, 20);
		game.boyfriend.setPosition(650, -260);
		game.gf.setPosition(280, -410);

		super.update(elapsed);
	}

	override function createPost()
	{
	}
}