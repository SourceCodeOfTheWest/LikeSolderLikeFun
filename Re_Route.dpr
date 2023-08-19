program Re_Route;

uses
  Vcl.Forms,
  PATCHnSCRATCH in 'PATCHnSCRATCH.pas' {Patch};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TPatch, Patch);
  Application.Run;
end.
