;*******************************************************
; Want a clear path for learning AutoHotkey; Take a look at our AutoHotkey Udemy courses.  They're structured in a way to make learning AHK EASY
; Right now you can  get a coupon code here: https://the-Automator.com/Learn
;*******************************************************
;; queries for a registered class by ID

#include WMI.ahk
; for item in Win32_ClassicCOMClassSetting("{0002DF01-0000-0000-C000-000000000046}").objList
for item in Win32_ClassicCOMClass("{0002DF01-0000-0000-C000-000000000046}").objProps
	msgbox % clipboard := item.ProgId


Win32_ClassicCOMClass(CLSID) {
    return new Win32_ClassicCOMClass(CLSID)
}


/*
[Dynamic, Provider("CIMWin32"), UUID("{0F73ED53-8ED9-11d2-B340-00105A1F8569}"), AMENDMENT]
class Win32_ClassicCOMClass : Win32_COMClass
{
  string   Caption;
  string   Description;
  datetime InstallDate;
  string   Status;
  string   ComponentId;
  string   Name;
};
*//*
    https://docs.microsoft.com/en-us/windows/win32/cimwin32prov/win32-classiccomclass
    ;; start Win32_ClassicCOMClass properties
    */
;; just a structure to hold Win32_ClassicCOMClass
class Win32_ClassicCOMClass {
    
    
    objProps {
		get {
			return this.Win32_ClassicCOMClassSetting.objProps
		}
	}
    
	/*
	Name: Caption
	Type: string
	*/
	Caption {
		get {
			return this.objProps.Caption
		}
	}

	/*
	Name: Description
	Type: string
	*/
	Description {
		get {
			return this.objProps.Description
		}
	}

	/*
	Name: InstallDate
	Type: datetime
	*/
	InstallDate {
		get {
			return this.objProps.InstallDate
		}
	}

	/*
	Name: Status
	Type: string
	*/
	Status {
		get {
			return this.objProps.Status
		}
	}

	/*
	Name: ComponentId
	Type: string
	*/
	ComponentId {
		get {
			return this.objProps.ComponentId
		}
	}

	/*
	Name: Name
	Type: string
	*/
	Name {
		get {
			return this.objProps.Name
		}
	}

    ;; end Win32_ClassicCOMClass properties

    __new(CLSID) {
		this.Win32_ClassicCOMClassSetting := new this.Win32_ClassicCOMClassSetting(CLSID)
    }

    class Win32_ClassicCOMClassSetting {
        ;; instantiate a WMI object
        static WMI := WMI()
        objProps[] {
            get {
                return list := this.WMI.ExecQuery( this.StrQuery )
            }
        }


        StrQuery := ""
        __new(CLSID) {
            this.StrQuery := "Select * from Win32_ClassicCOMClassSetting where ComponentId = '" . CLSID . "'"
        }
    }
}