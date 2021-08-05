unit form_topologyelem;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ComCtrls,
  Buttons, LConvEncoding, stan_types, LCLType,
  Lazutf8;

type

  { TForm_TopologyElement }

  TForm_TopologyElement = class(TForm)
    btn_Save: TButton;
    btn_Cancel: TButton;
    btn_Properties: TButton;
    cb_EditEnable: TCheckBox;
    CB_TypeElement: TComboBox;
    combobox_ID_Link: TComboBox;
    Edit_Line: TEdit;
    Edit_LineElement: TEdit;
    Edit_Name: TEdit;
    Edit_ID: TEdit;
    Edit_NameR: TEdit;
    Edit_NameE: TEdit;
    Edit_UVK: TEdit;
    GroupBox_ElementProperties: TGroupBox;
    Label_TypeElement: TLabel;
    Label_ID: TLabel;
    Label_ID_Link: TLabel;
    Label_Line: TLabel;
    Label_LineElement: TLabel;
    Label_Name: TLabel;
    Label_UVK: TLabel;
    UpDown_Line: TUpDown;
    UpDown_LineElement: TUpDown;
    UpDown_UVK: TUpDown;
    procedure btn_CancelClick(Sender: TObject);
    procedure btn_SaveClick(Sender: TObject);
    procedure cb_EditEnableChange(Sender: TObject);
    procedure CB_TypeElementChange(Sender: TObject);
    procedure Edit_NameChange(Sender: TObject);
    procedure Edit_NameUTF8KeyPress(Sender: TObject; var UTF8Key: TUTF8Char);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);

  private
    tplg_init   : TTopology;  { Начальное состояние }
    tplg_change : TTopology;  { Измененное состояние }

  public
    procedure Init (var tplg_elem : TTopology; var vlist : TStringList);
    procedure Get  (var tplg_elem : TTopology);
  end;

var
  Form_TopologyElement: TForm_TopologyElement;

implementation

{$R *.lfm}

{ TForm_TopologyElement }

procedure TForm_TopologyElement.FormCreate(Sender: TObject);
begin
  btn_Properties.Enabled     := FALSE;
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
  Label_TypeElement.Enabled  := FALSE;
  CB_TypeElement.Enabled     := FALSE;
  Edit_NameR.Enabled         := FALSE;
  Edit_NameE.Enabled         := FALSE;

  GroupBox_ElementProperties.Enabled := TRUE;
  btn_Cancel.Enabled                 := TRUE;
  cb_EditEnable.Enabled              := TRUE;

  cb_EditEnable.Checked := FALSE;
end;


procedure TForm_TopologyElement.FormActivate(Sender: TObject);
begin
  FormCreate (Sender);
  {Before call *.init}
  {Перед активацией формы нужно вызвать *.Init}
  CB_TypeElementChange (Sender);
end;

procedure TForm_TopologyElement.cb_EditEnableChange(Sender: TObject);
begin
  if (cb_EditEnable.Checked = TRUE)
  then begin
          btn_Properties.Enabled     := TRUE;
          btn_Save.Enabled           := TRUE;
          Edit_Line.Enabled          := FALSE;
          Edit_LineElement.Enabled   := FALSE;
          Edit_Name.Enabled          := TRUE;
          {Edit_ID.Enabled            := TRUE;} // Английское имя не редактируем
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
          CB_TypeElement.Enabled     := TRUE;

          GroupBox_ElementProperties.Enabled := TRUE;
          btn_Cancel.Enabled                 := TRUE;
          cb_EditEnable.Enabled              := TRUE;
       end
  else begin
          btn_Properties.Enabled     := FALSE;
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
          CB_TypeElement.Enabled     := FALSE;

          GroupBox_ElementProperties.Enabled := TRUE;
          btn_Cancel.Enabled                 := TRUE;
          cb_EditEnable.Enabled              := TRUE;
       end;
  CB_TypeElementChange (Sender);
end;

procedure TForm_TopologyElement.btn_CancelClick(Sender: TObject);
begin
  tplg_change := tplg_init;
end;

procedure TForm_TopologyElement.btn_SaveClick(Sender: TObject);
{===}
Var
  str_temp : String;
  _pos     : SizeInt;
{===}
begin
   tplg_change := tplg_init;

   tplg_change.Line := StrToInt (Edit_Line.Text);
   tplg_change.SubLine := StrToInt (Edit_LineElement.Text);

   tplg_change.Name := '';
   tplg_change.Id   := '';
   Case (CB_TypeElement.ItemIndex) Of
        1: Begin
              tplg_change.Name := 'СТ';
              tplg_change.Id   := 'ST';
           End;
        2: Begin
              tplg_change.Name := 'СП';
              tplg_change.Id   := 'SP';
           End;
        3: Begin
              tplg_change.Name := 'П';
              tplg_change.Id   := 'P';
           End;
        4: Begin
              tplg_change.Name := 'БП';
              tplg_change.Id   := 'V';
           End;
        5: Begin
              tplg_change.Name := 'Дз';
              tplg_change.Id   := 'DZ';
           End;
        6: Begin
              tplg_change.Name := 'М';
              tplg_change.Id   := 'M';
           End;
        7: Begin
              tplg_change.Name := 'Н';
              tplg_change.Id   := 'N';
           End;
        8: Begin
              tplg_change.Name := 'Ч';
              tplg_change.Id   := 'CH';
           End;
        9: Begin
              tplg_change.Name := 'УП';
              tplg_change.Id   := 'UP';
           End;
       10: Begin
              tplg_change.Name := 'СН';
              tplg_change.Id   := 'SN';
           End;
   End;
   tplg_change.Name := tplg_change.Name + Edit_Name.Text;
   tplg_change.Id   := tplg_change.Id   + Edit_ID.Text;

   tplg_change.Link := '';
   If (Combobox_ID_Link.ItemIndex <> 0)
      Then Begin
           str_temp := Combobox_ID_Link.Items [Combobox_ID_Link.ItemIndex];
           _pos := Pos ('[', str_temp);
           if (_pos <> 0)
              Then tplg_change.Link := Copy (str_temp, 1, _pos-1)
              Else tplg_change.Link := '?';
      End
      Else;

   tplg_change.UVK := StrToInt (Edit_UVK.Text);
end;

procedure TForm_TopologyElement.CB_TypeElementChange(Sender: TObject);
begin
   Combobox_ID_Link.Enabled := FALSE;
   If (CB_TypeElement.ItemIndex = 0)
      Then Begin
           Edit_NameR.Text := '';
           Edit_NameE.Text := '';
           Combobox_ID_Link.ItemIndex := 0;
      End
   Else
   If (CB_TypeElement.ItemIndex = 1)
      Then Begin
           Edit_NameR.Text := 'СТ';
           Edit_NameE.Text := 'ST';
           Combobox_ID_Link.Enabled := TRUE;
      End
   Else
   If (CB_TypeElement.ItemIndex = 2)
      Then Begin
           Edit_NameR.Text := 'СП';
           Edit_NameE.Text := 'SP';
           Combobox_ID_Link.ItemIndex := 0;
      End
   Else
   If (CB_TypeElement.ItemIndex = 3)
      Then Begin
           Edit_NameR.Text := 'П';
           Edit_NameE.Text := 'P';
           Combobox_ID_Link.ItemIndex := 0;
      End
   Else
   If (CB_TypeElement.ItemIndex = 4)
      Then Begin
           Edit_NameR.Text := 'БП';
           Edit_NameE.Text := 'V';
           Combobox_ID_Link.Enabled := TRUE;
      End
   Else
   If (CB_TypeElement.ItemIndex = 5)
      Then Begin
           Edit_NameR.Text := 'Дз';
           Edit_NameE.Text := 'DZ';
           Combobox_ID_Link.ItemIndex := 0;
      End
   Else
   If (CB_TypeElement.ItemIndex = 6)
      Then Begin
           Edit_NameR.Text := 'М';
           Edit_NameE.Text := 'M';
           Combobox_ID_Link.ItemIndex := 0;
      End
   Else
   If (CB_TypeElement.ItemIndex = 7)
      Then Begin
           Edit_NameR.Text := 'Н';
           Edit_NameE.Text := 'N';
           Combobox_ID_Link.ItemIndex := 0;
      End
   Else
   If (CB_TypeElement.ItemIndex = 8)
      Then Begin
           Edit_NameR.Text := 'Ч';
           Edit_NameE.Text := 'CH';
           Combobox_ID_Link.ItemIndex := 0;
      End
   Else
   If (CB_TypeElement.ItemIndex = 9)
      Then Begin
           Edit_NameR.Text := 'УП';
           Edit_NameE.Text := 'UP';
           Combobox_ID_Link.ItemIndex := 0;
      End
   Else
   If (CB_TypeElement.ItemIndex = 10)
      Then Begin
           Edit_NameR.Text := 'СН';
           Edit_NameE.Text := 'SN';
           Combobox_ID_Link.ItemIndex := 0;
      End
   Else Begin
           Edit_NameR.Text := '';
           Edit_NameE.Text := '';
           Combobox_ID_Link.ItemIndex := 0;
   End;

   {т.к. функция вызывается в FarmActive - проверяется флажок разрешения редактирования}
   If (cb_EditEnable.Checked = FALSE)
      Then Combobox_ID_Link.Enabled := FALSE
      Else;
end;

procedure TForm_TopologyElement.Edit_NameChange(Sender: TObject);
{===}
var
  WStr      : UnicodeString;
  WStrLen   : SizeInt;
  WChar     : WideChar;
  str_index : SizeInt;
  StrUTF8   : String;
{===}
{
function _2En (_ch : TUTF8Char) : TUTF8Char;
Begin
   If (_ch = 'А') Then Result := 'A' Else
   If (_ch = 'Б') Then Result := 'B' Else
   If (_ch = 'В') Then Result := 'V' Else
   If (_ch = 'Г') Then Result := 'G' Else
   If (_ch = 'Д') Then Result := 'D' Else
   If (_ch = 'Е') Then Result := 'E' Else
   If (_ch = 'Ё') Then Result := ''  Else
   If (_ch = 'Ж') Then Result := 'J' Else
   If (_ch = 'З') Then Result := 'Z' Else
   If (_ch = 'И') Then Result := 'I' Else
   If (_ch = 'Й') Then Result := ''  Else
   If (_ch = 'К') Then Result := 'K' Else
   If (_ch = 'Л') Then Result := 'L' Else
   If (_ch = 'М') Then Result := 'M' Else
   If (_ch = 'Н') Then Result := 'N' Else
   If (_ch = 'О') Then Result := 'O' Else
   If (_ch = 'П') Then Result := 'P' Else
   If (_ch = 'Р') Then Result := 'R' Else
   If (_ch = 'С') Then Result := 'S' Else
   If (_ch = 'Т') Then Result := 'T' Else
   If (_ch = 'У') Then Result := 'U' Else
   If (_ch = 'Ф') Then Result := 'F' Else
   If (_ch = 'Х') Then Result := 'H' Else
   If (_ch = 'Ц') Then Result := ''  Else
   If (_ch = 'Ч') Then Result := 'C' Else
   If (_ch = 'Ш') Then Result := ''  Else
   If (_ch = 'Щ') Then Result := ''  Else
   If (_ch = 'Ь') Then Result := ''  Else
   If (_ch = 'Ы') Then Result := ''  Else
   If (_ch = 'Ъ') Then Result := ''  Else
   If (_ch = 'Э') Then Result := ''  Else
   If (_ch = 'Ю') Then Result := ''  Else
   If (_ch = 'Я') Then Result := ''
   Else Result := _ch;
End;
}
begin
   Edit_ID.Text :=  '';
   StrUTF8 := '';

   WStr := UTF8ToUTF16 (Edit_Name.Text);
   WStrLen :=  Length (Edit_Name.Text);

   For str_index := 1 To WStrLen Do
   Begin
       WChar := WStr [str_index];
       StrUTF8 := StrUTF8 + _2En (UTF8Encode (WChar));
   End;

   Edit_ID.Text :=  StrUTF8;
end;
procedure TForm_TopologyElement.Edit_NameUTF8KeyPress(Sender: TObject;
  var UTF8Key: TUTF8Char);
Begin
   If (UTF8Key = 'а') Then UTF8Key := 'А' Else
   If (UTF8Key = 'б') Then UTF8Key := 'Б' Else
   If (UTF8Key = 'в') Then UTF8Key := 'В' Else
   If (UTF8Key = 'г') Then UTF8Key := 'Г' Else
   If (UTF8Key = 'д') Then UTF8Key := 'Д' Else
   If (UTF8Key = 'е') Then UTF8Key := 'Е' Else
   If (UTF8Key = 'ё') Then UTF8Key := #0  Else
   If (UTF8Key = 'ж') Then UTF8Key := 'Ж' Else
   If (UTF8Key = 'з') Then UTF8Key := 'З' Else
   If (UTF8Key = 'и') Then UTF8Key := 'И' Else
   If (UTF8Key = 'й') Then UTF8Key := #0  Else
   If (UTF8Key = 'к') Then UTF8Key := 'К' Else
   If (UTF8Key = 'л') Then UTF8Key := 'Л' Else
   If (UTF8Key = 'м') Then UTF8Key := 'М' Else
   If (UTF8Key = 'н') Then UTF8Key := 'Н' Else
   If (UTF8Key = 'о') Then UTF8Key := 'О' Else
   If (UTF8Key = 'п') Then UTF8Key := 'П' Else
   If (UTF8Key = 'р') Then UTF8Key := 'Р' Else
   If (UTF8Key = 'с') Then UTF8Key := 'С' Else
   If (UTF8Key = 'т') Then UTF8Key := 'Т' Else
   If (UTF8Key = 'у') Then UTF8Key := 'У' Else
   If (UTF8Key = 'ф') Then UTF8Key := 'Ф' Else
   If (UTF8Key = 'х') Then UTF8Key := 'Х' Else
   If (UTF8Key = 'ц') Then UTF8Key := #0  Else
   If (UTF8Key = 'ч') Then UTF8Key := 'Ч' Else
   If (UTF8Key = 'ш') Then UTF8Key := #0  Else
   If (UTF8Key = 'щ') Then UTF8Key := #0  Else
   If (UTF8Key = 'ь') Then UTF8Key := #0  Else
   If (UTF8Key = 'ы') Then UTF8Key := #0  Else
   If (UTF8Key = 'ъ') Then UTF8Key := #0  Else
   If (UTF8Key = 'э') Then UTF8Key := #0  Else
   If (UTF8Key = 'ю') Then UTF8Key := #0  Else
   If (UTF8Key = 'я') Then UTF8Key := #0  Else
   If (UTF8Key = #8)  Then UTF8Key := #8
   Else; // UTF8Key := #0;
end;

procedure TForm_TopologyElement.Init (var tplg_elem : TTopology; var vlist : TStringList);
{===}
var
  slist_count  : Integer;
  slist_index  : Integer;
  st           : String;
  str_tmp      : string;
{===}
begin
   {Редактируемый элемент-начальное значение}
   tplg_init   := tplg_elem;

   {Редактируемый элемент-это измененное состояние}
   tplg_change := tplg_init;

   str (tplg_change.Line, str_tmp);
   Edit_Line.Text := str_tmp;
   str (tplg_change.SubLine, str_tmp);
   Edit_LineElement.Text := str_tmp;

   If ((Length (tplg_change.Id) >= 2) And (tplg_change.Id [1] = 'S') And (tplg_change.Id [2] = 'T'))
      Then Begin
           CB_TypeElement.ItemIndex := 1;
           Edit_NameR.Text := 'СТ';
           Edit_NameE.Text := 'ST';
           Delete (tplg_change.Name, 1, 4); {4-так как русские буквы и utf}
           Delete (tplg_change.Id, 1, 2);
           Edit_Name.Text := tplg_change.Name;
           //Edit_Id.Text := tplg_change.Id;
      End
   Else
   If ((Length (tplg_change.Id) >= 2) And (tplg_change.Id [1] = 'S') And (tplg_change.Id [2] = 'P'))
      Then Begin
           CB_TypeElement.ItemIndex := 2;
           Edit_NameR.Text := 'СП';
           Edit_NameE.Text := 'SP';
           Delete (tplg_change.Name, 1, 4); {4-так как русские буквы и utf}
           Delete (tplg_change.Id, 1, 2);
           Edit_Name.Text := tplg_change.Name;
           //Edit_Id.Text := tplg_change.Id;
      End
   Else
   If ((Length (tplg_change.Id) >= 1) And (tplg_change.Id [1] = 'P'))
      Then Begin
           CB_TypeElement.ItemIndex := 3;
           Edit_NameR.Text := 'П';
           Edit_NameE.Text := 'P';
           Delete (tplg_change.Name, 1, 2); {4-так как русские буквы и utf}
           Delete (tplg_change.Id, 1, 1);
           Edit_Name.Text := tplg_change.Name;
           //Edit_Id.Text := tplg_change.Id;
      End
   Else
   If ((Length (tplg_change.Id) >= 1) And (tplg_change.Id [1] = 'V'))
      Then Begin
           CB_TypeElement.ItemIndex := 4;
           Edit_NameR.Text := 'БП';
           Edit_NameE.Text := 'V';
           Delete (tplg_change.Name, 1, 4); {4-так как русские буквы и utf}
           Delete (tplg_change.Id, 1, 1);
           Edit_Name.Text := tplg_change.Name;
           //Edit_Id.Text := tplg_change.Id;
      End
   Else
   If ((Length (tplg_change.Id) >= 2) And (tplg_change.Id [1] = 'D') And (tplg_change.Id [2] = 'Z'))
      Then Begin
           CB_TypeElement.ItemIndex := 5;
           Edit_NameR.Text := 'Дз';
           Edit_NameE.Text := 'DZ';
           Delete (tplg_change.Name, 1, 4); {4-так как русские буквы и utf}
           Delete (tplg_change.Id, 1, 2);
           Edit_Name.Text := tplg_change.Name;
           //Edit_Id.Text := tplg_change.Id;
      End
   Else
   If ((Length (tplg_change.Id) >= 1) And (tplg_change.Id [1] = 'M'))
      Then Begin
           CB_TypeElement.ItemIndex := 6;
           Edit_NameR.Text := 'М';
           Edit_NameE.Text := 'M';
           Delete (tplg_change.Name, 1, 2); {4-так как русские буквы и utf}
           Delete (tplg_change.Id, 1, 1);
           Edit_Name.Text := tplg_change.Name;
           //Edit_Id.Text := tplg_change.Id;
      End
   Else
   If ((Length (tplg_change.Id) >= 1) And (tplg_change.Id [1] = 'N'))
      Then Begin
           CB_TypeElement.ItemIndex := 7;
           Edit_NameR.Text := 'Н';
           Edit_NameE.Text := 'N';
           Delete (tplg_change.Name, 1, 2); {4-так как русские буквы и utf}
           Delete (tplg_change.Id, 1, 1);
           Edit_Name.Text := tplg_change.Name;
           //Edit_Id.Text := tplg_change.Id;
      End
   Else
   If ((Length (tplg_change.Id) >= 2) And (tplg_change.Id [1] = 'C') And (tplg_change.Id [2] = 'H'))
      Then Begin
           CB_TypeElement.ItemIndex := 8;
           Edit_NameR.Text := 'Ч';
           Edit_NameE.Text := 'CH';
           Delete (tplg_change.Name, 1, 2); {4-так как русские буквы и utf}
           Delete (tplg_change.Id, 1, 2);
           Edit_Name.Text := tplg_change.Name;
           //Edit_Id.Text := tplg_change.Id;
      End
   Else
   If ((Length (tplg_change.Id) >= 2) And (tplg_change.Id [1] = 'U') And (tplg_change.Id [2] = 'P'))
      Then Begin
           CB_TypeElement.ItemIndex := 9;
           Edit_NameR.Text := 'УП';
           Edit_NameE.Text := 'UP';
           Delete (tplg_change.Name, 1, 4); {4-так как русские буквы и utf}
           Delete (tplg_change.Id, 1, 2);
           Edit_Name.Text := tplg_change.Name;
           //Edit_Id.Text := tplg_change.Id;
      End
   Else
   If ((Length (tplg_change.Id) >= 2) And (tplg_change.Id [1] = 'S') And (tplg_change.Id [2] = 'N'))
      Then Begin
           CB_TypeElement.ItemIndex := 10;
           Edit_NameR.Text := 'СН';
           Edit_NameE.Text := 'SN';
           Delete (tplg_change.Name, 1, 4); {4-так как русские буквы и utf}
           Delete (tplg_change.Id, 1, 2);
           Edit_Name.Text := tplg_change.Name;
           //Edit_Id.Text := tplg_change.Id;
      End
   Else Begin
        CB_TypeElement.ItemIndex := 0;
        Edit_NameR.Text := '';
        Edit_NameE.Text := '';
        Edit_Name.Text := tplg_change.Name;
        //Edit_Id.Text := tplg_change.Id;
   End;

   {Формируем список переходов из существующих}
   combobox_ID_Link.Clear;
   slist_count := vlist.Count;
   For slist_index := 1 To slist_count Do
   Begin
       st := vlist[slist_index-1];
       combobox_ID_Link.Items.Add (st);
   End;
   combobox_ID_Link.Enabled   := TRUE;
   combobox_ID_Link.ItemIndex := 0;

   {Ищем и устанавливаем существующий переход, если он есть}
   slist_count := combobox_ID_Link.Items.Count;
   For slist_index := 1 To slist_count Do
   Begin
       st := combobox_ID_Link.Items [slist_index-1];
       If (Pos (tplg_init.Link, st) <> 0)
          Then Begin
               combobox_ID_Link.ItemIndex := slist_index-1;
               Break;
          End
          Else;
       {-endif1}
   End;

   {Edit_ID сам меняется по имени Edit_Name}
   {Edit_ID.Text := tplg_init.Id;}
   {str_tmp:=ConvertEncoding (tplg_init.Name, 'cp866', 'utf8');}

   str (tplg_init.UVK, str_tmp);
   Edit_UVK.Text := str_tmp;
end;

procedure TForm_TopologyElement.Get (var tplg_elem : TTopology);
Begin
   tplg_elem := tplg_change;
End;

end.

