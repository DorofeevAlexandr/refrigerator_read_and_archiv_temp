object Form1: TForm1
  Left = 0
  Top = 0
  Caption = #1040#1088#1093#1080#1074#1072#1090#1086#1088' '#1090#1077#1084#1087#1077#1088#1072#1090#1091#1088' ver. 1.0'
  ClientHeight = 418
  ClientWidth = 621
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  WindowState = wsMinimized
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object StatusBar1: TStatusBar
    Left = 0
    Top = 399
    Width = 621
    Height = 19
    Panels = <
      item
        Width = 200
      end
      item
        Width = 200
      end
      item
        Width = 200
      end>
  end
  object mLog: TMemo
    Left = 0
    Top = 0
    Width = 621
    Height = 399
    Align = alClient
    ScrollBars = ssBoth
    TabOrder = 1
  end
  object MainMenu1: TMainMenu
    Left = 480
    Top = 24
    object n_file: TMenuItem
      Caption = #1060#1072#1081#1083
      object n_read: TMenuItem
        Caption = #1055#1088#1086#1095#1080#1090#1072#1090#1100' '#1076#1072#1085#1085#1099#1077' '#1089' '#1055#1051#1050
        Enabled = False
        OnClick = n_readClick
      end
      object n_tuning: TMenuItem
        Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1080
        object N2: TMenuItem
          Caption = #1054#1089#1090#1072#1085#1086#1074#1080#1090#1100' '#1086#1087#1088#1086#1089
          OnClick = N2Click
        end
        object N3: TMenuItem
          Caption = #1047#1072#1087#1091#1089#1090#1080#1090#1100' '#1086#1087#1088#1086#1089
          OnClick = N3Click
        end
      end
      object n_close: TMenuItem
        Caption = #1042#1099#1093#1086#1076
        OnClick = n_closeClick
      end
    end
    object n_help: TMenuItem
      Caption = #1057#1087#1088#1072#1074#1082#1072
    end
  end
  object MdBClient_At: TIdModBusClient
    ConnectTimeout = 0
    IPVersion = Id_IPv4
    AutoConnect = False
    TimeOut = 3000
    Left = 344
    Top = 24
  end
  object TimerRead: TTimer
    Interval = 10000
    OnTimer = TimerReadTimer
    Left = 480
    Top = 144
  end
  object TimerPing: TTimer
    OnTimer = TimerPingTimer
    Left = 480
    Top = 208
  end
  object MdBClient_Torb: TIdModBusClient
    ConnectTimeout = 0
    IPVersion = Id_IPv4
    AutoConnect = False
    TimeOut = 3000
    Left = 344
    Top = 80
  end
end
