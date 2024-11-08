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
                    Comprovante = null, // ou um array de bytes para simular um comprovante
                    Status = "Concluído"
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
                    Status = "Pendente"
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
                    Status = "Em Andamento"
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
                Status = "Em Andamento"
            });
            // Assert
            Assert.AreEqual(4, manutencaoService.GetAll().Count());
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
            Assert.AreEqual(2, manutencaoService.GetAll().Count());
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
            manutencaoService.Edit(manutencao);
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
            var listaManutencao = manutencaoService!.GetAll();
            // Assert
            Assert.IsInstanceOfType(listaManutencao, typeof(IEnumerable<Manutencao>));
            Assert.IsNotNull(listaManutencao);
            Assert.AreEqual(3, listaManutencao.Count());
            Assert.AreEqual((uint)1, listaManutencao.First().Id);
        }
    }
}