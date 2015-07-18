
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


library fibssm;

{ Important note about DLL memory management: ShareMem must be the
  first unit in your library's USES clause AND your project's (select
  View-Project Source) USES clause if your DLL exports any procedures or
  functions that pass strings as parameters or function results. This
  applies to all strings passed to and from your DLL--even those that
  are nested in records and classes. ShareMem is the interface unit to
  the DELPHIMM.DLL shared memory manager, which must be deployed along
  with your DLL. To avoid using DELPHIMM.DLL, pass string information
  using PChar or ShortString parameters. }

uses
  ExceptionLog,
  Cpl,
  Windows,
  Forms,
  MainUnit in 'MainUnit.pas' {MainForm},
  MessageUnit in 'MessageUnit.pas' {MessageForm},
  ConstUnit in 'ConstUnit.pas',
  MiscServices in 'MiscServices.pas';

{$R *.RES}

procedure ExecuteApp;
 {$E .cpl}

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end;

{A callback function to export at Control Panel}
function CPlApplet(hwndCPl: THandle; uMsg: DWORD;
                 lParam1, lParam2: LongInt):LongInt;stdcall;
var
  NewCplInfo:PNewCplInfo;
begin
  Result:=0;
  case uMsg of
   {Initialization.Return True.}
   CPL_INIT:
    Result:=1;
   {Number of Applet.}
   CPL_GETCOUNT:
    Result:=1;
   {Transporting informations of this Applet to the Control Panel.}
   CPL_NEWINQUIRE:
    begin
     NewCplInfo:=PNewCplInfo(lParam2);
//     NewCplInfo.hIcon:=mainform.Icon.Handle;
     with NewCplInfo^ do
     begin
      dwSize:=SizeOf(TNewCplInfo);
      dwFlags:=0;
      dwHelpContext:=0;
      lData:=0;
      {An icon to display on Control Panel.}
      hIcon:=LoadIcon(HInstance,'MAINICON');
      {Applet name}
      //szName:='fibs';
      szName:='FIBS Service Manager';
      {Description of this Applet.}
      szInfo:='FIBS Service Manager';
      szHelpFile:='';
     end;
   end;
   {Executing this Applet.}
   CPL_DBLCLK:
    ExecuteApp;

   else Result:=0;
  end;
end;

{Exporting the function of CplApplet}
exports
  CPlApplet;

begin
end.
