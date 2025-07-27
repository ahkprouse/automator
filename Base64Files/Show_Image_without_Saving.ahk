;~ #Include <default_Settings> 
;~ https://www.autohotkey.com/boards/viewtopic.php?t=61370  by swagfag
;**************************************
Image:="R0lGODlhFwAVAPcAAP////39/fX///z7+/r6+vL+/vr5+fn5+fD+/uj8/vT09P/+k/79k/Pw7e7x8e7v7ezs7Ofl5f/9E+Li4uPg4eDf3ufa293d3dHj49zc3N/frv/qAP/pAP7qAP7pAP/lANLT0MjU087PzvbhAc7NzejhEfLeAM3Ly8vKysHPz/HdAMbGxv/OAMDHyMXFxcTExP/JAMPDw8S/ur69vr29vcW7sq/CwLu6u+vCAfKhoc/OELi4udC1ibq5trO5uba4uP60AcGysP+0ALa1tLW1tbS0tLqyq962Eq+vr66urqysrbGqo6urq6usq9OwJJuzsaqqqv6dAMO3DsirMqmmpLSqaaWlpa+ik6Ojo7OqO6CgoKehi5+fn6edgJyXl5eXl7CTaJ+Tk5aWlqqKio6VlZGRkbF/foqKipaLZICNjZqGZsltbpV+f4GCgYCAgHp8eolvbuRISL9WVp5hYHptZKpSU8lGRMo+PoVZWWtnW2VlZcA+PmpeXqE/P5NAQOMbGolBQNUgHlRVV9MeH5k1NZA5OnREQaMtLZcxMMYeG01NToQ3N/8AAKYlJf0AAPoAAJAtK/QDA/ECAvUAAPMAAO4AAHkwMUVFRcMQEN4EBOQBAZQgH+AAANAFBdUCAtMAAKQLDLAAAKoAAAAAAP///wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAUUAKQALAAAAAAXABUAAAj/AEkJHEiQIIYUBRMqDGKp0aE+fhQmDOMlDZxAkRhp/ARqjESBcTB1EuWJEadQd/bY2cTnYw6NGislMtOigAEEFn74IKFwESWNmuSEAEC0KIAJSRRC0pipEAUBRgc0IFpmRUJAkhghekL0QIQaV7qAWfJgx4WEcx79UUIAQAUjWaSMMIHDCY8hMxLimbQmgQMZaHRsGEz4iBpFCesMsgGCTpUSG0Z5mCxZxRRBCQkZ2pJHg4TBowiH3gAjyiWBNE7oYdOD1KUFownLHgXkNBQaEMgQoeKawajfwIOPEnIphpYMAFC0YeL68yijRUfBIE6jiAsFSNwIvMQiMnSi0k2TPbJy5gWXLwO5ezcqHcZpUkneNBGDJT0LFh+Ewyj9npQILTcUxB0L+xXI30cEXXKJEAwKYVp/CKanoIIFBQQAOw=="

IniRead,Image,images.txt,Images,shapes ;Read from ini file
Gdip_Startup() ; the-Automator.com/GDIP
hbm := Gdip_CreateHBITMAPFromBitmap(Gdip_BitmapFromBase64(Image))
Gui Add, Picture, , HBITMAP: %hbm%
Gui Show
return







;********************Using Active X and having the browser deal with decoding base64***********************************
Ver:=FixIE(11) ;;the-automator.com/fixIE  If you get errors, enable this and the line that restores the setting two down
Gui,Add,ActiveX,vWB w50 h50,mshtml
FixIE(Ver) ;used in conjunciton with 2 lines above
WB.Navigate("about:blank")
while(WB.ReadyState!=4)
	Sleep,100
WB.Document.Body.OuterHTML:="<html><img src='data:image/jpeg;base64,"(Image)"' width='50'/></html>"
Gui, Show
return




;~ https://www.autohotkey.com/boards/viewtopic.php?t=59966
Base64Dec(Code, FileName){
    CodeLength := StrLen(Code)
    DllCall("Crypt32.dll\CryptStringToBinary"
                                            , "str",    Code
                                            , "uint",  CodeLength
                                            , "uint",  0x00000001
                                            , "ptr",    0
                                            , "uint*", buffer
                                            , "int",    0
                                            , "int",    0)
    VarSetCapacity(bin, buffer, 0)
    DllCall("Crypt32.dll\CryptStringToBinary"
                                            , "str",    Code
                                            , "uint",  CodeLength
                                            , "uint",    0x00000001
                                            , "ptr",    &bin
                                            , "uint*", buffer
                                            , "int",    0
                                            , "int",    0)


    Handle := DllCall("CreateFile"
                                    , "str",    FileName
                                    , "uint",  0x10000000
                                    , "uint",  0x00000002
                                    , "ptr",    0
                                    , "uint",  2
                                    , "uint",  128
                                    , "ptr",    0, "ptr")
    DllCall("WriteFile"
                        , "ptr",    Handle
                        , "ptr",     &bin
                        , "uint",    buffer
                        , "int*",    var       ; Thank nnnik for discovering this error.
                        , "ptr",     0)
    DllCall("CloseHandle", "ptr", Handle)

    return
}