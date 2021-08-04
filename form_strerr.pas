unit form_strerr;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls;

type

  { TForm_StrError }

  TForm_StrError = class(TForm)
    ListBox_Errors: TListBox;
  private

  public

  end;

var
  Form_StrError: TForm_StrError;

implementation

{$R *.lfm}

end.

