function onSongStart()
{   
    modManager.queueSet(624, "reverse", 1, 1);
    modManager.queueEase(992, 998, "reverse", 0, "expoInOut", 1);
    modManager.queueEase(992, 998, "reverse", 1, "expoInOut", 0);

    modManager.queueEase(1120, 1131, "reverse", 0, "expoInOut", 0);
    modManager.queueEase(1120, 1131, "localrotateZ", ClientPrefs.downScroll ? 1.575 : -1.575, 'expoInOut', 1);

    modManager.queueEase(1360, 1371, "localrotateZ", 0, 'expoInOut', 1);

    //
    if (!ClientPrefs.downScroll)
    {
        modManager.queueEase(1630, 1630 + 11, "opponentSwap", -10, 'quartOut', 1);
        modManager.queueEase(1630, 1630 + 11, "transform0X", -632.5, 'quartOut', 0);
        modManager.queueEase(1630, 1630 + 11, "transform1X", -522.5, 'quartOut', 0);
        modManager.queueEase(1630, 1630 + 11, "transform1Y", 175, 'quartOut', 0);

        modManager.queueEase(1630, 1630 + 11, "reverse2", 1, 'quartOut', 0);
        modManager.queueEase(1630, 1630 + 11, "transform2X", -225, 'quartOut', 0);
        modManager.queueEase(1630, 1630 + 11, "transform2Y", -175, 'quartOut', 0);

        modManager.queueEase(1630, 1630 + 11, "reverse3", 1, 'quartOut', 0);
    }
    else
    {
        modManager.queueEase(1630, 1630 + 11, "opponentSwap", -10, 'quartOut', 1);
        
        modManager.queueEase(1630, 1630 + 11, "transform0X", -632.5, 'quartOut', 0);
        modManager.queueEase(1630, 1630 + 11, "transform1X", -522.5, 'quartOut', 0);
        modManager.queueEase(1630, 1630 + 11, "transform1Y", 175, 'quartOut', 0);

        modManager.queueEase(1630, 1630 + 11, "reverse1", 1, 'quartOut', 0);
        modManager.queueEase(1630, 1630 + 11, "transform2X", -225, 'quartOut', 0);
        modManager.queueEase(1630, 1630 + 11, "transform2Y", -175, 'quartOut', 0);

        modManager.queueEase(1630, 1630 + 11, "reverse0", 1, 'quartOut', 0);
    }
    //

    modManager.queueSet(1900, "opponentSwap", 4, 1);
    modManager.queueSet(1900, "opponentSwap", 2, 0);
    modManager.queueSet(1900, "transform0X", 0, 0);
    modManager.queueSet(1900, "transform1X", 0, 0);
    modManager.queueSet(1900, "transform1Y", 0, 0);

    modManager.queueSet(1900, "reverse2", 0, 0);
    modManager.queueSet(1900, "reverse1", 0, 0);
    modManager.queueSet(1900, "transform2X", 0, 0);
    modManager.queueSet(1900, "transform2Y", 0, 0);

    modManager.queueSet(1900, "transformZ", -0.75, 1);
    if (ClientPrefs.opponentStrums)
        modManager.queueSet(1920, "alpha", 0.75, 1);
    modManager.queueSet(1900, "reverse", 1, 1);

    modManager.queueSet(1900, "reverse3", 0, 0);
    modManager.queueSet(1900, "reverse0", 0, 0);

    modManager.queueEase(1920, 484 * 4, "opponentSwap", 1, "expoOut", 1);
    modManager.queueEase(508 * 4, 512 * 4, "opponentSwap", 1, "expoOut", 0);

    modManager.queueEase(2685, 2735, "opponentSwap", 4, "sineInOut", 1);
    modManager.queueEase(2685, 2735, "opponentSwap", 2, "sineInOut", 0);

    modManager.queueSet(2975, "opponentSwap", 0, 0);
    modManager.queueSet(2975, "opponentSwap", 0, 1);

    modManager.queueSet(2975, "transformZ", 0, 1);
    if (ClientPrefs.opponentStrums)
        modManager.queueSet(2975, "alpha", 0, 1);
    modManager.queueSet(2975, "reverse", 0, 1);

    modManager.queueEase(4030, 4030 + 24, "confusion0", -120, "bounceOut", 1);
    modManager.queueEase(4030, 4030 + 24, "confusion1", 67, "bounceOut", 1);
    modManager.queueEase(4030, 4030 + 24, "confusion2", 99, "bounceOut", 1);
    modManager.queueEase(4030, 4030 + 24, "confusion3", -50, "bounceOut", 1);

    modManager.queueEase(4048, 4048 + 24, "transform0Y", !ClientPrefs.downScroll ? 1080 : -1080, "bounceOut", 1);
    modManager.queueEase(4049, 4049 + 24, "transform1Y", !ClientPrefs.downScroll ? 772 : -772, "bounceOut", 1);
    modManager.queueEase(4050, 4050 + 24, "transform2Y", !ClientPrefs.downScroll ? 950 : -950, "bounceOut", 1);
    modManager.queueEase(4051, 4051 + 24, "transform3Y", !ClientPrefs.downScroll ? 690 : -690, "bounceOut", 1);

    modManager.queueEase(4072, 4072 + 20, "transformZ", -0.25, "sineInOut", 0);
    modManager.queueEase(4072, 4072 + 20, "transformY", ClientPrefs.downScroll ? 67 : -67, "sineInOut", 0);
    modManager.queueEase(4072, 4072 + 20, "transformX", -300, "sineInOut", 0);

    if (ClientPrefs.opponentStrums)
        modManager.queueSet(4096, "alpha", 0.6, 1);
    modManager.queueSet(4096, "reverse", 1, 1);
    modManager.queueSet(4096, "transformZ", 0.3, 1);
    modManager.queueSet(4096, "speed", 0, 1);
    modManager.queueSet(4096, "transform0Y", !ClientPrefs.downScroll ? 150 : -150, 1);
    modManager.queueSet(4096, "transform1Y", !ClientPrefs.downScroll ? 150 : -150, 1);
    modManager.queueSet(4096, "transform2Y", !ClientPrefs.downScroll ? 150 : -150, 1);
    modManager.queueSet(4096, "transform3Y", !ClientPrefs.downScroll ? 150 : -150, 1);

    modManager.queueSet(4096, "transform0X", 150, 1);
    modManager.queueSet(4096, "transform1X", 200, 1);
    modManager.queueSet(4096, "transform2X", 420, 1);
    modManager.queueSet(4096, "transform3X", 500, 1);

    modManager.queueSet(704, "drunkSpeed", 1100, 1);
    modManager.queueSet(704, "drunk", 0.05, 1);

    modManager.queueSet(864, "drunkSpeed", 1000, 0);
    modManager.queueSet(864, "drunk", 0.015, 0);

    modManager.queueSet(1888, "drunkSpeed", 0.15, 1);
    modManager.queueSet(1888, "drunk", 0.3, 1);

    modManager.queueSet(2976, "drunkSpeed", 1000, 1);
    modManager.queueSet(2976, "drunk", 0.1, 1);

    modManager.queueSet(736 * 4, "speed", 1.5, 1);

    modManager.queueSet(3520, "drunkSpeed", 1000, 1);
    modManager.queueSet(3520, "drunk", 0.15, 1);
    modManager.queueSet(3520, "drunkZSpeed", 1000, 1);
    modManager.queueSet(3520, "drunkZ", 0.1, 1);

    modManager.queueSet(3776, "drunk", 0.2, 1);
    modManager.queueSet(3776, "drunkZ", 0.2, 1);
}