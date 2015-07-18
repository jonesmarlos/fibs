unit EmailUnit;

interface

uses
  Classes, SysUtils, IdMessage, IdBaseComponent,
  IdComponent, IdTCPConnection, IdTCPClient, IdExplicitTLSClientServerBase,
  IdMessageClient, IdSMTPBase, IdSMTP;

procedure SendEmail(SendersMail: string; EmailAddr: string; Subject: string; SmtpServer: string; Body: string; MailUserName: string; MailPassword: string);

implementation

procedure SendEmail(SendersMail: string; EmailAddr: string; Subject: string; SmtpServer: string; Body: string; MailUserName: string; MailPassword: string);
var
  Smtp: TIdSMTP;
  Email: TIdMessage;
begin
  Smtp := TIdSMTP.Create;
  Email := TIdMessage.Create;
  try
    Smtp.Host := SmtpServer;
    Smtp.Username := MailUserName;
    Smtp.Password := MailPassword;
    if Smtp.Authenticate then
    begin
      Email.FromList.Add.Address := SendersMail;
      Email.Recipients.Add.Address := EmailAddr;
      Email.Subject := Subject;
      Email.Body.Add(Body);
      Smtp.Send(Email);
    end;
  finally
    Smtp.Free;
    Email.Free;
  end;
end;

end.
