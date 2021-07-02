unit FuncoesHelpers;

interface

uses FMX.Forms, FMX.Edit, FMX.ComboEdit;

procedure LimparForm(pForm: TForm);

implementation

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

end.
