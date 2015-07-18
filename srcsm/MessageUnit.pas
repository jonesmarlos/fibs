
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

unit MessageUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls;

type
  TMessageForm = class(TForm)
    MessageLabel: TLabel;
    Bevel1: TBevel;
    PrgIcon: TImage;
    Panel1: TPanel;
    ButtonOK: TButton;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    Mesaj:string;
  end;

 procedure MesajDlg(AMesaj:string;Ayar:char;Caption:string);
 function  ShowProcessDlg(AMessage:string;Caption:string): TMessageForm;
 procedure RefreshProcessDlg(AProcessDlg:TMessageForm;ANewMessage:string);
 procedure CloseProcessDlg(AProcessDlg:TMessageForm);

var
  MessageForm: TMessageForm;
implementation


{$R *.DFM}


 procedure MesajDlg(AMesaj:string;Ayar:char;Caption:string);
 begin
   MessageForm:=TMessageForm.Create(Application);
   MessageForm.Caption:=Caption;
   MessageForm.Mesaj:=AMesaj;
   MessageForm.MessageLabel.Caption:=MessageForm.Mesaj;
   MessageForm.MessageLabel.Alignment:=taCenter;
   MessageForm.Panel1.Visible:=true;
   MessageForm.ShowModal;
 end;



// Use this function to show a process dialog
 function ShowProcessDlg(AMessage:string;Caption:string):TMessageForm;
 begin
   result:=TMessageForm.Create(Application);
   result.Caption:=Caption;
   result.MessageLabel.Caption:=AMessage;
   result.Panel1.Visible:=false;
   result.Height:=140;
   result.Width:=240;
   result.PrgIcon.Left:=(240-40)div 2;
   result.Show;
   Application.ProcessMessages;
 end;

// Use this function to refresh process dialog's message
 procedure RefreshProcessDlg(AProcessDlg:TMessageForm;ANewMessage:string);
 begin
   AProcessDlg.MessageLabel.Caption:=ANewMessage;
   Application.ProcessMessages;
 end;

 procedure CloseProcessDlg(AProcessDlg:TMessageForm);
 begin
   AProcessDlg.Free;
 end;


procedure TMessageForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Action:=caFree;
  MessageForm:=nil;
end;






procedure TMessageForm.FormCreate(Sender: TObject);
begin
  self.DoubleBuffered:=true;
end;






end.
