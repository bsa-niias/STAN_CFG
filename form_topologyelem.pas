unit form_topologyelem;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ComCtrls,
  LConvEncoding,
  stan_types;

type

  { TForm_TopologyElement }

  TForm_TopologyElement = class(TForm)
    btn_Save: TButton;
    btn_Cancel: TButton;
    cb_EditEnable: TCheckBox;
    combobox_ID_Link: TComboBox;
    Edit_Line: TEdit;
    Edit_LineElement: TEdit;
    Edit_Name: TEdit;
    Edit_ID: TEdit;
    Edit_UVK: TEdit;
    GroupBox_ElementProperties: TGroupBox;
    Label_ID: TLabel;
    Label_ID_Link: TLabel;
    Label_Line: TLabel;
    Label_LineElement: TLabel;
    Label_Name: TLabel;
    Label_UVK: TLabel;
    UpDown_Line: TUpDown;
    UpDown_LineElement: TUpDown;
    UpDown_UVK: TUpDown;
    procedure cb_EditEnableChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure GroupBox_ElementPropertiesClick(Sender: TObject);

  private
    tplg_init   : TTopology;
    tplg_change : TTopology;

  public
    procedure TopologFieldsInit (var tplg_elem : TTopology);
  end;

var
  Form_TopologyElement: TForm_TopologyElement;

implementation

{$R *.lfm}

{ TForm_TopologyElement }

procedure TForm_TopologyElement.GroupBox_ElementPropertiesClick(Sender: TObject);
begin

end;

procedure TForm_TopologyElement.FormCreate(Sender: TObject);
begin
  btn_Save.Enabled           := FALSE;
  Edit_Line.Enabled          := FALSE;
  Edit_LineElement.Enabled   := FALSE;
  Edit_Name.Enabled          := FALSE;
  Edit_ID.Enabled            := FALSE;
  combobox_ID_Link.Enabled   := FALSE;
  Edit_UVK.Enabled           := FALSE;
  Label_Line.Enabled         := FALSE;
  Label_LineElement.Enabled  := FALSE;
  Label_Name.Enabled         := FALSE;
  Label_ID.Enabled           := FALSE;
  Label_ID_Link.Enabled      := FALSE;
  Label_UVK.Enabled          := FALSE;
  UpDown_Line.Enabled        := FALSE;
  UpDown_LineElement.Enabled := FALSE;
  UpDown_UVK.Enabled         := FALSE;

  GroupBox_ElementProperties.Enabled := TRUE;
  btn_Cancel.Enabled                 := TRUE;
  cb_EditEnable.Enabled              := TRUE;
end;

procedure TForm_TopologyElement.cb_EditEnableChange(Sender: TObject);
begin
  if (cb_EditEnable.Checked = TRUE)
  then begin
          btn_Save.Enabled           := TRUE;
          Edit_Line.Enabled          := FALSE;
          Edit_LineElement.Enabled   := FALSE;
          Edit_Name.Enabled          := FALSE;
          Edit_ID.Enabled            := TRUE;
          combobox_ID_Link.Enabled   := TRUE;
          Edit_UVK.Enabled           := FALSE;
          Label_Line.Enabled         := TRUE;
          Label_LineElement.Enabled  := TRUE;
          Label_Name.Enabled         := TRUE;
          Label_ID.Enabled           := TRUE;
          Label_ID_Link.Enabled      := TRUE;
          Label_UVK.Enabled          := TRUE;
          UpDown_Line.Enabled        := TRUE;
          UpDown_LineElement.Enabled := TRUE;
          UpDown_UVK.Enabled         := TRUE;

          GroupBox_ElementProperties.Enabled := TRUE;
          btn_Cancel.Enabled                 := TRUE;
          cb_EditEnable.Enabled              := TRUE;
       end
  else begin
          btn_Save.Enabled           := FALSE;
          Edit_Line.Enabled          := FALSE;
          Edit_LineElement.Enabled   := FALSE;
          Edit_Name.Enabled          := FALSE;
          Edit_ID.Enabled            := FALSE;
          combobox_ID_Link.Enabled   := FALSE;
          Edit_UVK.Enabled           := FALSE;
          Label_Line.Enabled         := FALSE;
          Label_LineElement.Enabled  := FALSE;
          Label_Name.Enabled         := FALSE;
          Label_ID.Enabled           := FALSE;
          Label_ID_Link.Enabled      := FALSE;
          Label_UVK.Enabled          := FALSE;
          UpDown_Line.Enabled        := FALSE;
          UpDown_LineElement.Enabled := FALSE;
          UpDown_UVK.Enabled         := FALSE;

          GroupBox_ElementProperties.Enabled := TRUE;
          btn_Cancel.Enabled                 := TRUE;
          cb_EditEnable.Enabled              := TRUE;
       end;
end;

procedure TForm_TopologyElement.TopologFieldsInit (var tplg_elem : TTopology);
var
  str_tmp          : string;

begin
   tplg_init   := tplg_elem;
   tplg_change := tplg_elem;

   str (tplg_init.Line, str_tmp);
   Edit_Line.Text := str_tmp;
   str (tplg_init.SubLine, str_tmp);
   Edit_LineElement.Text := str_tmp;

   Edit_ID.Text := tplg_init.Id;
   //str_tmp:=ConvertEncoding (tplg_init.Name, 'cp866', 'utf8');
   Edit_Name.Text := tplg_init.Name;
   combobox_ID_Link.Text := tplg_init.Link;

   str (tplg_init.UVK, str_tmp);
   Edit_UVK.Text := str_tmp;
end;

end.

