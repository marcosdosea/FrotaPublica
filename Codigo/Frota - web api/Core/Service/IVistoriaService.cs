using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Core.Service
{
    public interface IVistoriaService
    {
		uint Create(Vistorium vistoria);
		void Edit(Vistorium vistoria);
		void Delete(int id);
		Vistorium? Get(int id);
		IEnumerable<Vistorium> GetAll(uint idFrota);
	}
}
