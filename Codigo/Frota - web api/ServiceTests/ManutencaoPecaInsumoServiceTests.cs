using Core.Service;
using Core;
using Microsoft.EntityFrameworkCore;

namespace Service.Tests
{
    [TestClass()]
    public class ManutencaoPecaInsumoServiceTests
    {
        private FrotaContext? context;
        private IManutencaoPecaInsumoService? manutencaoPecaInsumoService;

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

            var manutencaoPecaInsumos = new List<Manutencaopecainsumo>
            {
                new Manutencaopecainsumo
                {
                    IdManutencao = 1,
                    IdPecaInsumo = 1001,
                    IdMarcaPecaInsumo = 2001,
                    Quantidade = 5.5f,
                    MesesGarantia = 12,
                    KmGarantia = 50000,
                    ValorIndividual = 299.99m,
                    Subtotal = 5.5m * 299.99m
                },
                new Manutencaopecainsumo
                {
                    IdManutencao = 2,
                    IdPecaInsumo = 1002,
                    IdMarcaPecaInsumo = 2002,
                    Quantidade = 3.0f,
                    MesesGarantia = 24,
                    KmGarantia = 100000,
                    ValorIndividual = 499.99m,
                    Subtotal = 3.0m * 499.99m
                },
                new Manutencaopecainsumo
                {
                    IdManutencao = 3,
                    IdPecaInsumo = 1003,
                    IdMarcaPecaInsumo = 2003,
                    Quantidade = 10.0f,
                    MesesGarantia = 6,
                    KmGarantia = 30000,
                    ValorIndividual = 199.99m,
                    Subtotal = 10.0m * 199.99m
                }
            };
            context.AddRange(manutencaoPecaInsumos);
            context.SaveChanges();
            manutencaoPecaInsumoService = new ManutencaoPecaInsumoService(context);
        }

        [TestMethod()]
        public void CreateTest()
        {
            // Act
            manutencaoPecaInsumoService!.Create(
                new Manutencaopecainsumo
                {
                    IdManutencao = 4,
                    IdPecaInsumo = 1004,
                    IdMarcaPecaInsumo = 2004,
                    Quantidade = 11.0f,
                    MesesGarantia = 6,
                    KmGarantia = 30004,
                    ValorIndividual = 100.00m,
                    Subtotal = 11.0m * 100.00m
                }
            );
            // Assert
            Assert.AreEqual(4, manutencaoPecaInsumoService.GetAll().Count());
            var manutencaoPecaInsumo = manutencaoPecaInsumoService.Get(4, 1004);
            Assert.AreEqual(11.0f, manutencaoPecaInsumo!.Quantidade);
            Assert.AreEqual(6, manutencaoPecaInsumo.MesesGarantia);
            Assert.AreEqual(100.00m, manutencaoPecaInsumo.ValorIndividual);
        }

        [TestMethod()]
        public void DeleteTest()
        {
            // Act
            manutencaoPecaInsumoService!.Delete(2, 1002);
            // Assert
            Assert.AreEqual(2, manutencaoPecaInsumoService.GetAll().Count());
            var manutencaoPecaInsumo = manutencaoPecaInsumoService.Get(2, 1002);
            Assert.AreEqual(null, manutencaoPecaInsumo);
        }

        [TestMethod()]
        public void EditTest()
        {
            //Act 
            var manutencaoPecaInsumo = manutencaoPecaInsumoService!.Get(3, 1003);
            manutencaoPecaInsumo!.Quantidade = 9.5f;
            manutencaoPecaInsumo.MesesGarantia = 8;
            manutencaoPecaInsumoService.Edit(manutencaoPecaInsumo);
            //Assert
            manutencaoPecaInsumo = manutencaoPecaInsumoService.Get(3, 1003);
            Assert.AreEqual(9.5f, manutencaoPecaInsumo!.Quantidade);
            Assert.AreEqual(8, manutencaoPecaInsumo.MesesGarantia);
            Assert.AreEqual(199.99m, manutencaoPecaInsumo.ValorIndividual);
        }

        [TestMethod()]
        public void GetTest()
        {
            var manutencaoPecaInsumo = manutencaoPecaInsumoService!.Get(1, 1001);
            Assert.IsNotNull(manutencaoPecaInsumo);
            Assert.AreEqual(5.5f, manutencaoPecaInsumo!.Quantidade);
            Assert.AreEqual(12, manutencaoPecaInsumo.MesesGarantia);
            Assert.AreEqual(299.99m, manutencaoPecaInsumo.ValorIndividual);
        }

        [TestMethod()]
        public void GetAllTest()
        {
            // Act
            var listaManutencaoPecaInsumo = manutencaoPecaInsumoService!.GetAll();
            // Assert
            Assert.IsInstanceOfType(listaManutencaoPecaInsumo, typeof(IEnumerable<Manutencaopecainsumo>));
            Assert.IsNotNull(listaManutencaoPecaInsumo);
            Assert.AreEqual(3, listaManutencaoPecaInsumo.Count());
            Assert.AreEqual((uint)1, listaManutencaoPecaInsumo.First().IdManutencao);
            Assert.AreEqual((uint)1001, listaManutencaoPecaInsumo.First().IdPecaInsumo);
            Assert.AreEqual(5.5f, listaManutencaoPecaInsumo.First().Quantidade);
        }
    }
}