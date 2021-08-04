program stan_cfg;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, dbflaz, datetimectrls, form_main, form_do_lamps_2color,
  form_topologyelem, stan_types, form_uvk, form_linpzu, form_strerr
  { you can add units after this };

{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Scaled:=True;
  Application.Initialize;
  Application.CreateForm(TSTANMain, STANMain);
  Application.CreateForm(TForm_DO_Lamps_2Color, frm_DO_Lamps_2Color);
  Application.CreateForm(TForm_TopologyElement, Form_TopologyElement);
  Application.CreateForm(TForm_UVK, Form_UVKs);
  Application.CreateForm(TForm_LINPZU, Form_LINPZUValue);
  Application.CreateForm(TForm_StrError, Form_StrError);
  Application.Run;
end.

