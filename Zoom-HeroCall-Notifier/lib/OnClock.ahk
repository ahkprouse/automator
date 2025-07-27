#Requires AutoHotkey v2.0

;**************************OnClock**************************************
; Class onclock is just a callback function has only one method which is .change()
;
; onclock.change.on(Callback,T,frequency)
;
; Callback should be a function which will be called according to  'T' which is time formate, by frequency in milliseconds
;
; T is same as ahk FormatTime
; when 
; T:= 'hh' callback will be called every hour change in OS clock
; T:= 'mm' callback will be called every minute change in OS clock
; T:= 'ss' callback will be called every Second change in OS clock
; T:= 'tt' callback will be called every 12 hour 'am/pm'
; same goes for.. DD for day, MM for month, YYYY for Year
; by Xeo786
;************************************************************************

; example: following will update/show tooltip every minute
/*
x := onclock.change.on(updateToolTipEveryminute)
updateToolTipEveryminute()
{
    tooltip 'Time changed : ' FormatTime(A_Now,'HH:mm') 
}
*/

Class onclock
{
    static change(Callback,T:='mm',frequency:=200)
    {
        this.frequency := frequency
        this.Callback := Callback
        this.T := T
        fn := ObjBindMethod(this, "Timmer")
		Settimer fn, this.frequency
    }

    static Timmer()
    {
        static oldtime := FormatTime(A_Now,this.T), called := 0
        time := FormatTime(A_Now,this.T)
        if (time!= oldtime)
        && !called 
        {
            this.Callback .call()
            oldtime := time
            called := 1
        }

        if (time != oldtime)
        && called 
        {
            called := 0
        }
    }
}

