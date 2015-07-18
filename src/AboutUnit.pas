
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

unit AboutUnit;

interface

uses
  windows, messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ComCtrls, Buttons, jpeg, TDLinkLabel;

type
  TAboutForm = class(TForm)
    IconImage: TImage;
    LabelPrgName: TLabel;
    LabelPrgInfo: TLabel;
    LabelRelease: TLabel;
    LabelDesigned: TLabel;
    Label25: TLabel;
    LabelPrgWebSite: TTDLinkLabel;
    LabelCopyright: TLabel;
    BackJpeg: TImage;
    Bevel1: TBevel;
    LabelAuthor: TLabel;
    TDLinkLabel1: TTDLinkLabel;
    TDLinkLabel2: TTDLinkLabel;
    TDLinkLabel3: TTDLinkLabel;
    TDLinkLabel4: TTDLinkLabel;
    TDLinkLabel5: TTDLinkLabel;
    TDLinkLabel6: TTDLinkLabel;
    TDLinkLabel7: TTDLinkLabel;
    Label2: TLabel;
    Label3: TLabel;
    TDLinkLabel8: TTDLinkLabel;
    Label1: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure BackJpegClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  AboutForm: TAboutForm;

implementation

uses ConstUnit;

{$R *.DFM}

procedure TAboutForm.FormCreate(Sender: TObject);
begin
  LabelPrgName.caption := PrgName;
  LabelPrgInfo.caption := PrgInfo;
  LabelRelease.caption := PrgRelease;
  LabelCopyright.caption := PrgCopyright;
  LabelPrgWebSite.caption := PrgWebSite;
  LabelPrgWebSite.LinkTo := 'http://' + PrgWebSite;
end;

procedure TAboutForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = vk_escape then
    Close;
end;

procedure TAboutForm.BackJpegClick(Sender: TObject);
begin
  Close;
end;

end.

