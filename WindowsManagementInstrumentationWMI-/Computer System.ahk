strComputer := "."
objWMIService := ComObjGet("winmgmts:{impersonationLevel=impersonate}!\\" . strComputer . "\root\cimv2")

colSettings := objWMIService.ExecQuery("Select * from Win32_ComputerSystem")._NewEnum
Gui, Add, ListView, x0 y0 r45 w400 h500 vMyLV, Attribute|Value
GuiControl, -Redraw, MyLV

While colSettings[strCSItem]
{
  LV_Add("","AdminPasswordStatus",strCSItem.AdminPasswordStatus )
  LV_Add("","AutomaticResetBootOption",strCSItem.AutomaticResetBootOption )
  LV_Add("","AutomaticResetCapability",strCSItem.AutomaticResetCapability )
  LV_Add("","BootROMSupported",strCSItem.BootROMSupported )
  LV_Add("","BootupState",strCSItem.BootupState )
  LV_Add("","Caption",strCSItem.Caption )
  LV_Add("","ChassisBootupState",strCSItem.ChassisBootupState )
  LV_Add("","CurrentTimeZone",strCSItem.CurrentTimeZone )
  LV_Add("","DaylightInEffect",strCSItem.DaylightInEffect )
  LV_Add("","Description",strCSItem.Description )
  LV_Add("","Domain",strCSItem.Domain )
  LV_Add("","DomainRole",strCSItem.DomainRole )
  LV_Add("","EnableDaylightSavingsTime",strCSItem.EnableDaylightSavingsTime )
  LV_Add("","FrontPanelResetStatus",strCSItem.FrontPanelResetStatus )
  LV_Add("","InfraredSupported",strCSItem.InfraredSupported )
  LV_Add("","KeyboardPasswordStatus",strCSItem.KeyboardPasswordStatus )
  LV_Add("","Manufacturer",strCSItem.Manufacturer )
  LV_Add("","Model",strCSItem.Model )
  LV_Add("","Name",strCSItem.Name )
  LV_Add("","NetworkServerModeEnabled",strCSItem.NetworkServerModeEnabled )
  LV_Add("","NumberOfLogicalProcessors",strCSItem.NumberOfLogicalProcessors )
  LV_Add("","NumberOfProcessors",strCSItem.NumberOfProcessors )
  LV_Add("","OEMStringArray",strCSItem.OEMStringArray )
  LV_Add("","PartOfDomain",strCSItem.PartOfDomain )
  LV_Add("","PauseAfterReset",strCSItem.PauseAfterReset )
  LV_Add("","PowerOnPasswordStatus",strCSItem.PowerOnPasswordStatus )
  LV_Add("","PowerState",strCSItem.PowerState )
  LV_Add("","PowerSupplyState",strCSItem.PowerSupplyState )
  LV_Add("","PrimaryOwnerContact",strCSItem.PrimaryOwnerContact )
  LV_Add("","PrimaryOwnerName",strCSItem.PrimaryOwnerName )
  LV_Add("","ResetCapability",strCSItem.ResetCapability )
  LV_Add("","ResetCount",strCSItem.ResetCount )
  LV_Add("","ResetLimit",strCSItem.ResetLimit )
  LV_Add("","Roles",strCSItem.Roles )
  LV_Add("","Status",strCSItem.Status )
  LV_Add("","SupportContactDescription",strCSItem.SupportContactDescription )
  LV_Add("","SystemStartupDelay",strCSItem.SystemStartupDelay )
  LV_Add("","SystemStartupOptions",strCSItem.SystemStartupOptions )
  LV_Add("","SystemStartupSetting",strCSItem.SystemStartupSetting )
  LV_Add("","SystemType",strCSItem.SystemType )
  LV_Add("","ThermalState",strCSItem.ThermalState )
  LV_Add("","TotalPhysicalMemory",Round(strCSItem.TotalPhysicalMemory/(1024*1024),0) . " MB")
  LV_Add("","UserName",strCSItem.UserName )
  LV_Add("","WakeUpType",strCSItem.WakeUpType )
  LV_Add("","Workgroup",strCSItem.Workgroup )
} 
GuiControl, +Redraw, MyLV
LV_ModifyCol()
Gui, Show, w400 h500, Computer Details
Return

GuiClose:
ExitApp