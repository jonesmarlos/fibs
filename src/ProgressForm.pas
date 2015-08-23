
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

unit ProgressForm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ComCtrls, JvExControls, JvComponent, JvLabel,
  JvProgressBar, JvSpecialProgress;

type
  TfmProgress = class(TForm)
    paCenter: TPanel;
    lbMessage: TJvLabel;
    pbProgress: TJvSpecialProgress;
    paFooter: TPanel;
    btClose: TButton;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
  private
    iCloseDisabled: Integer;
    evCloseEvent: TNotifyEvent;
    pWindowList: Pointer;

    function GetProgress: Integer;
    procedure SetProgress(Value: Integer);

    function GetMessageText: string;
    procedure SetMessageText(Value: string);

    procedure SetCloseEvent(Value: TNotifyEvent);

    procedure ResizeForm;
    procedure RefreshProgress;
  public
    property Progress: Integer read GetProgress write SetProgress;
    property MessageText: string read GetMessageText write SetMessageText;
    property CloseEvent: TNotifyEvent read evCloseEvent write SetCloseEvent;
  
    constructor Create(AOwner: TComponent; AMessage: string; AProgress: Integer = -1; ACloseEvent: TNotifyEvent = nil); reintroduce;

    procedure ShowProgress(AMessage: string = ''; AProgress: Integer = -1);
    procedure CloseProgress(Forced: Boolean = False);
    procedure DisableClose;
    procedure EnableClose;

    class function CreateProgress(AMessage: string; AProgress: Integer = -1; ACloseEvent: TNotifyEvent = nil): TfmProgress;
  end;

procedure ShowProgress(AMessage: string; AProgress: Integer = -1; ACloseEvent: TNotifyEvent = nil);
procedure RefreshProgress;
procedure CloseProgress;
procedure DisableClose;
procedure EnableClose;

var
  fmProgress: TfmProgress;

implementation

{$R *.DFM}
uses UDFConst;

procedure ShowProgress(AMessage: string; AProgress: Integer; ACloseEvent: TNotifyEvent);
begin
  if (not Assigned(fmProgress)) or (not fmProgress.Visible) then
  begin
    fmProgress := nil;
    fmProgress := TfmProgress.CreateProgress(AMessage, AProgress, ACloseEvent);
  end
  else
  begin
    fmProgress.MessageText := AMessage;
    fmProgress.Progress := AProgress;
    fmProgress.CloseEvent := ACloseEvent;
  end;
  fmProgress.RefreshProgress;
end;

procedure RefreshProgress;
begin
  if Assigned(fmProgress) then
    fmProgress.RefreshProgress;
end;

procedure CloseProgress;
begin
  if Assigned(fmProgress) then
    fmProgress.CloseProgress(False);
end;

procedure DisableClose;
begin
  if Assigned(fmProgress) then
    fmProgress.DisableClose;
end;

procedure EnableClose;
begin
  if Assigned(fmProgress) then
    fmProgress.EnableClose;
end;

{ TfmProgress }

constructor TfmProgress.Create(AOwner: TComponent; AMessage: string; AProgress: Integer; ACloseEvent: TNotifyEvent);
begin
  inherited Create(AOwner);
  Self.lbMessage.Caption := AMessage;
  Self.pbProgress.Visible := AProgress > -1;
  if Self.pbProgress.Visible then
    Self.pbProgress.Position := AProgress;
  Self.paFooter.Visible := Assigned(ACloseEvent);
  if Self.paFooter.Visible then
    Self.evCloseEvent := ACloseEvent;
end;

procedure TfmProgress.RefreshProgress;
begin
  if not Self.Visible then
    Self.Visible := True;
  Self.Refresh;
  Application.ProcessMessages;
end;

procedure TfmProgress.ShowProgress(AMessage: string; AProgress: Integer);
begin
  Self.MessageText := AMessage;
  Self.Progress := AProgress;
  Self.RefreshProgress;
end;

procedure TfmProgress.CloseProgress(Forced: Boolean);
begin
  if Forced or (Self.iCloseDisabled = 0) then
    Self.Close;
end;

procedure TfmProgress.DisableClose;
begin
  Inc(Self.iCloseDisabled);
end;

procedure TfmProgress.EnableClose;
begin
  Dec(Self.iCloseDisabled);
end;

procedure TfmProgress.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  EnableTaskWindows(Self.pWindowList);
  Self.iCloseDisabled := 0;
  Action := caFree;
end;

class function TfmProgress.CreateProgress(AMessage: string; AProgress: Integer; ACloseEvent: TNotifyEvent): TfmProgress;
begin
  Result := TfmProgress.Create(Application.MainForm, AMessage, AProgress, ACloseEvent);
end;

function TfmProgress.GetMessageText: string;
begin
  Result := Self.lbMessage.Caption;
end;

function TfmProgress.GetProgress: Integer;
begin
  if Self.pbProgress.Visible then
    Result := Self.pbProgress.Position
  else
    Result := -1;
end;

procedure TfmProgress.SetCloseEvent(Value: TNotifyEvent);
begin
  Self.evCloseEvent := Value;
  Self.ResizeForm;
end;

procedure TfmProgress.SetMessageText(Value: string);
begin
  Self.lbMessage.Caption := Value;
end;

procedure TfmProgress.SetProgress(Value: Integer);
begin
  Self.pbProgress.Visible := Value > -1;
  if Self.pbProgress.Visible then
    Self.pbProgress.Position := Value;
  Self.ResizeForm;
end;

procedure TfmProgress.ResizeForm;
var
  iHeigh: Integer;
begin
  iHeigh := 48;
  if Self.paFooter.Visible then
    Inc(iHeigh, 32);
  if Self.pbProgress.Visible then
    Inc(iHeigh, 16);
  Self.ClientHeight := iHeigh;
end;

procedure TfmProgress.FormShow(Sender: TObject);
begin
  Self.pWindowList := DisableTaskWindows(0);
end;

initialization
  fmProgress := nil;

end.

