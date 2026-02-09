package gameObjects.ui.notes;

import backend.animation.PsychAnimationController;
import backend.NoteTypesConfig;

import flixel.addons.effects.FlxSkewedSprite;

import shaders.RGBPalette;
import shaders.RGBPalette.RGBShaderReference;

import gameObjects.ui.notes.StrumNote;

import flixel.math.FlxRect;

using StringTools;

typedef EventNote = {
	strumTime:Float,
	event:String,
	value1:String,
	value2:String
}

typedef NoteSplashData = {
	disabled:Bool,
	texture:String,
	useGlobalShader:Bool, //breaks r/g/b/a but makes it copy default colors for your custom note
	useRGBShader:Bool,
	antialiasing:Bool,
	r:FlxColor,
	g:FlxColor,
	b:FlxColor,
	a:Float
}

class Note extends FlxSkewedSprite
{
	public var extraData:Map<String,Dynamic> = [];

	public static var quants:Array<Int> = [
		4,
		8,
		12,
		16,
		20,
		24,
		32,
		48,
		64,
		96,
		192
	];
	public var quant:Int = 4;

	//Note Color Stuff
	public var arrowRGBQuants:Array<Array<FlxColor>> = [
		[0xFFF9393F, 0xFFFFFFFF, 0xFF651038],
		[0xFF00FFFF, 0xFFFFFFFF, 0xFF1542B7],
		[0xFFC24B99, 0xFFFFFFFF, 0xFF3C1F56],
		[0xFFF0E342, 0xFFFFFFFF, 0xFF554320],
		[0xFFED36AD, 0xFFFFFFFF, 0xFF5C185A],
		[0xFFE98F16, 0xFFFFFFFF, 0xFF3F2D12],
		[0xFF4769B8, 0xFFFFFFFF, 0xFF161B27],
		[0xFF12FA05, 0xFFFFFFFF, 0xFF0A4447],
		[0xFF008080, 0xFFFFFFFF, 0xFF004D4D],
		[0xFF8a8a8a, 0xFFFFFFFF, 0xff3a3a3a],
		[0xFFbab86c, 0xFFFFFFFF, 0xff505a1f]
	];

	public var arrowRGBQuantsMania:Array<Array<FlxColor>> = [
		[0xFFFFC1C3, 0xFFFFFFFF, 0xFFFFFFFF],
		[0xFFDAFFFF, 0xFFFFFFFF, 0xFFFFFFFF],
		[0xFFFFD2EF, 0xFFFFFFFF, 0xFFFFFFFF],
		[0xFFFFFCCD, 0xFFFFFFFF, 0xFFFFFFFF],
		[0xFFFCE0F2, 0xFFFFFFFF, 0xFFFFFFFF],
		[0xFFFCE0BB, 0xFFFFFFFF, 0xFFFFFFFF],
		[0xFFDBE6FF, 0xFFFFFFFF, 0xFFFFFFFF],
		[0xFFD9FFD7, 0xFFFFFFFF, 0xFFFFFFFF],
		[0xFFCBFFFF, 0xFFFFFFFF, 0xFFFFFFFF],
		[0xffffffff, 0xFFFFFFFF, 0xFFFFFFFF],
		[0xffe9e7bb, 0xFFFFFFFF, 0xFFFFFFFF]
	];

	public var arrowRGBQuantsMercy:Array<Array<FlxColor>> = [
		[0xFFFDD577, 0xFFFEEECA, 0xFF6F4F0D],
		[0xFFFFF7E6, 0xFFFFFFFF, 0xFFEAA005],
		[0xFFFCFAF6, 0xFFFFFFFF, 0xFFA58C57],
		[0xFFFFE4A6, 0xFFFFFEFC, 0xFFAF7700],
		[0xFFEEDBB0, 0xFFFDFBF7, 0xFF79612F],
		[0xFFFFCA4A, 0xFFFFE0A1, 0xFF523802],
		[0xFFC9B179, 0xFFE2D4B6, 0xFF2E291E],
		[0xFFFFBA1D, 0xFFFFD373, 0xFF261A00],
		[0xFFAB996E, 0xFFCCBFA4, 0xFF131211],
		[0xFF7A7058, 0xFFA79B81, 0xFF000000],
		[0xFF69562B, 0xFFA88843, 0xFF000000]
	];

	public var arrowRGBQuantsGreyscale:Array<Array<FlxColor>> = [
		[0xFF737373, 0xFFFFFFFF, 0xFF2E2E2E],
		[0xFFB3B3B3, 0xFFFFFFFF, 0xFF424242],
		[0xFF777777, 0xFFFFFFFF, 0xFF2E2E2E],
		[0xFFD4D4D4, 0xFFFFFFFF, 0xFF444444],
		[0xFF7A7A7A, 0xFFFFFFFF, 0xFF343434],
		[0xFF9C9C9C, 0xFFFFFFFF, 0xFF2F2F2F],
		[0xFF686868, 0xFFFFFFFF, 0xFF1B1B1B],
		[0xFF999999, 0xFFFFFFFF, 0xFF333333],
		[0xFF5A5A5A, 0xFFFFFFFF, 0xFF363636],
		[0xFF8a8a8a, 0xFFFFFFFF, 0xff3a3a3a],
		[0xFFB0B0B0, 0xFFFFFFFF, 0xff505050]
	];

	public var arrowRGBSatanQuants:Array<Array<FlxColor>> = [
		[0xFFC40F0F, 0xFFDF7373, 0xFF7F1A1A],
		[0xFF9B1212, 0xFF9B3838, 0xFF6C0A0A],
		[0xFF792222, 0xFFA54242, 0xFF561414],
		[0xFF723434, 0xFF944949, 0xFF3C0B0B],
		[0xFFA14444, 0xFF9A5D5D, 0xFF441717],
		[0xFF563838, 0xFF784545, 0xFF381D1D],
		[0xFF3F2F2F, 0xFF685353, 0xFF241717],
		[0xFF8F6565, 0xFFCC8080, 0xFF432424],
		[0xFFD66D6D, 0xFFF29797, 0xFF633838],
		[0xff340202, 0xFF773030, 0xff110202],
		[0xff562222, 0xFF643C3C, 0xff1c0707]
	];

	public var arrowRGBQuantsError:Array<Array<FlxColor>> = [
		[0xFFF9393F, 0xFF201111, 0xFF180C12],
		[0xFF00FFFF, 0xFF161D1D, 0xFF0A0C13],
		[0xFFC24B99, 0xFF1A131B, 0xFF0D0911],
		[0xFFF0E342, 0xFF14140F, 0xFF110E09],
		[0xFFED36AD, 0xFF1F151D, 0xFF110911],
		[0xFFE98F16, 0xFF201B15, 0xFF110E09],
		[0xFF4769B8, 0xFF12151B, 0xFF090B0F],
		[0xFF12FA05, 0xFF111811, 0xFF040707],
		[0xFF008080, 0xFF00151B, 0xFF000A0A],
		[0xFF8a8a8a, 0xFF131313, 0xff0c0c0c],
		[0xFFbab86c, 0xFF1B1B15, 0xff0b0c05]
	];

	public var arrowRGBGreyscale:Array<Array<FlxColor>> = [
		[0xFF505050, 0xFFFFFFFF, 0xFF1B1B1B],
		[0xFF747474, 0xFFFFFFFF, 0xFF353535],
		[0xFFA2A2A2, 0xFFFFFFFF, 0xFF424242],
		[0xFF1D1D1D, 0xFFFFFFFF, 0xFF000000]
	];

	public var arrowRGBNewError:Array<Array<FlxColor>> = [
		[0xD8F01111, 0xFF271818, 0xFF140D0D],
		[0xFF00FFFF, 0x1C2525, 0x090E0D],
		[0xD89E11F0, 0xFF241827, 0xFF120D14],
		[0xFF00FF6A, 0x1C2520, 0x090E0B],
		[0xFF1100FF, 0x1C1C25, 0x09090E],
		[0xFFFF00DD, 0x251C22, 0x0E090D]
	];

	public var arrowRGBOldError:Array<Array<FlxColor>> = [
		[0xD8F01111, 0xFF271818, 0xFF140D0D],
		[0xFF00FFFF, 0x1C2525, 0x090E0D],
		[0xD8F01111, 0xFF271818, 0xFF140D0D],
		[0xFF00FFFF, 0x1C2525, 0x090E0D]
	];

	public var mesh:modcharting.SustainStrip = null;
  	public var z:Float = 0;

	public var strumTime:Float = 0;
	public var mustPress:Bool = false;
	public var noteData:Int = 0;
	public var canBeHit:Bool = false;
	public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;
	public var ignoreNote:Bool = false;
	public var hitByOpponent:Bool = false;
	public var noteWasHit:Bool = false;
	public var prevNote:Note;
	public var nextNote:Note;

	public var missed:Bool = false;

	public var spawned:Bool = false;

	public var tail:Array<Note> = []; // for sustains
	public var parent:Note;
	public var blockHit:Bool = false; // only works for player

	public var sustainLength:Float = 0;
	public var isSustainNote:Bool = false;
	public var noteType(default, set):String = null;

	public var eventName:String = '';
	public var eventLength:Int = 0;
	public var eventVal1:String = '';
	public var eventVal2:String = '';

	public var rgbShader:RGBShaderReference;
	public static var globalRgbShaders:Array<RGBPalette> = [];
	public var inEditor:Bool = false;
	public var inSettings:Bool = false;

	public var animSuffix:String = '';
	public var gfNote:Bool = false;
	public var earlyHitMult:Float = 0.5;
	public var lateHitMult:Float = 1;
	public var lowPriority:Bool = false;

	public static var SUSTAIN_SIZE:Int = 44;
	public static var swagWidth:Float = 160 * 0.7;
	
	public static var colArray:Array<String> = ['purple', 'blue', 'green', 'red'];
	private var pixelInt:Array<Int> = [0, 1, 2, 3];

	public static var defaultNoteSkin(default, never):String = "faviNotes/NOTE_assets-DEFAULT";

	public var noteSplashData:NoteSplashData = {
		disabled: false,
		texture: null,
		antialiasing: !PlayState.isPixelStage,
		useGlobalShader: false,
		useRGBShader: (PlayState.SONG != null) ? !(PlayState.SONG.disableNoteRGB == true) : true,
		r: -1,
		g: -1,
		b: -1,
		a: ClientPrefs.data.splashAlpha
	};

	public var offsetX:Float = 0;
	public var offsetY:Float = 0;
	public var offsetAngle:Float = 0;
	public var multAlpha:Float = 1;
	public var multSpeed(default, set):Float = 1;

	public var copyX:Bool = true;
	public var copyY:Bool = true;
	public var copyAngle:Bool = true;
	public var copyAlpha:Bool = true;

	public var hitHealth:Float = 0.023;
	public var missHealth:Float = 0.0475;
	public var rating:String = 'unknown';
	public var ratingMod:Float = 0; //9 = unknown, 0.25 = shit, 0.5 = bad, 0.75 = good, 1 = sick
	public var ratingDisabled:Bool = false;

	public var texture(default, set):String = null;

	public var noAnimation:Bool = false;
	public var noMissAnimation:Bool = false;
	public var customSkinnedNote:Bool = false;
	public var hitCausesMiss:Bool = false;
	public var distance:Float = 2000; //plan on doing scroll directions soon -bb

	public var hitsoundDisabled:Bool = false;
	public var hitsoundChartEditor:Bool = true;
	public var hitsound:String = 'hitsound';

	public static function getQuant(beat:Float){
		var row = Conductor.beatToNoteRow(beat);
		for(data in quants){
			if(row%(Conductor.ROWS_PER_MEASURE/data) == 0){
				return data;
			}
		}
		return quants[quants.length-1]; // invalid
	}

	private function set_multSpeed(value:Float):Float {
		resizeByRatio(value / multSpeed);
		multSpeed = value;
		//trace('fuck cock');
		return value;
	}

	public function resizeByRatio(ratio:Float) //haha funny twitter shit
	{
		if(isSustainNote && animation.curAnim != null && !animation.curAnim.name.endsWith('end'))
		{
			scale.y *= ratio;
			updateHitbox();
		}
	}

	private function set_texture(value:String):String {
		if(texture != value) {
			texture = value;
			reloadNote();
		}
		return value;
	}

	public function defaultRGB()
	{
		var arr:Array<FlxColor> = ClientPrefs.data.arrowRGB[noteData];
		if(PlayState.isPixelStage) arr = ClientPrefs.data.arrowRGBPixel[noteData];

		if (!inSettings)
		{
			if(PlayState.curStage == "menuSongs") arr = [0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF];
			if(PlayState.curStage == "waltRoom") arr = [0xFFFDD577, 0xFFFEEECA, 0xFF6F4F0D];
			if(PlayState.isGreyscale) arr = arrowRGBGreyscale[noteData];

			if (ClientPrefs.data.quantization)
			{
				var idx = quants.indexOf(quant);
				switch (PlayState.curStage)
				{
					case "waltRoom": arr = arrowRGBQuantsMercy[idx];
					case "menuSongs": arr = arrowRGBQuantsMania[idx];
					default: arr = PlayState.isGreyscale ? arrowRGBQuantsGreyscale[idx] : arrowRGBQuants[idx];
				}
			}
		}

		if (noteData > -1 && noteData <= arr.length)
		{
			rgbShader.r = arr[0];
			rgbShader.g = arr[1];
			rgbShader.b = arr[2];
		}
	}

	private function set_noteType(value:String):String {
		noteSplashData.texture = PlayState.SONG != null ? PlayState.SONG.splashSkin : 'noteSplashes';
		defaultRGB();

		if(noteData > -1 && noteType != value) {
			switch(value) {
				case 'Evilrett Alt Skin 1':
					reloadNote('faviNotes/NOTE_assets-LUNACYEVIL');
					customSkinnedNote = true;
				case 'Evilrett Alt Skin 1 No Anim':
					reloadNote('faviNotes/NOTE_assets-LUNACYEVIL');
					noAnimation = true;
					noMissAnimation = true;
					customSkinnedNote = true;
				case 'Evilrett Alt Skin 2':
					reloadNote('faviNotes/NOTE_assets-EVILINTRO');
					customSkinnedNote = true;
				case 'Evilrett Alt Skin 3':
					reloadNote('faviNotes/NOTE_assets-SATAN');
					customSkinnedNote = true;
					var arr:Array<FlxColor> = [0xFFBF8282, 0xFFF49999, 0xFFA74141];

					if (ClientPrefs.data.quantization)
					{
						var idx = quants.indexOf(quant);
						arr = arrowRGBSatanQuants[idx];
					}

					if (noteData > -1 && noteData <= arr.length)
					{
						rgbShader.r = arr[0];
						rgbShader.g = arr[1];
						rgbShader.b = arr[2];
					}
				case 'Hurt Note':
					ignoreNote = mustPress;
					//reloadNote('HURTNOTE_assets');
					//this used to change the note texture to HURTNOTE_assets.png,
					//but i've changed it to something more optimized with the implementation of RGBPalette:

					// note colors
					rgbShader.r = 0xFF101010;
					rgbShader.g = 0xFFFF0000;
					rgbShader.b = 0xFF990022;

					// splash data and colors
					noteSplashData.r = 0xFFFF0000;
					noteSplashData.g = 0xFF101010;
					noteSplashData.texture = 'noteSplashes/noteSplashes-electric';

					// gameplay data
					lowPriority = true;
					missHealth = isSustainNote ? 0.25 : 0.1;
					hitCausesMiss = true;
					hitsound = 'cancelMenu';
					hitsoundChartEditor = false;
				case 'Error Note':
					ignoreNote = mustPress;
					var arr:Array<FlxColor> = ClientPrefs.data.arrowRGB[noteData];

					if (PlayState.SONG.song == "Malfunction Legacy")
					{
						reloadNote('faviNotes/ERRORNOTE_assets');
						arr = arrowRGBOldError[noteData];
					}
					else
					{
						reloadNote('faviNotes/ERROR_NOTE');
						var randomInt:Int = FlxG.random.int(0, 5);
						arr = arrowRGBNewError[randomInt];
					}

					customSkinnedNote = true;

					if (ClientPrefs.data.quantization)
					{
						var idx = quants.indexOf(quant);
						arr = arrowRGBQuantsError[idx];
					}

					if (noteData > -1 && noteData <= arr.length)
					{
						rgbShader.r = arr[0];
						rgbShader.g = arr[1];
						rgbShader.b = arr[2];
					}

					lowPriority = true;
				case 'Alt Animation':
					animSuffix = '-alt';
				case 'No Animation':
					noAnimation = true;
					noMissAnimation = true;
				case 'GF Sing':
					gfNote = true;
				case 'Mal Must Miss These':
					noAnimation = true;
					noMissAnimation = true;
					hitCausesMiss = false;
					ignoreNote = true;

				case 'Mal Must Miss These (Error Edition)':
					var arr:Array<FlxColor> = ClientPrefs.data.arrowRGB[noteData];

					if (PlayState.SONG.song == "Malfunction Legacy")
					{
						reloadNote('faviNotes/ERRORNOTE_assets');
						arr = arrowRGBOldError[noteData];
					}
					else
					{
						reloadNote('faviNotes/ERROR_NOTE');
						var randomInt:Int = FlxG.random.int(0, 5);
						arr = arrowRGBNewError[randomInt];
					}

					customSkinnedNote = true;

					if (ClientPrefs.data.quantization)
					{
						var idx = quants.indexOf(quant);
						arr = arrowRGBQuantsError[idx];
					}

					if (noteData > -1 && noteData <= arr.length)
					{
						rgbShader.r = arr[0];
						rgbShader.g = arr[1];
						rgbShader.b = arr[2];
					}
					
					noAnimation = true;
					noMissAnimation = true;
					hitCausesMiss = false;
					ignoreNote = true;
			}
			if (value != null && value.length > 1) NoteTypesConfig.applyNoteTypeData(this, value);
			if (hitsound != 'hitsound' && ClientPrefs.data.hitsoundVolume > 0) Paths.sound(hitsound); //precache new sound for being idiot-proof
			noteType = value;
		}
		return value;
	}

	public function new(strumTime:Float, noteData:Int, ?prevNote:Note, ?sustainNote:Bool = false, ?inEditor:Bool = false, ?inSettings:Bool = false)
	{
		super();

		animation = new PsychAnimationController(this);

		if (prevNote == null)
			prevNote = this;

		this.prevNote = prevNote;
		isSustainNote = sustainNote;
		this.inEditor = inEditor;
		this.inSettings = inSettings;

		if (ClientPrefs.data.quantization){
			var beat = Conductor.getBeatInMeasure(strumTime);
			if(prevNote!=null && isSustainNote)
				quant = prevNote.quant;
			else
				quant = getQuant(beat);
		}

		x += (ClientPrefs.data.middleScroll ? PlayState.STRUM_X_MIDDLESCROLL : PlayState.STRUM_X) + 50;
		// MAKE SURE ITS DEFINITELY OFF SCREEN?
		y -= 2000;
		this.strumTime = strumTime;
		if(!inEditor) this.strumTime += ClientPrefs.data.noteOffset;

		this.noteData = noteData;

		if(noteData > -1) {
			texture = '';

			rgbShader = new RGBShaderReference(this, initializeGlobalRGBShader(noteData));
			if(PlayState.SONG != null && PlayState.SONG.disableNoteRGB) rgbShader.enabled = false;
			
			x += swagWidth * (noteData);
			if(!isSustainNote && noteData > -1 && noteData < 4) { //Doing this 'if' check to fix the warnings on Senpai songs
				var animToPlay:String = '';
				animToPlay = colArray[noteData % 4];
				animation.play(animToPlay + 'Scroll');
			}
		}

		// trace(prevNote);

		if(prevNote!=null)
			prevNote.nextNote = this;

		if (isSustainNote && prevNote != null)
		{
			alpha = 0.6;
			multAlpha = 0.6;
			hitsoundDisabled = true;
			if(ClientPrefs.data.downScroll) flipY = true;

			offsetX += width / 2;
			copyAngle = false;

			animation.play(colArray[noteData % 4] + 'holdend');

			updateHitbox();

			offsetX -= width / 2;

			if (PlayState.isPixelStage)
				offsetX += 30;

			if (prevNote.isSustainNote)
			{
				prevNote.animation.play(colArray[prevNote.noteData % 4] + 'hold');

				prevNote.scale.y *= Conductor.stepCrochet / 100 * 1.05;
				if(PlayState.instance != null)
				{
					prevNote.scale.y *= PlayState.instance.songSpeed;
				}

				if(PlayState.isPixelStage) {
					prevNote.scale.y *= 1.19;
					prevNote.scale.y *= (6 / height); //Auto adjust note size
				}
				prevNote.updateHitbox();
				// prevNote.setGraphicSize();
			}

			if(PlayState.isPixelStage) {
				scale.y *= PlayState.daPixelZoom;
				updateHitbox();
			}
		} else if(!isSustainNote) {
			earlyHitMult = 1;
		}
		x += offsetX;
	}

	public static function initializeGlobalRGBShader(noteData:Int)
	{
		if(globalRgbShaders[noteData] == null)
		{
			var newRGB:RGBPalette = new RGBPalette();
			globalRgbShaders[noteData] = newRGB;

			var arr:Array<FlxColor> = (!PlayState.isPixelStage) ? ClientPrefs.data.arrowRGB[noteData] : ClientPrefs.data.arrowRGBPixel[noteData];
			if (noteData > -1 && noteData <= arr.length)
			{
				newRGB.r = arr[0];
				newRGB.g = arr[1];
				newRGB.b = arr[2];
			}
		}
		return globalRgbShaders[noteData];
	}

	var _lastNoteOffX:Float = 0;
	static var _lastValidChecked:String; //optimization
	public var originalHeight:Float = 6;
	public var correctionOffset:Float = 0; //dont mess with this
	public function reloadNote(texture:String = '', postfix:String = '') {
		if(texture == null) texture = '';
		if(postfix == null) postfix = '';

		var skin:String = texture + postfix;
		if(texture.length < 1) {
			if(skin == null || skin.length < 1)
				if (PlayState.SONG != null)
				{
					switch (PlayState.SONG.arrowSkin)
					{
						case "Default":
							skin = "faviNotes/NOTE_assets-DEFAULT";
						case "Cartoon":
							skin = "faviNotes/NOTE_assets-CARTOON";
						case "Cross":
							skin = "faviNotes/NOTE_assets-CROSS";
						case "War":
							skin = "faviNotes/NOTE_assets-WAR";
						case "Mercy":
							skin = "faviNotes/NOTE_assets-MERCY";
						case "Sin":
							skin = "faviNotes/NOTE_assets-SIN";
						case "Malfunction":
							skin = "faviNotes/NOTE_assets-MALFUNCTION";
						case "Birthday":
							skin = "faviNotes/NOTE_assets-BIRTHDAY";
						case "Mania":
							switch (FreeplayState.maniaSkin)
							{
								case 0: skin = "faviNotes/NOTE_assets-MANIA";
								case 1: skin = "faviNotes/NOTE_assets-MANIABAR";
								case 2: skin = "faviNotes/NOTE_assets-MANIACIRCLE";
							}
						case "Base Game":
							skin = "NOTE_assets";
					}
				}
				else skin = PlayState.isPixelStage ? "faviNotes/NOTE_assets-MALFUNCTION" : "faviNotes/NOTE_assets-DEFAULT";
		}

		var animName:String = null;
		if(animation.curAnim != null) {
			animName = animation.curAnim.name;
		}

		var skinPixel:String = skin;
		var lastScaleY:Float = scale.y;
		var skinPostfix:String = getNoteSkinPostfix();
		var customSkin:String = skin + skinPostfix;
		var path:String = PlayState.isPixelStage ? 'pixelUI/' : '';
		if(customSkin == _lastValidChecked || Paths.fileExists('images/' + path + customSkin + '.png', IMAGE))
		{
			skin = customSkin;
			_lastValidChecked = customSkin;
		}
		else skinPostfix = '';

		if(PlayState.isPixelStage) {
			if (!inSettings)
			{
				if(isSustainNote) {
					var graphic = Paths.image('pixelUI/' + skinPixel + 'ENDS' + skinPostfix);
					loadGraphic(graphic, true, Math.floor(graphic.width / 4), Math.floor(graphic.height / 2));
					originalHeight = graphic.height / 2;
				} else {
					var graphic = Paths.image('pixelUI/' + skinPixel + skinPostfix);
					loadGraphic(graphic, true, Math.floor(graphic.width / 4), Math.floor(graphic.height / 5));
				}
			}
			else {
				if(isSustainNote) {
					var graphic = Paths.image('pixelUI/faviNotes/NOTE_assets-MALFUNCTIONENDS');
					loadGraphic(graphic, true, Math.floor(graphic.width / 4), Math.floor(graphic.height / 2));
					originalHeight = graphic.height / 2;
				} else {
					var graphic = Paths.image('pixelUI/faviNotes/NOTE_assets-MALFUNCTION');
					loadGraphic(graphic, true, Math.floor(graphic.width / 4), Math.floor(graphic.height / 5));
				}
			}
			setGraphicSize(Std.int(width * PlayState.daPixelZoom));
			loadPixelNoteAnims();
			antialiasing = false;

			if(isSustainNote) {
				offsetX += _lastNoteOffX;
				_lastNoteOffX = (width - (skin != "NOTE_assets" ? 9 : 7)) * (PlayState.daPixelZoom / 2);
				offsetX -= _lastNoteOffX;
			}
		} else {
			frames = Paths.getSparrowAtlas((inSettings ? "faviNotes/NOTE_assets-DEFAULT" : skin));
			loadNoteAnims();
			antialiasing = ClientPrefs.data.antialiasing;
			if(!isSustainNote)
			{
				centerOffsets();
				centerOrigin();
			}
		}

		if(isSustainNote) {
			scale.y = lastScaleY;
		}
		updateHitbox();

		if(animName != null)
			animation.play(animName, true);
	}

	public static function getNoteSkinPostfix()
	{
		var skin:String = '';
		if(ClientPrefs.data.noteSkin != ClientPrefs.defaultData.noteSkin)
			skin = '-' + ClientPrefs.data.noteSkin.trim().toLowerCase().replace(' ', '_');
		return skin;
	}

	function loadNoteAnims() {
		if (isSustainNote)
		{
			attemptToAddAnimationByPrefix('purpleholdend', 'pruple end hold', 24, true); // this fixes some retarded typo from the original note .FLA
			animation.addByPrefix(colArray[noteData] + 'holdend', colArray[noteData] + ' hold end', 24, true);
			animation.addByPrefix(colArray[noteData] + 'hold', colArray[noteData] + ' hold piece', 24, true);
		}
		else animation.addByPrefix(colArray[noteData] + 'Scroll', colArray[noteData] + '0');

		setGraphicSize(Std.int(width * 0.7));
		updateHitbox();
	}

	function loadPixelNoteAnims() {
		if(isSustainNote)
		{
			animation.add(colArray[noteData] + 'holdend', [noteData + 4], 24, true);
			animation.add(colArray[noteData] + 'hold', [noteData], 24, true);
		} else animation.add(colArray[noteData] + 'Scroll', [noteData + 4], 24, true);
	}

	function attemptToAddAnimationByPrefix(name:String, prefix:String, framerate:Float = 24, doLoop:Bool = true)
	{
		var animFrames = [];
		@:privateAccess
		animation.findByPrefix(animFrames, prefix); // adds valid frames to animFrames
		if(animFrames.length < 1) return;

		animation.addByPrefix(name, prefix, framerate, doLoop);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (mustPress)
		{
			// ok river
			if (strumTime > Conductor.songPosition - (Conductor.safeZoneOffset * lateHitMult)
				&& strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * earlyHitMult))
				canBeHit = true;
			else
				canBeHit = false;

			if (strumTime < Conductor.songPosition - Conductor.safeZoneOffset && !wasGoodHit)
				tooLate = true;
		}
		else
		{
			canBeHit = false;

			if (strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * earlyHitMult))
			{
				if((isSustainNote && prevNote.wasGoodHit) || strumTime <= Conductor.songPosition)
					wasGoodHit = true;
			}
		}

		if (tooLate && !inEditor)
		{
			if (alpha > 0.3)
				alpha = 0.3;
		}
	}

	public function followStrumNote(myStrum:StrumNote, fakeCrochet:Float, songSpeed:Float = 1)
	{
		var strumX:Float = myStrum.x;
		var strumY:Float = myStrum.y;
		var strumAngle:Float = myStrum.angle;
		var strumAlpha:Float = myStrum.alpha;
		var strumDirection:Float = myStrum.direction;

		distance = (0.45 * (Conductor.songPosition - strumTime) * songSpeed * multSpeed);
		if (!myStrum.downScroll) distance *= -1;

		var angleDir = strumDirection * Math.PI / 180;
		if (copyAngle)
			angle = strumDirection - 90 + strumAngle + offsetAngle;

		if(copyAlpha)
			alpha = strumAlpha * multAlpha;

		if(copyX)
			x = strumX + offsetX + Math.cos(angleDir) * distance;

		if(copyY)
		{
			y = strumY + offsetY + correctionOffset + Math.sin(angleDir) * distance;
			if(myStrum.downScroll && isSustainNote)
			{
				if(PlayState.isPixelStage)
				{
					y -= PlayState.daPixelZoom * 9.5;
				}
				y -= (frameHeight * scale.y) - (Note.swagWidth / 2);
			}
		}
	}

	public function clipToStrumNote(myStrum:StrumNote)
	{
		var center:Float = myStrum.y + offsetY + Note.swagWidth / 2;
		if(isSustainNote && (mustPress || !ignoreNote) &&
			(!mustPress || (wasGoodHit || (prevNote.wasGoodHit && !canBeHit))))
		{
			var swagRect:FlxRect = clipRect;
			if(swagRect == null) swagRect = new FlxRect(0, 0, frameWidth, frameHeight);

			if (myStrum.downScroll)
			{
				if(y - offset.y * scale.y + height >= center)
				{
					swagRect.width = frameWidth;
					swagRect.height = (center - y) / scale.y;
					swagRect.y = frameHeight - swagRect.height;
				}
			}
			else if (y + offset.y * scale.y <= center)
			{
				swagRect.y = (center - y) / scale.y;
				swagRect.width = width / scale.x;
				swagRect.height = (height / scale.y) - swagRect.y;
			}
			clipRect = swagRect;
		}
	}

	@:noCompletion
	override function set_clipRect(rect:FlxRect):FlxRect
	{
		clipRect = rect;

		if (frames != null)
			frame = frames.frames[animation.frameIndex];

		return rect;
	}
}