function onCreate()
{
	spawnGirlfriend(true);
	PlayState.defaultCamZoom = 1.25;
	PlayState.cameraSpeed = 50;

	var clubhouse:FlxSprite = new FlxSprite(-410, -100);
	clubhouse.frames = Paths.getSparrowAtlas('daHouse', 'data/stages/clubhouse/images');
	clubhouse.animation.addByPrefix('balloons bounce', 'daHouse idle', 12, true);
	clubhouse.animation.play('balloons bounce');
	clubhouse.scale.set(1.15, 1.15);
	clubhouse.updateHitbox();
	clubhouse.antialiasing = true;
	clubhouse.scrollFactor.set(1, 1);
	add(clubhouse);

	var vignette:FNFSprite = new FNFSprite(-250, -140).loadGraphic(Paths.image('vignetteOverlay', 'data/stages/clubhouse/images'));
	vignette.cameras = [PlayState.camAlt];
	vignette.scale.set(0.75, 0.75);
	vignette.antialiasing = true;
	vignette.scrollFactor();
	vignette.active = false;
	add(vignette);
}

function charStagePos(boyfriend:Character, gf:Character, dad:Character)
{
	switch (dad.curCharacter)
	{
		case 'munpet':
			dad.setPosition(-240, 0);
		default:
			dad.setPosition(-240, -260);
	}
	switch (boyfriend.curCharacter)
	{
		case 'xyloboy':
			boyfriend.setPosition(650, -100);
		default:
			boyfriend.setPosition(650, -360);
	}
	gf.setPosition(280, -410);
}
	
