
//*****************************************************************************
//
//  This is the revised version of gzioext unit.
//  Revised by Talat Dogan, August 2005.
//  Revised items signed as "TDogan"
//  EMail : dogantalat@yahoo.com
//
//*****************************************************************************

Unit gzioext;
{
  Pascal unit based on gzio.c -- IO on .gz files
  Copyright (C) 1995-1998 Jean-loup Gailly.

  Define NO_DEFLATE to compile this file without the compression code

  Pascal tranlastion based on code contributed by Francisco Javier Crespo
  Copyright (C) 1998 by Jacques Nomssi Nzali
  For conditions of distribution and use, see copyright notice in readme.txt
}

{ -------------------------------------------------------------
  modifications made for
  - GZip:
    - include original filename in header on writing
    - include timestamp in header on writing
    - extract original filename from header on reading
    - extract timestamp from header on reading
  - PKZip-Format
    - write PK-Format (see "appnote-960915-pk")

  the following bugs were fixed:
  - limitation of path length to 79 char in gzopen
  - enhanced error handling

  Changes Apr. 2004
  - all file handling was replaced by file streams
    ==> no limitation to length of paths and size of files
  - MSDOS no longer supported

  Copyright (c) by J. Rathlev, Apr. 2004 (E-Mail: rathlev@physik.uni-kiel.de)
}

interface

{$I zconf.inc}

uses
  SysUtils, Classes,
  zutil, zlib, crc, zdeflate, zinflate;

const
  PkLocalSignatur = $04034b50;
  PkDirSignatur = $02014b50;
  PkEndSignatur = $06054b50;
  Pk64RecSignatur = $06064b50;
  Pk64LocSignatur = $07064b50;

type
  TPKLocalHeader = packed record
    Signatur    : cardinal;
    Vers,Flag,
    Method      : word;
    FTimeStamp,
    CRC,
    CSize,USize : cardinal;
    FNLength,
    ExtraLength : word;
    end;

  TPKDirHeader = packed record
    Signatur    : cardinal;
    VersMade,
    VersExtr,
    Flag,
    Method      : word;
    FTimeStamp,
    CRC,
    CSize,USize : cardinal;
    FNLength,
    ExtraLength,
    CommLength,
    DiskStart,
    IntAttr     : word;
    ExtAttr,
    Offset      : cardinal;
    end;

  TPKEndHeader = packed record
    Signatur    : cardinal;
    ThisDisk,
    StartDisk,
    ThisEntries,
    TotalEntries : word;
    DirSize,
    Offset      : cardinal;
    CommLength  : word;
    end;

  TPKZip64Record = packed record
    Signatur    : cardinal;
    Size        : int64;
    VersMade,
    VersExtr    : word;
    ThisDisk,
    StartDisk   : cardinal;
    ThisEntries,
    TotalEntries,
    DirSize,
    Offset      : int64;
    end;

  TPKZip64Locator = packed record
    Signatur    : cardinal;
    StartDisk   : cardinal;
    Offset      : int64;
    TotalDisk   : cardinal;
    end;

  gz_stream = record
    stream      : z_stream;
    gz_err      : int;      { error code for last stream operation }
    gz_eof      : boolean;  { set if end of input file }
    inbuf       : pBytef;   { input buffer }
    outbuf      : pBytef;   { output buffer }
    crc         : uLong;    { crc32 of uncompressed data }
    gz_file     : TFileStream;     { .gz file }
    msg,                    { error message - limit 79 chars }
    path        : string[255];   { path name for debugging only - limit 255 chars }
    transparent : boolean;  { true if input file is not a .gz file }
    gzmode      : char;     { 'w' or 'r' }
    USize,CSize,
    filepos,                { start of file section }
    startpos    : int64;    { start of compressed data in file (header skipped) }
    time        : cardinal; { time stamp of file }
    end;

  gzFile = ^gz_Stream;
  gz_streamp = gzFile;
{  gzFile = voidp;}
  z_off_t = long;

  TLongWord = record
    case integer of
    0 : (Long : longword);
    1 : (Lo,Hi : word);
    2 : (LoL,LoH,HiL,HiH : byte);
    3 : (Bytes : array [0..3] of Byte);
    end;

{ --- JR ------------------------------------------------------------ }
function gzopen (apath,amode    : string;
                 var fname      : string;
                 var timestamp  : cardinal) : gzFile;
{ --- Added by TDogan ------------------------------------------------------------ }
function gzopenEX (apath,amode    : string;
                 var fname      : string;
                 var fnamename      : string;
                 var timestamp  : cardinal) : gzFile;
{ --- JR ------------------------------------------------------------ }
function ZipOpen (apath,amode,fname : string;
                  timestamp       : cardinal) : gzFile;
function ZipClose (f:gzFile) : int;
{ ------------------------------------------------------------------- }
function gzread  (f:gzFile; buf:voidp; len:uInt) : int;
function gzgetc  (f:gzfile) : int;
function gzgets  (f:gzfile; buf:PChar; len:int) : PChar;

{$ifndef NO_DEFLATE}
function gzwrite (f:gzFile; buf:voidp; len:uInt) : int;
function gzputc  (f:gzfile; c:char) : int;
function gzputs  (f:gzfile; s:PChar) : int;
function gzflush (f:gzFile; flush:int)           : int;
  {$ifdef GZ_FORMAT_STRING}
  function gzprintf (zfile : gzFile;
					 const format : string;
					 a : array of int);    { doesn't compile }
  {$endif}
{$endif}

function gzseek  (f:gzfile; offset:z_off_t; whence:int) : z_off_t;
function gztell  (f:gzfile) : z_off_t;
function gzclose (f:gzFile) : int;
function gzerror (f:gzFile; var errnum:Int)      : string;

const
  SEEK_SET {: z_off_t} = 0; { seek from beginning of file }
  SEEK_CUR {: z_off_t} = 1; { seek from current position }
  SEEK_END {: z_off_t} = 2;

implementation

const
  Z_EOF = -1;         { same value as in STDIO.H }
  Z_BUFSIZE = 16384;
  { Z_PRINTF_BUFSIZE = 4096; }


  gz_magic : array[0..1] of byte = ($1F, $8B); { gzip magic header }

  { gzip flag byte }

  ASCII_FLAG  = $01; { bit 0 set: file probably ascii text }
  HEAD_CRC    = $02; { bit 1 set: header CRC present }
  EXTRA_FIELD = $04; { bit 2 set: extra field present }
  ORIG_NAME   = $08; { bit 3 set: original file name present }
  COMMENT     = $10; { bit 4 set: file comment present }
  RESERVED    = $E0; { bits 5..7: reserved }

{ ---------------------------------------------------------------- }
(* Strip parts path of "Name" exceeds "Len"
  J. Rathlev  *)
function StripPath (Name : String;
                    Len  : integer) : String;
const
  Punkte = '...';
var
  i,j,nl : integer;
  ok     : boolean;
begin
  nl:=length(Name);
  if nl>=Len then begin
    i:=nl; ok:=true;
    while (Name[i]<>'\') and (i>0) do dec(i);
    if i=0 then Name:=Punkte+system.copy(Name,nl-Len+3,nl)
    else begin
      dec(i); j:=i;
      repeat
        while (Name[j]<>'\') and (j>0) do dec(j);
        dec(j);
        if j<0 then Name:=Punkte+system.copy(Name,nl-Len+3,nl)
        else begin
          ok:=nl-i+j+4<=Len;
          end;
        until ok or (j<0);
      if ok then begin
        inc(j,2);
        delete (Name,j,succ(i-j)); insert (Punkte,Name,j);
        end;
      end;
    end;
  StripPath:=Name;
  end;


function destroy (var s:gz_streamp) : int; forward;
procedure check_header (s              : gz_streamp;
                        var fname      : string;
                        var timestamp  : cardinal); forward;


{ GZOPEN ====================================================================

  Opens a gzip (.gz) file for reading or writing. As Pascal does not use
  file descriptors, the code has been changed to accept only path names.

  The mode parameter defaults to BINARY read or write operations ('r' or 'w')
  but can also include a compression level ('w9') or a strategy: Z_FILTERED
  as in 'w6f' or Z_HUFFMAN_ONLY as in 'w1h'. (See the description of
  deflateInit2 for more information about the strategy parameter.)

  gzopen can be used to open a file which is not in gzip format; in this
  case, gzread will directly read from the file without decompression.

  gzopen returns NIL if the file could not be opened (non-zero IOResult)
  or if there was insufficient memory to allocate the (de)compression state
  (zlib error is Z_MEM_ERROR).

============================================================================}

{ --- JR ------------------------------------------------------------ }
function gzopen (apath,amode    : string;
                 var fname      : string;
                 var timestamp  : cardinal) : gzFile;
{ ------------------------------------------------------------------- }

var
  i        : uInt;
  err      : int;
  level    : int;        { compression level }
  strategy : int;        { compression strategy }
  s        : gz_streamp;

{$IFNDEF NO_DEFLATE}
  gzheader : array [0..9] of byte;
{$ENDIF}

begin
  if (apath='') or (amode='') then begin
  	gzopen := Z_NULL; exit;
    end;

  GetMem (s,sizeof(gz_stream));
  if not Assigned (s) then begin
  	gzopen := Z_NULL; exit;
    end;

  level := Z_DEFAULT_COMPRESSION;
  strategy := Z_DEFAULT_STRATEGY;

  with s^do begin
    stream.zalloc := NIL;     { (alloc_func)0 }
    stream.zfree := NIL;      { (free_func)0 }
    stream.opaque := NIL;     { (voidpf)0 }
    stream.next_in := Z_NULL;
    stream.next_out := Z_NULL;
    stream.avail_in := 0;
    stream.avail_out := 0;
    gz_err := Z_OK;
    gz_eof := false;
    inbuf := Z_NULL;
    outbuf := Z_NULL;
    crc := crc32(0, Z_NULL, 0);
    msg := '';
    transparent := false;
    path := StripPath(apath,255); { limit to 255 chars }
    gzmode := chr(0);
    for i:=1 to Length(amode) do begin
      case amode[i] of
      'r'      : gzmode := 'r';
      'w'      : gzmode := 'w';
      '0'..'9' : level := Ord(amode[i])-Ord('0');
      'f'      : strategy := Z_FILTERED;
      'h'      : strategy := Z_HUFFMAN_ONLY;
        end;
      end;
    if (gzmode=chr(0)) then begin
      destroy(s); FreeMem(s, sizeof(gz_stream));
      gzopen := gzFile(Z_NULL);
      exit;
      end;

    if (gzmode<>'r')  then begin
  {$IFDEF NO_DEFLATE}
      err := Z_STREAM_ERROR;
  {$ELSE}
      err := deflateInit2 (stream, level, Z_DEFLATED, -MAX_WBITS,
               DEF_MEM_LEVEL, strategy);
      { windowBits is passed < 0 to suppress zlib header }

      GetMem (outbuf, Z_BUFSIZE);
      stream.next_out := outbuf;
  {$ENDIF}
      if (err <> Z_OK) or (outbuf = Z_NULL) then begin
        destroy(s); FreeMem(s, sizeof(gz_stream));
        gzopen := gzFile(Z_NULL);
        exit;
        end;
      end

    else begin
      GetMem (inbuf, Z_BUFSIZE);
      stream.next_in := inbuf;

      err := inflateInit2_ (stream, -MAX_WBITS, ZLIB_VERSION, sizeof(z_stream));
        { windowBits is passed < 0 to tell that there is no zlib header }

      if (err <> Z_OK) or (inbuf = Z_NULL) then begin
        destroy(s); FreeMem(s, sizeof(gz_stream));
        gzopen := gzFile(Z_NULL);
        exit;
      end;
    end;

    stream.avail_out := Z_BUFSIZE;

    (* use apath instead of s^.path (JR) *)
    try
      if (gzmode<>'r') then gz_file:=TFileStream.Create(apath,fmCreate)
      else gz_file:=TFileStream.Create(apath,fmOpenRead+fmShareDenyWrite);
    except
      on EFilestreamError do begin
        destroy(s); FreeMem(s, sizeof(gz_stream));
        gzopen := gzFile(Z_NULL);
        exit;
        end;
      end;
    if (gzmode = 'w') then begin { Write a very simple .gz header }
      i:=length(fname);
  {$IFNDEF NO_DEFLATE}
      gzheader [0] := gz_magic [0];
      gzheader [1] := gz_magic [1];
      gzheader [2] := Z_DEFLATED;   { method }
  { --- JR ------------------------------------------------------------ }
      if i>0 then gzheader [3] := $8            { with Filename }
      else gzheader [3] := 0;            { no flags }
      with TLongWord(timestamp) do begin
        gzheader [4] := LoL;            { time[0] }
        gzheader [5] := LoH;            { time[1] }
        gzheader [6] := HiL;            { time[2] }
        gzheader [7] := HiH;            { time[3] }
        end;
  { ------------------------------------------------------------------- }
      gzheader [8] := 0;            { xflags }
      gzheader [9] := 0;            { OS code = MS-DOS }
      try
        gz_file.write (gzheader,10);
      except
        destroy(s); FreeMem(s, sizeof(gz_stream));
        gzopen := gzFile(Z_NULL);
        exit;
        end;
      startpos := startpos+LONG(10);
      if i>0 then begin   // write filename
        inc(i);
        try
          gz_file.write (fname[1],i);
        except
          destroy(s); FreeMem(s, sizeof(gz_stream));
          gzopen := gzFile(Z_NULL);
          exit;
          end;
        startpos := startpos+LONG(i);
        end;
  {$ENDIF}
      end
    else begin
      check_header(s,fname,timestamp); { skip the .gz header }
      {$WARNINGS OFF} { combining signed and unsigned types }
      startpos:=gz_file.Position-stream.avail_in;
      {$WARNINGS ON}
      end;
    end;
  gzopen := gzFile(s);
  end;


{ GZOPENEX ====================================================================

  Opens a gzip (.gz) file for reading or writing. As Pascal does not use
  file descriptors, the code has been changed to accept only path names.
  The only differences from gzopen is that the it is possible to give a different
  name to file in the GZ file then real file name of compressed file.
  For example if you wants to compress any temporary file (e.g "~1AF.TMP")
  but want to give it any other name (e.g  "SAMPLE.GBK"), you just use gzipEx.

  The mode parameter defaults to BINARY read or write operations ('r' or 'w')
  but can also include a compression level ('w9') or a strategy: Z_FILTERED
  as in 'w6f' or Z_HUFFMAN_ONLY as in 'w1h'. (See the description of
  deflateInit2 for more information about the strategy parameter.)

  gzopenEx can be used to open a file which is not in gzip format; in this
  case, gzread will directly read from the file without decompression.

  gzopenEx returns NIL if the file could not be opened (non-zero IOResult)
  or if there was insufficient memory to allocate the (de)compression state
  (zlib error is Z_MEM_ERROR).

============================================================================}
{ --- Added by TDogan ------------------------------------------------------------ }
function gzopenEX (apath,amode    : string;
                 var fname      : string;
                 var fnamename      : string;
                 var timestamp  : cardinal) : gzFile;
{ ------------------------------------------------------------------- }

var
  i        : uInt;
  err      : int;
  level    : int;        { compression level }
  strategy : int;        { compression strategy }
  s        : gz_streamp;

{$IFNDEF NO_DEFLATE}
  gzheader : array [0..9] of byte;
{$ENDIF}

begin
  if (apath='') or (amode='') then begin
  	gzopenEx := Z_NULL; exit;
    end;

  GetMem (s,sizeof(gz_stream));
  if not Assigned (s) then begin
  	gzopenEx := Z_NULL; exit;
    end;

  level := Z_DEFAULT_COMPRESSION;
  strategy := Z_DEFAULT_STRATEGY;

  with s^do begin
    stream.zalloc := NIL;     { (alloc_func)0 }
    stream.zfree := NIL;      { (free_func)0 }
    stream.opaque := NIL;     { (voidpf)0 }
    stream.next_in := Z_NULL;
    stream.next_out := Z_NULL;
    stream.avail_in := 0;
    stream.avail_out := 0;
    gz_err := Z_OK;
    gz_eof := false;
    inbuf := Z_NULL;
    outbuf := Z_NULL;
    crc := crc32(0, Z_NULL, 0);
    msg := '';
    transparent := false;
    path := StripPath(apath,255); { limit to 255 chars }
    gzmode := chr(0);
    for i:=1 to Length(amode) do begin
      case amode[i] of
      'r'      : gzmode := 'r';
      'w'      : gzmode := 'w';
      '0'..'9' : level := Ord(amode[i])-Ord('0');
      'f'      : strategy := Z_FILTERED;
      'h'      : strategy := Z_HUFFMAN_ONLY;
        end;
      end;
    if (gzmode=chr(0)) then begin
      destroy(s); FreeMem(s, sizeof(gz_stream));
      gzopenEx := gzFile(Z_NULL);
      exit;
      end;

    if (gzmode<>'r')  then begin
  {$IFDEF NO_DEFLATE}
      err := Z_STREAM_ERROR;
  {$ELSE}
      err := deflateInit2 (stream, level, Z_DEFLATED, -MAX_WBITS,
               DEF_MEM_LEVEL, strategy);
      { windowBits is passed < 0 to suppress zlib header }

      GetMem (outbuf, Z_BUFSIZE);
      stream.next_out := outbuf;
  {$ENDIF}
      if (err <> Z_OK) or (outbuf = Z_NULL) then begin
        destroy(s); FreeMem(s, sizeof(gz_stream));
        gzopenEx := gzFile(Z_NULL);
        exit;
        end;
      end

    else begin
      GetMem (inbuf, Z_BUFSIZE);
      stream.next_in := inbuf;

      err := inflateInit2_ (stream, -MAX_WBITS, ZLIB_VERSION, sizeof(z_stream));
        { windowBits is passed < 0 to tell that there is no zlib header }

      if (err <> Z_OK) or (inbuf = Z_NULL) then begin
        destroy(s); FreeMem(s, sizeof(gz_stream));
        gzopenEx := gzFile(Z_NULL);
        exit;
      end;
    end;

    stream.avail_out := Z_BUFSIZE;

    (* use apath instead of s^.path (JR) *)
    try
      if (gzmode<>'r') then gz_file:=TFileStream.Create(apath,fmCreate)
      else gz_file:=TFileStream.Create(apath,fmOpenRead+fmShareDenyWrite);
    except
      on EFilestreamError do begin
        destroy(s); FreeMem(s, sizeof(gz_stream));
        gzopenEx := gzFile(Z_NULL);
        exit;
        end;
      end;
    if (gzmode = 'w') then begin { Write a very simple .gz header }
      i:=length(fnamename);// Added by TDogan
  {$IFNDEF NO_DEFLATE}
      gzheader [0] := gz_magic [0];
      gzheader [1] := gz_magic [1];
      gzheader [2] := Z_DEFLATED;   { method }
  { --- JR ------------------------------------------------------------ }
      if i>0 then gzheader [3] := $8            { with Filename }
      else gzheader [3] := 0;            { no flags }
      with TLongWord(timestamp) do begin
        gzheader [4] := LoL;            { time[0] }
        gzheader [5] := LoH;            { time[1] }
        gzheader [6] := HiL;            { time[2] }
        gzheader [7] := HiH;            { time[3] }
        end;
  { ------------------------------------------------------------------- }
      gzheader [8] := 0;            { xflags }
      gzheader [9] := 0;            { OS code = MS-DOS }
      try
        gz_file.write (gzheader,10);
      except
        destroy(s); FreeMem(s, sizeof(gz_stream));
        gzopenEx := gzFile(Z_NULL);
        exit;
        end;
      startpos := startpos+LONG(10);
      if i>0 then begin   // write filename
        inc(i);
        try
          gz_file.write (fnamename[1],i);
        except
          destroy(s); FreeMem(s, sizeof(gz_stream));
          gzopenEx := gzFile(Z_NULL);
          exit;
          end;
        startpos := startpos+LONG(i);
        end;
  {$ENDIF}
      end
    else begin
      check_header(s,fnamename,timestamp); { skip the .gz header }
      {$WARNINGS OFF} { combining signed and unsigned types }
      startpos:=gz_file.Position-stream.avail_in;
      {$WARNINGS ON}
      end;
    end;
  gzopenEx := gzFile(s);
  end;





{ GZSETPARAMS ===============================================================

  Update the compression level and strategy.

============================================================================}

//function gzsetparams (f:gzfile; level:int; strategy:int) : int;

//var

//  s : gz_streamp;
//  written: integer;

//begin

//  s := gz_streamp(f);

//  if (s = NIL) or (s^.gzmode <> 'w') then begin
//    gzsetparams := Z_STREAM_ERROR;
//    exit;
//  end;

  { Make room to allow flushing }
//  if (s^.stream.avail_out = 0) then begin
//    s^.stream.next_out := s^.outbuf;
//    blockwrite(s^.gz_file, s^.outbuf^, Z_BUFSIZE, written);
//    if (written <> Z_BUFSIZE) then s^.z_err := Z_ERRNO;
//    s^.stream.avail_out := Z_BUFSIZE;
//  end;

//  gzsetparams := deflateParams (s^.stream, level, strategy);
//end;


{ GET_BYTE ==================================================================

  Read a byte from a gz_stream. Updates next_in and avail_in.
  Returns EOF for end of file.
  IN assertion: the stream s has been sucessfully opened for reading.

============================================================================}

function get_byte (s:gz_streamp) : int;

begin
  if (s^.gz_eof) then begin
    get_byte := Z_EOF;
    exit;
    end;

  with s^ do if (stream.avail_in = 0) then begin
    try
      stream.avail_in:=gz_file.read (inbuf^,Z_BUFSIZE);
    except
      gz_err := Z_ERRNO;
      end;
    if (stream.avail_in = 0) then begin
      gz_eof := true;
      get_byte := Z_EOF;
      exit;
      end;
    stream.next_in := inbuf;
    end;

  Dec(s^.stream.avail_in);
  get_byte := s^.stream.next_in^;
  Inc(s^.stream.next_in);
  end;


{ GETLONG ===================================================================

   Reads a Longint in LSB order from the given gz_stream.

============================================================================}
function getLong(s : gz_streamp) : uLong;
var
  bt : TLongWord;
  i  : integer;
begin
  { x := uLong(get_byte(s));  - you can't do this with TP, no unsigned long }
  { the following assumes a little endian machine and TP }
  with bt do begin
    LoL:= Byte(get_byte(s));
    LoH:= Byte(get_byte(s));
    HiL:= Byte(get_byte(s));
    HiH:= Byte(get_byte(s));
    if (HiH = Z_EOF) then s^.gz_err := Z_DATA_ERROR;
    GetLong :=Long;
    end;
  end;


{ CHECK_HEADER ==============================================================

  Check the gzip header of a gz_stream opened for reading.
  Set the stream mode to transparent if the gzip magic header is not present.
  Set s^.err  to Z_DATA_ERROR if the magic header is present but the rest of
  the header is incorrect.

  IN assertion: the stream s has already been created sucessfully;
  s^.stream.avail_in is zero for the first time, but may be non-zero
  for concatenated .gz files

  Modification made for timestamp and filename (JR)
============================================================================}

procedure check_header (s              : gz_streamp;
                        var fname      : string;
                        var timestamp  : cardinal);

var
  method : int;  { method byte }
  flags  : int;  { flags byte }
  len    : uInt;
  c      : int;
  last   : boolean;
begin
  { Check the gzip magic header }
  for len := 0 to 1 do begin
    c := get_byte(s);
    if (c <> gz_magic[len]) then begin
      if (len <> 0) then begin
        Inc(s^.stream.avail_in);
        Dec(s^.stream.next_in);
      end;
      if (c <> Z_EOF) then begin
        Inc(s^.stream.avail_in);
        Dec(s^.stream.next_in);
	      s^.transparent := TRUE;
      end;
      if (s^.stream.avail_in <> 0) then s^.gz_err := Z_OK
      else s^.gz_err := Z_STREAM_END;
      exit;
      end;
    end;

  method := get_byte(s);
  flags := get_byte(s);
  if (method <> Z_DEFLATED) or ((flags and RESERVED) <> 0) then begin
    s^.gz_err := Z_DATA_ERROR;
    exit;
    end;

  timestamp:=getlong(s);              { read timestamp }
  for len := 0 to 1 do get_byte(s);   { discard xflags and OS code }

  if ((flags and EXTRA_FIELD) <> 0) then begin { skip the extra field }
    len := uInt(get_byte(s));
    len := len + (uInt(get_byte(s)) shr 8);
    { len is garbage if EOF but the loop below will quit anyway }
    while (len <> 0) and (get_byte(s) <> Z_EOF) do Dec(len);
    end;

  fname:='';
  if ((flags and ORIG_NAME) <> 0) then begin { skip the original file name }
    repeat
      c := get_byte(s);
      last:=(c = 0) or (c = Z_EOF);
      if not last then fname:=fname+chr(c);
      until last;
    end;

  if ((flags and COMMENT) <> 0) then begin { skip the .gz file comment }
    repeat
      c := get_byte(s);
      until (c = 0) or (c = Z_EOF);
    end;

  if ((flags and HEAD_CRC) <> 0) then begin { skip the header crc }
    get_byte(s);
    get_byte(s);
    end;

  if (s^.gz_eof) then
    s^.gz_err := Z_DATA_ERROR
  else
    s^.gz_err := Z_OK;
  end;


{ DESTROY ===================================================================

  Cleanup then free the buffers of given gz_stream. Return a zlib error code.
  Try freeing in the reverse order of allocations.
  Changed (JR): memory for gz_stream is not freed (calling program has to do instead,
    	made to use the info of gz_stream to create the PkZip compatible file directory
    	in the calling program after gzclose)

============================================================================}

function destroy (var s:gz_streamp) : int;

begin

  destroy := Z_OK;

  if not Assigned (s) then begin
    destroy := Z_STREAM_ERROR;
    exit;
  end;

  if (s^.stream.state <> NIL) then begin
    if (s^.gzmode<>'r') then begin
{$IFDEF NO_DEFLATE}
      destroy := Z_STREAM_ERROR;
{$ELSE}
      destroy := deflateEnd(s^.stream);
{$ENDIF}
	end
    else begin
      destroy := inflateEnd(s^.stream);
    end;
  end;

  with s^ do if (path <> '') then begin
    try
      gz_file.Free;
    except
      destroy := Z_ERRNO;
      end;
    end;

  if (s^.gz_err < 0) then destroy := s^.gz_err;

  if Assigned (s^.inbuf) then FreeMem(s^.inbuf, Z_BUFSIZE);
  if Assigned (s^.outbuf) then FreeMem(s^.outbuf, Z_BUFSIZE);
  end;

{ GZREAD ====================================================================

  Reads the given number of uncompressed bytes from the compressed file.
  If the input file was not in gzip format, gzread copies the given number
  of bytes into the buffer.

  gzread returns the number of uncompressed bytes actually read
  (0 for end of file, -1 for error).

============================================================================}

function gzread (f:gzFile; buf:voidp; len:uInt) : int;

var

  s         : gz_streamp;
  start     : pBytef;
  next_out  : pBytef;
  n         : uInt;
  crclen    : uInt;  { Buffer length to update CRC32 }
  filecrc   : uLong; { CRC32 stored in GZIP'ed file }
  filelen   : uLong; { Total lenght of uncompressed file }
  bytes     : integer;  { bytes actually read in I/O blockread }
  total_in  : uLong;
  total_out : uLong;
  fname      : string;
  timestamp  : cardinal;

begin
  s := gz_streamp(f);
  start := pBytef(buf); { starting point for crc computation }

  if (s = NIL) or (s^.gzmode <> 'r') then begin
    gzread := Z_STREAM_ERROR;
    exit;
    end;

  if (s^.gz_err = Z_DATA_ERROR) or (s^.gz_err = Z_ERRNO) then begin
    gzread := -1;
    exit;
    end;

  if (s^.gz_err = Z_STREAM_END) then begin
    gzread := 0;  { EOF }
    exit;
    end;

  with s^ do begin
    stream.next_out := pBytef(buf);
    stream.avail_out := len;
    while (stream.avail_out <> 0) do begin
      if (transparent) then begin
        { Copy first the lookahead bytes: }
        n := stream.avail_in;
        if (n > stream.avail_out) then n := stream.avail_out;
        if (n > 0) then begin
          zmemcpy(stream.next_out,stream.next_in, n);
          inc (stream.next_out, n);
          inc (stream.next_in, n);
          dec (stream.avail_out, n);
          dec (stream.avail_in, n);
          end;
        if (stream.avail_out > 0) then begin
          try
            bytes:=gz_file.read (stream.next_out^,stream.avail_out);
          except
            end;
          dec (stream.avail_out,bytes);
        end;
        dec (len,stream.avail_out);
        inc (stream.total_in,len);
        inc (s^.stream.total_out,len);
        gzread:=len;
        exit;
        end; { IF transparent }

      if (stream.avail_in = 0) and (not gz_eof) then begin
        try
          stream.avail_in:=gz_file.read (inbuf^,Z_BUFSIZE);
          if (stream.avail_in = 0) then begin
            gz_eof := true;
            end;
        except
          gz_err := Z_ERRNO; break;
          end;
        stream.next_in := inbuf;
        end;

      gz_err := inflate(stream,Z_NO_FLUSH);

      if (gz_err = Z_STREAM_END) then begin
        crclen := 0;
        next_out:=stream.next_out;
        while (next_out <> start ) do begin
          dec (next_out);
          inc (crclen);   { Hack because Pascal cannot substract pointers }
          end;
        { Check CRC and original size }
        crc := crc32(crc, start, crclen);
        start := stream.next_out;

        filecrc := getLong (s);
        filelen := getLong (s);

        if (crc <> filecrc) or (stream.total_out <> filelen) then gz_err := Z_DATA_ERROR
        else begin
          { Check for concatenated .gz files: }
          check_header(s,fname,timestamp);
          if (gz_err = Z_OK) then begin
            total_in := stream.total_in;
            total_out := stream.total_out;
            inflateReset (stream);
            stream.total_in := total_in;
            stream.total_out := total_out;
            crc := crc32 (0, Z_NULL, 0);
            end;
          end; {IF-THEN-ELSE}
        end;

      if (gz_err <> Z_OK) or (gz_eof) then break;

      end; {WHILE}

    crclen := 0;
    next_out := stream.next_out;
    while (next_out <> start ) do begin
      dec (next_out);
      inc (crclen);   { Hack because Pascal cannot substract pointers }
      end;
    crc := crc32 (crc, start, crclen);

    gzread := int(len - stream.avail_out);
    end;
  end;


{ GZGETC ====================================================================

  Reads one byte from the compressed file.
  gzgetc returns this byte or -1 in case of end of file or error.

============================================================================}

function gzgetc (f:gzfile) : int;

var c:byte;

begin

  if (gzread (f,@c,1) = 1) then gzgetc := c else gzgetc := -1;

end;


{ GZGETS ====================================================================

  Reads bytes from the compressed file until len-1 characters are read,
  or a newline character is read and transferred to buf, or an end-of-file
  condition is encountered. The string is then Null-terminated.

  gzgets returns buf, or Z_NULL in case of error.
  The current implementation is not optimized at all.

============================================================================}

function gzgets (f:gzfile; buf:PChar; len:int) : PChar;

var

  b      : PChar; { start of buffer }
  bytes  : Int;   { number of bytes read by gzread }
  gzchar : char;  { char read by gzread }

begin
  if (buf = Z_NULL) or (len <= 0) then begin
    gzgets := Z_NULL;
    exit;
  end;

  b := buf;
  repeat
    dec (len);
    bytes := gzread (f, buf, 1);
    gzchar := buf^;
    inc (buf);
  until (len = 0) or (bytes <> 1) or (gzchar = Chr(13));

  buf^ := Chr(0);
  if (b = buf) and (len > 0) then gzgets := Z_NULL else gzgets := b;
  end;


{$IFNDEF NO_DEFLATE}

{ GZWRITE ===================================================================

  Writes the given number of uncompressed bytes into the compressed file.
  gzwrite returns the number of uncompressed bytes actually written
  (0 in case of error).

============================================================================}

function gzwrite (f:gzfile; buf:voidp; len:uInt) : int;

var

  s : gz_streamp;
  written : integer;

begin
  s := gz_streamp(f);

  if (s = NIL) or (s^.gzmode='r') then begin
    gzwrite := Z_STREAM_ERROR;
    exit;
    end;

  with s^ do begin
    stream.next_in := pBytef(buf);
    stream.avail_in := len;

    while (stream.avail_in <> 0) do begin
      if (stream.avail_out = 0) then begin
        stream.next_out := outbuf;
        try
          written:=gz_file.Write(s^.outbuf^, Z_BUFSIZE);
          if (written <> Z_BUFSIZE) then begin
            gz_err := Z_ERRNO; break;
            end;
        except
          gz_err := Z_ERRNO; break;
          end;
        stream.avail_out := Z_BUFSIZE;
        end;

      gz_err := deflate(stream, Z_NO_FLUSH);
      if (gz_err <> Z_OK) then break;
      end; {WHILE}

    crc := crc32(crc, buf, len);
    gzwrite := int(len - stream.avail_in);
    end;
  end;


{ ===========================================================================
   Converts, formats, and writes the args to the compressed file under
   control of the format string, as in fprintf. gzprintf returns the number of
   uncompressed bytes actually written (0 in case of error).
}

{$IFDEF GZ_FORMAT_STRING}
function gzprintf (zfile : gzFile;
                   const format : string;
                   a : array of int) : int;
var
  buf : array[0..Z_PRINTF_BUFSIZE-1] of char;
  len : int;
begin
{$ifdef HAS_snprintf}
    snprintf(buf, sizeof(buf), format, a1, a2, a3, a4, a5, a6, a7, a8,
	     a9, a10, a11, a12, a13, a14, a15, a16, a17, a18, a19, a20);
{$else}
	sprintf(buf, format, a1, a2, a3, a4, a5, a6, a7, a8,
	    a9, a10, a11, a12, a13, a14, a15, a16, a17, a18, a19, a20);
{$endif}
    len := strlen(buf); { old sprintf doesn't return the nb of bytes written }
    if (len <= 0) return 0;

    gzprintf := gzwrite(file, buf, len);
end;
{$ENDIF}


{ GZPUTC ====================================================================

  Writes c, converted to an unsigned char, into the compressed file.
  gzputc returns the value that was written, or -1 in case of error.

============================================================================}

function gzputc (f:gzfile; c:char) : int;
begin
  if (gzwrite (f,@c,1) = 1) then
  {$IFDEF FPC}
    gzputc := int(ord(c))
  {$ELSE}
    gzputc := int(c)
  {$ENDIF}
  else
    gzputc := -1;
end;


{ GZPUTS ====================================================================

  Writes the given null-terminated string to the compressed file, excluding
  the terminating null character.
  gzputs returns the number of characters written, or -1 in case of error.

============================================================================}

function gzputs (f:gzfile; s:PChar) : int;
begin
  gzputs := gzwrite (f, voidp(s), strlen(s));
end;


{ DO_FLUSH ==================================================================

  Flushes all pending output into the compressed file.
  The parameter flush is as in the zdeflate() function.

============================================================================}

function do_flush (f:gzfile; flush:int) : int;
var
  len     : uInt;
  done    : boolean;
  s       : gz_streamp;
  written : integer;
begin
  done := false;
  s := gz_streamp(f);

  if (s = NIL) or (s^.gzmode = 'r') then begin
    do_flush := Z_STREAM_ERROR;
    exit;
    end;

  with s^ do begin
    stream.avail_in := 0; { should be zero already anyway }
    while true do begin
      len := Z_BUFSIZE - stream.avail_out;
      if (len <> 0) then begin
        try
          written:=gz_file.Write(outbuf^,len);
          if (written <> len) then begin
            gz_err := Z_ERRNO; break;
            end;
        except
          gz_err := Z_ERRNO; break;
          end;
        stream.next_out := outbuf;
        stream.avail_out := Z_BUFSIZE;
        end;

      if (done) then break;
      gz_err := deflate(stream, flush);

      { Ignore the second of two consecutive flushes: }
      if (len = 0) and (gz_err = Z_BUF_ERROR) then gz_err := Z_OK;

      { deflate has finished flushing only when it hasn't used up
        all the available space in the output buffer: }
      done := (stream.avail_out <> 0) or (gz_err = Z_STREAM_END);
      if (gz_err <> Z_OK) and (gz_err <> Z_STREAM_END) then break;
    end; {WHILE}

    if (gz_err = Z_STREAM_END) then do_flush:=Z_OK else do_flush:=gz_err;
    end;
  end;

{ GZFLUSH ===================================================================

  Flushes all pending output into the compressed file.
  The parameter flush is as in the zdeflate() function.

  The return value is the zlib error number (see function gzerror below).
  gzflush returns Z_OK if the flush parameter is Z_FINISH and all output
  could be flushed.

  gzflush should be called only when strictly necessary because it can
  degrade compression.

============================================================================}

function gzflush (f:gzfile; flush:int) : int;
var
  err : int;
  s   : gz_streamp;
begin
  s := gz_streamp(f);
  err := do_flush (f, flush);

  if (err <> 0) then begin
	  gzflush := err; exit;
    end;

  if (s^.gz_err = Z_STREAM_END) then gzflush := Z_OK else gzflush := s^.gz_err;
  end;

{$ENDIF} (* NO DEFLATE *)


{ GZREWIND ==================================================================

  Rewinds input file.

============================================================================}

function gzrewind (f:gzFile) : int;
var
  s:gz_streamp;
begin
  gzrewind := 0;
  s := gz_streamp(f);

  if (s = NIL) or (s^.gzmode <> 'r') then begin
    gzrewind := -1; exit;
    end;

  with s^ do begin
    gz_err := Z_OK;
    gz_eof := false;
    stream.avail_in := 0;
    stream.next_in := inbuf;

    if (startpos = 0) then begin { not a compressed file }
      gz_file.Seek (0,soFromBeginning);
      exit;
      end;

    inflateReset(stream);
    try
      gz_file.Seek (startpos,soFromBeginning);
    except
      on EFilerError do gzrewind := 1;
      end;
    end;
  end;


{ GZSEEK ====================================================================

  Sets the starting position for the next gzread or gzwrite on the given
  compressed file. The offset represents a number of bytes from the beginning
  of the uncompressed stream.

  gzseek returns the resulting offset, or -1 in case of error.
  SEEK_END is not implemented, returns error.
  In this version of the library, gzseek can be extremely slow.

============================================================================}

function gzseek (f:gzfile; offset:z_off_t; whence:int) : z_off_t;
var
  s : gz_streamp;
  size : uInt;
begin
  gzseek:=0;
  s := gz_streamp(f);

  if (s = NIL) or (whence = SEEK_END) or (s^.gz_err = Z_ERRNO)
      or (s^.gz_err = Z_DATA_ERROR) then begin
	  gzseek := z_off_t(-1); exit;
    end;

  with s^ do begin
    if (gzmode<>'r') then begin
    {$IFDEF NO_DEFLATE}
      gzseek := z_off_t(-1); exit;
    {$ELSE}
      if (whence = SEEK_SET) then dec(offset,stream.total_out);
      if (offset < 0) then begin;
        gzseek := z_off_t(-1); exit;
        end;

      { At this point, offset is the number of zero bytes to write. }
      if (inbuf = Z_NULL) then begin
        GetMem (s^.inbuf, Z_BUFSIZE);
        zmemzero(s^.inbuf, Z_BUFSIZE);
        end;

      while (offset > 0) do begin
        size := Z_BUFSIZE;
        if (offset < Z_BUFSIZE) then size := uInt(offset);

        size := gzwrite(f,inbuf,size);
        if (size = 0) then begin
          gzseek := z_off_t(-1); exit;
          end;

        dec (offset,size);
        end;

      gzseek := z_off_t(stream.total_in); exit;
    {$ENDIF}
      end;

    { Rest of function is for reading only }
    { compute absolute position }
    if (whence = SEEK_CUR) then inc (offset,stream.total_out);
    if (offset < 0) then begin
      gzseek := z_off_t(-1); exit;
      end;

    if (transparent) then begin
      stream.avail_in := 0;
      stream.next_in := s^.inbuf;
      try
        gz_file.Seek (offset,soFromBeginning);
      except
        on EFilerError do begin
          gzseek:=z_off_t(-1); exit;
          end;
        end;
      stream.total_in := uLong(offset);
      stream.total_out := uLong(offset);
      gzseek := z_off_t(offset);
      exit;
      end;

    { For a negative seek, rewind and use positive seek }
    if (uLong(offset) >= stream.total_out) then dec (offset, stream.total_out)
    else if (gzrewind(f) <> 0) then begin
      gzseek := z_off_t(-1); exit;
      end;

    { offset is now the number of bytes to skip. }
    if (offset <> 0) and (outbuf = Z_NULL)
    then GetMem (outbuf, Z_BUFSIZE);

    while (offset > 0) do begin
      size := Z_BUFSIZE;
      if (offset < Z_BUFSIZE) then size := int(offset);
      size := gzread (f, s^.outbuf, size);
      if (size <= 0) then begin
        gzseek := z_off_t(-1); exit;
        end;
      dec(offset, size);
      end;

    gzseek := z_off_t(stream.total_out);
    end;
  end;


{ GZTELL ====================================================================

  Returns the starting position for the next gzread or gzwrite on the
  given compressed file. This position represents a number of bytes in the
  uncompressed data stream.

============================================================================}

function gztell (f:gzfile) : z_off_t;
begin
  gztell := gzseek (f, 0, SEEK_CUR);
end;


{ GZEOF =====================================================================

  Returns TRUE when EOF has previously been detected reading the given
  input stream, otherwise FALSE.

============================================================================}

//function gzeof (f:gzfile) : boolean;
//var
//  s:gz_streamp;
//begin
//  s := gz_streamp(f);

//  if (s=NIL) or (s^.gzmode<>'r') then
//    gzeof := false
//  else
//    gzeof := s^.z_eof;
//end;


{ PUTLONG ===================================================================

  Outputs a Longint in LSB order to the given file
  The return value is true on write error

============================================================================}

function putLong (var f : TFileStream; x : uLong) : boolean;
var
  n : int;
begin
  putLong:=false;
  try
    f.Write(TLongWord(x).Bytes,4)
  except
    putLong:=true; exit;
    end;
 end;


{ GZCLOSE ===================================================================

  Flushes all pending output if necessary, closes the compressed file
  and deallocates all the (de)compression state.

  The return value is the zlib error number (see function gzerror below).

============================================================================}

function gzclose (f:gzFile) : int;
var
  err : int;
  s   : gz_streamp;
begin
  s := gz_streamp(f);

  if (s = NIL) then begin
    gzclose := Z_STREAM_ERROR; exit;
    end;

  with s^ do begin
    if (gzmode<>'r') then begin
  {$IFDEF NO_DEFLATE}
      gzclose := Z_STREAM_ERROR; exit;
  {$ELSE}
      err := do_flush (f, Z_FINISH);
      if (err <> Z_OK) then begin
        gzclose := destroy (gz_streamp(f));
        FreeMem(gz_streamp(f), sizeof(gz_stream));
        exit;
        end;

      if putLong (gz_file,crc) or putLong (gz_file,stream.total_in) then begin
        gzclose := Z_STREAM_ERROR;
        exit;
        end;
  {$ENDIF}
      end;

    gzclose := destroy (gz_streamp(f));
    FreeMem(gz_streamp(f), sizeof(gz_stream));
    end;
  end;


{ GZERROR ===================================================================

  Returns the error message for the last error which occured on the
   given compressed file. errnum is set to zlib error number. If an
   error occured in the file system and not in the compression library,
   errnum is set to Z_ERRNO and the application may consult errno
   to get the exact error code.

============================================================================}

function gzerror (f:gzfile; var errnum:int) : string;
var
 m : string;
 s : gz_streamp;
begin
  s := gz_streamp(f);
  if (s = NIL) then begin
    errnum := Z_STREAM_ERROR;
    gzerror := zError(Z_STREAM_ERROR);
    end;

  errnum := s^.gz_err;
  if (errnum = Z_OK) then begin
    gzerror := zError(Z_OK); exit;
    end;

  m := s^.stream.msg;
  if (errnum = Z_ERRNO) then m := '';
  if (m = '') then m := zError(s^.gz_err);

  s^.msg := s^.path+': '+m;
  gzerror := s^.msg;
  end;

{ ZIPOPEN =====(JR)=========================================================
  see gzopen (above) but only write
  ZipOpen writes a PK-Zip compatible file header
============================================================================}
function ZipOpen (apath,amode,fname : string;
                  timestamp        : cardinal) : gzFile;
var
  i        : uInt;
  err      : int;
  level    : int;        { compression level }
  strategy : int;        { compression strategy }
  s        : gz_streamp;
{$IFNDEF NO_DEFLATE}
  PKheader : TPKLocalHeader;
{$ENDIF}

begin
  if (apath='') or (amode='') then
  begin
   	ZipOpen := Z_NULL; exit;
  end;

  GetMem (s,sizeof(gz_stream));

  if not Assigned (s) then
  begin
	  ZipOpen := Z_NULL;
    exit;
  end;

  level := Z_DEFAULT_COMPRESSION;
  strategy := Z_DEFAULT_STRATEGY;

  with s^ do
  begin
    stream.zalloc := NIL;     { (alloc_func)0 }
    stream.zfree := NIL;      { (free_func)0 }
    stream.opaque := NIL;     { (voidpf)0 }
    stream.next_in := Z_NULL;
    stream.next_out := Z_NULL;
    stream.avail_in := 0;
    stream.avail_out := 0;
    gz_err := Z_OK;
    gz_eof := false;
    inbuf := Z_NULL;
    outbuf := Z_NULL;
    crc := crc32(0, Z_NULL, 0);
    msg := '';
    transparent := false;
    path := StripPath(apath,255); { limit to 255 chars }
    gzmode := 'w';
    time := TimeStamp;
    for i:=1 to Length(amode) do
    begin
      case amode[i] of
        '0'..'9' : level := Ord(amode[i])-Ord('0');
        'f'      : strategy := Z_FILTERED;
        'h'      : strategy := Z_HUFFMAN_ONLY;
      end;
    end;
    if (gzmode=chr(0)) then
    begin
      destroy(s); FreeMem(s, sizeof(gz_stream));
      ZipOpen := gzFile(Z_NULL);
      exit;
    end;

  {$IFDEF NO_DEFLATE}
    err := Z_STREAM_ERROR;
  {$ELSE}
    err := deflateInit2 (stream, level, Z_DEFLATED, -MAX_WBITS,
                                     DEF_MEM_LEVEL, strategy);
            { windowBits is passed < 0 to suppress zlib header }

    GetMem (outbuf, Z_BUFSIZE);
    stream.next_out := outbuf;
  {$ENDIF}
    if (err <> Z_OK) or (outbuf = Z_NULL) then
    begin
      destroy(s); FreeMem(s, sizeof(gz_stream));
      ZipOpen := gzFile(Z_NULL);
      exit;
    end;

    stream.avail_out := Z_BUFSIZE;

    try
      gz_file:=TFileStream.Create(apath,fmOpenReadWrite);
      filepos:=gz_file.Size;
      gz_file.Seek(filepos,0);
    except
      destroy(s); FreeMem(s, sizeof(gz_stream));
      ZipOpen := gzFile(Z_NULL);
      exit;
    end;

    i:=length(fname);
    if (gzmode = 'w') then begin { Write the Pk-header }
  {$IFNDEF NO_DEFLATE}
      with PKHeader do
      begin
        Signatur:=PKLocalSignatur;
        Vers:=$14;
        Flag:=2;
        Method:=8;
        FTimeStamp:=TimeStamp;
        CRC:=0;
        CSize:=0;
        USize:=0;
        FNLength:=i;
        ExtraLength:=0;
      end;
      gz_file.Write (PKheader,sizeof(PkHeader));
      startpos := filepos+LONG(sizeof(PkHeader));

      if i>0 then begin  // filename
        gz_file.Write (fname[1], i);
        startpos := startpos+i;
        end;
  {$ENDIF}
      end;
    end;
  ZipOpen := gzFile(s);
  end;

{ ZIPCLOSE ===================================================================

  Flushes all pending output if necessary, closes the compressed file
  and deallocates all the (de)compression state.
  Writes CRC and lebgth information to header

  The return value is the zlib error number (see function gzerror below).

============================================================================}

function ZipClose (f:gzFile) : int;
var
  err : int;
  s   : gz_streamp;
begin
  s := gz_streamp(f);
  if (s = NIL) then
  begin
    ZipClose := Z_STREAM_ERROR;
    exit;
  end;

  if (s^.gzmode = 'w') then
  begin
{$IFDEF NO_DEFLATE}
    ZipClose := Z_STREAM_ERROR; exit;
{$ELSE}
    err := do_flush (f, Z_FINISH);
    if (err <> Z_OK) then
    begin
      ZipClose := destroy (gz_streamp(f));
      FreeMem(f, sizeof(gz_stream));
      exit;
    end;

    with s^ do
    begin
      USize:=stream.total_in;
      with gz_file do
      begin
        CSize:=Size-startpos;
        Seek (filepos+14,soFromBeginning);
      end;
      if putLong (gz_file, crc) or putLong (gz_file, CSize) or
                  putLong (gz_file, USize) then
      begin
        ZipClose := Z_STREAM_ERROR;
        exit;
      end;
    end;
{$ENDIF}
  end;
  ZipClose := destroy (gz_streamp(f));
end;

end.
