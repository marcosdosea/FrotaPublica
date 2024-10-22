using System.ComponentModel.DataAnnotations;

namespace FrotaWeb.Models
{
	public class VistoriaViewModel
	{
		[Key]
		public int Id { get; set; }

		public DateTime Data { get; set; }

		public string Problemas { get; set; } = null!;

		public string Tipo { get; set; } = null!;

		public uint IdPessoaResponsavel { get; set; }

	}
}
