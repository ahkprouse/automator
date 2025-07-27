#Requires AutoHotkey v2.0-
#Include lib/WebView2.ahk

main := Gui()
main.Add("button", "w75", "")
main.Show("w800 h500")
wv := WebView2.create(main.Hwnd)
wv.CoreWebView2.Navigate("")
return