package funkin.game.modchart.modifiers;

// NOTE: THIS SHOULDNT HAVE ITS PERCENTAGE MODIFIED
// THIS IS JUST HERE TO ALLOW OTHER MODIFIERS TO HAVE PERSPECTIVE
// did my research
// i now know what a frustrum is lmao
// stuff ill forget after tonight
// its the next day and yea i forgot already LOL
// something somethng clipping idk
// either way
// perspective projection woo
class PerspectiveModifier extends NoteModifier
{
	override function getName() return 'perspectiveDONTUSE';
	
	override function getOrder() return Modifier.ModifierOrder.LAST + 100;
	
	override function shouldExecute(player:Int, val:Float) return true;
	
	var halfOffset = Vector3.get(FlxG.width / 2, FlxG.height / 2);
	
	var fov = Math.PI / 2;
	var near = 0;
	var far = 2;
	
	function FastTan(rad:Float) // thanks schmoovin
	{
		return FlxMath.fastSin(rad) / FlxMath.fastCos(rad);
	}
	
	public function getVector(curZ:Float, pos:Vector3):Vector3
	{
		pos.subtract(halfOffset, pos);
		
		var oX = pos.x;
		var oY = pos.y;
		
		pos.put();
		
		// should I be using a matrix?
		// .. nah im sure itll be fine just doing this manually
		// instead of doing a proper perspective projection matrix
		
		// var aspect = FlxG.width/FlxG.height;
		var aspect = 1;
		
		var shit = curZ - 1;
		if (shit > 0) shit = 0; // thanks schmovin!!
		
		var ta = FastTan(fov / 2);
		var x = oX * aspect / ta;
		var y = oY / ta;
		var a = (near + far) / (near - far);
		var b = 2 * near * far / (near - far);
		var z = (a * shit + b);
		// trace(shit, curZ, z, x/z, y/z);
		var returnedVector = Vector3.get(x / z, y / z, z);
		returnedVector.add(halfOffset, returnedVector);
		
		return returnedVector;
	}
	
	override function getPos(time:Float, visualDiff:Float, timeDiff:Float, beat:Float, pos:Vector3, data:Int, player:Int, obj:FlxSprite) return getVector(pos.z, pos);
	
	override function updateReceptor(beat:Float, receptor:StrumNote, pos:Vector3, player:Int) receptor.scale.scale(1 / pos.z);
	
	override function updateNote(beat:Float, note:Note, pos:Vector3, player:Int) note.scale.scale(1 / pos.z);
	
	override function updateNoteSplash(beat:Float, splash:NoteSplash, pos:Vector3, player:Int) splash.scale.scale(1 / pos.z);
	
	override function updateSustainSplash(beat:Float, splash:SustainSplash, pos:Vector3, player:Int) splash.scale.scale(1 / pos.z);
}
