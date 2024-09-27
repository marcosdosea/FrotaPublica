using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Core.Service
{
    public interface IVistoriaService
    {
		int Create(Vistorium vistoria);
		void Edit(Vistorium vistoria);
		void Delete(uint id);
		Vistorium? Get(uint id);
		IEnumerable<Vistorium> GetAll();
	}
}
