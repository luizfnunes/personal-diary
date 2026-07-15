unit unitEditor;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  DBExtCtrls, DBCtrls, ComCtrls, Menus, EditBtn, Buttons, HtmlView, SynEdit,
  SynHighlighterHTML, RegExpr, Base64, DB, CryptoHelper, unitImage;

type

  { TFormEditor }

  TFormEditor = class(TForm)
    BitBtn1: TBitBtn;
    BtnSaveTemplate: TBitBtn;
    BtnClearEditor: TBitBtn;
    BtnClearAll: TBitBtn;
    BtnClose: TBitBtn;
    BtnSave: TBitBtn;
    EditDate: TDateEdit;
    EditTitle: TEdit;
    HtmlViewerEditor: THtmlViewer;
    Label1: TLabel;
    Label2: TLabel;
    MenuItem100: TMenuItem;
    MenuItem86: TMenuItem;
    MenuItem48: TMenuItem;
    MenuItem64: TMenuItem;
    MenuItem32: TMenuItem;
    MenuItem30: TMenuItem;
    MenuItem28: TMenuItem;
    MenuItem26: TMenuItem;
    MenuItem24: TMenuItem;
    MenuItem22: TMenuItem;
    MenuItem18: TMenuItem;
    MenuItem16: TMenuItem;
    MenuItem12: TMenuItem;
    MenuItem10: TMenuItem;
    MenuItemPreto: TMenuItem;
    MenuItemBranco: TMenuItem;
    MenuItemLaranja: TMenuItem;
    MenuItemRoxo: TMenuItem;
    MenuItemVerde: TMenuItem;
    MenuItemVermelho: TMenuItem;
    MenuItemAzul: TMenuItem;
    MenuItemAmarelo: TMenuItem;
    PageControlMain: TPageControl;
    Panel1: TPanel;
    PanelTemplateBottom: TPanel;
    PanelEditorBottom: TPanel;
    PanelTop: TPanel;
    PopupMenuSizes: TPopupMenu;
    PopupMenuColors: TPopupMenu;
    StatusBar1: TStatusBar;
    SynEditTemplate: TSynEdit;
    SynEditContent: TSynEdit;
    SynHTMLSyn1: TSynHTMLSyn;
    TabSheetTemplate: TTabSheet;
    TabSheetView: TTabSheet;
    TabSheetEditor: TTabSheet;
    ToolBar1: TToolBar;
    TBParagraph: TToolButton;
    TBView: TToolButton;
    ToolButton10: TToolButton;
    TBHeader1: TToolButton;
    TBHeader2: TToolButton;
    TBHeader3: TToolButton;
    ToolButton14: TToolButton;
    TBImage: TToolButton;
    TBFontColors: TToolButton;
    TBFontSize: TToolButton;
    ToolButton18: TToolButton;
    ToolButton2: TToolButton;
    TBBold: TToolButton;
    TBItalic: TToolButton;
    TBUnderline: TToolButton;
    ToolButton6: TToolButton;
    TBAlignLeft: TToolButton;
    TBAlignCenter: TToolButton;
    TBAlignRight: TToolButton;
    procedure BitBtn1Click(Sender: TObject);
    procedure BtnClearAllClick(Sender: TObject);
    procedure BtnClearEditorClick(Sender: TObject);
    procedure BtnCloseClick(Sender: TObject);
    procedure BtnSaveClick(Sender: TObject);
    procedure BtnSaveTemplateClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure MenuItem100Click(Sender: TObject);
    procedure MenuItem10Click(Sender: TObject);
    procedure MenuItem12Click(Sender: TObject);
    procedure MenuItem16Click(Sender: TObject);
    procedure MenuItem18Click(Sender: TObject);
    procedure MenuItem22Click(Sender: TObject);
    procedure MenuItem24Click(Sender: TObject);
    procedure MenuItem26Click(Sender: TObject);
    procedure MenuItem28Click(Sender: TObject);
    procedure MenuItem30Click(Sender: TObject);
    procedure MenuItem32Click(Sender: TObject);
    procedure MenuItem48Click(Sender: TObject);
    procedure MenuItem64Click(Sender: TObject);
    procedure MenuItem86Click(Sender: TObject);
    procedure MenuItemAmareloClick(Sender: TObject);
    procedure MenuItemAzulClick(Sender: TObject);
    procedure MenuItemBrancoClick(Sender: TObject);
    procedure MenuItemLaranjaClick(Sender: TObject);
    procedure MenuItemPretoClick(Sender: TObject);
    procedure MenuItemRoxoClick(Sender: TObject);
    procedure MenuItemVerdeClick(Sender: TObject);
    procedure MenuItemVermelhoClick(Sender: TObject);
    procedure PageControlMainChange(Sender: TObject);
    procedure SynEditContentChange(Sender: TObject);
    procedure TBAlignCenterClick(Sender: TObject);
    procedure TBAlignLeftClick(Sender: TObject);
    procedure TBAlignRightClick(Sender: TObject);
    procedure TBHeader1Click(Sender: TObject);
    procedure TBHeader2Click(Sender: TObject);
    procedure TBHeader3Click(Sender: TObject);
    procedure TBImageClick(Sender: TObject);
    procedure TBParagraphClick(Sender: TObject);
    procedure TBBoldClick(Sender: TObject);
    procedure TBItalicClick(Sender: TObject);
    procedure TBUnderlineClick(Sender: TObject);
    procedure TBViewClick(Sender: TObject);
  private

  public
    Mode: string;
    procedure UpdatePreview();
    procedure InsertBlock(ATag: string; cBack: Integer; AParams: String = '');
    procedure AddClass(SynEdit: TSynEdit; const Classe: string; DefaultTag: string = 'div');
  end;

var
  FormEditor: TFormEditor;

implementation

uses unitDataModule, unitPrincipal;

{$R *.lfm}
procedure TFormEditor.InsertBlock(ATag: string; cBack: Integer; AParams: String = '');
begin
  if AParams <> '' then
    AParams:=' '+AParams;
  SynEditContent.InsertTextAtCaret('<'+ATag+AParams+'></'+ATag+'>');
  SynEditContent.CaretX := SynEditContent.CaretX - cBack;
end;

procedure TFormEditor.AddClass(SynEdit: TSynEdit; const Classe: string; DefaultTag: string = 'div');
var
  S: string;
  R: TRegExpr;
begin
  S := SynEdit.SelText;
  R := TRegExpr.Create;
  try
    R.Expression := '^<([a-zA-Z][a-zA-Z0-9]*)([^>]*)>';
    if R.Exec(S) then
    begin
      if Pos('class=', LowerCase(R.Match[0])) > 0 then
      begin
        S := StringReplace(S,'class="','class="' + Classe + ' ',[]);
      end
      else
      begin
        S := StringReplace(
          S,'>',' class="' + Classe + '">',[]);
      end;
      SynEdit.SelText := S;
    end
    else
    begin
      InsertBlock(DefaultTag, DefaultTag.Length + 3, 'class="'+Classe+'"');
    end;
  finally
    R.Free;
  end;
end;

procedure TFormEditor.UpdatePreview();
var
  ReplacedTemplate: String;
begin
  ReplacedTemplate:=StringReplace(SynEditTemplate.Text, '{{CONTENT}}', SynEditContent.Text, [rfIgnoreCase]);
  HtmlViewerEditor.LoadFromString(ReplacedTemplate);
end;

procedure TFormEditor.TBParagraphClick(Sender: TObject);
begin
  InsertBlock('p', 4);
end;

procedure TFormEditor.TBBoldClick(Sender: TObject);
begin
  InsertBlock('b', 4);
end;

procedure TFormEditor.TBItalicClick(Sender: TObject);
begin
  InsertBlock('i', 4);
end;

procedure TFormEditor.TBUnderlineClick(Sender: TObject);
begin
  InsertBlock('u', 4);
end;

procedure TFormEditor.TBViewClick(Sender: TObject);
begin
  UpdatePreview();
  PageControlMain.ActivePageIndex:=1;
end;

procedure TFormEditor.TBHeader1Click(Sender: TObject);
begin
  InsertBlock('h1', 5);
end;

procedure TFormEditor.TBHeader2Click(Sender: TObject);
begin
  InsertBlock('h2', 5);
end;

procedure TFormEditor.TBHeader3Click(Sender: TObject);
begin
  InsertBlock('h3', 5);
end;

procedure TFormEditor.TBImageClick(Sender: TObject);
begin
  FormImage.ShowModal;
end;

procedure TFormEditor.TBAlignLeftClick(Sender: TObject);
begin
  AddClass(SynEditContent, 'left', 'p');
end;

procedure TFormEditor.TBAlignCenterClick(Sender: TObject);
begin
  AddClass(SynEditContent, 'center', 'p');
end;

procedure TFormEditor.TBAlignRightClick(Sender: TObject);
begin
  AddClass(SynEditContent, 'right', 'p');
end;

procedure TFormEditor.MenuItemAmareloClick(Sender: TObject);
begin
  AddClass(SynEditContent, 'yellow', 'span');
end;

procedure TFormEditor.MenuItemAzulClick(Sender: TObject);
begin
  AddClass(SynEditContent, 'blue', 'span');
end;

procedure TFormEditor.MenuItemBrancoClick(Sender: TObject);
begin
  AddClass(SynEditContent, 'white', 'span');
end;

procedure TFormEditor.MenuItemLaranjaClick(Sender: TObject);
begin
  AddClass(SynEditContent, 'orange', 'span');
end;

procedure TFormEditor.MenuItemPretoClick(Sender: TObject);
begin
  AddClass(SynEditContent, 'black', 'span');
end;

procedure TFormEditor.MenuItemRoxoClick(Sender: TObject);
begin
  AddClass(SynEditContent, 'purple', 'span');
end;

procedure TFormEditor.MenuItemVerdeClick(Sender: TObject);
begin
  AddClass(SynEditContent, 'green', 'span');
end;

procedure TFormEditor.MenuItemVermelhoClick(Sender: TObject);
begin
  AddClass(SynEditContent, 'red', 'span');
end;

procedure TFormEditor.PageControlMainChange(Sender: TObject);
begin
  if PageControlMain.ActivePage = TabSheetView then
  begin
    UpdatePreview();
  end;
end;

procedure TFormEditor.SynEditContentChange(Sender: TObject);
begin

end;

procedure TFormEditor.MenuItem10Click(Sender: TObject);
begin
  AddClass(SynEditContent, 's-10');
end;

procedure TFormEditor.MenuItem12Click(Sender: TObject);
begin
  AddClass(SynEditContent, 's-12');
end;

procedure TFormEditor.MenuItem16Click(Sender: TObject);
begin
  AddClass(SynEditContent, 's-16');
end;

procedure TFormEditor.MenuItem18Click(Sender: TObject);
begin
  AddClass(SynEditContent, 's-18');
end;

procedure TFormEditor.MenuItem22Click(Sender: TObject);
begin
  AddClass(SynEditContent, 's-22');
end;

procedure TFormEditor.MenuItem24Click(Sender: TObject);
begin
  AddClass(SynEditContent, 's-24');
end;

procedure TFormEditor.MenuItem26Click(Sender: TObject);
begin
  AddClass(SynEditContent, 's-26');
end;

procedure TFormEditor.MenuItem28Click(Sender: TObject);
begin
  AddClass(SynEditContent, 's-28');
end;

procedure TFormEditor.MenuItem30Click(Sender: TObject);
begin
  AddClass(SynEditContent, 's-30');
end;

procedure TFormEditor.MenuItem32Click(Sender: TObject);
begin
  AddClass(SynEditContent, 's-32');
end;

procedure TFormEditor.MenuItem48Click(Sender: TObject);
begin
  AddClass(SynEditContent, 's-48');
end;

procedure TFormEditor.MenuItem64Click(Sender: TObject);
begin
  AddClass(SynEditContent, 's-64');
end;

procedure TFormEditor.MenuItem86Click(Sender: TObject);
begin
  AddClass(SynEditContent, 's-86');
end;

procedure TFormEditor.MenuItem100Click(Sender: TObject);
begin
  AddClass(SynEditContent, 's-100');
end;

procedure TFormEditor.BtnClearAllClick(Sender: TObject);
begin
  EditDate.Clear;
  EditTitle.Clear;
  SynEditContent.Clear;
end;

procedure TFormEditor.BitBtn1Click(Sender: TObject);
begin
  FormPrincipal.LoadTemplate();
end;

procedure TFormEditor.BtnClearEditorClick(Sender: TObject);
begin
  SynEditContent.Clear;
end;

procedure TFormEditor.BtnCloseClick(Sender: TObject);
begin
  BtnClearAll.Click;
  FormEditor.Close;
end;
procedure TFormEditor.BtnSaveClick(Sender: TObject);
begin
  if (EditDate.Text = '') or (EditTitle.Text = '') then
  begin
    MessageDlg('Atenção', 'Preencha corretamente a data e o título!', mtWarning, [mbOK], 0);
    Exit;
  end;

  try
    if Mode = 'insert' then
      DM.ZTableRegistry.Insert
    else if Mode = 'edit' then
      DM.ZTableRegistry.Edit;

    // Atribuição dos campos normais
    DM.ZTableRegistry.FieldByName('CREATED_AT').AsDateTime := EditDate.Date;
    DM.ZTableRegistry.FieldByName('TITLE').AsString := TCryptoHelper.EncryptString(EditTitle.Text, TCryptoHelper.KeyDefault);

    // O SEGREDO: Atribuir o texto do SynEdit direto como AnsiString/AsString.
    // O Zeos se encarrega de converter e salvar no BLOB sem dar erro de WRITE ONLY.
    DM.ZTableRegistry.FieldByName('CONTENT').AsString := TCryptoHelper.EncryptString(SynEditContent.Text, TCryptoHelper.KeyDefault);

    // Salva permanentemente no banco
    DM.ZTableRegistry.Post;
    DM.ZROQueryTmp.Close;
    DM.ZROQueryTmp.Open;
    FormPrincipal.CalendarLiteMain.Invalidate;
    // Limpeza e fechamento da tela
    BtnClearAll.Click;
    FormEditor.Close;

  except
    On E: Exception do
    begin
      DM.ZTableRegistry.Cancel;
      MessageDlg(
        'Erro',
        'Houve um erro ao salvar o registro no banco de dados!' +
        LineEnding + E.Message,
        mtError, [mbOK],
        0);
    end;
  end;
end;

procedure TFormEditor.BtnSaveTemplateClick(Sender: TObject);
var
  TemplateFile: String;
begin
  TemplateFile:=FormPrincipal.DataPath+'template.html';
  SynEditTemplate.Lines.SaveToFile(TemplateFile);
end;

procedure TFormEditor.FormActivate(Sender: TObject);
var
  BlobStream: TStream;
  HTMLString: TStringList;
begin
   PageControlMain.ActivePageIndex:=0;
   if Mode = 'edit' then
   begin
     EditDate.Date:=DM.ZTableRegistry.FieldByName('CREATED_AT').AsDateTime;
     EditTitle.Text:=TCryptoHelper.DecryptString(DM.ZTableRegistry.FieldByName('TITLE').AsString, TCryptoHelper.KeyDefault);
     HTMLString:=TStringList.Create;
     BlobStream := DM.ZTableRegistry.CreateBlobStream(DM.ZTableRegistry.FieldByName('CONTENT'), bmRead);
     try
       HTMLString.LoadFromStream(BlobStream);
       SynEditContent.Lines.Text:= TCryptoHelper.DecryptString(HTMLString.Text, TCryptoHelper.KeyDefault);
     finally
       BlobStream.Free;
       HTMLString.Free;
     end;
   end;
end;

procedure TFormEditor.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  Mode:= '';
  EditDate.Clear;
  EditTitle.Clear;
end;

end.

