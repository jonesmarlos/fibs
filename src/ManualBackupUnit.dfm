object ManualBackupForm: TManualBackupForm
  Left = 439
  Top = 86
  BorderIcons = []
  BorderStyle = bsDialog
  Caption = ' Backup and Mirror Now..'
  ClientHeight = 497
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
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Bevel1: TBevel
    Left = 0
    Top = 0
    Width = 464
    Height = 453
    Align = alTop
  end
  object Label5: TLabel
    Left = 12
    Top = 60
    Width = 81
    Height = 13
    Caption = 'Backup Directory'
  end
  object Label6: TLabel
    Left = 12
    Top = 36
    Width = 71
    Height = 13
    Caption = 'Database Path'
  end
  object Label7: TLabel
    Left = 12
    Top = 176
    Width = 52
    Height = 13
    Caption = 'User Name'
  end
  object Label8: TLabel
    Left = 12
    Top = 196
    Width = 53
    Height = 13
    Caption = 'Password :'
  end
  object Label3: TLabel
    Left = 12
    Top = 80
    Width = 84
    Height = 13
    Caption = 'Mirror Directory 1'
  end
  object Label11: TLabel
    Left = 12
    Top = 16
    Width = 52
    Height = 13
    Caption = 'Task Name'
  end
  object Label1: TLabel
    Left = 12
    Top = 152
    Width = 71
    Height = 13
    Caption = 'GBak Directory'
  end
  object Label13: TLabel
    Left = 13
    Top = 308
    Width = 224
    Height = 13
    Caption = 'GBAK Options                                                    '
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object LabelCompDegree: TLabel
    Left = 12
    Top = 262
    Width = 89
    Height = 13
    Caption = 'Compression Level'
  end
  object Label2: TLabel
    Left = 12
    Top = 282
    Width = 71
    Height = 13
    Caption = 'Backup Priority'
  end
  object Label4: TLabel
    Left = 12
    Top = 104
    Width = 84
    Height = 13
    Caption = 'Mirror Directory 2'
  end
  object Label9: TLabel
    Left = 12
    Top = 128
    Width = 84
    Height = 13
    Caption = 'Mirror Directory 3'
  end
  object Label10: TLabel
    Left = 20
    Top = 426
    Width = 78
    Height = 13
    Caption = 'Notify EMail To :'
  end
  object EditDestinationDir: TEdit
    Left = 108
    Top = 56
    Width = 340
    Height = 19
    AutoSize = False
    Color = clWhite
    Ctl3D = False
    Enabled = False
    ParentCtl3D = False
    ReadOnly = True
    TabOrder = 3
  end
  object EditDatabaseName: TEdit
    Left = 108
    Top = 34
    Width = 340
    Height = 19
    AutoSize = False
    Color = clWhite
    Ctl3D = False
    Enabled = False
    ParentCtl3D = False
    ReadOnly = True
    TabOrder = 2
  end
  object EditUserName: TEdit
    Left = 108
    Top = 172
    Width = 121
    Height = 19
    AutoSize = False
    Color = clWhite
    Ctl3D = False
    Enabled = False
    ParentCtl3D = False
    ReadOnly = True
    TabOrder = 6
  end
  object EditPassword: TEdit
    Left = 108
    Top = 194
    Width = 121
    Height = 19
    AutoSize = False
    Color = clWhite
    Ctl3D = False
    Enabled = False
    ParentCtl3D = False
    PasswordChar = '*'
    ReadOnly = True
    TabOrder = 7
  end
  object EditMirrorDir: TEdit
    Left = 108
    Top = 78
    Width = 340
    Height = 19
    AutoSize = False
    Color = clWhite
    Ctl3D = False
    Enabled = False
    ParentCtl3D = False
    ReadOnly = True
    TabOrder = 4
  end
  object EditTaskName: TEdit
    Left = 108
    Top = 12
    Width = 177
    Height = 19
    AutoSize = False
    Color = clWhite
    Ctl3D = False
    Enabled = False
    ParentCtl3D = False
    ReadOnly = True
    TabOrder = 1
  end
  object BitBtn1: TBitBtn
    Left = 200
    Top = 462
    Width = 163
    Height = 25
    Caption = 'Backup And Mirror Now'
    TabOrder = 0
    TabStop = False
    OnClick = BitBtn1Click
    Kind = bkOK
  end
  object BitBtn2: TBitBtn
    Left = 376
    Top = 462
    Width = 75
    Height = 25
    TabOrder = 8
    TabStop = False
    Kind = bkCancel
  end
  object EditGBakDir: TEdit
    Left = 108
    Top = 148
    Width = 340
    Height = 19
    AutoSize = False
    Color = clWhite
    Ctl3D = False
    Enabled = False
    ParentCtl3D = False
    ReadOnly = True
    TabOrder = 5
  end
  object CLBGbakOptions: TCheckListBox
    Left = 108
    Top = 308
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
    TabOrder = 9
  end
  object DBCheckBox1: TDBCheckBox
    Left = 8
    Top = 238
    Width = 113
    Height = 17
    Alignment = taLeftJustify
    Caption = 'Create ZIP Backup'
    DataField = 'ZIPBACKUP'
    DataSource = DModule.AlarmDS
    ReadOnly = True
    TabOrder = 10
    ValueChecked = 'True'
    ValueUnchecked = 'False'
  end
  object EditCompDeg: TEdit
    Left = 108
    Top = 258
    Width = 74
    Height = 19
    AutoSize = False
    Color = clWhite
    Ctl3D = False
    Enabled = False
    ParentCtl3D = False
    ReadOnly = True
    TabOrder = 11
  end
  object EditPriority: TEdit
    Left = 108
    Top = 282
    Width = 74
    Height = 19
    AutoSize = False
    Color = clWhite
    Ctl3D = False
    Enabled = False
    ParentCtl3D = False
    ReadOnly = True
    TabOrder = 12
  end
  object EditMirror2Dir: TEdit
    Left = 108
    Top = 102
    Width = 340
    Height = 19
    AutoSize = False
    Color = clWhite
    Ctl3D = False
    Enabled = False
    ParentCtl3D = False
    ReadOnly = True
    TabOrder = 13
  end
  object EditMirror3Dir: TEdit
    Left = 108
    Top = 126
    Width = 340
    Height = 19
    AutoSize = False
    Color = clWhite
    Ctl3D = False
    Enabled = False
    ParentCtl3D = False
    ReadOnly = True
    TabOrder = 14
  end
  object DBCheckBox2: TDBCheckBox
    Left = 8
    Top = 216
    Width = 113
    Height = 17
    Alignment = taLeftJustify
    Caption = 'Validate Database'
    DataField = 'DOVAL'
    DataSource = DModule.AlarmDS
    ReadOnly = True
    TabOrder = 15
    ValueChecked = 'True'
    ValueUnchecked = 'False'
  end
  object EditMailTo: TEdit
    Left = 108
    Top = 424
    Width = 349
    Height = 19
    AutoSize = False
    Color = clWhite
    Ctl3D = False
    Enabled = False
    ParentCtl3D = False
    ReadOnly = True
    TabOrder = 16
  end
end
