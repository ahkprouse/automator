
mGui := Gui(,'Media Player Preference')
mGui.AddCheckbox('vNotifyTrack','Track Notification')
mGui.AddText('y+m+3','Default Folder:')
mGui.AddEdit('x+m yp-3 w300 ReadOnly vDefaultFolder')
mGui.AddButton('x+m yp','...').OnEvent('click',SelectDefaultFolder)
mGui.AddButton('y+m x325','Save').OnEvent('click',SavePreference)
mGui.AddButton('x+m','Cancel').OnEvent('click',(*) => mGui.Hide())

ChangePreference() 
{
    mGui['DefaultFolder'].value := IniRead(ini,A_UserName ' Media','DefaultPath','')
    mGui['NotifyTrack'].value := IniRead(ini,A_UserName ' Media','NotifyTrack',1)
    mGui.Show()
}


SelectDefaultFolder(*)
{

    DefaultMediaFolder := FileSelect('D',RootDir '\..\','Select Media Folder')
    if !DefaultMediaFolder
        return 0
    
    mGui['DefaultFolder'].value := DefaultMediaFolder
}

SavePreference(*)
{
    global RootDir,TrackNotify
    IniWrite(RootDir     := mGui['DefaultFolder'].value,ini,A_UserName ' Media','DefaultPath')
    IniWrite(TrackNotify := mGui['NotifyTrack'  ].value,ini,A_UserName ' Media','NotifyTrack')
    mGui.Hide()
}