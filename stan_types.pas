unit stan_types;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type
{ ------------------------------------------------------------------------------- }
TTopology = record
  Line    : Integer;   { aka N_STR  (topolog.dbf) }
  SubLine : Integer;   { aka N_EL   (topolog.dbf) }
  Name    : string; { aka NAME_R (topolog.dbf) }
  Id      : string; { aka NAME_E (topolog.dbf) }
  Link    : string; { aka N_STR  (topolog.dbf) mast be == .Id over .Line }
  UVK     : Integer;   { aka STOYKA (topolog.dbf) }
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

