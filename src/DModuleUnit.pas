
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

unit DModuleUnit;

interface

uses
  SysUtils, Classes, DB, DBClient, SdfData;

type
  TDModule = class(TDataModule)
    AlarmDS: TDataSource;
    OptionsDS: TDataSource;
    AlarmTable: TSdfDataSet;
    OptionsTable: TSdfDataSet;
    OptionsTablePATHTOGBAK: TStringField;
    OptionsTableLOGDIR: TStringField;
    OptionsTableTASKNO: TStringField;
    AlarmTableTASKNO: TStringField;
    AlarmTableTASKNAME: TStringField;
    AlarmTableDBNAME: TStringField;
    AlarmTableMIRRORDIR: TStringField;
    AlarmTableMIRROR2DIR: TStringField;
    AlarmTableUSER: TStringField;
    AlarmTableZIPBACKUP: TStringField;
    AlarmTableROLE: TStringField;
    AlarmTableBOPTIONS: TStringField;
    AlarmTableDELETEALL: TStringField;
    AlarmTableBOXES: TStringField;
    AlarmTableACTIVE: TStringField;
    AlarmTableBACKUPDIR: TStringField;
    AlarmTableBCOUNTER: TStringField;
    AlarmTableCOMPRESS: TStringField;
    AlarmTablePVAL: TStringField;
    AlarmTablePUNIT: TStringField;
    OptionsTableAUTORUN: TStringField;
    AlarmTableMIRROR3DIR: TStringField;
    OptionsTableBPRIORTY: TStringField;
    AlarmTableLOCALCONN: TStringField;
    AlarmTablePASSWORD: TStringField;
    AlarmTableDOVAL: TStringField;
    AlarmTableMAILTO: TStringField;
    OptionsTableSMTPSERVER: TStringField;
    OptionsTableSENDERSMAIL: TStringField;
    OptionsTableMAILUSERNAME: TStringField;
    OptionsTableMAILPASSWORD: TStringField;
    AlarmTableBATCHFILE: TStringField;
    AlarmTableSHOWBATCHWIN: TStringField;
    OptionsTableFTPCONNTYPE: TStringField;
    AlarmTableUSEPARAMS: TStringField;
    OptionsTableARCHIVEDIR: TStringField;
    procedure DataModuleDestroy(Sender: TObject);
    procedure DataModuleCreate(Sender: TObject);
    procedure AlarmTableAfterInsert(DataSet: TDataSet);
    procedure OptionsTableAfterPost(DataSet: TDataSet);
    procedure AlarmTableAfterPost(DataSet: TDataSet);
    procedure AlarmTablePASSWORDGetText(Sender: TField; var Text: string;
      DisplayText: Boolean);
    procedure AlarmTablePASSWORDSetText(Sender: TField;
      const Text: string);
    procedure OptionsTableMAILPASSWORDSetText(Sender: TField;
      const Text: string);
    procedure OptionsTableMAILPASSWORDGetText(Sender: TField;
      var Text: string; DisplayText: Boolean);
  private
    { Private declarations }
  public
    { Public declarations }
    function CheckDatabaseSequenceIncrement: Boolean;
    procedure DuplicateTask(SetActive: Boolean);
  end;

var
  DModule: TDModule;

implementation

uses Variants, uTBase64, ConstUnit, IBDatabase, FunctionsUnit, StrUtils;

{$R *.dfm}

procedure TDModule.DataModuleDestroy(Sender: TObject);
begin
  //   FABDatabase.Connected:=false;
end;

procedure TDModule.DataModuleCreate(Sender: TObject);
begin
  try
    OptionsTable.FileName := DataFilesPath + '\prefs.dat';
    AlarmTable.FileName := DataFilesPath + '\tasks.dat';
    DModule.OptionsTable.Open;
    DModule.AlarmTable.Open;
  except
    DataFilesInvalid := true;
  end;
end;

procedure TDModule.AlarmTableAfterInsert(DataSet: TDataSet);
var
  TN: int64;
  StrTN: string;
begin
  StrTN := OptionsTableTASKNO.ASString;
  if StrTN = '' then
    TN := 0;
  TN := StrToInt(OptionsTableTASKNO.Value);
  AlarmTableTASKNO.AsInteger := TN;
  OptionsTable.edit;
  OptionsTableTASKNO.AsInteger := TN + 1;
  OptionsTable.Post;
end;

procedure TDModule.OptionsTableAfterPost(DataSet: TDataSet);
begin
  OptionsTable.SaveFileAs(DataFilesPath + '\prefs.dat');
end;

procedure TDModule.AlarmTableAfterPost(DataSet: TDataSet);
begin
  AlarmTable.SaveFileAs(DataFilesPath + '\tasks.dat');
end;

procedure TDModule.AlarmTablePASSWORDGetText(Sender: TField;
  var Text: string; DisplayText: Boolean);
begin
  DecodeData(AlarmTablePASSWORD.Value, Text);
end;

procedure TDModule.AlarmTablePASSWORDSetText(Sender: TField;
  const Text: string);
var
  s: string;
begin
  EncodeData(Text, s);
  AlarmTablePASSWORD.Value := s;
end;

procedure TDModule.OptionsTableMAILPASSWORDSetText(Sender: TField;
  const Text: string);
var
  s: string;
begin
  EncodeData(Text, s);
  OptionsTableMAILPASSWORD.Value := s;
end;

procedure TDModule.OptionsTableMAILPASSWORDGetText(Sender: TField;
  var Text: string; DisplayText: Boolean);
begin
  DecodeData(OptionsTableMAILPASSWORD.Value, Text);
end;

function TDModule.CheckDatabaseSequenceIncrement: Boolean;
var
  dbDatabase: TIBDatabase;
begin
  Result := False;
  {dbDatabase := TIBDatabase.Create(nil);
  try
    try
      // Test a connection with next sequence
      dbDatabase.DatabaseName := FunctionsUnit.RemoveDatabaseSequenceTokens(FunctionsUnit.IncrementDatabaseSequence(self.AlarmTableDBNAME.ASString));
      dbDatabase.Params.Add('user_name=' + self.AlarmTableUSER.ASString);
      dbDatabase.Params.Add('password=' + self.AlarmTablePASSWORD.Text);
      dbDatabase.LoginPrompt := false;
      dbDatabase.SQLDialect := 3;
      dbDatabase.DefaultTransaction := TIBTransaction.Create(nil);
      dbDatabase.DefaultTransaction.AddDatabase(dbDatabase);
      dbDatabase.Connected := True;
      if dbDatabase.TestConnected then
      begin
        Self.AlarmTable.Edit;
        Self.AlarmTableTASKNAME.ASString := FunctionsUnit.IncrementDatabaseSequence(self.AlarmTableTASKNAME.ASString);
        Self.AlarmTableDBNAME.ASString := FunctionsUnit.IncrementDatabaseSequence(self.AlarmTableDBNAME.ASString);
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

procedure TDModule.DuplicateTask(SetActive: Boolean);
var
  varCopyData: Variant;
  i: Integer;
  iTaskNo: Integer;
begin
  iTaskNo := Self.AlarmTable.RecordCount + 1;;
  varCopyData := VarArrayCreate([0, Self.AlarmTable.FieldCount - 1], varVariant);
  for i := 0 to Self.AlarmTable.FieldCount - 1 do
    varCopyData[i] := Self.AlarmTable.Fields[i].Value;
  Self.AlarmTable.Append;
  for i := 0 to Self.AlarmTable.FieldCount - 1 do
    Self.AlarmTable.Fields[i].Value := varCopyData[i];
  Self.AlarmTableTASKNO.AsString := IntToStr(iTaskNo);
  Self.AlarmTableBCOUNTER.AsString := '0';
  Self.AlarmTableACTIVE.AsString := IfThen(SetActive, '1', '0');
end;

end.

