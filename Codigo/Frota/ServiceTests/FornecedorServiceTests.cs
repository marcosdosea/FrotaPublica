using Core;
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

            var fornecedores = new List<Fornecedor>
            {
                new Fornecedor
                {
                    Id = 1,
                    Nome = "AutoParts Express",
                    Cnpj = "97234939000152",
                    Cep = "48770971",
                    Rua = "Rua Principal",
                    Bairro = "Canto",
                    Numero = null,
                    Complemento = null,
                    Cidade = "Teofilândia",
                    Estado = "BA",
                    Latitude = -114861,
                    Longitude = -389735,
                    IdFrota = 1
                },
                new Fornecedor
                {
                    Id = 2,
                    Nome = "FuelPro Distribuidora",
                    Cnpj = "84555003000181",
                    Cep = "69068420",
                    Rua = "Rua 14",
                    Bairro = "Raiz",
                    Numero = "16",
                    Complemento = "Andar 2",
                    Cidade = "Manaus",
                    Estado = "AM",
                    Latitude = -312149,
                    Longitude = -599969,
                    IdFrota = 2
                },
                new Fornecedor
                {
                    Id = 3,
                    Nome = "MaxFleet Services",
                    Cnpj = "10803495000140",
                    Cep = "27960168",
                    Rua = "Travessa Matias Barbosa",
                    Bairro = "Macaé",
                    Numero = "20",
                    Complemento = null,
                    Cidade = "Macaé",
                    Estado = "RG",
                    Latitude = -22383873,
                    Longitude = -417826,
                    IdFrota = 2
                },
                new Fornecedor
                {
                    Id = 4,
                    Nome = "RoadSafe Pneus",
                    Cnpj = "53933822000191",
                    Cep = "97545050",
                    Rua = "Rua Álvaro Ignácio de Medeiros",
                    Bairro = "Atlântida",
                    Numero = "400",
                    Complemento = null,
                    Cidade = "Alegrete",
                    Estado = "RS",
                    Latitude = -255612,
                    Longitude = -463233,
                    IdFrota = 3,
                    Ativo = 0
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
                    Nome = "TrackLine Logística",
                    Cnpj = "24926018000187",
                    Cep = "65907502",
                    Rua = "Rua Quinze de Novembro",
                    Bairro = "Nova Imperatriz",
                    Numero = null,
                    Complemento = null,
                    Cidade = "Imperatriz",
                    Estado = "MA",
                    Latitude = -551671,
                    Longitude = -474772,
                    IdFrota = 3
                },
                3
            );
            //Assert
            Assert.AreEqual(2, fornecedorService.GetAll(3).Count());
            var fornecedor = fornecedorService.Get(5);
            Assert.AreEqual("TrackLine Logística", fornecedor!.Nome);
            Assert.AreEqual("24926018000187", fornecedor.Cnpj);
        }

        [TestMethod()]
        public void DeleteTest()
        {
            //Act
            fornecedorService!.Delete(2);
            //Assert
            Assert.AreEqual(1, fornecedorService.GetAll(2).Count());
            var fornecedor = fornecedorService.Get(2);
            Assert.AreEqual(null, fornecedor);
        }

        [TestMethod()]
        public void EditTest()
        {
            //Act
            var fornecedor = fornecedorService!.Get(3);
            fornecedor!.Nome = "ItaPecas Ltda";
            fornecedor.Cnpj = "22557763000170";
            fornecedorService.Edit(fornecedor, 2);
            //Assert
            fornecedor = fornecedorService.Get(3);
            Assert.AreEqual("ItaPecas Ltda", fornecedor!.Nome);
            Assert.AreEqual("22557763000170", fornecedor.Cnpj);

        }

        [TestMethod()]
        public void GetTest()
        {
            var fornecedor = fornecedorService!.Get(1);
            Assert.IsNotNull(fornecedor);
            Assert.AreEqual("AutoParts Express", fornecedor!.Nome);
            Assert.AreEqual("97234939000152", fornecedor.Cnpj);
        }

        [TestMethod()]
        public void GetAllTest()
        {
            //Act
            var listaFornecedor = fornecedorService!.GetAll(3);
            //Assert
            Assert.IsInstanceOfType(listaFornecedor, typeof(IEnumerable<Fornecedor>));
            Assert.IsNotNull(listaFornecedor);
            Assert.AreEqual(1, listaFornecedor.Count());
            Assert.AreEqual((uint)4, listaFornecedor.First().Id);
            Assert.AreEqual("RoadSafe Pneus", listaFornecedor.First().Nome);
        }
    }
}