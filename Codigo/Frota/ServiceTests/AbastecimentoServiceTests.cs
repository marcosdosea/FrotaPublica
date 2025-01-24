using System.Security.Claims;
using Core;
using Core.Service;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;

namespace Service.Tests
{
    [TestClass()]
    public class AbastecimentoServiceTests
    {
        private FrotaContext? context;
        private IAbastecimentoService? abastecimentoService;
        private uint idFrotaUsuario;

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

            var abastecimentos = new List<Abastecimento>
            {
                new Abastecimento
                {
                    Id = 1,
                    IdFornecedor = 1,
                    IdVeiculo = 1,
                    IdFrota = 1,
                    IdPessoa = 2,
                    DataHora = DateTime.Parse("2021-06-11 14:30:00"),
                    Odometro=15000,
                    Litros=80,
                },
                new Abastecimento
                {
                    Id = 2,
                    IdFornecedor = 2,
                    IdVeiculo = 4,
                    IdFrota = 15,
                    IdPessoa = 46,
                    DataHora = DateTime.Parse("2021-06-15 19:45:28"),
                    Odometro=20000,
                    Litros=60,
                },
                new Abastecimento
                {
                    Id = 3,
                    IdFornecedor = 12,
                    IdVeiculo = 3,
                    IdFrota = 15,
                    IdPessoa = 31,
                    DataHora = DateTime.Parse("2021-06-20 10:00:45"),
                    Odometro=15000,
                    Litros=70,
                }
            };

            var pessoa = new Pessoa
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
                IdFrota = 15,
                IdPapelPessoa = 1,
                Ativo = 1
            };

            context.AddRange(abastecimentos);
            context.AddRange(pessoa);

            context.SaveChanges();

            var httpContextAccessor = new HttpContextAccessor
            {
                HttpContext = new DefaultHttpContext()
            };
            httpContextAccessor.HttpContext.User = new ClaimsPrincipal(
                new ClaimsIdentity(
                    [
                        new Claim(ClaimTypes.Name, "78766537070")
                    ],
                    "TesteAutenticacao"
                )
            );
            idFrotaUsuario = pessoa.IdFrota;
            abastecimentoService = new AbastecimentoService(context, new PessoaService(context, httpContextAccessor));
        }

        [TestMethod()]
        public void CreateTest()
        {
            // Act
            abastecimentoService!.Create(
                new Abastecimento
                {
                    Id = 4,
                    IdFornecedor = 14,
                    IdVeiculo = 19,
                    IdFrota = 15,
                    IdPessoa = 32,
                    DataHora = DateTime.Parse("2021-06-23 16:30:00"),
                    Odometro = 35000,
                    Litros = 90,
                },
                (int)idFrotaUsuario
            );
            // Assert
            Assert.AreEqual(3, abastecimentoService.GetAll((int)idFrotaUsuario).Count());
            var abastecimento = abastecimentoService.Get(4);
            Assert.AreEqual(DateTime.Parse("2021-06-23 16:30:00"), abastecimento!.DataHora);
            Assert.AreEqual(35000, abastecimento.Odometro);
            Assert.AreEqual(90, abastecimento.Litros);
        }

        [TestMethod()]
        public void DeleteTest()
        {
            // Act
            abastecimentoService!.Delete(2);
            // Assert
            Assert.AreEqual(1, abastecimentoService.GetAll((int)idFrotaUsuario).Count());
            var abastecimento = abastecimentoService.Get(2);
            Assert.AreEqual(null, abastecimento);
        }

        [TestMethod()]
        public void EditTest()
        {
            //Act 
            var abastecimento = abastecimentoService!.Get(2);
            abastecimento!.Odometro = 36500;
            abastecimento.Litros = 85;
            abastecimentoService.Edit(abastecimento, (int)idFrotaUsuario);
            //Assert
            abastecimento = abastecimentoService.Get(2);
            Assert.IsNotNull(abastecimento);
            Assert.AreEqual(36500, abastecimento.Odometro);
            Assert.AreEqual(85, abastecimento.Litros);
        }

        [TestMethod()]
        public void GetTest()
        {
            var abastecimento = abastecimentoService!.Get(1);
            Assert.IsNotNull(abastecimento);
            Assert.AreEqual(15000, abastecimento.Odometro);
            Assert.AreEqual(80, abastecimento.Litros);
        }

        [TestMethod()]
        public void GetAllTest()
        {
            // Act
            var listaAbastecimento = abastecimentoService!.GetAll((int)idFrotaUsuario);
            // Assert
            Assert.IsInstanceOfType(listaAbastecimento, typeof(IEnumerable<Abastecimento>));
            Assert.IsNotNull(listaAbastecimento);
            Assert.AreEqual(2, listaAbastecimento.Count());
            Assert.AreEqual((uint)2, listaAbastecimento.First().Id);
            Assert.AreEqual(DateTime.Parse("2021-06-15 19:45:28"), listaAbastecimento.First().DataHora);
        }
    }
}