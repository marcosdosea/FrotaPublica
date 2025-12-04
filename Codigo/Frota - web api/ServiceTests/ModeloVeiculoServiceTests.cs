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
                new Modeloveiculo
                {
                    Id = 1,
                    IdMarcaVeiculo = 101,
                    Nome = "Cargo 1119",
                    CapacidadeTanque = 50,
                    IdFrota = 1
                },
                new Modeloveiculo
                {
                    Id = 2,
                    IdMarcaVeiculo = 102,
                    Nome = "Sprinter",
                    CapacidadeTanque = 60,
                    IdFrota = 1
                },
                new Modeloveiculo
                {
                    Id = 3,
                    IdMarcaVeiculo = 103,
                    Nome = "Fiorino",
                    CapacidadeTanque = 45,
                    IdFrota = 2
                },
                new Modeloveiculo
                {
                    Id = 4,
                    IdMarcaVeiculo = 104,
                    Nome = "Master",
                    CapacidadeTanque = 55,
                    IdFrota = 2
                },
                new Modeloveiculo
                {
                    Id = 5,
                    IdMarcaVeiculo = 105,
                    Nome = "Kombi",
                    CapacidadeTanque = 65,
                    IdFrota = 3
                }
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
                    Nome = "Hilux",
                    CapacidadeTanque = 70,
                    IdFrota = 3
                }
            );
            // Assert
            Assert.AreEqual(2, modeloVeiculoService.GetAll(1).Count());
            var modeloVeiculo = modeloVeiculoService.Get(6);
            Assert.IsNotNull(modeloVeiculo);
            Assert.AreEqual("Hilux", modeloVeiculo.Nome);
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
            modeloVeiculo!.Nome = "Pajeiro";
            modeloVeiculo.CapacidadeTanque = 75;
            modeloVeiculoService.Edit(modeloVeiculo);
            // Assert
            modeloVeiculo = modeloVeiculoService.Get(2);
            Assert.AreEqual("Pajeiro", modeloVeiculo!.Nome);
            Assert.AreEqual(75, modeloVeiculo.CapacidadeTanque);
        }

        [TestMethod()]
        public void GetTest()
        {
            // Act
            var modeloVeiculo = modeloVeiculoService!.Get(3);
            // Assert
            Assert.IsNotNull(modeloVeiculo);
            Assert.AreEqual("Fiorino", modeloVeiculo!.Nome);
        }

        [TestMethod()]
        public void GetAllTest()
        {
            // Act
            var listaModeloVeiculo = modeloVeiculoService!.GetAll(1);
            // Assert
            Assert.IsInstanceOfType(listaModeloVeiculo, typeof(IEnumerable<Modeloveiculo>));
            Assert.IsNotNull(listaModeloVeiculo);
            Assert.AreEqual(2, listaModeloVeiculo.Count());
        }

        [TestMethod()]
        public void GetAllOrdemAlfabeticaTest()
        {
            // Act
            var listaModeloVeiculoDTO = modeloVeiculoService!.GetAllOrdemAlfabetica(1);
            // Assert
            Assert.IsInstanceOfType(listaModeloVeiculoDTO, typeof(IEnumerable<ModeloVeiculoDTO>));
            Assert.IsNotNull(listaModeloVeiculoDTO);
            Assert.AreEqual(2, listaModeloVeiculoDTO.Count());
            Assert.AreEqual("Cargo 1119", listaModeloVeiculoDTO.First().Nome);
        }
    }
}