;~ #Include <default_Settings>
;**************************************
;Learn more about RegEx here: https://the-Automator.com/RegEx
;Get this file Here: https://the-Automator.com/RegExPhone
;Learn more about functions here: https://the-Automator.com/Functions
;**************************************
MsgBox % phone:=PhoneStandardizer("0123456789101112")
;********************Standardize Phone numbers***********************************
PhoneStandardizer(PhoneNumb){   
	numbs:=RegExReplace(phoneNumb,"\D")   ; removes all non-digits
	return RegExReplace(Numbs,".*(\d{3})(\d{3})(\d{4}).*","$1.$2.$3")
}