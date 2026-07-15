unit unitUser;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, EditBtn,
  StdCtrls, Buttons, CryptoHelper;

type

  { TFormUser }

  TFormUser = class(TForm)
    BtnClose: TBitBtn;
    BtnUpdate: TBitBtn;
    EditButtonUsername: TEditButton;
    GroupBoxPassword: TGroupBox;
    GroupBoxUsername: TGroupBox;
    ImageAvatar: TImage;
    LabeledEditConfirm: TLabeledEdit;
    LabeledEditOldPass: TLabeledEdit;
    LabeledEditNewPass: TLabeledEdit;
    PanelButtons: TPanel;
    procedure BtnCloseClick(Sender: TObject);
    procedure BtnUpdateClick(Sender: TObject);
    procedure EditButtonUsernameButtonClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ClearPass();
  private

  public

  end;

var
  FormUser: TFormUser;

implementation

uses unitDataModule;

{$R *.lfm}

{ TFormUser }
procedure TFormUser.ClearPass();
begin
  LabeledEditOldPass.Text:='';
  LabeledEditNewPass.Text:='';
  LabeledEditConfirm.Text:='';
end;

procedure TFormUser.FormShow(Sender: TObject);
begin
  EditButtonUsername.Text:=DM.ZTableUser.FieldByName('USERNAME').AsString;
end;

procedure TFormUser.BtnUpdateClick(Sender: TObject);
var
  Hash, Passwd, NewPasswd: String;
begin
  if Length(LabeledEditNewPass.Text) < 5 then
  begin
     MessageDlg('Atenção!', 'Nova senha inválida! Use no mínimo 5 caracteres!', mtWarning, [mbOK], 0);
     Exit;
  end;
  if LabeledEditNewPass.Text <> LabeledEditConfirm.Text then
  begin
     MessageDlg('Atenção!', 'A senha de confirmação é diferente da nova senha!', mtWarning, [mbOK], 0);
     Exit;
  end;
  Hash:=DM.ZTableUser.FieldByName('PASSWD').AsString;
  Passwd:=LabeledEditOldPass.Text;
  if not TCryptoHelper.VerifyPassword(Passwd, Hash) then
  begin
     MessageDlg('Erro!', 'Senha atual inválida!', mtError, [mbOK], 0);
     Exit;
  end;
  NewPasswd:=LabeledEditNewPass.Text;
  DM.ZTableUser.Edit;
  DM.ZTableUser.FieldByName('PASSWD').AsString:=TCryptoHelper.HashPassword(NewPasswd);
  DM.ZTableUser.Post;
  MessageDlg('Sucesso!', 'Senha alterada com sucesso!', mtConfirmation, [mbOK], 0);
  ClearPass();
end;

procedure TFormUser.BtnCloseClick(Sender: TObject);
begin
  ClearPass();
  Close;
end;

procedure TFormUser.EditButtonUsernameButtonClick(Sender: TObject);
begin
  if (EditButtonUsername.Text = '') or (Length(EditButtonUsername.Text) < 3) then
  begin
    MessageDlg('Atenção!', 'Nome de usuário inválido! Use no mínimo 3 caracteres!', mtWarning, [mbOK], 0);
    Exit;
  end;
  DM.ZTableUser.Edit;
  DM.ZTableUser.FieldByName('USERNAME').AsString:=EditButtonUsername.Text;
  DM.ZTableUser.Post;
  MessageDlg('Sucesso!', 'Nome de usuário alterado com sucesso!', mtInformation, [mbOK], 0);
end;

end.

