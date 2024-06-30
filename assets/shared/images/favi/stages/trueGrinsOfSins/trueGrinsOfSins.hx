var staticS:FlxRuntimeShader;
var greyScale:FlxRuntimeShader;
var monitor:FlxRuntimeShader;

var shaderTime:Float = 0;

function onCreate()
{
	spawnGirlfriend(false);
	PlayState.defaultCamZoom = 0.75;
	PlayState.cameraSpeed = 2.5;

	staticS = new FlxRuntimeShader(File.getContent('./assets/shaders/tvStatic.frag'), null, 120);
	greyScale = new FlxRuntimeShader(File.getContent('./assets/shaders/grayScale.frag'), null, 120);
	monitor = new FlxRuntimeShader(Shaders.monitorFilter, null, 140);

	PlayState.camGame.setFilters(
		[
			new ShaderFilter(greyScale),
			new ShaderFilter(staticS),
			new ShaderFilter(monitor)
		]);

	var office:FNFSprite = new FNFSprite(-500, -300).loadGraphic(Paths.image('office', 'data/stages/trueGrinsOfSins/images'));
	office.antialiasing = true;
	office.scrollFactor.set(1, 1);
	office.active = false;
	add(office);

    var chair:FNFSprite = new FNFSprite(-500, -300).loadGraphic(Paths.image('chair', 'data/stages/trueGrinsOfSins/images'));
    chair.antialiasing = true;
    chair.scrollFactor.set(1, 1);
    chair.active = false;
    add(chair);

	var funiLight:FNFSprite = new FNFSprite(-500, -300).loadGraphic(Paths.image('light', 'data/stages/trueGrinsOfSins/images'));
	funiLight.antialiasing = true;
	funiLight.scrollFactor.set(1, 1);
	funiLight.alpha = 0.6;
	funiLight.blend = EngineTools.returnBlendMode("add");
	funiLight.active = false;
	foreground.add(funiLight);

    office.scale.set(0.85, 0.8);
    chair.scale.set(0.9, 0.85);
    funiLight.scale.set(0.85, 0.8);
}

function onUpdate(elapsed:Float, boyfriend:Character, gf:Character, dad:Character)
	{
			//Shader stuff
			shaderTime = Conductor.songPosition / 1000;
			staticS.setFloat('uTime', shaderTime);
			staticS.setFloat('iTime', shaderTime);
	}

function charStagePos(boyfriend:Character, gf:Character, dad:Character)
{
	boyfriend.setPosition(1300, 400);
	dad.setPosition(0, 0);
}


	
