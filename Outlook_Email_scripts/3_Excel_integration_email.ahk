#Include <Default_Settings> ;RAlt::
Browser_Forward::Reload ;RControl::
Browser_Back::
;***********Get email addresses from Excel*******************
XL_Handle(XL,1) ;Connect to Excel Application   1=Application 2=Workbook 3=Worksheet
loc:=XL_Find_Headers_in_Cols(XL,["email","First_Name","Industry","Price"]) ;pass search terms as an array and store locations in loc Object
;~  MsgBox % loc.email  A_Tab loc.First_Name A_Tab loc.Industry

;***********selected*******************
First_RWSL := XL.Selection.Row ;Identifies first row selected
Loops:=XL.Selection.Rows.Count ;returns number of rows selected
;~ MsgBox % First_RWSL a_tab loops
;***********now loop over active rows*******************
loop, % XL.Selection.Rows.Count {
     email:= XL.Range[loc.email . (First_RWSL + a_index-1)].value ; email address
First_Name:= XL.Range[loc.First_Name . (First_RWSL + a_index-1)].value ; First Name
  Industry:= XL.Range[loc.Industry . (First_RWSL + a_index-1)].value ; Industry
     Price:= Round(XL.Range[loc.Price . (First_RWSL + a_index-1)].value,2) ; Price

;~  MsgBox % email A_Tab First_Name A_Tab Industry A_Tab Price

MailItem := ComObjActive("Outlook.Application").CreateItem(0)
MailItem.BodyFormat := 2 ;html format
MailItem.TO  :=email ;"joejunkemail@yahoo.com"
MailItem.Subject:="How are things in " Industry "?"
;************************************************************
Body =
(
<HTML><p>Hi %First_Name%,</p>
<p>Just checking up if you were interested in the whatchamacleit I mentioned the other day for $%Price%.</p>
Cheers<br/>
<strong><em>Joe Glines</em></strong><br/></HTML>
)
MailItem.HTMLBody:=body
MailItem.Display ;
MsgBox Pause
}
return

