using System.Text.Json;

namespace Core.Service
{
    [Serializable]
    public class ServiceException : Exception
    {
        public ServiceException()
        {
        }

        public ServiceException(string? message) : base(message)
        {
        }

        public ServiceException(string mensagem, Exception inner)
            : base(mensagem, inner)
        {

        }

        public string Serialize()
        {
            return JsonSerializer.Serialize(this);
        }

        public static ServiceException? Deserialize(string json)
        {
            return JsonSerializer.Deserialize<ServiceException>(json);
        }
    }
}
