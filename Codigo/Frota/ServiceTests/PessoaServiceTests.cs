using Core;
using Core.Service;
using Microsoft.EntityFrameworkCore;

namespace Service.Tests
{
    [TestClass()]
    public class PessoaServiceTests
    {
        private FrotaContext? context;
        private IPessoaService? pessoaService;

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

            List<Pessoa> pessoas = new List<Pessoa>
            {
                new Pessoa
                {
                    Id = 1,
                    Cpf = "12345678901",
                    Nome = "Pessoa A",
                    Cep = "12345000",
                    Rua = "Rua A",
                    Bairro = "Bairro A",
                    Numero = "100",
                    Complemento = "Casa 1",
                    Cidade = "Cidade A",
                    Estado = "SP",
                    IdFrota = 101,
                    IdPapelPessoa = 201,
                    Ativo = 1
                },
                new Pessoa
                {
                    Id = 2,
                    Cpf = "23456789012",
                    Nome = "Pessoa B",
                    Cep = "54321000",
                    Rua = "Rua B",
                    Bairro = "Bairro B",
                    Numero = "200",
                    Complemento = "Apartamento 2",
                    Cidade = "Cidade B",
                    Estado = "RJ",
                    IdFrota = 102,
                    IdPapelPessoa = 202,
                    Ativo = 1
                },
                new Pessoa
                {
                    Id = 3,
                    Cpf = "34567890123",
                    Nome = "Pessoa C",
                    Cep = "67890000",
                    Rua = "Rua C",
                    Bairro = "Bairro C",
                    Numero = "300",
                    Complemento = "Prédio 3",
                    Cidade = "Cidade C",
                    Estado = "MG",
                    IdFrota = 103,
                    IdPapelPessoa = 203,
                    Ativo = 0
                },
                new Pessoa
                {
                    Id = 4,
                    Cpf = "45678901234",
                    Nome = "Pessoa D",
                    Cep = "98765000",
                    Rua = "Rua D",
                    Bairro = "Bairro D",
                    Numero = "400",
                    Complemento = "Bloco 4",
                    Cidade = "Cidade D",
                    Estado = "BA",
                    IdFrota = 104,
                    IdPapelPessoa = 204,
                    Ativo = 1
                }
            };
            context.AddRange(pessoas);
            context.SaveChanges();
            pessoaService = new PessoaService(context);
        }

        [TestMethod()]
        public void CreateTest()
        {
            // Act
            pessoaService!.Create(
                new Pessoa
                {
                    Id = 5,
                    Cpf = "56789012345",
                    Nome = "Pessoa E",
                    Cep = "76543210",
                    Rua = "Rua E",
                    Bairro = "Bairro E",
                    Numero = "500",
                    Complemento = "Casa 5",
                    Cidade = "Cidade E",
                    Estado = "PR",
                    IdFrota = 105,
                    IdPapelPessoa = 205,
                    Ativo = 1
                }
            );

            // Assert
            Assert.AreEqual(5, pessoaService.GetAll().Count());
            var pessoa = pessoaService.Get(5);
            Assert.AreEqual("56789012345", pessoa!.Cpf);
            Assert.AreEqual("Pessoa E", pessoa.Nome);
        }

        [TestMethod()]
        public void DeleteTest()
        {
            // Act
            pessoaService!.Delete(2);
            // Assert
            Assert.AreEqual(3, pessoaService.GetAll().Count());
            var pessoa = pessoaService.Get(2);
            Assert.AreEqual(null, pessoa);
        }

        [TestMethod()]
        public void EditTest()
        {
            // Act
            var pessoa = pessoaService!.Get(3);
            pessoa!.Cpf = "45678901234";
            pessoa.Nome = "Pessoa D";
            pessoaService.Edit(pessoa);
            // Assert
            pessoa = pessoaService.Get(3);
            Assert.AreEqual("45678901234", pessoa!.Cpf);
            Assert.AreEqual("Pessoa D", pessoa.Nome);
        }

        [TestMethod()]
        public void GetTest()
        {
            var pessoa = pessoaService!.Get(1);
            Assert.IsNotNull(pessoa);
            Assert.AreEqual("12345678901", pessoa!.Cpf);
            Assert.AreEqual("Pessoa A", pessoa.Nome);
        }

        [TestMethod()]
        public void GetAllTest()
        {
            // Act
            var listaPessoa = pessoaService!.GetAll();
            // Assert
            Assert.IsInstanceOfType(listaPessoa, typeof(IEnumerable<Pessoa>));
            Assert.IsNotNull(listaPessoa);
            Assert.AreEqual(4, listaPessoa.Count());
            Assert.AreEqual((uint)1, listaPessoa.First().Id);
            Assert.AreEqual("12345678901", listaPessoa.First().Cpf);
        }
    }
}