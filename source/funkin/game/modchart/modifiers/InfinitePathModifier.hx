package funkin.game.modchart.modifiers;

class InfinitePathModifier extends PathModifier
{
	public function new(modMgr:ModManager, prefix:String = 'infinite', ?parent:Modifier)
	{
		super(modMgr, prefix, parent);
	}
	
	override function getMoveSpeed()
	{
		return 1850;
	}
	
	override function getPath():Array<Array<Vector3>>
	{
		var infPath:Array<Vector3> = [];
		
		final step:Int = (ClientPrefs.lowQuality ? 15 : 3);
		
		var r = 0;
		while (r < 360)
		{
			var rad = r * Math.PI / 180;
			infPath.push(Vector3.get(FlxG.width * 0.5 + FlxMath.fastSin(rad) * 600, FlxG.height * 0.5 + FlxMath.fastSin(rad) * FlxMath.fastCos(rad) * 600, 0));
			
			r += step;
		}
		
		return [infPath];
	}
}
