unit ocv_ui_plug;

interface

uses
  Windows, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, ExtCtrls, StdCtrls, ComCtrls, SynEdit, SynEditTypes, SynHighlighterPas, uPSComponent_COM, uPSComponent_StdCtrls, uPSComponent_Forms, uPSComponent_Default, uPSComponent_Controls,
  uPSRuntime, uPSDisassembly, uPSUtils, uPSComponent, uPSDebugger, SynEditRegexSearch,
  SynEditSearch, SynEditMiscClasses, SynEditHighlighter, SynEditCodeFolding,
  ocv.core.types_c, ocv_lib, System.ImageList, Vcl.ImgList, ocv.comp.View, ocv.highgui_c,
  ocv_ui;

{ TGutterMarkDrawPlugin }

type
  TDebugSupportPlugin = class(TSynEditPlugin)
  protected
    fForm: TfrmOCV_Ui;//TSimpleIDEMainForm;

    procedure PaintGutterGlyphs(ACanvas: TCanvas; AClip: TRect; FirstLine, LastLine: integer);
    procedure AfterPaint(ACanvas: TCanvas; const AClip: TRect; FirstLine, LastLine: integer); override;
    procedure LinesInserted(FirstLine, Count: integer); override;
    procedure LinesDeleted(FirstLine, Count: integer); override;
  public
    constructor Create(AForm: TfrmOCV_Ui);//TSimpleIDEMainForm);
  end;


{$ENDREGION}

implementation

constructor TDebugSupportPlugin.Create(AForm: TfrmOCV_Ui);//TSimpleIDEMainForm);
begin
  inherited Create(AForm.mmEditor);
  fForm := AForm;
end;

procedure TDebugSupportPlugin.AfterPaint(ACanvas: TCanvas; const AClip: TRect;
  FirstLine, LastLine: integer);
begin
  PaintGutterGlyphs(ACanvas, AClip, FirstLine, LastLine);
end;

procedure TDebugSupportPlugin.LinesInserted(FirstLine, Count: integer);
begin
// Note: You will need this event if you want to track the changes to
//       breakpoints in "Real World" apps, where the editor is not read-only
end;

procedure TDebugSupportPlugin.LinesDeleted(FirstLine, Count: integer);
begin
// Note: You will need this event if you want to track the changes to
//       breakpoints in "Real World" apps, where the editor is not read-only
end;

procedure TDebugSupportPlugin.PaintGutterGlyphs(ACanvas: TCanvas; AClip: TRect; FirstLine, LastLine: integer);
var LH, X, Y: integer; ImgIndex: integer; //LI: TDebuggerLineInfos;
begin
//tip:
//  TDebuggerState = (dsStopped, dsRunning, dsPaused);
//  TDebuggerLineInfo = (dlCurrentLine, dlBreakpointLine, dlExecutableLine);
//  TDebuggerLineInfos = set of TDebuggerLineInfo;

with fForm do
 begin
    FirstLine := mmEditor.RowToLine(FirstLine);
    LastLine := mmEditor.RowToLine(LastLine);
    X := 14;
    LH := mmEditor.LineHeight;
    while FirstLine <= LastLine do
    begin
      Y := (LH - ImageListGutterGlyphs.Height) div 2
           + LH * (mmEditor.LineToRow(FirstLine) - mmEditor.TopLine);

       if FActiveLine = 0 then
        begin
             if ce.HasBreakPoint(ce.MainFileName, FirstLine ) then
                  ImgIndex := 3
             else ImgIndex := 0;
        end
       else
        begin
             if ce.HasBreakPoint(ce.MainFileName, FirstLine ) and ( FActiveLine = FirstLine )then
                  ImgIndex := 2
             else
              begin //same like above
               if ce.HasBreakPoint(ce.MainFileName, FirstLine ) then
                    ImgIndex := 3
               else ImgIndex := 0;
              end;
        end;

      if ImgIndex >= 0 then
        ImageListGutterGlyphs.Draw(ACanvas, X, Y, ImgIndex);

      Inc(FirstLine);
    end;
end;

end;

end.
