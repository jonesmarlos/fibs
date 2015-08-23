unit UDFValidation;

interface

uses
  Classes, Forms;

type

  TValidationType = (vtUnknown, vtWarning, vtConfirmation);

  TValidation = class(TComponent)
  private
    slMessages: TStringList;
    sHeader: string;
    sFooter: string;
    sPrefix: string;
    bUseIncludeOrder: Boolean;
  public
    property Header: string read sHeader write sHeader;
    property Footer: string read sFooter write sFooter;

    constructor Create(AOwner: TComponent; Header: string = ''; Footer: string = '';
      Prefix: string = ''; UseIncludeOrder: Boolean = False); reintroduce;
    destructor Destroy; override;

    procedure Add(MessageText: string; ValidationType: TValidationType);
    procedure Clear;
    function ShowModal: Boolean;
  end;

implementation

uses
  Dialogs, Controls, SysUtils, StrUtils;

constructor TValidation.Create(AOwner: TComponent; Header: string; Footer: string;
  Prefix: string; UseIncludeOrder: Boolean);
begin
  inherited Create(AOwner);
  Self.slMessages := TStringList.Create;
  Self.sHeader := Header;
  Self.sFooter := Footer;
  Self.sPrefix := Prefix;
  Self.bUseIncludeOrder := UseIncludeOrder;
end;

procedure TValidation.Add(MessageText: string; ValidationType: TValidationType);
begin
  Self.slMessages.AddObject(MessageText, TObject(ValidationType));
end;

procedure TValidation.Clear;
begin
  Self.slMessages.Clear;
end;

function TValidation.ShowModal: Boolean;
var
  iIndex: Integer;
  slWarning: TStringList;
  slConfirmation: TStringList;
  sMessageText: string;
  bWarningMessage: Boolean;
begin
  Result := False;
  bWarningMessage := False;
  slWarning := TStringList.Create;
  slConfirmation := TStringList.Create;
  try
    for iIndex := 0 to Self.slMessages.Count - 1 do
    begin
      if TValidationType(Self.slMessages.Objects[iIndex]) = vtWarning then
        bWarningMessage := True;
      if not Self.bUseIncludeOrder then
        case TValidationType(Self.slMessages.Objects[iIndex]) of
          vtWarning: slWarning.Add(Self.slMessages.Strings[iIndex]);
          vtConfirmation: slConfirmation.Add(Self.slMessages.Strings[iIndex]);
        end;
    end;
    if Self.bUseIncludeOrder then
      sMessageText := Self.slMessages.Text
    else
      sMessageText := IfThen(slWarning.Count > 0, slWarning.Text, '') + IfThen(slConfirmation.Count > 0, slConfirmation.Text, '');
  finally
    slWarning.Free;
    slConfirmation.Free;
  end;
  if bWarningMessage then
  begin
    MessageDlg(sMessageText, mtWarning, [mbOk], 0);
    Result := False;
  end
  else
  begin
    Result := (MessageDlg(sMessageText, mtConfirmation, [mbYes, mbNo], 0) = mrYes);
  end;
end;

destructor TValidation.Destroy;
begin
  Self.slMessages.Free;
  inherited;
end;

end.
