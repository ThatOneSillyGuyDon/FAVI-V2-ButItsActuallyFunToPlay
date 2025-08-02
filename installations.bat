@echo off
color 0a
cd ..
@echo on
echo Installing dependencies.
haxelib set lime 8.1.1
haxelib set openfl 9.2.2
haxelib set flixel 5.6.1
haxelib set flixel-addons 3.0.2
haxelib set flixel-ui 2.5.0
haxelib set hscript 2.5.0
haxelib set hxCodec 2.5.1
haxelib set tjson 1.4.0
haxelib remove flxanimate
haxelib git flxanimate https://github.com/ShadowMario/flxanimate dev
haxelib git linc_luajit https://github.com/superpowers04/linc_luajit
haxelib set hxdiscord_rpc 1.2.4
haxelib set hxcpp 4.3.2
haxelib set hxvlc 1.2.0
haxelib git fnf-modcharting-tools https://github.com/TheZoroForce240/FNF-Modcharting-Tools
echo Finished!
pause
