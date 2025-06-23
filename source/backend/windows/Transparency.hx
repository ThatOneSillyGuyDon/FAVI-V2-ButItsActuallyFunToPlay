package backend.windows;

@:cppFileCode('#include <windows.h>\n#include <dwmapi.h>\n\n#pragma comment(lib, "Dwmapi")')
class Transparency
{
	@:functionCode('
        HWND hWnd = GetActiveWindow();
        res = SetWindowLong(hWnd, -20, 0x00080000);
        if (res)
        {
            SetLayeredWindowAttributes(hWnd, 0x131313, 0, 0x00000001);
        }
    ')
	static public function getWindowsTransparent(res:Int = 0)
	{
		return res;
	}

	@:functionCode('
        HWND hWnd = GetActiveWindow();
        res = SetWindowLong(hWnd, -20, 0x00000000);
        if (res)
        {
            SetLayeredWindowAttributes(hWnd, 0x131313, 1, LWA_COLORKEY);
        }
    ')
	static public function getWindowsbackward(res:Int = 0)
	{
		return res;
	}
}
