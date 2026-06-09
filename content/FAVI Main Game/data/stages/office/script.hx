import openfl.filters.ShaderFilter;

var staticEffect = newShader('tvStatic');
var outline = newShader('darknessOutline');
var noteOutline = newShader('darknessOutline');
var funiLight;

function onLoad()
{
	outline.setFloat('thickness', 4.5);
	noteOutline.setFloat('thickness', 2.25);

	var office:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.image(PlayState.pathway + 'office'));
    var chair:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.image(PlayState.pathway + 'chair'));

	add(office);
	add(chair);

	office.scale.set(0.85, 0.8);
	chair.scale.set(0.9, 0.85);
}

function onCreatePost()
{
	funiLight = new FlxSprite(-500, -300).loadGraphic(Paths.image(PlayState.pathway + 'light'));
	funiLight.alpha = 0.6;
	funiLight.blend = 0;
	add(funiLight);
	funiLight.scale.set(0.85, 0.8);

	if (ClientPrefs.shaders && !ClientPrefs.lowQuality) camGame.filters = [new ShaderFilter(staticEffect)];
}

function onUpdate(elapsed)
{
	if (ClientPrefs.shaders)
	{
	    staticEffect.setFloat('uTime', shaderAnim);
		staticEffect.setFloat('iTime', shaderAnim);
	}
}

function onEvent(eventName, value1, value2)
{
	switch(eventName)
	{
		case "Trigger TG shader shi":
			switch (value1.toLowerCase())
			{
				case 'add':
					boyfriend.shader = outline;
					dad.shader = outline;
				case 'remove':
					boyfriend.shader = null;
					dad.shader = null;
				case 'addlight':
					funiLight.alpha = 0.6;
					camHUD.filters = [];
				case 'killlight':
					funiLight.alpha = 0.0001;
					camHUD.filters = [new ShaderFilter(noteOutline)];
			}			
		}
	}