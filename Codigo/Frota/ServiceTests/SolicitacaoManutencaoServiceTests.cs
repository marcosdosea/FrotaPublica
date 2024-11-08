using Core.Service;
using Core;
using Microsoft.EntityFrameworkCore;

namespace Service.Tests
{
	[TestClass()]
	public class SolicitacaoManutencaoServiceTests
	{
		private FrotaContext? context;
		private ISolicitacaoManutencaoService? solicitacaoManutencaoService;

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

			var solicitacoes = new List<Solicitacaomanutencao>
			{
				new Solicitacaomanutencao
				{
					Id = 1,
					IdVeiculo = 5,
					IdPessoa = 6,
					DataSolicitacao = DateTime.Parse("2024-01-15"),
					DescricaoProblema = "Motor apresentando superaquecimento"
				},
				new Solicitacaomanutencao
				{
					Id = 2,
					IdVeiculo = 2,
					IdPessoa = 3,
					DataSolicitacao = DateTime.Parse("2024-02-20"),
					DescricaoProblema = "Freios com desgaste excessivo"
				},
				new Solicitacaomanutencao
				{
					Id = 3,
					IdVeiculo = 1,
					IdPessoa = 2,
					DataSolicitacao = DateTime.Parse("2024-03-12"),
					DescricaoProblema = "Suspensão apresentando ruídos"
				}
			};
			context.AddRange(solicitacoes);
			context.SaveChanges();
			solicitacaoManutencaoService = new SolicitacaoManutencaoService(context);
		}

		[TestMethod()]
		public void CreateTest()
		{
			// Act
			solicitacaoManutencaoService!.Create(
				new Solicitacaomanutencao
				{
					Id = 4,
					IdVeiculo = 1,
					IdPessoa = 2,
					DataSolicitacao = DateTime.Parse("2024-04-05"),
					DescricaoProblema = "Bateria descarregando rapidamente"
				}
			);
			// Assert
			Assert.AreEqual(4, solicitacaoManutencaoService.GetAll().Count());
			var solicitacaoManutencao = solicitacaoManutencaoService.Get(4);
			Assert.AreEqual(DateTime.Parse("2024-04-05"), solicitacaoManutencao!.DataSolicitacao);
			Assert.AreEqual("Bateria descarregando rapidamente", solicitacaoManutencao!.DescricaoProblema);
		}

		[TestMethod()]
		public void DeleteTest()
		{
			// Act
			solicitacaoManutencaoService!.Delete(2);
			// Assert
			Assert.AreEqual(2, solicitacaoManutencaoService.GetAll().Count());
			var solicitacaoManutencao = solicitacaoManutencaoService.Get(2);
			Assert.AreEqual(null, solicitacaoManutencao);
		}

		[TestMethod()]
		public void EditTest()
		{
			//Act 
			var solicitacaoManutencao = solicitacaoManutencaoService!.Get(3);
			solicitacaoManutencao!.DataSolicitacao = DateTime.Parse("2024-04-05");
			solicitacaoManutencao.DescricaoProblema = "Ar-condicionado não está funcionando";
			solicitacaoManutencaoService.Edit(solicitacaoManutencao);
			//Assert
			solicitacaoManutencao = solicitacaoManutencaoService.Get(3);
			Assert.IsNotNull(solicitacaoManutencao);
			Assert.AreEqual(DateTime.Parse("2024-04-05"), solicitacaoManutencao.DataSolicitacao);
			Assert.AreEqual("Ar-condicionado não está funcionando", solicitacaoManutencao.DescricaoProblema);
		}

		[TestMethod()]
		public void GetTest()
		{
			var solicitacaoManutencao = solicitacaoManutencaoService!.Get(1);
			Assert.IsNotNull(solicitacaoManutencao);
			Assert.AreEqual(DateTime.Parse("2024-01-15"), solicitacaoManutencao.DataSolicitacao);
			Assert.AreEqual("Motor apresentando superaquecimento", solicitacaoManutencao.DescricaoProblema);
		}

		[TestMethod()]
		public void GetAllTest()
		{
			// Act
			var listaSolicitacaoManutencao = solicitacaoManutencaoService!.GetAll();
			// Assert
			Assert.IsInstanceOfType(listaSolicitacaoManutencao, typeof(IEnumerable<Solicitacaomanutencao>));
			Assert.IsNotNull(listaSolicitacaoManutencao);
			Assert.AreEqual(3, listaSolicitacaoManutencao.Count());
			Assert.AreEqual((uint)1, listaSolicitacaoManutencao.First().Id);
			Assert.AreEqual(DateTime.Parse("2024-01-15"), listaSolicitacaoManutencao.First().DataSolicitacao);
			Assert.AreEqual("Motor apresentando superaquecimento", listaSolicitacaoManutencao.First().DescricaoProblema);
		}
	}
}