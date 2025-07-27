class FFMPEG {
	static path {
		get {
			paths := EnvGet('PATH')

			current_path := ''
			for path in StrSplit(paths, ";")
			{
				if !FileExist(path "\ffmpeg.exe")
					continue

				current_path := path "\ffmpeg.exe"
				break
			}

			if !current_path
			{
				paths := RegRead("HKEY_CURRENT_USER\Environment", "Path")
				for path in StrSplit(paths, ";")
				{
					if !FileExist(path "\ffmpeg.exe")
						continue

					; the env path might be empty or not set
					; in cases where the user has not restarted
					; we set it here so the functions below can work
					; until we restart or log out.
					EnvSet('PATH', paths)
					current_path := path "\ffmpeg.exe"
					break
				}
			}

			return current_path
		}

		set {
			Paths := Map()
			for path in StrSplit(EnvGet('PATH'), ';')
			{
				if !path
					continue
				Paths.Set(path, true)
			}

			SplitPath value, , &dir
			Paths.Set(dir, true)

			fixed_paths := ''
			for path in Paths
				fixed_paths .= path ';'

			EnvSet('PATH', fixed_paths)
			RegWrite(fixed_paths, "REG_SZ","HKEY_CURRENT_USER\Environment", "Path")
			return value
		}
	}

	static __New()
	{
		if !FFMPEG.path
		{
			msg :=
			(
				'FFmpeg was not found in your Environment.

				This tool requires ffmpeg for processing files correctly.

				Do you know where ffmpeg.exe is located in your computer?'
			)
			if MsgBox(msg, 'Not found','Icon? Y/N') = 'No'
				FFMPEG.Setup()

			if !current_path := FileSelect('1',, 'Select ffmpeg.exe')
				ExitApp(MsgBox('No file selected', 'Error', 'IconX'))

			FFMPEG.path := current_path
		}
	}

	static Setup()
	{
		static msg :=
		(
			'Do you want to download it and setup the environment now?

			Note: clicking No will exit the application.'
		)
		if MsgBox(msg, 'Setting up ffmpeg', 'Icon! Y/N') = 'No'
			ExitApp

		if !location := FileSelect('D',, 'Pick the destination Folder')
			ExitApp(MsgBox('No folder destination selected', 'Error', 'IconX'))


		FFMPEG.Download()

		loop files, A_Temp '\*ffmpeg.exe', 'FR'
		{
			FileMove A_LoopFileFullPath, location '\ffmpeg.exe', true
			break
		}
		FFMPEG.path := location '\ffmpeg.exe'
		return
	}

	static Download()
	{
		TrayTip 'FFMpeg will download now.`nPlease wait.', 'Downloading', 0x1

		main := Gui()
		main.AddText('vAction Center w350', 'Downloading')
		main.AddProgress('vMarquee w350 h5 ' PBS_MARQUEE := 0x8)
		main.AddText('vQueue Center w350', '♾️')
		main.show()

		SetTimer UpdateMarquee(*)=> main['Marquee'].value := 1 , 10

		Download 'https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-essentials.zip', zipFile := A_Temp '\ffmpeg.zip'

		SetTimer UpdateMarquee, false
		main.Destroy()

		TrayTip 'Extracting FFmpeg', 'Extracting', 0x1

		oShell   := ComObject('Shell.Application')
		oDir     := oShell.NameSpace(A_Temp)
		oZipFile := oShell.NameSpace(zipFile)
		oDir.CopyHere(oZipFile.Items)

		FileDelete zipFile
		return
	}

	/**
	 *
	 * @param {String} path
	 * @param {'ogg'|'mp3'|'mp4'} out_format
	 * @returns {String}
	 */
	static VideoToAudio(path, out_format := 'ogg')
	{
		static cmd := 'ffmpeg -y -i "{}" -vn -ac 1 -b:a 24k -ar 16000 -af "highpass=f=85, lowpass=f=14000" -c:a libvorbis "{}"'

		if !FileExist(path)
			throw TargetError('File not found', A_ThisFunc, path)

		if out_format ~= '^\.'
			out_format := RegexReplace(out_format, '^\.')

		SplitPath path,,, &ext
		out_path := StrReplace(path, '.' ext, '.' out_format)

		RunWait Format(cmd, path, out_path),, 'Hide'

		if !FileExist(out_path)
			throw TargetError('File not created', A_ThisFunc, out_path)

		if FileGetSize(out_path) <= 0
			throw Error('File is empty', A_ThisFunc, out_path)

		return out_path
	}

	/**
	 *
	 * @param {String} video_path
	 * @param {String} subtitle_path
	 * @param {true|false} hardcode
	 * @returns {String}
	 */
	static AddSubtitles(video_path, subtitle_path, hardcode:=false)
	{
		static hardcoded  := 'ffmpeg -y -i "{}" -preset "ultrafast" -c:a copy -c:v libx265 -crf 18 -vf "subtitles=`'{}`'" "{}"'
		static softcoded  := 'ffmpeg -y -i "{}" -i "{}" -c:a copy -c:v copy -c:s mov_text "{}"'

		if !FileExist(video_path)
			throw TargetError('Video file not found', A_ThisFunc, video_path)

		if !FileExist(subtitle_path)
			throw TargetError('Subtitle file not found', A_ThisFunc, subtitle_path)

		SplitPath video_path,,, &ext
		out_path := StrReplace(video_path, '.' ext, '_subtitled.mp4')

		if !hardcode
			fix_subtitle_path := subtitle_path
		else
		{
			fix_subtitle_path := StrReplace(subtitle_path, '\', '/')
			fix_subtitle_path := RegexReplace(fix_subtitle_path, '([: \\])', '\$1')
		}

		RunWait A_Clipboard := Format(hardcode ? hardcoded : softcoded, video_path, fix_subtitle_path, out_path),, 'Hide'

		if !FileExist(out_path)
			throw TargetError('File not created', A_ThisFunc, out_path)

		if FileGetSize(out_path) <= 0
			throw Error('File is empty', A_ThisFunc, out_path)

		return out_path
	}

	/**
	 * @param MediaPath ; Path to the media file
	 * @param OutFolder ; Folder to save the sections
	 * @param SectionLength ; Length of each section in minutes (Default is 30 minutes)
	 */
	static CreateSections(MediaPath,OutFolder,SplitLength:= 30)
	{
		SectionLength := SplitLength * 60 ; converting minutes into seconds
		SplitPath(MediaPath,,,&ext,&name)
		info := FFMPEG.Getinfo(MediaPath)
		len := integer(TimeToSeconds(info['Length']))
		sectioncount := Ceil(len / SectionLength)
		sectioncount := sectioncount ? sectioncount : 1
		SectionLength := sectioncount = 1 ? len : SectionLength
		Sections := []
		loop sectioncount
		{
			sectionPath := OutFolder '\' name '-Section ' a_index '.' ext
			if FileExist(sectionPath)
				FileDelete(sectionPath)

			Sectioninfo := Map()
			VideoLength := a_index = sectioncount ? len : SectionLength
			Sectioninfo['path'] := sectionPath
			Sectioninfo['start'] := (a_index - 1) * SectionLength
			Sectioninfo['end'] := a_index = sectioncount ? len : a_index * VideoLength

			FFMPEG.Trim(MediaPath, sectionPath, Sectioninfo['start'], Sectioninfo['end'])
			Sections.Push(Sectioninfo)
		}
		return Sections

		TimeToSeconds(srtTime)
		{
			static regex := '(\d+):(\d+):(\d+)(?:,(\d+))?'
			RegExMatch(srtTime, regex, &match)
			return Round(match[1] * 3600 + match[2] * 60 + match[3] + (match[4] ? match[4] : 0) / 1000, 2)
		}
	}

	/**
	 *
	 * @param {String} in_Path
	 * @param {String} out_path
	 * @param {Integer} StartSec
	 * @param {Integer} EndSec
	 */
	static Trim(in_Path, out_path, StartSec, EndSec)
	{
		static cmd  := 'ffmpeg -y  -ss {} -t {} -i "{}" -y -c copy "{}"'

		if !FileExist(in_Path)
			throw TargetError('Video file not found', A_ThisFunc, in_Path)
		endTime := EndSec - StartSec
		RunWait Format(cmd, StartSec, endTime, in_Path, out_path),, 'Hide'

		if !FileExist(out_path)
			throw TargetError('File not created', A_ThisFunc, out_path)

		if FileGetSize(out_path) <= 0
			throw Error('File trim failed', A_ThisFunc, out_path)
	}

	/**
	 *
	 * @param {String} path
	 * @returns {String}
	 */
	static GetType(path)
	{
		static cmd := 'ffmpeg.exe -i "{}" 2>&1 | clip'
		if !FileExist(path)
			throw TargetError('File doesnt exist')
		oldClip := ClipboardAll()

		RunWait A_ComSpec ' /c ' Format(cmd, path),,'hide'

		streams := Map()
		while pos := RegExMatch(A_Clipboard, 'Stream #.*?: (.*?):', &matched, pos ?? 1)
		{
			streams.Set(matched[1], true)
			pos++
		}

		if streams.has('Video')
			handler := 'Video'
		else if streams.has('Audio')
			handler := 'Audio'
		else
			throw Error('Unable to get File Type', A_ThisFunc, path)

		Sleep 500
		A_Clipboard := oldClip

		return handler
	}

	static GetVersion()
	{
		static cmd  := 'ffmpeg 2>> "{}"'
		static out := a_temp '\ffmpeg_info.txt'
		try FileDelete(out)
		RunWait A_ComSpec ' /c ' Format(cmd, out) ,, 'hide'
		if !FileExist(out)
			throw Error('File does not exist, ffmpeg is not configured properly', A_ThisFunc, out)
		outtxt := FileRead(out,'utf-8')
		if !outtxt
			throw Error('File is empty', A_ThisFunc, out)
		
		if RegExMatch(outtxt, "ffmpeg version (.*?)\s", &match)
			return match[1]
		else
			throw Error('Unable to get version', A_ThisFunc, out)
	}

	/**
	 *
	 * @param {String} path
	 * @returns {Map}
	 */
	static Getinfo(path)
	{
		static cmd  := 'ffmpeg -i "{}" 2>> "{}"'
		static out := a_temp '\ffmpeg_info.txt'
		if !FileExist(path)
			throw TargetError('File doesnt exist')

		try FileDelete(out)
		RunWait A_ComSpec ' /c ' Format(cmd, path, out) ,, 'hide'

		while !FileExist(out)
		{
			Sleep 200
			if a_index > 10
				throw Error('File not created', A_ThisFunc, out)
		}
		outtxt := FileRead(out,'utf-8')
		if !outtxt
			throw Error('File is empty', A_ThisFunc, out)
		info := Map()
		v := 0, a := 0
		Loop Parse, outtxt, '`n'
		{
			if RegExMatch(A_LoopField, "Stream #\d+:\d+.*Video:.* ([0-9]+x[0-9]+).*", &match)
			{
				info["Resolution"] := match[1]
				info["Video_Stream" v++] := match[0]
			}
			else if RegExMatch(A_LoopField, "Stream #\d+:\d+.*Audio:.*", &match)
			{
				info["Audio_Stream" a++] := match[0]
			}
			else if RegExMatch(A_LoopField, "Duration: (\d{2}:\d{2}:\d{2}).(\d+),\s+start: ([\d.]+)", &match)
			{
				info["Duration"] := match[1] ":" match[2]
				info["Length"] := match[1]
				info["Start"] := match[3]
			}
		}
		return info
	}
}