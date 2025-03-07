using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Core.DTO
{
	public class FrotaDTO
	{
		public uint Id { get; set; }

		public string Nome { get; set; } = null!;
        public string Cnpj { get; set; } = null!;
    }
}
