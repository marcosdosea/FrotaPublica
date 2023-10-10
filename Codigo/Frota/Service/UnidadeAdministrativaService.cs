using Core;
using Core.Service;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Service
{
    public class UnidadeAdministrativa : IUnidadeAdministrativaService
    {
        private readonly FrotaContext context;

        // Construtor que recebe o contexto do banco.
        public UnidadeAdministrativa(FrotaContext context)
        {
            this.context = context;
        }

        // Método para criar uma nova unidade administrativa
        // Adiciona a unidade administrativa ao contexto.
        // Salva as alterações no banco.
        // Retorna o ID da unidade administrativa recém-criada.
        public uint Create(Unidadeadministrativa unidadeadministrativa)
        {
            context.Add(unidadeadministrativa);
            context.SaveChanges();
            return unidadeadministrativa.Id;
        }
        // Método para excluir uma unidade administrativa com base em seu ID.
        // Encontra a unidade administrativa com o ID especificado no banco de dados.
        // Remove a unidade administrativa do contexto.
        // Salva as alterações no banco de dados para efetuar a exclusão.
        public void Delete(uint UADM)
        {
            var unidadeadministrativa = context.UADMS.Find(UADM);
            context.Remove(unidadeadministrativa);
            context.SaveChanges();
        }

        // Método para editar uma unidade administrativa existente.
        // Atualiza a unidade administrativa no contexto.
        // Salva as alterações no banco de dados.
        public void Edit(Unidadeadministrativa unidadeadministrativa)
        {
            context.Update(unidadeadministrativa);
            context.SaveChanges();
        }

        // Método para obter uma unidade administrativa com base em seu ID.
        // Encontra a unidade administrativa com o ID especificado no banco de dados.
        // Verifica se a unidade administrativa foi encontrada.
        // Se não foi encontrada, retorna null ou pode ser implementada uma ação de tratamento de erro.
        // Retorna a unidade administrativa encontrada.
        public Unidadeadministrativa? Get(uint IdUADM)
        {
            var unidadeadministrativa = context.UADMS.Find(IdUADM);
            if (unidadeadministrativa == null)
            {
              return null;
            }
            return unidadeadministrativa;
        }

        uint IUnidadeAdministrativaService.Create(Unidadeadministrativa unidadeadministrativa)
        {
            throw new NotImplementedException();
        }

        void IUnidadeAdministrativaService.Delete(uint IdUADM)
        {
            throw new NotImplementedException();
        }

        void IUnidadeAdministrativaService.Edit(Unidadeadministrativa unidadeadministrativa)
        {
            throw new NotImplementedException();
        }

        Unidadeadministrativa? IUnidadeAdministrativaService.Get(uint IdUADM)
        {
            throw new NotImplementedException();
        }

        IEnumerable<Unidadeadministrativa> IUnidadeAdministrativaService.GetAll()
        {
            throw new NotImplementedException();
        }

        // Método para obter todas as unidades administrativas.
        // Retorna todas as unidades administrativas do banco de dados, sem rastreamento de mudanças.

    }
}
