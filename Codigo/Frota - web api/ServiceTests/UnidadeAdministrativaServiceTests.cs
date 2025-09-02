using System.Runtime.ConstrainedExecution;
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
                    Nome = "Logística Norte",
                    Cep = "59625400",
                    Rua = "Avenida Jorge Coelho de Andrade",
                    Bairro = "Presidente Costa e Silva",
                    Complemento = null,
                    Numero = "12",
                    Cidade = null,
                    Estado = null,
                    Latitude = null,
                    Longitude = null,
                    IdFrota = 1
                },
                new Unidadeadministrativa
                {
                    Id = 2,
                    Nome = "Operacional Sul",
                    Cep = "68909166",
                    Rua = "Sérgio Mendes",
                    Bairro = "Boné Azul",
                    Complemento = "Próximo a padaria Camilinha",
                    Numero = "28",
                    Cidade = "Macapá",
                    Estado = "AP",
                    Latitude = (float) 0.082705,
                    Longitude = (float) -51.0741820,
                    IdFrota = 1
                },
                new Unidadeadministrativa
                {
                    Id = 3,
                    Nome = "Distribuição Leste",
                    Cep = null,
                    Rua = null,
                    Bairro = null,
                    Complemento = null,
                    Numero = null,
                    Cidade = null,
                    Estado = null,
                    Latitude = null,
                    Longitude = null,
                    IdFrota = 2
                },
                new Unidadeadministrativa
                {
                    Id = 4,
                    Nome = "Distribuição Leste",
                    Cep = "59072240",
                    Rua = "Santo Euzébio",
                    Bairro = "Felipe Camarão",
                    Complemento = null,
                    Numero = "12",
                    Cidade = "Natal",
                    Estado = "RN",
                    Latitude = null,
                    Longitude = null,
                    IdFrota = 2
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
                    Nome = "Frota Central",
                    Cep = "20765090",
                    Rua = null,
                    Bairro = null,
                    Complemento = null,
                    Numero = "28",
                    Cidade = "Rio de Janeiro",
                    Estado = "RJ",
                    Latitude = (float)-22.90818,
                    Longitude = (float)-43.18251,
                },
                2
            );
            // Assert
            Assert.AreEqual(2, unidadeAdministrativaService.GetAll(1).Count());
            var unidade = unidadeAdministrativaService.Get(5);
            Assert.AreEqual("Frota Central", unidade!.Nome);
            Assert.AreEqual("20765090", unidade.Cep);
        }

        [TestMethod()]
        public void DeleteTest()
        {
            // Act
            unidadeAdministrativaService!.Delete(2);
            // Assert
            Assert.AreEqual(1, unidadeAdministrativaService.GetAll(1).Count());
            var unidade = unidadeAdministrativaService.Get(2);
            Assert.AreEqual(null, unidade);
        }

        [TestMethod()]
        public void EditTest()
        {
            // Act
            var unidade = unidadeAdministrativaService!.Get(3);
            unidade!.Nome = "Manutenção Zona Norte";
            unidade.Cep = "59114231";
            unidadeAdministrativaService.Edit(unidade, 2);
            // Assert
            unidade = unidadeAdministrativaService.Get(3);
            Assert.AreEqual("Manutenção Zona Norte", unidade!.Nome);
            Assert.AreEqual("59114231", unidade.Cep);
        }

        [TestMethod()]
        public void GetTest()
        {
            var unidade = unidadeAdministrativaService!.Get(1);
            Assert.IsNotNull(unidade);
            Assert.AreEqual("Logística Norte", unidade.Nome);
            Assert.AreEqual("59625400", unidade.Cep);
        }

        [TestMethod()]
        public void GetAllTest()
        {
            // Act
            var listaUnidade = unidadeAdministrativaService!.GetAll(1);
            // Assert
            Assert.IsInstanceOfType(listaUnidade, typeof(IEnumerable<Unidadeadministrativa>));
            Assert.IsNotNull(listaUnidade);
            Assert.AreEqual(2, listaUnidade.Count());
            Assert.AreEqual((uint)1, listaUnidade.First().Id);
            Assert.AreEqual("Logística Norte", listaUnidade.First().Nome);
        }

        [TestMethod()]
        public void GetAllOrdemAlfabeticaTest()
        {
            // Act
            var listaUnidade = unidadeAdministrativaService!.GetAllOrdemAlfabetica(1);
            // Assert
            Assert.IsInstanceOfType(listaUnidade, typeof(IEnumerable<UnidadeAdministrativaDTO>));
            Assert.IsNotNull(listaUnidade);
            Assert.AreEqual(2, listaUnidade.Count());
            Assert.AreEqual((uint)1, listaUnidade.First().Id);
            Assert.AreEqual("Logística Norte", listaUnidade.First().Nome);
        }
    }
}