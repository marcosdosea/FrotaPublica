using Core;
using Core.Datatables;
using Core.Service;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Service
{
    public class AbastecimentoService : IAbastecimentoService
    {
        private readonly FrotaContext context;
        private readonly IFrotaService frotaService;

        public AbastecimentoService(FrotaContext context, IFrotaService frotaService)
        {
            this.context = context;
            this.frotaService = frotaService;
        }

        /// <summary>
        /// Adiciona novo abastecimento na base de dados
        /// </summary>
        /// <param name="abastecimento"></param>
        /// <returns></returns>
        public uint Create(Abastecimento abastecimento)
        {
            context.Add(abastecimento);
            context.SaveChanges();
            return abastecimento.Id;
        }

        /// <summary>
        /// Exclui um abastecimento da base de dados
        /// </summary>
        /// <param name="idAbastecimento"></param>
        public void Delete(uint idAbastecimento)
        {
            var abastecimento = context.Abastecimentos.Find(idAbastecimento);
            if (abastecimento != null)
            {
                context.Remove(abastecimento);
                context.SaveChanges();
            }
        }

        /// <summary>
        /// Altera os dados da veiculo na base de dados
        /// </summary>
        /// <param name="abastecimento"></param>
        public void Edit(Abastecimento abastecimento)
        {
            context.Update(abastecimento);
            context.SaveChanges();

        }

        /// <summary>
        /// Obter um abastecimento pelo id
        /// </summary>
        /// <param name="idAbastecimento"></param>
        /// <returns></returns>
        public Abastecimento? Get(uint idAbastecimento)
        {
            return context.Abastecimentos.Find(idAbastecimento);
        }

        /// <summary>
        /// Obter a lista de abastecimentos cadastradas
        /// </summary>
        /// <returns></returns>
        public IEnumerable<Abastecimento> GetAll()
        {
            return context.Abastecimentos.AsNoTracking();
        }

        public DatatableResponse<Abastecimento> GetDataPage(DatatableRequest request)
        {
            uint idFrota = frotaService.GetFrotaByUser();
            var abastecimentos = context.Abastecimentos.Where(abastecimentos => abastecimentos.IdFrota == idFrota).AsNoTracking();

            var totalResults = abastecimentos.Count();

            if (request.Search != null && request.Search.GetValueOrDefault("value") != null)
            {
                abastecimentos = abastecimentos.Where(abastecimentos => abastecimentos.Id.ToString().Contains(request.Search.GetValueOrDefault("value")));
            }

            if (request.Order != null && request.Order[0].GetValueOrDefault("column").Equals("0"))
            {
                if (request.Order[0].GetValueOrDefault("dir").Equals("asc"))
                    abastecimentos = abastecimentos.OrderBy(abastecimentos => abastecimentos.Id);
                else
                    abastecimentos = abastecimentos.OrderByDescending(abastecimentos => abastecimentos.Id);
            }
            int countRecordsFiltered = abastecimentos.Count();
            abastecimentos = abastecimentos.Skip(request.Start).Take(request.Length);
            return new DatatableResponse<Abastecimento>
            {
                Data = abastecimentos.ToList(),
                Draw = request.Draw,
                RecordsFiltered = countRecordsFiltered,
                RecordsTotal = totalResults
            };
        }

        public IEnumerable<Abastecimento> GetPaged(int page, int lenght)
        {
            return context.Abastecimentos
                          .AsNoTracking()
                          .Skip(page * lenght)
                          .Take(lenght);
        }
    }
}
