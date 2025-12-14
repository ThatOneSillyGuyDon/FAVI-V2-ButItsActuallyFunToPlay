package gameObjects.stages;

class FuckingLine extends BaseStage
{
	override function create()
	{
		var whiteVoid:FlxSprite = new FlxSprite().makeGraphic(FlxG.width * 5, FlxG.height * 5, FlxColor.WHITE);
		whiteVoid.screenCenter();
		add(whiteVoid);

		var line:FlxSprite = new FlxSprite(-80, 0).loadGraphic(Paths.image('favi/stages/fuckingLine/theLine'));
		line.scale.set(1.3, 1.3);
		add(line);
	}
	
	override public function createPost() 
	{
		game.dad.setPosition(-400, -150);
		game.boyfriend.setPosition(900, 300);
		game.gf.visible = false;
	}

	override function opponentNoteHit(note:Note)
	{
		boyfriend.x += 1.2;
		boyfriend.y -= 1.2;
		boyfriend.scale.x -= 0.0012;
		boyfriend.scale.y -= 0.0012;

		if (ClientPrefs.data.mechanics)
		{
			if(game.healthThing > 0.05) // trol
				game.healthThing -= 0.015;
		}
	}

	override function goodNoteHit(note:Note)
	{
		boyfriend.x -= 1.4;
		boyfriend.y += 1.4;
		boyfriend.scale.x += 0.0014;
		boyfriend.scale.y += 0.0014;
	}
}