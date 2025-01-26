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
                    Descricao = "Filtro de ar Fram",
                    MesesGarantia = 24,
                    KmGarantia = 10000,
                    IdFrota = 1
                },

                new Pecainsumo
                {
                    Id = 2,
                    Descricao = "Óleo do motor",
                    MesesGarantia = 2,
                    KmGarantia = 12000,
                    IdFrota = 1
                },

                new Pecainsumo
                {
                    Id = 3,
                    Descricao = "Pastilhas de freio",
                    MesesGarantia = 6,
                    KmGarantia = 5000,
                    IdFrota = 2
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
                    Descricao = "Bateria Bosch",
                    MesesGarantia = 24,
                    KmGarantia = 20000,
                    IdFrota = 2
                }
            );
            // Assert
            Assert.AreEqual(2, pecaIsumoService.GetAll(2).Count());
            var pecaInsumo = pecaIsumoService.Get(4);
            Assert.AreEqual("Bateria Bosch", pecaInsumo!.Descricao);
        }

        [TestMethod()]
        public void DeleteTest()
        {
            // Act
            pecaIsumoService!.Delete(2);
            // Assert
            Assert.AreEqual(1, pecaIsumoService.GetAll(1).Count());
            var pecaInsumo = pecaIsumoService.Get(2);
            Assert.AreEqual(null, pecaInsumo);
        }

        [TestMethod()]
        public void EditTest()
        {
            //Act 
            var pecaInsumo = pecaIsumoService!.Get(3);
            pecaInsumo!.Descricao = "Pastilhas de freio Brembo";
            pecaIsumoService.Edit(pecaInsumo);
            //Assert
            pecaInsumo = pecaIsumoService!.Get(3);
            Assert.IsNotNull(pecaInsumo);
            Assert.AreEqual("Pastilhas de freio Brembo", pecaInsumo.Descricao);
        }

        [TestMethod()]
        public void GetTest()
        {
            var pecaInsumo = pecaIsumoService!.Get(1);
            Assert.IsNotNull(pecaInsumo);
            Assert.AreEqual("Filtro de ar Fram", pecaInsumo.Descricao);
        }

        [TestMethod()]
        public void GetAllTest()
        {
            // Act
            var listaPecaInsumo = pecaIsumoService!.GetAll(1);
            // Assert
            Assert.IsInstanceOfType(listaPecaInsumo, typeof(IEnumerable<Pecainsumo>));
            Assert.IsNotNull(listaPecaInsumo);
            Assert.AreEqual(2, listaPecaInsumo.Count());
            Assert.AreEqual((uint)1, listaPecaInsumo.First().Id);
            Assert.AreEqual("Filtro de ar Fram", listaPecaInsumo.First().Descricao);
        }
    }
}