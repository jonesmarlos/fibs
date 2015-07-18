
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

unit ManualBackupUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ExtCtrls, Spin, CheckLst, DBCtrls;

type
  TManualBackupForm = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    Label5: TLabel;
    Label6: TLabel;
    EditDestinationDir: TEdit;
    EditDatabaseName: TEdit;
    Label7: TLabel;
    Label8: TLabel;
    EditUserName: TEdit;
    EditPassword: TEdit;
    Label3: TLabel;
    EditMirrorDir: TEdit;
    Label11: TLabel;
    EditTaskName: TEdit;
    Label1: TLabel;
    EditGBakDir: TEdit;
    Bevel1: TBevel;
    Label13: TLabel;
    CLBGbakOptions: TCheckListBox;
    DBCheckBox1: TDBCheckBox;
    LabelCompDegree: TLabel;
    EditCompDeg: TEdit;
    Label2: TLabel;
    EditPriority: TEdit;
    Label4: TLabel;
    EditMirror2Dir: TEdit;
    Label9: TLabel;
    EditMirror3Dir: TEdit;
    DBCheckBox2: TDBCheckBox;
    EditMailTo: TEdit;
    Label10: TLabel;
    procedure BitBtn1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ManualBackupForm: TManualBackupForm;

implementation

{$R *.dfm}
uses DateUtils, ConstUnit, DModuleUnit, MesajUnit, PresetsUnit, FunctionsUnit;

procedure TManualBackupForm.BitBtn1Click(Sender: TObject);
var
  bd, MD, DD, gd, ld: string;
begin
  if EditTaskName.Text = '' then
  begin
    MessageDlg('Task Name cannot be empty!', mtError, [mbOk], 0);
    ModalResult := mrNone;
    exit;
  end;
  if DModule.AlarmTableLOCALCONN.AsBoolean = True then
  begin
    DD := FunctionsUnit.RemoveDatabaseSequenceTokens(EditDatabaseName.Text);
    if (DD = '') then
    begin
      MessageDlg('Database Path cannot be empty!', mtError, [mbOk], 0);
      ModalResult := mrNone;
      exit;
    end
    else
      if FileExists(DD) = False then
      begin
        MessageDlg('Database doesn''t exist onto given path!' + #13#10 + '(' + DD + ')', mtError, [mbOk], 0);
        ModalResult := mrNone;
        exit;
      end;
  end;
  bd := trim(EditDestinationDir.Text);
  if (bd = '') then
  begin
    MessageDlg('Backup Directory cannot be empty!', mtError, [mbOk], 0);
    ModalResult := mrNone;
    exit;
  end
  else
    if DirectoryExists(bd) = False then
    begin
      MessageDlg('Backup directory is not exist !' + #13#10 + '(' + bd + ')', mtError, [mbOk], 0);
      ModalResult := mrNone;
      exit;
    end;

  if IsFtpPath(EditMirrorDir.Text) = False then
  begin
    MD := trim(EditMirrorDir.Text);
    if trim(MD) = '' then
    begin
      //    MesajDlg('Mirror path is empty !'#13#10'Mirroring has been disabled !',  'c',PrgName);
      // dikkat !!! mrNone yok ..exit yok..
    end
    else
      if DirectoryExists(MD) = False then
      begin
        MessageDlg('Mirror directory is not exist !' + #13#10 + '(' + MD + ')', mtError, [mbOk], 0);
        ModalResult := mrNone;
        exit;
      end
      else
        if (MD = bd) then
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
    MD := trim(EditMirror2Dir.Text);
    if trim(MD) = '' then
    begin
      //    MesajDlg('Mirror path is empty !'#13#10'Mirroring has been disabled !',  'c',PrgName);
      // dikkat !!! mrNone yok ..exit yok..
    end
    else
      if DirectoryExists(MD) = False then
      begin
        MessageDlg('Mirror directory 2 is not exist !' + #13#10 + '(' + MD + ')', mtError, [mbOk], 0);
        ModalResult := mrNone;
        exit;
      end
      else
        if (MD = bd) then
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
    MD := trim(EditMirror3Dir.Text);
    if trim(MD) = '' then
    begin
      //    MesajDlg('Mirror path is empty !'#13#10'Mirroring has been disabled !',  'c',PrgName);
      // dikkat !!! mrNone yok ..exit yok..
    end
    else
      if DirectoryExists(MD) = False then
      begin
        MessageDlg('Mirror directory 3 is not exist!' + #13#10 + '(' + MD + ')', mtError, [mbOk], 0);
        ModalResult := mrNone;
        exit;
      end
      else
        if (MD = bd) then
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

  gd := trim(EditGBakDir.Text);
  if gd = '' then
  begin
    MessageDlg('GBAK Directory is empty!', mtError, [mbOk], 0);
    ModalResult := mrNone; //1.0.1
    exit;
  end
  else
    if DirectoryExists(gd) = False then
    begin
      MessageDlg('Gbak Directory doesn''t exists!' + #13#10 + '(' + gd + ')', mtError, [mbOk], 0);
      ModalResult := mrNone;
      exit;
    end
    else
      if FileExists(gd + '\gbak.exe') = False then
      begin
        MessageDlg('Gbak.exe cannot be found onto given Gbak Dir!' + #13#10 + '(' + gd + ')', mtError, [mbOk], 0);
        ModalResult := mrNone;
        exit;
      end;
  ld := trim(DModule.OptionsTableLOGDIR.Value);
  if (ld = '') then
  begin
    MessageDlg('LOG Directory is empty!', mtError, [mbOk], 0);
    ModalResult := mrNone;
    exit;
  end
  else
    if DirectoryExists(ld) = False then
    begin
      MessageDlg('Given LOG Directory doesn''t exists!' + #13#10 + '(' + ld + ')', mtError, [mbOk], 0);
      ModalResult := mrNone;
      exit;
    end;

  if EditUserName.Text = '' then
  begin
    MessageDlg('User Name cannot be empty!', mtError, [mbOk], 0);
    ModalResult := mrNone;
    exit;
  end;
  if EditPassword.Text = '' then
  begin
    MessageDlg('Password cannot be empty!', mtError, [mbOk], 0);
    ModalResult := mrNone;
    exit;
  end;
end;

procedure TManualBackupForm.FormShow(Sender: TObject);
begin
  Self.EditTaskName.Text := FunctionsUnit.RemoveDatabaseSequenceTokens(Self.EditTaskName.Text);
  Self.EditDatabaseName.Text := FunctionsUnit.RemoveDatabaseSequenceTokens(Self.EditDatabaseName.Text);
end;

end.
