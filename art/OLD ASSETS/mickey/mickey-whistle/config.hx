function loadAnimations()
	{
		setFrames("mickey-whistle", "images/characters");
		addByPrefix('singLEFT', 'left instance 1', 15, false);
		addByPrefix('singDOWN', 'down instance 1', 15, false);
		addByPrefix('singUP', 'up instance 1', 15, false);
		addByPrefix('singRIGHT', 'right instance 1', 15, false);
	
		if (!isPlayer)
		{
			addOffset("singLEFT", -351, -353);
			addOffset("singDOWN", -414, -405);
			addOffset("singUP", -393, -307);
			addOffset("singRIGHT", -417, -348);
			characterData.camOffsets = [360, 360];
			characterData.offsets = [0, -350];
		}

		setScale(1, 1);
		setIcon('mick-isolated-new');
		setBarColor([216, 216, 216]);
	}
	