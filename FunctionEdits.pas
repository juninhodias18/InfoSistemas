unit FunctionEdits;

interface

uses FMX.Objects, FMX.Forms, System.SysUtils;

        type
                TFunctionEdits = class(TForm)
        private
        public
                procedure EdtFormataTelefoneOnExit(Sender: TObject);
                procedure EdtFormataCPFCNPJOnExit(Sender: TObject);
                procedure EdtFormataCEPOnExit(Sender: TObject);
                procedure EdtValidaEmailOnExit(Sender: TObject);
        end;

var
        FunctionEdit : TFunctionEdits;

implementation

{ TFunctionEdits }

uses Funcao, FMX.Edit, FMX.Dialogs, System.UITypes;

procedure TFunctionEdits.EdtFormataCEPOnExit(Sender: TObject);
begin
        if (Length(SoNum(TEdit(Sender).Text)) = 8) then
                TEdit(Sender).Text := FormatarCEP(TEdit(Sender).Text);
end;

procedure TFunctionEdits.EdtFormataCPFCNPJOnExit(Sender: TObject);
begin
        if (Length(SoNum(TEdit(Sender).Text)) = 11) OR
           (Length(SoNum(TEdit(Sender).Text)) = 14) then
                TEdit(Sender).Text := FormatarCPF_CNPJ(TEdit(Sender).Text);
end;

procedure TFunctionEdits.EdtFormataTelefoneOnExit(Sender: TObject);
begin
        if (Length(SoNum(TEdit(Sender).Text)) = 10) OR
           (Length(SoNum(TEdit(Sender).Text)) = 11) then
                TEdit(Sender).Text := FormatarTelefone(TEdit(Sender).Text);
end;

procedure TFunctionEdits.EdtValidaEmailOnExit(Sender: TObject);
begin
        if (not TEdit(Sender).Text.IsEmpty) AND (not CalculaEmail(TEdit(Sender).Text)) then
                MessageDlg('Atençao!' +#13+
                           'Email inválido',TMsgDlgType.mtInformation,[TMsgDlgBtn.mbok],0);
end;

end.
