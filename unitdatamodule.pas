unit unitDataModule;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, ZConnection, ZDataset, ZAbstractRODataset, DB, CryptoHelper;

type

  { TDM }

  TDM = class(TDataModule)
    ZConnectionMain: TZConnection;
    ZQueryTmp: TZQuery;
    ZROQueryTmp: TZReadOnlyQuery;
    ZTableRegistryCONTENT: TZRawCLobField;
    ZTableRegistryCREATED_AT: TZDateField;
    ZTableRegistryID: TZIntegerField;
    ZTableRegistryTITLE: TZRawStringField;
    ZTableUser: TZTable;
    ZTableRegistry: TZTable;
    procedure ZTableRegistryFilterRecord(DataSet: TDataSet; var Accept: Boolean
      );
    procedure ZTableRegistryTITLEGetText(Sender: TField; var aText: string;
      DisplayText: Boolean);
  private

  public
    SearchTitle: String;
  end;

var
  DM: TDM;

implementation

{$R *.lfm}

{ TDM }

procedure TDM.ZTableRegistryTITLEGetText(Sender: TField; var aText: string;
  DisplayText: Boolean);
begin
  if Sender.IsNull then
    aText:=''
  else
    aText:= TCryptoHelper.DecryptString(Sender.AsString, TCryptoHelper.KeyDefault);
end;

procedure TDM.ZTableRegistryFilterRecord(DataSet: TDataSet; var Accept: Boolean
  );
var
  S: String;
begin
  if SearchTitle = '' then
  begin
    Accept := True;
    Exit;
  end;
  S := TCryptoHelper.DecryptString(DataSet.FieldByName('TITLE').AsString,TCryptoHelper.KeyDefault);
  Accept := Pos(SearchTitle, UpperCase(S)) > 0;
end;

end.

