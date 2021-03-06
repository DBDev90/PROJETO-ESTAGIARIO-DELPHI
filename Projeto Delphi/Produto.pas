unit Produto;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, DBGrids, StdCtrls, ExtCtrls, DBCtrls, DB, ADODB, Buttons;

type
  TTProduto = class(TForm)
    Panel1: TPanel;
    Label1: TLabel;
    lblNumRegistroP: TLabel;
    rgFiltroProduto: TRadioGroup;
    Panel2: TPanel;
    Panel3: TPanel;
    lblPesquisa: TLabel;
    edPesquisaProduto: TEdit;
    DBGridP: TDBGrid;
    DBNavigator1: TDBNavigator;
    qProduto: TADOQuery;
    dsProduto: TDataSource;
    btnLimpar: TBitBtn;
    btnFechar: TBitBtn;
    btnExcluir: TBitBtn;
    btnEditar: TBitBtn;
    btnConsultar: TBitBtn;
    btnInserir: TBitBtn;
    btnTransferir: TBitBtn;
    procedure btnInserirClick(Sender: TObject);
    procedure btnConsultarClick(Sender: TObject);
    procedure btnEditarClick(Sender: TObject);
    procedure btnFecharClick(Sender: TObject);
    procedure btnLimparClick(Sender: TObject);
    procedure DBGridPTitleClick(Column: TColumn);
    procedure edPesquisaProdutoKeyPress(Sender: TObject; var Key: Char);
    procedure btnExcluirClick(Sender: TObject);
    procedure rgFiltroProdutoClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure DBGridPDrawColumnCell(Sender: TObject; const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
    procedure btnTransferirClick(Sender: TObject);
  private
    { Private declarations }
    ColunaPesquisa, TranProd: string;
    CanClose: Boolean;
    procedure qProdutoATIVOGetText(Sender: TField; var Text: string;
      DisplayText: Boolean);
  public
    { Public declarations }
    procedure ChamaTelaP;
    function TranProduto(Tacao: string): string;
  end;

var
  TProduto: TTProduto;

implementation

uses
  ProdutoC, DMPrincipal, Funcoes, Funcoesdb;

{$R *.dfm}

{ TTProduto }



{ TTProduto }

procedure TTProduto.btnConsultarClick(Sender: TObject);
begin
  if qProduto.IsEmpty then
  begin
    EnviaMensagem('? preciso selecionar um produto para Consultar', 'Informa??o', mtInformation, [mbOK]);
    if edPesquisaProduto.CanFocus then
      edPesquisaProduto.SetFocus;
    Exit;
  end
  else
    TProdutoC.ChamaTelaP(qProduto.FieldByName('COD_PRODUTO').AsString, 'C');
end;

procedure TTProduto.btnEditarClick(Sender: TObject);
begin
  if qProduto.IsEmpty then
  begin
    EnviaMensagem('? preciso selecionar um produto para Editar', 'Informa??o', mtInformation, [mbOK]);
    if edPesquisaProduto.CanFocus then
      edPesquisaProduto.SetFocus;
    Exit;
  end
  else
    TProdutoC.ChamaTelaP(qProduto.FieldByName('COD_PRODUTO').AsString, 'E');
  qProduto.Requery;
end;

procedure TTProduto.btnExcluirClick(Sender: TObject);
begin
  CanClose := False;

  if qProduto.IsEmpty then
  begin
    EnviaMensagem('? preciso selecionar um produto para Excluir', 'Informa??o', mtInformation, [mbOK]);
    if edPesquisaProduto.CanFocus then
      edPesquisaProduto.SetFocus;
    Exit;
  end
  else
  begin
    if (MessageBox(Handle, 'Voc? tem certeza dessa a??o?', 'Aten??o', MB_ICONQUESTION + MB_YESNO)) = IDYES then
      CanClose := True
    else
      Exit;

    if CanClose = True then
    begin
      with TDMPrincipal.qAux do
      begin
        Close;
        SQL.Clear;
        SQL.Add('DELETE PRODUTO');
        SQL.Add('WHERE COD_PRODUTO = ' + qProduto.FieldByName('COD_PRODUTO').AsString);
        ExecSQL;

        EnviaMensagem('O produto foi exclu?do!', 'Informa??o', mtInformation, [mbOK]);
      end;
      qProduto.Requery;

      lblNumRegistroP.Caption := IntToStr(qProduto.RecordCount);
    end;
  end;
end;

procedure TTProduto.btnFecharClick(Sender: TObject);
begin
  TProduto.Close;
end;

procedure TTProduto.btnInserirClick(Sender: TObject);
var
  RCodigo: string;
begin
  RCodigo := TProdutoC.ChamaTelaP(' ', 'I');
  if RCodigo > '0' then
  begin
    with qProduto do
    begin
      Close;
      SQL.Clear;
      SQL.Add('SELECT * FROM PRODUTO');
      SQL.Add('WHERE COD_PRODUTO = ' + RCodigo);
      Open;

      TFloatField(qProduto.FieldByName('PRECO')).currency := true;
    end;
  end;
end;

procedure TTProduto.btnLimparClick(Sender: TObject);
begin
  qProduto.Close;
  edPesquisaProduto.Clear;
  lblNumRegistroP.Caption := '0';
  rgFiltroProduto.ItemIndex := 0;

  if edPesquisaProduto.CanFocus then
    edPesquisaProduto.SetFocus;
end;

procedure TTProduto.btnTransferirClick(Sender: TObject);
begin
  if qProduto.IsEmpty then
  begin
    EnviaMensagem('? preciso selecionar um produto para Transferir', '', mtInformation, [mbOK]);
    Exit;
  end
  else
    TranProd := qProduto.FieldByName('COD_PRODUTO').AsString;
  TProduto.Close;
end;

procedure TTProduto.ChamaTelaP;
begin
  TProduto := TTProduto.Create(Application);
  with TProduto do
  begin
    ShowModal;
  end;
  FreeAndNil(TProduto);
end;

procedure TTProduto.DBGridPDrawColumnCell(Sender: TObject; const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
begin
  qProduto.Open;
  if qProduto.FieldByName('ATIVO').Value = 0 then
  begin
    DBGridP.Canvas.Font.Color := clRed;
    DBGridP.Canvas.FillRect(Rect);
    DBGridP.DefaultDrawColumnCell(Rect, DataCol, Column, State);
  end;
end;

procedure TTProduto.DBGridPTitleClick(Column: TColumn);
var
  I: Integer;
begin
  ColunaPesquisa := Column.FieldName;
  if ColunaPesquisa <> 'ATIVO' then
  begin
    lblPesquisa.Caption := 'Digite um ' + Column.Title.Caption + ' ou * para todos e Tecle Enter';
    btnLimpar.Click;

    for I := 0 to DBGridP.Columns.Count - 1 do
    begin
      if DBGridP.Columns[I].FieldName = ColunaPesquisa then
        DBGridP.Columns[I].Title.Font.Color := clRed
      else
        DBGridP.Columns[I].Title.Font.Color := clBlack;
    end
  end;
end;

procedure TTProduto.edPesquisaProdutoKeyPress(Sender: TObject; var Key: Char);

  function Filtro: string;
  begin
    if TProduto.Tag = 0 then
    begin
      TProduto.Tag := 1;
      Result := ' WHERE ';
    end
    else
      Result := ' AND ';
  end;

begin
  TProduto.Tag := 0;
  if (ColunaPesquisa = 'COD_PRODUTO') and not CharInSet(Key,['0'..'9', #8, #13, #42]) then
  begin
    EnviaMensagem('Utilize apenas N?meros ou * para pesquisar por C?digo do Produto', 'Informa??o', mtInformation, [mbOK]);
    Key := #0;
  end
  else if (ColunaPesquisa = 'DESCRICAO') and CharInSet(Key,['0'..'9',#33..#41,#43..#47,#58..#64,#91..#93,#95,#123..#125]) then
  begin
    EnviaMensagem('Utilize apenas Letras ou * para pesquisar por Descri??o', 'Informa??o', mtInformation, [mbOK]);
    Key := #0;
  end
  else if (ColunaPesquisa = 'DATA_VALIDADE') and not CharInSet(Key, ['0'..'9', #8, #13, #47, #42]) then
  begin
    EnviaMensagem('Utilize apenas N?meros ou * para pesquisar por Data de Validade', 'Informa??o', mtInformation, [mbOK]);
    Key := #0;
  end
  else if (ColunaPesquisa = '') and not CharInSet(Key,[#13,#42]) then
  begin
    EnviaMensagem('Utilize * ou escolha uma coluna da tabela.', 'Informa??o', mtInformation, [mbOK]);
    Key := #0;
  end
  else if (Key = #13) and not Empty(edPesquisaProduto.Text) then
  begin
    with qProduto do
    begin
      Close;
      SQL.Clear;
      SQL.Add('SELECT COD_PRODUTO, DESCRICAO, PRECO, DATA_VALIDADE, ATIVO');
      SQL.Add('FROM PRODUTO');
      if edPesquisaProduto.Text <> '*' then
      begin
        if ColunaPesquisa = 'COD_PRODUTO' then
          SQL.Add(Filtro + ' COD_PRODUTO = ' + StringTextSql(edPesquisaProduto.Text));

        if ColunaPesquisa = 'DESCRICAO' then
          SQL.Add(Filtro + ' DESCRICAO LIKE ''%' + edPesquisaProduto.Text + '%''');

        lblPesquisa.Caption := 'Digite uma Descri??o ou * para todos e Tecle Enter';
        if ColunaPesquisa = 'PRECO' then
          SQL.Add(Filtro + ' PRECO LIKE ''%' + edPesquisaProduto.Text + '%''');

        if ColunaPesquisa = 'DATA_VALIDADE' then
          SQL.Add(Filtro + ' DATA_VALIDADE LIKE ''%' + edPesquisaProduto.Text + '%''');
      end;
      case rgFiltroProduto.ItemIndex of
        0:
          SQL.Add(Filtro + ' ATIVO = 1');
        1:
          SQL.Add(Filtro + ' ATIVO = 0');
      end;
      Open;
      FieldByName('ATIVO').OnGetText := qProdutoATIVOGetText;
      if qProduto.RecordCount = 0 then
        EnviaMensagem('N?o h? registros no sistema, verifique a informa??o digitada!', 'Informa??o', mtInformation, [mbOK]);

      TFloatField(qProduto.FieldByName('PRECO')).currency := true;

      lblNumRegistroP.Caption := IntToStr(qProduto.RecordCount);
      edPesquisaProduto.Clear;
    end;
  end;
end;

procedure TTProduto.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  case Key of
    VK_ESCAPE:
      begin
        if (btnFechar.Visible) and (btnFechar.Enabled) then
          btnFechar.Click;
      end;
    VK_F2:
      begin
        if (btnInserir.Visible) and (btnInserir.Enabled) then
          btnInserir.Click;
      end;
    VK_F3:
      begin
        if (btnConsultar.Visible) and (btnConsultar.Enabled) then
          btnConsultar.Click;
      end;
    VK_F4:
      begin
        if (btnEditar.Visible) and (btnEditar.Enabled) then
          btnEditar.Click;
      end;
    VK_F6:
      begin
        if (btnLimpar.Visible) and (btnLimpar.Enabled) then
          btnLimpar.Click;
      end;
    VK_F8:
      begin
        if (btnExcluir.visible) and (btnExcluir.Enabled) then
          btnExcluir.Click;
      end;
    VK_F12:
      begin
        if (btnTransferir.Visible) and (btnTransferir.Enabled) then
          btnTransferir.Click;
      end;
  end;
end;

procedure TTProduto.FormShow(Sender: TObject);
begin
  ColunaPesquisa := '';
  if edPesquisaProduto.CanFocus then
    edPesquisaProduto.SetFocus;
end;

procedure TTProduto.qProdutoATIVOGetText(Sender: TField; var Text: string;
  DisplayText: Boolean);
begin
  if qProduto.FieldByName('ATIVO').AsBoolean then
    Text := 'ATIVO'
  else
    Text := 'INATIVO';
end;

procedure TTProduto.rgFiltroProdutoClick(Sender: TObject);
begin
  qProduto.Close;
  edPesquisaProduto.Clear;
  lblNumRegistroP.Caption := '0';
  if edPesquisaProduto.CanFocus then
    edPesquisaProduto.SetFocus;
end;

function TTProduto.TranProduto(Tacao: string): string;
begin
  TProduto := TTProduto.Create(Application);
  with TProduto do
  begin
    if Tacao = 'T' then
    begin
      btnTransferir.Visible := True;

      if (btnInserir.Visible) and (btnInserir.Enabled) then
      begin
        btnInserir.Visible := False;
        btnInserir.Enabled := False;
      end;
      if (btnConsultar.Visible) and (btnConsultar.Enabled) then
      begin
        btnConsultar.Visible := False;
        btnConsultar.Enabled := False;
      end;
      if (btnEditar.Visible) and (btnEditar.Enabled) then
      begin
        btnEditar.Visible := False;
        btnEditar.Enabled := False;
      end;
      if (btnExcluir.Visible) and (btnExcluir.Enabled) then
      begin
        btnExcluir.Visible := False;
        btnExcluir.Enabled := False;
      end;
    end;
    ShowModal;
    Result := TranProd;
  end;
  FreeAndNil(TProduto);
end;

end.

