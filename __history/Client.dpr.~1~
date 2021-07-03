program Client;

uses
  System.StartUpCopy,
  FMX.Forms,
  View.CadCliente in 'View.CadCliente.pas' {frmCadCliente},
  FunctionRectangles in 'FunctionRectangles.pas',
  FuncoesHelpers in 'FuncoesHelpers.pas',
  Funcao in 'Funcao.pas',
  DataModulo in 'DataModulo.pas' {DM: TDataModule},
  FunctionEdits in 'FunctionEdits.pas',
  uClientes in 'uClientes.pas',
  Loading in 'Loading.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TDM, DM);
  Application.CreateForm(TfrmCadCliente, frmCadCliente);
  Application.Run;
end.
