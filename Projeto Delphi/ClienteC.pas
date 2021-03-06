unit ClienteC;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, Mask, Buttons;

type
  TTClienteC = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    cbAtivo: TCheckBox;
    edNomeClienteC: TEdit;
    lbNomeClienteC: TLabel;
    lbRgClienteC: TLabel;
    lblAtivo: TLabel;
    btnCancelar: TBitBtn;
    edRgClienteC: TMaskEdit;
    btnSalvar: TBitBtn;
    procedure btnCancelarClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure btnSalvarClick(Sender: TObject);
    procedure edNomeClienteCKeyPress(Sender: TObject; var Key: Char);
    procedure edRgClienteCKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
    xCodigo, yCodigo: string;
    AcaoTela: Char;
    procedure DesabilitaComponentes;
    procedure CarregaDados;
  public
    { Public declarations }
    function ChamaTela(Codigo: string; pAcaotela: Char): string;
  end;

var
  TClienteC: TTClienteC;

implementation

uses
  Funcoes, Funcoesdb, DMPrincipal, Produto, Cliente;

{$R *.dfm}

{ TTClienteC }


{ TTClienteC }

procedure TTClienteC.btnCancelarClick(Sender: TObject);
begin
  TClienteC.Close;
end;

procedure TTClienteC.btnSalvarClick(Sender: TObject);
begin
  if Empty(edNomeClienteC.Text) then
  begin
    EnviaMensagem('Informe o nome!', 'Informa??o', mtInformation, [mbOK]);
    if edNomeClienteC.CanFocus then
      edNomeClienteC.SetFocus;
    Exit;
  end;
  if (edRgClienteC.Text = '  .   .   - ') or Empty(edRgClienteC.Text) then
  begin
    EnviaMensagem('Informe o RG!', 'Informa??o', mtInformation, [mbOK]);
    if edRgClienteC.CanFocus then
      edRgClienteC.SetFocus;
      Exit;
  end;

  if AcaoTela = 'I' then
  begin
    if not (VerificaRG('Cliente', edRgClienteC.Text)) then
    begin
      EnviaMensagem('O sistema j? possui um cadastro com esse RG!', 'Informa??o', mtInformation, [mbOK]);
      Exit;
    end;
  end;

  edRgClienteC.Text := StringReplace(edRgClienteC.Text, ',', '.', [rfReplaceAll, rfIgnoreCase]);

  with TDMPrincipal.qAux do
  begin
    case AcaoTela of
      'I':
        begin
          Close;
          SQL.Clear;
          SQL.Add('INSERT INTO CLIENTE(NOME,RG,ATIVO)');
          SQL.Add('VALUES(' + StringTextSql(edNomeClienteC.Text));
          SQL.Add(', ' + StringTextSql(edRgClienteC.Text));
          SQL.Add(',' + BooleanTextSql(cbAtivo.Checked));
          SQL.Add(')');
          ExecSQL;
          EnviaMensagem('Usu?rio cadastrado com sucesso!', 'Informa??o', mtInformation, [mbOK]);

          yCodigo := GetCodigo('CLIENTE');
        end;
      'E':
        begin
          Close;
          SQL.Clear;
          SQL.Add('UPDATE CLIENTE');
          SQL.Add('SET');
          SQL.Add('NOME = ' + StringTextSql(edNomeClienteC.Text));
          SQL.Add(',RG = ' + StringTextSql(edRgClienteC.Text));

          if cbAtivo.Checked then
            SQL.Add(',ATIVO = 1')
          else
            sql.Add(',ATIVO = 0');

          SQL.Add('WHERE COD_CLIENTE = ' + xCodigo);
          ExecSQL;

          EnviaMensagem('As informa??es do cliente foram alteradas!', 'Informa??o', mtInformation, [mbOK]);
        end;
    end;
  end;
  Close;
end;

procedure TTClienteC.CarregaDados;
begin
  with TDMPrincipal.qAux do
  begin
    Close;
    SQL.Clear;
    SQL.Add('SELECT NOME,RG,ATIVO');
    SQL.Add('FROM CLIENTE');
    SQL.Add('WHERE COD_CLIENTE = ' + xCodigo);
    Open;
    if not IsEmpty then
    begin
      edNomeClienteC.Text := FieldByName('NOME').AsString;
      edRgClienteC.Text := FieldByName('RG').AsString;
      cbAtivo.Checked := FieldByName('ATIVO').AsBoolean;
    end;
    case AcaoTela of
      'C':
        begin
          DesabilitaComponentes;
        end;
    end;
  end;
end;

function TTClienteC.ChamaTela(Codigo: string; pAcaotela: Char): string;
begin
  TClienteC := TTClienteC.Create(Application);
  with TClienteC do
  begin
    xCodigo := Codigo;
    AcaoTela := pAcaotela;

    if pAcaotela <> 'I' then
      CarregaDados
    else
    begin
      cbAtivo.Checked := True;
      cbAtivo.Enabled := False;
    end;
    ShowModal;
    Result := yCodigo;
  end;
  FreeAndNil(TClienteC);
end;

procedure TTClienteC.DesabilitaComponentes;
begin
  edNomeClienteC.ReadOnly := True;
  edNomeClienteC.Enabled := False;
  edRgClienteC.ReadOnly := True;
  edRgClienteC.Enabled := False;
  cbAtivo.Enabled := False;
  btnSalvar.Visible := False;
end;

procedure TTClienteC.edNomeClienteCKeyPress(Sender: TObject;
  var Key: Char);
begin
  if CharInSet(Key,['0'..'9',#33..#41,#43..#47,#58..#64,#91..#93,#95,#123..#125]) then
  begin
    EnviaMensagem('Utilize apenas Letras.', 'Informa??o', mtInformation, [mbOK]);
    Key := #0;
  end
end;

procedure TTClienteC.edRgClienteCKeyPress(Sender: TObject; var Key: Char);
begin
  if not CharInSet(Key,['0'..'9',#8]) then
  begin
    EnviaMensagem('Utilize apenas N?meros.', 'Informa??o', mtInformation, [mbOK]);
    Key := #0;
  end;
end;

procedure TTClienteC.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  case Key of
    VK_ESCAPE:
      begin
        if (btnCancelar.Visible) and (btnCancelar.Enabled) then
          btnCancelar.Click;
      end;
    VK_F5:
      begin
        if (btnSalvar.Visible) and (btnSalvar.Enabled) then
          btnSalvar.Click;
      end;
  end;
end;

procedure TTClienteC.FormShow(Sender: TObject);
begin
  if AcaoTela = 'I' then
  begin
    if edNomeClienteC.CanFocus then
      edNomeClienteC.SetFocus;
  end;
end;

end.

