using Core;
using Core.DTO;
using Core.Service;
using Microsoft.EntityFrameworkCore;

namespace Service
{
    public class FornecedorService : IFornecedorService
    {
        private readonly FrotaContext context;

        public FornecedorService(FrotaContext context)
        {
            this.context = context;
        }

        /// <summary>
        /// Adionar um novo fornecedor na base de dados
        /// </summary>
        /// <param name="frota"></param>
        /// <returns></returns>
        public uint Create(Fornecedor fornecedor, int idFrota)
        {
            fornecedor.IdFrota = (uint)idFrota;
            context.Add(fornecedor);
            context.SaveChanges();
            return fornecedor.Id;
        }

        /// <summary>
        /// Excluir um fornecedor da base de dados
        /// </summary>
        /// <param name="idFrota"></param>
        public bool Delete(uint idFornecedor)
        {
            var entity = context.Fornecedors.Find(idFornecedor);
            if (entity != null)
            {
                context.Remove(entity);
                context.SaveChanges();
                return true;
            }
            return false;
        }

        /// <summary>
        /// Alterar os dados do fornecedor na base de dados
        /// </summary>
        /// <param name="frota"></param>
        public void Edit(Fornecedor fornecedor, int idFrota)
        {
            fornecedor.IdFrota = (uint)idFrota;
            context.Update(fornecedor);
            context.SaveChanges();
        }

        /// <summary>
        /// Obter pelo id do fornecedor
        /// </summary>
        /// <param name="idFrota"></param>
        /// <returns></returns>
        public Fornecedor? Get(uint idFornecedor)
        {
            return context.Fornecedors.Find(idFornecedor);
        }

        /// <summary>
        /// Obter a lista de fornecedores cadastradas
        /// </summary>
        /// <returns></returns>
        public IEnumerable<Fornecedor> GetAll(int idFrota)
        {
            return context.Fornecedors
                          .Where(fornecedor => fornecedor.IdFrota == idFrota)
                          .AsNoTracking();
        }

        /// <summary>
        /// Consultar um cnpj através da api da ReceitaWS
        /// </summary>
        /// <param name="cnpj">O CNPJ a ser consultado.</param>
        /// <returns>Uma tupla com um booleano indicando se a resposta foi bem-sucedida e o conteúdo ou mensagem de erro</returns>
        public async Task<(bool Success, string Data)> ConsultaCnpj(string cnpj)
        {
            using (var client = new HttpClient())
            {
                client.DefaultRequestHeaders.Add("User-Agent", "Mozilla/5.0");
                var response = await client.GetAsync($"https://www.receitaws.com.br/v1/cnpj/{cnpj}");
                if (response.IsSuccessStatusCode)
                {
                    var content = await response.Content.ReadAsStringAsync();
                    return (true, content);
                }
                else
                {
                    return (false, response.IsSuccessStatusCode.ToString());
                }
            }
        }


        public IEnumerable<FornecedorDTO> GetAllOrdemAlfabetica(int idFrota)
        {
            var fornecedoresDTOs = from fornecedor in context.Fornecedors.AsNoTracking()
                             where fornecedor.IdFrota == idFrota
                             orderby fornecedor.Nome
                             select new FornecedorDTO
                             {
                                 Id = fornecedor.Id,
                                 Nome = fornecedor.Nome
                             };
            return fornecedoresDTOs.ToList();
        }
    }
}