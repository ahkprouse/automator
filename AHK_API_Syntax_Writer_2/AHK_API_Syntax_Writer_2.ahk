; Joe Glines API syntax writer  
; http://the-automator.com/autohotkey-web-service-api-syntax-writer-automate-writing-your-winhttp-requests-with-my-syntax-writer/
; https://the-automator.com/download/AHK_API_Syntax_Writer_2.ahk
#SingleInstance, Force
#NoEnv
IconSize:=32
Menu, tray, icon, %A_WinDir%\system32\SHELL32.dll, 143
;***********************tray items********************************.
Menu, Tray, NoStandard ;removes default options
Menu, Tray, Add, Helpful Links, Helpful_Links
Menu, Tray, Add, About this program, About
Menu, Tray, Add,
Menu, Tray, Add, Reload
Menu, Tray, Add, Edit
Menu, Tray, Add, Exit
;******************************


;***********Begin Menus*******************
;***********API_Calls*******************
Menu,API_Examples,Add,** Wiki Request Methods **, API_Examples_Methods_Wiki ;WIKI lookup
Menu,API_Examples,Add,** MSDN WinHTTP Object ** , API_Examples_Methods_MSDN ;object model
Menu,API_Examples,Add,** CURL documentation (Adapt from CURL examples) ** , API_Examples_Methods_CURL ;object model
Menu,API_Examples,Add,

Menu,API_Examples,Add,WinHTTP Request Template  , API_Examples_WinHTTP_Request ;Basic winHTTP Example
Menu,API_Examples,Add,XHR Request Template    , API_Examples_XHR ;XHR Request
Menu,API_Examples,Add,XHR Request Template with Wait    , API_Examples_XHR_with_Wait ;XHR Request
Menu,API_Examples,Add,XHR Request Template Connected to IE Window, API_Examples_XHR_Connect_to_IE_Instance ;XHR Request connected to IE window

Menu,API_Examples,Add,XHR Template for Binary file   , API_Examples_XHR_for_Binary ;XHR for Binary
Menu,API_Examples,Add,Params in Key-Value pairs , API_Examples_Params
Menu,API_Examples,Add,
Menu,API_Examples,Add,IniRead and Auth File     , API_Examples_Authorization_INI_and_File

Menu,API_Examples,Icon,** Wiki Request Methods **   , %A_WinDir%\system32\netshell.dll,86
Menu,API_Examples,Icon,** MSDN WinHTTP Object **    , %A_WinDir%\system32\netshell.dll,86
Menu,API_Examples,Icon,** CURL documentation (Adapt from CURL examples) **     , %A_WinDir%\system32\netshell.dll,86

Menu,API_Examples,Icon,winHTTP Request Template     , %A_WinDir%\system32\shell32.dll,75
Menu,API_Examples,Icon,XHR Template for Binary file      , %A_WinDir%\system32\shell32.dll,75
Menu,API_Examples,Icon,IniRead and Auth File        , %A_WinDir%\system32\shell32.dll,212
Menu,API_Examples,Icon,Params in Key-Value pairs    , %A_WinDir%\system32\shell32.dll,105

Menu,API,Add,Example API Calls, :API_Examples ;***********Add Options*******************
Menu,API,Icon,Example API Calls,           %A_WinDir%\system32\shell32.dll,278

;***********API_Options*******************
;~  Menu,API_Options,Add,XXX Update XXX , API_PLACEHOLDER
Menu,API_Options,Add,Fiddler                         , API_Options_Fiddler
Menu,API_Options,Add,Prevent Redirect                , API_Options_Prevent_Redirect
Menu,API_Options,Add,Proxy                           , API_Options_SetProxy
Menu,API_Options,Add,Credentials                     , API_Options_SetCredentials

Menu,API_Options,Icon,Fiddler                        , %A_WinDir%\system32\netshell.dll,1
Menu,API_Options,Icon,Prevent Redirect               , %A_WinDir%\system32\netshell.dll,94
Menu,API_Options,Icon,Proxy                          , %A_WinDir%\system32\netshell.dll,90
Menu,API_Options,Icon,Credentials                    , %A_WinDir%\system32\shell32.dll,212
Menu,API,Add,Set Options, :API_Options ;***********Add Options*******************
Menu,API,Icon,Set Options,     %A_WinDir%\system32\shell32.dll,68
;***********End of Options*******************


;***********API_SetHeaders*******************
Menu,API_SetHeaders,Add,** Wiki Refernce **          , API_SetHeader_Wiki
Menu,API_SetHeaders,Add,Accept                       , API_SetHeader_Encoding

Menu,API_SetHeaders,Add,Accept Encoding              , API_SetHeader_Accept_Encoding
Menu,API_SetHeaders,Add,Accept Language              , API_SetHeader_Accept_Language
Menu,API_SetHeaders,Add,Authorization / Bearer Token , API_SetHeader_Authorization_Bearer_Token
Menu,API_SetHeaders,Add,Cookies                      , API_SetHeader_Cookie
Menu,API_SetHeaders,Add,Connection                   , API_SetHeader_Connection
Menu,API_SetHeaders,Add,Content Type                 , API_SetHeader_Content_Type
Menu,API_SetHeaders,Add,If Modified Since            , API_SetHeader_If_Modified_Since
Menu,API_SetHeaders,Add,Refering URL                 , API_SetHeader_Referer
Menu,API_SetHeaders,Add,User Agent                   , API_SetHeader_UserAgent

Menu,API_SetHeaders,Icon,** Wiki Refernce **             ,     %A_WinDir%\system32\netshell.dll,86
Menu,API_SetHeaders,Icon,Accept                          ,     %A_WinDir%\system32\mmcndmgr.dll,119

Menu,API_SetHeaders,Icon,Accept Encoding                 ,     %A_WinDir%\system32\shell32.dll,81
Menu,API_SetHeaders,Icon,Accept Language                 ,     %A_WinDir%\system32\shell32.dll,171
Menu,API_SetHeaders,Icon,Authorization / Bearer Token    ,     %A_WinDir%\system32\shell32.dll,212
Menu,API_SetHeaders,Icon,cookies                         ,     %A_WinDir%\system32\shell32.dll,85
Menu,API_SetHeaders,Icon,Connection                      ,     %A_WinDir%\system32\shell32.dll,38
Menu,API_SetHeaders,Icon,Content Type                    ,     %A_WinDir%\system32\shell32.dll,111
Menu,API_SetHeaders,Icon,If Modified Since               ,     %A_WinDir%\system32\shell32.dll,266
Menu,API_SetHeaders,Icon,Refering URL                    ,     %A_WinDir%\system32\netshell.dll,87
Menu,API_SetHeaders,Icon,User Agent                      ,     %A_WinDir%\system32\wmploc.dll,123

Menu,API,Add, Set Headers, :API_SetHeaders ;***********Add Set_Headers*******************
Menu,API,Icon,Set Headers,     %A_WinDir%\system32\mmcndmgr.dll,59

;~  Icons  https://diymediahome.org/windows-icons-reference-list-with-details-locations-images/
;**********End of SetHeaders********************

;***********API_GetHeaders*******************

Menu,API_GetHeaders,Add,** Wiki Response Codes **    , API_GetHeader_Wiki
Menu,API_GetHeaders,Add,Cache                        , API_GetHeader_Cache

Menu,API_GetHeaders,Add,Content Length               , API_GetHeader_ContentLength
Menu,API_GetHeaders,Add,Content Encoding             , API_GetHeader_Content_Encoding
Menu,API_GetHeaders,Add,Content Type                 , API_GetHeader_Content_Type
Menu,API_GetHeaders,Add,Last Modified                , API_GetHeaders_LastModified

Menu,API_GetHeaders,Icon,** Wiki Response Codes **   ,     %A_WinDir%\system32\netshell.dll,86
Menu,API_GetHeaders,Icon,Cache                       ,     %A_WinDir%\system32\mmcndmgr.dll,109

Menu,API_GetHeaders,Icon,Content Length              ,     %A_WinDir%\system32\shell32.dll,160
Menu,API_GetHeaders,Icon,Content Encoding            ,     %A_WinDir%\system32\shell32.dll,81
Menu,API_GetHeaders,Icon,Content Type                ,     %A_WinDir%\system32\shell32.dll,111
Menu,API_GetHeaders,Icon,Last Modified               ,     %A_WinDir%\system32\shell32.dll,266

Menu,API,Add, Get Headers, :API_GetHeaders ;***********Add Get_Headers*******************
Menu,API,Icon,Get Headers,     %A_WinDir%\system32\mmcndmgr.dll,123
;******************************

;***********API_Response*******************
Menu,API_Response,Add,Response , API_Response
Menu,API_Response,Add,text from Response Body, API_Response_Body
Menu,API_Response,Add,** Code definitions **, API_ResponseCodes


;***********API_Response_Parse_XML*******************
Menu,API_Response_XML,Add,Parse XML		, API_Response_XML_Parse
Menu,API_Response_XML,Add,Pretty			, API_Response_XML_Pretty
Menu,API_response_XML,Icon,Parse XML		,     %A_WinDir%\system32\shell32.dll,42
Menu,API_response_XML,Icon,Pretty			,     %A_WinDir%\system32\urlmon.dll,1


Menu,API_Response,Icon,** Code definitions **     ,     %A_WinDir%\system32\netshell.dll,86
Menu,API_response,Icon,Response				,     %A_WinDir%\system32\shell32.dll,171 
Menu,API_response,Icon,text from Response Body	,     %A_WinDir%\system32\shell32.dll,170 
Menu,API_Response,Add, Parse XML, :API_Response_XML ;***********Add API_Response_XML*******************
Menu,API_response,Icon,Parse XML		,     %A_WinDir%\system32\shell32.dll,42

;***********API_Response_JSON*******************
Menu,API_Response_JSON,Add,Parse JSON		, API_HTTP_Parse_JSON


Menu,API_response_JSON,Icon,Parse JSON		,     %A_WinDir%\system32\dsuiext.dll,3

Menu,API_Response,Add, Parse JSON, :API_Response_JSON ;***********Add Response_JSON*******************
Menu,API_response,Icon,Parse JSON		      ,     %A_WinDir%\system32\dsuiext.dll,3


Menu,API,Add, Response, :API_Response ;***********Add Options*******************
Menu,API,Icon,Response,     %A_WinDir%\system32\shell32.dll,171





;******************************
;***********Help*******************
;******************************
Menu,API,Add, ;***********spacer*******************
Menu,API,Add, Helpful links, Helpful_Links
return

Ralt::Reload
;******************************
^Lbutton::Menu, API, Show  ; right mouse and windows ;this is causing issues with screen clipper
return
;******************************
API_PLACEHOLDER:
return

;******************************
;***********API_Examples call/ Webservices *******************
API_Examples_Params:
Store:=ClipboardAll  ;****Store clipboard ****
Clipboard =
( Join`r
  ; put your key value pairs in this object & it will take care of prepending ? and & for you
QS:=QueryString_Builder({"q":"AutoHotkey","format":"xml","ia":"web"})

;********************QueryString Builder Function***********************************
QueryString_Builder(kvp){
for key, value in kvp
  queryString.=((A_Index="1")?(url "?"):("&")) key "=" value
return queryString
}
)
Gosub Paste_and_Restore_Stored_Clipboard
return

API_Examples_Methods_Wiki:
Run https://en.wikipedia.org/wiki/Hypertext_Transfer_Protocol#Request_methods
return

API_Examples_Methods_MSDN:
Run https://msdn.microsoft.com/en-us/library/windows/desktop/aa384106(v=vs.85).aspx
return

API_Examples_Methods_CURL:
Run https://curl.haxx.se/docs/manpage.html
return

API_Examples_WinHTTP_Request:
Store:=ClipboardAll  ;****Store clipboard ****
Clipboard =
(Join`r %
Endpoint:="http://api.duckduckgo.com/" 
QS:=QueryString_Builder({"":"","":"","":""})

;~  Payload:="" ;This is only for a POST request
;******************************
HTTP := ComObjCreate("WinHttp.WinHttpRequest.5.1") ;Create COM Object
HTTP.Open("GET", Endpoint  QS) ;GET & POST are most frequent, Make sure you UPPERCASE
;~ HTTP.SetTimeouts(0,60000,30000,120000) ;Modify wait for response to 2 minutes
;~ HTTP.Option(6):=0 ;Prevents redirect  
;~ HTTP.SetRequestHeader("Content-Language","en-US") ;Specify what language to return
;~ HTTP.SetRequestHeader("Accept", "text/html;charset=utf-8") ;Stipulate what you will accept in your response
;~ HTTP.SetRequestHeader("Content-Type", "application/x-www-form-urlencoded;charset=utf-8") ;specifcy the type of content you get back
;~ HTTP.SetRequestHeader("User-Agent","Mozilla/4.0 (compatible; Win32; WinHttp.WinHttpRequest.5)") ;Add a useragent (sometimes one is needed to get data returned)
HTTP.Send(Payload) ;If POST request put data in "Payload" variable
;~ HTTP.WaitForResponse() ;Wait for response before moving forward.  Use with SetTimeouts above ;https://www.autohotkey.com/boards/viewtopic.php?f=74&t=9136
DebugWindow(HTTP.ResponseText,1,1,500)
return
)
Gosub Paste_and_Restore_Stored_Clipboard
return





API_Examples_XHR:
Store:=ClipboardAll  ;****Store clipboard ****
Clipboard =
(Join`r
;***********XHR  https://en.wikipedia.org/wiki/XMLHttpRequest*******************
XHR:=ComObjCreate("MSXML2.XMLHTTP.6.0") ;https://msdn.microsoft.com/en-us/library/ms535874(v=vs.85).aspxu
XHR.Open("GET",URL,False) ;open( Method, URL, Asynchronous, UserName, Password )
;~ XHR.setRequestHeader("Name","Value") ; Set Headers here.  Not all work.  :(
XHR.Send()
while(XHR.ReadyState!=4) ;Wait for it to complete
	Sleep,50
DebugWindow(XHR.ResponseBody,1,1)
)
Gosub Paste_and_Restore_Stored_Clipboard
return

API_Examples_XHR_with_Wait:
Store:=ClipboardAll  ;****Store clipboard ****
Clipboard =
(Join`r %
;***********XHR  https://en.wikipedia.org/wiki/XMLHttpRequest*******************
XHR:=ComObjCreate("MSXML2.XMLHTTP.6.0") ;https://msdn.microsoft.com/en-us/library/ms535874(v=vs.85).aspxu
XHR.Open("GET",URL,true) ;open(Method,URL,Asynchronous,UserName,Password)
;~ XHR.setRequestHeader("Name","Value") ; Set Headers here.  Not all work.  :(
XHR.Send()
req.onreadystatechange := Func("Ready") ;The onreadystatechange property specifies a function to be executed every time the status of the XMLHttpRequest object changes

;********************Wait for Server response***********************************
Ready() {
	global XHR
	if (XHR.readyState != 4) ; 0=Request not initialized, 1=Request has been set up, 2=request has been sent, 3=request is in process, 4=request is completed
		return
	if (XHR.status = 200) ; OK
	    DebugWindow(XHR.responseText,1,1) 
	;~ DebugWindow(XHR.responseXML,1,1) 
	;~ DebugWindow(XHR.ResponseBody,1,1) ;Use XHR.response if it was a POST request
	else
		MsgBox %  XHR.StatusText "`n`n" XHR.GetAllResponseHeaders
}
)
Gosub Paste_and_Restore_Stored_Clipboard
return


API_Examples_XHR_Connect_to_IE_Instance:
Store:=ClipboardAll  ;****Store clipboard ****
Clipboard =
(Join`r
oWindow := ComObject(9,ComObjQuery(WBGet(),"{332C4427-26CB-11D0-B483-00C04FD90119}","{332C4427-26CB-11D0-B483-00C04FD90119}"),1)
XHR := oWindow.XMLHttpRequest()
;***********XHR  https://en.wikipedia.org/wiki/XMLHttpRequest*******************
XHR.Open("GET",URL,False) ;open(Method,URL,Asynchronous,UserName,Password)
;~ XHR.setRequestHeader("Name","Value") ; Set Headers here however not all work  :(
XHR.Send()
while(XHR.ReadyState!=4) ;Wait for it to complete
	Sleep,50
DebugWindow(XHR.ResponseBody,1,1)
)
Gosub Paste_and_Restore_Stored_Clipboard
return





API_Examples_XHR_for_Binary:
Store:=ClipboardAll  ;****Store clipboard ****
Clipboard =
( Join`r
;***********This will write a binary file to the folder where script is running*******************
;***********Another great reason to use MSXML2 is that it will use your IE cookies so you don't have to deal with Authentication  :)*******************
;***********Also read this post for pros/cons of each method:  https://autohotkey.com/boards/viewtopic.php?t=9554*******************
URL:="http://the-automator.com/mn/wp-content/uploads/2016/02/not_working.jpg"
SplitPath,URL,File_Name
HTTP:=ComObjCreate("MSXML2.XMLHTTP.6.0") ;https://msdn.microsoft.com/en-us/library/ms535874(v=vs.85).aspxu
ADODB:=ComObjCreate("ADODB.Stream") ;https://docs.microsoft.com/en-us/sql/ado/reference/ado-glossary
ADODB.Type:=1 ;set to 1 which is Binary  2 is text
HTTP.Open("GET",URL,1) ;open( Method, URL, Asynchronous, UserName, Password )
HTTP.Send()
while(HTTP.ReadyState!=4) ;Wait for it to complete
	Sleep,50
ADODB.Open() ;After it HTTP API call completes,
ADODB.Write(HTTP.ResponseBody) ;Write the binary data into ADODB Stream
ADODB.SaveToFile(A_WorkingDir "\" File_Name,2) ;Save it to a file
ADODB.Close()
)
Gosub Paste_and_Restore_Stored_Clipboard
return

API_Examples_Authorization_INI_and_File:
Store:=ClipboardAll  ;****Store clipboard ****
Clipboard =
( Join`r
IniRead, API_Token ,Auth.ini,API, Token
IniRead, API_Key   ,Auth.ini,API, Key
IniRead, API_Secret,Auth.ini,API, Secret
IniRead, API_ID    ,Auth.ini,API, ID
IniRead, API_Bearer,Auth.ini,API, Bearer
)
Gosub Paste_and_Restore_Stored_Clipboard
Ini_Text:="[API]`r`nToken=`r`nKey=`r`nSecret=`r`nID=`r`nBearer=`r`n"
FileSelectFolder, Fold,,3,Where you do want to save the ini file?

IfExist,%fold%\Auth.ini
MsgBox, 4,Overwrite file?,Are you sure you want to overwrite the existing file?
IfMsgBox Yes
{
	FileDelete, %fold%\Auth.ini
	FileAppend,%Ini_text%,%Fold%\Auth.ini,UTF-16
}
IfNotExist,%fold%\Auth.ini
	FileAppend,%Ini_text%,%Fold%\Auth.ini,UTF-16

run %fold%\Auth.ini ;now open the new file
return
;***********End of Examples*******************
;******************************

;***********Options *******************
API_Options_Fiddler:
Store:=ClipboardAll  ;****Store clipboard ****
Clipboard =
( Join`r
;***********if you're running Fiddler include this setting so AutoHotkey traffic will be tracked*******************
;***********You can download a free version here: https://www.telerik.com/download/fiddler*******************
IfWinExist, Fiddler
   HTTP.SetProxy(2,"localhost:8888") ;turn off if Fiddler not running
)
Gosub Paste_and_Restore_Stored_Clipboard
return


;***********API_Options_Prevent Redirect*******************
API_Options_Prevent_Redirect:
Store:=ClipboardAll  ;****Store clipboard ****
Clipboard =
( Join`r
;***********there are a lot more options you can find here: https://msdn.microsoft.com/en-us/library/windows/desktop/aa384108(v=vs.85).aspx *******************
;***********Prevent Redirects within API Call*******************
;***********if you're receiving a Responsecode in the 300s you might need this*******************
HTTP.Option(6):=0 ;Prevents redirect
)
Gosub Paste_and_Restore_Stored_Clipboard
return

;***********API_Options_Set proxy*******************
API_Options_SetProxy:
Store:=ClipboardAll  ;****Store clipboard ****
Clipboard =
( Join`r
;***********Below is a function to detect if you need to set proxy as well as how to configure it*******************
;***********You will need to aduust the proxy settings to your specific proxy*******************
if PN:=Proxy_Needed() ;use proxy if running from work
	HTTP.SetProxy(2,"wwwgate.mydomain.com:80") ; HTTPREQUEST_PROXYSETTING_PROXY= 2;

;***********Proxy function*******************
Proxy_Needed(Proxy="wwwgate.mydomain.com:80",TestURL="http://google.com"){
try {
HTTP := ComObjCreate("HTTP.WinHttpRequest.5.1")
HTTP.Open("POST",TestURL)
HTTP.SetProxy(2,Proxy)
HTTP.Send()
return (Proxy_Needed:=1)
} catch {
HTTP := ComObjCreate("HTTP.WinHttpRequest.5.1")
HTTP.Open("POST", TestURL )
HTTP.Send()
return (Proxy_Needed:=0)
}}

)
Gosub Paste_and_Restore_Stored_Clipboard
return

;***********API_Options_Set Credentials*******************
API_Options_SetCredentials:
Store:=ClipboardAll  ;****Store clipboard ****
Clipboard =
( Join`r
;***********Can be used to set credentials *******************
HTTP.SetCredentials("api",api_Key,"0") ;for webserver
; Below might allow you to leverage that you're already logged in and you wont have to pass credentials.
HTTP.SetAutoLogonPolicy(0) ;WINHTTP_AUTOLOGON_SECURITY_LEVEL_LOW ;means I don't need to pass credentials.  :)
)
Gosub Paste_and_Restore_Stored_Clipboard
return
;***********End of Options*******************
;******************************

;***********API_SetHeaders*******************
API_SetHeader_Wiki:
run https://en.wikipedia.org/wiki/List_of_HTTP_header_fields
run https://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14

return

;***********API_SetHeader-Accept*******************
API_SetHeader_Encoding:
Store:=ClipboardAll  ;****Store clipboard ****
Clipboard =
( Join`r
;~  the Accept header field allows the client to restrict what media types the server should send back.
;***********these are a few examples*******************
HTTP.SetRequestHeader("Accept","text/xml;charset=UTF-8") ;XML
HTTP.SetRequestHeader("Accept","text/html;charset=utf-8")  ;HTML
HTTP.SetRequestHeader("Accept","text/html;application/xhtml+xml, */*") ;more variet
HTTP.SetRequestHeader("Accept","application/x-ms-application, image/jpeg, application/xaml+xml, image/gif, image/pjpeg, application/x-ms-xbap, application/vnd.ms-excel, application/vnd.ms-powerpoint, application/msword, */*") ;Not sure if this works but good list of options
HTTP.SetRequestHeader("Accept","*/*") ;  Use Accept:*/* to accept all types of content
)
Gosub Paste_and_Restore_Stored_Clipboard
return

;***********API_SetHeader_Accept-Encoding*******************
API_SetHeader_Accept_Encoding:
Store:=ClipboardAll  ;****Store clipboard ****
Clipboard =
( Join`r
;**********************Accept-Encoding*********************************
; https://en.wikipedia.org/wiki/HTTP_compression
HTTP.SetRequestHeader("Accept-Encoding","gzip, deflate")

HTTP.SetRequestHeader("Accept-Encoding", "gzip,deflate,sdch") ;sdch is Google Shared Dictionary Compression for HTTP
)
Gosub Paste_and_Restore_Stored_Clipboard
return

;***********API_SetHeader_Accept-Language*******************
API_SetHeader_Accept_Language:
Store:=ClipboardAll  ;****Store clipboard ****
Clipboard =
( Join`r
;***********Set the acceptable languages*******************
; This header displays the default language setting of the user. If a website has different language versions, it can redirect a new surfer based on this data.  It can carry multiple languages, separated by commas. The first one is the preferred language, and each other listed language can carry a "q" value, which is an estimate of the user's preference for the language (min. 0 max. 1).
HTTP.SetRequestHeader("Accept-Language","en-us,en;q=0.5") ;multiple
HTTP.SetRequestHeader("Accept-Language","en-US") ;just one
)
Gosub Paste_and_Restore_Stored_Clipboard
return

;***********API_SetHeader-Authorization Bearer token*******************
API_SetHeader_Authorization_Bearer_Token:
Store:=ClipboardAll  ;****Store clipboard ****
Clipboard =
( Join`r
;***********Provide Bearer token in Header*******************
HTTP.SetRequestHeader("Authorization","Bearer " API_Token) ;Authorization in the form of a Bearer token
)
Gosub Paste_and_Restore_Stored_Clipboard
return

;***********API_SetHeader-Cookie*******************
API_SetHeader_Cookie:
Store:=ClipboardAll  ;****Store clipboard ****
Clipboard =
( Join`r
;**********************Cookie*********************************
/*
A cookie is a piece of data that is issued by a server in an HTTP response and stored for future use by the HTTP client. The client then re-supplies the cookie value in subsequent requests to the same server. This mechanism allows the server to store user preferences and identity individual users.  Servers supply cookies by populating the set-cookie response header with the following details:
   Name:Name of the cookie
  Value: Textual value to be held by the cookie
Expires: Date/time when the cookie should be discarded by the browser.  If this field is empty the cookie expires at the end of the current browser session. This field can also be used to delete a cookie by setting a date/time in the past.
   Path: Path below which the cookie should be supplied by the browser.
 Domain: Web site domain to which this cookie applies.  This will default to the current domain and attempts to set cookies on other domains are subject to the privacy controls built into the browser.
These fields allow a server to create, modify, delete, and control which parts of a web site will receive the cookie.
*/
;~ As the name suggests, this sends the cookies stored in your browser for that domain.  These are name=value pairs separated by semicolons. Cookies can also contain the session id.

;~ In PHP, individual cookies can be accessed with the $_COOKIE array. You can directly access the session variables using the $_SESSION array, and if you need the session id, you can use the session_id() function instead of the cookie.
HTTP.SetRequestHeader("Cookie", "First=Cookie; Second=bar")
HTTP.SetRequestHeader("Cookie", "Third=Cookie; Fourth=Cookie")

)
Gosub Paste_and_Restore_Stored_Clipboard
return

;***********API_SetHeader-Connection*******************
API_SetHeader_Connection:
Store:=ClipboardAll  ;****Store clipboard ****
Clipboard =
( Join`r
;**********************Connection*********************************
;~ requesting the use of persistent TCP connections.
HTTP.SetRequestHeader("Connection", "Keep-Alive")
)
Gosub Paste_and_Restore_Stored_Clipboard
return

;***********API_SetHeader-Content_Type*******************
API_SetHeader_Content_Type:
Store:=ClipboardAll  ;****Store clipboard ****
Clipboard =
( Join`r
;**********************Content-Type*********************************
HTTP.SetRequestHeader("Content-Type","application/x-www-form-urlencoded") ;URL encoded
;~ HTTP.SetRequestHeader("Content-Type", "text/xml;charset=UTF-8") ;Text / XML
HTTP.SetRequestHeader("Content-Type","application/json") ;JSON
)
Gosub Paste_and_Restore_Stored_Clipboard
return


;***********API_SetHeader_If_Modified_Since*******************
API_SetHeader_If_Modified_Since:
Store:=ClipboardAll  ;****Store clipboard ****
Clipboard =
( Join`r
;**********************If-Modified-Since*********************************
;~ If a web document is already cached in your browser, and you visit it again, your browser can check if the document has been updated by sending this.  If it was not modified since that date, the server will send a "304 Not Modified" response code, and no content - and the browser will load the content from the cache.
HTTP.SetRequestHeader("If-Modified-Since", "Sat, 28 Nov 2009 06:38:19 GMT")
)
Gosub Paste_and_Restore_Stored_Clipboard
return


;***********API_SetHeader_Referring_URL*******************
API_SetHeader_Referer:
Store:=ClipboardAll  ;****Store clipboard ****
Clipboard =
( Join`r
;***********Set Referring URL*******************
HTTP.SetRequestHeader("Referer","http://www.freecarrierlookup.com/")
)
Gosub Paste_and_Restore_Stored_Clipboard
return

;***********API_SetHeader_User_Agent*******************
API_SetHeader_UserAgent:
Store:=ClipboardAll  ;****Store clipboard ****
Clipboard =
( Join`r
;***********Set User Agent*******************
;***********Most common User Agents:  http://www.browser-info.net/useragents *******************
HTTP.SetRequestHeader("User-Agent","myXMLRPCClient/1.0")
HTTP.SetRequestHeader("User-Agent","Mozilla/4.0 (compatible; Win32; HTTP.WinHttpRequest.5)")
)
Gosub Paste_and_Restore_Stored_Clipboard
return
;***********End of Set Headers*******************
;******************************
;******************************


;******************************
;***********API_GetHeaders*******************
API_GetHeader_Wiki:
run https://en.wikipedia.org/wiki/List_of_HTTP_header_fields#Response_fields
run https://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14

return
;***********API_GetHeader_Cache*******************
API_GetHeader_Cache:
Store:=ClipboardAll  ;****Store clipboard ****
Clipboard =
( Join`r
;~ Definition from w3.org: "The Cache-Control general-header field is used to specify directives which MUST be obeyed by all caching mechanisms along the request/response chain." These "caching mechanisms" include gateways and proxies that your ISP may be using.
;~ Example:   Cache-Control: max-age=3600, public
;~ "public" means that the response may be cached by anyone. "max-age" indicates how many seconds the cache is valid for. Allowing your website to be cached can reduce server load and bandwidth, and also improve load times at the browser.  ;~ Caching can also be prevented by using the "no-cache" directive.
;***********Caching*******************
Cache_Control:=HTTP.getResponseHeader("Cache-Control")
Cache_Expires:=HTTP.getResponseHeader("Expires") ;~ Has the date the cache will expire
)
Gosub Paste_and_Restore_Stored_Clipboard
return

;***********API_GetHeader_Content_Length*******************
API_GetHeader_ContentLength:
Store:=ClipboardAll  ;****Store clipboard ****
Clipboard =
( Join`r
;~ When content is going to be transmitted to the browser, the server can indicate the size of it (in bytes) using this header.  This is especially useful for file downloads. That's how the browser can determine the progress of the download
;***********Content-Length*******************
Content_Length:=HTTP.getResponseHeader("Content-Length")
)
Gosub Paste_and_Restore_Stored_Clipboard
return

;***********API_GetHeader_Content_Encoding*******************
API_GetHeader_Content_Encoding:
Store:=ClipboardAll  ;****Store clipboard ****
Clipboard =
( Join`r
;**********************Content-Encoding*********************************
;~ This header is usually set when the returned content is compressed.
;~ Content_Encoding:=WebRequest.getResponseHeader("Content-Encoding")
)
Gosub Paste_and_Restore_Stored_Clipboard
return

;***********API_GetHeader_Content_Type*******************
API_GetHeader_Content_Type:
Store:=ClipboardAll  ;****Store clipboard ****
Clipboard =
( Join`r
;**********************Content-Type*********************************
;~ This header indicates the "mime-type" of the document. The browser then decides how to interpret the contents based on this. For example, an html page (or a PHP script with html output) may return this:
;~ 	Example:  		Content-Type: text/html; charset=UTF-8
;~ "text" is the type and "html" is the subtype of the document. The header can also contain more info such as charset.

;~ For a gif image, this may be sent:
;~ 	Example:  	Content-Type: image/gif.

;~ The browser can decide to use an external application or browser extension based on the mime-type. For example this will cause the Adobe Reader to be loaded:
	;~ Content-Type: application/pdf
;~ When loading directly, Apache can usually detect the mime-type of a document and send the appropriate header. Also most browsers have some amount fault tolerance and auto-detection of the mime-types, in case the headers are wrong or not present.
;~ You can find a list of common mime types here: http://www.webmaster-toolkit.com/mime-types.shtml
Content_Type:=WebRequest.getResponseHeader("Content-Type")
)
Gosub Paste_and_Restore_Stored_Clipboard
return

;***********API_GetHeaders_Last_Modified*******************
API_GetHeaders_LastModified:
Store:=ClipboardAll  ;****Store clipboard ****
Clipboard =
( Join`r
;**********************Last-Modified*********************************
;~ As the name suggests, this header indicates the last modify date of the document, in GMT format
Last_Modified:= HTTP.getResponseHeader("Last-Modified")
)
Gosub Paste_and_Restore_Stored_Clipboard
return
;***********End of GetResponse Headers*******************


;***********API_Response*******************
API_Response:
Store:=ClipboardAll  ;****Store clipboard ****
Clipboard =
( Join`r %
;***********Response fields*******************
MsgBox %  All_headers :=HTTP.GetAllResponseHeaders
MsgBox % Response_Text:=HTTP.ResponseText
MsgBox % Response_Body:=HTTP.ResponseBody
MsgBox %   Status_Text:=HTTP.StatusText
MsgBox %        Status:=HTTP.Status ;numeric value
)
Gosub Paste_and_Restore_Stored_Clipboard
return

API_Response_Body:
Clipboard =
( Join`r %
;****If you're getting weird error from Response text, this will convert bytes in ResponseBody to  text***********************************
Msgbox % text:=ConvertResponseBody(HTTP)
ConvertResponseBody(oHTTP){
	bytes:=oHTTP.Responsebody ;Responsebody has an array of bytes.  Single characters.
	loop, % oHTTP.GetResponseHeader("Content-Length") ;loop over  responsbody 1 byte at a time
		text .= chr(bytes[A_Index-1]) ;lookup each byte and assign a charter
	return text
}
)
Gosub Paste_and_Restore_Stored_Clipboard
return

API_ResponseCodes:
Run https://en.wikipedia.org/wiki/List_of_HTTP_status_codes
Run https://www.w3.org/Protocols/rfc2616/rfc2616-sec6.html#sec6.2

return


;***********API_Parse_XML*******************
API_Response_XML_Parse:
Store:=ClipboardAll  ;****Store clipboard ****
Clipboard =
( Join`r %
XML_QuickGrab(Response_Data,"form","id,name,campaign","1","1") ; !!!Remember XML is CASE SENSITIVE!!!

;***********XML_QuickGrab function*******************
XML_QuickGrab(XML_Data,Parent_Node,fields,Show_XML=1,Show_LV=0){
doc:=ComObjCreate("MSXML2.DOMDocument")
doc.loadXML(XML_Data)
;***********Show XML?*******************
if Show_XML {
    Gui,XMLGui:Destroy ;even if it doesn't exist it is a good habit to get into
    Gui,XMLGui:Default ;set as default
    gui,font, s12 cBlue q5, Courier New
    gui,Add,Edit,w900 h600 -Wrap HScroll, %VAR%
    gui,show
    ;SciTE_Output(sXML_Pretty(xml_data,"   ")) ;Text,Clear=1,LineBreak=1,Exit=0
}
;******************************
Obj:=[]
All:=Doc.SelectNodes("//" Parent_Node) ;Store nodes under what is selected

while(aa:=All.item[A_Index-1]){
	for a,b in StrSplit(Fields,",") ;iterate over fields
    		Obj[b]:=aa.SelectSingleNode(b).text ;get their text value and store in object
}

If Show_LV{
    Gui,ObjGui:Destroy ;even if it doesn't exist it is a good habit to get into
    Gui,ObjGui:Default ;set as default
    Gui,Add,ListView,h400 w600,Key|Value
    for a,b in Obj
	LV_Add("",a,b) ;use variadic function to add columns

    Loop,% LV_GetCount("Column")
	LV_ModifyCol(A_Index,"AutoHDR") ;adjust column width based on data
    gui, show
    MsgBox pause
    Gui,Destroy
    }
return Obj
}
)
Gosub Paste_and_Restore_Stored_Clipboard
return


;******************************
API_Response_XML_Pretty:
Store:=ClipboardAll  ;****Store clipboard ****
Clipboard =
( Join`r
   SciTE_Output(sXML_Pretty(xml_data,"   ")) ;sXML_Pretty =https://autohotkey.com/boards/viewtopic.php?t=666#p5170
)
Gosub Paste_and_Restore_Stored_Clipboard
return
;******************************
;***********end of API_Response_XML*******************

;******************************
;***********API_Response_JSON*******************
API_HTTP_Parse_JSON:
Store:=ClipboardAll  ;****Store clipboard ****
Clipboard =
( Join`r %
oAHK:=ParseJSON(Response) ;Make sure the ParseJSON function is in your library
DebugWindow(Obj2String(oAHK),1,1,200,0)
)
Gosub Paste_and_Restore_Stored_Clipboard
return


;***********Miscellaneous*******************
;***********to do -  64base*******************
;***********to do -  HMAC*******************
;***********to do -  OAuth*******************
;***********to do -  OAuth2*******************
;***********to do -  SciTE output function*******************
;***********to do -  httprequest - reference and provide file for download*******************





;***********Subroutines*******************
;******************************
;*******Store Clipboard- ****************
Store_Clipboard_Copy_Selected_Text:
Store:=ClipboardAll  ;Store full version of Clipboard
clipboard :="" ; Empty the clipboard
SendEvent, ^c  ;Depending on your OS and Admin level- you might want to check this
ClipWait, 1
If (ErrorLevel){ ;Added errorLevel checking
	MsgBox, No text was sent to clipboard
	Return
}
return

;***********Restore clipboard*******************
Paste_and_Restore_Stored_Clipboard:  ;~ MsgBox % clipboard
Sleep, 50
SendEvent, ^v ;Depending on your OS and Admin level- you might want to check this
Sleep, 50
Clipboard:=Store  ;Restore clipboard to original contents
return





;***********Helpful Links*******************
Helpful_Links:
Gui, Helpful:Destroy
Gui, Helpful:Font,Bold cBlack Norm
Gui, Helpful:Add,Text,y+5 ,Forum Links
Gui, Helpful:Font,CBlue Underline
Gui, Helpful:Add,Text,y+5 GWebsite_HTTP_Function, HTTPRequest Function by VxE
Gui, Helpful:Add,Text,y+5 GWebsite_Login_Tutorial, Login to Website Tutorial
Gui, Helpful:Add,Text,y+5 GWebsite_XML_CLass, maestrith XML Parsing Class
;~  Gui, Helpful:Add,Text,y+10 GWebsite_Mickers, Mickers Tutorial
;******************************
Gui, Helpful:Font,Bold cBlack Norm
Gui, Helpful:Add,Text,y+20, Other Resources
Gui, Helpful:Font,CBlue Underline
Gui, Helpful:Add,Text,y+10 GWebsite_the_Automator, The Automator
Gui, Helpful:Add,Text,y+10 GWebsite_WinHTTP_Object, WinHTTP Object on MSDN
Gui, Helpful:Add,Text,y+10 GWebsite_XPath,Intro to XPath
Gui, Helpful:Add,Text,y+10 GWebsite_JSON,Intro to JSON

Gui, Helpful:Add,Text,y+10 GWebsite_YouTube, YouTube Channel

hCurs:=DllCall("LoadCursor","UInt",NULL,"Int",32649,"UInt") ;IDC_HAND
onMessage(0x200, "MsgHandler")

Gui, Helpful:Show,w225 , Helpful links
return

;***********About me*******************
About:
Gui,About:Destroy
Gui,About:Font,Bold
Gui,About:Add,Text,x10 y10,Webservices /API Menu  v1.0
Gui,About:Font,Norm
Gui,About:Add,Text,x10 y30,To activate menu, Hold down a control key and click the left mouse button

Gui,About:Font
Gui,About:Font,CBlue Underline
Gui,About:Add,Text,y+10 GWebsite_LinkedIN, Joe Glines on LinkedIN
hCurs:=DllCall("LoadCursor","UInt",NULL,"Int",32649,"UInt") ;IDC_HAND
onMessage(0x200, "MsgHandler")
Gui,About:Font
Gui,About:Show,, About
return

Website_HTTP_Function:
Run,http://www.autohotkey.com/board/topic/47052-basic-webpage-controls-with-javascript-com-tutorial
gosub GuiClose
Return

Website_Login_Tutorial:
Run,https://autohotkey.com/board/topic/113013-how-to-do-logins-using-the-winhttprequest-com/
gosub GuiClose
Return

Website_XML_CLass:
Run, https://autohotkey.com/boards/viewtopic.php?f=62&t=33114&p=153893#p153893
gosub GuiClose
Return


Website_the_Automator:
Run, http://the-automator.com/webservice-api-calls/
gosub GuiClose
Return

Website_WinHTTP_Object:
Run, https://msdn.microsoft.com/en-us/library/aa384106.aspx
gosub GuiClose
Return

Website_XPath:
Run https://www.w3schools.com/xml/xpath_intro.asp
gosub GuiClose
Return

Website_JSON:
run https://www.w3schools.com/js/js_json_intro.asp
gosub GuiClose
Return

Website_LinkedIN:
Run,http://www.linkedin.com/in/joeglines/
Return


Website_YouTube:
Run, https://www.youtube.com/playlist?list=PL3JprvrxlW242fgxzzavJM7lRkCB90y4R
Return



Exit:
ExitApp
Return

Reload:
Reload
Return

Edit:
Edit
Return

GuiClose:
Gui,About:Destroy
OnMessage(0x200,"")
DllCall("DestroyCursor","Uint",hCur)
Return