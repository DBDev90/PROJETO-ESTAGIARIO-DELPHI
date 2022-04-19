unit Funcoes;

interface

uses SysUtils, Dialogs, Controls, StdCtrls, DateUtils;

function DataSQL(Data : TDateTime ) : String;

function DataSQLT(Data: TDateTime ): String;

function Empty( Dados: string ): boolean;

function DiasDoMes(AYear, AMonth: Integer): Integer;

function ValidarData( Data: string ):Boolean;

function Bissexto(AYear: Integer): Boolean;

function EnviaMensagem(Mensagem, Tipo: String; DlgType: TMsgDlgType; DlgButtonsType: TMsgDlgButtons): TModalResult;

implementation



function DataSQLT(Data: TDateTime ): String;
begin
  Result := QuotedStr(FormatDateTime('yyyy-mm-dd hh:mm:ss', Data));// + ' '+TimeToStr(Data) );
end;

function DataSQL(Data : TDateTime ) : String;
begin
  Result := QuotedStr(FormatDateTime('yyyy-mm-dd', Data) + ' 00:00:00');
end;

function Empty( Dados: string ): boolean;
begin
  if Length( Trim( Dados ) ) = 0 then
    Empty := True
  else
    Empty := False;
end;

function EnviaMensagem(Mensagem, Tipo: String; DlgType: TMsgDlgType; DlgButtonsType: TMsgDlgButtons): TModalResult;
var
  i: Integer;
begin
  with CreateMessageDialog(Mensagem, DlgType, DlgButtonsType) do
  try
    for i:= 0 to ComponentCount-1 do
     if Components[i] is TButton then
    begin
      with TButton(Components[i]) do
      case ModalResult of
        mrOk:     Caption:= 'Ok';
        mrCancel: Caption:= 'Cancelar';
        mrAbort:  Caption:= 'Abortar';
        mrRetry:  Caption:= 'Repetir';
        mrIgnore: Caption:= 'Ignorar';
        mrYes:    Caption:= 'Sim';
        mrNo:     Caption:= 'Não';
      end;
    end;
    Caption:= Tipo;
    Result:= ShowModal;
  finally
    Free;
  end;
end;

function ValidarData( Data: string ): Boolean;
var
  I, Y, UltDiaAux, DiaAux, MesAux: Integer;
  Teste: Boolean;
  sDia, sMes, sAno, SMesAno: String;
begin
  Teste := True;
  I := Length(Data);

  for Y := 1 to I do
   if not(Data[Y] in ['0','1','2','3','4','5','6','7','8','9','/']) then
     Teste := False;

  if Teste = True then
  begin
    if (Length(Data) = 8) then
    begin

      sDia := Copy(Data, 1, 2);
      sMes := Copy(Data, 4, 2);
      sAno := Copy(Data, 7, 2);
      SMesAno := Copy(Data, 4, 5);
    end
    else
    begin
      if (Length(Data) = 10) then
      begin
        sDia := Copy(Data, 1, 2);
        sMes := Copy(Data, 4, 2);
        sAno := Copy(Data, 7, 4);
        SMesAno := Copy(Data,4, 7);
      end
      else
        Teste := False;
    end;
  end;

  if Teste = True then
  begin
    MesAux := StrtoInt(SMes);
    if (MesAux <= 12) And (MesAux > 0) then
    begin
      UltDiaAux := DiasDoMes(StrToInt(sAno), StrToInt(sMes));
      DiaAux := StrtoInt(Sdia);
      if (DiaAux > UltDiaAux) or (DiaAux < 1) then
        Teste := False;
    end
    else
      Teste := False;
  end;

  ValidarData := Teste;
end;

function DiasDoMes(AYear, AMonth: Integer): Integer;
const
  DaysInMonth: array[1..12] of Integer = (31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);
begin
  Result := DaysInMonth[AMonth];
  if (AMonth = 2) and Bissexto(AYear) then
    Inc(Result);
end;

function Bissexto(AYear: Integer): Boolean;
begin
  Result := (AYear mod 4 = 0) and ((AYear mod 100 <> 0) or (AYear mod 400 = 0));
end;

end.
