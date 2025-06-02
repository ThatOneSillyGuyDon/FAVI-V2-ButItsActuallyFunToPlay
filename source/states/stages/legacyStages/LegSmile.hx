package states.stages.legacyStages;

#if !flash 
import openfl.filters.ShaderFilter;
#end

class LegSmile extends BaseStage
{
	public static var staticEffect:FlxRuntimeShader = new FlxRuntimeShader(Shaders.tvStatic, null, 120);

	public var shaderAnim:Float = 0;
	
	override function create()
	{
		game.defaultCamZoom = 0.9;
		game.cameraSpeed = 2;

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
		var funiLight:FlxSprite = new FlxSprite(-100, -100).loadGraphic(Paths.image(PlayState.pathway + 'officeLight'));
		funiLight.scale.set(1, 1);
		funiLight.updateHitbox();
		funiLight.antialiasing = true;
		funiLight.scrollFactor.set(1, 1);
		funiLight.alpha = 0.6;
		funiLight.blend = ADD;
		funiLight.active = false;
		add(funiLight);

		game.boyfriend.setPosition(1000, 300);
		game.dad.setPosition(200, 400);
		game.gf.visible = false;

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


	override function beatHit()
	{
		switch (curBeat)
		{
			case 62:
				FlxTween.tween(camGame, {alpha: 0}, 3, {ease: FlxEase.quartInOut});
				FlxTween.tween(camHUD, {alpha: 0}, 3, {ease: FlxEase.quartInOut});
			case 72:
				camGame.alpha = 1;
				if (ClientPrefs.data.flashing) camGame.flash(FlxColor.WHITE, 1.5);
				camHUD.alpha = 1;
			case 120 | 122 | 125 | 324 | 320 | 332 | 356 | 360 | 364: game.defaultCamZoom += 0.15;
			case 128: game.tweenCamera(0.9, 1, "sineInOut");
			case 156 | 400: game.defaultCamZoom += 0.35;
			case 159 | 308 | 340 | 376: game.defaultCamZoom = 0.9;
			case 160 | 228 | 404 | 472:
				game.defaultCamZoom = 0.9;
				game.camFlashSystem(BG_DARK, {alpha: 0, timer: 0.5, ease: FlxEase.quartOut});
				if (ClientPrefs.data.shaking)
				{
					camGame.shake(0.01, 24);
					camHUD.shake(0.004, 24);
				}
			case 224 | 468:
				game.camFlashSystem(BG_DARK, {alpha: 0.8, timer: 0.5, ease: FlxEase.quartOut});
				game.defaultCamZoom += 0.35;
			case 292: game.defaultCamZoom = 1.3;
			case 336: game.defaultCamZoom -= 0.1;
			case 536:
				if (ClientPrefs.data.flashing) camGame.flash(FlxColor.WHITE, 1.5);
				camHUD.visible = false;
			case 575: camGame.visible = false;
		}
	}
}