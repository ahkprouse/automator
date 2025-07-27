#Requires AutoHotkey v2.0

Class LiveMic
{
	Static __New()
	{
		bGui := Gui('-border AlwaysOnTop')
		bGui.SetFont("s16 C0x298939","Impact")
		bGui.AddText(,'Capturing Audio')
		bGui.SetFont("s12 Cblack",'Book Antiqua')
		this.DeviceName := bGui.AddText('xm yp+30 w300')
		bar := bGui.AddProgress('xm range0-500 w300')
		this.Note       := bGui.AddText('xm w300')
		bGui.Backcolor  := "0xFFD23E"
		this.Device := ''
		this.bar := bar
		this.UI := bGui
		this.UpdateBarFunc := ObjBindMethod(this,'updateLiveMicBar')
	}

	static SetMic(DeviceName)
	{
		; this.Device := DeviceName
		this.DeviceName.Value := DeviceName
	}

	static show()
	{
		this.UI.show('na')
		settimer this.UpdateBarFunc, 100
		; settimer Fix, 100
	}

	static hide()
	{
		if this.hasprop('UpdateBarFunc')
			settimer this.UpdateBarFunc, 0
		if this.audioMeter
			ObjRelease(this.audioMeter), this.audioMeter := ''
		this.UI.hide()
	}

	static updateLiveMicBar()
	{
		if this.DeviceName.Value = ''
		{
			msgbox 'please SetMic("your device name")'
			return
		}

		this.audioMeter := SoundGetInterface("{C02216F6-8C67-4B5B-9D00-D008E73E0064}",, this.DeviceName.Value)
		
		if this.audioMeter
		{
			; audioMeter->GetPeakValue(&peak)
			ComCall 3, this.audioMeter, "float*", &peak:=0
			if  peak > 0
				this.bar.value := peak * 1000
			else
				this.bar.value := 0
			Sleep 15
			; ObjRelease audioMeter
		}
		else
		{
			this.hide()
			MsgBox "Unable to get audio Device"
		}
	}
}

