
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

{ This unit is used to list backup times.}

unit PlanListForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Buttons, StdCtrls, ExtCtrls, JvExExtCtrls, JvBevel, FibsData;

type
  TfmPlanList = class(TForm)
    lsPlan: TListBox;
    btClose: TButton;
    bvFooter: TJvBevel;
  private
    { Private declarations }
  public
    { Public declarations }
    class procedure ShowPlan(AOwner: TComponent);
    class procedure ShowTaskPlan(AOwner: TComponent; TaskName: string; AlarmTimeList: TStringList); 
  end;

var
  fmPlanList: TfmPlanList;

implementation

uses
  UDFConst, UDFUtils, DateUtils, StrUtils;

{$R *.dfm}

{ TfmPlanList }

class procedure TfmPlanList.ShowPlan(AOwner: TComponent);
var
  fmPlanList: TfmPlanList;
  TStr, CStr: string;
  cc, i, KPos, NPos: Integer;
begin
  fmPlanList := TfmPlanList.Create(AOwner);
  try
    fmPlanList.lsPlan.Items.BeginUpdate;
    cc := 0;
    for i := 0 to UDFConst.TimeList.Count - 1 do
    begin
      KPos := Pos(' - ', UDFConst.TimeList[i]);
      NPos := Pos(' + ', UDFConst.TimeList[i]);
      TStr := UDFUtils.MyDateTimeToStr(StrToFloat(copy(UDFConst.TimeList[i], 1, KPos - 1)) + DateUtils.StartOfTheDay(Now));
      if TStr = UDFUtils.MyDateTimeToStr(CurrentAlarm + DateUtils.StartOfTheDay(Now)) then
        cc := i;
      CStr := StrUtils.RightStr(UDFConst.TimeList[i], Length(UDFConst.TimeList[i]) - NPos - 2);
      fmPlanList.lsPlan.Items.Add(' ' + IntToStr(i + 1) + '.   ' + TStr + ' - ' + CStr)
    end;
    fmPlanList.lsPlan.Items.EndUpdate;
    fmPlanList.Caption := 'Backup Executing Times in Today (' + DateToStr(Now) + ')';
    fmPlanList.lsPlan.TopIndex := cc - 1;
    fmPlanList.lsPlan.ItemIndex := cc;
    fmPlanList.ShowModal;
  finally
    fmPlanList.Release;
  end;
end;

class procedure TfmPlanList.ShowTaskPlan(AOwner: TComponent;
  TaskName: string; AlarmTimeList: TStringList);
var
  fmPlanList: TfmPlanList;
  s, TStr: string;
  cc, i, KPos, NPos: Integer;
begin
  fmPlanList := TfmPlanList.Create(AOwner);
  try
    fmPlanList.lsPlan.Clear;
    fmPlanList.lsPlan.Items.BeginUpdate;
    s := AlarmTimeList.Text;
    cc := 0;
    for i := 0 to AlarmTimeList.Count - 1 do
    begin
      KPos := Pos(' - ', AlarmTimeList[i]);
      NPos := Pos(' + ', AlarmTimeList[i]);
      TStr := TimeToStr(StrToFloat(copy(AlarmTimeList[i], 1, KPos - 1)));
      if TStr = MyDateTimeToStr(CurrentAlarm + StartOfTheDay(Now)) then
        cc := i;
      fmPlanList.lsPlan.items.Add(' ' + IntToStr(i + 1) + '.   ' + TStr); //+' - '+CStr)
    end;
    fmPlanList.lsPlan.items.EndUpdate;
    fmPlanList.Caption := 'Selected Backup Times of Task "' + TaskName + ' "';
    fmPlanList.lsPlan.TopIndex := cc - 1;
    fmPlanList.lsPlan.ItemIndex := cc;
    fmPlanList.ShowModal;
  finally
    fmPlanList.Release;
  end;
end;

end.
