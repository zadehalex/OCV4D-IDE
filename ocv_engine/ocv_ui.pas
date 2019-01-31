//Version: 31Jan2005

unit ocv_ui;

interface

uses
  Windows, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, ExtCtrls, StdCtrls, ComCtrls, SynEdit, SynEditTypes, SynHighlighterPas, uPSComponent_COM, uPSComponent_StdCtrls, uPSComponent_Forms, uPSComponent_Default, uPSComponent_Controls,
  uPSRuntime, uPSDisassembly, uPSUtils, uPSComponent, uPSCompiler, uPSDebugger, SynEditRegexSearch,
  SynEditSearch, SynEditMiscClasses, SynEditHighlighter, SynEditCodeFolding,
  ocv.core.types_c, ocv_lib, System.ImageList, Vcl.ImgList, ocv.comp.View, ocv.highgui_c,
  ocv_ui_proc;

type
  TfrmOCV_Ui = class(TForm)
   {$REGION 'vcl and proceudre'}
    ce: TPSScriptDebugger;
    IFPS3DllPlugin1: TPSDllPlugin;
    mmEditor: TSynEdit;
    PopupMenu1: TPopupMenu;
    BreakPointMenu: TMenuItem;
    MainMenu1: TMainMenu;
    muFile1: TMenuItem;
    Run1: TMenuItem;
    muStepOver1: TMenuItem;
    muStepInto1: TMenuItem;
    N1: TMenuItem;
    muReset1: TMenuItem;
    N2: TMenuItem;
    muRun2: TMenuItem;
    muExit1: TMenuItem;
    listLog: TListBox;
    Splitter1: TSplitter;
    SaveDialog1: TSaveDialog;
    OpenDialog1: TOpenDialog;
    N3: TMenuItem;
    N4: TMenuItem;
    muNew1: TMenuItem;
    muOpen1: TMenuItem;
    muSave1: TMenuItem;
    muSaveas1: TMenuItem;
    StatusBar: TStatusBar;
    muDecompile1: TMenuItem;
    N5: TMenuItem;
    IFPS3CE_Controls1: TPSImport_Controls;
    IFPS3CE_DateUtils1: TPSImport_DateUtils;
    IFPS3CE_Std1: TPSImport_Classes;
    IFPS3CE_Forms1: TPSImport_Forms;
    IFPS3CE_StdCtrls1: TPSImport_StdCtrls;
    IFPS3CE_ComObj1: TPSImport_ComObj;
    muPause1: TMenuItem;
    SynEditSearch: TSynEditSearch;
    SynEditRegexSearch: TSynEditRegexSearch;
    Search1: TMenuItem;
    muFind1: TMenuItem;
    muReplace1: TMenuItem;
    muSearchagain1: TMenuItem;
    N6: TMenuItem;
    muGotolinenumber1: TMenuItem;
    muSyntaxcheck1: TMenuItem;
    timerStart: TTimer;
    pnlOCV: TPanel;
    splitter2: TSplitter;
    SynPasSyn: TSynPasSyn;
    ImageListGutterGlyphs: TImageList;
    N7: TMenuItem;
    muScript1: TMenuItem;
    muScript2: TMenuItem;
    scrollboxOCV: TScrollBox;
    procedure mmEditorSpecialLineColors(Sender: TObject; Line: Integer; var Special: Boolean; var FG, BG: TColor);
    procedure BreakPointMenuClick(Sender: TObject);
    procedure muExit1Click(Sender: TObject);
    procedure muStepOver1Click(Sender: TObject);
    procedure muStepInto1Click(Sender: TObject);
    procedure muReset1Click(Sender: TObject);
    procedure ceIdle(Sender: TObject);
    procedure muRun2Click(Sender: TObject);
    procedure ceExecute(Sender: TPSScript);
    procedure ceAfterExecute(Sender: TPSScript);
    procedure ceCompile(Sender: TPSScript);
    procedure muNew1Click(Sender: TObject);
    procedure muOpen1Click(Sender: TObject);
    procedure muSave1Click(Sender: TObject);
    procedure muSaveas1Click(Sender: TObject);
    procedure mmEditorStatusChange(Sender: TObject; Changes: TSynStatusChanges);
    procedure muDecompile1Click(Sender: TObject);
    function ceNeedFile(Sender: TObject; const OrginFileName: ansiString; var FileName, Output: ansiString): Boolean;
    procedure ceBreakpoint(Sender: TObject; const FileName: ansistring; Position, Row, Col: Cardinal);
    procedure muPause1Click(Sender: TObject);
    procedure listLogDblClick(Sender: TObject);
    procedure muGotolinenumber1Click(Sender: TObject);
    procedure muFind1Click(Sender: TObject);
    procedure muSearchagain1Click(Sender: TObject);
    procedure muReplace1Click(Sender: TObject);
    procedure muSyntaxcheck1Click(Sender: TObject);
    procedure mmEditorDropFiles(Sender: TObject; X, Y: Integer; AFiles: TStrings);
    procedure timerStartTimer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ceLine(Sender: TObject);
    procedure ceLineInfo(Sender: TObject; const FileName: AnsiString; Position, Row, Col: Cardinal);
    procedure mmEditorGutterClick(Sender: TObject; Button: TMouseButton; X, Y, Line: Integer; Mark: TSynEditMark);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ocvView1MouseDown(Sender: TObject; Button: TMouseButton;  Shift: TShiftState; X, Y: Integer);
    procedure muScript1Click(Sender: TObject);
    procedure ceVerifyProc(Sender: TPSScript; Proc: TPSInternalProcedure;  const Decl: AnsiString; var Error: Boolean);
   {$ENDREGION}
  private
    FResume: Boolean;
    FActiveFile: string;

    function Compile: Boolean;
    function Execute: Boolean;
    procedure SetActiveFile(const Value: string);
    property aFile: string read FActiveFile write SetActiveFile;

    procedure Form_Layout_Setup;
  public
    FActiveLine: Longint;
    FSearchFromCaret: boolean;
    function SaveCheck: Boolean;
  end;

var
  frmOCV_Ui: TfrmOCV_Ui;

implementation

uses ocv_ui_plug,
     ide_debugoutput, uFrmGotoLine,dlgSearchText, dlgReplaceText, dlgConfirmReplace;

{$R *.dfm}

procedure TfrmOCV_Ui.ceCompile(Sender: TPSScript);
begin

  Sender.AddMethod(vOCV1, @TOCV_LIB.load_image,            'function load_image(const stFile:String):Integer');
  Sender.AddMethod(vOCV1, @TOCV_LIB.deal_with_image,       'procedure deal_with_image(idxMat:integer; var idxRes1,idxRes2:integer)');
  Sender.AddMethod(vOCV1, @TOCV_LIB.split_histogram_layer, 'procedure split_histogram_layer(idxMat:integer)');
  Sender.AddMethod(vOCV1, @TOCV_LIB.zero_all,              'procedure zero_all()');
  Sender.AddMethod(vOCV1, @TOCV_LIB.show_mat_image,        'procedure show_mat_image(idxMat:Integer)');

  Sender.AddMethod(vOCV1, @TOCV_LIB.Writeln, 'procedure writeln(s: string)');
  Sender.AddMethod(vOCV1, @TOCV_LIB.Readln, 'procedure readln(var s: string)');
  Sender.AddRegisteredVariable('Self', 'TForm');
  Sender.AddRegisteredVariable('Application', 'TApplication');
  Sender.AddRegisteredVariable('Image', 'TImage');//ok

end;

procedure TfrmOCV_Ui.FormCreate(Sender: TObject);
var  Settings : TStringList;
begin
  timerStart.Enabled := true;

  TDebugSupportPlugin.Create(Self);

  Settings := TStringList.Create;
  try
    SynPasSyn.EnumUserSettings(Settings);
    if Settings.Count > 0 then
      SynPasSyn.UseUserSettings(Settings.Count - 1);
  finally
    Settings.Free;
  end;

  vOCV1 := TOCV_LIB.Create; //ocv main procedure

  Form_Layout_Setup;
end;

procedure TfrmOCV_Ui.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  muReset1Click(MainMenu1);//stop ongoing job

  vOCV1.Free; //ocv main procedure

  Application.Terminate;
end;

procedure TfrmOCV_Ui.Form_Layout_Setup;
begin
  Width := 1024;
  pnlOCV.Width := 372;

end;

procedure TfrmOCV_Ui.timerStartTimer(Sender: TObject);
var stFileName:string;
begin
 TTimer(Sender).Enabled := False;

  oup_ocv_viewer_ini(scrollboxOCV);//create ocv_viewer

  //test
  muScript1.Click;

  //muRun2.Click;
  //load_image();
end;

procedure TfrmOCV_Ui.ocvView1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var stTmp:string;
begin
  stTmp := inttostr(TocvView(Sender).Tag);
  if TocvView(Sender).Image <> nil then
   cvShowImage( PAnsiChar(AnsiString(stTmp)) , TocvView(Sender).Image.IpImage );// .IplImage);
   //cvShowImage( 'test', TocvView(Sender).Image.IpImage );// .IplImage);
end;



{$REGION 'original code'}
procedure TfrmOCV_Ui.mmEditorSpecialLineColors(Sender: TObject; Line: Integer; var Special: Boolean; var FG, BG: TColor);
begin
  if ce.HasBreakPoint(ce.MainFileName, Line) then
   begin
    Special := True;
    if Line = FActiveLine then
         begin BG := clWhite; FG := clRed; end
    else begin FG := clWhite; BG := clRed; end;
   end
 else
  if Line = FActiveLine then
    begin Special := True; FG := clWhite; bg := clBlue; end
  else Special := False;
end;

procedure TfrmOCV_Ui.BreakPointMenuClick(Sender: TObject);
var Line: Longint;
begin
  Line := mmEditor.CaretY;
  if ce.HasBreakPoint(ce.MainFileName, Line) then
       ce.ClearBreakPoint(ce.MainFileName, Line)
  else ce.SetBreakPoint(ce.MainFileName, Line);
  mmEditor.Refresh;
end;

procedure TfrmOCV_Ui.ceLine(Sender: TObject);
begin
//  listLog.Items.Add('line: '+inttostr(FActiveLine));
end;

procedure TfrmOCV_Ui.ceLineInfo(Sender: TObject; const FileName: AnsiString; Position, Row, Col: Cardinal);
begin
  if ce.Exec.DebugMode <> dmRun then
    begin
      FActiveLine := Row;
      if (FActiveLine < mmEditor.TopLine +2) or (FActiveLine > mmEditor.TopLine + mmEditor.LinesInWindow -2) then
      begin mmEditor.TopLine := FActiveLine - (mmEditor.LinesInWindow div 2); end;
      mmEditor.CaretY := FActiveLine;
      mmEditor.CaretX := 1;
      mmEditor.Refresh;
    end
  else
    Application.ProcessMessages;
end;

procedure TfrmOCV_Ui.muExit1Click(Sender: TObject);
begin
  muReset1Click(nil); //terminate any running script
  if SaveCheck then Close; //check if script changed and not yet saved
end;

procedure TfrmOCV_Ui.muStepOver1Click(Sender: TObject);
begin
  if ce.Exec.Status in isRunningOrPaused then
       begin ce.StepOver; end
  else begin if Compile then  begin ce.StepInto; Execute; end; end;
end;

procedure TfrmOCV_Ui.muStepInto1Click(Sender: TObject);
begin
  if ce.Exec.Status in isRunningOrPaused then
       begin ce.StepInto; end
  else begin if Compile then begin ce.StepInto; Execute; end; end;
end;

procedure TfrmOCV_Ui.muPause1Click(Sender: TObject);
begin
 if ce.Exec.Status = isRunning then
  begin ce.Pause; ce.StepInto; end;
end;

procedure TfrmOCV_Ui.muReset1Click(Sender: TObject);
begin
  if ce.Exec.Status in isRunningOrPaused then
    ce.Stop;
end;

function TfrmOCV_Ui.Compile: Boolean;
var  i: Longint;
begin
  ce.Script.Assign(mmEditor.Lines);
  Result := ce.Compile;
  listLog.Clear;
  for i := 0 to ce.CompilerMessageCount -1 do
   begin listLog.Items.Add(ce.CompilerMessages[i].MessageToString); end;
  if Result then listLog.Items.Add(STR_SUCCESSFULLY_COMPILED);
end;

procedure TfrmOCV_Ui.ceIdle(Sender: TObject);
begin
  Application.ProcessMessages; //Birb: don't use Application.HandleMessage here, else GUI will be unrensponsive if you have a tight loop and won't be able to use Run/Reset menu action
  if FResume then
   begin FResume := False; ce.Resume; FActiveLine := 0; mmEditor.Refresh; end;
end;

procedure TfrmOCV_Ui.muRun2Click(Sender: TObject);
begin
  if CE.Running then
       begin FResume := True end
  else begin if Compile then Execute; end;
end;

procedure TfrmOCV_Ui.ceExecute(Sender: TPSScript);
begin
  ce.SetVarToInstance('SELF', Self);
  ce.SetVarToInstance('APPLICATION', Application);
  Caption := STR_FORM_TITLE_RUNNING;
end;

procedure TfrmOCV_Ui.ceAfterExecute(Sender: TPSScript);
begin
  Caption := STR_FORM_TITLE;
  FActiveLine := 0;

  mmEditor.Refresh;
end;

function TfrmOCV_Ui.Execute: Boolean;
var stMsg:string;
begin
  listLog.Items.Clear; //debugoutput.Output.Clear;
  if CE.Execute then
    begin
      stMsg := STR_SUCCESSFULLY_EXECUTED;//Messages.Items.Add(STR_SUCCESSFULLY_EXECUTED);
      Result := True;
    end
  else
    begin
      stMsg := STR_RUNTIME_ERROR +','+ extractFileName(aFile)+','+ IntToStr(ce.ExecErrorRow)+','+IntToStr(ce.ExecErrorCol)+','+IntToStr(ce.ExecErrorProcNo)+','+IntToStr(ce.ExecErrorByteCodePosition)+','+ce.ExecErrorToString; // messages.Items.Add(Format(STR_RUNTIME_ERROR, [extractFileName(aFile), ce.ExecErrorRow,ce.ExecErrorCol,ce.ExecErrorProcNo,ce.ExecErrorByteCodePosition,ce.ExecErrorToString])); //Birb
      Result := False;
    end;
end;

procedure TfrmOCV_Ui.muNew1Click(Sender: TObject);
begin
  if SaveCheck then //check if script changed and not yet saved
   begin
    mmEditor.ClearAll;
    mmEditor.Lines.Text := STR_DEFAULT_PROGRAM;
    mmEditor.Modified := False;
    aFile := '';
   end;
end;

procedure TfrmOCV_Ui.muOpen1Click(Sender: TObject);
begin
  if SaveCheck then //check if script changed and not yet saved
   begin
    if OpenDialog1.Execute then
     begin
      mmEditor.ClearAll;
      mmEditor.Lines.LoadFromFile(OpenDialog1.FileName);
      mmEditor.Modified := False;
      aFile := OpenDialog1.FileName; //ShowMessage(aFile);
     end;
   end;
end;

procedure TfrmOCV_Ui.muSave1Click(Sender: TObject);
begin
  if aFile <> '' then
   begin
    mmEditor.Lines.SaveToFile(aFile);
    mmEditor.Modified := False;
   end
  else muSaveAs1Click(nil);
end;

procedure TfrmOCV_Ui.muSaveas1Click(Sender: TObject);
begin
  if SaveDialog1.Execute then
   begin
    aFile := SaveDialog1.FileName;
    mmEditor.Lines.SaveToFile(aFile);
    mmEditor.Modified := False;
   end;
end;

//check if script changed and not yet saved//
function TfrmOCV_Ui.SaveCheck: Boolean;
begin
  if mmEditor.Modified then
    begin
      case MessageDlg(STR_NOTSAVED, mtConfirmation, mbYesNoCancel, 0) of
        idYes: begin muSave1Click(nil); Result := aFile <> ''; end;
        IDNO: Result := True;
        else  Result := False;
      end;
    end
  else Result := True;
end;

procedure TfrmOCV_Ui.mmEditorStatusChange(Sender: TObject; Changes: TSynStatusChanges);
begin
  StatusBar.Panels[0].Text := IntToStr(mmEditor.CaretY)+':'+IntToStr(mmEditor.CaretX)
end;

procedure TfrmOCV_Ui.muScript1Click(Sender: TObject);
var stFile:string;
begin
   stFile := ExtractFilePath(Application.ExeName) + 'script\'+TMenuItem(Sender).Caption+'.rops';
   stFile := StringReplace(stFile,'&','',[rfReplaceAll]);//i don't know menuitem has '&' char for shortcut

   mmEditor.ClearAll;
   mmEditor.Lines.LoadFromFile(stFile);
   mmEditor.Modified := False;
   aFile := stFile; //ShowMessage(aFile);

   muRun2.Click;
end;

procedure TfrmOCV_Ui.muDecompile1Click(Sender: TObject);
var s: AnsiString;// string;//not work???  s: {$IFDEF DELPHI2009UP} AnsiString {$ELSE} String {$ENDIF};
begin
//2019/01/25: modify uPSDisassembly.pas
//ok: function IFPS3DataToText(const Input: tbtstring; var Output: tbtstring): Boolean;
//ng: function IFPS3DataToText(const Input: tbtstring; var Output: string): Boolean;

  if Compile then
  begin
    ce.GetCompiled(s);
    IFPS3DataToText(s, s); //listLog.Items.Add(s);
    debugoutput.output.Lines.Text := s;
    debugoutput.visible := true;
  end;
end;

function TfrmOCV_Ui.ceNeedFile(Sender: TObject; const OrginFileName: ansiString;  var FileName, Output: ansiString): Boolean;
var  path: string; f: TFileStream;
begin
  if aFile <> '' then
    Path := ExtractFilePath(aFile)
  else
    Path := ExtractFilePath(ParamStr(0));
  Path := Path + FileName;
  try
    F := TFileStream.Create(Path, fmOpenRead or fmShareDenyWrite);
  except
    Result := false;
    exit;
  end;
  try
    SetLength(Output, f.Size);
    f.Read(Output[1], Length(Output));
  finally
    f.Free;
  end;
  Result := True;
end;

procedure TfrmOCV_Ui.ceVerifyProc(Sender: TPSScript; Proc: TPSInternalProcedure;
  const Decl: AnsiString; var Error: Boolean);
begin
//
end;

procedure TfrmOCV_Ui.ceBreakpoint(Sender: TObject; const FileName: ansistring; Position, Row, Col: Cardinal);
begin
  FActiveLine := Row;
  if (FActiveLine < mmEditor.TopLine +2) or (FActiveLine > mmEditor.TopLine + mmEditor.LinesInWindow -2) then
  begin
    mmEditor.TopLine := FActiveLine - (mmEditor.LinesInWindow div 2);
  end;
  mmEditor.CaretY := FActiveLine;
  mmEditor.CaretX := 1;

  mmEditor.Refresh;
end;

procedure TfrmOCV_Ui.SetActiveFile(const Value: string);
begin
  FActiveFile := Value;
  ce.MainFileName := ExtractFileName(FActiveFile);
  if Ce.MainFileName = '' then
    Ce.MainFileName := STR_UNNAMED;
end;

procedure TfrmOCV_Ui.listLogDblClick(Sender: TObject);
begin
  //if Copy(messages.Items[messages.ItemIndex],1,7)= '[Error]' then
  //begin
    mmEditor.CaretXY := GetErrorRowCol(listLog.Items[listLog.ItemIndex]);
    mmEditor.SetFocus;
  //end;
end;

procedure TfrmOCV_Ui.muGotolinenumber1Click(Sender: TObject);
begin
  with TfrmGotoLine.Create(self) do
  try
    Char := mmEditor.CaretX;
    Line := mmEditor.CaretY;
    ShowModal;
    if ModalResult = mrOK then
      mmEditor.CaretXY := CaretXY;
  finally
    Free;
    mmEditor.SetFocus;
  end;
end;

procedure TfrmOCV_Ui.muFind1Click(Sender: TObject);
begin
  ShowSearchReplaceDialog(FALSE);
end;

procedure TfrmOCV_Ui.muSearchagain1Click(Sender: TObject);
begin
  DoSearchReplaceText(FALSE, FALSE);
end;

procedure TfrmOCV_Ui.muReplace1Click(Sender: TObject);
begin
  ShowSearchReplaceDialog(TRUE);
end;

procedure TfrmOCV_Ui.muSyntaxcheck1Click(Sender: TObject);
begin
 Compile;
end;

procedure TfrmOCV_Ui.mmEditorDropFiles(Sender: TObject; X, Y: Integer;
  AFiles: TStrings);
begin
 if AFiles.Count>=1 then
  if SaveCheck then //check if script changed and not yet saved
  begin
    mmEditor.ClearAll;
    mmEditor.Lines.LoadFromFile(AFiles[0]);
    mmEditor.Modified := False;
    aFile := AFiles[0];
  end;
end;

procedure TfrmOCV_Ui.mmEditorGutterClick(Sender: TObject; Button: TMouseButton; X, Y, Line: Integer; Mark: TSynEditMark);
begin
 BreakPointMenuClick(TSynEdit(Sender));
end;
{$ENDREGION}

end.

