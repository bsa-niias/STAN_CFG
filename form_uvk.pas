unit form_uvk;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ComCtrls,
  Buttons;

type

  { TForm_UVK }

  TForm_UVK = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Edit_TUMS_count: TEdit;
    Edit_MSTU_count: TEdit;
    gb_TUMS: TGroupBox;
    gb_MSTU: TGroupBox;
    UpDown_TUMS: TUpDown;
    UpDown_MSTU: TUpDown;
    procedure Edit_MSTU_countKeyPress(Sender: TObject; var Key: char);
    procedure Edit_TUMS_countKeyPress(Sender: TObject; var Key: char);
  private

  public

  end;

var
  Form_UVKs: TForm_UVK;

implementation

{$R *.lfm}

{ TForm_UVK }

procedure TForm_UVK.Edit_TUMS_countKeyPress(Sender: TObject; var Key: char);
begin
  if not (Key in ['0'..'9',','])
     then Key:=#0
     else;
end;

procedure TForm_UVK.Edit_MSTU_countKeyPress(Sender: TObject; var Key: char);
begin
  if not (Key in ['0'..'9',','])
     then Key:=#0
     else;
end;

end.

