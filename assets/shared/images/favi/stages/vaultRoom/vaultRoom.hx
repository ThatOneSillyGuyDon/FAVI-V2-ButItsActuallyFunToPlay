var chains:FlxSprite;
var vault:FlxSprite;
var thingy:FlxSprite;
var chains2:FlxSprite;
var chains3:FlxSprite;
var light:FlxSprite;
var flair:FlxSprite;

var chainsI:FlxSprite;
var vaultI:FlxSprite;
var thingyI:FlxSprite;
var chainsI2:FlxSprite;
var chainsI3:FlxSprite;
var lightI:FlxSprite;
var flairI:FlxSprite;

var bloom:FlxRuntimeShader;
var chrom:FlxRuntimeShader;

function onCreate()
{
	spawnGirlfriend(false);

	vault = new FlxSprite(-200, -100).loadGraphic(Paths.image('vault', 'data/stages/vaultRoom/images'));
	vault.scale.set(2.45, 2.3);
	add(vault);
	chains = new FlxSprite(-225, -100).loadGraphic(Paths.image('chains1', 'data/stages/vaultRoom/images'));
	chains.scale.set(2.5, 2.3);
	chains.scrollFactor.set(1.2, 1.25);
	chains2 = new FlxSprite(-225, -100).loadGraphic(Paths.image('chains2', 'data/stages/vaultRoom/images'));
	chains2.scale.set(2.5, 2.3);
	chains2.scrollFactor.set(1.1, 1.2);
	chains3 = new FlxSprite(-225, -100).loadGraphic(Paths.image('chains3', 'data/stages/vaultRoom/images'));
	chains3.scale.set(2.5, 2.3);
	chains3.scrollFactor.set(1, 1.15);
	light = new FlxSprite(-200, -100).loadGraphic(Paths.image('lightSource', 'data/stages/vaultRoom/images'));
	light.blend = EngineTools.returnBlendMode("add");
	light.alpha = 0.1;
	light.scrollFactor.set(0.95, 1);
	light.scale.set(2.45, 2.3);
	flair = new FlxSprite(-200, -100).loadGraphic(Paths.image('lightFlair', 'data/stages/vaultRoom/images'));
	flair.blend = EngineTools.returnBlendMode("add");
	flair.alpha = 0.2;
	flair.scrollFactor.set(1.4, 1.25);
	flair.scale.set(2.5, 2.4);
	thingy = new FlxSprite(-200, -100).loadGraphic(Paths.image('darkness', 'data/stages/vaultRoom/images'));
	thingy.scale.set(2.45, 2.3);

	foreground.add(chains3);
	foreground.add(chains2);
	foreground.add(chains);
	foreground.add(light);
	foreground.add(flair);
	foreground.add(thingy);

	vaultI = new FlxSprite(-200, -100).loadGraphic(Paths.image('vaultInvert', 'data/stages/vaultRoom/images'));
	vaultI.scale.set(2.45, 2.3);
	vaultI.visible = false;
	add(vaultI);
	chainsI = new FlxSprite(-225, -100).loadGraphic(Paths.image('chainsI1', 'data/stages/vaultRoom/images'));
	chainsI.scale.set(2.5, 2.3);
	chainsI.scrollFactor.set(1.2, 1.25);
	chainsI.visible = false;
	chainsI2 = new FlxSprite(-225, -100).loadGraphic(Paths.image('chainsI2', 'data/stages/vaultRoom/images'));
	chainsI2.scale.set(2.5, 2.3);
	chainsI2.scrollFactor.set(1.1, 1.2);
	chainsI2.visible = false;
	chainsI3 = new FlxSprite(-225, -100).loadGraphic(Paths.image('chainsI3', 'data/stages/vaultRoom/images'));
	chainsI3.scale.set(2.5, 2.3);
	chainsI3.scrollFactor.set(1, 1.15);
	chainsI3.visible = false;
	lightI = new FlxSprite(-200, -100).loadGraphic(Paths.image('lightInvert', 'data/stages/vaultRoom/images'));
	lightI.blend = EngineTools.returnBlendMode("add");
	lightI.alpha = 0.1;
	lightI.scrollFactor.set(0.95, 1);
	lightI.scale.set(2.45, 2.3);
	flairI = new FlxSprite(-200, -100).loadGraphic(Paths.image('flairInvert', 'data/stages/vaultRoom/images'));
	flairI.blend = EngineTools.returnBlendMode("add");
	flairI.alpha = 0.2;
	flairI.scrollFactor.set(1.4, 1.25);
	flairI.scale.set(2.5, 2.4);
	thingyI = new FlxSprite(-200, -100).loadGraphic(Paths.image('brighter', 'data/stages/vaultRoom/images'));
	thingyI.scale.set(2.45, 2.3);
	thingyI.visible = false;

	foreground.add(chainsI3);
	foreground.add(chainsI2);
	foreground.add(chainsI);
	foreground.add(lightI);
	foreground.add(flairI);
	foreground.add(thingyI);
}

function onBeat(curBeat:Int, boyfriend:Character, gf:Character, dad:Character)
{
	if(curBeat == 544)
	{
		PlayState.camGame.flash("white", 3);
		/*PlayState.camGame.setFilters(
		[
			new ShaderFilter(bloom),
			new ShaderFilter(chrom)
		]);*/
		vault.visible = false;
		chains.visible = false;
		thingy.visible = false;
		chains2.visible = false;
		chains3.visible = false;
		light.visible = false;
		flair.visible = false;

		vaultI.visible = true;
		chainsI.visible = true;
		thingyI.visible = true;
		chainsI2.visible = true;
		chainsI3.visible = true;
		lightI.visible = true;
		flairI.visible = true;
	}

	if(curBeat == 608)
	{
		PlayState.camGame.flash("black", 3);
		PlayState.camGame.filtersEnabled = false;
		vault.visible = true;
		chains.visible = true;
		thingy.visible = true;
		chains2.visible = true;
		chains3.visible = true;
		light.visible = true;
		flair.visible = true;

		vaultI.visible = false;
		chainsI.visible = false;
		thingyI.visible = false;
		chainsI2.visible = false;
		chainsI3.visible = false;
		lightI.visible = false;
		flairI.visible = false;
	}
}

function charStagePos(boyfriend:Character, gf:Character, dad:Character)
{
    boyfriend.setPosition(960, 530);

	if (dad.curCharacter == 'white-noise-new') dad.setPosition(-680, -520); else dad.setPosition(90, 60);
}