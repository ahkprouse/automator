/**
 * =========================================================================== *
 * Want a clear path for learning AutoHotkey?                                  *
 * Take a look at our AutoHotkey courses here: the-Automator.com/Discover      *
 * They're structured in a way to make learning AHK EASY                       *
 * And come with a 200% moneyback guarantee so you have NOTHING to risk!       *
 * =========================================================================== *
 * @author      the-automator                                                  *
 * @version     0.4.1                                                          *
 * @copyright   Copyright (c) 2024 The Automator                               *
 * @link        https://www.the-automator.com/                                 *
 * @created     2025-01-01                                                     *
 * @modified    2025-01-01                                                     *
 * @description                                                                *
 * =========================================================================== *
 */

;@Ahk2Exe-SetVersion     0.4.1
;@Ahk2Exe-SetProductName Image2Clipboard
;@Ahk2Exe-SetDescription Allows you to select an image and load it to the clipboard

#SingleInstance,Force
forceRunAHK32Bit() ; this will restart the script into 32 bit AHK v1
Menu, Tray, Icon , C:\Windows\system32\imageres.dll, 243 ; setting tray icon

^1::ImageToClipboard("C:\Users\AA\Desktop\Clean\100.png") ;Control+1 grabs Motersday image
^2::ImageToClipboard("B:\pic\MothersDay2.png") ;Control+2 grabs second pic
return

ImageToClipboard(File_Path){

	if !fileexist(File_Path)
	{
		MsgBox, 16, Error, File not found: %File_Path%
		return 
	}
	ClipOld:=ClipboardAll ;backup clipboard
	pToken	:= Gdip_Startup() ;create GDI token
	hBitmap	:= Gdip_CreateHBITMAPFromBitmap(Gdip_CreateBitmapFromFile(File_Path)) ;Create hbitmap from pbitmap
	Gdip_Shutdown(pToken) ;clean up gdip
	SetClipboardData(8,hBitmap) ;Shove image into clipboard
	DllCall("DeleteObject","Uint",hBitmap) ;now clean up hBitmap memory
	Send,^v ;send paste
	Sleep,50 ;sleep for a bit
	clipboard:=ClipOld ;restore clipboard
}
Return

;~ https://autohotkey.com/board/topic/23162-how-to-copy-a-file-to-the-clipboard/page-2#entry151138
SetClipboardData(nFormat,hBitmap){
	DllCall("GetObject","Uint",hBitmap,"int",VarSetCapacity(oi,84,0),"Uint",&oi)
	hDBI :=DllCall("GlobalAlloc","Uint",2,"Uint",40+NumGet(oi,44))
	pDBI :=DllCall("GlobalLock","Uint",hDBI)
	DllCall("RtlMoveMemory","Uint",pDBI,"Uint",&oi+24,"Uint",40)
	DllCall("RtlMoveMemory","Uint",pDBI+40,"Uint",NumGet(oi,20),"Uint",NumGet(oi,44))
	DllCall("GlobalUnlock","Uint",hDBI)
	DllCall("OpenClipboard","Uint",0)
	DllCall("EmptyClipboard")
	DllCall("SetClipboardData","Uint",nFormat,"Uint",hDBI)
	DllCall("CloseClipboard")
}

;********************Functions from GDIP library***********************************
Gdip_Startup(){
	Ptr := A_PtrSize ? "UPtr" : "UInt"
	pToken := 0	
	if !DllCall("GetModuleHandle","str","gdiplus",Ptr)
		DllCall("LoadLibrary","str","gdiplus")
	VarSetCapacity(si,A_PtrSize = 8 ? 24 : 16,0),si := Chr(1)
	DllCall("gdiplus\GdiplusStartup",A_PtrSize ? "UPtr*" : "uint*",pToken,Ptr,&si,Ptr,0)
	return pToken
}

Gdip_Shutdown(pToken){
	Ptr := A_PtrSize ? "UPtr" : "UInt"	
	DllCall("gdiplus\GdiplusShutdown",Ptr,pToken)
	if hModule := DllCall("GetModuleHandle","str","gdiplus",Ptr)
		DllCall("FreeLibrary",Ptr,hModule)
	return 0
}

Gdip_DisposeImage(pBitmap){
	return DllCall("gdiplus\GdipDisposeImage",A_PtrSize ? "UPtr" : "UInt",pBitmap)
}

Gdip_CreateBitmapFromFile(sFile,IconNumber:=1,IconSize:=""){
	pBitmap := ""
	Ptr := A_PtrSize ? "UPtr" : "UInt",PtrA := A_PtrSize ? "UPtr*" : "UInt*"
	
	SplitPath sFile,,,Extension
	if RegExMatch(Extension,"^(?i:exe|dll)$"){
		Sizes := IconSize ? IconSize : 256 "|" 128 "|" 64 "|" 48 "|" 32 "|" 16
		BufSize := 16 + (2*(A_PtrSize ? A_PtrSize : 4))
		
		VarSetCapacity(buf,BufSize,0)
		For eachSize,Size in StrSplit( Sizes,"|" ){
			DllCall("PrivateExtractIcons","str",sFile,"int",IconNumber-1,"int",Size,"int",Size,PtrA,hIcon,PtrA,0,"uint",1,"uint",0)
			
			if !hIcon
				continue
			
			if !DllCall("GetIconInfo",Ptr,hIcon,Ptr,&buf)	{
				DestroyIcon(hIcon)
				continue
			}
			
			hbmMask  := NumGet(buf,12 + ((A_PtrSize ? A_PtrSize : 4) - 4))
			hbmColor := NumGet(buf,12 + ((A_PtrSize ? A_PtrSize : 4) - 4) + (A_PtrSize ? A_PtrSize : 4))
			if !(hbmColor && DllCall("GetObject",Ptr,hbmColor,"int",BufSize,Ptr,&buf)){
				DestroyIcon(hIcon)
				continue
			}
			break
		}
		if !hIcon
			return -1
		
		Width := NumGet(buf,4,"int"),Height := NumGet(buf,8,"int")
		hbm := CreateDIBSection(Width,-Height),hdc := CreateCompatibleDC(),obm := SelectObject(hdc,hbm)
		if !DllCall("DrawIconEx",Ptr,hdc,"int",0,"int",0,Ptr,hIcon,"uint",Width,"uint",Height,"uint",0,Ptr,0,"uint",3){
			DestroyIcon(hIcon)
			return -2
		}
		VarSetCapacity(dib,104)
		DllCall("GetObject",Ptr,hbm,"int",A_PtrSize = 8 ? 104 : 84,Ptr,&dib) ; sizeof(DIBSECTION) = 76+2*(A_PtrSize=8?4:0)+2*A_PtrSize
		Stride := NumGet(dib,12,"Int"),Bits := NumGet(dib,20 + (A_PtrSize = 8 ? 4 : 0)) ; padding
		DllCall("gdiplus\GdipCreateBitmapFromScan0","int",Width,"int",Height,"int",Stride,"int",0x26200A,Ptr,Bits,PtrA,pBitmapOld)
		pBitmap := Gdip_CreateBitmap(Width,Height)
		_G := Gdip_GraphicsFromImage(pBitmap),Gdip_DrawImage(_G,pBitmapOld,0,0,Width,Height,0,0,Width,Height)
		SelectObject(hdc,obm),DeleteObject(hbm),DeleteDC(hdc)
		Gdip_DeleteGraphics(_G),Gdip_DisposeImage(pBitmapOld)
		DestroyIcon(hIcon)
	}else{
		if (!A_IsUnicode){
			VarSetCapacity(wFile,1024)
			DllCall("kernel32\MultiByteToWideChar","uint",0,"uint",0,Ptr,&sFile,"int",-1,Ptr,&wFile,"int",512)
			DllCall("gdiplus\GdipCreateBitmapFromFile",Ptr,&wFile,PtrA,pBitmap)
		}else
			DllCall("gdiplus\GdipCreateBitmapFromFile",Ptr,&sFile,PtrA,pBitmap)
	}
	return pBitmap
}

Gdip_CreateHBITMAPFromBitmap(pBitmap,Background:=0xffffffff){
	DllCall("gdiplus\GdipCreateHBITMAPFromBitmap",A_PtrSize ? "UPtr" : "UInt",pBitmap,A_PtrSize ? "UPtr*" : "uint*",hbm,"int",Background)
	return hbm
}

Gdip_DrawImage(pGraphics,pBitmap,dx:="",dy:="",dw:="",dh:="",sx:="",sy:="",sw:="",sh:="",Matrix:=1){
	Ptr := A_PtrSize ? "UPtr" : "UInt"
	
	if !IsNumber(Matrix)
		ImageAttr := Gdip_SetImageAttributesColorMatrix(Matrix)
	else if (Matrix != 1)
		ImageAttr := Gdip_SetImageAttributesColorMatrix("1|0|0|0|0|0|1|0|0|0|0|0|1|0|0|0|0|0|" Matrix "|0|0|0|0|0|1")
	
	if (sx = "" && sy = "" && sw = "" && sh = ""){
		if (dx = "" && dy = "" && dw = "" && dh = ""){
			sx := dx := 0,sy := dy := 0
			sw := dw := Gdip_GetImageWidth(pBitmap)
			sh := dh := Gdip_GetImageHeight(pBitmap)
		}else{
			sx := sy := 0
			sw := Gdip_GetImageWidth(pBitmap)
			sh := Gdip_GetImageHeight(pBitmap)
		}
	}
	
	_E := DllCall("gdiplus\GdipDrawImageRectRect",Ptr,pGraphics,Ptr,pBitmap,"float",dx,"float",dy,"float",dw,"float",dh,"float",sx,"float",sy,"float",sw,"float",sh,"int",2,Ptr,ImageAttr,Ptr,0,Ptr,0)
	if ImageAttr
		Gdip_DisposeImageAttributes(ImageAttr)
	return _E
}

Gdip_GraphicsFromImage(pBitmap){
	DllCall("gdiplus\GdipGetImageGraphicsContext",A_PtrSize ? "UPtr" : "UInt",pBitmap,A_PtrSize ? "UPtr*" : "UInt*",pGraphics)
	return pGraphics
}

Gdip_CreateBitmap(Width,Height,Format:=0x26200A){
	pBitmap := ""	
	DllCall("gdiplus\GdipCreateBitmapFromScan0","int",Width,"int",Height,"int",0,"int",Format,A_PtrSize ? "UPtr" : "UInt",0,A_PtrSize ? "UPtr*" : "uint*",pBitmap)
	Return pBitmap
}

CreateDIBSection(w,h,hdc:="",bpp:=32,ByRef ppvBits:=0){
	Ptr := A_PtrSize ? "UPtr" : "UInt"	
	hdc2 := hdc ? hdc : GetDC()
	VarSetCapacity(bi,40,0)
	
	NumPut(w,bi,4,"uint"),NumPut(h,bi,8,"uint"),NumPut(40,bi,0,"uint"),NumPut(1,bi,12,"ushort"),NumPut(0,bi,16,"uInt"),NumPut(bpp,bi,14,"ushort")
	hbm := DllCall("CreateDIBSection",Ptr,hdc2,Ptr,&bi,"uint",0,A_PtrSize ? "UPtr*" : "uint*",ppvBits,Ptr,0,"uint",0,Ptr)
	
	if !hdc
		ReleaseDC(hdc2)
	return hbm
}

ReleaseDC(hdc,hwnd:=0){
	Ptr := A_PtrSize ? "UPtr" : "UInt"	
	return DllCall("ReleaseDC",Ptr,hwnd,Ptr,hdc)
}

DestroyIcon(hIcon){
	return DllCall("DestroyIcon",A_PtrSize ? "UPtr" : "UInt",hIcon)
}

CreateCompatibleDC(hdc:=0){
	return DllCall("CreateCompatibleDC",A_PtrSize ? "UPtr" : "UInt",hdc)
}

SelectObject(hdc,hgdiobj){
	Ptr := A_PtrSize ? "UPtr" : "UInt"	
	return DllCall("SelectObject",Ptr,hdc,Ptr,hgdiobj)
}

DeleteObject(hObject){
	return DllCall("DeleteObject",A_PtrSize ? "UPtr" : "UInt",hObject)
}

DeleteDC(hdc){
	return DllCall("DeleteDC",A_PtrSize ? "UPtr" : "UInt",hdc)
}

Gdip_DeleteGraphics(pGraphics){
	return DllCall("gdiplus\GdipDeleteGraphics",A_PtrSize ? "UPtr" : "UInt",pGraphics)
}

IsNumber(Var) {
	Static number := "number"
	If Var Is number
		Return True
	Return False
}

Gdip_SetImageAttributesColorMatrix(Matrix){
	Ptr := A_PtrSize ? "UPtr" : "UInt"
	
	VarSetCapacity(ColourMatrix,100,0)
	Matrix := RegExReplace(RegExReplace(Matrix,"^[^\d-\.]+([\d\.])","$1",,1),"[^\d-\.]+","|")
	Matrix := StrSplit(Matrix,"|")
	Loop 25 {
		M := (Matrix[A_Index] != "") ? Matrix[A_Index] : Mod(A_Index-1,6) ? 0 : 1
		NumPut(M,ColourMatrix,(A_Index-1)*4,"float")
	}
	DllCall("gdiplus\GdipCreateImageAttributes",A_PtrSize ? "UPtr*" : "uint*",ImageAttr)
	DllCall("gdiplus\GdipSetImageAttributesColorMatrix",Ptr,ImageAttr,"int",1,"int",1,Ptr,&ColourMatrix,Ptr,0,"int",0)
	return ImageAttr
}

Gdip_GetImageWidth(pBitmap){
	DllCall("gdiplus\GdipGetImageWidth",A_PtrSize ? "UPtr" : "UInt",pBitmap,"uint*",Width)
	return Width
}

Gdip_GetImageHeight(pBitmap){
	DllCall("gdiplus\GdipGetImageHeight",A_PtrSize ? "UPtr" : "UInt",pBitmap,"uint*",Height)
	return Height
}

Gdip_DisposeImageAttributes(ImageAttr){
	return DllCall("gdiplus\GdipDisposeImageAttributes",A_PtrSize ? "UPtr" : "UInt",ImageAttr)
}

GetDC(hwnd:=0){
	return DllCall("GetDC",A_PtrSize ? "UPtr" : "UInt",hwnd)
}


; Force script to run in 32-bit mode in AHK v1
forceRunAHK32Bit()
{
	; This script will restart itself using the 32-bit version of AutoHotkey if it's running in 64-bit mode

	; Check if the script is running in 64-bit mode
	if (A_PtrSize = 8) ; 8 bytes = 64-bit, 4 bytes = 32-bit
	{
		; Get the path to the 32-bit AutoHotkey executable
		ahk32Path := RegExReplace(A_AhkPath, "AutoHotkey(U64)?\.exe", "AutoHotkeyU32.exe")
		
		; Check if the 32-bit executable exists
		if FileExist(ahk32Path)
		{
			; Restart the script with the 32-bit executable
			Run, "%ahk32Path%" "%A_ScriptFullPath%" ; %1% %2% %3% %4% %5% %6% %7% %8% %9%
			ExitApp ; Exit the current 64-bit instance
		}
		else
		{
			MsgBox, 16, Error, Could not find 32-bit AutoHotkey executable.
			ExitApp
		}
	}

	; If we reach here, we're already running in 32-bit mode or we've restarted in 32-bit mode
	; MsgBox, % "Running in" A_PtrSize*8 "-bit mode"  ; This will show either "32-bit" or "64-bit"

	; Your actual script code goes here
	; ...
}


/*
 * =========================================================================== *
 * @license     CC BY 4.0                                                      *
 * =========================================================================== *
   This work by the-Automator.com is licensed under CC BY 4.0

   Attribution — You must give appropriate credit , provide a link to the license,
   and indicate if changes were made.

   You may do so in any reasonable manner, but not in any way that suggests the licensor
   endorses you or your use.

   No additional restrictions — You may not apply legal terms or technological measures that
   legally restrict others from doing anything the license permits.

*/