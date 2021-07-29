unit form_uvk;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ComCtrls,
  Buttons;

type

  { TForm_UVK }

  TForm_UVK = class(TForm)
    btnSave: TButton;
    btnCancel: TButton;
    Edit_TUMS_count: TEdit;
    Edit_MSTU_count: TEdit;
    gb_TUMS: TGroupBox;
    gb_MSTU: TGroupBox;
    UpDown_TUMS: TUpDown;
    UpDown_MSTU: TUpDown;
    procedure btnSaveClick(Sender: TObject);
    procedure Edit_MSTU_countKeyPress(Sender: TObject; var Key: char);
    procedure Edit_TUMS_countKeyPress(Sender: TObject; var Key: char);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);

  private
    _TUMSs : Integer;
    _MSTUs : Integer;

  public
    procedure Init (TUMSs_Init : Integer; MSTUs_Init : Integer);
    property TUMSs : Integer read _TUMSs write _TUMSs;
    property MSTUs : Integer read _MSTUs write _MSTUs;
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

procedure TForm_UVK.FormCreate(Sender: TObject);
begin
  _TUMSs := 0;
  _MSTUs := 0;
end;

procedure TForm_UVK.FormShow(Sender: TObject);
begin
  Edit_TUMS_count.Text := IntToStr (_TUMSs);
  Edit_MSTU_count.Text := IntToStr (_MSTUs);
end;

procedure TForm_UVK.Init(TUMSs_Init : Integer; MSTUs_Init : Integer);
begin
  _TUMSs := TUMSs_Init;
  _MSTUs := MSTUs_Init;
end;

procedure TForm_UVK.Edit_MSTU_countKeyPress(Sender: TObject; var Key: char);
begin
  if not (Key in ['0'..'9',','])
     then Key:=#0
     else;
end;

procedure TForm_UVK.btnSaveClick(Sender: TObject);
begin
  _TUMSs := StrToInt (Edit_TUMS_count.Text);
  _MSTUs := StrToInt (Edit_MSTU_count.Text);
end;

end.

