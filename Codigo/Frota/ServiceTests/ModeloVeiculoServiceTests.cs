using Core;
using Core.DTO;
using Core.Service;
using Microsoft.EntityFrameworkCore;

namespace Service.Tests
{
    [TestClass()]
    public class ModeloVeiculoServiceTests
    {
        private FrotaContext? context;
        private IModeloVeiculoService? modeloVeiculoService;

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

            var veiculos = new List<Modeloveiculo>
            {
                new Modeloveiculo { Id = 1, IdMarcaVeiculo = 101, Nome = "Modelo A", CapacidadeTanque = 50 },
                new Modeloveiculo { Id = 2, IdMarcaVeiculo = 102, Nome = "Modelo B", CapacidadeTanque = 60 },
                new Modeloveiculo { Id = 3, IdMarcaVeiculo = 103, Nome = "Modelo C", CapacidadeTanque = 45 },
                new Modeloveiculo { Id = 4, IdMarcaVeiculo = 104, Nome = "Modelo D", CapacidadeTanque = 55 },
                new Modeloveiculo { Id = 5, IdMarcaVeiculo = 105, Nome = "Modelo E", CapacidadeTanque = 65 }
            };

            context.AddRange(veiculos);
            context.SaveChanges();
            modeloVeiculoService = new ModeloVeiculoService(context);
        }

        [TestMethod()]
        public void CreateTest()
        {
            // Act
            modeloVeiculoService!.Create(
                new Modeloveiculo
                {
                    Id = 6,
                    IdMarcaVeiculo = 106,
                    Nome = "Modelo F",
                    CapacidadeTanque = 70
                }
            );
            // Assert
            Assert.AreEqual(6, modeloVeiculoService.GetAll().Count());
            var modeloVeiculo = modeloVeiculoService.Get(6);
            Assert.IsNotNull(modeloVeiculo);
            Assert.AreEqual("Modelo F", modeloVeiculo.Nome);
        }

        [TestMethod()]
        public void DeleteTest()
        {
            // Act
            modeloVeiculoService!.Delete(1);
            // Assert
            Assert.AreEqual(4, context!.Modeloveiculos.Count());
            var modeloVeiculo = modeloVeiculoService.Get(1);
            Assert.AreEqual(null, modeloVeiculo);
        }

        [TestMethod()]
        public void EditTest()
        {
            // Act
            var modeloVeiculo = modeloVeiculoService!.Get(2);
            modeloVeiculo!.Nome = "Modelo G";
            modeloVeiculo.CapacidadeTanque = 75;
            modeloVeiculoService.Edit(modeloVeiculo);
            // Assert
            modeloVeiculo = modeloVeiculoService.Get(2);
            Assert.AreEqual("Modelo G", modeloVeiculo!.Nome);
            Assert.AreEqual(75, modeloVeiculo.CapacidadeTanque);
        }

        [TestMethod()]
        public void GetTest()
        {
            // Act
            var modeloVeiculo = modeloVeiculoService!.Get(3);
            // Assert
            Assert.IsNotNull(modeloVeiculo);
            Assert.AreEqual("Modelo C", modeloVeiculo!.Nome);
        }

        [TestMethod()]
        public void GetAllTest()
        {
            // Act
            var listaModeloVeiculo = modeloVeiculoService!.GetAll();
            // Assert
            Assert.IsInstanceOfType(listaModeloVeiculo, typeof(IEnumerable<Modeloveiculo>));
            Assert.IsNotNull(listaModeloVeiculo);
            Assert.AreEqual(5, listaModeloVeiculo.Count());
        }

        [TestMethod()]
        public void GetAllOrdemAlfabeticaTest()
        {
            // Act
            var listaModeloVeiculoDTO = modeloVeiculoService!.GetAllOrdemAlfabetica();
            // Assert
            Assert.IsInstanceOfType(listaModeloVeiculoDTO, typeof(IEnumerable<ModeloVeiculoDTO>));
            Assert.IsNotNull(listaModeloVeiculoDTO);
            Assert.AreEqual(5, listaModeloVeiculoDTO.Count());
            Assert.AreEqual("Modelo A", listaModeloVeiculoDTO.First().Nome);
        }
    }
}