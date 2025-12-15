package gameObjects.stages;

#if !flash 
import openfl.filters.ShaderFilter;
#end

class ForestOld extends BaseStage
{

	public static var grayScale:FlxRuntimeShader = new FlxRuntimeShader(Shaders.grayScale, null, 120);
	public static var blurShader:FlxRuntimeShader = new FlxRuntimeShader(Shaders.tiltShift, null, 120);
	public static var blurShaderHUD:FlxRuntimeShader = new FlxRuntimeShader(Shaders.tiltShift, null, 120);
	public static var andromeda:FlxRuntimeShader = new FlxRuntimeShader(Shaders.andromedaVCR, null, 140);

	public var shaderAnim:Float = 0;

	override function create()
	{
		PlayState.isGreyscale = true;

		var forest:FlxSprite = new FlxSprite(-180, -350).loadGraphic(Paths.image('favi/stages/forestOld/forest'));
		add(forest);
	}
	
	override function createPost()
	{
		game.dad.setPosition(0, 0);
    	game.boyfriend.setPosition(900, -20);
		game.gf.visible = false;
		
		if (ClientPrefs.data.shaders)
		{
			blurShader.setFloat('bluramount', 0.6);
			blurShaderHUD.setFloat('bluramount', 0.1);
			andromeda.setFloat('glitchModifier', 0.2);
			andromeda.setBool('perspectiveOn', true);
			andromeda.setBool('vignetteMoving', true);
			if (!ClientPrefs.data.lowQuality)
			{
				camGame.setFilters([
					new ShaderFilter(grayScale),
					new ShaderFilter(blurShader),
				]);
				camHUD.setFilters([
					new ShaderFilter(grayScale),
					new ShaderFilter(blurShaderHUD),
					new ShaderFilter(andromeda)
				]);
			}
			else
			{
				camGame.setFilters([new ShaderFilter(grayScale)]);
				camHUD.setFilters([new ShaderFilter(grayScale)]);
			}
		}
	}
}