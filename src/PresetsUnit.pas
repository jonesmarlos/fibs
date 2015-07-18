
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

unit PresetsUnit;

interface

function DataFilesExists: Boolean;
function AlreadyRun: Boolean;
procedure PozitiveIntegerEditKeyPress(ASender: TObject; var AKey: Char);

function IsFtpPath(AFtpPath: string): Boolean;
function CheckFtpPath(AFtpPath: string): Boolean;
function ParseFtp(AFtpPath: string; var FtpUserName, FtpPassword, FtpHost, FtpDir, FtpFile: string): Boolean;

function MakeFull(ADir, AExt: string): string;

implementation

uses windows, SysUtils, Forms, Dialogs, StrUtils, ConstUnit, MesajUnit;

function DataFilesExists: Boolean;
begin
  result := false;
  DataFilesPath := ExtractFilePath(Application.ExeName);
  if FileExists(DataFilesPath + 'prefs.dat') then
  begin
    if FileExists(DataFilesPath + 'tasks.dat') then
    begin
      result := true;
    end
    else
      MesajDlg(DataFilesPath + 'tasks.dat is not exist !!!'#13#10'Program will be closed.. ', 'c', PrgName);
  end
  else
    MesajDlg(DataFilesPath + 'prefs.dat is not exist !!!'#13#10'Program will be closed.. ', 'c', PrgName);
end;

function AlreadyRun: Boolean;
const
  App = 'FIBS'; // do not localize
  SSubClass = '.OneInstance.'; // do not localize
var
  _OneInstanceMutex: THandle;
  Mutex: THandle;
  Flag: DWORD;
begin
  result := true;
  Mutex := CreateMutex(nil, true, PChar(App + SSubClass + 'CriticalSection')); // don't localize
  if (GetLastError <> 0) or (Mutex = 0) then
    exit;
  _OneInstanceMutex := CreateMutex(nil, false, PChar(App + SSubClass + 'Default')); // don't localize
  Flag := WaitForSingleObject(_OneInstanceMutex, 0);
  result := (Flag = WAIT_TIMEOUT);
  ReleaseMutex(Mutex);
  CloseHandle(Mutex);
end;

procedure PozitiveIntegerEditKeyPress(ASender: TObject; var AKey: Char);
begin
  if not (AKey in [#0, #8, #13, #27, '0', '1', '2', '3', '4', '5', '6', '7', '8', '9']) then
    AKey := #0;
end;

function IsFtpPath(AFtpPath: string): Boolean;
var
  APath: string;
begin
  result := false;
  APath := trim(AFtpPath);
  if AnsiLowerCase(AnsiLeftStr(APath, 6)) = 'ftp://' then
    result := true;
end;

function CheckFtpPath(AFtpPath: string): Boolean;
var
  APath: string;
  p1, p2, p3: Integer;
begin
  result := false;
  APath := trim(AFtpPath);
  if AnsiLowerCase(AnsiLeftStr(APath, 6)) = 'ftp://' then
  begin
    result := true;
    APath := AnsiReplaceStr(APath, '\', '/');
    p1 := PosEx(':', APath, 7);
    p2 := Pos('@', APath);
    p3 := PosEx('/', APath, 7);
    if ((p1 = 7) or // username is not exist
      (p2 - p1 = 1) or //password is not exist
      (p3 - p2 = 1) or //host is not exist
      (p1 = 0) or // : is not exist
      (p2 = 0)) {// @ is not exist} then
    begin
      result := false;
      MesajDlg('FTP Path Error !!!'#13#10'Define FTP Path like ftp://username:password@talatdogan.com/backups', 'c', PrgName);
    end;
  end;
end;

function ParseFtp(AFtpPath: string; var FtpUserName, FtpPassword, FtpHost, FtpDir, FtpFile: string): Boolean;
var
  APath: string;
  p1, p2, p3, p4, p5: Integer;
begin
  result := false;
  APath := trim(AFtpPath);
  if AnsiLowerCase(AnsiLeftStr(APath, 6)) = 'ftp://' then
  begin
    result := true;
    APath := AnsiReplaceStr(APath, '\', '/');
    p1 := PosEx(':', APath, 7);
    p2 := Pos('@', APath);
    p3 := PosEx('/', APath, 7);
    p4 := LastDelimiter('/', APath);
    p5 := Length(APath);
    if ((p1 = 7) or //username is not exist
      (p2 - p1 = 1) or //password is not exist
      (p3 - p2 = 1) or //host is not exist
      (p1 = 0) or // : is not exist
      (p2 = 0)) {// @ is not exist} then
    begin
      result := false;
      MesajDlg('FTP Path Error !!!'#13#10'Define FTP Path like ftp://username:password@talatdogan.com/backups', 'c', PrgName);
    end
    else
    begin
      FtpUserName := copy(APath, 7, p1 - 6 - 1);
      FtpPassword := copy(APath, p1 + 1, p2 - p1 - 1);
      FtpHost := copy(APath, p2 + 1, p3 - p2 - 1);
      FtpDir := copy(APath, p3 + 1, p4 - p3 - 1);
      FtpFile := copy(APath, p4 + 1, p5 - p4);
    end;
  end;
end;

function MakeFull(ADir, AExt: string): string;
begin
  if IsFtpPath(ADir) then
  begin
    if RightStr(ADir, 1) = '/' then
      result := ADir + AExt
    else
      result := ADir + '/' + AExt;
  end
  else
  begin
    if RightStr(ADir, 1) = '\' then
      result := ADir + AExt
    else
      result := ADir + '\' + AExt;
  end;
end;

{  Original Writer :Andreas Hörstemeier }
{ finds the count'th occurence of the substring, if count<0 then look from the back }

function posn(const s, T: string; Count: Integer): Integer;
var
  i, h, last: Integer;
  u: string;
begin
  u := T;
  if Count > 0 then
  begin
    result := Length(T);
    for i := 1 to Count do
    begin
      h := Pos(s, u);
      if h > 0 then
      begin
        u := copy(u, Pos(s, u) + 1, Length(u))
      end
      else
      begin
        u := '';
        inc(result);
      end;
    end;
    result := result - Length(u);
  end
  else
    if Count < 0 then
    begin
      last := 0;
      for i := Length(T) downto 1 do
      begin
        u := copy(T, i, Length(T));
        h := Pos(s, u);
        if (h <> 0) and (h + i <> last) then
        begin
          last := h + i - 1;
          inc(Count);
          if Count = 0 then
            break;
        end;
      end;
      if Count = 0 then
        result := last
      else
        result := 0;
    end
    else
      result := 0;
end;

{  Author : Andreas Hörstemeier }
{ standard syntax of an URL:  protocol://[user[:password]@]server[:port]/path              }

procedure parse_url(const url: string; var proto, user, pass, host, port, path: string);
var
  p, q: Integer;
  s: string;
begin
  proto := '';
  user := '';
  pass := '';
  host := '';
  port := '';
  path := '';
  p := Pos('://', url);
  if p = 0 then
  begin
    if lowercase(copy(url, 1, 7)) = 'mailto:' then
    begin (* mailto:// not common *)
      proto := 'mailto';
      p := Pos(':', url);
    end;
  end
  else
  begin
    proto := copy(url, 1, p - 1);
    inc(p, 2);
  end;
  s := copy(url, p + 1, Length(url));
  p := Pos('/', s);
  if p = 0 then
    p := Length(s) + 1;
  path := copy(s, p, Length(s));
  s := copy(s, 1, p - 1);
  p := posn(':', s, -1);
  if p > Length(s) then
    p := 0;
  q := posn('@', s, -1);
  if q > Length(s) then
    q := 0;
  if (p = 0) and (q = 0) then
  begin (* no user, password or port *)
    host := s;
    exit;
  end
  else
    if q < p then
    begin (* a port given *)
      port := copy(s, p + 1, Length(s));
      host := copy(s, q + 1, p - q - 1);
      if q = 0 then
        exit; (* no user, password *)
      s := copy(s, 1, q - 1);
    end
    else
    begin
      host := copy(s, q + 1, Length(s));
      s := copy(s, 1, q - 1);
    end;
  p := Pos(':', s);
  if p = 0 then
  begin
    user := s
  end
  else
  begin
    user := copy(s, 1, p - 1);
    pass := copy(s, p + 1, Length(s));
  end;
end;

end.

