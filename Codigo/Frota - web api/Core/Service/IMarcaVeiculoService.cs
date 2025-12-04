using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;


namespace Core.Service
{
    public interface IMarcaVeiculoService
    {
		uint Create(Marcaveiculo frota, int idFrota);
		void Edit(Marcaveiculo frota, int idFrota);
		void Delete(uint idFrota);
		Marcaveiculo? Get(uint idFrota);
		IEnumerable<Marcaveiculo> GetAll(int idFrota);
	}
}
