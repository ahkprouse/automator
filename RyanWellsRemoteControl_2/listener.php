<?php
if (isset($_POST['value'])) {
    $value = $_POST['value'];

    if ($value == "PowerPoint") {
        exec('START C:\Users\Ryan\OFFICE\root\Office16\POWERPNT.EXE');
    }
    if ($value == "Word") {
        exec('START C:\Users\Ryan\OFFICE\root\Office16\WINWORD.EXE');
    }
    if ($value == "NotePad") {
        exec('START C:\Windows\notepad.exe');
    }
    if ($value == "Timer") {
        exec('START C:\xampp\htdocs\countdown-clock.lnk');
    }
    if ($value == "Map") {
        exec('START C:\xampp\htdocs\map.lnk');
    }
    if ($value == "VSCode") {
        exec('START C:\xampp\htdocs\vscode.lnk');
    }
    if ($value == "UIAViewer") {
        exec('START C:\xampp\htdocs\uiaviewer.lnk');
    }
    if ($value == "QuickCode") {
        exec('START C:\xampp\htdocs\CodeQuickTester_v2.8.lnk');
    }
    if ($value == "xampp") {
        exec('START C:\xampp\htdocs\countdown-clock.lnk');
    }
    if ($value == "AHKHelp") {
            exec('START C:\xampp\htdocs\countdown-clock.lnk');
    }    
    if ($value == "Sublime") {
            exec('START C:\xampp\htdocs\sublime.lnk');
    }    
    if ($value == "Everything") {
        exec('START C:\xampp\htdocs\everything.lnk');
}  
if ($value == "Davinci") {
    exec('START C:\xampp\htdocs\resolve.lnk');
}  
if ($value == "htdocs") {
    exec('START C:\xampp\htdocs');
}  
if ($value == "clients") {
    exec('START C:\xampp\htdocs\clients.lnk');
}  
if ($value == "newfolder") {
    exec('START C:\xampp\htdocs\folder.lnk');
}  
if ($value == "glary") {
    exec('START C:\xampp\htdocs\launchglary.lnk');
}  
if ($value == "ccleaner") {
    exec('START C:\xampp\htdocs\launchcc.lnk');
}  
if ($value == "nir") {
    exec('START C:\xampp\htdocs\nir.lnk');
} 
if ($value == "desktop") {
    exec('START %windir%\explorer.exe shell:::{3080F90D-D7AD-11D9-BD98-0000947B0257}');
} 
if ($value == "clipper") {
    exec('START C:\xampp\htdocs\screenclipper.lnk');
} 
if ($value == "ocrclip") {
    exec('START C:\xampp\htdocs\ocrclip.lnk');
} 
if ($value == "telegram") {
    exec('START C:\xampp\htdocs\screenclipper.lnk');
} 
if ($value == "vacs") {
    exec('START C:\xampp\htdocs\ecovacs.lnk');
} 
if ($value == "playpause") {
    exec('START C:\xampp\htdocs\cmdparams1.exe k');
}

    }
?>