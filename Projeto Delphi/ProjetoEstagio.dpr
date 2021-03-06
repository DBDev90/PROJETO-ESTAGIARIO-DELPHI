program ProjetoEstagio;

uses
  Forms,
  MenuPrincipal in 'MenuPrincipal.pas' {TMenuPrincipal},
  DMPrincipal in 'DMPrincipal.pas' {TDMPrincipal: TDataModule},
  Cliente in 'Cliente.pas' {TCliente},
  ClienteC in 'ClienteC.pas' {TClienteC},
  Produto in 'Produto.pas' {TProduto},
  ProdutoC in 'ProdutoC.pas' {TProdutoC},
  Funcoes in 'Funcoes.pas',
  Funcoesdb in 'Funcoesdb.pas',
  Compra in 'Compra.pas' {TCompra},
  CompraC in 'CompraC.pas' {TCompraC};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TTDMPrincipal, TDMPrincipal);
  Application.CreateForm(TTMenuPrincipal, TMenuPrincipal);
  Application.Run;
end.
