
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

unit TaskForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Spin, CheckLst, DBCtrls, ComCtrls, EditBtn, Mask, StdCtrls,
  ExtCtrls, Buttons, Menus, FunctionsUnit, FibsData, JvExControls,
  JvComponent, JvGroupHeader, JvExStdCtrls, JvGroupBox, JvLabel, JvEdit,
  JvExMask, JvToolEdit, JvCheckBox, JvCombobox;

type
  TfmTask = class(TForm)
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label3: TLabel;
    Label11: TLabel;
    pcOptions: TPageControl;
    tsBackupTime: TTabSheet;
    tsBackupOptions: TTabSheet;
    lbTaskActive: TLabel;
    Label1: TLabel;
    lbPriority: TLabel;
    Label10: TLabel;
    Label16: TLabel;
    tsOtherOptions: TTabSheet;
    ghHeader: TJvGroupHeader;
    JvGroupBox1: TJvGroupBox;
    clbTimeHours: TCheckListBox;
    JvGroupBox2: TJvGroupBox;
    clbTimeMinutes: TCheckListBox;
    JvGroupBox3: TJvGroupBox;
    clbBackupOptions: TCheckListBox;
    JvGroupBox4: TJvGroupBox;
    Label4: TLabel;
    JvGroupBox5: TJvGroupBox;
    Label2: TLabel;
    JvGroupBox6: TJvGroupBox;
    JvGroupBox7: TJvGroupBox;
    JvLabel1: TJvLabel;
    btOk: TButton;
    btCancel: TButton;
    edTaskName: TJvEdit;
    edDatabaseName: TJvFilenameEdit;
    edBackupDir: TJvDirectoryEdit;
    edMirrorDir1: TJvDirectoryEdit;
    edMirrorDir2: TJvDirectoryEdit;
    edMirrorDir3: TJvDirectoryEdit;
    cbLocalConnection: TJvCheckBox;
    edUserName: TJvEdit;
    edPassword: TJvEdit;
    cbValidadeDatabase: TJvCheckBox;
    cbCompressBackup: TJvCheckBox;
    cbCompressLevel: TJvComboBox;
    cbPolicyType: TJvComboBox;
    edPolicyValue: TJvEdit;
    cbPolicyDeleteOfCBackup: TJvCheckBox;
    edMailTo: TJvEdit;
    edExternalFile: TJvFilenameEdit;
    cbUseBackupNameParameter: TJvCheckBox;
    cbExternalShowWindow: TJvCheckBox;
    procedure FormShow(Sender: TObject);
    procedure btOkClick(Sender: TObject);
    procedure edPolicyValueKeyPress(Sender: TObject; var Key: Char);
    procedure cbCompressBackupClick(Sender: TObject);
    procedure edTaskNameKeyPress(Sender: TObject; var Key: Char);
    procedure edDatabaseNameChange(Sender: TObject);
    procedure cbLocalConnectionClick(Sender: TObject);
  private
    bNewTask: Boolean;
    { Private declarations }
  public
    { Public declarations }
    procedure LoadTask(FibsRef: TdmFibs);
    procedure SaveTask(FibsRef: TdmFibs);
    procedure SetDefault;

    class function EditTask(AOwner: TComponent; FibsRef: TdmFibs; NewTask: Boolean): Boolean;
  end;

var
  fmTask: TfmTask;

implementation

{$R *.dfm}
uses StrUtils, DateUtils, UDFConst, UDFPresets, MesajUnit, DB, UDFValidation;

procedure TfmTask.FormShow(Sender: TObject);
begin
  if Self.bNewTask then
    Self.Caption := 'New Backup Task'
  else
    Self.Caption := 'Edit Backup Task';
  Self.ghHeader.Caption := Self.Caption;
  Self.pcOptions.ActivePage := Self.tsBackupTime;
end;

class function TfmTask.EditTask(AOwner: TComponent; FibsRef: TdmFibs;
  NewTask: Boolean): Boolean;
var
  fmTask: TfmTask;
begin
  fmTask := TfmTask.Create(AOwner);
  try
    fmTask.bNewTask := NewTask;
    fmTask.LoadTask(FibsRef);
    Result := fmTask.ShowModal = mrOk;
    if Result then
      fmTask.SaveTask(FibsRef);
  finally
    fmTask.Release;
  end;
end;

procedure TfmTask.LoadTask(FibsRef: TdmFibs);
var
  i: Integer;
  s, T: string; //Saat, Dakika Checklist stringi
  sTime: string;
  sOptions: string;
begin
  Self.edTaskName.Text := FibsRef.qrTaskTASKNAME.Value;
  Self.edDatabaseName.Text := FibsRef.qrTaskDBNAME.Value;
  Self.cbLocalConnection.Checked := FibsRef.qrTaskLOCALCONN.AsBoolean;
  Self.edBackupDir.Text := FibsRef.qrTaskBACKUPDIR.Value;
  Self.edMirrorDir1.Text := FibsRef.qrTaskMIRRORDIR.Value;
  Self.edMirrorDir2.Text := FibsRef.qrTaskMIRROR2DIR.Value;
  Self.edMirrorDir3.Text := FibsRef.qrTaskMIRROR3DIR.Value;
  Self.edUserName.Text := FibsRef.qrTaskUSER.Value;
  Self.edPassword.Text := FibsRef.qrTaskPASSWORD.Value;
  Self.lbPriority.Caption := 'Priority ' + FibsRef.qrOptionBPRIORTY.Value;
  Self.lbTaskActive.Visible := FibsRef.qrTaskACTIVE.AsInteger = 1;
  sTime := FibsRef.qrTaskBOXES.Value;
  for i := 1 to 24 do
    if (sTime[i] = '1') then
      Self.clbTimeHours.State[i - 1] := cbChecked
    else
      Self.clbTimeHours.State[i - 1] := cbUnChecked;
  for i := 25 to 84 do
    if (sTime[i] = '1') then
      Self.clbTimeMinutes.State[i - 25] := cbChecked
    else
      Self.clbTimeMinutes.State[i - 25] := cbUnChecked;
  sOptions := FibsRef.qrTaskBOPTIONS.Value;
  for i := 0 to TotalGBakOptions - 1 do
    if (sOptions[i + 1] = '1') then
      Self.clbBackupOptions.State[i] := cbChecked
    else
      Self.clbBackupOptions.State[i] := cbUnChecked;
  Self.cbValidadeDatabase.Checked := FibsRef.qrTaskDOVAL.AsBoolean;
  Self.cbCompressBackup.Checked := FibsRef.qrTaskZIPBACKUP.AsBoolean;
  Self.cbCompressLevel.ItemIndex := Self.cbCompressLevel.Items.IndexOf(FibsRef.qrTaskCOMPRESS.Value);
  Self.edPolicyValue.Text := FibsRef.qrTaskPVAL.Value;
  Self.cbPolicyType.ItemIndex := Self.cbPolicyType.Items.IndexOf(FibsRef.qrTaskPUNIT.Value);
  Self.cbPolicyDeleteOfCBackup.Checked := FibsRef.qrTaskDELETEALL.Value = 'T';
  Self.edMailTo.Text := FibsRef.qrTaskMAILTO.Value;
  Self.edExternalFile.Text := FibsRef.qrTaskBATCHFILE.Value;
  Self.cbUseBackupNameParameter.Checked := FibsRef.qrTaskUSEPARAMS.AsBoolean;
  Self.cbExternalShowWindow.Checked := FibsRef.qrTaskSHOWBATCHWIN.AsBoolean;
  Self.cbLocalConnectionClick(nil);
  Self.btOk.Enabled := (FibsRef.qrTaskACTIVE.AsInteger = 0);
end;

procedure TfmTask.SaveTask(FibsRef: TdmFibs);
var
  i: Integer;
  s, T: string; //Saat, Dakika Checklist stringi
  sTime: string;
  sOptions: string;
begin
  if Self.bNewTask then
    FibsRef.qrTask.Append
  else
    FibsRef.qrTask.Edit;
  FibsRef.qrTaskTASKNAME.Value := Self.edTaskName.Text;
  FibsRef.qrTaskDBNAME.Value := Self.edDatabaseName.Text;
  FibsRef.qrTaskLOCALCONN.AsBoolean := Self.cbLocalConnection.Checked;
  FibsRef.qrTaskBACKUPDIR.Value := Self.edBackupDir.Text;
  FibsRef.qrTaskMIRRORDIR.Value := Self.edMirrorDir1.Text;
  FibsRef.qrTaskMIRROR2DIR.Value := Self.edMirrorDir2.Text;
  FibsRef.qrTaskMIRROR3DIR.Value := Self.edMirrorDir3.Text;
  FibsRef.qrTaskUSER.Value := Self.edUserName.Text;
  FibsRef.qrTaskPASSWORD.Value := Self.edPassword.Text;
  sTime := '';
  for i := 1 to 24 do
    if Self.clbTimeHours.State[i - 1] = cbChecked then
      sTime := sTime + '1'
    else
      sTime := sTime + '0';
  for i := 25 to 84 do
    if Self.clbTimeMinutes.State[i - 25] = cbChecked then
      sTime := sTime + '1'
    else
      sTime := sTime + '0';
  FibsRef.qrTaskBOXES.Value := sTime;
  sOptions := '';
  for i := 0 to TotalGBakOptions - 1 do
    if Self.clbBackupOptions.State[i] = cbChecked then
      sOptions := sOptions + '1'
    else
      sOptions := sOptions + '0';
  FibsRef.qrTaskBOPTIONS.Value := sOptions;
  FibsRef.qrTaskDOVAL.AsBoolean := Self.cbValidadeDatabase.Checked;
  FibsRef.qrTaskZIPBACKUP.AsBoolean := Self.cbCompressBackup.Checked;
  FibsRef.qrTaskCOMPRESS.Value := Self.cbCompressLevel.Text;
  FibsRef.qrTaskPVAL.Value := Self.edPolicyValue.Text;
  FibsRef.qrTaskPUNIT.Value := Self.cbPolicyType.Text; 
  FibsRef.qrTaskDELETEALL.Value := IfThen(Self.cbPolicyDeleteOfCBackup.Checked, 'T', 'F');
  FibsRef.qrTaskMAILTO.Value := Self.edMailTo.Text;
  FibsRef.qrTaskBATCHFILE.Value := Self.edExternalFile.Text;
  FibsRef.qrTaskUSEPARAMS.AsBoolean := Self.cbUseBackupNameParameter.Checked;
  FibsRef.qrTaskSHOWBATCHWIN.AsBoolean := Self.cbExternalShowWindow.Checked;
  if Self.bNewTask then
    FibsRef.qrTaskBCOUNTER.AsInteger := 0;
  FibsRef.qrTask.Post;
end;

procedure TfmTask.btOkClick(Sender: TObject);
var
  vaValidation: TValidation;
  i, kk: Integer;
  iHourCount: Integer;
  iMinCount: Integer;

  procedure ValidateEmpty(Value: string; MessageText: string);
  begin
    if Length(Trim(Value)) = 0 then
      vaValidation.Add(MessageText, vtWarning);
  end;

  procedure ValidateFile(Value: string; MessageText: string);
  begin
    if not SysUtils.FileExists(Value) then
      vaValidation.Add(MessageText, vtWarning);
  end;

  procedure ValidateDir(Value: string; MessageText: string);
  begin
    if not SysUtils.DirectoryExists(Value) then
      vaValidation.Add(MessageText, vtWarning);
  end;

  procedure ValidateMirror(Mirror: string; Number: Integer);
  begin
    ValidateEmpty(Mirror, 'Mirror directory ' + IntToStr(Number) + ' cannot be empty!');
    if UDFPresets.IsFtpPath(Mirror) then
    begin
      if not UDFPresets.CheckFtpPath(Mirror) then
        vaValidation.Add('FTP Mirror ' + IntToStr(Number) + ' is not valid', vtWarning);
    end
    else
    begin
      ValidateDir(Mirror, 'Mirror directory ' + IntToStr(Number) + ' is not exist!');
      if AnsiSameText(Self.edBackupDir.Text, Mirror) then
        vaValidation.Add('Mirror directory must be different than Backup Directory!', vtWarning);
    end;
  end;
begin
  vaValidation := TValidation.Create(Self);
  try
    ValidateEmpty(Self.edTaskName.Text, 'Task Name cannot be empty!');
    ValidateEmpty(Self.edDatabaseName.Text, 'Path to database cannot be empty!');
    if Self.cbLocalConnection.Checked then
      ValidateFile(Self.edDatabaseName.Text, 'Database doesn''t exist onto given path!');
    ValidateEmpty(Self.edBackupDir.Text, 'Backup Directory cannot be empty!');
    ValidateDir(Self.edBackupDir.Text, 'Backup directory is not exist!');
    if UDFConst.ActiveTaskValidMirrorDirectory then
    begin
      ValidateMirror(Self.edMirrorDir1.Text, 1);
      ValidateMirror(Self.edMirrorDir2.Text, 2);
      ValidateMirror(Self.edMirrorDir3.Text, 3);
    end;
    ValidateEmpty(Self.edUserName.Text, 'User name cannot be empty!');
    ValidateEmpty(Self.edPassword.Text, 'Password cannot be empty!');
    iHourCount := 0;
    for i := 0 to 23 do
      if Self.clbTimeHours.Checked[i] then
        Inc(iHourCount);
    if iHourCount = 0 then
      vaValidation.Add('At least one Hour must be checked!', vtWarning);
    iMinCount := 0;
    for i := 0 to 59 do
      if Self.clbTimeMinutes.Checked[i] then
        Inc(iMinCount);
    if iMinCount = 0 then
      vaValidation.Add('At least one Minute must be checked!', vtWarning);
    case Self.cbPolicyType.ItemIndex of
      1:
        begin
          if StrToIntDef(Self.edPolicyValue.Text, 0) > 24 then
            vaValidation.Add('You can not enter greater values then 24 as preserving time-limit. If you need to, please select "Day''s Copies" item.', vtWarning);
        end;
      2:
        begin
          if StrToIntDef(Self.edPolicyValue.Text, 0) > 30 then
            vaValidation.Add('You can not enter greater values then 30 as preserving time-limit. If you need to, please select "Month''s Copies" item.', vtWarning);
        end;
      3:
        begin
          if StrToIntDef(Self.edPolicyValue.Text, 0) > 12 then
            vaValidation.Add('You can not enter greater values then 12 as preserving time-limit.', vtWarning);
        end;
    end;
    if Length(Trim(Self.edExternalFile.Text)) > 0 then
      ValidateFile(Self.edExternalFile.Text, 'File "' + Self.edExternalFile.Text + '" is not exist!');
  finally
    vaValidation.Free;
  end;
end;

procedure TfmTask.edPolicyValueKeyPress(Sender: TObject; var Key: Char);
begin
  UDFPresets.PozitiveIntegerEditKeyPress(Sender, Key);
end;

procedure TfmTask.cbCompressBackupClick(Sender: TObject);
begin
  Self.cbCompressLevel.Enabled := Self.cbCompressBackup.State = cbChecked;
end;

procedure TfmTask.edTaskNameKeyPress(Sender: TObject; var Key: Char);
begin
  if Key in [',', '/', '\', '!', '*', '{', '(', ')', '}', '"', '''', '%'] then
  begin
    MessageDlg('You cannot use illegal chars in Task Name!' + #13#10 + ' / \! * { ( ) } " '' %', mtError, [mbOk], 0);
    Key := #0;
  end;
end;

procedure TfmTask.edDatabaseNameChange(Sender: TObject);
var
  s: string;
  i: Integer;
begin
  s := Self.edDatabaseName.Text;
  i := Length(s);
  if ((i > 0) and (s[1] = '"') and (s[i] = '"')) then
    Self.edDatabaseName.Text := copy(s, 2, i - 2);
end;

procedure TfmTask.cbLocalConnectionClick(Sender: TObject);
begin
  Self.edDatabaseName.ShowButton := Self.cbLocalConnection.State = cbChecked;
end;

procedure TfmTask.SetDefault;
begin
  Self.edTaskName.Text := '';
  Self.cbLocalConnection.Checked := True;
  Self.edDatabaseName.Text := '';
  Self.edBackupDir.Text := '';
  Self.edMirrorDir1.Text := '';
  Self.edMirrorDir2.Text := '';
  Self.edMirrorDir3.Text := '';
  Self.edUserName.Text := '';
  Self.edPassword.Text := '';
  Self.clbTimeHours.ClearSelection;
  Self.clbTimeMinutes.ClearSelection;
  Self.clbBackupOptions.ClearSelection;
  Self.clbBackupOptions.Checked[0] := True;
  Self.clbBackupOptions.Checked[1] := True;
  Self.clbBackupOptions.Checked[2] := True;
  Self.cbValidadeDatabase.Checked := False;
  Self.cbCompressBackup.Checked := False;
  Self.cbCompressLevel.ItemIndex := 0;
  Self.edPolicyValue.Text := '';
  Self.cbPolicyType.ItemIndex := 0;
  Self.cbPolicyDeleteOfCBackup.Checked := False;
  Self.edMailTo.Text := '';
  Self.edExternalFile.Text := '';
  Self.cbUseBackupNameParameter.Checked := False;
  Self.cbExternalShowWindow.Checked := False;
end;

end.

