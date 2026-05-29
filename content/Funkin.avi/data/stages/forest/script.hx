import openfl.filters.ShaderFilter;

import flixel.addons.display.FlxTiledSprite;

var treesFront;
var street;
var treesBack;
var bushes;
var bg;
var path = "stages/forest/";
var chromZoomShader:FlxRuntimeShader = newShader('aberration');
var chromNormalShader:FlxRuntimeShader = newShader('aberrationDefault');
var dramaticCamMovement:FlxRuntimeShader = newShader('cameraMovement');
var monitorFilter:FlxRuntimeShader = newShader('monitorFilter');
var shaderAnim:Float = 0;

function onLoad()
{
	bg = new FlxTiledSprite(Paths.image(path + 'sky'), 3255, 850, true, false);
	treesBack = new FlxSprite().loadGraphic(Paths.image(path + 'treesBG'));
	bushes = new FlxSprite().loadGraphic(Paths.image(path + 'bushes'));
	street = new FlxSprite().loadGraphic(Paths.image(path + 'road'));
	treesFront = new FlxSprite().loadGraphic(Paths.image(path + 'treesFG'));
	
	for (i in [bg, treesBack, bushes, street])
		add(i);
}

function onCreatePost()
{
	for (i in [bg, treesBack, bushes, street, treesFront])
		i.scale.set(1.8, 1.6);
		
	bg.x -= 150;
	bg.y -= 500;
	treesFront.scale.x += .2;
	
	bg.scrollFactor.set(0.3, 0.3);
	treesBack.scrollFactor.set(0.65, 0.65);
	bushes.scrollFactor.set(0.9, 0.9);
	treesFront.scrollFactor.set(1.1, 1.1);
	
	add(treesFront);
	
	if (ClientPrefs.shaders)
	{
		if (!ClientPrefs.lowQuality)
		{
			camGame.filters = [
				new ShaderFilter(dramaticCamMovement),
				new ShaderFilter(monitorFilter),
				new ShaderFilter(chromZoomShader),
				new ShaderFilter(chromNormalShader)
			];
			camHUD.filters = [new ShaderFilter(chromNormalShader)];
		}
		else
		{
			camGame.filters = [
				new ShaderFilter(monitorFilter),
				new ShaderFilter(chromNormalShader)
			];
			camHUD.filters = [new ShaderFilter(chromNormalShader)];
		}
	}
}

function onUpdate(elapsed)
{
	if (bg != null) bg.scrollX -= FlxG.elapsed * 52;
	
	if (ClientPrefs.shaders)
	{
		shaderAnim = Conductor.songPosition / 1000;
		
		chromZoomShader.setFloat('aberration', 0.0001);
		chromZoomShader.setFloat('effectTime', 0.0001);
		chromNormalShader.setFloat('rOffset', 0.0001 / 45);
		chromNormalShader.setFloat('bOffset', -0.0001 / 45);
		dramaticCamMovement.setFloat('time', shaderAnim);
	}
}
