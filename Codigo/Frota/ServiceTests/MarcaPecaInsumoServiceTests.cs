using Core;
using Core.Service;
using Microsoft.EntityFrameworkCore;

namespace Service.Tests
{
    [TestClass()]
    public class MarcaPecaInsumoServiceTests
    {
        private FrotaContext? context;
        private IMarcaPecaInsumoService? marcaPecaInsumoService;

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

            var marcapecainsumos = new List<Marcapecainsumo>
            {
                new Marcapecainsumo
                {
                    Id = 1,
                    Descricao = "Bosch",
                    Idfrota = 1
                },
                new Marcapecainsumo
                {
                    Id = 2,
                    Descricao = "Delphi",
                    Idfrota = 1
                },
                new Marcapecainsumo
                {
                    Id = 3,
                    Descricao = "MTE-Thomson",
                    Idfrota = 2
                }
            };

            context.Marcapecainsumos.AddRange(marcapecainsumos);
            context.SaveChanges();

            marcaPecaInsumoService = new MarcaPecaInsumoService(context);
        }

        [TestMethod()]
        public void CreateTest()
        {
            // Act
            marcaPecaInsumoService!.Create(
                new Marcapecainsumo
                {
                    Id = 4,
                    Descricao = "Valeo",
                    Idfrota = 2
                }
            );
            // Assert
            Assert.AreEqual(4, context!.Marcapecainsumos.Count());
            var marcapecainsumo = marcaPecaInsumoService.Get(4);
            Assert.IsNotNull(marcapecainsumo);
            Assert.AreEqual("Valeo", marcapecainsumo!.Descricao);
        }

        [TestMethod()]
        public void DeleteTest()
        {
            // Act
            marcaPecaInsumoService!.Delete(1);
            // Assert
            Assert.AreEqual(2, context!.Marcapecainsumos.Count());
            var marcapecainsumo = marcaPecaInsumoService.Get(1);
            Assert.IsNull(marcapecainsumo);
        }

        [TestMethod()]
        public void EditTest()
        {
            // Act
            var marcapecainsumo = marcaPecaInsumoService!.Get(3);
            marcapecainsumo!.Descricao = "Magneti Marelli";
            marcaPecaInsumoService.Edit(marcapecainsumo);
            // Assert
            marcapecainsumo = marcaPecaInsumoService.Get(3);
            Assert.AreEqual("Magneti Marelli", marcapecainsumo!.Descricao);
        }

        [TestMethod()]
        public void GetTest()
        {
            // Act
            var marcapecainsumo = marcaPecaInsumoService!.Get(2);
            // Assert
            Assert.IsNotNull(marcapecainsumo);
            Assert.AreEqual("Delphi", marcapecainsumo!.Descricao);
        }

        [TestMethod()]
        public void GetAllTest()
        {
            // Act
            var listaMarcaPecaInsumo = marcaPecaInsumoService!.GetAll();
            // Assert
            Assert.IsInstanceOfType(listaMarcaPecaInsumo, typeof(IEnumerable<Marcapecainsumo>));
            Assert.IsNotNull(listaMarcaPecaInsumo);
            Assert.AreEqual(3, listaMarcaPecaInsumo.Count());
        }
    }
}