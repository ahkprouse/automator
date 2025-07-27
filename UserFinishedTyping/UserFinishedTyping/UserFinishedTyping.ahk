
#singleInstance Force
#Requires AutoHotkey v2.0.2+

main := Gui()
main.AddEdit('w300 r10')
    .OnEvent('Change', (*)=>(main['status'].value := 'Typing...', SetTimer(CheckFinishTyping, 300)))

main.AddText('vStatus w100','Ready')
main.Show()
return

CheckFinishTyping()
{
	static lower_bound := 500
	static upper_bound := 5000

	if A_TimeIdleKeyboard < lower_bound
	|| A_TimeIdleKeyboard > upper_bound
		return

	main['status'].value := 'Ready'
	SetTimer CheckFinishTyping, false
}