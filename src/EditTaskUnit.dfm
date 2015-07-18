object EditTaskForm: TEditTaskForm
  Left = 520
  Top = 150
  BorderIcons = []
  BorderStyle = bsDialog
  Caption = 'Edit Task'
  ClientHeight = 421
  ClientWidth = 555
  Color = clBtnFace
  DefaultMonitor = dmMainForm
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  HelpFile = 'FIBS.HLP'
  OldCreateOrder = False
  Position = poMainFormCenter
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 348
    Top = 158
    Width = 165
    Height = 17
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
  object LabelState: TLabel
    Left = 348
    Top = 158
    Width = 165
    Height = 17
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
    Left = 12
    Top = 58
    Width = 50
    Height = 13
    Caption = 'Backup Dir'
  end
  object Label6: TLabel
    Left = 12
    Top = 36
    Width = 46
    Height = 13
    Caption = 'Database'
  end
  object Label7: TLabel
    Left = 12
    Top = 150
    Width = 52
    Height = 13
    Caption = 'User Name'
  end
  object Label8: TLabel
    Left = 12
    Top = 172
    Width = 46
    Height = 13
    Caption = 'Password'
  end
  object Label3: TLabel
    Left = 12
    Top = 80
    Width = 53
    Height = 13
    Caption = 'Mirror Dir 1'
  end
  object Label11: TLabel
    Left = 12
    Top = 14
    Width = 52
    Height = 13
    Caption = 'Task Name'
  end
  object LabelPriorty: TLabel
    Left = 172
    Top = 158
    Width = 165
    Height = 17
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
    Left = 12
    Top = 104
    Width = 53
    Height = 13
    Caption = 'Mirror Dir 2'
  end
  object Label16: TLabel
    Left = 12
    Top = 128
    Width = 53
    Height = 13
    Caption = 'Mirror Dir 3'
  end
  object ButtonOK: TBitBtn
    Left = 452
    Top = 44
    Width = 80
    Height = 28
    TabOrder = 0
    TabStop = False
    OnClick = ButtonOKClick
    Kind = bkOK
  end
  object BitBtn2: TBitBtn
    Left = 452
    Top = 80
    Width = 80
    Height = 28
    TabOrder = 7
    TabStop = False
    Kind = bkCancel
  end
  object EditDestinationDir: TDirectoryEditBtn
    Left = 72
    Top = 56
    Width = 350
    Height = 19
    Ctl3D = False
    ParentCtl3D = False
    TabOrder = 3
    Glyph.Data = {
      56030000424D5603000000000000B6000000280000000E0000000C0000000100
      200000000000A002000000000000000000001000000000000000000000000000
      8000008000000080800080000000800080008080000080808000C0C0C0000000
      FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00000000000000000000000000000000000000
      000000000000000000000000000000000000FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF000000000000000000808080008080800080808000808080008080
      8000808080008080800000000000FF00FF00FF00FF00FF00FF00FF00FF000000
      0000FFFFFF000000000080808000808080008080800080808000808080008080
      80008080800000000000FF00FF00FF00FF00FF00FF0000000000FFFFFF00FFFF
      FF00000000008080800080808000808080008080800080808000808080008080
      800000000000FF00FF00FF00FF0000000000FFFFFF00FFFFFF00FFFFFF000000
      000000000000000000000000000000000000000000000000000000000000FF00
      FF00FF00FF0000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0000000000FF00FF00FF00FF00FF00FF00FF00FF000000
      0000FFFFFF00FFFFFF00FFFFFF00000000000000000000000000000000000000
      000000000000FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00000000000000
      000000000000FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00}
    NumGlyphs = 1
    BeforeBtnClick = EditDestinationDirBeforeBtnClick
  end
  object EditDatabaseName: TFileEditBtn
    Left = 72
    Top = 34
    Width = 350
    Height = 19
    Ctl3D = False
    ParentCtl3D = False
    TabOrder = 2
    OnChange = EditDatabaseNameChange
    Glyph.Data = {
      D6000000424DD60000000000000076000000280000000E0000000C0000000100
      0400000000006000000000000000000000001000000000000000000000000000
      8000008000000080800080000000800080008080000080808000C0C0C0000000
      FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00DDDDDDDDDDDD
      DD00D000000000000D00D088888888880D00D088888888880D00D00000000000
      0D00D088888888880D00D088888888880D00D000000000000D00D08888888888
      0D00D088888888880D00D000000000000D00DDDDDDDDDDDDDD00}
    NumGlyphs = 1
    BeforeBtnClick = EditDatabaseNameBeforeBtnClick
  end
  object EditUserName: TDBEdit
    Left = 72
    Top = 148
    Width = 80
    Height = 19
    Ctl3D = False
    DataField = 'USER'
    DataSource = DModule.AlarmDS
    ParentCtl3D = False
    TabOrder = 5
  end
  object EditPassword: TDBEdit
    Left = 72
    Top = 170
    Width = 80
    Height = 19
    Ctl3D = False
    DataField = 'PASSWORD'
    DataSource = DModule.AlarmDS
    ParentCtl3D = False
    PasswordChar = '*'
    TabOrder = 6
  end
  object EditMirrorDir: TDirectoryEditBtn
    Left = 72
    Top = 78
    Width = 350
    Height = 19
    Ctl3D = False
    ParentCtl3D = False
    TabOrder = 4
    Glyph.Data = {
      56030000424D5603000000000000B6000000280000000E0000000C0000000100
      200000000000A002000000000000000000001000000000000000000000000000
      8000008000000080800080000000800080008080000080808000C0C0C0000000
      FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00000000000000000000000000000000000000
      000000000000000000000000000000000000FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF000000000000000000808080008080800080808000808080008080
      8000808080008080800000000000FF00FF00FF00FF00FF00FF00FF00FF000000
      0000FFFFFF000000000080808000808080008080800080808000808080008080
      80008080800000000000FF00FF00FF00FF00FF00FF0000000000FFFFFF00FFFF
      FF00000000008080800080808000808080008080800080808000808080008080
      800000000000FF00FF00FF00FF0000000000FFFFFF00FFFFFF00FFFFFF000000
      000000000000000000000000000000000000000000000000000000000000FF00
      FF00FF00FF0000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0000000000FF00FF00FF00FF00FF00FF00FF00FF000000
      0000FFFFFF00FFFFFF00FFFFFF00000000000000000000000000000000000000
      000000000000FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00000000000000
      000000000000FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00}
    NumGlyphs = 1
  end
  object EditTaskDef: TDBEdit
    Left = 72
    Top = 12
    Width = 189
    Height = 19
    Ctl3D = False
    DataField = 'TASKNAME'
    DataSource = DModule.AlarmDS
    ParentCtl3D = False
    TabOrder = 1
    OnKeyPress = EditTaskDefKeyPress
  end
  object PageControl1: TPageControl
    Left = 4
    Top = 200
    Width = 549
    Height = 221
    ActivePage = TabSheet1
    TabOrder = 8
    object TabSheet1: TTabSheet
      Caption = '             Backup Time             '
      object Bevel4: TBevel
        Left = 12
        Top = 12
        Width = 97
        Height = 170
      end
      object Label9: TLabel
        Left = 20
        Top = 6
        Width = 40
        Height = 13
        Caption = '  Hours  '
      end
      object Bevel5: TBevel
        Left = 124
        Top = 12
        Width = 225
        Height = 170
      end
      object Label12: TLabel
        Left = 132
        Top = 6
        Width = 55
        Height = 13
        Caption = '  Minutes    '
      end
      object CGHours: TCheckListBox
        Left = 20
        Top = 20
        Width = 85
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
      object CGMinutes: TCheckListBox
        Left = 132
        Top = 20
        Width = 213
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
        TabOrder = 1
      end
    end
    object TabSheet3: TTabSheet
      Caption = '          Backup Options         '
      object Bevel2: TBevel
        Left = 272
        Top = 104
        Width = 253
        Height = 69
        Shape = bsFrame
      end
      object Bevel7: TBevel
        Left = 272
        Top = 20
        Width = 253
        Height = 65
        Shape = bsFrame
      end
      object Bevel6: TBevel
        Left = 12
        Top = 20
        Width = 241
        Height = 125
        Shape = bsFrame
      end
      object Label13: TLabel
        Left = 28
        Top = 14
        Width = 75
        Height = 13
        Caption = ' GBAK Options  '
      end
      object Label14: TLabel
        Left = 284
        Top = 14
        Width = 150
        Height = 13
        Caption = '  Backup Compression Options  '
      end
      object Label2: TLabel
        Left = 288
        Top = 126
        Width = 66
        Height = 13
        Caption = 'Preserve Last'
      end
      object Label15: TLabel
        Left = 288
        Top = 100
        Width = 122
        Height = 13
        Caption = '  Backup Preserve Policy  '
      end
      object Label4: TLabel
        Left = 292
        Top = 56
        Width = 89
        Height = 13
        Caption = 'Compression Level'
      end
      object CLBGbakOptions: TCheckListBox
        Left = 28
        Top = 32
        Width = 221
        Height = 105
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
      object DBCheckBox1: TDBCheckBox
        Left = 288
        Top = 32
        Width = 125
        Height = 17
        Alignment = taLeftJustify
        Caption = 'Create GZip Backup'
        DataField = 'ZIPBACKUP'
        DataSource = DModule.AlarmDS
        TabOrder = 1
        ValueChecked = 'True'
        ValueUnchecked = 'False'
        OnClick = DBCheckBox1Click
      end
      object DBCUnit: TDBComboBox
        Left = 400
        Top = 122
        Width = 109
        Height = 21
        Style = csDropDownList
        BevelKind = bkFlat
        Ctl3D = False
        DataField = 'PUNIT'
        DataSource = DModule.AlarmDS
        ItemHeight = 13
        Items.Strings = (
          'Backups'
          'Hour'#39's Backup'
          'Day'#39's Backup'
          'Month'#39's Backup')
        ParentCtl3D = False
        TabOrder = 2
      end
      object DBEAdet: TDBEdit
        Left = 364
        Top = 122
        Width = 37
        Height = 21
        AutoSize = False
        Ctl3D = False
        DataField = 'PVAL'
        DataSource = DModule.AlarmDS
        MaxLength = 4
        ParentCtl3D = False
        TabOrder = 3
        OnKeyPress = DBEAdetKeyPress
      end
      object DBCheckBox2: TDBCheckBox
        Left = 284
        Top = 148
        Width = 197
        Height = 17
        Alignment = taLeftJustify
        Caption = 'Delete  All Out-of-Criteria Backups'
        DataField = 'DELETEALL'
        DataSource = DModule.AlarmDS
        TabOrder = 4
        ValueChecked = '1'
        ValueUnchecked = '0'
      end
      object DBComboBox1: TDBComboBox
        Left = 400
        Top = 52
        Width = 77
        Height = 21
        Style = csDropDownList
        BevelKind = bkFlat
        Ctl3D = False
        DataField = 'COMPRESS'
        DataSource = DModule.AlarmDS
        ItemHeight = 13
        Items.Strings = (
          'None'
          'Fastest'
          'Default'
          'Maximum')
        ParentCtl3D = False
        TabOrder = 5
      end
      object DBCheckBoxValidate: TDBCheckBox
        Left = 48
        Top = 156
        Width = 185
        Height = 17
        Alignment = taLeftJustify
        Caption = 'Validate Database Before Backup'
        DataField = 'DOVAL'
        DataSource = DModule.AlarmDS
        TabOrder = 6
        ValueChecked = 'True'
        ValueUnchecked = 'False'
        OnClick = DBCheckBox1Click
      end
    end
    object TabSheet2: TTabSheet
      Caption = '             Other Options              '
      ImageIndex = 2
      object Bevel1: TBevel
        Left = 12
        Top = 20
        Width = 305
        Height = 49
        Shape = bsFrame
      end
      object Label17: TLabel
        Left = 24
        Top = 14
        Width = 208
        Height = 13
        Caption = ' Send EMail Notification if any error occurs  '
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object Label19: TLabel
        Left = 24
        Top = 38
        Width = 33
        Height = 13
        Caption = 'Mail To'
      end
      object Bevel8: TBevel
        Left = 12
        Top = 88
        Width = 305
        Height = 93
        Shape = bsFrame
      end
      object Label20: TLabel
        Left = 24
        Top = 82
        Width = 266
        Height = 13
        Caption = ' External file to be runned after completing backup task'
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object EditMailTo: TDBEdit
        Left = 64
        Top = 36
        Width = 233
        Height = 19
        Hint = 'Use  ; column  as address delimiter'
        Ctl3D = False
        DataField = 'MAILTO'
        DataSource = DModule.AlarmDS
        ParentCtl3D = False
        ParentShowHint = False
        ShowHint = True
        TabOrder = 0
      end
      object FileEditBtnBatchFile: TFileEditBtn
        Left = 28
        Top = 108
        Width = 269
        Height = 19
        Ctl3D = False
        ParentCtl3D = False
        TabOrder = 1
        NumGlyphs = 1
      end
      object DBCheckBox3: TDBCheckBox
        Left = 28
        Top = 152
        Width = 105
        Height = 17
        Caption = 'Show Window'
        DataField = 'SHOWBATCHWIN'
        DataSource = DModule.AlarmDS
        TabOrder = 2
        ValueChecked = 'True'
        ValueUnchecked = 'False'
      end
      object DBCheckBox4: TDBCheckBox
        Left = 28
        Top = 132
        Width = 257
        Height = 17
        Caption = 'Use the last backup'#39's filename as parameter'
        DataField = 'USEPARAMS'
        DataSource = DModule.AlarmDS
        TabOrder = 3
        ValueChecked = 'True'
        ValueUnchecked = 'False'
      end
    end
  end
  object DBEdit1: TDBEdit
    Left = 460
    Top = 8
    Width = 57
    Height = 19
    Ctl3D = False
    DataField = 'TASKNO'
    DataSource = DModule.AlarmDS
    ParentCtl3D = False
    TabOrder = 9
    Visible = False
  end
  object EditMirror2Dir: TDirectoryEditBtn
    Left = 72
    Top = 100
    Width = 350
    Height = 19
    Ctl3D = False
    ParentCtl3D = False
    TabOrder = 10
    Glyph.Data = {
      56030000424D5603000000000000B6000000280000000E0000000C0000000100
      200000000000A002000000000000000000001000000000000000000000000000
      8000008000000080800080000000800080008080000080808000C0C0C0000000
      FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00000000000000000000000000000000000000
      000000000000000000000000000000000000FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF000000000000000000808080008080800080808000808080008080
      8000808080008080800000000000FF00FF00FF00FF00FF00FF00FF00FF000000
      0000FFFFFF000000000080808000808080008080800080808000808080008080
      80008080800000000000FF00FF00FF00FF00FF00FF0000000000FFFFFF00FFFF
      FF00000000008080800080808000808080008080800080808000808080008080
      800000000000FF00FF00FF00FF0000000000FFFFFF00FFFFFF00FFFFFF000000
      000000000000000000000000000000000000000000000000000000000000FF00
      FF00FF00FF0000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0000000000FF00FF00FF00FF00FF00FF00FF00FF000000
      0000FFFFFF00FFFFFF00FFFFFF00000000000000000000000000000000000000
      000000000000FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00000000000000
      000000000000FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00}
    NumGlyphs = 1
  end
  object DBCBConnection: TDBCheckBox
    Left = 316
    Top = 12
    Width = 109
    Height = 17
    Caption = 'Local Connection'
    DataField = 'LOCALCONN'
    DataSource = DModule.AlarmDS
    TabOrder = 11
    ValueChecked = 'True'
    ValueUnchecked = 'False'
    OnClick = DBCBConnectionClick
  end
  object EditMirror3Dir: TDirectoryEditBtn
    Left = 72
    Top = 122
    Width = 350
    Height = 19
    Ctl3D = False
    ParentCtl3D = False
    TabOrder = 12
    Glyph.Data = {
      56030000424D5603000000000000B6000000280000000E0000000C0000000100
      200000000000A002000000000000000000001000000000000000000000000000
      8000008000000080800080000000800080008080000080808000C0C0C0000000
      FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00000000000000000000000000000000000000
      000000000000000000000000000000000000FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF000000000000000000808080008080800080808000808080008080
      8000808080008080800000000000FF00FF00FF00FF00FF00FF00FF00FF000000
      0000FFFFFF000000000080808000808080008080800080808000808080008080
      80008080800000000000FF00FF00FF00FF00FF00FF0000000000FFFFFF00FFFF
      FF00000000008080800080808000808080008080800080808000808080008080
      800000000000FF00FF00FF00FF0000000000FFFFFF00FFFFFF00FFFFFF000000
      000000000000000000000000000000000000000000000000000000000000FF00
      FF00FF00FF0000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0000000000FF00FF00FF00FF00FF00FF00FF00FF000000
      0000FFFFFF00FFFFFF00FFFFFF00000000000000000000000000000000000000
      000000000000FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00000000000000
      000000000000FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00}
    NumGlyphs = 1
  end
end
