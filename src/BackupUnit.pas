
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

{ Backup Thread}

unit BackupUnit;

interface

uses
  Windows, Classes, SysUtils, MesajUnit;

type

  TBackUp = class(TThread)
  private
    FSettings: TFormatSettings; // Thread-safe string formatting context.
    FPriority: TThreadPriority; // Scheduling priority of TBackup.
    FCompDegree: string; // GZip compression degree.
    FDeletedBU: string; // Filenames of the backup files deleted by "Backup Preserve Policy".
    FDeletedMR: string; // Filenames of the #1 Mirror files deleted by "Backup Preserve Policy".
    FDeletedMR2: string; // Filenames of the #2 Mirror files deleted by "Backup Preserve Policy".
    FDeletedMR3: string; // Filenames of the #3 Mirror files deleted by "Backup Preserve Policy".
    FOldestFileName: string; // Filename of the oldest backup or mirror file
    FDeleteAll: Integer; // 0=Delete only oldest file,  1= Delete all out-of-criteria backup files
    FPreserveUnit: Integer; // Basic Backup Preserve styles
    FPreserveCount: Integer; // Value of preserve style.
    FErrorInfo: string; // Basic error information
    FBackupNo: string; // Backup list number
    FZippedBackupFile: string; // Fully qualified path of GZipped backup file
    FZippedMirrorFile: string; // Fully qualified path of GZipped mirror file #1
    FZippedMirrorFile2: string; // Fully qualified path of GZipped mirror file #2
    FZippedMirrorFile3: string; // Fully qualified path of GZipped mirror file #3
    FTempDir: string; // Temporary files directory
    FTempBackFileName: string; // Fully qualified path of temporary file for backup
    FCompressBackup: Boolean; // 0= Do not create compressed backup, 1=Create compressed Backup
    FExternalFile: string; // Fully qualified path of external files to be runned
    FShowExternalWin: Boolean; // if True, the output windows of the external file is shown.
    FUseParams: Boolean; // if True, the last backup file's name is passed to external files as a parameter
    FSmtpServer: string; // SMTP Server address
    FSendersMail: string; // Mail account
    FMailUserName: string; // User Name
    FMailPassword: string; // Password
    FMailTo: string; // Receiver email address' delimited by column (;)
    FAlarm: TDateTime; // DateTime to Backup
    FConnectionType: DWORD; // FTP Connection Mode. 0= Active Mode,  $08000000=Passive Mode
    FManAuto: Boolean; // 0=Manual Mode, 1=Automatic Mode
    FDoValidate: Boolean; // if True, database validation will be done
    FCreateTime: string; // Thread create time
    FFullGBakParams: string; // Command line parameter to be used to run GBak.exe including output capture
    FGBakParams: string; // Command line parameter to be used to run GBak.exe
    FGFixParams: string; // Command line parameter to be used to run GFix.exe
    FTempValFileName: string; // Fully qualified path of temporary file for validation
    FDir: string; // FIBS Directory
    FTaskName: string; // Name of current backup task.
    FDatabaseFile: string; // Name of current backup task.
    FBackupFile: string; // Fully qualified filename of backup file
    FDoMirror: Boolean; // if True, backup file is copied onto Mirror #1
    FDoMirror2: Boolean; // if True, backup file is copied onto Mirror #2
    FDoMirror3: Boolean; // if True, backup file is copied onto Mirror #3
    FMirrorFile: string; // Fully qualified filename of Mirror File #1
    FMirrorFile2: string; // Fully qualified filename of Mirror File #2
    FMirrorFile3: string; // Fully qualified filename of Mirror File #3
    FLogFile: string; // Fully qualified filename of Log file for current task.
    FBackupOptions: string; // GBak switches
    FTempOrBackupFileSize: string; // Size of backup file in bytes
    PD: TMesajForm; // Message Dialog which shows the current process
    FSequenceIncremented: Boolean;
    FArchiveDir: string;
  protected
    function StrToOEM(s: string): string;
    function GetTempPath: string;
    function ConvertFileTime(LFT: TFileTime): TDateTime;
    function IsConnectedToInternet: Boolean;
    function GetTempBackupFileSize(const ATempFile: string): string;
    function WriteLog(ALogInfo: string): Integer;
    function ProgramRunWait(CommandLine, CurrentDir: string; Wait: Boolean): Boolean;
    function ProgramRunWaitRedirected(TempFileName, CommandLine, DatabaseToVal, CurrentDir: string; var Info: string; Wait: Boolean): Boolean;
    function CreateTemporaryFilename(const TempDirectory: string; var ATempFileName: string): Boolean;
    function DeleteOldest(ACurrentDir, ADirInfo: string): string;
    function DeleteLocalOldest(ACurrentDir, ADirInfo: string): string;
    function DeleteRemoteOldest(ACurrentDir, ADirInfo: string): string;
    function CreateEmail(const EmailAddr, cc, Subject, Body, Attach: string): Boolean;
    function FtpUploadFileEX(InternetAccessType: DWORD; ProxyName, ProxyByPass, strHost, strUser, strPwd: string; InternetService, port: Integer; LocalFilePath, RemoteDir, RemoteFilePath: string; TransferType, ConnectionType: DWORD; var AErrorMesaj: string): Boolean;
    function MirrorFileEx(ASourceFile: string; var ADestFile, AFtpErrorMesaj: string; AConnectionType: DWORD): LongBool;
    function ExtractFilePathEx(const AFullPath: string): string;
    procedure ShowPD; // Creates TMesajForm and passed handle to variable PD.
    procedure RefreshPD10; // Process Messages
    procedure RefreshPD11;
    procedure RefreshPD12;
    procedure RefreshPD13;
    procedure RefreshPD20;
    procedure RefreshPD22;
    procedure RefreshPD23;
    procedure RefreshPD30;
    procedure RefreshPD31;
    procedure RefreshPD40;
    procedure HidePD; // Hides and frees TMesajForm
    procedure Execute; override;
  public
    constructor Create(AAlarm: TDateTime;
      AParams, VParams, ADir, ATaskName, ABackupOptions,
      ADatabaseFile, ABackupFile, AMirrorFile, AMirrorFile2,
      AMirrorFile3, ALogFile, ABackupNo, ACompDegree,
      ASmtpServer, ASendersMail, AMailUserName, AMailPassword,
      AMailTo, AExternalFile: string;
      AUseParams, AShowExternalWin, ADoMirror, ADoMirror2, ADoMirror3, AManAuto,
      ACompressBackup, ADoValidate: Boolean;
      APCount, APUnit, ADeleteAll, AFtpConnType: Integer;
      ABackupPriority: TThreadPriority; ASequenceIncremented: Boolean; AArchiveDir: string);
  end;

implementation

uses WinInet, ShellApi, Forms, StrUtils, DateUtils, UDFConst, smtpsend, FunctionsUnit, EmailUnit;

//By Lance leonard
//http://www.techtricks.com/delphi/sendmail.php

function TBackUp.ConvertFileTime(LFT: TFileTime): TDateTime;
var
  FDFT: DWORD;
  w: Word;
begin
  Result := 0;
  if FileTimeToDosDateTime(LFT, w, LongRec(FDFT).Lo) then
    Result := FileDateToDateTime(FDFT);
end;

function TBackUp.ExtractFilePathEx(const AFullPath: string): string;
begin
  if AnsiLowerCase(AnsiLeftStr(Trim(AFullPath), 6)) = 'ftp://' then
  begin
    Result := copy(AFullPath, 1, LastDelimiter('/', AFullPath) - 1);
  end
  else
    Result := ExtractFilePath(AFullPath);
end;

function TBackUp.GetTempPath: string;
var
  Buffer: array[0..MAX_PATH] of Char;
begin
  Windows.GetTempPath(sizeof(Buffer), @Buffer);
  Result := Buffer;
end;

function TBackUp.GetTempBackupFileSize(const ATempFile: string): string;
var
  hFile: TFileStream;
begin
  if FileExists(ATempFile) then
  begin
    hFile := TFileStream.Create(ATempFile, fmOpenRead + fmShareDenyNone);
    try
      Result := FormatFloat('#,', hFile.size, FSettings);
    finally
      hFile.Free;
    end;
  end
  else
    Result := ATempFile + ' is not exists !!';
end;

function TBackUp.CreateEmail(const EmailAddr, cc, Subject, Body, Attach: string): Boolean;
begin
  EmailUnit.SendEmail(FSendersMail, EmailAddr, Subject, FSmtpServer, Body, FMailUserName, FMailPassword);
end;

function TBackUp.DeleteOldest(ACurrentDir, ADirInfo: string): string;
begin
  if AnsiLowerCase(AnsiLeftStr(Trim(ACurrentDir), 6)) = 'ftp://' then
    Result := DeleteRemoteOldest(ACurrentDir, ADirInfo)
  else
    Result := DeleteLocalOldest(ACurrentDir, ADirInfo);
end;

function TBackUp.DeleteRemoteOldest(ACurrentDir, ADirInfo: string): string;
begin
  Result := 'No Backup File has been deleted in ' + ADirInfo + ' because of not supporting the remote file deletion on FTP Mirrors yet !!'#13#10'   ';
end;

{
 Below given functions does not works correctly with all ftp servers
 because it cannot index remote files by file date-time.

function TBackup.DeleteRemoteOldest(ACurrentDir,ADirInfo:string):string;
var
  hNet, hFTP,hsearch: HINTERNET;
  finddata: TWin32FindData;
  SearchRec : TSearchRec;

  RemFilePath:array[0..999] of Char;
  AErrorMesaj:string;
  TS:TStringList;
  s,t,Key,NameExt,Ext:string;
  i,PDot:integer;
  TestTime,OldestFileAge:TDateTime;
  OldestFileAgeStr:string;
  Deleted,ff:Boolean;
  DeletedFilesCount,TryCount:integer;
  DeletedFiles:string;
  Liste:string;

  ProxyName,ProxyByPass: string;
  FtpUserName,FtpPassword,FtpHost,FtpDir,FtpFile:string;
  p1,p2,p3,p4,p5:integer;
  ax,bx:extended;
begin
  Result := '';
  AErrorMesaj:='';
  ACurrentDir:=trim(ACurrentDir);
  ACurrentDir:=AnsiReplaceStr(ACurrentDir,'\','/');
  if RightStr(ACurrentDir,1)<>'/' then  ACurrentDir:=ACurrentDir+'/';
  p1:=PosEx(':',ACurrentDir,7);
  p2:=Pos('@',ACurrentDir);
  p3:=PosEx('/',ACurrentDir,7);
  p4:=LastDelimiter('/',ACurrentDir);
  if p4<5 then p4:=0;
  p5:=Length(ACurrentDir);
  FtpUserName:=copy(ACurrentDir,7,p1-6-1);
  FtpPassword:=copy(ACurrentDir,p1+1,p2-p1-1);
  FtpHost:=copy(ACurrentDir,p2+1,p3-p2-1);
  FtpDir:='/'+copy(ACurrentDir,p3+1,p4-p3-1)+'/';
//  FtpFile:=copy(ACurrentDir,p4+1,p5-p4);
  hNet := InternetOpen('Program_Name', // Agent
                        INTERNET_OPEN_TYPE_PRECONFIG, // AccessType
                        PChar(ProxyName),
                        PChar(ProxyBypass),
                        0);
  if hNet = nil then
  begin
    result:='   Unable to get access to WinInet.Dll'#13#10'   ';
    Exit;
  end;
  hFTP := InternetConnect(hNet, // Handle from InternetOpen
                          PChar(FtpHost),
                          INTERNET_DEFAULT_FTP_PORT,
                          PChar(FtpUserName),
                          PChar(FtpPassword),
                          INTERNET_SERVICE_FTP,
                          0,
                          0);
  if hFTP = nil then
  begin
    InternetCloseHandle(hNet);
    result:=Format('   Host "%s" is not available',[FtpHost],FSettings);
    Exit;
  end;

  if FtpSetCurrentDirectory(hFTP, PChar(FtpDir))=false then
  begin
    InternetCloseHandle(hNet);
    InternetCloseHandle(hFTP);
    Result:='   '+FtpDir+' is not available';
    exit;
  end;
    result:='';
    TryCount:=0;
    DeletedFiles:='';
    DeletedFilesCount:=0;
    NameExt:=ExtractFileName(FDatabaseFile);
    Ext:=ExtractFileExt(FDatabaseFile);
    Key:=FTaskName+'*';
    TS:=TStringList.Create;
    TS.Sorted:=true;
    try
      hSearch := FtpFindFirstFile(hFTP,PChar(Key),findData,0,0);
      if hSearch = nil then
      begin
      end else
      begin
        repeat
          s:=FloatToStr(ConvertFileTime(finddata.ftLastWriteTime),FSettings);
          PDot:=Pos(DecimalSeparator,s);
          if (PDot=0) then s:='0000000000'+s+DecimalSeparator+'0' else s:='0000000000'+s;
          PDot:=Pos(DecimalSeparator,s);
          s:=copy(s,PDot-10,20);
          TS.Add(s+' - '+finddata.cFileName);
        until not InternetFindNextFile(hSearch,@findData);
        InternetCloseHandle(hSearch);
      end;
      t:=TS.Text;
      TestTime:=Now;
      if (FDeleteAll=0) then
      begin
        //Sadece en eski tarihli dosya siliniyor
        Deleted:=false;
        OldestFileAge:=StrToFloat((copy(TS[0],1,Pos(' - ',TS[0])-1)),FSettings); // En eski dosya
        OldestFileAgeStr:=DateTimeToStr(OldestFileAge,FSettings);
        FOldestFileName:=RightStr(TS[0],Length(TS[0])-Pos(' - ',TS[0])-3+1);
        if (FPreserveUnit=0)then  if (TS.Count>FPreserveCount) then
        begin
          inc(TryCount);
          Deleted:=FtpDeleteFile(hFTP,PChar(FtpDir+FOldestFileName)); //Son ..kopya
        end;
        if (FPreserveUnit=1)then  if (OldestFileAge<(TestTime-FPreserveCount/24))then
        begin
          inc(TryCount);
          Deleted:=FtpDeleteFile(hFTP,PChar(FtpDir+FOldestFileName));
        end;
        if (FPreserveUnit=2)then  if (OldestFileAge<(TestTime-FPreserveCount))   then
        begin
          inc(TryCount);
          Deleted:=FtpDeleteFile(hFTP,PChar(FtpDir+FOldestFileName));
        end;
        if (FPreserveUnit=3)then  if (OldestFileAge<(TestTime-FPreserveCount*30))then
        begin
          inc(TryCount);
          Deleted:=FtpDeleteFile(hFTP,PChar(FtpDir+FOldestFileName));
        end;
        if Deleted then inc(DeletedFilesCount);
        if TryCount>0 then
        begin
          if (DeletedFilesCount=TryCount)
             then Result:='The oldest backup file in '+ADirInfo+' ('+FOldestFileName+' '+OldestFileAgeStr+') has been deleted.'#13#10'   '+AErrorMesaj+#13#10'   '
             else Result:='ERROR !! The oldest backup file in '+ADirInfo+' ('+FOldestFileName+' '+OldestFileAgeStr+') couldn''t deleted.'#13#10'   '+AErrorMesaj+#13#10'   ';
        end else Result:='There is no out-of-criteria backup file to delete in '+ADirInfo+''#13#10'   ';
      end else
      begin
        //Bütün krýtere uymayanlar siliniyor
        for i:=0 to TS.Count-1 do
        begin
          Deleted:=false;
          OldestFileAge:=StrToFloat((copy(TS[i],1,Pos(' - ',TS[i])-1)),FSettings); // En eski dosya
          OldestFileAgeStr:=DateTimeToStr(OldestFileAge,FSettings);
          FOldestFileName:=RightStr(TS[i],Length(TS[i])-Pos(' - ',TS[i])-3+1);
          if (FPreserveUnit=0)then  if (TS.Count>FPreserveCount) then
          begin
            inc(TryCount);
            Deleted:=FtpDeleteFile(hFTP,PChar(FtpDir+FOldestFileName)); //Son ..kopya
          end;
          ax:=TestTime-FPreserveCount/24;
          bx:=OldestFileAge-ax;
          if (FPreserveUnit=1)then  if (OldestFileAge<(TestTime-FPreserveCount/24)) then
          begin
            inc(TryCount);
            Deleted:=FtpDeleteFile(hFTP,PChar(FtpDir+FOldestFileName));
          end;
          if (FPreserveUnit=2)then  if (OldestFileAge<(TestTime-FPreserveCount)) then
          begin
            inc(TryCount);
            Deleted:=FtpDeleteFile(hFTP,PChar(FtpDir+FOldestFileName));
          end;
          if (FPreserveUnit=3)then  if (OldestFileAge<(TestTime-FPreserveCount*30)) then
          begin
            inc(TryCount);
            Deleted:=FtpDeleteFile(hFTP,PChar(FtpDir+FOldestFileName));
          end;
          if Deleted then
          begin
            DeletedFiles:=DeletedFiles+FOldestFileName+' '+OldestFileAgeStr+', ';
            inc(DeletedFilesCount);
          end;
        end;
        if TryCount>0 then
        begin
          if (DeletedFilesCount=0) then Result:='ERROR !! None of Out-of-criteria backup files in '+ADirInfo+' has been deleted.'#13#10'   '+AErrorMesaj+#13#10'   '
          else if DeletedFilesCount=TryCount then Result:='All Out-of-criteria backup files ('+DeletedFiles+') in the '+ADirInfo+' has been deleted.'#13#10'   '+AErrorMesaj+#13#10'   '
          else Result:='ERROR !! Only '+IntToStr(DeletedFilesCount)+' of '+IntToStr(TryCount)+' Out-of-criteria backup files ('+DeletedFiles+') in '+ADirInfo+' has been deleted.'#13#10'   '+AErrorMesaj+#13#10'   ';
        end else Result:='There is no out-of-criteria backup file to delete in '+ADirInfo+''#13#10'   ';
      end;
    finally
      TS.Free;
    end;
  InternetCloseHandle(hFTP);
  InternetCloseHandle(hNet);
end;
}

function TBackUp.DeleteLocalOldest(ACurrentDir, ADirInfo: string): string;
var
  SearchRec: TSearchRec;
  ts: TStringList;
  T, s, Key, NameExt, Ext: string;
  i, PDot: Integer;
  TestTime, OldestFileAge: TDateTime;
  OldestFileAgeStr: string;
  Deleted: Boolean;
  DeletedFilesCount, TryCount: Integer;
  DeletedFiles: string;
begin
  Result := '';
  TryCount := 0;
  DeletedFiles := '';
  DeletedFilesCount := 0;
  NameExt := ExtractFileName(FDatabaseFile);
  Ext := ExtractFileExt(FDatabaseFile);
  if (ACurrentDir[Length(ACurrentDir)] <> '\') then
    ACurrentDir := ACurrentDir + '\';
  Key := ACurrentDir + FTaskName + '*';
  ts := TStringList.Create;
  ts.Sorted := True;
  try
    if FindFirst(Key, faAnyFile, SearchRec) = 0 then
    begin
      repeat
        s := FloatToStr(FileDateToDateTime(SearchRec.Time), FSettings);
        PDot := Pos(DecimalSeparator, s);
        if (PDot = 0) then
          s := '0000000000' + s + DecimalSeparator + '0'
        else
          s := '0000000000' + s;
        PDot := Pos(DecimalSeparator, s);
        s := copy(s, PDot - 10, 20);
        ts.Add(s + ' - ' + SearchRec.Name);
      until FindNext(SearchRec) <> 0;
      FindClose(SearchRec);
      T := ts.Text;
      TestTime := Now;
      if (FDeleteAll = 0) then
      begin
        //Delete only the oldest file
        Deleted := False;
        OldestFileAge := StrToFloat((copy(ts[0], 1, Pos(' - ', ts[0]) - 1)), FSettings); // En eski dosya
        OldestFileAgeStr := DateTimeToStr(OldestFileAge, FSettings);
        FOldestFileName := RightStr(ts[0], Length(ts[0]) - Pos(' - ', ts[0]) - 3 + 1);
        if (FPreserveUnit = 0) then
          if ((ts.Count > FPreserveCount)) then
          begin
            inc(TryCount);
            Deleted := DeleteFile(PChar(ACurrentDir + FOldestFileName)); //Son ..kopya
          end;
        if (FPreserveUnit = 1) then
          if (OldestFileAge < (TestTime - FPreserveCount / 24)) then
          begin
            inc(TryCount);
            Deleted := DeleteFile(PChar(ACurrentDir + FOldestFileName));
          end;
        if (FPreserveUnit = 2) then
          if (OldestFileAge < (TestTime - FPreserveCount)) then
          begin
            inc(TryCount);
            Deleted := DeleteFile(PChar(ACurrentDir + FOldestFileName));
          end;
        if (FPreserveUnit = 3) then
          if (OldestFileAge < TestTime - FPreserveCount * 30) then
          begin
            inc(TryCount);
            Deleted := DeleteFile(PChar(ACurrentDir + FOldestFileName));
          end;
        if Deleted then
          inc(DeletedFilesCount);
        if TryCount > 0 then
        begin
          if (DeletedFilesCount = TryCount) then
            Result := 'The oldest backup file in ' + ADirInfo + ' (' + FOldestFileName + ' ' + OldestFileAgeStr + ') has been deleted.'#13#10
          else
            Result := 'ERROR !! The oldest backup file in ' + ADirInfo + ' (' + FOldestFileName + ' ' + OldestFileAgeStr + ') couldn''t deleted.'#13#10
        end
        else
          Result := 'There is no out-of-criteria backup file to delete in ' + ADirInfo + ''#13#10;
      end
      else
      begin
        // Delete all out-of-criteriaa files
        for i := 0 to ts.Count - 1 do
        begin
          Deleted := False;
          OldestFileAge := StrToFloat((copy(ts[0], 1, Pos(' - ', ts[0]) - 1)), FSettings); // En eski dosya
          OldestFileAgeStr := DateTimeToStr(OldestFileAge, FSettings);
          FOldestFileName := RightStr(ts[0], Length(ts[0]) - Pos(' - ', ts[0]) - 3 + 1);
          if (FPreserveUnit = 0) then
            if (ts.Count > FPreserveCount) then
            begin
              inc(TryCount);
              Deleted := DeleteFile(PChar(ACurrentDir + FOldestFileName)); //Son ..kopya
            end;
          if (FPreserveUnit = 1) then
            if (OldestFileAge < (TestTime - FPreserveCount / 24)) then
            begin
              inc(TryCount);
              Deleted := DeleteFile(PChar(ACurrentDir + FOldestFileName));
            end;
          if (FPreserveUnit = 2) then
            if (OldestFileAge < (TestTime - FPreserveCount)) then
            begin
              inc(TryCount);
              Deleted := DeleteFile(PChar(ACurrentDir + FOldestFileName));
            end;
          if (FPreserveUnit = 3) then
            if (OldestFileAge < TestTime - FPreserveCount * 30) then
            begin
              inc(TryCount);
              Deleted := DeleteFile(PChar(ACurrentDir + FOldestFileName));
            end;
          if Deleted then
          begin
            ts.Delete(0);
            DeletedFiles := DeletedFiles + FOldestFileName + ' ' + OldestFileAgeStr + ', ';
            inc(DeletedFilesCount);
          end;
        end;
        if TryCount > 0 then
        begin
          if (DeletedFilesCount = 0) then
            Result := 'ERROR !! None of Out-of-criteria backup files in ' + ADirInfo + ' has been deleted.'#13#10
          else
            if DeletedFilesCount = TryCount then
              Result := 'All Out-of-criteria backup files (' + DeletedFiles + ') in the ' + ADirInfo + ' has been deleted.'#13#10
            else
              Result := 'ERROR !! Only ' + IntToStr(DeletedFilesCount) + ' of ' + IntToStr(TryCount) + ' Out-of-criteria backup files (' + DeletedFiles + ') in ' + ADirInfo + ' has been deleted.'#13#10;
        end
        else
          Result := 'There is no out-of-criteria backup file to delete in ' + ADirInfo + ''#13#10;
      end;
    end;
  finally
    ts.Free;
  end;
end;

function TBackUp.CreateTemporaryFilename(const TempDirectory: string; var ATempFileName: string): Boolean;
const
  TMP_FILE_PREFIX = '~'; {Must be 3 characters or less}
var
  TemporaryFileName: array[0..MAX_PATH - 1] of Char;
begin
  Result := False;
  ATempFileName := '';
  if GetTempFileName(PChar(TempDirectory), TMP_FILE_PREFIX, 0, TemporaryFileName) > 0 then
  begin
    Result := True;
    ATempFileName := TemporaryFileName;
  end;
end;

function TBackUp.IsConnectedToInternet: Boolean;
var
  dwConnectionTypes: DWORD;
begin
  dwConnectionTypes := INTERNET_CONNECTION_MODEM +
    INTERNET_CONNECTION_LAN +
    INTERNET_CONNECTION_PROXY;
  Result := InternetGetConnectedState(@dwConnectionTypes, 0);
end;

//Author Talat Dogan. I've inspirated Thomas Stutz.

function TBackUp.FtpUploadFileEX(InternetAccessType: DWORD; ProxyName, ProxyByPass, strHost, strUser, strPwd: string; InternetService, port: Integer; LocalFilePath, RemoteDir, RemoteFilePath: string; TransferType, ConnectionType: DWORD; var AErrorMesaj: string): Boolean;
var
  hNet, hFTP: HINTERNET;
  PutFile: Boolean;
begin
  Result := False;
  //  Open an internet session
  hNet := InternetOpen('Program_Name', // Agent
    InternetAccessType, // AccessType
    PChar(ProxyName),
    PChar(ProxyByPass),
    0); // or INTERNET_FLAG_ASYNC / INTERNET_FLAG_OFFLINE
  // Agent contains the name of the application or entity calling the Internet functions
  // See if connection handle is valid
  if hNet = nil then
  begin
    AErrorMesaj := '   Unable to get access to WinInet.Dll';
    Exit;
  end;
  { Connect to the FTP Server }
  hFTP := InternetConnect(hNet, // Handle from InternetOpen
    PChar(strHost), // FTP server
    port, // (INTERNET_DEFAULT_FTP_PORT),
    PChar(strUser), // username
    PChar(strPwd), // password
    InternetService, //INTERNET_SERVICE_FTP = 1; INTERNET_SERVICE_GOPHER = 2; INTERNET_SERVICE_HTTP = 3;
    ConnectionType, // flag: 0 or INTERNET_FLAG_PASSIVE
    0); // User defined number for callback
  if hFTP = nil then
  begin
    InternetCloseHandle(hNet);
    AErrorMesaj := Format('   Host "%s" is not available', [strHost], FSettings);
    Exit;
  end;

  if (RemoteDir <> '') then
  begin
    if FtpSetCurrentDirectory(hFTP, PChar(RemoteDir)) = False then
    begin
      if FtpCreateDirectory(hFTP, PChar(RemoteDir)) = False then
      begin
        InternetCloseHandle(hFTP);
        InternetCloseHandle(hNet);
        AErrorMesaj := Format('   Cannot Create directory to %s.', [RemoteDir], FSettings);
        Exit;
      end
      else
        FtpSetCurrentDirectory(hFTP, PChar(RemoteDir));
    end;
  end;
  { Upload file }
  PutFile := FtpPutFile(hFTP, // Handle to the ftp session
    PChar(LocalFilePath), // filename
    PChar(RemoteFilePath), // filename
    TransferType, // dwFlags
    0); // This is the context used for callbacks.
  if PutFile = False then
  begin
    InternetCloseHandle(hFTP);
    InternetCloseHandle(hNet);
    AErrorMesaj := Format('   Cannot upload backup file (' + RemoteFilePath + ') to host %s.', [strHost], FSettings);
    Exit;
  end;
  InternetCloseHandle(hFTP);
  InternetCloseHandle(hNet);
  Result := True;
end;

function TBackUp.MirrorFileEx(ASourceFile: string; var ADestFile, AFtpErrorMesaj: string; AConnectionType: DWORD): LongBool;
var
  FtpUserName, FtpPassword, FtpHost, FtpDir, FtpFile: string;
  FtpPort, FColPos, FAtPos, FDirPos, LLDirPos, LenPath: Integer;
  // LLColPos,LLAtPos :integer;
begin
  AFtpErrorMesaj := '';
  ADestFile := Trim(ADestFile);
  if AnsiLowerCase(AnsiLeftStr(ADestFile, 6)) = 'ftp://' then
  begin
    ADestFile := AnsiReplaceStr(ADestFile, '\', '/');
    FColPos := PosEx(':', ADestFile, 7);
    //  LLColPos:=LastDelimiter(':',ADestFile);
    FAtPos := Pos('@', ADestFile);
    //  LLAtPos:=LastDelimiter('@',ADestFile);
    FDirPos := PosEx('/', ADestFile, 7);
    LLDirPos := LastDelimiter('/', ADestFile);
    LenPath := Length(ADestFile);

    FtpUserName := copy(ADestFile, 7, FColPos - 6 - 1);
    FtpPassword := copy(ADestFile, FColPos + 1, FAtPos - FColPos - 1);
    FtpHost := copy(ADestFile, FAtPos + 1, FDirPos - FAtPos - 1);
    FtpDir := copy(ADestFile, FDirPos + 1, LLDirPos - FDirPos - 1);
    FtpFile := copy(ADestFile, LLDirPos + 1, LenPath - LLDirPos);
    FtpPort := 21;

    Result := FtpUploadFileEX(INTERNET_OPEN_TYPE_PRECONFIG,
      '', '',
      FtpHost, FtpUserName, FtpPassword,
      //                     INTERNET_SERVICE_FTP,21,
      INTERNET_SERVICE_FTP, FtpPort,
      ASourceFile, FtpDir, FtpFile,
      FTP_TRANSFER_TYPE_BINARY, AConnectionType, AFtpErrorMesaj);
    if AFtpErrorMesaj <> '' then
      AFtpErrorMesaj := AFtpErrorMesaj + #13#10;
  end
  else
    Result := CopyFile(PChar(ASourceFile), PChar(ADestFile), False);
end;

function TBackUp.WriteLog(ALogInfo: string): Integer;
var
  F: TextFile;
  LogDir: string;
begin
  Result := 0;
  LogDir := ExtractFileDir(FLogFile);
  try
    AssignFile(F, FLogFile);
    FileMode := fmOpenWrite + fmShareDenyWrite;
    if FileExists(FLogFile) = False then
      Rewrite(F);
    Append(F);
    write(F, ALogInfo);
    Flush(F);
    CloseFile(F);
  except
  end;
end;

function TBackUp.ProgramRunWait(CommandLine, CurrentDir: string; Wait: Boolean): Boolean;
var
  StartupInfo: TStartupInfo;
  ProcessInfo: TProcessInformation;
  pCurrentDir: PChar;
  ExitCode: DWORD;
  CreResult: LongBool;
begin
  Result := False;
  //Fill the record with 0's so you don't pass in random bollox to the API call
  FillChar(StartupInfo, sizeof(StartupInfo), 0);
  //and tell it the size of itself
  StartupInfo.cb := sizeof(StartupInfo);
  StartupInfo.dwFlags := STARTF_USESHOWWINDOW;
  StartupInfo.wShowWindow := SW_HIDE; //setup default dir

  if CurrentDir <> '' then
    pCurrentDir := PChar(CurrentDir)
  else
    pCurrentDir := nil;
  //Now do the API call
  CreResult := CreateProcess(nil, PChar(CommandLine), nil, nil, False, 0, nil, pCurrentDir, StartupInfo, ProcessInfo);
  if CreResult = True then
    //lpApplication??
  begin
    try
      if Wait then
      begin
        case WaitForSingleObject(ProcessInfo.hProcess, {12000)//test} INFINITE) of
          WAIT_ABANDONED: ;
          //            MessageBox(0, PChar('WAIT_ABANDONED'), PChar('Process returned'), 0);
          WAIT_OBJECT_0: ;
          //            MessageBox(0, PChar('WAIT_OBJECT_0'), PChar('Process returned'), 0);
          WAIT_TIMEOUT: ;
          //            MessageBox(0, PChar('WAIT_TIMEOUT'), PChar('Process returned'), 0);
          WAIT_FAILED: ;
          //            MessageBox(0, PChar('WAIT_FAILED'), PChar('Process returned'), 0);
        end;
        GetExitCodeProcess(ProcessInfo.hProcess, ExitCode);
        Result := (ExitCode = 0);
      end;
    finally
      CloseHandle(ProcessInfo.hThread);
      CloseHandle(ProcessInfo.hProcess);
    end;
  end
  else
    Result := False;
end;

function TBackUp.ProgramRunWaitRedirected(TempFileName, CommandLine, DatabaseToVal, CurrentDir: string; var Info: string; Wait: Boolean): Boolean;
var
  StartupInfo: TStartupInfo;
  ProcessInfo: TProcessInformation;
  pCurrentDir: PChar;
  ExitCode: DWORD;
  CreResult: LongBool;

  tmpName: string;
  tmp: Windows.THandle;
  tmpSec: TSecurityAttributes;
  res: TStringList;
begin
  Result := False;
  //  tmpName := 'Test.tmp';
  tmpName := TempFileName;
  FillChar(tmpSec, sizeof(tmpSec), #0);
  tmpSec.nLength := sizeof(tmpSec);
  tmpSec.bInheritHandle := True;
  tmp := Windows.CreateFile(PChar(tmpName),
    Generic_Write, File_Share_Write,
    @tmpSec, Create_Always, File_Attribute_Normal, 0);

  //Fill the record with 0's so you don't pass in random bollox to the API call
  FillChar(StartupInfo, sizeof(StartupInfo), 0);
  //and tell it the size of itself
  StartupInfo.cb := sizeof(StartupInfo);
  StartupInfo.hStdError := tmp;
  StartupInfo.dwFlags := STARTF_USESTDHANDLES or STARTF_USESHOWWINDOW;
  StartupInfo.wShowWindow := SW_HIDE; //setup default dir

  if CurrentDir <> '' then
    pCurrentDir := PChar(CurrentDir)
  else
    pCurrentDir := nil;
  //Now do the API call
  CreResult := CreateProcess(nil, PChar(CommandLine + ' ' + DatabaseToVal), nil, nil, True, 0, nil, pCurrentDir, StartupInfo, ProcessInfo);
  if CreResult = True then
    //lpApplication??
  begin
    try
      if Wait then
      begin
        case WaitForSingleObject(ProcessInfo.hProcess, {12000)//test} INFINITE) of
          WAIT_ABANDONED: ;
          //            MessageBox(0, PChar('WAIT_ABANDONED'), PChar('Process returned'), 0);
          WAIT_OBJECT_0: ;
          //            MessageBox(0, PChar('WAIT_OBJECT_0'), PChar('Process returned'), 0);
          WAIT_TIMEOUT: ;
          //            MessageBox(0, PChar('WAIT_TIMEOUT'), PChar('Process returned'), 0);
          WAIT_FAILED: ;
          //            MessageBox(0, PChar('WAIT_FAILED'), PChar('Process returned'), 0);
        end;
        GetExitCodeProcess(ProcessInfo.hProcess, ExitCode);
        Result := (ExitCode = 0);
      end;
    finally
      CloseHandle(ProcessInfo.hThread);
      CloseHandle(ProcessInfo.hProcess);
      CloseHandle(tmp);
      Info := '';
      res := TStringList.Create;
      try
        res.LoadFromFile(tmpName);
        Info := res.Text;
      finally
        res.Free;
      end;
      Windows.DeleteFile(PChar(tmpName));
    end;
  end
  else
  begin
    Info := CommandLine + ' couldn''t been executed ..';
    Result := False;
  end;
end;

constructor TBackUp.Create(AAlarm: TDateTime;
  AParams, VParams, ADir, ATaskName, ABackupOptions,
  ADatabaseFile, ABackupFile, AMirrorFile, AMirrorFile2,
  AMirrorFile3, ALogFile, ABackupNo, ACompDegree,
  ASmtpServer, ASendersMail, AMailUserName, AMailPassword,
  AMailTo, AExternalFile: string;
  AUseParams, AShowExternalWin, ADoMirror, ADoMirror2,
  ADoMirror3, AManAuto, ACompressBackup, ADoValidate: Boolean;
  APCount, APUnit, ADeleteAll, AFtpConnType: Integer;
  ABackupPriority: TThreadPriority; ASequenceIncremented: Boolean; AArchiveDir: string);
begin
  inherited Create(True);
  GetLocaleFormatSettings(SysLocale.DefaultLCID, FSettings);
  FPriority := ABackupPriority;
  FCompDegree := ACompDegree;
  FDeleteAll := ADeleteAll;
  FPreserveCount := APCount;
  FPreserveUnit := APUnit;
  FBackupNo := ABackupNo;
  FCompressBackup := ACompressBackup;
  FExternalFile := AExternalFile;
  FUseParams := AUseParams;
  FShowExternalWin := AShowExternalWin;
  FSmtpServer := ASmtpServer;
  FSendersMail := ASendersMail;
  FMailUserName := AMailUserName;
  FMailPassword := AMailPassword;
  FMailTo := AMailTo;
  FDoValidate := ADoValidate;
  FAlarm := AAlarm;
  FCreateTime := DateTimeToStr(Now, FSettings);
  FDoMirror := ADoMirror;
  FDoMirror2 := ADoMirror2;
  FDoMirror3 := ADoMirror3;
  if AFtpConnType = 0 then
    FConnectionType := 0 //Active Mode
  else
    FConnectionType := INTERNET_FLAG_PASSIVE; // Passive Mode

  FManAuto := AManAuto;
  FGBakParams := AParams + ' -y ' + GetTempPath + '~fibs_gbakout_' + FBackupNo + '.tmp';
  FGFixParams := VParams;
  FTempValFileName := GetTempPath + '~fibs_gfixout_' + FBackupNo + '.tmp';
  FDir := ADir;
  FTaskName := FunctionsUnit.RemoveDatabaseSequenceTokens(ATaskName);

  FDatabaseFile := FunctionsUnit.RemoveDatabaseSequenceTokens(ADatabaseFile);
  //Beta-13   if Pos(' ',ADatabaseFile)>0 then FDatabaseFile:='"'+ADatabaseFile+'"';
    //Dikkat sadece yukarý satýr Ver. 1.0.4

  FErrorInfo := '';

  FBackupFile := FunctionsUnit.RemoveDatabaseSequenceTokens(ABackupFile);
  //Beta-13  if Pos(' ',ABackupFile)>0 then FBackupFile:='"'+ABackupFile+'"';

  FMirrorFile := FunctionsUnit.RemoveDatabaseSequenceTokens(AMirrorFile);
  FMirrorFile2 := FunctionsUnit.RemoveDatabaseSequenceTokens(AMirrorFile2);
  FMirrorFile3 := FunctionsUnit.RemoveDatabaseSequenceTokens(AMirrorFile3);
  FLogFile := FunctionsUnit.RemoveDatabaseSequenceTokens(ALogFile);
  FBackupOptions := ABackupOptions;
  FSequenceIncremented := ASequenceIncremented;
  FArchiveDir := AArchiveDir;
  FreeOnTerminate := True;
  Priority := FPriority;
end;

procedure TBackUp.ShowPD;
begin
  PD := ShowProsesDlg('Back up task "' + FTaskName + '" is executing'#13#10'BackUp is preparing..', 'c', '');
end;

procedure TBackUp.RefreshPD10;
begin
  RefreshProsesDlg('Back up task "' + FTaskName + '" is executing'#13#10'BackUp File is GZipping..', 'c', PD);
end;

procedure TBackUp.RefreshPD11;
begin
  //  RefreshProsesDlg('Back up task "'+FTaskName+'" is executing'#13#10'BackUp File is GZipping..'+#13#10'MakeZip OK','c',PD);
  RefreshProsesDlg('Back up task "' + FTaskName + '" is executing'#13#10'Database is Validating..', 'c', PD);
end;

procedure TBackUp.RefreshPD12;
begin
  RefreshProsesDlg('Back up task "' + FTaskName + '" is executing'#13#10'BackUp is preparing..', 'c', PD);
end;

procedure TBackUp.RefreshPD13;
begin
  //  RefreshProsesDlg('Back up task "'+FTaskName+'" is executing'#13#10'BackUp File is GZipping..'+#13#10'CloseZip OK','c',PD);
  RefreshProsesDlg('Back up task "' + FTaskName + '" is executing'#13#10'Sending EMail Notification..' + #13#10'', 'c', PD);
end;

procedure TBackUp.RefreshPD20;
begin
  RefreshProsesDlg('Back up task "' + FTaskName + '" is executing'#13#10'BackUp File is mirroring to Mirror #1..', 'c', PD);
end;

procedure TBackUp.RefreshPD22;
begin
  RefreshProsesDlg('Back up task "' + FTaskName + '" is executing'#13#10'BackUp File is mirroring to Mirror #2..', 'c', PD);
end;

procedure TBackUp.RefreshPD23;
begin
  RefreshProsesDlg('Back up task "' + FTaskName + '" is executing'#13#10'BackUp File is mirroring to Mirror #3..', 'c', PD);
end;

procedure TBackUp.RefreshPD30;
begin
  RefreshProsesDlg('Back up task "' + FTaskName + '" is executing'#13#10'Out-of-Criteria files is deleting in backup dir and mirrors dir(s)..', 'c', PD);
end;

procedure TBackUp.RefreshPD31;
begin
  RefreshProsesDlg('Back up task "' + FTaskName + '" is executing'#13#10 + FExternalFile + 'is starting to be done extra task.', 'c', PD);
end;

procedure TBackUp.RefreshPD40;
begin
  RefreshProsesDlg('Back up task "' + FTaskName + '" is executing'#13#10'Writing in LOG..', 'c', PD);
end;

procedure TBackUp.HidePD;
begin
  HideProsesDlg(PD);
end;

procedure TBackUp.Execute;
var
  AStartTime, AEndTime: TDateTime;
  BackupInfoStr: string;
  MailBody, BUPath, MirrorPath, MirrorPath2, MirrorPath3, MMail, MDel, MBack, MFtpCopy, MFtpCopy2, MFtpCopy3, MCopy, MCopy2, MCopy3, MAuto: string;
  ValidateOK, EMailOK, TempOK, ZipOK, BCreOK, BackOK, CopyOK, CopyOK2, CopyOK3: LongBool;
  GOut, GFixOut, ss, BackupExt, AEndTimeStr: string;
  i, CompLevel: Integer;
  MirrorIsFtp, Mirror2IsFtp, Mirror3IsFtp: Boolean;
  BatchFileOk: Boolean;
  ParamsToBatch, MBatch: string;
  TX: TStrings;
  FtpModeInfoA, FtpModeInfoB: string;
  ExternalResultCode: cardinal;
  sArchiveFile: string;
  sMsgArchive: string;
  cmd7z: string;
  sBackupFileName: string;
begin
  Synchronize(ShowPD);
  try
    //    try
    AStartTime := Now;
    FTempDir := GetTempPath;
    TempOK := False;
    FErrorInfo := '';
    MailBody := 'Below listed errors has been encountered at the backup of Task ' + FTaskName + ' BackupNo :' + FBackupNo;
    //****** Validating Routines  ***************
    ValidateOK := False;
    if FDoValidate then
    begin
      Synchronize(RefreshPD11);
      ProgramRunWaitRedirected(FTempValFileName, FGFixParams, '"' + FDatabaseFile + '"', '', GFixOut, True);
      if GFixOut = '' then
      begin
        ValidateOK := True;
        GFixOut := 'Database was validated (before backup) by using gfix with -v -n switches. No validation error was found..'#13#10;
      end
      else
      begin
        TX := TStringList.Create;
        try
          TX.Text := GFixOut;
          TX.Insert(0, '--------------------------------------------------------------------------------------   GFix.exe Output   ----------------------------------------------------------------------------------');
          TX.Add('---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------');
          for i := 0 to TX.Count - 1 do
            TX[i] := '   ' + TX[i];
          GFixOut := TX.Text;
        finally
          TX.Free;
        end;
        MailBody := MailBody + #13#10#13#10 + FTaskName + ' has encountered database Validating Error !!';
        ValidateOK := False;
      end;
    end;
    //****** ***********************************
    Synchronize(RefreshPD12);
    ss := FBackupFile;
    BackupExt := ExtractFileExt(FBackupFile);
    FBackupFile := copy(FBackupFile, 1, Pos(BackupExt, FBackupFile) - 1) + '-' + FBackupNo + BackupExt;
    BackupExt := ExtractFileExt(FBackupFile);
    FMirrorFile := copy(FMirrorFile, 1, Pos(BackupExt, FMirrorFile) - 1) + '-' + FBackupNo + BackupExt;
    FMirrorFile2 := copy(FMirrorFile2, 1, Pos(BackupExt, FMirrorFile2) - 1) + '-' + FBackupNo + BackupExt;
    FMirrorFile3 := copy(FMirrorFile3, 1, Pos(BackupExt, FMirrorFile3) - 1) + '-' + FBackupNo + BackupExt;

    BUPath := ExtractFilePath(FBackupFile);
    //  FZippedBackupFile:=ChangeFileExt(FBackupFile,'.ZIP');
    //  FZippedMirrorFile:=ChangeFileExt(FMirrorFile,'.ZIP');
    //  FZippedBackupFile:=ChangeFileExt(FBackupFile,'.GZ');
    //  FZippedMirrorFile:=ChangeFileExt(FMirrorFile,'.GZ');

    if DirectoryExists(BUPath) = False then
      BCreOK := False
    else
      BCreOK := True;
    if BCreOK = True then
    begin
      if FCompressBackup then
      begin
        if DirectoryExists(FTempDir) = False then
        begin
          if CreateDir(FTempDir) then
            TempOK := CreateTemporaryFilename(FTempDir, FTempBackFileName);
        end
        else
          TempOK := CreateTemporaryFilename(FTempDir, FTempBackFileName);
        //Yukarýdaki nüansa dikkat TempDir yaratýlamazsa TempOk:=false oluyor..

        if TempOK then //Eðer ZIP isteniyorsa Temp yaratýlmýþ olmalý
        begin
          BackOK := ProgramRunWait(FGBakParams + ' "' + FDatabaseFile + '" ' + FTempBackFileName, FDir, True);
          FFullGBakParams := FGBakParams + ' ' + FDatabaseFile + ' ' + FTempBackFileName;
          FTempOrBackupFileSize := GetTempBackupFileSize(FTempBackFileName);
          if BackOK then
          begin
            //Sadece BackOK=true ise FileSize kontrol edilmeli.
            // Yoksa yarým kalmýþ bir backup 'ýn boyutu 0'dan farklý olduðu için BackOK
            // olmasý iþten bile deðil !!!
            if FTempOrBackupFileSize > '0' then
              BackOK := True
            else
              BackOK := False;
          end;
        end
        else
          BackOK := False;
      end
      else
      begin
        BackOK := ProgramRunWait(FGBakParams + ' "' + FDatabaseFile + '" ' + ' "' + FBackupFile + '" ', FDir, True);
        FFullGBakParams := FGBakParams + ' ' + FDatabaseFile + ' ' + ' ' + FBackupFile + ' ';
        FTempOrBackupFileSize := GetTempBackupFileSize(FBackupFile);
        if BackOK then
        begin
          //Sadece BackOK=true ise FileSize kontrol edilmeli.
          // Yoksa yarým kalmýþ bir backup 'ýn boyutu 0'dan farklý olduðu için BackOK
          // olmasý iþten bile deðil !!!
          if FTempOrBackupFileSize > '0' then
            BackOK := True
          else
            BackOK := False;
        end;
      end;
    end
    else
      BackOK := False;

    if BackOK = False then
    begin
      TX := TStringList.Create;
      try
        TX.LoadFromFile(GetTempPath + '~fibs_gbakout_' + FBackupNo + '.tmp');
        TX.Insert(0, '--------------------------------------------------------------------------------------   GBak.exe Output   ----------------------------------------------------------------------------------');
        TX.Add('---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------');
        for i := 0 to TX.Count - 1 do
          TX[i] := '   ' + TX[i];
        GOut := TX.Text;
      finally
        TX.Free;
      end;
      MailBody := MailBody + #13#10 + FTaskName + ' has encountered Backup Error !! (1)';
    end
    else
      GOut := '';
    Windows.DeleteFile(PChar(GetTempPath + '~fibs_gbakout_' + FBackupNo + '.tmp'));

    CopyOK := False;
    CopyOK2 := False;
    CopyOK3 := False;
    ZipOK := False;
    if (BackOK and FCompressBackup) then // Backup tamam ise ve Zip Ýsteniyorsa
    begin
      Synchronize(RefreshPD10);
      try
        CompLevel := 65;
        if FCompDegree = 'None' then
          CompLevel := 0
        else
          if FCompDegree = 'Fastest' then
            CompLevel := 2
          else
            if FCompDegree = 'Default' then
              CompLevel := 5
            else
              if FCompDegree = 'Maximum' then
                CompLevel := 9;
        try
          Self.FZippedBackupFile := ChangeFileExt(Self.FBackupFile, '.GZ');
          Self.FZippedMirrorFile := ChangeFileExt(Self.FMirrorFile, '.GZ');
          Self.FZippedMirrorFile2 := ChangeFileExt(Self.FMirrorFile2, '.GZ');
          Self.FZippedMirrorFile3 := ChangeFileExt(Self.FMirrorFile3, '.GZ');

          RenameFile(Self.FTempBackFileName, ExtractFilePath(Self.FTempBackFileName) + ExtractFileName(Self.FBackupFile));
          Self.FTempBackFileName := ExtractFilePath(Self.FTempBackFileName) + ExtractFileName(Self.FBackupFile);

          cmd7z := ExtractFilePath(Application.ExeName) + '7za a -y -tgzip -mx "' + Self.FZippedBackupFile + '" "' + Self.FTempBackFileName + '"';
          ZipOK := Self.ProgramRunWait(cmd7z, Self.FDir, True);
        except
          ZipOK := False;
        end;
      finally

      end;
    end;

    if TempOK then
      DeleteFile(PChar(FTempBackFileName)); //Let's delete *.TMP yý silelim
    // if task is running in auto mode then delete oldest backup file
    if FManAuto = True then
    begin
      //if new backup is created then delete oldest backup file
      if BackOK then
      begin
        FDeletedBU := DeleteOldest(BUPath, 'the Backup Dir');
      end;
    end;
    MirrorIsFtp := False;
    if (BackOK and FDoMirror) then // Backup is OK and Mirroring onto #1 is wanted..
    begin
      Synchronize(RefreshPD20);
      MirrorPath := ExtractFilePathEx(FMirrorFile);
      if (lowercase(copy(MirrorPath, 1, 6)) = 'ftp://') then
        MirrorIsFtp := True
      else
        MirrorIsFtp := False;
      if FCompressBackup then
      begin
        if ZipOK then
          CopyOK := MirrorFileEx(FZippedBackupFile, FZippedMirrorFile, MFtpCopy, FConnectionType)
        else
          CopyOK := False;
      end
      else
        CopyOK := MirrorFileEx(FBackupFile, FMirrorFile, MFtpCopy, FConnectionType);
      // if task is running in auto mode then delete oldest file in the Mirror #1 directory.
      if FManAuto = True then
      begin
        // if mirroring onto Mirror #1 is OK then delete oldest file in the Mirror #1 directory.
        if CopyOK then
        begin
          FDeletedMR := DeleteOldest(MirrorPath, 'Mirror Dir #1');
        end;
      end;
    end;

    Mirror2IsFtp := False;
    if (BackOK and FDoMirror2) then // Backup tamam ise ve Mirroring Ýsteniyorsa
    begin
      Synchronize(RefreshPD22);
      MirrorPath2 := ExtractFilePathEx(FMirrorFile2);
      if (lowercase(copy(MirrorPath2, 1, 6)) = 'ftp://') then
        Mirror2IsFtp := True
      else
        Mirror2IsFtp := False;
      if FCompressBackup then
      begin
        if ZipOK then
          CopyOK2 := MirrorFileEx(FZippedBackupFile, FZippedMirrorFile2, MFtpCopy2, FConnectionType)
        else
          CopyOK2 := False;
      end
      else
        CopyOK2 := MirrorFileEx(FBackupFile, FMirrorFile2, MFtpCopy2, FConnectionType);
      // if task is running in auto mode then delete oldest file in the Mirror #2 directory.
      if FManAuto = True then
      begin
        // if mirroring onto Mirror #2 is OK then delete oldest file in the Mirror #2 directory.
        if CopyOK2 then
        begin
          FDeletedMR2 := DeleteOldest(MirrorPath2, 'Mirror Dir #2');
        end;
      end;
    end;

    Mirror3IsFtp := False;
    if (BackOK and FDoMirror3) then // Backup tamam ise ve Mirroring Ýsteniyorsa
    begin
      Synchronize(RefreshPD23);
      MirrorPath3 := ExtractFilePathEx(FMirrorFile3);
      if (lowercase(copy(MirrorPath3, 1, 6)) = 'ftp://') then
        Mirror3IsFtp := True
      else
        Mirror3IsFtp := False;
      if FCompressBackup then
      begin
        if ZipOK then
          CopyOK3 := MirrorFileEx(FZippedBackupFile, FZippedMirrorFile3, MFtpCopy3, FConnectionType)
        else
          CopyOK3 := False;
      end
      else
        CopyOK3 := MirrorFileEx(FBackupFile, FMirrorFile3, MFtpCopy3, FConnectionType);
      // if task is running in auto mode then delete oldest file in the Mirror #3 directory.
      if FManAuto = True then
      begin
        // if mirroring onto Mirror #3 is OK then delete oldest file in the Mirror #3 directory.
        if CopyOK3 then
        begin
          FDeletedMR3 := DeleteOldest(MirrorPath3, 'Mirror Dir #3');
        end;
      end;
    end;

    AEndTime := Now;
    if AEndTime - AStartTime < 1 then
      AEndTimeStr := TimeToStr(AEndTime, FSettings)
    else
      AEndTimeStr := DateTimeToStr(AEndTime, FSettings);
    //  EMail   Synchronize(RefreshPD30);

    if FManAuto = False then
      MAuto := 'MANUAL '
    else
      MAuto := '';
    if BackOK then
    begin
      if FCompressBackup then // Zip istenmiþse
      begin
        if (ZipOK = False) then
        begin
          MBack := 'ERROR !!  NEW BACKUP FILE ( ' + FBackupFile + ' ) COULDN''T BEEN ZIPPED !'#13#10 + FErrorInfo + #13#10;
          MailBody := MailBody + #13#10 + FTaskName + ' has encountered Backup Error !! (2)'#13#10 + '          ' + MBack;
        end
        else
          MBack := 'New Backup File created as "' + FZippedBackupFile + '" on the Backup Dir.'#13#10;
      end
      else
        MBack := 'New Backup File created as "' + FBackupFile + '" on the Backup Dir.'#13#10;
    end
    else
    begin
      if FCompressBackup then
      begin
        if TempOK = False then
          MBack := 'ERROR !!  NEW BACKUP FILE ( ' + FBackupFile + ' ) COULDN''T BEEN CREATED Because of not creating Temporary File !'#13#10 + '   GBak Params : >' + FFullGBakParams + '< ' + #13#10
        else
          MBack := 'ERROR !!  NEW BACKUP FILE ( ' + FBackupFile + ' ) COULDN''T BEEN CREATED !'#13#10 + '   GBak Params : >' + FFullGBakParams + '< ' + #13#10;
      end
      else
        MBack := 'ERROR !!  NEW BACKUP FILE ( ' + FBackupFile + ' ) COULDN''T BEEN CREATED !'#13#10 + '   GBak Params : >' + FFullGBakParams + '< ' + #13#10;
      MailBody := MailBody + #13#10 + FTaskName + ' has encountered Backup Error !! (3)'#13#10 + '          ' + MBack;
      MBack := MBack + GOut;
    end;

    if BackOK then
    begin
      if FCompressBackup then
        MBack := MBack + '   Backup FileSize (uncompressed size) = ' + FTempOrBackupFileSize + ' Byte ' + #13#10
      else
        MBack := MBack + '   Backup FileSize = ' + FTempOrBackupFileSize + ' Byte ' + #13#10;
    end;

    if MirrorIsFtp then
    begin
      if FConnectionType = 0 then
      begin
        FtpModeInfoA := ' in ACTIVE Mode.';
        FtpModeInfoB := ' (FTP Mode ACTIVE)';
      end
      else
      begin
        FtpModeInfoA := ' in PASSIVE Mode.';
        FtpModeInfoB := ' (FTP Mode PASSIVE)';
      end;
    end;

    if CopyOK then
    begin
      if FCompressBackup then
        MCopy := 'New Backup File is mirrored onto Mirror #1 ( ' + FZippedMirrorFile + ' )' + FtpModeInfoA + #13#10
      else
        MCopy := 'New Backup File is mirrored onto Mirror #1 ( ' + FMirrorFile + ' )' + FtpModeInfoA + #13#10;
    end
    else
    begin
      if FDoMirror = False then
      begin
        MCopy := 'Mirroring #1 is disable..'#13#10
      end
      else
      begin
        if BackOK then
          MCopy := 'ERROR !!  NEW BACKUP FILE COULDN''T BEEN MIRRORED ONTO MIRROR #1 ( ' + MirrorPath + ' ) !' + FtpModeInfoB + #13#10
        else
          MCopy := 'ERROR !!  NEW BACKUP FILE COULDN''T BEEN MIRRORED ONTO MIRROR #1 ( No Backup File to Mirror !! ) !' + FtpModeInfoB + #13#10;
        MailBody := MailBody + #13#10 + FTaskName + ' has encountered a Mirroring #1 Error !! (4)'#13#10 + '          ' + MCopy;
      end;
    end;

    if Mirror2IsFtp then
    begin
      if FConnectionType = 0 then
      begin
        FtpModeInfoA := ' in ACTIVE Mode.';
        FtpModeInfoB := ' (FTP Mode ACTIVE)';
      end
      else
      begin
        FtpModeInfoA := ' in PASSIVE Mode.';
        FtpModeInfoB := ' (FTP Mode PASSIVE)';
      end;
    end;

    if CopyOK2 then
    begin
      if FCompressBackup then
        MCopy2 := 'New Backup File is mirrored onto Mirror #2 ( ' + FZippedMirrorFile2 + ' )' + FtpModeInfoA + #13#10
      else
        MCopy2 := 'New Backup File is mirrored onto Mirror #2 ( ' + FMirrorFile2 + ' )' + FtpModeInfoA + #13#10;
    end
    else
    begin
      if FDoMirror2 = False then
      begin
        MCopy2 := 'Mirroring #2 is disable..'#13#10
      end
      else
      begin
        if BackOK then
          MCopy2 := 'ERROR !!  NEW BACKUP FILE COULDN''T BEEN MIRRORED ONTO MIRROR #2 ( ' + MirrorPath2 + ' ) !' + FtpModeInfoB + #13#10
        else
          MCopy2 := 'ERROR !!  NEW BACKUP FILE COULDN''T BEEN MIRRORED ONTO MIRROR #2 ( No Backup File to Mirror !! ) !' + FtpModeInfoB + #13#10;
        MailBody := MailBody + #13#10 + FTaskName + ' has encountered a Mirroring #2 Error !! (5)'#13#10 + '          ' + MCopy;
      end;
    end;

    if Mirror3IsFtp then
    begin
      if FConnectionType = 0 then
      begin
        FtpModeInfoA := ' in ACTIVE Mode.';
        FtpModeInfoB := ' (FTP Mode ACTIVE)';
      end
      else
      begin
        FtpModeInfoA := ' in PASSIVE Mode.';
        FtpModeInfoB := ' (FTP Mode PASSIVE)';
      end;
    end;

    if CopyOK3 then
    begin
      if FCompressBackup then
        MCopy3 := 'New Backup File is mirrored onto Mirror #3 ( ' + FZippedMirrorFile3 + ' )' + FtpModeInfoA + #13#10
      else
        MCopy3 := 'New Backup File is mirrored onto Mirror #3 ( ' + FMirrorFile3 + ' )' + FtpModeInfoA + #13#10;
    end
    else
    begin
      if FDoMirror3 = False then
      begin
        MCopy3 := 'Mirroring #3 is disable..'#13#10
      end
      else
      begin
        if BackOK then
          MCopy2 := 'ERROR !!  NEW BACKUP FILE COULDN''T BEEN MIRRORED ONTO MIRROR #3 ( ' + MirrorPath3 + ' ) !' + FtpModeInfoB + #13#10
        else
          MCopy2 := 'ERROR !!  NEW BACKUP FILE COULDN''T BEEN MIRRORED ONTO MIRROR #3 ( No Backup File to Mirror !! ) !' + FtpModeInfoB + #13#10;
        MailBody := MailBody + #13#10 + FTaskName + ' has encountered a Mirroring #3 Error !! (6)'#13#10 + '          ' + MCopy;
      end;
    end;
    MDel := '';
    Synchronize(RefreshPD30);
    if FManAuto = True then
    begin
      MDel := FDeletedBU + FDeletedMR + FDeletedMR2 + FDeletedMR3;
    end
    else
      MDel := 'None of out-of-criteria backup file(s) on backup and/or mirrors dirs has been deleted because of being Manual backup Mode'#13#10;

    if Trim(FExternalFile) = '' then
    begin
      MBatch := 'External file execution is Disabled.'#13#10;
    end
    else
    begin
      Synchronize(RefreshPD31);
      if FCompressBackup then
        ParamsToBatch := FZippedBackupFile
      else
        ParamsToBatch := FBackupFile;
      ParamsToBatch := '"' + ParamsToBatch + '"';
      if FUseParams = True then
      begin
        if FShowExternalWin = True then
        begin
          ExternalResultCode := ShellExecute(Handle, 'open', PChar(FExternalFile), PChar(ParamsToBatch), nil, SW_SHOWNORMAL);
          BatchFileOk := ExternalResultCode > 32
        end
        else
        begin
          ExternalResultCode := ShellExecute(Handle, 'open', PChar(FExternalFile), PChar(ParamsToBatch), nil, SW_HIDE);
          BatchFileOk := ExternalResultCode > 32
        end;
      end
      else
      begin
        if FShowExternalWin = True then
        begin
          ExternalResultCode := ShellExecute(Handle, 'open', PChar(FExternalFile), nil, nil, SW_SHOWNORMAL);
          BatchFileOk := ExternalResultCode > 32
        end
        else
        begin
          ExternalResultCode := ShellExecute(Handle, 'open', PChar(FExternalFile), nil, nil, SW_HIDE);
          BatchFileOk := ExternalResultCode > 32
        end;
      end;
      if BatchFileOk = False then
      begin
        if FUseParams = True then
          MBatch := 'ERROR !!  EXTERNAL FILE ' + FExternalFile + ' COULDN''T BEEN RUNNED WITH PARAM ' + ParamsToBatch + ' !! (Error Code =' + IntToStr(ExternalResultCode) + ') ' + #13#10
        else
          MBatch := 'ERROR !!  EXTERNAL FILE ' + FExternalFile + ' COULDN''T BEEN RUNNED !! (Error Code =' + IntToStr(ExternalResultCode) + ') ' + #13#10;
      end
      else
        MBatch := 'External File "' + FExternalFile + '" has been started to run with parameter ' + ParamsToBatch + ' at ' + DateTimeToStr(Now) + #13#10
    end;

    if ((ValidateOK = False) or
      (BackOK = False) or
      ((FCompressBackup = True) and (ZipOK = False)) or
      ((FDoMirror = True) and (CopyOK = False)) or
      ((FDoMirror2 = True) and (CopyOK2 = False)) or
      ((FDoMirror3 = True) and (CopyOK3 = False))) then
    begin
      // There is a problem.
      if Trim(FMailTo) <> '' then
      begin
        // Wanted EMail Notification
        Synchronize(RefreshPD13);
        EMailOK := CreateEmail(FMailTo, '', 'Backup Error Warning for ' + FTaskName + ' Backup # ' + FBackupNo, MailBody, '');
        if EMailOK then
          MMail := 'Warning EMail sended to ' + FMailTo + ' at ' + DateTimeToStr(Now) + #13#10
        else
          MMail := 'ERROR !!  WARNING EMAIL COULDN''T BEEN SENDED TO "' + FMailTo + '"  !!. ' + DateTimeToStr(Now) + '   (Smtp Server Error Info :' + FErrorInfo + ')' + #13#10;
      end
      else
        MMail := 'EMail Notification is Disabled. So, no warning mail has been sended..'#13#10;
    end
    else
    begin
      MMail := 'EMail Notification is enabled. (No email notification has been sended because there is noting to notify.)'#13#10;
    end;

    // Archive backup, if sequence is changed
    if Self.FSequenceIncremented and (Self.FArchiveDir <> '') then
    begin
      ForceDirectories(Self.FArchiveDir);
      sArchiveFile := IfThen(Self.FArchiveDir[Length(Self.FArchiveDir)] in ['/', '\'], copy(Self.FArchiveDir, 1, Length(Self.FArchiveDir) - 1), Self.FArchiveDir) + '\' + ExtractFileName(IfThen(Self.FCompressBackup, Self.FZippedBackupFile, Self.FBackupFile));
      CopyFile(PChar(IfThen(Self.FCompressBackup, Self.FZippedBackupFile, Self.FBackupFile)), PChar(sArchiveFile), False);
      sMsgArchive := 'New Archive File created as "' + sArchiveFile + '" on the Archive Dir.' + #13#10;
    end
    else
      sMsgArchive := 'Archive File is disable.' + #13#10;

    BackupInfoStr := #13#10 +
      ' ' + MAuto + 'BACKUP TASK " ' + FTaskName + '-' + DateTimeToStr(FAlarm, FSettings) + ' "'#13#10 +
      '   Executed between ' + DateTimeToStr(AStartTime, FSettings) + ' and ' + AEndTimeStr + ' with " ' + FBackupOptions + ' " Backup Options.'#13#10 +
      //               '   Gbak Params    : '+FGBakParams+#13#10+
    '   Database File  : ' + FDatabaseFile + #13#10 +
      '   ' + GFixOut +
      '   ' + MBack +
      '   ' + MCopy + MFtpCopy +
      '   ' + MCopy2 + MFtpCopy2 +
      '   ' + MCopy3 + MFtpCopy3 +
      '   ' + MDel +
      '   ' + MBatch +
      '   ' + MMail +
      '   ' + sMsgArchive;
    Synchronize(RefreshPD40);
    WriteLog(BackupInfoStr);
  finally
    Synchronize(HidePD);
  end;
end;

// There is one more StrToOEM  function in the JRZip Unit

function TBackUp.StrToOEM(s: string): string;
var
  i: Integer;
begin
  for i := 1 to Length(s) do
  begin
    if s[i] >= #128 then
      s[i] := '_';
  end;
  Result := s;
end;

end.
