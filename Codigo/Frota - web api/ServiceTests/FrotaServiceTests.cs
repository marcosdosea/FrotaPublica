using Core;
using Core.DTO;
using Core.Service;
using Microsoft.EntityFrameworkCore;

namespace Service.Tests
{
    [TestClass()]
    public class FrotaServiceTests
    {
        private FrotaContext? context;
        private IFrotaService? frotaService;

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

            var frotas = new List<Frotum>
            {
                new Frotum
                {
                    Id = 1,
                    Nome = "Transportes Oliveira",
                    Cnpj = "26243946000172",
                    Cep = "79080170",
                    Rua = "Américo Carlos da Costa",
                    Bairro = "Jardim América",
                    Numero = "103",
                    Complemento = null,
                    Cidade = "Campo Grande",
                    Estado = "MS"
                },
                new Frotum
                {
                    Id = 2,
                    Nome = "Logística Santos",
                    Cnpj = "98103198000133",
                    Cep = null,
                    Rua = null,
                    Bairro = null,
                    Numero = null,
                    Complemento = null,
                    Cidade = null,
                    Estado = "RJ"
                },
                new Frotum
                {
                    Id = 3,
                    Nome = "Expresso Litoral",
                    Cnpj = "50806346000150",
                    Cep = "81460090",
                    Rua = null,
                    Bairro = null,
                    Numero = null,
                    Complemento = null,
                    Cidade = "Curitiba",
                    Estado = "PR"
                },
                new Frotum
                {
                    Id = 4,
                    Nome = "Carga Pesada Ltda",
                    Cnpj = "39612223000145",
                    Cep = "60832120",
                    Rua = "Nova Olímpia",
                    Bairro = null,
                    Numero = null,
                    Complemento = null,
                    Cidade = "Fortaleza",
                    Estado = "CE"
                }
            };
            context.AddRange(frotas);
            context.SaveChanges();
            frotaService = new FrotaService(context);
        }

        [TestMethod()]
        public void CreateTest()
        {
            //Act
            frotaService!.Create(
                new Frotum
                {
                    Id = 5,
                    Nome = "Transportadora Rápida",
                    Cnpj = "09802206000100",
                    Cep = null,
                    Rua = null,
                    Bairro = null,
                    Numero = null,
                    Complemento = null,
                    Cidade = "Cuiabá",
                    Estado = "MT"
                }
            );
            //Assert
            Assert.AreEqual(5, frotaService.GetAll().Count());
            var frota = frotaService.Get(5);
            Assert.AreEqual("Transportadora Rápida", frota!.Nome);
            Assert.AreEqual("09802206000100", frota.Cnpj);
        }

        [TestMethod()]
        public void DeleteTest()
        {
            //Act
            frotaService!.Delete(2);
            //Assert
            Assert.AreEqual(3, frotaService.GetAll().Count());
            var frota = frotaService.Get(2);
            Assert.AreEqual(null, frota);
        }

        [TestMethod()]
        public void EditTest()
        {
            //Act
            var frota = frotaService!.Get(3);
            frota!.Nome = "Expresso Litoral S/A";
            frota.Cnpj = "84616529000124";
            frotaService.Edit(frota);
            //Assert
            frota = frotaService.Get(3);
            Assert.AreEqual("Expresso Litoral S/A", frota!.Nome);
            Assert.AreEqual("84616529000124", frota.Cnpj);
        }

        [TestMethod()]
        public void GetTest()
        {
            var frota = frotaService!.Get(1);
            Assert.IsNotNull(frota);
            Assert.AreEqual("Transportes Oliveira", frota.Nome);
            Assert.AreEqual("26243946000172", frota.Cnpj);
        }

        [TestMethod()]
        public void GetAllTest()
        {
            //Act
            var listaFrota = frotaService!.GetAll();
            //Assert
            Assert.IsInstanceOfType(listaFrota, typeof(IEnumerable<Frotum>));
            Assert.IsNotNull(listaFrota);
            Assert.AreEqual(4, listaFrota.Count());
            Assert.AreEqual((uint)1, listaFrota.First().Id);
            Assert.AreEqual("Transportes Oliveira", listaFrota.First().Nome);
            Assert.AreEqual("26243946000172", listaFrota.First().Cnpj);
        }
    }
}