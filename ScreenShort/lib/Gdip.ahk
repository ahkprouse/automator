#Requires AutoHotkey v2.0+
/*
;#####################################################################################
; Conversion to V2 started
;#####################################################################################
*/

#include <GDI.h>

class GDIPlus {

	static StartUp()
	{
		NumPut 'int', 1, si := Buffer(A_PtrSize = 8 ? 24 : 16, 0)
		res := DllCall('GdiPlus\GdiplusStartup', 'ptr*', &pToken:=0, 'ptr', si, 'ptr', 0)

		if !pToken
			throw Error('Invalid token received', A_ThisFunc, res)

		return pToken
	}

/*
Gdip_Startup()
{
	Ptr := A_PtrSize ? "UPtr" : "UInt"
	pToken := 0

	if !DllCall("GetModuleHandle", "str", "gdiplus", Ptr)
		DllCall("LoadLibrary", "str", "gdiplus")
	VarSetCapacity(si, A_PtrSize = 8 ? 24 : 16, 0), si := Chr(1)
	DllCall("gdiplus\GdiplusStartup", A_PtrSize ? "UPtr*" : "uint*", pToken, Ptr, &si, Ptr, 0)
	return pToken
}
*/

	/**
	 * 
	 * @param {Integer} pToken 
	 * @returns {Float | Integer | String} 
	 */
	static ShutDown(pToken)
	{
		if !pToken || Type(pToken) != 'Integer'
			throw ValueError('The token is invalid', A_ThisFunc, 'pToken: ' pToken)

		if res := DllCall('GdiPlus\GdiplusShutdown', 'ptr', pToken)
			throw Error('Could not release the token', A_ThisFunc, res)

		return res
	}

	/**
	 * 
	 * @param {String} path 
	 */
	static CreateBitmapFromFile(path)
	{
		if !FileExist(path)
			throw ValueError('Invalid file path provided', A_ThisFunc, 'path: ' path)

		res := DllCall('GdiPlus\GdipCreateBitmapFromFile', 'str', path, 'ptr*', &pBitmap:=0)
		if !pBitmap
			throw Error('Ivalid bitmap handle received', A_ThisFunc, res)

		return pBitmap
	}

	/**
	 * 
	 * @param {Integer} pBitmap 
	 * @returns {Object} 
	 */
	static GetImageSize(pBitmap)
	{
		if !pBitmap || Type(pBitmap) != 'Integer'
			throw ValueError('The bitmap handle is invalid', A_ThisFunc, 'pBitmap: ' pBitmap)

		DllCall('GdiPlus\GdipGetImageWidth', 'ptr', pBitmap, 'ptr*', &width:=0)
		DllCall('GdiPlus\GdipGetImageHeight', 'ptr', pBitmap, 'ptr*', &height:=0)

		return {width: width, height: height}
	}

	/**
	 * 
	 * @param {Integer} width 
	 * @param {Integer} height 
	 */
	static CreateBitmap(width:=32, height:=32) => Gdiplus.CreateBitmapFromScan(width,height)

	/**
	 * 
	 * @param {Integer} width 
	 * @param {Integer} height 
	 */
	static CreateBitmapFromScan(width:=32, height:=32)
	{
		static Format32bppArgb := 0x26200A

		DllCall('GdiPlus\GdipCreateBitmapFromScan0',
		        'int', width,
		        'int', height,
		        'int', 0,
		        'int', Format32bppArgb,
		        'ptr', 0,
		        'ptr*', &pBitmap:=0)

		if !pBitmap
			throw ValueError('Invalid bitmap handle received', A_ThisFunc, 'pBitmap: ' pBitmap)

		return pBitmap
	}

	/**
	 * 
	 * @param {Integer} pBitmap 
	 */
	Static GraphicsFromImage(pBitmap) => GDIPlus.GetImageGraphicsContext(pBitmap)

	/**
	 * 
	 * @param {Integer} pBitmap 
	 */
	static GetImageGraphicsContext(pBitmap)
	{
		if !pBitmap || Type(pBitmap) != 'Integer'
			throw ValueError('The bitmap handle is invalid', A_ThisFunc, 'pBitmap: ' pBitmap)

		res := DllCall("GdiPlus\GdipGetImageGraphicsContext", 'ptr', pBitmap, 'ptr*', &pGraphics:=0)

		if !pGraphics
			throw Error('Ivalid graphics handle received', A_ThisFunc, res)

		return pGraphics
	}

	/**
	 * 
	 * @param {Integer} pBitmap 
	 * @returns {Float | Integer | String} 
	 */
	static DisposeImage(pBitmap)
	{
		if !pBitmap || Type(pBitmap) != 'Integer'
			throw ValueError('The bitmap handle is invalid', A_ThisFunc, 'pBitmap: ' pBitmap)

		return DllCall("GdiPlus\GdipDisposeImage", 'Ptr', pBitmap)
	}

	/**
	 * 
	 * @param {Integer} pBitmaps 
	 * @returns {Integer} 
	 */
	static DisposeImages(pBitmaps)
	{
		if Type(pBitmaps) != 'Array'
			throw ValueError('The argument is invalid',
			                 A_ThisFunc,
			                 'pBitmaps should be an array.`nCurrent Type: ' Type(pBitmaps))

		for bitmap in pBitmaps
			if GDIPlus.DisposeImage(bitmap)
				throw Error('Error while disposing image', A_ThisFunc)

		return true
	}
	
	/**
	 * 
	 * @param {Integer} pGraphics 
	 * @returns {Float | Integer | String} 
	 */
	static DeleteGraphic(pGraphics)
	{
		if !pGraphics || Type(pGraphics) != 'Integer'
			throw ValueError('The graphics handle is invalid', A_ThisFunc, 'pGraphics: ' pGraphics)

		return DllCall("GdiPlus\GdipDeleteGraphics", 'ptr', pGraphics)
	}

	/**
	 * 
	 * @param {Integer} pGraphics 
	 * @returns {Integer} 
	 */
	static DeleteGraphics(pGraphics)
	{
		if Type(pGraphics) != 'Array'
			throw ValueError('The argument is invalid',
			                 A_ThisFunc,
			                 'pBitmaps should be an array.`nCurrent Type: ' Type(pGraphics))

		for graphic in pGraphics
			if GDIPlus.DeleteGraphic(graphic)
				throw Error('Error while disposing the graphic', A_ThisFunc)

		return true
	}

	/**
	 * 
	 * @param {Integer} ARGB 
	 */
	static BrushCreateSolid(ARGB:=0xff000000)
	{
		DllCall("GdiPlus\GdipCreateSolidFill", "uint", ARGB, 'ptr*', &pBrush:=0)

		if !pBrush
			throw ValueError('Invalid Brush handle received', A_ThisFunc, 'pBrush: ' pBrush)

		return pBrush
	}

	/**
	 * 
	 * @param {Integer} pBrush 
	 * @returns {Float | Integer | String} 
	 */
	static DeleteBrush(pBrush) => DllCall("GdiPlus\GdipDeleteBrush", 'ptr', pBrush)

	/**
	 * 
	 * @param {Integer} pGraphics 
	 * @param {Integer} pBrush 
	 * @param {Integer} x 
	 * @param {Integer} y 
	 * @param {Integer} w 
	 * @param {Integer} h 
	 * @returns {Float | Integer | String} 
	 */
	static FillRectangle(pGraphics, pBrush, x, y, w, h)
	{
		if res := DllCall("gdiplus\GdipFillRectangle",
		               'ptr', pGraphics,
		               'ptr', pBrush,
		               "float", x,
		               "float", y,
		               "float", w,
		               "float", h)
			throw Error('Could not fill current rectangle', A_ThisFunc, res)
		
		return res
	}

	/**
	 * 
	 * @param {Integer} pGraphics 
	 * @param {Integer} pBitmap 
	 * @param {String} dx 
	 * @param {String} dy 
	 * @param {String} dw 
	 * @param {String} dh 
	 * @param {String} sx 
	 * @param {String} sy 
	 * @param {String} sw 
	 * @param {String} sh 
	 * @param {Integer} Matrix 
	 * @returns {Float | Integer | String} 
	 */
	static DrawImage(pGraphics, pBitmap, dx:="", dy:="", dw:="", dh:="", sx:="", sy:="", sw:="", sh:="", Matrix:=1)
	{
		if !IsNumber(Matrix)
			ImageAttr := GDIPlus.SetImageAttributesColorMatrix(Matrix)
		else if (Matrix != 1)
			ImageAttr := GDIPlus.SetImageAttributesColorMatrix("1|0|0|0|0|0|1|0|0|0|0|0|1|0|0|0|0|0|" Matrix "|0|0|0|0|0|1")
		
		if (sx = "" && sy = "" && sw = "" && sh = "")
		{
			if (dx = "" && dy = "" && dw = "" && dh = "")
			{
				sx := dx := 0, sy := dy := 0

				img := GDIPlus.GetImageSize(pBitmap)
				sw := dw := img.width
				sh := dh := img.height
			}
			else
			{
				sx := sy := 0
				img := GDIPlus.GetImageSize(pBitmap)
				sw := img.width
				sh := img.height
			}
		}
		
		res := DllCall("gdiplus\GdipDrawImageRectRect",
		               'ptr', pGraphics,
		               'ptr', pBitmap,
		               "float", dx,
		               "float", dy,
		               "float", dw,
		               "float", dh,
		               "float", sx,
		               "float", sy,
		               "float", sw,
		               "float", sh,
		               "int", 2,
		               'ptr', ImageAttr??0,
		               'ptr', 0,
		               'ptr', 0)
		if IsSet(ImageAttr)
			GDIPlus.DisposeImageAttributes(ImageAttr)
		
		return res
	}

	/**
	 * 
	 * @param {Integer} ImageAttr 
	 * @returns {Float | Integer | String} 
	 */
	static DisposeImageAttributes(ImageAttr) => DllCall("gdiplus\GdipDisposeImageAttributes", 'ptr', ImageAttr)

	/**
	 * 
	 * @param {String} Matrix 
	 */
	static SetImageAttributesColorMatrix(Matrix)
	{
		ColorMatrix := Buffer(100, 0)
		Matrix := RegExReplace(RegExReplace(Matrix, "^[^\d-\.]+([\d\.])", "$1", , 1), "[^\d-\.]+", "|")
		Matrix := StrSplit(Matrix, "|")
		Loop 25
		{
			M := (Matrix[A_Index] != "") ? Matrix[A_Index] : Mod(A_Index-1, 6) ? 0 : 1
			NumPut('float', M, ColorMatrix, (A_Index-1) * A_PtrSize)
		}
		DllCall("gdiplus\GdipCreateImageAttributes", 'ptr*', &ImageAttr:=0)
		DllCall("gdiplus\GdipSetImageAttributesColorMatrix", 'ptr', ImageAttr, "int", 1, "int", 1, 'ptr', ColorMatrix, 'ptr', 0, "int", 0)
		return ImageAttr
	}

	/**
	 * 
	 * @param {Integer} pBitmap 
	 * @param {String} sOutput 
	 * @param {Integer} Quality 
	 * @returns {Number | Integer} 
	 */
	static SaveBitmapToFile(pBitmap, sOutput, Quality:=75)
	{
		_p := 0

		SplitPath sOutput,,, &extension:=""
		if (!RegExMatch(extension, "^(?i:BMP|DIB|RLE|JPG|JPEG|JPE|JFIF|GIF|TIF|TIFF|PNG)$")) {
			return -1
		}
		extension := "." extension

		DllCall("gdiplus\GdipGetImageEncodersSize", "uint*", &nCount:=0, "uint*", &nSize:=0)
		ci := Buffer(nSize)
		DllCall("gdiplus\GdipGetImageEncoders", "UInt", nCount, "UInt", nSize, "UPtr", ci.Ptr)
		if !(nCount && nSize) {
			return -2
		}

		loop nCount {
			address := NumGet(ci, (idx := (48+7*A_PtrSize)*(A_Index-1))+32+3*A_PtrSize, "UPtr")
			sString := StrGet(address, "UTF-16")
			if !InStr(sString, "*" extension)
				continue

			pCodec := ci.Ptr+idx
			break
		}

		if !pCodec {
			return -3
		}

		if (Quality != 75) {
			Quality := (Quality < 0) ? 0 : (Quality > 100) ? 100 : Quality

			if RegExMatch(extension, "^\.(?i:JPG|JPEG|JPE|JFIF)$") {
				DllCall("gdiplus\GdipGetEncoderParameterListSize", "UPtr", pBitmap, "UPtr", pCodec, "uint*", &nSize)
				EncoderParameters := Buffer(nSize, 0)
				DllCall("gdiplus\GdipGetEncoderParameterList", "UPtr", pBitmap, "UPtr", pCodec, "UInt", nSize, "UPtr", EncoderParameters.Ptr)
				nCount := NumGet(EncoderParameters, "UInt")
				loop nCount
				{
					elem := (24+(A_PtrSize ? A_PtrSize : 4))*(A_Index-1) + 4 + (pad := A_PtrSize = 8 ? 4 : 0)
					if (NumGet(EncoderParameters, elem+16, "UInt") = 1) && (NumGet(EncoderParameters, elem+20, "UInt") = 6)
					{
						_p := elem + EncoderParameters.Ptr - pad - 4
						NumPut("UInt", Quality, NumGet(NumPut("UInt", 4, NumPut("UInt", 1, _p+0)+20), "UInt"))
						break
					}
				}
			}
		}

		_E := DllCall("gdiplus\GdipSaveImageToFile", "UPtr", pBitmap, "UPtr", StrPtr(sOutput), "UPtr", pCodec, "UInt", _p ? _p : 0)

		return _E ? -5 : 0
	}

  	; Gdip_SaveBitmapToFile(pBitmap, sOutput, Quality:=75)
	; {
	; 	nCount := 0
	; 	nSize := 0
	; 	_p := 0
		
	; 	SplitPath sOutput,,, Extension
	; 	if !RegExMatch(Extension, "^(?i:BMP|DIB|RLE|JPG|JPEG|JPE|JFIF|GIF|TIF|TIFF|PNG)$")
	; 		throw ValueError('Extension is not supported', A_ThisFunc, Extension)
	; 	Extension := "." Extension
		
	; 	DllCall("gdiplus\GdipGetImageEncodersSize", "uint*", nCount, "uint*", nSize)
	; 	ci := buffer(nSize ) ;VarSetCapacity(ci, nSize)
	; 	DllCall("gdiplus\GdipGetImageEncoders", "uint", nCount, "uint", nSize, Ptr, &ci)
	; 	if !(nCount && nSize)
	; 		return -2
	
	; 	Loop nCount
	; 	{
	; 		sString := StrGet(NumGet(ci, (idx := (48+7*A_PtrSize)*(A_Index-1))+32+3*A_PtrSize), "UTF-16")
	; 		if !InStr(sString, "*" Extension)
	; 			continue
			
	; 		pCodec := &ci+idx
	; 		break
	; 	}
		
	; 	if !pCodec
	; 		return -3
		
	; 	if (Quality != 75)
	; 	{
	; 		Quality := (Quality < 0) ? 0 : (Quality > 100) ? 100 : Quality
	; 		if RegExMatch(Extension, "^\.(?i:JPG|JPEG|JPE|JFIF)$")
	; 		{
	; 			DllCall("gdiplus\GdipGetEncoderParameterListSize", "Ptr", pBitmap, "Ptr", pCodec, "uint*", nSize)

	; 			EncoderParameters := Buffer(nSize,0) ;VarSetCapacity(EncoderParameters, nSize, 0)
	; 			DllCall("gdiplus\GdipGetEncoderParameterList", "Ptr", pBitmap, "Ptr", pCodec, "uint", nSize, "Ptr", &EncoderParameters)
	; 			nCount := NumGet(EncoderParameters, "UInt")
	; 			Loop nCount
	; 			{
	; 				elem := (24+A_PtrSize)*(A_Index-1) + 4 + (pad := A_PtrSize = 8 ? 4 : 0)
	; 				if (NumGet(EncoderParameters, elem+16, "UInt") = 1) && (NumGet(EncoderParameters, elem+20, "UInt") = 6)
	; 				{
	; 					_p := EncoderParameters.ptr + elem - pad - 4
	; 					NumPut(Quality,NumGet(NumPut(4, NumPut(1, _p+0)+20,"UInt")),"UInt")
	; 					break
	; 				}
	; 			}
	; 		}
	; 	}
	; 	_E := DllCall("gdiplus\GdipSaveImageToFile", "Ptr", pBitmap, "Ptr", &sOutput, "Ptr", pCodec, "uint", _p ? _p : 0)
	; 	return _E ? -5 : 0
	; }


	; static SaveBitmapToFile(pBitmap, sOutput)
	; {
		
	; 	nCount := 0
	; 	nSize := 0
	; 	_p := 0
	; 	SplitPath sOutput,,, Extension
	; 	if !RegExMatch(Extension, "^(?i:BMP|DIB|RLE|JPG|JPEG|JPE|JFIF|GIF|TIF|TIFF|PNG)$")
	; 		return -1
	; 	Extension := "." Extension
		
	; 	DllCall("gdiplus\GdipGetImageEncodersSize", "uint*", &nCount:=0, "uint*", &nSize:=0)
	; 	;VarSetCapacity(ci, nSize)
	; 	ci := buffer(nSize)
	; 	DllCall("gdiplus\GdipGetImageEncoders", "uint", nCount, "uint", nSize, 'Ptr', &ci)
	; 	if !(nCount && nSize)
	; 		return -2
		
	; 	StrGet_Name := "StrGet"
		
	; 	N := (A_AhkVersion < 2) ? nCount : "nCount"
	; 	Loop N
	; 	{
			
	; 		sString := StrGet(NumGet(ci, (idx := (48+7*A_PtrSize)*(A_Index-1))+32+3*A_PtrSize), "UTF-16")
	; 		if !InStr(sString, "*" Extension)
	; 			continue
			
	; 		pCodec := &ci+idx
	; 		break
	; 	}
		
	; 	if !pCodec
	; 		return -3
		
	; 	_E := DllCall("gdiplus\GdipSaveImageToFile", Ptr, pBitmap, Ptr, &sOutput, Ptr, pCodec, "uint", _p ? _p : 0)
	; 	return _E ? -5 : 0
	; }


	/**
	 * 
	 * @param {Integer} pGraphics 
	 * @param {Integer} Angle 
	 * @param {Integer} MatrixOrder 
	 * @returns {Float | Integer | String} 
	 */
	static RotateWorldTransform(pGraphics, Angle, MatrixOrder:=0)   => DllCall("gdiplus\GdipRotateWorldTransform", "Ptr", pGraphics, "float", Angle, "int", MatrixOrder)

	/**
	 * 
	 * @param {Integer} pGraphics 
	 * @param {Integer} x 
	 * @param {Integer} y 
	 * @param {Integer} MatrixOrder 
	 * @returns {Float | Integer | String} 
	 */
	static ScaleWorldTransform(pGraphics, x, y, MatrixOrder:=0)     => DllCall("gdiplus\GdipScaleWorldTransform", "Ptr", pGraphics, "float", x, "float", y, "int", MatrixOrder)

	/**
	 * 
	 * @param {Integer} pGraphics 
	 * @param {Integer} x 
	 * @param {Integer} y 
	 * @param {Integer} MatrixOrder 
	 * @returns {Float | Integer | String} 
	 */
	static TranslateWorldTransform(pGraphics, x, y, MatrixOrder:=0) => DllCall("gdiplus\GdipTranslateWorldTransform", "Ptr", pGraphics, "float", x, "float", y, "int", MatrixOrder)

	/**
	 * 
	 * @param {Integer} pGraphics 
	 * @returns {Float | Integer | String} 
	 */
	static ResetWorldTransform(pGraphics) => DllCall("gdiplus\GdipResetWorldTransform", "Ptr" , pGraphics)

	/**
	 * 
	 * @param {Integer} Width 
	 * @param {Integer} Height 
	 * @param {Integer} Angle 
	 * @param {Integer} xTranslation 
	 * @param {Integer} yTranslation 
	 */
	static GetRotatedTranslation(Width, Height, Angle, &xTranslation, &yTranslation)
	{
		static pi := 3.14159
		TAngle := Angle*(pi/180)
		Bound := (Angle >= 0) ? Mod(Angle, 360) : 360-Mod(-Angle, -360)
		if ((Bound >= 0) && (Bound <= 90))
			xTranslation := Height*Sin(TAngle), yTranslation := 0
		else if ((Bound > 90) && (Bound <= 180))
			xTranslation := (Height*Sin(TAngle))-(Width*Cos(TAngle)), yTranslation := -Height*Cos(TAngle)
		else if ((Bound > 180) && (Bound <= 270))
			xTranslation := -(Width*Cos(TAngle)), yTranslation := -(Height*Cos(TAngle))-(Width*Sin(TAngle))
		else if ((Bound > 270) && (Bound <= 360))
			xTranslation := 0, yTranslation := -Width*Sin(TAngle)
	}

	/**
	 * 
	 * @param {Integer} Width 
	 * @param {Integer} Height 
	 * @param {Integer} Angle 
	 * @param {Integer} RWidth 
	 * @param {Integer} RHeight 
	 * @returns {Number} 
	 */
	static GetRotatedDimensions(Width, Height, Angle, &RWidth, &RHeight)
	{
		static pi := 3.14159
		TAngle := Angle*(pi/180)
		if !(Width && Height)
			return -1
		RWidth := Ceil(Abs(Width*Cos(TAngle))+Abs(Height*Sin(TAngle)))
		RHeight := Ceil(Abs(Width*Sin(TAngle))+Abs(Height*Cos(Tangle)))
	}

	; RotateNoneFlipNone   = 0
	; Rotate90FlipNone     = 1
	; Rotate180FlipNone    = 2
	; Rotate270FlipNone    = 3
	; RotateNoneFlipX      = 4
	; Rotate90FlipX        = 5
	; Rotate180FlipX       = 6
	; Rotate270FlipX       = 7
	; RotateNoneFlipY      = Rotate180FlipX
	; Rotate90FlipY        = Rotate270FlipX
	; Rotate180FlipY       = RotateNoneFlipX
	; Rotate270FlipY       = Rotate90FlipX
	; RotateNoneFlipXY     = Rotate180FlipNone
	; Rotate90FlipXY       = Rotate270FlipNone
	; Rotate180FlipXY      = RotateNoneFlipNone
	; Rotate270FlipXY      = Rotate90FlipNone

	

	/**
	 * 
	 * @param {Integer} pBitmap 
	 * @param {Integer} RotateFlipType 
	 * @returns {Float | Integer | String} 
	 */
	static ImageRotateFlip(pBitmap, RotateFlipType:=1) => DllCall("gdiplus\GdipImageRotateFlip", "Ptr" , pBitmap, "int", RotateFlipType)

	/**
	 * 
	 * @param {Integer} pGraphics 
	 * @param {Integer} x 
	 * @param {Integer} y 
	 * @param {Integer} w 
	 * @param {Integer} h 
	 * @param {Integer} CombineMode 
	 * @returns {Float | Integer | String} 
	 */
	static SetClipRect(pGraphics, x, y, w, h, CombineMode:=0) => DllCall("gdiplus\GdipSetClipRect",  "Ptr" , pGraphics, "float", x, "float", y, "float", w, "float", h, "int", CombineMode)

	; Replace = 0
	; Intersect = 1
	; Union = 2
	; Xor = 3
	; Exclude = 4
	; Complement = 5
	/**
	 * 
	 * @param {Integer} pGraphics 
	 * @param {Integer} pPath 
	 * @param {Integer} CombineMode 
	 * @returns {Float | Integer | String} 
	 */
	static SetClipPath(pGraphics, pPath, CombineMode:=0) => DllCall("gdiplus\GdipSetClipPath", "Ptr", pGraphics, "Ptr", pPath, "int", CombineMode)
	
	/**
	 * 
	 * @param {Integer} pGraphics 
	 * @returns {Float | Integer | String} 
	 */
	static ResetClip(pGraphics) => DllCall("gdiplus\GdipResetClip", "Ptr", pGraphics)

	/**
	 * 
	 * @param {Integer} pGraphics 
	 */
	static GetClipRegion(pGraphics)
	{
		Region := GDIPlus.CreateRegion()
		DllCall("gdiplus\GdipGetClip", "Ptr" , pGraphics, "UInt", &Region)
		return Region
	}

	/**
	 * 
	 * @param {Integer} pGraphics 
	 * @param {Integer} Region 
	 * @param {Integer} CombineMode 
	 * @returns {Float | Integer | String} 
	 */
	static SetClipRegion(pGraphics, Region, CombineMode:=0)
	{
		return DllCall("gdiplus\GdipSetClipRegion", "Ptr", pGraphics, "Ptr", Region, "int", CombineMode)
	}
	static CreateRegion()
	{
		DllCall("gdiplus\GdipCreateRegion", "Ptr*", &Region=0)
		; if !Region

		return Region
	}

	/**
	 * 
	 * @param {Integer} Region 
	 * @returns {Float | Integer | String} 
	 */
	static DeleteRegion(Region) => DllCall("gdiplus\GdipDeleteRegion", "Ptr", Region)


	;#####################################################################################
	; BitmapLockBits
	;#####################################################################################

	/**
	 * 
	 * @param {Integer} pBitmap 
	 * @param {Integer} x 
	 * @param {Integer} y 
	 * @param {Integer} w 
	 * @param {Integer} h 
	 * @param {Integer} Stride 
	 * @param {Integer} Scan0 
	 * @param {Integer} BitmapData 
	 * @param {Integer} LockMode 
	 * @param {Integer} PixelFormat 
	 * @returns {Float | Integer | String} 
	 */
	static LockBits(pBitmap, x, y, w, h, &Stride, &Scan0, &BitmapData, LockMode := 3, PixelFormat := 0x26200a)
	{
		GDIPlus.CreateRect(&_Rect, x, y, w, h)
		BitmapData := Buffer(16+2*(A_PtrSize ? A_PtrSize : 4), 0) ; ;VarSetCapacity(BitmapData, 16+2*(A_PtrSize ? A_PtrSize : 4), 0)
		_E := DllCall("Gdiplus\GdipBitmapLockBits", "Ptr", pBitmap, "Ptr", &_Rect, "uint", LockMode, "int", PixelFormat, "Ptr", BitmapData)
		Stride := NumGet(BitmapData, 8, "Int")
		Scan0 := NumGet(BitmapData, 16, "Ptr")
		return _E
	}

	/**
	 * 
	 * @param {Integer} pBitmap 
	 * @param {Integer} BitmapData 
	 */
	static UnlockBits(pBitmap, &BitmapData)
	{
		if Type(BitmapData) != 'Buffer'
			return
		DllCall("Gdiplus\GdipBitmapUnlockBits", "Ptr", pBitmap, "Ptr", BitmapData)
	}

	/**
	 * 
	 * @param {Integer} ARGB 
	 * @param {Integer} Scan0 
	 * @param {Integer} x 
	 * @param {Integer} y 
	 * @param {Integer} Stride 
	 * @returns {Integer} 
	 */
	static SetLockBitPixel(ARGB, Scan0, x, y, Stride) => Numput(ARGB, Scan0+0, (x*4)+(y*Stride), "UInt")

	/**
	 * 
	 * @param {Integer} Scan0 
	 * @param {Integer} x 
	 * @param {Integer} y 
	 * @param {Integer} Stride 
	 * @returns {Float | Integer} 
	 */
	static GetLockBitPixel(Scan0, x, y, Stride) => NumGet(Scan0+0, (x*4)+(y*Stride), "UInt")

	/**
	 * 
	 * @param {Integer} A 
	 * @param {Integer} R 
	 * @param {Integer} G 
	 * @param {Integer} B 
	 */
	static ToARGB(A, R, G, B) => ((A << 24) | (R << 16) | (G << 8) | B)


	/**
	 * 
	 * @param {Integer} pBitmap 
	 * @param {Integer} pBitmapOut 
	 * @param {Integer} BlockSize 
	 * @returns {Number | Integer} 
	 */
	static PixelateBitmap(pBitmap, &pBitmapOut, BlockSize)
	{
		static PixelateBitmap
		
		if (!PixelateBitmap)
		{
			if A_PtrSize != 8 ; x86 machine code
				MCode_PixelateBitmap := "
			(LTrim Join
			558BEC83EC3C8B4514538B5D1C99F7FB56578BC88955EC894DD885C90F8E830200008B451099F7FB8365DC008365E000894DC88955F08945E833FF897DD4
			397DE80F8E160100008BCB0FAFCB894DCC33C08945F88945FC89451C8945143BD87E608B45088D50028BC82BCA8BF02BF2418945F48B45E02955F4894DC4
			8D0CB80FAFCB03CA895DD08BD1895DE40FB64416030145140FB60201451C8B45C40FB604100145FC8B45F40FB604020145F883C204FF4DE475D6034D18FF
			4DD075C98B4DCC8B451499F7F98945148B451C99F7F989451C8B45FC99F7F98945FC8B45F899F7F98945F885DB7E648B450C8D50028BC82BCA83C103894D
			C48BC82BCA41894DF48B4DD48945E48B45E02955E48D0C880FAFCB03CA895DD08BD18BF38A45148B7DC48804178A451C8B7DF488028A45FC8804178A45F8
			8B7DE488043A83C2044E75DA034D18FF4DD075CE8B4DCC8B7DD447897DD43B7DE80F8CF2FEFFFF837DF0000F842C01000033C08945F88945FC89451C8945
			148945E43BD87E65837DF0007E578B4DDC034DE48B75E80FAF4D180FAFF38B45088D500203CA8D0CB18BF08BF88945F48B45F02BF22BFA2955F48945CC0F
			B6440E030145140FB60101451C0FB6440F010145FC8B45F40FB604010145F883C104FF4DCC75D8FF45E4395DE47C9B8B4DF00FAFCB85C9740B8B451499F7
			F9894514EB048365140033F63BCE740B8B451C99F7F989451CEB0389751C3BCE740B8B45FC99F7F98945FCEB038975FC3BCE740B8B45F899F7F98945F8EB
			038975F88975E43BDE7E5A837DF0007E4C8B4DDC034DE48B75E80FAF4D180FAFF38B450C8D500203CA8D0CB18BF08BF82BF22BFA2BC28B55F08955CC8A55
			1488540E038A551C88118A55FC88540F018A55F888140183C104FF4DCC75DFFF45E4395DE47CA68B45180145E0015DDCFF4DC80F8594FDFFFF8B451099F7
			FB8955F08945E885C00F8E450100008B45EC0FAFC38365DC008945D48B45E88945CC33C08945F88945FC89451C8945148945103945EC7E6085DB7E518B4D
			D88B45080FAFCB034D108D50020FAF4D18034DDC8BF08BF88945F403CA2BF22BFA2955F4895DC80FB6440E030145140FB60101451C0FB6440F010145FC8B
			45F40FB604080145F883C104FF4DC875D8FF45108B45103B45EC7CA08B4DD485C9740B8B451499F7F9894514EB048365140033F63BCE740B8B451C99F7F9
			89451CEB0389751C3BCE740B8B45FC99F7F98945FCEB038975FC3BCE740B8B45F899F7F98945F8EB038975F88975103975EC7E5585DB7E468B4DD88B450C
			0FAFCB034D108D50020FAF4D18034DDC8BF08BF803CA2BF22BFA2BC2895DC88A551488540E038A551C88118A55FC88540F018A55F888140183C104FF4DC8
			75DFFF45108B45103B45EC7CAB8BC3C1E0020145DCFF4DCC0F85CEFEFFFF8B4DEC33C08945F88945FC89451C8945148945103BC87E6C3945F07E5C8B4DD8
			8B75E80FAFCB034D100FAFF30FAF4D188B45088D500203CA8D0CB18BF08BF88945F48B45F02BF22BFA2955F48945C80FB6440E030145140FB60101451C0F
			B6440F010145FC8B45F40FB604010145F883C104FF4DC875D833C0FF45108B4DEC394D107C940FAF4DF03BC874068B451499F7F933F68945143BCE740B8B
			451C99F7F989451CEB0389751C3BCE740B8B45FC99F7F98945FCEB038975FC3BCE740B8B45F899F7F98945F8EB038975F88975083975EC7E63EB0233F639
			75F07E4F8B4DD88B75E80FAFCB034D080FAFF30FAF4D188B450C8D500203CA8D0CB18BF08BF82BF22BFA2BC28B55F08955108A551488540E038A551C8811
			8A55FC88540F018A55F888140883C104FF4D1075DFFF45088B45083B45EC7C9F5F5E33C05BC9C21800
			)"
			else ; x64 machine code
				MCode_PixelateBitmap := "
			(LTrim Join
			4489442418488954241048894C24085355565741544155415641574883EC28418BC1448B8C24980000004C8BDA99488BD941F7F9448BD0448BFA8954240C
			448994248800000085C00F8E9D020000418BC04533E4458BF299448924244C8954241041F7F933C9898C24980000008BEA89542404448BE889442408EB05
			4C8B5C24784585ED0F8E1A010000458BF1418BFD48897C2418450FAFF14533D233F633ED4533E44533ED4585C97E5B4C63BC2490000000418D040A410FAF
			C148984C8D441802498BD9498BD04D8BD90FB642010FB64AFF4403E80FB60203E90FB64AFE4883C2044403E003F149FFCB75DE4D03C748FFCB75D0488B7C
			24188B8C24980000004C8B5C2478418BC59941F7FE448BE8418BC49941F7FE448BE08BC59941F7FE8BE88BC69941F7FE8BF04585C97E4048639C24900000
			004103CA4D8BC1410FAFC94863C94A8D541902488BCA498BC144886901448821408869FF408871FE4883C10448FFC875E84803D349FFC875DA8B8C249800
			0000488B5C24704C8B5C24784183C20448FFCF48897C24180F850AFFFFFF8B6C2404448B2424448B6C24084C8B74241085ED0F840A01000033FF33DB4533
			DB4533D24533C04585C97E53488B74247085ED7E42438D0C04418BC50FAF8C2490000000410FAFC18D04814863C8488D5431028BCD0FB642014403D00FB6
			024883C2044403D80FB642FB03D80FB642FA03F848FFC975DE41FFC0453BC17CB28BCD410FAFC985C9740A418BC299F7F98BF0EB0233F685C9740B418BC3
			99F7F9448BD8EB034533DB85C9740A8BC399F7F9448BD0EB034533D285C9740A8BC799F7F9448BC0EB034533C033D24585C97E4D4C8B74247885ED7E3841
			8D0C14418BC50FAF8C2490000000410FAFC18D04814863C84A8D4431028BCD40887001448818448850FF448840FE4883C00448FFC975E8FFC2413BD17CBD
			4C8B7424108B8C2498000000038C2490000000488B5C24704503E149FFCE44892424898C24980000004C897424100F859EFDFFFF448B7C240C448B842480
			000000418BC09941F7F98BE8448BEA89942498000000896C240C85C00F8E3B010000448BAC2488000000418BCF448BF5410FAFC9898C248000000033FF33
			ED33F64533DB4533D24533C04585FF7E524585C97E40418BC5410FAFC14103C00FAF84249000000003C74898488D541802498BD90FB642014403D00FB602
			4883C2044403D80FB642FB03F00FB642FA03E848FFCB75DE488B5C247041FFC0453BC77CAE85C9740B418BC299F7F9448BE0EB034533E485C9740A418BC3
			99F7F98BD8EB0233DB85C9740A8BC699F7F9448BD8EB034533DB85C9740A8BC599F7F9448BD0EB034533D24533C04585FF7E4E488B4C24784585C97E3541
			8BC5410FAFC14103C00FAF84249000000003C74898488D540802498BC144886201881A44885AFF448852FE4883C20448FFC875E941FFC0453BC77CBE8B8C
			2480000000488B5C2470418BC1C1E00203F849FFCE0F85ECFEFFFF448BAC24980000008B6C240C448BA4248800000033FF33DB4533DB4533D24533C04585
			FF7E5A488B7424704585ED7E48418BCC8BC5410FAFC94103C80FAF8C2490000000410FAFC18D04814863C8488D543102418BCD0FB642014403D00FB60248
			83C2044403D80FB642FB03D80FB642FA03F848FFC975DE41FFC0453BC77CAB418BCF410FAFCD85C9740A418BC299F7F98BF0EB0233F685C9740B418BC399
			F7F9448BD8EB034533DB85C9740A8BC399F7F9448BD0EB034533D285C9740A8BC799F7F9448BC0EB034533C033D24585FF7E4E4585ED7E42418BCC8BC541
			0FAFC903CA0FAF8C2490000000410FAFC18D04814863C8488B442478488D440102418BCD40887001448818448850FF448840FE4883C00448FFC975E8FFC2
			413BD77CB233C04883C428415F415E415D415C5F5E5D5BC3
			)"
			
			;VarSetCapacity(PixelateBitmap, StrLen(MCode_PixelateBitmap)//2)
			;nCount := StrLen(MCode_PixelateBitmap)//2
			PixelateBitmap := Buffer(nCount := StrLen(MCode_PixelateBitmap)//2)

			; N := (A_AhkVersion < 2) ? nCount : "nCount"
			Loop nCount
				NumPut("UChar", "0x" SubStr(MCode_PixelateBitmap, (2*A_Index)-1, 2), PixelateBitmap, A_Index-1)

			DllCall("VirtualProtect", "Ptr", &PixelateBitmap, "Ptr", PixelateBitmap, "uint", 0x40, "ptr*", 0)

			; DllCall("VirtualProtect", Ptr, &PixelateBitmap, Ptr, VarSetCapacity(PixelateBitmap), "uint", 0x40, A_PtrSize ? "UPtr*" : "UInt*", 0)
		}
		
		imgDim := GDIPlus.GetImageDimensions(pBitmap)
		img := GDIPlus.GetImageSize(pBitmap)
		if (imgDim.Width != img.width || imgDim.Height != img.height)
			return -1
		if (BlockSize > imgDim.Width || BlockSize > imgDim.Height)
			return -2
		
		E1 := GDIPlus.LockBits(pBitmap, 0, 0, imgDim.Width, imgDim.Height, &Stride1, &Scan01, &BitmapData1)
		E2 := GDIPlus.LockBits(pBitmapOut, 0, 0, imgDim.Width, imgDim.Height, &Stride2, &Scan02, &BitmapData2)
		if (E1 || E2)
			return -3
		
		; E := - unused exit code
		DllCall(&PixelateBitmap, "Ptr", Scan01, "Ptr", Scan02, "int", imgDim.Width, "int", imgDim.Height, "int", Stride1, "int", BlockSize)
		
		GDIPlus.UnlockBits(pBitmap, &BitmapData1), GDIPlus.UnlockBits(pBitmapOut, &BitmapData2)
		return 0
	}

	/**
	 * 
	 * @param {Integer} ARGB 
	 * @param {Integer} A 
	 * @param {Integer} R 
	 * @param {Integer} G 
	 * @param {Integer} B 
	 */
	static FromARGB(ARGB, &A, &R, &G, &B)
	{
		A := (0xff000000 & ARGB) >> 24
		R := (0x00ff0000 & ARGB) >> 16
		G := (0x0000ff00 & ARGB) >> 8
		B := 0x000000ff & ARGB
	}

	/**
	 * 
	 * @param {Integer} ARGB 
	 * @returns {Number} 
	 */
	static AFromARGB(ARGB) => (0xff000000 & ARGB) >> 24
	/**
	 * 
	 * @param {Integer} ARGB 
	 * @returns {Number} 
	 */
	static Gdip_RFromARGB(ARGB) => (0x00ff0000 & ARGB) >> 16
	/**
	 * 
	 * @param {Integer} ARGB 
	 * @returns {Number} 
	 */
	static GFromARGB(ARGB) => (0x0000ff00 & ARGB) >> 8

	/**
	 * 
	 * @param {Integer} ARGB 
	 * @returns {Number} 
	 */
	static BFromARGB(ARGB) => (0x000000ff & ARGB)

	;
	;#####################################################################################
	;#####################################################################################
	; STATUS ENUMERATION
	; Return values for functions specified to have status enumerated return type
	;#####################################################################################
	;
	; Ok =						= 0
	; GenericError				= 1
	; InvalidParameter			= 2
	; OutOfMemory				= 3
	; ObjectBusy				= 4
	; InsufficientBuffer		= 5
	; NotImplemented			= 6
	; Win32Error				= 7
	; WrongState				= 8
	; Aborted					= 9
	; FileNotFound				= 10
	; ValueOverflow				= 11
	; AccessDenied				= 12
	; UnknownImageFormat		= 13
	; FontFamilyNotFound		= 14
	; FontStyleNotFound			= 15
	; NotTrueTypeFont			= 16
	; UnsupportedGdiplusVersion	= 17
	; GdiplusNotInitialized		= 18
	; PropertyNotFound			= 19
	; PropertyNotSupported		= 20
	; ProfileNotFound			= 21
	;
	;#####################################################################################
	;#####################################################################################
	; FUNCTIONS
	;#####################################################################################
	;
	; UpdateLayeredWindow(hwnd, hdc, x:="", y:="", w:="", h:="", Alpha:=255)
	; BitBlt(ddc, dx, dy, dw, dh, sdc, sx, sy, Raster:="")
	; StretchBlt(dDC, dx, dy, dw, dh, sDC, sx, sy, sw, sh, Raster:="")
	; SetImage(hwnd, hBitmap)
	; Gdip_BitmapFromScreen(Screen:=0, Raster:="")
	; CreateRectF(ByRef RectF, x, y, w, h)
	; CreateSizeF(ByRef SizeF, w, h)
	; CreateDIBSection
	;
	;#####################################################################################

	; Function:					UpdateLayeredWindow
	; Description:				Updates a layered window with the handle to the DC of a gdi bitmap
	;
	; hwnd						Handle of the layered window to update
	; hdc						Handle to the DC of the GDI bitmap to update the window with
	; Layeredx					x position to place the window
	; Layeredy					y position to place the window
	; Layeredw					Width of the window
	; Layeredh					Height of the window
	; Alpha						Default = 255 : The transparency (0-255) to set the window transparency
	;
	; return					If the function succeeds, the return value is nonzero
	;
	; notes						If x or y omitted, then layered window will use its current coordinates
	;							If w or h omitted then current width and height will be used

	/**
	 * 
	 * @param {Integer} hwnd 
	 * @param {Integer} hdc 
	 * @param {Integer} x 
	 * @param {Integer} y 
	 * @param {Integer} w 
	 * @param {Integer} h 
	 * @param {Integer} Alpha 
	 * @returns {Float | Integer | String} 
	 */
	Static UpdateLayeredWindow(hwnd, hdc, x:="", y:="", w:="", h:="", Alpha:=255)
	{
		if ((x != "") && (y != ""))
		{
			;VarSetCapacity(pt, 8)
			;NumPut("UInt",x, pt, 0, ), NumPut("UInt",y, pt, 4, )
			pt := Buffer(8)
			NumPut("UInt",x, pt, 0)
			NumPut("UInt",y, pt, 4)

		}
		
		if (w = "") || (h = "")
		{
			GDIPlus.CreateRect(&winRect, 0, 0, 0, 0 ) ;is 16 on both 32 and 64
			DllCall( "GetWindowRect", "Ptr", hwnd, "Ptr", winRect )
			w := NumGet(winRect, 8, "UInt")  - NumGet(winRect, 0, "UInt")
			h := NumGet(winRect, 12, "UInt") - NumGet(winRect, 4, "UInt")
		}

		return DllCall("UpdateLayeredWindow"
		, "Ptr", hwnd
		, "Ptr", 0
		, "Ptr", ((x = "") && (y = "")) ? 0 : &pt
		, "Ptr", w|h<<32
		, "Ptr", hdc
		, "Ptr", 0
		, "uint", 0
		, "Ptr", Alpha<<16|1<<24
		, "uint", 2)
	}

	;#####################################################################################
	; Function				BitBlt
	; Description			The BitBlt function performs a bit-block transfer of the color data corresponding to a rectangle
	;						of pixels from the specified source device context into a destination device context.
	;
	; dDC					handle to destination DC
	; dx					x-coord of destination upper-left corner
	; dy					y-coord of destination upper-left corner
	; dw					width of the area to copy
	; dh					height of the area to copy
	; sDC					handle to source DC
	; sx					x-coordinate of source upper-left corner
	; sy					y-coordinate of source upper-left corner
	; Raster				raster operation code
	;
	; return				If the function succeeds, the return value is nonzero
	;
	; notes					If no raster operation is specified, then SRCCOPY is used, which copies the source directly to the destination rectangle
	;
	; BLACKNESS				= 0x00000042
	; NOTSRCERASE			= 0x001100A6
	; NOTSRCCOPY			= 0x00330008
	; SRCERASE				= 0x00440328
	; DSTINVERT				= 0x00550009
	; PATINVERT				= 0x005A0049
	; SRCINVERT				= 0x00660046
	; SRCAND				= 0x008800C6
	; MERGEPAINT			= 0x00BB0226
	; MERGECOPY				= 0x00C000CA
	; SRCCOPY				= 0x00CC0020
	; SRCPAINT				= 0x00EE0086
	; PATCOPY				= 0x00F00021
	; PATPAINT				= 0x00FB0A09
	; WHITENESS				= 0x00FF0062
	; CAPTUREBLT			= 0x40000000
	; NOMIRRORBITMAP		= 0x80000000
	/**
	 * 
	 * @param {Integer} ddc 
	 * @param {Integer} dx 
	 * @param {Integer} dy 
	 * @param {Integer} dw 
	 * @param {Integer} dh 
	 * @param {Integer} sdc 
	 * @param {Integer} sx 
	 * @param {Integer} sy
	 * @param {Integer} Raster 
	 * @returns {Float | Integer | String} 
	 */
	Static BitBlt(ddc, dx, dy, dw, dh, sdc, sx, sy, Raster:="")
	{
		return DllCall("gdi32\BitBlt"
						, "Ptr", dDC
						, "int", dx
						, "int", dy
						, "int", dw
						, "int", dh
						, "Ptr", sDC
						, "int", sx
						, "int", sy
						, "uint", Raster ? Raster : 0x00CC0020)
	}

	;#####################################################################################
	; Function				StretchBlt
	; Description			The StretchBlt function copies a bitmap from a source rectangle into a destination rectangle,
	;						stretching or compressing the bitmap to fit the dimensions of the destination rectangle, if necessary.
	;						The system stretches or compresses the bitmap according to the stretching mode currently set in the destination device context.
	;
	; ddc					handle to destination DC
	; dx					x-coord of destination upper-left corner
	; dy					y-coord of destination upper-left corner
	; dw					width of destination rectangle
	; dh					height of destination rectangle
	; sdc					handle to source DC
	; sx					x-coordinate of source upper-left corner
	; sy					y-coordinate of source upper-left corner
	; sw					width of source rectangle
	; sh					height of source rectangle
	; Raster				raster operation code
	;
	; return				If the function succeeds, the return value is nonzero
	;
	; notes					If no raster operation is specified, then SRCCOPY is used. It uses the same raster operations as BitBlt

	/**
	 * 
	 * @param {Integer} ddc 
	 * @param {Integer} dx 
	 * @param {Integer} dy 
	 * @param {Integer} dw 
	 * @param {Integer} dh 
	 * @param {Integer} sdc 
	 * @param {Integer} sx 
	 * @param {Integer} sy 
	 * @param {Integer} sw 
	 * @param {Integer} sh 
	 * @param {Integer} Raster 
	 * @returns {Float | Integer | String} 
	 */
	Static StretchBlt(ddc, dx, dy, dw, dh, sdc, sx, sy, sw, sh, Raster:="")
	{
		return DllCall("gdi32\StretchBlt"
						, "Ptr", ddc
						, "int", dx
						, "int", dy
						, "int", dw
						, "int", dh
						, "Ptr", sdc
						, "int", sx
						, "int", sy
						, "int", sw
						, "int", sh
						, "uint", Raster ? Raster : 0x00CC0020)
	}

	;#####################################################################################

	; Function				SetStretchBltMode
	; Description			The SetStretchBltMode function sets the bitmap stretching mode in the specified device context
	;
	; hdc					handle to the DC
	; iStretchMode			The stretching mode, describing how the target will be stretched
	;
	; return				If the function succeeds, the return value is the previous stretching mode. If it fails it will return 0
	;
	; STRETCH_ANDSCANS 		= 0x01
	; STRETCH_ORSCANS 		= 0x02
	; STRETCH_DELETESCANS 	= 0x03
	; STRETCH_HALFTONE 		= 0x04
	
	/**
	 * 
	 * @param {Integer} hdc 
	 * @param {Integer} iStretchMode 
	 * @returns {Float | Integer | String} 
	 */
	Static SetStretchBltMode(hdc, iStretchMode:=4)
	{
		return DllCall("gdi32\SetStretchBltMode"
						, "Ptr", hdc
						, "int", iStretchMode)
	}

	;#####################################################################################
	; Function				SetImage
	; Description			Associates a new image with a static control
	;
	; hwnd					handle of the control to update
	; hBitmap				a gdi bitmap to associate the static control with
	;
	; return				If the function succeeds, the return value is nonzero

	/**
	 * 
	 * @param {Integer} hwnd 
	 * @param {Integer} Bitmap 
	 * @returns {Float | Integer | String} 
	 */
	Static SetImage(hwnd, hBitmap)
	{
		E := DllCall( "SendMessage", "Ptr", hwnd, "UInt", 0x172, "UInt", 0x0, "Ptr", hBitmap )
		GDIPlus.DeleteObject(E)
		return E
	}

	;#####################################################################################
	; Function				SetSysColorToControl
	; Description			Sets a solid colour to a control
	;
	; hwnd					handle of the control to update
	; SysColor				A system colour to set to the control
	;
	; return				If the function succeeds, the return value is zero
	;
	; notes					A control must have the 0xE style set to it so it is recognised as a bitmap
	;						By default SysColor=15 is used which is COLOR_3DFACE. This is the standard background for a control
	;
	; COLOR_3DDKSHADOW				= 21
	; COLOR_3DFACE					= 15
	; COLOR_3DHIGHLIGHT				= 20
	; COLOR_3DHILIGHT				= 20
	; COLOR_3DLIGHT					= 22
	; COLOR_3DSHADOW				= 16
	; COLOR_ACTIVEBORDER			= 10
	; COLOR_ACTIVECAPTION			= 2
	; COLOR_APPWORKSPACE			= 12
	; COLOR_BACKGROUND				= 1
	; COLOR_BTNFACE					= 15
	; COLOR_BTNHIGHLIGHT			= 20
	; COLOR_BTNHILIGHT				= 20
	; COLOR_BTNSHADOW				= 16
	; COLOR_BTNTEXT					= 18
	; COLOR_CAPTIONTEXT				= 9
	; COLOR_DESKTOP					= 1
	; COLOR_GRADIENTACTIVECAPTION	= 27
	; COLOR_GRADIENTINACTIVECAPTION	= 28
	; COLOR_GRAYTEXT				= 17
	; COLOR_HIGHLIGHT				= 13
	; COLOR_HIGHLIGHTTEXT			= 14
	; COLOR_HOTLIGHT				= 26
	; COLOR_INACTIVEBORDER			= 11
	; COLOR_INACTIVECAPTION			= 3
	; COLOR_INACTIVECAPTIONTEXT		= 19
	; COLOR_INFOBK					= 24
	; COLOR_INFOTEXT				= 23
	; COLOR_MENU					= 4
	; COLOR_MENUHILIGHT				= 29
	; COLOR_MENUBAR					= 30
	; COLOR_MENUTEXT				= 7
	; COLOR_SCROLLBAR				= 0
	; COLOR_WINDOW					= 5
	; COLOR_WINDOWFRAME				= 6
	; COLOR_WINDOWTEXT				= 8

	/**
	 * 
	 * @param {Integer} hwnd 
	 * @param {Integer} SysColor 
	 * @returns {Integer} 
	 */
	Static SetSysColorToControl(hwnd, SysColor:=15)
	{
		GDIPlus.CreateRect(&winRect, 0, 0, 0, 0 ) ;is 16 on both 32 and 64
		DllCall( "GetWindowRect", "Ptr", hwnd, "Ptr", &winRect )
		w := NumGet("UInt" winRect, 8)  - NumGet("UInt" winRect, 0)
		h := NumGet("UInt" winRect, 12) - NumGet("UInt" winRect, 4)
		bc := DllCall("GetSysColor", "Int", SysColor, "UInt")
		pBrushClear := GDIPlus.BrushCreateSolid(0xff000000 | (bc >> 16 | bc & 0xff00 | (bc & 0xff) << 16))
		pBitmap := GDIPlus.CreateBitmap(w, h), G := GDIPlus.GraphicsFromImage(pBitmap)
		GDIPlus.FillRectangle(G, pBrushClear, 0, 0, w, h)
		hBitmap := GDIPlus.CreateHBITMAPFromBitmap(pBitmap)
		GDIPlus.SetImage(hwnd, hBitmap)
		GDIPlus.DeleteBrush(pBrushClear)
		GDIPlus.DeleteGraphics(G), GDIPlus.DisposeImage(pBitmap), GDIPlus.DeleteObject(hBitmap)
		return 0
	}


	;#####################################################################################
	; Function				Gdip_BitmapFromScreen
	; Description			Gets a gdi+ bitmap from the screen
	;
	; Screen				0 = All screens
	;						Any numerical value = Just that screen
	;						x|y|w|h = Take specific coordinates with a width and height
	; Raster				raster operation code
	;
	; return				If the function succeeds, the return value is a pointer to a gdi+ bitmap
	;						-1:		one or more of x,y,w,h not passed properly
	;
	; notes					If no raster operation is specified, then SRCCOPY is used to the returned bitmap

	/**
	 * 
	 * @param {Integer} Screen 
	 * @param {Integer} Raster 
	 * @returns {Number} 
	 */
	Static BitmapFromScreen(Screen:=0, Raster:="")
	{
		hhdc := 0
		if (Screen = 0)
		{
			_x := DllCall( "GetSystemMetrics", "Int", 76 )
			_y := DllCall( "GetSystemMetrics", "Int", 77 )
			_w := DllCall( "GetSystemMetrics", "Int", 78 )
			_h := DllCall( "GetSystemMetrics", "Int", 79 )
		}
		else if (SubStr(Screen, 1, 5) = "hwnd:")
		{
			Screen := SubStr(Screen, 6)
			if !WinExist("ahk_id " Screen)
				return -2
			GDIPlus.CreateRect( &winRect, 0, 0, 0, 0 ) ;is 16 on both 32 and 64
			DllCall( "GetWindowRect", "Ptr", Screen, "Ptr", winRect )
			_w := NumGet("UInt", winRect, 8 )  - NumGet("UInt", winRect, 0)
			_h := NumGet("UInt", winRect, 12) - NumGet("UInt", winRect, 4)
			_x := _y := 0
			hhdc := GDIPlus.GetDCEx(Screen, 3)
		}
		else if type(Screen) = "integer"
		{
			M :=  MonitorGetName(Screen) ;GetMonitorInfo(Screen)
			MonitorGet(Screen,&left,&top,&right,&bottom)
			_x := Left, _y := Top, _w := Right-Left, _h := Bottom-Top
		}
		else
		{
			S := StrSplit(Screen, "|")
			_x := S[1], _y := S[2], _w := S[3], _h := S[4]
		}
		
		if (_x = "") || (_y = "") || (_w = "") || (_h = "")
			return -1
		
		chdc := GDIPlus.CreateCompatibleDC(), hbm := GDIPlus.CreateDIBSection(_w, _h, chdc), obm := GDIPlus.SelectObject(chdc, hbm), hhdc := hhdc ? hhdc : GDIPlus.GetDC()
		GDIPlus.BitBlt(chdc, 0, 0, _w, _h, hhdc, _x, _y, Raster)
		GDIPlus.ReleaseDC(hhdc)
		
		pBitmap := GDIPlus.CreateBitmapFromHBITMAP(hbm)
		GDIPlus.SelectObject(chdc, obm), GDIPlus.DeleteObject(hbm), GDIPlus.DeleteDC(hhdc), GDIPlus.DeleteDC(chdc)
		return pBitmap
	}

	;#####################################################################################
	; Function				Gdip_BitmapFromHWND
	; Description			Uses PrintWindow to get a handle to the specified window and return a bitmap from it
	;
	; hwnd					handle to the window to get a bitmap from
	;
	; return				If the function succeeds, the return value is a pointer to a gdi+ bitmap
	;
	; notes					Window must not be not minimised in order to get a handle to it's client area

	/**
	 * 
	 * @param {Integer} hwnd 
	 */
	Static BitmapFromHWND(hwnd)
	{
		GDIPlus.CreateRect( &winRect, 0, 0, 0, 0 ) ;is 16 on both 32 and 64
		DllCall( "GetWindowRect", "Ptr", hwnd, "Ptr", winRect )
		Width :=  NumGet("UInt", winRect, 8 ) - NumGet("UInt", winRect, 0)
		Height := NumGet("UInt", winRect, 12 ) - NumGet("UInt", winRect, 4)
		hbm := GDIPlus.CreateDIBSection(Width, Height)
		hdc := GDIPlus.CreateCompatibleDC()
		obm := GDIPlus.SelectObject(hdc, hbm)
		GDIPlus.PrintWindow(hwnd, hdc)
		pBitmap := GDIPlus.CreateBitmapFromHBITMAP(hbm)
		GDIPlus.SelectObject(hdc, obm)
		GDIPlus.DeleteObject(hbm)
		GDIPlus.DeleteDC(hdc)
		return pBitmap
	}

	;#####################################################################################
	; Function				CreateRectF
	; Description			Creates a RectF object, containing a the coordinates and dimensions of a rectangle
	;
	; RectF					Name to call the RectF object
	; x						x-coordinate of the upper left corner of the rectangle
	; y						y-coordinate of the upper left corner of the rectangle
	; w						Width of the rectangle
	; h						Height of the rectangle
	;
	; return				No return value

	/**
	 * 
	 * @param {Integer} RectF 
	 * @param {Integer} x 
	 * @param {Integer} y 
	 * @param {Integer} w 
	 * @param {Integer} h 
	 */
	static CreateRectF(&RectF, x, y, w, h)
	{
		RectF := Buffer(16) ;VarSetCapacity(RectF, 16)
		NumPut("float",x, RectF, 0), NumPut("float",y, RectF, 4), NumPut("float",w, RectF, 8), NumPut("float",h, RectF, 12)
	}

	;#####################################################################################
	; Function				CreateRect
	; Description			Creates a Rect object, containing a the coordinates and dimensions of a rectangle
	;
	; RectF		 			Name to call the RectF object
	; x						x-coordinate of the upper left corner of the rectangle
	; y						y-coordinate of the upper left corner of the rectangle
	; w						Width of the rectangle
	; h						Height of the rectangle
	;
	; return				No return value

	/**
	 * 
	 * @param {Integer} Rect 
	 * @param {Integer} x 
	 * @param {Integer} y 
	 * @param {Integer} w 
	 * @param {Integer} h 
	 */
	static CreateRect(&Rect, x, y, w, h)
	{
		Rect := Buffer(16) ;VarSetCapacity(Rect, 16)
		NumPut("uint", x, Rect, 0), NumPut("uint", y, Rect, 4), NumPut("uint", w, Rect, 8), NumPut("uint", h, Rect, 12)
	}

	; Function				CreateSizeF
	; Description			Creates a SizeF object, containing an 2 values
	;
	; SizeF					Name to call the SizeF object
	; w						w-value for the SizeF object
	; h						h-value for the SizeF object
	;
	; return				No Return value

	/**
	 * 
	 * @param {Integer} SizeF 
	 * @param {Integer} w 
	 * @param {Integer} h 
	 */
	static CreateSizeF(&SizeF, w, h)
	{
		SizeF := Buffer(8) ;VarSetCapacity(SizeF, 8)
		NumPut(w, SizeF, 0, "float"), NumPut(h, SizeF, 4, "float")
	}

	;#####################################################################################
	; Function				CreatePointF
	; Description			Creates a SizeF object, containing an 2 values
	;
	; SizeF					Name to call the SizeF object
	; w						w-value for the SizeF object
	; h						h-value for the SizeF object
	;
	; return				No Return value

	/**
	 * 
	 * @param {Integer} PointF 
	 * @param {Integer} x 
	 * @param {Integer} y 
	 */
	static CreatePointF(&PointF, x, y)
	{
		PointF := Buffer(8) ; VarSetCapacity(PointF, 8)
		NumPut( "float", x, PointF, 0), NumPut("float", y, PointF, 4)
	}


	;#####################################################################################
	; Function				CreateDIBSection
	; Description			The CreateDIBSection function creates a DIB (Device Independent Bitmap) that applications can write to directly
	;
	; w						width of the bitmap to create
	; h						height of the bitmap to create
	; hdc					a handle to the device context to use the palette from
	; bpp					bits per pixel (32 = ARGB)
	; ppvBits				A pointer to a variable that receives a pointer to the location of the DIB bit values
	;
	; return				returns a DIB. A gdi bitmap
	;
	; notes					ppvBits will receive the location of the pixels in the DIB

	/**
	 * 
	 * @param {Integer} w 
	 * @param {Integer} h 
	 * @param {Integer} hdc 
	 * @param {Integer} bpp 
	 * @param {Integer} ppvBits 
	 * @returns {Float | Integer | String} 
	 */
	static CreateDIBSection(w, h, hdc:="", bpp:=32, &ppvBits:=0)
	{
	
		hdc2 := hdc ? hdc : GDIPlus.GetDC()
		bi := Buffer(40,0) ; VarSetCapacity(bi, 40, 0)
		
		NumPut("uint"  , w  , bi, 4)
		NumPut("uint"  , h  , bi, 8)
		NumPut("uint"  , 40 , bi, 0)
		NumPut("ushort", 1  , bi, 12)
		NumPut("uInt"  , 0  , bi, 16)
		NumPut("ushort", bpp, bi, 14)

		hbm := DllCall("CreateDIBSection"
						, "Ptr", hdc2
						, "Ptr", bi
						, "uint", 0
						, "Ptr", ppvBits
						, "Ptr", 0
						, "uint", 0, "Ptr")
		
		if !hdc
			GDIPlus.ReleaseDC(hdc2)
		return hbm
	}

	;#####################################################################################
	; Function				PrintWindow
	; Description			The PrintWindow function copies a visual window into the specified device context (DC), typically a printer DC
	;
	; hwnd					A handle to the window that will be copied
	; hdc					A handle to the device context
	; Flags					Drawing options
	;
	; return				If the function succeeds, it returns a nonzero value
	;
	; PW_CLIENTONLY			= 1

	/**
	 * 
	 * @param {Integer} hwnd 
	 * @param {Integer} hdc 
	 * @param {Integer} Flags 
	 * @returns {Float | Integer | String} 
	 */
	static PrintWindow(hwnd, hdc, Flags:=0) => DllCall("PrintWindow", "Ptr", hwnd, "Ptr", hdc, "uint", Flags)

	;#####################################################################################
	; Function				DestroyIcon
	; Description			Destroys an icon and frees any memory the icon occupied
	;
	; hIcon					Handle to the icon to be destroyed. The icon must not be in use
	;
	; return				If the function succeeds, the return value is nonzero

	/**
	 * 
	 * @param {Integer} hIcon 
	 * @returns {Float | Integer | String} 
	 */
	static DestroyIcon(hIcon) => DllCall("DestroyIcon", "Ptr", hIcon)

	;#####################################################################################
	; Function:				GetIconDimensions
	; Description:			Retrieves a given icon/cursor's width and height 
	;
	; hIcon					Pointer to an icon or cursor
	; Width					ByRef variable. This variable is set to the icon's width
	; Height				ByRef variable. This variable is set to the icon's height
	;
	; return				If the function succeeds, the return value is zero, otherwise:
	;						-1 = Could not retrieve the icon's info. Check A_LastError for extended information
	;						-2 = Could not delete the icon's bitmask bitmap
	;						-3 = Could not delete the icon's color bitmap

	/**
	 * 
	 * @param {Integer} hIcon 
	 * @param {Integer} Width 
	 * @param {Integer} Height 
	 * @returns {Number | Integer} 
	 */
	static GetIconDimensions(hIcon, &Width, &Height) {
		Width := Height := 0
		
		;VarSetCapacity(ICONINFO, size := 16 + 2 * A_PtrSize, 0)
		ICONINFO := Buffer(size := 16 + 2 * A_PtrSize, 0)
		
		if !DllCall("user32\GetIconInfo", "Ptr", hIcon, "Ptr", ICONINFO)
			return -1
		
		hbmMask := NumGet(ICONINFO, 16, "Ptr")
		hbmColor := NumGet(ICONINFO, 16 + A_PtrSize, "Ptr")
		;VarSetCapacity(BITMAP, size, 0)
		BITMAP := Buffer(size, 0)
		
		if DllCall("gdi32\GetObject", "Ptr", hbmColor, "Int", size, "Ptr", &BITMAP)
		{
			Width := NumGet(BITMAP, 4, "Int")
			Height := NumGet(BITMAP, 8, "Int")
		}
		
		if !DllCall("gdi32\DeleteObject", "Ptr", hbmMask)
			return -2
		
		if !DllCall("gdi32\DeleteObject", "Ptr", hbmColor)
			return -3
		
		return 0
	}
	/**
	 * 
	 * @param {Integer} hdc 
	 * @returns {Float | Integer | String} 
	 */
	static PaintDesktop(hdc) => DllCall("PaintDesktop", "Ptr", hdc)

	/**
	 * 
	 * @param {Integer} hdc 
	 * @param {Integer} w 
	 * @param {Integer} h 
	 * @returns {Float | Integer | String} 
	 */
	static CreateCompatibleBitmap(hdc, w, h) => DllCall("gdi32\CreateCompatibleBitmap", "Ptr", hdc, "int", w, "int", h)

	;#####################################################################################
	; Function				CreateCompatibleDC
	; Description			This function creates a memory device context (DC) compatible with the specified device
	;
	; hdc					Handle to an existing device context
	;
	; return				returns the handle to a device context or 0 on failure
	;
	; notes					If this handle is 0 (by default), the function creates a memory device context compatible with the application's current screen

	/**
	 * 
	 * @param {Integer} hdc 
	 * @returns {Float | Integer | String} 
	 */
	static CreateCompatibleDC(hdc:=0) => DllCall("CreateCompatibleDC", "Ptr", hdc)

	;####################################################################################
	; Function				SelectObject
	; Description			The SelectObject function selects an object into the specified device context (DC). The new object replaces the previous object of the same type
	;
	; hdc					Handle to a DC
	; hgdiobj				A handle to the object to be selected into the DC
	;
	; return				If the selected object is not a region and the function succeeds, the return value is a handle to the object being replaced
	;
	; notes					The specified object must have been created by using one of the following functions
	;						Bitmap - CreateBitmap, CreateBitmapIndirect, CreateCompatibleBitmap, CreateDIBitmap, CreateDIBSection (A single bitmap cannot be selected into more than one DC at the same time)
	;						Brush - CreateBrushIndirect, CreateDIBPatternBrush, CreateDIBPatternBrushPt, CreateHatchBrush, CreatePatternBrush, CreateSolidBrush
	;						Font - CreateFont, CreateFontIndirect
	;						Pen - CreatePen, CreatePenIndirect
	;						Region - CombineRgn, CreateEllipticRgn, CreateEllipticRgnIndirect, CreatePolygonRgn, CreateRectRgn, CreateRectRgnIndirect
	;
	; notes					If the selected object is a region and the function succeeds, the return value is one of the following value
	;
	; SIMPLEREGION			= 2 Region consists of a single rectangle
	; COMPLEXREGION			= 3 Region consists of more than one rectangle
	; NULLREGION			= 1 Region is empty
	/**
	 * 
	 * @param {Integer} hdc 
	 * @param {Integer} hgdiobj 
	 * @returns {Float | Integer | String} 
	 */
	static SelectObject(hdc, hgdiobj) => DllCall("SelectObject", "Ptr", hdc, "Ptr", hgdiobj)

	;#####################################################################################
	; Function				DeleteObject
	; Description			This function deletes a logical pen, brush, font, bitmap, region, or palette, freeing all system resources associated with the object
	;						After the object is deleted, the specified handle is no longer valid
	;
	; hObject				Handle to a logical pen, brush, font, bitmap, region, or palette to delete
	;
	; return				Nonzero indicates success. Zero indicates that the specified handle is not valid or that the handle is currently selected into a device context

	/**
	 * 
	 * @param {Integer} hObject 
	 * @returns {Float | Integer | String} 
	 */
	static DeleteObject(hObject) => DllCall("DeleteObject", "Ptr", hObject)

	;#####################################################################################
	; Function				GetDC
	; Description			This function retrieves a handle to a display device context (DC) for the client area of the specified window.
	;						The display device context can be used in subsequent graphics display interface (GDI) functions to draw in the client area of the window.
	;
	; hwnd					Handle to the window whose device context is to be retrieved. If this value is NULL, GetDC retrieves the device context for the entire screen
	;
	; return				The handle the device context for the specified window's client area indicates success. NULL indicates failure

	/**
	 * 
	 * @param {Integer} hwnd 
	 * @returns {Float | Integer | String} 
	 */
	static GetDC(hwnd:=0) => DllCall("GetDC", "Ptr", hwnd)


	;#####################################################################################
	; DCX_CACHE = 0x2
	; DCX_CLIPCHILDREN = 0x8
	; DCX_CLIPSIBLINGS = 0x10
	; DCX_EXCLUDERGN = 0x40
	; DCX_EXCLUDEUPDATE = 0x100
	; DCX_INTERSECTRGN = 0x80
	; DCX_INTERSECTUPDATE = 0x200
	; DCX_LOCKWINDOWUPDATE = 0x400
	; DCX_NORECOMPUTE = 0x100000
	; DCX_NORESETATTRS = 0x4
	; DCX_PARENTCLIP = 0x20
	; DCX_VALIDATE = 0x200000
	; DCX_WINDOW = 0x1

	/**
	 * 
	 * @param {Integer} hwnd 
	 * @param {Integer} flags 
	 * @param {Integer} hrgnClip 
	 * @returns {Float | Integer | String} 
	 */
	static GetDCEx(hwnd, flags:=0, hrgnClip:=0) => DllCall("GetDCEx", "Ptr", hwnd, "Ptr", hrgnClip, "int", flags)

	;#####################################################################################
	; Function				ReleaseDC
	; Description			This function releases a device context (DC), freeing it for use by other applications. The effect of ReleaseDC depends on the type of device context
	;
	; hdc					Handle to the device context to be released
	; hwnd					Handle to the window whose device context is to be released
	;
	; return				1 = released
	;						0 = not released
	;
	; notes					The application must call the ReleaseDC function for each call to the GetWindowDC function and for each call to the GetDC function that retrieves a common device context
	;						An application cannot use the ReleaseDC function to release a device context that was created by calling the CreateDC function; instead, it must use the DeleteDC function.
    ; duplicate version  ReleaseDC(pGraphics, hdc)
	/**
	 * 
	 * @param {Integer} hdc 
	 * @param {Integer} hwnd 
	 * @returns {Float | Integer | String} 
	 */
	static ReleaseDC(hdc, hwnd:=0) => DllCall("ReleaseDC", "Ptr", hwnd, "Ptr", hdc)

	;#####################################################################################
	; Function				DeleteDC
	; Description			The DeleteDC function deletes the specified device context (DC)
	;
	; hdc					A handle to the device context
	;
	; return				If the function succeeds, the return value is nonzero
	;
	; notes					An application must not delete a DC whose handle was obtained by calling the GetDC function. Instead, it must call the ReleaseDC function to free the DC

	/**
	 * 
	 * @param {Integer} hdc 
	 * @returns {Float | Integer | String} 
	 */
	static DeleteDC(hdc) => DllCall("DeleteDC", "Ptr", hdc)

	;####################################################################################
	; Function				Gdip_LibraryVersion
	; Description			Get the current library version
	;
	; return				the library version
	;
	; notes					This is useful for non compiled programs to ensure that a person doesn't run an old version when testing your scripts

	Static Version()
	{
		return '2.0a'
	}


	;#####################################################################################
	; Function:				Gdip_BitmapFromBRA
	; Description: 			Gets a pointer to a gdi+ bitmap from a BRA file
	;
	; BRAFromMemIn			The variable for a BRA file read to memory
	; File					The name of the file, or its number that you would like (This depends on alternate parameter)
	; Alternate				Changes whether the File parameter is the file name or its number
	;
	; return					If the function succeeds, the return value is a pointer to a gdi+ bitmap
	;						-1 = The BRA variable is empty
	;						-2 = The BRA has an incorrect header
	;						-3 = The BRA has information missing
	;						-4 = Could not find file inside the BRA

	/**
	 * 
	 * @param {Integer} BRAFromMemIn 
	 * @param {String} File 
	 * @param {Integer} Alternate 
	 * @returns {Number} 
	 */
	Static BitmapFromBRA(&BRAFromMemIn, File, Alternate := 0) {
		;pBitmap := ""
		If !(BRAFromMemIn)
			Return -1
		Headers := StrSplit(StrGet(BRAFromMemIn, 256, "CP0"), "`n")
		Header := StrSplit(Headers.1, "|")
		If (Header.Length() != 4) || (Header.2 != "BRA!")
			Return -2
		_Info := StrSplit(Headers.2, "|")
		If (_Info.Length() != 3)
			Return -3
		OffsetTOC := StrPut(Headers.1, "CP0") + StrPut(Headers.2, "CP0") ;  + 2
		OffsetData := _Info.2
		SearchIndex := Alternate ? 1 : 2
		TOC := StrGet(BRAFromMemIn + OffsetTOC, OffsetData - OffsetTOC - 1, "CP0")
		RX1 := A_AhkVersion < "2" ? "mi`nO)^" : "mi`n)^"
		Offset := Size := 0
		If RegExMatch(TOC, RX1 . (Alternate ? File "\|.+?" : "\d+\|" . File) . "\|(\d+)\|(\d+)$", &FileInfo) {
			Offset := OffsetData + FileInfo[1]
			Size := FileInfo[2]
		}
		If (Size = 0)
			Return -4
		hData := DllCall("GlobalAlloc", "UInt", 2, "UPtr", Size, "Ptr")
		pData := DllCall("GlobalLock", "Ptr", hData)
		DllCall("RtlMoveMemory", "Ptr", pData, "Ptr", BRAFromMemIn + Offset, "UPtr", Size)
		DllCall("GlobalUnlock", "Ptr", hData)
		DllCall("Ole32.dll\CreateStreamOnHGlobal", "Ptr", hData, "Int", 1, "Ptr*", &pStream:=0)
		DllCall("Gdiplus.dll\GdipCreateBitmapFromStream", "Ptr", pStream, "Ptr*", &pBitmap:=0)
		ObjRelease(pStream)
		Return pBitmap
	}

	;#####################################################################################
	; Function:				Gdip_BitmapFromBase64
	; Description:			Creates a bitmap from a Base64 encoded string
	;
	; Base64				ByRef variable. Base64 encoded string. Immutable, ByRef to avoid performance overhead of passing long strings.
	;
	; return				If the function succeeds, the return value is a pointer to a bitmap, otherwise:
	;						-1 = Could not calculate the length of the required buffer
	;						-2 = Could not decode the Base64 encoded string
	;						-3 = Could not create a memory stream

	/**
	 * 
	 * @param {Integer} Base64 
	 * @returns {Number} 
	 */
	static BitmapFromBase64(&Base64)
	{
		; calculate the length of the buffer needed
		if !(DllCall("crypt32\CryptStringToBinary", "Ptr", &Base64, "UInt", 0, "UInt", 0x01, "Ptr", 0, "UInt*", &DecLen:=0, "Ptr", 0, "Ptr", 0))
			return -1
		
		Dec := Buffer(DecLen << 1,0)
		
		; decode the Base64 encoded string
		if !(DllCall("crypt32\CryptStringToBinary", "Ptr", &Base64, "UInt", 0, "UInt", 0x01, "Ptr", &Dec, "UInt*", DecLen, "Ptr", 0, "Ptr", 0))
			return -2
		
		; create a memory stream
		if !(pStream := DllCall("shlwapi\SHCreateMemStream", "Ptr", &Dec, "UInt", DecLen))
			return -3
		
		DllCall("gdiplus\GdipCreateBitmapFromStreamICM", "Ptr", pStream, "Ptr*", &pBitmap:=0)
		ObjRelease(pStream)
		return pBitmap
	}

	;#####################################################################################
	; Function				Gdip_DrawRectangle
	; Description			This function uses a pen to draw the outline of a rectangle into the Graphics of a bitmap
	;
	; pGraphics				Pointer to the Graphics of a bitmap
	; pPen					Pointer to a pen
	; x						x-coordinate of the top left of the rectangle
	; y						y-coordinate of the top left of the rectangle
	; w						width of the rectanlge
	; h						height of the rectangle
	;
	; return				status enumeration. 0 = success
	;
	; notes					as all coordinates are taken from the top left of each pixel, then the entire width/height should be specified as subtracting the pen width

	/**
	 * 
	 * @param {Integer} pGraphics 
	 * @param {Integer} pPen 
	 * @param {Integer} x 
	 * @param {Integer} y 
	 * @param {Integer} w 
	 * @param {Integer} h 
	 * @returns {Float | Integer | String} 
	 */
	Static DrawRectangle(pGraphics, pPen, x, y, w, h) => DllCall("gdiplus\GdipDrawRectangle", "Ptr", pGraphics, "Ptr", pPen, "float", x, "float", y, "float", w, "float", h)

	;#####################################################################################
	; Function				Gdip_DrawRoundedRectangle
	; Description			This function uses a pen to draw the outline of a rounded rectangle into the Graphics of a bitmap
	;
	; pGraphics				Pointer to the Graphics of a bitmap
	; pPen					Pointer to a pen
	; x						x-coordinate of the top left of the rounded rectangle
	; y						y-coordinate of the top left of the rounded rectangle
	; w						width of the rectanlge
	; h						height of the rectangle
	; r						radius of the rounded corners
	;
	; return				status enumeration. 0 = success
	;
	; notes					as all coordinates are taken from the top left of each pixel, then the entire width/height should be specified as subtracting the pen width

	/**
	 * 
	 * @param {Integer} pGraphics 
	 * @param {Integer} pPen 
	 * @param {Integer} x 
	 * @param {Integer} y 
	 * @param {Integer} w 
	 * @param {Integer} h 
	 * @param {Integer} r 
	 * @returns {Float | Integer | String} 
	 */
	Static DrawRoundedRectangle(pGraphics, pPen, x, y, w, h, r)
	{
		GDIPlus.SetClipRect(pGraphics, x-r, y-r, 2*r, 2*r, 4)
		GDIPlus.SetClipRect(pGraphics, x+w-r, y-r, 2*r, 2*r, 4)
		GDIPlus.SetClipRect(pGraphics, x-r, y+h-r, 2*r, 2*r, 4)
		GDIPlus.SetClipRect(pGraphics, x+w-r, y+h-r, 2*r, 2*r, 4)
		_E := GDIPlus.DrawRectangle(pGraphics, pPen, x, y, w, h)
		GDIPlus.ResetClip(pGraphics)
		GDIPlus.SetClipRect(pGraphics, x-(2*r), y+r, w+(4*r), h-(2*r), 4)
		GDIPlus.SetClipRect(pGraphics, x+r, y-(2*r), w-(2*r), h+(4*r), 4)
		GDIPlus.DrawEllipse(pGraphics, pPen, x, y, 2*r, 2*r)
		GDIPlus.DrawEllipse(pGraphics, pPen, x+w-(2*r), y, 2*r, 2*r)
		GDIPlus.DrawEllipse(pGraphics, pPen, x, y+h-(2*r), 2*r, 2*r)
		GDIPlus.DrawEllipse(pGraphics, pPen, x+w-(2*r), y+h-(2*r), 2*r, 2*r)
		GDIPlus.ResetClip(pGraphics)
		return _E
	}

	;#####################################################################################
	; Function				Gdip_DrawEllipse
	; Description			This function uses a pen to draw the outline of an ellipse into the Graphics of a bitmap
	;
	; pGraphics				Pointer to the Graphics of a bitmap
	; pPen					Pointer to a pen
	; x						x-coordinate of the top left of the rectangle the ellipse will be drawn into
	; y						y-coordinate of the top left of the rectangle the ellipse will be drawn into
	; w						width of the ellipse
	; h						height of the ellipse
	;
	; return				status enumeration. 0 = success
	;
	; notes					as all coordinates are taken from the top left of each pixel, then the entire width/height should be specified as subtracting the pen width

	/**
	 * 
	 * @param {Integer} pGraphics 
	 * @param {Integer} pPen 
	 * @param {Integer} x 
	 * @param {Integer} y 
	 * @param {Integer} w 
	 * @param {Integer} h 
	 * @returns {Float | Integer | String} 
	 */
	static DrawEllipse(pGraphics, pPen, x, y, w, h) => DllCall("gdiplus\GdipDrawEllipse", "Ptr", pGraphics, "Ptr", pPen, "float", x, "float", y, "float", w, "float", h)

	;#####################################################################################
	; Function				Gdip_DrawBezier
	; Description			This function uses a pen to draw the outline of a bezier (a weighted curve) into the Graphics of a bitmap
	;
	; pGraphics				Pointer to the Graphics of a bitmap
	; pPen					Pointer to a pen
	; x1					x-coordinate of the start of the bezier
	; y1					y-coordinate of the start of the bezier
	; x2					x-coordinate of the first arc of the bezier
	; y2					y-coordinate of the first arc of the bezier
	; x3					x-coordinate of the second arc of the bezier
	; y3					y-coordinate of the second arc of the bezier
	; x4					x-coordinate of the end of the bezier
	; y4					y-coordinate of the end of the bezier
	;
	; return				status enumeration. 0 = success
	;
	; notes					as all coordinates are taken from the top left of each pixel, then the entire width/height should be specified as subtracting the pen width

	/**
	 * 
	 * @param {Integer} pGraphics 
	 * @param {Integer} pPen 
	 * @param {Integer} x1 
	 * @param {Integer} y1 
	 * @param {Integer} x2 
	 * @param {Integer} y2 
	 * @param {Integer} x3 
	 * @param {Integer} y3 
	 * @param {Integer} x4 
	 * @param {Integer} y4 
	 * @returns {Float | Integer | String} 
	 */
	Static DrawBezier(pGraphics, pPen, x1, y1, x2, y2, x3, y3, x4, y4) => DllCall("gdiplus\GdipDrawBezier"
																				, "Ptr", pgraphics
																				, "Ptr", pPen
																				, "float", x1
																				, "float", y1
																				, "float", x2
																				, "float", y2
																				, "float", x3
																				, "float", y3
																				, "float", x4
																				, "float", y4)


	;#####################################################################################
	; Function				Gdip_DrawArc
	; Description			This function uses a pen to draw the outline of an arc into the Graphics of a bitmap
	;
	; pGraphics				Pointer to the Graphics of a bitmap
	; pPen					Pointer to a pen
	; x						x-coordinate of the start of the arc
	; y						y-coordinate of the start of the arc
	; w						width of the arc
	; h						height of the arc
	; StartAngle			specifies the angle between the x-axis and the starting point of the arc
	; SweepAngle			specifies the angle between the starting and ending points of the arc
	;
	; return				status enumeration. 0 = success
	;
	; notes					as all coordinates are taken from the top left of each pixel, then the entire width/height should be specified as subtracting the pen width

	/**
	 * 
	 * @param {Integer} pGraphics 
	 * @param {Integer} pPen 
	 * @param {Integer} x 
	 * @param {Integer} y 
	 * @param {Integer} w 
	 * @param {Integer} h 
	 * @param {Integer} StartAngle 
	 * @param {Integer} SweepAngle 
	 * @returns {Float | Integer | String} 
	 */
	Static DrawArc(pGraphics, pPen, x, y, w, h, StartAngle, SweepAngle) => DllCall("gdiplus\GdipDrawArc"
																					, "Ptr", pGraphics
																					, "Ptr", pPen
																					, "float", x
																					, "float", y
																					, "float", w
																					, "float", h
																					, "float", StartAngle
																					, "float", SweepAngle)

	;#####################################################################################
	; Function				Gdip_DrawPie
	; Description			This function uses a pen to draw the outline of a pie into the Graphics of a bitmap
	;
	; pGraphics				Pointer to the Graphics of a bitmap
	; pPen					Pointer to a pen
	; x						x-coordinate of the start of the pie
	; y						y-coordinate of the start of the pie
	; w						width of the pie
	; h						height of the pie
	; StartAngle			specifies the angle between the x-axis and the starting point of the pie
	; SweepAngle			specifies the angle between the starting and ending points of the pie
	;
	; return				status enumeration. 0 = success
	;
	; notes					as all coordinates are taken from the top left of each pixel, then the entire width/height should be specified as subtracting the pen width

	/**
	 * 
	 * @param {Integer} pGraphics 
	 * @param {Integer} pPen 
	 * @param {Integer} x 
	 * @param {Integer} y 
	 * @param {Integer} w 
	 * @param {Integer} h 
	 * @param {Integer} StartAngle 
	 * @param {Integer} SweepAngle 
	 * @returns {Float | Integer | String} 
	 */
	Static DrawPie(pGraphics, pPen, x, y, w, h, StartAngle, SweepAngle) => DllCall("gdiplus\GdipDrawPie", "Ptr", pGraphics, "Ptr", pPen, "float", x, "float", y, "float", w, "float", h, "float", StartAngle, "float", SweepAngle)
	
	;#####################################################################################
	; Function				Gdip_DrawLine
	; Description			This function uses a pen to draw a line into the Graphics of a bitmap
	;
	; pGraphics				Pointer to the Graphics of a bitmap
	; pPen					Pointer to a pen
	; x1					x-coordinate of the start of the line
	; y1					y-coordinate of the start of the line
	; x2					x-coordinate of the end of the line
	; y2					y-coordinate of the end of the line
	;
	; return				status enumeration. 0 = success

	/**
	 * 
	 * @param {Integer} pGraphics 
	 * @param {Integer} pPen 
	 * @param {Integer} x1 
	 * @param {Integer} y1 
	 * @param {Integer} x2 
	 * @param {Integer} y2 
	 * @returns {Float | Integer | String} 
	 */
	Static DrawLine(pGraphics, pPen, x1, y1, x2, y2) => DllCall("gdiplus\GdipDrawLine"
																	, "Ptr", pGraphics
																	, "Ptr", pPen
																	, "float", x1
																	, "float", y1
																	, "float", x2
																	, "float", y2)

	;#####################################################################################
	; Function				Gdip_DrawLines
	; Description			This function uses a pen to draw a series of joined lines into the Graphics of a bitmap
	;
	; pGraphics				Pointer to the Graphics of a bitmap
	; pPen					Pointer to a pen
	; Points				the coordinates of all the points passed as x1,y1|x2,y2|x3,y3.....
	;
	; return				status enumeration. 0 = success
	/**
	 * 
	 * @param {Integer} pGraphics 
	 * @param {Integer} pPen 
	 * @param {Integer} Points 
	 * @returns {Float | Integer | String} 
	 */
	Static DrawLines(pGraphics, pPen, Points)
	{
		Points := StrSplit(Points, "|")
		;VarSetCapacity(PointF, 8*Points.Length())
		PointF := Buffer(PointF, 8*Points.Length)
		for eachPoint, Point in Points
		{
			Coord := StrSplit(Point, ",")
			NumPut(Coord[1], PointF, 8*(A_Index-1), "float"), NumPut(Coord[2], PointF, (8*(A_Index-1))+4, "float")
		}
		return DllCall("gdiplus\GdipDrawLines", "Ptr", pGraphics, "Ptr", pPen, "Ptr", PointF, "int", Points.Length())
	}

	;#####################################################################################
	; Function				Gdip_FillRoundedRectangle
	; Description			This function uses a brush to fill a rounded rectangle in the Graphics of a bitmap
	;
	; pGraphics				Pointer to the Graphics of a bitmap
	; pBrush				Pointer to a brush
	; x						x-coordinate of the top left of the rounded rectangle
	; y						y-coordinate of the top left of the rounded rectangle
	; w						width of the rectanlge
	; h						height of the rectangle
	; r						radius of the rounded corners
	;
	; return				status enumeration. 0 = success

	/**
	 * 
	 * @param {Integer} pGraphics 
	 * @param {Integer} pBrush 
	 * @param {Integer} x 
	 * @param {Integer} y 
	 * @param {Integer} w 
	 * @param {Integer} h 
	 * @param {Integer} r 
	 * @returns {Float | Integer | String} 
	 */
	Static FillRoundedRectangle(pGraphics, pBrush, x, y, w, h, r)
	{ 
		Region := GDIPlus.GetClipRegion(pGraphics)
		GDIPlus.SetClipRect(pGraphics, x-r, y-r, 2*r, 2*r, 4)
		GDIPlus.SetClipRect(pGraphics, x+w-r, y-r, 2*r, 2*r, 4)
		GDIPlus.SetClipRect(pGraphics, x-r, y+h-r, 2*r, 2*r, 4)
		GDIPlus.SetClipRect(pGraphics, x+w-r, y+h-r, 2*r, 2*r, 4)
		_E := GDIPlus.FillRectangle(pGraphics, pBrush, x, y, w, h)
		GDIPlus.SetClipRegion(pGraphics, Region, 0)
		GDIPlus.SetClipRect(pGraphics, x-(2*r), y+r, w+(4*r), h-(2*r), 4)
		GDIPlus.SetClipRect(pGraphics, x+r, y-(2*r), w-(2*r), h+(4*r), 4)
		GDIPlus.FillEllipse(pGraphics, pBrush, x, y, 2*r, 2*r)
		GDIPlus.FillEllipse(pGraphics, pBrush, x+w-(2*r), y, 2*r, 2*r)
		GDIPlus.FillEllipse(pGraphics, pBrush, x, y+h-(2*r), 2*r, 2*r)
		GDIPlus.FillEllipse(pGraphics, pBrush, x+w-(2*r), y+h-(2*r), 2*r, 2*r)
		GDIPlus.SetClipRegion(pGraphics, Region, 0)
		GDIPlus.DeleteRegion(Region)
		return _E
	}

	;#####################################################################################
	; Function				Gdip_FillPolygon
	; Description			This function uses a brush to fill a polygon in the Graphics of a bitmap
	;
	; pGraphics				Pointer to the Graphics of a bitmap
	; pBrush				Pointer to a brush
	; Points				the coordinates of all the points passed as x1,y1|x2,y2|x3,y3.....
	;
	; return				status enumeration. 0 = success
	;
	; notes					Alternate will fill the polygon as a whole, wheras winding will fill each new "segment"
	; Alternate 			= 0
	; Winding 				= 1

	/**
	 * 
	 * @param {Integer} pGraphics 
	 * @param {Integer} pBrush 
	 * @param {Integer} Points 
	 * @param {Integer} FillMode 
	 * @returns {Float | Integer | String} 
	 */
	Static FillPolygon(pGraphics, pBrush, Points, FillMode:=0)
	{
		Points := StrSplit(Points, "|")
		;VarSetCapacity(PointF, )
		PointF := Buffer(8*Points.Length)
		For eachPoint, Point in Points
		{
			Coord := StrSplit(Point, ",")
			NumPut(Coord[1], PointF, 8*(A_Index-1), "float"), NumPut(Coord[2], PointF, (8*(A_Index-1))+4, "float")
		}
		return DllCall("gdiplus\GdipFillPolygon", "Ptr", pGraphics, "Ptr", pBrush, "Ptr", PointF, "int", Points.Length(), "int", FillMode)
	}


	;#####################################################################################
	; Function				Gdip_FillPie
	; Description			This function uses a brush to fill a pie in the Graphics of a bitmap
	;
	; pGraphics				Pointer to the Graphics of a bitmap
	; pBrush				Pointer to a brush
	; x						x-coordinate of the top left of the pie
	; y						y-coordinate of the top left of the pie
	; w						width of the pie
	; h						height of the pie
	; StartAngle			specifies the angle between the x-axis and the starting point of the pie
	; SweepAngle			specifies the angle between the starting and ending points of the pie
	;
	; return				status enumeration. 0 = success

	/**
	 * 
	 * @param pGraphics 
	 * @param pBrush 
	 * @param {Integer} x 
	 * @param {Integer} y 
	 * @param {Integer} w 
	 * @param {Integer} h 
	 * @param StartAngle 
	 * @param SweepAngle 
	 * @returns {Float | Integer | String} 
	 */
	Static FillPie(pGraphics, pBrush, x, y, w, h, StartAngle, SweepAngle) => DllCall("gdiplus\GdipFillPie"
																				, "Ptr", pGraphics
																				, "Ptr", pBrush
																				, "float", x
																				, "float", y
																				, "float", w
																				, "float", h
																				, "float", StartAngle
																				, "float", SweepAngle)


	;#####################################################################################
	; Function				Gdip_FillEllipse
	; Description			This function uses a brush to fill an ellipse in the Graphics of a bitmap
	;
	; pGraphics				Pointer to the Graphics of a bitmap
	; pBrush				Pointer to a brush
	; x						x-coordinate of the top left of the ellipse
	; y						y-coordinate of the top left of the ellipse
	; w						width of the ellipse
	; h						height of the ellipse
	;
	; return				status enumeration. 0 = success

	/**
	 * 
	 * @param pGraphics 
	 * @param pBrush 
	 * @param {Integer} x 
	 * @param {Integer} y 
	 * @param {Integer} w 
	 * @param {Integer} h 
	 * @returns {Float | Integer | String} 
	 */
	static FillEllipse(pGraphics, pBrush, x, y, w, h) => DllCall("gdiplus\GdipFillEllipse", "Ptr", pGraphics, "Ptr", pBrush, "float", x, "float", y, "float", w, "float", h)


	;#####################################################################################
	; Function				Gdip_FillRegion
	; Description			This function uses a brush to fill a region in the Graphics of a bitmap
	;
	; pGraphics				Pointer to the Graphics of a bitmap
	; pBrush				Pointer to a brush
	; Region				Pointer to a Region
	;
	; return				status enumeration. 0 = success
	;
	; notes					You can create a region Gdip_CreateRegion() and then add to this

	/**
	 * 
	 * @param {Integer} pGraphics 
	 * @param {Integer} pBrush 
	 * @param {Integer} Region 
	 * @returns {Float | Integer | String} 
	 */
	static FillRegion(pGraphics, pBrush, Region) => DllCall("gdiplus\GdipFillRegion", "Ptr", pGraphics, "Ptr", pBrush, "Ptr", Region)

	;#####################################################################################
	; Function				Gdip_FillPath
	; Description			This function uses a brush to fill a path in the Graphics of a bitmap
	;
	; pGraphics				Pointer to the Graphics of a bitmap
	; pBrush				Pointer to a brush
	; Region				Pointer to a Path
	;
	; return				status enumeration. 0 = success
	/**
	 * 
	 * @param {Integer} pGraphics 
	 * @param {Integer} pBrush 
	 * @param {Integer} pPath 
	 * @returns {Float | Integer | String} 
	 */
	static FillPath(pGraphics, pBrush, pPath) => DllCall("gdiplus\GdipFillPath", "Ptr", pGraphics, "Ptr", pBrush, "Ptr", pPath)

	;#####################################################################################
	; Function				Gdip_DrawImagePointsRect
	; Description			This function draws a bitmap into the Graphics of another bitmap and skews it
	;
	; pGraphics				Pointer to the Graphics of a bitmap
	; pBitmap				Pointer to a bitmap to be drawn
	; Points				Points passed as x1,y1|x2,y2|x3,y3 (3 points: top left, top right, bottom left) describing the drawing of the bitmap
	; sx					x-coordinate of source upper-left corner
	; sy					y-coordinate of source upper-left corner
	; sw					width of source rectangle
	; sh					height of source rectangle
	; Matrix				a matrix used to alter image attributes when drawing
	;
	; return				status enumeration. 0 = success
	;
	; notes					if sx,sy,sw,sh are missed then the entire source bitmap will be used
	;						Matrix can be omitted to just draw with no alteration to ARGB
	;						Matrix may be passed as a digit from 0 - 1 to change just transparency
	;						Matrix can be passed as a matrix with any delimiter

	/**
	 * 
	 * @param {Integer} pGraphics 
	 * @param {Integer} pBitmap 
	 * @param {Integer} Points 
	 * @param {Integer} sx 
	 * @param {Integer} sy 
	 * @param {Integer} sw 
	 * @param {Integer} sh 
	 * @param {Integer} Matrix 
	 * @returns {Float | Integer | String} 
	 */
	Static DrawImagePointsRect(pGraphics, pBitmap, Points, sx:="", sy:="", sw:="", sh:="", Matrix:=1)
	{
		Ptr := A_PtrSize ? "UPtr" : "UInt"
		
		Points := StrSplit(Points, "|")
		PointF := buffer(8*Points.Length()) ;VarSetCapacity(PointF, 8*Points.Length())
		For eachPoint, Point in Points
		{
			Coord := StrSplit(Point, ",")
			NumPut(Coord[1], PointF, 8*(A_Index-1), "float"), NumPut(Coord[2], PointF, (8*(A_Index-1))+4, "float")
		}
		
		; if !IsNumber(Matrix)
		; 	ImageAttr := Gdip_SetImageAttributesColorMatrix(Matrix)
		; else if (Matrix != 1)
		; 	ImageAttr := Gdip_SetImageAttributesColorMatrix("1|0|0|0|0|0|1|0|0|0|0|0|1|0|0|0|0|0|" Matrix "|0|0|0|0|0|1")
		if (type(Matrix) = 'integer')
			ImageAttr := GDIPlus.SetImageAttributesColorMatrix(Matrix)
		else
			ImageAttr := GDIPlus.SetImageAttributesColorMatrix("1|0|0|0|0|0|1|0|0|0|0|0|1|0|0|0|0|0|" Matrix "|0|0|0|0|0|1")



		if (sx = "" && sy = "" && sw = "" && sh = "")
		{
			sx := 0, sy := 0
			img := GDIPlus.GetImageSize(pBitmap)
			sw := dw := img.width
			sh := dh := img.height
		}
		
		_E := DllCall("gdiplus\GdipDrawImagePointsRect"
					, Ptr, pGraphics
					, Ptr, pBitmap
					, Ptr, &PointF
					, "int", Points.Length()
					, "float", sx
					, "float", sy
					, "float", sw
					, "float", sh
					, "int", 2
					, Ptr, ImageAttr
					, Ptr, 0
					, Ptr, 0)
		if ImageAttr
			GDIPlus.DisposeImageAttributes(ImageAttr)
		return _E
	}

	;#####################################################################################
	; Function				Gdip_GraphicsFromHDC
	; Description			This function gets the graphics from the handle to a device context
	;
	; hdc					This is the handle to the device context
	;
	; return				returns a pointer to the graphics of a bitmap
	;
	; notes					You can draw a bitmap into the graphics of another bitmap
	/**
	 * 
	 * @param hdc 
	 */
	Static GraphicsFromHDC(hdc)
	{
		DllCall("gdiplus\GdipCreateFromHDC", "Ptr", hdc, "ptr*", &pGraphics:=0)
		return pGraphics
	}

	;#####################################################################################
	; Function				Gdip_GetDC
	; Description			This function gets the device context of the passed Graphics
	;
	; hdc					This is the handle to the device context
	;
	; return				returns the device context for the graphics of a bitmap

	/**
	 * 
	 * @param {Integer} pGraphics 
	 */
	Static GdipGetDC(pGraphics)
	{
		DllCall("gdiplus\GdipGetDC", "Ptr", pGraphics, "Ptr*", &hdc:=0)
		return hdc
	}

	;#####################################################################################
	; Function				Gdip_GraphicsClear
	; Description			Clears the graphics of a bitmap ready for further drawing
	;
	; pGraphics				Pointer to the graphics of a bitmap
	; ARGB					The colour to clear the graphics to
	;
	; return				status enumeration. 0 = success
	;
	; notes					By default this will make the background invisible
	;						Using clipping regions you can clear a particular area on the graphics rather than clearing the entire graphics

	/**
	 * 
	 * @param {Integer} pGraphics 
	 * @param {Integer} ARGB 
	 * @returns {Float | Integer | String} 
	 */
	Static GraphicsClear(pGraphics, ARGB:=0x00ffffff) => DllCall("gdiplus\GdipGraphicsClear", "Ptr", pGraphics, "int", ARGB)

	;#####################################################################################
	; Function				Gdip_BlurBitmap
	; Description			Gives a pointer to a blurred bitmap from a pointer to a bitmap
	;
	; pBitmap				Pointer to a bitmap to be blurred
	; Blur					The Amount to blur a bitmap by from 1 (least blur) to 100 (most blur)
	;
	; return				If the function succeeds, the return value is a pointer to the new blurred bitmap
	;						-1 = The blur parameter is outside the range 1-100
	;
	; notes					This function will not dispose of the original bitmap

	/**
	 * 
	 * @param {Integer} pBitmap 
	 * @param {Integer} Blur 
	 * @returns {Number} 
	 */
	Static BlurBitmap(pBitmap, Blur)
	{
		if (Blur > 100) || (Blur < 1)
			return -1
		img := GDIPlus.GetImageSize(pBitmap)
		sWidth := img.width
		sHeight := img.height

		dWidth := sWidth//Blur, dHeight := sHeight//Blur
		
		pBitmap1 := GDIPlus.CreateBitmapFromScan(dWidth, dHeight)
		G1 := GDIPlus.GetImageGraphicsContext(pBitmap1)
		GDIPlus.SetInterpolationMode(G1, 7)
		GDIPlus.DrawImage(G1, pBitmap, 0, 0, dWidth, dHeight, 0, 0, sWidth, sHeight)
		
		GDIPlus.DeleteGraphics(G1)
		
		pBitmap2 := GDIPlus.CreateBitmapFromScan(sWidth, sHeight)
		G2 := GDIPlus.GetImageGraphicsContext(pBitmap2)
		GDIPlus.SetInterpolationMode(G2, 7)
		GDIPlus.DrawImage(G2, pBitmap1, 0, 0, sWidth, sHeight, 0, 0, dWidth, dHeight)
		
		GDIPlus.DeleteGraphics(G2)
		GDIPlus.DisposeImage(pBitmap1)
		return pBitmap2
	}

	;#####################################################################################
	; Function				Gdip_GetPixel
	; Description			Gets the ARGB of a pixel in a bitmap
	;
	; pBitmap				Pointer to a bitmap
	; x						x-coordinate of the pixel
	; y						y-coordinate of the pixel
	;
	; return				Returns the ARGB value of the pixel

	/**
	 * 
	 * @param {Integer} pBitmap 
	 * @param {Integer} x 
	 * @param {Integer} y 
	 */
	static GetPixel(pBitmap, x, y)
	{
		DllCall("gdiplus\GdipBitmapGetPixel", "Ptr", pBitmap, "int", x, "int", y, "Ptr*", &ARGB:=0)
		return ARGB
	}

	;#####################################################################################
	; Function				Gdip_SetPixel
	; Description			Sets the ARGB of a pixel in a bitmap
	;
	; pBitmap				Pointer to a bitmap
	; x						x-coordinate of the pixel
	; y						y-coordinate of the pixel
	;
	; return				status enumeration. 0 = success

	/**
	 * 
	 * @param {Integer} pBitmap 
	 * @param {Integer} x 
	 * @param {Integer} y 
	 * @param {Integer} ARGB 
	 * @returns {Float | Integer | String} 
	 */
	Static SetPixel(pBitmap, x, y, ARGB) => DllCall("gdiplus\GdipBitmapSetPixel", "Ptr", pBitmap, "int", x, "int", y, "int", ARGB)

	;#####################################################################################
	; Function				Gdip_GetDimensions
	; Description			Gives the width and height of a bitmap
	;
	; pBitmap				Pointer to a bitmap
	; Width					ByRef variable. This variable will be set to the width of the bitmap
	; Height				ByRef variable. This variable will be set to the height of the bitmap
	;
	; return				No return value
	;						Gdip_GetDimensions(pBitmap, ThisWidth, ThisHeight) will set ThisWidth to the width and ThisHeight to the height
	; duplicate GetImageSize(pBitmap)

	/**
	 * 
	 * @param {Integer} pBitmap 
	 * @returns {Object} 
	 */
	static GetDimensions(pBitmap) => GDIPlus.GetImageSize(pBitmap)

	/**
	 * 
	 * @param {Integer} pBitmap 
	 * @returns {Object} 
	 */
	Static GetImageDimensions(pBitmap) => GDIPlus.GetImageSize(pBitmap)

	/**
	 * 
	 * @param {Integer} pBitmap 
	 */
	Static GetImagePixelFormat(pBitmap)
	{
		DllCall("gdiplus\GdipGetImagePixelFormat", "Ptr", pBitmap, "ptr*", &Format:=0)
		return Format
	}


	;#####################################################################################
	; Function				Gdip_GetDpiX
	; Description			Gives the horizontal dots per inch of the graphics of a bitmap
	;
	; pBitmap				Pointer to a bitmap
	; Width					ByRef variable. This variable will be set to the width of the bitmap
	; Height				ByRef variable. This variable will be set to the height of the bitmap
	;
	; return				No return value
	;						Gdip_GetDimensions(pBitmap, ThisWidth, ThisHeight) will set ThisWidth to the width and ThisHeight to the height
    ; combined >> Gdip_GetDpiX(pGraphics) Gdip_GetDpiY(pGraphics)

	/**
	 * 
	 * @param {Integer} pGraphics 
	 * @returns {Object} 
	 */
	static GetDpi(pGraphics)
	{
		DllCall("gdiplus\GdipGetDpiX", A_PtrSize ? "UPtr" : "uint", pGraphics, "float*", &dpix:=0)
		DllCall("gdiplus\GdipGetDpiY", A_PtrSize ? "UPtr" : "uint", pGraphics, "float*", &dpiy:=0)
		;return 
		return {X:Round(dpix), Y:Round(dpiy)}
	}


	;#####################################################################################
	/**
	 * 
	 * @param {Integer} pBitmap 
	 * @returns {Integer | String} 
	 */
	Static GetImageHorizontalResolution(pBitmap)
	{
		DllCall("gdiplus\GdipGetImageHorizontalResolution", "Ptr", pBitmap, "float*", &dpix:=0)
		return Round(dpix)
	}

	;#####################################################################################



	/**
	 * 
	 * @param {Integer} pBitmap 
	 * @returns {Integer | String} 
	 */
	Static GetImageVerticalResolution(pBitmap)
	{
		DllCall("gdiplus\GdipGetImageVerticalResolution", "Ptr", pBitmap, "float*", &dpiy:=0)
		return Round(dpiy)
	}

	;#####################################################################################

	/**
	 * 
	 * @param {Integer} pBitmap 
	 * @param {Integer} dpix 
	 * @param {Integer} dpiy  
	 * @returns {Float | Integer | String} 
	 */
	Static BitmapSetResolution(pBitmap, dpix, dpiy) => DllCall("gdiplus\GdipBitmapSetResolution", "Ptr", pBitmap, "float", dpix, "float", dpiy)

	;#####################################################################################

	/**
	 * 
	 * @param {Integer} hBitmap 
	 * @param {Integer} Palette 
	 */
	Static CreateBitmapFromHBITMAP(hBitmap, Palette:=0)
	{
		DllCall("gdiplus\GdipCreateBitmapFromHBITMAP", "Ptr", hBitmap, "Ptr", Palette, "Ptr*", &pBitmap:=0)
		return pBitmap
	}

	;#####################################################################################

	/**
	 * 
	 * @param {Integer} pBitmap 
	 * @param {Integer} Background 
	 */
	Static CreateHBITMAPFromBitmap(pBitmap, Background:=0xffffffff)
	{
		DllCall("gdiplus\GdipCreateHBITMAPFromBitmap", "Ptr", pBitmap, "Ptr*", &hbm:=0, "int", Background)
		return hbm
	}

	;#####################################################################################

	/**
	 * 
	 * @param {Integer} hIcon 
	 */
	Static CreateBitmapFromHICON(hIcon)
	{
		DllCall("gdiplus\GdipCreateBitmapFromHICON", "Ptr", hIcon, "Ptr*", &pBitmap:=0)
		return pBitmap
	}

	;#####################################################################################

	/**
	 * 
	 * @param {Integer} pBitmap 
	 */
	Static CreateHICONFromBitmap(pBitmap)
	{
		; pBitmap := ""
		DllCall("gdiplus\GdipCreateHICONFromBitmap", "Ptr", pBitmap, "Ptr*", &hIcon:=0)
		return hIcon
	}

	;#####################################################################################
	Static CreateBitmapFromClipboard()
	{
		if !DllCall("OpenClipboard", "Ptr", 0)
			return -1
		if !DllCall("IsClipboardFormatAvailable", "uint", 8)
			return -2
		if !hBitmap := DllCall("GetClipboardData", "uint", 2, "Ptr")
			return -3
		if !pBitmap := GDIPlus.CreateBitmapFromHBITMAP(hBitmap)
			return -4
		if !DllCall("CloseClipboard")
			return -5
		GDIPlus.DeleteObject(hBitmap)
		return pBitmap
	}

	;#####################################################################################

	/**
	 * 
	 * @param {Integer} pBitmap 
	 */
	Static SetBitmapToClipboard(pBitmap)
	{
		Ptr := A_PtrSize ? "UPtr" : "UInt"
		off1 := A_PtrSize = 8 ? 52 : 44, off2 := A_PtrSize = 8 ? 32 : 24
		hBitmap := GDIPlus.CreateHBITMAPFromBitmap(pBitmap)
		;DllCall("GetObject", Ptr, hBitmap, "int", VarSetCapacity(oi, A_PtrSize = 8 ? 104 : 84, 0), Ptr, &oi)
		oi := buffer(A_PtrSize = 8 ? 104 : 84, 0)
		DllCall("GetObject", "Ptr", hBitmap, "int", oi.size , "Ptr", &oi)
		hdib := DllCall("GlobalAlloc", "uint", 2, "Ptr", 40+NumGet(oi, off1, "UInt"), "Ptr")
		pdib := DllCall("GlobalLock", "Ptr", hdib, "Ptr")
		DllCall("RtlMoveMemory", "Ptr", pdib, "Ptr", &oi+off2, "Ptr", 40)
		DllCall("RtlMoveMemory", "Ptr", pdib+40, "Ptr", NumGet(oi, off2 - (A_PtrSize ? A_PtrSize : 4), "Ptr"), "Ptr", NumGet(oi, off1, "UInt"))
		DllCall("GlobalUnlock", "Ptr", hdib)
		DllCall("DeleteObject", "Ptr", hBitmap)
		DllCall("OpenClipboard", "Ptr", 0)
		DllCall("EmptyClipboard")
		DllCall("SetClipboardData", "uint", 8, "Ptr", hdib)
		DllCall("CloseClipboard")
	}

	/**
	 * 
	 * @param {Integer} pBitmap 
	 * @param {Integer} x 
	 * @param {Integer} y 
	 * @param {Integer} w 
	 * @param {Integer} h 
	 * @param {Integer} Format 
	 */
	Static CloneBitmapArea(pBitmap, x, y, w, h, Format:=0x26200A)
	{
		DllCall("gdiplus\GdipCloneBitmapArea"
						, "float", x
						, "float", y
						, "float", w
						, "float", h
						, "int", Format
						, "Ptr", pBitmap
						, "Ptr*" , &pBitmapDest:=0)
		return pBitmapDest
	}

	;#####################################################################################
	; Create resources
	;#####################################################################################

	/**
	 * 
	 * @param {Integer} ARGB 
	 * @param {Integer} w 
	 */
	Static CreatePen(ARGB, w)
	{
		DllCall("gdiplus\GdipCreatePen1", "UInt", ARGB, "float", w, "int", 2, "Ptr*", &pPen:=0)
		return pPen
	}

	;#####################################################################################

	/**
	 * 
	 * @param {Integer} pBrush 
	 * @param {Integer} w 
	 */
	Static CreatePenFromBrush(pBrush, w)
	{
		DllCall("gdiplus\GdipCreatePen2", "Ptr", pBrush, "float", w, "int", 2, "Ptr*" , &pPen:=0)
		return pPen
	}

	;#####################################################################################
	
	/**
	 * 
	 * @param {Integer} ARGBfront 
	 * @param {Integer} ARGBback 
	 * @param {Integer} HatchStyle 
	 */
	Static BrushCreateHatch(ARGBfront, ARGBback, HatchStyle:=0)
	{

		DllCall("gdiplus\GdipCreateHatchBrush", "int", HatchStyle, "UInt", ARGBfront, "UInt", ARGBback, "Ptr*", &pBrush:=0)
		return pBrush
	}

	;#####################################################################################

	/**
	 * 
	 * @param {Integer} pBitmap 
	 * @param {Integer} WrapMode 
	 * @param {Integer} x 
	 * @param {Integer} y 
	 * @param {Integer} w 
	 * @param {Integer} h 
	 */
	static CreateTextureBrush(pBitmap, WrapMode:=1, x:=0, y:=0, w:="", h:="")
	{
		if !(w && h)
			DllCall("gdiplus\GdipCreateTexture", "Ptr", pBitmap, "int", WrapMode, "Ptr*", &pBrush:=0)
		else
			DllCall("gdiplus\GdipCreateTexture2", "Ptr", pBitmap, "int", WrapMode, "float", x, "float", y, "float", w, "float", h, "Ptr*", &pBrush:=0)
		return pBrush
	}

	;#####################################################################################

	/**
	 * 
	 * @param {Integer} x1 
	 * @param {Integer} y1 
	 * @param {Integer} x2 
	 * @param {Integer} y2 
	 * @param {Integer} ARGB1 
	 * @param {Integer} ARGB2 
	 * @param {WrapModeTile|WrapModeTileFlipX|WrapModeTileFlipY|WrapModeTileFlipXY|WrapModeClamp} WrapMode
	 */
	Static CreateLineBrush(x1, y1, x2, y2, ARGB1, ARGB2, WrapMode:=1)
	{
		GDIPlus.CreatePointF(&PointF1, x1, y1)
		GDIPlus.CreatePointF(&PointF2, x2, y2)
		DllCall("gdiplus\GdipCreateLineBrush", "Ptr", PointF1, "Ptr", PointF2, "Uint", ARGB1, "Uint", ARGB2, "int", WrapMode, "Ptr*", &LGpBrush:=0)
		return LGpBrush
	}


	;#####################################################################################
	; LinearGradientModeHorizontal = 0
	; LinearGradientModeVertical = 1
	; LinearGradientModeForwardDiagonal = 2
	; LinearGradientModeBackwardDiagonal = 3
	
	/**
	 * 
	 * @param {Integer} x 
	 * @param {Integer} y 
	 * @param {Integer} w 
	 * @param {Integer} h 
	 * @param {Integer} ARGB1 
	 * @param {Integer} ARGB2 
	 * @param {Integer} LinearGradientMode 
	 * @param {LinearGradientModeHorizontal|LinearGradientModeVertical|LinearGradientModeForwardDiagonal|LinearGradientModeBackwardDiagonal} WrapMode 
	 */
	Static CreateLineBrushFromRect(x, y, w, h, ARGB1, ARGB2, LinearGradientMode:=1, WrapMode:=1)
	{
		GDIPlus.CreateRectF(&RectF, x, y, w, h)
		DllCall("gdiplus\GdipCreateLineBrushFromRect", "Ptr", RectF, "int", ARGB1, "int", ARGB2, "int", LinearGradientMode, "int", WrapMode, "Ptr*", &LGpBrush:=0)
		return LGpBrush
	}


	;#####################################################################################
	/**
	 * 
	 * @param {Integer} pBrush 
	 */
	Static CloneBrush(pBrush)
	{
		DllCall("gdiplus\GdipCloneBrush","Ptr", pBrush,"Ptr*", &pBrushClone:=0)
		return pBrushClone
	}

	;#####################################################################################
	; Delete resources
	;#####################################################################################

	/**
	 * 
	 * @param {Integer} pPen 
	 * @returns {Float | Integer | String} 
	 */
	Static DeletePen(pPen) => DllCall("gdiplus\GdipDeletePen", "Ptr", pPen)

	/**
	 * 
	 * @param {Integer} hFont 
	 * @returns {Float | Integer | String} 
	 */
	Static DeleteFont(hFont) => DllCall("gdiplus\GdipDeleteFont", "Ptr", hFont)

	/**
	 * 
	 * @param {Integer} hFormat 
	 * @returns {Float | Integer | String} 
	 */
	Static DeleteStringFormat(hFormat) => DllCall("gdiplus\GdipDeleteStringFormat", "Ptr" , hFormat)

	/**
	 * 
	 * @param {Integer} hFamily 
	 * @returns {Float | Integer | String} 
	 */
	Static DeleteFontFamily(hFamily) => DllCall("gdiplus\GdipDeleteFontFamily", "Ptr" , hFamily)

	/**
	 * 
	 * @param {Integer} Matrix 
	 * @returns {Float | Integer | String} 
	 */
	Static DeleteMatrix(Matrix) => DllCall("gdiplus\GdipDeleteMatrix", "Ptr" , Matrix)

	;#####################################################################################
	; Text functions
	;#####################################################################################

	/**
	 * 
	 * @param {Integer} pGraphics 
	 * @param {String} Text 
	 * @param {Integer} Options 
	 * @param {String} Font 
	 * @param {String} Width 
	 * @param {String} Height 
	 * @param {Integer} Measure 
	 * @returns {Number | Integer | Float | String} 
	 */
	Static TextToGraphics(pGraphics, Text, Options, Font:="Arial", Width:="", Height:="", Measure:=0)
	{
		IWidth := Width, IHeight:= Height := 0
		
		pattern_opts := (A_AhkVersion < "2") ? "iO)" : "i)"
		RegExMatch(Options, pattern_opts "X([\-\d\.]+)(p*)", &xpos)
		RegExMatch(Options, pattern_opts "Y([\-\d\.]+)(p*)", &ypos)
		RegExMatch(Options, pattern_opts "W([\-\d\.]+)(p*)", &Width)
		RegExMatch(Options, pattern_opts "H([\-\d\.]+)(p*)", &Height)
		RegExMatch(Options, pattern_opts "C(?!(entre|enter))([a-f\d]+)", &Colour)
		RegExMatch(Options, pattern_opts "Top|Up|Bottom|Down|vCentre|vCenter", &vPos)
		RegExMatch(Options, pattern_opts "NoWrap", &NoWrap)
		RegExMatch(Options, pattern_opts "R(\d)", &Rendering)
		RegExMatch(Options, pattern_opts "S(\d+)(p*)", &Size)
		
		if Colour && !GDIPlus.DeleteBrush(GDIPlus.CloneBrush(Colour[2]))
			PassBrush := 1, pBrush := Colour[2]
		
		if !(IWidth && IHeight) && ((xpos && xpos[2]) || (ypos && ypos[2]) || (Width && Width[2]) || (Height && Height[2]) || (Size && Size[2]))
			return -1
		
		Style := 0, Styles := "Regular|Bold|Italic|BoldItalic|Underline|Strikeout"
		For eachStyle, valStyle in StrSplit( Styles, "|" )
		{
			if RegExMatch(Options, "\b" valStyle)
				Style |= (valStyle != "StrikeOut") ? (A_Index-1) : 8
		}
		
		Align := 0, Alignments := "Near|Left|Centre|Center|Far|Right"
		For eachAlignment, valAlignment in StrSplit( Alignments, "|" )
		{
			if RegExMatch(Options, "\b" valAlignment)
				Align |= A_Index//2.1	; 0|0|1|1|2|2
		}
		
		xpos := (xpos && (xpos[1] != "")) ? xpos[2] ? IWidth*(xpos[1]/100) : xpos[1] : 0
		ypos := (ypos && (ypos[1] != "")) ? ypos[2] ? IHeight*(ypos[1]/100) : ypos[1] : 0
		Width := (Width && Width[1]) ? Width[2] ? IWidth*(Width[1]/100) : Width[1] : IWidth
		Height := (Height && Height[1]) ? Height[2] ? IHeight*(Height[1]/100) : Height[1] : IHeight
		if !PassBrush
			Colour := "0x" (Colour && Colour[2] ? Colour[2] : "ff000000")
		Rendering := (Rendering && (Rendering[1] >= 0) && (Rendering[1] <= 5)) ? Rendering[1] : 4
		Size := (Size && (Size[1] > 0)) ? Size[2] ? IHeight*(Size[1]/100) : Size[1] : 12
		
		hFamily := GDIPlus.FontFamilyCreate(Font)
		hFont := GDIPlus.FontCreate(hFamily, Size, Style)
		FormatStyle := NoWrap ? 0x4000 | 0x1000 : 0x4000
		hFormat := GDIPlus.StringFormatCreate(FormatStyle)
		pBrush := PassBrush ? pBrush : GDIPlus.BrushCreateSolid(Colour)
		if !(hFamily && hFont && hFormat && pBrush && pGraphics)
			return !pGraphics ? -2 : !hFamily ? -3 : !hFont ? -4 : !hFormat ? -5 : !pBrush ? -6 : 0
		
		GDIPlus.CreateRectF(&RC, xpos, ypos, Width, Height)
		GDIPlus.SetStringFormatAlign(hFormat, Align)
		GDIPlus.SetTextRenderingHint(pGraphics, Rendering)
		ReturnRC := GDIPlus.MeasureString(pGraphics, Text, hFont, hFormat, &RC)
		
		if vPos
		{
			ReturnRC := StrSplit(ReturnRC, "|")
			
			if (vPos[0] = "vCentre") || (vPos[0] = "vCenter")
				ypos += (Height-ReturnRC[4])//2
			else if (vPos[0] = "Top") || (vPos[0] = "Up")
				ypos := 0
			else if (vPos[0] = "Bottom") || (vPos[0] = "Down")
				ypos := Height-ReturnRC[4]
			
			GDIPlus.CreateRectF(&RC, xpos, ypos, Width, ReturnRC[4])
			ReturnRC := GDIPlus.MeasureString(pGraphics, Text, hFont, hFormat, &RC)
		}
		
		if !Measure
			_E := GDIPlus.DrawString(pGraphics, Text, hFont, hFormat, pBrush, &RC)
		
		if !PassBrush
			GDIPlus.DeleteBrush(pBrush)
		GDIPlus.DeleteStringFormat(hFormat)
		GDIPlus.DeleteFont(hFont)
		GDIPlus.DeleteFontFamily(hFamily)
		return _E ? _E : ReturnRC
	}


	;#####################################################################################

	/**
	 * 
	 * @param {Integer} pGraphics 
	 * @param {Integer} sString 
	 * @param {Integer} hFont 
	 * @param {Integer} hFormat 
	 * @param {Integer} pBrush 
	 * @param {Integer} RectF 
	 * @returns {Float | Integer | String} 
	 */
	static DrawString(pGraphics, sString, hFont, hFormat, pBrush, &RectF) => DllCall("gdiplus\GdipDrawString"
																						, "Ptr", pGraphics
																						, "Ptr", sString
																						, "int", -1
																						, "Ptr", hFont
																						, "Ptr", RectF
																						, "Ptr", hFormat
																						, "Ptr", pBrush)

	/**
	 * 
	 * @param {Integer} pGraphics 
	 * @param {Integer} sString 
	 * @param {Integer} hFont 
	 * @param {Integer} hFormat 
	 * @param {Integer} RectF 
	 * @returns {String | Integer} 
	 */
	Static MeasureString(pGraphics, sString, hFont, hFormat, &RectF)
	{
		Ptr := A_PtrSize ? "UPtr" : "UInt"
		
		RC := buffer(16) ;VarSetCapacity(RC, 16)
		DllCall("gdiplus\GdipMeasureString"
						, "Ptr", pGraphics
						, "Ptr", sString
						, "int", -1
						, "Ptr", hFont
						, "Ptr", RectF
						, "Ptr", hFormat
						, "Ptr", RC
						, "uint*", &Chars:=0
						, "uint*", &Lines:=0)
		
		return &RC ? NumGet("float", RC, 0 ) "|" NumGet("float", RC, 4) "|" NumGet("float",RC, 8) "|" NumGet("float", RC, 12) "|" Chars "|" Lines : 0
	}

	; Near = 0
	; Center = 1
	; Far = 2

	/**
	 * 
	 * @param {Integer} hFormat 
	 * @param {Integer} Align 
	 * @returns {Float | Integer | String} 
	 */
	Static SetStringFormatAlign(hFormat, Align)
	{
		return DllCall("gdiplus\GdipSetStringFormatAlign", "Ptr", hFormat, "int", Align)
	}

	; StringFormatFlagsDirectionRightToLeft    = 0x00000001
	; StringFormatFlagsDirectionVertical       = 0x00000002
	; StringFormatFlagsNoFitBlackBox           = 0x00000004
	; StringFormatFlagsDisplayFormatControl    = 0x00000020
	; StringFormatFlagsNoFontFallback          = 0x00000400
	; StringFormatFlagsMeasureTrailingSpaces   = 0x00000800
	; StringFormatFlagsNoWrap                  = 0x00001000
	; StringFormatFlagsLineLimit               = 0x00002000
	; StringFormatFlagsNoClip                  = 0x00004000

	/**
	 * 
	 * @param {Integer} Format 
	 * @param {Integer} Lang 
	 */
	Static StringFormatCreate(Format:=0, Lang:=0)
	{
		DllCall("gdiplus\GdipCreateStringFormat", "int", Format, "int", Lang, "Ptr*", &hFormat:=0)
		return hFormat
	}

	; Regular = 0
	; Bold = 1
	; Italic = 2
	; BoldItalic = 3
	; Underline = 4
	; Strikeout = 8

	/**
	 * 
	 * @param {Integer} hFamily 
	 * @param {Integer} Size 
	 * @param {Integer} Style 
	 */
	Static FontCreate(hFamily, Size, Style:=0)
	{
		DllCall("gdiplus\GdipCreateFont", "Ptr", hFamily, "float", Size, "int", Style, "int", 0, "Ptr*", &hFont:=0)
		return hFont
	}

	/**
	 * 
	 * @param {Integer} Font 
	 */
	Static FontFamilyCreate(Font)
	{
		DllCall("gdiplus\GdipCreateFontFamilyFromName"
						, "Ptr", Font
						, "uint", 0
						, "Ptr*", &hFamily:=0)
		
		return hFamily
	}

	;#####################################################################################
	; Matrix functions
	;#####################################################################################

	/**
	 * 
	 * @param {Integer} m11 
	 * @param {Integer} m12 
	 * @param {Integer} m21 
	 * @param {Integer} m22 
	 * @param {Integer} x 
	 * @param {Integer} y 
	 */
	Static CreateAffineMatrix(m11, m12, m21, m22, x, y)
	{
		DllCall("gdiplus\GdipCreateMatrix2", "float", m11, "float", m12, "float", m21, "float", m22, "float", x, "float", y, "Ptr*", &Matrix:=0)
		return Matrix
	}

	Static CreateMatrix()
	{
		DllCall("gdiplus\GdipCreateMatrix", "Ptr*", &Matrix:=0)
		return Matrix
	}

	;#####################################################################################
	; GraphicsPath functions
	;#####################################################################################

	; Alternate = 0
	; Winding = 1

	/**
	 * 
	 * @param {Integer} BrushMode 
	 */
	Static CreatePath(BrushMode:=0)
	{
		DllCall("gdiplus\GdipCreatePath", "int", BrushMode, "Ptr*", &pPath:=0)
		return pPath
	}

	/**
	 * 
	 * @param {Integer} pPath 
	 * @param {Integer} x 
	 * @param {Integer} y 
	 * @param {Integer} w 
	 * @param {Integer} h 
	 * @returns {Float | Integer | String} 
	 */
	Static AddPathEllipse(pPath, x, y, w, h) => DllCall("gdiplus\GdipAddPathEllipse", "Ptr", pPath, "float", x, "float", y, "float", w, "float", h)

	/**
	 * 
	 * @param {Integer} pPath 
	 * @param {Integer} Points 
	 * @returns {Float | Integer | String} 
	 */
	Static AddPathPolygon(pPath, Points)
	{
		Points := StrSplit(Points, "|")
		PointF := Buffer(8*Points.Length())  ;VarSetCapacity(PointF, 8*Points.Length())
		for eachPoint, Point in Points
		{
			Coord := StrSplit(Point, ",")
			NumPut("float", Coord[1], PointF, 8*(A_Index-1)), NumPut("float", Coord[2], PointF, (8*(A_Index-1))+4)
		}
		return DllCall("gdiplus\GdipAddPathPolygon", "Ptr", pPath, "Ptr", &PointF, "int", Points.Length())
	}

	/**
	 * 
	 * @param {Integer} pPath 
	 * @returns {Float | Integer | String} 
	 */
	Static DeletePath(pPath) => DllCall("gdiplus\GdipDeletePath", "Ptr", pPath)

	;#####################################################################################
	; Quality functions
	;#####################################################################################

	; SystemDefault = 0
	; SingleBitPerPixelGridFit = 1
	; SingleBitPerPixel = 2
	; AntiAliasGridFit = 3
	; AntiAlias = 4
	/**
	 * 
	 * @param {Integer} pGraphics 
	 * @param {Integer} RenderingHint 
	 * @returns {Float | Integer | String} 
	 */
	Static SetTextRenderingHint(pGraphics, RenderingHint) => DllCall("gdiplus\GdipSetTextRenderingHint", "Ptr", pGraphics, "int", RenderingHint)

	; Default = 0
	; LowQuality = 1
	; HighQuality = 2
	; Bilinear = 3
	; Bicubic = 4
	; NearestNeighbor = 5
	; HighQualityBilinear = 6
	; HighQualityBicubic = 7

	/**
	 * 
	 * @param {Integer} pGraphics 
	 * @param {Integer} InterpolationMode 
	 * @returns {Float | Integer | String} 
	 */
	Static SetInterpolationMode(pGraphics, InterpolationMode) => DllCall("gdiplus\GdipSetInterpolationMode", "Ptr", pGraphics, "int", InterpolationMode)

	; Default = 0
	; HighSpeed = 1
	; HighQuality = 2
	; None = 3
	; AntiAlias = 4

	/**
	 * 
	 * @param {Integer} pGraphics 
	 * @param {Integer} SmoothingMode 
	 * @returns {Float | Integer | String} 
	 */
	Static SetSmoothingMode(pGraphics, SmoothingMode) => DllCall("gdiplus\GdipSetSmoothingMode", "Ptr", pGraphics, "int", SmoothingMode)
	
	; CompositingModeSourceOver = 0 (blended)
	; CompositingModeSourceCopy = 1 (overwrite)
	/**
	 * 
	 * @param {Integer} pGraphics 
	 * @param {Integer} CompositingMode 
	 * @returns {Float | Integer | String} 
	 */
	Static SetCompositingMode(pGraphics, CompositingMode:=0) => DllCall("gdiplus\GdipSetCompositingMode", "Ptr", pGraphics, "int", CompositingMode)
	
}



