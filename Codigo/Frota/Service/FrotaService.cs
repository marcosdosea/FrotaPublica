using Core;
using Core.DTO;
using Core.Service;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;

namespace Service
{
    public class FrotaService : IFrotaService
    {
        private readonly FrotaContext context;

        private readonly IHttpContextAccessor httpContextAccessor;

        public FrotaService(FrotaContext context, IHttpContextAccessor httpContextAccessor)
        {
            this.context = context;
            this.httpContextAccessor = httpContextAccessor;
        }

        /// <summary>
        /// Adionar nova frota na base de dados
        /// </summary>
        /// <param name="frota"></param>
        /// <returns></returns>
        public uint Create(Frotum frota)
        {
            context.Add(frota);
            context.SaveChanges();
            return frota.Id;
        }

        /// <summary>
        /// Excluir uma frota da base de dados
        /// </summary>
        /// <param name="idFrota"></param>
        /// <returns>retorna verdadeiro se o registro for removido</returns>
        public bool Delete(uint idFrota)
        {
            var frota = context.Frota.Find(idFrota);
            if (frota != null)
            {
                context.Remove(frota);
                context.SaveChanges();
                return true;
            }
            return false;
        }

        /// <summary>
        /// Alterar os dados da frota na base de dados
        /// </summary>
        /// <param name="frota"></param>
        public void Edit(Frotum frota)
        {
            context.Update(frota);
            context.SaveChanges();
        }

        /// <summary>
        /// Obter pelo id da frota
        /// </summary>
        /// <param name="idFrota"></param>
        /// <returns>retorna o objeto ou um valor nulo</returns>
        public Frotum? Get(uint idFrota)
        {
            return context.Frota.Find(idFrota);

        }

        /// <summary>
        /// Obter o id da frota através do usuário autenticado
        /// </summary>
        /// <returns>Id do Frota</returns>
        /// <exception cref="UnauthorizedAccessException"></exception>
        /// <exception cref="InvalidOperationException"></exception>
        public uint GetFrotaByUser()
        {
            var cpf = httpContextAccessor.HttpContext?.User?.Identity?.Name;

            if (string.IsNullOrEmpty(cpf))
            {
                throw new UnauthorizedAccessException("Usuário não autenticado.");
            }
            var idFrota = context.Pessoas
                                 .AsNoTracking()
                                 .Where(p => p.Cpf == cpf)
                                 .Select(p => p.IdFrota)
                                 .FirstOrDefault();
            if (idFrota == 0)
            {
                throw new InvalidOperationException("Frota não encontrada para o usuário autenticado.");
            }
            return idFrota;
        }

        /// <summary>
        /// Obter a lista de frota cadastradas
        /// </summary>
        /// <returns></returns>
        public IEnumerable<Frotum> GetAll()
        {
            return context.Frota.AsNoTracking();
        }

        /// <summary>
        /// Obter a lista de frotas cadastradas em ordem alfabética
        /// </summary>
        /// <returns></returns>
        public IEnumerable<FrotaDTO> GetAllOrdemAlfabetica()
        {
            var frotaDTO = from frota in context.Frota
                           orderby frota.Nome
                           select new FrotaDTO
                           {
                               Id = frota.Id,
                               Nome = frota.Nome
                           };
            return frotaDTO.ToList();
        }
    }
}
