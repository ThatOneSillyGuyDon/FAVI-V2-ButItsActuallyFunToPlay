package backend;

#if cpp
import cpp.vm.Gc;
#end

/**
 * `MemoryRate` is a class that turns the `mem` more accurate using CPP and `cpp.vm.Gc` functions
 */
#if windows
@:headerCode("
#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include <psapi.h>
")
@:unreflective
@:nativeGen
#end
class MemoryRate {
	#if windows
	@:functionCode('
    PROCESS_MEMORY_COUNTERS pmc;
    if( GetProcessMemoryInfo(GetCurrentProcess(), &pmc, sizeof(pmc)) )
        return (pmc.WorkingSetSize); // i hope Haxe can use this as an int :sob:
    else
        return 0;

    ')
	static function windowsObtainMemory():Dynamic
		return 0;

	public static function obtainMemory():Dynamic
	{
		var memory = windowsObtainMemory();
		if (memory == 0)
			return Gc.memInfo(Gc.MEM_INFO_CURRENT); // gets used memory, including uncollected garbage (should be more accurate than System.totalMemory?)

		return memory;
	}
	#else
	public static function obtainMemory():Dynamic
	{
		var memory = windowsObtainMemory();
		if (memory == 0)
		{
			#if cpp
			return Gc.memInfo(Gc.MEM_INFO_CURRENT); // gets used memory, including uncollected garbage (should be more accurate than System.totalMemory?)
			#else
			return System.totalMemory;
			#end
		}
		return memory;
	}
	#end

}