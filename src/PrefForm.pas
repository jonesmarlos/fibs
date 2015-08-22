
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

unit PrefForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, Buttons, Mask, DBCtrls, ComCtrls,
  FibsData, JvComponentBase, JvAppStorage, JvAppRegistryStorage,
  JvToolEdit, JvExMask, JvDotNetControls, JvExControls, JvComponent,
  JvGroupHeader, JvExExtCtrls, JvBevel;

type
  TfmPref = class(TForm)
    lbGbakDir: TLabel;
    lbLogDir: TLabel;
    lbBackupPriority: TLabel;
    cbAutoRun: TDBCheckBox;
    cbBackupPriority: TDBComboBox;
    lbMailServer: TLabel;
    edSMTPServer: TEdit;
    edMailAdress: TEdit;
    lbSenderEmail: TLabel;
    lbUserName: TLabel;
    edUserName: TEdit;
    lbPassword: TLabel;
    edPassword: TEdit;
    Label6: TLabel;
    lbMailServerInfo: TLabel;
    lbSenderEmailInfo: TLabel;
    lbUserNameInfo: TLabel;
    lbPasswordInfo: TLabel;
    cbFtpPassive: TDBCheckBox;
    lbArchiveDir: TLabel;
    arsAutoRun: TJvAppRegistryStorage;
    arsFirebird: TJvAppRegistryStorage;
    arsEmail: TJvAppRegistryStorage;
    edGbakDir: TJvDirectoryEdit;
    edLogDir: TJvDirectoryEdit;
    edArchiveDir: TJvDirectoryEdit;
    ghGeneral: TJvGroupHeader;
    ghSMTPServer: TJvGroupHeader;
    JvBevel1: TJvBevel;
    btCancel: TButton;
    btOK: TButton;
    procedure btOkClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    procedure LoadPreferences(FibsRef: TdmFibs);
    procedure SavePreferences(FibsRef: TdmFibs);

    class function ShowPrefs(AOwner: TComponent; FibsRef: TdmFibs): boolean;
  end;

implementation

uses Registry, FileCtrl, MesajUnit, UDFConst, DCPbase64, UDFValidation;

{$R *.dfm}

class function TfmPref.ShowPrefs(AOwner: TComponent; FibsRef: TdmFibs): boolean;
var
  fmPref: TfmPref;
begin
  fmPref := TfmPref.Create(AOwner);
  try
    fmPref.LoadPreferences(FibsRef);
    if fmPref.ShowModal = mrOk then
      fmPref.SavePreferences(FibsRef);
  finally
    fmPref.Release;
  end;
end;

procedure TfmPref.LoadPreferences(FibsRef: TdmFibs);
begin
  Self.edGBakDir.Text := FibsRef.qrOptionPATHTOGBAK.Value;
  Self.edLogDir.Text := FibsRef.qrOptionLOGDIR.Value;
  Self.edArchiveDir.Text := FibsRef.qrOptionARCHIVEDIR.Value;
  Self.edSMTPServer.Text := FibsRef.qrOptionSMTPSERVER.Value;
  Self.edMailAdress.Text := FibsRef.qrOptionSENDERSMAIL.Value;
  Self.edUserName.Text := FibsRef.qrOptionMAILUSERNAME.Value;
  Self.edPassword.Text := DCPbase64.Base64DecodeStr(FibsRef.qrOptionMAILPASSWORD.AsString);
  if Length(Trim(Self.edGBakDir.Text)) = 0 then
    if Self.arsFirebird.PathExists('DefaultInstance') then
      Self.edGBakDir.Text := Self.arsFirebird.ReadString('DefaultInstance') + 'bin';
end;

procedure TfmPref.SavePreferences(FibsRef: TdmFibs);
begin
  FibsRef.qrOption.Edit;
  FibsRef.qrOptionPATHTOGBAK.Value := Self.edGBakDir.Text;
  FibsRef.qrOptionLOGDIR.Value := Self.edLogDir.Text;
  FibsRef.qrOptionARCHIVEDIR.Value := Self.edArchiveDir.Text;
  FibsRef.qrOptionSMTPSERVER.Value := Self.edSMTPServer.Text;
  FibsRef.qrOptionSENDERSMAIL.Value := Self.edMailAdress.Text;
  FibsRef.qrOptionMAILUSERNAME.Value := Self.edUserName.Text;
  FibsRef.qrOptionMAILPASSWORD.Value := DCPbase64.Base64EncodeStr(Self.edPassword.Text);
  FibsRef.qrOption.Post;
  if Self.cbAutoRun.Checked then
    Self.arsAutoRun.WriteString('FIBS_Backup_Scheduler', System.ParamStr(0))
  else
    Self.arsAutoRun.DeleteValue('FIBS_Backup_Scheduler');
end;

procedure TfmPref.FormCreate(Sender: TObject);
begin
  Self.edLogDir.Text := DataFilesPath;
end;

procedure TfmPref.btOkClick(Sender: TObject);
var
  vaValidation: TValidation;
begin
  vaValidation := TValidation.Create(Self);
  try
    if Length(Trim(Self.edGBakDir.Text)) = 0 then
      vaValidation.Add('Directory Name cannot be empty!', vtWarning);
    if not SysUtils.DirectoryExists(Self.edGBakDir.Text) then
      vaValidation.Add('There is No Directory given name!', vtWarning);
    if not SysUtils.FileExists(Self.edGBakDir.Text + '\gbak.exe') then
      vaValidation.Add('Gbak.exe cannot be found onto given dir!', vtWarning);
    if Length(Trim(Self.edLogDir.Text)) = 0 then
      vaValidation.Add('LOG Directory Name cannot be empty!', vtWarning);
    if not SysUtils.DirectoryExists(Self.edLogDir.Text) then
      vaValidation.Add('Given LOG Directory is not exists!', vtWarning);
    if vaValidation.ShowModal then
      Self.ModalResult := mrOk
    else
      Self.ModalResult := mrNone;
  finally
    vaValidation.Free;
  end;
end;

end.

