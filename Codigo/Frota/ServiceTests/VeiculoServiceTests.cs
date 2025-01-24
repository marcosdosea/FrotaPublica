using Core;
using Core.Service;
using Microsoft.EntityFrameworkCore;

namespace Service.Tests
{
    [TestClass()]
    public class VeiculoServiceTests
    {
        private FrotaContext? context;
        private IVeiculoService? veiculoService;

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

            var veiculos = new List<Veiculo>
            {
                new Veiculo
                {
                    Id = 1,
                    Placa = "JSD8135",
                    Chassi = "9BWZZZ377VT004251",
                    Cor = "Branco",
                    IdModeloVeiculo = 2,
                    IdFrota = 1,
                    IdUnidadeAdministrativa = 3,
                    Odometro = 12000,
                    Status = "D",
                    Ano = 2020,
                    Modelo = 2021,
                    Renavan = "12345678901",
                    VencimentoIpva = DateTime.Parse("2024-03-15"),
                    Valor = 45000.00m,
                    DataReferenciaValor = DateTime.Parse("2023-11-01")
                },
                new Veiculo
                {
                    Id = 2,
                    Placa = "MTM7627",
                    Chassi = "8AFZZZ407WT004352",
                    Cor = "Preto",
                    IdModeloVeiculo = 3,
                    IdFrota = 1,
                    IdUnidadeAdministrativa = 4,
                    Odometro = 25000,
                    Status = "M",
                    Ano = 2019,
                    Modelo = 2020,
                    Renavan = "98765432109",
                    VencimentoIpva = DateTime.Parse("2024-06-30"),
                    Valor = 35000.00m,
                    DataReferenciaValor = DateTime.Parse("2023-09-15")
                },
                new Veiculo
                {
                    Id = 3,
                    Placa = "HPQ8748",
                    Chassi = "7FBZZZ322VT009867",
                    Cor = "Prata",
                    IdModeloVeiculo = 1,
                    IdFrota = 2,
                    IdUnidadeAdministrativa = 5,
                    Odometro = 18000,
                    Status = "D",
                    Ano = 2021,
                    Modelo = 2022,
                    Renavan = "11223344556",
                    VencimentoIpva = DateTime.Parse("2024-12-10"),
                    Valor = 55000.00m,
                    DataReferenciaValor = DateTime.Parse("2023-10-10")
                }
            };

            context.AddRange(veiculos);
            context.SaveChanges();

            veiculoService = new VeiculoService(context);
        }

        [TestMethod()]
        public void CreateTest()
        {
            // Act
            veiculoService!.Create(
                new Veiculo
                {
                    Id = 4,
                    Placa = "DEF4567",
                    Chassi = "6G1ZZZ999XT009876",
                    Cor = "Azul",
                    IdModeloVeiculo = 4,
                    IdFrota = 2,
                    IdUnidadeAdministrativa = 6,
                    Odometro = 15000,
                    Status = "I",
                    Ano = 2018,
                    Modelo = 2019,
                    Renavan = "22334455667",
                    VencimentoIpva = DateTime.Parse("2024-05-20"),
                    Valor = 40000.00m,
                    DataReferenciaValor = DateTime.Parse("2023-08-01")
                }
            );

            // Assert
            Assert.AreEqual(2, veiculoService.GetAll(2).Count());
            var veiculo = veiculoService.Get(4);
            Assert.AreEqual("DEF4567", veiculo!.Placa);
            Assert.AreEqual("6G1ZZZ999XT009876", veiculo.Chassi);
        }

        [TestMethod()]
        public void DeleteTest()
        {
            // Act
            veiculoService!.Delete(2);
            // Assert
            Assert.AreEqual(1, veiculoService.GetAll(1).Count());
            var veiculo = veiculoService.Get(2);
            Assert.AreEqual(null, veiculo);
        }

        [TestMethod()]
        public void EditTest()
        {
            //Act 
            var veiculo = veiculoService!.Get(3);
            veiculo!.Placa = "JKL9011";
            veiculo.Chassi = "7FBZZZ322VT009007";
            veiculoService.Edit(veiculo);
            //Assert
            veiculo = veiculoService.Get(3);
            Assert.IsNotNull(veiculo);
            Assert.AreEqual("JKL9011", veiculo.Placa);
            Assert.AreEqual("7FBZZZ322VT009007", veiculo.Chassi);
        }

        [TestMethod()]
        public void GetTest()
        {
            var veiculo = veiculoService!.Get(1);
            Assert.IsNotNull(veiculo);
            Assert.AreEqual("JSD8135", veiculo.Placa);
            Assert.AreEqual("9BWZZZ377VT004251", veiculo.Chassi);
        }

        [TestMethod()]
        public void GetAllTest()
        {
            // Act
            var listaVeiculo = veiculoService!.GetAll(1);
            // Assert
            Assert.IsInstanceOfType(listaVeiculo, typeof(IEnumerable<Veiculo>));
            Assert.IsNotNull(listaVeiculo);
            Assert.AreEqual(2, listaVeiculo.Count());
            Assert.AreEqual((uint)1, listaVeiculo.First().Id);
            Assert.AreEqual("JSD8135", listaVeiculo.First().Placa);
        }
    }
}