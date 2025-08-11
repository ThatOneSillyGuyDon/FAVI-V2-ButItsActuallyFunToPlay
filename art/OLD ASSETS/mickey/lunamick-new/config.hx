function loadAnimations()
{
	addByPrefix('idle', 'Mickey2 Idle', 11);

	addByPrefix('singUP', 'Mickey2 Up', 11, false);
	addByPrefix('singLEFT', 'Mickey2 Left', 11, false);
	addByPrefix('singRIGHT', 'Mickey2 Right', 11, false);
	addByPrefix('singDOWN', 'Mickey2 Down', 11, false);

	addOffset('idle', -5, 0);

	addOffset('singUP', 0, 0);
	addOffset('singLEFT', -18, 0);
	addOffset('singRIGHT', 0, 10);
	addOffset('singDOWN', 10, 2);

	playAnim('idle');

	characterData.antialiasing = true;
	characterData.flipX = false;

	setBarColor([121, 121, 121]);
	setCamOffsets(420, 370);
    setOffsets(-690, 2000);
	setGraphicSize(get('width') * 0.6);
}