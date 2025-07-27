#SingleInstance, Force ; Only allow one version running
Browser_Forward::Reload ; Reload the script
Browser_Back::
;http://www.autohotkey.com/forum/topic69675.html
;~  mail :=    ComObjActive("Outlook.Application").GetNameSpace("MAPI").GetDefaultFolder[6] ;Inbox
mail := ComObjActive("Outlook.Application").GetNameSpace("MAPI").GetDefaultFolder[6].Folders("AutoHotkey")

MsgBox % "there are " mail.Items.Count " emails in the " mail.Name " folder"
Loop %   mail.Items.Count
	{
	   if   Instr(mail.Items[A_Index].SenderName,"Joe Glines") {
       ;~  if   Instr(mail.Items[A_Index].Subject,"AutoHotkey") {
			Item := mail.Items(A_Index) ;sets Item to the values of the selected email

		MsgBox %  "To:`t" Item.To  "  Subject:`t" Item.Subject "`r" ;.   "`nBody:`t" Item.Body
      ;~  mail.Items[A_Index].Display() ; Shows email
		}
}
;~  SciTE_Output(list) ;Text,Clear=1,LineBreak=1,Exit=0


