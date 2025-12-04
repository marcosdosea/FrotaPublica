using Microsoft.AspNetCore.Identity.UI.Services;
using System.Net;
using System.Net.Mail;
using System.Net.Mime;

namespace FrotaWeb.Helpers;
public class EmailSender : IEmailSender
{
    private readonly SmtpClient _client;
    private readonly string _from;
    private readonly string _webRootPath;

    public EmailSender(IConfiguration configuration, IWebHostEnvironment environment)
    {
        _from = configuration["Smtp:From"];
        _webRootPath = environment.WebRootPath; // Obtém o caminho físico do wwwroot
        _client = new SmtpClient
        {
            Host = configuration["Smtp:Host"],
            Port = int.Parse(configuration["Smtp:Port"]),
            Credentials = new NetworkCredential(configuration["Smtp:Username"], configuration["Smtp:Password"]),
            EnableSsl = true
        };
    }

    public Task SendEmailAsync(string email, string subject, string htmlMessage)
    {
        // Caminho físico para a imagem no servidor, dentro do wwwroot

        var mailMessage = new MailMessage
        {
            From = new MailAddress(_from),
            Subject = "Confirme seu cadastro",
            Body = htmlMessage,
            IsBodyHtml = true
        };
        mailMessage.To.Add(email);

        // Cria o conteúdo HTML com a imagem embutida
        var htmlWithHeaderAndFooter = $@"
            <html>
              <body style=""margin: 0; padding: 0; font-family: Arial, sans-serif; background-color: #f7f7f7; border-radius: 10px;"">
                <table align=""center"" border=""0"" cellpadding=""0"" cellspacing=""0"" width=""600"" style=""border-collapse: collapse; background-color: #ffffff; box-shadow: 0px 4px 10px rgba(0, 0, 0, 0.1);"">
                  <!-- Header -->
       
                  <tr>
                    <td align=""center"" style=""padding: 30px 40px; background-color: #0C69AB;"">
                        <h2 style=""color: #ffffff; text-align: start; height: 0px; font-size: 20px;"">Olá,</h2>
                        <h2 style=""color: #ffffff; text-align: start; height: 20px; font-weight: 800; font-size: 30px;"">{subject}</h2>
                        <h2 style=""color: #ffffff; text-align: start; height: 0px; font-weight: 600; font-size: 20px;"">Bem vindo ao Frota!</h2>
                    </td>
                  </tr>
      
                  <!-- Body Content -->
                  <tr>
                    <td style=""padding: 10px; font-size: 16px; line-height: 1.6; color: #333333;"">
                      <h2 style=""color: #0C69AB; text-align: center;"">Está quase lá!</h2>
                      <h3 style=""color: #000000; text-align: center; font-size: 15px;"">Informe a senha que será usada para acessar o frota.</h3>
                    </td>
                  </tr>
      
                  <!-- Call to Action -->
                  <tr>
                    <td align=""center"" style=""padding: 20px;"">
                      <a href=""{htmlMessage}"" style=""background-color: #0C69AB; color: #ffffff; text-decoration: none; padding: 10px 20px; border-radius: 5px; font-size: 16px;"">Ir para o site</a>
                    </td>
                  </tr>

                  <tr>
                    <td align=""center"" style=""padding: 20px;"">
                      <h3 style=""color: #000000; text-align: center;"">Ou acesse o link abaixo:</h3>
                      <a href={htmlMessage} style=""color: #0C69AB;"">{htmlMessage}</a>
                    </td>
                  </tr>
      
                  <!-- Footer -->
                  <tr>
                    <td align=""center"" style=""padding: 20px; background-color: #D9E9F4; font-size: 14px; color: #888888;"">
                      <p>&copy; 2025 Frota. Todos os direitos reservados.</p>
                    </td>
                  </tr>
                </table>
              </body>
            </html>";

        // Cria a visualização alternativa com o HTML e a imagem inline
        var altView = AlternateView.CreateAlternateViewFromString(htmlWithHeaderAndFooter, null, MediaTypeNames.Text.Html);

        // Adiciona a visualização alternativa (HTML com a imagem inline) ao email
        mailMessage.AlternateViews.Add(altView);

        return _client.SendMailAsync(mailMessage);
    }
}
