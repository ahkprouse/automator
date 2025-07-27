;*******************************************************
; Want a clear path for learning AutoHotkey; Take a look at our AutoHotkey Udemy courses.  They're structured in a way to make learning AHK EASY
; Right now you can  get a coupon code here: https://the-Automator.com/Learn
;*******************************************************
#SingleInstance,Force
;~ #Include <default_Settings> ;RAlt::
;~  Browser_Forward::Reload ;RControl::
;~  Browser_Back::
;************************************************************
SetWorkingDir,%A_ScriptDir%\
OnMessage(0x232,"Move_Windows")
SetBatchLines,-1

Arena_Grid:=[[],[]]
Pig_Count_Array:=[]
Pig_Count:=0


oPig:=[[],{1:"",2:"",3:"",4:""}]



Pig_Png:=[]
Pig_Png[1]:="test.bmp"
Pig_Png[2]:="test.bmp"
Pig_Png[3]:="test.bmp"
Pig_Png[4]:="test.bmp"

Force_Move:=0


;oPig[]{1:"",2:"",3:"",4:""}  ;Template for pig objects
;oPig[]{Pig_Y:"",Pig_X:"",Pig_Direction:"",Action:""} ;Meaning of item in pig objects



Create_Arena()
;SetTimer,Add_Pig,10
SetTimer,Start_Moving_Pigs,Off
return

;                                       Labels
;#####################################################################################################################
;#####################################################################################################################
;#####################################################################################################################
;#####################################################################################################################

GuiClose:
ExitApp
Reload:
Reload
Submit2:
Gui,2:Submit,NoHide
return
Add_Pig:
	;loop 500
New_Pig_Settings()
ToolTip, % Pig_Count
return
Add_100_Pigs:
Loop 100
{
			New_Pig_Settings()
			ToolTip, % Pig_Count
		}
	return
Start_Pigs:
	SetTimer,Start_Moving_Pigs,10
	;MsgBox, 262144, ,Here
	return
Stop_Pigs:
	SetTimer,Start_Moving_Pigs,Off
	return
Start_Moving_Pigs:
	;MsgBox, 262144, ,Here
	Move_Pigs()
	return
Move_All_Pigs_Down:
	i:=1
	Loop % Pig_Count
		{
			if(oPig[i].3!=3)
				{
					oPig[i].3:=3
					GuiControl,4:,Pig%i%,% Pig_Png[3]
				}
			i++
		}
	return
Move_All_Pigs_Right:
	i:=1
	Loop % Pig_Count
		{
			if(oPig[i].3!=2)
				{
					oPig[i].3:=2
					GuiControl,4:,Pig%i%,% Pig_Png[2]
				}
			i++
		}
	return
Move_All_Pigs_Up:
	i:=1
	Loop % Pig_Count
		{
			if(oPig[i].3!=1)
				{
					oPig[i].3:=1
					GuiControl,4:,Pig%i%,% Pig_Png[1]
				}
			i++
		}
	return
Move_All_Pigs_Left:
	i:=1
	Loop % Pig_Count
		{
			if(oPig[i].3!=4)
				{
					oPig[i].3:=4
					GuiControl,4:,Pig%i%,% Pig_Png[4]
				}
			i++
		}
	return
;                                       Functions
;#####################################################################################################################
;#####################################################################################################################
;#####################################################################################################################
;#####################################################################################################################

Move_Pigs()
	{
		global
		;MsgBox, 262144, ,Here
		g:=1
		Loop % Pig_Count
			{
				if(oPig[g].3=1) ;Up
					{
						;MsgBox, 262144, ,Here
						Check_Up()
					}
				else if(oPig[g].3=2) ;Right
					{
						Check_Right()
					}
				else if(oPig[g].3=3) ;Down
					{
						Check_Down()
					}
				else if(oPig[g].3=4) ;Left
					{
						Check_Left()
					}
				g++
			}
	}
Check_Left()
	{
		global
		if(Arena_Grid[oPig[g].1,oPig[g].2-1]=0)
			{
				;MsgBox, 262144, ,Here
				Move_Left()
			}
		else if(Force_Move = 0)
			New_Pig_Direction_Left()
	}
Check_Down()
	{
		global
		if(Arena_Grid[oPig[g].1+1,oPig[g].2]=0)
			{
				;MsgBox, 262144, ,Here
				Move_Down()
			}
		else if(Force_Move = 0)
			New_Pig_Direction_Down()
	}
Check_Right()
	{
		global
		if(Arena_Grid[oPig[g].1,oPig[g].2+1]=0)
			{
				;MsgBox, 262144, ,Here
				Move_Right()
			}
		else if(Force_Move = 0)
			New_Pig_Direction_Right()
	}
Check_Up()
	{
		global
		;MsgBox, 262144, , % oPig[g].1-1
		if(Arena_Grid[oPig[g].1-1,oPig[g].2]=0)
			{
				;MsgBox, 262144, ,Here
				Move_Up()
			}
		else if(Force_Move = 0)
			New_Pig_Direction_Up()
	}
New_Pig_Direction_Up()
	{
		global
		i:=1
		Loop
			{
				Random,Dir,2,4
				if(Dir=2&&Arena_Grid[oPig[g].1,oPig[g].2+1]=0)
					{
						oPig[g].3:=2
						GuiControl,4:,Pig%g%,% Pig_Png[2]
						break
					}
				else if(Dir=3&&Arena_Grid[oPig[g].1+1,oPig[g].2]=0)
					{
						oPig[g].3:=3
						GuiControl,4:,Pig%g%,% Pig_Png[3]
						break
					}
				else if(Dir=4&&Arena_Grid[oPig[g].1,oPig[g].2-1]=0)
					{
						oPig[g].3:=4
						GuiControl,4:,Pig%g%,% Pig_Png[4]
						break
					}
				else if(i>5)
					break
				i++
			}
	}
New_Pig_Direction_Right()
	{
		global
		i:=1
		Loop
			{
				Random,Dir,1,4
				if(Dir=1&&Arena_Grid[oPig[g].1-1,oPig[g].2]=0)
					{
						oPig[g].3:=1
						GuiControl,4:,Pig%g%,% Pig_Png[1]
						break
					}
				else if(Dir=3&&Arena_Grid[oPig[g].1+1,oPig[g].2]=0)
					{
						oPig[g].3:=3
						GuiControl,4:,Pig%g%,% Pig_Png[3]
						break
					}
				else if(Dir=4&&Arena_Grid[oPig[g].1,oPig[g].2-1]=0)
					{
						oPig[g].3:=4
						GuiControl,4:,Pig%g%,% Pig_Png[4]
						break
					}
				else if(i>8)
					break
				i++
			}
	}
New_Pig_Direction_Down()
	{
		global
		i:=1
		Loop
			{
				Random,Dir,1,4
				if(Dir=1&&Arena_Grid[oPig[g].1-1,oPig[g].2]=0)
					{
						oPig[g].3:=1
						GuiControl,4:,Pig%g%,% Pig_Png[1]
						break
					}
				else if(Dir=2&&Arena_Grid[oPig[g].1,oPig[g].2+1]=0)
					{
						oPig[g].3:=2
						GuiControl,4:,Pig%g%,% Pig_Png[2]
						break
					}
				else if(Dir=4&&Arena_Grid[oPig[g].1,oPig[g].2-1]=0)
					{
						oPig[g].3:=4
						GuiControl,4:,Pig%g%,% Pig_Png[4]
						break
					}
				else if(i>8)
					break
				i++
			}
	}
New_Pig_Direction_Left()
	{
		global
		i:=1
		Loop
			{
				Random,Dir,1,3
				if(Dir=1&&Arena_Grid[oPig[g].1-1,oPig[g].2]=0)
					{
						oPig[g].3:=1
						GuiControl,4:,Pig%g%,% Pig_Png[1]
						break
					}
				else if(Dir=2&&Arena_Grid[oPig[g].1,oPig[g].2+1]=0)
					{
						oPig[g].3:=2
						GuiControl,4:,Pig%g%,% Pig_Png[2]
						break
					}
				else if(Dir=3&&Arena_Grid[oPig[g].1+1,oPig[g].2]=0)
					{
						oPig[g].3:=3
						GuiControl,4:,Pig%g%,% Pig_Png[3]
						break
					}
				else if(i>5)
					break
				i++
			}
	}
Move_Up()
	{
		global
		Arena_Grid[oPig[g].1,oPig[g].2]:=0
		Arena_Grid[oPig[g].1-1,oPig[g].2]:=2
		oPig[g].1-=1
		YYPig:=(oPig[g].1-1)*10
		GuiControl,4:Move,Pig%g%,y%YYPig%
	}
Move_Down()
	{
		global
		Arena_Grid[oPig[g].1,oPig[g].2]:=0
		Arena_Grid[oPig[g].1+1,oPig[g].2]:=2
		oPig[g].1+=1
		YYPig:=(oPig[g].1-1)*10
		GuiControl,4:Move,Pig%g%,y%YYPig%
	}
Move_Right()
	{
		global
		Arena_Grid[oPig[g].1,oPig[g].2]:=0
		Arena_Grid[oPig[g].1,oPig[g].2+1]:=2
		oPig[g].2+=1
		XXPig:=(oPig[g].2-1)*10
		GuiControl,4:Move,Pig%g%,x%XXPig%
	}
Move_Left()
	{
		global
		Arena_Grid[oPig[g].1,oPig[g].2]:=0
		Arena_Grid[oPig[g].1,oPig[g].2-1]:=2
		oPig[g].2-=1
		XXPig:=(oPig[g].2-1)*10
		GuiControl,4:Move,Pig%g%,x%XXPig%
	}
New_Pig_Settings()
	{
		global
		Insert_Pig_To_Pig_Count_Array()
		Set_New_Pig_Direction_And_Location()
		Place_New_Pig_On_Map()
	}
Insert_Pig_To_Pig_Count_Array()
	{
		global
		Pig_Count++
		Loop % Pig_Count
			{
				if(Pig_Count_Array[A_Index]=0||Pig_Count_Array[A_Index]=Null)
					{
						Pig_Count_Array[A_Index] := 1
						Pig_Slot := A_Index
						;msgbox, % Pig_Slot "`n" A_Index
						break
					}
			}
	}
Set_New_Pig_Direction_And_Location()
	{
		global
		Random,Pig_Direction,1,4
		Loop
			{
				Random,Pig_XX,2,99
				Random,Pig_YY,2,69
				if(Arena_Grid[Pig_YY,Pig_XX]=0)
					{
						oPig[Pig_Slot]:={1:"",2:"",3:"",4:""}
						oPig[Pig_Slot].1:=Pig_YY
						oPig[Pig_Slot].2:=Pig_XX
						oPig[Pig_Slot].3:=Pig_Direction
						oPig[Pig_Slot].4:=0
						;MsgBox, 262144, ,% Pig_Slot "`n" oPig[Pig_Slot].1 "`n" oPig[Pig_Slot].2 "`n" oPig[Pig_Slot].3 "`n" oPig[Pig_Slot].4
						;dmp(oPig)
						break
					}
			}

	}
Place_New_Pig_On_Map()
	{
		global
		XPig:= (oPig[Pig_Slot].2-1)*10
		YPig:= (oPig[Pig_Slot].1-1)*10
		;MsgBox, 262144, ,% oPig[Pig_Slot].1 "`n" oPig[Pig_Slot].2 "`n" oPig[Pig_Slot].3 "`n" oPig[Pig_Slot].4 "`n" XPig "`n" YPig
		Arena_Grid[oPig[Pig_Slot].1,oPig[Pig_Slot].2]:=2
		Gui,4:Add,Picture, x%XPig% y%YPig% w10 h10 vPig%Pig_Slot%,% Pig_Png[oPig[Pig_Slot].3]
	}
Create_Arena() ;GUI 1
	{
		global
		Gui,1:+AlwaysOnTop
		Gui,1:Color,Gray
		Gui,1:Show,x0 y0 w1300 h700
		Add_Control_Panel()
		Add_Background_Layer()
		Add_Bot_Layer()
		Create_Grid()
	}
Add_Control_Panel() ;GUI 2
	{
		global
		Gui,2:+AlwaysOnTop -Caption +Owner1
		Gui,2:Color,AAAA55
		Gui,2:Add,Button,x50 y20 w200 h40 Section gAdd_Pig,Add New Pig
		Gui,2:Add,Button,xs w200 h40 Section gAdd_100_Pigs,Add 100 New Pigs
		Gui,2:Add,Button,xs w200 h40  gStart_Pigs,Start Pigs
		Gui,2:Add,Button,xs w200 h40  gStop_Pigs,Stop Pigs
		Gui,2:Add,Checkbox,xs vForce_Move gSubmit2,Force Move
		Gui,2:Add,Button,xs w200 h40  gMove_All_Pigs_Up,Send Pigs Up
		Gui,2:Add,Button,xs w200 h40  gMove_All_Pigs_Right,Send Pigs Right
		Gui,2:Add,Button,xs w200 h40  gMove_All_Pigs_Down,Send Pigs Down
		Gui,2:Add,Button,xs w200 h40  gMove_All_Pigs_Left,Send Pigs Left
		Gui,2:Add,Button,xs w200 h40  gReload,Reload
		Gui,2:Add,Picture,xs w200 h200  ,Pig Up.png

		Gui,2:Show,x3 y26 w300 h700
	}
Add_Background_Layer() ;GUI 3
	{
		global
		Gui,3:+AlwaysOnTop -Caption +Owner1
		Gui,3:Color,F0F0F0

		Gui,3:Add,Picture,x0 y0 w1000 h10,Black Square.png
		Gui,3:Add,Picture,x0 y690 w1000 h10,Black Square.png
		Gui,3:Add,Picture,x0 y10 w10 h680,Black Square.png
		Gui,3:Add,Picture,x990 y10 w10 h680,Black Square.png

		Gui,3:Show,x303 y26 w1000 h700
		Gui,3:+LastFound

		Winset,Transcolor,F0F0F0
	}
Add_Bot_Layer() ;GUI 4
	{
		global
		Gui,4:+AlwaysOnTop -Caption +Owner1
		Gui,4:Color,F0F0F0
		Gui,4:Show,x303 y26 w1000 h700
		Gui,4:+LastFound

		Winset,Transcolor,F0F0F0
	}
Create_Grid()
	{
		global
		j:=1
		Loop 70
			{
				i:=1
				Loop 100
					{
						if(i=1||i=100||j=1||j==70)
							Arena_Grid[j,i]:=1
						else
							Arena_Grid[j,i]:=0
						i++
					}
				j++
			}
		;MsgBox, % Arena_Grid[2,33] "`n" Arena_Grid[60,2]	"`n" Arena_Grid[2,2] "`n" Arena_Grid[50,77]
	}
Move_Windows()
	{
		WinGetPos,X,Y,,,A
		X1:=X+303
		Y1:=Y+26
		X2:=X+3
		Gui,2:Show,% "x" X2 "y" Y1
		Gui,3:Show,% "x" X1 "y" Y1
		Gui,4:Show,% "x" X1 "y" Y1
	}
Esc::ExitApp