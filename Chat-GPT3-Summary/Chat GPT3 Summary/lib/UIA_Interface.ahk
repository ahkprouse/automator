﻿/*
	Introduction & credits
	This library implements Microsoft's UI Automation framework. More information is here: https://docs.microsoft.com/en-us/windows/win32/winauto/entry-uiauto-win32
	Credit for this file mostly goes to jethrow: https://github.com/jethrow/UIA_Interface/blob/master/UIA_Interface.ahk
	I have added a lot of modifications to it, including custom methods for elements (eg element.Click()), UIA_Enum class etc
*/

/* 
	Usage
	UIA needs to be initialized with UIA_Interface() function, which returns a UIA_Interface object:
	UIA := UIA_Interface()
	After calling this function, all UIA_Interface class properties and methods can be accessed through it. 
	In addition some extra variables are initialized: 
		CurrentVersion contains the version number of IUIAutomation interface
		TrueCondition contains a UIA_TrueCondition
		TreeWalkerTrue contains an UIA_TreeWalker that was created with UIA_TrueCondition
	Note that a new UIA_Interface object can't be created with the "new" keyword. 
	
	UIAutomation constants and enumerations are available from the UIA_Enum class (see a more thorough description at the class header).
	Microsoft documentation for constants and enumerations:
		UI Automation Constants: https://docs.microsoft.com/en-us/windows/win32/winauto/uiauto-entry-constants
		UI Automation Enumerations: https://docs.microsoft.com/en-us/windows/win32/winauto/uiauto-entry-enumerations
	
	For more information, see the AHK Forums post on UIAutomation: https://www.autohotkey.com/boards/viewtopic.php?f=6&t=104999
*/


/* 	
	Questions:
	- if method returns a SafeArray, should we return a Wrapped SafeArray, Raw SafeArray, or AHK Array. Currently we return wrapped AHK arrays for SafeArrays. Although SafeArrays are more convenient to loop over, this causes more confusion in users who are not familiar with SafeArrays (questions such as why are they 0-indexed not 1-indexed, why doesnt for k, v in SafeArray work properly etc). 
	- on UIA Interface conversion methods, how should the data be returned? wrapped/extracted or raw? should raw data be a ByRef param?
	- do variants need cleared? what about SysAllocString BSTRs? As per Microsoft documentation (https://docs.microsoft.com/en-us/cpp/atl-mfc-shared/allocating-and-releasing-memory-for-a-bstr?view=msvc-170), when we pass a BSTR into IUIAutomation, then IUIAutomation should take care of freeing it. But when we receive a UIA_Variant and use UIA_VariantData, then we should clear the BSTR.
	- ObjRelease: if IUIA returns an interface then it automatically increases the ref count for the object it inherits from, and when released decreases it. So do all returned objects (UIA_Element, UIA_Pattern, UIA_TextRange) need to be released? Currently we release these objects as well, but jethrow's version didn't. 
	- do RECT structs need destroyed?
	- if returning wrapped data & raw is ByRef, will the wrapped data being released destroy the raw data?
	- returning variant data other than vt=3|8|9|13|0x2000
	- Cached Members?
	- UIA Element existance - dependent on window being visible (non minimized), and also sometimes Elements are lazily generated (eg Microsoft Teams, when a meeting is started then the toolbar buttons (eg Mute, react) aren't visible to UIA, but hovering over them with the cursor or calling ElementFromPoint causes Teams to generate and make them visible to UIA.
	- better way of supporting differing versions of IUIAutomation (version 2, 3, 4)
	- Get methods vs property getter: currently we use properties when the item stores data, fetching the data is "cheap" and when it doesn't have side-effects, and in computationally expensive cases use Get...(). 
	- should ElementFromHandle etc methods have activateChromiumAccessibility set to True or False? Currently is True, because Chromium apps are very common, and checking whether its on should be relatively fast.
*/

; Base class for all UIA objects (UIA_Interface, UIA_Element etc), that is also used to get constants and enumerations from UIA_Enum.
class UIA_Base {
	__New(p:="", flag:=0, version:="") {
		ObjRawSet(this,"__Type","IUIAutomation" SubStr(this.__Class,5))
		,ObjRawSet(this,"__Value",p)
		,ObjRawSet(this,"__Flag",flag)
		,ObjRawSet(this,"__Version",version)
	}
	__Get(member) {
		local
		global UIA_Enum
		if member not in base,__UIA,TreeWalkerTrue,TrueCondition ; These should act as normal
		{
			if ObjHasKey(UIA_Enum, member) {
				return UIA_Enum[member]
			} else if RegexMatch(member, "i)PatternId|EventId|PropertyId|AttributeId|ControlTypeId|AnnotationType|StyleId|LandmarkTypeId|HeadingLevel|ChangeId|MetadataId", match) {
				return UIA_Enum["UIA_" match](member)
			} else if !InStr(member, "Current")
				try return this["Current" member]
			if InStr(this.__Class, "UIA_Element") {
				if (prop := UIA_Enum.UIA_PropertyId(member))
					return this.GetCurrentPropertyValue(prop)
				else if ((SubStr(member, 1, 6) = "Cached") && (prop := UIA_Enum.UIA_PropertyId(SubStr(member, 7))))
					return this.GetCachedPropertyValue(prop)
				if (member ~= "i)Pattern\d?") { 
					if UIA_Enum.UIA_PatternId(member)
						return this.GetCurrentPatternAs(member)
					else if ((SubStr(member, 1, 6) = "Cached") && UIA_Enum.UIA_PatternId(pattern := SubStr(member, 7)))
						return this.GetCachedPatternAs(pattern)
				}
			}
			throw Exception("Property not supported by the " this.__Class " Class.",-1,member)
		}
	}
	__Set(member, value) {
		if (member != "base") {
			if !InStr(member, "Current")
				try return this["Current" member] := value
			throw Exception("Assigning values not supported by the " this.__Class " Class.",-1,member)
		}
	}
	__Call(member, params*) {
		local
		global UIA_Base, UIA_Enum
		if RegexMatch(member, "i)^(?:UIA_)?(PatternId|EventId|PropertyId|AttributeId|ControlTypeId|AnnotationType|StyleId|LandmarkTypeId|HeadingLevel|ChangeId|MetadataId)$", match) {
			return UIA_Enum["UIA_" match1](params*)
		} else if !ObjHasKey(UIA_Base,member)&&!ObjHasKey(this,member)&&!(member = "_NewEnum") {
			throw Exception("Method Call not supported by the " this.__Class " Class.",-1,member)
		}
	}
	__Delete() {
		this.__Flag ? ((this.__Flag == 2) ? DllCall("GlobalFree", "Ptr", this.__Value) : ObjRelease(this.__Value)):
	}
	__Vt(n) {
		return NumGet(NumGet(this.__Value+0,"ptr")+n*A_PtrSize,"ptr")
	}
}	

/* 
	Exposes methods that enable to discover, access, and filter UI Automation elements. UI Automation exposes every element of the UI Automation as an object represented by the IUIAutomation interface. The members of this interface are not specific to a particular element.
	Microsoft documentation: https://docs.microsoft.com/en-us/windows/win32/api/uiautomationclient/nn-uiautomationclient-iuiautomation
*/
class UIA_Interface extends UIA_Base {
	static __IID := "{30cbe57d-d9d0-452a-ab13-7ac5ac4825ee}"

	; ---------- UIA_Interface properties ----------

	ControlViewWalker[] {
		get {
			local out
			return UIA_Hr(DllCall(this.__Vt(14), "ptr",this.__Value, "ptr*",out:=""))?new UIA_TreeWalker(out):
		}
	}
	ContentViewWalker[] {
		get {
			local out
			return UIA_Hr(DllCall(this.__Vt(15), "ptr",this.__Value, "ptr*",out:=""))?new UIA_TreeWalker(out):
		}
	}
	RawViewWalker[] {
		get {
			local out
			return UIA_Hr(DllCall(this.__Vt(16), "ptr",this.__Value, "ptr*",out:=""))?new UIA_TreeWalker(out):
		}
	}
	RawViewCondition[] {
		get {
			local out
			return UIA_Hr(DllCall(this.__Vt(17), "ptr",this.__Value, "ptr*",out:=""))?new UIA_Condition(out):
		}
	}
	ControlViewCondition[] {
		get {
			local out
			return UIA_Hr(DllCall(this.__Vt(18), "ptr",this.__Value, "ptr*",out:=""))?new UIA_Condition(out):
		}
	}
	ContentViewCondition[] {
		get {
			local out
			return UIA_Hr(DllCall(this.__Vt(19), "ptr",this.__Value, "ptr*",out:=""))?new UIA_Condition(out):
		}
	}
	ProxyFactoryMapping[] {
		get {
			local out
			return UIA_Hr(DllCall(this.__Vt(48), "ptr",this.__Value, "ptr*",out:=""))?new UIA_ProxyFactoryMapping(out):
		}
	}
	ReservedNotSupportedValue[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(54), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}
	ReservedMixedAttributeValue[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(55), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}

	; ---------- UIA_Interface methods ----------
		
	; Compares two UI Automation elements to determine whether they represent the same underlying UI element.
	CompareElements(e1,e2) { 
		local
		return UIA_Hr(DllCall(this.__Vt(3), "ptr",this.__Value, "ptr",e1.__Value, "ptr",e2.__Value, "int*",out:=""))? out:
	}
	; Compares two integer arrays containing run-time identifiers (IDs) to determine whether their content is the same and they belong to the same UI element. r1 and r2 need to be RuntimeId arrays (returned by GetRuntimeId()), where array.base.__Value contains the corresponding safearray.
	CompareRuntimeIds(r1,r2) { 
		local
		return UIA_Hr(DllCall(this.__Vt(4), "ptr",this.__Value, "ptr",ComObjValue(r1.__Value), "ptr",ComObjValue(r2.__Value), "int*",out:=""))? out:
	}
	; Retrieves the UI Automation element that represents the desktop.
	GetRootElement() { 
		local
		return UIA_Hr(DllCall(this.__Vt(5), "ptr",this.__Value, "ptr*",out:=""))? UIA_Element(out):
	}
	; Retrieves a UI Automation element for the specified window. Additionally activateChromiumAccessibility flag can be set to True to send the WM_GETOBJECT message to Chromium-based apps to activate accessibility if it isn't activated.
	ElementFromHandle(hwnd:="A", ByRef activateChromiumAccessibility:=True) { 
		local
		if hwnd is not integer
			hwnd := WinExist(hwnd)
		if !hwnd
			return
		if (activateChromiumAccessibility != 0)
			activateChromiumAccessibility := this.ActivateChromiumAccessibility(hwnd)
		return UIA_Hr(DllCall(this.__Vt(6), "ptr",this.__Value, "ptr",hwnd, "ptr*",out:=""))? UIA_Element(out):
	}
	; Retrieves the UI Automation element at the specified point on the desktop. Additionally activateChromiumAccessibility flag can be set to True to send the WM_GETOBJECT message to Chromium-based apps to activate accessibility if it isn't activated. If Chromium needs to be activated, then activateChromiumAccessibility is set to that windows element.
	ElementFromPoint(x:="", y:="", ByRef activateChromiumAccessibility:=True) { 
		local
		if (x==""||y=="") {
			VarSetCapacity(pt, 8, 0), NumPut(8, pt, "Int"), DllCall("user32.dll\GetCursorPos","UInt",&pt), x :=  NumGet(pt,0,"Int"), y := NumGet(pt,4,"Int")
		}
		if ((activateChromiumAccessibility!=0) && (hwnd := DllCall("GetAncestor", "UInt", DllCall("user32.dll\WindowFromPoint", "int64",  y << 32 | x), "UInt", GA_ROOT := 2))) { ; hwnd from point by SKAN
			activateChromiumAccessibility := this.ActivateChromiumAccessibility(hwnd)
		}
		return UIA_Hr(DllCall(this.__Vt(7), "ptr",this.__Value, "UInt64",x==""||y==""?pt:x&0xFFFFFFFF|(y&0xFFFFFFFF)<<32, "ptr*",out:=""))? UIA_Element(out):
	}	
	; Retrieves the UI Automation element that has the input focus. If activateChromiumAccessibility is set to True, and Chromium needs to be activated, then activateChromiumAccessibility is set to that windows element.
	GetFocusedElement(ByRef activateChromiumAccessibility:=True) { 
		local
		if (activateChromiumAccessibility!=0)
			activateChromiumAccessibility := this.ActivateChromiumAccessibility()
		return UIA_Hr(DllCall(this.__Vt(8), "ptr",this.__Value, "ptr*",out:=""))? UIA_Element(out):
	}
	; Retrieves the UI Automation element that represents the desktop, prefetches the requested properties and control patterns, and stores the prefetched items in the cache.
	GetRootElementBuildCache(cacheRequest) { ; UNTESTED. 
		local
		return UIA_Hr(DllCall(this.__Vt(9), "ptr",this.__Value, "ptr", cacheRequest.__Value, "ptr*",out:=""))? UIA_Element(out):
	}
	; Retrieves a UI Automation element for the specified window, prefetches the requested properties and control patterns, and stores the prefetched items in the cache.
	ElementFromHandleBuildCache(hwnd:="A", cacheRequest:=0, ByRef activateChromiumAccessibility:=True) { 
		local
		if hwnd is not integer
			hwnd := WinExist(hwnd)
		if !hwnd
			return
		if (activateChromiumAccessibility != 0)
			activateChromiumAccessibility := this.ActivateChromiumAccessibility(hwnd, cacheRequest)
		return UIA_Hr(DllCall(this.__Vt(10), "ptr",this.__Value, "ptr",hwnd, "ptr",cacheRequest.__Value, "ptr*",out:=""))? UIA_Element(out):
	}
	; Retrieves the UI Automation element at the specified point on the desktop, prefetches the requested properties and control patterns, and stores the prefetched items in the cache.
	ElementFromPointBuildCache(x:="", y="", cacheRequest:=0, ByRef activateChromiumAccessibility:=True) {
		local 
		if (x==""||y=="")
			VarSetCapacity(pt, 8, 0), NumPut(8, pt, "Int"), DllCall("user32.dll\GetCursorPos","UInt",&pt), x :=  NumGet(pt,0,"Int"), y := NumGet(pt,4,"Int")
		if (activateChromiumAccessibility!=0)
			activateChromiumAccessibility := this.ActivateChromiumAccessibility(hwnd, cacheRequest)
		return UIA_Hr(DllCall(this.__Vt(11), "ptr",this.__Value, "UInt64",x==""||y==""?pt:x&0xFFFFFFFF|(y&0xFFFFFFFF)<<32, "ptr", cacheRequest.__Value, "ptr*",out:=""))? UIA_Element(out):
	}	
	; Retrieves the UI Automation element that has the input focus, prefetches the requested properties and control patterns, and stores the prefetched items in the cache. 
	GetFocusedElementBuildCache(cacheRequest, ByRef activateChromiumAccessibility:=True) { ; UNTESTED. 
		local
		if (activateChromiumAccessibility!=0)
			activateChromiumAccessibility := this.ActivateChromiumAccessibility(,cacheRequest)
		return UIA_Hr(DllCall(this.__Vt(12), "ptr",this.__Value, "ptr", cacheRequest.__Value, "ptr*",out:=""))? UIA_Element(out):
	}
	; Retrieves a UIA_TreeWalker object that can be used to traverse the Microsoft UI Automation tree.
	CreateTreeWalker(condition) {
		local out
		return UIA_Hr(DllCall(this.__Vt(13), "ptr",this.__Value, "ptr",(IsObject(condition)?condition:this.CreateCondition(condition)).__Value, "ptr*",out:=""))? new UIA_TreeWalker(out):
	}
	CreateCacheRequest() { 
		local out
		return UIA_Hr(DllCall(this.__Vt(20), "ptr",this.__Value, "ptr*",out:=""))? new UIA_CacheRequest(out):
	}
	; Creates a condition that is always true.
	CreateTrueCondition() { 
		local out
		return UIA_Hr(DllCall(this.__Vt(21), "ptr",this.__Value, "ptr*",out:=""))? new UIA_BoolCondition(out):
	}
	; Creates a condition that is always false.
	CreateFalseCondition() { 
		local out
		return UIA_Hr(DllCall(this.__Vt(22), "ptr",this.__Value, "ptr*",out:=""))? new UIA_BoolCondition(out):
	}
	; Creates a condition that selects elements that have a property with the specified value. 
	; If type is specified then a new variant is created with the specified variant type, otherwise the type is fetched from UIA_PropertyVariantType enums (so usually this can be left unchanged).
	CreatePropertyCondition(propertyId, value, type:="Variant") { 
		local
		global UIA_Enum, UIA_PropertyCondition
		if propertyId is not integer
			propertyId := UIA_Enum.UIA_PropertyId(propertyId)
		if (type!="Variant")
			UIA_Variant(value,type,value)
		else if (maybeVar := UIA_Enum.UIA_PropertyVariantType(propertyId)) {
			UIA_Variant(value,maybeVar,value)
		}
		return UIA_Hr((A_PtrSize == 4) ? DllCall(this.__Vt(23), "ptr",this.__Value, "int",propertyId, "int64", NumGet(value, 0, "int64"), "int64", NumGet(value, 8, "int64"), "ptr*",out:="") : DllCall(this.__Vt(23), "ptr",this.__Value, "int",propertyId, "ptr",&value, "ptr*",out:=""))? new UIA_PropertyCondition(out):
	}
	; Creates a condition that selects elements that have a property with the specified value (value), using optional flags. If type is specified then a new variant is created with the specified variant type, otherwise the type is fetched from UIA_PropertyVariantType enums (so usually this can be left unchanged). flags can be one of PropertyConditionFlags, default is PropertyConditionFlags_IgnoreCase = 0x1.
	CreatePropertyConditionEx(propertyId, value, type:="Variant", flags:=0x1) { 
		local
		global UIA_Enum, UIA_PropertyCondition
		if propertyId is not integer
			propertyId := UIA_Enum.UIA_PropertyId(propertyId)
		maybeVar := UIA_Enum.UIA_PropertyVariantType(propertyId)
		if (type!="Variant")
			UIA_Variant(value,type,value)
		else if maybeVar {
			UIA_Variant(value,maybeVar,value)
		}
		if (maybeVar != 8) ; Check if the type is not BSTR to remove flags
			flags := 0
		return UIA_Hr((A_PtrSize == 4) ? DllCall(this.__Vt(24), "ptr",this.__Value, "int",propertyId, "int64", NumGet(value, 0, "int64"), "int64", NumGet(value, 8, "int64"), "uint",flags, "ptr*",out:="") : DllCall(this.__Vt(24), "ptr",this.__Value, "int",propertyId, "ptr",&value, "uint",flags, "ptr*",out:=""))? new UIA_PropertyCondition(out):
	}
	; Creates a condition that selects elements that match both of two conditions.
	CreateAndCondition(c1,c2) { 
		local out
		return UIA_Hr(DllCall(this.__Vt(25), "ptr",this.__Value, "ptr",c1.__Value, "ptr",c2.__Value, "ptr*",out:=""))? new UIA_AndCondition(out):
	}
	; Creates a condition that selects elements based on multiple conditions, all of which must be true.
	CreateAndConditionFromArray(array) { 
		local
		global UIA_AndCondition
	;->in: AHK Array or Wrapped SafeArray
		if ComObjValue(array)&0x2000
			SafeArray:=array
		else {
			SafeArray:=ComObj(0x2003,DllCall("oleaut32\SafeArrayCreateVector", "uint",13, "uint",0, "uint",array.MaxIndex()),1)
			for i,c in array
				SafeArray[A_Index-1]:=c.__Value, ObjAddRef(c.__Value) ; AddRef - SafeArrayDestroy will release UIA_Conditions - they also release themselves
		}
		return UIA_Hr(DllCall(this.__Vt(26), "ptr",this.__Value, "ptr",ComObjValue(SafeArray), "ptr*",out:=""))? new UIA_AndCondition(out):
	}
	; Creates a condition that selects elements from a native array, based on multiple conditions that must all be true
	CreateAndConditionFromNativeArray(conditions, conditionCount) { ; UNTESTED. 
		/*	[in]           IUIAutomationCondition **conditions,
			[in]           int conditionCount,
			[out, retval]  IUIAutomationCondition **newCondition
		*/
		local out
		return UIA_Hr(DllCall(this.__Vt(27), "ptr",this.__Value, "ptr", conditions, "int", conditionCount, "ptr*",out:=""))? new UIA_AndCondition(out):
	}
	; Creates a combination of two conditions where a match exists if either of the conditions is true.
	CreateOrCondition(c1,c2) { 
		local out
		return UIA_Hr(DllCall(this.__Vt(28), "ptr",this.__Value, "ptr",c1.__Value, "ptr",c2.__Value, "ptr*",out:=""))? new UIA_OrCondition(out):
	}
	; Creates a combination of two or more conditions where a match exists if any of the conditions is true.
	CreateOrConditionFromArray(array) { 
		local SafeArray, i, c, out
	;->in: AHK Array or Wrapped SafeArray
		if ComObjValue(array)&0x2000
			SafeArray:=array
		else {
			SafeArray:=ComObj(0x2003,DllCall("oleaut32\SafeArrayCreateVector", "uint",13, "uint",0, "uint",array.MaxIndex()),1)
			for i,c in array
				SafeArray[A_Index-1]:=c.__Value, ObjAddRef(c.__Value) ; AddRef - SafeArrayDestroy will release UIA_Conditions - they also release themselves
		}
		return UIA_Hr(DllCall(this.__Vt(29), "ptr",this.__Value, "ptr",ComObjValue(SafeArray), "ptr*",out:=""))? new UIA_OrCondition(out):
	}
	CreateOrConditionFromNativeArray(p*) { ; Not Implemented
		local out
		return UIA_Hr(DllCall(this.__Vt(30), "ptr",this.__Value, "ptr",conditions, "int", conditionCount, "ptr*",out:=""))? new UIA_OrCondition(out):
	/*	[in]           IUIAutomationCondition **conditions,
		[in]           int conditionCount,
		[out, retval]  IUIAutomationCondition **newCondition
	*/
	}
	; Creates a condition that is the negative of a specified condition.
	CreateNotCondition(c) { 
		local out
		return UIA_Hr(DllCall(this.__Vt(31), "ptr",this.__Value, "ptr",c.__Value, "ptr*",out:=""))? new UIA_NotCondition(out):
	}
	; Registers a method that handles Microsoft UI Automation events. eventId must be an EventId enum. scope must be a TreeScope enum. cacheRequest can be specified is caching is used. handler is an event handler object, which can be created with UIA_CreateEventHandler function.
	AddAutomationEventHandler(eventId, element, scope=0x4, cacheRequest=0, handler="") { 
		return UIA_Hr(DllCall(this.__Vt(32), "ptr",this.__Value, "int", eventId, "ptr", element.__Value, "uint", scope, "ptr",cacheRequest.__Value,"ptr",handler.__Value))
	}
	; Removes the specified UI Automation event handler.
	RemoveAutomationEventHandler(eventId, element, handler) { 
		return UIA_Hr(DllCall(this.__Vt(33), "ptr",this.__Value, "int", eventId, "ptr", element.__Value, "ptr",handler.__Value))
	}

	;~ AddPropertyChangedEventHandlerNativeArray 	34
	
	; Registers a method that handles an array of property-changed events
	AddPropertyChangedEventHandler(element,scope:=0x1,cacheRequest:=0,handler:="",propertyArray:="") {
		local
		if !IsObject(propertyArray)
			propertyArray := [propertyArray] 
		SafeArray:=ComObjArray(0x3,propertyArray.MaxIndex())
		for i,propertyId in propertyArray
			SafeArray[i-1]:=propertyId
		return UIA_Hr(DllCall(this.__Vt(35), "ptr",this.__Value, "ptr",element.__Value, "int",scope, "ptr",cacheRequest.__Value,"ptr",handler.__Value,"ptr",ComObjValue(SafeArray)))
	}
	RemovePropertyChangedEventHandler(element, handler) {
		return UIA_Hr(DllCall(this.__Vt(36), "ptr",this.__Value, "ptr",element.__Value, "ptr", handler.__Value))
	}

	AddStructureChangedEventHandler(element, scope:=0x4, cacheRequest:=0, handler:=0) { 
		return UIA_Hr(DllCall(this.__Vt(37), "ptr",this.__Value, "ptr",element.__Value, "int", scope, "ptr", cacheRequest.__Value, "ptr",handler.__Value))
	}
	RemoveStructureChangedEventHandler(element, handler) { ; UNTESTED
		return UIA_Hr(DllCall(this.__Vt(38), "ptr",this.__Value, "ptr", element.__Value, "ptr",handler.__Value))
	}
	; Registers a method that handles ChangedEvent events. handler is required, cacheRequest can be left to 0
	AddFocusChangedEventHandler(handler, cacheRequest:=0) { 
		return UIA_Hr(DllCall(this.__Vt(39), "ptr",this.__Value, "ptr",cacheRequest.__Value, "ptr",handler.__Value))
	}
	RemoveFocusChangedEventHandler(handler) {
		return UIA_Hr(DllCall(this.__Vt(40), "ptr",this.__Value, "ptr",handler.__Value))
	}
	RemoveAllEventHandlers() {
		return UIA_Hr(DllCall(this.__Vt(41), "ptr",this.__Value))
	}

	IntNativeArrayToSafeArray(ByRef nArr, n:="") { 
		local out
		return UIA_Hr(DllCall(this.__Vt(42), "ptr",this.__Value, "ptr",&nArr, "int",n?n:VarSetCapacity(nArr)/4, "ptr*",out:=""))? ComObj(0x2003,out,1):
	}
	IntSafeArrayToNativeArray(sArr, Byref nArr, Byref arrayCount) { ; NOT WORKING
		local
		VarSetCapacity(nArr,(sArr.MaxIndex()+1)*A_PtrSize)
		return UIA_Hr(DllCall(this.__Vt(43), "ptr",this.__Value, "ptr",ComObjValue(sArr), "ptr*",nArr:="", "int*",arrayCount:=""))? nArr:
	}

	RectToVariant(ByRef rect, ByRef out="") {	; in:{left,top,right,bottom} ; out:(left,top,width,height)
		; in:	RECT Struct
		; out:	AHK Wrapped SafeArray & ByRef Variant
		return UIA_Hr(DllCall(this.__Vt(44), "ptr",this.__Value, "ptr",&rect, "ptr",UIA_Variant(out)))? UIA_VariantData(out):
	}
	VariantToRect(ByRef var, ByRef rect="") { ; NOT WORKING
		; in:	VT_VARIANT (SafeArray)
		; out:	AHK Wrapped RECT Struct & ByRef Struct
		VarSetCapacity(rect,16)
		return UIA_Hr(DllCall(this.__Vt(45), "ptr",this.__Value, "ptr",var, "ptr*",rect:=""))? UIA_RectToObject(rect):
	}

	;~ SafeArrayToRectNativeArray 	46
	;~ CreateProxyFactoryEntry 	47
	
	; Retrieves the registered programmatic name of a property. Intended for debugging and diagnostic purposes only. The string is not localized.
	GetPropertyProgrammaticName(Id) { 
		local
		return UIA_Hr(DllCall(this.__Vt(49), "ptr",this.__Value, "int",Id, "ptr*",out:=""))? UIA_GetBSTRValue(out):
	}
	; Retrieves the registered programmatic name of a control pattern. Intended for debugging and diagnostic purposes only. The string is not localized.
	GetPatternProgrammaticName(Id) { 
		local
		return UIA_Hr(DllCall(this.__Vt(50), "ptr",this.__Value, "int",Id, "ptr*",out:=""))? UIA_GetBSTRValue(out):
	}
	; Returns an object where keys are the names and values are the Ids
	PollForPotentialSupportedPatterns(e, Byref Ids:="", Byref Names:="") { 
		return UIA_Hr(DllCall(this.__Vt(51), "ptr",this.__Value, "ptr",e.__Value, "ptr*",Ids:="", "ptr*",Names:=""))? UIA_SafeArraysToObject(Names:=ComObj(0x2008,Names,1),Ids:=ComObj(0x2003,Ids,1)): ; These SafeArrays are wrapped by ComObj, so they will automatically be released
	}
	PollForPotentialSupportedProperties(e, Byref Ids:="", Byref Names:="") {
		return UIA_Hr(DllCall(this.__Vt(52), "ptr",this.__Value, "ptr",e.__Value, "ptr*",Ids:="", "ptr*",Names:=""))? UIA_SafeArraysToObject(Names:=ComObj(0x2008,Names,1),Ids:=ComObj(0x2003,Ids,1)):
	}
	CheckNotSupported(value) { ; Useless in this Framework???
		/*	Checks a provided VARIANT to see if it contains the Not Supported identifier.
			After retrieving a property for a UI Automation element, call this method to determine whether the element supports the 
			retrieved property. CheckNotSupported is typically called after calling a property retrieving method such as GetCurrentPropertyValue.
		*/
		local
		return UIA_Hr(DllCall(this.__Vt(53), "ptr",this.__Value, "ptr",value, "int*",out:=""))? out:
	}
	
	;~ ReservedNotSupportedValue 	54
	;~ ReservedMixedAttributeValue 	55
	
	/*
		This only works if the program implements IAccessible (Acc/MSAA) natively (option 1 in the following explanation). 

		There are two types of Acc objects:
		1) Where the program implements Acc natively. In this case, Acc will be the actual IAccessible object for the implementation.
		2) The program doesn't implement Acc, but Acc instead creates a proxy object which sends messages to the window and maps Win32 controls to a specific IAccessible method. This would be for most Win32 programs, where for example accName would actually do something similar to ControlGetText and return that value. If ElementFromIAccessible is used with this kind of proxy object, E_INVALIDARG - "One or more arguments are not valid" error is returned.
	*/
	ElementFromIAccessible(IAcc, childId:=0) {
		/* The method returns E_INVALIDARG - "One or more arguments are not valid" - if the underlying implementation of the
		Microsoft UI Automation element is not a native Microsoft Active Accessibility server; that is, if a client attempts to retrieve
		the IAccessible interface for an element originally supported by a proxy object from Oleacc.dll, or by the UIA-to-MSAA Bridge.
		*/
		local
		return UIA_Hr(DllCall(this.__Vt(56), "ptr",this.__Value, "ptr",IsObject(IAcc) ? ComObjValue(IAcc) : IAcc, "int",childId, "ptr*",out:=""))? UIA_Element(out):
	}
	ElementFromIAccessibleBuildCache(IAcc, childId:=0, cacheRequest:=0) {
		local
		return UIA_Hr(DllCall(this.__Vt(57), "ptr",this.__Value, "ptr",IsObject(IAcc) ? ComObjValue(IAcc) : IAcc, "int",childId, "ptr", cacheRequest.__Value, "ptr*",out:=""))? UIA_Element(out):
	}

	; ------- ONLY CUSTOM FUNCTIONS FROM HERE ON ----------------

	/*
		CreateCondition can create a condition from an expression, or a PropertyId and property value pair.

		1) If creating a single condition from a PropertyId and value pair:
				propertyOrExpr: Property can be the PropertyId, or (partial) name (eg 30000 == "ControlType" == "ControlTypePropertyId").  
				valueOrFlags: the value corresponding to the PropertyId
				flags: 0=no flags; 1=ignore case (case insensitive matching); 2=match substring; 3=ignore case and match substring
			Example: CreateCondition("Name", "Username", 1) would create a condition with NameProperty and value of "Username", with case sensitivity turned off.
			
		2) If creating a condition from an expression, propertyOrExpr takes the expression and valueOrFlags the default flags, and flags argument is ignored.

			Similarly to FindFirstBy, the expression takes a value in the form of "PropertyId=propertyValue" to create a property condition for PropertyId with the value propertyValue. PropertyId can be most properties from UIA_Enum.UIA_PropertyId method (for example Name, ControlType, AutomationId etc). 
			If propertyValue contains any parentheses, then the value needs to be surrounded by single quotes. Escape ' with \, escape \ with \.
				"Name=Username:" would create a property condition with UIA_Enum.UIA_NamePropertyId and the value "Username:"
				"Name='MyTest\''" creates a NameProperty condition for value "MyTest'"
			
			Criteria can be combined with AND, OR, &&, || (not case sensitive):
				"Name=Username: AND ControlType=Button" would create a condition with the name property of "Username:" and control type of button.
			Parentheses are supported.
			
			Negation can be specified with NOT or !:
				"NOT ControlType=Edit" would create a condition that selects everything but ControlType Edit

			Different flags can be specified for each condition by specifying "FLAGS=n" after the condition value.
				"Name=Username: FLAGS=1" would create a case-insensitive condition only for that condition. By default the flags argument is used.
			
			Flags: 0=no flags; 1=ignore case (case insensitive); 2=match substring; 3=ignore case and match substring
	*/
	CreateCondition(propertyOrExpr, valueOrFlags:="", flags:=0) {
		local
		global UIA_Enum
		if InStr(propertyOrExpr, "=") { ; Expression
			match := "", match3 := "", match5 := "", currentCondition := "", fullCondition := "", operator := "",valueOrFlags := (valueOrFlags == "") ? 0 : valueOrFlags, counter := 1, conditions := [], currentExpr := "(" propertyOrExpr ")"
			; First create all single conditions (not applying AND, OR, NOT)
			while RegexMatch(currentExpr, "i) *(NOT|!)? *(\w+?(?<!UIA_CONDITION)) *=(?: *(\d+|'.*?(?<=[^\\]|[^\\]\\\\)')|([^()]*?)) *(?: FLAGS=(\d))? *?( AND | OR |&&|\|\||[()]|$) *", match) {
				/*
					matchRegex:
						group1 : NOT
						group2 : propertyId
						group3 : propertyValue
						group4 : propertyValueOld
						group5 : "FLAGS" value
						group6 : next and/or operator
					
					Escape ' with \ : 'Test\'' -> Test'
					Escape \ with \ : 'Test\\\'' -> Test\'
				*/
				if !match
					break
				match3 := (match3 == "") ? match4 : match3
				currentFlags := (match5 == "") ? valueOrFlags : match5
				if ((SubStr(match3,1,1) == "'") && (SubStr(match3,0,1) == "'"))
					match3 := StrReplace(RegexReplace(SubStr(match3,2,StrLen(match3)-2), "(?<=[^\\]|[^\\]\\\\)\\'", "'"), "\\", "\")
				conditions[counter] := this.CreateCondition(match2, match3, currentFlags)
				if (match1 == "NOT")
					match1 := "!"
				currentExpr := StrReplace(currentExpr, match, " " match1 "UIA_CONDITION=" counter (match6 ? ((match6 == ")") ? ") " : match6) : ""))
				counter++
			}
			currentExpr := StrReplace(StrReplace(StrReplace(currentExpr, " OR ", "||"), " AND ", "&&"), "NOT", "!")
			; Create NNF: Move NOT conditions to inside parenthesis, remove double NOTs
			While RegexMatch(currentExpr, "! *(\((?:[^)(]+|(?1))*+\))", match) {
				match1 := SubStr(match1, 2, StrLen(match1)-2)
				currentExpr := StrReplace(currentExpr, match, "(" RegexReplace(match1, "([^)(]+?|\((?:[^)(]+|(?1))*+\)) *(\|\||&&|\)|$) *", "!$1$2$3") ")")
				currentExpr := StrReplace(currentExpr, "!!", "")
			}
			; Create all NOT conditions
			pos:=1, match:=""
			While (pos := RegexMatch(currentExpr, "! *UIA_CONDITION=(\d+)", match, pos+StrLen(match))) {
				conditions[match1] := this.CreateNotCondition(conditions[match1])
				currentExpr := StrReplace(currentExpr, match, "UIA_CONDITION=" match1)
				pos -= 1
			}
			; Create AND/OR conditions
			currentExpr := StrReplace(currentExpr, " ", ""), parenthesisMatch:=""
			While RegexMatch(currentExpr, "\(([^()]+)\)", parenthesisMatch) { ; Match parenthesis that doesn't have parentheses inside
				pos := 1, match:="", match1:="", fullCondition:="", operator:=""
				while (pos := RegexMatch(parenthesisMatch1, "UIA_CONDITION=(\d+)(&&|\|\||$)", match, pos+StrLen(match))) {
					fullCondition := (operator == "&&") ? this.CreateAndCondition(fullCondition, conditions[match1]) : (operator == "||") ? this.CreateOrCondition(fullCondition, conditions[match1]) : conditions[match1]
					operator := match2
				}
				conditions[counter] := fullCondition
				currentExpr := StrReplace(currentExpr, parenthesisMatch, "UIA_CONDITION=" counter)
				counter++
			}
			return conditions[counter-1]
		} else {
			if RegexMatch(propertyOrExpr, "^\d+$")
				propCond := propertyOrExpr
			else {
				if (propertyOrExpr = "Type")
					propertyOrExpr := "ControlType"
				RegexMatch(propertyOrExpr, "i)(?:UIA_)?\K.+?(?=(Id)?PropertyId|$)", propertyOrExpr), propCond := UIA_Enum.UIA_PropertyId(propertyOrExpr), propertyOrExpr := StrReplace(StrReplace(propertyOrExpr, "AnnotationAnnotation", "Annotation"), "StylesStyle", "Style")
			}	
			if valueOrFlags is not integer
			{
				valueOrFlags := IsFunc("UIA_Enum.UIA_" propertyOrExpr "Id") ? UIA_Enum["UIA_" propertyOrExpr "Id"](valueOrFlags) : IsFunc("UIA_Enum.UIA_" propertyOrExpr) ? UIA_Enum["UIA_" propertyOrExpr](valueOrFlags) : valueOrFlags
			}
			if propCond
				return this.CreatePropertyConditionEx(propCond, valueOrFlags,, flags)
		}
	}

	; Gets ElementFromPoint and filters out the smallest subelement that is under the specified point. If windowEl (window under the point) is provided, then a deep search is performed for the smallest element (this might be very slow in large trees).
	SmallestElementFromPoint(x:="", y:="", ByRef activateChromiumAccessibility:=True, windowEl:="") { 
		local
		if (x==""||y=="") {
			VarSetCapacity(pt, 8, 0), NumPut(8, pt, "Int"), DllCall("user32.dll\GetCursorPos","UInt",&pt), x :=  NumGet(pt,0,"Int"), y := NumGet(pt,4,"Int")
		}
		if IsObject(windowEl) {
			element := this.ElementFromPoint(x, y, activateChromiumAccessibility)
			bound := element.CurrentBoundingRectangle, elementSize := (bound.r-bound.l)*(bound.b-bound.t), prevElementSize := 0, stack := [windowEl, element], x := x==""?0:x, y := y==""?0:y
			Loop 
			{
				bound := stack[1].CurrentBoundingRectangle
				if ((x >= bound.l) && (x <= bound.r) && (y >= bound.t) && (y <= bound.b)) { ; If parent is not in bounds, then children arent either
					if ((newSize := (bound.r-bound.l)*(bound.b-bound.t)) < elementSize)
						element := stack[1], elementSize := newSize
					for _, childEl in stack[1].GetChildren() {
						bound := childEl.CurrentBoundingRectangle
						if ((x >= bound.l) && (x <= bound.r) && (y >= bound.t) && (y <= bound.b)) { ; Select only children that are under the mouse
							stack.Push(childEl)
							if ((newSize := (bound.r-bound.l)*(bound.b-bound.t)) < elementSize)
								elementSize := newSize, element := childEl
						}
					}
				}
				stack.RemoveAt(1)
			} Until !stack.MaxIndex()
			return element
		} else {
			element := this.ElementFromPoint(x, y, activateChromiumAccessibility)
			bound := element.CurrentBoundingRectangle, elementSize := (bound.r-bound.l)*(bound.b-bound.t), prevElementSize := 0
			for k, v in element.FindAll(this.__UIA.TrueCondition) {
				bound := v.CurrentBoundingRectangle
				if ((x >= bound.l) && (x <= bound.r) && (y >= bound.t) && (y <= bound.b) && ((newSize := (bound.r-bound.l)*(bound.b-bound.t)) < elementSize))
					element := v, elementSize := newSize
			}
			return element
		}
	}
	; This can be used when a Chromium apps content isn't accessible by normal methods (ElementFromHandle, GetRootElement etc). fromFocused=True uses the focused element as a reference point, fromFocused=False uses ElementFromPoint
	GetChromiumContentElement(winTitle:="A", ByRef fromFocused:=True) {
		local
		WinActivate, %winTitle%
		WinWaitActive, %winTitle%,,1
		WinGetPos, X, Y, W, H, %winTitle%
		if fromFocused
			fromFocused := this.GetFocusedElement()
		else
			fromFocused := this.ElementFromPoint(x+w//2, y+h//2) ; Use ElementFromPoint on the center of the window (the actual coordinate doesn't really matter, it just needs to be inside the window)
		chromiumTW := this.CreateTreeWalker(this.CreateCondition("ControlType","Document")) ; Create a TreeWalker to find the Document element (the content)
		try focusedEl := chromiumTW.NormalizeElement(fromFocused) ; Get the first parent that is a Window element
		return focusedEl
	}
	; Tries to get the Chromium content from Chrome_RenderWidgetHostHWND1 control
	ElementFromChromium(winTitle:="A", activateChromiumAccessibility:=True, timeOut:=500) {
		local
		try ControlGet, cHwnd, Hwnd,, Chrome_RenderWidgetHostHWND1, %winTitle%
		if !cHwnd
			return
		cEl := this.ElementFromHandle(cHwnd,False)
		if (activateChromiumAccessibility != 0) {
			SendMessage, WM_GETOBJECT := 0x003D, 0, 1, , ahk_id %cHwnd%
			if cEl {
				cEl.CurrentName ; it doesn't work without calling CurrentName (at least in Skype)
				if (cEl.CurrentControlType == 50030) {
					startTime := A_TickCount
					while (!cEl.CurrentValue && (A_TickCount-startTime < timeOut))
						Sleep, 20
				}
			}
		}
		return cEl
	}
	; In some setups Chromium-based renderers don't react to UIA calls by enabling accessibility, so we need to send the WM_GETOBJECT message to the renderer control to enable accessibility. Thanks to users malcev and rommmcek for this tip. Explanation why this works: https://www.chromium.org/developers/design-documents/accessibility/#TOC-How-Chrome-detects-the-presence-of-Assistive-Technology 
	ActivateChromiumAccessibility(hwnd:="A", cacheRequest:=0, timeOut:=500) {
		static activatedHwnds := {}
		if hwnd is not integer
			hwnd := WinExist(hwnd)
		if activatedHwnds[hwnd] 
			return
		activatedHwnds[hwnd] := 1 ; Shouldn't store the element here, otherwise it can't be released until the program exits
		return this.ElementFromChromium("ahk_id " hwnd,, timeOut)
	}
}

class UIA_Interface2 extends UIA_Interface {
	static __IID := "{34723aff-0c9d-49d0-9896-7ab52df8cd8a}"
	
	; ---------- UIA_Interface2 properties ----------

	; Specifies whether calls to UI Automation control pattern methods automatically set focus to the target element. Default is True. 
	AutoSetFocus[] 
	{
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(58), "ptr",this.__Value, "ptr*", out:=""))?out:
		}
		set {
			return UIA_Hr(DllCall(this.__Vt(59), "ptr",this.__Value, "int", value))
		}
	}
	; Specifies the length of time that UI Automation will wait for a provider to respond to a client request for an automation element. Default is 20000ms (20 seconds), minimum seems to be 50ms.
	ConnectionTimeout[] 
	{
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(60), "ptr",this.__Value, "ptr*", out:=""))?out:
		}
		set {
			return UIA_Hr(DllCall(this.__Vt(61), "ptr",this.__Value, "int", value)) ; Minimum seems to be 50 (ms?)
		}
	}
	; Specifies the length of time that UI Automation will wait for a provider to respond to a client request for information about an automation element. Default is 2000ms (2 seconds), minimum seems to be 50ms.
	TransactionTimeout[] 
	{
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(62), "ptr",this.__Value, "ptr*", out:=""))?out:
		}
		set {
			return UIA_Hr(DllCall(this.__Vt(63), "ptr",this.__Value, "int", value))
		}
	}
}

class UIA_Interface3 extends UIA_Interface2 { ; UNTESTED
	static __IID := "{73d768da-9b51-4b89-936e-c209290973e7}"

	AddTextEditTextChangedEventHandler(element, scope, textEditChangeType, cacheRequest:=0, handler:="") {
		return UIA_Hr(DllCall(this.__Vt(64), "ptr",this.__Value, "ptr", element.__Value, "int", scope, "int", textEditChangeType, "ptr", cacheRequest.__Value, "ptr", handler.__Value))
	}
	RemoveTextEditTextChangedEventHandler(element, handler) {
		return UIA_Hr(DllCall(this.__Vt(65), "ptr",this.__Value, "ptr", element.__Value, "ptr", handler.__Value))
	}
}

class UIA_Interface4 extends UIA_Interface3 { ; UNTESTED
	static __IID := "{1189c02a-05f8-4319-8e21-e817e3db2860}"

	AddChangesEventHandler(element, scope, changeTypes, changesCount, cacheRequest:=0, handler:="") { ; NOT WORKING. changeTypes should be an array?
		return UIA_Hr(DllCall(this.__Vt(66), "ptr",this.__Value, "ptr", element.__Value, "int", scope, "int", changeTypes, "int", changesCount, "ptr", cacheRequest.__Value, "ptr", handler.__Value))
	}
	RemoveChangesEventHandler(element, handler) {
		return UIA_Hr(DllCall(this.__Vt(67), "ptr",this.__Value, "ptr", element.__Value, "ptr", handler.__Value))
	}
}
class UIA_Interface5 extends UIA_Interface4 { ; UNTESTED
	static __IID := "{25f700c8-d816-4057-a9dc-3cbdee77e256}"

	AddNotificationEventHandler(element, scope:=0x4, cacheRequest:=0, handler:=0) {
		return UIA_Hr(DllCall(this.__Vt(68), "ptr",this.__Value, "ptr", element.__Value, "uint", scope, "ptr", cacheRequest.__Value, "ptr", handler.__Value))
	}
	RemoveNotificationEventHandler(element, handler) {
		return UIA_Hr(DllCall(this.__Vt(69), "ptr",this.__Value, "ptr", element.__Value, "ptr", handler.__Value))
	}
}
class UIA_Interface6 extends UIA_Interface5 { ; UNTESTED
	static __IID := "{aae072da-29e3-413d-87a7-192dbf81ed10}"

	; ---------- UIA_Interface6 properties ----------

	; Indicates whether an accessible technology client adjusts provider request timeouts when the provider is non-responsive.
	ConnectionRecoveryBehavior[] 
	{
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(73), "ptr",this.__Value, "ptr*", out:=""))?out:
		}
		set {
			return UIA_Hr(DllCall(this.__Vt(74), "ptr",this.__Value, "int", value)) 
		}
	}
	; Gets or sets whether an accessible technology client receives all events, or a subset where duplicate events are detected and filtered.
	CoalesceEvents[] 
	{
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(75), "ptr",this.__Value, "ptr*", out:=""))?out:
		}
		set {
			return UIA_Hr(DllCall(this.__Vt(76), "ptr",this.__Value, "int", value))
		}
	}

	; ---------- UIA_Interface6 methods ----------

	; Registers one or more event listeners in a single method call.
	CreateEventHandlerGroup() {
		local out
		return UIA_Hr(DllCall(this.__Vt(70), "ptr",this.__Value, "ptr*", out:="")) ? new UIA_AutomationEventHandlerGroup(out):
	}
	; Registers a collection of event handler methods specified with the UIA_Interface6 CreateEventHandlerGroup.
	AddEventHandlerGroup(element, handlerGroup) {
		return UIA_Hr(DllCall(this.__Vt(71), "ptr",this.__Value, "ptr", element.__Value, "ptr", handlerGroup.__Value)) 
	}
	RemoveEventHandlerGroup(element, handlerGroup) {
		return UIA_Hr(DllCall(this.__Vt(72), "ptr",this.__Value, "ptr", element.__Value, "ptr", handlerGroup.__Value)) 
	}
	; Registers a method that handles when the active text position changes.
	AddActiveTextPositionChangedEventHandler(element,scope:=0x4,cacheRequest:=0,handler:="") {
		return UIA_Hr(DllCall(this.__Vt(77), "ptr",this.__Value, "ptr", element.__Value, "int", scope, "ptr", cacheRequest.__Value, "ptr", handler.__Value)) 
	}
	RemoveActiveTextPositionChangedEventHandler(element,handler) {
		return UIA_Hr(DllCall(this.__Vt(78), "ptr",this.__Value, "ptr", element.__Value, "ptr", handler.__Value)) 
	}
}
class UIA_Interface7 extends UIA_Interface6 {
	static __IID := "{29de312e-83c6-4309-8808-e8dfcb46c3c2}"
}

/*
	Exposes methods and properties for a UI Automation element, which represents a UI item.
	Microsoft documentation: https://docs.microsoft.com/en-us/windows/win32/api/uiautomationclient/nn-uiautomationclient-iuiautomationelement
*/
class UIA_Element extends UIA_Base {
	;~ http://msdn.microsoft.com/en-us/library/windows/desktop/ee671425(v=vs.85).aspx
	static __IID := "{d22108aa-8ac5-49a5-837b-37bbb3d7591e}"
	
	; ---------- UIA_Element properties ----------
	CurrentProcessId[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(20), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}
	CurrentControlType[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(21), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}
	CurrentLocalizedControlType[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(22), "ptr",this.__Value, "ptr*",out:=""))?UIA_GetBSTRValue(out):
		}
	}
	CurrentName[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(23), "ptr",this.__Value, "ptr*",out:=""))?UIA_GetBSTRValue(out):
		}
	}
	CurrentAcceleratorKey[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(24), "ptr",this.__Value, "ptr*",out:=""))?UIA_GetBSTRValue(out):
		}
	}
	CurrentAccessKey[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(25), "ptr",this.__Value, "ptr*",out:=""))?UIA_GetBSTRValue(out):
		}
	}
	CurrentHasKeyboardFocus[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(26), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}
	CurrentIsKeyboardFocusable[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(27), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}
	CurrentIsEnabled[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(28), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}
	CurrentAutomationId[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(29), "ptr",this.__Value, "ptr*",out:=""))?UIA_GetBSTRValue(out):
		}
	}
	CurrentClassName[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(30), "ptr",this.__Value, "ptr*",out:=""))?UIA_GetBSTRValue(out):
		}
	}
	CurrentHelpText[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(31), "ptr",this.__Value, "ptr*",out:=""))?UIA_GetBSTRValue(out):
		}
	}
	CurrentCulture[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(32), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}
	CurrentIsControlElement[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(33), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}
	CurrentIsContentElement[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(34), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}
	CurrentIsPassword[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(35), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}
	CurrentNativeWindowHandle[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(36), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}
	CurrentItemType[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(37), "ptr",this.__Value, "ptr*",out:=""))?UIA_GetBSTRValue(out):
		}
	}
	CurrentIsOffscreen[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(38), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}
	CurrentOrientation[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(39), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}
	CurrentFrameworkId[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(40), "ptr",this.__Value, "ptr*",out:=""))?UIA_GetBSTRValue(out):
		}
	}
	CurrentIsRequiredForForm[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(41), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}
	CurrentItemStatus[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(42), "ptr",this.__Value, "ptr*",out:=""))?UIA_GetBSTRValue(out):
		}
	}
	CurrentBoundingRectangle[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(43), "ptr",this.__Value, "ptr",&(rect,VarSetCapacity(rect,16))))?UIA_RectToObject(rect):
		}
	}
	CurrentLabeledBy[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(44), "ptr",this.__Value, "ptr*",out:=""))?UIA_Element(out):
		}
	}
	CurrentAriaRole[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(45), "ptr",this.__Value, "ptr*",out:=""))?UIA_GetBSTRValue(out):
		}
	}
	CurrentAriaProperties[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(46), "ptr",this.__Value, "ptr*",out:=""))?UIA_GetBSTRValue(out):
		}
	}
	CurrentIsDataValidForForm[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(47), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}
	CurrentControllerFor[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(48), "ptr",this.__Value, "ptr*",out:=""))?UIA_ElementArray(out):
		}
	}
	CurrentDescribedBy[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(49), "ptr",this.__Value, "ptr*",out:=""))?UIA_ElementArray(out):
		}
	}
	CurrentFlowsTo[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(50), "ptr",this.__Value, "ptr*",out:=""))?UIA_ElementArray(out):
		}
	}
	CurrentProviderDescription[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(51), "ptr",this.__Value, "ptr*",out:=""))?UIA_GetBSTRValue(out):
		}
	}
	CachedProcessId[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(52), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}
	CachedControlType[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(53), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}
	CachedLocalizedControlType[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(54), "ptr",this.__Value, "ptr*",out:=""))?UIA_GetBSTRValue(out):
		}
	}
	CachedName[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(55), "ptr",this.__Value, "ptr*",out:=""))?UIA_GetBSTRValue(out):
		}
	}
	CachedAcceleratorKey[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(56), "ptr",this.__Value, "ptr*",out:=""))?UIA_GetBSTRValue(out):
		}
	}
	CachedAccessKey[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(57), "ptr",this.__Value, "ptr*",out:=""))?UIA_GetBSTRValue(out):
		}
	}
	CachedHasKeyboardFocus[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(58), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}
	CachedIsKeyboardFocusable[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(59), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}
	CachedIsEnabled[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(60), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}
	CachedAutomationId[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(61), "ptr",this.__Value, "ptr*",out:=""))?UIA_GetBSTRValue(out):
		}
	}
	CachedClassName[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(62), "ptr",this.__Value, "ptr*",out:=""))?UIA_GetBSTRValue(out):
		}
	}
	CachedHelpText[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(63), "ptr",this.__Value, "ptr*",out:=""))?UIA_GetBSTRValue(out):
		}
	}
	CachedCulture[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(64), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}
	CachedIsControlElement[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(65), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}
	CachedIsContentElement[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(66), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}
	CachedIsPassword[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(67), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}
	CachedNativeWindowHandle[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(68), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}
	CachedItemType[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(69), "ptr",this.__Value, "ptr*",out:=""))?UIA_GetBSTRValue(out):
		}
	}
	CachedIsOffscreen[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(70), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}
	CachedOrientation[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(71), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}
	CachedFrameworkId[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(72), "ptr",this.__Value, "ptr*",out:=""))?UIA_GetBSTRValue(out):
		}
	}
	CachedIsRequiredForForm[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(73), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}
	CachedItemStatus[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(74), "ptr",this.__Value, "ptr*",out:=""))?UIA_GetBSTRValue(out):
		}
	}
	CachedBoundingRectangle[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(75), "ptr",this.__Value, "ptr",&(rect,VarSetCapacity(rect,16))))?UIA_RectToObject(rect):
		}
	}
	CachedLabeledBy[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(76), "ptr",this.__Value, "ptr*",out:=""))?UIA_Element(out):
		}
	}
	CachedAriaRole[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(77), "ptr",this.__Value, "ptr*",out:=""))?UIA_GetBSTRValue(out):
		}
	}
	CachedAriaProperties[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(78), "ptr",this.__Value, "ptr*",out:=""))?UIA_GetBSTRValue(out):
		}
	}
	CachedIsDataValidForForm[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(79), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}
	CachedControllerFor[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(80), "ptr",this.__Value, "ptr*",out:=""))?UIA_ElementArray(out):
		}
	}
	CachedDescribedBy[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(81), "ptr",this.__Value, "ptr*",out:=""))?UIA_ElementArray(out):
		}
	}
	CachedFlowsTo[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(82), "ptr",this.__Value, "ptr*",out:=""))?UIA_ElementArray(out):
		}
	}
	CachedProviderDescription[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(83), "ptr",this.__Value, "ptr*",out:=""))?UIA_GetBSTRValue(out):
		}
	}
	; ---------- Custom UIA_Element properties ----------

	; Gets or sets the current value of the element. Getter is a wrapper for GetCurrentPropertyValue("Value"), setter a wrapper for SetValue
	CurrentValue[] { 
		get {
			return this.GetCurrentPropertyValue("Value")
		}
		set {
			return this.SetValue(value)
		}
	}
	CachedValue[] { 
		get {
			return this.GetCachedPropertyValue("Value")
		}
	}
	CurrentExists[] {
		get {
			try {
				if ((this.CurrentName this.CurrentValue (this.CurrentBoundingRectangle.t ? 1 : "")) == "")
					return 0
			} 
			return 1
		}
	}

	; ---------- UIA_Element methods ----------

	SetFocus() {
		return UIA_Hr(DllCall(this.__Vt(3), "ptr",this.__Value))
	}
	; Retrieves the unique identifier assigned to the UI element. The identifier is only guaranteed to be unique to the UI of the desktop on which it was generated. Identifiers can be reused over time.
	GetRuntimeId() { 
		local
		return UIA_Hr(DllCall(this.__Vt(4), "ptr",this.__Value, "ptr*",sa:=""))? UIA_SafeArrayToAHKArray(ComObj(0x2003,sa,1)):
	}
	; Retrieves the first child or descendant element that matches the specified condition. scope must be one of TreeScope enums (default is TreeScope_Descendants := 0x4). If cacheRequest is specified, then FindFirstBuildCache is used instead.
	FindFirst(c:="", scope:=0x4, cacheRequest:="") { 
		local
		if !cacheRequest	
			return UIA_Hr(DllCall(this.__Vt(5), "ptr",this.__Value, "uint",scope, "ptr",(c=""?this.TrueCondition:(IsObject(c)?c:this.__UIA.CreateCondition(c))).__Value, "ptr*",out:=""))? UIA_Element(out):
		return this.FindFirstBuildCache(c, scope, cacheRequest)
	}
	; Returns all UI Automation elements that satisfy the specified condition. scope must be one of TreeScope enums (default is TreeScope_Descendants := 0x4). If cacheRequest is specified, then FindAllBuildCache is used instead.
	FindAll(c:="", scope:=0x4, cacheRequest:="") { 
		local
		if !cacheRequest
			return UIA_Hr(DllCall(this.__Vt(6), "ptr",this.__Value, "uint",scope, "ptr",(c=""?this.TrueCondition:(IsObject(c)?c:this.__UIA.CreateCondition(c))).__Value, "ptr*",out:=""))? UIA_ElementArray(out):
		return this.FindAllBuildCache(c, scope, cacheRequest)
	}
	; Retrieves the first child or descendant element that matches the specified condition, prefetches the requested properties and control patterns, and stores the prefetched items in the cache
	FindFirstBuildCache(c:="", scope:=0x4, cacheRequest:="") { ; UNTESTED. 
		local
		return UIA_Hr(DllCall(this.__Vt(7), "ptr",this.__Value, "uint",scope, "ptr",(c=""?this.TrueCondition:(IsObject(c)?c:this.__UIA.CreateCondition(c))).__Value, "ptr",cacheRequest.__Value, "ptr*",out:=""))? UIA_Element(out):
	}
	; Returns all UI Automation elements that satisfy the specified condition, prefetches the requested properties and control patterns, and stores the prefetched items in the cache.
	FindAllBuildCache(c:="", scope:=0x4, cacheRequest:="") { ; UNTESTED. 
		local
		return UIA_Hr(DllCall(this.__Vt(8), "ptr",this.__Value, "uint",scope, "ptr",(c=""?this.TrueCondition:(IsObject(c)?c:this.__UIA.CreateCondition(c))).__Value, "ptr",cacheRequest.__Value, "ptr*",out:=""))? UIA_ElementArray(out):
	}
	; Retrieves a new UI Automation element with an updated cache.
	BuildUpdatedCache(cacheRequest) { ; UNTESTED. 
		local
		return UIA_Hr(DllCall(this.__Vt(9), "ptr",this.__Value, "ptr", cacheRequest.__Value, "ptr*",out:=""))? UIA_Element(out):
	}
	; Retrieves the current value of a property for this element. "out" will be set to the raw variant (generally not used).
	GetCurrentPropertyValue(propertyId, ByRef out:="") { 
		if propertyId is not integer
			propertyId := UIA_Enum.UIA_PropertyId(propertyId)
		return UIA_Hr(DllCall(this.__Vt(10), "ptr",this.__Value, "uint", propertyId, "ptr",UIA_Variant(out)))? UIA_VariantData(out):
		
	}
	; Retrieves a property value for this element, optionally ignoring any default value. Passing FALSE in the ignoreDefaultValue parameter is equivalent to calling GetCurrentPropertyValue
	GetCurrentPropertyValueEx(propertyId, ignoreDefaultValue:=1, ByRef out:="") { 
		if propertyId is not integer
			propertyId := UIA_Enum.UIA_PropertyId(propertyId)
		return UIA_Hr(DllCall(this.__Vt(11), "ptr",this.__Value, "uint",propertyId, "uint",ignoreDefaultValue, "ptr",UIA_Variant(out)))? UIA_VariantData(out):
	}
	; Retrieves a property value from the cache for this element.
	GetCachedPropertyValue(propertyId, ByRef out:="") { ; UNTESTED. 
		if propertyId is not integer
			propertyId := UIA_Enum.UIA_PropertyId(propertyId)
		return UIA_Hr(DllCall(this.__Vt(12), "ptr",this.__Value, "uint",propertyId, "ptr",UIA_Variant(out)))? UIA_VariantData(out):
	}
	; Retrieves a property value from the cache for this element, optionally ignoring any default value. Passing FALSE in the ignoreDefaultValue parameter is equivalent to calling GetCachedPropertyValue
	GetCachedPropertyValueEx(propertyId, ignoreDefaultValue:=1, ByRef out:="") { 
		if propertyId is not integer
			propertyId := UIA_Enum.UIA_PropertyId(propertyId)
		return UIA_Hr(DllCall(this.__Vt(13), "ptr",this.__Value, "uint",propertyId, "uint",ignoreDefaultValue, "ptr",UIA_Variant(out)))? UIA_VariantData(out):
	}
	; Retrieves a UIA_Pattern object of the specified control pattern on this element. If a full pattern name is specified then that exact version will be used (eg "TextPattern" will return a UIA_TextPattern object), otherwise the highest version will be used (eg "Text" might return UIA_TextPattern2 if it is available). usedPattern will be set to the actual string used to look for the pattern (used mostly for debugging purposes)
	GetCurrentPatternAs(pattern, ByRef usedPattern:="") { 
		local riid, out
		if (usedPattern := InStr(pattern, "Pattern") ? pattern : UIA_Pattern(pattern, this))
			return UIA_Hr(DllCall(this.__Vt(14), "ptr",this.__Value, "int",UIA_%usedPattern%.__PatternId, "ptr",UIA_GUID(riid,UIA_%usedPattern%.__iid), "ptr*",out:="")) ? new UIA_%usedPattern%(out,1):
		throw Exception("Pattern not implemented.",-1, "UIA_" pattern "Pattern")
	}
	; Retrieves a UIA_Pattern object of the specified control pattern on this element from the cache of this element. 
	GetCachedPatternAs(pattern, ByRef usedPattern:="") { 
		local riid, out
		if (usedPattern := InStr(pattern, "Pattern") ? pattern : UIA_Pattern(pattern, this))
			return UIA_Hr(DllCall(this.__Vt(15), "ptr",this.__Value, "int",UIA_%usedPattern%.__PatternId, "ptr",UIA_GUID(riid,UIA_%usedPattern%.__iid), "ptr*",out:="")) ? new UIA_%usedPattern%(out,1):
		throw Exception("Pattern not implemented.",-1, "UIA_" pattern "Pattern")
	}
	GetCurrentPattern(pattern, ByRef usedPattern:="") {
		local out
		; I don't know the difference between this and GetCurrentPatternAs
		if (usedPattern := InStr(pattern, "Pattern") ? pattern : UIA_Pattern(pattern, this))
			return UIA_Hr(DllCall(this.__Vt(16), "ptr",this.__Value, "int",UIA_%usedPattern%.__PatternId, "ptr*",out:="")) ? new UIA_%usedPattern%(out,1):
		else throw Exception("Pattern not implemented.",-1, "UIA_" pattern "Pattern")
	}
	GetCachedPattern(pattern, ByRef usedPattern:="") {
		local out
		; I don't know the difference between this and GetCachedPatternAs
		if (usedPattern := InStr(pattern, "Pattern") ? pattern : UIA_Pattern(pattern, this))
			return UIA_Hr(DllCall(this.__Vt(17), "ptr",this.__Value, "int", UIA_%usedPattern%.__PatternId, "ptr*",out:="")) ? new UIA_%usedPattern%(out,1):
		else throw Exception("Pattern not implemented.",-1, "UIA_" pattern "Pattern")
	}
	; Retrieves from the cache the parent of this UI Automation element
	GetCachedParent() { 
		local
		return UIA_Hr(DllCall(this.__Vt(18), "ptr",this.__Value, "ptr*",out:=""))? UIA_Element(out):
	}
	; Retrieves the cached child elements of this UI Automation element
	GetCachedChildren() { ; UNTESTED. 
		local
		return UIA_Hr(DllCall(this.__Vt(19), "ptr",this.__Value, "ptr*",out:=""))? UIA_ElementArray(out):
	}
	; Retrieves the physical screen coordinates of a point on the element that can be clicked
	GetClickablePoint() { 
		local
		return UIA_Hr(DllCall(this.__Vt(84), "ptr",this.__Value, "ptr", &(point,VarSetCapacity(point,8)), "ptr*",out:=""))&&out? {x:NumGet(point,0,"int"), y:NumGet(point,4,"int")}:
	}
	
	; ---------- Custom UIA_Element methods ----------

	; Wait until the element doesn't exist, with a default timeOut of 10000ms (10 seconds). Returns 1 if the element doesn't exist, otherwise 0.
	WaitNotExist(timeOut:=10000) { 
		local
		startTime := A_TickCount
		while ((exists := this.CurrentExists) && ((timeOut < 1) ? 1 : (A_tickCount - startTime < timeOut)))
			Sleep, 100
		return !exists
	}
	; Wrapper for GetClickablePoint(), where additionally the coordinates are converted to relative coordinates. relativeTo can be window, screen or client, default is A_CoordModeMouse
	GetClickablePointRelativeTo(relativeTo:="") { 
		local
		res := this.GetClickablePoint()
		relativeTo := (relativeTo == "") ? A_CoordModeMouse : relativeTo
		StringLower, relativeTo, relativeTo
		if (relativeTo == "screen")
			return res
		else {
			hwnd := this.GetParentHwnd()
			if ((relativeTo == "window") || (relativeTo == "relative")) {
				VarSetCapacity(RECT, 16)
				DllCall("user32\GetWindowRect", "Ptr", hwnd, "Ptr", &RECT)
				return {x:(res.x-NumGet(&RECT, 0, "Int")), y:(res.y-NumGet(&RECT, 4, "Int"))}
			} else if (relativeTo == "client") {
				VarSetCapacity(pt,8,0), NumPut(res.x,&pt,0,"int"), NumPut(res.y,&pt,4,"int")
				DllCall("ScreenToClient", "Ptr",hwnd, "Ptr",&pt)
				return {x:NumGet(pt,"int"), y:NumGet(pt,4,"int")}
			}
		}
	}
	; Get all available patterns for the element. Use of this should be avoided, since it calls GetCurrentPatternAs for every possible pattern. A better option is PollForPotentialSupportedPatterns.
	GetSupportedPatterns() {
		local result := [], patterns := "Invoke,Selection,Value,RangeValue,Scroll,ExpandCollapse,Grid,GridItem,MultipleView,Window,SelectionItem,Dock,Table,TableItem,Text,Toggle,Transform,ScrollItem,ItemContainer,VirtualizedItem,SyncronizedInput,LegacyIAccessible"

		Loop, Parse, patterns, `,
		{
			try {
				if this.GetCurrentPropertyValue(UIA_Enum.UIA_PropertyId("Is" A_LoopField "PatternAvailable")) {
					result.Push(A_LoopField)
				}
			}
		}
		return result
	}
	; Get the parent window hwnd from the element
	GetParentHwnd() {
		local TW, hwndNotZeroCond, hwndRoot, hwnd
		hwndNotZeroCond := this.__UIA.CreateNotCondition(this.__UIA.CreatePropertyCondition(UIA_Enum.UIA_PropertyId("NativeWindowHandle"), 0)) ; create a condition to find NativeWindowHandlePropertyId of not 0
		TW := this.__UIA.CreateTreeWalker(hwndNotZeroCond)
		try {
			hwnd := TW.NormalizeElement(this).GetCurrentPropertyValue(UIA_Enum.UIA_PropertyId("NativeWindowHandle"))
			return hwndRoot := DllCall("user32\GetAncestor", Ptr,hwnd, UInt,2, Ptr)
		} catch {
			return 0
		}
	}
	; Set element value using Value pattern, or as a fall-back using LegacyIAccessible pattern. If a pattern is specified then that is used instead. Alternatively CurrentValue property can be used to set the value.
	SetValue(val, pattern:="") { 
		if !pattern {
			try {
				this.GetCurrentPatternAs("Value").SetValue(val)
			} catch {
				this.GetCurrentPatternAs("LegacyIAccessible").SetValue(val)
			}
		} else {
			this.GetCurrentPatternAs(pattern).SetValue(val)
		}
	}
	; Click using one of the available click-like methods (InvokePattern Invoke(), TogglePattern Toggle(), ExpandCollapsePattern Expand() or Collapse() (depending on the state of the element), SelectionItemPattern Select(), or LegacyIAccessible DoDefaultAction()), in which case ClickCount is ignored. If WhichButton is specified (for example "left", "right") then the native mouse Click function will be used to click the center of the element.
	; If WhichButton is a number, then Sleep will be called with that number. Eg Click(200) will sleep 200ms after clicking
	; If ClickCountAndSleepTime is a number >=10, then Sleep will be called with that number. To click 10+ times and sleep after, specify "ClickCount SleepTime". Ex: Click("left", 200) will sleep 200ms after clicking. Ex: Click("left", "20 200") will left-click 20 times and then sleep 200ms.
	; If Relative is "Rel" or "Relative" then X and Y coordinates are treated as offsets from the current mouse position. Otherwise it expects offset values for both X and Y (eg "-5 10" would offset X by -5 and Y by +10).
	Click(WhichButtonOrSleepTime:="", ClickCountAndSleepTime:=1, DownOrUp:="", Relative:="") {	
		local
		global UIA_Enum
		if ((WhichButtonOrSleepTime == "") or RegexMatch(WhichButtonOrSleepTime, "^\d+$")) {
			SleepTime := WhichButtonOrSleepTime ? WhichButtonOrSleepTime : -1
			if (this.GetCurrentPropertyValue(UIA_Enum.UIA_IsInvokePatternAvailablePropertyId)) {
				this.GetCurrentPatternAs("Invoke").Invoke()
				Sleep, %SleepTime%
				return 1
			}
			if (this.GetCurrentPropertyValue(UIA_Enum.UIA_IsTogglePatternAvailablePropertyId)) {
				togglePattern := this.GetCurrentPatternAs("Toggle"), toggleState := togglePattern.CurrentToggleState
				togglePattern.Toggle()
				if (togglePattern.CurrentToggleState != toggleState) {
					Sleep, %SleepTime%
					return 1
				}
			}
			if (this.GetCurrentPropertyValue(UIA_Enum.UIA_IsExpandCollapsePatternAvailablePropertyId)) {
				if ((expandState := (pattern := this.GetCurrentPatternAs("ExpandCollapse")).CurrentExpandCollapseState) == 0)
					pattern.Expand()
				Else
					pattern.Collapse()
				if (pattern.CurrentExpandCollapseState != expandState) {
					Sleep, %SleepTime%
					return 1
				}
			} 
			if (this.GetCurrentPropertyValue(UIA_Enum.UIA_IsSelectionItemPatternAvailablePropertyId)) {
				selectionPattern := this.GetCurrentPatternAs("SelectionItem"), selectionState := selectionPattern.CurrentIsSelected
				selectionPattern.Select()
				if (selectionPattern.CurrentIsSelected != selectionState) {
					Sleep, %sleepTime%
					return 1
				}
			}
			if (this.GetCurrentPropertyValue(UIA_Enum.UIA_IsLegacyIAccessiblePatternAvailablePropertyId)) {
				this.GetCurrentPatternAs("LegacyIAccessible").DoDefaultAction()
				Sleep, %sleepTime%
				return 1
			}
			return 0
		} else {
			rel := [0,0]
			if (Relative && !InStr(Relative, "rel"))
				rel := StrSplit(Relative, " "), Relative := ""
			ClickCount := 1, SleepTime := -1
			if (ClickCountAndSleepTime := StrSplit(ClickCountAndSleepTime, " "))[2] {
				ClickCount := ClickCountAndSleepTime[1], SleepTime := ClickCountAndSleepTime[2]
			} else if ClickCountAndSleepTime[1] {
				if (ClickCountAndSleepTime[1] > 9) {
					SleepTime := ClickCountAndSleepTime[1]
				} else {
					ClickCount := ClickCountAndSleepTime[1]
				}
			}
			try pos := this.GetClickablePointRelativeTo()
			if !(pos.x || pos.y) {
				pos := this.GetCurrentPos() ; or should only GetClickablePoint be used instead?
				Click, % (pos.x+pos.w//2+rel[1]) " " (pos.y+pos.h//2+rel[2]) " " WhichButtonOrSleepTime (ClickCount ? " " ClickCount : "") (DownOrUp ? " " DownOrUp : "") (Relative ? " " Relative : "")
			} else {
				Click, % (pos.x+rel[1]) " " (pos.y+rel[2]) " " WhichButtonOrSleepTime (ClickCount ? " " ClickCount : "") (DownOrUp ? " " DownOrUp : "") (Relative ? " " Relative : "")
			}
			Sleep, %SleepTime%
		}
	}
	; ControlClicks the element after getting relative coordinates with GetClickablePointRelativeTo("window"). Specifying WinTitle makes the function faster, since it bypasses getting the Hwnd from the element. 
	; If WinTitle or WinText is a number, then Sleep will be called with that number of milliseconds. Ex: ControlClick(200) will sleep 200ms after clicking. Same for ControlClick("ahk_id 12345", 200)
	ControlClick(WinTitleOrSleepTime:="", WinTextOrSleepTime:="", WhichButton:="", ClickCount:="", Options:="", ExcludeTitle:="", ExcludeText:="") { 
		local
		try this.SetFocus()
		if (WinTitleOrSleepTime == "")
			WinTitleOrSleepTime := "ahk_id " this.GetParentHwnd()
		try pos := this.GetClickablePointRelativeTo("window")
		if !(pos.x || pos.y) {
			pos := this.GetCurrentPos("window") ; or should GetClickablePoint be used instead?
			ControlClick, % "X" pos.x+pos.w//2 " Y" pos.y+pos.h//2, % WinTitleOrSleepTime, % WinTextOrSleepTime, % WhichButton, % ClickCount, % Options, % ExcludeTitle, % ExcludeText
		} else {
			ControlClick, % "X" pos.x " Y" pos.y, % WinTitleOrSleepTime, % WinTextOrSleepTime, % WhichButton, % ClickCount, % Options, % ExcludeTitle, % ExcludeText
		}
		if WinTitleOrSleepTime is integer
			Sleep, %WinTitleOrSleepTime%
		else if WinTextOrSleepTime is integer
			Sleep, %WinTextOrSleepTime%
	}
	; Returns an object containing the x, y coordinates and width and height: {x:x coordinate, y:y coordinate, w:width, h:height}. relativeTo can be client, window or screen, default is A_CoordModeMouse.
	GetCurrentPos(relativeTo:="") { 
		local
		relativeTo := (relativeTo == "") ? A_CoordModeMouse : relativeTo
		StringLower, relativeTo, relativeTo
		br := this.CurrentBoundingRectangle
		if (relativeTo == "screen")
			return {x:br.l, y:br.t, w:(br.r-br.l), h:(br.b-br.t)}
		else {
			hwnd := this.GetParentHwnd()
			if ((relativeTo == "window") || (relativeTo == "relative")) {
				VarSetCapacity(RECT, 16)
				DllCall("user32\GetWindowRect", "Ptr", hwnd, "Ptr", &RECT)
				return {x:(br.l-NumGet(&RECT, 0, "Int")), y:(br.t-NumGet(&RECT, 4, "Int")), w:(br.r-br.l), h:(br.b-br.t)}
			} else if (relativeTo == "client") {
				VarSetCapacity(pt,8,0), NumPut(br.l,&pt,0,"int"), NumPut(br.t,&pt,4,"int")
				DllCall("ScreenToClient", "Ptr",hwnd, "Ptr",&pt)
				return {x:NumGet(pt,"int"), y:NumGet(pt,4,"int"), w:(br.r-br.l), h:(br.b-br.t)}
			}
		}			
	}
	; By default get only direct children (UIA_TreeScope_Children := 0x2)
	GetChildren(scope:=0x2, c:="") { 
		return this.FindAll(c=="" ? this.TrueCondition : c, scope)
	}
	; Get all child elements using TreeViewer
	TWGetChildren() { 
		local
		arr := []
		if !IsObject(nextChild := this.TreeWalkerTrue.GetFirstChildElement(this))
			return 0
		arr.Push(nextChild)
		while IsObject(nextChild := this.TreeWalkerTrue.GetNextSiblingElement(nextChild))
			arr.Push(nextChild)
		return arr
	}
	DumpRecursive(maxDepth:=20, layer:="", useTreeWalker := False, cached := False) { ; This function might hang if the element has thousands of empty custom elements (e.g. complex webpage)
		local
		StrReplace(layer, ".",, dotcount)
		if (dotcount >= maxDepth)
			return ""
		if !(children := (cached ? this.GetCachedChildren() : (useTreeWalker ? this.TWGetChildren() : this.GetChildren())))
			return ""
		returnStr := ""
		for k, v in children {
			returnStr .= layer . (layer == "" ? "" : ".") . k " " (cached ? v.CachedDump() : v.Dump()) . "`n" . v.DumpRecursive(maxDepth, layer (layer == "" ? "" : ".") k, useTreeWalker, cached)
		}
		return returnStr
	}
	; Returns info about the element: ControlType, Name, Value, LocalizedControlType, AutomationId, AcceleratorKey. 
	Dump() { 
		local
		global UIA_Enum
		return "Type: " (ctrlType := this.CurrentControlType) " (" UIA_Enum.UIA_ControlTypeId(ctrlType) ")" ((name := this.CurrentName) == "" ? "" : " Name: """ name """") ((val := this.CurrentValue) == "" ? "" : " Value: """ val """") ((lct := this.CurrentLocalizedControlType) == "" ? "" : " LocalizedControlType: """ lct """") ((aid := this.CurrentAutomationId) == "" ? "" : " AutomationId: """ aid """") ((cm := this.CurrentClassName) == "" ? "" : " ClassName: """ cm """") ((ak := this.CurrentAcceleratorKey) == "" ? "" : " AcceleratorKey: """ ak """")
	}
	CachedDump() { 
		local
		global UIA_Enum
		return "Type: " (ctrlType := this.CachedControlType) " (" UIA_Enum.UIA_ControlTypeId(ctrlType) ")" ((name := this.CachedName) == "" ? "" : " Name: """ name """") ((val := this.CachedValue) == "" ? "" : " Value: """ val """") ((lct := this.CachedLocalizedControlType) == "" ? "" : " LocalizedControlType: """ lct """") ((aid := this.CachedAutomationId) == "" ? "" : " AutomationId: """ aid """") ((cm := this.CachedClassName) == "" ? "" : " ClassName: """ cm """") ((ak := this.CachedAcceleratorKey) == "" ? "" : " AcceleratorKey: """ ak """")
	}
	; Returns info (ControlType, Name etc) for all descendants of the element. maxDepth is the allowed depth of recursion, by default 20 layers. DO NOT call this on the root element!
	DumpAll(maxDepth:=20) { 
		return (this.Dump() .  "`n" . this.DumpRecursive(maxDepth))
	}
	; Requires caching for properties ControlType, LocalizedControlType, Name, Value, AutomationId, AcceleratorKey
	CachedDumpAll(maxDepth:=20) { 
		return (this.CachedDump() .  "`n" . this.DumpRecursive(maxDepth,,,True))
	}
	/*
		FindFirst using search criteria. 
		expr: 
			Takes a value in the form of "PropertyId=matchvalue" to match a specific property with the value matchValue. PropertyId can be most properties from UIA_Enum.UIA_PropertyId method (for example Name, ControlType, AutomationId etc). 
			
			Example1: "Name=Username:" would use FindFirst with UIA_Enum.UIA_NamePropertyId matching the name "Username:"
			Example2: "ControlType=Button would FindFirst using UIA_Enum.UIA_ControlTypePropertyId and matching for UIA_Enum.UIA_ButtonControlTypeId. Alternatively "ControlType=50000" can be used (direct value for UIA_ButtonControlTypeId which is 50000)
			
			Criteria can be combined with AND, OR, &&, ||:
			Example3: "Name=Username: AND ControlType=Button" would FindFirst an element with the name property of "Username:" and control type of button.

			Flags can be modified for each individual condition by specifying FLAGS=n after the condition (and before and/or operator). 0=no flags; 1=ignore case (case insensitive matching); 2=match substring; 3=ignore case and match substring

			If matchMode==3 or matching substrings is supported (Windows 10 17763 and above) and matchMode==2, then parentheses are supported. 
			Otherwise parenthesis are not supported, and criteria are evaluated left to right, so "a AND b OR c" would be evaluated as "(a and b) or c".
			
			Negation can be specified with NOT:
			Example4: "NOT ControlType=Edit" would return the first element that is not an edit element
		
		scope:
			Scope by default is UIA_TreeScope_Descendants. 
			
		matchMode:
			If using Name PropertyId as a criteria, this follows the SetTitleMatchMode scheme: 
				1=name must must start with the specified name
				2=can contain anywhere
				3=exact match
				RegEx=using regular expression. In this case the Name can't be empty.
		
		caseSensitive:
			If matching for a string, this will specify case-sensitivity.

	*/
	FindFirstBy(expr, scope:=0x4, matchMode:=3, caseSensitive:=True, cacheRequest:="") { 
		local
		global UIA_Enum
		static MatchSubstringSupported := !InStr(A_OSVersion, "WIN") && (StrSplit(A_OSVersion, ".")[3] >= 17763)
		if ((matchMode == 3) || (matchMode==2 && MatchSubstringSupported)) {
			return this.FindFirst(this.__UIA.CreateCondition(expr, ((matchMode==2)?2:0)|!caseSensitive), scope, cacheRequest)
		}
		pos := 1, match := "", createCondition := "", operator := "", bufName := []
		while (pos := RegexMatch(expr, "i) *(NOT|!)? *(\w+?) *=(?: *(\d+|'.*?(?<=[^\\]|[^\\]\\\\)')|(.*?))(?: FLAGS=(\d))?( AND | OR | && | \|\| |$)", match, pos+StrLen(match))) {
			if !match
				break
			if ((StrLen(match3) > 1) && (SubStr(match3,1,1) == "'") && (SubStr(match3,0,1) == "'"))
				match3 := StrReplace(RegexReplace(SubStr(match3,2,StrLen(match3)-2), "(?<=[^\\]|[^\\]\\\\)\\'", "'"), "\\", "\") ; Remove single quotes and escape characters
			else if match4
				match3 := match4
			if ((isNamedProperty := RegexMatch(match2, "i)Name|AutomationId|Value|ClassName|FrameworkId")) && !bufName[1] && ((matchMode != 2) || ((matchMode == 2) && !MatchSubstringSupported)) && (matchMode != 3)) { ; Check if we have a condition that needs FindAll to be searched, and save it. Apply only for the first one encountered.
				bufName[1] := (match1 ? "NOT " : "") match2, bufName[2] := match3, bufName[3] := match5
				Continue
			}
			newCondition := this.__UIA.CreateCondition(match2, match3, match5 ? match5 : ((((matchMode==2) && isNamedProperty)?2:0)|!caseSensitive))
			if match1
				newCondition := this.__UIA.CreateNotCondition(newCondition)
			fullCondition := (operator == " AND " || operator == " && ") ? this.__UIA.CreateAndCondition(fullCondition, newCondition) : (operator == " OR " || operator == " || ") ? this.__UIA.CreateOrCondition(fullCondition, newCondition) : newCondition
			operator := match6 ; Save the operator to be used in the next loop
		}
		if (bufName[1]) { ; If a special case was encountered requiring FindAll
			notProp := InStr(bufName[1], "NOT "), property := StrReplace(StrReplace(bufName[1], "NOT "), "Current"), value := bufName[2], caseSensitive := bufName[3] ? !(bufName[3]&1) : caseSensitive 
			if (property = "value")
				property := "ValueValue"
			if (MatchSubstringSupported && (matchMode==1)) { ; Check if we can speed up the search by limiting to substrings when matchMode==1
				propertyCondition := this.__UIA.CreatePropertyConditionEx(UIA_Enum["UIA_" property "PropertyId"], value,, 2|!caseSensitive)
				if notProp
					propertyCondition := this.__UIA.CreateNotCondition(propertyCondition)
			} else 
				propertyCondition := this.__UIA.CreateNotCondition(this.__UIA.CreatePropertyCondition(UIA_Enum["UIA_" property "PropertyId"], ""))
			fullCondition := IsObject(fullCondition) ? this.__UIA.CreateAndCondition(propertyCondition, fullCondition) : propertyCondition
			for _, element in this.FindAll(fullCondition, scope, cacheRequest) {
				curValue := element["Current" property]
				if notProp {
					if (((matchMode == 1) && !InStr(SubStr(curValue, 1, StrLen(value)), value, caseSensitive)) || ((matchMode == 2) && !InStr(curValue, value, caseSensitive)) || (InStr(matchMode, "RegEx") && !RegExMatch(curValue, value)))
						return element
				} else {
					if (((matchMode == 1) && InStr(SubStr(curValue, 1, StrLen(value)), value, caseSensitive)) || ((matchMode == 2) && InStr(curValue, value, caseSensitive)) || (InStr(matchMode, "RegEx") && RegExMatch(curValue, value)))
						return element
				}
			}
		} else {
			return this.FindFirst(fullCondition, scope, cacheRequest)
		}
	}
	; FindFirst using UIA_NamePropertyId. "scope" is search scope, which can be any of UIA_Enum TreeScope values. "MatchMode" has same convention as window TitleMatchMode: 1=needs to start with the specified name, 2=can contain anywhere, 3=exact match, RegEx=regex match. 
	FindFirstByName(name, scope:=0x4, matchMode:=3, caseSensitive:=True, cacheRequest:="") {
		local
		global UIA_Enum
		static MatchSubstringSupported := !InStr(A_OSVersion, "WIN") && (StrSplit(A_OSVersion, ".")[3] >= 17763)
		if (matchMode == 3 || (MatchSubstringSupported && (matchMode == 2))) {
			nameCondition := this.__UIA.CreatePropertyConditionEx(UIA_Enum.UIA_NamePropertyId, name,, ((matchMode==3)?0:2)|!caseSensitive)
			return this.FindFirst(nameCondition, scope, cacheRequest)
		}
		nameCondition := ((matchMode==1)&&MatchSubstringSupported)?this.__UIA.CreatePropertyConditionEx(UIA_Enum.UIA_NamePropertyId, name,, 2|!caseSensitive):this.__UIA.CreateNotCondition(this.__UIA.CreatePropertyCondition(UIA_Enum.UIA_NamePropertyId, ""))
		for k, v in this.FindAll(nameCondition, scope, cacheRequest) {
			curName := v.CurrentName
			if (((matchMode == 1) && InStr(SubStr(curName, 1, StrLen(name)), name, caseSensitive))|| ((matchMode == 2) && InStr(curName, name, caseSensitive)) || ((matchMode = "RegEx") && RegExMatch(curName, name)))
				return v		
		}
	}
	; FindFirst using UIA_ControlTypeId. controlType can be the ControlTypeId numeric value, or in string form (eg "Button")
	FindFirstByType(controlType, scope:=0x4, cacheRequest:="") {
		local
		global UIA_Enum
		if controlType is not integer
			controlType := UIA_Enum.UIA_ControlTypeId(controlType)
		if !controlType
			throw Exception("Invalid control type specified", -1)
		controlCondition := this.__UIA.CreatePropertyCondition(UIA_Enum.UIA_ControlTypePropertyId, controlType)
		return this.FindFirst(controlCondition, scope, cacheRequest)
	}
	; FindFirst using UIA_NamePropertyId and UIA_ControlTypeId. controlType can be the ControlTypeId numeric value, or in string form (eg "Button"). scope is search scope, which can be any of UIA_Enum TreeScope values. matchMode has same convention as window TitleMatchMode: 1=needs to start with the specified name, 2=can contain anywhere, 3=exact match, RegEx=regex match
	FindFirstByNameAndType(name, controlType, scope:=0x4, matchMode:=3, caseSensitive:=True, cacheRequest:="") { 
		local
		global UIA_Enum
		static MatchSubstringSupported := !InStr(A_OSVersion, "WIN") && (StrSplit(A_OSVersion, ".")[3] >= 17763)
		if controlType is not integer
			controlType := UIA_Enum.UIA_ControlTypeId(controlType)
		if !controlType
			throw Exception("Invalid control type specified", -1)
		controlCondition := this.__UIA.CreatePropertyCondition(UIA_Enum.UIA_ControlTypePropertyId, controlType, 3)
		if (matchMode == 3 || (MatchSubstringSupported && (matchMode == 2))) {
			nameCondition := this.__UIA.CreatePropertyConditionEx(UIA_Enum.UIA_NamePropertyId, name,, ((matchMode==3)?0:2)|!caseSensitive)
			AndCondition := this.__UIA.CreateAndCondition(nameCondition, controlCondition)
			return this.FindFirst(AndCondition, scope, cacheRequest)
		}
		nameCondition := ((matchMode==1) && MatchSubstringSupported)?this.__UIA.CreatePropertyConditionEx(UIA_Enum.UIA_NamePropertyId, name,, 2|(!caseSensitive)):this.__UIA.CreateNotCondition(this.__UIA.CreatePropertyCondition(UIA_Enum.UIA_NamePropertyId, ""))
		AndCondition := this.__UIA.CreateAndCondition(nameCondition, controlCondition)
		for k, v in this.FindAll(AndCondition, scope, cacheRequest) {
			curName := v.CurrentName
			if (((matchMode == 1) && InStr(SubStr(curName, 1, StrLen(name)), name, caseSensitive)) || ((matchMode == 2) && InStr(curName, name, caseSensitive)) || ((matchMode = "RegEx") && RegExMatch(curName, name)))
				return v		
		}
	}
	; FindAll using an expression containing the desired conditions. For more information about expr, see FindFirstBy explanation
	FindAllBy(expr, scope:=0x4, matchMode:=3, caseSensitive:=True, cacheRequest:="") {
		local
		global UIA_Enum
		static MatchSubstringSupported := !InStr(A_OSVersion, "WIN") && (StrSplit(A_OSVersion, ".")[3] >= 17763)
		if ((matchMode == 3) || (matchMode==2 && MatchSubstringSupported)) 
			return this.FindAll(this.__UIA.CreateCondition(expr, ((matchMode==2)?2:0)|!caseSensitive), scope, cacheRequest)
		pos := 1, match := "", createCondition := "", operator := "", bufName := []
		while (pos := RegexMatch(expr, "i) *(NOT|!)? *(\w+?) *=(?: *(\d+|'.*?(?<=[^\\]|[^\\]\\\\)')|(.*?))(?: FLAGS=(\d))?( AND | OR | && | \|\| |$)", match, pos+StrLen(match))) {
			if !match
				break
			if ((StrLen(match3) > 1) && (SubStr(match3,1,1) == "'") && (SubStr(match3,0,1) == "'"))
				match3 := StrReplace(RegexReplace(SubStr(match3,2,StrLen(match3)-2), "(?<=[^\\]|[^\\]\\\\)\\'", "'"), "\\", "\") ; Remove single quotes and escape characters
			else if match4
				match3 := match4
			if ((isNamedProperty := RegexMatch(match2, "i)Name|AutomationId|Value|ClassName|FrameworkId")) && !bufName[1] && ((matchMode != 2) || ((matchMode == 2) && !MatchSubstringSupported)) && (matchMode != 3)) { ; Check if we have a condition that needs FindAll to be searched, and save it. Apply only for the first one encountered.
				bufName[1] := (match1 ? "NOT " : "") match2, bufName[2] := match3, bufName[3] := match5
				Continue
			}
			newCondition := this.__UIA.CreateCondition(match2, match3, match5 ? match5 : ((((matchMode==2) && isNamedProperty)?2:0)|!caseSensitive))
			if match1
				newCondition := this.__UIA.CreateNotCondition(newCondition)
			fullCondition := (operator == " AND " || operator == " && ") ? this.__UIA.CreateAndCondition(fullCondition, newCondition) : (operator == " OR " || operator == " || ") ? this.__UIA.CreateOrCondition(fullCondition, newCondition) : newCondition
			operator := match6 ; Save the operator to be used in the next loop
		}
		if (bufName[1]) { ; If a special case was encountered requiring FindAll
			notProp := InStr(bufName[1], "NOT "), property := StrReplace(StrReplace(bufName[1], "NOT "), "Current"), value := bufName[2], returnArr := [], caseSensitive := bufName[3] ? !(bufName[3]&1) : caseSensitive
			if (property = "value")
				property := "ValueValue"
			if (MatchSubstringSupported && (matchMode==1)) { ; Check if we can speed up the search by limiting to substrings when matchMode==1
				propertyCondition := this.__UIA.CreatePropertyConditionEx(UIA_Enum["UIA_" property "PropertyId"], value,, 2|!caseSensitive)
				if notProp
					propertyCondition := this.__UIA.CreateNotCondition(propertyCondition)
			} else 
				propertyCondition := this.__UIA.CreateNotCondition(this.__UIA.CreatePropertyCondition(UIA_Enum["UIA_" property "PropertyId"], ""))
			fullCondition := IsObject(fullCondition) ? this.__UIA.CreateAndCondition(propertyCondition, fullCondition) : propertyCondition
			for _, element in this.FindAll(fullCondition, scope, cacheRequest) {
				curValue := element["Current" property]
				if notProp {
					if (((matchMode == 1) && !InStr(SubStr(curValue, 1, StrLen(value)), value, caseSensitive)) || ((matchMode == 2) && !InStr(curValue, value, caseSensitive)) || (InStr(matchMode, "RegEx") && !RegExMatch(curValue, value)))
						returnArr.Push(element)
				} else {
					if (((matchMode == 1) && InStr(SubStr(curValue, 1, StrLen(value)), value, caseSensitive)) || ((matchMode == 2) && InStr(curValue, value, caseSensitive)) || (InStr(matchMode, "RegEx") && RegExMatch(curValue, value)))
						returnArr.Push(element)
				}
			}
			return returnArr[1] ? returnArr : ""
		} else {
			return this.FindAll(fullCondition, scope, cacheRequest)
		}
	}
	; FindAll using UIA_NamePropertyId. scope is search scope, which can be any of UIA_Enum TreeScope values. matchMode has same convention as window TitleMatchMode: 1=needs to start with the specified name, 2=can contain anywhere, 3=exact match, RegEx=regex match
	FindAllByName(name, scope:=0x4, matchMode:=3, caseSensitive:=True, cacheRequest:="") { 
		local
		global UIA_Enum
		static MatchSubstringSupported := !InStr(A_OSVersion, "WIN") && (StrSplit(A_OSVersion, ".")[3] >= 17763)
		if (matchMode == 3 || ((matchMode == 2) && MatchSubstringSupported)) {
			nameCondition := this.__UIA.CreatePropertyConditionEx(UIA_Enum.UIA_NamePropertyId, name,, ((matchMode==3)?0:2)|!caseSensitive)
			return this.FindAll(nameCondition, scope, cacheRequest)
		}
		nameCondition := ((matchMode==1) && MatchSubstringSupported)?this.__UIA.CreatePropertyConditionEx(UIA_Enum.UIA_NamePropertyId, name,, 2|!caseSensitive):this.__UIA.CreateNotCondition(this.__UIA.CreatePropertyCondition(UIA_Enum.UIA_NamePropertyId, ""))
		retList := []
		for k, v in this.FindAll(nameCondition, scope, cacheRequest) {
			curName := v.CurrentName
			if (((matchMode == 1) && InStr(SubStr(curName, 1, StrLen(name)), name, caseSensitive)) || ((matchMode == 2) && InStr(curName, name, caseSensitive)) || ((matchMode = "RegEx") && RegExMatch(curName, name)))
				retList.Push(v)		
		}
		return retList
	}
	; FindAll using UIA_ControlTypeId. controlType can be the ControlTypeId numeric value, or in string form (eg "Button"). scope is search scope, which can be any of UIA_Enum TreeScope values.
	FindAllByType(controlType, scope:=0x4, cacheRequest:="") {
		local
		global UIA_Enum
		if controlType is not integer
			controlType := UIA_Enum.UIA_ControlTypeId(controlType)
		if !controlType
			throw Exception("Invalid control type specified", -1)
		controlCondition := this.__UIA.CreatePropertyCondition(UIA_Enum.UIA_ControlTypePropertyId, controlType)
		return this.FindAll(controlCondition, scope, cacheRequest)
	}
	; FindAll using UIA_NamePropertyId and UIA_ControlTypeId. controlType can be the ControlTypeId numeric value, or in string form (eg "Button"). scope is search scope, which can be any of UIA_Enum TreeScope values. matchMode has same convention as window TitleMatchMode: 1=needs to start with the specified name, 2=can contain anywhere, 3=exact match, RegEx=regex match
	FindAllByNameAndType(name, controlType, scope:=0x4, matchMode:=3, caseSensitive:=True, cacheRequest:="") { 
		local
		global UIA_Enum
		static MatchSubstringSupported := !InStr(A_OSVersion, "WIN") && (StrSplit(A_OSVersion, ".")[3] >= 17763)
		if controlType is not integer
			controlType := UIA_Enum.UIA_ControlTypeId(controlType)
		if !controlType
			throw Exception("Invalid control type specified", -1)
		controlCondition := this.__UIA.CreatePropertyCondition(UIA_Enum.UIA_ControlTypePropertyId, controlType)
		if (matchMode == 3 || (MatchSubstringSupported && (matchMode == 2))) {
			nameCondition := this.__UIA.CreatePropertyConditionEx(UIA_Enum.UIA_NamePropertyId, name,, ((matchMode==3)?0:2)|!caseSensitive)
			AndCondition := this.__UIA.CreateAndCondition(nameCondition, controlCondition)
			return this.FindAll(AndCondition, scope, cacheRequest)
		}
		nameCondition := ((matchMode==1) && MatchSubstringSupported)?this.__UIA.CreatePropertyConditionEx(UIA_Enum.UIA_NamePropertyId, name,, 2|!caseSensitive):this.__UIA.CreateNotCondition(this.__UIA.CreatePropertyCondition(UIA_Enum.UIA_NamePropertyId, ""))
		AndCondition := this.__UIA.CreateAndCondition(nameCondition, controlCondition)
		returnArr := []
		for k, v in this.FindAll(AndCondition, scope, cacheRequest) {
			curName := v.CurrentName
			if (((matchMode == 1) && InStr(SubStr(curName, 1, StrLen(name)), name, caseSensitive)) || ((matchMode == 2) && InStr(curName, name, caseSensitive)) || ((matchMode = "RegEx") && RegExMatch(curName, name)))
				returnArr.Push(v)	
		}
		return returnArr
	}
	/*
		FindByPath gets an element by a relative "path" from a starting element. 
		1) To get the nth child of the starting element, set searchPath to "n". To get a deeper node, separate the numbers with a ".": "2.1" will get the second childs first child. This kind of path can easily be got from the UIA_Element.DumpAll() method, which returns a path in the same style (this is like the Acc path but for UIA, they are not compatible!).
		2) To get the nth parent of the starting element, use "Pn": "P2" will get the parent of the parent.
		3) To get sibling elements, put a "+" or "-" in front of "n": +2 will get the next sibling from the next sibling (calling GetNextSiblingElement twice). Using this after "Pn" doesn't require a "." separator ("P2.-1" == "P2-1").

		These conditions can also be combined:
		searchPath="P1-1.1.1.2" -> gets the parent element, then the previous sibling element of the parent, and then "1.1.2" gets the second child of the first childs first child. 

		c or condition argument can be used to only filter elements specified by the condition: 
		UIA_Element.FindByPath("+2", "Type=Button") will only consider "Button" controls and gets the second sibling button.
	*/
	FindByPath(searchPath:="", c:="") {
		local
		el := this, ErrorLevel := 0, PathTW := (c=="" ? this.TreeWalkerTrue : this.__UIA.CreateTreeWalker(c))
		searchPath := StrReplace(StrReplace(searchPath, " "), ",", ".")
		Loop, Parse, searchPath, .
		{
			if RegexMatch(A_LoopField, "^\d+$") {
				children := el.GetChildren(0x2,c)
				if !IsObject(el := children[A_LoopField])
					return ErrorLevel := "Step " A_index " was out of bounds"
			} else {
				if RegexMatch(A_LoopField, "i)p(\d+)?", m) {
					if !m1
						m1 := 1
					Loop, %m1% {
						if !(el := PathTW.GetParentElement(el))
							return ErrorLevel := "Step " A_index " with P" m1 " was out of bounds (GetParentElement failed)"
					}
				}
				if RegexMatch(A_LoopField, "([+-])(\d+)?", m) {
					if !m2
						m2 := 1
					if (m1 == "+") {
						Loop, %m2% {
							if !(el := PathTW.GetNextSiblingElement(el))
								return ErrorLevel := "Step " A_index " with """ m1 m2 """ was out of bounds (GetNextSiblingElement failed)"
						}
					} else if (m1 == "-") {
						Loop, %m2% {
							if !(el := PathTW.GetPreviousSiblingElement(el))
								return ErrorLevel := "Step " A_index " with """ m1 m2 """ was out of bounds (GetPreviousSiblingElement failed)"
						}
					}
				}
			}
		}
		return el
	}
	; Calls UIA_Element.FindByPath until the element is found and then returns it. By default waits indefinitely, timeOut can be specified in milliseconds. 
	WaitElementExistByPath(searchPath, c:="", timeOut:=-1) { 
		local
		startTime := A_TickCount
		while (!IsObject(el := this.FindByPath(searchPath, c)) && ((timeOut < 1) ? 1 : (A_tickCount - startTime < timeOut)))
			Sleep, 40
		return el
	}
	; Calls UIA_Element.FindFirstBy until the element is found and then returns it. By default waits indefinitely, timeOut can be specified in milliseconds. For explanations of the other arguments, see FindFirstBy
	WaitElementExist(expr, scope:=0x4, matchMode:=3, caseSensitive:=True, timeOut:=-1, cacheRequest:="") { 
		local
		startTime := A_TickCount
		while (!IsObject(el := this.FindFirstBy(expr, scope, matchMode, caseSensitive, cacheRequest)) && ((timeOut < 1) ? 1 : (A_tickCount - startTime < timeOut)))
			Sleep, 40
		return el
	}
	; Tries to FindFirstBy the element and if it is found then waits until the element doesn't exist (using WaitNotExist()), with a timeOut of 10000ms (10 seconds). For explanations of the other arguments, see FindFirstBy
	WaitElementNotExist(expr, scope:=0x4, matchMode:=3, caseSensitive:=True, timeOut:=-1) { 
		local
		return !IsObject(el := this.FindFirstBy(expr, scope, matchMode, caseSensitive)) || el.WaitNotExist(timeOut)
	}
	; Calls UIA_Element.FindFirstByName until the element is found and then returns it. By default waits indefinitely, timeOut can be specified in milliseconds.
	WaitElementExistByName(name, scope:=0x4, matchMode:=3, caseSensitive:=True, timeOut:=-1, cacheRequest:="") {
		local
		startTime := A_TickCount
		while (!IsObject(el := this.FindFirstByName(name, scope, matchMode, caseSensitive, cacheRequest)) && ((timeOut < 1) ? 1 : (A_tickCount - startTime < timeOut)))
			Sleep, 40
		return el
	}
	; Calls UIA_Element.FindFirstByType until the element is found and then returns it. By default waits indefinitely, timeOut can be specified in milliseconds.
	WaitElementExistByType(controlType, scope:=0x4, timeOut:=-1, cacheRequest:="") { 
		local
		startTime := A_TickCount
		while (!IsObject(el := this.FindFirstByType(controlType, scope, cacheRequest)) && ((timeOut < 1) ? 1 : (A_tickCount - startTime < timeOut)))
			Sleep, 100
		return el
	}
	; Calls UIA_Element.FindFirstByNameAndType until the element is found and then returns it. By default waits indefinitely, timeOut can be specified in milliseconds.
	WaitElementExistByNameAndType(name, controlType, scope:=0x4, matchMode:=3, caseSensitive:=True, timeOut:=-1, cacheRequest:="") {
		local
		startTime := A_TickCount
		while (!IsObject(el := (this.FindFirstByNameAndType(name, controlType, scope, matchMode, caseSensitive, cacheRequest))) && ((timeOut < 1) ? 1 : (A_tickCount - startTime < timeOut))) {
			Sleep, 100
		}
		return el
	}

	Highlight(displayTime:=2000, color:="Red", d:=4) { ; Based on FindText().RangeTip from the FindText library, credit goes to feiyue
		local
		br := this.CurrentBoundingRectangle, x := br.l, y := br.t, w := br.r-br.l, h := br.b-br.t, d:=Floor(d)
		Loop 4 {
			Gui, Range_%A_Index%: +Hwndid +AlwaysOnTop -Caption +ToolWindow -DPIScale +E0x08000000
			i:=A_Index
			, x1:=(i=2 ? x+w : x-d)
			, y1:=(i=3 ? y+h : y-d)
			, w1:=(i=1 or i=3 ? w+2*d : d)
			, h1:=(i=2 or i=4 ? h+2*d : d)
			Gui, Range_%i%: Color, %color%
			Gui, Range_%i%: Show, NA x%x1% y%y1% w%w1% h%h1%
		}
		Sleep, %displayTime%
		Loop 4
			Gui, Range_%A_Index%: Destroy
		return this
	}
}

class UIA_Element2 extends UIA_Element {
	;~ http://msdn.microsoft.com/en-us/library/windows/desktop/ee671425(v=vs.85).aspx
	static __IID := "{6749C683-F70D-4487-A698-5F79D55290D6}"

	; ---------- UIA_Element2 properties ----------

	CurrentOptimizeForVisualContent[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(85), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}
	CachedOptimizeForVisualContent[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(86), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}
	CurrentLiveSetting[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(87), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}
	CachedLiveSetting[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(88), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}
	CurrentFlowsFrom[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(89), "ptr",this.__Value, "ptr*",out:=""))?UIA_ElementArray(out):
		}
	}
	CachedFlowsFrom[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(90), "ptr",this.__Value, "ptr*",out:=""))?UIA_ElementArray(out):
		}
	}
}
class UIA_Element3 extends UIA_Element2 {
	static __IID := "{8471DF34-AEE0-4A01-A7DE-7DB9AF12C296}"

	; ---------- UIA_Element3 properties ----------

	CurrentIsPeripheral[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(92), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}
	CachedIsPeripheral[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(93), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}

	; ---------- UIA methods ----------

	ShowContextMenu() {
		return UIA_Hr(DllCall(this.__Vt(91), "ptr",this.__Value))
	}
}
class UIA_Element4 extends UIA_Element3 {
	static __IID := "{3B6E233C-52FB-4063-A4C9-77C075C2A06B}"

	; ---------- UIA_Element4 properties ----------

	CurrentPositionInSet[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(94), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}
	CurrentSizeOfSet[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(95), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}
	CurrentLevel[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(96), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}
	CurrentAnnotationTypes[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(97), "ptr",this.__Value, "ptr",UIA_Variant(out:="")))&&out?UIA_VariantData(out):
		}
	}
	CurrentAnnotationObjects[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(98), "ptr",this.__Value, "ptr*",out:=""))?UIA_ElementArray(out):
		}
	}
	CachedPositionInSet[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(99), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}
	CachedSizeOfSet[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(100), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}
	CachedLevel[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(101), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}
	CachedAnnotationTypes[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(102), "ptr",this.__Value, "ptr",UIA_Variant(out:="")))&&out?UIA_VariantData(out):
		}
	}
	CachedAnnotationObjects[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(103), "ptr",this.__Value, "ptr*",out:=""))?UIA_ElementArray(out):
		}
	}

}
class UIA_Element5 extends UIA_Element4 {
	static __IID := "{98141C1D-0D0E-4175-BBE2-6BFF455842A7}"

	; ---------- UIA_Element5 properties ----------

	CurrentLandmarkType[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(104), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}
	CurrentLocalizedLandmarkType[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(105), "ptr",this.__Value, "ptr*",out:=""))?UIA_GetBSTRValue(out):
		}
	}
	CachedLandmarkType[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(106), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}
	CachedLocalizedLandmarkType[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(107), "ptr",this.__Value, "ptr*",out:=""))?UIA_GetBSTRValue(out):
		}
	}
}
class UIA_Element6 extends UIA_Element5 {
	static __IID := "{4780D450-8BCA-4977-AFA5-A4A517F555E3}"

	; ---------- UIA_Element6 properties ----------

	CurrentFullDescription[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(108), "ptr",this.__Value, "ptr*",out:=""))?UIA_GetBSTRValue(out):
		}
	}
	CachedFullDescription[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(109), "ptr",this.__Value, "ptr*",out:=""))?UIA_GetBSTRValue(out):
		}
	}
}
class UIA_Element7 extends UIA_Element6 {
	static __IID := "{204E8572-CFC3-4C11-B0C8-7DA7420750B7}"
	
	; Finds the first matching element in the specified order. traversalOptions must be one of TreeTraversalOptions enums. [optional] root is pointer to the element with which to begin the search.
	FindFirstWithOptions(scope:=0x4, c:="", traversalOptions:=0, root:=0) { 
		local
		return UIA_Hr(DllCall(this.__Vt(110), "ptr",this.__Value, "uint",scope, "ptr",(c=""?this.TrueCondition:(IsObject(c)?c:this.__UIA.CreateCondition(c))).__Value, "int", traversalOptions, "ptr", root.__Value, "ptr*",out:=""))? UIA_Element(out):
	}
	FindAllWithOptions(scope:=0x4, c:="", traversalOptions:=0, root:=0) {
		local
		return UIA_Hr(DllCall(this.__Vt(111), "ptr",this.__Value, "uint",scope, "ptr",(c=""?this.TrueCondition:(IsObject(c)?c:this.__UIA.CreateCondition(c))).__Value, "int", traversalOptions, "ptr", root.__Value, "ptr*",out:=""))? UIA_ElementArray(out):
	}
	FindFirstWithOptionsBuildCache(scope:=0x4, c:="", cacheRequest:=0, traversalOptions:=0, root:=0) {
		local
		return UIA_Hr(DllCall(this.__Vt(112), "ptr",this.__Value, "uint",scope, "ptr",(c=""?this.TrueCondition:(IsObject(c)?c:this.__UIA.CreateCondition(c))).__Value, "ptr", cacheRequest.__Value, "int", traversalOptions, "ptr", root.__Value, "ptr*",out:=""))? UIA_Element(out):
	}
	FindAllWithOptionsBuildCache(scope:=0x4, c:="", cacheRequest:=0, traversalOptions:=0, root:=0) {
		local
		return UIA_Hr(DllCall(this.__Vt(113), "ptr",this.__Value, "uint",scope, "ptr",(c=""?this.TrueCondition:(IsObject(c)?c:this.__UIA.CreateCondition(c))).__Value, "ptr", cacheRequest.__Value, "int", traversalOptions, "ptr", root.__Value, "ptr*",out:=""))? UIA_ElementArray(out):
	}
	GetCurrentMetadataValue(targetId, metadataId) {
		local
		return UIA_Hr(DllCall(this.__Vt(114), "ptr",this.__Value, "int",targetId, "int", metadataId, "ptr*", UIA_Variant(out:="")))? UIA_VariantData(out):
	}
}

class UIA_ElementArray extends UIA_Base {
	static __IID := "{14314595-b4bc-4055-95f2-58f2e42c9855}"

	; ---------- UIA_ElementArray properties ----------

	Length[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(3), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}

	; ---------- UIA_ElementArray methods ----------
	
	GetElement(i) {
		local
		return UIA_Hr(DllCall(this.__Vt(4), "ptr",this.__Value, "int",i, "ptr*",out:=""))? UIA_Element(out):
	}
}
/*
	Exposes properties and methods that UI Automation client applications use to view and navigate the UI Automation elements on the desktop.
	Microsoft documentation: https://docs.microsoft.com/en-us/windows/win32/api/uiautomationclient/nn-uiautomationclient-iuiautomationtreewalker
*/
class UIA_TreeWalker extends UIA_Base {
	;~ http://msdn.microsoft.com/en-us/library/windows/desktop/ee671470(v=vs.85).aspx
	static __IID := "{4042c624-389c-4afc-a630-9df854a541fc}"

	; ---------- UIA_TreeWalker properties ----------

	Condition[] {
		get {
			local out
			return UIA_Hr(DllCall(this.__Vt(15), "ptr",this.__Value, "ptr*",out:=""))?new UIA_Condition(out):
		}
	}

	; ---------- UIA_TreeWalker methods ----------

	GetParentElement(e) {
		local
		return UIA_Hr(DllCall(this.__Vt(3), "ptr",this.__Value, "ptr",e.__Value, "ptr*",out:=""))? UIA_Element(out):
	}
	GetFirstChildElement(e) {
		local
		return UIA_Hr(DllCall(this.__Vt(4), "ptr",this.__Value, "ptr",e.__Value, "ptr*",out:=""))? UIA_Element(out):
	}
	GetLastChildElement(e) {
		local
		return UIA_Hr(DllCall(this.__Vt(5), "ptr",this.__Value, "ptr",e.__Value, "ptr*",out:=""))? UIA_Element(out):
	}
	GetNextSiblingElement(e) {
		local
		return UIA_Hr(DllCall(this.__Vt(6), "ptr",this.__Value, "ptr",e.__Value, "ptr*",out:=""))? UIA_Element(out):
	}
	GetPreviousSiblingElement(e) {
		local
		return UIA_Hr(DllCall(this.__Vt(7), "ptr",this.__Value, "ptr",e.__Value, "ptr*",out:=""))? UIA_Element(out):
	}
	NormalizeElement(e) {
		local
		return UIA_Hr(DllCall(this.__Vt(8), "ptr",this.__Value, "ptr",e.__Value, "ptr*",out:=""))? UIA_Element(out):
	}
	GetParentElementBuildCache(e, cacheRequest) {
		local
		return UIA_Hr(DllCall(this.__Vt(9), "ptr",this.__Value, "ptr",e.__Value, "ptr",cacheRequest.__Value, "ptr*",out:=""))? UIA_Element(out):
	}
	GetFirstChildElementBuildCache(e, cacheRequest) {
		local
		return UIA_Hr(DllCall(this.__Vt(10), "ptr",this.__Value, "ptr",e.__Value, "ptr",cacheRequest.__Value, "ptr*",out:=""))? UIA_Element(out):
	}
	GetLastChildElementBuildCache(e, cacheRequest) {
		local
		return UIA_Hr(DllCall(this.__Vt(11), "ptr",this.__Value, "ptr",e.__Value, "ptr",cacheRequest.__Value, "ptr*",out:=""))? UIA_Element(out):
	}
	GetNextSiblingElementBuildCache(e, cacheRequest) {
		local
		return UIA_Hr(DllCall(this.__Vt(12), "ptr",this.__Value, "ptr",e.__Value, "ptr",cacheRequest.__Value, "ptr*",out:=""))? UIA_Element(out):
	}
	GetPreviousSiblingElementBuildCache(e, cacheRequest) {
		local
		return UIA_Hr(DllCall(this.__Vt(13), "ptr",this.__Value, "ptr",e.__Value, "ptr",cacheRequest.__Value, "ptr*",out:=""))? UIA_Element(out):
	}
	NormalizeElementBuildCache(e, cacheRequest) {
		local
		return UIA_Hr(DllCall(this.__Vt(14), "ptr",this.__Value, "ptr",e.__Value, "ptr",cacheRequest.__Value, "ptr*",out:=""))? UIA_Element(out):
	}
}

/*
	This is the primary interface for conditions used in filtering when searching for elements in the UI Automation tree. This interface has no members.
	Microsoft documentation: https://docs.microsoft.com/en-us/windows/win32/api/uiautomationclient/nn-uiautomationclient-iuiautomationcondition
*/
class UIA_Condition extends UIA_Base {
	;~ http://msdn.microsoft.com/en-us/library/windows/desktop/ee671420(v=vs.85).aspx
	static __IID := "{352ffba8-0973-437c-a61f-f64cafd81df9}"
}

/*
	Represents a condition based on a property value that is used to find UI Automation elements.
	Microsoft documentation: https://docs.microsoft.com/en-us/windows/win32/api/uiautomationclient/nn-uiautomationclient-iuiautomationpropertycondition
*/
class UIA_PropertyCondition extends UIA_Condition {
	static __IID := "{99ebf2cb-5578-4267-9ad4-afd6ea77e94b}"

	; ---------- UIA_PropertyCondition properties ----------

	PropertyId[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(3), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}
	PropertyValue[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(4), "ptr",this.__Value, "ptr",UIA_Variant(out:="")))&&out?UIA_VariantData(out):
		}
	}
	PropertyConditionFlags[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(5), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}
}

/*
	Exposes properties and methods that Microsoft UI Automation client applications can use to retrieve information about an AND-based property condition.
	Microsoft documentation: https://docs.microsoft.com/en-us/windows/win32/api/uiautomationclient/nn-uiautomationclient-iuiautomationandcondition
*/
class UIA_AndCondition extends UIA_Condition {
	static __IID := "{a7d0af36-b912-45fe-9855-091ddc174aec}"

	; ---------- UIA_AndCondition properties ----------

	ChildCount[] {
		get {
			local out
			return UIA_Hr(DllCall(this.__Vt(3), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}

	;~ GetChildrenAsNativeArray	4	IUIAutomationCondition ***childArray
	GetChildren() { ; Returns a native AHK array containing all the conditions (already subtyped to AndCondition, OrCondition etc)
		local
		global UIA_AndCondition, UIA_OrCondition, UIA_BoolCondition, UIA_NotCondition, UIA_PropertyCondition
		ret := UIA_Hr(DllCall(this.__Vt(5), "ptr",this.__Value, "ptr*",out:="")), arr := []
		if (out && (safeArray := ComObj(0x2003,out,1))) {
			for k in safeArray {
				obj := ComObject(9, k, 1), ObjAddRef(k)
				for _, n in ["Property", "Bool", "And", "Or", "Not"] {
					if ComObjQuery(obj, UIA_%n%Condition.__IID) {
						arr.Push(new UIA_%n%Condition(k))
						break
					}
				}
				ObjRelease(k)
			}
			return arr
		}
		return
	}
}

/*
	Represents a condition made up of multiple conditions, at least one of which must be true.
	Microsoft documentation: https://docs.microsoft.com/en-us/windows/win32/api/uiautomationclient/nn-uiautomationclient-iuiautomationorcondition
*/
class UIA_OrCondition extends UIA_Condition {
	static __IID := "{8753f032-3db1-47b5-a1fc-6e34a266c712}"

	; ---------- UIA_OrCondition properties ----------

	ChildCount[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(3), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}

	; ---------- UIA_OrCondition methods ----------

	;~ GetChildrenAsNativeArray	4	IUIAutomationCondition ***childArray
	GetChildren() {
		local
		global UIA_AndCondition, UIA_OrCondition, UIA_BoolCondition, UIA_NotCondition, UIA_PropertyCondition
		ret := UIA_Hr(DllCall(this.__Vt(5), "ptr",this.__Value, "ptr*",out:="")), arr := []
		if (out && (safeArray := ComObject(0x2003,out,1))) {
			for k in safeArray {
				obj := ComObject(9, k, 1) ; ObjAddRef and ObjRelease probably aren't needed here, since ref count won't fall to 0
				for _, n in ["Property", "Bool", "And", "Or", "Not"] {
					if ComObjQuery(obj, UIA_%n%Condition.__IID) {
						arr.Push(new UIA_%n%Condition(k,1))
						break
					}
				}
			}
			return arr
		}
		return
	}
}

/*
	Represents a condition that can be either TRUE=1 (selects all elements) or FALSE=0(selects no elements).
	Microsoft documentation: 
*/
class UIA_BoolCondition extends UIA_Condition {
	static __IID := "{1B4E1F2E-75EB-4D0B-8952-5A69988E2307}"

	; ---------- UIA_BoolCondition properties ----------

	BooleanValue[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(3), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}
}

/*
	Represents a condition that is the negative of another condition.
	Microsoft documentation: https://docs.microsoft.com/en-us/windows/win32/api/uiautomationclient/nn-uiautomationclient-iuiautomationnotcondition
*/
class UIA_NotCondition extends UIA_Condition {
	static __IID := "{f528b657-847b-498c-8896-d52b565407a1}"

	GetChild() { ; Type of the received condition can be determined with out.__Class
		local
		global UIA_AndCondition, UIA_OrCondition, UIA_BoolCondition, UIA_NotCondition, UIA_PropertyCondition
		ret := UIA_Hr(DllCall(this.__Vt(3), "ptr",this.__Value, "ptr*",out:="")), obj := ComObject(9, out, 1)
		for k, v in ["Bool", "Property", "And", "Or", "Not"] {
			if ComObjQuery(obj, UIA_%v%Condition.__IID)
				return ret?new UIA_%v%Condition(out):
		}
		return UIA_Hr(0x80004005)
	}
}

class UIA_IUnknown extends UIA_Base {
	;~ http://msdn.microsoft.com/en-us/library/windows/desktop/ms680509(v=vs.85).aspx
	static __IID := "{00000000-0000-0000-C000-000000000046}"
}

/*
	Exposes properties and methods of a cache request. Client applications use this interface to specify the properties and control patterns to be cached when a Microsoft UI Automation element is obtained.
	Microsoft documentation: https://docs.microsoft.com/en-us/windows/win32/api/uiautomationclient/nn-uiautomationclient-iuiautomationcacherequest
*/
class UIA_CacheRequest extends UIA_Base {
	static __IID := "{b32a92b5-bc25-4078-9c08-d7ee95c48e03}"

	; ---------- UIA_CacheRequest properties ----------

	TreeScope[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(6), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
		set {
			UIA_Hr(DllCall(this.__Vt(7), "ptr",this.__Value, "ptr", value))
		}
	}
	TreeFilter[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(8), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
		set {
			UIA_Hr(DllCall(this.__Vt(9), "ptr",this.__Value, "ptr",value.__Value))
		}
	}
	AutomationElementMode[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(10), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
		set {
			UIA_Hr(DllCall(this.__Vt(11), "ptr",this.__Value, "ptr",value))
		}
	}

	; ---------- UIA_CacheRequest methods ----------

	Clone() {
		local out
		return UIA_Hr(DllCall(this.__Vt(5), "ptr",this.__Value, "ptr*",out:="")) ? new UIA_CacheRequest(out):
	}	
	AddProperty(property) {
		if property is not integer
			property := UIA_Enum.UIA_PropertyId(property)
		return UIA_Hr(DllCall(this.__Vt(3), "ptr",this.__Value, "ptr",property))
	}
	AddPattern(pattern) {
		if pattern is not integer
			pattern := UIA_Enum.UIA_PatternId(pattern)
		return UIA_Hr(DllCall(this.__Vt(4), "ptr",this.__Value,"ptr",pattern))
	}
}

/*
	Exposes a method to handle Microsoft UI Automation events
	Microsoft documentation: https://docs.microsoft.com/en-us/windows/win32/api/uiautomationclient/nn-uiautomationclient-iuiautomationeventhandler
*/
class _UIA_EventHandler extends UIA_Base {
	;~ http://msdn.microsoft.com/en-us/library/windows/desktop/ee696044(v=vs.85).aspx
	static __IID := "{146c3c17-f12e-4e22-8c27-f894b9b79c69}"

	HandleAutomationEvent(sender, eventId) {
		local param1, funcName
		param1 := this, this := Object(A_EventInfo), funcName := this.__Version
		%funcName%(UIA_Element(sender), eventId)
		return 0
	}
}
/*
	Exposes a method to handle events that are raised when the keyboard focus moves to another UI Automation element.
	Microsoft documentation: https://docs.microsoft.com/en-us/windows/win32/api/uiautomationclient/nn-uiautomationclient-iuiautomationfocuschangedeventhandler
*/
class _UIA_FocusChangedEventHandler extends UIA_Base {
	;~ http://msdn.microsoft.com/en-us/library/windows/desktop/ee696051(v=vs.85).aspx
	static __IID := "{c270f6b5-5c69-4290-9745-7a7f97169468}"

	HandleFocusChangedEvent(sender) {
		local param1, funcName
		param1 := this, this := Object(A_EventInfo), funcName := this.__Version
		%funcName%(UIA_Element(sender))
		return 0
	}
}
/*
	Exposes a method to handle Microsoft UI Automation events that occur when a property is changed.
	Microsoft documentation: https://docs.microsoft.com/en-us/windows/win32/api/uiautomationclient/nn-uiautomationclient-iuiautomationpropertychangedeventhandler
*/
class _UIA_PropertyChangedEventHandler extends UIA_Base { ; UNTESTED
	;~ http://msdn.microsoft.com/en-us/library/windows/desktop/ee696119(v=vs.85).aspx
	static __IID := "{40cd37d4-c756-4b0c-8c6f-bddfeeb13b50}"

	HandlePropertyChangedEvent(sender, propertyId, newValue) {
		local param1, funcName
		param1 := this, this := Object(A_EventInfo), funcName := this.__Version
		%funcName%(UIA_Element(sender), propertyId, UIA_VariantData(newValue,0))
		return 0
	}
}
/*
	Exposes a method to handle events that occur when the Microsoft UI Automation tree structure is changed.
	Microsoft documentation: https://docs.microsoft.com/en-us/windows/win32/api/uiautomationclient/nn-uiautomationclient-iuiautomationstructurechangedeventhandler
*/
class _UIA_StructureChangedEventHandler extends UIA_Base {
	;~ http://msdn.microsoft.com/en-us/library/windows/desktop/ee696197(v=vs.85).aspx
	static __IID := "{e81d1b4e-11c5-42f8-9754-e7036c79f054}"

	HandleStructureChangedEvent(sender, changeType, runtimeId) {
		local param1, funcName
		param1 := this, this := Object(A_EventInfo), funcName := this.__Version
		%funcName%(UIA_Element(sender), changeType, UIA_SafeArrayToAHKArray(ComObj(0x2003,runtimeId))) ; ComObj(0x2003,runtimeId,1) crashes the script. Should the SAFEARRAY be released manually?
		return 0
	}
}
/*
	Exposes a method to handle events that occur when Microsoft UI Automation reports a text-changed event from text edit controls
	Microsoft documentation: https://docs.microsoft.com/en-us/windows/win32/api/uiautomationclient/nn-uiautomationclient-iuiautomationtextedittextchangedeventhandler
*/
class _UIA_TextEditTextChangedEventHandler extends UIA_Base { ; UNTESTED
	;~ http://msdn.microsoft.com/en-us/library/windows/desktop/dn302202(v=vs.85).aspx
	static __IID := "{92FAA680-E704-4156-931A-E32D5BB38F3F}"

	HandleTextEditTextChangedEvent(sender, changeType, eventStrings) {
		local param1, funcName
		param1 := this, this := Object(A_EventInfo), funcName := this.__Version
		%funcName%(UIA_Element(sender), changeType, UIA_SafeArrayToAHKArray(ComObj(0x2008,eventStrings)))
		return 0
	}
}
/*
	Exposes a method to handle one or more Microsoft UI Automation change events
	Microsoft documentation: https://docs.microsoft.com/en-us/windows/win32/api/uiautomationclient/nn-uiautomationclient-iuiautomationchangeseventhandler
*/
class _UIA_ChangesEventHandler extends UIA_Base { ; UNTESTED
	static __IID := "{58EDCA55-2C3E-4980-B1B9-56C17F27A2A0}"

	HandleChangesEvent(sender, uiaChanges, changesCount) {
		local param1, funcName, changes
		param1 := this, this := Object(A_EventInfo), funcName := this.__Version, changes := {}
		changes.uiaId := NumGet(uiaChanges,, 0), changes.payload := UIA_VariantData(uiaChanges,, 8), changes.extraInfo := UIA_VariantData(uiaChanges,,16+2*A_PtrSize)
		
		%funcName%(UIA_Element(sender), changes, changesCount)
		return 0
	}
}
/*
	Exposes a method to handle Microsoft UI Automation notification events
	Microsoft documentation: https://docs.microsoft.com/en-us/windows/win32/api/uiautomationclient/nn-uiautomationclient-iuiautomationnotificationeventhandler
*/
class _UIA_NotificationEventHandler extends UIA_Base {
	static __IID := "{C7CB2637-E6C2-4D0C-85DE-4948C02175C7}"

	HandleNotificationEvent(sender, notificationKind, notificationProcessing, displayString, activityId) {
		local param1, funcName
		param1 := this, this := Object(A_EventInfo), funcName := this.__Version
		%funcName%(UIA_Element(sender), notificationKind, notificationProcessing, StrGet(displayString), StrGet(activityId))
		DllCall("oleaut32\SysFreeString", "ptr", displayString), DllCall("oleaut32\SysFreeString", "ptr", activityId)
		return 0
	}
}

class UIA_AutomationEventHandlerGroup extends UIA_Base {
	static __IID := "{C9EE12F2-C13B-4408-997C-639914377F4E}"

	AddActiveTextPositionChangedEventHandler(scope:=0x4, cacheRequest:=0, handler:="") {
		return UIA_Hr(DllCall(this.__Vt(3), "ptr",this.__Value, "int", scope, "int", cacheRequest.__Value, "ptr", handler.__Value))
	}
	AddAutomationEventHandler(eventId, scope:=0x4, cacheRequest:=0, handler:="") {
		return UIA_Hr(DllCall(this.__Vt(4), "ptr",this.__Value, "uint", eventId, "uint", scope, "ptr",cacheRequest.__Value,"ptr", handler.__Value))
	}
	AddChangesEventHandler(scope, changeTypes, changesCount, cacheRequest:=0, handler:="") {
		return UIA_Hr(DllCall(this.__Vt(5), "ptr",this.__Value, "int", scope, "int", changeTypes, "int", changesCount, "ptr", cacheRequest.__Value, "ptr", handler.__Value))
	}
	AddNotificationEventHandler(scope:=0x4, cacheRequest:=0, handler:="") {
		return UIA_Hr(DllCall(this.__Vt(6), "ptr",this.__Value, "int", scope, "int", cacheRequest.__Value, "ptr", handler.__Value))
	}
	AddPropertyChangedEventHandler(scope:=0x1,cacheRequest:=0,handler:="",propertyArray:="") {
		local
		SafeArray:=ComObjArray(0x3,propertyArray.MaxIndex())
		for i,propertyId in propertyArray
			SafeArray[i-1]:=propertyId
		return UIA_Hr(DllCall(this.__Vt(7), "ptr",this.__Value, "int",scope, "ptr",cacheRequest.__Value,"ptr",handler.__Value,"ptr",ComObjValue(SafeArray)))
	}
	AddStructureChangedEventHandler(scope:=0x4, cacheRequest:=0, handler:="") { ; UNTESTED. 
		return UIA_Hr(DllCall(this.__Vt(8), "ptr",this.__Value, "int", scope, "ptr",cacheRequest.__Value, "ptr", handler.__Value))
	}
	AddTextEditTextChangedEventHandler(scope, textEditChangeType, cacheRequest:=0, handler:="") {
		return UIA_Hr(DllCall(this.__Vt(9), "ptr",this.__Value, "int", scope, "int", textEditChangeType, "ptr", cacheRequest.__Value, "ptr", handler.__Value))
	}
}

/*
	Provides access to a control that enables child elements to be arranged horizontally and vertically, relative to each other.
	Microsoft documentation: https://docs.microsoft.com/en-us/windows/win32/api/uiautomationclient/nn-uiautomationclient-iuiautomationdockpattern
*/
class UIA_DockPattern extends UIA_Base {
	;~ http://msdn.microsoft.com/en-us/library/windows/desktop/ee671421
	static	__IID := "{fde5ef97-1464-48f6-90bf-43d0948e86ec}"
		,	__PatternID := 10011

	; ---------- UIA_DockPattern properties ----------

	CurrentDockPosition[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(4), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}
	CachedDockPosition[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(5), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}

	; ---------- UIA_DockPattern methods ----------

	SetDockPosition(Pos) {
		return UIA_Hr(DllCall(this.__Vt(3), "ptr",this.__Value, "uint",pos))
	}
	/*	DockPosition_Top	= 0,
		DockPosition_Left	= 1,
		DockPosition_Bottom	= 2,
		DockPosition_Right	= 3,
		DockPosition_Fill	= 4,
		DockPosition_None	= 5
	*/
}

/*
	Provides access to a control that can visually expand to display content, and collapse to hide content.
	Microsoft documentation: https://docs.microsoft.com/en-us/windows/win32/api/uiautomationclient/nn-uiautomationclient-iuiautomationexpandcollapsepattern
*/
class UIA_ExpandCollapsePattern extends UIA_Base {
	static	__IID := "{619be086-1f4e-4ee4-bafa-210128738730}"
		,	__PatternID := 10005

	; ---------- UIA_ExpandCollapsePattern properties ----------

	CachedExpandCollapseState[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(6), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}
	CurrentExpandCollapseState[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(5), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}

	; ---------- UIA_ExpandCollapsePattern methods ----------
	
	Expand() {
		return UIA_Hr(DllCall(this.__Vt(3), "ptr",this.__Value))
	}
	Collapse() {
		return UIA_Hr(DllCall(this.__Vt(4), "ptr",this.__Value))
	}	
	/*	ExpandCollapseState_Collapsed	= 0,
		ExpandCollapseState_Expanded	= 1,
		ExpandCollapseState_PartiallyExpanded	= 2,
		ExpandCollapseState_LeafNode	= 3
	*/
}

/*
	Provides access to a child control in a grid-style container that supports the IUIAutomationGridPattern interface.
	Microsoft documentation: https://docs.microsoft.com/en-us/windows/win32/api/uiautomationclient/nn-uiautomationclient-iuiautomationgriditempattern
*/
class UIA_GridItemPattern extends UIA_Base {
	;~ http://msdn.microsoft.com/en-us/library/windows/desktop/ee696053
	static	__IID := "{78f8ef57-66c3-4e09-bd7c-e79b2004894d}"
		,	__PatternID := 10007

	; ---------- UIA_GridItemPattern properties ----------

	CurrentContainingGrid[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(3), "ptr",this.__Value, "ptr*",out:=""))?UIA_Element(out):
		}
	}
	CurrentRow[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(4), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}
	CurrentColumn[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(5), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}
	CurrentRowSpan[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(6), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}
	CurrentColumnSpan[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(7), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}
	CachedContainingGrid[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(8), "ptr",this.__Value, "ptr*",out:=""))?UIA_Element(out):
		}
	}
	CachedRow[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(9), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}
	CachedColumn[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(10), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}
	CachedRowSpan[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(11), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}
	CachedColumnSpan[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(12), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}
}

/*
	Provides access to a control that acts as a container for a collection of child controls that are organized in a two-dimensional logical coordinate system that can be traversed by row and column. The children of this element support the GridItemPattern interface.
	Microsoft documentation: https://docs.microsoft.com/en-us/windows/win32/api/uiautomationclient/nn-uiautomationclient-iuiautomationgridpattern
*/
class UIA_GridPattern extends UIA_Base {
	;~ http://msdn.microsoft.com/en-us/library/windows/desktop/ee696064
	static	__IID := "{414c3cdc-856b-4f5b-8538-3131c6302550}"
		,	__PatternID := 10006

	; ---------- UIA_GridPattern properties ----------

	CurrentRowCount[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(4), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}
	CurrentColumnCount[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(5), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}
	CachedRowCount[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(6), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}
	CachedColumnCount[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(7), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}

	; ---------- UIA_GridPattern methods ----------

	GetItem(row,column) { ; Hr!=0 if no result, or blank output?
		local
		return UIA_Hr(DllCall(this.__Vt(3), "ptr",this.__Value, "uint",row, "uint",column, "ptr*",out:=""))? UIA_Element(out):
	}
}

/*
	Exposes a method that enables a client application to invoke the action of a control (typically a button). A control should support this interface if it initiates or performs a single, unambiguous action and does not maintain state when activated.
	Microsoft documentation: https://docs.microsoft.com/en-us/windows/win32/api/uiautomationclient/nn-uiautomationclient-iuiautomationinvokepattern
*/
class UIA_InvokePattern extends UIA_Base {
	;~ http://msdn.microsoft.com/en-us/library/windows/desktop/ee696070
	static	__IID := "{fb377fbe-8ea6-46d5-9c73-6499642d3059}"
		,	__PatternID := 10000
	
	Invoke() {
		return UIA_Hr(DllCall(this.__Vt(3), "ptr",this.__Value))
	}
}

/*
	Exposes a method that retrieves an item from a container, such as a virtual list. This interface is not limited to use by virtualized containers. Any container that can implement efficient name lookup can support this control pattern, enabling clients to look up names more quickly than by using methods such as FindFirst, which must traverse the Microsoft UI Automation tree.
	Microsoft documentation: https://docs.microsoft.com/en-us/windows/win32/api/uiautomationclient/nn-uiautomationclient-iuiautomationitemcontainerpattern
*/
class UIA_ItemContainerPattern extends UIA_Base {
	;~ http://msdn.microsoft.com/en-us/library/windows/desktop/ee696072
	static	__IID := "{c690fdb2-27a8-423c-812d-429773c9084e}"
		,	__PatternID := 10019

	FindItemByProperty(startAfter, propertyId, ByRef value, type:=8) {	; Hr!=0 if no result, or blank output?
		local
		if (type!="Variant")
			UIA_Variant(value,type,value)
		return UIA_Hr((A_PtrSize == 4) ? DllCall(this.__Vt(3), "ptr",this.__Value, "ptr",startAfter.__Value, "int",propertyId, "int64",NumGet(value, 0, "int64"),"int64",NumGet(value, 8, "int64"), "ptr*",out:="") : DllCall(this.__Vt(3), "ptr",this.__Value, "ptr",startAfter.__Value, "int",propertyId, "ptr",&value, "ptr*",out:=""))? UIA_Element(out):
	}
}

/*
	Exposes methods and properties that enable Microsoft UI Automation clients to retrieve UI information from Microsoft Active Accessibility (MSAA) servers.
	Microsoft documentation: https://docs.microsoft.com/en-us/windows/win32/api/uiautomationclient/nn-uiautomationclient-iuiautomationlegacyiaccessiblepattern
*/
class UIA_LegacyIAccessiblePattern extends UIA_Base {
	static	__IID := "{828055ad-355b-4435-86d5-3b51c14a9b1b}"
		,	__PatternID := 10018

	; ---------- UIA_LegacyIAccessiblePattern properties ----------

	CurrentChildId[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(6), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}
	CurrentName[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(7), "ptr",this.__Value, "ptr*",out:=""))?UIA_GetBSTRValue(out):
		}
	}
	CurrentValue[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(8), "ptr",this.__Value, "ptr*",out:=""))?UIA_GetBSTRValue(out):
		}
		set {
			return UIA_Hr(DllCall(this.__Vt(5), "ptr",this.__Value, "ptr",&value))
		}
	}
	CurrentDescription[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(9), "ptr",this.__Value, "ptr*",out:=""))?UIA_GetBSTRValue(out):
		}
	}
	CurrentRole[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(10), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}
	CurrentState[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(11), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}
	CurrentHelp[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(12), "ptr",this.__Value, "ptr*",out:=""))?UIA_GetBSTRValue(out):
		}
	}
	CurrentKeyboardShortcut[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(13), "ptr",this.__Value, "ptr*",out:=""))?UIA_GetBSTRValue(out):
		}
	}
	CurrentDefaultAction[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(15), "ptr",this.__Value, "ptr*",out:=""))?UIA_GetBSTRValue(out):
		}
	}
	CachedChildId[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(16), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}
	CachedName[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(17), "ptr",this.__Value, "ptr*",out:=""))?UIA_GetBSTRValue(out):
		}
	}
	CachedValue[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(18), "ptr",this.__Value, "ptr*",out:=""))?UIA_GetBSTRValue(out):
		}
	}
	CachedDescription[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(19), "ptr",this.__Value, "ptr*",out:=""))?UIA_GetBSTRValue(out):
		}
	}
	CachedRole[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(20), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}
	CachedState[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(21), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}
	CachedHelp[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(22), "ptr",this.__Value, "ptr*",out:=""))?UIA_GetBSTRValue(out):
		}
	}
	CachedKeyboardShortcut[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(23), "ptr",this.__Value, "ptr*",out:=""))?UIA_GetBSTRValue(out):
		}
	}
	CachedDefaultAction[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(25), "ptr",this.__Value, "ptr*",out:=""))?UIA_GetBSTRValue(out):
		}
	}

	; ---------- UIA_LegacyIAccessiblePattern methods ----------

	Select(flags:=3) {
		return UIA_Hr(DllCall(this.__Vt(3), "ptr",this.__Value, "int",flags))
	}
	DoDefaultAction() {
		return UIA_Hr(DllCall(this.__Vt(4), "ptr",this.__Value))
	}
	SetValue(value) {
		return UIA_Hr(DllCall(this.__Vt(5), "ptr",this.__Value, "ptr",&value))
	}
	GetCurrentSelection() { ; UNTESTED
		local
		return UIA_Hr(DllCall(this.__Vt(14), "ptr",this.__Value, "ptr*",out:=""))? UIA_ElementArray(out):
	}
	;~ GetCachedSelection	24	IUIAutomationElementArray
	GetIAccessible() {
	/*	This method returns NULL if the underlying implementation of the UI Automation element is not a native 
	Microsoft Active Accessibility server; that is, if a client attempts to retrieve the IAccessible interface 
	for an element originally supported by a proxy object from OLEACC.dll, or by the UIA-to-MSAA Bridge.
	*/
		local
		return UIA_Hr(DllCall(this.__Vt(26), "ptr",this.__Value, "ptr*",pacc:=""))&&pacc? ComObj(9,pacc,1):
	}
}

/*
	Provides access to a control that can switch between multiple representations of the same information or set of child controls.
	Microsoft documentation: https://docs.microsoft.com/en-us/windows/win32/api/uiautomationclient/nn-uiautomationclient-iuiautomationmultipleviewpattern
*/
class UIA_MultipleViewPattern extends UIA_Base {
	;~ http://msdn.microsoft.com/en-us/library/windows/desktop/ee696099
	static	__IID := "{8d253c91-1dc5-4bb5-b18f-ade16fa495e8}"
		,	__PatternID := 10008

	; ---------- UIA_MultipleViewPattern properties ----------

	CurrentCurrentView[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(5), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}
	CachedCurrentView[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(7), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}

	; ---------- UIA_MultipleViewPattern methods ----------

	GetViewName(view) { ; need to release BSTR?
		local
		return UIA_Hr(DllCall(this.__Vt(3), "ptr",this.__Value, "int",view, "ptr*",out:=""))? StrGet(out) (DllCall("oleaut32\SysFreeString", "ptr", out)?"":""):
	}
	SetCurrentView(view) {
		return UIA_Hr(DllCall(this.__Vt(4), "ptr",this.__Value, "int",view))
	}
	GetCurrentSupportedViews() {
		local
		return UIA_Hr(DllCall(this.__Vt(6), "ptr",this.__Value, "ptr*",out:=""))? UIA_SafeArrayToAHKArray(ComObj(0x2003,out,1)):
	}
	GetCachedSupportedViews() {
		local
		return UIA_Hr(DllCall(this.__Vt(8), "ptr",this.__Value, "ptr*",out:=""))? UIA_SafeArrayToAHKArray(ComObj(0x2003,out,1)):
	}
}

/*
	Provides access to a control that presents a range of values.
	Microsoft documentation: https://docs.microsoft.com/en-us/windows/win32/api/uiautomationclient/nn-uiautomationclient-iuiautomationrangevaluepattern
*/
class UIA_RangeValuePattern extends UIA_Base {
	;~ http://msdn.microsoft.com/en-us/library/windows/desktop/ee696147
	static	__IID := "{59213f4f-7346-49e5-b120-80555987a148}"
		,	__PatternID := 10003

	; ---------- UIA_RangeValuePattern properties ----------

	CurrentValue[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(4), "ptr",this.__Value, "Double*",out:=""))?out:
		}
		set {
			return UIA_Hr(DllCall(this.__Vt(3), "ptr",this.__Value, "double",value))
		}
	}
	CurrentIsReadOnly[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(5), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}
	CurrentMaximum[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(6), "ptr",this.__Value, "Double*",out:=""))?out:
		}
	}
	CurrentMinimum[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(7), "ptr",this.__Value, "double*",out:=""))?out:
		}
	}
	CurrentLargeChange[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(8), "ptr",this.__Value, "double*",out:=""))?out:
		}
	}
	CurrentSmallChange[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(9), "ptr",this.__Value, "double*",out:=""))?out:
		}
	}
	CachedValue[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(10), "ptr",this.__Value, "double*",out:=""))?out:
		}
	}
	CachedIsReadOnly[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(11), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}
	CachedMaximum[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(12), "ptr",this.__Value, "double*",out:=""))?out:
		}
	}
	CachedMinimum[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(13), "ptr",this.__Value, "double*",out:=""))?out:
		}
	}
	CachedLargeChange[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(14), "ptr",this.__Value, "double*",out:=""))?out:
		}
	}
	CachedSmallChange[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(15), "ptr",this.__Value, "double*",out:=""))?out:
		}
	}

	; ---------- UIA_RangeValuePattern methods ----------

	SetValue(val) {
		return UIA_Hr(DllCall(this.__Vt(3), "ptr",this.__Value, "double",val))
	}
}

/*
	Exposes a method that enables an item in a scrollable view to be placed in a visible portion of the view.
	Microsoft documentation: https://docs.microsoft.com/en-us/windows/win32/api/uiautomationclient/nn-uiautomationclient-iuiautomationscrollitempattern
*/
class UIA_ScrollItemPattern extends UIA_Base {
	;~ http://msdn.microsoft.com/en-us/library/windows/desktop/ee696165
	static	__IID := "{b488300f-d015-4f19-9c29-bb595e3645ef}"
		,	__PatternID := 10017

	ScrollIntoView() {
		return UIA_Hr(DllCall(this.__Vt(3), "ptr",this.__Value))
	}
}

/*
	Provides access to a control that acts as a scrollable container for a collection of child elements. The children of this element support IUIAutomationScrollItemPattern.
	Microsoft documentation: https://docs.microsoft.com/en-us/windows/win32/api/uiautomationclient/nn-uiautomationclient-iuiautomationscrollpattern
*/
class UIA_ScrollPattern extends UIA_Base {
	;~ http://msdn.microsoft.com/en-us/library/windows/desktop/ee696167
	static	__IID := "{88f4d42a-e881-459d-a77c-73bbbb7e02dc}"
		,	__PatternID := 10004

	; ---------- UIA_ScrollPattern properties ----------

	CurrentHorizontalScrollPercent[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(5), "ptr",this.__Value, "double*",out:=""))?out:
		}
	}
	CurrentVerticalScrollPercent[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(6), "ptr",this.__Value, "double*",out:=""))?out:
		}
	}
	CurrentHorizontalViewSize[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(7), "ptr",this.__Value, "double*",out:=""))?out:
		}
	}
	CurrentVerticalViewSize[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(8), "ptr",this.__Value, "double*",out:=""))?out:
		}
	}
	CurrentHorizontallyScrollable[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(9), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}
	CurrentVerticallyScrollable[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(10), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}
	CachedHorizontalScrollPercent[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(11), "ptr",this.__Value, "double*",out:=""))?out:
		}
	}
	CachedVerticalScrollPercent[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(12), "ptr",this.__Value, "double*",out:=""))?out:
		}
	}
	CachedHorizontalViewSize[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(13), "ptr",this.__Value, "double*",out:=""))?out:
		}
	}
	CachedVerticalViewSize[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(14), "ptr",this.__Value, "double*",out:=""))?out:
		}
	}
	CachedHorizontallyScrollable[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(15), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}
	CachedVerticallyScrollable[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(16), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}

	; ---------- UIA_ScrollPattern methods ----------
		
	Scroll(horizontal:=-1, vertical:=-1) { ; Default is ScrollAmount_NoAmount
		return UIA_Hr(DllCall(this.__Vt(3), "ptr",this.__Value, "uint",horizontal, "uint",vertical))
	}
	SetScrollPercent(horizontal:=-1, vertical:=-1) { ; Default is ScrollAmount_NoAmount
		return UIA_Hr(DllCall(this.__Vt(4), "ptr",this.__Value, "double",horizontal, "double",vertical))
	}
	/*	UIA_ScrollPatternNoScroll	=	-1
		ScrollAmount_LargeDecrement	= 0,
		ScrollAmount_SmallDecrement	= 1,
		ScrollAmount_NoAmount	= 2,
		ScrollAmount_LargeIncrement	= 3,
		ScrollAmount_SmallIncrement	= 4
	*/
}

/*
	Provides access to the selectable child items of a container control that supports SelectionPattern
	Microsoft documentation: https://docs.microsoft.com/en-us/windows/win32/api/uiautomationclient/nn-uiautomationclient-iuiautomationselectionitempattern
*/
class UIA_SelectionItemPattern extends UIA_Base { ; UNTESTED
	static	__IID := "{A8EFA66A-0FDA-421A-9194-38021F3578EA}"
		,	__PatternID := 10010

	; ---------- UIA_SelectionItemPattern properties ----------

	CurrentIsSelected[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(6), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}
	CurrentSelectionContainer[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(7), "ptr",this.__Value, "ptr*",out:=""))?UIA_Element(out):
		}
	}
	CachedIsSelected[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(8), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}
	CachedSelectionContainer[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(9), "ptr",this.__Value, "ptr*",out:=""))?UIA_Element(out):
		}
	}

	; ---------- UIA_SelectionItemPattern methods ----------

	Select() {
		return UIA_Hr(DllCall(this.__Vt(3), "ptr",this.__Value))
	}
	AddToSelection() {
		return UIA_Hr(DllCall(this.__Vt(4), "ptr",this.__Value))
	}
	RemoveFromSelection() {
		return UIA_Hr(DllCall(this.__Vt(5), "ptr",this.__Value))
	}
}

/*
	Provides access to a control that contains selectable child items. The children of this element support SelectionItemPattern.
	Microsoft documentation: https://docs.microsoft.com/en-us/windows/win32/api/uiautomationclient/nn-uiautomationclient-iuiautomationselectionpattern
*/
class UIA_SelectionPattern extends UIA_Base {
	static	__IID := "{5ED5202E-B2AC-47A6-B638-4B0BF140D78E}"
		,	__PatternID := 10001

	; ---------- UIA_SelectionPattern properties ----------

	CurrentCanSelectMultiple[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(4), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}
	CurrentIsSelectionRequired[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(5), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}
	CachedCanSelectMultiple[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(7), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}
	CachedIsSelectionRequired[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(8), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}

	; ---------- UIA_SelectionPattern methods ----------

	GetCurrentSelection() { ; Returns an array of selected elements
		local
		return UIA_Hr(DllCall(this.__Vt(3), "ptr",this.__Value, "ptr*",out:=""))?UIA_ElementArray(out):
	}
	GetCachedSelection() {
		local
		return UIA_Hr(DllCall(this.__Vt(6), "ptr",this.__Value, "ptr*",out:=""))?UIA_ElementArray(out):
	}
}

class UIA_SelectionPattern2 extends UIA_SelectionPattern { ; UNTESTED
	static	__IID := "{0532bfae-c011-4e32-a343-6d642d798555}"
		,	__PatternID := 10034

	; ---------- UIA_SelectionPattern2 properties ----------

	CurrentFirstSelectedItem[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(9), "ptr",this.__Value, "ptr*",out:=""))?UIA_Element(out):
		}
	}
	CurrentLastSelectedItem[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(10), "ptr",this.__Value, "ptr*",out:=""))?UIA_Element(out):
		}
	}
	CurrentCurrentSelectedItem[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(11), "ptr",this.__Value, "ptr*",out:=""))?UIA_Element(out):
		}
	}
	CurrentItemCount[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(12), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}
	CachedFirstSelectedItem[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(13), "ptr",this.__Value, "ptr*",out:=""))?UIA_Element(out):
		}
	}
	CachedLastSelectedItem[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(14), "ptr",this.__Value, "ptr*",out:=""))?UIA_Element(out):
		}
	}
	CachedCurrentSelectedItem[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(15), "ptr",this.__Value, "ptr*",out:=""))?UIA_Element(out):
		}
	}
	CachedItemCount[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(16), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}
}

/*
	Enables a client application to retrieve information about an item (cell) in a spreadsheet. 
	Microsoft documentation: https://docs.microsoft.com/en-us/windows/win32/api/uiautomationclient/nn-uiautomationclient-iuiautomationspreadsheetitempattern
*/
class UIA_SpreadsheetItemPattern extends UIA_Base { ; UNTESTED
	static	__IID := "{7D4FB86C-8D34-40E1-8E83-62C15204E335}"
		,	__PatternID := 10027

	; ---------- UIA_SpreadsheetItemPattern properties ----------

	CurrentFormula[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(3), "ptr",this.__Value, "ptr*",out:=""))?UIA_GetBSTRValue(out):
		}
	}
	CachedFormula[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(6), "ptr",this.__Value, "ptr*",out:=""))?UIA_GetBSTRValue(out):
		}
	}

	; ---------- UIA_SpreadsheetItemPattern methods ----------

	GetCurrentAnnotationObjects() {
		local
		return UIA_Hr(DllCall(this.__Vt(4), "ptr",this.__Value, "ptr*",out:=""))?UIA_ElementArray(out):
	}
	GetCurrentAnnotationTypes() {
		local
		return UIA_Hr(DllCall(this.__Vt(5), "ptr",this.__Value, "ptr", UIA_Variant(out:="")))?UIA_VariantData(out):
	}
	GetCachedAnnotationObjects() {
		local
		return UIA_Hr(DllCall(this.__Vt(7), "ptr",this.__Value, "ptr*",out:=""))?UIA_ElementArray(out):
	}
	GetCachedAnnotationTypes() {
		local
		return UIA_Hr(DllCall(this.__Vt(8), "ptr",this.__Value, "ptr", UIA_Variant(out:="")))?UIA_VariantData(out):
	}
}

/*
	Enables a client application to access the items (cells) in a spreadsheet
	Microsoft documentation: https://docs.microsoft.com/en-us/windows/win32/api/uiautomationclient/nn-uiautomationclient-iuiautomationspreadsheetpattern
*/
class UIA_SpreadsheetPattern extends UIA_Base { ; UNTESTED
	static	__IID := "{7517A7C8-FAAE-4DE9-9F08-29B91E8595C1}"
		,	__PatternID := 10026

	GetItemByName(name) {
		local
		return UIA_Hr(DllCall(this.__Vt(3), "ptr",this.__Value, "ptr", &name, "ptr*",out:=""))? UIA_Element(out):
	}
}

/*
	Enables Microsoft UI Automation clients to retrieve the visual styles associated with an element in a document.
	Microsoft documentation: https://docs.microsoft.com/en-us/windows/win32/api/uiautomationclient/nn-uiautomationclient-iuiautomationstylespattern
*/
class UIA_StylesPattern extends UIA_Base { ; UNTESTED
	static	__IID := "{85B5F0A2-BD79-484A-AD2B-388C9838D5FB}"
		,	__PatternID := 10025

	; ---------- UIA_StylesPattern properties ----------

	CurrentStyleId[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(3), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}
	CurrentStyleName[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(4), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}
	CurrentFillColor[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(5), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}
	CurrentFillPatternStyle[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(6), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}
	CurrentShape[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(7), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}
	CurrentFillPatternColor[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(8), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}
	CurrentExtendedProperties[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(9), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}
	CachedStyleId[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(11), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}
	CachedStyleName[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(12), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}
	CachedFillColor[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(13), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}
	CachedFillPatternStyle[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(14), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}
	CachedShape[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(15), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}
	CachedFillPatternColor[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(16), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}
	CachedExtendedProperties[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(17), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}

	; ---------- UIA_StylesPattern methods ----------

	GetCurrentExtendedPropertiesAsArray(byref propertyCount) {
		local
		return UIA_Hr(DllCall(this.__Vt(10), "ptr",this.__Value, "ptr*", propertyArray:="", "int*", propertyCount:=""))?UIA_SafeArrayToAHKArray(ComObj(0x2003,propertyArray,1)):
	}
	GetCachedExtendedPropertiesAsArray(byref propertyCount) {
		local
		return UIA_Hr(DllCall(this.__Vt(18), "ptr",this.__Value, "ptr*", propertyArray:="", "int*", propertyCount:=""))?UIA_SafeArrayToAHKArray(ComObj(0x2003,propertyArray,1)):
	}
}

/*
	Provides access to the keyboard or mouse input of a control.
	Microsoft documentation: https://docs.microsoft.com/en-us/windows/win32/api/uiautomationclient/nn-uiautomationclient-iuiautomationsynchronizedinputpattern
*/
class UIA_SynchronizedInputPattern extends UIA_Base { ; UNTESTED
	static	__IID := "{2233BE0B-AFB7-448B-9FDA-3B378AA5EAE1}"
		,	__PatternID := 10021

	StartListening(inputType) {
		return UIA_Hr(DllCall(this.__Vt(3), "ptr",this.__Value, "int",inputType))
	}
	Cancel() {
		return UIA_Hr(DllCall(this.__Vt(3), "ptr",this.__Value))
	}
}

/*
	Provides access to a child element in a container that supports TablePattern
	Microsoft documentation: https://docs.microsoft.com/en-us/windows/win32/api/uiautomationclient/nn-uiautomationclient-iuiautomationtableitempattern
*/
class UIA_TableItemPattern extends UIA_Base {
	static	__IID := "{0B964EB3-EF2E-4464-9C79-61D61737A27E}"
		,	__PatternID := 10013

	GetCurrentRowHeaderItems() {
		local
		return UIA_Hr(DllCall(this.__Vt(3), "ptr",this.__Value, "ptr*",out:=""))?UIA_ElementArray(out):
	}
	GetCurrentColumnHeaderItems() {
		local
		return UIA_Hr(DllCall(this.__Vt(4), "ptr",this.__Value, "ptr*",out:=""))?UIA_ElementArray(out):
	}
	GetCachedRowHeaderItems() {
		local
		return UIA_Hr(DllCall(this.__Vt(5), "ptr",this.__Value, "ptr*",out:=""))?UIA_ElementArray(out):
	}
	GetCachedColumnHeaderItems() {
		local
		return UIA_Hr(DllCall(this.__Vt(6), "ptr",this.__Value, "ptr*",out:=""))?UIA_ElementArray(out):
	}
}

/*
	Provides access to a control that acts as a container for a collection of child elements. The children of this element support TableItemPattern and are organized in a two-dimensional logical coordinate system that can be traversed by row and column.
	Microsoft documentation: https://docs.microsoft.com/en-us/windows/win32/api/uiautomationclient/nn-uiautomationclient-iuiautomationtablepattern
*/
class UIA_TablePattern extends UIA_Base {
	static	__IID := "{620E691C-EA96-4710-A850-754B24CE2417}"
		,	__PatternID := 10012

	; ---------- UIA_TablePattern properties ----------

	CurrentRowOrColumnMajor[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(5), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}
	CachedRowOrColumnMajor[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(8), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}

	; ---------- UIA_TablePattern methods ----------

	GetCurrentRowHeaders() {
		local
		return UIA_Hr(DllCall(this.__Vt(3), "ptr",this.__Value, "ptr*",out:=""))?UIA_ElementArray(out):
	}
	GetCurrentColumnHeaders() {
		local
		return UIA_Hr(DllCall(this.__Vt(4), "ptr",this.__Value, "ptr*",out:=""))?UIA_ElementArray(out):
	}
	GetCachedRowHeaders() {
		local
		return UIA_Hr(DllCall(this.__Vt(6), "ptr",this.__Value, "ptr*",out:=""))?UIA_ElementArray(out):
	}
	GetCachedColumnHeaders() {
		local
		return UIA_Hr(DllCall(this.__Vt(7), "ptr",this.__Value, "ptr*",out:=""))?UIA_ElementArray(out):
	}
}

/*
	Provides access to a control that contains text. Note that TextPattern nor TextRange can't be used to change the text itself, only to get information about the text or select text. To change the text, UIA_Element.SetValue(val) can be used.
	Microsoft documentation: https://docs.microsoft.com/en-us/windows/win32/api/uiautomationclient/nn-uiautomationclient-iuiautomationtextpattern
*/
class UIA_TextPattern extends UIA_Base {
	static	__IID := "{32EBA289-3583-42C9-9C59-3B6D9A1E9B6A}"
		,	__PatternID := 10014

	; ---------- UIA_TextPattern properties ----------

	; DocumentRange returns a TextRange that encloses the main text of a document.
	DocumentRange[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(7), "ptr",this.__Value, "ptr*",out:=""))?UIA_TextRange(out):
		}
	}
	SupportedTextSelection[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(8), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}

	; ---------- UIA_TextPattern methods ----------

	; Retrieves an empty TextRange nearest to the specified screen coordinates
	RangeFromPoint(x, y) { 
		local
		return UIA_Hr(DllCall(this.__Vt(3), "ptr",this.__Value, "int64",x&0xFFFFFFFF|y<<32, "ptr*",out:=""))?UIA_TextRange(out):
	}
	; Retrieves a text range enclosing a child element such as an image, hyperlink, Microsoft Excel spreadsheet, or other embedded object.
	RangeFromChild(child) { 
		local
		return UIA_Hr(DllCall(this.__Vt(4), "ptr",this.__Value, "ptr",child.__Value, "ptr*",out:=""))?UIA_TextRange(out):
	}
	; Returns the currently selected text
	GetSelection() { 
		local
		return UIA_Hr(DllCall(this.__Vt(5), "ptr",this.__Value, "ptr*",out:=""))?UIA_TextRangeArray(out):
	}
	; Retrieves an array of disjoint text ranges from a text-based control where each text range represents a contiguous span of visible text
	GetVisibleRanges() { 
		local
		return UIA_Hr(DllCall(this.__Vt(6), "ptr",this.__Value, "ptr*",out:=""))?UIA_TextRangeArray(out):
	}
}

class UIA_TextPattern2 extends UIA_TextPattern {
	static	__IID := "{506A921A-FCC9-409F-B23B-37EB74106872}"
		,	__PatternID := 10024

	RangeFromAnnotation(annotation) {
		local
		return UIA_Hr(DllCall(this.__Vt(9), "ptr",this.__Value, "ptr", annotation.__Value, "ptr*",out:=""))?UIA_TextRange(out):
	}
	GetCaretRange(ByRef isActive:="") {
		local
		return UIA_Hr(DllCall(this.__Vt(10), "ptr",this.__Value, "ptr*", isActive, "ptr*",out:=""))?UIA_TextRange(out):
	}
}

/*
	Provides access to a control that modifies text, for example a control that performs auto-correction or enables input composition through an Input Method Editor (IME).
	Microsoft documentation: https://docs.microsoft.com/en-us/windows/win32/api/uiautomationclient/nn-uiautomationclient-iuiautomationtexteditpattern
*/
class UIA_TextEditPattern extends UIA_TextPattern { ; UNTESTED
	static	__IID := "{17E21576-996C-4870-99D9-BFF323380C06}"
		,	__PatternID := 10032

	GetActiveComposition() {
		local
		return UIA_Hr(DllCall(this.__Vt(9), "ptr",this.__Value, "ptr*",out:=""))?UIA_TextRange(out):
	}
	GetConversionTarget() {
		local
		return UIA_Hr(DllCall(this.__Vt(10), "ptr",this.__Value, "ptr*",out:=""))?UIA_TextRange(out):
	}
}

/*
	Provides access a text-based control (or an object embedded in text) that is a child or descendant of another text-based control.
	Microsoft documentation: https://docs.microsoft.com/en-us/windows/win32/api/uiautomationclient/nn-uiautomationclient-iuiautomationtextchildpattern
*/
class UIA_TextChildPattern extends UIA_Base { ; UNTESTED
	static	__IID := "{6552B038-AE05-40C8-ABFD-AA08352AAB86}"
		,	__PatternID := 10029

	; ---------- UIA_TextChildPattern properties ----------

	TextContainer[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(3), "ptr",this.__Value, "ptr*",out:=""))?UIA_Element(out):
		}
	}
	TextRange[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(4), "ptr",this.__Value, "ptr*",out:=""))?UIA_TextRange(out):
		}
	}
}

/*
	Provides access to a control that can cycle through a set of states, and maintain a state after it is set.
	Microsoft documentation: https://docs.microsoft.com/en-us/windows/win32/api/uiautomationclient/nn-uiautomationclient-iuiautomationtogglepattern
*/
class UIA_TogglePattern extends UIA_Base
{
    ; https://docs.microsoft.com/en-us/windows/win32/api/uiautomationclient/nn-uiautomationclient-iuiautomationtogglepattern
    static __IID := "{94cf8058-9b8d-4ab9-8bfd-4cd0a33c8c70}"
	, __PatternID := 10015

	; ---------- UIA_TogglePattern properties ----------

	CurrentToggleState[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(4), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
		set { ; Custom
			if (this.CurrentToggleState != value)
				this.Toggle()
		}
	}
	CachedToggleState[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(5), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}

	; ---------- UIA_TogglePattern methods ----------

    Toggle() {
		return UIA_Hr(DllCall(this.__Vt(3), "ptr",this.__Value))
    }
}

/*
	Provides access to a control that can be moved, resized, or rotated.
	Microsoft documentation: https://docs.microsoft.com/en-us/windows/win32/api/uiautomationclient/nn-uiautomationclient-iuiautomationtransformpattern 
*/
class UIA_TransformPattern extends UIA_Base {
	static	__IID := "{A9B55844-A55D-4EF0-926D-569C16FF89BB}"
		,	__PatternID := 10016

	; ---------- UIA_TransformPattern properties ----------

	CurrentCanMove[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(6), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}
	CurrentCanResize[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(7), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}
	CurrentCanRotate[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(8), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}
	CachedCanMove[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(9), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}
	CachedCanResize[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(10), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}
	CachedCanRotate[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(11), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}

	; ---------- UIA_TransformPattern methods ----------

	Move(x, y) {
		return UIA_Hr(DllCall(this.__Vt(3), "ptr",this.__Value, "double",x, "double",y))
	}
	Resize(w, h) {
		return UIA_Hr(DllCall(this.__Vt(4), "ptr",this.__Value, "double",w, "double",h))
	}
	Rotate(degrees) {
		return UIA_Hr(DllCall(this.__Vt(5), "ptr",this.__Value, "double",degrees))
	}
}

class UIA_TransformPattern2 extends UIA_TransformPattern { ; UNTESTED 
	static	__IID := "{6D74D017-6ECB-4381-B38B-3C17A48FF1C2}"
		,	__PatternID := 10028

	; ---------- UIA_TransformPattern2 properties ----------

	CurrentCanZoom[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(14), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}
	CachedCanZoom[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(15), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}
	CurrentZoomLevel[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(16), "ptr",this.__Value, "double*",out:=""))?out:
		}
	}
	CachedZoomLevel[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(17), "ptr",this.__Value, "double*",out:=""))?out:
		}
	}
	CurrentZoomMinimum[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(18), "ptr",this.__Value, "double*",out:=""))?out:
		}
	}
	CachedZoomMinimum[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(19), "ptr",this.__Value, "double*",out:=""))?out:
		}
	}
	CurrentZoomMaximum[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(20), "ptr",this.__Value, "double*",out:=""))?out:
		}
	}
	CachedZoomMaximum[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(21), "ptr",this.__Value, "double*",out:=""))?out:
		}
	}

	; ---------- UIA_TransformPattern2 methods ----------

	Zoom(zoomValue) {
		return UIA_Hr(DllCall(this.__Vt(12), "ptr",this.__Value, "double",zoomValue))
	}
	ZoomByUnit(ZoomUnit) {
		return UIA_Hr(DllCall(this.__Vt(13), "ptr",this.__Value, "uint",ZoomUnit))
	}
}

/*
	Provides access to a control that presents a range of values.
	Microsoft documentation: https://docs.microsoft.com/en-us/windows/win32/api/uiautomationclient/nn-uiautomationclient-iuiautomationvaluepattern
*/
class UIA_ValuePattern extends UIA_Base {
	static	__IID := "{A94CD8B1-0844-4CD6-9D2D-640537AB39E9}"
		,	__PatternID := 10002

	; ---------- UIA_ValuePattern properties ----------

	CurrentValue[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(4), "ptr",this.__Value, "ptr*",out:=""))?UIA_GetBSTRValue(out):
		}
		set {
			return UIA_Hr(DllCall(this.__Vt(3), "ptr",this.__Value, "ptr",&value))
		}
	}
	CurrentIsReadOnly[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(5), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}
	CachedValue[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(6), "ptr",this.__Value, "ptr*",out:=""))?UIA_GetBSTRValue(out):
		}
	}
	CachedIsReadOnly[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(7), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}

	; ---------- UIA_ValuePattern methods ----------

	SetValue(val) {
		return UIA_Hr(DllCall(this.__Vt(3), "ptr",this.__Value, "ptr",&val))
	}
}

/*
	Represents a virtualized item, which is an item that is represented by a placeholder automation element in the Microsoft UI Automation tree.
	Microsoft documentation: https://docs.microsoft.com/en-us/windows/win32/api/uiautomationclient/nn-uiautomationclient-iuiautomationvirtualizeditempattern
*/
class UIA_VirtualizedItemPattern extends UIA_Base {
	static	__IID := "{6BA3D7A6-04CF-4F11-8793-A8D1CDE9969F}"
		,	__PatternID := 10020

	Realize() {
		return UIA_Hr(DllCall(this.__Vt(3), "ptr",this.__Value))
	}
}

/*
	Provides access to the fundamental functionality of a window.
	Microsoft documentation: https://docs.microsoft.com/en-us/windows/win32/api/uiautomationclient/nn-uiautomationclient-iuiautomationwindowpattern
*/
class UIA_WindowPattern extends UIA_Base {
	static __IID := "{0FAEF453-9208-43EF-BBB2-3B485177864F}"
		, __PatternID := 10009

	; ---------- UIA_WindowPattern properties ----------

	CurrentCanMaximize[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(6), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}
	CurrentCanMinimize[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(7), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}
	CurrentIsModal[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(8), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}
	CurrentIsTopmost[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(9), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}
	CurrentWindowVisualState[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(10), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}
	CurrentWindowInteractionState[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(11), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}
	CachedCanMaximize[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(12), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}
	CachedCanMinimize[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(13), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}
	CachedIsModal[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(14), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}
	CachedIsTopmost[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(15), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}
	CachedWindowVisualState[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(16), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}
	CachedWindowInteractionState[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(17), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}

	; ---------- UIA_WindowPattern methods ----------

	Close() {
		return UIA_Hr(DllCall(this.__Vt(3), "ptr",this.__Value))
	}
	WaitForInputIdle(milliseconds) {
		local
		return UIA_Hr(DllCall(this.__Vt(4), "ptr",this.__Value, "int",milliseconds, "Int*", out:=""))?out:
	}
	SetWindowVisualState(state) {
		return UIA_Hr(DllCall(this.__Vt(5), "ptr",this.__Value, "int",state))
	}
}

/*
	Provides access to the properties of an annotation in a document.
	Microsoft documentation: https://docs.microsoft.com/en-us/windows/win32/api/uiautomationclient/nn-uiautomationclient-iuiautomationannotationpattern
*/
class UIA_AnnotationPattern extends UIA_Base {	
	static __IID := "{9A175B21-339E-41B1-8E8B-623F6B681098}"
		, __PatternID := 10023

	; ---------- UIA_AnnotationPattern properties ----------

	CurrentAnnotationTypeId[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(3), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}
	CurrentAnnotationTypeName[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(4), "ptr",this.__Value, "ptr*",out:=""))?UIA_GetBSTRValue(out):
		}
	}
	CurrentAuthor[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(5), "ptr",this.__Value, "ptr*",out:=""))?UIA_GetBSTRValue(out):
		}
	}
	CurrentDateTime[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(6), "ptr",this.__Value, "ptr*",out:=""))?UIA_GetBSTRValue(out):
		}
	}
	CurrentTarget[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(7), "ptr",this.__Value, "ptr*",out:=""))?UIA_Element(out):
		}
	}
	CachedAnnotationTypeId[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(8), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}
	CachedAnnotationTypeName[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(9), "ptr",this.__Value, "ptr*",out:=""))?UIA_GetBSTRValue(out):
		}
	}
	CachedAuthor[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(10), "ptr",this.__Value, "ptr*",out:=""))?UIA_GetBSTRValue(out):
		}
	}
	CachedDateTime[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(11), "ptr",this.__Value, "ptr*",out:=""))?UIA_GetBSTRValue(out):
		}
	}
	CachedTarget[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(12), "ptr",this.__Value, "ptr*",out:=""))?UIA_Element(out):
		}
	}
}

/*
	Provides access to information exposed by a UI Automation provider for an element that can be dragged as part of a drag-and-drop operation.
	Microsoft documentation: https://docs.microsoft.com/en-us/windows/win32/api/uiautomationclient/nn-uiautomationclient-iuiautomationdragpattern
*/
class UIA_DragPattern extends UIA_Base { ; UNTESTED, couldn't find a window that supported this
	static __IID := "{1DC7B570-1F54-4BAD-BCDA-D36A722FB7BD}"
		, __PatternID := 10030

	; ---------- UIA_DragPattern properties ----------

	CurrentIsGrabbed[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(3), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}
	CachedIsGrabbed[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(4), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}
	CurrentDropEffect[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(5), "ptr",this.__Value, "ptr*",out:=""))?UIA_GetBSTRValue(out):
		}
	}
	CachedDropEffect[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(6), "ptr",this.__Value, "ptr*",out:=""))?UIA_GetBSTRValue(out):
		}
	}
	CurrentDropEffects[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(7), "ptr",this.__Value, "ptr",UIA_Variant(out:="")))&&out?UIA_VariantData(out):
		}
	}
	CachedDropEffects[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(8), "ptr",this.__Value, "ptr",UIA_Variant(out:="")))&&out?UIA_VariantData(out):
		}
	}

	; ---------- UIA_DragPattern methods ----------
	GetCurrentGrabbedItems() {
		local
		return UIA_Hr(DllCall(this.__Vt(9), "ptr",this.__Value, "ptr*",out:=""))?UIA_ElementArray(out):
	}
	GetCachedGrabbedItems() {
		local
		return UIA_Hr(DllCall(this.__Vt(10), "ptr",this.__Value, "ptr*",out:=""))?UIA_ElementArray(out):
	}
}

/*
	Provides access to drag-and-drop information exposed by a Microsoft UI Automation provider for an element that can be the drop target of a drag-and-drop operation.
	Microsoft documentation: https://docs.microsoft.com/en-us/windows/win32/api/uiautomationclient/nn-uiautomationclient-iuiautomationdroptargetpattern
*/
class UIA_DropTargetPattern extends UIA_Base { ; UNTESTED
	static __IID := "{69A095F7-EEE4-430E-A46B-FB73B1AE39A5}"
		, __PatternID := 10031

	; ---------- UIA_DropTargetPattern properties ----------

	CurrentDropTargetEffect[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(3), "ptr",this.__Value, "ptr*",out:=""))?UIA_GetBSTRValue(out):
		}
	}
	CachedDropTargetEffect[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(4), "ptr",this.__Value, "ptr*",out:=""))?UIA_GetBSTRValue(out):
		}
	}
	CurrentDropTargetEffects[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(5), "ptr",this.__Value, "ptr",UIA_Variant(out:="")))&&out?UIA_VariantData(out):
		}
	}
	CachedDropTargetEffects[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(6), "ptr",this.__Value, "ptr",UIA_Variant(out:="")))&&out?UIA_VariantData(out):
		}
	}
}

/*
	Provides access to the underlying object model implemented by a control or application.
	Microsoft documentation: https://docs.microsoft.com/en-us/windows/win32/api/uiautomationclient/nn-uiautomationclient-iuiautomationobjectmodelpattern
*/
class UIA_ObjectModelPattern extends UIA_Base {			; Windows 8 [desktop apps only]
	;~ http://msdn.microsoft.com/en-us/library/windows/desktop/hh437262(v=vs.85).aspx
	static	__IID := "{71c284b3-c14d-4d14-981e-19751b0d756d}"
		,	__PatternID := 10022
	GetUnderlyingObjectModel() { ; UNTESTED. Returns IUnknown interface used to access the underlying object model of the provider.
		local
		return UIA_Hr(DllCall(this.__Vt(3), "ptr",this.__Value, "ptr*",out:=""))?out:
	}
}

;~ class UIA_PatternHandler extends UIA_Base {
;~ class UIA_PatternInstance extends UIA_Base {

/*
	Provides access to a span of continuous text in a container that supports the TextPattern interface. TextRange can be used to select, compare, and retrieve embedded objects from the text span. The interface uses two endpoints to delimit where the text span starts and ends. Disjoint spans of text are represented by a TextRangeArray, which is an array of TextRange interfaces.
	Microsoft documentation: https://docs.microsoft.com/en-us/windows/win32/api/uiautomationclient/nn-uiautomationclient-iuiautomationtextrange
*/
class UIA_TextRange extends UIA_Base {
	static __IID := "{A543CC6A-F4AE-494B-8239-C814481187A8}"

	; Returns a copy of the TextRange (retrieves a new IUIAutomationTextRange identical to the original and inheriting all properties of the original).
	Clone() { 
		local
		return UIA_Hr(DllCall(this.__Vt(3), "ptr",this.__Value, "ptr*",out:=""))?UIA_TextRange(out):
	}
	; Compares whether this TextRange has the same endpoints as comparisonTextRange
	Compare(comparisonTextRange) { 
		local
		return UIA_Hr(DllCall(this.__Vt(4), "ptr",this.__Value,"ptr",comparisonTextRange.__Value, "ptr*",out:=""))?out:
	}
	; Retrieves a value that specifies whether the start or end endpoint of this text range is the same as the start or end endpoint of comparisonTextRange. Returns a negative value if the caller's endpoint occurs earlier in the text than the target endpoint; 0 if the caller's endpoint is at the same location as the target endpoint; or a positive value if the caller's endpoint occurs later in the text than the target endpoint. srcEndPoint and targetEndPoint need to be TextPatternRangeEndpoint enums.
	CompareEndPoints(srcEndPoint, comparisonTextRange, targetEndPoint) { 
		local
		return UIA_Hr(DllCall(this.__Vt(5), "ptr",this.__Value,"int", srcEndPoint,"ptr",comparisonTextRange.__Value, "int", targetEndPoint,"ptr*",out:=""))?out:
	}
	; Normalizes the text range by the specified text unit. The range is expanded if it is smaller than the specified unit, or shortened if it is longer than the specified unit. unit needs to be a TextUnit enum (default is TextUnit_Document == 6)
	ExpandToEnclosingUnit(unit:=6) { 
		return UIA_Hr(DllCall(this.__Vt(6), "ptr",this.__Value,"int",unit))
	}
	; Retrieves a text range subset that has the specified text attribute value. attr needs to be a UIA_TextAttributeId enum, and val the desired value (some can be strings, others text attribute enums such as BulletStyle enum)
	FindAttribute(attr, val, backward:=False) { 
		local var, out
		if attr is not integer
			attr := UIA_Enum.UIA_AttributeId(attr)
		UIA_Variant(var:="", UIA_Enum.UIA_AttributeVariantType(attr), val)
		return UIA_Hr((A_PtrSize == 4) ? DllCall(this.__Vt(7), "ptr",this.__Value,"int",attr,"int64",NumGet(var, 0, "int64"),"int64",NumGet(var, 8, "int64"),"int",backward, "ptr*",out:="") : DllCall(this.__Vt(7), "ptr",this.__Value,"int",attr,"ptr",&var,"int",backward,"ptr*",out:=""))?UIA_TextRange(out):
	}
	; Retrieves a text range subset that contains the specified text.
	FindText(text, backward:=False, ignoreCase:=False) { 
		local
		return UIA_Hr(DllCall(this.__Vt(8), "ptr",this.__Value,"ptr", &text,"int",backward, "int", ignoreCase,"ptr*",out:=""))?UIA_TextRange(out):
	}					
	; Retrieves the value of the specified text attribute across the entire text range. attr needs to be a UIA_TextAttributeId enum.
	GetAttributeValue(attr) { 
		local
		return UIA_Hr(DllCall(this.__Vt(9), "ptr",this.__Value,"int", attr,"ptr",UIA_Variant(out:="")))?UIA_VariantData(out):
	}
	; Returns an array of bounding rectangle objects {x:top left X-coord,y:top left Y-coord,w:width,h:height} for each fully or partially visible line of text in a text range.
	GetBoundingRectangles() { 
		local
		static b:={__Class:"object",__Type:"RECT",Struct:Func("UIA_RectStructure")}
		if UIA_Hr(DllCall(this.__Vt(10), "ptr",this.__Value,"ptr*",out:="")) {
			DllCall("oleaut32\SafeArrayGetVartype", "ptr", out, "ushort*", baseType:="")
			sa := UIA_GetSafeArrayValue(out, baseType), retArr := []
			Loop, % sa.MaxIndex() / 4
				retArr.Push({x:Floor(sa[4*(A_Index-1)+1]),y:Floor(sa[4*(A_Index-1)+2]),w:Floor(sa[4*(A_Index-1)+3]),h:Floor(sa[4*(A_Index-1)+4]),base:b})
			return retArr
		}
	}
	; Returns the innermost UI Automation element that encloses the text range.
	GetEnclosingElement() { 
		local
		return UIA_Hr(DllCall(this.__Vt(11), "ptr",this.__Value,"ptr*",out:=""))?UIA_Element(out):
	}
	; Returns the plain text of the text range. maxLength is the maximum length of the string to return, or -1 if no limit is required.
	GetText(maxLength:=-1) { 
		local
		return UIA_Hr(DllCall(this.__Vt(12), "ptr",this.__Value,"int", maxLength,"ptr*",out:=""))?StrGet(out) (DllCall("oleaut32\SysFreeString", "ptr", out)?"":""):
	}
	; Moves the text range forward or backward by the specified number of text units. unit needs to be a TextUnit enum.
	Move(unit, count) { 
		local
		return UIA_Hr(DllCall(this.__Vt(13), "ptr",this.__Value,"int", unit,"int",count, "ptr*",out:=""))?out:
	}
	; Moves one endpoint of the text range the specified number of text units within the document range. endpoint needs to be TextPatternRangeEndpoint enum. unit needs to be a TextUnit enum.
	MoveEndpointByUnit(endpoint, unit, count) { 
		local
		return UIA_Hr(DllCall(this.__Vt(14), "ptr",this.__Value,"int", endpoint,"int", unit, "int", count, "ptr*",out:=""))?out:
	}
	; Moves one endpoint of the current text range to the specified endpoint of a second text range. srcEndPoint and targetEndPoint need to be TextPatternRangeEndpoint enums.
	MoveEndpointByRange(srcEndPoint, range, targetEndPoint) { 
		local
		return UIA_Hr(DllCall(this.__Vt(15), "ptr",this.__Value,"int", srcEndPoint,"ptr",range.__Value, "int", targetEndPoint,"ptr*",out:=""))
	}
	; Selects the span of text that corresponds to this text range, and removes any previous selection.
	Select() { 
		return UIA_Hr(DllCall(this.__Vt(16), "ptr",this.__Value))
	}
	; Adds the text range to the collection of selected text ranges in a control that supports multiple, disjoint spans of selected text.
	AddToSelection() { 
		return UIA_Hr(DllCall(this.__Vt(17), "ptr",this.__Value))
	}
	; Removes the text range from an existing collection of selected text in a text container that supports multiple, disjoint selections.
	RemoveFromSelection() { 
		return UIA_Hr(DllCall(this.__Vt(18), "ptr",this.__Value))
	}
	; Causes the text control to scroll until the text range is visible in the viewport. alignToTop is a boolean value.
	ScrollIntoView(alignToTop) { 
		local
		return UIA_Hr(DllCall(this.__Vt(19), "ptr",this.__Value,"int", alignToTop))
	}
	; Retrieves a collection of all embedded objects that fall within the text range.
	GetChildren() { 
		local
		return UIA_Hr(DllCall(this.__Vt(20), "ptr",this.__Value,"ptr*",out:=""))?UIA_ElementArray(out):
	}
}

class UIA_TextRange2 extends UIA_TextRange {
	static __IID := "{BB9B40E0-5E04-46BD-9BE0-4B601B9AFAD4}"

	ShowContextMenu() {
		local
		return UIA_Hr(DllCall(this.__Vt(21), "ptr",this.__Value,"ptr*",out:=""))
	}
}
class UIA_TextRange3 extends UIA_TextRange2 { ; UNTESTED
	static __IID := "{6A315D69-5512-4C2E-85F0-53FCE6DD4BC2}"

	GetEnclosingElementBuildCache(cacheRequest) {
		local
		return UIA_Hr(DllCall(this.__Vt(22), "Ptr", this.__Value, "Ptr", cacheRequest.__Value, "ptr*",out:=""))?UIA_Element(out):
	}
	GetChildrenBuildCache(cacheRequest) {
		local
		return UIA_Hr(DllCall(this.__Vt(23), "Ptr", this.__Value, "Ptr", cacheRequest.__Value, "ptr*",out:=""))?UIA_ElementArray(out):
	}
	GetAttributeValues(attributeIds, attributeIdCount) { ; currently returns a AHK array
		local
		if ComObjValue(attributeIds)&0x2000
			SafeArray:=attributeIds
		else {
			SafeArray:=ComObj(0x2003,DllCall("oleaut32\SafeArrayCreateVector", "uint",13, "uint",0, "uint",attributeIds.MaxIndex()),1)
			for i,c in attributeIds
				SafeArray[A_Index-1]:=c.__Value, ObjAddRef(c.__Value) ; AddRef - SafeArrayDestroy will release UIA_Conditions - they also release themselves
		}
		return UIA_Hr(DllCall(this.__Vt(24), "ptr",this.__Value, "ptr", ComObjValue(SafeArray), "int", attributeIdCount, "ptr*",out:=""))? UIA_SafeArrayToAHKArray(ComObj(0x2003,out,1)):
	}
}

/*
	Represents a collection (array) of TextRange objects
	Microsoft documentation: https://docs.microsoft.com/en-us/windows/win32/api/uiautomationclient/nn-uiautomationclient-iuiautomationtextrangearray
*/
class UIA_TextRangeArray extends UIA_Base {
	static __IID := "{CE4AE76A-E717-4C98-81EA-47371D028EB6}"

	; ---------- UIA_TextRangeArray properties ----------

	Length[] {
		get {
			local
			return UIA_Hr(DllCall(this.__Vt(3), "ptr",this.__Value, "ptr*",out:=""))?out:
		}
	}

	; ---------- UIA_TextRangeArray methods ----------
	
	GetElement(i) {
		local
		return UIA_Hr(DllCall(this.__Vt(4), "ptr",this.__Value, "int",i, "ptr*",out:=""))?UIA_TextRange(out):
	}
}

;~ UIA Functions

/*
	UIAInterface function initializes the UIAutomation interface and returns a UIA_Interface object. After calling this function, all UIA_Interface class properties and methods can be accessed through the returned object. 
		maxVersion can be used to limit the UIA_Interface version being created. By default the highest version available is used (usually IUIAutomation7 interface). 
		Specifiying maxVersion:=2 would try to initialize IUIAutomation2 interface, and if that fails then IUIAutomation interface.
	In addition some extra variables are initialized: 
		CurrentVersion contains the version number of IUIAutomation interface
		TrueCondition contains a UIA_TrueCondition
		TreeWalkerTrue contains an UIA_TreeWalker that was created with UIA_TrueCondition
	On subsequent calls of UIA_Interface(), the previously created UIA interface object is returned to avoid multiple connections being made. To bypass this, specify a maxVersion
	Note that a new UIA_Interface object can't be created with the "new" keyword. 
*/
UIA_Interface(maxVersion:="") {
	local screenreader := "", max, uiaBase, e
	static uia := ""
	if (IsObject(uia) && (maxVersion == ""))
		return uia
	; enable screenreader flag if disabled
	DllCall("user32.dll\SystemParametersInfo", "uint", 0x0046, "uint", 0, "ptr*", screenreader) ; SPI_GETSCREENREADER
	if !screenreader
		DllCall("user32.dll\SystemParametersInfo", "uint", 0x0047, "uint", 1, "int", 0, "uint", 2) ; SPI_SETSCREENREADER
	max := (maxVersion?maxVersion:UIA_Enum.UIA_MaxVersion_Interface)+1
	while (--max) {
			
		if (!IsObject(UIA_Interface%max%) || (max == 1))
			continue

		try {
			if uia:=ComObjCreate("{e22ad333-b25f-460c-83d0-0581107395c9}",UIA_Interface%max%.__IID) {
				uia:=new UIA_Interface%max%(uia, 1, max), uiaBase := uia.base
				Loop, %max%
					uiaBase := uiaBase.base
				uiaBase.__UIA:=uia, uiaBase.TrueCondition:=uia.CreateTrueCondition(), uiaBase.TreeWalkerTrue := uia.CreateTreeWalker(uiaBase.TrueCondition)
				return uia
			}
		}
	}
	; If all else fails, try the first IUIAutomation version
	try {
		if uia:=ComObjCreate("{ff48dba4-60ef-4201-aa87-54103eef594e}","{30cbe57d-d9d0-452a-ab13-7ac5ac4825ee}")
			return uia:=new UIA_Interface(uia, 1, 1), uia.base.base.__UIA:=uia, uia.base.base.CurrentVersion:=1, uia.base.base.TrueCondition:=uia.CreateTrueCondition(), uia.base.base.TreeWalkerTrue := uia.CreateTreeWalker(uia.base.base.TrueCondition)
		throw "UIAutomation Interface failed to initialize."
	} catch e
		MsgBox, 262160, UIA Startup Error, % IsObject(e)?"IUIAutomation Interface is not registered.":e.Message
	return
}
; Converts an error code to the corresponding error message
UIA_Hr(hr) {
	local
	;~ http://blogs.msdn.com/b/eldar/archive/2007/04/03/a-lot-of-hresult-codes.aspx
	static err:={0x8000FFFF:"Catastrophic failure.",0x80004001:"Not implemented.",0x8007000E:"Out of memory.",0x80070057:"One or more arguments are not valid.",0x80004002:"Interface not supported.",0x80004003:"Pointer not valid.",0x80070006:"Handle not valid.",0x80004004:"Operation aborted.",0x80004005:"Unspecified error.",0x80070005:"General access denied.",0x800401E5:"The object identified by this moniker could not be found.",0x80040201:"UIA_E_ELEMENTNOTAVAILABLE",0x80040200:"UIA_E_ELEMENTNOTENABLED",0x80131509:"UIA_E_INVALIDOPERATION",0x80040202:"UIA_E_NOCLICKABLEPOINT",0x80040204:"UIA_E_NOTSUPPORTED",0x80040203:"UIA_E_PROXYASSEMBLYNOTLOADED",0x80131505:"COR_E_TIMEOUT"} ; //not completed
	if hr&&(hr&=0xFFFFFFFF) {
		RegExMatch(Exception("",-2).what,"(\w+).(\w+)",i)
		throw Exception(UIA_Hex(hr) " - " err[hr], -2, i2 "  (" i1 ")")
	}
	return !hr
}
UIA_NotImplemented() {
	local
	RegExMatch(Exception("",-2).What,"(\D+)\.(\D+)",m)
	MsgBox, 262192, UIA Message, Class:`t%m1%`nMember:`t%m2%`n`nMethod has not been implemented yet.
}
; Used by UIA methods to create new UIA_Element objects of the highest available version. The highest version to try can be changed by modifying UIA_Enum.UIA_CurrentVersion_Element value.
UIA_Element(e,flag:=1) {
	local max, riid
	static v := "", previousVersion := ""
	if !e
		return
	if (previousVersion != UIA_Enum.UIA_CurrentVersion_Element) ; Check if the user wants an element with a different version
		v := ""
	else if v
		return (v==1)?new UIA_Element(e,flag,1):new UIA_Element%v%(e,flag,v)
	max := UIA_Enum.UIA_CurrentVersion_Element+1
	While (--max) {
		if UIA_GUID(riid, UIA_Element%max%.__IID)
			return new UIA_Element%max%(e,flag,v:=max)
	}
	return new UIA_Element(e,flag,v:=1)
}
; Used by UIA methods to create new UIA_TextRange objects of the highest available version. The highest version to try can be changed by modifying UIA_Enum.UIA_CurrentVersion_TextRange value.
UIA_TextRange(e,flag:=1) {
	local max, riid
	static v := "", previousVersion := ""
	if (previousVersion != UIA_Enum.UIA_CurrentVersion_TextRange) ; Check if the user wants an element with a different version
		v := ""
	else if v
		return (v==1)?new UIA_TextRange(e,flag,1):new UIA_TextRange%v%(e,flag,v)
	max := UIA_Enum.UIA_MaxVersion_TextRange+1
	While (--max) {
		if UIA_GUID(riid, UIA_TextRange%max%.__IID)
			return new UIA_TextRange%max%(e,flag,v:=max)
	}
	return new UIA_TextRange(e,flag,v:=1)
}
; Used by UIA methods to create new Pattern objects of the highest available version for a given pattern.
UIA_Pattern(p, el) {
	local i, patternName, patternAvailableId
	static maxPatternVersions := {Selection:2, Text:2, TextRange:3, Transform:2}
	if p is integer 
		return patternName := UIA_Enum.UIA_Pattern(p)
	else
		patternName := InStr(p, "Pattern") ? p : p "Pattern", i:=2
	
	Loop {
		i++
		if !(UIA_Enum.UIA_PatternId(patternName i) && IsObject(UIA_%patternName%%i%) && UIA_%patternName%%i%.__iid && UIA_%patternName%%i%.__PatternID)
			break
	}
	While (--i > 1) {
		if ((patternAvailableId := UIA_Enum["UIA_Is" patternName i "AvailablePropertyId"]) && el.GetCurrentPropertyValue(patternAvailableId))
			return patternName i
	}
	return patternName
}
; Used to fetch constants and enumerations from the UIA_Enum class. The "UIA_" part of a variable name can be left out (eg UIA_Enum("ButtonControlTypeId") will return 50000).
UIA_Enum(e) {
	if ObjHasKey(UIA_Enum, e)
		return UIA_Enum[e]
	else if ObjHasKey(UIA_Enum, "UIA_" e)
		return UIA_Enum["UIA_" e]
}
UIA_ElementArray(p, uia:="",flag:=1) { ; Should AHK Object be 0 or 1 based? Currently 1 based.
	local
	global UIA_ElementArray
	if !p
		return
	a:=new UIA_ElementArray(p,flag),out:=[]
	Loop % a.Length
		out[A_Index]:=a.GetElement(A_Index-1)
	return out, out.base:={UIA_ElementArray:a}
}
UIA_TextRangeArray(p, uia:="",flag:=1) { ; Should AHK Object be 0 or 1 based? Currently 1 based.
	local
	global UIA_TextRangeArray
	a:=new UIA_TextRangeArray(p,flag),out:=[]
	Loop % a.Length
		out[A_Index]:=a.GetElement(A_Index-1)
	return out, out.base:={UIA_TextRangeArray:a}
}
UIA_RectToObject(ByRef r) { ; rect.__Value work with DllCalls?
	static b:={__Class:"object",__Type:"RECT",Struct:Func("UIA_RectStructure")}
	return {l:NumGet(r,0,"Int"),t:NumGet(r,4,"Int"),r:NumGet(r,8,"Int"),b:NumGet(r,12,"Int"),base:b}
}
UIA_RectStructure(this, ByRef r) {
	static sides:="ltrb"
	VarSetCapacity(r,16)
	Loop Parse, sides
		NumPut(this[A_LoopField],r,(A_Index-1)*4,"Int")
}
UIA_SafeArrayToAHKArray(safearray) {
	local
	b:={__Class:"object",__Type:"SafeArray",__Value:safearray}
	out := []
	for k in safearray
		out.Push(k)
	return out, out.base:=b
}
UIA_SafeArraysToObject(keys,values) {
;~	1 dim safearrays w/ same # of elements
	local
	out:={}
	for key in keys
		out[key]:=values[A_Index-1]
	return out
}
UIA_Hex(p) {
	local
	setting:=A_FormatInteger
	SetFormat,IntegerFast,H
	out:=p+0 ""
	SetFormat,IntegerFast,%setting%
	return out
}
UIA_GUID(ByRef GUID, sGUID) { ;~ Converts a string to a binary GUID and returns its address.
	if !sGUID
		return
	VarSetCapacity(GUID,16,0)
	return DllCall("ole32\CLSIDFromString", "wstr",sGUID, "ptr",&GUID)>=0?&GUID:""
}
UIA_Variant(ByRef var,type:=0,val:=0) {
	; https://www.autohotkey.com/boards/viewtopic.php?t=6979
	static SIZEOF_VARIANT := 8 + (2 * A_PtrSize)
	VarSetCapacity(var, SIZEOF_VARIANT), ComObject(0x400C, &var)[] := type&&(type!=8)?ComObject(type,type=0xB?(!val?0:-1):val):val
	return &var ; The variant probably doesn't need clearing, because it is passed to UIA and UIA should take care of releasing it.
	; Old implementation:
	; return (VarSetCapacity(var,8+2*A_PtrSize)+NumPut(type,var,0,"short")+NumPut(type=8? DllCall("oleaut32\SysAllocString", "ptr",&val):val,var,8,"ptr"))*0+&var
}
UIA_IsVariant(ByRef vt, ByRef type:="", offset:=0, flag:=1) {
	local
	size:=VarSetCapacity(vt),type:=NumGet(vt,offset,"UShort")
	return size>=16&&size<=24&&type>=0&&(type<=23||type|0x2000)
}
UIA_VariantType(type){
	static _:={2:[2,"short"]
	,3:[4,"int"]
	,4:[4,"float"]
	,5:[8,"double"]
	,0xA:[4,"uint"]
	,0xB:[2,"short"]
	,0x10:[1,"char"]
	,0x11:[1,"uchar"]
	,0x12:[2,"ushort"]
	,0x13:[4,"uint"]
	,0x14:[8,"int64"]
	,0x15:[8,"uint64"]}
	return _.haskey(type)?_[type]:[A_PtrSize,"ptr"]
}
UIA_VariantData(ByRef p, flag:=1, offset:=0) {
	local
	if flag {
		var := !UIA_IsVariant(p,vt, offset)?"Invalid Variant":ComObject(0x400C, &p)[] ; https://www.autohotkey.com/boards/viewtopic.php?t=6979
		UIA_VariantClear(&p) ; Clears variant, except if it contains a pointer to an object (eg IDispatch). BSTR is automatically freed.
	} else {
		vt:=NumGet(p+0,offset,"UShort"), var := !(vt>=0&&(vt<=23||vt|0x2000))?"Invalid Variant":ComObject(0x400C, p)[]
		UIA_VariantClear(p)
	}
	return vt=11?-var:var ; Negate value if VT_BOOL (-1=True, 0=False)
	; Old implementation, based on Sean's COM_Enumerate function
	; return !UIA_IsVariant(p,vt, offset)?"Invalid Variant"
	;		:vt=0?"" ; VT_EMPTY
	;		:vt=3?NumGet(p,offset+8,"int")
	;		:vt=8?StrGet(NumGet(p,offset+8))
	;		:vt=11?-NumGet(p,offset+8,"short")
	;		:vt=9||vt=13||vt&0x2000?ComObj(vt,NumGet(p,offset+8),flag)
	;		:vt<0x1000&&UIA_VariantChangeType(&p,&p)=0?StrGet(NumGet(p,offset+8)) UIA_VariantClear(&p)
	;		:NumGet(p,offset+8)
/*
	VT_EMPTY     =      0  		; No value
	VT_NULL      =      1 		; SQL-style Null
	VT_I2        =      2 		; 16-bit signed int
	VT_I4        =      3 		; 32-bit signed int
	VT_R4        =      4 		; 32-bit floating-point number
	VT_R8        =      5 		; 64-bit floating-point number
	VT_CY        =      6 		; Currency
	VT_DATE      =      7  		; Date
	VT_BSTR      =      8 		; COM string (Unicode string with length prefix)
	VT_DISPATCH  =      9 		; COM object 
	VT_ERROR     =    0xA  10	; Error code (32-bit integer)
	VT_BOOL      =    0xB  11	; Boolean True (-1) or False (0)
	VT_VARIANT   =    0xC  12	; VARIANT (must be combined with VT_ARRAY or VT_BYREF)
	VT_UNKNOWN   =    0xD  13	; IUnknown interface pointer
	VT_DECIMAL   =    0xE  14	; (not supported)
	VT_I1        =   0x10  16	; 8-bit signed int
	VT_UI1       =   0x11  17	; 8-bit unsigned int
	VT_UI2       =   0x12  18	; 16-bit unsigned int
	VT_UI4       =   0x13  19	; 32-bit unsigned int
	VT_I8        =   0x14  20	; 64-bit signed int
	VT_UI8       =   0x15  21	; 64-bit unsigned int
	VT_INT       =   0x16  22	; Signed machine int
	VT_UINT      =   0x17  23	; Unsigned machine int
	VT_RECORD    =   0x24  36	; User-defined type
	VT_ARRAY     = 0x2000  		; SAFEARRAY
	VT_BYREF     = 0x4000  		; Pointer to another type of value
					= 0x1000  4096

	COM_SysAllocString(str) {
		Return	DllCall("oleaut32\SysAllocString", "Uint", &str)
	}
	COM_SysFreeString(pstr) {
			DllCall("oleaut32\SysFreeString", "Uint", pstr)
	}
	COM_SysString(ByRef wString, sString) {
		VarSetCapacity(wString,4+nLen:=2*StrLen(sString))
		Return	DllCall("kernel32\lstrcpyW","Uint",NumPut(nLen,wString),"Uint",&sString)
	}
	DllCall("oleaut32\SafeArrayGetVartype", "ptr*",ComObjValue(SafeArray), "uint*",pvt)
	HRESULT SafeArrayGetVartype(
		_In_   SAFEARRAY *psa,
		_Out_  VARTYPE *pvt
	);
	DllCall("oleaut32\SafeArrayDestroy", "ptr",ComObjValue(SafeArray))
	HRESULT SafeArrayDestroy(
		_In_  SAFEARRAY *psa
	);
*/
}
UIA_VariantChangeType(pvarDst, pvarSrc, vt:=8) { ; written by Sean
	return DllCall("oleaut32\VariantChangeTypeEx", "ptr",pvarDst, "ptr",pvarSrc, "Uint",1024, "Ushort",0, "Ushort",vt)
}
UIA_VariantClear(pvar) { ; Written by Sean
	DllCall("oleaut32\VariantClear", "ptr",pvar)
}
UIA_GetSafeArrayValue(p,type,flag:=1){ ; Credit: https://github.com/neptercn/UIAutomation/blob/master/UIA.ahk
	local
	t:=UIA_VariantType(type),item:={},pv:=NumGet(p+8+A_PtrSize,"ptr")
	loop % NumGet(p+8+2*A_PtrSize,"uint") {
		item.Insert((type=8)?StrGet(NumGet(pv+(A_Index-1)*t.1,t.2),"utf-16"):NumGet(pv+(A_Index-1)*t.1,t.2))
	}
	if flag
		DllCall("oleaut32\SafeArrayDestroy","ptr", p)
	return item
}
UIA_GetBSTRValue(ByRef bstr) {
	local
	val := StrGet(bstr)
	DllCall("oleaut32\SysFreeString", "ptr", bstr)
	return val
}
/*
	UIA_CreateEventHandler(funcName, handlerType) returns a new handler object that can be used with methods that create EventHandlers (eg AddAutomationEventHandler)
		funcName: name of the function that will receive the calls when an event happens
		handlerType: needed by some of the newer Add...EventHandler functions. In the case of AddAutomationEventHandler, this should be left empty. For other Add...EventHandler cases, specify the ... part: FocusChanged, StructureChanged, TextEditTextChanged, Changes, Notification. So for AddFocusChangedEventHandler, set this value to "FocusChanged"
	
	The function funcName needs to be able to receive a certain number of arguments that depends on the type on handler being created:
		HandleAutomationEvent(sender, eventId)  <--- this is the most common handler type created with AddAutomationEventHandler, and the handler function needs to have exactly two arguments: sender (the element which sent the event), and eventId.
		HandleFocusChangedEvent(sender)
		HandlePropertyChangedEvent(sender, propertyId, newValue)
		HandleStructureChangedEvent(sender, changeType, runtimeId)
		HandleTextEditTextChangedEvent(sender, changeType, eventStrings)
		HandleChangesEvent(sender, uiaChanges, changesCount)
		HandleNotificationEvent(sender, notificationKind, notificationProcessing, displayString, activityId)
*/
UIA_CreateEventHandler(funcName, handlerType:="") { ; Possible handlerType values: empty, FocusChanged, StructureChanged, TextEditTextChanged, Changes, Notification.
	local handler, ptr
	if !(IsFunc(funcName) || IsObject(funcName)) ; Figuring out if the Object is callable is way too difficult to bother with. 
		throw Exception(funcName "is not a function!", -1)
	ptr := DllCall("GlobalAlloc", "UInt",0x40, "UInt",A_PtrSize*5, "Ptr" )
	handler := new _UIA_%handlerType%EventHandler(ptr,2,funcName) ; deref will be done on destruction of EventHandler. Function name piggybacks on the __Version property
	,NumPut(ptr+A_PtrSize,ptr+0)
	,NumPut(RegisterCallback("_UIA_QueryInterface","F"),ptr+0,A_PtrSize*1)
	,NumPut(RegisterCallback("_UIA_AddRef","F"),ptr+0,A_PtrSize*2)
	,NumPut(RegisterCallback("_UIA_Release","F"),ptr+0,A_PtrSize*3)
	,NumPut(RegisterCallback("_UIA_" handlerType "EventHandler.Handle" (handlerType == "" ? "Automation" : handlerType) "Event","F",,&handler),ptr+0,A_PtrSize*4)
	return handler
}
_UIA_QueryInterface(pSelf, pRIID, pObj){ ; Credit: https://github.com/neptercn/UIAutomation/blob/master/UIA.ahk
	local
	DllCall("ole32\StringFromIID","ptr",pRIID,"ptr*",sz:=""),str:=StrGet(sz) ; sz should not be freed here
	return (str="{00000000-0000-0000-C000-000000000046}")||(str="{146c3c17-f12e-4e22-8c27-f894b9b79c69}")||(str="{40cd37d4-c756-4b0c-8c6f-bddfeeb13b50}")||(str="{e81d1b4e-11c5-42f8-9754-e7036c79f054}")||(str="{c270f6b5-5c69-4290-9745-7a7f97169468}")||(str="{92FAA680-E704-4156-931A-E32D5BB38F3F}")||(str="{58EDCA55-2C3E-4980-B1B9-56C17F27A2A0}")||(str="{C7CB2637-E6C2-4D0C-85DE-4948C02175C7}")?NumPut(pSelf,pObj+0)*0:0x80004002 ; E_NOINTERFACE
}
_UIA_AddRef(pSelf){
}
_UIA_Release(pSelf){
}


/*
	UIA_Enum contains UIA constants and enumerations. 
	
	There are multiple ways to access the constants:
	1) Use the returned object of UIA_Interface:
		After UIA := UIA_Interface()
		UIA.UIA_InvokePatternId would return the corresponding ID of 10000. Similarly UIA.TreeScope_Descendants would return 0x4
		If a property starts with "UIA_" then that part may be omitted: UIA.ButtonControlTypeId would return 50000.
		
		Calling UIA_Enum methods is also supported:
		UIA.UIA_EventId(20000) would return "ToolTipOpened"
	2) Use UIA_Enum prototype. This requires using exact property and method names:
		UIA_Enum.UIA_InvokePatternId
		UIA_Enum.UIA_PatternId(10000)
	
	3) Use a UIA_Enum object:
		After UIAc := new UIA_Enum
		UIAc.InvokePatternId returns 10000
		UIAc.PatternId(10000) returns "InvokePattern"
	
	4) Use the UIA_Enum function:
		UIA_Enum("ButtonControlTypeId") would return 50000
*/

class UIA_Enum { ; main source: https://github.com/Ixiko/AHK-libs-and-classes-collection/blob/master/libs/o-z/UIAutomationClient_1_0_64bit.ahk

	__Get(member) {
		if member not in base 
		{
			if ((SubStr(member, 1, 4) != "UIA_") && ObjHasKey(UIA_Enum, "UIA_" member)) {
				return this["UIA_" member]
			}
		}
		return UIA_Enum.member
	}
	__Call(member, params*) {
		if member not in base 
		{
			if ((SubStr(member, 1, 4) != "UIA_") && IsFunc("UIA_Enum.UIA_" member))
				return this["UIA_" member](params*)
		}
	}

	; UIA_Interface specific enums, which define maximum available version numbers for interfaces (eg currently the highest version for UIA_Interface is 7). CurrentVersion specifies the version used by any new objects created, this can be changed dynamically.
	static UIA_MaxVersion_Interface := 7
	static UIA_MaxVersion_Element := 7
	static UIA_CurrentVersion_Element := 7
	static UIA_MaxVersion_TextRange := 3
	static UIA_CurrentVersion_TextRange := 3
	
	; The following are not strictly enumerations but constants, it makes more sense to include them here
	; module UIA_PatternIds
	static UIA_InvokePatternId := 10000
	static UIA_SelectionPatternId := 10001
	static UIA_ValuePatternId := 10002
	static UIA_RangeValuePatternId := 10003
	static UIA_ScrollPatternId := 10004
	static UIA_ExpandCollapsePatternId := 10005
	static UIA_GridPatternId := 10006
	static UIA_GridItemPatternId := 10007
	static UIA_MultipleViewPatternId := 10008
	static UIA_WindowPatternId := 10009
	static UIA_SelectionItemPatternId := 10010
	static UIA_DockPatternId := 10011
	static UIA_TablePatternId := 10012
	static UIA_TableItemPatternId := 10013
	static UIA_TextPatternId := 10014
	static UIA_TogglePatternId := 10015
	static UIA_TransformPatternId := 10016
	static UIA_ScrollItemPatternId := 10017
	static UIA_LegacyIAccessiblePatternId := 10018
	static UIA_ItemContainerPatternId := 10019
	static UIA_VirtualizedItemPatternId := 10020
	static UIA_SynchronizedInputPatternId := 10021
	static UIA_ObjectModelPatternId := 10022
	static UIA_AnnotationPatternId := 10023
	static UIA_TextPattern2Id := 10024
	static UIA_StylesPatternId := 10025
	static UIA_SpreadsheetPatternId := 10026
	static UIA_SpreadsheetItemPatternId := 10027
	static UIA_TransformPattern2Id := 10028
	static UIA_TextChildPatternId := 10029
	static UIA_DragPatternId := 10030
	static UIA_DropTargetPatternId := 10031
	static UIA_TextEditPatternId := 10032
	static UIA_CustomNavigationPatternId := 10033
	static UIA_SelectionPattern2Id := 10034 

	UIA_PatternId(n:="") {
		static name:={10000:"InvokePattern",10001:"SelectionPattern",10002:"ValuePattern",10003:"RangeValuePattern",10004:"ScrollPattern",10005:"ExpandCollapsePattern",10006:"GridPattern",10007:"GridItemPattern",10008:"MultipleViewPattern",10009:"WindowPattern",10010:"SelectionItemPattern",10011:"DockPattern",10012:"TablePattern",10013:"TableItemPattern",10014:"TextPattern",10015:"TogglePattern",10016:"TransformPattern",10017:"ScrollItemPattern",10018:"LegacyIAccessiblePattern",10019:"ItemContainerPattern",10020:"VirtualizedItemPattern",10021:"SynchronizedInputPattern",10022:"ObjectModelPattern",10023:"AnnotationPattern",10024:"TextPattern2",10025:"StylesPattern",10026:"SpreadsheetPattern",10027:"SpreadsheetItemPattern",10028:"TransformPattern2",10029:"TextChildPattern",10030:"DragPattern",10031:"DropTargetPattern",10032:"TextEditPattern",10033:"CustomNavigationPattern",10034:"SelectionPattern2"}, id:={InvokePattern:10000,SelectionPattern:10001,ValuePattern:10002,RangeValuePattern:10003,ScrollPattern:10004,ExpandCollapsePattern:10005,GridPattern:10006,GridItemPattern:10007,MultipleViewPattern:10008,WindowPattern:10009,SelectionItemPattern:10010,DockPattern:10011,TablePattern:10012,TableItemPattern:10013,TextPattern:10014,TogglePattern:10015,TransformPattern:10016,ScrollItemPattern:10017,LegacyIAccessiblePattern:10018,ItemContainerPattern:10019,VirtualizedItemPattern:10020,SynchronizedInputPattern:10021,ObjectModelPattern:10022,AnnotationPattern:10023,TextPattern2:10024,StylesPattern:10025,SpreadsheetPattern:10026,SpreadsheetItemPattern:10027,TransformPattern2:10028,TextChildPattern:10029,DragPattern:10030,DropTargetPattern:10031,TextEditPattern:10032,CustomNavigationPattern:10033,SelectionPattern2:10034}
		if !n
			return id
		if n is integer
			return name[n]
		if ObjHasKey(id, n "Pattern")
			return id[n "Pattern"]
		else if ObjHasKey(id, n)
			return id[n]
		return id[RegexReplace(n, "(?:UIA_)?(.+?)(?:Id)?$", "$1")]
	}

	; module UIA_EventIds
	static UIA_ToolTipOpenedEventId := 20000
	static UIA_ToolTipClosedEventId := 20001
	static UIA_StructureChangedEventId := 20002
	static UIA_MenuOpenedEventId := 20003
	static UIA_AutomationPropertyChangedEventId := 20004
	static UIA_AutomationFocusChangedEventId := 20005
	static UIA_AsyncContentLoadedEventId := 20006
	static UIA_MenuClosedEventId := 20007
	static UIA_LayoutInvalidatedEventId := 20008
	static UIA_Invoke_InvokedEventId := 20009
	static UIA_SelectionItem_ElementAddedToSelectionEventId := 20010
	static UIA_SelectionItem_ElementRemovedFromSelectionEventId := 20011
	static UIA_SelectionItem_ElementSelectedEventId := 20012
	static UIA_Selection_InvalidatedEventId := 20013
	static UIA_Text_TextSelectionChangedEventId := 20014
	static UIA_Text_TextChangedEventId := 20015
	static UIA_Window_WindowOpenedEventId := 20016
	static UIA_Window_WindowClosedEventId := 20017
	static UIA_MenuModeStartEventId := 20018
	static UIA_MenuModeEndEventId := 20019
	static UIA_InputReachedTargetEventId := 20020
	static UIA_InputReachedOtherElementEventId := 20021
	static UIA_InputDiscardedEventId := 20022
	static UIA_SystemAlertEventId := 20023
	static UIA_LiveRegionChangedEventId := 20024
	static UIA_HostedFragmentRootsInvalidatedEventId := 20025
	static UIA_Drag_DragStartEventId := 20026
	static UIA_Drag_DragCancelEventId := 20027
	static UIA_Drag_DragCompleteEventId := 20028
	static UIA_DropTarget_DragEnterEventId := 20029
	static UIA_DropTarget_DragLeaveEventId := 20030
	static UIA_DropTarget_DroppedEventId := 20031
	static UIA_TextEdit_TextChangedEventId := 20032
	static UIA_TextEdit_ConversionTargetChangedEventId := 20033
	static UIA_ChangesEventId := 20034
	static UIA_NotificationEventId := 20035
	static UIA_ActiveTextPositionChangedEventId := 20036

	UIA_EventId(n:="") {
		static id:={ToolTipOpened:20000,ToolTipClosed:20001,StructureChanged:20002,MenuOpened:20003,AutomationPropertyChanged:20004,AutomationFocusChanged:20005,AsyncContentLoaded:20006,MenuClosed:20007,LayoutInvalidated:20008,Invoke_Invoked:20009,SelectionItem_ElementAddedToSelection:20010,SelectionItem_ElementRemovedFromSelection:20011,SelectionItem_ElementSelected:20012,Selection_Invalidated:20013,Text_TextSelectionChanged:20014,Text_TextChanged:20015,Window_WindowOpened:20016,Window_WindowClosed:20017,MenuModeStart:20018,MenuModeEnd:20019,InputReachedTarget:20020,InputReachedOtherElement:20021,InputDiscarded:20022,SystemAlert:20023,LiveRegionChanged:20024,HostedFragmentRootsInvalidated:20025,Drag_DragStart:20026,Drag_DragCancel:20027,Drag_DragComplete:20028,DropTarget_DragEnter:20029,DropTarget_DragLeave:20030,DropTarget_Dropped:20031,TextEdit_TextChanged:20032,TextEdit_ConversionTargetChanged:20033,Changes:20034,Notification:20035,ActiveTextPositionChanged:20036}, name:={20000:"ToolTipOpened",20001:"ToolTipClosed",20002:"StructureChanged",20003:"MenuOpened",20004:"AutomationPropertyChanged",20005:"AutomationFocusChanged",20006:"AsyncContentLoaded",20007:"MenuClosed",20008:"LayoutInvalidated",20009:"Invoke_Invoked",20010:"SelectionItem_ElementAddedToSelection",20011:"SelectionItem_ElementRemovedFromSelection",20012:"SelectionItem_ElementSelected",20013:"Selection_Invalidated",20014:"Text_TextSelectionChanged",20015:"Text_TextChanged",20016:"Window_WindowOpened",20017:"Window_WindowClosed",20018:"MenuModeStart",20019:"MenuModeEnd",20020:"InputReachedTarget",20021:"InputReachedOtherElement",20022:"InputDiscarded",20023:"SystemAlert",20024:"LiveRegionChanged",20025:"HostedFragmentRootsInvalidated",20026:"Drag_DragStart",20027:"Drag_DragCancel",20028:"Drag_DragComplete",20029:"DropTarget_DragEnter",20030:"DropTarget_DragLeave",20031:"DropTarget_Dropped",20032:"TextEdit_TextChanged",20033:"TextEdit_ConversionTargetChanged",20034:"Changes",20035:"Notification",20036:"ActiveTextPositionChanged"}
		if !n
			return id
		if n is integer
			return name[n]
		if ObjHasKey(id, n)
			return id[n]
		return id[StrReplace(StrReplace(n, "EventId"), "UIA_")]
	}

	; module UIA_PropertyIds
	static UIA_RuntimeIdPropertyId := 30000
	static UIA_BoundingRectanglePropertyId := 30001
	static UIA_ProcessIdPropertyId := 30002
	static UIA_ControlTypePropertyId := 30003
	static UIA_LocalizedControlTypePropertyId := 30004
	static UIA_NamePropertyId := 30005
	static UIA_AcceleratorKeyPropertyId := 30006
	static UIA_AccessKeyPropertyId := 30007
	static UIA_HasKeyboardFocusPropertyId := 30008
	static UIA_IsKeyboardFocusablePropertyId := 30009
	static UIA_IsEnabledPropertyId := 30010
	static UIA_AutomationIdPropertyId := 30011
	static UIA_ClassNamePropertyId := 30012
	static UIA_HelpTextPropertyId := 30013
	static UIA_ClickablePointPropertyId := 30014
	static UIA_CulturePropertyId := 30015
	static UIA_IsControlElementPropertyId := 30016
	static UIA_IsContentElementPropertyId := 30017
	static UIA_LabeledByPropertyId := 30018
	static UIA_IsPasswordPropertyId := 30019
	static UIA_NativeWindowHandlePropertyId := 30020
	static UIA_ItemTypePropertyId := 30021
	static UIA_IsOffscreenPropertyId := 30022
	static UIA_OrientationPropertyId := 30023
	static UIA_FrameworkIdPropertyId := 30024
	static UIA_IsRequiredForFormPropertyId := 30025
	static UIA_ItemStatusPropertyId := 30026
	static UIA_IsDockPatternAvailablePropertyId := 30027
	static UIA_IsExpandCollapsePatternAvailablePropertyId := 30028
	static UIA_IsGridItemPatternAvailablePropertyId := 30029
	static UIA_IsGridPatternAvailablePropertyId := 30030
	static UIA_IsInvokePatternAvailablePropertyId := 30031
	static UIA_IsMultipleViewPatternAvailablePropertyId := 30032
	static UIA_IsRangeValuePatternAvailablePropertyId := 30033
	static UIA_IsScrollPatternAvailablePropertyId := 30034
	static UIA_IsScrollItemPatternAvailablePropertyId := 30035
	static UIA_IsSelectionItemPatternAvailablePropertyId := 30036
	static UIA_IsSelectionPatternAvailablePropertyId := 30037
	static UIA_IsTablePatternAvailablePropertyId := 30038
	static UIA_IsTableItemPatternAvailablePropertyId := 30039
	static UIA_IsTextPatternAvailablePropertyId := 30040
	static UIA_IsTogglePatternAvailablePropertyId := 30041
	static UIA_IsTransformPatternAvailablePropertyId := 30042
	static UIA_IsValuePatternAvailablePropertyId := 30043
	static UIA_IsWindowPatternAvailablePropertyId := 30044
	static UIA_ValueValuePropertyId := 30045
	static UIA_ValueIsReadOnlyPropertyId := 30046
	static UIA_RangeValueValuePropertyId := 30047
	static UIA_RangeValueIsReadOnlyPropertyId := 30048
	static UIA_RangeValueMinimumPropertyId := 30049
	static UIA_RangeValueMaximumPropertyId := 30050
	static UIA_RangeValueLargeChangePropertyId := 30051
	static UIA_RangeValueSmallChangePropertyId := 30052
	static UIA_ScrollHorizontalScrollPercentPropertyId := 30053
	static UIA_ScrollHorizontalViewSizePropertyId := 30054
	static UIA_ScrollVerticalScrollPercentPropertyId := 30055
	static UIA_ScrollVerticalViewSizePropertyId := 30056
	static UIA_ScrollHorizontallyScrollablePropertyId := 30057
	static UIA_ScrollVerticallyScrollablePropertyId := 30058
	static UIA_SelectionSelectionPropertyId := 30059
	static UIA_SelectionCanSelectMultiplePropertyId := 30060
	static UIA_SelectionIsSelectionRequiredPropertyId := 30061
	static UIA_GridRowCountPropertyId := 30062
	static UIA_GridColumnCountPropertyId := 30063
	static UIA_GridItemRowPropertyId := 30064
	static UIA_GridItemColumnPropertyId := 30065
	static UIA_GridItemRowSpanPropertyId := 30066
	static UIA_GridItemColumnSpanPropertyId := 30067
	static UIA_GridItemContainingGridPropertyId := 30068
	static UIA_DockDockPositionPropertyId := 30069
	static UIA_ExpandCollapseExpandCollapseStatePropertyId := 30070
	static UIA_MultipleViewCurrentViewPropertyId := 30071
	static UIA_MultipleViewSupportedViewsPropertyId := 30072
	static UIA_WindowCanMaximizePropertyId := 30073
	static UIA_WindowCanMinimizePropertyId := 30074
	static UIA_WindowWindowVisualStatePropertyId := 30075
	static UIA_WindowWindowInteractionStatePropertyId := 30076
	static UIA_WindowIsModalPropertyId := 30077
	static UIA_WindowIsTopmostPropertyId := 30078
	static UIA_SelectionItemIsSelectedPropertyId := 30079
	static UIA_SelectionItemSelectionContainerPropertyId := 30080
	static UIA_TableRowHeadersPropertyId := 30081
	static UIA_TableColumnHeadersPropertyId := 30082
	static UIA_TableRowOrColumnMajorPropertyId := 30083
	static UIA_TableItemRowHeaderItemsPropertyId := 30084
	static UIA_TableItemColumnHeaderItemsPropertyId := 30085
	static UIA_ToggleToggleStatePropertyId := 30086
	static UIA_TransformCanMovePropertyId := 30087
	static UIA_TransformCanResizePropertyId := 30088
	static UIA_TransformCanRotatePropertyId := 30089
	static UIA_IsLegacyIAccessiblePatternAvailablePropertyId := 30090
	static UIA_LegacyIAccessibleChildIdPropertyId := 30091
	static UIA_LegacyIAccessibleNamePropertyId := 30092
	static UIA_LegacyIAccessibleValuePropertyId := 30093
	static UIA_LegacyIAccessibleDescriptionPropertyId := 30094
	static UIA_LegacyIAccessibleRolePropertyId := 30095
	static UIA_LegacyIAccessibleStatePropertyId := 30096
	static UIA_LegacyIAccessibleHelpPropertyId := 30097
	static UIA_LegacyIAccessibleKeyboardShortcutPropertyId := 30098
	static UIA_LegacyIAccessibleSelectionPropertyId := 30099
	static UIA_LegacyIAccessibleDefaultActionPropertyId := 30100
	static UIA_AriaRolePropertyId := 30101
	static UIA_AriaPropertiesPropertyId := 30102
	static UIA_IsDataValidForFormPropertyId := 30103
	static UIA_ControllerForPropertyId := 30104
	static UIA_DescribedByPropertyId := 30105
	static UIA_FlowsToPropertyId := 30106
	static UIA_ProviderDescriptionPropertyId := 30107
	static UIA_IsItemContainerPatternAvailablePropertyId := 30108
	static UIA_IsVirtualizedItemPatternAvailablePropertyId := 30109
	static UIA_IsSynchronizedInputPatternAvailablePropertyId := 30110
	static UIA_OptimizeForVisualContentPropertyId := 30111
	static UIA_IsObjectModelPatternAvailablePropertyId := 30112
	static UIA_AnnotationAnnotationTypeIdPropertyId := 30113
	static UIA_AnnotationAnnotationTypeNamePropertyId := 30114
	static UIA_AnnotationAuthorPropertyId := 30115
	static UIA_AnnotationDateTimePropertyId := 30116
	static UIA_AnnotationTargetPropertyId := 30117
	static UIA_IsAnnotationPatternAvailablePropertyId := 30118
	static UIA_IsTextPattern2AvailablePropertyId := 30119
	static UIA_StylesStyleIdPropertyId := 30120
	static UIA_StylesStyleNamePropertyId := 30121
	static UIA_StylesFillColorPropertyId := 30122
	static UIA_StylesFillPatternStylePropertyId := 30123
	static UIA_StylesShapePropertyId := 30124
	static UIA_StylesFillPatternColorPropertyId := 30125
	static UIA_StylesExtendedPropertiesPropertyId := 30126
	static UIA_IsStylesPatternAvailablePropertyId := 30127
	static UIA_IsSpreadsheetPatternAvailablePropertyId := 30128
	static UIA_SpreadsheetItemFormulaPropertyId := 30129
	static UIA_SpreadsheetItemAnnotationObjectsPropertyId := 30130
	static UIA_SpreadsheetItemAnnotationTypesPropertyId := 30131
	static UIA_IsSpreadsheetItemPatternAvailablePropertyId := 30132
	static UIA_Transform2CanZoomPropertyId := 30133
	static UIA_IsTransformPattern2AvailablePropertyId := 30134
	static UIA_LiveSettingPropertyId := 30135
	static UIA_IsTextChildPatternAvailablePropertyId := 30136
	static UIA_IsDragPatternAvailablePropertyId := 30137
	static UIA_DragIsGrabbedPropertyId := 30138
	static UIA_DragDropEffectPropertyId := 30139
	static UIA_DragDropEffectsPropertyId := 30140
	static UIA_IsDropTargetPatternAvailablePropertyId := 30141
	static UIA_DropTargetDropTargetEffectPropertyId := 30142
	static UIA_DropTargetDropTargetEffectsPropertyId := 30143
	static UIA_DragGrabbedItemsPropertyId := 30144
	static UIA_Transform2ZoomLevelPropertyId := 30145
	static UIA_Transform2ZoomMinimumPropertyId := 30146
	static UIA_Transform2ZoomMaximumPropertyId := 30147
	static UIA_FlowsFromPropertyId := 30148
	static UIA_IsTextEditPatternAvailablePropertyId := 30149
	static UIA_IsPeripheralPropertyId := 30150
	static UIA_IsCustomNavigationPatternAvailablePropertyId := 30151
	static UIA_PositionInSetPropertyId := 30152
	static UIA_SizeOfSetPropertyId := 30153
	static UIA_LevelPropertyId := 30154
	static UIA_AnnotationTypesPropertyId := 30155
	static UIA_AnnotationObjectsPropertyId := 30156
	static UIA_LandmarkTypePropertyId := 30157
	static UIA_LocalizedLandmarkTypePropertyId := 30158
	static UIA_FullDescriptionPropertyId := 30159
	static UIA_FillColorPropertyId := 30160
	static UIA_OutlineColorPropertyId := 30161
	static UIA_FillTypePropertyId := 30162
	static UIA_VisualEffectsPropertyId := 30163
	static UIA_OutlineThicknessPropertyId := 30164
	static UIA_CenterPointPropertyId := 30165
	static UIA_RotationPropertyId := 30166
	static UIA_SizePropertyId := 30167
	static UIA_IsSelectionPattern2AvailablePropertyId := 30168
	static UIA_Selection2FirstSelectedItemPropertyId := 30169
	static UIA_Selection2LastSelectedItemPropertyId := 30170
	static UIA_Selection2CurrentSelectedItemPropertyId := 30171
	static UIA_Selection2ItemCountPropertyId := 30172
	static UIA_HeadingLevelPropertyId := 30173
	static UIA_IsDialogPropertyId := 30174

	UIA_PropertyId(n:="") {
		local
		static ids:="RuntimeId:30000,BoundingRectangle:30001,ProcessId:30002,ControlType:30003,LocalizedControlType:30004,Name:30005,AcceleratorKey:30006,AccessKey:30007,HasKeyboardFocus:30008,IsKeyboardFocusable:30009,IsEnabled:30010,AutomationId:30011,ClassName:30012,HelpText:30013,ClickablePoint:30014,Culture:30015,IsControlElement:30016,IsContentElement:30017,LabeledBy:30018,IsPassword:30019,NativeWindowHandle:30020,ItemType:30021,IsOffscreen:30022,Orientation:30023,FrameworkId:30024,IsRequiredForForm:30025,ItemStatus:30026,IsDockPatternAvailable:30027,IsExpandCollapsePatternAvailable:30028,IsGridItemPatternAvailable:30029,IsGridPatternAvailable:30030,IsInvokePatternAvailable:30031,IsMultipleViewPatternAvailable:30032,IsRangeValuePatternAvailable:30033,IsScrollPatternAvailable:30034,IsScrollItemPatternAvailable:30035,IsSelectionItemPatternAvailable:30036,IsSelectionPatternAvailable:30037,IsTablePatternAvailable:30038,IsTableItemPatternAvailable:30039,IsTextPatternAvailable:30040,IsTogglePatternAvailable:30041,IsTransformPatternAvailable:30042,IsValuePatternAvailable:30043,IsWindowPatternAvailable:30044,ValueValue:30045,ValueIsReadOnly:30046,RangeValueValue:30047,RangeValueIsReadOnly:30048,RangeValueMinimum:30049,RangeValueMaximum:30050,RangeValueLargeChange:30051,RangeValueSmallChange:30052,ScrollHorizontalScrollPercent:30053,ScrollHorizontalViewSize:30054,ScrollVerticalScrollPercent:30055,ScrollVerticalViewSize:30056,ScrollHorizontallyScrollable:30057,ScrollVerticallyScrollable:30058,SelectionSelection:30059,SelectionCanSelectMultiple:30060,SelectionIsSelectionRequired:30061,GridRowCount:30062,GridColumnCount:30063,GridItemRow:30064,GridItemColumn:30065,GridItemRowSpan:30066,GridItemColumnSpan:30067,GridItemContainingGrid:30068,DockDockPosition:30069,ExpandCollapseExpandCollapseState:30070,MultipleViewCurrentView:30071,MultipleViewSupportedViews:30072,WindowCanMaximize:30073,WindowCanMinimize:30074,WindowWindowVisualState:30075,WindowWindowInteractionState:30076,WindowIsModal:30077,WindowIsTopmost:30078,SelectionItemIsSelected:30079,SelectionItemSelectionContainer:30080,TableRowHeaders:30081,TableColumnHeaders:30082,TableRowOrColumnMajor:30083,TableItemRowHeaderItems:30084,TableItemColumnHeaderItems:30085,ToggleToggleState:30086,TransformCanMove:30087,TransformCanResize:30088,TransformCanRotate:30089,IsLegacyIAccessiblePatternAvailable:30090,LegacyIAccessibleChildId:30091,LegacyIAccessibleName:30092,LegacyIAccessibleValue:30093,LegacyIAccessibleDescription:30094,LegacyIAccessibleRole:30095,LegacyIAccessibleState:30096,LegacyIAccessibleHelp:30097,LegacyIAccessibleKeyboardShortcut:30098,LegacyIAccessibleSelection:30099,LegacyIAccessibleDefaultAction:30100,AriaRole:30101,AriaProperties:30102,IsDataValidForForm:30103,ControllerFor:30104,DescribedBy:30105,FlowsTo:30106,ProviderDescription:30107,IsItemContainerPatternAvailable:30108,IsVirtualizedItemPatternAvailable:30109,IsSynchronizedInputPatternAvailable:30110,OptimizeForVisualContent:30111,IsObjectModelPatternAvailable:30112,AnnotationAnnotationTypeId:30113,AnnotationAnnotationTypeName:30114,AnnotationAuthor:30115,AnnotationDateTime:30116,AnnotationTarget:30117,IsAnnotationPatternAvailable:30118,IsTextPattern2Available:30119,StylesStyleId:30120,StylesStyleName:30121,StylesFillColor:30122,StylesFillPatternStyle:30123,StylesShape:30124,StylesFillPatternColor:30125,StylesExtendedProperties:30126,IsStylesPatternAvailable:30127,IsSpreadsheetPatternAvailable:30128,SpreadsheetItemFormula:30129,SpreadsheetItemAnnotationObjects:30130,SpreadsheetItemAnnotationTypes:30131,IsSpreadsheetItemPatternAvailable:30132,Transform2CanZoom:30133,IsTransformPattern2Available:30134,LiveSetting:30135,IsTextChildPatternAvailable:30136,IsDragPatternAvailable:30137,DragIsGrabbed:30138,DragDropEffect:30139,DragDropEffects:30140,IsDropTargetPatternAvailable:30141,DropTargetDropTargetEffect:30142,DropTargetDropTargetEffects:30143,DragGrabbedItems:30144,Transform2ZoomLevel:30145,Transform2ZoomMinimum:30146,Transform2ZoomMaximum:30147,FlowsFrom:30148,IsTextEditPatternAvailable:30149,IsPeripheral:30150,IsCustomNavigationPatternAvailable:30151,PositionInSet:30152,SizeOfSet:30153,Level:30154,AnnotationTypes:30155,AnnotationObjects:30156,LandmarkType:30157,LocalizedLandmarkType:30158,FullDescription:30159,FillColor:30160,OutlineColor:30161,FillType:30162,VisualEffects:30163,OutlineThickness:30164,CenterPoint:30165,Rotation:30166,Size:30167,IsSelectionPattern2Available:30168,Selection2FirstSelectedItem:30169,Selection2LastSelectedItem:30170,Selection2CurrentSelectedItem:30171,Selection2ItemCount:30173,IsDialog:30174"
		if !n
			return ids		
		if n is integer 
		{
			RegexMatch(ids, "([^,]+):" n, m)
			return m1
		}
		
		n := StrReplace(StrReplace(n, "UIA_"), "PropertyId")
		if (SubStr(n,1,7) = "Current")
			n := SubStr(n,8)
		RegexMatch(ids, "i)(?:^|,)" n "(?:" n ")?(?:Id)?:(\d+)", m)
		if (!m1 && (n = "type"))
			return 30003
		return m1
	}

	UIA_PropertyVariantType(id){
		static type:={30000:0x2003,30001:0x2005,30002:3,30003:3,30004:8,30005:8,30006:8,30007:8,30008:0xB,30009:0xB,30010:0xB,30011:8,30012:8,30013:8,30014:0x2005,30015:3,30016:0xB,30017:0xB,30018:0xD,30019:0xB,30020:3,30021:8,30022:0xB,30023:3,30024:8,30025:0xB,30026:8,30027:0xB,30028:0xB,30029:0xB,30030:0xB,30031:0xB,30032:0xB,30033:0xB,30034:0xB,30035:0xB,30036:0xB,30037:0xB,30038:0xB,30039:0xB,30040:0xB,30041:0xB,30042:0xB,30043:0xB,30044:0xB,30045:8,30046:0xB,30047:5,30048:0xB,30049:5,30050:5,30051:5,30052:5,30053:5,30054:5,30055:5,30056:5,30057:0xB,30058:0xB,30059:0x200D,30060:0xB,30061:0xB,30062:3,30063:3,30064:3,30065:3,30066:3,30067:3,30068:0xD,30069:3,30070:3,30071:3,30072:0x2003,30073:0xB,30074:0xB,30075:3,30076:3,30077:0xB,30078:0xB,30079:0xB,30080:0xD,30081:0x200D,30082:0x200D,30083:0x2003,30084:0x200D,30085:0x200D,30086:3,30087:0xB,30088:0xB,30089:0xB,30090:0xB,30091:3,30092:8,30093:8,30094:8,30095:3,30096:3,30097:8,30098:8,30099:0x200D,30100:8}, type2:={30101:8,30102:8,30103:0xB,30104:0xD,30105:0xD,30106:0xD,30107:8,30108:0xB,30109:0xB,30110:0xB,30111:0xB,30112:0xB,30113:3,30114:8,30115:8,30116:8,30117:0xD,30118:0xB,30119:0xB,30120:3,30121:8,30122:3,30123:8,30124:8,30125:3,30126:8,30127:0xB,30128:0xB,30129:8,30130:0x200D,30131:0x2003,30132:0xB,30133:0xB,30134:0xB,30135:3,30136:0xB,30137:0xB,30138:0xB,30139:8,30140:0x2008,30141:0xB,30142:8,30143:0x2008,30144:0x200D,30145:5,30146:5,30147:5,30148:0x200D,30149:0xB,30150:0xB,30151:0xB,30152:3,30153:3,30154:3,30155:0x2003,30156:0x2003,30157:3,30158:8,30159:8,30160:3,30161:0x2003,30162:3,30163:3,30164:0x2005,30165:0x2005,30166:5,30167:0x2005,30168:0xB} ; missing VTs from 30169 and on
		return ObjHasKey(type, id) ? type[id] : type2[id]
	}

	; module UIA_TextAttributeIds
	static UIA_AnimationStyleAttributeId := 40000
	static UIA_BackgroundColorAttributeId := 40001
	static UIA_BulletStyleAttributeId := 40002
	static UIA_CapStyleAttributeId := 40003
	static UIA_CultureAttributeId := 40004
	static UIA_FontNameAttributeId := 40005
	static UIA_FontSizeAttributeId := 40006
	static UIA_FontWeightAttributeId := 40007
	static UIA_ForegroundColorAttributeId := 40008
	static UIA_HorizontalTextAlignmentAttributeId := 40009
	static UIA_IndentationFirstLineAttributeId := 40010
	static UIA_IndentationLeadingAttributeId := 40011
	static UIA_IndentationTrailingAttributeId := 40012
	static UIA_IsHiddenAttributeId := 40013
	static UIA_IsItalicAttributeId := 40014
	static UIA_IsReadOnlyAttributeId := 40015
	static UIA_IsSubscriptAttributeId := 40016
	static UIA_IsSuperscriptAttributeId := 40017
	static UIA_MarginBottomAttributeId := 40018
	static UIA_MarginLeadingAttributeId := 40019
	static UIA_MarginTopAttributeId := 40020
	static UIA_MarginTrailingAttributeId := 40021
	static UIA_OutlineStylesAttributeId := 40022
	static UIA_OverlineColorAttributeId := 40023
	static UIA_OverlineStyleAttributeId := 40024
	static UIA_StrikethroughColorAttributeId := 40025
	static UIA_StrikethroughStyleAttributeId := 40026
	static UIA_TabsAttributeId := 40027
	static UIA_TextFlowDirectionsAttributeId := 40028
	static UIA_UnderlineColorAttributeId := 40029
	static UIA_UnderlineStyleAttributeId := 40030
	static UIA_AnnotationTypesAttributeId := 40031
	static UIA_AnnotationObjectsAttributeId := 40032
	static UIA_StyleNameAttributeId := 40033
	static UIA_StyleIdAttributeId := 40034
	static UIA_LinkAttributeId := 40035
	static UIA_IsActiveAttributeId := 40036
	static UIA_SelectionActiveEndAttributeId := 40037
	static UIA_CaretPositionAttributeId := 40038
	static UIA_CaretBidiModeAttributeId := 40039
	static UIA_LineSpacingAttributeId := 40040
	static UIA_BeforeParagraphSpacingAttributeId := 40041
	static UIA_AfterParagraphSpacingAttributeId := 40042
	static UIA_SayAsInterpretAsAttributeId := 40043

	UIA_AttributeId(n:="") {
		static id:={AnimationStyle:40000,BackgroundColor:40001,BulletStyle:40002,CapStyle:40003,Culture:40004,FontName:40005,FontSize:40006,FontWeight:40007,ForegroundColor:40008,HorizontalTextAlignment:40009,IndentationFirstLine:40010,IndentationLeading:40011,IndentationTrailing:40012,IsHidden:40013,IsItalic:40014,IsReadOnly:40015,IsSubscript:40016,IsSuperscript:40017,MarginBottom:40018,MarginLeading:40019,MarginTop:40020,MarginTrailing:40021,OutlineStyles:40022,OverlineColor:40023,OverlineStyle:40024,StrikethroughColor:40025,StrikethroughStyle:40026,Tabs:40027,TextFlowDirections:40028,UnderlineColor:40029,UnderlineStyle:40030,AnnotationTypes:40031,AnnotationObjects:40032,StyleName:40033,StyleId:40034,Link:40035,IsActive:40036,SelectionActiveEnd:40037,CaretPosition:40038,CaretBidiMode:40039,LineSpacing:40040,BeforeParagraphSpacing:40041,AfterParagraphSpacing:40042,SayAsInterpretAs:40043}, name:={40000:"AnimationStyle",40001:"BackgroundColor",40002:"BulletStyle",40003:"CapStyle",40004:"Culture",40005:"FontName",40006:"FontSize",40007:"FontWeight",40008:"ForegroundColor",40009:"HorizontalTextAlignment",40010:"IndentationFirstLine",40011:"IndentationLeading",40012:"IndentationTrailing",40013:"IsHidden",40014:"IsItalic",40015:"IsReadOnly",40016:"IsSubscript",40017:"IsSuperscript",40018:"MarginBottom",40019:"MarginLeading",40020:"MarginTop",40021:"MarginTrailing",40022:"OutlineStyles",40023:"OverlineColor",40024:"OverlineStyle",40025:"StrikethroughColor",40026:"StrikethroughStyle",40027:"Tabs",40028:"TextFlowDirections",40029:"UnderlineColor",40030:"UnderlineStyle",40031:"AnnotationTypes",40032:"AnnotationObjects",40033:"StyleName",40034:"StyleId",40035:"Link",40036:"IsActive",40037:"SelectionActiveEnd",40038:"CaretPosition",40039:"CaretBidiMode",40040:"LineSpacing",40041:"BeforeParagraphSpacing",40042:"AfterParagraphSpacing",40043:"SayAsInterpretAs"}
		if !n
			return id
		if n is integer
			return name[n]
		if ObjHasKey(id, n)
			return id[n]
		return id[StrReplace(StrReplace(n, "AttributeId"), "UIA_")]
	}

	UIA_AttributeVariantType(id){
		Static type:={40000:3,40001:3,40002:3,40003:3,40004:3,40005:8,40006:5,40007:3,40008:3,40009:3,40010:5,40011:5,40012:5,40013:0xB,40014:0xB,40015:0xB,40016:0xB,40017:0xB,40018:5,40019:5,40020:5,40021:5,40022:3,40023:3,40024:3,40025:3,40026:3,40027:0x2005,40028:3,40029:3,40030:3,40031:0x2003,40032:0x200D,40033:8,40034:3,40035:0xD,40036:0xB,40037:3,40038:3,40039:3,40040:8,40041:5,40042:5,40043:8} ; 40032 and 40043 might be incorrect
		return type[id]
	}

	; module UIA_ControlTypeIds
	static UIA_ButtonControlTypeId := 50000
	static UIA_CalendarControlTypeId := 50001
	static UIA_CheckBoxControlTypeId := 50002
	static UIA_ComboBoxControlTypeId := 50003
	static UIA_EditControlTypeId := 50004
	static UIA_HyperlinkControlTypeId := 50005
	static UIA_ImageControlTypeId := 50006
	static UIA_ListItemControlTypeId := 50007
	static UIA_ListControlTypeId := 50008
	static UIA_MenuControlTypeId := 50009
	static UIA_MenuBarControlTypeId := 50010
	static UIA_MenuItemControlTypeId := 50011
	static UIA_ProgressBarControlTypeId := 50012
	static UIA_RadioButtonControlTypeId := 50013
	static UIA_ScrollBarControlTypeId := 50014
	static UIA_SliderControlTypeId := 50015
	static UIA_SpinnerControlTypeId := 50016
	static UIA_StatusBarControlTypeId := 50017
	static UIA_TabControlTypeId := 50018
	static UIA_TabItemControlTypeId := 50019
	static UIA_TextControlTypeId := 50020
	static UIA_ToolBarControlTypeId := 50021
	static UIA_ToolTipControlTypeId := 50022
	static UIA_TreeControlTypeId := 50023
	static UIA_TreeItemControlTypeId := 50024
	static UIA_CustomControlTypeId := 50025
	static UIA_GroupControlTypeId := 50026
	static UIA_ThumbControlTypeId := 50027
	static UIA_DataGridControlTypeId := 50028
	static UIA_DataItemControlTypeId := 50029
	static UIA_DocumentControlTypeId := 50030
	static UIA_SplitButtonControlTypeId := 50031
	static UIA_WindowControlTypeId := 50032
	static UIA_PaneControlTypeId := 50033
	static UIA_HeaderControlTypeId := 50034
	static UIA_HeaderItemControlTypeId := 50035
	static UIA_TableControlTypeId := 50036
	static UIA_TitleBarControlTypeId := 50037
	static UIA_SeparatorControlTypeId := 50038
	static UIA_SemanticZoomControlTypeId := 50039
	static UIA_AppBarControlTypeId := 50040

	UIA_ControlTypeId(n:="") {
		static id:={Button:50000,Calendar:50001,CheckBox:50002,ComboBox:50003,Edit:50004,Hyperlink:50005,Image:50006,ListItem:50007,List:50008,Menu:50009,MenuBar:50010,MenuItem:50011,ProgressBar:50012,RadioButton:50013,ScrollBar:50014,Slider:50015,Spinner:50016,StatusBar:50017,Tab:50018,TabItem:50019,Text:50020,ToolBar:50021,ToolTip:50022,Tree:50023,TreeItem:50024,Custom:50025,Group:50026,Thumb:50027,DataGrid:50028,DataItem:50029,Document:50030,SplitButton:50031,Window:50032,Pane:50033,Header:50034,HeaderItem:50035,Table:50036,TitleBar:50037,Separator:50038,SemanticZoom:50039,AppBar:50040}, name:={50000:"Button",50001:"Calendar",50002:"CheckBox",50003:"ComboBox",50004:"Edit",50005:"Hyperlink",50006:"Image",50007:"ListItem",50008:"List",50009:"Menu",50010:"MenuBar",50011:"MenuItem",50012:"ProgressBar",50013:"RadioButton",50014:"ScrollBar",50015:"Slider",50016:"Spinner",50017:"StatusBar",50018:"Tab",50019:"TabItem",50020:"Text",50021:"ToolBar",50022:"ToolTip",50023:"Tree",50024:"TreeItem",50025:"Custom",50026:"Group",50027:"Thumb",50028:"DataGrid",50029:"DataItem",50030:"Document",50031:"SplitButton",50032:"Window",50033:"Pane",50034:"Header",50035:"HeaderItem",50036:"Table",50037:"TitleBar",50038:"Separator",50039:"SemanticZoom",50040:"AppBar"}
		if !n
			return id
		if n is integer
			return name[n]
		if ObjHasKey(id, n)
			return id[n]
		return id[StrReplace(StrReplace(n, "ControlTypeId"), "UIA_")]
	}

; module AnnotationType
	static UIA_AnnotationType_Unknown := 60000
	static UIA_AnnotationType_SpellingError := 60001
	static UIA_AnnotationType_GrammarError := 60002
	static UIA_AnnotationType_Comment := 60003
	static UIA_AnnotationType_FormulaError := 60004
	static UIA_AnnotationType_TrackChanges := 60005
	static UIA_AnnotationType_Header := 60006
	static UIA_AnnotationType_Footer := 60007
	static UIA_AnnotationType_Highlighted := 60008
	static UIA_AnnotationType_Endnote := 60009
	static UIA_AnnotationType_Footnote := 60010
	static UIA_AnnotationType_InsertionChange := 60011
	static UIA_AnnotationType_DeletionChange := 60012
	static UIA_AnnotationType_MoveChange := 60013
	static UIA_AnnotationType_FormatChange := 60014
	static UIA_AnnotationType_UnsyncedChange := 60015
	static UIA_AnnotationType_EditingLockedChange := 60016
	static UIA_AnnotationType_ExternalChange := 60017
	static UIA_AnnotationType_ConflictingChange := 60018
	static UIA_AnnotationType_Author := 60019
	static UIA_AnnotationType_AdvancedProofingIssue := 60020
	static UIA_AnnotationType_DataValidationError := 60021
	static UIA_AnnotationType_CircularReferenceError := 60022
	static UIA_AnnotationType_Mathematics := 60023

	UIA_AnnotationType(n:="") {
		static id:={Unknown:60000,SpellingError:60001,GrammarError:60002,Comment:60003,FormulaError:60004,TrackChanges:60005,Header:60006,Footer:60007,Highlighted:60008,Endnote:60009,Footnote:60010,InsertionChange:60011,DeletionChange:60012,MoveChange:60013,FormatChange:60014,UnsyncedChange:60015,EditingLockedChange:60016,ExternalChange:60017,ConflictingChange:60018,Author:60019,AdvancedProofingIssue:60020,DataValidationError:60021,CircularReferenceError:60022,Mathematics:60023}, name:={60000:"Unknown",60001:"SpellingError",60002:"GrammarError",60003:"Comment",60004:"FormulaError",60005:"TrackChanges",60006:"Header",60007:"Footer",60008:"Highlighted",60009:"Endnote",60010:"Footnote",60011:"InsertionChange",60012:"DeletionChange",60013:"MoveChange",60014:"FormatChange",60015:"UnsyncedChange",60016:"EditingLockedChange",60017:"ExternalChange",60018:"ConflictingChange",60019:"Author",60020:"AdvancedProofingIssue",60021:"DataValidationError",60022:"CircularReferenceError",60023:"Mathematics"}
		if !n
			return id
		if n is integer
			return name[n]
		if ObjHasKey(id, n)
			return id[n]
		return id[StrSplit(n, "_").Pop()]
	}

	; module StyleId
	static UIA_StyleId_Custom := 70000
	static UIA_StyleId_Heading1 := 70001
	static UIA_StyleId_Heading2 := 70002
	static UIA_StyleId_Heading3 := 70003
	static UIA_StyleId_Heading4 := 70004
	static UIA_StyleId_Heading5 := 70005
	static UIA_StyleId_Heading6 := 70006
	static UIA_StyleId_Heading7 := 70007
	static UIA_StyleId_Heading8 := 70008
	static UIA_StyleId_Heading9 := 70009
	static UIA_StyleId_Title := 70010
	static UIA_StyleId_Subtitle := 70011
	static UIA_StyleId_Normal := 70012
	static UIA_StyleId_Emphasis := 70013
	static UIA_StyleId_Quote := 70014
	static UIA_StyleId_BulletedList := 70015
	static UIA_StyleId_NumberedList := 70016

	UIA_StyleId(n:="") {
		static id:={Custom:70000,Heading1:70001,Heading2:70002,Heading3:70003,Heading4:70004,Heading5:70005,Heading6:70006,Heading7:70007,Heading8:70008,Heading9:70009,Title:70010,Subtitle:70011,Normal:70012,Emphasis:70013,Quote:70014,BulletedList:70015,NumberedList:70016}, name:={70000:"Custom",70001:"Heading1",70002:"Heading2",70003:"Heading3",70004:"Heading4",70005:"Heading5",70006:"Heading6",70007:"Heading7",70008:"Heading8",70009:"Heading9",70010:"Title",70011:"Subtitle",70012:"Normal",70013:"Emphasis",70014:"Quote",70015:"BulletedList",70016:"NumberedList"}
		if !n
			return id
		if n is integer
			return name[n]
		if ObjHasKey(id, n)
			return id[n]
		return id[StrSplit(n, "_").Pop()]
	}

	; module LandmarkTypeIds
	static UIA_CustomLandmarkTypeId := 80000
	static UIA_FormLandmarkTypeId := 80001
	static UIA_MainLandmarkTypeId := 80002
	static UIA_NavigationLandmarkTypeId := 80003
	static UIA_SearchLandmarkTypeId := 80004
	
	UIA_LandmarkTypeId(n:="") {
		static id:={Custom:80000,Form:80001,Main:80002,Navigation:80003,Search:80004}, name:={80000:"Custom",80001:"Form",80002:"Main",80003:"Navigation",80004:"Search"}
		if !n
			return id
		if n is integer
			return name[n]
		if ObjHasKey(id, n)
			return id[n]
		return id[StrReplace(StrReplace(n, "LandmarkTypeId"), "UIA_")]
	}
 
	; module HeadingLevelIds
	static UIA_HeadingLevel_None := 80050
	static UIA_HeadingLevel1 := 80051
	static UIA_HeadingLevel2 := 80052
	static UIA_HeadingLevel3 := 80053
	static UIA_HeadingLevel4 := 80054
	static UIA_HeadingLevel5 := 80055
	static UIA_HeadingLevel6 := 80056
	static UIA_HeadingLevel7 := 80057
	static UIA_HeadingLevel8 := 80058
	static UIA_HeadingLevel9 := 80059

	UIA_HeadingLevel(n:="") {
		static id:={None:80050, 1:80051, 2:80052, 3:80053, 4:80054, 5:80055, 6:80056, 7:80057, 8:80058, 9:80059}, name:={80050:"None", 80051:"1", 80052:"2", 80053:"3", 80054:"4", 80055:"5", 80056:"6", 80057:"7", 80058:"8", 80059:"9"}
		if !n
			return id
		if n is integer
			return (n > 80000)?name[n]:id[n]
		if ObjHasKey(id, n)
			return id[n]
		return id[StrReplace(StrReplace(n, "HeadingLevel"), "UIA_")]
	}

	; module ChangeIds
	static UIA_SummaryChangeId := 90000
	
	UIA_ChangeId(n:="") {
		static id:={Summary:90000}, name:={90000:"Summary"}
		if !n
			return id
		if n is integer
			return name[n]
		if ObjHasKey(id, n)
			return id[n]
		return id[StrReplace(StrReplace(n, "ChangeId"), "UIA_")]
	}

	; module MetadataIds
	static UIA_SayAsInterpretAsMetadataId := 100000
	
	UIA_MetadataId(n:="") {
		static id:={SayAsInterpretAs:100000}, name:={100000:"SayAsInterpretAs"}
		if !n
			return id
		if n is integer
			return name[n]
		if ObjHasKey(id, n)
			return id[n]
		return id[StrReplace(StrReplace(n, "MetadataId"), "UIA_")]
	}


	; Uiautomationcoreapi.h enumerations
	; enum AsyncContentLoadedState Contains values that describe the progress of asynchronous loading of content.
	static AsyncContentLoadedState_Beginning := 0
	static AsyncContentLoadedState_Progress := 1
	static AsyncContentLoadedState_Completed := 2
	
	AsyncContentLoadedState(Value:="") {
		static v1:={0:"Beginning", 1:"Progress", 2:"Completed"}
		if Value is not integer
			return this["AsyncContentLoadedState_" Value]
		return (Value=="")?v1:v1[Value]
	}
	
	; enum AutomationIdentifierType Contains values used in the UiaLookupId function
	static AutomationIdentifierType_Property := 0
	static AutomationIdentifierType_Pattern := 1
	static AutomationIdentifierType_Event := 2
	static AutomationIdentifierType_ControlType := 3
	static AutomationIdentifierType_TextAttribute := 4
	static AutomationIdentifierType_LandmarkType := 5
	static AutomationIdentifierType_Annotation := 6
	static AutomationIdentifierType_Changes := 7
	static AutomationIdentifierType_Style := 8

	AutomationIdentifierType(Value:="") {
		static v1:={0:"Property", 1:"Pattern", 2:"Event", 3:"ControlType", 4:"TextAttribute", 5:"LandmarkType", 6:"Annotation", 7:"Changes", 8:"Style"}
		if Value is not integer
			return this["AutomationIdentifierType_" Value]
		return (Value=="")?v1:v1[Value]
	}
	
	; enum ConditionType Contains values that specify a type of UiaCondition.
	static ConditionType_True := 0
	static ConditionType_False := 1
	static ConditionType_Property := 2
	static ConditionType_And := 3
	static ConditionType_Or := 4
	static ConditionType_Not := 5

	ConditionType(Value:="") {
		static v1:={0:"True", 1:"False", 2:"Property", 3:"And", 4:"Or", 5:"Not"}
		if Value is not integer
			return this["ConditionType_" Value]
		return (Value=="")?v1:v1[Value]
	}
	
	; enum EventArgsType
	static EventArgsType_Simple := 0
	static EventArgsType_PropertyChanged := 1
	static EventArgsType_StructureChanged := 2
	static EventArgsType_AsyncContentLoaded := 3
	static EventArgsType_WindowClosed := 4
	static EventArgsType_TextEditTextChanged := 5
	static EventArgsType_Changes := 6
	static EventArgsType_Notification := 7
	static EventArgsType_ActiveTextPositionChanged := 8
	static EventArgsType_StructuredMarkup := 9

	EventArgsType(Value:="") {
		static v1:={0:"Simple", 1:"PropertyChanged", 2:"StructureChanged", 3:"AsyncContentLoaded", 4:"WindowClosed", 5:"TextEditTextChanged", 6:"Changes", 7:"Notification", 8:"ActiveTextPositionChanged", 9:"StructuredMarkup"}
		if Value is not integer
			return this["EventArgsType_" Value]
		return (Value=="")?v1:v1[Value]
	}

	; Uiautomationclient.h enumerations
	
	; enum AutomationElementMode Contains values that specify the type of reference to use when returning UI Automation elements.
	static AutomationElementMode_None := 0x0
	static AutomationElementMode_Full := 0x1

	AutomationElementMode(Value:="") {
		static v1:={0x0:"None", 0x1:"Full"}
		if Value is not integer
			return this["AutomationElementMode_" Value]
		return (Value=="")?v1:v1[Value]
	}

	; enum CoalesceEventsOptions Contains possible values for the CoalesceEvents property, which indicates whether an accessible technology client receives all events, or a subset where duplicate events are detected and filtered.
	static CoalesceEventsOptions_Disabled := 0x0
	static CoalesceEventsOptions_Enabled := 0x1

	CoalesceEventsOptions(Value:="") {
		static v1:={0x0:"Disabled", 0x1:"Enabled"}
		if Value is not integer
			return this["CoalesceEventsOptions_" Value]
		return (Value=="")?v1:v1[Value]
	}

	; enum ConnectionRecoveryBehaviorOptions Contains possible values for the ConnectionRecoveryBehavior property, which indicates whether an accessible technology client adjusts provider request timeouts when the provider is non-responsive.
	static ConnectionRecoveryBehaviorOptions_Disabled := 0
	static ConnectionRecoveryBehaviorOptions_Enabled := 0x1

	ConnectionRecoveryBehaviorOptions(Value:="") {
		static v1:={0x0:"Disabled", 0x1:"Enabled"}
		if Value is not integer
			return this["ConnectionRecoveryBehaviorOptions_" Value]
		return (Value=="")?v1:v1[Value]
	}

	; enum PropertyConditionFlags Contains values used in creating property conditions.
	static PropertyConditionFlags_None := 0x0
	static PropertyConditionFlags_IgnoreCase := 0x1
	static PropertyConditionFlags_MatchSubstring = 0x2

	PropertyConditionFlags(Value:="") {
		static v1:={0x0:"None", 0x1:"IgnoreCase", 0x2:"MatchSubstring"}
		if Value is not integer
			return this["PropertyConditionFlags_" Value]
		return (Value=="")?v1:v1[Value]
	}

	; enum TreeScope Contains values that specify the scope of various operations in the Microsoft UI Automation tree.
	static TreeScope_None := 0x0
	static TreeScope_Element := 0x1
	static TreeScope_Children := 0x2
	static TreeScope_Descendants := 0x4
	static TreeScope_Parent := 0x8
	static TreeScope_Ancestors := 0x10
	static TreeScope_Subtree := 0x7

	TreeScope(Value:="") {
		static v1:={0x0:"None", 0x1:"Element", 0x2:"Children", 0x4:"Descendants", 0x8:"Parent", 0x10:"Ancestors", 0x7:"Subtree"}
		if Value is not integer
			return this["TreeScope_" Value]
		return (Value=="")?v1:v1[Value]
	}

	;enum TreeTraversalOptions Defines values that can be used to customize tree navigation order.
	static TreeTraversalOptions_Default := 0x0
	static TreeTraversalOptions_PostOrder := 0x1
	static TreeTraversalOptions_LastToFirstOrder := 0x2

	TreeTraversalOptions(Value:="") {
		static v1:={0x0:"Default", 0x1:"PostOrder", 0x2:"LastToFirstOrder"}
		if Value is not integer
			return this["TreeTraversalOptions_" Value]
		return (Value=="")?v1:v1[Value]
	}
	
	; Uiautomationcore.h enumerations

	; enum ActiveEnd Contains possible values for the SelectionActiveEnd text attribute, which indicates the location of the caret relative to a text range that represents the currently selected text.
	static ActiveEnd_None := 0
	static ActiveEnd_Start := 1
	static ActiveEnd_End := 2

	ActiveEnd(Value:="") {
		static v1:={0x0:"None", 0x1:"Start", 0x2:"End"}
		if Value is not integer
			return this["ActiveEnd_" Value]
		return (Value=="")?v1:v1[Value]
	}

	; enum AnimationStyle Contains values for the AnimationStyle text attribute.
	static AnimationStyle_None := 0
	static AnimationStyle_LasVegasLights := 1
	static AnimationStyle_BlinkingBackground := 2
	static AnimationStyle_SparkleText := 3
	static AnimationStyle_MarchingBlackAnts := 4
	static AnimationStyle_MarchingRedAnts := 5
	static AnimationStyle_Shimmer := 6
	static AnimationStyle_Other := -1

	AnimationStyle(Value:="") {
		static v1:={0:"None", 1:"LasVegasLights",2:"BlinkingBackground", 3:"SparkleText",4:"MarchingBlackAnts", 5:"MarchingRedAnts", 6:"Shimmer", -1:"Other"}
		if Value is not integer
			return this["AnimationStyle_" Value]
		return (Value=="")?v1:v1[Value]
	}

	; enum BulletStyle Contains values for the BulletStyle text attribute.
	static BulletStyle_None := 0
	static BulletStyle_HollowRoundBullet := 1
	static BulletStyle_FilledRoundBullet := 2
	static BulletStyle_HollowSquareBullet := 3
	static BulletStyle_FilledSquareBullet := 4
	static BulletStyle_DashBullet := 5
	static BulletStyle_Other := -1

	BulletStyle(Value:="") {
		static v1:={0:"None", 1:"HollowRoundBullet",2:"FilledRoundBullet", 3:"HollowSquareBullet",4:"FilledSquareBullet", 5:"DashBullet", -1:"Other"}
		if Value is not integer
			return this["BulletStyle_" Value]
		return (Value=="")?v1:v1[Value]
	}
	
	; enum CapStyle Contains values that specify the value of the CapStyle text attribute.
	static CapStyle_None := 0
	static CapStyle_SmallCap := 1
	static CapStyle_AllCap := 2
	static CapStyle_AllPetiteCaps := 3
	static CapStyle_PetiteCaps := 4
	static CapStyle_Unicase := 5
	static CapStyle_Titling := 6
	static CapStyle_Other := -1
	
	CapStyle(Value:="") {
		static v1:={0:"None", 1:"SmallCap",2:"AllCap", 3:"AllPetiteCaps",4:"PetiteCaps", 5:"Unicase",6:"Titling", -1:"Other"}
		if Value is not integer
			return this["CapStyle_" Value]
		return (Value=="")?v1:v1[Value]
	}
	
	; enum CaretBidiMode Contains possible values for the CaretBidiMode text attribute, which indicates whether the caret is in text that flows from left to right, or from right to left.
	static CaretBidiMode_LTR := 0
	static CaretBidiMode_RTL := 1

	CaretBidiMode(Value:="") {
		static v1:={0:"LTR", 1:"RTL"}
		if Value is not integer
			return this["CaretBidiMode_" Value]
		return (Value=="")?v1:v1[Value]
	}
	
	; enum CaretPosition Contains possible values for the CaretPosition text attribute, which indicates the location of the caret relative to a line of text in a text range.
	static CaretPosition_Unknown := 0
	static CaretPosition_EndOfLine := 1
	static CaretPosition_BeginningOfLine := 2
	
	CaretPosition(Value:="") {
		static v1:={0:"Unknown", 1:"EndOfLine", 2:"BeginningOfLine"}
		if Value is not integer
			return this["CaretPosition_" Value]
		return (Value=="")?v1:v1[Value]
	}
	
	; enum DockPosition Contains values that specify the location of a docking window represented by the Dock control pattern.
	static DockPosition_Top := 0x0
	static DockPosition_Left := 0x1
	static DockPosition_Bottom := 0x2
	static DockPosition_Right := 0x3
	static DockPosition_Fill := 0x4
	static DockPosition_None := 0x5

	DockPosition(Value:="") {
		static v1:={0x0:"Top", 0x1:"Left", 0x2:"Bottom", 0x3:"Right", 0x4:"Fill", 0x5:"None"}
		if Value is not integer
			return this["DockPosition_" Value]
		return (Value=="")?v1:v1[Value]
	}

	; enum ExpandCollapseState Contains values that specify the state of a UI element that can be expanded and collapsed.	
	static ExpandCollapseState_Collapsed := 0x0
	static ExpandCollapseState_Expanded := 0x1
	static ExpandCollapseState_PartiallyExpanded := 0x2
	static ExpandCollapseState_LeafNode := 0x3

	ExpandCollapseState(Value:="") {
		static v1:={0x0:"Collapsed", 0x1:"Expanded", 0x2:"PartiallyExpanded", 0x3:"LeafNode"}
		if Value is not integer
			return this["ExpandCollapseState_" Value]
		return (Value=="")?v1:v1[Value]
	}	
	
	; enum FillType Contains values for the FillType attribute.
	static FillType_None := 0
	static FillType_Color := 1
	static FillType_Gradient := 2
	static FillType_Picture := 3
	static FillType_Pattern := 4

	FillType(Value:="") {
		static v1:={0x0:"None", 0x1:"Color", 0x2:"Gradient", 0x3:"Picture", 0x4:"Pattern"}
		if Value is not integer
			return this["FillType_" Value]
		return (Value=="")?v1:v1[Value]
	}
	
	; enum FlowDirection Contains values for the TextFlowDirections text attribute.
	static FlowDirections_Default := 0
	static FlowDirections_RightToLeft := 0x1
	static FlowDirections_BottomToTop := 0x2
	static FlowDirections_Vertical := 0x4

	FlowDirection(Value:="") {
		static v1:={0x0:"Default", 0x1:"RightToLeft", 0x2:"BottomToTop", 0x4:"Vertical"}
		if Value is not integer
			return this["FlowDirection_" Value]
		return (Value=="")?v1:v1[Value]
	}

	;enum LiveSetting Contains possible values for the LiveSetting property. This property is implemented by provider elements that are part of a live region.
	static LiveSetting_Off := 0x0
	static LiveSetting_Polite := 0x1
	static LiveSetting_Assertive := 0x2

	LiveSetting(Value:="") {
		static v1:={0x0:"Off", 0x1:"Polite", 0x2:"Assertive"}
		if Value is not integer
			return this["LiveSetting_" Value]
		return (Value=="")?v1:v1[Value]
	}

	; enum NavigateDirection Contains values used to specify the direction of navigation within the Microsoft UI Automation tree.
	static NavigateDirection_Parent := 0x0
	static NavigateDirection_NextSibling := 0x1
	static NavigateDirection_PreviousSibling := 0x2
	static NavigateDirection_FirstChild := 0x3
	static NavigateDirection_LastChild := 0x4

	NavigateDirection(Value:="") {
		static v1:={0x0:"Parent", 0x1:"NextSibling", 0x2:"PreviousSibling", 0x3:"FirstChild", 0x4:"LastChild"}
		if Value is not integer
			return this["NavigateDirection_" Value]
		return (Value=="")?v1:v1[Value]
	}
	
	; enum NotificationKind Defines values that indicate the type of a notification event, and a hint to the listener about the processing of the event. 
	static NotificationKind_ItemAdded := 0
	static NotificationKind_ItemRemoved := 1
	static NotificationKind_ActionCompleted := 2
	static NotificationKind_ActionAborted := 3
	static NotificationKind_Other := 4
	
	NotificationKind(Value:="") {
		static v1:={0x0:"ItemAdded", 0x1:"ItemRemoved", 0x2:"ActionCompleted", 0x3:"ActionAborted", 0x4:"Other"}
		if Value is not integer
			return this["NotificationKind_" Value]
		return (Value=="")?v1:v1[Value]
	}
	
	; enum NotificationProcessing Defines values that indicate how a notification should be processed.
	static NotificationProcessing_ImportantAll := 0
	static NotificationProcessing_ImportantMostRecent := 1
	static NotificationProcessing_All := 2
	static NotificationProcessing_MostRecent := 3
	static NotificationProcessing_CurrentThenMostRecent := 4

	NotificationProcessing(Value:="") {
		static v1:={0x0:"ImportantAll", 0x1:"ImportantMostRecent", 0x2:"All", 0x3:"MostRecent", 0x4:"CurrentThenMostRecent"}
		if Value is not integer
			return this["NotificationProcessing_" Value]
		return (Value=="")?v1:v1[Value]
	}	

	; enum OrientationType Contains values that specify the orientation of a control.
	static OrientationType_None := 0x0
	static OrientationType_Horizontal := 0x1
	static OrientationType_Vertical := 0x2

	OrientationType(Value:="") {
		static v1:={0x0:"None", 0x1:"Horizontal", 0x2:"Vertical"}
		if Value is not integer
			return this["OrientationType_" Value]
		return (Value=="")?v1:v1[Value]
	}
	
	; enum OutlineStyles Contains values for the OutlineStyle text attribute.
	static OutlineStyles_None := 0
	static OutlineStyles_Outline := 1
	static OutlineStyles_Shadow := 2
	static OutlineStyles_Engraved := 4
	static OutlineStyles_Embossed := 8
	
	OutlineStyles(Value:="") {
		static v1:={0:"None", 1:"Outline", 2:"Shadow", 4:"Engraved", 8:"Embossed"}
		if Value is not integer
			return this["OutlineStyles_" Value]
		return (Value=="")?v1:v1[Value]
	}

	;enum ProviderOptions
	static ProviderOptions_ClientSideProvider := 0x1
	static ProviderOptions_ServerSideProvider := 0x2
	static ProviderOptions_NonClientAreaProvider := 0x4
	static ProviderOptions_OverrideProvider := 0x8
	static ProviderOptions_ProviderOwnsSetFocus := 0x10
	static ProviderOptions_UseComThreading := 0x20
	static ProviderOptions_RefuseNonClientSupport := 0x40
	static ProviderOptions_HasNativeIAccessible := 0x80
	static ProviderOptions_UseClientCoordinates := 0x100

	ProviderOptions(Value:="") {
		static v1:={0x1:"ClientSideProvider", 0x2:"ServerSideProvider", 0x4:"NonClientAreaProvider", 0x8:"OverrideProvider", 0x10:"ProviderOwnsSetFocus", 0x20:"UseComThreading", 0x40:"RefuseNonClientSupport", 0x80:"HasNativeIAccessible", 0x100:"UseClientCoordinates"}
		if Value is not integer
			return this["ProviderOptions_" Value]
		return (Value=="")?v1:v1[Value]
	}	

	; enum RowOrColumnMajor Contains values that specify whether data in a table should be read primarily by row or by column.	
	static RowOrColumnMajor_RowMajor := 0x0
	static RowOrColumnMajor_ColumnMajor := 0x1
	static RowOrColumnMajor_Indeterminate := 0x2

	RowOrColumnMajor(Value:="") {
		static v1:={0x0:"RowMajor", 0x1:"ColumnMajor", 0x2:"Indeterminate"}
		if Value is not integer
			return this["RowOrColumnMajor_" Value]
		return (Value=="")?v1:v1[Value]
	}	
	
	; enum SayAsInterpretAs Defines the values that indicate how a text-to-speech engine should interpret specific data.
	static SayAsInterpretAs_None := 0
	static SayAsInterpretAs_Spell := 1
	static SayAsInterpretAs_Cardinal := 2
	static SayAsInterpretAs_Ordinal := 3
	static SayAsInterpretAs_Number := 4
	static SayAsInterpretAs_Date := 5
	static SayAsInterpretAs_Time := 6
	static SayAsInterpretAs_Telephone := 7
	static SayAsInterpretAs_Currency := 8
	static SayAsInterpretAs_Net := 9
	static SayAsInterpretAs_Url := 10
	static SayAsInterpretAs_Address := 11
	static SayAsInterpretAs_Alphanumeric := 12
	static SayAsInterpretAs_Name := 13
	static SayAsInterpretAs_Media := 14
	static SayAsInterpretAs_Date_MonthDayYear := 15
	static SayAsInterpretAs_Date_DayMonthYear := 16
	static SayAsInterpretAs_Date_YearMonthDay := 17
	static SayAsInterpretAs_Date_YearMonth := 18
	static SayAsInterpretAs_Date_MonthYear := 19
	static SayAsInterpretAs_Date_DayMonth := 20
	static SayAsInterpretAs_Date_MonthDay := 21
	static SayAsInterpretAs_Date_Year := 22
	static SayAsInterpretAs_Time_HoursMinutesSeconds12 := 23
	static SayAsInterpretAs_Time_HoursMinutes12 := 24
	static SayAsInterpretAs_Time_HoursMinutesSeconds24 := 25
	static SayAsInterpretAs_Time_HoursMinutes24 := 26
	
	SayAsInterpretAs(Value:="") {
		static v1:={0:"None", 1:"Spell", 2:"Cardinal", 3:"Ordinal", 4:"Number", 5:"Date", 6:"Time", 7:"Telephone", 8:"Currency", 9:"Net", 10:"Url", 11:"Address", 13:"Name", 14:"Media", 15:"Date_MonthDayYear", 16:"Date_DayMonthYear", 17:"Date_YearMonthDay", 18:"Date_YearMonth", 19:"Date_MonthYear", 20:"Date_DayMonth", 21:"Date_MonthDay", 22:"Date_Year", 23:"Time_HoursMinutesSeconds12", 24:"Time_HoursMinutes12", 25:"Time_HoursMinutesSeconds24", 26:"Time_HoursMinutes24"}
		if Value is not integer
			return this["SayAsInterpretAs_" Value]
		return (Value=="")?v1:v1[Value]
	}

	; enum ScrollAmount Contains values that specify the direction and distance to scroll.	
	static ScrollAmount_LargeDecrement := 0x0
	static ScrollAmount_SmallDecrement := 0x1
	static ScrollAmount_NoAmount := 0x2
	static ScrollAmount_LargeIncrement := 0x3
	static ScrollAmount_SmallIncrement := 0x4

	ScrollAmount(Value:="") {
		static v1:={0x0:"LargeDecrement", 0x1:"SmallDecrement", 0x2:"NoAmount", 0x3:"LargeIncrement", 0x4:"SmallIncrement"}
		if Value is not integer
			return this["ScrollAmount_" Value]
		return (Value=="")?v1:v1[Value]
	}	
	
	; enum StructureChangeType Contains values that specify the type of change in the Microsoft UI Automation tree structure.	
	static StructureChangeType_ChildAdded := 0x0
	static StructureChangeType_ChildRemoved := 0x1
	static StructureChangeType_ChildrenInvalidated := 0x2
	static StructureChangeType_ChildrenBulkAdded := 0x3
	static StructureChangeType_ChildrenBulkRemoved := 0x4
	static StructureChangeType_ChildrenReordered := 0x5

	StructureChangeType(Value:="") {
		static v1:={0x0:"ChildAdded", 0x1:"ChildRemoved", 0x2:"ChildrenInvalidated", 0x3:"ChildrenBulkAdded", 0x4:"ChildrenBulkRemoved", 0x5:"ChildrenReordered"}
		if Value is not integer
			return this["StructureChangeType_" Value]
		return (Value=="")?v1:v1[Value]
	}

	; enum SupportedTextSelection Contains values that specify the supported text selection attribute.	
	static SupportedTextSelection_None := 0x0
	static SupportedTextSelection_Single := 0x1
	static SupportedTextSelection_Multiple := 0x2

	SupportedTextSelection(Value:="") {
		static v1:={0x0:"None", 0x1:"Single", 0x2:"Multiple"}
		if Value is not integer
			return this["SupportedTextSelection_" Value]
		return (Value=="")?v1:v1[Value]
	}	

	; enum SynchronizedInputType Contains values that specify the type of synchronized input.	
	static SynchronizedInputType_KeyUp := 0x1
	static SynchronizedInputType_KeyDown := 0x2
	static SynchronizedInputType_LeftMouseUp := 0x4
	static SynchronizedInputType_LeftMouseDown := 0x8
	static SynchronizedInputType_RightMouseUp := 0x10
	static SynchronizedInputType_RightMouseDown := 0x20

	SynchronizedInputType(Value:="") {
		static v1:={0x1:"KeyUp", 0x2:"KeyDown", 0x4:"LeftMouseUp", 0x8:"LeftMouseDown", 0x10:"RightMouseUp", 0x20:"RightMouseDown"}
		if Value is not integer
			return this["SynchronizedInputType_" Value]
		return (Value=="")?v1:v1[Value]
	}	

	; enum TextDecorationLineStyle Contains values that specify the OverlineStyle, StrikethroughStyle, and UnderlineStyle text attributes.
	static TextDecorationLineStyle_None := 0
	static TextDecorationLineStyle_Single := 1
	static TextDecorationLineStyle_WordsOnly := 2
	static TextDecorationLineStyle_Double := 3
	static TextDecorationLineStyle_Dot := 4
	static TextDecorationLineStyle_Dash := 5
	static TextDecorationLineStyle_DashDot := 6
	static TextDecorationLineStyle_DashDotDot := 7
	static TextDecorationLineStyle_Wavy := 8
	static TextDecorationLineStyle_ThickSingle := 9
	static TextDecorationLineStyle_DoubleWavy := 11
	static TextDecorationLineStyle_ThickWavy := 12
	static TextDecorationLineStyle_LongDash := 13
	static TextDecorationLineStyle_ThickDash := 14
	static TextDecorationLineStyle_ThickDashDot := 15
	static TextDecorationLineStyle_ThickDashDotDot := 16
	static TextDecorationLineStyle_ThickDot := 17
	static TextDecorationLineStyle_ThickLongDash := 18
	static TextDecorationLineStyle_Other := -1

	TextDecorationLineStyle(Value:="") {
		static v1:={0:"None", 1:"Single", 2:"WordsOnly", 3:"Double", 4:"Dot", 5:"Dash", 6:"DashDot", 7:"DashDotDot", 8:"Wavy", 9:"ThickSingle", 11:"DoubleWavy", 12:"ThickWavy", 13:"LongDash", 14:"ThickDash", 15:"ThickDashDot", 16:"ThickDashDotDot", 17:"ThickDot", 18:"ThickLongDash", -1:"Other"}
		if Value is not integer
			return this["TextDecorationLineStyle_" Value]
		return (Value=="")?v1:v1[Value]
	}

	; enum TextEditChangeType Describes the text editing change being performed by controls when text-edit events are raised or handled.
	static TextEditChangeType_None := 0x0
	static TextEditChangeType_AutoCorrect := 0x1
	static TextEditChangeType_Composition := 0x2
	static TextEditChangeType_CompositionFinalized := 0x3
	static TextEditChangeType_AutoComplete := 0x4

	TextEditChangeType(Value:="") {
		static v1:={0x0:"None", 0x1:"AutoCorrect", 0x2:"Composition", 0x3:"CompositionFinalized", 0x4:"AutoComplete"}
		if Value is not integer
			return this["TextEditChangeType_" Value]
		return (Value=="")?v1:v1[Value]
	}

	; enum TextPatternRangeEndpoint Contains values that specify the endpoints of a text range.
	static TextPatternRangeEndpoint_Start := 0x0
	static TextPatternRangeEndpoint_End := 0x1

	TextPatternRangeEndpoint(Value:="") {
		static v1:={0x0:"Start", 0x1:"End"}
		if Value is not integer
			return this["TextPatternRangeEndpoint_" Value]
		return (Value=="")?v1:v1[Value]
	}

	; enum TextUnit Contains values that specify units of text for the purposes of navigation.	
	static TextUnit_Character := 0x0
	static TextUnit_Format := 0x1
	static TextUnit_Word := 0x2
	static TextUnit_Line := 0x3
	static TextUnit_Paragraph := 0x4
	static TextUnit_Page := 0x5
	static TextUnit_Document := 0x6

	TextUnit(Value:="") {
		static v1:={0x0:"Character", 0x1:"Format", 0x2:"Word", 0x3:"Line", 0x4:"Paragraph", 0x5:"Page", 0x6:"Document"}
		if Value is not integer
			return this["TextUnit_" Value]
		return (Value=="")?v1:v1[Value]
	}	
	
	; enum ToggleState Contains values that specify the toggle state of a Microsoft UI Automation element that implements the Toggle control pattern.
	static ToggleState_Off := 0x0
	static ToggleState_On := 0x1
	static ToggleState_Indeterminate := 0x2

	ToggleState(Value:="") {
		static v1:={0x0:"Off", 0x1:"On", 0x2:"Indeterminate"}
		if Value is not integer
			return this["ToggleState_" Value]
		return (Value=="")?v1:v1[Value]
	}

	;enum ZoomUnit Contains possible values for the IUIAutomationTransformPattern2::ZoomByUnit method, which zooms the viewport of a control by the specified unit.
	static ZoomUnit_NoAmount := 0x0
	static ZoomUnit_LargeDecrement := 0x1
	static ZoomUnit_SmallDecrement := 0x2
	static ZoomUnit_LargeIncrement := 0x3
	static ZoomUnit_SmallIncrement := 0x4

	ZoomUnit(Value:="") {
		static v1:={0x0:"NoAmount", 0x1:"LargeDecrement", 0x2:"SmallDecrement", 0x3:"LargeIncrement", 0x4:"SmallIncrement"}
		if Value is not integer
			return this["ZoomUnit_" Value]
		return (Value=="")?v1:v1[Value]
	}

	; enum WindowVisualState Contains values that specify the visual state of a window.
	static WindowVisualState_Normal := 0x0
	static WindowVisualState_Maximized := 0x1
	static WindowVisualState_Minimized := 0x2

	WindowVisualState(Value:="") {
		static v1:={0x0:"Normal", 0x1:"Maximized", 0x2:"Minimized"}
		if Value is not integer
			return this["WindowVisualState_" Value]
		return (Value=="")?v1:v1[Value]
	}

	; enum WindowInteractionState Contains values that specify the current state of the window for purposes of user interaction.
	static WindowInteractionState_Running := 0x0
	static WindowInteractionState_Closing := 0x1
	static WindowInteractionState_ReadyForUserInteraction := 0x2
	static WindowInteractionState_BlockedByModalWindow := 0x3
	static WindowInteractionState_NotResponding := 0x4

	WindowInteractionState(Value:="") {
		static v1:={0x0:"Running", 0x1:"Closing", 0x2:"ReadyForUserInteraction", 0x3:"BlockedByModalWindow", 0x4:"NotResponding"}
		if Value is not integer
			return this["WindowInteractionState_" Value]
		return (Value=="")?v1:v1[Value]
	}
}

class IAccessible_Enum { ; from UIA2.ahk (https://github.com/neptercn/UIAutomation/blob/master/UIA2.ahk)
	; enum SELFLAG specify how an accessible object becomes selected or takes the focus. http://msdn.microsoft.com/en-us/library/dd373634(v=vs.85).aspx
	static SELFLAG_NONE := 0
	static SELFLAG_TAKEFOCUS := 0x1
	static SELFLAG_TAKESELECTION := 0x2
	static SELFLAG_EXTENDSELECTION := 0x4
	static SELFLAG_ADDSELECTION := 0x8
	static SELFLAG_REMOVESELECTION := 0x10
	static SELFLAG_VALID := 0x1f
	
	; enum Roles describe the roles of various UI objects in an application. http://msdn.microsoft.com/en-us/library/dd373608%28v=vs.85%29.aspx
	static ROLE_SYSTEM_TITLEBAR := 0x1
	static ROLE_SYSTEM_MENUBAR := 0x2
	static ROLE_SYSTEM_SCROLLBAR := 0x3
	static ROLE_SYSTEM_GRIP := 0x4
	static ROLE_SYSTEM_SOUND := 0x5
	static ROLE_SYSTEM_CURSOR := 0x6
	static ROLE_SYSTEM_CARET := 0x7
	static ROLE_SYSTEM_ALERT := 0x8
	static ROLE_SYSTEM_WINDOW := 0x9
	static ROLE_SYSTEM_CLIENT := 0xa
	static ROLE_SYSTEM_MENUPOPUP := 0xb
	static ROLE_SYSTEM_MENUITEM := 0xc
	static ROLE_SYSTEM_TOOLTIP := 0xd
	static ROLE_SYSTEM_APPLICATION := 0xe
	static ROLE_SYSTEM_DOCUMENT := 0xf
	static ROLE_SYSTEM_PANE := 0x10
	static ROLE_SYSTEM_CHART := 0x11
	static ROLE_SYSTEM_DIALOG := 0x12
	static ROLE_SYSTEM_BORDER := 0x13
	static ROLE_SYSTEM_GROUPING := 0x14
	static ROLE_SYSTEM_SEPARATOR := 0x15
	static ROLE_SYSTEM_TOOLBAR := 0x16
	static ROLE_SYSTEM_STATUSBAR := 0x17
	static ROLE_SYSTEM_TABLE := 0x18
	static ROLE_SYSTEM_COLUMNHEADER := 0x19
	static ROLE_SYSTEM_ROWHEADER := 0x1a
	static ROLE_SYSTEM_COLUMN := 0x1b
	static ROLE_SYSTEM_ROW := 0x1c
	static ROLE_SYSTEM_CELL := 0x1d
	static ROLE_SYSTEM_LINK := 0x1e
	static ROLE_SYSTEM_HELPBALLOON := 0x1f
	static ROLE_SYSTEM_CHARACTER := 0x20
	static ROLE_SYSTEM_LIST := 0x21
	static ROLE_SYSTEM_LISTITEM := 0x22
	static ROLE_SYSTEM_OUTLINE := 0x23
	static ROLE_SYSTEM_OUTLINEITEM := 0x24
	static ROLE_SYSTEM_PAGETAB := 0x25
	static ROLE_SYSTEM_PROPERTYPAGE := 0x26
	static ROLE_SYSTEM_INDICATOR := 0x27
	static ROLE_SYSTEM_GRAPHIC := 0x28
	static ROLE_SYSTEM_STATICTEXT := 0x29
	static ROLE_SYSTEM_TEXT := 0x2a
	static ROLE_SYSTEM_PUSHBUTTON := 0x2b
	static ROLE_SYSTEM_CHECKBUTTON := 0x2c
	static ROLE_SYSTEM_RADIOBUTTON := 0x2d
	static ROLE_SYSTEM_COMBOBOX := 0x2e
	static ROLE_SYSTEM_DROPLIST := 0x2f
	static ROLE_SYSTEM_PROGRESSBAR := 0x30
	static ROLE_SYSTEM_DIAL := 0x31
	static ROLE_SYSTEM_HOTKEYFIELD := 0x32
	static ROLE_SYSTEM_SLIDER := 0x33
	static ROLE_SYSTEM_SPINBUTTON := 0x34
	static ROLE_SYSTEM_DIAGRAM := 0x35
	static ROLE_SYSTEM_ANIMATION := 0x36
	static ROLE_SYSTEM_EQUATION := 0x37
	static ROLE_SYSTEM_BUTTONDROPDOWN := 0x38
	static ROLE_SYSTEM_BUTTONMENU := 0x39
	static ROLE_SYSTEM_BUTTONDROPDOWNGRID := 0x3a
	static ROLE_SYSTEM_WHITESPACE := 0x3b
	static ROLE_SYSTEM_PAGETABLIST := 0x3c
	static ROLE_SYSTEM_CLOCK := 0x3d
	static ROLE_SYSTEM_SPLITBUTTON := 0x3e
	static ROLE_SYSTEM_IPADDRESS := 0x3f
	static ROLE_SYSTEM_OUTLINEBUTTON := 0x40
	
	; enum State describe the state of objects in an application UI. http://msdn.microsoft.com/en-us/library/dd373609%28v=vs.85%29.aspx
	static STATE_SYSTEM_NORMAL := 0
	static STATE_SYSTEM_UNAVAILABLE := 0x1
	static STATE_SYSTEM_SELECTED := 0x2
	static STATE_SYSTEM_FOCUSED := 0x4
	static STATE_SYSTEM_PRESSED := 0x8
	static STATE_SYSTEM_CHECKED := 0x10
	static STATE_SYSTEM_MIXED := 0x20
	static STATE_SYSTEM_INDETERMINATE := 0x20
	static STATE_SYSTEM_READONLY := 0x40
	static STATE_SYSTEM_HOTTRACKED := 0x80
	static STATE_SYSTEM_DEFAULT := 0x100
	static STATE_SYSTEM_EXPANDED := 0x200
	static STATE_SYSTEM_COLLAPSED := 0x400
	static STATE_SYSTEM_BUSY := 0x800
	static STATE_SYSTEM_FLOATING := 0x1000
	static STATE_SYSTEM_MARQUEED := 0x2000
	static STATE_SYSTEM_ANIMATED := 0x4000
	static STATE_SYSTEM_INVISIBLE := 0x8000
	static STATE_SYSTEM_OFFSCREEN := 0x10000
	static STATE_SYSTEM_SIZEABLE := 0x20000
	static STATE_SYSTEM_MOVEABLE := 0x40000
	static STATE_SYSTEM_SELFVOICING := 0x80000
	static STATE_SYSTEM_FOCUSABLE := 0x100000
	static STATE_SYSTEM_SELECTABLE := 0x200000
	static STATE_SYSTEM_LINKED := 0x400000
	static STATE_SYSTEM_TRAVERSED := 0x800000
	static STATE_SYSTEM_MULTISELECTABLE := 0x1000000
	static STATE_SYSTEM_EXTSELECTABLE := 0x2000000
	static STATE_SYSTEM_ALERT_LOW := 0x4000000
	static STATE_SYSTEM_ALERT_MEDIUM := 0x8000000
	static STATE_SYSTEM_ALERT_HIGH := 0x10000000
	static STATE_SYSTEM_PROTECTED := 0x20000000
	static STATE_SYSTEM_VALID := 0x7fffffff
	static STATE_SYSTEM_HASPOPUP := 0x40000000
	
	; enum Event describes the events that are generated by the operating system and by server applications. http://msdn.microsoft.com/en-us/library/dd318066%28v=vs.85%29.aspx
	static EVENT_MIN := 0x00000001
	static EVENT_MAX := 0x7FFFFFFF
	static EVENT_SYSTEM_SOUND := 0x0001
	static EVENT_SYSTEM_ALERT := 0x0002
	static EVENT_SYSTEM_FOREGROUND := 0x0003
	static EVENT_SYSTEM_MENUSTART := 0x0004
	static EVENT_SYSTEM_MENUEND := 0x0005
	static EVENT_SYSTEM_MENUPOPUPSTART := 0x0006
	static EVENT_SYSTEM_MENUPOPUPEND := 0x0007
	static EVENT_SYSTEM_CAPTURESTART := 0x0008
	static EVENT_SYSTEM_CAPTUREEND := 0x0009
	static EVENT_SYSTEM_MOVESIZESTART := 0x000A
	static EVENT_SYSTEM_MOVESIZEEND := 0x000B
	static EVENT_SYSTEM_CONTEXTHELPSTART := 0x000C
	static EVENT_SYSTEM_CONTEXTHELPEND := 0x000D
	static EVENT_SYSTEM_DRAGDROPSTART := 0x000E
	static EVENT_SYSTEM_DRAGDROPEND := 0x000F
	static EVENT_SYSTEM_DIALOGSTART := 0x0010
	static EVENT_SYSTEM_DIALOGEND := 0x0011
	static EVENT_SYSTEM_SCROLLINGSTART := 0x0012
	static EVENT_SYSTEM_SCROLLINGEND := 0x0013
	static EVENT_SYSTEM_SWITCHSTART := 0x0014
	static EVENT_SYSTEM_SWITCHEND := 0x0015
	static EVENT_SYSTEM_MINIMIZESTART := 0x0016
	static EVENT_SYSTEM_MINIMIZEEND := 0x0017
	static EVENT_SYSTEM_DESKTOPSWITCH := 0x0020
	static EVENT_SYSTEM_END := 0x00FF
	static EVENT_OEM_DEFINED_START := 0x0101
	static EVENT_OEM_DEFINED_END := 0x01FF
	static EVENT_UIA_EVENTID_START := 0x4E00
	static EVENT_UIA_EVENTID_END := 0x4EFF
	static EVENT_UIA_PROPID_START := 0x7500
	static EVENT_UIA_PROPID_END := 0x75FF
	static EVENT_CONSOLE_CARET := 0x4001
	static EVENT_CONSOLE_UPDATE_REGION := 0x4002
	static EVENT_CONSOLE_UPDATE_SIMPLE := 0x4003
	static EVENT_CONSOLE_UPDATE_SCROLL := 0x4004
	static EVENT_CONSOLE_LAYOUT := 0x4005
	static EVENT_CONSOLE_START_APPLICATION := 0x4006
	static EVENT_CONSOLE_END_APPLICATION := 0x4007
	static EVENT_CONSOLE_END := 0x40FF
	static EVENT_OBJECT_CREATE := 0x8000
	static EVENT_OBJECT_DESTROY := 0x8001
	static EVENT_OBJECT_SHOW := 0x8002
	static EVENT_OBJECT_HIDE := 0x8003
	static EVENT_OBJECT_REORDER := 0x8004
	static EVENT_OBJECT_FOCUS := 0x8005
	static EVENT_OBJECT_SELECTION := 0x8006
	static EVENT_OBJECT_SELECTIONADD := 0x8007
	static EVENT_OBJECT_SELECTIONREMOVE := 0x8008
	static EVENT_OBJECT_SELECTIONWITHIN := 0x8009
	static EVENT_OBJECT_STATECHANGE := 0x800A
	static EVENT_OBJECT_LOCATIONCHANGE := 0x800B
	static EVENT_OBJECT_NAMECHANGE := 0x800C
	static EVENT_OBJECT_DESCRIPTIONCHANGE := 0x800D
	static EVENT_OBJECT_VALUECHANGE := 0x800E
	static EVENT_OBJECT_PARENTCHANGE := 0x800F
	static EVENT_OBJECT_HELPCHANGE := 0x8010
	static EVENT_OBJECT_DEFACTIONCHANGE := 0x8011
	static EVENT_OBJECT_ACCELERATORCHANGE := 0x8012
	static EVENT_OBJECT_INVOKED := 0x8013
	static EVENT_OBJECT_TEXTSELECTIONCHANGED := 0x8014
	static EVENT_OBJECT_CONTENTSCROLLED := 0x8015
	static EVENT_SYSTEM_ARRANGMENTPREVIEW := 0x8016
	static EVENT_OBJECT_END := 0x80FF
	static EVENT_AIA_START := 0xA000
	static EVENT_AIA_END := 0xAFFF
	
	; enum Navigation indicate the spatial (up, down, left, and right) or logical (first child, last, next, and previous) direction observed when clients use IAccessible::accNavigate to navigate from one user interface element to another within the same container. http://msdn.microsoft.com/en-us/library/dd373600%28v=vs.85%29.aspx
	static NAVDIR_MIN := 0
	static NAVDIR_UP := 1
	static NAVDIR_DOWN := 2
	static NAVDIR_LEFT := 3
	static NAVDIR_RIGHT := 4
	static NAVDIR_NEXT := 5
	static NAVDIR_PREVIOUS := 6
	static NAVDIR_FIRSTCHILD := 7
	static NAVDIR_LASTCHILD := 8
	static NAVDIR_MAX := 9
	
	; enum Object Identifiers determine the object to which a WM_GETOBJECT message request refers. http://msdn.microsoft.com/en-us/library/dd373606%28v=vs.85%29.aspx
	static OBJID_WINDOW := 0
	static OBJID_SYSMENU := -1
	static OBJID_TITLEBAR := -2
	static OBJID_MENU := -3
	static OBJID_CLIENT := -4
	static OBJID_VSCROLL := -5
	static OBJID_HSCROLL := -6
	static OBJID_SIZEGRIP := -7
	static OBJID_CARET := -8
	static OBJID_CURSOR := -9
	static OBJID_ALERT := -10
	static OBJID_SOUND := -11
	static OBJID_QUERYCLASSNAMEIDX := -12
	static OBJID_NATIVEOM := -16
}


