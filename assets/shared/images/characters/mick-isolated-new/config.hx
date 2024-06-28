function loadAnimations()
	{
		setFrames("mick-isolated-new", "images/characters");
		addByPrefix('idle', 'idle', 9, false);
		addByPrefix('singLEFT', 'left', 9, false);
		addByPrefix('singDOWN', 'down', 9, false);
		addByPrefix('singUP', 'up', 9, false);
		addByPrefix('singRIGHT', 'right', 9, false);
	
		if (!isPlayer)
		{
			addOffset("idle", 0, 0);
			addOffset("singLEFT", -2, 0);
			addOffset("singDOWN", 1, 0);
			addOffset("singUP", 8, 4);
			addOffset("singRIGHT", -3, 0);
			characterData.camOffsets = [90, 60];
			characterData.offsets = [0, -350];
		}

		setScale(0.6, 0.6);
		setIcon('mick-isolated-new');
		setBarColor([216, 216, 216]);
	
		playAnim('idle');
	}
	