function onCreate()
{
	spawnGirlfriend(false);

	var whiteVoid:FlxSprite = new FlxSprite().makeGraphic(FlxG.width * 5, FlxG.height * 5, EngineTools.returnColor('white'));
	whiteVoid.screenCenter();
	add(whiteVoid);

	var line:FlxSprite = new FlxSprite(-80, 0).loadGraphic(Paths.image('theLine', 'data/stages/fuckingLine'));
	line.scale.set(1.3, 1.3);
	add(line);
}

function charStagePos(boyfriend:Character, gf:Character, dad:Character)
{
	dad.setPosition(-400, -150);
	boyfriend.setPosition(900, 300);
}