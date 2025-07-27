#Requires AutoHotkey v2.0

#Include ..\NotifyV2.ahk


f1::
{
  WinGetClientPos(&x,&y,&w,&h,'A')
  Notify.Show(
    {
      BDText:'Some text',
      HDText:'some header',
      GenLoc:'x' x + w/2  ' y' y + h/2
    }
  )
}