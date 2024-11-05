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

            var frotas = new List<Frota>
            {
                new Frota
                {
                    Id = 1,
                    Nome = "Transportes Oliveira",
                    Cnpj = "12345678000199",
                    Cep = "12345678",
                    Rua = "Avenida Principal",
                    Bairro = "Centro",
                    Numero = "100",
                    Complemento = "Sala 201",
                    Cidade = "São Paulo",
                    Estado = "SP"
                },
                new Frota
                {
                    Id = 2,
                    Nome = "Logística Santos",
                    Cnpj = "98765432000188",
                    Cep = "98765432",
                    Rua = "Rua das Flores",
                    Bairro = "Vila Nova",
                    Numero = "250",
                    Complemento = "Galpão 3",
                    Cidade = "Rio de Janeiro",
                    Estado = "RJ"
                },
                new Frota
                {
                    Id = 3,
                    Nome = "Expresso Litoral",
                    Cnpj = "45612378000122",
                    Cep = "54321098",
                    Rua = "Avenida Atlântica",
                    Bairro = "Boa Vista",
                    Numero = "300",
                    Complemento = null,
                    Cidade = "Salvador",
                    Estado = "BA"
                },
                new Frota
                {
                    Id = 4,
                    Nome = "Carga Pesada Ltda",
                    Cnpj = "32165498000177",
                    Cep = "67890123",
                    Rua = "Rua do Porto",
                    Bairro = "Industrial",
                    Numero = "75",
                    Complemento = "Bloco B",
                    Cidade = "Curitiba",
                    Estado = "PR"
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
                new Frota
                {
                    Id = 5,
                    Nome = "Transportadora Rápida",
                    Cnpj = "65498732000166",
                    Cep = "76543210",
                    Rua = "Avenida dos Expedicionários",
                    Bairro = "Jardim das Flores",
                    Numero = "150",
                    Complemento = "Sala 301",
                    Cidade = "Belo Horizonte",
                    Estado = "MG"
                }
            );
            //Assert
            Assert.AreEqual(5, frotaService.GetAll().Count());
            var frota = frotaService.Get(5);
            Assert.AreEqual("Transportadora Rápida", frota!.Nome);
            Assert.AreEqual("65498732000166", frota.Cnpj);
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
            frota.Cnpj = "45612378000122";
            frotaService.Edit(frota);
            //Assert
            frota = frotaService.Get(3);
            Assert.AreEqual("Expresso Litoral S/A", frota!.Nome);
            Assert.AreEqual("45612378000122", frota.Cnpj);
        }

        [TestMethod()]
        public void GetTest()
        {
            var frota = frotaService!.Get(1);
            Assert.IsNotNull(frota);
            Assert.AreEqual("Transportes Oliveira", frota.Nome);
            Assert.AreEqual("12345678000199", frota.Cnpj);
        }

        [TestMethod()]
        public void GetAllTest()
        {
            //Act
            var listaFrota = frotaService!.GetAll();
            //Assert
            Assert.IsInstanceOfType(listaFrota, typeof(IEnumerable<Frota>));
            Assert.IsNotNull(listaFrota);
            Assert.AreEqual(4, listaFrota.Count());
            Assert.AreEqual((uint)1, listaFrota.First().Id);
            Assert.AreEqual("Transportes Oliveira", listaFrota.First().Nome);
        }

        [TestMethod()]
        public void GetAllOrdemAlfabeticaTest()
        {
            //Act
            var listaFrota = frotaService!.GetAllOrdemAlfabetica();
            //Assert
            Assert.IsInstanceOfType(listaFrota, typeof(IEnumerable<FrotaDTO>));
            Assert.IsNotNull(listaFrota);
            Assert.AreEqual(4, listaFrota.Count());
            Assert.AreEqual((uint)4, listaFrota.First().Id);
            Assert.AreEqual("Carga Pesada Ltda", listaFrota.First().Nome);
        }
    }
}