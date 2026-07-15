function onCreatePost()
{
    switch (PlayState.SONG.song)
	{
		case "Rotten Petals":
			audio.inst.loadEmbedded(Paths.music("aviOST/rottenPetals"));
		case "Seeking Freedom":
			audio.inst.loadEmbedded(Paths.music("aviOST/seekingFreedom"));
		case "Curtain Call":
			audio.inst.loadEmbedded(Paths.music("aviOST/curtainCall"));
		case "Mistful Wind":
			audio.inst.loadEmbedded(Paths.music("aviOST/gameOver/mistfulWind"));
		case "Am I Real?":
			audio.inst.loadEmbedded(Paths.music("aviOST/gameOver/amIReal"));
		case "Your Final Bow":
			audio.inst.loadEmbedded(Paths.music("aviOST/gameOver/yourFinalBow"));
		case "The Wretched Tilezones (Simple Life)":
			audio.inst.loadEmbedded(Paths.music("aviOST/pause/theWretchedTilezones"));
		case "Ahh the Scary (Somber Night)":
			audio.inst.loadEmbedded(Paths.music("aviOST/pause/somberNight"));
		case "Ship the Fart Yay Hooray <3 (Distant Stars)":
			audio.inst.loadEmbedded(Paths.music("aviOST/pause/shipTheFartYayHoorayv3v"));
		case "Alone":
			audio.inst.loadEmbedded(Paths.music("aviOST/alone"));
	}
}