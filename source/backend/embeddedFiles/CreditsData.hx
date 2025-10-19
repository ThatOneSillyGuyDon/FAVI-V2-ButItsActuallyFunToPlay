package backend.embeddedFiles;

enum abstract CreditsData(String) from String to String {
    var dontCross1:String = '{
	"settings":
		[
			"Art: Domingo & Moe\n\nChart: Dreupy\n\nCode: ThatOneSillyGuy\n\nMusic: Lasagnacat", 25, -25
		]
	}';
    var dontCross2:String = '{
	"settings":
		[
			"Art: Domingo & Moe\n\nChart: Purg\n\nCode: ThatOneSillyGuy\n\nMusic: Lasagnacat", 25, -25
		]
	}';
    var dontCross3:String = '{
	"settings":
		[
			"Art: Domingo & Moe\n\nChart: ThatOneSillyGuy\n\nCode: ThatOneSillyGuy\n\nMusic: Lasagnacat", 25, -25
		]
	}';
	// In Case You'll add the dealthly chart
	var dontCross4:String = '{
		"settings":
		[
			"Art: Domingo & Moe\n\nChart: MalyPlus\n\nCode: ThatOneSillyGuy\n\nMusic: Lasagnacat", 25, -25
		]
	}';

	var dontCross5:String = '{
		"settings":
		[
			"Art: Domingo & Moe\n\nChart: rezeo285\n\nCode: ThatOneSillyGuy\n\nMusic: Lasagnacat", 25, -25
		]
	}';
    var malfunction:String = '{
	"settings":
		[
			"Art: ThatOneSillyGuy, 8tastic &\njaooazul\n\nChart: ThatOneSillyGuy\n\nCode: ThatOneSillyGuy\n\nMusic: obscurity.", -13, -25
		]
	}';
    var scrapped:String = '{
	"settings":
		[
			"Art: Ms.IDK, & Teelbe\n\nChart: Dreupy\n\nCode: ThatOneSillyGuy\n\nMusic: Lasagnacat", 20, -25
		]
	}';
	var wbb:String = '{
	"settings":
	[
		"Art: N/A\n\nChart: ThatOneSillyGuy (for now\ncause i\'m too lazy to find purg\'s chart)\n\nCode: ThatOneSillyGuy\n\nMusic: inneaux & Sayan Sama", -48, 20
	]
}';
}