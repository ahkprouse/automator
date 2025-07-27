#Requires AutoHotkey v2.0

#Include <v2\Yunit\Yunit>
#Include <v2\Yunit\Window>
#Include ..\OpenAI.ahk

inifile := '..\examples\auth.ini'

Yunit.Use(YunitWindow).Test(UnitTestsOpenAI)

class UnitTestsOpenAI {
	basic_authentication()
	{
		token := IniRead(inifile, 'API', 'token')
		orgID := IniRead(inifile, 'API', 'orgID')

		Yunit.Assert(OpenAI.Authenticate(token, orgID), 'Authentication failed')
		Yunit.Assert(OpenAI.token == token, 'Token not set')
		Yunit.Assert(OpenAI.orgID == orgID, 'OrgID not set')
		Yunit.Assert(OpenAI.authenticated, 'Not authenticated')
		Yunit.Assert(OpenAI.basic_headers['Authorization'] == 'Bearer ' token, 'Bearer token not set or invalid')
		Yunit.Assert(OpenAI.basic_headers['OpenAI-Organization'] == orgID, 'OpenAI-Organization not set or invalid')
	}

	class t•1Requests {
		begin() => OpenAI.Authenticate(IniRead(iniFile, 'API', 'token'),IniRead(iniFile, 'API', 'orgID'))

		t1•request_no_body()
		{
			res := OpenAI.Request('GET', 'models')
			Yunit.Assert(res.status == 200, 'Status code not 200')
			Yunit.Assert(res.ResponseText, 'Response text is empty')
			Yunit.Assert(JSON.parse(res.ResponseText), 'Response text is not JSON')
		}

		t2•request_body_audio()
		{
			body := Map(
				'model', 'tts-1',
				'voice', 'alloy',
				'input', 'The quick brown fox jumped over the lazy dog.',
			)
			res := OpenAI.Request('POST', 'audio/speech', body)

			Yunit.Assert(res.status == 200, 'Status code not 200')
			Yunit.Assert(res.ResponseStream, 'Response text is empty')
		}

		; t3•request_body_image()
		; {
		; 	body := Map(
		; 		'model' , 'dall-e-3',
		; 		'prompt', 'A cute baby sea otter',
		; 		'n'     , 1,
		; 		'size'  , '1024x1024'
		; 	)
		; 	res := OpenAI.Request('POST', 'images/generations', body)

		; 	Yunit.Assert(res.status == 200, 'Status code not 200')
		; 	Yunit.Assert(res.ResponseText, 'Response text is empty')
		; 	Yunit.Assert(output := JSON.parse(res.ResponseText), 'Response text is not JSON')
		; 	A_Clipboard := output['data'][1]['url']
		; }
	}

	class t•2Models {
		begin() => OpenAI.Authenticate(IniRead(iniFile, 'API', 'token'),IniRead(iniFile, 'API', 'orgID'))

		t1•listing_models()
		{
			models := OpenAI.Models()
			Yunit.Assert(models is OpenAI.Models, 'Response is not an instance of OpenAI.Models')
			Yunit.Assert(models.Count > 0, 'No models found')

			for id, model in models
			{
				Yunit.Assert(model is OpenAI.Model, 'Model is not an instance of OpenAI.Model')

				for prop in OpenAI.Model.OwnProps()
				{
					if prop = 'prototype'
						continue
					Yunit.Assert(model.HasProp(prop), 'Model is missing property: ' prop)
				}
			}
		}

		t2•retrieve_model()
		{
			gpt4o := OpenAI.Model('gpt-4o')
			Yunit.Assert(gpt4o is OpenAI.Model, 'Model is not an instance of OpenAI.Model')

			for prop in OpenAI.Model.OwnProps()
			{
				if prop = 'prototype'
					continue
				Yunit.Assert(gpt4o.HasProp(prop), 'Model is missing property: ' prop)
			}
		}

		t3•retrieve_model_from_list()
		{
			models := OpenAI.Models()
			gpt4o := models['gpt-4o']

			Yunit.Assert(models is OpenAI.Models, 'Model is not an instance of OpenAI.Models')
			Yunit.Assert(gpt4o is OpenAI.Model, 'Model is not an instance of OpenAI.Model')

			for prop in OpenAI.Model.OwnProps()
			{
				if prop = 'prototype'
					continue
				Yunit.Assert(gpt4o.HasProp(prop), 'Model is missing property: ' prop)
			}


		}
	}

	class t•3Files {
		begin() => OpenAI.Authenticate(IniRead(iniFile, 'API', 'token'),IniRead(iniFile, 'API', 'orgID'))
		end() {
			while FileExist('my_test_file.txt')
				try FileDelete('my_test_file.txt')
		}

		t1•listing_files()
		{
			files := OpenAI.Files()
			Yunit.Assert(files is OpenAI.Files, 'Response is not an instance of OpenAI.Files')
			for id, wFile in files
				Yunit.Assert(wFile is OpenAI.File, 'File is not an instance of OpenAI.File')
		}

		t2•retrieve_file()
		{
			for id in  OpenAI.Files()
			{
				file_id := id
				break
			}

			wFile := OpenAI.File(file_id)
			Yunit.Assert(wFile is OpenAI.File, 'File is not an instance of OpenAI.File')
		}

		t3•create_file()
		{
			hFile := FileOpen('my_test_file.txt', 'w-', 'utf-8')
			hFile.Write('Hello, World!')
			hFile.Close()

			wFile := OpenAI.File.Upload('my_test_file.txt', 'assistants')
			Yunit.Assert(wFile is OpenAI.File, 'File is not an instance of OpenAI.File')

			file_id := wFile.id
			wFile := OpenAI.File(file_id)
			Yunit.Assert(wFile is OpenAI.File, 'File is not an instance of OpenAI.File')

			wFile.Delete()
			try OpenAI.File(file_id)
			catch
				Yunit.Assert(true)
		}

		t4•retrieve_file_contents()
		{
			hFile := FileOpen('my_test_file.txt', 'w-', 'utf-8')
			hFile.Write('{"prompt": "What is the answer to 2+2","completion": "4"}')
			hFile.Close()

			wFile := OpenAI.File.Upload('my_test_file.txt')
			contents := wFile.GetContent()
			Yunit.Assert(contents, 'File contents are empty')
		}
	}

	class t•4ChatCompletion {
		begin() => OpenAI.Authenticate(IniRead(iniFile, 'API', 'token'),IniRead(iniFile, 'API', 'orgID'))

		basic_chat_completion()
		{
			conversation := OpenAI.Chat.Completion.Messages()
			conversation.Push({role: 'user', content: 'Hello! Give me a random fact that you might find interesting.'})

			gpt4o := OpenAI.Model('gpt-4o')
			res := OpenAI.Chat(gpt4o, conversation)

			Yunit.Assert(res.response is OpenAI.Chat.Completion, 'Response is not an instance of OpenAI.Completion')
			Yunit.Assert(res.response.HasOwnProp('choices'))
			Yunit.Assert(
				res.response.choices is OpenAI.Chat.Completion.Choices,
				'Choices is not an OpenAI.Chat.Completion.Choices'
			)
			Yunit.Assert(res.response.choices.Length > 0, 'No choices found')
			Yunit.Assert(
				res.response.choices[1] is OpenAI.Chat.Completion.Choice,
				'Choice is not an instance of OpenAI.Chat.Completion.Choice'
			)
			Yunit.Assert(res.response.choices[1].HasOwnProp('message'), 'Choice is missing message')
			gpt4o := OpenAI.Model('gpt-4o')
			client := OpenAI.Chat()
			client.Create(gpt4o, conversation)
		}
	}

	class t•5Audio{
		begin() => OpenAI.Authenticate(IniRead(iniFile, 'API', 'token'),IniRead(iniFile, 'API', 'orgID'))

		t1•transcription()
		{
			model := OpenAI.Model('whisper-1')
			transcription := OpenAI.Audio.Transcription.create('527426.wav', model)
			Yunit.Assert(transcription is OpenAI.Audio.Transcription, 'Transcription is not an instance of OpenAI.Audio.Transcription')
			Yunit.Assert(transcription.HasOwnProp('text'), 'Transcription is missing')
		}
	}
}