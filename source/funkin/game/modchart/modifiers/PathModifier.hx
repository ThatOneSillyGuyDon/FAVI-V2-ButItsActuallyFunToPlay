package funkin.game.modchart.modifiers;

@:structInit
class PathInfo
{
	public var position:Vector3;
	public var dist:Float;
	public var start:Float;
	public var end:Float;
}

class PathModifier extends NoteModifier
{
	var prefix:String;
	
	var moveSpeed:Float;
	var pathData:Array<Array<PathInfo>> = [];
	var totalDists:Array<Float> = [];
	
	override function getName() return prefix;
	
	public function getMoveSpeed()
	{
		return 5000;
	}
	
	public function getPath():Array<Array<Vector3>>
	{
		return [];
	}
	
	public function tracePath(path:Array<Array<Vector3>>):Void
	{
		pathData.resize(0);
		totalDists.resize(0);
		
		for (dir in 0 ... path.length)
		{
			totalDists[dir] = 0;
			pathData[dir] = [];
			
			for (idx in 0 ... path[dir].length)
			{
				final pos = path[dir][idx];
				
				if (idx > 0)
				{
					final last = pathData[dir][idx - 1];
					final totalDist = (totalDists[dir] += Vector3.distance(last.position, pos));
					
					last.end = totalDist;
					last.dist = last.start - totalDist; // used for interpolation
				}
				
				pathData[dir].push(
					{
						position: pos,
						start: totalDists[dir],
						end: totalDists[dir],
						dist: 0
					});
			}
		}
	}
	
	public function new(modMgr:ModManager, prefix:String = 'basePath', ?parent:Modifier)
	{	
		this.prefix = prefix;
		
		super(modMgr, parent);
		
		moveSpeed = getMoveSpeed();
		
		tracePath(getPath());
	}
	
	override function getPos(time:Float, visualDiff:Float, timeDiff:Float, beat:Float, pos:Vector3, data:Int, player:Int, obj:FlxSprite)
	{
		if (getValue(player) == 0 || pathData.length == 0) return pos;
		
		final daPath = pathData[data % pathData.length], totalDist = totalDists[data % totalDists.length];
		
		final prefix:String = getName();
		
		final moveSpeed:Float = (moveSpeed * (1 - getSubmodValue('${prefix}speed', player)));
		
		final progress = ((getSubmodValue('${prefix}visual', player) > 0 ? visualDiff : timeDiff) / moveSpeed * totalDist);
		final clampProgress = FlxMath.bound(progress, 0, totalDist);
		
		for (idx in 0 ... daPath.length - 1)
		{
			final cData = daPath[idx], nData = daPath[idx + 1];
			
			if (clampProgress >= cData.start && clampProgress <= cData.end)
			{
				final alpha = ((cData.start - progress) / cData.dist);
				final interpPos:Vector3 = cData.position.lerp(nData.position, alpha);
				
				return pos.lerp(interpPos, getValue(player));
			}
		}
		
		if (daPath.length == 0) return pos;
		
		return pos.lerp(daPath[0].position, getValue(player));
	}
	
	override function getSubmods()
	{
		final prefix:String = getName();
		
		return ['${prefix}visual', '${prefix}speed'];
	}
}
