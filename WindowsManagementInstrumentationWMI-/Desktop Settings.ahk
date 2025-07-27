strComputer := "."
objWMIService := ComObjGet("winmgmts:{impersonationLevel=impersonate}!\\" . strComputer . "\root\cimv2")

colItems := objWMIService.ExecQuery("Select * from Win32_Desktop")._NewEnum
While colItems[objItem]
    MsgBox % "Border Width: " . objItem.BorderWidth
    . "`nCaption: " . objItem.Caption
    . "`nCool Switch: " . objItem.CoolSwitch
    . "`nCursor Blink Rate: " . objItem.CursorBlinkRate
    . "`nDescription: " . objItem.Description
    . "`nDrag Full Windows: " . objItem.DragFullWindows
    . "`nGrid Granularity: " . objItem.GridGranularity
    . "`nIcon Spacing: " . objItem.IconSpacing
    . "`nIcon Title Face Name: " . objItem.IconTitleFaceName
    . "`nIcon Title Size: " . objItem.IconTitleSize
    . "`nIcon Title Wrap: " . objItem.IconTitleWrap
    . "`nName: " . objItem.Name
    . "`nPattern: " . objItem.Pattern
    . "`nScreen Saver Active: " . objItem.ScreenSaverActive
    . "`nScreen Saver Executable: " . objItem.ScreenSaverExecutable
    . "`nScreen Saver Secure: " . objItem.ScreenSaverSecure
    . "`nScreen Saver Timeout: " . objItem.ScreenSaverTimeout
    . "`nSetting ID: " . objItem.SettingID
    . "`nWallpaper: " . objItem.Wallpaper
    . "`nWallpaper Stretched: " . objItem.WallpaperStretched
    . "`nWallpaper Tiled: " . objItem.WallpaperTiled