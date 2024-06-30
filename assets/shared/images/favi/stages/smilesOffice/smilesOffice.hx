var staticS:FlxRuntimeShader;
var greyScale:FlxRuntimeShader;
var monitor:FlxRuntimeShader;

var shaderTime:Float = 0;

function onCreate()
{
	spawnGirlfriend(false);
	PlayState.defaultCamZoom = 0.9;
	PlayState.cameraSpeed = 2;

	staticS = new FlxRuntimeShader(File.getContent('./assets/shaders/tvStatic.frag'), null, 120);
	greyScale = new FlxRuntimeShader(File.getContent('./assets/shaders/grayScale.frag'), null, 120);
	monitor = new FlxRuntimeShader(Shaders.monitorFilter, null, 140);

	PlayState.camGame.setFilters(
		[
			new ShaderFilter(greyScale),
			new ShaderFilter(staticS),
			new ShaderFilter(monitor)
		]);

	var office:FNFSprite = new FNFSprite(-100, -100).loadGraphic(Paths.image('office', 'data/stages/smilesOffice/images'));
	office.scale.set(1, 1);
	office.updateHitbox();
	office.antialiasing = true;
	office.scrollFactor.set(1, 1);
	office.active = false;
	add(office);

	var funiLight:FNFSprite = new FNFSprite(-100, -100).loadGraphic(Paths.image('officeLight', 'data/stages/smilesOffice/images'));
	funiLight.scale.set(1, 1);
	funiLight.updateHitbox();
	funiLight.antialiasing = true;
	funiLight.scrollFactor.set(1, 1);
	funiLight.alpha = 0.6;
	funiLight.blend = "add";
	funiLight.active = false;
	foreground.add(funiLight);
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
	boyfriend.setPosition(1000, 300);
	dad.setPosition(200, 400);
}


	
