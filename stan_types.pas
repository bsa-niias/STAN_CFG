unit stan_types;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,
  LCLType, Lazutf8;

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
PTTopology = ^TTopology;

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
procedure TopologyElementReset (ptplg : PTTopology);
function _2En (_ch : TUTF8Char) : TUTF8Char;

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

procedure TopologyElementReset (ptplg : PTTopology);
begin
   ptplg^.Line    := 0;
   ptplg^.SubLine := 0;
   ptplg^.Id      := '';
   ptplg^.Name    := '';
   ptplg^.Link    := '';
   ptplg^.UVK     := 0;
end;

function _2En (_ch : TUTF8Char) : TUTF8Char;
Begin
   If (_ch = 'А') Then Result := 'A' Else
   If (_ch = 'Б') Then Result := 'B' Else
   If (_ch = 'В') Then Result := 'V' Else
   If (_ch = 'Г') Then Result := 'G' Else
   If (_ch = 'Д') Then Result := 'D' Else
   If (_ch = 'Е') Then Result := 'E' Else
   If (_ch = 'Ё') Then Result := ''  Else
   If (_ch = 'Ж') Then Result := 'J' Else
   If (_ch = 'З') Then Result := 'Z' Else
   If (_ch = 'з') Then Result := 'Z' Else
   If (_ch = 'И') Then Result := 'I' Else
   If (_ch = 'Й') Then Result := ''  Else
   If (_ch = 'К') Then Result := 'K' Else
   If (_ch = 'Л') Then Result := 'L' Else
   If (_ch = 'М') Then Result := 'M' Else
   If (_ch = 'Н') Then Result := 'N' Else
   If (_ch = 'О') Then Result := 'O' Else
   If (_ch = 'о') Then Result := 'O' Else
   If (_ch = 'П') Then Result := 'P' Else
   If (_ch = 'Р') Then Result := 'R' Else
   If (_ch = 'С') Then Result := 'S' Else
   If (_ch = 'Т') Then Result := 'T' Else
   If (_ch = 'У') Then Result := 'U' Else
   If (_ch = 'Ф') Then Result := 'F' Else
   If (_ch = 'Х') Then Result := 'H' Else
   If (_ch = 'Ц') Then Result := ''  Else
   If (_ch = 'Ч') Then Result := 'C' Else
   If (_ch = 'ч') Then Result := 'C' Else
   If (_ch = 'Ш') Then Result := ''  Else
   If (_ch = 'Щ') Then Result := ''  Else
   If (_ch = 'Ь') Then Result := ''  Else
   If (_ch = 'Ы') Then Result := ''  Else
   If (_ch = 'Ъ') Then Result := ''  Else
   If (_ch = 'Э') Then Result := ''  Else
   If (_ch = 'Ю') Then Result := ''  Else
   If (_ch = 'Я') Then Result := ''
   Else Result := _ch;
End;

end.

