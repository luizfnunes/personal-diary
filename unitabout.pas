unit unitAbout;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  Buttons, LCLIntf;

type

  { TFormAbout }

  TFormAbout = class(TForm)
    Fechar: TBitBtn;
    ButtonLink: TButton;
    ImageLogo: TImage;
    Label1: TLabel;
    Label2: TLabel;
    StaticText1: TStaticText;
    procedure ButtonLinkClick(Sender: TObject);
    procedure FecharClick(Sender: TObject);
  private

  public

  end;

var
  FormAbout: TFormAbout;

implementation

{$R *.lfm}

{ TFormAbout }

procedure TFormAbout.ButtonLinkClick(Sender: TObject);
begin
  OpenURL('https://deviantart.com/lazymau');
end;

procedure TFormAbout.FecharClick(Sender: TObject);
begin
  Close;
end;

end.

