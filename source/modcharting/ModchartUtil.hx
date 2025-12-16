package modcharting;

import flixel.tweens.FlxEase;
import flixel.math.FlxMath;
import flixel.math.FlxAngle;
import openfl.geom.Vector3D;
import flixel.FlxG;

import states.PlayState;
import gameObjects.ui.notes.Note;

using StringTools;

class ModchartUtil
{
    public static function getDownscroll(instance:MusicBeatState)
    {
        return ClientPrefs.data.downScroll;
    }
    public static function getMiddlescroll(instance:MusicBeatState)
    {
        return ClientPrefs.data.middleScroll;
    }
    public static function getScrollSpeed(instance:PlayState)
    {
        if (instance == null)
            return PlayState.SONG.speed;

        return instance.songSpeed;
    }

    public static function getIsPixelStage(instance:MusicBeatState)
    {
        if (instance == null)
            return false;
        
        return PlayState.isPixelStage;
    }

    public static function getNoteOffsetX(daNote:Note, instance:MusicBeatState)
    {
        return daNote.offsetX;
    }

    static var currentFakeCrochet:Float = -1;
    static var lastBpm:Float = -1;

    public static function getFakeCrochet()
    {
        if (PlayState.SONG.bpm != lastBpm)
        {
            currentFakeCrochet = (60 / PlayState.SONG.bpm) * 1000; //only need to calculate once
            lastBpm = PlayState.SONG.bpm;
        }
        return currentFakeCrochet;
            
    }

    public static var zNear:Float = 0;
    public static var zFar:Float = 100;
    public static var defaultFOV:Float = 90;

    /**
        Converts a Vector3D to its in world coordinates using perspective math
    **/
    public static function calculatePerspective(pos:Vector3D, FOV:Float, offsetX:Float = 0, offsetY:Float = 0)
    {

        /* math from opengl lol
            found from this website https://ogldev.org/www/tutorial12/tutorial12.html
        */

        //TODO: maybe try using actual matrix???

        var newz = pos.z - 1;
        var zRange = zNear - zFar;
        var tanHalfFOV = FlxMath.fastSin(FOV*0.5)/FlxMath.fastCos(FOV*0.5); //faster tan
        if (pos.z > 1) //if above 1000 z basically
            newz = 0; //should stop weird mirroring with high z values

        //var m00 = 1/(tanHalfFOV);
        //var m11 = 1/tanHalfFOV;
        //var m22 = (-zNear - zFar) / zRange; //isnt this just 1 lol
        //var m23 = 2 * zFar * zNear / zRange;
        //var m32 = 1;

        var xOffsetToCenter = pos.x - (FlxG.width*0.5); //so the perspective focuses on the center of the screen
        var yOffsetToCenter = pos.y - (FlxG.height*0.5);

        var zPerspectiveOffset = (newz+(2 * zFar * zNear / zRange));


        //xOffsetToCenter += (offsetX / (1/-zPerspectiveOffset));
        //yOffsetToCenter += (offsetY / (1/-zPerspectiveOffset));
        xOffsetToCenter += (offsetX * -zPerspectiveOffset);
        yOffsetToCenter += (offsetY * -zPerspectiveOffset);

        var xPerspective = xOffsetToCenter*(1/tanHalfFOV);
        var yPerspective = yOffsetToCenter*tanHalfFOV;
        xPerspective /= -zPerspectiveOffset;
        yPerspective /= -zPerspectiveOffset;

        pos.x = xPerspective+(FlxG.width*0.5); //offset it back to normal
        pos.y = yPerspective+(FlxG.height*0.5);
        pos.z = zPerspectiveOffset;

        

        //pos.z -= 1;
        //pos = perspectiveMatrix.transformVector(pos);

        return pos;
    }
    /**
        Returns in-world 3D coordinates using polar angle, azimuthal angle and a radius.
        (Spherical to Cartesian)

        @param	theta Angle used along the polar axis.
        @param	phi Angle used along the azimuthal axis.
        @param	radius Distance to center.
    **/
    public static function getCartesianCoords3D(theta:Float, phi:Float, radius:Float):Vector3D
    {
        var pos:Vector3D = new Vector3D();
        var rad = FlxAngle.TO_RAD;
        pos.x = FlxMath.fastCos(theta*rad)*FlxMath.fastSin(phi*rad);
        pos.y = FlxMath.fastCos(phi*rad);
        pos.z = FlxMath.fastSin(theta*rad)*FlxMath.fastSin(phi*rad);
        pos.x *= radius;
        pos.y *= radius;
        pos.z *= radius;

        return pos;
    }

    public static function getFlxEaseByString(?ease:String = '') {
		switch(ease.toLowerCase().trim()) {
			case 'backin': return FlxEase.backIn;
			case 'backinout': return FlxEase.backInOut;
			case 'backout': return FlxEase.backOut;
			case 'bouncein': return FlxEase.bounceIn;
			case 'bounceinout': return FlxEase.bounceInOut;
			case 'bounceout': return FlxEase.bounceOut;
			case 'circin': return FlxEase.circIn;
			case 'circinout': return FlxEase.circInOut;
			case 'circout': return FlxEase.circOut;
			case 'cubein': return FlxEase.cubeIn;
			case 'cubeinout': return FlxEase.cubeInOut;
			case 'cubeout': return FlxEase.cubeOut;
			case 'elasticin': return FlxEase.elasticIn;
			case 'elasticinout': return FlxEase.elasticInOut;
			case 'elasticout': return FlxEase.elasticOut;
			case 'expoin': return FlxEase.expoIn;
			case 'expoinout': return FlxEase.expoInOut;
			case 'expoout': return FlxEase.expoOut;
			case 'quadin': return FlxEase.quadIn;
			case 'quadinout': return FlxEase.quadInOut;
			case 'quadout': return FlxEase.quadOut;
			case 'quartin': return FlxEase.quartIn;
			case 'quartinout': return FlxEase.quartInOut;
			case 'quartout': return FlxEase.quartOut;
			case 'quintin': return FlxEase.quintIn;
			case 'quintinout': return FlxEase.quintInOut;
			case 'quintout': return FlxEase.quintOut;
			case 'sinein': return FlxEase.sineIn;
			case 'sineinout': return FlxEase.sineInOut;
			case 'sineout': return FlxEase.sineOut;
			case 'smoothstepin': return FlxEase.smoothStepIn;
			case 'smoothstepinout': return FlxEase.smoothStepInOut;
			case 'smoothstepout': return FlxEase.smoothStepInOut;
			case 'smootherstepin': return FlxEase.smootherStepIn;
			case 'smootherstepinout': return FlxEase.smootherStepInOut;
			case 'smootherstepout': return FlxEase.smootherStepOut;
		}
		return FlxEase.linear;
	}


    public static function getTimeFromBeat(beat:Float)
    {
        var totalTime:Float = 0;
        var curBpm = Conductor.bpm;
        if (PlayState.SONG != null)
            curBpm = PlayState.SONG.bpm;
        for (i in 0...Math.floor(beat))
        {
            if (Conductor.bpmChangeMap.length > 0)
            {
                for (j in 0...Conductor.bpmChangeMap.length)
                {
                    if (totalTime >= Conductor.bpmChangeMap[j].songTime)
                        curBpm = Conductor.bpmChangeMap[j].bpm;
                }
            }
            totalTime += (60/curBpm)*1000;
        }

        var leftOverBeat = beat - Math.floor(beat);
        totalTime += (60/curBpm)*1000*leftOverBeat;

        return totalTime;
    }
}