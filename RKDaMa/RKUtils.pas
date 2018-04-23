unit RKUtils;

interface

uses Windows, SysUtils, Classes;

type
  TRKConfig = record
    User: string;
    Pass: string;
    SoftId: string;
    SoftKey: string;
    TypeId: string;
  end;

var
  // ����INI���ļ�����Ĭ���뱾����ͬ������׺ΪINI�����裬���и���INI����
  RKConfigFileName: string;
  // ������Ϣ����
  RKConfig: TRKConfig;

procedure GetRKConfig();
procedure SetRKConfig();

procedure LoadTypeIds(AList: TStrings; const AFileName: string);
function GetIndexByTypeId(AList: TStrings; ATypeId: Integer): Integer; overload;
function GetIndexByTypeId(AList: TStrings; const ATypeId: string): Integer; overload;
function GetTypeIdFromList(AList: TStrings; AIndex: Integer): string; overload;

function GetRandomPartKey: string;

implementation

// ��ȡINI������Ϣ
function ReadString(const ASection, AIdent, ADefault: string): string;
var
  Buffer: array[0..4096 - 1] of Char;
begin
  SetString(Result, Buffer, GetPrivateProfileString(PChar(ASection),
    PChar(AIdent), PChar(ADefault), Buffer, SizeOf(Buffer),
    PChar(RKConfigFileName)));
end;

// ���ַ���д��INI
procedure WriteString(const ASection, AIdent, AValue: string);
begin
  WritePrivateProfileString(PChar(ASection), PChar(AIdent),
    PChar(AValue), PChar(RKConfigFileName));
end;

// �õ��ϴ������õ���Ϣ
procedure GetRKConfig();
begin
  RKConfig.User := ReadString('CONFIG', 'User', 'zdfhyzm');
  RKConfig.Pass := ReadString('CONFIG', 'Password', '123456aaa');
  RKConfig.SoftId := ReadString('CONFIG', 'SoftId', '101707');
  RKConfig.SoftKey := ReadString('CONFIG', 'SoftKey', 'd566ec6b71ae4e83ace82d33827db751');
  RKConfig.TypeId := ReadString('CONFIG', 'TypeId', '3040');
end;

// ���浱ǰ�����õ���Ϣ
procedure SetRKConfig();
begin
  WriteString('CONFIG', 'User', RKConfig.User);
  WriteString('CONFIG', 'Password', RKConfig.Pass);
  WriteString('CONFIG', 'SoftId', RKConfig.SoftId );
  WriteString('CONFIG', 'SoftKey', RKConfig.SoftKey);
  WriteString('CONFIG', 'TypeId', RKConfig.TypeId);  
end;

//
// �������ļ��м��������ļ����ݵ�TStrings�У�����ID��ΪTObjectָ������������Objects��
//
procedure LoadTypeIds(AList: TStrings; const AFileName: string);
var
  S, Id: string;
  I, EndPos, TypeId: Integer;
begin
  AList.Clear;
  if not FileExists(AFileName) then Exit;

  AList.LoadFromFile(AFileName);
  for I := 0 to AList.Count - 1 do
  begin
    S := AList[I];
    EndPos := Pos(']', S);
    if EndPos > 0 then
    begin
      Id := Copy(S, 2, EndPos - 2);
      TypeId := StrToIntDef(Id, 0);
      AList.Objects[I] := Pointer(TypeId);
    end;
  end;
end;

// �õ�TString�У�����ID��ȡ�ö�Ӧindex����ΪTCombobox��ʾ��
// ����������ʹ�����á�
function GetIndexByTypeId(AList: TStrings; ATypeId: Integer): Integer; 
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to AList.Count - 1 do
    if Integer(AList.Objects[I]) = ATypeId then
    begin
      Result := I;
      break;
    end;
end;

// ͬ�ϣ�������ͬ��
function GetIndexByTypeId(AList: TStrings; const ATypeId: string): Integer;
var
  TypeId: Integer;
begin
  TypeId := StrToIntDef(ATypeId, -1);
  if TypeId <> -1 then
    Result := GetIndexByTypeId(AList, TypeId)
  else
    Result := -1;
end;

// ȡ��AList��Object�����IDֵ(�����stringȡ��)
function GetTypeIdFromList(AList: TStrings; AIndex: Integer): string; overload;
var
  Id: Integer;
begin
  if (AIndex >= 0) and (AIndex < AList.Count) then
  begin
    Id := Cardinal(AList.Objects[AIndex]);
    Result := IntToStr(Id);
  end else
    Result := '';
end;

// �õ�һ��15���ȵ�����ַ���(����+��ĸ)
function GetRandomPartKey: string;

  function RandDigit(): Char;
  var
    V: Integer;
  begin
    V := Random(9);
    if V < 0 then
      V := 0;
    if V > 9 then
      V := 9;
    Result := Char(V + Ord('0'));
  end;

  function RandLetter: Char;
  var
    V: Integer;
  begin
    Result := 'a';
    V := Random(25);
    if V < 0 then
      V := 0;
    if V > 25 then
      V := 25;
    Inc(Result, V);
  end;

var          
  R: PChar;
  KeyRnd, Len: Integer;
begin
  Len := 15;
  SetLength(Result, Len);
  R := PChar(Result);
  while Len > 0 do
  begin
    KeyRnd := Random(13);
    if KeyRnd and 1 = 0 then
      R^ := RandDigit
    else
      R^ := RandLetter;
    Inc(R);
    Dec(Len);
  end;
end;

initialization
  // ��ʼĬ�ϵ������ļ�
  RKConfigFileName := ChangeFileExt(ParamStr(0), '.INI');

end.
