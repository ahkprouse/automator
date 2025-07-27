ExploreObj(the,)

ExploreObj(Obj, Depth=12, NewRow="`n", Equal="  =  ", Indent="`t", CurIndent="") {
	; Link:	www.autohotkey.com/forum/topic69253.html
	static ShowChar := 60	; number of characters to show
	For k,v in Obj {
		StringReplace, k, k, `n,,all
		StringReplace, k, k, `r,,all
		k := (StrLen(k) > ShowChar) ? SubStr(k,1,ShowChar) " ..." : k
		if (IsObject(v))
		ToReturn .= CurIndent . k . NewRow . (depth>1 ? %A_ThisFunc%(v, Depth-1, NewRow, Equal, Indent, CurIndent . Indent) . NewRow : "")
		else {
			StringReplace, v, v, `n,,all
			StringReplace, v, v, `r,,all
			v := (StrLen(v) > ShowChar) ? SubStr(v,1,ShowChar) " ..." : v, ToReturn .= CurIndent . k . Equal . v . NewRow
		}
    }
	return RTrim(ToReturn, NewRow)
}


;====== Testing area ======
oKey3 := Object("Key`n`n3.1", "value `n`n3.1", "Key3.2", "value 3.2")
oKey4 := Object("Key4.1", "value 4.1",  "Key4.2", Object("Key4.2.1", "value 4.2.1", "Key4.2.2", "value 4.2.2"), "Key4.3", "value 4.3")
oKey5 := Object("Key5.1", "value 5.1", "Key5.2", "value 5.2", "Key5.3", "value 5.3")

oRoot := Object()
oRoot["Key`n`n1"] := "value 1 `n`nThe string to search for. Matching is not case sensitive unless StringCaseSense has been turned on."
oRoot.Key2 := "value 2"
oRoot.Key3 := oKey3
oRoot.Key4 := oKey4
oRoot.Key5 := oKey5

MsgBox,, Exploring Root object, % ExploreObj(oRoot)
MsgBox,, Exploring Root object - 1 level deep, % ExploreObj(oRoot,1)
MsgBox,, Exploring Key4 object, % ExploreObj(oKey4)
MsgBox,, Exploring oRoot.Key4["Key4.2"] object, % ExploreObj(oRoot.Key4["Key4.2"])