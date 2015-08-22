
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

unit FunctionsUnit;

interface

function MyDateTimeToStr(ADT: TDateTime): string;
function FileExistsRem(const FileName: string; AEnableControl: Boolean): Boolean;
function IsValidDirectory(const ADir: string): Boolean;

function RemoveDatabaseSequenceTokens(ADatabasePath: string): string;
function IncrementDatabaseSequence(AString: string): string;
function GetDatabaseSequence(AString: string): Integer;

implementation

uses SysUtils, StrUtils, UDFConst, UDFPresets; //, windows;

function IsValidDirectory(const ADir: string): Boolean;
begin
  Result := (Trim(ADir) = '') or ((DirectoryExists(ADir) or IsFtpPath(ADir)));
end;

function RemoveDatabaseSequenceTokens(ADatabasePath: string): string;
begin
  Result := StringReplace(ADatabasePath, DatabaseSequenceBeginToken, '', [rfReplaceAll]);
  Result := StringReplace(Result, DatabaseSequenceEndToken, '', [rfReplaceAll]);
end;

function IncrementDatabaseSequence(AString: string): string;
var
  i: Integer;
  iBegin: Integer;
  sTmp: string;
  sFormat: string;
  iSequence: Integer;
begin
  iBegin := 0;
  sTmp := '';
  iSequence := 0;
  Result := '';
  for i := 1 to Length(AString) do
  begin
    if AString[i] = DatabaseSequenceBeginToken then
    begin
      iBegin := i;
    end
    else
      if AString[i] = DatabaseSequenceEndToken then
      begin
        if iBegin > 0 then
        begin
          sTmp := copy(AString, iBegin + 1, i - iBegin - 1);
          sFormat := StringOfChar('0', Length(sTmp));
          iSequence := StrToIntDef(sTmp, 0);
          inc(iSequence);
          Result := Result + DatabaseSequenceBeginToken + FormatFloat(sFormat, iSequence) + DatabaseSequenceEndToken;
          iBegin := 0;
        end;
        // Discartes a DatabaseSequenceEndToken char
      end
      else
        if iBegin = 0 then
        begin
          Result := Result + AString[i];
        end;
  end;
end;

function GetDatabaseSequence(AString: string): Integer;
var
  i: Integer;
  iBegin: Integer;
  sTmp: string;
  sFormat: string;
begin
  iBegin := 0;
  sTmp := '';
  Result := 0;
  for i := 1 to Length(AString) do
  begin
    if AString[i] = DatabaseSequenceBeginToken then
    begin
      iBegin := i;
    end
    else
      if AString[i] = DatabaseSequenceEndToken then
      begin
        if iBegin > 0 then
        begin
          sTmp := copy(AString, iBegin + 1, i - iBegin - 1);
          Result := StrToIntDef(sTmp, 0);
          Exit;
        end;
        // Discartes a DatabaseSequenceEndToken char
      end
  end;
end;

function MyDateTimeToStr(ADT: TDateTime): string;
var
  Saat: Double;
begin
  Saat := Frac(ADT);
  if Saat = 0 then
    Result := DateTimeToStr(ADT) + ' 00:00:00'
  else
    Result := DateTimeToStr(ADT);
end;

function FileExistsRem(const FileName: string; AEnableControl: Boolean): Boolean;
begin
  if AEnableControl then
    Result := FileExists(FileName)
  else
    Result := True;
end;

{
 procedure SelfDuplicate(Folder:String);
 begin
   if Folder[Length(Folder)]<>'' then Folder:=Folder+'';
   CopyFile(PChar(Paramstr(0)),Pchar(Folder+ExtractFilename(Paramstr(0))),False);
 end;

 function GetTempPath:String;
 var
  Buffer : Array [0..MAX_PATH] of char;
 begin
   Windows.GetTempPath(sizeof(Buffer),@buffer);
   Result:=Buffer;
 end;

}

end.
