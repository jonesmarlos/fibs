object fmLog: TfmLog
  Left = 486
  Top = 204
  BorderIcons = [biSystemMenu, biMaximize]
  BorderStyle = bsDialog
  Caption = ' Backup Log Viewer'
  ClientHeight = 360
  ClientWidth = 600
  Color = clBtnFace
  DefaultMonitor = dmMainForm
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  DesignSize = (
    600
    360)
  PixelsPerInch = 96
  TextHeight = 13
  object lbLogPath: TLabel
    Left = 8
    Top = 328
    Width = 47
    Height = 13
    Anchors = [akLeft, akBottom]
    Caption = 'lbLogPath'
    Color = clBtnFace
    Font.Charset = ANSI_CHARSET
    Font.Color = clGray
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentColor = False
    ParentFont = False
    Layout = tlCenter
  end
  object grLogText: TStringGrid
    Left = 8
    Top = 8
    Width = 584
    Height = 312
    TabStop = False
    Anchors = [akLeft, akTop, akRight, akBottom]
    Color = 16252927
    ColCount = 1
    Ctl3D = False
    DefaultColWidth = 5000
    DefaultRowHeight = 16
    FixedCols = 0
    RowCount = 1
    FixedRows = 0
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    GridLineWidth = 0
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine]
    ParentCtl3D = False
    ParentFont = False
    TabOrder = 0
  end
  object btClose: TButton
    Left = 496
    Top = 328
    Width = 96
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = '&Close'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object btPrint: TButton
    Left = 392
    Top = 328
    Width = 96
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = '&Print'
    TabOrder = 2
    OnClick = btPrintClick
  end
  object dlgPrint: TPrintDialog
    Copies = 1
    MaxPage = 9999
    Options = [poPageNums, poSelection, poWarning, poDisablePrintToFile]
    Left = 116
    Top = 220
  end
end
