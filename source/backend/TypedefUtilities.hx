package backend;

typedef SongMetadata =
{
	var name:String;
	var week:Int;
	var character:String;
	var color:FlxColor;
	var composer:String;
	var difficultyRank:String;
	var textColor:FlxColor;
	//var discArt:String;
}

/**
 * Pause Menu Data
 */
 typedef PauseData =
 {
	 var settings:Array<Dynamic>;
 }

/**
 * Typedef used for Song Card Customization
 */
typedef SongCardData =
{
	// Font Settings
	var font:String;
	var fontSize:Array<Int>;
	var fontColor:Array<Float>;
	var fontScale:Array<Float>;
	var fontAlpha:Array<Float>;
	var fontAlignType:String;
	var fontOffset:Array<Float>;

	// Base Settings
	var customArt:String;
	var playerIcon:String;
	var opponentIcon:String;

	// Animation Settings
	var isAnimated:Bool;
	var animName:String;
	var animFramerate:Int;
	var isLooped:Bool;

	// Icon Settings
	var playerOffset:Array<Float>;
	var opponentOffset:Array<Float>;
	var playerScale:Array<Float>;
	var opponentScale:Array<Float>;
	var playerAlpha:Array<Float>;
	var opponentAlpha:Array<Float>;

	// Extra Settings
	var cardAlpha:Array<Float>;
	var cardScale:Array<Float>;
	var cardOffsets:Array<Float>;
	var isScreenCenter:Bool;

	// Tween Settings
	var tweenIn:String;
	var tweenOut:String;
	var cardMoveIntro:Array<Float>;
	var cardMoveOutro:Array<Float>;
	var playerMoveIntro:Array<Float>;
	var playerMoveOutro:Array<Float>;
	var oppMoveIntro:Array<Float>;
	var oppMoveOutro:Array<Float>;
	var fontMoveIntro:Array<Float>;
	var fontMoveOutro:Array<Float>;

	// Special FX Settings
	var cardShader:String;
	var playerShader:String;
	var opponentShader:String;
	var cardBlend:String;
	var playerBlend:String;
	var opponentBlend:String;
}

typedef FlashingSettings = 
{
	/**
	* The visiblity of your background you want it to flash at
	*/
	@:optional var alpha:Float;

	/**
	* How long you want the fade out transition to take
	*/
	@:optional var timer:Float;

	/**
	* Fade out transition easing
	*/
	@:optional var ease:(t:Float)->Float;

	/**
	 * The array of the color values (RGB)
	 */
	 @:optional var colors:Array<Int>;
}

// prob gonna keep jsons and then hardcode it cus thats pretty smart
typedef CharMenuThing = { info:Array<Dynamic> };