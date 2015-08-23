
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

unit LogUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Buttons, Grids, StdCtrls;

type
  TLogForm = class(TForm)
    SpeedButton1: TSpeedButton;
    StringGrid1: TStringGrid;
    LabelLogPath: TLabel;
    SBprint: TSpeedButton;
    PrintDialog1: TPrintDialog;
    procedure SpeedButton1Click(Sender: TObject);
    procedure SBprintClick(Sender: TObject);
  private
    { Private declarations }
    Tarih: string;
    procedure PrintHeader(aCanvas: TCanvas; aPageCount: Integer;
      aTextrect: TRect; var Continue: Boolean);
    procedure PrintFooter(aCanvas: TCanvas; aPageCount: Integer;
      aTextrect: TRect; var Continue: Boolean);
  public
    { Public declarations }
    LogFile: string;
  end;

var
  LogForm: TLogForm;

implementation

{$R *.dfm}

uses Printers, ProgressForm, UDFConst;

type
  THeaderFooterProc = procedure(aCanvas: TCanvas; aPageCount: Integer;
    aTextrect: TRect; var Continue: Boolean) of object;
  { Prototype for a callback method that PrintString will call
    when it is time to print a header or footer on a page. The
    parameters that will be passed to the callback are:
    aCanvas   : the canvas to output on
    aPageCount: page number of the current page, counting from 1
    aTextRect : output rectangle that should be used. This will be
                the area available between non-printable margin and
                top or bottom margin, in device units (dots). Output
                is not restricted to this area, though.
    continue  : will be passed in as True. If the callback sets it
                to false the print job will be aborted. }

{+------------------------------------------------------------
| Function PrintStrings
|
| Parameters :
|   lines:
|     contains the text to print, already formatted into
|     lines of suitable length. No additional wordwrapping
|     will be done by this routine and also no text clipping
|     on the right margin!
|   leftmargin, topmargin, rightmargin, bottommargin:
|     define the print area. Unit is inches, the margins are
|     measured from the edge of the paper, not the printable
|     area, and are positive values! The margin will be adjusted
|     if it lies outside the printable area.
|   linesPerInch:
|     used to calculate the line spacing independent of font
|     size.
|   aFont:
|     font to use for printout, must not be Nil.
|   measureonly:
|     If true the routine will only count pages and not produce any
|     output on the printer. Set this parameter to false to actually
|     print the text.
|   OnPrintheader:
|     can be Nil. Callback that will be called after a new page has
|     been started but before any text has been output on that page.
|     The callback should be used to print a header and/or a watermark
|     on the page.
|   OnPrintfooter:
|     can be Nil. Callback that will be called after all text for one
|     page has been printed, before a new page is started. The  callback
|     should be used to print a footer on the page.
| Returns:
|   number of pages printed. If the job has been aborted the return
|   value will be 0.
| Description:
|   Uses the Canvas.TextOut function to perform text output in
|   the rectangle defined by the margins. The text can span
|   multiple pages.
| Nomenclature:
|   Paper coordinates are relative to the upper left corner of the
|   physical page, canvas coordinates (as used by Delphis  Printer.Canvas)
|   are relative to the upper left corner of the printable area. The
|   printorigin variable below holds the origin of the canvas  coordinate
|   system in paper coordinates. Units for both systems are printer
|   dots, the printers device unit, the unit for resolution is dots
|   per inch (dpi).
| Error Conditions:
|   A valid font is required. Margins that are outside the printable
|   area will be corrected, invalid margins will raise an EPrinter
|   exception.
| Created: 13.05.99 by P. Below
+------------------------------------------------------------}

function PrintStrings(Lines: TStrings;
  const leftmargin, rightmargin,
  topmargin, bottommargin: single;
  const linesPerInch: single;
  aFont: TFont;
  measureonly: Boolean;
  OnPrintheader,
  OnPrintfooter: THeaderFooterProc): Integer;
var
  continuePrint: Boolean; { continue/abort flag for callbacks }
  pagecount: Integer; { number of current page }
  textrect: TRect; { output area, in canvas coordinates }
  headerrect: TRect; { area for header, in canvas
  coordinates }
  footerrect: TRect; { area for footes, in canvas
  coordinates }
  lineheight: Integer; { line spacing in dots }
  charheight: Integer; { font height in dots  }
  textstart: Integer; { index of first line to print on
  current page, 0-based. }

{ Calculate text output and header/footer rectangles. }

  procedure CalcPrintRects;
  var
    X_resolution: Integer; { horizontal printer resolution, in dpi }
    Y_resolution: Integer; { vertical printer resolution, in dpi }
    pagerect: TRect; { total page, in paper coordinates }
    printorigin: TPoint; { origin of canvas coordinate system in
    paper coordinates. }

{ Get resolution, paper size and non-printable margin from
printer driver. }

    procedure GetPrinterParameters;
    begin
      with Printer.Canvas do
      begin
        X_resolution := GetDeviceCaps(Handle, LOGPIXELSX);
        Y_resolution := GetDeviceCaps(Handle, LOGPIXELSY);
        printorigin.X := GetDeviceCaps(Handle, PHYSICALOFFSETX);
        printorigin.Y := GetDeviceCaps(Handle, PHYSICALOFFSETY);
        pagerect.Left := 0;
        pagerect.Right := GetDeviceCaps(Handle, PHYSICALWIDTH);
        pagerect.Top := 0;
        pagerect.Bottom := GetDeviceCaps(Handle, PHYSICALHEIGHT);
      end; { With }
    end; { GetPrinterParameters }

    { Calculate area between the requested margins, paper-relative.
      Adjust margins if they fall outside the printable area.
      Validate the margins, raise EPrinter exception if no text area
      is left. }

    procedure CalcRects;
    var
      max: Integer;
    begin
      with textrect do
      begin
        { Figure textrect in paper coordinates }
        Left := Round(leftmargin * X_resolution);
        if Left < printorigin.X then
          Left := printorigin.X;

        Top := Round(topmargin * Y_resolution);
        if Top < printorigin.Y then
          Top := printorigin.Y;

        { Printer.PageWidth and PageHeight return the size of the
          printable area, we need to add the printorigin to get the
          edge of the printable area in paper coordinates. }
        Right := pagerect.Right - Round(rightmargin * X_resolution);
        max := Printer.PageWidth + printorigin.X;
        if Right > max then
          Right := max;

        Bottom := pagerect.Bottom - Round(bottommargin *
          Y_resolution);
        max := Printer.PageHeight + printorigin.Y;
        if Bottom > max then
          Bottom := max;

        { Validate the margins. }
        if (Left >= Right) or (Top >= Bottom) then
          raise EPrinter.Create('PrintString: the supplied margins are too large, there' +
            'is no area to print left on the page.');
      end; { With }

      { Convert textrect to canvas coordinates. }
      OffsetRect(textrect, -printorigin.X, -printorigin.Y);

      { Build header and footer rects. }
      headerrect := Rect(textrect.Left, 0,
        textrect.Right, textrect.Top);
      footerrect := Rect(textrect.Left, textrect.Bottom,
        textrect.Right, Printer.PageHeight);
    end; { CalcRects }
  begin { CalcPrintRects }
    GetPrinterParameters;
    CalcRects;
    lineheight := Round(Y_resolution / linesPerInch);
  end; { CalcPrintRects }

  { Print a page with headers and footers. }

  procedure PrintPage;

    procedure FireHeaderFooterEvent(event: THeaderFooterProc; r: TRect);
    begin
      if Assigned(event) then
      begin
        event(Printer.Canvas,
          pagecount,
          r,
          continuePrint);
        { Revert to our font, in case event handler changed
          it. }
        Printer.Canvas.Font := aFont;
      end; { If }
    end; { FireHeaderFooterEvent }

    procedure DoHeader;
    begin
      FireHeaderFooterEvent(OnPrintheader, headerrect);
    end; { DoHeader }

    procedure DoFooter;
    begin
      FireHeaderFooterEvent(OnPrintfooter, footerrect);
    end; { DoFooter }

    procedure DoPage;
    var
      Y: Integer;
    begin
      Y := textrect.Top;
      while (textstart < Lines.Count) and
        (Y <= (textrect.Bottom - charheight)) do
      begin
        { Note: use TextRect instead of TextOut to effect clipping
          of the line on the right margin. It is a bit slower,
          though. The clipping rect would be
          Rect( textrect.left, y, textrect.right, y+charheight). }
        Printer.Canvas.TextOut(textrect.Left, Y, Lines[textstart]);
        inc(textstart);
        inc(Y, lineheight);
      end; { While }
    end; { DoPage }
  begin { PrintPage }
    DoHeader;
    if continuePrint then
    begin
      DoPage;
      DoFooter;
      if (textstart < Lines.Count) and continuePrint then
      begin
        inc(pagecount);
        Printer.NewPage;
      end; { If }
    end;
  end; { PrintPage }
begin { PrintStrings }
  Assert(Assigned(aFont),
    'PrintString: requires a valid aFont parameter!');

  continuePrint := True;
  pagecount := 1;
  textstart := 0;
  Printer.BeginDoc;
  try
    CalcPrintRects;
    {$IFNDEF WIN32}
    { Fix for Delphi 1 bug. }
    Printer.Canvas.Font.PixelsPerInch := Y_resolution;
    {$ENDIF }
    Printer.Canvas.Font := aFont;
    charheight := Printer.Canvas.TextHeight('Äy');
    while (textstart < Lines.Count) and continuePrint do
      PrintPage;
  finally
    if continuePrint and not measureonly then
      Printer.EndDoc
    else
    begin
      Printer.Abort;
    end;
  end;

  if continuePrint then
    Result := pagecount
  else
    Result := 0;
end; { PrintStrings }

procedure TLogForm.PrintFooter(aCanvas: TCanvas; aPageCount: Integer;
  aTextrect: TRect; var Continue: Boolean);
var
  s: string;
  res: Integer;
begin
  with aCanvas do
  begin
    { Draw a gray line one point wide below the text }
    res := GetDeviceCaps(Handle, LOGPIXELSY);
    pen.Style := psSolid;
    pen.Color := clGray;
    pen.width := Round(res / 72);
    MoveTo(aTextrect.Left, aTextrect.Top);
    LineTo(aTextrect.Right, aTextrect.Top);
    { Print the page number in Arial 8pt, gray, on right side of
      footer rect. }
    s := Format('Page %d', [aPageCount]);
    Font.Name := 'Arial';
    Font.size := 8;
    Font.Color := clGray;
    TextOut(aTextrect.Left, aTextrect.Top + res div 18, Tarih);
    TextOut(aTextrect.Right - TextWidth(s), aTextrect.Top + res div 18, s);
  end;
end;

procedure TLogForm.PrintHeader(aCanvas: TCanvas; aPageCount: Integer;
  aTextrect: TRect; var Continue: Boolean);
var
  res: Integer;
begin
  with aCanvas do
  begin
    { Draw a gray line one point wide 4 points above the text }
    res := GetDeviceCaps(Handle, LOGPIXELSY);
    pen.Style := psSolid;
    pen.Color := clGray;
    pen.width := Round(res / 72);
    MoveTo(aTextrect.Left, aTextrect.Bottom - res div 18);
    LineTo(aTextrect.Right, aTextrect.Bottom - res div 18);
    { Print the company name in Arial 8pt, gray, on left side of
      footer rect. }
    Font.Name := 'Arial';
    Font.size := 8;
    Font.Color := clGray;
    TextOut(aTextrect.Left, aTextrect.Bottom - res div 10 - TextHeight('W'), LogFile);
    TextOut(aTextrect.Right - TextWidth(PrgName), aTextrect.Bottom - res div 10 - TextHeight('W'), PrgName);
  end;
end;

procedure TLogForm.SpeedButton1Click(Sender: TObject);
begin
  Close;
end;

procedure TLogForm.SBprintClick(Sender: TObject);
var
  pc: Integer;
begin
  //  Tarih:=DateTimeTostr(Now);
  DateTimeTostring(Tarih, 'dd mmmm yyyy, dddd   hh:nn:ss', Now);
  pc := PrintStrings(StringGrid1.Cols[0], 0.75, 0.5, 0.75, 1, 6, StringGrid1.Font, True, PrintHeader, PrintFooter);
  if pc > 0 then
  begin
    PrintDialog1.FromPage := 1;
    PrintDialog1.ToPage := pc;
  end;
  if PrintDialog1.Execute then
  begin
    PrintStrings(StringGrid1.Cols[0],
      0.75, 0.5, 0.75, 1,
      6,
      StringGrid1.Font,
      False,
      PrintHeader, PrintFooter);
  end;

end;

end.
