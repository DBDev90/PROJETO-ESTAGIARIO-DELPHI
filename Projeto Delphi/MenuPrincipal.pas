unit MenuPrincipal;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus;

type
  TTMenuPrincipal = class(TForm)
    MainMenu1: TMainMenu;
    Manuteno1: TMenuItem;
    Relatrios1: TMenuItem;
    Sair1: TMenuItem;
    Cliente1: TMenuItem;
    Produto1: TMenuItem;
    Compra1: TMenuItem;
    procedure Cliente1Click(Sender: TObject);
    procedure Produto1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Sair1Click(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure Compra1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  TMenuPrincipal: TTMenuPrincipal;

implementation

uses
  Cliente, Produto, DMPrincipal, Funcoes, Funcoesdb, Compra;

{$R *.dfm}

procedure TTMenuPrincipal.Cliente1Click(Sender: TObject);
begin
  TCliente.ChamaTela;
end;

procedure TTMenuPrincipal.Compra1Click(Sender: TObject);
begin
  TCompra.ChamaTela;
end;

procedure TTMenuPrincipal.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  TDMPrincipal.Conexao.Connected := False;
end;

procedure TTMenuPrincipal.FormCreate(Sender: TObject);
begin
  TDMPrincipal.Conexao.Connected := True;
end;

procedure TTMenuPrincipal.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of
    VK_ESCAPE:
      Close;
  end;
end;

procedure TTMenuPrincipal.Produto1Click(Sender: TObject);
begin
  TProduto.ChamaTelaP;
end;

procedure TTMenuPrincipal.Sair1Click(Sender: TObject);
begin

    Application.Terminate;

end;

end.
