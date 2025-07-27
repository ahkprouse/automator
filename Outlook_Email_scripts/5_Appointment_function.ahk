#Include <default_Settings>
Browser_Forward::Reload
Browser_Back::
;***********************Read and Write appointments from Calendar**************************.
;http://www.autohotkey.com/forum/viewtopic.php?t=61509&p=379775#379775
;~https://msdn.microsoft.com/EN-US/library/office/ff862177.aspx

Start_Time:="9/1/2017 11:00:00 AM"  ; "3/2/2017" . A_Space . "5:00pm"
Body:="my test of body"
Subj:="my test of subject"
Audio:="C:\Windows\Media\Windows Notify Messaging.wav"

;~ Create_Appoint(Body,0,"Red",1,10,0,"Office","Joe","joejunk",20,Audio,1,Start_Time,Subj)
Create_Appoint(Body,0,"Red",1,10,0,"Office","Joe","joejunk",,,,Start_Time,Subj)
return

Create_Appoint(Body="",Busy_Status="2",Category="Blue",Display=0,Duration=60,Importance=1,Location="",Opt_Attend="",Req_Attend="",Reminder_Min=20,Reminder_Audio="",Sensitivity=0,Start_Time="",Subject=""){
Outlook := ComObjCreate("Outlook.Application") ;also check to see if Outlook is running?
item := outlook.CreateItem(1) ;create appointment
;~item.Attachments.Add:=""http://replyapp.acemlnb.com/lt.php?s=c95b6ab39c2d493c61162c1479113bc2&i=497A659A26A8815http://replyapp.acemlnb.com/lt.php?s=c95b6ab39c2d493c61162c1479113bc2&i=497A659A26A8815
;~item.AllDayEvent:=1 ;True
item.Body := Body
item.BusyStatus := Busy_Status ;0=Free 1=Tentative 2=Busy  3=Out of Office 4=Working Elsewhere
item.Categories := Category . " Category" ;~ "Blue Category"  https://msdn.microsoft.com/en-us/library/office/ff864208.aspx
item.Duration := Duration ; 60 ;use this or item.end
;~ item.End   := End_Time ;"3/2/2017" . A_Space . "7:00pm"
item.Importance:= Importance ;0=low 1=Normal 2=High
item.Location:= Location ;"Internet" ;Location of appointment
item.OptionalAttendees:= Opt_Attend ; "Bob the Builder"
item.RequiredAttendees:= Req_Attend ; "James Brown"
Item.ReminderMinutesBeforeStart:= Reminder_Min ; 60
item.ReminderSet := True
;~ item.RTFBody:=Body ;https://msdn.microsoft.com/en-us/library/office/ff861303.aspx
item.ReminderPlaySound := True
item.ReminderSoundFile:=Reminder_Audio
item.Sensitivity:= Sensitivity ;2 ;0=Normal 1=Personal 2=Private 3=Confidential
item.Start := Start_Time ; 9/1/2010 9:00:00 AM
item.Subject := Subject
if (Display=1)
    item.Display()
item.save()  ; warns about programmatic access with normal settings
}


