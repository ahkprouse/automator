strComputer := "."
objWMIService := ComObjGet("winmgmts:{impersonationLevel=impersonate}!\\" . strComputer . "\root\cimv2")

colSettings := objWMIService.ExecQuery("Select * from Win32_OperatingSystem")._NewEnum

Gui, Add, ListView, x0 y0 r45 w400 h500 vMyLV, Attribute|Value
GuiControl, -Redraw, MyLV

While colSettings[objOSItem]
{
  LV_Add("","Build Number" ,objOSItem.BuildNumber )
  LV_Add("","Build Type" ,objOSItem.BuildType )
  LV_Add("","Caption" ,objOSItem.Caption )
  LV_Add("","CountryCode" ,objOSItem.CountryCode )
  LV_Add("","CreationClassName" ,objOSItem.CreationClassName )
  LV_Add("","CSDVersion" ,objOSItem.CSDVersion )
  LV_Add("","CSName" ,objOSItem.CSName )
  LV_Add("","CurrentTimeZone" ,objOSItem.CurrentTimeZone )
  LV_Add("","Distributed" ,objOSItem.Distributed )
  LV_Add("","EncryptionLevel" ,objOSItem.EncryptionLevel )
  LV_Add("","FreePhysicalMemory" ,objOSItem.FreePhysicalMemory )
  LV_Add("","FreeSpaceInPagingFiles" ,objOSItem.FreeSpaceInPagingFiles )
  LV_Add("","FreeVirtualMemory" ,objOSItem.FreeVirtualMemory )
  LV_Add("","InstallDate" ,objOSItem.InstallDate )
  LV_Add("","LargeSystemCache" ,objOSItem.LargeSystemCache )
  LV_Add("","LastBootUpTime" ,objOSItem.LastBootUpTime )
  LV_Add("","LocalDateTime" ,objOSItem.LocalDateTime )
  LV_Add("","Locale" ,objOSItem.Locale )
  LV_Add("","Manufacturer" ,objOSItem.Manufacturer )
  LV_Add("","MaxNumberOfProcesses" ,objOSItem.MaxNumberOfProcesses )
  LV_Add("","MaxProcessMemorySize" ,objOSItem.MaxProcessMemorySize )
  LV_Add("","Name" ,objOSItem.Name )
  LV_Add("","NumberOfLicensedUsers" ,objOSItem.NumberOfLicensedUsers )
  LV_Add("","NumberOfProcesses" ,objOSItem.NumberOfProcesses )
  LV_Add("","NumberOfUsers" ,objOSItem.NumberOfUsers )
  LV_Add("","Organization" ,objOSItem.Organization )
  LV_Add("","OSLanguage" ,objOSItem.OSLanguage )
  LV_Add("","OSType" ,objOSItem.OSType )
  LV_Add("","Primary" ,objOSItem.Primary )
  LV_Add("","ProductType" ,objOSItem.ProductType )
  LV_Add("","RegisteredUser" ,objOSItem.RegisteredUser )
  LV_Add("","SerialNumber" ,objOSItem.SerialNumber )
  LV_Add("","ServicePackMajorVersion" ,objOSItem.ServicePackMajorVersion )
  LV_Add("","ServicePackMinorVersion" ,objOSItem.ServicePackMinorVersion )
  LV_Add("","SizeStoredInPagingFiles" ,objOSItem.SizeStoredInPagingFiles )
  LV_Add("","Status" ,objOSItem.Status )
  LV_Add("","SuiteMask" ,objOSItem.SuiteMask )
  LV_Add("","SystemDevice" ,objOSItem.SystemDevice )
  LV_Add("","SystemDirectory" ,objOSItem.SystemDirectory )
  LV_Add("","SystemDrive" ,objOSItem.SystemDrive )
  LV_Add("","TotalSwapSpaceSize" ,objOSItem.TotalSwapSpaceSize )
  LV_Add("","TotalVirtualMemorySize" ,objOSItem.TotalVirtualMemorySize )
  LV_Add("","TotalVisibleMemorySize" ,objOSItem.TotalVisibleMemorySize )
  LV_Add("","Version" ,objOSItem.Version )
  LV_Add("","WindowsDirectory" ,objOSItem.WindowsDirectory )
}

GuiControl, +Redraw, MyLV
LV_ModifyCol()
Gui, Show, w400 h500, Operating System Details
Return

GuiClose:
ExitApp