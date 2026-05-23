package funkin.backend;

import funkin.states.PlayState;

// do more wuith this
@:nullSafety
class Difficulty
{
	/**
	 * Constant list of the default Difficulties used by the game
	 */
	public static final defaultDifficulties:Array<String> = ['Easy', 'Normal', 'Hard'];
	
	/**
	 * Resets the currently loaded difficulties to `defaultDifficulties`
	 */
	public static inline function reset() return (difficulties = defaultDifficulties.copy());
	
	/**
	 * The considered default difficulty. Used to determine which difficulties chart shouldnt have a suffix
	 */
	public static var defaultDifficulty:String = 'Normal';
	
	/**
	 * Currently loaded list of difficulties 
	 */
	public static var difficulties:Array<String> = reset();
	
	/**
	 * Returns the difficulty suffix from an index in `Difficulty.difficulties`
	 */
	public static function getDifficultyFilePath(number:Int = -1):String
	{
		if (number == -1) number = PlayState.storyMeta.difficulty;
		
		var fileSuffix:Null<String> = difficulties[number];
		
		if (fileSuffix == null)
		{
			Logger.log('difficulty in index $number does not exist');
			return Paths.sanitize(defaultDifficulty);
		}
		
		return Paths.sanitize(fileSuffix);
	}
	
	/**
	 * Gets the current difficulty by string.
	 * @return String
	 */
	public static function getCurrentDifficultyString():String
	{
		return difficulties[PlayState.storyMeta.difficulty] ?? defaultDifficulty;
	}
}
