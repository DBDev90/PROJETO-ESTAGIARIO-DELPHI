unit CompraC;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, DB, DBClient, Grids, DBGrids, Buttons, Mask,
  rxToolEdit, DBCtrls, rxCurrEdit, ADODB;

type
  TTCompraC = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    gbProd: TGroupBox;
    edCodPC: TEdit;
    edDescPC: TEdit;
    edQuantPC: TEdit;
    Panel3: TPanel;
    Label1: TLabel;
    gbClien: TGroupBox;
    btnPesquisarC: TBitBtn;
    edNomeCC: TEdit;
    Panel4: TPanel;
    DBGrid1: TDBGrid;
    dsCompra: TDataSource;
    cdsCompra: TClientDataSet;
    cdsCompraCOD_PRODUTO: TIntegerField;
    cdsCompraDESCRICAO: TStringField;
    cdsCompraQUANTIDADE: TIntegerField;
    cdsCompraPRECO: TFloatField;
    cdsCompraACAO: TStringField;
    deCompra: TDateEdit;
    btnLimparC: TBitBtn;
    Panel5: TPanel;
    edCodCC: TEdit;
    btnPesquisaP: TBitBtn;
    btnLimparP: TBitBtn;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    btnExcluir: TBitBtn;
    btnAdicionar: TBitBtn;
    Label8: TLabel;
    Label9: TLabel;
    lblContaRegistro: TLabel;
    btnSalvar: TBitBtn;
    btnCancelar: TBitBtn;
    lblAcao: TLabel;
    cdsCompraVALORTOTAL: TCurrencyField;
    MostraTotal: TCurrencyEdit;
    edPrecoPC: TCurrencyEdit;
    ADOQuery1: TADOQuery;
    DataSource1: TDataSource;
    cdsCompraCODITEMCOMPRA: TIntegerField;
    procedure btnCancelarClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure btnPesquisarCClick(Sender: TObject);
    procedure btnLimparCClick(Sender: TObject);
    procedure edCodCCKeyPress(Sender: TObject; var Key: Char);
    procedure btnPesquisaPClick(Sender: TObject);
    procedure btnLimparPClick(Sender: TObject);
    procedure edCodPCKeyPress(Sender: TObject; var Key: Char);
    procedure edQuantPCClick(Sender: TObject);
    procedure edQuantPCKeyPress(Sender: TObject; var Key: Char);
    procedure edQuantPCChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure DBGrid1CellClick(Column: TColumn);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnExcluirClick(Sender: TObject);
    procedure btnSalvarClick(Sender: TObject);
    procedure cdsCompraBeforeDelete(DataSet: TDataSet);
    procedure btnAdicionarClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    xCodCompra: string;
    xCodigo: string;
    AcaoTela: Char;
//    Valor: Integer;
//    ProdutoEditado: Double;

    vetProdutosExcluidos: TStringList;
    procedure DBGrid1DblClick(Sender: TObject);
    procedure CarregaDados;
    procedure DesabilitaComponentes;
  public
    { Public declarations }
    function ChamaTelaC(Codigo: string; pAcaoTela: Char): string;
  end;

var
  TCompraC: TTCompraC;

implementation

uses
  Cliente, DMPrincipal, Funcoes, Funcoesdb, Produto, Compra;

{$R *.dfm}

procedure TTCompraC.btnLimparCClick(Sender: TObject);
begin
  if cdsCompra.RecordCount > 0 then
  begin
    if (MessageBox(Handle, 'O cliente atual ser? removido!' + #13#13 + 'Gostaria de remover os produtos que foram adicionados?', 'Aten??o', MB_ICONQUESTION + MB_YESNO)) = IDYES then
    begin
      edCodCC.Clear;
      edNomeCC.Clear;

      if (edCodPC.Text <> '') and (edDescPC.Text <> '') then
      begin
        edCodPC.Clear;
        edDescPC.Clear;
        edPrecoPC.Clear;
        edQuantPC.Clear;

        btnAdicionar.Enabled := False;
        btnLimparP.Enabled := False;
      end;

      if cdsCompra.Active then
      begin
        cdsCompra.EmptyDataSet;
        lblContaRegistro.Caption := IntToStr(cdsCompra.RecordCount);
      end;

      btnLimparC.Enabled := False;
      btnExcluir.Enabled := False;

      MostraTotal.Clear;

      edCodCC.SetFocus;
    end
    else
    begin
      edCodCC.Clear;
      edNomeCC.Clear;

      if edCodCC.CanFocus then
        edCodCC.SetFocus;
    end;
  end
  else
  begin
    edCodCC.Clear;
    edNomeCC.Clear;

    if edCodCC.CanFocus then
      edCodCC.SetFocus;
  end;

end;

procedure TTCompraC.btnLimparPClick(Sender: TObject);
begin
  edCodPC.Clear;
  edDescPC.Clear;
  edPrecoPC.Clear;
  edQuantPC.Clear;
  btnLimparP.Enabled := False;
end;

procedure TTCompraC.btnPesquisaPClick(Sender: TObject);
var
  Produto: string;
begin
  if not ValidarData(deCompra.Text) then
  begin
    EnviaMensagem('? preciso selecionar a data de compra antes de inserir um Produto!', 'Informa??o', mtInformation, [mbOK]);
    if deCompra.CanFocus then
      deCompra.SetFocus;
    Exit;
  end
  else if Empty(edCodCC.Text) and Empty(edNomeCC.Text) then
  begin
    EnviaMensagem('? preciso selecionar um Cliente antes de adicionar um produto!', 'Informa??o', mtInformation, [mbOK]);
    if edCodCC.CanFocus then
      edCodCC.SetFocus;
    Exit;
  end
  else
    Produto := TProduto.TranProduto('T');
  if Produto <> '' then
  begin
    with TDMPrincipal.qAux do
    begin
      Close;
      SQL.Clear;
      SQL.Add('SELECT COD_PRODUTO,DESCRICAO,PRECO');
      SQL.Add('FROM PRODUTO');
      SQL.Add('WHERE COD_PRODUTO = ' + Produto);
      Open;
      if not IsEmpty then
      begin
        edCodPC.Text := FieldByName('COD_PRODUTO').AsString;
        edDescPC.Text := FieldByName('DESCRICAO').AsString;
        edPrecoPC.Text := FieldByName('PRECO').AsString;
        btnLimparP.Enabled := True;

        TFloatField(TDMPrincipal.qAux.FieldByName('PRECO')).currency := true;

        if edQuantPC.CanFocus then
          edQuantPC.SetFocus;
      end
      else
      begin
        EnviaMensagem('N?o h? registros no sistema, verifique a informa??o digitada!', 'Informa??o', mtInformation, [mbOK]);
        btnLimparP.Click;
      end;
    end;
  end;
end;

procedure TTCompraC.btnPesquisarCClick(Sender: TObject);
var
  Cliente: string;
begin
  if not ValidarData(deCompra.Text) then
  begin
    EnviaMensagem('? preciso selecionar a data de compra antes de inserir um Cliente!', 'Informa??o', mtInformation, [mbOK]);
    if deCompra.CanFocus then
      deCompra.SetFocus;
  end
  else
  begin
    Cliente := TCliente.TransferirCliente('T');
    if Cliente <> '' then
    begin
      with TDMPrincipal.qAux do
      begin
        Close;
        SQL.Clear;
        SQL.Add('SELECT COD_CLIENTE,NOME');
        SQL.Add('FROM CLIENTE');
        sql.Add('WHERE COD_CLIENTE = ' + Cliente);
        Open;
        if not IsEmpty then
        begin
          edCodCC.Text := FieldByName('COD_CLIENTE').AsString;
          edNomeCC.Text := FieldByName('NOME').AsString;
          btnLimparC.Enabled := True;

          if btnPesquisaP.CanFocus then
            btnPesquisaP.SetFocus;
        end
        else
        begin
          EnviaMensagem('N?o foi poss?vel transferir o Cliente', 'Informa??o', mtInformation, [mbOK]);
          btnLimparC.Click;
        end;
      end;
    end;
  end;
end;

procedure TTCompraC.btnSalvarClick(Sender: TObject);
begin
  MostraTotal.Text := StringReplace(MostraTotal.Text, ',', '.', [rfReplaceAll, rfIgnoreCase]);

  case AcaoTela of
    'I':
      begin
        with ADOQuery1 do
        begin
          Close;
          SQL.Clear;
          SQL.Add('INSERT INTO COMPRA(DATA, COD_CLIENTE, VALOR_TOTAL)');
          SQL.Add('VALUES(' + StringTextSql(FormatDateTime('yyyy-mm-dd', deCompra.Date)));
          SQL.Add(',' + QuotedStr(edCodCC.Text));
          SQL.Add(',' + StringTextSql(MostraTotal.Text));
          SQL.Add(')');
          ExecSQL;

//          with ADOQuery1 do
//          begin
//            Close;
//            SQL.Clear;
//            SQL.Add('SELECT IDENT_CURRENT(''COMPRA'') AS COD_COMPRA');
//            Open;
//            if not IsEmpty then
//              xCodCompra := FieldByName('COD_COMPRA').AsString;
//          end;
          xCodCompra := GetCodigo('COMPRA');

          with cdsCompra do
          begin
            First;
            while not Eof do
            begin
              ADOQuery1.Close;
              ADOQuery1.SQL.Clear;
              ADOQuery1.SQL.Add('INSERT INTO ITENS_COMPRA(COD_COMPRA,COD_PRODUTO,QUANTIDADE)');
              ADOQuery1.SQL.Add('VALUES(' + xCodCompra);
              ADOQuery1.SQL.Add(',' + FieldByName('COD_PRODUTO').AsString);
              ADOQuery1.SQL.Add(',' + FieldByName('QUANTIDADE').AsString);
              ADOQuery1.SQL.Add(')');
              ExecSQL;
              Next;
            end;
          end;

          EnviaMensagem('Compra realizada com sucesso!', 'Informa??o', mtInformation, [mbOK]);
        end;
      end;
    'E':
      begin
        begin
          if vetProdutosExcluidos.Count > 0 then
          begin
            with ADOQuery1 do
            begin
              Close;
              SQL.Clear;
              SQL.Add('DELETE FROM ITENS_COMPRA');

              if vetProdutosExcluidos.Count > 1 then
              begin
                SQL.Add('WHERE COD_PRODUTO IN (' + vetProdutosExcluidos.DelimitedText + ')');
                SQL.Add('AND COD_COMPRA = ' + xCodigo);
              end
              else
              begin
                SQL.Add('WHERE COD_PRODUTO = ' + vetProdutosExcluidos.DelimitedText);
                SQL.Add('AND COD_COMPRA = ' + xCodigo);
              end;

              ExecSQL;
            end;
          end;
        end;

        with cdsCompra do
        begin
          First;
          while not Eof do
          begin
            ADOQuery1.Close;
            ADOQuery1.SQL.Clear;
            ADOQuery1.SQL.Add('UPDATE ITENS_COMPRA SET');
            ADOQuery1.SQL.Add('COD_COMPRA = ' + xCodigo);
            ADOQuery1.SQL.Add(',COD_PRODUTO = ' + FieldByName('COD_PRODUTO').AsString);
            ADOQuery1.SQL.Add(',QUANTIDADE = ' + FieldByName('QUANTIDADE').AsString);
            ADOQuery1.SQL.Add('WHERE COD_ITEM_COMPRA = ' + FieldByName('CODITEMCOMPRA').AsString);
            ADOQuery1.ExecSQL;
            Next;
          end;

          ADOQuery1.Close;
          ADOQuery1.SQL.Clear;
          ADOQuery1.SQL.Add('UPDATE COMPRA SET');
          ADOQuery1.SQL.Add('VALOR_TOTAL = ' + StringTextSql(MostraTotal.Text));
          ADOQuery1.SQL.Add('WHERE COD_COMPRA = ' + xCodigo);
          ADOQuery1.ExecSQL;

          EnviaMensagem('Compra atualizada com sucesso!', 'Informa??o', mtInformation, [mbOK]);
        end;
      end;
  end;
  Close;
end;

procedure TTCompraC.btnAdicionarClick(Sender: TObject);
var
  aux: Double;
begin
  aux := 0;
  with cdsCompra do
  begin
    if (cdsCompra.Locate('COD_PRODUTO', edCodPC.Text, [])) and not (cdsCompra.FieldByName('ACAO').value = 'E') then
    begin
      EnviaMensagem('Este produto j? foi adicionado!' + #13#13 + 'D? um Duplo Clique sobre o mesmo para Editar!', 'Informa??o', mtInformation, [mbOk]);
      btnLimparP.Click;
      if edCodPC.CanFocus then
        edCodPC.SetFocus;
      Exit;
    end
    else if cdsCompra.FieldByName('ACAO').Value <> 'E' then
    begin
      First;
      Append;
      FieldByName('COD_PRODUTO').Value := edCodPC.Text;
      FieldByName('DESCRICAO').Value := edDescPC.Text;
      FieldByName('QUANTIDADE').Value := edQuantPC.Text;
      FieldByName('PRECO').Value := edPrecoPC.Text;
      FieldByName('VALORTOTAL').AsFloat := StrToFloat(edPrecoPC.Text) * StrToFloat(edQuantPC.Text);
      FieldByName('ACAO').Value := 'I';
      Post;

      First;
      while not cdsCompra.Eof do
      begin
        aux := aux + cdsCompra.FieldByName('VALORTOTAL').AsFloat;
        cdsCompra.Next;
      end;

      lblContaRegistro.Caption := IntToStr(cdsCompra.RecordCount);

      btnLimparP.Click;
      edCodPC.Enabled := True;
      if edCodPC.CanFocus then
        edCodPC.SetFocus;
    end
    else
    begin
      Edit;
      FieldByName('COD_PRODUTO').Value := edCodPC.Text;
      FieldByName('DESCRICAO').Value := edDescPC.Text;
      FieldByName('QUANTIDADE').Value := edQuantPC.Text;
      FieldByName('PRECO').Value := edPrecoPC.Text;
      FieldByName('VALORTOTAL').AsFloat := StrToFloat(edPrecoPC.Text) * StrToFloat(edQuantPC.Text);
      FieldByName('ACAO').Value := 'E';
      Post;

      First;
      while not cdsCompra.Eof do
      begin
        aux := aux + cdsCompra.FieldByName('VALORTOTAL').AsFloat;
        cdsCompra.Next;
      end;

      lblContaRegistro.Caption := IntToStr(cdsCompra.RecordCount);

      edCodPC.Clear;
      edDescPC.Clear;
      edQuantPC.Clear;

      if btnExcluir.Enabled then
        btnExcluir.Enabled := False;
    end;
    MostraTotal.Text := FloatToStr(aux);
  end;
end;

procedure TTCompraC.btnCancelarClick(Sender: TObject);
begin
  TCompraC.Close;
end;

procedure TTCompraC.btnExcluirClick(Sender: TObject);
var
  aux: Double;
begin
  aux := 0;
  if cdsCompra.IsEmpty then
  begin
    EnviaMensagem('? preciso selecionar um registro para excluir!', 'Informa??o', mtInformation, [mbOK]);
    Exit;
  end
  else
  begin
    cdsCompra.Delete;

    with cdsCompra do
    begin
      First;
      while not Eof do
      begin
        aux := aux + FieldByName('VALORTOTAL').AsFloat;
        Next;
      end;
    end;
    MostraTotal.Text := FloatToStr(aux);
  end;

  lblContaRegistro.Caption := IntToStr(cdsCompra.RecordCount);

  btnExcluir.Enabled := false;

  edCodPC.Enabled := True;
  if edCodPC.CanFocus then
    edCodPC.SetFocus;
end;

procedure TTCompraC.CarregaDados;
begin
  with ADOQuery1 do
  begin
    Close;
    SQL.Clear;
    SQL.Add('SELECT C.DATA,C.COD_CLIENTE,CL.NOME');
    SQL.Add('FROM COMPRA C');
    SQL.Add('INNER JOIN CLIENTE CL');
    SQL.Add('ON C.COD_CLIENTE = CL.COD_CLIENTE');
    SQL.Add('WHERE COD_COMPRA = ' + xCodigo);
    Open;

    if not IsEmpty then
    begin
      deCompra.Text := FieldByName('DATA').AsString;
      edCodCC.Text := FieldByName('COD_CLIENTE').AsString;
      edNomeCC.Text := FieldByName('NOME').AsString;

      Close;
      SQL.Clear;
      SQL.Add('SELECT IC.COD_PRODUTO,P.DESCRICAO,P.PRECO,IC.QUANTIDADE,IC.COD_ITEM_COMPRA,C.VALOR_TOTAL');
      SQL.Add('FROM ITENS_COMPRA IC');
      SQL.Add('INNER JOIN PRODUTO P');
      SQL.Add('ON IC.COD_PRODUTO = P.COD_PRODUTO');
      SQL.Add('INNER JOIN COMPRA C');
      SQL.Add('ON IC.COD_COMPRA = C.COD_COMPRA');
      SQL.Add('WHERE IC.COD_COMPRA = ' + xCodigo);
      Open;

      if not IsEmpty then
      begin
        First;
        while not Eof do
        begin
          cdsCompra.Append;
          cdsCompra.FieldByName('COD_PRODUTO').Value := FieldByName('COD_PRODUTO').Value;
          cdsCompra.FieldByName('DESCRICAO').Value := FieldByName('DESCRICAO').Value;
          cdsCompra.FieldByName('PRECO').Value := FieldByName('PRECO').Value;
          cdsCompra.FieldByName('QUANTIDADE').Value := FieldByName('QUANTIDADE').Value;
          cdsCompra.FieldByName('VALORTOTAL').Value := FieldByName('QUANTIDADE').Value * FieldByName('PRECO').Value;
          cdsCompra.FieldByName('ACAO').Value := 'I';
          cdsCompra.FieldByName('CODITEMCOMPRA').value := FieldByName('COD_ITEM_COMPRA').Value;
          MostraTotal.Text := FieldByName('VALOR_TOTAL').AsString;
          cdsCompra.Post;
          Next;
        end;

        lblContaRegistro.Caption := IntToStr(cdsCompra.RecordCount);
      end;
    end;

    case AcaoTela of
      'C':
        begin
          DesabilitaComponentes;
        end;
      'E':
        begin
          btnPesquisarC.Enabled := False;
          edCodCC.Enabled := False;
          btnPesquisaP.Enabled := False;
          edCodPC.Enabled := False;
          edQuantPC.Enabled := false;
        end;
    end;
  end;
end;

procedure TTCompraC.cdsCompraBeforeDelete(DataSet: TDataSet);
begin
  if not Empty(cdsCompra.FieldByName('COD_PRODUTO').AsString) then
  begin
    vetProdutosExcluidos.Add(cdsCompra.FieldByName('COD_PRODUTO').AsString);
  end;
end;

function TTCompraC.ChamaTelaC(Codigo: string; pAcaoTela: Char): string;
begin
  TCompraC := TTCompraC.Create(Application);
  with TCompraC do
  begin
    xCodigo := Codigo;
    AcaoTela := pAcaoTela;

    if pAcaoTela <> 'I' then
      CarregaDados;

    ShowModal;
    Result := xCodCompra;
  end;
  FreeAndNil(TCompraC);
end;

procedure TTCompraC.DBGrid1CellClick(Column: TColumn);
begin
  btnExcluir.Enabled := True;
end;

procedure TTCompraC.DBGrid1DblClick(Sender: TObject);
begin
  with cdsCompra do
  begin
    cdsCompra.Edit;
    cdsCompra.FieldByName('ACAO').Value := 'E';
    cdsCompra.Post;

    edCodPC.Text := FieldByName('COD_PRODUTO').AsString;
    edDescPC.Text := FieldByName('DESCRICAO').AsString;
    edPrecoPC.Text := FieldByName('PRECO').AsString;
    edQuantPC.Text := FieldByName('QUANTIDADE').AsString;

    if btnExcluir.Enabled = True then
      btnExcluir.Enabled := False;

    if edQuantPC.CanFocus then
      edQuantPC.SetFocus;

    edCodPC.Enabled := False;
    edQuantPC.Enabled := True;
  end;
end;

procedure TTCompraC.DesabilitaComponentes;
begin
  btnPesquisarC.Enabled := False;
  btnLimparC.Enabled := False;
  edNomeCC.Enabled := False;
  edCodCC.Enabled := False;
  btnPesquisaP.Enabled := False;
  btnLimparP.Enabled := False;
  edCodPC.Enabled := False;
  edDescPC.Enabled := False;
  edPrecoPC.Enabled := False;
  edQuantPC.Enabled := False;
  btnAdicionar.Enabled := False;
  btnAdicionar.Visible := False;
  btnExcluir.Enabled := False;
  btnExcluir.Visible := False;
  btnSalvar.Enabled := False;
end;

procedure TTCompraC.edCodCCKeyPress(Sender: TObject; var Key: Char);
begin
  if not CharInSet(Key, ['0'..'9', #8, #13]) then
  begin
    EnviaMensagem('Utilize apenas N?meros', 'Informa??o', mtInformation, [mbOK]);
    Key := #0;
  end
  else if (Key = #13) and not Empty(edCodCC.Text) then
  begin
    if edCodCC.Text <> '*' then
    begin
      with TDMPrincipal.qAux do
      begin
        Close;
        SQL.Clear;
        SQL.Add('SELECT COD_CLIENTE,NOME');
        SQL.Add('FROM CLIENTE');
        SQL.Add('WHERE COD_CLIENTE = ' + edCodCC.Text);
        Open;
        if not IsEmpty then
        begin
          edCodCC.Text := FieldByName('COD_CLIENTE').AsString;
          edNomeCC.Text := FieldByName('NOME').AsString;
          btnLimparC.Enabled := True;

          if edCodPC.CanFocus then
            edCodPC.SetFocus;
        end
        else
        begin
          EnviaMensagem('N?o h? registros no sistema, verifique a informa??o digitada!', 'Informa??o', mtInformation, [mbOK]);
          btnLimparC.Click;
          Exit;
        end;
      end;
    end
    else
    begin
      EnviaMensagem('N?o ? poss?vel pesquisar por *.' + #13 + 'Utilize apenas n?meros!', 'Informa??o', mtInformation, [mbOK]);
      btnLimparC.Click;
      Exit;
    end;
  end;
end;

procedure TTCompraC.edCodPCKeyPress(Sender: TObject; var Key: Char);
begin
  if not CharInSet(Key, ['0'..'9', #8, #13]) then
  begin
    EnviaMensagem('S? ? permitido pesquisa por n?meros', 'Informa??o', mtInformation, [mbOK]);
    Key := #0;
  end
  else if (Key = #13) and not Empty(edCodCC.Text) then
  begin
    if edCodPC.Text <> '*' then
    begin
      if Empty(edCodCC.Text) and (Empty(edNomeCC.Text)) then
      begin
        EnviaMensagem('? preciso selecionar um Cliente antes de adicionar um produto!', 'Informa??o', mtInformation, [mbOK]);
        btnLimparP.Click;
        if edCodCC.CanFocus then
          edCodCC.SetFocus;
        Exit;
      end
      else
      begin
        with TDMPrincipal.qAux do
        begin
          Close;
          SQL.Clear;
          SQL.Add('SELECT COD_PRODUTO,DESCRICAO,PRECO');
          SQL.Add('FROM PRODUTO');
          SQL.Add('WHERE COD_PRODUTO = ' + edCodPC.Text);
          Open;

          if not IsEmpty then
          begin
            edCodPC.Text := FieldByName('COD_PRODUTO').AsString;
            edDescPC.Text := FieldByName('DESCRICAO').AsString;
            edPrecoPC.Text := FieldByName('PRECO').AsString;
            btnLimparP.Enabled := True;

            if edQuantPC.CanFocus then
              edQuantPC.SetFocus;
          end
          else
          begin
            EnviaMensagem('N?o h? registros no sistema, verifique a informa??o digitada!', 'Informa??o', mtInformation, [mbOK]);
            btnLimparP.Click;
            Exit;
          end;
        end;
      end;
    end
    else
    begin
      EnviaMensagem('N?o ? poss?vel pesquisar por *.' + #13 + 'Utilize apenas n?meros!', 'Informa??o', mtInformation, [mbOK]);
      btnLimparP.Click;
      Exit;
    end;
  end;
end;

procedure TTCompraC.edQuantPCChange(Sender: TObject);
begin
  if (edCodPC.Text <> '') and (edDescPC.Text <> '') then
  begin
    if edQuantPC.Text <> '' then
      btnAdicionar.Enabled := True;
  end
  else
    btnAdicionar.Enabled := False;
end;

procedure TTCompraC.edQuantPCClick(Sender: TObject);
begin
  if Empty(edCodPC.Text) and Empty(edDescPC.Text) then
  begin
    EnviaMensagem('? preciso selecionar um produto antes de inserir quantidade!', 'Informa??o', mtInformation, [mbOK]);
    if edCodPC.CanFocus then
      edCodPC.SetFocus;
    Exit;
  end;
end;

procedure TTCompraC.edQuantPCKeyPress(Sender: TObject; var Key: Char);
begin
  if Empty(edCodPC.Text) and Empty(edDescPC.Text) then
  begin
    EnviaMensagem('? preciso selecionar um produto antes de inserir quantidade!', 'Informa??o', mtInformation, [mbOK]);
    edQuantPC.Clear;
    if edCodPC.CanFocus then
      edCodPC.SetFocus;
    Exit;
  end
  else
  begin
    if (Key = #13) then
    begin
      if (edQuantPC.Text > '0') and (edQuantPC.Text <> '') then
      begin
        if (btnAdicionar.Enabled) and (btnAdicionar.Visible) then
          btnAdicionar.Click;
      end
      else
      begin
        EnviaMensagem('A quantidade m?nima deve ser 1', 'Informa??o', mtInformation, [mbOK]);
        edQuantPC.Clear;
        btnAdicionar.Enabled := False;
        Exit;
      end;
    end;
  end;
end;

procedure TTCompraC.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  FreeAndNil(cdsCompra);
end;

procedure TTCompraC.FormCreate(Sender: TObject);
begin
  cdsCompra.CreateDataSet;

  deCompra.Date := Date();

  DBGrid1.ControlStyle := DBGrid1.ControlStyle + [csClickEvents];
  TTCompraC(DBGrid1).OnDblClick := DBGrid1DblClick;

  vetProdutosExcluidos := TStringList.Create;
end;

procedure TTCompraC.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  case Key of
    VK_ESCAPE:
      begin
        if (btnCancelar.Visible) and (btnCancelar.Enabled) then
          btnCancelar.Click;
      end;
    VK_F3:
      begin
        if (btnPesquisarC.Visible) and (btnPesquisarC.Enabled) then
          btnPesquisarC.Click;
      end;
    VK_F6:
      begin
        if (btnLimparC.Visible) and (btnLimparC.Enabled) then
          btnLimparC.Click;
      end;
    VK_F4:
      begin
        if (btnPesquisaP.Visible) and (btnPesquisaP.Enabled) then
          btnPesquisaP.Click;
      end;
    VK_F7:
      begin
        if (btnLimparP.Visible) and (btnLimparP.Enabled) then
          btnLimparP.Click;
      end;
    VK_F2:
      begin
        if (btnAdicionar.Visible) and (btnAdicionar.Enabled) then
          btnAdicionar.Click;
      end;
    VK_F8:
      begin
        if (btnExcluir.Visible) and (btnExcluir.Enabled) then
          btnExcluir.Click;
      end;
    VK_F5:
      begin
        if (btnSalvar.Visible) and (btnSalvar.Enabled) then
          btnSalvar.Click;
      end;
  end;
end;

procedure TTCompraC.FormShow(Sender: TObject);
begin
  if edCodCC.CanFocus then
    edCodCC.SetFocus;
end;

end.

