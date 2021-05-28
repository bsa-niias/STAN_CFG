program stan_cfg;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, dbflaz, datetimectrls,
  form_main, form_do_lamps_2color
  { you can add units after this };

{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Scaled:=True;
  Application.Initialize;
  Application.CreateForm(TSTANMain, STANMain);
  Application.CreateForm(TForm_DO_Lamps_2Color, frm_DO_Lamps_2Color);
  Application.Run;
end.

