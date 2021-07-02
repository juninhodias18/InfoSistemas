unit uClientes;

interface
        type TClientes = class
                private
                        nome     : string;
                        ident    : string;
                        cpf      : string;
                        telefone : string;
                        email    : string;

                        cep           : string;
                        logradouro    : string;
                        logradouroNro : string;
                        bairro        : string;
                        complemento   : string;
                        pais          : string;
                        uf            : string;
                        cidade        : string;
                public
                        constructor CriaObjeto;

                        // DADOS PESSOAIS
                        procedure SetNome(pNome : string);
                        procedure SetIdent(pIdent : string);
                        procedure SetCpf(pCpf: string);
                        procedure SetTelefone(pTelefone : string);
                        procedure SetEmail(pEmail : string);

                        procedure SetCep(pCep : string);
                        procedure SetLogradouro(pLogradouro : string);
                        procedure SetLogradouroNro(pLogradourpNro : string);
                        procedure SetBairro(pBairro : string);
                        procedure SetComplemento(pComplemento : string);
                        procedure SetPais(pPais : string);
                        procedure SetUf(pUf : string);
                        procedure SetCidade(pCidade : string);

                        // ENDEREÇO
                        function  GetNome : string;
                        function  GetIdent : string;
                        function  GetCpf : string;
                        function  GetTelefone : string;
                        function  GetEmail : string;

                        function  GetCep : string;
                        function  GetLogradouro : string;
                        function  GetLogradouroNro : string;
                        function  GetBairro : string;
                        function  GetComplemento : string;
                        function  GetPais : string;
                        function  GetUf : string;
                        function  GetCidade : string;

                        destructor DestroiObjeto;
        end;


implementation

{ Clientes }

constructor TClientes.CriaObjeto;
begin
        nome     := '';
        ident    := '';
        cpf      := '';
        telefone := '';
        email    := '';

        cep           := '';
        logradouro    := '';
        logradouroNro := '';
        bairro        := '';
        complemento   := '';
        pais          := '';
        uf            := '';
        cidade        := '';
end;

destructor TClientes.DestroiObjeto;
begin

end;

function TClientes.GetBairro: string;
begin
        Result := bairro
end;

function TClientes.GetCep: string;
begin
        Result := cep
end;

function TClientes.GetCidade: string;
begin
        Result := cidade
end;

function TClientes.GetComplemento: string;
begin
        Result := complemento
end;

function TClientes.GetCpf: string;
begin
        Result := cpf
end;

function TClientes.GetEmail: string;
begin
        Result := email
end;

function TClientes.GetIdent: string;
begin
        Result := ident
end;

function TClientes.GetLogradouro: string;
begin
        Result := logradouro
end;

function TClientes.GetLogradouroNro: string;
begin
        Result := logradouroNro
end;

function TClientes.GetNome: string;
begin
        Result := nome
end;

function TClientes.GetPais: string;
begin
        Result := pais
end;

function TClientes.GetTelefone: string;
begin
        Result := telefone
end;

function TClientes.GetUf: string;
begin
        Result := uf
end;

procedure TClientes.SetBairro(pBairro: string);
begin
        bairro := pBairro
end;

procedure TClientes.SetCep(pCep: string);
begin
        cep := pCep
end;

procedure TClientes.SetCidade(pCidade: string);
begin
        cidade := pCidade
end;

procedure TClientes.SetComplemento(pComplemento: string);
begin
        complemento := pComplemento
end;

procedure TClientes.SetCpf(pCpf: string);
begin
        cpf := pCpf
end;

procedure TClientes.SetEmail(pEmail: string);
begin
        email := pEmail
end;

procedure TClientes.SetIdent(pIdent: string);
begin
        ident := pIdent
end;

procedure TClientes.SetLogradouroNro(pLogradourpNro: string);
begin
        logradouroNro := pLogradourpNro
end;

procedure TClientes.SetLogradouro(pLogradouro: string);
begin
        logradouro := pLogradouro
end;

procedure TClientes.SetNome(pNome : string);
begin
        nome := pNome
end;

procedure TClientes.SetPais(pPais: string);
begin
        pais := pPais
end;

procedure TClientes.SetTelefone(pTelefone: string);
begin
        telefone := pTelefone
end;

procedure TClientes.SetUf(pUf: string);
begin
        uf := pUf
end;

end.
