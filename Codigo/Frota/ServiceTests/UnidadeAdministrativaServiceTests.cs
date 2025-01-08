using Core;
using Core.DTO;
using Core.Service;
using Microsoft.EntityFrameworkCore;

namespace Service.Tests
{
    [TestClass()]
    public class UnidadeAdministrativaServiceTests
    {
        private FrotaContext? context;
        private IUnidadeAdministrativaService? unidadeAdministrativaService;

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

            var unidades = new List<Unidadeadministrativa>
            {
                new Unidadeadministrativa
                {
                    Id = 1,
                    Nome = "Unidade A",
                    Cep = "12345000",
                    Rua = "Rua A",
                    Bairro = "Bairro A",
                    Numero = "100",
                    Complemento = "Prédio 1",
                    Cidade = "Cidade A",
                    Estado = "SP",
                    Latitude = -23.571234f,
                    Longitude = -46.453333f,
                    IdFrota = 1
                },
                new Unidadeadministrativa
                {
                    Id = 2,
                    Nome = "Unidade B",
                    Cep = "54321000",
                    Rua = "Rua B",
                    Bairro = "Bairro B",
                    Numero = "200",
                    Complemento = "Andar 2",
                    Cidade = "Cidade B",
                    Estado = "RJ",
                    Latitude = -22.561234f,
                    Longitude = -44.323333f,
                    IdFrota = 1
                },
                new Unidadeadministrativa
                {
                    Id = 3,
                    Nome = "Unidade C",
                    Cep = "67890000",
                    Rua = "Rua C",
                    Bairro = "Bairro C",
                    Numero = "300",
                    Complemento = "Prédio 3",
                    Cidade = "Cidade C",
                    Estado = "MG",
                    Latitude = -24.561234f,
                    Longitude = -45.323333f,
                    IdFrota = 1
                },
                new Unidadeadministrativa
                {
                    Id = 4,
                    Nome = "Unidade D",
                    Cep = "98765000",
                    Rua = "Rua D",
                    Bairro = "Bairro D",
                    Numero = "400",
                    Complemento = "Bloco 4",
                    Cidade = "Cidade D",
                    Estado = "BA",
                    Latitude = -25.561234f,
                    Longitude = -46.323333f,
                    IdFrota = 1
                }
            };
            context.AddRange(unidades);
            context.SaveChanges();
            unidadeAdministrativaService = new UnidadeAdministrativaService(context);
        }

        [TestMethod()]
        public void CreateTest()
        {
            // Act
            unidadeAdministrativaService!.Create(
                new Unidadeadministrativa
                {
                    Id = 5,
                    Nome = "Unidade E",
                    Cep = "54321000",
                    Rua = "Rua E",
                    Bairro = "Bairro E",
                    Numero = "500",
                    Complemento = "Prédio 5",
                    Cidade = "Cidade E",
                    Estado = "RS",
                    Latitude = -26.561234f,
                    Longitude = -47.323333f,
                    IdFrota = 1
                }, 1 //id da frota
            );
            // Assert
            Assert.AreEqual(5, unidadeAdministrativaService.GetAll(1).Count());
            var unidade = unidadeAdministrativaService.Get(5);
            Assert.AreEqual("Unidade E", unidade!.Nome);
            Assert.AreEqual("54321000", unidade.Cep);
        }

        [TestMethod()]
        public void DeleteTest()
        {
            // Act
            unidadeAdministrativaService!.Delete(2);
            // Assert
            Assert.AreEqual(3, unidadeAdministrativaService.GetAll(1).Count());
            var unidade = unidadeAdministrativaService.Get(2);
            Assert.AreEqual(null, unidade);
        }

        [TestMethod()]
        public void EditTest()
        {
            // Act
            var unidade = unidadeAdministrativaService!.Get(3);
            unidade!.Nome = "Unidade C Alterada";
            unidade.Cep = "67890001";
            unidadeAdministrativaService.Edit(unidade, 1);
            // Assert
            unidade = unidadeAdministrativaService.Get(3);
            Assert.AreEqual("Unidade C Alterada", unidade!.Nome);
            Assert.AreEqual("67890001", unidade.Cep);
        }

        [TestMethod()]
        public void GetTest()
        {
            var unidade = unidadeAdministrativaService!.Get(1);
            Assert.IsNotNull(unidade);
            Assert.AreEqual("Unidade A", unidade.Nome);
            Assert.AreEqual("12345000", unidade.Cep);
        }

        [TestMethod()]
        public void GetAllTest()
        {
            // Act
            var listaUnidade = unidadeAdministrativaService!.GetAll(1);
            // Assert
            Assert.IsInstanceOfType(listaUnidade, typeof(IEnumerable<Unidadeadministrativa>));
            Assert.IsNotNull(listaUnidade);
            Assert.AreEqual(4, listaUnidade.Count());
            Assert.AreEqual((uint)1, listaUnidade.First().Id);
            Assert.AreEqual("Unidade A", listaUnidade.First().Nome);
        }

        [TestMethod()]
        public void GetAllOrdemAlfabeticaTest()
        {
            // Act
            var listaUnidade = unidadeAdministrativaService!.GetAllOrdemAlfabetica(1);
            // Assert
            Assert.IsInstanceOfType(listaUnidade, typeof(IEnumerable<UnidadeAdministrativaDTO>));
            Assert.IsNotNull(listaUnidade);
            Assert.AreEqual(4, listaUnidade.Count());
            Assert.AreEqual((uint)1, listaUnidade.First().Id);
            Assert.AreEqual("Unidade A", listaUnidade.First().Nome);
        }
    }
}