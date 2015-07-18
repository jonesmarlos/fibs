
{****************************************************************************}
{                                                                            }
{               FIBS Firebird-Interbase Backup Scheduler                     }
{                                                                            }
{                 Copyright (c) 2005-2006, Talat Dogan                       }
{                                                                            }
{ This program is free software; you can redistribute it and/or modify it    }
{ under the terms of the GNU General Public License as published by the Free }
{ Software Foundation; either version 2 of the License, or (at your option)  }
{ any later version.                                                         }
{                                                                            }
{ This program is distributed in the hope that it will be useful, but        }
{ WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY }
{ or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for}
{ more details.                                                              }
{                                                                            }
{ You should have received a copy of the GNU General Public License along    }
{ with this program; if not, write to the Free Software Foundation, Inc.,    }
{ 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA                      }
{                                                                            }
{ Contact : dogantalat@yahoo.com
{                                                                            }
{****************************************************************************}

{ This unit holds program globals }

unit ConstUnit;

interface

uses Classes, SysUtils;

const
  PrgName: string = 'FIBS 2.0.4';
  PrgInfo: string = 'Firebird-Interbase Backup Scheduler';
  PrgCopyright: string = '(c) 2005-2014, Talat Dogan';
  PrgWebSite: string = 'www.talatdogan.com';

  ReleaseInfo = '2.0.4';
  ReleaseDate = '03.03.2014';
  PrgRelease: string = 'Release : ' + ReleaseInfo + ' - ' + ReleaseDate;

  // ****************  See end of the unit for revision notes ******************//
const
  TotalGBakOptions: Integer = 8;

  DatabaseSequenceBeginToken: Char = '[';
  DatabaseSequenceEndToken: Char = ']';

  ActiveTaskValidMirrorDirectory: Boolean = False;

var
  SyncLog: TMultiReadExclusiveWriteSynchronizer;

  RunningAsService: Boolean = false; // True, when FIBS is running as a Windows service
  DataFilesInvalid: Boolean = false; // True, if prefs.dat and tasks.dat are not corrupt or older version
  MainFormHidden: Boolean = false; // True, if MainForm is minimised to the tray.
  DataFilesPath: string; // Path to the Database files (prefs.dat and tasks.dat)

  AlarmTimeList: TStringList;
  TimeList: TStringList;
  CurrentTime: TDateTime;
  ThatDay: Integer;
  CurrentDay: Integer;
  CurrentAlarm: TDateTime;
  CurrentOwner: string;
  CurrentOwnerName: string;
  CurrentItem: Integer;
  ExecutedItem: Integer = -1; // Rev.2.0.1-1 ; this was "ExecutedItem : integer = 0;"
  NoItemToExecute: Boolean = false;
  LastItemExecuted: Boolean = false;
  // Alarms count in the hour, day and month.
  AlarmInHour, AlarmInDay, AlarmInMonth: Integer;
  // Backups to be preserved in the hour, day and month.
  PreservedInHour, PreservedInDay, PreservedInMonth: Integer;

implementation

// *********************  Rev.2.0.2  July 29, 2006 ***************************//
//  ATTENTION !!    THIS RELEASE MUST BE COMPILED WITH TDirectoryEditBtn Ver.1.1
// No code modification has been done.
// EditTaskUnit.dfm and PrefUnit.dfm  files has been updated for compiling with
// TDirectoryEditBtn ver.1.1.
// See revisions.txt for full revision info about Rev.2.0.2

// *********************  Rev.2.0.1  July 24, 2006 ***************************//
// Julien Ferraro has fixed the weird scheduling bug which is troubled some users.
// Fixed task deleting probled reported by tJey on Jul 15, 2006.
// Modified/Added/deleted lines signed as Rev.2.0.1
// See revisions.txt for full revision info about Rev.2.0.1
// ***************************************************************************//

end.

