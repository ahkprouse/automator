strComputer := "."
objWMIService := ComObjGet("winmgmts:{impersonationLevel=impersonate}!\\" . strComputer . "\root\cimv2")

colItems := objWMIService.ExecQuery("Select * from Win32_PointingDevice")._NewEnum
While colItems[objItem]
    MsgBox % "Description: " . objItem.Description
    . "`nDevice ID: " . objItem.DeviceID
    . "`nDevice Interface: " . objItem.DeviceInterface
    . "`nDouble Speed Threshold: " . objItem.DoubleSpeedThreshold
    . "`nHandedness: " . objItem.Handedness
    . "`nHardware Type: " . objItem.HardwareType
    . "`nINF File Name: " . objItem.InfFileName
    . "`nINF Section: " . objItem.InfSection
    . "`nManufacturer: " . objItem.Manufacturer
    . "`nName: " . objItem.Name
    . "`nNumber Of Buttons: " . objItem.NumberOfButtons
    . "`nPNP Device ID: " . objItem.PNPDeviceID
    . "`nPointing Type: " . objItem.PointingType
    . "`nQuad Speed Threshold: " . objItem.QuadSpeedThreshold
    . "`nResolution: " . objItem.Resolution
    . "`nSample Rate: " . objItem.SampleRate
    . "`nSynch: " . objItem.Synch