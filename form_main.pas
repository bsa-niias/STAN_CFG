unit form_main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, LCLType, StdCtrls,
  Menus, Grids, UITypes, DBGrids, DBCtrls, Buttons, form_do_lamps_2color, dbf,
  DB, LConvEncoding,
  fpjson, jsonparser, jsonscanner,
  stan_types, form_topologyelem,
  form_uvk, form_linpzu;

{ ------------------------------------------------------------------------------- }
const
  LengthTopologName : Word = 20;  {максимальная длина имени в топологии}

type

{сортированный список элементов топологии,
 сортировка по номеру и строки и элементу в этой строке}
TTopologyList = class (TList)
public
    procedure SortAdd (var TopologyElement : TTopology);
    procedure TopologyListReorderAfterAdd;
    procedure TopologyListReorderAfterRemove;
end;

{ ------------------------------------------------------------------------------- }
{ TSTANMain }
TSTANMain = class(TForm)
    btn_LineUp: TBitBtn;
    btn_LineDown: TBitBtn;
    btn_SublineUp: TBitBtn;
    btn_SublineDown: TBitBtn;
    btn_NewSubline: TButton;
    btn_DeleteSubline: TButton;
    btn_EditLine: TButton;
    btn_NewLine: TButton;
    btn_CheckDepend: TButton;
    Btn_Find: TButton;
    Btn_FindNext: TButton;
    Edit_FindText: TEdit;
{Menu}
    Menu0_Project: TMenuItem;
    Menu_Project_Create: TMenuItem;
    Menu_Project_Open: TMenuItem;
    Menu_Project_Save: TMenuItem;
    Menu_Project_SaveAs: TMenuItem;
    Menu_Project_Close: TMenuItem;
    Menu_Project_Exit: TMenuItem;
    {}
    Menu0_Config: TMenuItem;
    Menu_Config_UVK: TMenuItem;
    Menu_Config_LINPZU: TMenuItem;
    {}
    Menu0_Dependency: TMenuItem;
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
    Dialog_SaveAsProject: TSaveDialog;
    StringGrid_TopologData: TStringGrid;
    StringGrid_ColumnsName: TStringGrid;
    {function Dbf1Translate(Dbf: TDbf; Src, Dest: PChar; ToOem: Boolean): Integer;}
    procedure Btn_FindClick(Sender: TObject);
    procedure Btn_FindNextClick(Sender: TObject);
    procedure btn_NewLineClick(Sender: TObject);
    procedure btn_SublineDownClick(Sender: TObject);
    procedure btn_SublineUpClick(Sender: TObject);
    procedure btn_DeleteSublineClick(Sender: TObject);
    procedure btn_LineDownClick(Sender: TObject);
    procedure btn_LineUpClick(Sender: TObject);
    procedure btn_NewSublineClick(Sender: TObject);
    procedure Edit_FindTextChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure Menu_Config_UVKClick(Sender: TObject);
    procedure Menu_DO_LampsClick(Sender: TObject);
    procedure Menu_DO_Lamps_2CircleClick(Sender: TObject);
    procedure Menu_Project_CloseClick(Sender: TObject);
    procedure Menu_Project_CreateClick(Sender: TObject);
    procedure Menu_Project_ExitClick(Sender: TObject);
    procedure Menu_Project_OpenClick(Sender: TObject);
    procedure Menu_Project_SaveAsClick(Sender: TObject);
    procedure Menu_Project_SaveClick(Sender: TObject);
    procedure StringGrid_TopologDataDblClick(Sender: TObject);
    procedure Menu_Config_LINPZU_Action (Sender: TObject);

  private
    CFG            : TTopologyCFG;
    KO             : TKolObj;
    TopologyList   : TTopologyList;
    DependIsChange : Boolean;
    {индекс поиска для "найти" и "искать дальше"}
    SearchIndex    : Integer;

    procedure Menu_Config_LINPZUGen;
    procedure SaveProject (var _cfg : TTopologyCFG);

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
  StanPrjFullName  : string;            {имя файла выбранное в диалоговом окне - временная строка}
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
  If (DlgRes = FALSE)
     Then exit { не создаем проект }
     Else;

  {"сбрасываем" все имена}
  CFG.StanPrjName         := ''; {имя проекта}
  CFG.StanPrjFFName       := ''; {полный путь + имя проекта с расширением}
  CFG.StanPrjDirName      := ''; {Только путь}
  CFG.StanPrjKolObjName   := '';
  CFG.StanPrjTopologyName := '';

  {определяем название проекта == имя файлы без пути и расширения}
  { возвращается полный путь+название проекта, даже если нет файла }
  StanPrjFullName := Dialog_CreateNewProject.FileName;
  CFG.StanPrjName  := ExtractFileName (StanPrjFullName);
  PosFExt := pos ('.spr', CFG.StanPrjName); { Поиск расширения файла }
  If (PosFExt = 0) { Нет расширения }
     Then       {Имя проекта без раширения}
     Else Begin { есть расширение? }
          If (((PosFExt-1)+4) = Length (CFG.StanPrjName)) {есть. -1, т.к. posfext это номер позиции расширения}
             Then SetLength (CFG.StanPrjName, Length (CFG.StanPrjName)-4)
             Else;
          {-endif2}
     end;
  {-endif1}

  {определяем каталог с файлом проекта}
  CFG.StanPrjFFName := StanPrjFullName;   {ExpandFileName (...)}
  PosFExt := pos ('.spr', CFG.StanPrjFFName); { Поиск расширения фала }
  If (PosFExt = 0) { Нет расширения }
     Then CFG.StanPrjFFName := CFG.StanPrjFFName + '.spr'  {+ расширение файла конфигурации}
     Else Begin { есть расширение? }
          If (PosFExt+3 = Length (CFG.StanPrjFFName)) {есть}
             Then
             Else CFG.StanPrjFFName := CFG.StanPrjFFName + '.spr';  {+ расширение файла конфигурации}
          {-endif2}
     End;
  {-endif1}

  {определяем каталог с проектом}
  CFG.StanPrjDirName        := Dialog_CreateNewProject.InitialDir;
  If (CFG.StanPrjDirName [Length (CFG.StanPrjDirName)] <> '\')
     Then CFG.StanPrjDirName := CFG.StanPrjDirName + '\'
     Else;
  {-endif1}

  {имя файла объектов}
  CFG.StanPrjKolObjName   := CFG.StanPrjName+'_kolobj.js';
  {имя файла топологии}
  CFG.StanPrjTopologyName := CFG.StanPrjName+'_topolog.js';

  If (FileExists (CFG.StanPrjFFName) = TRUE) { файл конфигурации существует }
     Then Begin
          MessageDlg ('Создание проекта ... ',
                      'Проект STAN ['+CFG.StanPrjFFName+'] существует.' +
                      'Определите новое имя проекта, либо используйте <Открыть проект (*.spr) ...>',
                      mtError, [mbOk], '0');

          {"сбрасываем" все имена}
          CFG.StanPrjName         := ''; {имя проекта}
          CFG.StanPrjFFName       := ''; {полный путь + имя проекта с расширением}
          CFG.StanPrjDirName      := ''; {Только путь}
          CFG.StanPrjKolObjName   := '';
          CFG.StanPrjTopologyName := '';

          Exit;
     End
     Else;
  {-endif1}

  {Конфигурация}
  KO.TUMS.Count := 0;
  KO.MSTU.Count := 0;

  //{оформляем заголовки таблицы}
  (Menu_StanProject.Items [0]).Items [2].Enabled := TRUE;   { "Сохранить" }
  (Menu_StanProject.Items [0]).Items [3].Enabled := TRUE;   { "Сохранить как ..." }
  (Menu_StanProject.Items [0]).Items [4].Enabled := TRUE;   { "Закрыть" }
  (Menu_StanProject.Items [0]).Items [0].Enabled := FALSE;  { "Создать ..." }
  (Menu_StanProject.Items [0]).Items [1].Enabled := FALSE;  { "Открыть" }
  (Menu_StanProject.Items [0]).Items [5].Enabled := TRUE;   { "Выход" }
  (Menu_StanProject.Items [1]).Items [0].Enabled := TRUE;
  (Menu_StanProject.Items [1]).Items [1].Enabled := TRUE;
  (Menu_StanProject.Items [1]).Enabled := TRUE;

  Menu_Config_LINPZUGen;

  StringGrid_TopologData.Visible := TRUE;
  StringGrid_ColumnsName.Visible := TRUE;
  btn_NewSubline.Visible         := TRUE;
  btn_DeleteSubline.Visible      := TRUE;
  btn_EditLine.Visible           := TRUE;
  btn_LineUp.Visible             := TRUE;
  btn_LineDown.Visible           := TRUE;
  btn_SublineUp.Visible          := TRUE;
  btn_SublineDown.Visible        := TRUE;
  btn_NewLine.Visible            := TRUE;
  btn_CheckDepend.Visible        := TRUE;
  {Поиск}
  Btn_Find.Visible := TRUE;
  Btn_FindNext.Visible := TRUE;
  Edit_FindText.Visible := TRUE;
  Btn_Find.Enabled := FALSE;
  Btn_FindNext.Enabled := FALSE;
  Edit_FindText.Enabled := TRUE;
  Edit_FindText.Text := '';

  TopologyList.Clear; {удаляем старые данные}
  ConfigureVisualGrid_Topology (TopologyList);  { заполняем сетку }
  Caption := 'БД Сервер->STAN (aka FoxPro) <'+CFG.StanPrjName+':'+CFG.StanPrjFFName+'>';

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

    TopologDbf.First;
    while (TopologDbf.EOF <> TRUE) do {читаем данные}
    begin
       {N_STR}  TopologyLine.Line    := TopologDbf.Fields [0].AsInteger;
       {N_EL}   TopologyLine.SubLine := TopologDbf.Fields [1].AsInteger;
       {NAME_E} TopologyLine.Id      := ConvertEncoding (TopologDbf.Fields [3].AsString, 'cp866', 'utf8');
       {NAME_R} TopologyLine.Name    := ConvertEncoding (TopologDbf.Fields [2].AsString, 'cp866', 'utf8');;
       {SL}     TopologyLine.Link    := ConvertEncoding (TopologDbf.Fields [4].AsString, 'cp866', 'utf8');;
       {STOYKA} TopologyLine.UVK     := TopologDbf.Fields [5].AsInteger;
       TopologyList.SortAdd(TopologyLine);
       TopologDbf.Next;
    end;
    TopologE.Destroy;
    TopologDbf.Destroy;

    Application.MessageBox ('В меню "Конфигурация" определите количество стоек и количество объектов!',
                            'Загрузка', MB_OK);

    btn_NewSubline.SetFocus;
  Except
    Application.MessageBox ('Неправильный формат topolog.dbf', 'f.ck.p', MB_OK);
  end;

end;

{ === Перезагружаем табличку-grid отображения топологии ====================== }
procedure TSTANMain.ConfigureVisualGrid_Topology (var list_source : TTopologyList);
var
  strgrid_index : longword;   { индексы доступа }
  li            : longword;
  str_tmp       : AnsiString;
  ptplg         : ^TTopology; { элемент списка }

begin
  StringGrid_TopologData.Clean;

  {оформляем заголовки таблицы}
  StringGrid_ColumnsName.ColCount   := 7;
  StringGrid_ColumnsName.RowCount   := 1;
  StringGrid_ColumnsName.FixedCols  := 1;
  StringGrid_ColumnsName.FixedRows  := 1;
  StringGrid_ColumnsName.Cells[1,0] := 'N_STR';  {TopologDbf.FieldDefs [0].Name;}
  StringGrid_ColumnsName.Cells[2,0] := 'N_EL';   {TopologDbf.FieldDefs [1].Name;}
  StringGrid_ColumnsName.Cells[3,0] := 'NAME_E'; {TopologDbf.FieldDefs [2].Name;}
  StringGrid_ColumnsName.Cells[4,0] := 'NAME_R'; {TopologDbf.FieldDefs [3].Name;}
  StringGrid_ColumnsName.Cells[5,0] := 'SL';     {TopologDbf.FieldDefs [4].Name;}
  StringGrid_ColumnsName.Cells[6,0] := 'STOYKA'; {TopologDbf.FieldDefs [5].Name;}
  StringGrid_ColumnsName.ColWidths[0] := 50;
  StringGrid_ColumnsName.ColWidths[1] := 70;
  StringGrid_ColumnsName.ColWidths[2] := 70;
  StringGrid_ColumnsName.ColWidths[3] := 150;
  StringGrid_ColumnsName.ColWidths[4] := 150;
  StringGrid_ColumnsName.ColWidths[5] := 150;
  StringGrid_ColumnsName.ColWidths[6] := 70;

  StringGrid_TopologData.ColCount   := 7;
  StringGrid_TopologData.RowCount   := 0;
  StringGrid_TopologData.FixedCols  := 1;
  StringGrid_TopologData.FixedRows  := 0;
  StringGrid_TopologData.ColWidths[0] := StringGrid_ColumnsName.ColWidths[0];
  StringGrid_TopologData.ColWidths[1] := StringGrid_ColumnsName.ColWidths[1];
  StringGrid_TopologData.ColWidths[2] := StringGrid_ColumnsName.ColWidths[2];
  StringGrid_TopologData.ColWidths[3] := StringGrid_ColumnsName.ColWidths[3];
  StringGrid_TopologData.ColWidths[4] := StringGrid_ColumnsName.ColWidths[4];
  StringGrid_TopologData.ColWidths[5] := StringGrid_ColumnsName.ColWidths[5];
  StringGrid_TopologData.ColWidths[6] := StringGrid_ColumnsName.ColWidths[6];

  {формируем и форматируем таблицу}
  StringGrid_TopologData.RowCount := list_source.Count;
  for strgrid_index := 1 to TopologyList.Count do
  begin
     li := strgrid_index - 1;
     ptplg := TopologyList.Items[li];

     str (strgrid_index, str_tmp);
     StringGrid_TopologData.Cells[0,li] := str_tmp;      { порядковый номер }
     str (ptplg^.Line, str_tmp);
     StringGrid_TopologData.Cells[1,li] := str_tmp;      { №строки }
     str (ptplg^.SubLine, str_tmp);
     StringGrid_TopologData.Cells[2,li] := str_tmp;      { №подстроки }
     StringGrid_TopologData.Cells[3,li] := ptplg^.Id;    { имя-идентификатор }
     //str_tmp:=ConvertEncoding (ptplg^.Name, 'cp866', 'utf8');
     StringGrid_TopologData.Cells[4,li] := ptplg^.Name;  { имя }
     StringGrid_TopologData.Cells[5,li] := ptplg^.Link;  { переход-идентификатор }
     str (ptplg^.UVK, str_tmp);
     StringGrid_TopologData.Cells[6,li] := str_tmp;       { стойка }
  end;

end;

{=== Открыть существующий проект ==============================================}
procedure TSTANMain.Menu_Project_OpenClick(Sender: TObject);
var
  {dialog's}
  DlgRes           : BOOLEAN;           {dialog_execute_result}
  MsgRes           : TModalResult;      {message_execute_result}
  StanPrjFullName  : string;            {имя файла проекта выбранное в диалоговом окне - временная строка}
  {file's routine}
  PosFExt          : SizeInt;
  StanPrjFD        : TextFile;
  TopoFD           : TextFile;
  KOFD             : TextFile;
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
  tli              : Longint;       { индекс цикла списка }
  koi              : Longint;
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
  CFG.StanPrjName         := ''; {имя проекта}
  CFG.StanPrjFFName       := ''; {полный путь + имя проекта с расширением}
  CFG.StanPrjDirName      := ''; {Только путь}
  CFG.StanPrjKolObjName   := '';
  CFG.StanPrjTopologyName := '';

  {определяем название проекта}
  StanPrjFullName    := Dialog_OpenProject.FileName;    { возвращается полный путь, даже если нет файла }
  CFG.StanPrjName := ExtractFileName (StanPrjFullName);
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
  CFG.StanPrjFFName := StanPrjFullName; { ExpandFileName нужно? }
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

  {определяем каталог с файлами конфигурации}
  json_key       :=  'STAN.Directory';
  json_value     := json_data.FindPath (json_key).AsString;
  CFG.StanPrjDirName := json_value;

  {определяем файл с описанием топологии}
  json_key       :=  'STAN.KolObj';
  json_value     := json_data.FindPath (json_key).AsString;
  //json_valueutf8 := ConvertEncoding (json_value, 'cp866', 'utf8');
  CFG.StanPrjKolObjName :=  {CFG.StanPrjDirName +} json_value; //json_valueutf8;

  {определяем файл с описанием топологии}
  json_key       :=  'STAN.Topology';
  json_value     := json_data.FindPath (json_key).AsString;
  //json_valueutf8 := ConvertEncoding (json_value, 'cp866', 'utf8');
  CFG.StanPrjTopologyName :=  {CFG.StanPrjDirName +} json_value; //json_valueutf8;

  FreeAndNil (json_data);
  FreeAndNil (json_parser);

  if (FileExists (CFG.StanPrjDirName+CFG.StanPrjKolObjName) = TRUE) { файл топологии(.js) существует }
     then begin
          {чтение файла топологии в строку}
          json_strline := '';
          json_strfull := '';
          AssignFile (KOFD, CFG.StanPrjDirName+CFG.StanPrjKolObjName);
          Reset (KOFD);
          json_strfull := '';
          while (not (eof (KOFD))) do
          begin
             ReadLn (KOFD, json_strline);
             json_strfull := json_strfull + json_strline;
          end; { while ... }
          CloseFile (KOFD);
          {преобразование кодировки}
          json_strutf8 := ConvertEncoding (json_strfull, 'cp866', 'utf8');

          {находим расположение файла топологии}
          json_parser    := TJSONParser.Create(json_strutf8,DefaultOptions);
          json_data      := json_parser.Parse;// as TJSONObject;
          {определяем директорию с проектом}
          json_key       := 'KolObj.TUMS.Count';
          json_value     := json_data.FindPath (json_key).AsString;
          KO.TUMS.Count  := StrToInt (json_value);
          for koi := 1 to KO.TUMS.Count do
          begin
             json_key       := 'KolObj.TUMS.LINPZU.'+IntToStr (koi)+'.C';
             json_value     := json_data.FindPath (json_key).AsString;
             KO.TUMS.Items [koi].C := StrToInt (json_value);
             json_key       := 'KolObj.TUMS.LINPZU.'+IntToStr (koi)+'.E';
             json_value     := json_data.FindPath (json_key).AsString;
             KO.TUMS.Items [koi].E := StrToInt (json_value);
             json_key       := 'KolObj.TUMS.LINPZU.'+IntToStr (koi)+'.Q';
             json_value     := json_data.FindPath (json_key).AsString;
             KO.TUMS.Items [koi].Q := StrToInt (json_value);
             json_key       := 'KolObj.TUMS.LINPZU.'+IntToStr (koi)+'.F';
             json_value     := json_data.FindPath (json_key).AsString;
             KO.TUMS.Items [koi].F := StrToInt (json_value);
             json_key       := 'KolObj.TUMS.LINPZU.'+IntToStr (koi)+'.I';
             json_value     := json_data.FindPath (json_key).AsString;
             KO.TUMS.Items [koi].I := StrToInt (json_value);
             json_key       := 'KolObj.TUMS.LINPZU.'+IntToStr (koi)+'.L';
             json_value     := json_data.FindPath (json_key).AsString;
             KO.TUMS.Items [koi].L := StrToInt (json_value);
          end;

          json_key       := 'KolObj.MSTU.Count';
          json_value     := json_data.FindPath (json_key).AsString;
          KO.MSTU.Count  := StrToInt (json_value);
          for koi := 1 to KO.MSTU.Count do
          begin
             json_key       := 'KolObj.MSTU.LINPZU.'+IntToStr (koi)+'.C';
             json_value     := json_data.FindPath (json_key).AsString;
             KO.MSTU.Items [koi].C := StrToInt (json_value);
             json_key       := 'KolObj.MSTU.LINPZU.'+IntToStr (koi)+'.E';
             json_value     := json_data.FindPath (json_key).AsString;
             KO.MSTU.Items [koi].E := StrToInt (json_value);
             json_key       := 'KolObj.MSTU.LINPZU.'+IntToStr (koi)+'.Q';
             json_value     := json_data.FindPath (json_key).AsString;
             KO.MSTU.Items [koi].Q := StrToInt (json_value);
             json_key       := 'KolObj.MSTU.LINPZU.'+IntToStr (koi)+'.F';
             json_value     := json_data.FindPath (json_key).AsString;
             KO.MSTU.Items [koi].F := StrToInt (json_value);
             json_key       := 'KolObj.MSTU.LINPZU.'+IntToStr (koi)+'.I';
             json_value     := json_data.FindPath (json_key).AsString;
             KO.MSTU.Items [koi].I := StrToInt (json_value);
             json_key       := 'KolObj.MSTU.LINPZU.'+IntToStr (koi)+'.L';
             json_value     := json_data.FindPath (json_key).AsString;
             KO.MSTU.Items [koi].L := StrToInt (json_value);
          end;

          FreeAndNil (json_data);
          FreeAndNil (json_parser);
     end
     else begin
     end;
  {-endif1}

  if (FileExists (CFG.StanPrjDirName+CFG.StanPrjTopologyName) = TRUE) { файл топологии(.js) существует }
     then begin
          TopologyList.Clear; {сброс текущей топологии}

          {чтение файла топологии в строку}
          json_strline := '';
          json_strfull := '';
          AssignFile (TopoFD, CFG.StanPrjDirName+CFG.StanPrjTopologyName);
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

             TopologyList.SortAdd (TopologyLine);
          end; { end for ... }
          FreeAndNil (json_data);
          FreeAndNil (json_parser);

          ConfigureVisualGrid_Topology (TopologyList);  { заполняем сетку }
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
             TopologyList := TTopologyList.Create;

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
                  TopologyList.SortAdd(TopologyLine);
                  TopologDbf.Next;
              end;
              TopologDbf.Destroy;
              TopologE.Destroy;

              ConfigureVisualGrid_Topology (TopologyList);  { заполняем сетку }

              Application.MessageBox ('В меню "Конфигурация" определите количество стоек и количество объектов!',
                                      'Загрузка', MB_OK);
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
  {Конфигурация}
  (Menu_StanProject.Items [1]).Items [0].Enabled := TRUE;
  (Menu_StanProject.Items [1]).Items [1].Enabled := TRUE;
  (Menu_StanProject.Items [1]).Enabled := TRUE;

  Menu_Config_LINPZUGen;

  StringGrid_TopologData.Visible := TRUE;
  StringGrid_ColumnsName.Visible := TRUE;
  btn_NewSubline.Visible    := TRUE;
  btn_DeleteSubline.Visible := TRUE;
  btn_EditLine.Visible   := TRUE;
  btn_LineUp.Visible  := TRUE;
  btn_LineDown.Visible:= TRUE;
  btn_SublineUp.Visible  := TRUE;
  btn_SublineDown.Visible:= TRUE;
  btn_NewLine.Visible:= TRUE;
  btn_CheckDepend.Visible:= TRUE;
  {Поиск}
  Btn_Find.Visible := TRUE;
  Btn_FindNext.Visible := TRUE;
  Edit_FindText.Visible := TRUE;
  Btn_Find.Enabled := FALSE;
  Btn_FindNext.Enabled := FALSE;
  Edit_FindText.Enabled := TRUE;
  Edit_FindText.Text := '';

  Caption := 'БД Сервер->STAN (aka FoxPro) <'+CFG.StanPrjName+':'+CFG.StanPrjFFName+'>';
end;

procedure TSTANMain.Menu_Project_SaveAsClick(Sender: TObject);
var
  {dialog's}
  DlgRes           : BOOLEAN;           {dialog_execute_result}
  //MsgRes           : TModalResult;      {message_execute_result}
  StanPrjFullName  : string;  {каталог + имя файла выбранное в диалоговом окне - временная строка}
  //StanPrjName      : string;  {имя файла выбранное в диалоговом окне - временная строка}
  PosFExt          : SizeInt;
begin

  Dialog_SaveAsProject.Title := 'Сохранить проект STAN с новым именем ... ';
  DlgRes := Dialog_SaveAsProject.Execute;
  If (DlgRes = FALSE)
     Then exit { не создаем проект }
     Else;

  StanPrjFullName := Dialog_SaveAsProject.FileName;  { возвращается полный путь, даже если нет файла }

  {определяем каталог с файлом проекта}
  PosFExt := pos ('.spr', StanPrjFullName); { Поиск расширения фала }
  If (PosFExt = 0) { Нет расширения }
     Then StanPrjFullName := StanPrjFullName + '.spr'  {+ расширение файла конфигурации}
     Else Begin { есть расширение? }
          If (PosFExt+3 = Length (StanPrjFullName)) {есть}
             Then
             Else StanPrjFullName := StanPrjFullName + '.spr';  {+ расширение файла конфигурации}
          {-endif2}
     end;
  {-endif1}

  if (FileExists (StanPrjFullName) = TRUE) { файл конфигурации существует }
     then begin
          MessageDlg ('Сохранение проекта как ... ',
                      'Проект STAN ['+StanPrjFullName+'] уже существует. ' +
                      'Определите новое имя или выберите другой каталог проекта.',
                      mtError, [mbOk], '0');
          Exit;
     end
     else;
  {-endif1}

  {"сбрасываем" все имена}
  CFG.StanPrjName         := ''; {имя проекта}
  CFG.StanPrjFFName       := '';
  CFG.StanPrjDirName      := '';
  CFG.StanPrjKolObjName   := '';
  CFG.StanPrjTopologyName := '';

  {новые определения}
  CFG.StanPrjName := ExtractFileName (StanPrjFullName);
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
  CFG.StanPrjFFName         :=  StanPrjFullName;
  {определяем каталог с проектом}
  CFG.StanPrjDirName        := Dialog_SaveAsProject.InitialDir;
  If (CFG.StanPrjDirName [Length (CFG.StanPrjDirName)] <> '\')
     Then CFG.StanPrjDirName := CFG.StanPrjDirName + '\'
     Else;
  {-endif1}
  {имя файла объектов}
  CFG.StanPrjKolObjName   := CFG.StanPrjName+'_kolobj.js';
  {имя файла топологии}
  CFG.StanPrjTopologyName := CFG.StanPrjName+'_topolog.js';

  SaveProject (CFG);
  Caption := 'БД Сервер->STAN (aka FoxPro) <'+CFG.StanPrjName+':'+CFG.StanPrjFFName+'>';

  DependIsChange := FALSE;
End;

procedure TSTANMain.Menu_Project_ExitClick(Sender: TObject);
var
  {dialog's}
  MsgRes  : TModalResult; {message_execute_result}
begin
  {MsgRes := MessageDlg ('Работа с проектом ... ',
                        'Закрыть проект '+CFG.StanPrjName+' ('+
                        CFG.StanPrjFFName+') и выйти из программы ?',
                        mtConfirmation, [mbYes, mbNo], '0');}

  MsgRes := MessageDlg ('Работа с проектом ... ', 'Выйти из программы ?',
                        mtConfirmation, [mbYes, mbNo], '0');

  if (MsgRes <> mrYes)
     then exit
     else;
  {-endif1}

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
begin
  SaveProject (CFG);
  DependIsChange := FALSE;
end;

{=== Редактирование элемента строки топологии =================================}
procedure TSTANMain.StringGrid_TopologDataDblClick(Sender: TObject);
var
  topolog_row   : Integer;     { выбранная строка в списке }
  TopologyLine  : TTopology;   { значения }
  ptplg         : ^TTopology;
begin
  topolog_row := StringGrid_TopologData.Row;
  if (topolog_row < 0)
     then exit
     else;
  {-endif0}

  ptplg := TopologyList.Items[topolog_row]; { нумерация с  }

  TopologyLine := ptplg^;
  Form_TopologyElement.TopologFieldsInit (TopologyLine);
  Form_TopologyElement.ShowModal;

  DependIsChange := TRUE;
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

{=== Добавление новой подстроки ===============================================}
procedure TSTANMain.btn_NewSublineClick(Sender: TObject);
var
  topolog_row     : Integer;     { выбранная строка в списке }
  TopologyElement : TTopology;   { значения }
  pTplg_new       : ^TTopology;
  TopRow_old      : Integer;     { сохранение позиции отображения строк stringgrid }
{---}
begin
  { память для нового элемента в список }
  new (pTplg_new);
  if (pTplg_new = NIL)
     then begin
          Application.MessageBox ('Нехватка памяти. TSTANMain.btn_NewSublineClick (...)', 'f.ck.p', MB_OK);
          exit;
     end
     else;
  {-endif0}

  //TopologyElementReset (TopologyElement);
  TopologyElement.Line    := 0;
  TopologyElement.SubLine := 0;
  TopologyElement.Id      := '';
  TopologyElement.Name    := '';
  TopologyElement.Link    := '';
  TopologyElement.UVK     := 0;
  pTplg_new^ :=  TopologyElement; { копия значения }

  TopRow_old := StringGrid_TopologData.TopRow;    { первая отображаемая строка - сохраняем }

  if (TopologyList.Count = 0)
     Then topolog_row := 0
     Else Begin
          topolog_row := StringGrid_TopologData.Row;
          topolog_row := topolog_row + 1;
     End;
  {-endif0}

  TopologyList.Insert(topolog_row, pTplg_new);  { добавляем новоый элемент строки топологии }
  TopologyList.TopologyListReorderAfterAdd;     { корректировка индексов }
  ConfigureVisualGrid_Topology (TopologyList);  { перерисовываем таблицу }

  StringGrid_TopologData.Row := topolog_row;    { выделяем новую строку }

  StringGrid_TopologData.TopRow := TopRow_old;  { восстанавливаем первую отображаемую строку }

  DependIsChange := TRUE;
end;

procedure TSTANMain.Edit_FindTextChange(Sender: TObject);
begin
  If (Edit_FindText.Text <> '')
     Then Begin
          Btn_Find.Enabled := TRUE;
          Btn_FindNext.Enabled := TRUE;
     End
     Else Begin
          Btn_Find.Enabled := FALSE;
          Btn_FindNext.Enabled := FALSE;
     End;
end;

{=== Удаление подстроки =======================================================}
procedure TSTANMain.btn_DeleteSublineClick(Sender: TObject);
var
  topolog_row     : Integer;     { выбранная строка в списке }
  pTplg           : ^TTopology;
  TopRow_old      : Integer;     { сохранение позиции отображения строк stringgrid }
{---}
begin
  topolog_row := StringGrid_TopologData.Row;
  if (topolog_row < 0)
     then exit
     else;
  {-endif0}

  pTplg := TopologyList.Items [topolog_row];
  pTplg^.Line    := 0;
  pTplg^.SubLine := 0;
  pTplg^.Id      := '';
  pTplg^.Name    := '';
  pTplg^.Link    := '';
  pTplg^.UVK     := 0;

  TopRow_old := StringGrid_TopologData.TopRow;  { первая отображаемая строка - сохраняем }

  TopologyList.TopologyListReorderAfterRemove;  { корректировка индексов }
  TopologyList.Delete(topolog_row);
  ConfigureVisualGrid_Topology (TopologyList);  { перерисовываем таблицу }

  StringGrid_TopologData.Row := topolog_row;    { выделяем новую строку }

  StringGrid_TopologData.TopRow := TopRow_old;  { восстанавливаем первую отображаемую строку }

  DependIsChange := TRUE;
end;

{=== Перемещение строки зависимостей "наверх" =================================}
procedure TSTANMain.btn_LineUpClick(Sender: TObject);
{---}
var
  topolog_row     : Integer;     { выбранная строка в списке }
  pTplg           : ^TTopology;
  LineValue       : Integer;
  TopRow_old      : Integer;
  pTplg2          : ^TTopology;
  pTplg3          : ^TTopology;
  c               : Integer;
  tli             : Integer;
{---}
begin
  topolog_row := StringGrid_TopologData.Row;
  if (topolog_row < 0) { нет ничего }
     then exit
     else;
  {-endif0}

  pTplg := TopologyList.Items [topolog_row];  { элеент строки }
  LineValue := pTplg^.Line; { номер строки }

  if (pTplg^.Line = 1) { нече двигать первую строку вверх }
     then exit { Application.MessageBox ('Первая строка зависимостей!', 'ВНИМАНИЕ !', MB_OK); }
     else;
  {-endif0}

  if (pTplg^.SubLine <> 1)
     then begin
          Application.MessageBox ('Для перемещения укажите первый элемент строки зависимостей!','ВНИМАНИЕ !', MB_OK);
          exit;
     end
     else;
  {-endif0}

  { двигаем не первую строчку и стоим на певом элементе }
  if (topolog_row = 0)
     then begin { счет строчек зависимоcтей начинается не с "1" }
          {ничего не делаем !!!!}
     end
     else begin
          pTplg2 := TopologyList.Items [topolog_row-1];
          if (pTplg2^.Line+1 = pTplg^.Line)
             then begin
                  Application.MessageBox ('Соседние строки зависимостей (это функция не объединения строк)!',
                                          'ВНИМАНИЕ !', MB_OK);
                  exit;
             end
             else;
          {-endif1}
     end;
  {-endif0}

  TopRow_old := StringGrid_TopologData.TopRow;  { первая отображаемая строка - сохраняем }

  c := TopologyList.Count;
  for tli := topolog_row to c-1 do
  begin
      pTplg3  := TopologyList.Items [tli];
      if (pTplg3^.Line <> LineValue)
         then break
         else;
      pTplg3^.Line := LineValue-1;
  end;

  ConfigureVisualGrid_Topology (TopologyList);  { перерисовываем таблицу }

  StringGrid_TopologData.Row := topolog_row;    { выделяем новую строку }
  StringGrid_TopologData.TopRow := TopRow_old;  { восстанавливаем первую отображаемую строку }

  DependIsChange := TRUE;
end;

{=== Перемещение строки зависимостей "вниз" ===================================}
procedure TSTANMain.btn_LineDownClick(Sender: TObject);
{---}
var
  topolog_row     : Integer;     { выбранная строка в списке }
  pTplg           : ^TTopology;
  LineValue       : Integer;
  TopRow_old      : Integer;
  pTplg2          : ^TTopology;
  pTplg3          : ^TTopology;
  tli             : Integer;
{---}
begin
  topolog_row := StringGrid_TopologData.Row;
  if (topolog_row < 0) { нет ничего }
     then exit
     else;
  {-endif0}

  pTplg := TopologyList.Items [topolog_row];  { элеент строки }
  LineValue := pTplg^.Line; { номер строки }

  if (topolog_row <> TopologyList.Count-1) { не последний элемент }
     then begin
          pTplg2 := TopologyList.Items [topolog_row+1];
          if (pTplg2^.SubLine <> 1)
             then begin
                  Application.MessageBox ('Для перемещения укажите последний элемент строки зависимостей!',
                                          'ВНИМАНИЕ !', MB_OK);
                  exit;
             end
             else;
          {-endif1}

          if (pTplg2^.Line = pTplg^.Line+1)
             then begin
                  Application.MessageBox ('Соседние строки зависимостей (это функция не объединения строк)!',
                                          'ВНИМАНИЕ !', MB_OK);
                  exit;
             end
             else;
          {-endif1}
     end
     else;
  {-endif0}

  TopRow_old := StringGrid_TopologData.TopRow;  { первая отображаемая строка - сохраняем }

  LineValue := pTplg^.Line;
  for tli := topolog_row downto 0 do
  begin
      pTplg3  := TopologyList.Items [tli];
      if (pTplg3^.Line <> LineValue)
         then break
         else;
      pTplg3^.Line := LineValue+1;
  end;

  ConfigureVisualGrid_Topology (TopologyList);  { перерисовываем таблицу }

  StringGrid_TopologData.Row := topolog_row;    { выделяем новую строку }
  StringGrid_TopologData.TopRow := TopRow_old;  { восстанавливаем первую отображаемую строку }

  DependIsChange := TRUE;
end;

{=== Перемещение подстроки зависимостей "вверх" ================================}
procedure TSTANMain.btn_SublineUpClick(Sender: TObject);
var
  topolog_row     : Integer;     { выбранная строка в списке }
  pTplg           : ^TTopology;
  pTplg2          : ^TTopology;
  TopRow_old      : Integer;     { сохранение позиции отображения строк stringgrid }
  ExchangeVal     : Integer;
{---}
begin
  topolog_row := StringGrid_TopologData.Row;

  if (topolog_row <= 0)  { либо ничего нет, либо первый элемент }
     then exit
     else;
  {-endif0}

  pTplg  := TopologyList.Items [topolog_row];
  pTplg2 := TopologyList.Items [topolog_row-1];

  if (pTplg^.SubLine = 1)
     then begin
          Application.MessageBox ('Первый элемент строки зависимостей. При необходимости отредактируйте нумерацию вручную!',
                                  'ВНИМАНИЕ !', MB_OK);
          exit;
     end
     else;
  {-endif0}

  if (pTplg^.Line <> pTplg2^.Line)
     then begin
          Application.MessageBox ('Разные строки зависимостей. При необходимости отредактируйте нумерацию вручную!',
                                  'ВНИМАНИЕ !', MB_OK);
          exit;
     end
     else;
  {-endif0}

  TopRow_old := StringGrid_TopologData.TopRow;  { первая отображаемая строка - сохраняем }

  { замена нумерации подстрок }
  ExchangeVal     := pTplg2^.Subline;
  pTplg2^.Subline := pTplg^.Subline;
  pTplg^.Subline  := ExchangeVal;

  { смена указателей }
  TopologyList.Items [topolog_row-1] := pTplg;
  TopologyList.Items [topolog_row]   := pTplg2;

  ConfigureVisualGrid_Topology (TopologyList);  { перерисовываем таблицу }

  StringGrid_TopologData.Row := topolog_row-1;    { выделяем новую строку }
  StringGrid_TopologData.TopRow := TopRow_old;  { восстанавливаем первую отображаемую строку }

  DependIsChange := TRUE;
end;

{=== Перемещение подстроки зависимостей "вверх" ===============================}
procedure TSTANMain.btn_SublineDownClick(Sender: TObject);
var
  topolog_row     : Integer;     { выбранная строка в списке }
  pTplg           : ^TTopology;
  pTplg2          : ^TTopology;
  TopRow_old      : Integer;     { сохранение позиции отображения строк stringgrid }
  ExchangeVal     : Integer;
{---}
begin
  topolog_row := StringGrid_TopologData.Row;

  if (topolog_row < 0)  { ничего нет }
     then exit
     else;
  {-endif0}

  if (topolog_row = StringGrid_TopologData.RowCount-1)  { последний элемент }
     then exit
     else;
  {-endif0}

  pTplg  := TopologyList.Items [topolog_row];
  pTplg2 := TopologyList.Items [topolog_row+1];

  if (pTplg^.Line <> pTplg2^.Line)
     then begin
          Application.MessageBox ('Разные строки зависимостей. Отредактируйте нумерацию вручную!',
                                  'ВНИМАНИЕ !', MB_OK);
          exit;
     end
     else;
  {-endif0}

  TopRow_old := StringGrid_TopologData.TopRow;  { первая отображаемая строка - сохраняем }

  { замена нумерации подстрок }
  ExchangeVal     := pTplg2^.Subline;
  pTplg2^.Subline := pTplg^.Subline;
  pTplg^.Subline  := ExchangeVal;

  { смена указателей }
  TopologyList.Items [topolog_row]   := pTplg2;
  TopologyList.Items [topolog_row+1] := pTplg;

  ConfigureVisualGrid_Topology (TopologyList);  { перерисовываем таблицу }

  StringGrid_TopologData.Row := topolog_row+1;    { выделяем новую строку }
  StringGrid_TopologData.TopRow := TopRow_old;  { восстанавливаем первую отображаемую строку }

  DependIsChange := TRUE;
end;

{=== Создание новой строки. Всегда добавляется в конец ========================}
procedure TSTANMain.btn_NewLineClick(Sender: TObject);
var
  //topolog_row     : Integer;     { выбранная строка в списке }
  TopologyElement : TTopology;   { значения }
  pTplg_new       : ^TTopology;
  pTplg2          : ^TTopology;
  //TopRow_old      : Integer;     { сохранение позиции отображения строк stringgrid }
{---}
begin
  { память для нового элемента в список }
  new (pTplg_new);
  if (pTplg_new = NIL)
     then begin
          Application.MessageBox ('Нехватка памяти. TSTANMain.btn_NewLineClick (...)', 'f.ck.p', MB_OK);
          exit;
     end
     else;
  {-endif0}

  //TopologyElementReset (TopologyElement);
  TopologyElement.Line    := 0;
  TopologyElement.SubLine := 0;
  TopologyElement.Id      := '';
  TopologyElement.Name    := '';
  TopologyElement.Link    := '';
  TopologyElement.UVK     := 0;

  {определяем номер последней строки}
  if (TopologyList.Count > 0)
     then begin
          pTplg2 := TopologyList.Last;
          TopologyElement.Line := pTplg2^.Line+1;
     end
     else begin
          TopologyElement.Line := 1;
     end;
  {-endif0}
  TopologyElement.SubLine := 1;
  pTplg_new^ :=  TopologyElement; { копия значения }

  TopologyList.Add(pTplg_new);  { добавляем новый элемент строки топологии }
  ConfigureVisualGrid_Topology (TopologyList);  { перерисовываем таблицу }

  StringGrid_TopologData.Row := TopologyList.Count;    { выделяем новую строку }

  DependIsChange := TRUE;
end;

procedure TSTANMain.Btn_FindClick(Sender: TObject);
{===}
var
  tplist_count : Integer;
  tplist_index : Integer;
  tpl_element  : PTTopology;
  st           : String;
{===}
begin
  st := Edit_FindText.Text;
  tplist_count := TopologyList.Count;
  For tplist_index := 1 To tplist_count Do
  Begin
     tpl_element := TopologyList.Items[tplist_index-1];
     If (tpl_element = NIL)
        Then Continue
        Else;

     If (Pos (st, tpl_element^.Name) <> 0)
        Then Begin
             SearchIndex := tplist_index;
             StringGrid_TopologData.Row := tplist_index-1;    { выделяем новую строку }
             StringGrid_TopologData.TopRow := tplist_index-1; { восстанавливаем первую отображаемую строку }
             Exit;
        End
        Else;
  End;
  Application.MessageBox ('Нет такого (проверьте регистр)!', 'Поиск', MB_OK);
End;

procedure TSTANMain.Btn_FindNextClick(Sender: TObject);
{===}
var
  tplist_count : Integer;
  tplist_index : Integer;
  tpl_element  : PTTopology;
  st           : String;
{===}
begin
  st := Edit_FindText.Text;
  tplist_count := TopologyList.Count;
  For tplist_index := SearchIndex+1 To tplist_count Do
  Begin
     tpl_element := TopologyList.Items[tplist_index-1];
     If (tpl_element = NIL)
        Then Continue
        Else;

     If (Pos (st, tpl_element^.Name) <> 0)
        Then Begin
             SearchIndex := tplist_index;
             StringGrid_TopologData.Row := tplist_index-1;    { выделяем новую строку }
             StringGrid_TopologData.TopRow := tplist_index-1; { восстанавливаем первую отображаемую строку }
             Exit;
        End
        Else;
  End;
  Application.MessageBox ('Больше нет!', 'Поиск', MB_OK);
End;

{=== Создание (инициализация) главной формы ===================================}
procedure TSTANMain.FormCreate(Sender: TObject);
var
  koi : Integer;
{===}
begin
  { Все меню заблокированы пока, не откроется или создатся проект }
  (Menu_StanProject.Items [0]).Items [2].Enabled := FALSE;  { "Сохранить" }
  (Menu_StanProject.Items [0]).Items [3].Enabled := FALSE;  { "Сохранить как" }
  (Menu_StanProject.Items [0]).Items [4].Enabled := FALSE;  { "Закрыть" }
  {Конфигурация}
  (Menu_StanProject.Items [1]).Items [0].Enabled := FALSE;
  (Menu_StanProject.Items [1]).Items [1].Enabled := FALSE;
  (Menu_StanProject.Items [1]).Enabled := FALSE;

  StringGrid_TopologData.Visible := FALSE;
  StringGrid_ColumnsName.Visible := FALSE;
  btn_NewSubline.Visible    := FALSE;
  btn_DeleteSubline.Visible := FALSE;
  btn_EditLine.Visible   := FALSE;
  btn_LineUp.Visible  := FALSE;
  btn_LineDown.Visible:= FALSE;
  btn_SublineUp.Visible  := FALSE;
  btn_SublineDown.Visible:= FALSE;
  btn_NewLine.Visible:= FALSE;
  btn_CheckDepend.Visible:= FALSE;
  {Поиск}
  Btn_Find.Visible := FALSE;
  Btn_FindNext.Visible := FALSE;
  Edit_FindText.Visible := FALSE;
  Edit_FindText.Text := '';
  SearchIndex := 0;

  (Menu_StanProject.Items [0]).Items [0].Enabled := TRUE;  { "Создать" }
  (Menu_StanProject.Items [0]).Items [1].Enabled := TRUE;  { "Открыть" }

  CFG.StanPrjName         := '';
  CFG.StanPrjDirName      := '';
  CFG.StanPrjFFName       := '';
  CFG.StanPrjTopologyName := '';

  KO.TUMS.Count := 0;
  KO.MSTU.Count := 0;
  For koi := 1 To 256 Do
  Begin
    KO.TUMS.Items [koi].C := 0;
    KO.TUMS.Items [koi].E := 0;
    KO.TUMS.Items [koi].Q := 0;
    KO.TUMS.Items [koi].I := 0;
    KO.TUMS.Items [koi].F := 0;
    KO.TUMS.Items [koi].J := 0;
    KO.TUMS.Items [koi].L := 0;

    KO.MSTU.Items [koi].C := 0;
    KO.MSTU.Items [koi].E := 0;
    KO.MSTU.Items [koi].Q := 0;
    KO.MSTU.Items [koi].I := 0;
    KO.MSTU.Items [koi].F := 0;
    KO.MSTU.Items [koi].J := 0;
    KO.MSTU.Items [koi].L := 0;
  End;
  TopologyList := TTopologyList.Create;

  DependIsChange := FALSE;

  Caption :=  'БД Сервер->STAN (aka FoxPro) <NONE>';
end;

{Вызов меню - определения количества стоек ТУМС и МСТУ}
procedure TSTANMain.Menu_Config_UVKClick(Sender: TObject);
begin
   Form_UVKs.Init(KO.TUMS.Count, KO.MSTU.Count);

   if (Form_UVKs.ShowModal = mrOk)
      Then Begin
           KO.TUMS.Count := Form_UVKs.TUMSs;
           KO.MSTU.Count := Form_UVKs.MSTUs;
      end
      else;
   {endif1}

   {"Ручное" конфигурирование меню для определения LINPZU
     и с ручными обработчиками}
   Menu_Config_LINPZUGen;
end;

{Конфигурирование меню для определения LINPZU}
procedure TSTANMain.Menu_Config_LINPZUGen;
var
  koi : Integer;
  miUVKObj : TMenuItem;
Begin
  Menu_Config_LINPZU.Clear;
  Menu_Config_LINPZU.Enabled:= FALSE;

  for koi := 1 to KO.TUMS.Count do
  begin
     miUVKObj := TMenuItem.Create (self);
     miUVKObj.Caption:='TUMS:' + IntToStr (koi);
     miUVKObj.OnClick := @Menu_Config_LINPZU_Action;
     miUVKObj.Tag := koi;
     Menu_Config_LINPZU.Add(miUVKObj);
  end;

  for koi := 1 to KO.MSTU.Count do
  begin
     if ((koi = 1) And (Menu_Config_LINPZU.Count > 0))
        Then Menu_Config_LINPZU.AddSeparator
        Else;

     miUVKObj := TMenuItem.Create (self);
     miUVKObj.Caption:='MSTU:' + IntToStr (koi);
     miUVKObj.OnClick := @Menu_Config_LINPZU_Action;
     miUVKObj.Tag := koi;
     Menu_Config_LINPZU.Add(miUVKObj);
  end;

  if (Menu_Config_LINPZU.Count > 0)
     Then Menu_Config_LINPZU.Enabled:= TRUE
     Else;
End;

{Обработчик формирования объектов LINPZU}
procedure TSTANMain.Menu_Config_LINPZU_Action (Sender: TObject);
Var
  linpzu : PTLINPZU;
Begin
  {miUVKObj.Tag - LINPZU для ТУМС или МСТУ. Тип в Caption}
  linpzu := NIL;
  if (TMenuItem (Sender).Caption [1] = 'T')
     Then Begin
          linpzu := @KO.TUMS.Items [TMenuItem (Sender).Tag];
          {Form_LINPZUValue.Init(@KO.TUMS.Items [TMenuItem (Sender).Tag]);}
     End
     Else
  if (TMenuItem (Sender).Caption [1] = 'M')
     Then Begin
          linpzu := @KO.MSTU.Items [TMenuItem (Sender).Tag];
          {Form_LINPZUValue.Init(@KO.MSTU.Items [TMenuItem (Sender).Tag]);}
     End
     Else;
  {endif}

  if (linpzu = NIL)
     Then Begin
          Application.MessageBox ('Ошибка программы (неопределен тип стойки)', 'f.ck.p', MB_OK);
          Exit;
     end
     Else;
  {endif}

  {Ввод количества объектов}
  Form_LINPZUValue.Init (linpzu);

  if (Form_LINPZUValue.ShowModal = mrOk)
     Then Begin
          linpzu^.C := Form_LINPZUValue.get_C;
          linpzu^.E := Form_LINPZUValue.get_E;
          linpzu^.Q := Form_LINPZUValue.get_Q;
          linpzu^.F := Form_LINPZUValue.get_F;
          linpzu^.I := Form_LINPZUValue.get_I;
          linpzu^.L := Form_LINPZUValue.get_L;
     end
     else;

end;

{=== Закрыть проект ===========================================================}
procedure TSTANMain.Menu_Project_CloseClick(Sender: TObject);
var
  {dialog's}
  MsgRes  : TModalResult; {message_execute_result}
  koi : Longint;
{===}
begin
  MsgRes := MessageDlg ('Работа с проектом ... ',
                        'Закрыть проект '+CFG.StanPrjName+' ('+
                        CFG.StanPrjFFName+') ?',
                        mtConfirmation, [mbYes, mbNo], '0');

  if (MsgRes <> mrYes)
     then exit
     else;
  {-endif1}

  {"сбрасываем" все имена}
  CFG.StanPrjName         := ''; {имя проекта}
  CFG.StanPrjFFName       := '';
  CFG.StanPrjDirName      := '';
  CFG.StanPrjKolObjName   := '';
  CFG.StanPrjTopologyName := '';

  { Все меню заблокированы пока, не откроется или создатся проект }
  StringGrid_TopologData.Visible := FALSE;
  StringGrid_ColumnsName.Visible := FALSE;
  btn_NewSubline.Visible    := FALSE;
  btn_DeleteSubline.Visible := FALSE;
  btn_EditLine.Visible   := FALSE;
  btn_LineUp.Visible  := FALSE;
  btn_LineDown.Visible:= FALSE;
  btn_SublineUp.Visible  := FALSE;
  btn_SublineDown.Visible:= FALSE;
  btn_NewLine.Visible:= FALSE;
  btn_CheckDepend.Visible:= FALSE;
  {Поиск}
  Btn_Find.Visible := FALSE;
  Btn_FindNext.Visible := FALSE;
  Edit_FindText.Visible := FALSE;
  Btn_Find.Enabled := FALSE;
  Btn_FindNext.Enabled := FALSE;
  Edit_FindText.Enabled := FALSE;
  Edit_FindText.Text := '';

  {Меню}
  (Menu_StanProject.Items [0]).Items [2].Enabled := FALSE;  { "Сохранить" }
  (Menu_StanProject.Items [0]).Items [3].Enabled := FALSE;  { "Сохранить как" }
  (Menu_StanProject.Items [0]).Items [4].Enabled := FALSE;  { "Закрыть" }
  (Menu_StanProject.Items [0]).Items [0].Enabled := TRUE;  { "Создать" }
  (Menu_StanProject.Items [0]).Items [1].Enabled := TRUE;  { "Открыть" }
  {Конфигурация}
  (Menu_StanProject.Items [1]).Items [0].Enabled := FALSE;
  (Menu_StanProject.Items [1]).Items [1].Enabled := FALSE;
  (Menu_StanProject.Items [1]).Enabled := FALSE;

  KO.TUMS.Count := 0;
  KO.MSTU.Count := 0;
  For koi := 1 To 256 Do
  Begin
    KO.TUMS.Items [koi].C := 0;
    KO.TUMS.Items [koi].E := 0;
    KO.TUMS.Items [koi].Q := 0;
    KO.TUMS.Items [koi].I := 0;
    KO.TUMS.Items [koi].F := 0;
    KO.TUMS.Items [koi].J := 0;
    KO.TUMS.Items [koi].L := 0;

    KO.MSTU.Items [koi].C := 0;
    KO.MSTU.Items [koi].E := 0;
    KO.MSTU.Items [koi].Q := 0;
    KO.MSTU.Items [koi].I := 0;
    KO.MSTU.Items [koi].F := 0;
    KO.MSTU.Items [koi].J := 0;
    KO.MSTU.Items [koi].L := 0;
  End;

  TopologyList.Clear;
  StringGrid_TopologData.Clear;

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
{=== Корректировка индексов после включения нового элемента (0,0)==============}
procedure TTopologyList.TopologyListReorderAfterAdd;
var
  tli              : Integer;
  tli2             : Integer;
  c                : Integer;
  pTopologyElement : ^TTopology;
  CurrentLine      : Integer;
  CurrentSubLine   : Integer;

begin

  if (self.Count = 0) {есть что-то?}
     then exit
     else;

  tli := 0;
  pTopologyElement := self.Items [tli];
  {Проверка включения первого элемента}
  {т.к. элемент включается после существующего, то}
  {0,0 в первом элементе говорит о том, что добавили самый первый элемент}
  if ((pTopologyElement^.Line = 0) and (pTopologyElement^.SubLine = 0))
     then begin
          pTopologyElement^.Line    := 1;
          pTopologyElement^.SubLine := 1;
          exit;
     end
     else;
  {-endif0}

  tli := 0;
  pTopologyElement := self.Items [tli];
  CurrentLine    := pTopologyElement^.Line;
  CurrentSubLine := pTopologyElement^.SubLine;

  c := self.Count;
  for tli := 1 to c do { нулевой, т.е. певый пропускаем }
  begin
     pTopologyElement := self.Items [tli];
     if ((pTopologyElement^.Line = 0) and (pTopologyElement^.SubLine = 0))
        then begin
             pTopologyElement^.Line    := CurrentLine;
             pTopologyElement^.SubLine := CurrentSubLine + 1;

             CurrentSubLine := pTopologyElement^.SubLine;

             if (tli+1 = c) {вставка самого последнего элемента}
                then exit
                else;
             {-endif2}

             for tli2 := tli+1 to c do { со следующего и "до упора" }
             begin
                pTopologyElement := self.Items [tli2];
                if (pTopologyElement^.Line = CurrentLine)
                   then begin
                        pTopologyElement^.SubLine := CurrentSubLine + 1;
                        CurrentSubLine := pTopologyElement^.SubLine;
                   end
                   else exit;
             end;
        end
        else;
     {-endif1}

     CurrentLine    := pTopologyElement^.Line;
     CurrentSubLine := pTopologyElement^.SubLine;
  end;

end;

{=== Корректировка индексов после удаления элемента (-1,-1) ===================}
procedure TTopologyList.TopologyListReorderAfterRemove;
var
  tli                   : Integer;
  tli2                  : Integer;
  c                     : Integer;
  pTopologyElement      : ^TTopology;
  pTopologyElement_next : ^TTopology;
  pTopologyElement2     : ^TTopology;
  CurrentLine           : Integer;
  CurrentSubLine        : Integer;

begin

  if (self.Count = 0) {есть что-то?}
     then exit
     else;

  {количество элементов больше нуля}
  c := self.Count;
  for tli := 1 to c do { нулевой, т.е. первый пропускаем }
  begin
     pTopologyElement := self.Items [tli-1];
     {CurrentLine      := pTopologyElement^.Line;}
     {CurrentSubLine   := pTopologyElement^.SubLine;}
     if ((pTopologyElement^.Line = 0) and (pTopologyElement^.SubLine = 0))
        then break
        else continue;
     exit; { ничего не нашли }
     {-endif1}
  end;

  {tli-1 указывает на элемент с "0,0"}
  pTopologyElement := self.Items [tli-1];

  if (tli = c) { последний элемент в списке - выходим }
     then exit
     else;
  {-endif0}

  { следующий элемент }
  pTopologyElement_next := self.Items [tli];

  if (pTopologyElement_next^.SubLine = 1) { удалили последний элемент строки - пересчет не нужен }
     then exit   { да - последний }
     else begin
          CurrentLine := pTopologyElement_next^.Line;

          if (pTopologyElement_next^.SubLine = 2) { удалили первый элемент }
             then begin
                  CurrentSubLine := 1;
             end
             else begin { удалили где-то в середине }
                  CurrentSubLine := pTopologyElement_next^.SubLine-1;
             end;
             {-endif1}

             for tli2 := tli to c do { со следующего и "до упора" }
             begin
                pTopologyElement2 := self.Items [tli2];
                if (pTopologyElement2^.Line = CurrentLine)
                   then begin
                        pTopologyElement2^.SubLine := CurrentSubLine;
                        CurrentSubLine := CurrentSubLine+1;
                   end
                   else exit;
             end; { end for := ... }
     end;
  {-endif0}
end;

{ ---------------------------------------------------------------------------- }
procedure TSTANMain.SaveProject (var _cfg : TTopologyCFG);
var
  StanPrjFD          : TextFile;

  StanPrjKolObjFD    : TextFile;
  koi                : Longint;       { индекс цикла списка }

  StanPrjTopologyFD  : TextFile;
  tli                : Longint;       { индекс цикла списка }
  ptplg              : ^TTopology;
  str_tmp            : AnsiString;
  str_tmp1           : AnsiString;
  topostr            : AnsiString;

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
  json_stan.Add ('Name', _cfg.StanPrjName);
  json_stan.Add ('Directory', _cfg.StanPrjDirName);
  json_stan.Add ('KolObj', _cfg.StanPrjName+'_kolobj.js' {_cfg.StanPrjKolObjFFName});
  json_stan.Add ('Topology', _cfg.StanPrjName+'_topolog.js' {_cfg.StanPrjTopologyFFName});
  json_cfg.Add ('STAN', json_stan);
  cfgstr_utf8  := json_cfg.FormatJSON([foSingleLineArray],5);
  cfgstr_cp866 := ConvertEncoding (cfgstr_utf8, 'utf8', 'cp866');

  AssignFile (StanPrjFD, _cfg.StanPrjDirName+_cfg.StanPrjName+'.spr'{_cfg.StanPrjFFName});
  ReWrite (StanPrjFD);
  WriteLn (StanPrjFD, cfgstr_cp866);
  CloseFile (StanPrjFD);
  {FreeAndNil (json_stan);} {Удалится в json_cfg}
  FreeAndNil (json_cfg);

  {запись ***_kolobj.js конфигурационного файла}
  AssignFile (StanPrjKolObjFD, _cfg.StanPrjDirName+_cfg.StanPrjKolObjName);
  ReWrite (StanPrjKolObjFD);
  WriteLn (StanPrjKolObjFD, '{');
  WriteLn (StanPrjKolObjFD, '   "Type" : "JSON",');
  WriteLn (StanPrjKolObjFD, '   "TimeStamp" : "' + DateToStr (Now)+' '+TimeToStr (Now)+'",');
  WriteLn (StanPrjKolObjFD, '   "KolObj" : {');
  WriteLn (StanPrjKolObjFD, '      "TUMS" : {');
  WriteLn (StanPrjKolObjFD, '         "Count" : "'+IntToStr (KO.TUMS.Count)+'",');
  WriteLn (StanPrjKolObjFD, '         "LINPZU" : {');
  for koi := 1 to KO.TUMS.Count do
  begin
      str_tmp   := '"'+IntToStr (koi)+'" : {';
      Write (StanPrjKolObjFD, '            '+str_tmp);

      str_tmp  := '"C":"'+IntToStr (KO.TUMS.Items [koi].C)+'",';
      str_tmp1 := Format ('%s%'+IntToStr (11-Length (str_tmp))+'s',[str_tmp,' ']);
      Write (StanPrjKolObjFD, str_tmp1);
      str_tmp  := '"E":"'+IntToStr (KO.TUMS.Items [koi].E)+'",';
      str_tmp1 := Format ('%s%'+IntToStr (11-Length (str_tmp))+'s',[str_tmp,' ']);
      Write (StanPrjKolObjFD, str_tmp1);
      str_tmp  := '"Q":"'+IntToStr (KO.TUMS.Items [koi].Q)+'",';
      str_tmp1 := Format ('%s%'+IntToStr (11-Length (str_tmp))+'s',[str_tmp,' ']);
      Write (StanPrjKolObjFD, str_tmp1);
      str_tmp  := '"F":"'+IntToStr (KO.TUMS.Items [koi].F)+'",';
      str_tmp1 := Format ('%s%'+IntToStr (11-Length (str_tmp))+'s',[str_tmp,' ']);
      Write (StanPrjKolObjFD, str_tmp1);
      str_tmp  := '"I":"'+IntToStr (KO.TUMS.Items [koi].I)+'",';
      str_tmp1 := Format ('%s%'+IntToStr (11-Length (str_tmp))+'s',[str_tmp,' ']);
      Write (StanPrjKolObjFD, str_tmp1);
      str_tmp  := '"L":"'+IntToStr (KO.TUMS.Items [koi].L)+'"';
      str_tmp1 := Format ('%s%'+IntToStr (11-Length (str_tmp))+'s',[str_tmp,' ']);
      Write (StanPrjKolObjFD, str_tmp1);

      if (koi <> KO.TUMS.Count)
         Then WriteLn (StanPrjKolObjFD, ' },')
         Else WriteLn (StanPrjKolObjFD, ' }');
  end;
  WriteLn (StanPrjKolObjFD, '         }');
  WriteLn (StanPrjKolObjFD, '      },');

  WriteLn (StanPrjKolObjFD, '      "MSTU" : {');
  WriteLn (StanPrjKolObjFD, '         "Count" : "'+IntToStr (KO.MSTU.Count)+'",');
  WriteLn (StanPrjKolObjFD, '         "LINPZU" : {');
  for koi := 1 to KO.MSTU.Count do
  begin
     str_tmp   := '"'+IntToStr (koi)+'" : {';
     Write (StanPrjKolObjFD, '            '+str_tmp);

     str_tmp  := '"C":"'+IntToStr (KO.MSTU.Items [koi].C)+'",';
     str_tmp1 := Format ('%s%'+IntToStr (11-Length (str_tmp))+'s',[str_tmp,' ']);
     Write (StanPrjKolObjFD, str_tmp1);
     str_tmp  := '"E":"'+IntToStr (KO.MSTU.Items [koi].E)+'",';
     str_tmp1 := Format ('%s%'+IntToStr (11-Length (str_tmp))+'s',[str_tmp,' ']);
     Write (StanPrjKolObjFD, str_tmp1);
     str_tmp  := '"Q":"'+IntToStr (KO.MSTU.Items [koi].Q)+'",';
     str_tmp1 := Format ('%s%'+IntToStr (11-Length (str_tmp))+'s',[str_tmp,' ']);
     Write (StanPrjKolObjFD, str_tmp1);
     str_tmp  := '"F":"'+IntToStr (KO.MSTU.Items [koi].F)+'",';
     str_tmp1 := Format ('%s%'+IntToStr (11-Length (str_tmp))+'s',[str_tmp,' ']);
     Write (StanPrjKolObjFD, str_tmp1);
     str_tmp  := '"I":"'+IntToStr (KO.MSTU.Items [koi].I)+'",';
     str_tmp1 := Format ('%s%'+IntToStr (11-Length (str_tmp))+'s',[str_tmp,' ']);
     Write (StanPrjKolObjFD, str_tmp1);
     str_tmp  := '"L":"'+IntToStr (KO.MSTU.Items [koi].L)+'"';
     str_tmp1 := Format ('%s%'+IntToStr (11-Length (str_tmp))+'s',[str_tmp,' ']);
     Write (StanPrjKolObjFD, str_tmp1);

      if (koi <> KO.MSTU.Count)
         Then WriteLn (StanPrjKolObjFD, ' },')
         Else WriteLn (StanPrjKolObjFD, ' }');
  end;
  WriteLn   (StanPrjKolObjFD, '         }');
  WriteLn   (StanPrjKolObjFD, '      }');
  WriteLn   (StanPrjKolObjFD, '   }');
  WriteLn   (StanPrjKolObjFD, '}');
  CloseFile (StanPrjKolObjFD);

  {запись ***_topology.js конфигурационного файла}
  AssignFile (StanPrjTopologyFD, _cfg.StanPrjDirName+_cfg.StanPrjTopologyName);
  ReWrite (StanPrjTopologyFD);
  WriteLn (StanPrjTopologyFD, '{');
  WriteLn (StanPrjTopologyFD, '   "Type" : "JSON",');
  WriteLn (StanPrjTopologyFD, '   "TimeStamp" : "' + DateToStr (Now)+' '+TimeToStr (Now)+'",');
  WriteLn (StanPrjTopologyFD, '   "Topology" : {');
  str (TopologyList.Count, topostr);
  Write (StanPrjTopologyFD, '      "Count" : "'+topostr+'"');
  if (TopologyList.Count > 0)
     then WriteLn (StanPrjTopologyFD, ',')
     else WriteLn (StanPrjTopologyFD, '');

  for tli := 1 to TopologyList.Count do
  begin
     ptplg := TopologyList.Items[tli-1];

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

     if (tli <> TopologyList.Count)
        then topostr := topostr + ',' {Write (StanPrjTopologyFD, ',')}
        else;

     //topostr_cp866 := ConvertEncoding (topostr_utf8, 'utf8', 'cp866');
     WriteLn (StanPrjTopologyFD, topostr);
  end;

  WriteLn   (StanPrjTopologyFD, '   }');
  WriteLn   (StanPrjTopologyFD, '}');
  CloseFile (StanPrjTopologyFD);
end;

{ ---------------------------------------------------------------------------- }
end.

