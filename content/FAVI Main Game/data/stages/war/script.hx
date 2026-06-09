
var defaultPath:String = 'stages/war/';
var sky;
var sun;
var bg;
var semibg;
var things;
var grassBack;
var ground;
var goofy;
var mickey;
var fore;
	
function onLoad()
{	
    defaultCamZoom = .6;
	cameraSpeed = .68;

	sky = new FlxSprite(-1280 * defaultCamZoom, -720 * defaultCamZoom, Paths.image(defaultPath + 'sky'));
    things = new FlxSprite(-1280 * defaultCamZoom, (-720 * defaultCamZoom) + 150, Paths.image(defaultPath + 'things'));
    ground = new FlxSprite(-1280 * defaultCamZoom, -720 * defaultCamZoom, Paths.image(defaultPath + 'ground'));

	sky.scrollFactor.set(.07, .05);
    things.scrollFactor.set(.73, .64);

    things.scale.set(1.25, 1.25);
    ground.scale.set(1.35, 1.35);

    things.updateHitbox();
	ground.updateHitbox();
	
    add(sky);

	if (!ClientPrefs.lowQuality)
	{
		sun = new FlxSprite(-1280 * defaultCamZoom, -720 * defaultCamZoom, Paths.image(defaultPath + 'sun'));
        bg = new FlxSprite(-1280 * defaultCamZoom, -720 * defaultCamZoom, Paths.image(defaultPath + 'bg'));
        semibg = new FlxSprite(-1280 * defaultCamZoom, -720 * defaultCamZoom, Paths.image(defaultPath + 'semibackground'));
        grassBack = new FlxSprite(-1280 * defaultCamZoom, -720 * defaultCamZoom, Paths.image(defaultPath + "groundBack"));
        goofy = new FlxSprite(-1280 * defaultCamZoom, -720 * defaultCamZoom, Paths.image(defaultPath + "goofySpot"));
        mickey = new FlxSprite(-1280 * defaultCamZoom, -720 * defaultCamZoom, Paths.image(defaultPath + "mickeySpot"));
        fore = new FlxSprite(-1280 * defaultCamZoom, -720 * defaultCamZoom, Paths.image(defaultPath + "grassFore"));

		sun.scrollFactor.set(.22, .12);
        bg.scrollFactor.set(.32, .27);
        semibg.scrollFactor.set(.52, .48);
        grassBack.scrollFactor.set(.86, .76);
        goofy.scrollFactor.set(1, 1);
        mickey.scrollFactor.set(1, 1);
        fore.scrollFactor.set(1.15, 1.15);

        semibg.scale.set(1.23, 1.23);
        grassBack.scale.set(1.3, 1.3);
        goofy.scale.set(1.35, 1.35);
        mickey.scale.set(1.35, 1.35);
        fore.scale.set(1.4, 1.4);

        semibg.updateHitbox();
        grassBack.updateHitbox();
        goofy.updateHitbox();
        mickey.updateHitbox();
        fore.updateHitbox();

		sun.y += 200;
		grassBack.y += 70;
		bg.x += 150;
		bg.y += 250;
        fore.y -= 180;
		fore.x -= 80;

        add(sun);
		add(bg);
		add(semibg);
	}

	add(things);
	if (!ClientPrefs.lowQuality) add(grassBack);
	add(ground);

	if (!ClientPrefs.lowQuality)
	{
		add(goofy);
		add(mickey);
	}
}

function onCreatePost() if (!ClientPrefs.lowQuality) add(fore);