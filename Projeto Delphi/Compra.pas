unit Compra;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Grids, DBGrids, DB, ADODB, DBCtrls, Buttons;

type
  TTCompra = class(TForm)
    Panel3: TPanel;
    lblPesquisa: TLabel;
    edPesquisaCompra: TEdit;
    Panel2: TPanel;
    Panel1: TPanel;
    Panel4: TPanel;
    DBGrid1: TDBGrid;
    DBGrid2: TDBGrid;
    qCompra: TADOQuery;
    dsCompra: TDataSource;
    Panel5: TPanel;
    DBNavigator1: TDBNavigator;
    Label1: TLabel;
    lblNumRegistroC: TLabel;
    qProdutoC: TADOQuery;
    dsProdC: TDataSource;
    btnLimpar: TBitBtn;
    btnFechar: TBitBtn;
    btnExcluir: TBitBtn;
    btnEditar: TBitBtn;
    btnConsultar: TBitBtn;
    btnInserir: TBitBtn;
    procedure btnFecharClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure btnLimparClick(Sender: TObject);
    procedure edPesquisaCompraKeyPress(Sender: TObject; var Key: Char);
    procedure DBGrid1TitleClick(Column: TColumn);
    procedure btnInserirClick(Sender: TObject);
    procedure btnConsultarClick(Sender: TObject);
    procedure btnEditarClick(Sender: TObject);
    procedure btnExcluirClick(Sender: TObject);
    procedure qCompraAfterScroll(DataSet: TDataSet);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    ColunaPesquisa: string;
    CanClose: Boolean;
  public
    { Public declarations }
    procedure ChamaTela;
  end;

var
  TCompra: TTCompra;

implementation

uses
  DMPrincipal, Funcoes, Funcoesdb, CompraC, Cliente;

{$R *.dfm}

{ TTCompra }

procedure TTCompra.btnConsultarClick(Sender: TObject);
begin
  if qCompra.IsEmpty then
  begin
    EnviaMensagem('? preciso selecionar uma compra para Consultar', 'Informa??o', mtInformation, [mbOK]);
    if edPesquisaCompra.CanFocus then
      edPesquisaCompra.SetFocus;
    Exit;
  end
  else
    TCompraC.ChamaTelaC(qCompra.FieldByName('COD_COMPRA').AsString, 'C');
end;

procedure TTCompra.btnEditarClick(Sender: TObject);
begin
  if qCompra.IsEmpty then
  begin
    EnviaMensagem('? preciso selecionar uma compra para Editar', 'Informa??o', mtInformation, [mbOK]);
    if edPesquisaCompra.CanFocus then
      edPesquisaCompra.SetFocus;
    Exit;
  end
  else
    TCompraC.ChamaTelaC(qCompra.FieldByName('COD_COMPRA').AsString, 'E');
end;

procedure TTCompra.btnExcluirClick(Sender: TObject);
begin
  CanClose := False;

  if qCompra.IsEmpty then
  begin
    EnviaMensagem('? preciso selecionar uma compra para Excluir', 'Informa??o', mtInformation, [mbOK]);
    if edPesquisaCompra.CanFocus then
      edPesquisaCompra.SetFocus;
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
        SQL.Add('DELETE COMPRA');
        SQL.Add('WHERE COD_COMPRA = ' + qCompra.FieldByName('COD_COMPRA').AsString);
        ExecSQL;
      end;

      with TDMPrincipal.qAux do
      begin
        Close;
        SQL.Clear;
        SQL.Add('DELETE ITENS_COMPRA');
        SQL.Add('WHERE COD_COMPRA = ' + qCompra.FieldByName('COD_COMPRA').AsString);
        ExecSQL;
      end;
      EnviaMensagem('A compra foi exclu?da!', 'Informa??o', mtInformation, [mbOK]);

      qCompra.Requery;
      qProdutoC.Requery;

      lblNumRegistroC.Caption := IntToStr(qCompra.RecordCount);
    end;
  end;
end;

procedure TTCompra.btnFecharClick(Sender: TObject);
begin
  TCompra.Close;
end;

procedure TTCompra.btnInserirClick(Sender: TObject);
var
  RCodigo: string;
begin
  RCodigo := TCompraC.ChamaTelaC('', 'I');
  if RCodigo > '0' then
  begin
    with qCompra do
    begin
      Close;
      SQL.Clear;
      SQL.Add('SELECT C.COD_COMPRA,C.DATA,CL.NOME');
      SQL.Add('FROM COMPRA C');
      SQL.Add('INNER JOIN CLIENTE CL');
      SQL.Add('ON C.COD_CLIENTE = CL.COD_CLIENTE');
      SQL.Add('WHERE C.COD_COMPRA = ' + RCodigo);
      Open;
    end;

    with qProdutoC do
    begin
      Close;
      SQL.Clear;
      SQL.Add('SELECT IC.COD_PRODUTO,P.DESCRICAO,IC.QUANTIDADE');
      SQL.Add('FROM ITENS_COMPRA IC');
      SQL.Add('INNER JOIN PRODUTO P');
      SQL.Add('ON IC.COD_PRODUTO = P.COD_PRODUTO');
      SQL.Add('INNER JOIN COMPRA C');
      SQL.Add('ON IC.COD_COMPRA = C.COD_COMPRA');
      SQL.Add('WHERE IC.COD_COMPRA = ' + RCodigo);
      Open;
    end;
  end;
end;

procedure TTCompra.btnLimparClick(Sender: TObject);
begin
  qCompra.Close;
  qProdutoC.Close;
  edPesquisaCompra.Clear;
  edPesquisaCompra.Clear;
  lblNumRegistroC.Caption := '0';
  if edPesquisaCompra.CanFocus then
    edPesquisaCompra.SetFocus;
end;

procedure TTCompra.ChamaTela;
begin
  TCompra := TTCompra.Create(Application);
  with TCompra do
  begin
    ShowModal;
  end;
  FreeAndNil(TCompra);
end;

procedure TTCompra.DBGrid1TitleClick(Column: TColumn);
var
  I: Integer;
begin
  ColunaPesquisa := Column.FieldName;
  lblPesquisa.Caption := 'Digite um ' + Column.Title.Caption + ' ou * para Todos e Tecle Enter';
  btnLimpar.Click;

  for I := 0 to DBGrid1.Columns.Count - 1 do
  begin
    if DBGrid1.Columns[I].FieldName = ColunaPesquisa then
      DBGrid1.Columns[I].Title.Font.Color := clRed
    else
      DBGrid1.Columns[I].Title.Font.Color := clBlack;
  end;
end;

procedure TTCompra.edPesquisaCompraKeyPress(Sender: TObject; var Key: Char);
begin
  if (ColunaPesquisa = 'COD_COMPRA') and not CharInSet(Key, ['0'..'9', #8, #13, #42]) then
  begin
    EnviaMensagem('Utilize apenas N?meros ou * para pesquisar por C?digo da Compra', 'Informa??o', mtInformation, [mbOK]);
    Key := #0;
  end
  else if (ColunaPesquisa = 'DATA') and not CharInSet(Key, ['0'..'9', #8, #13, #47, #42]) then
  begin
    EnviaMensagem('Utilize apenas N?meros ou * para pesquisar por Data', 'Informa??o', mtInformation, [mbOK]);
    Key := #0;
  end
  else if (ColunaPesquisa = 'NOME') and CharInSet(Key, ['0'..'9', #33..#41, #43..#47, #58..#64, #91..#93, #95, #123..#125]) then
  begin
    EnviaMensagem('Utilize apenas Letras ou * para pesquisar por Nome', 'Informa??o', mtInformation, [mbOK]);
    Key := #0;
  end
  else if (ColunaPesquisa = '') and not CharInSet(Key,[#13,#42]) then
  begin
    EnviaMensagem('Utilize * ou escolha uma coluna da tabela.', 'Informa??o', mtInformation, [mbOK]);
    Key := #0;
  end
  else if (Key = #13) and not Empty(edPesquisaCompra.Text) then
  begin
    with qCompra do
    begin
      Close;
      SQL.Clear;
      SQL.Add('SELECT C.COD_COMPRA,C.DATA,CL.NOME');
      SQL.Add('FROM COMPRA C');
      SQL.Add('INNER JOIN CLIENTE CL');
      SQL.Add('ON CL.COD_CLIENTE = C.COD_CLIENTE');

      if (edPesquisaCompra.Text) <> '*' then
      begin
        if (ColunaPesquisa = 'COD_COMPRA') then
          SQL.Add('WHERE C.COD_COMPRA = ' + StringTextSql(edPesquisaCompra.Text));

        if ColunaPesquisa = 'DATA' then
          SQL.Add('WHERE C.DATA LIKE ''%' + edPesquisaCompra.Text + '%''');

        if ColunaPesquisa = 'NOME' then
          SQL.Add('WHERE CL.NOME LIKE ''%' + edPesquisaCompra.Text + '%''');
      end;

      Open;

      if qCompra.IsEmpty then
      begin
        EnviaMensagem('N?o h? registros no sistema, verifique a informa??o digitada!', 'Informa??o', mtInformation, [mbOK]);
        Exit;
      end;

      lblNumRegistroC.Caption := IntToStr(qCompra.RecordCount);

      edPesquisaCompra.Clear;
    end;
  end;
end;

procedure TTCompra.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
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
        if (btnExcluir.Visible) and (btnExcluir.Enabled) then
          btnExcluir.Click;
      end;
  end;
end;

procedure TTCompra.FormShow(Sender: TObject);
begin
  if edPesquisaCompra.CanFocus then
    edPesquisaCompra.SetFocus;
end;

procedure TTCompra.qCompraAfterScroll(DataSet: TDataSet);
begin
  with qProdutoC do
  begin
    Close;
    SQL.Clear;
    SQL.Add('SELECT IC.COD_PRODUTO,P.DESCRICAO,IC.QUANTIDADE');
    SQL.Add('FROM ITENS_COMPRA IC');
    SQL.Add('INNER JOIN PRODUTO P');
    SQL.Add('ON P.COD_PRODUTO = IC.COD_PRODUTO');
    SQL.Add('WHERE IC.COD_COMPRA = ' + qCompra.FieldByName('COD_COMPRA').AsString);
    Open;
  end;
end;

end.

