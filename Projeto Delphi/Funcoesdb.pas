unit Funcoesdb;

interface

uses SysUtils, Variants,Funcoes, ADODB, Forms, Dialogs, JclSysUtils;

Function StringTextSql( xTexto:Variant ):String ;

function BooleanTextSql(xValor: Variant): String;

function GetCodigo(Tabela:string):string;

function VerificaRG(Tabela,Dados:String):Boolean;

Function DateTextSql( xData:TDateTime; xTipoHora:char = 'N' ):String ;

implementation

uses
  DMPrincipal;

Function StringTextSql( xTexto:Variant ):String;
Begin
  if (xTexto = '') or (xTexto = null) then
   Result := 'NULL'
  else
    Result := QuotedStr(xTexto) ;
end ;

function BooleanTextSql(xValor: Variant): String;
begin
  if xValor = Null then
     Result := 'NULL'
  else
  begin
    if xValor = True then
      Result := StringTextSql('1')
    Else
      Result := StringTextSql('0');
  end;
end;

Function DateTextSql( xData:TDateTime; xTipoHora:char ):String ;
Begin
  if xData = 0 then
    Result := 'NULL'
  else
  if xTipoHora = 'T' then
  begin
    Result := DataSQLT(xData);
  end
  else
    Result := DataSQL(xData);
End;

function GetCodigo(Tabela:string):string;
var Qaux:TADOQuery;
begin
try
  Qaux := TADOQuery.Create(Application);
  with Qaux do
  begin
    CommandTimeout := 0;
    Connection := TDMPrincipal.Conexao;
    Close;
    SQL.Clear;
    SQL.Add('SELECT IDENT_CURRENT('+QuotedStr(Tabela)+')AS CODIGO');
    Open;
    if not IsEmpty then
      Result := FieldByName('CODIGO').AsString
    else
      Result :=  '';
  end;
finally
end;
end;


function VerificaRG(Tabela,Dados:String):Boolean;
var Qaux:TADOQuery;
begin
  Qaux :=  TADOQuery.Create(Application);
  with Qaux do
  begin
    Connection := TDMPrincipal.Conexao;
    CommandTimeout := 0;
    Close;
    sql.Clear;
    sql.Add('select * from ' + Tabela);
    SQL.Add('where rg = '+QuotedStr(Dados));
    Open;
    if not IsEmpty then
      Result := False
    else
      Result := True;
  end;
end;

end.
