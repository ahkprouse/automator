# Rufaydium-V2

![alt text](https://i.ibb.co/HBPZ9Nd/Rufaydium.jpg)

# Rufaydium

AutoHotkey WebDriver Library to interact with browsers.
Rufaydium will automatically try to download the latest Webdriver and updates Webdriver according to browser Version while creating Webdriver Session.

Supported browsers: Chrome, MS Edge, Firefox, Opera.

**Forum:** https://www.autohotkey.com/boards/viewtopic.php?f=6&t=102616

Rufaydium utilizes Rest API of W3C from https://www.w3.org/TR/webdriver2/
and also supports Chrome Devtools Protocols same as [chrome.ahk](https://github.com/G33kDude/Chrome.ahk)

## Note: 
No need to install / setup Selenium, Rufaydium is AHK's Selenium and is more flexible than selenium.

## [Support / Download](https://www.the-automator.com/rufaydium)

## How to use

```AutoHotkey
#Include Rufaydium.ahk
/*
	it will Download "chromedriver.exe" into "Bin" Folder
	In case Driver is not yet available, it will Download "chromedriver.exe" into "A_ScriptDir"
	before starting the Driver.
*/
Chrome := Rufaydium("chrome")

f1::
/*
	Create new session if WebBrowser Version Matches the Webdriver Version.
	It will ask to download the compatible WebDriver if not present.
*/
Page := Chrome.NewSession(funcallback)
; navigate to url
Page.Navigate("https://www.autohotkey.com/")
return

f12::
Page.Close()  ; close session 
Chrome.Exit() ; then exits driver
return

funcallback(data) ; reponse will be Json string
{
	OutputDebug data
}

```

# Rufaydium(DriverName,CustomPort:=0,Info:=1,TrayIcon:=1)
`WDM.ahk` Class included into Rufaydium.ahk that download/launches driver in the background where port 9515 set to default for chrome.

```AutoHotkey
Chrome := Rufaydium() ; "chromedriver" is default instance "Chrome" can also be used
MSEdge := Rufaydium("msedgedriver",CustomPort:=9516) ; will Download/Load MS Edge driver communication port will be 9516 "egde", "msedge" can be used
Firefox := Rufaydium("geckodriver") ; "Firefox" can be used
Opera   := Rufaydium("operadriver") ; "Opera" can be used
```
Note: 
1. Driver will be downloaded into Bin Folder.
2. Driver will not run if Port is occupied. Make sure to not run different drivers with the same port. i.e. trying to run Chromedriver and Edgedriver with the same port.

# Driver Default port
Rufaydium now supports 4 WebDrivers and has one default port; it will not run if the Port is already in use. We need to run the driver with a separate port using Driver Parameters, or we need to exit the already running driver and run a different driver if we want to use the same port.  
Rufaydium has default ports for every driver to resolve this conflict:

|Driver Name  | Ports |
|-------------|-------|
|chromedriver | 9515  |
|msedgedriver | 9516  |
|geckodriver  | 9517  |
|operadriver  | 9518  |
|bravedriver | 9515  |

> note: BraveDriver Parameter will download chromedriver but uses BraveCapabailities 
>
> ## Driver Parameters
 Driver Parameters will be implemented soon


 ## Script reloading

We can reload the script as many times as we want, but the driver will be active in the process so we can have control over all the sessions created through WebDriver so far. We can also close the Driver process, but this will cause issues as we can no longer access any session created through WebDriver. its better to use `Session.exit()` then `Chrome.Driver.Exit()`.

```AutoHotkey
; to download and Run chromeDriver.exe using port 10280
Chrome := Rufaydium("chromedriver",10280)
; to close driver 
Chrome.Exit() 
; to close and Delete Driver.exe
Chrome.Delete() 
```

# Capabilities Class 
One can access and use Capabilities after creating 'Rufaydium()' instance, 
Rufaydium will create next session followed by specified Capabilities.  
so user has to Make changes to capabilities before creating a session.

```AutoHotkey
Chrome := Rufaydium() ; will load Chrome driver with default Capabilities
Chrome.capabilities.setUserProfile("abcxyz@gmail.com") ; "Default" is Default Profile user and user can also use email address to grab specific account 

; can change user profile Data Dir, but location: "D:\Profile Dir\Profile 1" must exist
Chrome.capabilities.setUserProfile("Profile 1","D:\Profile Dir\") 

; New Session will be created according to above Capabilities settings
Session := Chrome.NewSession()
```
## Enable HeadlessMode
This will SET and GET HeadlessMode
```AutoHotkey
Browser.capabilities.HeadlessMode := true
MsgBox, % Browser.capabilities.HeadlessMode
```
## Enable Incognito Mode
This will SET and GET Incognito mode
```AutoHotkey
Browser.capabilities.IncognitoMode := true
MsgBox, % Browser.capabilities.IncognitoMode
```
>Note after Setting ```IncognitoMode := true``` .setUserProfile() would not work

## UserPrompt
[User prompt handler](https://www.w3.org/TR/webdriver2/#dfn-user-prompt-handler) can be assigned using UserPrompt, which decides handling procedure of Browser alerts/messages

Following parameters are allowed
| Keyword            | State                    | Description                                                                              |
|--------------------|--------------------------|------------------------------------------------------------------------------------------|
| dismiss            | Dismiss state            | All Alert prompt should be dismissed.                                                    |
| accept             | Accept state             | All Alert prompt should be accepted.                                                     |
| dismiss and notify | Dismiss and notify state | All Alert prompt should be dismissed, and an error returned that the dialog was handled. |
| accept and notify  | Accept and notify state  | All Alert prompt should be accepted, and an error returned that the dialog was handled.  |
| ignore             | Ignore state             | All Alert prompt should be left to the user to handle.                                   |

```AutoHotkey
MsgBox, % Browser.capabilities.UserPrompt ; default useprompt is dismiss
Browser.capabilities.UserPrompt := "ignore"
```

## Enable CrossOriginFrame
This will Set and Get CrossOriginFrame access
```AutoHotkey
Browser.capabilities.useCrossOriginFrame := true
MsgBox, % Browser.capabilities.useCrossOriginFrame
```
## Setting / Removing Args
Command-line arguments to use when starting Chrome. See [here](http://peter.sh/experiments/chromium-command-line-switches/)
```AutoHotkey
Chrome := Rufaydium()
Chrome.capabilities.addArg("--headless")
Chrome.capabilities.RemoveArg("--headless")
```

## Binary
We can also load Chromium-based browsers, for example, the Brave browser is based on chromium and can be controlled using the ChromeDriver, SetBinary has been Merged into ```AutoHotkey
page := NewSession(CallbackFunc,binaryPath)
```
or change binary before Session Creation
```AutoHotkey
Chrome.capabilities.Setbinary(binaryPath)
Chrome.capabilities.Resetbinary()
```

## other methods
```AutoHotkey
Chrome := Rufaydium()
; most of the options that are included as capabilities method are defined here https://chromedriver.chromium.org/capabilities#h.p_ID_106
Chrome.capabilities.Addextensions(extensionloaction) ; will load extensions
Chrome.capabilities.AddexcludeSwitches("enable-automation") ; will load Chrome without default args
Chrome.capabilities.DebugPort(9255) ; will change port for debuggerAddress
```

## SetTimeouts
Timeout can be define at any level/time/place, 

```AutoHotkey
Browser := Rufaydium(driver,params)
ResolveTimeout := ConnectTimeout := SendTimeout := ReceiveTimeout := 3 * 1000
Broswer.SetTimeouts(ResolveTimeout, ConnectTimeout, SendTimeout, ReceiveTimeout)
```
> read about [Settimeouts](https://learn.microsoft.com/en-us/windows/win32/winhttp/iwinhttprequest-settimeouts)


 Rufaydium Sessions
## New Session
Create a session after Setting up capabilities.  
We can skip capabilities, as the session will load default Capabilities based on the Driver used. The default Capabilities should work with any Driver.  

Note: In case the WebDriver version is mismatched with the browser version, Rufaydium will ask to update the driver and update the WebDriver automatically and load the new driver and create a session.  
This ability is supported for the Chrome and MS Edge web browsers for now.

```AutoHotkey
Chrome := Rufaydium("chromedriver.exe")
Session := Chrome.NewSession()
```

## Using WebDriver with different Browsers
Brave uses chromedriver.exe, by simply passing Browser.exe (referred binary) into NewSession() method


```AutoHotKey
Brave := Rufaydium() ; Brave browser support chromedriver.exe
; New Session will be created using Brave browser, 
Session := Brave.NewSession("C:\Program Files\BraveSoftware\Brave-Browser\Application\brave.exe")
Brave.Session() ; will always open new Brave session until we reset 
Brave.Capabilities.Resetbinary() ; reset binary to driver default
Brave.Session() ; will create Chrome session as we have loaded Chrome driver
```
this way we can load All Chromium Based browsers

## Getting Existing Sessions
We can also access sessions created previously using the title or URL.
 
```AutoHotkey
Msgbox, % json.dump(Chrome.Sessions()) ; will return all Webdriver Sessions detail

Session := Chrome.getSession(1) ; this will return with Session by number sequencing from first created to latest created and switch to Active TAB

Session := Chrome.getSession(1,2) ; this will return with first session and switch Second tab, Tabs count from left to right
Session := Chrome.getSessionByUrl(URL)
Session2 := Chrome.getSessionByTitle(Title)
```

Note: above methods are based on `httpserver\sessions` command which is not W3C standard. Rufaydium uses AHK's functions ReadIni, WriteIni & DeleteIni, to store and parse Session IDs by creating `ActiveSessions.ini` at `GeckoDriver location`, therefore `getSessionByUrl()` & `getSessionByTitle()` now support Firefox sessions too, this way Rufaydium can continue geckodriver Sessions, or multiple AHK scripts can control Firefox.

```AutoHotkey
FF := Rufaydium("geckodriver.exe")
Page := FF.NewSession() ; session id will be saved to ini for access after reloading script
```

## Session Auto Delete
User can close WebDriver session manually, Driver takes time to respond to any command in this kind of situation because Session was not closed for the driver, and webdriver tries to lookup nonexistnig driver on every next api call,

therefore Rufaydium auto-delete will delete reachable/closed by the user Session inorder to overcome driver response lag

## Session.New(type:='tab',url:=0,Activate:=1) Session.NewTab() & Session.NewWindow()
creating New tab/Window with navigation and Switching
```AutoHotkey
Session.New('tab',url)          ; will create tab + Navigate url + activate tab 
Session.New('tab',url,false)    ; will create tab + Navigate url
Session.New('Window',url,false) ; will create NewWindow + Navigate url
Session.New('Window')           ; will create NewWindow + activate Window
Session.New('tab',false,false)  ; will create tab
```

Creates just a new tab or New Window
```AutoHotkey
handle1 := Session.NewTab()
handle2 := Session.NewWindow()
; to activate window
Session.SwitchTab(handle)
```

## Session.Title
returns Page title
```AutoHotkey
MsgBox, % Session.Title
```

## Session.HTML
returns Page HTML
```AutoHotkey
MsgBox, % Session.HTML
```
## Session.url
return Page URL
```AutoHotkey
MsgBox, % Session.url
Session.url := "https://www.autohotkey.com/boards/posting.php?mode=edit&f=6&p=456008"
```
## Session.Navigate(url)
Navigates to the requested URL
```AutoHotkey
Session.Navigate("https://www.autohotkey.com/")
```
Multiple url can be navigated at once
```AutoHotkey
TabId := Session.currentTab
Session.Navigate(url1,url2,url3,url4,url4)
Session.Switch(TabId) ; returned to previous tab
```
## Session.Refresh()
Refresh the web page and wait until it gets refreshed.
```AutoHotkey
Session.Refresh()
MsgBox, Page refresh complete
```

## Session.Back() & Session.Forward()
helps navigate to previous or from previous to recent the page acting like browser back and forward buttons. 

## SwitchTabs(), SwitchbyTitle() & SwitchbyURL(), ActiveTab()
Help to switch between tabs.
```AutoHotkey
Session.SwitchTabs(2) ; switch tab by number, counted from left to right
Session.SwitchbyTitle(Title)
Session.SwitchbyURL(url)
Session.ActiveTab() ; Switch to active tab. Note: this does not work for firefox, right now.
```

## Session window position and location
```AutoHotkey
; Getting window position and location
sessionrect := Session.Getrect()
MsgBox json.stringify(sessionrect)
; set session window position and location
Srect := Session.SetRect(20,30,500,400) ; x, y, w, h 
; error handling
if Srect.has('error')
	MsgBox Srect['error']
; setting rect will return rect array
rect := Session.SetRect(1,1) ; this maximize to cover full screen and while taking care of taskbar
MsgBox json.stringify(rect)
; sometime we only want to play with x or y 
Session['x'] := 30
MsgBox session['y']
; this also return whole rect as well ; not just height and also 
k := Session.height := A_ScreenHeight - (A_ScreenHeight * 5 / 100)
if !k.has('error')
	MsgBox json.stringify(k)

Session.Maximize() ; this will Maximize session window
windowrect := Session.Minimize() ; this will minimize session window
if !windowrect.has('error') ; error handling 
	MsgBox json.stringify(windowrect) ; if not error return with window rect

; following will turn full screen mode on
MsgBox Json.stringify(Session.FullScreen()) ; return with rect, you can see x and y are zero h w are full screen sizes
; this simply turn fullscreen mode of
Session.Maximize()
```

## Session.Close() and Session.Exit()
Session.Close() Close Session window
Session.Exit() terminate Session by closing all windows.

```AutoHotkey
Chrome := Rufaydium()
Page := Chrome.NewSession()
Page.Navigate("https://www.google.com/")
Page.New("Tab") 	; create new tab &  activate
Page.Navigate("https://www.autohotkey.com/boards/viewtopic.php?t=94276") ; navigating 2nd tab
; Page.close() ; will close the active window / tab
Page.exit() ; will close all windows / tabs will end up closing whole session 
```

## Switching Between Window Tabs & Frame
One can Switch tabs using `Session.SwitchbyTitle(Title)` or `Session.SwitchbyURL(url="")`
but Session remains the same If you check out the [above examples](https://github.com/Xeo786/Rufaydium-Webdriver#sessionnewtab--sessionnewwindow), I posted you would easily understand how switching Tab works.

Just like Switching tabs, one can Switch to any Frame but the session pointer will remain the same.

![alt text](https://i.ibb.co/PW2P9ZG/Rufaydium-Frames-Example.png)

According to the above image, we have 1 session having three tabs

Example for TAB 1

```AutoHotkey
Session.SwitchbyURL(tab1url) ; to switch to TAB 1
; tab 1 has total 3 Frame
MsgBox, % Session.FramesLength() ; this will return Frame quantity 2 from Main frame 
Session.Frame(0) ; switching to frame A
Session.getElementByID(someid) ; this will get element from frame A
; now we cannot switch to frame B directly we need to go to main frame / main page
Session.ParentFrame() ; switch back to parent frame
Session.Frame(1) ; switching to frame B
Session.getElementByID(someid) ; this will get element from frame B
; frame B also has a nested frame we can switch to frame BA because its inside frame B
Session.Frame(0) ; switching to frame BA
Session.getElementByID(someid) ; this will get element from frame BA
Session.ParentFrame() ; switch back to Frame B
Session.ParentFrame() ; switch back to Main Page / Main frame
```

Example for TAB 2

```AutoHotkey
Session.SwitchbyURL(tab2url) ; to switch to TAB 2
; tab 1 also has total 3 frames
MsgBox, % Session.FramesLength() ; this will return Frame quantity 3
Session.Frame(0) ; switching to frame X
Session.ParentFrame() ; switch back to Main Page / Main frame
Session.Frame(1) ; switching to frame Y
Session.ParentFrame() ; switch back to Main Page / Main frame
Session.Frame(2) ; switching to frame Z
Session.ParentFrame() ; switch back to Main Page / Main frame
```

Example for TAB 3

```AutoHotkey
Session.SwitchbyURL(tab3url) ; to switch to TAB 3
MsgBox, % Session.FramesLength() ; this will return Frame quantity which is Zero because TAB 3 has no frame
```

## Accessing Element / Elements
The following methods return with an element pointer.
```AutoHotkey
Element := Session.getElementByID(id)
Element := Session.QuerySelector(Path)
Element := Session.QuerySelectorAll(Path)
Element := Session.getElementsbyClassName(Class)
Element := Session.getElementsbyName(Name) 
Element := Session.getElementsbyTagName(TagName)
Element := Session.getElementsbyXpath(xPath)
```
Getting element(s) from the element Just like DOM
```AutoHotkey
element := Session.querySelector(".Someclass")
ChildElements := element.querySelectorAll("#someID")
```
Getting Parent and Child elements
```AutoHotkey
e := Page.QuerySelector("#keywords")
parentelement := e.parentElement
for n, child in parentelement.children
	msgbox "index: " n "`nTagName: " child.tagname
```

Above methods are based on `.findelement()`/`.findelements()`
```AutoHotkey
Session.findelement(by.selector,"div") 
Session.findelements(by.selector,".class") 
```
We can check the element's length
```AutoHotKey
elements := Session.querySelectorAll(Path)
MsgBox elements.count
```
See [accessing table](https://github.com/Xeo786/Rufaydium-Webdriver#accessing-tables)

## by Class

```AutoHotkey
Class Session
{
	Class by
	{
		static selector := "css selector"
		static Linktext := "link text"
		static Plinktext := "partial link text"
		static TagName := "tag name"
		static XPath	:= "xpath"
	}
}
```

## Accessing Tables

There are many ways to access the table you can use the JavaScript function to extract `Session.ExecuteSync(JS)`
but an easy and simple way is to utilize AHK `for` loops. Looping through the table is a little bit slow because one Rufaydium step consists of 3 steps

1) `Json.Parse()` 
2) `WinHTTP Request` 
3) `Json.Stringify()` 

Looping through tables takes lots of steps, so it's better to use `Session.ExecuteSync(JS)` to read huge tables and do it much faster if we just want to extract table data and do not have to interact with tables 

>Note: Following method will only works when InnerText return with tabs and line breaks and tabs
```AutoHotkey
; reading thousand rows lighting fast
Table := Session.QuerySelectorAll("table")[1].innerText
Tablearray := []
for r, row in StrSplit(Table,"`n") 
{
	for c, cell in StrSplit(row,"`t")
	{
		;MsgBox "Row: " r " Col:" C "`nText:" cell
		Tablearray[r,c] := cell
	}
}
MsgBox Tablearray[1,5]
```
## Session.ActiveElement()
returns handle for focused/active element

## Handling Session alerts popup messages
```AutoHotkey
Session.Alert("GET") ; getting text from pop up msg
Session.Alert("accept") ; pressing OK / accept pop up msg
Session.Alert("dismiss") ; pressing cancel / dismiss pop up msg
Session.Alert("Send","some text")  ; sending a Alert / pop up msg 
```

## Tacking Screen Shots accept only png file format
```AutoHotkey
Session.Screenshot("picture location.png") ; will save PNG to A_ScriptDir
Session.Screenshot(a_desktop "\picture location.png") ; will save PNG to a_desktop
Session.CaptureFullSizeScreenShot(a_desktop "\fullPage.png") ; will save full page screenshot
```

# PDF printing 
```AutoHotkey
Session.PrintPDF(savepath) ; for default print options
```

## Session inputs events
```AutoHotkey
Class Mouse
    Static LButton := 0
	Static MButton := 1
	Static RButton := 2
}
```

```AutoHotkey
Session.move(x,y) ;move mouse pointer to location
Session.click() ; sending left click on moved location ; [button: 0(left) | 1(middle) | 2(right)]
Session.DoubleClick() ; sending double left click on moved location
Session.MBDown() ; sending mouse left click down on moved location
Session.MBup() ; sending mouse left click up on moved location
```

```AutoHotkey
Session.GetCookies() ; return with Map of cookies you need to parse then and understand 
Session.GetCookieName(Name) ; return with cookie
Session.AddCookie(CookieObj) ; will add cookie
```

# Element
Element.ahk has methods and properties beside these if user set get property
or call any method will be executed in javascript console 

in following example  we get element and try get innerText property 
which is not defined in "element" Class 
therefore the innerText will be executed in JS console so as JavaScript
which is case-Sensetive, and user must takecare about Case-Sensetivity 
while getting setting 
```AutoHotkey
DivElem := Page.querySelector('div)
msgbox DivElem.innerText ; get
DivElem.id := 'some_id'  ; set
```

in following example method will be called in js Console 
```AutoHotkey
attribMap := Session.querySelector('div').getAttributeNames() ; will be execute in js 
Session.querySelector('div').getAttribute('class') ; Element class Method
```

## Shadow Elements
Shadow elements can easily be accessed using `element.shadow()`.


# Session.Actions()
We can interact with a page using `Actions(interactions*)` method, interactions are generated using [Mouse](https://github.com/Xeo786/Rufaydium-Webdriver#mouse-class), [Scroll](https://github.com/Xeo786/Rufaydium-Webdriver#scroll-class) [Keyboard](https://github.com/Xeo786/Rufaydium-Webdriver#keyboard-class) Classes based on [Actions](https://github.com/Xeo786/Rufaydium-Webdriver#actions-class) Class. Sending Empty Actions() method would release/stop ongoing action.
```AutoHotKey
Session.Actions(Interaction1,Interaction2,interaction3) ; read Action class for Interactions

Session.Actions() ; stop onging action
```
# Actions Class
Action class that help generating Webdriver Actions Payload for Session.Actions() method, extends from [Mouse](https://github.com/Xeo786/Rufaydium-Webdriver#mouse-class), [Scroll](https://github.com/Xeo786/Rufaydium-Webdriver#scroll-class) [Keyboard](https://github.com/Xeo786/Rufaydium-Webdriver#keyboard-class) Classes (hereinafter referred to as "interaction/interactions" ), action payloads should be casesensitive and has specific parameters for concerning "pointerType", so these classes not only helps generating them, but also make them easy to understand.

Following methods inherited to Mouse, Scroll and Keyboard Classes, generate a interaction Objects that later translated to Webdriver Actions payload, hereinafter referred to as "Event/Events creations" 

`Pause(duration)` create event of "pause" to cause delay between interactions, where default 'duration' is 100

`cancel()` create 'pointerCancel' event

`Clear()` resets interaction by deleting all delete Events
> note: One interaction Class Object has multiple events

## Mouse Class

Mouse Class generates event/interaction Objects 'Type' "pointer" that later translated to Webdriver Actions payload when submitted as parameters to Session.Actions().

`interaction := mouse(pointerType)` accepts 'pointerType' as parameter which can be "mouse", "pen", or "touch", where default pointerType is mouse, return  interaction Class object.

`mouse.Clear()` resets interaction by deleting all delete Events.

`mouse.cancel()` create 'pointerCancel' event, which act like mouse not over document.

`mouse.press(Button)` create a payload object for "pointerDown", accepts "Button" parameter 0(left), 1(middle), or 2(right) mouse button, empty parameter considered 0 to autohotkey results setting left mouse button default.

`mouse.Release(Button)` create a payload object for "pointerUp", accepts "Button" parameter 0(left), 1(middle), or 2(right) mouse button, empty parameter considered 0 to autohotkey results setting left mouse button default.

`mouse.Move(x,y,duration,width,height,pressure,tangentialPressure,tiltX,tiltY,twist,altitudeAngle,azimuthAngle,origin)` will move mouse pointer to 'x' 'y' direction, moveing taking time as 'duration', 
pointer size can be define as 'width' 'height' which is optional, 

move can be tweaked for button/touch 'pressure' 'tangentialPressure' 'tiltX','tiltY','twist','altitudeAngle','azimuthAngle' by using these respective parameters, which are also optional. 

"origin" can be  "viewport" or "pointer"

Default parameters for move:
| Parameters | Ports |
|-------------|-------|
|x|0|
|y|0|
|duration|10|
|width|0|
|height|0|
|pressure|0|
|tangentialPressure|0|
|tiltX|0|
|tiltY|0|
|twist|0|
|altitudeAngle|0|
|azimuthAngle|0|
|origin|"viewport"|


`mouse.click(button,x,y,duration)` click generates for serialized objects following methods already defined above, and will be translated to JSON payload and executed one by one from first to last creation.
```AutoHotKey
mouse.move(x,y,0)
mouse.press(button,duration)
mouse.Pause(500)
mouse.release(button,duration)
```

Mouse Interaction and event example
```AutoHotKey
MouseEvent := mouse() ; Setting pointerType "mouse"
MouseEvent.press() ; mouse.LButton (Default) | mouse.MButton | mouse.RButton
MouseEvent.move(x:=288,y:=258,Delay:=10)
MouseEvent.release()
Session.Actions(MouseEvent)
```

## Scroll Class
Scroll Class generates event/interaction Objects 'Type' "wheel" that later translated to Webdriver Actions payload when submitted as parameters to Session.Actions().

`interaction := Scroll(pointerType:='mouse')` accepts 'pointerType' as parameter which can be "mouse", "pen", or "touch", where default pointerType is mouse, return interaction Class object.

`interaction.Clear()` resets interaction by deleting all delete Events.

`interaction.Scroll(deltaX,deltaY,x,y,duration,origin)` navigates vertical horizontal scroll on webpage's document view. 
It performs a scroll given duration, x, y, target delta x, target delta y, current delta x and current delta y:

Default parameters for Scroll method:
| Parameters | Ports |
|-------------|-------|
|deltaX|0|
|deltaY|0|
|x|0|
|y|0|
|duration|10|
|origin|"viewport"|

Following Methods utilized ```.Scroll(s)``` to perform scroll up down left right, where 's' is Scrolling value from the calculated from the exiting position, default value for 's' is 50 

`interaction.ScrollUP(s)`

`interaction.ScrollDown(s)`

`interaction.ScrollLeft(s)`

`interaction.ScrollRight(s)`

## Keyboard Class
Keyboard Class generates event/interaction Objects 'Type' "key" that later translated to Webdriver Actions payload when submitted as parameters to Session.Actions().

```KeyInterAction := Keyboard()``` return interaction Class object. does not required any parameter

```Keyboard.Clear()``` resets interaction by deleting all delete Events.

```Keyboard.keyUp(key)``` create a payload object for "keyUp", required "key" parameter as key "Value"

```Keyboard.keyDown(key)``` create a payload object for "keyDown", required "key" parameter as key "Value"

```Keyboard.SendKey(keys)``` utilizes 'keyUp()' and 'keyDown()' methods simultaneously to send keystrokes, required Keys string parameter, its recommended to use `Element.Sendkey()` to mimic keystrokes on element or `WDElement.value` to set and Get element value.