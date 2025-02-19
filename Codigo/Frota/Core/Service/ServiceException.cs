using System.Text.Json;
using System.Text.RegularExpressions;
using Microsoft.EntityFrameworkCore;
using MySql.Data.MySqlClient;

namespace Core.Service
{
    [Serializable]
    public class ServiceException : Exception
    {
        public string AtributoError { get; private set; } = string.Empty;
        public string MensagemCustom { get; private set; } = string.Empty;

        public ServiceException()
        {
        }

        public ServiceException(string? message) : base(message)
        {
        }

        public ServiceException(string mensagem, Exception inner)
            : base(mensagem, inner)
        {
            this.ProcessarAtualizacaoBanco(inner);
        }

        public string Serialize()
        {
            return JsonSerializer.Serialize(this);
        }

        public static ServiceException? Deserialize(string json)
        {
            return JsonSerializer.Deserialize<ServiceException>(json);
        }

        public void ProcessarAtualizacaoBanco(Exception exception)
        {
            switch (exception)
            {
                case DbUpdateException dbUpdateException:
                    if (dbUpdateException.InnerException is MySqlException mySqlException)
                    {
                        if (mySqlException.Number == 1062)
                        {
                            string expressaoRegularAtributo = @"'([^']+)_UNIQUE'";
                            var match = Regex.Match(mySqlException.Message, expressaoRegularAtributo);
                            this.AtributoError = match.Groups[1].Value;
                        }
                        else if (mySqlException.Number == 1451)
                        {
                            this.MensagemCustom = "Este registro não pode ser excluído";
                        }
                    }
                    break;
            }
        }
    }
}
