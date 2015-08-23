unit UDFTask;

interface

uses
  Classes, SysUtils;

type

  TMirrorType = (mtLocal, mtFtp);
  TDatabaseType = (dbFirebird);

  TDatabaseConnection = class
  private
    FType: TDatabaseType;
    FServer: string;
    FDBName: string;
    FUserName: string;
    FPassword: string;
  end;

  TTaskMirror = class
  private
    FType: TMirrorType;
    FValue: string;
  end;

  TArrayOfTaskMirror = array of TTaskMirror;

  TTaskTrigger = class
  private
    FHour: Integer;
    FMinute: Integer;
  end;

  TArrayOfTaskTrigger = array of TTaskTrigger;

  TTask = class
  private
    FId: Integer;
    FName: string;
    FConnection: TDatabaseConnection;
    FMirrors: TArrayOfTaskMirror;
    FTriggers: TArrayOfTaskTrigger;
  end;

implementation

end.
