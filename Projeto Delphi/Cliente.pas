unit Cliente;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, DBGrids, ExtCtrls, DBCtrls, StdCtrls, DB, ADODB, Buttons;

type
  TTCliente = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    DBGrid1: TDBGrid;
    Label1: TLabel;
    lblNumRegistro: TLabel;
    rgFiltroCliente: TRadioGroup;
    lblPesquisa: TLabel;
    edPesquisaCliente: TEdit;
    DBNavigator1: TDBNavigator;
    qCliente: TADOQuery;
    dsCliente: TDataSource;
    btnLimpar: TBitBtn;
    btnFechar: TBitBtn;
    btnExcluir: TBitBtn;
    btnEditar: TBitBtn;
    btnConsultar: TBitBtn;
    btnInserir: TBitBtn;
    btnTransferir: TBitBtn;
    procedure btnConsultarClick(Sender: TObject);
    procedure btnInserirClick(Sender: TObject);
    procedure btnEditarClick(Sender: TObject);
    procedure btnLimparClick(Sender: TObject);
    procedure DBGrid1TitleClick(Column: TColumn);
    procedure edPesquisaClienteKeyPress(Sender: TObject; var Key: Char);
    procedure btnFecharClick(Sender: TObject);
    procedure btnExcluirClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure rgFiltroClienteClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure DBGrid1DrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
    procedure qClienteATIVOGetText(Sender: TField; var Text: string;
      DisplayText: Boolean);
    procedure btnTransferirClick(Sender: TObject);
  private
    { Private declarations }
    ColunaPesquisa,TranCliente: string;
    CanClose: Boolean;
  public
    function TransferirCliente(TAcao:string):string;
    { Public declarations }
    procedure ChamaTela;
  end;

var
  TCliente: TTCliente;

implementation

uses
  ClienteC, Funcoes, Funcoesdb, DMPrincipal;

{$R *.dfm}

{ TTCliente }

procedure TTCliente.btnConsultarClick(Sender: TObject);
begin
  if qCliente.IsEmpty then
  begin
    EnviaMensagem('? preciso selecionar um cliente para Consultar', 'Informa??o', mtInformation, [mbOK]);
    if edPesquisaCliente.CanFocus then
      edPesquisaCliente.SetFocus;
    Exit;
  end
  else
  begin
    TClienteC.ChamaTela(qCliente.FieldByName('COD_CLIENTE').AsString, 'C');
  end;
end;

procedure TTCliente.btnEditarClick(Sender: TObject);
begin
  if qCliente.IsEmpty then
  begin
    EnviaMensagem('? preciso selecionar um cliente para Editar', '', mtInformation, [mbOK]);
    if edPesquisaCliente.CanFocus then
      edPesquisaCliente.SetFocus;
    Exit;
  end
  else
  begin
    TClienteC.ChamaTela(qCliente.FieldByName('COD_CLIENTE').AsString, 'E');
    qCliente.Requery;
  end;
end;

procedure TTCliente.btnExcluirClick(Sender: TObject);
begin
  CanClose := False;

  if qCliente.IsEmpty then
  begin
    EnviaMensagem('? preciso selecionar um cliente para Excluir', 'Informa??o', mtInformation, [mbOK]);
    if edPesquisaCliente.CanFocus then
      edPesquisaCliente.SetFocus;
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
        sql.Clear;
        SQL.Add('DELETE CLIENTE');
        SQL.Add('WHERE COD_CLIENTE = ' + qCliente.FieldByName('COD_CLIENTE').AsString);
        ExecSQL;

        EnviaMensagem('O cliente foi exclu?do!', 'Informa??o', mtInformation, [mbOK]);
      end;
      qCliente.Requery;

      lblNumRegistro.Caption := IntToStr(qCliente.RecordCount);
    end;
  end;
end;

procedure TTCliente.btnFecharClick(Sender: TObject);
begin
  TCliente.Close;
end;

procedure TTCliente.btnInserirClick(Sender: TObject);
var
  RCodigo: string;
begin
  RCodigo := TClienteC.ChamaTela('', 'I');
  if RCodigo > '0' then
  begin
    with qCliente do
    begin
      Close;
      SQL.Clear;
      SQL.Add('SELECT * FROM CLIENTE');
      SQL.Add('WHERE COD_CLIENTE = ' + RCodigo);
      Open;
    end;
  end;
end;

procedure TTCliente.btnLimparClick(Sender: TObject);
begin
  qCliente.Close;
  edPesquisaCliente.Clear;
  lblNumRegistro.Caption := '0';
  rgFiltroCliente.ItemIndex := 0;
  if edPesquisaCliente.CanFocus then
    edPesquisaCliente.SetFocus;
end;

procedure TTCliente.btnTransferirClick(Sender: TObject);
begin
  if qCliente.IsEmpty then
  begin
    EnviaMensagem('? preciso selecionar um cliente para Transferir', '', mtInformation, [mbOK]);
    Exit;
  end
  else
    TranCliente := qCliente.FieldByName('COD_CLIENTE').AsString;
    TCliente.Close;
end;

procedure TTCliente.ChamaTela;
begin
  TCliente := TTCliente.Create(Application);
  with TCliente do
  begin
    ShowModal;
  end;
  FreeAndNil(TCliente);
end;

procedure TTCliente.DBGrid1DrawColumnCell(Sender: TObject;
  const Rect: TRect; DataCol: Integer; Column: TColumn;
  State: TGridDrawState);

begin
  qCliente.Open;
  if qCliente.FieldByName('ATIVO').Value = 0 then
  begin
    DBGrid1.Canvas.Font.Color := clRed;
    DBGrid1.Canvas.FillRect(Rect);
    DBGrid1.DefaultDrawColumnCell(Rect,DataCol,Column,State);
  end;
end;

procedure TTCliente.DBGrid1TitleClick(Column: TColumn);
var
  I: Integer;
begin
  ColunaPesquisa := Column.FieldName;
  if ColunaPesquisa <> 'ATIVO' then
  begin
    lblPesquisa.Caption := 'Digite um ' + Column.Title.Caption + ' ou * para todos e Tecle Enter';
    btnLimpar.Click;

    for I := 0 to DBGrid1.Columns.Count - 1 do
    begin
      if DBGrid1.Columns[I].FieldName = ColunaPesquisa then
        DBGrid1.Columns[I].Title.Font.Color := clRed
      else
        DBGrid1.Columns[I].Title.Font.Color := clBlack;
    end;
  end;
end;

procedure TTCliente.edPesquisaClienteKeyPress(Sender: TObject; var Key: Char);

  function Filtro: string;
  begin
    if TCliente.Tag = 0 then
    begin
      TCliente.Tag := 1;
      Result := ' WHERE ';
    end
    else
      Result := ' AND ';
  end;

begin
  TCliente.Tag := 0;
  if (ColunaPesquisa = 'COD_CLIENTE') and not CharInSet(Key,['0'..'9', #8, #13, #42]) then
  begin
    EnviaMensagem('Utilize apenas N?meros ou * para pesquisar por C?digo do Cliente', 'Informa??o', mtInformation, [mbOK]);
    Key := #0;
  end
  else if (ColunaPesquisa = 'NOME') and CharInSet(Key,['0'..'9',#33..#41,#43..#47,#58..#64,#91..#93,#95,#123..#125]) then
  begin
    EnviaMensagem('Utilize apenas Letras ou * para pesquisar por Nome', 'Informa??o', mtInformation, [mbOK]);
    Key := #0;
  end
  else if (ColunaPesquisa = 'RG') and not CharInSet(Key,['0'..'9', #8, #13, #42]) then
  begin
    EnviaMensagem('Utilize apenas N?meros ou * para pesquisar por RG', 'Informa??o', mtInformation, [mbOK]);
    Key := #0;
  end
  else if (ColunaPesquisa = '') and not CharInSet(Key,[#13,#42]) then
  begin
    EnviaMensagem('Utilize * ou escolha uma coluna da tabela.', 'Informa??o', mtInformation, [mbOK]);
    Key := #0;
  end
  else if (Key = #13) and not Empty(edPesquisaCliente.Text) then
  begin
    with qCliente do
    begin
      Close;
      SQL.Clear;
      SQL.Add('SELECT COD_CLIENTE,NOME,RG,ATIVO');
      SQL.Add('FROM CLIENTE');
      if edPesquisaCliente.Text <> '*' then
      begin
        if ColunaPesquisa = 'COD_CLIENTE' then
          SQL.Add(Filtro + ' COD_CLIENTE = ' + StringTextSql(edPesquisaCliente.Text));

        if ColunaPesquisa = 'NOME' then
          SQL.Add(Filtro + ' NOME LIKE ''%' + edPesquisaCliente.Text + '%''');

        if ColunaPesquisa = 'RG' then
          SQL.Add(Filtro + ' RG LIKE ''%' + edPesquisaCliente.Text + '%''');
      end;
      case rgFiltroCliente.ItemIndex of
        0:
          SQL.Add(Filtro + ' ATIVO = 1');
        1:
          SQL.Add(Filtro + ' ATIVO = 0');
      end;
      Open;
      FieldByName('ATIVO').OnGetText := qClienteATIVOGetText;
      if qCliente.RecordCount = 0 then
        EnviaMensagem('N?o h? registros no sistema, verifique a informa??o digitada!', 'Informa??o', mtInformation, [mbOK]);
      
      lblNumRegistro.Caption := IntToStr(qCliente.RecordCount);

      edPesquisaCliente.Clear;
    end;
  end;
end;

procedure TTCliente.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
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
    VK_F8:
      begin
        if (btnExcluir.Visible) and (btnExcluir.Enabled) then
          btnExcluir.Click;
      end;
    VK_F6:
      begin
        if (btnLimpar.Visible) and (btnLimpar.Enabled) then
          btnLimpar.Click;
      end;
    VK_F12:
      begin
        if (btnTransferir.Visible) and (btnTransferir.Enabled) then
          btnTransferir.Click;
      end;
  end;
end;

procedure TTCliente.FormShow(Sender: TObject);
begin
  ColunaPesquisa := '';
  if edPesquisaCliente.CanFocus then
    edPesquisaCliente.SetFocus;

end;

procedure TTCliente.qClienteATIVOGetText(Sender: TField; var Text: string;
  DisplayText: Boolean);
begin
  if qCliente.FieldByName('ATIVO').AsBoolean then
    Text := 'ATIVO'
  else
    Text := 'INATIVO';
end;

procedure TTCliente.rgFiltroClienteClick(Sender: TObject);
begin
  qCliente.Close;
  edPesquisaCliente.Clear;
  lblNumRegistro.Caption := '0';
  if edPesquisaCliente.CanFocus then
    edPesquisaCliente.SetFocus;
end;

function TTCliente.TransferirCliente(TAcao: string): string;
begin
 TCliente := TTCliente.Create(Application);
 with TCliente do
 begin
    if TAcao = 'T' then
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

   Result := TranCliente;

   FreeAndNil(TCliente);
 end;
end;

end.

