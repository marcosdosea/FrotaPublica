using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Core.Service;

public interface IPercursoService
{
	uint Create(Percurso percurso);
	void Edit(Percurso percurso);
	void Delete(uint idPercurso);
	Percurso? Get(uint idPercurso);
	IEnumerable<Percurso> GetAll();
	Percurso? ObterPercursosAtualDoMotorista(int idPessoa);
}
