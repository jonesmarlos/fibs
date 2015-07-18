
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

unit BackupServiceUnit;

interface

uses
  SysUtils, Classes, Windows, SvcMgr, WinSvc;

type
  TBackupService = class(TService)
  protected
    procedure Start(Sender: TService; var Started: Boolean);
    procedure Stop(Sender: TService; var Stopped: Boolean);
    procedure Execute(Sender: TService);
  private
  public
    function GetServiceController: TServiceController; override;
    constructor CreateNew(AOwner: TComponent; Dummy: Integer = 0); override;
    procedure CreateForm(InstanceClass: TComponentClass; var Reference);
    procedure Run;
    procedure SetTitle(ATitle: string);
  end;

function BackupStartService(DisplayName: string): Boolean;
function BackupIsService: Boolean;

function ServiceGetStatus(sMachine, sService: PChar): DWORD;
function ServiceRunning(sMachine, sService: PChar): Boolean;

var
  BackupService: TBackupService;
  ServiceExeName: string = '';

implementation

var
  FIsService: Boolean;
  FServiceName: string;
  FDisplayName: string;

  {TBackupService}

procedure ServiceController(CtrlCode: DWORD); stdcall;
begin
  BackupService.Controller(CtrlCode);
end;

function TBackupService.GetServiceController: TServiceController;
begin
  Result := ServiceController;
end;

procedure TBackupService.CreateForm(InstanceClass: TComponentClass; var Reference);
begin
  SvcMgr.Application.CreateForm(InstanceClass, Reference);
end;

procedure TBackupService.Run;
begin
  SvcMgr.Application.Run;
end;

procedure TBackupService.SetTitle(ATitle: string);
begin
  SvcMgr.Application.Title := ATitle;
end;

constructor TBackupService.CreateNew(AOwner: TComponent; Dummy: Integer);
begin
  inherited;
  AllowPause := False;
  Interactive := True;
  DisplayName := FDisplayName;
  Name := FServiceName;
  OnStart := Start;
  OnStop := Stop;
end;

procedure TBackupService.Start(Sender: TService; var Started: Boolean);
begin
  Started := True;
end;

procedure TBackupService.Execute(Sender: TService);
begin
  while not Terminated do
    ServiceThread.ProcessRequests(True);
end;

procedure TBackupService.Stop(Sender: TService; var Stopped: Boolean);
begin
  Stopped := True;
end;

{ Utilities}

function BackupIsService: Boolean;
begin
  Result := FIsService;
end;

function BackupStartService(DisplayName: string): Boolean;
var
  Mgr, Svc: Integer;
  UserName, ServiceStartName: string;
  Config: pointer;
  size: DWORD;
  n: Integer;
begin
  FDisplayName := DisplayName;
  FServiceName := DisplayName;

  for n := 1 to Length(FServiceName) do
    if FServiceName[n] = ' ' then
      FServiceName[n] := '_';
  FIsService := FindCmdLineSwitch('install', ['-', '\', '/'], True) or
    FindCmdLineSwitch('uninstall', ['-', '\', '/'], True);

  if FIsService then
  begin
    SvcMgr.Application.Initialize;
    BackupService := TBackupService.CreateNew(SvcMgr.Application, 0);
    Result := True;
    exit;
  end;

  Mgr := OpenSCManager(nil, nil, SC_MANAGER_ALL_ACCESS);
  if Mgr <> 0 then
  begin
    Svc := OpenService(Mgr, PChar(FServiceName), SERVICE_ALL_ACCESS);
    FIsService := Svc <> 0;
    if FIsService then
    begin
      QueryServiceConfig(Svc, nil, 0, size);
      Config := AllocMem(size);
      try
        QueryServiceConfig(Svc, Config, size, size);
        ServiceStartName := PQueryServiceConfig(Config)^.lpServiceStartName;
        ServiceExeName := PQueryServiceConfig(Config)^.lpBinaryPathName;
        if CompareText(ServiceStartName, 'LocalSystem') = 0 then
          ServiceStartName := 'SYSTEM';
      finally
        Dispose(Config);
      end;
      CloseServiceHandle(Svc);
    end;
    CloseServiceHandle(Mgr);
  end;

  if FIsService then
  begin
    size := 256;
    SetLength(UserName, size);
    GetUserName(PChar(UserName), size);
    SetLength(UserName, StrLen(PChar(UserName)));
    FIsService := CompareText(UserName, ServiceStartName) = 0;
  end;

  Result := FIsService;
  if FIsService then
  begin
    SvcMgr.Application.Initialize;
    BackupService := TBackupService.CreateNew(SvcMgr.Application, 0);
  end;
end;

function ServiceGetStatus(sMachine, sService: PChar): DWORD;
{******************************************}
{*** Parameters: ***}
{*** sService: specifies the name of the service to open
{*** sMachine: specifies the name of the target computer
{*** ***}
{*** Return Values: ***}
{*** -1 = Error opening service ***}
{*** 1 = SERVICE_STOPPED ***}
{*** 2 = SERVICE_START_PENDING ***}
{*** 3 = SERVICE_STOP_PENDING ***}
{*** 4 = SERVICE_RUNNING ***}
{*** 5 = SERVICE_CONTINUE_PENDING ***}
{*** 6 = SERVICE_PAUSE_PENDING ***}
{*** 7 = SERVICE_PAUSED ***}
{******************************************}
var
  SCManHandle, SvcHandle: SC_Handle;
  ss: TServiceStatus;
  dwStat: DWORD;
begin
  dwStat := 0;
  // Open service manager handle.
  SCManHandle := OpenSCManager(sMachine, nil, SC_MANAGER_CONNECT);
  if (SCManHandle > 0) then
  begin
    SvcHandle := OpenService(SCManHandle, sService, SERVICE_QUERY_STATUS);
    // if Service installed
    if (SvcHandle > 0) then
    begin
      // SS structure holds the service status (TServiceStatus);
      if (QueryServiceStatus(SvcHandle, ss)) then
        dwStat := ss.dwCurrentState;
      CloseServiceHandle(SvcHandle);
    end;
    CloseServiceHandle(SCManHandle);
  end;
  Result := dwStat;
end;
{
  Windows 2000 and earlier: All processes are granted the SC_MANAGER_CONNECT,
  SC_MANAGER_ENUMERATE_SERVICE, and SC_MANAGER_QUERY_LOCK_STATUS access rights.

  Windows XP: Only authenticated users are granted the SC_MANAGER_CONNECT,
  SC_MANAGER_ENUMERATE_SERVICE,
  and SC_MANAGER_QUERY_LOCK_STATUS access rights.

  Do not use the service display name (as displayed in the services
  control panel applet.) You must use the real service name, as
  referenced in the registry under
  HKEY_LOCAL_MACHINE\System\CurrentControlSet\Services
}

function ServiceRunning(sMachine, sService: PChar): Boolean;
begin
  Result := SERVICE_RUNNING = ServiceGetStatus(sMachine, sService);
end;

end.
