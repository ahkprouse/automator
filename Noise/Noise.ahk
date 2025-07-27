/**
 * =========================================================================== *
 * Want a clear path for learning AutoHotkey?                                  *
 * Take a look at our AutoHotkey courses here: the-Automator.com/Discover      *
 * They're structured in a way to make learning AHK EASY                       *
 * And come with a 200% moneyback guarantee so you have NOTHING to risk!       *
 * =========================================================================== *
 * @author      the-Automator                                                  *
 * @version     0.0.0                                                          *
 * @copyright   Copyright (c) 2024 The Automator                               *
 * @link        https://www.the-automator.com/                                 *
 * @created     YYYY-DD-MM                                                     *
 * @modified    YYYY-DD-MM                                                     *
 * @description                                                                *
 * =========================================================================== *
 * @license     CC BY 4.0                                                      *
 * =========================================================================== *
   This work by the-Automator.com is licensed under CC BY 4.0

   Attribution — You must give appropriate credit , provide a link to the license,
   and indicate if changes were made.

   You may do so in any reasonable manner, but not in any way that suggests the licensor
   endorses you or your use.

   No additional restrictions — You may not apply legal terms or technological measures that
   legally restrict others from doing anything the license permits.
 */
;@Ahk2Exe-SetVersion     "0.0.0"
;@Ahk2Exe-SetMainIcon    res\main.ico
;@Ahk2Exe-SetProductName the-Automator 
;@Ahk2Exe-SetDescription the-Automator
#Requires AutoHotkey v2.0+
#SingleInstance Force
; Noise.ahk
; Sends keystrokes to keep the PC from falling asleep
; Skrommel @2005
; Srouce : https://www.dcmembers.com/skrommel/download/noise/


A_TrayMenu.add('Open Folder',(*)=>Run(A_ScriptDir))
A_TrayMenu.SetIcon("Open Folder","shell32.dll",4)

Noise := 1
NoiseDelay := 10000
MyGui       := Gui("-SysMenu","Noise!")

MyEdit      := MyGui.add("edit")

MyText      := MyGui.add("Text", "w120" ,"Delay: " round((NoiseDelay / 100) * 50,0) " milliseconds" )
MySlider    := MyGui.AddSlider(,50)
MySlider.OnEvent("Change",ToggleNoise)

ToogleBtn   := MyGui.add("button",,"Pause")
ToogleBtn.OnEvent("Click",ToggleNoise)

MyGui.add("button","x+m","Quit").OnEvent("click",(*) => ExitApp())
MyGui.Show()
setTimer MakeNoise, (NoiseDelay / 100) * MySlider.Value
return

MakeNoise()
{
    if !MyEdit.Enabled
        MyEdit.Enabled := 1
    MyEdit.value := ""
    N := Random(65,90)
    ControlSend "{Blind}" Chr(n), "Edit1", "Noise!"
}

ToggleNoise(obj,info)
{
    Global Noise
    MyText.Value := "Delay: " round((NoiseDelay / 100) * MySlider.Value ,0) " milliseconds"
    if obj.Text = "Start" or obj.Text = "Pause"
        Noise := !Noise
    if Noise
    {
        ToogleBtn.Text := "Pause"
        setTimer MakeNoise, (NoiseDelay / 100) * MySlider.Value + 1
    }   
    else
    {
        ToogleBtn.Text := "Start"
        MyEdit.value := "Start to avoid Sleep"
        MyEdit.Enabled := 0
        setTimer MakeNoise, 0
    }   
}
