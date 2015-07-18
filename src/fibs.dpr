{*******************************************************}
{                                                       }
{       FIBS Firebird-Interbase Backup Scheduler        }
{                                                       }
{       Copyright (c) 2005-2006, Talat Dogan            }
{                                                       }
{*******************************************************}

program fibs;

uses
  ExceptionLog,
  windows,
  messages,
  SysUtils,
  Forms,
  Dialogs,
  WinSvc,
  MainUnit in 'MainUnit.pas' {MainForm},
  PrefUnit in 'PrefUnit.pas' {PrefForm},
  ConstUnit in 'ConstUnit.pas',
  DModuleUnit in 'DModuleUnit.pas' {DModule: TDataModule},
  EditTaskUnit in 'EditTaskUnit.pas' {EditTaskForm},
  uTBase64 in 'UTBASE64.PAS',
  PresetsUnit in 'PresetsUnit.pas',
  MesajUnit in 'MesajUnit.pas' {MesajForm},
  BackupUnit in 'BackupUnit.pas',
  ManualBackupUnit in 'ManualBackupUnit.pas' {ManualBackupForm},
  FunctionsUnit in 'FunctionsUnit.pas',
  PlanListUnit in 'PlanListUnit.pas' {PlanListForm},
  AboutUnit in 'AboutUnit.pas' {AboutForm},
  LogUnit in 'LogUnit.pas' {LogForm},
  YesNoUnit in 'YesNoUnit.pas' {YesNoForm},
  RetMonitorTools in 'RetMonitorTools.pas',
  BackupServiceUnit in 'BackupServiceUnit.pas',
  ServiceUtilsUnit in 'ServiceUtilsUnit.pas',
  smtpsend in 'Synapse\smtpsend.pas',
  PortUnit in 'PortUnit.pas',
  EditBtn in '..\components\EditBtb-DBEditBtn_v1.1_Revised\EditBtn.pas',
  EmailUnit in 'EmailUnit.pas';

{$R *.RES}

begin
  // Check if FIBS is running as a servic.e
  if ServiceRunning(nil, 'FIBSBackupService') then
  begin
    MesajDlg('FIBS is still running as a service !!!', 'c', PrgName);
    exit;
  end;
  // FIBS is not running as a service.
  // Check if FIBS is running as an application.
  if AlreadyRun then
  begin
    MesajDlg('FIBS is still running as a desktop Application !!!', 'c', PrgName);
    exit;
  end;
  // FIBS is not running as a service nor an application.
  // Check if FIBS is installed as a service.
  if BackupStartService('FIBSBackupService') then
  begin
    // FIBS is installed as a service.
    // Check Datafiles are exist.
    if DataFilesExists then
    begin
      BackupService.SetTitle('FIBS');
      RunningAsService := true;
      BackupService.CreateForm(TMainForm, MainForm);
      // Check Datafiles are not corrupt nor old version.
      if DataFilesInvalid then
      begin
        DModule.Free;
        MainForm.Free;
        MesajDlg('ERROR !!' + 'prefs.dat or tasks.dat is not exists or corrupt or old version!!'#13#10'FIBS cannot start !!!', 'c', PrgName);
        PostThreadMessage(BackupService.ServiceThread.ThreadID, WM_QUIT, 0, 0);
        exit;
      end;
      SetCurrentDir(ExtractFileDir(ServiceExeName));
      // Create MainForm
      BackupService.CreateForm(TEditTaskForm, EditTaskForm);
      BackupService.Run;
    end;
    exit;
  end;
  // FIBS is not installed as a service.
  // Check again if FIBS is running as an application.
  if AlreadyRun = false then
  begin
    // FIBS is not running as an application.
    // Run it as an application.
    Application.Title := 'FIBS';
    Application.HelpFile := 'fibs.hlp';
    Application.Initialize;
    // Check Datafiles are exist.
    if DataFilesExists then
    begin
      RunningAsService := false;
      Application.CreateForm(TMainForm, MainForm);
  // Check Datafiles are not corrupt nor old version.
      if DataFilesInvalid then
      begin
        DModule.Free;
        MainForm.Free;
        MesajDlg('ERROR !!'#13#10 + 'prefs.dat and/or tasks.dat is/are not exist, old version or corrupt !!'#13#10'FIBS cannot start !!!', 'c', PrgName);
        Application.Terminate;
        exit;
      end;
      SetCurrentDir(ExtractFileDir(Application.ExeName)); //Beta-13
      Application.CreateForm(TEditTaskForm, EditTaskForm);
      Application.Run;
    end;
  end
  else
    MesajDlg('FIBS Firebird-Interbase Backup Scheduler can run only one instance !!!', 'c', PrgName);
end.

