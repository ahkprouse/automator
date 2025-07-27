; Execute JavaScript in the WebView and get correctly formatted return value

#Include <_JXON> ; Needs the jxon-library to interpret JSON correctly.

static response_handler := WebView2.Handler(myhandler)
wb.ExecuteScript('document.URL', response_handler) ; Example JavaScript-command: document.URL (the currently opened URL)
myHandler(response_handler, errorCode, result){
	result_json := strget(result)
	url := jxon_load(&result_json)
}