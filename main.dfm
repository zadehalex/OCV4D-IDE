object frmmain: Tfrmmain
  Left = 0
  Top = 0
  Caption = 'Main UI'
  ClientHeight = 99
  ClientWidth = 163
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object StatusBar: TStatusBar
    Left = 0
    Top = 79
    Width = 163
    Height = 20
    Panels = <
      item
        Width = 240
      end
      item
        Width = 160
      end
      item
        Width = 280
      end
      item
        BiDiMode = bdRightToLeft
        ParentBiDiMode = False
        Width = 50
      end>
  end
  object timerStartup: TTimer
    Enabled = False
    Interval = 50
    OnTimer = timerStartupTimer
    Left = 20
    Top = 30
  end
end
