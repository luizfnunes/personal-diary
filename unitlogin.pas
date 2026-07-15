unit unitLogin;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, Buttons,
  CryptoHelper;

type

  { TFormLogin }

  TFormLogin = class(TForm)
    ButtonLogin: TBitBtn;
    ButtonClose: TBitBtn;
    EditPassword: TLabeledEdit;
    ImageAvatar: TImage;
    EditUsername: TLabeledEdit;
    ImageListLogin: TImageList;
    SpeedButtonEye: TSpeedButton;
    procedure ButtonLoginClick(Sender: TObject);
    procedure ButtonCloseClick(Sender: TObject);
    procedure EditPasswordKeyPress(Sender: TObject; var Key: char);
    procedure EditUsernameKeyPress(Sender: TObject; var Key: char);
    procedure FormShow(Sender: TObject);
    procedure SpeedButtonEyeClick(Sender: TObject);
  private

  public

  end;

var
  FormLogin: TFormLogin;

implementation

uses unitDataModule;

{$R *.lfm}

{ TFormLogin }
procedure ConnectDatabase;
var
  DataPath: String;
begin
  DataPath:=ExtractFilePath(Application.ExeName) + 'data\';
  try
    DM.ZTableRegistry.Close;
    DM.ZROQueryTmp.Close;
    DM.ZConnectionMain.Connected:=False;
    DM.ZConnectionMain.Database:=DataPath+'DATABASE.FDB';
    DM.ZConnectionMain.Protocol:='firebird';
    DM.ZConnectionMain.LibraryLocation:=DataPath+'FBCLIENT.dll';
    DM.ZConnectionMain.Connect;
    DM.ZTableRegistry.TableName:='REGISTER';
    DM.ZTableRegistry.Open;
    DM.ZTableUser.TableName:='USERS';
    DM.ZTableUser.Open;
  except
    On E: Exception do
    begin
      MessageDlg(
        'Erro',
        'Houve um erro ao conectar com o banco de dados! Finalizando Programa.' +
        LineEnding + E.Message,
        mtError, [mbOK],
        0);
      Application.Terminate;
    end;
  end;
end;

procedure TFormLogin.ButtonCloseClick(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TFormLogin.EditPasswordKeyPress(Sender: TObject; var Key: char);
begin
  if Key = #13 then
    ButtonLogin.Click;
end;

procedure TFormLogin.EditUsernameKeyPress(Sender: TObject; var Key: char);
begin
  if Key = #13 then
    EditPassword.SetFocus;
end;

procedure TFormLogin.FormShow(Sender: TObject);
begin
  ConnectDatabase;
end;

procedure TFormLogin.SpeedButtonEyeClick(Sender: TObject);
begin
  if EditPassword.PasswordChar = #0 then
  begin
    EditPassword.PasswordChar:='*';
    SpeedButtonEye.ImageIndex:=2;
  end
  else
  begin
    EditPassword.PasswordChar:=#0;
    SpeedButtonEye.ImageIndex:=3;
  end;
end;

procedure TFormLogin.ButtonLoginClick(Sender: TObject);
var
  User, Passwd, Hash: String;
begin
  User:=EditUsername.Text;
  Passwd:=EditPassword.Text;
  DM.ZQueryTmp.Connection:=DM.ZConnectionMain;
  DM.ZQueryTmp.Close;
  DM.ZQueryTmp.SQL.Text:='SELECT * FROM USERS WHERE USERNAME=:username';
  DM.ZQueryTmp.ParamByName('username').AsString:=User;
  DM.ZQueryTmp.Open;
  if DM.ZQueryTmp.RecordCount > 0 then
  begin
    Hash:=DM.ZQueryTmp.FieldByName('PASSWD').AsString;
    if TCryptoHelper.VerifyPassword(Passwd, Hash) then
    begin
      ModalResult:=mrOK;
      Exit;
    end;
  end;
  MessageDlg('Erro!', 'Usuário ou senha inválidos!', mtError, [mbOK], 0);
end;

end.

