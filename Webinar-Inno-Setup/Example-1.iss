; -- Example1.iss --

; SEE THE DOCUMENTATION FOR DETAILS ON CREATING .ISS SCRIPT FILES!

#define MyDistributionFiles "O:\Temp\Webinar-Inno Setup\Distribution files"
#define MyBuildDir "O:\Temp\Webinar-Inno Setup\Build"

[Setup]
AppName=My Program
AppVersion=1.5
DefaultDirName={autopf}\My Program
DefaultGroupName=My Program
OutputDir={#MyBuildDir}

[Files]
Source: "{#MyDistributionFiles}\My Program.exe"; DestDir: "{app}"
Source: "{#MyDistributionFiles}\Readme.txt"; DestDir: "{app}"; Flags: isreadme

[Icons]
Name: "{group}\My Program"; Filename: "{app}\My Program.exe"
