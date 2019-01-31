program ocv4d_ide;

uses
  FastMM4 in 'prog\FastMM4.pas',
  FastMM4Messages in 'prog\FastMM4Messages.pas',
  Forms,
  ide_debugoutput in 'ocv_engine\ide_debugoutput.pas' {debugoutput},
  uFrmGotoLine in 'ocv_engine\uFrmGotoLine.pas' {frmGotoLine},
  dlgSearchText in 'ocv_engine\dlgSearchText.pas' {TextSearchDialog},
  dlgConfirmReplace in 'ocv_engine\dlgConfirmReplace.pas' {ConfirmReplaceDialog},
  dlgReplaceText in 'ocv_engine\dlgReplaceText.pas' {TextReplaceDialog},
  ocv_ui in 'ocv_engine\ocv_ui.pas' {frmOCV_Ui},
  ocv_lib in 'ocv_engine\ocv_lib.pas',
  main in 'main.pas' {frmmain},
  ocv_ui_plug in 'ocv_engine\ocv_ui_plug.pas',
  ocv_ui_proc in 'ocv_engine\ocv_ui_proc.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(Tfrmmain, frmmain);
  Application.Run;
end.
