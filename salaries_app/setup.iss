[Setup]
AppName=Mini Mercado - Balance Closing System
AppVersion=2.1.0
AppPublisher=Mini Mercado
AppPublisherURL=https://minimercado.com
AppSupportURL=https://minimercado.com/support
AppUpdatesURL=https://minimercado.com/updates
DefaultDirName={autopf}\Mini Mercado\Balance Closing System
DefaultGroupName=Mini Mercado
AllowNoIcons=yes
LicenseFile=
InfoBeforeFile=
InfoAfterFile=
OutputDir=installer
OutputBaseFilename=MiniMercadoBalanceSetup
SetupIconFile=windows\runner\resources\app_icon.ico
Compression=lzma
SolidCompression=yes
WizardStyle=modern
PrivilegesRequired=lowest
ArchitecturesAllowed=x64
ArchitecturesInstallIn64BitMode=x64

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "build\windows\x64\runner\Release\data\*"; DestDir: "{app}\data"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\Mini Mercado - Balance Closing System"; Filename: "{app}\salaries_app.exe"
Name: "{group}\{cm:UninstallProgram,Mini Mercado - Balance Closing System}"; Filename: "{uninstallexe}"
Name: "{autodesktop}\Mini Mercado - Balance Closing System"; Filename: "{app}\salaries_app.exe"; Tasks: desktopicon

[Run]
Filename: "{app}\salaries_app.exe"; Description: "{cm:LaunchProgram,Mini Mercado - Balance Closing System}"; Flags: nowait postinstall skipifsilent

[Code]
function InitializeSetup(): Boolean;
begin
  Result := True;
end;
