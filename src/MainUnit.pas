
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

unit MainUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Mask, Buttons, ActiveX, ShellApi, Menus, ExtCtrls, Grids, DBGrids,
  DBCtrls, ThdTimer;

const
  WM_ICONTRAY = WM_USER + 1; // User-defined message

type

  TMainForm = class(TForm)
    MainMenu1: TMainMenu;
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
    MainTimer: TThreadedTimer;
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
    PopupMenu1: TPopupMenu;
    PopMenuShow: TMenuItem;
    PopMenuExit: TMenuItem;
    N8: TMenuItem;
    PopMenuHide: TMenuItem;
    MenuView: TMenuItem;
    MenuHelpHelp: TMenuItem;
    N5: TMenuItem;
    TrayTimer: TThreadedTimer;
    PopMenuStopService: TMenuItem;
    Label2: TLabel;
    ButtonPrefs: TSpeedButton;
    PopupMenu2: TPopupMenu;
    miTaskDuplicate: TMenuItem;
    procedure MenuPrefsClick(Sender: TObject);
    procedure MenuEditTaskClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure MenuNewClick(Sender: TObject);
    procedure MenuExitClick(Sender: TObject);
    procedure MenuActivateClick(Sender: TObject);
    procedure MenuDeactivateClick(Sender: TObject);
    procedure MainTimerTimer(Sender: TObject);
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
    procedure PopMenuShowClick(Sender: TObject);
    procedure PopMenuHideClick(Sender: TObject);
    procedure MenuViewClick(Sender: TObject);
    procedure MenuHelpHelpClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure TrayTimerTimer(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure PopMenuStopServiceClick(Sender: TObject);
    procedure PopupMenu1Popup(Sender: TObject);
    procedure WndProc(var Message: TMessage); override;
    procedure miTaskDuplicateClick(Sender: TObject);
    procedure PopupMenu2Popup(Sender: TObject);
  private
    procedure Icontray(var Msg: TMessage); message WM_ICONTRAY;
    procedure SysCommand(var Message: TWMSYSCOMMAND); message WM_SYSCOMMAND;
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
  MainForm: TMainForm;
  NotifyIconData: TNotifyIconData;
  fwm_TaskbarRestart: cardinal;

implementation

uses Registry, Variants, StrUtils, PrefUnit, EditTaskUnit, ConstUnit, DModuleUnit, BackupUnit,
  uTBase64, MesajUnit, ManualBackupUnit, FunctionsUnit, PlanListUnit,
  AboutUnit, LogUnit, YesNoUnit, PresetsUnit, DateUtils,
  RetMonitorTools, BackupServiceUnit, DB;

{$R *.DFM}

procedure PCharFromStr(const AString: ShortString; var APChar: PChar);
var
  ILen: Integer;
begin
  ILen := Length(AString);
  APChar := StrAlloc(ILen + 1);
  FillChar(APChar^, ILen + 1, #$00);
  Move(AString[1], APChar^, ILen);
end;

procedure TMainForm.Icontray(var Msg: TMessage);
var
  CursorPos: TPoint;
begin
  if Msg.lParam = WM_RBUTTONDOWN then
  begin
    GetCursorPos(CursorPos);
    PopupMenu1.Popup(CursorPos.x, CursorPos.y);
  end
  else
    if Msg.lParam = WM_LBUTTONDOWN then
    begin
      if MainForm.Visible = False then
      begin
        PopMenuShow.Click;
      end
      else
      begin
        Application.BringToFront;
        if screen.ActiveForm = MainForm then
          screen.ActiveForm.BringToFront;
      end;
    end
    else
      inherited;
end;

procedure TMainForm.SetResetAutoRun;
var
  Registry: TRegistry;
  AKey: string;
begin
  AKey := 'FIBS_Backup_Scheduler';
  Registry := TRegistry.Create;
  try
    Registry.RootKey := HKEY_LOCAL_MACHINE;
    if Registry.OpenKey('\Software\Microsoft\Windows\CurrentVersion\Run', False) then
    begin
      if DModule.OptionsTableAUTORUN.Value = '1' then
        Registry.WriteString(AKey, ParamStr(0))
      else
        Registry.DeleteValue(AKey);
    end;
  finally
    Registry.Free;
  end;
end;

procedure TMainForm.WndProc(var Message: TMessage);
var
  si: LongBool;
begin
  if (Message.Msg = fwm_TaskbarRestart) then
  begin
    si := Shell_NotifyIcon(NIM_ADD, @NotifyIconData);
    if si = False then
      TrayTimer.Enabled := True;
  end
  else
    if (Message.Msg = WM_CLOSE) then
    begin
      ButtonQuit.Click;
    end
    else
      if (Message.Msg = WM_ENDSESSION) then
      begin
        SetThreadLocale(LOCALE_SYSTEM_DEFAULT);
        SysUtils.GetFormatSettings;
        Application.UpdateFormatSettings := False;
      end
      else
        inherited WndProc(Message);
end;

procedure TMainForm.SetApplicationPriorty;
var
  MainThread: THandle;
  APriority: Integer;
  //  ap:string;
begin
  MainThread := GetCurrentProcess;
  APriority := THREAD_PRIORITY_NORMAL;
  {
   ap:=DModule.OptionsTableFPRIORTY.Value;
   if ap='Idle' then APriority:=THREAD_PRIORITY_IDLE
   else if ap='Lowest' then APriority:=THREAD_PRIORITY_LOWEST
   else if ap='Lower' then APriority:=THREAD_PRIORITY_BELOW_NORMAL
   else if ap='Normal' then APriority:=THREAD_PRIORITY_NORMAL
   else if ap='Higher' then APriority:=THREAD_PRIORITY_ABOVE_NORMAL
   else if ap='Highest' then APriority:=THREAD_PRIORITY_HIGHEST;
   }
  SetThreadPriority(MainThread, APriority);
end;

procedure TMainForm.MenuPrefsClick(Sender: TObject);
var
  s: string;
begin
  PrefForm := TPrefForm.Create(Self);
  try
    PrefForm.DirectoryEdit1.Text := DModule.OptionsTablePATHTOGBAK.Value;
    PrefForm.DirectoryLogDir.Text := DModule.OptionsTableLOGDIR.Value;
    PrefForm.DirectoryArchiveDir.Text := DModule.OptionsTableARCHIVEDIR.Value;
    PrefForm.EditSMTPServer.Text := DModule.OptionsTableSMTPSERVER.Value;
    PrefForm.EditMailAdress.Text := DModule.OptionsTableSENDERSMAIL.Value;
    PrefForm.EditUserName.Text := DModule.OptionsTableMAILUSERNAME.Value;
    DecodeData(DModule.OptionsTableMAILPASSWORD.Value, s);
    PrefForm.EditPassword.Text := s;
    if PrefForm.ShowModal = mrOk then
    begin
      DModule.OptionsTable.edit;
      SetResetAutoRun;
      DModule.OptionsTablePATHTOGBAK.Value := PrefForm.DirectoryEdit1.Text;
      DModule.OptionsTableLOGDIR.Value := PrefForm.DirectoryLogDir.Text;
      DModule.OptionsTableARCHIVEDIR.Value := PrefForm.DirectoryArchiveDir.Text;
      DModule.OptionsTableSMTPSERVER.Value := PrefForm.EditSMTPServer.Text;
      DModule.OptionsTableSENDERSMAIL.Value := PrefForm.EditMailAdress.Text;
      DModule.OptionsTableMAILUSERNAME.Value := PrefForm.EditUserName.Text;

      EncodeData(PrefForm.EditPassword.Text, s);
      DModule.OptionsTableMAILPASSWORD.Value := s;
      DModule.OptionsTable.Post;
    end;
  finally
    PrefForm.Free;
  end;
end;

procedure TMainForm.MenuEditTaskClick(Sender: TObject);
var
  i: Integer;
  s, T: string; //Saat, Dakika Checklist stringi
begin
  if DModule.AlarmTable.RecordCount > 0 then
  begin
    EditTaskForm.caption := ' Edit Backup Task';
    EditTaskForm.EditDatabaseName.Text := DModule.AlarmTableDBNAME.Value;
    EditTaskForm.EditDestinationDir.Text := DModule.AlarmTableBACKUPDIR.Value;
    EditTaskForm.EditMirrorDir.Text := DModule.AlarmTableMIRRORDIR.Value;
    EditTaskForm.EditMirror2Dir.Text := DModule.AlarmTableMIRROR2DIR.Value;
    EditTaskForm.EditMirror3Dir.Text := DModule.AlarmTableMIRROR3DIR.Value;
    EditTaskForm.LabelState.Visible := DModule.AlarmTableACTIVE.AsInteger = 1;
    EditTaskForm.FileEditBtnBatchFile.Text := DModule.AlarmTableBATCHFILE.Value;

    EditTaskForm.EditDatabaseName.Button.Enabled := DModule.AlarmTableLOCALCONN.AsBoolean = True;

    T := DModule.AlarmTableBOXES.Value;
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
    s := DModule.AlarmTableBOPTIONS.Value;
    for i := 0 to TotalGBakOptions - 1 do
      if (s[i + 1] = '1') then
        EditTaskForm.CLBGbakOptions.State[i] := cbChecked
      else
        EditTaskForm.CLBGbakOptions.State[i] := cbUnChecked;

    EditTaskForm.ButtonOK.Enabled := (DModule.AlarmTableACTIVE.AsInteger = 0);
    EditTaskForm.Position := poMainFormCenter;
    if EditTaskForm.ShowModal = mrOk then
    begin
      DModule.AlarmTable.edit;
      DModule.AlarmTableDBNAME.Value := EditTaskForm.EditDatabaseName.Text;
      DModule.AlarmTableBACKUPDIR.Value := EditTaskForm.EditDestinationDir.Text;
      DModule.AlarmTableMIRRORDIR.Value := EditTaskForm.EditMirrorDir.Text;
      DModule.AlarmTableMIRROR2DIR.Value := EditTaskForm.EditMirror2Dir.Text;
      DModule.AlarmTableMIRROR3DIR.Value := EditTaskForm.EditMirror3Dir.Text;
      DModule.AlarmTableBATCHFILE.Value := EditTaskForm.FileEditBtnBatchFile.Text;

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
      DModule.AlarmTableBOXES.Value := T;
      s := '';
      for i := 0 to TotalGBakOptions - 1 do
        if EditTaskForm.CLBGbakOptions.State[i] = cbChecked then
          s := s + '1'
        else
          s := s + '0';
      DModule.AlarmTableBOPTIONS.Value := s;

      DModule.AlarmTable.Post;

      DeleteCurrentTaskFromTimeList;

      GetAlarmTimeList(T);
      PreservedInHour := AlarmInHour;
      PreservedInDay := AlarmInDay;
      PreservedInMonth := AlarmInDay * AlarmInMonth;

      if DModule.AlarmTableACTIVE.AsInteger = 1 then
      begin
        for i := 0 to AlarmTimeList.Count - 1 do
          TimeList.Add(AlarmTimeList.Strings[i]);
        InitAlarms;
      end;
    end
    else
      DModule.AlarmTable.Cancel;
  end
  else
    MessageDlg('No Task to Edit!', mtError, [mbOk], 0);
end;

procedure TMainForm.DeleteCurrentTaskFromTimeList;
var
  x, y: string;
  i, L, StartPos, ALen: Integer;
begin
  if TimeList.Count > 0 then
  begin
    y := DModule.AlarmTableTASKNO.AsString;
    for i := TimeList.Count - 1 downto 0 do
    begin
      StartPos := Pos(' - ', TimeList.Strings[i]) + 3;
      x := TimeList[i];
      L := Pos(' + ', TimeList.Strings[i]);
      ALen := L - StartPos;
      x := copy(TimeList.Strings[i], StartPos, ALen);
      if x = y then
        TimeList.Delete(i);
    end;
  end;
end;

procedure TMainForm.GetAlarmTimeList(T: string);
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
          AlarmTimeList.Add(AlarmDateTimeStr + ' - ' + DModule.AlarmTableTASKNO.AsString + ' + ' + DModule.AlarmTableTASKNAME.AsString);
        end;
      end;
    end;
  end;
end;

procedure TMainForm.FormCreate(Sender: TObject);
var
  si: LongBool;
begin
  SetApplicationPriorty;

  fwm_TaskbarRestart := RegisterWindowMessage('TaskbarCreated');
  WindowProc := WndProc;

  Application.CreateForm(TDModule, DModule);
  if DataFilesInvalid then
    exit;

  SetThreadLocale(LOCALE_SYSTEM_DEFAULT);
  SysUtils.GetFormatSettings;
  Application.UpdateFormatSettings := False;

  SyncLog := TMultiReadExclusiveWriteSynchronizer.Create;
  AlarmTimeList := TStringList.Create;
  AlarmTimeList.Sorted := True;
  TimeList := TStringList.Create;
  TimeList.Sorted := True;
  MainTimer.Enabled := True;
  MainForm.caption := 'FIBS  ' + PrgInfo + ' Ver. ' + ReleaseInfo;
  ActivateAllLeavedActive;

  // Hide process messages when FIBS is minimised.
  if BackupIsService then
  begin
    Hide;
    MainFormHidden := True;
  end
  else
  begin
    Application.ShowMainForm := False;
    MainFormHidden := True;
  end;

  with NotifyIconData do
  begin
    hIcon := Self.Icon.Handle;
    if RunningAsService then
      StrPCopy(szTip, PrgName + ' is running As a Service.')
    else
      StrPCopy(szTip, PrgName + ' is running As a Application.');
    Wnd := Handle;
    uCallbackMessage := WM_ICONTRAY;
    uID := 1;
    uFlags := NIF_MESSAGE + NIF_ICON + NIF_TIP;
    cbSize := sizeof(TNotifyIconData);
  end;

  si := Shell_NotifyIcon(NIM_ADD, @NotifyIconData);
  if si = False then
  begin
    TrayTimer.Enabled := True;
  end;

  // Hide FIBS from Taskbar and Alt+Tab window.
  SetWindowLong(Application.Handle,
    GWL_EXSTYLE,
    GetWindowLong(Application.Handle, GWL_EXSTYLE)
    or WS_EX_TOOLWINDOW // remove app from the Alt+Tab window
    and not WS_EX_APPWINDOW); // remove app from the taskbar
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  AlarmTimeList.Free;
  TimeList.Free;
  SyncLog.Free;
  Application.HelpCommand(HELP_QUIT, 0);
  Shell_NotifyIcon(NIM_DELETE, @NotifyIconData);
end;

procedure TMainForm.MenuNewClick(Sender: TObject);
var
  i: Integer;
  s: string;
  bul: Boolean;
  TN: string;
begin
  DModule.AlarmTable.DisableControls;
  try
    TN := DModule.AlarmTableTASKNO.Value;
    DModule.AlarmTable.First;
    bul := DModule.AlarmTable.Locate('ACTIVE', 1, []);
    DModule.AlarmTable.First;
    DModule.AlarmTable.Locate('TASKNO', TN, []);
  finally
    DModule.AlarmTable.EnableControls;
  end;
  if bul then
  begin
    MessageDlg('You MUST DEACTIVE all active Tasks before adding a new Task!', mtError, [mbOk], 0);
    exit;
  end;
  DModule.AlarmTable.Append;
  EditTaskForm.caption := ' New Backup Task';
  EditTaskForm.EditDatabaseName.Text := '';
  EditTaskForm.EditDestinationDir.Text := '';
  EditTaskForm.EditMirrorDir.Text := '';
  EditTaskForm.EditMirror2Dir.Text := '';
  EditTaskForm.EditMirror3Dir.Text := '';
  EditTaskForm.LabelState.Visible := False;
  AlarmTimeList.Text := '';
  DModule.AlarmTableDOVAL.Value := 'False';
  DModule.AlarmTableMAILTO.Value := '';
  DModule.AlarmTableSHOWBATCHWIN.Value := 'False';
  DModule.AlarmTableUSEPARAMS.Value := 'False';

  DModule.AlarmTableLOCALCONN.Value := 'True';
  DModule.AlarmTableACTIVE.AsInteger := 0;
  DModule.AlarmTableDELETEALL.AsInteger := 1;
  DModule.AlarmTableZIPBACKUP.Value := 'True'; // Careful  it's case sensitive
  DModule.AlarmTableCOMPRESS.Value := 'Default';
  DModule.AlarmTablePUNIT.Value := 'Backups';
  DModule.AlarmTableBCOUNTER.AsInteger := 0;
  DModule.AlarmTablePVAL.AsInteger := 1;
  DModule.AlarmTableBOPTIONS.Value := '11100000';
  DModule.AlarmTableBOXES.Value := DupeString('0', 84);
  for i := 0 to 23 do
    EditTaskForm.CGHours.checked[i] := False;
  for i := 0 to 59 do
    EditTaskForm.CGMinutes.checked[i] := False;
  s := DModule.AlarmTableBOPTIONS.Value;
  for i := 0 to TotalGBakOptions - 1 do
    if (s[i + 1] = '1') then
      EditTaskForm.CLBGbakOptions.State[i] := cbChecked
    else
      EditTaskForm.CLBGbakOptions.State[i] := cbUnChecked;
  EditTaskForm.Position := poMainFormCenter;
  if EditTaskForm.ShowModal = mrOk then
  begin
    DModule.AlarmTableDBNAME.Value := EditTaskForm.EditDatabaseName.Text;
    DModule.AlarmTableBACKUPDIR.Value := EditTaskForm.EditDestinationDir.Text;
    DModule.AlarmTableMIRRORDIR.Value := EditTaskForm.EditMirrorDir.Text;
    DModule.AlarmTableMIRROR2DIR.Value := EditTaskForm.EditMirror2Dir.Text;
    DModule.AlarmTableMIRROR3DIR.Value := EditTaskForm.EditMirror3Dir.Text;
    s := '';
    for i := 0 to TotalGBakOptions - 1 do
      if EditTaskForm.CLBGbakOptions.State[i] = cbChecked then
        s := s + '1'
      else
        s := s + '0';
    DModule.AlarmTableBOPTIONS.Value := s;
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
    DModule.AlarmTableBOXES.Value := s;
    DModule.AlarmTable.Post;
  end
  else
    DModule.AlarmTable.Cancel;
end;

procedure TMainForm.DeleteAlarmsFromTimeList;
var
  x, y: string;
  i: Integer;
  StartPos, Uzun: Integer;
begin
  if TimeList.Count > 0 then
  begin
    y := DModule.AlarmTableTASKNO.AsString;
    for i := TimeList.Count - 1 downto 0 do
    begin
      StartPos := Pos(' - ', TimeList.Strings[i]) + 3;
      Uzun := Pos(' + ', TimeList.Strings[i]) - StartPos;
      x := copy(TimeList.Strings[i], StartPos, Uzun);
      if x = y then
        TimeList.Delete(i);
    end;
  end;
end;

procedure TMainForm.MenuExitClick(Sender: TObject);
begin
  if BackupIsService then
  begin
    MessageDlg(PrgName + ' is running as a Windows Service now.'#13#10 +
      'If you want to stop FIBSBackupService please use FIBS tray icon''s "Stop Service" menu'#13#10 +
      'or use FIBSSM FIBS Service Manager.', mtInformation, [mbOk], 0);
    exit;
  end
  else
  begin
    Show;
    if MessageDlg('Do you really want to exit?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
    begin
      MainTimer.Enabled := False;
      Close;
    end;
  end;
end;

procedure TMainForm.MenuActivateClick(Sender: TObject);
var
  gd, ld: string;
begin
  if DModule.AlarmTable.RecordCount < 1 then
  begin
    MessageDlg('No backup task to be activated!', mtError, [mbOk], 0);
    exit;
  end;
  gd := trim(DModule.OptionsTablePATHTOGBAK.Value);
  if gd = '' then
  begin
    MessageDlg('GBAK Directory is empty!', mtError, [mbOk], 0);
    exit;
  end
  else
    if DirectoryExists(gd) = False then
    begin
      MessageDlg('Gbak Directory doesn''t exists!', mtError, [mbOk], 0);
      ModalResult := mrNone;
      exit;
    end
    else
      if FileExists(gd + '\gbak.exe') = False then
      begin
        MessageDlg('Gbak.exe cannot be found onto given Gbak Dir!', mtError, [mbOk], 0);
        ModalResult := mrNone;
        exit;
      end;
  ld := trim(DModule.OptionsTableLOGDIR.Value);
  if (ld = '') then
  begin
    MessageDlg('LOG Directory is empty!', mtError, [mbOk], 0);
    exit;
  end
  else
    if DirectoryExists(ld) = False then
    begin
      MessageDlg('Given LOG Directory doesn''t exists!' + #13#10 + '(' + ld + ')', mtError, [mbOk], 0);
      ModalResult := mrNone;
      exit;
    end;

  if MessageDlg('Do you want to ACTIVATE ' + DModule.AlarmTableTASKNAME.Value + '?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    ActivateOne;
  end;
end;

procedure TMainForm.MenuDeactivateClick(Sender: TObject);
begin
  if MessageDlg('Do you want to DEACTIVATE ' + DModule.AlarmTableTASKNAME.Value + '?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    DeleteAlarmsFromTimeList;
    DModule.AlarmTable.edit;
    DModule.AlarmTableACTIVE.AsInteger := 0;
    DModule.AlarmTable.Post;
    InitAlarms;
  end;
end;

procedure TMainForm.BackUpDatabase(ARecNo: string; AAlarmDateTime: TDateTime);
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
  DModule.AlarmTable.DisableControls;
  Book := DModule.AlarmTableTASKNO.AsString;
  try
    DModule.AlarmTable.Locate('TASKNO', ARecNo, []);
    TaskName := DModule.AlarmTableTASKNAME.Value;
    GBakPath := DModule.OptionsTablePATHTOGBAK.Value;
    UserName := DModule.AlarmTableUSER.Value;
    //  Password:=DModule.AlarmTablePASSWORD.Value;
    DecodeData(DModule.AlarmTablePASSWORD.Value, Password);
    DoValidate := DModule.AlarmTableDOVAL.AsBoolean;
    BatchFile := DModule.AlarmTableBATCHFILE.Value;
    ShowBatchWin := DModule.AlarmTableSHOWBATCHWIN.AsBoolean;
    UseParams := DModule.AlarmTableUSEPARAMS.AsBoolean;

    SmtpServer := DModule.OptionsTableSMTPSERVER.Value;
    SendersMail := DModule.OptionsTableSENDERSMAIL.Value;
    MailUserName := DModule.OptionsTableMAILUSERNAME.Value;
    DecodeData(DModule.OptionsTableMAILPASSWORD.Value, MailPassword);

    MailTo := DModule.AlarmTableMAILTO.Value;
    FtpConnType := StrToIntDef(DModule.OptionsTableFTPCONNTYPE.AsString, 0);

    CompDegree := DModule.AlarmTableCOMPRESS.Value;
    DeleteAll := DModule.AlarmTableDELETEALL.AsInteger;
    PVAdet := DModule.AlarmTablePVAL.AsInteger;
    PVUnit := -1; // For init
    if DModule.AlarmTablePUNIT.Value = 'Backups' then
      PVUnit := 0
    else
      if DModule.AlarmTablePUNIT.Value = 'Hour''s Backup' then
        PVUnit := 1
      else
        if DModule.AlarmTablePUNIT.Value = 'Day''s Backup' then
          PVUnit := 2
        else
          if DModule.AlarmTablePUNIT.Value = 'Month''s Backup' then
            PVUnit := 3;

    FullDBPath := DModule.AlarmTableDBNAME.Value;
    BUPath := DModule.AlarmTableBACKUPDIR.Value;
    MirrorPath := DModule.AlarmTableMIRRORDIR.Value;
    Mirror2Path := DModule.AlarmTableMIRROR2DIR.Value;
    Mirror3Path := DModule.AlarmTableMIRROR3DIR.Value;
    currdir := ExtractFilePath(Application.ExeName);
    BackupNo := RightStr('0000' + DModule.AlarmTableBCOUNTER.AsString, 4);

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
    CompressBackup := DModule.AlarmTableZIPBACKUP.AsBoolean;

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
    FullLogPath := MakeFull(DModule.OptionsTableLOGDIR.Value, LogNameExt);

    BackupPriorityStr := DModule.OptionsTableBPRIORTY.Value;
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

    DModule.AlarmTable.edit;
    if ((StrToInt(BackupNo) + 1) > 9999) then
      DModule.AlarmTableBCOUNTER.AsInteger := 0
    else
      DModule.AlarmTableBCOUNTER.AsInteger := StrToInt(BackupNo) + 1;
    DModule.AlarmTable.Post;

    GenelOptions := '-v';
    s := DModule.AlarmTableBOPTIONS.Value;
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
    SequenceIncremented := DModule.CheckDatabaseSequenceIncrement;
    ArchiveDir := DModule.OptionsTableARCHIVEDIR.Value;
    Backup := TBackUp.Create(AAlarmDateTime, komut, VKomut, currdir, TaskName, BackUpOptions,
      FullDBPath, FullBUPath, FullMirrorPath, FullMirror2Path,
      FullMirror3Path, FullLogPath, BackupNo, CompDegree, SmtpServer,
      SendersMail, MailUserName, MailPassword, MailTo, BatchFile,
      UseParams, ShowBatchWin, DoMirror, DoMirror2, DoMirror3, True,
      CompressBackup, DoValidate, PVAdet, PVUnit, DeleteAll, FtpConnType,
      BackupPriority, SequenceIncremented, ArchiveDir);
  finally
    DModule.AlarmTable.Locate('TASKNO', Book, []);
    DModule.AlarmTable.EnableControls;
    try
      Backup.WaitFor;
    except
    end;
    if SequenceIncremented then
      Self.BackUpDatabase(ARecNo, AAlarmDateTime);
  end;
end;

procedure TMainForm.ManualBackUp(AAlarmDateTime: TDateTime; TaskName, GBakPath, UserName, Password, FullDBPath, BUPath, MirrorPath, Mirror2Path, Mirror3Path, ACompDegree: string; ADoZip, ADoValidate: Boolean);
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
  BackupNo := RightStr('0000' + DModule.AlarmTableBCOUNTER.AsString, 4);
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

  DeleteAll := DModule.AlarmTableDELETEALL.AsInteger;

  BackupPriorityStr := DModule.OptionsTableBPRIORTY.Value;
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

  PVAdet := DModule.AlarmTablePVAL.AsInteger;
  PVUnit := -1;
  if DModule.AlarmTablePUNIT.Value = 'Backups' then
    PVUnit := 0
  else
    if DModule.AlarmTablePUNIT.Value = 'Hour''s Backup' then
      PVUnit := 1
    else
      if DModule.AlarmTablePUNIT.Value = 'Day''s Backup' then
        PVUnit := 2
      else
        if DModule.AlarmTablePUNIT.Value = 'Month''s Backup' then
          PVUnit := 3;

  SmtpServer := DModule.OptionsTableSMTPSERVER.Value;
  SendersMail := DModule.OptionsTableSENDERSMAIL.Value;
  MailUserName := DModule.OptionsTableMAILUSERNAME.Value;
  DecodeData(DModule.OptionsTableMAILPASSWORD.Value, MailPassword);

  BatchFile := DModule.AlarmTableBATCHFILE.Value;
  ShowBatchWin := DModule.AlarmTableSHOWBATCHWIN.AsBoolean;
  UseParams := DModule.AlarmTableUSEPARAMS.AsBoolean;
  MailTo := DModule.AlarmTableMAILTO.Value;
  FtpConnType := StrToIntDef(DModule.OptionsTableFTPCONNTYPE.AsString, 1);

  LogName := 'LOG_' + TaskName;
  LogNameExt := 'LOG_' + TaskName + '.TXT';
  FullLogPath := MakeFull(DModule.OptionsTableLOGDIR.Value, LogNameExt);
  DModule.AlarmTable.edit;
  if ((StrToInt(BackupNo) + 1) > 9999) then
    DModule.AlarmTableBCOUNTER.AsInteger := 0
  else
    DModule.AlarmTableBCOUNTER.AsInteger := StrToInt(BackupNo) + 1;
  DModule.AlarmTable.Post;
  GenelOptions := '-v';
  s := DModule.AlarmTableBOPTIONS.Value;
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
  SequenceIncremented := DModule.CheckDatabaseSequenceIncrement;
  ArchiveDir := DModule.OptionsTableARCHIVEDIR.Value;
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
    if YesNoDlg('A new database sequence [' + FormatFloat('0000', FunctionsUnit.GetDatabaseSequence(DModule.AlarmTableDBNAME.AsString)) + '] is found. Backup now?', 'c', 'Database sequence') = mrYes then
      Self.ManualBackUp(AAlarmDateTime, DModule.AlarmTableTASKNAME.AsString, GBakPath, UserName, Password, DModule.AlarmTableDBNAME.AsString, BUPath, MirrorPath, Mirror2Path, Mirror3Path, ACompDegree, ADoZip, ADoValidate);
  }
end;

function GetTrapTime(s: string): TDateTime;
begin
  Result := StrToFloat(copy(s, 1, Pos(' - ', s) - 1))
end;

procedure TMainForm.InitAlarms;
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

procedure TMainForm.SetAlarms;
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

procedure TMainForm.MainTimerTimer(Sender: TObject);
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
    exit;
  end;
  if NoItemToExecute = True then
    exit;
  if LastItemExecuted then
    exit;
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

procedure TMainForm.TaskGridDrawColumnCell(Sender: TObject;
  const Rect: TRect; DataCol: Integer; Column: TColumn;
  State: TGridDrawState);
begin
  if DModule.AlarmTable.RecordCount = 0 then
    exit;
  if not (State = [gdSelected]) then
  begin
    if DataCol = 0 then
    begin
      if DModule.AlarmTableACTIVE.AsInteger = 1 then
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

procedure TMainForm.MenuTaskClick(Sender: TObject);
begin
  MenuActivate.Enabled := DModule.AlarmTableACTIVE.AsString = '0'; //Rev.2.0.1-2 ; this was "MenuActivate.Enabled:=DModule.AlarmTableACTIVE.AsInteger=0;"
  MenuDeactivate.Enabled := not MenuActivate.Enabled;
  MenuDeactivateAll.Enabled := not NoItemToExecute;
  if DModule.AlarmTable.RecordCount < 1 then
  begin
    MenuDelete.caption := 'Delete Task';
    MenuActivate.caption := 'Activate Task';
    MenuDeactivate.caption := 'Deactivate Task';
  end
  else
  begin
    MenuDelete.caption := 'Delete Task "' + DModule.AlarmTableTASKNAME.Value + ' "';
    MenuActivate.caption := 'Activate "' + DModule.AlarmTableTASKNAME.Value + ' "';
    MenuDeactivate.caption := 'Deactivate "' + DModule.AlarmTableTASKNAME.Value + ' "';
  end;
end;

procedure TMainForm.MenuDeleteClick(Sender: TObject);
begin
  if DModule.AlarmTable.RecordCount > 0 then
  begin
    if DModule.AlarmTableACTIVE.AsInteger = 0 then
    begin
      if MessageDlg('Do you want to DELETE' + DModule.AlarmTableTASKNAME.Value + '?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
      begin
        DeleteAlarmsFromTimeList;
        DModule.AlarmTable.Delete;
        InitAlarms;
      end;
    end
    else
      MessageDlg('Deactivate Task before Delete!', mtWarning, [mbOk], 0);
  end
  else
    MessageDlg('No Task to Delete!', mtError, [mbOk], 0);
end;

procedure TMainForm.TaskGridKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
    MenuEditTask.Click;
end;

procedure TMainForm.MenuPlanClick(Sender: TObject);
var
  TStr, CStr: string;
  cc, i, KPos, NPos: Integer;
var
  ts: TStrings;
begin
  if DModule.AlarmTable.RecordCount < 1 then
  begin
    MessageDlg('No backup task to be seen the backup executing times!', mtError, [mbOk], 0);
    exit;
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

procedure TMainForm.MenuAboutClick(Sender: TObject);
begin
  AboutForm := TAboutForm.Create(Self);
  try
    AboutForm.ShowModal;
  finally
    AboutForm.Free;
  end;
end;

procedure TMainForm.MenuTimeSettingsClick(Sender: TObject);
var
  s, TStr: string;
  cc, i, KPos, NPos: Integer;
begin
  if DModule.AlarmTable.RecordCount < 1 then
  begin
    MessageDlg('No backup task to be seen the backup time settings!', mtError, [mbOk], 0);
    exit;
  end;
  PlanListForm := TPlanListForm.Create(Self);
  PlanListForm.caption := 'Selected Backup Times of Task "' + DModule.AlarmTableTASKNAME.Value + ' "';
  PlanListForm.PlanList.Clear;
  PlanListForm.PlanList.items.BeginUpdate;

  GetAlarmTimeList(DModule.AlarmTableBOXES.Value);
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

procedure TMainForm.MenuLogClick(Sender: TObject);
var
  F: TextFile;
  s: string;
  TaskName, DBNameExt, LogDir, LogName, LogNameExt, LogPath: string;
  i: Integer;
begin
  if DModule.AlarmTable.RecordCount < 1 then
  begin
    MessageDlg('No task log to be viewed!', mtError, [mbOk], 0);
    exit;
  end;
  TaskName := FunctionsUnit.RemoveDatabaseSequenceTokens(DModule.AlarmTableTASKNAME.Value);
  DBNameExt := ExtractFileName(DModule.AlarmTableDBNAME.Value);
  LogName := 'LOG_' + TaskName;
  LogNameExt := 'LOG_' + TaskName + '.TXT';
  LogDir := DModule.OptionsTableLOGDIR.Value;
  LogPath := MakeFull(LogDir, LogNameExt);
  if (LogPath = '') then
  begin
    MessageDlg('LOG Directory is empty!', mtError, [mbOk], 0);
    exit;
  end
  else
    if DirectoryExists(LogDir) = False then
    begin
      MessageDlg('Given LOG Directory doesn''t exists!' + #13#10 + '(' + LogDir + ')', mtError, [mbOk], 0);
      exit;
    end;
  if FileExists(LogPath) = False then
  begin
    MessageDlg('LOG File for Task "' + TaskName + '" is not exist!' + #13#10 + 'Log File will be created after executing a backup task.', mtError, [mbOk], 0);
    exit;
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

procedure TMainForm.ActivateAllLeavedActive;
var
  i: Integer;
  gd, ld, Mirr, Mirr2, Mirr3: string;
  bValidMirrors: Boolean;
begin
  gd := trim(DModule.OptionsTablePATHTOGBAK.Value);
  ld := trim(DModule.OptionsTableLOGDIR.Value);
  if (gd = '') or (DirectoryExists(gd) = False) or (FileExists(gd + '\gbak.exe') = False) or
    (ld = '') or (DirectoryExists(ld) = False) then
  begin
    DeactivateAll;
    exit;
  end;
  DModule.AlarmTable.DisableControls;
  try
    DModule.AlarmTable.First;
    while not DModule.AlarmTable.eof do
    begin
      if DModule.AlarmTableACTIVE.AsInteger = 1 then
      begin
        if FileExistsRem(FunctionsUnit.RemoveDatabaseSequenceTokens(DModule.AlarmTableDBNAME.Value), DModule.AlarmTableLOCALCONN.AsBoolean) then
        begin
          if FunctionsUnit.IsValidDirectory(DModule.AlarmTableBACKUPDIR.Value) then
          begin
            bValidMirrors := FunctionsUnit.IsValidDirectory(DModule.AlarmTableMIRRORDIR.Value) and FunctionsUnit.IsValidDirectory(DModule.AlarmTableMIRROR2DIR.Value) and FunctionsUnit.IsValidDirectory(DModule.AlarmTableMIRROR3DIR.Value);
            bValidMirrors := (not ActiveTaskValidMirrorDirectory) or bValidMirrors;
            if bValidMirrors then
            begin
              DeleteCurrentTaskFromTimeList;
              GetAlarmTimeList(DModule.AlarmTableBOXES.Value);
              for i := 0 to AlarmTimeList.Count - 1 do
                TimeList.Add(AlarmTimeList[i]);
            end;
          end;
        end;
      end;
      DModule.AlarmTable.Next;
    end;
    InitAlarms;
  finally
    DModule.AlarmTable.First;
    DModule.AlarmTable.EnableControls;
  end;
end;

procedure TMainForm.ActivateOne;
var
  i: Integer;
  PD: TMesajForm;
  Mirr, Mirr2, Mirr3: string;
  bValidMirrors: Boolean;
begin
  PD := ShowProsesDlg('Tasks are being activating..'#13#10'Please Wait..', 'c', PrgName);
  DModule.AlarmTable.DisableControls;
  try
    if DModule.AlarmTableACTIVE.AsInteger = 0 then
    begin
      if FileExistsRem(FunctionsUnit.RemoveDatabaseSequenceTokens(DModule.AlarmTableDBNAME.Value), DModule.AlarmTableLOCALCONN.AsBoolean) then
      begin
        if FunctionsUnit.IsValidDirectory(DModule.AlarmTableBACKUPDIR.Value) then
        begin
          bValidMirrors := FunctionsUnit.IsValidDirectory(DModule.AlarmTableMIRRORDIR.Value) and FunctionsUnit.IsValidDirectory(DModule.AlarmTableMIRROR2DIR.Value) and FunctionsUnit.IsValidDirectory(DModule.AlarmTableMIRROR3DIR.Value);
          bValidMirrors := (not ActiveTaskValidMirrorDirectory) or bValidMirrors;
          if bValidMirrors then
          begin
            DeleteCurrentTaskFromTimeList;
            GetAlarmTimeList(DModule.AlarmTableBOXES.Value);
            for i := 0 to AlarmTimeList.Count - 1 do
              TimeList.Add(AlarmTimeList[i]);
            DModule.AlarmTable.edit;
            DModule.AlarmTableACTIVE.AsInteger := 1;
            DModule.AlarmTable.Post;
            InitAlarms;
          end;
        end
        else
          MessageDlg('This Task can''t be Activated'#13#10'Because Directory "' + DModule.AlarmTableBACKUPDIR.Value + '" is not Exists!', mtError, [mbOk], 0); //1.0.12
      end
      else
        MessageDlg('This Task can''t be Activated'#13#10 + 'Because Database "' + DModule.AlarmTableDBNAME.Value + '" is not exists!', mtError, [mbOk], 0); //1.0.12
    end;
  finally
    DModule.AlarmTable.EnableControls;
    HideProsesDlg(PD);
  end;
end;

procedure TMainForm.ActivateAll;
var
  i: Integer;
  Book: Integer;
  PD: TMesajForm;
  Mirr, Mirr2, Mirr3: string;
  bValidMirrors: Boolean;

  function ValidDirectory(ADir: string): Boolean;
  begin
    ADir := trim(ADir);
    Result := (ADir = '') or ((DirectoryExists(ADir) or IsFtpPath(ADir)));
  end;
begin
  PD := ShowProsesDlg('Tasks are being activating..'#13#10'Please Wait..', 'c', PrgName);
  DModule.AlarmTable.DisableControls;
  Book := DModule.AlarmTableTASKNO.AsInteger;
  try
    DModule.AlarmTable.First;
    while not DModule.AlarmTable.eof do
    begin
      if DModule.AlarmTableACTIVE.AsInteger = 0 then
      begin
        if FileExistsRem(FunctionsUnit.RemoveDatabaseSequenceTokens(DModule.AlarmTableDBNAME.Value), DModule.AlarmTableLOCALCONN.AsBoolean) then
        begin
          if DirectoryExists(DModule.AlarmTableBACKUPDIR.Value) then
          begin
            bValidMirrors := ValidDirectory(DModule.AlarmTableMIRRORDIR.Value) and ValidDirectory(DModule.AlarmTableMIRROR2DIR.Value) and ValidDirectory(DModule.AlarmTableMIRROR3DIR.Value);
            bValidMirrors := (not ActiveTaskValidMirrorDirectory) or bValidMirrors;
            if bValidMirrors then
            begin
              DeleteCurrentTaskFromTimeList;
              GetAlarmTimeList(DModule.AlarmTableBOXES.Value);
              for i := 0 to AlarmTimeList.Count - 1 do
                TimeList.Add(AlarmTimeList[i]);
              DModule.AlarmTable.edit;
              DModule.AlarmTableACTIVE.AsInteger := 1;
            end;
          end;
        end;
      end;
      DModule.AlarmTable.Next;
    end;
    DModule.AlarmTable.CheckBrowseMode;
    InitAlarms;
  finally
    DModule.AlarmTable.Locate('TASKNO', Book, []);
    DModule.AlarmTable.EnableControls;
    HideProsesDlg(PD);
  end;
end;

procedure TMainForm.MenuActivateAllClick(Sender: TObject);
var
  gd, ld: string;
begin
  if DModule.AlarmTable.RecordCount < 1 then
  begin
    MessageDlg('No backup task to be activated!', mtError, [mbOk], 0);
    exit;
  end;
  gd := trim(DModule.OptionsTablePATHTOGBAK.Value);
  if gd = '' then
  begin
    MessageDlg('GBAK Directory is empty!', mtError, [mbOk], 0);
    exit;
  end
  else
    if DirectoryExists(gd) = False then
    begin
      MessageDlg('Gbak Directory doesn''t exists!', mtError, [mbOk], 0);
      ModalResult := mrNone;
      exit;
    end
    else
      if FileExists(gd + '\gbak.exe') = False then
      begin
        MessageDlg('Gbak.exe cannot be found onto given Gbak Dir!', mtError, [mbOk], 0);
        ModalResult := mrNone;
        exit;
      end;
  ld := trim(DModule.OptionsTableLOGDIR.Value);
  if (ld = '') then
  begin
    MessageDlg('LOG Directory is empty!', mtError, [mbOk], 0);
    exit;
  end
  else
    if DirectoryExists(ld) = False then
    begin
      MessageDlg('Given LOG Directory doesn''t exists!' + #13#10 + '(' + ld + ')', mtError, [mbOk], 0);
      ModalResult := mrNone;
      exit;
    end;
  if MessageDlg('Only error-free-defined tasks will be activated !!'#13#10 +
    '(But no error message will be shown !)'#13#10#13#10 +
    'Do you want to ACTIVATE all deactive tasks?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    ActivateAll;
  end;
end;

procedure TMainForm.DeactivateAll;
var
  Book: Integer;
  PD: TMesajForm;
begin
  PD := ShowProsesDlg('Tasks are being deactivating..'#13#10'Please Wait..', 'c', PrgName);
  DModule.AlarmTable.DisableControls;
  Book := DModule.AlarmTableTASKNO.AsInteger;
  try
    DModule.AlarmTable.First;
    while not DModule.AlarmTable.eof do
    begin
      if DModule.AlarmTableACTIVE.AsInteger = 1 then
      begin
        DeleteAlarmsFromTimeList;
        DModule.AlarmTable.edit;
        DModule.AlarmTableACTIVE.AsInteger := 0;
      end;
      DModule.AlarmTable.Next;
    end;
    DModule.AlarmTable.CheckBrowseMode;
    InitAlarms;
  finally
    DModule.AlarmTable.Locate('TASKNO', Book, []);
    DModule.AlarmTable.EnableControls;
    HideProsesDlg(PD);
  end;
end;

procedure TMainForm.MenuDeactivateAllClick(Sender: TObject);
begin
  if MessageDlg('Do you want to activate All deactive tasks ?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    DeactivateAll;
  end;
end;

procedure TMainForm.MenuBackupNowClick(Sender: TObject);
var
  s, TN, GP, UN, PW, DN, DD, MD, MD2, MD3: string; //1.0.1 bd,mxd,ld
  DoVal, ZBU: Boolean;
  i: Integer;
  passw: string;
begin
  if DModule.AlarmTable.RecordCount < 1 then
  begin
    MessageDlg('No backup task to execute!', mtError, [mbOk], 0);
    ModalResult := mrNone;
    exit;
  end;

  ManualBackupForm := TManualBackupForm.Create(Self);
  ManualBackupForm.EditTaskName.Text := DModule.AlarmTableTASKNAME.Value;
  ManualBackupForm.EditDatabaseName.Text := DModule.AlarmTableDBNAME.Value;
  ManualBackupForm.EditDestinationDir.Text := DModule.AlarmTableBACKUPDIR.Value;
  ManualBackupForm.EditMirrorDir.Text := DModule.AlarmTableMIRRORDIR.Value;
  ManualBackupForm.EditMirror2Dir.Text := DModule.AlarmTableMIRROR2DIR.Value;
  ManualBackupForm.EditMirror3Dir.Text := DModule.AlarmTableMIRROR3DIR.Value;
  ManualBackupForm.EditGBakDir.Text := DModule.OptionsTablePATHTOGBAK.Value;
  ManualBackupForm.EditUserName.Text := DModule.AlarmTableUSER.Value;
  DecodeData(DModule.AlarmTablePASSWORD.Value, passw);
  ManualBackupForm.EditPassword.Text := passw;
  ManualBackupForm.EditCompDeg.Text := DModule.AlarmTableCOMPRESS.Value;
  ManualBackupForm.EditPriority.Text := DModule.OptionsTableBPRIORTY.Value;
  ManualBackupForm.EditMailTo.Text := DModule.AlarmTableMAILTO.Value;
  s := DModule.AlarmTableBOPTIONS.Value;
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
        DModule.AlarmTableCOMPRESS.Value, ZBU, DoVal);
    end;
  finally
    ManualBackupForm.Free;
  end;
end;

procedure TMainForm.PopMenuShowClick(Sender: TObject);
begin
  if MainForm.Visible = False then
  begin
    Application.ShowMainForm := True;
    MainForm.Show;
    MainFormHidden := False;
  end
  else
    screen.ActiveForm.SetFocus;
end;

procedure TMainForm.PopMenuHideClick(Sender: TObject);
begin
  if screen.ActiveForm = nil then
    exit;
  if screen.ActiveForm = MainForm then
  begin
    MainForm.Hide;
    MainFormHidden := True;
  end
  else
    MessageDlg('Close window "' + screen.ActiveForm.caption + '" first!', mtError, [mbOk], 0);
end;

// Below codes hides mainform when minimize button is pressed.
// Author   : Madshi
// Web Site : http://www.madshi.net/

procedure TMainForm.SysCommand(var Message: TWMSYSCOMMAND);
begin
  if Message.CmdType and $FFF0 = SC_MINIMIZE then
    PopMenuHide.Click
  else
    inherited;
end;

procedure TMainForm.MenuViewClick(Sender: TObject);
begin
  MenuPlan.caption := 'Backup Executing Times in Today (' + DateToStr(Now) + ')';
  if DModule.AlarmTable.RecordCount < 1 then
  begin
    MenuTimeSettings.caption := 'Backup Time Settings of Current Task';
    MenuLog.caption := 'LOG of Selected Task';
  end
  else
  begin
    MenuTimeSettings.caption := 'Backup Time Settings of Task "' + DModule.AlarmTableTASKNAME.Value + ' "';
    MenuLog.caption := 'LOG of Task "' + DModule.AlarmTableTASKNAME.Value + '"';
  end;
end;

procedure TMainForm.MenuHelpHelpClick(Sender: TObject);
var
  HelpPath: string;
  res: Integer;
begin
  HelpPath := GetCurrentDir + '\fibs.hlp';
  res := ShellExecute(Handle, 'open', PChar(HelpPath), nil, nil, SW_SHOWNORMAL);
  if res = 0 then
    MessageDlg('Error opening help file "' + HelpPath + '"'#13#10'The operating system is out of memory or resources.', mtError, [mbOk], 0)
  else
    if res = SE_ERR_FNF then
      MessageDlg('Error opening help file !!'#13#10'Help file "' + HelpPath + '" couldn''t found.', mtError, [mbOk], 0)
    else
      if res = SE_ERR_OOM then
        MessageDlg('Error opening help file "' + HelpPath + '"'#13#10'There was not enough memory to complete the operation.', mtError, [mbOk], 0)
      else
        if res = SE_ERR_SHARE then
          MessageDlg('Error opening help file "' + HelpPath + '"'#13#10'A sharing violation occurred.', mtError, [mbOk], 0);
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

procedure TMainForm.FormShow(Sender: TObject);
begin
  // use primary monitor
  MoveWindowToMonitor(Handle, 1);
end;

procedure TMainForm.TrayTimerTimer(Sender: TObject);
var
  si: Boolean;
begin
  si := Shell_NotifyIcon(NIM_ADD, @NotifyIconData);
  if si = True then
    TrayTimer.Enabled := False;
end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if BackupIsService then
    Action := caNone
  else
    Action := caFree;
end;

procedure TMainForm.PopMenuStopServiceClick(Sender: TObject);
begin
  if BackupIsService then
    PostThreadMessage(BackupService.ServiceThread.ThreadID, WM_QUIT, 0, 0)
  else
    Application.Terminate;
end;

procedure TMainForm.PopupMenu1Popup(Sender: TObject);
begin
  if BackupIsService then
    PopMenuStopService.Visible := True
  else
    PopMenuStopService.Visible := False;
  PopMenuExit.Visible := not PopMenuStopService.Visible;
end;

procedure TMainForm.miTaskDuplicateClick(Sender: TObject);
begin
  DModule.DuplicateTask(False);
  Self.MenuEditTaskClick(nil);
end;

procedure TMainForm.PopupMenu2Popup(Sender: TObject);
begin
  Self.miTaskDuplicate.Enabled := DModule.AlarmTable.RecordCount > 0;
end;

end.

