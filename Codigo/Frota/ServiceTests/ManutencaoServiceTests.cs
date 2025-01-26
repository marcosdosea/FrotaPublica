using Core;
using Core.DTO;
using Core.Service;
using Microsoft.EntityFrameworkCore;

namespace Service.Tests
{
    [TestClass()]
    public class ManutencaoServiceTests
    {
        private FrotaContext? context;
        private IManutencaoService? manutencaoService;

        [TestInitialize()]
        public void Initialize()
        {
            // Arrange
            var builder = new DbContextOptionsBuilder<FrotaContext>();
            builder.UseInMemoryDatabase("Frota");
            var options = builder.Options;

            context = new FrotaContext(options);
            context.Database.EnsureDeleted();
            context.Database.EnsureCreated();
            var manutencoes = new List<Manutencao>
            {
                new Manutencao
                {
                    Id = 1,
                    IdVeiculo = 1001,
                    IdFornecedor = 2001,
                    DataHora = DateTime.Now,
                    IdResponsavel = 3001,
                    ValorPecas = 1500.50m,
                    ValorManutencao = 500.75m,
                    Tipo = "Preventiva",
                    Comprovante = null,
                    Status = "Concluído",
                    IdFrota = 1
                },
                new Manutencao
                {
                    Id = 2,
                    IdVeiculo = 1002,
                    IdFornecedor = 2002,
                    DataHora = DateTime.Now.AddDays(-7),
                    IdResponsavel = 3002,
                    ValorPecas = 200.00m,
                    ValorManutencao = 150.25m,
                    Tipo = "Corretiva",
                    Comprovante = null,
                    Status = "Pendente",
                    IdFrota = 1
                },
                new Manutencao
                {
                    Id = 3,
                    IdVeiculo = 1003,
                    IdFornecedor = 2003,
                    DataHora = DateTime.Now.AddMonths(-1),
                    IdResponsavel = 3003,
                    ValorPecas = 750.00m,
                    ValorManutencao = 250.00m,
                    Tipo = "Preventiva",
                    Comprovante = null,
                    Status = "Em Andamento",
                    IdFrota = 2
                }
            };
            context.AddRange(manutencoes);
            context.SaveChanges();
            manutencaoService = new ManutencaoService(context);
        }

        [TestMethod()]
        public void CreateTest()
        {
            // Act
            manutencaoService!.Create(new Manutencao
            {
                Id = 4,
                IdVeiculo = 1003,
                IdFornecedor = 2003,
                DataHora = DateTime.Now.AddMonths(-1),
                IdResponsavel = 3003,
                ValorPecas = 750.00m,
                ValorManutencao = 250.00m,
                Tipo = "Preventiva",
                Comprovante = null,
                Status = "Em Andamento",
            },
                2
            );
            // Assert
            Assert.AreEqual(2, manutencaoService.GetAll(2).Count());
            var manutencao = manutencaoService.Get(4);
            Assert.AreEqual("Preventiva", manutencao!.Tipo);
            Assert.AreEqual(3003m, manutencao.IdResponsavel);
        }

        [TestMethod()]
        public void DeleteTest()
        {
            // Act
            manutencaoService!.Delete(2);
            // Assert
            Assert.AreEqual(1, manutencaoService.GetAll(1).Count());
            var manutencao = manutencaoService.Get(2);
            Assert.AreEqual(null, manutencao);
        }

        [TestMethod()]
        public void EditTest()
        {
            // Act
            var manutencao = manutencaoService!.Get(3);
            manutencao!.ValorPecas = 1000.00m;
            manutencao.ValorManutencao = 500.00m;
            manutencaoService.Edit(manutencao, 2);
            // Assert
            manutencao = manutencaoService.Get(3);
            Assert.AreEqual(1000.00m, manutencao!.ValorPecas);
            Assert.AreEqual(500.00m, manutencao.ValorManutencao);
        }

        [TestMethod()]
        public void GetTest()
        {
            // Act
            var manutencao = manutencaoService!.Get(1);
            // Assert
            Assert.IsNotNull(manutencao);
            Assert.AreEqual("Preventiva", manutencao.Tipo);
            Assert.AreEqual(1001m, manutencao.IdVeiculo);
            Assert.AreEqual(2001m, manutencao.IdFornecedor);
        }

        [TestMethod()]
        public void GetAllTest()
        {
            // Act
            var listaManutencao = manutencaoService!.GetAll(1);
            // Assert
            Assert.IsInstanceOfType(listaManutencao, typeof(IEnumerable<Manutencao>));
            Assert.IsNotNull(listaManutencao);
            Assert.AreEqual(2, listaManutencao.Count());
            Assert.AreEqual((uint)1, listaManutencao.First().Id);
        }
    }
}