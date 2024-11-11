using Core.Service;
using Core;
using Microsoft.EntityFrameworkCore;

namespace Service.Tests
{
	[TestClass()]
	public class PecaInsumoServiceTests
	{
		private FrotaContext? context;
		private IPecaInsumoService? pecaIsumoService;

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

			var pecasInsumos = new List<Pecainsumo>
			{
				new Pecainsumo
				{
					Id = 1,
					Descricao = "Filtro de ar substituído"
				},

				new Pecainsumo
				{
					Id = 2,
					Descricao = "Óleo do motor trocado"
				},

				new Pecainsumo
				{
					Id = 3,
					Descricao = "Pastilhas de freio gastas"
				},
			};
			context.AddRange(pecasInsumos);
			context.SaveChanges();
			pecaIsumoService = new PecaInsumoService(context);
		}

		[TestMethod()]
		public void CreateTest()
		{
			// Act
			pecaIsumoService!.Create(
				new Pecainsumo
				{
					Id = 4,
					Descricao = "Bateria nova instalada"
				}
			);
			// Assert
			Assert.AreEqual(4, pecaIsumoService.GetAll().Count());
			var pecaInsumo = pecaIsumoService.Get(4);
			Assert.AreEqual("Bateria nova instalada", pecaInsumo!.Descricao);
		}

		[TestMethod()]
		public void DeleteTest()
		{
			// Act
			pecaIsumoService!.Delete(2);
			// Assert
			Assert.AreEqual(2, pecaIsumoService.GetAll().Count());
			var pecaInsumo = pecaIsumoService.Get(2);
			Assert.AreEqual(null, pecaInsumo);
		}

		[TestMethod()]
		public void EditTest()
		{
			//Act 
			var pecaInsumo = pecaIsumoService!.Get(3);
			pecaInsumo!.Descricao = "Pneu dianteiro trocado";
			//Assert
			pecaInsumo = pecaIsumoService.Get(3);
			Assert.IsNotNull(pecaInsumo);
			Assert.AreEqual("Pneu dianteiro trocado", pecaInsumo.Descricao);
		}

		[TestMethod()]
		public void GetTest()
		{
			var pecaInsumo = pecaIsumoService!.Get(1);
			Assert.IsNotNull(pecaInsumo);
			Assert.AreEqual("Filtro de ar substituído", pecaInsumo.Descricao);
		}

		[TestMethod()]
		public void GetAllTest()
		{
			// Act
			var listaPecaInsumo = pecaIsumoService!.GetAll();
			// Assert
			Assert.IsInstanceOfType(listaPecaInsumo, typeof(IEnumerable<Pecainsumo>));
			Assert.IsNotNull(listaPecaInsumo);
			Assert.AreEqual(3, listaPecaInsumo.Count());
			Assert.AreEqual((uint)1, listaPecaInsumo.First().Id);
			Assert.AreEqual("Filtro de ar substituído", listaPecaInsumo.First().Descricao);
		}
	}
}