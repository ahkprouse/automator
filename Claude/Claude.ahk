
#Requires AutoHotkey v2.0
#Include .\lib\cJson.ahk\Dist\JSON.ahk

/**
 * @description Claude AI Wrapper class for AHK
 * @author RaptorX
 * @date 2025/02/26
 * @version 0.2.0
 */
class ClaudeAI {
	static headers := Map(
		'anthropic-version', '2023-06-01',
		'content-type', 'application/json',
		'x-api-key', '',
	)
	static token {
		get => ClaudeAI.headers['x-api-key']
		set {
			http := ComObject('WinHttp.WinHttpRequest.5.1')

			http.Open('POST','https://api.anthropic.com/v1/messages')

			for header, hValue in ClaudeAI.headers
				try http.SetRequestHeader(header, hValue)

			http.SetRequestHeader('x-api-key', value)
			http.Send('{"model":"claude-3-sonnet-20240229","max_tokens":1,"messages":[{"role":"user","content":"Hello"}]}')

			if http.Status != 200
			{
				OutputDebug http.Status '`n' http.ResponseText '`n'
				return false
			}

			return ClaudeAI.headers['x-api-key'] := value
		}
	}

	static authenticated {
		get => !!ClaudeAI.headers['x-api-key']
	}

	static Authenticate(api_key) => ClaudeAI.token := api_key

	static Request(method, endpoint, body, user_headers:=Map())
	{
		http := ComObject('WinHttp.WinHttpRequest.5.1')
		if !ClaudeAI.authenticated
			throw Error('Unauthorized.`nYou must authenticate first', -2)

		http.Open(method, 'https://api.anthropic.com/v1/' endpoint)
		for header, hValue in ClaudeAI.headers
		{
			if !header
				continue
			http.SetRequestHeader(header, hValue)
		}

		for header, hValue in user_headers
		{
			if !header
				continue
			http.SetRequestHeader(header, hValue)
		}

		http.Send(body)
		; Create a custom object with the correct UTF-8 response
		return {
			Status: http.Status,
			ResponseText: ConvertSafeArraytoUTF8(http.ResponseBody),
			ResponseBody: http.ResponseBody,
			ResponseStream: http.ResponseStream,
			ResponseHeaders: http.GetAllResponseHeaders(),
		}

		ConvertSafeArraytoUTF8(safe_array)
		{
			; Convert the response body to UTF-8
			responseBody := safe_array
			size := responseBody.MaxIndex() + 1
			rawBuffer := Buffer(size)
			DllCall("OleAut32.dll\SafeArrayAccessData", "Ptr", ComObjValue(responseBody), "Ptr*", &pdata:=0)
			DllCall("RtlMoveMemory", "Ptr", rawBuffer.Ptr, "Ptr", pdata, "Ptr", size)
			DllCall("OleAut32.dll\SafeArrayUnaccessData", "Ptr", ComObjValue(responseBody))
			return utf8 := StrGet(rawBuffer, "UTF-8")
		}
	}

	class Messages {
		; static model          := ''
		; static messages       := ''
		; static max_tokens     := ''
		; static metadata       := ''
		; static stop_sequences := ''
		; static stream         := ''
		; static system         := ''
		; static temperature    := ''
		; static tools          := ''
		; static top_k          := ''
		; static top_p          := ''

		/**
		 *
		 * @param {'claude-3-7-sonnet-latest'|'claude-3-5-sonnet-latest'|'claude-3-5-opus-latest'|'claude-3-5-haiku-latest'} model
		 * @param {Array}   messages
		 * @param {Integer} max_tokens
		 * @param {Object}  metadata
		 * @param {String}  stop_sequences
		 * @param {Boolean} stream
		 * @param {String}  system
		 * @param {Float}   temperature
		 * @param {Object}  tool_choice
		 * @param {Object}  tools
		 * @param {Integer} top_k
		 * @param {Integer} top_p
		 * @param {Object}  thinking
		 */
		static Create(
			model, messages, max_tokens?, metadata?, stop_sequences?,
			stream?, system?, temperature?, tool_choice?, tools?, top_k?, top_p?, thinking?
		)
		{
			if !(model is String)
				throw TypeError(
					'Invalid Model type, Expected a string but got: ' Type(model),
					A_ThisFunc,
					Model
				)
			if !(messages is Array)
				throw TypeError(
					'Invalid Messages type, Expected an array but got: ' Type(messages),
					A_ThisFunc,
					Messages
				)
			if IsSet(temperature) && !(temperature is Float)
				throw TypeError(
					'Invalid Temperature type, Expected a float but got: ' Type(temperature),
					A_ThisFunc,
					Temperature
				)
			if IsSet(temperature) && (temperature < 0.0 || temperature > 1.0)
				throw Error('Invalid Temperature, temperature must be between 0.0 and 1.0 got: ' temperature)

			if IsSet(thinking) && !(thinking is Object)
				throw TypeError(
					'Invalid Thinking type, Expected an object but got: ' Type(thinking),
					A_ThisFunc,
					Thinking
				)

			body := {}
			params := [
				'model',
				'messages',
				'max_tokens',
				'metadata',
				'stop_sequences',
				'stream',
				'system',
				'temperature',
				'tool_choice',
				'tools',
				'top_k',
				'top_p',
				'thinking'
			]
			for param in params
			{
				if IsSet(%param%)
					body.%param% := %param%
			}

			if !body.HasProp('max_tokens')
				body.max_tokens := 500

			; OutputDebug JSON.stringify(body) '`n'
			return ClaudeAI.Messages.Response(ClaudeAI.Request('POST', 'messages', JSON.stringify(body)))
		}

		class Response extends Map {
			__New(raw_response)
			{
				response := JSON.parse(raw_response.ResponseText)
				if raw_response.Status != 200
					throw response

				for key, value in response
					this[key] := value
			}
		}
	}

}