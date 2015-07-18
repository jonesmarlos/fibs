
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

unit MainUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Dialogs,Forms,
Buttons, StdCtrls, WinSvc,SvcMgr, ExtCtrls;

type
  TMainForm = class(TForm)
    SBStart: TSpeedButton;
    SBStop: TSpeedButton;
    SBRefresh: TSpeedButton;
    IconImage: TImage;
    StatLabel: TLabel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Bevel1: TBevel;
    Label5: TLabel;
    Label7: TLabel;
    RBManual: TRadioButton;
    RBAuto: TRadioButton;
    Bevel2: TBevel;
    Label4: TLabel;
    procedure SBRefreshClick(Sender: TObject);
    procedure SBStartClick(Sender: TObject);
    procedure SBStopClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Label7Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    ServiceStartType:dword;
    function ServiceGetStatus(sMachine, sService : string ) : integer;
    function ServiceStatusStr(AStatCode:dword): string;
    function ServiceStart(sMachine,sService : string ) : boolean;
    function ServiceStop(sMachine,sService : string ) : boolean;
  public
    { Public declarations }
    Stat:dword; 
  end;



var
  MainForm: TMainForm;

implementation

uses MessageUnit, ConstUnit, MiscServices,shellapi;


{$R *.DFM}

// get service statusreturn status code if successful -1 if not
//
// return codes:
//   SERVICE_STOPPED
//   SERVICE_RUNNING
//   SERVICE_PAUSED
//
// following return codes are used to indicate that the service is in the
// middle of getting to oneof the above states:
//
//   SERVICE_START_PENDING
//   SERVICE_STOP_PENDING
//   SERVICE_CONTINUE_PENDING
//   SERVICE_PAUSE_PENDING
//
// sMachine: machine name, ie: \SERVER   empty = local machine
// sService: service name, ie: Alerter
//
function TMainForm.ServiceGetStatus(sMachine, sService : string ) : integer;
var
  // service control manager handle
  schm,
  // service handle
  schs   : SC_Handle;
  // service status
  ss     : TServiceStatus;
  // current service status
  dwStat : integer;
begin
  dwStat := -1;
  // connect to the service control manager
  schm := OpenSCManager(PChar(sMachine),Nil,SC_MANAGER_CONNECT);
  // if successful...
  if(schm > 0)then
  begin
    // open a handle to the specified service
    schs := OpenService(schm,PChar(sService),
          // we want to query service status
            SERVICE_QUERY_STATUS);
    // if successful...
    if(schs > 0)then
    begin
      // retrieve the current status of the specified service
      if(QueryServiceStatus(schs,ss))then
      begin
        dwStat := ss.dwCurrentState;
      end;
      // close service handle
      CloseServiceHandle(schs);
    end;
    // close service control manager handle
    CloseServiceHandle(schm);
  end;
  Result := dwStat;
end;



//
// start service return TRUE if successful
// sMachine:   machine name, ie: \SERVER    empty = local machine
// sService:   service name, ie: Alerter
//
function TMainForm.ServiceStart(sMachine,sService : string ) : boolean;
var
  // service control manager handle
  schm,
  // service handle
  schs   : SC_Handle;
  // service status
  ss     : TServiceStatus;
  // temp char pointer
  psTemp : PChar;
  // check point
  dwChkP : DWord;
begin
  ss.dwCurrentState := 0;
  // connect to the service control manager
  schm := OpenSCManager(PChar(sMachine),Nil,SC_MANAGER_CONNECT);
  // if successful...
  if(schm > 0)then
  begin
    // open a handle to the specified service
     schs := OpenService(schm,PChar(sService),
     // we want to start the service and
      SERVICE_START or
      // query service status
      SERVICE_QUERY_STATUS);
    // if successful...
    if(schs > 0)then
    begin
      psTemp := Nil;
      if(StartService(schs,0,psTemp))then
      begin
        // check status
        if(QueryServiceStatus(schs,ss))then
        begin
          while(SERVICE_RUNNING <> ss.dwCurrentState)do
          begin
            // dwCheckPoint contains a value that the service increments periodically
            // to report its progress during a lengthy operation.
            // save current value
            dwChkP := ss.dwCheckPoint;
            // wait a bit before checking status again
            // dwWaitHint is the estimated amount of time the calling program
            // should wait before calling QueryServiceStatus() again
            // idle events should be handled here...
            Sleep(ss.dwWaitHint);
            if(not QueryServiceStatus(schs,ss))then
            begin
              // couldn't check status break from the loop
              break;
            end;
            if(ss.dwCheckPoint < dwChkP)then
            begin
              // QueryServiceStatus didn't increment dwCheckPoint as it should have.
              // avoid an infinite loop by breaking
              break;
            end;
          end;
        end;
      end;
      // close service handle
      CloseServiceHandle(schs);
    end;
    // close service control manager handle
    CloseServiceHandle(schm);
  end;
  // return TRUE if the service status is running
  Result :=SERVICE_RUNNING =ss.dwCurrentState;
end;


//
// stop service return TRUE if successful
// sMachine: machine name, ie: \SERVER empty = local machine
// sService  service name, ie: Alerter
//
function TMainForm.ServiceStop(sMachine,sService : string ) : boolean;
var
  // service controlmanager handle
  schm,
  // service handle
  schs   : SC_Handle;
  // service status
  ss     : TServiceStatus;
  // check point
  dwChkP : DWord;
begin
  // connect to the service control manager
  schm := OpenSCManager(PChar(sMachine),Nil,SC_MANAGER_CONNECT);
  // if successful...
  if(schm > 0)then
  begin
    // open a handle to the specified service
    schs := OpenService(schm,PChar(sService),
      // we want to stop the service and
      SERVICE_STOP or
      // query service status
      SERVICE_QUERY_STATUS);
    // if successful...
    if(schs > 0)then
    begin
      if(ControlService(schs,SERVICE_CONTROL_STOP,ss))then
      begin
        // check status
        if(QueryServiceStatus(schs,ss))then
        begin
          while(SERVICE_STOPPED <> ss.dwCurrentState)do
          begin
            // dwCheckPoint contains a value that the service increments periodically
            // to report its progress during a lengthy operation.
            // save current value
            dwChkP := ss.dwCheckPoint;
            // wait a bit before checking status again
            // dwWaitHint is theestimated amount of time  the calling program
            // should wait before calling QueryServiceStatus() again
            // idle events should be handled here...
            Sleep(ss.dwWaitHint);
            if(not QueryServiceStatus(schs,ss))then
            begin
              // couldn't check status break from the loop
              break;
            end;
            if(ss.dwCheckPoint < dwChkP)then
            begin
              // QueryServiceStatus didn't increment dwCheckPoint as it should have.
              // avoid an infinite loop by breaking
              break;
            end;
          end;
        end;
      end;
      // close service handle
      CloseServiceHandle(schs);
    end;
    // close service control manager handle
    CloseServiceHandle(schm);
  end;
  // return TRUE if the service status is stopped
  Result :=SERVICE_STOPPED =ss.dwCurrentState;
end;



function TMainForm.ServiceStatusStr(AStatCode:dword): string;
var
 s:string;
begin
  s:='Status Read ERROR !!';
 case AStatCode of
   SERVICE_STOPPED:s:='FIBS Backup Service is NOT running';
   SERVICE_START_PENDING:s:='FIBS Backup Service is starting';
   SERVICE_STOP_PENDING: s:='FIBS Backup Service is stopping';
   SERVICE_RUNNING: s:='FIBS Backup Service is running';
   SERVICE_CONTINUE_PENDING:s:='FIBS Backup Service continue is pending';
   SERVICE_PAUSE_PENDING:s:='FIBS Backup Service pause is pending';
   SERVICE_PAUSED:s:='FIBS Backup Service is paused';
 end;
 result:=s;
end;

{ Returns the status of the service. Maybe you want to check this
  more than once, so just call this function again.
  Results may be: SERVICE_STOPPED
                  SERVICE_START_PENDING
                  SERVICE_STOP_PENDING
                  SERVICE_RUNNING
                  SERVICE_CONTINUE_PENDING
                  SERVICE_PAUSE_PENDING
                  SERVICE_PAUSED   }


{
  Windows 2000 and earlier: All processes are granted the SC_MANAGER_CONNECT,
  SC_MANAGER_ENUMERATE_SERVICE, and SC_MANAGER_QUERY_LOCK_STATUS access rights.

  Windows XP: Only authenticated users are granted the SC_MANAGER_CONNECT,
  SC_MANAGER_ENUMERATE_SERVICE,
  and SC_MANAGER_QUERY_LOCK_STATUS access rights.
}

{
  Do not use the service display name (as displayed in the services
  control panel applet.) You must use the real service name, as
  referenced in the registry under
  HKEY_LOCAL_MACHINE\System\CurrentControlSet\Services
}




procedure TMainForm.SBRefreshClick(Sender: TObject);
var
  sst:dword;
begin
  if ZaherIsServiceInstalled('', 'FIBSBackupService')=false then
  begin
    StatLabel.Caption:='FIBSBackupService hasn''t been installed !';
    exit;
  end;
  ServiceStartType:=GetServiceStartType('FIBSBackupService');
  case ServiceStartType of
    2: RBAuto.Checked:=true;
    3: RBManual.Checked:=true;
  end;
  Stat:=ServiceGetStatus('', 'FIBSBackupService');
  StatLabel.Caption:=ServiceStatusStr(Stat);
end;


procedure TMainForm.SBStartClick(Sender: TObject);
var
  oks:Boolean;
  mess:TMessageForm;
begin
  if ZaherIsServiceInstalled('', 'FIBSBackupService')=false then
  begin
    StatLabel.Caption:='FIBSBackupService hasn''t been installed !';
    exit;
  end;

  Stat:=ServiceGetStatus('', 'FIBSBackupService');
  StatLabel.Caption:=ServiceStatusStr(Stat);

  if Stat in[SERVICE_START_PENDING,SERVICE_RUNNING] then
  begin
    MesajDlg('FIBS Service has already been started !!','c',PrgName);
    exit;
  end;
  oks:=false;
  Mess:=ShowProcessDlg('Please wait..'#13#10'FIBSBackupService starting type being changed to automatic mode..',PrgName);
  if RBAuto.Checked then
  begin
     if ChangeServiceStartType('FIBSBackupService',SERVICE_AUTO_START)=false then
     MesajDlg('Warning !'#13#10'FIBSBackupService start type couldn'' been changed to Automatic Starting  Mode !!'#13#10+
                   'That is, after restarting of Windows, FIBS will need to be started as a Service Manually..','c',PrgName);
  end else
  begin
     if ChangeServiceStartType('FIBSBackupService',SERVICE_DEMAND_START)=false then
     MesajDlg('Warning !'#13#10'FIBSBackupService start type couldn'' been changed to Manual Starting  Mode !!'#13#10+
             'That is, after restarting of Windows, FIBS will start Automatically..','c',PrgName);
  end;
  RefreshProcessDlg(Mess,'Please wait..'#13#10'FIBS Backup Service is Starting');

  try
    oks:=ServiceStart('','FIBSBackupService');
    RefreshProcessDlg(Mess,'Please wait..'#13#10'Service Status is refreshing');
    SBRefresh.Click;
  finally
    CloseProcessDlg(Mess);
    if oks=true then
    begin
       RBAuto.Enabled:=false;   // 1.0.5
       RBManual.Enabled:=false; // 1.0.5
    end else
    begin
       RBAuto.Enabled:=true;   // 1.0.5
       RBManual.Enabled:=true; // 1.0.5
       MesajDlg('WARNING !!!'#13#10+
                'FIBS is running as a desktop Application,'#13#10+
                'or FIBS Backup Service really cannot be started !!','c',PrgName);
    end;
  end;
end;

procedure TMainForm.SBStopClick(Sender: TObject);
var
  oks:Boolean;
  mess:TMessageForm;
begin
  if ZaherIsServiceInstalled('', 'FIBSBackupService')=false then
  begin
    StatLabel.Caption:='FIBSBackupService hasn''t been installed !';
    exit;
  end;
   SBRefresh.Click;
  if Stat in[SERVICE_STOP_PENDING,SERVICE_STOPPED] then
  begin
    MesajDlg('FIBS Service has already been stopped !!','c',PrgName);
    exit;
  end;
   oks:=false;
   Mess:=ShowProcessDlg('Please wait..'#13#10'FIBS Backup Service is Stopping',PrgName);
   try
     oks:=ServiceStop('','FIBSBackupService');
     RefreshProcessDlg(Mess,'Please wait..'#13#10'Service Status is refreshing');
     SBRefresh.Click;
   finally
     CloseProcessDlg(Mess);
     if oks=true then
     begin
       RBAuto.Enabled:=true;   // 1.0.5
       RBManual.Enabled:=true; // 1.0.5
     end else
     begin
       MesajDlg('ERROR !!!'#13#10+
                'FIBS Backup Service really cannot be stopped !!','c',PrgName);
       RBAuto.Enabled:=false;   // 1.0.5
       RBManual.Enabled:=false; // 1.0.5
     end;
   end;
end;

procedure TMainForm.FormShow(Sender: TObject);
begin
  SBRefresh.Click;
end;

procedure TMainForm.Label7Click(Sender: TObject);
begin
  MesajDlg('I would like to thanks to Thodin, ( Matthew Horrocks, '#13#10+
           'matthew@horrocksp.freeserve.co.uk ) for making it possible'#13#10+
           'for me to write FIBS Service Manager easily '#13#10+
           'by using his "cpl_form_applet"','c',PrgName);
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  Caption:='FIBSSM '+PrgInfo+' '+CoreCompileInfo;
  Label1.Caption:=PrgCompileInfo;
  SetWindowLong(self.Handle,
                   GWL_EXSTYLE,
                   GetWindowLong(self.Handle, GWL_EXSTYLE)
                   or WS_EX_TOOLWINDOW         // remove app from the Alt+Tab window
                   and not WS_EX_APPWINDOW);   // remove app from the taskbar

end;

end.
