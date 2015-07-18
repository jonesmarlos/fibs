
unit RetMonitorTools;
//Author : retnyg @ http://krazz.net/retnyg

interface
uses windows, Types, Graphics;

const
  MinFact = 125;
  MaxFact = 167;
  MONITOR_DEFAULTTONULL = $0; //If the monitor is not found, return 0
  MONITOR_DEFAULTTOPRIMARY = $1; //If the monitor is not found, return the primary monitor
  MONITOR_DEFAULTTONEAREST = $2; //If the monitor is not found, return the nearest monitor

type

  PMONITORINFO = ^TMONITORINFO;
  TMONITORINFO = record
    cbSize: DWORD;
    rcMonitor: TRect;
    rcWork: TRect;
    dwFlags: DWORD;
  end;

  // own functions
function GetDesktopDimensions: TRect;
function GuessNumberMonitors: Byte;
function GetNumberMonitors: Byte;
function MoveWindowToMonitor(hnd: HWND; monNum: Byte): Boolean;
function GetMonitorFromWindow(hnd: HWND): Byte;

// imported API functions
function GetMonitorInfo(AMonitorHandle: pointer; var ADataRecord: TMONITORINFO): Boolean;
stdcall; External 'User32.dll' Name 'GetMonitorInfoA'; overload;
function MonitorFromPoint(APoint: TPoint; AFlags: DWORD): pointer;
stdcall; External 'User32.dll';
function MonitorFromWindow(AWindowHandle: HWND; AFlags: DWORD): pointer;
stdcall; External 'User32.dll';

implementation

function GetDesktopDimensions: TRect;
var
  DC: HDC;
  Cn: TCanvas;
begin
  DC := GetDC(0);
  Cn := TCanvas.Create;
  Cn.Handle := DC;
  result := Cn.ClipRect;
  Cn.Free;
  ReleaseDc(0, DC);
end;

function GuessNumberMonitors: Byte;
var
  dr: TRect;
begin
  result := 1;
  dr := GetDesktopDimensions;
  while (dr.Right * 100) div dr.Bottom > MaxFact do
  begin
    inc(result);
    dr.Right := (dr.Right) - ((dr.Bottom * MinFact) div 100);
  end;
end;

function GetNumberMonitors: Byte;
// slower than GuessNumberMonitors
var
  LastMon, NewMon: pointer;
  dr: TRect;
begin
  result := 0;
  LastMon := nil;
  dr := GetDesktopDimensions;
  while dr.Right > 0 do
  begin
    NewMon := MonitorFromPoint(dr.BottomRight, MONITOR_DEFAULTTONEAREST);
    if NewMon <> LastMon then
    begin
      inc(result);
      LastMon := NewMon;
    end;
    dec(dr.Right, 100);
  end;
end;

function MoveWindowToMonitor(hnd: HWND; monNum: Byte): Boolean;
var
  dr: TRect;
  NumMon: Byte;
  PxpMon, NewX: DWORD;
begin
  result := false;
  NumMon := GuessNumberMonitors;
  if (NumMon > 0) and (monNum > 0) then
  begin
    dr := GetDesktopDimensions;
    PxpMon := dr.Right div NumMon;
    if GetwindowRect(hnd, dr) then
    begin
      NewX := (dr.Left mod PxpMon) + ((PxpMon * monNum) - PxpMon);
      if MoveWindow(hnd, NewX, dr.Top, dr.Right - dr.Left, dr.Bottom - dr.Top, true) then
        result := true;
    end;
  end;
end;

function GetMonitorFromWindow(hnd: HWND): Byte;
var
  dr: TRect;
  NumMon: Byte;
  PxpMon: DWORD;
begin
  result := 1;
  NumMon := GuessNumberMonitors;
  if (NumMon > 1) then
  begin
    dr := GetDesktopDimensions;
    PxpMon := dr.Right div NumMon;
    if GetwindowRect(hnd, dr) then
      result := (dr.Left div PxpMon) + 1;
  end;
end;

end.

