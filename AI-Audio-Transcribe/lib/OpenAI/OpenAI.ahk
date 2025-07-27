#SingleInstance
#Requires Autohotkey v2.0-
;--
;Ahk2Exe-SetVersion     0.2.0
;Ahk2Exe-SetMainIcon    res\main.ico
;Ahk2Exe-SetProductName OpenAI-AHK
;Ahk2Exe-SetDescription OpenAI API Wrapper for AutoHotkey

/**
 * ============================================================================ *
 * @Author   : RaptorX                                                          *
 * @Homepage :                                                                  *
 *                                                                              *
 * @Created  : June 21, 2024                                                    *
 * @Modified : July 14, 2024                                                    *
 * ============================================================================ *
 */

#Include .\lib\JSON\JSON.ahk

; JSON.true  := ComValue(11, 65535)
; JSON.false := ComValue(11, 0)
; JSON.null  := ComValue(1, 0)

class OpenAI {
	static token := ''
	static orgID := ''
	static basic_headers := Map(
			'Content-Type', 'application/json',
			'Authorization', 'Bearer {}',
			'OpenAI-Organization', '{}',
			'User-Agent', 'OpenAI-AHK/1.0.0'
	)

	static authenticated {
		get => !!OpenAI.token
	}

	static Authenticate(key, orgID?)
	{
		http := ComObject('WinHttp.WinHttpRequest.5.1')
		http.Open('GET', 'https://api.openai.com/v1/models', false) ; https://platform.openai.com/docs/api-reference/authentication
		http.SetRequestHeader('Authorization', 'Bearer ' key)
		http.Send()
		if (http.Status != 200)
			return false

		OpenAI.token := key, OpenAI.orgID := orgID ?? ''

		for header, value in Map('Authorization', key, 'OpenAI-Organization', orgID ?? '')
			OpenAI.basic_headers[header] := Format(OpenAI.basic_headers[header], value)

		return true
	}

	static Request(method, endpoint, body:='', user_headers:=Map())
	{
		static http := ComObject('WinHttp.WinHttpRequest.5.1')

		if !OpenAI.authenticated
			throw Error('OpenAI not authenticated')

		http.Open(method, 'https://api.openai.com/v1/' endpoint, true)

		for header, value in OpenAI.basic_headers
		{
			if !value
			|| user_headers.Has(header)
				continue
			http.SetRequestHeader(header, value)
		}

		for header, value in user_headers
			http.SetRequestHeader(header, value)

		http.SetTimeouts(
			60*1000,  ; ResolveTimeout,
			30*1000,  ; ConnectTimeout,
			300*1000, ; SendTimeout,
			300*1000  ; ReceiveTimeout
		)

		switch Type(body)
		{
		case 'String':
			try body ? JSON.parse(body) : ''
			catch
				throw Error('Invalid JSON body', A_ThisFunc, 'expected JSON string, got: ' Type(body))
			http.Send(body)
		case 'Map':
			http.Send(JSON.stringify(body))
		case 'ComObjArray':
			http.Send(body)
		default:
			throw Error('Invalid body type')
		}

		http.WaitForResponse()

		 ; Convert the response body to UTF-8
		responseBody := http.ResponseBody
		size := responseBody.MaxIndex() + 1
		rawBuffer := Buffer(size)
		DllCall("OleAut32.dll\SafeArrayAccessData", "Ptr", ComObjValue(responseBody), "Ptr*", &pdata:=0)
		DllCall("RtlMoveMemory", "Ptr", rawBuffer.Ptr, "Ptr", pdata, "Ptr", size)
		DllCall("OleAut32.dll\SafeArrayUnaccessData", "Ptr", ComObjValue(responseBody))
		utf8 := StrGet(rawBuffer, "UTF-8")

		; Create a custom object with the correct UTF-8 response
		return {
			Status: http.Status,
			ResponseText: utf8,
			ResponseBody: http.ResponseBody,
			ResponseStream: http.ResponseStream,
			ResponseHeaders: http.GetAllResponseHeaders(),
		}
	}

	class Model {
		id       := ''
		object   := ''
		created  := 0
		owned_by := ''

		__New(id, object?, created?, owned_by?)
		{
			if id
			&& !IsSet(object)
			&& !IsSet(created)
			&& !IsSet(owned_by)
			{
				switch Type(id)
				{
				case 'Map':
					for prop in this.OwnProps()
						this.%prop% := id[prop]
				case 'String':
					res := OpenAI.Request('GET', 'models/' id)
					if res.Status != 200
						throw Error(res.Status '`n' res.ResponseText)

					raw_model := JSON.parse(res.ResponseText)

					for prop in this.OwnProps()
						this.%prop% := raw_model[prop]
				default: throw Error('Invalid ID type', A_ThisFunc, 'expected Map, got: ' Type(id))
				}
				return this
			}

			for prop in this.OwnProps()
				this.%prop% := %prop%

			return this
		}
	}

	class Models extends Map {
		__New()
		{
			res := OpenAI.Request('GET', 'models')
			if res.Status != 200
				throw Error(res.Status '`n' res.ResponseText)

			raw_models := JSON.parse(res.ResponseText)
			for model in raw_models['data']
				this.Set(model['id'], OpenAI.Model(model))
		}

		Set(id, model)
		{
			if Type(model) != 'OpenAI.Model'
				throw Error('Invalid model type', A_ThisFunc, 'expected OpenAI.Model, got: ' Type(model))

			return super.Set(id, model)
		}
	}

	class Chat {
		messages            := []
		model               := ''
		frequency_penalty   := 0
		logit_bias          := JSON.null
		logprobs            := JSON.false
		top_logprobs        := JSON.null
		max_tokens          := JSON.null
		n                   := 1
		presence_penalty    := 0
		response_format     := JSON.null
		seed                := JSON.null
		service_tier        := JSON.null
		stop                := JSON.null
		stream              := JSON.false
		stream_options      := JSON.null
		temperature         := 1
		top_p               := 1
		tools               := JSON.null
		tool_choice         := JSON.null
		user                := ''

		__New(model_id?, messages?)
		{
			if !IsSet(model_id) && !IsSet(messages)
				return this

			this.Create(model_id, messages)
		}

		Create(model_id, messages)
		{
			switch Type(model_id)
			{
			case 'String':       this.model := model_id
			case 'OpenAI.Model': this.model := model_id.id
			default:
				throw Error('Invalid model ID type', A_ThisFunc, 'expected Map/String, got: ' Type(model_id))
			}

			switch Type(messages)
			{
			case 'OpenAI.Chat.Completion.Messages':
				this.messages := messages
			case 'Array':
				for message in messages
					this.messages.Push(OpenAI.Chat.Completion.Message(message))
			case 'String':
				this.messages.Push(OpenAI.Chat.Completion.Message({role: 'user', content: messages}))
			default:
				throw Error(
					'Invalid messages type', A_ThisFunc,
					'expected String/Array/OpenAI.Chat.Completion.Messages, got: ' Type(messages)
				)
			}

			body := JSON.stringify(this)
			res := OpenAI.Request('POST', 'chat/completions', body)

			if res.Status != 200
				throw Error(res.Status '`n' res.ResponseText)

			raw_completion := JSON.parse(res.ResponseText)
			return this.response := OpenAI.Chat.Completion(raw_completion)
		}

		class Completion {
			id                 := ''
			object             := ''
			created            := 0
			model              := {}
			system_fingerprint := ''
			choices            := OpenAI.Chat.Completion.Choices()
			usage              := {}

			__New(completion)
			{
				if Type(completion) != 'Map'
					throw Error('Invalid completion type', A_ThisFunc, 'expected Map, got: ' Type(completion))

				for prop in this.OwnProps()
				{
					switch prop
					{
					case 'choices':
						for choice in completion[prop]
							this.choices.Push(OpenAI.Chat.Completion.Choice(choice))
					case 'usage':
						this.usage := OpenAI.Chat.Completion.Usage(completion[prop])
					default:
						this.%prop% := completion[prop]
					}
				}
			}

			class Choice {
				index         := 0
				message       := {}
				logprobs      := ''
				finish_reason := ''

				__New(choice)
				{
					if Type(choice) != 'Map'
						throw Error('Invalid choice type', A_ThisFunc, 'expected Map, got: ' Type(choice))

					for prop in this.OwnProps()
						this.%prop% := choice[prop]
				}
			}

			class Choices extends Array {
				Push(choice)
				{
					if Type(choice) != 'OpenAI.Chat.Completion.Choice'
						throw Error(
							'Invalid choice type', A_ThisFunc,
							'expected OpenAI.Chat.Completion.Choice, got: ' Type(choice)
						)

					return super.Push(choice)
				}
			}

			class Usage {
				prompt_tokens     := 0,
				completion_tokens := 0,
				total_tokens      := 0

				__New(usage := Map())
				{
					if Type(usage) != 'Map'
						throw Error('Invalid usage type', A_ThisFunc, 'expected Map, got: ' Type(usage))

					for prop in this.OwnProps()
						this.%prop% := usage[prop]
				}
			}

			class Message {
				role        := ''
				content     := ''

				__New(message)
				{
					if Type(message) != 'Object'
						throw Error('Invalid message type', A_ThisFunc, 'expected Object, got: ' Type(message))

					for prop, value in message.OwnProps()
						this.%prop% := value
				}
			}

			class Messages extends Array {
				Push(message)
				{
					if Type(message) != 'Object'
					&& Type(message) != 'OpenAI.Chat.Completion.Message'
						throw Error(
							'Invalid message type', A_ThisFunc,
							'expected OpenAI.Chat.Completion.Message, got: ' Type(message)
						)

					return super.Push(message)
				}
			}
		}
	}

	class Audio {

		class Transcription {
			task     := '',
			language := '',
			duration := 0,
			text     := '',
			segments := []

			__New(raw)
			{
				switch Type(raw)
				{
				case 'String':
					this.text := raw
				default:
					for prop, value in raw
						this.%prop% := value
				}
			}

			/**
			 *  {reference} https://platform.openai.com/docs/api-reference/audio/createTranscription
			 * @param {String} path The audio file path to transcribe
			 *                      in one of these formats: flac, mp3, mp4, mpeg, mpga, m4a, ogg, wav, or webm.
			 * @param {String|OpenAI.Model} model ID of the model to use.
			 *                                    Only whisper-1 (which is powered by our open
			 *                                    source Whisper V2 model) is currently available.
			 * @param {String} language The language of the input audio.
			 *                          Supplying the input language in ISO-639-1 format will improve accuracy and latency.
			 * @param {String} prompt An optional text to guide the model's style or continue a previous
			 *                        audio segment. The prompt should match the audio language.
			 * @param {'json'|'text'|'srt'|'verbose_json'|'vtt'} response_format The format of the transcript output
			 * @param {Integer} temperature
			 * @param {Array} timestamp_granularities
			 * @returns {OpenAI.Audio.Transcription}
			 */
			static create(path, model, language?, prompt?, response_format?, temperature?, timestamp_granularities?)
			{
				switch Type(model)
				{
				case 'String':
					model := OpenAI.Model(model)
				}

				data :=  {
					file                    :[path],
					model                   : model.id,
					language                : language ?? 'en',
					prompt                  : prompt ?? '',
					response_format         : response_format ?? 'json',
					temperature             : temperature ?? 0 ,
					timestamp_granularities : timestamp_granularities ?? 'segment'
				}
				OpenAI.File.CreateFormData(&PostData, &hdr_ContentType, data)
				res := OpenAI.Request('POST', 'audio/transcriptions', PostData, Map('Content-Type', hdr_ContentType))
				return OpenAI.Audio.Transcription(JSON.parse(res.responseText))
			}
		}
	}

	class File {
		id         := ''
		object     := ''
		bytes      := 0
		created_at := 0
		filename   := ''
		purpose    := ''

		__New(id, object?, bytes?, created_at?, filename?, purpose?)
		{
			if id
			&& !IsSet(object)
			&& !IsSet(bytes)
			&& !IsSet(created_at)
			&& !IsSet(filename)
			&& !IsSet(purpose)
			{
				switch Type(id)
				{
				case 'Map':
					if id.Has('deleted')
					&& id['deleted']
					{
						this.id := id['id']
						return this
					}
					else
					{
						for prop in this.OwnProps()
							this.%prop% := id[prop]
					}
				case 'String':
					res := OpenAI.Request('GET', 'files/' id)
					if res.Status != 200
						throw Error(res.Status '`n' res.ResponseText)

					raw_file := JSON.parse(res.ResponseText)

					for prop in this.OwnProps()
						this.%prop% := raw_file[prop]
				default: throw Error('Invalid ID type', A_ThisFunc, 'expected Map, got: ' Type(id))
				}
				return this
			}

			for prop in this.OwnProps()
				this.%prop% := %prop%

			return this
		}

		static Upload(path, purpose := 'fine-tune')
		{
			OpenAI.File.CreateFormData(&PostData, &hdr_ContentType, {file:[path], purpose: purpose})
			res := OpenAI.Request('POST', 'files', PostData, Map('Content-Type', hdr_ContentType))
			return OpenAI.File(JSON.parse(res.responseText))

		}

		GetContent() => OpenAI.File.GetContent(this.id)
		static GetContent(id)
		{
			res := OpenAI.Request('GET', 'files/' id '/content')
			if res.Status != 200
				throw Error(res.Status '`n' res.ResponseText)

			return res.responseText
		}

		Delete() => OpenAI.File.Delete(this.id)
		static Delete(id)
		{
			res := OpenAI.Request('DELETE', 'files/' id)
			if res.Status != 200
				throw Error(res.Status '`n' res.ResponseText)

			return OpenAI.File(JSON.parse(res.ResponseText))
		}

		; CreateFormData() by tmplinshi, AHK Topic: https://autohotkey.com/boards/viewtopic.php?t=7647
		; Thanks to Coco: https://autohotkey.com/boards/viewtopic.php?p=41731#p41731
		; Modified version by SKAN, 09/May/2016
		; Rewritten by iseahound in September 2022
		; Converted to v2 by RaptorX 19/01/2023

		Class CreateFormData {
			__New(&retData, &retHeader, objParam) {

				Local CRLF := "`r`n", i, k, v, str, pvData
				; Create a random Boundary
				Local Boundary := OpenAI.File.CreateFormData.RandomBoundary()
				Local BoundaryLine := "------------------------------" . Boundary

				; Create an IStream backed with movable memory.
				hData := DllCall("GlobalAlloc", "uint", 0x2, "uptr", 0, "ptr")
				DllCall("ole32\CreateStreamOnHGlobal", "ptr", hData, "int", False, "ptr*", &pStream:=0, "uint")
				OpenAI.File.CreateFormData.pStream := pStream

				; Loop input paramters
				For k, v in objParam.OwnProps()
				{
					If IsObject(v) {
						For i, FileName in v
						{
						str := BoundaryLine . CRLF
							. 'Content-Disposition: form-data; name="' . k . '"; filename="' . FileName . '"' . CRLF
							. 'Content-Type: ' . OpenAI.File.CreateFormData.MimeType(FileName) . CRLF . CRLF

						OpenAI.File.CreateFormData.StrPutUTF8(str)
						OpenAI.File.CreateFormData.LoadFromFile(Filename)
						OpenAI.File.CreateFormData.StrPutUTF8(CRLF)

						}
					} Else {
						str := BoundaryLine . CRLF
						. 'Content-Disposition: form-data; name="' . k '"' . CRLF . CRLF
						. v . CRLF
						OpenAI.File.CreateFormData.StrPutUTF8(str)
					}
				}

				OpenAI.File.CreateFormData.StrPutUTF8(BoundaryLine . "--" . CRLF)

				OpenAI.File.CreateFormData.pStream := ObjRelease(pStream) ; Should be 0.
				pData := DllCall("GlobalLock", "ptr", hData, "ptr")
				size := DllCall("GlobalSize", "ptr", pData, "uptr")

				; Create a bytearray and copy data in to it.
				static VT_UI1 := 0x11
				retData := ComObjArray(VT_UI1, size)
				pvData  := NumGet(ComObjValue(retData), 8 + A_PtrSize , "ptr")
				DllCall("RtlMoveMemory", "Ptr", pvData, "Ptr", pData, "Ptr", size)

				DllCall("GlobalUnlock", "ptr", hData)
				DllCall("GlobalFree", "Ptr", hData, "Ptr")                   ; free global memory

				retHeader := "multipart/form-data; boundary=----------------------------" . Boundary
			}

			static StrPutUTF8(str) {
				buf := Buffer(StrPut(str, "UTF-8") - 1) ; remove null terminator
				StrPut(str, buf, buf.size, "UTF-8")
				DllCall("shlwapi\IStream_Write", "ptr", OpenAI.File.CreateFormData.pStream, "ptr", buf.Ptr, "uint", buf.Size, "uint")
			}

			static LoadFromFile(filepath) {
				DllCall("shlwapi\SHCreateStreamOnFileEx"
					,   "wstr", filepath
					,   "uint", 0x0             ; STGM_READ
					,   "uint", 0x80            ; FILE_ATTRIBUTE_NORMAL
					,    "int", False            ; fCreate is ignored when STGM_CREATE is set.
					,    "ptr", 0               ; pstmTemplate (reserved)
					,   "ptr*", &pFileStream:=0
					,   "uint")
				DllCall("shlwapi\IStream_Size", "ptr", pFileStream, "uint64*", &size:=0, "uint")
				DllCall("shlwapi\IStream_Copy", "ptr", pFileStream , "ptr", OpenAI.File.CreateFormData.pStream, "uint", size, "uint")
				ObjRelease(pFileStream)
			}

			static RandomBoundary() {
				static str := "0|1|2|3|4|5|6|7|8|9|a|b|c|d|e|f|g|h|i|j|k|l|m|n|o|p|q|r|s|t|u|v|w|x|y|z"
				str := Sort(str, 'D| Random')
				str := StrReplace(str, "|")
				Return SubStr(str, 1, 12)
			}

			static MimeType(FileName) {
				n := FileOpen(FileName, "r").ReadUInt()
				Return (n   = 0x474E5089) ? "image/png"
				: (n        = 0x38464947) ? "image/gif"
				: (n&0xFFFF = 0x4D42   ) ? "image/bmp"
				: (n&0xFFFF = 0xD8FF   ) ? "image/jpeg"
				: (n&0xFFFF = 0x4949   ) ? "image/tiff"
				: (n&0xFFFF = 0x4D4D   ) ? "image/tiff"
				: "application/octet-stream"
			}
		}
	}

	class Files extends Map {
		__New()
		{
			res := OpenAI.Request('GET', 'files')
			if res.Status != 200
				throw Error(res.Status '`n' res.ResponseText)

			raw_files := JSON.parse(res.ResponseText)
			for wFile in raw_files['data']
				this.Set(wFile['id'], OpenAI.File(wFile))
		}
	}
}