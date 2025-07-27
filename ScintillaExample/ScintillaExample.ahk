#Include <scilexer.h>
#Include <scintilla-wrapper\SCI>

Gui, Main:new, % "+LastFound"
$main := WinExist()

Gui, add, Edit, xm w150
Gui, add, Edit, xm w600

sci := new scintilla($main, 10, 60, 600, 480, "lib\SciLexer.dll")

; Here we set some basic options
; Style_Default is used to set some defaults for all the other styles below.
sci.SetWrapMode(SC_WRAP_WORD), sci.setlexer(SCLEX_HTML)
sci.StyleSetFont(STYLE_DEFAULT, "Courier New"), sci.StyleSetSize(STYLE_DEFAULT, 10)
sci.StyleSetBack(STYLE_DEFAULT, 0x212121), sci.StyleClearAll()
sci.SetCaretFore(0xAAAAAA)

; This opens the first margin (0 based) which shows line numbers
; The size of the margin is calculated byt TextWidth. 
; You can set the size manually if you want
sci.SetMarginWidthN(0, sci.TextWidth(STYLE_LINENUMBER, "_999"))

; This turns off the second margin as it is not needed.
sci.SetMarginWidthN(1, 0)

; Here we set the coloring for certain HTML elements.
sci.StyleSetFore(SCE_H_DEFAULT               , 0xEEEEEE)
sci.StyleSetFore(SCE_H_TAG                   , 0x0091cf), sci.StyleSetBold(SCE_H_TAG, true)
sci.StyleSetFore(SCE_H_TAGUNKNOWN            , 0xFF0000), sci.StyleSetBold(SCE_H_TAGUNKNOWN, true)
sci.StyleSetFore(SCE_H_ATTRIBUTE             , 0x00d69a)
sci.StyleSetFore(SCE_H_ATTRIBUTEUNKNOWN      , 0xFF0000), sci.StyleSetBold(SCE_H_ATTRIBUTEUNKNOWN, true)
sci.StyleSetFore(SCE_H_NUMBER                , 0x0000FF)
sci.StyleSetFore(SCE_H_DOUBLESTRING          , 0xcf9e00)
sci.StyleSetFore(SCE_H_SINGLESTRING          , 0xcf9e00)
sci.StyleSetFore(SCE_H_OTHER                 , 0xEEEEEE)
sci.StyleSetFore(SCE_H_COMMENT               , 0x0b8500)
sci.StyleSetFore(SCE_H_ENTITY                , 0xe07802)
sci.StyleSetFore(SCE_H_TAGEND                , 0x0091cf), sci.StyleSetBold(SCE_H_TAGEND, true)
sci.StyleSetFore(SCE_H_VALUE                 , 0xEEEEEE)

Gui, main:Show, w620 h550
return

MainGuiClose:
	ExitApp, 0