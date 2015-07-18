 {****************************************************************************}
 {                                                                            }
 {                    TDLinkLabel Linked Label Component                      }
 {                                                                            }
 {                    Copyright (c) 2005-2006, Talat Dogan                    }
 {                                                                            }
 { This library is free software; you can redistribute it and/or modify it    }
 { under the terms of the GNU Lesser General Public License as published by   }
 { the Free Software Foundation; either version 2.1 of the License,           }
 { or (at your option) any later version.                                     }
 {                                                                            }
 { This library is distributed in the hope that it will be useful, but        }
 { WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY }
 { or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public     }
 { License for more details.                                                  }
 {                                                                            }
 { You should have received a copy of the GNU Lesser General Public License   }
 { along with this library; if not, write to the Free Software Foundation,    }
 { Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA                }
 {                                                                            }
 { Contact : dogantalat@yahoo.com
 {                                                                            }
 {****************************************************************************}





unit TDLinkLabel;

interface


uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, StdCtrls, ShellAPI, Forms;

type
  TTDLinkLabel = class(TCustomLabel)
  private
    { Private declarations }
    FOrgColor     : TColor;
    FLinkColor    : TColor;
    FLinkTo       : String;
    FOnMouseEnter : TNotifyEvent;
    FOnMouseLeave : TNotifyEvent;
    procedure SetLinkColor(Value:TColor);
  protected
    { Protected declarations }
    procedure WMClick(var Msg:TMessage); message WM_LBUTTONDOWN;
    procedure CMMouseEnter(var Msg: TMessage); message CM_MouseEnter;
    procedure CMMouseLeave(var Msg: TMessage); message CM_MouseLeave;
  public
    { Public declarations }
    constructor Create(AOwner:TComponent);override;
    destructor Destroy;override;
  published
    { Published declarations }
    property Caption;
    property Font;
    property Color;
    property LinkColor:TColor read FLinkColor write SetLinkColor default clBlue;
    property LinkTo: String read FLinkTo write FLinkTo;
    property Visible;
    property ShowHint;
    property AutoSize;
    property WordWrap;
    property Align;
    property Alignment;
    property Enabled;
    property Transparent;
  end;




procedure Register;

implementation

constructor TTDLinkLabel.Create(AOwner:TComponent);
begin
  inherited Create(AOwner);
  Font.Style:=[];
  FOrgColor:=Font.Color;
  FLinkColor:=clBlue;
  Cursor:=crHandPoint;
end;

destructor TTDLinkLabel.Destroy;
begin
  inherited Destroy;
end;

procedure TTDLinkLabel.SetLinkColor(Value:TColor);
begin
  FLinkColor:=Value;
end;

procedure TTDLinkLabel.WMClick(var Msg:TMessage);
begin
   ShellExecute(GetDesktopWindow,'open',PChar(FLinkTo),nil,nil,SW_SHOWNORMAL);
end;


procedure TTDLinkLabel.CMMouseEnter(var Msg: TMessage);
begin
  if not (csDesigning in ComponentState) then
  begin
    Font.Style:=[fsUnderline];
    Font.color:=FLinkColor;
  end;
  if Assigned(FOnMouseEnter) then OnMouseEnter(Self);
end;

procedure TTDLinkLabel.CMMouseLeave(var Msg: TMessage);
begin
  Font.Style:=[];
  Font.color:=FOrgColor;
  if Assigned(FOnMouseLeave) then OnMouseLeave(Self);
end;


procedure Register;
begin
  RegisterComponents('Talat', [TTDLinkLabel]);
end;

end.
