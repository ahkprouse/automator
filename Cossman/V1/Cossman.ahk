#SingleInstance,Force

#include lib\Notify.ahk
FilePath := A_ScriptDir "\Cossman Billboards.txt" ; You can make it relative to the script path
AppsKey & b:: ;Run B:\Progs\AutoHotkey_L\AutoRun\Cossman_Billboards.ahk ;cossman billboards / sayings / quotes
;********************Cossman / Memes***********************************
; Run Chrome.exe "https://www.linkedin.com/feed/"
; Run Chrome.exe "https://www.facebook.com"

Loop,read, % FilePath
	aa := A_Index ;increment rows- Need to know what the last row is

Random, Random_Row, 1, %aa% ;selecat random row
FileReadLine, Clipboard, % FilePath, %Random_Row% ;read the random row
Notify().AddWindow(Clipboard,{Time:6000,Icon:300,Background:"0x1100AA",Ident:"MyID",Title:"On Clipboard",TitleSize:16,size:14})
return