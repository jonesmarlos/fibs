
//*****************************************************************************
//
//  This is the revised version of JRZip unit.
//  Revised by Talat Dogan, August 2005.
//  Revised items signed as "TDogan"
//  EMail : dogantalat@yahoo.com
//
//*****************************************************************************

{ ---------------------------------------------------------------
  Delphi-Unit
  Subroutines for packing files
  Supports:
  gz-Format: packing and unpacking
    gz-files include original filename and timestamp
    calling:
    - GZip (Source,Destination)
    - GUnzip (Source,Destination)
    - GzFileInfo (Source)

   PkZip-Format: packing
    calling:
    - MakeZip (Destination,BasicDirectory)
    - AddZip (Source)
    - CloseZip
  all error handling using exceptions

  acknowledgments:
  - uses a modified version of gzio from Jean-loup Gailly and Francisco Javier Crespo
  - uses the zlib-library from Jean-loup Gailly and Mark Adler
  J. Rathlev, Uni-Kiel (rathlev@physik.uni-kiel.de)
  Vers. 1.0 - Jan. 2001
  Vers. 1.1 - March 2002 added: GzFileInfo
  Vers. 1.2 - Aug. 2002 enhanced error handling
  Vers. 1.3 - Nov. 2002 bug in GUnzip fixed (FileMode settings)
                        Convert filenames in ZIP to OEM character set
  Vers. 1.31 - Aug. 2003 bug in AddZip (FreeMem) fixed
  Vers. 1.32 - Jan. 2004 bug in TPkHeader.Create fixed (USz,CSz were exchanged)
  Vers. 1.33 - Apr. 2004 call to application.processmessages in compress and uncompress added
  			 bug in gzip timestamp fixed (daylight saving time)
  Vers. 1.4 - Apr. 2004 uses filestreams instead of assignfile/blockread/blockwrite
  Vers. 1.41 - Jun. 2005 uses TFileTime (64 bit) for file time stamps
  }


unit JRZip;

interface

uses
  Windows, Sysutils, Classes, Forms, GzIOExt;

const
  GzExt = '.gz';
  BUFLEN = 16384;

  errGzCreate = 1;
  errGzOpen   = 2;
  errGzClose  = 3;
  errGzRead   = 4;
  errGzWrite  = 5;
  errGzAttr   = 6;

type
  TCvTable = array [0..127] of char;
const
  TabToOEM : TCvTable =(
    #$20,#$20,#$20,#$20,#$20,#$20,#$20,#$20,#$20,#$20,#$20,#$20,#$20,#$20,#$20,#$20,
    #$20,#$20,#$20,#$20,#$20,#$20,#$20,#$20,#$20,#$20,#$20,#$20,#$20,#$20,#$20,#$20,
    #$20,#$AD,#$9B,#$9C,#$20,#$9D,#$B3,#$15,#$20,#$20,#$20,#$AE,#$AA,#$C4,#$20,#$20,
    #$F8,#$F1,#$FD,#$FC,#$20,#$E6,#$E3,#$20,#$20,#$20,#$20,#$AF,#$AC,#$AB,#$20,#$A8,
    #$41,#$41,#$41,#$41,#$8E,#$8F,#$92,#$80,#$45,#$90,#$45,#$45,#$49,#$49,#$49,#$49,
    #$44,#$A5,#$4F,#$4F,#$4F,#$4F,#$99,#$20,#$20,#$55,#$55,#$55,#$9A,#$59,#$20,#$E1,
    #$85,#$61,#$83,#$61,#$84,#$86,#$91,#$87,#$8A,#$82,#$88,#$89,#$8D,#$A1,#$8C,#$8B,
    #$20,#$A4,#$95,#$A2,#$93,#$6F,#$94,#$F6,#$20,#$97,#$A3,#$96,#$81,#$79,#$20,#$98);

type
  TCompressionType = (ctStandard,ctFiltered,ctHuffmanOnly);
  EGZipError = class(EInOutError)
  public
    GZipError : integer;
    constructor Create (ErrString : string; ErrNR : integer);
  end;

  TGzFileInfo = record
    Filename : string;
    DateTime : integer;
    Attr     : word;
   end;

  TPkHeader = class(TObject)
    TimeStamp,CRC   : int64;
    Offset,
    CSize,USize     : int64;
    Attr            : integer;
    constructor Create (Ts,Ofs,Chk,CSz,USz,At : int64);
  end;

{ ---------------------------------------------------------------- }
(* set then compression level from 1 .. 9
            method to "Standard, Filtered or HuffmanOnly"
   default: Standard, 6 *)
procedure SetCompression (Method : TCompressionType;
                          Level  : integer);

{ ---------------------------------------------------------------- }
(* Umwandeln eines ANSI-Strings nach OEM *)
function StrToOEM (s : string) : string;

{ ---------------------------------------------------------------- }
(* copy source to destination producing gz-file *)
procedure GZip (Source,Destination : string);

// Revised and added by TDogan
procedure GZipEx(Source,Destination,ASourceName : string;ACompLevel:integer);

// Revised and added by TDogan
function GZipExFunc(Source,Destination,ASourceName : string;ACompLevel:integer;var AErrorInfo:string):integer;

(* copy source to destination retrieving from gz-file *)
procedure GUnzip (Source,Destination : string);

(* retrieve date from gz-file *)
function GzFileInfo (Source : string) : TGzFileInfo;

{ ---------------------------------------------------------------- }
(* open Destination as PkZip compatible archive,
  all added files are relative to BasicDirectory *)
procedure MakeZip (Destination,BasicDirectory : string);

(* add Source to Pk-Archive *)
procedure AddZip (Source : string);

// Revised and added by TDogan
// adds Source to Pk-Archive but names it with a different filename
procedure AddZipEx (Source, ASourceName : string;ACompLevel:integer);

(* close Pk-Archive, write trailer *)
procedure CloseZip;

// Revised and added by TDogan
function MakeZipFunc(Destination,BasicDirectory:string; var AErrorInfo:string):integer;

// Revised and added by TDogan
function AddZipExFunc (Source, ASourceName : string;ACompLevel:integer;var AErrorInfo:string):integer;

var
  PBase,PDest : string;
  FileList    : TStringList;

{ ---------------------------------------------------------------- }
implementation

var
  CLevel : integer;
  CType  : TCompressionType;

{ ---------------------------------------------------------------- }
(* Umwandeln eines ANSI-Strings nach OEM *)
function StrToOEM (s : string) : string;
var
  i  : integer;
begin
  for i:=1 to length(s) do begin
    if s[i]>=#128 then s[i]:=TabToOEM[ord(s[i])-128];
    end;
  StrToOEM:=s;
  end;

{ ---------------------------------------------------------------- }
(* Ermittle die Uhrzeit (UTC) des letztenh Zugriffs auf eine Datei *)
function GetFileLastWriteTime(const FileName: string): TFileTime;
var
  Handle   : THandle;
  FindData : TWin32FindData;
begin
  Handle := FindFirstFile(PChar(FileName), FindData);
  if Handle <> INVALID_HANDLE_VALUE then begin
    Windows.FindClose(Handle);
    if (FindData.dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY) = 0 then begin
      Result:=FindData.ftLastWriteTime; Exit;
      end;
    end;
  with Result do begin
    dwLowDateTime:=0; dwHighDateTime:=0;
    end;
  end;

(* Setze die Uhrzeit (UTC) des letzten Schreib-Zugriffs auf eine Datei *)
function SetFileLastWriteTime(const FileName: string; FileTime : TFileTime) : integer;
var
  Handle   : THandle;
begin
  Handle:=FileOpen(FileName, fmOpenWrite);
  if Handle=THandle(-1) then Result:=GetLastError
  else begin
    if SetFileTime(Handle,nil,nil,@FileTime) then Result:=0
    else Result:=GetLastError;
    FileClose(Handle);
    end;
  end;

(* konvertiere Filetime in Delphi-Zeit (TDateTime) *)
function FileTimeToDateTime (ft : TFileTime) : TDateTime;
var
  st : TSystemTime;
begin
  FileTimeToSystemTime(ft,st);
  with st do Result:=EncodeDate(wYear,wMonth,wDay)+EncodeTime(wHour,wMinute,wSecond,wMilliseconds);
  end;

(* konvertiere Delphi-Zeit (TDateTime) in  Filetime *)
function DateTimeToFileTime (dt : TDateTime) : TFileTime;
var
  st : TSystemTime;
begin
  with st do begin
    DecodeDate(dt,wYear,wMonth,wDay);
    DecodeTime(dt,wHour,wMinute,wSecond,wMilliseconds);
    end;
  SystemTimeToFileTime(st,Result);
  end;

{ ------------------------------------------------------------------- }
constructor TPkHeader.Create (Ts,Ofs,Chk,CSz,USz,At : int64);
begin
  inherited Create;
  Timestamp:=Ts; Offset:=Ofs; CRC:=Chk;
  CSize:=CSz; USize:=USz; Attr:=At;
  end;

{ ------------------------------------------------------------------- }
(* generate error message *)
constructor EGZipError.Create (ErrString : string;
                               ErrNR     : integer);
begin
  inherited Create (ErrString);
  GZipError:=ErrNr;
  end;

{ ------------------------------------------------------------------- }
procedure SetCompression (Method : TCompressionType;
                          Level  : integer);
begin
  CLevel:=Level; CType:=Method;
end;

{ gz_compress ----------------------------------------------
# This code comes from minigzip.pas with some changes
# Original:
# minigzip.c -- usage example of the zlib compression library
# Copyright (C) 1995-1998 Jean-loup Gailly.
#
# Pascal tranlastion
# Copyright (C) 1998 by Jacques Nomssi Nzali
#
# 0 - No Error
# 1 - Read Error
# 2 - Write Error
-----------------------------------------------------------}
function gz_compress (var infile : TFileStream;
                      outfile    : gzFile): integer;
var
  n,len : integer;
  sz,k  : int64;
  ioerr : integer;
  buf   : packed array [0..BUFLEN-1] of byte; { Global uses BSS instead of stack }
begin
  gz_compress:=0; n:=0; sz:=0;
  while true do begin
    inc(n);
//Disabled by TDogan    if (n mod 8)=0 then Application.ProcessMessages;
    try
      len:=infile.Read(buf, BUFLEN)
    except
      gz_compress:= 1;
      try infile.Free; except end;
      exit;
      end;
    if (len = 0) then begin
      if infile.Size<>sz then gz_compress:= 1;
      try infile.Free; except end;
      exit;
      end
    else begin
    {Comparing signed and unsigned types}
      try
        k:=gzwrite (outfile, @buf, len);
        sz:=sz+k;
        if k <> len then begin
          gz_compress:= 2;
          try infile.Free; except end;
          exit;
          end
      except
        gz_compress:= 2;
        try infile.Free; except end;
        end;
      end;
    end; {WHILE}
  end;

{ gz_uncompress ----------------------------------------------
# This code comes from minigzip.pas with some changes
# Original:
# minigzip.c -- usage example of the zlib compression library
# Copyright (C) 1995-1998 Jean-loup Gailly.
#
# Pascal tranlastion
# Copyright (C) 1998 by Jacques Nomssi Nzali
#
# 0 - No error
# 1 - Read Error
# 2 - Write Error
-----------------------------------------------------------}
function gz_uncompress (infile      : gzFile;
                        var outfile : TFileStream) : integer;
var
  n,len   : integer;
  written : integer;
  buf     : packed array [0..BUFLEN-1] of byte; { Global uses BSS instead of stack }
  errorcode : byte;
begin
  errorcode := 0; n:=0;
  while true do begin
    inc(n);
//Disabled by TDogan    if (n mod 10)=0 then Application.ProcessMessages;
    len := gzread (infile, @buf, BUFLEN);
    if (len < 0) then begin
      errorcode := 1;
      break;
      end;
    if (len = 0) then break;
    try
      written:=outfile.Write(buf,len);
    except
      errorcode := 2; break;
      end;
    {$WARNINGS OFF}{Comparing signed and unsigned types}
    if (written <> len) then begin
    {$WARNINGS ON}
      errorcode := 2; break;
      end;
    end; {WHILE}
  try
    outfile.Free;
  except
    errorcode := 3
    end;
  gz_uncompress := errorcode
  end;

{ GZip --------------------------------------------------------}
// Source  = source file,  Destination = gz-file
procedure GZip (Source,Destination : string);
var
  outmode : string;
  s       : string;
  outFile : gzFile;
  infile  : TFileStream;
  errorcode : integer;
  FTime     : TFileTime;
  utime     : cardinal;
  n         : Integer;
  Attr      : word;
begin
  try
    infile:=TFileStream.Create(Source,fmOpenRead+fmShareDenyNone);
  except
    on EFOpenError do
      raise EGZipError.Create ('Error opening '+Source,errGzOpen);
    end;
  outmode := 'w  ';
  s := IntToStr(CLevel);
  outmode[2] := s[1];
  case CType of
     ctHuffmanOnly : outmode[3] := 'h';
     ctFiltered    : outmode[3] := 'f';
    end;
  s:=ExtractFilename(Source);
  Attr:=FileGetAttr(Source);
//  ftime:=FileAge(Source);  // file time stamp
  FTime:=GetFileLastWriteTime(Source);
  // unix time for gzip
  utime:=round(SecsPerDay*(FileTimeToDateTime(GetFileLastWriteTime(Source))-25569));
  // always overwrite destination, reset attributes
  if FileExists(Destination) then begin
    if FileSetAttr(Destination,faArchive)<>0 then begin
      try infile.Free; except end;
      raise EGZipError.Create ('Error creating '+Destination,errGzCreate);
      end;
    end;
  outFile:=gzopen (Destination,outmode,s,utime);
  if (outFile = NIL) then begin
    try infile.Free; except end;
    raise EGZipError.Create ('Error opening '+Destination,errGzCreate);
    end
  else begin
    errorcode := gz_compress(infile,outFile);
    if errorcode > 0 then begin
      try outFile^.gz_file.Free; except end;
      case errorcode of
      1 : raise EGZipError.Create ('Error reading from '+Source,errGzRead);
      2 : raise EGZipError.Create ('Error writing to '+Destination,errGzWrite);
        end;
      end
    else begin
      if (gzclose (outFile) <> 0{Z_OK}) then
         raise EGZipError.Create ('Error closing '+Destination,errGzClose);
      (* set time stamp of gz-file *)
//      n:=FileSetDate(Destination,ftime);
      n:=SetFileLastWriteTime(Destination,FTime);
      if n=0 then n:=FileSetAttr(Destination,Attr);
      if n>0 then
        raise EGZipError.Create ('Error changing attributes '+Destination,errGzAttr);
      end;
    end;
  end;


{ Function GZipExFunc --------------------------------------------------------}
// Source  = source file,  Destination = gz-file
//
// 0 - No Error
// 1 - File Create Error
// 2 - File open Error
// 3 - File close Error
// 4 - File Read Error
// 5 - File write Error
// 6 - Attr Change Error

{ GZipEx --------------------------------------------------------}

// Revised and added by TDogan
function GZipExFunc(Source,Destination,ASourceName : string;ACompLevel:integer;var AErrorInfo:string):integer;
var
  outmode : string;
  s       : string;
  outFile : gzFile;
  infile  : TFileStream;
  errorcode : integer;
  FTime     : TFileTime;
  utime     : cardinal;
  n         : Integer;
  Attr      : word;
begin
   result:=0;//No Error
  try
    infile:=TFileStream.Create(Source,fmOpenRead+fmShareDenyNone);
  except
    on EFOpenError do
    begin
      AErrorInfo:='Error opening '+Source;
      result:=errGzOpen;
      exit;
    end;
  end;
  outmode := 'w  ';
//  s := IntToStr(CLevel);
   s:=IntToStr(ACompLevel);
  outmode[2] := s[1];
  case CType of
     ctHuffmanOnly : outmode[3] := 'h';
     ctFiltered    : outmode[3] := 'f';
    end;
  s:=ExtractFilename(Source);
  Attr:=FileGetAttr(Source);
//  ftime:=FileAge(Source);  // file time stamp
  FTime:=GetFileLastWriteTime(Source);
  // unix time for gzip
  utime:=round(SecsPerDay*(FileTimeToDateTime(GetFileLastWriteTime(Source))-25569));
  // always overwrite destination, reset attributes
  if FileExists(Destination) then
  begin
    if FileSetAttr(Destination,faArchive)<>0 then
    begin
      try
        infile.Free;
      except
      end;
      AErrorInfo:='Error creating '+Destination;
      result:=errGzCreate;
      exit;
    end;
  end;
  outFile:=gzopenEx (Destination,outmode,s,ASourceName,utime);
  if (outFile = NIL) then
  begin
    try
      infile.Free;
    except
    end;
    raise EGZipError.Create ('Error opening '+Destination,errGzCreate);
    AErrorInfo:='Error creating '+Destination;
    result:=errGzCreate;
    // exit; gerek yok
  end else
  begin
    errorcode := gz_compress(infile,outFile);
    if errorcode > 0 then
    begin
      try
        outFile^.gz_file.Free;
      except
      end;
      if errorcode=1 then
      begin
        AErrorInfo:='Error reading from '+Source;
        result:=errGzRead;
      end else if errorcode=2 then
      begin
        AErrorInfo:='Error writing to '+Destination;
        result:=errGzWrite;
      end;
    end else
    begin
      if (gzclose (outFile) <> 0{Z_OK}) then
      begin
        AErrorInfo:='Error closing '+Destination;
        result:=errGzClose;
        exit;
      end;
      (* set time stamp of gz-file *)
//      n:=FileSetDate(Destination,ftime);
      n:=SetFileLastWriteTime(Destination,FTime);
      if n=0 then n:=FileSetAttr(Destination,Attr);
      if n>0 then
      begin
        AErrorInfo:='Error changing attributes '+Destination;
        result:=errGzAttr;
      end;
    end;
  end;
end;



// Revised and added by TDogan
{ GZipEx --------------------------------------------------------}
// Source  = source file,  Destination = gz-file
procedure GZipEx(Source,Destination,ASourceName : string;ACompLevel:integer);
var
  outmode : string;
  s       : string;
  outFile : gzFile;
  infile  : TFileStream;
  errorcode : integer;
  FTime     : TFileTime;
  utime     : cardinal;
  n         : Integer;
  Attr      : word;
begin
  try
    infile:=TFileStream.Create(Source,fmOpenRead+fmShareDenyNone);
  except
    on EFOpenError do
      raise EGZipError.Create ('Error opening '+Source,errGzOpen);
    end;
  outmode := 'w  ';
//  s := IntToStr(CLevel);
   s:=IntToStr(ACompLevel);
  outmode[2] := s[1];
  case CType of
     ctHuffmanOnly : outmode[3] := 'h';
     ctFiltered    : outmode[3] := 'f';
    end;
  s:=ExtractFilename(Source);
  Attr:=FileGetAttr(Source);
//  ftime:=FileAge(Source);  // file time stamp
  FTime:=GetFileLastWriteTime(Source);
  // unix time for gzip
  utime:=round(SecsPerDay*(FileTimeToDateTime(GetFileLastWriteTime(Source))-25569));
  // always overwrite destination, reset attributes
  if FileExists(Destination) then
  begin
    if FileSetAttr(Destination,faArchive)<>0 then
    begin
      try
        infile.Free;
      except
      end;
      raise EGZipError.Create ('Error creating '+Destination,errGzCreate);
    end;
  end;
  outFile:=gzopenEx (Destination,outmode,s,ASourceName,utime);
  if (outFile = NIL) then
  begin
    try
      infile.Free;
    except
    end;
    raise EGZipError.Create ('Error opening '+Destination,errGzCreate);
  end else
  begin
    errorcode := gz_compress(infile,outFile);
    if errorcode > 0 then
    begin
      try
        outFile^.gz_file.Free;
      except
      end;
      case errorcode of
        1 : raise EGZipError.Create ('Error reading from '+Source,errGzRead);
        2 : raise EGZipError.Create ('Error writing to '+Destination,errGzWrite);
      end;
    end else
    begin
      if (gzclose (outFile) <> 0{Z_OK}) then raise EGZipError.Create ('Error closing '+Destination,errGzClose);
      (* set time stamp of gz-file *)
//      n:=FileSetDate(Destination,ftime);
      n:=SetFileLastWriteTime(Destination,FTime);
      if n=0 then n:=FileSetAttr(Destination,Attr);
      if n>0 then  raise EGZipError.Create ('Error changing attributes '+Destination,errGzAttr);
    end;
  end;
end;

  { GUnzip ------------------------------------------------------}
// Source  = gz-file,  Destination = destination folder
procedure GUnzip (Source,Destination : string);
var
  infile    : gzFile;
  outfile   : TFileStream;
  errorcode : integer;
  s         : string;
  ftime,n   : integer;
  lft       : TFileTime;
  utime     : cardinal;
  Attr      : word;
begin
  Attr:=FileGetAttr(Source);
  infile := gzopen (Source, 'r',s,utime);
  if (infile = NIL) then begin
    raise EGZipError.Create ('Error opening '+Source,errGzOpen);
    end
  else begin
    if length(s)>0 then s:=Destination+s
    else s:=Destination+ChangeFileExt(ExtractFilename(Source),'');
    // always overwrite destination, reset attributes
    if FileExists(s) then FileSetAttr(s,faArchive);
    try
      outfile:=TFileStream.Create(s,fmCreate);
      errorcode:=gz_uncompress (infile,outfile);
      if errorcode>0 then begin
        try infile^.gz_file.Free; except end;
        case errorcode of
        1 : raise EGZipError.Create ('Error reading from '+Source,errGzRead);
        2 : raise EGZipError.Create ('Error writing to '+s,errGzWrite);
          end;
        end
      else begin
        if (gzclose (inFile) <> 0) then
           raise EGZipError.Create ('Error closing '+Source,errGzClose);
        (* set time stamp of gz-file *)
        FileTimeToLocalFileTime(DateTimeToFileTime(utime/SecsPerDay+25569),lft);
        FileTimeToDosDateTime(lft,LongRec(ftime).Hi,LongRec(ftime).Lo);
        n:=FileSetDate(s,ftime);
        if n=0 then n:=FileSetAttr(s,Attr);
        if n>0 then raise EGZipError.Create ('Error changing attributes '+s,errGzAttr);
        end;
    except
      on EFCreateError do begin
        try infile^.gz_file.Free; except end;
        raise EGZipError.Create ('Error creating '+s,errGzCreate);
        end;
      end;
    end;
  end;


{ GDate ------------------------------------------------------}
(* retrieve date and time from gz-file *)
function GzFileInfo (Source : string) : TGzFileInfo;
var
  infile    : gzFile;
  s         : string;
  utime     : cardinal;
  lft       : TFileTime;
begin
  with Result do begin
    Filename:='';
    DateTime:=DateTimeToFileDate(Now);
    infile:=gzopen (Source,'r',s,utime);
    if (infile = NIL) then begin
      raise EGZipError.Create ('Error opening '+Source,errGzOpen);
      end
    else begin
      gzclose (infile);
      if length(s)>0 then Filename:=s
      else Filename:=ChangeFileExt(ExtractFilename(Source),'');
      (* get time stamp of gz-file *)
      FileTimeToLocalFileTime(DateTimeToFileTime(utime/SecsPerDay+25569),lft);
      FileTimeToDosDateTime(lft,LongRec(DateTime).Hi,LongRec(DateTime).Lo);
      Attr:=FileGetAttr(Source);
      end;
    end;
  end;

//***************

// Revised and added by TDogan
{ AddZipEx ---TD--------------------------------------------------
  Add "Source" to open archive with a different Name (see MakeZip)
---------------------------------------------------------------}
procedure AddZipEx (Source, ASourceName : string;ACompLevel:integer);
var
  outmode   : string;
  s         : string;
  outFile   : gzFile;
  infile    : TFileStream;
  errorcode : integer;
  utime     : cardinal;
begin
  if length (PDest)>0 then
  begin
    try
      infile:=TFileStream.Create(Source,fmOpenRead+fmShareDenyNone);
    except
      on EFOpenError do raise EGZipError.Create ('Error opening '+Source,errGzOpen);
    end;
    case CType of
       ctHuffmanOnly : outmode:='h';
       ctFiltered    : outmode:='f';
    end;
    SetCompression (ctStandard,ACompLevel); // Added by TDogan
    outmode := outmode+copy(IntToStr(cLevel),1,1);
    s:=StrToOEM(ExtractRelativePath(PBase,Source)); // ZIP needs OEM characters (like DOS)
    ASourceName:=StrToOEM(ExtractFileName(ASourceName)); // Added by TDogan
    utime:=FileAge(Source);
    outFile := ZipOpen(PDest, outmode,s,utime);
    if (outFile = NIL) then
    begin
      try
        infile.Free;
      except
      end;
      raise EGZipError.Create ('Error opening '+PDest,errGzOpen);
    end else
    begin
      errorcode := gz_compress(infile, outFile);
      if errorcode > 0 then
      begin
        case errorcode of
          1 : raise EGZipError.Create ('Error reading from '+Source,errGzRead);
          2 : raise EGZipError.Create ('Error writing to '+PDest,errGzWrite);
        end;
      end else
      begin
        if ZipClose(outfile)<>0 then
        begin
          raise EGZipError.Create ('Error closing '+PDest,errGzClose);
        end else
        begin
          with outfile^ do
                   FileList.Addobject(ASourceName,TPkHeader.Create(time,filepos,CRC,
                                      CSize,USize,FileGetAttr(Source)));
          FreeMem(outfile,sizeof(gz_stream));
        end;
      end;
    end;
  end;
end;

//***************



{ MakeZip -----------------------------------------------------
  Open archive for AddZip
---------------------------------------------------------------}
procedure MakeZip (Destination,BasicDirectory : string);
var
  fZip : TFileStream;
begin
  FileList:=TStringList.Create;
  FileList.Sorted:=false;
  PDest:=Destination; PBase:=BasicDirectory;
  try
    fZip:=TFileStream.Create(Destination,fmCreate);
    fZip.Free;
  except
    on EFCreateError do begin
      raise EGZipError.Create ('Error creating '+Destination,errGzCreate);
      end;
    end;
  end;

{ AddZip ---JR--------------------------------------------------
  Add "Source" to open archive (see MakeZip)
---------------------------------------------------------------}
procedure AddZip (Source : string);
var
  outmode   : string;
  s         : string;
  outFile   : gzFile;
  infile    : TFileStream;
  errorcode : integer;
  utime     : cardinal;
begin
  if length (PDest)>0 then begin
    try
      infile:=TFileStream.Create(Source,fmOpenRead+fmShareDenyNone);
    except
      on EFOpenError do
        raise EGZipError.Create ('Error opening '+Source,errGzOpen);
      end;
    case CType of
       ctHuffmanOnly : outmode:='h';
       ctFiltered    : outmode:='f';
      end;
    outmode := outmode+copy(IntToStr(cLevel),1,1);
    s:=StrToOEM(ExtractRelativePath(PBase,Source)); // ZIP needs OEM characters (like DOS)
    utime:=FileAge(Source);
    outFile := ZipOpen (PDest, outmode,s,utime);
    if (outFile = NIL) then begin
      try infile.Free; except end;
      raise EGZipError.Create ('Error opening '+PDest,errGzOpen);
      end
    else begin
      errorcode := gz_compress(infile, outFile);
      if errorcode > 0 then begin
        case errorcode of
        1 : raise EGZipError.Create ('Error reading from '+Source,errGzRead);
        2 : raise EGZipError.Create ('Error writing to '+PDest,errGzWrite);
          end;
        end
      else begin
        if ZipClose(outfile)<>0 then begin
          raise EGZipError.Create ('Error closing '+PDest,errGzClose);
          end
        else begin
          with outfile^ do
            FileList.Addobject(s,TPkHeader.Create(time,filepos,CRC,
                               CSize,USize,FileGetAttr(Source)));
          FreeMem(outfile,sizeof(gz_stream));
          end;
        end;
      end;
    end;
  end;

{ CloseZip -----------------------------------------------------
  Write directory and final block
---------------------------------------------------------------}
procedure CloseZip;
var
  zf  : TFileStream;
  pke : TPkEndHeader;
  pkd : TPkDirHeader;
  off : int64;
  i   : integer;
  s   : string[255];
begin
  if length (PDest)>0 then begin
    zf:=TFileStream.Create(PDest,fmOpenReadWrite);
    with zf do begin
      off:=Size; Seek(off,0);
      end;
    with FileList do for i:=0 to Count-1 do begin  // central directory structure
      with pkd do begin
        Signatur:=PkDirSignatur;
        VersMade:=$14;
        VersExtr:=$14;
        Flag:=2;
        Method:=8;
        FTimeStamp:=(Objects[i] as TPkHeader).TimeStamp;
        CRC:=(Objects[i] as TPkHeader).CRC;
        CSize:=(Objects[i] as TPkHeader).CSize;
        USize:=(Objects[i] as TPkHeader).USize;
        FNLength:=length(Strings[i]);
        ExtraLength:=0;
        CommLength:=0;
        DiskStart:=0;
        IntAttr:=0;
        ExtAttr:=(Objects[i] as TPkHeader).Attr;
        Offset:=(Objects[i] as TPkHeader).Offset;
        end;
      zf.Write(pkd,sizeof(pkd));
      s:=Strings[i];
      zf.Write(s[1],pkd.FNLength);
      end;
    with pke do begin
      Signatur:=PkEndSignatur;
      ThisDisk:=0;
      StartDisk:=0;
      ThisEntries:=FileList.Count;
      TotalEntries:=FileList.Count;
      DirSize:=zf.Position-off;
      Offset:=off;
      CommLength:=0;
      end;
    zf.Write(pke,sizeof(pke));
    zf.Free;
    with FileList do begin
      for i:=0 to Count-1 do Objects[i].Free;
      Free;
      end;
    PDest:='';
    end;
  end;

// Revised and added by TDogan
function MakeZipFunc(Destination,BasicDirectory:string; var AErrorInfo:string):integer;
var
  fZip : TFileStream;
begin
  Result:=0;
  FileList:=TStringList.Create;
  FileList.Sorted:=false;
  PDest:=Destination; PBase:=BasicDirectory;
  try
    fZip:=TFileStream.Create(Destination,fmCreate);
    fZip.Free;
  except
    on EFCreateError do
       begin
         AErrorInfo:='Error creating '+Destination;
         Result:=errGzCreate;
       end;
  end;
end;

// Revised and added by TDogan
function AddZipExFunc (Source, ASourceName : string;ACompLevel:integer;var AErrorInfo:string):integer;
var
  outmode   : string;
  s         : string;
  outFile   : gzFile;
  infile    : TFileStream;
  errorcode : integer;
  utime     : cardinal;
begin
  Result:=0;
  if length (PDest)>0 then
  begin
    try
      infile:=TFileStream.Create(Source,fmOpenRead+fmShareDenyNone);
    except
      on EFOpenError do
         begin
           AErrorInfo:='Error opening '+Source;
           Result:=errGzOpen;
           exit;
         end;
      else
        exit;   
    end;
    case CType of
       ctHuffmanOnly : outmode:='h';
       ctFiltered    : outmode:='f';
    end;
    SetCompression (ctStandard,ACompLevel); //TDogan
    outmode := outmode+copy(IntToStr(cLevel),1,1);
    s:=StrToOEM(ExtractRelativePath(PBase,Source)); // ZIP needs OEM characters (like DOS)
    ASourceName:=StrToOEM(ExtractFileName(ASourceName)); // TDogan
    utime:=FileAge(Source);
    outFile := ZipOpen(PDest, outmode,s,utime);
    if (outFile = NIL) then
    begin
      try
        infile.Free;
      except
      end;
      AErrorInfo:='Error opening '+PDest;
      Result:=errGzOpen;
      exit;
    end else
    begin
      errorcode := gz_compress(infile, outFile);
      if errorcode > 0 then
      begin
        if errorcode=1 then
        begin
          AErrorInfo:='Error reading from '+Source;
          Result:=errGzRead;
          //exit; gereksiz
        end else
        begin
          AErrorInfo:='Error writing to '+PDest;
          Result:=errGzWrite;
          //exit; gereksiz
        end;
      end else
      begin
        if ZipClose(outfile)<>0 then
        begin
          AErrorInfo:='Error closing '+PDest;
          Result:=errGzClose;
        end else
        begin
          with outfile^ do FileList.Addobject(ASourceName,TPkHeader.Create(time,filepos,CRC,
                                              CSize,USize,FileGetAttr(Source)));
          FreeMem(outfile,sizeof(gz_stream));
        end;
      end;
    end;
  end;
end;
//***************

begin
  PDest:=''; PBase:='';
  CLevel:=6; CType:=ctStandard;
end.