unit form_linpzu;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ComCtrls,
  stan_types;

type

  { TForm_LINPZU }

  TForm_LINPZU = class(TForm)
    btnCancel: TButton;
    btnSave: TButton;
    Edit_C: TEdit;
    Edit_E: TEdit;
    Edit_Q: TEdit;
    Edit_F: TEdit;
    Edit_I: TEdit;
    Edit_L: TEdit;
    lC: TLabel;
    lE: TLabel;
    lQ: TLabel;
    lF: TLabel;
    lI: TLabel;
    lL: TLabel;
    UpDown_C: TUpDown;
    UpDown_E: TUpDown;
    UpDown_Q: TUpDown;
    UpDown_F: TUpDown;
    UpDown_I: TUpDown;
    UpDown_L: TUpDown;
    procedure btnSaveClick(Sender: TObject);
    procedure Edit_CKeyPress(Sender: TObject; var Key: char);
    procedure Edit_EKeyPress(Sender: TObject; var Key: char);
    procedure Edit_FKeyPress(Sender: TObject; var Key: char);
    procedure Edit_IKeyPress(Sender: TObject; var Key: char);
    procedure Edit_LKeyPress(Sender: TObject; var Key: char);
    procedure Edit_QKeyPress(Sender: TObject; var Key: char);
    procedure FormCreate(Sender: TObject);
  private

  public
    procedure Init (LINPZU_Init : PTLINPZU);
    function get_C : Integer;
    function get_E : Integer;
    function get_Q : Integer;
    function get_F : Integer;
    function get_I : Integer;
    function get_L : Integer;
  end;

var
  Form_LINPZUValue: TForm_LINPZU;

implementation

{$R *.lfm}

{ TForm_LINPZU }

procedure TForm_LINPZU.Edit_CKeyPress(Sender: TObject; var Key: char);
begin
  if not (Key in ['0'..'9',','])
     then Key:=#0
     else;
end;

procedure TForm_LINPZU.btnSaveClick(Sender: TObject);
begin

end;

procedure TForm_LINPZU.Edit_EKeyPress(Sender: TObject; var Key: char);
begin
  if not (Key in ['0'..'9',','])
     then Key:=#0
     else;
end;

procedure TForm_LINPZU.Edit_FKeyPress(Sender: TObject; var Key: char);
begin
  if not (Key in ['0'..'9',','])
     then Key:=#0
     else;
end;

procedure TForm_LINPZU.Edit_IKeyPress(Sender: TObject; var Key: char);
begin
  if not (Key in ['0'..'9',','])
     then Key:=#0
     else;
end;

procedure TForm_LINPZU.Edit_LKeyPress(Sender: TObject; var Key: char);
begin
  if not (Key in ['0'..'9',','])
     then Key:=#0
     else;
end;

procedure TForm_LINPZU.Edit_QKeyPress(Sender: TObject; var Key: char);
begin
  if not (Key in ['0'..'9',','])
     then Key:=#0
     else;
end;

procedure TForm_LINPZU.FormCreate(Sender: TObject);
begin
  Edit_C.Text := '0';
  Edit_E.Text := '0';
  Edit_Q.Text := '0';
  Edit_F.Text := '0';
  Edit_I.Text := '0';
  Edit_L.Text := '0';
end;

procedure TForm_LINPZU.Init (LINPZU_Init : PTLINPZU);
Begin
  Edit_C.Text := '0';
  Edit_E.Text := '0';
  Edit_Q.Text := '0';
  Edit_F.Text := '0';
  Edit_I.Text := '0';
  Edit_L.Text := '0';

  if (LINPZU_Init = NIL)
     Then exit
     Else;
  {endif}

  Edit_C.Text := IntToStr (LINPZU_Init^.C);
  Edit_E.Text := IntToStr (LINPZU_Init^.E);
  Edit_Q.Text := IntToStr (LINPZU_Init^.Q);
  Edit_F.Text := IntToStr (LINPZU_Init^.F);
  Edit_I.Text := IntToStr (LINPZU_Init^.I);
  Edit_L.Text := IntToStr (LINPZU_Init^.L);
End;

function TForm_LINPZU.get_C : Integer;
Begin
  Result :=  StrToInt (Edit_C.Text);
end;

function TForm_LINPZU.get_E : Integer;
Begin
  Result :=  StrToInt (Edit_E.Text);
end;

function TForm_LINPZU.get_Q : Integer;
Begin
  Result :=  StrToInt (Edit_Q.Text);
end;

function TForm_LINPZU.get_F : Integer;
Begin
  Result :=  StrToInt (Edit_F.Text);
end;

function TForm_LINPZU.get_I : Integer;
Begin
  Result :=  StrToInt (Edit_I.Text);
end;

function TForm_LINPZU.get_L : Integer;
Begin
  Result :=  StrToInt (Edit_L.Text);
end;

end.

