[Setup]
AppName=Salaries App
AppVersion=1.0.0
DefaultDirName={autopf64}\\Salaries App
DefaultGroupName=Salaries App
UninstallDisplayIcon={app}\\salaries_app.exe
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
OutputDir=installer

[Files]
Source: "build\\windows\\x64\\runner\\Release\\*"; DestDir: "{app}"; Flags: recursesubdirs

[Icons]
Name: "{group}\\Salaries App"; Filename: "{app}\\salaries_app.exe"
Name: "{autodesktop}\\Salaries App"; Filename: "{app}\\salaries_app.exe"; Tasks: desktopicon

[Run]
Filename: "{app}\\salaries_app.exe"; Description: "Launch application"; Flags: nowait postinstall skipifsilent

[Tasks]
Name: "desktopicon"; Description: "Create a desktop icon"; GroupDescription: "Additional tasks:";
