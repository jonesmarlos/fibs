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
  SMTP: TIdSMTP;
  Email: TIdMessage;
begin
  SMTP := TIdSMTP.Create;
  Email := TIdMessage.Create;
  try
    SMTP.host := SmtpServer;
    SMTP.UserName := MailUserName;
    SMTP.Password := MailPassword;
    if SMTP.Authenticate then
    begin
      Email.FromList.Add.Address := SendersMail;
      Email.Recipients.Add.Address := EmailAddr;
      Email.Subject := Subject;
      Email.Body.Add(Body);
      SMTP.Send(Email);
    end;
  finally
    SMTP.Free;
    Email.Free;
  end;
end;

end.
