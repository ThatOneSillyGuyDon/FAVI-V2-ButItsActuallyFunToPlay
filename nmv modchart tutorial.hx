// this script file is to be used as a template of how the modchart system works on Nightmare Vision.
// this will go over pretty much everything you'll need to know to use this thing.
// list of quite literally every single modifier you can use. this list can be expanded by making your own modifier scripts
// in your mod folder's scripts folder through "modifiers/yourModName.hx"
/*  Modifier Names:
	- boost
	- wave
	- brake
	- stealth
	- hidden
	- hiddenOffset
	- stealthPastReceptors
	- sudden
	- suddenOffset
	- blink
	- randomVanish
	- alpha
	- alpha + note.noteData (basically, alpha0, alpha1, alpha2, alpha3, same logic can be applied to every other modifier that does this)
	- sustainSplashAlpha
	- sustainSplashAlpha + note.noteData
	- noteSplashAlpha
	- noteSplashAlpha + note.noteData
	- noteAlpha
	- noteAlpha + note.noteData
	- dark
	- dark + note.noteData
	- useStealthGlow
	- dontUseStealthGlow
	- beat
	- confusion
	- confusion + note.noteData
	- noteAngle
	- note + note.noteData + Angle
	- receptorAngle
	- receptor + note.noteData + Angle
	- drunk
	- drunkSpeed
	- drunkOffset
	- drunkPeriod
	- tipsy
	- tipsySpeed
	- tispyOffset
	- bumpy
	- bumpySpeed
	- bumpyOffset
	- tipZ
	- tipZSpeed
	- tipZOffset
	- drunkZ
	- drunkZSpeed
	- drunkZOffset
	- drunkZPeriod
	- flip
	- infinite
	- invert
	- rotateX
	- rotate + note.noteData + X
	- rotateY
	- rotate + note.noteData + Y
	- rotateZ
	- rotate + note.noteData + Z
	- opponentSwap
	- basePath
	- basePathvisual
	- basePathspeed
	- receptorScroll
	- reverse
	- reverse + note.noteData
	- cross
	- split
	- alternate
	- reverseScroll
	- crossScroll
	- splitScroll
	- alternateScroll
	- centered
	- unboundedReverse
	- mini
	- miniX
	- mini + note.noteData + X
	- miniY
	- mini + note.noteData + Y
	- squish
	- squish + note.noteData
	- stretch
	- stretch + note.noteData
	- receptorScaleX
	- receptor + note.noteData + ScaleX
	- receptorScaleY
	- receptor + note.noteData + ScaleY
	- noteScaleX
	- note + note.noteData + ScaleX
	- noteScaleY
	- note + note.noteData + ScaleY
	- noteSplashScaleX
	- noteSplash + note.noteData + ScaleX
	- noteSplashScaleY
	- noteSplash + note.noteData + ScaleY
	- sustainSplashScaleX
	- sustainSplash + note.noteData + ScaleX
	- sustainSplashScaleY
	- sustainSplash + note.noteData + "caleY
	- transformX
	- transform + note.noteData + X
	- transformY
	- transform + note.noteData + Y
	- transformZ
	- transform + note.noteData + Z
	- transformX-a
	- transform  note.noteData + X-a
	- transformY-a
	- transform + note.noteData + Y-a
	- transformZ-a
	- transform + note.noteData + Z-a
	- xmod
	- xmod + note.noteData
 */
// stole this function from the d-sides endless modchart lmao
//
// numericForInterval() is basically what allows you to repeat a sequence of events without
// copy+pasting it all over the script, thank you DuskieWhy for this function.
//
// start = curStep value it starts
//
// end = curStep value it stops
//
// interval = how many step hits in between loops to repeat events
//
// func = your code for sequence of events it will loop in between intervals
function numericForInterval(start, end, interval, func)
{
	var index = start;
	while (index < end)
	{
		func(index);
		index += interval;
	}
}

function onCreatePost()
{
	if (ClientPrefs.modcharts) loadModchart();
}

function loadModchart()
{
	// modManager is your only and primary tool for basically everything here.
	
	// queueSet(curStep, modName, value, player)
	//
	// is the most basic function. It sets a mod to a specific value at a specific time by curStep hit.
	// The value will be applied instantly at the time you set it to,
	// and will stay that way until you change it again with another queueSet or queueEase.
	//
	// curStep = the step at which to apply your mod
	//
	// modName = the name of the mod you want to apply. You can find a list of all mods and their names in
	// source/funkin/game/modchart/modifiers (you can also use submod names and custom mod scripts as well)
	//
	// value = the value you want to set the mod to.
	//
	// player = 0 for player notes, 1 for opponent notes, -1 for both
	// If you don't specify this, it will default to -1.
	
	modManager.queueSet(12, "drunk", 4);
	
	// queueEase(curStep, endCurStep, modName, value, easing, player)
	//
	// it's just queueSet but with an end time and an easing type. Nothing special.
	//
	// curStep = ditto of queueSet
	//
	// endCurStep = the step at which to finish the tween. The mod will be fully applied at this step.
	//
	// modName = ditto of queueSet
	//
	// value = ditto of queueSet
	//
	// easing = the type of easing to apply. You know the deal.
	//
	// player = ditto of queueSet
	
	modManager.queueEase(16, 32, "drunkSpeed", 0, 'expoOut');
	
	// setValue(modName, value, player)
	//
	// This is basically an instant version of queueSet. It applies the mod immediately at the start of the song.
	
	modManager.setValue("tipsy", -0.1);
	
	// updateTimeline(curStep)
	//
	// This is used to update the modchart timeline. Not really needed, but it's there
	// if you need to fix something later.
	
	modManager.updateTimeline(64);
	
	// queueEaseP(curStep, endCurStep, modName, percent, easing, player)
	//
	// This is a special function that eases a mod by a percentage of its current value instead of to a specific value.
	// That's it really, it's basically if you wanna get fancy.
	
	modManager.queueEaseP(48, 64, "alpha", 35, 'expoOut');
	
	// queueSetP(curStep, modName, percent, player)
	//
	// basically the same thing as queueEaseP but for queueSet.
	
	modManager.queueSetP(80, "tipsyOffset", 80);
	
	// getPos(curStep, diff, tDiff, beat, data, player, obj, exclusions, pos)
	//
	// not even gonna bother explaining this one, good luck, why don't you try looking at the source code
	// and see if you can understand it, because I certainly don't.
	
	modManager.getPos(128, 2, 6, 16, 1, -1, null, ["what?", "why?"], null);
}
