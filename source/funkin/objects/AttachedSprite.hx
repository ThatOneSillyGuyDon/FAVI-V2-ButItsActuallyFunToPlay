package funkin.objects;

import flixel.FlxSprite;

@:nullSafety
class AttachedSprite extends FlxSprite
{
	public var sprTracker:Null<FlxSprite> = null;
	
	public var xAdd:Float = 0;
	public var yAdd:Float = 0;
	public var angleAdd:Float = 0;
	public var alphaMult:Float = 1;
	
	public var copyAngle:Bool = true;
	public var copyAlpha:Bool = true;
	public var copyVisible:Bool = false;
	
	public function new(?file:String, ?anim:String, ?library:String, loop:Bool = false)
	{
		super();
		if (anim != null)
		{
			@:nullSafety(Off)
			frames = Paths.getSparrowAtlas(file, library);
			animation.addByPrefix('idle', anim, 24, loop);
			animation.play('idle');
		}
		else if (file != null)
		{
			loadGraphic(Paths.image(file));
		}
		scrollFactor.set();
	}
	
	override function draw():Void
	{
		if (sprTracker != null)
		{
			setPosition(sprTracker.x + xAdd, sprTracker.y + yAdd);
			scrollFactor.copyFrom(sprTracker.scrollFactor);
			
			if (copyAngle) angle = sprTracker.angle + angleAdd;
			
			if (copyAlpha) alpha = sprTracker.alpha * alphaMult;
			
			if (copyVisible) visible = sprTracker.visible;
		}
		
		super.draw();
	}
	
	override function makeGraphic(width:Int, height:Int, color:FlxColor = FlxColor.WHITE, unique:Bool = false, ?key:String)
	{
		super.makeGraphic(width, height, color, unique, key);
		return this;
	}
}
