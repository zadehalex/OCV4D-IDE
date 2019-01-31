unit main;

{$REGION 'tip:'}
//comment=
{$ENDREGION}

{$REGION 'iMotionType Template'}
//      case iMotionType of
//       0:begin aup_variant_set_vlaue(1,-1); end;
//       1:begin end;
//       2:begin end;
//       3:begin end;
//       9:begin end;
//      end;
{$ENDREGION}

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.StdCtrls;

type
  Tfrmmain = class(TForm)
    timerStartup: TTimer;
    StatusBar: TStatusBar;
    procedure FormCreate(Sender: TObject);
    procedure timerStartupTimer(Sender: TObject);
  private
  public
  end;

var
  frmmain: Tfrmmain;

implementation

uses ocv_ui;

{$R *.dfm}

procedure Tfrmmain.FormCreate(Sender: TObject);
begin
   timerStartup.Enabled := True;
end;

procedure Tfrmmain.timerStartupTimer(Sender: TObject);
begin
 TTimer(Sender).Enabled := false;

   frmOCV_Ui := TfrmOCV_Ui.Create(self);
   frmOCV_Ui.Show;

   //hide main form
   self.top := screen.Height - self.height;
   frmmain.Visible := false;
end;

end.
