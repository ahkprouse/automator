class OpenAI {
    static create(path, model, language?, prompt?, response_format?, temperature?, timestamp_granularities?) {
        switch Type(model) {
            case 'String':
                model := OpenAI.Model(model)
        }
        
        data := {
            file: [path],
            model: model.id,
            language: language ?? 'en',
            prompt: prompt ?? '',
            response_format: response_format ?? 'json',
            temperature: temperature ?? 0,
            timestamp_granularities: timestamp_granularities ?? 'segment'
        }
        
        MsgBox(data.language)
        
        OpenAI.File.CreateFormData(&PostData, &hdr_ContentType, data)
        res := OpenAI.Request('POST', 'audio/transcriptions', PostData, Map('Content-Type', hdr_ContentType, 'Accept', '*/*'))
        text := OpenAI.ConvertResponseBody(res)
        return OpenAI.Audio.Transcription(JSON.parse(res.responseText))
    }

    static Request(method, endpoint, body := '', user_headers := Map()) {
        static http := ComObject('WinHttp.WinHttpRequest.5.1')
        
        if !OpenAI.authenticated
            throw Error('OpenAI not authenticated')
        
        http.Open(method, 'https://api.openai.com/v1/' endpoint)
        
        for header, value in OpenAI.basic_headers {
            if user_headers.Has(header)
                continue
            if value
                http.SetRequestHeader(header, value)
        }
        
        for header, value in user_headers
            http.SetRequestHeader(header, value)
        
        switch Type(body) {
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
        
        return http
    }

    static ConvertResponseBody(oHTTP) {
        bytes := oHTTP.Responsebody
        text := ""
        loop oHTTP.GetResponseHeader('Content-Length')
            text .= Chr(bytes[A_Index-1])
        return text
    }
}
