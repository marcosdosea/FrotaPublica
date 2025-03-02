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
                    Cep = "16203585068",
                    Rua = "Francisco Gomes",
                    Bairro = "Nova Cidade",
                    Complemento = null,
                    Numero = "12",
                    Cidade = "Itaboraí",
                    Estado = "RJ",
                    IdFrota = 1,
                    IdPapelPessoa = 1,
                    Ativo = 1
                },
                new Pessoa
                {
                    Id = 2,
                    Cpf = "06130691025",
                    Nome = "Kauã Oliveira",
                    Cep = "79002800",
                    Rua = null,
                    Bairro = null,
                    Numero = null,
                    Complemento = null,
                    Cidade = null,
                    Estado = "MS",
                    IdFrota = 1,
                    IdPapelPessoa = 1,
                    Ativo = 1
                },
                new Pessoa
                {
                    Id = 3,
                    Cpf = "20551985054",
                    Nome = "Igor Andrade",
                    Cep = null,
                    Rua = null,
                    Bairro = null,
                    Numero = null,
                    Complemento = null,
                    Cidade = null,
                    Estado = "MG",
                    IdFrota = 2,
                    IdPapelPessoa = 1,
                    Ativo = 0
                },
                new Pessoa
                {
                    Id = 4,
                    Cpf = "95832085078",
                    Nome = "Marcos Santana",
                    Cep = null,
                    Rua = null,
                    Bairro = null,
                    Numero = null,
                    Complemento = null,
                    Cidade = "Aiquara",
                    Estado = "BA",
                    IdFrota = 3,
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
            context.AddRange(pessoas);

            context.SaveChanges();

            var claims = new List<Claim>
            {
                new Claim(ClaimTypes.Name, "78766537070"),
                new Claim(ClaimTypes.NameIdentifier, "1"),
                new Claim(ClaimTypes.Role, "Administrador")
            };
            var principal = new ClaimsPrincipal(new ClaimsIdentity(claims, "TesteAutenticacao"));
            var httpContextAccessor = new HttpContextAccessor
            {
                HttpContext = new DefaultHttpContext
                {
                    User = principal
                }
            };

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
                    Cpf = "48483971038",
                    Nome = "Jonatha Gabriel",
                    Cep = null,
                    Rua = null,
                    Bairro = null,
                    Numero = null,
                    Complemento = null,
                    Cidade = null,
                    Estado = "PR",
                    IdPapelPessoa = 1,
                    Ativo = 1
                },
                3
            );
            // Assert
            Assert.AreEqual(2, pessoaService.GetAll(1).Count());
            var pessoa = pessoaService.Get(5);
            Assert.AreEqual("48483971038", pessoa!.Cpf);
            Assert.AreEqual("Jonatha Gabriel", pessoa.Nome);
        }

        [TestMethod()]
        public void DeleteTest()
        {
            // Act
            pessoaService!.Delete(2);
            // Assert
            Assert.AreEqual(1, pessoaService.GetAll(1).Count());
            var pessoa = pessoaService.Get(2);
            Assert.AreEqual(null, pessoa);
        }

        [TestMethod()]
        public void EditTest()
        {
            // Act
            var pessoa = pessoaService!.Get(4);
            pessoa!.Cidade = "Mossoró";
            pessoa.Estado = "RN";
            pessoaService.Edit(pessoa, 3);
            // Assert
            pessoa = pessoaService.Get(4);
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
            var listaPessoa = pessoaService!.GetAll(3);
            // Assert
            Assert.IsInstanceOfType(listaPessoa, typeof(IEnumerable<Pessoa>));
            Assert.IsNotNull(listaPessoa);
            Assert.AreEqual(1, listaPessoa.Count());
            Assert.AreEqual((uint)4, listaPessoa.First().Id);
            Assert.AreEqual("95832085078", listaPessoa.First().Cpf);
        }
    }
}