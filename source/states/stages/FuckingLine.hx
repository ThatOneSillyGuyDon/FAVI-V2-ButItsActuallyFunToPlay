package states.stages;

import states.stages.objects.*;

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
	
	override function createPost()
	{
		game.dad.setPosition(-400, -150);
		game.boyfriend.setPosition(900, 300);
		game.gf.visible = false;
	}
}