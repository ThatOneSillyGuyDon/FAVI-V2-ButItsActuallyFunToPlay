import flixel.FlxSprite;

var defaultPath:String = 'data/stages/war/stuff';

function onCreate()
{
    PlayState.defaultCamZoom = .6;
    PlayState.cameraSpeed = .67;

    var sky = new FlxSprite(-1280 * PlayState.defaultCamZoom, -720 * PlayState.defaultCamZoom, Paths.image('sky', defaultPath));
    sky.scrollFactor.set(.07, .05);
    add(sky);

    var sun = new FlxSprite(-1280 * PlayState.defaultCamZoom, -720 * PlayState.defaultCamZoom, Paths.image('sun', defaultPath));
    sun.scrollFactor.set(.13, .09);
    add(sun);

    var bg = new FlxSprite(-1280 * PlayState.defaultCamZoom, -720 * PlayState.defaultCamZoom, Paths.image('bg', defaultPath));
    bg.scrollFactor.set(.32, .27);
    add(bg);

    var semibg = new FlxSprite(-1280 * PlayState.defaultCamZoom, -720 * PlayState.defaultCamZoom, Paths.image('semibackground', defaultPath));
    semibg.scrollFactor.set(.52, .48);
    semibg.scale.set(1.23, 1.23);
    semibg.updateHitbox();
    add(semibg);

    var things = new FlxSprite(-1280 * PlayState.defaultCamZoom, -720 * PlayState.defaultCamZoom, Paths.image('things', defaultPath));
    things.scrollFactor.set(.73, .64);
    things.scale.set(1.25, 1.25);
    things.updateHitbox();
    add(things);

    var ground = new FlxSprite(-1280 * PlayState.defaultCamZoom, -720 * PlayState.defaultCamZoom, Paths.image('ground', defaultPath));
    ground.scrollFactor.set(1, 1);
    ground.scale.set(1.35, 1.35);
    ground.updateHitbox();
    add(ground);

    spawnGirlfriend(false);
}

function charStagePos(boyfriend:Character, gf:Character, dad:Character, player3:Character)
{
    dad.setPosition(-140, 30);
    boyfriend.setPosition(1450, 650);
}