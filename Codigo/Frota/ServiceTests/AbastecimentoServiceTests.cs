using Core;
using Core.Service;
using Microsoft.EntityFrameworkCore;

namespace Service.Tests
{
	[TestClass()]
	public class AbastecimentoServiceTests
	{
		private FrotaContext? context;
		private IAbastecimentoService? abastecimentoService;

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

			var abastecimentos = new List<Abastecimento>
			{
				new Abastecimento
				{
					Id = 1,
					IdVeiculoPercurso = 1,
					IdPessoaPercurso = 1,
					DataHora = DateTime.Parse("2021-07-02"),
					Odometro = 10000,
					Litros = 50,
					IdFornecedor = 1
				},
				new Abastecimento
				{
					Id = 2,
					IdVeiculoPercurso = 2,
					IdPessoaPercurso = 1,
					DataHora = DateTime.Parse("2021-06-11"),
					Odometro = 20000,
					Litros = 60,
					IdFornecedor = 1
				},
				new Abastecimento
				{
					Id = 3,
					IdVeiculoPercurso = 1,
					IdPessoaPercurso = 2,
					DataHora = DateTime.Parse("2021-08-12"),
					Odometro = 25000,
					Litros = 100,
					IdFornecedor = 1
				}
			};
			context.AddRange(abastecimentos);
			context.SaveChanges();
			abastecimentoService = new AbastecimentoService(context);
		}

		[TestMethod()]
		public void CreateTest()
		{
			// Act
			abastecimentoService!.Create(
				new Abastecimento
				{
					Id = 4,
					IdVeiculoPercurso = 1,
					IdPessoaPercurso = 2,
					DataHora = DateTime.Parse("2021-10-18"),
					Odometro = 25800,
					Litros = 90,
					IdFornecedor = 1
				}
			);
			// Assert
			Assert.AreEqual(4, abastecimentoService.GetAll().Count());
			var abastecimento = abastecimentoService.Get(4);
			Assert.AreEqual(DateTime.Parse("2021-10-18"), abastecimento!.DataHora);
			Assert.AreEqual(25800, abastecimento.Odometro);
			Assert.AreEqual(90, abastecimento.Litros);
		}

		[TestMethod()]
		public void DeleteTest()
		{
			// Act
			abastecimentoService!.Delete(2);
			// Assert
			Assert.AreEqual(2, abastecimentoService.GetAll().Count());
			var abastecimento = abastecimentoService.Get(2);
			Assert.AreEqual(null, abastecimento);
		}

		[TestMethod()]
		public void EditTest()
		{
			//Act 
			var abastecimento = abastecimentoService!.Get(3);
			abastecimento!.Odometro = 25700;
			abastecimento.Litros = 85;
			abastecimentoService.Edit(abastecimento);
			//Assert
			abastecimento = abastecimentoService.Get(3);
			Assert.IsNotNull(abastecimento);
			Assert.AreEqual(25700, abastecimento.Odometro);
			Assert.AreEqual(85, abastecimento.Litros);
		}

		[TestMethod()]
		public void GetTest()
		{
			var abastecimento = abastecimentoService!.Get(1);
			Assert.IsNotNull(abastecimento);
			Assert.AreEqual(10000, abastecimento.Odometro);
			Assert.AreEqual(50, abastecimento.Litros);
		}

		[TestMethod()]
		public void GetAllTest()
		{
			// Act
			var listaAbastecimento = abastecimentoService!.GetAll();
			// Assert
			Assert.IsInstanceOfType(listaAbastecimento, typeof(IEnumerable<Abastecimento>));
			Assert.IsNotNull(listaAbastecimento);
			Assert.AreEqual(3, listaAbastecimento.Count());
			Assert.AreEqual((uint)1, listaAbastecimento.First().Id);
			Assert.AreEqual(DateTime.Parse("2021-07-02"), listaAbastecimento.First().DataHora);
		}
	}
}