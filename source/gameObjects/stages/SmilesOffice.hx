package gameObjects.stages;

#if !flash 
import openfl.filters.ShaderFilter;
#end

class SmilesOffice extends BaseStage
{
	public static var staticEffect:FlxRuntimeShader = new FlxRuntimeShader(Shaders.tvStatic, null, 120);

	public var shaderAnim:Float = 0;
	
	override function create()
	{
		game.defaultCamZoom = 0.9;
		game.cameraSpeed = 2;
		PlayState.isGreyscale = true;

		var office:FlxSprite = new FlxSprite(-100, -100).loadGraphic(Paths.image(PlayState.pathway + 'office'));
		office.scale.set(1, 1);
		office.updateHitbox();
		office.antialiasing = true;
		office.scrollFactor.set(1, 1);
		office.active = false;
		add(office);
	}

	override function createPost()
	{
		game.boyfriend.setPosition(1000, 300);
		game.dad.setPosition(200, 400);
		game.gf.visible = false;
		
		var funiLight:FlxSprite = new FlxSprite(-100, -100).loadGraphic(Paths.image(PlayState.pathway + 'officeLight'));
		funiLight.scale.set(1, 1);
		funiLight.updateHitbox();
		funiLight.antialiasing = true;
		funiLight.scrollFactor.set(1, 1);
		funiLight.alpha = 0.6;
		funiLight.blend = ADD;
		funiLight.active = false;
		add(funiLight);

		if (ClientPrefs.data.shaders && !ClientPrefs.data.lowQuality)
		{
			camGame.setFilters([
				new ShaderFilter(staticEffect)
			]);
		}
	}

	override function update(elapsed:Float)
	{
		shaderAnim = Conductor.songPosition / 1000;
		
		if (ClientPrefs.data.shaders && !ClientPrefs.data.lowQuality)
		{
			staticEffect.setFloat('uTime', shaderAnim);
			staticEffect.setFloat('iTime', shaderAnim);
		}
	}
}