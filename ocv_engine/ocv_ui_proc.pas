unit ocv_ui_proc;

interface

uses
  Windows, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, ExtCtrls, StdCtrls, ComCtrls, SynEdit, SynEditTypes, SynHighlighterPas, uPSComponent_COM, uPSComponent_StdCtrls, uPSComponent_Forms, uPSComponent_Default, uPSComponent_Controls,
  uPSRuntime, uPSDisassembly, uPSUtils, uPSComponent, uPSDebugger, SynEditRegexSearch,
  SynEditSearch, SynEditMiscClasses, SynEditHighlighter, SynEditCodeFolding,
  ocv.core_c, ocv.core.types_c, System.ImageList, Vcl.ImgList, ocv.comp.View, ocv.highgui_c,
  ocv.imgproc.types_c,ocv.utils,ocv.comp.Types,ocv.comp.ImageOperation,
  ocv_lib;

const
  isRunningOrPaused = [isRunning, isPaused];

// options - to be saved to the registry
var
  gbSearchBackwards: boolean;
  gbSearchCaseSensitive: boolean;
  gbSearchFromCaret: boolean;
  gbSearchSelectionOnly: boolean;
  gbSearchTextAtCaret: boolean;
  gbSearchWholeWords: boolean;
  gbSearchRegex: boolean;
  gsSearchText: string;
  gsSearchTextHistory: string;
  gsReplaceText: string;
  gsReplaceTextHistory: string;

resourcestring
  STR_TEXT_NOTFOUND = 'Text not found';
  STR_UNNAMED = 'Unnamed';
  STR_SUCCESSFULLY_COMPILED = 'Successfully compiled';
  STR_SUCCESSFULLY_EXECUTED = 'Successfully executed';
  STR_RUNTIME_ERROR='[Runtime error] %s(%d:%d), bytecode(%d:%d): %s'; //Birb
  STR_FORM_TITLE = 'OCV4D-IDE';
  STR_FORM_TITLE_RUNNING = 'OCV4D-IDE - Running';
  STR_INPUTBOX_TITLE = 'Script';
  STR_DEFAULT_PROGRAM = 'Program test;'#13#10'begin'#13#10'end.';
  STR_NOTSAVED = 'File has not been saved, save now?';


  procedure oup_ocv_viewer_ini(pnlParent:TScrollBox);
  procedure oup_ocv_viewer_reset(pnlParent:TScrollBox);

  function GetErrorRowCol(const inStr: string): TBufferCoord;
  procedure DoSearchReplaceText(AReplace: boolean; ABackwards: boolean);
  procedure ShowSearchReplaceDialog(AReplace: boolean);

implementation

uses ocv_ui,
  ide_debugoutput, uFrmGotoLine,dlgSearchText, dlgReplaceText, dlgConfirmReplace;

procedure oup_ocv_viewer_ini(pnlParent:TScrollBox);
var i,j,dx,dy,iw,ih,iTag:Integer; view1: TocvView;
begin
    //1. get ix, iy
    iw :=2; ih:=8; //16: conicntOcvViewer
    dx := 173;//trunc(pnlParent.Width  / iw);//180
    dy := 120;//trunc(pnlParent.Height / ih);//120

    //2. create panel
     j:= 0; iTag := 0;
     while j < ih do
       begin
           i:= 0;
           while i < iw do
            begin
              //----------------------------------------------------------------
                view1 := TocvView.Create(pnlParent);
                  view1.Parent := pnlParent;
                  view1.OnMouseDown := frmOCV_Ui.ocvView1MouseDown;
                  view1.Cursor := crHandPoint;
                  view1.Width  := dx;
                  view1.Height := dy;
                  view1.Left   := i*dx;
                  view1.Top    := j*dy;
                  view1.Tag    := iTag;
              //----------------------------------------------------------------
              i := i + 1; iTag := iTag + 1;
            end;
        j := j + 1;
       end;

    //9. visible = true
    //pnlParent.Visible := true; move to upper level
end;

procedure oup_ocv_viewer_reset(pnlParent:TScrollBox);
var i:Integer; ocvTmp:IocvImage;  imgBlank : pIplImage; //blank image
begin

  //1. create blank image
        imgBlank := cvCreateImage(cvSize(255, 200),8, 3);
        cvSet(imgBlank, cvScalar(192,192,192));//black
  ocvTmp:= TocvImage.CreateClone(imgBlank) as IocvImage;

  //2. run loop to fill blink
  if  pnlParent.ControlCount > 0 then
   begin
     for  i := 0 to conicntOcvViewer -1   do
      begin
          TocvView(frmOCV_UI.scrollboxOCV.Controls[i]).DrawImage(ocvTmp);
      end;
   end;

  ocvTmp   := nil;
  cvReleaseImage(imgBlank); // imgBlank := nil; not work, can't free memory

  //9. scrollbar to top
  frmOCV_Ui.scrollboxOCV.VertScrollBar.Position := 0;

end;

{$REGION 'orgiginal code'}
function GetErrorRowCol(const inStr: string): TBufferCoord;
var Row:string; Col:string; p1,p2,p3:integer;
begin
  p1:=Pos('(',inStr);
  p2:=Pos(':',inStr);
  p3:=Pos(')',inStr);
  if (p1>0) and (p2>p1) and (p3>p2) then
   begin
    Row := Copy(inStr, p1+1,p2-p1-1);
    Col := Copy(inStr, p2+1,p3-p2-1);
    Result.Char := StrToInt(Trim(Col));
    Result.Line := StrToInt(Trim(Row));
   end
  else
   begin
    Result.Char := 1;
    Result.Line := 1;
   end
end;

procedure DoSearchReplaceText(AReplace: boolean; ABackwards: boolean);
var Options: TSynSearchOptions;
begin
with frmOCV_Ui do
 begin
  Statusbar.SimpleText := '';
  if AReplace then
       Options := [ssoPrompt, ssoReplace, ssoReplaceAll]
  else Options := [];

  if ABackwards            then Include(Options, ssoBackwards);
  if gbSearchCaseSensitive then Include(Options, ssoMatchCase);
  if not fSearchFromCaret  then Include(Options, ssoEntireScope);
  if gbSearchSelectionOnly then Include(Options, ssoSelectedOnly);
  if gbSearchWholeWords    then Include(Options, ssoWholeWord);
  if gbSearchRegex         then mmEditor.SearchEngine := SynEditRegexSearch
  else   mmEditor.SearchEngine := SynEditSearch;

  if mmEditor.SearchReplace(gsSearchText, gsReplaceText, Options) = 0 then
   begin
    MessageBeep(MB_ICONASTERISK);
    Statusbar.SimpleText := STR_TEXT_NOTFOUND;
    if ssoBackwards in Options then
         mmEditor.BlockEnd := mmEditor.BlockBegin
    else mmEditor.BlockBegin := mmEditor.BlockEnd;
    mmEditor.CaretXY := mmEditor.BlockBegin;
   end;

  if ConfirmReplaceDialog <> nil then
    ConfirmReplaceDialog.Free;
end;

end;

procedure ShowSearchReplaceDialog(AReplace: boolean);
var  dlg: TTextSearchDialog;
begin
with frmOCV_Ui do
 begin
  Statusbar.SimpleText := '';
  if AReplace then
       dlg := TTextReplaceDialog.Create(frmOCV_Ui)
  else dlg := TTextSearchDialog.Create(frmOCV_Ui);

  with dlg do
   try  // assign search options
    SearchBackwards       := gbSearchBackwards;
    SearchCaseSensitive   := gbSearchCaseSensitive;
    SearchFromCursor      := gbSearchFromCaret;
    SearchInSelectionOnly := gbSearchSelectionOnly;
    // start with last search text
    SearchText := gsSearchText;
    if gbSearchTextAtCaret then
     begin // if something is selected search for that text
      if frmOCV_Ui.mmEditor.SelAvail and (frmOCV_Ui.mmEditor.BlockBegin.Line = frmOCV_Ui.mmEditor.BlockEnd.Line) //Birb (fix at SynEdit's SearchReplaceDemo)
      then SearchText := frmOCV_Ui.mmEditor.SelText
      else SearchText := frmOCV_Ui.mmEditor.GetWordAtRowCol(frmOCV_Ui.mmEditor.CaretXY);
     end;

    SearchTextHistory := gsSearchTextHistory;
    if AReplace then with dlg as TTextReplaceDialog do
     begin
      ReplaceText        := gsReplaceText;
      ReplaceTextHistory := gsReplaceTextHistory;
     end;

    SearchWholeWords := gbSearchWholeWords;
    if ShowModal = mrOK then
     begin
      gbSearchBackwards     := SearchBackwards;
      gbSearchCaseSensitive := SearchCaseSensitive;
      gbSearchFromCaret     := SearchFromCursor;
      gbSearchSelectionOnly := SearchInSelectionOnly;
      gbSearchWholeWords    := SearchWholeWords;
      gbSearchRegex         := SearchRegularExpression;
      gsSearchText          := SearchText;
      gsSearchTextHistory   := SearchTextHistory;
      if AReplace then with dlg as TTextReplaceDialog do begin
        gsReplaceText := ReplaceText;
        gsReplaceTextHistory := ReplaceTextHistory;
      end;

      fSearchFromCaret := gbSearchFromCaret;
      if gsSearchText <> '' then
       begin
        DoSearchReplaceText(AReplace, gbSearchBackwards);
        fSearchFromCaret := TRUE;
       end;
    end;
  finally
    dlg.Free;
  end;

 end;
end;
{$ENDREGION}

end.
