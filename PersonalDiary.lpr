program PersonalDiary;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  {$IFDEF HASAMIGA}
  athreads,
  {$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, unitPrincipal, FrameViewer09, unitDataModule, zcomponent, unitEditor, unitImage,
  CryptoHelper, unitUser, unitLogin, Controls, UnitAbout;

{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Scaled:=True;
  {$PUSH}{$WARN 5044 OFF}
  Application.MainFormOnTaskbar:=True;
  {$POP}
  Application.Initialize;
  Application.CreateForm(TDM, DM);
  FormLogin:=TFormLogin.Create(nil);
  try
    if FormLogin.ShowModal = mrOK then
    begin
      Application.CreateForm(TFormPrincipal, FormPrincipal);
      Application.CreateForm(TFormEditor, FormEditor);
      Application.CreateForm(TFormImage, FormImage);
      Application.CreateForm(TFormUser, FormUser);
      Application.CreateForm(TFormAbout, FormAbout);
      Application.Run;
    end
    else
      Application.Terminate;
  finally
    FormLogin.Free;
  end;
end.

