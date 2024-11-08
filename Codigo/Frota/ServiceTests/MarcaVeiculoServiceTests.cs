using Core;
using Core.DTO;
using Core.Service;
using Microsoft.EntityFrameworkCore;

namespace Service.Tests
{
    [TestClass()]
    public class MarcaVeiculoServiceTests
    {
        private FrotaContext? context;
        private IMarcaVeiculoService? marcaVeiculoService;

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

            var marcasVeiculo = new List<Marcaveiculo>
            {
                new Marcaveiculo
                {
                    Id = 1,
                    Nome = "Volkswagen"
                },
                new Marcaveiculo
                {
                    Id = 2,
                    Nome = "Chevrolet"
                },
                new Marcaveiculo
                {
                    Id = 3,
                    Nome = "Ford"
                }
            };

            context.AddRange(marcasVeiculo);
            context.SaveChanges();
            marcaVeiculoService = new MarcaVeiculoService(context);
        }

        [TestMethod()]
        public void CreateTest()
        {
            // Act
            marcaVeiculoService!.Create(
                new Marcaveiculo
                {
                    Id = 4,
                    Nome = "Fiat"
                }
            );
            // Assert
            Assert.AreEqual(4, marcaVeiculoService!.GetAll().Count());
            var marca = marcaVeiculoService!.Get(4);
            Assert.AreEqual("Fiat", marca!.Nome);
        }

        [TestMethod()]
        public void DeleteTest()
        {
            // Act
            marcaVeiculoService!.Delete(1);
            // Assert
            Assert.AreEqual(2, marcaVeiculoService!.GetAll().Count());
            var marca = marcaVeiculoService!.Get(1);
            Assert.AreEqual(null, marca);
        }

        [TestMethod()]
        public void EditTest()
        {
            // Act
            var marca = marcaVeiculoService!.Get(3);
            marca!.Nome = "Ferrari";
            marcaVeiculoService!.Edit(marca);
            // Assert
            marca = marcaVeiculoService!.Get(3);
            Assert.AreEqual("Ferrari", marca!.Nome);
        }

        [TestMethod()]
        public void GetTest()
        {
            // Act
            var marca = marcaVeiculoService!.Get(2);
            // Assert
            Assert.IsNotNull(marca);
            Assert.AreEqual("Chevrolet", marca!.Nome);
        }

        [TestMethod()]
        public void GetAllTest()
        {
            // Act
            var listaMarcas = marcaVeiculoService!.GetAll();
            // Assert
            Assert.IsInstanceOfType(listaMarcas, typeof(IEnumerable<Marcaveiculo>));
            Assert.IsNotNull(listaMarcas);
            Assert.AreEqual(3, listaMarcas.Count());
        }
    }
}