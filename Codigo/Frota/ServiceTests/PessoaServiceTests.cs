using System.Security.Claims;
using Core;
using Core.Service;
using Microsoft.AspNetCore.Http;
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
                    Cpf = "78766537070",
                    Nome = "Guilherme Lima",
                    Cep = "12345000",
                    Rua = "Rua A",
                    Bairro = "Bairro A",
                    Numero = "100",
                    Complemento = "Casa 1",
                    Cidade = "Cidade A",
                    Estado = "SP",
                    IdFrota = 1,
                    IdPapelPessoa = 1,
                    Ativo = 1
                },
                new Pessoa
                {
                    Id = 2,
                    Cpf = "87637838005",
                    Nome = "Kauã Oliveira",
                    Cep = "54321000",
                    Rua = "Rua B",
                    Bairro = null,
                    Numero = "200",
                    Complemento = null,
                    Cidade = "Cidade B",
                    Estado = "RJ",
                    IdFrota = 1,
                    IdPapelPessoa = 1,
                    Ativo = 1
                },
                new Pessoa
                {
                    Id = 3,
                    Cpf = "85566853072",
                    Nome = "Igor Andrade",
                    Cep = "67890000",
                    Rua = "Rua C",
                    Bairro = "Bairro C",
                    Numero = "300",
                    Complemento = "Prédio 3",
                    Cidade = "Cidade C",
                    Estado = "MG",
                    IdFrota = 3,
                    IdPapelPessoa = 1,
                    Ativo = 0
                },
                new Pessoa
                {
                    Id = 4,
                    Cpf = "98713875043",
                    Nome = "Marcos Santana",
                    Cep = "98765000",
                    Rua = "Rua D",
                    Bairro = "Bairro D",
                    Numero = "400",
                    Complemento = "Bloco 4",
                    Cidade = "Cidade D",
                    Estado = "BA",
                    IdFrota = 4,
                    IdPapelPessoa = 1,
                    Ativo = 1
                }
            };

            var frotas = new List<Frotum>
            {
                new Frotum
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
                new Frotum
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
                new Frotum
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
                new Frotum
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

            context.AddRange(pessoas);
            context.SaveChanges();

            var claims = new List<Claim>
            {
                new Claim(ClaimTypes.Name, "78766537070"),
                new Claim(ClaimTypes.NameIdentifier, "1"),
                new Claim(ClaimTypes.Role, "Administrador") 
            };
            var principal = new ClaimsPrincipal(new ClaimsIdentity(claims, "TestAuthentication"));
            var httpContextAccessor = new HttpContextAccessor
            {
                HttpContext = new DefaultHttpContext
                {
                    User = principal
                }
            };

            pessoaService = new PessoaService(context, new FrotaService(context, httpContextAccessor));
        }

        [TestMethod()]
        public void CreateTest()
        {
            // Act
            pessoaService!.Create(
                new Pessoa
                {
                    Id = 5,
                    Cpf = "40187344094",
                    Nome = "Jonatha Gabriel",
                    Cep = "76543210",
                    Rua = "Rua E",
                    Bairro = "Bairro E",
                    Numero = "500",
                    Complemento = "Casa 5",
                    Cidade = "Cidade E",
                    Estado = "PR",
                    IdFrota = 1,
                    IdPapelPessoa = 1,
                    Ativo = 1
                }
            );

            // Assert
            Assert.AreEqual(3, pessoaService.GetAll().Count());
            var pessoa = pessoaService.Get(5);
            Assert.AreEqual("40187344094", pessoa!.Cpf);
            Assert.AreEqual("Jonatha Gabriel", pessoa.Nome);
        }

        [TestMethod()]
        public void DeleteTest()
        {
            // Act
            pessoaService!.Delete(2);
            // Assert
            Assert.AreEqual(1, pessoaService.GetAll().Count());
            var pessoa = pessoaService.Get(2);
            Assert.AreEqual(null, pessoa);
        }

        [TestMethod()]
        public void EditTest()
        {
            // Act
            var pessoa = pessoaService!.Get(2);
            pessoa!.Cidade = "Mossoró";
            pessoa.Estado = "RN";
            pessoaService.Edit(pessoa);
            // Assert
            pessoa = pessoaService.Get(2);
            Assert.AreEqual("Mossoró", pessoa!.Cidade);
            Assert.AreEqual("RN", pessoa.Estado);
        }

        [TestMethod()]
        public void GetTest()
        {
            var pessoa = pessoaService!.Get(1);
            Assert.IsNotNull(pessoa);
            Assert.AreEqual("78766537070", pessoa!.Cpf);
            Assert.AreEqual("Guilherme Lima", pessoa.Nome);
        }

        [TestMethod()]
        public void GetAllTest()
        {
            // Act
            var listaPessoa = pessoaService!.GetAll();
            // Assert
            Assert.IsInstanceOfType(listaPessoa, typeof(IEnumerable<Pessoa>));
            Assert.IsNotNull(listaPessoa);
            Assert.AreEqual(2, listaPessoa.Count());
            Assert.AreEqual((uint)1, listaPessoa.First().Id);
            Assert.AreEqual("78766537070", listaPessoa.First().Cpf);
        }
    }
}