package funkin.game.modchart;

interface IModNote
{
	public var animation:flixel.animation.FlxAnimationController;
	
	public var animOffsets(default, null):Map<String, Array<Float>>;
	
	public var spriteOffset(default, null):FlxPoint;
	public var animOffset(default, null):FlxPoint;
	public var offset(default, null):FlxPoint;
	
	public var baseScale(default, null):FlxPoint;
	public var scale(default, null):FlxPoint;
	
	public var noteData:Int;
}
