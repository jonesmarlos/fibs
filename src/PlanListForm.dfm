object fmPlanList: TfmPlanList
  Left = 574
  Top = 218
  BorderIcons = [biMinimize, biMaximize]
  BorderStyle = bsDialog
  Caption = ' Monthly Backup Plan'
  ClientHeight = 360
  ClientWidth = 320
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
    320
    360)
  PixelsPerInch = 96
  TextHeight = 13
  object bvFooter: TJvBevel
    Left = 8
    Top = 320
    Width = 304
    Height = 8
    Anchors = [akLeft, akRight, akBottom]
    Shape = bsTopLine
  end
  object lsPlan: TListBox
    Left = 8
    Top = 8
    Width = 304
    Height = 304
    Anchors = [akLeft, akTop, akRight, akBottom]
    Color = 16252927
    Ctl3D = False
    ItemHeight = 13
    ParentCtl3D = False
    TabOrder = 0
  end
  object btClose: TButton
    Left = 216
    Top = 328
    Width = 96
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = '&Close'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
end
