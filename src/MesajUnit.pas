
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

unit MesajUnit;

interface

uses
  windows, messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ComCtrls;

type
  TMesajForm = class(TForm)
    SBox: TScrollBox;
    MesajLabel: TLabel;
    Panel1: TPanel;
    ButtonOK: TButton;
    PanelIcon: TPanel;
    PrgIcon: TImage;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure ButtonOKClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
  private
    { Private declarations }
    procedure ResizeForm;
  public
    { Public declarations }
    Mesaj: string;
  end;

function ShowProsesDlg(AMessage: string; AAlignment: Char; ACaption: string): TMesajForm;
procedure MesajDlg(AMessage: string; AAlignment: Char; ACaption: string);
procedure RefreshProsesDlg(ANewMessage: string; AAlignment: Char; AProsesDlg: TMesajForm);
procedure HideProsesDlg(AProsesDlg: TMesajForm);

var
  MesajForm: TMesajForm;
implementation

{$R *.DFM}
uses ConstUnit;

procedure MesajDlg(AMessage: string; AAlignment: Char; ACaption: string);
//  AMessage is message to show
//  AAlignment can be L, C or R
//  ACaption  is caption of the dialog
begin
  MesajForm := TMesajForm.Create(Application);
  MesajForm.caption := ACaption;
  MesajForm.Mesaj := AMessage;
  MesajForm.MesajLabel.caption := MesajForm.Mesaj;
  case AAlignment of
    'L', 'l': MesajForm.MesajLabel.Alignment := taLeftJustify;
    'R', 'r': MesajForm.MesajLabel.Alignment := taRightJustify;
    'C', 'c': MesajForm.MesajLabel.Alignment := taCenter;
  end;
  MesajForm.ShowModal;
end;

function ShowProsesDlg(AMessage: string; AAlignment: Char; ACaption: string): TMesajForm;
begin
  result := TMesajForm.Create(Application);
  result.caption := ACaption;
  result.MesajLabel.caption := AMessage;
  case AAlignment of
    'L', 'l': result.MesajLabel.Alignment := taLeftJustify;
    'R', 'r': result.MesajLabel.Alignment := taRightJustify;
    'C', 'c': result.MesajLabel.Alignment := taCenter;
  end;
  result.ButtonOK.Visible := false;
  result.Panel1.Visible := false;
  result.ResizeForm;
  if MainFormHidden then
    result.Hide
  else
    result.Show;
  Application.ProcessMessages;
end;

procedure RefreshProsesDlg(ANewMessage: string; AAlignment: Char; AProsesDlg: TMesajForm);
begin
  //  ANewMessage is message to show
  //  AAlignment can be L, C or R
  //  ACaption  is caption of the dialog
  AProsesDlg.MesajLabel.caption := ANewMessage;
  case AAlignment of
    'L', 'l': AProsesDlg.MesajLabel.Alignment := taLeftJustify;
    'R', 'r': AProsesDlg.MesajLabel.Alignment := taRightJustify;
    'C', 'c': AProsesDlg.MesajLabel.Alignment := taCenter;
  end;
  AProsesDlg.ResizeForm;
  Application.ProcessMessages;
end;

procedure HideProsesDlg(AProsesDlg: TMesajForm);
begin
  AProsesDlg.Free;
end;

procedure TMesajForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
  MesajForm := nil;
end;

procedure TMesajForm.FormShow(Sender: TObject);
begin
  ResizeForm;
end;

procedure TMesajForm.ButtonOKClick(Sender: TObject);
begin
  Close;
end;

procedure TMesajForm.ResizeForm;
begin
  if MesajLabel.width < ButtonOK.width then
    MesajLabel.width := ButtonOK.width;
  if (self.width < MesajLabel.width + 50) then
    self.width := MesajLabel.width + 50;
  MesajLabel.Left := ((self.width - MesajLabel.width) div 2);
  if Panel1.Visible then
    self.height := MesajLabel.Top + MesajLabel.height + 50 + Panel1.height + PanelIcon.height
  else
    self.height := MesajLabel.Top + MesajLabel.height + PanelIcon.height + 50;
  if self.height > 500 then
    self.height := 500;
  if self.width > 700 then
    self.width := 700;
  PrgIcon.Left := (self.width div 2) - (PrgIcon.width div 2) - 2;
  ButtonOK.Left := (self.width div 2) - (ButtonOK.width div 2) - 2;
end;

procedure TMesajForm.FormCreate(Sender: TObject);
begin
  SBox.DoubleBuffered := true;
end;

procedure TMesajForm.FormResize(Sender: TObject);
begin
  self.Position := poMainFormCenter;
end;

end.

