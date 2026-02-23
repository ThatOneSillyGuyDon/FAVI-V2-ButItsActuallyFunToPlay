@echo off
color 0a
cd ..
@echo on
echo Installing dependencies.
haxelib set away3d 5.0.9
haxelib set lime 8.2.2
haxelib set openfl 9.4.1
haxelib set flixel 5.7.0
haxelib set flixel-addons 3.2.2
haxelib set flixel-tools 1.5.1
haxelib set hscript-iris 1.1.3
haxelib set hscript 2.7.0
haxelib set tjson 1.4.0
haxelib git hxvlc https://github.com/MAJigsaw77/hxvlc a1ac9900248209a91a9a9c1ebc1ae8af5dfdfb86
haxelib remove flxanimate
haxelib git flxanimate https://github.com/ShadowMario/flxanimate dev
haxelib git linc_luajit https://github.com/superpowers04/linc_luajit
haxelib set hxdiscord_rpc 1.2.4
haxelib set hxcpp 4.3.2
echo Finished!
pause
