unit stan_types;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type
{ ------------------------------------------------------------------------------- }
TTopology = record
  Line    : Word;   { aka N_STR  (topolog.dbf) }
  SubLine : Word;   { aka N_EL   (topolog.dbf) }
  Name    : string; { aka NAME_R (topolog.dbf) }
  Id      : string; { aka NAME_E (topolog.dbf) }
  Link    : string; { aka N_STR  (topolog.dbf) mast be == .Id over .Line }
  UVK     : Word;   { aka STOYKA (topolog.dbf) }
end;

implementation

end.

