﻿/**
 * =========================================================================== *
 * Want a clear path for learning AutoHotkey?                                  *
 * Take a look at our AutoHotkey courses here: the-Automator.com/Discover      *
 * They're structured in a way to make learning AHK EASY                       *
 * And come with a 200% moneyback guarantee so you have NOTHING to risk!       *
 * =========================================================================== *
 * @author      the-Automator                                                  *
 * @version     0.0.0                                                          *
 * @DevPath     S:\lib\v2\WebViewToo\AHK Resources\ComVar.ahk                  *
 * @copyright   Copyright (c) 2024 The Automator                               *
 * @link        https://www.the-automator.com/                                 *
 * @created     YYYY-DD-MM                                                     *
 * @modified    YYYY-DD-MM                                                     *
 * @description                                                                *
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

; Construction and deconstruction VARIANT struct
class ComVar {
	/**
	 * Construction VARIANT struct, `ptr` property points to the address, `__Item` property returns var's Value
	 * @param vVal Values that need to be wrapped, supports String, Integer, Double, Array, ComValue, ComObjArray
	 * ### example
	 * `var1 := ComVar('string'), MsgBox(var1[])`
	 * 
	 * `var2 := ComVar([1,2,3,4], , true)`
	 * 
	 * `var3 := ComVar(ComValue(0xb, -1))`
	 * @param vType Variant's type, VT_VARIANT(default)
	 * @param convert Convert AHK's array to ComObjArray
	 */
	__New(vVal := unset, vType := 0xC, convert := false) {
		static size := 8 + 2 * A_PtrSize
		this.var := Buffer(size, 0), this.owner := true
		this.ref := ComValue(0x4000 | vType, this.var.Ptr + (vType = 0xC ? 0 : 8))
		if IsSet(vVal) {
			if (Type(vVal) == "ComVar") {
				this.var := vVal.var, this.ref := vVal.ref, this.obj := vVal, this.owner := false
			} else {
				if (IsObject(vVal)) {
					if (vType != 0xC)
						this.ref := ComValue(0x400C, this.var.ptr)
					if convert && (vVal is Array) {
						switch Type(vVal[1]) {
							case "Integer": vType := 3
							case "String": vType := 8
							case "Float": vType := 5
							case "ComValue", "ComObject": vType := ComObjType(vVal[1])
							default: vType := 0xC
						}
						ComObjFlags(obj := ComObjArray(vType, vVal.Length), -1), i := 0, this.ref[] := obj
						for v in vVal
							obj[i++] := v
					} else
						this.ref[] := vVal
				} else
					this.ref[] := vVal
			}
		}
	}
	__Delete() => (this.owner ? DllCall("oleaut32\VariantClear", "ptr", this.var) : 0)
	__Item {
		get => this.ref[]
		set => this.ref[] := value
	}
	Ptr => this.var.Ptr
	Size => this.var.Size
	Type {
		get => NumGet(this.var, "ushort")
		set {
			if (!this.IsVariant)
				throw PropertyError("VarType is not VT_VARIANT, Type is read-only.", -2)
			NumPut("ushort", Value, this.var)
		}
	}
	IsVariant => ComObjType(this.ref) & 0xC
}