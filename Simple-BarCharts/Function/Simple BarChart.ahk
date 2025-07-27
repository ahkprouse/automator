/**
 * ============================================================================ *
 * @Author   : Xeo786                                                          *
 * @Homepage : the-automator.com                                                                 *
 *                                                                              *
 * @Created  : May 30, 2024                                                   *
 * ============================================================================ *
 * Want a clear path for learning AutoHotkey?                                   *
 * Take a look at our AutoHotkey courses here: the-Automator.com/Discover       *
 * They're structured in a way to make learning AHK EASY                        *
 * And come with a 200% moneyback guarantee so you have NOTHING to risk!        *
 * ============================================================================ *
 */

/*
This work by the-Automator.com is licensed under CC BY 4.0

Attribution — You must give appropriate credit , provide a link to the license,
and indicate if changes were made.
You may do so in any reasonable manner, but not in any way that suggests the licensor
endorses you or your use.
No additional restrictions — You may not apply legal terms or technological measures that
legally restrict others from doing anything the license permits.
*/
;@Ahk2Exe-SetVersion     0.0.0
;@Ahk2Exe-SetMainIcon    res\main.ico
;@Ahk2Exe-SetProductName
;@Ahk2Exe-SetDescription
;--
#SingleInstance
#Requires Autohotkey v2.0+

CreateBarChart(input,HeaderText:='',FooterText:='', pv:='v',BarWidth:=500,BarHeight:=50,FontSize:=12,FontColor:='Black',BarColor:='98fa98',BackgroundColor:='dffae6')
{
    switch Type(input)
    {
        case "Map"   :ChartData := input
        case "String": ChartData := str2map(input,",",':')
        Default:return
    }
    maxval := findmax(ChartData)
    Prog := Gui("-MinimizeBox -MaximizeBox +Caption +Owner +AlwaysOnTop")
    Prog.BackColor := BackgroundColor
    
    Prog.SetFont('s' FontSize ' w800 c' FontColor)
    if HeaderText
        Prog.Add("Text", "w" BarWidth " BackgroundTrans center", HeaderText)

    Prog.SetFont('s' FontSize ' w500 c' FontColor)

    for name, value in ChartData
    {
        Prog.Add("Progress", "xm w" BarWidth " h" BarHeight " Range1-" maxval " Background" BackgroundColor " c" BarColor, value)
        Prog.Add("Text", " w500 BackgroundTrans xp yp+15", "  " name " : " (pv = 'v' ? Value : Round((Value / maxval) * 100, 1) '%'))
    }
    Prog.SetFont('s' FontSize ' w800 c' FontColor)
    if FooterText
        Prog.Add("Text", "w" BarWidth " BackgroundTrans center", FooterText)
    Prog.Show()
    return Prog

    findmax(mapin)
    {
        max := 0
        for Key, value in mapin
        {
            if value > max 
                max := value
        }
        return max
    }

    str2map(str,lineSep,ValSep)
    {
        mymap := map()
        for i, line in StrSplit(str, lineSep)
        {
            result := StrSplit(line, ValSep)
            mymap[result[1]] := result[2]
        }
        return mymap
    }
}
