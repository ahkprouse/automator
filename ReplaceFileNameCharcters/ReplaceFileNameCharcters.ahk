;********Illegal/unwanted charcters for file names******************************
;~ MsgBox % ReplaceFileNameCharcters(" this $; removed {} characters?")
ReplaceFileNameCharcters(String){
	NewStr:=RegExReplace(String,"[\\$;@\-/&%#!.<>\{\[\]\}}{?\|*\(\)_+=']","") ;
	return NewStr:=Trim(RegExReplace(NewStr, " +"," ")) ;replace multiple spaces and trim outsides
}