package backend;

/**
 * An extension of `flixel.text.FlxText` which adds content from `Alphabet`
 */
class FlxTextAlphabet extends FlxText 
{
    public var targetY:Float = 0;
    public var isMenuItem:Bool = false;
    public var changeX:Bool = true;
    public var changeY:Bool = true;

    public var distancePerItem:FlxPoint = new FlxPoint(20, 120);
	public var startPosition:FlxPoint = new FlxPoint(0, 0); //for the calculations

    /**
	 * Creates a new `FlxText` object at the specified position.
	 *
	 * @param   X              The x position of the text.
	 * @param   Y              The y position of the text.
	 * @param   FieldWidth     The `width` of the text object. Enables `autoSize` if `<= 0`.
	 *                         (`height` is determined automatically).
	 * @param   Text           The actual text you would like to display initially.
	 * @param   Size           The font size for this text object.
	 * @param   EmbeddedFont   Whether this text field uses embedded fonts or not.
	 */
    public function new(X:Float = 0, Y:Float = 0, FieldWidth:Float = 0, ?Text:String, Size:Int = 8, EmbeddedFont:Bool = true)
    {
        super(X, Y, FieldWidth, Text, Size, EmbeddedFont);

        this.startPosition.x = X;
        this.startPosition.y = Y;
    }

    public function snapToPosition()
    {
        if (isMenuItem)
        {
            if(changeX)
                x = (targetY * distancePerItem.x) + startPosition.x;
            if(changeY)
                y = (targetY * 1.3 * distancePerItem.y) + startPosition.y;
        }
    }

    public var changeLerp:Bool = false;
    public var lerpVal:Float = 0;
    override function update(elapsed:Float)
    {
        if (!changeLerp) lerpVal = CoolUtil.boundTo(elapsed * 9.6, 0, 1);
        if (isMenuItem)
        {
            if(changeX)
                x = FlxMath.lerp(x, (targetY * distancePerItem.x) + startPosition.x, lerpVal);
            if(changeY)
                y = FlxMath.lerp(y, (targetY * 1.3 * distancePerItem.y) + startPosition.y, lerpVal);
        }
        super.update(elapsed);
    }
}