SC_SCREEN := 0
SC_ACTIVE := 1
SC_ACTIVECLIENT := 2
SC_WINDOW := 3

; F12::
; {
; 	image := ScreenShot.FromActiveWindow()
; 	image.Show()
; 	return
; }

class ScreenShot
{

	static FromScreen(Monitor:=1, Cursor:=true, bTaskbar:=false) => ScreenShot.Capture(SC_SCREEN, Monitor, Cursor, bTaskbar)
	static FromActiveWindow() => ScreenShot.Capture(SC_ACTIVE)
	static FromActiveClient() => ScreenShot.Capture(SC_ACTIVECLIENT)
	; FromWindow(title) => ScreenShot.Capture(SC_WINDOW, title)
	; static FromClient(title) => ScreenShot.Capture(SC_ACTIVECLIENT)
	; FromHWND(hwnd) => ScreenShot.Capture(SC_WINDOW, hwnd)

	static Capture(region, info:=1, bCursor:=true, bTaskbar:=false, coords?)
	{
		static BI_RGB         := 0x0000
		static SRCCOPY        := 0x00CC0020 ; dest = source
		static CAPTUREBLT     := 0x40000000 ; Include layered windows

		ScreenShot.CheckArgs(region, info, bCursor, bTaskbar, coords??unset)

		hWnd        := 0 ; Main Screen
		compression := BI_RGB
		if region is Object
		{

			x := region.x
			y := region.y
			w := region.w
			h := region.h
		}
		else
		{
			switch region
			{
			case SC_SCREEN:
				MonitorGetWorkArea(info, &x, &y, &w, &h)

				if bTaskbar && h != A_ScreenHeight
					h += 30 ; get Taskbar
			case SC_ACTIVE:
				activeWin := WinExist('A')
				oldStyle := WinGetStyle()
				; WinSetStyle
				WinGetPos(&x, &y, &w, &h, 'A')
				x += 8
				w -= 16
				h -= 8
			case SC_ACTIVECLIENT:
				WinGetClientPos(&x, &y, &w, &h, 'A')
			case SC_WINDOW:
				hWnd := WinExist(info)
				WinGetPos(&x, &y, &w, &h, info)
			}
		}

		if !hdcSrc := DllCall('User32\GetDC', 'uint', hWnd) ; [in] HWND hWnd
			throw Error('Could not get the Device Context', A_ThisFunc, 'User32\GetDC')

		if !hdcDst := DllCall('Gdi32\CreateCompatibleDC', 'uint', hdcSrc) ; [in] HDC hdc
			throw Error('Could not get a compatible Device Context', A_ThisFunc, 'Gdi32\CreateCompatibleDC')

		; BITMAPINFO structure
		; https://learn.microsoft.com/en-us/windows/win32/api/wingdi/ns-wingdi-bitmapinfo


		;BITMAPINFOHEADER structure
			;https://learn.microsoft.com/en-us/previous-versions/dd183376(v=vs.85)
		NumPut 'uint'  , 40,          ; DWORD biSize;
		       'uint'  , w,           ; LONG  biWidth;
		       'uint'  , h,           ; LONG  biHeight;
		       'ushort', 1,           ; WORD  biPlanes;
		       'ushort', 32,          ; WORD  biBitCount;
		       'uint'  , Compression, ; DWORD biCompression;
		       'uint'  , 0,           ; DWORD biSizeImage;
		       'uint'  , 0,           ; LONG  biXPelsPerMeter;
		       'uint'  , 0,           ; LONG  biYPelsPerMeter;
		       'uint'  , 0,           ; DWORD biClrUsed;
		       'uint'  , 0,           ; DWORD biClrImportant;

			; RGBQUAD structure
			; https://learn.microsoft.com/en-us/windows/win32/api/wingdi/ns-wingdi-rgbquad
		       'char'  , 0,           ; BYTE rgbBlue;
		       'char'  , 0,           ; BYTE rgbGreen;
		       'char'  , 0,           ; BYTE rgbRed;
		       'char'  , 0,           ; BYTE rgbReserved;
		        bmi := Buffer(44, 0)

		if !HBITMAP := DllCall('Gdi32\CreateDIBSection',
		                       'uint', hdcSrc,      ; [in]  HDC              hdc,
		                       'ptr' , bmi,         ; [in]  const BITMAPINFO *pbmi,
		                       'uint', 0,           ; [in]  UINT             usage,
		                       'ptr*', &vbits:=0,   ; [out] VOID             **ppvBits,
		                       'ptr' , 0,           ; [in]  HANDLE           hSection,
		                       'uint', 0)           ; [in]  DWORD            offset
			throw Error('Could not create the DIB section', A_ThisFunc, 'Gdi32\CreateDIBSection')

		if !oBM := DllCall('Gdi32\SelectObject',
		                   'uint', hdcDst,  ; [in] HDC     hdc,
		                   'uint', HBITMAP) ; [in] HGDIOBJ h
			throw Error('Could not select the object', A_ThisFunc, 'Gdi32\SelectObject')

		if !DllCall('Gdi32\BitBlt',
		            'ptr',  hdcDst,             ; [in] HDC   hdc,
		            'int' , 0,                  ; [in] int   x,
		            'int' , 0,                  ; [in] int   y,
		            'int' , w,                  ; [in] int   cx,
		            'int' , h,                  ; [in] int   cy,
		            'ptr',  hdcSrc,             ; [in] HDC   hdcSrc,
		            'int' , x,                  ; [in] int   x1,
		            'int' , y,                  ; [in] int   y1,
		            'uint', CAPTUREBLT|SRCCOPY) ; [in] DWORD rop
			throw Error('Could not perform bit block transfer', A_ThisFunc,
			            'Gdi32\BitBlt: ' A_LastError)

		If bCursor
		{
			; CaptureCursor(hdcDst, nL, nT)

			; CURSORINFO structure
			; https://learn.microsoft.com/en-us/windows/win32/api/winuser/ns-winuser-cursorinfo
			cbSize := A_PtrSize+16
			NumPut 'uint', cbSize,  ; DWORD   cbSize;
			       'uint', 0,       ; DWORD   flags;
			       'Ptr' , 0,       ; HCURSOR hCursor;

			       ; POINT structure
			       ; https://learn.microsoft.com/en-us/previous-versions/dd162805(v=vs.85)
			       'int' , 0,       ; LONG x;
			       'int' , 0,       ; LONG y;
			        pci := Buffer(cbSize)

			if !DllCall('User32\GetCursorInfo',
			            'Ptr', pci) ; [in, out] PCURSORINFO pci
				throw Error('Could not get the cursor information', A_ThisFunc,
				            'User32\GetCursorInfo: ' A_LastError)

			; CURSORINFO structure
			; https://learn.microsoft.com/en-us/windows/win32/api/winuser/ns-winuser-cursorinfo
			bShow   := NumGet(pci, 4, 'uint')                ; DWORD   flags;
			hCursor := NumGet(pci, 8, 'ptr')                 ; HCURSOR hCursor;
			xCursor := NumGet(pci, 8 + A_PtrSize, 'int')     ; LONG x;
			yCursor := NumGet(pci, 8 + A_PtrSize + 4, 'int') ; LONG y;

			pIconInfo := Buffer(A_PtrSize = 8 ? 28 : 20)
			if !DllCall('User32\GetIconInfo',
			            'uint', hCursor,   ; [in]  HICON     hIcon,
			            'Ptr' , pIconInfo) ; [out] PICONINFO piconinfo
				throw Error('Could not get the cursor icon information', A_ThisFunc,
				            'User32\GetIconInfo: ' A_LastError)

			; ICONINFO structure
			; https://learn.microsoft.com/en-us/windows/win32/api/winuser/ns-winuser-iconinfo
			fIcon    := NumGet(pIconInfo,0, 'int')               ; BOOL    fIcon;
			xHotspot := NumGet(pIconInfo,4, 'uint')              ; DWORD   xHotspot;
			yHotspot := NumGet(pIconInfo,8, 'uint')              ; DWORD   yHotspot;
			hBMMask  := NumGet(pIconInfo,12, 'ptr')              ; HBITMAP hbmMask;
			hBMColor := NumGet(pIconInfo,12 + A_PtrSize, 'ptr')  ; HBITMAP hbmColor;

			if bShow
				if !DllCall('User32\DrawIcon',
				            'uint', hdcDst,                    ;  [in] HDC   hDC,
				            'int' , xCursor - xHotspot - x,    ;  [in] int   X,
				            'int' , yCursor - yHotspot - y,    ;  [in] int   Y,
				            'uint', hCursor)                   ;  [in] HICON hIcon
					throw Error('Could not draw the cursor icon', A_ThisFunc,
					            'User32\DrawIcon: ' A_LastError)

			if hBMMask
				DllCall 'Gdi32\DeleteObject',
				        'uint', hBMMask  ; [in] HGDIOBJ ho
			if hBMColor
				DllCall 'Gdi32\DeleteObject',
				        'uint', hBMColor ; [in] HGDIOBJ ho
		}

		if !DllCall('Gdi32\SelectObject',
		            'uint', hdcDst, ; [in] HDC     hdc,
		            'uint', oBM)    ; [in] HGDIOBJ h
			throw Error('Could not replace the object in the destination', A_ThisFunc, 'Gdi32\SelectObject')

		DllCall 'User32\ReleaseDC',
		        'uint', hWnd,   ; [in] HWND hWnd,
		        'uint', hdcSrc  ; [in] HDC  hDC

		DllCall 'Gdi32\DeleteDC', 'uint', hdcDst ; [in] HDC hdc

		return ScreenShot.Image(HBITMAP)
	}

	static ImprovedCapture()
	{

	}

	static CheckArgs(region, info, bCursor, bTaskbar, coords?) {
		OutputDebug region is Object
		if !(region is Object) && (region < SC_SCREEN || region > SC_WINDOW)
			throw ValueError( 'Invalid region type.`nValid types are:`n`nSC_SCREEN`nSC_ACTIVE`nSC_ACTIVECLIENT`n'
			                . 'SC_WINDOW'
			                , A_ThisFunc
			                , 'region: ' region)
		if region is Object
		&& (!region.HasProp('x') || !region.HasProp('y') || !region.HasProp('w') || !region.HasProp('h'))
			throw ValueError('This Parameter must be an object', A_ThisFunc, 'region')
		if bCursor  ~= '[^01]'
			throw ValueError('This Parameter must be true or false', A_ThisFunc, 'bCursor: ' bCursor)
		if bTaskbar ~= '[^01]'
			throw ValueError('This Parameter must be true or false', A_ThisFunc, 'bCursor: ' bTaskbar)
	}

	class Image
	{
		static hBitmap := 0

		path := ''
		main := Gui('', 'Screen Image - ' A_Now)

		__New(hBitmap)
		{
			this.hBitmap := hBitmap
			return this
		}

		__Delete() => DllCall('DeleteObject', 'uint', this.hBitmap)

		Show(region?, impath:='', caption:=true)
		{
			main := this.main
			main.Opt((caption ? '+' : '-') 'Caption')
			main.OnEvent('Escape', (*)=>main.Hide())

			if IsSet(region)
				w := region.w, h := region.h

			main.OnEvent('Close', (*)=>main.Destroy())
			main.MarginX := main.MarginY := 0

			this.Save(impath)
			main.AddPicture('w' ( w??A_ScreenWidth -200) ' h' (h??-1), impath)
			main.Show()
		}

		CopytoClipboard()
		{
			static CF_DIB := 8

			if WinExist('Screen Image')
				throw Error('This function cannot work when using the ScreenShot.Show() function first')

			pv := Buffer(84)
			if !DllCall('GetObject',
			            'uint', this.hBitmap, ; [in]  HANDLE h,
			            'int' , pv.size,      ; [in]  int    c,
			            'ptr' , pv)           ; [out] LPVOID pv
				throw Error('Could not get the HBITMAP object')

			if !hDIB := DllCall('GlobalAlloc',
			                    'uint', 2,                            ; [in] UINT   uFlags,
			                    'uint', 40 + NumGet(pv, 44, 'uint'))  ; [in] SIZE_T dwBytes
				throw Error('Could not allocate memory for copying')

			if !pDIB := DllCall('GlobalLock',
			                    'uint', hDIB) ; [in] HGLOBAL hMem
				throw Error('Could not lock memory for copying')

			DllCall 'RtlMoveMemory',
			        'uint', pDIB,        ; _Out_       VOID UNALIGNED *Destination,
			        'uint', pv.ptr + 24, ; _In_  const VOID UNALIGNED *Source,
			        'uint', 40           ; _In_        SIZE_T         Length

			DllCall 'RtlMoveMemory',
			        'uint', pDIB + 40,              ; _Out_       VOID UNALIGNED *Destination,
			        'uint', NumGet(pv, 20,'uint'),  ; _In_  const VOID UNALIGNED *Source,
			        'uint', NumGet(pv, 44, 'uint')  ; _In_        SIZE_T         Length

			DllCall 'GlobalUnlock',
			        'uint', hDIB ; [in] HGLOBAL hMem

			if !DllCall('OpenClipboard', 'ptr', 0) ; [in, optional] HWND hWndNewOwner
				throw Error('Could not open the clipboard')

			if !DllCall('EmptyClipboard')
				throw Error('Could not empty the clipboard')

			if !DllCall('SetClipboardData',
			            'uint', CF_DIB, ; [in]           UINT   uFormat,
			            'uint', hDIB)   ; [in, optional] HANDLE hMem
				throw Error('Could not set the clipboard data')

			DllCall 'CloseClipboard'
		}

		Save(sFile := A_Temp '\screen.png')
		{
			oi := Buffer(84)
			DllCall('GetObject',
			        'uint', this.hBitmap, ; [in]  HANDLE h,
			        'int' , oi.size,      ; [in]  int    c,
			        'ptr' , oi)           ; [out] LPVOID pv

			hFile := DllCall("CreateFile", "Uint", StrPtr(sFile), "Uint", 0x40000000, "Uint", 0, "Uint", 0, "Uint", 2, "Uint", 0, "Uint", 0)
			DllCall("WriteFile", "Uint", hFile, "int64P", 0x4D42|14+40+NumGet(oi,44, 'int')<<16, "Uint", 6, "UintP", 0, "Uint", 0)
			DllCall("WriteFile", "Uint", hFile, "int64P", 54<<32, "Uint", 8, "UintP", 0, "Uint", 0)
			DllCall("WriteFile", "Uint", hFile, "Uint", oi.ptr+24, "Uint", 40, "UintP", 0, "Uint", 0)
			DllCall("WriteFile", "Uint", hFile, "Uint", NumGet(oi,20, 'int'), "Uint", NumGet(oi,44, 'int'), "UintP", 0, "Uint", 0)
			DllCall("CloseHandle", "Uint", hFile)

			return this.path := sFile
		}
	}
}