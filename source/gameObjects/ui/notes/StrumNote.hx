package gameObjects.ui.notes;

import backend.animation.PsychAnimationController;
import flixel.addons.effects.FlxSkewedSprite;

import shaders.RGBPalette;
import shaders.RGBPalette.RGBShaderReference;

using StringTools;

class StrumNote extends FlxSkewedSprite
{
	public var rgbShader:RGBShaderReference;
	public var resetAnim:Float = 0;
	private var noteData:Int = 0;
	public var direction:Float = 90;//plan on doing scroll directions soon -bb
	public var downScroll:Bool = false;//plan on doing scroll directions soon -bb
	public var sustainReduce:Bool = true;

	//hardcoded greyscale color palette
	public var arrowRGBGreyscale:Array<Array<FlxColor>> = [
		[0xFF505050, 0xFFFFFFFF, 0xFF1B1B1B],
		[0xFF747474, 0xFFFFFFFF, 0xFF353535],
		[0xFFA2A2A2, 0xFFFFFFFF, 0xFF424242],
		[0xFF1D1D1D, 0xFFFFFFFF, 0xFF000000]
	];
	
	private var player:Int;

	public var inSettings:Bool = false;
	
	public var texture(default, set):String = null;
	public function set_texture(value:String):String {
		if(texture != value) {
			texture = value;
			reloadNote();
		}
		return value;
	}

	public var useRGBShader:Bool = true;
	public function new(x:Float, y:Float, leData:Int, player:Int, ?inSettings:Bool = false) {
		animation = new PsychAnimationController(this);
		this.inSettings = inSettings;

		rgbShader = new RGBShaderReference(this, Note.initializeGlobalRGBShader(leData));
		rgbShader.enabled = false;
		if(PlayState.SONG != null && PlayState.SONG.disableNoteRGB) useRGBShader = false;
		
		var arr:Array<FlxColor> = ClientPrefs.data.arrowRGB[leData];
		if(PlayState.isPixelStage) arr = ClientPrefs.data.arrowRGBPixel[leData];

		if(!inSettings)
		{
			if(PlayState.curStage == "menuSongs") arr = [0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF];
			if(PlayState.curStage == "waltRoom") arr = [0xFFFDD577, 0xFFFEEECA, 0xFF6F4F0D];
			if(PlayState.isGreyscale) arr = arrowRGBGreyscale[leData];
		}
		
		if(leData <= arr.length)
		{
			@:bypassAccessor
			{
				rgbShader.r = arr[0];
				rgbShader.g = arr[1];
				rgbShader.b = arr[2];
			}
		}

		noteData = leData;
		this.player = player;
		this.noteData = leData;
		super(x, y);

		var skin:String = null;
		if(PlayState.SONG != null && PlayState.SONG.arrowSkin != null && PlayState.SONG.arrowSkin.length > 1 && !inSettings) skin = PlayState.SONG.arrowSkin;
		else skin = Note.defaultNoteSkin;

		if (PlayState.SONG != null && !inSettings)
		{
			switch (PlayState.SONG.arrowSkin)
			{
				case "Mania":
					switch (FreeplayState.maniaSkin)
					{
						case 0: skin = "faviNotes/NOTE_assets-MANIA";
						case 1: skin = "faviNotes/NOTE_assets-MANIABAR";
						case 2: skin = "faviNotes/NOTE_assets-MANIACIRCLE";
					}
				case "Cartoon":
					skin = "faviNotes/NOTE_assets-CARTOON";
				case "Mercy":
					skin = "faviNotes/NOTE_assets-MERCY";
				case "Base Game":
					skin = "NOTE_assets";
				case "Sin":
					skin = "faviNotes/NOTE_assets-SIN";
				case "Cross":
					skin = "faviNotes/NOTE_assets-CROSS";
				case "Malfunction":
					skin = "faviNotes/NOTE_assets-MALFUNCTION";
				case "War":
					skin = "faviNotes/NOTE_assets-WAR";
				case "Birthday":
					skin = "faviNotes/NOTE_assets-BIRTHDAY";
				case "Default":
					skin = "faviNotes/NOTE_assets-DEFAULT";
			}
		}
		else skin = PlayState.isPixelStage ? "faviNotes/NOTE_assets-MALFUNCTION" : "faviNotes/NOTE_assets-DEFAULT";

		var customSkin:String = skin + Note.getNoteSkinPostfix();
		if(Paths.fileExists('images/$customSkin.png', IMAGE)) skin = customSkin;

		texture = skin; //Load texture and anims
		scrollFactor.set();
	}

	public function reloadNote()
	{
		var lastAnim:String = null;
		if(animation.curAnim != null) lastAnim = animation.curAnim.name;

		if(PlayState.isPixelStage)
		{
			loadGraphic(Paths.image('pixelUI/' + texture));
			width = width / 4;
			height = height / 5;
			loadGraphic(Paths.image('pixelUI/' + texture), true, Math.floor(width), Math.floor(height));

			antialiasing = false;
			setGraphicSize(Std.int(width * PlayState.daPixelZoom));

			animation.add('green', [6]);
			animation.add('red', [7]);
			animation.add('blue', [5]);
			animation.add('purple', [4]);
			switch (Math.abs(noteData) % 4)
			{
				case 0:
					animation.add('static', [0]);
					animation.add('pressed', [4, 8], 12, false);
					animation.add('confirm', [12, 16], 24, false);
				case 1:
					animation.add('static', [1]);
					animation.add('pressed', [5, 9], 12, false);
					animation.add('confirm', [13, 17], 24, false);
				case 2:
					animation.add('static', [2]);
					animation.add('pressed', [6, 10], 12, false);
					animation.add('confirm', [14, 18], 12, false);
				case 3:
					animation.add('static', [3]);
					animation.add('pressed', [7, 11], 12, false);
					animation.add('confirm', [15, 19], 24, false);
			}
		}
		else
		{
			frames = Paths.getSparrowAtlas(texture);
			animation.addByPrefix('green', 'arrowUP');
			animation.addByPrefix('blue', 'arrowDOWN');
			animation.addByPrefix('purple', 'arrowLEFT');
			animation.addByPrefix('red', 'arrowRIGHT');

			antialiasing = ClientPrefs.data.antialiasing;
			setGraphicSize(Std.int(width * 0.7));

			switch (Math.abs(noteData) % 4)
			{
				case 0:
					animation.addByPrefix('static', 'arrowLEFT');
					animation.addByPrefix('pressed', 'left press', 24, false);
					animation.addByPrefix('confirm', 'left confirm', 24, false);
				case 1:
					animation.addByPrefix('static', 'arrowDOWN');
					animation.addByPrefix('pressed', 'down press', 24, false);
					animation.addByPrefix('confirm', 'down confirm', 24, false);
				case 2:
					animation.addByPrefix('static', 'arrowUP');
					animation.addByPrefix('pressed', 'up press', 24, false);
					animation.addByPrefix('confirm', 'up confirm', 24, false);
				case 3:
					animation.addByPrefix('static', 'arrowRIGHT');
					animation.addByPrefix('pressed', 'right press', 24, false);
					animation.addByPrefix('confirm', 'right confirm', 24, false);
			}
		}
		updateHitbox();

		if(lastAnim != null)
		{
			playAnim(lastAnim, true);
		}
	}

	public function postAddedToGroup() {
		playAnim('static');
		x += Note.swagWidth * noteData;
		x += 50;
		x += ((FlxG.width / 2) * player);
		ID = noteData;
	}

	override function update(elapsed:Float) {
		if(resetAnim > 0) {
			resetAnim -= elapsed;
			if(resetAnim <= 0) {
				playAnim('static');
				resetAnim = 0;
			}
		}
		//if(animation.curAnim != null){ //my bad i was upset
		if(animation.curAnim.name == 'confirm' && !PlayState.isPixelStage) {
			centerOrigin();
		//}
		}

		super.update(elapsed);
	}

	public function playAnim(anim:String, ?force:Bool = false) {
		animation.play(anim, force);
		centerOffsets();
		centerOrigin();
		if(useRGBShader) rgbShader.enabled = (animation.curAnim != null && animation.curAnim.name != 'static');
	}
}