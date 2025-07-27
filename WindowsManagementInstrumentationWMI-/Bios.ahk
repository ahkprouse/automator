strComputer := "."
objWMIService := ComObjGet("winmgmts:{impersonationLevel=impersonate}!\\" . strComputer . "\root\cimv2")

colSettings := objWMIService.ExecQuery("Select * from Win32_BIOS")._NewEnum

While colSettings[objBiosItem]
{
  MsgBox % "BIOSVersion : " . objBiosItem.BIOSVersion
  . "`nBuildNumber : " . objBiosItem.BuildNumber
  . "`nCaption : " . objBiosItem.Caption
  . "`nCurrentLanguage : " . objBiosItem.CurrentLanguage
  . "`nDescription : " . objBiosItem.Description
  . "`nInstallableLanguages : " . objBiosItem.InstallableLanguages
  . "`nInstallDate : " . objBiosItem.InstallDate
  . "`nListOfLanguages : " . objBiosItem.ListOfLanguages
  . "`nManufacturer : " . objBiosItem.Manufacturer
  . "`nName : " . objBiosItem.Name
  . "`nPrimaryBIOS : " . objBiosItem.PrimaryBIOS
  . "`nReleaseDate : " . objBiosItem.ReleaseDate
  . "`nSerialNumber2 : " . objBiosItem.SerialNumber
  . "`nSMBIOSBIOSVersion : " . objBiosItem.SMBIOSBIOSVersion
  . "`nSMBIOSMajorVersion : " . objBiosItem.SMBIOSMajorVersion
  . "`nSMBIOSMinorVersion : " . objBiosItem.SMBIOSMinorVersion
  . "`nSMBIOSPresent : " . objBiosItem.SMBIOSPresent
  . "`nSoftwareElementID : " . objBiosItem.SoftwareElementID
  . "`nSoftwareElementState : " . objBiosItem.SoftwareElementState
  . "`nStatus : " . objBiosItem.Status
  . "`nTargetOperatingSystem : " . objBiosItem.TargetOperatingSystem
  . "`nVersion : " . objBiosItem.Version
}