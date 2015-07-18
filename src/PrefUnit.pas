
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

unit PrefUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, Buttons, Mask, DBCtrls, EditBtn, ComCtrls;

type
  TPrefForm = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    Label4: TLabel;
    Label1: TLabel;
    Label2: TLabel;
    DBCheckBox2: TDBCheckBox;
    DBComboBox1: TDBComboBox;
    DirectoryLogDir: TDirectoryEditBtn;
    DirectoryEdit1: TDirectoryEditBtn;
    SpeedButton1: TSpeedButton;
    Label11: TLabel;
    EditSMTPServer: TEdit;
    EditMailAdress: TEdit;
    Label14: TLabel;
    Label12: TLabel;
    EditUserName: TEdit;
    Label13: TLabel;
    EditPassword: TEdit;
    Label3: TLabel;
    Label6: TLabel;
    Bevel4: TBevel;
    Label5: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    DBCBFtpType: TDBCheckBox;
    Bevel3: TBevel;
    Label10: TLabel;
    DirectoryArchiveDir: TDirectoryEditBtn;
    procedure BitBtn1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  PrefForm: TPrefForm;

implementation

uses Registry, FileCtrl, MesajUnit, ConstUnit;

{$R *.dfm}

procedure TPrefForm.BitBtn1Click(Sender: TObject);
begin
  if DirectoryEdit1.Text = '' then
  begin
    MessageDlg('Directory Name cannot be empty!', mtError, [mbOk], 0);
    exit;
  end
  else
    if DirectoryExists(trim(DirectoryEdit1.Text)) = False then
    begin
      MessageDlg('There is No Directory given name!', mtError, [mbOk], 0);
      ModalResult := mrNone;
      exit;
    end
    else
      if FileExists(trim(DirectoryEdit1.Text) + '\gbak.exe') = False then
      begin
        MessageDlg('Gbak.exe cannot be found onto given dir!', mtError, [mbOk], 0);
        ModalResult := mrNone;
        exit;
      end;
  if DirectoryLogDir.Text = '' then
  begin
    MessageDlg('LOG Directory Name cannot be empty!', mtError, [mbOk], 0);
    exit;
  end
  else
    if DirectoryExists(trim(DirectoryLogDir.Text)) = False then
    begin
      MessageDlg('Given LOG Directory is not exists!', mtError, [mbOk], 0);
      ModalResult := mrNone;
      exit;
    end;
end;

procedure TPrefForm.FormCreate(Sender: TObject);
begin
  DirectoryLogDir.Text := DataFilesPath;
end;

procedure TPrefForm.SpeedButton1Click(Sender: TObject);
var
  Reg: TRegistry;
  DefMail: string;
begin
  Reg := TRegistry.Create;
  try
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    if Reg.OpenKey('\SOFTWARE\Firebird Project\Firebird Server\Instances', False) then
    begin
      DirectoryEdit1.Text := Reg.ReadString('DefaultInstance') + 'bin';
      Reg.CloseKey;
      if RunningAsService = False then
      begin
        Reg.RootKey := HKEY_CURRENT_USER;
        if Reg.OpenKey('\Software\Microsoft\Internet Account Manager', False) then
        begin
          DefMail := Reg.ReadString('Default Mail Account');
          Reg.CloseKey;
          if Reg.OpenKey('\Software\Microsoft\Internet Account Manager\Accounts\' + DefMail, False) then
          begin
            EditSMTPServer.Text := Reg.ReadString('SMTP Server');
            EditMailAdress.Text := Reg.ReadString('SMTP Email Address');
            EditUserName.Text := Reg.ReadString('POP3 User Name');
            EditPassword.Text := '';
            Reg.CloseKey;
            MessageDlg('Warning !!'#13#10'Reading Default Mail Account from registry clears the password box..'#13#10 +
              'Please do not forget entering the correct password.', mtError, [mbOk], 0);
          end
          else
            MessageDlg('Default Mail Account hasn''t been found!', mtError, [mbOk], 0);
        end
        else
          MessageDlg('No Mail Account has been found!', mtError, [mbOk], 0);
      end
      else
        MessageDlg('FIBS can''t get email related data while it''s running as a service !'#13#10'Please run FIBS as an application to get email-related-data and then restart FIBS as a service.', mtError, [mbOk], 0);
    end
    else
      MessageDlg('Firebird key couldn''t been found in the registry!', mtError, [mbOk], 0);
  finally
    Reg.Free;
  end;
end;

end.
