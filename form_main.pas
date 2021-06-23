unit form_main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, LCLType, StdCtrls,
  Menus, Grids, UITypes, DBGrids, DBCtrls, Buttons, form_do_lamps_2color, dbf,
  DB, LConvEncoding,
  fpjson, jsonparser, jsonscanner,
  stan_types, form_topologyelem;

{ ------------------------------------------------------------------------------- }
const
  LengthTopologName : Word = 20;  {максимальная длина имени в топологии}

type
{конфигурация окружения}
TTopologyCFG = record
  StanPrjName           : AnsiString;    { stan project name - usually station name}
  {StanPrjFName     : string;}
  StanPrjFFName         : AnsiString;    { full file name }
  StanPrjDirName        : AnsiString;    { directory name }
  StanPrjTopologyFFName : AnsiString;
end;

{сортированный список элементов топологии,
 сортировка по номеру и строки и элементу в этой строке}
TTopologyList = class (TList)
public
    procedure SortAdd (var TopologyElement : TTopology);
end;

{ ------------------------------------------------------------------------------- }
{ TSTANMain }
TSTANMain = class(TForm)
    btn_NewLine: TButton;
    btn_DeleteLine: TButton;
    btn_EditLine: TButton;
{Menu}
    Menu0_Dependency: TMenuItem;
    Menu_Project_Exit: TMenuItem;
    Menu_Project_Close: TMenuItem;
    Menu_Project_SaveAs: TMenuItem;
    Menu_Project_Save: TMenuItem;
    Menu_Project_Create: TMenuItem;
    Menu_Project_Open: TMenuItem;
    Menu_Dep_Signal: TMenuItem;
    Menu_Dep_DopStructure: TMenuItem;
    Menu_Dep_IN: TMenuItem;
    Menu_Dep_OUT: TMenuItem;
    Menu_Dep_SP: TMenuItem;
    Menu_Dep_UP: TMenuItem;
    Menu_Dep_P: TMenuItem;
    Menu_Dep_BaseStep: TMenuItem;
    Menu_Dep_DZ: TMenuItem;
    Menu_Dep_DO: TMenuItem;
    Menu_Dep_TUMSs: TMenuItem;
    Menu_Dep_Diag: TMenuItem;
    Menu_Dep_Switch: TMenuItem;
    Menu_Dep_Topology: TMenuItem;
    Menu_StanProject: TMainMenu;
    Menu0_Project: TMenuItem;
    Menu0_Switches: TMenuItem;
    Menu0_DO: TMenuItem;
    Menu_DO_Lamps_2Circle: TMenuItem;
    Menu_DO_Lamps_2Ring: TMenuItem;
    Menu_DO_Lamps_Fider: TMenuItem;
    Menu_DO_Lamps_4x: TMenuItem;
    Menu_DO_Lamps_NPO: TMenuItem;
    Menu_DO_Lamps: TMenuItem;
    Menu_DO_Buttons: TMenuItem;
    Menu_DO_RialwayLines: TMenuItem;
    Menu_DO_SignalObjects: TMenuItem;
    Menu_DO_RailwayCrosses: TMenuItem;
    Menu_DO_Dims: TMenuItem;
    Dialog_CreateNewProject: TOpenDialog;
    Dialog_OpenProject: TOpenDialog;
    StringGrid_TopologData: TStringGrid;
    {function Dbf1Translate(Dbf: TDbf; Src, Dest: PChar; ToOem: Boolean): Integer;}
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure Menu_DO_LampsClick(Sender: TObject);
    procedure Menu_DO_Lamps_2CircleClick(Sender: TObject);
    procedure Menu_Project_CloseClick(Sender: TObject);
    procedure Menu_Project_CreateClick(Sender: TObject);
    procedure Menu_Project_ExitClick(Sender: TObject);
    procedure Menu_Project_OpenClick(Sender: TObject);
    procedure Menu_Project_SaveClick(Sender: TObject);
    procedure StringGrid_TopologDataDblClick(Sender: TObject);

  private
    //JObjCFG  : TJSONObject;
    //JObjSTAN : TJSONObject;

    CFG      : TTopologyCFG;
    Topology : TTopologyList;

  public
    {=Перезагружает StringGrid по списку Tlist=}
    procedure ConfigureVisualGrid_Topology (var list_source : TTopologyList);
end;

{ ---------------------------------------------------------------------------- }
var
  STANMain: TSTANMain;

{ ---------------------------------------------------------------------------- }
implementation

{$R *.lfm}

{ TSTANMain }

procedure TSTANMain.Menu_DO_Lamps_2CircleClick(Sender: TObject);
begin
  frm_DO_Lamps_2Color.Show;
end;

{=== Создание нового проекта ==================================================}
procedure TSTANMain.Menu_Project_CreateClick(Sender: TObject);
{---}
var
  {dialog's}
  DlgRes           : BOOLEAN;           {dialog_execute_result}
  MsgRes           : TModalResult;      {message_execute_result}
  StanPrjFName     : string;            {имя файла выбранное в диалоговом окне - временная строка}
  {file's routine}
  PosFExt          : SizeInt;
  {dbf}
  TopologDbf       : TDbf;
  TopologE         : EDatabaseError;
  {bd}
  TopologyLine     : TTopology;
{---}
begin
  Dialog_CreateNewProject.Title := 'Создать проект STAN ... ';
  DlgRes := Dialog_CreateNewProject.Execute;
  if (DlgRes = FALSE)
  then exit { не создаем проект }
  else;

  {"сбрасываем" все имена}
  CFG.StanPrjName           := ''; {имя проекта}
  CFG.StanPrjFFName         := '';
  CFG.StanPrjDirName        := '';
  CFG.StanPrjTopologyFFName := '';

  {определяем название проекта == имя файлы без расширения}
  StanPrjFName := Dialog_CreateNewProject.FileName;    { возвращается полный путь, даже если нет файла }
  CFG.StanPrjName  := ExtractFileName (StanPrjFName);
  PosFExt := pos ('.spr', CFG.StanPrjName); { Поиск расширения файла }
  if (PosFExt = 0) { Нет расширения }
     then       {Имя проекта без раширения}
     else begin { есть расширение? }
          if (((PosFExt-1)+4) = Length (CFG.StanPrjName)) {есть. -1, т.к. posfext это номер позиции расширения}
             then SetLength (CFG.StanPrjName, Length (CFG.StanPrjName)-4)
             else;
          {-endif2}
     end;
  {-endif1}

  {определяем каталог с файлом проекта}
  CFG.StanPrjFFName := StanPrjFName;   {ExpandFileName (...)}
  PosFExt := pos ('.spr', CFG.StanPrjFFName); { Поиск расширения фала }
  if (PosFExt = 0) { Нет расширения }
     then CFG.StanPrjFFName := CFG.StanPrjFFName + '.spr'  {+ расширение файла конфигурации}
     else begin { есть расширение? }
          if (PosFExt = Length (CFG.StanPrjFFName)-3) {есть}
             then
             else CFG.StanPrjFFName := CFG.StanPrjFFName + '.spr';  {+ расширение файла конфигурации}
          {-endif2}
     end;
  {-endif1}

  {определяем каталог с проектом}
  CFG.StanPrjDirName := Dialog_CreateNewProject.InitialDir;

  {имя файла топологии}
  CFG.StanPrjTopologyFFName :=  CFG.StanPrjDirName+CFG.StanPrjName+'_topolog.js';

  if (FileExists (CFG.StanPrjFFName) = TRUE) { файл конфигурации существует }
     then begin
          MessageDlg ('Создание проекта ... ',
                      'Проект STAN ['+CFG.StanPrjFFName+'] существует.' +
                      'Определите новое имя проекта, либо используйте <Открыть проект (*.spr) ...>',
                      mtError, [mbOk], '0');
          Exit;
     end
     else;
  {-endif1}

  {оформляем таблицу}
  StringGrid_TopologData.ColCount   := 7;
  StringGrid_TopologData.RowCount   := 1;
  StringGrid_TopologData.FixedCols  := 1;
  StringGrid_TopologData.FixedRows  := 1;
  StringGrid_TopologData.Cells[1,0] := 'N_STR';  {TopologDbf.FieldDefs [0].Name;}
  StringGrid_TopologData.Cells[2,0] := 'N_EL';   {TopologDbf.FieldDefs [1].Name;}
  StringGrid_TopologData.Cells[3,0] := 'NAME_R'; {TopologDbf.FieldDefs [2].Name;}
  StringGrid_TopologData.Cells[4,0] := 'NAME_E'; {TopologDbf.FieldDefs [3].Name;}
  StringGrid_TopologData.Cells[5,0] := 'SL';     {TopologDbf.FieldDefs [4].Name;}
  StringGrid_TopologData.Cells[6,0] := 'STOYKA'; {TopologDbf.FieldDefs [5].Name;}

  StringGrid_TopologData.ColWidths[0] := 50;
  StringGrid_TopologData.ColWidths[1] :=
    Trunc ((StringGrid_TopologData.Width - StringGrid_TopologData.ColWidths[0] - 20) / 6);
  { 20 == width vertical scrollbar}
  StringGrid_TopologData.ColWidths[2] := StringGrid_TopologData.ColWidths[1];
  StringGrid_TopologData.ColWidths[3] := StringGrid_TopologData.ColWidths[1];
  StringGrid_TopologData.ColWidths[4] := StringGrid_TopologData.ColWidths[1];
  StringGrid_TopologData.ColWidths[5] := StringGrid_TopologData.ColWidths[1];
  StringGrid_TopologData.ColWidths[6] := StringGrid_TopologData.ColWidths[1];

  (Menu_StanProject.Items [0]).Items [2].Enabled := TRUE;   { "Сохранить" }
  (Menu_StanProject.Items [0]).Items [3].Enabled := TRUE;   { "Сохранить как ..." }
  (Menu_StanProject.Items [0]).Items [4].Enabled := TRUE;   { "Закрыть" }

  (Menu_StanProject.Items [0]).Items [0].Enabled := FALSE;  { "Создать ..." }
  (Menu_StanProject.Items [0]).Items [1].Enabled := FALSE;  { "Открыть" }

  StringGrid_TopologData.Visible := TRUE;
  btn_NewLine.Visible    := TRUE;
  btn_DeleteLine.Visible := TRUE;
  btn_EditLine.Visible   := TRUE;

  { есть dbf топология?}
  if (FileExists (CFG.StanPrjDirName+'TOPOLOG.DBF') = FALSE) { файл топологии dbf отсутствует }
     then exit
     else;
  {-endif1}

  {есть!}
  msgres := MessageDlg ('Загрузка данных ... ',
                        'В каталоге проекта найден TOPOLOG.DBF. Загрузить топологию станции (DBF) ?',
                         mtConfirmation, [mbYes, mbNo], '0');
  if (msgres <> mrYes) {нужно загрузить?}
     then exit {нет}
     else;
  {-endif1}

  try
    TopologDbf := TDbf.Create(nil);
    TopologDbf.TableLevel:= 4;
    TopologDbf.TableName := 'TOPOLOG.DBF';
    TopologDbf.FilePath  := CFG.StanPrjDirName;
    TopologDbf.Open;
    TopologE := EDatabaseError.Create ('topolog.dbf');
    TopologE.Message := 'Bad format topolog.dbf (#TopologDbf.FieldCount)';
    if (TopologDbf.FieldCount <> 6) then raise (TopologE);
    TopologE.Message := 'Bad format topolog.dbf (#TopologDbf.FieldDefs)';
    if (TopologDbf.FieldDefs [0].Name <> 'N_STR')  then raise (TopologE);
    if (TopologDbf.FieldDefs [1].Name <> 'N_EL')   then raise (TopologE);
    if (TopologDbf.FieldDefs [2].Name <> 'NAME_R') then raise (TopologE);
    if (TopologDbf.FieldDefs [3].Name <> 'NAME_E') then raise (TopologE);
    if (TopologDbf.FieldDefs [4].Name <> 'SL')     then raise (TopologE);
    if (TopologDbf.FieldDefs [5].Name <> 'STOYKA') then raise (TopologE);

    Topology.Clear; {удаляем старые данные}

    TopologDbf.First;
    while (TopologDbf.EOF <> TRUE) do {читаем данные}
    begin
       {N_STR}  TopologyLine.Line    := TopologDbf.Fields [0].AsInteger;
       {N_EL}   TopologyLine.SubLine := TopologDbf.Fields [1].AsInteger;
       {NAME_E} TopologyLine.Id      := ConvertEncoding (TopologDbf.Fields [3].AsString, 'cp866', 'utf8');
       {NAME_R} TopologyLine.Name    := ConvertEncoding (TopologDbf.Fields [2].AsString, 'cp866', 'utf8');;
       {SL}     TopologyLine.Link    := ConvertEncoding (TopologDbf.Fields [4].AsString, 'cp866', 'utf8');;
       {STOYKA} TopologyLine.UVK     := TopologDbf.Fields [5].AsInteger;
       Topology.SortAdd(TopologyLine);
       TopologDbf.Next;
    end;
    TopologE.Destroy;
    TopologDbf.Destroy;

    ConfigureVisualGrid_Topology (Topology);  { заполняем сетку }
    btn_NewLine.SetFocus;
  Except
    Application.MessageBox ('Неправильный формат topolog.dbf', 'f.ck.p', MB_OK);
  end;

  Caption := 'БД Сервер->STAN (aka FoxPro) <'+CFG.StanPrjName+':'+CFG.StanPrjFFName+'>';
end;

{ === Перезагружаем табличку-grid отображения топологии ====================== }
procedure TSTANMain.ConfigureVisualGrid_Topology (var list_source : TTopologyList);
var
  ti      : longword;   { индексы доступа }
  li      : longword;
  str_tmp : AnsiString;
  ptplg   : ^TTopology; { элемент списка }

begin
  StringGrid_TopologData.Clean;

  {оформляем таблицу}
  StringGrid_TopologData.ColCount  := 7;
  StringGrid_TopologData.RowCount  := 1;
  StringGrid_TopologData.FixedCols := 1;
  StringGrid_TopologData.FixedRows := 1;
  StringGrid_TopologData.Cells[1,0] := 'N_STR';  {from TopologDbf.FieldDefs [0].Name;}
  StringGrid_TopologData.Cells[2,0] := 'N_EL';   { ... TopologDbf.FieldDefs [1].Name;}
  StringGrid_TopologData.Cells[3,0] := 'NAME_E'; { ... TopologDbf.FieldDefs [2].Name;}
  StringGrid_TopologData.Cells[4,0] := 'NAME_R'; { ... TopologDbf.FieldDefs [3].Name;}
  StringGrid_TopologData.Cells[5,0] := 'SL';     { ... TopologDbf.FieldDefs [4].Name;}
  StringGrid_TopologData.Cells[6,0] := 'STOYKA'; { ... TopologDbf.FieldDefs [5].Name;}

  {формируем и форматируем таблицу}
  StringGrid_TopologData.RowCount := list_source.Count + 1;
  for ti := 1 to Topology.Count do
  begin
     li := ti - 1;
     ptplg := Topology.Items[li];

     str (ti, str_tmp);
     StringGrid_TopologData.Cells[0,ti] := str_tmp;      { порядковый номер }
     str (ptplg^.Line, str_tmp);
     StringGrid_TopologData.Cells[1,ti] := str_tmp;      { №строки }
     str (ptplg^.SubLine, str_tmp);
     StringGrid_TopologData.Cells[2,ti] := str_tmp;      { №подстроки }
     StringGrid_TopologData.Cells[3,ti] := ptplg^.Id;    { имя-идентификатор }
     //str_tmp:=ConvertEncoding (ptplg^.Name, 'cp866', 'utf8');
     StringGrid_TopologData.Cells[4,ti] := ptplg^.Name;  { имя }
     StringGrid_TopologData.Cells[5,ti] := ptplg^.Link;  { переход-идентификатор }
     str (ptplg^.UVK, str_tmp);
     StringGrid_TopologData.Cells[6,ti] := str_tmp;       { стойка }
  end;

  StringGrid_TopologData.ColWidths[0] := 50;
  StringGrid_TopologData.ColWidths[1] :=
    Trunc ((StringGrid_TopologData.Width - StringGrid_TopologData.ColWidths[0] - 20) / 6);
  { 20 == width vertical scrollbar}
  StringGrid_TopologData.ColWidths[2] := StringGrid_TopologData.ColWidths[1];
  StringGrid_TopologData.ColWidths[3] := StringGrid_TopologData.ColWidths[1];
  StringGrid_TopologData.ColWidths[4] := StringGrid_TopologData.ColWidths[1];
  StringGrid_TopologData.ColWidths[5] := StringGrid_TopologData.ColWidths[1];
  StringGrid_TopologData.ColWidths[6] := StringGrid_TopologData.ColWidths[1];

end;

{=== Открыть существующий проект ==============================================}
procedure TSTANMain.Menu_Project_OpenClick(Sender: TObject);
var
  {dialog's}
  DlgRes           : BOOLEAN;           {dialog_execute_result}
  MsgRes           : TModalResult;      {message_execute_result}
  StanPrjFName     : string;            {имя файла проекта выбранное в диалоговом окне - временная строка}
  {file's routine}
  PosFExt          : SizeInt;
  StanPrjFD        : TextFile;
  TopoFD           : TextFile;
  {json}
  json_parser      : TJSONParser;
  json_data        : TJSONData;
  json_strline     : AnsiString;
  json_strfull     : AnsiString;
  json_strutf8     : AnsiString;
  json_key         : TJSONStringType;
  json_value       : TJSONStringType;
  {dbf}
  TopologDbf       : TDbf;
  TopologE         : EDatabaseError;
  {bd}
  TopologyLine     : TTopology;
  tli              : longword;       { индекс цикла списка }
  {..._topology.js}
  topology_count    : LongWord;
  topology_path     : String;
  topology_lineprop : TJSONArray;

begin
  Dialog_OpenProject.Title  := 'Открыть проект STAN (*.spr) ... ';
  DlgRes := Dialog_OpenProject.Execute;
  if (DlgRes = FALSE)
     then exit
     else;
  {-endif1}

  {"сбрасываем" все имена}
  CFG.StanPrjName           := ''; {имя проекта}
  CFG.StanPrjFFName         := '';
  CFG.StanPrjDirName        := '';
  CFG.StanPrjTopologyFFName := '';

  {определяем название проекта}
  StanPrjFName    := Dialog_OpenProject.FileName;    { возвращается полный путь, даже если нет файла }
  CFG.StanPrjName := ExtractFileName (StanPrjFName);
  PosFExt := pos ('.spr', CFG.StanPrjName); { Поиск расширения файла }
  if (PosFExt = 0) { Нет расширения }
     then       {Имя проекта без раширения}
     else begin { есть расширение? }
          if (((PosFExt-1)+4) = Length (CFG.StanPrjName)) {есть. -1, т.к. posfext это номер позиции расширения}
             then SetLength (CFG.StanPrjName, Length (CFG.StanPrjName)-4)
             else;
          {-endif2}
     end;
  {-endif1}

  {определяем полное имя файла проекта}
  //CFG.StanPrjFFName := ExpandFileName (CFG.StanPrjFName);
  CFG.StanPrjFFName := StanPrjFName; { ExpandFileName нужно? }
  PosFExt := pos ('.spr', CFG.StanPrjFFName); { Поиск расширения фала }
  if (PosFExt = 0) { нет расширения }
     then CFG.StanPrjFFName := CFG.StanPrjFFName + '.spr'  {+ расширение файла конфигурации}
     else begin { есть расширение }
          if (PosFExt = Length (CFG.StanPrjFFName)-3) {есть}
             then
             else CFG.StanPrjFFName := CFG.StanPrjFFName + '.spr';  {+ расширение файла конфигурации}
          {-endif2}
     end;
  {-endif1}

  {проверка наличия файла конфигурации}
  if (FileExists (CFG.StanPrjFFName) = FALSE)
      then begin
           MessageDlg ('Загрузка данных ... ',
                       'Файл конфигурации "' + AnsiUpperCase (CFG.StanPrjFFName) + '" отсутствует!',
                       mtError, [mbOk], '0');
           exit;
      end
      else;
  {-endif1}

  {чтение файла конфигурации в строку}
  AssignFile (StanPrjFD, CFG.StanPrjFFName);
  Reset (StanPrjFD);
  json_strfull := '';
  while (not (eof (StanPrjFD))) do
  begin
     ReadLn (StanPrjFD, json_strline);
     json_strfull := json_strfull + json_strline;
  end; { while ... }
  CloseFile (StanPrjFD);
  {преобразование кодировки}
  json_strutf8 := ConvertEncoding (json_strfull, 'cp866', 'utf8');

  {Парсим структуру конфигурационного файла}
  json_parser    := TJSONParser.Create(json_strfull,DefaultOptions);
  json_data      := json_parser.Parse;// as TJSONObject;
  {определяем файл с описанием топологии}
  json_key       :=  'STAN.Topology';
  json_value     := json_data.FindPath (json_key).AsString;
  //json_valueutf8 := ConvertEncoding (json_value, 'cp866', 'utf8');
  CFG.StanPrjTopologyFFName :=  json_value; //json_valueutf8;
  {определяем каталог с файлом конфигурации}
  json_key       :=  'STAN.Directory';
  json_value     := json_data.FindPath (json_key).AsString;
  CFG.StanPrjDirName := json_value;
  FreeAndNil (json_data);
  FreeAndNil (json_parser);

  if (FileExists (CFG.StanPrjTopologyFFName) = TRUE) { файл топологии(.js) существует }
     then begin
          Topology.Clear; {сброс текущей топологии}

          {чтение файла топологии в строку}
          json_strline := '';
          json_strfull := '';
          AssignFile (TopoFD, CFG.StanPrjTopologyFFName);
          Reset (TopoFD);
          json_strfull := '';
          while (not (eof (TopoFD))) do
          begin
             ReadLn (TopoFD, json_strline);
             json_strfull := json_strfull + json_strline;
          end; { while ... }
          CloseFile (TopoFD);
          {преобразование кодировки}
          json_strutf8 := ConvertEncoding (json_strfull, 'cp866', 'utf8');

          {находим расположение файла топологии}
          json_parser    := TJSONParser.Create(json_strutf8,DefaultOptions);
          json_data      := json_parser.Parse;// as TJSONObject;
          {определяем директорию с проектом}
          json_key       := 'Topology.Count';
          json_value     := json_data.FindPath (json_key).AsString;
          topology_count := StrToInt (json_value);
          for tli := 1 to topology_count do
          begin
             topology_path := 'Topology.' + IntToStr (tli);
             {TopologyLine}
             TopologyLine.Line    := 0;
             TopologyLine.SubLine := 0;
             TopologyLine.Id      := '';
             TopologyLine.Name    := '';
             TopologyLine.Link    := '';
             TopologyLine.UVK     := 0;

             topology_lineprop    := TJSONArray (json_data.FindPath (topology_path));
             TopologyLine.Line    := topology_lineprop.Items [0].AsInteger;
             TopologyLine.SubLine := topology_lineprop.Items [1].AsInteger;
             TopologyLine.Id      := topology_lineprop.Items [2].AsString;
             TopologyLine.Name    := topology_lineprop.Items [3].AsString;
             TopologyLine.Link    := topology_lineprop.Items [4].AsString;
             TopologyLine.UVK     := topology_lineprop.Items [5].AsInteger;

             Topology.SortAdd (TopologyLine);
          end; { end for ... }
          FreeAndNil (json_data);
          FreeAndNil (json_parser);

          ConfigureVisualGrid_Topology (Topology);  { заполняем сетку }
     end
     else begin
          if (FileExists (CFG.StanPrjDirName+'TOPOLOG.DBF') = FALSE) { файл топологии(.js) существует }
             then exit
             else;
          {-endif2}
          { файла *_topology.ts нет, но есть TOPOLOG.DBF }
          MsgRes := MessageDlg ('Загрузка данных ... ',
                                'Файл *_topology.ts отсутствует в каталоге проекта.'+
                                'Найден TOPOLOG.DBF. Подгрузить данные (DBF) ?',
                                mtConfirmation, [mbYes, mbNo], '0');
          if (MsgRes <> mrYes)
             then exit
             else;
          {-endif2}

          {MsgRes == mrYes}
          try
             TopologDbf := TDbf.Create(nil);
             TopologDbf.TableLevel:= 4;
             TopologDbf.TableName := 'TOPOLOG.DBF';
             TopologDbf.FilePath  := CFG.StanPrjDirName;
             TopologDbf.Open;
             TopologE := EDatabaseError.Create ('topolog.dbf');
             TopologE.Message := 'Bad format topolog.dbf (#TopologDbf.FieldCount)';
             if (TopologDbf.FieldCount <> 6) then raise (TopologE);
             TopologE.Message := 'Bad format topolog.dbf (#TopologDbf.FieldDefs)';
             if (TopologDbf.FieldDefs [0].Name <> 'N_STR')  then raise (TopologE);
             if (TopologDbf.FieldDefs [1].Name <> 'N_EL')   then raise (TopologE);
             if (TopologDbf.FieldDefs [2].Name <> 'NAME_R') then raise (TopologE);
             if (TopologDbf.FieldDefs [3].Name <> 'NAME_E') then raise (TopologE);
             if (TopologDbf.FieldDefs [4].Name <> 'SL')     then raise (TopologE);
             if (TopologDbf.FieldDefs [5].Name <> 'STOYKA') then raise (TopologE);
             {читаем данные}
             Topology := TTopologyList.Create;

             //Topolog_rowcount := 0;
             TopologDbf.First;
             while (TopologDbf.EOF <> TRUE) do
             begin
                  {N_STR}  TopologyLine.Line    := TopologDbf.Fields [0].AsInteger;
                  {N_EL}   TopologyLine.SubLine := TopologDbf.Fields [1].AsInteger;
                  {NAME_E} TopologyLine.Id      := ConvertEncoding (TopologDbf.Fields [3].AsString, 'cp866', 'utf8');
                  {NAME_R} TopologyLine.Name    := ConvertEncoding (TopologDbf.Fields [2].AsString, 'cp866', 'utf8');;
                  {SL}     TopologyLine.Link    := ConvertEncoding (TopologDbf.Fields [4].AsString, 'cp866', 'utf8');;
                  {STOYKA} TopologyLine.UVK     := TopologDbf.Fields [5].AsInteger;
                  Topology.SortAdd(TopologyLine);
                  TopologDbf.Next;
              end;
              TopologDbf.Destroy;
              TopologE.Destroy;

              ConfigureVisualGrid_Topology (Topology);  { заполняем сетку }
          Except
              Application.MessageBox ('Неправильный формат topolog.dbf', 'f.ck.p', MB_OK);
          end;
     end;
  {-endif1}

  (Menu_StanProject.Items [0]).Items [2].Enabled := TRUE;   { "Сохранить" }
  (Menu_StanProject.Items [0]).Items [3].Enabled := TRUE;   { "Сохранить как ..." }
  (Menu_StanProject.Items [0]).Items [4].Enabled := TRUE;   { "Закрыть" }
  (Menu_StanProject.Items [0]).Items [0].Enabled := FALSE;  { "Создать ..." }
  (Menu_StanProject.Items [0]).Items [1].Enabled := FALSE;  { "Открыть" }

  StringGrid_TopologData.Visible := TRUE;

  btn_NewLine.Visible    := TRUE;
  btn_DeleteLine.Visible := TRUE;
  btn_EditLine.Visible   := TRUE;

  Caption := 'БД Сервер->STAN (aka FoxPro) <'+CFG.StanPrjName+':'+CFG.StanPrjFFName+'>';
end;

procedure TSTANMain.Menu_Project_ExitClick(Sender: TObject);
begin
  Application.Terminate;
end;

(*
{=== example save using json_lib. None delete =================================}
procedure TSTANMain.Menu_Project_SaveClick(Sender: TObject);
var
  JObjTOPOLOGWRAP    : TJSONObject;
  JObjTOPOLOG        : TJSONObject;
  JObjTOPOLOGARRAY   : TJSONArray;

  tplgstr_utf8       : TJSONStringType;
  tplgstr_cp866      : String;
  StanPrjTopologyFD  : TextFile;
  tli                : longword;
  ptplg              : ^TTopology;
  str_tmp            : string;

begin
  JObjTOPOLOGWRAP := TJSONObject.Create;
  JObjTOPOLOGWRAP.Add ('Type', 'JSON');
  JObjTOPOLOGWRAP.Add ('TimeStamp', DateToStr (Now)+' '+TimeToStr (Now));

  JObjTOPOLOG := TJSONObject.Create;
  str (Topology.Count, str_tmp);
  JObjTOPOLOG.Add ('Count', str_tmp);

  for tli := 0 to Topology.Count-1 do
  begin
     JObjTOPOLOGARRAY := TJSONArray.Create;

     ptplg := Topology.Items[tli];

     str (ptplg^.Line, str_tmp);
     JObjTOPOLOGARRAY.Add ( str_tmp); //'Line'
     str (ptplg^.SubLine, str_tmp);
     JObjTOPOLOGARRAY.Add ( str_tmp); //'Subline'
     str_tmp :=  ptplg^.Id;
     JObjTOPOLOGARRAY.Add ( str_tmp); //'ID'
     str_tmp := ConvertEncoding (ptplg^.Name, 'cp866', 'utf8');
     JObjTOPOLOGARRAY.Add ( str_tmp); //'Name'
     StringGrid_TopologData.Cells[3,tli+1] := str_tmp;
     str_tmp :=  ptplg^.Link;
     JObjTOPOLOGARRAY.Add ( str_tmp); //'Link'
     str (ptplg^.UVK, str_tmp);
     JObjTOPOLOGARRAY.Add ( str_tmp); //'UVK'

     str_tmp := Format ('%.4d', [tli+1]);
     JObjTOPOLOG.Add (str_tmp, JObjTOPOLOGARRAY);
  end;

  JObjTOPOLOGWRAP.Add ('Topology', JObjTOPOLOG);

  tplgstr_utf8  := JObjTOPOLOGWRAP.FormatJSON([foSingleLineArray],5);
  tplgstr_cp866 := ConvertEncoding (tplgstr_utf8, 'utf8', 'cp866');

  AssignFile (StanPrjTopologyFD, CFG.StanPrjTopologyFFName);
  ReWrite (StanPrjTopologyFD);
  WriteLn (StanPrjTopologyFD, tplgstr_cp866);
  CloseFile (StanPrjTopologyFD);
  FreeAndNil (JObjTOPOLOGWRAP);
end;
*)

{=== Сохрание проекта =========================================================}
procedure TSTANMain.Menu_Project_SaveClick(Sender: TObject);
var
  StanPrjFD          : TextFile;
  StanPrjTopologyFD  : TextFile;
  tli                : Longint;       { индекс цикла списка }
  ptplg              : ^TTopology;
  //str_tmp            : string;
  //str_tmp1           : string;
  //str_tmp2           : string;
  str_tmp            : AnsiString;
  str_tmp1           : AnsiString;
  topostr            : AnsiString;
  //topostr_cp866      : AnsiString;

  {json}
  json_cfg           : TJSONObject;
  json_stan          : TJSONObject;
  cfgstr_utf8        : AnsiString;
  cfgstr_cp866       : AnsiString;
begin

  {запись базового конфигурационного файла}
  json_cfg := TJSONObject.Create;
  json_cfg.Add ('Type', 'JSON');
  json_cfg.Add ('TimeStamp', DateToStr (Now)+' '+TimeToStr (Now));

  json_stan := TJSONObject.Create;
  json_stan.Add ('Name', CFG.StanPrjName);
  json_stan.Add ('Directory', CFG.StanPrjDirName);
  json_stan.Add ('Topology', CFG.StanPrjTopologyFFName);
  json_cfg.Add ('STAN', json_stan);
  cfgstr_utf8  := json_cfg.FormatJSON([foSingleLineArray],5);
  cfgstr_cp866 := ConvertEncoding (cfgstr_utf8, 'utf8', 'cp866');

  AssignFile (StanPrjFD, CFG.StanPrjFFName);
  ReWrite (StanPrjFD);
  WriteLn (StanPrjFD, cfgstr_cp866);
  CloseFile (StanPrjFD);
  {FreeAndNil (json_stan);} {Удалится в json_cfg}
  FreeAndNil (json_cfg);

  {запись ***_topology.js конфигурационного файла}
  AssignFile (StanPrjTopologyFD, CFG.StanPrjTopologyFFName);
  ReWrite (StanPrjTopologyFD);
  WriteLn (StanPrjTopologyFD, '{');
  WriteLn (StanPrjTopologyFD, '   "Type" : "JSON",');
  WriteLn (StanPrjTopologyFD, '   "TimeStamp" : "' + DateToStr (Now)+' '+TimeToStr (Now)+'",');
  WriteLn (StanPrjTopologyFD, '   "Topology" : {');
  str (Topology.Count, topostr);
  Write (StanPrjTopologyFD, '      "Count" : "'+topostr+'"');
  if (Topology.Count > 0)
     then WriteLn (StanPrjTopologyFD, ',')
     else;

  for tli := 1 to Topology.Count do
  begin
     ptplg := Topology.Items[tli-1];

     Write (StanPrjTopologyFD, '      '); {отступ}

     topostr := '';
     {номер строки топологии - нумерация сквозная}
     str_tmp      := '"'+IntToStr (tli)+'"';
     topostr := topostr + Format ('%7s',[str_tmp]);
     topostr := topostr + ' : ';
     topostr := topostr + '[';

     {номер строки}
     str (ptplg^.Line, str_tmp);
     str_tmp  := '"'+str_tmp+'"';
     topostr := topostr + Format ('%5s',[str_tmp]);
     topostr := topostr + ', ';

     {номер подстроки}
     str (ptplg^.SubLine, str_tmp);
     str_tmp  := '"'+str_tmp+'"';
     topostr := topostr + Format ('%5s',[str_tmp]);
     topostr := topostr + ', ';

     {идентификатор}
     str_tmp  := '"'+ptplg^.Id+'"';
     str_tmp  := ConvertEncoding (str_tmp, 'utf8', 'cp866');
     str_tmp1 := '%s,%'+IntToStr ((LengthTopologName+3)-Length (str_tmp))+'s'; { 3 == " " , }
     topostr := topostr + Format (str_tmp1,[str_tmp, ' ']);

     {имя}
     str_tmp  := '"'+ptplg^.Name+'"';
     str_tmp  := ConvertEncoding (str_tmp, 'utf8', 'cp866');
     str_tmp1 := '%s,%'+IntToStr ((LengthTopologName+3)-Length (str_tmp))+'s';
     topostr := topostr + Format (str_tmp1,[str_tmp, ' ']);

     {идентификатор перехода}
     str_tmp  := '"'+ptplg^.Link+'"';
     str_tmp  := ConvertEncoding (str_tmp, 'utf8', 'cp866');
     str_tmp1 := '%s,%'+IntToStr ((LengthTopologName+3)-Length (str_tmp))+'s';
     topostr := topostr + Format (str_tmp1,[str_tmp, ' ']);

     {номер стойки}
     str_tmp  := '"'+IntToStr (ptplg^.UVK)+'"';
     topostr := topostr + Format ('%3s',[str_tmp]);
     topostr := topostr + ' ]';

     if (tli <> Topology.Count)
        then topostr := topostr + ',' {Write (StanPrjTopologyFD, ',')}
        else;

     //topostr_cp866 := ConvertEncoding (topostr_utf8, 'utf8', 'cp866');
     WriteLn (StanPrjTopologyFD, topostr);
  end;

  WriteLn (StanPrjTopologyFD, '   }');
  WriteLn (StanPrjTopologyFD, '}');

  CloseFile (StanPrjTopologyFD);
end;

{=== Редактирование элемента строки топологии =================================}
procedure TSTANMain.StringGrid_TopologDataDblClick(Sender: TObject);
var
  topolog_row   : Integer;     { выбранная строка в списке }
  TopologyLine  : TTopology;   { значения }
  ptplg         : ^TTopology;
begin
  topolog_row := StringGrid_TopologData.Row;
  if (topolog_row < 1)
     then exit
     else;
  {-endif0}

  ptplg := Topology.Items[topolog_row-1];

  TopologyLine := ptplg^;
  Form_TopologyElement.TopologFieldsInit (TopologyLine);
  Form_TopologyElement.ShowModal;
end;

(*===
function TSTANMain.Dbf1Translate(Dbf: TDbf; Src, Dest: PChar; ToOem: Boolean): Integer;
var
  s: string;
begin
{init dbf table for correct cirilic}
{TStringField (Dbf1.Fields.Fields[dbf_column_index]).Transliterate := true;}
  if (ToOEM = true)
    then s:=ConvertEncoding (Src, 'utf8', 'cp866')
    else s:=ConvertEncoding (Src, 'cp866', 'utf8');

  strcopy (Dest, PChar (s));
  Result := strlen (Dest);
end;
===*)

{=== Завершение работы ========================================================}
procedure TSTANMain.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  CloseAction := caFree;
  Menu_Project_ExitClick (Sender);
end;

{=== Создание (инициализация) главной формы ===================================}
procedure TSTANMain.FormCreate(Sender: TObject);
begin
  { Все меню заблокированы пока, не откроется или создатся проект }
  (Menu_StanProject.Items [0]).Items [2].Enabled := FALSE;  { "Сохранить" }
  (Menu_StanProject.Items [0]).Items [3].Enabled := FALSE;  { "Сохранить как" }
  (Menu_StanProject.Items [0]).Items [4].Enabled := FALSE;  { "Закрыть" }
  StringGrid_TopologData.Visible := FALSE;
  btn_NewLine.Visible    := FALSE;
  btn_DeleteLine.Visible := FALSE;
  btn_EditLine.Visible   := FALSE;

  (Menu_StanProject.Items [0]).Items [0].Enabled := TRUE;  { "Создать" }
  (Menu_StanProject.Items [0]).Items [1].Enabled := TRUE;  { "Открыть" }

  Topology := TTopologyList.Create;
  CFG.StanPrjName           := '';
  CFG.StanPrjDirName        := '';
  CFG.StanPrjFFName         := '';
  CFG.StanPrjTopologyFFName := '';

  Caption :=  'БД Сервер->STAN (aka FoxPro) <NONE>';
end;

{=== Закрыть проект ===========================================================}
procedure TSTANMain.Menu_Project_CloseClick(Sender: TObject);
var
  {dialog's}
  MsgRes           : TModalResult;      {message_execute_result}
begin
  MsgRes := MessageDlg ('Работа с проектом ... ',
                        'Закрыть проект '+CFG.StanPrjName+' ('+
                        CFG.StanPrjFFName+') ?',
                        mtConfirmation, [mbYes, mbNo], '0');

  if (MsgRes <> mrYes)
     then exit
     else;
  {-endif1}

  Topology.Clear;
  StringGrid_TopologData.Clear;

  {"сбрасываем" все имена}
  CFG.StanPrjName           := ''; {имя проекта}
  CFG.StanPrjFFName         := '';
  CFG.StanPrjDirName        := '';
  CFG.StanPrjTopologyFFName := '';

  { Все меню заблокированы пока, не откроется или создатся проект }
  (Menu_StanProject.Items [0]).Items [2].Enabled := FALSE;  { "Сохранить" }
  (Menu_StanProject.Items [0]).Items [3].Enabled := FALSE;  { "Сохранить как" }
  (Menu_StanProject.Items [0]).Items [4].Enabled := FALSE;  { "Закрыть" }
  StringGrid_TopologData.Visible := FALSE;
  btn_NewLine.Visible    := FALSE;
  btn_DeleteLine.Visible := FALSE;
  btn_EditLine.Visible   := FALSE;

  (Menu_StanProject.Items [0]).Items [0].Enabled := TRUE;  { "Создать" }
  (Menu_StanProject.Items [0]).Items [1].Enabled := TRUE;  { "Открыть" }

  Caption :=  'БД Сервер->STAN (aka FoxPro) <NONE>';
end;

{ ------------------------------------------------------------------------------- }
procedure TSTANMain.Menu_DO_LampsClick(Sender: TObject);
begin
end;

{=== Реализация списка с топологией +сортировка в качестве обязательного функционала ===}
procedure TTopologyList.SortAdd (var TopologyElement : TTopology);
Var
  pTplg_new : ^TTopology;       { указатель новой строки топологии }
  pTplg_s   : ^TTopology;       { указатель из списка строк для сортировки }
  eme       : EHeapMemoryError; { исключение при нехватке памяти }
  tli       : longword;         { индекс цикла списка }
  key_new   : longword;         { 'ключ' сортировки новой записи }
  key_s     : longword;         { 'ключ' сортировки записи из TList }
  etplg     : ERangeError;      { исключение при ошибке в DBF }
  isIns     : Boolean;

Begin
  try
    { память для новой строки в список }
    new (pTplg_new);
    if (pTplg_new = NIL)
       then begin
            eme := EHeapMemoryError.Create ('TTopologyList');
            eme.Message := 'None memory for TTopologyList.SortAdd.';
            raise (eme);
       end
       else;
    {-endif0}
    pTplg_new^ :=  TopologyElement; { копия значения }
    key_new    := pTplg_new^.Line*1024 + pTplg_new^.SubLine;

    { типа "алгоритм сортировки" }
    isIns := FALSE;
    if (self.Count = 0)
       then begin
            self.Add (pTplg_new); { пустой список }
            isIns := TRUE;
       end
       else begin
            for tli := 0 to self.Count-1 do
            begin
               pTplg_s := self.Items[tli];
               key_s   := pTplg_s^.Line*1024 + pTplg_s^.SubLine;
               { new 'topolog.line' is great }
               if (key_new > key_s)
                  then continue { nothing do }
                  else;
               {-endif2}
               { new 'topolog.line' is equal }
               if (key_new = key_s)
                  then begin { it's bag! }
                       etplg := ERangeError.Create ('TTopologyList');
                       etplg.Message := 'Topology line dublicate in dbf.';
                       raise (etplg);
                   end
               else;
               {-endif2}
               { new 'topolog.line' is less }
               if (key_new < key_s)
                  then begin { add and loop break }
                       self.Insert (tli, pTplg_new);
                       isIns := TRUE;
                       break;
                  end
                  else;
               {-endif2}
            end; { end for ... }
            {...}
            if (isIns = FALSE)
               then self.Add (pTplg_new) { добавляем в конец }
               else;
            {-endif1}
       end;
    {-endif0}
  Except
    Application.MessageBox ('Дублирование записей', 'f.ck.p', MB_OK);
  end;

End;
{ ---------------------------------------------------------------------------- }
end.

