
//*****************************************************************************
//
//  This is the revised version of EditBtn unit.
//  Revision 1.1   July 29, 2006
//  Revised by Talat Dogan,
//  Revised items signed as "TDogan"
//  EMail : dogantalat@yahoo.com
//
//*****************************************************************************

unit EditBtn;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Mask, Buttons,ExtCtrls,ShlObj ;

type
  TEditBtn = class(TEdit)
  private
    FButton: TSpeedButton;
    FEditorEnabled: Boolean;
    FAfterBtnClick : TNotifyEvent;
    FBeforeBtnClick : TNotifyEvent;
    FOnBtnClick : TNotifyEvent;
    procedure SetGlyph(Pic: TBitmap);
    function GetGlyph : TBitmap;

    procedure SetNumGlyphs(ANumber: Integer);
    function GetNumGlyphs:Integer;

    function GetMinHeight: Integer;
    procedure SetEditRect;
    procedure WMSize(var Message: TWMSize); message WM_SIZE;
    procedure CMEnter(var Message: TCMGotFocus); message CM_ENTER;
    procedure WMPaste(var Message: TWMPaste);   message WM_PASTE;
    procedure WMCut(var Message: TWMCut);   message WM_CUT;
  protected
    procedure GetChildren(Proc: TGetChildProc; Root: TComponent); override;
    function IsValidChar(Key: Char): Boolean; 
    procedure BtnClick (Sender: TObject); virtual;
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
    property AfterBtnClick : TNotifyEvent read FAfterBtnClick write FAfterBtnClick;
    property BeforeBtnClick : TNotifyEvent read FBeforeBtnClick write FBeforeBtnClick;
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



type
  TFileEditBtn = class(TEditBtn)
  private
    FFileName: String;
    FOnBtnClick : TNotifyEvent;
    FOpenDialog :TOpenDialog;
  protected
    procedure BtnClick (Sender: TObject); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
   property FileName: String read FFileName write FFileName stored True;
   property OpenDialog: TOpenDialog read FOpenDialog;
   property OnBtnClick : TNotifyEvent read FOnBtnClick write FOnBtnClick;
  end;

type
	TRootFolders=(roRecycleBin,roControlPanel,roDesktop,roDesktopDir,roMyComputer,
                roFontsDir,roNethood,roNetwork,roPersonel,roPrinters,roProgramFiles,
                roRecent,roSendTo,roStartMenu,roStartUp,roTemplates);
const

	ROOT_FOLDERS_ARRAY: array[TRootFolders] of Integer=
		(CSIDL_BITBUCKET,CSIDL_CONTROLS,CSIDL_DESKTOP,CSIDL_DESKTOPDIRECTORY,
     CSIDL_DRIVES,CSIDL_FONTS,CSIDL_NETHOOD,CSIDL_NETWORK,CSIDL_PERSONAL,
     CSIDL_PRINTERS,CSIDL_PROGRAMS,CSIDL_RECENT,CSIDL_SENDTO,CSIDL_STARTMENU,
     CSIDL_STARTUP,CSIDL_TEMPLATES);


type
  TDirectoryEditBtn = class(TEditBtn)
  private
    FRootFolder: TRootFolders;
    FOnBtnClick : TNotifyEvent;
    function SelectDirectory(const Caption:string; const Root: TRootFolders; var Directory: string): Boolean;
  protected
    procedure BtnClick (Sender: TObject); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
		property RootFolder: TRootFolders read FRootFolder write FRootFolder default roMyComputer;
    property OnBtnClick : TNotifyEvent read FOnBtnClick write FOnBtnClick;
  end;




procedure Register;

implementation

uses FileCtrl, ActiveX;



{ TEditBtn }
constructor TEditBtn.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FButton := TSpeedButton.Create (Self);
  FButton.Width := 15;
  FButton.Height := 17;
  FButton.Parent := Self;
  FButton.OnClick := BtnClick;
  FButton.Cursor:=crArrow;
  ControlStyle := ControlStyle - [csSetCaption];
  FEditorEnabled := True;
end;

destructor TEditBtn.Destroy;
begin
  FButton := nil;
  inherited Destroy;
end;

procedure TEditBtn.GetChildren(Proc: TGetChildProc; Root: TComponent);
begin
end;

procedure TEditBtn.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited KeyDown(Key, Shift);
end;

procedure TEditBtn.SetGlyph(Pic: TBitmap);
Begin
  FButton.Glyph.Assign(Pic);
end;

function TEditBtn.GetGlyph : TBitmap;
Begin
 Result:=FButton.Glyph;
end;

procedure TEditBtn.SetNumGlyphs(ANumber: Integer);
Begin
 FButton.NumGlyphs:=ANumber;
end;

function TEditBtn.GetNumGlyphs:Integer;
begin
 Result:=FButton.NumGlyphs;
end;

procedure TEditBtn.KeyPress(var Key: Char);
begin
  if not IsValidChar(Key) then
  begin
    Key := #0;
    MessageBeep(0)
  end;
  if Key <> #0 then inherited KeyPress(Key);
end;

function TEditBtn.IsValidChar(Key: Char): Boolean;
begin
    Result := True;
end;

procedure TEditBtn.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
{  Params.Style := Params.Style and not WS_BORDER;  }
  Params.Style := Params.Style or ES_MULTILINE or WS_CLIPCHILDREN;
end;

procedure TEditBtn.CreateWnd;
begin
  inherited CreateWnd;
  SetEditRect;
end;

procedure TEditBtn.SetEditRect;
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

procedure TEditBtn.WMSize(var Message: TWMSize);
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
    if Ctl3D=false then
    begin
      FButton.Flat:=true;
      FButton.Transparent:=false;
    end;
    FButton.Width:=Height;
    if NewStyleControls and Ctl3D then
      FButton.SetBounds(Width - FButton.Width - 5, 0, FButton.Width, Height - 5)
    else FButton.SetBounds (Width - FButton.Width-6, 2, FButton.Width+4, Height - 4);
    SetEditRect;
  end;
end;

function TEditBtn.GetMinHeight: Integer;
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

procedure TEditBtn.BtnClick (Sender: TObject);
begin
    if Assigned(FBeforeBtnClick) then FBeforeBtnClick(Self);
    if Assigned(FOnBtnClick) then FOnBtnClick(Self);
    if Assigned(FAfterBtnClick) then FAfterBtnClick(Self);
end;


procedure TEditBtn.WMPaste(var Message: TWMPaste);
begin
  if not FEditorEnabled or ReadOnly then Exit;
  inherited;
end;

procedure TEditBtn.WMCut(var Message: TWMPaste);
begin
  if not FEditorEnabled or ReadOnly then Exit;
  inherited;
end;



procedure TEditBtn.CMEnter(var Message: TCMGotFocus);
begin
  if AutoSelect and not (csLButtonDown in ControlState) then
    SelectAll;
   inherited;
end;



constructor TFileEditBtn.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FButton.OnClick := BtnClick;
  FOpenDialog := TOpenDialog.Create (Self);
  FOpenDialog.Ctl3D:=false;
  FOpenDialog.Filter:='Firebird-Interbase Files (*.FDB) (*.GDB) (*.IB)|*.GDB;*.FDB;*.IB|Firebird Files (*.FDB)|*.FDB|Interbase Files  (*.IB)|*.IB|All files (*.*)|*.*';
  FOpenDialog.Options:=[ofHideReadOnly,ofPathMustExist,ofFileMustExist,ofNoTestFileCreate,ofEnableSizing];
  FOpenDialog.InitialDir:='Desktop';
  FOpenDialog.FileName:=Text;
end;

destructor TFileEditBtn.Destroy;
begin
  FOpenDialog := nil;
  inherited Destroy;
end;


procedure TFileEditBtn.BtnClick (Sender: TObject);
begin
  inherited BtnClick(sender);
    if Assigned(FOnBtnClick) then FOnBtnClick(Self)
    else
    begin
      if FileExists(Text) then OpenDialog.FileName:=Text; //1.6
      if OpenDialog.Execute then Text:=OpenDialog.FileName;
    end;
end;




constructor TDirectoryEditBtn.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
	FRootFolder:=roMyComputer;
  FButton.OnClick := BtnClick;
end;

destructor TDirectoryEditBtn.Destroy;
begin
  inherited Destroy;
end;
{
 SelectDirectory function (Type 1) opens Browse Dialog at the atribrary
 position on the desktop.
 To show it on the screen center I've used Zarko Gajic's way which is
 revised as below.   12.05.2006
}
//****************************************************************************//
//                   Original SelectDirCB function                            //
// Author :  Zarko Gajic                                                      //
// Source :  http://delphi.about.com/od/windowsshellapi/l/aa122803a.htm       //
//                                                                            //
//****************************************************************************//
//                                                                            //
//  function SelectDirCB(Wnd: HWND; uMsg: UINT; lParam, lpData: LPARAM): Integer stdcall;
//  begin
//    if (uMsg = BFFM_INITIALIZED) and (lpData <> 0) then
//    SendMessage(Wnd, BFFM_SETSELECTION, Integer(True), lpdata);
//    result := 0;
//  end;
//****************************************************************************//

//****************************************************************************//
//                   Revised SelectDirCB function                             //
//               Revised by Talat Dogan  on May 12,2006                       //
//                                                                            //
//****************************************************************************//
//                                                                            //
function SelectDirCB(Wnd: HWND; uMsg: UINT; lParam, lpData: LPARAM): Integer stdcall;
var
  WA, Rect : TRect; // TDogan
  DialogPT : TPoint;// TDogan
begin
  case uMsg of
    BFFM_INITIALIZED:
     if (lpData <> 0) then
      begin
        SendMessage(Wnd, BFFM_SETSELECTION, Integer(True), lpdata);
        GetWindowRect(Application.MainForm.Handle,WA);  // for MainFormCenter
//      WA := Screen.WorkAreaRect;                      // for  ScreenCenter
        GetWindowRect(Wnd, Rect);
        DialogPT.X := WA.Left+((WA.Right-WA.Left) div 2) - ((Rect.Right-rect.Left) div 2); // for MainFormCenter
        DialogPT.Y := WA.Top+((WA.Bottom-WA.Top) div 2) - ((Rect.Bottom-rect.Top) div 2);  // for MainFormCenter
//      DialogPT.X := ((WA.Right-WA.Left) div 2) - ((Rect.Right-rect.Left) div 2);         // for ScreenCenter
//      DialogPT.Y := ((WA.Bottom-WA.Top) div 2) - ((Rect.Bottom-rect.Top) div 2);         // for ScreenCenter
        MoveWindow(Wnd, DialogPT.X, DialogPT.Y, Rect.Right - Rect.Left, Rect.Bottom - Rect.Top, True);
      end;
  end;
  Result := 0;
end;
//****************************************************************************//

//****************************************************************************//
//                   Revised SelectDirectory function                         //
//               Revised by Talat Dogan  on May 12,2006                       //
//               Revision 1.1 July 29, 2006  by Talat Dogan
//****************************************************************************//
//                                                                            //
function TDirectoryEditBtn.SelectDirectory(const Caption:string; const Root: TRootFolders; var Directory: string): Boolean;
var
  WindowList: Pointer;
  BrowseInfo: TBrowseInfo;
  Buffer: PChar;
  OldErrorMode: Cardinal;
  ItemIDList: PItemIDList;
  ShellMalloc: IMalloc;
  IDesktopFolder: IShellFolder;
  Eaten, Flags: LongWord;
begin
  Result := False;
  if not DirectoryExists(Directory) then Directory := '';
  FillChar(BrowseInfo, SizeOf(BrowseInfo), 0);
  if (ShGetMalloc(ShellMalloc) = S_OK) and (ShellMalloc <> nil) then
  begin
    Buffer := ShellMalloc.Alloc(MAX_PATH);
    try
      with BrowseInfo do
      begin
        hwndOwner := Application.Handle;
  	  	SHGetSpecialFolderLocation(Application.Handle,ROOT_FOLDERS_ARRAY[FRootFolder],pidlRoot);
        pszDisplayName := Buffer;
        lpszTitle := PChar(Caption);
        ulFlags := BIF_RETURNONLYFSDIRS;
        lpfn := SelectDirCB;
        lParam := Integer(PChar(Directory));
      end;
      WindowList := DisableTaskWindows(0);
      OldErrorMode := SetErrorMode(SEM_FAILCRITICALERRORS);
      try
        ItemIDList := ShBrowseForFolder(BrowseInfo);
      finally
        SetErrorMode(OldErrorMode);
        EnableTaskWindows(WindowList);
      end;
      Result :=  ItemIDList <> nil;
      if Result then
      begin
        ShGetPathFromIDList(ItemIDList, Buffer);
        ShellMalloc.Free(ItemIDList);
        Directory := Buffer;
      end;
    finally
      ShellMalloc.Free(Buffer);
    end;
  end;
end;
//****************************************************************************//


procedure TDirectoryEditBtn.BtnClick (Sender: TObject);
var
  sDirectory: string;
begin
  inherited BtnClick(sender);
    if Assigned(FOnBtnClick) then FOnBtnClick(Self)
    else
    begin
      sDirectory:=Text;
      if SelectDirectory('', FRootFolder,sDirectory) then Text:= sDirectory;
    end;
end;




procedure Register;
begin
  RegisterComponents('MBS', [TEditBtn, TDirectoryEditBtn,TFileEditBtn]);
end;

end.
