using Core;
using Core.DTO;
using Core.Service;
using Microsoft.EntityFrameworkCore;


namespace Service.Tests
{
    [TestClass()]
    public class FornecedorServiceTests
    {
        private FrotaContext? context;
        private IFornecedorService? fornecedorService;

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

            var fornecedores =  new List<Fornecedor>
            {
                new Fornecedor
                {
                    Id = 1,
                    Nome = "Fornecedor A",
                    Cnpj = "12345678901234",
                    Cep = "12345000",
                    Rua = "Rua A",
                    Bairro = "Bairro A",
                    Numero = "100",
                    Complemento = "Sala 1",
                    Cidade = "Cidade A",
                    Estado = "SP",
                    Latitude = -23571234,
                    Longitude = -46453333
                },
                new Fornecedor
                {
                    Id = 2,
                    Nome = "Fornecedor B",
                    Cnpj = "98765432109876",
                    Cep = "54321000",
                    Rua = "Rua B",
                    Bairro = "Bairro B",
                    Numero = "200",
                    Complemento = "Andar 2",
                    Cidade = "Cidade B",
                    Estado = "RJ",
                    Latitude = -22561234,
                    Longitude = -44323333
                },
                new Fornecedor
                {
                    Id = 3,
                    Nome = "Fornecedor C",
                    Cnpj = "11223344556677",
                    Cep = "67890000",
                    Rua = "Rua C",
                    Bairro = "Bairro C",
                    Numero = "300",
                    Complemento = "Prédio 3",
                    Cidade = "Cidade C",
                    Estado = "MG",
                    Latitude = -24561234,
                    Longitude = -45323333
                },
                new Fornecedor
                {
                    Id = 4,
                    Nome = "Fornecedor D",
                    Cnpj = "22334455667788",
                    Cep = "98765000",
                    Rua = "Rua D",
                    Bairro = "Bairro D",
                    Numero = "400",
                    Complemento = "Bloco 4",
                    Cidade = "Cidade D",
                    Estado = "BA",
                    Latitude = -25561234,
                    Longitude = -46323333
                }
            };

            context.AddRange(fornecedores);
            context.SaveChanges();
            fornecedorService = new FornecedorService(context);
        }

        [TestMethod()]
        public void CreateTest()
        {
            //Act
            fornecedorService!.Create(
                new Fornecedor
                {
                    Id = 5,
                    Nome = "Fornecedor E",
                    Cnpj = "33445566778899",
                    Cep = "76543210",
                    Rua = "Rua E",
                    Bairro = "Bairro E",
                    Numero = "500",
                    Complemento = "Sala 5",
                    Cidade = "Cidade E",
                    Estado = "RS",
                    Latitude = -26561234,
                    Longitude = -47323333
                }
            );
            //Assert
            Assert.AreEqual(5, fornecedorService.GetAll().Count());
            var fornecedor = fornecedorService.Get(5);
            Assert.AreEqual("Fornecedor E", fornecedor!.Nome);
            Assert.AreEqual("33445566778899", fornecedor.Cnpj);
        }

        [TestMethod()]
        public void DeleteTest()
        {
            //Act
            fornecedorService!.Delete(2);
            //Assert
            Assert.AreEqual(3, fornecedorService.GetAll().Count());
            var fornecedor = fornecedorService.Get(2);
            Assert.AreEqual(null, fornecedor);
        }

        [TestMethod()]
        public void EditTest()
        {
            //Act
            var fornecedor = fornecedorService!.Get(3);
            fornecedor!.Nome = "Fornecedor C Ltda";
            fornecedor.Cnpj = "11223344556677";
            fornecedorService.Edit(fornecedor);
            //Assert
            fornecedor = fornecedorService.Get(3);
            Assert.AreEqual("Fornecedor C Ltda", fornecedor!.Nome);
            Assert.AreEqual("11223344556677", fornecedor.Cnpj);

        }

        [TestMethod()]
        public void GetTest()
        {
            var fornecedor = fornecedorService!.Get(1);
            Assert.IsNotNull(fornecedor);
            Assert.AreEqual("Fornecedor A", fornecedor!.Nome);
            Assert.AreEqual("12345678901234", fornecedor.Cnpj);
        }

        [TestMethod()]
        public void GetAllTest()
        {
            //Act
            var listaFornecedor = fornecedorService!.GetAll();
            //Assert
            Assert.IsInstanceOfType(listaFornecedor, typeof(IEnumerable<Fornecedor>));
            Assert.IsNotNull(listaFornecedor);
            Assert.AreEqual(4, listaFornecedor.Count());
            Assert.AreEqual((uint)1, listaFornecedor.First().Id);
            Assert.AreEqual("Fornecedor A", listaFornecedor.First().Nome);
        }
    }
}