;
; DO NOT RUN FROM INNO SETUP EDITOR
; THIS SCRIPT REQUIRES ENVIRONMENT VARIABLES FROM BATCH
;

#define MyBetaProd GetEnv('QAPBETAPROD')
#define MyAppVersionNumber GetEnv('QAPVERSIONNUMBER') ; exemple "1.2.3.4"
#define MyAppVersion GetEnv('QAPVERSIONTEXT') ; exemple "v1.2.3.4 BETA"
#define MyVersionFileName GetEnv('QAPVERSIONFILE') ; exemple "1_2_3_4 ou 1_2_3_4-beta"

#define MyAppName "Quick Access Popup"
#define MyAppNameNoSpace "QuickAccessPopup"
#define MyAppNameLower "quickaccesspopup"
#define MyAppPublisher "Jean Lalonde"
#define MyAppURL "http://www.QuickAccessPopup.com"
#define MyAppExeName "QuickAccessPopup.exe"
#define MyDateYearString GetDateTimeString('yyyy', '', '');
#define MyAppCopyright "Copyright (c) Jean Lalonde 2013-"
#define MyAppDescription "Quick Access Popup (Windows software)"
#define QAPmessengerVersionFileName "QAPmessenger-1_4-32-bit.exe"
#define JLdir "JeanLalonde"
#define JLicons "JLicons-1_6_3.dll"
#define SQLite "sqlite3"

[CustomMessages]
; Example
; VariableName=Text
; Filename: "https://www.quickaccesspopup.com/example/"; Description: "{cm:VariableName}"; Flags: postinstall shellexec unchecked
HelpMePayExpenses=&HELP me pay EXPENSES for making QAP
dutch.HelpMePayExpenses=&Help me om de uitgaven te betalen om QAP
french.HelpMePayExpenses=&Aidez-moi � payer mes frais
PaypalCredit=(Paypal or credit cards)
dutch.PaypalCredit=(Paypal of creditcards)
french.PaypalCredit=(Paypal ou cartes de cr�dit)

[Setup]
; NOTE: The value of AppId uniquely identifies this application.
; Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
AppId={{ZZZZZZZZ-ZZZZ-ZZZZ-ZZZZ-ZZZZZZZZZZZZ}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
AppCopyright={#MyAppCopyright}{#MyDateYearString}
DefaultDirName={commonpf}\{#MyAppName}
DefaultGroupName={#MyAppName}
LicenseFile=C:\Dropbox\AutoHotkey\{#MyAppNameNoSpace}\Distribution-files\license.txt
OutputDir=C:\Temp\QAP_Compile\
OutputBaseFilename={#MyAppNameLower}-setup{#MyBetaProd}
SetupIconFile=C:\Dropbox\AutoHotkey\{#MyAppNameNoSpace}\Distribution-files\{#MyAppNameNoSpace}{#MyBetaProd}.ico
Compression=lzma
SolidCompression=yes
ArchitecturesInstallIn64BitMode=x64
; AppMutex={#MyAppNameNoSpace}Mutex -> do not use AppMutex - Use instead automatic closing when install and [Code] section when uninstall
; DisableWelcomePage=yes -> keep default and display (make it is displayed)
DisableWelcomePage=no
; DisableReadyPage=yes -> keep default and display
; display Dir page only at first install but show dir on ready page
DisableDirPage=auto
AlwaysShowDirOnReadyPage=yes
; display Group page only at first install but show group on ready page
DisableProgramGroupPage=auto
AlwaysShowGroupOnReadyPage=yes
VersionInfoVersion={#MyAppVersionNumber}
VersionInfoCopyright={#MyAppCopyright}{#MyDateYearString}
VersionInfoCompany={#MyAppPublisher}
VersionInfoDescription={#MyAppDescription}

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"
Name: "french"; MessagesFile: "compiler:Languages\French.isl"
Name: "german"; MessagesFile: "compiler:Languages\German.isl"
Name: "dutch"; MessagesFile: "compiler:Languages\Dutch.isl"
Name: "korean"; MessagesFile: "compiler:Languages\Korean.isl"
; Name: "swedish"; MessagesFile: "compiler:Languages\Swedish.isl"
Name: "italian"; MessagesFile: "compiler:Languages\Italian.isl"
Name: "spanish"; MessagesFile: "compiler:Languages\Spanish.isl"
Name: "brazilportuguese"; MessagesFile: "compiler:Languages\BrazilianPortuguese.isl"
; Name: "chinesetraditional"; MessagesFile: "compiler:Languages\ChineseTraditional.isl"
Name: "portuguese"; MessagesFile: "compiler:Languages\Portuguese.isl"
Name: "russian"; MessagesFile: "compiler:Languages\Russian.isl"
; Name: "chinesesimplified"; MessagesFile: "compiler:Languages\ChineseSimplified.isl"

[Dirs]
; repository for files to be copied for first execution
Name: "{commonappdata}\{#MyAppName}" 

[Files]
Source: "C:\Dropbox\AutoHotkey\{#MyAppNameNoSpace}\build-v8{#MyBetaProd}\{#MyAppNameNoSpace}-64-bit.exe"; DestDir: "{app}"; DestName: "{#MyAppNameNoSpace}.exe"; Check: IsWin64; Flags: 64bit ignoreversion signonce
Source: "C:\Dropbox\AutoHotkey\{#MyAppNameNoSpace}\build-v8{#MyBetaProd}\{#MyAppNameNoSpace}-32-bit.exe"; DestDir: "{app}"; DestName: "{#MyAppNameNoSpace}.exe"; Check: "not IsWin64"; Flags: 32bit ignoreversion signonce
Source: "C:\Dropbox\AutoHotkey\{#MyAppNameNoSpace}\Distribution-files\{#QAPmessengerVersionFileName}"; DestDir: "{app}"; DestName: "QAPmessenger.exe"; Flags: ignoreversion signonce
Source: "C:\Dropbox\AutoHotkey\{#MyAppNameNoSpace}\Distribution-files\Setup-Only\_do_not_remove_or_rename.txt"; DestDir: "{app}"; DestName: "_do_not_remove_or_rename.txt"; Flags: ignoreversion
Source: "C:\Dropbox\AutoHotkey\{#MyAppNameNoSpace}\Distribution-files\{#MyAppNameNoSpace}.ico"; DestDir: "{app}"; DestName: "{#MyAppNameNoSpace}.ico"; Flags: ignoreversion
Source: "C:\Dropbox\AutoHotkey\{#MyAppNameNoSpace}\Distribution-files\{#JLicons}"; DestDir: "{commonappdata}\{#JLdir}"; DestName: "JLicons.dll"; Flags: sharedfile ignoreversion signonce
Source: "C:\Dropbox\AutoHotkey\{#MyAppNameNoSpace}\Distribution-files\Setup-Only\_JeanLalonde_read-me.txt"; DestDir: "{commonappdata}\{#JLdir}"; DestName: "_read-me.txt"; Flags: sharedfile ignoreversion
Source: "C:\Dropbox\AutoHotkey\{#MyAppNameNoSpace}\Distribution-files\{#SQLite}-64-bit.dll"; DestDir: "{app}"; DestName: "{#SQLite}.dll"; Check: IsWin64; Flags: 64bit ignoreversion signonce
Source: "C:\Dropbox\AutoHotkey\{#MyAppNameNoSpace}\Distribution-files\{#SQLite}-32-bit.dll"; DestDir: "{app}"; DestName: "{#SQLite}.dll"; Check: not IsWin64; Flags: 32bit ignoreversion signonce
Source: "C:\Dropbox\AutoHotkey\{#MyAppNameNoSpace}\Distribution-files\{#SQLite}-64-bit.def"; DestDir: "{app}"; DestName: "{#SQLite}.def"; Check: IsWin64; Flags: 64bit ignoreversion
Source: "C:\Dropbox\AutoHotkey\{#MyAppNameNoSpace}\Distribution-files\{#SQLite}-32-bit.def"; DestDir: "{app}"; DestName: "{#SQLite}.def"; Check: not IsWin64; Flags: 32bit ignoreversion
; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[INI]
Filename: "{commonappdata}\{#MyAppName}\{#MyAppNameLower}-setup.ini"; Section: "Global"; Key: "LanguageCode"; String: "EN"; Languages: english
Filename: "{commonappdata}\{#MyAppName}\{#MyAppNameLower}-setup.ini"; Section: "Global"; Key: "LanguageCode"; String: "FR"; Languages: french
Filename: "{commonappdata}\{#MyAppName}\{#MyAppNameLower}-setup.ini"; Section: "Global"; Key: "LanguageCode"; String: "DE"; Languages: german
Filename: "{commonappdata}\{#MyAppName}\{#MyAppNameLower}-setup.ini"; Section: "Global"; Key: "LanguageCode"; String: "NL"; Languages: dutch
Filename: "{commonappdata}\{#MyAppName}\{#MyAppNameLower}-setup.ini"; Section: "Global"; Key: "LanguageCode"; String: "KO"; Languages: korean
; Filename: "{commonappdata}\{#MyAppName}\{#MyAppNameLower}-setup.ini"; Section: "Global"; Key: "LanguageCode"; String: "SV"; Languages: swedish
Filename: "{commonappdata}\{#MyAppName}\{#MyAppNameLower}-setup.ini"; Section: "Global"; Key: "LanguageCode"; String: "IT"; Languages: italian
Filename: "{commonappdata}\{#MyAppName}\{#MyAppNameLower}-setup.ini"; Section: "Global"; Key: "LanguageCode"; String: "ES"; Languages: spanish
Filename: "{commonappdata}\{#MyAppName}\{#MyAppNameLower}-setup.ini"; Section: "Global"; Key: "LanguageCode"; String: "PT-BR"; Languages: brazilportuguese
; Filename: "{commonappdata}\{#MyAppName}\{#MyAppNameLower}-setup.ini"; Section: "Global"; Key: "LanguageCode"; String: "ZH-TW"; Languages: chinesetraditional
Filename: "{commonappdata}\{#MyAppName}\{#MyAppNameLower}-setup.ini"; Section: "Global"; Key: "LanguageCode"; String: "PT"; Languages: portuguese
Filename: "{commonappdata}\{#MyAppName}\{#MyAppNameLower}-setup.ini"; Section: "Global"; Key: "LanguageCode"; String: "RU"; Languages: russian
; Filename: "{commonappdata}\{#MyAppName}\{#MyAppNameLower}-setup.ini"; Section: "Global"; Key: "LanguageCode"; String: "ZH-CN"; Languages: chinesesimplified

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; WorkingDir: "{commonappdata}\{#MyAppName}"; Tasks: startmenu
Name: "{group}\{cm:ProgramOnTheWeb,{#MyAppName}}"; Filename: "{#MyAppURL}"; Tasks: startmenu
Name: "{group}\{cm:UninstallProgram,{#MyAppName}}"; Filename: "{uninstallexe}"; Tasks: startmenu

[Registry]
; --- SETUP KEYS ---
; APP PATH - setup regardless of SetupExplorerContextMenus()
Root: HKLM; Subkey: "SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\{#MyAppExeName}"; ValueType: string; ValueName: ""; ValueData: "{app}\{#MyAppExeName}"; Flags: uninsdeletekey
Root: HKLM; Subkey: "SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\{#MyAppExeName}"; ValueType: string; ValueName: "Path"; ValueData: "{app}"; Flags: uninsdeletekey

; DELETE Run (startup) value in current user (do not create but delete when uninstall)
Root: HKCU; Subkey: "Software\Microsoft\Windows\CurrentVersion\Run"; ValueType: none; ValueName: "{#MyAppName}"; Flags: dontcreatekey uninsdeletevalue
; DELETE Software key (including WorkingFolder value) in current user (do not create but delete when uninstall)
Root: HKCU; Subkey: "Software\Jean Lalonde\Quick Access Popup"; ValueType: none; Flags: dontcreatekey uninsdeletekey

; --- CONTEXTUAL MENUS KEYS ---
; ADD FILE - for remainig lines of the section setup only if SetupExplorerContextMenus()
Root: HKCR; Subkey: "*\shell\Add File to Quick Access Popup menu"; ValueType: string; ValueName: ""; ValueData: "Add File to Quick Access Popup menu"; Flags: uninsdeletekey; Check: SetupExplorerContextMenus()
Root: HKCR; Subkey: "*\shell\Add File to Quick Access Popup menu"; ValueType: string; ValueName: "Icon"; ValueData: """{app}\{#MyAppNameNoSpace}.ico"""; Check: SetupExplorerContextMenus()
Root: HKCR; Subkey: "*\shell\Add File to Quick Access Popup menu\command"; ValueType: string; ValueName: ""; ValueData: """{app}\QAPmessenger.exe"" AddFile ""%1"""; Check: SetupExplorerContextMenus()

; ADD FILE EXPRESS
Root: HKCR; Subkey: "*\shell\Add File to Quick Access Popup menu Express"; ValueType: string; ValueName: ""; ValueData: "Add File to Quick Access Popup menu Express"; Flags: uninsdeletekey; Check: SetupExplorerContextMenus()
Root: HKCR; Subkey: "*\shell\Add File to Quick Access Popup menu Express"; ValueType: string; ValueName: "Icon"; ValueData: """{app}\{#MyAppNameNoSpace}.ico"""; Check: SetupExplorerContextMenus()
Root: HKCR; Subkey: "*\shell\Add File to Quick Access Popup menu Express"; ValueType: string; ValueName: "Extended"; ValueData: ""; Check: SetupExplorerContextMenus()
Root: HKCR; Subkey: "*\shell\Add File to Quick Access Popup menu Express\command"; ValueType: string; ValueName: ""; ValueData: """{app}\QAPmessenger.exe"" AddFileXpress ""%1"""; Check: SetupExplorerContextMenus()

; ADD FOLDER
Root: HKCR; Subkey: "Folder\shell\Add Folder to Quick Access Popup menu"; ValueType: string; ValueName: ""; ValueData: "Add Folder to Quick Access Popup menu"; Flags: uninsdeletekey; Check: SetupExplorerContextMenus()
Root: HKCR; Subkey: "Folder\shell\Add Folder to Quick Access Popup menu"; ValueType: string; ValueName: "Icon"; ValueData: """{app}\{#MyAppNameNoSpace}.ico"""; Check: SetupExplorerContextMenus()
Root: HKCR; Subkey: "Folder\shell\Add Folder to Quick Access Popup menu\command"; ValueType: string; ValueName: ""; ValueData: """{app}\QAPmessenger.exe"" AddFolder ""%1"""; Check: SetupExplorerContextMenus()

; ADD FOLDER EXPRESS
Root: HKCR; Subkey: "Folder\shell\Add Folder to Quick Access Popup menu Express"; ValueType: string; ValueName: ""; ValueData: "Add Folder to Quick Access Popup menu Express"; Flags: uninsdeletekey; Check: SetupExplorerContextMenus()
Root: HKCR; Subkey: "Folder\shell\Add Folder to Quick Access Popup menu Express"; ValueType: string; ValueName: "Icon"; ValueData: """{app}\{#MyAppNameNoSpace}.ico"""; Check: SetupExplorerContextMenus()
Root: HKCR; Subkey: "Folder\shell\Add Folder to Quick Access Popup menu Express"; ValueType: string; ValueName: "Extended"; ValueData: ""; Check: SetupExplorerContextMenus()
Root: HKCR; Subkey: "Folder\shell\Add Folder to Quick Access Popup menu Express\command"; ValueType: string; ValueName: ""; ValueData: """{app}\QAPmessenger.exe"" AddFolderXpress ""%1"""; Check: SetupExplorerContextMenus()

; DESKTOP SHOW MENU 
Root: HKCR; Subkey: "DesktopBackground\shell\Show Quick Access Popup menu"; ValueType: string; ValueName: ""; ValueData: "Show Quick Access Popup menu"; Flags: uninsdeletekey; Check: SetupExplorerContextMenus()
Root: HKCR; Subkey: "DesktopBackground\shell\Show Quick Access Popup menu"; ValueType: string; ValueName: "Icon"; ValueData: """{app}\{#MyAppNameNoSpace}.ico"""; Check: SetupExplorerContextMenus()
Root: HKCR; Subkey: "DesktopBackground\shell\Show Quick Access Popup menu\command"; ValueType: string; ValueName: ""; ValueData: "{app}\QAPmessenger.exe ShowMenuLaunch"; Check: SetupExplorerContextMenus()

; DESKTOP SHOW ALTERNATIVE MENU
Root: HKCR; Subkey: "DesktopBackground\shell\Show Quick Access Popup Alternative menu"; ValueType: string; ValueName: ""; ValueData: "Show Quick Access Popup Alternative menu"; Flags: uninsdeletekey; Check: SetupExplorerContextMenus()
Root: HKCR; Subkey: "DesktopBackground\shell\Show Quick Access Popup Alternative menu"; ValueType: string; ValueName: "Icon"; ValueData: """{app}\{#MyAppNameNoSpace}.ico"""; Check: SetupExplorerContextMenus()
Root: HKCR; Subkey: "DesktopBackground\shell\Show Quick Access Popup Alternative menu"; ValueType: string; ValueName: "Extended"; ValueData: ""; Check: SetupExplorerContextMenus()
Root: HKCR; Subkey: "DesktopBackground\shell\Show Quick Access Popup Alternative menu\command"; ValueType: string; ValueName: ""; ValueData: """{app}\QAPmessenger.exe"" ShowMenuAlternative"; Check: SetupExplorerContextMenus()

; FOLDER BACKGROUND SHOW MENU
Root: HKCR; Subkey: "Directory\Background\shell\Show Quick Access Popup menu"; ValueType: string; ValueName: ""; ValueData: "Show Quick Access Popup menu"; Flags: uninsdeletekey; Check: SetupExplorerContextMenus()
Root: HKCR; Subkey: "Directory\Background\shell\Show Quick Access Popup menu"; ValueType: string; ValueName: "Icon"; ValueData: """{app}\{#MyAppNameNoSpace}.ico"""; Check: SetupExplorerContextMenus()
Root: HKCR; Subkey: "Directory\Background\shell\Show Quick Access Popup menu\command"; ValueType: string; ValueName: ""; ValueData: """{app}\QAPmessenger.exe"" ShowMenuNavigate"; Check: SetupExplorerContextMenus()

; FOLDER BACKGROUND SHOW ALTERNATIVE MENU
Root: HKCR; Subkey: "Directory\Background\shell\Show Quick Access Popup Alternative menu"; ValueType: string; ValueName: ""; ValueData: "Show Quick Access Popup Alternative menu"; Flags: uninsdeletekey; Check: SetupExplorerContextMenus()
Root: HKCR; Subkey: "Directory\Background\shell\Show Quick Access Popup Alternative menu"; ValueType: string; ValueName: "Icon"; ValueData: """{app}\{#MyAppNameNoSpace}.ico"""; Check: SetupExplorerContextMenus()
Root: HKCR; Subkey: "Directory\Background\shell\Show Quick Access Popup Alternative menu"; ValueType: string; ValueName: "Extended"; ValueData: ""; Check: SetupExplorerContextMenus()
Root: HKCR; Subkey: "Directory\Background\shell\Show Quick Access Popup Alternative menu\command"; ValueType: string; ValueName: ""; ValueData: """{app}\QAPmessenger.exe"" ShowMenuAlternative"; Check: SetupExplorerContextMenus()

; FOLDER BACKGROUND ADD FOLDER
Root: HKCR; Subkey: "Directory\Background\shell\Add Folder to Quick Access Popup menu"; ValueType: string; ValueName: ""; ValueData: "Add Folder to Quick Access Popup menu"; Flags: uninsdeletekey; Check: SetupExplorerContextMenus()
Root: HKCR; Subkey: "Directory\Background\shell\Add Folder to Quick Access Popup menu"; ValueType: string; ValueName: "Icon"; ValueData: """{app}\{#MyAppNameNoSpace}.ico"""; Check: SetupExplorerContextMenus()
Root: HKCR; Subkey: "Directory\Background\shell\Add Folder to Quick Access Popup menu\command"; ValueType: string; ValueName: ""; ValueData: """{app}\QAPmessenger.exe"" AddFolder ""%V"""; Check: SetupExplorerContextMenus()

; FOLDER BACKGROUND ADD FOLDER EXPRESS
Root: HKCR; Subkey: "Directory\Background\shell\Add Folder to Quick Access Popup menu Express"; ValueType: string; ValueName: ""; ValueData: "Add Folder to Quick Access Popup menu Express"; Flags: uninsdeletekey; Check: SetupExplorerContextMenus()
Root: HKCR; Subkey: "Directory\Background\shell\Add Folder to Quick Access Popup menu Express"; ValueType: string; ValueName: "Icon"; ValueData: """{app}\{#MyAppNameNoSpace}.ico"""; Check: SetupExplorerContextMenus()
Root: HKCR; Subkey: "Directory\Background\shell\Add Folder to Quick Access Popup menu Express"; ValueType: string; ValueName: "Extended"; ValueData: ""; Check: SetupExplorerContextMenus()
Root: HKCR; Subkey: "Directory\Background\shell\Add Folder to Quick Access Popup menu Express\command"; ValueType: string; ValueName: ""; ValueData: """{app}\QAPmessenger.exe"" AddFolderXpress ""%V"""; Check: SetupExplorerContextMenus()

; ADD SHORTCUT (Inno Setup does not create a key at HKEY_CLASSES_ROOT\lnkfile\... Must use HKLM\Software\Classes\...)
Root: HKLM; Subkey: "Software\Classes\lnkfile\shell\Import Shortcut to Quick Access Popup menu"; ValueType: string; ValueName: ""; ValueData: "Import Shortcut to Quick Access Popup menu"; Flags: uninsdeletekey; Check: SetupExplorerContextMenus()
Root: HKLM; Subkey: "Software\Classes\lnkfile\shell\Import Shortcut to Quick Access Popup menu"; ValueType: string; ValueName: ""; ValueData: "Import Shortcut to Quick Access Popup menu"; Flags: uninsdeletekey; Check: SetupExplorerContextMenus()
Root: HKLM; Subkey: "Software\Classes\lnkfile\shell\Import Shortcut to Quick Access Popup menu"; ValueType: string; ValueName: "Icon"; ValueData: """{app}\{#MyAppNameNoSpace}.ico"""; Check: SetupExplorerContextMenus()
Root: HKLM; Subkey: "Software\Classes\lnkfile\shell\Import Shortcut to Quick Access Popup menu\command"; ValueType: string; ValueName: ""; ValueData: """{app}\QAPmessenger.exe"" AddShortcut ""%1"""; Check: SetupExplorerContextMenus()

[Run]
Filename: "{app}\{#MyAppExeName}"; WorkingDir: "{commonappdata}\{#MyAppName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: waituntilidle postinstall skipifsilent
Filename: "https://www.paypal.com/donate?hosted_button_id=MKS3LBZSUGT6N"; Description: "{cm:HelpMePayExpenses} {cm:PaypalCredit}"; Flags: postinstall shellexec unchecked

[Tasks]
Name: startmenu; Description: "Create a Start Menu folder";

[UninstallDelete]
Type: files; Name: "{userstartup}\{#MyAppNameLower}.lnk"

[Code]
function ShouldSkipPage(PageID: Integer): Boolean;
begin
  // if the page that is asked to be skipped is the licence page, then...
  if (PageID = wpLicense) or (PageID = wpSelectTasks) then
  begin
    // if the app was already installed, skip the page
    Result := (Length(WizardForm.PrevAppDir) > 0);
  end
  else
  begin
    // do not skip other pages (not necessary, but safer)
    Result := False;
  end;
end;

function IsProcessRunning(FileName: String): Boolean;
var
  objSWbemLocator, objSWbemServices: Variant;
begin
  try
    objSWbemLocator := CreateOleObject('WbemScripting.SWbemLocator');
  except
    ShowExceptionMessage;
    Exit;
  end;
  objSWbemServices := objSWbemLocator.ConnectServer();
  objSWbemServices.Security_.ImpersonationLevel := 3;
  Result := (objSWbemServices.ExecQuery('SELECT * FROM Win32_Process WHERE Name="' + FileName + '"').Count > 0);
end;

function InitializeUninstall(): Boolean;
var
  ResultCode: Integer;
begin
  Result := True;
  while IsProcessRunning('{#MyAppExeName}') do begin
    case MsgBox('{#MyAppName} must be closed before uninstall'+#13#13+'Press OK to close it automatically or CANCEL to close it manually.', mbError, MB_OKCANCEL) of
      IDCANCEL:
      begin
        Result := False;
        Break;
      end;
      IDOK:
      begin
        Exec(ExpandConstant('{sys}\taskkill.exe'), '/im "{#MyAppExeName}" /f', '', SW_HIDE, ewWaitUntilTerminated, ResultCode); 
        if ResultCode = 0 then
        begin
          Result := True;
        end
        else
        begin
          Result := False;
          MsgBox('An error occurred while closing {#MyAppExeName} process.', mbError, MB_OK);
        end;
      end;
    end;
  end;
end;

function SetupExplorerContextMenus(): Boolean;
var
  WorkingFolder: String;
begin
  // function RegQueryStringValue(const RootKey: Integer; const SubKeyName, ValueName: String; var ResultStr: String): Boolean;
  if RegQueryStringValue(HKEY_CURRENT_USER, 'Software\Jean Lalonde\{#MyAppName}', 'WorkingFolder', WorkingFolder) then
  begin
  // function GetIniString(const Section, Key, Default, Filename: String): String;
  // setup Explorer context menus if ExplorerContextMenus is 1 (or is not found) for both quickaccesspopup.ini file in current Settings Folder and in commonappdata
  // (in other words, do not setup context menus if either of these files include ExplorerContextMenus with value "0")
    Result := (GetIniString('Global', 'ExplorerContextMenus', '1', AddBackslash(WorkingFolder) + '{#MyAppNameNoSpace}.ini') = '1') and (GetIniString('Global', 'ExplorerContextMenus', '1', ExpandConstant('{commonappdata}\{#MyAppName}\{#MyAppNameNoSpace}.ini')) = '1')
  end
  else
  begin
    // WorkingFolder not found, this is a first installation, task enabled
    Result := True;
  end;
end;

function ExecuteSponsoringTask(): Boolean;
var
  WorkingFolder: String;
  Donor: String;
  DonorCode: String;
begin
  // function RegQueryStringValue(const RootKey: Integer; const SubKeyName, ValueName: String; var ResultStr: String): Boolean;
  if RegQueryStringValue(HKEY_CURRENT_USER, 'Software\Jean Lalonde\{#MyAppName}', 'WorkingFolder', WorkingFolder) then
  begin
    // WorkingFolder key found, user is upgrading
    // function GetIniString(const Section, Key, Default, Filename: String): String;
    Donor := GetIniString('Global', 'Donor', 'ERROR', AddBackslash(WorkingFolder) + '{#MyAppNameNoSpace}.ini')
    DonorCode := GetIniString('Global', 'DonorCode', 'ERROR', AddBackslash(WorkingFolder) + '{#MyAppNameNoSpace}.ini')
    // MsgBox('WorkingFolder: ' + WorkingFolder + ' / Donor: ' + Donor + ' / DonorCode: ' + DonorCode, mbInformation, MB_OK)
    if (Donor <> 'ERROR') or (DonorCode <> 'ERROR') then
    begin
      // user is a sponsor, task disabled
      Result := False;
    end
    else
    begin
      // user is not a sponsor, task enabled
      Result := True;
     end
  end
  else
  begin
    // WorkingFolder not found, this is a first installation, task disabled
    Result := False;
  end;
end;

function NotExecuteSponsoringTask(): Boolean;
begin
  Result := Not ExecuteSponsoringTask();
end;
