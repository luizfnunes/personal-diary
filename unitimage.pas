unit unitImage;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, EditBtn,
  StdCtrls, MaskEdit, ExtCtrls, Buttons, Spin, Base64, RegExpr, BGRABitmap,
  BGRABitmapTypes, FPWriteJPEG;

type

  { TFormImage }

  TFormImage = class(TForm)
    BtnAdd: TBitBtn;
    BtnCancel: TBitBtn;
    FileNameImage: TFileNameEdit;
    GroupBoxImage: TGroupBox;
    GroupBoxConfig: TGroupBox;
    Label2: TLabel;
    LabelHeight: TLabel;
    LabelFile: TLabel;
    PanelWidth: TPanel;
    PanelHeight: TPanel;
    PanelButtons: TPanel;
    RadioGroupAlign: TRadioGroup;
    RadioGroupSize: TRadioGroup;
    SpinEditHeight: TSpinEdit;
    SpinEditWidth: TSpinEdit;
    procedure BtnAddClick(Sender: TObject);
    procedure BtnCancelClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure RadioGroupSizeSelectionChanged(Sender: TObject);
    function URLValida(const AURL: string): Boolean;
  private

  public

  end;

var
  FormImage: TFormImage;

implementation

uses unitEditor;

{$R *.lfm}

{ TFormImage }

function TFormImage.URLValida(const AURL: string): Boolean;
var
  RE: TRegExpr;
begin
  RE := TRegExpr.Create;
  try
    RE.Expression := '^(https?://)[A-Za-z0-9.-]+\.[A-Za-z]{2,}(:[0-9]+)?(/.*)?$';
    Result := RE.Exec(AURL);
  finally
    RE.Free;
  end;
end;

procedure TFormImage.BtnCancelClick(Sender: TObject);
begin
  FormImage.Close;
end;

procedure TFormImage.BtnAddClick(Sender: TObject);
var
  ImageClass: String;
  Src: String;
  MimeType: String;
  InStream: TFileStream;
  OutStream: RawByteString;
  NewWidth, NewHeight: Integer;
  Img, ImgResize: TBGRABitmap;
  MS: TMemoryStream;
  WriterJPEG: TFPWriterJPEG;
begin
  case LowerCase(ExtractFileExt(FileNameImage.FileName)) of
    '.png': MimeType := 'image/png';
    '.jpg', '.jpeg': MimeType := 'image/jpeg';
    '.gif': MimeType := 'image/gif';
    '.bmp': MimeType := 'image/bmp';
    '.webp': MimeType := 'image/webp';
    '.svg': MimeType := 'image/svg+xml';
  else
    MimeType := 'application/octet-stream';
  end;
  Src:='';
  ImageClass:='';
  if RadioGroupAlign.ItemIndex = 0 then
    ImageClass:='class="left"'
  else if RadioGroupAlign.ItemIndex = 1 then
    ImageClass:='class="right"';
  if FileNameImage.FileName.IsEmpty then
  begin
    MessageDlg('Atenção!', 'Nome do arquivo inválido!', mtWarning, [mbOK], 0);
    Exit;
  end;
  if RadioGroupSize.ItemIndex = 0 then
  begin
    InStream := TFileStream.Create(FileNameImage.FileName, fmOpenRead);
    try
      SetLength(OutStream, InStream.Size);
      InStream.ReadBuffer(OutStream[1], Length(OutStream));
      Src:='<img '+ImageClass+' src="data:image/'+MimeType+';base64,'+EncodeStringBase64(OutStream)+'"/>';
      FormEditor.SynEditContent.InsertTextAtCaret(Src);
      FormImage.Close;
    finally
      InStream.Free;
    end;
  end
  else if RadioGroupSize.ItemIndex = 1 then
  begin
    NewWidth := SpinEditWidth.Value;
    NewHeight := SpinEditHeight.Value;
    Img := TBGRABitmap.Create(FileNameImage.FileName);
    try
      ImgResize := Img.Resample(NewWidth, NewHeight) as TBGRABitmap;
      try
        MS := TMemoryStream.Create;
        WriterJPEG := TFPWriterJPEG.Create;
        try
          // Salva como JPEG
          WriterJPEG.CompressionQuality := 90;
          ImgResize.SaveToStream(MS, WriterJPEG);
          MS.Position := 0;
          SetLength(OutStream, MS.Size);
          MS.ReadBuffer(OutStream[1], MS.Size);

          Src := '<img ' + ImageClass +
                 ' src="data:image/jpeg;base64,' +
                 EncodeStringBase64(OutStream) +
                 '"/>';
          FormEditor.SynEditContent.InsertTextAtCaret(Src);
          Close;
        finally
          MS.Free;
          WriterJPEG.Free;
        end;
      finally
        ImgResize.Free;
      end;
    finally
      Img.Free;
    end;
  end;
end;

procedure TFormImage.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  FileNameImage.Text:='';
  RadioGroupAlign.ItemIndex:=0;
  RadioGroupSize.ItemIndex:=0;
  SpinEditWidth.Value:=320;
  SpinEditHeight.Value:=240;
end;

procedure TFormImage.RadioGroupSizeSelectionChanged(Sender: TObject);
begin
   if RadioGroupSize.ItemIndex = 1 then
   begin
     PanelWidth.Enabled:=True;
     PanelHeight.Enabled:=True;
   end
   else
   begin
     PanelWidth.Enabled:=False;
     PanelHeight.Enabled:=False;
   end;
end;

end.

