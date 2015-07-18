
 {****************************************************************************}
 {                                                                            }
 {                      FIBSSM FIBS Service Manager                           }
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

unit MiscServices;

interface

uses
  Windows, SvcMgr, WinSvc, Classes, Controls, SysUtils;

type
  EServiceException=class(Exception);

function GetServiceStartType(ServiceName: string):dword;
function ChangeServiceStartType(ServiceName:string; ServiceStartType: dword):Boolean;

function ZaherIsServiceManagerAvailable(const MachineName: string): Boolean;
function ZaherInstallService(FileName, ServiceName, DisplayName, Description: string; ServiceType, StartType: Cardinal; Dependencies:array of string; LoadGroup: string; TagID: DWORD): Boolean;
function ZaherIsServiceInstalled(MachineName, ServiceName: string): Boolean;
function ZaherRemoveService(MachineName, ServiceName: string): Boolean;
function ZaherStartService(MachineName, ServiceName: string): Boolean;
function ZaherStopService(MachineName, ServiceName: string): Boolean;
function ZaherIsServiceRunning(MachineName, ServiceName: string): Boolean;

implementation

uses
  Registry;


function GetServiceStartType(ServiceName: string):dword;
var
   Mgr, Svc: Integer;
   Config: Pointer;
   Size: DWord;
   n: integer;
   StartType: DWord;
 begin
{
  SERVICE_BOOT_START            = 0;
  SERVICE_SYSTEM_START          = 1
  SERVICE_AUTO_START            = 2
  SERVICE_DEMAND_START          = 3
  SERVICE_DISABLED              = 4
  ERROR                         = 5//  Talat
}
   result:=5;
   Mgr := OpenSCManager(nil, nil, SC_MANAGER_ALL_ACCESS);
   if Mgr <> 0 then
   begin
     Svc := OpenService(Mgr, PChar(ServiceName), SERVICE_ALL_ACCESS);
     if (Svc <> 0) then
     begin
       QueryServiceConfig (Svc, nil, 0, Size);
       Config := AllocMem(Size);
       try
         QueryServiceConfig(Svc, Config, Size, Size);
         Result:=PQueryServiceConfig(Config)^.dwStartType;
       finally
         Dispose(Config);
       end;
       CloseServiceHandle(Svc);
     end;
     CloseServiceHandle(Mgr);
   end;
 end;


  // ServiceName      : FIBSBackupService
  // ServiceStartType : SERVICE_AUTO_START  veya SERVICE_DEMAND_START
  function ChangeServiceStartType(ServiceName:string; ServiceStartType: dword):Boolean;
  var
    Svc     : Integer;
    SvcMgr  : Integer;
  begin
    Result:=False;
    SvcMgr := OpenSCManager(nil, nil, SC_MANAGER_ALL_ACCESS);
    Svc := OpenService(SvcMgr, PChar(ServiceName), SERVICE_ALL_ACCESS);
    if Svc = 0 then  RaiseLastOSError;
    try
      Result:=ChangeServiceConfig(
                     Svc,                   // handle to service
                     SERVICE_NO_CHANGE,     // service Type
                     ServiceStartType,      // start Type
                     SERVICE_NO_CHANGE,     // Error Control
                     nil,   // pointer to service binary file name
                     nil,   // pointer to load ordering group name
                     nil,   // pointer to variable to get tag identifier
                     nil,   // pointer to array of dependency names
                     nil,   // pointer to account name of service
                     nil,   // pointer to password for service account
                     nil    // pointer to display name
                     );
//    if not DeleteService(Svc) then  RaiseLastOSError;
    finally
      CloseServiceHandle(Svc);
    end;
  end;



function ZaherIsServiceManagerAvailable(const MachineName: string): Boolean;
var
  hSCM: THandle;
begin
  if Win32Platform = VER_PLATFORM_WIN32_NT then
  begin
    hSCM := OpenSCManager(PChar(MachineName), 'ServicesActive', SC_MANAGER_ALL_ACCESS);
    if hSCM = 0 then
      Result := False
    else
    begin
      Result :=  True;
      CloseServiceHandle(hSCM);
    end;
  end
  else
    Result := False;
end;

function ZaherOpenServiceManager(const MachineName: string = ''): THANDLE;
begin
  if Win32Platform = VER_PLATFORM_WIN32_NT then
  begin
    Result := OpenSCManager(PChar(MachineName), 'ServicesActive', SC_MANAGER_ALL_ACCESS);
    if Result = 0 then
      raise EServiceException.Create('the servicemanager is not available');
  end
  else
    raise EServiceException.Create('only nt based systems support services');
end;

function ZaherIsServiceInstalled(MachineName, ServiceName: string): boolean;
var
  hSCM: THandle;
  hService: THandle;
  Err:Cardinal;
begin
  hSCM := ZaherOpenServiceManager(MachineName);
  if hSCM <> 0 then
  begin
    hService := OpenService(hSCM, PChar(ServiceName), SERVICE_QUERY_CONFIG);
    if hService = 0 then
    begin
      Err:=GetLastError;
      if Err <> ERROR_SERVICE_DOES_NOT_EXIST then
        RaiseLastOSError;
      Result:=False;
    end
    else
    begin
      Result := true;
      CloseServiceHandle(hService)
    end;
    CloseServiceHandle(hSCM)
  end
  else
    Result := false;
end;

function ZaherInstallService(FileName, ServiceName, DisplayName, Description: string; ServiceType, StartType: Cardinal; Dependencies:array of string; LoadGroup: string; TagID: DWORD): boolean;
var
  hSCM: THandle;
  hService: THandle;
  DependOn:string;
  aReg:TRegistry;
  i:Integer;
  PTagID:PDWORD;
  PDependOn:PChar;
begin
  hSCM := ZaherOpenServiceManager();
  Result := false;
  if hSCM <> 0 then
  begin
    DependOn := '';
    if Length(Dependencies)>0 then
    begin
      for i :=0 to Length(Dependencies)-1 do
      begin
        DependOn:=DependOn + Dependencies[i]+#0;
      end;
      DependOn:=DependOn + #0;
    end;
    PTagID:=@TagID;
    if DependOn<>'' then
      PDependOn:=PChar(DependOn)
    else
      PDependOn:=nil;
    hService := CreateService(hSCM, PChar(ServiceName), PChar(DisplayName), SERVICE_ALL_ACCESS, ServiceType, StartType, 0, PChar(FileName), PChar(LoadGroup), PTagID, PDependOn, nil, nil);
    if hService = 0 then
      RaiseLastOSError
    else
    begin
      Result := true;
   // Win2K & WinXP supports aditional description text for services
      if Description <> '' then
      begin
        aReg:=TRegistry.Create;
        try
          aReg.RootKey := HKEY_LOCAL_MACHINE;
          if aReg.OpenKey('System\CurrentControlSet\Services\' + ServiceName, False) then
            aReg.WriteString('Description', Description);
        finally
          aReg.Free;
        end;
      end;
      CloseServiceHandle(hService)
    end;
    CloseServiceHandle(hSCM)
  end
end;

function ZaherRemoveService(MachineName, ServiceName: string): boolean;
var
  hSCM: THandle;
  hService: THandle;
begin
  hSCM := ZaherOpenServiceManager(MachineName);
  Result := false;
  if hSCM <> 0 then
  begin
    hService := OpenService(hSCM, PChar(ServiceName), SERVICE_ALL_ACCESS);
    if hService <> 0 then
    begin
      Result := DeleteService(hService);
      CloseServiceHandle(hService)
    end;
    CloseServiceHandle(hSCM)
  end
end;

function ZaherStartService(MachineName, ServiceName: string): boolean;
var
  hSCM: THandle;
  hService: THandle;
  p:PChar;
  Err:Cardinal;
begin
  hSCM := ZaherOpenServiceManager(MachineName);
  Result := false;
  if hSCM <> 0 then
  begin
    hService := OpenService(hSCM, PChar(ServiceName), SERVICE_START);
    if hService <> 0 then
    begin
      P:=nil;
      Result := WinSvc.StartService(hService, 0, P);
      if not Result then
      begin
        Err:=GetLastError;
        if Err <> ERROR_SERVICE_ALREADY_RUNNING then
          RaiseLastOSError;
      end;
      CloseServiceHandle(hService)
    end;
    CloseServiceHandle(hSCM)
  end;
end;

function ZaherStopService(MachineName, ServiceName: string): boolean;
var
  hSCM: THandle;
  hService: THandle;
  Status: SERVICE_STATUS;
begin
  hSCM := ZaherOpenServiceManager(MachineName);
  Result := false;
  if hSCM <> 0 then
  begin
    hService := OpenService(hSCM, PChar(ServiceName), SERVICE_STOP);
    if hService <> 0 then
    begin
      Result := ControlService(hService, SERVICE_CONTROL_STOP, Status);
      CloseServiceHandle(hService)
    end;
    CloseServiceHandle(hSCM)
  end;
end;

function ZaherIsServiceRunning(MachineName, ServiceName: string): boolean;
var
  hSCM: THandle;
  hService: THandle;
  Status: SERVICE_STATUS;
begin
  hSCM := ZaherOpenServiceManager(MachineName);
  Result := false;
  if hSCM <> 0 then
  begin
    hService := OpenService(hSCM, PChar(ServiceName), SERVICE_QUERY_STATUS);
    if hService <> 0 then
    begin
      if QueryServiceStatus(hService, Status) then
      begin
        Result := (Status.dwCurrentState = SERVICE_RUNNING)
      end;
      CloseServiceHandle(hService)
    end;
    CloseServiceHandle(hSCM)
  end
end;

initialization
finalization
end.
