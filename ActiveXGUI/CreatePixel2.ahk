;*******************************************************
; Want a clear path for learning AutoHotkey; Take a look at our AutoHotkey Udemy courses.  They're structured in a way to make learning AHK EASY
; Right now you can  get a coupon code here: https://the-Automator.com/Learn
;*******************************************************
;~ #Include <default_Settings>
#Include <GDIP>
CreateBMP("0x00ff00",500,"c:\temp\bmp\test.bmp") ;white=0xffffff, Red=0xff0000, Blue=0x0000ff, Green=0x00ff00

;**************************************
CreateBMP(PixelColor,PixelDim,FilePath){
	; Borrowed & adapted from https://www.autohotkey.com/board/topic/58056-solvedgdi-changes-pixel-color-when-saving-to-file/
	SetFormat, Integer, hex
	FileDelete,% FilePath ;Delete the picture if already there	
	
;********************Start GDI and make sure it returns a token***********************************
	If !pToken := Gdip_Startup(){ ;Start GDI, if fail, show message box
		MsgBox, 48, error, GDIP failed to start.`nPlease ensure you have the GDI library and `nUse an #include or put in your Library`nYou can get my copy here: `nhttps://the-Automator.com/GDIP
		Return
	}
	
;********************Create a gdi+ bitmap for the Outfile***********************************
	pBitmapOutFile := Gdip_CreateBitmap(PixelDim,PixelDim)
	loop, % PixelDim {
		h := A_Index-1
		loop, % PixelDim {
			Gdip_SetPixel(pBitmapOutFile,A_Index-1,h,PixelColor) ; set all pixel color
		}
	}
	Gdip_SaveBitmapToFile(pBitmapOutFile,FilePath, 100) ; save the BMP file
	Gdip_DisposeImage(pBitmapInFile) ; Dispose of InFile
	Gdip_Shutdown(pToken) ; ...and gdi+ may now be shutdown
}