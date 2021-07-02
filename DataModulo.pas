unit DataModulo;

interface

uses
  System.SysUtils, System.Classes, System.UITypes;

type
  TDM = class(TDataModule)
    procedure DataModuleCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DM: TDM;

        zColorError  : TAlphaColor;
        zColorPadrao : TAlphaColor;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

procedure TDM.DataModuleCreate(Sender: TObject);
begin
        zColorError  := $FFFF0303;
        zColorPadrao := $FF000000;
end;

end.
