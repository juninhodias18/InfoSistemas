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
  IdIOHandlerSocket, IdIOHandlerStack, IdSSL, IdSSLOpenSSL, IdAttachmentFile, IdText;

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
  private
        cadCliente : TClientes;
    { Private declarations }
        procedure SetForm;
        function  CamposObrigatorios : boolean;
        procedure BuscaCEP(pCEP : string);
        procedure CarregaCEP(pJSON : string);
        function  EnviarEmail(const AAssunto, ADestino, AAnexo: String; ACorpo: TStrings): Boolean;
  public
    { Public declarations }
  end;

var
  frmCadCliente: TfrmCadCliente;

implementation

{$R *.fmx}

uses FuncoesHelpers, Funcao, DataModulo, FunctionEdits, Loading;

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
begin
        if not CamposObrigatorios then Abort;

                //TLoading.Show(Form1, 'Aguarde... Estamos trabalhando na sua requisi��o. Isso pode demorar alguns segundos...');
        TLoading.Show(frmCadCliente, 'Aguarde' + #13 + 'Salvando...');


        TThread.CreateAnonymousThread(procedure
        begin
                sleep(3000);
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

                TThread.Synchronize(nil, procedure
                begin
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


        TThread.CreateAnonymousThread(procedure
        begin
                mCep := 'http://viacep.com.br/ws/'+SoNum(pCEP)+'/json';
                RESTClient1.BaseURL := mCep;
                RESTRequest1.Execute;
                CarregaCEP(RESTRequest1.Response.JSONText);

                TThread.Synchronize(nil, procedure
                begin
                        TLoading.Hide;
                        edtLogradouro.SetFocus;
                        edtLogradouro.SelectAll;
                end);

        end).Start;
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
                MessageDlg('Aten�ao!' +#13+
                           'Campos destacados em vermelho s�o obrigat�rios',TMsgDlgType.mtInformation,[TMsgDlgBtn.mbok],0);

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
                MessageDlg('Aten�ao!' +#13+
                           'CEP inv�lido.',TMsgDlgType.mtInformation,[TMsgDlgBtn.mbok],0);
        end;
end;

procedure TfrmCadCliente.edtCepTyping(Sender: TObject);
begin
        BuscaCEP(edtCep.Text);
end;

function TfrmCadCliente.EnviarEmail(const AAssunto, ADestino, AAnexo: String; ACorpo: TStrings): Boolean;
var
  IniFile              : TIniFile;
  sFrom                : String;
  sBccList             : String;
  sHost                : String;
  iPort                : Integer;
  sUserName            : String;
  sPassword            : String;

  idMsg                : TIdMessage;
  IdText               : TIdText;
  idSMTP               : TIdSMTP;
  IdSSLIOHandlerSocket : TIdSSLIOHandlerSocketOpenSSL;
begin
  try
    try
      //Cria��o e leitura do arquivo INI com as configura��es
      IniFile                          := TIniFile.Create(ExtractFilePath(ParamStr(0)) + 'Config.ini');
      sFrom                            := IniFile.ReadString('Email' , 'From'     , sFrom);
      sBccList                         := IniFile.ReadString('Email' , 'BccList'  , sBccList);
      sHost                            := IniFile.ReadString('Email' , 'Host'     , sHost);
      iPort                            := IniFile.ReadInteger('Email', 'Port'     , iPort);
      sUserName                        := IniFile.ReadString('Email' , 'UserName' , sUserName);
      sPassword                        := IniFile.ReadString('Email' , 'Password' , sPassword);

      //Configura os par�metros necess�rios para SSL
      IdSSLIOHandlerSocket                   := TIdSSLIOHandlerSocketOpenSSL.Create(Self);
      IdSSLIOHandlerSocket.SSLOptions.Method := sslvSSLv23;
      IdSSLIOHandlerSocket.SSLOptions.Mode  := sslmClient;

      //Vari�vel referente a mensagem
      idMsg                            := TIdMessage.Create(Self);
      idMsg.CharSet                    := 'utf-8';
      idMsg.Encoding                   := meMIME;
      idMsg.From.Name                  := 'MEU ASSUNTO';
      idMsg.From.Address               := sFrom;
      idMsg.Priority                   := mpNormal;
      idMsg.Subject                    := AAssunto;

      //Add Destinat�rio(s)
      idMsg.Recipients.Add;
      idMsg.Recipients.EMailAddresses := ADestino;
      idMsg.CCList.EMailAddresses      := 'PARA@DOMINIO.COM.BR';
      idMsg.BccList.EMailAddresses    := sBccList;
      idMsg.BccList.EMailAddresses    := 'PARA@DOMINIO.COM.BR'; //C�pia Oculta

      //Vari�vel do texto
      idText := TIdText.Create(idMsg.MessageParts);
      idText.Body.Add(ACorpo.Text);
      idText.ContentType := 'text/html; text/plain; charset=iso-8859-1';

      //Prepara o Servidor
      IdSMTP                           := TIdSMTP.Create(Self);
      IdSMTP.IOHandler                 := IdSSLIOHandlerSocket;
      IdSMTP.UseTLS                    := utUseImplicitTLS;
      IdSMTP.AuthType                  := satDefault;
      IdSMTP.Host                      := sHost;
      IdSMTP.AuthType                  := satDefault;
      IdSMTP.Port                      := iPort;
      IdSMTP.Username                  := sUserName;
      IdSMTP.Password                  := sPassword;

      //Conecta e Autentica
      IdSMTP.Connect;
      IdSMTP.Authenticate;

      if AAnexo &lt;&gt; EmptyStr then
        if FileExists(AAnexo) then
          TIdAttachmentFile.Create(idMsg.MessageParts, AAnexo);

      //Se a conex�o foi bem sucedida, envia a mensagem
      if IdSMTP.Connected then
      begin
        try
          IdSMTP.Send(idMsg);
        except on E:Exception do
          begin
            ShowMessage('Erro ao tentar enviar: ' + E.Message);
          end;
        end;
      end;

      //Depois de tudo pronto, desconecta do servidor SMTP
      if IdSMTP.Connected then
        IdSMTP.Disconnect;

      Result := True;
    finally
      IniFile.Free;

      UnLoadOpenSSLLibrary;

      FreeAndNil(idMsg);
      FreeAndNil(IdSSLIOHandlerSocket);
      FreeAndNil(idSMTP);
    end;
  except on e:Exception do
    begin
      Result := False;
    end;
  end;
end;

procedure TfrmCadCliente.FormClose(Sender: TObject; var Action: TCloseAction);
begin
        if MessageDlg('Aten�ao!' +#13+ 'Deseja sair do sistema?',
                TMsgDlgType.mtWarning,[TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo],0) = mrNo then
                        Action := TCloseAction.caNone;
end;

procedure TfrmCadCliente.FormCreate(Sender: TObject);
begin
        SetForm;
end;

procedure TfrmCadCliente.btnRecuperarClick(Sender: TObject);
begin
        if cadCliente = nil then Abort;

                 //TLoading.Show(Form1, 'Aguarde... Estamos trabalhando na sua requisi��o. Isso pode demorar alguns segundos...');
        TLoading.Show(frmCadCliente, 'Aguarde' + #13 + 'Carregando suas informa��es...');


        TThread.CreateAnonymousThread(procedure
        begin
                sleep(3000);
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

                TThread.Synchronize(nil, procedure
                begin
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

end.
