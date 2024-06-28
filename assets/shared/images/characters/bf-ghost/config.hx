function loadAnimations()
{
	addByPrefix('idle', 'BlessBf idle', 10);
	addByPrefix('singUP', 'BlessBf up', 24, false);
	addByPrefix('singLEFT', 'BlessBf left', 24, false);
	addByPrefix('singRIGHT', 'BlessBf right', 24, false);
	addByPrefix('singDOWN', 'BlessBf down', 24, false);

	addOffset("idle", 568, 1010);
	addOffset("singRIGHT", 598, 1030);
	addOffset("singDOWN", 623, 1040);
	addOffset("singLEFT", 650, 1080);
	addOffset("singUP", 550, 970);

	playAnim('idle');

	characterData.antialiasing = true;
	characterData.flipX = true;

	setBarColor([49, 176, 209]);
	setCamOffsets(-300, -500);
	setOffsets(0, 0);
	setGraphicSize(get('width') * 0.5);
}
