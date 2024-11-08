using Core.Service;
using Core;
using Microsoft.EntityFrameworkCore;

namespace Service.Tests
{
	[TestClass()]
	public class VistoriaServiceTests
	{
		private FrotaContext? context;
		private IVistoriaService? vistoriaService;

		[TestInitialize]
		public void Initialize()
		{
			// Arrange
			var builder = new DbContextOptionsBuilder<FrotaContext>();
			builder.UseInMemoryDatabase("Frota");
			var options = builder.Options;

			context = new FrotaContext(options);
			context.Database.EnsureDeleted();
			context.Database.EnsureCreated();

			var vistorias = new List<Vistorium>
			{
				new Vistorium
				{
					Id = 1,
					Data = DateTime.Parse("2024-11-7"),
					Problemas = "Amortecedor desgastado",
					Tipo = "S",
					IdPessoaResponsavel = 2
				},
				new Vistorium
				{
					Id = 2,
					Data = DateTime.Parse("2024-12-7"),
					Problemas = "Freio com desgaste",
					Tipo = "S",
					IdPessoaResponsavel = 2
				},
				new Vistorium
				{
					Id = 3,
					Data = DateTime.Parse("2024-11-15"),
					Problemas = "Óleo abaixo do nível",
					Tipo = "R",
					IdPessoaResponsavel = 3
				}
			};
			context.AddRange(vistorias);
			context.SaveChanges();
			vistoriaService = new VistoriaService(context);
		}

		[TestMethod()]
		public void CreateTest()
		{
			// Act
			vistoriaService!.Create(
				new Vistorium
				{
					Id = 4,
					Data = DateTime.Parse("2024-11-20"),
					Problemas = "Pneus desbalanceados",
					Tipo = "R",
					IdPessoaResponsavel = 3
				}
			);
			// Assert
			Assert.AreEqual(4, vistoriaService.GetAll().Count());
			var vistoria = vistoriaService.Get(4);
			Assert.AreEqual(DateTime.Parse("2024-11-20"), vistoria!.Data);
			Assert.AreEqual("Pneus desbalanceados", vistoria.Problemas);
			Assert.AreEqual("R", vistoria.Tipo);
		}

		[TestMethod()]
		public void DeleteTest()
		{
			// Act
			vistoriaService!.Delete(2);
			// Assert
			Assert.AreEqual(2, vistoriaService.GetAll().Count());
			var vistoria = vistoriaService.Get(2);
			Assert.AreEqual(null, vistoria);
		}

		[TestMethod()]
		public void EditTest()
		{
			//Act 
			var vistoria = vistoriaService!.Get(3);
			vistoria!.Problemas = "Freio com desgaste e vazamento de fluido";
			vistoria.Tipo = "R";
			vistoriaService.Edit(vistoria);
			//Assert
			vistoria = vistoriaService.Get(3);
			Assert.IsNotNull(vistoria);
			Assert.AreEqual("Freio com desgaste e vazamento de fluido", vistoria.Problemas);
			Assert.AreEqual("R", vistoria.Tipo);
		}

		[TestMethod()]
		public void GetTest()
		{
			var vistoria = vistoriaService!.Get(1);
			Assert.IsNotNull(vistoria);
			Assert.AreEqual(DateTime.Parse("2024-11-7"), vistoria!.Data);
			Assert.AreEqual("Amortecedor desgastado", vistoria.Problemas);
			Assert.AreEqual("S", vistoria.Tipo);
		}

		[TestMethod()]
		public void GetAllTest()
		{
			// Act
			var listaVistoria = vistoriaService!.GetAll();
			// Assert
			Assert.IsInstanceOfType(listaVistoria, typeof(IEnumerable<Vistorium>));
			Assert.IsNotNull(listaVistoria);
			Assert.AreEqual(3, listaVistoria.Count());
			Assert.AreEqual((uint)1, listaVistoria.First().Id);
			Assert.AreEqual(DateTime.Parse("2024-11-7"), listaVistoria.First().Data);
		}
	}
}