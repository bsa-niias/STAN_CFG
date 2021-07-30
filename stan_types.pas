unit stan_types;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type
{ ------------------------------------------------------------------------------- }
{конфигурация окружения}
TTopologyCFG = record
                          {имя проекта - из имени файла}
  StanPrjName         : AnsiString;    { stan project name - usually station name}
  StanPrjFFName       : AnsiString;    { full file name }
  StanPrjDirName      : AnsiString;    { directory name }
  StanPrjTopologyName : AnsiString;
  StanPrjKolObjName   : AnsiString;
end;

{ ------------------------------------------------------------------------------- }
TTopology = record
  Line    : Integer;   { aka N_STR  (topolog.dbf) }
  SubLine : Integer;   { aka N_EL   (topolog.dbf) }
  Name    : string;    { aka NAME_R (topolog.dbf) }
  Id      : string;    { aka NAME_E (topolog.dbf) }
  Link    : string;    { aka N_STR  (topolog.dbf) mast be == .Id over .Line }
  UVK     : Integer;   { aka STOYKA (topolog.dbf) }
end;

{Количество объектов (контроль/управление)}
TLINPZU = record
  C : Integer;
  E : Integer;
  Q : Integer;
  F : Integer;
  I : Integer;
  L : Integer;
  J : Integer;
end;
PTLINPZU = ^TLINPZU;

TUVK = record
  Count : Integer;
  Items : array [1..256] of TLINPZU;
end;

{Количество ТУМС (МСТУ)}
TKolObj = record
  TUMS : TUVK;
  MSTU : TUVK;
end;

procedure TopologyElementReset (var tplg : TTopology);

implementation

procedure TopologyElementReset (var tplg : TTopology);
begin
   tplg.Line    := 0;
   tplg.SubLine := 0;
   tplg.Id      := '';
   tplg.Name    := '';
   tplg.Link    := '';
   tplg.UVK     := 0;
end;

end.

