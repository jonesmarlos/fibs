
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

unit EditTaskUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Spin, CheckLst, DBCtrls, ComCtrls, EditBtn, Mask, StdCtrls,
  ExtCtrls, Buttons, Menus, FunctionsUnit;

type
  TEditTaskForm = class(TForm)
    ButtonOK: TBitBtn;
    BitBtn2: TBitBtn;
    Label5: TLabel;
    Label6: TLabel;
    EditDestinationDir: TDirectoryEditBtn;
    EditDatabaseName: TFileEditBtn;
    Label7: TLabel;
    Label8: TLabel;
    EditUserName: TDBEdit;
    EditPassword: TDBEdit;
    Label3: TLabel;
    EditMirrorDir: TDirectoryEditBtn;
    Label11: TLabel;
    EditTaskDef: TDBEdit;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    Bevel4: TBevel;
    Label9: TLabel;
    Bevel5: TBevel;
    Label12: TLabel;
    CGHours: TCheckListBox;
    CGMinutes: TCheckListBox;
    TabSheet3: TTabSheet;
    LabelState: TLabel;
    CLBGbakOptions: TCheckListBox;
    DBEdit1: TDBEdit;
    Label13: TLabel;
    Label14: TLabel;
    DBCheckBox1: TDBCheckBox;
    Label2: TLabel;
    Label15: TLabel;
    Bevel2: TBevel;
    Bevel6: TBevel;
    Bevel7: TBevel;
    DBCUnit: TDBComboBox;
    DBEAdet: TDBEdit;
    DBCheckBox2: TDBCheckBox;
    Label1: TLabel;
    DBComboBox1: TDBComboBox;
    Label4: TLabel;
    LabelPriorty: TLabel;
    Label10: TLabel;
    EditMirror2Dir: TDirectoryEditBtn;
    DBCBConnection: TDBCheckBox;
    Label16: TLabel;
    EditMirror3Dir: TDirectoryEditBtn;
    DBCheckBoxValidate: TDBCheckBox;
    TabSheet2: TTabSheet;
    Bevel1: TBevel;
    Label17: TLabel;
    EditMailTo: TDBEdit;
    Label19: TLabel;
    Bevel8: TBevel;
    Label20: TLabel;
    FileEditBtnBatchFile: TFileEditBtn;
    DBCheckBox3: TDBCheckBox;
    DBCheckBox4: TDBCheckBox;
    procedure ButtonOKClick(Sender: TObject);
    procedure DBEAdetKeyPress(Sender: TObject; var Key: Char);
    procedure FormShow(Sender: TObject);
    procedure DBCheckBox1Click(Sender: TObject);
    procedure EditTaskDefKeyPress(Sender: TObject; var Key: Char);
    procedure EditDatabaseNameChange(Sender: TObject);
    procedure EditDatabaseNameBeforeBtnClick(Sender: TObject);
    procedure EditDestinationDirBeforeBtnClick(Sender: TObject);
    procedure DBCBConnectionClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  EditTaskForm: TEditTaskForm;

implementation

{$R *.dfm}
uses StrUtils, DateUtils, ConstUnit, DModuleUnit, PresetsUnit, MesajUnit;

procedure TEditTaskForm.ButtonOKClick(Sender: TObject);
var
  i, kk: Integer;
begin
  if trim(EditTaskDef.Text) = '' then
  begin
    MessageDlg('Task Name cannot be empty!', mtError, [mbOk], 0);
    ModalResult := mrNone;
    exit;
  end;
  if DModule.AlarmTableLOCALCONN.AsBoolean = True then
  begin
    if trim(EditDatabaseName.Text) = '' then
    begin
      MessageDlg('Path to database cannot be empty!', mtError, [mbOk], 0);
      ModalResult := mrNone;
      exit;
    end
    else
      if FileExists(trim(FunctionsUnit.RemoveDatabaseSequenceTokens(EditDatabaseName.Text))) = False then
      begin
        MessageDlg('Database doesn''t exist onto given path!', mtError, [mbOk], 0);
        ModalResult := mrNone;
        exit;
      end;
  end;

  if trim(EditDestinationDir.Text) = '' then
  begin
    MessageDlg('Backup Directory cannot be empty!', mtError, [mbOk], 0);
    ModalResult := mrNone;
    exit;
  end
  else
    if DirectoryExists(EditDestinationDir.Text) = False then
    begin
      MessageDlg('Backup directory is not exist !', mtError, [mbOk], 0);
      ModalResult := mrNone;
      exit;
    end;
  if ActiveTaskValidMirrorDirectory then
  begin
    if IsFtpPath(EditMirrorDir.Text) = False then
    begin
      if trim(EditMirrorDir.Text) = '' then
      begin
        //  MesajDlg('Mirror path is empty !'#13#10'Mirroring has been disabled !',  'c',PrgName);
        // dikkat !!! mrNone yok ..exit yok..
      end
      else
        if DirectoryExists(EditMirrorDir.Text) = False then
        begin
          MessageDlg('Mirror directory is not exist!', mtError, [mbOk], 0);
          ModalResult := mrNone;
          exit;
        end
        else
          if (EditMirrorDir.Text = EditDestinationDir.Text) then
          begin
            MessageDlg('Mirror directory must be different than Backup Directory!', mtError, [mbOk], 0);
            ModalResult := mrNone;
            exit;
          end;
    end
    else
    begin
      if CheckFtpPath(EditMirrorDir.Text) = False then
      begin
        ModalResult := mrNone;
        exit;
      end;
    end;

    if IsFtpPath(EditMirror2Dir.Text) = False then
    begin
      if trim(EditMirror2Dir.Text) = '' then
      begin
        //    MesajDlg('Mirror path is empty !'#13#10'Mirroring has been disabled !',  'c',PrgName);
        // dikkat !!! mrNone yok ..exit yok..
      end
      else
        if DirectoryExists(EditMirror2Dir.Text) = False then
        begin
          MessageDlg('Mirror directory 2 is not exist!', mtError, [mbOk], 0);
          ModalResult := mrNone;
          exit;
        end
        else
          if (EditMirror2Dir.Text = EditDestinationDir.Text) then
          begin
            MessageDlg('Mirror directory 2 must be different than Backup Directory!', mtError, [mbOk], 0);
            ModalResult := mrNone;
            exit;
          end;
    end
    else
    begin
      if CheckFtpPath(EditMirror2Dir.Text) = False then
      begin
        ModalResult := mrNone;
        exit;
      end;
    end;

    if IsFtpPath(EditMirror3Dir.Text) = False then
    begin
      if trim(EditMirror3Dir.Text) = '' then
      begin
        // MesajDlg('Mirror path is empty !'#13#10'Mirroring has been disabled !',  'c',PrgName);
        // dikkat !!! mrNone yok ..exit yok..
      end
      else
        if DirectoryExists(EditMirror3Dir.Text) = False then
        begin
          MessageDlg('Mirror directory 3 is not exist!', mtError, [mbOk], 0);
          ModalResult := mrNone;
          exit;
        end
        else
          if (EditMirror3Dir.Text = EditDestinationDir.Text) then
          begin
            MessageDlg('Mirror directory 3 must be different than Backup Directory!', mtError, [mbOk], 0);
            ModalResult := mrNone;
            exit;
          end;
    end
    else
    begin
      if CheckFtpPath(EditMirror3Dir.Text) = False then
      begin
        ModalResult := mrNone;
        exit;
      end;
    end;
  end;

  if EditUserName.Text = '' then
  begin
    MessageDlg('User name cannot be empty!', mtError, [mbOk], 0);
    ModalResult := mrNone;
    exit;
  end;
  if EditPassword.Text = '' then
  begin
    MessageDlg('Password cannot be empty !', mtError, [mbOk], 0);
    ModalResult := mrNone;
    exit;
  end;
  for i := 0 to 23 do
    if CGHours.checked[i] = True then
    begin
      kk := 1;
      break;
    end
    else
      kk := 0;
  if kk = 0 then
  begin
    MessageDlg('At least one Hour must be checked!', mtError, [mbOk], 0);
    ModalResult := mrNone;
    exit;
  end;
  for i := 0 to 59 do
    if CGMinutes.checked[i] = True then
    begin
      kk := 1;
      break;
    end
    else
      kk := 0;
  if kk = 0 then
  begin
    MessageDlg('At least one Minute must be checked!', mtError, [mbOk], 0);
    ModalResult := mrNone;
    exit;
  end;

  case DBCUnit.items.IndexOf(DBCUnit.Text) of
    1:
      if StrToInt(DBEAdet.Text) > 24 then
      begin
        MessageDlg('You can not enter greater values then 24 as preserving time-limit. If you need to, please select "Day''s Copies" item.', mtError, [mbOk], 0);
        ModalResult := mrNone;
        exit;
      end;
    2:
      if StrToInt(DBEAdet.Text) > 30 then
      begin
        MessageDlg('You can not enter greater values then 30 as preserving time-limit. If you need to, please select "Month''s Copies" item.', mtError, [mbOk], 0);
        ModalResult := mrNone;
        exit;
      end;
    3:
      if StrToInt(DBEAdet.Text) > 12 then
      begin
        MessageDlg('You can not enter greater values then 12 as preserving time-limit.', mtError, [mbOk], 0);
        ModalResult := mrNone;
        exit;
      end;
  end;

  if trim(FileEditBtnBatchFile.Text) <> '' then
  begin
    if FileExists(trim(FileEditBtnBatchFile.Text)) = False then
    begin
      MessageDlg('ERROR !!'#13#10'File "' + FileEditBtnBatchFile.Text + '" is not exist!', mtError, [mbOk], 0);
      ModalResult := mrNone;
      exit;
    end;
  end;
end;

procedure TEditTaskForm.DBEAdetKeyPress(Sender: TObject; var Key: Char);
begin
  PozitiveIntegerEditKeyPress(Sender, Key);
end;

procedure TEditTaskForm.FormShow(Sender: TObject);
begin
  PageControl1.ActivePageIndex := 0;
  LabelPriorty.caption := 'Priority ' + DModule.OptionsTableBPRIORTY.Value;
end;

procedure TEditTaskForm.DBCheckBox1Click(Sender: TObject);
begin
  DBComboBox1.Enabled := DBCheckBox1.State = cbChecked;
end;

procedure TEditTaskForm.EditTaskDefKeyPress(Sender: TObject;
  var Key: Char);
begin
  if Key in [',', '/', '\', '!', '*', '{', '(', ')', '}', '"', '''', '%'] then
  begin
    MessageDlg('You cannot use illegal chars in Task Name!'#13#10'/ , \ ! { ( ) } " '' %', mtError, [mbOk], 0);
    Key := #0;
  end;
end;

procedure TEditTaskForm.EditDatabaseNameChange(Sender: TObject);
var
  s: string;
  i: Integer;
begin
  s := EditDatabaseName.Text;
  i := Length(s);
  if ((i > 0) and (s[1] = '"') and (s[i] = '"')) then
    EditDatabaseName.Text := copy(s, 2, i - 2);
end;

procedure TEditTaskForm.EditDatabaseNameBeforeBtnClick(Sender: TObject);
begin
  if trim(EditDatabaseName.Text) = '' then
    exit;
  if FileExists(EditDatabaseName.Text) = False then
    MessageDlg('File "' + EditDatabaseName.Text + '" is not Exists!', mtError, [mbOk], 0);
end;

procedure TEditTaskForm.EditDestinationDirBeforeBtnClick(Sender: TObject);
begin
  if trim(EditDestinationDir.Text) = '' then
    exit;
  if DirectoryExists(EditDestinationDir.Text) = False then
    MessageDlg('Directory "' + EditDestinationDir.Text + '" is not Exists!', mtError, [mbOk], 0);
end;

procedure TEditTaskForm.DBCBConnectionClick(Sender: TObject);
begin
  EditDatabaseName.Button.Enabled := DBCBConnection.State = cbChecked;
end;

procedure TEditTaskForm.FormCreate(Sender: TObject);
begin
  FileEditBtnBatchFile.OpenDialog.Filter := 'Batch Files (*.BAT)|*.BAT|Exe Files (*.EXE)|*.EXE|All files (*.*)|*.*';
end;

end.
