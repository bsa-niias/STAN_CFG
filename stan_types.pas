unit stan_types;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type
{ ------------------------------------------------------------------------------- }
TTopology = record
  Line    : LongWord;   { aka N_STR  (topolog.dbf) }
  SubLine : LongWord;   { aka N_EL   (topolog.dbf) }
  Name    : string; { aka NAME_R (topolog.dbf) }
  Id      : string; { aka NAME_E (topolog.dbf) }
  Link    : string; { aka N_STR  (topolog.dbf) mast be == .Id over .Line }
  UVK     : LongWord;   { aka STOYKA (topolog.dbf) }
end;

implementation

end.

