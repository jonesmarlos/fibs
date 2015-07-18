
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

unit PortUnit;

interface

function GetSysComputerName: string;
function GetSysIPAddress(AComputerName: string): string;
function PreparePORTString(APortToConnect: Word): string;

implementation

uses Windows, winsock, SysUtils;

function GetSysComputerName: string;
{gets local computer name via WinAPI}
var
  size: DWORD;
begin
  size := MAX_COMPUTERNAME_LENGTH + 1; {set + 1 to be sure}
  SetLength(Result, size);
  if GetComputerName(PChar(Result), size) then
    SetLength(Result, StrLen(PChar(Result)))
  else
  begin
    {error handling}
    Result := 'Error ' + IntToStr(GetLastError);
  end; {else begin..}
end; {function TconWhoAmI.GetSysComputerName}

function GetSysIPAddress(AComputerName: string): string;
{gets system IP address using Winsock}
var
  r: Integer;
  WSAData: TWSAData;
  HostEnt: PHostEnt;
  host: string;
  SockAddr: TSockAddrIn;
begin
  Result := '';
  r := WSAStartup(MakeWord(1, 1), WSAData);
  if (r = 0) then
  try
    host := AComputerName;
    if (host = '') then
    begin
      SetLength(host, MAX_PATH);
      GetHostName(PChar(host), MAX_PATH);
    end;
    HostEnt := GetHostByName(PChar(host));
    if HostEnt <> nil then
    begin
      SockAddr.sin_addr.S_addr := Longint(PLongint(HostEnt^.h_addr_list^)^);
      Result := inet_ntoa(SockAddr.sin_addr);
    end;
  finally
    WSACleanup;
  end; {try..finally..}
end; {function TconWhoAmI.GetSysIPAddress}

function PreparePORTString(APortToConnect: Word): string;
var
  IPStr: string;
begin
  Result := '';
  IPStr := GetSysIPAddress(GetSysComputerName);
  Result := StringReplace(IPStr, '.', ',', [rfReplaceAll]) + ',' +
    IntToStr(APortToConnect div 256) + ',' + IntToStr(APortToConnect mod 256);
end;

end.
