unit form_main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Menus, Grids,
  DBGrids, DBCtrls, form_do_lamps_2color, dbf, DB, dbf_lang, LConvEncoding;

type

  { TSTANMain }

  TSTANMain = class(TForm)
    DataSource1: TDataSource;
    Dbf1: TDbf;
    DBGrid1: TDBGrid;
    Menu0_Dependency: TMenuItem;
    Menu_Dep_Topology_New: TMenuItem;
    Menu_Dep_Topology_Open: TMenuItem;
    Menu_Dep_Topology_NewDBF: TMenuItem;
    Menu0_File: TMenuItem;
    Menu_File_SaveAsProject: TMenuItem;
    Menu_File_OpenProject: TMenuItem;
    MenuItem5: TMenuItem;
    Menu_File_SaveProject: TMenuItem;
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
    SelectDirectoryDialog1: TSelectDirectoryDialog;
    function Dbf1Translate(Dbf: TDbf; Src, Dest: PChar; ToOem: Boolean): Integer;
    procedure FormCreate(Sender: TObject);
    procedure Menu_Dep_TopologyClick(Sender: TObject);
    procedure Menu_DO_LampsClick(Sender: TObject);
    procedure Menu_DO_Lamps_2CircleClick(Sender: TObject);
    procedure Menu_File_SaveAsProjectClick(Sender: TObject);

  private

  public

  end;

var
  STANMain: TSTANMain;

implementation

{$R *.lfm}

{ TSTANMain }

procedure TSTANMain.Menu_DO_Lamps_2CircleClick(Sender: TObject);

begin
  frm_DO_Lamps_2Color.Show;
end;

procedure TSTANMain.Menu_File_SaveAsProjectClick(Sender: TObject);
//var
  //SD: TSelectDirectoryDialog;
begin

  //SD.Create (nil);
      //OpenDialog1.Title := 'Select Directory';
      //OpenDialog1.Options := [ofPickFolders, ofPathMustExist, ofForceFileSystem]; // YMMV
      //OkButtonLabel := 'Select';
      //DefaultFolder := FDir;
      //FileName := FDir;
      //if Execute then
  SelectDirectoryDialog1.Execute;
end;

function TSTANMain.Dbf1Translate(Dbf: TDbf; Src, Dest: PChar; ToOem: Boolean): Integer;
var
  i: integer;
  s: string;
begin
  //s:=ConvertEncoding (Src, 'cp866', 'utf8');
  //{
  if (ToOEM = true)
    then s:=ConvertEncoding (Src, 'utf8', 'cp866')
    else s:=ConvertEncoding (Src, 'cp866', 'utf8');
  //}
  strcopy (Dest, PChar (s));

  Result := strlen (Dest);
end;

procedure TSTANMain.FormCreate(Sender: TObject);
var
  dbf_column_index: Integer;
begin

  //dbf1.LanguageID:=dbfLangId_RUS_866;
  for dbf_column_index:= 0 to dbf1.FieldCount-1 do
  begin
    if dbf1.Fields.Fields[dbf_column_index].DataType = ftString
    Then
       Begin
         TStringField (Dbf1.Fields.Fields[dbf_column_index]).Transliterate := true;
       end
    else;
  end;
end;

procedure TSTANMain.Menu_Dep_TopologyClick(Sender: TObject);
begin

end;

procedure TSTANMain.Menu_DO_LampsClick(Sender: TObject);
begin

end;

end.

