package gameObjects.stages;

class War extends BaseStage
{
	//WAR DILEMMA
	var defaultPath:String = 'favi/stages/war/stuff/';
	
	override function create()
	{
		game.defaultCamZoom = .6;
		game.cameraSpeed = .67;
	
		var sky = new FlxSprite(-1280 * defaultCamZoom, -720 * defaultCamZoom, Paths.image(defaultPath + 'sky'));
		sky.scrollFactor.set(.07, .05);
		add(sky);
	
		if (!ClientPrefs.data.lowQuality)
		{
			var sun = new FlxSprite(-1280 * defaultCamZoom, -720 * defaultCamZoom, Paths.image(defaultPath + 'sun'));
			sun.scrollFactor.set(.22, .12);
			sun.y += 200;
			add(sun);
		
			var bg = new FlxSprite(-1280 * defaultCamZoom, -720 * defaultCamZoom, Paths.image(defaultPath + 'bg'));
			bg.scrollFactor.set(.32, .27);
			bg.x += 150;
			bg.y += 250;
			add(bg);
		
			var semibg = new FlxSprite(-1280 * defaultCamZoom, -720 * defaultCamZoom, Paths.image(defaultPath + 'semibackground'));
			semibg.scrollFactor.set(.52, .48);
			semibg.scale.set(1.23, 1.23);
			semibg.updateHitbox();
			add(semibg);
		}
	
		var things = new FlxSprite(-1280 * defaultCamZoom, (-720 * defaultCamZoom) + 150, Paths.image(defaultPath + 'things'));
		things.scrollFactor.set(.73, .64);
		things.scale.set(1.25, 1.25);
		things.updateHitbox();
		add(things);

		if (!ClientPrefs.data.lowQuality)
		{
			var grassBack = new FlxSprite(-1280 * defaultCamZoom, -720 * defaultCamZoom, Paths.image(defaultPath + "groundBack"));
			grassBack.scrollFactor.set(.86, .76);
			grassBack.scale.set(1.3, 1.3);
			grassBack.y += 70;
			grassBack.updateHitbox();
			add(grassBack);
		}
	
		var ground = new FlxSprite(-1280 * defaultCamZoom, -720 * defaultCamZoom, Paths.image(defaultPath + 'ground'));
		ground.scrollFactor.set(1, 1);
		ground.scale.set(1.35, 1.35);
		ground.updateHitbox();
		add(ground);

		if (!ClientPrefs.data.lowQuality)
		{
			var goofy = new FlxSprite(-1280 * defaultCamZoom, -720 * defaultCamZoom, Paths.image(defaultPath + "goofySpot"));
			goofy.scrollFactor.set(1, 1);
			goofy.scale.set(1.35, 1.35);
			goofy.updateHitbox();
			add(goofy);

			var mickey = new FlxSprite(-1280 * defaultCamZoom, -720 * defaultCamZoom, Paths.image(defaultPath + "mickeySpot"));
			mickey.scrollFactor.set(1, 1);
			mickey.scale.set(1.35, 1.35);
			mickey.updateHitbox();
			add(mickey);
		}
	}

	override function createPost()
	{	
		game.dad.setPosition(-140, 80);
   	 	game.boyfriend.setPosition(1500, 650);
		game.gf.visible = false;
		
		if (!ClientPrefs.data.lowQuality)
		{
			var fore = new FlxSprite(-1280 * defaultCamZoom, -720 * defaultCamZoom, Paths.image(defaultPath + "grassFore"));
			fore.scale.set(1.4, 1.4);
			fore.scrollFactor.set(1.15, 1.15);
			fore.y -= 180;
			fore.x -= 80;
			fore.updateHitbox();
			add(fore);
		}
	}
}