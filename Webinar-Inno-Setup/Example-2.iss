; -- Example1.iss --

; SEE THE DOCUMENTATION FOR DETAILS ON CREATING .ISS SCRIPT FILES!

#define MyDistributionFiles "O:\Temp\Webinar-Inno Setup\Distribution files"
#define MyBuildDir "O:\Temp\Webinar-Inno Setup\Build"
#define MyAppName "My Program"
#define MyAppVersion "v1.2.3"
; #define MyAppVersion GetEnv('APPVERSIONTEXT')
#define MyAppVersionFileName "1_2_3"
; #define MyAppVersionFileName GetEnv('APPVERSIONFILE')
#define MyAppURL "https://the-automator.com"
#define MyAppExeName "My Program.exe"

[Setup]
AppName={#MyAppName}
AppVersion={#MyAppVersion} 
AppVerName={#MyAppName} {#MyAppVersion}
AppPublisherURL={#MyAppURL}
DefaultDirName={autopf}\My Program
DefaultGroupName=My Program
OutputDir={#MyBuildDir}
OutputBaseFilename={#MyAppName}-{#MyAppVersionFileName}-setup
SetupIconFile={#MyDistributionFiles}\{#MyAppName}.ico
LicenseFile={#MyDistributionFiles}\License.txt
Compression=lzma
SolidCompression=yes

[Files]
Source: "{#MyDistributionFiles}\My Program.exe"; DestDir: "{app}"
Source: "{#MyDistributionFiles}\Readme.txt"; DestDir: "{app}"; Flags: isreadme

[Tasks]
Name: startmenu; Description: "Create a Start Menu folder";

[Icons]
Name: "{group}\My Program"; Filename: "{app}\My Program-2.exe"
Name: "{group}\{cm:ProgramOnTheWeb,{#MyAppName}}"; Filename: "{#MyAppURL}"; Tasks: startmenu
Name: "{group}\{cm:UninstallProgram,{#MyAppName}}"; Filename: "{uninstallexe}"; Tasks: startmenu

[Dirs]
; folder under "My Documents"
Name: "{commonappdata}\{#MyAppName}" 

[INI]
Filename: "{commonappdata}\{#MyAppName}\{#MyAppName}.ini"; Section: "Global"; Key: "LanguageCode"; String: "EN"; Languages: english
Filename: "{commonappdata}\{#MyAppName}\{#MyAppName}.ini"; Section: "Global"; Key: "LanguageCode"; String: "FR"; Languages: french
Filename: "{commonappdata}\{#MyAppName}\{#MyAppName}.ini"; Section: "Global"; Key: "LanguageCode"; String: "ES"; Languages: spanish

[Run]
Filename: "{app}\{#MyAppExeName}"; WorkingDir: "{commonappdata}\{#MyAppName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: waituntilidle postinstall skipifsilent
Filename: "https://www.paypal.com/donate?hosted_button_id=MKS3LBZSUGT6N"; Description: "{cm:HelpMePayExpenses} {cm:PaypalCredit}"; Flags: postinstall shellexec unchecked

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"
Name: "french"; MessagesFile: "compiler:Languages\French.isl"
Name: "spanish"; MessagesFile: "compiler:Languages\Spanish.isl"

[CustomMessages]
; Example
; VariableName=Text
; Filename: "https://www.quickaccesspopup.com/example/"; Description: "{cm:VariableName}"; Flags: postinstall shellexec unchecked
HelpMePayExpenses=&HELP me pay EXPENSES for making this app
french.HelpMePayExpenses=&Aidez-moi à payer mes frais
spanish.HelpMePayExpenses=&Ayúdame a pagar mis gastos
PaypalCredit=(Paypal or credit cards)
french.PaypalCredit=(Paypal ou cartes de crédit)
french.PaypalCredit=(Paypal o tarjetas de crédito)
