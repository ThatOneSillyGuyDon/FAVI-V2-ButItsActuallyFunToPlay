package backend.devPlugins;

import flixel.addons.transition.FlxTransitionableState;

/**
 * Plugin that allows easy state reloading
 * 
 * 
 * press F5 to reload the state
 * 
 * press F6 to reload and refresh memory
 */
@:nullSafety
class HotReloadPlugin extends FlxBasic
{
	static var instance:Null<HotReloadPlugin> = null;
	
	public static function init()
	{
		if (instance == null) FlxG.plugins.addPlugin(instance = new HotReloadPlugin());
	}
	
	public function new()
	{
		super();
		this.visible = false;
	}
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		
		if (FlxG.keys.justPressed.F5)
		{
			FlxG.resetState();
		}
		
		if (FlxG.keys.justPressed.F6)
		{
			FlxG.signals.preStateCreate.addOnce((state) -> {
				Paths.clearStoredMemory();
				Paths.clearUnusedMemory();
			});
			
			FlxG.resetState();
		}
	}
}
