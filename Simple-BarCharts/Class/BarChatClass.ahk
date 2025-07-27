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
#Requires AutoHotkey v2.0

Class BarChart
{
	__new(Header:='',Footer:='')
	{
		this.Header := Header
		this.Footer := Footer
		this.Alignment := 'Horizontal'
		this.BarWidth:=500
		this.BarHeight:=50
		this.FontSize:=12
		this.FontColor:='Black'
		this.BarColor:='98fa98'
		this.BackgroundColor:='dffae6'
		this.Guioptions := "-MinimizeBox -MaximizeBox +Caption +Owner +AlwaysOnTop"
	}

	Create(input,show:='')
	{
		switch Type(input)
		{
			case "Map"   :ChartData := input
			case "String": ChartData := this.str2map(input,",",':')
			Default:return
		}
		switch this.Alignment, false
		{
			case "Horizontal", "H" : return this.Horizontal(ChartData,show)
			; case "Vertical"  , "V" : return this.Vertical(ChartData,show)
			Default: ToolTip('this version it onver support Horizontal alignment')
		}
	}

	Horizontal(ChartData,show)
	{
		maxval := this.findmax(ChartData)
		Prog := Gui(this.Guioptions)
		Prog.BackColor := this.BackgroundColor
		
		Prog.SetFont('s' this.FontSize ' w800 c' this.FontColor)
		if this.Header
			Prog.Add("Text", "w" this.BarWidth " BackgroundTrans center", this.Header)
		Prog.SetFont('s' this.FontSize ' w500 c' this.FontColor)
		for name, value in ChartData
		{
			Prog.Add("Progress", "xm w" this.BarWidth " h" this.BarHeight " Range1-" maxval " Background" this.BackgroundColor " c" this.BarColor, value)
			Prog.Add("Text", " w500 BackgroundTrans xp yp+15", "  " name " : " Value)
		}
		Prog.SetFont('s' this.FontSize ' w800 c' this.FontColor)
		if this.Footer
			Prog.Add("Text", "w" this.BarWidth " BackgroundTrans center", this.Footer)
		Prog.Show(show)
		return Prog
	}

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