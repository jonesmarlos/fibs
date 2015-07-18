unit DBEditBtn;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Mask, DBCtrls,Buttons,ExtCtrls;

type
  TDBEditBtn = class(TDBEdit)
  private
    FButton: TSpeedButton;
    FEditorEnabled: Boolean;
    FOnBtnClick : TNotifyEvent;

    procedure SetGlyph(Pic: TBitmap);
    function GetGlyph : TBitmap;

    procedure SetNumGlyphs(ANumber: Integer);
    function GetNumGlyphs:Integer;




    function GetMinHeight: Integer;
    procedure SetEditRect;
    procedure WMSize(var Message: TWMSize); message WM_SIZE;
    procedure CMEnter(var Message: TCMGotFocus); message CM_ENTER;
    procedure CMExit(var Message: TCMExit);   message CM_EXIT;
    procedure WMPaste(var Message: TWMPaste);   message WM_PASTE;
    procedure WMCut(var Message: TWMCut);   message WM_CUT;
  protected
    procedure GetChildren(Proc: TGetChildProc; Root: TComponent); override;
    function IsValidChar(Key: Char): Boolean; virtual;
    procedure aClick (Sender: TObject); virtual;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyPress(var Key: Char); override;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure CreateWnd; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property Button: TSpeedButton read FButton;
  published
    property AutoSelect;
    property AutoSize;
    property Color;
    property Ctl3D;
    property DragCursor;
    property DragMode;
    property EditorEnabled: Boolean read FEditorEnabled write FEditorEnabled default True;
    property Enabled;
    property Font;
    property Glyph : TBitmap read GetGlyph write SetGlyph;
    property NumGlyphs : Integer read GetNumGlyphs write SetNumGlyphs;
    property MaxLength;
    property ParentColor;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ReadOnly;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Visible;
    property OnChange;
    property OnClick;
    property OnBtnClick : TNotifyEvent read FOnBtnClick write FOnBtnClick;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnStartDrag;
  end;

procedure Register;

implementation

{ TDBEditBtn }

constructor TDBEditBtn.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FButton := TSpeedButton.Create (Self);
  FButton.Width := 15;
  FButton.Height := 17;
  IF  csDesigning in ComponentState then
   FButton.Visible := True
  Else FButton.Visible := False;
  FButton.Parent := Self;
  FButton.OnClick := aClick;
  FButton.Cursor:=crArrow;
  ControlStyle := ControlStyle - [csSetCaption];
  FEditorEnabled := True;
end;

destructor TDBEditBtn.Destroy;
begin
  FButton := nil;
  inherited Destroy;
end;

procedure TDBEditBtn.GetChildren(Proc: TGetChildProc; Root: TComponent);
begin
end;

procedure TDBEditBtn.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited KeyDown(Key, Shift);
end;

procedure TDBEditBtn.SetGlyph(Pic: TBitmap);
Begin
  FButton.Glyph.Assign(Pic);
end;

function TDBEditBtn.GetGlyph : TBitmap;
Begin
 Result:=FButton.Glyph;
end;

procedure TDBEditBtn.SetNumGlyphs(ANumber: Integer);
Begin
 FButton.NumGlyphs:=ANumber;
end;

function TDBEditBtn.GetNumGlyphs:Integer;
begin
 Result:=FButton.NumGlyphs;
end;

procedure TDBEditBtn.KeyPress(var Key: Char);
begin
  if not IsValidChar(Key) then
  begin
    Key := #0;
    MessageBeep(0)
  end;
  if Key <> #0 then inherited KeyPress(Key);
end;

function TDBEditBtn.IsValidChar(Key: Char): Boolean;
begin
    Result := True;
end;

procedure TDBEditBtn.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
{  Params.Style := Params.Style and not WS_BORDER;  }
  Params.Style := Params.Style or ES_MULTILINE or WS_CLIPCHILDREN;
end;

procedure TDBEditBtn.CreateWnd;
begin
  inherited CreateWnd;
  SetEditRect;
end;

procedure TDBEditBtn.SetEditRect;
var
  Loc: TRect;
begin
  SendMessage(Handle, EM_GETRECT, 0, LongInt(@Loc));
  Loc.Bottom := ClientHeight + 1;  {+1 is workaround for windows paint bug}
  Loc.Right := ClientWidth - FButton.Width - 2;
  Loc.Top := 0;
  Loc.Left := 0;
  SendMessage(Handle, EM_SETRECTNP, 0, LongInt(@Loc));
  SendMessage(Handle, EM_GETRECT, 0, LongInt(@Loc));  {debug}
end;

procedure TDBEditBtn.WMSize(var Message: TWMSize);
var
  MinHeight: Integer;
begin
  inherited;
  MinHeight := 5;
    { text edit bug: if size to less than minheight, then edit ctrl does
      not display the text }
  if Height < MinHeight then   
    Height := MinHeight
  else if FButton <> nil then
  begin
    FButton.Width:=Height;
    if NewStyleControls and Ctl3D then
      FButton.SetBounds(Width - FButton.Width - 5, 0, FButton.Width, Height - 5)
    else FButton.SetBounds (Width - FButton.Width, 1, FButton.Width, Height - 1);
    SetEditRect;
  end;
end;

function TDBEditBtn.GetMinHeight: Integer;
var
  DC: HDC;
  SaveFont: HFont;
  I: Integer;
  SysMetrics, Metrics: TTextMetric;
begin
  DC := GetDC(0);
  GetTextMetrics(DC, SysMetrics);
  SaveFont := SelectObject(DC, Font.Handle);
  GetTextMetrics(DC, Metrics);
  SelectObject(DC, SaveFont);
  ReleaseDC(0, DC);
  I := SysMetrics.tmHeight;
  if I > Metrics.tmHeight then I := Metrics.tmHeight;
  Result := Metrics.tmHeight + I div 4 + GetSystemMetrics(SM_CYBORDER) * 4 + 2;
end;

procedure TDBEditBtn.aClick (Sender: TObject);
begin
  if ReadOnly then MessageBeep(0)
  else IF Assigned(FOnBtnClick) then FOnBtnClick(Self);

end;


procedure TDBEditBtn.WMPaste(var Message: TWMPaste);
begin
  if not FEditorEnabled or ReadOnly then Exit;
  inherited;
end;

procedure TDBEditBtn.WMCut(var Message: TWMPaste);   
begin
  if not FEditorEnabled or ReadOnly then Exit;
  inherited;
end;

procedure TDBEditBtn.CMExit(var Message: TCMExit);
begin
  FButton.Visible:=False;
  inherited;

end;


procedure TDBEditBtn.CMEnter(var Message: TCMGotFocus);
begin
  FButton.Visible:=True;
  if AutoSelect and not (csLButtonDown in ControlState) then
    SelectAll;

  inherited;
end;


procedure Register;
begin
  RegisterComponents('MBS', [TDBEditBtn]);
end;

end.
