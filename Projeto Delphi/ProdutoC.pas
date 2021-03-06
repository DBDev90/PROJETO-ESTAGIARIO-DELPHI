unit ProdutoC;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Mask, rxToolEdit, ComCtrls, DBCtrls, Buttons;

type
  TTProdutoC = class(TForm)
    Panel1: TPanel;
    cbAtivo: TCheckBox;
    Panel2: TPanel;
    lbNomeClienteC: TLabel;
    lbRgClienteC: TLabel;
    edDescProdC: TEdit;
    Label1: TLabel;
    DateEdit1: TDateEdit;
    edPrecoProdC: TEdit;
    btnSalvar: TBitBtn;
    btnCancelar: TBitBtn;
    procedure btnCancelarClick(Sender: TObject);
    procedure btnSalvarClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure edDescProdCKeyPress(Sender: TObject; var Key: Char);
    procedure edPrecoProdCKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
    xCodigo, yCodigo: string;
    AcaoTela: Char;
    procedure DesabilitaComponentes;
    procedure CarregaDados;
  public
    { Public declarations }
    function ChamaTelaP(Codigo: string; pAcaoTela: Char): string;
  end;

var
  TProdutoC: TTProdutoC;

implementation

uses
  Funcoes, DMPrincipal, Funcoesdb, Produto;

{$R *.dfm}

procedure TTProdutoC.btnCancelarClick(Sender: TObject);
begin
  TProdutoC.Close;
end;

procedure TTProdutoC.btnSalvarClick(Sender: TObject);
begin
  if Empty(edDescProdC.Text) then
  begin
    EnviaMensagem('Informe a descri??o!', 'Informa??o', mtInformation, [mbOK]);
    if edDescProdC.CanFocus then
      edDescProdC.SetFocus;
    Exit;
  end;
  if Empty(edPrecoProdC.Text) then
  begin
    EnviaMensagem('Informe o pre?o!', 'Informa??o', mtInformation, [mbOK]);
    if edPrecoProdC.CanFocus then
      edPrecoProdC.SetFocus;
    Exit;
  end;
  if not (ValidarData(DateEdit1.Text)) then
  begin
    EnviaMensagem('Informe uma data de validade!', 'Informa??o', mtInformation, [mbOK]);
    Exit;
  end;

  edPrecoProdC.Text := StringReplace(edPrecoProdC.Text,',','.',[rfReplaceAll,rfIgnoreCase]);

  with TDMPrincipal.qAux do
  begin
    case AcaoTela of
      'I':
        begin
          Close;
          SQL.Clear;
          SQL.Add('INSERT INTO PRODUTO(DESCRICAO,PRECO,DATA_VALIDADE,ATIVO)');
          SQL.Add('VALUES(' + StringTextSql(edDescProdC.Text));
          SQL.Add(', ' + StringTextSql(edPrecoProdC.Text));
          SQL.Add(', ' + StringTextSql(FormatDateTime('yyyy/mm/dd hh:mm:ss', DateEdit1.Date)));
          SQL.Add(',' + BooleanTextSql(cbAtivo.Checked));
          SQL.Add(')');
          ExecSQL;
          EnviaMensagem('Produto cadastrado com sucesso!','Informa??o',mtInformation,[mbOK]);

          yCodigo := GetCodigo('PRODUTO'); //retorna ?ltimo registro para feedback no grid
        end;
      'E':
        begin
          Close;
          sql.Clear;
          SQL.Add('UPDATE PRODUTO');
          SQL.Add('SET');
          SQL.Add('DESCRICAO = ' + StringTextSql(edDescProdC.Text));
          SQL.Add(',PRECO = ' + edPrecoProdC.Text);
          SQL.Add(',DATA_VALIDADE = ' + StringTextSql(FormatDateTime('yyyy/mm/dd hh:mm:ss', DateEdit1.Date)));

          if cbAtivo.Checked then
            SQL.Add(',ATIVO = 1')
          else
            SQL.Add(',ATIVO = 0');

          SQL.Add('WHERE COD_PRODUTO = ' + xCodigo);
          ExecSQL;

          EnviaMensagem('As informa??es do produto foram alteradas!', 'Informa??o', mtInformation, [mbOK]);
        end;
    end;
  end;
  Close;
end;

procedure TTProdutoC.CarregaDados;
begin
  with TDMPrincipal.qAux do
  begin
    Close;
    SQL.Clear;
    SQL.Add('SELECT DESCRICAO,PRECO,DATA_VALIDADE,ATIVO');
    SQL.Add('FROM PRODUTO');
    SQL.Add('WHERE COD_PRODUTO = ' + xCodigo);
    Open;
    if not IsEmpty then
    begin
      edDescProdC.Text := FieldByName('DESCRICAO').AsString;
      edPrecoProdC.Text := FieldByName('PRECO').AsString;
      DateEdit1.Text := FieldByName('DATA_VALIDADE').AsString;
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

function TTProdutoC.ChamaTelaP(Codigo: string; pAcaoTela: Char): string;
begin
  TProdutoC := TTProdutoC.Create(Application);
  with TProdutoC do
  begin
    xCodigo := Codigo;
    AcaoTela := pAcaoTela;

    if pAcaoTela <> 'I' then
      CarregaDados
    else
    begin
      cbAtivo.Checked := True;
      cbAtivo.Enabled := False;
    end;
    ShowModal;
    Result := yCodigo;
  end;
  FreeAndNil(TProdutoC);
end;

procedure TTProdutoC.DesabilitaComponentes;
begin
  edDescProdC.ReadOnly := True;
  edDescProdC.Enabled := False;
  edPrecoProdC.ReadOnly := True;
  edPrecoProdC.Enabled := False;
  DateEdit1.ReadOnly := True;
  DateEdit1.Enabled := False;
  cbAtivo.Enabled := False;
  btnSalvar.Visible := False;
end;

procedure TTProdutoC.edDescProdCKeyPress(Sender: TObject; var Key: Char);
begin
  if CharInSet(Key,['0'..'9',#33..#41,#43..#47,#58..#64,#91..#93,#95,#123..#125]) then
  begin
    EnviaMensagem('Utilize apenas Letras.', 'Informa??o', mtInformation, [mbOK]);
    Key := #0;
  end
end;

procedure TTProdutoC.edPrecoProdCKeyPress(Sender: TObject; var Key: Char);
begin
  if not CharInSet(Key,['0'..'9',#8,#44]) then
  begin
    EnviaMensagem('Utilize apenas N?meros.', 'Informa??o', mtInformation, [mbOK]);
    Key := #0;
  end;
end;

procedure TTProdutoC.FormCreate(Sender: TObject);
begin
  DecimalSeparator := ',';
  ThousandSeparator := '.';

  DateEdit1.MinDate := Date();
  DateEdit1.Date := Date;
end;

procedure TTProdutoC.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
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

procedure TTProdutoC.FormShow(Sender: TObject);
begin
  if AcaoTela = 'I' then
  begin
    if edDescProdC.CanFocus then
      edDescProdC.SetFocus;
  end;
end;

end.

