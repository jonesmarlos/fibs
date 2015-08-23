
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
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ComCtrls, Buttons, jpeg, JvExControls,
  JvComponent, JvLinkLabel, JvExStdCtrls, JvHtControls, JvLabel;

type
  TAboutForm = class(TForm)
    IconImage: TImage;
    LabelPrgName: TLabel;
    LabelPrgInfo: TLabel;
    LabelRelease: TLabel;
    LabelDesigned: TLabel;
    Label25: TLabel;
    LabelCopyright: TLabel;
    BackJpeg: TImage;
    Bevel1: TBevel;
    LabelAuthor: TLabel;
    Label3: TLabel;
    JvLabel1: TJvLabel;
    JvLabel2: TJvLabel;
    JvLabel4: TJvLabel;
    JvLabel5: TJvLabel;
    JvLabel6: TJvLabel;
    JvLabel7: TJvLabel;
    JvLabel8: TJvLabel;
    JvLabel9: TJvLabel;
    JvLabel10: TJvLabel;
    JvLabel11: TJvLabel;
    JvLabel3: TJvLabel;
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

uses UDFConst;

{$R *.DFM}

procedure TAboutForm.FormCreate(Sender: TObject);
begin
  LabelPrgName.caption := PrgName;
  LabelPrgInfo.caption := PrgInfo;
  LabelRelease.caption := PrgRelease;
  LabelCopyright.caption := PrgCopyright;
  JvLabel2.caption := PrgWebSite;
  JvLabel2.url := 'http://' + PrgWebSite;
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
