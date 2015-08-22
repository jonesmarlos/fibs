object fmPref: TfmPref
  Left = 500
  Top = 239
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Preferences'
  ClientHeight = 344
  ClientWidth = 488
  Color = clBtnFace
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnCreate = FormCreate
  DesignSize = (
    488
    344)
  PixelsPerInch = 96
  TextHeight = 13
  object lbGbakDir: TLabel
    Left = 16
    Top = 32
    Width = 89
    Height = 19
    AutoSize = False
    Caption = 'GBak Directory'
    Color = clBtnFace
    ParentColor = False
    Layout = tlCenter
  end
  object lbLogDir: TLabel
    Left = 16
    Top = 56
    Width = 89
    Height = 19
    AutoSize = False
    Caption = 'LOG Directory'
    Color = clBtnFace
    ParentColor = False
    Layout = tlCenter
  end
  object lbBackupPriority: TLabel
    Left = 16
    Top = 104
    Width = 89
    Height = 19
    AutoSize = False
    Caption = 'Backup Priorty'
    Color = clBtnFace
    ParentColor = False
    Layout = tlCenter
  end
  object lbMailServer: TLabel
    Left = 16
    Top = 200
    Width = 89
    Height = 19
    AutoSize = False
    Caption = 'Mail Server'
    Layout = tlCenter
  end
  object lbSenderEmail: TLabel
    Left = 16
    Top = 224
    Width = 89
    Height = 19
    AutoSize = False
    Caption = 'Sender'#39's Email'
    Layout = tlCenter
  end
  object lbUserName: TLabel
    Left = 16
    Top = 248
    Width = 89
    Height = 19
    AutoSize = False
    Caption = 'User Name'
    Layout = tlCenter
  end
  object lbPassword: TLabel
    Left = 16
    Top = 272
    Width = 89
    Height = 19
    AutoSize = False
    Caption = 'Password'
    Layout = tlCenter
  end
  object Label6: TLabel
    Left = 148
    Top = 304
    Width = 3
    Height = 13
    Color = clBtnFace
    ParentColor = False
    Layout = tlCenter
  end
  object lbMailServerInfo: TLabel
    Left = 256
    Top = 200
    Width = 204
    Height = 19
    AutoSize = False
    Caption = '( Like  mail.xyz.com  or webmail.xyz.com ) '
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
  object lbSenderEmailInfo: TLabel
    Left = 256
    Top = 224
    Width = 88
    Height = 19
    AutoSize = False
    Caption = '( john@xyz.com ) '
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
  object lbUserNameInfo: TLabel
    Left = 256
    Top = 248
    Width = 50
    Height = 19
    AutoSize = False
    Caption = '( jbrown ) '
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
  object lbPasswordInfo: TLabel
    Left = 256
    Top = 272
    Width = 41
    Height = 19
    AutoSize = False
    Caption = '( **** ) '
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
  object lbArchiveDir: TLabel
    Left = 16
    Top = 80
    Width = 89
    Height = 19
    AutoSize = False
    Caption = 'Archive Directory'
    Color = clBtnFace
    ParentColor = False
    Layout = tlCenter
  end
  object ghGeneral: TJvGroupHeader
    Left = 8
    Top = 8
    Width = 472
    Height = 17
    Anchors = [akLeft, akTop, akRight]
    Caption = 'General options'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object ghSMTPServer: TJvGroupHeader
    Left = 8
    Top = 176
    Width = 472
    Height = 17
    Anchors = [akLeft, akTop, akRight]
    Caption = 'SMTP Server to be used for sending email notification'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object JvBevel1: TJvBevel
    Left = 8
    Top = 304
    Width = 472
    Height = 8
    Anchors = [akLeft, akRight, akBottom]
    Shape = bsTopLine
  end
  object cbAutoRun: TDBCheckBox
    Left = 16
    Top = 136
    Width = 405
    Height = 17
    Caption = 
      'Automatically launch FIBS  when Windows starts,  if it'#39's not ins' +
      'talled as a service. '
    Color = clBtnFace
    Ctl3D = True
    DataField = 'AUTORUN'
    DataSource = dmFibs.dsOption
    ParentColor = False
    ParentCtl3D = False
    TabOrder = 0
    ValueChecked = '1'
    ValueUnchecked = '0'
  end
  object cbBackupPriority: TDBComboBox
    Left = 112
    Top = 104
    Width = 96
    Height = 21
    Style = csDropDownList
    BevelKind = bkFlat
    Ctl3D = False
    DataField = 'BPRIORTY'
    DataSource = dmFibs.dsOption
    ItemHeight = 13
    Items.Strings = (
      'Idle'
      'Lowest'
      'Lower'
      'Normal'
      'Higher'
      'Highest')
    ParentCtl3D = False
    TabOrder = 1
  end
  object edSMTPServer: TEdit
    Left = 112
    Top = 224
    Width = 133
    Height = 19
    Ctl3D = False
    ParentCtl3D = False
    TabOrder = 2
  end
  object edMailAdress: TEdit
    Left = 112
    Top = 200
    Width = 133
    Height = 19
    Ctl3D = False
    ParentCtl3D = False
    TabOrder = 3
  end
  object edUserName: TEdit
    Left = 112
    Top = 248
    Width = 133
    Height = 19
    Ctl3D = False
    ParentCtl3D = False
    TabOrder = 4
  end
  object edPassword: TEdit
    Left = 112
    Top = 272
    Width = 133
    Height = 19
    Ctl3D = False
    ParentCtl3D = False
    PasswordChar = '*'
    TabOrder = 5
  end
  object cbFtpPassive: TDBCheckBox
    Left = 16
    Top = 152
    Width = 301
    Height = 17
    Caption = 'Use "Passive" mode FTP connection'
    Color = clBtnFace
    DataField = 'FTPCONNTYPE'
    DataSource = dmFibs.dsOption
    ParentColor = False
    TabOrder = 6
    ValueChecked = '1'
    ValueUnchecked = '0'
  end
  object edGbakDir: TJvDirectoryEdit
    Left = 112
    Top = 32
    Width = 360
    Height = 19
    DialogKind = dkWin32
    Flat = True
    ParentCtl3D = False
    ButtonFlat = True
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 7
    Text = 'edGbakDir'
  end
  object edLogDir: TJvDirectoryEdit
    Left = 112
    Top = 56
    Width = 360
    Height = 19
    DialogKind = dkWin32
    Flat = True
    ParentCtl3D = False
    ButtonFlat = True
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 8
    Text = 'edLogDir'
  end
  object edArchiveDir: TJvDirectoryEdit
    Left = 112
    Top = 80
    Width = 360
    Height = 19
    DialogKind = dkWin32
    Flat = True
    ParentCtl3D = False
    ButtonFlat = True
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 9
    Text = 'edArchiveDir'
  end
  object btCancel: TButton
    Left = 384
    Top = 312
    Width = 96
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 10
  end
  object btOK: TButton
    Left = 280
    Top = 312
    Width = 96
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = '&OK'
    Default = True
    ModalResult = 1
    TabOrder = 11
  end
  object arsAutoRun: TJvAppRegistryStorage
    StorageOptions.BooleanStringTrueValues = 'TRUE, YES, Y'
    StorageOptions.BooleanStringFalseValues = 'FALSE, NO, N'
    RegRoot = hkLocalMachine
    Root = 'Software\Microsoft\Windows\CurrentVersion\Run'
    SubStorages = <>
    Left = 424
    Top = 248
  end
  object arsFirebird: TJvAppRegistryStorage
    StorageOptions.BooleanStringTrueValues = 'TRUE, YES, Y'
    StorageOptions.BooleanStringFalseValues = 'FALSE, NO, N'
    RegRoot = hkLocalMachine
    Root = 'SOFTWARE\Firebird Project\Firebird Server\Instances'
    SubStorages = <>
    Left = 432
    Top = 120
  end
  object arsEmail: TJvAppRegistryStorage
    StorageOptions.BooleanStringTrueValues = 'TRUE, YES, Y'
    StorageOptions.BooleanStringFalseValues = 'FALSE, NO, N'
    Root = '%NONE%'
    SubStorages = <>
    Left = 360
    Top = 248
  end
end
