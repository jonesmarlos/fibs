
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

unit FibsData;

interface

uses
  SysUtils, Classes, DB, DBClient, SdfData, UDFTask;

type
  TdmFibs = class(TDataModule)
    dsTask: TDataSource;
    dsOption: TDataSource;
    qrTask: TSdfDataSet;
    qrOption: TSdfDataSet;
    qrOptionPATHTOGBAK: TStringField;
    qrOptionLOGDIR: TStringField;
    qrOptionTASKNO: TStringField;
    qrTaskTASKNO: TStringField;
    qrTaskTASKNAME: TStringField;
    qrTaskDBNAME: TStringField;
    qrTaskMIRRORDIR: TStringField;
    qrTaskMIRROR2DIR: TStringField;
    qrTaskUSER: TStringField;
    qrTaskZIPBACKUP: TStringField;
    qrTaskROLE: TStringField;
    qrTaskBOPTIONS: TStringField;
    qrTaskDELETEALL: TStringField;
    qrTaskBOXES: TStringField;
    qrTaskACTIVE: TStringField;
    qrTaskBACKUPDIR: TStringField;
    qrTaskBCOUNTER: TStringField;
    qrTaskCOMPRESS: TStringField;
    qrTaskPVAL: TStringField;
    qrTaskPUNIT: TStringField;
    qrOptionAUTORUN: TStringField;
    qrTaskMIRROR3DIR: TStringField;
    qrOptionBPRIORTY: TStringField;
    qrTaskLOCALCONN: TStringField;
    qrTaskPASSWORD: TStringField;
    qrTaskDOVAL: TStringField;
    qrTaskMAILTO: TStringField;
    qrOptionSMTPSERVER: TStringField;
    qrOptionSENDERSMAIL: TStringField;
    qrOptionMAILUSERNAME: TStringField;
    qrOptionMAILPASSWORD: TStringField;
    qrTaskBATCHFILE: TStringField;
    qrTaskSHOWBATCHWIN: TStringField;
    qrOptionFTPCONNTYPE: TStringField;
    qrTaskUSEPARAMS: TStringField;
    qrOptionARCHIVEDIR: TStringField;
    procedure DataModuleDestroy(Sender: TObject);
    procedure DataModuleCreate(Sender: TObject);
    procedure qrTaskAfterInsert(DataSet: TDataSet);
    procedure qrOptionAfterPost(DataSet: TDataSet);
    procedure qrTaskAfterPost(DataSet: TDataSet);
    procedure qrTaskPASSWORDGetText(Sender: TField; var Text: string;
      DisplayText: Boolean);
    procedure qrTaskPASSWORDSetText(Sender: TField;
      const Text: string);
    procedure qrOptionMAILPASSWORDSetText(Sender: TField;
      const Text: string);
    procedure qrOptionMAILPASSWORDGetText(Sender: TField;
      var Text: string; DisplayText: Boolean);
  private
    { Private declarations }
    bmTask: Integer;
  public
    { Public declarations }
    function CheckDatabaseSequenceIncrement: Boolean;
    procedure DuplicateTask(SetActive: Boolean);

    procedure GetTaskBookmark;
    procedure SetTaskBookmark; 
    function GetTask: TTask;
    procedure SetTask(Task: TTask);

    procedure SetTaskDefault;
  end;

var
  dmFibs: TdmFibs;

implementation

uses Variants, UDFConst, IBDatabase, UDFUtils, StrUtils, DCPbase64;

{$R *.dfm}

procedure TdmFibs.DataModuleDestroy(Sender: TObject);
begin
  //   FABDatabase.Connected:=false;
end;

procedure TdmFibs.DataModuleCreate(Sender: TObject);
begin
  try
    Self.qrOption.FileName := DataFilesPath + '\prefs.dat';
    Self.qrTask.FileName := DataFilesPath + '\tasks.dat';
    Self.qrOption.Open;
    Self.qrTask.Open;
  except
    DataFilesInvalid := True;
  end;
end;

procedure TdmFibs.qrTaskAfterInsert(DataSet: TDataSet);
var
  TN: int64;
  StrTN: string;
begin
  StrTN := Self.qrOptionTASKNO.AsString;
  if StrTN = '' then
    TN := 0;
  TN := Self.qrOptionTASKNO.AsInteger;
  Self.qrTaskTASKNO.AsInteger := TN;
  Self.qrOption.Edit;
  Self.qrOptionTASKNO.AsInteger := TN + 1;
  Self.qrOption.Post;
end;

procedure TdmFibs.qrOptionAfterPost(DataSet: TDataSet);
begin
  Self.qrOption.SaveFileAs(DataFilesPath + '\prefs.dat');
end;

procedure TdmFibs.qrTaskAfterPost(DataSet: TDataSet);
begin
  Self.qrTask.SaveFileAs(DataFilesPath + '\tasks.dat');
end;

procedure TdmFibs.qrTaskPASSWORDGetText(Sender: TField;
  var Text: string; DisplayText: Boolean);
begin
  Text := DCPbase64.Base64DecodeStr(Self.qrTaskPASSWORD.AsString);
end;

procedure TdmFibs.qrTaskPASSWORDSetText(Sender: TField;
  const Text: string);
begin
  Self.qrTaskPASSWORD.AsString := DCPbase64.Base64EncodeStr(Text);
end;

procedure TdmFibs.qrOptionMAILPASSWORDSetText(Sender: TField;
  const Text: string);
begin
  Self.qrOptionMAILPASSWORD.AsString := DCPbase64.Base64EncodeStr(Text);
end;

procedure TdmFibs.qrOptionMAILPASSWORDGetText(Sender: TField;
  var Text: string; DisplayText: Boolean);
begin
  Text := DCPbase64.Base64DecodeStr(Self.qrOptionMAILPASSWORD.AsString);
end;

function TdmFibs.CheckDatabaseSequenceIncrement: Boolean;
var
  dbDatabase: TIBDatabase;
begin
  Result := False;
  {dbDatabase := TIBDatabase.Create(nil);
  try
    try
      // Test a connection with next sequence
      dbDatabase.DatabaseName := UDFUtils.RemoveDatabaseSequenceTokens(FunctionsUnit.IncrementDatabaseSequence(self.AlarmTableDBNAME.AsString));
      dbDatabase.Params.Add('user_name=' + self.AlarmTableUSER.AsString);
      dbDatabase.Params.Add('password=' + self.AlarmTablePASSWORD.Text);
      dbDatabase.LoginPrompt := false;
      dbDatabase.SQLDialect := 3;
      dbDatabase.DefaultTransaction := TIBTransaction.Create(nil);
      dbDatabase.DefaultTransaction.AddDatabase(dbDatabase);
      dbDatabase.Connected := True;
      if dbDatabase.TestConnected then
      begin
        Self.AlarmTable.Edit;
        Self.AlarmTableTASKNAME.AsString := UDFUtils.IncrementDatabaseSequence(self.AlarmTableTASKNAME.AsString);
        Self.AlarmTableDBNAME.AsString := UDFUtils.IncrementDatabaseSequence(self.AlarmTableDBNAME.AsString);
        Self.AlarmTable.Post;
        Result := True;
      end;
    except
    end;
    try
      dbDatabase.ForceClose;
    except
    end;
  finally
    dbDatabase.Free;
  end;}
end;

procedure TdmFibs.DuplicateTask(SetActive: Boolean);
var
  varCopyData: Variant;
  i: Integer;
  iTaskNo: Integer;
begin
  iTaskNo := Self.qrTask.RecordCount + 1;
  varCopyData := VarArrayCreate([0, Self.qrTask.FieldCount - 1], varVariant);
  for i := 0 to Self.qrTask.FieldCount - 1 do
    varCopyData[i] := Self.qrTask.Fields[i].Value;
  Self.qrTask.Append;
  for i := 0 to Self.qrTask.FieldCount - 1 do
    Self.qrTask.Fields[i].Value := varCopyData[i];
  Self.qrTaskTASKNO.AsString := IntToStr(iTaskNo);
  Self.qrTaskBCOUNTER.AsString := '0';
  Self.qrTaskACTIVE.AsString := IfThen(SetActive, '1', '0');
end;

procedure TdmFibs.GetTaskBookmark;
begin
  Self.bmTask := Self.qrTaskTASKNO.AsInteger;
end;

procedure TdmFibs.SetTaskBookmark;
begin
  if Self.bmTask > 0 then
    Self.qrTask.Locate(Self.qrTaskTASKNO.FieldName, Self.bmTask, []);
end;

function TdmFibs.GetTask: TTask;
begin
  Result := TTask.Create;
end;

procedure TdmFibs.SetTask(Task: TTask);
begin

end;

procedure TdmFibs.SetTaskDefault;
begin
  Self.qrTaskDOVAL.Value := 'False';
  Self.qrTaskMAILTO.Value := '';
  Self.qrTaskSHOWBATCHWIN.Value := 'False';
  Self.qrTaskUSEPARAMS.Value := 'False';
  Self.qrTaskLOCALCONN.Value := 'True';
  Self.qrTaskACTIVE.AsInteger := 0;
  Self.qrTaskDELETEALL.AsInteger := 1;
  Self.qrTaskZIPBACKUP.Value := 'True';
  Self.qrTaskCOMPRESS.Value := 'Default';
  Self.qrTaskPUNIT.Value := 'Backups';
  Self.qrTaskBCOUNTER.AsInteger := 0;
  Self.qrTaskPVAL.AsInteger := 1;
  Self.qrTaskBOPTIONS.Value := '11100000';
  Self.qrTaskBOXES.Value := DupeString('0', 84);
end;

end.
