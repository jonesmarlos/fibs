object fmBackup: TfmBackup
  Left = 550
  Top = 162
  BorderIcons = []
  BorderStyle = bsDialog
  Caption = ' Backup and Mirror Now..'
  ClientHeight = 496
  ClientWidth = 464
  Color = clBtnFace
  DefaultMonitor = dmMainForm
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  PixelsPerInch = 96
  TextHeight = 13
  object lbBackupDir: TLabel
    Left = 8
    Top = 56
    Width = 97
    Height = 19
    AutoSize = False
    Caption = 'Backup Directory'
    Layout = tlCenter
  end
  object lbDatabaseName: TLabel
    Left = 8
    Top = 32
    Width = 97
    Height = 19
    AutoSize = False
    Caption = 'Database Path'
    Layout = tlCenter
  end
  object lbUserName: TLabel
    Left = 8
    Top = 176
    Width = 97
    Height = 19
    AutoSize = False
    Caption = 'User Name'
    Layout = tlCenter
  end
  object lbPassword: TLabel
    Left = 8
    Top = 200
    Width = 97
    Height = 19
    AutoSize = False
    Caption = 'Password :'
    Layout = tlCenter
  end
  object lbMirrorDir1: TLabel
    Left = 8
    Top = 80
    Width = 97
    Height = 19
    AutoSize = False
    Caption = 'Mirror Directory 1'
    Layout = tlCenter
  end
  object lbTaskName: TLabel
    Left = 8
    Top = 8
    Width = 97
    Height = 19
    AutoSize = False
    Caption = 'Task Name'
    Layout = tlCenter
  end
  object lbGbakDir: TLabel
    Left = 8
    Top = 152
    Width = 97
    Height = 19
    AutoSize = False
    Caption = 'GBak Directory'
    Layout = tlCenter
  end
  object lbGbakOptions: TLabel
    Left = 8
    Top = 312
    Width = 97
    Height = 19
    AutoSize = False
    Caption = 'GBAK Options'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    Layout = tlCenter
  end
  object lbCompressLevel: TLabel
    Left = 8
    Top = 264
    Width = 97
    Height = 19
    AutoSize = False
    Caption = 'Compression Level'
    Layout = tlCenter
  end
  object lbBackupPriority: TLabel
    Left = 8
    Top = 288
    Width = 97
    Height = 19
    AutoSize = False
    Caption = 'Backup Priority'
    Layout = tlCenter
  end
  object lbMirrorDir2: TLabel
    Left = 8
    Top = 104
    Width = 97
    Height = 19
    AutoSize = False
    Caption = 'Mirror Directory 2'
    Layout = tlCenter
  end
  object lbMirrorDir3: TLabel
    Left = 8
    Top = 128
    Width = 97
    Height = 19
    AutoSize = False
    Caption = 'Mirror Directory 3'
    Layout = tlCenter
  end
  object lbMailTo: TLabel
    Left = 8
    Top = 424
    Width = 97
    Height = 19
    AutoSize = False
    Caption = 'Notify EMail To :'
    Layout = tlCenter
  end
  object JvBevel1: TJvBevel
    Left = 8
    Top = 456
    Width = 448
    Height = 8
    Shape = bsTopLine
    Edges = [beTop]
    Inner = bvRaised
  end
  object edBackupDir: TEdit
    Left = 112
    Top = 56
    Width = 344
    Height = 19
    AutoSize = False
    Color = clWhite
    Ctl3D = False
    Enabled = False
    ParentCtl3D = False
    ReadOnly = True
    TabOrder = 2
  end
  object edDatabaseName: TEdit
    Left = 112
    Top = 32
    Width = 344
    Height = 19
    AutoSize = False
    Color = clWhite
    Ctl3D = False
    Enabled = False
    ParentCtl3D = False
    ReadOnly = True
    TabOrder = 1
  end
  object edUserName: TEdit
    Left = 112
    Top = 176
    Width = 128
    Height = 19
    AutoSize = False
    Color = clWhite
    Ctl3D = False
    Enabled = False
    ParentCtl3D = False
    ReadOnly = True
    TabOrder = 5
  end
  object edPassword: TEdit
    Left = 112
    Top = 200
    Width = 128
    Height = 19
    AutoSize = False
    Color = clWhite
    Ctl3D = False
    Enabled = False
    ParentCtl3D = False
    PasswordChar = '*'
    ReadOnly = True
    TabOrder = 6
  end
  object edMirrorDir1: TEdit
    Left = 112
    Top = 80
    Width = 344
    Height = 19
    AutoSize = False
    Color = clWhite
    Ctl3D = False
    Enabled = False
    ParentCtl3D = False
    ReadOnly = True
    TabOrder = 3
  end
  object edTaskName: TEdit
    Left = 112
    Top = 8
    Width = 177
    Height = 19
    AutoSize = False
    Color = clWhite
    Ctl3D = False
    Enabled = False
    ParentCtl3D = False
    ReadOnly = True
    TabOrder = 0
  end
  object edGbakDir: TEdit
    Left = 112
    Top = 152
    Width = 344
    Height = 19
    AutoSize = False
    Color = clWhite
    Ctl3D = False
    Enabled = False
    ParentCtl3D = False
    ReadOnly = True
    TabOrder = 4
  end
  object clbGbakOptions: TCheckListBox
    Left = 112
    Top = 312
    Width = 225
    Height = 109
    TabStop = False
    BevelInner = bvNone
    BevelOuter = bvNone
    BorderStyle = bsNone
    Color = clBtnFace
    Enabled = False
    ItemHeight = 13
    Items.Strings = (
      'Create Tranpostable Backup'
      'Convert External Tables to Internal Tables'
      'Do not Perform Garbage Collection'
      'Ignore Checksum Error'
      'Ignore Limbo Transactions'
      'Only Backup Metadata'
      'Create Uncompressed Backup'
      'Use Non-Tranpostable Format')
    TabOrder = 7
  end
  object edCompressLevel: TEdit
    Left = 112
    Top = 264
    Width = 128
    Height = 19
    AutoSize = False
    Color = clWhite
    Ctl3D = False
    Enabled = False
    ParentCtl3D = False
    ReadOnly = True
    TabOrder = 8
  end
  object edBackupPriority: TEdit
    Left = 112
    Top = 288
    Width = 128
    Height = 19
    AutoSize = False
    Color = clWhite
    Ctl3D = False
    Enabled = False
    ParentCtl3D = False
    ReadOnly = True
    TabOrder = 9
  end
  object edMirrorDir2: TEdit
    Left = 112
    Top = 104
    Width = 344
    Height = 19
    AutoSize = False
    Color = clWhite
    Ctl3D = False
    Enabled = False
    ParentCtl3D = False
    ReadOnly = True
    TabOrder = 10
  end
  object edMirrorDir3: TEdit
    Left = 112
    Top = 128
    Width = 344
    Height = 19
    AutoSize = False
    Color = clWhite
    Ctl3D = False
    Enabled = False
    ParentCtl3D = False
    ReadOnly = True
    TabOrder = 11
  end
  object edMailTo: TEdit
    Left = 112
    Top = 424
    Width = 344
    Height = 19
    AutoSize = False
    Color = clWhite
    Ctl3D = False
    Enabled = False
    ParentCtl3D = False
    ReadOnly = True
    TabOrder = 12
  end
  object cbValidateDatabase: TJvCheckBox
    Left = 112
    Top = 224
    Width = 108
    Height = 17
    Caption = 'Validate Database'
    Enabled = False
    TabOrder = 13
    LinkedControls = <>
    HotTrackFont.Charset = ANSI_CHARSET
    HotTrackFont.Color = clWindowText
    HotTrackFont.Height = -11
    HotTrackFont.Name = 'Tahoma'
    HotTrackFont.Style = []
    ReadOnly = True
  end
  object cbCreateZipBackup: TJvCheckBox
    Left = 112
    Top = 240
    Width = 110
    Height = 17
    Caption = 'Create ZIP Backup'
    Enabled = False
    TabOrder = 14
    LinkedControls = <>
    HotTrackFont.Charset = ANSI_CHARSET
    HotTrackFont.Color = clWindowText
    HotTrackFont.Height = -11
    HotTrackFont.Name = 'Tahoma'
    HotTrackFont.Style = []
    ReadOnly = True
  end
  object btBackupNow: TButton
    Left = 256
    Top = 464
    Width = 96
    Height = 25
    Caption = '&Backup Now'
    Default = True
    ModalResult = 1
    TabOrder = 15
  end
  object btCancel: TButton
    Left = 360
    Top = 464
    Width = 96
    Height = 25
    Cancel = True
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 16
  end
end
