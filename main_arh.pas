unit main_arh;

interface

uses
   Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, IdBaseComponent, IdComponent, IdTCPConnection,
  IdTCPClient, IdModbusClient, Types, ExtCtrls, Menus, ComCtrls,
  IdCustomTCPServer, WinSock, uICMP, SQLiteTable3;

type
  TPLC = record
  Host: string;
  plc_v_seti: boolean;
  skip_ping: integer;
  sqlite_base_open: boolean;
  end;


type
  T_Temperature = record
	temp_name: string;
  temp_coment: string;
  reg_adress: word;
  value: real;
  max_val: real;
  min_val: real;
  al_min: boolean;
  al_max: boolean;
  end;




type
  TForm1 = class(TForm)
    MainMenu1: TMainMenu;
    StatusBar1: TStatusBar;
    n_file: TMenuItem;
    n_help: TMenuItem;
    n_close: TMenuItem;
    n_tuning: TMenuItem;
    MdBClient_At: TIdModBusClient;
    TimerRead: TTimer;
    mLog: TMemo;
    n_read: TMenuItem;
    TimerPing: TTimer;
    MdBClient_Torb: TIdModBusClient;
    N2: TMenuItem;
    N3: TMenuItem;
    procedure n_closeClick(Sender: TObject);
    procedure n_readClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure TimerPingTimer(Sender: TObject);
    procedure TimerReadTimer(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure N2Click(Sender: TObject);
    procedure N3Click(Sender: TObject);
  private
    { Private declarations }

  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  Torbeevo: TPLC;
  Atajschego: TPLC;
  Torbeevo_temper: array[0..129] of T_Temperature;
  Atajschego_temper: array[0..59] of T_Temperature;

  BaseTorbeevo : TSQLiteDatabase; //база данных SQLite
  BaseAtajschego : TSQLiteDatabase; //база данных SQLite

  // en_work_net: boolean;


implementation

{$R *.dfm}

procedure InitTemperature();
begin

Torbeevo_temper[0].temp_name := 'T_WinCC_1_1';
Torbeevo_temper[0].temp_coment := 'Помещение 1.1';
Torbeevo_temper[0].reg_adress := 100;

Torbeevo_temper[1].temp_name := 'T_WinCC_1';
Torbeevo_temper[1].temp_coment := 'Помещение 1 (пропиленгликоль)';
Torbeevo_temper[1].reg_adress := 102;

Torbeevo_temper[2].temp_name := 'T_WinCC_2_5_0';
Torbeevo_temper[2].temp_coment := 'Помещение 2.5 ДТ-0';
Torbeevo_temper[2].reg_adress := 104;

Torbeevo_temper[3].temp_name := 'T_WinCC_2_5_1';
Torbeevo_temper[3].temp_coment := 'Помещение 2.5 ДТ-1';
Torbeevo_temper[3].reg_adress := 106;

Torbeevo_temper[4].temp_name := 'T_WinCC_2_5_3';
Torbeevo_temper[4].temp_coment := 'Помещение 2.5 ДТ-3';
Torbeevo_temper[4].reg_adress := 108;

Torbeevo_temper[5].temp_name := 'T_WinCC_2_6_1';
Torbeevo_temper[5].temp_coment := 'Помещение 2.6';
Torbeevo_temper[5].reg_adress := 110;

Torbeevo_temper[6].temp_name := 'T_WinCC_2';
Torbeevo_temper[6].temp_coment := 'Помещение 2 (пропиленгликоль)';
Torbeevo_temper[6].reg_adress := 112;

Torbeevo_temper[7].temp_name := 'T_WinCC_3_1';
Torbeevo_temper[7].temp_coment := 'Помещение 3.1';
Torbeevo_temper[7].reg_adress := 114;

Torbeevo_temper[8].temp_name := 'T_WinCC_3';
Torbeevo_temper[8].temp_coment := 'Помещение 3, 20 (пропиленгликоль) ДТ-3.0';
Torbeevo_temper[8].reg_adress := 116;

Torbeevo_temper[9].temp_name := 'T_WinCC_4_0';
Torbeevo_temper[9].temp_coment := 'Помещение 4 ДТ-0';
Torbeevo_temper[9].reg_adress := 118;

Torbeevo_temper[10].temp_name := 'T_WinCC_4_3';
Torbeevo_temper[10].temp_coment := 'Помещение 4 ДТ-3';
Torbeevo_temper[10].reg_adress := 120;

Torbeevo_temper[11].temp_name := 'T_WinCC_4_6';
Torbeevo_temper[11].temp_coment := 'Помещение 4 ДТ-6';
Torbeevo_temper[11].reg_adress := 122;

Torbeevo_temper[12].temp_name := 'T_WinCC_5_1_0';
Torbeevo_temper[12].temp_coment := 'Помещение 5.1 ДТ-0';
Torbeevo_temper[12].reg_adress := 124;

Torbeevo_temper[13].temp_name := 'T_WinCC_5_1_1';
Torbeevo_temper[13].temp_coment := 'Помещение 5.1 ДТ-1';
Torbeevo_temper[13].reg_adress := 126;

Torbeevo_temper[14].temp_name := 'T_WinCC_5_1_2';
Torbeevo_temper[14].temp_coment := 'Помещение 5.1 ДТ-2';
Torbeevo_temper[14].reg_adress := 128;

Torbeevo_temper[15].temp_name := 'T_WinCC_5';
Torbeevo_temper[15].temp_coment := 'Помещение 5, 6 (пропиленгликоль) ДТ-5.0';
Torbeevo_temper[15].reg_adress := 130;

Torbeevo_temper[16].temp_name := 'T_WinCC_6_1';
Torbeevo_temper[16].temp_coment := 'Помещение 6.1';
Torbeevo_temper[16].reg_adress := 132;

Torbeevo_temper[17].temp_name := 'T_WinCC_6';
Torbeevo_temper[17].temp_coment := 'Помещение 5, 6 (пропиленгликоль) ДТ-6.0';
Torbeevo_temper[17].reg_adress := 134;

Torbeevo_temper[18].temp_name := 'T_WinCC_7';
Torbeevo_temper[18].temp_coment := 'Помещение 7 (пропиленгликоль)';
Torbeevo_temper[18].reg_adress := 136;

Torbeevo_temper[19].temp_name := 'T_WinCC_8_1';
Torbeevo_temper[19].temp_coment := 'Коридор 8 ДТ-1';
Torbeevo_temper[19].reg_adress := 138;

Torbeevo_temper[20].temp_name := 'T_WinCC_8_2';
Torbeevo_temper[20].temp_coment := 'Коридор 8 ДТ-2';
Torbeevo_temper[20].reg_adress := 140;

Torbeevo_temper[21].temp_name := 'T_WinCC_8_3';
Torbeevo_temper[21].temp_coment := 'Коридор 8 ДТ-3';
Torbeevo_temper[21].reg_adress := 142;

Torbeevo_temper[22].temp_name := 'T_WinCC_8_4';
Torbeevo_temper[22].temp_coment := 'Коридор 8 ДТ-4';
Torbeevo_temper[22].reg_adress := 144;

Torbeevo_temper[23].temp_name := 'T_WinCC_8_5';
Torbeevo_temper[23].temp_coment := 'Коридор 8 ДТ-5';
Torbeevo_temper[23].reg_adress := 146;

Torbeevo_temper[24].temp_name := 'T_WinCC_8_6';
Torbeevo_temper[24].temp_coment := 'Коридор 8 ДТ-6';
Torbeevo_temper[24].reg_adress := 148;

Torbeevo_temper[25].temp_name := 'T_WinCC_8_7';
Torbeevo_temper[25].temp_coment := 'Коридор 8 ДТ-7';
Torbeevo_temper[25].reg_adress := 150;

Torbeevo_temper[26].temp_name := 'T_WinCC_8_8';
Torbeevo_temper[26].temp_coment := 'Коридор 8 ДТ-8';
Torbeevo_temper[26].reg_adress := 152;

Torbeevo_temper[27].temp_name := 'T_WinCC_8_9';
Torbeevo_temper[27].temp_coment := 'Коридор 8 ДТ-9';
Torbeevo_temper[27].reg_adress := 154;

Torbeevo_temper[28].temp_name := 'T_WinCC_8_10';
Torbeevo_temper[28].temp_coment := 'Коридор 8 ДТ-10';
Torbeevo_temper[28].reg_adress := 156;

Torbeevo_temper[29].temp_name := 'T_WinCC_8_11';
Torbeevo_temper[29].temp_coment := 'Коридор 8 ДТ-11';
Torbeevo_temper[29].reg_adress := 158;

Torbeevo_temper[30].temp_name := 'T_WinCC_8_12';
Torbeevo_temper[30].temp_coment := 'Коридор 8 ДТ-12';
Torbeevo_temper[30].reg_adress := 160;

Torbeevo_temper[31].temp_name := 'T_WinCC_8_13';
Torbeevo_temper[31].temp_coment := 'Коридор 8 ДТ-13';
Torbeevo_temper[31].reg_adress := 162;

Torbeevo_temper[32].temp_name := 'T_WinCC_9_0';
Torbeevo_temper[32].temp_coment := 'Помещение 9 ДТ-0';
Torbeevo_temper[32].reg_adress := 164;

Torbeevo_temper[33].temp_name := 'T_WinCC_9_1';
Torbeevo_temper[33].temp_coment := 'Помещение 9 ДТ-1';
Torbeevo_temper[33].reg_adress := 166;

Torbeevo_temper[34].temp_name := 'T_WinCC_9_4';
Torbeevo_temper[34].temp_coment := 'Помещение 9 ДТ-4';
Torbeevo_temper[34].reg_adress := 168;

Torbeevo_temper[35].temp_name := 'T_WinCC_10_0';
Torbeevo_temper[35].temp_coment := 'Помещение 10 ДТ-0';
Torbeevo_temper[35].reg_adress := 170;

Torbeevo_temper[36].temp_name := 'T_WinCC_10_1';
Torbeevo_temper[36].temp_coment := 'Помещение 10 ДТ-1';
Torbeevo_temper[36].reg_adress := 172;

Torbeevo_temper[37].temp_name := 'T_WinCC_10_2';
Torbeevo_temper[37].temp_coment := 'Помещение 10 ДТ-2';
Torbeevo_temper[37].reg_adress := 174;

Torbeevo_temper[38].temp_name := 'T_WinCC_11';
Torbeevo_temper[38].temp_coment := 'Помещение 11 (пропиленгликоль)';
Torbeevo_temper[38].reg_adress := 176;

Torbeevo_temper[39].temp_name := 'T_WinCC_12';
Torbeevo_temper[39].temp_coment := 'Помещение 12 (пропиленгликоль)';
Torbeevo_temper[39].reg_adress := 178;

Torbeevo_temper[40].temp_name := 'T_WinCC_13';
Torbeevo_temper[40].temp_coment := 'Помещение 13 (пропиленгликоль)';
Torbeevo_temper[40].reg_adress := 180;

Torbeevo_temper[41].temp_name := 'T_WinCC_15_0';
Torbeevo_temper[41].temp_coment := 'Помещение 15 (пропиленгликоль) ДТ-0';
Torbeevo_temper[41].reg_adress := 182;

Torbeevo_temper[42].temp_name := 'T_WinCC_15_1_0';
Torbeevo_temper[42].temp_coment := 'Помещение 15.1 ДТ-0';
Torbeevo_temper[42].reg_adress := 184;

Torbeevo_temper[43].temp_name := 'T_WinCC_15_1_2';
Torbeevo_temper[43].temp_coment := 'Помещение 15.1 ДТ-2';
Torbeevo_temper[43].reg_adress := 186;

Torbeevo_temper[44].temp_name := 'T_WinCC_15_1_4';
Torbeevo_temper[44].temp_coment := 'Помещение 15.1 ДТ-4';
Torbeevo_temper[44].reg_adress := 188;

Torbeevo_temper[45].temp_name := 'T_WinCC_15_2';
Torbeevo_temper[45].temp_coment := 'Помещение 15 (пропиленгликоль) ДТ-2';
Torbeevo_temper[45].reg_adress := 190;

Torbeevo_temper[46].temp_name := 'T_WinCC_15_4';
Torbeevo_temper[46].temp_coment := 'Помещение 15 (пропиленгликоль) ДТ-4';
Torbeevo_temper[46].reg_adress := 192;

Torbeevo_temper[47].temp_name := 'T_WinCC_16_0';
Torbeevo_temper[47].temp_coment := 'Помещение 16 (пропиленгликоль) ДТ-0';
Torbeevo_temper[47].reg_adress := 194;

Torbeevo_temper[48].temp_name := 'T_WinCC_16_1_1';
Torbeevo_temper[48].temp_coment := 'Помещение 16.1';
Torbeevo_temper[48].reg_adress := 196;

Torbeevo_temper[49].temp_name := 'T_WinCC_16_1';
Torbeevo_temper[49].temp_coment := 'Помещение 16 (пропиленгликоль) ДТ-1';
Torbeevo_temper[49].reg_adress := 198;

Torbeevo_temper[50].temp_name := 'T_WinCC_16_3';
Torbeevo_temper[50].temp_coment := 'Помещение 16 (пропиленгликоль) ДТ-3';
Torbeevo_temper[50].reg_adress := 200;

Torbeevo_temper[51].temp_name := 'T_WinCC_18';
Torbeevo_temper[51].temp_coment := 'Помещение 18 (пропиленгликоль)';
Torbeevo_temper[51].reg_adress := 202;

Torbeevo_temper[52].temp_name := 'T_WinCC_19_0';
Torbeevo_temper[52].temp_coment := 'Помещение 19 (пропиленгликоль) ДТ-0';
Torbeevo_temper[52].reg_adress := 204;

Torbeevo_temper[53].temp_name := 'T_WinCC_19_1';
Torbeevo_temper[53].temp_coment := 'Помещение 19 (пропиленгликоль) ДТ-1';
Torbeevo_temper[53].reg_adress := 206;

Torbeevo_temper[54].temp_name := 'T_WinCC_19_2';
Torbeevo_temper[54].temp_coment := 'Помещение 19 (пропиленгликоль) ДТ-2';
Torbeevo_temper[54].reg_adress := 208;

Torbeevo_temper[55].temp_name := 'T_WinCC_19X_0';
Torbeevo_temper[55].temp_coment := 'Помещение 19Х (аммиак) ДТ-0';
Torbeevo_temper[55].reg_adress := 210;

Torbeevo_temper[56].temp_name := 'T_WinCC_19X_1';
Torbeevo_temper[56].temp_coment := 'Помещение 19Х (аммиак) ДТ-1';
Torbeevo_temper[56].reg_adress := 212;

Torbeevo_temper[57].temp_name := 'T_WinCC_19X_2';
Torbeevo_temper[57].temp_coment := 'Помещение 19Х (аммиак) ДТ-2';
Torbeevo_temper[57].reg_adress := 214;

Torbeevo_temper[58].temp_name := 'T_WinCC_20';
Torbeevo_temper[58].temp_coment := 'Помещение 3, 20 (пропиленгликоль) ДТ-20.0';
Torbeevo_temper[58].reg_adress := 216;

Torbeevo_temper[59].temp_name := 'T_WinCC_25';
Torbeevo_temper[59].temp_coment := 'Помещение 25 (пропиленгликоль)';
Torbeevo_temper[59].reg_adress := 218;

Torbeevo_temper[60].temp_name := 'T_WinCC_25X';
Torbeevo_temper[60].temp_coment := 'Помещение 25Х (аммиак)';
Torbeevo_temper[60].reg_adress := 220;

Torbeevo_temper[61].temp_name := 'T_WinCC_26X';
Torbeevo_temper[61].temp_coment := 'Помещение 26Х (аммиак)';
Torbeevo_temper[61].reg_adress := 222;

Torbeevo_temper[62].temp_name := 'T_WinCC_27X';
Torbeevo_temper[62].temp_coment := 'Помещение 27Х (аммиак)';
Torbeevo_temper[62].reg_adress := 224;

Torbeevo_temper[63].temp_name := 'T_WinCC_27XA';
Torbeevo_temper[63].temp_coment := 'Помещение 27ХА (аммиак)';
Torbeevo_temper[63].reg_adress := 226;

Torbeevo_temper[64].temp_name := 'T_WinCC_28X';
Torbeevo_temper[64].temp_coment := 'Помещение 28Х (аммиак)';
Torbeevo_temper[64].reg_adress := 228;

Torbeevo_temper[65].temp_name := 'T_WinCC_29X';
Torbeevo_temper[65].temp_coment := 'Помещение 29Х (аммиак)';
Torbeevo_temper[65].reg_adress := 230;

Torbeevo_temper[66].temp_name := 'T_WinCC_30B_0';
Torbeevo_temper[66].temp_coment := 'Помещение 30Б (аммиак) ДТ-0';
Torbeevo_temper[66].reg_adress := 232;

Torbeevo_temper[67].temp_name := 'T_WinCC_30B_1';
Torbeevo_temper[67].temp_coment := 'Помещение 30Б (аммиак) ДТ-1';
Torbeevo_temper[67].reg_adress := 234;

Torbeevo_temper[68].temp_name := 'T_WinCC_30B_2';
Torbeevo_temper[68].temp_coment := 'Помещение 30Б (аммиак) ДТ-2';
Torbeevo_temper[68].reg_adress := 236;

Torbeevo_temper[69].temp_name := 'T_WinCC_30X';
Torbeevo_temper[69].temp_coment := 'Помещение 30Х (аммиак)';
Torbeevo_temper[69].reg_adress := 238;

Torbeevo_temper[70].temp_name := 'T_WinCC_32P_0';
Torbeevo_temper[70].temp_coment := 'Помещение 30П (пропиленгликоль) ДТ-0';
Torbeevo_temper[70].reg_adress := 240;

Torbeevo_temper[71].temp_name := 'T_WinCC_32P_1';
Torbeevo_temper[71].temp_coment := 'Помещение 30П (пропиленгликоль) ДТ-1';
Torbeevo_temper[71].reg_adress := 242;

Torbeevo_temper[72].temp_name := 'T_WinCC_32P_2';
Torbeevo_temper[72].temp_coment := 'Помещение 30П (пропиленгликоль) ДТ-2';
Torbeevo_temper[72].reg_adress := 244;

Torbeevo_temper[73].temp_name := 'T_WinCC_32X';
Torbeevo_temper[73].temp_coment := 'Помещение 32Х (пропиленгликоль)';
Torbeevo_temper[73].reg_adress := 246;

Torbeevo_temper[74].temp_name := 'T_WinCC_33X';
Torbeevo_temper[74].temp_coment := 'Помещение 33Х (аммиак)';
Torbeevo_temper[74].reg_adress := 248;

Torbeevo_temper[75].temp_name := 'T_WinCC_34X';
Torbeevo_temper[75].temp_coment := 'Помещение 34Х (аммиак)';
Torbeevo_temper[75].reg_adress := 250;

Torbeevo_temper[76].temp_name := 'T_WinCC_44';
Torbeevo_temper[76].temp_coment := 'Помещение 44 (пропиленгликоль)';
Torbeevo_temper[76].reg_adress := 252;

Torbeevo_temper[77].temp_name := 'T_WinCC_49_0';
Torbeevo_temper[77].temp_coment := 'Помещение 49 (пропиленгликоль) ДТ-0';
Torbeevo_temper[77].reg_adress := 254;

Torbeevo_temper[78].temp_name := 'T_WinCC_49_1';
Torbeevo_temper[78].temp_coment := 'Помещение 49 (пропиленгликоль) ДТ-1';
Torbeevo_temper[78].reg_adress := 256;

Torbeevo_temper[79].temp_name := 'T_WinCC_49_2';
Torbeevo_temper[79].temp_coment := 'Помещение 49 (пропиленгликоль) ДТ-2';
Torbeevo_temper[79].reg_adress := 258;

Torbeevo_temper[80].temp_name := 'T_OPC_21_1';
Torbeevo_temper[80].temp_coment := 'Склад специй ДТ-1';
Torbeevo_temper[80].reg_adress := 260;

Torbeevo_temper[81].temp_name := 'T_OPC_21_2';
Torbeevo_temper[81].temp_coment := 'Склад специй ДТ-2';
Torbeevo_temper[81].reg_adress := 262;

Torbeevo_temper[82].temp_name := 'T_OPC_21_3';
Torbeevo_temper[82].temp_coment := 'Склад специй ДТ-3';
Torbeevo_temper[82].reg_adress := 264;

Torbeevo_temper[83].temp_name := 'T_OPC_21_4';
Torbeevo_temper[83].temp_coment := 'Склад специй ДТ-4';
Torbeevo_temper[83].reg_adress := 266;

Torbeevo_temper[84].temp_name := 'T_OPC_21_5';
Torbeevo_temper[84].temp_coment := 'Склад специй ДТ-5';
Torbeevo_temper[84].reg_adress := 268;

Torbeevo_temper[85].temp_name := 'T_OPC_1_1';
Torbeevo_temper[85].temp_coment := 'Формовка ДТ-1';
Torbeevo_temper[85].reg_adress := 270;

Torbeevo_temper[86].temp_name := 'T_OPC_1_2';
Torbeevo_temper[86].temp_coment := 'Формовка ДТ-2';
Torbeevo_temper[86].reg_adress := 272;

Torbeevo_temper[87].temp_name := 'T_OPC_1_3';
Torbeevo_temper[87].temp_coment := 'Формовка ДТ-3';
Torbeevo_temper[87].reg_adress := 274;

Torbeevo_temper[88].temp_name := 'T_OPC_1_4';
Torbeevo_temper[88].temp_coment := 'Формовка ДТ-4';
Torbeevo_temper[88].reg_adress := 276;

Torbeevo_temper[89].temp_name := 'T_OPC_1_5';
Torbeevo_temper[89].temp_coment := 'Формовка ДТ-5';
Torbeevo_temper[89].reg_adress := 278;

Torbeevo_temper[90].temp_name := 'T_OPC_2_1';
Torbeevo_temper[90].temp_coment := 'Фаршесоставление ДТ-1';
Torbeevo_temper[90].reg_adress := 280;

Torbeevo_temper[91].temp_name := 'T_OPC_2_2';
Torbeevo_temper[91].temp_coment := 'Фаршесоставление ДТ-2';
Torbeevo_temper[91].reg_adress := 282;

Torbeevo_temper[92].temp_name := 'T_OPC_2_3';
Torbeevo_temper[92].temp_coment := 'Фаршесоставление ДТ-3';
Torbeevo_temper[92].reg_adress := 284;

Torbeevo_temper[93].temp_name := 'T_OPC_2_4';
Torbeevo_temper[93].temp_coment := 'Фаршесоставление ДТ-4';
Torbeevo_temper[93].reg_adress := 286;

Torbeevo_temper[94].temp_name := 'T_OPC_Reserv_1';
Torbeevo_temper[94].temp_coment := 'Резерв ';
Torbeevo_temper[94].reg_adress := 288;

Torbeevo_temper[95].temp_name := 'T_OPC_Reserv_2';
Torbeevo_temper[95].temp_coment := 'Резерв ';
Torbeevo_temper[95].reg_adress := 290;

Torbeevo_temper[96].temp_name := 'T_OPC_4_1';
Torbeevo_temper[96].temp_coment := 'Камера охлаждения вареных колбас и ветчин ДТ-1';
Torbeevo_temper[96].reg_adress := 292;

Torbeevo_temper[97].temp_name := 'T_OPC_4_2';
Torbeevo_temper[97].temp_coment := 'Камера охлаждения вареных колбас и ветчин ДТ-2';
Torbeevo_temper[97].reg_adress := 294;

Torbeevo_temper[98].temp_name := 'T_OPC_4_3';
Torbeevo_temper[98].temp_coment := 'Камера охлаждения вареных колбас и ветчин ДТ-3';
Torbeevo_temper[98].reg_adress := 296;

Torbeevo_temper[99].temp_name := 'T_OPC_4_4';
Torbeevo_temper[99].temp_coment := 'Камера охлаждения вареных колбас и ветчин ДТ-4';
Torbeevo_temper[99].reg_adress := 298;

Torbeevo_temper[100].temp_name := 'T_OPC_5_1';
Torbeevo_temper[100].temp_coment := 'Упаковка, маркировка ДТ-1';
Torbeevo_temper[100].reg_adress := 300;

Torbeevo_temper[101].temp_name := 'T_OPC_5_2';
Torbeevo_temper[101].temp_coment := 'Упаковка, маркировка ДТ-2';
Torbeevo_temper[101].reg_adress := 302;

Torbeevo_temper[102].temp_name := 'T_OPC_6_1';
Torbeevo_temper[102].temp_coment := 'Склад готовой продукции ДТ-1';
Torbeevo_temper[102].reg_adress := 304;

Torbeevo_temper[103].temp_name := 'T_OPC_6_2';
Torbeevo_temper[103].temp_coment := 'Склад готовой продукции ДТ-2';
Torbeevo_temper[103].reg_adress := 306;

Torbeevo_temper[104].temp_name := 'T_OPC_6_3';
Torbeevo_temper[104].temp_coment := 'Склад готовой продукции ДТ-3';
Torbeevo_temper[104].reg_adress := 308;

Torbeevo_temper[105].temp_name := 'T_OPC_7_1';
Torbeevo_temper[105].temp_coment := 'Развитие ДТ-1';
Torbeevo_temper[105].reg_adress := 310;

Torbeevo_temper[106].temp_name := 'T_OPC_7_2';
Torbeevo_temper[106].temp_coment := 'Развитие ДТ-2';
Torbeevo_temper[106].reg_adress := 312;

Torbeevo_temper[107].temp_name := 'T_OPC_7_3';
Torbeevo_temper[107].temp_coment := 'Развитие ДТ-3';
Torbeevo_temper[107].reg_adress := 314;

Torbeevo_temper[108].temp_name := 'T_OPC_7_4';
Torbeevo_temper[108].temp_coment := 'Развитие ДТ-4';
Torbeevo_temper[108].reg_adress := 316;

Torbeevo_temper[109].temp_name := 'T_OPC_49a';
Torbeevo_temper[109].temp_coment := 'Упаковка в/к колбас в гофротару';
Torbeevo_temper[109].reg_adress := 318;

Torbeevo_temper[110].temp_name := 'T_OPC_Reserv_3';
Torbeevo_temper[110].temp_coment := 'Резерв ';
Torbeevo_temper[110].reg_adress := 320;

Torbeevo_temper[111].temp_name := 'T_OPC_7a';
Torbeevo_temper[111].temp_coment := 'Зона упаковки в/к колбас';
Torbeevo_temper[111].reg_adress := 322;

Torbeevo_temper[112].temp_name := 'T_OPC_Reserv_4';
Torbeevo_temper[112].temp_coment := 'Резерв ';
Torbeevo_temper[112].reg_adress := 324;

Torbeevo_temper[113].temp_name := 'T_OPC_13a';
Torbeevo_temper[113].temp_coment := 'Зона составления фарша в/к колбас';
Torbeevo_temper[113].reg_adress := 326;

Torbeevo_temper[114].temp_name := 'T_OPC_Reserv_5';
Torbeevo_temper[114].temp_coment := 'Резерв ';
Torbeevo_temper[114].reg_adress := 328;

Torbeevo_temper[115].temp_name := 'T_OPC_6a';
Torbeevo_temper[115].temp_coment := 'Цех упаковки сосисок';
Torbeevo_temper[115].reg_adress := 330;

Torbeevo_temper[116].temp_name := 'T_OPC_Reserv_6';
Torbeevo_temper[116].temp_coment := 'Резерв ';
Torbeevo_temper[116].reg_adress := 332;

Torbeevo_temper[117].temp_name := 'T_OPC_Reserv_7';
Torbeevo_temper[117].temp_coment := 'Резерв ';
Torbeevo_temper[117].reg_adress := 334;

Torbeevo_temper[118].temp_name := 'T_OPC_Reserv_8';
Torbeevo_temper[118].temp_coment := 'Резерв ';
Torbeevo_temper[118].reg_adress := 336;

Torbeevo_temper[119].temp_name := 'T_OPC_Reserv_9';
Torbeevo_temper[119].temp_coment := 'Резерв ';
Torbeevo_temper[119].reg_adress := 338;

Torbeevo_temper[120].temp_name := 'T_OPC_Reserv_10';
Torbeevo_temper[120].temp_coment := 'Резерв ';
Torbeevo_temper[120].reg_adress := 340;

Torbeevo_temper[121].temp_name := 'T_OPC_Reserv_11';
Torbeevo_temper[121].temp_coment := 'Резерв ';
Torbeevo_temper[121].reg_adress := 342;

Torbeevo_temper[122].temp_name := 'T_OPC_Reserv_12';
Torbeevo_temper[122].temp_coment := 'Резерв ';
Torbeevo_temper[122].reg_adress := 344;

Torbeevo_temper[123].temp_name := 'T_OPC_Reserv_13';
Torbeevo_temper[123].temp_coment := 'Резерв ';
Torbeevo_temper[123].reg_adress := 346;

Torbeevo_temper[124].temp_name := 'T_OPC_2a3';
Torbeevo_temper[124].temp_coment := 'Формовка ветчин';
Torbeevo_temper[124].reg_adress := 348;

Torbeevo_temper[125].temp_name := 'T_OPC_Reserv_14';
Torbeevo_temper[125].temp_coment := 'Резерв ';
Torbeevo_temper[125].reg_adress := 350;

Torbeevo_temper[126].temp_name := 'T_OPC_Reserv_15';
Torbeevo_temper[126].temp_coment := 'Резерв ';
Torbeevo_temper[126].reg_adress := 352;

Torbeevo_temper[127].temp_name := 'T_OPC_Reserv_16';
Torbeevo_temper[127].temp_coment := 'Резерв ';
Torbeevo_temper[127].reg_adress := 354;

Torbeevo_temper[128].temp_name := 'T_OPC_Reserv_17';
Torbeevo_temper[128].temp_coment := 'Резерв ';
Torbeevo_temper[128].reg_adress := 356;

Torbeevo_temper[129].temp_name := 'T_OPC_Reserv_18';
Torbeevo_temper[129].temp_coment := 'Резерв ';
Torbeevo_temper[129].reg_adress := 358;


Atajschego_temper[0].temp_name := 'A_T_OPC_7_1';
Atajschego_temper[0].temp_coment := 'Помещение 7 ДТ-1';
Atajschego_temper[0].reg_adress := 100;

Atajschego_temper[1].temp_name := 'A_T_OPC_7_2';
Atajschego_temper[1].temp_coment := 'Помещение 7 ДТ-2';
Atajschego_temper[1].reg_adress := 102;

Atajschego_temper[2].temp_name := 'A_T_OPC_7_3';
Atajschego_temper[2].temp_coment := 'Помещение 7 ДТ-3';
Atajschego_temper[2].reg_adress := 104;

Atajschego_temper[3].temp_name := 'A_T_OPC_7_4';
Atajschego_temper[3].temp_coment := 'Помещение 7 ДТ-4';
Atajschego_temper[3].reg_adress := 106;

Atajschego_temper[4].temp_name := 'A_T_OPC_7_5';
Atajschego_temper[4].temp_coment := 'Помещение 7 ДТ-5';
Atajschego_temper[4].reg_adress := 108;

Atajschego_temper[5].temp_name := 'A_T_OPC_7_6';
Atajschego_temper[5].temp_coment := 'Помещение 7 ДТ-6';
Atajschego_temper[5].reg_adress := 110;

Atajschego_temper[6].temp_name := 'A_T_OPC_7_7';
Atajschego_temper[6].temp_coment := 'Помещение 7 ДТ-7';
Atajschego_temper[6].reg_adress := 112;

Atajschego_temper[7].temp_name := 'A_T_OPC_9_1';
Atajschego_temper[7].temp_coment := 'Помещение 9 (Обвалка) ДТ-1';
Atajschego_temper[7].reg_adress := 114;

Atajschego_temper[8].temp_name := 'A_T_OPC_9_2';
Atajschego_temper[8].temp_coment := 'Помещение 9 (Обвалка) ДТ-2';
Atajschego_temper[8].reg_adress := 116;

Atajschego_temper[9].temp_name := 'A_T_OPC_9_3';
Atajschego_temper[9].temp_coment := 'Помещение 9 (Обвалка) ДТ-3';
Atajschego_temper[9].reg_adress := 118;

Atajschego_temper[10].temp_name := 'A_T_OPC_9_4';
Atajschego_temper[10].temp_coment := 'Помещение 9 (Обвалка) ДТ-4';
Atajschego_temper[10].reg_adress := 120;

Atajschego_temper[11].temp_name := 'A_T_OPC_7_2_1';
Atajschego_temper[11].temp_coment := 'Помещение 7.2 ДТ-1';
Atajschego_temper[11].reg_adress := 122;

Atajschego_temper[12].temp_name := 'A_T_OPC_7_2_2';
Atajschego_temper[12].temp_coment := 'Помещение 7.2 ДТ-2';
Atajschego_temper[12].reg_adress := 124;

Atajschego_temper[13].temp_name := 'A_T_OPC_7_2_3';
Atajschego_temper[13].temp_coment := 'Помещение 7.2 ДТ-3';
Atajschego_temper[13].reg_adress := 126;

Atajschego_temper[14].temp_name := 'A_T_OPC_7_2_4';
Atajschego_temper[14].temp_coment := 'Помещение 7.2 ДТ-4';
Atajschego_temper[14].reg_adress := 128;

Atajschego_temper[15].temp_name := 'A_T_OPC_7_2_5';
Atajschego_temper[15].temp_coment := 'Помещение 7.2 ДТ-5';
Atajschego_temper[15].reg_adress := 130;

Atajschego_temper[16].temp_name := 'A_T_OPC_7_2_6';
Atajschego_temper[16].temp_coment := 'Помещение 7.2 ДТ-6';
Atajschego_temper[16].reg_adress := 132;

Atajschego_temper[17].temp_name := 'A_T_OPC_7_2_7';
Atajschego_temper[17].temp_coment := 'Помещение 7.2 ДТ-7';
Atajschego_temper[17].reg_adress := 134;

Atajschego_temper[18].temp_name := 'A_T_OPC_7_2_8';
Atajschego_temper[18].temp_coment := 'Помещение 7.2 ДТ-8';
Atajschego_temper[18].reg_adress := 136;

Atajschego_temper[19].temp_name := 'A_T_OPC_7_2_9';
Atajschego_temper[19].temp_coment := 'Помещение 7.2 ДТ-9';
Atajschego_temper[19].reg_adress := 138;

Atajschego_temper[20].temp_name := 'A_T_OPC_7_2_10';
Atajschego_temper[20].temp_coment := 'Помещение 7.2 ДТ-10';
Atajschego_temper[20].reg_adress := 140;

Atajschego_temper[21].temp_name := 'A_T_OPC_13_1';
Atajschego_temper[21].temp_coment := 'Помещение 13 (аммиачный испаритель) ДТ-1';
Atajschego_temper[21].reg_adress := 142;

Atajschego_temper[22].temp_name := 'A_T_OPC_13_2';
Atajschego_temper[22].temp_coment := '(Резерв) Помещение 13 (аммиачный испаритель) ДТ-2';
Atajschego_temper[22].reg_adress := 144;

Atajschego_temper[23].temp_name := 'A_T_OPC_13_3';
Atajschego_temper[23].temp_coment := '(Резерв) Помещение 13 (аммиачный испаритель) ДТ-3';
Atajschego_temper[23].reg_adress := 146;

Atajschego_temper[24].temp_name := 'A_T_OPC_13_4';
Atajschego_temper[24].temp_coment := '(Резерв) Помещение 13 (аммиачный испаритель) ДТ-4';
Atajschego_temper[24].reg_adress := 148;

Atajschego_temper[25].temp_name := 'A_T_OPC_13_5';
Atajschego_temper[25].temp_coment := '(Резерв) Помещение 13 (аммиачный испаритель) ДТ-5';
Atajschego_temper[25].reg_adress := 150;

Atajschego_temper[26].temp_name := 'A_T_OPC_12_1';
Atajschego_temper[26].temp_coment := 'Помещение 12 (аммиачный испаритель) ДТ-1';
Atajschego_temper[26].reg_adress := 152;

Atajschego_temper[27].temp_name := 'A_T_OPC_12_2';
Atajschego_temper[27].temp_coment := 'Помещение 12 (аммиачный испаритель) ДТ-2';
Atajschego_temper[27].reg_adress := 154;

Atajschego_temper[28].temp_name := 'A_T_OPC_12_3';
Atajschego_temper[28].temp_coment := 'Помещение 12 (аммиачный испаритель) ДТ-3';
Atajschego_temper[28].reg_adress := 156;

Atajschego_temper[29].temp_name := 'A_T_OPC_11_1';
Atajschego_temper[29].temp_coment := 'Помещение 11 (аммиачный испаритель) ДТ-1';
Atajschego_temper[29].reg_adress := 158;

Atajschego_temper[30].temp_name := 'A_T_OPC_11_2';
Atajschego_temper[30].temp_coment := 'Помещение 11 (аммиачный испаритель) ДТ-2';
Atajschego_temper[30].reg_adress := 160;

Atajschego_temper[31].temp_name := 'A_T_OPC_11_3';
Atajschego_temper[31].temp_coment := 'Помещение 11 (аммиачный испаритель) ДТ-3';
Atajschego_temper[31].reg_adress := 162;

Atajschego_temper[32].temp_name := 'A_T_OPC_9_2_1';
Atajschego_temper[32].temp_coment := 'Помещение 9.2 (Разделка охлажденной свинины) ДТ-1';
Atajschego_temper[32].reg_adress := 164;

Atajschego_temper[33].temp_name := 'A_T_OPC_9_2_2';
Atajschego_temper[33].temp_coment := 'Помещение 9.2 (Разделка охлажденной свинины) ДТ-2';
Atajschego_temper[33].reg_adress := 166;

Atajschego_temper[34].temp_name := 'A_T_OPC_9_2_3';
Atajschego_temper[34].temp_coment := 'Помещение 9.2 (Разделка охлажденной свинины) ДТ-3';
Atajschego_temper[34].reg_adress := 168;

Atajschego_temper[35].temp_name := 'A_T_OPC_9_2_4';
Atajschego_temper[35].temp_coment := 'Помещение 9.2 (Разделка охлажденной свинины) ДТ-4';
Atajschego_temper[35].reg_adress := 170;

Atajschego_temper[36].temp_name := 'A_T_OPC_9_2_5';
Atajschego_temper[36].temp_coment := 'Помещение 9.2 (Разделка охлажденной свинины) ДТ-5';
Atajschego_temper[36].reg_adress := 172;

Atajschego_temper[37].temp_name := 'A_T_OPC_9_2_6';
Atajschego_temper[37].temp_coment := 'Помещение 9.2 (Разделка охлажденной свинины) ДТ-6';
Atajschego_temper[37].reg_adress := 174;

Atajschego_temper[38].temp_name := 'A_T_OPC_15_2_1';
Atajschego_temper[38].temp_coment := 'Помещение 15.2 (Камера охлаждения ливерных колбас) ДТ-1';
Atajschego_temper[38].reg_adress := 176;

Atajschego_temper[39].temp_name := 'A_T_OPC_15_2_2';
Atajschego_temper[39].temp_coment := 'Помещение 15.2 (Камера охлаждения ливерных колбас) ДТ-2';
Atajschego_temper[39].reg_adress := 178;

Atajschego_temper[40].temp_name := 'A_T_OPC_15_2_4';
Atajschego_temper[40].temp_coment := 'Помещение 15.2 (Камера охлаждения ливерных колбас) ДТ-4';
Atajschego_temper[40].reg_adress := 180;

Atajschego_temper[41].temp_name := 'A_T_OPC_15_2_5';
Atajschego_temper[41].temp_coment := 'Помещение 15.2 (Камера охлаждения ливерных колбас) ДТ-5';
Atajschego_temper[41].reg_adress := 182;

Atajschego_temper[42].temp_name := 'A_T_OPC_15_2_6';
Atajschego_temper[42].temp_coment := 'Помещение 15.2 (Камера охлаждения ливерных колбас) ДТ-6';
Atajschego_temper[42].reg_adress := 184;

Atajschego_temper[43].temp_name := 'A_T_OPC_15_3_1_1';
Atajschego_temper[43].temp_coment := 'Помещение 15.3 (Склад готовой продукции) ДТ-1.1';
Atajschego_temper[43].reg_adress := 186;

Atajschego_temper[44].temp_name := 'A_T_OPC_15_3_1_2';
Atajschego_temper[44].temp_coment := 'Помещение 15.3  (Склад готовой продукции) ДТ-1.2';
Atajschego_temper[44].reg_adress := 188;

Atajschego_temper[45].temp_name := 'A_T_OPC_15_3_2_1';
Atajschego_temper[45].temp_coment := 'Помещение 15.3 (Склад готовой продукции) ДТ-2.1';
Atajschego_temper[45].reg_adress := 190;

Atajschego_temper[46].temp_name := 'A_T_OPC_15_3_2_2';
Atajschego_temper[46].temp_coment := 'Помещение 15.3  (Склад готовой продукции) ДТ-2.2';
Atajschego_temper[46].reg_adress := 192;

Atajschego_temper[47].temp_name := 'A_T_OPC_16_1';
Atajschego_temper[47].temp_coment := 'Помещение 16 ДТ-1';
Atajschego_temper[47].reg_adress := 194;

Atajschego_temper[48].temp_name := 'A_T_OPC_16_2';
Atajschego_temper[48].temp_coment := 'Помещение 16 ДТ-2';
Atajschego_temper[48].reg_adress := 196;

Atajschego_temper[49].temp_name := 'A_T_OPC_16_3';
Atajschego_temper[49].temp_coment := 'Помещение 16 ДТ-3';
Atajschego_temper[49].reg_adress := 198;

Atajschego_temper[50].temp_name := 'A_T_OPC_16_4';
Atajschego_temper[50].temp_coment := 'Помещение 16 ДТ-4';
Atajschego_temper[50].reg_adress := 200;

Atajschego_temper[51].temp_name := 'A_T_OPC_16_5';
Atajschego_temper[51].temp_coment := 'Помещение 16 ДТ-5';
Atajschego_temper[51].reg_adress := 202;

Atajschego_temper[52].temp_name := 'A_T_OPC_34_1';
Atajschego_temper[52].temp_coment := 'Камера 34 ДТ-1';
Atajschego_temper[52].reg_adress := 204;

Atajschego_temper[53].temp_name := 'A_T_OPC_34_2';
Atajschego_temper[53].temp_coment := 'Камера 34 ДТ-2';
Atajschego_temper[53].reg_adress := 206;

Atajschego_temper[54].temp_name := 'A_T_OPC_34_3';
Atajschego_temper[54].temp_coment := 'Камера 34 ДТ-3';
Atajschego_temper[54].reg_adress := 208;

Atajschego_temper[55].temp_name := 'A_T_OPC_34_4';
Atajschego_temper[55].temp_coment := 'Камера 34 ДТ-4';
Atajschego_temper[55].reg_adress := 210;

Atajschego_temper[56].temp_name := 'A_T_OPC_35_1';
Atajschego_temper[56].temp_coment := 'Камера 35 ДТ-1';
Atajschego_temper[56].reg_adress := 212;

Atajschego_temper[57].temp_name := 'A_T_OPC_35_2';
Atajschego_temper[57].temp_coment := 'Камера 35 ДТ-2';
Atajschego_temper[57].reg_adress := 214;

Atajschego_temper[58].temp_name := 'A_T_OPC_36_1';
Atajschego_temper[58].temp_coment := 'Камера 36 ДТ-1';
Atajschego_temper[58].reg_adress := 216;

Atajschego_temper[59].temp_name := 'A_T_OPC_36_2';
Atajschego_temper[59].temp_coment := 'Камера 36 ДТ-2';
Atajschego_temper[59].reg_adress := 218;

end;

function StTime: string;
begin
  result :=
FormatDateTime('yyyy', Date) + '-' +
FormatDateTime('mm', Date) + '-' +
FormatDateTime('dd', Date) + ' ' +

FormatDateTime('hh', Time)+':'+
FormatDateTime('nn', Time)+':'+
FormatDateTime('ss', Time)+'.'+
FormatDateTime('zzz', Time);

end;

procedure SaveLog;
var
  stDate, stTime:string;
begin
  // Сохранение лог файла.
 DateTimeToString(stDate,'yyyy_mm_dd ',Date);
 DateTimeToString(stTime,'hh_nn_ss_zzz',Time);
 try
   form1.mLog.Lines.SaveToFile('Log_'+stDate+stTime+'.txt');
 finally
   form1.mLog.Lines.Clear;
 end;

end;

// ==================================================================
function RegistersToReal(w1, w2: word): real;
var
  dw: dword;
  p_real: ^Single;
begin
  dw := w2 * 65536 + w1;
  p_real := Addr(dw);
  result :=  p_real^
end;

procedure ReadDataPLC(var plc :TPLC;
                      FirstReg, LengthReg, FirstVal, LengthVal: integer;
                      memo: TMemo;
                      var MdBClient: TIdModBusClient;
                      var T: array of T_Temperature);
var
  Data: array[0..1024] of Word;
  i: Integer;
begin

  if (LengthReg > 0) and plc.plc_v_seti then
  begin

    MdBClient.Host := plc.Host;
    try
      try
        MdBClient.Connect;
        memo.Lines.Add(StTime + ' - ' + plc.Host + ' - Register value(s) read:');
        memo.Lines.Add(plc.Host + ' - '+'FirstReg = ' +  IntToStr(FirstReg));
        memo.Lines.Add(plc.Host + ' - '+'LengthReg = ' +  IntToStr(LengthReg));
        MdBClient.ReadHoldingRegisters(FirstReg+1, LengthReg, Data);
        Application.ProcessMessages;

        {
        for i := 0 to (LengthReg - 1) do
          memo.Lines.Add(IntToStr(FirstReg + i) +
                                  ': '  +
                                  IntToStr(Data[i]));
        }
        for i := 0 to LengthVal - 1 do
          begin
            T[i + FirstVal].value := RegistersToReal(Data[2*i],
                                          Data[2*i + 1]);
            // memo.Lines.Add(IntToStr(i + FirstVal) + '  -  ' +
            //                T[i + FirstVal].temp_name + ' = ' +
            //                FloatToStrF(T[i + FirstVal].value, ffGeneral, 5, 1));
          end;

      except
        memo.Lines.Add(StTime + ' - ' + plc.Host + ' - PLC read operation failed!');
        plc.plc_v_seti := false;
      end;
    finally
      MdBClient.Disconnect;
    end;
  end;


end;


procedure TForm1.n_readClick(Sender: TObject);
begin
   ReadDataPLC(Torbeevo, 100, 100, 0, 50,
               mLog, MdBClient_Torb,
               Torbeevo_temper);
  { ReadDataPLC(Atajschego, 100, 100,
               mLog, MdBClient_At,
               Atajschego_temper);       }
end;



// ==================================================================

function Ping(Host: string):boolean;
 var hIP: THandle;
     Icmp_rep: TIcmp_echo_reply;
     IPAddr: TIPAddr;
begin
  try
    form1.mLog.Lines.Add(StTime + ' - ' + 'Ping = ' + Host);
    Icmp_rep.DataSize:= 0;
    IPAddr:= inet_addr(PAnsiChar(AnsiString(Host)));

    hIP:= IcmpCreateFile();
    IcmpSendEcho(hIP,IPAddr,nil,0,nil,@Icmp_rep,sizeof(Icmp_rep),3000);
    IcmpCloseHandle(hIP);
    Application.ProcessMessages;

    result:= (Icmp_rep.RoundTripTime < 2000) and (Icmp_rep.Status = IP_SUCCESS);
  except
    result:= false;
  end;

  if result then
      form1.mLog.Lines.Add(StTime + ' - ' + Host + ' в сети')
  else
      form1.mLog.Lines.Add(StTime + ' - ' + Host + ' не в сети');

end;


procedure PLC_Ping(var plc: TPLC; plc_name: string; StatusPanel: TStatusPanel);
begin
// form1.mLog.Lines.Add(plc.Host + ' = ' + intToStr(plc.skip_ping));
  if (plc.skip_ping <> 0) then
    begin
      dec(plc.skip_ping);
      if plc.skip_ping < 0 then
        plc.skip_ping := 0;
    end
  else
    begin
      plc.skip_ping := 4;
      plc.plc_v_seti := False;
      if Ping(plc.Host) then
        begin
          plc.plc_v_seti := True;
          StatusPanel.Text := plc_name + ' ПЛК в сети';
          plc.skip_ping := 2;
        end
      else
        begin
          plc.plc_v_seti := False;
          StatusPanel.Text := plc_name + ' ПЛК не в сети';
          plc.skip_ping := 6;
        end
    end;
end;


procedure TForm1.TimerPingTimer(Sender: TObject);
begin
  // Вывод времени и даты на панель статуса
  Form1.StatusBar1.Panels[0].Text:='Сегодня '+
  FormatDateTime('d', Date)+'.'+
  FormatDateTime('m', Date)+'.'+
  FormatDateTime('yyyy', Date)+
  '    '+'Время '+
  FormatDateTime('h', Time)+':'+
  FormatDateTime('nn', Time)+':'+
  FormatDateTime('ss', Time);

end;


// ===================================================================
procedure BaseCreate(var Base : TSQLiteDatabase;BaseName: string;
                      T: array of T_Temperature; var plc: TPLC);
var s:string;
  i: Integer;
begin
  try
  Base:=TSQLiteDatabase.Create(BaseName + '.sqlite');//указываем файл БД
  form1.mLog.Lines.Add('Открыта база - ' + BaseName);
  if not Base.TableExists('Temperature') then //таблица в БД отсутствует - создаем
    begin
      s:='CREATE TABLE Temperature ';
      s:=s+'(id INTEGER PRIMARY KEY AUTOINCREMENT,';
      s:=s+'Time TEXT';
      for i := 0 to length(T) - 1 do
          s:= s + ',' + T[i].temp_name + ' REAL';
      s:=s+')';
      Base.ExecSQL(s);
      form1.mLog.Lines.Add('Создана таблица Temperature в базе - ' + BaseName);
    end;
  plc.sqlite_base_open := True;

  except  on E : Exception do
    begin
      form1.mLog.Lines.Add(BaseName +
                                '- Во время создания таблицы произошла ошибка:');
      form1.mLog.Lines.Add(concat(E.ClassName,' : ',E.Message));
      plc.sqlite_base_open := False;
      Base.Destroy;
    end;
  end;
end;

procedure BaseWrite(Base : TSQLiteDatabase;BaseName: string;
                      T: array of T_Temperature; var plc: TPLC);
var s, s_time:string;
    i: integer;
begin

s_time :=
FormatDateTime('yyyy', Date) + '-' +
FormatDateTime('mm', Date) + '-' +
FormatDateTime('dd', Date) + ' ' +

FormatDateTime('hh', Time)+':'+
FormatDateTime('nn', Time)+':'+
FormatDateTime('ss', Time)+'.'+
FormatDateTime('zzz', Time);

  if plc.sqlite_base_open then
    begin
      try
        // Base:=TSQLiteDatabase.Create(BaseName + '.sqlite');//указываем файл БД
        //добавляем в базу данных новую запись
        s:='INSERT INTO Temperature ';
        s:=s+'(Time';
        for i := 0 to length(T) - 1 do
          s:= s + ', ' + T[i].temp_name;
        s:=s+') ';
        s:=s+'VALUES ("'+s_time+'"';
        for i := 0 to length(T) - 1 do
          s:= s + ', ' + FloatToStrF(T[i].value, ffGeneral, 6, 2);
        s:=s+')';
        Base.ExecSQL(s);
        form1.mLog.Lines.Add(s_time + ' - Добавлена запись в базу - ' + BaseName);
        form1.mLog.Lines.Add(' ');
      except on E : Exception do
        begin
          form1.mLog.Lines.Add(s_time + ' - ' + BaseName +
                                '- Во время добавления в таблицу произошла ошибка:');
          form1.mLog.Lines.Add(concat(E.ClassName,' : ',E.Message));
          plc.sqlite_base_open := False;
          // Base.Destroy;
        end;
      end;
    end;
end;

// ====================================================================


procedure TForm1.FormCreate(Sender: TObject);
begin
   //en_work_net := true;
   SysUtils.DecimalSeparator:='.';
   Torbeevo.Host := '192.168.110.98';
   Atajschego.Host := '192.168.5.242';
   InitTemperature;
   BaseCreate(BaseTorbeevo, 'Torbeevo_temp', Torbeevo_temper, Torbeevo);
   BaseCreate(BaseAtajschego, 'Atajschevo_temp', Atajschego_temper, Atajschego);

end;


procedure TForm1.FormDestroy(Sender: TObject);
begin
   SaveLog;
   if BaseTorbeevo <> nil then freeandnil(BaseTorbeevo);
   if BaseAtajschego <> nil then freeandnil(BaseAtajschego);
end;

procedure TForm1.N2Click(Sender: TObject);
begin
  form1.TimerRead.Enabled := False;
  // form1.TimerPing.Enabled := False;
end;

procedure TForm1.N3Click(Sender: TObject);
begin
  form1.TimerRead.Enabled := True;
  // form1.TimerPing.Enabled := True;
end;

procedure TForm1.n_closeClick(Sender: TObject);
begin
  form1.Close;
end;


procedure TForm1.TimerReadTimer(Sender: TObject);
begin
TimerRead.Enabled := false;

if (mLog.Lines.Count > 10000) then
    SaveLog;

if not Torbeevo.sqlite_base_open then
   BaseCreate(BaseTorbeevo, 'Torbeevo_temp', Torbeevo_temper, Torbeevo);

if not Atajschego.sqlite_base_open then
   BaseCreate(BaseAtajschego, 'Atajschevo_temp', Atajschego_temper, Atajschego);


PLC_Ping(Torbeevo, 'Торбеевский', StatusBar1.Panels[1]);
PLC_Ping(Atajschego, 'Атяшевский', StatusBar1.Panels[2]);


if Torbeevo.plc_v_seti then
  begin
   ReadDataPLC(Torbeevo, 100, 100, 0, 50,
              mLog, MdBClient_Torb,
              Torbeevo_temper);
   ReadDataPLC(Torbeevo, 200, 100, 50, 50,
              mLog, MdBClient_Torb,
              Torbeevo_temper);
   ReadDataPLC(Torbeevo, 300, 60, 100, 30,
              mLog, MdBClient_Torb,
              Torbeevo_temper);
   BaseWrite(BaseTorbeevo, 'Torbeevo_temp', Torbeevo_temper, Torbeevo);
  end;


if Atajschego.plc_v_seti then
  begin
    ReadDataPLC(Atajschego, 100, 100, 0, 50,
              mLog, MdBClient_At,
              Atajschego_temper);
    ReadDataPLC(Atajschego, 200, 20, 50, 10,
              mLog, MdBClient_At,
              Atajschego_temper);
    BaseWrite(BaseAtajschego, 'Atajschevo_temp', Atajschego_temper, Atajschego);
  end;


if not Torbeevo.sqlite_base_open then
   BaseTorbeevo.Destroy;

if not Atajschego.sqlite_base_open then
   BaseAtajschego.Destroy;

TimerRead.Enabled := True;

end;


end.
