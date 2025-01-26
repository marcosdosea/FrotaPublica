using Core;
using Core.Service;
using Microsoft.EntityFrameworkCore;

namespace Service.Tests
{
    [TestClass()]
    public class VeiculoPecaInsumoServiceTests
    {
        private FrotaContext? context;
        private IVeiculoPecaInsumoService? service;

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

            List<Veiculopecainsumo> veiculoPecaInsumoList = new List<Veiculopecainsumo>
            {
                new Veiculopecainsumo
                {
                    IdVeiculo = 1,
                    IdPecaInsumo = 101,
                    DataFinalGarantia = new DateTime(2025, 12, 31),
                    KmFinalGarantia = 50000,
                    DataProximaTroca = new DateTime(2024, 06, 15),
                    KmProximaTroca = 30000
                },
                new Veiculopecainsumo
                {
                    IdVeiculo = 2,
                    IdPecaInsumo = 102,
                    DataFinalGarantia = new DateTime(2026, 01, 15),
                    KmFinalGarantia = 60000,
                    DataProximaTroca = new DateTime(2024, 09, 20),
                    KmProximaTroca = 35000
                },
                new Veiculopecainsumo
                {
                    IdVeiculo = 3,
                    IdPecaInsumo = 103,
                    DataFinalGarantia = new DateTime(2027, 05, 10),
                    KmFinalGarantia = 75000,
                    DataProximaTroca = new DateTime(2025, 02, 28),
                    KmProximaTroca = 45000
                }
            };
            context.AddRange(veiculoPecaInsumoList);
            context.SaveChanges();
            service = new VeiculoPecaInsumoService(context);
        }

        [TestMethod()]
        public void CreateTest()
        {
            // Act
            service!.Create(
                new Veiculopecainsumo
                {
                    IdVeiculo = 4,
                    IdPecaInsumo = 101,
                    DataFinalGarantia = new DateTime(2025, 12, 31),
                    KmFinalGarantia = 50000,
                    DataProximaTroca = new DateTime(2024, 06, 15),
                    KmProximaTroca = 30000
                }
            );

            // Assert
            Assert.AreEqual(4, service.GetAll().Count());
            var veiculoPecaInsumo = service.Get(4, 101);
            Assert.AreEqual(50000, veiculoPecaInsumo!.KmFinalGarantia);
            Assert.AreEqual(30000, veiculoPecaInsumo!.KmProximaTroca);
        }

        [TestMethod()]
        public void DeleteTest()
        {
            // Act
            var veiculoPecaInsumo = service!.Get(2, 102);
            service!.Delete(veiculoPecaInsumo!);
            // Assert
            Assert.AreEqual(2, service.GetAll().Count());
            var veiculoPecaInsumoDeletado = service.Get(2, 102);
            Assert.AreEqual(null, veiculoPecaInsumoDeletado);
        }

        [TestMethod()]
        public void EditTest()
        {
            // Act
            var veiculoPecaInsumo = service!.Get(1, 101);
            veiculoPecaInsumo!.KmFinalGarantia = 1;
            veiculoPecaInsumo!.KmProximaTroca = 1;
            service.Edit(veiculoPecaInsumo);

            // Assert
            Assert.AreEqual(1, veiculoPecaInsumo!.KmFinalGarantia);
            Assert.AreEqual(1, veiculoPecaInsumo!.KmProximaTroca);
        }

        [TestMethod()]
        public void GetTest()
        {
            var veiculoPecaInsumo = service!.Get(1, 101);
            Assert.IsNotNull(veiculoPecaInsumo);
            Assert.AreEqual(50000, veiculoPecaInsumo.KmFinalGarantia);
            Assert.AreEqual(30000, veiculoPecaInsumo.KmProximaTroca);
        }

        [TestMethod()]
        public void GetAllTest()
        {
            // Act
            var listaVeiculosPecaInsumos = service!.GetAll();
            // Assert
            Assert.IsInstanceOfType(listaVeiculosPecaInsumos, typeof(IEnumerable<Veiculopecainsumo>));
            Assert.IsNotNull(listaVeiculosPecaInsumos);
            Assert.AreEqual(3, listaVeiculosPecaInsumos.Count());
        }
    }
}