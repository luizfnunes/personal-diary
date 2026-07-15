unit CryptoHelper;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, DCPbase64, DCPrijndael, DCPsha256;

type
  TCryptoHelper = class
  private
    class function GenerateStaticSalt: string;
  public
    class var KeyDefault: String;
    class function EncryptString(const AText, AKey: string): string;
    class function DecryptString(const ACipherText, AKey: string): string;
    class function HashPassword(const APassword: string): string;
    class function VerifyPassword(const APassword, AHash: string): boolean;
  end;

implementation

{ TCryptoHelper }

class function TCryptoHelper.GenerateStaticSalt: string;
begin
  Result := '$2a$10$LazarusCryptoHelperSaltBase$';
end;

class function TCryptoHelper.EncryptString(const AText, AKey: string): string;
var
  Cipher: TDCP_rijndael;
  KeyHash: array[0..31] of Byte; // 256 bits
begin
  if AText = '' then Exit('');

  FillChar(KeyHash, SizeOf(KeyHash), 0);

  with TDCP_sha256.Create(nil) do
  try
    Init;
    UpdateStr(AKey);
    Final(KeyHash);
  finally
    Free;
  end;

  Cipher := TDCP_rijndael.Create(nil);
  try
    Cipher.Init(KeyHash, 256, nil);
    Result := Cipher.EncryptString(AText);
  finally
    Cipher.Free;
  end;
end;

class function TCryptoHelper.DecryptString(const ACipherText, AKey: string): string;
var
  Cipher: TDCP_rijndael;
  KeyHash: array[0..31] of Byte;
begin
  if ACipherText = '' then Exit('');

  FillChar(KeyHash, SizeOf(KeyHash), 0);

  with TDCP_sha256.Create(nil) do
  try
    Init;
    UpdateStr(AKey);
    Final(KeyHash);
  finally
    Free;
  end;

  Cipher := TDCP_rijndael.Create(nil);
  try
    Cipher.Init(KeyHash, 256, nil);
    Result := Cipher.DecryptString(ACipherText);
  finally
    Cipher.Free;
  end;
end;

class function TCryptoHelper.HashPassword(const APassword: string): string;
var
  Hasher: TDCP_sha256;
  Digest: array[0..31] of Byte;
begin
  FillChar(Digest, SizeOf(Digest), 0);
  Hasher := TDCP_sha256.Create(nil);
  try
    Hasher.Init;
    Hasher.UpdateStr(APassword + GenerateStaticSalt);
    Hasher.Final(Digest);

    SetLength(Result, SizeOf(Digest) * 2);
    BinToHex(@Digest[0], PChar(Result), SizeOf(Digest));

  finally
    Hasher.Free;
  end;
end;

class function TCryptoHelper.VerifyPassword(const APassword, AHash: string): boolean;
begin
  Result := SameText(HashPassword(APassword), AHash);
end;


initialization
  TCryptoHelper.KeyDefault:='123456';
end.
