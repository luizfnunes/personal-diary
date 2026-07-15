unit unitPrincipal;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, DB, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  ComCtrls, DBGrids, DBExtCtrls, DBCtrls, Buttons, HtmlView, CalendarLite, CryptoHelper,
  unitUser, unitAbout;

type

  { TFormPrincipal }

  TFormPrincipal = class(TForm)
    CalendarLiteMain: TCalendarLite;
    DataSourceRegistry: TDataSource;
    DBDateEdit1: TDBDateEdit;
    DBEditTitle: TDBEdit;
    DBGrid1: TDBGrid;
    EditSearch: TEdit;
    GroupBox1: TGroupBox;
    HtmlViewerMain: THtmlViewer;
    ImageListPrincipal: TImageList;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    PanelSearch: TPanel;
    PanelFilter: TPanel;
    PanelRegistry: TPanel;
    PanelView: TPanel;
    SpeedButtonClear: TSpeedButton;
    SpeedButtonSearch: TSpeedButton;
    Splitter1: TSplitter;
    StatusBar1: TStatusBar;
    ToolBar1: TToolBar;
    TBNew: TToolButton;
    TBUser: TToolButton;
    ToolButtonAbout: TToolButton;
    ToolButton2: TToolButton;
    TBEdit: TToolButton;
    TBDelete: TToolButton;
    TBUpdate: TToolButton;
    ToolButton3: TToolButton;
    ToolButton6: TToolButton;
    procedure CalendarLiteMainDblClick(Sender: TObject);
    procedure CalendarLiteMainPrepareCanvas(Sender: TObject; ACanvas: TCanvas;
      AYear, AMonth, ADay: Word; AState: TCalCellStates);
    procedure DataSourceRegistryDataChange(Sender: TObject; Field: TField);
    procedure EditSearchKeyPress(Sender: TObject; var Key: char);
    procedure FormActivate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure SpeedButtonClearClick(Sender: TObject);
    procedure SpeedButtonSearchClick(Sender: TObject);
    procedure TBDeleteClick(Sender: TObject);
    procedure TBEditClick(Sender: TObject);
    procedure TBShowViewClick(Sender: TObject);
    procedure TBNewClick(Sender: TObject);
    procedure TBUpdateClick(Sender: TObject);
    procedure TBUserClick(Sender: TObject);
    procedure ToolButtonAboutClick(Sender: TObject);
  private

  public
    DataPath: String;
    procedure SetDefaultHTML();
    procedure LoadTemplate();
  end;

var
  FormPrincipal: TFormPrincipal;

implementation

{$R *.lfm}
uses unitEditor, unitDataModule;

{ TFormPrincipal }
procedure TFormPrincipal.SetDefaultHTML();
var
  Code: String;
begin
  Code :=
    '<html>' +
    '<body bgcolor="#000000" text="#FFFFFF" style="margin: 0; padding: 0;">' +
    '  <table width="100%" height="100%" border="0" cellspacing="0" cellpadding="0">' +
    '    <tr>' +
    '      <td align="center" valign="middle">' +
    '        ' +
    '        <img src="data:image/png;base64,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" border="0" alt="" />' +
    '        <br /><br />' +
    '        ' +
    '        <font face="Arial, Helvetica, sans-serif" size="5"><b>Diário</b></font>' +
    '      </td>' +
    '    </tr>' +
    '  </table>' +
    '</body>' +
    '</html>';;
  HtmlViewerMain.LoadFromString(Code);
end;

procedure TFormPrincipal.LoadTemplate();
var
  TemplateFile: String;
begin
  TemplateFile:=DataPath+'template.html';
  if FileExists(TemplateFile) then
    FormEditor.SynEditTemplate.Lines.LoadFromFile(TemplateFile)
  else
    MessageDlg('Atenção', 'O arquivo de template não foi encontrado!'+
    LineEnding+'PorFavor, salve um arquivo de template antes de continuar!',
    mtWarning, [mbOk], 0);
end;

procedure TFormPrincipal.TBUpdateClick(Sender: TObject);
begin
  if not DataSourceRegistry.DataSet.IsEmpty then
  begin
    DataSourceRegistry.DataSet.Refresh;
  end;
end;

procedure TFormPrincipal.TBUserClick(Sender: TObject);
begin
  FormUser.ShowModal;
end;

procedure TFormPrincipal.ToolButtonAboutClick(Sender: TObject);
begin
  FormAbout.ShowModal;
end;

procedure TFormPrincipal.TBShowViewClick(Sender: TObject);
begin
  PanelView.Visible:=not PanelView.Visible;
end;

procedure TFormPrincipal.TBNewClick(Sender: TObject);
begin
  FormEditor.Mode:='insert';
  FormEditor.ShowModal;
end;

procedure TFormPrincipal.DataSourceRegistryDataChange(Sender: TObject;
  Field: TField);
var
  FileNameTemplate: String;
  TemplateString: TStringList;
  PreviewString: String;
  BlobStream: TStream;
  HTMLString: TStringList;
begin
  PanelRegistry.Caption:='Total de Registros: '+IntToStr(DataSourceRegistry.DataSet.RecordCount);
  if DataSourceRegistry.DataSet.IsEmpty then
  begin
    SetDefaultHTML();
  end
  else
  begin
    FileNameTemplate:=DataPath+'template.html';
    TemplateString:=TStringList.Create;
    if FileExists(FileNameTemplate) then
    begin
      TemplateString.LoadFromFile(FileNameTemplate);
    end;
    HTMLString:=TStringList.Create;
    BlobStream := DataSourceRegistry.DataSet.CreateBlobStream(DataSourceRegistry.DataSet.FieldByName('CONTENT'), bmRead);
    try
      HTMLString.LoadFromStream(BlobStream);
      if FileExists(FileNameTemplate) then
      begin
        PreviewString:=StringReplace(TemplateString.Text, '{{CONTENT}}', TCryptoHelper.DecryptString(HTMLString.Text, TCryptoHelper.KeyDefault), [rfIgnoreCase]);
        HtmlViewerMain.LoadFromString(PreviewString, '');
      end
      else
      begin
        PreviewString:=TCryptoHelper.DecryptString(HTMLString.Text, TCryptoHelper.KeyDefault);
        HtmlViewerMain.LoadFromString(PreviewString, '');
      end;
    finally
      TemplateString.Free;
      BlobStream.Free;
      HTMLString.Free;
    end;
  end;
end;

procedure TFormPrincipal.EditSearchKeyPress(Sender: TObject; var Key: char);
begin
  if Key = #13 then
    SpeedButtonSearch.Click;
end;


procedure TFormPrincipal.CalendarLiteMainPrepareCanvas(Sender: TObject;
  ACanvas: TCanvas; AYear, AMonth, ADay: Word; AState: TCalCellStates);
var
  DataChecagem: TDateTime;
begin
  if csOtherMonth in AState then Exit;

  if (DM = nil) or (not Assigned(DM)) then Exit;
  if (DM.ZROQueryTmp = nil) or (not DM.ZROQueryTmp.Active) then Exit;

  DataChecagem := EncodeDate(AYear, AMonth, ADay);

  if DM.ZROQueryTmp.Locate('CREATED_AT', DataChecagem, []) then
  begin
    ACanvas.Brush.Style := bsSolid;
    ACanvas.Brush.Color := $00E74C3C;
    ACanvas.Font.Color := clWhite;
    ACanvas.Font.Style := [fsBold];
  end;
end;

procedure TFormPrincipal.CalendarLiteMainDblClick(Sender: TObject);
var
  SelectedDate: TDateTime;
begin
  SelectedDate := TRUNC(CalendarLiteMain.Date);

  // 2. Verifica se o Dataset principal está ativo e pronto
  if (DataSourceRegistry.DataSet <> nil) and (DataSourceRegistry.DataSet.Active) then
  begin
    // 3. Manda o Dataset procurar e se posicionar nessa data
    // Se encontrar, o DBGrid pula para a linha na hora!
    if not DataSourceRegistry.DataSet.Locate('CREATED_AT', SelectedDate, []) then
    begin
      // Opcional: Código caso queira limpar a visualização se clicar num dia vazio
    end;
  end;
end;

procedure TFormPrincipal.FormActivate(Sender: TObject);
begin
  SetDefaultHTML();
  CalendarLiteMain.Invalidate;
end;

procedure TFormPrincipal.FormShow(Sender: TObject);
begin
  DataPath := ExtractFilePath(Application.ExeName) + 'data\';
  LoadTemplate();
  DM.ZROQueryTmp.Close;
  DM.ZROQueryTmp.Open;
  CalendarLiteMain.Date:=Date;
  CalendarLiteMain.Invalidate;
end;

procedure TFormPrincipal.SpeedButtonClearClick(Sender: TObject);
begin
  DM.SearchTitle:='';
  DM.ZTableRegistry.Filtered:=False;
  DM.ZTableRegistry.Filtered:=True;
  EditSearch.Text:='';
end;

procedure TFormPrincipal.SpeedButtonSearchClick(Sender: TObject);
begin
  DM.SearchTitle:=UpperCase(EditSearch.Text);
  DM.ZTableRegistry.Filtered:=False;
  DM.ZTableRegistry.Filtered:=True;
end;

procedure TFormPrincipal.TBDeleteClick(Sender: TObject);
var
  Message: String;
  DecTitle: String;
begin
  DecTitle:=TCryptoHelper.DecryptString(DataSourceRegistry.DataSet.FieldByName('TITLE').AsString, TCryptoHelper.KeyDefault);
  if not DataSourceRegistry.DataSet.IsEmpty then
  begin
    Message:= 'Deseja realmente excluir o registro '+DecTitle;
    if MessageDlg('Excluir registro', Message, mtConfirmation, [mbYes, MbNo], 0) = mrYes then
    begin
      DataSourceRegistry.DataSet.Delete;
      DM.ZROQueryTmp.Close;
      DM.ZROQueryTmp.Open;
      CalendarLiteMain.Invalidate;
    end;
  end;
end;

procedure TFormPrincipal.TBEditClick(Sender: TObject);
begin
  if not DataSourceRegistry.DataSet.IsEmpty then
  begin
    FormEditor.Mode:='edit';
    FormEditor.ShowModal;
  end;
end;


end.

