using Core;
using Core.Service;
using Microsoft.EntityFrameworkCore;

namespace Service
{
    public class VistoriaService : IVistoriaService
    {
        private readonly FrotaContext context;

        public VistoriaService(FrotaContext context)
        {
            this.context = context;
        }
        /// <summary>
        /// Cadastra uma nova vistoria
        /// </summary>
        /// <param name="vistoria"></param>
        /// <returns>Id da vistoria cadastrada</returns>
        /// <exception cref="NotImplementedException"></exception>
        public uint Create(Vistorium vistoria)
        {
            context.Add(vistoria);
            context.SaveChanges();
            return (uint)vistoria.Id;
        }
        /// <summary>
        /// Exclui uma vistoria na base de dados
        /// </summary>
        /// <param name="id">Id da vistoria que será excluída</param>
        /// <exception cref="NotImplementedException"></exception>
        public void Delete(uint id)
        {
            var vistoria = context.Vistoria.Find(id);
            if (vistoria != null)
            {
                context.Remove(vistoria);
                context.SaveChanges();
            }
        }
        /// <summary>
        /// Edita uma vistoria na base de dados
        /// </summary>
        /// <param name="vistoria">Objeto contendo os dados da vistoria a ser editada</param>
        /// <exception cref="NotImplementedException"></exception>
        public void Edit(Vistorium vistoria)
        {
            context.Update(vistoria);
            context.SaveChanges();
        }
        /// <summary>
        /// Busca uma vistoria cadastrada
        /// </summary>
        /// <param name="id">Id da vistoria que a ser consultada</param>
        /// <returns>Objeto contendo os dados da vistoria encontrada, ou null se não existir</returns>
        /// <exception cref="NotImplementedException"></exception>
        public Vistorium? Get(uint id)
        {
            return context.Vistoria.Find(id);
        }

        /// <summary>
        /// Busca todas as vistorias cadastradas associadas à frota do usuário
        /// </summary>
		/// <param name="idFrota">Id da frota do usuário</param>
        /// <returns>Uma coleção de objetos do tipo Vistorium representando as vistorias encontradas</returns>
        public IEnumerable<Vistorium> GetAll(uint idFrota)
        {
            return context.Vistoria
                           .AsNoTracking()
                           .Include(vistoria => vistoria.IdPessoaResponsavelNavigation)
                           .Where(vistoria => vistoria.IdPessoaResponsavelNavigation.IdFrota == idFrota);
        }
    }
}
