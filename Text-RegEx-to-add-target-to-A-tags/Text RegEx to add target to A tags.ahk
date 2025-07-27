;~ #Include <default_Settings> 
#SingleInstance,Force
Clipboard=
(
blah <a href="https://the.com" >source</a> blah
blah <a href="https://the.com" >source</a> blah
blah <a href="https://the.com" target="blank">source</a> and
blah <a href="https://the.com" target="blank">source</a> and
one  <a href="https://the.com" >source</a> more
)
Clipboard:= RegExReplace(clipboard,"im)(<a.*?""(\s*))(?<!target=""blank"")>","$1target=""blank"">")
DebugWindow(Clipboard,Clear:=1,LineBreak:=1,Sleep:=500,AutoHide:=0)






















;~ try:=RegExReplace(text,"im).*(target=\x22blank\x22)>.*","$1")
;~ try:=RegExReplace(text,"im)(?!.*target)<(a\s+href)","<a Target=""_blank"" $1")
;~ try:=RegExReplace(text,"im)(<a\s+href)(.*?>)","<a target=""_blank"" $1$2")
;~ try:=RegExReplace(text,"im)(<a\s+href)(.*?>)(?<!target)","<a target=""_blank"" $1$2")
;~ try:=RegExReplace(text,"im)(<a\s+href)(.*?)(?<!.target=""_blank"")>?","$1$2")
;~ try:=RegExReplace(text,"im)(<a\s+href.*?>)(?<!target)","$1|")
;~ try:=RegExReplace(text,"im)(<a\s+)(.*?href.*?>)(?<!target)","$1|$2")

;~ try := RegExReplace(Text, "im)(<a .+?)(?<![t])(>.*?)</a>","$1|$2")
;~ try := RegExReplace(Text,"im)(<a.*?)(" needle ")(.*?</a>)","|$1|$2|$3")
try := RegExReplace(Text,"im)<a(.*?)>","|$1|")
	;~ <a.*?"(\s*)(?<!target="blank")> ;from Jackie
pattern=(<a.*?"(\s*))(?<!target="blank")>
;~ try := RegExReplace(Text,"im)" pattern "","$1target=""blank"">") ;works


try := RegExReplace(Text,"im)(<a.*?""(\s*))(?<!target=""blank"")>","$1target=""blank"">")




