#Requires AutoHotkey v2.0

; command := 'ffmpeg -y -f dshow -i audio="{}" -af acompressor=threshold=-20dB:ratio=4:attack=200:release=1000,highpass=f=200,lowpass=f=3000,afftdn=nf=-25,adeclick,adeclick,volume=5dB -acodec libopus -b:a 24k -ac 1 -application voip -ar 16000 "{}"'
; record_out_path := A_ScriptDir "\test.ogg"
; microphoneName := "Microphone (USB Audio Device)"
; Run( Format(command,microphoneName,record_out_path),, 'Min',&pid )

; Process_Suspend(pid)


; NumpadAdd::
; {
; 	Process_Resume(pid)

; 	while GetKeyState(A_ThisHotkey)
; 		sleep 100
; 	WinClose('ffmpeg.exe')
; 	ProcessWaitClose('ffmpeg.exe',5)
; }

; mic :=  'Microphone (TONOR TC-777 Audio Device)'
; audiopath := A_Desktop '\audio.ogg'
; ffmpegLiveAudio(mic, audiopath)


Class ffmpegLiveAudio
{
	static command := 'ffmpeg -y -f dshow -i audio="{}" -af acompressor=threshold=-20dB:ratio=4:attack=200:release=1000,highpass=f=200,lowpass=f=3000,afftdn=nf=-25,adeclick,adeclick,volume=5dB -acodec libopus -b:a 24k -ac 1 -application voip -ar 16000 "{}"'

	__New(microphoneName, record_out_path)
	{
		this.microphoneName := microphoneName
		this.record_out_path := record_out_path
		this.pid := this.SetupRecording()
		OnExit((*)=>this.Kill())
	}

	Start() 	=> this.pid := this.SetupRecording()
	Pause() 	=> this.Process_Suspend(this.pid)
	Continue()  => this.Process_Resume(this.pid)
	Stop() 		=> (this.terminateffmpeg(),this.record_out_path)
	
	SetupRecording()
	{
		DetectHiddenWindows true
		this.Kill() ; aviod any error if ffmpeg is already recording 
		Run Format(ffmpegLiveAudio.command, this.microphoneName , this.record_out_path),, 'hide' ;, &pid
		ProcessWait('ffmpeg.exe')
		WinWait('ahk_exe ffmpeg.exe')
		pid := WinGetPID('ahk_exe ffmpeg.exe')
		return pid
	}

	Kill()
	{
		while ProcessExist('ffmpeg.exe')
		{
			ProcessClose('ffmpeg.exe')
			sleep 100
		}
	}


	terminateffmpeg()
	{
		this.Process_Resume(this.pid)
		while !WinExist('ffmpeg.exe')
		{
			sleep 200
			if a_index > 20
				break
		}
		DetectHiddenWindows true
		if WinExist('ffmpeg.exe')
			WinClose('ffmpeg.exe')
		ProcessWaitClose('ffmpeg.exe',5)
	}


	Process_Suspend(PID_or_Name){
		PID := (InStr(PID_or_Name,".")) ? ProcessExist(PID_or_Name) : PID_or_Name
		h:=DllCall("OpenProcess", "uInt", 0x1F0FFF, "Int", 0, "Int", pid)
		If !h   
			Return -1
		DllCall("ntdll.dll\NtSuspendProcess", "Int", h)
		DllCall("CloseHandle", "Int", h)
		Return
	}
	
	Process_Resume(PID_or_Name){
		PID := (InStr(PID_or_Name,".")) ? ProcessExist(PID_or_Name) : PID_or_Name
		h:=DllCall("OpenProcess", "uInt", 0x1F0FFF, "Int", 0, "Int", pid)
		If !h   
			Return -1
		DllCall("ntdll.dll\NtResumeProcess", "Int", h)
		DllCall("CloseHandle", "Int", h)
	}
}



 
