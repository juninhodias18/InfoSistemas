unit Funcao;

interface
uses FMX.Forms, System.MaskUtils, System.JSON;

procedure LimparForm(pForm: TForm);
function  Se(pCondicao, pResultT, pResultF: Variant): Variant; overload;
function  CalculaCnpjCpf(pNumero : String; pMensagem : boolean = False) : Boolean;
function  SoNum(pValor : string) : string;
function  FormatarCPF_CNPJ(CPF_CNPJ: string = ''): string;
function  FormatarTelefone(pTelefone : String):String;
function  FormatarCEP(pCep : String):String;
function  CalculaEmail(const Value: string): Boolean;

implementation

uses
  FMX.Edit, FMX.ComboEdit, System.Variants, System.SysUtils, FMX.Dialogs,
  System.UITypes;

procedure LimparForm(pForm: TForm);
var i: integer;
begin
        for i := 0 to pForm.ComponentCount - 1 do
        begin
                if pForm.Components[i] is TEdit then
                        TEdit(pForm.Components[i]).Text := '';
                if pForm.Components[i] is TComboEdit then
                        TComboEdit(pForm.Components[i]).ItemIndex := -1;
        end;
end;

function  Se(pCondicao, pResultT, pResultF: Variant): Variant; overload;
begin
        if pCondicao then Result := pResultT
        else Result := pResultF
end;

function CalculaCnpjCpf(pNumero : String; pMensagem : boolean = False) : Boolean;
Var
        i,d,b,
        Digito : Byte;
        Soma : Integer;
        CNPJ : Boolean;
        DgPass,
        DgCalc : String;
begin
        Result := False;
        pNumero := SoNum(pNumero);
        Case Length(pNumero) of
                11: CNPJ := False;
                14: CNPJ := True;
                else Exit;
        end;
        DgCalc := '';
        DgPass := Copy(pNumero,Length(pNumero)-1,2);
        pNumero := Copy(pNumero,1,Length(pNumero)-2);
        For d := 1 to 2 do begin
                B := Se(D=1,2,3); // BYTE
                SOMA := Se(D=1,0,STRTOINTDEF(DGCALC,0)*2);
                for i := Length(pNumero) downto 1 do begin
                        Soma := Soma + (Ord(pNumero[I])-Ord('0'))*b;
                        Inc(b);
                        If (b > 9) And CNPJ Then b := 2;
                end;
                Digito := 11 - Soma mod 11;
                If Digito >= 10 then Digito := 0;
                DgCalc := DgCalc + Chr(Digito + Ord('0'));
        end;
        Result := DgCalc = DgPass;

        if (not Result) AND (pMensagem) then
                MessageDlg('Atençao!' +#13+
                           'CPF/CNPJ inválido',TMsgDlgType.mtInformation,[TMsgDlgBtn.mbok],0);
end;

function SoNum(pValor : string) : string;
var I: Integer;
begin
  Result := '';
  For I := 1 To Length(pValor) do
   If pValor[I] In ['1','2','3','4','5','6','7','8','9','0'] Then
     Result := Result + pValor[I];
end;

function FormatarCPF_CNPJ(CPF_CNPJ: string = ''): string;
var I: integer;
begin
        Result := SoNum(CPF_CNPJ);
        if Length(Result) = 14 then begin
                Result := Copy(Result, 1, 2) + '.' +
                Copy(Result, 3, 3) + '.' +
                Copy(Result, 6, 3) + '/' +
                Copy(Result, 9, 4) + '-' +
                Copy(Result,13, 2);
        end else if Length(Result) = 11 then begin
                Result := Copy(Result, 1, 3) + '.' +
                Copy(Result, 4, 3) + '.' +
                Copy(Result, 7, 3) + '-' +
                Copy(Result,10, 2);
        end;
        if not CalculaCnpjCpf(Result, True) then Result := '';
end;

Function FormatarTelefone(pTelefone:String):String;
begin
        pTelefone := SoNum(pTelefone);
        if Length(SoNum(pTelefone)) = 10 then
                Result:=FormatmaskText('\(00\)0000\-0000;0;',pTelefone)
        else
                Result:=FormatmaskText('\(00\)00000\-0000;0;',pTelefone);
end;

function  FormatarCEP(pCep : String):String;
begin
        pCep := SoNum(pCep);
        if Length(SoNum(pCep)) = 8 then
                Result:=FormatmaskText('00000-000;0;',pCep)
end;

function CalculaEmail(const Value: string): Boolean;
        function CaracteresValidos(const s: string): Boolean;
        var i: Integer;
        begin
                Result := False;
                for i := 1 to Length(s) do
                        if not(s[i] in ['a' .. 'z', 'A' .. 'Z', '0' .. '9', '_', '-', '.']) then
                                Exit;
                Result := true;
        end;
var
  i: Integer;
  NamePart, ServerPart: string;
begin
        Result := False;
        i := Pos('@', Value);
        if i = 0 then Exit;
        NamePart := Copy(Value, 1, i - 1);
        ServerPart := Copy(Value, i + 1, Length(Value));
        if (Length(NamePart) = 0) or ((Length(ServerPart) < 5)) then Exit;
        i := Pos('.', ServerPart);
        if (i = 0) or (i > (Length(ServerPart) - 2)) then Exit;
        Result := CaracteresValidos(NamePart) and CaracteresValidos(ServerPart);
end;

end.
