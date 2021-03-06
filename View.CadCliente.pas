unit View.CadCliente;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.Layouts, FMX.ComboEdit, FMX.StdCtrls, FMX.Edit, FMX.Controls.Presentation,
  FunctionRectangles, uClientes, REST.Types, REST.Client, Data.Bind.Components,
  Data.Bind.ObjectScope, System.JSON, IniFiles, IdComponent,
  IdTCPConnection, IdTCPClient, IdHTTP, IdBaseComponent, IdMessage,
  IdExplicitTLSClientServerBase, IdMessageClient, IdSMTPBase, IdSMTP, IdIOHandler,
  IdIOHandlerSocket, IdIOHandlerStack, IdSSL, IdSSLOpenSSL, IdAttachmentFile, IdText,
  FMX.Memo.Types, FMX.ScrollBox, FMX.Memo, XMLDoc, XMLIntf;

type
  TfrmCadCliente = class(TForm)
    gbDadosPessoais: TGroupBox;
    edtNome: TEdit;
    lbNome: TLabel;
    Label2: TLabel;
    edtIdentidade: TEdit;
    lbCpf: TLabel;
    edtCpf: TEdit;
    edtTelefone: TEdit;
    lbTelefone: TLabel;
    Label5: TLabel;
    edtEmail: TEdit;
    gbEndereco: TGroupBox;
    lbCep: TLabel;
    edtCep: TEdit;
    Label8: TLabel;
    edtLogradouroNro: TEdit;
    edtBairro: TEdit;
    lbBairro: TLabel;
    lbLogradouro: TLabel;
    edtLogradouro: TEdit;
    Label6: TLabel;
    edtComplemento: TEdit;
    lbPais: TLabel;
    lbCidade: TLabel;
    lbUF: TLabel;
    Layout1: TLayout;
    btnSalvar: TRectangle;
    Label14: TLabel;
    Image1: TImage;
    btnFechar: TRectangle;
    Label15: TLabel;
    Image2: TImage;
    btnLimpar: TRectangle;
    Label16: TLabel;
    Image3: TImage;
    edtPais: TEdit;
    edtUf: TEdit;
    edtCidade: TEdit;
    btnRecuperar: TRectangle;
    Label1: TLabel;
    Image4: TImage;
    RESTResponse1: TRESTResponse;
    RESTRequest1: TRESTRequest;
    RESTClient1: TRESTClient;
    procedure FormCreate(Sender: TObject);
    procedure btnLimparClick(Sender: TObject);
    procedure btnSalvarClick(Sender: TObject);
    procedure btnRecuperarClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnFecharClick(Sender: TObject);
    procedure edtCepTyping(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
  private
        mmCorpo : TMemo;
        cadCliente : TClientes;
    { Private declarations }
        procedure SetForm;
        function  CamposObrigatorios : boolean;
        procedure BuscaCEP(pCEP : string);
        procedure CarregaCEP(pJSON : string);
        function  EnviarEmail(const AAssunto, ADestino, AAnexo: String): Boolean;
        procedure GeraCorpoEmail;
        function  GeraXMLEmail: string;
  public
    { Public declarations }
  end;

var
  frmCadCliente: TfrmCadCliente;

implementation

{$R *.fmx}

uses Funcao, DataModulo, FunctionEdits, Loading;

{ TForm1 }

procedure TfrmCadCliente.btnFecharClick(Sender: TObject);
begin
        Close
end;

procedure TfrmCadCliente.btnLimparClick(Sender: TObject);
begin
        LimparForm(Self);
end;

procedure TfrmCadCliente.btnSalvarClick(Sender: TObject);
var mAnexo : string;
begin
        if not CamposObrigatorios then Abort;


        TLoading.Show(frmCadCliente, 'Aguarde' + #13 + 'Gerando email...');
        GeraCorpoEmail;
        TLoading.AlteraDescricao(frmCadCliente, 'Aguarde' + #13 + 'Gerando XML...');
        mAnexo := GeraXMLEmail;

        //TLoading.Show(Form1, 'Aguarde... Estamos trabalhando na sua requisi??o. Isso pode demorar alguns segundos...');
        TLoading.AlteraDescricao(frmCadCliente, 'Aguarde' + #13 + 'Salvando...');


        TThread.CreateAnonymousThread(procedure begin
                sleep(1500);
                if cadCliente = nil then cadCliente := TClientes.CriaObjeto;
                cadCliente.SetNome(edtNome.Text);
                cadCliente.SetIdent(edtIdentidade.Text);
                cadCliente.SetCpf(edtCpf.Text);
                cadCliente.SetTelefone(edtTelefone.Text);
                cadCliente.SetEmail(edtEmail.Text);

                cadCliente.SetCep(edtCep.Text);
                cadCliente.SetLogradouro(edtLogradouro.Text);
                cadCliente.SetLogradouroNro(edtLogradouroNro.Text);
                cadCliente.SetBairro(edtBairro.Text);
                cadCliente.SetComplemento(edtComplemento.Text);
                cadCliente.SetPais(edtPais.Text);
                cadCliente.SetUf(edtUf.Text);
                cadCliente.SetCidade(edtCidade.Text);

                EnviarEmail('Bem vindo!', edtEmail.Text, mAnexo);

                TThread.Synchronize(nil, procedure begin
                        TLoading.Hide;
                        LimparForm(frmCadCliente);
                end);
        end).Start;
end;

procedure TfrmCadCliente.BuscaCEP(pCEP: string);
var mCEp : string;
begin
        if Length(pCEP) <> 8  then abort;

        TLoading.Show(frmCadCliente, 'Aguarde' + #13 + 'Buscando CEP...');
        TThread.CreateAnonymousThread(procedure begin
                mCep := 'http://viacep.com.br/ws/'+SoNum(pCEP)+'/json';
                RESTClient1.BaseURL := mCep;
                RESTRequest1.Execute;
                CarregaCEP(RESTRequest1.Response.JSONText);

                TThread.Synchronize(nil, procedure begin
                        TLoading.Hide;
                        edtLogradouro.SetFocus;
                        edtLogradouro.SelectAll;
                end);
        end).Start;
end;

procedure TfrmCadCliente.Button1Click(Sender: TObject);
begin
        GeraXMLEmail;
end;

function TfrmCadCliente.CamposObrigatorios: boolean;
begin
        lbNome.TextSettings.FontColor       := Se(edtNome.Text.IsEmpty,            zColorError, zColorPadrao);
        lbCpf.TextSettings.FontColor        := Se(edtCpf.Text.IsEmpty OR
                                                  not CalculaCnpjCpf(edtCpf.Text), zColorError, zColorPadrao);
        lbTelefone.TextSettings.FontColor   := Se(edtTelefone.Text.IsEmpty,        zColorError, zColorPadrao);
        lbCep.TextSettings.FontColor        := Se(edtCep.Text.IsEmpty,             zColorError, zColorPadrao);
        lbBairro.TextSettings.FontColor     := Se(edtBairro.Text.IsEmpty,          zColorError, zColorPadrao);
        lbLogradouro.TextSettings.FontColor := Se(edtLogradouro.Text.IsEmpty,      zColorError, zColorPadrao);
        lbPais.TextSettings.FontColor       := Se(edtPais.Text.IsEmpty,            zColorError, zColorPadrao);
        lbCidade.TextSettings.FontColor     := Se(edtUf.Text.IsEmpty,              zColorError, zColorPadrao);
        lbUF.TextSettings.FontColor         := Se(edtCidade.Text.IsEmpty,          zColorError, zColorPadrao);

        Result := not ((edtNome.Text.IsEmpty)
              OR (edtCpf.Text.IsEmpty OR not CalculaCnpjCpf(edtCpf.Text))
              OR (edtTelefone.Text.IsEmpty)
              OR (edtCep.Text.IsEmpty)
              OR (edtBairro.Text.IsEmpty)
              OR (edtLogradouro.Text.IsEmpty)
              OR (edtPais.Text.IsEmpty)
              OR (edtUf.Text.IsEmpty)
              OR (edtCidade.Text.IsEmpty));

        if Not Result then
                MessageDlg('Aten?ao!' +#13+
                           'Campos destacados em vermelho s?o obrigat?rios',TMsgDlgType.mtInformation,[TMsgDlgBtn.mbok],0);
end;

procedure TfrmCadCliente.CarregaCEP(pJSON: string);
var jsonRaiz: TJSONObject;
begin
        jsonRaiz := TJSONObject.ParseJSONValue(pJson) as TJSONObject;
        try
                edtCep.Text         := jsonRaiz.GetValue<string>('cep');
                edtLogradouro.Text  := jsonRaiz.GetValue<string>('logradouro');
                edtBairro.Text      := jsonRaiz.GetValue<string>('bairro');
                edtComplemento.Text := jsonRaiz.GetValue<string>('complemento');
                edtUf.Text          := jsonRaiz.GetValue<string>('uf');
                edtCidade.Text      := jsonRaiz.GetValue<string>('localidade');
        except
                MessageDlg('Aten?ao!' +#13+
                           'CEP inv?lido.',TMsgDlgType.mtInformation,[TMsgDlgBtn.mbok],0);
        end;
end;

procedure TfrmCadCliente.edtCepTyping(Sender: TObject);
begin
        BuscaCEP(edtCep.Text);
end;

procedure TfrmCadCliente.FormClose(Sender: TObject; var Action: TCloseAction);
begin
        if MessageDlg('Aten?ao!' +#13+ 'Deseja sair do sistema?',
                TMsgDlgType.mtWarning,[TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo],0) = mrNo then
                        Action := TCloseAction.caNone
        else if mmCorpo <> nil then begin
                mmCorpo := nil;
                mmCorpo.Free;
        end;
end;

procedure TfrmCadCliente.FormCreate(Sender: TObject);
begin
        SetForm;
end;

procedure TfrmCadCliente.FormKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
begin
        case Key of
                vkEscape: btnFechar.OnClick(btnFechar);
                vkF3    : btnLimpar.OnClick(btnLimpar);
                vkF5    : btnSalvar.OnClick(btnSalvar);
                vkF10   : btnRecuperar.OnClick(btnRecuperar);
        end;

end;

procedure TfrmCadCliente.GeraCorpoEmail;
begin
        if mmCorpo = nil then
                mmCorpo := TMemo.Create(nil);

        mmCorpo.Lines.Add('         nome: ' + edtNome.Text          + '<br>');
        mmCorpo.Lines.Add('        ident: ' + edtIdentidade.Text    + '<br>');
        mmCorpo.Lines.Add('          cpf: ' + edtCpf.Text           + '<br>');
        mmCorpo.Lines.Add('     telefone: ' + edtTelefone.Text      + '<br>');
        mmCorpo.Lines.Add('        email: ' + edtEmail.Text         + '<br>');

        mmCorpo.Lines.Add('          cep: ' + edtCep.Text           + '<br>');
        mmCorpo.Lines.Add('   logradouro: ' + edtLogradouro.Text    + '<br>');
        mmCorpo.Lines.Add('logradouroNro: ' + edtLogradouroNro.Text + '<br>');
        mmCorpo.Lines.Add('       bairro: ' + edtBairro.Text        + '<br>');
        mmCorpo.Lines.Add('  complemento: ' + edtComplemento.Text   + '<br>');
        mmCorpo.Lines.Add('         pais: ' + edtPais.Text          + '<br>');
        mmCorpo.Lines.Add('           uf: ' + edtUf.Text          + '<br>');
        mmCorpo.Lines.Add('       cidade: ' + edtCidade.Text        + '<br>');
end;

function TfrmCadCliente.GeraXMLEmail : string;
var
  XMLDocument: TXMLDocument;
  NodeTabela, NodeRegistro, NodeEndereco: IXMLNode;
  I: Integer;
begin
        XMLDocument := TXMLDocument.Create(Self);
        try
                XMLDocument.Active := True;
                NodeTabela := XMLDocument.AddChild('CadatroDeClientes');

                NodeRegistro := NodeTabela.AddChild('DadosPessoais');
                NodeRegistro.ChildValues['Nome']       := edtNome.Text;
                NodeRegistro.ChildValues['Identidade'] := edtIdentidade.Text;
                NodeRegistro.ChildValues['CPF']        := edtCpf.Text;
                NodeRegistro.ChildValues['Telefone']   := edtTelefone.Text;
                NodeRegistro.ChildValues['Email']      := edtEmail.Text;

                NodeEndereco := NodeTabela.AddChild('Endereco');
                NodeEndereco.ChildValues['CEP']         := edtCep.Text;
                NodeEndereco.ChildValues['Logradouro']  := edtLogradouro.Text;
                NodeEndereco.ChildValues['Nro']          := edtLogradouroNro.Text;
                NodeEndereco.ChildValues['Bairro']      := edtBairro.Text;
                NodeEndereco.ChildValues['Complemento'] := edtComplemento.Text;
                NodeEndereco.ChildValues['Pais']        := edtPais.Text;
                NodeEndereco.ChildValues['UF']          := edtUf.Text;
                NodeEndereco.ChildValues['Cidade']      := edtCidade.Text;

                Result := Trim(edtNome.Text)+'.xml';
                XMLDocument.SaveToFile(Result);
        finally
                XMLDocument.Free;
        end;
end;

procedure TfrmCadCliente.btnRecuperarClick(Sender: TObject);
begin
        if cadCliente = nil then Abort;

        TLoading.Show(frmCadCliente, 'Aguarde' + #13 + 'Carregando suas informa??es...');
        TThread.CreateAnonymousThread(procedure begin
                sleep(1500);
                edtNome.Text       := cadCliente.GetNome;
                edtIdentidade.Text := cadCliente.GetIdent;
                edtCpf.Text        := cadCliente.GetCpf;
                edtTelefone.Text   := cadCliente.GetTelefone;
                edtEmail.Text      := cadCliente.GetEmail;

                edtCep.Text           := cadCliente.GetCep;
                edtLogradouro.Text    := cadCliente.GetLogradouro;
                edtLogradouroNro.Text := cadCliente.GetLogradouroNro;
                edtBairro.Text        := cadCliente.GetBairro;
                edtComplemento.Text   := cadCliente.GetComplemento;
                edtPais.Text          := cadCliente.GetPais;
                edtUf.Text            := cadCliente.GetUf;
                edtCidade.Text        := cadCliente.GetCidade;

                TThread.Synchronize(nil, procedure begin
                        TLoading.Hide;
                end);
        end).Start;
end;

procedure TfrmCadCliente.SetForm;
begin
        //----------------
        // BOTOES RODAPE
        //----------------
        btnSalvar.OnMouseEnter := FunctionRectangle.RecMouseEnter;
        btnSalvar.OnMouseLeave := FunctionRectangle.RecMouseLeave;

        btnLimpar.OnMouseEnter := FunctionRectangle.RecMouseEnter;
        btnLimpar.OnMouseLeave := FunctionRectangle.RecMouseLeave;

        btnFechar.OnMouseEnter := FunctionRectangle.RecMouseEnter;
        btnFechar.OnMouseLeave := FunctionRectangle.RecMouseLeave;

        btnRecuperar.OnMouseEnter := FunctionRectangle.RecMouseEnter;
        btnRecuperar.OnMouseLeave := FunctionRectangle.RecMouseLeave;

        //----------------
        // EDITS DADOS PESSOAIS
        //----------------
        edtCpf.OnExit          := FunctionEdit.EdtFormataCPFCNPJOnExit;
        edtTelefone.OnExit     := FunctionEdit.EdtFormataTelefoneOnExit;
        edtEmail.OnExit        := FunctionEdit.EdtValidaEmailOnExit;

        //----------------
        // EDITS ENDERECO
        //----------------
        edtCep.OnExit := FunctionEdit.EdtFormataCEPOnExit;
end;

function TfrmCadCliente.EnviarEmail(const AAssunto, ADestino, AAnexo: String): Boolean;
var
  sFrom                : String;
  sBccList             : String;
  sHost                : String;
  iPort                : Integer;
  sUserName            : String;
  sPassword            : String;

  idMsg                : TIdMessage;
  idText               : TIdText;
  idSMTP               : TIdSMTP;
  idSSLIOHandlerSocket : TIdSSLIOHandlerSocketOpenSSL;
begin
        try
                try
                        sFrom                            := 'marcos.junior.send@gmail.com';
                        sBccList                         := 'juninhodias16@gmail.com';
                        sHost                            := 'smtp.gmail.com';
                        iPort                            := 465;
                        sUserName                        := 'marcos.junior.send@gmail.com';
                        sPassword                        := 'mdias1997Jr';

                        IdSSLIOHandlerSocket                   := TIdSSLIOHandlerSocketOpenSSL.Create(Self);
                        IdSSLIOHandlerSocket.SSLOptions.Method := sslvSSLv23;
                        IdSSLIOHandlerSocket.SSLOptions.Mode   := sslmClient;

                        idMsg                            := TIdMessage.Create(Self);
                        idMsg.CharSet                    := 'utf-8';
                        idMsg.Encoding                   := meMIME;
                        idMsg.From.Name                  := 'Seu cadastro';
                        idMsg.From.Address               := sFrom;
                        idMsg.Priority                   := mpNormal;
                        idMsg.Subject                    := AAssunto;

                        idMsg.Recipients.Add;
                        idMsg.Recipients.EMailAddresses := ADestino;
                        idMsg.BccList.EMailAddresses    := sBccList;

                        idText := TIdText.Create(idMsg.MessageParts);
                        idText.Body.Add(mmCorpo.Text);
                        idText.ContentType := 'text/html; text/plain; charset=iso-8859-1';

                        idSMTP                           := TIdSMTP.Create(Self);
                        idSMTP.IOHandler                 := IdSSLIOHandlerSocket;
                        idSMTP.UseTLS                    := utUseImplicitTLS;
                        idSMTP.AuthType                  := satDefault;
                        idSMTP.Host                      := sHost;
                        idSMTP.AuthType                  := satDefault;
                        idSMTP.Port                      := iPort;
                        idSMTP.Username                  := sUserName;
                        idSMTP.Password                  := sPassword;

                        idSMTP.Connect;
                        idSMTP.Authenticate;

                        if (AAnexo <> EmptyStr) AND FileExists(AAnexo) then
                                TIdAttachmentFile.Create(idMsg.MessageParts, AAnexo);

                        if idSMTP.Connected then begin
                                try
                                        IdSMTP.Send(idMsg);
                                except on E:Exception do
                                    ShowMessage('Erro ao tentar enviar: ' + E.Message);
                                end;
                        end;

                        if idSMTP.Connected then idSMTP.Disconnect;

                        Result := True;
                finally
                        UnLoadOpenSSLLibrary;
                        FreeAndNil(idMsg);
                        FreeAndNil(idSSLIOHandlerSocket);
                        FreeAndNil(idSMTP);
                end;
        except on e:Exception do
                        Result := False;
        end;
end;

end.
