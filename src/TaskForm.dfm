object fmTask: TfmTask
  Left = 454
  Top = 156
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Edit Task'
  ClientHeight = 496
  ClientWidth = 560
  Color = clBtnFace
  DefaultMonitor = dmMainForm
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  HelpFile = 'FIBS.HLP'
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 392
    Top = 176
    Width = 152
    Height = 19
    Alignment = taCenter
    AutoSize = False
    Caption = 'TASK DEACTIVE'
    Color = clRed
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentColor = False
    ParentFont = False
    Layout = tlCenter
  end
  object lbTaskActive: TLabel
    Left = 392
    Top = 176
    Width = 152
    Height = 19
    Alignment = taCenter
    AutoSize = False
    Caption = 'TASK ACTIVE'
    Color = clLime
    Font.Charset = ANSI_CHARSET
    Font.Color = clBlack
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentColor = False
    ParentFont = False
    Layout = tlCenter
  end
  object Label5: TLabel
    Left = 16
    Top = 80
    Width = 73
    Height = 19
    AutoSize = False
    Caption = 'Backup Dir'
    Layout = tlCenter
  end
  object Label6: TLabel
    Left = 16
    Top = 56
    Width = 73
    Height = 19
    AutoSize = False
    Caption = 'Database'
    Layout = tlCenter
  end
  object Label7: TLabel
    Left = 16
    Top = 176
    Width = 73
    Height = 19
    AutoSize = False
    Caption = 'User Name'
    Layout = tlCenter
  end
  object Label8: TLabel
    Left = 16
    Top = 200
    Width = 73
    Height = 19
    AutoSize = False
    Caption = 'Password'
    Layout = tlCenter
  end
  object Label3: TLabel
    Left = 16
    Top = 104
    Width = 73
    Height = 19
    AutoSize = False
    Caption = 'Mirror Dir 1'
    Layout = tlCenter
  end
  object Label11: TLabel
    Left = 16
    Top = 32
    Width = 73
    Height = 19
    AutoSize = False
    Caption = 'Task Name'
    Layout = tlCenter
  end
  object lbPriority: TLabel
    Left = 232
    Top = 176
    Width = 152
    Height = 19
    Alignment = taCenter
    AutoSize = False
    Caption = 'PRIORITY NORMAL'
    Color = clYellow
    Font.Charset = ANSI_CHARSET
    Font.Color = clBlack
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentColor = False
    ParentFont = False
    Layout = tlCenter
  end
  object Label10: TLabel
    Left = 16
    Top = 128
    Width = 73
    Height = 19
    AutoSize = False
    Caption = 'Mirror Dir 2'
    Layout = tlCenter
  end
  object Label16: TLabel
    Left = 16
    Top = 152
    Width = 73
    Height = 19
    AutoSize = False
    Caption = 'Mirror Dir 3'
    Layout = tlCenter
  end
  object ghHeader: TJvGroupHeader
    Left = 8
    Top = 8
    Width = 544
    Height = 17
    Caption = 'Edit Backup Task'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object pcOptions: TPageControl
    Left = 8
    Top = 232
    Width = 544
    Height = 224
    ActivePage = tsBackupTime
    TabOrder = 0
    object tsBackupTime: TTabSheet
      Caption = '             Backup Time             '
      object JvGroupBox1: TJvGroupBox
        Left = 8
        Top = 8
        Width = 112
        Height = 184
        Caption = '  Hours  '
        TabOrder = 0
        object clbTimeHours: TCheckListBox
          Left = 8
          Top = 16
          Width = 96
          Height = 160
          TabStop = False
          BorderStyle = bsNone
          Color = clBtnFace
          Columns = 2
          ItemHeight = 13
          Items.Strings = (
            '00'
            '01'
            '02'
            '03'
            '04'
            '05'
            '06'
            '07'
            '08'
            '09'
            '10'
            '11'
            '12'
            '13'
            '14'
            '15'
            '16'
            '17'
            '18'
            '19'
            '20'
            '21'
            '22'
            '23')
          TabOrder = 0
        end
      end
      object JvGroupBox2: TJvGroupBox
        Left = 128
        Top = 8
        Width = 256
        Height = 184
        Caption = '  Minutes    '
        TabOrder = 1
        object clbTimeMinutes: TCheckListBox
          Left = 8
          Top = 16
          Width = 240
          Height = 160
          TabStop = False
          BorderStyle = bsNone
          Color = clBtnFace
          Columns = 5
          ItemHeight = 13
          Items.Strings = (
            '00'
            '01'
            '02'
            '03'
            '04'
            '05'
            '06'
            '07'
            '08'
            '09'
            '10'
            '11'
            '12'
            '13'
            '14'
            '15'
            '16'
            '17'
            '18'
            '19'
            '20'
            '21'
            '22'
            '23'
            '24'
            '25'
            '26'
            '27'
            '28'
            '29'
            '30'
            '31'
            '32'
            '33'
            '34'
            '35'
            '36'
            '37'
            '38'
            '39'
            '40'
            '41'
            '42'
            '43'
            '44'
            '45'
            '46'
            '47'
            '48'
            '49'
            '50'
            '51'
            '52'
            '53'
            '54'
            '55'
            '56'
            '57'
            '58'
            '59')
          ParentShowHint = False
          ShowHint = True
          TabOrder = 0
        end
      end
    end
    object tsBackupOptions: TTabSheet
      Caption = '          Backup Options         '
      object JvGroupBox3: TJvGroupBox
        Left = 8
        Top = 8
        Width = 256
        Height = 128
        Caption = ' GBAK Options  '
        TabOrder = 0
        object clbBackupOptions: TCheckListBox
          Left = 8
          Top = 16
          Width = 240
          Height = 104
          TabStop = False
          BevelInner = bvNone
          BevelOuter = bvNone
          BorderStyle = bsNone
          Color = clBtnFace
          ItemHeight = 13
          Items.Strings = (
            'Create Tranpostable Backup'
            'Do not Perform Garbage Collection'
            'Convert External Tables to Internal Tables'
            'Ignore Checksum Error'
            'Ignore Limbo Transactions'
            'Only Backup Metadata'
            'Create Uncompressed Backup'
            'Use Non-Tranpostable Format')
          TabOrder = 0
        end
      end
      object JvGroupBox4: TJvGroupBox
        Left = 272
        Top = 8
        Width = 256
        Height = 72
        Caption = '  Backup Compression Options  '
        TabOrder = 1
        object Label4: TLabel
          Left = 8
          Top = 40
          Width = 89
          Height = 19
          AutoSize = False
          Caption = 'Compression Level'
          Layout = tlCenter
        end
        object cbCompressBackup: TJvCheckBox
          Left = 8
          Top = 16
          Width = 115
          Height = 17
          Caption = 'Create GZip Backup'
          TabOrder = 0
          OnClick = cbCompressBackupClick
          LinkedControls = <>
          HotTrackFont.Charset = ANSI_CHARSET
          HotTrackFont.Color = clWindowText
          HotTrackFont.Height = -11
          HotTrackFont.Name = 'Tahoma'
          HotTrackFont.Style = []
        end
        object cbCompressLevel: TJvComboBox
          Left = 104
          Top = 40
          Width = 136
          Height = 21
          BevelKind = bkFlat
          Style = csDropDownList
          ItemHeight = 13
          ItemIndex = 0
          TabOrder = 1
          Text = 'None'
          Items.Strings = (
            'None'
            'Fastest'
            'Default'
            'Maximum')
        end
      end
      object JvGroupBox5: TJvGroupBox
        Left = 272
        Top = 88
        Width = 256
        Height = 72
        Caption = '  Backup Preserve Policy  '
        TabOrder = 2
        object Label2: TLabel
          Left = 8
          Top = 16
          Width = 66
          Height = 13
          Caption = 'Preserve Last'
        end
        object cbPolicyType: TJvComboBox
          Left = 136
          Top = 16
          Width = 104
          Height = 21
          BevelKind = bkFlat
          Style = csDropDownList
          ItemHeight = 13
          ItemIndex = 0
          TabOrder = 0
          Text = 'Backups'
          Items.Strings = (
            'Backups'
            'Hour'#39's Backup'
            'Day'#39's Backup'
            'Month'#39's Backup')
        end
        object edPolicyValue: TJvEdit
          Left = 104
          Top = 16
          Width = 32
          Height = 21
          BevelInner = bvNone
          BevelKind = bkFlat
          BevelOuter = bvNone
          Flat = True
          ParentCtl3D = False
          Modified = False
          AutoSize = False
          TabOrder = 1
          Text = 'edPolicyValue'
          OnKeyPress = edPolicyValueKeyPress
        end
        object cbPolicyDeleteOfCBackup: TJvCheckBox
          Left = 8
          Top = 48
          Width = 185
          Height = 17
          Caption = 'Delete  All Out-of-Criteria Backups'
          TabOrder = 2
          LinkedControls = <>
          HotTrackFont.Charset = ANSI_CHARSET
          HotTrackFont.Color = clWindowText
          HotTrackFont.Height = -11
          HotTrackFont.Name = 'Tahoma'
          HotTrackFont.Style = []
        end
      end
      object cbValidadeDatabase: TJvCheckBox
        Left = 8
        Top = 144
        Width = 180
        Height = 17
        Caption = 'Validate Database Before Backup'
        TabOrder = 3
        LinkedControls = <>
        HotTrackFont.Charset = ANSI_CHARSET
        HotTrackFont.Color = clWindowText
        HotTrackFont.Height = -11
        HotTrackFont.Name = 'Tahoma'
        HotTrackFont.Style = []
      end
    end
    object tsOtherOptions: TTabSheet
      Caption = '             Other Options              '
      ImageIndex = 2
      object JvGroupBox6: TJvGroupBox
        Left = 8
        Top = 8
        Width = 520
        Height = 72
        Caption = ' Send EMail Notification if any error occurs  '
        TabOrder = 0
        object JvLabel1: TJvLabel
          Left = 8
          Top = 48
          Width = 44
          Height = 13
          Caption = 'JvLabel1'
          Visible = False
          HotTrackFont.Charset = ANSI_CHARSET
          HotTrackFont.Color = clWindowText
          HotTrackFont.Height = -11
          HotTrackFont.Name = 'Tahoma'
          HotTrackFont.Style = []
        end
        object edMailTo: TJvEdit
          Left = 8
          Top = 24
          Width = 504
          Height = 19
          Flat = True
          ParentCtl3D = False
          Modified = False
          TabOrder = 0
          Text = 'edMailTo'
        end
      end
      object JvGroupBox7: TJvGroupBox
        Left = 8
        Top = 88
        Width = 520
        Height = 88
        Caption = ' External file to be runned after completing backup task'
        TabOrder = 1
        object edExternalFile: TJvFilenameEdit
          Left = 8
          Top = 24
          Width = 504
          Height = 19
          Flat = True
          ParentCtl3D = False
          Filter = 
            'Batch Files (*.BAT)|*.BAT|Exe Files (*.EXE)|*.EXE|All files (*.*' +
            ')|*.*'
          ButtonFlat = True
          TabOrder = 0
          Text = 'edExternalFile'
        end
        object cbUseBackupNameParameter: TJvCheckBox
          Left = 8
          Top = 48
          Width = 232
          Height = 17
          Caption = 'Use the last backup'#39's filename as parameter'
          TabOrder = 1
          LinkedControls = <>
          HotTrackFont.Charset = ANSI_CHARSET
          HotTrackFont.Color = clWindowText
          HotTrackFont.Height = -11
          HotTrackFont.Name = 'Tahoma'
          HotTrackFont.Style = []
        end
        object cbExternalShowWindow: TJvCheckBox
          Left = 8
          Top = 64
          Width = 88
          Height = 17
          Caption = 'Show Window'
          TabOrder = 2
          LinkedControls = <>
          HotTrackFont.Charset = ANSI_CHARSET
          HotTrackFont.Color = clWindowText
          HotTrackFont.Height = -11
          HotTrackFont.Name = 'Tahoma'
          HotTrackFont.Style = []
        end
      end
    end
  end
  object btOk: TButton
    Left = 352
    Top = 464
    Width = 96
    Height = 25
    Caption = '&OK'
    Default = True
    ModalResult = 1
    TabOrder = 1
    OnClick = btOkClick
  end
  object btCancel: TButton
    Left = 456
    Top = 464
    Width = 96
    Height = 25
    Cancel = True
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 2
  end
  object edTaskName: TJvEdit
    Left = 96
    Top = 32
    Width = 240
    Height = 19
    Flat = True
    ParentCtl3D = False
    Modified = False
    TabOrder = 3
    Text = 'edTaskName'
    OnKeyPress = edTaskNameKeyPress
  end
  object edDatabaseName: TJvFilenameEdit
    Left = 96
    Top = 56
    Width = 448
    Height = 19
    Flat = True
    ParentCtl3D = False
    ButtonFlat = True
    TabOrder = 4
    Text = 'edDatabaseName'
    OnChange = edDatabaseNameChange
  end
  object edBackupDir: TJvDirectoryEdit
    Left = 96
    Top = 80
    Width = 448
    Height = 19
    DialogKind = dkWin32
    Flat = True
    ParentCtl3D = False
    ButtonFlat = True
    TabOrder = 5
    Text = 'edBackupDir'
  end
  object edMirrorDir1: TJvDirectoryEdit
    Left = 96
    Top = 104
    Width = 448
    Height = 19
    DialogKind = dkWin32
    Flat = True
    ParentCtl3D = False
    ButtonFlat = True
    TabOrder = 6
    Text = 'edMirrorDir1'
  end
  object edMirrorDir2: TJvDirectoryEdit
    Left = 96
    Top = 128
    Width = 448
    Height = 19
    DialogKind = dkWin32
    Flat = True
    ParentCtl3D = False
    ButtonFlat = True
    TabOrder = 7
    Text = 'edMirrorDir2'
  end
  object edMirrorDir3: TJvDirectoryEdit
    Left = 96
    Top = 152
    Width = 448
    Height = 19
    DialogKind = dkWin32
    Flat = True
    ParentCtl3D = False
    ButtonFlat = True
    TabOrder = 8
    Text = 'edMirrorDir3'
  end
  object cbLocalConnection: TJvCheckBox
    Left = 344
    Top = 32
    Width = 100
    Height = 17
    Caption = 'Local connection'
    TabOrder = 9
    OnClick = cbLocalConnectionClick
    LinkedControls = <>
    HotTrackFont.Charset = ANSI_CHARSET
    HotTrackFont.Color = clWindowText
    HotTrackFont.Height = -11
    HotTrackFont.Name = 'Tahoma'
    HotTrackFont.Style = []
  end
  object edUserName: TJvEdit
    Left = 96
    Top = 176
    Width = 128
    Height = 19
    Flat = True
    ParentCtl3D = False
    Modified = False
    TabOrder = 10
    Text = 'edUserName'
  end
  object edPassword: TJvEdit
    Left = 96
    Top = 200
    Width = 128
    Height = 19
    Flat = True
    ParentCtl3D = False
    Modified = False
    ThemedPassword = True
    TabOrder = 11
    Text = 'edPassword'
  end
end
