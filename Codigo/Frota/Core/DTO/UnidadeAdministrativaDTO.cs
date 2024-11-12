using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Core.DTO
{
	public class UnidadeAdministrativaDTO
	{
		public uint Id { get; set; }

		public string Nome { get; set; } = null!;
	}
}
