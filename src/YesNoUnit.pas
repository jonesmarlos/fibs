
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

unit YesNoUnit;

interface

uses
  windows, messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls;

type
  TYesNoForm = class(TForm)
    Panel1: TPanel;
    Button1: TButton;
    Button2: TButton;
    ScrollBox1: TScrollBox;
    MesajLabel: TLabel;
    Bevel1: TBevel;
    PrgIcon: TImage;
    procedure FormShow(Sender: TObject);
    procedure FormResize(Sender: TObject);
  private
    { Private declarations }
    procedure ResizeYesNoForm;
  public
    { Public declarations }
  end;
function YesNoDlgOld(AMessage: string; AAlignment: Char; ACaption: string): Integer;
var
  YesNoForm: TYesNoForm;

implementation

{$R *.DFM}
uses ConstUnit;

function YesNoDlgOld(AMessage: string; AAlignment: Char; ACaption: string): Integer;
//  AMessage is message to show
//  AAlignment can be L, C or R
//  ACaption  is caption of the dialog
begin
  YesNoForm := TYesNoForm.Create(Application);
  YesNoForm.caption := ACaption;
  YesNoForm.MesajLabel.caption := AMessage;
  case AAlignment of
    'L', 'l': YesNoForm.MesajLabel.Alignment := taLeftJustify;
    'R', 'r': YesNoForm.MesajLabel.Alignment := taRightJustify;
    'C', 'c': YesNoForm.MesajLabel.Alignment := taCenter;
  end;
  result := YesNoForm.ShowModal;
  YesNoForm.Free;
end;

procedure TYesNoForm.FormShow(Sender: TObject);
begin
  ResizeYesNoForm;
end;

procedure TYesNoForm.ResizeYesNoForm;
var
  orta, ara: Integer;
begin
  self.width := MesajLabel.width + 75;
  MesajLabel.Left := ((self.width - MesajLabel.width) div 2);
  self.height := MesajLabel.Top + MesajLabel.height + 50 + Panel1.height;
  if self.height > 500 then
    self.height := 500;
  if self.width > 700 then
    self.width := 500;
  PrgIcon.Left := (self.width div 2) - (PrgIcon.width div 2) - 2;
  orta := self.width div 2;
  ara := (orta - Button1.width) div 3;
  Button1.Left := orta - ara - Button1.width;
  Button2.Left := orta + ara;
end;

procedure TYesNoForm.FormResize(Sender: TObject);
begin
  self.Position := poMainFormCenter;
end;

end.

