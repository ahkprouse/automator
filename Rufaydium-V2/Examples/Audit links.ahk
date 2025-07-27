#include ..\Rufaydium.ahk

url := InputBox( "Provide link", "Link tester")
if !url or !RegExMatch(url.value,"^http")
{
	Notify.show("please provide correct URL`n Please reRun")
	exitapp
}
url := url.value

RegExMatch(url,"//([\w\d.-]+)",&Origin)
Chrome := Rufaydium()
Page := Chrome.NewSession()
Page.url := url
xlapp := ComObject('excel.application')
xlapp.visible := true
book := xlapp.Workbooks.Add
book.saveas(a_desktop "\newbook.xlsx", FileFormat:= 51)
sheet := book.sheets(1)
cell := sheet.range('a1')
cell.offset(0,0).value := "text"
cell.offset(0,1).value := "Link"
cell.offset(0,2).value := "Origin"
cell.offset(0,3).value := "Status"
for i, ele in Page.findelements(Session.by.Plinktext,"") ; querySelector('main')
{
	CheckOrigin := "CrossOrigin"
	href := ele.href
	if InStr(href,Origin[1])
		CheckOrigin := "Same"
	cell.offset(a_index,0).value := ele.innerText
	cell.offset(a_index,1).value := href
	cell.offset(a_index,2).value := CheckOrigin
	cell.offset(a_index,3).value := stst := checkstatus()
	lastn := i
}
; lastn := 3
; text := Page.querySelector('.content.rich-content').querySelectorAll('p')[1].innerText
; Page.querySelector('.content.rich-content').querySelectorAll('p')[1].innerText := text "`narbab.irfan@gmail.com" 

; maintext := Page.querySelector('main').innerText
; if RegExMatch(maintext,"(?<email>[\w\d._-]+@[\w\d]+.\w\w\w)\W",&t)
; {
; 	if ValidateEMail(t['email'])
; 	{
; 		email := Page.findelements(Session.by.Plinktext,t['email'])
; 		if IsObject(email)
; 			emaillink := "email is linked"
; 		else
; 			emaillink := "email not linked"
; 	}
; 	cell.offset(lastn +1,1).value := t['email']
; 	cell.offset(lastn +1,2).value := emaillink
; }

Notify.show("done")
Page.close()
Chrome.Exit()
sleep 5000
exitapp


ValidateEMail(email)
{
	if RegExMatch(email,"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$")
		return 1
}

checkstatus()
{
	Http := ComObject('WinHttp.WinHttpRequest.5.1')
	Http.Open("GET", url, false)
	Http.SetRequestHeader("Content-Type","application/json")
	Http.Send()
	Http.WaitForResponse()
	return Http.Status()
}

^f12::
{
	book.save()
	Book.close()
	xlapp.quit()
	Page.close()
	Chrome.Exit()
	exitapp
}