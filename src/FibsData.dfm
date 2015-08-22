object dmFibs: TdmFibs
  OldCreateOrder = True
  OnCreate = DataModuleCreate
  OnDestroy = DataModuleDestroy
  Left = 438
  Top = 244
  Height = 275
  Width = 450
  object dsTask: TDataSource
    DataSet = qrTask
    Left = 20
    Top = 56
  end
  object dsOption: TDataSource
    DataSet = qrOption
    Left = 80
    Top = 56
  end
  object qrTask: TSdfDataSet
    FileMustExist = False
    ReadOnly = False
    FileName = '.\tasks.dat'
    Schema.Strings = (
      'TASKNO=10'
      'TASKNAME=30'
      'DBNAME=100'
      'BACKUPDIR=100'
      'MIRRORDIR=100'
      'MIRROR2DIR=100'
      'MIRROR3DIR=100'
      'USER=20'
      'PASSWORD=24'
      'ROLE=32'
      'PVAL=10'
      'PUNIT=16'
      'ZIPBACKUP=5'
      'BOPTIONS=32'
      'DELETEALL=1'
      'BOXES=115'
      'COMPRESS=10'
      'LOCALCONN=5'
      'BCOUNTER=6'
      'ACTIVE=1'
      'DOVAL=5'
      'MAILTO=250'
      'BATCHFILE=250'
      'SHOWBATCHWIN=5'
      'USEPARAMS=5')
    FieldDefs = <
      item
        Name = 'TASKNO'
        DataType = ftString
        Size = 10
      end
      item
        Name = 'TASKNAME'
        DataType = ftString
        Size = 30
      end
      item
        Name = 'DBNAME'
        DataType = ftString
        Size = 100
      end
      item
        Name = 'BACKUPDIR'
        DataType = ftString
        Size = 100
      end
      item
        Name = 'MIRRORDIR'
        DataType = ftString
        Size = 100
      end
      item
        Name = 'MIRROR2DIR'
        DataType = ftString
        Size = 100
      end
      item
        Name = 'MIRROR3DIR'
        DataType = ftString
        Size = 100
      end
      item
        Name = 'USER'
        DataType = ftString
        Size = 20
      end
      item
        Name = 'PASSWORD'
        DataType = ftString
        Size = 24
      end
      item
        Name = 'ROLE'
        DataType = ftString
        Size = 32
      end
      item
        Name = 'PVAL'
        DataType = ftString
        Size = 10
      end
      item
        Name = 'PUNIT'
        DataType = ftString
        Size = 16
      end
      item
        Name = 'ZIPBACKUP'
        DataType = ftString
        Size = 5
      end
      item
        Name = 'BOPTIONS'
        DataType = ftString
        Size = 32
      end
      item
        Name = 'DELETEALL'
        DataType = ftString
        Size = 1
      end
      item
        Name = 'BOXES'
        DataType = ftString
        Size = 84
      end
      item
        Name = 'COMPRESS'
        DataType = ftString
        Size = 10
      end
      item
        Name = 'LOCALCONN'
        DataType = ftString
        Size = 5
      end
      item
        Name = 'BCOUNTER'
        DataType = ftString
        Size = 6
      end
      item
        Name = 'ACTIVE'
        DataType = ftString
        Size = 1
      end
      item
        Name = 'DOVAL'
        DataType = ftString
        Size = 1
      end
      item
        Name = 'MAILTO'
        DataType = ftString
        Size = 250
      end
      item
        Name = 'BATCHFILE'
        DataType = ftString
        Size = 250
      end
      item
        Name = 'SHOWBATCHWIN'
        DataType = ftString
        Size = 5
      end
      item
        Name = 'USEPARAMS'
        DataType = ftString
        Size = 5
      end>
    AfterInsert = qrTaskAfterInsert
    AfterPost = qrTaskAfterPost
    Delimiter = ';'
    FirstLineAsSchema = False
    Left = 20
    Top = 8
    object qrTaskTASKNO: TStringField
      FieldName = 'TASKNO'
      Size = 10
    end
    object qrTaskTASKNAME: TStringField
      FieldName = 'TASKNAME'
      Size = 30
    end
    object qrTaskDBNAME: TStringField
      FieldName = 'DBNAME'
      Size = 100
    end
    object qrTaskBACKUPDIR: TStringField
      FieldName = 'BACKUPDIR'
      Size = 100
    end
    object qrTaskMIRRORDIR: TStringField
      FieldName = 'MIRRORDIR'
      Size = 100
    end
    object qrTaskMIRROR2DIR: TStringField
      FieldName = 'MIRROR2DIR'
      Size = 100
    end
    object qrTaskMIRROR3DIR: TStringField
      FieldName = 'MIRROR3DIR'
      Size = 100
    end
    object qrTaskUSER: TStringField
      FieldName = 'USER'
    end
    object qrTaskPASSWORD: TStringField
      FieldName = 'PASSWORD'
      OnGetText = qrTaskPASSWORDGetText
      OnSetText = qrTaskPASSWORDSetText
      Size = 24
    end
    object qrTaskROLE: TStringField
      FieldName = 'ROLE'
      Size = 32
    end
    object qrTaskPVAL: TStringField
      Alignment = taCenter
      FieldName = 'PVAL'
      Size = 10
    end
    object qrTaskPUNIT: TStringField
      FieldName = 'PUNIT'
      Size = 16
    end
    object qrTaskZIPBACKUP: TStringField
      FieldName = 'ZIPBACKUP'
      Size = 5
    end
    object qrTaskBOPTIONS: TStringField
      FieldName = 'BOPTIONS'
      Size = 32
    end
    object qrTaskDELETEALL: TStringField
      FieldName = 'DELETEALL'
      Size = 1
    end
    object qrTaskBOXES: TStringField
      FieldName = 'BOXES'
      Size = 84
    end
    object qrTaskCOMPRESS: TStringField
      FieldName = 'COMPRESS'
      Size = 10
    end
    object qrTaskLOCALCONN: TStringField
      FieldName = 'LOCALCONN'
      Size = 5
    end
    object qrTaskBCOUNTER: TStringField
      FieldName = 'BCOUNTER'
      Size = 6
    end
    object qrTaskACTIVE: TStringField
      FieldName = 'ACTIVE'
      Size = 1
    end
    object qrTaskDOVAL: TStringField
      FieldName = 'DOVAL'
      Size = 5
    end
    object qrTaskMAILTO: TStringField
      FieldName = 'MAILTO'
      Size = 250
    end
    object qrTaskBATCHFILE: TStringField
      FieldName = 'BATCHFILE'
      Size = 250
    end
    object qrTaskSHOWBATCHWIN: TStringField
      FieldName = 'SHOWBATCHWIN'
      Size = 5
    end
    object qrTaskUSEPARAMS: TStringField
      FieldName = 'USEPARAMS'
      Size = 5
    end
  end
  object qrOption: TSdfDataSet
    FileMustExist = False
    ReadOnly = False
    FileName = '.\prefs.dat'
    Schema.Strings = (
      'PATHTOGBAK=100'
      'TASKNO=10'
      'LOGDIR=100'
      'BPRIORTY=10'
      'AUTORUN=1'
      'SMTPSERVER=250'
      'SENDERSMAIL=250'
      'MAILUSERNAME=80'
      'MAILPASSWORD=80'
      'FTPCONNTYPE=1'
      'ARCHIVEDIR=100')
    FieldDefs = <
      item
        Name = 'PATHTOGBAK'
        DataType = ftString
        Size = 100
      end
      item
        Name = 'TASKNO'
        DataType = ftString
        Size = 10
      end
      item
        Name = 'LOGDIR'
        DataType = ftString
        Size = 100
      end
      item
        Name = 'BPRIORTY'
        DataType = ftString
        Size = 10
      end
      item
        Name = 'AUTORUN'
        DataType = ftString
        Size = 1
      end
      item
        Name = 'SMTPSERVER'
        DataType = ftString
        Size = 250
      end
      item
        Name = 'SENDERSMAIL'
        DataType = ftString
        Size = 250
      end
      item
        Name = 'MAILUSERNAME'
        DataType = ftString
        Size = 80
      end
      item
        Name = 'MAILPASSWORD'
        DataType = ftString
        Size = 80
      end
      item
        Name = 'FTPCONNTYPE'
        DataType = ftString
        Size = 1
      end
      item
        Name = 'ARCHIVEDIR'
        DataType = ftString
        Size = 100
      end>
    AfterPost = qrOptionAfterPost
    Delimiter = ';'
    FirstLineAsSchema = False
    Left = 80
    Top = 8
    object qrOptionPATHTOGBAK: TStringField
      FieldName = 'PATHTOGBAK'
      Size = 100
    end
    object qrOptionTASKNO: TStringField
      FieldName = 'TASKNO'
      Size = 10
    end
    object qrOptionLOGDIR: TStringField
      FieldName = 'LOGDIR'
      Size = 100
    end
    object qrOptionBPRIORTY: TStringField
      FieldName = 'BPRIORTY'
      Size = 10
    end
    object qrOptionAUTORUN: TStringField
      FieldName = 'AUTORUN'
      Size = 1
    end
    object qrOptionSMTPSERVER: TStringField
      FieldName = 'SMTPSERVER'
      Size = 250
    end
    object qrOptionSENDERSMAIL: TStringField
      FieldName = 'SENDERSMAIL'
      Size = 250
    end
    object qrOptionMAILUSERNAME: TStringField
      FieldName = 'MAILUSERNAME'
      Size = 80
    end
    object qrOptionMAILPASSWORD: TStringField
      FieldName = 'MAILPASSWORD'
      OnGetText = qrOptionMAILPASSWORDGetText
      OnSetText = qrOptionMAILPASSWORDSetText
      Size = 80
    end
    object qrOptionFTPCONNTYPE: TStringField
      FieldName = 'FTPCONNTYPE'
      Size = 5
    end
    object qrOptionARCHIVEDIR: TStringField
      FieldName = 'ARCHIVEDIR'
      Size = 100
    end
  end
end
