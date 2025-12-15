package gameObjects.stages;

#if !flash 
import openfl.filters.ShaderFilter;
#end
import shaders.OutlineEffect;

class TrueGrinsOfSins extends BaseStage
{
	var staticEffect:FlxRuntimeShader = new FlxRuntimeShader(Shaders.tvStatic, null, 120);

	var outline:OutlineEffect = new OutlineEffect();
	var noteOutline:OutlineEffect = new OutlineEffect();

	public var shaderAnim:Float = 0;

	var funiLight:FlxSprite;

	override function create()
	{
		game.spawnShadow[0] = game.spawnShadow[1] = true;
		game.defaultCamZoom = 0.75;
		game.cameraSpeed = 2.5;
		PlayState.isGreyscale = true;

		outline.thickness = 4.5;
		noteOutline.thickness = 2.25;

		var office:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.image(PlayState.pathway + 'office'));
		office.antialiasing = true;
		office.scrollFactor.set(1, 1);
		office.active = false;
		add(office);

		var chair:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.image(PlayState.pathway + 'chair'));
		chair.antialiasing = true;
		chair.scrollFactor.set(1, 1);
		chair.active = false;
		add(chair);

		office.scale.set(0.85, 0.8);
		chair.scale.set(0.9, 0.85);
	}

	override function createPost()
	{
		game.boyfriend.setPosition(1300, 400);
		game.dad.setPosition(0, 0);
		game.gf.setPosition(1100, 560);
		
		funiLight = new FlxSprite(-500, -300).loadGraphic(Paths.image(PlayState.pathway + 'light'));
		funiLight.antialiasing = true;
		funiLight.scrollFactor.set(1, 1);
		funiLight.alpha = 0.6;
		funiLight.blend = ADD;
		funiLight.active = false;
		add(funiLight);
		funiLight.scale.set(0.85, 0.8);

		if (ClientPrefs.data.shaders)
		{
			if (!ClientPrefs.data.lowQuality)
			{
				camGame.setFilters([
					new ShaderFilter(staticEffect)
				]);
			}
		}
	}

	override function update(elapsed:Float)
	{
		shaderAnim = Conductor.songPosition / 1000;
		
		if (ClientPrefs.data.shaders)
		{
			staticEffect.setFloat('uTime', shaderAnim);
			staticEffect.setFloat('iTime', shaderAnim);
		}
	}

	var skyTwn:FlxTween;
	// For events
	override function eventCalled(eventName:String, value1:String, value2:String, flValue1:Null<Float>, flValue2:Null<Float>, strumTime:Float)
	{
		switch(eventName)
		{
			case "Trigger TG shader shi":
				switch (value1.toLowerCase())
				{
					case 'add':
						game.boyfriend.shader = outline.shader;
						game.dad.shader = outline.shader;
					case 'remove':
						game.boyfriend.shader = null;
						game.dad.shader = null;	
					case 'addlight':
						funiLight.alpha = 0.6;
						camHUD.setFilters([]);
					case 'killlight':
						funiLight.alpha = 0.0001;
						camHUD.setFilters([new ShaderFilter(noteOutline.shader)]);
				}
				
		}
	}
}