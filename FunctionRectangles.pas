unit FunctionRectangles;

interface

uses FMX.Objects, FMX.Forms;

        type
                TFunctionRectangles = class(TForm)
        private
        public
                procedure RecMouseEnter(Sender: TObject);
                procedure RecMouseLeave(Sender: TObject);
        end;

const
        zMouseEnterOpacity = 0.5;
        zMouseLeaveOpacity = 1;

var
        FunctionRectangle : TFunctionRectangles;

implementation

procedure TFunctionRectangles.RecMouseEnter(Sender: TObject);
begin
        TRectangle(Sender).Opacity := zMouseEnterOpacity;
end;

procedure TFunctionRectangles.RecMouseLeave(Sender: TObject);
begin
        TRectangle(Sender).Opacity := zMouseLeaveOpacity;
end;

end.
