
{****************************************************************************}
{                                                                            }
{               FIBS Firebird-Interbase Backup Scheduler                     }
{                                                                            }
{                 Copyright (c) 2005-2006, Talat Dogan                       }
{                                                                            }
{ This program is free software; you can redistribute it and/or modify it    }
{ under the terms of the GNU General Public License as published by the Free }
{ Software Foundation; either version 2 of the License, or (at your option)  }
{ any later version.                                                         }
{                                                                            }
{ This program is distributed in the hope that it will be useful, but        }
{ WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY }
{ or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for}
{ more details.                                                              }
{                                                                            }
{ You should have received a copy of the GNU General Public License along    }
{ with this program; if not, write to the Free Software Foundation, Inc.,    }
{ 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA                      }
{                                                                            }
{ Contact : dogantalat@yahoo.com
{                                                                            }
{****************************************************************************}

unit FibsForm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Mask, Buttons, ActiveX, ShellApi, Menus, ExtCtrls, Grids, DBGrids,
  DBCtrls, ThdTimer, FibsData, JvComponentBase, JvTrayIcon, JvThreadTimer;

const
  WM_ICONTRAY = WM_USER + 1; // User-defined message

type

  TfmFibs = class(TForm)
    mmMenu: TMainMenu;
    MenuPrefs: TMenuItem;
    ButtonPanel: TPanel;
    ButtonLogs: TSpeedButton;
    ButtonQuit: TSpeedButton;
    ButtonEditTask: TSpeedButton;
    StatPanel: TPanel;
    LabelPanel: TPanel;
    MenuTask: TMenuItem;
    MenuNew: TMenuItem;
    MenuEditTask: TMenuItem;
    TaskGrid: TDBGrid;
    MenuActivate: TMenuItem;
    N1: TMenuItem;
    MenuDeactivate: TMenuItem;
    N2: TMenuItem;
    MenuExit: TMenuItem;
    MenuHelp: TMenuItem;
    MenuAbout: TMenuItem;
    LabelClock: TLabel;
    ButtonBackupNow: TSpeedButton;
    LabelAllTaskCompleted: TLabel;
    LabelNextBackup: TLabel;
    Label5: TLabel;
    N3: TMenuItem;
    MenuDelete: TMenuItem;
    N4: TMenuItem;
    MenuPlan: TMenuItem;
    MenuTimeSettings: TMenuItem;
    ButtonPlan: TSpeedButton;
    MenuLog: TMenuItem;
    N6: TMenuItem;
    MenuActivateAll: TMenuItem;
    MenuDeactivateAll: TMenuItem;
    MenuBackupNow: TMenuItem;
    N7: TMenuItem;
    pmTray: TPopupMenu;
    miTrayShow: TMenuItem;
    miTrayExit: TMenuItem;
    N8: TMenuItem;
    miTrayHide: TMenuItem;
    MenuView: TMenuItem;
    MenuHelpHelp: TMenuItem;
    N5: TMenuItem;
    miTrayStopService: TMenuItem;
    Label2: TLabel;
    ButtonPrefs: TSpeedButton;
    pmTask: TPopupMenu;
    miTaskDuplicate: TMenuItem;
    tiTray: TJvTrayIcon;
    ttTimer: TJvThreadTimer;
    miTaskEdit: TMenuItem;
    miTaskBackup: TMenuItem;
    procedure MenuPrefsClick(Sender: TObject);
    procedure MenuEditTaskClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure MenuNewClick(Sender: TObject);
    procedure MenuExitClick(Sender: TObject);
    procedure MenuActivateClick(Sender: TObject);
    procedure MenuDeactivateClick(Sender: TObject);
    procedure TaskGridDrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
    procedure MenuTaskClick(Sender: TObject);
    procedure MenuDeleteClick(Sender: TObject);
    procedure TaskGridKeyPress(Sender: TObject; var Key: Char);
    procedure MenuPlanClick(Sender: TObject);
    procedure MenuAboutClick(Sender: TObject);
    procedure MenuTimeSettingsClick(Sender: TObject);
    procedure MenuLogClick(Sender: TObject);
    procedure MenuActivateAllClick(Sender: TObject);
    procedure MenuDeactivateAllClick(Sender: TObject);
    procedure MenuBackupNowClick(Sender: TObject);
    procedure miTrayShowClick(Sender: TObject);
    procedure miTrayHideClick(Sender: TObject);
    procedure MenuViewClick(Sender: TObject);
    procedure MenuHelpHelpClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure miTrayStopServiceClick(Sender: TObject);
    procedure pmTrayPopup(Sender: TObject);
    procedure miTaskDuplicateClick(Sender: TObject);
    procedure pmTaskPopup(Sender: TObject);
    procedure tiTrayDblClick(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ttTimerTimer(Sender: TObject);
    procedure miTaskEditClick(Sender: TObject);
    procedure miTaskBackupClick(Sender: TObject);
  private
    procedure InitAlarms;
    procedure SetAlarms;
    procedure DeleteAlarmsFromTimeList;
    procedure BackUpDatabase(ARecNo: string; AAlarmDateTime: TDateTime);
    procedure ManualBackUp(AAlarmDateTime: TDateTime; TaskName, GBakPath, UserName, Password, FullDBPath, BUPath, MirrorPath, Mirror2Path, Mirror3Path, ACompDegree: string; ADoZip, ADoValidate: Boolean);
    procedure GetAlarmTimeList(T: string);
    procedure DeleteCurrentTaskFromTimeList;
    procedure DeactivateAll;
    procedure ActivateAll;
    procedure ActivateOne;
    procedure ActivateAllLeavedActive;
    procedure SetResetAutoRun;
    procedure SetApplicationPriorty;
  public
  end;

var
  fmFibs: TfmFibs;

implementation

uses Registry, Variants, StrUtils, PrefUnit, EditTaskUnit, ConstUnit, BackupUnit,
  MesajUnit, ManualBackupUnit, FunctionsUnit, PlanListUnit,
  AboutUnit, LogUnit, PresetsUnit, DateUtils,
  RetMonitorTools, BackupServiceUnit, DB, DCPbase64;

{$R *.DFM}

procedure TfmFibs.SetResetAutoRun;
var
  rgReg: TRegistry;
  AKey: string;
begin
  AKey := 'FIBS_Backup_Scheduler';
  rgReg := TRegistry.Create;
  try
    rgReg.RootKey := HKEY_LOCAL_MACHINE;
    if rgReg.OpenKey('\Software\Microsoft\Windows\CurrentVersion\Run', False) then
    begin
      if dmFibs.qrOptionAUTORUN.Value = '1' then
        rgReg.WriteString(AKey, ParamStr(0))
      else
        rgReg.DeleteValue(AKey);
    end;
  finally
    rgReg.Free;
  end;
end;

procedure TfmFibs.SetApplicationPriorty;
var
  cpProcess: THandle;
  iPriority: Integer;
  sPriority: string;
begin
  cpProcess := Windows.GetCurrentProcess;
  iPriority := THREAD_PRIORITY_NORMAL;
  sPriority := dmFibs.qrOptionBPRIORTY.Value;
  if sPriority = 'Idle' then
    iPriority := Windows.THREAD_PRIORITY_IDLE
  else
    if sPriority = 'Lowest' then
      iPriority := Windows.THREAD_PRIORITY_LOWEST
    else
      if sPriority = 'Lower' then
        iPriority := Windows.THREAD_PRIORITY_BELOW_NORMAL
      else
        if sPriority = 'Normal' then
          iPriority := Windows.THREAD_PRIORITY_NORMAL
        else
          if sPriority = 'Higher' then
            iPriority := Windows.THREAD_PRIORITY_ABOVE_NORMAL
          else
            if sPriority = 'Highest' then
              iPriority := Windows.THREAD_PRIORITY_HIGHEST;
  Windows.SetThreadPriority(cpProcess, iPriority);
end;

procedure TfmFibs.MenuPrefsClick(Sender: TObject);
begin
  PrefForm := TPrefForm.Create(Self);
  try
    PrefForm.DirectoryEdit1.Text := dmFibs.qrOptionPATHTOGBAK.Value;
    PrefForm.DirectoryLogDir.Text := dmFibs.qrOptionLOGDIR.Value;
    PrefForm.DirectoryArchiveDir.Text := dmFibs.qrOptionARCHIVEDIR.Value;
    PrefForm.EditSMTPServer.Text := dmFibs.qrOptionSMTPSERVER.Value;
    PrefForm.EditMailAdress.Text := dmFibs.qrOptionSENDERSMAIL.Value;
    PrefForm.EditUserName.Text := dmFibs.qrOptionMAILUSERNAME.Value;
    PrefForm.EditPassword.Text := DCPbase64.Base64DecodeStr(dmFibs.qrOptionMAILPASSWORD.AsString);
    if PrefForm.ShowModal = mrOk then
    begin
      dmFibs.qrOption.Edit;
      SetResetAutoRun;
      dmFibs.qrOptionPATHTOGBAK.Value := PrefForm.DirectoryEdit1.Text;
      dmFibs.qrOptionLOGDIR.Value := PrefForm.DirectoryLogDir.Text;
      dmFibs.qrOptionARCHIVEDIR.Value := PrefForm.DirectoryArchiveDir.Text;
      dmFibs.qrOptionSMTPSERVER.Value := PrefForm.EditSMTPServer.Text;
      dmFibs.qrOptionSENDERSMAIL.Value := PrefForm.EditMailAdress.Text;
      dmFibs.qrOptionMAILUSERNAME.Value := PrefForm.EditUserName.Text;
      dmFibs.qrOptionMAILPASSWORD.Value := DCPbase64.Base64EncodeStr(PrefForm.EditPassword.Text);
      dmFibs.qrOption.Post;
    end;
  finally
    PrefForm.Free;
  end;
end;

procedure TfmFibs.MenuEditTaskClick(Sender: TObject);
var
  i: Integer;
  s, T: string; //Saat, Dakika Checklist stringi
begin
  if dmFibs.qrTask.RecordCount > 0 then
  begin
    EditTaskForm.caption := ' Edit Backup Task';
    EditTaskForm.EditDatabaseName.Text := dmFibs.qrTaskDBNAME.Value;
    EditTaskForm.EditDestinationDir.Text := dmFibs.qrTaskBACKUPDIR.Value;
    EditTaskForm.EditMirrorDir.Text := dmFibs.qrTaskMIRRORDIR.Value;
    EditTaskForm.EditMirror2Dir.Text := dmFibs.qrTaskMIRROR2DIR.Value;
    EditTaskForm.EditMirror3Dir.Text := dmFibs.qrTaskMIRROR3DIR.Value;
    EditTaskForm.LabelState.Visible := dmFibs.qrTaskACTIVE.AsInteger = 1;
    EditTaskForm.FileEditBtnBatchFile.Text := dmFibs.qrTaskBATCHFILE.Value;

    EditTaskForm.EditDatabaseName.Button.Enabled := dmFibs.qrTaskLOCALCONN.AsBoolean = True;

    T := dmFibs.qrTaskBOXES.Value;
    for i := 1 to 24 do
      if (T[i] = '1') then
        EditTaskForm.CGHours.State[i - 1] := cbChecked
      else
        EditTaskForm.CGHours.State[i - 1] := cbUnChecked;
    for i := 25 to 84 do
      if (T[i] = '1') then
        EditTaskForm.CGMinutes.State[i - 25] := cbChecked
      else
        EditTaskForm.CGMinutes.State[i - 25] := cbUnChecked;
    s := dmFibs.qrTaskBOPTIONS.Value;
    for i := 0 to TotalGBakOptions - 1 do
      if (s[i + 1] = '1') then
        EditTaskForm.CLBGbakOptions.State[i] := cbChecked
      else
        EditTaskForm.CLBGbakOptions.State[i] := cbUnChecked;

    EditTaskForm.ButtonOK.Enabled := (dmFibs.qrTaskACTIVE.AsInteger = 0);
    if EditTaskForm.ShowModal = mrOk then
    begin
      dmFibs.qrTask.Edit;
      dmFibs.qrTaskDBNAME.Value := EditTaskForm.EditDatabaseName.Text;
      dmFibs.qrTaskBACKUPDIR.Value := EditTaskForm.EditDestinationDir.Text;
      dmFibs.qrTaskMIRRORDIR.Value := EditTaskForm.EditMirrorDir.Text;
      dmFibs.qrTaskMIRROR2DIR.Value := EditTaskForm.EditMirror2Dir.Text;
      dmFibs.qrTaskMIRROR3DIR.Value := EditTaskForm.EditMirror3Dir.Text;
      dmFibs.qrTaskBATCHFILE.Value := EditTaskForm.FileEditBtnBatchFile.Text;

      //Let's set Time CheckList..
      T := '';
      for i := 1 to 24 do
        if EditTaskForm.CGHours.State[i - 1] = cbChecked then
          T := T + '1'
        else
          T := T + '0';
      for i := 25 to 84 do
        if EditTaskForm.CGMinutes.State[i - 25] = cbChecked then
          T := T + '1'
        else
          T := T + '0';
      dmFibs.qrTaskBOXES.Value := T;
      s := '';
      for i := 0 to TotalGBakOptions - 1 do
        if EditTaskForm.CLBGbakOptions.State[i] = cbChecked then
          s := s + '1'
        else
          s := s + '0';
      dmFibs.qrTaskBOPTIONS.Value := s;

      dmFibs.qrTask.Post;

      DeleteCurrentTaskFromTimeList;

      GetAlarmTimeList(T);
      PreservedInHour := AlarmInHour;
      PreservedInDay := AlarmInDay;
      PreservedInMonth := AlarmInDay * AlarmInMonth;

      if dmFibs.qrTaskACTIVE.AsInteger = 1 then
      begin
        for i := 0 to AlarmTimeList.Count - 1 do
          TimeList.Add(AlarmTimeList.Strings[i]);
        InitAlarms;
      end;
    end
    else
      dmFibs.qrTask.Cancel;
  end
  else
    MessageDlg('No Task to Edit!', mtError, [mbOk], 0);
end;

procedure TfmFibs.DeleteCurrentTaskFromTimeList;
var
  X, Y: string;
  i, L, StartPos, ALen: Integer;
begin
  if TimeList.Count > 0 then
  begin
    Y := dmFibs.qrTaskTASKNO.AsString;
    for i := TimeList.Count - 1 downto 0 do
    begin
      StartPos := Pos(' - ', TimeList.Strings[i]) + 3;
      X := TimeList[i];
      L := Pos(' + ', TimeList.Strings[i]);
      ALen := L - StartPos;
      X := copy(TimeList.Strings[i], StartPos, ALen);
      if X = Y then
        TimeList.Delete(i);
    end;
  end;
end;

procedure TfmFibs.GetAlarmTimeList(T: string);
var
  PDot, h, minu: Integer;
  //  MaxDay :integer;
  AYear, AMonth, ADay, AMinute, ASecond, AMilliSecond: Word;
  AlarmDateTimeStr: string;
  AlarmDateTime: TDateTime;
begin
  AMinute := 0;
  ASecond := 0;
  AMilliSecond := 0;
  AlarmInHour := 0;
  AlarmInDay := 0;
  AlarmInMonth := 0;
  AlarmTimeList.Clear;
  DecodeDate(Date, AYear, AMonth, ADay);
  //  MaxDay:=DaysInAMonth(AYear,AMonth);
  for h := 0 to 23 do
  begin
    if T[h + 1] = '1' then
    begin
      inc(AlarmInDay);
      for minu := 0 to 59 do
      begin
        if T[minu + 25] = '1' then
        begin
          inc(AlarmInHour);
          AlarmDateTime := EncodeDateTime(AYear, AMonth, ADay, h, minu, ASecond, AMilliSecond);
          AlarmDateTimeStr := '000' + FloatToStr(AlarmDateTime - StartOfTheDay(AlarmDateTime));
          PDot := Pos(DecimalSeparator, AlarmDateTimeStr);
          if (PDot > 0) then
            Delete(AlarmDateTimeStr, 1, PDot - 4)
          else
            AlarmDateTimeStr := RightStr(AlarmDateTimeStr, 3);
          AlarmTimeList.Add(AlarmDateTimeStr + ' - ' + dmFibs.qrTaskTASKNO.AsString + ' + ' + dmFibs.qrTaskTASKNAME.AsString);
        end;
      end;
    end;
  end;
end;

procedure TfmFibs.FormCreate(Sender: TObject);
begin
  Application.CreateForm(TdmFibs, dmFibs);
  Self.SetApplicationPriorty;
  if DataFilesInvalid then
    Exit;
  Windows.SetThreadLocale(LOCALE_SYSTEM_DEFAULT);
  SysUtils.GetFormatSettings;
  Application.UpdateFormatSettings := False;
  ConstUnit.SyncLog := TMultiReadExclusiveWriteSynchronizer.Create;
  ConstUnit.AlarmTimeList := TStringList.Create;
  ConstUnit.AlarmTimeList.Sorted := True;
  ConstUnit.TimeList := TStringList.Create;
  ConstUnit.TimeList.Sorted := True;
  Self.ttTimer.Enabled := True;
  Self.caption := 'FIBS  ' + PrgInfo + ' Ver. ' + ReleaseInfo;
  Self.ActivateAllLeavedActive;
  // Hide process messages when FIBS is minimised.
  if BackupIsService then
  begin
    Self.Hide;
    ConstUnit.MainFormHidden := True;
  end
  else
  begin
    Application.ShowMainForm := False;
    ConstUnit.MainFormHidden := True;
  end;
  if ConstUnit.RunningAsService then
    Self.tiTray.Hint := ConstUnit.PrgName + ' is running As a Service.'
  else
    Self.tiTray.Hint := ConstUnit.PrgName + ' is running As a Application.';
  Self.tiTray.Active := True;
  Self.tiTray.HideApplication;
end;

procedure TfmFibs.FormDestroy(Sender: TObject);
begin
  ConstUnit.AlarmTimeList.Free;
  ConstUnit.TimeList.Free;
  ConstUnit.SyncLog.Free;
end;

procedure TfmFibs.MenuNewClick(Sender: TObject);
var
  i: Integer;
  s: string;
  bul: Boolean;
  TN: string;
begin
  dmFibs.qrTask.DisableControls;
  try
    TN := dmFibs.qrTaskTASKNO.Value;
    dmFibs.qrTask.First;
    bul := dmFibs.qrTask.Locate('ACTIVE', 1, []);
    dmFibs.qrTask.First;
    dmFibs.qrTask.Locate('TASKNO', TN, []);
  finally
    dmFibs.qrTask.EnableControls;
  end;
  if bul then
  begin
    MessageDlg('You MUST DEACTIVE all active Tasks before adding a new Task!', mtError, [mbOk], 0);
    Exit;
  end;
  dmFibs.qrTask.Append;
  EditTaskForm.caption := ' New Backup Task';
  EditTaskForm.EditDatabaseName.Text := '';
  EditTaskForm.EditDestinationDir.Text := '';
  EditTaskForm.EditMirrorDir.Text := '';
  EditTaskForm.EditMirror2Dir.Text := '';
  EditTaskForm.EditMirror3Dir.Text := '';
  EditTaskForm.LabelState.Visible := False;
  AlarmTimeList.Text := '';
  dmFibs.qrTaskDOVAL.Value := 'False';
  dmFibs.qrTaskMAILTO.Value := '';
  dmFibs.qrTaskSHOWBATCHWIN.Value := 'False';
  dmFibs.qrTaskUSEPARAMS.Value := 'False';

  dmFibs.qrTaskLOCALCONN.Value := 'True';
  dmFibs.qrTaskACTIVE.AsInteger := 0;
  dmFibs.qrTaskDELETEALL.AsInteger := 1;
  dmFibs.qrTaskZIPBACKUP.Value := 'True'; // Careful  it's case sensitive
  dmFibs.qrTaskCOMPRESS.Value := 'Default';
  dmFibs.qrTaskPUNIT.Value := 'Backups';
  dmFibs.qrTaskBCOUNTER.AsInteger := 0;
  dmFibs.qrTaskPVAL.AsInteger := 1;
  dmFibs.qrTaskBOPTIONS.Value := '11100000';
  dmFibs.qrTaskBOXES.Value := DupeString('0', 84);
  for i := 0 to 23 do
    EditTaskForm.CGHours.checked[i] := False;
  for i := 0 to 59 do
    EditTaskForm.CGMinutes.checked[i] := False;
  s := dmFibs.qrTaskBOPTIONS.Value;
  for i := 0 to TotalGBakOptions - 1 do
    if (s[i + 1] = '1') then
      EditTaskForm.CLBGbakOptions.State[i] := cbChecked
    else
      EditTaskForm.CLBGbakOptions.State[i] := cbUnChecked;
  if EditTaskForm.ShowModal = mrOk then
  begin
    dmFibs.qrTaskDBNAME.Value := EditTaskForm.EditDatabaseName.Text;
    dmFibs.qrTaskBACKUPDIR.Value := EditTaskForm.EditDestinationDir.Text;
    dmFibs.qrTaskMIRRORDIR.Value := EditTaskForm.EditMirrorDir.Text;
    dmFibs.qrTaskMIRROR2DIR.Value := EditTaskForm.EditMirror2Dir.Text;
    dmFibs.qrTaskMIRROR3DIR.Value := EditTaskForm.EditMirror3Dir.Text;
    s := '';
    for i := 0 to TotalGBakOptions - 1 do
      if EditTaskForm.CLBGbakOptions.State[i] = cbChecked then
        s := s + '1'
      else
        s := s + '0';
    dmFibs.qrTaskBOPTIONS.Value := s;
    s := '';
    for i := 1 to 24 do
      if EditTaskForm.CGHours.State[i - 1] = cbChecked then
        s := s + '1'
      else
        s := s + '0';
    for i := 25 to 84 do
      if EditTaskForm.CGMinutes.State[i - 25] = cbChecked then
        s := s + '1'
      else
        s := s + '0';
    dmFibs.qrTaskBOXES.Value := s;
    dmFibs.qrTask.Post;
  end
  else
    dmFibs.qrTask.Cancel;
end;

procedure TfmFibs.DeleteAlarmsFromTimeList;
var
  X, Y: string;
  i: Integer;
  StartPos, Uzun: Integer;
begin
  if TimeList.Count > 0 then
  begin
    Y := dmFibs.qrTaskTASKNO.AsString;
    for i := TimeList.Count - 1 downto 0 do
    begin
      StartPos := Pos(' - ', TimeList.Strings[i]) + 3;
      Uzun := Pos(' + ', TimeList.Strings[i]) - StartPos;
      X := copy(TimeList.Strings[i], StartPos, Uzun);
      if X = Y then
        TimeList.Delete(i);
    end;
  end;
end;

procedure TfmFibs.MenuExitClick(Sender: TObject);
begin
  if BackupIsService then
  begin
    MessageDlg(PrgName + ' is running as a Windows Service now.'#13#10 +
      'If you want to stop FIBSBackupService please use FIBS tray icon''s "Stop Service" menu'#13#10 +
      'or use FIBSSM FIBS Service Manager.', mtInformation, [mbOk], 0);
    Exit;
  end
  else
  begin
    Show;
    if MessageDlg('Do you really want to exit?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
    begin
      Self.ttTimer.Enabled := False;
      Close;
    end;
  end;
end;

procedure TfmFibs.MenuActivateClick(Sender: TObject);
var
  gd, ld: string;
begin
  if dmFibs.qrTask.RecordCount < 1 then
  begin
    MessageDlg('No backup task to be activated!', mtError, [mbOk], 0);
    Exit;
  end;
  gd := Trim(dmFibs.qrOptionPATHTOGBAK.Value);
  if gd = '' then
  begin
    MessageDlg('GBAK Directory is empty!', mtError, [mbOk], 0);
    Exit;
  end
  else
    if DirectoryExists(gd) = False then
    begin
      MessageDlg('Gbak Directory doesn''t exists!', mtError, [mbOk], 0);
      ModalResult := mrNone;
      Exit;
    end
    else
      if FileExists(gd + '\gbak.exe') = False then
      begin
        MessageDlg('Gbak.exe cannot be found onto given Gbak Dir!', mtError, [mbOk], 0);
        ModalResult := mrNone;
        Exit;
      end;
  ld := Trim(dmFibs.qrOptionLOGDIR.Value);
  if (ld = '') then
  begin
    MessageDlg('LOG Directory is empty!', mtError, [mbOk], 0);
    Exit;
  end
  else
    if DirectoryExists(ld) = False then
    begin
      MessageDlg('Given LOG Directory doesn''t exists!' + #13#10 + '(' + ld + ')', mtError, [mbOk], 0);
      ModalResult := mrNone;
      Exit;
    end;

  if MessageDlg('Do you want to ACTIVATE ' + dmFibs.qrTaskTASKNAME.Value + '?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    ActivateOne;
  end;
end;

procedure TfmFibs.MenuDeactivateClick(Sender: TObject);
begin
  if MessageDlg('Do you want to DEACTIVATE ' + dmFibs.qrTaskTASKNAME.Value + '?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    DeleteAlarmsFromTimeList;
    dmFibs.qrTask.Edit;
    dmFibs.qrTaskACTIVE.AsInteger := 0;
    dmFibs.qrTask.Post;
    InitAlarms;
  end;
end;

procedure TfmFibs.BackUpDatabase(ARecNo: string; AAlarmDateTime: TDateTime);
var
  GenelOptions, BackUpOptions: string;
  FullDBPath, DBNameExt, DBExt: string;
  MirrorPath, Mirror2Path, Mirror3Path, FullMirrorPath, FullMirror2Path, FullMirror3Path: string;
  FullBUPath, BUPath, BUNameExt, LogName, LogNameExt: string;
  GBakPath, komut, VKomut, UserName, Password: string;
  DeleteAll, PVAdet, PVUnit, LenExt: Integer;
  currdir: string;
  FtpConnType: Integer;
  BatchFile, MailTo, Book, TaskName: string;
  DoValidate, CompressBackup, DoMirror, DoMirror2, DoMirror3: Boolean;
  BackupPriorityStr, CompDegree, s, BackupNo, FullLogPath: string;
  BackupPriority: TThreadPriority;
  SmtpServer, SendersMail, MailUserName, MailPassword: string;
  ShowBatchWin, UseParams: Boolean;
  Backup: TThread;
  SequenceIncremented: Boolean;
  ArchiveDir: string;
begin
  dmFibs.qrTask.DisableControls;
  Book := dmFibs.qrTaskTASKNO.AsString;
  try
    dmFibs.qrTask.Locate('TASKNO', ARecNo, []);
    TaskName := dmFibs.qrTaskTASKNAME.Value;
    GBakPath := dmFibs.qrOptionPATHTOGBAK.Value;
    UserName := dmFibs.qrTaskUSER.Value;
    Password := DCPbase64.Base64DecodeStr(dmFibs.qrTaskPASSWORD.AsString);
    DoValidate := dmFibs.qrTaskDOVAL.AsBoolean;
    BatchFile := dmFibs.qrTaskBATCHFILE.Value;
    ShowBatchWin := dmFibs.qrTaskSHOWBATCHWIN.AsBoolean;
    UseParams := dmFibs.qrTaskUSEPARAMS.AsBoolean;

    SmtpServer := dmFibs.qrOptionSMTPSERVER.Value;
    SendersMail := dmFibs.qrOptionSENDERSMAIL.Value;
    MailUserName := dmFibs.qrOptionMAILUSERNAME.Value;
    MailPassword := DCPbase64.Base64DecodeStr(dmFibs.qrOptionMAILPASSWORD.AsString);

    MailTo := dmFibs.qrTaskMAILTO.Value;
    FtpConnType := StrToIntDef(dmFibs.qrOptionFTPCONNTYPE.AsString, 0);

    CompDegree := dmFibs.qrTaskCOMPRESS.Value;
    DeleteAll := dmFibs.qrTaskDELETEALL.AsInteger;
    PVAdet := dmFibs.qrTaskPVAL.AsInteger;
    PVUnit := -1; // For init
    if dmFibs.qrTaskPUNIT.Value = 'Backups' then
      PVUnit := 0
    else
      if dmFibs.qrTaskPUNIT.Value = 'Hour''s Backup' then
        PVUnit := 1
      else
        if dmFibs.qrTaskPUNIT.Value = 'Day''s Backup' then
          PVUnit := 2
        else
          if dmFibs.qrTaskPUNIT.Value = 'Month''s Backup' then
            PVUnit := 3;

    FullDBPath := dmFibs.qrTaskDBNAME.Value;
    BUPath := dmFibs.qrTaskBACKUPDIR.Value;
    MirrorPath := dmFibs.qrTaskMIRRORDIR.Value;
    Mirror2Path := dmFibs.qrTaskMIRROR2DIR.Value;
    Mirror3Path := dmFibs.qrTaskMIRROR3DIR.Value;
    currdir := ExtractFilePath(Application.ExeName);
    BackupNo := RightStr('0000' + dmFibs.qrTaskBCOUNTER.AsString, 4);

    if (MirrorPath <> '') then
      DoMirror := True
    else
      DoMirror := False;
    if (Mirror2Path <> '') then
      DoMirror2 := True
    else
      DoMirror2 := False;
    if (Mirror3Path <> '') then
      DoMirror3 := True
    else
      DoMirror3 := False;
    CompressBackup := dmFibs.qrTaskZIPBACKUP.AsBoolean;

    DBNameExt := ExtractFileName(FullDBPath);
    DBExt := UpperCase(ExtractFileExt(DBNameExt));
    LenExt := Length(DBExt);
    if DBExt = '.GDB' then
      BUNameExt := TaskName + '.GBK'
    else
      if DBExt = '.FDB' then
        BUNameExt := TaskName + '.FBK'
      else
        if DBExt = '.IB' then
          BUNameExt := TaskName + '.IBK'
        else
          BUNameExt := TaskName + '.XBK';

    FullBUPath := MakeFull(BUPath, BUNameExt);
    FullMirrorPath := MakeFull(MirrorPath, BUNameExt);
    FullMirror2Path := MakeFull(Mirror2Path, BUNameExt);
    FullMirror3Path := MakeFull(Mirror2Path, BUNameExt);

    LogName := 'LOG_' + TaskName;
    LogNameExt := 'LOG_' + TaskName + '.TXT';
    FullLogPath := MakeFull(dmFibs.qrOptionLOGDIR.Value, LogNameExt);

    BackupPriorityStr := dmFibs.qrOptionBPRIORTY.Value;
    BackupPriority := tpNormal; //for Init
    if BackupPriorityStr = 'Idle' then
      BackupPriority := tpIdle
    else
      if BackupPriorityStr = 'Lowest' then
        BackupPriority := tpLowest
      else
        if BackupPriorityStr = 'Lower' then
          BackupPriority := tpLower
        else
          if BackupPriorityStr = 'Normal' then
            BackupPriority := tpNormal
          else
            if BackupPriorityStr = 'Higher' then
              BackupPriority := tpHigher
            else
              if BackupPriorityStr = 'Highest' then
                BackupPriority := tpHighest;

    dmFibs.qrTask.Edit;
    if ((StrToInt(BackupNo) + 1) > 9999) then
      dmFibs.qrTaskBCOUNTER.AsInteger := 0
    else
      dmFibs.qrTaskBCOUNTER.AsInteger := StrToInt(BackupNo) + 1;
    dmFibs.qrTask.Post;

    GenelOptions := '-v';
    s := dmFibs.qrTaskBOPTIONS.Value;
    BackUpOptions := '';
    if (s[1] = '1') then
      BackUpOptions := BackUpOptions + ' -t'; //Create Tranpostable Backup
    if (s[2] = '1') then
      BackUpOptions := BackUpOptions + ' -g'; //Do not Perform Garbage Collection
    if (s[3] = '1') then
      BackUpOptions := BackUpOptions + ' -co'; //Convert External Tables to Internal Tables
    if (s[4] = '1') then
      BackUpOptions := BackUpOptions + ' -ig'; //Ignore Checksum Error
    if (s[5] = '1') then
      BackUpOptions := BackUpOptions + ' -l'; //Ignore Limbo Transactions
    if (s[6] = '1') then
      BackUpOptions := BackUpOptions + ' -m'; //Only Backup Metadata
    if (s[7] = '1') then
      BackUpOptions := BackUpOptions + ' -e'; //Create Uncompressed Backup
    if (s[8] = '1') then
      BackUpOptions := BackUpOptions + ' -nt'; //Use Non-Tranpostable Format

    komut := GBakPath + '\gbak.exe' +
      ' ' + GenelOptions +
      ' ' + BackUpOptions +
      ' -user ' + UserName +
      ' -password ' + Password;

    VKomut := '"' + GBakPath + '\gfix.exe"' +
      ' -v -n -user ' + UserName +
      ' -password ' + Password;
    SequenceIncremented := dmFibs.CheckDatabaseSequenceIncrement;
    ArchiveDir := dmFibs.qrOptionARCHIVEDIR.Value;
    Backup := TBackUp.Create(AAlarmDateTime, komut, VKomut, currdir, TaskName, BackUpOptions,
      FullDBPath, FullBUPath, FullMirrorPath, FullMirror2Path,
      FullMirror3Path, FullLogPath, BackupNo, CompDegree, SmtpServer,
      SendersMail, MailUserName, MailPassword, MailTo, BatchFile,
      UseParams, ShowBatchWin, DoMirror, DoMirror2, DoMirror3, True,
      CompressBackup, DoValidate, PVAdet, PVUnit, DeleteAll, FtpConnType,
      BackupPriority, SequenceIncremented, ArchiveDir);
  finally
    dmFibs.qrTask.Locate('TASKNO', Book, []);
    dmFibs.qrTask.EnableControls;
    try
      Backup.WaitFor;
    except
    end;
    if SequenceIncremented then
      Self.BackUpDatabase(ARecNo, AAlarmDateTime);
  end;
end;

procedure TfmFibs.ManualBackUp(AAlarmDateTime: TDateTime; TaskName, GBakPath, UserName, Password, FullDBPath, BUPath, MirrorPath, Mirror2Path, Mirror3Path, ACompDegree: string; ADoZip, ADoValidate: Boolean);
var
  GenelOptions, BackUpOptions: string;
  DBNameExt, DBExt: string;
  FullMirrorPath, FullMirror2Path, FullMirror3Path, FullBUPath, BUNameExt, LogName, LogNameExt: string;
  komut, VKomut: string;
  DeleteAll, PVAdet, PVUnit, LenExt: Integer;
  MailTo, s, FullLogPath, currdir: string;
  DoMirror, DoMirror2, DoMirror3: Boolean;
  BackupPriorityStr, BackupNo: string;
  BackupPriority: TThreadPriority;
  FtpConnType: Integer;
  BatchFile, SmtpServer, SendersMail, MailUserName, MailPassword: string;
  ShowBatchWin, UseParams: Boolean;
  Backup: TThread;
  SequenceIncremented: Boolean;
  ArchiveDir: string;
begin
  BackupNo := RightStr('0000' + dmFibs.qrTaskBCOUNTER.AsString, 4);
  currdir := ExtractFilePath(Application.ExeName);
  if (MirrorPath <> '') then
    DoMirror := True
  else
    DoMirror := False;
  if (Mirror2Path <> '') then
    DoMirror2 := True
  else
    DoMirror2 := False;
  if (Mirror3Path <> '') then
    DoMirror3 := True
  else
    DoMirror3 := False;
  DBNameExt := ExtractFileName(FullDBPath);
  DBExt := UpperCase(ExtractFileExt(DBNameExt));
  LenExt := Length(DBExt);

  if DBExt = '.GDB' then
    BUNameExt := TaskName + '.GBK'
  else
    if DBExt = '.FDB' then
      BUNameExt := TaskName + '.FBK'
    else
      if DBExt = '.IB' then
        BUNameExt := TaskName + '.IBK'
      else
        BUNameExt := TaskName + '.XBK';

  FullBUPath := MakeFull(BUPath, BUNameExt);
  FullMirrorPath := MakeFull(MirrorPath, BUNameExt);
  FullMirror2Path := MakeFull(Mirror2Path, BUNameExt);
  FullMirror3Path := MakeFull(Mirror3Path, BUNameExt);

  DeleteAll := dmFibs.qrTaskDELETEALL.AsInteger;

  BackupPriorityStr := dmFibs.qrOptionBPRIORTY.Value;
  BackupPriority := tpNormal; // For Init
  if BackupPriorityStr = 'Idle' then
    BackupPriority := tpIdle
  else
    if BackupPriorityStr = 'Lowest' then
      BackupPriority := tpLowest
    else
      if BackupPriorityStr = 'Lower' then
        BackupPriority := tpLower
      else
        if BackupPriorityStr = 'Normal' then
          BackupPriority := tpNormal
        else
          if BackupPriorityStr = 'Higher' then
            BackupPriority := tpHigher
          else
            if BackupPriorityStr = 'Highest' then
              BackupPriority := tpHighest;

  PVAdet := dmFibs.qrTaskPVAL.AsInteger;
  PVUnit := -1;
  if dmFibs.qrTaskPUNIT.Value = 'Backups' then
    PVUnit := 0
  else
    if dmFibs.qrTaskPUNIT.Value = 'Hour''s Backup' then
      PVUnit := 1
    else
      if dmFibs.qrTaskPUNIT.Value = 'Day''s Backup' then
        PVUnit := 2
      else
        if dmFibs.qrTaskPUNIT.Value = 'Month''s Backup' then
          PVUnit := 3;

  SmtpServer := dmFibs.qrOptionSMTPSERVER.Value;
  SendersMail := dmFibs.qrOptionSENDERSMAIL.Value;
  MailUserName := dmFibs.qrOptionMAILUSERNAME.Value;
  MailPassword := DCPbase64.Base64DecodeStr(dmFibs.qrOptionMAILPASSWORD.AsString);

  BatchFile := dmFibs.qrTaskBATCHFILE.Value;
  ShowBatchWin := dmFibs.qrTaskSHOWBATCHWIN.AsBoolean;
  UseParams := dmFibs.qrTaskUSEPARAMS.AsBoolean;
  MailTo := dmFibs.qrTaskMAILTO.Value;
  FtpConnType := StrToIntDef(dmFibs.qrOptionFTPCONNTYPE.AsString, 1);

  LogName := 'LOG_' + TaskName;
  LogNameExt := 'LOG_' + TaskName + '.TXT';
  FullLogPath := MakeFull(dmFibs.qrOptionLOGDIR.Value, LogNameExt);
  dmFibs.qrTask.Edit;
  if ((StrToInt(BackupNo) + 1) > 9999) then
    dmFibs.qrTaskBCOUNTER.AsInteger := 0
  else
    dmFibs.qrTaskBCOUNTER.AsInteger := StrToInt(BackupNo) + 1;
  dmFibs.qrTask.Post;
  GenelOptions := '-v';
  s := dmFibs.qrTaskBOPTIONS.Value;
  BackUpOptions := '';
  if (s[1] = '1') then
    BackUpOptions := BackUpOptions + ' -t'; //Create Tranpostable Backup
  if (s[2] = '1') then
    BackUpOptions := BackUpOptions + ' -g'; //Do not Perform Garbage Collection
  if (s[3] = '1') then
    BackUpOptions := BackUpOptions + ' -co'; //Convert External Tables to Internal Tables
  if (s[4] = '1') then
    BackUpOptions := BackUpOptions + ' -ig'; //Ignore Checksum Error
  if (s[5] = '1') then
    BackUpOptions := BackUpOptions + ' -l'; //Ignore Limbo Transactions
  if (s[6] = '1') then
    BackUpOptions := BackUpOptions + ' -m'; //Only Backup Metadata
  if (s[7] = '1') then
    BackUpOptions := BackUpOptions + ' -e'; //Create Uncompressed Backup
  if (s[8] = '1') then
    BackUpOptions := BackUpOptions + ' -nt'; //Use Non-Tranpostable Format

  komut := GBakPath + '\gbak.exe' +
    ' ' + GenelOptions +
    ' ' + BackUpOptions +
    ' -user ' + UserName +
    ' -password ' + Password;
  VKomut := '"' + GBakPath + '\gfix.exe"' +
    ' -v -n -user ' + UserName +
    ' -password ' + Password;
  SequenceIncremented := dmFibs.CheckDatabaseSequenceIncrement;
  ArchiveDir := dmFibs.qrOptionARCHIVEDIR.Value;
  Backup := TBackUp.Create(AAlarmDateTime, komut, VKomut, currdir, TaskName, BackUpOptions,
    FullDBPath, FullBUPath, FullMirrorPath, FullMirror2Path,
    FullMirror3Path, FullLogPath, BackupNo, ACompDegree, SmtpServer,
    SendersMail, MailUserName, MailPassword, MailTo, BatchFile,
    UseParams, ShowBatchWin, DoMirror, DoMirror2, DoMirror3, False,
    ADoZip, ADoValidate, PVAdet, PVUnit, DeleteAll, FtpConnType,
    BackupPriority, SequenceIncremented, ArchiveDir);
  Backup.Resume;
  {try
    Backup.WaitFor;
    Sleep(200);
  except
  end;
  if SequenceIncremented then
    if MessageDlg('A new database sequence [' + FormatFloat('0000', FunctionsUnit.GetDatabaseSequence(dmFibs.qrTaskDBNAME.AsString)) + '] is found. Backup now?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
      Self.ManualBackUp(AAlarmDateTime, dmFibs.qrTaskTASKNAME.AsString, GBakPath, UserName, Password, dmFibs.qrTaskDBNAME.AsString, BUPath, MirrorPath, Mirror2Path, Mirror3Path, ACompDegree, ADoZip, ADoValidate);}
end;

function GetTrapTime(s: string): TDateTime;
begin
  Result := StrToFloat(copy(s, 1, Pos(' - ', s) - 1))
end;

procedure TfmFibs.InitAlarms;
var
  NamePos, KeyPos, i: Integer;
  ATrapStr: string;
  ATrap: TDateTime;
  DT: TDateTime;
  AlarmFound: Boolean;
begin
  //Find CurrentTime
  DT := Now;
  LabelClock.caption := DateTimeToStr(DT);
  CurrentTime := DT - StartOfTheDay(DT);
  //Find next alarm time and owner
  CurrentOwner := '-';
  CurrentOwnerName := '-';
  ;
  CurrentAlarm := 0; //TdateTime
  CurrentItem := 0;
  AlarmFound := False;

  for i := 0 to TimeList.Count - 1 do
  begin
    CurrentItem := i;
    KeyPos := Pos(' - ', TimeList[i]);
    NamePos := Pos(' + ', TimeList[i]);
    ATrapStr := copy(TimeList[i], 1, KeyPos - 1);
    ATrap := StrToFloat(ATrapStr);
    // Exit loop if the alarm point is greater then CurrentTime..
    if ATrap > CurrentTime then
    begin
      CurrentAlarm := ATrap;
      CurrentOwner := copy(TimeList[i], KeyPos + 3, NamePos - (KeyPos + 3));
      CurrentOwnerName := RightStr(TimeList[i], Length(TimeList[i]) - NamePos - 2);
      AlarmFound := True;
      break;
    end;
  end;
  if (TimeList.Count = 0) then
  begin
    NoItemToExecute := True;
    Label5.Visible := False;
  end
  else
  begin
    NoItemToExecute := False;
    if AlarmFound = True then
    begin
      LastItemExecuted := False;
      Label5.caption := '  Next Backup : ' + CurrentOwnerName + ' on ' + MyDateTimeToStr(CurrentAlarm + StartOfTheDay(Now));
      Label5.Visible := True;
    end
    else
    begin
      LastItemExecuted := True;
      Label5.Visible := False;
    end;
  end;
  LabelAllTaskCompleted.Visible := LastItemExecuted;
  LabelNextBackup.Visible := NoItemToExecute;
end;

procedure TfmFibs.SetAlarms;
var
  NamePos, KeyPos: Integer;
  ATrapStr: string;
  ATrap: TDateTime;
  ItemStr: string;
begin
  // if current items is not at the bottom of the list increase List Item Number.
  if (CurrentItem < (TimeList.Count - 1)) then
  begin
    CurrentItem := CurrentItem + 1;
    ItemStr := TimeList[CurrentItem];
    KeyPos := Pos(' - ', ItemStr);
    NamePos := Pos(' + ', ItemStr);
    ATrapStr := copy(ItemStr, 1, KeyPos - 1);
    ATrap := StrToFloat(ATrapStr);
    CurrentAlarm := ATrap;
    CurrentOwner := copy(TimeList[CurrentItem], KeyPos + 3, NamePos - (KeyPos + 3));
    CurrentOwnerName := RightStr(TimeList[CurrentItem], Length(TimeList[CurrentItem]) - NamePos - 2);
    Label5.caption := '  Next Backup : ' + CurrentOwnerName + ' on ' + MyDateTimeToStr(CurrentAlarm + StartOfTheDay(Now));
  end;
end;

procedure TfmFibs.TaskGridDrawColumnCell(Sender: TObject;
  const Rect: TRect; DataCol: Integer; Column: TColumn;
  State: TGridDrawState);
begin
  if dmFibs.qrTask.RecordCount = 0 then
    Exit;
  if not (State = [gdSelected]) then
  begin
    if DataCol = 0 then
    begin
      if dmFibs.qrTaskACTIVE.AsInteger = 1 then
      begin
        TaskGrid.Canvas.Brush.Color := $00DBFFCD;
        TaskGrid.Canvas.Font.Color := $00DBFFCD;
      end
      else
      begin
        TaskGrid.Canvas.Brush.Color := clRed;
        TaskGrid.Canvas.Font.Color := clRed;
      end;
      TaskGrid.DefaultDrawColumnCell(Rect, DataCol, Column, State);
    end;
  end;
end;

procedure TfmFibs.MenuTaskClick(Sender: TObject);
begin
  MenuActivate.Enabled := dmFibs.qrTaskACTIVE.AsString = '0'; //Rev.2.0.1-2 ; this was "MenuActivate.Enabled:=dmFibs.qrTaskACTIVE.AsInteger=0;"
  MenuDeactivate.Enabled := not MenuActivate.Enabled;
  MenuDeactivateAll.Enabled := not NoItemToExecute;
  if dmFibs.qrTask.RecordCount < 1 then
  begin
    MenuDelete.caption := 'Delete Task';
    MenuActivate.caption := 'Activate Task';
    MenuDeactivate.caption := 'Deactivate Task';
  end
  else
  begin
    MenuDelete.caption := 'Delete Task "' + dmFibs.qrTaskTASKNAME.Value + ' "';
    MenuActivate.caption := 'Activate "' + dmFibs.qrTaskTASKNAME.Value + ' "';
    MenuDeactivate.caption := 'Deactivate "' + dmFibs.qrTaskTASKNAME.Value + ' "';
  end;
end;

procedure TfmFibs.MenuDeleteClick(Sender: TObject);
begin
  if dmFibs.qrTask.RecordCount > 0 then
  begin
    if dmFibs.qrTaskACTIVE.AsInteger = 0 then
    begin
      if MessageDlg('Do you want to DELETE' + dmFibs.qrTaskTASKNAME.Value + '?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
      begin
        DeleteAlarmsFromTimeList;
        dmFibs.qrTask.Delete;
        InitAlarms;
      end;
    end
    else
      MessageDlg('Deactivate Task before Delete!', mtWarning, [mbOk], 0);
  end
  else
    MessageDlg('No Task to Delete!', mtError, [mbOk], 0);
end;

procedure TfmFibs.TaskGridKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
    MenuEditTask.Click;
end;

procedure TfmFibs.MenuPlanClick(Sender: TObject);
var
  TStr, CStr: string;
  cc, i, KPos, NPos: Integer;
var
  ts: TStrings;
begin
  if dmFibs.qrTask.RecordCount < 1 then
  begin
    MessageDlg('No backup task to be seen the backup executing times!', mtError, [mbOk], 0);
    Exit;
  end;
  ts := TStringList.Create;
  ts.BeginUpdate;
  cc := 0;
  for i := 0 to TimeList.Count - 1 do
  begin
    KPos := Pos(' - ', TimeList[i]);
    NPos := Pos(' + ', TimeList[i]);
    TStr := MyDateTimeToStr(StrToFloat(copy(TimeList[i], 1, KPos - 1)) + StartOfTheDay(Now));
    if TStr = MyDateTimeToStr(CurrentAlarm + StartOfTheDay(Now)) then
      cc := i;
    CStr := RightStr(TimeList[i], Length(TimeList[i]) - NPos - 2);
    ts.Add(' ' + IntToStr(i + 1) + '.   ' + TStr + ' - ' + CStr)
  end;
  ts.EndUpdate;

  PlanListForm := TPlanListForm.Create(Self);
  PlanListForm.caption := 'Backup Executing Times in Today (' + DateToStr(Now) + ')';
  PlanListForm.PlanList.items.BeginUpdate;
  PlanListForm.PlanList.items.AddStrings(ts);
  PlanListForm.PlanList.items.EndUpdate;
  ts.Free;
  PlanListForm.PlanList.TopIndex := cc - 1;
  PlanListForm.PlanList.ItemIndex := cc;
  try
    PlanListForm.ShowModal;
  finally
    PlanListForm.Free;
  end;
end;

procedure TfmFibs.MenuAboutClick(Sender: TObject);
begin
  AboutForm := TAboutForm.Create(Self);
  try
    AboutForm.ShowModal;
  finally
    AboutForm.Free;
  end;
end;

procedure TfmFibs.MenuTimeSettingsClick(Sender: TObject);
var
  s, TStr: string;
  cc, i, KPos, NPos: Integer;
begin
  if dmFibs.qrTask.RecordCount < 1 then
  begin
    MessageDlg('No backup task to be seen the backup time settings!', mtError, [mbOk], 0);
    Exit;
  end;
  PlanListForm := TPlanListForm.Create(Self);
  PlanListForm.caption := 'Selected Backup Times of Task "' + dmFibs.qrTaskTASKNAME.Value + ' "';
  PlanListForm.PlanList.Clear;
  PlanListForm.PlanList.items.BeginUpdate;

  GetAlarmTimeList(dmFibs.qrTaskBOXES.Value);
  s := AlarmTimeList.Text;
  cc := 0;
  for i := 0 to AlarmTimeList.Count - 1 do
  begin
    KPos := Pos(' - ', AlarmTimeList[i]);
    NPos := Pos(' + ', AlarmTimeList[i]);
    TStr := TimeToStr(StrToFloat(copy(AlarmTimeList[i], 1, KPos - 1)));
    if TStr = MyDateTimeToStr(CurrentAlarm + StartOfTheDay(Now)) then
      cc := i;
    PlanListForm.PlanList.items.Add(' ' + IntToStr(i + 1) + '.   ' + TStr); //+' - '+CStr)
  end;
  PlanListForm.PlanList.items.EndUpdate;
  PlanListForm.PlanList.TopIndex := cc - 1;
  PlanListForm.PlanList.ItemIndex := cc;
  try
    PlanListForm.ShowModal;
  finally
    PlanListForm.Free;
  end;
end;

procedure TfmFibs.MenuLogClick(Sender: TObject);
var
  F: TextFile;
  s: string;
  TaskName, DBNameExt, LogDir, LogName, LogNameExt, LogPath: string;
  i: Integer;
begin
  if dmFibs.qrTask.RecordCount < 1 then
  begin
    MessageDlg('No task log to be viewed!', mtError, [mbOk], 0);
    Exit;
  end;
  TaskName := FunctionsUnit.RemoveDatabaseSequenceTokens(dmFibs.qrTaskTASKNAME.Value);
  DBNameExt := ExtractFileName(dmFibs.qrTaskDBNAME.Value);
  LogName := 'LOG_' + TaskName;
  LogNameExt := 'LOG_' + TaskName + '.TXT';
  LogDir := dmFibs.qrOptionLOGDIR.Value;
  LogPath := MakeFull(LogDir, LogNameExt);
  if (LogPath = '') then
  begin
    MessageDlg('LOG Directory is empty!', mtError, [mbOk], 0);
    Exit;
  end
  else
    if DirectoryExists(LogDir) = False then
    begin
      MessageDlg('Given LOG Directory doesn''t exists!' + #13#10 + '(' + LogDir + ')', mtError, [mbOk], 0);
      Exit;
    end;
  if FileExists(LogPath) = False then
  begin
    MessageDlg('LOG File for Task "' + TaskName + '" is not exist!' + #13#10 + 'Log File will be created after executing a backup task.', mtError, [mbOk], 0);
    Exit;
  end;
  LogForm := TLogForm.Create(Self);
  LogForm.caption := '  Task " ' + TaskName + ' " LOG';
  LogForm.LogFile := LogNameExt;
  LogForm.LabelLogPath.caption := 'Log File: ' + LogPath;
  try
    i := 1;
    AssignFile(F, LogPath);
    Reset(F);
    LogForm.StringGrid1.Cols[0].BeginUpdate;
    while not eof(F) do
    begin
      LogForm.StringGrid1.RowCount := i;
      Readln(F, s);
      LogForm.StringGrid1.Cols[0][i - 1] := s;
      inc(i);
    end;
    LogForm.StringGrid1.Cols[0].EndUpdate;
    CloseFile(F);
    LogForm.StringGrid1.TopRow := LogForm.StringGrid1.RowCount - 1;
    LogForm.ShowModal;
  finally
    LogForm.Free;
  end;
end;

procedure TfmFibs.ActivateAllLeavedActive;
var
  i: Integer;
  gd, ld, Mirr, Mirr2, Mirr3: string;
  bValidMirrors: Boolean;
begin
  gd := Trim(dmFibs.qrOptionPATHTOGBAK.Value);
  ld := Trim(dmFibs.qrOptionLOGDIR.Value);
  if (gd = '') or (DirectoryExists(gd) = False) or (FileExists(gd + '\gbak.exe') = False) or
    (ld = '') or (DirectoryExists(ld) = False) then
  begin
    DeactivateAll;
    Exit;
  end;
  dmFibs.qrTask.DisableControls;
  try
    dmFibs.qrTask.First;
    while not dmFibs.qrTask.eof do
    begin
      if dmFibs.qrTaskACTIVE.AsInteger = 1 then
      begin
        if FileExistsRem(FunctionsUnit.RemoveDatabaseSequenceTokens(dmFibs.qrTaskDBNAME.Value), dmFibs.qrTaskLOCALCONN.AsBoolean) then
        begin
          if FunctionsUnit.IsValidDirectory(dmFibs.qrTaskBACKUPDIR.Value) then
          begin
            bValidMirrors := FunctionsUnit.IsValidDirectory(dmFibs.qrTaskMIRRORDIR.Value) and FunctionsUnit.IsValidDirectory(dmFibs.qrTaskMIRROR2DIR.Value) and FunctionsUnit.IsValidDirectory(dmFibs.qrTaskMIRROR3DIR.Value);
            bValidMirrors := (not ActiveTaskValidMirrorDirectory) or bValidMirrors;
            if bValidMirrors then
            begin
              DeleteCurrentTaskFromTimeList;
              GetAlarmTimeList(dmFibs.qrTaskBOXES.Value);
              for i := 0 to AlarmTimeList.Count - 1 do
                TimeList.Add(AlarmTimeList[i]);
            end;
          end;
        end;
      end;
      dmFibs.qrTask.Next;
    end;
    InitAlarms;
  finally
    dmFibs.qrTask.First;
    dmFibs.qrTask.EnableControls;
  end;
end;

procedure TfmFibs.ActivateOne;
var
  i: Integer;
  PD: TMesajForm;
  Mirr, Mirr2, Mirr3: string;
  bValidMirrors: Boolean;
begin
  PD := ShowProsesDlg('Tasks are being activating..'#13#10'Please Wait..', 'c', PrgName);
  dmFibs.qrTask.DisableControls;
  try
    if dmFibs.qrTaskACTIVE.AsInteger = 0 then
    begin
      if FileExistsRem(FunctionsUnit.RemoveDatabaseSequenceTokens(dmFibs.qrTaskDBNAME.Value), dmFibs.qrTaskLOCALCONN.AsBoolean) then
      begin
        if FunctionsUnit.IsValidDirectory(dmFibs.qrTaskBACKUPDIR.Value) then
        begin
          bValidMirrors := FunctionsUnit.IsValidDirectory(dmFibs.qrTaskMIRRORDIR.Value) and FunctionsUnit.IsValidDirectory(dmFibs.qrTaskMIRROR2DIR.Value) and FunctionsUnit.IsValidDirectory(dmFibs.qrTaskMIRROR3DIR.Value);
          bValidMirrors := (not ActiveTaskValidMirrorDirectory) or bValidMirrors;
          if bValidMirrors then
          begin
            DeleteCurrentTaskFromTimeList;
            GetAlarmTimeList(dmFibs.qrTaskBOXES.Value);
            for i := 0 to AlarmTimeList.Count - 1 do
              TimeList.Add(AlarmTimeList[i]);
            dmFibs.qrTask.Edit;
            dmFibs.qrTaskACTIVE.AsInteger := 1;
            dmFibs.qrTask.Post;
            InitAlarms;
          end;
        end
        else
          MessageDlg('This Task can''t be Activated'#13#10'Because Directory "' + dmFibs.qrTaskBACKUPDIR.Value + '" is not Exists!', mtError, [mbOk], 0); //1.0.12
      end
      else
        MessageDlg('This Task can''t be Activated'#13#10 + 'Because Database "' + dmFibs.qrTaskDBNAME.Value + '" is not exists!', mtError, [mbOk], 0); //1.0.12
    end;
  finally
    dmFibs.qrTask.EnableControls;
    HideProsesDlg(PD);
  end;
end;

procedure TfmFibs.ActivateAll;
var
  i: Integer;
  Book: Integer;
  PD: TMesajForm;
  Mirr, Mirr2, Mirr3: string;
  bValidMirrors: Boolean;

  function ValidDirectory(ADir: string): Boolean;
  begin
    ADir := Trim(ADir);
    Result := (ADir = '') or ((DirectoryExists(ADir) or IsFtpPath(ADir)));
  end;
begin
  PD := ShowProsesDlg('Tasks are being activating..'#13#10'Please Wait..', 'c', PrgName);
  dmFibs.qrTask.DisableControls;
  Book := dmFibs.qrTaskTASKNO.AsInteger;
  try
    dmFibs.qrTask.First;
    while not dmFibs.qrTask.eof do
    begin
      if dmFibs.qrTaskACTIVE.AsInteger = 0 then
      begin
        if FileExistsRem(FunctionsUnit.RemoveDatabaseSequenceTokens(dmFibs.qrTaskDBNAME.Value), dmFibs.qrTaskLOCALCONN.AsBoolean) then
        begin
          if DirectoryExists(dmFibs.qrTaskBACKUPDIR.Value) then
          begin
            bValidMirrors := ValidDirectory(dmFibs.qrTaskMIRRORDIR.Value) and ValidDirectory(dmFibs.qrTaskMIRROR2DIR.Value) and ValidDirectory(dmFibs.qrTaskMIRROR3DIR.Value);
            bValidMirrors := (not ActiveTaskValidMirrorDirectory) or bValidMirrors;
            if bValidMirrors then
            begin
              DeleteCurrentTaskFromTimeList;
              GetAlarmTimeList(dmFibs.qrTaskBOXES.Value);
              for i := 0 to AlarmTimeList.Count - 1 do
                TimeList.Add(AlarmTimeList[i]);
              dmFibs.qrTask.Edit;
              dmFibs.qrTaskACTIVE.AsInteger := 1;
            end;
          end;
        end;
      end;
      dmFibs.qrTask.Next;
    end;
    dmFibs.qrTask.CheckBrowseMode;
    InitAlarms;
  finally
    dmFibs.qrTask.Locate('TASKNO', Book, []);
    dmFibs.qrTask.EnableControls;
    HideProsesDlg(PD);
  end;
end;

procedure TfmFibs.MenuActivateAllClick(Sender: TObject);
var
  gd, ld: string;
begin
  if dmFibs.qrTask.RecordCount < 1 then
  begin
    MessageDlg('No backup task to be activated!', mtError, [mbOk], 0);
    Exit;
  end;
  gd := Trim(dmFibs.qrOptionPATHTOGBAK.Value);
  if gd = '' then
  begin
    MessageDlg('GBAK Directory is empty!', mtError, [mbOk], 0);
    Exit;
  end
  else
    if DirectoryExists(gd) = False then
    begin
      MessageDlg('Gbak Directory doesn''t exists!', mtError, [mbOk], 0);
      ModalResult := mrNone;
      Exit;
    end
    else
      if FileExists(gd + '\gbak.exe') = False then
      begin
        MessageDlg('Gbak.exe cannot be found onto given Gbak Dir!', mtError, [mbOk], 0);
        ModalResult := mrNone;
        Exit;
      end;
  ld := Trim(dmFibs.qrOptionLOGDIR.Value);
  if (ld = '') then
  begin
    MessageDlg('LOG Directory is empty!', mtError, [mbOk], 0);
    Exit;
  end
  else
    if DirectoryExists(ld) = False then
    begin
      MessageDlg('Given LOG Directory doesn''t exists!' + #13#10 + '(' + ld + ')', mtError, [mbOk], 0);
      ModalResult := mrNone;
      Exit;
    end;
  if MessageDlg('Only error-free-defined tasks will be activated !!'#13#10 +
    '(But no error message will be shown !)'#13#10#13#10 +
    'Do you want to ACTIVATE all deactive tasks?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    ActivateAll;
  end;
end;

procedure TfmFibs.DeactivateAll;
var
  Book: Integer;
  PD: TMesajForm;
begin
  PD := ShowProsesDlg('Tasks are being deactivating..'#13#10'Please Wait..', 'c', PrgName);
  dmFibs.qrTask.DisableControls;
  Book := dmFibs.qrTaskTASKNO.AsInteger;
  try
    dmFibs.qrTask.First;
    while not dmFibs.qrTask.eof do
    begin
      if dmFibs.qrTaskACTIVE.AsInteger = 1 then
      begin
        DeleteAlarmsFromTimeList;
        dmFibs.qrTask.Edit;
        dmFibs.qrTaskACTIVE.AsInteger := 0;
      end;
      dmFibs.qrTask.Next;
    end;
    dmFibs.qrTask.CheckBrowseMode;
    InitAlarms;
  finally
    dmFibs.qrTask.Locate('TASKNO', Book, []);
    dmFibs.qrTask.EnableControls;
    HideProsesDlg(PD);
  end;
end;

procedure TfmFibs.MenuDeactivateAllClick(Sender: TObject);
begin
  if MessageDlg('Do you want to activate All deactive tasks ?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    DeactivateAll;
  end;
end;

procedure TfmFibs.MenuBackupNowClick(Sender: TObject);
var
  s, TN, GP, UN, PW, DN, DD, MD, MD2, MD3: string; //1.0.1 bd,mxd,ld
  DoVal, ZBU: Boolean;
  i: Integer;
  passw: string;
begin
  if dmFibs.qrTask.RecordCount < 1 then
  begin
    MessageDlg('No backup task to execute!', mtError, [mbOk], 0);
    ModalResult := mrNone;
    Exit;
  end;

  ManualBackupForm := TManualBackupForm.Create(Self);
  ManualBackupForm.EditTaskName.Text := dmFibs.qrTaskTASKNAME.Value;
  ManualBackupForm.EditDatabaseName.Text := dmFibs.qrTaskDBNAME.Value;
  ManualBackupForm.EditDestinationDir.Text := dmFibs.qrTaskBACKUPDIR.Value;
  ManualBackupForm.EditMirrorDir.Text := dmFibs.qrTaskMIRRORDIR.Value;
  ManualBackupForm.EditMirror2Dir.Text := dmFibs.qrTaskMIRROR2DIR.Value;
  ManualBackupForm.EditMirror3Dir.Text := dmFibs.qrTaskMIRROR3DIR.Value;
  ManualBackupForm.EditGBakDir.Text := dmFibs.qrOptionPATHTOGBAK.Value;
  ManualBackupForm.EditUserName.Text := dmFibs.qrTaskUSER.Value;
  ManualBackupForm.EditPassword.Text := DCPbase64.Base64DecodeStr(dmFibs.qrTaskPASSWORD.AsString);
  ManualBackupForm.EditCompDeg.Text := dmFibs.qrTaskCOMPRESS.Value;
  ManualBackupForm.EditPriority.Text := dmFibs.qrOptionBPRIORTY.Value;
  ManualBackupForm.EditMailTo.Text := dmFibs.qrTaskMAILTO.Value;
  s := dmFibs.qrTaskBOPTIONS.Value;
  for i := 0 to TotalGBakOptions - 1 do
    if (s[i + 1] = '1') then
      ManualBackupForm.CLBGbakOptions.State[i] := cbChecked
    else
      ManualBackupForm.CLBGbakOptions.State[i] := cbUnChecked;
  try
    if ManualBackupForm.ShowModal = mrOk then
    begin
      TN := ManualBackupForm.EditTaskName.Text;
      DN := ManualBackupForm.EditDatabaseName.Text;
      DD := ManualBackupForm.EditDestinationDir.Text;
      MD := ManualBackupForm.EditMirrorDir.Text;
      MD2 := ManualBackupForm.EditMirror2Dir.Text;
      MD3 := ManualBackupForm.EditMirror3Dir.Text;
      UN := ManualBackupForm.EditUserName.Text;
      PW := ManualBackupForm.EditPassword.Text;
      GP := ManualBackupForm.EditGBakDir.Text;
      ZBU := ManualBackupForm.DBCheckBox1.State = cbChecked;
      DoVal := ManualBackupForm.DBCheckBox2.State = cbChecked;
      ManualBackUp(Now, TN, GP, UN, PW, DN, DD, MD, MD2, MD3,
        dmFibs.qrTaskCOMPRESS.Value, ZBU, DoVal);
    end;
  finally
    ManualBackupForm.Free;
  end;
end;

procedure TfmFibs.miTrayShowClick(Sender: TObject);
begin
  if Self.Visible = False then
  begin
    Application.ShowMainForm := True;
    Self.Show;
    MainFormHidden := False;
  end
  else
    screen.ActiveForm.SetFocus;
end;

procedure TfmFibs.miTrayHideClick(Sender: TObject);
begin
  if screen.ActiveForm = nil then
    Exit;
  if screen.ActiveForm = Self then
  begin
    Self.Hide;
    MainFormHidden := True;
  end
  else
    MessageDlg('Close window "' + screen.ActiveForm.caption + '" first!', mtError, [mbOk], 0);
end;

procedure TfmFibs.MenuViewClick(Sender: TObject);
begin
  MenuPlan.caption := 'Backup Executing Times in Today (' + DateToStr(Now) + ')';
  if dmFibs.qrTask.RecordCount < 1 then
  begin
    MenuTimeSettings.caption := 'Backup Time Settings of Current Task';
    MenuLog.caption := 'LOG of Selected Task';
  end
  else
  begin
    MenuTimeSettings.caption := 'Backup Time Settings of Task "' + dmFibs.qrTaskTASKNAME.Value + ' "';
    MenuLog.caption := 'LOG of Task "' + dmFibs.qrTaskTASKNAME.Value + '"';
  end;
end;

procedure TfmFibs.MenuHelpHelpClick(Sender: TObject);
var
  HelpPath: string;
  res: Integer;
  sMsg: string;
begin
  HelpPath := GetCurrentDir + '\fibs.hlp';
  res := ShellExecute(Handle, 'open', PChar(HelpPath), nil, nil, SW_SHOWNORMAL);
  case res of
    0: sMsg := 'Error opening help file "' + HelpPath + '"'#13#10'The operating system is out of memory or resources.';
    SE_ERR_FNF: sMsg := 'Error opening help file !!'#13#10'Help file "' + HelpPath + '" couldn''t found.';
    SE_ERR_OOM: sMsg := 'Error opening help file "' + HelpPath + '"'#13#10'There was not enough memory to complete the operation.';
    SE_ERR_SHARE: sMsg := 'Error opening help file "' + HelpPath + '"'#13#10'A sharing violation occurred.';
  end;
  MessageDlg(sMsg, mtError, [mbOk], 0);
  {
  0	The operating system is out of memory or resources.
  ERROR_FILE_NOT_FOUND	The specified file was not found.
  ERROR_PATH_NOT_FOUND	The specified path was not found.
  ERROR_BAD_FORMAT	The .EXE file is invalid (non-Win32 .EXE or error in .EXE image).
  SE_ERR_ACCESSDENIED	The operating system denied access to the specified file.
  SE_ERR_ASSOCINCOMPLETE	The filename association is incomplete or invalid.
  SE_ERR_FNF	The specified file was not found.
  SE_ERR_NOASSOC	There is no application associated with the given filename extension.
  SE_ERR_OOM	There was not enough memory to complete the operation.
  SE_ERR_PNF	The specified path was not found.
  SE_ERR_SHARE	A sharing violation occurred.
  }
end;

procedure TfmFibs.FormShow(Sender: TObject);
begin
  Self.BringToFront;
end;

procedure TfmFibs.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if BackupIsService then
    Action := caNone
  else
    Action := caFree;
end;

procedure TfmFibs.miTrayStopServiceClick(Sender: TObject);
begin
  if BackupIsService then
    PostThreadMessage(BackupService.ServiceThread.ThreadID, WM_QUIT, 0, 0)
  else
    Application.Terminate;
end;

procedure TfmFibs.pmTrayPopup(Sender: TObject);
begin
  if BackupIsService then
    Self.miTrayStopService.Visible := True
  else
    Self.miTrayStopService.Visible := False;
  Self.miTrayExit.Visible := not Self.miTrayStopService.Visible;
end;

procedure TfmFibs.miTaskDuplicateClick(Sender: TObject);
begin
  dmFibs.DuplicateTask(False);
  Self.MenuEditTaskClick(nil);
end;

procedure TfmFibs.pmTaskPopup(Sender: TObject);
begin
  Self.miTaskDuplicate.Enabled := dmFibs.qrTask.RecordCount > 0;
end;

procedure TfmFibs.tiTrayDblClick(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  Self.miTrayShowClick(nil);
end;

procedure TfmFibs.ttTimerTimer(Sender: TObject);
var
  DT: TDateTime;
begin
  DT := Now;
  LabelClock.caption := DateTimeToStr(DT);
  CurrentTime := DT - StartOfTheDay(DT);
  CurrentDay := DayOf(DT);
  if (CurrentDay <> ThatDay) then
  begin
    ThatDay := CurrentDay;
    InitAlarms;
    Exit;
  end;
  if NoItemToExecute = True then
    Exit;
  if LastItemExecuted then
    Exit;
  if ((ExecutedItem <> CurrentItem) and (CurrentAlarm <= CurrentTime)) then
  begin
    BackUpDatabase(CurrentOwner, CurrentAlarm + StartOfTheDay(Now));
    ExecutedItem := CurrentItem;
    if (CurrentItem = TimeList.Count - 1) then
    begin
      LastItemExecuted := True;
      LabelAllTaskCompleted.Visible := LastItemExecuted;
      Label5.Visible := False;
    end
    else
    begin
      LastItemExecuted := False;
      LabelAllTaskCompleted.Visible := LastItemExecuted;
    end;
    SetAlarms;
  end;
end;

procedure TfmFibs.miTaskEditClick(Sender: TObject);
begin
  Self.MenuEditTaskClick(nil);
end;

procedure TfmFibs.miTaskBackupClick(Sender: TObject);
begin
  Self.MenuBackupNowClick(nil);
end;

end.

