var wobblyBG:FlxRuntimeShader;
var shaderTime:Float = 0;

var treesFront:FNFSprite;
var goofyStreet:FNFSprite;
var treesBack:FNFSprite;
var goofyBG:FNFSprite;

function onCreate()
{
	// Literally what Goofy is seeing right about now lmfao
	wobblyBG = new FlxRuntimeShader(File.getContent("./assets/shaders/weebleWobble.frag"), null, 120);

	wobblyBG.setFloat('uSpeed', 1.0);
	wobblyBG.setFloat('uFrequency', 1.0);
	wobblyBG.setFloat('uWaveAmplitude', 0.5);

	spawnGirlfriend(false);
	PlayState.cameraSpeed = 0.9;
	PlayState.defaultCamZoom = 0.65;
	PlayState.skipCountdown = true;

	if(!lowQuality)
		{
			goofyBG = new FNFSprite(-600, -650).loadGraphic(Paths.image('bg', 'data/stages/forestNew/images'));
			goofyBG.scrollFactor.set(0.7, 0.7);
			goofyBG.scale.set(1.2, 1.2);
			goofyBG.screenCenter();
			add(goofyBG);
		}

	treesBack = new FNFSprite(-550, -650).loadGraphic(Paths.image('treesBack', 'data/stages/forestNew/images'));
	treesBack.scale.set(1.3, 1.2);
	treesBack.scrollFactor.set(1, 0.8);
	add(treesBack);

	goofyStreet = new FNFSprite(-700, -950).loadGraphic(Paths.image('ground', 'data/stages/forestNew/images'));
	goofyStreet.scale.set(2, 1.9);
	goofyStreet.scrollFactor.set(1, 1);
	add(goofyStreet);

	if(!lowQuality)
		{
			treesFront = new FNFSprite(-550, -650).loadGraphic(Paths.image('treesFront', 'data/stages/forestNew/images'));
			treesFront.scale.set(1.5, 1.5);
			treesFront.scrollFactor.set(1.2, 1.2);
			foreground.add(treesFront);
		}
}

function onBeat(curBeat:Int, boyfriend:Character, gf:Character, dad:Character)
{
	if (!Init.trueSettings.get('Disable Screen Shaders'))
		{
			if (curBeat == 192)
			{	
				if(!lowQuality && goofyBG != null && treesFront != null)
					{
						goofyBG.shader = wobblyBG;
						goofyStreet.shader = wobblyBG;
						treesBack.shader = wobblyBG;
						treesFront.shader = wobblyBG;
					}
			}
		}
		
	if (curBeat == 256)
		{
			if(!lowQuality && treesFront != null && goofyBG != null)
				{
					goofyBG.shader = null;
					goofyStreet.shader = null;
					treesBack.shader = null;
					treesFront.shader = null;
				}
		}
}

function onUpdate(elapsed:Float, boyfriend:Character, gf:Character, dad:Character)
{
	// Shader stuff
	shaderTime = Conductor.songPosition / 1000;
	wobblyBG.setFloat('uTime', shaderTime);
}

function charStagePos(boyfriend:Character, gf:Character, dad:Character)
{
	dad.setPosition(-320, 130);
	boyfriend.setPosition(850, 0);
}