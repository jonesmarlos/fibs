
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

unit BackupForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ExtCtrls, Spin, CheckLst, DBCtrls,
  FibsData, JvExStdCtrls, JvCheckBox, JvExExtCtrls, JvBevel;

type
  TfmBackup = class(TForm)
    lbBackupDir: TLabel;
    lbDatabaseName: TLabel;
    edBackupDir: TEdit;
    edDatabaseName: TEdit;
    lbUserName: TLabel;
    lbPassword: TLabel;
    edUserName: TEdit;
    edPassword: TEdit;
    lbMirrorDir1: TLabel;
    edMirrorDir1: TEdit;
    lbTaskName: TLabel;
    edTaskName: TEdit;
    lbGbakDir: TLabel;
    edGbakDir: TEdit;
    lbGbakOptions: TLabel;
    clbGbakOptions: TCheckListBox;
    lbCompressLevel: TLabel;
    edCompressLevel: TEdit;
    lbBackupPriority: TLabel;
    edBackupPriority: TEdit;
    lbMirrorDir2: TLabel;
    edMirrorDir2: TEdit;
    lbMirrorDir3: TLabel;
    edMirrorDir3: TEdit;
    edMailTo: TEdit;
    lbMailTo: TLabel;
    cbValidateDatabase: TJvCheckBox;
    cbCreateZipBackup: TJvCheckBox;
    JvBevel1: TJvBevel;
    btBackupNow: TButton;
    btCancel: TButton;
  private
    { Private declarations }
  public
    { Public declarations }
    procedure LoadTask(FibsRef: TdmFibs);

    class function ShowBackup(AOwner: TComponent; FibsRef: TdmFibs): Boolean;
  end;

implementation

{$R *.dfm}
uses DateUtils, UDFConst, ProgressForm, UDFPresets, UDFUtils, Soap.EncdDecd,
  DB;

procedure TfmBackup.LoadTask(FibsRef: TdmFibs);
var
  sOptions: string;
  i: Integer;
begin
  Self.edTaskName.Text := UDFUtils.RemoveDatabaseSequenceTokens(FibsRef.qrTaskTASKNAME.Value);
  Self.edDatabaseName.Text := UDFUtils.RemoveDatabaseSequenceTokens(FibsRef.qrTaskDBNAME.Value);
  Self.edBackupDir.Text := FibsRef.qrTaskBACKUPDIR.Value;
  Self.edMirrorDir1.Text := FibsRef.qrTaskMIRRORDIR.Value;
  Self.edMirrorDir2.Text := FibsRef.qrTaskMIRROR2DIR.Value;
  Self.edMirrorDir3.Text := FibsRef.qrTaskMIRROR3DIR.Value;
  Self.edGbakDir.Text := FibsRef.qrOptionPATHTOGBAK.Value;
  Self.edUserName.Text := FibsRef.qrTaskUSER.Value;
  Self.edPassword.Text := Soap.EncdDecd.DecodeString(FibsRef.qrTaskPASSWORD.AsString);
  Self.cbValidateDatabase.Checked := FibsRef.qrTaskDOVAL.AsBoolean;
  Self.cbCreateZipBackup.Checked := FibsRef.qrTaskZIPBACKUP.AsBoolean;
  Self.edCompressLevel.Text := FibsRef.qrTaskCOMPRESS.Value;
  Self.edBackupPriority.Text := FibsRef.qrOptionBPRIORTY.Value;
  Self.edMailTo.Text := FibsRef.qrTaskMAILTO.Value;
  sOptions := FibsRef.qrTaskBOPTIONS.Value;
  for i := 0 to TotalGBakOptions - 1 do
    if (sOptions[i + 1] = '1') then
      Self.clbGbakOptions.State[i] := cbChecked
    else
      Self.clbGbakOptions.State[i] := cbUnChecked;
end;

class function TfmBackup.ShowBackup(AOwner: TComponent;
  FibsRef: TdmFibs): Boolean;
var
  fmBackup: TfmBackup;
begin
  Result := False;
  fmBackup := TfmBackup.Create(AOwner);
  try
    fmBackup.LoadTask(FibsRef);
    Result := fmBackup.ShowModal = mrOk;
  finally
    fmBackup.Release;
  end;
end;

end.
