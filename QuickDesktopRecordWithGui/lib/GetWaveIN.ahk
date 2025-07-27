GetInputDevices()
{
	devices := Array()                              ; Array to store devices' names
	numDevices := DllCall("winmm\waveInGetNumDevs") ; Get the number of audio input devices
	WAVEINCAPS := Buffer(80)                        ; Buffer to store device information
	Loop numDevices 
	{
		DllCall(
			"winmm\waveInGetDevCaps", 
			"UInt", A_Index-1, 
			"UInt", WAVEINCAPS.ptr, 
			"UInt", WAVEINCAPS.size)
		devices.push(StrGet(WAVEINCAPS.ptr + 8, "UTF-16"))
	}
	return devices
}