
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

unit ServiceUtilsUnit;

interface
uses
  Windows;

function StartService(ServiceName: string): Boolean;
function StopService(ServiceName: string): Boolean;
function ChangeServiceStartType(ServiceName: string; ServiceStartType: DWORD): Boolean;

implementation

uses
  SvcMgr, WinSvc, SysUtils;

// ServiceName      : FIBSBackupService
// ServiceStartType : SERVICE_AUTO_START  veya SERVICE_DEMAND_START

function ChangeServiceStartType(ServiceName: string; ServiceStartType: DWORD): Boolean;
var
  Svc: Integer;
  SvcMgr: Integer;
begin
  SvcMgr := OpenSCManager(nil, nil, SC_MANAGER_ALL_ACCESS);
  Svc := OpenService(SvcMgr, PChar(ServiceName), SERVICE_ALL_ACCESS);
  if Svc = 0 then
    RaiseLastOSError;
  try
    Result := ChangeServiceConfig(
      Svc, // handle to service
      SERVICE_NO_CHANGE, // service Type
      ServiceStartType, // start Type
      SERVICE_NO_CHANGE, // Error Control
      nil, // pointer to service binary file name
      nil, // pointer to load ordering group name
      nil, // pointer to variable to get tag identifier
      nil, // pointer to array of dependency names
      nil, // pointer to account name of service
      nil, // pointer to password for service account
      nil // pointer to display name
      );
    //    if not DeleteService(Svc) then  RaiseLastOSError;
  finally
    CloseServiceHandle(Svc);
  end;
end;

// ServiceName      : FIBSBackupService

function StopService(ServiceName: string): Boolean;
var
  Svc: Integer;
  SvcMgr: Integer;
  Status: SERVICE_STATUS;
begin
  SvcMgr := OpenSCManager(nil, nil, SC_MANAGER_ALL_ACCESS);
  Svc := OpenService(SvcMgr, PChar(ServiceName), SERVICE_ALL_ACCESS);
  if Svc = 0 then
    RaiseLastOSError;
  try
    Result := ControlService(Svc, SERVICE_CONTROL_STOP, Status);
  finally
    CloseServiceHandle(Svc);
  end;
end;

// ServiceName      : FIBSBackupService

function StartService(ServiceName: string): Boolean;
var
  Svc: Integer;
  SvcMgr: Integer;
  Status: SERVICE_STATUS;
begin
  SvcMgr := OpenSCManager(nil, nil, SC_MANAGER_ALL_ACCESS);
  Svc := OpenService(SvcMgr, PChar(ServiceName), SERVICE_ALL_ACCESS);
  if Svc = 0 then
    RaiseLastOSError;
  try
    Result := ControlService(Svc, SERVICE_CONTROL_CONTINUE, Status);
  finally
    CloseServiceHandle(Svc);
  end;
end;

function GetServiceStartType(ServiceName: string): DWORD;
var
  Mgr, Svc: Integer;
  Config: pointer;
  size: DWORD;
begin
  { Results
    SERVICE_BOOT_START            = 0;
    SERVICE_SYSTEM_START          = 1
    SERVICE_AUTO_START            = 2
    SERVICE_DEMAND_START          = 3
    SERVICE_DISABLED              = 4
    ERROR                         = 5 //  Talat
  }
  Result := 5;
  Mgr := OpenSCManager(nil, nil, SC_MANAGER_ALL_ACCESS);
  if Mgr <> 0 then
  begin
    Svc := OpenService(Mgr, PChar(ServiceName), SERVICE_ALL_ACCESS);
    if (Svc <> 0) then
    begin
      QueryServiceConfig(Svc, nil, 0, size);
      Config := AllocMem(size);
      try
        QueryServiceConfig(Svc, Config, size, size);
        Result := PQueryServiceConfig(Config)^.dwStartType;
      finally
        Dispose(Config);
      end;
      CloseServiceHandle(Svc);
    end;
    CloseServiceHandle(Mgr);
  end;
end;

end.
